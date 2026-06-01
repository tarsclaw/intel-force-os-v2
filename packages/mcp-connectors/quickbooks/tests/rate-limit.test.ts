// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
// MUST exist). Verifies soft (80%) and hard (100%) thresholds against
// the 500/min Intuit bucket.

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

const REALM = "test-realm-rate-limit";

describe("quickbooks rate-limit", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check(REALM);
    expect(s.minute_used).toBe(0);
    expect(s.minute_remaining).toBe(500);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute soft threshold (400)", () => {
    for (let i = 0; i < 399; i++) consume(REALM);
    const s = check(REALM);
    expect(s.minute_used).toBe(399);
    expect(s.shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 400", () => {
    for (let i = 0; i < 400; i++) consume(REALM);
    const s = check(REALM);
    expect(s.minute_used).toBe(400);
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 500 (consume returns false)", () => {
    for (let i = 0; i < 500; i++) consume(REALM);
    const s = check(REALM);
    expect(s.minute_used).toBe(500);
    expect(s.reason).toBe("minute-hard");
    expect(consume(REALM)).toBe(false);
  });

  it("isolates buckets per realm_id", () => {
    for (let i = 0; i < 450; i++) consume("realm-A");
    expect(check("realm-A").shouldBackoff).toBe(true);
    expect(check("realm-B").shouldBackoff).toBe(false);
    expect(check("realm-B").minute_used).toBe(0);
  });
});
