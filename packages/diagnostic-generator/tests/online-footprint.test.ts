import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

let tmp: string;

beforeEach(() => {
  tmp = mkdtempSync(join(tmpdir(), "ifos-of-test-"));
  process.env.IFOS_WEB_SCRAPER_CACHE_DIR = tmp;
  process.env.COMPANIES_HOUSE_API_KEY = "test-fixture-key";
});

afterEach(() => {
  rmSync(tmp, { recursive: true, force: true });
  delete process.env.IFOS_WEB_SCRAPER_CACHE_DIR;
  delete process.env.COMPANIES_HOUSE_API_KEY;
});

describe("@ifos/diagnostic-generator — online-footprint slug fallback", () => {
  it("prefers suffix-stripped slug for LinkedIn URL when both reachable", async () => {
    const calls: string[] = [];
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async (input: RequestInfo | URL) => {
      const url = typeof input === "string" ? input : input.toString();
      calls.push(url);
      // Any robots.txt fetch returns 404 (no robots; allowed)
      if (url.endsWith("/robots.txt")) return new Response("", { status: 404 });
      // Both base and full slug LinkedIn URLs return 200
      if (url.includes("/company/hays/")) return new Response(null, { status: 200 });
      if (url.includes("/company/hays-plc/")) return new Response(null, { status: 200 });
      return new Response(null, { status: 404 });
    }) as typeof fetch;

    const { fetchOnlineFootprint } = await import("../src/sections/online-footprint.js");
    try {
      const r = await fetchOnlineFootprint("Hays plc");
      expect(r.linkedInUrl).toBe("https://www.linkedin.com/company/hays/");
      expect(r.linkedInReachable).toBe(true);
    } finally {
      globalThis.fetch = origFetch;
    }
  });

  it("falls back to full slug if suffix-stripped not reachable", async () => {
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async (input: RequestInfo | URL) => {
      const url = typeof input === "string" ? input : input.toString();
      if (url.endsWith("/robots.txt")) return new Response("", { status: 404 });
      // Suffix-stripped 404; full slug 200
      if (url.includes("/company/example/")) return new Response(null, { status: 404 });
      if (url.includes("/company/example-ltd/")) return new Response(null, { status: 200 });
      return new Response(null, { status: 404 });
    }) as typeof fetch;

    const { fetchOnlineFootprint } = await import("../src/sections/online-footprint.js");
    try {
      const r = await fetchOnlineFootprint("Example Ltd");
      expect(r.linkedInUrl).toBe("https://www.linkedin.com/company/example-ltd/");
      expect(r.linkedInReachable).toBe(true);
    } finally {
      globalThis.fetch = origFetch;
    }
  });

  it("returns last-seen status when neither slug reachable", async () => {
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async (input: RequestInfo | URL) => {
      const url = typeof input === "string" ? input : input.toString();
      if (url.endsWith("/robots.txt")) return new Response("", { status: 404 });
      return new Response(null, { status: 404 });
    }) as typeof fetch;

    const { fetchOnlineFootprint } = await import("../src/sections/online-footprint.js");
    try {
      const r = await fetchOnlineFootprint("Unknown Holdings");
      expect(r.linkedInReachable).toBe(false);
      expect(r.linkedInStatus).toBe(404);
    } finally {
      globalThis.fetch = origFetch;
    }
  });
});
