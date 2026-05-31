// Package public surface smoke tests. Per review-mcp-connector §1
// (capabilities surface — exports match README capability table).

import { describe, expect, it } from "vitest";
import {
  VERSION,
  XeroClient,
  XERO_BASE_URL,
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  listOpenInvoices,
  getInvoice,
  listPayments,
  writePaymentReceived,
  XeroCache,
  XeroError,
  XeroAuthError,
  XeroRateLimitError,
  XeroNotFoundError,
  XeroValidationError,
} from "../src/index.js";

describe("@ifos/xero package surface", () => {
  it("exports VERSION 0.1.0", () => {
    expect(VERSION).toBe("0.1.0");
  });

  it("exports XeroClient class + base URL", () => {
    expect(typeof XeroClient).toBe("function");
    expect(XERO_BASE_URL).toBe("https://api.xero.com/api.xro/2.0");
  });

  it("exports all 4 capability functions", () => {
    expect(typeof listOpenInvoices).toBe("function");
    expect(typeof getInvoice).toBe("function");
    expect(typeof listPayments).toBe("function");
    expect(typeof writePaymentReceived).toBe("function");
  });

  it("exports auth helpers (load/save/refresh/shouldRefresh)", () => {
    expect(typeof loadTokens).toBe("function");
    expect(typeof saveTokens).toBe("function");
    expect(typeof refreshTokens).toBe("function");
    expect(typeof shouldRefresh).toBe("function");
  });

  it("exports XeroCache + error hierarchy", () => {
    expect(typeof XeroCache).toBe("function");
    // All error classes extend XeroError
    expect(new XeroAuthError("x") instanceof XeroError).toBe(true);
    expect(new XeroRateLimitError("x") instanceof XeroError).toBe(true);
    expect(new XeroNotFoundError("x") instanceof XeroError).toBe(true);
    expect(new XeroValidationError("x") instanceof XeroError).toBe(true);
  });
});
