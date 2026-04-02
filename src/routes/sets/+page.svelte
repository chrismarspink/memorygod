<script lang="ts">
	import { base } from '$app/paths';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	let sets: any[] = $state([]);
	let shareCodeInput = $state('');
	let loading = $state(true);
	let joinError = $state('');
	let joinLoading = $state(false);

	onMount(async () => {
		if (!$user) { goto(`${base}/auth/login`); return; }
		await loadSets();
	});

	async function loadSets() {
		loading = true;
		const userId = $user!.id;

		const { data: own } = await supabase
			.from('card_sets')
			.select('*, cards(count)')
			.eq('owner_id', userId)
			.order('created_at', { ascending: false });

		const { data: shared } = await supabase
			.from('shared_sets')
			.select('*, card_sets(*, cards(count))')
			.eq('member_id', userId);

		const sharedMapped = (shared ?? []).map((s: any) => ({
			...s.card_sets,
			isShared: true,
			isActive: s.is_active,
			sharedSetId: s.id
		}));

		sets = [...(own ?? []), ...sharedMapped];
		loading = false;
	}

	async function joinByCode() {
		if (!shareCodeInput.trim()) return;
		joinLoading = true;
		joinError = '';

		const { data: set } = await supabase
			.from('card_sets')
			.select('id, owner_id')
			.eq('share_code', shareCodeInput.trim().toUpperCase())
			.eq('is_shared', true)
			.maybeSingle();

		if (!set) {
			joinError = '유효하지 않은 공유 코드입니다';
			joinLoading = false;
			return;
		}

		const { error } = await supabase.from('shared_sets').insert({
			set_id: set.id,
			owner_id: set.owner_id,
			member_id: $user!.id
		});

		if (error) {
			joinError = error.code === '23505' ? '이미 참여한 세트입니다' : error.message;
		} else {
			shareCodeInput = '';
			await loadSets();
		}
		joinLoading = false;
	}
</script>

<svelte:head>
	<title>내 세트 - 기억의 신</title>
</svelte:head>

<div class="max-w-2xl mx-auto p-4 space-y-6">
	<div class="flex items-center justify-between">
		<h1 class="text-xl font-bold">내 세트</h1>
		<a href="{base}/upload" class="bg-[var(--color-primary)] text-white px-4 py-2 rounded-xl text-sm font-medium">
			+ 업로드
		</a>
	</div>

	<!-- Join by code -->
	<div class="bg-white rounded-xl p-4 shadow-sm">
		<h3 class="text-sm font-medium text-gray-700 mb-2">공유 코드로 참여</h3>
		<div class="flex gap-2">
			<input
				type="text"
				bind:value={shareCodeInput}
				placeholder="MG-XXXX"
				class="flex-1 px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)]"
			/>
			<button
				onclick={joinByCode}
				disabled={joinLoading}
				class="px-4 py-2 bg-[var(--color-primary)] text-white rounded-lg text-sm font-medium disabled:opacity-50"
			>
				참여
			</button>
		</div>
		{#if joinError}
			<div class="text-red-500 text-xs mt-2">{joinError}</div>
		{/if}
	</div>

	{#if loading}
		<div class="flex justify-center py-12">
			<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[var(--color-primary)]"></div>
		</div>
	{:else if sets.length === 0}
		<div class="bg-white rounded-xl p-8 text-center text-gray-400 shadow-sm">
			<p>아직 세트가 없습니다</p>
		</div>
	{:else}
		<div class="space-y-3">
			{#each sets as set}
				<a href="{base}/sets/{set.id}" class="block bg-white rounded-xl p-4 shadow-sm hover:shadow transition-shadow">
					<div class="flex items-center justify-between mb-1">
						<h3 class="font-medium">{set.title}</h3>
						<div class="flex gap-1">
							{#if set.isShared}
								<span class="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">공유</span>
							{/if}
							{#if set.isActive}
								<span class="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full">활성</span>
							{/if}
						</div>
					</div>
					<div class="text-sm text-gray-500">
						{set.cards?.[0]?.count ?? set.card_count ?? 0}장
						{#if set.description}· {set.description}{/if}
					</div>
				</a>
			{/each}
		</div>
	{/if}
</div>
