// @ifos/quickbooks — public API
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability ID
//       on agents/recruitment/cash-conductor/tools.yaml AND (for state-changing
//       capabilities) has an action_type entry in agents/_shared/autosend-policy.yaml.
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
//       declared as bus capabilities (no action_type; no authz check).
//
// Reference implementation: @ifos/xero. Pattern parity intentional —
// review-mcp-connector §1 requires capability surface set-equality.

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §quickbooks)
// ─────────────────────────────────────────────────────────────────────────

// quickbooks_oauth (action_type: quickbooks_oauth, green tier per autosend-policy.yaml)
export { refreshTokens } from "./auth.js";
// quickbooks_list_open_invoices (read-only) + quickbooks_get_invoice (read-only)
export { listOpenInvoices, getInvoice } from "./invoices.js";
// quickbooks_list_payments (read-only) + quickbooks_write_payment_received
// (action_type: accounting_reconciliation_write, yellow tier per autosend-policy.yaml)
export { listPayments, writePaymentReceived } from "./payments.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once by cycle.sh Step 1; per-realm URL construction
export {
  QbClient,
  QB_BASE_URL_PRODUCTION,
  QB_BASE_URL_SANDBOX,
  DEFAULT_TIMEOUT_MS,
} from "./client.js";
// Token-file I/O + pure predicates (shouldRefresh for access; refreshTokenNearExpiry
// for the 7-day re-consent danger window — operator alerting hook)
export {
  loadTokens,
  saveTokens,
  shouldRefresh,
  refreshTokenNearExpiry,
} from "./auth.js";
// Disk cache
export { QbCache } from "./cache.js";
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
// Error hierarchy
export {
  QbError,
  QbAuthError,
  QbRateLimitError,
  QbNotFoundError,
  QbValidationError,
} from "./errors.js";
export type {
  QbTokens,
  QbOAuthConfig,
  QbInvoice,
  QbQueryResponse,
  QbPayment,
  QbPaymentWriteRequest,
  QbClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";
