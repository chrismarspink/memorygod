<script lang="ts">
	import { base } from '$app/paths';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	let sets: any[] = $state([]);
	let todayStats = $state({ reviewed: 0, newCards: 0, streak: 0 });
	let reviewCount = $state(0);
	let loading = $state(true);

	onMount(async () => {
		if (!$user) {
			goto(`${base}/auth/login`);
			return;
		}
		await loadDashboard();
	});

	async function loadDashboard() {
		loading = true;
		const userId = $user!.id;
		const today = new Date().toISOString().split('T')[0];

		// Load user sets
		const { data: ownSets } = await supabase
			.from('card_sets')
			.select('*, cards(count)')
			.eq('owner_id', userId);

		// Load shared sets
		const { data: sharedSets } = await supabase
			.from('shared_sets')
			.select('set_id, card_sets(*, cards(count))')
			.eq('member_id', userId);

		const shared = (sharedSets ?? []).map((s: any) => ({ ...s.card_sets, isShared: true }));
		sets = [...(ownSets ?? []), ...shared];

		// Review count for today
		const { count: revCount } = await supabase
			.from('review_logs')
			.select('*', { count: 'exact', head: true })
			.eq('user_id', userId)
			.lte('next_review_at', today);

		reviewCount = revCount ?? 0;

		// Today's stats
		const { data: stats } = await supabase
			.from('daily_stats')
			.select('*')
			.eq('user_id', userId)
			.eq('study_date', today)
			.maybeSingle();

		todayStats = {
			reviewed: stats?.cards_studied ?? 0,
			newCards: stats?.cards_new ?? 0,
			streak: 0
		};

		// Calculate streak
		const { data: recentStats } = await supabase
			.from('daily_stats')
			.select('study_date')
			.eq('user_id', userId)
			.order('study_date', { ascending: false })
			.limit(30);

		if (recentStats) {
			let streak = 0;
			const d = new Date();
			for (const stat of recentStats) {
				const dateStr = d.toISOString().split('T')[0];
				if (stat.study_date === dateStr) {
					streak++;
					d.setDate(d.getDate() - 1);
				} else {
					break;
				}
			}
			todayStats.streak = streak;
		}

		loading = false;
	}
</script>

<svelte:head>
	<title>기억의 신 - 홈</title>
</svelte:head>

{#if loading}
	<div class="flex items-center justify-center h-screen">
		<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[var(--color-primary)]"></div>
	</div>
{:else}
	<div class="max-w-2xl mx-auto p-4 space-y-6">
		<!-- Header -->
		<div class="flex items-center justify-between">
			<h1 class="text-2xl font-bold text-[var(--color-primary)]">기억의 신</h1>
			<div class="text-sm text-gray-500">{$user?.email}</div>
		</div>

		<!-- Today's review banner -->
		<a
			href="{base}/study"
			class="block bg-[var(--color-primary)] text-white rounded-2xl p-6 shadow-lg hover:shadow-xl transition-shadow"
		>
			<div class="text-sm opacity-80 mb-1">오늘의 학습</div>
			<div class="text-2xl font-bold mb-2">
				복습 {reviewCount}장 + 새 카드 대기중
			</div>
			<div class="inline-flex items-center gap-2 bg-white/20 rounded-full px-4 py-2 text-sm font-medium">
				학습 시작 →
			</div>
		</a>

		<!-- Mini stats -->
		<div class="grid grid-cols-3 gap-3">
			<div class="bg-white rounded-xl p-4 text-center shadow-sm">
				<div class="text-2xl font-bold text-[var(--color-primary)]">{todayStats.reviewed}</div>
				<div class="text-xs text-gray-500 mt-1">오늘 학습</div>
			</div>
			<div class="bg-white rounded-xl p-4 text-center shadow-sm">
				<div class="text-2xl font-bold text-[var(--color-success)]">{sets.length}</div>
				<div class="text-xs text-gray-500 mt-1">내 세트</div>
			</div>
			<div class="bg-white rounded-xl p-4 text-center shadow-sm">
				<div class="text-2xl font-bold text-[var(--color-accent)]">{todayStats.streak}</div>
				<div class="text-xs text-gray-500 mt-1">연속 일수</div>
			</div>
		</div>

		<!-- My sets -->
		<div>
			<div class="flex items-center justify-between mb-3">
				<h2 class="text-lg font-semibold">내 세트</h2>
				<a href="{base}/upload" class="text-sm text-[var(--color-primary)] font-medium">+ 새 세트</a>
			</div>
			{#if sets.length === 0}
				<div class="bg-white rounded-xl p-8 text-center text-gray-400 shadow-sm">
					<p class="mb-2">아직 세트가 없습니다</p>
					<a href="{base}/upload" class="text-[var(--color-primary)] font-medium">엑셀 업로드로 시작하기</a>
				</div>
			{:else}
				<div class="space-y-3">
					{#each sets as set}
						<a href="{base}/sets/{set.id}" class="block bg-white rounded-xl p-4 shadow-sm hover:shadow transition-shadow">
							<div class="flex items-center justify-between mb-2">
								<h3 class="font-medium">{set.title}</h3>
								{#if set.isShared}
									<span class="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">공유</span>
								{/if}
							</div>
							<div class="text-sm text-gray-500">
								{set.cards?.[0]?.count ?? set.card_count ?? 0}장
								{#if set.domains?.length}
									· {set.domains.join(', ')}
								{/if}
							</div>
						</a>
					{/each}
				</div>
			{/if}
		</div>
	</div>
{/if}
