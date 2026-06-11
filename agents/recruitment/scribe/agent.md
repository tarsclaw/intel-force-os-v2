# Scribe — the data spine

**Status:** Proposed.
**Build state (post-W6 build slice, 2026-06-10):** the W6 build slice is BUILT on branch `worktree-agent-a59f16e915e384257`: `cycle.sh` (10-step, 4 modes), `validate.sh` (Gate A G1-G8), `context.sh`, `cleanup.sh`, `tools.yaml`, 5 `bin/` helpers, 3 fixtures + 3 deterministic DB-backed fixture suites — all green under `scripts/build-gate.sh` **against the dev DB** (run evidence: per-assert outputs recorded in `docs/features/agent-build/03-implementation/scribe-summary.md`; note: build-gate skips the DB suites wherever `IFOS_DB_URL` is unreachable — in such an environment the suites SKIP rather than pass, so "all green" is an evidence claim about the dev-DB runs, not about every environment; gate hardening tracked by the orchestrator). This document was reconciled to the built Granola-poll reality in the round-2 fix pass (Codex round-1 findings 1-4). **What has NOT happened:** no live Bullhorn or Granola call — Bullhorn dev creds are EMPTY, the `@ifos/bullhorn` CLI bridge is the Janitor build slice's parallel deliverable (Scribe consumes it only through `bin/bh-bridge.sh`), the Granola IFOS-side OAuth token is not on disk, and `@ifos/granola` has no built CLI. Live smoke is founder-gated (see §8). Earlier history: Day-20 W4 bilateral pass + R19 substantive fixes; pre-pivot Fathom/Fireflies prose removed 2026-06-10 (see vendor note below).
**Vendor note (Day-29 pivot, founder-decided 2026-06-03):** the v1.0 transcript vendor is **Granola** (`@ifos/granola`; official MCP server mcp.granola.ai/mcp). The original W3 draft of this document specified a webhook-driven flow from Fathom/Fireflies; that is PRE-PIVOT history, not the v1.0 path (no Fathom/Fireflies signup, connector, or webhook contract exists in v1.0). Granola publishes no webhooks, so the operational trigger is a **poll-sweep**; a generic verified-webhook surface is retained as a secondary mode (§2). This reconciliation is contract-prose truth-up only — the §10 status flip remains founder-gated and is NOT exercised here.
**Per-component state (honest, verified 2026-06-10):** `cycle.sh`/`validate.sh`/`context.sh`/`cleanup.sh`/`bin/*` BUILT + fixture-proven; `context.sh` reads `tenant_adapters.config` (v0.4 keys `bullhorn_corporation_id` + `granola_workspace_id`) with `IFOS_FORCE_*` env fallbacks for fixtures; LLM extraction path EXISTS but is opt-in (`IFOS_SCRIBE_USE_LLM=1`) — fixtures run the deterministic extractor; the voice classifier is NOT built (notes carry honest `unscored/no_corpus` or `unscored/no_classifier`); `bin/bh-bridge.sh` conforms to the agreed `@ifos/bullhorn` CLI contract (review-scribe.md orchestrator ruling) and degrades honestly (exit 3 `unavailable`, no fake writes) until the Janitor bridge lands.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
**Tier:** Tier 2 (event-driven — Granola poll-sweep cron + secondary webhook mode; not persistent PTY) per ULTRAPLAN A3 line 518 (drafted pre-pivot as "webhook-driven"; the tier classification is unchanged by the trigger swap).

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Scribe ingests a call transcript from Granola (`@ifos/granola`; discovered by a 5-minute poll-sweep of meetings since the last poll — Granola publishes no webhooks; Ringover deferred to v1.1+) and produces TWO outputs per meeting:** (1) a structured Bullhorn write payload populating the per-entity Gate A minimum of placement-relevant fields on the appropriate entity (≥3 for candidate / brief / opportunity / placement; ≥2 for contact, whose Scribe-writable v0.3 set is exactly two fields — §3; contractor is NOT a v1.0 resolution target — see §3), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS) **except for Opportunity, which is cache-only/vault-only at v1.0** (§3); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of **meeting end (`ended_at`) — the single timing anchor**; poll-discovery latency (the 5-minute sweep cadence) is a component within that window, never a second anchor (per master brief §8.2 line 597). Gate A hard-fails any transcript that doesn't produce the per-entity minimum of structured-field extractions (Contact 2, others 3 — §5 G2; ULTRAPLAN A3 line 524's ≥3 predates the v0.3 Contact write scope). The tacit-note carries no confidence threshold of its own — as shipped it is gated by voice score ≥0.75 when a real numeric score exists, warn-and-pass when unscored (no classifier in v1.0 — §5 G3), plus the structural checks: rendered to the 8-category taxonomy (§3 Step-6 renderer), ≤800 words (§5 G8), and the full-note-body PII scan (§5 G6). Gate B success threshold: 90% of calls completing their Bullhorn write within 5 minutes of **meeting end (`ended_at`) — the single timing anchor** (§5); consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1 — with the honest `unscored` state while the classifier is unbuilt (§5 G3 warn-when-unscored).

