// Reed.co.uk types — Recruiter API surface IFOS Sourcing Scout (W9) consumes.
// Reference: https://www.reed.co.uk/developers/jobseeker (verified 2026-06-03
// via WebFetch — Basic-auth-with-API-key-as-username pattern); Recruiter API
// inferred to use same auth + similar resource shape (job postings + candidate
// search + applications received per posting). Live verification deferred to
// founder's Reed Recruiter API commercial signup (per docs/operations/
// founder-api-signups-2026-06-03.md P2).

/**
 * Reed Recruiter API uses HTTP Basic authentication with the API key as the
 * username and an EMPTY password. Verified 2026-06-03 against
 * reed.co.uk/developers/jobseeker (Jobseeker API uses same scheme; Recruiter
 * API expected to mirror).
 *
 * Auth header format:
 *   Authorization: Basic base64(API_KEY:)
 *
 * NO OAuth refresh dance; no token rotation. Key is long-lived; rotates
 * only via founder action in the Reed developer portal.
 */
export interface ReedConfig {
  /** Reed-issued API key (long-lived; lives in env; NEVER logged or
   *  serialised to disk). */
  api_key: string;
  /** Per-tenant Reed account identifier; used for rate-limit bucketing
   *  + audit context. Resolution at runtime by Sourcing Scout context.sh
   *  via tenant_adapters.config (v0.5+ schema supplement — pending). */
  account_id: string;
  /** Optional API base URL override; defaults to https://www.reed.co.uk/api.
   *  Test envs may point at a fixture server. Reed's API is versioned
   *  via path segment (e.g. /api/1.0/...); the base URL stops before the
   *  version. */
  base_url?: string;
  /** API version (default "1.0"; verified from
   *  reed.co.uk/developers/jobseeker example URL). */
  api_version?: string;
}

// ─────────────────────────────────────────────────────────────────────────
// Candidate resource (Recruiter API candidate-search surface)
// ─────────────────────────────────────────────────────────────────────────

export interface ReedCandidate {
  /** Reed-internal candidate identifier (opaque). */
  candidate_id: string;
  full_name: string | null;
  email: string | null;
  phone: string | null;
  /** ISO city or region (e.g. "London", "Manchester"). */
  location: string | null;
  /** Current job title self-reported by the candidate. */
  current_title: string | null;
  /** Years of experience as integer (Reed self-reports band; v0.1.0 rounds
   *  to integer years). */
  years_experience: number | null;
  /** Desired salary band (Reed exposes min + max integers). */
  salary_expectation_min: number | null;
  salary_expectation_max: number | null;
  /** Stable URL of the candidate's CV download (TODO(W6-live): verify auth
   *  required for this URL — likely separate session-token download). */
  cv_url: string | null;
  /** ISO-8601 timestamp; Reed-side last activity (CV update / application). */
  last_active: string | null;
}

// ─────────────────────────────────────────────────────────────────────────
// Job posting resource (Recruiter API post-jobs surface)
// ─────────────────────────────────────────────────────────────────────────

export interface ReedJobPosting {
  job_id: string;
  title: string;
  description: string;
  /** ISO city or region. */
  location: string;
  /** Salary band (GBP). */
  salary_min: number | null;
  salary_max: number | null;
  /** "perm" | "contract" | "temp" — Reed contract-type enum (TODO(W6-live):
   *  verify exact enum values at commercial signup). */
  contract_type: string;
  /** Whether the posting is currently visible to jobseekers. */
  active: boolean;
  /** ISO-8601 creation timestamp. */
  created_at: string;
  /** Number of applications received against this posting. */
  application_count: number;
}

// ─────────────────────────────────────────────────────────────────────────
// Search request shape (candidate search)
// ─────────────────────────────────────────────────────────────────────────

export interface ReedCandidateSearchOptions {
  /** Free-text keywords matched against CV + job title. */
  keywords?: string;
  /** Location filter (Reed accepts UK city names + regional aliases). */
  location?: string;
  /** Salary band filter (returns candidates whose expectation overlaps
   *  this range). */
  salary_min?: number;
  salary_max?: number;
  /** Pagination: how many results per page (Reed max typically 100). */
  results_to_take?: number;
  /** Pagination: starting offset. */
  results_to_skip?: number;
}

// ─────────────────────────────────────────────────────────────────────────
// Generic list response shape (Reed search endpoints share this envelope)
// ─────────────────────────────────────────────────────────────────────────

export interface ReedListResponse<T> {
  /** Reed's term for total matching rows across pagination. */
  total_results: number;
  /** Page size used. */
  results: T[];
}

export interface ReedClientOptions {
  config: ReedConfig;
  /** Override fetch (testing). */
  fetchFn?: typeof fetch;
  /** Override now() (testing). */
  now?: () => number;
}
