// Top-level capabilities exposed by the connector. Composes CHClient +
// CHCache + rate-limit gates per call.

import { CHCache } from "./cache.js";
import { CHClient, CHClientOptions } from "./client.js";
import { CHRateLimitError } from "./errors.js";
import { check as rateCheck, consume as rateConsume } from "./rate-limit.js";
import type {
  CHFilingHistoryResponse,
  CHOfficersResponse,
  CHProfile,
  CHSearchResponse,
  CHSearchResult,
} from "./types.js";

const CACHE_TTL_MS = 7 * 24 * 60 * 60 * 1000; // 7 days per tools.yaml

let memoClient: CHClient | null = null;
function getClient(opts?: CHClientOptions): CHClient {
  if (opts) return new CHClient(opts);
  if (!memoClient) memoClient = new CHClient();
  return memoClient;
}

function getCache(): CHCache {
  return CHCache.fromEnv();
}

async function rateGated<T>(fn: () => Promise<T>, endpoint: string): Promise<T> {
  const state = rateCheck();
  if (state.shouldBackoff) {
    // Soft-budget hit; throw immediately rather than risk a 429.
    throw new CHRateLimitError(endpoint);
  }
  if (!rateConsume()) {
    throw new CHRateLimitError(endpoint);
  }
  return fn();
}

/** Reset memoised client + rate limiter (test helper). */
export function _resetForTest(): void {
  memoClient = null;
}

export async function search(
  name: string,
  opts: CHClientOptions = {},
): Promise<CHSearchResult[]> {
  const cache = getCache();
  const cacheKey = `search:${name.toLowerCase()}`;
  const cached = await cache.get<CHSearchResult[]>(cacheKey);
  if (cached) return cached;

  const client = getClient(opts);
  const response = await rateGated(
    () =>
      client.getJson<CHSearchResponse>("/search/companies", {
        q: name,
        items_per_page: "20",
      }),
    "/search/companies",
  );
  const items = response.items ?? [];
  await cache.set(cacheKey, items, CACHE_TTL_MS);
  return items;
}

export async function profile(
  companyNumber: string,
  opts: CHClientOptions = {},
): Promise<CHProfile | null> {
  const cache = getCache();
  const cacheKey = `profile:${companyNumber}`;
  const cached = await cache.get<CHProfile>(cacheKey);
  if (cached) return cached;

  const client = getClient(opts);
  try {
    const result = await rateGated(
      () => client.getJson<CHProfile>(`/company/${companyNumber}`),
      `/company/${companyNumber}`,
    );
    await cache.set(cacheKey, result, CACHE_TTL_MS);
    return result;
  } catch (err) {
    if ((err as { name?: string }).name === "CHNotFoundError") return null;
    throw err;
  }
}

export async function officers(
  companyNumber: string,
  opts: CHClientOptions = {},
): Promise<CHOfficersResponse | null> {
  const cache = getCache();
  const cacheKey = `officers:${companyNumber}`;
  const cached = await cache.get<CHOfficersResponse>(cacheKey);
  if (cached) return cached;

  const client = getClient(opts);
  try {
    const result = await rateGated(
      () => client.getJson<CHOfficersResponse>(`/company/${companyNumber}/officers`),
      `/company/${companyNumber}/officers`,
    );
    await cache.set(cacheKey, result, CACHE_TTL_MS);
    return result;
  } catch (err) {
    if ((err as { name?: string }).name === "CHNotFoundError") return null;
    throw err;
  }
}

export async function filingHistory(
  companyNumber: string,
  sinceDays: number = 90,
  opts: CHClientOptions = {},
): Promise<CHFilingHistoryResponse | null> {
  const cache = getCache();
  const cacheKey = `filings:${companyNumber}:${sinceDays}`;
  const cached = await cache.get<CHFilingHistoryResponse>(cacheKey);
  if (cached) return cached;

  const client = getClient(opts);
  try {
    const all = await rateGated(
      () =>
        client.getJson<CHFilingHistoryResponse>(`/company/${companyNumber}/filing-history`, {
          items_per_page: "35",
        }),
      `/company/${companyNumber}/filing-history`,
    );
    const cutoff = Date.now() - sinceDays * 24 * 60 * 60 * 1000;
    const filtered = (all.items ?? []).filter((f) => Date.parse(f.date) >= cutoff);
    const result: CHFilingHistoryResponse = { ...all, items: filtered };
    await cache.set(cacheKey, result, CACHE_TTL_MS);
    return result;
  } catch (err) {
    if ((err as { name?: string }).name === "CHNotFoundError") return null;
    throw err;
  }
}
