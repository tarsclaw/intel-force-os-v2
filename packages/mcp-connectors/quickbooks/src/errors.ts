// QuickBooks error hierarchy. Errors NEVER include credential values; only key
// names + status codes + safe metadata. Per review-mcp-connector §5
// (zero secret interpolation in error messages).

export class QbError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
  ) {
    super(message);
    this.name = "QbError";
  }
}

/** OAuth refresh failed: client_id/secret rejected, refresh_token invalid, or token-file write/read failed. */
export class QbAuthError extends QbError {
  constructor(message: string, status?: number) {
    super(message, status, false);
    this.name = "QbAuthError";
  }
}

/** Rate-limit budget exhausted (500/min per realmId per Intuit docs). */
export class QbRateLimitError extends QbError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "QbRateLimitError";
  }
}

/** Invoice/payment/customer not found. */
export class QbNotFoundError extends QbError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "QbNotFoundError";
  }
}

/** QuickBooks rejected the write payload (400 + Fault.type=ValidationFault). */
export class QbValidationError extends QbError {
  constructor(
    message: string,
    public readonly providerErrors: string[] = [],
  ) {
    super(message, 400, false);
    this.name = "QbValidationError";
  }
}
