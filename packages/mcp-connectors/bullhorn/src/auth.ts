// Bullhorn TWO-STEP token refresh + atomic disk persistence + concurrent-call
// dedup. This is Bullhorn-specific — distinct from xero's single-step OAuth
// because Bullhorn requires:
//
//   Step A: OAuth 2.0 refresh against auth-{region}.bullhornstaffing.com →
//           new {oauth_access_token, oauth_refresh_token, expires_in}.
//   Step B: REST login GET against rest.bullhornstaffing.com/rest-services/login
//           ?version=2.0&access_token={oauth_access_token} → returns
//           {BhRestToken, restUrl}. THIS is the token + base-URL the REST API
//           calls actually use. The OAuth access_token alone won't work on
//           data endpoints.
//
// Per review-mcp-connector §2 (OAuth refresh idempotency):
//   - Concurrent refresh() calls converge on ONE full Step-A + Step-B
//     rotation, not N (in-process Promise lock per corporation_id).
//   - Atomic write via .tmp + rename — no torn file visible to parallel
//     readers even mid-refresh.
//   - Tokens NEVER logged or thrown into error messages (review-mcp-connector §5).
//
// Token file shape on disk (JSON; mode 0600):
//   {
//     "oauth_access_token": "...", "oauth_refresh_token": "...",
//     "oauth_expires_at_ms": N, "scope": "...", "token_type": "Bearer",
//     "bh_rest_token": "...", "rest_url": "https://rest9.bullhornstaffing.com/...",
//     "bh_rest_token_expires_at_ms": N
//   }

import { promises as fs } from "node:fs";
import { BullhornAuthError } from "./errors.js";
import type { BullhornOAuthConfig, BullhornRegion, BullhornTokens } from "./types.js";

/**
 * Bullhorn region → OAuth endpoint mapping. Per community sources
 * (https://help.bullhorn.com/article/How-To-Authenticate-With-the-Bullhorn-REST-API)
 * the OAuth host is region-specific; the REST host (rest.bullhornstaffing.com)
 * is global and returns a per-corp REST URL from /login.
 *
 * v1.0 default: explicit per-tenant region (US 'east'/'west', UK 'uk').
 * TODO(W5-live): verify endpoint variance during first commercial signup;
 * Bullhorn's public docs are thin on exact regional URLs.
 */
function oauthHostFor(region: BullhornRegion): string {
  switch (region) {
    case "west":
      return "https://auth-west.bullhornstaffing.com";
    case "east":
      return "https://auth-east.bullhornstaffing.com";
    case "uk":
      return "https://auth-uk.bullhornstaffing.com";
  }
}

export const BULLHORN_REST_LOGIN_URL =
  "https://rest.bullhornstaffing.com/rest-services/login";

// In-process per-corporation refresh dedup: while a refresh is in-flight,
// concurrent callers share the same Promise → one OAuth call, one REST login
// call, one file write.
const inflight: Map<string, Promise<BullhornTokens>> = new Map();

