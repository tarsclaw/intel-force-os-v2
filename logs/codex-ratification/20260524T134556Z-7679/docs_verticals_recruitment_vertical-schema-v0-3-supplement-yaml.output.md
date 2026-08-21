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
session id: 019e5a3c-3813-7821-80d0-6a06d1bfffa6
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
# and all v0.1 + v0.2 entities. v0.3 changes:
#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
#     R-only for Scribe)
#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only)
#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only)
# All other access levels carry forward from v0.1 + v0.2.

agent_access_matrix:

  # Disposition tokens: R | W | R+W | none

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

codex
I’ll verify the supplement against the repo context it cites: predecessor schema, migration files, and the integration docs that define the matrix constraints.
exec
/bin/zsh -lc "sed -n '1,260p' docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
# and all v0.1 + v0.2 entities. v0.3 changes:
#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
#     R-only for Scribe)
#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only)
#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only)
# All other access levels carry forward from v0.1 + v0.2.

agent_access_matrix:

  # Disposition tokens: R | W | R+W | none


exec
/bin/zsh -lc "rg --files docs/verticals/recruitment | rg 'vertical-schema|migrations|bullhorn-integration-path|sequencing-target|operational-hygiene|codex-disagreement'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '261,620p' docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

 succeeded in 181ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql

codex
The file exists in the repo and the companion migrations are present. I’m checking the SQL and predecessor schema now for mismatches that would make the supplement’s claims false.
exec
/bin/zsh -lc "sed -n '1,220p' docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '260,620p' docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
-- ============================================================================
-- IFOS recruitment vertical schema — v0.3 → v0.2 rollback
-- ============================================================================
-- Companion rollback for: v0.2-to-v0.3.sql
-- Authored:               2026-05-24 (Day 19)
-- Status:                 DRAFTED; only execute if v0.3 changes break production.
--
-- Rolls back v0.3 additions:
--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
--   - Restores v0.2 entities.data validation trigger (loses v0.3 field validation)
--   - Restores v0.2 tenant_adapters.config validation trigger
--
-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
-- rows are DELETED. Operator must export to JSON via /vault/<tenant>/exports/
-- BEFORE running this rollback if any rows present.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- §1 — Operator confirmation prompt
-- ----------------------------------------------------------------------------

DO $$
DECLARE
  cct_rows INT;
  cci_rows INT;
BEGIN
  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
  IF cct_rows > 0 OR cci_rows > 0 THEN
    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
    RAISE NOTICE 'EXPORT TO JSON BEFORE PROCEEDING (per migration §1 warning)';
    -- Note: not raising EXCEPTION; operator runs with explicit acknowledgment
  END IF;
END $$;

-- ----------------------------------------------------------------------------
-- §2 — Drop v0.3 auxiliary tables
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;

-- ----------------------------------------------------------------------------
-- §3 — Restore v0.2 validation trigger for entities.data
-- ----------------------------------------------------------------------------

DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
DROP FUNCTION IF EXISTS validate_entities_data_v0_3();

-- v0.2 validate_voice_scores function is preserved in the schema (we replaced
-- the trigger binding but didn't drop the v0.2 function). Re-attach it.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validate_voice_scores') THEN
    RAISE EXCEPTION 'v0.2 validate_voice_scores function missing — rollback cannot complete; re-apply v0.1-to-v0.2.sql §4 to restore';
  END IF;
END $$;

CREATE TRIGGER validate_voice_scores
  BEFORE INSERT OR UPDATE ON entities
  FOR EACH ROW
  EXECUTE FUNCTION validate_voice_score_fields();

-- ----------------------------------------------------------------------------
-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
-- ----------------------------------------------------------------------------

DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();

-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
-- function; the keys were unvalidated at v0.2. Restoring v0.2 state means no
-- tenant_adapters config validation trigger.

-- ----------------------------------------------------------------------------
-- §5 — Smoke verification (read-only)
-- ----------------------------------------------------------------------------

DO $$
DECLARE
  cct_exists INT;
  cci_exists INT;
BEGIN
  SELECT count(*) INTO cct_exists FROM information_schema.tables
    WHERE table_name = 'cash_conductor_transactions';
  SELECT count(*) INTO cci_exists FROM information_schema.tables
    WHERE table_name = 'cash_conductor_invoices';
  IF cct_exists > 0 OR cci_exists > 0 THEN
    RAISE EXCEPTION 'v0.3 tables still present after rollback';
  END IF;
  RAISE NOTICE 'v0.3 → v0.2 rollback verified: cash_conductor tables dropped';
END $$;

COMMIT;

-- ============================================================================
-- End of v0.3 → v0.2 rollback
-- ============================================================================

 succeeded in 0ms:
    IF d ? 'must_haves' THEN
      IF jsonb_typeof(d->'must_haves') != 'array' THEN
        RAISE EXCEPTION 'must_haves must be array';
      END IF;
      IF jsonb_array_length(d->'must_haves') > 15 THEN
        RAISE EXCEPTION 'must_haves max length 15';
      END IF;
      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
        IF jsonb_typeof(arr_item) != 'string' THEN
          RAISE EXCEPTION 'must_haves items must be strings';
        END IF;
      END LOOP;
    END IF;

    IF d ? 'nice_to_haves' THEN
      IF jsonb_typeof(d->'nice_to_haves') != 'array' THEN
        RAISE EXCEPTION 'nice_to_haves must be array';
      END IF;
      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'nice_to_haves') LOOP
        IF jsonb_typeof(arr_item) != 'string' THEN
          RAISE EXCEPTION 'nice_to_haves items must be strings';
        END IF;
      END LOOP;
    END IF;

    IF d ? 'deal_breakers' THEN
      IF jsonb_typeof(d->'deal_breakers') != 'array' THEN
        RAISE EXCEPTION 'deal_breakers must be array';
      END IF;
      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
        IF jsonb_typeof(arr_item) != 'string' THEN
          RAISE EXCEPTION 'deal_breakers items must be strings';
        END IF;
      END LOOP;
    END IF;
  END IF;

  -- v0.3 placement fields
  IF et = 'placement' THEN
    IF d ? 'placement_status' THEN
      IF (d->>'placement_status') NOT IN (
        'pending_start', 'active', 'completed', 'terminated_early', 'on_hold', 'cancelled'
      ) THEN
        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
      END IF;
    END IF;

    IF d ? 'week_1_status_note' THEN
      IF jsonb_typeof(d->'week_1_status_note') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'week_1_status_note must be string or null';
      END IF;
      IF d->>'week_1_status_note' IS NOT NULL
         AND length(d->>'week_1_status_note') > 500 THEN
        RAISE EXCEPTION 'week_1_status_note exceeds 500 chars (got %)', length(d->>'week_1_status_note');
      END IF;
    END IF;

    IF d ? 'satisfaction_signal' THEN
      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
      END IF;
    END IF;
  END IF;

  -- v0.3 opportunity fields
  IF et = 'opportunity' THEN
    IF d ? 'headcount_growth_signal_text' THEN
      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
      END IF;
      IF d->>'headcount_growth_signal_text' IS NOT NULL
         AND length(d->>'headcount_growth_signal_text') > 280 THEN
        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
      END IF;
    END IF;

    IF d ? 'hiring_velocity_band' THEN
      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
      END IF;
    END IF;

    IF d ? 'decision_window_text' THEN
      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'decision_window_text must be string or null';
      END IF;
      IF d->>'decision_window_text' IS NOT NULL
         AND length(d->>'decision_window_text') > 280 THEN
        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Rebind the trigger to the new function (drops + recreates)
DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;

CREATE TRIGGER validate_entities_data_v0_3
  BEFORE INSERT OR UPDATE ON entities
  FOR EACH ROW
  EXECUTE FUNCTION validate_entities_data_v0_3();

-- ----------------------------------------------------------------------------
-- §5 — tenant_adapters.config validation trigger (new keys)
-- ----------------------------------------------------------------------------
--
-- v0.3 codifies 4 new config keys agents read. The validation trigger ensures
-- only the documented keys are stored (hard-fail on unknown keys per Rule 2
-- Schema before code).

CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
RETURNS TRIGGER AS $$
DECLARE
  c JSONB := NEW.config;
  k TEXT;
  allowed_keys TEXT[] := ARRAY[
    -- v0.1 + v0.2 keys (forwarded; do not remove)
    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
    'janitor_last_run',
    'pii_retention_days',  -- v0.2 PII purge runbook key
    -- autosend-safety-policy.md keys
    'approval_routing', 'approval_timeouts', 'sampling_rates',
    -- v0.3 additions
    'cash_conductor_last_run',
    'concierge_last_poll',
    'concierge_send_window',
    'diagnostic_per_claim_sample_rate'
  ];
BEGIN
  IF c IS NULL THEN
    RETURN NEW;
  END IF;

  FOR k IN SELECT jsonb_object_keys(c) LOOP
    IF NOT (k = ANY(allowed_keys)) THEN
      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
    END IF;
  END LOOP;

  -- v0.3 type validations
  IF c ? 'diagnostic_per_claim_sample_rate' THEN
    IF jsonb_typeof(c->'diagnostic_per_claim_sample_rate') != 'number' THEN
      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be integer';
    END IF;
    IF (c->>'diagnostic_per_claim_sample_rate')::int < 1
       OR (c->>'diagnostic_per_claim_sample_rate')::int > 100 THEN
      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be 1-100';
    END IF;
  END IF;

  IF c ? 'concierge_send_window' THEN
    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
      RAISE EXCEPTION 'concierge_send_window must be object';
    END IF;
    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
      RAISE EXCEPTION 'concierge_send_window must include timezone';
    END IF;
    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
    END IF;
    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
    END IF;
  END IF;

  -- v0.3 timestamp-typed keys
  IF c ? 'cash_conductor_last_run' THEN
    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
    END IF;
  END IF;

  IF c ? 'concierge_last_poll' THEN
    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;

CREATE TRIGGER validate_tenant_adapters_config_v0_3
  BEFORE INSERT OR UPDATE ON tenant_adapters
  FOR EACH ROW
  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();

-- ----------------------------------------------------------------------------
-- §6 — Smoke verification (read-only)
-- ----------------------------------------------------------------------------

DO $$
DECLARE
  ccr_count INT;
  cci_count INT;
BEGIN
  SELECT count(*) INTO ccr_count FROM information_schema.tables
    WHERE table_name = 'cash_conductor_transactions';
  IF ccr_count != 1 THEN
    RAISE EXCEPTION 'cash_conductor_transactions table not created';
  END IF;

  SELECT count(*) INTO cci_count FROM information_schema.tables
    WHERE table_name = 'cash_conductor_invoices';
  IF cci_count != 1 THEN
    RAISE EXCEPTION 'cash_conductor_invoices table not created';
  END IF;

  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
END $$;

COMMIT;

-- ============================================================================
-- End of v0.2 → v0.3 migration
-- ============================================================================

exec
/bin/zsh -lc "sed -n '1,260p' docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
-- ============================================================================
-- IFOS recruitment vertical schema — v0.2 → v0.3 migration
-- ============================================================================
-- Companion to: docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
-- Authored:     2026-05-24 (Day 19; post-bilateral Cat-β unblock)
-- Status:       DRAFTED; NOT executed against production Hetzner Postgres yet.
--               Execute against migration-test tenant first via run-live-migration.sh.
--
-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
-- Concierge). v0.3 additions:
--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
--     (both RLS-isolated per tenant_slug)
--   - JSONB validation trigger updates for entities.data: validate new keys on
--     candidate, contact, brief, placement, opportunity (14 fields across 5
--     entity_types)
--   - JSONB validation trigger for tenant_adapters.config: 4 new keys
--   - decision_log.payload extension is documented in autosend-safety-policy.md
--     §7 supplement; no migration needed (JSONB column accepts any keys at write
--     time; validation is in v0.2 trigger)
--
-- All v0.3 additions are STRICTLY ADDITIVE. Rollback path: companion
-- v0.3-to-v0.2.sql.
--
-- Prerequisites:
--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
--     recent_edit tables exist; validate_voice_scores trigger active)
--   - RLS policies + ifos_app grants from Day-4 §6.3 in place
--   - migration-test tenant row exists in tenants table
--
-- Execution order: BEGIN; <each block>; COMMIT;   on success.
--                  BEGIN; <each block>; ROLLBACK; on any error.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- §1 — Verify prerequisite v0.2 state
-- ----------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
  END IF;
  RAISE NOTICE 'v0.2 prerequisites verified';
END $$;

-- ----------------------------------------------------------------------------
-- §2 — Create cash_conductor_transactions table (RLS-isolated)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
  id                 BIGSERIAL PRIMARY KEY,
  tenant_slug        TEXT NOT NULL,
  transaction_id     TEXT NOT NULL,
  posted_at          TIMESTAMPTZ NOT NULL,
  amount             NUMERIC(15, 2) NOT NULL,
  currency           TEXT NOT NULL DEFAULT 'GBP',
  payee_name_raw     TEXT,
  description        TEXT,
  bank_provider      TEXT NOT NULL,
  match_status       TEXT NOT NULL DEFAULT 'unmatched',
  matched_invoice_id TEXT,
  match_confidence   NUMERIC(3, 2),
  match_dimensions   TEXT[],
  ingested_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  raw_payload        JSONB,

  CONSTRAINT cct_match_status_valid CHECK (
    match_status IN ('unmatched', 'matched', 'ambiguous')
  ),
  CONSTRAINT cct_bank_provider_valid CHECK (
    bank_provider IN ('truelayer', 'plaid_uk', 'open_banking_direct')
  ),
  CONSTRAINT cct_match_confidence_range CHECK (
    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
  ),
  CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id)
);

CREATE INDEX IF NOT EXISTS idx_cct_tenant_posted
  ON cash_conductor_transactions (tenant_slug, posted_at DESC);

CREATE INDEX IF NOT EXISTS idx_cct_tenant_unmatched
  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
  WHERE match_status IN ('unmatched', 'ambiguous');

-- RLS isolation per Day-4 §6.3 pattern
ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;

CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
  FOR ALL TO ifos_app
  USING (tenant_slug = current_setting('app.current_tenant', true));

GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;

-- ----------------------------------------------------------------------------
-- §3 — Create cash_conductor_invoices table (RLS-isolated)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
  id                       BIGSERIAL PRIMARY KEY,
  tenant_slug              TEXT NOT NULL,
  invoice_id               TEXT NOT NULL,
  accounting_provider      TEXT NOT NULL,
  invoice_number           TEXT,
  issued_at                TIMESTAMPTZ NOT NULL,
  due_at                   TIMESTAMPTZ NOT NULL,
  amount_total             NUMERIC(15, 2) NOT NULL,
  amount_paid              NUMERIC(15, 2) NOT NULL DEFAULT 0,
  currency                 TEXT NOT NULL DEFAULT 'GBP',
  status                   TEXT NOT NULL DEFAULT 'open',
  client_contact_id        TEXT,
  client_billing_email     TEXT,
  last_chase_position      INT NOT NULL DEFAULT 0,
  last_chase_sent_at       TIMESTAMPTZ,
  ingested_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  raw_payload              JSONB,

  CONSTRAINT cci_status_valid CHECK (
    status IN ('open', 'partial', 'paid', 'overdue', 'cancelled', 'voided')
  ),
  CONSTRAINT cci_provider_valid CHECK (
    accounting_provider IN ('xero', 'quickbooks', 'sage')
  ),
  CONSTRAINT cci_chase_position_range CHECK (
    last_chase_position >= 0 AND last_chase_position <= 4
  ),
  CONSTRAINT cci_amount_paid_non_negative CHECK (
    amount_paid >= 0 AND amount_paid <= amount_total
  ),
  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
);

CREATE INDEX IF NOT EXISTS idx_cci_tenant_due
  ON cash_conductor_invoices (tenant_slug, due_at);

CREATE INDEX IF NOT EXISTS idx_cci_tenant_overdue
  ON cash_conductor_invoices (tenant_slug, status, due_at)
  WHERE status IN ('open', 'partial', 'overdue');

CREATE INDEX IF NOT EXISTS idx_cci_tenant_chase
  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
  WHERE last_chase_position BETWEEN 1 AND 3;

ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;

CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
  FOR ALL TO ifos_app
  USING (tenant_slug = current_setting('app.current_tenant', true));

GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;

-- ----------------------------------------------------------------------------
-- §4 — Replace JSONB validation function for entities.data (adds v0.3 keys)
-- ----------------------------------------------------------------------------
--
-- The v0.2 migration installed validate_voice_scores trigger which validates
-- the 6 voice-score keys. v0.3 extends validation to cover the 14 new keys
-- for candidate, contact, brief, placement, opportunity. We replace the
-- function in place (CREATE OR REPLACE) so the v0.2 voice-score checks remain.

CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
RETURNS TRIGGER AS $$
DECLARE
  d JSONB := NEW.data;
  et TEXT := NEW.entity_type;
  arr_item JSONB;
BEGIN
  -- v0.2 voice-score keys (forwarded; preserves v0.2 [0.0, 1.0] range check)
  IF d ? 'voice_classifier_score' THEN
    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
      RAISE EXCEPTION 'voice_classifier_score must be number or null';
    END IF;
    IF d->'voice_classifier_score' != 'null'::jsonb THEN
      IF (d->>'voice_classifier_score')::numeric < 0.0
         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
      END IF;
    END IF;
  END IF;

  IF d ? 'voice_drift_at_close' THEN
    IF jsonb_typeof(d->'voice_drift_at_close') NOT IN ('number', 'null') THEN
      RAISE EXCEPTION 'voice_drift_at_close must be number or null';
    END IF;
    IF d->'voice_drift_at_close' != 'null'::jsonb THEN
      IF (d->>'voice_drift_at_close')::numeric < 0.0
         OR (d->>'voice_drift_at_close')::numeric > 1.0 THEN
        RAISE EXCEPTION 'voice_drift_at_close out of [0.0, 1.0] range: %', d->>'voice_drift_at_close';
      END IF;
    END IF;
  END IF;

  -- v0.3 candidate fields
  IF et = 'candidate' THEN
    IF d ? 'employment_type' THEN
      IF (d->>'employment_type') NOT IN (
        'perm', 'contract', 'contract_inside_ir35', 'contract_outside_ir35', 'day_rate', 'hybrid'
      ) THEN
        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
      END IF;
    END IF;

    IF d ? 'key_skills' THEN
      IF jsonb_typeof(d->'key_skills') != 'array' THEN
        RAISE EXCEPTION 'key_skills must be array';
      END IF;
      IF jsonb_array_length(d->'key_skills') > 20 THEN
        RAISE EXCEPTION 'key_skills max length 20 (got %)', jsonb_array_length(d->'key_skills');
      END IF;
      -- Every element must be a string
      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'key_skills') LOOP
        IF jsonb_typeof(arr_item) != 'string' THEN
          RAISE EXCEPTION 'key_skills items must be strings; got %', jsonb_typeof(arr_item);
        END IF;
      END LOOP;
    END IF;

    IF d ? 'linkedin_url' THEN
      IF jsonb_typeof(d->'linkedin_url') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'linkedin_url must be string or null';
      END IF;
      IF d->>'linkedin_url' IS NOT NULL
         AND d->>'linkedin_url' !~ '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$' THEN
        RAISE EXCEPTION 'linkedin_url does not match expected pattern: %', d->>'linkedin_url';
      END IF;
    END IF;
  END IF;

  -- v0.3 contact fields
  IF et = 'contact' THEN
    IF d ? 'preferred_channel' THEN
      IF (d->>'preferred_channel') NOT IN (
        'email', 'phone', 'sms', 'teams', 'slack', 'in_person', 'unknown'
      ) THEN
        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
      END IF;
    END IF;

    IF d ? 'next_action_target_date' THEN
      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
      END IF;
    END IF;
  END IF;

  -- v0.3 brief fields
  IF et = 'brief' THEN
    IF d ? 'must_haves' THEN

