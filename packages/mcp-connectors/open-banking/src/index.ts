// @ifos/open-banking — public API
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability ID
//       on agents/recruitment/cash-conductor/tools.yaml AND (for state-changing
//       capabilities) has an action_type entry in agents/_shared/autosend-policy.yaml.
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
//       declared as bus capabilities (no action_type; no authz check).
//
// Provider scope (W4 Day-26):
//   - TrueLayer: fully implemented (v1.0 path per Cash Conductor §9 Q2).
//   - Plaid UK: interface present; implementation throws NotImplementedError
//     until v1.1+ (no UK Cash Conductor pilot needs Plaid at v1.0).
//
// PSD2 90-day consent tracking is THE load-bearing distinction from Xero / QB:
// banks legally require user re-authentication every 90 days regardless of
// refresh-token TTL. See auth.ts getTokenAgeStage + README §"PSD2 consent lifecycle".

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §open-banking)
// ─────────────────────────────────────────────────────────────────────────

// open_banking_truelayer_oauth (action_type: open_banking_truelayer, green tier)
// open_banking_plaid_uk_oauth — same function with provider='plaid-uk'; throws
// NotImplementedError until v1.1+; action_type open_banking_plaid_uk green tier
// per autosend-policy.yaml (registered for set-equality even though it never
// fires in v1.0).
export { refreshTokens } from "./auth.js";
// open_banking_list_transactions (read-only)
export { listTransactionsSince } from "./transactions.js";
// open_banking_get_account_balance (read-only)
export { getAccountBalance } from "./balance.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once by cycle.sh Step 1; provider-aware base URL
export {
  OpenBankingClient,
  TRUELAYER_API_PROD,
  TRUELAYER_API_SANDBOX,
  DEFAULT_TIMEOUT_MS,
} from "./client.js";
// Token-file I/O + pure predicates (shouldRefresh for access-token age;
// getTokenAgeStage for PSD2 consent-expiry staged alerting)
export {
  loadTokens,
  saveTokens,
  shouldRefresh,
  getTokenAgeStage,
} from "./auth.js";
// Disk cache (transactions TTL 5min; balance TTL 0)
export { OpenBankingCache } from "./cache.js";
// Rate-limit introspection — soft signal exposed via rateCheck() (read-only;
// consumer responsible for honouring shouldBackoff at the 80% soft threshold;
// hard 100% gate is enforced inside rateConsume()).
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
// Test/diagnostic
export { _resetInflightForTest } from "./auth.js";
// Error hierarchy (OpenBankingConsentExpiredError + NotImplementedError are
// load-bearing for the consumer's branching logic)
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
