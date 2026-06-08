// QuickBooks LIVE capability tests — gated by MCP_LIVE_TESTS=1 (skipped otherwise).
//
// Honest-signal pattern per review-mcp-connector §10 + README §Live tests:
// these exercise the real QuickBooks Online sandbox API and only run when
// MCP_LIVE_TESTS=1 AND a token bundle exists on disk (minted once by
// scripts/bootstrap-qb-oauth.sh). Under the normal `pnpm test` fixture run the
// whole suite is SKIPPED — never a no-op pass, so the fixture passed-count
// stays honest.
//
// PATH A: client_id/secret + realm come from process.env (sourced by the
// `test:live` script from _secrets.env); tokens come from the vault file. No
// credential value is ever inlined here or printed by these tests.

import { describe, it, expect, beforeAll } from "vitest";
import { homedir } from "node:os";
import { join } from "node:path";
import {
  QbClient,
  refreshTokens,
  loadTokens,
  listOpenInvoices,
  getInvoice,
} from "../src/index.js";
import type { QbOAuthConfig, QbInvoice } from "../src/index.js";

const LIVE = !!process.env.MCP_LIVE_TESTS;
const TOKEN_DIR =
  process.env.IFOS_TOKEN_DIR ??
  join(homedir(), ".ifos-local-vault", "dev-sandbox");
const TOKEN_FILE = join(TOKEN_DIR, "qb-tokens.json");

describe.skipIf(!LIVE)("@ifos/quickbooks LIVE (MCP_LIVE_TESTS=1)", () => {
  let config: QbOAuthConfig;
  let openInvoices: QbInvoice[] = [];

  beforeAll(async () => {
    const client_id = process.env.QB_CLIENT_ID;
    const client_secret = process.env.QB_CLIENT_SECRET;
    const realm_id = process.env.QB_SANDBOX_REALM_ID;
    if (!client_id || !client_secret || !realm_id) {
      throw new Error(
        "QB_CLIENT_ID / QB_CLIENT_SECRET / QB_SANDBOX_REALM_ID not in env. Run via " +
          "`pnpm --filter @ifos/quickbooks test:live` (it sources _secrets.env) — never inline the values.",
      );
    }
    config = {
      client_id,
      client_secret,
      realm_id,
      environment: "sandbox",
      token_file_path: TOKEN_FILE,
    };
    const onDisk = await loadTokens(config);
    if (!onDisk) {
      throw new Error(
        `No valid token bundle at ${TOKEN_FILE}. Run the one-time dance first:\n` +
          "  bash packages/mcp-connectors/quickbooks/scripts/bootstrap-qb-oauth.sh",
      );
    }
  });

  it("refreshTokens rotates the access_token against oauth.platform.intuit.com", async () => {
    const current = await loadTokens(config);
    expect(current).not.toBeNull();
    const rotated = await refreshTokens(config, current!, fetch);
    expect(typeof rotated.access_token).toBe("string");
    expect(rotated.access_token.length).toBeGreaterThan(0);
    expect(rotated.expires_at_ms).toBeGreaterThan(Date.now());
    expect(rotated.refresh_token_expires_at_ms).toBeGreaterThan(Date.now());
  });

  it("listOpenInvoices returns invoices with Balance > 0", async () => {
    const client = new QbClient({ config });
    openInvoices = await listOpenInvoices(client, { no_cache: true });
    expect(Array.isArray(openInvoices)).toBe(true);
    for (const inv of openInvoices) {
      expect(typeof inv.Id).toBe("string");
      expect(inv.Balance).toBeGreaterThan(0);
    }
  });

  it("getInvoice fetches a single invoice by Id", async () => {
    const client = new QbClient({ config });
    // The QB sandbox company ships with sample invoices. Prefer an open one;
    // if the filtered list is empty, fall back to the first invoice from an
    // unfiltered query so the capability is still exercised against real data.
    let probeId = openInvoices[0]?.Id;
    if (!probeId) {
      const res = await client.request<{ QueryResponse: { Invoice?: QbInvoice[] } }>(
        "/query",
        { query: { query: "SELECT * FROM Invoice STARTPOSITION 1 MAXRESULTS 1" } },
      );
      probeId = res.QueryResponse.Invoice?.[0]?.Id;
    }
    expect(probeId, "QuickBooks sandbox has no invoices to probe").toBeTruthy();
    const inv = await getInvoice(client, probeId!, { no_cache: true });
    expect(inv).not.toBeNull();
    expect(inv!.Id).toBe(probeId);
  });
});
