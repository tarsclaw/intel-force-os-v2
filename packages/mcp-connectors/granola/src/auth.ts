// Granola OAuth 2.1 + PKCE (S256) + Dynamic Client Registration helpers +
// atomic token persistence + concurrent-call dedup.
//
// The Granola MCP server uses OAuth 2.0 with Dynamic Client Registration per
// docs.granola.ai ("credentials are handled automatically. You don't need to
// generate or enter any client ID or client secret"). The browser-based flow
// employs PKCE (S256). The IFOS wrapper handles the refresh path + per-workspace
// token persistence; the initial browser-based authorisation_code dance is a
// founder-side one-time bootstrap (run once per workspace, redirect captures
// the code, IFOS exchanges + persists).
//
// Per review-mcp-connector §2 (OAuth refresh idempotency):
//   - Concurrent refresh() calls converge on ONE rotation per workspace_id
//     (in-process Promise lock).
//   - Atomic write via .tmp + rename — no torn file visible to parallel readers.
//   - Tokens NEVER logged or thrown into error messages (review-mcp-connector §5).
//   - didForceRefresh flag honoured per cluster F R4 lesson: a single forced
//     refresh per request lifecycle in the client.
//
// TODO(W5-live): wire the live MCP-server token endpoint URL once the founder
// confirms it (the public Granola docs reference "browser OAuth" but do not
// publish the raw /token endpoint path — IFOS holds the placeholder default
// at https://api.granola.ai/oauth/token; first commercial signup verifies).

import { createHash, randomBytes } from "node:crypto";
import { promises as fs } from "node:fs";
import { GranolaAuthError } from "./errors.js";
import type { GranolaConfig, GranolaTokens } from "./types.js";

/** Default Granola OAuth token endpoint. Placeholder pending W5-live
 *  verification — the public MCP docs do not publish the raw endpoint URL
 *  (browser-mediated OAuth is the documented path). */
export const DEFAULT_GRANOLA_TOKEN_URL = "https://api.granola.ai/oauth/token";

/** Default Granola dynamic-client-registration endpoint. Placeholder pending
 *  W5-live verification — same caveat as above. */
export const DEFAULT_GRANOLA_DCR_URL = "https://api.granola.ai/oauth/register";

// In-process per-workspace refresh dedup: while a refresh is in-flight,
// concurrent callers share the same Promise → one token rotation, one file write.
const inflight: Map<string, Promise<GranolaTokens>> = new Map();

/**
 * PKCE pair generator. Returns the verifier (random URL-safe 32-byte string)
 * and the challenge (base64url(SHA-256(verifier))) per RFC 7636 §4.1-4.2.
 * Consumer stores the verifier locally until the authorisation_code returns,
 * then passes both to exchangeAuthCode().
 */
export function generatePkcePair(): { code_verifier: string; code_challenge: string } {
  // 32 random bytes → 43-char base64url verifier (well above RFC 7636 min 43 chars).
  const code_verifier = randomBytes(32).toString("base64url");
  const code_challenge = createHash("sha256")
    .update(code_verifier)
    .digest("base64url");
  return { code_verifier, code_challenge };
}

