// Rate-limit tests per review-mcp-connector §3. Verifies soft (80%) and
// hard (100%) thresholds against the per-account_id minute bucket (60/min
// hard default; Reed does not publish exact rate-limit numbers; v0.1.0
// conservative default well above expected Sourcing Scout poll cadence).

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

const ACCT = "test-account-rate-limit";

describe("reed rate-limit (per-account_id bucket; 60/min hard)", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check(ACCT);
    expect(s.minute_used).toBe(0);
    expect(s.minute_remaining).toBe(60);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute-soft threshold (48)", () => {
    for (let i = 0; i < 47; i++) consume(ACCT);
    const s = check(ACCT);
    expect(s.minute_used).toBe(47);
    expect(s.shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 48", () => {
    for (let i = 0; i < 48; i++) consume(ACCT);
    const s = check(ACCT);
    expect(s.minute_used).toBe(48);
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 60 (consume returns false on the 61st call)", () => {
    for (let i = 0; i < 60; i++) consume(ACCT);
    const s = check(ACCT);
    expect(s.minute_used).toBe(60);
    expect(s.reason).toBe("minute-hard");
    expect(consume(ACCT)).toBe(false);
  });

  it("isolates buckets per account_id", () => {
    for (let i = 0; i < 50; i++) consume("acct-A");
    expect(check("acct-A").shouldBackoff).toBe(true);
    expect(check("acct-B").shouldBackoff).toBe(false);
    expect(check("acct-B").minute_used).toBe(0);
  });
});
