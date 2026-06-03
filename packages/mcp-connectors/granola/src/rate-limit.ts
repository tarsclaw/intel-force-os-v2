// Rate limiter for Granola. Granola does NOT publish exact per-workspace
// limits in the MCP surface docs; v1.0 conservative default is 60/min per
// workspace_id (1/sec sustained). The dominant access pattern is Scribe's
// 5-minute cron polling list_meetings → cheap; rare transcript fetches per
// new meeting → moderate. This budget is well above expected steady-state
// load while leaving headroom for backfill operations.
//
// Per-workspace_id isolation — multi-tenant safe. Soft backoff at 80%
// (48/min); hard fail at 100% (60/min) → GranolaRateLimitError.

const MINUTE_MS = 60 * 1000;
const MINUTE_HARD = 60;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 48

const minuteTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  workspace_id: string;
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
  workspace_id: string,
  now: () => number = Date.now,
): RateState {
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(workspace_id), t);
  minuteTimestamps.set(workspace_id, minute);

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
    workspace_id,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  workspace_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(workspace_id, now);
  if (state.reason === "minute-hard") return false;
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(workspace_id), t);
  minute.push(t);
  minuteTimestamps.set(workspace_id, minute);
  return true;
}

export function reset(workspace_id?: string): void {
  if (workspace_id !== undefined) {
    minuteTimestamps.delete(workspace_id);
  } else {
    minuteTimestamps.clear();
  }
}
