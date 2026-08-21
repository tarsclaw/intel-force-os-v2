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
session id: 019e5a31-690d-7b12-b0fe-5e50b72ef5b9
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
#   - Scribe Contact: none → RW (writes preferred_channel + next_action +
#     decision_authority)
#   - Scribe Brief: R → RW (writes must_haves + nice_to_haves + deal_breakers
#     + salary_min/max + start_date)
#   - Scribe Opportunity: none → RW (writes 3 new fields)
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
    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date + decision_authority writes
    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers + salary + start_date writes
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
    candidate: R+W         # writes candidate proposals from multi-source aggregation
    contractor: R+W        # same
    client: R
    contact: R
    brief: R               # reads to filter candidates
    opportunity: R
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
    sql_definition_in: migrations/v0.2-to-v0.3.sql §2
    primary_columns:
      - id           # bigserial
      - tenant_slug  # RLS-isolated
      - transaction_id
      - posted_at
      - amount
      - match_status
      - matched_invoice_id
    indexes:
      - "(tenant_slug, posted_at DESC)"
      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
    retention: |
      90-day rolling for unmatched + ambiguous rows; matched rows retained
      indefinitely (audit). Cold archive at v1.1+.
    v1_0_agent_access:
      - Cash Conductor: RW

  cash_conductor_invoices:
    rationale: |
      Open invoice register cached from accounting provider. Same auxiliary-
      table pattern as transactions. Per Cash Conductor §4 Step 4.
    sql_definition_in: migrations/v0.2-to-v0.3.sql §3
    primary_columns:
      - id
      - tenant_slug
      - invoice_id
      - accounting_provider
      - due_at
      - amount_total
      - amount_paid
      - status
      - last_chase_position
    indexes:
      - "(tenant_slug, due_at)"
      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
    retention: |
      Paid retained 7 years (UK statutory accounting). Cancelled/voided 90d.
    v1_0_agent_access:
      - Cash Conductor: RW

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
    - Scribe agent.md §3 entity-field table becomes schema-verifiable
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
I’ll verify the supplement against the existing schema/migration context and cited IFOS docs, then return only the ratification verdict in the required format.
exec
/bin/zsh -lc "sed -n '261,620p' docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date + decision_authority writes
    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers + salary + start_date writes
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
    candidate: R+W         # writes candidate proposals from multi-source aggregation
    contractor: R+W        # same
    client: R
    contact: R
    brief: R               # reads to filter candidates
    opportunity: R
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
    sql_definition_in: migrations/v0.2-to-v0.3.sql §2
    primary_columns:
      - id           # bigserial
      - tenant_slug  # RLS-isolated
      - transaction_id
      - posted_at
      - amount
      - match_status
      - matched_invoice_id
    indexes:
      - "(tenant_slug, posted_at DESC)"
      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
    retention: |
      90-day rolling for unmatched + ambiguous rows; matched rows retained
      indefinitely (audit). Cold archive at v1.1+.
    v1_0_agent_access:
      - Cash Conductor: RW

  cash_conductor_invoices:
    rationale: |
      Open invoice register cached from accounting provider. Same auxiliary-
      table pattern as transactions. Per Cash Conductor §4 Step 4.
    sql_definition_in: migrations/v0.2-to-v0.3.sql §3
    primary_columns:
      - id
      - tenant_slug
      - invoice_id
      - accounting_provider
      - due_at
      - amount_total
      - amount_paid
      - status
      - last_chase_position
    indexes:
      - "(tenant_slug, due_at)"
      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
    retention: |
      Paid retained 7 years (UK statutory accounting). Cancelled/voided 90d.
    v1_0_agent_access:
      - Cash Conductor: RW

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
#   - Scribe Contact: none → RW (writes preferred_channel + next_action +
#     decision_authority)
#   - Scribe Brief: R → RW (writes must_haves + nice_to_haves + deal_breakers
#     + salary_min/max + start_date)
#   - Scribe Opportunity: none → RW (writes 3 new fields)
#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only)
#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only)
# All other access levels carry forward from v0.1 + v0.2.

agent_access_matrix:

  # Disposition tokens: R | W | R+W | none

  diagnostic:

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
/bin/zsh -lc "sed -n '621,760p' docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    - Scribe agent.md §3 entity-field table becomes schema-verifiable
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

