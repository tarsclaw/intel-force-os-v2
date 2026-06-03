// CV-Library error hierarchy. Errors NEVER include api_key / access_token
// values; only key NAMES, status codes, and safe metadata. Per
// review-mcp-connector §5 (zero secret interpolation).
//
// Pattern: ES2022 Error(message, {cause}) constructor option per the
// autosend-bridge-telegram pattern landed 2026-06-01 commit 9b282d8.

export class CVLibraryError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
    cause?: unknown,
  ) {
    super(message, cause !== undefined ? { cause } : undefined);
    this.name = "CVLibraryError";
  }
}

/**
 * 401 — auth credential invalid/revoked. No retry path; rotation is manual
 * via CV-Library portal + env-var update + process restart.
 *
 * Maps to ESC_CVLIBRARY_AUTH (blocking per catalogue §2.7).
 */
export class CVLibraryAuthError extends CVLibraryError {
  constructor(message: string, status?: number, cause?: unknown) {
    super(message, status, false, cause);
    this.name = "CVLibraryAuthError";
  }
}

/**
 * 429 — rate-limit exhausted. CV-Library does not publish exact numbers
 * (verified via WebFetch 2026-06-03 — recruiter page 403'd; live docs
 * accessible post-signup only). v0.1.0 conservative default 60/min per
 * account_id.
 *
 * Maps to ESC_RATE_LIMIT_HIT (warn; payload.upstream='cv-library').
 */
export class CVLibraryRateLimitError extends CVLibraryError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "CVLibraryRateLimitError";
  }
}

/** CV-Library resource not found at the given ID. Distinct from generic 4xx. */
export class CVLibraryNotFoundError extends CVLibraryError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "CVLibraryNotFoundError";
  }
}

/**
 * CV-Library rejected a request shape (400).
 *
 * Maps to ESC_CVLIBRARY_VALIDATION_FAIL (warn; QUEUED for catalogue
 * registration at W6 build start).
 */
export class CVLibraryValidationError extends CVLibraryError {
  constructor(
    message: string,
    public readonly providerErrors: string[] = [],
  ) {
    super(message, 400, false);
    this.name = "CVLibraryValidationError";
  }
}
