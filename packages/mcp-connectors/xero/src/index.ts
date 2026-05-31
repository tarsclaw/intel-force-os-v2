// @ifos/xero — public API
//
// Used by Cash Conductor agent (W4-7 build wave) per
// agents/recruitment/cash-conductor/tools.yaml capabilities:
//   xero_oauth                       → auth.refreshTokens + client.getValidAccessToken
//   accounting_reconciliation_write  → payments.writePaymentReceived
//   (read-only invoice register)     → invoices.listOpenInvoices + getInvoice
//
// Reference implementation: @ifos/companies-house. Pattern parity intentional —
// new connectors mirror this structure (see review-mcp-connector skill §1).

export {
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  _resetInflightForTest,
} from "./auth.js";
export { XeroClient, XERO_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
export { listOpenInvoices, getInvoice } from "./invoices.js";
export { listPayments, writePaymentReceived } from "./payments.js";
export { XeroCache } from "./cache.js";
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
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
