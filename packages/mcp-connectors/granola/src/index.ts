// @ifos/granola — public API
//
// The exports below split into TWO groups per review-mcp-connector §1 +
// README §"Capabilities":
//   (1) BUS-ROUTED CAPABILITIES — each maps 1:1 to a tools.yaml capability
//       ID on agents/recruitment/scribe/tools.yaml (lands W6 bundle scaffold).
//       Set-equal with the 6 official Granola MCP tools (3 meeting + 1
//       folder + 1 transcript + 1 account) per
//       https://mcp.granola.ai/mcp + docs.granola.ai (verified 2026-06-03
//       via WebFetch).
//   (2) INTERNAL HELPERS — exposed for consumer convenience + testing, but
//       NOT declared as bus capabilities (no action_type; no authz check).
//
// Reference implementation: @ifos/bullhorn (Day-28 scaffold; commit ff0f7b6)
// + @ifos/workos (Day-29 Phase 2 scaffold; commit 6dc5a4a). Granola adds:
//   - OAuth 2.1 PKCE + Dynamic Client Registration (browser-mediated bootstrap)
//   - Plan-tier guard (PAID_PLAN_TOOLS = list_meeting_folders + get_meeting_transcript)
//   - GranolaTransport abstraction (the upstream is MCP JSON-RPC, not raw HTTP REST)
//
// TODO(W5-live): wire @modelcontextprotocol/sdk's StreamableHTTPClientTransport
// as the default transport. The scaffold layer is transport-agnostic so this
// is a single-file plug-in at first commercial signup.

// ─────────────────────────────────────────────────────────────────────────
// (1) Bus-routed capabilities (set-equal with Scribe tools.yaml — W6+)
// ─────────────────────────────────────────────────────────────────────────

// Meeting capabilities (all plans): list_meetings + get_meetings + query_granola_meetings
export { listMeetings, getMeeting, queryMeetings } from "./meetings.js";
// Folder capability (PAID plans only): list_meeting_folders
export { listFolders } from "./folders.js";
// Transcript capability (PAID plans only): get_meeting_transcript
export { getTranscript } from "./transcripts.js";
// Account capability (all plans): get_account_info — used by IFOS to
// pre-cache plan_tier and short-circuit the per-call Paid-plan guard
export { getAccountInfo } from "./account.js";

// ─────────────────────────────────────────────────────────────────────────
// (2) Internal helpers (NOT bus-routed; surfaced for consumers + tests)
// ─────────────────────────────────────────────────────────────────────────

// Transport class — constructed once per workspace_id; carries the above
// capabilities through the rate-limit + retry + plan-tier-guard layers.
export {
  GranolaClient,
  DEFAULT_TIMEOUT_MS,
  DEFAULT_MCP_SERVER_URL,
  PAID_PLAN_TOOLS,
} from "./client.js";
// OAuth helpers (PKCE pair, code exchange, token refresh, atomic persist)
export {
  generatePkcePair,
  loadTokens,
  saveTokens,
  shouldRefresh,
  refreshTokens,
  exchangeAuthCode,
  DEFAULT_GRANOLA_TOKEN_URL,
  DEFAULT_GRANOLA_DCR_URL,
} from "./auth.js";
// Disk cache (10-min default TTL; 1h on account info; 5min on meetings)
export { GranolaCache } from "./cache.js";
// Rate-limit introspection — soft signal exposed via rateCheck() (read-only;
// consumer is responsible for honouring shouldBackoff at the soft threshold;
// the hard 100% gate is enforced inside rateConsume()).
export {
  check as rateCheck,
  consume as rateConsume,
  reset as resetRateLimit,
} from "./rate-limit.js";
// Wire-shape parsers (mainly for advanced consumers that want to bypass
// the capability helpers and call callTool() directly)
export {
  parseListMeetings,
  parseMeeting,
  parseListFolders,
  parseTranscript,
  parseAccountInfo,
} from "./parsers.js";
// Test/diagnostic
export { _resetInflightForTest } from "./auth.js";
// Error hierarchy
export {
  GranolaError,
  GranolaAuthError,
  GranolaRateLimitError,
  GranolaNotFoundError,
  GranolaPlanTierInsufficientError,
} from "./errors.js";
export type {
  GranolaConfig,
  GranolaTokens,
  GranolaPlanTier,
  GranolaMeeting,
  GranolaTranscript,
  GranolaTranscriptSegment,
  GranolaFolder,
  GranolaAccountInfo,
  GranolaTransport,
  GranolaToolCallResult,
  GranolaClientOptions,
} from "./types.js";
export type { RateState } from "./rate-limit.js";

export const VERSION = "0.1.0";