---

## §2 — Invocation surface

### Granola poll-sweep (v1.0 PRIMARY operational trigger)

```bash
cycle.sh --mode poll-sweep        # 5-minute cron (default mode)
```

Granola publishes no webhooks, so the operational trigger is a 5-minute cron
that lists meetings since `CTX_GRANOLA_LAST_POLL` (`@ifos/granola`
`list-meetings --since <ISO>`; `granola_meetings_polled` discovery row) and
runs Steps 2-10 per new meeting. The Step-1 `webhook_verified` marker is
emitted honestly with `method:poll; signature:not_applicable` — there is no
external webhook input to verify in this mode, and Gate A G1 accepts
`{verified, not_applicable}` while hard-failing `{invalid, missing}`.
`--dry-run` runs the sweep through Step 7 only (no Step 8/9 writes;
`dry_run_writes_skipped` row).

### Generic verified webhook (v1.0 SECONDARY mode — supported, not the operational path)

```bash
cycle.sh --mode webhook --payload <json file> \
  ( --signature sha256=<hex> | --bearer <token> )
```

The implementation also carries a generic per-call webhook surface for any
future provider that does push: HMAC-SHA256 over the payload file (secret
`$SCRIBE_WEBHOOK_SECRET`, `openssl dgst`) or bearer-token compare. Signature
mismatch → `ESC_INPUT_VALIDATION_FAIL` + `webhook_verified` row with
`result:invalid; rejected:401` + exit 1 (the HTTP layer maps this to 401).
The payload carries the meeting metadata (`call_id`, `metadata.title`,
`metadata.end_time`, `duration_seconds`, `participants`,
`metadata.notes_markdown`). No v1.0 provider pushes to this surface —
Granola is poll-only.

### Manual trigger (v1.0 — debugging / replay)

```bash
ifosctl scribe replay --tenant <slug> --call-id <granola_meeting_id>
# implemented as: cycle.sh --mode replay --call-id <meeting_id>
```

Useful when a poll window was missed or a transcript needs reprocessing after
a taxonomy update.

### Pre-pivot note (historical)

The W3 draft of this section specified Fathom (HMAC) / Fireflies (bearer)
webhooks as the v1.0 primary path. That was superseded by the Day-29 Granola
pivot (founder, 2026-06-03); no Fathom/Fireflies connector, signup, or
contract exists in v1.0.

### v1.1+ surfaces (deferred)

- Telegram command (`@ifos_bot scribe replay <call-id>`)
- Brain UI per-call "Reprocess" button
- Brain UI "Confidence audit" view showing extraction confidence histograms

---

## §3 — Output shape

Two outputs per meeting. Both write atomically; Step-9 failure rolls back Step 8 (best-effort — §4 Step 9 + §9 Q5). The Gate-B `recent_edit` row is only inserted after Step 9 settles (the table is append-only for `ifos_app`), so a rolled-back write never enters the edit-rate denominator.

### Output 1 — Bullhorn structured-field writes (per-entity Gate A minimum: Contact 2, others 3)

Target entity inferred from non-firm participant emails matched against the
RLS-scoped IFOS `entities` cache, most-context-specific entity first
(resolution priority: **placement > brief > opportunity > contact >
candidate** — a placed candidate's check-in resolves to the Placement, not
the Candidate):
- 1:1 call with candidate → Candidate entity update
- 1:1 call with client contact → Contact entity update
- Briefing call (consultant + client) → Brief entity update
- Placement check-in (consultant + placed candidate) → Placement entity update
- Opportunity scoping (consultant + prospect) → **cache-only path** (below)

**Contractor is NOT a v1.0 resolution target.** The built resolver's priority
set is exactly the five types above; `contractor` is not in the entity-cache
resolution shape and has no field table or Bullhorn write mapping in this
slice. v1.1+ may add it once the contractor entity lands in the cache + the
vertical schema defines its writable fields — until then it is excluded from
this contract rather than promised and papered over.

