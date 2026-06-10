# Janitor — the wedge agent

**Status:** Proposed (W6-7 build slice COMPLETE on this branch; status flip founder-gated per §10).
**Build state:** W6-7 build slice COMPLETE (spec-001; branch `worktree-agent-abb2ffb971bb471ba`, 2026-06-10) — all 6 sibling bundle files (`cycle.sh` 12 steps + `validate.sh` Gate A G1-G7 + `context.sh` + `cleanup.sh` + `tools.yaml` + `README.md`) + 3 fixtures LIVE/BUILT; build-gate GREEN; three deterministic DB-backed fixture suites green (`scripts/run-janitor-{dedup,gate-a,report}-test.sh`). Fixture-proven only: zero live Bullhorn calls have ever been made by this bundle (all six `BULLHORN_*` creds EMPTY per names-only re-verification 2026-06-10; live smoke founder-gated). Companies House is the one live-capable path (key SET; live-smoked once, read-only). Prior contract history: Day-20 W4 bilateral pass; R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority; R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4; R19 (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Still awaits: Q1 LOI + Bullhorn Sub-decision B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + live Bullhorn credentials + Codex re-ratification of the built bundle + founder approvals per §10.
**Reading-discipline note (updated 2026-06-10 at W6-7 build; originally added 2026-06-03 per Codex Fbis-R3 closure pattern + CC + Concierge precedent):** this `agent.md` is the **CONTRACT** that the W6-7 build slice implemented against. The 6 sibling bundle files + 3 fixtures are **LIVE** — the W6-7 build slice (spec-001, this branch; commits `184a2bf` + `4ceccbc` + `2938b20` + `30bdff8`) replaced every `TODO(W6-7)` marker with live implementation; the three DB-backed fixture suites are green under build-gate. **Per-component build state, honestly stated:** `@ifos/bullhorn` — implemented connector package + built `dist/cli.js` bridge (`packages/mcp-connectors/bullhorn`, v0.1.0; typecheck clean; vitest 52/52; generic `update-entity` for Candidate|ClientContact|JobOrder|Placement + extended `create-note` per the agreed CLI contract). Live credentials are the ONLY gap on that path: with creds EMPTY the agent runs DEGRADED — Step 2 scans the Postgres `entities` Bullhorn cache instead of the live API; all coverage is fixture-driven (`IFOS_JANITOR_FIXTURE_*`). `@ifos/companies-house` — live-capable (key SET); smoked once read-only via `bin/ch-lookup.mjs` (HAYS PLC → CRN 02150950, source_confidence 0.9). **Runtime-audit truth (W6-7 behaviour):** the three yellow-tier action rows the contract names (`bullhorn_candidate_dedupe` + `bullhorn_field_backfill` + `bullhorn_note_attach`) ARE emitted at runtime — cycle.sh Step 9 validates each proposal through validate.sh, then emits `hh_decision_action "${_jn_atype}"` (cycle.sh lines 703-704) with per-type tallies at lines 705-709 and the `bullhorn_write_batch` summary row at lines 711-712. Until creds land, each row carries `write_state:deferred` in its reason (the batch summary tallies them as `deferred_no_creds:<N>`); the Gate-A-validated decision is real and audited, the transport is honestly deferred, never faked — post-creds the same rows carry `write_state:applied`. `context.sh` uses the canonical RLS-scoped `SELECT config->>'<key>' FROM tenant_adapters` path (v0.4 supplement LIVE on VPS per commit `a1bbcf6`), with `IFOS_FORCE_*` env fallbacks retained for fixtures/local-dev only. **Voice honesty:** no embedding classifier ships at v1.0 — Step 8 emits `unscored/no_corpus` (or `classifier_unavailable` when a corpus is active) rather than a faked score; validate.sh G5 is hard-when-scored / warn-when-unscored. LinkedIn (§4 Step 7) is an explicit NO-OP audit row (`linkedin_enrichment_skipped`). §10 lifecycle status remains **Proposed** pending Codex re-ratification of the built bundle + founder approvals — the status flip is founder-gated.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.2 (lines 105-116; §2.1 is the Diagnostic section).

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any AUTO-MERGE proposal with confidence <0.85 (per ULTRAPLAN A2 line 510) — Gate A's merge-confidence check applies to auto-merge proposals ONLY; held and dropped pairs are classified upstream at §4 Steps 3-4 per the spec-001 band→action table (≥0.85 + no 90d activity → auto-merge; 0.70–0.85 OR ≥0.85-with-recency → held via ESC_DUPLICATE_DETECTED; <0.70 → silent drop) and never reach Gate A. Gate B success threshold: ≥15% dedup AND ≥10% field-completeness — two independent thresholds, both must pass. SHIPPED v1.0 metric (cycle.sh Step 10, header lines 716-724 + computation lines 755-762): deterministic in-run `decision_log`-derived ratios — `dedup_pct = 100·merges/(merges + review-band pairs)`, `completeness_pct = 100·backfills/(backfills + still-missing rows)`. Explicit limitation: this is NOT yet measured against the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511) — no day-0 baseline exists yet; baseline-relative measurement is the documented post-pilot enhancement (accepted build deviation 6; captured at pilot onboarding per §9 Q6). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.

---

## §2 — Invocation surface

### Cron (v1.0)

```bash
# /etc/cron.daily/ifos-janitor → calls this script per tenant
0 2 * * * sudo -u ifos_user /usr/local/bin/ifos-janitor.sh --tenant <slug>
```

Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.

### Manual trigger (v1.0 — operator convenience)

```bash
ifosctl janitor --tenant <slug> [--dry-run] [--report-only]
```

`--dry-run` reports what WOULD be written without touching Bullhorn. `--report-only` regenerates the day-30 report without doing dedup/enrichment passes (used post-incident for manual report regeneration).

### v1.1+ surfaces (deferred)

- Brain UI "Run Janitor now" button → triggers via internal API
- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)

