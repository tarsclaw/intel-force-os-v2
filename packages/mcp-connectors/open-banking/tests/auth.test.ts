// OAuth tests per review-mcp-connector §2 (idempotency + atomic file write +
// concurrent-safety test) + PSD2 consent-expiry guard test.

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  _resetInflightForTest,
  loadTokens,
  refreshTokens,
  saveTokens,
  shouldRefresh,
} from "../src/auth.js";
import {
  NotImplementedError,
  OpenBankingAuthError,
  OpenBankingConsentExpiredError,
} from "../src/errors.js";
import type {
  OpenBankingConfig,
  OpenBankingTokens,
} from "../src/types.js";

const DAY_MS = 24 * 60 * 60 * 1000;

const FIXTURE_TOKENS: OpenBankingTokens = {
  access_token: "tl-access-old",
  refresh_token: "tl-refresh-old",
  expires_at_ms: Date.now() + 3600_000,
  consent_expires_at_ms: Date.now() + 60 * DAY_MS,
  scope: "accounts transactions balance",
  token_type: "Bearer",
};

const REFRESH_OK_BODY = JSON.stringify({
  access_token: "tl-new-access",
  refresh_token: "tl-new-refresh",
  expires_in: 3600,
  scope: "accounts transactions balance",
  token_type: "Bearer",
});

function makeConfig(
  token_file: string,
  overrides: Partial<OpenBankingConfig> = {},
): OpenBankingConfig {
  return {
    provider: "truelayer",
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    connection_id: "acct-fixture",
    environment: "sandbox",
    token_file_path: token_file,
    ...overrides,
  };
}

let token_file: string;

beforeEach(() => {
  token_file = join(
    tmpdir(),
    `ob-tokens-test-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
  _resetInflightForTest();
});
afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
});

describe("open-banking auth", () => {
  it("loadTokens returns null when file missing", async () => {
    expect(await loadTokens(makeConfig(token_file))).toBeNull();
  });

  it("save + load round-trips token bundle (with consent_expires_at_ms)", async () => {
    const config = makeConfig(token_file);
    await saveTokens(config, FIXTURE_TOKENS);
    const loaded = await loadTokens(config);
    expect(loaded).toEqual(FIXTURE_TOKENS);
  });

  it("shouldRefresh: true if within 5-min safety window", () => {
    const expiringSoon: OpenBankingTokens = {
      ...FIXTURE_TOKENS,
      expires_at_ms: Date.now() + 60_000,
    };
    expect(shouldRefresh(expiringSoon)).toBe(true);
  });

  it("refreshTokens (TrueLayer): success writes new tokens; consent_expires_at_ms PRESERVED", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(REFRESH_OK_BODY, {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });

    const newT = await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    expect(newT.access_token).toBe("tl-new-access");
    expect(newT.consent_expires_at_ms).toBe(FIXTURE_TOKENS.consent_expires_at_ms);
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(newT.access_token);
  });

  it("refreshTokens: 401 surfaces as OpenBankingAuthError (refresh_token_revoked); no token leak", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(JSON.stringify({ error: "invalid_grant" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });

    await expect(
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
    ).rejects.toBeInstanceOf(OpenBankingAuthError);
    try {
      await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    } catch (e) {
      expect((e as Error).message).not.toContain(FIXTURE_TOKENS.refresh_token);
    }
  });

  it("refreshTokens: consent within 7-day blocking window REFUSES refresh (PSD2 hard stop)", async () => {
    const config = makeConfig(token_file);
    const nearExpiry: OpenBankingTokens = {
      ...FIXTURE_TOKENS,
      consent_expires_at_ms: Date.now() + 3 * DAY_MS, // 3 days = blocking
    };
    const fakeFetch = async (): Promise<Response> =>
      new Response(REFRESH_OK_BODY, { status: 200 });
    await expect(
      refreshTokens(config, nearExpiry, fakeFetch as typeof fetch),
    ).rejects.toBeInstanceOf(OpenBankingConsentExpiredError);
  });

  it("refreshTokens: concurrent calls (same provider+connection) converge on ONE network call", async () => {
    const config = makeConfig(token_file);
    let calls = 0;
    const fakeFetch = async (): Promise<Response> => {
      calls += 1;
      await new Promise((r) => setTimeout(r, 25));
      return new Response(REFRESH_OK_BODY, {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    };

    const [a, b, c] = await Promise.all([
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
    ]);
    expect(calls).toBe(1);
    expect(a.access_token).toBe(b.access_token);
    expect(b.access_token).toBe(c.access_token);
  });

  it("refreshTokens: Plaid UK provider throws NotImplementedError (v1.1+ deferred)", async () => {
    const config = makeConfig(token_file, { provider: "plaid_uk" });
    await expect(
      refreshTokens(config, FIXTURE_TOKENS, fetch),
    ).rejects.toBeInstanceOf(NotImplementedError);
  });
});
