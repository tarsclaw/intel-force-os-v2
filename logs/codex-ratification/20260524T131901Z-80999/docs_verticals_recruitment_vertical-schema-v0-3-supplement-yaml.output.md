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
session id: 019e5a23-9541-7233-9fdd-cf9671292b6c
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

exec
/bin/zsh -lc 'ls -l docs/verticals/recruitment/migrations docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.yaml 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
-rw-r--r--@ 1 madsadmin  staff  26369 May 22 16:17 docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
-rw-r--r--@ 1 madsadmin  staff  25785 May 24 14:18 docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
-rw-r--r--@ 1 madsadmin  staff  46985 May 20 13:48 docs/verticals/recruitment/vertical-schema.yaml

docs/verticals/recruitment/migrations:
total 64
-rw-r--r--@ 1 madsadmin  staff  16182 May 23 14:21 v0.1-to-v0.2.sql
-rw-r--r--@ 1 madsadmin  staff   2182 May 20 11:44 v0.2-to-v0.1.sql
-rw-r--r--@ 1 madsadmin  staff   4716 May 22 14:29 v0.2-to-v0.3-pii-purge.sql
-rw-r--r--@ 1 madsadmin  staff   1229 May 22 14:29 v0.3-to-v0.2-pii-purge.sql