---

## §3 — Output shape

Two outputs per run. Both are load-bearing artefacts.

### Output 1 — Day-30 Markdown report

Located at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`. Eight sections:

| # | Section | Content |
|---|---|---|
| 1 | **Record counts** | Total candidates / contractors / clients / contacts / placements / opportunities before + after this run; deltas per entity type |
| 2 | **Dedup pairs** | List of duplicate candidate AND contractor pairs identified this run; for each pair: entity type (candidate / contractor — separate types per vertical-schema.yaml §1), `bullhorn_id`, match dimensions (name + email + phone + LinkedIn), confidence score, action taken (auto-merged ≥0.85 / approval-gated 0.70–0.85 via ESC_DUPLICATE_DETECTED / dropped <0.70) |
| 3 | **Field-completeness deltas** | Per entity-type table: which fields were filled in (e.g., candidate.location, contractor.day_rate); source of the backfill (Companies House lookup, LinkedIn enrichment, derivation from related entities) |
| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
| 5 | **Agent vs. consultant attribution** | Rows attributed to Janitor automated work vs consultant manual entry; supports the day-30 before/after narrative |
| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
| 7 | **Exception list** | Failed writes (Bullhorn 4xx/5xx, FK violations); rate-limit hits; dedup proposals flagged for review (confidence between 0.7-0.85); operator action items |
| 8 | **Executive summary** | 200-word narrative suitable for forwarding to the tenant's hiring leader; cites top-3 cleanup wins; quantifies time saved (hours of consultant data-entry work avoided) |

### Output 2 — Bullhorn writes (yellow tier)

Three write categories. Action types map to existing entries in `agents/_shared/autosend-policy.yaml` (all three below are already registered there as yellow-tier):

1. **Candidate / contractor merge** (`PUT /Candidate/{primary_id}` + cascade; candidate and contractor are separate entity types per vertical-schema.yaml §1 but share the §4 Steps 3-4 fuzzy-matcher) — auto-merged only when confidence ≥0.85 AND neither record had Bullhorn activity in the last 90 days (per ULTRAPLAN A2 line 510 verbatim); pairs in the 0.70–0.85 review band, or ≥0.85 with recent activity, are held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before any write. Action type: **`bullhorn_candidate_dedupe`** with `payload.entity_type ∈ {candidate, contractor}` discriminating the two — reused rather than a separate contractor action_type (same yellow tier + matcher; registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
3. **Tacit-note attach** (`POST /Note` linked to entity) — narrative summary of consultant edits + decision-log resolutions over the 30-day window. Action type: **`bullhorn_note_attach`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 20).

Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.

---

## §4 — Workflow

12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.

```
0. Session start
   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice corpus
     (used for tacit-note attribution) + recent edits (for note harvest)
   → hh_decision_trigger("session_start", "janitor nightly cron")

