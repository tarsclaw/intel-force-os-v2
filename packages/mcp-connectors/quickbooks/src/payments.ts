// QuickBooks Payments capability surface — read + write (write is the only
// state-changing capability in this connector). Consumed by Cash Conductor
// §4 Step 6 (reconciliation write — accounting_reconciliation_write action_type,
// yellow tier per autosend-policy.yaml).

import type { QbClient } from "./client.js";
import { QbCache } from "./cache.js";
import type {
  QbPayment,
  QbPaymentWriteRequest,
  QbQueryResponse,
} from "./types.js";

const PAYMENTS_CACHE_TTL_MS = 5 * 60 * 1000;

export interface ListPaymentsOptions {
  /** ISO yyyy-MM-dd; payments on/after this date. */
  since?: string;
  start_position?: number;
  max_results?: number;
  no_cache?: boolean;
  cache?: QbCache;
}

/** List payments. QB doesn't separate received vs sent at the type level — caller filters via TotalAmt sign + LinkedTxn presence if needed. */
export async function listPayments(
  client: QbClient,
  options: ListPaymentsOptions = {},
): Promise<QbPayment[]> {
  const cache = options.cache ?? QbCache.fromEnv();
  const start = options.start_position ?? 1;
  const max = options.max_results ?? 100;
  const key = `payments:start=${start}:max=${max}:since=${options.since ?? "all"}`;

  if (!options.no_cache) {
    const hit = await cache.get<QbPayment[]>(key);
    if (hit !== null) return hit;
  }

  let query = "SELECT * FROM Payment";
  if (options.since) {
    query += ` WHERE TxnDate >= '${options.since}'`;
  }
  query += ` STARTPOSITION ${start} MAXRESULTS ${max}`;

  const res = await client.request<QbQueryResponse<"Payment", QbPayment>>(
    "/query",
    { query: { query } },
  );
  const payments = res.QueryResponse.Payment ?? [];
  await cache.set(key, payments, PAYMENTS_CACHE_TTL_MS);
  return payments;
}

/** CLI `write-payment` args → QuickBooks write-request mapping input. */
export interface PaymentWriteCliArgs {
  /** QB invoice Id the payment is linked to (LinkedTxn TxnId). */
  invoice: string;
  /** Payment amount (must equal the bank-deposit amount for Stage 1-2 matches). */
  amount: number;
  /** QB CustomerRef value — the customer the invoice belongs to (QB requires it on Payment). */
  customer: string;
  /** Optional ISO yyyy-MM-dd payment date (defaults to QB server date if omitted). */
  date?: string;
  /** Optional payment reference (e.g. the bank transaction id). */
  reference?: string;
}

/**
 * Pure map: CLI args → QbPaymentWriteRequest (single-invoice payment). Factored
 * out of cli.ts so the arg→payload mapping is unit-testable without a live
 * client (Cash Conductor §4 Step 6 reconciliation write).
 */
export function buildPaymentWriteRequest(
  args: PaymentWriteCliArgs,
): QbPaymentWriteRequest {
  return {
    CustomerRef: { value: args.customer },
    TotalAmt: args.amount,
    ...(args.date ? { TxnDate: args.date } : {}),
    ...(args.reference ? { PaymentRefNum: args.reference } : {}),
    Line: [
      {
        Amount: args.amount,
        LinkedTxn: [{ TxnId: args.invoice, TxnType: "Invoice" }],
      },
    ],
  };
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
  client: QbClient,
  payment: QbPaymentWriteRequest,
): Promise<QbPayment> {
  // QB POST /payment returns { Payment: {...} } (not wrapped in QueryResponse)
  const res = await client.request<{ Payment: QbPayment }>("/payment", {
    method: "POST",
    body: payment,
    max_retries: 0,
  });
  if (!res.Payment) {
    throw new Error(
      "QuickBooks POST /payment succeeded but response contained no Payment record",
    );
  }
  return res.Payment;
}
