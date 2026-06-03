// WorkOS error hierarchy. Errors NEVER include secret_key values; only key
// NAMES, status codes, and safe metadata. Per review-mcp-connector §5
// (zero secret interpolation in error messages).
//
// Pattern: ES2022 Error(message, {cause}) constructor option per the
// autosend-bridge-telegram pattern landed 2026-06-01 commit 9b282d8 —
// Error.cause is read-only on the prototype so it must go through the super
// constructor's options bag, not as a post-construction assignment.

export class WorkosError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
    cause?: unknown,
  ) {
    super(message, cause !== undefined ? { cause } : undefined);
    this.name = "WorkosError";
  }
}

/**
 * 401 — secret key invalid, rotated, or revoked in WorkOS dashboard. Unlike
 * Bullhorn there is NO refresh dance; the env-var must be updated and the
 * process restarted.
 *
 * Maps to ESC_WORKOS_AUTH (blocking; operator + ifos_oncall_chat_id per
 * agents/_shared/escalation-codes.md — pending W5 Phase 4 addition).
 */
export class WorkosAuthError extends WorkosError {
  constructor(message: string, status?: number, cause?: unknown) {
    super(message, status, false, cause);
    this.name = "WorkosAuthError";
  }
}

/**
 * 429 — rate-limit exhausted. WorkOS publishes ~100 RPS per account
 * (verified via support docs); v1.0 default budget is conservative at
 * 6000/min per org_id (10/sec sustained; matches the per-tenant slice
 * of the platform-wide 100 RPS ceiling).
 *
 * Maps to ESC_RATE_LIMIT_HIT (warn; operator_chat_id; payload.upstream='workos')
 * per agents/_shared/escalation-codes.md.
 */
export class WorkosRateLimitError extends WorkosError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "WorkosRateLimitError";
  }
}

/** WorkOS resource (org/connection/directory/user/group) not found at the
 *  given ID. Distinct from a generic 4xx error. */
export class WorkosNotFoundError extends WorkosError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "WorkosNotFoundError";
  }
}

/**
 * WorkOS rejected a request shape (422 typically — WorkOS uses 422 for
 * validation errors rather than 400). v1.0 IFOS surface is read-only so
 * this should rarely fire; reserved for v1.1+ writes (SCIM provisioning,
 * org creation).
 *
 * Maps to ESC_WORKOS_VALIDATION_FAIL (warn; operator_chat_id) per
 * agents/_shared/escalation-codes.md — pending W5 Phase 4 addition.
 */
export class WorkosValidationError extends WorkosError {
  constructor(
    message: string,
    public readonly providerErrors: string[] = [],
  ) {
    super(message, 422, false);
    this.name = "WorkosValidationError";
  }
}