exec
/bin/zsh -lc 'rg -n "CREATE TABLE cash_conductor|ALTER TABLE candidate|candidate_linkedin_url|employment_type|open_questions|per_claim_confidence_distribution|cash_conductor_transactions|cash_conductor_invoices" docs/verticals/recruitment -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:382:open_questions_v0_2_additions:
docs/verticals/recruitment/vertical-schema.yaml:795:open_questions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:25:#   §4 — 2 new auxiliary Postgres tables for Cash Conductor: cash_conductor_transactions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:26:#        + cash_conductor_invoices (per Cash Conductor Round-8 finding #2)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:29:#   §6 — decision_log.payload extension for per_claim_confidence_distribution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:60:    employment_type:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:66:        (v0.1 line ~145 if present) which is about role type; employment_type is
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:298:candidate_linkedin_url_addition:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:339:cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:357:    matched_invoice_id: TEXT  # FK to cash_conductor_invoices.invoice_id when match_status='matched'
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:366:    CREATE POLICY tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:374:cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:    CREATE POLICY tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:478:  per_claim_confidence_distribution:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:507:    1: "ALTER TABLE candidate ADD COLUMN data jsonb (new keys via validate-jsonb trigger): employment_type, key_skills, linkedin_url"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:512:    6: "CREATE TABLE cash_conductor_transactions (per §4); ENABLE RLS + tenant_isolation policy"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:513:    7: "CREATE TABLE cash_conductor_invoices (per §4); ENABLE RLS + tenant_isolation policy"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:536:open_questions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:537:  Q1_employment_type_enum_completeness:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:538:    question: "Are the 6 employment_type enum values exhaustive for UK recruitment? Missing options: 'fixed_term_employee', 'apprenticeship', 'contract_for_services'?"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:549:  Q4_cash_conductor_transactions_retention:

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '290,430p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '130,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   290	# ============================================================================
   291	# §3 — Janitor schema-access additions
   292	# ============================================================================
   293	#
   294	# Per Janitor agent.md Round-8 finding #1 (candidate.linkedin_url missing) +
   295	# Round-8 finding #3 (Janitor reads recent_edit + tone_rule but v0.2 doesn't
   296	# grant access).
   297	
   298	candidate_linkedin_url_addition:
   299	  v0_3_new:
   300	    linkedin_url:
   301	      type: text  # URL
   302	      required: false
   303	      pattern: '^https://(www\.|uk\.|[a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
   304	      notes: |
   305	        LinkedIn profile URL. Set by Sourcing Scout from candidate matching;
   306	        Janitor uses for dedup (LinkedIn URL is a stronger match signal than
   307	        name + email alone). Concierge reads for outreach context (NOT for
   308	        outbound; outreach is via candidate.email or candidate.phone).
   309	      source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
   310	      v1_0_agent_access:
   311	        - Sourcing Scout (R+W)
   312	        - Janitor (R for dedup; W only via dedup-merge)
   313	        - Concierge (R)
   314	
   315	janitor_v0_2_table_access_expansion:
   316	  recent_edit:
   317	    v0_2: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   318	    v0_3: [voice-drift-canary (W), Concierge (R), Janitor (R), LoRA (R)]
   319	    rationale: |
   320	      Janitor agent.md §4 Step 8 queries recent_edit for tacit-note harvest
   321	      (rows with resolution='approved_after_edit'). Per Round-8 finding #3.
   322	
   323	  tone_rule:
   324	    v0_2: [Scribe (R), Cash Conductor (R), Concierge (R)]
   325	    v0_3: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R)]
   326	    rationale: |
   327	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   328	      applies_to_agents containing 'janitor' for tacit-note narrative
   329	      voice-classification.
   330	
   331	# ============================================================================
   332	# §4 — Cash Conductor auxiliary Postgres tables (NOT entities)
   333	# ============================================================================
   334	#
   335	# Per Cash Conductor agent.md Round-8 finding #2 + the v0.2-pattern of
   336	# auxiliary tables for state that doesn't fit the entity model (similar
   337	# to v0.2's voice_corpus + tone_rule + recent_edit).
   338	
   339	cash_conductor_transactions:
   340	  type: auxiliary_postgres_table
   341	  rationale: |
   342	    Open Banking transactions are high-volume, time-series, and don't model
   343	    well as entity.data JSONB rows. v0.3 introduces a first-class table with
   344	    indexes for date + amount + match-status. Per Cash Conductor agent.md
   345	    §4 Step 3 + ADR-002 vault/Postgres split (structured state in Postgres).
   346	  schema:
   347	    id: BIGSERIAL PRIMARY KEY
   348	    tenant_slug: TEXT NOT NULL  # RLS-isolated per Day-4 §6.3
   349	    transaction_id: TEXT NOT NULL  # provider-supplied (TrueLayer / Plaid)
   350	    posted_at: TIMESTAMPTZ NOT NULL
   351	    amount: NUMERIC(15, 2) NOT NULL  # GBP; negative for outgoing
   352	    currency: TEXT NOT NULL DEFAULT 'GBP'
   353	    payee_name_raw: TEXT  # as supplied by Open Banking
   354	    description: TEXT
   355	    bank_provider: TEXT  # 'truelayer' | 'plaid_uk' | 'open_banking_direct'
   356	    match_status: TEXT  # 'unmatched' | 'matched' | 'ambiguous'
   357	    matched_invoice_id: TEXT  # FK to cash_conductor_invoices.invoice_id when match_status='matched'
   358	    match_confidence: NUMERIC(3, 2)  # 0.00-1.00; per Cash Conductor §3 Output 1 stages
   359	    match_dimensions: TEXT[]  # ['exact_amount', 'payee_match', 'within_90d_window', etc.]
   360	    ingested_at: TIMESTAMPTZ NOT NULL DEFAULT now()
   361	    raw_payload: JSONB  # full Open Banking response for audit
   362	  indexes:
   363	    - "(tenant_slug, posted_at DESC)"  # tenant scan
   364	    - "(tenant_slug, match_status, posted_at DESC)"  # unmatched queue
   365	  rls_policy: |
   366	    CREATE POLICY tenant_isolation ON cash_conductor_transactions
   367	    FOR ALL TO ifos_app
   368	    USING (tenant_slug = current_setting('app.current_tenant', true));
   369	  retention: |
   370	    90-day rolling window for unmatched + ambiguous rows; matched rows retained
   371	    indefinitely (audit trail). Pre-90-day matched-only stored to cold archive
   372	    at v1.1+.
   373	
   374	cash_conductor_invoices:
   375	  type: auxiliary_postgres_table
   376	  rationale: |
   377	    Open invoice register cached from accounting provider (Xero / QuickBooks /
   378	    Sage). Same auxiliary-table pattern as transactions. Per Cash Conductor
   379	    agent.md §4 Step 4.
   380	  schema:
   381	    id: BIGSERIAL PRIMARY KEY
   382	    tenant_slug: TEXT NOT NULL
   383	    invoice_id: TEXT NOT NULL  # accounting-provider-supplied ID
   384	    accounting_provider: TEXT NOT NULL  # 'xero' | 'quickbooks' | 'sage'
   385	    invoice_number: TEXT
   386	    issued_at: TIMESTAMPTZ NOT NULL
   387	    due_at: TIMESTAMPTZ NOT NULL
   388	    amount_total: NUMERIC(15, 2) NOT NULL
   389	    amount_paid: NUMERIC(15, 2) NOT NULL DEFAULT 0
   390	    currency: TEXT NOT NULL DEFAULT 'GBP'
   391	    status: TEXT  # 'open' | 'partial' | 'paid' | 'overdue' | 'cancelled' | 'voided'
   392	    client_contact_id: TEXT  # links to Bullhorn placement.client_contact_id when known
   393	    client_billing_email: TEXT
   394	    last_chase_position: INT DEFAULT 0  # 0 = no chases; 1-3 = position per §3.2; 4 = operator-handled
   395	    last_chase_sent_at: TIMESTAMPTZ
   396	    ingested_at: TIMESTAMPTZ NOT NULL DEFAULT now()
   397	    raw_payload: JSONB
   398	  indexes:
   399	    - "(tenant_slug, due_at)"  # aged-debtors query
   400	    - "(tenant_slug, status, due_at)"  # overdue scan
   401	    - "(tenant_slug, last_chase_position, due_at)"  # chase pipeline
   402	  rls_policy: |
   403	    CREATE POLICY tenant_isolation ON cash_conductor_invoices
   404	    FOR ALL TO ifos_app
   405	    USING (tenant_slug = current_setting('app.current_tenant', true));
   406	  retention: |
   407	    Paid invoices retained 7 years (UK statutory accounting record retention).
   408	    Cancelled / voided retained 90 days post-cancel.
   409	
   410	# ============================================================================
   411	# §5 — tenant_adapters.config field additions
   412	# ============================================================================
   413	#
   414	# Per Cash Conductor Round-8 finding #2 + Concierge Round-8 finding #7. The
   415	# tenant_adapters table (Day-4 §6.3 + v0.2 §3 if defined there) has a JSONB
   416	# config column; v0.3 codifies the keys agents read.
   417	
   418	tenant_adapters_config_additions:
   419	  cash_conductor_last_run:
   420	    type: timestamptz
   421	    required: false
   422	    default: null
   423	    set_by: cash_conductor
   424	    read_by: [cash_conductor]
   425	    notes: |
   426	      Cash Conductor cron sweep updates this at session-close (per agent.md §4
   427	      Step 14). On next run, cycle.sh queries transactions/invoices since this
   428	      timestamp.
   429	
   430	  concierge_last_poll:

 succeeded in 0ms:
   130	      v1_0_agent_access:
   131	        - Scribe (R+W)
   132	        - Sourcing Scout (R)
   133	
   134	    nice_to_haves:
   135	      type: list_of_string
   136	      required: false
   137	      notes: |
   138	        Soft preferences; Sourcing Scout uses for ranking, not hard filter.
   139	      source: IFOS-derived (Scribe extracts)
   140	      v1_0_agent_access:
   141	        - Scribe (R+W)
   142	        - Sourcing Scout (R)
   143	
   144	    deal_breakers:
   145	      type: list_of_string
   146	      required: false
   147	      notes: |
   148	        Anti-requirements; Sourcing Scout EXCLUDES candidates matching any item.
   149	      source: IFOS-derived (Scribe extracts)
   150	      v1_0_agent_access:
   151	        - Scribe (R+W)
   152	        - Sourcing Scout (R)
   153	
   154	placement_field_additions:
   155	  v0_1_existing_relevant:
   156	    - start_date  # already on placement entity
   157	
   158	  v0_3_new:
   159	    placement_status:
   160	      type: enum
   161	      values: [pending_start, active, completed, terminated_early, on_hold, cancelled]
   162	      required: false
   163	      default: pending_start
   164	      notes: |
   165	        Lifecycle state tracking. Scribe sets to 'active' at 7-day check-in
   166	        confirming candidate started. Janitor flags ambiguous states via
   167	        ESC_LIFECYCLE_STATE_UNKNOWN.
   168	      source: IFOS-derived (Scribe + Janitor)
   169	      v1_0_agent_access:
   170	        - Scribe (R+W)
   171	        - Janitor (R+W)
   172	        - Concierge (R for nurture timing)
   173	
   174	    week_1_status_note:
   175	      type: text
   176	      required: false
   177	      max_length: 500
   178	      notes: |
   179	        Free-text narrative captured by Scribe at 7-day check-in call. Stored
   180	        verbatim; voice-classifier review at write time per §7 of Scribe agent.md.
   181	      source: IFOS-derived (Scribe extracts from 7d check-in call)
   182	      v1_0_agent_access:
   183	        - Scribe (R+W)
   184	        - Concierge (R for 30d/90d follow-up framing)
   185	
   186	    satisfaction_signal:
   187	      type: enum
   188	      values: [positive, neutral, negative, unclear]
   189	      required: false
   190	      default: unclear
   191	      notes: |
   192	        Scribe's inference from 7d/30d/90d check-in call sentiment. Concierge
   193	        reads to adjust nurture tone (positive → relationship-builder, negative
   194	        → operator-escalation).
   195	      source: IFOS-derived (Scribe extraction with LLM sentiment classifier)
   196	      v1_0_agent_access:
   197	        - Scribe (R+W)
   198	        - Concierge (R)
   199	
   200	opportunity_field_additions:
   201	  v0_1_existing_relevant: []
   202	
   203	  v0_3_new:
   204	    headcount_growth_signal_text:
   205	      type: text
   206	      required: false
   207	      max_length: 280
   208	      notes: |
   209	        Free-text capture by Scribe of growth-signal phrases from prospecting
   210	        calls ("we're hiring 5 engineers this quarter", "scaling the team 2x
   211	        by year-end"). Sourcing Scout reads to ICP-fit-score opportunities.
   212	      source: IFOS-derived (Scribe extraction)
   213	      v1_0_agent_access:
   214	        - Scribe (R+W)
   215	        - Sourcing Scout (R)
   216	
   217	    hiring_velocity_band:
   218	      type: enum
   219	      values: [slow, moderate, fast, urgent, unknown]
   220	      required: false

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '55,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    55	    - notice_period_weeks   # already exists at line 133
    56	    - salary_expectation_min  # already exists at line 116
    57	    - salary_expectation_max  # already exists at line 120
    58	
    59	  v0_3_new:
    60	    employment_type:
    61	      type: enum
    62	      values: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
    63	      required: false
    64	      notes: |
    65	        Extracted by Scribe from call context. Distinct from candidate.contract_type
    66	        (v0.1 line ~145 if present) which is about role type; employment_type is
    67	        about candidate's *preferred* engagement model. IR35 distinction matters
    68	        for UK contractors.
    69	      source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3 + call context)
    70	      v1_0_agent_access:
    71	        - Scribe (W)
    72	        - Sourcing Scout (R for filter matching)
    73	
    74	    key_skills:
    75	      type: list_of_string
    76	      required: false
    77	      notes: |
    78	        Aggregated skill tags extracted by Scribe + Sourcing Scout from CV + call
    79	        transcripts. Free-text strings; W4 polish may add controlled-vocabulary
    80	        clustering. Max 20 items per candidate; oldest pruned at v1.1.
    81	      source: IFOS-derived (Scribe extracts from CV + transcripts; Sourcing Scout from CV-Library + Reed search results)
    82	      v1_0_agent_access:
    83	        - Scribe (W)
    84	        - Sourcing Scout (R+W)
    85	
    86	contact_field_additions:
    87	  v0_1_existing_relevant:
    88	    - decision_authority    # already exists at line 316 (enum: yes/no/influencer/blocker/unknown per Q5)
    89	
    90	  v0_3_new:
    91	    preferred_channel:
    92	      type: enum
    93	      values: [email, phone, sms, teams, slack, in_person, unknown]
    94	      required: false
    95	      default: unknown
    96	      notes: |
    97	        Extracted by Scribe from call context (consultant notes contact's stated
    98	        preference). Concierge reads to route outbound lifecycle comms.
    99	      source: IFOS-derived (Scribe extraction)
   100	      v1_0_agent_access:
   101	        - Scribe (R+W)
   102	        - Concierge (R)
   103	
   104	    next_action_target_date:
   105	      type: date
   106	      required: false
   107	      notes: |
   108	        ISO-8601 date. Set by Scribe at call-end when "I'll follow up by X" is in
   109	        transcript. Concierge respects this when scheduling lifecycle nurture.
   110	      source: IFOS-derived (Scribe extraction)
   111	      v1_0_agent_access:
   112	        - Scribe (R+W)
   113	        - Concierge (R)
   114	
   115	brief_field_additions:
   116	  v0_1_existing_relevant:
   117	    - salary_min  # already exists at line ~371
   118	    - salary_max  # already exists at line ~376
   119	    - start_date  # already exists at line ~395
   120	

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '470,560p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   470	# ============================================================================
   471	#
   472	# Per ADR-006 + Round-8 finding for Diagnostic. The decision_log.payload JSONB
   473	# shape from autosend-safety-policy.md §7 is extended with a new key for
   474	# per-claim quality metric. v0.3 supplements the payload schema; W4 polish
   475	# implements the runtime path that writes this key.
   476	
   477	decision_log_payload_extension:
   478	  per_claim_confidence_distribution:
   479	    type: object
   480	    required: false
   481	    written_when: |
   482	      Tier 2 per-claim citation validation runs (sample-rate-gated; 1-in-N per
   483	      tenant_adapters.config.diagnostic_per_claim_sample_rate).
   484	    shape:
   485	      total_claims: integer
   486	      claims_with_confidence_above_0_6: integer
   487	      claims_with_confidence_below_0_6: integer
   488	      mean_confidence: NUMERIC(3, 2)
   489	      sampled_at: timestamptz
   490	      sample_rate_applied: integer  # 1-in-N at write time
   491	    notes: |
   492	      Aggregate metric, not per-claim detail. Per-claim detail not persisted
   493	      to keep decision_log payload size bounded. Per-claim raw data goes to
   494	      a separate v1.1 quality-metrics table if needed.
   495	
   496	# ============================================================================
   497	# §7 — Migration sequencing
   498	# ============================================================================
   499	
   500	migration_sequence:
   501	  forward: docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
   502	  rollback: docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
   503	  pre_conditions:
   504	    - v0.2 supplement migration applied (voice_corpus + tone_rule + recent_edit tables exist)
   505	    - 6 voice_classifier_score / voice_drift_at_close fields present on candidate + contractor + contact + brief + opportunity + placement
   506	  steps:
   507	    1: "ALTER TABLE candidate ADD COLUMN data jsonb (new keys via validate-jsonb trigger): employment_type, key_skills, linkedin_url"
   508	    2: "ALTER TABLE contact ADD: preferred_channel, next_action_target_date"
   509	    3: "ALTER TABLE brief ADD: must_haves, nice_to_haves, deal_breakers"
   510	    4: "ALTER TABLE placement ADD: placement_status, week_1_status_note, satisfaction_signal"
   511	    5: "ALTER TABLE opportunity ADD: headcount_growth_signal_text, hiring_velocity_band, decision_window_text"
   512	    6: "CREATE TABLE cash_conductor_transactions (per §4); ENABLE RLS + tenant_isolation policy"
   513	    7: "CREATE TABLE cash_conductor_invoices (per §4); ENABLE RLS + tenant_isolation policy"
   514	    8: "ALTER TABLE tenant_adapters: validate new config keys via JSONB validation trigger (cash_conductor_last_run, concierge_last_poll, concierge_send_window, diagnostic_per_claim_sample_rate)"
   515	    9: "UPDATE v1_0_agent_access lists in recent_edit + tone_rule v0.2 schema to include 'janitor'"
   516	    10: "validate.sh smoke test against migration-test tenant; expect zero failures"
   517	
   518	# ============================================================================
   519	# §8 — Codex ratification path
   520	# ============================================================================
   521	
   522	codex_ratification:
   523	  skill: review-schema-change
   524	  expected_round_trips: 1-2 (mechanical fixes if any)
   525	  post-ratify_actions:
   526	    - Apply migration SQL against migration-test tenant (Path A founder action)
   527	    - Run tenancy-audit.sh; expect 12/12 invariants pass
   528	    - Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge) to
   529	      cite v0.3 supplement instead of "v0.3-supplement-pending"
   530	    - Re-run Codex on the 4 agent.md files; expect Cat-β findings closed
   531	
   532	# ============================================================================
   533	# §9 — Open questions
   534	# ============================================================================
   535	
   536	open_questions:
   537	  Q1_employment_type_enum_completeness:
   538	    question: "Are the 6 employment_type enum values exhaustive for UK recruitment? Missing options: 'fixed_term_employee', 'apprenticeship', 'contract_for_services'?"
   539	    resolution: Founder review at first-pilot onboarding; add per-tenant overrides if needed.
   540	
   541	  Q2_key_skills_max_length:
   542	    question: "Cap at 20 items per candidate — does it accommodate senior technical candidates with 30+ skill tags?"
   543	    resolution: v1.0 cap at 20; revisit at first-pilot data after 30+ candidates indexed.
   544	
   545	  Q3_placement_status_enum_lifecycle:
   546	    question: "6-state enum — does it map to Bullhorn's native placement state machine? Risk of impedance mismatch at sync time."
   547	    resolution: First-pilot Bullhorn schema audit at onboarding; add mapping table if Bullhorn states don't 1:1.
   548	
   549	  Q4_cash_conductor_transactions_retention:
   550	    question: "90-day rolling for unmatched + indefinite for matched — is indefinite UK GDPR-compatible? Bank transaction PII implications."
   551	    resolution: Founder + legal review (placeholder; not gating v0.3 ratification). Recommended: indefinite-with-pseudonymization at year 7.
   552	
   553	  Q5_tenant_adapters_config_validation_trigger:
   554	    question: "JSONB validation trigger for the 4 new config keys — should it hard-fail on unknown keys, or warn-and-store-anyway?"
   555	    resolution: Hard-fail; only documented keys may be set. Per master brief §1 Rule 2 (Schema before code).
   556	
   557	# ============================================================================
   558	# §10 — Why this supplement is the right unblock
   559	# ============================================================================
   560	

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '220,289p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '430,469p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,40p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   220	      required: false
   221	      default: unknown
   222	      notes: |
   223	        Scribe's inference from prospecting-call urgency cues. Drives ranking
   224	        in Sourcing Scout's brief-to-candidate pipeline.
   225	      source: IFOS-derived (Scribe LLM classification)
   226	      v1_0_agent_access:
   227	        - Scribe (R+W)
   228	        - Sourcing Scout (R)
   229	
   230	    decision_window_text:
   231	      type: text
   232	      required: false
   233	      max_length: 280
   234	      notes: |
   235	        Free-text capture by Scribe of decision-timing phrases ("we need someone
   236	        starting in Q3", "decision by end of week"). Concierge reads to time
   237	        outbound comms.
   238	      source: IFOS-derived (Scribe extraction)
   239	      v1_0_agent_access:
   240	        - Scribe (R+W)
   241	        - Concierge (R)
   242	
   243	# ============================================================================
   244	# §2 — Scribe access matrix expansion
   245	# ============================================================================
   246	#
   247	# Per Scribe agent.md §3 Round-8 finding #2: Scribe writes to Contact, Brief,
   248	# and Opportunity in v1.0 cycle.sh per agent.md §4 Steps 5-9; current v0.1
   249	# matrix gives Scribe `contact: none`, `brief: R`, `opportunity: none`.
   250	# v0.3 expands these to match actual Scribe write paths.
   251	
   252	scribe_access_matrix_changes:
   253	  contact:
   254	    v0_1: none
   255	    v0_3: R+W
   256	    rationale: |
   257	      Scribe writes preferred_channel + next_action_target_date + decision_authority
   258	      updates from call context. Per §6 (Scribe agent.md §4 Step 5-9).
   259	    new_writable_fields:
   260	      - preferred_channel  # v0.3-added
   261	      - next_action_target_date  # v0.3-added
   262	      - decision_authority  # already exists; v0.3 grants Scribe write access
   263	
   264	  brief:
   265	    v0_1: R
   266	    v0_3: R+W
   267	    rationale: |
   268	      Scribe writes must_haves + nice_to_haves + deal_breakers + structured-field
   269	      updates from briefing-call transcripts. Per Ultraplan §8.1 A3 line 524 verbatim
   270	      ("≥3 structured-field extractions"); Brief is a primary write target.
   271	    new_writable_fields:
   272	      - must_haves  # v0.3-added
   273	      - nice_to_haves  # v0.3-added
   274	      - deal_breakers  # v0.3-added
   275	      - salary_min  # v0.1; v0.3 grants Scribe write
   276	      - salary_max  # v0.1; v0.3 grants Scribe write
   277	      - start_date  # v0.1; v0.3 grants Scribe write
   278	
   279	  opportunity:
   280	    v0_1: none
   281	    v0_3: R+W
   282	    rationale: |
   283	      Scribe writes headcount_growth_signal_text + hiring_velocity_band +
   284	      decision_window_text from prospecting-call transcripts.
   285	    new_writable_fields:
   286	      - headcount_growth_signal_text  # v0.3-added
   287	      - hiring_velocity_band  # v0.3-added
   288	      - decision_window_text  # v0.3-added
   289	

 succeeded in 0ms:
   430	  concierge_last_poll:
   431	    type: timestamptz
   432	    required: false
   433	    default: null
   434	    set_by: concierge
   435	    read_by: [concierge]
   436	    notes: |
   437	      Concierge polling cron updates this at end of each poll cycle (per
   438	      agent.md §4 Step 1 mode=poll). On next poll, query Bullhorn for state
   439	      transitions since this timestamp.
   440	
   441	  concierge_send_window:
   442	    type: object
   443	    required: false
   444	    default:
   445	      timezone: Europe/London
   446	      weekday_start: '09:00'
   447	      weekday_end: '17:00'
   448	      weekend_send_enabled: false
   449	    set_by: [tenant-admin]  # via Brain UI tenant config screen
   450	    read_by: [concierge]
   451	    notes: |
   452	      Per-tenant outbound sending hours. Concierge respects this when scheduling
   453	      orange-tier sends; sends queued outside the window deferred to next
   454	      in-window slot.
   455	
   456	  diagnostic_per_claim_sample_rate:
   457	    type: integer
   458	    required: false
   459	    default: 10
   460	    range: [1, 100]  # 1-in-N sample rate; 10 = 10% of reports validated
   461	    set_by: [tenant-admin]
   462	    read_by: [diagnostic]
   463	    notes: |
   464	      Per ADR-006 Tier 2 (post-launch quality metric). Sample 1-in-N Diagnostic
   465	      reports for per-claim citation validation. Activates at W4 polish when
   466	      Tier 2 ships; until then this field is documented intent only.
   467	
   468	# ============================================================================
   469	# §6 — decision_log.payload extension (per ADR-006 W4-polish prerequisite)

 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
     2	# ============================================================================
     3	# Status: Proposed (Codex Day-19 ratification queue addendum)
     4	# Date:   2026-05-24 (Day 19 of bilateral disposition execution)
     5	# Author: Founder (Maddox) + Claude Code, post-Round-8 Cat-β categorization
     6	# Predecessor: docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml (Day 8)
     7	#
     8	# Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
     9	# Concierge) — schema-supplement-needed items that block re-ratification of those
    10	# agent.md scaffolds. Documented in:
    11	# `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4
    12	# Cat-β section.
    13	#
    14	# Companion: docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql + v0.3-to-v0.2.sql
    15	#   Forward + rollback drafted alongside.
    16	#
    17	# Layer over v0.1 (8 entities) + v0.2 (3 voice/edit auxiliary tables + 6 voice
    18	# score fields). v0.3 adds:
    19	#   §1 — 14 new entity.data field additions across candidate + contact + brief +
    20	#        placement + opportunity (per Scribe Round-8 finding #1)
    21	#   §2 — Scribe access matrix expansion (Contact none→R+W; Brief R→R+W; per
    22	#        Scribe Round-8 finding #2)
    23	#   §3 — Janitor candidate.linkedin_url addition + Janitor access added to
    24	#        recent_edit + tone_rule v1_0_agent_access (per Janitor Round-8 finding #3)
    25	#   §4 — 2 new auxiliary Postgres tables for Cash Conductor: cash_conductor_transactions
    26	#        + cash_conductor_invoices (per Cash Conductor Round-8 finding #2)
    27	#   §5 — tenant_adapters.config field additions: cash_conductor_last_run +
    28	#        concierge_last_poll + concierge_send_window + diagnostic_per_claim_sample_rate
    29	#   §6 — decision_log.payload extension for per_claim_confidence_distribution
    30	#        (per ADR-006 W4-polish prerequisite)
    31	# ============================================================================
    32	
    33	vertical: recruitment
    34	version: v0.3
    35	supplements: v0.2
    36	status: Proposed
    37	date: 2026-05-24
    38	author: founder (Maddox) + Claude Code, post-bilateral Cat-β unblock
    39	codex_ratification_queue_position: 44  # after v0.2 supplement (29) + post-bilateral-extension catalogue commits (5e59f9c, cbef6b5, etc.)
    40	

exec
/bin/zsh -lc 'rg -n "contract_type|current_role|candidate:|bullhorn_id|agent_access_matrix|Scribe|contact:|brief:|opportunity:" docs/verticals/recruitment/vertical-schema.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
48:  candidate:
54:      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
58:      bullhorn_id:
104:      current_role:
115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
119:        source: IFOS-derived (Scribe extraction; GBP annual)
132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
136:        source: IFOS-derived (Scribe extracts)
159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
166:      bullhorn_id:
196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
230:      bullhorn_id:
283:  contact:
291:      bullhorn_id:
331:      do_not_contact:
341:  brief:
348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
352:      bullhorn_id:
435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
438:      bullhorn_id:
495:  opportunity:
505:      bullhorn_id:
545:      bullhorn_id:
594:  placement_for_brief:
599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
625:  candidate_engaged_with_contact:
632:  candidate_referred_by_contact:
639:  opportunity_for_brief:
647:  opportunity_about_candidate:
669:agent_access_matrix:
672:    candidate: none
675:    contact: none
676:    brief: none
678:    opportunity: none
683:    candidate: R+W   # full sweep + normalisation + dedup proposals
686:    contact: R       # read-only (Concierge owns writes)
687:    brief: R         # status drift sweep
689:    opportunity: none
692:  Scribe:
693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
696:    contact: none
697:    brief: R         # write-context resolution
699:    opportunity: none
703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
706:    contact: none
707:    brief: none
709:    opportunity: none
713:    candidate: R     # passive matching
716:    contact: none    # thin v1.0
717:    brief: R         # active brief context for matching
719:    opportunity: none
723:    candidate: R+W   # lifecycle state on every event
726:    contact: R       # decision-maker resolution for orange-tier sends
727:    brief: R         # linked-brief context
729:    opportunity: none
741:  candidate:
760:  contact:
765:  brief:
777:  opportunity:
844:  Q9_multi_client_contact:
870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.

exec
/bin/zsh -lc "rg -n \"master brief|§8\\.2|Diagnostic|Janitor|Scribe|Cash Conductor|Sourcing Scout|Concierge\" docs/verticals/recruitment -S | head -80" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:10:# Source: master brief §6 Day 6 line 490 (8 core entities)
docs/verticals/recruitment/vertical-schema.yaml:26:  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:53:      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:54:      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:56:      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:119:        source: IFOS-derived (Scribe extraction; GBP annual)
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:136:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:161:      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
docs/verticals/recruitment/vertical-schema.yaml:191:        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
docs/verticals/recruitment/vertical-schema.yaml:196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
docs/verticals/recruitment/vertical-schema.yaml:205:        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
docs/verticals/recruitment/vertical-schema.yaml:214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
docs/verticals/recruitment/vertical-schema.yaml:216:      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
docs/verticals/recruitment/vertical-schema.yaml:217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
docs/verticals/recruitment/vertical-schema.yaml:226:      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:228:      - Concierge (R — relationship context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:261:        source: IFOS-derived (Janitor maintains)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
docs/verticals/recruitment/vertical-schema.yaml:288:      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
docs/verticals/recruitment/vertical-schema.yaml:289:      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
docs/verticals/recruitment/vertical-schema.yaml:321:        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
docs/verticals/recruitment/vertical-schema.yaml:334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
docs/verticals/recruitment/vertical-schema.yaml:347:      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:350:      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:410:        source: IFOS-derived (Concierge maintains based on client check-in cadence)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:436:      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:480:        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
docs/verticals/recruitment/vertical-schema.yaml:481:        notes: Drives Concierge nurture-event firing.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
docs/verticals/recruitment/vertical-schema.yaml:615:    v1_0_exercise: Concierge reads for addressee-resolution per bullhorn §4.1 A6 Voice gate; addressee = primary decision-maker contact.
docs/verticals/recruitment/vertical-schema.yaml:623:    v1_0_exercise: Concierge addressee context.
docs/verticals/recruitment/vertical-schema.yaml:630:    v1_0_exercise: Concierge reads for outbound-message addressee correctness; thin in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:671:  Diagnostic:
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:682:  Janitor:
docs/verticals/recruitment/vertical-schema.yaml:686:    contact: R       # read-only (Concierge owns writes)
docs/verticals/recruitment/vertical-schema.yaml:692:  Scribe:
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:722:  Concierge:
docs/verticals/recruitment/vertical-schema.yaml:736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:775:    notes: lifecycle_stage is IFOS-derived (Concierge maintains); Bullhorn does not natively store IFOS's nurture-cadence stages.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '58,150p;795,835p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    58	      bullhorn_id:
    59	        type: integer
    60	        required: true
    61	        source: Bullhorn.Candidate.id
    62	        notes: Adapter-layer primary key for Bullhorn round-trip. Stable across ingests.
    63	      first_name:
    64	        type: string
    65	        required: true
    66	        source: Bullhorn.Candidate.firstName
    67	      last_name:
    68	        type: string
    69	        required: true
    70	        source: Bullhorn.Candidate.lastName
    71	      email:
    72	        type: string
    73	        required: false
    74	        source: Bullhorn.Candidate.email
    75	        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
    76	      phone:
    77	        type: string
    78	        required: false
    79	        source: Bullhorn.Candidate.phone
    80	      mobile:
    81	        type: string
    82	        required: false
    83	        source: Bullhorn.Candidate.mobile
    84	      status:
    85	        type: string
    86	        required: true
    87	        source: Bullhorn.Candidate.status
    88	        enum: [active, archived, do_not_contact, placed, contractor_promoted]
    89	        notes: |
    90	          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
    91	      owner_user_id:
    92	        type: integer
    93	        required: false
    94	        source: Bullhorn.Candidate.owner.id
    95	        notes: Bullhorn user (consultant) who owns this candidate record.
    96	      date_added_at:
    97	        type: timestamp
    98	        required: true
    99	        source: Bullhorn.Candidate.dateAdded
   100	      date_last_modified_at:
   101	        type: timestamp
   102	        required: true
   103	        source: Bullhorn.Candidate.dateLastModified
   104	      current_role:
   105	        type: string
   106	        required: false
   107	        source: Bullhorn.Candidate.occupation
   108	      current_employer:
   109	        type: string
   110	        required: false
   111	        source: Bullhorn.Candidate.companyName
   112	      desired_role:
   113	        type: string
   114	        required: false
   115	        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
   116	      salary_expectation_min:
   117	        type: number
   118	        required: false
   119	        source: IFOS-derived (Scribe extraction; GBP annual)
   120	      salary_expectation_max:
   121	        type: number
   122	        required: false
   123	        source: IFOS-derived (GBP annual)
   124	      location:
   125	        type: string
   126	        required: false
   127	        source: Bullhorn.Candidate.address.city
   128	        notes: Free-text city/region for v0.1. Structured location pending v1.1.
   129	      willing_to_relocate:
   130	        type: boolean
   131	        required: false
   132	        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
   133	      notice_period_weeks:
   134	        type: integer
   135	        required: false
   136	        source: IFOS-derived (Scribe extracts)
   137	      source:
   138	        type: string
   139	        required: false
   140	        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
   141	        source: IFOS-derived (set by Sourcing Scout at first-touch)
   142	      voice_classifier_score:
   143	        type: number
   144	        required: false
   145	        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
   146	        notes: |
   147	          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
   148	    notes:
   149	      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
   150	      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
   795	open_questions:
   796	
   797	  Q1_contractor_entity_type:
   798	    status: RESOLVED (Day 6 founder decision)
   799	    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
   800	    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
   801	
   802	  Q2_note_handling:
   803	    status: DEFERRED to v1.1
   804	    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
   805	    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
   806	    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
   807	
   808	  Q3_full_bullhorn_field_set:
   809	    status: DEFERRED to Week 3-4
   810	    v0_1_decision: v0.1 ships minimal v1.0 working set (~10-20 fields per entity) covering what the 6 v1.0 agents actually touch per bullhorn §4.1.
   811	    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
   812	    rationale: Premature schema lockdown is the failure mode; minimum-shape approach lets pilot data guide expansion.
   813	
   814	  Q4_system_agents_not_entities:
   815	    status: RESOLVED (Day 6 founder decision)
   816	    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
   817	    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
   818	
   819	  Q5_contact_decision_authority_granularity:
   820	    status: DEFERRED to v1.1
   821	    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
   822	    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
   823	    v1_1_plus_expansion: Sub-fields for decision-domain (technical/budget/strategic), authority tier (final/recommend/influence/observer), engagement history aggregate, preferred-channel sentiment.
   824	
   825	  Q6_timesheet_field_set:
   826	    status: DEFERRED to v2.0
   827	    v0_1_decision: Timesheet entity has placeholder 7-field shape (id, week_starting, hours_worked, approved_by_client, approved_by_contractor, date_submitted, primary key).
   828	    revisit_trigger: v2.0 T2 Timesheet agent build verifies against real Bullhorn data and expands.
   829	    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
   830	
   831	  Q7_umbrella_company_promotion:
   832	    status: DEFERRED to v1.1
   833	    surfaced_during_drafting: 2026-05-18 Day 6
   834	    v0_1_decision: contractor.umbrella_company is free-text field in v0.1.
   835	    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.

codex
REJECTED

1. Companion migration files are cited but missing. Lines 14-15 and 500-502 cite `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` and `v0.3-to-v0.2.sql`, but those files are not present under `docs/verticals/recruitment/migrations/`. The schema-change skill §7 requires referenced forward and rollback migrations to exist and be non-trivial. Add both migration files or change the supplement to Proposed-without-migration and remove claims that they are drafted.

2. Field types do not conform to the schema-change contract. Lines 61, 75, 135, 145, 175, 205, 231, 301, 420, 431, 488, and 489 use `enum`, `list_of_string`, `text`, `timestamptz`, and `NUMERIC(3, 2)`, but allowed YAML field types are `string | integer | number | boolean | array | object | timestamp | date`. Rewrite enums as `type: string` plus `enum/values`, lists as `type: array` with item type, text as `string`, timestamptz as `timestamp`, and numeric SQL types as `number`.

3. Migration sequencing violates the Day-4 generic entity layering. Lines 507-511 instruct `ALTER TABLE candidate/contact/brief/placement/opportunity`, but the supplement itself says these are `entities.data` JSONB keys, and the schema layering invariant says vertical schemas define JSON shapes over the generic `entities` table, not per-entity tables. Replace these steps with JSONB-shape/validation updates for `entities.data` by `entity_type`.

4. The access matrix change is incomplete. Lines 252-288 provide only Scribe deltas, while the schema-change skill §5 requires `agent_access_matrix` to list every v1.0 agent across every entity and to match each entity/field access declaration. Add a complete v0.3 matrix for Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, and Concierge across all v0.1 entities plus the v0.3 auxiliary-table access declarations.

5. Open questions do not meet the required structure. Lines 536-555 use `question` and `resolution` only; they do not provide A/B/C options, `v0_3_default`, or `trigger_for_revisit`, and Q4 explicitly says “placeholder; not gating v0.3 ratification.” Rewrite each Q1-Q5 with numbered options, the default encoded by v0.3, and a concrete revisit trigger.

6. The supplement contains an unverifiable schema citation. Lines 65-66 refer to `candidate.contract_type (v0.1 line ~145 if present)`, but `candidate.contract_type` is not present in `docs/verticals/recruitment/vertical-schema.yaml`; line 145 is `voice_classifier_score` source text. Remove the claim or add a real existing field citation.
tokens used
35,177
REJECTED

1. Companion migration files are cited but missing. Lines 14-15 and 500-502 cite `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` and `v0.3-to-v0.2.sql`, but those files are not present under `docs/verticals/recruitment/migrations/`. The schema-change skill §7 requires referenced forward and rollback migrations to exist and be non-trivial. Add both migration files or change the supplement to Proposed-without-migration and remove claims that they are drafted.

2. Field types do not conform to the schema-change contract. Lines 61, 75, 135, 145, 175, 205, 231, 301, 420, 431, 488, and 489 use `enum`, `list_of_string`, `text`, `timestamptz`, and `NUMERIC(3, 2)`, but allowed YAML field types are `string | integer | number | boolean | array | object | timestamp | date`. Rewrite enums as `type: string` plus `enum/values`, lists as `type: array` with item type, text as `string`, timestamptz as `timestamp`, and numeric SQL types as `number`.

3. Migration sequencing violates the Day-4 generic entity layering. Lines 507-511 instruct `ALTER TABLE candidate/contact/brief/placement/opportunity`, but the supplement itself says these are `entities.data` JSONB keys, and the schema layering invariant says vertical schemas define JSON shapes over the generic `entities` table, not per-entity tables. Replace these steps with JSONB-shape/validation updates for `entities.data` by `entity_type`.

4. The access matrix change is incomplete. Lines 252-288 provide only Scribe deltas, while the schema-change skill §5 requires `agent_access_matrix` to list every v1.0 agent across every entity and to match each entity/field access declaration. Add a complete v0.3 matrix for Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, and Concierge across all v0.1 entities plus the v0.3 auxiliary-table access declarations.

5. Open questions do not meet the required structure. Lines 536-555 use `question` and `resolution` only; they do not provide A/B/C options, `v0_3_default`, or `trigger_for_revisit`, and Q4 explicitly says “placeholder; not gating v0.3 ratification.” Rewrite each Q1-Q5 with numbered options, the default encoded by v0.3, and a concrete revisit trigger.

6. The supplement contains an unverifiable schema citation. Lines 65-66 refer to `candidate.contract_type (v0.1 line ~145 if present)`, but `candidate.contract_type` is not present in `docs/verticals/recruitment/vertical-schema.yaml`; line 145 is `voice_classifier_score` source text. Remove the claim or add a real existing field citation.
