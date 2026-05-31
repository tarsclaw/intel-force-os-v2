// Xero API types — subset of the v2 API surface IFOS Cash Conductor consumes.
// Reference: https://developer.xero.com/documentation/api/accounting/overview
//
// Shapes are intentionally narrower than Xero's full schema — only fields
// Cash Conductor §3 Output 1 (reconciliation) + §3 Output 2 (chase drafts) +
// §10 (weekly report DSO) actually read.

export interface XeroTokens {
  access_token: string;
  refresh_token: string;
  /** Unix epoch milliseconds when the access_token expires. */
  expires_at_ms: number;
  /** Comma-separated scopes granted. */
  scope: string;
  /** Bearer; always 'Bearer' in v2. */
  token_type: string;
}

export interface XeroOAuthConfig {
  client_id: string;
  client_secret: string;
  /** Tenant ID (Xero "connection") this token bundle is for. */
  tenant_id: string;
  /** Token file on disk; atomic-rename writes go here. */
  token_file_path: string;
}

export interface XeroInvoice {
  InvoiceID: string;
  InvoiceNumber: string | null;
  Type: "ACCREC" | "ACCPAY";
  Status: "DRAFT" | "SUBMITTED" | "AUTHORISED" | "PAID" | "VOIDED" | "DELETED";
  Date: string; // ISO yyyy-MM-dd
  DueDate: string;
  CurrencyCode: string;
  Total: number;
  AmountDue: number;
  AmountPaid: number;
  Contact: { ContactID: string; Name: string };
  Reference: string | null;
  UpdatedDateUTC: string; // /Date(<ms>+0000)/
}

export interface XeroInvoicesResponse {
  Id: string;
  Status: string;
  Invoices: XeroInvoice[];
}

export interface XeroPayment {
  PaymentID: string;
  Invoice: { InvoiceID: string; InvoiceNumber?: string };
  Account: { AccountID: string; Code?: string };
  Date: string;
  Amount: number;
  Reference: string | null;
  CurrencyRate: number;
  PaymentType: "ACCRECPAYMENT" | "ACCPAYPAYMENT";
  Status: "AUTHORISED" | "DELETED";
  UpdatedDateUTC: string;
}

export interface XeroPaymentsResponse {
  Id: string;
  Status: string;
  Payments: XeroPayment[];
}

export interface XeroPaymentWriteRequest {
  Invoice: { InvoiceID: string };
  Account: { Code: string };
  Date: string;
  Amount: number;
  Reference?: string;
}

export interface XeroClientOptions {
  config: XeroOAuthConfig;
  /** Override fetch (testing). */
  fetchFn?: typeof fetch;
  /** Override now() (testing). */
  now?: () => number;
}
