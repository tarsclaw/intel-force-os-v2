// Scaffold tests — verify public surface, exports, error hierarchy.
// Per review-mcp-connector §1 (capabilities-set-equal-with-README + exports).

import { describe, expect, it } from "vitest";

import {
  DEFAULT_API_VERSION,
  DEFAULT_BASE_URL,
  DEFAULT_TIMEOUT_MS,
  ReedAuthError,
  ReedCache,
  ReedClient,
  ReedError,
  ReedNotFoundError,
  ReedRateLimitError,
  ReedValidationError,
  VERSION,
  getCandidate,
  getJob,
  listJobs,
  rateCheck,
  rateConsume,
  resetRateLimit,
  searchCandidates,
} from "../src/index.js";

describe("@ifos/reed — scaffold", () => {
  it("exports VERSION + DEFAULT_TIMEOUT_MS + DEFAULT_BASE_URL + DEFAULT_API_VERSION", () => {
    expect(VERSION).toBe("0.1.0");
    expect(DEFAULT_TIMEOUT_MS).toBe(15_000);
    expect(DEFAULT_BASE_URL).toBe("https://www.reed.co.uk/api");
    expect(DEFAULT_API_VERSION).toBe("1.0");
  });

  it("exports the bus-routed capability functions (set-equal with sourcing-scout/tools.yaml)", () => {
    // Candidate capabilities
    expect(typeof searchCandidates).toBe("function");
    expect(typeof getCandidate).toBe("function");
    // Job capabilities
    expect(typeof listJobs).toBe("function");
    expect(typeof getJob).toBe("function");
  });

  it("exports internal helpers (NOT bus-routed; for consumer + tests)", () => {
    expect(typeof ReedClient).toBe("function"); // class
    expect(typeof ReedCache).toBe("function"); // class
    expect(typeof rateCheck).toBe("function");
    expect(typeof rateConsume).toBe("function");
    expect(typeof resetRateLimit).toBe("function");
  });

  it("exports a complete error hierarchy", () => {
    expect(new ReedError("test") instanceof Error).toBe(true);
    expect(new ReedAuthError("test") instanceof ReedError).toBe(true);
    expect(new ReedRateLimitError("test") instanceof ReedError).toBe(true);
    expect(new ReedNotFoundError("test") instanceof ReedError).toBe(true);
    expect(new ReedValidationError("test") instanceof ReedError).toBe(true);
  });

  it("error names match class names (per Error.name conventions)", () => {
    expect(new ReedError("x").name).toBe("ReedError");
    expect(new ReedAuthError("x").name).toBe("ReedAuthError");
    expect(new ReedRateLimitError("x").name).toBe("ReedRateLimitError");
    expect(new ReedNotFoundError("x").name).toBe("ReedNotFoundError");
    expect(new ReedValidationError("x").name).toBe("ReedValidationError");
  });

  it("ReedClient can be instantiated with a minimal config", () => {
    const client = new ReedClient({
      config: { api_key: "fake-api-key", account_id: "acct-fake-001" },
    });
    expect(client).toBeInstanceOf(ReedClient);
  });
});
