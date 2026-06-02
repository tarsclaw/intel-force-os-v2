// Scaffold tests — verify public surface, exports, error hierarchy.
// Per review-mcp-connector §1 (capabilities-set-equal-with-README + exports).

import { describe, expect, it } from "vitest";

import {
  BullhornAuthError,
  BullhornCache,
  BullhornClient,
  BullhornError,
  BullhornNotFoundError,
  BullhornRateLimitError,
  BullhornValidationError,
  BULLHORN_REST_LOGIN_URL,
  DEFAULT_TIMEOUT_MS,
  VERSION,
  createActivityLogEntry,
  createNote,
  getCandidate,
  getClient,
  getContact,
  getNote,
  getPlacement,
  listCandidates,
  listClients,
  listContacts,
  listPlacements,
  loadTokens,
  rateCheck,
  rateConsume,
  refreshTokens,
  resetRateLimit,
  saveTokens,
  shouldRefresh,
  updateCandidate,
} from "../src/index.js";

describe("@ifos/bullhorn — scaffold", () => {
  it("exports VERSION + DEFAULT_TIMEOUT_MS + BULLHORN_REST_LOGIN_URL", () => {
    expect(VERSION).toBe("0.1.0");
    expect(DEFAULT_TIMEOUT_MS).toBe(15_000);
    expect(BULLHORN_REST_LOGIN_URL).toBe(
      "https://rest.bullhornstaffing.com/rest-services/login",
    );
  });

  it("exports the bus-routed capability functions (set-equal with consumer tools.yaml)", () => {
    // OAuth (Step A + Step B refresh wrapper)
    expect(typeof refreshTokens).toBe("function");
    // Candidate capabilities (Janitor)
    expect(typeof getCandidate).toBe("function");
    expect(typeof listCandidates).toBe("function");
    expect(typeof updateCandidate).toBe("function");
    // Placement (Concierge + Cash Conductor addressee resolution)
    expect(typeof getPlacement).toBe("function");
    expect(typeof listPlacements).toBe("function");
    // ClientCorporation (Concierge + CC)
    expect(typeof getClient).toBe("function");
    expect(typeof listClients).toBe("function");
    // ClientContact (Concierge + CC)
    expect(typeof getContact).toBe("function");
    expect(typeof listContacts).toBe("function");
    // Note write (Concierge activity-log + Scribe)
    expect(typeof createNote).toBe("function");
    expect(typeof createActivityLogEntry).toBe("function");
    expect(typeof getNote).toBe("function");
  });

  it("exports internal helpers (NOT bus-routed; for consumer + tests)", () => {
    expect(typeof BullhornClient).toBe("function"); // class
    expect(typeof BullhornCache).toBe("function"); // class
    expect(typeof loadTokens).toBe("function");
    expect(typeof saveTokens).toBe("function");
    expect(typeof shouldRefresh).toBe("function");
    expect(typeof rateCheck).toBe("function");
    expect(typeof rateConsume).toBe("function");
    expect(typeof resetRateLimit).toBe("function");
  });

  it("exports a complete error hierarchy", () => {
    // Each error class exists and inherits from BullhornError (which extends Error)
    expect(new BullhornError("test") instanceof Error).toBe(true);
    expect(new BullhornAuthError("test") instanceof BullhornError).toBe(true);
    expect(new BullhornRateLimitError("test") instanceof BullhornError).toBe(true);
    expect(new BullhornNotFoundError("test") instanceof BullhornError).toBe(true);
    expect(new BullhornValidationError("test") instanceof BullhornError).toBe(true);
  });

  it("error names match class names (per Error.name conventions)", () => {
    expect(new BullhornError("x").name).toBe("BullhornError");
    expect(new BullhornAuthError("x").name).toBe("BullhornAuthError");
    expect(new BullhornRateLimitError("x").name).toBe("BullhornRateLimitError");
    expect(new BullhornNotFoundError("x").name).toBe("BullhornNotFoundError");
    expect(new BullhornValidationError("x").name).toBe("BullhornValidationError");
  });
});