exec
/bin/zsh -lc "sed -n '1,220p' docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql" in /Users/madsadmin/code/CortexOS
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
  EXECUTE FUNCTION validate_voice_scores();

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

codex
I found the migration files are present, so I’m checking whether their concrete SQL matches the supplement’s claims and whether the referenced entity access shape is internally consistent.
exec
/bin/zsh -lc "sed -n '261,620p' docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
/bin/zsh -lc 'rg -n "''^(entities:|relationships:|agent_access_matrix:|bullhorn_mapping:|  candidate:|  contractor:|  client:|  contact:|  brief:|  opportunity:|  placement:|  timesheet:|  voice_corpus:|  recent_edit:|  tone_rule:)" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "voice_corpus|tone_rule|recent_edit|v1_0_agent_access|agent_access_matrix|Diagnostic|Janitor|Scribe|Cash Conductor|Sourcing Scout|Concierge" docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
56:  voice_corpus:
58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
60:    v1_0_agent_access:
61:      - Scribe (R — voice samples for note-summary tone matching)
62:      - Concierge (R — voice samples for outbound message generation)
120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
123:  tone_rule:
125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
127:    v1_0_agent_access:
128:      - Scribe (R — note format constraints)
129:      - Cash Conductor (R — payment reminder tone)
130:      - Concierge (R — every outbound message)
140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
189:  recent_edit:
193:    v1_0_agent_access:
195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
252:      tone_rules_triggered:
257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
270:    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
309:        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).
317:        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.
333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
341:  voice_corpus_governs_tone_rules:
342:    source: voice_corpus
343:    target: tone_rule
346:      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
350:  recent_edit_drives_retraining:
351:    source: recent_edit
352:    target: voice_corpus
355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
384:  Q11_voice_corpus_chunk_storage:
386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
393:  Q12_tone_rule_severity_block_path:
395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
401:    trigger_for_revisit: first Concierge build (W10) — measure real retry success rate
403:  Q13_recent_edit_retention_under_GDPR:
405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
435:      the Diagnostic + Janitor agent builds verify the schema against real
441:    expected_date: post-Concierge build (W10-13) — first agent to heavily exercise voice corpus
443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.

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
/bin/zsh -lc "ruby -e 'require \"yaml\"; YAML.load_file(\"docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml\"); puts \"ok\"'" in /Users/madsadmin/code/CortexOS
 succeeded in 487ms:
