import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { generateReport } from "../src/generate.js";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

let tmp: string;

beforeEach(() => {
  tmp = mkdtempSync(join(tmpdir(), "ifos-dg-test-"));
  process.env.IFOS_CH_CACHE_DIR = tmp;
  process.env.IFOS_WEB_SCRAPER_CACHE_DIR = tmp;
  // Stub Companies House API key so client doesn't throw at module init.
  // Tests use mocked fetch via process-wide globals; no real CH calls.
  process.env.COMPANIES_HOUSE_API_KEY = "test-fixture-key";
});

afterEach(() => {
  rmSync(tmp, { recursive: true, force: true });
  delete process.env.IFOS_CH_CACHE_DIR;
  delete process.env.IFOS_WEB_SCRAPER_CACHE_DIR;
  delete process.env.COMPANIES_HOUSE_API_KEY;
});

describe("@ifos/diagnostic-generator", () => {
  it("produces a 12-section Markdown report even with no real data", async () => {
    // Replace globalThis.fetch with a stub that returns 404 for everything,
    // simulating the "firm has no online footprint" path.
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async () => new Response("", { status: 404 })) as typeof fetch;

    try {
      const md = await generateReport({
        firmName: "Nonexistent Test Firm",
        tenantSlug: "migration-test",
        sectorHint: "fintech",
      });

      // Count ## section headings
      const sections = md.match(/^##\s/gm) ?? [];
      expect(sections).toHaveLength(12);

      // Each section needs at least one Markdown link [x](y)
      const parts = md.split(/^##\s/m);
      // parts[0] is preamble; parts[1..12] are sections
      for (let i = 1; i <= 12; i++) {
        const linkCount = (parts[i].match(/\[[^\]]+\]\([^)]+\)/g) ?? []).length;
        expect(linkCount, `section ${i} should have ≥1 link`).toBeGreaterThanOrEqual(1);
      }

      // Sanity: word count in valid range
      const words = md.split(/\s+/).filter(Boolean).length;
      expect(words).toBeGreaterThanOrEqual(400);
      expect(words).toBeLessThanOrEqual(2000);
    } finally {
      globalThis.fetch = origFetch;
    }
  });

  it("includes the firm name in the title", async () => {
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async () => new Response("", { status: 404 })) as typeof fetch;
    try {
      const md = await generateReport({
        firmName: "Charterhouse Partners",
        tenantSlug: "migration-test",
      });
      expect(md).toMatch(/^# Diagnostic report — Charterhouse Partners/m);
    } finally {
      globalThis.fetch = origFetch;
    }
  });

  it("composes a §12 conversation opener that anchors to a real signal", async () => {
    const origFetch = globalThis.fetch;
    globalThis.fetch = (async () => new Response("", { status: 404 })) as typeof fetch;
    try {
      const md = await generateReport({
        firmName: "Test Anchor Firm",
        tenantSlug: "migration-test",
      });
      const opener = md.split(/^## Conversation opener/m)[1] ?? "";
      expect(opener).toMatch(/Hi.*?Test Anchor Firm|Hi —/);
      // Must include an evidence link (Source: [...](...))
      expect(opener).toMatch(/\[[^\]]+\]\([^)]+\)/);
    } finally {
      globalThis.fetch = origFetch;
    }
  });
});
