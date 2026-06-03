// Rate limiter for WorkOS. WorkOS publishes ~100 RPS per account (verified
// via support docs; community sources corroborate). v1.0 conservative default
// per org_id: 6000/min (10/sec sustained — same slice cadence as Bullhorn's
// per-corp budget). Tunable when admin-onboarding telemetry shows the actual
// ceiling.
//
// Per-org_id isolation — multi-tenant safe. Soft backoff at 80% (4800/min);
// hard fail at 100% (6000/min) → WorkosRateLimitError. NOTE: the WorkOS
// quota is technically per-API-key not per-org; the v1.0 IFOS deployment runs
// one secret across many tenant orgs, so per-org bucketing is the FAIR-USE
// slice rather than the upstream ceiling. The true platform-wide gate is
// the 6000/min × N concurrent orgs which the upstream itself will 429-enforce.

const MINUTE_MS = 60 * 1000;
const MINUTE_HARD = 6000;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 4800

const minuteTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  org_id: string;
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
  org_id: string,
  now: () => number = Date.now,
): RateState {
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(org_id), t);
  minuteTimestamps.set(org_id, minute);

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
    org_id,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  org_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(org_id, now);
  if (state.reason === "minute-hard") return false;
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(org_id), t);
  minute.push(t);
  minuteTimestamps.set(org_id, minute);
  return true;
}

export function reset(org_id?: string): void {
  if (org_id !== undefined) {
    minuteTimestamps.delete(org_id);
  } else {
    minuteTimestamps.clear();
  }
}
