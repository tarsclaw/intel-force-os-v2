// Token-aging property-based tests — covers day 0-100 boundary of the PSD2
// consent lifecycle per goal-w4-day-26 Phase 2 Step 7. Verifies stage
// transitions at the exact day boundaries (7, 14, 30) and post-expiry behaviour.

import { describe, expect, it } from "vitest";
import { getTokenAgeStage } from "../src/auth.js";
import type { OpenBankingTokens, TokenAgeStage } from "../src/types.js";

const DAY_MS = 24 * 60 * 60 * 1000;
const NOW = 1_700_000_000_000; // arbitrary fixed reference time
const fixedNow = (): number => NOW;

function tokensExpiringInDays(days: number): OpenBankingTokens {
  return {
    access_token: "x",
    refresh_token: "x",
    expires_at_ms: NOW + 60 * 60 * 1000,
    consent_expires_at_ms: NOW + days * DAY_MS,
    scope: "accounts transactions balance",
    token_type: "Bearer",
  };
}

describe("getTokenAgeStage — boundary classification", () => {
  it("days > 30 → fresh", () => {
    for (const d of [31, 45, 60, 90, 100]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("fresh");
    }
  });

  it("days 15 .. 30 → info", () => {
    for (const d of [30, 25, 20, 16, 15.001]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("info");
    }
  });

  it("days 8 .. 14 → warn", () => {
    for (const d of [14, 13, 10, 8, 7.001]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("warn");
    }
  });

  it("days 0 .. 7 → blocking", () => {
    for (const d of [7, 6, 3, 1, 0.5, 0]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("blocking");
    }
  });

  it("days negative (already expired) → blocking", () => {
    for (const d of [-0.5, -3, -10, -100]) {
      const r = getTokenAgeStage(tokensExpiringInDays(d), fixedNow);
      expect(r.stage, `day ${d}`).toBe<TokenAgeStage>("blocking");
    }
  });

  it("returns days_until_consent_expiry consistent with input", () => {
    const r = getTokenAgeStage(tokensExpiringInDays(45.5), fixedNow);
    expect(r.days_until_consent_expiry).toBeCloseTo(45.5, 6);
  });
});
