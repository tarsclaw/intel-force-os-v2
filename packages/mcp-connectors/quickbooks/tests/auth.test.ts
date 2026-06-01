// OAuth tests per review-mcp-connector §2 (idempotency + atomic file
// write + concurrent-safety test).

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import {
  _resetInflightForTest,
  loadTokens,
  refreshTokens,
  refreshTokenNearExpiry,
  saveTokens,
  shouldRefresh,
} from "../src/auth.js";
import { QbAuthError } from "../src/errors.js";
import type { QbOAuthConfig, QbTokens } from "../src/types.js";

const FIXTURE_TOKENS: QbTokens = {
  access_token: "fake-access-old",
  refresh_token: "fake-refresh-old",
  expires_at_ms: Date.now() + 3600_000,
  refresh_token_expires_at_ms: Date.now() + 100 * 24 * 60 * 60 * 1000,
  scope: "com.intuit.quickbooks.accounting",
  token_type: "Bearer",
};

const REFRESH_OK_BODY = JSON.stringify({
  access_token: "fake-new-access-abcdef123456",
  refresh_token: "fake-new-refresh-zyxwvu987654",
  expires_in: 3600,
  x_refresh_token_expires_in: 100 * 24 * 60 * 60,
  scope: "com.intuit.quickbooks.accounting",
  token_type: "Bearer",
});

function makeConfig(token_file: string, realm_id = "test-realm-id"): QbOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    realm_id,
    environment: "sandbox",
    token_file_path: token_file,
  };
}

let token_file: string;

beforeEach(() => {
  token_file = join(
    tmpdir(),
    `qb-tokens-test-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
  _resetInflightForTest();
});
afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
});

describe("quickbooks auth", () => {
  it("loadTokens returns null when file missing", async () => {
    const config = makeConfig(token_file);
    expect(await loadTokens(config)).toBeNull();
  });

  it("save + load round-trips token bundle", async () => {
    const config = makeConfig(token_file);
    await saveTokens(config, FIXTURE_TOKENS);
    const loaded = await loadTokens(config);
    expect(loaded).toEqual(FIXTURE_TOKENS);
  });

  it("shouldRefresh: true if within 5-min safety window", () => {
    const expiringSoon: QbTokens = {
      ...FIXTURE_TOKENS,
      expires_at_ms: Date.now() + 60_000,
    };
    expect(shouldRefresh(expiringSoon)).toBe(true);
  });

  it("refreshTokenNearExpiry: true when refresh token within 7-day danger window", () => {
    const danger: QbTokens = {
      ...FIXTURE_TOKENS,
      refresh_token_expires_at_ms: Date.now() + 24 * 60 * 60 * 1000,
    };
    expect(refreshTokenNearExpiry(danger)).toBe(true);
    expect(refreshTokenNearExpiry(FIXTURE_TOKENS)).toBe(false);
  });

  it("refreshTokens: success writes new tokens atomically + returns them", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(REFRESH_OK_BODY, {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });

    const newT = await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    expect(newT.access_token).toBe("fake-new-access-abcdef123456");
    expect(newT.refresh_token).toBe("fake-new-refresh-zyxwvu987654");
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(newT.access_token);
    expect(onDisk?.refresh_token_expires_at_ms).toBeGreaterThan(Date.now());
  });

  it("refreshTokens: 401 surfaces as QbAuthError; does NOT include token in error", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(
        JSON.stringify({ error: "invalid_grant" }),
        { status: 401, headers: { "Content-Type": "application/json" } },
      );

    await expect(
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
    ).rejects.toBeInstanceOf(QbAuthError);
    try {
      await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    } catch (e) {
      const msg = (e as Error).message;
      expect(msg).not.toContain(FIXTURE_TOKENS.refresh_token);
    }
  });

  it("refreshTokens: concurrent calls converge on ONE network call (idempotent dedup)", async () => {
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
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(a.access_token);
  });
});
