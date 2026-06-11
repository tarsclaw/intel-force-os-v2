// @ifos/bullhorn — public API
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability ID
//       on agents/recruitment/{janitor,scribe,concierge}/tools.yaml AND (for
//       state-changing capabilities) has an action_type entry in
//       agents/_shared/autosend-policy.yaml.
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but NOT
//       declared as bus capabilities (no action_type; no authz check). Adding
//       a new one here does NOT require a tools.yaml edit; promoting one to a
//       capability does.
//
// Reference implementation: @ifos/xero (Day-25 RATIFIED scaffold). Bullhorn
// adds the two-step OAuth (Step A: refresh access_token at
// auth-{region}.bullhornstaffing.com; Step B: REST login at
// rest.bullhornstaffing.com/rest-services/login → BhRestToken + per-corp
// restUrl). Per docs/decisions/bullhorn-integration-path.md Sub-decision A
// RESOLVED 2026-06-02: v1.0 path is direct API per-tenant OAuth; marketplace
// deferred to v1.1+.

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with {janitor,scribe,concierge}/tools.yaml §bullhorn)
// ─────────────────────────────────────────────────────────────────────────

// bullhorn_oauth (action_type: bullhorn_oauth, green tier per autosend-policy.yaml
// QUEUED status — will be REGISTERED when Janitor tools.yaml lands in W5 Phase 5)
export { refreshTokens } from "./auth.js";
// bullhorn_get_candidate (read-only) + bullhorn_list_candidates (read-only)
// bullhorn_update_candidate (action_type: bullhorn_candidate_dedupe yellow tier
// OR bullhorn_field_backfill yellow tier per Janitor agent.md §3; the consumer
// cycle.sh decides which action_type emit by mutation type)
export { getCandidate, listCandidates, updateCandidate } from "./candidates.js";
// bullhorn_get_placement (read-only) + bullhorn_list_placements (read-only)
export { getPlacement, listPlacements } from "./placements.js";
// bullhorn_get_client (read-only) + bullhorn_list_clients (read-only)
// bullhorn_update_client (action_type: bullhorn_field_backfill yellow tier per
// Janitor agent.md §3 Output 2.2 — Step 9 client field-backfill writes)
export { getClient, listClients, updateClient } from "./clients.js";
// bullhorn_get_contact (read-only) + bullhorn_list_contacts (read-only)
export { getContact, listContacts } from "./contacts.js";
// bullhorn_create_note (action_type: bullhorn_activity_log_write green tier per
// autosend-policy.yaml — REGISTERED 2026-06-02 per Concierge cluster Fbis-R1
// closure) + bullhorn_create_activity_log_entry (convenience wrapper)
export { createNote, createActivityLogEntry, getNote } from "./notes.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once by cycle.sh Step 1 per consumer agent;
// per-corporation_id; not a capability in the bus sense (no action_type;
// no authz check) — it carries the capabilities above through the
// rate-limit + retry + two-step OAuth attach path.
export { BullhornClient, DEFAULT_TIMEOUT_MS } from "./client.js";
// Token-file I/O + pure predicates
export { loadTokens, saveTokens, shouldRefresh, BULLHORN_REST_LOGIN_URL } from "./auth.js";
// Disk cache (5-15min TTL per entity-type churn)
export { BullhornCache } from "./cache.js";
// Rate-limit introspection — soft signal exposed via rateCheck() (read-only;
// see README §"Rate limits" — consumer is responsible for honouring shouldBackoff
// at the soft threshold; the hard 100% gate is enforced inside rateConsume()).
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
// Test/diagnostic
export { _resetInflightForTest } from "./auth.js";
// Error hierarchy
export {
  BullhornError,
  BullhornAuthError,
  BullhornRateLimitError,
  BullhornNotFoundError,
  BullhornValidationError,
} from "./errors.js";
export type {
  BullhornRegion,
  BullhornTokens,
  BullhornOAuthConfig,
  BullhornCandidate,
  BullhornPlacement,
  BullhornClient as BullhornClientCorp,
  BullhornContact,
  BullhornNote,
  BullhornNoteWriteRequest,
  BullhornListResponse,
  BullhornClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";
