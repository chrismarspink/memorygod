<script lang="ts">
	interface Props {
		score: number;
		count?: number;
		interactive?: boolean;
		onrate?: (score: number) => void;
	}

	let { score, count = 0, interactive = false, onrate }: Props = $props();
	let hoverScore = $state(0);
</script>

<div class="inline-flex items-center gap-1">
	<div class="flex">
		{#each [1, 2, 3, 4, 5] as star}
			{#if interactive}
				<button
					onclick={() => onrate?.(star)}
					onmouseenter={() => hoverScore = star}
					onmouseleave={() => hoverScore = 0}
					class="text-xl leading-none transition-colors
						{(hoverScore || score) >= star ? 'text-amber-400' : 'text-gray-300'}"
				>
					★
				</button>
			{:else}
				<span class="text-sm leading-none {score >= star ? 'text-amber-400' : score >= star - 0.5 ? 'text-amber-300' : 'text-gray-300'}">
					★
				</span>
			{/if}
		{/each}
	</div>
	{#if count > 0}
		<span class="text-xs text-gray-400 ml-1">{score.toFixed(1)} ({count}명)</span>
	{/if}
</div>
