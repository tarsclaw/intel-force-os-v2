// Open Banking (TrueLayer) LIVE capability tests — gated by MCP_LIVE_TESTS=1.
//
// Honest-signal pattern per review-mcp-connector §10 + README §Live tests:
// these exercise the real TrueLayer SANDBOX API against the Mock Bank and only
// run when MCP_LIVE_TESTS=1 AND a token bundle exists on disk (minted once by
// scripts/bootstrap-ob-oauth.sh). Under the normal `pnpm test` fixture run the
// whole suite is SKIPPED — never a no-op pass, so the fixture passed-count
// stays honest.
//
// PATH A: client_id/secret come from process.env (sourced by the `test:live`
// script from _secrets.env); tokens + the linked account_id come from the vault
// files. No credential value is ever inlined here or printed by these tests.

import { describe, it, expect, beforeAll } from "vitest";
import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import {
  OpenBankingClient,
  refreshTokens,
  loadTokens,
  listTransactionsSince,
  getAccountBalance,
} from "../src/index.js";
import type { OpenBankingConfig } from "../src/index.js";

const LIVE = !!process.env.MCP_LIVE_TESTS;
const TOKEN_DIR =
  process.env.IFOS_TOKEN_DIR ??
  join(homedir(), ".ifos-local-vault", "dev-sandbox");
const TOKEN_FILE = join(TOKEN_DIR, "ob-tokens.json");
const ACCOUNT_FILE = join(TOKEN_DIR, "ob-account.json");

describe.skipIf(!LIVE)("@ifos/open-banking LIVE (MCP_LIVE_TESTS=1)", () => {
  let config: OpenBankingConfig;

  beforeAll(async () => {
    const client_id = process.env.TRUELAYER_CLIENT_ID;
    const client_secret = process.env.TRUELAYER_CLIENT_SECRET;
    if (!client_id || !client_secret) {
      throw new Error(
        "TRUELAYER_CLIENT_ID / TRUELAYER_CLIENT_SECRET not in env. Run via " +
          "`pnpm --filter @ifos/open-banking test:live` (it sources _secrets.env) — never inline the values.",
      );
    }
    let connection_id: string;
    try {
      const raw = await fs.readFile(ACCOUNT_FILE, "utf8");
      connection_id = (JSON.parse(raw) as { connection_id: string }).connection_id;
    } catch {
      throw new Error(
        `No ${ACCOUNT_FILE}. Run the one-time dance first:\n` +
          "  bash packages/mcp-connectors/open-banking/scripts/bootstrap-ob-oauth.sh",
      );
    }
    config = {
      provider: "truelayer",
      client_id,
      client_secret,
      connection_id,
      environment: "sandbox",
      token_file_path: TOKEN_FILE,
    };
    const onDisk = await loadTokens(config);
    if (!onDisk) {
      throw new Error(
        `No valid token bundle at ${TOKEN_FILE}. Run bootstrap-ob-oauth.sh first.`,
      );
    }
  });

  it("refreshTokens rotates the access_token against auth.truelayer-sandbox.com", async () => {
    const current = await loadTokens(config);
    expect(current).not.toBeNull();
    const rotated = await refreshTokens(config, current!, fetch);
    expect(typeof rotated.access_token).toBe("string");
    expect(rotated.access_token.length).toBeGreaterThan(0);
    expect(rotated.expires_at_ms).toBeGreaterThan(Date.now());
    // TrueLayer does not extend PSD2 consent on refresh — it is preserved.
    expect(rotated.consent_expires_at_ms).toBe(current!.consent_expires_at_ms);
  });

  it("listTransactionsSince returns provider-agnostic transactions for the Mock Bank account", async () => {
    const client = new OpenBankingClient({ config });
    const since = new Date(Date.now() - 89 * 24 * 60 * 60 * 1000).toISOString();
    const txns = await listTransactionsSince(client, config, { since, no_cache: true });
    expect(Array.isArray(txns)).toBe(true);
    for (const t of txns) {
      expect(typeof t.transaction_id).toBe("string");
      expect(typeof t.amount).toBe("number");
      expect(typeof t.currency).toBe("string");
      expect(typeof t.posted_at).toBe("string");
    }
  });

  it("getAccountBalance returns available/current/currency for the Mock Bank account", async () => {
    const client = new OpenBankingClient({ config });
    const balance = await getAccountBalance(client, config);
    expect(typeof balance.available).toBe("number");
    expect(typeof balance.current).toBe("number");
    expect(typeof balance.currency).toBe("string");
    expect(balance.currency.length).toBeGreaterThan(0);
    expect(typeof balance.fetched_at).toBe("string");
  });
});
