// Package public surface smoke tests. Per review-mcp-connector §1
// (capabilities surface — exports match README capability table).

import { describe, expect, it } from "vitest";
import {
  VERSION,
  QbClient,
  QB_BASE_URL_PRODUCTION,
  QB_BASE_URL_SANDBOX,
  loadTokens,
  saveTokens,
  refreshTokens,
  shouldRefresh,
  refreshTokenNearExpiry,
  listOpenInvoices,
  getInvoice,
  listPayments,
  writePaymentReceived,
  QbCache,
  QbError,
  QbAuthError,
  QbRateLimitError,
  QbNotFoundError,
  QbValidationError,
} from "../src/index.js";

describe("@ifos/quickbooks package surface", () => {
  it("exports VERSION 0.1.0", () => {
    expect(VERSION).toBe("0.1.0");
  });

  it("exports QbClient class + base URLs (production + sandbox)", () => {
    expect(typeof QbClient).toBe("function");
    expect(QB_BASE_URL_PRODUCTION).toBe("https://quickbooks.api.intuit.com");
    expect(QB_BASE_URL_SANDBOX).toBe("https://sandbox-quickbooks.api.intuit.com");
  });

  it("exports all 4 capability functions", () => {
    expect(typeof listOpenInvoices).toBe("function");
    expect(typeof getInvoice).toBe("function");
    expect(typeof listPayments).toBe("function");
    expect(typeof writePaymentReceived).toBe("function");
  });

  it("exports auth helpers (load/save/refresh/shouldRefresh/refreshTokenNearExpiry)", () => {
    expect(typeof loadTokens).toBe("function");
    expect(typeof saveTokens).toBe("function");
    expect(typeof refreshTokens).toBe("function");
    expect(typeof shouldRefresh).toBe("function");
    expect(typeof refreshTokenNearExpiry).toBe("function");
  });

  it("exports QbCache + error hierarchy", () => {
    expect(typeof QbCache).toBe("function");
    expect(new QbAuthError("x") instanceof QbError).toBe(true);
    expect(new QbRateLimitError("x") instanceof QbError).toBe(true);
    expect(new QbNotFoundError("x") instanceof QbError).toBe(true);
    expect(new QbValidationError("x") instanceof QbError).toBe(true);
  });
});