ok

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '521,700p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '221,520p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   521	      Re-attaches the trigger to entities table (migration §4).
   522	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   523	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   524	    5: |
   525	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   526	      hard-fails on unknown config keys (Rule 2); type-validates the 4 new
   527	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   528	    6: |
   529	      Smoke verification DO block confirms both cash_conductor_*
   530	      tables exist (migration §6).
   531	    7: |
   532	      COMMIT; or ROLLBACK on any error.
   533	
   534	  post_migration_steps:
   535	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   536	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   537	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   538	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   539	       Cat-β findings closed
   540	
   541	# ============================================================================
   542	# §7 — Codex ratification path
   543	# ============================================================================
   544	
   545	codex_ratification:
   546	  skill: review-schema-change
   547	  expected_round_trips: 1-2 (mechanical fixes only)
   548	  manifest_queue_position: 44 (after v0.2 supplement at 29)
   549	
   550	# ============================================================================
   551	# §8 — Open questions (structured per review-schema-change §8)
   552	# ============================================================================
   553	
   554	open_questions:
   555	
   556	  Q1_employment_type_enum_completeness:
   557	    question: Are 6 employment_type enum values sufficient for UK recruitment?
   558	    options:
   559	      A: |
   560	        Keep 6 values as in §1.candidate.employment_type — perm, contract,
   561	        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
   562	      B: |
   563	        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
   564	      C: |
   565	        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
   566	        (array of allowed strings); validate at write time against tenant's list.
   567	    v0_3_default: A
   568	    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
   569	      outside A, escalate to B or C.
   570	
   571	  Q2_key_skills_max_length:
   572	    question: Cap at 20 items per candidate adequate?
   573	    options:
   574	      A: Keep cap at 20 (validator hard-fails over).
   575	      B: Increase to 50 (handles senior technical candidates with deep stacks).
   576	      C: Remove cap entirely (rely on application-layer pruning).
   577	    v0_3_default: A
   578	    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
   579	      of candidates hit the 20-item cap, escalate to B.
   580	
   581	  Q3_placement_status_enum_lifecycle:
   582	    question: 6-state placement_status enum maps to Bullhorn's native state machine?
   583	    options:
   584	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   585	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   586	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   587	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   588	    v0_3_default: A
   589	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   590	      escalate to B or C if 1:1 mapping breaks.
   591	
   592	  Q4_cash_conductor_transactions_retention:
   593	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   594	      What's the production retention policy?
   595	    options:
   596	      A: 7-year retention with automated pseudonymization at year 7 (hash
   597	         payee_name_raw + description; preserve amount + dates for audit).
   598	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   599	         rows retained beyond 7 years for cross-period reconciliation).
   600	      C: Per-tenant retention override in tenant_adapters.config.
   601	    v0_3_default: A
   602	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   603	      tenant requires shorter retention, escalate to C with tenant-specific
   604	      override. Pseudonymization implementation lands in W4-polish slice.
   605	    production_use_gating: |
   606	      Until pseudonymization implementation lands, production use of
   607	      cash_conductor_transactions table is GATED by an explicit per-tenant
   608	      DPA addendum signed by founder + tenant. Migration-test tenant data
   609	      is not subject to this gate.
   610	
   611	  Q5_unknown_config_keys_handling:
   612	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   613	    options:
   614	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   615	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   616	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   617	    v0_3_default: A
   618	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   619	      for forward-compat, escalate to B or C with explicit ADR.
   620	
   621	# ============================================================================
   622	# §9 — Why v0.3 is the right unblock
   623	# ============================================================================
   624	
   625	rationale: |
   626	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   627	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   628	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   629	  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys + 1
   630	  payload extension, closing those findings.
   631	
   632	  After v0.3 ratifies + migration applies:
   633	    - Scribe agent.md §3 entity-field table becomes schema-verifiable
   634	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   635	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   636	    - Concierge tenant_adapters.config field refs valid
   637	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   638	
   639	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   640	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   641	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   642	  not schema gaps.
   643	
   644	# ============================================================================
   645	
   646	end_of_supplement: true

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
   247	#   - Scribe Contact: none → RW (writes preferred_channel + next_action +
   248	#     decision_authority)
   249	#   - Scribe Brief: R → RW (writes must_haves + nice_to_haves + deal_breakers
   250	#     + salary_min/max + start_date)
   251	#   - Scribe Opportunity: none → RW (writes 3 new fields)
   252	#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only)
   253	#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only)
   254	# All other access levels carry forward from v0.1 + v0.2.
   255	
   256	agent_access_matrix:
   257	
   258	  # Disposition tokens: R | W | R+W | none
   259	
   260	  diagnostic:
   261	    candidate: R           # reads for outreach context (§11 decision-maker map)
   262	    contractor: none       # not in scope at v1.0
   263	    client: R              # reads via Companies House lookup (entity-shape if cached)
   264	    contact: R             # reads for §11 decision-maker map
   265	    brief: none            # diagnostic is sales-tool not brief-driven
   266	    opportunity: R         # may read prospect-firm opportunity if exists
   267	    placement: none
   268	    timesheet: none
   269	    voice_corpus: R
   270	    voice_corpus_chunks: R
   271	    tone_rule: R
   272	    recent_edit: none
   273	
   274	  janitor:
   275	    candidate: R+W         # dedup + field-backfill writes
   276	    contractor: R+W        # dedup + field-backfill writes
   277	    client: R+W            # Companies House enrichment writes
   278	    contact: R+W           # dedup + field-backfill writes
   279	    brief: R               # context for related candidate cleanup
   280	    opportunity: R
   281	    placement: R+W         # lifecycle-state cleanup
   282	    timesheet: R           # reads for placement-state inference
   283	    voice_corpus: R        # tacit-note narrative voice grounding
   284	    voice_corpus_chunks: R
   285	    tone_rule: R           # v0.3 NEW (was no access)
   286	    recent_edit: R         # v0.3 NEW (was Concierge/canary/LoRA only); for tacit-note harvest
   287	
   288	  scribe:
   289	    candidate: R+W         # call-summary field extraction
   290	    contractor: R+W        # call-summary field extraction
   291	    client: R
   292	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date + decision_authority writes
   293	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers + salary + start_date writes
   294	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
   295	    placement: R+W         # check-in field extraction
   296	    timesheet: R           # reads for placement-context resolution on check-in calls
   297	    voice_corpus: R        # tacit-note voice grounding
   298	    voice_corpus_chunks: R
   299	    tone_rule: R           # v0.2
   300	    recent_edit: W         # writes its own edits for retraining
   301	
   302	  cash_conductor:
   303	    candidate: none        # no Bullhorn dependency
   304	    contractor: none
   305	    client: R              # reads client billing details
   306	    contact: R             # reads for invoice addressee resolution
   307	    brief: none
   308	    opportunity: none
   309	    placement: R           # reads for client linkage on invoice
   310	    timesheet: R           # reads to verify billable hours match invoiced amounts
   311	    voice_corpus: R        # chase-email voice grounding
   312	    voice_corpus_chunks: R
   313	    tone_rule: R           # v0.2
   314	    recent_edit: W         # writes its own chase-draft edits for retraining
   315	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   316	
   317	  sourcing_scout:
   318	    candidate: R+W         # writes candidate proposals from multi-source aggregation
   319	    contractor: R+W        # same
   320	    client: R
   321	    contact: R
   322	    brief: R               # reads to filter candidates
   323	    opportunity: R
   324	    placement: none
   325	    timesheet: none
   326	    voice_corpus: R        # rationale-narrative voice grounding
   327	    voice_corpus_chunks: R
   328	    tone_rule: R
   329	    recent_edit: W         # writes rationale-narrative edits for retraining
   330	
   331	  concierge:
   332	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   333	    contractor: R+W        # writes lifecycle states for contractor placements too
   334	    client: R
   335	    contact: R             # reads for outbound recipient resolution
   336	    brief: R
   337	    opportunity: R
   338	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   339	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   340	    voice_corpus: R        # lifecycle-comms voice grounding
   341	    voice_corpus_chunks: R
   342	    tone_rule: R           # v0.2
   343	    recent_edit: R         # v0.2
   344	
   345	# ============================================================================
   346	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   347	# ============================================================================
   348	
   349	auxiliary_tables:
   350	
   351	  cash_conductor_transactions:
   352	    rationale: |
   353	      Open Banking transactions are high-volume + time-series + don't model
   354	      as entity.data JSONB. v0.3 introduces a first-class table with
   355	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   356	      §4 Step 3 + ADR-002 vault/Postgres split.
   357	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2
   358	    primary_columns:
   359	      - id           # bigserial
   360	      - tenant_slug  # RLS-isolated
   361	      - transaction_id
   362	      - posted_at
   363	      - amount
   364	      - match_status
   365	      - matched_invoice_id
   366	    indexes:
   367	      - "(tenant_slug, posted_at DESC)"
   368	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   369	    retention: |
   370	      90-day rolling for unmatched + ambiguous rows; matched rows retained
   371	      indefinitely (audit). Cold archive at v1.1+.
   372	    v1_0_agent_access:
   373	      - Cash Conductor: RW
   374	
   375	  cash_conductor_invoices:
   376	    rationale: |
   377	      Open invoice register cached from accounting provider. Same auxiliary-
   378	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   379	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3
   380	    primary_columns:
   381	      - id
   382	      - tenant_slug
   383	      - invoice_id
   384	      - accounting_provider
   385	      - due_at
   386	      - amount_total
   387	      - amount_paid
   388	      - status
   389	      - last_chase_position
   390	    indexes:
   391	      - "(tenant_slug, due_at)"
   392	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   393	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   394	    retention: |
   395	      Paid retained 7 years (UK statutory accounting). Cancelled/voided 90d.
   396	    v1_0_agent_access:
   397	      - Cash Conductor: RW
   398	
   399	# ============================================================================
   400	# §4 — tenant_adapters.config new keys (4 keys)
   401	# ============================================================================
   402	#
   403	# tenant_adapters.config is JSONB; validation via
   404	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   405	# on unknown keys per Rule 2.
   406	
   407	tenant_adapters_config_additions:
   408	
   409	  cash_conductor_last_run:
   410	    type: timestamp
   411	    required: false
   412	    set_by: cash_conductor
   413	    read_by: [cash_conductor]
   414	    notes: |
   415	      Cash Conductor cron sweep updates at session-close. Next run queries
   416	      transactions/invoices since this timestamp.
   417	
   418	  concierge_last_poll:
   419	    type: timestamp
   420	    required: false
   421	    set_by: concierge
   422	    read_by: [concierge]
   423	    notes: |
   424	      Concierge polling cron updates at end of each cycle. Next poll queries
   425	      Bullhorn for state transitions since this timestamp.
   426	
   427	  concierge_send_window:
   428	    type: object
   429	    required: false
   430	    default:
   431	      timezone: Europe/London
   432	      weekday_start: '09:00'
   433	      weekday_end: '17:00'
   434	      weekend_send_enabled: false
   435	    set_by: [tenant-admin]
   436	    read_by: [concierge]
   437	    object_shape:
   438	      timezone:
   439	        type: string
   440	        notes: IANA timezone identifier
   441	      weekday_start:
   442	        type: string
   443	        notes: HH:MM 24-hour format
   444	      weekday_end:
   445	        type: string
   446	        notes: HH:MM 24-hour format
   447	      weekend_send_enabled:
   448	        type: boolean
   449	    notes: |
   450	      Per-tenant outbound sending hours. Concierge respects when scheduling
   451	      orange-tier sends.
   452	
   453	  diagnostic_per_claim_sample_rate:
   454	    type: integer
   455	    range: [1, 100]
   456	    default: 10
   457	    required: false
   458	    set_by: [tenant-admin]
   459	    read_by: [diagnostic]
   460	    notes: |
   461	      Per ADR-006 Tier 2 (post-launch quality metric). Sample 1-in-N
   462	      Diagnostic reports for per-claim citation validation. Activates at
   463	      W4 polish; documented intent only until then.
   464	
   465	# ============================================================================
   466	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   467	# ============================================================================
   468	
   469	decision_log_payload_extension:
   470	  per_claim_confidence_distribution:
   471	    type: object
   472	    required: false
   473	    written_when: |
   474	      Tier 2 per-claim validation runs (sample-rate-gated by
   475	      tenant_adapters.config.diagnostic_per_claim_sample_rate).
   476	    object_shape:
   477	      total_claims:
   478	        type: integer
   479	      claims_with_confidence_above_0_6:
   480	        type: integer
   481	      claims_with_confidence_below_0_6:
   482	        type: integer
   483	      mean_confidence:
   484	        type: number
   485	      sampled_at:
   486	        type: timestamp
   487	      sample_rate_applied:
   488	        type: integer
   489	    notes: |
   490	      Aggregate metric, not per-claim detail. Per-claim raw data goes to a
   491	      separate v1.1 quality-metrics table if commercial value justifies.
   492	
   493	# ============================================================================
   494	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   495	# ============================================================================
   496	
   497	migration_sequence:
   498	  forward: migrations/v0.2-to-v0.3.sql
   499	  rollback: migrations/v0.3-to-v0.2.sql
   500	
   501	  pre_conditions:
   502	    - v0.2 migration applied (voice_corpus + tone_rule + recent_edit tables exist)
   503	    - validate_voice_scores trigger active on entities table
   504	    - RLS + ifos_app grants from Day-4 §6.3 in place
   505	    - migration-test tenant row exists in tenants table
   506	
   507	  steps:
   508	    1: |
   509	      Verify v0.2 prerequisites (DO block in migration §1).
   510	    2: |
   511	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   512	      ifos_app grants + 2 indexes (migration §2).
   513	    3: |
   514	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   515	      (migration §3).
   516	    4: |
   517	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   518	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   519	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   520	      candidate / contact / brief / placement / opportunity entity_types.

