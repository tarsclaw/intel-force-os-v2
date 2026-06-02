// Bullhorn error hierarchy. Errors NEVER include credential values; only key
// NAMES, status codes, and safe metadata. Per review-mcp-connector §5
// (zero secret interpolation in error messages).
//
// Pattern: ES2022 Error(message, {cause}) constructor option per the
// autosend-bridge-telegram pattern landed 2026-06-01 commit 9b282d8 —
// Error.cause is read-only on the prototype so it must go through the super
// constructor's options bag, not as a post-construction assignment.

export class BullhornError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
    cause?: unknown,
  ) {
    super(message, cause !== undefined ? { cause } : undefined);
    this.name = "BullhornError";
  }
}

/**
 * OAuth refresh (Step A) OR REST login (Step B) failed: client_id/secret
 * rejected, refresh_token invalid/revoked in Bullhorn admin, or the REST
 * login call returned non-200. Distinct from BullhornRateLimitError (429)
 * and BullhornValidationError (400 on a write).
 *
 * Maps to ESC_BULLHORN_AUTH (blocking; operator + ifos_oncall_chat_id per
 * agents/_shared/escalation-codes.md). Consumer cycle.sh should emit on
 * this error type → agent enters degraded mode (drafts-only, no auto-send)
 * until the founder re-runs the OAuth consent dance.
 */
export class BullhornAuthError extends BullhornError {
  constructor(message: string, status?: number, cause?: unknown) {
    super(message, status, false, cause);
    this.name = "BullhornAuthError";
  }
}

/**
 * Rate-limit budget exhausted — either local bucket pre-emptive (we refused
 * to call to avoid hammering Bullhorn) OR Bullhorn returned 429 directly.
 * Bullhorn does not publish exact per-corporation limits (the docs reference
 * a "Fair Use Policy" without numbers); v1.0 default is conservative at
 * 10/sec per corporation_id (community-cited; see README §Rate limits).
 *
 * Maps to ESC_RATE_LIMIT_HIT (warn; operator_chat_id; payload.upstream='bullhorn')
 * per agents/_shared/escalation-codes.md.
 */
export class BullhornRateLimitError extends BullhornError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "BullhornRateLimitError";
  }
}

/** Bullhorn entity (candidate/placement/client/contact/note) not found at the
 *  given ID. Distinct from a generic 4xx error. */
export class BullhornNotFoundError extends BullhornError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "BullhornNotFoundError";
  }
}

/**
 * Bullhorn rejected a write payload (400). Typically schema mismatch,
 * required-field-missing, or business-rule violation (e.g. attempting to
 * place a candidate against a non-existent jobOrder).
 *
 * Maps to ESC_BULLHORN_WRITE_FAIL (warn; operator_chat_id) per
 * agents/_shared/escalation-codes.md. The catalogue explicitly scopes
 * ESC_BULLHORN_WRITE_FAIL to POST/PUT/PATCH; GET 5xx failures surface as
 * the base BullhornError without a dedicated ESC code (see README §Retry).
 */
export class BullhornValidationError extends BullhornError {
  constructor(
    message: string,
    public readonly providerErrors: string[] = [],
  ) {
    super(message, 400, false);
    this.name = "BullhornValidationError";
  }
}
