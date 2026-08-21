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
# Date:   2026-05-24 (Day 19 of bilateral disposition execution)
# Author: Founder (Maddox) + Claude Code, post-Round-8 Cat-β categorization
# Predecessor: docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml (Day 8)
#
# Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
# Concierge) — schema-supplement-needed items that block re-ratification of those
# agent.md scaffolds. Documented in:
# `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4
# Cat-β section.
#
# Companion: docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql + v0.3-to-v0.2.sql
#   Forward + rollback drafted alongside.
#
# Layer over v0.1 (8 entities) + v0.2 (3 voice/edit auxiliary tables + 6 voice
# score fields). v0.3 adds:
#   §1 — 14 new entity.data field additions across candidate + contact + brief +
#        placement + opportunity (per Scribe Round-8 finding #1)
#   §2 — Scribe access matrix expansion (Contact none→R+W; Brief R→R+W; per
#        Scribe Round-8 finding #2)
#   §3 — Janitor candidate.linkedin_url addition + Janitor access added to
#        recent_edit + tone_rule v1_0_agent_access (per Janitor Round-8 finding #3)
#   §4 — 2 new auxiliary Postgres tables for Cash Conductor: cash_conductor_transactions
#        + cash_conductor_invoices (per Cash Conductor Round-8 finding #2)
#   §5 — tenant_adapters.config field additions: cash_conductor_last_run +
#        concierge_last_poll + concierge_send_window + diagnostic_per_claim_sample_rate
#   §6 — decision_log.payload extension for per_claim_confidence_distribution
#        (per ADR-006 W4-polish prerequisite)
# ============================================================================

vertical: recruitment
version: v0.3
supplements: v0.2
status: Proposed
date: 2026-05-24
author: founder (Maddox) + Claude Code, post-bilateral Cat-β unblock
codex_ratification_queue_position: 44  # after v0.2 supplement (29) + post-bilateral-extension catalogue commits (5e59f9c, cbef6b5, etc.)

# ============================================================================
# §1 — New entity.data field additions (14 fields across 5 entities)
# ============================================================================
#
# Per Scribe agent.md §3 Round-8 finding #1: ~12 fields claimed verbatim in
# the canonical entity-field table do not exist in v0.1/v0.2 schema. v0.3
# adds them as entities.data JSONB keys per Day-4 §6.3 generic primitive
# layer (NOT as auxiliary tables; these are first-class domain attributes).
# Plus the headcount_growth_signal_text / hiring_velocity_band /
# decision_window_text on opportunity.

candidate_field_additions:
  v0_1_existing_relevant:
    - current_role          # already exists at line 104
    - notice_period_weeks   # already exists at line 133
    - salary_expectation_min  # already exists at line 116
    - salary_expectation_max  # already exists at line 120

  v0_3_new:
    employment_type:
      type: enum
      values: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
      required: false
      notes: |
        Extracted by Scribe from call context. Distinct from candidate.contract_type
        (v0.1 line ~145 if present) which is about role type; employment_type is
        about candidate's *preferred* engagement model. IR35 distinction matters
        for UK contractors.
      source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3 + call context)
      v1_0_agent_access:
        - Scribe (W)
        - Sourcing Scout (R for filter matching)

    key_skills:
      type: list_of_string
      required: false
      notes: |
        Aggregated skill tags extracted by Scribe + Sourcing Scout from CV + call
        transcripts. Free-text strings; W4 polish may add controlled-vocabulary
        clustering. Max 20 items per candidate; oldest pruned at v1.1.
      source: IFOS-derived (Scribe extracts from CV + transcripts; Sourcing Scout from CV-Library + Reed search results)
      v1_0_agent_access:
        - Scribe (W)
        - Sourcing Scout (R+W)

