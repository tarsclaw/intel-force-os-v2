Reading prompt from stdin...
OpenAI Codex v0.132.0
--------
workdir: /Users/madsadmin/code/CortexOS
model: gpt-5.5
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR]
reasoning effort: none
reasoning summaries: none
session id: 019e5a3f-076d-7160-88aa-3db7f277ddeb
--------
user
=== TOP-LEVEL CODEX RATIFICATION SKILL ===

# Codex ratification — top-level skill

You are reviewing an Intel Force OS (IFOS) artefact for ratification.

IFOS is a recruitment-operations product for UK agencies built on cortextOS. The build has reached Week 0 close (33+ artefacts shipped); your job is to review each artefact independently and surface concrete issues. Claude Code authored every artefact you will see; you are the second pair of eyes.

**Your output for every artefact MUST start with one of two literal tokens:**

- `RATIFIED` — the artefact is accepted as-is. Optionally followed by minor advisory notes that do not block merge.
- `REJECTED` — the artefact has concrete issues. MUST be followed by a numbered list of issues. Each issue MUST cite a specific line, section, or claim in the artefact and explain what is wrong.

Do not include preamble, throat-clearing, or summary. Do not soften REJECTED to "needs minor improvement". If you find an issue, REJECT and list it. If the artefact passes, RATIFY.

---

## §1 — The five rules (master brief §1)

Every artefact is checked against the five rules in order. **A violation of any one is grounds for REJECTED.**

1. **Output before architecture** — Every agent ships with its output contract written first as a one-paragraph screenshot description. Does this artefact name what it produces before what it is built from? For non-agent artefacts (ADRs, schemas, runbooks): does the artefact name its goal/output before its mechanism?

2. **Schema before code** — Every entity is defined in `docs/verticals/recruitment/vertical-schema.yaml` (or v0.2 supplement) before any agent reads/writes it. Does this artefact assume entities/fields that are not in the schema?

3. **Reuse before build** — `_shared/` helpers (`hook-helpers.sh`, `voice-loader.sh`, `escalation-codes.md`) + `common-*.json` schemas + ESC catalogue exist; new code must reuse, not re-implement. Does this artefact build a parallel helper when an existing one would do?

4. **Quality gates before features** — Gate A (`validate.sh` hard-fails) + Gate B (`decision_log` mandatory writes) + autosend-safety-policy tier dispatch. Does this artefact bypass or weaken any gate?

5. **Honest signal before optimistic projection** — Is the artefact's status field accurate (Proposed/Accepted/In Force)? Are caveats explicit? Are limitations named, not buried?

---

## §2 — The four boundaries (master brief §3)

Boundary violations are immediate REJECT.

1. **Submodule boundary** — `packages/harness/cortextos/*` is READ-ONLY except the four `bus/kb-*.sh` files we shadow via `packages/brain/bus-overrides/`. Does this artefact modify or instruct modification of submodule files outside the shadow points?

2. **Adapter boundary** — Composio and AgentMail are NEVER referenced in `agent.md`, `tools.yaml`, vault files, or fixtures. Does this artefact mention either name in those locations?

3. **Vault/Postgres split** — Markdown content lives in vault (`/vault/<tenant>/`); structured state lives in Postgres (`decision_log`, `entities`, `entity_links`, `voice_corpus`, etc.); pgvector indexes over both. Does this artefact mix the two (e.g., narrative content into Postgres, structured state into markdown)?

4. **Brain-replacement boundary** — Only the four `bus/kb-*.sh` shadow points may interact with cortextOS's brain system. Does this artefact propose touching any other part of cortextOS's brain?

---

## §3 — Honest-signal checks specific to IFOS

These are recurring failure modes Claude Code is prone to. Look for them.

- **Citation accuracy** — section references like "§X.Y" MUST be verifiable. Open the cited file at the cited line/section; does the citation hold? Past violations: a Day-6 audit found 15 fabricated "master brief §10.4 cost target" references; §10.4 is actually the Codex exclusion list.

- **Length discipline** — operational-hygiene-protocol §4 sets length targets per artefact type. Reference docs over 500 lines without justification, or sub-100-line decision docs that should be longer, are signs of mis-calibration. Flag but don't reject on length alone.

- **No defensive additions** — operational-hygiene-protocol §3. Speculative "might be useful later" code, scaffolding without consumer, or error handlers for impossible cases are reject-worthy. Validate at system boundaries only.

- **Dates** — operational-hygiene-protocol §5 + master brief §1 Rule 5. Absolute dates (not relative — "by Friday" is wrong; "by 2026-06-03" is right). Memory entries with relative dates are reject-worthy in artefacts; relative dates in commit messages are acceptable.

---

## §4 — Output contract — exact format

```
RATIFIED
[optional advisory notes; 0-5 lines maximum]
```

OR

```
REJECTED

1. <one-line problem statement>. <2-4 line explanation citing specific lines/sections>. <one-line proposed fix>.

2. <next issue, same shape>

3. <etc.>
```

**Do NOT:**
- Use language like "this artefact is generally well-written but..." — get to the verdict
- Include a "summary" or "conclusion" section after the verdict
- Use Markdown headers (`##`) inside the output — keep it terse
- Repeat the artefact's own content back; reference it by line/section instead

**DO:**
- Quote specific text when citing a problem (`"Line 47: 'every agent...'"`)
- Number issues sequentially
- Propose a concrete fix per issue, not just identify the problem
- Use RATIFIED-with-notes for genuinely minor things that don't block merge (typos, suboptimal wording); use REJECTED for anything load-bearing

---

## §5 — How to invoke the type-specific skill

After this top-level skill loads, the founder will tell you which type-specific skill to apply:

- `review-architecture-decision.md` — for ADRs, decision docs, design docs
- `review-schema-change.md` — for `vertical-schema.yaml` edits
- `review-postgres-migration.md` — for `.sql` files under `migrations/`
- `review-agent-bundle.md` — for new agents under `agents/<vertical>/<name>/`
- `review-mcp-connector.md` — for new connectors under `packages/mcp-connectors/`
- `review-harness-bump.md` — for pinned cortextos SHA changes

The type-specific skill ADDS checks on top of this one. The five rules + four boundaries from this top-level skill always apply.

---

## §6 — When in doubt

If the artefact's purpose is unclear OR you cannot determine whether a rule applies, return REJECTED with a numbered issue asking for clarification. Do not RATIFY by default. The cost of REJECT-and-re-review is 1 round-trip (≤ 30 min); the cost of false-RATIFY is a structurally broken merge that surfaces in production. Bias toward REJECT.

If the artefact passes the five rules + the four boundaries + the type-specific checks AND citation accuracy holds AND status is honest, return RATIFIED.

---

## §7 — Your relationship to Claude Code

Claude Code authored this artefact. Claude tends to:

- Over-elaborate on architecture (long worked examples; multiple alternatives explored when one is enough)
- Soft-pedal limitations (caveats buried at the bottom; optimistic language up top)
- Miss type/build issues (you catch these more reliably)
- Over-defensive code (extra error handlers, scaffolding without consumer)

You tend to:
- Under-weight semantic/specification concerns (Claude catches these more reliably)
- Over-conservative about architecture (Claude pushes for cleaner abstractions sometimes worth taking)

**Disagreements between you and Claude are the most valuable signal.** Write them concretely. The founder will use them as decision-input. Do not hedge.

---

*End of top-level SKILL.md. Apply the relevant type-specific skill next.*

=== TYPE-SPECIFIC SKILL: schema-change ===

# Codex ratification skill — review-schema-change

Type-specific checks for: `docs/verticals/recruitment/vertical-schema.yaml` + any v0.X supplement file (`vertical-schema.vN.M-supplement.yaml`).

This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.

---

## §1 — Schema layering invariant

IFOS vertical schemas layer above Day-4 §6.3 generic Postgres primitives:

```
entities (id, tenant_slug, entity_type, entity_id, data JSONB, version, ...)
entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
decision_log (..., agent_name, phase, payload JSONB, ...)
```

The vertical schema specifies (a) which `entity_type` slugs are valid, (b) what JSON shape `entities.data` takes per entity_type, (c) which `link_type` slugs are valid. **Schemas DO NOT create new Postgres tables in v0.X** — supplements that propose new tables (e.g., `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`) MUST be paired with explicit `docs/verticals/recruitment/migrations/vN.M-to-vN.M+1.sql` companion files OR explicitly mark the new tables as "auxiliary v0.X tables, not entities".

REJECT if a schema declares a new entity_type without naming whether it lives in `entities.data` JSONB OR in a new auxiliary table; the layering should be explicit.

---

## §2 — Per-entity required fields

Every entity_type definition MUST include:

- `description` — 1-2 sentence canonical definition in IFOS vocabulary
- `bullhorn_source` — exactly one of:
  - `Bullhorn.<Entity>` (with optional `where` clause)
  - `none (IFOS-derived from <source>)`
  - `none (IFOS-internal; not synced to ATS)`
- `v1_0_agent_access` — list of agents from master brief §8.2 with R / W / R+W disposition, OR explicit "none (v1.1+ exercise)"
- `canonical_fields` — at least 5 fields with type + required + source (Bullhorn path OR IFOS-derived)

REJECT if any of these are missing.

For each field within `canonical_fields`:

- `type` — one of `string | integer | number | boolean | array | object | timestamp | date`
- `required` — boolean
- `source` — `Bullhorn.<Entity>.<field>` OR `IFOS-derived` (with note on how)
- `notes` — optional but recommended for non-obvious fields

REJECT if any field lacks `type`, `required`, or `source`.

---

## §3 — JSON Schema compatibility (for entities.data shape)

Field types declared in the YAML must round-trip to valid JSON Schema. Cross-check against `packages/agents-runtime/_shared/common-*.json`:

- If a field's `type: array`, the YAML must imply item type (via `notes: Items: <type>`)
- If a field's `type: object`, the YAML must imply nested shape OR be explicitly free-form
- If a field references a `voice_classifier_score` or similar [0.0, 1.0] bounded value, confirm the migration SQL adds a CHECK constraint OR a trigger

REJECT if YAML field types cannot be expressed as JSON Schema for entities.data.

---

## §4 — Relationship definitions

`relationships:` (or `additional_relationships:` in supplements) defines `entity_links.link_type` values. Each MUST include:

- `source` — entity_type
- `target` — entity_type
- `cardinality` — `1:1 | 1:N | N:1 | M:N`
- `description` — 1-2 sentences
- `v1_0_exercise` — which agents use this link OR explicit "none (v1.1+)"

REJECT if cardinality is missing or contradicts the agent_access_matrix (e.g., cardinality says `1:N` from candidate → placement but matrix has both as R+W to placement, implying M:N).

Cross-referenced entities MUST exist in this schema OR a previous version (v0.1 for v0.2 supplement). REJECT if relationship references an undefined entity_type.

---

## §5 — Agent access matrix consistency

`agent_access_matrix:` must list every v1.0 agent (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) + state R / W / R+W / none for every entity_type.

Cross-check:

- For each entity, the `v1_0_agent_access` field in §1 MUST match the matrix
- For each agent in the matrix, every entity from `entities:` MUST be present (no silent omissions)
- `Diagnostic` must have `none` or `R` for all entities — Diagnostic doesn't write to Bullhorn per `sequencing-target.md` §2.1
- `Janitor` must have R+W on `candidate` per `bullhorn-integration-path.md` §4.1 A2
- `Scribe` must have R+W on `candidate` + `placement` per §4.1 A3
- `Concierge` must have R+W on `candidate` + `placement` per §4.1 A6

REJECT if matrix omits an agent, omits an entity, or contradicts the agent's specified bullhorn-integration role.

---

## §6 — Bullhorn mapping consistency

`bullhorn_mapping:` must align with `bullhorn-integration-path.md` §3 endpoint surface:

- Every entity with `bullhorn_source: Bullhorn.X` must have a mapping row in `bullhorn_mapping:`
- Field mappings (canonical IFOS field → Bullhorn field) must NOT contradict Bullhorn's actual API
- v1.0 endpoint surface is 4 entities (Candidate, ClientCorporation, JobOrder, Note + Placement extension). v0.X schemas with more `Bullhorn.X` sources than these need explicit deferral notes for v1.1+ entities.

REJECT if a `Bullhorn.X` source is named but no corresponding mapping row exists.

---

## §7 — Migration SQL pairing (for supplements that add entities)

