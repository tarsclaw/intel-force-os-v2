// Scaffold tests — verify public surface, exports, error hierarchy.
// Per review-mcp-connector §1.

import { describe, expect, it } from "vitest";

import {
  CVLibraryAuthError,
  CVLibraryCache,
  CVLibraryClient,
  CVLibraryError,
  CVLibraryNotFoundError,
  CVLibraryRateLimitError,
  CVLibraryValidationError,
  DEFAULT_BASE_URL,
  DEFAULT_TIMEOUT_MS,
  VERSION,
  getCandidate,
  rateCheck,
  rateConsume,
  resetRateLimit,
  searchCandidates,
} from "../src/index.js";

describe("@ifos/cv-library — scaffold", () => {
  it("exports VERSION + DEFAULT_TIMEOUT_MS + DEFAULT_BASE_URL", () => {
    expect(VERSION).toBe("0.1.0");
    expect(DEFAULT_TIMEOUT_MS).toBe(15_000);
    expect(DEFAULT_BASE_URL).toBe("https://api.cv-library.co.uk");
  });

  it("exports the bus-routed capability functions (set-equal with sourcing-scout/tools.yaml)", () => {
    expect(typeof searchCandidates).toBe("function");
    expect(typeof getCandidate).toBe("function");
  });

  it("exports internal helpers (NOT bus-routed; for consumer + tests)", () => {
    expect(typeof CVLibraryClient).toBe("function"); // class
    expect(typeof CVLibraryCache).toBe("function"); // class
    expect(typeof rateCheck).toBe("function");
    expect(typeof rateConsume).toBe("function");
    expect(typeof resetRateLimit).toBe("function");
  });

  it("exports a complete error hierarchy", () => {
    expect(new CVLibraryError("test") instanceof Error).toBe(true);
    expect(new CVLibraryAuthError("test") instanceof CVLibraryError).toBe(true);
    expect(new CVLibraryRateLimitError("test") instanceof CVLibraryError).toBe(true);
    expect(new CVLibraryNotFoundError("test") instanceof CVLibraryError).toBe(true);
    expect(new CVLibraryValidationError("test") instanceof CVLibraryError).toBe(true);
  });

  it("error names match class names (per Error.name conventions)", () => {
    expect(new CVLibraryError("x").name).toBe("CVLibraryError");
    expect(new CVLibraryAuthError("x").name).toBe("CVLibraryAuthError");
    expect(new CVLibraryRateLimitError("x").name).toBe("CVLibraryRateLimitError");
    expect(new CVLibraryNotFoundError("x").name).toBe("CVLibraryNotFoundError");
    expect(new CVLibraryValidationError("x").name).toBe("CVLibraryValidationError");
  });

  it("CVLibraryClient can be instantiated with Basic auth mode", () => {
    const client = new CVLibraryClient({
      config: { account_id: "acct-fake", auth_mode: "basic", api_key: "test-key" },
    });
    expect(client).toBeInstanceOf(CVLibraryClient);
  });

  it("CVLibraryClient can be instantiated with Bearer auth mode", () => {
    const client = new CVLibraryClient({
      config: { account_id: "acct-fake", auth_mode: "bearer", access_token: "test-token" },
    });
    expect(client).toBeInstanceOf(CVLibraryClient);
  });

  it("CVLibraryClient throws when Basic mode missing api_key", () => {
    expect(() => new CVLibraryClient({
      config: { account_id: "acct-fake", auth_mode: "basic" },
    })).toThrow(/api_key required/);
  });

  it("CVLibraryClient throws when Bearer mode missing access_token", () => {
    expect(() => new CVLibraryClient({
      config: { account_id: "acct-fake", auth_mode: "bearer" },
    })).toThrow(/access_token required/);
  });
});
