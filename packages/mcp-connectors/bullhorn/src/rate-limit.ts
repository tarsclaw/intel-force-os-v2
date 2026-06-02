// Rate limiter for Bullhorn. Bullhorn's published "Fair Use Policy" does NOT
// numerate per-corporation limits — community knowledge suggests ~10/sec per
// corporation_id is the safe band (verified via support-forum + n8n integration
// thread, cited in docs/decisions/bullhorn-integration-path.md §2.2). v1.0
// conservative default: 600/min per corporation_id (10/sec sustained). Tunable
// when Cash Conductor + Janitor + Scribe runtime telemetry shows actual ceiling.
//
// Per-corporation_id isolation — multi-tenant safe. Soft backoff at 80%
// (480/min); hard fail at 100% (600/min) → BullhornRateLimitError.

const MINUTE_MS = 60 * 1000;
const MINUTE_HARD = 600;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 480

const minuteTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  corporation_id: string;
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
  corporation_id: string,
  now: () => number = Date.now,
): RateState {
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(corporation_id), t);
  minuteTimestamps.set(corporation_id, minute);

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
    corporation_id,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  corporation_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(corporation_id, now);
  if (state.reason === "minute-hard") return false;
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(corporation_id), t);
  minute.push(t);
  minuteTimestamps.set(corporation_id, minute);
  return true;
}

export function reset(corporation_id?: string): void {
  if (corporation_id !== undefined) {
    minuteTimestamps.delete(corporation_id);
  } else {
    minuteTimestamps.clear();
  }
}