exec
/bin/zsh -lc 'rg -n "''^(entities:|relationships:|agent_access_matrix:|bullhorn_mapping:|  candidate:|  contact:|  brief:|  opportunity:|  placement:|  contractor:|  timesheet:|  client:|  voice_corpus:|  tone_rule:|  recent_edit:)" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:53:entities:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:303:  contact:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:311:  brief:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:319:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:
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

exec
/bin/zsh -lc "sed -n '280,345p' docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '45,240p' docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '669,735p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    v1_0_query_volume_estimate: 10-50 queries per agent session × ~5 active agents × 24/7 = ~10k queries/day/tenant (well within pgvector + HNSW comfortable load).

# ============================================================================
# §3 — Additional fields on existing v0.1 entities (6)
# ============================================================================

additional_fields:

  candidate:
    voice_classifier_score:
      type: number
      required: false
      source: IFOS-derived
      notes: |
        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.

  contractor:
    voice_classifier_score:
      type: number
      required: false
      source: IFOS-derived
      notes: Same as candidate.voice_classifier_score, scoped to contractor sub-case.

  contact:
    voice_classifier_score:
      type: number
      required: false
      source: IFOS-derived
      notes: |
        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).

  brief:
    voice_classifier_score:
      type: number
      required: false
      source: IFOS-derived
      notes: |
        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.

  opportunity:
    voice_classifier_score:
      type: number
      required: false
      source: IFOS-derived
      notes: |
        v1.1+ Triage exercises this; v1.0 sets to NULL. Tracks voice score for outbound messages within a specific candidate-brief opportunity pairing.

  placement:
    voice_drift_at_close:
      type: number
      required: false
      source: IFOS-derived
      notes: |
        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.

# ============================================================================
# §4 — Additional relationships (2)
# ============================================================================

additional_relationships:

  voice_corpus_governs_tone_rules:
    source: voice_corpus
    target: tone_rule
    cardinality: 1:N
    description: |

 succeeded in 0ms:
#   `migrations/v0.1-to-v0.2.sql` §2-§5.
#
#   The 6 voice_classifier_score / voice_drift_at_close fields added to existing
#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
#   in §3 below DO land as `entities.data` JSONB keys per the Day-4 §6.3 generic
#   primitive layer; they are validated by the `validate_voice_scores` trigger
#   in `migrations/v0.1-to-v0.2.sql` §7.

