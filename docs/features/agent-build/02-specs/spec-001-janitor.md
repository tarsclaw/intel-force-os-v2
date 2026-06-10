# Spec 001 — Janitor build (PROVE-ONE pilot)

**A sub-agent given ONLY this file + `agents/recruitment/janitor/agent.md` + the Cash Conductor
template + CLAUDE.md has everything it needs to build Janitor autonomously.**

- **Agent dir:** `agents/recruitment/janitor/` (cycle.sh 12-step + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures — SKELETON, ~13 TODO(W5) markers)
- **Master-plan source (READ IN FULL — it is the detailed step-by-step spec):** `agents/recruitment/janitor/agent.md`
- **Mirror template:** Cash Conductor (`agents/recruitment/cash-conductor/`). Reuse its exact idioms: the RLS `BEGIN; SET LOCAL app.current_tenant; … COMMIT;` psql blocks; reusable `sql/*.sql` run via `\i`; `bin/` render helpers; the `scripts/run-*-test.sh` deterministic fixture pattern (seed under a throwaway tenant in a ROLLBACK'd transaction; register the tenant in `tenants` first only when the row writes to a decision_log-FK table).
- **Wave/tier:** v1.0 W5; Tier 1 nightly cron. **Janitor is the wedge agent (agent.md §1).**

## 1. Scope
Replace the 13 TODO markers in `janitor/cycle.sh` (+ validate.sh + cleanup.sh) with live impl
matching agent.md §3-§6: the 12-step nightly workflow, the 8-section day-30 report, the 3
Bullhorn write categories, Gate A, and deterministic fixtures. Out of scope: LinkedIn enrichment
(Step 7 — v1.1, Proxycurl shut down → NO-OP); live Bullhorn writes (see §8 blocker).

## 2. Upstream contract (CONSUMES — freeze on main first)
- `agents/_shared/` substrate (hook-helpers, voice-loader, autosend-policy, escalation-codes) — already frozen.
- **autosend-policy action_types (already registered, yellow):** `bullhorn_candidate_dedupe` (payload.entity_type ∈ {candidate,contractor}), `bullhorn_field_backfill`, `bullhorn_note_attach`, `operator_notify_telegram`, `janitor_run_complete`. Verify each with `grep '^  <name>:' agents/_shared/autosend-policy.yaml` before use.
- **Postgres (v0.4 schema):** `entities` (Bullhorn cache, read+dedup), `recent_edit` (R access — Janitor reads `resolution='approved_after_edit'` rows, §2a grant), `decision_log` (append), `tenant_adapters.config.janitor_last_run` (read+write; validated key per v0.3 trigger). No new migration required.
- **Connectors/CLIs:** `@ifos/bullhorn` (auth refresh + read scan + PUT/PATCH/POST writes) — **needs a CLI bridge built mirroring the cash-conductor connector CLIs**; `@ifos/companies-house` (client enrichment; live key SET).
- **Voice:** `hh_load_tone_rules` (applies_to_agents ∋ janitor) + `hh_load_voice_samples`.

## 3. Downstream contract (MUST EXPOSE)
- decision_log markers: `janitor_scan`, `field_completeness_audit`, `janitor_tacit_note_harvest`, `day_30_report`, + action rows `bullhorn_candidate_dedupe`/`bullhorn_field_backfill`/`bullhorn_note_attach`/`operator_notify_telegram`/`janitor_run_complete`. These feed the day-30 report aggregation (Step 10) + kill-criterion Trigger 8 evidence.
- `tenant_adapters.config.janitor_last_run` updated each run (the incremental-scan watermark Step 2 reads).

## 4. Workflow steps to wire (agent.md §4 — EVERY step; nothing omitted)
| Step | What to implement | decision_log marker | ESC on fail | CC pattern to mirror |
|---|---|---|---|---|
| 0 | Session start; context.sh hydrate (tenant + Bullhorn auth + voice corpus + recent edits) | `hh_decision_trigger session_start` | — | CC Step 0 |
| 1 | Bullhorn auth refresh (8-min loop) | — | `ESC_BULLHORN_AUTH` (2 retries) | CC Step 1 `_cc_refresh` |
| 2 | Entity scan since `janitor_last_run` (candidates/contractors/clients/contacts/placements/opportunities) | `janitor_scan` ("N scanned") | `ESC_RATE_LIMIT_HIT` (429, 60s backoff) | CC Step 3/4 ingest idiom |
| 3 | Dedup pass — candidates: fuzzy (name·0.3+email·0.4+phone·0.2+linkedin·0.1); drop <0.85; drop if either has 90d activity | (intermediate; row at Step 9) | — | CC Step 5 match SQL (conf scoring) |
| 4 | Dedup pass — contractors: same matcher, separate entity_type | (intermediate) | — | reuse Step 3 logic |
| 5 | Field-completeness audit (canonical fields per vertical-schema) | `field_completeness_audit` ("N missing") | — | CC Step 5 scan |
| 6 | Companies House enrichment (clients): name→CRN→industry/CH number; 7d cache | (backfill row at Step 9) | `ESC_RATE_LIMIT_HIT` | Diagnostic CH usage |
| 7 | LinkedIn enrichment — **v1.0 NO-OP** (Proxycurl shut down); structurally present, documented skip | — | — | (skip) |
| 8 | Tacit-note harvest: `SELECT FROM recent_edit WHERE resolved_at>now()-30d AND resolution='approved_after_edit'`; group by entity_type; voice-classified LLM narrative | `janitor_tacit_note_harvest` | `ESC_VOICE_DRIFT` (<0.75 after 3 retries) | CC Step 8 draft (voice honesty: unscored if no corpus) |
| 9 | Bullhorn write batch (yellow): per merge/backfill/note → `hh_decision_action` + atomic write; 4xx skip, 5xx retry-once | `bullhorn_candidate_dedupe`/`bullhorn_field_backfill`/`bullhorn_note_attach` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 write-back (idempotent + ESC routing) |
| 10 | Day-30 report assembly (8 sections per §3 Output 1; Gate-B metric) → vault md | `day_30_report` ("Gate-B: N") | — | CC Step 13 weekly report (reusable metrics SQL + assembler) |
| 11 | Operator Telegram notify (green if Gate-B met, yellow if missed) | `operator_notify_telegram` | — | (autosend bridge — drafts-only until W10-13) |
| 12 | Session close: update `janitor_last_run`; run-complete | `janitor_run_complete` (green action) | `ESC_GATE_B_MISS` (both thresholds, 3 consecutive) | CC Step 14 |

**Dedup confidence band → action (agent.md §3 Output 2.1 + §5):** ≥0.85 AND no 90d activity → auto-merge (yellow, spot-check). 0.70–0.85, OR ≥0.85 with 90d activity → hold for Telegram approval via `ESC_DUPLICATE_DETECTED` (SUCCESS-path gate, not a Gate A fail). <0.70 → silently drop.

## 5. Gate A (validate.sh) — every check (agent.md §5)
| Check | Rule | ESC on fail | Enforcement |
|---|---|---|---|
| auth | Bullhorn refresh succeeded in Step 1 | `ESC_BULLHORN_AUTH` | hard |
| merge-conf | every proposed merge ≥0.85 | `ESC_AGENT_OUTPUT_SHAPE` | hard |
| 90d-activity | no merge if either record had activity in 90d | (held via `ESC_DUPLICATE_DETECTED`) | hard |
| backfill-src | no backfill where source confidence <0.7 | `ESC_AGENT_OUTPUT_SHAPE` | hard |
| voice | tacit-note narrative classifier ≥0.75 | `ESC_VOICE_DRIFT` | hard (warn-when-unscored, per CC honesty) |
| batch-size | Bullhorn write batch ≤100/min | `ESC_AGENT_OUTPUT_SHAPE` | hard |
| PII | no PII outside firm boundary in narratives (regex) | `ESC_PII_LEAKAGE_RISK` | hard |

## 6. Acceptance criteria (DONE when)
- All §4 steps emit their markers (verify against decision_log after a fixture-mode run).
- All 7 Gate A checks live per §5; ESC routing correct.
- `bash scripts/build-gate.sh` green; **new fixtures added + green** (see §7).
- shellcheck CLEAN; RLS-scoped; the four boundaries honoured; atomic per-step commits; tree clean.

## 7. Test plan (deterministic fixtures — mirror CC's six suites)
- `scripts/run-janitor-dedup-test.sh` — seed candidate/contractor rows with crafted name/email/phone/linkedin; assert confidence scoring + band→action (auto / approval-gated / drop) + the 90d-activity exclusion.
- `scripts/run-janitor-gate-a-test.sh` — PASS + each fail class (merge-conf, backfill-src, batch-size, PII) + ESC route (register tenant first — decision_log FK).
- `scripts/run-janitor-report-test.sh` — seed decision_log action rows; assert the 8-section report metrics + Gate-B two-threshold logic (both-must-pass, not composite).
- Extend `scripts/build-gate.sh` automatically picks up new `run-*-test.sh`.

## 8. Honest-scope flags (DOCUMENT, NEVER FAKE)
- **🔴 BULLHORN CREDS BLOCKED (founder action):** Steps 1/2/9 hit Bullhorn; dev creds are unobtainable (dev-support enquiry pending). **Janitor can be fully BUILT + fixture-proven + gate-green, but NOT live-smoked against Bullhorn until creds land.** Acceptance = fixture-proven + gate-green; live-Bullhorn-smoke is a separate post-creds founder-gated step. Build the `@ifos/bullhorn` CLI bridge + wire the steps to it; the deterministic fixtures prove the logic against seeded `entities` rows.
- **Companies House (Step 6) IS live-capable** (key SET) — smoke that one path live.
- Tacit-note voice (Step 8): if tenant `voice_corpus` empty → record `unscored/no_corpus`, never a faked score (CC precedent).
- LinkedIn (Step 7): NO-OP (Proxycurl shutdown).

## 9. Dependencies + sequencing
- Blocked-for-live by: Bullhorn creds (founder). NOT blocked for build/fixtures.
- This is the **PROVE-ONE pilot** — it validates the build machine (bundle wiring + fixtures + gates + the Bullhorn CLI-bridge pattern) before Scribe/Sourcing-Scout fan out. Run it solo first.
- Can run in parallel with: Scribe, Sourcing Scout (disjoint files) once proven.
