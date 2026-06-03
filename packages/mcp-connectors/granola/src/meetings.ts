// Meeting read capabilities. Wraps 3 of the 6 Granola MCP tools:
// - list_meetings (All plans) — Scribe's primary 5-min poll
// - get_meetings (All plans) — single-meeting hydrate
// - query_granola_meetings (All plans) — semantic search across notes
//
// Free-plan limitation per Granola docs: queries against notes are limited
// to the last 30 days; consumer (Scribe) should honour this by capping
// list-window args at 30d for Free workspaces.

import { GranolaCache } from "./cache.js";
import { GranolaClient } from "./client.js";
import { parseListMeetings, parseMeeting } from "./parsers.js";
import type { GranolaMeeting, GranolaPlanTier } from "./types.js";

interface ReadOptions {
  cache?: GranolaCache;
  no_cache?: boolean;
  plan_tier_hint?: GranolaPlanTier;
}

interface ListMeetingsOptions extends ReadOptions {
  /** ISO-8601 date range start (e.g. "2026-06-01"). */
  start_date?: string;
  /** ISO-8601 date range end. */
  end_date?: string;
  /** Filter to a specific folder. */
  folder_id?: string;
  /** Page size. */
  limit?: number;
  /** Pagination cursor. */
  cursor?: string;
}

interface QueryOptions extends ReadOptions {
  /** Natural-language query string. */
  query: string;
  /** Optional time window. */
  start_date?: string;
  end_date?: string;
  limit?: number;
}

const DEFAULT_TTL_MS = 5 * 60 * 1000;

/**
 * List meetings within an optional date range. Mirrors the official MCP tool
 * `list_meetings`. All plans.
 */
export async function listMeetings(
  client: GranolaClient,
  options: ListMeetingsOptions = {},
): Promise<GranolaMeeting[]> {
  const cache = options.cache;
  const args: Record<string, unknown> = {};
  if (options.start_date) args.start_date = options.start_date;
  if (options.end_date) args.end_date = options.end_date;
  if (options.folder_id) args.folder_id = options.folder_id;
  if (options.limit) args.limit = options.limit;
  if (options.cursor) args.cursor = options.cursor;

  const cacheKey = `granola:list_meetings:${JSON.stringify(args)}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<GranolaMeeting[]>(cacheKey);
    if (cached) return cached;
  }
  const result = await client.callTool("list_meetings", args, {
    plan_tier_hint: options.plan_tier_hint,
  });
  const meetings = parseListMeetings(result);
  if (cache) await cache.set(cacheKey, meetings, DEFAULT_TTL_MS);
  return meetings;
}

/**
 * Hydrate a single meeting by id. Mirrors the official MCP tool `get_meetings`
 * (note: official name is `get_meetings`, plural, per the Granola docs —
 * confusing naming on Granola's side but we honour the wire name).
 *
 * Returns null if the tool surfaces a 404; throws otherwise.
 */
export async function getMeeting(
  client: GranolaClient,
  meeting_id: string,
  options: ReadOptions = {},
): Promise<GranolaMeeting | null> {
  const cache = options.cache;
  const cacheKey = `granola:get_meeting:${meeting_id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<GranolaMeeting>(cacheKey);
    if (cached) return cached;
  }
  try {
    const result = await client.callTool(
      "get_meetings",
      { meeting_id },
      { plan_tier_hint: options.plan_tier_hint },
    );
    const meeting = parseMeeting(result);
    if (meeting && cache) await cache.set(cacheKey, meeting, DEFAULT_TTL_MS);
    return meeting;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}

/**
 * Semantic search across meeting notes. Mirrors `query_granola_meetings`.
 * All plans (Free is capped to last 30 days per Granola docs).
 */
export async function queryMeetings(
  client: GranolaClient,
  options: QueryOptions,
): Promise<GranolaMeeting[]> {
  const cache = options.cache;
  const args: Record<string, unknown> = { query: options.query };
  if (options.start_date) args.start_date = options.start_date;
  if (options.end_date) args.end_date = options.end_date;
  if (options.limit) args.limit = options.limit;

  const cacheKey = `granola:query_granola_meetings:${JSON.stringify(args)}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<GranolaMeeting[]>(cacheKey);
    if (cached) return cached;
  }
  const result = await client.callTool("query_granola_meetings", args, {
    plan_tier_hint: options.plan_tier_hint,
  });
  const meetings = parseListMeetings(result);
  if (cache) await cache.set(cacheKey, meetings, DEFAULT_TTL_MS);
  return meetings;
}
