<script lang="ts">
	interface Props {
		percent: number;
		size?: number;
		strokeWidth?: number;
		color?: string;
	}

	let { percent, size = 48, strokeWidth = 4, color = 'var(--color-primary)' }: Props = $props();

	const radius = (size - strokeWidth) / 2;
	const circumference = 2 * Math.PI * radius;
	const offset = circumference - (percent / 100) * circumference;
</script>

<svg width={size} height={size} class="transform -rotate-90">
	<circle
		cx={size / 2}
		cy={size / 2}
		r={radius}
		fill="none"
		stroke="#e5e7eb"
		stroke-width={strokeWidth}
	/>
	<circle
		cx={size / 2}
		cy={size / 2}
		r={radius}
		fill="none"
		stroke={color}
		stroke-width={strokeWidth}
		stroke-dasharray={circumference}
		stroke-dashoffset={offset}
		stroke-linecap="round"
		class="transition-all duration-500"
	/>
</svg>
