// Rate-limit tests per review-mcp-connector §3. Verifies soft (80%) and
// hard (100%) thresholds against the per-corporation_id minute bucket
// (conservative 600/min default — Bullhorn doesn't publish an exact limit
// per "Fair Use Policy"; community sources suggest ~10/sec sustained).

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

const CORP = "test-corporation-rate-limit";

describe("bullhorn rate-limit (per-corporation_id bucket; 600/min hard)", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check(CORP);
    expect(s.minute_used).toBe(0);
    expect(s.minute_remaining).toBe(600);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute-soft threshold (480)", () => {
    for (let i = 0; i < 479; i++) consume(CORP);
    const s = check(CORP);
    expect(s.minute_used).toBe(479);
    expect(s.shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 480", () => {
    for (let i = 0; i < 480; i++) consume(CORP);
    const s = check(CORP);
    expect(s.minute_used).toBe(480);
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 600 (consume returns false on the 601st call)", () => {
    for (let i = 0; i < 600; i++) consume(CORP);
    const s = check(CORP);
    expect(s.minute_used).toBe(600);
    expect(s.reason).toBe("minute-hard");
    // Bucket exhausted — consume must return false
    expect(consume(CORP)).toBe(false);
  });

  it("isolates buckets per corporation_id", () => {
    for (let i = 0; i < 500; i++) consume("corp-A");
    expect(check("corp-A").shouldBackoff).toBe(true);
    expect(check("corp-B").shouldBackoff).toBe(false);
    expect(check("corp-B").minute_used).toBe(0);
  });
});
