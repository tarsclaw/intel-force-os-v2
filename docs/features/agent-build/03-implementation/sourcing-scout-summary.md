# Sourcing Scout — W9 build-slice summary (spec-003)

**Date:** 2026-06-10 · **Branch:** `worktree-agent-a45354564e8f66257` · **Builder:** IMPLEMENT sub-agent (Claude Fable 5)
**Spec:** `docs/features/agent-build/02-specs/spec-003-sourcing-scout.md` · **Contract:** `agents/recruitment/sourcing-scout/agent.md`
**Result:** all ~15 TODO markers replaced with live implementation; `bash scripts/build-gate.sh` GREEN (shellcheck CLEAN 42 files; 4 connector suites green; all 9 DB-backed fixture suites green incl. the 3 new scout suites).

## What was built, per spec-003 §4 step

| Step | Delivered | Marker emitted | ESC route live |
|---|---|---|---|
| 0 | Session start (cycle.sh) + context.sh hydration (canonical `tenant_adapters` SELECTs for `bullhorn_corporation_id` / `blocked_recipients` / `firm_domains` / `operator_telegram_chat_id`, RLS `SET LOCAL app.current_tenant` on every query; `IFOS_FORCE_*` fixture fallbacks retained) | `session_start` | — |
| 1 | Brief ingestion: `--brief-id` → Postgres `entities` read (`entity_type='brief'`; spec §2 upstream contract); `--description` → deterministic `bin/parse-brief.sh` (role/location/salary/work-mode/seniority/sector) | `brief_ingested` ("input_type; key_dims:N") | `ESC_BRIEF_AMBIGUITY` (<3 dims OR brief_id unresolvable) via `autosend_escalate` + exit 1 (no `validate_gate_a_fail` row — reserved for Gate A per deviation 4; aligned in the Round-2 fix pass) |
| 2 | Multi-source auth: per-source state = fixture override ∨ (creds present ∧ connector CLI built); degraded source → catalogue ESC + skip, never exit 1; all-degraded → immediate `<5 obtainable` floor escalation | `auth_refresh_complete` ("sources_ok:N/4; degraded:list; linkedin:v1.0_no_op") | `ESC_BULLHORN_AUTH` / `ESC_REED_AUTH` / `ESC_CVLIBRARY_AUTH` (degraded-skip), `ESC_AGENT_OUTPUT_SHAPE` (all degraded) |
| 3 | Bullhorn passive-match call-site (filter contract `status:active + modified<90d`, ≤30) through the shared query layer; degraded-skip today (creds EMPTY) | `bullhorn_query` ("results:N; queried:bool") | `ESC_RATE_LIMIT_HIT` (upstream=bullhorn) |
| 4 | LinkedIn NO-OP, structurally present (empty result set feeds the aggregate; report row "deferred to v1.1+; vendor pending") | `linkedin_query` ("results:0; no_op") | — |
| 5 | Reed query through the shared layer; degraded-skip today (creds EMPTY); 429 path → cached_only | `reed_query` | `ESC_REED_AUTH`, `ESC_RATE_LIMIT_HIT` (upstream=reed) |
| 6 | CV-Library — the live source: new `@ifos/cv-library` `dist/cli.js` (`check-auth` network-free + `search-candidates` normalised to the unified candidate shape); fixture path (`IFOS_SCOUT_FIXTURE_CVLIBRARY`) keeps every test deterministic; **no live API call made in this build** | `cvlibrary_query` | `ESC_CVLIBRARY_AUTH`, `ESC_RATE_LIMIT_HIT` |
| 7 | `bin/fuzzy-match.sh` — carried Janitor matcher (name·0.3+email·0.4+phone·0.2+linkedin·0.1; ≥0.85) + provenance (`sources[]`/`refs[]`) + field merge + deterministic confidence heuristic | `aggregate_dedupe` ("pre:N; post:M; cross_source_matches:K") | — |
| 8 | DNC filter vs `blocked_recipients` (email lowercase / phone digits-normalised last-10 / name lowercase); drops → §3 exception list, NO ESC fire (catalogue §2.10 disposition) | `dnc_filter` ("dropped:N; kept:M") | — |
| 9 | Top-15 rank + deterministic ≥50-word rationale (`bin/render-rationale.sh`, tone-rule compliant, zero PII); voice honesty: `unscored/no_corpus` (or `classifier_unavailable`); numeric score <0.75 after retry budget → drop + ESC. **ONE `candidate_proposed` row PER candidate** incl. dropped (`included=false` + `drop_reason: dnc_filter | voice_drift | rank_cutoff_top15`) | `candidate_proposed` (per candidate) | `ESC_VOICE_DRIFT` (drop candidate) |
| 10 | Proposal JSON assembly → `validate.sh` Gate A → PASS: §3 Markdown report to `/vault/<tenant>/sourcing-scout-reports/<slug>-<ISO>.md` (0600); FAIL: partial draft (`--partial` banner + degradation notes) to `/tmp/sourcing-scout-<tenant>-<slug>-partial.md`, exit 1 BEFORE `scout_report` | `scout_report` ("N candidates from M sources") | `ESC_AGENT_OUTPUT_SHAPE` + `validate_gate_a_fail` (emitted by validate.sh) |
| 11 | Session close: Telegram operator notify when configured (green `operator_notify_telegram`), stdout otherwise; run-complete row on BOTH pass and fail paths (fail carries `gate_a:FAIL` + partial path) | `scout_run_complete` (action; green) | — |

