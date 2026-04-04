<script lang="ts">
	import { base } from '$app/paths';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { calcSM2, nextReviewDate, type Score } from '$lib/sm2';
	import FlashCard from '$lib/components/FlashCard.svelte';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	interface Card {
		id: string;
		front: string;
		back: string;
		hint?: string;
		domain?: string;
		image_url?: string;
		isNew: boolean;
	}

	let queue: Card[] = $state([]);
	let currentIndex = $state(0);
	let flipped = $state(false);
	let loading = $state(true);
	let sessionDone = $state(false);
	let sessionResults = $state({ total: 0, knew: 0, confused: 0, forgot: 0 });

	onMount(async () => {
		if (!$user) {
			goto(`${base}/auth/login`);
			return;
		}
		await loadQueue();
	});

	async function loadQueue() {
		loading = true;
		const userId = $user!.id;
		const today = new Date().toISOString().split('T')[0];

		// Get user settings
		const { data: settings } = await supabase
			.from('user_settings')
			.select('*')
			.eq('user_id', userId)
			.maybeSingle();

		const revLimit = settings?.daily_rev_limit ?? 50;
		const newLimit = settings?.daily_new_limit ?? 20;

		// Review cards (due today or earlier)
		const { data: reviewLogs } = await supabase
			.from('review_logs')
			.select('card_id, cards(*)')
			.eq('user_id', userId)
			.lte('next_review_at', today)
			.limit(revLimit);

		const reviewCards: Card[] = (reviewLogs ?? []).map((r: any) => ({
			...r.cards,
			isNew: false
		}));

		// Get all user's enabled (ON) set IDs
		const { data: ownSets } = await supabase
			.from('card_sets')
			.select('id')
			.eq('owner_id', userId)
			.neq('is_enabled', false);

		const { data: sharedActive } = await supabase
			.from('shared_sets')
			.select('set_id')
			.eq('member_id', userId)
			.eq('is_active', true);

		const setIds = [
			...(ownSets ?? []).map((s: any) => s.id),
			...(sharedActive ?? []).map((s: any) => s.set_id)
		];

		if (setIds.length === 0) {
			queue = reviewCards;
			loading = false;
			return;
		}

		// New cards (not yet in review_logs)
		const reviewedCardIds = (reviewLogs ?? []).map((r: any) => r.card_id);
		const { data: allReviewed } = await supabase
			.from('review_logs')
			.select('card_id')
			.eq('user_id', userId);

		const allReviewedIds = (allReviewed ?? []).map((r: any) => r.card_id);

		let newCardsQuery = supabase
			.from('cards')
			.select('*')
			.in('set_id', setIds)
			.order('order_index')
			.limit(newLimit);

		if (allReviewedIds.length > 0) {
			newCardsQuery = newCardsQuery.not('id', 'in', `(${allReviewedIds.join(',')})`);
		}

		const { data: newCards } = await newCardsQuery;

		const newMapped: Card[] = (newCards ?? []).map((c: any) => ({ ...c, isNew: true }));

		// Review first setting
		if (settings?.review_first !== false) {
			queue = [...reviewCards, ...newMapped];
		} else {
			queue = [...newMapped, ...reviewCards];
		}

		loading = false;
	}

	let saveError = $state('');
	let saveLog = $state('대기중');

	async function handleRate(score: Score) {
		const card = queue[currentIndex];
		const userId = $user!.id;
		const today = new Date().toISOString().split('T')[0];
		saveError = '';
		saveLog = `저장중... card=${card.id.slice(0,8)} score=${score}`;

		// Get existing state
		const { data: existing } = await supabase
			.from('review_logs')
			.select('*')
			.eq('card_id', card.id)
			.eq('user_id', userId)
			.maybeSingle();

		const prev = {
			interval: existing?.interval_days ?? 1,
			easiness: existing?.easiness ?? 2.5,
			repetition: existing?.repetition ?? 0
		};

		const next = calcSM2(prev, score);
		const reviewData = {
			card_id: card.id,
			user_id: userId,
			result: score,
			interval_days: next.interval,
			easiness: next.easiness,
			repetition: next.repetition,
			next_review_at: nextReviewDate(next.interval),
			reviewed_at: new Date().toISOString()
		};

		// Try upsert, fallback to update if exists
		const { error: upsertErr } = await supabase
			.from('review_logs')
			.upsert(reviewData, { onConflict: 'card_id,user_id' });

		if (upsertErr) {
			saveLog = `upsert 실패: ${upsertErr.message} (code: ${upsertErr.code})`;
			saveError = `저장 오류: ${upsertErr.message}`;
			// Fallback: try update if already exists
			if (existing) {
				const { error: updateErr } = await supabase
					.from('review_logs')
					.update(reviewData)
					.eq('card_id', card.id)
					.eq('user_id', userId);
				if (updateErr) {
					saveError += ` | 업데이트도 실패: ${updateErr.message}`;
				} else {
					saveError = '';
				}
			} else {
				// Try plain insert
				const { error: insertErr } = await supabase
					.from('review_logs')
					.insert(reviewData);
				if (insertErr) {
					saveError += ` | insert도 실패: ${insertErr.message}`;
				} else {
					saveError = '';
				}
			}
		}

		// Update daily stats
		const { error: rpcErr } = await supabase.rpc('increment_daily_stats', {
			p_user_id: userId,
			p_date: today,
			p_is_new: card.isNew
		});

		if (rpcErr) {
			saveError += ` | daily_stats 오류: ${rpcErr.message}`;
		}

		if (!saveError) {
			saveLog = `저장 완료! card=${card.id.slice(0,8)} score=${score} interval=${next.interval}d`;
		} else {
			saveLog = saveError;
		}

		// Track session
		sessionResults.total++;
		if (score === 5) sessionResults.knew++;
		else if (score === 3) sessionResults.confused++;
		else sessionResults.forgot++;

		// Next card
		if (currentIndex < queue.length - 1) {
			currentIndex++;
			flipped = false;
		} else {
			sessionDone = true;
		}
	}

	function restartSession() {
		sessionDone = false;
		sessionResults = { total: 0, knew: 0, confused: 0, forgot: 0 };
		currentIndex = 0;
		flipped = false;
		loadQueue();
	}
