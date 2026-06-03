// Scaffold tests — verify public surface, exports, error hierarchy.
// Per review-mcp-connector §1 (capabilities-set-equal-with-README + exports).

import { describe, expect, it } from "vitest";

import {
  DEFAULT_GRANOLA_DCR_URL,
  DEFAULT_GRANOLA_TOKEN_URL,
  DEFAULT_MCP_SERVER_URL,
  DEFAULT_TIMEOUT_MS,
  GranolaAuthError,
  GranolaCache,
  GranolaClient,
  GranolaError,
  GranolaNotFoundError,
  GranolaPlanTierInsufficientError,
  GranolaRateLimitError,
  PAID_PLAN_TOOLS,
  VERSION,
  exchangeAuthCode,
  generatePkcePair,
  getAccountInfo,
  getMeeting,
  getTranscript,
  listFolders,
  listMeetings,
  loadTokens,
  queryMeetings,
  rateCheck,
  rateConsume,
  refreshTokens,
  resetRateLimit,
  saveTokens,
  shouldRefresh,
} from "../src/index.js";

describe("@ifos/granola — scaffold", () => {
  it("exports VERSION + DEFAULT_TIMEOUT_MS + DEFAULT_MCP_SERVER_URL + DEFAULT token URLs", () => {
    expect(VERSION).toBe("0.1.0");
    expect(DEFAULT_TIMEOUT_MS).toBe(30_000);
    expect(DEFAULT_MCP_SERVER_URL).toBe("https://mcp.granola.ai/mcp");
    expect(DEFAULT_GRANOLA_TOKEN_URL).toBe("https://api.granola.ai/oauth/token");
    expect(DEFAULT_GRANOLA_DCR_URL).toBe("https://api.granola.ai/oauth/register");
  });

  it("exports the bus-routed capability functions (set-equal with future Scribe tools.yaml)", () => {
    // Meeting capabilities (all plans; 3 of 6 official MCP tools)
    expect(typeof listMeetings).toBe("function");
    expect(typeof getMeeting).toBe("function");
    expect(typeof queryMeetings).toBe("function");
    // Folder capability (Paid only; 1 of 6)
    expect(typeof listFolders).toBe("function");
    // Transcript capability (Paid only; 1 of 6)
    expect(typeof getTranscript).toBe("function");
    // Account capability (all plans; 1 of 6)
    expect(typeof getAccountInfo).toBe("function");
  });

  it("PAID_PLAN_TOOLS contains exactly the two Paid-only tool names", () => {
    expect(PAID_PLAN_TOOLS.size).toBe(2);
    expect(PAID_PLAN_TOOLS.has("list_meeting_folders")).toBe(true);
    expect(PAID_PLAN_TOOLS.has("get_meeting_transcript")).toBe(true);
    expect(PAID_PLAN_TOOLS.has("list_meetings")).toBe(false);
    expect(PAID_PLAN_TOOLS.has("get_meetings")).toBe(false);
    expect(PAID_PLAN_TOOLS.has("query_granola_meetings")).toBe(false);
    expect(PAID_PLAN_TOOLS.has("get_account_info")).toBe(false);
  });

  it("exports internal helpers (NOT bus-routed; for consumer + tests)", () => {
    expect(typeof GranolaClient).toBe("function"); // class
    expect(typeof GranolaCache).toBe("function"); // class
    expect(typeof generatePkcePair).toBe("function");
    expect(typeof loadTokens).toBe("function");
    expect(typeof saveTokens).toBe("function");
    expect(typeof shouldRefresh).toBe("function");
    expect(typeof refreshTokens).toBe("function");
    expect(typeof exchangeAuthCode).toBe("function");
    expect(typeof rateCheck).toBe("function");
    expect(typeof rateConsume).toBe("function");
    expect(typeof resetRateLimit).toBe("function");
  });

  it("exports a complete error hierarchy including PlanTierInsufficient", () => {
    expect(new GranolaError("test") instanceof Error).toBe(true);
    expect(new GranolaAuthError("test") instanceof GranolaError).toBe(true);
    expect(new GranolaRateLimitError("test") instanceof GranolaError).toBe(true);
    expect(new GranolaNotFoundError("test") instanceof GranolaError).toBe(true);
    expect(
      new GranolaPlanTierInsufficientError("test", "paid", "get_meeting_transcript") instanceof
        GranolaError,
    ).toBe(true);
  });

  it("error names match class names (per Error.name conventions)", () => {
    expect(new GranolaError("x").name).toBe("GranolaError");
    expect(new GranolaAuthError("x").name).toBe("GranolaAuthError");
    expect(new GranolaRateLimitError("x").name).toBe("GranolaRateLimitError");
    expect(new GranolaNotFoundError("x").name).toBe("GranolaNotFoundError");
    expect(
      new GranolaPlanTierInsufficientError("x", "paid", "list_meeting_folders").name,
    ).toBe("GranolaPlanTierInsufficientError");
  });

  it("PlanTierInsufficient error carries required_tier + capability metadata", () => {
    const e = new GranolaPlanTierInsufficientError(
      "transcript requires Paid",
      "paid",
      "get_meeting_transcript",
    );
    expect(e.required_tier).toBe("paid");
    expect(e.capability).toBe("get_meeting_transcript");
    expect(e.status).toBe(403);
  });
});
