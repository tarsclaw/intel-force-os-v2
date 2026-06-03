// Rate limiter for Reed. Reed does NOT publish exact rate-limit numbers in
// the Jobseeker API docs (verified 2026-06-03 via WebFetch reed.co.uk/
// developers/jobseeker — "Rate Limits: Not specified"). v0.1.0 conservative
// default: 60/min per account_id (1/sec sustained; well above expected
// Sourcing Scout daily-poll cadence). Tunable when first commercial Reed
// account telemetry shows actual ceiling.
//
// Per-account_id isolation — multi-tenant safe. Soft backoff at 80% (48/min);
// hard fail at 100% (60/min) → ReedRateLimitError.

const MINUTE_MS = 60 * 1000;
const MINUTE_HARD = 60;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 48

const minuteTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  account_id: string;
  minute_used: number;
  minute_remaining: number;
  shouldBackoff: boolean;
  reason: "ok" | "minute-soft" | "minute-hard";
}

function pruneMinute(arr: number[] | undefined, now: number): number[] {
  if (!arr) return [];
  return arr.filter((ts) => now - ts < MINUTE_MS);
}

export function check(
  account_id: string,
  now: () => number = Date.now,
): RateState {
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(account_id), t);
  minuteTimestamps.set(account_id, minute);

  const minute_used = minute.length;
  let reason: RateState["reason"] = "ok";
  let shouldBackoff = false;

  if (minute_used >= MINUTE_HARD) {
    reason = "minute-hard";
    shouldBackoff = true;
  } else if (minute_used >= MINUTE_SOFT) {
    reason = "minute-soft";
    shouldBackoff = true;
  }

  return {
    account_id,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  account_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(account_id, now);
  if (state.reason === "minute-hard") return false;
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(account_id), t);
  minute.push(t);
  minuteTimestamps.set(account_id, minute);
  return true;
}

export function reset(account_id?: string): void {
  if (account_id !== undefined) {
    minuteTimestamps.delete(account_id);
  } else {
    minuteTimestamps.clear();
  }
}
