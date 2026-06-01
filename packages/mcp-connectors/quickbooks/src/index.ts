// @ifos/quickbooks — public API
//
// Used by Cash Conductor agent (W4-7 build wave) per
// agents/recruitment/cash-conductor/tools.yaml capabilities:
//   quickbooks_oauth                 → auth.refreshTokens + client.getValidAccessToken
//   accounting_reconciliation_write  → payments.writePaymentReceived
//   (read-only invoice register)     → invoices.listOpenInvoices + getInvoice
//
// Reference implementation: @ifos/xero (Day-25 RATIFIED scaffold). Pattern
// parity intentional — review-mcp-connector §1 requires capability surface
// set-equality with the reference connector for the same Cash Conductor
// consumer interface.

export {
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  refreshTokenNearExpiry,
  _resetInflightForTest,
} from "./auth.js";
export {
  QbClient,
  QB_BASE_URL_PRODUCTION,
  QB_BASE_URL_SANDBOX,
  DEFAULT_TIMEOUT_MS,
} from "./client.js";
export { listOpenInvoices, getInvoice } from "./invoices.js";
export { listPayments, writePaymentReceived } from "./payments.js";
export { QbCache } from "./cache.js";
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
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
