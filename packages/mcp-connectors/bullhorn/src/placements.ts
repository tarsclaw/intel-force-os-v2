// Placement read capabilities. Bullhorn entity: Placement.
// Consumer: Concierge (lifecycle state monitoring) + Cash Conductor
// (addressee resolution against cached Bullhorn placement client).

import { BullhornCache } from "./cache.js";
import { BullhornClient } from "./client.js";
import type { BullhornListResponse, BullhornPlacement } from "./types.js";

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

const DEFAULT_FIELDS =
  "id,candidate,clientCorporation,jobOrder,status,dateBegin,dateEnd,payRate,billRate,dateLastModified";
const DEFAULT_TTL_MS = 5 * 60 * 1000;

/** Single-placement fetch by Bullhorn id. */
export async function getPlacement(
  client: BullhornClient,
  id: number,
  options: ReadOptions = {},
): Promise<BullhornPlacement | null> {
  const cache = options.cache;
  const cacheKey = `bullhorn:Placement:${id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<BullhornPlacement>(cacheKey);
    if (cached) return cached;
  }
  try {
    const res = await client.request<{ data: BullhornPlacement }>(
      `/entity/Placement/${id}`,
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
 * Search placements. Common Concierge query: state-transitioned placements
 * since last poll → `"dateLastModified:[N TO *] AND status:Confirmed"`.
 */
export async function listPlacements(
  client: BullhornClient,
  options: ListOptions = {},
): Promise<BullhornPlacement[]> {
  const cache = options.cache;
  const query = options.query ?? "isDeleted:false";
  const fields = options.fields ?? DEFAULT_FIELDS;
  const start = options.start ?? 0;
  const count = options.count ?? 100;
  const cacheKey = `bullhorn:Placement:search:${query}:${fields}:${start}:${count}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<BullhornPlacement[]>(cacheKey);
    if (cached) return cached;
  }
  const res = await client.request<BullhornListResponse<BullhornPlacement>>(
    `/search/Placement`,
    { query: { query, fields, start: String(start), count: String(count) } },
  );
  if (cache) await cache.set(cacheKey, res.data, DEFAULT_TTL_MS);
  return res.data;
}
