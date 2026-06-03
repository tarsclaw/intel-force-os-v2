// Rate-limit tests per review-mcp-connector §3. Verifies soft (80%) and
// hard (100%) thresholds against the per-org_id minute bucket (6000/min hard
// — WorkOS published quota is ~100 RPS per account; v1.0 default per-org
// slice is 6000/min sustained; matches Bullhorn's per-corp budget cadence).

import { beforeEach, describe, expect, it } from "vitest";
import { check, consume, reset } from "../src/rate-limit.js";

const ORG = "test-org-rate-limit";

describe("workos rate-limit (per-org_id bucket; 6000/min hard)", () => {
  beforeEach(() => {
    reset();
  });

  it("starts at 0 used with full budget", () => {
    const s = check(ORG);
    expect(s.minute_used).toBe(0);
    expect(s.minute_remaining).toBe(6000);
    expect(s.shouldBackoff).toBe(false);
    expect(s.reason).toBe("ok");
  });

  it("does NOT backoff before minute-soft threshold (4800)", () => {
    for (let i = 0; i < 4799; i++) consume(ORG);
    const s = check(ORG);
    expect(s.minute_used).toBe(4799);
    expect(s.shouldBackoff).toBe(false);
  });

  it("triggers minute-soft backoff at 4800", () => {
    for (let i = 0; i < 4800; i++) consume(ORG);
    const s = check(ORG);
    expect(s.minute_used).toBe(4800);
    expect(s.shouldBackoff).toBe(true);
    expect(s.reason).toBe("minute-soft");
  });

  it("blocks at minute-hard 6000 (consume returns false on the 6001st call)", () => {
    for (let i = 0; i < 6000; i++) consume(ORG);
    const s = check(ORG);
    expect(s.minute_used).toBe(6000);
    expect(s.reason).toBe("minute-hard");
    // Bucket exhausted — consume must return false
    expect(consume(ORG)).toBe(false);
  });

  it("isolates buckets per org_id", () => {
    for (let i = 0; i < 5000; i++) consume("org-A");
    expect(check("org-A").shouldBackoff).toBe(true);
    expect(check("org-B").shouldBackoff).toBe(false);
    expect(check("org-B").minute_used).toBe(0);
  });

  it("uses 'global' bucket separately from any specific org bucket", () => {
    for (let i = 0; i < 4800; i++) consume("global");
    expect(check("global").shouldBackoff).toBe(true);
    expect(check("org-Z").shouldBackoff).toBe(false);
  });
});