exec
/bin/zsh -lc "sed -n '739,790p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
bullhorn_mapping:

  candidate:
    bullhorn_entity: Bullhorn.Candidate
    primary_key: id
    status_filter: status != 'contractor'
    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.

  contractor:
    bullhorn_entity: Bullhorn.Candidate
    primary_key: id
    status_filter: status='contractor'
    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.

  client:
    bullhorn_entity: Bullhorn.ClientCorporation
    primary_key: id
    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.

  contact:
    bullhorn_entity: Bullhorn.ClientContact
    primary_key: id
    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.

  brief:
    bullhorn_entity: Bullhorn.JobOrder
    primary_key: id
    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
    notes: Skills extraction (required_skills, nice_to_have_skills arrays) is IFOS-derived from JD body, not Bullhorn-sourced (Bullhorn does not consistently structure skill fields across tenants).

  placement:
    bullhorn_entity: Bullhorn.Placement
    primary_key: id
    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
    notes: lifecycle_stage is IFOS-derived (Concierge maintains); Bullhorn does not natively store IFOS's nurture-cadence stages.

  opportunity:
    bullhorn_entity: Bullhorn.JobSubmission (or Bullhorn.Opportunity depending on tenant configuration)
    primary_key: id
    field_mapping_density: v0.1 covers 5 fields (placeholder shape); full Bullhorn field-density TBD pending v1.1 Brief Decoder / Inbound Triage build.
    notes: Tenant-config dependent — some Bullhorn tenants use JobSubmission, some use Opportunity, some both. Adapter layer resolves at ingest.

  timesheet:
    bullhorn_entity: Bullhorn.Timesheet
    primary_key: id
    field_mapping_density: v0.1 covers 7 fields (placeholder shape); full Bullhorn field-density TBD pending v2.0 T2 Timesheet + T6 Pay & Bill builds.