**Opportunity output contract (cache-only/vault-only at v1.0).** The Bullhorn
endpoint A3 row covers Candidate / ClientContact / JobOrder / Note /
Placement only at v1.0 — there is no Opportunity PATCH endpoint and no
Bullhorn Note target for it. For a resolved `opportunity` the contract is:
- Output 1 → IFOS-cached Postgres `entities` row update ONLY (the v0.3
  fields `headcount_growth_signal_text` + `hiring_velocity_band` +
  `decision_window_text` per v0.3 supplement §1); the
  `bullhorn_scribe_field_write` action row records
  `bullhorn_push:cache_only_by_design` — no Bullhorn PATCH is attempted.
- Output 2 → vault note ONLY (canonical per ADR-002). Step 9 is skipped with
  a `note_attach_deferred` output row,
  `reason:opportunity_cache_only_no_note_endpoint` — Opportunity is
  **excluded from the "note mirrored to Bullhorn" promise**; a consultant
  reads it in the vault/Brain UI until a v1.1+ Bullhorn surface exists.

**Per-entity Gate A minimum (Codex R2-1).** The Gate A field-count bar is per entity, set by the size of each entity's Scribe-writable schema: **Contact = 2** (`preferred_channel` + `next_action_target_date` are its ONLY Scribe-writable v0.3 fields — `decision_authority` is R-only per the v0.3 §2 access matrix), **all other entities = 3** (ULTRAPLAN A3 line 524's ≥3, which predates the v0.3 Contact write scope). A blanket ≥3 would hard-fail every legitimate Contact-resolved call, since at most 2 writable fields can survive G4/G5. Extraction may surface MORE than the minimum (including R-only fields like `decision_authority`); R-only material flows to the tacit-note narrative only — it never enters the structured-write payload. Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):

| Entity | Canonical fields (schema-verified) |
|---|---|
| Candidate | `location`, `current_role`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (v0.3; enum per supplement §1), `key_skills` (v0.3; list) |
| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
| Placement | `start_date`, `placement_status` (v0.3), `week_1_status_vault_path` (v0.3; vault pointer, not narrative), `satisfaction_signal` (v0.3) |
| Opportunity | `headcount_growth_signal_text` (v0.3), `hiring_velocity_band` (v0.3), `decision_window_text` (v0.3) |

Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Field-name accuracy is enforced at runtime, not by prose: `bin/validate-fields.sh` derives its per-entity allowlist + type/range checks from the schema files themselves (mirroring the `validate_entities_data_v0_3` DB trigger), so Gate A G4/G5 fail any drift between this table and the schema as actually deployed.

Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.

### Output 2 — Tacit-note Markdown attachment

One Markdown note per call, attached to the same Bullhorn entity as Output 1 via the `@ifos/bullhorn` `create-note` surface (through `bin/bh-bridge.sh`) — except Opportunity, which is vault-only at v1.0 (cache-only path above). Structure:

```markdown
# Tacit notes — <Call-context-summary>
**Date:** <ISO-date>  **Duration:** <N> min  **Participants:** <list>

## Things observed that don't fit a structured field

- <Observation 1 — bullet, 1-2 sentences, with transcript timestamp [MM:SS]>
- <Observation 2 — ...>
- ...

## Tone signals

- <Tone signal 1 — e.g., "client sounded frustrated about Bullhorn data quality">
- <Tone signal 2 — ...>

## Open questions for consultant follow-up

- <Open question 1>
- <Open question 2>
```

Length cap: 800 words. Voice-classified (≥0.75). Persistent classifier failure (after 3 retries) is a **hard Gate A failure** — fires `ESC_VOICE_DRIFT` + `validate_gate_a_fail`; the note is NOT attached to Bullhorn (Step 9 is skipped) and is held as a `/tmp`/vault draft flagged "needs consultant review" for manual handling. The placeholder is explicitly a non-success state, never a passing output.

