// @ifos/cv-library — public API
//
// Bus-routed capabilities (set-equal with sourcing-scout/tools.yaml
// cvlibrary_*) + internal helpers per review-mcp-connector §1.
//
// Reference implementation: @ifos/reed (Day-34 Phase 8 sibling commit) —
// same long-lived-key shape; same per-account_id rate-limit pattern.
// CV-Library auth model is PLACEHOLDER (Basic OR Bearer dual-support per
// CVLibraryConfig.auth_mode) pending W6-live verification at commercial
// signup (CV-Library recruiter docs accessible post-signup only;
// 2026-06-03 WebFetch attempt returned 403).

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with sourcing-scout/tools.yaml)
// ─────────────────────────────────────────────────────────────────────────

export { searchCandidates, getCandidate } from "./candidates.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

export { CVLibraryClient, DEFAULT_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
export { CVLibraryCache } from "./cache.js";
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
export {
  CVLibraryError,
  CVLibraryAuthError,
  CVLibraryRateLimitError,
  CVLibraryNotFoundError,
  CVLibraryValidationError,
} from "./errors.js";
export type {
  CVLibraryConfig,
  CVLibraryAuthMode,
  CVLibraryCandidate,
  CVLibraryCandidateSearchOptions,
  CVLibraryListResponse,
  CVLibraryClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";