1. Bullhorn auth refresh
   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
     (bullhorn-integration-path.md §4.5)
   → ESC_BULLHORN_AUTH if refresh fails after 2 retries

2. Bullhorn entity scan (read-only)
   → enumerate candidates + contractors + clients + contacts + placements +
     opportunities created/modified since last Janitor run (last_run_at in
     tenant_adapters.config.janitor_last_run — declared in vertical-schema
     v0.3 supplement §4 tenant_adapters_config_additions.janitor_last_run;
     enforced by migrations/v0.2-to-v0.3.sql §5 validator allowlist)
   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per ESC_RATE_LIMIT_HIT catalogue §2.5 standard handling)

3. Dedup pass — candidate entity type
   → matcher: bin/dedup-pairs.sh (pure-jq deterministic helper; declared in
     tools.yaml as capability `janitor_dedup_matcher`)
   → fuzzy-match across (name, email, phone, linkedin_url) tuples
   → compute confidence per pair: name × 0.3 + email × 0.4 + phone × 0.2 + linkedin × 0.1
     (comparable-weight normalisation + required strong identifier per build
     deviation 1)
   → classify per the spec-001 §4 band→action table (the ONE model §1/§5/§6 cite):
     · ≥0.85 AND no Bullhorn activity on EITHER record in last 90d (per
       ULTRAPLAN A2 line 510) → AUTO-MERGE proposal (yellow tier; written at
       Step 9 behind Gate A)
     · 0.70–0.85, OR ≥0.85 with recent (or unknown) 90d activity → HELD for
       synchronous Telegram approval via ESC_DUPLICATE_DETECTED (SUCCESS-path
       approval gate, NOT a Gate A failure)
     · <0.70 → silent drop (tallied in the dedup_candidate_pass marker reason)
   → batch auto-band pairs into proposed-merge list (in-memory intermediate;
     not persisted — hh_decision_action emitted at Step 9 when each merge
     actually writes)

4. Dedup pass — contractor entity type
   → same algorithm as candidates (same bin/dedup-pairs.sh matcher + band
     table); separate entity_type per Q1 Day-6 resolution (vertical-schema.yaml §1)

5. Field completeness audit (canonical field names per vertical-schema.yaml)
   → for each entity, check critical fields: candidate.location (line 124),
     client.industry (line 238), client.size_employees (line 243),
     contractor.day_rate_min/day_rate_max (lines 193-197),
     brief.salary_min/salary_max (lines 371-376)
   → identify missing-field rows
   → batch enrichment calls
   → hh_decision_output("field_completeness_audit", tenant, "<N> missing-field rows")

6. Companies House enrichment (clients only)
   → tools.yaml capabilities `companies_house_search` (client.name per
     vertical-schema.yaml line 235 → CRN) + `companies_house_get_company`
     (CRN → profile) on @ifos/companies-house, invoked via bin/ch-lookup.mjs
     → fill canonical schema fields client.industry (line 238),
     client.companies_house_number (line 252)
   → 7-day cache + shared 600/5min rate budget live INSIDE the connector
     (Diagnostic precedent); budget shared with Diagnostic
   → ESC_RATE_LIMIT_HIT on 429

