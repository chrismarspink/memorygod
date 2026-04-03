<script lang="ts">
	interface Props {
		domains: string[];
		selected: string;
		onchange: (domain: string) => void;
		counts?: Record<string, number>;
	}

	let { domains, selected, onchange, counts = {} }: Props = $props();
</script>

<div class="flex flex-wrap md:flex-col gap-1">
	<button
		onclick={() => onchange('')}
		class="px-3 py-1.5 rounded-lg text-sm transition-colors
			{!selected ? 'bg-[var(--color-primary)] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}"
	>
		전체 {counts[''] ? `(${counts['']})` : ''}
	</button>
	{#each domains as d}
		<button
			onclick={() => onchange(d)}
			class="px-3 py-1.5 rounded-lg text-sm transition-colors
				{selected === d ? 'bg-[var(--color-primary)] text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}"
		>
			{d} {counts[d] ? `(${counts[d]})` : ''}
		</button>
	{/each}
</div>