</script>

<svelte:head>
	<title>학습 - 기억의 신</title>
</svelte:head>

{#if loading}
	<div class="flex items-center justify-center h-screen">
		<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-[var(--color-primary)]"></div>
	</div>
{:else if queue.length === 0}
	<div class="flex flex-col items-center justify-center h-screen p-4 text-center">
		<div class="text-5xl mb-4">🎉</div>
		<h2 class="text-xl font-bold mb-2">오늘의 학습 완료!</h2>
		<p class="text-gray-500 mb-6">복습할 카드가 없습니다</p>
		<a href="{base}/" class="text-[var(--color-primary)] font-medium">홈으로 돌아가기</a>
	</div>
{:else if sessionDone}
	<!-- Session complete -->
	<div class="flex flex-col items-center justify-center h-screen p-4 text-center">
		<div class="text-5xl mb-4">✅</div>
		<h2 class="text-xl font-bold mb-4">학습 완료!</h2>
		<div class="bg-white rounded-2xl p-6 shadow-sm w-full max-w-sm space-y-3 mb-6">
			<div class="flex justify-between">
				<span class="text-gray-500">총 학습</span>
				<span class="font-bold">{sessionResults.total}장</span>
			</div>
			<div class="flex justify-between">
				<span class="text-emerald-600">알았음</span>
				<span class="font-bold text-emerald-600">{sessionResults.knew}</span>
			</div>
			<div class="flex justify-between">
				<span class="text-amber-600">헷갈림</span>
				<span class="font-bold text-amber-600">{sessionResults.confused}</span>
			</div>
			<div class="flex justify-between">
				<span class="text-red-600">몰랐음</span>
				<span class="font-bold text-red-600">{sessionResults.forgot}</span>
			</div>
		</div>
		<div class="flex gap-3">
			<button onclick={restartSession} class="px-6 py-3 bg-[var(--color-primary)] text-white rounded-xl font-medium">
				다시 학습
			</button>
			<a href="{base}/" class="px-6 py-3 bg-gray-100 text-gray-700 rounded-xl font-medium">
				홈으로
			</a>
		</div>
	</div>
{:else}
	<div class="flex flex-col md:flex-row md:gap-8 md:max-w-5xl md:mx-auto p-4 min-h-screen">
		<!-- Debug log (항상 표시) -->
		<div class="w-full max-w-md mx-auto mb-2 text-xs p-2 rounded-lg border
			{saveError ? 'text-red-600 bg-red-50 border-red-200' : 'text-blue-600 bg-blue-50 border-blue-200'}">
			[SAVE] {saveLog}
		</div>
		<!-- Card area -->
		<div class="md:w-1/2 flex flex-col items-center justify-center">
			<!-- Progress bar -->
			<div class="w-full max-w-md mb-4">
				<div class="flex justify-between text-sm text-gray-500 mb-1">
					<span>{currentIndex + 1} / {queue.length}</span>
					<span>{Math.round(((currentIndex + 1) / queue.length) * 100)}%</span>
				</div>
				<div class="w-full h-2 bg-gray-200 rounded-full overflow-hidden">
					<div
						class="h-full bg-[var(--color-primary)] rounded-full transition-all"
						style="width: {((currentIndex + 1) / queue.length) * 100}%"
					></div>
				</div>
			</div>

			<FlashCard
				front={queue[currentIndex].front}
				back={queue[currentIndex].back}
				hint={queue[currentIndex].hint}
				domain={queue[currentIndex].domain}
				image_url={queue[currentIndex].image_url}
				{flipped}
				onflip={() => flipped = !flipped}
				onrate={handleRate}
			/>
		</div>

		<!-- Desktop side panel -->
		<div class="hidden md:flex md:w-1/2 flex-col justify-center space-y-4">
			<div class="bg-white rounded-2xl p-6 shadow-sm">
				<h3 class="font-semibold mb-3">학습 현황</h3>
				<div class="space-y-2 text-sm">
					<div class="flex justify-between">
						<span class="text-gray-500">진행</span>
						<span>{currentIndex + 1} / {queue.length}</span>
					</div>
					<div class="flex justify-between">
						<span class="text-emerald-600">알았음</span>
						<span>{sessionResults.knew}</span>
					</div>
					<div class="flex justify-between">
						<span class="text-amber-600">헷갈림</span>
						<span>{sessionResults.confused}</span>
					</div>
					<div class="flex justify-between">
						<span class="text-red-600">몰랐음</span>
						<span>{sessionResults.forgot}</span>
					</div>
				</div>
			</div>
			{#if queue[currentIndex].isNew}
				<div class="text-xs text-blue-600 bg-blue-50 px-3 py-2 rounded-lg">
					새 카드
				</div>
			{:else}
				<div class="text-xs text-gray-500 bg-gray-50 px-3 py-2 rounded-lg">
					복습 카드
				</div>
			{/if}
		</div>
	</div>
{/if}
