<script lang="ts">
	import { base } from '$app/paths';
	import { page } from '$app/stores';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	const LIB_CATEGORIES = [
		{ value: 'language', label: '어학' },
		{ value: 'history', label: '역사' },
		{ value: 'science', label: '과학' },
		{ value: 'it', label: 'IT/기술' },
		{ value: 'etc', label: '기타' }
	];

	let set: any = $state(null);
	let cards: any[] = $state([]);
	let loading = $state(true);
	let shareCode = $state('');
	let domainFilter = $state('');
	let showShareModal = $state(false);
	let publishCategory = $state('');

	$effect(() => {
		const id = $page.params.id;
		if (id && $user) loadSet(id);
	});

	async function loadSet(id: string) {
		loading = true;

		const { data: s } = await supabase
			.from('card_sets')
			.select('*')
			.eq('id', id)
			.single();

		set = s;

		const { data: c } = await supabase
			.from('cards')
			.select('*')
			.eq('set_id', id)
			.order('order_index');

		cards = c ?? [];
		loading = false;
	}

	function filteredCards() {
		if (!domainFilter) return cards;
		return cards.filter(c => c.domain === domainFilter);
	}

	function uniqueDomains() {
		return [...new Set(cards.map(c => c.domain).filter(Boolean))];
	}

	async function generateShareCode() {
		const code = 'MG-' + Math.random().toString(36).substring(2, 6).toUpperCase();
		const { error } = await supabase
			.from('card_sets')
			.update({ share_code: code, is_shared: true })
			.eq('id', set.id);

		if (!error) {
			set.share_code = code;
			set.is_shared = true;
			shareCode = code;
		}
	}

	async function disableShare() {
		await supabase
			.from('card_sets')
			.update({ is_shared: false, share_code: null })
			.eq('id', set.id);
		set.is_shared = false;
		set.share_code = null;
		shareCode = '';
	}

	async function togglePublic() {
		const newPublic = !set.is_public;
		const updates: any = { is_public: newPublic };
		if (newPublic && publishCategory) {
			updates.category = publishCategory;
			updates.author_name = $user?.email?.split('@')[0] ?? '익명';
		}
		const { error } = await supabase
			.from('card_sets')
			.update(updates)
			.eq('id', set.id);
		if (!error) {
			set.is_public = newPublic;
			if (newPublic) {
				set.category = updates.category;
				set.author_name = updates.author_name;
			}
		}
	}

	async function deleteSet() {
		if (!confirm('이 세트를 삭제하시겠습니까?')) return;
		await supabase.from('card_sets').delete().eq('id', set.id);
		goto(`${base}/sets`);
	}

	onMount(() => {
		if (!$user) goto(`${base}/auth/login`);
	});
</script>

<svelte:head>
	<title>{set?.title ?? '세트'} - 기억의 신</title>
</svelte:head>

