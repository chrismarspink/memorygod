<script lang="ts">
	import type { Score } from '$lib/sm2';

	interface Props {
		front: string;
		back: string;
		hint?: string;
		domain?: string;
		image_url?: string;
		flipped: boolean;
		onflip: () => void;
		onrate: (score: Score) => void;
	}

	let { front, back, hint, domain, image_url, flipped, onflip, onrate }: Props = $props();

	let hintLevel = $state(0);

	function getHintText(): string {
		if (!hint && !back) return '';
		const text = hint || back;
		switch (hintLevel) {
			case 1: return `${text.length}글자`;
			case 2: return text[0] + '●'.repeat(text.length - 1);
			case 3: return text.slice(0, Math.ceil(text.length / 2)) + '●'.repeat(text.length - Math.ceil(text.length / 2));
			default: return '';
		}
	}

	function showHint() {
		if (hintLevel < 3) hintLevel++;
	}

	$effect(() => {
		if (front) hintLevel = 0;
	});
</script>

<div class="w-full max-w-md mx-auto">
	<!-- Card with flip animation -->
	<div class="card-perspective">
		<button
			onclick={onflip}
			class="card-inner w-full min-h-[280px] cursor-pointer"
			class:card-flipped={flipped}
		>
			<!-- Front face -->
			<div class="card-face card-front bg-white rounded-2xl shadow-lg p-6 flex flex-col items-center justify-center text-center relative">
				{#if domain}
					<span class="absolute top-4 left-4 text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">
						{domain}
					</span>
				{/if}
				<div class="text-lg font-medium leading-relaxed">{front}</div>
				{#if image_url}
					<img src={image_url} alt="" class="mt-4 max-h-32 rounded-lg object-contain" />
				{/if}
				{#if hintLevel > 0}
					<div class="mt-4 text-sm text-amber-600 bg-amber-50 px-3 py-1.5 rounded-lg">
						{getHintText()}
					</div>
				{/if}
				<div class="mt-4 text-xs text-gray-400">탭하여 정답 확인</div>
			</div>

			<!-- Back face -->
			<div class="card-face card-back bg-white rounded-2xl shadow-lg p-6 flex flex-col items-center justify-center text-center">
				<div class="text-lg font-medium leading-relaxed text-[var(--color-primary)]">{back}</div>
				{#if hint}
					<div class="mt-3 text-sm text-gray-500">{hint}</div>
				{/if}
			</div>
		</button>
	</div>

	<!-- Actions -->
	<div class="mt-4 flex gap-3">
		{#if !flipped}
			<button
				onclick={showHint}
				class="flex-1 py-3 bg-amber-50 text-amber-700 rounded-xl text-sm font-medium hover:bg-amber-100 transition-colors"
			>
				힌트 ({hintLevel}/3)
			</button>
		{:else}
			<button
				onclick={() => onrate(5)}
				class="flex-1 py-3 bg-emerald-50 text-emerald-700 rounded-xl text-sm font-medium hover:bg-emerald-100 transition-colors"
			>
				✓ 알았음
			</button>
			<button
				onclick={() => onrate(3)}
				class="flex-1 py-3 bg-amber-50 text-amber-700 rounded-xl text-sm font-medium hover:bg-amber-100 transition-colors"
			>
				~ 헷갈림
			</button>
			<button
				onclick={() => onrate(1)}
				class="flex-1 py-3 bg-red-50 text-red-700 rounded-xl text-sm font-medium hover:bg-red-100 transition-colors"
			>
				✗ 몰랐음
			</button>
		{/if}
	</div>
</div>

<style>
	.card-perspective {
		perspective: 1000px;
	}
	.card-inner {
		position: relative;
		transition: transform 0.5s ease;
		transform-style: preserve-3d;
	}
	.card-flipped {
		transform: rotateY(180deg);
	}
	.card-face {
		position: absolute;
		inset: 0;
		backface-visibility: hidden;
		-webkit-backface-visibility: hidden;
	}
	.card-back {
		transform: rotateY(180deg);
	}
	.card-front {
		transform: rotateY(0deg);
	}
</style>
