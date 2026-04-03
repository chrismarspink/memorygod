<script lang="ts">
	interface Props {
		streakDays: string[];
		days?: number;
	}

	let { streakDays, days = 7 }: Props = $props();

	const dayLabels = ['일', '월', '화', '수', '목', '금', '토'];

	function getDates(): { date: string; day: string; active: boolean }[] {
		const result = [];
		for (let i = days - 1; i >= 0; i--) {
			const d = new Date();
			d.setDate(d.getDate() - i);
			const dateStr = d.toISOString().split('T')[0];
			result.push({
				date: dateStr,
				day: dayLabels[d.getDay()],
				active: streakDays.includes(dateStr)
			});
		}
		return result;
	}
</script>

<div class="flex gap-1.5 justify-center">
	{#each getDates() as { date, day, active }}
		<div class="flex flex-col items-center gap-1">
			<div
				class="w-8 h-8 rounded-lg flex items-center justify-center text-xs font-medium transition-colors
					{active ? 'bg-[var(--color-success)] text-white' : 'bg-gray-100 text-gray-400'}"
			>
				{new Date(date).getDate()}
			</div>
			<span class="text-[10px] text-gray-400">{day}</span>
		</div>
	{/each}
</div>