{#if loading}
	<div class="flex items-center justify-center h-screen">
		<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[var(--color-primary)]"></div>
	</div>
{:else if set}
	<div class="max-w-5xl mx-auto p-4">
		<!-- Header -->
		<div class="flex items-center justify-between mb-4">
			<div>
				<a href="{base}/sets" class="text-sm text-gray-400 hover:text-gray-600">← 내 세트</a>
				<h1 class="text-xl font-bold mt-1">{set.title}</h1>
				{#if set.description}
					<p class="text-sm text-gray-500">{set.description}</p>
				{/if}
			</div>
			{#if set.owner_id === $user?.id}
				<div class="flex gap-2">
					<button
						onclick={() => showShareModal = !showShareModal}
						class="px-3 py-2 bg-blue-50 text-blue-700 rounded-lg text-sm font-medium"
					>
						공유
					</button>
					<button
						onclick={deleteSet}
						class="px-3 py-2 bg-red-50 text-red-700 rounded-lg text-sm font-medium"
					>
						삭제
					</button>
				</div>
			{/if}
		</div>

		<!-- Share modal -->
		{#if showShareModal}
			<div class="bg-white rounded-xl p-4 shadow-sm mb-4 space-y-4">
				<!-- Share code -->
				<div>
					<h4 class="text-sm font-medium text-gray-700 mb-2">공유 코드</h4>
					{#if set.share_code}
						<div class="flex items-center justify-between">
							<div class="text-2xl font-bold text-[var(--color-primary)] tracking-wider">{set.share_code}</div>
							<button onclick={disableShare} class="text-sm text-red-500">공유 중지</button>
						</div>
					{:else}
						<button
							onclick={generateShareCode}
							class="w-full py-2 bg-[var(--color-primary)] text-white rounded-lg text-sm font-medium"
						>
							공유 코드 생성
						</button>
					{/if}
				</div>

				<!-- Public library toggle -->
				<div class="border-t border-gray-100 pt-4">
					<h4 class="text-sm font-medium text-gray-700 mb-2">공개 라이브러리</h4>
					{#if !set.is_public}
						<div class="space-y-2">
							<select
								bind:value={publishCategory}
								class="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)]"
							>
								<option value="">카테고리 선택</option>
								{#each LIB_CATEGORIES as cat}
									<option value={cat.value}>{cat.label}</option>
								{/each}
							</select>
							<button
								onclick={togglePublic}
								disabled={!publishCategory}
								class="w-full py-2 bg-emerald-500 text-white rounded-lg text-sm font-medium hover:bg-emerald-600 disabled:opacity-50"
							>
								라이브러리에 공개
							</button>
						</div>
					{:else}
						<div class="flex items-center justify-between">
							<span class="text-sm text-emerald-600 font-medium">공개 중</span>
							<button onclick={togglePublic} class="text-sm text-red-500">공개 중지</button>
						</div>
					{/if}
				</div>
			</div>
		{/if}

		<!-- Content: desktop 2-col, mobile 1-col -->
		<div class="flex flex-col md:flex-row md:gap-6">
			<!-- Domain filter (sidebar on desktop) -->
			{#if uniqueDomains().length > 0}
				<div class="md:w-48 mb-4 md:mb-0">
					<div class="bg-white rounded-xl p-3 shadow-sm">
						<h3 class="text-sm font-medium text-gray-700 mb-2">영역 필터</h3>
						<div class="flex flex-wrap md:flex-col gap-1">
							<button
								onclick={() => domainFilter = ''}
								class="px-3 py-1.5 rounded-lg text-sm {!domainFilter ? 'bg-[var(--color-primary)] text-white' : 'bg-gray-100 text-gray-600'}"
							>
								전체 ({cards.length})
							</button>
							{#each uniqueDomains() as d}
								<button
									onclick={() => domainFilter = d}
									class="px-3 py-1.5 rounded-lg text-sm {domainFilter === d ? 'bg-[var(--color-primary)] text-white' : 'bg-gray-100 text-gray-600'}"
								>
									{d} ({cards.filter(c => c.domain === d).length})
								</button>
							{/each}
						</div>
					</div>
				</div>
			{/if}

			<!-- Cards table -->
			<div class="flex-1">
				<div class="bg-white rounded-xl shadow-sm overflow-hidden">
					<table class="w-full text-sm">
						<thead class="bg-gray-50 text-gray-600">
							<tr>
								<th class="px-3 py-2.5 text-left w-10">#</th>
								<th class="px-3 py-2.5 text-left">앞면</th>
								<th class="px-3 py-2.5 text-left">뒷면</th>
								<th class="px-3 py-2.5 text-left hidden md:table-cell">영역</th>
							</tr>
						</thead>
						<tbody>
							{#each filteredCards() as card, i}
								<tr class="border-t border-gray-100 hover:bg-gray-50">
									<td class="px-3 py-2.5 text-gray-400">{card.order_index + 1}</td>
									<td class="px-3 py-2.5">{card.front}</td>
									<td class="px-3 py-2.5 text-gray-600">{card.back}</td>
									<td class="px-3 py-2.5 text-gray-400 hidden md:table-cell">{card.domain || '-'}</td>
								</tr>
							{/each}
						</tbody>
					</table>
					{#if filteredCards().length === 0}
						<div class="p-8 text-center text-gray-400">카드가 없습니다</div>
					{/if}
				</div>
			</div>
		</div>
	</div>
{/if}
