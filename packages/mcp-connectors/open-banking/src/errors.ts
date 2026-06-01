// Open Banking error hierarchy. Errors NEVER include credential values; only
// key names + status codes + safe metadata. Per review-mcp-connector §5.

export class OpenBankingError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
  ) {
    super(message);
    this.name = "OpenBankingError";
  }
}

/** OAuth refresh failed: client_id/secret rejected, refresh_token invalid, OR consent expired (must re-do PSD2 dance). */
export class OpenBankingAuthError extends OpenBankingError {
  constructor(
    message: string,
    status?: number,
    public readonly reason: "credentials" | "consent_expired" | "refresh_token_revoked" | "unknown" = "unknown",
  ) {
    super(message, status, false);
    this.name = "OpenBankingAuthError";
  }
}

/** Rate-limit budget exhausted. */
export class OpenBankingRateLimitError extends OpenBankingError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "OpenBankingRateLimitError";
  }
}

/** Consent expired (PSD2 90-day) — special-case of auth failure with re-consent guidance. */
export class OpenBankingConsentExpiredError extends OpenBankingAuthError {
  constructor(message: string) {
    super(message, undefined, "consent_expired");
    this.name = "OpenBankingConsentExpiredError";
  }
}

/** Connection or transaction not found. */
export class OpenBankingNotFoundError extends OpenBankingError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "OpenBankingNotFoundError";
  }
}

/** Provider not implemented (e.g. Plaid UK during v1.0 — deferred to v1.1+). */
export class NotImplementedError extends OpenBankingError {
  constructor(message: string) {
    super(message, undefined, false);
    this.name = "NotImplementedError";
  }
}