# ============================================================================
# §5 — Open questions
# ============================================================================

exec
/bin/zsh -lc "sed -n '45,230p' docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "sed -n '669,738p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
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
# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
# ============================================================================


exec
/bin/zsh -lc "sed -n '283,340p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
  contact:
    description: |
      A person at a client company. Decision-makers, hiring managers, HR, procurement. Bullhorn calls this `ClientContact`. v1.0 representation is thin (10 fields); v1.1 Triage agent expands decision-authority modelling.
    bullhorn_source: Bullhorn.ClientContact
    v1_0_agent_access:
      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
    canonical_fields:
      bullhorn_id:
        type: integer
        required: true
        source: Bullhorn.ClientContact.id
      first_name:
        type: string
        required: true
        source: Bullhorn.ClientContact.firstName
      last_name:
        type: string
        required: true
        source: Bullhorn.ClientContact.lastName
      email:
        type: string
        required: false
        source: Bullhorn.ClientContact.email
      phone:
        type: string
        required: false
        source: Bullhorn.ClientContact.phone
      title:
        type: string
        required: false
        source: Bullhorn.ClientContact.title
        notes: Job title at client.
      decision_authority:
        type: string
        required: false
        enum: [yes, no, influencer, blocker, unknown]
        source: IFOS-derived (founder captures during intake; thin v0.1, expanded v1.1)
        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
      preferred_contact_method:
        type: string
        required: false
        enum: [email, phone, telegram, whatsapp, linkedin]
        source: IFOS-derived
      date_added_at:
        type: timestamp
        required: true
        source: Bullhorn.ClientContact.dateAdded
      do_not_contact:
        type: boolean
        required: true
        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
    notes:
      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
      - v1.1 Triage expands: structured decision-authority (budget tier, decision domain, escalation chain), engagement history aggregate, preferred-channel sentiment.

  # --------------------------------------------------------------------------