contact_field_additions:
  v0_1_existing_relevant:
    - decision_authority    # already exists at line 316 (enum: yes/no/influencer/blocker/unknown per Q5)

  v0_3_new:
    preferred_channel:
      type: enum
      values: [email, phone, sms, teams, slack, in_person, unknown]
      required: false
      default: unknown
      notes: |
        Extracted by Scribe from call context (consultant notes contact's stated
        preference). Concierge reads to route outbound lifecycle comms.
      source: IFOS-derived (Scribe extraction)
      v1_0_agent_access:
        - Scribe (R+W)
        - Concierge (R)

    next_action_target_date:
      type: date
      required: false
      notes: |
        ISO-8601 date. Set by Scribe at call-end when "I'll follow up by X" is in
        transcript. Concierge respects this when scheduling lifecycle nurture.
      source: IFOS-derived (Scribe extraction)
      v1_0_agent_access:
        - Scribe (R+W)
        - Concierge (R)

brief_field_additions:
  v0_1_existing_relevant:
    - salary_min  # already exists at line ~371
    - salary_max  # already exists at line ~376
    - start_date  # already exists at line ~395

  v0_3_new:
    must_haves:
      type: list_of_string
      required: false
      notes: |
        Hard requirements; Sourcing Scout filters candidates against this list.
        Scribe extracts from briefing-call transcripts. Free-text strings; max
        15 items; W4 polish may add controlled-vocabulary clustering.
      source: IFOS-derived (Scribe extracts)
      v1_0_agent_access:
        - Scribe (R+W)
        - Sourcing Scout (R)

    nice_to_haves:
      type: list_of_string
      required: false
      notes: |
        Soft preferences; Sourcing Scout uses for ranking, not hard filter.
      source: IFOS-derived (Scribe extracts)
      v1_0_agent_access:
        - Scribe (R+W)
        - Sourcing Scout (R)

    deal_breakers:
      type: list_of_string
      required: false
      notes: |
        Anti-requirements; Sourcing Scout EXCLUDES candidates matching any item.
      source: IFOS-derived (Scribe extracts)
      v1_0_agent_access:
        - Scribe (R+W)
        - Sourcing Scout (R)

placement_field_additions:
  v0_1_existing_relevant:
    - start_date  # already on placement entity

  v0_3_new:
    placement_status:
      type: enum
      values: [pending_start, active, completed, terminated_early, on_hold, cancelled]
      required: false
      default: pending_start
      notes: |
        Lifecycle state tracking. Scribe sets to 'active' at 7-day check-in
        confirming candidate started. Janitor flags ambiguous states via
        ESC_LIFECYCLE_STATE_UNKNOWN.
      source: IFOS-derived (Scribe + Janitor)
      v1_0_agent_access:
        - Scribe (R+W)
        - Janitor (R+W)
        - Concierge (R for nurture timing)

    week_1_status_note:
      type: text
      required: false
      max_length: 500
      notes: |
        Free-text narrative captured by Scribe at 7-day check-in call. Stored
        verbatim; voice-classifier review at write time per §7 of Scribe agent.md.
      source: IFOS-derived (Scribe extracts from 7d check-in call)
      v1_0_agent_access:
        - Scribe (R+W)
        - Concierge (R for 30d/90d follow-up framing)

    satisfaction_signal:
      type: enum
      values: [positive, neutral, negative, unclear]
      required: false
      default: unclear
      notes: |
        Scribe's inference from 7d/30d/90d check-in call sentiment. Concierge
        reads to adjust nurture tone (positive → relationship-builder, negative
        → operator-escalation).
      source: IFOS-derived (Scribe extraction with LLM sentiment classifier)
      v1_0_agent_access:
        - Scribe (R+W)
        - Concierge (R)