Supplements (`vertical-schema.vN.M-supplement.yaml`) that add new entity_types MUST be paired with:

- `docs/verticals/recruitment/migrations/vN.M-to-vN.M+1.sql` (forward migration)
- `docs/verticals/recruitment/migrations/vN.M+1-to-vN.M.sql` (rollback)

The supplement MUST cite both file paths in a `migration:` section. REJECT if a supplement adds tables without naming the migration files.

If migration files exist, cross-check (don't deeply review — that's `review-postgres-migration` skill's job):

- Every new entity_type in the supplement → exactly one `CREATE TABLE` in the forward migration
- Every new field added to existing entities → either a JSONB key (preferred per Day-4 §6.3) OR a column ADD on `entities` (less common)
- The rollback SQL exists + is non-trivial (not just `-- TODO`)

REJECT if migration files are referenced but missing OR mismatch the supplement's declared additions.

---

## §8 — Open-question discipline

`open_questions:` (or `open_questions_vN.M_additions:` in supplements) entries MUST:

- Be numbered (Q1, Q2, ...) with no gaps
- State the question concretely (not "what should we do about X?" — instead "should X be A or B?")
- Name options (A / B / C with one-line descriptions)
- Have a `vN.M_default` (the default the schema currently encodes)
- Have a `trigger_for_revisit` (when do we revisit — named event/date, not "later")

REJECT if any question lacks options OR a default OR a trigger.

Sample-check: if the schema has 10+ open questions but most defaults are "TBD" or "founder decides during pilot", that's signal of insufficient design depth. REJECT and demand defaults.

---

## §9 — Voice corpus + voice score consistency (for v0.2 + later)

If the supplement defines voice_corpus / tone_rule / recent_edit (Phase 4 patterns):

- `voice_corpus` MUST have a `version` field (semver) + `is_active` boolean + at-most-one-active enforced (partial unique index in migration SQL)
- `voice_corpus` chunking_strategy enum must be exhaustive — listing only "paragraph" without "sentence-window-N" or "semantic-segment-vN" reserved is acceptable for v0.X but should name the reserved values
- `tone_rule.severity` must be `info | warn | block`; other values REJECT
- `tone_rule.applies_to_agents` — empty array = "all agents"; non-empty array = filter list. If the field allows null with different semantics, REJECT (ambiguity)
- `recent_edit` MUST be append-only in migration GRANTs (SELECT + INSERT only on `ifos_app` role)
- `recent_edit.resolution` must be exhaustive: `approved_verbatim | approved_after_edit | rejected | deferred`
- `voice_classifier_score` fields on entities must be `[0.0, 1.0]` bounded — REJECT if no CHECK constraint or trigger is named in migration

---

## §10 — Common false-RATIFY traps to watch for

- **Missing required field on entity** — `candidate.bullhorn_id` MUST be `required: true` (it's the round-trip primary key). If marked `false`, REJECT.

- **Inconsistent required + nullable** — `required: true` with a `notes: May be nullable for...` is contradictory. REJECT.

- **Source mismatch** — `source: Bullhorn.Candidate.email` on a field marked `IFOS-derived` is incoherent. REJECT.

- **PII flagging missing** — fields holding email/phone/name should have a `notes:` line referencing `autosend-safety-policy §7 payload_preview PII rules`. Not blocking on absence but flag in RATIFIED-with-notes.

- **Schema-validates-itself-fail** — try to mentally construct an `entities.data` JSON for the candidate entity using the schema's required fields. If you can't construct a valid example, REJECT.

---

## §11 — Quick checklist

- [ ] Status field present + matches content
- [ ] Layering invariant stated (entities/entity_links/decision_log primitives + JSONB shape OR new auxiliary tables)
- [ ] Every entity has description + bullhorn_source + v1_0_agent_access + canonical_fields (≥5 fields)
- [ ] Every field has type + required + source
- [ ] All relationships have source + target + cardinality
- [ ] Agent access matrix lists all 6 v1.0 agents × all entities
- [ ] Bullhorn mapping matches `bullhorn-integration-path.md` §3 surface
- [ ] Migration SQL files exist + are referenced (if supplement adds entities)
- [ ] Open questions all have options + default + trigger
- [ ] (For v0.2+) voice corpus + tone_rule + recent_edit invariants checked
- [ ] No PII fields without privacy notes (advisory only)

If all clear: RATIFIED.
If any fail: REJECTED with numbered issues citing specifics.

=== ARTEFACT UNDER REVIEW ===

Path: docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml

--- BEGIN ARTEFACT ---

# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
# ============================================================================
# Status: Proposed (Codex Day-19 ratification queue addendum)
# Date:   2026-05-24 (Day 19; post-Round-8 Cat-β unblock)
# Author: Founder (Maddox) + Claude Code
# Predecessor: docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
#
# Closes Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor + Concierge
# schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
# Phase 4 Cat-β section.
#
# Companion migrations: migrations/v0.2-to-v0.3.sql + migrations/v0.3-to-v0.2.sql
#   Both files drafted at commit alongside this supplement.
#
# Field types: per `review-schema-change` skill §2 allowed types only —
# string | integer | number | boolean | array | object | timestamp | date.
# Enums expressed as `type: string` + `enum: [...]`. Lists as `type: array`
# with `items.type`. SQL-level types (NUMERIC(15,2), TIMESTAMPTZ etc.) appear
# only in the companion migration SQL, not here.
#
# Schema layering: entities.data is JSONB per Day-4 §6.3 generic primitive.
# v0.3 entity-field additions are JSONB key shapes validated via the
# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
# tables — they're already JSONB-shaped.
# ============================================================================

vertical: recruitment
version: v0.3
supplements: v0.2
status: Proposed
date: 2026-05-24
author: founder (Maddox) + Claude Code; bilateral Cat-β unblock
codex_ratification_queue_position: 44

# ============================================================================
# §1 — New entity.data JSONB key shapes (14 across 5 entities)
# ============================================================================
#
# All additions land as JSONB keys on the existing entities.data column
# (Day-4 §6.3 generic primitive layer). Validation lives in
# validate_entities_data_v0_3() trigger function (migration §4).

entity_field_additions:

  candidate:
    v0_3_new_keys:
      employment_type:
        type: string
        enum: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
        required: false
        notes: |
          Candidate's preferred engagement model (distinct from role type).
          IR35 distinction matters for UK contractors. Extracted by Scribe
          from call context.
        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
        v1_0_agent_access:
          - Scribe: W
          - Sourcing Scout: R

      key_skills:
        type: array
        items:
          type: string
        max_items: 20
        required: false
        notes: |
          Aggregated skill tags from CV + transcripts. Free-text strings;
          W4 polish may add controlled-vocabulary clustering. Max 20 items
          per candidate enforced by validate_entities_data_v0_3.
        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
        v1_0_agent_access:
          - Scribe: W
          - Sourcing Scout: R+W

      linkedin_url:
        type: string
        pattern: '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
        required: false
        notes: |
          LinkedIn profile URL. Pattern enforced by trigger. Set by Sourcing
          Scout from match; Janitor uses for dedup (stronger match signal
          than name+email); Concierge reads for outreach context (NOT for
          outbound — outreach via candidate.email or candidate.phone only).
        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
        v1_0_agent_access:
          - Sourcing Scout: R+W
          - Janitor: R   # W only via dedup-merge action
          - Concierge: R

  contact:
    v0_3_new_keys:
      preferred_channel:
        type: string
        enum: [email, phone, sms, teams, slack, in_person, unknown]
        default: unknown
        required: false
        notes: |
          Contact's stated preference; extracted by Scribe from call context.
          Concierge reads to route outbound lifecycle comms.
        source: IFOS-derived (Scribe extraction)
        v1_0_agent_access:
          - Scribe: R+W
          - Concierge: R

      next_action_target_date:
        type: date
        required: false
        notes: |
          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
          is in transcript. Concierge respects this when scheduling lifecycle
          nurture.
        source: IFOS-derived (Scribe extraction)
        v1_0_agent_access:
          - Scribe: R+W
          - Concierge: R

  brief:
    v0_3_new_keys:
      must_haves:
        type: array
        items:
          type: string
        max_items: 15
        required: false
        notes: |
          Hard requirements; Sourcing Scout filters candidates against this
          list. Free-text strings; max 15 items enforced by trigger.
        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
        v1_0_agent_access:
          - Scribe: R+W
          - Sourcing Scout: R

      nice_to_haves:
        type: array
        items:
          type: string
        required: false
        notes: |
          Soft preferences; Sourcing Scout uses for ranking, not hard filter.
        source: IFOS-derived (Scribe extracts)
        v1_0_agent_access:
          - Scribe: R+W
          - Sourcing Scout: R

      deal_breakers:
        type: array
        items:
          type: string
        required: false
        notes: |
          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
          item.
        source: IFOS-derived (Scribe extracts)
        v1_0_agent_access:
          - Scribe: R+W
          - Sourcing Scout: R

  placement:
    v0_3_new_keys:
      placement_status:
        type: string
        enum: [pending_start, active, completed, terminated_early, on_hold, cancelled]
        default: pending_start
        required: false
        notes: |
          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
          confirming candidate started. Janitor flags ambiguous via
          ESC_LIFECYCLE_STATE_UNKNOWN.
        source: IFOS-derived (Scribe + Janitor)
        v1_0_agent_access:
          - Scribe: R+W
          - Janitor: R+W
          - Concierge: R

      week_1_status_note:
        type: string
        max_length: 500
        required: false
        notes: |
          Free-text narrative from 7d check-in call. Stored verbatim;
          voice-classifier review at write time per Scribe §7.
        source: IFOS-derived (Scribe extracts from 7d check-in call)
        v1_0_agent_access:
          - Scribe: R+W
          - Concierge: R

      satisfaction_signal:
        type: string
        enum: [positive, neutral, negative, unclear]
        default: unclear
        required: false
        notes: |
          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
          Concierge reads to adjust nurture tone.
        source: IFOS-derived (Scribe LLM extraction)
        v1_0_agent_access:
          - Scribe: R+W
          - Concierge: R

  opportunity:
    v0_3_new_keys:
      headcount_growth_signal_text:
        type: string
        max_length: 280
        required: false
        notes: |
          Free-text capture of growth-signal phrases from prospecting calls
          ("we're hiring 5 engineers this quarter"). Sourcing Scout reads
          to ICP-fit-score opportunities.
        source: IFOS-derived (Scribe extraction)
        v1_0_agent_access:
          - Scribe: R+W
          - Sourcing Scout: R

      hiring_velocity_band:
        type: string
        enum: [slow, moderate, fast, urgent, unknown]
        default: unknown
        required: false
        notes: |
          Scribe LLM inference from prospecting-call urgency cues. Drives
          ranking in Sourcing Scout's brief-to-candidate pipeline.
        source: IFOS-derived (Scribe LLM classification)
        v1_0_agent_access:
          - Scribe: R+W
          - Sourcing Scout: R

      decision_window_text:
        type: string
        max_length: 280
        required: false
        notes: |
          Free-text capture of decision-timing phrases. Concierge reads to
          time outbound comms.
        source: IFOS-derived (Scribe extraction)
        v1_0_agent_access:
          - Scribe: R+W
          - Concierge: R

# ============================================================================
# §2 — Complete v0.3 agent access matrix
# ============================================================================
#
# Per review-schema-change skill §5: full matrix across all v1.0 agents
# and all v0.1 + v0.2 entities. v0.3 is a CUMULATIVE matrix that includes
# v0.1 + v0.2 + v0.3 dispositions. Where this matrix differs from
# vertical-schema.yaml v0.1 §3, the cell is an EXPLICIT v0.3 amendment
# with a marker comment in-line. Full list of v0.3 amendments:
#
# Cells changed from v0.1 baseline:
#   - Diagnostic client: none → R (reads Companies House data via cached
#     client entity; sales-tool source-of-truth context — v0.3 amendment)
#   - Diagnostic contact: none → R (reads §11 decision-maker map context)
#   - Diagnostic opportunity: none → R (reads prospect-firm opportunity if exists)
#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
#     pattern as candidate/contractor — v0.3 amendment)
#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
#     v0.3 amendment)
#   - Janitor timesheet: none → R (reads for placement-state inference)
#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
#     R-only for Scribe)
#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
#   - Scribe timesheet: none → R (reads for placement-context resolution
#     on check-in calls)
#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
#     — v0.3 amendment)
#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
#   - Cash Conductor timesheet: none → R (reads to verify billable hours
#     match invoiced amounts)
#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
#     from multi-source aggregation — v0.3 amendment)
#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
#     activity-log links per concierge §4 Step 13-14 — v0.3 amendment)
#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
#   - Concierge opportunity: none → R (reads for outbound lifecycle-event context)
#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
#     concierge §4 Step 14 — v0.3 amendment)
#   - Concierge timesheet: none → R (reads to verify placement-progress for
#     7d/30d/90d nurture)
#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
#     extended)
#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
#     — v0.2 extended)
#
# All other access levels carry forward unchanged from v0.1 + v0.2.

agent_access_matrix:

  # Disposition tokens: R | W | R+W | none
  #
  # ENTITY-LEVEL vs FIELD-LEVEL ACCESS:
  # The matrix below is ENTITY-LEVEL — declares the maximum disposition an
  # agent may have on any field of that entity. Per-field access (in §1
  # entity_field_additions[*].v1_0_agent_access) NARROWS the entity-level
  # disposition. Example: Scribe.candidate: R+W at entity level; per-field
  # candidate.employment_type grants Scribe: W (because Scribe doesn't read
  # employment_type, just writes it). This is intentional — the entity-level
  # token is the ceiling; field-level may be narrower but never broader.
  #
  # Validation: the validate_entities_data_v0_3 trigger enforces field-level
  # writes per the per-field constraints; entity-level RLS enforces tenant
  # isolation. There is no separate field-level permission enforcement layer
  # in v0.3 (would need column-level RLS or app-level mediation; W4+ work).

  diagnostic:
    candidate: R           # reads for outreach context (§11 decision-maker map)
    contractor: none       # not in scope at v1.0
    client: R              # reads via Companies House lookup (entity-shape if cached)
    contact: R             # reads for §11 decision-maker map
    brief: none            # diagnostic is sales-tool not brief-driven
    opportunity: R         # may read prospect-firm opportunity if exists
    placement: none
    timesheet: none
    voice_corpus: R
    voice_corpus_chunks: R
    tone_rule: R
    recent_edit: none

  janitor:
    candidate: R+W         # dedup + field-backfill writes
    contractor: R+W        # dedup + field-backfill writes
    client: R+W            # Companies House enrichment writes
    contact: R+W           # dedup + field-backfill writes
    brief: R               # context for related candidate cleanup
    opportunity: R
    placement: R+W         # lifecycle-state cleanup
    timesheet: R           # reads for placement-state inference
    voice_corpus: R        # tacit-note narrative voice grounding
    voice_corpus_chunks: R
    tone_rule: R           # v0.3 NEW (was no access)
    recent_edit: R         # v0.3 NEW (was Concierge/canary/LoRA only); for tacit-note harvest

  scribe:
    candidate: R+W         # call-summary field extraction
    contractor: R+W        # call-summary field extraction
    client: R
    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
    placement: R+W         # check-in field extraction
    timesheet: R           # reads for placement-context resolution on check-in calls
    voice_corpus: R        # tacit-note voice grounding
    voice_corpus_chunks: R
    tone_rule: R           # v0.2
    recent_edit: W         # writes its own edits for retraining

  cash_conductor:
    candidate: none        # no Bullhorn dependency
    contractor: none
    client: R              # reads client billing details
    contact: R             # reads for invoice addressee resolution
    brief: none
    opportunity: none
    placement: R           # reads for client linkage on invoice
    timesheet: R           # reads to verify billable hours match invoiced amounts
    voice_corpus: R        # chase-email voice grounding
    voice_corpus_chunks: R
    tone_rule: R           # v0.2
    recent_edit: W         # writes its own chase-draft edits for retraining
    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)

  sourcing_scout:
    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
    # writes its proposed-candidate rows + reads opportunity context. These
    # are entity-level access overrides codified here.
    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
    client: R
    contact: R
    brief: R               # reads to filter candidates
    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
    placement: none
    timesheet: none
    voice_corpus: R        # rationale-narrative voice grounding
    voice_corpus_chunks: R
    tone_rule: R
    recent_edit: W         # writes rationale-narrative edits for retraining

  concierge:
    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
    contractor: R+W        # writes lifecycle states for contractor placements too
    client: R
    contact: R             # reads for outbound recipient resolution
    brief: R
    opportunity: R
    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
    voice_corpus: R        # lifecycle-comms voice grounding
    voice_corpus_chunks: R
    tone_rule: R           # v0.2
    recent_edit: R         # v0.2

# ============================================================================
# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
# ============================================================================

auxiliary_tables:

  cash_conductor_transactions:
    rationale: |
      Open Banking transactions are high-volume + time-series + don't model
      as entity.data JSONB. v0.3 introduces a first-class table with
      RLS isolation and indexes for date + match-status. Per Cash Conductor
      §4 Step 3 + ADR-002 vault/Postgres split.
    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
    columns:
      id: {type: integer, required: true, notes: BIGSERIAL primary key in SQL}
      tenant_slug: {type: string, required: true, notes: RLS isolation key per Day-4 §6.3}
      transaction_id: {type: string, required: true, notes: Provider-supplied (TrueLayer / Plaid)}
      posted_at: {type: timestamp, required: true}
      amount: {type: number, required: true, notes: NUMERIC(15,2) GBP; negative for outgoing}
      currency: {type: string, required: true, default: GBP}
      payee_name_raw: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
      description: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct]}
      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched}
      matched_invoice_id: {type: string, required: false, notes: FK to cash_conductor_invoices.invoice_id when match_status='matched'}
      match_confidence: {type: number, required: false, notes: "range [0.00, 1.00]"}
      match_dimensions: {type: array, items: {type: string}, required: false}
      ingested_at: {type: timestamp, required: true, default: now()}
      raw_payload: {type: object, required: false, pii: true, notes: Full Open Banking response; pseudonymized at year 7}
    indexes:
      - "(tenant_slug, posted_at DESC)"
      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
    retention: |
      INTENT (W4-polish enforcement required): 7-year retention with
      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
      description, raw_payload). Aligned with Q4 v0_3_default. The
      v0.2-to-v0.3 migration creates the table + indexes only; the
      pseudonymization + purge implementation is a W4-polish slice (pg_cron
      job or external scheduled job; not yet authored).
    enforcement_gate: |
      Production use of this table GATED until pseudonymization + purge
      implementation lands as W4 polish. Per-tenant DPA addendum signed
      by founder + tenant before go-live; migration-test tenant exempt.

  cash_conductor_invoices:
    rationale: |
      Open invoice register cached from accounting provider. Same auxiliary-
      table pattern as transactions. Per Cash Conductor §4 Step 4.
    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
    columns:
      id: {type: integer, required: true}
      tenant_slug: {type: string, required: true}
      invoice_id: {type: string, required: true}
      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage]}
      invoice_number: {type: string, required: false}
      issued_at: {type: timestamp, required: true}
      due_at: {type: timestamp, required: true}
      amount_total: {type: number, required: true, notes: NUMERIC(15,2) GBP}
      amount_paid: {type: number, required: true, default: 0}
      currency: {type: string, required: true, default: GBP}
      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open}
      client_contact_id: {type: string, required: false, notes: Links to Bullhorn placement.client_contact_id}
      client_billing_email: {type: string, required: false, pii: true}
      last_chase_position: {type: integer, required: true, default: 0, notes: 0-4 per Cash Conductor §3.2}
      last_chase_sent_at: {type: timestamp, required: false}
      ingested_at: {type: timestamp, required: true, default: now()}
      raw_payload: {type: object, required: false, pii: true}
    indexes:
      - "(tenant_slug, due_at)"
      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
    retention: |
      INTENT (W4-polish enforcement required): 7-year retention with
      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
      pseudonymization + purge implementation is a W4-polish slice
      (pg_cron job or external scheduled job; not yet authored).
    enforcement_gate: |
      Until pseudonymization + 90d-cancelled-purge implementation lands as
      W4 polish, production use of cash_conductor_invoices is GATED by
      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
      per §3 cash_conductor_transactions.retention). Migration-test tenant
      data is exempt; pilot tenants require the DPA addendum signed before
      go-live.

