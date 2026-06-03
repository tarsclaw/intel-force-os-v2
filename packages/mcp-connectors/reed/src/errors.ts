// Reed error hierarchy. Errors NEVER include api_key values; only key NAMES,
// status codes, and safe metadata. Per review-mcp-connector §5 (zero secret
// interpolation in error messages).
//
// Pattern: ES2022 Error(message, {cause}) constructor option per the
// autosend-bridge-telegram pattern landed 2026-06-01 commit 9b282d8.

export class ReedError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
    cause?: unknown,
  ) {
    super(message, cause !== undefined ? { cause } : undefined);
    this.name = "ReedError";
  }
}

/**
 * 401 — API key invalid or revoked in Reed developer portal. No retry path
 * (Reed uses long-lived API key with no refresh dance; rotation is manual
 * via portal + env-var update + process restart). Surface immediately as
 * blocking for the consumer.
 *
 * Maps to ESC_REED_AUTH (blocking per catalogue §2.7; operator +
 * ifos_oncall_chat_id routing).
 */
export class ReedAuthError extends ReedError {
  constructor(message: string, status?: number, cause?: unknown) {
    super(message, status, false, cause);
    this.name = "ReedAuthError";
  }
}

/**
 * 429 — rate-limit exhausted. Reed does NOT publish exact rate-limit
 * numbers in the Jobseeker API docs (Recruiter API may differ; v0.1.0
 * default is conservative at 60/min per account_id).
 *
 * Maps to ESC_RATE_LIMIT_HIT (warn; operator_chat_id; payload.upstream='reed').
 */
export class ReedRateLimitError extends ReedError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "ReedRateLimitError";
  }
}

/** Reed resource (candidate/job posting) not found at the given ID.
 *  Distinct from a generic 4xx error. */
export class ReedNotFoundError extends ReedError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "ReedNotFoundError";
  }
}

/**
 * Reed rejected a request shape (400). Typically schema mismatch on a
 * post-job payload OR invalid search filter combination.
 *
 * Maps to ESC_REED_VALIDATION_FAIL (warn; operator_chat_id; QUEUED for
 * catalogue registration at W6 build start alongside the package's live
 * wiring).
 */
export class ReedValidationError extends ReedError {
  constructor(
    message: string,
    public readonly providerErrors: string[] = [],
  ) {
    super(message, 400, false);
    this.name = "ReedValidationError";
  }
}
