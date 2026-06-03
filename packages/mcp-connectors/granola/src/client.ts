// Granola wrapper client — wraps the MCP transport with: token-attach (via
// loaded GranolaTokens + refresh-on-stale), per-workspace_id rate-limit
// budget, plan-tier guard (pre-check + 403 surface), typed errors, 401-force-
// refresh (single rotation per request lifecycle per cluster F R4 lesson).
//
// Distinct from BullhornClient + WorkosClient: the upstream is not raw HTTP
// REST but the Granola MCP server (which speaks JSON-RPC over Streamable
// HTTP). Auth/rate-limit/error handling happens HERE in the wrapper; the
// transport itself just shuttles the JSON-RPC envelope.

import { refreshTokens, shouldRefresh, loadTokens } from "./auth.js";
import {
  GranolaAuthError,
  GranolaError,
  GranolaNotFoundError,
  GranolaPlanTierInsufficientError,
  GranolaRateLimitError,
} from "./errors.js";
import { consume } from "./rate-limit.js";
import type {
  GranolaAccountInfo,
  GranolaClientOptions,
  GranolaPlanTier,
  GranolaToolCallResult,
  GranolaTokens,
} from "./types.js";

export const DEFAULT_TIMEOUT_MS = 30_000;
export const DEFAULT_MCP_SERVER_URL = "https://mcp.granola.ai/mcp";

/** Subset of Granola MCP tools that require a Paid plan per the official
 *  docs (verified 2026-06-03 via WebFetch). */
export const PAID_PLAN_TOOLS: ReadonlySet<string> = new Set([
  "list_meeting_folders",
  "get_meeting_transcript",
]);

interface CallToolOptions {
  /** Bypass the rate-limit consume() call (used by internal helpers that
   *  already accounted for the call). */
  skip_rate_limit?: boolean;
  /** Caller-supplied plan-tier hint (avoids loading account info on every
   *  call). When set + the tool requires Paid + the hint says Free, the
   *  call throws GranolaPlanTierInsufficientError without hitting the wire. */
  plan_tier_hint?: GranolaPlanTier;
  /** Override max retries for this call (default 2 for read tools, 0 for writes). */
  max_retries?: number;
}

export class GranolaClient {
  private readonly opts: GranolaClientOptions;
  private readonly now: () => number;
  private current_tokens: GranolaTokens | null = null;
  /** Cached account info — used to short-circuit Paid-tier guard without
   *  loading on every call. Populated lazily on first capability call that
   *  hits a Paid-only tool. */
  private cached_account_info: GranolaAccountInfo | null = null;

  constructor(opts: GranolaClientOptions) {
    this.opts = opts;
    this.now = opts.now ?? Date.now;
  }

  /** Returns the active access_token, refreshing eagerly if within the
   *  safety window. Loads from disk on first call. */
  async getValidToken(): Promise<string> {
    if (!this.current_tokens) {
      this.current_tokens = await loadTokens(this.opts.config);
      if (!this.current_tokens) {
        throw new GranolaAuthError(
          "No Granola tokens on disk; browser-based OAuth consent flow " +
            `required to bootstrap tokens for workspace_id=${this.opts.config.workspace_id}. ` +
            "Run the one-time authorise + exchangeAuthCode dance per README §Bootstrap.",
        );
      }
    }
    if (shouldRefresh(this.current_tokens, this.now)) {
      this.current_tokens = await refreshTokens(
        this.opts.config,
        this.current_tokens,
      );
    }
    return this.current_tokens.access_token;
  }

  /** Test/diagnostic — set the cached plan tier without hitting the wire. */
  _setAccountInfoForTest(info: GranolaAccountInfo): void {
    this.cached_account_info = info;
  }

