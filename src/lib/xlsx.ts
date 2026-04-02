import * as XLSX from 'xlsx';

interface ParsedCard {
	front: string;
	back: string;
	hint?: string;
	domain?: string;
	tags?: string[];
	image_url?: string;
	order_index: number;
}

const FRONT_ALIASES = ['front', '앞면', '질문', 'question', 'term'];
const BACK_ALIASES = ['back', '뒷면', '정답', 'answer', 'definition'];
const HINT_ALIASES = ['hint', '힌트'];
const DOMAIN_ALIASES = ['domain', '영역', '카테고리', 'category'];
const TAGS_ALIASES = ['tags', '태그'];
const IMAGE_ALIASES = ['image_url', '이미지', 'image'];

function findColumn(headers: string[], aliases: string[]): string | null {
	const lower = headers.map(h => h.toLowerCase().trim());
	for (const alias of aliases) {
		const idx = lower.indexOf(alias.toLowerCase());
		if (idx !== -1) return headers[idx];
	}
	return null;
}

export function parseExcel(buffer: ArrayBuffer): { cards: ParsedCard[]; domains: string[] } {
	const wb = XLSX.read(buffer, { type: 'array' });
	const ws = wb.Sheets[wb.SheetNames[0]];
	const rows: Record<string, string>[] = XLSX.utils.sheet_to_json(ws, { defval: '' });

	if (rows.length === 0) throw new Error('빈 파일입니다');

	const headers = Object.keys(rows[0]);
	const frontCol = findColumn(headers, FRONT_ALIASES);
	const backCol = findColumn(headers, BACK_ALIASES);

	if (!frontCol || !backCol) {
		throw new Error('필수 컬럼(front/앞면, back/뒷면)을 찾을 수 없습니다');
	}

	const hintCol = findColumn(headers, HINT_ALIASES);
	const domainCol = findColumn(headers, DOMAIN_ALIASES);
	const tagsCol = findColumn(headers, TAGS_ALIASES);
	const imageCol = findColumn(headers, IMAGE_ALIASES);

	const domains = new Set<string>();
	const cards: ParsedCard[] = [];

	rows.forEach((row, i) => {
		const front = String(row[frontCol] ?? '').trim();
		const back = String(row[backCol] ?? '').trim();
		if (!front || !back) return;

		const domain = domainCol ? String(row[domainCol] ?? '').trim() : undefined;
		if (domain) domains.add(domain);

		const tagsStr = tagsCol ? String(row[tagsCol] ?? '').trim() : '';
		const tags = tagsStr ? tagsStr.split(/[,;，；]/).map(t => t.trim()).filter(Boolean) : [];

		cards.push({
			front,
			back,
			hint: hintCol ? String(row[hintCol] ?? '').trim() || undefined : undefined,
			domain: domain || undefined,
			tags,
			image_url: imageCol ? String(row[imageCol] ?? '').trim() || undefined : undefined,
			order_index: i
		});
	});

	return { cards, domains: [...domains] };
}
