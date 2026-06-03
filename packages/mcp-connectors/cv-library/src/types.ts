// CV-Library types — candidate-search surface IFOS Sourcing Scout (W9)
// consumes. v0.1.0 scaffolds against an INFERRED auth + endpoint shape;
// live verification deferred to founder's CV-Library commercial signup
// per docs/operations/founder-api-signups-2026-06-03.md P3 (cv-library.co.uk
// recruiter page returned 403 to anonymous WebFetch 2026-06-03 attempt;
// live docs accessible only post-signup).
//
// v0.1.0 ASSUMES HTTP Basic auth as the UK-job-board norm (mirrors Reed's
// verified pattern). The auth_mode field below lets the consumer override
// if CV-Library uses Bearer tokens, OAuth, OR custom session cookies once
// verified at commercial signup.

/**
 * v0.1.0 supports two auth modes — Basic (mirror Reed) and Bearer (mirror
 * WorkOS). One of api_key (Basic) OR access_token (Bearer) must be set.
 * Live verification at commercial signup determines which is actually used
 * by CV-Library Recruiter API.
 */
export type CVLibraryAuthMode = "basic" | "bearer";

export interface CVLibraryConfig {
  /** Per-tenant CV-Library account identifier; used for rate-limit
   *  bucketing + audit context. */
  account_id: string;
  /** Auth mode — Basic OR Bearer; verified at commercial signup. */
  auth_mode: CVLibraryAuthMode;
  /** API key for Basic auth mode (used as username with empty password,
   *  same pattern as Reed). Required when auth_mode='basic'. */
  api_key?: string;
  /** Bearer token for Bearer auth mode. Required when auth_mode='bearer'. */
  access_token?: string;
  /** Optional API base URL override; defaults to https://api.cv-library.co.uk
   *  (TODO(W6-live): verify exact base URL at commercial signup —
   *  could be api.cv-library.co.uk OR cv-library.co.uk/api OR similar). */
  base_url?: string;
}

// ─────────────────────────────────────────────────────────────────────────
// Candidate resource (Recruiter API candidate-search surface)
// ─────────────────────────────────────────────────────────────────────────

export interface CVLibraryCandidate {
  /** CV-Library-internal candidate identifier (opaque). */
  candidate_id: string;
  full_name: string | null;
  email: string | null;
  phone: string | null;
  /** ISO city or region. */
  location: string | null;
  current_title: string | null;
  years_experience: number | null;
  /** Desired salary (single value; CV-Library exposes single rather than band). */
  salary_expectation: number | null;
  /** Stable URL of the candidate's CV download (TODO(W6-live): verify auth
   *  required for this URL). */
  cv_url: string | null;
  /** ISO-8601 timestamp; CV-Library-side last activity. */
  last_active: string | null;
}

// ─────────────────────────────────────────────────────────────────────────
// Search request shape
// ─────────────────────────────────────────────────────────────────────────

export interface CVLibraryCandidateSearchOptions {
  /** Free-text keywords matched against CV. */
  keywords?: string;
  /** Location filter (UK city or region). */
  location?: string;
  /** Minimum salary expectation. */
  salary_min?: number;
  /** Maximum salary expectation. */
  salary_max?: number;
  /** Pagination: how many results per page. */
  limit?: number;
  /** Pagination: starting offset (CV-Library uses offset-based vs Reed's
   *  results_to_skip — verify at W6-live). */
  offset?: number;
}

// ─────────────────────────────────────────────────────────────────────────
// Generic list response shape
// ─────────────────────────────────────────────────────────────────────────

export interface CVLibraryListResponse<T> {
  total: number;
  results: T[];
}

export interface CVLibraryClientOptions {
  config: CVLibraryConfig;
  /** Override fetch (testing). */
  fetchFn?: typeof fetch;
  /** Override now() (testing). */
  now?: () => number;
}
