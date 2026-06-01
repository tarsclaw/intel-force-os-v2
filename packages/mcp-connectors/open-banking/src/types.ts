// Open Banking API types — provider-agnostic core + provider-tagged variants.
// IFOS Cash Conductor consumes via the provider-switching client façade.
//
// Provider scope (W4 Day-26 scaffold):
//   - TrueLayer: fully implemented (v1.0 path per Cash Conductor §9 Q2).
//   - Plaid UK: interface defined; implementation deferred to v1.1+ (throws
//     NotImplementedError until then).

export type OpenBankingProvider = "truelayer" | "plaid-uk";

export interface OpenBankingTokens {
  access_token: string;
  refresh_token: string;
  /** Unix epoch milliseconds when access_token expires (~1h TrueLayer / ~1h Plaid). */
  expires_at_ms: number;
  /**
   * Unix epoch milliseconds when the PSD2 CONSENT expires (~90 days).
   * Distinct from refresh_token expiry — PSD2 mandates user re-authentication
   * every 90 days regardless of refresh-token TTL.
   */
  consent_expires_at_ms: number;
  scope: string;
  token_type: string;
}

export interface OpenBankingConfig {
  provider: OpenBankingProvider;
  client_id: string;
  client_secret: string;
  /** Per-bank-connection identifier from the provider (TrueLayer: account_id; Plaid UK: item_id). */
  connection_id: string;
  environment: "sandbox" | "production";
  token_file_path: string;
}

export interface OpenBankingTransaction {
  /** Provider-assigned transaction id. */
  transaction_id: string;
  /** ISO 8601 timestamp (UTC) when the transaction posted. */
  posted_at: string;
  /** Amount in major currency units (positive = credit / inbound; negative = debit / outbound). */
  amount: number;
  currency: string;
  /** Free-text counterparty / payee name as provided by the bank. */
  description: string;
  /** Optional bank-reference / memo field. */
  reference: string | null;
  /** Provider-specific raw payload preserved for audit + future fields. */
  raw_provider_payload: Record<string, unknown>;
}

export interface OpenBankingBalance {
  /** Current available balance in major currency units. */
  available: number;
  /** Current cleared balance (may differ from `available` during pending transactions). */
  current: number;
  currency: string;
  /** ISO 8601 timestamp (UTC) when the balance was fetched. */
  fetched_at: string;
}

export type TokenAgeStage = "fresh" | "info" | "warn" | "blocking";

export interface TokenAgeReport {
  stage: TokenAgeStage;
  days_until_consent_expiry: number;
  consent_expires_at_ms: number;
}

export interface OpenBankingClientOptions {
  config: OpenBankingConfig;
  fetchFn?: typeof fetch;
  now?: () => number;
}
