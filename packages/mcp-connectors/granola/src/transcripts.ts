// Transcript fetch capability. Wraps the official Granola MCP tool
// `get_meeting_transcript`. PAID PLANS ONLY per Granola docs.
//
// Cache: 10-min TTL — transcripts are IMMUTABLE once Granola generates them
// (the transcript for meeting_id X today is the same transcript for
// meeting_id X tomorrow). Keying on meeting_id is sufficient. Longer TTLs
// (1h, 1d) would be safe but 10 min matches the rest of the package and
// keeps disk usage bounded.

import { GranolaCache } from "./cache.js";
import { GranolaClient } from "./client.js";
import { parseTranscript } from "./parsers.js";
import type { GranolaPlanTier, GranolaTranscript } from "./types.js";

interface GetTranscriptOptions {
  cache?: GranolaCache;
  no_cache?: boolean;
  /** Pre-known plan tier (skips wire round-trip for Free workspaces). */
  plan_tier_hint?: GranolaPlanTier;
}

const DEFAULT_TTL_MS = 10 * 60 * 1000;

/**
 * Fetch the transcript for a meeting. PAID PLANS ONLY — throws
 * GranolaPlanTierInsufficientError on Free workspaces.
 *
 * Returns null on 404 (no transcript exists for that meeting — e.g. a
 * meeting that was scheduled but never actually recorded).
 */
export async function getTranscript(
  client: GranolaClient,
  meeting_id: string,
  options: GetTranscriptOptions = {},
): Promise<GranolaTranscript | null> {
  const cache = options.cache;
  const cacheKey = `granola:get_meeting_transcript:${meeting_id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<GranolaTranscript>(cacheKey);
    if (cached) return cached;
  }
  try {
    const result = await client.callTool(
      "get_meeting_transcript",
      { meeting_id },
      { plan_tier_hint: options.plan_tier_hint },
    );
    const transcript = parseTranscript(result);
    if (transcript && cache) await cache.set(cacheKey, transcript, DEFAULT_TTL_MS);
    return transcript;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}
