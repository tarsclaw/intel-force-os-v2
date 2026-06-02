// Auth tests per review-mcp-connector §2 (OAuth refresh idempotency).
// Bullhorn-specific: tests cover BOTH Step A (OAuth refresh) AND Step B
// (REST login) of the two-step refresh; concurrent dedup is per corporation_id.

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";

import {
  _resetInflightForTest,
  BULLHORN_REST_LOGIN_URL,
  BullhornAuthError,
  loadTokens,
  refreshTokens,
  saveTokens,
  shouldRefresh,
} from "../src/index.js";
import type { BullhornOAuthConfig, BullhornTokens } from "../src/index.js";

let token_file: string;

function makeConfig(): BullhornOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    corporation_id: "test-corp-auth",
    region: "east",
    token_file_path: token_file,
  };
}

function makeTokens(overrides: Partial<BullhornTokens> = {}): BullhornTokens {
  return {
    oauth_access_token: "oauth-fake-access",
    oauth_refresh_token: "oauth-fake-refresh",
    oauth_expires_at_ms: Date.now() + 600_000,
    scope: "all",
    token_type: "Bearer",
    bh_rest_token: "bhrest-fake",
    rest_url: "https://rest9.bullhornstaffing.com/rest-services/fakeCorp/",
    bh_rest_token_expires_at_ms: Date.now() + 600_000,
    ...overrides,
  };
}

beforeEach(() => {
  token_file = join(tmpdir(), `bullhorn-auth-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`);
  _resetInflightForTest();
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
});

describe("bullhorn auth — token file I/O", () => {
  it("loadTokens returns null when file is missing", async () => {
    const tokens = await loadTokens(makeConfig());
    expect(tokens).toBeNull();
  });

  it("saveTokens → loadTokens round-trips the full BullhornTokens shape", async () => {
    const t = makeTokens();
    await saveTokens(makeConfig(), t);
    const loaded = await loadTokens(makeConfig());
    expect(loaded).toEqual(t);
  });

  it("shouldRefresh returns true when EITHER OAuth or BhRestToken expires within window", () => {
    const fixed_now = 1_000_000_000_000;
    // OAuth fresh but BhRestToken near expiry
    const tBhExpiring = makeTokens({
      oauth_expires_at_ms: fixed_now + 10 * 60 * 1000,
      bh_rest_token_expires_at_ms: fixed_now + 30 * 1000, // 30s away
    });
    expect(shouldRefresh(tBhExpiring, () => fixed_now, 90 * 1000)).toBe(true);
    // Both fresh
    const tBothFresh = makeTokens({
      oauth_expires_at_ms: fixed_now + 10 * 60 * 1000,
      bh_rest_token_expires_at_ms: fixed_now + 10 * 60 * 1000,
    });
    expect(shouldRefresh(tBothFresh, () => fixed_now, 90 * 1000)).toBe(false);
  });
});