Each tacit-note write emits its own `decision_log` rows: on vault render, `agent_name='scribe'`, `phase='output'`, `output_type='tacit_note_rendered'` carrying `{vault_path, body_sha256, voice_score}` (body NOT in payload per ADR-002 vault/Postgres split); on Bullhorn attach, `phase='action'`, `action_type='bullhorn_note_append_summary'`, `tier='yellow'`, payload carrying `note_payload_hash` + `payload_preview` + the resolved `<entity_type>:<bullhorn_id>` (per §4 Steps 6 + 9).

Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
1. Relationship signal (client warmth, candidate enthusiasm, prior friction)
2. Process friction (consultant complaint, tool gap, time waste)
3. Competitive intel (mentions of competitor agencies / candidates working with others)
4. Pricing/budget signal (off-record indications of room or constraint)
5. Decision-process insight (who actually decides; coffee-machine politics)
6. Calendar / availability nuance (vacation, life events affecting timeline)
7. Cultural fit observation (working style, communication preferences)
8. Risk flag (legal, IR35, compliance, reference concerns)

v1.1+: expand taxonomy based on first 3 pilot tenants' patterns.

---

## §4 — Workflow

10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Steps 0-2 are per-session; Steps 3-10 run per discovered meeting (the poll-sweep iterates; replay/webhook process one call).

