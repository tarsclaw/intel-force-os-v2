// WorkOS API types — subset of the v1.0 surface IFOS admin/onboarding flows
// consume. Reference: https://workos.com/docs (organizations, connections,
// directory sync). Shapes are intentionally narrower than the full WorkOS
// schema — only fields the v1.0 admin/tenant-onboarding paths actually read.
//
// WorkOS AuthKit per docs/build-brief/00-MASTER-BRIEF.md §5.3 line 401 is the
// v1.0 IFOS auth substrate; this package is the READ surface over org/
// connection/directory-sync resources that the admin UI + tenant provisioning
// dance need. SCIM-write provisioning + audit-log streaming are v1.1+ scope.

/**
 * WorkOS uses a SINGLE long-lived secret key as the API credential — distinct
 * from Bullhorn's two-step OAuth + REST-login dance. Per WorkOS docs the
 * secret key (sk_…) is presented via Bearer auth on every request; there is
 * NO refresh dance and NO per-tenant token rotation at the API layer.
 *
 * (Per-tenant identity context — which org an admin is acting on — is encoded
 * via the organization_id query/path parameter, not via a token swap. This is
 * a deliberate WorkOS design choice and matches the IFOS multi-tenant model
 * where one platform-level secret services many tenant orgs.)
 *
 * Net: WorkosConfig is much smaller than BullhornOAuthConfig — no token_file_path,
 * no refresh_token, no expiry. The key rotates only when the founder rotates
 * it manually in the WorkOS dashboard, in which case the IFOS deployment
 * env-var changes and the process restarts.
 */
export interface WorkosConfig {
  /** WorkOS secret key (e.g. "sk_test_…" or "sk_live_…"). Lives in env;
   *  NEVER serialised, NEVER logged. */
  secret_key: string;
  /** Optional API base URL override; defaults to https://api.workos.com.
   *  Test envs may point at a fixture server. */
  base_url?: string;
}

// ─────────────────────────────────────────────────────────────────────────
// Organisation resource (the WorkOS "tenant container")
// ─────────────────────────────────────────────────────────────────────────

export interface WorkosOrganization {
  id: string; // "org_…"
  name: string;
  /** Allowed domains for SSO/login (e.g. ["acme-tech.co.uk"]). */
  domains: WorkosDomain[];
  /** Whether domain-match login auto-creates accounts. */
  allow_profiles_outside_organization?: boolean;
  created_at: string; // ISO-8601
  updated_at: string;
}

export interface WorkosDomain {
  id: string;
  domain: string;
  /** "verified" | "pending" — only verified domains accept SSO logins. */
  state?: string;
}

// ─────────────────────────────────────────────────────────────────────────
// Connection resource (a configured SSO/identity-provider link per org)
// ─────────────────────────────────────────────────────────────────────────

export interface WorkosConnection {
  id: string; // "conn_…"
  organization_id: string;
  /** Identity provider type — "OktaSAML" | "GoogleOAuth" | "AzureSAML" |
   *  "GenericOIDC" | "MicrosoftOAuth" | "AdfsSAML" | … (full enum on
   *  WorkOS docs; v1.0 IFOS supports any). */
  connection_type: string;
  name: string;
  /** "active" | "draft" | "inactive". Only "active" connections accept logins. */
  state: string;
  /** Login domain (e.g. "acme-tech.co.uk"); paired with organization for routing. */
  domains: WorkosDomain[];
  created_at: string;
  updated_at: string;
}

// ─────────────────────────────────────────────────────────────────────────
// Directory Sync resources (SCIM-backed user + group mirror per org)
// ─────────────────────────────────────────────────────────────────────────

export interface WorkosDirectory {
  id: string; // "directory_…"
  organization_id: string;
  /** "okta scim v2.0" | "azure scim v2.0" | … */
  type: string;
  name: string;
  /** "linked" | "unlinked" — only linked directories produce user data. */
  state: string;
  domain?: string;
  created_at: string;
  updated_at: string;
}

export interface WorkosDirectoryUser {
  id: string; // "directory_user_…"
  directory_id: string;
  organization_id: string;
  /** SCIM-canonical externalId (often the IdP-side user identifier). */
  idp_id: string;
  username: string | null;
  emails: { primary: boolean; type?: string; value: string }[];
  first_name: string | null;
  last_name: string | null;
  /** "active" | "suspended" | "inactive". */
  state: string;
  /** Group membership IDs (resolved separately via listDirectoryGroups). */
  groups?: WorkosDirectoryGroup[];
  created_at: string;
  updated_at: string;
}

export interface WorkosDirectoryGroup {
  id: string; // "directory_group_…"
  directory_id: string;
  organization_id: string;
  idp_id: string;
  name: string;
  created_at: string;
  updated_at: string;
}

// ─────────────────────────────────────────────────────────────────────────
// Generic list response shape (WorkOS list endpoints share this envelope)
// ─────────────────────────────────────────────────────────────────────────

export interface WorkosListResponse<T> {
  object: "list";
  data: T[];
  list_metadata: {
    before: string | null;
    after: string | null;
  };
}

export interface WorkosClientOptions {
  config: WorkosConfig;
  /** Override fetch (testing). */
  fetchFn?: typeof fetch;
  /** Override now() (testing). */
  now?: () => number;
}
