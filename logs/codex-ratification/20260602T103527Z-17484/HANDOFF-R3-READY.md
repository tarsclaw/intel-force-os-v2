# Codex Cluster F — Round-2 REJECT closure, Round-3 ready

**Session:** `20260602T103527Z-17484` (Round 2 — actually Round 2 in our round-trip accounting; the script calls each invocation "round 1" internally because it doesn't track cross-invocation state).
**R2 outcome:** REJECTED 3/3 with 10 NEW issues (none repeating R1).
**Fix-bundle authored:** 2026-06-02 (autonomous evening-3 continuation; founder absent).
**Next:** founder re-runs `bash scripts/run-codex-ratification.sh --cluster F`.

## Why R3 is being run (≤2 ceiling exceeded)

See `docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md` for full reasoning. Short version:

- The ≤2 ceiling (learning 01) prevents capricious-nitpick cycles on the SAME issues
- R2 found 10 NEW issues, none repeating R1 — this is healthy Codex behavior
- 6 are self-inflicted by R1 fixes shifting things (citation drift, asymmetric live-test fix, asymmetric error-path fix, stale wording)
- 4 are genuine new findings R1 missed (401-loop bug in 3 client.ts; schema enum mismatch in OB)
- The 401-loop bug is production-critical (server-side-invalidated tokens would loop forever)
- All 10 are defensible-as-stated; none are counter-argument territory
- Founder's standing /goal "ensure we are full ratified" authorizes continued work

## What changed since R2

6 commits closing all 10 R2 issues:

| Commit | What | Tests / Gates |
|---|---|---|
| `587b2ae` | Decision-doc justifying R3 work + risk acknowledgement | n/a |
| `d0cc836` | `@ifos/xero` — 4 R2 issues closed: 401 force-refresh + AUTH-typed throw on retry-exhaust; README citation drift fix (drop volatile line numbers); README live-test honesty (mirrors OB R1 pattern); 2 new daily-bucket tests (burst-pattern clock fitting 5000 calls in 125 of 1440 minute windows) | 28/28 vitest (was 25); typecheck ✓ |
| `f67879f` | `@ifos/quickbooks` — 3 R2 issues closed: same 401 force-refresh pattern; README live-test honesty; "lands later" wording updated to reflect Cash Conductor bundle landed yesterday | 26/26 vitest (was 23); typecheck ✓ |
| `9c79cfb` | `@ifos/open-banking` — 3 R2 issues closed: schema-aligned `plaid-uk` → `plaid_uk` across all 9 src/+tests/+README files; 401 force-refresh + AUTH-typed throw (was generic OpenBankingError); 3 new tests (listTransactionsSince 429-retry-exhaust + getAccountBalance 500-retry-exhaust + 401-forces-refresh-then-retry) | 31/31 vitest (was 28); typecheck ✓ |
| `bed39c6` | State-sync — priorities header refreshed | tree clean |

## The shared 401 bug (worth understanding)

All 3 client.ts files had the same pattern:

```typescript
// BEFORE (broken):
if (res.status === 401 && attempt < max_retries) {
  this.current_tokens = null;          // ← clears cache
  await sleep(backoff(attempt));
  continue;
}
```

The bug: the next iteration calls `getValidAccessToken()` which calls `loadTokens(config)` — reloading the SAME old token from disk. Then `shouldRefresh()` checks `expires_at_ms - now < 5min`. If the token's epoch-expiry is still far in the future (which it is — server-side revocation doesn't update the local timestamp), `shouldRefresh()` returns false, so NO refresh happens. The retry uses the same stale Bearer header → another 401 → loop until retries exhausted.

```typescript
// AFTER (fixed):
if (res.status === 401 && attempt < max_retries) {
  if (this.current_tokens) {
    this.current_tokens = await refreshTokens(
      this.opts.config,
      this.current_tokens,
      this.fetchFn,
    );
  }
  await sleep(backoff(attempt));
  continue;
}
if (res.status === 401) {
  throw new XeroAuthError(/* … AUTH-typed so consumer maps to ESC_ACCOUNTING_AUTH … */);
}
```

The new tests assert that the OAuth refresh endpoint is hit between the failed 401 GET and the retried-GET, AND that the retried-GET uses the rotated Bearer token. Would have FAILED against the pre-fix code.

## Per-package quality gates (all green)

| Package | typecheck | vitest | boundary |
|---|---|---|---|
| `@ifos/xero` | ✓ CLEAN | ✓ 28/28 | ✓ 0 violations |
| `@ifos/quickbooks` | ✓ CLEAN | ✓ 26/26 | ✓ 0 violations |
| `@ifos/open-banking` | ✓ CLEAN | ✓ 31/31 | ✓ 0 violations |

**Total: 85/85 tests passing across all 3 packages.**

## Round-3 instructions

```bash
cd ~/code/CortexOS
bash scripts/run-codex-ratification.sh --cluster F
```

Expected outcome: `RATIFIED: 3   REJECTED: 0`.

**Risk if R3 still rejects:** per the decision-doc's "Risk + diminishing returns" section, pause and escalate to founder. Don't auto-proceed to R4. We'd be looking at either a Codex skill limitation (review-mcp-connector keeps finding new things on each pass — the skill needs hardening) or a structural connector issue we should redesign.

## What this run does NOT touch

- Production credentials (none entered chat; none required).
- Live API calls (all tests are fixture-backed).
- Ratified artefacts outside scope (agent.md files at cluster-E layer untouched).
- Codex round-trip count for clusters E, A-D, Fbis, or G (this fix bundle is cluster-F-scoped).

— end —