auxiliary_table_access_matrix:
  cash_conductor_transactions:
    diagnostic: none
    janitor: none
    scribe: none
    cash_conductor: R+W
    sourcing_scout: none
    concierge: none
  cash_conductor_invoices:
    diagnostic: none
    janitor: none
    scribe: none
    cash_conductor: R+W
    sourcing_scout: none
    concierge: none

# ============================================================================
# §4 — tenant_adapters.config new keys (4 keys)
# ============================================================================
#
# tenant_adapters.config is JSONB; validation via
# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
# on unknown keys per Rule 2.

tenant_adapters_config_additions:

  cash_conductor_last_run:
    type: timestamp
    required: false
    set_by: cash_conductor
    read_by: [cash_conductor]
    notes: |
      Cash Conductor cron sweep updates at session-close. Next run queries
      transactions/invoices since this timestamp.

  concierge_last_poll:
    type: timestamp
    required: false
    set_by: concierge
    read_by: [concierge]
    notes: |
      Concierge polling cron updates at end of each cycle. Next poll queries
      Bullhorn for state transitions since this timestamp.

  concierge_send_window:
    type: object
    required: false
    default:
      timezone: Europe/London
      weekday_start: '09:00'
      weekday_end: '17:00'
      weekend_send_enabled: false
    set_by: [tenant-admin]
    read_by: [concierge]
    object_shape:
      timezone:
        type: string
        notes: IANA timezone identifier
      weekday_start:
        type: string
        notes: HH:MM 24-hour format
      weekday_end:
        type: string
        notes: HH:MM 24-hour format
      weekend_send_enabled:
        type: boolean
    notes: |
      Per-tenant outbound sending hours. Concierge respects when scheduling
      orange-tier sends.

  diagnostic_per_claim_sample_rate:
    type: integer
    range: [1, 100]
    default: 10
    required: false
    set_by: [tenant-admin]
    read_by: [diagnostic]
    notes: |
      Per ADR-006 Tier 2 (post-launch quality metric). Sample 1-in-N
      Diagnostic reports for per-claim citation validation. Activates at
      W4 polish; documented intent only until then.

# ============================================================================
# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
# ============================================================================

decision_log_payload_extension:
  per_claim_confidence_distribution:
    type: object
    required: false
    written_when: |
      Tier 2 per-claim validation runs (sample-rate-gated by
      tenant_adapters.config.diagnostic_per_claim_sample_rate).
    object_shape:
      total_claims:
        type: integer
      claims_with_confidence_above_0_6:
        type: integer
      claims_with_confidence_below_0_6:
        type: integer
      mean_confidence:
        type: number
      sampled_at:
        type: timestamp
      sample_rate_applied:
        type: integer
    notes: |
      Aggregate metric, not per-claim detail. Per-claim raw data goes to a
      separate v1.1 quality-metrics table if commercial value justifies.
    validation:
      mean_confidence: "[0.0, 1.0] range — enforced at write-time by W4-polish decision_log writer extension (not by Postgres trigger; payload is JSONB)"
      claims_with_confidence_above_0_6: ">= 0 (non-negative integer)"
      claims_with_confidence_below_0_6: ">= 0 (non-negative integer)"
      total_claims: "= above + below (consistency invariant)"
      sample_rate_applied: "[1, 100] (matches tenant_adapters.config.diagnostic_per_claim_sample_rate range)"
    enforcement_gate: |
      v0.3 declares the shape. Range + invariant validation lands in the
      W4-polish decision_log writer extension that ships with Tier 2
      sampling activation. Until then, no Tier 2 writes occur, so the
      validation gap is non-blocking.

# ============================================================================
# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
# ============================================================================

