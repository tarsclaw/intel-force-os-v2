# Janitor — directory README

**Status:** BUILT (W6-7 build slice per `docs/features/agent-build/02-specs/spec-001-janitor.md`) — fixture-proven + gate-green. **Live Bullhorn smoke is founder-gated** (Bullhorn creds EMPTY per spec-001 §8; verified names-only 2026-06-10). `agent.md` status field is founder-gated and unchanged.

## What's in this directory

| File | What it is | Status |
|---|---|---|
| `agent.md` | Output-contract-first agent specification (the CONTRACT this build implements) | Proposed (founder-gated flip) |
| `tools.yaml` | Capability declarations: Bullhorn R+W via the `@ifos/bullhorn` CLI bridge, Companies House, Telegram | BUILT |
| `context.sh` | Session hydration — canonical RLS `tenant_adapters` reads + Bullhorn auth-state probe + voice/tone/recent_edit load | LIVE |
| `cycle.sh` | 12-step nightly workflow per agent.md §4 (modes: full-cleanup / incremental / report-only / dry-run) | LIVE |
| `validate.sh` | Gate A G1-G7 per agent.md §5 + spec-001 §5, per-class ESC routing | LIVE |
| `cleanup.sh` | Post-run TTL cache purge (Bullhorn 24h / Companies House 7d / stale run dirs) | LIVE |
| `bin/dedup-pairs.sh` | Pair fuzzy matcher — spec weights (0.3/0.4/0.2/0.1), comparable-weight normalisation + required strong identifier (Scout-reviewed semantics), band→action per spec-001 §4 | LIVE |
| `bin/ch-lookup.mjs` | Companies House search→CRN→profile bridge over the connector dist (Diagnostic precedent) | LIVE (key SET) |
| `bin/render-tacit-note.sh` | Deterministic PII-free narrative template + optional LLM polish (`ANTHROPIC_API_KEY`) | LIVE |
| `sql/field-completeness.sql` | Reusable RLS-scoped missing-field audit (`\i` from cycle.sh + tests) | LIVE |
| `sql/day30-report-metrics.sql` | Reusable RLS-scoped day-30 report metrics + Gate B inputs | LIVE |
| `fixtures/*.yaml` | 3 fixtures aligned to the live marker contract (spec-001 §3 names) | ALIGNED |

## Honest scope (spec-001 §8)

- **Bullhorn creds founder-gated:** Steps 1/2/9 are wired to `packages/mcp-connectors/bullhorn/dist/cli.js` (built this slice: check-auth / refresh / list-* / update-candidate / update-client / create-note). Until creds land the agent runs DEGRADED: Step 2 scans the Postgres `entities` cache; Step 9 validates every write through Gate A and records the yellow action row with `write_state:deferred_no_bullhorn_creds`. Never faked.
- **Companies House (Step 6) is live** (key SET; one read-only live smoke run at build time).
- **LinkedIn (Step 7) NO-OP** (Proxycurl shutdown; vendor selection W8-9).
- **Voice:** empty tenant `voice_corpus` → `unscored/no_corpus` recorded honestly; `IFOS_JANITOR_FORCE_VOICE_SCORE` exercises the scored `ESC_VOICE_DRIFT` route.

## Tests (deterministic, DB-backed; build-gate auto-discovered)

- `scripts/run-janitor-dedup-test.sh` — matcher unit asserts + E2E band→action over seeded `entities` rows
- `scripts/run-janitor-gate-a-test.sh` — Gate A PASS + every fail class + ESC routing
- `scripts/run-janitor-report-test.sh` — 8-section report + two-threshold Gate B + 3-consecutive-miss `ESC_GATE_B_MISS`

## Ratification

Codex re-ratification of the full bundle queued (agent.md §10 state 2) + founder open-question approvals (agent.md §9).

*End of Janitor README.*
