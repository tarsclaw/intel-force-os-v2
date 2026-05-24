// Rate limiter for Companies House. CH documented: 600 requests / 5-min
// window per IP. Pre-emptive backoff at 80% capacity (480 in 5 min).

const WINDOW_MS = 5 * 60 * 1000;
const HARD_BUDGET = 600;
const SOFT_BUDGET = Math.floor(HARD_BUDGET * 0.8); // 480

let timestamps: number[] = [];

export interface RateState {
  used: number;
  budgetRemaining: number;
  shouldBackoff: boolean;
}

export function check(now: () => number = Date.now): RateState {
  const t = now();
  timestamps = timestamps.filter((ts) => t - ts < WINDOW_MS);
  return {
    used: timestamps.length,
    budgetRemaining: HARD_BUDGET - timestamps.length,
    shouldBackoff: timestamps.length >= SOFT_BUDGET,
  };
}

export function consume(now: () => number = Date.now): boolean {
  const state = check(now);
  if (state.budgetRemaining <= 0) return false;
  timestamps.push(now());
  return true;
}

export function reset(): void {
  timestamps = [];
}