`cleanup.sh`: live TTL purges (Bullhorn 24h; Reed/CV-Library 1h; /tmp partial drafts 24h); token files, vault reports, decision_log untouched; audit row stays `hh_decision_output` because `sourcing_scout_cleanup` is not yet registered in autosend-policy.yaml (spec §2 registers only `scout_run_complete` + `validate_gate_a_fail`).

## Gate A (validate.sh) — spec-003 §5, all checks live

G1 count [5,15] · G2 contact method (email regex + opt-in MX via `IFOS_SCOUT_MX_CHECK=1`; E.164; LinkedIn URL; bullhorn_internal) · G3 ≥50 words (recomputed from the body, never trusting the self-reported count) · G4 voice ≥0.75 hard-when-scored / **warn-when-unscored** · G5 DNC defence-in-depth re-check · G6 PII firm-boundary regex (BLOCKING; class precedence over all others) · G7 source floor (no live source returns 0 without a degradation note + at least one contribution or degradation recorded). Failure → mandatory `validate_gate_a_fail` action row + `autosend_escalate` with per-class routing (`ESC_AGENT_OUTPUT_SHAPE` / `ESC_VOICE_DRIFT` / `ESC_PII_LEAKAGE_RISK`), exit 1.

## Fixture results (deterministic, DB-backed; build-gate auto-discovered)

| Suite | Result | Coverage |
|---|---|---|
| `scripts/run-scout-dedupe-test.sh` | **GREEN** (15/15) | 5 matcher-unit asserts (name+email merge; name+phone with UK +44/0 equivalence; strong-identifier no-merge for name-only collisions; provenance; cross-source field merge) + 10 E2E asserts over the fixture-01 pool (pre:18→post:15; DNC dropped:2/kept:13; 15 `candidate_proposed` rows = 13 included + 2 DNC; Gate A PASS; vault report with 13 ranked candidates + LinkedIn-deferred row) |
| `scripts/run-scout-gate-a-test.sh` | **GREEN** (PASS + 9 fail classes) | exit codes + ESC routing for G1 low/high, G2 missing-contact + non-E.164, G3, G4 scored-voice → `ESC_VOICE_DRIFT`, G5 DNC re-check, G6 PII → `ESC_PII_LEAKAGE_RISK` (precedence verified with a simultaneous G1 fail), G7 source-floor; `validate_gate_a_fail` action row asserted for all 9 failures |
| `scripts/run-scout-degraded-test.sh` | **GREEN** (18/18) | fixture-02 scenario: `ESC_BULLHORN_AUTH` degraded-skip; Reed live-at-refresh then 429 → `ESC_RATE_LIMIT_HIT` + 0 results; `sources_ok:2/4; degraded:bullhorn`; 3 < 5 floor → Gate A FAIL exit 1 + /tmp partial draft with degradation notes + NO vault write + `scout_run_complete gate_a:FAIL`; plus the all-sources-degraded Step-2 `<5 obtainable` floor escalation (`sources_ok:0/4`) |

