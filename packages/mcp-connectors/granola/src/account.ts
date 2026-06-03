// Account-info capability. Wraps the official Granola MCP tool
// `get_account_info`. All plans. Returns workspace name + plan tier +
// user email + feature flags (transcripts_enabled / folders_enabled).
//
// Consumer pattern: Scribe loads this once per cycle and caches the
// plan_tier into the GranolaClient via _setAccountInfoForTest()-style
// internal helper (NOT the test hook — a real production hydrate). This
// short-circuits the per-call plan-tier guard so Free-plan callers don't
// hit the wire just to be rejected with 403 on every folder/transcript
// attempt.

import { GranolaCache } from "./cache.js";
import { GranolaClient } from "./client.js";
import { parseAccountInfo } from "./parsers.js";
import type { GranolaAccountInfo } from "./types.js";

interface GetAccountInfoOptions {
  cache?: GranolaCache;
  no_cache?: boolean;
}

const DEFAULT_TTL_MS = 60 * 60 * 1000; // 1h — plan tier rarely changes

/**
 * Fetch account info for the authenticated workspace. All plans. Cached
 * 1 hour by default — plan tier changes are a manual founder/customer
 * action and don't need sub-hour reactivity.
 */
export async function getAccountInfo(
  client: GranolaClient,
  options: GetAccountInfoOptions = {},
): Promise<GranolaAccountInfo> {
  const cache = options.cache;
  const cacheKey = `granola:get_account_info`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<GranolaAccountInfo>(cacheKey);
    if (cached) return cached;
  }
  const result = await client.callTool("get_account_info", {});
  const info = parseAccountInfo(result);
  if (cache) await cache.set(cacheKey, info, DEFAULT_TTL_MS);
  return info;
}
