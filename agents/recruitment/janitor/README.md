# Janitor — directory README

**Status:** Proposed (Day-16 pre-W5-build scaffold; awaits Bullhorn A+B + Q1 LOI + W5 build slice).

## What's in this directory

| File | What it is | Status |
|---|---|---|
| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed |
| `README.md` | This file | Proposed |

## What's NOT in this directory (yet)

Full agent bundle per ADR-003: 6 files + 3 fixtures. Built at W5 start (~2 weeks per ULTRAPLAN A2 line 512):

- `tools.yaml` — MCP declarations: Bullhorn R+W, Companies House, voice classifier
- `context.sh` — Session hydration (Bullhorn auth refresh + voice corpus + recent edits)
- `validate.sh` — Gate A (dedup confidence ≥0.85 + activity-window 90d + field-source confidence ≥0.7 + voice ≥0.75 + PII boundary + Bullhorn batch ≤100/min)
- `cycle.sh` — 12-step workflow (per agent.md §4)
- `cleanup.sh` — Post-run cleanup (rotate Bullhorn refresh token; flush stale cache)
- `fixtures/01-primary-1000-candidates.yaml` — Golden case: clean tenant, ~15% expected dedup
- `fixtures/02-edge-case-no-duplicates.yaml` — Edge case: zero dedup proposals (graceful "no action" report)
- `fixtures/99-merge-confidence-canary.yaml` — Adversarial: confidence just below 0.85 — Gate A must reject

## Build dependencies (per agent.md §8)

Janitor W5 build slice gated on:
- Bullhorn Sub-decisions A+B Accepted (per Bullhorn partnerships form submitted 2026-05-24)
- First pilot tenant onboarded (per Q1 LOI signing)
- Bullhorn MCP connector built (W3-W4 conditional per ADR-005)

## Ratification

Per `.codex/ratification/review-architecture-decision.md` skill. Queued for Codex Round 4 Phase 2 (Day 20).

*End of Janitor README.*
