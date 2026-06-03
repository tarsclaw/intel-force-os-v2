// Reed Recruiter API candidate-search capability. Used by Sourcing Scout
// (W9) at cycle.sh Step 5 for source #2 in the 3-source v1.0 candidate pool.
//
// Reed Recruiter API endpoint shape is INFERRED from the Jobseeker API
// pattern (verified 2026-06-03 via WebFetch). Path placeholders carry
// TODO(W6-live) markers for verification at commercial signup; the auth
// model (HTTP Basic with API key as username) is confirmed.

import { ReedCache } from "./cache.js";
import { ReedClient } from "./client.js";
import type {
  ReedCandidate,
  ReedCandidateSearchOptions,
  ReedListResponse,
} from "./types.js";

interface ReadOptions {
  /** Cache namespace (per-account isolation via cache key prefix). */
  cache?: ReedCache;
  /** Skip cache (force live read). */
  no_cache?: boolean;
}

const DEFAULT_TTL_MS = 60 * 60 * 1000; // 1 hour per cache module default

/**
 * Search Reed candidates by brief dimensions (keywords + location + salary).
 * TODO(W6-live): verify exact endpoint path against Reed Recruiter API docs
 * at commercial signup. v0.1.0 uses /candidates/search as a placeholder
 * (mirrors the Jobseeker API /search shape).
 */
export async function searchCandidates(
  client: ReedClient,
  options: ReedCandidateSearchOptions & ReadOptions = {},
): Promise<ReedListResponse<ReedCandidate>> {
  const cache = options.cache;
  const query: Record<string, string> = {};
  if (options.keywords) query.keywords = options.keywords;
  if (options.location) query.locationName = options.location;
  if (options.salary_min !== undefined) query.minimumSalary = String(options.salary_min);
  if (options.salary_max !== undefined) query.maximumSalary = String(options.salary_max);
  if (options.results_to_take !== undefined) query.resultsToTake = String(options.results_to_take);
  if (options.results_to_skip !== undefined) query.resultsToSkip = String(options.results_to_skip);

  const cacheKey = `reed:candidates:search:${JSON.stringify(query)}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<ReedListResponse<ReedCandidate>>(cacheKey);
    if (cached) return cached;
  }
  // TODO(W6-live): verify path against Reed Recruiter API docs.
  const res = await client.request<ReedListResponse<ReedCandidate>>(
    `/candidates/search`,
    { query },
  );
  if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
  return res;
}

/**
 * Fetch a single candidate by Reed-internal candidate_id. Cached 1 hour.
 * Returns null on 404; throws on auth/rate-limit/5xx per typed errors.
 */
export async function getCandidate(
  client: ReedClient,
  candidate_id: string,
  options: ReadOptions = {},
): Promise<ReedCandidate | null> {
  const cache = options.cache;
  const cacheKey = `reed:candidates:${candidate_id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<ReedCandidate>(cacheKey);
    if (cached) return cached;
  }
  try {
    // TODO(W6-live): verify path against Reed Recruiter API docs.
    const res = await client.request<ReedCandidate>(
      `/candidates/${candidate_id}`,
    );
    if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
    return res;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}
