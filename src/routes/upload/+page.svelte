<script lang="ts">
	import { base } from '$app/paths';
	import { user } from '$lib/auth';
	import { supabase } from '$lib/supabase';
	import { parseExcel } from '$lib/xlsx';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	let title = $state('');
	let description = $state('');
	let file: File | null = $state(null);
	let preview: any[] = $state([]);
	let domains: string[] = $state([]);
	let error = $state('');
	let loading = $state(false);
	let dragOver = $state(false);

	onMount(() => {
		if (!$user) goto(`${base}/auth/login`);
	});

	async function handleFile(f: File) {
		error = '';
		file = f;
		title = title || f.name.replace(/\.(xlsx|csv)$/i, '');
		try {
			const buffer = await f.arrayBuffer();
			const result = parseExcel(buffer);
			preview = result.cards.slice(0, 10);
			domains = result.domains;
		} catch (e: any) {
			error = e.message;
			preview = [];
		}
	}

	function onDrop(e: DragEvent) {
		e.preventDefault();
		dragOver = false;
		const f = e.dataTransfer?.files[0];
		if (f) handleFile(f);
	}

	function onFileInput(e: Event) {
		const input = e.target as HTMLInputElement;
		if (input.files?.[0]) handleFile(input.files[0]);
	}

	async function upload() {
		if (!file || !title.trim()) return;
		loading = true;
		error = '';

		try {
			const buffer = await file.arrayBuffer();
			const { cards, domains: parsedDomains } = parseExcel(buffer);

			// Create card set
			const { data: set, error: setErr } = await supabase
				.from('card_sets')
				.insert({
					owner_id: $user!.id,
					title: title.trim(),
					description: description.trim() || null,
					domains: parsedDomains,
					card_count: cards.length
				})
				.select()
				.single();

			if (setErr) throw setErr;

			// Insert cards in batches
			const batchSize = 100;
			for (let i = 0; i < cards.length; i += batchSize) {
				const batch = cards.slice(i, i + batchSize).map(c => ({
					set_id: set.id,
					front: c.front,
					back: c.back,
					hint: c.hint || null,
					domain: c.domain || null,
					tags: c.tags || [],
					image_url: c.image_url || null,
					order_index: c.order_index
				}));

				const { error: cardErr } = await supabase.from('cards').insert(batch);
				if (cardErr) throw cardErr;
			}

			goto(`${base}/sets/${set.id}`);
		} catch (e: any) {
			error = e.message || '업로드에 실패했습니다';
		} finally {
			loading = false;
		}
	}
</script>

<svelte:head>
	<title>엑셀 업로드 - 기억의 신</title>
</svelte:head>

<div class="max-w-2xl mx-auto p-4 space-y-6">
	<h1 class="text-xl font-bold">새 세트 만들기</h1>

	<!-- File drop zone -->
	<div
		role="button"
		tabindex="0"
		class="border-2 border-dashed rounded-2xl p-8 text-center transition-colors cursor-pointer
			{dragOver ? 'border-[var(--color-primary)] bg-blue-50' : 'border-gray-300 hover:border-gray-400'}"
		ondragover={(e) => { e.preventDefault(); dragOver = true; }}
		ondragleave={() => dragOver = false}
		ondrop={onDrop}
		onclick={() => document.getElementById('fileInput')?.click()}
		onkeydown={(e) => { if (e.key === 'Enter') document.getElementById('fileInput')?.click(); }}
	>
		<input id="fileInput" type="file" accept=".xlsx,.csv" class="hidden" onchange={onFileInput} />
		{#if file}
			<div class="text-[var(--color-primary)] font-medium">{file.name}</div>
			<div class="text-sm text-gray-500 mt-1">{preview.length}+ 카드 감지됨</div>
		{:else}
			<div class="text-gray-400 text-lg mb-2">📂</div>
			<div class="text-gray-500">엑셀(.xlsx) 또는 CSV 파일을 드래그하거나 클릭</div>
			<div class="text-xs text-gray-400 mt-2">필수 컬럼: front(앞면), back(뒷면)</div>
		{/if}
	</div>

	{#if file}
		<!-- Set info -->
		<div class="space-y-3">
			<div>
				<label for="title" class="block text-sm font-medium text-gray-700 mb-1">세트 제목</label>
				<input
					id="title"
					type="text"
					bind:value={title}
					class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)]"
					placeholder="예: 정보처리기사 핵심"
				/>
			</div>
			<div>
				<label for="desc" class="block text-sm font-medium text-gray-700 mb-1">설명 (선택)</label>
				<input
					id="desc"
					type="text"
					bind:value={description}
					class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)]"
					placeholder="세트에 대한 간단한 설명"
				/>
			</div>
		</div>

		<!-- Preview -->
		{#if preview.length > 0}
			<div>
				<h3 class="text-sm font-medium text-gray-700 mb-2">미리보기 (최대 10개)</h3>
				<div class="bg-white rounded-xl shadow-sm overflow-hidden">
					<table class="w-full text-sm">
						<thead class="bg-gray-50">
							<tr>
								<th class="px-3 py-2 text-left">#</th>
								<th class="px-3 py-2 text-left">앞면</th>
								<th class="px-3 py-2 text-left">뒷면</th>
								<th class="px-3 py-2 text-left">영역</th>
							</tr>
						</thead>
						<tbody>
							{#each preview as card, i}
								<tr class="border-t border-gray-100">
									<td class="px-3 py-2 text-gray-400">{i + 1}</td>
									<td class="px-3 py-2 truncate max-w-[150px]">{card.front}</td>
									<td class="px-3 py-2 truncate max-w-[150px]">{card.back}</td>
									<td class="px-3 py-2 text-gray-500">{card.domain || '-'}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
				{#if domains.length > 0}
					<div class="mt-2 flex flex-wrap gap-1">
						{#each domains as d}
							<span class="text-xs bg-blue-50 text-blue-700 px-2 py-0.5 rounded-full">{d}</span>
						{/each}
					</div>
				{/if}
			</div>
		{/if}

		{#if error}
			<div class="text-red-500 text-sm bg-red-50 p-3 rounded-xl">{error}</div>
		{/if}

		<button
			onclick={upload}
			disabled={loading || !title.trim()}
			class="w-full bg-[var(--color-primary)] text-white py-3 rounded-xl font-medium hover:bg-[var(--color-primary-light)] transition-colors disabled:opacity-50"
		>
			{loading ? '업로드 중...' : `${preview.length}장 업로드`}
		</button>
	{/if}
</div>
