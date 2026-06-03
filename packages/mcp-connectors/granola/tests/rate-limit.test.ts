// Rate-limit tests per review-mcp-connector §3. Verifies soft (80%) and
// hard (100%) thresholds against the per-workspace_id minute bucket
// (conservative 60/min hard default — Granola doesn't publish a per-workspace
// number in the MCP surface docs; 60/min is the safe upper bound that still
// covers Scribe's 5-min poll + transcript-fetch cadence).

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

const WS = "test-workspace-rate-limit";

describe("granola rate-limit (per-workspace_id bucket; 60/min hard)", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check(WS);
    expect(s.minute_used).toBe(0);
    expect(s.minute_remaining).toBe(60);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute-soft threshold (48)", () => {
    for (let i = 0; i < 47; i++) consume(WS);
    const s = check(WS);
    expect(s.minute_used).toBe(47);
    expect(s.shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 48", () => {
    for (let i = 0; i < 48; i++) consume(WS);
    const s = check(WS);
    expect(s.minute_used).toBe(48);
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 60 (consume returns false on the 61st call)", () => {
    for (let i = 0; i < 60; i++) consume(WS);
    const s = check(WS);
    expect(s.minute_used).toBe(60);
    expect(s.reason).toBe("minute-hard");
    expect(consume(WS)).toBe(false);
  });

  it("isolates buckets per workspace_id", () => {
    for (let i = 0; i < 50; i++) consume("ws-A");
    expect(check("ws-A").shouldBackoff).toBe(true);
    expect(check("ws-B").shouldBackoff).toBe(false);
    expect(check("ws-B").minute_used).toBe(0);
  });
});