describe("bullhorn auth — two-step refresh (Step A + Step B)", () => {
  it("refreshTokens performs Step A (OAuth) THEN Step B (REST login) and persists", async () => {
    const calls: { url: string; method: string }[] = [];
    const fakeFetch: typeof fetch = async (input, init) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      calls.push({ url, method: init?.method ?? "GET" });
      if (url.startsWith("https://auth-east.bullhornstaffing.com/oauth/token")) {
        return new Response(
          JSON.stringify({
            access_token: "new-oauth-access",
            refresh_token: "new-oauth-refresh",
            expires_in: 600,
            scope: "all",
            token_type: "Bearer",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      if (url.startsWith(BULLHORN_REST_LOGIN_URL)) {
        return new Response(
          JSON.stringify({
            BhRestToken: "new-bhrest-token",
            restUrl: "https://rest9.bullhornstaffing.com/rest-services/newCorp/",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      throw new Error(`Unexpected URL in fake fetch: ${url}`);
    };

    const current = makeTokens();
    await saveTokens(makeConfig(), current);
    const result = await refreshTokens(makeConfig(), current, fakeFetch);

    expect(calls).toHaveLength(2);
    expect(calls[0]?.method).toBe("POST"); // Step A is POST
    expect(calls[0]?.url).toContain("auth-east.bullhornstaffing.com");
    expect(calls[1]?.method).toBe("GET"); // Step B is GET
    expect(calls[1]?.url).toContain("rest-services/login");
    expect(calls[1]?.url).toContain("access_token=new-oauth-access");

    expect(result.oauth_access_token).toBe("new-oauth-access");
    expect(result.oauth_refresh_token).toBe("new-oauth-refresh");
    expect(result.bh_rest_token).toBe("new-bhrest-token");
    expect(result.rest_url).toBe(
      "https://rest9.bullhornstaffing.com/rest-services/newCorp/",
    );

    // Persisted to disk
    const onDisk = await loadTokens(makeConfig());
    expect(onDisk?.bh_rest_token).toBe("new-bhrest-token");
  });

  it("refreshTokens throws BullhornAuthError on Step A failure WITHOUT leaking credentials", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response(JSON.stringify({ error: "invalid_grant" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });

    await expect(
      refreshTokens(makeConfig(), makeTokens(), fakeFetch),
    ).rejects.toBeInstanceOf(BullhornAuthError);

    // Verify error message does NOT contain the refresh_token or client_secret
    try {
      await refreshTokens(makeConfig(), makeTokens(), fakeFetch);
    } catch (e) {
      const msg = (e as Error).message;
      expect(msg).not.toContain("fake-client-secret");
      expect(msg).not.toContain("oauth-fake-refresh");
    }
  });

  it("refreshTokens throws BullhornAuthError on Step B failure", async () => {
    const fakeFetch: typeof fetch = async (input) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      if (url.startsWith("https://auth-east.bullhornstaffing.com")) {
        return new Response(
          JSON.stringify({
            access_token: "new-access",
            refresh_token: "new-refresh",
            expires_in: 600,
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      // Step B fails
      return new Response("", { status: 500 });
    };

    await expect(
      refreshTokens(makeConfig(), makeTokens(), fakeFetch),
    ).rejects.toBeInstanceOf(BullhornAuthError);
  });

  it("concurrent refreshTokens() calls converge on ONE rotation (in-process dedup per corporation_id)", async () => {
    let stepACount = 0;
    let stepBCount = 0;
    const fakeFetch: typeof fetch = async (input) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      if (url.startsWith("https://auth-east.bullhornstaffing.com")) {
        stepACount += 1;
        // Add a microtask delay to ensure concurrent overlap
        await new Promise((r) => setTimeout(r, 5));
        return new Response(
          JSON.stringify({
            access_token: "concurrent-access",
            refresh_token: "concurrent-refresh",
            expires_in: 600,
            scope: "all",
            token_type: "Bearer",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      if (url.startsWith(BULLHORN_REST_LOGIN_URL)) {
        stepBCount += 1;
        return new Response(
          JSON.stringify({
            BhRestToken: "concurrent-bhrest",
            restUrl: "https://rest.bullhornstaffing.com/rest-services/concurrent/",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      throw new Error(`Unexpected URL: ${url}`);
    };

    const current = makeTokens();
    await saveTokens(makeConfig(), current);

    // Fire 3 concurrent refresh calls — should converge on ONE Step A + ONE Step B
    const results = await Promise.all([
      refreshTokens(makeConfig(), current, fakeFetch),
      refreshTokens(makeConfig(), current, fakeFetch),
      refreshTokens(makeConfig(), current, fakeFetch),
    ]);

    expect(stepACount).toBe(1);
    expect(stepBCount).toBe(1);
    // All 3 callers received the same token bundle
    expect(results[0]).toEqual(results[1]);
    expect(results[1]).toEqual(results[2]);
  });
});