opportunity_field_additions:
  v0_1_existing_relevant: []

  v0_3_new:
    headcount_growth_signal_text:
      type: text
      required: false
      max_length: 280
      notes: |
        Free-text capture by Scribe of growth-signal phrases from prospecting
        calls ("we're hiring 5 engineers this quarter", "scaling the team 2x
        by year-end"). Sourcing Scout reads to ICP-fit-score opportunities.
      source: IFOS-derived (Scribe extraction)
      v1_0_agent_access:
        - Scribe (R+W)
        - Sourcing Scout (R)

    hiring_velocity_band:
      type: enum
      values: [slow, moderate, fast, urgent, unknown]
      required: false
      default: unknown
      notes: |
        Scribe's inference from prospecting-call urgency cues. Drives ranking
        in Sourcing Scout's brief-to-candidate pipeline.
      source: IFOS-derived (Scribe LLM classification)
      v1_0_agent_access:
        - Scribe (R+W)
        - Sourcing Scout (R)

    decision_window_text:
      type: text
      required: false
      max_length: 280
      notes: |
        Free-text capture by Scribe of decision-timing phrases ("we need someone
        starting in Q3", "decision by end of week"). Concierge reads to time
        outbound comms.
      source: IFOS-derived (Scribe extraction)
      v1_0_agent_access:
        - Scribe (R+W)
        - Concierge (R)

# ============================================================================
# §2 — Scribe access matrix expansion
# ============================================================================
#
# Per Scribe agent.md §3 Round-8 finding #2: Scribe writes to Contact, Brief,
# and Opportunity in v1.0 cycle.sh per agent.md §4 Steps 5-9; current v0.1
# matrix gives Scribe `contact: none`, `brief: R`, `opportunity: none`.
# v0.3 expands these to match actual Scribe write paths.

scribe_access_matrix_changes:
  contact:
    v0_1: none
    v0_3: R+W
    rationale: |
      Scribe writes preferred_channel + next_action_target_date + decision_authority
      updates from call context. Per §6 (Scribe agent.md §4 Step 5-9).
    new_writable_fields:
      - preferred_channel  # v0.3-added
      - next_action_target_date  # v0.3-added
      - decision_authority  # already exists; v0.3 grants Scribe write access

  brief:
    v0_1: R
    v0_3: R+W
    rationale: |
      Scribe writes must_haves + nice_to_haves + deal_breakers + structured-field
      updates from briefing-call transcripts. Per Ultraplan §8.1 A3 line 524 verbatim
      ("≥3 structured-field extractions"); Brief is a primary write target.
    new_writable_fields:
      - must_haves  # v0.3-added
      - nice_to_haves  # v0.3-added
      - deal_breakers  # v0.3-added
      - salary_min  # v0.1; v0.3 grants Scribe write
      - salary_max  # v0.1; v0.3 grants Scribe write
      - start_date  # v0.1; v0.3 grants Scribe write

  opportunity:
    v0_1: none
    v0_3: R+W
    rationale: |
      Scribe writes headcount_growth_signal_text + hiring_velocity_band +
      decision_window_text from prospecting-call transcripts.
    new_writable_fields:
      - headcount_growth_signal_text  # v0.3-added
      - hiring_velocity_band  # v0.3-added
      - decision_window_text  # v0.3-added

# ============================================================================
# §3 — Janitor schema-access additions
# ============================================================================
#
# Per Janitor agent.md Round-8 finding #1 (candidate.linkedin_url missing) +
# Round-8 finding #3 (Janitor reads recent_edit + tone_rule but v0.2 doesn't
# grant access).

candidate_linkedin_url_addition:
  v0_3_new:
    linkedin_url:
      type: text  # URL
      required: false
      pattern: '^https://(www\.|uk\.|[a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
      notes: |
        LinkedIn profile URL. Set by Sourcing Scout from candidate matching;
        Janitor uses for dedup (LinkedIn URL is a stronger match signal than
        name + email alone). Concierge reads for outreach context (NOT for
        outbound; outreach is via candidate.email or candidate.phone).
      source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
      v1_0_agent_access:
        - Sourcing Scout (R+W)
        - Janitor (R for dedup; W only via dedup-merge)
        - Concierge (R)

janitor_v0_2_table_access_expansion:
  recent_edit:
    v0_2: [voice-drift-canary (W), Concierge (R), LoRA (R)]
    v0_3: [voice-drift-canary (W), Concierge (R), Janitor (R), LoRA (R)]
    rationale: |
      Janitor agent.md §4 Step 8 queries recent_edit for tacit-note harvest
      (rows with resolution='approved_after_edit'). Per Round-8 finding #3.

  tone_rule:
    v0_2: [Scribe (R), Cash Conductor (R), Concierge (R)]
    v0_3: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R)]
    rationale: |
      Janitor agent.md §7 calls hh_load_tone_rules filtered by
      applies_to_agents containing 'janitor' for tacit-note narrative
      voice-classification.

