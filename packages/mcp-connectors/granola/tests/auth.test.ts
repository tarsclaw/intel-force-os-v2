// Auth tests per review-mcp-connector §2 (OAuth refresh idempotency).
// Granola-specific: PKCE pair generator + token round-trip + concurrent
// dedup per workspace_id + no-leak-on-401.

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";

import {
  GranolaAuthError,
  _resetInflightForTest,
  generatePkcePair,
  loadTokens,
  refreshTokens,
  saveTokens,
  shouldRefresh,
} from "../src/index.js";
import type { GranolaConfig, GranolaTokens } from "../src/index.js";

let token_file: string;

function makeConfig(): GranolaConfig {
  return {
    client_id: "fake-client-id",
    workspace_id: "ws-test-auth",
    token_file_path: token_file,
  };
}

function makeTokens(overrides: Partial<GranolaTokens> = {}): GranolaTokens {
  return {
    access_token: "fake-access",
    refresh_token: "fake-refresh",
    expires_at_ms: Date.now() + 600_000,
    scope: "meetings:read transcripts:read",
    token_type: "Bearer",
    ...overrides,
  };
}

beforeEach(() => {
  token_file = join(
    tmpdir(),
    `granola-auth-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
  _resetInflightForTest();
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
});

describe("granola auth — PKCE pair generation", () => {
  it("generatePkcePair returns matching verifier + S256 challenge with valid lengths", () => {
    const pair = generatePkcePair();
    // RFC 7636 §4.1: verifier MUST be 43-128 chars
    expect(pair.code_verifier.length).toBeGreaterThanOrEqual(43);
    expect(pair.code_verifier.length).toBeLessThanOrEqual(128);
    // base64url(SHA256(...)) is 43 chars
    expect(pair.code_challenge.length).toBe(43);
    // Verifier + challenge MUST NOT match (challenge is the SHA-256 hash)
    expect(pair.code_challenge).not.toBe(pair.code_verifier);
  });

  it("generatePkcePair returns different pairs on each call (random)", () => {
    const a = generatePkcePair();
    const b = generatePkcePair();
    expect(a.code_verifier).not.toBe(b.code_verifier);
    expect(a.code_challenge).not.toBe(b.code_challenge);
  });
});

describe("granola auth — token file I/O", () => {
  it("loadTokens returns null when file is missing", async () => {
    const tokens = await loadTokens(makeConfig());
    expect(tokens).toBeNull();
  });

  it("saveTokens → loadTokens round-trips the full GranolaTokens shape", async () => {
    const t = makeTokens();
    await saveTokens(makeConfig(), t);
    const loaded = await loadTokens(makeConfig());
    expect(loaded).toEqual(t);
  });

  it("shouldRefresh returns true when access_token expires within window", () => {
    const fixed_now = 1_000_000_000_000;
    const tExpiring = makeTokens({ expires_at_ms: fixed_now + 30 * 1000 }); // 30s
    expect(shouldRefresh(tExpiring, () => fixed_now, 120 * 1000)).toBe(true);
    const tFresh = makeTokens({ expires_at_ms: fixed_now + 10 * 60 * 1000 });
    expect(shouldRefresh(tFresh, () => fixed_now, 120 * 1000)).toBe(false);
  });
});

describe("granola auth — refresh", () => {
  it("refreshTokens performs POST and persists new tokens", async () => {
    const calls: { url: string; method: string; body: string }[] = [];
    const fakeFetch: typeof fetch = async (input, init) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      const body = init?.body instanceof URLSearchParams ? init.body.toString() : "";
      calls.push({ url, method: init?.method ?? "GET", body });
      return new Response(
        JSON.stringify({
          access_token: "new-access",
          refresh_token: "new-refresh",
          expires_in: 3600,
          scope: "meetings:read transcripts:read",
          token_type: "Bearer",
        }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    };

    const current = makeTokens();
    await saveTokens(makeConfig(), current);
    const result = await refreshTokens(makeConfig(), current, fakeFetch);

    expect(calls).toHaveLength(1);
    expect(calls[0]?.method).toBe("POST");
    expect(calls[0]?.url).toContain("api.granola.ai/oauth/token");
    expect(calls[0]?.body).toContain("grant_type=refresh_token");
    expect(calls[0]?.body).toContain("client_id=fake-client-id");

    expect(result.access_token).toBe("new-access");
    expect(result.refresh_token).toBe("new-refresh");

    const onDisk = await loadTokens(makeConfig());
    expect(onDisk?.access_token).toBe("new-access");
  });

  it("refreshTokens throws GranolaAuthError on 4xx WITHOUT leaking credentials", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response(JSON.stringify({ error: "invalid_grant" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });

    await expect(
      refreshTokens(makeConfig(), makeTokens(), fakeFetch),
    ).rejects.toBeInstanceOf(GranolaAuthError);

    try {
      await refreshTokens(makeConfig(), makeTokens(), fakeFetch);
    } catch (e) {
      const msg = (e as Error).message;
      expect(msg).not.toContain("fake-refresh");
      expect(msg).not.toContain("fake-access");
    }
  });

  it("refreshTokens persists rotated refresh_token when server returns a new one", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response(
        JSON.stringify({
          access_token: "rotated-access",
          refresh_token: "rotated-refresh",
          expires_in: 3600,
        }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    const current = makeTokens();
    const result = await refreshTokens(makeConfig(), current, fakeFetch);
    expect(result.refresh_token).toBe("rotated-refresh");
  });

  it("refreshTokens preserves existing refresh_token when server omits it", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response(
        JSON.stringify({
          access_token: "new-access",
          expires_in: 3600,
        }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    const current = makeTokens();
    const result = await refreshTokens(makeConfig(), current, fakeFetch);
    expect(result.refresh_token).toBe(current.refresh_token);
  });

  it("concurrent refreshTokens() calls converge on ONE rotation (in-process dedup per workspace_id)", async () => {
    let callCount = 0;
    const fakeFetch: typeof fetch = async () => {
      callCount += 1;
      // Add a microtask delay to ensure concurrent overlap
      await new Promise((r) => setTimeout(r, 5));
      return new Response(
        JSON.stringify({
          access_token: "concurrent-access",
          refresh_token: "concurrent-refresh",
          expires_in: 3600,
        }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    };

    const current = makeTokens();
    await saveTokens(makeConfig(), current);

    const results = await Promise.all([
      refreshTokens(makeConfig(), current, fakeFetch),
      refreshTokens(makeConfig(), current, fakeFetch),
      refreshTokens(makeConfig(), current, fakeFetch),
    ]);

    expect(callCount).toBe(1);
    expect(results[0]).toEqual(results[1]);
    expect(results[1]).toEqual(results[2]);
  });
});