7. LinkedIn enrichment (candidates; v1.1 via Proxycurl)
   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
     signup commercial decision)
   → at v1.1: linkedin.profile_fetch(candidate.linkedin_url) → location +
     current_company → write back

8. Tacit-note harvest
   → query the `recent_edit` v0.2 table directly (per vertical-schema.v0.2-supplement.yaml
     recent_edit definition; v0.3 supplement §2a grants Janitor R access):
     SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
     AND resolution='approved_after_edit' AND tenant_slug=$tenant
   → join to decision_log only if action-context lookups needed
   → group by target_entity_type (candidate / contractor / contact / brief / etc.)
   → for each group, generate narrative summary via voice-classified LLM
     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
   → hh_decision_output("janitor_tacit_note_harvest", "tenant:<slug>",
     "harvested:<N> rows; groups:<M> entity-types; narrative_drafts:<K>")
   → on classifier fail after retries: hh_decision_action("validate_gate_a_fail",
     "tenant:<slug>", payload_hash, "ESC_VOICE_DRIFT; classifier_score:<N>")

9. Bullhorn write batch (yellow tier — spot-check sampling)
   → for each proposed merge / backfill / note: emit hh_decision_action with
     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
   → atomic per-write transaction (BEGIN/COMMIT)
   → on 4xx: emit ESC_BULLHORN_WRITE_FAIL; skip; continue
   → on 5xx: emit ESC_BULLHORN_WRITE_FAIL; retry once with 30s backoff

10. Day-30 report assembly
   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
     now() - interval '30 days' AND tenant_slug=$tenant
   → group by action_type; tally success/fail; compute Gate-B metric
   → 8-section Markdown report (per §3 above)
   → write to /vault/<tenant>/janitor-reports/day-30-<ISO-date>.md
   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")

11. Operator notification (Telegram)
   → if Gate-B target met: green-tier notification with summary
   → if Gate-B target missed: yellow-tier notification + 200-char executive
     summary suggesting consultant follow-up
   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
     notification_hash, "gate_b_state:met|missed; chars:<N>")

12. Session close
   → update tenant_adapters.config.janitor_last_run = now()
   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
   → exit code 0 (or 1 if BOTH Gate-B thresholds missed for 3 consecutive runs per §5 + catalogue → ESC_GATE_B_MISS)
```

### Audit coverage — consolidated model (per master brief §8.1 Change 2)

Every step that produces output or takes action audits to `decision_log` — but
not every step carries its OWN `hh_decision_*` row; two clusters consolidate
(deliberate, one model):

- **Step 1 failures** audit via the per-run `bullhorn_auth_refresh` output row
  (token state recorded every run) plus the `ESC_BULLHORN_AUTH` gating row on
  refresh failure or creds absence. There is no separate Step-1
  `hh_decision_action` row.
- **Steps 3-4 outcomes** audit downstream: AUTO-band pairs become the Step 9
  `bullhorn_candidate_dedupe` yellow action rows when each merge actually
  writes; HELD pairs each emit an `ESC_DUPLICATE_DETECTED` gating row at
  Steps 3-4 (catalogue §2.5 payload shape; also listed in the day-30 report §7
  exception list); DROPPED (<0.70) pairs are tallied in the
  `dedup_candidate_pass` / `dedup_contractor_pass` marker reasons
  (`dropped:<N>`) with batch outcomes summarised in `bullhorn_write_batch`.
  No held or dropped outcome is traceless.

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:

- Bullhorn auth refresh succeeded in Step 1 (no stale token writes)
- Every AUTO-MERGE proposal has confidence ≥ 0.85 per ULTRAPLAN A2 line 510 (G2 — applies to auto-merge proposals ONLY; review-band pairs are held upstream at §4 Steps 3-4 and never reach Step 9, so this check is defence-in-depth against a band-classification bug, not the band mechanism itself)
- No auto-merge proposal where EITHER record has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim; G3 — same defence-in-depth scope as G2)
- No field-backfill where source confidence <0.7 (CH 404 / LinkedIn empty / no derivation source)
- Tacit-note narratives pass voice classifier ≥ 0.75
- Bullhorn write batch size ≤ 100 per minute (rate-limit defensive)
- No PII outside firm boundary in tacit-note narratives (regex pass)

Gate A failure routing by class (per catalogue §2.5):
- PII detected outside firm boundary → `ESC_PII_LEAKAGE_RISK` (blocking; operator + ifos_oncall per catalogue routing)
- Tacit-note voice classifier <0.75 → `ESC_VOICE_DRIFT` (warn; operator_chat_id)
- Tone-rule violations → `ESC_TONE_RULE_VIOLATION` (warn; operator_chat_id per catalogue §2.10)
- Output-shape failures (section count, write-batch size, dedup confidence below threshold for action) → `ESC_AGENT_OUTPUT_SHAPE` (warn; operator_chat_id)

`ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT a Gate A failure code — per catalogue trigger it's the SUCCESS-path Telegram approval gate for dedup pairs that need human approval before merge: the 0.70–0.85 review band, plus any ≥0.85 pair where a record has Bullhorn activity in the last 90 days. Pairs ≥0.85 with no recent activity auto-merge (yellow tier, spot-check) and do NOT fire it. Sub-0.70 confidence pairs silently drop in the Step 3 algorithm; no ESC fire. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.

