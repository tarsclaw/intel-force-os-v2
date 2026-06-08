// Xero LIVE capability tests — gated by MCP_LIVE_TESTS=1 (skipped otherwise).
//
// Honest-signal pattern per review-mcp-connector §10 + README §Live tests:
// these exercise the real Xero API against the Demo Company sandbox and only
// run when MCP_LIVE_TESTS=1 AND a token bundle exists on disk (minted once by
// scripts/bootstrap-xero-oauth.sh). Under the normal `pnpm test` fixture run
// the whole suite is SKIPPED — it is never a no-op pass, so the fixture
// passed-count stays honest.
//
// PATH A: client_id/secret come from process.env (sourced by the `test:live`
// script from _secrets.env); tokens come from the vault file. No credential
// value is ever inlined here or printed by these tests.

import { describe, it, expect, beforeAll } from "vitest";
import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import {
  XeroClient,
  refreshTokens,
  loadTokens,
  listOpenInvoices,
  getInvoice,
} from "../src/index.js";
import type { XeroOAuthConfig, XeroInvoice } from "../src/index.js";

const LIVE = !!process.env.MCP_LIVE_TESTS;
const TOKEN_DIR =
  process.env.IFOS_TOKEN_DIR ??
  join(homedir(), ".ifos-local-vault", "dev-sandbox");
const TOKEN_FILE = join(TOKEN_DIR, "xero-tokens.json");
const TENANT_FILE = join(TOKEN_DIR, "xero-tenant.json");

describe.skipIf(!LIVE)("@ifos/xero LIVE (MCP_LIVE_TESTS=1)", () => {
  let config: XeroOAuthConfig;
  let openInvoices: XeroInvoice[] = [];

  beforeAll(async () => {
    const client_id = process.env.XERO_CLIENT_ID;
    const client_secret = process.env.XERO_CLIENT_SECRET;
    if (!client_id || !client_secret) {
      throw new Error(
        "XERO_CLIENT_ID / XERO_CLIENT_SECRET not in env. Run via " +
          "`pnpm --filter @ifos/xero test:live` (it sources _secrets.env) — never inline the values.",
      );
    }
    let tenant_id: string;
    try {
      const raw = await fs.readFile(TENANT_FILE, "utf8");
      tenant_id = (JSON.parse(raw) as { tenant_id: string }).tenant_id;
    } catch {
      throw new Error(
        `No ${TENANT_FILE}. Run the one-time dance first:\n` +
          "  bash packages/mcp-connectors/xero/scripts/bootstrap-xero-oauth.sh",
      );
    }
    config = { client_id, client_secret, tenant_id, token_file_path: TOKEN_FILE };
    const onDisk = await loadTokens(config);
    if (!onDisk) {
      throw new Error(
        `No valid token bundle at ${TOKEN_FILE}. Run bootstrap-xero-oauth.sh first.`,
      );
    }
  });

  it("refreshTokens rotates the access_token against identity.xero.com", async () => {
    const current = await loadTokens(config);
    expect(current).not.toBeNull();
    const rotated = await refreshTokens(config, current!, fetch);
    expect(typeof rotated.access_token).toBe("string");
    expect(rotated.access_token.length).toBeGreaterThan(0);
    expect(rotated.expires_at_ms).toBeGreaterThan(Date.now());
  });

  it("listOpenInvoices returns AUTHORISED/SUBMITTED invoices with AmountDue > 0", async () => {
    const client = new XeroClient({ config });
    openInvoices = await listOpenInvoices(client, { no_cache: true });
    expect(Array.isArray(openInvoices)).toBe(true);
    for (const inv of openInvoices) {
      expect(typeof inv.InvoiceID).toBe("string");
      expect(inv.AmountDue).toBeGreaterThan(0);
      expect(["AUTHORISED", "SUBMITTED"]).toContain(inv.Status);
    }
  });

  it("getInvoice fetches a single invoice by InvoiceID", async () => {
    const client = new XeroClient({ config });
    // Demo Company reliably carries sample invoices. Prefer an open one; if the
    // filtered list is empty, fall back to the first invoice on an unfiltered
    // page so the capability is still exercised against real data.
    let probeId = openInvoices[0]?.InvoiceID;
    if (!probeId) {
      const page = await client.request<{ Invoices: XeroInvoice[] }>("/Invoices", {
        query: { page: "1" },
      });
      probeId = page.Invoices?.[0]?.InvoiceID;
    }
    expect(probeId, "Xero org has no invoices to probe").toBeTruthy();
    const inv = await getInvoice(client, probeId!, { no_cache: true });
    expect(inv).not.toBeNull();
    expect(inv!.InvoiceID).toBe(probeId);
  });
});
