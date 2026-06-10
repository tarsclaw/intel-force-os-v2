# Janitor — W6-7 build-slice summary (spec-001, PROVE-ONE pilot)

**Date:** 2026-06-10 · **Branch:** `worktree-agent-abb2ffb971bb471ba` · **Builder:** IMPLEMENT sub-agent (Claude Fable 5)
**Spec:** `docs/features/agent-build/02-specs/spec-001-janitor.md` · **Contract:** `agents/recruitment/janitor/agent.md`
**Result:** all ~13 TODO(W6-7) markers replaced with live implementation; `bash scripts/build-gate.sh` **GREEN** (shellcheck CLEAN 40 files; 4 connector suites green; all 9 DB-backed fixture suites green incl. the 3 new janitor suites); one read-only Companies House live smoke green.

## What was built, per spec-001 §4 step

| Step | Delivered | Marker emitted | ESC route live |
|---|---|---|---|
| 0 | Session start (cycle.sh) + context.sh hydration: canonical RLS `tenant_adapters` SELECTs for `janitor_dedup_threshold` / `bullhorn_corporation_id` / `operator_telegram_chat_id` (`IFOS_FORCE_*` fixture fallbacks retained); Bullhorn auth-state probe via the new CLI; voice-corpus presence + tone-rule count + recent_edit 30d count | `session_start` | — |
| 1 | Bullhorn two-step refresh via `@ifos/bullhorn dist/cli.js refresh` (2 retries → blocking `ESC_BULLHORN_AUTH` + exit 1). Creds-absent (founder-gated today) → honest DEGRADED state: ESC fires with `reason=credentials_absent`, run continues against the entities cache (Scout degraded-skip precedent) | `bullhorn_auth_refresh` | `ESC_BULLHORN_AUTH` (both classes) |
| 2 | Entity scan: live CLI pull call-site (list-candidates/contacts/clients `--since` watermark → entities upsert; 429 → 60s backoff + retry) + cache-count path shared by both modes; watermark from `tenant_adapters.config.janitor_last_run` | **`janitor_scan`** (spec-001 §3 contract name — supersedes skeleton `bullhorn_entity_scan`) | `ESC_RATE_LIMIT_HIT` (upstream=bullhorn) |
| 3 | `bin/dedup-pairs.sh`: spec weights (name·0.3+email·0.4+phone·0.2+linkedin·0.1) with comparable-weight normalisation + required strong identifier (Scout-reviewed semantics; deviation 1); band→action table EXACT per spec §4 incl. unknown-activity conservative hold + greedy auto-band de-overlap; review pairs → per-pair `ESC_DUPLICATE_DETECTED` (SUCCESS path) | `dedup_candidate_pass` | `ESC_DUPLICATE_DETECTED` |
| 4 | Same matcher over `entity_type='contractor'` | `dedup_contractor_pass` | (same) |
| 5 | `sql/field-completeness.sql` (reusable `\i`; canonical fields per vertical-schema: candidate.location, client.industry/size_employees/companies_house_number, contractor.day_rate_min/max, brief.salary_min/max) + Step 6 client queue | `field_completeness_audit` | — |
| 6 | Companies House via `bin/ch-lookup.mjs` over the connector dist (search→CRN→profile; connector owns 7d cache + shared budget; Diagnostic precedent); deterministic `source_confidence` 0.9 exact / 0.75 inexact / 0 not-found (feeds G4); cap 25 lookups/run; rate_limited → ESC + stop; **LIVE-SMOKED** (HAYS PLC → CRN 02150950, SIC 70100, conf 0.9) | `companies_house_enrichment` | `ESC_RATE_LIMIT_HIT` (upstream=companies-house) |
| 7 | NO-OP, structurally present (explicit audit row; Proxycurl shutdown; vendor W8-9) | `linkedin_enrichment_skipped` | — |
| 8 | recent_edit harvest (`resolution='approved_after_edit'`, 30d, RLS) grouped by target_entity_type; `bin/render-tacit-note.sh` deterministic template (PII-free BY CONSTRUCTION — only aggregate counts/types ever reach the narrative or the LLM; raw edit text never leaves Postgres); LLM polish active when `ANTHROPIC_API_KEY` set (`IFOS_JANITOR_NO_LLM=1` test guard); voice honesty: `unscored/no_corpus` | **`janitor_tacit_note_harvest`** (contract name — supersedes skeleton `tacit_note_harvest`) | `ESC_VOICE_DRIFT` (enforced at G5) |
| 9 | Gate-A-gated write batch: per proposal validate.sh → write via CLI (update-candidate / update-client / create-note) when live; 4xx → ESC + skip; 5xx → retry-once (30s) → ESC + skip; creds-absent → yellow action row with `write_state:deferred_no_bullhorn_creds` (decision recorded, transport honestly deferred); 100/min cap with remainder-defers + exception note | `bullhorn_candidate_dedupe` / `bullhorn_field_backfill` / `bullhorn_note_attach` action rows + `bullhorn_write_batch` summary | `ESC_BULLHORN_WRITE_FAIL` (4xx/5xx) |
| 10 | 8-section day-30 report (agent.md §3 Output 1) from `sql/day30-report-metrics.sql`; Gate B = TWO independent thresholds (dedup ≥15% AND completeness ≥10%; both-must-pass, never composite); vault write 0600 | `day_30_report` ("Gate-B: dedup_pct:…; completeness_pct:…; gate_b_met:…; gate_b_both_missed:…; sections:8") | — |
| 11 | Operator notify: live Telegram sendMessage when token + chat id configured; stdout degrade otherwise (token EMPTY today); ≤200-char summary; gate_b_state in payload | `operator_notify_telegram` (green action) | — |
| 12 | `janitor_last_run` stamp (validated key); last-3 `day_30_report` rows checked for `gate_b_both_missed:true` ×3 → `ESC_GATE_B_MISS` + exit 1 (single-run / single-threshold misses never fire) | `janitor_run_complete` (green action; emitted on BOTH exit paths) | `ESC_GATE_B_MISS` |