  /** Call a Granola MCP tool with IFOS-wrapper guards applied. */
  async callTool(
    tool_name: string,
    args: Record<string, unknown>,
    options: CallToolOptions = {},
  ): Promise<GranolaToolCallResult> {
    // ─── Pre-emptive plan-tier guard ─────────────────────────────────────
    // If we know the workspace is Free AND the tool requires Paid → throw
    // without spending a rate-limit slot or a wire call.
    if (PAID_PLAN_TOOLS.has(tool_name)) {
      const tier =
        options.plan_tier_hint ?? this.cached_account_info?.plan_tier;
      if (tier === "free") {
        throw new GranolaPlanTierInsufficientError(
          `Granola tool '${tool_name}' requires a Paid plan; ` +
            `workspace_id=${this.opts.config.workspace_id} is on Free tier`,
          "paid",
          tool_name,
        );
      }
    }

    const max_retries = options.max_retries ?? 2;
    // Per cluster F R4 lesson: refreshTokens() is state-changing — limit to
    // ONE forced refresh per request lifecycle, otherwise concurrent 401s
    // burn refresh_token rotations needlessly.
    let didForceRefresh = false;

    for (let attempt = 0; attempt <= max_retries; attempt++) {
      // Pre-emptive rate-limit check (per-workspace_id bucket)
      if (!options.skip_rate_limit) {
        const allowed = consume(this.opts.config.workspace_id, this.now);
        if (!allowed) {
          throw new GranolaRateLimitError(
            `Granola rate-limit budget exhausted ` +
              `(workspace=${this.opts.config.workspace_id}); ` +
              `local bucket prevents call to avoid upstream 429`,
          );
        }
      }

      // Ensure we have a fresh token; refreshTokens() handles rotation.
      await this.getValidToken();

      const result = await this.opts.transport.callTool(tool_name, args);

      // 200-ish happy path
      if (!result.isError) {
        return result;
      }

      // Map status hints into typed errors
      const status = result._status_hint ?? 0;

      // 401: access_token rejected — force one refresh + retry
      if (status === 401 && attempt < max_retries && !didForceRefresh) {
        if (this.current_tokens) {
          this.current_tokens = await refreshTokens(
            this.opts.config,
            this.current_tokens,
          );
        }
        didForceRefresh = true;
        continue;
      }
      if (status === 401) {
        throw new GranolaAuthError(
          `Granola MCP tool '${tool_name}' returned 401 after ${attempt + 1} attempt(s)` +
            (didForceRefresh
              ? " including a forced refresh — server is rejecting the rotated token"
              : ""),
          401,
        );
      }

      // 403: plan-tier insufficient (upstream override of the pre-guard)
      if (status === 403 && PAID_PLAN_TOOLS.has(tool_name)) {
        throw new GranolaPlanTierInsufficientError(
          `Granola tool '${tool_name}' rejected with 403 — workspace is not on a Paid plan`,
          "paid",
          tool_name,
        );
      }

      // 404: resource not found
      if (status === 404) {
        throw new GranolaNotFoundError(
          `Granola MCP tool '${tool_name}' returned 404 (resource not found)`,
        );
      }

      // 429: rate-limited upstream
      if (status === 429 && attempt < max_retries) {
        // No Retry-After parsing — the MCP wire doesn't carry HTTP headers
        // through; backoff via attempt counter instead.
        await sleep(250 * 2 ** attempt);
        continue;
      }
      if (status === 429) {
        throw new GranolaRateLimitError(
          `Granola returned 429 after ${attempt + 1} attempt(s)`,
        );
      }

      // 5xx: retry with backoff
      if (status >= 500 && attempt < max_retries) {
        await sleep(250 * 2 ** attempt);
        continue;
      }

      // Otherwise: surface as base error (preserve isError content)
      const msgFromContent =
        result.content
          .filter((c) => c.type === "text")
          .map((c) => (c.type === "text" ? c.text : ""))
          .join(" ") || `Granola MCP tool '${tool_name}' failed`;
      throw new GranolaError(msgFromContent, status);
    }
    throw new GranolaError(
      `Granola MCP tool '${tool_name}' exhausted retries`,
    );
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}
