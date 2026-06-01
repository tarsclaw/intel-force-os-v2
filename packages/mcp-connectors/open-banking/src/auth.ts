// Open Banking OAuth refresh + PSD2 90-day consent tracking + token-aging stages.
//
// PSD2 mandates that users re-authenticate every 90 days regardless of whether
// the refresh token would otherwise still be valid. This package's auth layer
// tracks BOTH:
//   - access_token expiry (typical ~1h) → refresh transparently
//   - consent expiry (~90 days from initial consent) → emit ESC_OPEN_BANKING_TOKEN_AGING
//     stages so the agent can notify the operator before the consent dies
//
// Token-aging stages (per Cash Conductor agent.md §6):
//   - fresh:    > 30 days to consent expiry
//   - info:     ≤ 30 days  (operator-aware; nothing breaks)
//   - warn:     ≤ 14 days  (escalate to operator chat)
//   - blocking: ≤ 7  days  (HARD STOP — must re-consent; refuses to issue new access tokens)
//
// Provider scope (W4 Day-26):
//   - TrueLayer: full OAuth refresh implemented.
//   - Plaid UK: refreshTokens throws NotImplementedError (v1.1+).

import { promises as fs } from "node:fs";
import {
  NotImplementedError,
  OpenBankingAuthError,
  OpenBankingConsentExpiredError,
} from "./errors.js";
import type {
  OpenBankingConfig,
  OpenBankingTokens,
  TokenAgeReport,
  TokenAgeStage,
} from "./types.js";

const TRUELAYER_TOKEN_ENDPOINT_PROD =
  "https://auth.truelayer.com/connect/token";
const TRUELAYER_TOKEN_ENDPOINT_SANDBOX =
  "https://auth.truelayer-sandbox.com/connect/token";

const DAY_MS = 24 * 60 * 60 * 1000;

const inflight: Map<string, Promise<OpenBankingTokens>> = new Map();

/** Read token file from disk; returns null if missing/malformed. */
export async function loadTokens(
  config: OpenBankingConfig,
): Promise<OpenBankingTokens | null> {
  let raw: string;
  try {
    raw = await fs.readFile(config.token_file_path, "utf8");
  } catch {
    return null;
  }
  try {
    const parsed = JSON.parse(raw) as OpenBankingTokens;
    if (
      typeof parsed.access_token !== "string" ||
      typeof parsed.refresh_token !== "string" ||
      typeof parsed.expires_at_ms !== "number" ||
      typeof parsed.consent_expires_at_ms !== "number"
    ) {
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

/** Atomic save: write to <path>.tmp then rename. */
export async function saveTokens(
  config: OpenBankingConfig,
  tokens: OpenBankingTokens,
): Promise<void> {
  const tmpPath = `${config.token_file_path}.tmp.${process.pid}`;
  await fs.writeFile(tmpPath, JSON.stringify(tokens, null, 2), { mode: 0o600 });
  await fs.rename(tmpPath, config.token_file_path);
}

/** Returns true if access token expires within the next `safety_window_ms` (default 5 min). */
export function shouldRefresh(
  tokens: OpenBankingTokens,
  now: () => number = Date.now,
  safety_window_ms = 5 * 60 * 1000,
): boolean {
  return tokens.expires_at_ms - now() < safety_window_ms;
}

/**
 * Pure function: classify token age based on days to PSD2 consent expiry.
 * Property-tested across day 0-100 boundary.
 */
export function getTokenAgeStage(
  tokens: OpenBankingTokens,
  now: () => number = Date.now,
): TokenAgeReport {
  const days = (tokens.consent_expires_at_ms - now()) / DAY_MS;
  let stage: TokenAgeStage;
  if (days <= 7) stage = "blocking";
  else if (days <= 14) stage = "warn";
  else if (days <= 30) stage = "info";
  else stage = "fresh";
  return {
    stage,
    days_until_consent_expiry: days,
    consent_expires_at_ms: tokens.consent_expires_at_ms,
  };
}

/**
 * Refresh OAuth tokens. Provider-aware: TrueLayer fully implemented; Plaid UK
 * throws NotImplementedError. Concurrent-safe per (provider, connection_id).
 *
 * Refuses refresh if consent age is "blocking" — operator MUST re-do the PSD2
 * consent dance with the user first.
 */
export async function refreshTokens(
  config: OpenBankingConfig,
  current_tokens: OpenBankingTokens,
  fetchFn: typeof fetch = fetch,
  now: () => number = Date.now,
): Promise<OpenBankingTokens> {
  // Consent-age hard stop BEFORE attempting refresh
  const ageReport = getTokenAgeStage(current_tokens, now);
  if (ageReport.stage === "blocking") {
    throw new OpenBankingConsentExpiredError(
      `PSD2 consent within ${Math.max(0, Math.floor(ageReport.days_until_consent_expiry))} days of expiry; ` +
        `re-consent required before refresh (provider=${config.provider}, connection_id=${config.connection_id})`,
    );
  }

  if (config.provider === "plaid-uk") {
    throw new NotImplementedError(
      "Plaid UK OAuth refresh not yet implemented (v1.1+ deferred per Cash Conductor §9 Q2; v1.0 path is TrueLayer)",
    );
  }

  const lockKey = `${config.provider}:${config.connection_id}`;
  const existing = inflight.get(lockKey);
  if (existing) return existing;

  const tokenEndpoint =
    config.environment === "production"
      ? TRUELAYER_TOKEN_ENDPOINT_PROD
      : TRUELAYER_TOKEN_ENDPOINT_SANDBOX;

  const promise = (async () => {
    try {
      const body = new URLSearchParams({
        grant_type: "refresh_token",
        client_id: config.client_id,
        client_secret: config.client_secret,
        refresh_token: current_tokens.refresh_token,
      });

      const res = await fetchFn(tokenEndpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          Accept: "application/json",
        },
        body,
      });

      if (!res.ok) {
        // Never include the response body verbatim — TrueLayer may echo
        // the (now-invalid) refresh_token in error responses.
        throw new OpenBankingAuthError(
          `TrueLayer OAuth refresh failed (HTTP ${res.status}); credentials may have been revoked or refresh_token expired`,
          res.status,
          res.status === 401 ? "refresh_token_revoked" : "credentials",
        );
      }

      const data = (await res.json()) as {
        access_token: string;
        refresh_token: string;
        expires_in: number;
        scope?: string;
        token_type: string;
      };

      // TrueLayer does NOT extend the PSD2 consent on refresh — only the
      // access_token rotates. Preserve the consent_expires_at_ms from
      // current_tokens; the consent dance has its own re-authentication flow.
      const new_tokens: OpenBankingTokens = {
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_at_ms: now() + data.expires_in * 1000,
        consent_expires_at_ms: current_tokens.consent_expires_at_ms,
        scope: data.scope ?? current_tokens.scope,
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
