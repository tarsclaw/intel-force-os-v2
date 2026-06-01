// QuickBooks Online OAuth 2.0 token refresh + atomic disk persistence + concurrent-call dedup.
//
// Per review-mcp-connector §2 (OAuth refresh idempotency):
//   - Concurrent refresh() calls converge on ONE token rotation, not N
//     (in-process Promise lock per realm_id).
//   - Atomic write to token_file_path via .tmp + rename — no torn file
//     visible to a parallel reader even mid-refresh.
//   - Tokens NEVER logged or thrown into error messages (review-mcp-connector §5).
//
// QuickBooks vs Xero refresh diff:
//   - Endpoint: https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer
//     (vs Xero's https://identity.xero.com/connect/token)
//   - Both use Basic auth (Base64(client_id:client_secret)) + grant_type=refresh_token
//   - Both rotate the refresh_token on every refresh
//   - QB returns BOTH `expires_in` (access; ~3600s) AND `x_refresh_token_expires_in`
//     (refresh; ~8640000s ~ 100 days) — Xero doesn't return refresh expiry
//   - QB tokens are per-realm (each connected company has its own bundle)
//
// Token file shape (JSON):
//   { "access_token": "...", "refresh_token": "...", "expires_at_ms": N,
//     "refresh_token_expires_at_ms": N, "scope": "...", "token_type": "Bearer" }

import { promises as fs } from "node:fs";
import { QbAuthError } from "./errors.js";
import type { QbOAuthConfig, QbTokens } from "./types.js";

const QB_TOKEN_ENDPOINT = "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer";

const inflight: Map<string, Promise<QbTokens>> = new Map();

/** Read token file from disk; returns null if missing/malformed. */
export async function loadTokens(
  config: QbOAuthConfig,
): Promise<QbTokens | null> {
  let raw: string;
  try {
    raw = await fs.readFile(config.token_file_path, "utf8");
  } catch {
    return null;
  }
  try {
    const parsed = JSON.parse(raw) as QbTokens;
    if (
      typeof parsed.access_token !== "string" ||
      typeof parsed.refresh_token !== "string" ||
      typeof parsed.expires_at_ms !== "number" ||
      typeof parsed.refresh_token_expires_at_ms !== "number"
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
  config: QbOAuthConfig,
  tokens: QbTokens,
): Promise<void> {
  const tmpPath = `${config.token_file_path}.tmp.${process.pid}`;
  await fs.writeFile(tmpPath, JSON.stringify(tokens, null, 2), { mode: 0o600 });
  await fs.rename(tmpPath, config.token_file_path);
}

/**
 * Returns true if access token expires within the next `safety_window_ms` (default 5 min).
 */
export function shouldRefresh(
  tokens: QbTokens,
  now: () => number = Date.now,
  safety_window_ms = 5 * 60 * 1000,
): boolean {
  return tokens.expires_at_ms - now() < safety_window_ms;
}

/**
 * Returns true if refresh token is within the danger window (default 7 days from expiry).
 * QB refresh tokens are ~100-day TTL; if you cross the danger window without using them,
 * you'll need to re-do the consent dance from scratch.
 */
export function refreshTokenNearExpiry(
  tokens: QbTokens,
  now: () => number = Date.now,
  danger_window_ms = 7 * 24 * 60 * 60 * 1000,
): boolean {
  return tokens.refresh_token_expires_at_ms - now() < danger_window_ms;
}

/**
 * Refresh OAuth tokens. Concurrent-safe: if a refresh is in flight for the
 * same realm, return the in-flight Promise (one network call, one file write).
 *
 * Throws QbAuthError on 4xx (credentials rejected); does NOT retry.
 */
export async function refreshTokens(
  config: QbOAuthConfig,
  current_tokens: QbTokens,
  fetchFn: typeof fetch = fetch,
): Promise<QbTokens> {
  const lockKey = config.realm_id;
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

      const res = await fetchFn(QB_TOKEN_ENDPOINT, {
        method: "POST",
        headers: {
          Authorization: `Basic ${basic}`,
          "Content-Type": "application/x-www-form-urlencoded",
          Accept: "application/json",
        },
        body,
      });

      if (!res.ok) {
        // Never include the response body verbatim — QB may echo the
        // (now-invalid) refresh_token in error responses.
        throw new QbAuthError(
          `QuickBooks OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
          res.status,
        );
      }

      const data = (await res.json()) as {
        access_token: string;
        refresh_token: string;
        expires_in: number;
        x_refresh_token_expires_in: number;
        scope?: string;
        token_type: string;
      };

      const now = Date.now();
      const new_tokens: QbTokens = {
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_at_ms: now + data.expires_in * 1000,
        refresh_token_expires_at_ms: now + data.x_refresh_token_expires_in * 1000,
        scope: data.scope ?? "",
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
