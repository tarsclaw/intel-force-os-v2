import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  search,
  profile,
  officers,
  filingHistory,
  _resetForTest,
  resetRateLimit,
  CHAuthError,
  CHRateLimitError,
  CHNotFoundError,
  CHClient,
  type FetchFn,
} from "../src/index.js";

let tmp: string;

beforeEach(() => {
  _resetForTest();
  resetRateLimit();
  tmp = mkdtempSync(join(tmpdir(), "ifos-ch-test-"));
  process.env.IFOS_CH_CACHE_DIR = tmp;
  process.env.COMPANIES_HOUSE_API_KEY = "test-key-do-not-use";
});

afterEach(() => {
  rmSync(tmp, { recursive: true, force: true });
  delete process.env.IFOS_CH_CACHE_DIR;
  delete process.env.COMPANIES_HOUSE_API_KEY;
});

function mockFetch(handler: (url: string) => Response): FetchFn {
  return vi.fn(async (input: RequestInfo | URL) => {
    const url = typeof input === "string" ? input : input.toString();
    return handler(url);
  }) as unknown as FetchFn;
}

describe("@ifos/companies-house — client", () => {
  it("throws CHAuthError if api key missing", () => {
    delete process.env.COMPANIES_HOUSE_API_KEY;
    expect(() => new CHClient()).toThrow(CHAuthError);
  });

  it("sends Basic auth header with api key", async () => {
    const fetchImpl = vi.fn(
      async () => new Response(JSON.stringify({ items: [], total_results: 0 }), { status: 200 }),
    ) as unknown as FetchFn;
    const client = new CHClient({ apiKey: "abc123", fetchImpl });
    await client.getJson("/search/companies", { q: "x" });
    const call = (fetchImpl as unknown as { mock: { calls: [string, RequestInit][] } }).mock
      .calls[0];
    const headers = (call[1].headers ?? {}) as Record<string, string>;
    expect(headers.Authorization).toBe("Basic " + Buffer.from("abc123:").toString("base64"));
  });

  it("maps 401 → CHAuthError", async () => {
    const fetchImpl = mockFetch(() => new Response("nope", { status: 401 }));
    const client = new CHClient({ apiKey: "x", fetchImpl });
    await expect(client.getJson("/x")).rejects.toBeInstanceOf(CHAuthError);
  });

  it("maps 404 → CHNotFoundError", async () => {
    const fetchImpl = mockFetch(() => new Response("nope", { status: 404 }));
    const client = new CHClient({ apiKey: "x", fetchImpl });
    await expect(client.getJson("/x")).rejects.toBeInstanceOf(CHNotFoundError);
  });

  it("maps 429 → CHRateLimitError", async () => {
    const fetchImpl = mockFetch(() => new Response("nope", { status: 429 }));
    const client = new CHClient({ apiKey: "x", fetchImpl });
    await expect(client.getJson("/x")).rejects.toBeInstanceOf(CHRateLimitError);
  });
});

describe("@ifos/companies-house — search", () => {
  it("returns items array", async () => {
    const fetchImpl = mockFetch(
      () =>
        new Response(
          JSON.stringify({
            items: [{ company_number: "08732145", title: "TEST CO LTD", company_status: "active" }],
            total_results: 1,
            start_index: 0,
            items_per_page: 20,
          }),
          { status: 200 },
        ),
    );
    const results = await search("test co", { fetchImpl });
    expect(results).toHaveLength(1);
    expect(results[0].company_number).toBe("08732145");
  });

  it("caches search results", async () => {
    let calls = 0;
    const fetchImpl = mockFetch(() => {
      calls++;
      return new Response(JSON.stringify({ items: [], total_results: 0 }), { status: 200 });
    });
    await search("foo bar", { fetchImpl });
    await search("foo bar", { fetchImpl });
    expect(calls).toBe(1);
  });
});

describe("@ifos/companies-house — profile", () => {
  it("returns parsed profile", async () => {
    const fetchImpl = mockFetch(
      () =>
        new Response(
          JSON.stringify({
            company_number: "08732145",
            company_name: "TEST CO LTD",
            company_status: "active",
            date_of_creation: "2013-09-14",
            type: "ltd",
            registered_office_address: {
              address_line_1: "23 King William Street",
              postal_code: "EC4R 9AT",
              country: "United Kingdom",
            },
          }),
          { status: 200 },
        ),
    );
    const prof = await profile("08732145", { fetchImpl });
    expect(prof?.company_name).toBe("TEST CO LTD");
    expect(prof?.registered_office_address.postal_code).toBe("EC4R 9AT");
  });

  it("returns null on 404 (company not in CH)", async () => {
    const fetchImpl = mockFetch(() => new Response("nope", { status: 404 }));
    const prof = await profile("99999999", { fetchImpl });
    expect(prof).toBeNull();
  });
});

describe("@ifos/companies-house — officers", () => {
  it("returns officers list", async () => {
    const fetchImpl = mockFetch(
      () =>
        new Response(
          JSON.stringify({
            items: [
              { name: "BOWEN, Sarah", officer_role: "director", appointed_on: "2013-09-14" },
              { name: "MARSHALL, James", officer_role: "director", appointed_on: "2019-04-12" },
            ],
            total_results: 2,
            active_count: 2,
            resigned_count: 0,
          }),
          { status: 200 },
        ),
    );
    const dirs = await officers("08732145", { fetchImpl });
    expect(dirs?.items).toHaveLength(2);
    expect(dirs?.items[0].name).toBe("BOWEN, Sarah");
  });
});

describe("@ifos/companies-house — filingHistory", () => {
  it("filters to sinceDays window", async () => {
    const now = new Date();
    const recent = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);
    const ancient = "2020-01-01";
    const fetchImpl = mockFetch(
      () =>
        new Response(
          JSON.stringify({
            items: [
              { category: "accounts", description: "Recent", date: recent, type: "AA" },
              { category: "accounts", description: "Ancient", date: ancient, type: "AA" },
            ],
            total_count: 2,
            start_index: 0,
            items_per_page: 35,
          }),
          { status: 200 },
        ),
    );
    const fh = await filingHistory("08732145", 90, { fetchImpl });
    expect(fh?.items).toHaveLength(1);
    expect(fh?.items[0].description).toBe("Recent");
  });
});

describe("@ifos/companies-house — rate limiting", () => {
  it("throws CHRateLimitError when soft budget hit", async () => {
    const fetchImpl = mockFetch(
      () => new Response(JSON.stringify({ items: [], total_results: 0 }), { status: 200 }),
    );
    // Consume the soft budget (480) by issuing distinct cache keys to avoid hitting cache
    for (let i = 0; i < 480; i++) {
      // direct rate consumption via search with unique queries (use small query strings)
      await search(`q${i}`, { fetchImpl }).catch(() => undefined);
    }
    await expect(search("one more", { fetchImpl })).rejects.toBeInstanceOf(CHRateLimitError);
  });
});