exec
/bin/zsh -lc "sed -n '341,428p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
  brief:
    description: |
      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
    bullhorn_source: Bullhorn.JobOrder
    aliases: [role]
    v1_0_agent_access:
      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
    canonical_fields:
      bullhorn_id:
        type: integer
        required: true
        source: Bullhorn.JobOrder.id
      title:
        type: string
        required: true
        source: Bullhorn.JobOrder.title
        notes: Role title as advertised; not internal IFOS-codified.
      description:
        type: string
        required: false
        source: Bullhorn.JobOrder.publicDescription
        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
      role_type:
        type: string
        required: true
        enum: [permanent, contract, temp, retained_search]
        source: Bullhorn.JobOrder.employmentType (with mapping)
      salary_min:
        type: number
        required: false
        source: Bullhorn.JobOrder.salary
        notes: GBP annual for permanent roles.
      salary_max:
        type: number
        required: false
        source: Bullhorn.JobOrder.salaryUnit (range parsing)
      day_rate_min:
        type: number
        required: false
        source: IFOS-derived (extracted from JD; GBP per day for contract roles)
      day_rate_max:
        type: number
        required: false
        source: IFOS-derived
      location:
        type: string
        required: false
        source: Bullhorn.JobOrder.address.city
      remote_policy:
        type: string
        required: false
        enum: [full_remote, hybrid_2_days_office, hybrid_3_days_office, on_site, flexible]
        source: IFOS-derived (extracted from JD)
      required_skills:
        type: array
        items: string
        required: false
        source: IFOS-derived (extracted from JD; v0.1 free strings; v1.1+ canonicalised skill taxonomy)
      start_date_target:
        type: date
        required: false
        source: IFOS-derived
      urgency:
        type: string
        required: false
        enum: [hot, warm, cold]
        source: IFOS-derived (Concierge maintains based on client check-in cadence)
      status:
        type: string
        required: true
        enum: [open, on_hold, filled, closed_lost, closed_won, cancelled]
        source: Bullhorn.JobOrder.status (with mapping)
      date_added_at:
        type: timestamp
        required: true
        source: Bullhorn.JobOrder.dateAdded
      date_last_modified_at:
        type: timestamp
        required: true
        source: Bullhorn.JobOrder.dateLastModified
    notes:
      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).

  # --------------------------------------------------------------------------