```
0. Session start
   → context.sh hydrates: tenant config (tenant_adapters v0.4 keys) + voice
     corpus id (direct voice_corpus lookup) + tone rules (hh_load_tone_rules
     — the only voice-loader call wired in v1.0; §7) + granola plan_tier
     cache (recent_edits drift input NOT hydrated in v1.0 — §7 declared gap)
   → hh_decision_trigger("session_start", "scribe mode=<mode> call_id=<id|NA>")

1. Discovery / webhook verification (mode-dependent)
   → poll-sweep (PRIMARY): @ifos/granola list-meetings --since
     <CTX_GRANOLA_LAST_POLL>; emits webhook_verified with
     "method:poll; signature:not_applicable" (honest — no external input to
     verify) + granola_meetings_polled discovery row (count, window,
     workspace_id)
   → webhook (SECONDARY): HMAC-SHA256 over payload file (secret
     $SCRIBE_WEBHOOK_SECRET) or bearer compare;
     ESC_INPUT_VALIDATION_FAIL on mismatch; reject with 401 (exit 1)
   → replay: single-meeting hydrate; "method:manual_replay;
     signature:not_applicable"
   → hh_decision_output("webhook_verified", "call:<id|sweep>", "provider:granola; …")

2. Bullhorn auth refresh (via bin/bh-bridge.sh refresh ONLY)
   → bridge runs the network-free check-auth probe first: creds/token not
     provisioned → result:unavailable (NO ESC — honest degrade; Gate A G7
     then blocks Bullhorn writes); genuine refresh failure after 2 retries →
     ESC_BULLHORN_AUTH (blocking)
   → hh_decision_output("bullhorn_auth_refreshed", "tenant:<slug>",
     "corporation_id:<id>; result:refreshed|fresh|unavailable|failed")

3. Granola transcript fetch (per meeting)
   → @ifos/granola get-transcript --meeting <id> (PAID-plan tool; pre-guarded
     by CTX_GRANOLA_PLAN_TIER — free tier degrades to notes-only ingest
     BEFORE any wire round-trip)
   → ESC_PROVIDER_FETCH_FAIL (upstream=granola) on failure; retry once 30s
     backoff, then degrade to notes_markdown ingest if present, else skip
   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
     (0600 from birth — umask 177)
   → DECLARED DEVIATION 10: the spec's transcript-side ESC_PII_LEAKAGE_RISK
     is NOT implemented — transcripts inherently contain third-party contact
     data; the /tmp copy is 0600 + purged ≤24h and never leaves the firm
     boundary; the control point for what DOES leave is Gate A G6's
     FULL-note-body scan (Step 7 → validate.sh)
   → hh_decision_output("transcript_fetched", "call:<id>",
     "provider:granola; bytes:<N>; tmp_path:<path>; ingest_mode:<m>; plan_tier:<t>")

4. Participant + entity inference
   → non-firm participant emails (CTX_FIRM_DOMAIN_WHITELIST) matched against
     the RLS-scoped IFOS entities cache; priority placement > brief >
     opportunity > contact > candidate (§3; contractor not in the v1.0 set)
   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
     a Scribe run with no resolvable target cannot produce structured writes)
   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>",
     "call:<id>; confidence:<N>; match:email_exact")

5. Field extraction (deterministic default; LLM opt-in)
   → bin/extract-fields.sh: deterministic regex extraction
     (fixture-reproducible default) — or the LLM path when
     IFOS_SCRIBE_USE_LLM=1 + key present (json_schema output, deterministic
     fallback on any failure)
   → output = JSON with per-field confidence scores
   → discard fields confidence <0.6 (per Gate A)
   → require ≥ the per-entity Gate A minimum (contact 2, others 3 — §3) of
     fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
     (catalogue aggregate form — payload: entity_type, fields_extracted_count,
     confidence_floor 0.6, required_minimum, agent_name)
   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
     "<N> fields ≥0.6 confidence; extractor:<deterministic|llm_with_deterministic_fallback>")

6. Tacit-note generation (deterministic renderer; voice scored HONESTLY)
   → bin/render-tacit-note.sh: §3 Output 2 shape + 8-category taxonomy +
     tone rules (≤12-word quote clip; no compensation in narrative;
     participant emails masked to local parts)
   → voice score resolution — never faked: numeric only via the test hook /
     future classifier wire-in; otherwise unscored/no_corpus or
     unscored/no_classifier (classifier microservice not built — §8)
   → numeric score <0.75 → note flagged needs_consultant_review; Gate A G3
     hard-fails it (ESC_VOICE_DRIFT); the 3-retry loop applies only to a
     future non-deterministic generator (retries:0 recorded today)
   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md mode 0600
   → hh_decision_output("tacit_note_rendered", "<vault_path>",
     "vault_path:<p>; body_sha256:<h>; voice_score:<s>; words:<N>; retries:<n>")
     — metadata ONLY per ADR-002; body never in payload

7. Field-extraction validation against vertical-schema
   → verify each extracted field name exists in target entity schema
   → verify each extracted value passes per-field type/range checks
   → drop invalid; require ≥ per-entity minimum valid (contact 2, others 3 —
     §3; failure = ESC_SCHEMA_VIOLATION per catalogue line 163 —
     vertical-schema field-constraint violation at write time)
   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
     "<N> valid of <M> extracted; dropped:<N-invalid>")
   → on Gate A failure (< per-entity minimum valid): hh_decision_action("validate_gate_a_fail",
     "<entity_type>:<bullhorn_id>", payload_hash,
     "ESC_SCHEMA_VIOLATION; agent_name:scribe; valid:<N>") and exit 1
     (validate_gate_a_fail is the canonical green-tier action_type registered
     in agents/_shared/autosend-policy.yaml line 119; agent:all; Scribe uses
     the shared signature with agent_name in payload to distinguish.)

8. Bullhorn write — structured fields (yellow tier)
   → primary surface: RLS-scoped IFOS entities-cache UPDATE (the
     validate_entities_data_v0_3 DB trigger re-enforces shapes at write
     time); prior-data snapshot taken for rollback
   → Bullhorn PATCH push via bin/bh-bridge.sh
     update-entity --entity-type <T> --id <N> --patch <json>; push state
     recorded honestly on the action row
     (bullhorn_push:pushed|deferred_bridge_unavailable|cache_only_by_design)
   → opportunity: cache-only by design (§3) — no PATCH attempted
   → on success: hh_decision_action("bullhorn_scribe_field_write",
     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
   → the Gate B recent_edit row (resolution='deferred') for this write is
     inserted only AFTER Step 9 settles — recent_edit is append-only for
     ifos_app, so the denominator stays honest by never writing the row for
     a write that gets rolled back
   → on PATCH hard-fail: roll the cache back; ESC_BULLHORN_WRITE_FAIL;
     do NOT proceed to Step 9

9. Bullhorn write — tacit-note attachment (yellow tier)
   → bin/bh-bridge.sh create-note --entity-type <T> --entity-id <N>
     --body-file <vault note> --title <s> (mirror of vault artefact from
     Step 6 — the FULL body, which is why Gate A G6 scans the full body)
   → CLI {ok:false, reason:"unsupported_entity"}: person-scoped fallback
     (create-note --person-id <N>) when the resolved entity IS a person
     (candidate/contact); otherwise honest defer (note_attach_deferred row,
     reason:unsupported_entity) — never faked
   → bridge unavailable: note_attach_deferred row (no yellow row — no
     Bullhorn state changed); opportunity: deferred by design (§3)
   → on success: hh_decision_action("bullhorn_note_append_summary",
     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
   → on hard failure: rollback Step 8 (best-effort cache restore + reverse
     PATCH); no recent_edit row exists yet (inserted only after this step
     settles), so Gate B's denominator isn't inflated; ESC_BULLHORN_WRITE_FAIL

10. Session close + SLA metric
   → per-call elapsed_seconds anchored to MEETING END (`ended_at`) — the
     single timing anchor, stated identically in §1 and §5 (cycle.sh computes
     elapsed from the meeting's end_time payload field; bin/sla-class.sh
     buckets it). Poll-discovery latency (the 5-minute sweep cadence) is a
     component within that window, never a second anchor — it counts against
     Scribe, honestly (consistent with the catalogue's "after call end"
     wording; stricter than any receipt-time anchoring)
   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
     10 min". Catalogue ESC_SCRIBE_SLA_MISS triggers (line 443): "summary-render
     >30 min OR note-attach >1h after call end". The two thresholds are
     different scopes — master brief 10-min is the product UX promise; catalogue
     30-min/1h is the alerting threshold (less false alarms).
   → if elapsed > 3600 (1h): fire ESC_SCRIBE_SLA_MISS with `sla_type=note_attach` (per catalogue)
   → if elapsed > 1800 (30 min): fire ESC_SCRIBE_SLA_MISS with `sla_type=summary_render` (per catalogue)
   → if elapsed > 600 (10 min) but ≤ 1800: NO ESC fire — recorded as Gate B
     "10-min miss" in the day-30 report aggregation; counts against Gate B 90% target
   → if elapsed > 300 (5 min) but ≤ 600: info-level (still under product promise)
   → hh_decision_action("scribe_run_complete", "call:<last_id>",
     "mode; calls_processed/skipped; field_writes; note_attaches;
     sla_class:<WORST class across the sweep>")
   → exit 0 (poll-sweep/dry-run always; replay/webhook exit 1 on a per-call
     gate failure)
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` (BUILT — runs between cycle.sh Step 7 and Step 8) enforces:

