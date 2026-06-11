// Client-corporation read capabilities. Bullhorn entity: ClientCorporation.
// Consumer: Concierge (resolve client name for comms templating) +
// Cash Conductor (addressee resolution).

import { BullhornCache } from "./cache.js";
import { BullhornClient } from "./client.js";
import type { BullhornClient as BullhornClientCorp, BullhornListResponse } from "./types.js";

interface ReadOptions {
  cache?: BullhornCache;
  no_cache?: boolean;
}

interface ListOptions extends ReadOptions {
  query?: string;
  fields?: string;
  start?: number;
  count?: number;
}

const DEFAULT_FIELDS = "id,name,status,industry,numEmployees,website,dateLastModified";
const DEFAULT_TTL_MS = 15 * 60 * 1000; // ClientCorporation changes less frequently than Candidate

/** Single client-corporation fetch by Bullhorn id. */
export async function getClient(
  client: BullhornClient,
  id: number,
  options: ReadOptions = {},
): Promise<BullhornClientCorp | null> {
  const cache = options.cache;
  const cacheKey = `bullhorn:ClientCorporation:${id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<BullhornClientCorp>(cacheKey);
    if (cached) return cached;
  }
  try {
    const res = await client.request<{ data: BullhornClientCorp }>(
      `/entity/ClientCorporation/${id}`,
      { query: { fields: DEFAULT_FIELDS } },
    );
    if (cache) await cache.set(cacheKey, res.data, DEFAULT_TTL_MS);
    return res.data;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}

/** Search client-corporations. */
export async function listClients(
  client: BullhornClient,
  options: ListOptions = {},
): Promise<BullhornClientCorp[]> {
  const cache = options.cache;
  const query = options.query ?? "isDeleted:false";
  const fields = options.fields ?? DEFAULT_FIELDS;
  const start = options.start ?? 0;
  const count = options.count ?? 100;
  const cacheKey = `bullhorn:ClientCorporation:search:${query}:${fields}:${start}:${count}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<BullhornClientCorp[]>(cacheKey);
    if (cached) return cached;
  }
  const res = await client.request<BullhornListResponse<BullhornClientCorp>>(
    `/search/ClientCorporation`,
    { query: { query, fields, start: String(start), count: String(count) } },
  );
  if (cache) await cache.set(cacheKey, res.data, DEFAULT_TTL_MS);
  return res.data;
}

/**
 * Update a client-corporation's mutable fields. Bullhorn POST
 * /entity/ClientCorporation/{id}. Used by Janitor for Step 9 field-backfill
 * (client.industry / client.companies_house_number / client.size_employees
 * per agent.md §3 Output 2.2; action_type='bullhorn_field_backfill' yellow
 * tier). Writes are non-retryable per client.ts retry policy — caller
 * decides on 4xx/5xx (Janitor: 4xx skip; 5xx retry-once with backoff).
 */
export async function updateClient(
  client: BullhornClient,
  id: number,
  patch: Partial<BullhornClientCorp>,
): Promise<{ changedEntityType: string; changedEntityId: number; changeType: string }> {
  return client.request<{
    changedEntityType: string;
    changedEntityId: number;
    changeType: string;
  }>(`/entity/ClientCorporation/${id}`, {
    method: "POST",
    body: patch,
  });
}
