<script lang="ts">
	import { base } from '$app/paths';
	import { user, signOut } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	let settings: any = $state(null);
	let loading = $state(true);
	let saving = $state(false);
	let saved = $state(false);

	onMount(async () => {
		if (!$user) { goto(`${base}/auth/login`); return; }
		const { data } = await supabase
			.from('user_settings')
			.select('*')
			.eq('user_id', $user.id)
			.maybeSingle();

		settings = data ?? {
			daily_new_limit: 20,
			daily_rev_limit: 50,
			review_first: true,
			study_mode: 'sequential',
			dday_date: null,
			sleep_start: '23:00',
			sleep_end: '07:00',
			notify_times: ['07:30', '20:00']
		};
		loading = false;
	});

	async function save() {
		saving = true;
		saved = false;
		const { error } = await supabase
			.from('user_settings')
			.upsert({
				user_id: $user!.id,
				daily_new_limit: settings.daily_new_limit,
				daily_rev_limit: settings.daily_rev_limit,
				review_first: settings.review_first,
				study_mode: settings.study_mode,
				dday_date: settings.dday_date || null,
				sleep_start: settings.sleep_start,
				sleep_end: settings.sleep_end,
				notify_times: settings.notify_times,
				updated_at: new Date().toISOString()
			}, { onConflict: 'user_id' });

		saving = false;
		if (!error) {
			saved = true;
			setTimeout(() => saved = false, 2000);
		}
	}

	async function handleSignOut() {
		await signOut();
		goto(`${base}/auth/login`);
	}
</script>

<svelte:head>
	<title>설정 - 기억의 신</title>
</svelte:head>

{#if loading}
	<div class="flex items-center justify-center h-screen">
		<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[var(--color-primary)]"></div>
	</div>
{:else}
	<div class="max-w-lg mx-auto p-4 space-y-6">
		<h1 class="text-xl font-bold">설정</h1>

		<!-- Study settings -->
		<div class="bg-white rounded-xl p-4 shadow-sm space-y-4">
			<h2 class="font-semibold text-gray-800">학습 계획</h2>

			<div>
				<label class="block text-sm text-gray-600 mb-1">시험 D-day</label>
				<input
					type="date"
					bind:value={settings.dday_date}
					class="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)]"
				/>
			</div>

			<div>
				<label class="block text-sm text-gray-600 mb-1">
					하루 새 카드: <span class="font-bold text-[var(--color-primary)]">{settings.daily_new_limit}</span>장
				</label>
				<input
					type="range"
					min="5" max="100" step="5"
					bind:value={settings.daily_new_limit}
					class="w-full accent-[var(--color-primary)]"
				/>
			</div>

			<div>
				<label class="block text-sm text-gray-600 mb-1">
					하루 복습 한도: <span class="font-bold text-[var(--color-primary)]">{settings.daily_rev_limit}</span>장
				</label>
				<input
					type="range"
					min="10" max="200" step="10"
					bind:value={settings.daily_rev_limit}
					class="w-full accent-[var(--color-primary)]"
				/>
			</div>

			<div>
				<label class="block text-sm text-gray-600 mb-1">카드 순서</label>
				<select
					bind:value={settings.study_mode}
					class="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)]"
				>
					<option value="sequential">순서대로</option>
					<option value="associated">연관도순</option>
					<option value="domain">영역별</option>
				</select>
			</div>

			<label class="flex items-center gap-2">
				<input type="checkbox" bind:checked={settings.review_first} class="accent-[var(--color-primary)]" />
				<span class="text-sm text-gray-600">복습 카드 먼저</span>
			</label>
		</div>

		<!-- Notification settings -->
		<div class="bg-white rounded-xl p-4 shadow-sm space-y-4">
			<h2 class="font-semibold text-gray-800">알림 / 수면 보호</h2>

			<div class="grid grid-cols-2 gap-3">
				<div>
					<label class="block text-sm text-gray-600 mb-1">알림 시간 1</label>
					<input
						type="time"
						bind:value={settings.notify_times[0]}
						class="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm"
					/>
				</div>
				<div>
					<label class="block text-sm text-gray-600 mb-1">알림 시간 2</label>
					<input
						type="time"
						bind:value={settings.notify_times[1]}
						class="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm"
					/>
				</div>
			</div>

			<div class="grid grid-cols-2 gap-3">
				<div>
					<label class="block text-sm text-gray-600 mb-1">수면 시작</label>
					<input
						type="time"
						bind:value={settings.sleep_start}
						class="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm"
					/>
				</div>
				<div>
					<label class="block text-sm text-gray-600 mb-1">수면 종료</label>
					<input
						type="time"
						bind:value={settings.sleep_end}
						class="w-full px-3 py-2 border border-gray-200 rounded-lg text-sm"
					/>
				</div>
			</div>
		</div>

		<!-- Save -->
		<button
			onclick={save}
			disabled={saving}
			class="w-full bg-[var(--color-primary)] text-white py-3 rounded-xl font-medium hover:bg-[var(--color-primary-light)] transition-colors disabled:opacity-50"
		>
			{saving ? '저장 중...' : saved ? '저장됨!' : '설정 저장'}
		</button>

		<!-- Account -->
		<div class="bg-white rounded-xl p-4 shadow-sm">
			<h2 class="font-semibold text-gray-800 mb-3">계정</h2>
			<div class="text-sm text-gray-500 mb-3">{$user?.email}</div>
			<button
				onclick={handleSignOut}
				class="w-full py-2 bg-red-50 text-red-600 rounded-lg text-sm font-medium hover:bg-red-100"
			>
				로그아웃
			</button>
		</div>
	</div>
{/if}