/** Read token file from disk; returns null if missing/malformed. */
export async function loadTokens(
  config: GranolaConfig,
): Promise<GranolaTokens | null> {
  let raw: string;
  try {
    raw = await fs.readFile(config.token_file_path, "utf8");
  } catch {
    return null;
  }
  try {
    const parsed = JSON.parse(raw) as GranolaTokens;
    if (
      typeof parsed.access_token !== "string" ||
      typeof parsed.refresh_token !== "string" ||
      typeof parsed.expires_at_ms !== "number" ||
      typeof parsed.token_type !== "string"
    ) {
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

/**
 * Atomic save: write to <path>.tmp then rename. A parallel reader either
 * sees the OLD file or the NEW file, never a torn partial.
 */
export async function saveTokens(
  config: GranolaConfig,
  tokens: GranolaTokens,
): Promise<void> {
  const tmpPath = `${config.token_file_path}.tmp.${process.pid}`;
  await fs.writeFile(tmpPath, JSON.stringify(tokens, null, 2), { mode: 0o600 });
  await fs.rename(tmpPath, config.token_file_path);
}

/**
 * Returns true if the access_token expires within the next
 * `safety_window_ms` (default 120s — Granola tokens typically have ~1h TTL
 * per OAuth 2.1 norms; a 2-min window gives generous headroom).
 */
export function shouldRefresh(
  tokens: GranolaTokens,
  now: () => number = Date.now,
  safety_window_ms = 120 * 1000,
): boolean {
  return tokens.expires_at_ms - now() < safety_window_ms;
}

/**
 * Standard OAuth 2.1 refresh: rotate access_token (and refresh_token if the
 * server returns a new one). Concurrent-safe: if a refresh is in flight
 * for the same workspace_id, return the in-flight Promise (one rotation
 * per workspace, not N).
 *
 * Throws GranolaAuthError on 4xx; does NOT retry — caller decides whether
 * to surface ESC_GRANOLA_AUTH and degrade.
 */
export async function refreshTokens(
  config: GranolaConfig,
  current_tokens: GranolaTokens,
  fetchFn: typeof fetch = fetch,
  token_url: string = DEFAULT_GRANOLA_TOKEN_URL,
): Promise<GranolaTokens> {
  const lockKey = config.workspace_id;
  const existing = inflight.get(lockKey);
  if (existing) return existing;

  const promise = (async () => {
    try {
      const body = new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: current_tokens.refresh_token,
        client_id: config.client_id,
      });

      const res = await fetchFn(token_url, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body,
      });

      if (!res.ok) {
        // Never include the response body verbatim — Granola may echo the
        // (now-invalid) refresh_token in error responses.
        throw new GranolaAuthError(
          `Granola OAuth refresh failed (HTTP ${res.status}); ` +
            `refresh_token may have been revoked or expired — re-run browser ` +
            `OAuth consent for workspace_id=${config.workspace_id}`,
          res.status,
        );
      }

      const data = (await res.json()) as {
        access_token: string;
        refresh_token?: string;
        expires_in: number;
        scope?: string;
        token_type?: string;
      };

      const nowMs = Date.now();
      const new_tokens: GranolaTokens = {
        access_token: data.access_token,
        // OAuth 2.1 servers may rotate or persist the refresh_token; honour
        // whichever the server returned, fall back to the existing one.
        refresh_token: data.refresh_token ?? current_tokens.refresh_token,
        expires_at_ms: nowMs + data.expires_in * 1000,
        scope: data.scope ?? current_tokens.scope,
        token_type: data.token_type ?? "Bearer",
      };

      await saveTokens(config, new_tokens);
      return new_tokens;
    } finally {
      inflight.delete(lockKey);
    }
  })();

  inflight.set(lockKey, promise);
  return promise;
}

/**
 * Initial code-exchange after the browser redirect captures the
 * authorisation_code. Founder runs this once per workspace_id during
 * the bootstrap dance.
 *
 * Throws GranolaAuthError on 4xx.
 */
export async function exchangeAuthCode(
  config: GranolaConfig,
  authorisation_code: string,
  code_verifier: string,
  redirect_uri: string,
  fetchFn: typeof fetch = fetch,
  token_url: string = DEFAULT_GRANOLA_TOKEN_URL,
): Promise<GranolaTokens> {
  const body = new URLSearchParams({
    grant_type: "authorization_code",
    code: authorisation_code,
    code_verifier,
    redirect_uri,
    client_id: config.client_id,
  });

  const res = await fetchFn(token_url, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body,
  });

  if (!res.ok) {
    throw new GranolaAuthError(
      `Granola authorisation_code exchange failed (HTTP ${res.status}); ` +
        `code may have expired or PKCE verifier mismatched`,
      res.status,
    );
  }

  const data = (await res.json()) as {
    access_token: string;
    refresh_token: string;
    expires_in: number;
    scope?: string;
    token_type?: string;
  };

  const nowMs = Date.now();
  const tokens: GranolaTokens = {
    access_token: data.access_token,
    refresh_token: data.refresh_token,
    expires_at_ms: nowMs + data.expires_in * 1000,
    scope: data.scope,
    token_type: data.token_type ?? "Bearer",
  };

  await saveTokens(config, tokens);
  return tokens;
}

/** Test helper — clears the in-flight refresh map. */
export function _resetInflightForTest(): void {
  inflight.clear();
}
