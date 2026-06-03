// CV-Library candidate-search capability. Used by Sourcing Scout (W9) at
// cycle.sh Step 6 for source #3 in the 3-source v1.0 candidate pool.
//
// TODO(W6-live): verify exact endpoint paths against CV-Library Recruiter
// API docs at commercial signup. v0.1.0 uses /v1/candidates/search +
// /v1/candidates/{id} as placeholders (TBD verification).

import { CVLibraryCache } from "./cache.js";
import { CVLibraryClient } from "./client.js";
import type {
  CVLibraryCandidate,
  CVLibraryCandidateSearchOptions,
  CVLibraryListResponse,
} from "./types.js";

interface ReadOptions {
  cache?: CVLibraryCache;
  no_cache?: boolean;
}

const DEFAULT_TTL_MS = 60 * 60 * 1000; // 1 hour

/**
 * Search CV-Library candidates by brief dimensions.
 * TODO(W6-live): verify exact endpoint path + query param names.
 */
export async function searchCandidates(
  client: CVLibraryClient,
  options: CVLibraryCandidateSearchOptions & ReadOptions = {},
): Promise<CVLibraryListResponse<CVLibraryCandidate>> {
  const cache = options.cache;
  const query: Record<string, string> = {};
  if (options.keywords) query.keywords = options.keywords;
  if (options.location) query.location = options.location;
  if (options.salary_min !== undefined) query.salary_min = String(options.salary_min);
  if (options.salary_max !== undefined) query.salary_max = String(options.salary_max);
  if (options.limit !== undefined) query.limit = String(options.limit);
  if (options.offset !== undefined) query.offset = String(options.offset);

  const cacheKey = `cv-library:candidates:search:${JSON.stringify(query)}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<CVLibraryListResponse<CVLibraryCandidate>>(cacheKey);
    if (cached) return cached;
  }
  // TODO(W6-live): verify path against CV-Library Recruiter API docs.
  const res = await client.request<CVLibraryListResponse<CVLibraryCandidate>>(
    `/v1/candidates/search`,
    { query },
  );
  if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
  return res;
}

/**
 * Fetch a single candidate by CV-Library-internal candidate_id.
 * Returns null on 404; throws on auth/rate-limit/5xx per typed errors.
 */
export async function getCandidate(
  client: CVLibraryClient,
  candidate_id: string,
  options: ReadOptions = {},
): Promise<CVLibraryCandidate | null> {
  const cache = options.cache;
  const cacheKey = `cv-library:candidates:${candidate_id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<CVLibraryCandidate>(cacheKey);
    if (cached) return cached;
  }
  try {
    // TODO(W6-live): verify path against CV-Library Recruiter API docs.
    const res = await client.request<CVLibraryCandidate>(
      `/v1/candidates/${candidate_id}`,
    );
    if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
    return res;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}
