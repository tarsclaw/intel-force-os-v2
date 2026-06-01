// Rate limiter for Open Banking providers. Conservative per-provider buckets;
// per-(provider, connection_id) state for multi-bank isolation.
//
// TrueLayer published limits (https://docs.truelayer.com/docs/api-overview):
//   Production: not publicly numbered; sandbox often constrained to ~10/min
//   per connection. We use a conservative 30/min cap with 24/min soft.
// Plaid UK published limits (https://plaid.com/docs/api/rate-limits/):
//   Standard tier: 30 calls/minute per item. Same cap structure.
//
// Both providers handle rate-limit-friendly behaviour at the protocol layer
// (429 + Retry-After honoured by client.ts).

const MINUTE_MS = 60 * 1000;
const MINUTE_HARD = 30;
const MINUTE_SOFT = Math.floor(MINUTE_HARD * 0.8); // 24

const minuteTimestamps: Map<string, number[]> = new Map();

export interface RateState {
  provider_connection_key: string;
  minute_used: number;
  minute_remaining: number;
  shouldBackoff: boolean;
  reason: "ok" | "minute-soft" | "minute-hard";
}

function key(provider: string, connection_id: string): string {
  return `${provider}:${connection_id}`;
}

function pruneMinute(arr: number[] | undefined, now: number): number[] {
  if (!arr) return [];
  return arr.filter((ts) => now - ts < MINUTE_MS);
}

export function check(
  provider: string,
  connection_id: string,
  now: () => number = Date.now,
): RateState {
  const k = key(provider, connection_id);
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(k), t);
  minuteTimestamps.set(k, minute);

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
    provider_connection_key: k,
    minute_used,
    minute_remaining: MINUTE_HARD - minute_used,
    shouldBackoff,
    reason,
  };
}

export function consume(
  provider: string,
  connection_id: string,
  now: () => number = Date.now,
): boolean {
  const state = check(provider, connection_id, now);
  if (state.reason === "minute-hard") return false;
  const k = key(provider, connection_id);
  const t = now();
  const minute = pruneMinute(minuteTimestamps.get(k), t);
  minute.push(t);
  minuteTimestamps.set(k, minute);
  return true;
}

export function reset(provider?: string, connection_id?: string): void {
  if (provider !== undefined && connection_id !== undefined) {
    minuteTimestamps.delete(key(provider, connection_id));
  } else {
    minuteTimestamps.clear();
  }
}
