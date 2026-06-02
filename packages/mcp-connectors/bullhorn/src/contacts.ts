// Client-contact read capabilities. Bullhorn entity: ClientContact.
// Consumer: Concierge (resolve recipient email for client-side comms) +
// Cash Conductor (verify invoice addressee matches Bullhorn placement client).

import { BullhornCache } from "./cache.js";
import { BullhornClient } from "./client.js";
import type { BullhornContact, BullhornListResponse } from "./types.js";

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
  "id,clientCorporation,firstName,lastName,email,status,dateLastModified";
const DEFAULT_TTL_MS = 10 * 60 * 1000;

/** Single client-contact fetch by Bullhorn id. */
export async function getContact(
  client: BullhornClient,
  id: number,
  options: ReadOptions = {},
): Promise<BullhornContact | null> {
  const cache = options.cache;
  const cacheKey = `bullhorn:ClientContact:${id}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<BullhornContact>(cacheKey);
    if (cached) return cached;
  }
  try {
    const res = await client.request<{ data: BullhornContact }>(
      `/entity/ClientContact/${id}`,
      { query: { fields: DEFAULT_FIELDS } },
    );
    if (cache) await cache.set(cacheKey, res.data, DEFAULT_TTL_MS);
    return res.data;
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}

/** Search client-contacts. */
export async function listContacts(
  client: BullhornClient,
  options: ListOptions = {},
): Promise<BullhornContact[]> {
  const cache = options.cache;
  const query = options.query ?? "isDeleted:false";
  const fields = options.fields ?? DEFAULT_FIELDS;
  const start = options.start ?? 0;
  const count = options.count ?? 100;
  const cacheKey = `bullhorn:ClientContact:search:${query}:${fields}:${start}:${count}`;
  if (cache && !options.no_cache) {
    const cached = await cache.get<BullhornContact[]>(cacheKey);
    if (cached) return cached;
  }
  const res = await client.request<BullhornListResponse<BullhornContact>>(
    `/search/ClientContact`,
    { query: { query, fields, start: String(start), count: String(count) } },
  );
  if (cache) await cache.set(cacheKey, res.data, DEFAULT_TTL_MS);
  return res.data;
}