entities:

  # --------------------------------------------------------------------------
  voice_corpus:
    description: |
      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
    bullhorn_source: none (IFOS-derived from /vault/<tenant>/_voice/ ingest)
    v1_0_agent_access:
      - Scribe (R — voice samples for note-summary tone matching)
      - Concierge (R — voice samples for outbound message generation)
      - voice-drift-canary nightly cron (R — drift detection input)
    canonical_fields:
      tenant_slug:
        type: string
        required: true
        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
        notes: RLS-isolated per tenant. Maps to entities.tenant_slug at row level.
      version:
        type: string
        required: true
        source: IFOS-derived (operator names at re-index time)
        notes: |
          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
      source_doc_count:
        type: integer
        required: true
        source: IFOS-derived (counted by ingest pipeline)
        notes: Number of source documents ingested into this version (emails + notes + marketing). Sanity check during re-index.
      source_doc_origin:
        type: array
        required: true
        source: IFOS-derived (vault _voice/ subdirectory enumeration)
        notes: |
          Items enum: ["vault_emails", "bullhorn_notes", "marketing_copy", "founder_curated", "consultant_drafts"]. Order documents provenance for the LoRA pipeline (v2.0 Scale tier).
      chunk_count:
        type: integer
        required: true
        source: IFOS-derived (computed by chunking pass)
        notes: Number of text chunks produced from the source corpus after the chunking pass. One chunk = one row in the pgvector index.
      chunking_strategy:
        type: string
        required: true
        source: IFOS-derived (config; v0.2 default "paragraph")
        notes: |
          Enum: ["paragraph", "sentence-window-5", "semantic-segment-v1"]. v0.2 ships with "paragraph" (simplest, deterministic). Other values reserved for v1.1 experimentation per Q5 voice gate research.
      embedding_model:
        type: string
        required: true
        source: IFOS-derived (config; default text-embedding-3-small)
        notes: |
          Identifier of the embedding model used to populate the pgvector column. v0.2 ships with "text-embedding-3-small" (1536 dimensions); revising model triggers re-index + new version row.
      last_indexed_at:
        type: timestamp
        required: true
        source: IFOS-derived (timestamped at ingest completion)
        notes: When the indexing pipeline last completed for this version. Set on row insert; never updated post-insert (immutability of versioned packs).
      is_active:
        type: boolean
        required: true
        source: IFOS-derived (atomic flip on version rollover)
        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
      ingest_completion_ms:
        type: integer
        required: false
        source: IFOS-derived (observability counter; pipeline timing)
        notes: How long the ingest+chunk+embed pipeline took. Observability only.
    notes: |
      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.

  # --------------------------------------------------------------------------
  tone_rule:
    description: |
      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
    bullhorn_source: none (IFOS-derived; authored in /vault/<tenant>/_voice/tone-rules.yaml then synced to Postgres)
    v1_0_agent_access:
      - Scribe (R — note format constraints)
      - Cash Conductor (R — payment reminder tone)
      - Concierge (R — every outbound message)
    canonical_fields:
      tenant_slug:
        type: string
        required: true
        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
      rule_id:
        type: string
        required: true
        source: IFOS-derived (operator names at rule authoring time)
        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
      rule_text:
        type: string
        required: true
        source: IFOS-derived (operator natural-language description)
        notes: Natural-language description of the rule. Surfaced verbatim to the agent.
      severity:
        type: string
        required: true
        source: IFOS-derived (operator picks at rule authoring)
        notes: |
          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
      applies_to_agents:
        type: array
        required: true
        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
        notes: |
          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
      enabled:
        type: boolean
        required: true
        source: IFOS-derived (default true; operator toggles via Brain UI)
        notes: Soft-delete pattern. Tenant can disable a rule without deleting the row; preserves history for audit.
      created_by:
        type: string
        required: true
        source: IFOS-derived (enum from rule provenance — onboarding-flow / Brain-UI / CSM-intervention)
        notes: |
          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
      created_at:
        type: timestamp
        required: true
        source: IFOS-derived (timestamped at insert)
      examples_positive:
        type: array
        required: false
        source: IFOS-derived (operator-curated at rule authoring)
        notes: |
          Items: short string phrases. Examples of compliant text. Surfaced to the agent in the context bundle.
      examples_negative:
        type: array
        required: false
        source: IFOS-derived (operator-curated at rule authoring)
        notes: |
          Items: short string phrases. Examples of non-compliant text (the typical drift the rule prevents). Surfaced to the agent.
    notes: |
      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).

  # --------------------------------------------------------------------------
  recent_edit:
    description: |
      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
    bullhorn_source: none (IFOS-derived from operator's approve/edit UX)
    v1_0_agent_access:
      - voice-drift-canary cron (R — drift detection)
      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
      - LoRA pipeline v2.0 (R — SFT pair generation)
    canonical_fields:
      tenant_slug:
        type: string
        required: true
        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
      agent_name:
        type: string
        required: true
        source: IFOS-derived (from CTX_AGENT_NAME at edit-capture time)
        notes: |
          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
      action_type:
        type: string
        required: true
        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
      target_entity_type:
        type: string
        required: false
        source: IFOS-derived (entity context at edit time; nullable for system-level edits)
        notes: |
          Optional pointer to the entity the draft was about (e.g. "candidate", "client"). Enables linking voice drift to entity classes (some entity types correlate with more drift).
      target_entity_id:
        type: string
        required: false
        source: IFOS-derived (entity ID at edit time; Bullhorn ID or IFOS slug)
        notes: bullhorn_id or IFOS slug. Used in the entity_links join below.
      original_text:
        type: string
        required: true
        source: IFOS-derived (agent's draft as produced; capped at 8192 chars)
        notes: |
          The agent's draft as produced. **Stored verbatim** (privacy posture: this is the agent's own output, not external PII). Length-capped at 8192 chars; if longer, suffix truncated with "[...]" marker.
      edited_text:
        type: string
        required: false
        source: IFOS-derived (consultant's final version at approve time; null when approved verbatim)
        notes: |
          The consultant's final version. Nullable when the consultant approved verbatim (no edit). Length-capped at 8192 chars.
      edit_distance:
        type: integer
        required: false
        source: IFOS-derived (Levenshtein computed at insert; null when edited_text null)
        notes: |

 succeeded in 0ms:
agent_access_matrix:

  Diagnostic:
    candidate: none
    contractor: none
    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
    contact: none
    brief: none
    placement: none
    opportunity: none
    timesheet: none
    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.

  Janitor:
    candidate: R+W   # full sweep + normalisation + dedup proposals
    contractor: R+W  # status normalisation
    client: R+W      # orphan-link sweep + normalisation
    contact: R       # read-only (Concierge owns writes)
    brief: R         # status drift sweep
    placement: R     # orphan / stale-tag sweep
    opportunity: none
    timesheet: none

  Scribe:
    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
    contractor: R+W  # contractor calls same pattern
    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
    contact: none
    brief: R         # write-context resolution
    placement: R+W   # note links on placed-candidate calls
    opportunity: none
    timesheet: none

  Cash_Conductor:
    candidate: none  # No Bullhorn touch — Xero + Open Banking only
    contractor: none
    client: none
    contact: none
    brief: none
    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
    opportunity: none
    timesheet: none

  Sourcing_Scout:
    candidate: R     # passive matching
    contractor: R    # contractor pool
    client: R        # target-firm context
    contact: none    # thin v1.0
    brief: R         # active brief context for matching
    placement: none
    opportunity: none
    timesheet: none

  Concierge:
    candidate: R+W   # lifecycle state on every event
    contractor: R+W  # lifecycle state, contractor-specific cadence
    client: R        # relationship context
    contact: R       # decision-maker resolution for orange-tier sends
    brief: R         # linked-brief context
    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
    opportunity: none
    timesheet: none

# ============================================================================
# §4 — Bullhorn mapping
# ============================================================================
# Per-entity Bullhorn source + field-level mapping notes.

exec
/bin/zsh -lc 'rg -n "validate_voice|CREATE FUNCTION validate|CREATE TRIGGER validate" docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:221:CREATE OR REPLACE FUNCTION validate_voice_score_fields()
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:246:CREATE OR REPLACE TRIGGER validate_voice_scores
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:250:  EXECUTE FUNCTION validate_voice_score_fields();
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:321:--   → expect validate_voice_scores
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:52:-- v0.2 validate_voice_scores function is preserved in the schema (we replaced
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:57:  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validate_voice_scores') THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:58:    RAISE EXCEPTION 'v0.2 validate_voice_scores function missing — rollback cannot complete; re-apply v0.1-to-v0.2.sql §4 to restore';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:62:CREATE TRIGGER validate_voice_scores
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:65:  EXECUTE FUNCTION validate_voice_score_fields();

exec
/bin/zsh -lc 'rg -n "voice_corpus_chunks|agent_access_matrix|Diagnostic:|diagnostic:|Cash_Conductor|cash_conductor|Sourcing_Scout|sourcing_scout|Concierge:|concierge:" docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "CREATE TABLE IF NOT EXISTS voice_corpus_chunks|GRANT .*recent_edit|tone_rule|severity|applies_to_agents|resolution|is_active|partial unique|UNIQUE.*is_active" docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
270:    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.

 succeeded in 0ms:
10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
56:  is_active             BOOLEAN     NOT NULL DEFAULT FALSE,
65:  WHERE is_active = TRUE;
82:CREATE TABLE IF NOT EXISTS voice_corpus_chunks (
110:-- §4 — Create tone_rule table
113:CREATE TABLE IF NOT EXISTS tone_rule (
118:  severity            TEXT        NOT NULL CHECK (severity IN ('info', 'warn', 'block')),
119:  applies_to_agents   TEXT[]      NOT NULL DEFAULT '{}',
126:  CONSTRAINT tone_rule_tenant_rule_id_unique UNIQUE (tenant_slug, rule_id)
129:CREATE INDEX IF NOT EXISTS tone_rule_tenant_enabled_idx ON tone_rule (tenant_slug, enabled);
131:ALTER TABLE tone_rule ENABLE ROW LEVEL SECURITY;
132:ALTER TABLE tone_rule FORCE ROW LEVEL SECURITY;
133:DROP POLICY IF EXISTS tone_rule_tenant_isolation ON tone_rule;
134:CREATE POLICY tone_rule_tenant_isolation ON tone_rule
151:  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
153:  tone_rules_triggered   TEXT[]      NOT NULL DEFAULT '{}',
174:-- Voice corpus + tone_rule are mutable (re-index + rule revisions).
179:GRANT SELECT, INSERT, UPDATE, DELETE ON tone_rule           TO ifos_app;
180:GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
184:GRANT USAGE, SELECT ON SEQUENCE tone_rule_id_seq           TO ifos_app;
185:GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
201:--   ALTER TABLE tone_rule OWNER TO postgres;
205:--   ALTER SEQUENCE tone_rule_id_seq OWNER TO postgres;
292:  last_indexed_at, is_active, ingest_completion_ms
318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');

exec
/bin/zsh -lc "rg -n \"Ultraplan|§8\\.1|A3|Cash Conductor|ADR-002|ADR-006|sequencing-target|bullhorn-integration-path\" docs -g '*.md' -g '*.yaml'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/operations/bullhorn-outreach-emails.md:5:**Purpose:** Drop-in email drafts the founder sends to Bullhorn partnerships + developer support to resolve Sub-decisions A + B in `docs/decisions/bullhorn-integration-path.md`. Closes Risk #2 mitigation path; unblocks Janitor W5 build gate.
docs/operations/bullhorn-outreach-emails.md:13:Per `bullhorn-integration-path.md` §1.3:
docs/operations/bullhorn-outreach-emails.md:73:- If they confirm direct-tier works for pilot scale → Sub-decision A flips to **Direct API**; Status: Accepted. Update `bullhorn-integration-path.md` §5.
docs/operations/bullhorn-outreach-emails.md:132:- Update `bullhorn-integration-path.md` §6 (refresh-loop architecture) with the confirmed numbers.
docs/operations/bullhorn-outreach-emails.md:142:3. Claude will update `bullhorn-integration-path.md` §5 (Sub-decision A) or §6 (Sub-decision B) Status from Proposed → Accepted (or document any new findings).
docs/operations/bullhorn-outreach-emails.md:154:**Hard cutoff:** if no response by 2026-06-10 (3.5 weeks from today), Sub-decision A is forced to **Direct API** (lowest-friction path; commercial verification deferred to post-pilot) and the connector scaffolds against that — per the §2.3 §1.4 fallback architecture in `bullhorn-integration-path.md` which was designed for exactly this scenario.
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/runbooks/day-4-provisioning.md:58:### §0.2 — DRIFT: master brief §6 Day 4 table list says `entity_graph`, ADR-002 Edit 3 split this to `entities` + `entity_links`
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:70:- Master brief §8.1 Change 2: three values — `trigger`, `output`, `action`
docs/runbooks/day-4-provisioning.md:71:- `sequencing-target.md` §5-A: adds `gating_failed`, `agent_handoff`
docs/runbooks/day-4-provisioning.md:75:The runbook applies exactly these. **Do not invent additional phase values during execution** (e.g., `session_start`, `tool_call`, `escalation`) unless a Codex-ratified change to either master brief §8.1 or `sequencing-target.md` §5-A pre-dates the migration. Speculative additions break the schema-before-code rule.
docs/runbooks/day-4-provisioning.md:690:**Tightening 1:** former `entity_graph` is split into `entities` + `entity_links` per ADR-002 Edit 3.
docs/runbooks/day-4-provisioning.md:706:-- entities (formerly entity_graph; split per ADR-002 Edit 3)
docs/runbooks/day-4-provisioning.md:726:-- entity_links (split from entity_graph adjacency per ADR-002 Edit 3)
docs/runbooks/day-4-provisioning.md:749:-- decision_log (per ADR-002 §3 Decision 3; phase enum per §6.4 below = Tightening 3)
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:842:# Source: Day 4 runbook §6.5; consolidates Ultraplan §5.1 + ADR-003 §2.1-C
docs/runbooks/day-4-provisioning.md:1054:### §8.1 — Hetzner-level: enable automatic backups (already done in §2.3)
docs/runbooks/day-4-provisioning.md:1090:The vault per ADR-002 + master brief §3.3 is markdown, git-backed. Initial baseline:
docs/runbooks/day-4-provisioning.md:1286:- Not the wiki-brain provisioning (the `wiki-*` parallel scripts land Week 1-2 per ADR-002)
docs/runbooks/day-4-provisioning.md:1288:- Not the Bullhorn MCP connector (Week 1-2 per `bullhorn-integration-path.md` §6)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:129:      - Cash Conductor (R — payment reminder tone)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:191:      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:397:      - A: Single retry then escalate (current Ultraplan §5.3 default)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:400:    v0_2_default: A; matches Ultraplan §5.3 retry budget for green-path agents
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:451:    expected_date: 2027+ per LoRA pipeline activation per Ultraplan §6
docs/verticals/recruitment/vertical-schema.yaml:11:#       + bullhorn-integration-path.md §4.1 (per-agent endpoint requirements)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:54:      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:426:      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
docs/verticals/recruitment/vertical-schema.yaml:435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:666:# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:838:    status: DEFERRED to v1.1 / ADR-006
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/specs/ULTRAPLAN.md:1:# Intel Force OS — The Ultraplan
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:198:- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
docs/specs/ULTRAPLAN.md:418:| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/specs/ULTRAPLAN.md:515:#### A3. The Scribe — the data spine
docs/specs/ULTRAPLAN.md:529:#### A4. Cash Conductor (real-time mode) — the FD's evenings back
docs/specs/ULTRAPLAN.md:601:#### A9. Real-time Cash Conductor reframe (2 weeks)
docs/specs/ULTRAPLAN.md:603:Already specified in §8.1 A4 as v1.0. The v1.1 work is the reframe of pitch and any latency optimisations needed once we have 3+ tenants in production. Not a new build, ~3 days of polish.
docs/specs/ULTRAPLAN.md:688:| Cash Conductor | ✓ | | | ✓ | | | | | | ✓ | Open Banking |
docs/specs/ULTRAPLAN.md:713:7. **Xero / QuickBooks / Sage** — 4 of 18 (one per tenant typically). Cash Conductor's blocker.
docs/specs/ULTRAPLAN.md:764:### Weeks 7–8 — Cash Conductor + Hire #1 onboards
docs/specs/ULTRAPLAN.md:767:- Week 8: Cash Conductor agent; chase-cadence config; tenant-level baseline DSO captured
docs/specs/ULTRAPLAN.md:769:Milestone: Cash Conductor running in shadow mode against first pilot's accounting data.
docs/specs/ULTRAPLAN.md:800:5. Cash Conductor's escalation-tier-3 (bad debt write-off draft) — manual until 6 months in
docs/specs/ULTRAPLAN.md:821:| 5 | Open Banking integration takes more than 1 week | Medium | Medium | End of week 7 status not "Xero + first bank connected" | Cash Conductor ships with manual reconciliation in v1.0; webhook-driven mode at v1.1 |
docs/specs/ULTRAPLAN.md:847:- [ ] Bullhorn integration path decision: marketplace vs direct API. **Owner:** Maddox. **Output:** decision documented in `decisions/bullhorn-integration-path.md`.
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:19:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:21:6. **`docs/decisions/sequencing-target.md`** §3.1 (build waves) + §6.6 (failure conditions)
docs/operations/goal-week-3-polish-and-scaffold.md:23:8. **`docs/decisions/bullhorn-integration-path.md`** §1.3 (commercial-blocker table) + §1.4 (fallback architecture) + §4.1 (per-agent Bullhorn surface)
docs/operations/goal-week-3-polish-and-scaffold.md:33:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:93:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:103:| Cash Conductor MCP connectors (Xero, QuickBooks, etc.) | Reserved for W4 per ADR-005 |
docs/operations/goal-week-3-polish-and-scaffold.md:109:| Modifying ratified ADRs 001-005 | Audit trail; ADR-006+ if new architectural decisions surface during Week 3 |
docs/operations/goal-week-3-polish-and-scaffold.md:291:- ULTRAPLAN §8.1 A2 lines 507-514 (full Janitor spec)
docs/operations/goal-week-3-polish-and-scaffold.md:293:- `bullhorn-integration-path.md` §4.1 (Janitor's Bullhorn entity surface)
docs/operations/goal-week-3-polish-and-scaffold.md:302:- **Tier:** Tier 1 (batch nightly cron; not request-driven) per `sequencing-target.md` §2.1
docs/operations/goal-week-3-polish-and-scaffold.md:322:Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`
docs/operations/goal-week-3-polish-and-scaffold.md:329:- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
docs/operations/goal-week-3-polish-and-scaffold.md:331:- `bullhorn-integration-path.md` §4.1 (Scribe's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:337:- **Tier:** Tier 2 (request-driven, per-call invocation) per `sequencing-target.md` §2.1
docs/operations/goal-week-3-polish-and-scaffold.md:350:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:352:### DAY 18 — Cash Conductor agent.md scaffold (Step 10)
docs/operations/goal-week-3-polish-and-scaffold.md:357:- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:360:- `vertical-schema.yaml` §3 agent_access_matrix Cash Conductor row
docs/operations/goal-week-3-polish-and-scaffold.md:361:- ADR-005 §5.1 (Cash Conductor independence from Bullhorn — strategic value)
docs/operations/goal-week-3-polish-and-scaffold.md:368:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:379:Commit: `decision(pre-build): agents/recruitment/cash-conductor/agent.md — output contract per ULTRAPLAN §8.1 A4`
docs/operations/goal-week-3-polish-and-scaffold.md:386:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:388:- `bullhorn-integration-path.md` §4.1 (Sourcing Scout's Bullhorn read surface)
docs/operations/goal-week-3-polish-and-scaffold.md:407:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:412:- ULTRAPLAN §8.1 A6 lines 561-570 (Concierge spec)
docs/operations/goal-week-3-polish-and-scaffold.md:416:- `bullhorn-integration-path.md` §4.1 (Concierge's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:434:Commit: `decision(pre-build): agents/recruitment/concierge/agent.md — output contract per ULTRAPLAN §8.1 A6`
docs/operations/goal-week-3-polish-and-scaffold.md:459:1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
docs/operations/goal-week-3-polish-and-scaffold.md:588:1. **Every claim cites a master plan section.** No bare assertions. Every paragraph either cites the master brief / ULTRAPLAN / sequencing-target / kill-criterion / specific ADR, OR is explicitly stated as "scaffold inference; founder review required."
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:618:  Cash Conductor (W7-8):  <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:639:  ✓ ULTRAPLAN §8.1 — all 6 agents have output contracts authored
docs/operations/goal-week-3-polish-and-scaffold.md:641:  ✓ sequencing-target.md §3.1 — Build Wave 1 (Diagnostic) ratified;
docs/operations/goal-week-3-polish-and-scaffold.md:648:    - Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/goal-week-3-polish-and-scaffold.md:649:    - Cash Conductor build (full bundle)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Closes Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor + Concierge
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:56:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:254:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:352:# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:361:      RLS isolation and indexes for date + match-status. Per Cash Conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:362:      §4 Step 3 + ADR-002 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:398:      table pattern as transactions. Per Cash Conductor §4 Step 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:414:      last_chase_position: {type: integer, required: true, default: 0, notes: 0-4 per Cash Conductor §3.2}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:468:      Cash Conductor cron sweep updates at session-close. Next run queries
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:514:      Per ADR-006 Tier 2 (post-launch quality metric). Sample 1-in-N
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:519:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:600:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:691:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:710:    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:712:    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
docs/operations/codex-ratification-guide.md:173:brief §2.4 row 3 line reference holds; ADR-002 Edit 1 reference holds. Five-rule
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/runbooks/operational-hygiene-protocol.md:300:- `sequencing-target.md §6.6 three failure conditions` — ✅ verified §6.6 exists and contains the three failure conditions verbatim
docs/runbooks/operational-hygiene-protocol.md:302:- `bullhorn-integration-path.md §4.1 + §6.3` (canonical-orange anchor) — ✅ verified both sections exist and contain claimed content
docs/specs/PRODUCT-SPEC.md:73:#### R2. Real-Time Cash Conductor — the FD's evenings back
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:345:- Cash Conductor runs against historical invoices — produces the DSO baseline.
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:401:| 4 | Approval gates with standing authorisations | Every agent that auto-sends — Triage, Concierge, Cash Conductor, Competitor Interception |
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:474:- Cash Conductor (real-time mode)
docs/specs/PRODUCT-SPEC.md:523:2. **Real-Time Cash Conductor** — "DSO drops by 15+ days, working capital unlocked."
docs/architecture/architecture-cohesion-review.md:32:| **Foundation** | ADR-001 (bus poll), ADR-002 (parallel brain), cortexos-primitive-status.md (audit), second-brain-design.md (vault/Postgres split) |
docs/architecture/architecture-cohesion-review.md:41:3. ADR-002 (ratifies parallel-brain decision)
docs/architecture/architecture-cohesion-review.md:59:| ADR-002 | brain replacement details | second-brain-design.md | ✓ second-brain-design §2.4 covers vault/Postgres split |
docs/architecture/architecture-cohesion-review.md:60:| ADR-002 | `_shared/` helpers contract | "Week 1 work" §"For Week 1 work" → vault-concurrency.md + hook-helpers.sh | ✓ landed Phase 1 + 3 commits |
docs/architecture/architecture-cohesion-review.md:90:| A3 | **The `_shared/` symlink target `../../../_shared` resolves to `<org>/agents/_shared/`, not anywhere else.** | renderer.ts symlinkSync call | If filesystem semantics differ (mac vs linux), or someone moves the rendered dir, symlink could escape. macOS + Linux behaviour verified identical for this case. |
docs/architecture/architecture-cohesion-review.md:95:| A8 | **Bullhorn OAuth refresh-loop fires before token expiry under load.** Per-agent 8-min cycle vs 10-min TTL. | bullhorn-integration-path.md §4.5 + common-ats.json `auth_refresh_interval_seconds` | If the 2-min buffer is insufficient under network latency or rate-limit backoff, agent loses Bullhorn auth mid-write. Untested at scale; flagged at first Janitor build. |
docs/architecture/architecture-cohesion-review.md:233:| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A1 (the 10-step workflow for Diagnostic, lines 495-526).
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:398:Master plan alignment: ULTRAPLAN §8.1 Week-4 milestone hit on Day-13
docs/specs/_archive-build-handoff.md:47:The architecture is layered like this (per Ultraplan §3.3 and Business Plan §5.2):
docs/specs/_archive-build-handoff.md:75:**The rule (Ultraplan §3.4):** if you need something CortexOS doesn't have, contribute it upstream. Don't fork. The exception is anything recruitment-vertical-specific — that stays in your layer.
docs/specs/_archive-build-handoff.md:119:This is Ultraplan §11, restated as a Claude Code work plan. Each day is a session or two of Claude Code. End every day by committing what you have.
docs/specs/_archive-build-handoff.md:190:## The five rules (Ultraplan §1 — non-negotiable)
docs/specs/_archive-build-handoff.md:195:5. Honest signal before optimistic projection — the risk register (Ultraplan §10) is the truth-telling instrument.
docs/specs/_archive-build-handoff.md:203:See `docs/PATTERN-REFERENCE.md` and Ultraplan §4. Every agent has exactly:
docs/specs/_archive-build-handoff.md:221:The single most important Day-1 task. Per Ultraplan §11, write `docs/architecture/cortexos-primitive-status.md` with one line per primitive:
docs/specs/_archive-build-handoff.md:239:**The Ultraplan assumes primitives 1, 4, 5 are working at v1.0 start; 2, 3, 6, 7 may land during the build window.** Your audit either confirms this or triggers a re-cut of §9 of the Ultraplan.
docs/specs/_archive-build-handoff.md:241:Also Day 1: have your first design-partner sales conversation. The Ultraplan §10 risk register lists "no signed LOI by end of week 0" as a v1.0-killer risk. Sales conversations start now.
docs/specs/_archive-build-handoff.md:245:Per Ultraplan §11, decide and document in `docs/decisions/bullhorn-integration-path.md`:
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:259:Provision the production Hetzner UK VPS per Ultraplan §5.1 / §5.2:
docs/specs/_archive-build-handoff.md:272:`docs/auto-send-safety-policy.md` (Q11 from the Ultraplan's source Q&A):
docs/specs/_archive-build-handoff.md:299:The single-sentence test (Ultraplan §12):
docs/specs/_archive-build-handoff.md:308:Update `.agents/current-priorities.md`. Update Ultraplan §10 risk register with anything new. Commit.
docs/specs/_archive-build-handoff.md:324:Per the user memory and Ultraplan §4.4, every agent is built in isolation before integration. The pattern for any new agent:
docs/specs/_archive-build-handoff.md:359:- Picking which agent to build next — that's the Ultraplan §9 sprint plan and depends on pilot conversations
docs/specs/_archive-build-handoff.md:367:If you ever want to see what `/onboarding` does, run it inside `~/cortextos` in a sandbox session — but don't commit any of its output. The Intel Force OS repo has its own onboarding shape (per Business Plan §5.4 / Ultraplan §5.5) which is what you build into the wizard at v1.0.
docs/specs/_archive-build-handoff.md:373:Per Ultraplan §9, v1.0 ships six agents in the Starter and Boutique tiers. In order:
docs/specs/_archive-build-handoff.md:380:| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/_archive-build-handoff.md:415:These are Ultraplan §1. Pin them above your desk:
docs/specs/_archive-build-handoff.md:421:5. **Honest signal before optimistic projection** — when something doesn't work, log it and re-plan. The risk register in Ultraplan §10 is the truth-telling instrument; updated weekly, by name, with no hedging.
docs/specs/_archive-build-handoff.md:431:- **Decision logging is required** (Ultraplan §4.2 change 2). Every agent run writes three log entries via `hh_decision_trigger`, `hh_decision_output`, `hh_decision_action`. Missing calls = hard fail in validate.sh. This is what enables the per-tenant LoRA pipeline at v2.0.
docs/specs/_archive-build-handoff.md:434:- **You are not allowed to market 99.9% uptime.** The honest number is 99.5% and the customer agreement says so (Ultraplan §3.5).
docs/specs/_archive-build-handoff.md:448:| "Let me skip the test fixtures for now..." | Ultraplan §4.3 |
docs/specs/_archive-build-handoff.md:449:| "Let me build Triage first because it's the most exciting..." | Ultraplan §9 |
docs/specs/_archive-build-handoff.md:451:| "Let me ship without the kill criterion documented..." | Ultraplan §11 Day 5 |
docs/specs/_archive-build-handoff.md:469:That's it. The system from there is just doing the work, one day at a time, against the Ultraplan §11 checklist and then the §9 sprint plan.
docs/build-brief/00-MASTER-BRIEF.md:167:IFOS implements its second brain as a **parallel system**, not by shadowing cortextOS's stock knowledge base. cortextOS's `bus/kb-*.sh` files (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh` at SHA `c21fbfe`) remain untouched and continue to serve cortextOS-template agents. IFOS agents invoke a parallel wrapper surface at `packages/brain/bus-overrides/wiki-*.sh` (9 v1.0 + 1 v1.1 stub) that dispatches to `packages/brain/wiki/lib/` against Postgres + filesystem markdown. The §3.1 "four `bus/kb-*.sh` shadow points" edit-exception is unused — IFOS does not edit any file under `packages/harness/cortextos/`. See `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` + `docs/architecture/second-brain-design.md` for the full design.
docs/build-brief/00-MASTER-BRIEF.md:280:| `docs/RISK-REGISTER.md` | Truth-telling instrument, updated weekly | Copy of Ultraplan §10 |
docs/build-brief/00-MASTER-BRIEF.md:413:| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
docs/build-brief/00-MASTER-BRIEF.md:434:Per Ultraplan §11. Do not write any agent code until all of these are cleared.
docs/build-brief/00-MASTER-BRIEF.md:454:- [ ] If audit reveals primitives 1, 4, or 5 are NOT working today → re-cut Ultraplan §9 sprint plan tomorrow
docs/build-brief/00-MASTER-BRIEF.md:458:- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: authorization-code grant for production tenants; authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (Bullhorn does not support `client_credentials` grant for tenant-scoped data per Bullhorn OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`). Document in `docs/decisions/bullhorn-integration-path.md`.
docs/build-brief/00-MASTER-BRIEF.md:463:- [ ] Confirm or revise Ultraplan §9's "close first 3 pilots fastest" → `docs/decisions/sequencing-target.md`
docs/build-brief/00-MASTER-BRIEF.md:464:- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation.
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:486:Single-sentence test (Ultraplan §12). Answer each Y/N:
docs/build-brief/00-MASTER-BRIEF.md:508:| `phase-2-agent-suite/_shared/hook-helpers.sh` | Common validate/telemetry shell fns | `packages/agents-runtime/_shared/hooks/hook-helpers.sh` | Add `hh_decision_trigger/output/action` per Ultraplan §4.2 |
docs/build-brief/00-MASTER-BRIEF.md:564:### 8.1 The three v2 changes (Ultraplan §4.2)
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:794:- Picking which agent to build next — depends on pilot conversations (Ultraplan §9)
docs/build-brief/00-MASTER-BRIEF.md:839:Verbatim from Ultraplan §10. Full register at `docs/RISK-REGISTER.md`, weekly updates.
docs/build-brief/00-MASTER-BRIEF.md:960:From there, the build is just doing the work one day at a time: §6 this week, then Ultraplan §9 for the 14 weeks of v1.0, then Spec §9 for v1.0 → v2.0.
docs/runbooks/tenant-lifecycle.md:5:**Authority:** Consolidates Day-4 §6.5 provisioning + tenancy-invariants.md + ADR-002 + ADR-003 + v0.2 supplement.
docs/runbooks/tenant-lifecycle.md:151:| Bullhorn OAuth refresh | Per-agent 8-min cycle per `bullhorn-integration-path.md` §4.5; ESC_BULLHORN_AUTH on failure | (No invariant violation; runtime concern) |
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/operations/codex-round-2-handoff.md:73:| 2 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | status drift + edit disposition | RATIFY (status + Edits 1+2+3 cite `0e5b2b4`) |
docs/operations/codex-round-2-handoff.md:75:| 4 | `docs/decisions/bullhorn-integration-path.md` | status "Mixed" enum violation + Week-1 gate | RATIFY status; Week-1 gate may rebound (disagreement doc filed) |
docs/operations/codex-round-2-handoff.md:76:| 5 | `docs/decisions/sequencing-target.md` | status "Drafting" | RATIFY (status "Accepted") |
docs/operations/codex-round-2-handoff.md:207:  docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/operations/codex-round-2-handoff.md:209:  docs/decisions/bullhorn-integration-path.md
docs/operations/codex-round-2-handoff.md:210:  docs/decisions/sequencing-target.md
docs/architecture/agent-bundle-renderer-design.md:5:**Surfaced by:** `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §"For Week 1 work" — declared the renderer the load-bearing Week-1 prerequisite.
docs/architecture/agent-bundle-renderer-design.md:9:**Reading order:** ADR-002 first, then this design, then ADR-003.
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:54:- **§1.1-A:** master brief §8.1 names `validate.sh` and `context.sh` at the bundle root but does not specify the **invocation mechanism** — i.e. how does the agent invoke them from within its Claude Code session? Claude Code's hooks convention is `.claude/hooks/*.sh`; cortextOS templates don't use that path (they use `.claude/skills/` for skill scripts but not `.claude/hooks/` for lifecycle hooks). Recommended resolution in §2.1: render the two scripts to `.claude/hooks/` so they integrate with Claude Code's hook discovery; CLAUDE.md preamble (synthesised from agent.md per §2.1) references them by name.
docs/architecture/agent-bundle-renderer-design.md:55:- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:110:| `agents/recruitment/<name>/config.schema.json` | `orgs/<org>/agents/<name>/config.json` | **Synthesis** | (1) `config.schema.json` (the JSON Schema itself, used for validation); (2) `/vault/{tenant-slug}/_config.yaml` per Ultraplan §5.1 line 220 (provides per-tenant values that fill schema fields); (3) bundle-level defaults from any `default` keys in the schema; (4) common-*.json shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) — spec gap §2.1-B on where common schemas live | Materialised JSON validates clean against the source schema using Ajv (or equivalent) before the renderer writes; required fields all populated; no extra fields beyond schema. Daemon-required fields (per §1.2): `enabled` defaults true, `runtime` defaults `claude-code`, `max_session_seconds` defaults 255600, `working_directory` defaults to the rendered agent dir |
docs/architecture/agent-bundle-renderer-design.md:116:| _(no IFOS source)_ | `orgs/<org>/agents/<name>/.env` | **Synthesis** | (1) `tools.yaml` MCP server list (declares which credentials are needed: `BULLHORN_OAUTH_TOKEN`, `MS_GRAPH_TOKEN`, etc.); (2) `/vault/{tenant-slug}/_secrets.env` — spec gap §2.1-C (Ultraplan §5.1 doesn't enumerate this file but it's the natural place for per-tenant credentials); (3) the agent's per-bot Telegram credentials from the same secrets file (`BOT_TOKEN`, `CHAT_ID`, `ALLOWED_USER`) per cortextOS Primitive 5 contract | All MCP server tokens declared in `tools.yaml` resolve to a non-empty value; `BOT_TOKEN` matches `/^\d+:[A-Za-z0-9_-]+$/` per `agent-manager.ts:218`; `ALLOWED_USER` is numeric per `agent-manager.ts:224`; file written `chmod 0600` (credentials) |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:119:| _(no IFOS source — cortextOS templates ship 24 skills)_ | `.claude/skills/{activity-channel, agent-browser, ..., worker-agents}` (24 dirs) | **Drop** | n/a | n/a — the R2 commitment per design §1.7 + ADR-002 Decision 1. Detailed itemisation in §2.2 below |
docs/architecture/agent-bundle-renderer-design.md:123:- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:125:- **§2.1-C:** Ultraplan §5.1 line 220 names `_voice/`, `_playbooks/`, `_decisions/`, `_config.yaml` under `/vault/{tenant}/` but does not enumerate `_secrets.env`. Recommended resolution: add `_secrets.env` to the per-tenant vault skeleton; created at tenant provisioning (Ultraplan §5.5 line 263 `provision-tenant.sh {slug}` step 2). Mode `0600` owned by `ifos-tenant-{slug}`. Per Master Brief §3.3 "structured data lives in Postgres" applies to entity data; per-tenant *secrets* are the canonical exception that lives on the filesystem.
docs/architecture/agent-bundle-renderer-design.md:133:- **ADR-002 Decision 1** — cortextOS KB stays untouched; IFOS agents don't call `kb-*`. Inheriting `knowledge-base` and `memory` skills would mean IFOS agents have on-disk documentation telling them to invoke commands that, per ADR-002, they must not invoke.
docs/architecture/agent-bundle-renderer-design.md:135:- **Master brief §3.1 (submodule boundary stays intact)** — the §3.1 exception for the four `bus/kb-*.sh` shadow points is already a dead clause per ADR-002. Inheriting cortextOS skills would introduce a new implicit "shadow" — IFOS agents would carry skill documentation that points back into cortextOS's surface — undoing the cleanliness ADR-002 established.
docs/architecture/agent-bundle-renderer-design.md:141:| `knowledge-base` | Calls `kb-query` / `kb-ingest` / `kb-collections` / `kb-setup` against cortextOS's mmrag/ChromaDB KB | IFOS uses `wiki-*` parallel bus wrappers against `/vault/{tenant}/wiki/` + Postgres `entities` / `entity_links` per ADR-002 Decision 2 and design §2.3 / §2.4 |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:144:| `tasks` | cortextOS task management — `create-task` / `update-task` / `complete-task` against the `orgs/{org}/tasks/` directory | IFOS uses Postgres `decision_log` for the "what did this agent do" trail and the wiki for the "what's the state of this entity" view. The cortextOS task store is unused by IFOS agents (parallel to the KB-untouched decision per ADR-002 Decision 1) |
docs/architecture/agent-bundle-renderer-design.md:153:**Spec gap §2.2-A:** master brief §8.1 doesn't specify the opt-in syntax in `tools.yaml`. Recommended resolution: add a top-level `cortextos_skills:` block in `tools.yaml` with a list of skill names. Example:
docs/architecture/agent-bundle-renderer-design.md:298:Note: `wiki-*` bus operations are NOT declared in `tools.yaml` per ADR-002 Decision 2 — they're internal bus commands. `cortextos_skills:` is empty per the R2 default (§2.2).
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:465:Rationale: matches existing IFOS package convention. Master brief §4.1 line 195-204 enumerates the operative package directories (`packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}/`); the renderer is a distinct concern (bundle → runtime translation) that doesn't belong inside any of those. It's not the brain (wiki content, per ADR-002), not the harness (read-only submodule per master brief §3.1), not agents-runtime/_shared/ (the shared helper *content*, not the *tooling* that materialises agents). Standalone `packages/agent-renderer/` keeps the surface clean.
docs/architecture/agent-bundle-renderer-design.md:475:- `packages/brain/agent-cli/` — extending the brain CLI; rejected because the brain CLI is wiki ops (per ADR-002 Decision 2), and bundle rendering is not a wiki concern. Coupling two distinct CLIs into one package raises lock-in cost.
docs/architecture/agent-bundle-renderer-design.md:491:- **Git pre-push hook:** fires too late — the push lands the bundle source in git, but the target tenant filesystem is on a different host (Hetzner UK VPS per Ultraplan §5.1 line 218), so a pre-push hook on a dev laptop has no access to the tenant vault to render against. v1.1+ if a hook integrates with a CI runner that has tenant access.
docs/architecture/agent-bundle-renderer-design.md:538:- **Per-tenant config:** `/vault/<tenant>/_config.yaml` per Ultraplan §5.1 line 220.
docs/architecture/agent-bundle-renderer-design.md:540:- **Schema refs:** `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` per spec gap §2.1-B and Ultraplan §5.3 line 357-364.
docs/architecture/agent-bundle-renderer-design.md:646:**Recovery:** stderr lists missing paths. Founder scaffolds the missing helpers (Week-1 prerequisite per ADR-002). Re-runs.
docs/architecture/agent-bundle-renderer-design.md:666:**Recovery:** stderr: `Tenant <slug> not provisioned. Run: bash scripts/provision-tenant.sh <slug>`. Founder runs `provision-tenant.sh` per Ultraplan §5.5 step 2. Re-runs render.
docs/architecture/agent-bundle-renderer-design.md:702:New escalation code added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3:
docs/architecture/agent-bundle-renderer-design.md:718:The cortextOS `cortextos-ifos add-agent` command (`packages/harness/cortextos/src/cli/add-agent.ts:18-316`) is **unchanged**. IFOS does **not** use it for IFOS-owned agents. The R2 commitment per ADR-002 §1.7-A drives this.
docs/architecture/agent-bundle-renderer-design.md:760:| `packages/agents-runtime/_shared/{voice-loader,hook-helpers}.sh` (per ADR-002 prerequisite) | Claude Code | Weeks 1-2 |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:771:Three edits flagged. The first two land in their own ADR-003 commit alongside the design and ADR-003 (this batch's session-close commit); the third joins the atomic correction commit that ADR-001 + ADR-002 already queue.
docs/architecture/agent-bundle-renderer-design.md:800:**Edit C — Master brief §8.1 add renderer reference:**
docs/architecture/agent-bundle-renderer-design.md:804:**Proposed:** add a one-paragraph footnote at the end of §8 (before §8.1): "The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly. The renderer (`packages/agent-renderer/`, per ADR-003) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant)."
docs/architecture/agent-bundle-renderer-design.md:806:Edit A and Edit B land in this batch's commit alongside ADR-003. Edit C joins the atomic correction commit (it's a substantive wording change, parallel to ADR-002 Edit 1 and Edit 2; ratified together by Codex on Day 7).
docs/architecture/agent-bundle-renderer-design.md:829:- `packages/agents-runtime/_shared/common-*.json` (the schema $ref targets — seven files per Ultraplan §5.3 line 357-364).
docs/architecture/agent-bundle-renderer-design.md:830:- `_secrets.env` added to `provision-tenant.sh` skeleton — Day 4 of Week 0 (alongside the Postgres `entity_graph` rename per ADR-002 Edit 3).
docs/operations/codex-ratification-execution-plan.md:124:| 2 | ADR-002 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | A |
docs/operations/codex-ratification-execution-plan.md:127:| 5 | bullhorn-integration-path | `docs/decisions/bullhorn-integration-path.md` | A (Sub-decisions A+B Proposed; C Accepted) |
docs/operations/codex-ratification-execution-plan.md:128:| 6 | sequencing-target | `docs/decisions/sequencing-target.md` | A |
docs/operations/codex-ratification-execution-plan.md:198:**Total: 34 items.** Five items (Sub-decisions A+B in bullhorn-integration-path, brain-ui-scope as Proposed, items pending founder pre-resolution per Day-7 manifest §6) are reviewed as-is — Codex may flag the Proposed status as a non-blocking observation.
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:25:**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:31:Option A — **Tighten Gate A to per-claim citation** (matches Ultraplan). Requires implementing per-claim citation validation in `validate.sh` (significant logic; W4 polish item but Codex says it should be Gate A v0).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:33:Option B — **Amend Ultraplan §8.1 A1 line 497** to read "no unsupported claims at section level" (loosens upstream to match v0 implementation).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:263:- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:275:| Cash Conductor | 5 | `20260524T113038Z-83732` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:297:- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:300:- `ESC_OPEN_BANKING_TOKEN_AGING` — Cash Conductor uses <30 days warn / <7 days blocking staged; catalogue defines ≤14 days info. Resolution: align catalogue to Cash Conductor's actual staged definition.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:301:- `ESC_AUTOSEND_RACE` — Cash Conductor uses for payment-received-during-chase race; catalogue defines for two-agents-same-payload_hash race. Resolution: widen to cover both.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:317:  - Cash Conductor Steps 7-8, 11
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:355:- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:358:- `ESC_OPEN_BANKING_TOKEN_AGING` — three staged behaviors aligned to Cash Conductor §6
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:373:| Cash Conductor | 5 | 5 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:403:- **A) Amend ULTRAPLAN §8.1 A1 line 497** — change "no claims unsupported by source data" to "no claims unsupported at section level" to match v0 reality. Aggressive; rewrites upstream spec.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*
docs/operations/founder-legal-setup-guide.md:257:- Update `bullhorn-integration-path.md` with any UK-data-residency confirmations from solicitors
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:13:ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:19:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:58:**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:64:`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:74:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:103:- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:150:- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:152:*End of ADR-006.*
docs/operations/codex-round-2-remediation-prompt.md:192:  FIX 6 — bullhorn-integration-path.md line 95 + Gate Hierarchy subsection
docs/operations/codex-round-2-remediation-prompt.md:194:  File: docs/decisions/bullhorn-integration-path.md
docs/operations/codex-round-2-remediation-prompt.md:218:  | Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (sequencing-target §2.1) | Awaits Q1 LOI |
docs/operations/codex-round-2-remediation-prompt.md:234:       commit that lands the bullhorn-integration-path.md fix).
docs/operations/codex-round-2-remediation-prompt.md:389:    - bullhorn-integration-path.md  (FIX 6)
docs/operations/codex-round-2-remediation-prompt.md:474:        docs/decisions/bullhorn-integration-path.md \
docs/operations/codex-round-2-remediation-prompt.md:505:    - bullhorn-integration-path.md: line 95 sharpened + Gate hierarchy
docs/operations/codex-round-2-remediation-prompt.md:623:6. bullhorn-integration-path.md line 95 sharpening + Gate hierarchy subsection + disagreement doc closure + autosend-approval-bridge-spec.md category mapping rewrite + pii-purge-operational-pattern.md "Proposed pending D3"
docs/architecture/cortexos-kb-surface-investigation.md:6:**Surfaced by:** ADR-002 (in-progress, since superseded by the reframe — see "Why this document exists" below).
docs/architecture/cortexos-kb-surface-investigation.md:14:Drafting ADR-002 began with the plan to read all four real files and pick one of three outcomes (full shadow / mixed shadow + new wrappers / abandon shadow). After reading **only `kb-setup.sh`**, the substrate of cortextOS's KB became clear, and that substrate is incompatible with the IFOS wiki data model in master brief §5. The ADR's scope is too narrow to absorb that finding — it would be designing the second brain inside an architectural decision record, on the side of an audit.
docs/architecture/cortexos-kb-surface-investigation.md:109:3. **Claude writes `ADR-002` against the design.** The decision is binding; the design is the evidence.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:167:OR open a follow-on ADR if the decision warrants more substantive recording (e.g., ADR-005 for D1; ADR-006 for D2 + D3 bundle).
docs/architecture/vault-concurrency.md:3:**Status:** Reference (no Proposed/Accepted lifecycle). Synthesis of `docs/architecture/second-brain-design.md` §2.6 + `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` Decisions 2-3 + `docs/decisions/sequencing-target.md` §5-A `decision_log.phase` extension.
docs/architecture/vault-concurrency.md:6:**Surfaced by:** `ADR-002` §"For Week 1 work" + `second-brain-design.md` Spec gap 2.6 + `sequencing-target.md` §6.5 (Day-4 Postgres provisioning consolidation).
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:21:- **Wiki library** (`packages/brain/wiki/lib/*.ts` per ADR-002 Decision 2) — the read/write API every agent invokes; serialises and coordinates the above.
docs/architecture/vault-concurrency.md:30:Four mechanisms address these four failure modes in §2-§5. **All four mechanisms must be implemented in `wiki/lib/concurrency.ts`** for the wiki API to ship in v1.0 weeks 11-13 per `sequencing-target.md` §4.1 row 6 (Concierge, the heaviest concurrency stressor).
docs/architecture/vault-concurrency.md:35:- Multi-tenant filesystem isolation — kernel-enforced per Ultraplan §5.1 line 220 (`ifos-tenant-{slug}` OS user); not a concurrency concern within a tenant.
docs/architecture/vault-concurrency.md:36:- Cross-tenant read consistency — RLS handles this at the Postgres layer per ADR-002 Decision 3; not a wiki-library concern.
docs/architecture/vault-concurrency.md:192:- If second attempt also fails: raise `ESC_VAULT_VERSION_MISMATCH`, record in `decision_log` with `phase='gating_failed'` per `sequencing-target.md` §5-A enum extension, log human-readable error to operator Telegram per primitive 5 escalation surface.
docs/architecture/vault-concurrency.md:265:**Substrate:** discover all entities that reference the target via `entity_links` table per `second-brain-design.md` §2.4.2; iterate in deadlock-safe order; apply the rewrite under per-entity flock per §2; update `entity_links` rows in a single Postgres transaction per ADR-002 Decision 3.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:429:**None from this document.** The concurrency design was already authorised by `ADR-002` Decisions 2-3 + `second-brain-design.md` §2.6. This document is reference / specification, not a new decision — it does not surface fresh master-brief drifts.
docs/architecture/vault-concurrency.md:441:The `entities.version` column is a new Day-4 tightening — joins the three already on the list per `sequencing-target.md` §6.5 (entity_graph split + `_secrets.env` + `decision_log.phase` enum extension). Day-4 task now has **4 consolidated tightenings**.
docs/architecture/cortexos-primitive-status.md:9:Two findings need founder review before the Day 7 single-sentence test (master brief §6 / Ultraplan §12). Both are master-brief drifts against the verified SHA, surfaced in Primitive 3:
docs/architecture/cortexos-primitive-status.md:22:| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:25:| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
docs/architecture/cortexos-primitive-status.md:61:- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:66:**Risk if flaky:** Tier-1 always-on agents collapse to scheduled cron with cold-start latency, eliminating the "sub-second to first useful action" claim that justifies pricing the Triage/Concierge/Pulse demos above point-tool parity (Ultraplan §3.2). Per Ultraplan §3.1 row 1, the documented contingency is: "Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving." Quirk 2 (`.agents/learnings/00-cortextos-quirks.md`) — `node-pty` requires `npm rebuild` on Node 25+ — is the most likely re-trip wire because the Mac Studio cluster nodes for the v2.0 Sovereign tier may not run Node 22 LTS by default.
docs/architecture/cortexos-primitive-status.md:124:**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:259:**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.
docs/architecture/cortexos-primitive-status.md:296:Telegram is mature, hardened, and well-tested. iOS is explicitly "coming soon" in the README and has no APNs/push-notification code path — only an `outbound-messages.jsonl` log shape that a future iOS app would consume. Ultraplan §3.1 row 5 already accepts iOS deferral to v1.2, so this is not a v1.0 blocker.
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:328:**Risk if flaky:** Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5 ("iOS in v1.2 is the marketing line, not a tech blocker"). Real risk is Telegram outage during a Cash Conductor escalation, which is exactly what the activity-channel + per-agent-bot belt-and-braces pattern (primitive 4 evidence, `approval.ts:222-226`) was built to mitigate after the "50h+ Repo-B-style stall" incident.
docs/architecture/cortexos-primitive-status.md:370:Full experiment lifecycle code, dedicated sprint-3 test file, fully-documented 8-phase theta-wave skill shipped in the `analyst` template. Approval-gate integration ties it back into primitive 4. Not on the v1.0 critical path — Ultraplan §3.1 row 6 already defers it to v1.1 Night Sourcer.
docs/architecture/cortexos-primitive-status.md:389:- v1.0: **No agent depends on this.** Ultraplan §3.1 row 6: "This is for the Night Sourcer in v1.1, not v1.0. Defer the question."
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:456:- v1.0: **No agent depends on this.** Ultraplan §3.1 row 7: "This is for v1.1+. Defer."
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/architecture/cortexos-primitive-status.md:460:**Risk if flaky:** Brief Decoder slips to v1.2 — the documented contingency in Ultraplan §3.1 row 3. Loses the "shortlist in 90 minutes" demo for the Growth tier. The "orchestrator-coupled Telegram polling" trade-off (`agent-manager.ts:465-472`) means if the orchestrator agent itself crashes, the activity-channel callbacks stop until restart — primitive 1's crash-loop alert covers that case.
docs/RISK-REGISTER.md:4:the top. Full risk list is in master brief §12 and Ultraplan §10.
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:50:Full risk register per master brief §12 / Ultraplan §10. Port the remaining
docs/RISK-REGISTER.md:60:- 2026-05-16 (Day 2) — Risk #2 status entry updated: Sub-decision C **Accepted** per `bullhorn-integration-path.md` §4 + §5; Sub-decisions A and B **Proposed** with named reduction triggers (Sunday/Monday commercial conversations). Two staged severity reductions specified (High → Medium on commercial answers; Medium → Low on first Week 3-4 Bullhorn write landing clean). Risk #7 edit count revised from 5 to 6 (Bullhorn decision §6.6 sixth edit added — master brief §6 Day 2 line 466 `service-account for dev` correction). No new risks surfaced from Day 2 — Sub-decisions A and B Proposed is the intended honest state pending commercial verification, not a new risk surface.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/architecture/second-brain-design.md:4:**Status:** Reference. Q3 recommendation non-binding; ADR-002 ratifies it.
docs/architecture/second-brain-design.md:5:**Surfaced by:** `docs/architecture/cortexos-kb-surface-investigation.md` — the cortextOS KB substrate is incompatible with the IFOS wiki data model, and the gap is large enough that the second brain needs its own design before ADR-002 can land.
docs/architecture/second-brain-design.md:8:**Reading order:** the investigation doc first, then this. Then ADR-002.
docs/architecture/second-brain-design.md:52:**IFOS agents do not run cortextOS's heartbeat-memory pattern.** The IFOS Agent Bundle v2 (master brief §8.1) specifies six files per agent:
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:78:The exception in §3.1 becomes a dead clause: there are four `bus/kb-*.sh` files but we don't shadow them. The §3.4 wording needs to change to reflect this (ADR-002 will specify the replacement wording).
docs/architecture/second-brain-design.md:110:**But IFOS Agent Bundle v2 is a different shape.** Master brief §8.1 specifies six files plus three fixture directories:
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:154:Two source documents touch on vault structure. Master brief §5.1 (lines 297-349) and Ultraplan §5.1 (line 220) **disagree** — flagged as **Spec gap 2.1-A** in the final section. Master brief wins per §0; this design merges the two so nothing is lost.
docs/architecture/second-brain-design.md:161:/vault/{tenant-slug}/                               ← path per master brief §3.3 line 217, Ultraplan §5.1 line 217
docs/architecture/second-brain-design.md:162:├── _voice/                                         ← voice profile (Ultraplan §5.1 line 220)
docs/architecture/second-brain-design.md:163:│   ├── style-guide.md                              ← master brief §5.5 footnote, Ultraplan §5.2 wizard Day 3
docs/architecture/second-brain-design.md:164:│   ├── tone-rules.yaml                             ← Ultraplan §6.1 line 312
docs/architecture/second-brain-design.md:165:│   └── samples/                                    ← Ultraplan §6.1 line 313 — 20+ pasted emails, embedded in pgvector
docs/architecture/second-brain-design.md:166:├── _playbooks/                                     ← firm SOPs (Ultraplan §5.1 line 220)
docs/architecture/second-brain-design.md:168:├── _config.yaml                                    ← per-tenant config (Ultraplan §5.1 line 220)
docs/architecture/second-brain-design.md:190:└── temp/                                           ← if Temp tier active (Ultraplan §5.1 line 220) — v1.1+ deferred for IFOS Temp launch
docs/architecture/second-brain-design.md:197:| `_voice/style-guide.md` | one file | markdown | fixed name | Onboarding wizard Day 3 (founder); Concierge edits via Brain UI v1.1+ | every agent's `context.sh` via `_shared/voice-loader.sh` (Ultraplan §6.1 line 322) |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:203:| `wiki/raw/inbox-emails/` | one file per email | markdown with frontmatter | `{epoch}-{from-domain}-{rand5}.md` | inbound email webhook handler (v1.0: Cash Conductor for AR-relevant; v1.1: Triage for everything) | Brief Decoder (v1.1), Cash Conductor (v1.0); future Pulse semantic-search-over-raw |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:221:**Filesystem-ownership note** (Ultraplan §5.1 line 218-223): `/vault/{tenant-slug}/` is owned by OS user `ifos-tenant-{slug}` in group `ifos-tenants`, mode `0700` on the tenant root, `0644` on files. Kernel-enforced isolation per Ultraplan §5.2 "kernel-stops cross-tenant test passes" on Day 4 of Week 0.
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:227:Eight canonical entities exist per master brief §6 Day 6 / Ultraplan §11 Day 6 line 490:
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:311:xero_contact_id: 9876                                # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:362:invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:430:| `semantic-search-over-raw` | future Pulse (v1.2): "any inbox emails mentioning compliance risk in last 30 days" | **v1.2+ deferred** | `(query: str, raw_collection: str, tenant_id: str, date_range?: tuple)` | `List[RawChunkRef]` ranked by similarity | few seconds | The only operation where cortextOS's mmrag/ChromaDB substrate is a plausible candidate. v1.0/v1.1 don't need it — flagged in Q3 as the one place ADR-002 should leave a forward-compatible hook |
docs/architecture/second-brain-design.md:432:| `delete-entity` | any agent + human override; soft via `archive/` move | **v1.2+ deferred** | `(id: str, mode: 'soft'\|'hard', tenant_id: str)` | `EntityRef` (with `status: archived`) | few seconds | Master brief §5.1 line 332 implies soft via archive/; hard delete is GDPR-driven (Ultraplan §5.5 line 275 day-60 cryptographic erase) but operates at tenant level, not entity level |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:440:- Hard-delete-per-entity — v1.2+; v1.0/v1.1 hard-delete is only at tenant offboarding (Ultraplan §5.5)
docs/architecture/second-brain-design.md:442:**The `semantic-search-over-raw` row is the bridge to ADR-002.** Q3 will recommend whether to use cortextOS's mmrag/ChromaDB for this future operation (which would require shadowing exactly the `bus/kb-ingest.sh` + `bus/kb-query.sh` pair against `raw/` content), or build an IFOS-native pgvector index over raw/ — both are tenable, both are v1.2+ work, neither needs a decision before Week 11.
docs/architecture/second-brain-design.md:450:- **Path:** `/vault/{tenant-slug}/` on the shared encrypted LUKS volume (Ultraplan §5.1 line 218). Sub-paths per §2.1 above.
docs/architecture/second-brain-design.md:451:- **Ownership:** OS user `ifos-tenant-{slug}` in group `ifos-tenants`, mode `0700` on the tenant root, `0644` on files (Ultraplan §5.1 lines 218-223). The PM2 agent process for tenant X runs as `ifos-tenant-{X}` and cannot read tenant Y's vault — kernel enforces this.
docs/architecture/second-brain-design.md:458:  - **Filesystem:** Restic nightly to S3-compatible UK-region storage, 30 days of dailies + 12 months of monthlies (Ultraplan §5.6 line 281). RPO 5 minutes, RTO 4 hours (Ultraplan §5.6 line 283).
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:463:Three tables anchored in Ultraplan §5.1 line 227 ("`tenants`, `entity_graph`, `decision_log`"). The IFOS design here renames `entity_graph` to **`entities`** (one row per entity) and adds **`entity_links`** (the adjacency table) — both flagged below as **Spec gap 2.4-B** because Ultraplan groups them under a single name.
docs/architecture/second-brain-design.md:465:**Table: `tenants`** (master brief §3.3 + Ultraplan §5.1)
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:567:Partitioned by hash on `tenant_slug` (Ultraplan §5.1 line 228: "Both `entity_graph` and `decision_log` partitioned by `tenant_id` (hash partitioning, 32 partitions to start)"). This is the **only** source of entity-history queries — the `_decisions/` directory in Ultraplan §5.1 line 220 is for narrative summaries (Spec gap 2.1-B remains; recommended resolution: `_decisions/` is for founder-written end-of-quarter narratives only, not for agent decisions; agent decisions live exclusively in `decision_log`).
docs/architecture/second-brain-design.md:569:**Spec gap 2.4-B:** Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`". This design splits them into `entities` + `entity_links` for clearer indexing semantics. **Recommended resolution:** adopt the split; update master brief §3.3 or Ultraplan §5.1 to reflect the two-table model. Codex-ratifiable on Day 7 by reading this section.
docs/architecture/second-brain-design.md:575:**v1.0 use:** voice corpus only. Ultraplan §6.1 line 314 says "samples/{n}.md — raw samples indexed for RAG retrieval (embedded with pgvector at capture time)" and line 322 says voice-loader.sh retrieves "the 3 most semantically similar past samples to the current task via pgvector cosine similarity."
docs/architecture/second-brain-design.md:600:1. **Forward-compatibility with semantic-search-over-raw (v1.2+).** If the eventual Pulse-like agent uses cortextOS's mmrag/ChromaDB for raw/ content, IFOS-side and cortextOS-side embeddings live in the same vector space and a query embedded once can search both indexes. ADR-002 will recommend keeping this hook open.
docs/architecture/second-brain-design.md:615:**v1.2+ forward-compatibility hook:** the semantic-search-over-raw operation (v1.2+) is the one place where cortextOS's substrate could come back into the picture. ADR-002 will recommend leaving the option open — i.e. don't dismantle cortextOS's KB tooling — without scoping the v1.2 work now.
docs/architecture/second-brain-design.md:672:| `search-by-name` | Postgres `entities` trigram on `display_name` (`gin_trgm_ops`) | Filesystem grep over `wiki/compiled/{type}/*.md` frontmatter | Hot path; sub-second target. Fuzzy match returns top-N by similarity score; tie-break by `importance_score DESC` then `updated_at DESC`. Fallback only fires if Postgres unhealthy (per master brief §3.5 RLS / Ultraplan §3.5 degraded-mode contingency). |
docs/architecture/second-brain-design.md:680:| `semantic-search-over-raw` | **v1.2+ deferred** — placeholder primary = either cortextOS mmrag/ChromaDB **OR** IFOS-native pgvector over chunked raw/ content | n/a | ADR-002 will recommend keeping cortextOS's substrate available as the v1.2+ implementation option without committing to it now. |
docs/architecture/second-brain-design.md:688:**No operation reads via grep at hot path.** All hot-path reads go through Postgres. Filesystem reads are the source-of-truth fallback for the rare unhealthy-Postgres case (which itself triggers the degraded-mode fallback per Ultraplan §3.5).
docs/architecture/second-brain-design.md:701:- If the file lock times out (5 seconds), the operation fails with `ESC_VAULT_LOCK_TIMEOUT` per master brief §8.1 Change 3 vocabulary (new code; goes in `_shared/escalation-codes.md` v0.1).
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:773:| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:780:**Peak concurrent tenants on shared infra (v1.0):** 3-6 (Product Spec §3 first three paid pilots target). The shared Postgres + RLS model (Ultraplan §5.1 line 226) handles this trivially.
docs/architecture/second-brain-design.md:782:**Decision-log volume:** every agent run produces 1-3 `decision_log` rows (`hh_decision_trigger`, `hh_decision_output`, optionally `hh_decision_action` when human responds). At 6 v1.0 agents × ~10 runs/agent/day × 3 tenants × 3 rows = ~540 rows/day per shared Postgres instance. Trivial volume; the table needs hash partitioning (per Ultraplan §5.1) primarily for query performance at v1.2+ scale, not v1.0 write throughput.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/architecture/second-brain-design.md:891:| **Operational complexity** — new infrastructure introduced | None new. 12 shell wrappers + a Node CLI binary + a library; same shape as `packages/harness/cortextos/bus/`. No new PM2 process. | One new PM2 process per machine (`ifos-wiki-mcp`). Adds to the operations surface: process supervision, restart policy, port allocation, logs to manage. At Sovereign tier (one cluster slice per tenant per Ultraplan §5.4) this is one extra process per tenant. | Skill files added to every agent at scaffold time. Under R2 renderer (recommended), the renderer must be extended to inject the wiki skill — additional renderer logic. Under R1, automatic. |
docs/architecture/second-brain-design.md:895:| **Failure mode if cortextOS daemon is unhealthy** | Wrappers don't depend on the daemon — they exec directly into Node. As long as Postgres is up and the filesystem is mounted, wiki ops succeed. Decision_log writes still go through (Postgres direct). Tracks per Ultraplan §3.5 "Tier 1 agents have degraded-mode fallbacks" — the wiki is part of the fallback substrate, not part of what fails. | If `ifos-wiki-mcp` crashes, every agent loses wiki access until it restarts. PM2 auto-restart bounds the outage to ~5s, but during the outage every wiki call fails. If `cortextos-daemon` is unhealthy, MCP connections from agents (which are in PTYs supervised by the daemon) may also be affected. Two-process dependency. | Same as α (library invoked directly, no daemon dependency) but adds skill-discovery path: if the agent's Claude Code session can't find the skill (e.g. corrupted scaffold), all wiki ops fail. |
docs/architecture/second-brain-design.md:907:2. **Master brief §8 (Agent Bundle v2 pattern + `tools.yaml` contract).** §8.1 specifies the bundle has `tools.yaml` for "MCP servers + scopes + degraded modes" — i.e. external MCP connectors (Bullhorn, Companies House, Xero). The wiki is **internal** to IFOS, not an external execution backend. Treating wiki ops as bus commands (Option α) keeps `tools.yaml` clean of internal-surface declarations; treating them as MCP tools (Option β) conflates internal-data-access with external-tool-invocation in the same `tools.yaml`.
docs/architecture/second-brain-design.md:908:3. **Master brief §3.5 + §5.5 (multi-tenancy + onboarding wizard 5-day flow).** §3.5's "100 customers by end of 2027" stress test (Product Spec §5.4) demands zero per-customer operational drag. Option α adds no per-customer infrastructure. Option β at Sovereign tier (Ultraplan §5.4 per-tenant cluster slice) means one `ifos-wiki-mcp` process per Sovereign tenant — a new operational surface to monitor at scale.
docs/architecture/second-brain-design.md:922:- **v1.2+ semantic-search-over-raw:** ADR-002 will recommend keeping this hook open. Under Option α, the eventual implementation is a `wiki-semantic-search.sh` that internally chooses either cortextOS's mmrag (the v1.2+ option) or an IFOS-native pgvector-over-raw index — no agent-side change.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/second-brain-design.md:967:| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
docs/architecture/second-brain-design.md:968:| **2.1-B** | `_decisions/` directory (Ultraplan §5.1) overlapping with Postgres `decision_log` table | Two candidates for "where agent history lives" | Resolved in §2.4.2: `_decisions/` is for founder-written end-of-quarter narratives only; agent decisions live exclusively in Postgres `decision_log`. Update Ultraplan §5.1 wording. | No |
docs/architecture/second-brain-design.md:969:| **2.1-C** | `wiki/compiled/playbooks/` (master brief §5.1 line 331) collides with `/vault/{tenant}/_playbooks/` (Ultraplan §5.1) | Same folder name at two paths with different intended uses | **Recommendation:** drop `wiki/compiled/playbooks/`. Playbooks live at `/vault/{tenant}/_playbooks/` only. Update master brief §5.1 to remove the `playbooks/` line from the `wiki/compiled/` tree. | No |
docs/architecture/second-brain-design.md:972:| **2.4-A** | Master brief / Ultraplan silent on git for tenant vault | No backup-via-git mechanism specified | `git init` at tenant provisioning (`provision-tenant.sh` Ultraplan §5.5 step 2). Founder commits via Obsidian Git plugin; agents don't commit. | No — commit cadence can be decided Week 1+. |
docs/architecture/second-brain-design.md:973:| **2.4-B** | Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`" | Single-table model insufficient for the JSONB GIN + trigram + adjacency mix v1.0 needs | Split into `entities` + `entity_links` per §2.4.2. Update master brief §3.3 / Ultraplan §5.1 wording. **Roll into Week 0 Day 4 Postgres provisioning.** | **Tight** — Day 4 of Week 0 (this week). |
docs/architecture/second-brain-design.md:974:| **2.4-C** | Master brief / Ultraplan silent on embedding model | No model specified for voice_samples_embedded or future compiled/ embeddings | Adopt `gemini-embedding-001` (3072 dims) — matches cortextOS's KB substrate per kb-setup.sh migration target. Same `GEMINI_API_KEY` serves both. Revisit if a sharply better model ships before Week 11. | No |
docs/architecture/second-brain-design.md:976:| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
docs/architecture/second-brain-design.md:979:**Five gaps are already resolved inline in this design** (2.1-B, 2.1-C, 2.2-A, 2.2-B, 2.6 with mechanisms in §2.6.x). **Three need master-brief / Ultraplan edits in the atomic correction commit** (2.1-A wording reconciliation, 2.4-B / 3.4-B Postgres table-rename, 3.4-A v1.0 brain wording rewrite). **Two are Week-1 prerequisite artefacts** (§1.7-A renderer ADR-003 + `agent-bundle-renderer-design.md`; 2.6 companion `vault-concurrency.md`). **Two are operational defaults** that the founder can either ratify or override at any later point (2.4-A git init at provisioning; 2.4-C `gemini-embedding-001` model choice).
docs/decisions/ADR-003-agent-bundle-renderer.md:5:**Surfaced by:** `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §"For Week 1 work" + `docs/architecture/agent-bundle-renderer-design.md` (full design)
docs/decisions/ADR-003-agent-bundle-renderer.md:13:ADR-002 §1.7-A surfaced the spec gap. Master brief §8 (lines 545-568) specifies the IFOS Agent Bundle v2 — six files plus three fixtures at `agents/recruitment/<name>/` — but is silent on how the bundle becomes a runnable cortextOS agent. The cortextOS daemon's `AgentManager.discoverAndStart()` (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`) reads from `${frameworkRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `CLAUDE.md`, `.env`). The two layouts are incompatible without translation.
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:70:Three edits per design §5.3. Edits A and B land in this ADR's commit (small wording adds; Edit A is needed live before Week-1 renderer implementation). Edit C joins the deferred atomic correction commit alongside ADR-001 + ADR-002 edits.
docs/decisions/ADR-003-agent-bundle-renderer.md:133:**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.
docs/decisions/ADR-003-agent-bundle-renderer.md:135:**Proposed:** insert a one-paragraph footnote at the end of §8 (before §8.1):
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/ADR-003-agent-bundle-renderer.md:145:**For Week 0 remaining (Day 2 through Day 7).** ADR-003 doesn't unblock or block any remaining Week 0 work directly. Day 2 (Bullhorn integration path), Day 3 (sequencing + Brain UI scope), Day 4 (Postgres provisioning with `entities` + `entity_links` split per ADR-002 Edit 3 + `_secrets.env` skeleton), Day 5 (auto-send safety policy + kill criterion), Day 6 (vertical schema v0.1), Day 7 (single-sentence test + first Codex ratification) all proceed independently. The renderer is queued for Codex Day-7 review but does not gate Day 7's other reviews.
docs/decisions/ADR-003-agent-bundle-renderer.md:149:**For Codex Day-7 ratification queue.** ADR-003 + the design doc join the queue alongside `cortextos-primitive-status.md`, ADR-001, ADR-002, `second-brain-design.md`, the deferred atomic master-brief correction commit, and the Day-4 Postgres provisioning artefact. The 22-item spec gap consolidation in design §5.4 plus the four-bucket structure (resolved inline / master-brief edits / Week-1+ prerequisites / operational defaults) is the ratification-supporting evidence.
docs/decisions/ADR-003-agent-bundle-renderer.md:151:**For the master brief atomic correction commit.** Edit C (the §8 footnote) joins ADR-001 + ADR-002 edits in the deferred single commit at end of Week 0 / early Week 1. Edits A and B land in this batch's commit because (a) Edit A is needed live before Week-1 renderer implementation can scaffold the package path, (b) Edit B is a small wording add to a code block, (c) neither is substantive enough to warrant the atomic-correction overhead.
docs/decisions/ADR-003-agent-bundle-renderer.md:156:- **`_shared/` helper code authoring** (`voice-loader.sh`, `hook-helpers.sh` contents) — already on the Week-1 prerequisite list per ADR-002 §"For Week 1 work." Not an ADR; just implementation work.
docs/decisions/ADR-003-agent-bundle-renderer.md:157:- **`docs/architecture/vault-concurrency.md` companion document** — already on the Week-1 prerequisite list per ADR-002. Not an ADR; resolves design §2.6 spec gap.
docs/decisions/ADR-003-agent-bundle-renderer.md:164:2. Edit C (§8 footnote) joins ADR-001 + ADR-002 edits in the deferred atomic correction commit at end of Week 0 / early Week 1. Five-edit manifest for that commit confirmed: ADR-001 §2.4 row 3 + Ultraplan §3.2; ADR-002 Edit 1 §3.4 + Edit 2 §5.5; ADR-003 Edit C §8.
docs/decisions/v1.0-kill-criterion.md:7:**Surfaced by:** Master brief Day 5 spec; folds carry-forwards from `sequencing-target.md` §6.6 + `bullhorn-integration-path.md` §4.1 + Day-4 §11 closing-commit work.
docs/decisions/v1.0-kill-criterion.md:37:**v1.0 commitments to existing pilots are honoured under original scope.** New v1.0 contracts under rescoped terms. The master brief and Ultraplan are amended by atomic-correction commit; Codex ratifies before v1.0 resumption.
docs/decisions/v1.0-kill-criterion.md:67:**Source:** `sequencing-target.md` §6.6 failure condition (i); Risk #5 in `docs/RISK-REGISTER.md`; ADR-003 §"Consequences" line 141 (renderer is load-bearing Week-1 deliverable).
docs/decisions/v1.0-kill-criterion.md:75:**Threshold:** Janitor agent cannot authenticate to Bullhorn via the documented OAuth flow (per `bullhorn-integration-path.md` §4.5 refresh-loop architecture) by end of Week 5 (2026-06-28). Authentication failure modes that trigger: (a) OAuth token endpoint returns non-2xx persistently; (b) refresh-loop architecture fails at 10-minute TTL boundary; (c) Bullhorn rate-limits IFOS's auth endpoint preventing pilot operations; (d) Bullhorn partnership programme requirement blocks production-tenant access.
docs/decisions/v1.0-kill-criterion.md:79:**Source:** `sequencing-target.md` §6.6 failure condition (ii); Risk #2 in `docs/RISK-REGISTER.md`; `bullhorn-integration-path.md` Sub-decisions A + B (currently Proposed pending Sunday/Monday commercial conversations — which themselves have not happened due to design-partner-pipeline gap).
docs/decisions/v1.0-kill-criterion.md:89:**Recovery path:** PIVOT is structural; resumption is via rescoped v1.0 under new ATS assumption. Pivoted v1.0 continues with adjusted master brief / Ultraplan; atomic-correction commit lands the rescope.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:224:- **Trigger 6 (Unit economics):** founder decides PIVOT direction (cheaper model tier, reduced agent frequency, etc.) → consults Jack on pricing implications before locking → updates Ultraplan pricing plan.
docs/decisions/v1.0-kill-criterion.md:306:1. Rescope plan replaces affected slices of master brief and Ultraplan. New atomic-correction commit lands the rescope edits (separate from the existing 10-edit atomic-correction manifest — pivot is a wholly new manifest event).
docs/decisions/v1.0-kill-criterion.md:322:4. v1.1 — if launched — is a wholly new initiative under different premises. Not a continuation of v1.0. Has its own master brief, Ultraplan, kill criterion.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:339:- The ATS assumption: Bullhorn-first per `bullhorn-integration-path.md` Sub-decision C
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:1:# ADR-002 — Brain system as parallel, not shadow
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:62:- **Filesystem markdown** at `/vault/{tenant-slug}/wiki/` per design §2.1 (POSIX 0700 / 0644, per-tenant OS user `ifos-tenant-{slug}` per Ultraplan §5.1 line 218).
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:63:- **Postgres tables (v1.0):** `tenants`, `entities`, `entity_links`, `decision_log` — schemas in design §2.4.2. RLS by tenant_slug on every table except `tenants`. The Ultraplan §5.1 line 227 single `entity_graph` table is **split** into `entities` (one row per entity) and `entity_links` (adjacency) — see Spec gap 2.4-B in the design doc.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:69:The one operation where cortextOS's mmrag/ChromaDB substrate could still serve IFOS is **semantic-search-over-raw** against `/vault/{tenant}/wiki/raw/` content (per design §2.3 row 9). That operation is **v1.2+ deferred**. ADR-002 explicitly **does not commit** to either cortextOS-substrate or IFOS-pgvector-native for the eventual implementation. The decision is deferred to a future ADR (likely in v1.2 planning) so it can be made against then-current evidence: actual raw/ volume, actual query patterns, actual cost data on Gemini embeddings, and whether Anthropic or OpenAI has shipped a sharply better embedding model by then.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:105:This edit lands on **Day 4 of Week 0 (this week)** as part of the Postgres provisioning task per master brief §6 Day 4, **not** in the brain-ADR atomic commit. ADR-002 authorises the split; Day 4 implements it.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:111:**For Week 1 work.** ADR-002 makes three Week-1 prerequisites load-bearing:
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:117:**For Day 4 this week (Postgres provisioning).** The `entity_graph` → `entities` + `entity_links` split per Spec gap 2.4-B / 3.4-B must land in the Day 4 migration. This is the only immediate-week impact of ADR-002.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:123:**For future ADRs.** ADR-002 explicitly defers three decisions:
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:133:1. ADR-001 + ADR-002 master-brief edits LANDED in atomic-correction commit `0e5b2b4` (Day 7 2026-05-20). Status: closed.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:6:**Source:** Master brief §6 Day 7 lines 492-501 + Ultraplan §12
docs/decisions/2026-05-18-day-7-single-sentence-test.md:14:> Single-sentence test (Ultraplan §12). Answer each Y/N:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:34:- **Pipeline state:** zero design partners in pipeline as of 2026-05-18 Day 5; founder did not initiate the Sunday/Monday outreach paths queued in `bullhorn-integration-path.md` §1.3 (Bullhorn partnerships, Bullhorn dev support, design partner #1) because no named target existed for design-partner #1 path; warm-path strategy supersedes cold outreach.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:45:- **Primitive 5 (Telegram + iOS approval surface):** confirmed shipped per `cortexos-primitive-status.md` audit. Two-poller mechanism (`agent-manager.ts:478-575`, `maybeStartActivityChannelPoller()`) integrates with primitive 4 approval gates. Per master brief §12 Risk #1 framing: "Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:56:- **Auth path cleared: NO.** Sub-decisions A (marketplace vs direct API) and B (OAuth flow specifics — authorization-code grant against IFOS-owned dev tenant) remain Status: Proposed in `bullhorn-integration-path.md`. The technical path is documented but the commercial gates have not passed:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:68:- **Sequencing:** `docs/decisions/sequencing-target.md` §4.1 ratifies the 6-agent build order; renderer is Week 1-2 prerequisite for the Diagnostic W3-4 first render per ADR-003 §5.2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:93:| 4 | Agent Bundle v2 refactor scoped + <5 days? | **YES** | High — ADR-003 + sequencing-target + design doc all Accepted |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/brain-ui-scope.md:6:**Surfaced by:** Master brief §6 Day 3 line 472 — "Brain UI v1.0 scope decision" + ADR-002 §3.4 closing paragraph (Brain UI explicitly forward-deferred to v1.1) + `second-brain-design.md` §3.4 ("Brain UI minimal v1 is built as a thin read-only page over `decision_log` — no new wiki API needed").
docs/decisions/brain-ui-scope.md:9:**Reading order:** master brief §5.5 (Brain UI build sequence stages) + ADR-002 (parallel-not-shadow + v1.0 brain build wording correction) + `second-brain-design.md` §3.4 closing paragraph (Brain UI v1.0+ scope) first; then this document end-to-end.
docs/decisions/brain-ui-scope.md:15:Per master brief §5.5 (lines 416-424) after ADR-002 Edit 2 applies in the atomic correction commit, the staged Brain UI build is:
docs/decisions/brain-ui-scope.md:24:**Revisit trigger:** start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2 v1.1 timing). Three v1.0 observations will inform the v1.1 scoping session:
docs/decisions/brain-ui-scope.md:34:Three features named in master brief §5.5 (post-ADR-002-Edit-2 wording) + `second-brain-design.md` §3.4. Each feature scoped here without implementation commitment.
docs/decisions/brain-ui-scope.md:41:- Shows recent `decision_log` entries with phase + outcome filtering (`trigger | output | action | gating_failed | agent_handoff` per `sequencing-target.md` §5.3 + §6.5 enum extension).
docs/decisions/brain-ui-scope.md:42:- Highlights pending approvals (Concierge auto-send escalations per `bullhorn-integration-path.md` §4.1 row 4).
docs/decisions/brain-ui-scope.md:44:- Per-tenant scoped via RLS per ADR-002 §3 Decision 3; multi-tenant founder view aggregates across tenant_slugs.
docs/decisions/brain-ui-scope.md:55:**Dependency on v1.0:** wiki API live + `decision_log` populated per ADR-002 §3 Decision 3 + extended phase enum per `sequencing-target.md` §6.5.
docs/decisions/brain-ui-scope.md:134:No UI work. Wiki API + Postgres + pgvector + filesystem is the v1.0 deliverable per ADR-002 Edit 2 + `second-brain-design.md` §3.4 closing paragraph. Master brief §5.5 already correctly scopes this (post-Edit-2). No new constraint from this document.
docs/decisions/brain-ui-scope.md:176:> "- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation."
docs/decisions/brain-ui-scope.md:180:1. **Path** `.agents/decisions/brain-ui-scope.md` → `docs/decisions/brain-ui-scope.md` (same convention drift as line 471, fixed in `sequencing-target.md` §6.8 as the 7th edit).
docs/decisions/brain-ui-scope.md:181:2. **`kb-*` shadow language** → `wiki-*` parallel system (corrects against ADR-002 Edit 1 §3.4 brain-replacement seam wording).
docs/decisions/brain-ui-scope.md:182:3. **`/brain` today-view as v1.0 deliverable** → today-view is v1.1 (corrects against ADR-002 Edit 2 §5.5 v1.0 brain build wording).
docs/decisions/brain-ui-scope.md:187:2. ADR-001 Ultraplan §3.2: latency reframe
docs/decisions/brain-ui-scope.md:188:3. ADR-002 Edit 1 §3.4: shadow → parallel
docs/decisions/brain-ui-scope.md:189:4. ADR-002 Edit 2 §5.5: v1.0 brain build wording
docs/decisions/brain-ui-scope.md:191:6. `bullhorn-integration-path.md` §6.6: §6 Day 2 line 466 OAuth wording
docs/decisions/brain-ui-scope.md:192:7. `sequencing-target.md` §6.8: §6 Day 3 line 471 path convention
docs/decisions/brain-ui-scope.md:229:**Proposed.** Revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2). At revisit, founder + Claude Code:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:46:| **A. Accept the floor** | Leave `pollInterval` at the 1000ms default. Rewrite Ultraplan §3.2's "four-agent pipelines complete in seconds" to "four-agent pipelines complete in 3-5 seconds end-to-end" and remove any "sub-second handoff" framing from the closing-demo deck | Zero engineering | Honest signal; Concierge's "30-min lifecycle event → drafted comms" SLA is unaffected (3-5s is rounding error against 30 minutes); Brief Decoder's "90-min brief-to-shortlist" is also unaffected. Only sales narrative changes. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:59:- Single edit to Ultraplan §3.2: rewrite "four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes" → "four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound."
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:72:- The brain-replacement seam (§3.4) is unaffected by this ADR. ADR-002 covers that separately.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:76:**Accepted — Option A.** Founder decision logged 2026-05-16. The master brief §2.4 row 3 + Ultraplan §3.2 edits are deferred to a single atomic "spec drift reconciliation" commit that lands alongside whatever ADR-002 dictates for §3.4. Codex ratifies the combined commit on Day 7 with the other Week 0 artefacts.
docs/decisions/bullhorn-integration-path.md:6:**Surfaced by:** Master brief §6 Day 2 (lines 466-467) — "Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev." Plus Ultraplan §11 Day 2 (lines 847-849).
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:17:Three sub-decisions, named in master brief §6 Day 2 line 466 and extended in Ultraplan §11 Day 2 lines 847-849.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:37:| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:42:This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.
docs/decisions/bullhorn-integration-path.md:48:**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:104:| Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (`sequencing-target.md` §2.1) | Awaits Q1 LOI |
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:289:| **A1 Diagnostic** (no Bullhorn) | n/a | n/a | n/a | n/a | n/a | n/a — runs against public footprint per Ultraplan §8.1 line 489 |
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:319:- **On-disk per-tenant credentials:** `/vault/<tenant-slug>/_secrets.env`, mode `0600`, owner `ifos-tenant-<slug>`, group `ifos-tenants`. Filesystem isolation per Ultraplan §5.1 line 218.
docs/decisions/bullhorn-integration-path.md:323:- **Per-agent token isolation:** each IFOS agent process loads only its tenant's credentials at start via the renderer-materialised `.env`. No cross-tenant token sharing — kernel-enforced via the per-tenant OS user model (Ultraplan §5.1 line 220 "agent process for tenant X runs as `ifos-tenant-{X}`").
docs/decisions/bullhorn-integration-path.md:324:- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
docs/decisions/bullhorn-integration-path.md:442:§3.2 finding (Bullhorn does NOT support client_credentials grant for tenant-scoped data per public OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`) forecloses the master brief §6 Day 2 line 466 pre-statement. New sixth edit for the atomic correction commit alongside ADR-001 + ADR-002 + ADR-003 Edit C.
docs/decisions/bullhorn-integration-path.md:446:> "- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev. Document in `docs/decisions/bullhorn-integration-path.md`"
docs/decisions/bullhorn-integration-path.md:450:> "- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: authorization-code grant for production tenants; authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (Bullhorn does not support `client_credentials` grant for tenant-scoped data per Bullhorn OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`). Document in `docs/decisions/bullhorn-integration-path.md`."
docs/decisions/bullhorn-integration-path.md:460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
docs/decisions/bullhorn-integration-path.md:492:| 6th edit | Master brief §6 Day 2 line 466 | `service-account for dev` → `authorization-code grant against an IFOS-owned Bullhorn dev tenant` (per §6.6) | Joins atomic correction commit at end of Week 0 / early Week 1, alongside ADR-001 + ADR-002 + ADR-003 Edit C |
docs/decisions/bullhorn-integration-path.md:502:| `ESC_BULLHORN_AUTH` escalation code wired into `agents/_shared/escalation-codes.md` | Claude Code | Week 1-2 (alongside `_shared/hook-helpers.sh` Week-1 prereq from ADR-002) |
docs/decisions/sequencing-target.md:6:**Surfaced by:** Master brief §6 Day 3 (lines 469-473) — "Confirm or revise Ultraplan §9's 'close first 3 pilots fastest' → `.agents/decisions/sequencing-target.md`" (note: master brief §6 names `.agents/decisions/`; this document lives at `docs/decisions/sequencing-target.md` matching the convention established by ADR-001 through ADR-003 + bullhorn-integration-path.md — **Spec gap §1-A** flagged for atomic correction).
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:32:- **A. First agent.** Which agent ships first in Week 3-4? Anchors the renderer (ADR-003) + `_shared/` helpers (Week-1-2 prereqs from ADR-002) + Postgres `decision_log` (Day 4 Week 0) end-to-end test. Affects how risk surfaces — first agent is the smoke test for every substrate dependency.
docs/decisions/sequencing-target.md:42:**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
docs/decisions/sequencing-target.md:46:The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
docs/decisions/sequencing-target.md:50:Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
docs/decisions/sequencing-target.md:57:| 4 | **Commercial value** | Whether the agent's output is demoable to a design partner / first paying customer per Product Spec §2.2 R-rows | Earlier commercial-value agents accelerate the first-pilot conversion (Ultraplan §9 line 725 target Week 12); but commercial-value agents are typically the more complex ones, conflicting with criterion 1 |
docs/decisions/sequencing-target.md:65:Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:99:| 4. Commercial value | **Medium** | Internal sales tool per Product Spec §2.2 R13 ("Not on the customer pricing card"). Drives qualified discovery-call pipeline. Demoable to a prospect but not the closing demo. Ultraplan §8.1 line 499 Gate B target: "≥30% of diagnostics produced lead to a discovery call booked" |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:109:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 513 estimate **L (2 weeks)** — the Bullhorn MCP work is rate-limiting per Ultraplan §8.1 line 514 ("Bullhorn MCP server doesn't exist yet — this is the critical-path build"). One MCP server (Bullhorn) + Companies House for enrichment. Single primary output (cleanup report) but with continuous nightly cron pattern |
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:111:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:118:### 2.3 — A3 Scribe
docs/decisions/sequencing-target.md:122:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 526 estimate **M (1 week)**. Webhook-driven not always-on. Structured-field mapping is per-firm config not code per Ultraplan §8.1 line 526. Tacit-note extraction is the hard part per Ultraplan §8.1 line 527 ("Start with a small taxonomy (5-10 tacit-note types) and expand") |
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:127:| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:131:### 2.4 — A4 Cash Conductor
docs/decisions/sequencing-target.md:135:| 1. Implementation simplicity | **Medium-High** | Ultraplan §8.1 line 541 estimate **L (2 weeks)**. Three accounting integrations (Xero / QuickBooks / Sage — one per tenant per Ultraplan §8.1 line 537). Open Banking auth complexity (90-day token rotation per Ultraplan §8.1 line 542 gotcha). Tier 1 always-on (cortextOS Primitive 1 dependency) |
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:140:| 6. Tenant-onboarding readiness | **Medium** | Needs Xero/QuickBooks/Sage OAuth (one of, per tenant) + Open Banking auth (TrueLayer/Plaid UK per Ultraplan §8.1 line 539). Chase-cadence config per tenant. FD's mobile for Telegram approval per Ultraplan §8.1 line 540 |
docs/decisions/sequencing-target.md:142:**Hire-#1 anchor (per Ultraplan §9 line 766 verbatim):** "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)." Cash Conductor's three-accounting-API + Open-Banking integration is the right scope for Hire #1's first sprint per Ultraplan §9 — this places Cash Conductor at W7-8 in the canonical sequence.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:163:| 1. Implementation simplicity | **High complexity (Low simplicity)** | Ultraplan §8.1 line 568 estimate **XL (4 weeks)** — biggest v1.0 agent. Lifecycle state machine across 24+ months of candidate post-placement (week-1 / month-1 / month-3 / month-6 / month-12 / month-24 nurture per Product Spec §2.2 R7). Six-plus comms types (acknowledgement, prep, debrief, rejection, placement, multi-stage check-ins) |
docs/decisions/sequencing-target.md:164:| 2. Substrate exercise | **Maximum** | **All** of cortextOS Primitives 1+2+4+5 exercised. **First exercise of Primitive 2** (71-hour context rotation per Day 1 cortextos-primitive-status.md) — Concierge holds long-running state across 24+ months of candidate lifecycle. First Bullhorn webhook exercise per Day 2 §4.2 (with 5-minute polling fallback). Per `bullhorn-integration-path.md` §4.1 row 4: reads Candidate, ClientCorporation, JobOrder, Placement, Note + writes Note, Candidate state-fields, Placement state-fields |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:183:W6:   Scribe (A3)
docs/decisions/sequencing-target.md:184:W7-8: Cash Conductor (A4) — Hire-#1-anchored per Ultraplan §9 line 766
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:193:- W5: Risk #2 (Bullhorn auth) — Janitor first writes. Reduction trigger 2 fires (Medium → Low per `bullhorn-integration-path.md` §6.7).
docs/decisions/sequencing-target.md:194:- W7-8: Risk #1 (cortextOS Primitives 1+4+5) — Cash Conductor first Tier-1. Reduction trigger fires.
docs/decisions/sequencing-target.md:198:- Bullhorn webhook coverage gaps surface only at Concierge W10-13 (Ultraplan §8.1 line 569 caveat).
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:210:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:212:W12-13: Cash Conductor (A4)
docs/decisions/sequencing-target.md:215:**Why this ordering:** Get the flagship demoable agent (Concierge) live earliest to accelerate first-pilot conversion per Ultraplan §9 line 725 target Week 12.
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:223:**Hire-#1-onboarding fit:** **Bad.** Structural conflict with Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:231:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:232:W11:  Cash Conductor (A4)
docs/decisions/sequencing-target.md:236:**Why this ordering:** Front-load risk-de-risking by building Concierge (the most Primitive-heavy agent) early. Cash Conductor's Risk #1 exercise becomes redundant if Concierge already exercises Primitives 1+2+4+5.
docs/decisions/sequencing-target.md:240:1. **Concierge depends on Scribe** for Notes-for-context (per `bullhorn-integration-path.md` §4.1 row 4 — Concierge reads Notes Scribe wrote). Building Concierge at W6-9 before Scribe (W10) means Concierge's first-month operation has empty Note context. Materially degrades the Tier-1 always-on demo.
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:242:3. **Hire-#1 anchor broken.** Cash Conductor at W11 is 4 weeks after Hire #1's assumed W7 start. Hire #1 again has no first-sprint scope.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:255:| 4. Commercial value | Tied (Diagnostic substrate, then flagship Concierge last; closing demo at W12-13 per Ultraplan §9 line 781) | Wins on raw timing (Concierge W5-8 demoable earlier) — but loses on substrate quality (Concierge ships with degraded Notes-for-context) | Tied — Concierge W6-9 marginally earlier than Alpha but with same substrate gaps as Beta |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:294:The Hire-#1 anchor at W7-8 per Ultraplan §9 line 766 is load-bearing — Cash Conductor's three-accounting-API + Open-Banking work is well-scoped for Hire #1's first sprint. Beta and Gamma both displace Cash Conductor past W7-8 (W12-13 and W11 respectively), leaving Hire #1 with no first-sprint scope per §3.2 and §3.3 structural defects.
docs/decisions/sequencing-target.md:300:**Trigger 1 — Risk #2 materialises in Week 4-5.** If Bullhorn auth path breaks (Day 2 Sub-decisions A or B don't flip to Accepted, marketplace required but unobtainable, OAuth flow blocks deployment, or per-tenant client_id ticket cycle slows past 5 business days per `bullhorn-integration-path.md` §1.3 row 5):
docs/decisions/sequencing-target.md:302:- **Decider:** founder, on Week 4 weekly review (per Ultraplan §9 line 787 "Weekly review: Friday afternoon").
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:325:- The 6-agent sequence per §4.1, including Cash Conductor's W7-8 Hire-#1 anchor.
docs/decisions/sequencing-target.md:334:- Whether Cash Conductor's 2-week build can compress if Hire #1 onboarding is fast — deferred to Week 7 Cash-Conductor-kickoff check-in.
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:376:**New `decision_log` `phase` values introduced by this document:** `gating_failed`, `agent_handoff`. The Postgres decision_log table column `phase` (per `second-brain-design.md` §2.4.2 schema) currently lists only `trigger | output | action` per ADR-002 Decision 3. **Spec gap §5-A** flagged for Day 4 Postgres provisioning: extend the `phase` column's accepted values to include the two new ones. Schema migration is a one-line `CHECK` constraint update.
docs/decisions/sequencing-target.md:389:- `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` per master brief §8.1 Changes 1+2.
docs/decisions/sequencing-target.md:401:- Output: 12-page audit per Ultraplan §8.1 line 489-496 against a real prospect's public footprint.
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:408:First exercise is Janitor at W5 per §4.1 row 2. **If Day 2 Sub-decisions A and B haven't flipped from Proposed to Accepted by start of W4** (per `bullhorn-integration-path.md` §1.3 commercial-blocker table), this is the natural blocker. Founder Sunday/Monday commercial conversations must land before W4 start to keep the Janitor W5 slot intact. Sub-decision C is already Accepted so the endpoint surface is buildable; the gate is auth path (A) and client_credentials foreclosure (B).
docs/decisions/sequencing-target.md:432:Lands at Day 4 alongside the `entity_graph` → `entities` + `entity_links` split (ADR-002 Edit 3) and the `_secrets.env` skeleton addition (ADR-003 design §3.3 Spec gap §2.1-C). Three Day-4-tightenings consolidate into one provisioning task.
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:455:Per §1.5 Spec gap §1-A finding: master brief §6 Day 3 line 471 names the path `.agents/decisions/sequencing-target.md` but the convention established by Days 1-2 is `docs/decisions/`. Same path-convention drift applies to line 472 (Brain UI scope decision; will be flagged in `brain-ui-scope.md` separately if needed).
docs/decisions/sequencing-target.md:459:> "- [ ] Confirm or revise Ultraplan §9's "close first 3 pilots fastest" → `.agents/decisions/sequencing-target.md`"
docs/decisions/sequencing-target.md:463:> "- [ ] Confirm or revise Ultraplan §9's "close first 3 pilots fastest" → `docs/decisions/sequencing-target.md`"
docs/decisions/sequencing-target.md:465:Joins the atomic correction commit as the **7th edit**, alongside the 6 edits already queued (5 from ADR-001/ADR-002/ADR-003 + 1 from `bullhorn-integration-path.md` §6.6). Updated 7-edit manifest:
docs/decisions/sequencing-target.md:468:2. ADR-001 Ultraplan §3.2: latency reframe
docs/decisions/sequencing-target.md:469:3. ADR-002 Edit 1 §3.4: shadow → parallel
docs/decisions/sequencing-target.md:470:4. ADR-002 Edit 2 §5.5: v1.0 brain build wording
docs/decisions/sequencing-target.md:472:6. `bullhorn-integration-path.md` §6.6: §6 Day 2 line 466 OAuth wording
docs/decisions/sequencing-target.md:473:7. **`sequencing-target.md` §6.8: §6 Day 3 line 471 path convention** (NEW)
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:500:| 7th edit | Master brief §6 Day 3 line 471 | `.agents/decisions/` → `docs/decisions/` (per §6.8) | Joins atomic correction commit at end of Week 0 / early Week 1, alongside ADR-001 + ADR-002 + ADR-003 Edit C + `bullhorn-integration-path.md` §6.6 |
docs/decisions/sequencing-target.md:507:| Substrate readiness for W3 Diagnostic build (renderer + `_shared/` + `decision_log`) | Claude Code | End of W2 | Already tracked from ADR-002 + ADR-003 |
docs/decisions/sequencing-target.md:508:| Day 2 commercial conversations land by start of W4 (Risk #2 reduction triggers) | Founder | Sunday-Monday outreach; resolved by end of W3 | Already tracked from `bullhorn-integration-path.md` §1.3 |
docs/decisions/sequencing-target.md:510:| Hire #1 onboarded and productive by W7 per Ultraplan §9 line 766 | Founder | End of W6 | Already tracked from RISK-REGISTER #4 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/decisions/sequencing-target.md:522:End of sequencing-target decision document.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:1:# Codex disagreement — bullhorn-integration-path Week-1 implementation gate
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:4:**Artefact disagreed on:** `docs/decisions/bullhorn-integration-path.md`
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:48:The bullhorn-integration-path.md line 95 wording is arguably ambiguous — "Week-1 implementation can proceed" without qualifying "Week-1 prereq code only, not agent-build slices" is loose. The fix is wording sharpening, not gate-tightening.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:54:- [ ] Incorporated (Codex correct; rewrite bullhorn-integration-path §95 to make all Week-1 implementation conditional on A+B Accepted)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:72:**Round-2 remediation update (2026-05-22):** this source-document sharpening landed in this commit alongside the new `bullhorn-integration-path.md` Gate hierarchy subsection.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:82:- **Split the difference** — line 95 wording sharpens AND a new explicit "Week-1 prereq vs W5 agent-build gate hierarchy" subsection is added to bullhorn-integration-path.md §1.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:13:ULTRAPLAN.md §8.1 specifies the v1.0 build sequence:
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:22:| 7-8 | Cash Conductor |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:47:1. **Diagnostic is the named first agent.** `sequencing-target.md` §3.1 ratified Build Wave 1 = Diagnostic. Doing it earlier doesn't violate the sequence — it accelerates it.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:69:| Bullhorn unresponsive past 2026-06-10 | Force Direct-API fallback per `bullhorn-integration-path.md` §1.4; Janitor scaffold begins; Bullhorn auth gated on first pilot raising support ticket |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:106:- ULTRAPLAN §8.1 line 753-755 (Week-4 milestone definition)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:108:- `sequencing-target.md` §3.1 (Build Wave 1 = Diagnostic)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:110:- `bullhorn-integration-path.md` §1.4 (Direct-API fallback architecture for slow Bullhorn response)
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:95:| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
docs/decisions/autosend-safety-policy.md:102:| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
docs/decisions/autosend-safety-policy.md:107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:136:The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:223:  - bullhorn_note_customer_visible   # orange (CANONICAL — bullhorn-integration-path §4.1)
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/2026-05-18-codex-ratification-manifest.md:18:| 3 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | Accepted | Verify Option α reasoning + Edits 1+2+3 all applied (3, 4, 12 in atomic-correction manifest) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:19:| 4 | `docs/architecture/second-brain-design.md` | Reference (ADR-002 binding) | Cross-check against ADR-002 ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:22:| 7 | `docs/decisions/bullhorn-integration-path.md` | Sub-decision C Accepted; A+B Proposed | Verify Sub-decision C technical analysis; flag A+B as awaiting commercial gates (Q3 unblocker) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:51:**Cross-cutting reference:** these 4 artefacts ratify the layered defence model documented across Day-4 §7 (RLS isolation gate) + ADR-002 (parallel brain) + ADR-003 (renderer) + ADR-004 (deviations). They are downstream of, not redundant with, the existing 21+ queue items.
docs/decisions/2026-05-18-codex-ratification-manifest.md:62:| 2 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | RATIFIED | Incorporated remediation verified clean. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:64:| 4 | `docs/decisions/bullhorn-integration-path.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:65:| 5 | `docs/decisions/sequencing-target.md` | RATIFIED | Incorporated remediation verified clean. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:94:| 1 | `docs/decisions/bullhorn-integration-path.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:172:| 3 | ADR-002 | REJECTED (2 issues) | Issue 1 (status drift) + Issue 2 (master-brief-edit disposition) both **incorporated** at `2b287d3` — disposition now cites commit `0e5b2b4`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:176:| 7 | bullhorn-integration-path.md | REJECTED (3 issues) | Issue 1 (status enum) + Issue 3 (rate-limit speculation note) **incorporated** at `2b287d3`. Issue 2 (Week-1 gate) **counter-argued** in `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`; line 95 wording sharpened. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:177:| 8 | sequencing-target.md | REJECTED (2 issues) | Issue 1 (status drift) **incorporated** at `2b287d3`. Issue 2 (phase enum cite) implicitly addressed via ADR-004 Decision 7 cross-reference. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:265:| 2 | Ultraplan §3.2 watcher → FastChecker + 3-5s reframe | ADR-001 §Consequences line 59 | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:266:| 3 | §3.4 shadow → parallel (full rewrite) | ADR-002 Edit 1 line 81 | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:267:| 4 | §5.5 v1.0 minimum row + v1.0+/v1.1 row merge | ADR-002 Edit 2 line 91 | ✓ verbatim (with side effect documented) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:268:| 5 | §8 renderer footnote (before §8.1) | ADR-003 Edit C | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:275:| 12 | §6 Day 4 line 478 table list (entity_graph split) | ADR-002 Edit 3 | ✓ verbatim |
docs/decisions/2026-05-18-codex-ratification-manifest.md:287:| 7 | `bullhorn-integration-path.md` Sub-decisions A+B | Proposed pending commercial conversations | Either (a) run the Bullhorn outreach + design-partner #1 conversation during extension and flip to Accepted, OR (b) accept ratification of Sub-decision C only, with A+B explicitly marked "deferred to first pilot's actual ATS confirmation" |
docs/decisions/autosend-approval-bridge-spec.md:241:| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql | sed -n '45,70p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '220,520p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    57	  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validate_voice_scores') THEN
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

 succeeded in 0ms:
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
   246	# and all v0.1 + v0.2 entities. v0.3 changes:
   247	#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
   248	#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
   249	#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
   250	#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
   251	#     R-only for Scribe)
   252	#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
   253	#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only)
   254	#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only)
   255	# All other access levels carry forward from v0.1 + v0.2.
   256	
   257	agent_access_matrix:
   258	
   259	  # Disposition tokens: R | W | R+W | none
   260	
   261	  diagnostic:
   262	    candidate: R           # reads for outreach context (§11 decision-maker map)
   263	    contractor: none       # not in scope at v1.0
   264	    client: R              # reads via Companies House lookup (entity-shape if cached)
   265	    contact: R             # reads for §11 decision-maker map
   266	    brief: none            # diagnostic is sales-tool not brief-driven
   267	    opportunity: R         # may read prospect-firm opportunity if exists
   268	    placement: none
   269	    timesheet: none
   270	    voice_corpus: R
   271	    voice_corpus_chunks: R
   272	    tone_rule: R
   273	    recent_edit: none
   274	
   275	  janitor:
   276	    candidate: R+W         # dedup + field-backfill writes
   277	    contractor: R+W        # dedup + field-backfill writes
   278	    client: R+W            # Companies House enrichment writes
   279	    contact: R+W           # dedup + field-backfill writes
   280	    brief: R               # context for related candidate cleanup
   281	    opportunity: R
   282	    placement: R+W         # lifecycle-state cleanup
   283	    timesheet: R           # reads for placement-state inference
   284	    voice_corpus: R        # tacit-note narrative voice grounding
   285	    voice_corpus_chunks: R
   286	    tone_rule: R           # v0.3 NEW (was no access)
   287	    recent_edit: R         # v0.3 NEW (was Concierge/canary/LoRA only); for tacit-note harvest
   288	
   289	  scribe:
   290	    candidate: R+W         # call-summary field extraction
   291	    contractor: R+W        # call-summary field extraction
   292	    client: R
   293	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
   294	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
   295	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
   296	    placement: R+W         # check-in field extraction
   297	    timesheet: R           # reads for placement-context resolution on check-in calls
   298	    voice_corpus: R        # tacit-note voice grounding
   299	    voice_corpus_chunks: R
   300	    tone_rule: R           # v0.2
   301	    recent_edit: W         # writes its own edits for retraining
   302	
   303	  cash_conductor:
   304	    candidate: none        # no Bullhorn dependency
   305	    contractor: none
   306	    client: R              # reads client billing details
   307	    contact: R             # reads for invoice addressee resolution
   308	    brief: none
   309	    opportunity: none
   310	    placement: R           # reads for client linkage on invoice
   311	    timesheet: R           # reads to verify billable hours match invoiced amounts
   312	    voice_corpus: R        # chase-email voice grounding
   313	    voice_corpus_chunks: R
   314	    tone_rule: R           # v0.2
   315	    recent_edit: W         # writes its own chase-draft edits for retraining
   316	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   317	
   318	  sourcing_scout:
   319	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   320	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   321	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   322	    # writes its proposed-candidate rows + reads opportunity context. These
   323	    # are entity-level access overrides codified here.
   324	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   325	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   326	    client: R
   327	    contact: R
   328	    brief: R               # reads to filter candidates
   329	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   330	    placement: none
   331	    timesheet: none
   332	    voice_corpus: R        # rationale-narrative voice grounding
   333	    voice_corpus_chunks: R
   334	    tone_rule: R
   335	    recent_edit: W         # writes rationale-narrative edits for retraining
   336	
   337	  concierge:
   338	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   339	    contractor: R+W        # writes lifecycle states for contractor placements too
   340	    client: R
   341	    contact: R             # reads for outbound recipient resolution
   342	    brief: R
   343	    opportunity: R
   344	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   345	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   346	    voice_corpus: R        # lifecycle-comms voice grounding
   347	    voice_corpus_chunks: R
   348	    tone_rule: R           # v0.2
   349	    recent_edit: R         # v0.2
   350	
   351	# ============================================================================
   352	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   353	# ============================================================================
   354	
   355	auxiliary_tables:
   356	
   357	  cash_conductor_transactions:
   358	    rationale: |
   359	      Open Banking transactions are high-volume + time-series + don't model
   360	      as entity.data JSONB. v0.3 introduces a first-class table with
   361	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   362	      §4 Step 3 + ADR-002 vault/Postgres split.
   363	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   364	    columns:
   365	      id: {type: integer, required: true, notes: BIGSERIAL primary key in SQL}
   366	      tenant_slug: {type: string, required: true, notes: RLS isolation key per Day-4 §6.3}
   367	      transaction_id: {type: string, required: true, notes: Provider-supplied (TrueLayer / Plaid)}
   368	      posted_at: {type: timestamp, required: true}
   369	      amount: {type: number, required: true, notes: NUMERIC(15,2) GBP; negative for outgoing}
   370	      currency: {type: string, required: true, default: GBP}
   371	      payee_name_raw: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   372	      description: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   373	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct]}
   374	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched}
   375	      matched_invoice_id: {type: string, required: false, notes: FK to cash_conductor_invoices.invoice_id when match_status='matched'}
   376	      match_confidence: {type: number, required: false, notes: "range [0.00, 1.00]"}
   377	      match_dimensions: {type: array, items: {type: string}, required: false}
   378	      ingested_at: {type: timestamp, required: true, default: now()}
   379	      raw_payload: {type: object, required: false, pii: true, notes: Full Open Banking response; pseudonymized at year 7}
   380	    indexes:
   381	      - "(tenant_slug, posted_at DESC)"
   382	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   383	    retention: |
   384	      INTENT (W4-polish enforcement required): 7-year retention with
   385	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   386	      description, raw_payload). Aligned with Q4 v0_3_default. The
   387	      v0.2-to-v0.3 migration creates the table + indexes only; the
   388	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   389	      job or external scheduled job; not yet authored).
   390	    enforcement_gate: |
   391	      Production use of this table GATED until pseudonymization + purge
   392	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   393	      by founder + tenant before go-live; migration-test tenant exempt.
   394	
   395	  cash_conductor_invoices:
   396	    rationale: |
   397	      Open invoice register cached from accounting provider. Same auxiliary-
   398	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   399	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   400	    columns:
   401	      id: {type: integer, required: true}
   402	      tenant_slug: {type: string, required: true}
   403	      invoice_id: {type: string, required: true}
   404	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage]}
   405	      invoice_number: {type: string, required: false}
   406	      issued_at: {type: timestamp, required: true}
   407	      due_at: {type: timestamp, required: true}
   408	      amount_total: {type: number, required: true, notes: NUMERIC(15,2) GBP}
   409	      amount_paid: {type: number, required: true, default: 0}
   410	      currency: {type: string, required: true, default: GBP}
   411	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open}
   412	      client_contact_id: {type: string, required: false, notes: Links to Bullhorn placement.client_contact_id}
   413	      client_billing_email: {type: string, required: false, pii: true}
   414	      last_chase_position: {type: integer, required: true, default: 0, notes: 0-4 per Cash Conductor §3.2}
   415	      last_chase_sent_at: {type: timestamp, required: false}
   416	      ingested_at: {type: timestamp, required: true, default: now()}
   417	      raw_payload: {type: object, required: false, pii: true}
   418	    indexes:
   419	      - "(tenant_slug, due_at)"
   420	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   421	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   422	    retention: |
   423	      INTENT (W4-polish enforcement required): 7-year retention with
   424	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   425	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   426	      pseudonymization + purge implementation is a W4-polish slice
   427	      (pg_cron job or external scheduled job; not yet authored).
   428	    enforcement_gate: |
   429	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   430	      W4 polish, production use of cash_conductor_invoices is GATED by
   431	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   432	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   433	      data is exempt; pilot tenants require the DPA addendum signed before
   434	      go-live.
   435	
   436	auxiliary_table_access_matrix:
   437	  cash_conductor_transactions:
   438	    diagnostic: none
   439	    janitor: none
   440	    scribe: none
   441	    cash_conductor: R+W
   442	    sourcing_scout: none
   443	    concierge: none
   444	  cash_conductor_invoices:
   445	    diagnostic: none
   446	    janitor: none
   447	    scribe: none
   448	    cash_conductor: R+W
   449	    sourcing_scout: none
   450	    concierge: none
   451	
   452	# ============================================================================
   453	# §4 — tenant_adapters.config new keys (4 keys)
   454	# ============================================================================
   455	#
   456	# tenant_adapters.config is JSONB; validation via
   457	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   458	# on unknown keys per Rule 2.
   459	
   460	tenant_adapters_config_additions:
   461	
   462	  cash_conductor_last_run:
   463	    type: timestamp
   464	    required: false
   465	    set_by: cash_conductor
   466	    read_by: [cash_conductor]
   467	    notes: |
   468	      Cash Conductor cron sweep updates at session-close. Next run queries
   469	      transactions/invoices since this timestamp.
   470	
   471	  concierge_last_poll:
   472	    type: timestamp
   473	    required: false
   474	    set_by: concierge
   475	    read_by: [concierge]
   476	    notes: |
   477	      Concierge polling cron updates at end of each cycle. Next poll queries
   478	      Bullhorn for state transitions since this timestamp.
   479	
   480	  concierge_send_window:
   481	    type: object
   482	    required: false
   483	    default:
   484	      timezone: Europe/London
   485	      weekday_start: '09:00'
   486	      weekday_end: '17:00'
   487	      weekend_send_enabled: false
   488	    set_by: [tenant-admin]
   489	    read_by: [concierge]
   490	    object_shape:
   491	      timezone:
   492	        type: string
   493	        notes: IANA timezone identifier
   494	      weekday_start:
   495	        type: string
   496	        notes: HH:MM 24-hour format
   497	      weekday_end:
   498	        type: string
   499	        notes: HH:MM 24-hour format
   500	      weekend_send_enabled:
   501	        type: boolean
   502	    notes: |
   503	      Per-tenant outbound sending hours. Concierge respects when scheduling
   504	      orange-tier sends.
   505	
   506	  diagnostic_per_claim_sample_rate:
   507	    type: integer
   508	    range: [1, 100]
   509	    default: 10
   510	    required: false
   511	    set_by: [tenant-admin]
   512	    read_by: [diagnostic]
   513	    notes: |
   514	      Per ADR-006 Tier 2 (post-launch quality metric). Sample 1-in-N
   515	      Diagnostic reports for per-claim citation validation. Activates at
   516	      W4 polish; documented intent only until then.
   517	
   518	# ============================================================================
   519	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   520	# ============================================================================

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql | sed -n '221,252p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   221	CREATE OR REPLACE FUNCTION validate_voice_score_fields()
   222	RETURNS TRIGGER AS $$
   223	DECLARE
   224	  score_keys TEXT[] := ARRAY['voice_classifier_score', 'voice_drift_at_close'];
   225	  k TEXT;
   226	  v JSONB;
   227	BEGIN
   228	  FOREACH k IN ARRAY score_keys LOOP
   229	    v := NEW.data -> k;
   230	    IF v IS NOT NULL AND jsonb_typeof(v) != 'null' THEN
   231	      IF jsonb_typeof(v) != 'number' THEN
   232	        RAISE EXCEPTION 'entities.data.% must be number; got %', k, jsonb_typeof(v);
   233	      END IF;
   234	      IF (v::TEXT)::NUMERIC < 0.0 OR (v::TEXT)::NUMERIC > 1.0 THEN
   235	        RAISE EXCEPTION 'entities.data.% out of range [0.0, 1.0]: %', k, v::TEXT;
   236	      END IF;
   237	    END IF;
   238	  END LOOP;
   239	  RETURN NEW;
   240	END;
   241	$$ LANGUAGE plpgsql;
   242	
   243	-- Postgres 14+ CREATE OR REPLACE TRIGGER is idempotent without requiring
   244	-- table ownership. DROP TRIGGER would require ownership (entities is owned
   245	-- by postgres; ifos_app has only TRIGGER privilege from Day-11 GRANT).
   246	CREATE OR REPLACE TRIGGER validate_voice_scores
   247	  BEFORE INSERT OR UPDATE ON entities
   248	  FOR EACH ROW
   249	  WHEN (NEW.entity_type IN ('candidate', 'contractor', 'contact', 'brief', 'opportunity', 'placement'))
   250	  EXECUTE FUNCTION validate_voice_score_fields();
   251	
   252	-- ----------------------------------------------------------------------------

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '520,760p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '221,360p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

 succeeded in 0ms:
   520	# ============================================================================
   521	
   522	decision_log_payload_extension:
   523	  per_claim_confidence_distribution:
   524	    type: object
   525	    required: false
   526	    written_when: |
   527	      Tier 2 per-claim validation runs (sample-rate-gated by
   528	      tenant_adapters.config.diagnostic_per_claim_sample_rate).
   529	    object_shape:
   530	      total_claims:
   531	        type: integer
   532	      claims_with_confidence_above_0_6:
   533	        type: integer
   534	      claims_with_confidence_below_0_6:
   535	        type: integer
   536	      mean_confidence:
   537	        type: number
   538	      sampled_at:
   539	        type: timestamp
   540	      sample_rate_applied:
   541	        type: integer
   542	    notes: |
   543	      Aggregate metric, not per-claim detail. Per-claim raw data goes to a
   544	      separate v1.1 quality-metrics table if commercial value justifies.
   545	    validation:
   546	      mean_confidence: "[0.0, 1.0] range — enforced at write-time by W4-polish decision_log writer extension (not by Postgres trigger; payload is JSONB)"
   547	      claims_with_confidence_above_0_6: ">= 0 (non-negative integer)"
   548	      claims_with_confidence_below_0_6: ">= 0 (non-negative integer)"
   549	      total_claims: "= above + below (consistency invariant)"
   550	      sample_rate_applied: "[1, 100] (matches tenant_adapters.config.diagnostic_per_claim_sample_rate range)"
   551	    enforcement_gate: |
   552	      v0.3 declares the shape. Range + invariant validation lands in the
   553	      W4-polish decision_log writer extension that ships with Tier 2
   554	      sampling activation. Until then, no Tier 2 writes occur, so the
   555	      validation gap is non-blocking.
   556	
   557	# ============================================================================
   558	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   559	# ============================================================================
   560	
   561	migration_sequence:
   562	  forward: migrations/v0.2-to-v0.3.sql
   563	  rollback: migrations/v0.3-to-v0.2.sql
   564	
   565	  pre_conditions:
   566	    - v0.2 migration applied (voice_corpus + tone_rule + recent_edit tables exist)
   567	    - validate_voice_scores trigger active on entities table
   568	    - RLS + ifos_app grants from Day-4 §6.3 in place
   569	    - migration-test tenant row exists in tenants table
   570	
   571	  steps:
   572	    1: |
   573	      Verify v0.2 prerequisites (DO block in migration §1).
   574	    2: |
   575	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   576	      ifos_app grants + 2 indexes (migration §2).
   577	    3: |
   578	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   579	      (migration §3).
   580	    4: |
   581	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   582	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   583	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   584	      candidate / contact / brief / placement / opportunity entity_types.
   585	      Re-attaches the trigger to entities table (migration §4).
   586	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   587	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   588	    5: |
   589	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   590	      hard-fails on unknown config keys (Rule 2); type-validates the 4 new
   591	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   592	    6: |
   593	      Smoke verification DO block confirms both cash_conductor_*
   594	      tables exist (migration §6).
   595	    7: |
   596	      COMMIT; or ROLLBACK on any error.
   597	
   598	  post_migration_steps:
   599	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   600	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   601	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   602	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   603	       Cat-β findings closed
   604	
   605	# ============================================================================
   606	# §7 — Codex ratification path
   607	# ============================================================================
   608	
   609	codex_ratification:
   610	  skill: review-schema-change
   611	  expected_round_trips: 1-2 (mechanical fixes only)
   612	  manifest_queue_position: 44 (after v0.2 supplement at 29)
   613	
   614	# ============================================================================
   615	# §8 — Open questions (structured per review-schema-change §8)
   616	# ============================================================================
   617	
   618	open_questions:
   619	
   620	  Q1_employment_type_enum_completeness:
   621	    question: Are 6 employment_type enum values sufficient for UK recruitment?
   622	    options:
   623	      A: |
   624	        Keep 6 values as in §1.candidate.employment_type — perm, contract,
   625	        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
   626	      B: |
   627	        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
   628	      C: |
   629	        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
   630	        (array of allowed strings); validate at write time against tenant's list.
   631	    v0_3_default: A
   632	    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
   633	      outside A, escalate to B or C.
   634	
   635	  Q2_key_skills_max_length:
   636	    question: Cap at 20 items per candidate adequate?
   637	    options:
   638	      A: Keep cap at 20 (validator hard-fails over).
   639	      B: Increase to 50 (handles senior technical candidates with deep stacks).
   640	      C: Remove cap entirely (rely on application-layer pruning).
   641	    v0_3_default: A
   642	    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
   643	      of candidates hit the 20-item cap, escalate to B.
   644	
   645	  Q3_placement_status_enum_lifecycle:
   646	    question: 6-state placement_status enum maps to Bullhorn's native state machine?
   647	    options:
   648	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   649	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   650	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   651	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   652	    v0_3_default: A
   653	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   654	      escalate to B or C if 1:1 mapping breaks.
   655	
   656	  Q4_cash_conductor_transactions_retention:
   657	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   658	      What's the production retention policy?
   659	    options:
   660	      A: 7-year retention with automated pseudonymization at year 7 (hash
   661	         payee_name_raw + description; preserve amount + dates for audit).
   662	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   663	         rows retained beyond 7 years for cross-period reconciliation).
   664	      C: Per-tenant retention override in tenant_adapters.config.
   665	    v0_3_default: A
   666	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   667	      tenant requires shorter retention, escalate to C with tenant-specific
   668	      override. Pseudonymization implementation lands in W4-polish slice.
   669	    production_use_gating: |
   670	      Until pseudonymization implementation lands, production use of
   671	      cash_conductor_transactions table is GATED by an explicit per-tenant
   672	      DPA addendum signed by founder + tenant. Migration-test tenant data
   673	      is not subject to this gate.
   674	
   675	  Q5_unknown_config_keys_handling:
   676	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   677	    options:
   678	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   679	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   680	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   681	    v0_3_default: A
   682	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   683	      for forward-compat, escalate to B or C with explicit ADR.
   684	
   685	# ============================================================================
   686	# §9 — Why v0.3 is the right unblock
   687	# ============================================================================
   688	
   689	rationale: |
   690	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   691	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   692	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   693	  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys + 1
   694	  payload extension, closing those findings.
   695	
   696	  After v0.3 ratifies + migration applies:
   697	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   698	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   699	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   700	      placement_status, week_1_status_note, satisfaction_signal,
   701	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   702	      are now schema-backed. The Scribe §3 narrative still references SOME
   703	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   704	      seniority — not yet in schema; brief.start_date should be
   705	      start_date_target; opportunity.sector — not yet in schema). These
   706	      residual gaps are tracked in W4-polish-schema-extension backlog;
   707	      they do not block v0.3 ratification but do require a Scribe agent.md
   708	      consistency-pass before Scribe ratifies.
   709	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   710	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   711	    - Concierge tenant_adapters.config field refs valid
   712	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   713	
   714	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   715	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   716	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   717	  not schema gaps.
   718	
   719	# ============================================================================
   720	
   721	end_of_supplement: true

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '288,338p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   288	  candidate:
   289	    voice_classifier_score:
   290	      type: number
   291	      required: false
   292	      source: IFOS-derived
   293	      notes: |
   294	        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
   295	
   296	  contractor:
   297	    voice_classifier_score:
   298	      type: number
   299	      required: false
   300	      source: IFOS-derived
   301	      notes: Same as candidate.voice_classifier_score, scoped to contractor sub-case.
   302	
   303	  contact:
   304	    voice_classifier_score:
   305	      type: number
   306	      required: false
   307	      source: IFOS-derived
   308	      notes: |
   309	        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).
   310	
   311	  brief:
   312	    voice_classifier_score:
   313	      type: number
   314	      required: false
   315	      source: IFOS-derived
   316	      notes: |
   317	        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.
   318	
   319	  opportunity:
   320	    voice_classifier_score:
   321	      type: number
   322	      required: false
   323	      source: IFOS-derived
   324	      notes: |
   325	        v1.1+ Triage exercises this; v1.0 sets to NULL. Tracks voice score for outbound messages within a specific candidate-brief opportunity pairing.
   326	
   327	  placement:
   328	    voice_drift_at_close:
   329	      type: number
   330	      required: false
   331	      source: IFOS-derived
   332	      notes: |
   333	        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
   334	
   335	# ============================================================================
   336	# §4 — Additional relationships (2)
   337	# ============================================================================
   338	

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '669,724p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   669	agent_access_matrix:
   670	
   671	  Diagnostic:
   672	    candidate: none
   673	    contractor: none
   674	    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
   675	    contact: none
   676	    brief: none
   677	    placement: none
   678	    opportunity: none
   679	    timesheet: none
   680	    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
   681	
   682	  Janitor:
   683	    candidate: R+W   # full sweep + normalisation + dedup proposals
   684	    contractor: R+W  # status normalisation
   685	    client: R+W      # orphan-link sweep + normalisation
   686	    contact: R       # read-only (Concierge owns writes)
   687	    brief: R         # status drift sweep
   688	    placement: R     # orphan / stale-tag sweep
   689	    opportunity: none
   690	    timesheet: none
   691	
   692	  Scribe:
   693	    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
   694	    contractor: R+W  # contractor calls same pattern
   695	    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
   696	    contact: none
   697	    brief: R         # write-context resolution
   698	    placement: R+W   # note links on placed-candidate calls
   699	    opportunity: none
   700	    timesheet: none
   701	
   702	  Cash_Conductor:
   703	    candidate: none  # No Bullhorn touch — Xero + Open Banking only
   704	    contractor: none
   705	    client: none
   706	    contact: none
   707	    brief: none
   708	    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
   709	    opportunity: none
   710	    timesheet: none
   711	
   712	  Sourcing_Scout:
   713	    candidate: R     # passive matching
   714	    contractor: R    # contractor pool
   715	    client: R        # target-firm context
   716	    contact: none    # thin v1.0
   717	    brief: R         # active brief context for matching
   718	    placement: none
   719	    opportunity: none
   720	    timesheet: none
   721	
   722	  Concierge:
   723	    candidate: R+W   # lifecycle state on every event
   724	    contractor: R+W  # lifecycle state, contractor-specific cadence

codex
REJECTED

1. Rollback migration cited by the supplement is internally broken. Lines 12 and 561-563 cite `migrations/v0.3-to-v0.2.sql` as the companion rollback, but that file checks for `pg_proc.proname = 'validate_voice_scores'` while the v0.2 function is actually `validate_voice_score_fields()`; the trigger name is `validate_voice_scores`. This makes the rollback fail before it restores the v0.2 trigger. Fix `v0.3-to-v0.2.sql` to check for `validate_voice_score_fields` and keep the trigger name as `validate_voice_scores`.

2. The agent access matrix changes more access than the supplement admits. Lines 245-255 say the v0.3 matrix changes only Scribe Contact/Brief/Opportunity and Janitor `recent_edit`/`tone_rule`, with all other access carried forward; but lines 261-349 also change Diagnostic from `none` to reads, Cash Conductor from `none` to reads, Sourcing Scout candidate/contractor/opportunity, Concierge opportunity, and Janitor contact/opportunity/placement/timesheet relative to `vertical-schema.yaml` §3. This violates honest-signal discipline because unlisted permission changes are load-bearing schema changes. Either document every changed cell with a rationale and source citation, or revert cells not intentionally changed.

3. The supplement claims complete matrix consistency, but field-level access and entity-level access are not reconciled. Example: `candidate.employment_type` lines 57-59 grants Scribe `W` and Sourcing Scout `R`, while the entity matrix lines 289-290 and 318-324 grants both broader `R+W` on candidate; `linkedin_url` line 88 says Janitor `R` with “W only via dedup-merge action” while line 276 grants Janitor `R+W` on candidate. Add an explicit rule that field-level access narrows entity-level access, or make the field access entries match the matrix.
tokens used
75,918
REJECTED

1. Rollback migration cited by the supplement is internally broken. Lines 12 and 561-563 cite `migrations/v0.3-to-v0.2.sql` as the companion rollback, but that file checks for `pg_proc.proname = 'validate_voice_scores'` while the v0.2 function is actually `validate_voice_score_fields()`; the trigger name is `validate_voice_scores`. This makes the rollback fail before it restores the v0.2 trigger. Fix `v0.3-to-v0.2.sql` to check for `validate_voice_score_fields` and keep the trigger name as `validate_voice_scores`.

2. The agent access matrix changes more access than the supplement admits. Lines 245-255 say the v0.3 matrix changes only Scribe Contact/Brief/Opportunity and Janitor `recent_edit`/`tone_rule`, with all other access carried forward; but lines 261-349 also change Diagnostic from `none` to reads, Cash Conductor from `none` to reads, Sourcing Scout candidate/contractor/opportunity, Concierge opportunity, and Janitor contact/opportunity/placement/timesheet relative to `vertical-schema.yaml` §3. This violates honest-signal discipline because unlisted permission changes are load-bearing schema changes. Either document every changed cell with a rationale and source citation, or revert cells not intentionally changed.

3. The supplement claims complete matrix consistency, but field-level access and entity-level access are not reconciled. Example: `candidate.employment_type` lines 57-59 grants Scribe `W` and Sourcing Scout `R`, while the entity matrix lines 289-290 and 318-324 grants both broader `R+W` on candidate; `linkedin_url` line 88 says Janitor `R` with “W only via dedup-merge action” while line 276 grants Janitor `R+W` on candidate. Add an explicit rule that field-level access narrows entity-level access, or make the field access entries match the matrix.