migration_sequence:
  forward: migrations/v0.2-to-v0.3.sql
  rollback: migrations/v0.3-to-v0.2.sql

  pre_conditions:
    - v0.2 migration applied (voice_corpus + tone_rule + recent_edit tables exist)
    - validate_voice_scores trigger active on entities table
    - RLS + ifos_app grants from Day-4 §6.3 in place
    - migration-test tenant row exists in tenants table

  steps:
    1: |
      Verify v0.2 prerequisites (DO block in migration §1).
    2: |
      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
      ifos_app grants + 2 indexes (migration §2).
    3: |
      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
      (migration §3).
    4: |
      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
      score checks. Adds JSONB key validations for 14 v0.3 fields across
      candidate / contact / brief / placement / opportunity entity_types.
      Re-attaches the trigger to entities table (migration §4).
      NOTE: entities table itself is unchanged; entity.data is JSONB and
      v0.3 keys are validated by the trigger, not via ALTER TABLE.
    5: |
      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
      hard-fails on unknown config keys (Rule 2); type-validates the 4 new
      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
    6: |
      Smoke verification DO block confirms both cash_conductor_*
      tables exist (migration §6).
    7: |
      COMMIT; or ROLLBACK on any error.

  post_migration_steps:
    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
       to cite v0.3 supplement instead of "v0.3-supplement-pending"
    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
       Cat-β findings closed

# ============================================================================
# §7 — Codex ratification path
# ============================================================================

codex_ratification:
  skill: review-schema-change
  expected_round_trips: 1-2 (mechanical fixes only)
  manifest_queue_position: 44 (after v0.2 supplement at 29)

# ============================================================================
# §8 — Open questions (structured per review-schema-change §8)
# ============================================================================

open_questions:

  Q1_employment_type_enum_completeness:
    question: Are 6 employment_type enum values sufficient for UK recruitment?
    options:
      A: |
        Keep 6 values as in §1.candidate.employment_type — perm, contract,
        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
      B: |
        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
      C: |
        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
        (array of allowed strings); validate at write time against tenant's list.
    v0_3_default: A
    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
      outside A, escalate to B or C.

  Q2_key_skills_max_length:
    question: Cap at 20 items per candidate adequate?
    options:
      A: Keep cap at 20 (validator hard-fails over).
      B: Increase to 50 (handles senior technical candidates with deep stacks).
      C: Remove cap entirely (rely on application-layer pruning).
    v0_3_default: A
    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
      of candidates hit the 20-item cap, escalate to B.

  Q3_placement_status_enum_lifecycle:
    question: 6-state placement_status enum maps to Bullhorn's native state machine?
    options:
      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
      C: Add a mapping table (auxiliary) — placement_status_mapping with
         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
    v0_3_default: A
    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
      escalate to B or C if 1:1 mapping breaks.

  Q4_cash_conductor_transactions_retention:
    question: Bank-feed transactions contain PII (payee_name_raw + description).
      What's the production retention policy?
    options:
      A: 7-year retention with automated pseudonymization at year 7 (hash
         payee_name_raw + description; preserve amount + dates for audit).
      B: Indefinite with pseudonymization at year 7 (same as A but matched
         rows retained beyond 7 years for cross-period reconciliation).
      C: Per-tenant retention override in tenant_adapters.config.
    v0_3_default: A
    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
      tenant requires shorter retention, escalate to C with tenant-specific
      override. Pseudonymization implementation lands in W4-polish slice.
    production_use_gating: |
      Until pseudonymization implementation lands, production use of
      cash_conductor_transactions table is GATED by an explicit per-tenant
      DPA addendum signed by founder + tenant. Migration-test tenant data
      is not subject to this gate.

  Q5_unknown_config_keys_handling:
    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
    options:
      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
    v0_3_default: A
    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
      for forward-compat, escalate to B or C with explicit ADR.

# ============================================================================
# §9 — Why v0.3 is the right unblock
# ============================================================================

rationale: |
  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys + 1
  payload extension, closing those findings.

  After v0.3 ratifies + migration applies:
    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
      the v0.3-added fields (employment_type, key_skills, preferred_channel,
      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
      placement_status, week_1_status_note, satisfaction_signal,
      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
      are now schema-backed. The Scribe §3 narrative still references SOME
      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
      seniority — not yet in schema; brief.start_date should be
      start_date_target; opportunity.sector — not yet in schema). These
      residual gaps are tracked in W4-polish-schema-extension backlog;
      they do not block v0.3 ratification but do require a Scribe agent.md
      consistency-pass before Scribe ratifies.
    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
    - Concierge tenant_adapters.config field refs valid
    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)

  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
  ~3-5 residual mechanical findings per agent (down from current 4-6) —
  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
  not schema gaps.

# ============================================================================

end_of_supplement: true

--- END ARTEFACT ---

=== YOUR TASK ===

Apply the top-level SKILL.md plus the type-specific skill above to the artefact.

Return EXACTLY ONE of:

  RATIFIED
  [optional 0-5 lines of advisory notes]

OR

  REJECTED

  1. <one-line problem statement>. <2-4 line explanation citing specific lines/sections>. <one-line proposed fix>.

  2. <next issue, same shape>

  ...

