<script lang="ts">
	import { base } from '$app/paths';
	import { page } from '$app/stores';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import StarRating from '$lib/components/StarRating.svelte';

	let set: any = $state(null);
	let previewCards: any[] = $state([]);
	let totalCards = $state(0);
	let avgScore = $state(0);
	let ratingCount = $state(0);
	let myRating = $state(0);
	let loading = $state(true);
	let downloading = $state(false);

	onMount(async () => {
		if (!$user) { goto(`${base}/auth/login`); return; }
		await loadDetail();
	});

	$effect(() => {
		const id = $page.params.id;
		if (id && $user) loadDetail();
	});

	async function loadDetail() {
		loading = true;
		const id = $page.params.id;

		const { data: s } = await supabase
			.from('card_sets')
			.select('*')
			.eq('id', id)
			.eq('is_public', true)
			.single();

		set = s;
		if (!s) { loading = false; return; }

		// Preview cards (first 5)
		const { data: cards, count } = await supabase
			.from('cards')
			.select('front, back, domain', { count: 'exact' })
			.eq('set_id', id)
			.order('order_index')
			.limit(5);

		previewCards = cards ?? [];
		totalCards = count ?? s.card_count ?? 0;

		// Ratings
		const { data: ratings } = await supabase
			.from('library_ratings')
			.select('score, user_id')
			.eq('set_id', id);

		if (ratings && ratings.length > 0) {
			avgScore = ratings.reduce((a: number, r: any) => a + r.score, 0) / ratings.length;
			ratingCount = ratings.length;
			const mine = ratings.find((r: any) => r.user_id === $user!.id);
			myRating = mine?.score ?? 0;
		}

		loading = false;
	}

	async function rateSet(score: number) {
		if (set.owner_id === $user!.id) {
			alert('자신의 세트는 평가할 수 없습니다');
			return;
		}

		await supabase.from('library_ratings').upsert({
			set_id: set.id,
			user_id: $user!.id,
			score,
			updated_at: new Date().toISOString()
		}, { onConflict: 'set_id,user_id' });

		myRating = score;
		await loadDetail();
	}

	async function downloadSet() {
		if (downloading) return;
		downloading = true;

		try {
			// Get all cards
			const { data: cards } = await supabase
				.from('cards')
				.select('front, back, hint, domain, tags, image_url, order_index')
				.eq('set_id', set.id)
				.order('order_index');

			// Create new set
			const { data: newSet, error: setErr } = await supabase
				.from('card_sets')
				.insert({
					owner_id: $user!.id,
					title: set.title,
					description: set.description,
					domains: set.domains,
					category: set.category,
					card_count: cards?.length ?? 0,
					source_set_id: set.id
				})
				.select()
				.single();

			if (setErr) throw setErr;

			// Copy cards
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

			// Increment download count
			await supabase.rpc('increment_download_count', { p_set_id: set.id });

			goto(`${base}/sets/${newSet.id}`);
		} catch (e: any) {
			alert(e.message || '가져오기에 실패했습니다');
		} finally {
			downloading = false;
		}
	}
</script>

<svelte:head>
	<title>{set?.title ?? '세트'} - 라이브러리</title>
</svelte:head>

{#if loading}
	<div class="flex items-center justify-center h-screen">
		<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[var(--color-primary)]"></div>
	</div>
{:else if !set}
	<div class="flex flex-col items-center justify-center h-screen p-4 text-center">
		<p class="text-gray-400 text-lg">세트를 찾을 수 없습니다</p>
		<a href="{base}/library" class="mt-4 text-[var(--color-primary)] font-medium">라이브러리로 돌아가기</a>
	</div>
{:else}
	<div class="max-w-2xl mx-auto p-4 space-y-6">
		<!-- Back link -->
		<a href="{base}/library" class="text-sm text-gray-400 hover:text-gray-600">← 라이브러리</a>

		<!-- Header -->
		<div>
			<h1 class="text-2xl font-bold">{set.title}</h1>
			{#if set.description}
				<p class="text-gray-500 mt-1">{set.description}</p>
			{/if}
			<div class="flex items-center gap-3 mt-3 text-sm text-gray-400">
				{#if set.author_name}
					<span>{set.author_name}</span>
				{/if}
				<span>{totalCards}장</span>
				<span>다운로드 {set.download_count ?? 0}회</span>
			</div>

			<!-- Rating display -->
			<div class="mt-3">
				<StarRating score={avgScore} count={ratingCount} />
			</div>
		</div>

		<!-- Download button -->
		<button
			onclick={downloadSet}
			disabled={downloading}
			class="w-full py-3 bg-[var(--color-primary)] text-white rounded-xl text-base font-medium hover:bg-[var(--color-primary-light)] transition-colors disabled:opacity-50"
		>
			{downloading ? '가져오는 중...' : '내 세트에 추가'}
		</button>

		<!-- My rating -->
		{#if set.owner_id !== $user?.id}
			<div class="bg-white rounded-xl p-4 shadow-sm">
				<h3 class="text-sm font-medium text-gray-700 mb-2">내 평가</h3>
				<StarRating score={myRating} interactive={true} onrate={rateSet} />
			</div>
		{/if}

		<!-- Card preview -->
		<div class="bg-white rounded-xl shadow-sm overflow-hidden">
			<div class="px-4 py-3 bg-gray-50 flex justify-between text-sm text-gray-600">
				<span>카드 미리보기</span>
				<span>{previewCards.length} / {totalCards}장</span>
			</div>
			<table class="w-full text-sm">
				<tbody>
					{#each previewCards as card, i}
						<tr class="border-t border-gray-100">
							<td class="px-4 py-3 text-gray-400 w-8">{i + 1}</td>
							<td class="px-4 py-3 font-medium">{card.front}</td>
							<td class="px-4 py-3 text-gray-500">{card.back}</td>
							{#if card.domain}
								<td class="px-4 py-3 text-gray-400 text-xs hidden md:table-cell">{card.domain}</td>
							{/if}
						</tr>
					{/each}
				</tbody>
			</table>
			{#if totalCards > 5}
				<div class="px-4 py-3 text-center text-xs text-gray-400 border-t border-gray-100">
					+{totalCards - 5}장 더 있습니다
				</div>
			{/if}
		</div>

		<!-- Domains -->
		{#if set.domains?.length}
			<div class="flex flex-wrap gap-1">
				{#each set.domains as d}
					<span class="text-xs bg-blue-50 text-blue-600 px-2 py-0.5 rounded-full">{d}</span>
				{/each}
			</div>
		{/if}
	</div>
{/if}
