// Reed Recruiter API job-posting capability. Used by tenant onboarding +
// Concierge job-posting flow at v1.1+ (Sourcing Scout v1.0 is read-only on
// Reed). Declared at v0.1.0 for capability-surface set-equality with the
// README + tools.yaml capability declarations.
//
// Reed Recruiter API endpoint shape is INFERRED from public Recruiter
// product pages. Path placeholders carry TODO(W6-live) markers for
// verification at commercial signup; the auth model (HTTP Basic with API
// key as username) is confirmed.

import { ReedClient } from "./client.js";
import type {
  ReedJobPosting,
  ReedListResponse,
} from "./types.js";

interface ListJobsOptions {
  /** Pagination: how many results per page. */
  results_to_take?: number;
  /** Pagination: starting offset. */
  results_to_skip?: number;
  /** Filter to only active job postings. */
  active_only?: boolean;
}

/**
 * List job postings for the authenticated recruiter account. v1.0 read-only
 * usage; v1.1+ adds POST/PUT for posting + updating jobs.
 * TODO(W6-live): verify exact endpoint path against Reed Recruiter API docs.
 */
export async function listJobs(
  client: ReedClient,
  options: ListJobsOptions = {},
): Promise<ReedListResponse<ReedJobPosting>> {
  const query: Record<string, string> = {};
  if (options.results_to_take !== undefined) query.resultsToTake = String(options.results_to_take);
  if (options.results_to_skip !== undefined) query.resultsToSkip = String(options.results_to_skip);
  if (options.active_only) query.activeOnly = "true";

  // TODO(W6-live): verify path against Reed Recruiter API docs.
  return client.request<ReedListResponse<ReedJobPosting>>(`/jobs`, { query });
}

/**
 * Fetch a single job posting by Reed-internal job_id. Returns null on 404.
 * TODO(W6-live): verify path against Reed Recruiter API docs.
 */
export async function getJob(
  client: ReedClient,
  job_id: string,
): Promise<ReedJobPosting | null> {
  try {
    return await client.request<ReedJobPosting>(`/jobs/${job_id}`);
  } catch (e: unknown) {
    if ((e as { status?: number })?.status === 404) return null;
    throw e;
  }
}