Do not include preamble, throat-clearing, or summary. Begin your response with the literal word RATIFIED or REJECTED.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,520p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	-- ============================================================================
     2	-- IFOS recruitment vertical schema — v0.3 → v0.2 rollback
     3	-- ============================================================================
     4	-- Companion rollback for: v0.2-to-v0.3.sql
     5	-- Authored:               2026-05-24 (Day 19)
     6	-- Status:                 DRAFTED; only execute if v0.3 changes break production.
     7	--
     8	-- Rolls back v0.3 additions:
     9	--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
    10	--   - Restores v0.2 entities.data validation trigger (loses v0.3 field validation)
    11	--   - Restores v0.2 tenant_adapters.config validation trigger
    12	--
    13	-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
    14	-- rows are DELETED. Operator must export to JSON via /vault/<tenant>/exports/
    15	-- BEFORE running this rollback if any rows present.
    16	-- ============================================================================
    17	
    18	BEGIN;
    19	
    20	-- ----------------------------------------------------------------------------
    21	-- §1 — Operator confirmation prompt
    22	-- ----------------------------------------------------------------------------
    23	
    24	DO $$
    25	DECLARE
    26	  cct_rows INT;
    27	  cci_rows INT;
    28	BEGIN
    29	  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
    30	  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
    31	  IF cct_rows > 0 OR cci_rows > 0 THEN
    32	    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
    33	    RAISE NOTICE 'EXPORT TO JSON BEFORE PROCEEDING (per migration §1 warning)';
    34	    -- Note: not raising EXCEPTION; operator runs with explicit acknowledgment
    35	  END IF;
    36	END $$;
    37	
    38	-- ----------------------------------------------------------------------------
    39	-- §2 — Drop v0.3 auxiliary tables
    40	-- ----------------------------------------------------------------------------
    41	
    42	DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
    43	DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
    44	
    45	-- ----------------------------------------------------------------------------
    46	-- §3 — Restore v0.2 validation trigger for entities.data
    47	-- ----------------------------------------------------------------------------
    48	
    49	DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
    50	DROP FUNCTION IF EXISTS validate_entities_data_v0_3();
    51	
    52	-- v0.2 validate_voice_scores function is preserved in the schema (we replaced
    53	-- the trigger binding but didn't drop the v0.2 function). Re-attach it.
    54	
    55	DO $$
    56	BEGIN
    57	  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validate_voice_score_fields') THEN
    58	    RAISE EXCEPTION 'v0.2 validate_voice_scores function missing — rollback cannot complete; re-apply v0.1-to-v0.2.sql §4 to restore';
    59	  END IF;
    60	END $$;
    61	
    62	CREATE TRIGGER validate_voice_scores
    63	  BEFORE INSERT OR UPDATE ON entities
    64	  FOR EACH ROW
    65	  EXECUTE FUNCTION validate_voice_score_fields();
    66	
    67	-- ----------------------------------------------------------------------------
    68	-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
    69	-- ----------------------------------------------------------------------------
    70	
    71	DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
    72	DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
    73	
    74	-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
    75	-- function; the keys were unvalidated at v0.2. Restoring v0.2 state means no
    76	-- tenant_adapters config validation trigger.
    77	
    78	-- ----------------------------------------------------------------------------
    79	-- §5 — Smoke verification (read-only)
    80	-- ----------------------------------------------------------------------------
    81	
    82	DO $$
    83	DECLARE
    84	  cct_exists INT;
    85	  cci_exists INT;
    86	BEGIN
    87	  SELECT count(*) INTO cct_exists FROM information_schema.tables
    88	    WHERE table_name = 'cash_conductor_transactions';
    89	  SELECT count(*) INTO cci_exists FROM information_schema.tables
    90	    WHERE table_name = 'cash_conductor_invoices';
    91	  IF cct_exists > 0 OR cci_exists > 0 THEN
    92	    RAISE EXCEPTION 'v0.3 tables still present after rollback';
    93	  END IF;
    94	  RAISE NOTICE 'v0.3 → v0.2 rollback verified: cash_conductor tables dropped';
    95	END $$;
    96	
    97	COMMIT;
    98	
    99	-- ============================================================================
   100	-- End of v0.3 → v0.2 rollback
   101	-- ============================================================================

 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
     2	# ============================================================================
     3	# Status: Proposed (Codex Day-19 ratification queue addendum)
     4	# Date:   2026-05-24 (Day 19; post-Round-8 Cat-β unblock)
     5	# Author: Founder (Maddox) + Claude Code
     6	# Predecessor: docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
     7	#
     8	# Closes Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor + Concierge
     9	# schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
    10	# Phase 4 Cat-β section.
    11	#
    12	# Companion migrations: migrations/v0.2-to-v0.3.sql + migrations/v0.3-to-v0.2.sql
    13	#   Both files drafted at commit alongside this supplement.
    14	#
    15	# Field types: per `review-schema-change` skill §2 allowed types only —
    16	# string | integer | number | boolean | array | object | timestamp | date.
    17	# Enums expressed as `type: string` + `enum: [...]`. Lists as `type: array`
    18	# with `items.type`. SQL-level types (NUMERIC(15,2), TIMESTAMPTZ etc.) appear
    19	# only in the companion migration SQL, not here.
    20	#
    21	# Schema layering: entities.data is JSONB per Day-4 §6.3 generic primitive.
    22	# v0.3 entity-field additions are JSONB key shapes validated via the
    23	# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
    24	# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
    25	# tables — they're already JSONB-shaped.
    26	# ============================================================================
    27	
    28	vertical: recruitment
    29	version: v0.3
    30	supplements: v0.2
    31	status: Proposed
    32	date: 2026-05-24
    33	author: founder (Maddox) + Claude Code; bilateral Cat-β unblock
    34	codex_ratification_queue_position: 44
    35	
    36	# ============================================================================
    37	# §1 — New entity.data JSONB key shapes (14 across 5 entities)
    38	# ============================================================================
    39	#
    40	# All additions land as JSONB keys on the existing entities.data column
    41	# (Day-4 §6.3 generic primitive layer). Validation lives in
    42	# validate_entities_data_v0_3() trigger function (migration §4).
    43	
    44	entity_field_additions:
    45	
    46	  candidate:
    47	    v0_3_new_keys:
    48	      employment_type:
    49	        type: string
    50	        enum: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
    51	        required: false
    52	        notes: |
    53	          Candidate's preferred engagement model (distinct from role type).
    54	          IR35 distinction matters for UK contractors. Extracted by Scribe
    55	          from call context.
    56	        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
    57	        v1_0_agent_access:
    58	          - Scribe: W
    59	          - Sourcing Scout: R
    60	
    61	      key_skills:
    62	        type: array
    63	        items:
    64	          type: string
    65	        max_items: 20
    66	        required: false
    67	        notes: |
    68	          Aggregated skill tags from CV + transcripts. Free-text strings;
    69	          W4 polish may add controlled-vocabulary clustering. Max 20 items
    70	          per candidate enforced by validate_entities_data_v0_3.
    71	        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
    72	        v1_0_agent_access:
    73	          - Scribe: W
    74	          - Sourcing Scout: R+W
    75	
    76	      linkedin_url:
    77	        type: string
    78	        pattern: '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
    79	        required: false
    80	        notes: |
    81	          LinkedIn profile URL. Pattern enforced by trigger. Set by Sourcing
    82	          Scout from match; Janitor uses for dedup (stronger match signal
    83	          than name+email); Concierge reads for outreach context (NOT for
    84	          outbound — outreach via candidate.email or candidate.phone only).
    85	        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
    86	        v1_0_agent_access:
    87	          - Sourcing Scout: R+W
    88	          - Janitor: R   # W only via dedup-merge action
    89	          - Concierge: R
    90	
    91	  contact:
    92	    v0_3_new_keys:
    93	      preferred_channel:
    94	        type: string
    95	        enum: [email, phone, sms, teams, slack, in_person, unknown]
    96	        default: unknown
    97	        required: false
    98	        notes: |
    99	          Contact's stated preference; extracted by Scribe from call context.
   100	          Concierge reads to route outbound lifecycle comms.
   101	        source: IFOS-derived (Scribe extraction)
   102	        v1_0_agent_access:
   103	          - Scribe: R+W
   104	          - Concierge: R
   105	
   106	      next_action_target_date:
   107	        type: date
   108	        required: false
   109	        notes: |
   110	          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
   111	          is in transcript. Concierge respects this when scheduling lifecycle
   112	          nurture.
   113	        source: IFOS-derived (Scribe extraction)
   114	        v1_0_agent_access:
   115	          - Scribe: R+W
   116	          - Concierge: R
   117	
   118	  brief:
   119	    v0_3_new_keys:
   120	      must_haves:
   121	        type: array
   122	        items:
   123	          type: string
   124	        max_items: 15
   125	        required: false
   126	        notes: |
   127	          Hard requirements; Sourcing Scout filters candidates against this
   128	          list. Free-text strings; max 15 items enforced by trigger.
   129	        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
   130	        v1_0_agent_access:
   131	          - Scribe: R+W
   132	          - Sourcing Scout: R
   133	
   134	      nice_to_haves:
   135	        type: array
   136	        items:
   137	          type: string
   138	        required: false
   139	        notes: |
   140	          Soft preferences; Sourcing Scout uses for ranking, not hard filter.
   141	        source: IFOS-derived (Scribe extracts)
   142	        v1_0_agent_access:
   143	          - Scribe: R+W
   144	          - Sourcing Scout: R
   145	
   146	      deal_breakers:
   147	        type: array
   148	        items:
   149	          type: string
   150	        required: false
   151	        notes: |
   152	          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
   153	          item.
   154	        source: IFOS-derived (Scribe extracts)
   155	        v1_0_agent_access:
   156	          - Scribe: R+W
   157	          - Sourcing Scout: R
   158	
   159	  placement:
   160	    v0_3_new_keys:
   161	      placement_status:
   162	        type: string
   163	        enum: [pending_start, active, completed, terminated_early, on_hold, cancelled]
   164	        default: pending_start
   165	        required: false
   166	        notes: |
   167	          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
   168	          confirming candidate started. Janitor flags ambiguous via
   169	          ESC_LIFECYCLE_STATE_UNKNOWN.
   170	        source: IFOS-derived (Scribe + Janitor)
   171	        v1_0_agent_access:
   172	          - Scribe: R+W
   173	          - Janitor: R+W
   174	          - Concierge: R
   175	
   176	      week_1_status_note:
   177	        type: string
   178	        max_length: 500
   179	        required: false
   180	        notes: |
   181	          Free-text narrative from 7d check-in call. Stored verbatim;
   182	          voice-classifier review at write time per Scribe §7.
   183	        source: IFOS-derived (Scribe extracts from 7d check-in call)
   184	        v1_0_agent_access:
   185	          - Scribe: R+W
   186	          - Concierge: R
   187	
   188	      satisfaction_signal:
   189	        type: string
   190	        enum: [positive, neutral, negative, unclear]
   191	        default: unclear
   192	        required: false
   193	        notes: |
   194	          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
   195	          Concierge reads to adjust nurture tone.
   196	        source: IFOS-derived (Scribe LLM extraction)
   197	        v1_0_agent_access:
   198	          - Scribe: R+W
   199	          - Concierge: R
   200	
   201	  opportunity:
   202	    v0_3_new_keys:
   203	      headcount_growth_signal_text:
   204	        type: string
   205	        max_length: 280
   206	        required: false
   207	        notes: |
   208	          Free-text capture of growth-signal phrases from prospecting calls
   209	          ("we're hiring 5 engineers this quarter"). Sourcing Scout reads
   210	          to ICP-fit-score opportunities.
   211	        source: IFOS-derived (Scribe extraction)
   212	        v1_0_agent_access:
   213	          - Scribe: R+W
   214	          - Sourcing Scout: R
   215	
   216	      hiring_velocity_band:
   217	        type: string
   218	        enum: [slow, moderate, fast, urgent, unknown]
   219	        default: unknown
   220	        required: false
   221	        notes: |
   222	          Scribe LLM inference from prospecting-call urgency cues. Drives
   223	          ranking in Sourcing Scout's brief-to-candidate pipeline.
   224	        source: IFOS-derived (Scribe LLM classification)
   225	        v1_0_agent_access:
   226	          - Scribe: R+W
   227	          - Sourcing Scout: R
   228	
   229	      decision_window_text:
   230	        type: string
   231	        max_length: 280
   232	        required: false
   233	        notes: |
   234	          Free-text capture of decision-timing phrases. Concierge reads to
   235	          time outbound comms.
   236	        source: IFOS-derived (Scribe extraction)
   237	        v1_0_agent_access:
   238	          - Scribe: R+W
   239	          - Concierge: R
   240	
   241	# ============================================================================
   242	# §2 — Complete v0.3 agent access matrix
   243	# ============================================================================
   244	#
   245	# Per review-schema-change skill §5: full matrix across all v1.0 agents
   246	# and all v0.1 + v0.2 entities. v0.3 is a CUMULATIVE matrix that includes
   247	# v0.1 + v0.2 + v0.3 dispositions. Where this matrix differs from
   248	# vertical-schema.yaml v0.1 §3, the cell is an EXPLICIT v0.3 amendment
   249	# with a marker comment in-line. Full list of v0.3 amendments:
   250	#
   251	# Cells changed from v0.1 baseline:
   252	#   - Diagnostic client: none → R (reads Companies House data via cached
   253	#     client entity; sales-tool source-of-truth context — v0.3 amendment)
   254	#   - Diagnostic contact: none → R (reads §11 decision-maker map context)
   255	#   - Diagnostic opportunity: none → R (reads prospect-firm opportunity if exists)
   256	#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
   257	#     pattern as candidate/contractor — v0.3 amendment)
   258	#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
   259	#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
   260	#     v0.3 amendment)
   261	#   - Janitor timesheet: none → R (reads for placement-state inference)
   262	#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
   263	#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
   264	#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
   265	#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
   266	#     R-only for Scribe)
   267	#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
   268	#   - Scribe timesheet: none → R (reads for placement-context resolution
   269	#     on check-in calls)
   270	#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
   271	#     — v0.3 amendment)
   272	#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
   273	#   - Cash Conductor timesheet: none → R (reads to verify billable hours
   274	#     match invoiced amounts)
   275	#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
   276	#     from multi-source aggregation — v0.3 amendment)
   277	#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
   278	#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
   279	#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
   280	#     activity-log links per concierge §4 Step 13-14 — v0.3 amendment)
   281	#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
   282	#   - Concierge opportunity: none → R (reads for outbound lifecycle-event context)
   283	#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
   284	#     concierge §4 Step 14 — v0.3 amendment)
   285	#   - Concierge timesheet: none → R (reads to verify placement-progress for
   286	#     7d/30d/90d nurture)
   287	#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
   288	#     extended)
   289	#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
   290	#     — v0.2 extended)
   291	#
   292	# All other access levels carry forward unchanged from v0.1 + v0.2.
   293	
   294	agent_access_matrix:
   295	
   296	  # Disposition tokens: R | W | R+W | none
   297	  #
   298	  # ENTITY-LEVEL vs FIELD-LEVEL ACCESS:
   299	  # The matrix below is ENTITY-LEVEL — declares the maximum disposition an
   300	  # agent may have on any field of that entity. Per-field access (in §1
   301	  # entity_field_additions[*].v1_0_agent_access) NARROWS the entity-level
   302	  # disposition. Example: Scribe.candidate: R+W at entity level; per-field
   303	  # candidate.employment_type grants Scribe: W (because Scribe doesn't read
   304	  # employment_type, just writes it). This is intentional — the entity-level
   305	  # token is the ceiling; field-level may be narrower but never broader.
   306	  #
   307	  # Validation: the validate_entities_data_v0_3 trigger enforces field-level
   308	  # writes per the per-field constraints; entity-level RLS enforces tenant
   309	  # isolation. There is no separate field-level permission enforcement layer
   310	  # in v0.3 (would need column-level RLS or app-level mediation; W4+ work).
   311	
   312	  diagnostic:
   313	    candidate: R           # reads for outreach context (§11 decision-maker map)
   314	    contractor: none       # not in scope at v1.0
   315	    client: R              # reads via Companies House lookup (entity-shape if cached)
   316	    contact: R             # reads for §11 decision-maker map
   317	    brief: none            # diagnostic is sales-tool not brief-driven
   318	    opportunity: R         # may read prospect-firm opportunity if exists
   319	    placement: none
   320	    timesheet: none
   321	    voice_corpus: R
   322	    voice_corpus_chunks: R
   323	    tone_rule: R
   324	    recent_edit: none
   325	
   326	  janitor:
   327	    candidate: R+W         # dedup + field-backfill writes
   328	    contractor: R+W        # dedup + field-backfill writes
   329	    client: R+W            # Companies House enrichment writes
   330	    contact: R+W           # dedup + field-backfill writes
   331	    brief: R               # context for related candidate cleanup
   332	    opportunity: R
   333	    placement: R+W         # lifecycle-state cleanup
   334	    timesheet: R           # reads for placement-state inference
   335	    voice_corpus: R        # tacit-note narrative voice grounding
   336	    voice_corpus_chunks: R
   337	    tone_rule: R           # v0.3 NEW (was no access)
   338	    recent_edit: R         # v0.3 NEW (was Concierge/canary/LoRA only); for tacit-note harvest
   339	
   340	  scribe:
   341	    candidate: R+W         # call-summary field extraction
   342	    contractor: R+W        # call-summary field extraction
   343	    client: R
   344	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
   345	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
   346	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
   347	    placement: R+W         # check-in field extraction
   348	    timesheet: R           # reads for placement-context resolution on check-in calls
   349	    voice_corpus: R        # tacit-note voice grounding
   350	    voice_corpus_chunks: R
   351	    tone_rule: R           # v0.2
   352	    recent_edit: W         # writes its own edits for retraining
   353	
   354	  cash_conductor:
   355	    candidate: none        # no Bullhorn dependency
   356	    contractor: none
   357	    client: R              # reads client billing details
   358	    contact: R             # reads for invoice addressee resolution
   359	    brief: none
   360	    opportunity: none
   361	    placement: R           # reads for client linkage on invoice
   362	    timesheet: R           # reads to verify billable hours match invoiced amounts
   363	    voice_corpus: R        # chase-email voice grounding
   364	    voice_corpus_chunks: R
   365	    tone_rule: R           # v0.2
   366	    recent_edit: W         # writes its own chase-draft edits for retraining
   367	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   368	
   369	  sourcing_scout:
   370	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   371	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   372	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   373	    # writes its proposed-candidate rows + reads opportunity context. These
   374	    # are entity-level access overrides codified here.
   375	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   376	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   377	    client: R
   378	    contact: R
   379	    brief: R               # reads to filter candidates
   380	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   381	    placement: none
   382	    timesheet: none
   383	    voice_corpus: R        # rationale-narrative voice grounding
   384	    voice_corpus_chunks: R
   385	    tone_rule: R
   386	    recent_edit: W         # writes rationale-narrative edits for retraining
   387	
   388	  concierge:
   389	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   390	    contractor: R+W        # writes lifecycle states for contractor placements too
   391	    client: R
   392	    contact: R             # reads for outbound recipient resolution
   393	    brief: R
   394	    opportunity: R
   395	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   396	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   397	    voice_corpus: R        # lifecycle-comms voice grounding
   398	    voice_corpus_chunks: R
   399	    tone_rule: R           # v0.2
   400	    recent_edit: R         # v0.2
   401	
   402	# ============================================================================
   403	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   404	# ============================================================================
   405	
   406	auxiliary_tables:
   407	
   408	  cash_conductor_transactions:
   409	    rationale: |
   410	      Open Banking transactions are high-volume + time-series + don't model
   411	      as entity.data JSONB. v0.3 introduces a first-class table with
   412	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   413	      §4 Step 3 + ADR-002 vault/Postgres split.
   414	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   415	    columns:
   416	      id: {type: integer, required: true, notes: BIGSERIAL primary key in SQL}
   417	      tenant_slug: {type: string, required: true, notes: RLS isolation key per Day-4 §6.3}
   418	      transaction_id: {type: string, required: true, notes: Provider-supplied (TrueLayer / Plaid)}
   419	      posted_at: {type: timestamp, required: true}
   420	      amount: {type: number, required: true, notes: NUMERIC(15,2) GBP; negative for outgoing}
   421	      currency: {type: string, required: true, default: GBP}
   422	      payee_name_raw: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   423	      description: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   424	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct]}
   425	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched}
   426	      matched_invoice_id: {type: string, required: false, notes: FK to cash_conductor_invoices.invoice_id when match_status='matched'}
   427	      match_confidence: {type: number, required: false, notes: "range [0.00, 1.00]"}
   428	      match_dimensions: {type: array, items: {type: string}, required: false}
   429	      ingested_at: {type: timestamp, required: true, default: now()}
   430	      raw_payload: {type: object, required: false, pii: true, notes: Full Open Banking response; pseudonymized at year 7}
   431	    indexes:
   432	      - "(tenant_slug, posted_at DESC)"
   433	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   434	    retention: |
   435	      INTENT (W4-polish enforcement required): 7-year retention with
   436	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   437	      description, raw_payload). Aligned with Q4 v0_3_default. The
   438	      v0.2-to-v0.3 migration creates the table + indexes only; the
   439	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   440	      job or external scheduled job; not yet authored).
   441	    enforcement_gate: |
   442	      Production use of this table GATED until pseudonymization + purge
   443	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   444	      by founder + tenant before go-live; migration-test tenant exempt.
   445	
   446	  cash_conductor_invoices:
   447	    rationale: |
   448	      Open invoice register cached from accounting provider. Same auxiliary-
   449	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   450	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   451	    columns:
   452	      id: {type: integer, required: true}
   453	      tenant_slug: {type: string, required: true}
   454	      invoice_id: {type: string, required: true}
   455	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage]}
   456	      invoice_number: {type: string, required: false}
   457	      issued_at: {type: timestamp, required: true}
   458	      due_at: {type: timestamp, required: true}
   459	      amount_total: {type: number, required: true, notes: NUMERIC(15,2) GBP}
   460	      amount_paid: {type: number, required: true, default: 0}
   461	      currency: {type: string, required: true, default: GBP}
   462	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open}
   463	      client_contact_id: {type: string, required: false, notes: Links to Bullhorn placement.client_contact_id}
   464	      client_billing_email: {type: string, required: false, pii: true}
   465	      last_chase_position: {type: integer, required: true, default: 0, notes: 0-4 per Cash Conductor §3.2}
   466	      last_chase_sent_at: {type: timestamp, required: false}
   467	      ingested_at: {type: timestamp, required: true, default: now()}
   468	      raw_payload: {type: object, required: false, pii: true}
   469	    indexes:
   470	      - "(tenant_slug, due_at)"
   471	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   472	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   473	    retention: |
   474	      INTENT (W4-polish enforcement required): 7-year retention with
   475	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   476	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   477	      pseudonymization + purge implementation is a W4-polish slice
   478	      (pg_cron job or external scheduled job; not yet authored).
   479	    enforcement_gate: |
   480	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   481	      W4 polish, production use of cash_conductor_invoices is GATED by
   482	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   483	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   484	      data is exempt; pilot tenants require the DPA addendum signed before
   485	      go-live.
   486	
   487	auxiliary_table_access_matrix:
   488	  cash_conductor_transactions:
   489	    diagnostic: none
   490	    janitor: none
   491	    scribe: none
   492	    cash_conductor: R+W
   493	    sourcing_scout: none
   494	    concierge: none
   495	  cash_conductor_invoices:
   496	    diagnostic: none
   497	    janitor: none
   498	    scribe: none
   499	    cash_conductor: R+W
   500	    sourcing_scout: none
   501	    concierge: none
   502	
   503	# ============================================================================
   504	# §4 — tenant_adapters.config new keys (4 keys)
   505	# ============================================================================
   506	#
   507	# tenant_adapters.config is JSONB; validation via
   508	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   509	# on unknown keys per Rule 2.
   510	
   511	tenant_adapters_config_additions:
   512	
   513	  cash_conductor_last_run:
   514	    type: timestamp
   515	    required: false
   516	    set_by: cash_conductor
   517	    read_by: [cash_conductor]
   518	    notes: |
   519	      Cash Conductor cron sweep updates at session-close. Next run queries
   520	      transactions/invoices since this timestamp.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	-- ============================================================================
     2	-- IFOS recruitment vertical schema — v0.2 → v0.3 migration
     3	-- ============================================================================
     4	-- Companion to: docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
     5	-- Authored:     2026-05-24 (Day 19; post-bilateral Cat-β unblock)
     6	-- Status:       DRAFTED; NOT executed against production Hetzner Postgres yet.
     7	--               Execute against migration-test tenant first via run-live-migration.sh.
     8	--
     9	-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
    10	-- Concierge). v0.3 additions:
    11	--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
    12	--     (both RLS-isolated per tenant_slug)
    13	--   - JSONB validation trigger updates for entities.data: validate new keys on
    14	--     candidate, contact, brief, placement, opportunity (14 fields across 5
    15	--     entity_types)
    16	--   - JSONB validation trigger for tenant_adapters.config: 4 new keys
    17	--   - decision_log.payload extension is documented in autosend-safety-policy.md
    18	--     §7 supplement; no migration needed (JSONB column accepts any keys at write
    19	--     time; validation is in v0.2 trigger)
    20	--
    21	-- All v0.3 additions are STRICTLY ADDITIVE. Rollback path: companion
    22	-- v0.3-to-v0.2.sql.
    23	--
    24	-- Prerequisites:
    25	--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
    26	--     recent_edit tables exist; validate_voice_scores trigger active)
    27	--   - RLS policies + ifos_app grants from Day-4 §6.3 in place
    28	--   - migration-test tenant row exists in tenants table
    29	--
    30	-- Execution order: BEGIN; <each block>; COMMIT;   on success.
    31	--                  BEGIN; <each block>; ROLLBACK; on any error.
    32	-- ============================================================================
    33	
    34	BEGIN;
    35	
    36	-- ----------------------------------------------------------------------------
    37	-- §1 — Verify prerequisite v0.2 state
    38	-- ----------------------------------------------------------------------------
    39	
    40	DO $$
    41	BEGIN
    42	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
    43	    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
    44	  END IF;
    45	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
    46	    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
    47	  END IF;
    48	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
    49	    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
    50	  END IF;
    51	  RAISE NOTICE 'v0.2 prerequisites verified';
    52	END $$;
    53	
    54	-- ----------------------------------------------------------------------------
    55	-- §2 — Create cash_conductor_transactions table (RLS-isolated)
    56	-- ----------------------------------------------------------------------------
    57	
    58	CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
    59	  id                 BIGSERIAL PRIMARY KEY,
    60	  tenant_slug        TEXT NOT NULL,
    61	  transaction_id     TEXT NOT NULL,
    62	  posted_at          TIMESTAMPTZ NOT NULL,
    63	  amount             NUMERIC(15, 2) NOT NULL,
    64	  currency           TEXT NOT NULL DEFAULT 'GBP',
    65	  payee_name_raw     TEXT,
    66	  description        TEXT,
    67	  bank_provider      TEXT NOT NULL,
    68	  match_status       TEXT NOT NULL DEFAULT 'unmatched',
    69	  matched_invoice_id TEXT,
    70	  match_confidence   NUMERIC(3, 2),
    71	  match_dimensions   TEXT[],
    72	  ingested_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    73	  raw_payload        JSONB,
    74	
    75	  CONSTRAINT cct_match_status_valid CHECK (
    76	    match_status IN ('unmatched', 'matched', 'ambiguous')
    77	  ),
    78	  CONSTRAINT cct_bank_provider_valid CHECK (
    79	    bank_provider IN ('truelayer', 'plaid_uk', 'open_banking_direct')
    80	  ),
    81	  CONSTRAINT cct_match_confidence_range CHECK (
    82	    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
    83	  ),
    84	  CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id)
    85	);
    86	
    87	CREATE INDEX IF NOT EXISTS idx_cct_tenant_posted
    88	  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
    89	
    90	CREATE INDEX IF NOT EXISTS idx_cct_tenant_unmatched
    91	  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
    92	  WHERE match_status IN ('unmatched', 'ambiguous');
    93	
    94	-- RLS isolation per Day-4 §6.3 pattern
    95	ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
    96	ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
    97	
    98	CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
    99	  FOR ALL TO ifos_app
   100	  USING (tenant_slug = current_setting('app.current_tenant', true));
   101	
   102	GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
   103	GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
   104	
   105	-- ----------------------------------------------------------------------------
   106	-- §3 — Create cash_conductor_invoices table (RLS-isolated)
   107	-- ----------------------------------------------------------------------------
   108	
   109	CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
   110	  id                       BIGSERIAL PRIMARY KEY,
   111	  tenant_slug              TEXT NOT NULL,
   112	  invoice_id               TEXT NOT NULL,
   113	  accounting_provider      TEXT NOT NULL,
   114	  invoice_number           TEXT,
   115	  issued_at                TIMESTAMPTZ NOT NULL,
   116	  due_at                   TIMESTAMPTZ NOT NULL,
   117	  amount_total             NUMERIC(15, 2) NOT NULL,
   118	  amount_paid              NUMERIC(15, 2) NOT NULL DEFAULT 0,
   119	  currency                 TEXT NOT NULL DEFAULT 'GBP',
   120	  status                   TEXT NOT NULL DEFAULT 'open',
   121	  client_contact_id        TEXT,
   122	  client_billing_email     TEXT,
   123	  last_chase_position      INT NOT NULL DEFAULT 0,
   124	  last_chase_sent_at       TIMESTAMPTZ,
   125	  ingested_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
   126	  raw_payload              JSONB,
   127	
   128	  CONSTRAINT cci_status_valid CHECK (
   129	    status IN ('open', 'partial', 'paid', 'overdue', 'cancelled', 'voided')
   130	  ),
   131	  CONSTRAINT cci_provider_valid CHECK (
   132	    accounting_provider IN ('xero', 'quickbooks', 'sage')
   133	  ),
   134	  CONSTRAINT cci_chase_position_range CHECK (
   135	    last_chase_position >= 0 AND last_chase_position <= 4
   136	  ),
   137	  CONSTRAINT cci_amount_paid_non_negative CHECK (
   138	    amount_paid >= 0 AND amount_paid <= amount_total
   139	  ),
   140	  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
   141	);
   142	
   143	CREATE INDEX IF NOT EXISTS idx_cci_tenant_due
   144	  ON cash_conductor_invoices (tenant_slug, due_at);
   145	
   146	CREATE INDEX IF NOT EXISTS idx_cci_tenant_overdue
   147	  ON cash_conductor_invoices (tenant_slug, status, due_at)
   148	  WHERE status IN ('open', 'partial', 'overdue');
   149	
   150	CREATE INDEX IF NOT EXISTS idx_cci_tenant_chase
   151	  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
   152	  WHERE last_chase_position BETWEEN 1 AND 3;
   153	
   154	ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
   155	ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
   156	
   157	CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
   158	  FOR ALL TO ifos_app
   159	  USING (tenant_slug = current_setting('app.current_tenant', true));
   160	
   161	GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
   162	GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
   163	
   164	-- ----------------------------------------------------------------------------
   165	-- §4 — Replace JSONB validation function for entities.data (adds v0.3 keys)
   166	-- ----------------------------------------------------------------------------
   167	--
   168	-- The v0.2 migration installed validate_voice_scores trigger which validates
   169	-- the 6 voice-score keys. v0.3 extends validation to cover the 14 new keys
   170	-- for candidate, contact, brief, placement, opportunity. We replace the
   171	-- function in place (CREATE OR REPLACE) so the v0.2 voice-score checks remain.
   172	
   173	CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
   174	RETURNS TRIGGER AS $$
   175	DECLARE
   176	  d JSONB := NEW.data;
   177	  et TEXT := NEW.entity_type;
   178	  arr_item JSONB;
   179	BEGIN
   180	  -- v0.2 voice-score keys (forwarded; preserves v0.2 [0.0, 1.0] range check)
   181	  IF d ? 'voice_classifier_score' THEN
   182	    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
   183	      RAISE EXCEPTION 'voice_classifier_score must be number or null';
   184	    END IF;
   185	    IF d->'voice_classifier_score' != 'null'::jsonb THEN
   186	      IF (d->>'voice_classifier_score')::numeric < 0.0
   187	         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
   188	        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
   189	      END IF;
   190	    END IF;
   191	  END IF;
   192	
   193	  IF d ? 'voice_drift_at_close' THEN
   194	    IF jsonb_typeof(d->'voice_drift_at_close') NOT IN ('number', 'null') THEN
   195	      RAISE EXCEPTION 'voice_drift_at_close must be number or null';
   196	    END IF;
   197	    IF d->'voice_drift_at_close' != 'null'::jsonb THEN
   198	      IF (d->>'voice_drift_at_close')::numeric < 0.0
   199	         OR (d->>'voice_drift_at_close')::numeric > 1.0 THEN
   200	        RAISE EXCEPTION 'voice_drift_at_close out of [0.0, 1.0] range: %', d->>'voice_drift_at_close';
   201	      END IF;
   202	    END IF;
   203	  END IF;
   204	
   205	  -- v0.3 candidate fields
   206	  IF et = 'candidate' THEN
   207	    IF d ? 'employment_type' THEN
   208	      IF (d->>'employment_type') NOT IN (
   209	        'perm', 'contract', 'contract_inside_ir35', 'contract_outside_ir35', 'day_rate', 'hybrid'
   210	      ) THEN
   211	        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
   212	      END IF;
   213	    END IF;
   214	
   215	    IF d ? 'key_skills' THEN
   216	      IF jsonb_typeof(d->'key_skills') != 'array' THEN
   217	        RAISE EXCEPTION 'key_skills must be array';
   218	      END IF;
   219	      IF jsonb_array_length(d->'key_skills') > 20 THEN
   220	        RAISE EXCEPTION 'key_skills max length 20 (got %)', jsonb_array_length(d->'key_skills');
   221	      END IF;
   222	      -- Every element must be a string
   223	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'key_skills') LOOP
   224	        IF jsonb_typeof(arr_item) != 'string' THEN
   225	          RAISE EXCEPTION 'key_skills items must be strings; got %', jsonb_typeof(arr_item);
   226	        END IF;
   227	      END LOOP;
   228	    END IF;
   229	
   230	    IF d ? 'linkedin_url' THEN
   231	      IF jsonb_typeof(d->'linkedin_url') NOT IN ('string', 'null') THEN
   232	        RAISE EXCEPTION 'linkedin_url must be string or null';
   233	      END IF;
   234	      IF d->>'linkedin_url' IS NOT NULL
   235	         AND d->>'linkedin_url' !~ '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$' THEN
   236	        RAISE EXCEPTION 'linkedin_url does not match expected pattern: %', d->>'linkedin_url';
   237	      END IF;
   238	    END IF;
   239	  END IF;
   240	
   241	  -- v0.3 contact fields
   242	  IF et = 'contact' THEN
   243	    IF d ? 'preferred_channel' THEN
   244	      IF (d->>'preferred_channel') NOT IN (
   245	        'email', 'phone', 'sms', 'teams', 'slack', 'in_person', 'unknown'
   246	      ) THEN
   247	        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
   248	      END IF;
   249	    END IF;
   250	
   251	    IF d ? 'next_action_target_date' THEN
   252	      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
   253	        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
   254	      END IF;
   255	    END IF;
   256	  END IF;
   257	
   258	  -- v0.3 brief fields
   259	  IF et = 'brief' THEN
   260	    IF d ? 'must_haves' THEN

