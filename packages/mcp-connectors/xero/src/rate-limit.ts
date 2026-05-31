// Rate limiter for Xero. Per Xero published limits
// (https://developer.xero.com/documentation/guides/oauth2/limits):
//   - 60 calls / 60-second window per app per tenant (minute bucket)
//   - 5000 calls / day per tenant (daily bucket)
//   - Concurrent: 5 simultaneous calls per app per tenant (we don't enforce
//     concurrency here — single-process Cash Conductor cycle.sh is serial)
//
// We track BOTH windows; backoff at 80% of the tighter one. Per-tenant
// state (multi-tenant safe).

const MINUTE_MS = 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;
const MINUTE_HARD = 60;
const DAILY_HARD = 5000;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 48
const DAILY_SOFT = Math.floor(DAILY_HARD * 0.8); // 4000

const minuteTimestamps: Map<string, number[]> = new Map();
const dailyTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  tenant_id: string;
  minute_used: number;
  minute_remaining: number;
  daily_used: number;
  daily_remaining: number;
  shouldBackoff: boolean;
  reason: "ok" | "minute-soft" | "daily-soft" | "minute-hard" | "daily-hard";
}

function pruneMinute(arr: number[] | undefined, now: number): number[] {
  if (!arr) return [];
  return arr.filter((ts) => now - ts < MINUTE_MS);
}
function pruneDay(arr: number[] | undefined, now: number): number[] {
  if (!arr) return [];
  return arr.filter((ts) => now - ts < DAY_MS);
}

export function check(
  tenant_id: string,
  now: () => number = Date.now,
): RateState {
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(tenant_id), t);
  const day = pruneDay(dailyTimestamps.get(tenant_id), t);
  minuteTimestamps.set(tenant_id, minute);
  dailyTimestamps.set(tenant_id, day);

  const minute_used = minute.length;
  const daily_used = day.length;
  let reason: RateState["reason"] = "ok";
  let shouldBackoff = false;

  if (minute_used >= MINUTE_HARD) {
    reason = "minute-hard";
    shouldBackoff = true;
  } else if (daily_used >= DAILY_HARD) {
    reason = "daily-hard";
    shouldBackoff = true;
  } else if (daily_used >= DAILY_SOFT) {
    reason = "daily-soft";
    shouldBackoff = true;
  } else if (minute_used >= MINUTE_SOFT) {
    reason = "minute-soft";
    shouldBackoff = true;
  }

  return {
    tenant_id,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    daily_used,
    daily_remaining: DAILY_HARD - daily_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  tenant_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(tenant_id, now);
  if (state.reason === "minute-hard" || state.reason === "daily-hard")
    return false;
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(tenant_id), t);
  const day = pruneDay(dailyTimestamps.get(tenant_id), t);
  minute.push(t);
  day.push(t);
  minuteTimestamps.set(tenant_id, minute);
  dailyTimestamps.set(tenant_id, day);
  return true;
}

export function reset(tenant_id?: string): void {
  if (tenant_id !== undefined) {
    minuteTimestamps.delete(tenant_id);
    dailyTimestamps.delete(tenant_id);
  } else {
    minuteTimestamps.clear();
    dailyTimestamps.clear();
  }
}
