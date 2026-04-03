<script lang="ts">
	import { base } from '$app/paths';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import ProgressRing from '$lib/components/ProgressRing.svelte';

	let sets: any[] = $state([]);
	let todayStats = $state({ reviewed: 0, newCards: 0, streak: 0 });
	let reviewCount = $state(0);
	let ddayText = $state('');
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

		// Load user settings (D-day)
		const { data: settings } = await supabase
			.from('user_settings')
			.select('dday_date')
			.eq('user_id', userId)
			.maybeSingle();

		if (settings?.dday_date) {
			const diff = Math.ceil((new Date(settings.dday_date).getTime() - Date.now()) / 86400000);
			ddayText = diff > 0 ? `D-${diff}` : diff === 0 ? 'D-Day!' : `D+${Math.abs(diff)}`;
		}

		// Load user sets with review progress
		const { data: ownSets } = await supabase
			.from('card_sets')
			.select('*, cards(count)')
			.eq('owner_id', userId);

		const { data: sharedSets } = await supabase
			.from('shared_sets')
			.select('set_id, card_sets(*, cards(count))')
			.eq('member_id', userId);

		const shared = (sharedSets ?? []).map((s: any) => ({
			...s.card_sets,
			isShared: true,
			isEnabled: s.is_active !== false
		}));
		const allSets = [...(ownSets ?? []).map((s: any) => ({
			...s,
			isShared: false,
			isEnabled: s.is_enabled !== false
		})), ...shared];

		// Get mastered count per set
		const { data: reviews } = await supabase
			.from('review_logs')
			.select('card_id, repetition, easiness, cards(set_id)')
			.eq('user_id', userId);

		const setMastery: Record<string, { reviewed: number; mastered: number }> = {};
		(reviews ?? []).forEach((r: any) => {
			const sid = r.cards?.set_id;
			if (!sid) return;
			if (!setMastery[sid]) setMastery[sid] = { reviewed: 0, mastered: 0 };
			setMastery[sid].reviewed++;
			if (r.repetition >= 3 && r.easiness >= 2.0) setMastery[sid].mastered++;
		});

		sets = allSets.map((s: any) => {
			const total = s.cards?.[0]?.count ?? s.card_count ?? 0;
			const m = setMastery[s.id];
			return {
				...s,
				totalCards: total,
				masteredCards: m?.mastered ?? 0,
				reviewedCards: m?.reviewed ?? 0,
				masteryPct: total > 0 && m ? Math.round((m.mastered / total) * 100) : 0,
				isEnabled: s.isEnabled !== false
			};
		});

		// Review count
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
			<div class="flex items-center gap-2">
				{#if ddayText}
					<span class="bg-red-500 text-white text-xs font-bold px-2.5 py-1 rounded-full">{ddayText}</span>
				{/if}
				<div class="w-8 h-8 bg-[var(--color-primary)] text-white rounded-full flex items-center justify-center text-xs font-bold">
					{($user?.email ?? '?')[0].toUpperCase()}
				</div>
			</div>
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
				<div class="text-2xl font-bold text-[var(--color-success)]">
					{sets.reduce((a, s) => a + s.totalCards, 0) > 0
						? Math.round(sets.reduce((a, s) => a + s.masteredCards, 0) / sets.reduce((a, s) => a + s.totalCards, 0) * 100)
						: 0}%
				</div>
				<div class="text-xs text-gray-500 mt-1">숙달도</div>
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
						<a
							href="{base}/sets/{set.id}"
							class="block bg-white rounded-xl p-4 shadow-sm hover:shadow transition-all
								{set.isEnabled ? '' : 'opacity-40'}"
						>
							<div class="flex items-center justify-between mb-2">
								<div class="flex items-center gap-3">
									<ProgressRing
										percent={set.masteryPct}
										size={40}
										strokeWidth={3}
										color={set.isEnabled ? 'var(--color-primary)' : '#d1d5db'}
									/>
									<div>
										<div class="flex items-center gap-2">
											<h3 class="font-medium">{set.title}</h3>
											{#if !set.isEnabled}
												<span class="text-[10px] bg-gray-200 text-gray-500 px-1.5 py-0.5 rounded">학습 제외</span>
											{/if}
										</div>
										<div class="text-xs text-gray-400">{set.totalCards}장 · 숙달 {set.masteryPct}%</div>
									</div>
								</div>
								{#if set.isShared}
									<span class="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">공유</span>
								{/if}
							</div>
							<!-- Progress bar -->
							<div class="w-full h-1.5 bg-gray-100 rounded-full overflow-hidden">
								<div
									class="h-full rounded-full transition-all
										{set.isEnabled ? 'bg-[var(--color-success)]' : 'bg-gray-300'}"
									style="width: {set.masteryPct}%"
								></div>
							</div>
						</a>
					{/each}
				</div>
			{/if}
		</div>
	</div>
{/if}
