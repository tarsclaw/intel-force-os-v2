// Granola error hierarchy. Errors NEVER include access_token / refresh_token
// values; only key NAMES, status codes, and safe metadata. Per
// review-mcp-connector §5 (zero secret interpolation in error messages).
//
// Pattern: ES2022 Error(message, {cause}) constructor option per the
// autosend-bridge-telegram pattern landed 2026-06-01 commit 9b282d8 —
// Error.cause is read-only on the prototype so it must go through the super
// constructor's options bag, not as a post-construction assignment.

import type { GranolaPlanTier } from "./types.js";

export class GranolaError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly retryable: boolean = false,
    cause?: unknown,
  ) {
    super(message, cause !== undefined ? { cause } : undefined);
    this.name = "GranolaError";
  }
}

/**
 * OAuth refresh failed: refresh_token rejected, client_id revoked, or the
 * Granola token endpoint returned non-200. Consumer should surface
 * ESC_GRANOLA_AUTH and degrade to "no new transcripts ingested" mode until
 * the founder re-runs the browser-based OAuth consent.
 *
 * Maps to ESC_GRANOLA_AUTH (blocking; operator + ifos_oncall_chat_id —
 * pending W6 escalation-codes.md addition).
 */
export class GranolaAuthError extends GranolaError {
  constructor(message: string, status?: number, cause?: unknown) {
    super(message, status, false, cause);
    this.name = "GranolaAuthError";
  }
}

/**
 * Rate-limit budget exhausted — either the IFOS local bucket pre-emptively
 * blocked the call OR the Granola MCP server surfaced an upstream 429.
 * Granola does NOT publish exact per-workspace limits; v1.0 default is
 * conservative at 60/min per workspace_id (1/sec sustained — meeting-cadence
 * polling is the dominant consumer pattern).
 *
 * Maps to ESC_RATE_LIMIT_HIT (warn; operator_chat_id; payload.upstream='granola').
 */
export class GranolaRateLimitError extends GranolaError {
  constructor(
    message: string,
    public readonly retryAfterSeconds: number | null = null,
  ) {
    super(message, 429, true);
    this.name = "GranolaRateLimitError";
  }
}

/** Granola resource (meeting/transcript/folder) not found at the given ID.
 *  Distinct from a generic 4xx error. */
export class GranolaNotFoundError extends GranolaError {
  constructor(message: string) {
    super(message, 404, false);
    this.name = "GranolaNotFoundError";
  }
}

/**
 * 403 — caller attempted a Paid-tier capability (list_meeting_folders or
 * get_meeting_transcript) on a Free-plan workspace. The IFOS wrapper
 * pre-guards via plan_tier metadata when available (cached
 * GranolaAccountInfo) AND surfaces the upstream 403 typed for consumer
 * branching when the cache is cold.
 *
 * Maps to ESC_GRANOLA_PLAN_TIER (warn; operator_chat_id — pending W6
 * escalation-codes.md addition). Consumer (Scribe) should degrade the
 * affected tenant to "notes-only ingest" mode and surface to the operator
 * that an upgrade to a Paid plan is required for transcript ingest.
 */
export class GranolaPlanTierInsufficientError extends GranolaError {
  constructor(
    message: string,
    public readonly required_tier: GranolaPlanTier,
    public readonly capability: string,
  ) {
    super(message, 403, false);
    this.name = "GranolaPlanTierInsufficientError";
  }
}