- G1 — webhook signature state: `verified` or `not_applicable` (poll/replay — no external input exists); `invalid`/`missing` hard-fail
- G2 — structured-field extractions with confidence ≥0.6 meet the **per-entity minimum: Contact 2, all other entities 3** (§3; ULTRAPLAN A3 line 524's ≥3 applies to the 3-field entities — it predates the v0.3 Contact write scope of exactly two Scribe-writable fields)
- G3 — tacit-note voice classifier ≥0.75 — hard fail on a numeric score below threshold; **warn-when-unscored** (no corpus / no classifier ⇒ a score cannot be honestly computed; warned, never faked)
- G4 — field names exist in target entity per vertical-schema.yaml (+v0.3 supplement)
- G5 — per-field type + range validation passes; ≥ per-entity minimum valid after drops (Contact 2, others 3)
- G6 — no PII outside firm boundary in the tacit-note narrative — scans the **FULL physical note body** resolved from `tacit_note.vault_path` (Step 9 exports the full body to Bullhorn; the 500-char preview is the audit-row artefact only); fail-closed when the body is unreadable
- G7 — Bullhorn auth refresh succeeded this session (fresh `bullhorn_auth_refreshed` row, result fresh|refreshed; `unavailable`/`failed`/absent blocks all Bullhorn writes)
- G8 — tacit-note word count ≤800 (§3 cap)

Gate A failures fire the per-check ESC class (`ESC_INPUT_VALIDATION_FAIL` / `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` / `ESC_VOICE_DRIFT` / `ESC_SCHEMA_VIOLATION` / `ESC_PII_LEAKAGE_RISK` / `ESC_BULLHORN_AUTH` / `ESC_AGENT_OUTPUT_SHAPE`) + a `validate_gate_a_fail` action row; transcript stays in `/tmp` (auto-purged 24h); operator notified.

### Gate B — Outcome thresholds (success metrics, not block)

Two metrics, **ONE timing anchor: meeting end (`ended_at`) — the single timing anchor, stated identically in §1 and §4 Step 10** — as implemented (cycle.sh Step 10 computes `elapsed` from the meeting's `end_time` payload field; `bin/sla-class.sh` buckets it):

- **SLA:** ≥90% of calls have their Bullhorn write completed within 5 minutes of **meeting end (`ended_at`)**. Poll-discovery latency (the 5-minute sweep cadence, §2) is a *component within that window*, never a second anchor — it counts against Scribe; there is no separate "webhook receipt" or "poll receipt" anchor at v1.0.
- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)

**ULTRAPLAN drift note (pre-pivot wording; noted only — ULTRAPLAN not edited):** ULTRAPLAN A3 line 525 reads "90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%". The "of webhook" anchor predates the Day-29 Granola pivot (§2: Granola publishes no webhooks; the poll-sweep is the primary trigger and the secondary webhook mode has no v1.0 provider). The implemented anchor — meeting end — is at least as strict as any receipt-time anchor; the 90%/5-min and ≤20% numbers are unchanged.

Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).

Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing; likely indicates LLM prompt drift or taxonomy mismatch).

