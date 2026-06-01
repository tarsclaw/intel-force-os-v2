// @ifos/xero — public API
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability ID
//       on agents/recruitment/cash-conductor/tools.yaml AND (for state-changing
//       capabilities) has an action_type entry in agents/_shared/autosend-policy.yaml.
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
//       declared as bus capabilities (no action_type; no authz check). Adding
//       a new one here does NOT require a tools.yaml edit; promoting one to a
//       capability does.
//
// Reference implementation: @ifos/companies-house. Pattern parity intentional.

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with cash-conductor/tools.yaml §xero)
// ─────────────────────────────────────────────────────────────────────────

// xero_oauth (action_type: xero_oauth, green tier per autosend-policy.yaml)
export { refreshTokens } from "./auth.js";
// xero_list_open_invoices (read-only) + xero_get_invoice (read-only)
export { listOpenInvoices, getInvoice } from "./invoices.js";
// xero_list_payments (read-only) + xero_write_payment_received
// (action_type: accounting_reconciliation_write, yellow tier per autosend-policy.yaml)
export { listPayments, writePaymentReceived } from "./payments.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once by cycle.sh Step 1; not a capability in
// the bus sense (no action_type; no authz check) — it carries the capabilities
// above through the rate-limit + retry + OAuth attach path.
export { XeroClient, XERO_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
// Token-file I/O + pure predicates
export { loadTokens, saveTokens, shouldRefresh } from "./auth.js";
// Disk cache
export { XeroCache } from "./cache.js";
// Rate-limit introspection — soft signal exposed via rateCheck() (read-only;
// see README §"Rate limits" — consumer is responsible for honouring shouldBackoff
// at the soft threshold; the hard 100% gate is enforced inside rateConsume()).
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
// Test/diagnostic
export { _resetInflightForTest } from "./auth.js";
// Error hierarchy
export {
  XeroError,
  XeroAuthError,
  XeroRateLimitError,
  XeroNotFoundError,
  XeroValidationError,
} from "./errors.js";
export type {
  XeroTokens,
  XeroOAuthConfig,
  XeroInvoice,
  XeroInvoicesResponse,
  XeroPayment,
  XeroPaymentsResponse,
  XeroPaymentWriteRequest,
  XeroClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";
