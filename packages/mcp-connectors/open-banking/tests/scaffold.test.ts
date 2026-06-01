// Package public surface smoke tests. Per review-mcp-connector §1.

import { describe, expect, it } from "vitest";
import {
  VERSION,
  OpenBankingClient,
  TRUELAYER_API_PROD,
  TRUELAYER_API_SANDBOX,
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  getTokenAgeStage,
  listTransactionsSince,
  getAccountBalance,
  OpenBankingCache,
  OpenBankingError,
  OpenBankingAuthError,
  OpenBankingConsentExpiredError,
  OpenBankingRateLimitError,
  OpenBankingNotFoundError,
  NotImplementedError,
} from "../src/index.js";

describe("@ifos/open-banking package surface", () => {
  it("exports VERSION 0.1.0", () => {
    expect(VERSION).toBe("0.1.0");
  });

  it("exports OpenBankingClient + base URLs (production + sandbox)", () => {
    expect(typeof OpenBankingClient).toBe("function");
    expect(TRUELAYER_API_PROD).toBe("https://api.truelayer.com");
    expect(TRUELAYER_API_SANDBOX).toBe("https://api.truelayer-sandbox.com");
  });

  it("exports all 2 capability functions", () => {
    expect(typeof listTransactionsSince).toBe("function");
    expect(typeof getAccountBalance).toBe("function");
  });

  it("exports auth helpers (load/save/refresh/shouldRefresh/getTokenAgeStage)", () => {
    expect(typeof loadTokens).toBe("function");
    expect(typeof saveTokens).toBe("function");
    expect(typeof refreshTokens).toBe("function");
    expect(typeof shouldRefresh).toBe("function");
    expect(typeof getTokenAgeStage).toBe("function");
  });

  it("exports OpenBankingCache + full error hierarchy including ConsentExpired + NotImplementedError", () => {
    expect(typeof OpenBankingCache).toBe("function");
    expect(new OpenBankingAuthError("x") instanceof OpenBankingError).toBe(true);
    expect(new OpenBankingConsentExpiredError("x") instanceof OpenBankingAuthError).toBe(true);
    expect(new OpenBankingRateLimitError("x") instanceof OpenBankingError).toBe(true);
    expect(new OpenBankingNotFoundError("x") instanceof OpenBankingError).toBe(true);
    expect(new NotImplementedError("x") instanceof OpenBankingError).toBe(true);
  });
});
