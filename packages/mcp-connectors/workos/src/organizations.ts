// Organization read capabilities. WorkOS resource: Organization.
// Consumer: tenant onboarding flow (resolve tenant → workos_org_id at v0.4
// supplement landing per goal-week-5-execution-plan.md Phase 4) + admin SSO
// surface (list orgs for the platform admin view).

import { WorkosCache } from "./cache.js";
import { WorkosClient } from "./client.js";
import type {
  WorkosListResponse,
  WorkosOrganization,
} from "./types.js";

interface ReadOptions {
  /** Cache namespace (per-org isolation via cache key prefix). */
  cache?: WorkosCache;
  /** Skip cache (force live read). */
  no_cache?: boolean;
}

interface ListOptions extends ReadOptions {
  /** Page size (WorkOS max 100). */
  limit?: number;
  /** Cursor for forward pagination. */
  after?: string;
  /** Cursor for backward pagination. */
  before?: string;
  /** Filter by domain (e.g. ?domains=acme-tech.co.uk). */
  domains?: string[];
}

const DEFAULT_TTL_MS = 10 * 60 * 1000;

/**
 * Fetch a single org by id (e.g. "org_01ABCDE…"). Cached 10 min.
 * Returns null on 404; throws on auth/rate-limit/5xx per typed errors.
 */
export async function getOrganization(
  client: WorkosClient,
  org_id: string,
  options: ReadOptions = {},
): Promise<WorkosOrganization | null> {
  const cache = options.cache;
  const cacheKey = `workos:Organization:${org_id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosOrganization>(cacheKey);
    if (cached) return cached;
  }
  try {
    const res = await client.request<WorkosOrganization>(
      `/organizations/${org_id}`,
      { org_id },
    );
    if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
    return res;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}

/**
 * List orgs (admin/platform view). Rate-limit bucketed under "global" since
 * this is a top-level endpoint not scoped to a specific tenant.
 */
export async function listOrganizations(
  client: WorkosClient,
  options: ListOptions = {},
): Promise<WorkosListResponse<WorkosOrganization>> {
  const cache = options.cache;
  const limit = options.limit ?? 100;
  const query: Record<string, string> = { limit: String(limit) };
  if (options.after) query.after = options.after;
  if (options.before) query.before = options.before;
  if (options.domains) query.domains = options.domains.join(",");

  const cacheKey = `workos:Organization:list:${JSON.stringify(query)}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosListResponse<WorkosOrganization>>(cacheKey);
    if (cached) return cached;
  }
  const res = await client.request<WorkosListResponse<WorkosOrganization>>(
    `/organizations`,
    { query },
  );
  if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
  return res;
}
