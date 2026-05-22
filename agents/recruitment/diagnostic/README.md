# Diagnostic — directory README

**Status:** Proposed (Day-11 pre-build scaffold; awaits W3-4 build slice).

## What's in this directory

| File | What it is | Status |
|---|---|---|
| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed (Day-11 draft) |
| `README.md` | This file — positions the directory | Proposed |

## What's NOT in this directory (yet)

Per master brief §3.1 boundary 1 + ADR-003 (agent bundle v2 pattern), a full agent bundle is 6 files + 3 fixtures:

| File | Purpose | Builds at |
|---|---|---|
| `tools.yaml` | MCP tool declarations (Companies House + LinkedIn read-only + web scraper) | W3 build start |
| `context.sh` | Session hydration (voice corpus + target_patch + tone rules) | W3 build start |
| `validate.sh` | Gate A enforcement (12 sections + per-section citation + voice ≥ 0.75 + PII boundary) | W3 build start |
| `cycle.sh` | Workflow orchestration (10-step process from agent.md §4) | W3 build start |
| `cleanup.sh` | Post-render cleanup (drop raw LinkedIn profile data per ToS gotcha §6.1) | W3 build start |
| `fixtures/01-primary.yaml` | Golden case: well-formed UK fintech recruitment firm | W3 build start |
| `fixtures/02-edge-case-no-online-footprint.yaml` | Edge case: firm with placeholder website + no LinkedIn page | W3 build start |
| `fixtures/99-voice-drift-canary.yaml` | Adversarial: forces voice classifier near threshold | W3 build start |

## Why this directory exists at Day 11 (pre-Q1 LOI)

Master brief §1 Rule 1 demands "Output before architecture." The agent.md output contract can be authored without any customer present — it's a self-contained description of what the agent produces. Pre-writing the output contract:

1. **Frees W3 build slice** to focus on the 5 other bundle files + 3 fixtures, not iterating on the contract under deadline pressure
2. **Surfaces design questions early** (e.g., what are the 12 sections? — answered in agent.md §3 + open questions §9)
3. **Provides a ratification target** — Codex can review `agent.md` during a Round-4+ pass without W3 build being complete
4. **Demonstrates Rule 1 discipline** — output contract IS the first artefact, not the last

## What ratifies this directory

Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this directory ratifies as a unit when the full 6-file + 3-fixture bundle exists.

Until then, individual files (this README + agent.md) ratify via `review-architecture-decision.md` skill on their own ratification queue position.

## Pre-W3 build gate

Per agent.md §8, the W3 build slice DOES NOT START until:

- ✅ Renderer + `_shared/` substrate ratified (Round 3, commit `45f3f42`)
- ⏸ Live VPS migration applied (`scripts/run-live-migration.sh`)
- ⏸ Tenancy audit passes 12 invariants (`scripts/run-tenancy-audit.sh`)
- ⏸ Q1 design partner LOI signed
- ⏸ `target_patch.json` for first pilot tenant
- ⏸ Voice corpus seeded for first pilot tenant
- ⏸ Companies House + LinkedIn MCP connectors built
- ⏸ `validate.sh` Gate A logic built
- ⏸ Bundle fixtures with golden outputs

Until all ⏸ items resolve → ✅, this directory holds the output contract only.

*End of README.*
