import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import {
  renderConversationOpener,
  renderConversationOpenerSync,
  type ConversationOpenerInput,
} from "../src/sections/conversation-opener.js";

const baseInput: ConversationOpenerInput = {
  firmName: "Test Firm Ltd",
  firmSignal: {
    companyNumber: "08732145",
    companyName: "Test Firm Ltd",
    incorporationDate: "2013-09-14",
    status: "active",
    address: "23 King William Street, London",
    sicCodes: ["78200"],
    latestAccounts: "2025-03-31",
    recentFilingCount: 2,
    directors: [{ name: "BOWEN, Sarah", role: "director", appointedOn: "2013-09-14" }],
  },
  painSignals: {
    careersPageUrl: "https://test-firm.com/careers",
    careersPageStatus: 200,
    matches: [{ pattern: "rapid growth", quote: "rapid growth" }],
  },
  recentActivity: {
    filings: [{ date: "2026-04-21", description: "Annual accounts", category: "accounts" }],
  },
  sectorHint: "fintech",
};

beforeEach(() => {
  // Ensure no leftover key from other tests
  delete process.env.ANTHROPIC_API_KEY;
});

afterEach(() => {
  delete process.env.ANTHROPIC_API_KEY;
});

describe("§12 conversation opener — LLM-driven with fallback", () => {
  it("uses deterministic fallback when ANTHROPIC_API_KEY unset", async () => {
    const md = await renderConversationOpener(baseInput);
    expect(md).toMatch(/^## Conversation opener/m);
    expect(md).toMatch(/deterministic/i); // generation label
    // Anchors to pain signal quote (top priority deterministic path)
    expect(md).toMatch(/rapid growth/);
    // Has evidence link (Gate A V2)
    expect(md).toMatch(/\[[^\]]+\]\([^)]+\)/);
  });

  it("falls back deterministically when LLM call throws", async () => {
    process.env.ANTHROPIC_API_KEY = "invalid-test-key";
    // Mock the @anthropic-ai/sdk Anthropic class to throw on .messages.create
    vi.doMock("@anthropic-ai/sdk", () => {
      class Anthropic {
        messages = {
          create: vi.fn(async () => {
            throw new Error("simulated network failure");
          }),
        };
      }
      return { default: Anthropic };
    });

    // Re-import to pick up the mock
    const mod = await import("../src/sections/conversation-opener.js?reimport=" + Date.now());
    const md = await (mod as { renderConversationOpener: typeof renderConversationOpener })
      .renderConversationOpener(baseInput);

    expect(md).toMatch(/^## Conversation opener/m);
    // Should label as deterministic because LLM threw
    expect(md).toMatch(/deterministic|fallback/i);
  });

  it("renderConversationOpenerSync returns deterministic output regardless of key", () => {
    process.env.ANTHROPIC_API_KEY = "any-key";
    const md = renderConversationOpenerSync(baseInput);
    expect(md).toMatch(/^## Conversation opener/m);
    expect(md).toMatch(/deterministic/i);
  });

  it("falls back gracefully when firm has no signals", async () => {
    const md = await renderConversationOpener({
      ...baseInput,
      firmSignal: {
        ...baseInput.firmSignal,
        companyNumber: null,
        directors: [],
      },
      painSignals: {
        careersPageUrl: null,
        careersPageStatus: null,
        matches: [],
      },
      recentActivity: { filings: [] },
    });
    expect(md).toMatch(/^## Conversation opener/m);
    // No-signals fallback should still produce a valid section with a link
    expect(md).toMatch(/\[[^\]]+\]\([^)]+\)/);
    // Should mention sector hint
    expect(md).toMatch(/fintech|recruitment/);
  });
});
