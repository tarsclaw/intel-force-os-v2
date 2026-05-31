// Xero OAuth 2.0 token refresh + atomic disk persistence + concurrent-call dedup.
//
// Per review-mcp-connector §2 (OAuth refresh idempotency):
//   - Concurrent refresh() calls converge on ONE token rotation, not N
//     (in-process Promise lock per tenant_id).
//   - Atomic write to token_file_path via .tmp + rename — no torn file
//     visible to a parallel reader even mid-refresh.
//   - Tokens NEVER logged or thrown into error messages (review-mcp-connector §5).
//
// Token file shape (JSON):
//   { "access_token": "...", "refresh_token": "...", "expires_at_ms": N,
//     "scope": "...", "token_type": "Bearer" }
//
// Token file path is per-tenant (configured via XeroOAuthConfig.token_file_path).
// Recommend: ~/.ifos-local-vault/<tenant>/xero-tokens-<xero_tenant_id>.json (mode 0600).

import { promises as fs } from "node:fs";
import { XeroAuthError } from "./errors.js";
import type { XeroOAuthConfig, XeroTokens } from "./types.js";

const XERO_TOKEN_ENDPOINT = "https://identity.xero.com/connect/token";

// In-process per-tenant refresh dedup: while a refresh is in-flight,
// concurrent callers share the same Promise → one network call, one
// token rotation, one file write.
const inflight: Map<string, Promise<XeroTokens>> = new Map();

/** Read token file from disk; returns null if missing/malformed. */
export async function loadTokens(
  config: XeroOAuthConfig,
): Promise<XeroTokens | null> {
  let raw: string;
  try {
    raw = await fs.readFile(config.token_file_path, "utf8");
  } catch {
    return null;
  }
  try {
    const parsed = JSON.parse(raw) as XeroTokens;
    if (
      typeof parsed.access_token !== "string" ||
      typeof parsed.refresh_token !== "string" ||
      typeof parsed.expires_at_ms !== "number"
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
  config: XeroOAuthConfig,
  tokens: XeroTokens,
): Promise<void> {
  const tmpPath = `${config.token_file_path}.tmp.${process.pid}`;
  await fs.writeFile(tmpPath, JSON.stringify(tokens, null, 2), { mode: 0o600 });
  await fs.rename(tmpPath, config.token_file_path);
}

/**
 * Returns true if tokens expire within the next `safety_window_ms` (default 5 min).
 * Use to decide whether to refresh eagerly before a downstream call.
 */
export function shouldRefresh(
  tokens: XeroTokens,
  now: () => number = Date.now,
  safety_window_ms = 5 * 60 * 1000,
): boolean {
  return tokens.expires_at_ms - now() < safety_window_ms;
}

/**
 * Refresh OAuth tokens. Concurrent-safe: if a refresh is in flight for the
 * same tenant, return the in-flight Promise (one network call, one file write).
 *
 * Throws XeroAuthError on 4xx (credentials rejected); does NOT retry — caller
 * decides whether to re-attempt with new credentials.
 */
export async function refreshTokens(
  config: XeroOAuthConfig,
  current_tokens: XeroTokens,
  fetchFn: typeof fetch = fetch,
): Promise<XeroTokens> {
  const lockKey = config.tenant_id;
  const existing = inflight.get(lockKey);
  if (existing) return existing;

  const promise = (async () => {
    try {
      const basic = Buffer.from(
        `${config.client_id}:${config.client_secret}`,
      ).toString("base64");

      const body = new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: current_tokens.refresh_token,
      });

      const res = await fetchFn(XERO_TOKEN_ENDPOINT, {
        method: "POST",
        headers: {
          Authorization: `Basic ${basic}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body,
      });

      if (!res.ok) {
        // Never include the response body verbatim — Xero may echo the
        // (now-invalid) refresh_token in error responses.
        throw new XeroAuthError(
          `Xero OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
          res.status,
        );
      }

      const data = (await res.json()) as {
        access_token: string;
        refresh_token: string;
        expires_in: number;
        scope: string;
        token_type: string;
      };

      const new_tokens: XeroTokens = {
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_at_ms: Date.now() + data.expires_in * 1000,
        scope: data.scope,
        token_type: data.token_type,
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

/** Test helper — clears the in-flight refresh map. */
export function _resetInflightForTest(): void {
  inflight.clear();
}
