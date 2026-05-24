// In-process rate limiter. Window-based token bucket per host.
// Per tools.yaml: 30 requests / 60 seconds across all hosts.

const WINDOW_MS = 60_000;
const DEFAULT_BUDGET = 30;

let timestamps: number[] = [];

export interface RateLimitOptions {
  readonly budget?: number;
  readonly windowMs?: number;
  readonly now?: () => number;
}

export function tryConsume(opts: RateLimitOptions = {}): boolean {
  const budget = opts.budget ?? DEFAULT_BUDGET;
  const windowMs = opts.windowMs ?? WINDOW_MS;
  const now = (opts.now ?? Date.now)();
  timestamps = timestamps.filter((t) => now - t < windowMs);
  if (timestamps.length >= budget) return false;
  timestamps.push(now);
  return true;
}

export function reset(): void {
  timestamps = [];
}