---

## §6 — Escalation codes

Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Granola; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream=granola`; also fired when a meeting has neither transcript nor notes to ingest | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | Catalogue **aggregate form** (escalation-codes.md, amended 2026-06-10): extracted fields with confidence ≥0.6 below the per-entity Gate A minimum (Contact 2, others 3 — §3). Payload: `entity_type`, `fields_extracted_count`, `confidence_floor` (0.6), `required_minimum`, `agent_name` | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary detected by Gate A G6's FULL-note-body scan (or the body is unreadable — fail-closed). Note-side only: the transcript-side scan is declared deviation 10 (§4 Step 3) — the note body is what leaves the firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1, mode=webhook only) | warn | operator_chat_id |
| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
| `ESC_GATE_B_MISS` | Both Gate B metrics (≥90% within-5-min-of-meeting-end SLA AND ≤20% structured-field edit-rate — §5) below target for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |

Scribe does NOT use:

- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow

---

## §7 — Voice + tone constraints

Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`. **As built (verified 2026-06-10): `context.sh` calls exactly ONE of the three loaders — `hh_load_tone_rules`. `hh_load_voice_samples` and `hh_load_recent_edits` are NOT WIRED in v1.0.**

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** (WIRED — the only voice-loader call in `context.sh`; count surfaced as `CTX_TONE_RULES_COUNT`) — surfaces rules like:
  - No identifying language about call participants beyond their professional context
  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
  - No compensation specifics in tacit notes (those go to structured fields only)
- **`hh_load_voice_samples` — NOT WIRED in v1.0.** `context.sh` does not call it (the deterministic note renderer consumes no ANN samples; `CTX_VOICE_CORPUS_ID` is hydrated by a direct `voice_corpus` lookup, not via the loader). The ANN query (top-5 chunks matching "internal call summary note" task context) lands with the LLM-rationale/classifier enhancement — same disposition as Sourcing Scout's deferred voice-sample wiring.
- **`hh_load_recent_edits` — NOT WIRED in v1.0.** `context.sh` does not call it; consultant-edit-pattern drift input lands with the Gate-B edit-rate consumer (the day-30 metrics roll-up over `recent_edit` rows — §5). Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.

**Declared gap vs master brief §8.1 Change 1:** the brief expects every `context.sh` to call all three loaders (`hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`). Scribe v1.0 satisfies one of three. This is a known, declared deviation — not a dropped requirement: the two unwired loaders are queued against their consuming features above (voice samples → classifier/LLM enhancement; recent edits → Gate-B edit-rate consumer), because wiring them today would hydrate context no v1.0 code path reads.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies + live-smoke gates (post-build state, 2026-06-10)

The W6 build slice is BUILT (fixture-proven, no live calls). Remaining ⏸
items gate LIVE OPERATION, not the build:

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
| `validate.sh` Gate A logic (G1-G8) | W6 build slice (this branch) | ✅ built |
| `context.sh` hydration (tenant_adapters v0.4 keys + env fallbacks) | W6 build slice | ✅ built |
| `cycle.sh` orchestration (10-step, 4 modes) | W6 build slice | ✅ built |
| `cleanup.sh` + 5 `bin/` helpers | W6 build slice | ✅ built |
| 3 fixtures + 3 deterministic DB-backed fixture suites | W6 build slice | ✅ built (green in build-gate.sh against the dev DB — run evidence in scribe-summary; the DB suites SKIP where `IFOS_DB_URL` is unreachable, so the green claim is dev-DB-run evidence, not environment-independent; gate hardening tracked by the orchestrator) |
| Tacit-note taxonomy v0.1 (8 categories, deterministic cues) | §3; founder prune/expand with first pilot | ✅ implemented (v0.1) |
| **Granola: IFOS-side OAuth token on disk** (`@ifos/granola` reads its own token bundle, not the Claude-Code MCP keychain) | Founder OAuth dance | ⏸ |
| **Granola: `@ifos/granola` CLI built** (`list-meetings --since` / `get-transcript --meeting` — expected surface documented at the cycle.sh call sites) | Connector build slice | ⏸ |
| ≥1 recorded meeting in the test workspace | Founder | ⏸ |
| **Bullhorn dev creds provisioned** (BULLHORN_CLIENT_ID/SECRET — EMPTY as of 2026-06-10) | Founder commercial action | ⏸ |
| **`@ifos/bullhorn` CLI bridge** (Janitor build slice, parallel; agreed contract in review-scribe.md) | Janitor branch merge | ⏸ |
| Bullhorn Sub-decision B (write scope) Accepted | Bullhorn partnerships response | ⏸ (Sub-decision A RESOLVED 2026-06-02) |
| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| Voice-classifier microservice (until then: honest `unscored`) | W4-5 polish — NOT built | ⏸ |
| LLM extraction live use (path built, opt-in `IFOS_SCRIBE_USE_LLM=1`) | Founder cost approval (§9 Q2) | ⏸ |