### Gate B — Outcome threshold (success metric, not block)

Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.

Two independent thresholds (both must pass): dedup improvement ≥15% AND field-completeness improvement ≥10%. NOT a composite — composite would let one cover the other.

**Shipped v1.0 measurement (W6-7 build; accepted deviation 6):** the live cycle.sh computes the two thresholds as deterministic in-run `decision_log`-derived ratios, not against a day-0 baseline — `dedup_pct = 100·merges/(merges + review-band pairs)` and `completeness_pct = 100·backfills/(backfills + still-missing rows)` (cycle.sh Step 10: header comment lines 716-724, computation lines 755-762; definitions printed in report §6). **Limitation, explicit:** ULTRAPLAN's "before/after vs day-0 baseline" semantics are NOT implemented yet because no day-0 baseline exists pre-pilot — the baseline is captured at first pilot onboarding (per §9 Q6), and baseline-relative Gate B measurement is the documented post-pilot enhancement. The thresholds (≥15% / ≥10%), the AND-logic, and the 3-consecutive-both-missed → `ESC_GATE_B_MISS` trigger are unchanged.

Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.

Per catalogue `escalation-codes.md` ESC_GATE_B_MISS trigger (Janitor example: "dedup confidence <15% AND field-completeness uplift <10%"): `ESC_GATE_B_MISS` fires only when BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND completeness-improvement <10%) → flag for operator review (heuristic tuning may be needed; not a kill). Single-threshold misses are tracked in the day-30 report (§3 Output 1 row 6) and inform tenant-level quality review but do NOT fire ESC. Sensitivity choice: strict AND-trigger reduces false alarms; tightening to OR-trigger requires a catalogue amendment + re-ratification.

---

## §6 — Escalation codes

