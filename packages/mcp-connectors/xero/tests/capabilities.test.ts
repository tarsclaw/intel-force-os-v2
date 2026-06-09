// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
// path + ≥1 error path per capability).

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { XeroClient } from "../src/client.js";
import { XeroCache } from "../src/cache.js";
import { saveTokens, _resetInflightForTest } from "../src/auth.js";
import { reset as resetRateLimit } from "../src/rate-limit.js";
import { listOpenInvoices, getInvoice } from "../src/invoices.js";
import {
  buildPaymentWriteRequest,
  listPayments,
  writePaymentReceived,
} from "../src/payments.js";
import {
  XeroError,
  XeroNotFoundError,
  XeroRateLimitError,
  XeroValidationError,
} from "../src/errors.js";
import type {
  XeroOAuthConfig,
  XeroTokens,
  XeroPaymentWriteRequest,
} from "../src/types.js";

import INVOICES_PAGE_1 from "../fixtures/invoices-page-1.json" with { type: "json" };
import PAYMENTS_RECENT from "../fixtures/payments-recent.json" with { type: "json" };
import PAYMENT_WRITE_OK from "../fixtures/payment-write-ok.json" with { type: "json" };

const FIXTURE_TOKENS: XeroTokens = {
  access_token: "fake-access",
  refresh_token: "fake-refresh",
  expires_at_ms: Date.now() + 1800_000,
  scope: "accounting.transactions offline_access",
  token_type: "Bearer",
};

let token_file: string;
let cache_dir: string;
let cache: XeroCache;

function makeConfig(): XeroOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    tenant_id: "fixture-tenant",
    token_file_path: token_file,
  };
}

function makeOkResponse(body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

beforeEach(async () => {
  token_file = join(tmpdir(), `xero-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`);
  cache_dir = join(tmpdir(), `xero-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`);
  cache = new XeroCache(cache_dir);
  _resetInflightForTest();
  resetRateLimit();
  await saveTokens(makeConfig(), FIXTURE_TOKENS);
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
});

describe("xero capabilities — invoices", () => {
  it("listOpenInvoices: returns parsed array from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const invoices = await listOpenInvoices(client, { cache, no_cache: true });
    expect(invoices.length).toBe(2);
    expect(invoices[0]?.InvoiceID).toBe("0000aaaa-1111-2222-3333-444455556666");
    expect(invoices[0]?.AmountDue).toBe(1200);
    expect(invoices[1]?.Contact.Name).toBe("Beta Search Partners");
  });

  it("getInvoice: returns single invoice when present", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const inv = await getInvoice(client, "0000aaaa-1111-2222-3333-444455556666", {
      cache,
      no_cache: true,
    });
    expect(inv).not.toBeNull();
    expect(inv?.InvoiceNumber).toBe("INV-0001");
  });

  it("getInvoice: 404 surfaces as XeroNotFoundError", async () => {
    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      getInvoice(client, "00000000-0000-0000-0000-000000000000", { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(XeroNotFoundError);
  });

  // Error-path coverage for listOpenInvoices (per review-mcp-connector §6 +
  // Codex F-R1 issue #4: every capability needs ≥1 happy + ≥1 error fixture).
  it("listOpenInvoices: persistent 429 surfaces as XeroRateLimitError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("", {
        status: 429,
        headers: { "Retry-After": "0" }, // 0s = no wait; just exhausts retries fast
      });
    };
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      listOpenInvoices(client, { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(XeroRateLimitError);
    expect(calls).toBeGreaterThanOrEqual(2); // initial + ≥1 retry per max_retries=2 default for GET
  });
});

