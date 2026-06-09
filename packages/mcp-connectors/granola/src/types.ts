// Granola types — subset of the v1.0 surface IFOS Scribe agent consumes.
// Reference: https://mcp.granola.ai/mcp + https://docs.granola.ai/help-center/
// sharing/integrations/integrations-with-granola (verified 2026-06-03 via WebFetch).
//
// The official Granola MCP server exposes SIX tools; the IFOS wrapper groups
// them into 4 capability files (meetings + folders + transcripts + account)
// matching review-mcp-connector §1 set-equality requirements.

/**
 * Granola plan tiers (verified 2026-06-03 via Granola docs WebFetch).
 *
 * The plan-doc-encoded shape 'basic'|'business'|'enterprise' was an
 * approximation; the ACTUAL Granola MCP docs gate features as either
 * "All plans" (free) or "Paid plans only". The IFOS type honours the
 * actual API rather than the approximation — surface this delta in
 * the W5 close report so the goal-week-5-execution-plan.md Phase 3
 * description can be corrected fix-forward.
 *
 * Free plan limitation per Granola docs: "you can only query notes
 * in the last 30 days". Paid plans (Business, Pro, Team, Enterprise)
 * unlock `list_meeting_folders` + `get_meeting_transcript` + full
 * history.
 */
export type GranolaPlanTier = "free" | "paid";

/**
 * Granola uses OAuth 2.0 with Dynamic Client Registration per the official
 * docs ("credentials are handled automatically. You don't need to generate
 * or enter any client ID or client secret"). The browser-based flow uses
 * PKCE (S256). The IFOS wrapper persists the resulting access_token +
 * refresh_token + expires_at to disk per workspace_id.
 *
 * Net: GranolaConfig is smaller than BullhornOAuthConfig because:
 * - No client_secret (DCR handles it; client_id is per-install)
 * - No region (single global endpoint)
 * - workspace_id replaces corporation_id as the per-tenant key
 */
export interface GranolaConfig {
  /** Granola-issued client_id from the dynamic-client-registration bootstrap.
   *  Per-IFOS-install (lives in env); workspace_id is per-tenant. */
  client_id: string;
  /** Per-tenant Granola workspace identifier. Multi-tenant IFOS deployments
   *  hold one client_id but issue per-workspace_id token bundles + rate-limit
   *  + cache namespaces. */
  workspace_id: string;
  /** Token file on disk; atomic-rename writes go here. Recommend:
   *  ~/.ifos-local-vault/<tenant>/granola-tokens-<workspace_id>.json (mode 0600). */
  token_file_path: string;
  /** Optional MCP server URL override; defaults to https://mcp.granola.ai/mcp.
   *  Test envs may point at a fixture server. */
  mcp_server_url?: string;
}

export interface GranolaTokens {
  access_token: string;
  refresh_token: string;
  /** Unix epoch milliseconds when the access_token expires. */
  expires_at_ms: number;
  scope?: string;
  token_type: string; // typically "Bearer"
}

// ─────────────────────────────────────────────────────────────────────────
// Meeting + transcript shapes (consumed by Scribe agent W6+)
// ─────────────────────────────────────────────────────────────────────────

export interface GranolaMeeting {
  id: string;
  title: string | null;
  /** ISO-8601; meeting start (when it was scheduled, not when transcribed). */
  start_time: string;
  /** ISO-8601; meeting end. May be null for in-progress / cancelled. */
  end_time: string | null;
  duration_minutes: number | null;
  /** Folder this meeting was filed under, if any. */
  folder_id: string | null;
  /** Free-text attendee list (Granola does NOT publish a structured
   *  per-attendee schema in the MCP surface; this is what we get). */
  attendees: string[];
  /** Granola-generated summary notes (markdown). */
  notes_markdown: string | null;
  /** Whether the consumer has a transcript available for this meeting.
   *  Paid plans only; on free plans this is always false even if the
   *  meeting was recorded. */
  has_transcript: boolean;
  created_at: string;
  updated_at: string;
}

export interface GranolaTranscriptSegment {
  /** Seconds-from-start (float). */
  start_seconds: number;
  end_seconds: number;
  /** Speaker label (e.g. "Speaker 1", or a real name if Granola identified them). */
  speaker: string | null;
  text: string;
}

export interface GranolaTranscript {
  meeting_id: string;
  /** ISO language code (e.g. "en"). */
  language: string;
  segments: GranolaTranscriptSegment[];
  /** Total transcript duration in seconds. */
  duration_seconds: number;
  generated_at: string;
}

export interface GranolaFolder {
  id: string;
  name: string;
  parent_folder_id: string | null;
  /** Count of meetings filed under this folder (may be approximate per Granola). */
  meeting_count: number;
  created_at: string;
  updated_at: string;
}

export interface GranolaAccountInfo {
  /** Workspace this token bundle authenticates against. */
  workspace_id: string;
  workspace_name: string;
  plan_tier: GranolaPlanTier;
  /** Email of the user the token was issued to. */
  user_email: string | null;
  /** Whether transcripts are unlocked on this plan (mirrors plan_tier === 'paid'). */
  transcripts_enabled: boolean;
  /** Whether folder listing is unlocked on this plan. */
  folders_enabled: boolean;
}

// ─────────────────────────────────────────────────────────────────────────
// MCP transport abstraction
// ─────────────────────────────────────────────────────────────────────────

/**
 * The Granola MCP server speaks the standard MCP wire protocol over HTTP
 * (Streamable HTTP transport per the MCP spec). The IFOS wrapper does NOT
 * pull in @modelcontextprotocol/sdk at v0.1.0 — instead it abstracts behind
 * a thin `GranolaTransport` interface so:
 *   (1) tests can inject a fake transport without any real HTTP, and
 *   (2) the live wiring (W5-live) can plug `StreamableHTTPClientTransport`
 *       from @modelcontextprotocol/sdk into the same surface.
 *
 * The default HTTP transport implementation lives in src/transport-http.ts
 * (GranolaHttpTransport, wraps StreamableHTTPClientTransport). The
 * auth/rate-limit/cache/plan-tier layers are independent of which transport is
 * wired in. Live path UNVERIFIED until Phase-1b live tests run.
 */
export interface GranolaTransport {
  /** Call an MCP tool by name with arbitrary JSON args; return the tool's
   *  result envelope verbatim. The wrapper's capability helpers parse the
   *  result into typed shapes. */
  callTool(
    tool_name: string,
    args: Record<string, unknown>,
  ): Promise<GranolaToolCallResult>;
}

/** MCP tool-call result envelope. Mirrors the MCP wire shape: a list of
 *  content blocks (text or structured-data) plus an isError flag. */
export interface GranolaToolCallResult {
  content: Array<{ type: "text"; text: string } | { type: "resource"; uri: string }>;
  isError?: boolean;
  /** HTTP-equivalent status hint for IFOS error mapping. The official
   *  MCP transport surfaces auth/rate-limit/etc. via the isError flag +
   *  content; the IFOS wrapper layer maps these into the typed error
   *  classes. */
  _status_hint?: number;
}

export interface GranolaClientOptions {
  config: GranolaConfig;
  /** Transport (real or fake). OPTIONAL: when omitted, GranolaClient defaults
   *  to GranolaHttpTransport (src/transport-http.ts) wrapping the
   *  @modelcontextprotocol/sdk StreamableHTTPClientTransport against
   *  config.mcp_server_url. Tests inject a fake transport here. */
  transport?: GranolaTransport;
  /** Override now() (testing). */
  now?: () => number;
}
