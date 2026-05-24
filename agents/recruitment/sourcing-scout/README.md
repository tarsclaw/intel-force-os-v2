# Sourcing Scout — directory README

**Status:** Proposed (Day-19 pre-W9-build scaffold).

## What's in this directory

| File | Status |
|---|---|
| `agent.md` | Proposed |
| `README.md` | Proposed |

## What's NOT in this directory (yet)

Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):

- `tools.yaml` — Bullhorn R + Proxycurl + Reed + CV-Library + source-abstraction layer
- `context.sh` — multi-source auth refresh + voice corpus + DNC list load
- `validate.sh` — Gate A (5-15 candidates + contact method + ≥50 words + DNC + voice ≥0.75)
- `cycle.sh` — 11-step workflow
- `cleanup.sh` — cache cleanup + per-source token rotation
- `fixtures/01-primary-perm-fintech.yaml` — golden: perm role, ≥10 candidates from 4 sources
- `fixtures/02-edge-case-niche-role.yaml` — niche role: only 5-7 candidates available
- `fixtures/99-dnc-filter-canary.yaml` — adversarial: many candidates hit DNC list

## Night Sourcer (v1.1) reuse

Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.

## Ratification

Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.

*End of Sourcing Scout README.*