describe("xero capabilities — payments", () => {
  it("listPayments: returns parsed array from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENTS_RECENT);
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payments = await listPayments(client, { cache, no_cache: true });
    expect(payments.length).toBe(1);
    expect(payments[0]?.Amount).toBe(2000);
    expect(payments[0]?.PaymentType).toBe("ACCRECPAYMENT");
  });

  it("buildPaymentWriteRequest: maps CLI args → Xero write request (reference omitted when absent)", () => {
    const withRef = buildPaymentWriteRequest({
      invoice: "0000aaaa-1111-2222-3333-444455556666",
      amount: 1200.0,
      date: "2026-05-22",
      account: "090",
      reference: "BACS-2026-05-22-002",
    });
    expect(withRef).toEqual({
      Invoice: { InvoiceID: "0000aaaa-1111-2222-3333-444455556666" },
      Account: { Code: "090" },
      Date: "2026-05-22",
      Amount: 1200.0,
      Reference: "BACS-2026-05-22-002",
    });
    const noRef = buildPaymentWriteRequest({
      invoice: "inv-1",
      amount: 50,
      date: "2026-05-22",
      account: "090",
    });
    expect("Reference" in noRef).toBe(false);
  });

  it("writePaymentReceived: success path returns created payment", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENT_WRITE_OK);
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payload: XeroPaymentWriteRequest = {
      Invoice: { InvoiceID: "0000aaaa-1111-2222-3333-444455556666" },
      Account: { Code: "090" },
      Date: "2026-05-22",
      Amount: 1200.0,
      Reference: "BACS-2026-05-22-002",
    };
    const created = await writePaymentReceived(client, payload);
    expect(created.PaymentID).toBe("p000-cccc-2222");
    expect(created.Amount).toBe(1200);
  });

  it("writePaymentReceived: 400 surfaces as XeroValidationError (no retry)", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("Invoice ID does not exist", { status: 400 });
    };
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payload: XeroPaymentWriteRequest = {
      Invoice: { InvoiceID: "00000000-0000-0000-0000-000000000000" },
      Account: { Code: "090" },
      Date: "2026-05-22",
      Amount: 1200.0,
    };
    await expect(writePaymentReceived(client, payload)).rejects.toBeInstanceOf(XeroValidationError);
    expect(calls).toBe(1); // write was NOT retried
  });

  // Error-path coverage for listPayments (per review-mcp-connector §6 +
  // Codex F-R1 issue #4): GET retries 5xx exponentially; after retries
  // exhausted the typed error is XeroError (NOT XeroRateLimitError).
  it("listPayments: persistent 500 surfaces as XeroError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("Xero internal error", { status: 500 });
    };
    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      listPayments(client, { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(XeroError);
    expect(calls).toBeGreaterThanOrEqual(2); // initial + retries per max_retries=2
  });

  // 401-forces-refresh: per Codex F-R2 issue #1, a 401 on a GET MUST trigger
  // an explicit refreshTokens() call before retrying — NOT just null the cache
  // (which would reload the same stale token from disk if shouldRefresh()
  // returns false). This test would FAIL against the pre-fix code: the second
  // GET would use the same access_token and the 401 loop would never break.
  it("401 on GET forces explicit token refresh + retry uses new access_token", async () => {
    let getCalls = 0;
    let refreshCalls = 0;
    let observedSecondAuth: string | null = null;

    const fakeFetch: typeof fetch = async (input, init) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      if (url.includes("identity.xero.com/connect/token")) {
        refreshCalls += 1;
        return new Response(
          JSON.stringify({
            access_token: "rotated-access-token-after-401",
            refresh_token: "rotated-refresh-token",
            expires_in: 1800,
            scope: "accounting.transactions offline_access",
            token_type: "Bearer",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      // Invoice GET path
      getCalls += 1;
      if (getCalls === 1) {
        return new Response("", { status: 401 });
      }
      observedSecondAuth = (init?.headers as Record<string, string>)?.["Authorization"] ?? null;
      return makeOkResponse(INVOICES_PAGE_1);
    };

    const client = new XeroClient({ config: makeConfig(), fetchFn: fakeFetch });
    const invoices = await listOpenInvoices(client, { cache, no_cache: true });

    expect(invoices.length).toBe(2);
    expect(getCalls).toBe(2); // initial 401 + retry
    expect(refreshCalls).toBe(1); // forced refresh between attempts
    expect(observedSecondAuth).toBe("Bearer rotated-access-token-after-401");
  });
});
