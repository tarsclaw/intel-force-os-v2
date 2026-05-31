// Xero error hierarchy. Errors NEVER include credential values; only key
// names + status codes + safe metadata. Per review-mcp-connector §5
// (zero secret interpolation in error messages).

export class XeroError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
  ) {
    super(message);
    this.name = "XeroError";
  }
}

/** OAuth refresh failed: client_id/secret rejected, refresh_token invalid, or token-file write/read failed. */
export class XeroAuthError extends XeroError {
  constructor(message: string, status?: number) {
    super(message, status, false);
    this.name = "XeroAuthError";
  }
}

/** Rate-limit budget exhausted (60/min per app per tenant; 5000/day per tenant). */
export class XeroRateLimitError extends XeroError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "XeroRateLimitError";
  }
}

/** Invoice/payment/contact not found. */
export class XeroNotFoundError extends XeroError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "XeroNotFoundError";
  }
}

/** Xero rejected the write payload (400). Typically schema or business-rule failures. */
export class XeroValidationError extends XeroError {
  constructor(
    message: string,
    public readonly providerErrors: string[] = [],
  ) {
    super(message, 400, false);
    this.name = "XeroValidationError";
  }
}
