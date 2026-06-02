// Open Banking transactions capability — list transactions since a given timestamp.
// Consumed by Cash Conductor §4 Step 3 (bank transaction ingest).
//
// TrueLayer endpoint: GET /data/v1/accounts/<account_id>/transactions?from=<ISO>&to=<ISO>
// Plaid UK endpoint (v1.1+): POST /transactions/get (different shape; deferred).

import type { OpenBankingClient } from "./client.js";
import { OpenBankingCache } from "./cache.js";
import { NotImplementedError } from "./errors.js";
import type {
  OpenBankingConfig,
  OpenBankingTransaction,
} from "./types.js";

const TRANSACTIONS_CACHE_TTL_MS = 5 * 60 * 1000;

interface TrueLayerTransactionsResponse {
  results: Array<{
    transaction_id: string;
    timestamp: string;
    amount: number;
    currency: string;
    description: string;
    transaction_type?: string;
    transaction_category?: string;
    meta?: { reference?: string };
  }>;
  status: string;
}

export interface ListTransactionsOptions {
  /** ISO 8601 — fetch transactions on/after this timestamp. */
  since: string;
  /** ISO 8601 — fetch transactions on/before this timestamp (defaults to now). */
  until?: string;
  no_cache?: boolean;
  cache?: OpenBankingCache;
}

/**
 * List transactions for a connected bank account since a given timestamp.
 * Returns provider-agnostic OpenBankingTransaction shape; TrueLayer raw payload
 * preserved in `raw_provider_payload`.
 */
export async function listTransactionsSince(
  client: OpenBankingClient,
  config: OpenBankingConfig,
  options: ListTransactionsOptions,
): Promise<OpenBankingTransaction[]> {
  if (config.provider === "plaid_uk") {
    throw new NotImplementedError(
      "Plaid UK listTransactionsSince not yet implemented (v1.1+ deferred per Cash Conductor §9 Q2)",
    );
  }

  const cache = options.cache ?? OpenBankingCache.fromEnv();
  const until = options.until ?? new Date().toISOString();
  const key = `transactions:${config.connection_id}:since=${options.since}:until=${until}`;

  if (!options.no_cache) {
    const hit = await cache.get<OpenBankingTransaction[]>(key);
    if (hit !== null) return hit;
  }

  const path = `/data/v1/accounts/${encodeURIComponent(config.connection_id)}/transactions`;
  const res = await client.request<TrueLayerTransactionsResponse>(path, {
    query: { from: options.since, to: until },
  });

  const transactions: OpenBankingTransaction[] = (res.results ?? []).map((r) => ({
    transaction_id: r.transaction_id,
    posted_at: r.timestamp,
    amount: r.amount,
    currency: r.currency,
    description: r.description,
    reference: r.meta?.reference ?? null,
    raw_provider_payload: r as unknown as Record<string, unknown>,
  }));

  await cache.set(key, transactions, TRANSACTIONS_CACHE_TTL_MS);
  return transactions;
}