exec
/bin/zsh -lc 'rg --files docs/verticals/recruitment | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '520,820p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '260,620p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	    IF d ? 'must_haves' THEN
   261	      IF jsonb_typeof(d->'must_haves') != 'array' THEN
   262	        RAISE EXCEPTION 'must_haves must be array';
   263	      END IF;
   264	      IF jsonb_array_length(d->'must_haves') > 15 THEN
   265	        RAISE EXCEPTION 'must_haves max length 15';
   266	      END IF;
   267	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
   268	        IF jsonb_typeof(arr_item) != 'string' THEN
   269	          RAISE EXCEPTION 'must_haves items must be strings';
   270	        END IF;
   271	      END LOOP;
   272	    END IF;
   273	
   274	    IF d ? 'nice_to_haves' THEN
   275	      IF jsonb_typeof(d->'nice_to_haves') != 'array' THEN
   276	        RAISE EXCEPTION 'nice_to_haves must be array';
   277	      END IF;
   278	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'nice_to_haves') LOOP
   279	        IF jsonb_typeof(arr_item) != 'string' THEN
   280	          RAISE EXCEPTION 'nice_to_haves items must be strings';
   281	        END IF;
   282	      END LOOP;
   283	    END IF;
   284	
   285	    IF d ? 'deal_breakers' THEN
   286	      IF jsonb_typeof(d->'deal_breakers') != 'array' THEN
   287	        RAISE EXCEPTION 'deal_breakers must be array';
   288	      END IF;
   289	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
   290	        IF jsonb_typeof(arr_item) != 'string' THEN
   291	          RAISE EXCEPTION 'deal_breakers items must be strings';
   292	        END IF;
   293	      END LOOP;
   294	    END IF;
   295	  END IF;
   296	
   297	  -- v0.3 placement fields
   298	  IF et = 'placement' THEN
   299	    IF d ? 'placement_status' THEN
   300	      IF (d->>'placement_status') NOT IN (
   301	        'pending_start', 'active', 'completed', 'terminated_early', 'on_hold', 'cancelled'
   302	      ) THEN
   303	        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
   304	      END IF;
   305	    END IF;
   306	
   307	    IF d ? 'week_1_status_note' THEN
   308	      IF jsonb_typeof(d->'week_1_status_note') NOT IN ('string', 'null') THEN
   309	        RAISE EXCEPTION 'week_1_status_note must be string or null';
   310	      END IF;
   311	      IF d->>'week_1_status_note' IS NOT NULL
   312	         AND length(d->>'week_1_status_note') > 500 THEN
   313	        RAISE EXCEPTION 'week_1_status_note exceeds 500 chars (got %)', length(d->>'week_1_status_note');
   314	      END IF;
   315	    END IF;
   316	
   317	    IF d ? 'satisfaction_signal' THEN
   318	      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
   319	        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
   320	      END IF;
   321	    END IF;
   322	  END IF;
   323	
   324	  -- v0.3 opportunity fields
   325	  IF et = 'opportunity' THEN
   326	    IF d ? 'headcount_growth_signal_text' THEN
   327	      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
   328	        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
   329	      END IF;
   330	      IF d->>'headcount_growth_signal_text' IS NOT NULL
   331	         AND length(d->>'headcount_growth_signal_text') > 280 THEN
   332	        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
   333	      END IF;
   334	    END IF;
   335	
   336	    IF d ? 'hiring_velocity_band' THEN
   337	      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
   338	        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
   339	      END IF;
   340	    END IF;
   341	
   342	    IF d ? 'decision_window_text' THEN
   343	      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
   344	        RAISE EXCEPTION 'decision_window_text must be string or null';
   345	      END IF;
   346	      IF d->>'decision_window_text' IS NOT NULL
   347	         AND length(d->>'decision_window_text') > 280 THEN
   348	        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
   349	      END IF;
   350	    END IF;
   351	  END IF;
   352	
   353	  RETURN NEW;
   354	END;
   355	$$ LANGUAGE plpgsql;
   356	
   357	-- Rebind the trigger to the new function (drops + recreates)
   358	DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
   359	DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
   360	
   361	CREATE TRIGGER validate_entities_data_v0_3
   362	  BEFORE INSERT OR UPDATE ON entities
   363	  FOR EACH ROW
   364	  EXECUTE FUNCTION validate_entities_data_v0_3();
   365	
   366	-- ----------------------------------------------------------------------------
   367	-- §5 — tenant_adapters.config validation trigger (new keys)
   368	-- ----------------------------------------------------------------------------
   369	--
   370	-- v0.3 codifies 4 new config keys agents read. The validation trigger ensures
   371	-- only the documented keys are stored (hard-fail on unknown keys per Rule 2
   372	-- Schema before code).
   373	
   374	CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
   375	RETURNS TRIGGER AS $$
   376	DECLARE
   377	  c JSONB := NEW.config;
   378	  k TEXT;
   379	  allowed_keys TEXT[] := ARRAY[
   380	    -- v0.1 + v0.2 keys (forwarded; do not remove)
   381	    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
   382	    'janitor_last_run',
   383	    'pii_retention_days',  -- v0.2 PII purge runbook key
   384	    -- autosend-safety-policy.md keys
   385	    'approval_routing', 'approval_timeouts', 'sampling_rates',
   386	    -- v0.3 additions
   387	    'cash_conductor_last_run',
   388	    'concierge_last_poll',
   389	    'concierge_send_window',
   390	    'diagnostic_per_claim_sample_rate'
   391	  ];
   392	BEGIN
   393	  IF c IS NULL THEN
   394	    RETURN NEW;
   395	  END IF;
   396	
   397	  FOR k IN SELECT jsonb_object_keys(c) LOOP
   398	    IF NOT (k = ANY(allowed_keys)) THEN
   399	      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
   400	    END IF;
   401	  END LOOP;
   402	
   403	  -- v0.3 type validations
   404	  IF c ? 'diagnostic_per_claim_sample_rate' THEN
   405	    IF jsonb_typeof(c->'diagnostic_per_claim_sample_rate') != 'number' THEN
   406	      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be integer';
   407	    END IF;
   408	    IF (c->>'diagnostic_per_claim_sample_rate')::int < 1
   409	       OR (c->>'diagnostic_per_claim_sample_rate')::int > 100 THEN
   410	      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be 1-100';
   411	    END IF;
   412	  END IF;
   413	
   414	  IF c ? 'concierge_send_window' THEN
   415	    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
   416	      RAISE EXCEPTION 'concierge_send_window must be object';
   417	    END IF;
   418	    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
   419	      RAISE EXCEPTION 'concierge_send_window must include timezone';
   420	    END IF;
   421	    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
   422	       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
   423	      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
   424	    END IF;
   425	    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
   426	       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
   427	      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
   428	    END IF;
   429	  END IF;
   430	
   431	  -- v0.3 timestamp-typed keys
   432	  IF c ? 'cash_conductor_last_run' THEN
   433	    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
   434	      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
   435	    END IF;
   436	  END IF;
   437	
   438	  IF c ? 'concierge_last_poll' THEN
   439	    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
   440	      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
   441	    END IF;
   442	  END IF;
   443	
   444	  RETURN NEW;
   445	END;
   446	$$ LANGUAGE plpgsql;
   447	
   448	DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
   449	
   450	CREATE TRIGGER validate_tenant_adapters_config_v0_3
   451	  BEFORE INSERT OR UPDATE ON tenant_adapters
   452	  FOR EACH ROW
   453	  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
   454	
   455	-- ----------------------------------------------------------------------------
   456	-- §6 — Smoke verification (read-only)
   457	-- ----------------------------------------------------------------------------
   458	
   459	DO $$
   460	DECLARE
   461	  ccr_count INT;
   462	  cci_count INT;
   463	BEGIN
   464	  SELECT count(*) INTO ccr_count FROM information_schema.tables
   465	    WHERE table_name = 'cash_conductor_transactions';
   466	  IF ccr_count != 1 THEN
   467	    RAISE EXCEPTION 'cash_conductor_transactions table not created';
   468	  END IF;
   469	
   470	  SELECT count(*) INTO cci_count FROM information_schema.tables
   471	    WHERE table_name = 'cash_conductor_invoices';
   472	  IF cci_count != 1 THEN
   473	    RAISE EXCEPTION 'cash_conductor_invoices table not created';
   474	  END IF;
   475	
   476	  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
   477	END $$;
   478	
   479	COMMIT;
   480	
   481	-- ============================================================================
   482	-- End of v0.2 → v0.3 migration
   483	-- ============================================================================

 succeeded in 0ms:
   520	      transactions/invoices since this timestamp.
   521	
   522	  concierge_last_poll:
   523	    type: timestamp
   524	    required: false
   525	    set_by: concierge
   526	    read_by: [concierge]
   527	    notes: |
   528	      Concierge polling cron updates at end of each cycle. Next poll queries
   529	      Bullhorn for state transitions since this timestamp.
   530	
   531	  concierge_send_window:
   532	    type: object
   533	    required: false
   534	    default:
   535	      timezone: Europe/London
   536	      weekday_start: '09:00'
   537	      weekday_end: '17:00'
   538	      weekend_send_enabled: false
   539	    set_by: [tenant-admin]
   540	    read_by: [concierge]
   541	    object_shape:
   542	      timezone:
   543	        type: string
   544	        notes: IANA timezone identifier
   545	      weekday_start:
   546	        type: string
   547	        notes: HH:MM 24-hour format
   548	      weekday_end:
   549	        type: string
   550	        notes: HH:MM 24-hour format
   551	      weekend_send_enabled:
   552	        type: boolean
   553	    notes: |
   554	      Per-tenant outbound sending hours. Concierge respects when scheduling
   555	      orange-tier sends.
   556	
   557	  diagnostic_per_claim_sample_rate:
   558	    type: integer
   559	    range: [1, 100]
   560	    default: 10
   561	    required: false
   562	    set_by: [tenant-admin]
   563	    read_by: [diagnostic]
   564	    notes: |
   565	      Per ADR-006 Tier 2 (post-launch quality metric). Sample 1-in-N
   566	      Diagnostic reports for per-claim citation validation. Activates at
   567	      W4 polish; documented intent only until then.
   568	
   569	# ============================================================================
   570	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   571	# ============================================================================
   572	
   573	decision_log_payload_extension:
   574	  per_claim_confidence_distribution:
   575	    type: object
   576	    required: false
   577	    written_when: |
   578	      Tier 2 per-claim validation runs (sample-rate-gated by
   579	      tenant_adapters.config.diagnostic_per_claim_sample_rate).
   580	    object_shape:
   581	      total_claims:
   582	        type: integer
   583	      claims_with_confidence_above_0_6:
   584	        type: integer
   585	      claims_with_confidence_below_0_6:
   586	        type: integer
   587	      mean_confidence:
   588	        type: number
   589	      sampled_at:
   590	        type: timestamp
   591	      sample_rate_applied:
   592	        type: integer
   593	    notes: |
   594	      Aggregate metric, not per-claim detail. Per-claim raw data goes to a
   595	      separate v1.1 quality-metrics table if commercial value justifies.
   596	    validation:
   597	      mean_confidence: "[0.0, 1.0] range — enforced at write-time by W4-polish decision_log writer extension (not by Postgres trigger; payload is JSONB)"
   598	      claims_with_confidence_above_0_6: ">= 0 (non-negative integer)"
   599	      claims_with_confidence_below_0_6: ">= 0 (non-negative integer)"
   600	      total_claims: "= above + below (consistency invariant)"
   601	      sample_rate_applied: "[1, 100] (matches tenant_adapters.config.diagnostic_per_claim_sample_rate range)"
   602	    enforcement_gate: |
   603	      v0.3 declares the shape. Range + invariant validation lands in the
   604	      W4-polish decision_log writer extension that ships with Tier 2
   605	      sampling activation. Until then, no Tier 2 writes occur, so the
   606	      validation gap is non-blocking.
   607	
   608	# ============================================================================
   609	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   610	# ============================================================================
   611	
   612	migration_sequence:
   613	  forward: migrations/v0.2-to-v0.3.sql
   614	  rollback: migrations/v0.3-to-v0.2.sql
   615	
   616	  pre_conditions:
   617	    - v0.2 migration applied (voice_corpus + tone_rule + recent_edit tables exist)
   618	    - validate_voice_scores trigger active on entities table
   619	    - RLS + ifos_app grants from Day-4 §6.3 in place
   620	    - migration-test tenant row exists in tenants table
   621	
   622	  steps:
   623	    1: |
   624	      Verify v0.2 prerequisites (DO block in migration §1).
   625	    2: |
   626	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   627	      ifos_app grants + 2 indexes (migration §2).
   628	    3: |
   629	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   630	      (migration §3).
   631	    4: |
   632	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   633	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   634	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   635	      candidate / contact / brief / placement / opportunity entity_types.
   636	      Re-attaches the trigger to entities table (migration §4).
   637	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   638	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   639	    5: |
   640	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   641	      hard-fails on unknown config keys (Rule 2); type-validates the 4 new
   642	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   643	    6: |
   644	      Smoke verification DO block confirms both cash_conductor_*
   645	      tables exist (migration §6).
   646	    7: |
   647	      COMMIT; or ROLLBACK on any error.
   648	
   649	  post_migration_steps:
   650	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   651	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   652	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   653	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   654	       Cat-β findings closed
   655	
   656	# ============================================================================
   657	# §7 — Codex ratification path
   658	# ============================================================================
   659	
   660	codex_ratification:
   661	  skill: review-schema-change
   662	  expected_round_trips: 1-2 (mechanical fixes only)
   663	  manifest_queue_position: 44 (after v0.2 supplement at 29)
   664	
   665	# ============================================================================
   666	# §8 — Open questions (structured per review-schema-change §8)
   667	# ============================================================================
   668	
   669	open_questions:
   670	
   671	  Q1_employment_type_enum_completeness:
   672	    question: Are 6 employment_type enum values sufficient for UK recruitment?
   673	    options:
   674	      A: |
   675	        Keep 6 values as in §1.candidate.employment_type — perm, contract,
   676	        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
   677	      B: |
   678	        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
   679	      C: |
   680	        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
   681	        (array of allowed strings); validate at write time against tenant's list.
   682	    v0_3_default: A
   683	    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
   684	      outside A, escalate to B or C.
   685	
   686	  Q2_key_skills_max_length:
   687	    question: Cap at 20 items per candidate adequate?
   688	    options:
   689	      A: Keep cap at 20 (validator hard-fails over).
   690	      B: Increase to 50 (handles senior technical candidates with deep stacks).
   691	      C: Remove cap entirely (rely on application-layer pruning).
   692	    v0_3_default: A
   693	    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
   694	      of candidates hit the 20-item cap, escalate to B.
   695	
   696	  Q3_placement_status_enum_lifecycle:
   697	    question: 6-state placement_status enum maps to Bullhorn's native state machine?
   698	    options:
   699	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   700	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   701	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   702	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   703	    v0_3_default: A
   704	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   705	      escalate to B or C if 1:1 mapping breaks.
   706	
   707	  Q4_cash_conductor_transactions_retention:
   708	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   709	      What's the production retention policy?
   710	    options:
   711	      A: 7-year retention with automated pseudonymization at year 7 (hash
   712	         payee_name_raw + description; preserve amount + dates for audit).
   713	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   714	         rows retained beyond 7 years for cross-period reconciliation).
   715	      C: Per-tenant retention override in tenant_adapters.config.
   716	    v0_3_default: A
   717	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   718	      tenant requires shorter retention, escalate to C with tenant-specific
   719	      override. Pseudonymization implementation lands in W4-polish slice.
   720	    production_use_gating: |
   721	      Until pseudonymization implementation lands, production use of
   722	      cash_conductor_transactions table is GATED by an explicit per-tenant
   723	      DPA addendum signed by founder + tenant. Migration-test tenant data
   724	      is not subject to this gate.
   725	
   726	  Q5_unknown_config_keys_handling:
   727	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   728	    options:
   729	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   730	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   731	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   732	    v0_3_default: A
   733	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   734	      for forward-compat, escalate to B or C with explicit ADR.
   735	
   736	# ============================================================================
   737	# §9 — Why v0.3 is the right unblock
   738	# ============================================================================
   739	
   740	rationale: |
   741	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   742	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   743	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   744	  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys + 1
   745	  payload extension, closing those findings.
   746	
   747	  After v0.3 ratifies + migration applies:
   748	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   749	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   750	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   751	      placement_status, week_1_status_note, satisfaction_signal,
   752	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   753	      are now schema-backed. The Scribe §3 narrative still references SOME
   754	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   755	      seniority — not yet in schema; brief.start_date should be
   756	      start_date_target; opportunity.sector — not yet in schema). These
   757	      residual gaps are tracked in W4-polish-schema-extension backlog;
   758	      they do not block v0.3 ratification but do require a Scribe agent.md
   759	      consistency-pass before Scribe ratifies.
   760	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   761	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   762	    - Concierge tenant_adapters.config field refs valid
   763	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   764	
   765	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   766	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   767	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   768	  not schema gaps.
   769	
   770	# ============================================================================
   771	
   772	end_of_supplement: true

