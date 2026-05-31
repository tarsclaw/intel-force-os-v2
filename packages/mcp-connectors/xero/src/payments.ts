// Xero Payments capability surface — read + write (write is the only
// state-changing capability in this connector). Consumed by Cash Conductor
// §4 Step 6 (reconciliation write — accounting_reconciliation_write action_type,
// yellow tier per autosend-policy.yaml).

import type { XeroClient } from "./client.js";
import { XeroCache } from "./cache.js";
import type {
  XeroPayment,
  XeroPaymentsResponse,
  XeroPaymentWriteRequest,
} from "./types.js";

const PAYMENTS_CACHE_TTL_MS = 5 * 60 * 1000;

export interface ListPaymentsOptions {
  /** ISO yyyy-MM-dd; payments on/after this date. */
  since?: string;
  page?: number;
  no_cache?: boolean;
  cache?: XeroCache;
}

/** List payments received (PaymentType=ACCRECPAYMENT). */
export async function listPayments(
  client: XeroClient,
  options: ListPaymentsOptions = {},
): Promise<XeroPayment[]> {
  const cache = options.cache ?? XeroCache.fromEnv();
  const page = options.page ?? 1;
  const key = `payments:page=${page}:since=${options.since ?? "all"}`;

  if (!options.no_cache) {
    const hit = await cache.get<XeroPayment[]>(key);
    if (hit !== null) return hit;
  }

  const whereParts = ['PaymentType=="ACCRECPAYMENT"'];
  if (options.since) {
    whereParts.push(`Date>=DateTime(${options.since.replace(/-/g, ",")})`);
  }
  const query: Record<string, string> = {
    where: whereParts.join(" AND "),
    order: "Date DESC",
    page: String(page),
  };

  const res = await client.request<XeroPaymentsResponse>("/Payments", { query });
  const payments = res.Payments ?? [];
  await cache.set(key, payments, PAYMENTS_CACHE_TTL_MS);
  return payments;
}

/**
 * Write a payment received against an invoice. State-changing — emits
 * action_type='accounting_reconciliation_write' (yellow tier per
 * autosend-policy.yaml; documented in agents/recruitment/cash-conductor/agent.md §3).
 *
 * No retry on write failure — caller decides (Cash Conductor §4 Step 6
 * surfaces ESC_ACCOUNTING_WRITE_FAIL on 4xx/5xx).
 */
export async function writePaymentReceived(
  client: XeroClient,
  payment: XeroPaymentWriteRequest,
): Promise<XeroPayment> {
  const res = await client.request<XeroPaymentsResponse>("/Payments", {
    method: "PUT",
    body: { Payments: [payment] },
    max_retries: 0,
  });
  const created = res.Payments?.[0];
  if (!created) {
    throw new Error(
      "Xero PUT /Payments succeeded but response contained no Payment record",
    );
  }
  return created;
}