exec
/bin/zsh -lc 'rg -n "Phase 4|Cat-β|Cat-|v0.3|schema gaps|Round-8" docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md docs/architecture/bullhorn-integration-path.md docs/architecture/sequencing-target.md 2>/dev/null' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:256:- Cat-1 (Gate A hybrid): Diagnostic §1 verified already correct
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:257:- Cat-2 (decision-log calls): added hh_decision_output / hh_decision_action calls across all §4 sections; pre-registered action_types via Phase 1
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:260:- Cat-5 (§5 honesty): 5 pre-build scaffolds gained explicit "validate.sh does NOT exist yet — W-X build slice delivers this contract" framing; Diagnostic gained warn-only-paths honesty note
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:287:#### Category β — Schema-supplement-needed (v0.3 supplement is a founder-action gate before W4-W13 builds)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:293:- All five are blocked on v0.3 supplement landing (founder review at first-pilot-onboarding) — DOCUMENTED IN W4 BACKLOG
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:324:**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:329:- Diagnostic: pre-build-with-honesty-notes; Round-8-reviewed; ~3 implementation-gap findings (Cat-δ) queued for W3-4 polish slice
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:333:- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:338:2. ESC catalogue v2 amendments (widen 5 codes per Cat-γ list above)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:350:After Round 8 + Cat-α inline fixes, founder authorized continued work via "confirm everything and prepare us for the codex ratify" then "proceed" instructions.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:352:### Cat-γ catalogue widening (commit `5e59f9c`)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:361:### Cat-δ Diagnostic polish (commit `cbef6b5`)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:370:| Diagnostic | 5 | 5 | 0 (different findings; 2 Cat-δ closed, 2 new internal-consistency surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:371:| Janitor | 6 | 6 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:373:| Cash Conductor | 5 | 5 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:374:| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:378:**Cumulative empirical (10 rounds total):** ~75 unique findings catalogued; ~7 closed via Cat-α + Cat-γ + Cat-δ inline this session; convergence rate ~10% per round. The pattern documented in master brief §10.3 step 5 holds.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:383:1. Gate A per-claim vs per-section: STILL flagged despite Cat-1 hybrid disposition; this is a Codex–founder disagreement, not relitigation of Cat-1 (founder's hybrid stance documented but Codex doesn't accept the bilateral-disposition framing as an in-band acceptance of weakening). **Disposition: founder-decision; flagged as Cat-ζ "Cat-1 framing not auto-accepted by Codex".**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:384:2. §1/§3 vs §5 internal inconsistency on Gate A hard-fail vs warn+skip — Cat-α (Diagnostic's hybrid framing introduced §1/§5 contradictions that need explicit reconciliation)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:385:3. §8 build-dependency table says validate.sh "Not built" but file exists — Cat-α; 30s fix
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:386:4. §6 includes ESC_RENDERER_FAILED in "Diagnostic uses" table — Cat-α; remove
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:387:5. §6 says only one action_type but cycle.sh now has operator_notify_telegram (Round-9 introduced by Cat-δ commit) — Cat-α; align §6
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:390:1. Step 9 per-candidate decision_log row missing — Cat-ε
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:392:3. ESC_DNC_FILTER_HIT used for shortlist filtering (pre-outbound), catalogue defines for outbound refusal — Cat-γ widening needed (similar to other 5 widened)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:394:5. Q7 passive-status enum claim (line 333) — Cat-α; my Round-8 fix updated Step 3 prose but missed Q7
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:396:### Cat-ζ — new category surfaced by Round 9
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:398:**Cat-ζ — Codex does not accept bilateral-disposition framings as in-band Gate A acceptances.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:405:- **C) Document as permanent Cat-ζ disagreement** — accept that Codex will continue flagging this; rely on the disagreement doc as the founder-authority record.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:413:**Stopping condition met:** founder's "proceed" → Cat-γ widening + Cat-δ Diagnostic polish + Round 9 + this categorization is the conclusive "RATIFY-or-document-disagreement" outcome per the bilateral disposition. No further autonomous remediation will be attempted.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:418:3. **Per-agent build-slice delivery** (W5-W13) — closes Cat-δ + Cat-ε per agent at its build wave
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:419:4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:422:**Per-agent state at Phase 4 close:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*

