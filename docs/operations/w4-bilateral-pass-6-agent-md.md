# W4 bilateral pass — 6 agent.md scaffolds → RATIFIED

**Date:** 2026-05-25 (Day 20)
**Goal:** disposition 24 residual Codex findings across 6 agent.md scaffolds and drive all 6 to **RATIFIED** in a single coordinated pass.
**Time-box:** 60-90 minutes founder + Claude.
**Trigger 2:** DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 — 20 days runway. Diagnostic is pass-order #1.

## How to read this doc

Each finding has the same 4-line shape:

```
Finding N. <one-line summary>
  Cite:       <file + line range>
  Codex says: <verbatim quote of the issue>
  Disposition: [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND
```

We tick a box per finding, do the edit (or write the disagreement), then rerun:

```bash
bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/<agent>/agent.md
```

When that returns `RATIFIED`, flip Status in the agent.md §10 from Pre-Build-Round-N-Reviewed → RATIFIED, commit, move to next agent.

**Source of these findings:** the latest round per agent in `logs/codex-ratification/20260524T*/`. Verbatim text quoted from each Codex response.

---

## Pass order

| # | Agent | Findings | Why this position |
|---|---|---|---|
| 1 | Diagnostic | 5 | Trigger 2 runway (20 days). Bundle code is complete; only RATIFIED is missing. |
| 2 | Janitor | 4 | All mechanical schema-citation fixes; cleanest pass. |
| 3 | Sourcing Scout | 3 | Lowest residual; one scope question (webhook auto-source). |
| 4 | Cash Conductor | 3 | Blocked partially by D1 (W4 #4) — pre-resolve docs-only items. |
| 5 | Scribe | 5 | Ringover scope question is the only non-mechanical. |
| 6 | Concierge | 4 | Depends on Concierge-Gate-A ADR (W4 #3) — may defer to that ADR. |

---

## 1. Diagnostic — `agents/recruitment/diagnostic/agent.md`

**Round:** R16 post-v0.3 (Pre-Build-Round-16-Reviewed). Log: `logs/codex-ratification/20260524T130117Z-63874/`.

### Finding 1. Voice escalation overstated for v0
  - **Cite:** §4 line 109; cross-ref generator README + `validate.sh` lines 253-255
  - **Codex says:** "Line 109 says `ESC_VOICE_DRIFT` is 'raised internally by §12 LLM step if classifier <0.75 after 3 retries,' but the generator README says v0 has 'No LLM-driven §12' and 'No voice classifier gate,' and `validate.sh` only calls the classifier once when `IFOS_VOICE_CLASSIFIER_URL` is set. Fix §4 to say voice drift is a `validate.sh` V3 concern in v0, with retries deferred to W4 if intended."
  - **Likely:** FIX-IN-PLACE. Rewrite §4 line 109 to scope to v0 (single-pass classifier on V3, no retries, no LLM §12). Add W4 forward-look as a parenthetical.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 2. ESC_RATE_LIMIT_HIT claimed but not implemented
  - **Cite:** §4 line 108 + §6 line 173; cross-ref `cycle.sh` (no 429 catch)
  - **Codex says:** "Lines 108 and 173 say `ESC_RATE_LIMIT_HIT` is raised for Companies House or LinkedIn 429s, but `cycle.sh` has no 429 catch or `hh_decision_action` path for that code; the generator CLI just exits generic on thrown errors. Fix by either implementing a 429 catch that emits `ESC_RATE_LIMIT_HIT`, or marking this as a W4/planned tools.yaml mapping rather than current v0 behaviour."
  - **Likely:** FIX-IN-PLACE + DEFER. Re-label both lines as W4-planned (mark with planned-W4 tag); implementation deferred to bundle-build slice.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 3. Gate A failure signature incomplete
  - **Cite:** §4 lines 117-119 vs §6 line 171 + `validate.sh` lines 253-255
  - **Codex says:** "Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature."
  - **Likely:** FIX-IN-PLACE. Add `ESC_VOICE_DRIFT` to the §4 line 117-119 signature list.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 4. Citation drift in §3
  - **Cite:** §3 line 45 citing `validate.sh` lines 89-97
  - **Codex says:** "Line 45 cites `validate.sh` lines 89-97 as saying 'W4 polish adds title + order check,' but those lines say only that exact heading matching is not implemented and 'At W3 build' it should tighten. Fix the citation wording to match the live file or remove the quoted claim."
  - **Likely:** FIX-IN-PLACE. Verify lines 89-97 of `validate.sh`, rewrite the quote to match exactly OR remove the quotation marks and rephrase as paraphrase.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 5. Stale Q3 resolution path
  - **Cite:** §9 line 238; cross-ref §8 lines 213-215
  - **Codex says:** "Line 238 says Proxycurl/API choice is 'Resolved at W3 start before Companies House + LinkedIn MCP connectors authored,' while this Day-19 artefact and §8 lines 213-215 say the connector/web-scraper work is already shipped and Proxycurl is deferred. Fix Q3 to describe the current W4 Proxycurl/commercial decision path."
  - **Likely:** FIX-IN-PLACE. Rewrite Q3 to describe the actual Day-19 disposition (Proxycurl deferred; current W4 decision is whether to re-evaluate before pilot).
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

---

## 2. Janitor — `agents/recruitment/janitor/agent.md`

**Round:** R11 post-v0.3. Log: `logs/codex-ratification/20260524T174156Z-10120/`.

### Finding 1. Gate A failures misrouted to single ESC code
  - **Cite:** §5 line 187
  - **Codex says:** "Line 187 says `ESC_AGENT_OUTPUT_SHAPE` applies to 'ALL Gate A conditions,' including voice classifier, PII, and write-batch size. The catalogue defines `ESC_VOICE_DRIFT` for classifier failures and `ESC_PII_LEAKAGE_RISK` as blocking for PII leakage; downgrading PII to `ESC_AGENT_OUTPUT_SHAPE` weakens Gate A routing. Fix §5 so each Gate A condition maps to its catalogue code, reserving `ESC_AGENT_OUTPUT_SHAPE` for report/output-shape failures only."
  - **Likely:** FIX-IN-PLACE. Split §5 line 187 into per-condition routing: voice → VOICE_DRIFT; PII → PII_LEAKAGE_RISK; batch-size → AGENT_OUTPUT_SHAPE.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 2. `decision_log.outcome='approved_after_edit'` is wrong field
  - **Cite:** §3 line 59; cross-ref v0.2 supplement §1.3 (recent_edit.resolution)
  - **Codex says:** "Line 59 says tacit notes are harvested from `decision_log` rows with `outcome='approved_after_edit'`, but the schema only documents `decision_log` as `agent_name`, `phase`, and `payload JSONB`; `approved_after_edit` is the `recent_edit.resolution` enum in v0.2 supplement §1.3. Fix §3 to harvest from `recent_edit.resolution='approved_after_edit'` and use `decision_log` only for action-context joins."
  - **Likely:** FIX-IN-PLACE. Rewrite §3 line 59 to source from `recent_edit.resolution`. Note that `decision_log.outcome` was added in `recent_edit`'s sister table in v0.3; verify this hasn't changed Codex's read.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 3. Wrong schema authority for recent_edit access
  - **Cite:** §4 lines 135-137; cross-ref v0.3 supplement §2
  - **Codex says:** "Lines 135-137 say Janitor queries the `recent_edit` v0.2 table directly, but v0.2 access lists only voice-drift-canary, Concierge, and LoRA; Janitor R access is added in v0.3 supplement §2. Fix the citation to v0.3 supplement and add v0.3 schema/migration ratification as a §8 prerequisite."
  - **Likely:** FIX-IN-PLACE. Update citation to "v0.3 supplement §2"; add v0.3 migration RATIFIED as §8 build prereq.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 4. `janitor_dedup_threshold` + `janitor_last_run` keys absent from schema supplement
  - **Cite:** §2 + §4 lines 42, 95, 166; cross-ref v0.3 migration §5 allowlist
  - **Codex says:** "Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement's `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist."
  - **Likely:** **REJECT-CODEX** with rationale, OR small schema supplement edit. The migration allowlist IS the v0.3 supplement enforcement (per ADR-006 + the v0.3 trigger). But Codex's point is that they should also appear in the YAML schema definition (`tenant_adapters_config_additions`) for documentation completeness. Founder call: edit the YAML supplement to declare them explicitly, OR write disagreement claiming migration-allowlist is sufficient single-source-of-truth.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

---

## 3. Sourcing Scout — `agents/recruitment/sourcing-scout/agent.md`

**Round:** R8 post-v0.3. Log: `logs/codex-ratification/20260524T151757Z-97714/`.

### Finding 1. False schema-status claim for `blocked_recipients`
  - **Cite:** §4 Step 8; cross-ref `v0.2-to-v0.3.sql` line 397
  - **Codex says:** "It says 'the actual config-key SCHEMA registration is v0.4-supplement-pending' and that v0.3 only registers other keys, but `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` §5 allowlists `blocked_recipients` at line 397. Fix by removing the v0.4-pending claim for `blocked_recipients`; keep v0.4-pending only for `auto_source_on_brief_create`."
  - **Likely:** FIX-IN-PLACE. Remove v0.4-pending claim for `blocked_recipients`; keep it only for `auto_source_on_brief_create`. (Verify: v0.3 migration line 397 does include `blocked_recipients` in allowlist? Confirmed in our earlier read: "tier_overrides, blocked_recipients, janitor_dedup_threshold..." — yes.)
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 2. Wrong Proposed→Accepted criteria for pre-build scaffold
  - **Cite:** §10
  - **Codex says:** "It flips to Accepted on ratification/founder questions/ADR-006 before the W9 bundle exists, but the agent-bundle skill treats Accepted as production-ready after sibling files + fixtures exist and pass gates. Fix by keeping this scaffold Proposed after ratification, and make Proposed → Accepted depend on W9 build completion: `tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`, and 3 fixtures."
  - **Likely:** FIX-IN-PLACE. Edit §10 to gate Accepted on W9 bundle completion (sibling files + fixtures + gate A). Ratified scaffold stays at "Proposed (Ratified at Round-N)" until W9.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 3. v1.0 Bullhorn webhook path active despite blocked config
  - **Cite:** §1 + §2; cross-ref `auto_source_on_brief_create` v0.4-pending
  - **Codex says:** "The output contract lists the webhook trigger as an active trigger, and §2 labels it 'Webhook (v1.0)', but §2 also says `auto_source_on_brief_create` is v0.4-supplement-pending and the code path is blocked. Fix by either moving webhook auto-source to deferred/v0.4+ surfaces, or add the v0.4 schema supplement as a hard §8 prerequisite and make the §1 contract explicitly conditional."
  - **Likely:** FIX-IN-PLACE. Either tag webhook trigger as "v0.4+" or condition §1 on the v0.4 supplement landing. Founder preference: scope question — is the webhook trigger part of v1.0 surface or deferred?
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

---

## 4. Cash Conductor — `agents/recruitment/cash-conductor/agent.md`

**Round:** R17 post-v0.3. Log: `logs/codex-ratification/20260524T145439Z-74254/`.

### Finding 1. §8 sibling bundle list incomplete; capability names missing
  - **Cite:** §8 lines 382-385; §4 various
  - **Codex says:** "Lines 382-385 list `validate.sh`, `context.sh`, `cycle.sh`, and fixtures, but omit `tools.yaml` and `cleanup.sh`; meanwhile lines 36 and 54 explicitly rely on `tools.yaml`, and §4 invokes accounting/Open Banking capabilities without declared planned capability names. Add `tools.yaml` and `cleanup.sh` to §8 and name the planned `tools.yaml` capability for each §4 provider step."
  - **Likely:** FIX-IN-PLACE. Add `tools.yaml` + `cleanup.sh` to §8 sibling list. Annotate §4 with planned capability names (`xero.invoices.list`, `truelayer.transactions.fetch`, etc.).
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 2. Concierge/D1 dependency under-specified
  - **Cite:** §8 line 380; cross-ref §4 lines 235-253 + line 244 (D1)
  - **Codex says:** "Line 380 says Cash Conductor only depends on Concierge `agent.md` being Accepted, but lines 235-253 require Concierge to receive drafts, run the approval bridge, transport sends, and callback; line 244 also cites the unresolved D1 path. Add Founder Decision D1 resolved + autosend bridge/Concierge transport availability as explicit prerequisites, or rewrite §4 to use the existing shared autosend approval helper without Concierge."
  - **Likely:** FIX-IN-PLACE. Add to §8 prereqs: (a) D1 resolved, (b) Concierge autosend-bridge live. Note: D1 is W4 queue #4 — this finding documents the dependency in the agent.md but does NOT block ratification of the scaffold (Status will be Proposed→Pre-Build pending D1).
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 3. Impossible draft audit-row shape (output phase with action_type)
  - **Cite:** §3 line 114; cross-ref §4 line 237
  - **Codex says:** "Line 114 says each draft writes `phase='output'` with `action_type='xero_reminder_draft_internal'`, but `xero_reminder_draft_internal` is an autosend action type and §4 line 237 correctly routes it through `hh_decision_action`; `hh_decision_output` rows use output-type payloads, not autosend tier dispatch. Change §3 so draft generation is an output row such as `output_type='chase_draft_generated'`, and the queued draft is a separate `phase='action'` row with `action_type='xero_reminder_draft_internal'`."
  - **Likely:** FIX-IN-PLACE. Split §3 line 114 into two rows: (a) `phase='output'` with `output_type='chase_draft_generated'`; (b) `phase='action'` with `action_type='xero_reminder_draft_internal'`.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

---

## 5. Scribe — `agents/recruitment/scribe/agent.md`

**Round:** R3 post-v0.3. Log: `logs/codex-ratification/20260524T174401Z-12038/`.

### Finding 1. Schema-source field names mismatched
  - **Cite:** §3 lines 76-80; cross-ref `vertical-schema.yaml` + v0.3 supplement
  - **Codex says:** "Lines 76-80 list `brief.start_date`, `placement.week_1_status_note`, and `opportunity.sector` as canonical/schema-verified, but `vertical-schema.yaml` uses `start_date_target` and the v0.3 supplement explicitly says `week_1_status_note` became `week_1_status_vault_path` and `opportunity.sector` is not yet in schema. Fix the field table to use schema-backed names or land the missing supplement before ratification."
  - **Likely:** FIX-IN-PLACE. Replace field names: `start_date` → `start_date_target`; `week_1_status_note` → `week_1_status_vault_path`. For `opportunity.sector`: drop from canonical, or escalate to "v0.4-pending" tag.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 2. Output/action steps missing `hh_decision_*` calls
  - **Cite:** §4 lines 141-149 (transcript fetch) + lines 180-184 (field extract/mutate)
  - **Codex says:** "Lines 141-149 refresh Bullhorn auth and fetch/store a transcript in `/tmp` without any decision-log write; lines 180-184 validate and mutate the extracted field set without a `hh_decision_output` or Gate-A failure action. Add decision-log calls for each output/action/failure point or mark the steps as purely internal with no side effect."
  - **Likely:** FIX-IN-PLACE. Add `hh_decision_output transcript_fetched` after line 149; add `hh_decision_output extraction_complete` + `hh_decision_action gate_a_passed/failed` after line 184.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 3. Ringover declared v1.0 without build dependencies
  - **Cite:** §3 lines 16, 30, 39; cross-ref §8 lines 295-298 + ULTRAPLAN A3 lines 521-523
  - **Codex says:** "Lines 16, 30, and 39 include Ringover as a provider, but §8 lines 295-298 only gate Fathom/Fireflies signup and connector work; ULTRAPLAN A3 lines 521-523 require Bullhorn, Fathom, and Fireflies tools/APIs, not Ringover. Either remove Ringover from v1.0 surfaces or add the Ringover commercial/API/connector prerequisites explicitly."
  - **Likely:** SCOPE question. Was Ringover ever in scope or is this a transcription? Founder call: drop Ringover from v1.0 (clean delete) OR add Ringover as a planned v1.1 surface (tag with v1.1-pending). Memory note: `feedback_cold_outreach_dont_overstate.md` and `feedback_verify_urls_before_claiming.md` suggest the founder prefers not overstating capabilities → recommend **drop Ringover** unless there's a specific pilot need.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 4. autosend-policy YAML citation wrong
  - **Cite:** §3 lines 16, 214
  - **Codex says:** "Line 16 cites `autosend-safety-policy.yaml` and line 214 cites `autosend-safety-policy §4`, but the runtime YAML in the repo is `agents/_shared/autosend-policy.yaml`; `autosend-safety-policy` exists as a decision `.md`, not YAML. Replace the YAML citation with `agents/_shared/autosend-policy.yaml` and cite the decision doc only when referring to policy rationale."
  - **Likely:** FIX-IN-PLACE. Replace `autosend-safety-policy.yaml` → `agents/_shared/autosend-policy.yaml` (runtime) where mechanical; keep `autosend-safety-policy §4` where it's the decision-doc rationale citation, but fix to `docs/decisions/autosend-safety-policy.md §4`.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 5. ESC_PROVIDER_FETCH_FAIL used outside catalogue definition
  - **Cite:** §6 line 250; cross-ref `agents/_shared/escalation-codes.md` lines 324-329
  - **Codex says:** "Line 250 defines it for Fathom/Fireflies/Ringover transcript fetches, but `agents/_shared/escalation-codes.md` lines 324-329 define a generic upstream read failure with examples that do not include transcript providers and no transcript-specific payload. Either update the catalogue to register transcript-provider usage and payload fields, or use/register a Scribe-specific transcript fetch code."
  - **Likely:** FIX-IN-PLACE. Either add transcript-provider examples + payload to catalogue line 324-329 (small edit; touches `_shared`, needs ratification of catalogue change too), OR register a new code `ESC_TRANSCRIPT_FETCH_FAIL`. Catalogue extension is cleaner.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

---

## 6. Concierge — `agents/recruitment/concierge/agent.md`

**Round:** R3 post-v0.3. Log: `logs/codex-ratification/20260524T174513Z-13185/`.

### Finding 1. Output/action steps missing `hh_decision_*` calls
  - **Cite:** §4 lines 187-193 (draft write) + lines 222-228 (approval routing)
  - **Codex says:** "Lines 187-193 write the draft to `/vault/<tenant>/concierge-drafts/<draft_id>.md` but do not log the output; lines 222-228 route approval via autosend-bridge but do not log the approval-routing action. Type-specific §1 requires every output/action step to call `hh_decision_*`. Add explicit `hh_decision_output` for draft creation and `hh_decision_action` or `hh_decision_output` for approval routing."
  - **Likely:** FIX-IN-PLACE. Add `hh_decision_output concierge_email_draft` after line 193; add `hh_decision_action approval_routed` after line 228.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 2. Draft mis-classified as orange tier
  - **Cite:** §3 line 67; cross-ref line 102 + `autosend-policy.yaml`
  - **Codex says:** "Line 67 says 'an email draft (orange tier)', but lines 102 and autosend-policy define `concierge_email_draft` as yellow; only the send actions are orange. This creates an internal contract conflict for Gate A/B and decision_log rows. Change line 67 to 'email draft (yellow tier); send is separate orange-tier action'."
  - **Likely:** FIX-IN-PLACE. Edit §3 line 67 verbatim per Codex's suggested phrasing.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 3. Gate-A→Gate-B reframe omitted from §10 status-flip criteria
  - **Cite:** §10 lines 417-421; cross-ref ULTRAPLAN A6 line 566 + lines 206-212/276
  - **Codex says:** "Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker."
  - **Likely:** **SCOPE-EXPAND**. This is the analogue of ADR-006 for Diagnostic. W4 queue #3 already plans this ADR ("Future ADR — Concierge Gate A 30-min SLA hybrid"). Disposition options:
    - (a) Add Concierge-Gate-A-ADR to §10 Accepted blockers; flip Concierge agent.md → RATIFIED (but Status stays Proposed pending ADR). W4 #3 then writes the ADR + closes the loop.
    - (b) Write the ADR NOW in this session (15-30 min) and then close both at once.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

### Finding 4. ULTRAPLAN line-citation drift
  - **Cite:** §3 lines 16, 39, 76, 333, 345; cross-ref ULTRAPLAN A6
  - **Codex says:** "Lines 16, 39, 76, 333, and 345 cite line 570 for lifecycle/rejection gotchas, but verified ULTRAPLAN has the gotcha text on line 569 and line 570 is blank. Update these citations to ULTRAPLAN A6 line 569."
  - **Likely:** FIX-IN-PLACE. Find-and-replace `ULTRAPLAN A6 line 570` → `ULTRAPLAN A6 line 569`. Verify count: 5 sites.
  - **Disposition:** [ ] FIX-IN-PLACE  [ ] DEFER  [ ] REJECT-CODEX  [ ] SCOPE-EXPAND

---

## Cross-cutting observations

1. **Hh_decision_* coverage** (Scribe #2, Concierge #1) — workflow narratives are dropping the decision-log writes between numbered steps. After this pass, recommend a one-shot grep on all 6 agent.md to confirm every workflow step that produces output/action has an `hh_decision_*` annotation.

2. **Schema-citation hygiene** (Janitor #2, #3, #4; Sourcing Scout #1; Scribe #1) — v0.2/v0.3 supplement boundary is the single most-failed cross-reference. After this pass, recommend a CI grep that flags any `agent.md` field reference whose name doesn't appear in `vertical-schema.yaml` OR `vertical-schema.v0.3-supplement.yaml`.

3. **Catalogue completeness** (Diagnostic #2, Janitor #1, Scribe #5) — `escalation-codes.md` is the canonical mapping; agent.md narratives drift from it. After this pass, recommend a CI grep verifying every `ESC_*` reference in `agent.md` exists in the catalogue with at least the agent_name in `used_by`.

4. **Concierge Gate-A ADR** (Concierge #3) — only structural finding. Recommend writing the ADR before flipping Concierge to RATIFIED (analogue of ADR-006 process).

5. **Status semantics** (Sourcing Scout #2) — confirm with founder: "Ratified at Round-N" is not "Accepted"; Accepted requires bundle completion. Likely a one-line clarification in the agent-bundle skill or master brief §8 to prevent this drift in future agents.

---

## Acceptance checklist (per agent)

For each of the 6 agents, the bilateral pass produces:

- [ ] All findings dispositioned (FIX-IN-PLACE / DEFER / REJECT-CODEX / SCOPE-EXPAND)
- [ ] FIX-IN-PLACE edits applied to agent.md (or sibling files)
- [ ] REJECT-CODEX disagreements written to `docs/decisions/codex-disagreement-2026-05-25.md`
- [ ] SCOPE-EXPAND items moved to W4 backlog with concrete next-action
- [ ] `bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/<agent>/agent.md` returns `RATIFIED`
- [ ] §10 Status flipped Pre-Build-Round-N-Reviewed → **RATIFIED**
- [ ] Commit with `bilateral-pass(w4): <agent> → RATIFIED + N residuals dispositioned`

## Session-close acceptance

- [ ] 4-6 of 6 agents RATIFIED in this session
- [ ] Remaining agents have concrete blockers documented (e.g., "Concierge pending Concierge-Gate-A ADR")
- [ ] Diagnostic is RATIFIED (Trigger 2 burn-down)
- [ ] `.agents/current-priorities.md` updated with W4 Day-20 close
