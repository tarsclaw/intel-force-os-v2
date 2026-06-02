// Candidate read + update capabilities. Bullhorn entity: Candidate.
// Consumer: Janitor (dedup + field backfill) + Scribe (post-call attribution).

import { BullhornCache } from "./cache.js";
import { BullhornClient } from "./client.js";
import type { BullhornCandidate, BullhornListResponse } from "./types.js";

interface ReadOptions {
  /** Cache namespace (per-corporation tenant isolation handled by config). */
  cache?: BullhornCache;
  /** Skip cache (force live read). */
  no_cache?: boolean;
}

interface ListOptions extends ReadOptions {
  /** Bullhorn `query` parameter (Lucene-style); e.g. "isDeleted:false". */
  query?: string;
  /** Bullhorn `fields` list (comma-separated); defaults to a minimal set. */
  fields?: string;
  /** Pagination start offset. */
  start?: number;
  /** Page size (Bullhorn max 500). */
  count?: number;
}

const DEFAULT_FIELDS = "id,firstName,lastName,email,email2,email3,status,dateAdded,dateLastModified,owner,occupation";
const DEFAULT_TTL_MS = 5 * 60 * 1000;

/**
 * Single-candidate fetch by Bullhorn id. Cached by default (5 min TTL).
 * Returns null on 404; throws on auth/rate-limit/5xx per typed errors.
 */
export async function getCandidate(
  client: BullhornClient,
  id: number,
  options: ReadOptions = {},
): Promise<BullhornCandidate | null> {
  const cache = options.cache;
  const cacheKey = `bullhorn:Candidate:${id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<BullhornCandidate>(cacheKey);
    if (cached) return cached;
  }
  try {
    const res = await client.request<{ data: BullhornCandidate }>(
      `/entity/Candidate/${id}`,
      { query: { fields: DEFAULT_FIELDS } },
    );
    if (cache) await cache.set(cacheKey, res.data, DEFAULT_TTL_MS);
    return res.data;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}

/**
 * Search candidates via Bullhorn /search endpoint.
 * Per-corporation isolation handled by config.corporation_id (passed to
 * client which enforces via per-corp rate-limit + REST URL).
 */
export async function listCandidates(
  client: BullhornClient,
  options: ListOptions = {},
): Promise<BullhornCandidate[]> {
  const cache = options.cache;
  const query = options.query ?? "isDeleted:false";
  const fields = options.fields ?? DEFAULT_FIELDS;
  const start = options.start ?? 0;
  const count = options.count ?? 100;
  const cacheKey = `bullhorn:Candidate:search:${query}:${fields}:${start}:${count}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<BullhornCandidate[]>(cacheKey);
    if (cached) return cached;
  }
  const res = await client.request<BullhornListResponse<BullhornCandidate>>(
    `/search/Candidate`,
    { query: { query, fields, start: String(start), count: String(count) } },
  );
  if (cache) await cache.set(cacheKey, res.data, DEFAULT_TTL_MS);
  return res.data;
}

/**
 * Update a candidate's mutable fields. Bullhorn POST /entity/Candidate/{id}.
 * Used by Janitor for dedup-merge + field-backfill operations. Writes are
 * non-retryable per client.ts retry policy — caller decides on 4xx/5xx.
 */
export async function updateCandidate(
  client: BullhornClient,
  id: number,
  patch: Partial<BullhornCandidate>,
): Promise<{ changedEntityType: string; changedEntityId: number; changeType: string }> {
  return client.request<{
    changedEntityType: string;
    changedEntityId: number;
    changeType: string;
  }>(`/entity/Candidate/${id}`, {
    method: "POST",
    body: patch,
  });
}
