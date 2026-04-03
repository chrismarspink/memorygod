<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { base } from '$app/paths';
	import { goto } from '$app/navigation';
	import { initAuth, user, signOut } from '$lib/auth';
	import OwlMascot from '$lib/components/OwlMascot.svelte';
	import '../app.css';

	async function handleSignOut() {
		await signOut();
		goto(`${base}/auth/login`);
	}

	let { children } = $props();
	let authReady = $state(false);

	const publicPaths = [`${base}/auth/login`, `${base}/auth/register`];

	onMount(async () => {
		await initAuth();
		authReady = true;
	});

	$effect(() => {
		if (!authReady) return;
		const path = $page.url.pathname;
		const isPublic = publicPaths.some(p => path.startsWith(p));
		if (!$user && !isPublic) {
			goto(`${base}/auth/login`);
		}
	});

	const navItems = [
		{ href: `${base}/`, icon: '🏠', label: '홈' },
		{ href: `${base}/study`, icon: '📖', label: '학습' },
		{ href: `${base}/library`, icon: '🔍', label: '탐색' },
		{ href: `${base}/sets`, icon: '📚', label: '세트' },
		{ href: `${base}/stats`, icon: '📊', label: '통계' },
		{ href: `${base}/settings`, icon: '⚙️', label: '설정' }
	];

	function isActive(href: string, pathname: string): boolean {
		if (href === `${base}/`) return pathname === `${base}/` || pathname === `${base}`;
		return pathname.startsWith(href);
	}
</script>

{#if !authReady}
	<div class="flex items-center justify-center h-screen bg-[var(--color-bg)]">
		<div class="text-center">
			<OwlMascot state="loading" size="xl" />
			<p class="mt-4 text-sm text-gray-400">기억을 불러오는 중...</p>
		</div>
	</div>
{:else if $user}
	<!-- Desktop sidebar -->
	<nav class="hidden md:flex fixed left-0 top-0 h-full w-16 flex-col items-center bg-[var(--color-primary)] py-4 z-50">
		<div class="text-white font-bold text-lg mb-4">MG</div>
		<div class="flex flex-col items-center gap-2 flex-1">
			{#each navItems as item}
				<a
					href={item.href}
					class="flex flex-col items-center justify-center w-12 h-12 rounded-lg text-xs transition-colors
						{isActive(item.href, $page.url.pathname) ? 'bg-white/20 text-white' : 'text-white/60 hover:text-white hover:bg-white/10'}"
				>
					<span class="text-lg">{item.icon}</span>
					<span class="mt-0.5">{item.label}</span>
				</a>
			{/each}
		</div>
		<!-- Account + Logout at bottom -->
		<div class="flex flex-col items-center gap-2 mt-auto pt-2 border-t border-white/10 w-full">
			<div class="w-8 h-8 bg-white/20 text-white rounded-full flex items-center justify-center text-xs font-bold" title={$user?.email}>
				{($user?.email ?? '?')[0].toUpperCase()}
			</div>
			<button
				onclick={handleSignOut}
				class="flex flex-col items-center justify-center w-12 h-12 rounded-lg text-xs text-white/60 hover:text-white hover:bg-white/10 transition-colors"
				title="로그아웃"
			>
				<span class="text-lg">🚪</span>
				<span class="mt-0.5">로그아웃</span>
			</button>
		</div>
	</nav>

	<!-- Mobile bottom tabs -->
	<nav class="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 flex justify-around items-center h-14 z-50 safe-bottom">
		{#each navItems as item}
			<a
				href={item.href}
				class="flex flex-col items-center justify-center flex-1 h-full text-xs transition-colors
					{isActive(item.href, $page.url.pathname) ? 'text-[var(--color-primary)] font-semibold' : 'text-gray-400'}"
			>
				<span class="text-lg">{item.icon}</span>
				<span class="mt-0.5">{item.label}</span>
			</a>
		{/each}
	</nav>

	<!-- Main content -->
	<main class="md:ml-16 pb-16 md:pb-0 min-h-screen">
		{@render children()}
	</main>
{:else}
	{@render children()}
{/if}

<style>
	.safe-bottom {
		padding-bottom: env(safe-area-inset-bottom);
	}
</style>
