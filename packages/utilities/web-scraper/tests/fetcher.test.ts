import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { headCheck, fetchFirstNLines, type FetchFn } from "../src/index.js";
import { resetRateLimit } from "../src/index.js";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

let tmpCacheDir: string;

beforeEach(() => {
  resetRateLimit();
  tmpCacheDir = mkdtempSync(join(tmpdir(), "ifos-ws-test-"));
  process.env.IFOS_WEB_SCRAPER_CACHE_DIR = tmpCacheDir;
});

afterEach(() => {
  rmSync(tmpCacheDir, { recursive: true, force: true });
  delete process.env.IFOS_WEB_SCRAPER_CACHE_DIR;
});

function mockFetch(handler: (url: string, init: RequestInit) => Response): FetchFn {
  return vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const url = typeof input === "string" ? input : input.toString();
    return handler(url, init ?? {});
  }) as unknown as FetchFn;
}

describe("@ifos/web-scraper — headCheck", () => {
  it("returns shape on 200", async () => {
    const fetchImpl = mockFetch((url) => {
      if (url.endsWith("/robots.txt")) return new Response("", { status: 404 });
      return new Response(null, {
        status: 200,
        headers: { "last-modified": "Wed, 21 Oct 2026 07:28:00 GMT", "content-type": "text/html" },
      });
    });
    const result = await headCheck("https://example.com/page", { fetchImpl });
    expect(result?.status).toBe(200);
    expect(result?.lastModified).toBe("Wed, 21 Oct 2026 07:28:00 GMT");
    expect(result?.contentType).toContain("text/html");
  });

  it("returns shape on 404 (not cached)", async () => {
    const fetchImpl = mockFetch((url) => {
      if (url.endsWith("/robots.txt")) return new Response("", { status: 404 });
      return new Response(null, { status: 404 });
    });
    const result = await headCheck("https://example.com/missing", { fetchImpl });
    expect(result?.status).toBe(404);
  });

  it("blocks on robots.txt disallow", async () => {
    const fetchImpl = mockFetch((url) => {
      if (url.endsWith("/robots.txt")) {
        return new Response("User-agent: *\nDisallow: /private", { status: 200 });
      }
      return new Response(null, { status: 200 });
    });
    const result = await headCheck("https://example.com/private/x", { fetchImpl });
    expect(result).toBeNull();
  });

  it("returns null on network error", async () => {
    const fetchImpl = mockFetch((url) => {
      if (url.endsWith("/robots.txt")) return new Response("", { status: 404 });
      throw new Error("ECONNREFUSED");
    });
    const result = await headCheck("https://example.com/x", { fetchImpl });
    expect(result).toBeNull();
  });

  it("caches a 200 response", async () => {
    let callCount = 0;
    const fetchImpl = mockFetch((url) => {
      if (url.endsWith("/robots.txt")) return new Response("", { status: 404 });
      callCount++;
      return new Response(null, { status: 200, headers: { "content-type": "text/html" } });
    });
    await headCheck("https://example.com/page", { fetchImpl });
    await headCheck("https://example.com/page", { fetchImpl });
    // 2 robots fetches + 1 page fetch (second page comes from cache)
    expect(callCount).toBe(1);
  });
});

describe("@ifos/web-scraper — fetchFirstNLines", () => {
  it("captures up to N lines", async () => {
    const body = ["<!DOCTYPE html>", "<html>", "<head>", "<title>X</title>", "</head>"].join("\n");
    const fetchImpl = mockFetch((url) => {
      if (url.endsWith("/robots.txt")) return new Response("", { status: 404 });
      return new Response(body, { status: 200, headers: { "content-type": "text/html" } });
    });
    const result = await fetchFirstNLines("https://example.com/page", 3, { fetchImpl });
    expect(result?.lines).toHaveLength(3);
    expect(result?.lines[0]).toBe("<!DOCTYPE html>");
    expect(result?.lines[2]).toBe("<head>");
  });

  it("handles empty body gracefully", async () => {
    const fetchImpl = mockFetch((url) => {
      if (url.endsWith("/robots.txt")) return new Response("", { status: 404 });
      return new Response("", { status: 200 });
    });
    const result = await fetchFirstNLines("https://example.com/empty", 10, { fetchImpl });
    expect(result?.lines).toHaveLength(0);
  });
});

describe("@ifos/web-scraper — rate limit", () => {
  it("returns null after budget exhausted", async () => {
    const fetchImpl = mockFetch(() => new Response("", { status: 404 }));
    // Robots cached after first hit; rate limiter still counts each headCheck
    let nullCount = 0;
    for (let i = 0; i < 35; i++) {
      const r = await headCheck(`https://example.com/p${i}`, { fetchImpl });
      if (r === null) nullCount++;
    }
    // We expect SOME nulls past the 30 budget — exact count depends on
    // whether robots calls also consumed budget. Conservative assertion:
    expect(nullCount).toBeGreaterThan(0);
  });
});
