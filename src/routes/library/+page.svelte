<script lang="ts">
	import { base } from '$app/paths';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	interface LibSet {
		id: string;
		title: string;
		description: string | null;
		author_name: string | null;
		category: string | null;
		domains: string[];
		card_count: number;
		fork_count: number;
		created_at: string;
	}

	const CATEGORIES = [
		{ value: '', label: '전체' },
		{ value: 'language', label: '어학' },
		{ value: 'history', label: '역사' },
		{ value: 'science', label: '과학' },
		{ value: 'it', label: 'IT/기술' },
		{ value: 'etc', label: '기타' }
	];

	let sets: LibSet[] = $state([]);
	let loading = $state(true);
	let search = $state('');
	let category = $state('');
	let sort = $state<'latest' | 'popular'>('latest');
	let forking = $state<string | null>(null);

	onMount(async () => {
		if (!$user) { goto(`${base}/auth/login`); return; }
		await loadLibrary();
	});

	async function loadLibrary() {
		loading = true;

		let query = supabase
			.from('card_sets')
			.select('id, title, description, author_name, category, domains, card_count, fork_count, created_at')
			.eq('is_public', true);

		if (category) {
			query = query.eq('category', category);
		}

		if (search.trim()) {
			query = query.or(`title.ilike.%${search.trim()}%,description.ilike.%${search.trim()}%`);
		}

		if (sort === 'popular') {
			query = query.order('fork_count', { ascending: false });
		} else {
			query = query.order('created_at', { ascending: false });
		}

		query = query.limit(50);

		const { data } = await query;
		sets = (data ?? []) as LibSet[];
		loading = false;
	}

	async function forkSet(setId: string) {
		if (forking) return;
		forking = setId;

		try {
			// 1. Get original set
			const { data: original } = await supabase
				.from('card_sets')
				.select('title, description, domains, category')
				.eq('id', setId)
				.single();

			if (!original) throw new Error('세트를 찾을 수 없습니다');

			// 2. Get original cards
			const { data: cards } = await supabase
				.from('cards')
				.select('front, back, hint, domain, tags, image_url, order_index')
				.eq('set_id', setId)
				.order('order_index');

			// 3. Create new set (copy)
			const { data: newSet, error: setErr } = await supabase
				.from('card_sets')
				.insert({
					owner_id: $user!.id,
					title: original.title,
					description: original.description,
					domains: original.domains,
					category: original.category,
					card_count: cards?.length ?? 0,
					forked_from: setId
				})
				.select()
				.single();

			if (setErr) throw setErr;

			// 4. Copy cards in batches
			if (cards && cards.length > 0) {
				const batchSize = 100;
				for (let i = 0; i < cards.length; i += batchSize) {
					const batch = cards.slice(i, i + batchSize).map(c => ({
						set_id: newSet.id,
						...c
					}));
					await supabase.from('cards').insert(batch);
				}
			}

			// 5. Increment fork count
			await supabase.rpc('increment_fork_count', { p_set_id: setId });

			// 6. Navigate to new set
			goto(`${base}/sets/${newSet.id}`);
		} catch (e: any) {
			alert(e.message || '복제에 실패했습니다');
		} finally {
			forking = null;
		}
	}

	function getCategoryLabel(value: string | null): string {
		return CATEGORIES.find(c => c.value === (value ?? ''))?.label ?? value ?? '';
	}

	// Reactive search/filter
	$effect(() => {
		// Re-run when search, category, or sort changes
		search; category; sort;
		// debounce handled by user action
	});
</script>

<svelte:head>
	<title>라이브러리 - 기억의 신</title>
</svelte:head>

<div class="max-w-3xl mx-auto p-4 space-y-4">
	<div class="flex items-center justify-between">
		<h1 class="text-xl font-bold">공개 라이브러리</h1>
	</div>

	<!-- Search + Filter -->
	<div class="space-y-3">
		<div class="flex gap-2">
			<input
				type="text"
				bind:value={search}
				placeholder="세트 검색..."
				class="flex-1 px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)]"
				oninput={() => loadLibrary()}
			/>
			<button
				onclick={loadLibrary}
				class="px-4 py-2.5 bg-[var(--color-primary)] text-white rounded-xl text-sm font-medium"
			>
				검색
			</button>
		</div>

		<!-- Category tabs -->
		<div class="flex gap-1.5 overflow-x-auto pb-1">
			{#each CATEGORIES as cat}
				<button
					onclick={() => { category = cat.value; loadLibrary(); }}
					class="px-3 py-1.5 rounded-full text-sm whitespace-nowrap transition-colors
						{category === cat.value ? 'bg-[var(--color-primary)] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}"
				>
					{cat.label}
				</button>
			{/each}
		</div>

		<!-- Sort -->
		<div class="flex gap-2 text-sm">
			<button
				onclick={() => { sort = 'latest'; loadLibrary(); }}
				class="px-3 py-1 rounded-lg {sort === 'latest' ? 'font-semibold text-[var(--color-primary)]' : 'text-gray-400'}"
			>
				최신순
			</button>
			<button
				onclick={() => { sort = 'popular'; loadLibrary(); }}
				class="px-3 py-1 rounded-lg {sort === 'popular' ? 'font-semibold text-[var(--color-primary)]' : 'text-gray-400'}"
			>
				인기순
			</button>
		</div>
	</div>

	<!-- Results -->
	{#if loading}
		<div class="flex justify-center py-12">
			<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[var(--color-primary)]"></div>
		</div>
	{:else if sets.length === 0}
		<div class="bg-white rounded-xl p-8 text-center text-gray-400 shadow-sm">
			<p class="text-lg mb-1">공개된 세트가 없습니다</p>
			<p class="text-sm">내 세트를 공개하면 여기에 표시됩니다</p>
		</div>
	{:else}
		<div class="space-y-3">
			{#each sets as set}
				<div class="bg-white rounded-xl p-4 shadow-sm">
					<div class="flex items-start justify-between gap-3">
						<div class="flex-1 min-w-0">
							<div class="flex items-center gap-2 mb-1">
								<h3 class="font-medium truncate">{set.title}</h3>
								{#if set.category}
									<span class="text-xs bg-blue-50 text-blue-600 px-2 py-0.5 rounded-full shrink-0">
										{getCategoryLabel(set.category)}
									</span>
								{/if}
							</div>
							{#if set.description}
								<p class="text-sm text-gray-500 line-clamp-2 mb-2">{set.description}</p>
							{/if}
							<div class="flex items-center gap-3 text-xs text-gray-400">
								{#if set.author_name}
									<span>{set.author_name}</span>
								{/if}
								<span>{set.card_count}장</span>
								<span>복제 {set.fork_count}회</span>
								{#if set.domains?.length}
									<span>{set.domains.slice(0, 3).join(', ')}</span>
								{/if}
							</div>
						</div>
						<button
							onclick={() => forkSet(set.id)}
							disabled={forking === set.id}
							class="shrink-0 px-4 py-2 bg-[var(--color-primary)] text-white rounded-xl text-sm font-medium hover:bg-[var(--color-primary-light)] transition-colors disabled:opacity-50"
						>
							{forking === set.id ? '복제중...' : '+ 내 세트로'}
						</button>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>
