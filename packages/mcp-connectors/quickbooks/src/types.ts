// QuickBooks Online API types — subset of the v3 Accounting API surface
// IFOS Cash Conductor consumes.
// Reference: https://developer.intuit.com/app/developer/qbo/docs/api/accounting/most-commonly-used/invoice
//
// QuickBooks is per-realm: each connected company has a unique realmId, and
// the token bundle + base URL are realm-scoped. This is the key structural
// difference from Xero (which uses one tenant_id header per call).

export interface QbTokens {
  access_token: string;
  refresh_token: string;
  /** Unix epoch milliseconds when the access_token expires (typically ~1h after issue). */
  expires_at_ms: number;
  /** Refresh token expiry (QB rolls refresh tokens; ~100 days from issue). */
  refresh_token_expires_at_ms: number;
  /** Comma-separated scopes granted. */
  scope: string;
  /** Always 'Bearer' in v3. */
  token_type: string;
}

export interface QbOAuthConfig {
  client_id: string;
  client_secret: string;
  /** QuickBooks "realmId" (per-company identifier; unique per connected QB Online company). */
  realm_id: string;
  /** Production vs sandbox base URL switch. */
  environment: "production" | "sandbox";
  /** Token file on disk; atomic-rename writes go here. */
  token_file_path: string;
}

export interface QbInvoice {
  Id: string;
  DocNumber: string | null;
  TxnDate: string; // yyyy-MM-dd
  DueDate: string;
  CurrencyRef: { value: string; name?: string };
  TotalAmt: number;
  Balance: number;
  CustomerRef: { value: string; name?: string };
  CustomerMemo: { value: string } | null;
  /** Document line items omitted at v0; Cash Conductor doesn't need them. */
  MetaData: {
    CreateTime: string;
    LastUpdatedTime: string;
  };
}

export interface QbQueryResponse<TEntity extends string, TBody> {
  QueryResponse: { [K in TEntity]?: TBody[] } & {
    startPosition?: number;
    maxResults?: number;
    totalCount?: number;
  };
  time: string;
}

export interface QbPayment {
  Id: string;
  TxnDate: string;
  TotalAmt: number;
  CustomerRef: { value: string; name?: string };
  PaymentRefNum: string | null;
  /** Lines map each payment to one or more invoices (Cash Conductor uses single-invoice payments). */
  Line: Array<{
    Amount: number;
    LinkedTxn: Array<{ TxnId: string; TxnType: "Invoice" }>;
  }>;
  MetaData: {
    CreateTime: string;
    LastUpdatedTime: string;
  };
}

export interface QbPaymentWriteRequest {
  /** Single-invoice payment shape. Cash Conductor doesn't write multi-invoice payments at v0. */
  CustomerRef: { value: string };
  TotalAmt: number;
  TxnDate?: string;
  PaymentRefNum?: string;
  Line: Array<{
    Amount: number;
    LinkedTxn: Array<{ TxnId: string; TxnType: "Invoice" }>;
  }>;
}

export interface QbClientOptions {
  config: QbOAuthConfig;
  /** Override fetch (testing). */
  fetchFn?: typeof fetch;
  /** Override now() (testing). */
  now?: () => number;
}