Test idiom mirrors Cash Conductor: throwaway tenant registered in `tenants` (decision_log FK; `DELETE` cascades cleanup) because cycle.sh/validate.sh open their own DB connections; all source data from `IFOS_SCOUT_FIXTURE_*` files — zero network, zero LLM.

## Deviations from spec / skeleton (documented, deliberate)

1. **Fuzzy-matcher scoring normalisation.** A literal absolute-sum of the Janitor weights can never reach 0.85 for the common cross-board case (one source has phone, the other linkedin → name+email caps at 0.7), which would break the contracted dedupe behaviour in fixture-01. Implemented: matched-weight / comparable-weight normalisation + a required strong-identifier match (email|phone|linkedin) so name-only pairs never merge. Same weights, same threshold. **Reconcile with the Janitor helper at review** (spec §9 "carry a copy + reconcile").
2. **Marker names follow spec-003 §3**, superseding skeleton-era names (`bullhorn_query` not `bullhorn_passive_query`; `linkedin_query` not `linkedin_search_skipped`; per-candidate `candidate_proposed` not a single `rationale_generation` row). Fixture YAMLs updated accordingly.
3. **Fixture-01 arithmetic corrected to its own data**: 18 pre-dedupe → 15 post-dedupe (3 cross-source pairs) → 2 DNC drops → 13 final (the skeleton text claimed 18→14→12).
4. **Per-source ESC rows use the CC `autosend_escalate` idiom** (phase=`gating_failed`, outcome=ESC code) rather than the skeleton-fixture idea of `validate_gate_a_fail` action rows for Step-2/Step-5 source failures; `validate_gate_a_fail` is reserved for Gate A itself (master brief §8.1 Change 2 reading).
5. **Step 1 brief_id path reads the Postgres `entities` mirror** (spec §2 upstream contract) rather than a direct `bullhorn.getBrief` (no such export in @ifos/bullhorn v0.1.0; direct endpoint = v1.1 enhancement, noted in tools.yaml).
6. **G2 MX check is opt-in** (`IFOS_SCOUT_MX_CHECK=1`): live DNS in the gate would make fixtures non-deterministic offline. Format regex always enforced.
7. **Confidence + rationale are deterministic v1.0 heuristics/templates** (CC templated-draft precedent); LLM ranking + rationale polish and the embedding voice classifier are the documented enhancements — same JSON contracts, no cycle.sh changes needed when they land.

## Honest-scope notes (spec-003 §8)

