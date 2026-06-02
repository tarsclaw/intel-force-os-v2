// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
// path + ≥1 error path per capability). Plaid UK NotImplementedError path
// covered for both capabilities.

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { OpenBankingClient } from "../src/client.js";
import { OpenBankingCache } from "../src/cache.js";
import { saveTokens, _resetInflightForTest } from "../src/auth.js";
import { reset as resetRateLimit } from "../src/rate-limit.js";
import { listTransactionsSince } from "../src/transactions.js";
import { getAccountBalance } from "../src/balance.js";
import {
  NotImplementedError,
  OpenBankingError,
  OpenBankingRateLimitError,
} from "../src/errors.js";
import type {
  OpenBankingConfig,
  OpenBankingTokens,
} from "../src/types.js";

import TL_TRANSACTIONS from "../fixtures/truelayer-transactions.json" with { type: "json" };
import TL_BALANCE from "../fixtures/truelayer-balance.json" with { type: "json" };

const DAY_MS = 24 * 60 * 60 * 1000;

const FIXTURE_TOKENS: OpenBankingTokens = {
  access_token: "tl-access",
  refresh_token: "tl-refresh",
  expires_at_ms: Date.now() + 3600_000,
  consent_expires_at_ms: Date.now() + 60 * DAY_MS,
  scope: "accounts transactions balance",
  token_type: "Bearer",
};

let token_file: string;
let cache_dir: string;
let cache: OpenBankingCache;

function makeConfig(
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

function makeOkResponse(body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

beforeEach(async () => {
  token_file = join(
    tmpdir(),
    `ob-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
  cache_dir = join(
    tmpdir(),
    `ob-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`,
  );
  cache = new OpenBankingCache(cache_dir);
  _resetInflightForTest();
  resetRateLimit();
  await saveTokens(makeConfig(), FIXTURE_TOKENS);
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
});

describe("open-banking capabilities — TrueLayer (v1.0)", () => {
  it("listTransactionsSince: returns provider-agnostic OpenBankingTransaction[] from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(TL_TRANSACTIONS);
    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    const txns = await listTransactionsSince(client, config, {
      since: "2026-05-01T00:00:00Z",
      cache,
      no_cache: true,
    });
    expect(txns.length).toBe(3);
    expect(txns[0]?.transaction_id).toBe("tl-tx-aaa-111");
    expect(txns[0]?.amount).toBe(2000);
    expect(txns[0]?.reference).toBe("BACS-2026-05-20-001");
    // Debit transaction preserves negative amount
    expect(txns[2]?.amount).toBe(-85.5);
    // raw_provider_payload preserved
    expect(txns[0]?.raw_provider_payload.transaction_id).toBe("tl-tx-aaa-111");
  });

  it("getAccountBalance: returns OpenBankingBalance with available + current + currency", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(TL_BALANCE);
    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    const bal = await getAccountBalance(client, config);
    expect(bal.available).toBe(47823.55);
    expect(bal.current).toBe(47909.05);
    expect(bal.currency).toBe("GBP");
    expect(bal.fetched_at).toBe("2026-06-01T08:30:00Z");
  });

  // Error-path coverage for listTransactionsSince + getAccountBalance per
  // Codex F-R2 issue #3 (open-banking): review-mcp-connector §6 requires
  // ≥1 happy + ≥1 error fixture per capability. R1 wrongly assumed the Plaid
  // NotImplementedError test counted as the error path; Codex correctly
  // distinguishes "stub-throws-on-unsupported-provider" from "TrueLayer
  // upstream returns error".
  it("listTransactionsSince: persistent 429 surfaces as OpenBankingRateLimitError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("", {
        status: 429,
        headers: { "Retry-After": "0" },
      });
    };
    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    await expect(
      listTransactionsSince(client, config, {
        since: "2026-05-01T00:00:00Z",
        cache,
        no_cache: true,
      }),
    ).rejects.toBeInstanceOf(OpenBankingRateLimitError);
    expect(calls).toBeGreaterThanOrEqual(2);
  });

  it("getAccountBalance: persistent 500 surfaces as OpenBankingError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("TrueLayer internal error", { status: 500 });
    };
    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    await expect(getAccountBalance(client, config)).rejects.toBeInstanceOf(
      OpenBankingError,
    );
    expect(calls).toBeGreaterThanOrEqual(2);
  });

  // 401-forces-refresh: per Codex F-R2 issue #2 (open-banking), a 401 on a GET
  // MUST trigger an explicit refreshTokens() call before retrying, AND on final
  // exhaustion throw OpenBankingAuthError (not the generic OpenBankingError).
  it("401 on GET forces explicit token refresh + retry uses new access_token", async () => {
    let getCalls = 0;
    let refreshCalls = 0;
    let observedSecondAuth: string | null = null;

    const fakeFetch: typeof fetch = async (input, init) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      if (url.includes("auth.truelayer-sandbox.com/connect/token")) {
        refreshCalls += 1;
        return new Response(
          JSON.stringify({
            access_token: "rotated-access-token-after-401",
            refresh_token: "rotated-refresh-token",
            expires_in: 3600,
            scope: "accounts transactions balance",
            token_type: "Bearer",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      // Data GET path
      getCalls += 1;
      if (getCalls === 1) {
        return new Response("", { status: 401 });
      }
      observedSecondAuth = (init?.headers as Record<string, string>)?.["Authorization"] ?? null;
      return makeOkResponse(TL_TRANSACTIONS);
    };

    const config = makeConfig();
    const client = new OpenBankingClient({ config, fetchFn: fakeFetch });
    const txns = await listTransactionsSince(client, config, {
      since: "2026-05-01T00:00:00Z",
      cache,
      no_cache: true,
    });

    expect(txns.length).toBeGreaterThan(0);
    expect(getCalls).toBe(2);
    expect(refreshCalls).toBe(1);
    expect(observedSecondAuth).toBe("Bearer rotated-access-token-after-401");
  });
});

describe("open-banking capabilities — Plaid UK (v1.1+ deferred)", () => {
  it("listTransactionsSince throws NotImplementedError for Plaid UK", async () => {
    const config = makeConfig({ provider: "plaid_uk" });
    const client = new OpenBankingClient({ config });
    await expect(
      listTransactionsSince(client, config, { since: "2026-05-01T00:00:00Z" }),
    ).rejects.toBeInstanceOf(NotImplementedError);
  });

  it("getAccountBalance throws NotImplementedError for Plaid UK", async () => {
    const config = makeConfig({ provider: "plaid_uk" });
    const client = new OpenBankingClient({ config });
    await expect(getAccountBalance(client, config)).rejects.toBeInstanceOf(
      NotImplementedError,
    );
  });
});
