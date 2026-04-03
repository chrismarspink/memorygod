<script lang="ts">
	import { base } from '$app/paths';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import StreakCalendar from '$lib/components/StreakCalendar.svelte';

	let weeklyData: { date: string; count: number }[] = $state([]);
	let domainStats: { domain: string; total: number; mastered: number }[] = $state([]);
	let streakDays: string[] = $state([]);
	let totalCards = $state(0);
	let masteredCards = $state(0);
	let loading = $state(true);

	onMount(async () => {
		if (!$user) { goto(`${base}/auth/login`); return; }
		await loadStats();
	});

	async function loadStats() {
		loading = true;
		const userId = $user!.id;
		const today = new Date();

		// Weekly data (last 7 days) — use range query instead of .in()
		const weekDates: string[] = [];
		for (let i = 6; i >= 0; i--) {
			const d = new Date(today);
			d.setDate(d.getDate() - i);
			weekDates.push(d.toISOString().split('T')[0]);
		}

		const weekStart = weekDates[0];
		const weekEnd = weekDates[weekDates.length - 1];

		const { data: weekStats } = await supabase
			.from('daily_stats')
			.select('study_date, cards_studied')
			.eq('user_id', userId)
			.gte('study_date', weekStart)
			.lte('study_date', weekEnd);

		const statsMap = new Map((weekStats ?? []).map((s: any) => [s.study_date, s.cards_studied]));
		weeklyData = weekDates.map(d => ({
			date: d,
			count: statsMap.get(d) ?? 0
		}));

		// Streak days (last 30 days)
		const thirtyDaysAgo = new Date(today);
		thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

		const { data: allStats } = await supabase
			.from('daily_stats')
			.select('study_date, cards_studied')
			.eq('user_id', userId)
			.gte('study_date', thirtyDaysAgo.toISOString().split('T')[0])
			.order('study_date', { ascending: false });

		streakDays = (allStats ?? []).filter((s: any) => s.cards_studied > 0).map((s: any) => s.study_date);

		// Domain mastery
		const { data: reviews } = await supabase
			.from('review_logs')
			.select('card_id, easiness, repetition, cards(domain)')
			.eq('user_id', userId);

		const domainMap = new Map<string, { total: number; mastered: number }>();
		(reviews ?? []).forEach((r: any) => {
			const domain = r.cards?.domain || '미분류';
			if (!domainMap.has(domain)) domainMap.set(domain, { total: 0, mastered: 0 });
			const d = domainMap.get(domain)!;
			d.total++;
			if (r.repetition >= 3 && r.easiness >= 2.0) d.mastered++;
		});

		domainStats = [...domainMap.entries()].map(([domain, stats]) => ({
			domain,
			...stats
		}));

		totalCards = (reviews ?? []).length;
		masteredCards = (reviews ?? []).filter((r: any) => r.repetition >= 3 && r.easiness >= 2.0).length;

		loading = false;
	}

	function dayLabel(dateStr: string) {
		const days = ['일', '월', '화', '수', '목', '금', '토'];
		return days[new Date(dateStr).getDay()];
	}

	function maxCount() {
		return Math.max(...weeklyData.map(d => d.count), 1);
	}
</script>

<svelte:head>
	<title>통계 - 기억의 신</title>
</svelte:head>

{#if loading}
	<div class="flex items-center justify-center h-screen">
		<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[var(--color-primary)]"></div>
	</div>
{:else}
	<div class="max-w-2xl mx-auto p-4 space-y-6">
		<h1 class="text-xl font-bold">학습 통계</h1>

		<!-- Overall -->
		<div class="grid grid-cols-2 gap-3">
			<div class="bg-white rounded-xl p-4 shadow-sm text-center">
				<div class="text-2xl font-bold text-[var(--color-primary)]">{totalCards}</div>
				<div class="text-xs text-gray-500 mt-1">학습한 카드</div>
			</div>
			<div class="bg-white rounded-xl p-4 shadow-sm text-center">
				<div class="text-2xl font-bold text-[var(--color-success)]">
					{totalCards > 0 ? Math.round((masteredCards / totalCards) * 100) : 0}%
				</div>
				<div class="text-xs text-gray-500 mt-1">숙달도</div>
			</div>
		</div>

		<!-- Weekly chart -->
		<div class="bg-white rounded-xl p-4 shadow-sm">
			<h3 class="text-sm font-medium text-gray-700 mb-4">주간 학습량</h3>
			<div class="flex items-end gap-2 h-32">
				{#each weeklyData as day}
					<div class="flex-1 flex flex-col items-center">
						<div class="text-xs text-gray-500 mb-1">{day.count}</div>
						<div
							class="w-full rounded-t-lg bg-[var(--color-primary)] transition-all min-h-[4px]"
							style="height: {day.count > 0 ? (day.count / maxCount()) * 100 : 4}%"
						></div>
						<div class="text-xs text-gray-400 mt-1">{dayLabel(day.date)}</div>
					</div>
				{/each}
			</div>
		</div>

		<!-- Domain mastery -->
		{#if domainStats.length > 0}
			<div class="bg-white rounded-xl p-4 shadow-sm">
				<h3 class="text-sm font-medium text-gray-700 mb-3">영역별 숙달도</h3>
				<div class="space-y-3">
					{#each domainStats as ds}
						{@const pct = ds.total > 0 ? Math.round((ds.mastered / ds.total) * 100) : 0}
						<div>
							<div class="flex justify-between text-sm mb-1">
								<span>{ds.domain}</span>
								<span class="text-gray-500">{pct}% ({ds.mastered}/{ds.total})</span>
							</div>
							<div class="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
								<div class="h-full bg-[var(--color-success)] rounded-full" style="width: {pct}%"></div>
							</div>
						</div>
					{/each}
				</div>
			</div>
		{/if}

		<!-- Streak calendar -->
		<div class="bg-white rounded-xl p-4 shadow-sm">
			<h3 class="text-sm font-medium text-gray-700 mb-3">연속 학습</h3>
			<StreakCalendar {streakDays} />
		</div>
	</div>
{/if}
