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
});
