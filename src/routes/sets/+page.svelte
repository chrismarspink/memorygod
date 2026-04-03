<script lang="ts">
	import { base } from '$app/paths';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	interface SetItem {
		id: string;
		title: string;
		description: string | null;
		card_count: number;
		cardCount: number;
		isShared: boolean;
		isEnabled: boolean;
		sharedSetId?: string;
	}

	let sets: SetItem[] = $state([]);
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

		const ownMapped: SetItem[] = (own ?? []).map((s: any) => ({
			id: s.id,
			title: s.title,
			description: s.description,
			card_count: s.card_count,
			cardCount: s.cards?.[0]?.count ?? s.card_count ?? 0,
			isShared: false,
			isEnabled: s.is_enabled !== false,
		}));

		const sharedMapped: SetItem[] = (shared ?? []).map((s: any) => ({
			id: s.card_sets.id,
			title: s.card_sets.title,
			description: s.card_sets.description,
			card_count: s.card_sets.card_count,
			cardCount: s.card_sets.cards?.[0]?.count ?? s.card_sets.card_count ?? 0,
			isShared: true,
			isEnabled: s.is_active !== false,
			sharedSetId: s.id,
		}));

		sets = [...ownMapped, ...sharedMapped];
		loading = false;
	}

	function enabledSets() {
		return sets.filter(s => s.isEnabled);
	}

	function enabledCardCount() {
		return enabledSets().reduce((a, s) => a + s.cardCount, 0);
	}

	async function toggleSet(set: SetItem, e: Event) {
		e.preventDefault();
		e.stopPropagation();

		const newState = !set.isEnabled;

		// Prevent turning off the last enabled set
		if (!newState && enabledSets().length <= 1) {
			alert('최소 1개 세트는 학습 중이어야 합니다');
			return;
		}

		// Optimistic update
		set.isEnabled = newState;
		sets = [...sets];

		if (set.isShared && set.sharedSetId) {
			await supabase
				.from('shared_sets')
				.update({ is_active: newState })
				.eq('id', set.sharedSetId);
		} else {
			await supabase
				.from('card_sets')
				.update({ is_enabled: newState })
				.eq('id', set.id);
		}
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
			member_id: $user!.id,
			is_active: true
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

	<!-- Summary -->
	{#if sets.length > 0}
		<div class="text-sm text-gray-500">
			학습 중 <span class="font-semibold text-[var(--color-primary)]">{enabledSets().length}개</span> 세트
			· 총 <span class="font-semibold">{enabledCardCount()}장</span>
		</div>
	{/if}

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
				<div class="bg-white rounded-xl p-4 shadow-sm hover:shadow transition-shadow">
					<div class="flex items-center justify-between">
						<a href="{base}/sets/{set.id}" class="flex-1 min-w-0">
							<div class="flex items-center gap-2 mb-1">
								<h3 class="font-medium truncate">{set.title}</h3>
								{#if set.isShared}
									<span class="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full shrink-0">공유</span>
								{/if}
							</div>
							<div class="text-sm text-gray-500">
								{set.cardCount}장
								{#if set.description}· {set.description}{/if}
							</div>
						</a>
						<!-- ON/OFF toggle -->
						<button
							onclick={(e) => toggleSet(set, e)}
							class="shrink-0 ml-3 w-12 h-7 rounded-full transition-colors relative
								{set.isEnabled ? 'bg-[var(--color-success)]' : 'bg-gray-300'}"
							title={set.isEnabled ? '학습 ON' : '학습 OFF'}
						>
							<div
								class="absolute top-0.5 w-6 h-6 bg-white rounded-full shadow transition-transform
									{set.isEnabled ? 'translate-x-5' : 'translate-x-0.5'}"
							></div>
						</button>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>
