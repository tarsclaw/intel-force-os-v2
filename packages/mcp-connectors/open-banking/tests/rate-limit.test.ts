// Rate-limit tests per review-mcp-connector §3 (bucket-exhaustion test
// MUST exist). Verifies soft (80%) + hard (100%) thresholds, multi-provider
// + multi-connection isolation.

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

describe("open-banking rate-limit", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check("truelayer", "acct-1");
    expect(s.minute_used).toBe(0);
    expect(s.minute_remaining).toBe(30);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute soft threshold (24)", () => {
    for (let i = 0; i < 23; i++) consume("truelayer", "acct-1");
    expect(check("truelayer", "acct-1").shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 24", () => {
    for (let i = 0; i < 24; i++) consume("truelayer", "acct-1");
    const s = check("truelayer", "acct-1");
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 30 (consume returns false)", () => {
    for (let i = 0; i < 30; i++) consume("truelayer", "acct-1");
    expect(check("truelayer", "acct-1").reason).toBe("minute-hard");
    expect(consume("truelayer", "acct-1")).toBe(false);
  });

  it("isolates buckets per (provider, connection_id) pair", () => {
    for (let i = 0; i < 25; i++) consume("truelayer", "acct-A");
    expect(check("truelayer", "acct-A").shouldBackoff).toBe(true);
    expect(check("truelayer", "acct-B").shouldBackoff).toBe(false);
    expect(check("plaid-uk", "acct-A").shouldBackoff).toBe(false);
  });
});
