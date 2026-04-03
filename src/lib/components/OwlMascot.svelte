<script lang="ts">
	import { base } from '$app/paths';

	type OwlState =
		| 'loading' | 'seeyou' | 'thinking'
		| 'happy' | 'confused' | 'surprised' | 'sleeping'
		| 'panic' | 'love' | 'bored' | 'sing' | 'smug'
		| 'worry' | 'angry' | 'fear';

	interface Props {
		state?: OwlState;
		size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
	}

	let { state = 'happy', size = 'md' }: Props = $props();

	// Actual paths under static/assets/
	const SRC_MAP: Record<OwlState, string> = {
		loading:   `${base}/assets/logo/owl-color.png`,
		seeyou:    `${base}/assets/splash/owl-seeyou.png`,
		thinking:  `${base}/assets/splash/owl-thinking.png`,
		happy:     `${base}/assets/owl-states/happy.png`,
		confused:  `${base}/assets/owl-states/confused.png`,
		surprised: `${base}/assets/owl-states/surprised.png`,
		sleeping:  `${base}/assets/owl-states/sleeping.png`,
		panic:     `${base}/assets/owl-states/e_panic.png`,
		love:      `${base}/assets/owl-states/e_love.png`,
		bored:     `${base}/assets/owl-states/e_bored.png`,
		sing:      `${base}/assets/owl-states/e_sing.png`,
		smug:      `${base}/assets/owl-states/e_smug.png`,
		worry:     `${base}/assets/owl-states/e_worry.png`,
		angry:     `${base}/assets/owl-states/e_angry.png`,
		fear:      `${base}/assets/owl-states/e_fear.png`,
	};

	const RETINA_MAP: Record<string, string> = {
		loading:   `${base}/assets/logo/owl-color@2x.png`,
		seeyou:    `${base}/assets/splash/owl-seeyou@2x.png`,
		thinking:  `${base}/assets/splash/owl-thinking@2x.png`,
		happy:     `${base}/assets/owl-states/happy@2x.png`,
		confused:  `${base}/assets/owl-states/confused@2x.png`,
		surprised: `${base}/assets/owl-states/surprised@2x.png`,
		sleeping:  `${base}/assets/owl-states/sleeping@2x.png`,
	};

	const SIZE_MAP = {
		xs: 'w-8 h-8',
		sm: 'w-12 h-12',
		md: 'w-20 h-20',
		lg: 'w-32 h-32',
		xl: 'w-48 h-48',
	};
</script>

<img
	src={SRC_MAP[state]}
	srcset={RETINA_MAP[state] ? `${RETINA_MAP[state]} 2x` : undefined}
	alt=""
	aria-hidden="true"
	class="{SIZE_MAP[size]} object-contain"
/>
