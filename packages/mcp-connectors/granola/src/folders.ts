// Folder list capability. Wraps the official Granola MCP tool
// `list_meeting_folders`. PAID PLANS ONLY per Granola docs.
//
// The wrapper's plan-tier pre-guard (PAID_PLAN_TOOLS in client.ts) catches
// Free-plan callers before any wire call; the 403 surface from the live
// MCP server is handled identically (typed as GranolaPlanTierInsufficientError).

import { GranolaCache } from "./cache.js";
import { GranolaClient } from "./client.js";
import { parseListFolders } from "./parsers.js";
import type { GranolaFolder, GranolaPlanTier } from "./types.js";

interface ListFoldersOptions {
  cache?: GranolaCache;
  no_cache?: boolean;
  /** Pre-known plan tier (skips on-the-wire 403 round-trip for Free workspaces). */
  plan_tier_hint?: GranolaPlanTier;
}

const DEFAULT_TTL_MS = 10 * 60 * 1000;

/**
 * List meeting folders for the authenticated workspace. PAID PLANS ONLY —
 * throws GranolaPlanTierInsufficientError if the plan_tier_hint or cached
 * account_info indicates Free.
 */
export async function listFolders(
  client: GranolaClient,
  options: ListFoldersOptions = {},
): Promise<GranolaFolder[]> {
  const cache = options.cache;
  const cacheKey = `granola:list_meeting_folders:default`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<GranolaFolder[]>(cacheKey);
    if (cached) return cached;
  }
  const result = await client.callTool(
    "list_meeting_folders",
    {},
    { plan_tier_hint: options.plan_tier_hint },
  );
  const folders = parseListFolders(result);
  if (cache) await cache.set(cacheKey, folders, DEFAULT_TTL_MS);
  return folders;
}
