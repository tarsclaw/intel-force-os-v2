# Sourcing Scout — directory README

**Status:** W9 build slice COMPLETE (spec-003) — full bundle LIVE, pending Codex
re-ratification of the built bundle + founder Q1/Q3/Q5 approvals per agent.md §10.

Request-response passive sourcing: brief in → ranked 5-15 candidate Markdown
report out, aggregated across Bullhorn (read-only) + Reed + CV-Library
(LinkedIn NO-OP at v1.0 per the Proxycurl shutdown caveat in `agent.md`).

## What's in this directory

| File | Status |
|---|---|
| `agent.md` | The CONTRACT (Ratified-as-Scaffold; binding spec for this build) |
| `tools.yaml` | LIVE — capability set; @ifos/reed + @ifos/cv-library scaffolded v0.1.0 |
| `context.sh` | LIVE — canonical tenant_adapters SELECTs + per-source auth state + voice/DNC/firm-domain hydration |
| `cycle.sh` | LIVE — 11-step workflow per spec-003 §4 (all decision_log markers + ESC routes) |
| `validate.sh` | LIVE — Gate A G1-G7 per spec-003 §5 (validate_gate_a_fail + per-class ESC routing) |
| `cleanup.sh` | LIVE — TTL cache purge + stale /tmp partial-draft removal |
| `bin/fuzzy-match.sh` | Carried copy of the Janitor matcher (≥0.85; reconcile when Janitor lands its helper) |
| `bin/parse-brief.sh` | Deterministic free-text brief parser (LLM parse = documented enhancement) |
| `bin/render-rationale.sh` | Deterministic ≥50-word rationale renderer (CC templated-draft pattern) |
| `bin/render-scout-report.sh` | agent.md §3 Markdown report renderer (+ `--partial` banner) |
| `fixtures/01-primary.yaml` | Happy path: 18→15 dedupe → 2 DNC → 13 final; Gate A PASS |
| `fixtures/02-edge-case-degraded-sources.yaml` | Bullhorn auth-skip + Reed 429 → 3 < 5 floor; Gate A FAIL |
| `fixtures/99-dnc-bulk-filter.yaml` | 9/12 DNC bulk drop → floor FAIL + exception-list visibility |

Fixture test suites (build-gate auto-discovered): `scripts/run-scout-dedupe-test.sh`,
`scripts/run-scout-gate-a-test.sh`, `scripts/run-scout-degraded-test.sh`.

## Honest scope (spec-003 §8)

- Bullhorn + Reed creds EMPTY → per-source degraded-skip (ESC_*_AUTH), never faked.
- CV-Library is the live source — wired via `@ifos/cv-library dist/cli.js`
  (`check-auth` + `search-candidates`); the live smoke is the orchestrator's
  post-build step. Tests run on deterministic `IFOS_SCOUT_FIXTURE_*` files.
- Voice: empty `voice_corpus` → rationales recorded `unscored/no_corpus`;
  Gate A G4 warns-when-unscored, hard once the classifier lands.
- DNC drops at sourcing time → exception list only; no ESC fire
  (ESC_SOURCING_DNC_FILTER is W4-polish backlog).

## Night Sourcer (v1.1) reuse

The source-abstraction layer (single `_scout_query_source()` path over
per-source mapping config + the unified candidate shape normalised in each
connector CLI) is the Night Sourcer reuse surface per ULTRAPLAN A5 line 555.
The source-abstraction ADR (agent.md §9 Q6) is still to be authored.

*End of Sourcing Scout README.*