codex
REJECTED

1. Agent access matrix changes are not reflected in the entity-level `v1_0_agent_access` definitions. Lines 285-286 add Janitor access to `tone_rule` and `recent_edit`, and lines 300, 314, and 329 add write access to `recent_edit`, but the inherited v0.2 entity definitions do not list those agents. This violates review-schema-change §5, which requires entity-level `v1_0_agent_access` to match the matrix. Add explicit v0.3 access amendments for each affected v0.2 entity or revise the matrix.

2. Auxiliary-table access uses an invalid disposition token. Lines 372-373 and 396-397 use `Cash Conductor: RW`, while line 258 defines valid tokens as `R | W | R+W | none` and the schema-change skill requires `R+W`. Replace `RW` with `R+W`.

3. Scribe write scope is asserted without schema-backed field ownership. Lines 247-250 say Scribe writes `decision_authority`, `salary_min/max`, and `start_date`, but §1 only adds `preferred_channel`, `next_action_target_date`, `must_haves`, `nice_to_haves`, and `deal_breakers`; the inherited fields still have different sources/ownership (`decision_authority` is founder/v1.1 Triage, brief salary fields are Bullhorn-sourced, and the base field is `start_date_target`, not `start_date`). Add explicit v0.3 field-source/access amendments for those existing fields or remove those write claims from the matrix comments and access expansion.
tokens used
61,480
REJECTED

1. Agent access matrix changes are not reflected in the entity-level `v1_0_agent_access` definitions. Lines 285-286 add Janitor access to `tone_rule` and `recent_edit`, and lines 300, 314, and 329 add write access to `recent_edit`, but the inherited v0.2 entity definitions do not list those agents. This violates review-schema-change §5, which requires entity-level `v1_0_agent_access` to match the matrix. Add explicit v0.3 access amendments for each affected v0.2 entity or revise the matrix.

2. Auxiliary-table access uses an invalid disposition token. Lines 372-373 and 396-397 use `Cash Conductor: RW`, while line 258 defines valid tokens as `R | W | R+W | none` and the schema-change skill requires `R+W`. Replace `RW` with `R+W`.

3. Scribe write scope is asserted without schema-backed field ownership. Lines 247-250 say Scribe writes `decision_authority`, `salary_min/max`, and `start_date`, but §1 only adds `preferred_channel`, `next_action_target_date`, `must_haves`, `nice_to_haves`, and `deal_breakers`; the inherited fields still have different sources/ownership (`decision_authority` is founder/v1.1 Triage, brief salary fields are Bullhorn-sourced, and the base field is `start_date_target`, not `start_date`). Add explicit v0.3 field-source/access amendments for those existing fields or remove those write claims from the matrix comments and access expansion.