exec
/bin/zsh -lc 'rg -n "entities:|''^  (candidate|contractor|client|contact|brief|opportunity|placement|timesheet):|relationships:|agent_access_matrix:|bullhorn_mapping:" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:45:entities:
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:153:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:221:  client:
docs/verticals/recruitment/vertical-schema.yaml:283:  contact:
docs/verticals/recruitment/vertical-schema.yaml:341:  brief:
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:495:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:535:  timesheet:
docs/verticals/recruitment/vertical-schema.yaml:583:relationships:
docs/verticals/recruitment/vertical-schema.yaml:669:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:739:bullhorn_mapping:
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:754:  client:
docs/verticals/recruitment/vertical-schema.yaml:760:  contact:
docs/verticals/recruitment/vertical-schema.yaml:765:  brief:
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:777:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:783:  timesheet:
docs/verticals/recruitment/vertical-schema.yaml:814:  Q4_system_agents_not_entities:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:42:#   The label `entities:` below is a YAML key (the schema-document convention from
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:53:entities:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:303:  contact:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:311:  brief:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:319:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:339:additional_relationships:

codex
REJECTED

1. `placement.week_1_status_note` stores narrative content in Postgres. Lines 176-183 define a `string` field as “Free-text narrative from 7d check-in call” and say it is “Stored verbatim”; that violates the Vault/Postgres split, where narrative content belongs in vault and Postgres should hold structured state or links. Proposed fix: store the check-in narrative in vault/Bullhorn Note and keep only a structured status enum, summary signal, or vault/note reference in `entities.data`.

