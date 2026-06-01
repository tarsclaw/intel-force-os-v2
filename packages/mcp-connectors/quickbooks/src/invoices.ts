// QuickBooks Invoices capability surface — read-only (list + get).
// Consumed by Cash Conductor §4 Step 4 (invoice register ingest).
//
// QB uses the Query API for list operations:
//   GET /v3/company/<realmId>/query?query=SELECT * FROM Invoice WHERE Balance > '0'
// Single-entity reads use the entity endpoint:
//   GET /v3/company/<realmId>/invoice/<id>

import type { QbClient } from "./client.js";
import { QbCache } from "./cache.js";
import type { QbInvoice, QbQueryResponse } from "./types.js";

const INVOICE_CACHE_TTL_MS = 5 * 60 * 1000;

export interface ListOpenInvoicesOptions {
  /** ISO yyyy-MM-dd; filter to invoices issued on/after this date. */
  issued_since?: string;
  /** 1-indexed start position (QB pagination). 1000 max per page. */
  start_position?: number;
  max_results?: number;
  no_cache?: boolean;
  cache?: QbCache;
}

/**
 * List open invoices (Balance > 0).
 * QB pagination uses startposition + maxresults; default 100 per call.
 */
export async function listOpenInvoices(
  client: QbClient,
  options: ListOpenInvoicesOptions = {},
): Promise<QbInvoice[]> {
  const cache = options.cache ?? QbCache.fromEnv();
  const start = options.start_position ?? 1;
  const max = options.max_results ?? 100;
  const key = `invoices:open:start=${start}:max=${max}:since=${options.issued_since ?? "all"}`;

  if (!options.no_cache) {
    const hit = await cache.get<QbInvoice[]>(key);
    if (hit !== null) return hit;
  }

  // QB query syntax: SQL-like, with single-quote string literals
  let query = "SELECT * FROM Invoice WHERE Balance > '0'";
  if (options.issued_since) {
    query += ` AND TxnDate >= '${options.issued_since}'`;
  }
  query += ` STARTPOSITION ${start} MAXRESULTS ${max}`;

  const res = await client.request<QbQueryResponse<"Invoice", QbInvoice>>(
    "/query",
    { query: { query } },
  );
  const invoices = res.QueryResponse.Invoice ?? [];
  await cache.set(key, invoices, INVOICE_CACHE_TTL_MS);
  return invoices;
}

/** Get a single invoice by QB Id (numeric string). */
export async function getInvoice(
  client: QbClient,
  invoiceId: string,
  options: { cache?: QbCache; no_cache?: boolean } = {},
): Promise<QbInvoice | null> {
  const cache = options.cache ?? QbCache.fromEnv();
  const key = `invoice:${invoiceId}`;
  if (!options.no_cache) {
    const hit = await cache.get<QbInvoice>(key);
    if (hit !== null) return hit;
  }
  // Single-entity read returns { Invoice: {...} } (not wrapped in QueryResponse)
  const res = await client.request<{ Invoice: QbInvoice }>(
    `/invoice/${encodeURIComponent(invoiceId)}`,
  );
  const inv = res.Invoice ?? null;
  if (inv) await cache.set(key, inv, INVOICE_CACHE_TTL_MS);
  return inv;
}
