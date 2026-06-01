// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
// path + ≥1 error path per capability).

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { QbClient } from "../src/client.js";
import { QbCache } from "../src/cache.js";
import { saveTokens, _resetInflightForTest } from "../src/auth.js";
import { reset as resetRateLimit } from "../src/rate-limit.js";
import { listOpenInvoices, getInvoice } from "../src/invoices.js";
import { listPayments, writePaymentReceived } from "../src/payments.js";
import { QbValidationError, QbNotFoundError } from "../src/errors.js";
import type {
  QbOAuthConfig,
  QbTokens,
  QbPaymentWriteRequest,
} from "../src/types.js";

import INVOICES_PAGE_1 from "../fixtures/invoices-page-1.json" with { type: "json" };
import PAYMENTS_RECENT from "../fixtures/payments-recent.json" with { type: "json" };
import PAYMENT_WRITE_OK from "../fixtures/payment-write-ok.json" with { type: "json" };

const FIXTURE_TOKENS: QbTokens = {
  access_token: "fake-access",
  refresh_token: "fake-refresh",
  expires_at_ms: Date.now() + 3600_000,
  refresh_token_expires_at_ms: Date.now() + 100 * 24 * 60 * 60 * 1000,
  scope: "com.intuit.quickbooks.accounting",
  token_type: "Bearer",
};

let token_file: string;
let cache_dir: string;
let cache: QbCache;

function makeConfig(): QbOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    realm_id: "fixture-realm",
    environment: "sandbox",
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
  token_file = join(
    tmpdir(),
    `qb-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
  cache_dir = join(
    tmpdir(),
    `qb-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`,
  );
  cache = new QbCache(cache_dir);
  _resetInflightForTest();
  resetRateLimit();
  await saveTokens(makeConfig(), FIXTURE_TOKENS);
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
});

describe("quickbooks capabilities — invoices", () => {
  it("listOpenInvoices: returns parsed array from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(INVOICES_PAGE_1);
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const invoices = await listOpenInvoices(client, { cache, no_cache: true });
    expect(invoices.length).toBe(2);
    expect(invoices[0]?.Id).toBe("1001");
    expect(invoices[0]?.Balance).toBe(1500);
    expect(invoices[1]?.CustomerRef.name).toBe("Beta Search Partners");
  });

  it("getInvoice: returns single invoice when present (single-entity endpoint shape)", async () => {
    const fakeFetch: typeof fetch = async () =>
      makeOkResponse({ Invoice: INVOICES_PAGE_1.QueryResponse.Invoice[0] });
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const inv = await getInvoice(client, "1001", { cache, no_cache: true });
    expect(inv).not.toBeNull();
    expect(inv?.DocNumber).toBe("INV-1001");
  });

  it("getInvoice: 404 surfaces as QbNotFoundError", async () => {
    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      getInvoice(client, "99999", { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(QbNotFoundError);
  });
});

describe("quickbooks capabilities — payments", () => {
  it("listPayments: returns parsed array from fixture", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENTS_RECENT);
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payments = await listPayments(client, { cache, no_cache: true });
    expect(payments.length).toBe(1);
    expect(payments[0]?.TotalAmt).toBe(2000);
    expect(payments[0]?.Line[0]?.LinkedTxn[0]?.TxnId).toBe("1002");
  });

  it("writePaymentReceived: success path returns created payment", async () => {
    const fakeFetch: typeof fetch = async () => makeOkResponse(PAYMENT_WRITE_OK);
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payload: QbPaymentWriteRequest = {
      CustomerRef: { value: "200" },
      TotalAmt: 1500.0,
      TxnDate: "2026-05-22",
      PaymentRefNum: "BACS-2026-05-22-002",
      Line: [
        {
          Amount: 1500.0,
          LinkedTxn: [{ TxnId: "1001", TxnType: "Invoice" }],
        },
      ],
    };
    const created = await writePaymentReceived(client, payload);
    expect(created.Id).toBe("p-502");
    expect(created.TotalAmt).toBe(1500);
  });

  it("writePaymentReceived: 400 surfaces as QbValidationError (no retry)", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("Invoice Id does not exist", { status: 400 });
    };
    const client = new QbClient({ config: makeConfig(), fetchFn: fakeFetch });
    const payload: QbPaymentWriteRequest = {
      CustomerRef: { value: "0" },
      TotalAmt: 100.0,
      Line: [{ Amount: 100.0, LinkedTxn: [{ TxnId: "0", TxnType: "Invoice" }] }],
    };
    await expect(writePaymentReceived(client, payload)).rejects.toBeInstanceOf(
      QbValidationError,
    );
    expect(calls).toBe(1); // write was NOT retried
  });
});