Pre-pivot rows removed 2026-06-10: Fathom/Fireflies commercial signup + connector + per-tenant provider routing (superseded by the Granola pivot; no longer dependencies of anything).

**Live smoke checklist (founder-gated):** provision Bullhorn sandbox creds → land the Janitor `@ifos/bullhorn` bridge → complete the Granola OAuth dance → record ≥1 meeting → run `cycle.sh --mode replay --call-id <meeting_id>` without `BH_BRIDGE_TEST_MODE`.

---

## §9 — Status + open questions

**Status:** Proposed. W6 build slice BUILT + fixture-proven (this branch); live smoke awaits the §8 ⏸ gates (Bullhorn creds + bridge merge + Granola token + recorded meeting) + Q1 LOI / pilot tenant.

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | ~~Fathom vs Fireflies — first-mover provider for v1.0?~~ **RESOLVED 2026-06-03 (Day-29 pivot): Granola is the v1.0 vendor** (founder decision; poll-sweep trigger). Fathom/Fireflies are not in v1.0. | Closed. |
| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? (v1.0 default is the zero-LLM deterministic extractor; this gates enabling `IFOS_SCRIBE_USE_LLM=1`.) | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
| Q3 | Tacit-note taxonomy v0.1 — 8 categories implemented in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
| Q4 | Webhook replay protection (SECONDARY mode only) — should Scribe reject webhook payloads >5 min old? Moot for the primary poll-sweep path (no inbound webhooks at v1.0). | Recommend yes when a push provider lands; timeout config in tools.yaml then. |
| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH (cache restore + reverse PATCH; the Gate-B recent_edit row is insert-after-settle so it never needs unwinding). Could leave the Bullhorn entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
| Q7 | What happens when a transcript references PII outside the tenant's Bullhorn data (e.g., a candidate's spouse's medical condition)? | Control point is the NOTE body (declared deviation 10, §4 Step 3): Gate A G6 full-body scan blocks the note write + fires ESC_PII_LEAKAGE_RISK; the transcript itself stays 0600 in /tmp and is purged ≤24h. Document tenant policy. |

### Gotchas (carried forward from ULTRAPLAN A3 line 527)

1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
2. **Transcript availability varies by Granola plan tier.** `get-transcript` is a PAID-plan tool; free workspaces degrade to notes-only ingest (pre-guarded via plan_tier cache — no wasted wire call). IFOS workspace confirmed Paid (founder 2026-06-03).
3. **LLM hallucination on field extraction is the failure mode** (when the opt-in LLM path is enabled). Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks + deterministic fallback on any failure.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict. The status flip below is FOUNDER-GATED — the 2026-06-10 Granola/built-state reconciliation of this document deliberately did NOT exercise it.

Status flips Proposed → Accepted when:
- Codex Round 4 Phase 2 ratifies
- Founder approves §9 Q3 (taxonomy) — Q1 already RESOLVED by the Day-29 Granola pivot (founder 2026-06-03); Q4 (webhook replay timeout) deferred with the secondary-mode push provider
- Q2 cost model approved with budget cap (gates LLM-path enablement)

Status flips Accepted → In Force when:
- ~~W6 build slice produces all 5 sibling bundle files + 3 fixtures~~ ✅ done 2026-06-10 (this branch; fixture-proven, live smoke pending)
- First production transcript processed end-to-end against migration-test tenant (needs the §8 ⏸ live gates)
- SLA + edit-rate Gate-B metrics measurable
- Codex re-ratifies post-build via `review-agent-bundle.md` skill

Until then: this document is the post-build contract record — reconciled to what was built, with live operation still gated.

*End of Scribe agent.md draft.*