All codes are registered in `agents/_shared/escalation-codes.md` (catalogue extended to 52 codes per `2026-05-24` bilateral disposition; see disagreement-doc + `catalogue(bilateral)` commit).

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on merge/backfill/note write | warn | operator_chat_id |
| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Tacit-note narrative voice classifier <0.75 (after 3 retries) | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (section count or per-section citation missing in day-30 report) | warn | operator_chat_id |
| `ESC_DUPLICATE_DETECTED` | Per catalogue §2.5 (amended 2026-06-10): dedup pairs needing human approval before merge — the 0.70–0.85 review band, plus ≥0.85 pairs with recent Bullhorn activity (SUCCESS path; Telegram approval gate fires). NOT a Gate A failure code. Payload per catalogue: `entity_a_id` / `entity_b_id` / `entity_type` (`candidate`\|`contractor`) / `confidence_score` / `match_basis` (e.g. `email+phone`) / `hold_reason` (`review_band` \| `recency_hold_90d`). | warn | operator_chat_id (via Telegram approval gate per catalogue routing) |
| `ESC_GATE_B_MISS` | Per catalogue trigger: per-agent local Gate B metric threshold missed. For Janitor: BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND field-completeness-improvement <10%) per catalogue `ESC_GATE_B_MISS` Janitor example. Single-threshold misses do NOT fire (per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |

Janitor does NOT use:

- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
- **OAuth-token revocation** — there is no separate `ESC_BULLHORN_OAUTH_REVOKED` catalogue code; revocation is folded into `ESC_BULLHORN_AUTH` via `payload.failure_type='revoked_401'` (per concierge §6 + catalogue). Janitor fires `ESC_BULLHORN_AUTH` (listed above) on any refresh/revocation failure
- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction

---

## §7 — Voice + tone constraints

Step 8 (tacit-note narrative generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
  - No identifying language about candidates beyond what's in their CV / Bullhorn record
  - No commercial sensitive information (rates / placement fees / commission %)
  - No external-party PII (clients of clients)
- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies — actual state (refreshed 2026-06-10 post-W6-7 build)

The W6-7 build slice is COMPLETE on this branch. The table below distinguishes three states precisely: **BUILT** (code exists, tests green), **fixture-proven** (behaviour verified against deterministic fixtures/DB suites, no live API call), and **live-credential-gated** (everything but the credential is in place; founder action).

| Dependency | Source | Status (2026-06-10) |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ ratified |
| Diagnostic first-agent precedent | `agents/recruitment/diagnostic/` | ✅ v0 BUILT + wired (its own lifecycle tracked in its agent.md) |
| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action |
| **Bullhorn Sub-decision A** | `docs/decisions/bullhorn-integration-path.md` | ✅ RESOLVED 2026-06-02 — direct API per-tenant OAuth; marketplace deferred to v1.1+ |
| **Bullhorn Sub-decision B** | Bullhorn developer-support route (`developer.bullhorn.com`) | ⏸ in flight; founder submitted 2026-06-02 |
| `@ifos/bullhorn` connector + CLI bridge | `packages/mcp-connectors/bullhorn` (v0.1.0, `dist/cli.js`) | ✅ BUILT — typecheck clean; vitest 52/52; `update-entity` (Candidate\|ClientContact\|JobOrder\|Placement) + extended `create-note` per the agreed CLI contract; zero live API calls made |
| Bullhorn live credentials (client_id + client_secret + tenant OAuth) | Tenant pilot OAuth ticket | ⏸ EMPTY — all six `BULLHORN_*` keys (names-only re-verified 2026-06-10); founder-gated; **the ONLY gap between fixture-proven and live on the Bullhorn path** |
| Companies House MCP connector | Day-13 shipped (`@ifos/companies-house`) | ✅ BUILT + live-capable (key SET); live-smoked once read-only via `bin/ch-lookup.mjs` (HAYS PLC → CRN 02150950) |
| Tenant `target_patch.json` + `_secrets.env` provisioned | provision-tenant.sh ran for first pilot | ⏸ Post-LOI |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ Post-LOI. No embedding classifier ships at v1.0 — Step 8 emits honest `unscored/no_corpus`; G5 warn-when-unscored (never a faked score) |
| `validate.sh` Gate A logic (G1-G7) | This branch (commit `184a2bf`) | ✅ LIVE — all 7 checks enforced; gate-a suite green (4 pass + 8 fail classes) |
| `context.sh` hydration | This branch (commit `184a2bf`) | ✅ LIVE — canonical RLS-scoped `tenant_adapters` SELECT path; `IFOS_FORCE_*` fallbacks retained for fixtures only |
| `cycle.sh` orchestration (12-step) | This branch (commit `184a2bf`) | ✅ LIVE — all 12 steps; fixture-proven end-to-end against the local dev DB (full smoke under a throwaway tenant) |
| Dedup heuristic + confidence scorer | `bin/dedup-pairs.sh` | ✅ LIVE — deterministic pure-jq; dedup suite green |
| 3 fixtures + DB-backed suites | `fixtures/` + `scripts/run-janitor-{dedup,gate-a,report}-test.sh` | ✅ green (`01-primary`, `02-edge-case-fuzzy-match`, `99-recent-activity-blocked`) |
| LinkedIn enrichment | §4 Step 7 | — NO-OP at v1.0 (explicit `linkedin_enrichment_skipped` audit row; vendor selection deferred to v1.1+) |

**The remaining ⏸ items no longer gate the build (done); they gate LIVE operation:** the Bullhorn live smoke (refresh → scan → one sandbox write through Steps 1-2-9) and pilot onboarding are founder-gated post-creds steps. Kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) context preserved for history: Bullhorn auth was not cleared in W5; the build proceeded fixture-first in W6-7 per spec-001 §8's honest-scope disposition (creds EMPTY, founder-gated; writes recorded as deferred, never faked) rather than deferring the agent.

---

## §9 — Status + open questions

**Status:** Proposed (W6-7 build slice COMPLETE on this branch; status flip founder-gated per §10). Still awaits: Bullhorn Sub-decision B (A RESOLVED 2026-06-02) + live Bullhorn credentials + Q1 LOI + Codex re-ratification of the built bundle + founder approvals below.

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
| Q2 | Field-completeness priority order — which missing fields are highest-impact to backfill first? | Founder review with first pilot tenant; varies by tenant focus (perm vs contract). |
| Q3 | Bullhorn write batch size — current default 100/min. Bullhorn published rate-limit isn't documented; we may need to negotiate. | Bullhorn commercial conversation Sub-decision B output. |
| Q4 | Tacit-note attribution — should notes attribute to "Intel Force OS Janitor" or just "Internal note"? Tenant brand preference. | Per-tenant config at first-pilot onboarding. |
| Q5 | Day-30 report distribution path — vault only OR also forwarded to tenant's hiring leader via email? | v1.0: vault only. v1.1: opt-in email forward via Concierge. |
| Q6 | Gate B exception handling — what if a tenant's day-0 baseline is already exceptionally clean (low headroom for improvement)? | Founder review at first 3-tenant cohort; may need per-tenant Gate B calibration. |

### Gotchas (carried forward from ULTRAPLAN A2 line 513)

1. **Bullhorn MCP server — RESOLVED at W6-7.** Originally "doesn't exist yet; critical-path build for v1.0" (per ULTRAPLAN A2 line 513). The `@ifos/bullhorn` connector package + `dist/cli.js` bridge are now BUILT (vitest 52/52); the remaining critical-path item is live credentials (founder-gated), not code.
2. **Dedup is hard; start conservative.** High-confidence merges only (≥0.85); tune up the threshold over time as data builds.
3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.

Status flips Proposed → Accepted (pre-build) when:
- Codex Round 4 Phase 2 ratifies
- Founder approves §9 open questions Q1 + Q2 + Q4 + Q5 + Q6
- Q3 resolves via Bullhorn Sub-decision B answer

Status flips Accepted → In Force when:
- ~~W5 build slice produces all 5 sibling bundle files + 3 fixtures~~ **SATISFIED 2026-06-10** — the W6-7 build slice (spec-001, this branch) shipped all 6 sibling bundle files + 3 fixtures LIVE; build-gate GREEN
- First production run against migration-test tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row) — pending; blocked on live Bullhorn credentials (founder-gated)
- Day-30 baseline measured for first pilot tenant — pending; post-LOI
- Codex re-ratifies post-build via `review-agent-bundle.md` skill — in progress on this branch

Current position (2026-06-10): the contract below is IMPLEMENTED — the bundle is built and fixture-proven, not production-proven (zero live Bullhorn calls). The §10 status field stays **Proposed** until the founder flips it; the flip is founder-gated, not Claude's call.

*End of Janitor agent.md draft.*