/** Read token file from disk; returns null if missing/malformed. */
export async function loadTokens(
  config: BullhornOAuthConfig,
): Promise<BullhornTokens | null> {
  let raw: string;
  try {
    raw = await fs.readFile(config.token_file_path, "utf8");
  } catch {
    return null;
  }
  try {
    const parsed = JSON.parse(raw) as BullhornTokens;
    if (
      typeof parsed.oauth_access_token !== "string" ||
      typeof parsed.oauth_refresh_token !== "string" ||
      typeof parsed.oauth_expires_at_ms !== "number" ||
      typeof parsed.bh_rest_token !== "string" ||
      typeof parsed.rest_url !== "string" ||
      typeof parsed.bh_rest_token_expires_at_ms !== "number"
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
  config: BullhornOAuthConfig,
  tokens: BullhornTokens,
): Promise<void> {
  const tmpPath = `${config.token_file_path}.tmp.${process.pid}`;
  await fs.writeFile(tmpPath, JSON.stringify(tokens, null, 2), { mode: 0o600 });
  await fs.rename(tmpPath, config.token_file_path);
}

/**
 * Returns true if EITHER the OAuth access_token OR the BhRestToken expires
 * within the next `safety_window_ms` (default 90s — both Bullhorn tokens have
 * ~10 min TTL so a tighter window than xero's 5min reduces wasted-refresh).
 */
export function shouldRefresh(
  tokens: BullhornTokens,
  now: () => number = Date.now,
  safety_window_ms = 90 * 1000,
): boolean {
  const nowMs = now();
  return (
    tokens.oauth_expires_at_ms - nowMs < safety_window_ms ||
    tokens.bh_rest_token_expires_at_ms - nowMs < safety_window_ms
  );
}

/**
 * Full two-step refresh: rotate OAuth tokens, then call REST login to get
 * a new BhRestToken + restUrl. Concurrent-safe: if a refresh is in flight
 * for the same corporation_id, return the in-flight Promise (one full
 * rotation per corp, not N).
 *
 * Throws BullhornAuthError on 4xx from either Step A (OAuth refresh) or
 * Step B (REST login); does NOT retry — caller decides whether to re-attempt
 * with new credentials or surface ESC_BULLHORN_AUTH.
 */
export async function refreshTokens(
  config: BullhornOAuthConfig,
  current_tokens: BullhornTokens,
  fetchFn: typeof fetch = fetch,
): Promise<BullhornTokens> {
  const lockKey = config.corporation_id;
  const existing = inflight.get(lockKey);
  if (existing) return existing;

  const promise = (async () => {
    try {
      // ─── Step A: OAuth refresh ─────────────────────────────────────────
      const oauthHost = oauthHostFor(config.region);
      const oauthUrl = `${oauthHost}/oauth/token`;
      const oauthBody = new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: current_tokens.oauth_refresh_token,
        client_id: config.client_id,
        client_secret: config.client_secret,
      });

      const oauthRes = await fetchFn(oauthUrl, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: oauthBody,
      });

      if (!oauthRes.ok) {
        // Never include the response body verbatim — Bullhorn may echo the
        // (now-invalid) refresh_token in error responses.
        throw new BullhornAuthError(
          `Bullhorn OAuth refresh (Step A) failed (HTTP ${oauthRes.status}); ` +
            `credentials may have been revoked or refresh_token expired`,
          oauthRes.status,
        );
      }

      const oauthData = (await oauthRes.json()) as {
        access_token: string;
        refresh_token: string;
        expires_in: number;
        scope?: string;
        token_type?: string;
      };

      // ─── Step B: REST login ────────────────────────────────────────────
      const loginUrl = new URL(BULLHORN_REST_LOGIN_URL);
      loginUrl.searchParams.set("version", "2.0");
      loginUrl.searchParams.set("access_token", oauthData.access_token);

      const loginRes = await fetchFn(loginUrl.toString(), { method: "GET" });

      if (!loginRes.ok) {
        throw new BullhornAuthError(
          `Bullhorn REST login (Step B) failed (HTTP ${loginRes.status}); ` +
            `OAuth access_token was accepted but the login endpoint refused it`,
          loginRes.status,
        );
      }

      const loginData = (await loginRes.json()) as {
        BhRestToken: string;
        restUrl: string;
      };

      const nowMs = Date.now();
      const new_tokens: BullhornTokens = {
        oauth_access_token: oauthData.access_token,
        oauth_refresh_token: oauthData.refresh_token,
        oauth_expires_at_ms: nowMs + oauthData.expires_in * 1000,
        scope: oauthData.scope ?? current_tokens.scope,
        token_type: oauthData.token_type ?? "Bearer",
        bh_rest_token: loginData.BhRestToken,
        rest_url: loginData.restUrl,
        // BhRestToken TTL is not explicitly returned; default to the OAuth
        // expiry (Bullhorn's ~10min TTL is the same for both per forum threads).
        bh_rest_token_expires_at_ms: nowMs + oauthData.expires_in * 1000,
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
