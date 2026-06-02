// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
// MUST exist). Verifies soft (80%) and hard (100%) thresholds against
// both the 60/min and 5000/day Xero buckets.

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

const TENANT = "test-tenant-rate-limit";

describe("xero rate-limit", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check(TENANT);
    expect(s.minute_used).toBe(0);
    expect(s.daily_used).toBe(0);
    expect(s.minute_remaining).toBe(60);
    expect(s.daily_remaining).toBe(5000);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute soft threshold (48)", () => {
    for (let i = 0; i < 47; i++) consume(TENANT);
    const s = check(TENANT);
    expect(s.minute_used).toBe(47);
    expect(s.shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 48", () => {
    for (let i = 0; i < 48; i++) consume(TENANT);
    const s = check(TENANT);
    expect(s.minute_used).toBe(48);
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 60 (consume returns false)", () => {
    for (let i = 0; i < 60; i++) consume(TENANT);
    const s = check(TENANT);
    expect(s.minute_used).toBe(60);
    expect(s.reason).toBe("minute-hard");
    // Bucket exhausted — consume must return false
    expect(consume(TENANT)).toBe(false);
  });

  it("isolates buckets per tenant_id", () => {
    for (let i = 0; i < 50; i++) consume("tenant-A");
    expect(check("tenant-A").shouldBackoff).toBe(true);
    expect(check("tenant-B").shouldBackoff).toBe(false);
    expect(check("tenant-B").minute_used).toBe(0);
  });

  // Daily-bucket coverage per Codex F-R2 issue #4 — README + module comment
  // claim daily soft (4000) + hard (5000) coverage; this section closes the
  // gap. Strategy: burst 40 calls (under the 48/min soft) per minute window,
  // then tick to the next minute. After 100 bursts → 4000 daily. After 125
  // bursts → 5000 daily. Fits comfortably under the 1440 minute-windows-per-day
  // budget (we use 125 of 1440). check() reports daily-soft / daily-hard
  // because the cascade checks daily BEFORE minute-soft.
  describe("daily bucket (5000/day per Xero published limit)", () => {
    function burstClock(start = 0) {
      let t = start;
      return {
        nowMs: () => t,
        advanceToNextMinute: () => {
          t += 60_001;
        },
      };
    }

    function burstFill(tenant: string, totalCalls: number, perBurst = 40) {
      const clk = burstClock();
      let done = 0;
      while (done < totalCalls) {
        const burst = Math.min(perBurst, totalCalls - done);
        for (let i = 0; i < burst; i++) consume(tenant, clk.nowMs);
        done += burst;
        if (done < totalCalls) clk.advanceToNextMinute();
      }
      return clk;
    }

    it("triggers daily-soft backoff at 4000 used", () => {
      const clk = burstFill(TENANT, 4000);
      const s = check(TENANT, clk.nowMs);
      expect(s.daily_used).toBe(4000);
      expect(s.shouldBackoff).toBe(true);
      expect(s.reason).toBe("daily-soft");
    });

    it("blocks at daily-hard 5000 (consume returns false on the 5001st call)", () => {
      const clk = burstFill(TENANT, 5000);
      const s = check(TENANT, clk.nowMs);
      expect(s.daily_used).toBe(5000);
      expect(s.reason).toBe("daily-hard");
      // Bucket exhausted — consume must return false
      expect(consume(TENANT, clk.nowMs)).toBe(false);
    });
  });
});