- **Bullhorn READ-ONLY honoured**: zero Bullhorn writes anywhere in the bundle; no write capabilities in tools.yaml; the only action_types emitted are green (`scout_run_complete`, `validate_gate_a_fail`, `operator_notify_telegram`).
- **No live API call was made in this build.** CV-Library is fully wired (`check-auth` smoked network-free; `search-candidates` is the orchestrator's live-smoke surface).
- **⚠️ CV-Library cred-state discrepancy (for the orchestrator before the live smoke):** the brief stated "CV-Library SET". A comment-aware re-check of `~/.ifos-local-vault/dev-sandbox/_secrets.env` (names only, values never printed) shows the `CVLIBRARY_*` lines are `KEY=` followed by an inline `# comment` — i.e. **values EMPTY**; the naive `awk -F=` check counts the comment text as a value. Either the creds live elsewhere or the earlier SET verification was a false positive. The degraded-skip path covers this gracefully; the live smoke needs real values first.
- Voice: dev tenants have an empty `voice_corpus` → every rationale records `unscored/no_corpus`; G4 warns. `IFOS_SCOUT_FORCE_VOICE_SCORE` test hook exercises the scored `ESC_VOICE_DRIFT` drop route.
- Reed/Bullhorn live = founder-gated (creds EMPTY, verified names-only).
- Telegram notify degrades to stdout (TELEGRAM_BOT_TOKEN EMPTY).

## Files touched

- `agents/recruitment/sourcing-scout/{cycle.sh, validate.sh, context.sh, cleanup.sh, tools.yaml, README.md}` — TODO markers → live
- `agents/recruitment/sourcing-scout/bin/{fuzzy-match.sh, parse-brief.sh, render-rationale.sh, render-scout-report.sh}` — new
- `agents/recruitment/sourcing-scout/fixtures/*.yaml` — aligned to the live contract
- `packages/mcp-connectors/cv-library/{src/cli.ts, tsup.config.ts}` — new CLI bridge (typecheck + 20 vitest green; reed also re-verified green 18/18)
- `scripts/run-scout-{dedupe,gate-a,degraded}-test.sh` — new

## Queued for review / follow-ups

- Codex re-ratification of the full bundle (agent.md §10 state 2) + founder Q1/Q3/Q5/Q6 approvals.
- Reconcile `bin/fuzzy-match.sh` with the Janitor matcher when it lands (deviation 1).
- Register `sourcing_scout_cleanup` (+ the three `*_oauth` green action_types) in autosend-policy.yaml, then switch cleanup.sh to `hh_decision_action`.
- Source-abstraction ADR (agent.md §9 Q6) still to be authored.
- Orchestrator live smoke: verify CV-Library cred values actually exist (see discrepancy note), build `@ifos/cv-library` (`pnpm --filter @ifos/cv-library build`), then run cycle.sh without fixture overrides against a real brief.

## Round-2 fix pass (2026-06-10 — Codex ratification round-1 REJECT on agent.md + reviewer MINORs)

| # | Finding | Fix |
|---|---|---|
| 1 | agent.md internal contradiction: §1 still contracted FOUR sources incl. LinkedIn-via-Proxycurl; §4 Step 4 still specified a live Proxycurl workflow | §1/§3/§4/§6/§8/§9 rewritten to the three-source v1.0 contract; LinkedIn is an explicit structurally-present NO-OP row everywhere (Step 4 documents the live `linkedin_query` `results:0; no_op` marker — unchanged in cycle.sh); ESC_LINKEDIN_AUTH marked NOT-fired-at-v1.0; Proxycurl rows in §8/§9 re-cast as v1.1+ LinkedIn-vendor items |
| 2 | False migration citation: `blocked_recipients` anchored to v0.2-to-v0.3.sql line 398 / block 396-409 (actually `decision_window_text`) | Verified against the file: key at line 434, `allowed_keys` array 432-445, element-type validation block 510-523; supplement declaration corrected 810-827 → 823-840. Both citation sites (header Schema-key block + §4 Step 8) corrected |
| 3 | False schema citation: `recent_edit` W anchored to supplement lines 584-593 + 715-724 (actually voice_corpus/tone_rule) | Verified: corrected to 597-606 (§2a access-list) + 728-737 (access matrix) in §7 |
| 4 | Stale build-state language: "@ifos/reed + @ifos/cv-library don't exist yet"; "validate.sh does NOT exist yet" | Build-state header + reading-discipline note rewritten to the W9 live bundle with per-component states (bullhorn: package exists, no CLI bridge, creds EMPTY → degraded-skip; reed: package v0.1.0, creds EMPTY; cv-library: package + dist/cli.js, creds EMPTY, live smoke founder-gated; nothing production-proven — zero live API calls); §5 Cat-5 note updated (validate.sh LIVE, not production-proven); §8 table statuses updated. §10 status field NOT flipped (founder-gated) |
| 5 | tools.yaml stale NOTE: Step 4 "emits `linkedin_search_skipped`" | Corrected to the live `linkedin_query` no-op marker |
| 6 | tools.yaml header "Status: Proposed (W5 Day-33 SKELETON…)" vs README LIVE | Header now "Status: LIVE (W9 build slice, spec-003)" with explicit note that the agent.md §10 lifecycle flip is founder-gated and separate |
| A5 | Advisory: cycle.sh Step-1 ESC_BRIEF_AMBIGUITY paths emitted `validate_gate_a_fail` action rows, contradicting deviation 4 (reserved for Gate A) | Code aligned to the `autosend_escalate`-only idiom (the escalation itself writes the `gating_failed` decision_log row, so the audit trail stands); no fixture/test asserted the removed rows; gate re-run GREEN |
