# Scribe — directory README

**Status:** Proposed (Day-17 pre-W6-build scaffold).

## What's in this directory

| File | Status |
|---|---|
| `agent.md` | Proposed |
| `README.md` | Proposed |

## What's NOT in this directory (yet)

Full bundle at W6 build (~1 week per ULTRAPLAN A3 line 526):

- `tools.yaml` — Bullhorn W + Fathom R + Fireflies R + voice classifier
- `context.sh` — webhook handler + Bullhorn auth refresh + voice corpus
- `validate.sh` — Gate A (≥3 fields × confidence ≥0.6 + voice ≥0.75 + PII boundary)
- `cycle.sh` — 10-step workflow
- `cleanup.sh` — purge /tmp transcript + rotate token
- `fixtures/01-primary-briefing-call.yaml` — golden case
- `fixtures/02-edge-case-short-call.yaml` — 2-min call, minimal extractable fields
- `fixtures/99-pii-outside-boundary-canary.yaml` — adversarial: transcript references non-tenant PII

## Ratification

Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.

*End of Scribe README.*
