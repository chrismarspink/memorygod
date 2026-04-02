<script lang="ts">
	import { base } from '$app/paths';
	import { goto } from '$app/navigation';
	import { signUp } from '$lib/auth';
	import { supabase } from '$lib/supabase';

	let email = $state('');
	let password = $state('');
	let confirmPassword = $state('');
	let error = $state('');
	let loading = $state(false);
	let success = $state(false);

	async function handleRegister(e: Event) {
		e.preventDefault();
		error = '';

		if (password !== confirmPassword) {
			error = '비밀번호가 일치하지 않습니다';
			return;
		}

		loading = true;
		try {
			const data = await signUp(email, password);
			// Create default user_settings
			if (data.user) {
				await supabase.from('user_settings').insert({ user_id: data.user.id });
			}
			success = true;
		} catch (err: any) {
			error = err.message || '회원가입에 실패했습니다';
		} finally {
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>회원가입 - 기억의 신</title>
</svelte:head>

<div class="min-h-screen flex items-center justify-center p-4 bg-[var(--color-bg)]">
	<div class="w-full max-w-sm">
		<div class="text-center mb-8">
			<h1 class="text-3xl font-bold text-[var(--color-primary)] mb-2">기억의 신</h1>
			<p class="text-gray-500 text-sm">회원가입</p>
		</div>

		{#if success}
			<div class="bg-white rounded-2xl p-6 shadow-sm text-center space-y-4">
				<div class="text-4xl">✉️</div>
				<h2 class="text-lg font-semibold">이메일을 확인해주세요</h2>
				<p class="text-sm text-gray-500">
					{email}로 확인 메일을 보냈습니다.<br/>
					메일의 링크를 클릭하면 가입이 완료됩니다.
				</p>
				<a href="{base}/auth/login" class="inline-block text-[var(--color-primary)] font-medium text-sm">
					로그인으로 이동
				</a>
			</div>
		{:else}
			<form onsubmit={handleRegister} class="bg-white rounded-2xl p-6 shadow-sm space-y-4">
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
				<div>
					<label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-1">비밀번호 확인</label>
					<input
						id="confirmPassword"
						type="password"
						bind:value={confirmPassword}
						required
						minlength="6"
						class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent"
						placeholder="비밀번호 재입력"
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
					{loading ? '가입 중...' : '회원가입'}
				</button>
			</form>

			<p class="text-center text-sm text-gray-500 mt-4">
				이미 계정이 있으신가요?
				<a href="{base}/auth/login" class="text-[var(--color-primary)] font-medium">로그인</a>
			</p>
		{/if}
	</div>
</div>