2. The bounded confidence metric is declared without the required SQL constraint or trigger. Lines 573-606 add `decision_log_payload_extension.per_claim_confidence_distribution.mean_confidence` with validation `[0.0, 1.0]`, but explicitly defer enforcement to a W4 writer extension rather than the v0.3 migration. `review-schema-change` §3 requires `[0.0, 1.0]` bounded values to have a CHECK constraint or trigger. Proposed fix: add a v0.3 migration trigger/check path for this payload invariant, or remove the field from v0.3 until the enforcing writer ships.

3. The supplement overclaims field-level access enforcement. Lines 307-310 say `validate_entities_data_v0_3` “enforces field-level writes” while also admitting there is no separate field-level permission layer; the companion migration only validates JSON shape/enums/lengths, not which agent is writing. This is an honest-signal and quality-gate issue because the access matrix reads as enforceable when it is only documentary. Proposed fix: change the claim to “validates field shape only” and name the actual enforcement point, or implement app/DB enforcement for agent-level write permissions.
tokens used
45,124
REJECTED

1. `placement.week_1_status_note` stores narrative content in Postgres. Lines 176-183 define a `string` field as “Free-text narrative from 7d check-in call” and say it is “Stored verbatim”; that violates the Vault/Postgres split, where narrative content belongs in vault and Postgres should hold structured state or links. Proposed fix: store the check-in narrative in vault/Bullhorn Note and keep only a structured status enum, summary signal, or vault/note reference in `entities.data`.

2. The bounded confidence metric is declared without the required SQL constraint or trigger. Lines 573-606 add `decision_log_payload_extension.per_claim_confidence_distribution.mean_confidence` with validation `[0.0, 1.0]`, but explicitly defer enforcement to a W4 writer extension rather than the v0.3 migration. `review-schema-change` §3 requires `[0.0, 1.0]` bounded values to have a CHECK constraint or trigger. Proposed fix: add a v0.3 migration trigger/check path for this payload invariant, or remove the field from v0.3 until the enforcing writer ships.

3. The supplement overclaims field-level access enforcement. Lines 307-310 say `validate_entities_data_v0_3` “enforces field-level writes” while also admitting there is no separate field-level permission layer; the companion migration only validates JSON shape/enums/lengths, not which agent is writing. This is an honest-signal and quality-gate issue because the access matrix reads as enforceable when it is only documentary. Proposed fix: change the claim to “validates field shape only” and name the actual enforcement point, or implement app/DB enforcement for agent-level write permissions.
