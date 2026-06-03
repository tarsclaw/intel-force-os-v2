// @ifos/reed — public API
//
// The exports below split into TWO groups per review-mcp-connector §1:
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability
//       on agents/recruitment/sourcing-scout/tools.yaml (the v0.1.0
//       capability declarations carry package_status:scaffold_pending_phase_8;
//       this commit fulfills that scaffold).
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but
//       NOT declared as bus capabilities (no action_type; no authz check).
//
// Reference implementation: @ifos/bullhorn (Day-28 scaffold) MINUS the
// two-step OAuth dance + @ifos/workos (Day-29 Phase 2) pattern for the
// long-lived-key auth model. Reed uses HTTP Basic with API key as username
// + empty password (verified 2026-06-03 via WebFetch
// reed.co.uk/developers/jobseeker — Jobseeker API uses same scheme;
// Recruiter API expected to mirror; live verification deferred to founder's
// Reed Recruiter API commercial signup per docs/operations/
// founder-api-signups-2026-06-03.md P2).

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with sourcing-scout/tools.yaml)
// ─────────────────────────────────────────────────────────────────────────

// Candidate capabilities (Sourcing Scout Step 5 source)
export { searchCandidates, getCandidate } from "./candidates.js";
// Job-posting capabilities (v1.0 read-only; v1.1+ adds POST/PUT)
export { listJobs, getJob } from "./jobs.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once per account_id by the consumer's
// context.sh; carries the capabilities above through the rate-limit +
// retry + Basic-auth attach path.
export {
  ReedClient,
  DEFAULT_BASE_URL,
  DEFAULT_API_VERSION,
  DEFAULT_TIMEOUT_MS,
} from "./client.js";
// Disk cache (1-hour default TTL; matches Reed's job-market churn rate)
export { ReedCache } from "./cache.js";
// Rate-limit introspection — soft signal exposed via rateCheck() (read-only;
// see README §"Rate limits" — consumer is responsible for honouring shouldBackoff
// at the soft threshold; the hard 100% gate is enforced inside rateConsume()).
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
// Error hierarchy
export {
  ReedError,
  ReedAuthError,
  ReedRateLimitError,
  ReedNotFoundError,
  ReedValidationError,
} from "./errors.js";
export type {
  ReedConfig,
  ReedCandidate,
  ReedJobPosting,
  ReedCandidateSearchOptions,
  ReedListResponse,
  ReedClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";
