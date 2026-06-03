// @ifos/workos — public API
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a future tools.yaml capability
//       on a v1.1+ admin/onboarding agent (v1.0 has no agent consumer; WorkOS is
//       the tenant-auth substrate the admin UI calls directly per master brief
//       §5.3 line 401). When a v1.1+ agent attaches, these will get action_type
//       entries in agents/_shared/autosend-policy.yaml.
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
//       declared as bus capabilities (no action_type; no authz check).
//
// Reference implementation: @ifos/bullhorn (Day-28 scaffold) — same shape MINUS
// auth.ts. WorkOS uses a long-lived secret key with NO refresh dance, so no
// auth.ts module exists. The secret_key rotates only via manual founder action
// (WorkOS dashboard → env-var → process restart); a 401 surfaces immediately as
// WorkosAuthError without retry.

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with future workos consumer tools.yaml)
// ─────────────────────────────────────────────────────────────────────────

// Organisation capabilities (read-only; v1.0 admin/onboarding surface)
export { getOrganization, listOrganizations } from "./organizations.js";
// Connection capabilities (read-only; v1.0 SSO link inspection)
export { getConnection, listConnections } from "./connections.js";
// Directory Sync capabilities (read-only; v1.0 SCIM user/group mirror inspection)
export {
  getDirectory,
  getDirectoryGroup,
  getDirectoryUser,
  listDirectories,
  listDirectoryGroups,
  listDirectoryUsers,
} from "./directory_sync.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once by the consumer per process; per-org_id
// rate-limit bucketing is applied at call time via the org_id field on
// RequestOptions (resolved automatically by capability helpers).
export { WorkosClient, DEFAULT_BASE_URL, DEFAULT_TIMEOUT_MS } from "./client.js";
// Disk cache (10-min TTL per slow-changing org/connection/directory metadata)
export { WorkosCache } from "./cache.js";
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
  WorkosError,
  WorkosAuthError,
  WorkosRateLimitError,
  WorkosNotFoundError,
  WorkosValidationError,
} from "./errors.js";
export type {
  WorkosConfig,
  WorkosOrganization,
  WorkosDomain,
  WorkosConnection,
  WorkosDirectory,
  WorkosDirectoryUser,
  WorkosDirectoryGroup,
  WorkosListResponse,
  WorkosClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";