`cleanup.sh`: live TTL purges (Bullhorn cache 24h; Companies House cache 7d; stale `janitor-run-*` workspaces 24h); token files / vault reports / recent_edit / decision_log untouched; audit row stays `hh_decision_output` (`janitor_cleanup` not yet registered in autosend-policy.yaml — substrate frozen; CC/Scout precedent).

## Gate A (validate.sh) — spec-001 §5, all 7 checks live

G1 auth freshness (hard-fail on `token_state:failed`; warn on degraded/absent — no stale-token risk when no live write can occur, see deviation 4) · G2 dedup confidence ≥ threshold → `ESC_AGENT_OUTPUT_SHAPE` · G3 90d-activity (recent OR unknown → reject auto-write + `ESC_DUPLICATE_DETECTED` SUCCESS-path) · G4 backfill `source_confidence` ≥0.7 → `ESC_AGENT_OUTPUT_SHAPE` · G5 voice ≥0.75 hard-when-scored / warn-when-unscored → `ESC_VOICE_DRIFT` · G6 PII firm-boundary regex → `ESC_PII_LEAKAGE_RISK` (BLOCKING; precedence over all classes) · G7 batch ≤100/min → `ESC_AGENT_OUTPUT_SHAPE` (spec-001 §5 routing, supersedes the skeleton comment's ESC_RATE_LIMIT_HIT). Every failure emits the mandatory `validate_gate_a_fail` action row + the per-class `autosend_escalate` row, exit 1.

## @ifos/bullhorn CLI bridge (owned package this cycle)

`packages/mcp-connectors/bullhorn/src/cli.ts` (new; mirrors xero/quickbooks/cv-library): `check-auth` (network-free) / `refresh` / `list-candidates` / `list-contacts` / `list-clients` (normalised rows for the entities upsert) / `update-candidate` / `update-client` / `create-note`. `updateClient` capability added to `src/clients.ts` + exported (Step 9 client backfill needed it; the package only had candidate update). tsup entry extended; **typecheck green; 31/31 vitest green** (2 new cases: updateClient happy path + 400 no-retry). `check-auth` smoked network-free. No live Bullhorn call was made anywhere in this build.

## Fixture results (deterministic, DB-backed; build-gate auto-discovered)

| Suite | Result | Coverage |
|---|---|---|
| `scripts/run-janitor-dedup-test.sh` | **GREEN** (13 matcher asserts + 12 E2E) | auto band (conf 1.0); UK +44/0 phone equivalence; strong-identifier no-pair; sub-0.70 silent drop; 0.70–0.85 review band; recency hold (pair-MIN reason); unknown-activity conservative hold; E2E over seeded entities: `janitor_scan`, band counts, ESC_DUPLICATE_DETECTED hold, 2 dedupe + 1 backfill + 2 note yellow rows all `write_state:deferred`, tacit harvest, run-complete |
| `scripts/run-janitor-gate-a-test.sh` | **GREEN** (4 pass + 8 fail classes + ESC routes) | G2, G3 recent + G3 unknown, G4, G5 scored, G6 PII + G6 precedence-over-G5, G7 batch-cap; pass paths incl. unscored-voice warn + firm-domain email allowed; `validate_gate_a_fail` row per failure (8/8) |
| `scripts/run-janitor-report-test.sh` | **GREEN** (13 asserts) | 8-section shape; Gate B AND-logic (scenario B: completeness met cannot cover dedup miss → `gate_b_met:false`, `both_missed:false`); 3-consecutive both-missed → `ESC_GATE_B_MISS` + exit 1; run-complete row on the failing path |

Test idiom mirrors Cash Conductor: registered throwaway tenant (`tenants` FK; DELETE cascades entities/tenant_adapters/decision_log), recent_edit + decision_log pruning via the owner connection; zero network, zero LLM (fixture hooks `IFOS_JANITOR_FIXTURE_CH`, `IFOS_JANITOR_NO_LLM`, `IFOS_JANITOR_RETRY_DELAY_S=0`).

## Live smokes

- **Companies House (permitted; key SET):** `bin/ch-lookup.mjs --name "HAYS PLC"` → `{ok:true, crn:"02150950", industry:"70100", source_confidence:0.9}` — one read-only call through the connector's cache/rate-limit path.
- **Bullhorn:** NONE (creds EMPTY, founder-gated). `check-auth` network-free smoke only.
- Full end-to-end smoke ran against the local dev DB under a throwaway tenant (all 12 steps + 8-section report verified, then cleaned up).

## Deviations from spec / skeleton (numbered, deliberate)

1. **Fuzzy-matcher scoring normalisation.** Spec-001 §4's literal weight-sum can never reach 0.85 for a name+email-only match (caps at 0.7). Implemented the Scout-reviewed semantics named in the build brief: matched-weight / comparable-weight normalisation + a required strong-identifier match (email|phone|linkedin), same weights, same 0.85 threshold. Band→action table kept exactly per spec §4. Cross-agent reconciliation with Scout's `bin/fuzzy-match.sh` queued for review (the two scripts share normalisation + scoring verbatim; Janitor's emits pairs/bands, Scout's emits clusters).
2. **Unknown activity → conservative review hold.** Spec/fixtures only define behaviour when `last_activity_days` is known. Records with UNKNOWN activity are never auto-merged — they hold via `ESC_DUPLICATE_DETECTED` ("dedup is hard; start conservative", agent.md §9 gotcha 2). Live activity hydration from Bullhorn placements/notes is the post-creds enhancement.
3. **Per-pair holds emit `ESC_DUPLICATE_DETECTED` gating rows, not `operator_approval_request` action rows.** The skeleton fixtures expected an `operator_approval_request` action_type that is NOT registered in autosend-policy.yaml (would fail-safe-red through `hh_decision_action`). Scout deviation-4 precedent applied; fixture YAMLs aligned.
4. **G1 warns (not fails) on degraded/absent auth state.** The check exists to block stale-token writes; with creds founder-gated there is no token and no live write (Step 9 records `write_state:deferred`), so a hard fail would only block the deferred audit trail. Hard-fail on `token_state:failed` is enforced.
5. **Step 9 in degraded mode records the validated yellow action row with `write_state:deferred_no_bullhorn_creds`.** The Gate-A-validated decision is real and audit-worthy; the transport is honestly deferred (payload says so), never faked. Post-creds, the same rows carry `write_state:applied`.
6. **Gate B v1.0 metric definitions are decision_log-derived:** `dedup_pct = 100·merges/(merges+review-band)`, `completeness_pct = 100·backfills/(backfills+still-missing)`. No day-0 baseline exists yet (captured at pilot onboarding per agent.md §9 Q6); the baseline-relative measure is the documented enhancement. Definitions printed in report §6.
7. **Dedupe "merge write" v1.0 = provenance stamp on the primary** (`customText1: ifos:merged_from:<target>` via update-candidate). Bullhorn has no single-call merge API; the full field-cascade merge is the post-sandbox enhancement (needs live sandbox semantics; agent.md §9 gotcha 1).
8. **Step 11 tier nuance:** agent.md says "yellow-tier notification" on Gate-B miss, but `operator_notify_telegram` is registered GREEN in autosend-policy.yaml and tiers are policy-owned. The miss state + ≤200-char summary ride in the payload (`gate_b_state:missed`); changing tier-by-content would need a policy change (substrate frozen).
9. **Fixed a latent skeleton bug:** bare `*2*` glob step-matching mis-matches `"12"` (report-only mode would have run Step 2). Replaced with word-boundary matching. (Same latent pattern exists in CC's cycle.sh — flagged for the orchestrator, not touched per the surgical-changes rule.)
10. **Marker names follow spec-001 §3** (`janitor_scan`, `janitor_tacit_note_harvest`), superseding skeleton-era names; fixture YAMLs + tools.yaml comments/headers aligned (the Scout-review stale-comment finding pre-empted).

## Honest-scope notes (spec-001 §8)

- **🔴 Bullhorn creds remain EMPTY** (re-verified comment-aware names-only check 2026-06-10: all six `BULLHORN_*` keys EMPTY). Janitor is BUILT + fixture-proven + gate-green; the live Bullhorn smoke (refresh → scan → one sandbox write) is a founder-gated post-creds step. The CLI bridge + cycle.sh call-sites are the wired surface it runs through.
- Companies House key SET → Step 6 live-capable; smoked once read-only.
- ANTHROPIC_API_KEY SET → Step 8 LLM polish path is active in production runs; tests pin the deterministic template.
- TELEGRAM_BOT_TOKEN EMPTY → Step 11 degrades to stdout (channel recorded honestly).
- Dev tenants have empty `voice_corpus` → narratives record `unscored/no_corpus`; `IFOS_JANITOR_FORCE_VOICE_SCORE` exercises the scored `ESC_VOICE_DRIFT` route.
- O(n²) pair scan is fine at incremental-scan pool sizes; a blocking-key pre-pass is the documented enhancement before full-corpus backfills on large tenants.

## Files touched

- `agents/recruitment/janitor/{cycle.sh, validate.sh, context.sh, cleanup.sh, tools.yaml, README.md, fixtures/*.yaml}` — TODO markers → live
- `agents/recruitment/janitor/bin/{dedup-pairs.sh, ch-lookup.mjs, render-tacit-note.sh}` — new
- `agents/recruitment/janitor/sql/{field-completeness.sql, day30-report-metrics.sql}` — new
- `packages/mcp-connectors/bullhorn/{src/cli.ts (new), src/clients.ts (+updateClient), src/index.ts, tsup.config.ts, tests/capabilities.test.ts}` — owned this cycle
- `scripts/run-janitor-{dedup,gate-a,report}-test.sh` — new

## Queued for review / follow-ups

- Codex re-ratification of the full bundle (agent.md §10 state 2) + founder Q1/Q2/Q4/Q5/Q6 approvals; agent.md status flip is founder-gated (not touched).
- Founder-gated post-creds: Bullhorn OAuth consent bootstrap + live smoke (refresh / scan / one sandbox write through Steps 1-2-9).
- Register `bullhorn_oauth` + `janitor_cleanup` (green) in autosend-policy.yaml (substrate owner), then switch cleanup.sh to `hh_decision_action`.
- Reconcile `bin/dedup-pairs.sh` with Scout's `bin/fuzzy-match.sh` into one shared helper at review (deviation 1; semantics already identical).
- Orchestrator note: CC cycle.sh carries the same `*N*` step-glob latent bug (deviation 9).
