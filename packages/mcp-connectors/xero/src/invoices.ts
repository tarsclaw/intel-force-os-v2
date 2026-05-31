// Xero Invoices capability surface — read-only (list + get).
// Consumed by Cash Conductor §4 Step 4 (invoice register ingest).

import type { XeroClient } from "./client.js";
import { XeroCache } from "./cache.js";
import type { XeroInvoice, XeroInvoicesResponse } from "./types.js";

const INVOICE_CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes — invoices change often

export interface ListOpenInvoicesOptions {
  /** ISO yyyy-MM-dd; filter to invoices issued on/after this date. */
  issued_since?: string;
  /** 1-indexed page; Xero returns 100 per page. */
  page?: number;
  /** Bypass disk cache. */
  no_cache?: boolean;
  cache?: XeroCache;
}

/**
 * List open invoices (Status IN (AUTHORISED, SUBMITTED) with AmountDue > 0).
 * Pagination via `page` (1-indexed; 100 per page); call repeatedly until
 * fewer than 100 results return.
 */
export async function listOpenInvoices(
  client: XeroClient,
  options: ListOpenInvoicesOptions = {},
): Promise<XeroInvoice[]> {
  const cache = options.cache ?? XeroCache.fromEnv();
  const page = options.page ?? 1;
  const key = `invoices:open:page=${page}:issued_since=${options.issued_since ?? "all"}`;

  if (!options.no_cache) {
    const hit = await cache.get<XeroInvoice[]>(key);
    if (hit !== null) return hit;
  }

  // Xero `where` syntax: e.g. AmountDue>0 AND Status==\"AUTHORISED\"
  const whereParts = ['AmountDue>0', 'Status=="AUTHORISED"||Status=="SUBMITTED"'];
  if (options.issued_since) {
    whereParts.push(`Date>=DateTime(${options.issued_since.replace(/-/g, ",")})`);
  }
  const query: Record<string, string> = {
    where: whereParts.join(" AND "),
    order: "Date DESC",
    page: String(page),
  };

  const res = await client.request<XeroInvoicesResponse>("/Invoices", { query });
  const invoices = res.Invoices ?? [];
  await cache.set(key, invoices, INVOICE_CACHE_TTL_MS);
  return invoices;
}

/** Get a single invoice by Xero InvoiceID (UUID). */
export async function getInvoice(
  client: XeroClient,
  invoiceId: string,
  options: { cache?: XeroCache; no_cache?: boolean } = {},
): Promise<XeroInvoice | null> {
  const cache = options.cache ?? XeroCache.fromEnv();
  const key = `invoice:${invoiceId}`;
  if (!options.no_cache) {
    const hit = await cache.get<XeroInvoice>(key);
    if (hit !== null) return hit;
  }
  const res = await client.request<XeroInvoicesResponse>(
    `/Invoices/${encodeURIComponent(invoiceId)}`,
  );
  const inv = res.Invoices?.[0] ?? null;
  if (inv) await cache.set(key, inv, INVOICE_CACHE_TTL_MS);
  return inv;
}
