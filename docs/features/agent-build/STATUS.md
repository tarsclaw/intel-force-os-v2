# Agent-build STATUS board

_Orchestrator refreshes this at every milestone (method doc §5). Founder reads it for an
at-a-glance view. `git log`/branch diffs are the ground truth._

**Phase:** 0 (pre-fan-out). Gates built; specs authored; substrate-freeze + prove-one pending.

| Agent | Spec | Phase | Status | Branch | Live-smoke capable now? |
|---|---|---|---|---|---|
| Diagnostic | — | — | ✅ LIVE (template #1) | `main` | yes (Companies House + Anthropic) |
| Cash Conductor | — | — | ✅ LIVE (template #2) | `main` | yes (QB/Xero/TrueLayer sandboxes) |
| Sourcing Scout | `spec-003-sourcing-scout.md` | 1 (PROVE-ONE) | ⚪ not started | — | **YES via CV-Library** (degraded mode) — the live pilot; Reed/Bullhorn blocked |
| Janitor | `spec-001-janitor.md` | 2 | ⚪ not started | — | partial — Companies House yes; **Bullhorn BLOCKED** |
| Scribe | `spec-002-scribe.md` | 2 | ⚪ not started | — | no — **Bullhorn BLOCKED** + Granola token/0-meetings |
| Concierge | `spec-004-concierge.md` | 4 (last) | ⚪ not started | — | no — Bullhorn + autosend-bridge wiring + email OAuth |

## Gate readiness (method doc §4)
- ✅ Worktree isolation — available (`Agent` tool `isolation: "worktree"`).
- ✅ Pre-commit hook — `.githooks/pre-commit` active (`core.hooksPath=.githooks`); blocks broken-shell commits.
- ✅ Merge gate — `scripts/build-gate.sh` (green on current tree).
- ⏸ Review tier — review sub-agent prompt + `run-codex-ratification.sh` per branch (orchestrator runs at review).
- ✅ Human merge gate — founder.

## Cross-cutting truths (read before fan-out)
1. **Bullhorn dev creds are unobtainable** (long-standing blocker). Janitor/Scribe/Concierge cores
   hit Bullhorn → they BUILD to gate-green + fixture-proven, but **live-Bullhorn-smoke is a
   founder-gated post-creds step.** Acceptance bar for those = fixture-proven + gate-green.
2. **Sourcing Scout is the only fully live-smokeable remaining agent now** (CV-Library creds SET,
   read-only on Bullhorn → degraded-mode skips it). Best live prove-one demo.
3. **Concierge's autosend-bridge production wiring (its W10-13 deliverable) also unblocks Cash
   Conductor's drafts-only→orange-send path** — build it once, two agents go live.
4. Empty `voice_corpus` → record `unscored/no_corpus`, never a faked score (CC precedent).

## Founder actions that unblock LIVE (build proceeds without them)
- Bullhorn dev sandbox creds (unblocks Janitor/Scribe/Concierge + Sourcing Scout source #1).
- Reed API creds (unblocks Sourcing Scout source #2).
- Granola IFOS-side OAuth token on disk + ≥1 recorded meeting (unblocks Scribe live transcript).
- MS Graph / Gmail OAuth per tenant (unblocks Concierge live send).
- Apply v0.5 migration to prod VPS (unblocks Cash Conductor prod reconciliation writes).
