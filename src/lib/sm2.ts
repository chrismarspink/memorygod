export interface SM2State {
	interval: number;
	easiness: number;
	repetition: number;
}

export type Score = 5 | 3 | 1;

export function calcSM2(state: SM2State, score: Score): SM2State {
	let { interval, easiness, repetition } = state;

	if (score >= 3) {
		if (repetition === 0) interval = 1;
		else if (repetition === 1) interval = 6;
		else interval = Math.round(interval * easiness);
		repetition++;
	} else {
		repetition = 0;
		interval = 1;
	}

	easiness = easiness + 0.1 - (5 - score) * (0.08 + (5 - score) * 0.02);
	easiness = Math.max(1.3, Math.round(easiness * 100) / 100);

	return { interval, easiness, repetition };
}

export function nextReviewDate(intervalDays: number): string {
	const d = new Date();
	d.setDate(d.getDate() + intervalDays);
	return d.toISOString().split('T')[0];
}
