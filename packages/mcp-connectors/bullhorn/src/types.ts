// Bullhorn REST API types — subset of the v2 surface IFOS Janitor + Scribe +
// Concierge agents consume. Reference: https://bullhorn.github.io/docs +
// https://bullhorn.github.io/rest-api-docs/ + community knowledge on the
// two-step OAuth + REST-login flow.
//
// Shapes are intentionally narrower than Bullhorn's full schema — only fields
// the three v1.0 agents actually read/write per their respective agent.md §3
// output contracts + agent.md §4 workflow steps.

export type BullhornRegion = "west" | "east" | "uk";

/**
 * Bullhorn's auth model is TWO-STEP per docs/decisions/bullhorn-integration-path.md
 * §4.5 + verified 2026-06-02 against community sources:
 *
 *   Step A: OAuth 2.0 standard auth-code → access_token at
 *           https://auth-{region}.bullhornstaffing.com/oauth/token
 *           (or https://auth.bullhornstaffing.com/oauth/token without region
 *           prefix; per-region URLs are typically more reliable. v1.0 default:
 *           explicit region per config to avoid latent regional confusion).
 *
 *   Step B: REST login: GET https://rest.bullhornstaffing.com/rest-services/
 *           login?version=2.0&access_token={oauth_access_token} → returns
 *           { BhRestToken, restUrl } where restUrl is corp-specific
 *           (e.g. https://rest9.bullhornstaffing.com/rest-services/{corpToken}/).
 *
 *   Step C: All subsequent REST calls use BhRestToken as a query parameter
 *           OR header on the per-corp restUrl. BhRestToken TTL is short
 *           (typically ~10 minutes per Bullhorn forums); refresh by re-doing
 *           Step B with the OAuth access_token (if fresh) OR re-doing both
 *           Steps A + B if the OAuth access_token is also expired.
 *
 * Net: the token bundle persisted to disk has BOTH the OAuth token pair AND
 * the BhRestToken/restUrl bundle, with TWO expiry timestamps.
 */
export interface BullhornTokens {
  // OAuth 2.0 layer (Step A)
  oauth_access_token: string;
  oauth_refresh_token: string;
  /** Unix epoch milliseconds when the OAuth access_token expires (~10 min Bullhorn default). */
  oauth_expires_at_ms: number;
  /** Comma-separated scopes granted at consent time. */
  scope: string;
  token_type: string; // typically "Bearer"

  // REST session layer (Step B)
  bh_rest_token: string;
  /** Corp-specific REST URL returned by the /login call (e.g. https://rest9.bullhornstaffing.com/rest-services/<corpToken>/). */
  rest_url: string;
  /** Unix epoch milliseconds when the BhRestToken expires (~10 min Bullhorn default; mirrors OAuth TTL). */
  bh_rest_token_expires_at_ms: number;
}

export interface BullhornOAuthConfig {
  client_id: string;
  client_secret: string;
  /** Bullhorn corporation_id this token bundle is for. Per-corp isolation
   *  (different IFOS pilot tenants → different corporation_ids). */
  corporation_id: string;
  /**
   * Bullhorn data-centre region. Required because the OAuth + REST endpoints
   * are region-specific. v1.0 conservative default in fixtures: 'east' (US-East
   * is the most-deployed region; UK-region tenants override per onboarding).
   * If you genuinely don't know the region, leave it as 'east' and surface
   * the first OAuth failure for region resolution.
   */
  region: BullhornRegion;
  /** Token file on disk; atomic-rename writes go here. Recommend:
   *  ~/.ifos-local-vault/<tenant>/bullhorn-tokens-<corporation_id>.json (mode 0600). */
  token_file_path: string;
}

// ─────────────────────────────────────────────────────────────────────────
// Entity types (subset Janitor + Scribe + Concierge agents consume)
// ─────────────────────────────────────────────────────────────────────────

export interface BullhornCandidate {
  id: number;
  firstName: string | null;
  lastName: string | null;
  email: string | null;
  email2: string | null;
  email3: string | null;
  status: string | null; // "New Lead" | "Active" | "Placed" | "Inactive" | ...
  dateAdded: number; // epoch ms
  dateLastModified: number; // epoch ms
  owner?: { id: number; firstName?: string; lastName?: string };
  occupation?: string | null;
  customText1?: string | null;
}

export interface BullhornPlacement {
  id: number;
  candidate: { id: number };
  clientCorporation: { id: number };
  jobOrder: { id: number };
  status: string | null; // "Pending" | "Confirmed" | "Placed" | ...
  dateBegin: number | null;
  dateEnd: number | null;
  payRate: number | null;
  billRate: number | null;
  dateLastModified: number;
}

/** Bullhorn "ClientCorporation" — the corporate client (e.g. "Acme Tech Ltd"). */
export interface BullhornClient {
  id: number;
  name: string;
  status: string | null;
  industry?: string | null;
  numEmployees?: number | null;
  website?: string | null;
  dateLastModified: number;
}

/** Bullhorn "ClientContact" — a person at a client corporation. */
export interface BullhornContact {
  id: number;
  clientCorporation: { id: number; name?: string };
  firstName: string | null;
  lastName: string | null;
  email: string | null;
  status: string | null;
  dateLastModified: number;
}

/** Bullhorn Note entity — used for activity logs and consultant notes. */
export interface BullhornNote {
  id: number;
  action: string; // "Note" | "Call" | "Meeting" | "Email" | ...
  comments: string; // free-text body
  dateAdded: number;
  personReference?: { id: number; _subtype?: string };
  commentingPerson?: { id: number };
}

export interface BullhornNoteWriteRequest {
  action: string;
  comments: string;
  /** Candidate / ClientContact reference being noted-against. */
  personReference: { id: number };
}

// ─────────────────────────────────────────────────────────────────────────
// Generic list response shape (Bullhorn /search and /query endpoints)
// ─────────────────────────────────────────────────────────────────────────

export interface BullhornListResponse<T> {
  total: number;
  start: number;
  count: number;
  data: T[];
}

export interface BullhornClientOptions {
  config: BullhornOAuthConfig;
  /** Override fetch (testing). */
  fetchFn?: typeof fetch;
  /** Override now() (testing). */
  now?: () => number;
}
