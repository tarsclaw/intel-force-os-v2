// @ifos/open-banking — public API
//
// Used by Cash Conductor agent (W4-7 build wave) per
// agents/recruitment/cash-conductor/tools.yaml capabilities:
//   open_banking_truelayer | open_banking_plaid_uk → refreshTokens + getValidAccessToken
//   (bank transaction ingest)                     → listTransactionsSince
//   (cash-flow forecast balance)                  → getAccountBalance
//
// Provider scope (W4 Day-26):
//   - TrueLayer: fully implemented (v1.0 path per Cash Conductor §9 Q2).
//   - Plaid UK: interface present; implementation throws NotImplementedError
//     until v1.1+ (no UK Cash Conductor pilot needs Plaid at v1.0).
//
// PSD2 90-day consent tracking is THE load-bearing distinction from Xero / QB:
// banks legally require user re-authentication every 90 days regardless of
// refresh-token TTL. See auth.ts getTokenAgeStage + the README §"PSD2 consent
// lifecycle" for the operator alerting flow.

export {
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  getTokenAgeStage,
  _resetInflightForTest,
} from "./auth.js";
export {
  OpenBankingClient,
  TRUELAYER_API_PROD,
  TRUELAYER_API_SANDBOX,
  DEFAULT_TIMEOUT_MS,
} from "./client.js";
export { listTransactionsSince } from "./transactions.js";
export { getAccountBalance } from "./balance.js";
export { OpenBankingCache } from "./cache.js";
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
export {
  OpenBankingError,
  OpenBankingAuthError,
  OpenBankingConsentExpiredError,
  OpenBankingRateLimitError,
  OpenBankingNotFoundError,
  NotImplementedError,
} from "./errors.js";
export type {
  OpenBankingProvider,
  OpenBankingTokens,
  OpenBankingConfig,
  OpenBankingTransaction,
  OpenBankingBalance,
  TokenAgeStage,
  TokenAgeReport,
  OpenBankingClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";
