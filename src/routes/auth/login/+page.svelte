<script lang="ts">
	import { base } from '$app/paths';
	import { goto } from '$app/navigation';
	import { signIn } from '$lib/auth';
	import OwlMascot from '$lib/components/OwlMascot.svelte';

	let email = $state('');
	let password = $state('');
	let error = $state('');
	let loading = $state(false);

	async function handleLogin(e: Event) {
		e.preventDefault();
		error = '';
		loading = true;
		try {
			await signIn(email, password);
			goto(`${base}/`);
		} catch (err: any) {
			error = err.message || '로그인에 실패했습니다';
		} finally {
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>로그인 - 기억의 신</title>
</svelte:head>

<div class="min-h-screen flex items-center justify-center p-4 bg-[var(--color-bg)]">
	<div class="w-full max-w-sm">
		<div class="text-center mb-8">
			<div class="flex justify-center mb-3">
				<OwlMascot state="seeyou" size="xl" />
			</div>
			<h1 class="text-3xl font-bold text-[var(--color-primary)] mb-2">기억의 신</h1>
			<p class="text-gray-500 text-sm">과학적 망각곡선 기반 암기 앱</p>
		</div>

		<form onsubmit={handleLogin} class="bg-white rounded-2xl p-6 shadow-sm space-y-4">
			<div>
				<label for="email" class="block text-sm font-medium text-gray-700 mb-1">이메일</label>
				<input
					id="email"
					type="email"
					bind:value={email}
					required
					class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent"
					placeholder="email@example.com"
				/>
			</div>
			<div>
				<label for="password" class="block text-sm font-medium text-gray-700 mb-1">비밀번호</label>
				<input
					id="password"
					type="password"
					bind:value={password}
					required
					minlength="6"
					class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent"
					placeholder="6자 이상"
				/>
			</div>

			{#if error}
				<div class="text-red-500 text-sm bg-red-50 p-3 rounded-xl">{error}</div>
			{/if}

			<button
				type="submit"
				disabled={loading}
				class="w-full bg-[var(--color-primary)] text-white py-3 rounded-xl font-medium hover:bg-[var(--color-primary-light)] transition-colors disabled:opacity-50"
			>
				{loading ? '로그인 중...' : '로그인'}
			</button>
		</form>

		<p class="text-center text-sm text-gray-500 mt-4">
			계정이 없으신가요?
			<a href="{base}/auth/register" class="text-[var(--color-primary)] font-medium">회원가입</a>
		</p>
	</div>
</div>