# ============================================================================
# §4 — Cash Conductor auxiliary Postgres tables (NOT entities)
# ============================================================================
#
# Per Cash Conductor agent.md Round-8 finding #2 + the v0.2-pattern of
# auxiliary tables for state that doesn't fit the entity model (similar
# to v0.2's voice_corpus + tone_rule + recent_edit).

cash_conductor_transactions:
  type: auxiliary_postgres_table
  rationale: |
    Open Banking transactions are high-volume, time-series, and don't model
    well as entity.data JSONB rows. v0.3 introduces a first-class table with
    indexes for date + amount + match-status. Per Cash Conductor agent.md
    §4 Step 3 + ADR-002 vault/Postgres split (structured state in Postgres).
  schema:
    id: BIGSERIAL PRIMARY KEY
    tenant_slug: TEXT NOT NULL  # RLS-isolated per Day-4 §6.3
    transaction_id: TEXT NOT NULL  # provider-supplied (TrueLayer / Plaid)
    posted_at: TIMESTAMPTZ NOT NULL
    amount: NUMERIC(15, 2) NOT NULL  # GBP; negative for outgoing
    currency: TEXT NOT NULL DEFAULT 'GBP'
    payee_name_raw: TEXT  # as supplied by Open Banking
    description: TEXT
    bank_provider: TEXT  # 'truelayer' | 'plaid_uk' | 'open_banking_direct'
    match_status: TEXT  # 'unmatched' | 'matched' | 'ambiguous'
    matched_invoice_id: TEXT  # FK to cash_conductor_invoices.invoice_id when match_status='matched'
    match_confidence: NUMERIC(3, 2)  # 0.00-1.00; per Cash Conductor §3 Output 1 stages
    match_dimensions: TEXT[]  # ['exact_amount', 'payee_match', 'within_90d_window', etc.]
    ingested_at: TIMESTAMPTZ NOT NULL DEFAULT now()
    raw_payload: JSONB  # full Open Banking response for audit
  indexes:
    - "(tenant_slug, posted_at DESC)"  # tenant scan
    - "(tenant_slug, match_status, posted_at DESC)"  # unmatched queue
  rls_policy: |
    CREATE POLICY tenant_isolation ON cash_conductor_transactions
    FOR ALL TO ifos_app
    USING (tenant_slug = current_setting('app.current_tenant', true));
  retention: |
    90-day rolling window for unmatched + ambiguous rows; matched rows retained
    indefinitely (audit trail). Pre-90-day matched-only stored to cold archive
    at v1.1+.

cash_conductor_invoices:
  type: auxiliary_postgres_table
  rationale: |
    Open invoice register cached from accounting provider (Xero / QuickBooks /
    Sage). Same auxiliary-table pattern as transactions. Per Cash Conductor
    agent.md §4 Step 4.
  schema:
    id: BIGSERIAL PRIMARY KEY
    tenant_slug: TEXT NOT NULL
    invoice_id: TEXT NOT NULL  # accounting-provider-supplied ID
    accounting_provider: TEXT NOT NULL  # 'xero' | 'quickbooks' | 'sage'
    invoice_number: TEXT
    issued_at: TIMESTAMPTZ NOT NULL
    due_at: TIMESTAMPTZ NOT NULL
    amount_total: NUMERIC(15, 2) NOT NULL
    amount_paid: NUMERIC(15, 2) NOT NULL DEFAULT 0
    currency: TEXT NOT NULL DEFAULT 'GBP'
    status: TEXT  # 'open' | 'partial' | 'paid' | 'overdue' | 'cancelled' | 'voided'
    client_contact_id: TEXT  # links to Bullhorn placement.client_contact_id when known
    client_billing_email: TEXT
    last_chase_position: INT DEFAULT 0  # 0 = no chases; 1-3 = position per §3.2; 4 = operator-handled
    last_chase_sent_at: TIMESTAMPTZ
    ingested_at: TIMESTAMPTZ NOT NULL DEFAULT now()
    raw_payload: JSONB
  indexes:
    - "(tenant_slug, due_at)"  # aged-debtors query
    - "(tenant_slug, status, due_at)"  # overdue scan
    - "(tenant_slug, last_chase_position, due_at)"  # chase pipeline
  rls_policy: |
    CREATE POLICY tenant_isolation ON cash_conductor_invoices
    FOR ALL TO ifos_app
    USING (tenant_slug = current_setting('app.current_tenant', true));
  retention: |
    Paid invoices retained 7 years (UK statutory accounting record retention).
    Cancelled / voided retained 90 days post-cancel.

