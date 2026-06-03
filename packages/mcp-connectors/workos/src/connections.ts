// Connection read capabilities. WorkOS resource: Connection (a configured
// SSO link between an org and an identity provider — Okta, Google, Azure
// AD, OIDC, etc.).
// Consumer: admin SSO surface (verify connection state before routing a
// login attempt to WorkOS AuthKit).

import { WorkosCache } from "./cache.js";
import { WorkosClient } from "./client.js";
import type {
  WorkosConnection,
  WorkosListResponse,
} from "./types.js";

interface ReadOptions {
  cache?: WorkosCache;
  no_cache?: boolean;
}

interface ListOptions extends ReadOptions {
  limit?: number;
  after?: string;
  before?: string;
  /** Filter by org (recommended — connections are always org-scoped). */
  organization_id?: string;
  /** Filter by connection type (e.g. "OktaSAML"). */
  connection_type?: string;
  /** Filter by login domain. */
  domain?: string;
}

const DEFAULT_TTL_MS = 10 * 60 * 1000;

/**
 * Fetch a single connection by id (e.g. "conn_01ABCDE…"). Cached 10 min.
 * Returns null on 404; throws on auth/rate-limit/5xx per typed errors.
 */
export async function getConnection(
  client: WorkosClient,
  connection_id: string,
  options: ReadOptions = {},
): Promise<WorkosConnection | null> {
  const cache = options.cache;
  const cacheKey = `workos:Connection:${connection_id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosConnection>(cacheKey);
    if (cached) return cached;
  }
  try {
    const res = await client.request<WorkosConnection>(
      `/connections/${connection_id}`,
    );
    if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
    return res;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}

/**
 * List connections (admin SSO view; filter by organization_id in practice).
 */
export async function listConnections(
  client: WorkosClient,
  options: ListOptions = {},
): Promise<WorkosListResponse<WorkosConnection>> {
  const cache = options.cache;
  const limit = options.limit ?? 100;
  const query: Record<string, string> = { limit: String(limit) };
  if (options.after) query.after = options.after;
  if (options.before) query.before = options.before;
  if (options.organization_id) query.organization_id = options.organization_id;
  if (options.connection_type) query.connection_type = options.connection_type;
  if (options.domain) query.domain = options.domain;

  const cacheKey = `workos:Connection:list:${JSON.stringify(query)}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosListResponse<WorkosConnection>>(cacheKey);
    if (cached) return cached;
  }
  const res = await client.request<WorkosListResponse<WorkosConnection>>(
    `/connections`,
    {
      query,
      // If org-scoped, bucket rate-limit per that org; else "global"
      org_id: options.organization_id,
    },
  );
  if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
  return res;
}
