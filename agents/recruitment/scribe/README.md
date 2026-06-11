# Scribe — directory README

**Status:** agent.md Proposed (status flip is founder-gated); bundle BUILT
(W6 build slice, 2026-06-10) — gate-green + fixture-proven; live
Bullhorn/Granola smoke founder-gated (creds + ≥1 recorded meeting).

## What's in this directory

| File | Status |
|---|---|
| `agent.md` | Proposed (CONTRACT; reconciled 2026-06-10 to the Granola poll-sweep + built reality — Fathom/Fireflies reduced to historical notes; §10 status flip still founder-gated) |
| `tools.yaml` | built — Bullhorn W (via `bin/bh-bridge.sh`) + Granola R + voice notes |
| `context.sh` | built — tenant_adapters v0.4 reads, token states, voice/tone hydration |
| `cycle.sh` | built — 10-step per-call workflow (poll-sweep / replay / webhook / dry-run) |
| `validate.sh` | built — Gate A G1-G8 (7 spec-002 §5 checks + word cap) |
| `cleanup.sh` | built — cache purges + last-poll stamp |
| `bin/bh-bridge.sh` | built — single reconciliation point for the @ifos/bullhorn CLI bridge (Janitor-owned package) |
| `bin/extract-fields.sh` | built — deterministic Step 5 extraction (+ opt-in LLM path) |
| `bin/render-tacit-note.sh` | built — deterministic §3 Output 2 renderer (8-category taxonomy) |
| `bin/validate-fields.sh` | built — schema-file-derived name/type/range validator |
| `bin/sla-class.sh` | built — Step 10 SLA bucket computation |
| `fixtures/01-primary.yaml` | golden case (exercised by `scripts/run-scribe-extraction-test.sh`) |
| `fixtures/02-edge-case-paid-only.yaml` | Free-tier degraded notes-only ingest |
| `fixtures/99-voice-drift-blocked.yaml` | adversarial: voice <0.75 → writes blocked |

## Fixture suites (DB-backed; auto-discovered by scripts/build-gate.sh)

- `scripts/run-scribe-extraction-test.sh`
- `scripts/run-scribe-gate-a-test.sh`
- `scripts/run-scribe-sla-test.sh`

## Build summary

`docs/features/agent-build/03-implementation/scribe-summary.md`

## Ratification

Post-build Codex re-ratification via `review-agent-bundle.md` (agent.md §10).

*End of Scribe README.*