# ============================================================================
# §5 — tenant_adapters.config field additions
# ============================================================================
#
# Per Cash Conductor Round-8 finding #2 + Concierge Round-8 finding #7. The
# tenant_adapters table (Day-4 §6.3 + v0.2 §3 if defined there) has a JSONB
# config column; v0.3 codifies the keys agents read.

tenant_adapters_config_additions:
  cash_conductor_last_run:
    type: timestamptz
    required: false
    default: null
    set_by: cash_conductor
    read_by: [cash_conductor]
    notes: |
      Cash Conductor cron sweep updates this at session-close (per agent.md §4
      Step 14). On next run, cycle.sh queries transactions/invoices since this
      timestamp.

  concierge_last_poll:
    type: timestamptz
    required: false
    default: null
    set_by: concierge
    read_by: [concierge]
    notes: |
      Concierge polling cron updates this at end of each poll cycle (per
      agent.md §4 Step 1 mode=poll). On next poll, query Bullhorn for state
      transitions since this timestamp.

  concierge_send_window:
    type: object
    required: false
    default:
      timezone: Europe/London
      weekday_start: '09:00'
      weekday_end: '17:00'
      weekend_send_enabled: false
    set_by: [tenant-admin]  # via Brain UI tenant config screen
    read_by: [concierge]
    notes: |
      Per-tenant outbound sending hours. Concierge respects this when scheduling
      orange-tier sends; sends queued outside the window deferred to next
      in-window slot.

  diagnostic_per_claim_sample_rate:
    type: integer
    required: false
    default: 10
    range: [1, 100]  # 1-in-N sample rate; 10 = 10% of reports validated
    set_by: [tenant-admin]
    read_by: [diagnostic]
    notes: |
      Per ADR-006 Tier 2 (post-launch quality metric). Sample 1-in-N Diagnostic
      reports for per-claim citation validation. Activates at W4 polish when
      Tier 2 ships; until then this field is documented intent only.

# ============================================================================
# §6 — decision_log.payload extension (per ADR-006 W4-polish prerequisite)
# ============================================================================
#
# Per ADR-006 + Round-8 finding for Diagnostic. The decision_log.payload JSONB
# shape from autosend-safety-policy.md §7 is extended with a new key for
# per-claim quality metric. v0.3 supplements the payload schema; W4 polish
# implements the runtime path that writes this key.

decision_log_payload_extension:
  per_claim_confidence_distribution:
    type: object
    required: false
    written_when: |
      Tier 2 per-claim citation validation runs (sample-rate-gated; 1-in-N per
      tenant_adapters.config.diagnostic_per_claim_sample_rate).
    shape:
      total_claims: integer
      claims_with_confidence_above_0_6: integer
      claims_with_confidence_below_0_6: integer
      mean_confidence: NUMERIC(3, 2)
      sampled_at: timestamptz
      sample_rate_applied: integer  # 1-in-N at write time
    notes: |
      Aggregate metric, not per-claim detail. Per-claim detail not persisted
      to keep decision_log payload size bounded. Per-claim raw data goes to
      a separate v1.1 quality-metrics table if needed.

# ============================================================================
# §7 — Migration sequencing
# ============================================================================

