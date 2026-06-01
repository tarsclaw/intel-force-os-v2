// Rate limiter for QuickBooks Online. Per Intuit published limits
// (https://developer.intuit.com/app/developer/qbo/docs/develop/rate-limits):
//   - 500 calls / 60-second window per app per realmId (minute bucket)
//   - 10 calls / second concurrent throttle (not enforced here — single-process
//     Cash Conductor cycle.sh is serial)
//
// No published daily cap; only the per-minute throttle. Pre-emptive backoff at
// 80% of the minute bucket. Per-realm state (multi-realm safe).

const MINUTE_MS = 60 * 1000;
const MINUTE_HARD = 500;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 400

const minuteTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  realm_id: string;
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
  realm_id: string,
  now: () => number = Date.now,
): RateState {
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(realm_id), t);
  minuteTimestamps.set(realm_id, minute);

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
    realm_id,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  realm_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(realm_id, now);
  if (state.reason === "minute-hard") return false;
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(realm_id), t);
  minute.push(t);
  minuteTimestamps.set(realm_id, minute);
  return true;
}

export function reset(realm_id?: string): void {
  if (realm_id !== undefined) {
    minuteTimestamps.delete(realm_id);
  } else {
    minuteTimestamps.clear();
  }
}
