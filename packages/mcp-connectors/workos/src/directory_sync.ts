// Directory Sync read capabilities. WorkOS resources: Directory + DirectoryUser
// + DirectoryGroup (SCIM-backed mirror of the tenant's IdP user/group state).
// Consumer: tenant provisioning view (admin sees which users have been pushed
// from their IdP) + Janitor v1.1+ (could enrich candidate-vs-employee dedup
// against the directory, but v1.0 does not).
//
// v1.0 surface is READ-ONLY. SCIM write-back (push provisioning changes from
// IFOS into the tenant IdP) is v1.1+ scope per master brief §6 + plan-doc §6.

import { WorkosCache } from "./cache.js";
import { WorkosClient } from "./client.js";
import type {
  WorkosDirectory,
  WorkosDirectoryGroup,
  WorkosDirectoryUser,
  WorkosListResponse,
} from "./types.js";

interface ReadOptions {
  cache?: WorkosCache;
  no_cache?: boolean;
}

interface ListDirectoriesOptions extends ReadOptions {
  limit?: number;
  after?: string;
  before?: string;
  organization_id?: string;
}

interface ListUsersOptions extends ReadOptions {
  limit?: number;
  after?: string;
  before?: string;
  /** Filter by directory (recommended). */
  directory?: string;
  /** Filter by group (intersect with directory). */
  group?: string;
}

interface ListGroupsOptions extends ReadOptions {
  limit?: number;
  after?: string;
  before?: string;
  directory?: string;
}

const DEFAULT_TTL_MS = 10 * 60 * 1000;

/** Fetch a single directory by id (e.g. "directory_01…"). */
export async function getDirectory(
  client: WorkosClient,
  directory_id: string,
  options: ReadOptions = {},
): Promise<WorkosDirectory | null> {
  const cache = options.cache;
  const cacheKey = `workos:Directory:${directory_id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosDirectory>(cacheKey);
    if (cached) return cached;
  }
  try {
    const res = await client.request<WorkosDirectory>(
      `/directories/${directory_id}`,
    );
    if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
    return res;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}

/** List directories (admin view; typically scoped to organization_id). */
export async function listDirectories(
  client: WorkosClient,
  options: ListDirectoriesOptions = {},
): Promise<WorkosListResponse<WorkosDirectory>> {
  const cache = options.cache;
  const limit = options.limit ?? 100;
  const query: Record<string, string> = { limit: String(limit) };
  if (options.after) query.after = options.after;
  if (options.before) query.before = options.before;
  if (options.organization_id) query.organization_id = options.organization_id;

  const cacheKey = `workos:Directory:list:${JSON.stringify(query)}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosListResponse<WorkosDirectory>>(cacheKey);
    if (cached) return cached;
  }
  const res = await client.request<WorkosListResponse<WorkosDirectory>>(
    `/directories`,
    { query, org_id: options.organization_id },
  );
  if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
  return res;
}

/** List directory users (admin view; filter by directory in practice). */
export async function listDirectoryUsers(
  client: WorkosClient,
  options: ListUsersOptions = {},
): Promise<WorkosListResponse<WorkosDirectoryUser>> {
  const cache = options.cache;
  const limit = options.limit ?? 100;
  const query: Record<string, string> = { limit: String(limit) };
  if (options.after) query.after = options.after;
  if (options.before) query.before = options.before;
  if (options.directory) query.directory = options.directory;
  if (options.group) query.group = options.group;

  const cacheKey = `workos:DirectoryUser:list:${JSON.stringify(query)}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosListResponse<WorkosDirectoryUser>>(cacheKey);
    if (cached) return cached;
  }
  const res = await client.request<WorkosListResponse<WorkosDirectoryUser>>(
    `/directory_users`,
    { query },
  );
  if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
  return res;
}

/** Single user by id (e.g. "directory_user_01…"). Returns null on 404. */
export async function getDirectoryUser(
  client: WorkosClient,
  user_id: string,
  options: ReadOptions = {},
): Promise<WorkosDirectoryUser | null> {
  const cache = options.cache;
  const cacheKey = `workos:DirectoryUser:${user_id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosDirectoryUser>(cacheKey);
    if (cached) return cached;
  }
  try {
    const res = await client.request<WorkosDirectoryUser>(
      `/directory_users/${user_id}`,
    );
    if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
    return res;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}

/** List directory groups (admin view; filter by directory in practice). */
export async function listDirectoryGroups(
  client: WorkosClient,
  options: ListGroupsOptions = {},
): Promise<WorkosListResponse<WorkosDirectoryGroup>> {
  const cache = options.cache;
  const limit = options.limit ?? 100;
  const query: Record<string, string> = { limit: String(limit) };
  if (options.after) query.after = options.after;
  if (options.before) query.before = options.before;
  if (options.directory) query.directory = options.directory;

  const cacheKey = `workos:DirectoryGroup:list:${JSON.stringify(query)}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosListResponse<WorkosDirectoryGroup>>(cacheKey);
    if (cached) return cached;
  }
  const res = await client.request<WorkosListResponse<WorkosDirectoryGroup>>(
    `/directory_groups`,
    { query },
  );
  if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
  return res;
}

/** Single group by id (e.g. "directory_group_01…"). Returns null on 404. */
export async function getDirectoryGroup(
  client: WorkosClient,
  group_id: string,
  options: ReadOptions = {},
): Promise<WorkosDirectoryGroup | null> {
  const cache = options.cache;
  const cacheKey = `workos:DirectoryGroup:${group_id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<WorkosDirectoryGroup>(cacheKey);
    if (cached) return cached;
  }
  try {
    const res = await client.request<WorkosDirectoryGroup>(
      `/directory_groups/${group_id}`,
    );
    if (cache) await cache.set(cacheKey, res, DEFAULT_TTL_MS);
    return res;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}
