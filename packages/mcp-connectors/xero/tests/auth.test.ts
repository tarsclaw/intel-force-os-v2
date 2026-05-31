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
  saveTokens,
  shouldRefresh,
} from "../src/auth.js";
import { XeroAuthError } from "../src/errors.js";
import type { XeroOAuthConfig, XeroTokens } from "../src/types.js";

const FIXTURE_TOKENS: XeroTokens = {
  access_token: "fake-access-old",
  refresh_token: "fake-refresh-old",
  expires_at_ms: Date.now() + 1800_000,
  scope: "accounting.transactions offline_access",
  token_type: "Bearer",
};

const REFRESH_OK_BODY = JSON.stringify({
  access_token: "fake-new-access-token-abcdef123456",
  refresh_token: "fake-new-refresh-token-zyxwvu987654",
  expires_in: 1800,
  scope: "accounting.transactions offline_access",
  token_type: "Bearer",
});

function makeConfig(token_file: string, tenant_id = "test-tenant-id"): XeroOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    tenant_id,
    token_file_path: token_file,
  };
}

let token_file: string;

beforeEach(() => {
  token_file = join(tmpdir(), `xero-tokens-test-${process.pid}-${Date.now()}-${Math.random()}.json`);
  _resetInflightForTest();
});
afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
});

describe("xero auth", () => {
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
    const expiringSoon: XeroTokens = { ...FIXTURE_TOKENS, expires_at_ms: Date.now() + 60_000 };
    expect(shouldRefresh(expiringSoon)).toBe(true);
  });

  it("shouldRefresh: false if comfortably ahead of safety window", () => {
    const fresh: XeroTokens = { ...FIXTURE_TOKENS, expires_at_ms: Date.now() + 30 * 60_000 };
    expect(shouldRefresh(fresh)).toBe(false);
  });

  it("refreshTokens: success path writes new tokens atomically + returns them", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(REFRESH_OK_BODY, { status: 200, headers: { "Content-Type": "application/json" } });

    const newT = await refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch);
    expect(newT.access_token).toBe("fake-new-access-token-abcdef123456");
    expect(newT.refresh_token).toBe("fake-new-refresh-token-zyxwvu987654");
    // File now exists with new tokens
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(newT.access_token);
  });

  it("refreshTokens: 401 surfaces as XeroAuthError; does NOT include token in error", async () => {
    const config = makeConfig(token_file);
    const fakeFetch = async (): Promise<Response> =>
      new Response(JSON.stringify({ error: "invalid_grant", error_description: "refresh_token expired" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });

    await expect(refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch)).rejects.toBeInstanceOf(XeroAuthError);
    // Verify the message does NOT leak the refresh_token value
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
      // small delay to ensure overlap
      await new Promise((r) => setTimeout(r, 25));
      return new Response(REFRESH_OK_BODY, { status: 200, headers: { "Content-Type": "application/json" } });
    };

    const [a, b, c] = await Promise.all([
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
      refreshTokens(config, FIXTURE_TOKENS, fakeFetch as typeof fetch),
    ]);
    expect(calls).toBe(1);
    expect(a.access_token).toBe(b.access_token);
    expect(b.access_token).toBe(c.access_token);
    // File written exactly once with the new token
    const onDisk = await loadTokens(config);
    expect(onDisk?.access_token).toBe(a.access_token);
  });
});
