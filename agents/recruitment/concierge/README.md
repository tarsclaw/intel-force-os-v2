# Concierge — directory README

**Status:** Proposed (Day-19 pre-W10-13-build scaffold).

## What's in this directory

| File | Status |
|---|---|
| `agent.md` | Proposed |
| `README.md` | Proposed |

## What this is

The customer-comms agent. Highest-stakes v1.0 agent (XL complexity, 4 weeks build). 12 lifecycle events × 2 recipient roles = 24+ comms-template variants per tenant. Orange-tier autosend per `autosend-safety-policy.yaml` — consultant approval mandatory before send.

## What's NOT in this directory (yet)

Full bundle at W10-13 build (~4 weeks per ULTRAPLAN A6 line 568 XL flag):

- `tools.yaml` — Bullhorn R+W + Microsoft Graph + Gmail + voice classifier + autosend bridge (per D1 outcome)
- `context.sh` — multi-source auth + voice corpus + comms-template library + addressee-resolution data
- `validate.sh` — Gate A (SLA 30 min + voice ≥0.75 per-position + addressee + tone-rule + PII + anti-duplicate) — most complex validator of v1.0
- `cycle.sh` — 15-step workflow with lifecycle state machine
- `cleanup.sh` — token rotation + 14-day decision_log retention check
- `fixtures/01-primary-interview-completed.yaml` — golden case
- `fixtures/02-edge-case-rejection.yaml` — position-3 voice ≥0.82 test
- `fixtures/03-edge-case-90day-checkin.yaml` — nurture sweep
- `fixtures/04-edge-case-missed-webhook-poll-recovery.yaml` — polling fallback test
- `fixtures/99-addressee-mismatch-canary.yaml` — Gate A blocker (wrong recipient)

5 fixtures (broader than 3-fixture pattern) warranted by XL complexity.

## Critical pre-requisite

**Founder Decision D1 (autosend orange-tier path) MUST be resolved before W10 build starts.** Per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Three options:
- D1-A: bridge to cortextOS approval system (most powerful; ~3 days dev)
- D1-B: lightweight Telegram shim (recommended for v1.0 ship; ~1 day dev)
- D1-C: no autosend; manual consultant pickup (0 dev; ships fastest but worst UX)

## Ratification

Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.

*End of Concierge README.*
