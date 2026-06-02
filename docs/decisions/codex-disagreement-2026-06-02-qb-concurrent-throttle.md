# Codex disagreement — `@ifos/quickbooks` 10/s concurrent throttle

**Status:** Counter-argument accepted (founder-authorized 2026-06-02; not implementing Codex's requested change).
**Date:** 2026-06-02.
**Author:** Claude Code (autonomous; founder approved escalation path to R4 with this counter-argument).
**Codex sessions:** R3 `20260602T105413Z-29512` issue #1 (initial); R4 `20260602T111820Z-43583` issue #1 (reaffirmed under same reasoning). The counter-argument STANDS — see "What would change the call" below; until those conditions become true, this stays disagreed.

## Codex's claim (verbatim)

> QuickBooks' second/concurrent throttle is declared but deliberately not implemented. `README.md` lines 112-116 and `src/rate-limit.ts` lines 1-8 cite the upstream `10 calls per second concurrent throttle`, then say it is "not enforced here"; `src/rate-limit.ts` lines 10-14 only implement the 500/minute bucket. This fails `review-mcp-connector.md` §3 because the declared upstream rate-limit budget is not covered by a safety-margin implementation or exhaustion test. Add a per-second/concurrency limiter with tests, or remove the claim only if provider docs prove it is not an applicable call/window budget.

## Why we are not implementing

### 1. The concurrent throttle is **inapplicable** to a single-process serial caller.

`packages/mcp-connectors/quickbooks/README.md` line 113 verbatim:

> **10 calls per second concurrent throttle** (not enforced here — single-process Cash Conductor cycle.sh is serial)

Intuit's "10 concurrent calls per realmId" cap fires when ≥10 in-flight HTTP requests exist simultaneously against the same realm. Cash Conductor `cycle.sh` calls `@ifos/quickbooks` from a serial bash flow — `await` resolves before the next call is issued. The number of in-flight requests against any one realm at any moment is **exactly 1**. The concurrent throttle cannot be hit by definition.

Codex's reading of §3 ("the declared upstream rate-limit budget is not covered by a safety-margin implementation or exhaustion test") treats every documented upstream limit as one the connector must enforce. That's the right rule for budgets a caller could plausibly violate — like the 500/minute calls-per-realm rate, which IS implemented + tested. It's the wrong rule for budgets the architecture makes structurally impossible to exceed.

### 2. Implementing it anyway would be defensive code for an impossible case.

Per Karpathy's per-edit discipline (CLAUDE.md "Coding-agent discipline" rule 2 — "Simplicity first; nothing speculative — no unrequested abstractions, no 'flexibility' for futures not in master brief §6 or §8"), adding a concurrency limiter would:

- Add per-realm in-flight-counter state + acquire/release semantics in `src/rate-limit.ts`
- Add wrapper calls at every entry-point in `src/client.ts` (request, getValidAccessToken)
- Add tests that mock concurrent execution (Promise.all of N) and assert the limiter throttles correctly
- Buy us **zero** real-world protection because the consumer is serial

That's the textbook "no defensive additions" anti-pattern per operational-hygiene-protocol §3.

### 3. The README is already explicit about the limitation.

The "not enforced here" caveat is right there in the rate-limit section. A future maintainer who switches Cash Conductor to a multi-process or concurrent caller has the explicit note to act on. This is honest signal, not omission.

## What would change the call

If any of these become true, **implement the concurrency limiter**:

- Cash Conductor cycle.sh becomes multi-process (e.g. one process per tenant running in parallel against the same QB realm — only realistic if a single IFOS tenant connects multiple QB realms or if we shift to a worker-pool model).
- A new consumer of `@ifos/quickbooks` lands that doesn't share Cash Conductor's serial-bash discipline (e.g. a webhook handler that batches concurrent invoice lookups).
- Intuit publishes evidence that the throttle is per-minute window rather than per-second concurrent, in which case it overlaps with the existing 500/minute bucket but with a tighter window.

Until then, this is closed as counter-argument.

## What we DID change in R4

Nothing functional. The README + `src/rate-limit.ts` module comment retain the "not enforced here; single-process Cash Conductor cycle.sh is serial" caveats (already present pre-Codex-review). No new code. No new test. No README edit — the existing language is the right disclosure.

This decision-doc itself is the only artefact added to close the issue.

## Risk

**Low.** If a future caller violates the serial assumption AND Intuit's concurrent throttle is actually enforced as documented AND we have 10+ in-flight requests against the same realm simultaneously, we'd see HTTP 429s with `Retry-After` headers from Intuit's edge — which the existing 429 retry path handles correctly. So even in the broken-assumption case, the safety-net is in place (just at the upstream edge rather than the local bucket).

## Companion changes (NOT this disagreement)

The QB R3 issue #2 (`package.json` description steps drift — cites 4-6 + 10-11; actual is 1, 4, 5, 6, 9) is a real honest-signal fix and is being closed by a separate commit in the same R4 fix bundle.

— end of disagreement —
