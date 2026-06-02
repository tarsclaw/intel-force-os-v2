// Open Banking balance capability — get current account balance.
// Consumed by Cash Conductor §10 (weekly cash-flow forecast; available + cleared
// distinction matters for pending-transaction nuance).
//
// TrueLayer endpoint: GET /data/v1/accounts/<account_id>/balance
// Plaid UK endpoint (v1.1+): POST /accounts/balance/get (deferred).

import type { OpenBankingClient } from "./client.js";
import { NotImplementedError } from "./errors.js";
import type {
  OpenBankingBalance,
  OpenBankingConfig,
} from "./types.js";

interface TrueLayerBalanceResponse {
  results: Array<{
    available: number;
    current: number;
    currency: string;
    update_timestamp: string;
  }>;
  status: string;
}

/**
 * Fetch current account balance. Returns provider-agnostic OpenBankingBalance
 * shape. NOT cached by default — balances are point-in-time values; staleness
 * matters more than throughput for Cash Conductor's weekly forecast.
 */
export async function getAccountBalance(
  client: OpenBankingClient,
  config: OpenBankingConfig,
): Promise<OpenBankingBalance> {
  if (config.provider === "plaid_uk") {
    throw new NotImplementedError(
      "Plaid UK getAccountBalance not yet implemented (v1.1+ deferred per Cash Conductor §9 Q2)",
    );
  }

  const path = `/data/v1/accounts/${encodeURIComponent(config.connection_id)}/balance`;
  const res = await client.request<TrueLayerBalanceResponse>(path);

  const r = res.results?.[0];
  if (!r) {
    throw new Error(
      `TrueLayer balance fetch returned no results for connection ${config.connection_id}`,
    );
  }

  return {
    available: r.available,
    current: r.current,
    currency: r.currency,
    fetched_at: r.update_timestamp,
  };
}