migration_sequence:
  forward: docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
  rollback: docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
  pre_conditions:
    - v0.2 supplement migration applied (voice_corpus + tone_rule + recent_edit tables exist)
    - 6 voice_classifier_score / voice_drift_at_close fields present on candidate + contractor + contact + brief + opportunity + placement
  steps:
    1: "ALTER TABLE candidate ADD COLUMN data jsonb (new keys via validate-jsonb trigger): employment_type, key_skills, linkedin_url"
    2: "ALTER TABLE contact ADD: preferred_channel, next_action_target_date"
    3: "ALTER TABLE brief ADD: must_haves, nice_to_haves, deal_breakers"
    4: "ALTER TABLE placement ADD: placement_status, week_1_status_note, satisfaction_signal"
    5: "ALTER TABLE opportunity ADD: headcount_growth_signal_text, hiring_velocity_band, decision_window_text"
    6: "CREATE TABLE cash_conductor_transactions (per §4); ENABLE RLS + tenant_isolation policy"
    7: "CREATE TABLE cash_conductor_invoices (per §4); ENABLE RLS + tenant_isolation policy"
    8: "ALTER TABLE tenant_adapters: validate new config keys via JSONB validation trigger (cash_conductor_last_run, concierge_last_poll, concierge_send_window, diagnostic_per_claim_sample_rate)"
    9: "UPDATE v1_0_agent_access lists in recent_edit + tone_rule v0.2 schema to include 'janitor'"
    10: "validate.sh smoke test against migration-test tenant; expect zero failures"

# ============================================================================
# §8 — Codex ratification path
# ============================================================================

codex_ratification:
  skill: review-schema-change
  expected_round_trips: 1-2 (mechanical fixes if any)
  post-ratify_actions:
    - Apply migration SQL against migration-test tenant (Path A founder action)
    - Run tenancy-audit.sh; expect 12/12 invariants pass
    - Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge) to
      cite v0.3 supplement instead of "v0.3-supplement-pending"
    - Re-run Codex on the 4 agent.md files; expect Cat-β findings closed

# ============================================================================
# §9 — Open questions
# ============================================================================

open_questions:
  Q1_employment_type_enum_completeness:
    question: "Are the 6 employment_type enum values exhaustive for UK recruitment? Missing options: 'fixed_term_employee', 'apprenticeship', 'contract_for_services'?"
    resolution: Founder review at first-pilot onboarding; add per-tenant overrides if needed.

  Q2_key_skills_max_length:
    question: "Cap at 20 items per candidate — does it accommodate senior technical candidates with 30+ skill tags?"
    resolution: v1.0 cap at 20; revisit at first-pilot data after 30+ candidates indexed.

  Q3_placement_status_enum_lifecycle:
    question: "6-state enum — does it map to Bullhorn's native placement state machine? Risk of impedance mismatch at sync time."
    resolution: First-pilot Bullhorn schema audit at onboarding; add mapping table if Bullhorn states don't 1:1.

  Q4_cash_conductor_transactions_retention:
    question: "90-day rolling for unmatched + indefinite for matched — is indefinite UK GDPR-compatible? Bank transaction PII implications."
    resolution: Founder + legal review (placeholder; not gating v0.3 ratification). Recommended: indefinite-with-pseudonymization at year 7.

  Q5_tenant_adapters_config_validation_trigger:
    question: "JSONB validation trigger for the 4 new config keys — should it hard-fail on unknown keys, or warn-and-store-anyway?"
    resolution: Hard-fail; only documented keys may be set. Per master brief §1 Rule 2 (Schema before code).

# ============================================================================
# §10 — Why this supplement is the right unblock
# ============================================================================

rationale: |
  Round-8 categorization (per disagreement doc Phase 4 Cat-β) identified that
  4 of 5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
  Concierge) cannot re-ratify until the schema fields they reference exist
  in the canonical schema. v0.3 supplement adds the 14 entity fields + 2
  auxiliary tables + 4 config fields + 1 payload extension that close those
  findings.

  After v0.3 ratifies + migration applies:
    - Scribe agent.md §3 entity-field table becomes verifiable (was Round-8
      finding #1 + Round-8 finding #2)
    - Janitor candidate.linkedin_url reference becomes valid (was Round-8 #1)
    - Cash Conductor Postgres-tables claim in agent.md §4 Steps 3-4 becomes
      schema-backed (was Round-8 #2)
    - Concierge tenant_adapters.config field references become valid
      (was Round-8 #7)
    - Diagnostic Tier 2 schema substrate exists (per ADR-006 W4-polish)

  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
  expect ~3-5 residual findings per agent (down from current 4-6) — those
  residuals are per-agent specifics (workflow honesty, validate.sh/cycle.sh
  build slices) not schema gaps.

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
