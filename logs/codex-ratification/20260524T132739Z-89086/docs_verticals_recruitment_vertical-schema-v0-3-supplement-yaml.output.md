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
session id: 019e5a2b-93bb-7c80-9ae8-7659ae67fa07
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
          - Sourcing Scout: RW

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
          - Sourcing Scout: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
          - Janitor: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
    cash_conductor_transactions: R+W  # v0.3 NEW auxiliary table
    cash_conductor_invoices: R+W      # v0.3 NEW auxiliary table

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
# §8 — Open questions (structured per review-schema-change §6)
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
    question: Indefinite retention for matched transactions UK GDPR-compatible?
    options:
      A: Indefinite as v0.3 default; defer GDPR audit to v1.1.
      B: 7-year retention then automated pseudonymization (replace payee_name_raw
         + description with hashes; preserve amount + dates for audit).
      C: Per-tenant retention override in tenant_adapters.config.
    v0_3_default: A
    trigger_for_revisit: Founder + legal review at first-pilot DPA; if pilot
      tenant requires specific retention policy, escalate to B or C.

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
I’m checking the referenced schema lineage and companion migrations so the verdict is grounded in the repository, not just the pasted YAML.
exec
/bin/zsh -lc "sed -n '1,240p' docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml" in /Users/madsadmin/code/CortexOS
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
          - Sourcing Scout: RW

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
          - Sourcing Scout: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
          - Janitor: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
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
          - Scribe: RW
          - Concierge: R


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

codex
The supplement exists in the tree with forward and rollback migrations. I’m now checking the full v0.3 file against the prior schema and the SQL details where the supplement makes verifiable claims.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '140,420p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,520p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   383	    -- v0.3 additions
   384	    'cash_conductor_last_run',
   385	    'concierge_last_poll',
   386	    'concierge_send_window',
   387	    'diagnostic_per_claim_sample_rate'
   388	  ];
   389	BEGIN
   390	  IF c IS NULL THEN
   391	    RETURN NEW;
   392	  END IF;
   393	
   394	  FOR k IN SELECT jsonb_object_keys(c) LOOP
   395	    IF NOT (k = ANY(allowed_keys)) THEN
   396	      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
   397	    END IF;
   398	  END LOOP;
   399	
   400	  -- v0.3 type validations
   401	  IF c ? 'diagnostic_per_claim_sample_rate' THEN
   402	    IF jsonb_typeof(c->'diagnostic_per_claim_sample_rate') != 'number' THEN
   403	      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be integer';
   404	    END IF;
   405	    IF (c->>'diagnostic_per_claim_sample_rate')::int < 1
   406	       OR (c->>'diagnostic_per_claim_sample_rate')::int > 100 THEN
   407	      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be 1-100';
   408	    END IF;
   409	  END IF;
   410	
   411	  IF c ? 'concierge_send_window' THEN
   412	    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
   413	      RAISE EXCEPTION 'concierge_send_window must be object';
   414	    END IF;
   415	    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
   416	      RAISE EXCEPTION 'concierge_send_window must include timezone';
   417	    END IF;
   418	  END IF;
   419	
   420	  RETURN NEW;

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
    74	          - Sourcing Scout: RW
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
    87	          - Sourcing Scout: RW
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
   103	          - Scribe: RW
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
   115	          - Scribe: RW
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
   131	          - Scribe: RW
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
   143	          - Scribe: RW
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
   156	          - Scribe: RW
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
   172	          - Scribe: RW
   173	          - Janitor: RW
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
   185	          - Scribe: RW
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
   198	          - Scribe: RW
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
   213	          - Scribe: RW
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
   226	          - Scribe: RW
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
   238	          - Scribe: RW
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
   315	    cash_conductor_transactions: R+W  # v0.3 NEW auxiliary table
   316	    cash_conductor_invoices: R+W      # v0.3 NEW auxiliary table
   317	
   318	  sourcing_scout:
   319	    candidate: R+W         # writes candidate proposals from multi-source aggregation
   320	    contractor: R+W        # same
   321	    client: R
   322	    contact: R
   323	    brief: R               # reads to filter candidates
   324	    opportunity: R
   325	    placement: none
   326	    timesheet: none
   327	    voice_corpus: R        # rationale-narrative voice grounding
   328	    voice_corpus_chunks: R
   329	    tone_rule: R
   330	    recent_edit: W         # writes rationale-narrative edits for retraining
   331	
   332	  concierge:
   333	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   334	    contractor: R+W        # writes lifecycle states for contractor placements too
   335	    client: R
   336	    contact: R             # reads for outbound recipient resolution
   337	    brief: R
   338	    opportunity: R
   339	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   340	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   341	    voice_corpus: R        # lifecycle-comms voice grounding
   342	    voice_corpus_chunks: R
   343	    tone_rule: R           # v0.2
   344	    recent_edit: R         # v0.2
   345	
   346	# ============================================================================
   347	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   348	# ============================================================================
   349	
   350	auxiliary_tables:
   351	
   352	  cash_conductor_transactions:
   353	    rationale: |
   354	      Open Banking transactions are high-volume + time-series + don't model
   355	      as entity.data JSONB. v0.3 introduces a first-class table with
   356	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   357	      §4 Step 3 + ADR-002 vault/Postgres split.
   358	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2
   359	    primary_columns:
   360	      - id           # bigserial
   361	      - tenant_slug  # RLS-isolated
   362	      - transaction_id
   363	      - posted_at
   364	      - amount
   365	      - match_status
   366	      - matched_invoice_id
   367	    indexes:
   368	      - "(tenant_slug, posted_at DESC)"
   369	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   370	    retention: |
   371	      90-day rolling for unmatched + ambiguous rows; matched rows retained
   372	      indefinitely (audit). Cold archive at v1.1+.
   373	    v1_0_agent_access:
   374	      - Cash Conductor: RW
   375	
   376	  cash_conductor_invoices:
   377	    rationale: |
   378	      Open invoice register cached from accounting provider. Same auxiliary-
   379	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   380	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3
   381	    primary_columns:
   382	      - id
   383	      - tenant_slug
   384	      - invoice_id
   385	      - accounting_provider
   386	      - due_at
   387	      - amount_total
   388	      - amount_paid
   389	      - status
   390	      - last_chase_position
   391	    indexes:
   392	      - "(tenant_slug, due_at)"
   393	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   394	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   395	    retention: |
   396	      Paid retained 7 years (UK statutory accounting). Cancelled/voided 90d.
   397	    v1_0_agent_access:
   398	      - Cash Conductor: RW
   399	
   400	# ============================================================================
   401	# §4 — tenant_adapters.config new keys (4 keys)
   402	# ============================================================================
   403	#
   404	# tenant_adapters.config is JSONB; validation via
   405	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   406	# on unknown keys per Rule 2.
   407	
   408	tenant_adapters_config_additions:
   409	
   410	  cash_conductor_last_run:
   411	    type: timestamp
   412	    required: false
   413	    set_by: cash_conductor
   414	    read_by: [cash_conductor]
   415	    notes: |
   416	      Cash Conductor cron sweep updates at session-close. Next run queries
   417	      transactions/invoices since this timestamp.
   418	
   419	  concierge_last_poll:
   420	    type: timestamp
   421	    required: false
   422	    set_by: concierge
   423	    read_by: [concierge]
   424	    notes: |
   425	      Concierge polling cron updates at end of each cycle. Next poll queries
   426	      Bullhorn for state transitions since this timestamp.
   427	
   428	  concierge_send_window:
   429	    type: object
   430	    required: false
   431	    default:
   432	      timezone: Europe/London
   433	      weekday_start: '09:00'
   434	      weekday_end: '17:00'
   435	      weekend_send_enabled: false
   436	    set_by: [tenant-admin]
   437	    read_by: [concierge]
   438	    object_shape:
   439	      timezone:
   440	        type: string
   441	        notes: IANA timezone identifier
   442	      weekday_start:
   443	        type: string
   444	        notes: HH:MM 24-hour format
   445	      weekday_end:
   446	        type: string
   447	        notes: HH:MM 24-hour format
   448	      weekend_send_enabled:
   449	        type: boolean
   450	    notes: |
   451	      Per-tenant outbound sending hours. Concierge respects when scheduling
   452	      orange-tier sends.
   453	
   454	  diagnostic_per_claim_sample_rate:
   455	    type: integer
   456	    range: [1, 100]
   457	    default: 10
   458	    required: false
   459	    set_by: [tenant-admin]
   460	    read_by: [diagnostic]
   461	    notes: |
   462	      Per ADR-006 Tier 2 (post-launch quality metric). Sample 1-in-N
   463	      Diagnostic reports for per-claim citation validation. Activates at
   464	      W4 polish; documented intent only until then.
   465	
   466	# ============================================================================
   467	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   468	# ============================================================================
   469	
   470	decision_log_payload_extension:
   471	  per_claim_confidence_distribution:
   472	    type: object
   473	    required: false
   474	    written_when: |
   475	      Tier 2 per-claim validation runs (sample-rate-gated by
   476	      tenant_adapters.config.diagnostic_per_claim_sample_rate).
   477	    object_shape:
   478	      total_claims:
   479	        type: integer
   480	      claims_with_confidence_above_0_6:
   481	        type: integer
   482	      claims_with_confidence_below_0_6:
   483	        type: integer
   484	      mean_confidence:
   485	        type: number
   486	      sampled_at:
   487	        type: timestamp
   488	      sample_rate_applied:
   489	        type: integer
   490	    notes: |
   491	      Aggregate metric, not per-claim detail. Per-claim raw data goes to a
   492	      separate v1.1 quality-metrics table if commercial value justifies.
   493	
   494	# ============================================================================
   495	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   496	# ============================================================================
   497	
   498	migration_sequence:
   499	  forward: migrations/v0.2-to-v0.3.sql
   500	  rollback: migrations/v0.3-to-v0.2.sql
   501	
   502	  pre_conditions:
   503	    - v0.2 migration applied (voice_corpus + tone_rule + recent_edit tables exist)
   504	    - validate_voice_scores trigger active on entities table
   505	    - RLS + ifos_app grants from Day-4 §6.3 in place
   506	    - migration-test tenant row exists in tenants table
   507	
   508	  steps:
   509	    1: |
   510	      Verify v0.2 prerequisites (DO block in migration §1).
   511	    2: |
   512	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   513	      ifos_app grants + 2 indexes (migration §2).
   514	    3: |
   515	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   516	      (migration §3).
   517	    4: |
   518	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   519	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   520	      score checks. Adds JSONB key validations for 14 v0.3 fields across

exec
/bin/zsh -lc 'rg -n "cash_conductor_transactions|cash_conductor_invoices|voice_corpus|tone_rule|recent_edit|GRANT|CREATE TABLE|CREATE POLICY|FOR ALL" docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "''^(entities:|relationships:|agent_access_matrix:|bullhorn_mapping:|  candidate:|  contact:|  brief:|  opportunity:|  placement:|  contractor:|  client:|  timesheet:|  voice_corpus:|  tone_rule:|  recent_edit:)" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:25:--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:26:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:42:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:43:    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:45:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:46:    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:48:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:49:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:58:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:88:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:91:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:95:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:96:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:98:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:99:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:102:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:103:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:109:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:144:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:147:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:151:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:154:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:157:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:158:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:161:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:162:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:441:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:447:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:452:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:11:--   - 1 auxiliary table: voice_corpus_chunks (holds the pgvector index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:43:-- §2 — Create voice_corpus table (per-tenant voice pack)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:46:CREATE TABLE IF NOT EXISTS voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:59:  CONSTRAINT voice_corpus_tenant_version_unique UNIQUE (tenant_slug, version)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:62:-- Partial unique index: at most one active voice_corpus per tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:63:CREATE UNIQUE INDEX IF NOT EXISTS voice_corpus_one_active_per_tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:64:  ON voice_corpus (tenant_slug)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:67:CREATE INDEX IF NOT EXISTS voice_corpus_tenant_slug_idx ON voice_corpus (tenant_slug);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:69:ALTER TABLE voice_corpus ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:70:ALTER TABLE voice_corpus FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:71:DROP POLICY IF EXISTS voice_corpus_tenant_isolation ON voice_corpus;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:72:CREATE POLICY voice_corpus_tenant_isolation ON voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:76:-- §3 — Create voice_corpus_chunks table (pgvector substrate)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:78:-- One row per chunk produced from voice_corpus source docs. Embedding column
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:82:CREATE TABLE IF NOT EXISTS voice_corpus_chunks (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:85:  voice_corpus_id   BIGINT      NOT NULL REFERENCES voice_corpus (id) ON DELETE CASCADE,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:91:  CONSTRAINT voice_corpus_chunks_corpus_chunk_unique UNIQUE (voice_corpus_id, chunk_index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:94:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_tenant_idx ON voice_corpus_chunks (tenant_slug);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:95:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_corpus_idx ON voice_corpus_chunks (voice_corpus_id);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:99:  ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:103:ALTER TABLE voice_corpus_chunks ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:104:ALTER TABLE voice_corpus_chunks FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:105:DROP POLICY IF EXISTS voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:106:CREATE POLICY voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:110:-- §4 — Create tone_rule table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:113:CREATE TABLE IF NOT EXISTS tone_rule (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:126:  CONSTRAINT tone_rule_tenant_rule_id_unique UNIQUE (tenant_slug, rule_id)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:129:CREATE INDEX IF NOT EXISTS tone_rule_tenant_enabled_idx ON tone_rule (tenant_slug, enabled);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:131:ALTER TABLE tone_rule ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:132:ALTER TABLE tone_rule FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:133:DROP POLICY IF EXISTS tone_rule_tenant_isolation ON tone_rule;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:134:CREATE POLICY tone_rule_tenant_isolation ON tone_rule
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:138:-- §5 — Create recent_edit table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:141:CREATE TABLE IF NOT EXISTS recent_edit (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:153:  tone_rules_triggered   TEXT[]      NOT NULL DEFAULT '{}',
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:160:CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:161:CREATE INDEX IF NOT EXISTS recent_edit_tenant_action_idx ON recent_edit (tenant_slug, action_type, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:162:CREATE INDEX IF NOT EXISTS recent_edit_lookback_idx ON recent_edit (tenant_slug, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:164:ALTER TABLE recent_edit ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:165:ALTER TABLE recent_edit FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:166:DROP POLICY IF EXISTS recent_edit_tenant_isolation ON recent_edit;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:167:CREATE POLICY recent_edit_tenant_isolation ON recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:174:-- Voice corpus + tone_rule are mutable (re-index + rule revisions).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:177:GRANT SELECT, INSERT, UPDATE        ON voice_corpus        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:178:GRANT SELECT, INSERT, UPDATE, DELETE ON voice_corpus_chunks TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:179:GRANT SELECT, INSERT, UPDATE, DELETE ON tone_rule           TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:180:GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:182:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_id_seq        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:183:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_chunks_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:184:GRANT USAGE, SELECT ON SEQUENCE tone_rule_id_seq           TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:185:GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:193:-- bypass the GRANT-based append-only model (T5 invariant). FORCE ROW LEVEL
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:199:--   ALTER TABLE voice_corpus OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:200:--   ALTER TABLE voice_corpus_chunks OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:201:--   ALTER TABLE tone_rule OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:202:--   ALTER TABLE recent_edit OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:203:--   ALTER SEQUENCE voice_corpus_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:204:--   ALTER SEQUENCE voice_corpus_chunks_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:205:--   ALTER SEQUENCE tone_rule_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:206:--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:245:-- by postgres; ifos_app has only TRIGGER privilege from Day-11 GRANT).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:280:-- §9 — Reference rows: seed migration-test tenant with a starter voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:282:-- Inserts a single empty active voice_corpus row for migration-test only.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:289:INSERT INTO voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:313:-- SELECT count(*) FROM voice_corpus WHERE tenant_slug = 'migration-test';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:315:-- SELECT indexname FROM pg_indexes WHERE tablename = 'voice_corpus_chunks';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:316:--   → expect: voice_corpus_chunks_pkey, voice_corpus_chunks_tenant_idx,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:317:--             voice_corpus_chunks_corpus_idx, voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:35:#   as **auxiliary Postgres tables** (real CREATE TABLE statements in
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:252:      tone_rules_triggered:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:270:    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:341:  voice_corpus_governs_tone_rules:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:342:    source: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:343:    target: tone_rule
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:346:      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:352:    target: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:384:  Q11_voice_corpus_chunk_storage:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:393:  Q12_tone_rule_severity_block_path:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '520,760p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '1,460p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   520	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   521	      candidate / contact / brief / placement / opportunity entity_types.
   522	      Re-attaches the trigger to entities table (migration §4).
   523	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   524	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   525	    5: |
   526	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   527	      hard-fails on unknown config keys (Rule 2); type-validates the 4 new
   528	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   529	    6: |
   530	      Smoke verification DO block confirms both cash_conductor_*
   531	      tables exist (migration §6).
   532	    7: |
   533	      COMMIT; or ROLLBACK on any error.
   534	
   535	  post_migration_steps:
   536	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   537	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   538	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   539	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   540	       Cat-β findings closed
   541	
   542	# ============================================================================
   543	# §7 — Codex ratification path
   544	# ============================================================================
   545	
   546	codex_ratification:
   547	  skill: review-schema-change
   548	  expected_round_trips: 1-2 (mechanical fixes only)
   549	  manifest_queue_position: 44 (after v0.2 supplement at 29)
   550	
   551	# ============================================================================
   552	# §8 — Open questions (structured per review-schema-change §6)
   553	# ============================================================================
   554	
   555	open_questions:
   556	
   557	  Q1_employment_type_enum_completeness:
   558	    question: Are 6 employment_type enum values sufficient for UK recruitment?
   559	    options:
   560	      A: |
   561	        Keep 6 values as in §1.candidate.employment_type — perm, contract,
   562	        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
   563	      B: |
   564	        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
   565	      C: |
   566	        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
   567	        (array of allowed strings); validate at write time against tenant's list.
   568	    v0_3_default: A
   569	    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
   570	      outside A, escalate to B or C.
   571	
   572	  Q2_key_skills_max_length:
   573	    question: Cap at 20 items per candidate adequate?
   574	    options:
   575	      A: Keep cap at 20 (validator hard-fails over).
   576	      B: Increase to 50 (handles senior technical candidates with deep stacks).
   577	      C: Remove cap entirely (rely on application-layer pruning).
   578	    v0_3_default: A
   579	    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
   580	      of candidates hit the 20-item cap, escalate to B.
   581	
   582	  Q3_placement_status_enum_lifecycle:
   583	    question: 6-state placement_status enum maps to Bullhorn's native state machine?
   584	    options:
   585	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   586	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   587	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   588	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   589	    v0_3_default: A
   590	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   591	      escalate to B or C if 1:1 mapping breaks.
   592	
   593	  Q4_cash_conductor_transactions_retention:
   594	    question: Indefinite retention for matched transactions UK GDPR-compatible?
   595	    options:
   596	      A: Indefinite as v0.3 default; defer GDPR audit to v1.1.
   597	      B: 7-year retention then automated pseudonymization (replace payee_name_raw
   598	         + description with hashes; preserve amount + dates for audit).
   599	      C: Per-tenant retention override in tenant_adapters.config.
   600	    v0_3_default: A
   601	    trigger_for_revisit: Founder + legal review at first-pilot DPA; if pilot
   602	      tenant requires specific retention policy, escalate to B or C.
   603	
   604	  Q5_unknown_config_keys_handling:
   605	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   606	    options:
   607	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   608	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   609	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   610	    v0_3_default: A
   611	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   612	      for forward-compat, escalate to B or C with explicit ADR.
   613	
   614	# ============================================================================
   615	# §9 — Why v0.3 is the right unblock
   616	# ============================================================================
   617	
   618	rationale: |
   619	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   620	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   621	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   622	  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys + 1
   623	  payload extension, closing those findings.
   624	
   625	  After v0.3 ratifies + migration applies:
   626	    - Scribe agent.md §3 entity-field table becomes schema-verifiable
   627	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   628	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   629	    - Concierge tenant_adapters.config field refs valid
   630	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   631	
   632	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   633	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   634	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   635	  not schema gaps.
   636	
   637	# ============================================================================
   638	
   639	end_of_supplement: true

 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.2 — voice corpus supplement
     2	# ============================================================================
     3	# Status: Proposed (Codex Day-7 ratification queue addendum)
     4	# Date:   2026-05-20 (Day 8 of Week 0 extension)
     5	# Author: Founder (Maddox), Phase-4 of bubbly-snuggling-lantern.md plan
     6	# Predecessor: docs/verticals/recruitment/vertical-schema.yaml v0.1 (`fec8872`)
     7	#
     8	# Closes Day-7-honest-read gap #1 (voice corpus schema undefined). Required by
     9	# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
    10	# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
    11	# helpers need data substrate; this supplement defines it.
    12	#
    13	# Companion: docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
    14	#   Drafted alongside; executed against migration-test tenant in Phase 5.
    15	#
    16	# Layer over v0.1 generic primitives (entities + entity_links + decision_log
    17	# from Day-4 §6.3). Three new entity_types + one pgvector index over
    18	# voice_corpus.text_chunks + per-entity voice classifier score fields.
    19	# ============================================================================
    20	
    21	vertical: recruitment
    22	version: v0.2
    23	supplements: v0.1
    24	status: Proposed
    25	date: 2026-05-20
    26	author: founder (Maddox), Phase-4 voice-corpus-substrate via Claude Code
    27	codex_ratification_queue_position: 29  # appended after Phase-3 items
    28	
    29	# ============================================================================
    30	# §1 — New entities (3) — auxiliary Postgres tables, NOT entities.data entity_types
    31	# ============================================================================
    32	#
    33	# LAYERING DISCLOSURE (Codex Round 1 — issue 2 incorporation):
    34	#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
    35	#   as **auxiliary Postgres tables** (real CREATE TABLE statements in
    36	#   `migrations/v0.1-to-v0.2.sql`), NOT as entity_types in the entities/entity_links
    37	#   generic primitive layer from Day-4 §6.3. The voice corpus requires (a) pgvector
    38	#   HNSW indexes which need real columns + indexes, not JSONB blobs, and (b) RLS
    39	#   policies on per-table tenant_slug — both of which are simpler with first-class
    40	#   tables.
    41	#
    42	#   The label `entities:` below is a YAML key (the schema-document convention from
    43	#   v0.1) — read it as "new domain entities introduced in v0.2", not as "rows in the
    44	#   Postgres `entities` table". The Postgres-level shape lives in
    45	#   `migrations/v0.1-to-v0.2.sql` §2-§5.
    46	#
    47	#   The 6 voice_classifier_score / voice_drift_at_close fields added to existing
    48	#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
    49	#   in §3 below DO land as `entities.data` JSONB keys per the Day-4 §6.3 generic
    50	#   primitive layer; they are validated by the `validate_voice_scores` trigger
    51	#   in `migrations/v0.1-to-v0.2.sql` §7.
    52	
    53	entities:
    54	
    55	  # --------------------------------------------------------------------------
    56	  voice_corpus:
    57	    description: |
    58	      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
    59	    bullhorn_source: none (IFOS-derived from /vault/<tenant>/_voice/ ingest)
    60	    v1_0_agent_access:
    61	      - Scribe (R — voice samples for note-summary tone matching)
    62	      - Concierge (R — voice samples for outbound message generation)
    63	      - voice-drift-canary nightly cron (R — drift detection input)
    64	    canonical_fields:
    65	      tenant_slug:
    66	        type: string
    67	        required: true
    68	        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
    69	        notes: RLS-isolated per tenant. Maps to entities.tenant_slug at row level.
    70	      version:
    71	        type: string
    72	        required: true
    73	        source: IFOS-derived (operator names at re-index time)
    74	        notes: |
    75	          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
    76	      source_doc_count:
    77	        type: integer
    78	        required: true
    79	        source: IFOS-derived (counted by ingest pipeline)
    80	        notes: Number of source documents ingested into this version (emails + notes + marketing). Sanity check during re-index.
    81	      source_doc_origin:
    82	        type: array
    83	        required: true
    84	        source: IFOS-derived (vault _voice/ subdirectory enumeration)
    85	        notes: |
    86	          Items enum: ["vault_emails", "bullhorn_notes", "marketing_copy", "founder_curated", "consultant_drafts"]. Order documents provenance for the LoRA pipeline (v2.0 Scale tier).
    87	      chunk_count:
    88	        type: integer
    89	        required: true
    90	        source: IFOS-derived (computed by chunking pass)
    91	        notes: Number of text chunks produced from the source corpus after the chunking pass. One chunk = one row in the pgvector index.
    92	      chunking_strategy:
    93	        type: string
    94	        required: true
    95	        source: IFOS-derived (config; v0.2 default "paragraph")
    96	        notes: |
    97	          Enum: ["paragraph", "sentence-window-5", "semantic-segment-v1"]. v0.2 ships with "paragraph" (simplest, deterministic). Other values reserved for v1.1 experimentation per Q5 voice gate research.
    98	      embedding_model:
    99	        type: string
   100	        required: true
   101	        source: IFOS-derived (config; default text-embedding-3-small)
   102	        notes: |
   103	          Identifier of the embedding model used to populate the pgvector column. v0.2 ships with "text-embedding-3-small" (1536 dimensions); revising model triggers re-index + new version row.
   104	      last_indexed_at:
   105	        type: timestamp
   106	        required: true
   107	        source: IFOS-derived (timestamped at ingest completion)
   108	        notes: When the indexing pipeline last completed for this version. Set on row insert; never updated post-insert (immutability of versioned packs).
   109	      is_active:
   110	        type: boolean
   111	        required: true
   112	        source: IFOS-derived (atomic flip on version rollover)
   113	        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
   114	      ingest_completion_ms:
   115	        type: integer
   116	        required: false
   117	        source: IFOS-derived (observability counter; pipeline timing)
   118	        notes: How long the ingest+chunk+embed pipeline took. Observability only.
   119	    notes: |
   120	      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
   121	
   122	  # --------------------------------------------------------------------------
   123	  tone_rule:
   124	    description: |
   125	      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
   126	    bullhorn_source: none (IFOS-derived; authored in /vault/<tenant>/_voice/tone-rules.yaml then synced to Postgres)
   127	    v1_0_agent_access:
   128	      - Scribe (R — note format constraints)
   129	      - Cash Conductor (R — payment reminder tone)
   130	      - Concierge (R — every outbound message)
   131	    canonical_fields:
   132	      tenant_slug:
   133	        type: string
   134	        required: true
   135	        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
   136	      rule_id:
   137	        type: string
   138	        required: true
   139	        source: IFOS-derived (operator names at rule authoring time)
   140	        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
   141	      rule_text:
   142	        type: string
   143	        required: true
   144	        source: IFOS-derived (operator natural-language description)
   145	        notes: Natural-language description of the rule. Surfaced verbatim to the agent.
   146	      severity:
   147	        type: string
   148	        required: true
   149	        source: IFOS-derived (operator picks at rule authoring)
   150	        notes: |
   151	          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
   152	      applies_to_agents:
   153	        type: array
   154	        required: true
   155	        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
   156	        notes: |
   157	          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
   158	      enabled:
   159	        type: boolean
   160	        required: true
   161	        source: IFOS-derived (default true; operator toggles via Brain UI)
   162	        notes: Soft-delete pattern. Tenant can disable a rule without deleting the row; preserves history for audit.
   163	      created_by:
   164	        type: string
   165	        required: true
   166	        source: IFOS-derived (enum from rule provenance — onboarding-flow / Brain-UI / CSM-intervention)
   167	        notes: |
   168	          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
   169	      created_at:
   170	        type: timestamp
   171	        required: true
   172	        source: IFOS-derived (timestamped at insert)
   173	      examples_positive:
   174	        type: array
   175	        required: false
   176	        source: IFOS-derived (operator-curated at rule authoring)
   177	        notes: |
   178	          Items: short string phrases. Examples of compliant text. Surfaced to the agent in the context bundle.
   179	      examples_negative:
   180	        type: array
   181	        required: false
   182	        source: IFOS-derived (operator-curated at rule authoring)
   183	        notes: |
   184	          Items: short string phrases. Examples of non-compliant text (the typical drift the rule prevents). Surfaced to the agent.
   185	    notes: |
   186	      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
   187	
   188	  # --------------------------------------------------------------------------
   189	  recent_edit:
   190	    description: |
   191	      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
   192	    bullhorn_source: none (IFOS-derived from operator's approve/edit UX)
   193	    v1_0_agent_access:
   194	      - voice-drift-canary cron (R — drift detection)
   195	      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
   196	      - LoRA pipeline v2.0 (R — SFT pair generation)
   197	    canonical_fields:
   198	      tenant_slug:
   199	        type: string
   200	        required: true
   201	        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
   202	      agent_name:
   203	        type: string
   204	        required: true
   205	        source: IFOS-derived (from CTX_AGENT_NAME at edit-capture time)
   206	        notes: |
   207	          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
   208	      action_type:
   209	        type: string
   210	        required: true
   211	        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
   212	        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
   213	      target_entity_type:
   214	        type: string
   215	        required: false
   216	        source: IFOS-derived (entity context at edit time; nullable for system-level edits)
   217	        notes: |
   218	          Optional pointer to the entity the draft was about (e.g. "candidate", "client"). Enables linking voice drift to entity classes (some entity types correlate with more drift).
   219	      target_entity_id:
   220	        type: string
   221	        required: false
   222	        source: IFOS-derived (entity ID at edit time; Bullhorn ID or IFOS slug)
   223	        notes: bullhorn_id or IFOS slug. Used in the entity_links join below.
   224	      original_text:
   225	        type: string
   226	        required: true
   227	        source: IFOS-derived (agent's draft as produced; capped at 8192 chars)
   228	        notes: |
   229	          The agent's draft as produced. **Stored verbatim** (privacy posture: this is the agent's own output, not external PII). Length-capped at 8192 chars; if longer, suffix truncated with "[...]" marker.
   230	      edited_text:
   231	        type: string
   232	        required: false
   233	        source: IFOS-derived (consultant's final version at approve time; null when approved verbatim)
   234	        notes: |
   235	          The consultant's final version. Nullable when the consultant approved verbatim (no edit). Length-capped at 8192 chars.
   236	      edit_distance:
   237	        type: integer
   238	        required: false
   239	        source: IFOS-derived (Levenshtein computed at insert; null when edited_text null)
   240	        notes: |
   241	          Computed Levenshtein distance between original_text and edited_text. NULL when edited_text is NULL (approved verbatim). Computed at insert time by the operator UX; not derived at query time.
   242	      resolution:
   243	        type: string
   244	        required: true
   245	        source: IFOS-derived (operator UX action at approve/reject time)
   246	        notes: |
   247	          Enum: ["approved_verbatim", "approved_after_edit", "rejected", "deferred"]. `deferred` indicates operator returned to inbox without resolving (4h timeout case).
   248	      resolved_at:
   249	        type: timestamp
   250	        required: true
   251	        source: IFOS-derived (timestamped at operator action)
   252	      tone_rules_triggered:
   253	        type: array
   254	        required: false
   255	        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
   256	        notes: |
   257	          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
   258	    notes: |
   259	      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
   260	
   261	# ============================================================================
   262	# §2 — Pgvector index (1)
   263	# ============================================================================
   264	
   265	pgvector_indexes:
   266	
   267	  voice_samples_embedded:
   268	    description: |
   269	      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
   270	    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
   271	    column: embedding
   272	    dimensions: 1536                                 # text-embedding-3-small
   273	    distance_metric: cosine
   274	    index_type: hnsw                                 # HNSW preferred over IVFFlat for v1.0 corpus sizes (<10k chunks/tenant)
   275	    index_params:
   276	      m: 16
   277	      ef_construction: 64
   278	    notes: |
   279	      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
   280	    v1_0_query_volume_estimate: 10-50 queries per agent session × ~5 active agents × 24/7 = ~10k queries/day/tenant (well within pgvector + HNSW comfortable load).
   281	
   282	# ============================================================================
   283	# §3 — Additional fields on existing v0.1 entities (6)
   284	# ============================================================================
   285	
   286	additional_fields:
   287	
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
   339	additional_relationships:
   340	
   341	  voice_corpus_governs_tone_rules:
   342	    source: voice_corpus
   343	    target: tone_rule
   344	    cardinality: 1:N
   345	    description: |
   346	      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
   347	    v1_0_exercise: |
   348	      Sparse in v0.2 (linkage is recorded but not actively queried). v1.1 voice-drift-canary cross-references to identify rule-corpus mismatches.
   349	
   350	  recent_edit_drives_retraining:
   351	    source: recent_edit
   352	    target: voice_corpus
   353	    cardinality: M:N
   354	    description: |
   355	      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
   356	    v1_0_exercise: |
   357	      Recorded but not actively driving retraining in v1.0 (Brain UI v1.1 surfaces the queue; v2.0 LoRA pipeline reads it). v0.2 establishes the linkage schema so production data accumulates cleanly from W3 forward.
   358	
   359	# ============================================================================
   360	# §5 — Migration approach (cross-reference to companion SQL)
   361	# ============================================================================
   362	
   363	migration:
   364	  sql_file: docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
   365	  rollback_sql_file: docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
   366	  status: drafted (Phase 4); execution against migration-test tenant scheduled for Phase 5
   367	  rollback_strategy: |
   368	    All v0.2 additions are nullable columns + new tables. Rollback = DROP TABLE on the 3 new tables + DROP COLUMN on the 6 added fields. No v0.1 data is mutated; v0.1 reads continue working after rollback. Migration SQL ships with companion v0.2-to-v0.1.sql (Phase 4 deliverable; landed in same commit).
   369	
   370	  prerequisite_extensions:
   371	    - pgvector (already enabled at Day-4 §6.5; verify version >= 0.8.0 for HNSW support)
   372	
   373	  decision_log_phase_implication: |
   374	    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
   375	
   376	# ============================================================================
   377	# §6 — Open questions added in v0.2
   378	# ============================================================================
   379	# Three new questions; resolved at Codex ratification OR at first pilot data.
   380	# ============================================================================
   381	
   382	open_questions_v0_2_additions:
   383	
   384	  Q11_voice_corpus_chunk_storage:
   385	    question: |
   386	      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
   387	    options:
   388	      - A: Store both — duplicates ~50MB/tenant but enables fast retrieval without vault round-trip
   389	      - B: Store embedding + pointer — saves disk, requires vault read per top-K retrieval (latency cost)
   390	    v0_2_default: A (store both); revise to B if disk pressure surfaces at >50 tenants
   391	    trigger_for_revisit: tenant count > 50 OR pgvector storage > 10% of total disk
   392	
   393	  Q12_tone_rule_severity_block_path:
   394	    question: |
   395	      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
   396	    options:
   397	      - A: Single retry then escalate (current Ultraplan §5.3 default)
   398	      - B: Three retries then escalate
   399	      - C: No retry; immediate escalate (operator triages drift in real-time)
   400	    v0_2_default: A; matches Ultraplan §5.3 retry budget for green-path agents
   401	    trigger_for_revisit: first Concierge build (W10) — measure real retry success rate
   402	
   403	  Q13_recent_edit_retention_under_GDPR:
   404	    question: |
   405	      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
   406	    options:
   407	      - A: Indefinite retention (current v0.2 default; maximises LoRA training signal)
   408	      - B: Text bodies purged after 90 days; metadata retained indefinitely
   409	      - C: Text bodies purged after pilot ends (tenant-controlled retention)
   410	    v0_2_default: |
   411	      Pending D2/D3 resolution. v0.2 ships with text fields stored verbatim
   412	      but production deployment + first pilot LOI BLOCKED until D2 SeedLegals
   413	      advisor input + D3 founder decision land. Recommended default per
   414	      Claude analysis: D3-B (90-day text purge + indefinite metadata) with
   415	      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
   416	      Implementation pre-written: scripts/ifos-pii-purge.sh +
   417	      docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql (post
   418	      Round-2 remediation fix).
   419	    trigger_for_revisit: external advisor onboarding (kill-criterion §3.4 Week 1-2 must-fill) — legal/DPO review of retention posture
   420	
   421	# ============================================================================
   422	# §7 — Versioning continuation (extends v0.1 §6)
   423	# ============================================================================
   424	
   425	versioning:
   426	
   427	  v0_2:
   428	    status: This document — Proposed
   429	    date: 2026-05-20 (Day 8, Week 0 extension period)
   430	    scope: |
   431	      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
   432	
   433	      Live migration deferred to Phase 5 against migration-test tenant first;
   434	      production rollout after Codex ratifies v0.2 (queue position 29) and
   435	      the Diagnostic + Janitor agent builds verify the schema against real
   436	      Bullhorn data (Q3 trigger from v0.1 §5).
   437	    next_action: |
   438	      Phase 5 — execute migration SQL against migration-test tenant; verify pgvector HNSW index builds clean; voice-loader.sh queries return expected shape; commit.
   439	
   440	  v1_0_voice:
   441	    expected_date: post-Concierge build (W10-13) — first agent to heavily exercise voice corpus
   442	    scope: |
   443	      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
   444	
   445	  v1_1_voice:
   446	    expected_date: post-first-pilot voice corpus mature (Q4 2026 if pilot lands)
   447	    scope: |
   448	      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
   449	
   450	  v2_0_voice:
   451	    expected_date: 2027+ per LoRA pipeline activation per Ultraplan §6
   452	    scope: |
   453	      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
   454	
   455	# ============================================================================
   456	# End of vertical-schema.v0.2-supplement.yaml
   457	# ============================================================================

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '420,470p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   420	  RETURN NEW;
   421	END;
   422	$$ LANGUAGE plpgsql;
   423	
   424	DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
   425	
   426	CREATE TRIGGER validate_tenant_adapters_config_v0_3
   427	  BEFORE INSERT OR UPDATE ON tenant_adapters
   428	  FOR EACH ROW
   429	  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
   430	
   431	-- ----------------------------------------------------------------------------
   432	-- §6 — Smoke verification (read-only)
   433	-- ----------------------------------------------------------------------------
   434	
   435	DO $$
   436	DECLARE
   437	  ccr_count INT;
   438	  cci_count INT;
   439	BEGIN
   440	  SELECT count(*) INTO ccr_count FROM information_schema.tables
   441	    WHERE table_name = 'cash_conductor_transactions';
   442	  IF ccr_count != 1 THEN
   443	    RAISE EXCEPTION 'cash_conductor_transactions table not created';
   444	  END IF;
   445	
   446	  SELECT count(*) INTO cci_count FROM information_schema.tables
   447	    WHERE table_name = 'cash_conductor_invoices';
   448	  IF cci_count != 1 THEN
   449	    RAISE EXCEPTION 'cash_conductor_invoices table not created';
   450	  END IF;
   451	
   452	  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
   453	END $$;
   454	
   455	COMMIT;
   456	
   457	-- ============================================================================
   458	-- End of v0.2 → v0.3 migration
   459	-- ============================================================================

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '660,735p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   660	    v2_0_notes: T2 Timesheet + T6 Pay & Bill primary readers/writers.
   661	
   662	# ============================================================================
   663	# §3 — Agent × Entity R/W matrix
   664	# ============================================================================
   665	# Source-of-truth for who-touches-what across v1.0 agents.
   666	# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
   667	# ============================================================================
   668	
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
   725	    client: R        # relationship context
   726	    contact: R       # decision-maker resolution for orange-tier sends
   727	    brief: R         # linked-brief context
   728	    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
   729	    opportunity: none
   730	    timesheet: none
   731	
   732	# ============================================================================
   733	# §4 — Bullhorn mapping
   734	# ============================================================================
   735	# Per-entity Bullhorn source + field-level mapping notes.

codex
The first concrete concern is around the access matrix and table permissions. I’m checking whether it’s an artefact-only wording issue or a load-bearing mismatch with the migration and earlier schema.
exec
/bin/zsh -lc 'rg -n "cash_conductor_transactions|cash_conductor_invoices|tenant_adapters_config_additions|decision_log_payload_extension|entity_field_additions" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:30:  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:43:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:58:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:88:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:91:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:95:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:96:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:98:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:102:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:103:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:109:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:144:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:147:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:151:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:154:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:157:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:161:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:162:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:441:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:447:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:452:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:44:entity_field_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:315:    cash_conductor_transactions: R+W  # v0.3 NEW auxiliary table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:316:    cash_conductor_invoices: R+W      # v0.3 NEW auxiliary table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:352:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:376:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:408:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:470:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:512:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:515:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:593:  Q4_cash_conductor_transactions_retention:

exec
/bin/zsh -lc "rg -n \"Phase 4|Cat-β|Cat-|v0.3|cash_conductor|decision_authority|salary_min|start_date|tenant_adapters|diagnostic_per_claim_sample_rate|per_claim_confidence_distribution\" docs/decisions docs/verticals/recruitment agents packages -g '"'!node_modules'"'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg -n \"tenant_adapters|validate_tenant_adapters|tier_overrides|blocked_recipients|janitor_dedup_threshold|janitor_last_run|config\" docs/verticals/recruitment docs/architecture docs/decisions packages agents -g '"'!node_modules'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:4:# Date:   2026-05-24 (Day 19; post-Round-8 Cat-β unblock)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Closes Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor + Concierge
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:10:# Phase 4 Cat-β section.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:12:# Companion migrations: migrations/v0.2-to-v0.3.sql + migrations/v0.3-to-v0.2.sql
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:22:# v0.3 entity-field additions are JSONB key shapes validated via the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:23:# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:29:version: v0.3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:33:author: founder (Maddox) + Claude Code; bilateral Cat-β unblock
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:42:# validate_entities_data_v0_3() trigger function (migration §4).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:47:    v0_3_new_keys:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:70:          per candidate enforced by validate_entities_data_v0_3.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:92:    v0_3_new_keys:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:119:    v0_3_new_keys:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:160:    v0_3_new_keys:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:202:    v0_3_new_keys:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:242:# §2 — Complete v0.3 agent access matrix
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:246:# and all v0.1 + v0.2 entities. v0.3 changes:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:248:#     decision_authority)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:250:#     + salary_min/max + start_date)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:285:    tone_rule: R           # v0.3 NEW (was no access)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:286:    recent_edit: R         # v0.3 NEW (was Concierge/canary/LoRA only); for tacit-note harvest
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date + decision_authority writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers + salary + start_date writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:  cash_conductor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:315:    cash_conductor_transactions: R+W  # v0.3 NEW auxiliary table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:316:    cash_conductor_invoices: R+W      # v0.3 NEW auxiliary table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:333:    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:339:    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:352:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:355:      as entity.data JSONB. v0.3 introduces a first-class table with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:358:    sql_definition_in: migrations/v0.2-to-v0.3.sql §2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:376:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:380:    sql_definition_in: migrations/v0.2-to-v0.3.sql §3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:401:# §4 — tenant_adapters.config new keys (4 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:405:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:408:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:410:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:413:    set_by: cash_conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:414:    read_by: [cash_conductor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:454:  diagnostic_per_claim_sample_rate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:  per_claim_confidence_distribution:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:476:      tenant_adapters.config.diagnostic_per_claim_sample_rate).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:499:  forward: migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:500:  rollback: migrations/v0.3-to-v0.2.sql
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:512:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:515:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:518:      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:520:      score checks. Adds JSONB key validations for 14 v0.3 fields across
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:524:      v0.3 keys are validated by the trigger, not via ALTER TABLE.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:526:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:528:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:530:      Smoke verification DO block confirms both cash_conductor_*
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:538:       to cite v0.3 supplement instead of "v0.3-supplement-pending"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:       Cat-β findings closed
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:568:    v0_3_default: A
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:578:    v0_3_default: A
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:    v0_3_default: A
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:593:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:596:      A: Indefinite as v0.3 default; defer GDPR audit to v1.1.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:599:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:600:    v0_3_default: A
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:605:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:607:      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:610:    v0_3_default: A
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:615:# §9 — Why v0.3 is the right unblock
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:619:  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:621:  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:625:  After v0.3 ratifies + migration applies:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:629:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:632:  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:256:- Cat-1 (Gate A hybrid): Diagnostic §1 verified already correct
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:257:- Cat-2 (decision-log calls): added hh_decision_output / hh_decision_action calls across all §4 sections; pre-registered action_types via Phase 1
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:260:- Cat-5 (§5 honesty): 5 pre-build scaffolds gained explicit "validate.sh does NOT exist yet — W-X build slice delivers this contract" framing; Diagnostic gained warn-only-paths honesty note
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:287:#### Category β — Schema-supplement-needed (v0.3 supplement is a founder-action gate before W4-W13 builds)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:293:- All five are blocked on v0.3 supplement landing (founder review at first-pilot-onboarding) — DOCUMENTED IN W4 BACKLOG
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:324:**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:329:- Diagnostic: pre-build-with-honesty-notes; Round-8-reviewed; ~3 implementation-gap findings (Cat-δ) queued for W3-4 polish slice
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:366:  status: drafted (Phase 4); execution against migration-test tenant scheduled for Phase 5
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:368:    All v0.2 additions are nullable columns + new tables. Rollback = DROP TABLE on the 3 new tables + DROP COLUMN on the 6 added fields. No v0.1 data is mutated; v0.1 reads continue working after rollback. Migration SQL ships with companion v0.2-to-v0.1.sql (Phase 4 deliverable; landed in same commit).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:417:      docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql (post
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:101:  cash_conductor_run_complete:
agents/_shared/autosend-policy.yaml:342:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:353:# Defaults applied when override fields are absent in tenant_adapters
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:33:Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:119:- Sample rate configurable per tenant via field landing in v0.3 vertical-schema supplement (concrete field name + type specified there, not in this ADR)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
agents/_shared/escalation-codes.md:383:- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
agents/_shared/escalation-codes.md:414:- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/escalation-codes.md:451:  - **Janitor:** placement record has ambiguous lifecycle markers (e.g. start_date present but no end_date AND no `active` flag AND no recent activity); Janitor cannot safely tag or update
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:2:-- IFOS recruitment vertical schema — v0.3 → v0.2 PII purge audit column ROLLBACK
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:4:-- Reverses v0.2-to-v0.3-pii-purge.sql. Strictly destructive on the audit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:29:-- End of v0.3-to-v0.2-pii-purge.sql
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:393:# tenant override via tenant_adapters.config.sampling_rates.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:2:-- IFOS recruitment vertical schema — v0.2 → v0.3 migration
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:4:-- Companion to: docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:5:-- Authored:     2026-05-24 (Day 19; post-bilateral Cat-β unblock)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:10:-- Concierge). v0.3 additions:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 4 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:21:-- All v0.3 additions are STRICTLY ADDITIVE. Rollback path: companion
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:22:-- v0.3-to-v0.2.sql.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:58:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:88:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:91:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:95:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:96:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:98:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:102:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:103:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:109:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:144:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:147:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:151:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:154:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:157:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:161:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:162:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:165:-- §4 — Replace JSONB validation function for entities.data (adds v0.3 keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:169:-- the 6 voice-score keys. v0.3 extends validation to cover the 14 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:173:CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:205:  -- v0.3 candidate fields
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:241:  -- v0.3 contact fields
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:258:  -- v0.3 brief fields
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:297:  -- v0.3 placement fields
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:324:  -- v0.3 opportunity fields
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:359:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:361:CREATE TRIGGER validate_entities_data_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:364:  EXECUTE FUNCTION validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:367:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:370:-- v0.3 codifies 4 new config keys agents read. The validation trigger ensures
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:374:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:383:    -- v0.3 additions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:384:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:387:    'diagnostic_per_claim_sample_rate'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:396:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:400:  -- v0.3 type validations
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:401:  IF c ? 'diagnostic_per_claim_sample_rate' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:402:    IF jsonb_typeof(c->'diagnostic_per_claim_sample_rate') != 'number' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:403:      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be integer';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:405:    IF (c->>'diagnostic_per_claim_sample_rate')::int < 1
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:406:       OR (c->>'diagnostic_per_claim_sample_rate')::int > 100 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:407:      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be 1-100';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:424:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:427:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:429:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:441:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:447:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:452:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:-- End of v0.2 → v0.3 migration
agents/_shared/voice-loader.sh:8:#   - vertical-schema.v0.2-supplement.yaml schema migrated (Phase 4 SQL)
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:2:-- IFOS recruitment vertical schema — v0.3 → v0.2 rollback
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:4:-- Companion rollback for: v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:6:-- Status:                 DRAFTED; only execute if v0.3 changes break production.
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:8:-- Rolls back v0.3 additions:
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:10:--   - Restores v0.2 entities.data validation trigger (loses v0.3 field validation)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:30:  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:39:-- §2 — Drop v0.3 auxiliary tables
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:43:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:49:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:50:DROP FUNCTION IF EXISTS validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:68:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:74:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:76:-- tenant_adapters config validation trigger.
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:92:    RAISE EXCEPTION 'v0.3 tables still present after rollback';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:94:  RAISE NOTICE 'v0.3 → v0.2 rollback verified: cash_conductor tables dropped';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:100:-- End of v0.3 → v0.2 rollback
docs/decisions/autosend-approval-bridge-spec.md:224:## §5 — Database migration (v0.3 schema increment)
docs/decisions/autosend-approval-bridge-spec.md:227:- `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` — adds the table + GRANTs + RLS policy
docs/decisions/autosend-approval-bridge-spec.md:228:- `docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql` — rollback (DROP TABLE)
docs/decisions/autosend-approval-bridge-spec.md:229:- `docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml` (or similar) — schema doc
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:5:-- Authored:     2026-05-20 (Phase 4 of bubbly-snuggling-lantern.md plan)
agents/recruitment/cash-conductor/agent.md:86:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:107:Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='xero_reminder_draft_internal'` (registered yellow tier — but Cash Conductor escalates to orange-tier `xero_reminder_send_customer` for the actual customer-facing send routed via Concierge; this row is the draft itself, not the send), payload includes the draft.
agents/recruitment/cash-conductor/agent.md:160:   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
agents/recruitment/cash-conductor/agent.md:169:   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
agents/recruitment/cash-conductor/agent.md:249:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:250:    → hh_decision_action("cash_conductor_run_complete", session_id,
agents/recruitment/cash-conductor/agent.md:273:**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/cash-conductor/agent.md:283:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:319:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:324:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:2:-- IFOS recruitment vertical schema — v0.2 → v0.3 PII purge audit column
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:19:-- All v0.3 additions are strictly additive. Rollback at v0.3-to-v0.2.sql.
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:96:-- End of v0.2-to-v0.3-pii-purge.sql
agents/recruitment/scribe/agent.md:75:| Contact | `seniority`, `decision_authority` (enum: yes/no/influencer/blocker/unknown per Q5 v0.1), `preferred_channel`, `next_action_target_date` |
agents/recruitment/scribe/agent.md:76:| Brief | `salary_min` + `salary_max`, `start_date`, `role_type`, `must_haves` (list), `nice_to_haves` (list), `deal_breakers` (list) |
agents/recruitment/scribe/agent.md:77:| Placement | `start_date`, `placement_status`, `week_1_status_note` (free-text), `satisfaction_signal` (enum) |
agents/recruitment/scribe/agent.md:80:Field names match canonical schema verbatim; some v0.1 fields (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `week_1_status_note`) are scheduled for v0.3 supplement at W6 build start — flagged here as pre-build references requiring schema-supplement landing before Scribe references them in `cycle.sh`. The Q1 verification pass (W6 Day 1) audits all field names against the schema as it exists then.
agents/recruitment/scribe/agent.md:226:**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
docs/decisions/2026-05-18-codex-ratification-manifest.md:85:| 25 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:86:| 26 | `docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql` | RATIFIED | First ratification on Round 2; RATIFIED; paired forward migration remains rejected. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:102:| 9 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:264:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:277:**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/concierge/agent.md:392:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
packages/agents-runtime/_shared/common-voice.json:5:  "description": "Per-tenant voice corpus reference. Read by agents/_shared/voice-loader.sh per master brief §8.1 Change 1. Schema substrate landed in vertical-schema.yaml v0.2 (Phase 4).",
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
agents/recruitment/janitor/agent.md:70:2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run)
agents/recruitment/janitor/agent.md:116:     brief.salary_min/salary_max (lines 371-376)
agents/recruitment/janitor/agent.md:166:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:275:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:26:- `vertical-schema.v0.2-supplement.yaml` (Phase 4, commit `45b59e0`)
agents/recruitment/sourcing-scout/agent.md:231:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:239:Per bilateral-disposition Cat-3: Gate B is a local leading metric for Sourcing Scout quality; NOT mapped to any v1.0 kill-criterion trigger. Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
agents/recruitment/diagnostic/agent.md:3:**Status:** Pre-Build-Round-16-Reviewed (Day-19; full bundle built — agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures all present. 16 Codex review-agent-bundle rounds attempted; ADR-006 closed Cat-1/Cat-ζ Gate A architectural finding (R10); subsequent rounds reduced from 5→5→4→5→5→4→5 mechanical findings with steady-state ~5 findings/round at the cross-reference-sync layer. Per master brief §10.3 step 5: founder-arbitrated Accepted on next bilateral pass OR per documented disagreement. Status flips Proposed → Accepted when ALL: (a) bilateral founder review of remaining mechanical findings, AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds, AND (d) Gate B baseline measurement begins.)
agents/recruitment/diagnostic/agent.md:150:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:163:Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
agents/recruitment/diagnostic/agent.md:222:| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ 10 rounds attempted; ADR-006 (Accepted) closed Cat-1 Gate A finding; residual mechanical findings tracked in disagreement doc Phase 4-5 |
agents/recruitment/diagnostic/agent.md:232:**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (10+ rounds; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on smaller mechanical findings).
packages/harness/cortextos/src/daemon/agent-manager.ts:158:      // (a future change accidentally breaks the exit-await). Phase 4 of
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:50:### Phase 4: Evaluate Agent Research Cycles
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:295:## Phase 4: Autonomous Execution
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:395:## Phase 4: Autonomous Execution
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:294:## Phase 4: Autonomous Execution
packages/harness/cortextos/community/skills/evening-review/SKILL.md:141:## Phase 4: Overnight Task Proposals
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:295:## Phase 4: Autonomous Execution
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:118:## Phase 4: Copy Files
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:140:## Phase 4: Overnight Task Proposals
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:394:## Phase 4: Autonomous Execution
packages/harness/cortextos/community/skills/weekly-review/SKILL.md:156:## Phase 4: Update State
packages/harness/cortextos/templates/orchestrator/.claude/skills/weekly-review/SKILL.md:155:## Phase 4: Update State
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:395:## Phase 4: Autonomous Execution
packages/harness/cortextos/src/bus/task.ts:751:  // reference to an archived task. Phase 4 directive was
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:165:## Dashboard (Phase 4)
packages/harness/cortextos/CHANGELOG.md:24:### Phase 4 — Cron Dashboard
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1155:  // We follow the Phase 4 pattern: routes called directly with NextRequest,
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:4: * Phase 4 Full Backtesting: End-to-end scenarios for all 6 dashboard CRUD
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:331:    console.log('\n=== Phase 4 Performance Summary ===');
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:395:## Phase 4: Autonomous Execution

 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:401:# §4 — tenant_adapters.config new keys (4 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:405:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:408:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:476:      tenant_adapters.config.diagnostic_per_claim_sample_rate).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:526:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:527:      hard-fails on unknown config keys (Rule 2); type-validates the 4 new
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:528:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:599:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:604:  Q5_unknown_config_keys_handling:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:605:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:611:    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:622:  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys + 1
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:629:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:95:        source: IFOS-derived (config; v0.2 default "paragraph")
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:101:        source: IFOS-derived (config; default text-embedding-3-small)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:342:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:349:    reason: "Recipient in tenant's blocked_recipients override list"
agents/_shared/autosend-policy.yaml:353:# Defaults applied when override fields are absent in tenant_adapters
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:287:# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
agents/_shared/hook-helpers.sh:300:  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
agents/_shared/hook-helpers.sh:393:# tenant override via tenant_adapters.config.sampling_rates.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
agents/_shared/tests/test-hook-helpers.sh:193:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:196:tier_overrides:
agents/_shared/tests/test-hook-helpers.sh:207:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:210:tier_overrides:
agents/_shared/tests/test-hook-helpers.sh:220:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:223:tier_overrides:
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:50:- **Definition:** Postgres RLS is enabled on every tenant-data table. Even if a policy is missing or misconfigured, RLS-enabled tables default to deny.
docs/architecture/tenancy-invariants.md:125:  Expected: only `config.json` differs (different tenant_slug) and `.env` differs (different secrets); no cross-references.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:52:- Authored as a separate W4 ADR (number to be assigned at W4-polish authoring time; this ADR does NOT pre-assign a number) together with the schema supplements that define its payload key + per-tenant config field
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:119:- Sample rate configurable per tenant via field landing in v0.3 vertical-schema supplement (concrete field name + type specified there, not in this ADR)
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
packages/diagnostic-generator/vitest.config.ts:1:import { defineConfig } from "vitest/config";
docs/verticals/recruitment/vertical-schema.yaml:498:    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
docs/verticals/recruitment/vertical-schema.yaml:538:    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
docs/verticals/recruitment/vertical-schema.yaml:778:    bullhorn_entity: Bullhorn.JobSubmission (or Bullhorn.Opportunity depending on tenant configuration)
docs/verticals/recruitment/vertical-schema.yaml:781:    notes: Tenant-config dependent — some Bullhorn tenants use JobSubmission, some use Opportunity, some both. Adapter layer resolves at ingest.
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:199:  - **A:** Helpers write to `/vault/<tenant>/decision-log.jsonl` (fallback mode) — that's structured. BUT it's an audit trail that replays into Postgres, not the source of truth. Vault `_voice/`, `_config/`, `_brand/`, `_playbooks/` are content (markdown). Vault `spot-checks/` is markdown notes. Vault `_secrets.env` is config (Path D). ✓ Mostly clean.
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are orange-tier (`xero_reminder_draft_internal` per `autosend-safety-policy.yaml` line 104; consultant approval required before send via Concierge); reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:141:   → context.sh hydrates: tenant config + accounting-provider auth +
agents/recruitment/cash-conductor/agent.md:249:    → update tenant_adapters.config.cash_conductor_last_run = now()
packages/utilities/web-scraper/README.md:15:- **Cache:** 1-hour TTL for careers pages (matches `tools.yaml` cache config); disk-backed at `~/.ifos-cache/web-scraper/`. Override via `IFOS_WEB_SCRAPER_CACHE_DIR` env var.
packages/utilities/web-scraper/README.md:17:- **Timeout:** 10s default; configurable per call.
docs/architecture/agent-bundle-renderer-design.md:23:├── config.schema.json                  # Per-tenant config (extends common-*.json)
docs/architecture/agent-bundle-renderer-design.md:44:| `config.schema.json` (line 553) | Per-tenant JSON Schema, extending `common-*.json` shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) | the renderer (materialises to `config.json` per §2.1); per-tenant onboarding wizard at Product Spec §5.2 Day 4 fills schema fields | **Static schema; dynamic materialisation** per tenant |
docs/architecture/agent-bundle-renderer-design.md:64:private discoverAgents(): Array<{ name: string; dir: string; org: string; config: AgentConfig }> {
docs/architecture/agent-bundle-renderer-design.md:70:The daemon scans `${frameworkRoot}/orgs/{org}/agents/{name}/`. Each `<name>` subdirectory is an agent. No manifest file is required — directory presence is the registration. `${ctxRoot}/config/enabled-agents.json` (line 82) is read to honour explicit enable/disable choices but is not required for discovery — agents not listed default to enabled (line 86 fallback `{}`).
docs/architecture/agent-bundle-renderer-design.md:76:| `config.json` | **Practically required** | `loadAgentConfig` at line 946-956 returns `{}` if missing, so technically optional. But fields drive behaviour: `enabled` (line 59), `runtime` (line 117 of agent-process.ts), `model`, `max_session_seconds` (255600 = 71h default per agent-process.ts:598), `working_directory`, `telegram_polling` (line 315), `max_crashes_per_day`, `startup_delay`, `timezone`, `ctx_warning_threshold`, `ctx_handoff_threshold` | `agent-manager.ts:946-956` + `agent-process.ts:597-639` |
docs/architecture/agent-bundle-renderer-design.md:77:| `CLAUDE.md` or `AGENTS.md` | **Practically required** | Claude Code's session-start protocol reads `CLAUDE.md` in the agent's working directory. Without it, the agent boots into a Claude Code session with no IFOS context. Daemon doesn't read it directly. | `agent-pty.ts:146-152` spawns `claude` binary in `cwd = config.working_directory \|\| agentDir \|\| process.cwd()` (line 63); Claude Code's discovery is downstream of that |
docs/architecture/agent-bundle-renderer-design.md:91:`CTX_INSTANCE_ID`, `CTX_ROOT`, `CTX_FRAMEWORK_ROOT`, `CTX_AGENT_NAME`, `CTX_ORG`, `CTX_AGENT_DIR`, `CTX_PROJECT_ROOT`, plus backward-compat `CRM_AGENT_NAME` and `CRM_TEMPLATE_ROOT`. Optional based on tenant config: `CTX_TELEGRAM_CHAT_ID`, `CTX_TIMEZONE`, `TZ`, `CTX_ORCHESTRATOR_AGENT`.
docs/architecture/agent-bundle-renderer-design.md:93:**PTY spawn invariant:** `agent-pty.ts:144-152` spawns the `claude` binary with `cwd = config.working_directory || agentDir`. The agent boots into Claude Code with the rendered agent directory as its working directory.
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:110:| `agents/recruitment/<name>/config.schema.json` | `orgs/<org>/agents/<name>/config.json` | **Synthesis** | (1) `config.schema.json` (the JSON Schema itself, used for validation); (2) `/vault/{tenant-slug}/_config.yaml` per Ultraplan §5.1 line 220 (provides per-tenant values that fill schema fields); (3) bundle-level defaults from any `default` keys in the schema; (4) common-*.json shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) — spec gap §2.1-B on where common schemas live | Materialised JSON validates clean against the source schema using Ajv (or equivalent) before the renderer writes; required fields all populated; no extra fields beyond schema. Daemon-required fields (per §1.2): `enabled` defaults true, `runtime` defaults `claude-code`, `max_session_seconds` defaults 255600, `working_directory` defaults to the rendered agent dir |
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:125:- **§2.1-C:** Ultraplan §5.1 line 220 names `_voice/`, `_playbooks/`, `_decisions/`, `_config.yaml` under `/vault/{tenant}/` but does not enumerate `_secrets.env`. Recommended resolution: add `_secrets.env` to the per-tenant vault skeleton; created at tenant provisioning (Ultraplan §5.5 line 263 `provision-tenant.sh {slug}` step 2). Mode `0600` owned by `ifos-tenant-{slug}`. Per Master Brief §3.3 "structured data lives in Postgres" applies to entity data; per-tenant *secrets* are the canonical exception that lives on the filesystem.
docs/architecture/agent-bundle-renderer-design.md:173:├── config.schema.json
docs/architecture/agent-bundle-renderer-design.md:238:**`config.schema.json` (abbreviated to schema skeleton):**
docs/architecture/agent-bundle-renderer-design.md:243:  "title": "Concierge per-tenant configuration",
docs/architecture/agent-bundle-renderer-design.md:337:├── config.json                              ← synthesised
docs/architecture/agent-bundle-renderer-design.md:399:**`config.json` (materialised per the schema + `/vault/acme/_config.yaml`):**
docs/architecture/agent-bundle-renderer-design.md:476:- `scripts/render-agent.sh` — bash; rejected because the renderer reads YAML schema (`config.schema.json`'s allOf $refs), validates via JSON Schema (Ajv), parses YAML config, and synthesises preamble templates with variable substitution — all easier in TypeScript than in shell.
docs/architecture/agent-bundle-renderer-design.md:485:1. **Day-1 cadence is founder + Claude Code in a session.** A render is something Claude Code triggers after editing the source bundle, or after the founder edits per-tenant config. Manual invocation matches the conversational rhythm; automation creates surprise.
docs/architecture/agent-bundle-renderer-design.md:525:| 1 | Schema-validation failure (config.schema.json vs /vault/<tenant>/_config.yaml) |
docs/architecture/agent-bundle-renderer-design.md:538:- **Per-tenant config:** `/vault/<tenant>/_config.yaml` per Ultraplan §5.1 line 220.
docs/architecture/agent-bundle-renderer-design.md:571:- **No daemon notification.** The renderer writes to disk; the cortextOS daemon's existing `discoverAndStart()` polling picks up new agents on next daemon start (or via `cortextos-ifos enable <agent>` IPC). For brand-new agents the renderer's stdout prints: `Render complete. To activate: pm2 restart ifos-daemon`. For re-renders of existing agents, stdout prints: `Render complete. To pick up new config: cortextos-ifos bus self-restart <agent>`.
docs/architecture/agent-bundle-renderer-design.md:598:- **Refuse if target exists:** rejected because re-renders are the dominant flow — every per-tenant config edit triggers a re-render. A `--force` flag on every invocation is friction without benefit. The §5.1 non-rendered-target check covers the dangerous case (accidental overwrite of a `cortextos-ifos add-agent` scaffold); that's the actual risk.
docs/architecture/agent-bundle-renderer-design.md:604:3. If `bundle_sha` matches AND the rendered output's marker file timestamp matches AND `/vault/<tenant>/_config.yaml` mtime hasn't changed AND `agents/_shared/` SHA matches the org's last-snapshot SHA:
docs/architecture/agent-bundle-renderer-design.md:605:   - Renderer exits 0 with stdout: `No-op: bundle, tenant config, and shared helpers unchanged since last render.`
docs/architecture/agent-bundle-renderer-design.md:609:This makes re-runs cheap and accurate. A founder editing only `agents/recruitment/concierge/agent.md` and re-rendering all tenants gets a no-op on tenants whose config hasn't moved, and a real render on tenants whose `_config.yaml` was touched.
docs/architecture/agent-bundle-renderer-design.md:632:**Detection:** Renderer runs Ajv (or equivalent JSON Schema validator) against `/vault/<tenant>/_config.yaml` materialised through the schema's `allOf $ref` resolution chain. Validation fails on missing required fields, type mismatches, or unrecognised keys (`additionalProperties: false`).
docs/architecture/agent-bundle-renderer-design.md:636:**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.
docs/architecture/agent-bundle-renderer-design.md:652:**Detection:** Renderer checks `agents/recruitment/<name>/` exists; lists files; verifies all six required files from §1.1 are present (README.md, agent.md, config.schema.json, tools.yaml, validate.sh, context.sh).
docs/architecture/agent-bundle-renderer-design.md:662:**Detection:** `/vault/<tenant>/` doesn't exist OR `/vault/<tenant>/_config.yaml` is missing.
docs/architecture/agent-bundle-renderer-design.md:685:- For re-renders of running agents: renderer's stdout instructs `cortextos-ifos bus self-restart <name>` — the agent picks up new config on session refresh per Primitive 2.
docs/architecture/agent-bundle-renderer-design.md:726:3. Creates `goals.json`, `config.json`, `.env` placeholder.
docs/architecture/cortexos-kb-surface-investigation.md:31:- **Chat model field:** `gemini_model: "gemini-2.5-flash"` — exists in config but unclear from setup alone whether mmrag uses it for query rewriting, summarisation, or just metadata.
docs/architecture/cortexos-kb-surface-investigation.md:50:  - Writes a default `config.json` at `$KB_ROOT/config.json` if absent (line 82-95) with the eight-key schema documented above.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 4 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:367:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:370:-- v0.3 codifies 4 new config keys agents read. The validation trigger ensures
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:374:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:377:  c JSONB := NEW.config;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:381:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:382:    'janitor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:396:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:424:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:427:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:429:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
packages/utilities/web-scraper/pnpm-lock.yaml:776:  lilconfig@3.1.3:
packages/utilities/web-scraper/pnpm-lock.yaml:783:  load-tsconfig@0.2.5:
packages/utilities/web-scraper/pnpm-lock.yaml:835:  postcss-load-config@6.0.1:
packages/utilities/web-scraper/pnpm-lock.yaml:1406:      load-tsconfig: 0.2.5
packages/utilities/web-scraper/pnpm-lock.yaml:1543:  lilconfig@3.1.3: {}
packages/utilities/web-scraper/pnpm-lock.yaml:1547:  load-tsconfig@0.2.5: {}
packages/utilities/web-scraper/pnpm-lock.yaml:1592:  postcss-load-config@6.0.1(postcss@8.5.15)(tsx@4.22.3):
packages/utilities/web-scraper/pnpm-lock.yaml:1594:      lilconfig: 3.1.3
packages/utilities/web-scraper/pnpm-lock.yaml:1700:      postcss-load-config: 6.0.1(postcss@8.5.15)(tsx@4.22.3)
docs/decisions/autosend-approval-bridge-spec.md:201:├── tsconfig.json
docs/decisions/autosend-approval-bridge-spec.md:220:Estimated: ~600 lines TypeScript (incl. tests), ~150 lines bash/PM2 config. Similar shape to `packages/agent-renderer/` but smaller.
docs/decisions/autosend-approval-bridge-spec.md:307:- Adds 1 PM2-managed process (`ifos-autosend-bridge`) → ecosystem.config.js update
docs/architecture/cortexos-primitive-status.md:36:**Master-brief description:** `node-pty` + `ecosystem.config.js` regen via `cortextos ecosystem`; agents run as PM2-managed PTY processes that auto-restart on crash or after the 71-hour context rotation (master brief §2.4 row 1).
docs/architecture/cortexos-primitive-status.md:40:The code is real, well-instrumented, and the agent-process layer has unit tests with substantial regression coverage. It does not earn "shipped and tested" because (a) there is no direct unit test of `AgentPTY.spawn()` against the real `node-pty` binding, (b) Day-0 setup surfaced two concrete production-class quirks against this primitive (node-pty Node 25+ ABI breakage, npm-link PATH conflict), and (c) `ecosystem.config.js:42-46` cites a real "2026-04-22 restart storm" that required structural hardening (BUG-011, BUG-032, BUG-040, BUG-048 fixes are still visible as defence-in-depth in `agent-process.ts`).
docs/architecture/cortexos-primitive-status.md:45:- `packages/harness/cortextos/src/daemon/agent-process.ts:21-720` — `AgentProcess` orchestrates the full lifecycle. Notable hardening visible in the code: BUG-040 lifecycle-generation guard (`agent-process.ts:111` and `:142-146`), BUG-032 CRLF + 5s wait on `/exit` graceful shutdown (`:227-231`), BUG-011 exit-promise race fix (`:133-152, :248-256`), BUG-048 stale-config session-timer re-read (`:611-636`). Crash recovery uses exponential backoff capped at 5 minutes (`:437`), `max_crashes_per_day` default 10 (`:28`), halts the agent after exceeded.
docs/architecture/cortexos-primitive-status.md:46:- `packages/harness/cortextos/src/daemon/index.ts:30-214` — daemon-level crash plumbing. `recordCrash` / `shouldSendCrashLoopAlert` / `writeDaemonCrashedMarkers` form the crash-loop detector (3 crashes in 15 min triggers a Telegram alert with 30-min cooldown, `:34-36`). PM2's `max_restarts: 10` in `ecosystem.config.js:47` is the circuit breaker beyond it.
docs/architecture/cortexos-primitive-status.md:47:- `packages/harness/cortextos/ecosystem.config.js:14-51` — daemon script entry, env-driven, `autorestart: true`, `max_restarts: 10`, `restart_delay: 5000`. The 35-line comment block above `max_restarts` explicitly names the 2026-04-22 storm and warns against raising the values without strengthening the upstream fix.
docs/architecture/cortexos-primitive-status.md:78:cortextos-ifos ecosystem                 # writes ecosystem.config.js
docs/architecture/cortexos-primitive-status.md:79:pm2 start ecosystem.config.js
docs/architecture/cortexos-primitive-status.md:101:Two complementary mechanisms ship: a wall-clock session timer at exactly 71 hours (255600s) plus a context-percentage tiered handoff system that fires earlier when actual token usage crosses configurable thresholds. Both have regression-named bug fixes and dedicated test files. No Day-0 brittleness evidence.
docs/architecture/cortexos-primitive-status.md:105:- `src/daemon/agent-process.ts:597-639` — `startSessionTimer()`. `DEFAULT_MAX_SESSION_S = 255600` (line 598) is exactly 71 × 3600. Timer fires `sessionRefresh()` at line 634. BUG-048 fix (line 607-636) re-reads `max_session_seconds` from disk on each timer tick so config edits take effect; `MAX_SETTIMEOUT_MS = 2_147_483_647` clamp at line 603 prevents int32-overflow infinite-loop wedge.
docs/architecture/cortexos-primitive-status.md:114:- `tests/unit/daemon/agent-process.test.ts:234-348` — `sessionRefresh()` delegation order (line 234), 1-second timer fires (line 254), config-on-disk reschedule for longer durations (line 270), and the int32-setTimeout overflow regression (line 305).
docs/architecture/cortexos-primitive-status.md:131:echo '{"max_session_seconds": 60}' > ~/.cortextos/ifos-v2/orgs/test-org/agents/rot-probe/config.json
docs/architecture/cortexos-primitive-status.md:141:# Set thresholds in config.json: ctx_handoff_threshold: 80
docs/architecture/cortexos-primitive-status.md:169:- `src/bus/message.ts:19-44` — HMAC-SHA256 signing using `${ctxRoot}/config/bus-signing-key`. Quirk 5 in `.agents/learnings/00-cortextos-quirks.md` confirms each instance has its own key (IFOS and Personal have separate HMAC keys).
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:204:cat ~/.cortextos/ifos-v2/config/bus-signing-key   # must exist; non-empty
docs/architecture/cortexos-primitive-status.md:244:  - `src/bus/approval.ts:34-42` — path-resolution bug "that hid for hours because of the silent `.catch` below"; fix removed silent fallback, surfaces misconfiguration loudly now.
docs/architecture/cortexos-primitive-status.md:354:# expect: at least one offset file; if activity-channel bot is configured for the org,
docs/architecture/cortexos-primitive-status.md:374:- `src/bus/experiment.ts` (542 lines) — `Experiment` type at line 8-28 with full lifecycle fields (status `proposed | running | completed`, decision `keep | discard | null`, baseline/result values, hypothesis, surface, direction, window, measurement, learning). `ExperimentCycle` type at line 66-79 carries the recurring-experiment cron metadata (`loop_interval`, `enabled`, `created_by`). `ExperimentConfig.theta_wave` config block at line 81-94 with `enabled / interval / metric / auto_create_agent_cycles / auto_modify_agent_cycles` toggles.
docs/architecture/cortexos-primitive-status.md:375:- CHANGELOG §"Experiment System (Theta Wave)" lines 150-160 confirms shipped functions: `createExperiment`, `runExperiment`, `evaluateExperiment`, `manageCycle`, `loadExperimentConfig`. Approval-gate integration: `experiments/config.json` with `approval_required: true` makes `create-experiment` auto-create an approval and block until approved.
docs/architecture/cortexos-primitive-status.md:408:  > ~/.cortextos/ifos-v2/orgs/test-org/agents/probe-analyst/experiments/config.json
docs/architecture/cortexos-primitive-status.md:438:- `templates/orchestrator/` — 17 files including a 238-line `CLAUDE.md` plus `IDENTITY.md`, `SOUL.md`, `GOALS.md`, `GUARDRAILS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `ONBOARDING.md`, `AGENTS.md`, `config.json`, `goals.json`, plus `experiments/`, `memory/`, `skills/` directories. Mirror set for `agent`, `analyst`, `agent-codex`, `hermes`, `m2c1-worker` templates.
docs/architecture/cortexos-primitive-status.md:440:- `src/daemon/agent-manager.ts:312-315` — `config.telegram_polling: false` lets specialist agents skip Telegram polling: "Set telegram_polling: false in config.json to prevent a specialist agent from running its own poller (only the designated orchestrator agent should poll)."
docs/architecture/cortexos-primitive-status.md:492:echo '{"telegram_polling": false}' > ~/.cortextos/ifos-v2/orgs/orch-test/agents/worker/config.json
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
agents/recruitment/scribe/agent.md:131:   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice
agents/recruitment/scribe/agent.md:153:     + consultant accounts (per tenant config)
agents/recruitment/scribe/agent.md:298:| Per-tenant call-routing config (which provider) | Tenant onboarding | ⏸ |
agents/recruitment/scribe/agent.md:322:| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:68:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:74:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:76:-- tenant_adapters config validation trigger.
packages/agent-renderer/src/renderer.ts:18:import { synthesiseConfigJson, ConfigSynthesisError } from "./synthesis/configJson.js";
packages/agent-renderer/src/renderer.ts:31:    join(ctx.vaultRoot, "_config.yaml"),
packages/agent-renderer/src/renderer.ts:32:    join(ctx.vaultRoot, "_config", "_config.yaml"),
packages/agent-renderer/src/renderer.ts:93:  const bundleSchemaPath = join(ctx.bundleDir, "config.schema.json");
packages/agent-renderer/src/renderer.ts:99:  let configJson: Record<string, unknown>;
packages/agent-renderer/src/renderer.ts:101:    configJson = synthesiseConfigJson(ctx, tenantConfig, agentMaterialised as never) as Record<string, unknown>;
packages/agent-renderer/src/renderer.ts:148:    writeFileTracked(join(staging.tmpDir, "config.json"), JSON.stringify(configJson, null, 2) + "\n", undefined, counter);
packages/utilities/web-scraper/vitest.config.ts:1:import { defineConfig } from "vitest/config";
packages/diagnostic-generator/src/sections/icp-fit.ts:26:      `Source: [tenant config](vault://${firmSignal.companyNumber ? "target-patch" : "target-patch"})`,
packages/harness/cortextos/src/telegram/api.ts:408:   * silent-broken-config that used to surface only at first real send:
packages/harness/cortextos/src/telegram/api.ts:460:    // no further probing is needed — the config is broken no matter what
docs/architecture/vault-concurrency.md:201:**Substrate:** filesystem `stat(2)` mtime check before writing. If the file was modified within the last `DEBOUNCE_THRESHOLD_S` (30s default, configurable per tenant), wait and retry.
docs/architecture/vault-concurrency.md:216:  const DEBOUNCE_THRESHOLD_S = 30; // configurable per tenant via /vault/<tenant>/_config.yaml
docs/architecture/vault-concurrency.md:253:### 4.4 — Tenant configurability
docs/architecture/vault-concurrency.md:255:The 30s default is conservative — tenants whose founders type at human speed (~200 char/min) have natural pauses every 5-10s, so 30s of inactivity reliably indicates "founder has stepped away." Tenants with collaborative editing (multiple humans in Obsidian via sync) may need a longer threshold; setting `debounce_threshold_s: 60` in `/vault/<tenant>/_config.yaml` extends it.
docs/architecture/vault-concurrency.md:423:| Debounce threshold default (30s, configurable per tenant via `_config.yaml`) | §4.2 + §4.4 |
docs/architecture/vault-concurrency.md:447:| `OP_LOCK_TIMEOUT_S` (per-operation flock acquire timeout) | 5 seconds | `/vault/<tenant>/_config.yaml` per-tenant override |
docs/architecture/vault-concurrency.md:448:| `DEBOUNCE_THRESHOLD_S` (Obsidian-edit debounce window) | 30 seconds | `/vault/<tenant>/_config.yaml` per-tenant override |
docs/architecture/vault-concurrency.md:450:| Retry policy on Postgres version-mismatch | 1 retry with 100ms backoff (`OP_RETRY_BACKOFF_MS`) | Hard-coded in v1.0; may surface to per-tenant config in v1.1+ if observed contention requires |
docs/decisions/ADR-004-renderer-implementation-deviations.md:72:**Observation:** `cortextos-ifos list-agents` (which calls into `packages/harness/cortextos/src/bus/agents.ts` `listAgents()`) scans `${frameworkRoot}/orgs/<org>/agents/*` and treats every immediate directory child as an agent. `_shared/` sits in that location per ADR-003 §3.3.3 Option γ. Result: `_shared` appears in the list-agents output as if it were an agent named `_shared` in org `<tenant>`, with no display name + no config + status `stopped`.
docs/decisions/ADR-004-renderer-implementation-deviations.md:74:**Decision:** **Accept as upstream limitation.** Do NOT modify the renderer to relocate `_shared/` outside the scanned directory. The placement matches ADR-003's design intent (one canonical `_shared/` per org reachable by all agents via relative symlink). Renderer correctness is unaffected — the daemon's own `discoverAndStart()` doesn't try to launch `_shared` because it has no `config.json`; PM2 + agent-manager skip it cleanly. Only the cosmetic `list-agents` output is affected.
packages/agents-runtime/_shared/common-vault.json:5:  "description": "Vault paths + concurrency lock config per docs/architecture/vault-concurrency.md.",
packages/agents-runtime/_shared/common-vault.json:18:    "config_subdir": {
packages/agents-runtime/_shared/common-vault.json:20:      "default": "_config/",
packages/agents-runtime/_shared/common-vault.json:21:      "description": "Relative to vault_root; holds _config.yaml + autosend-overrides.yaml."
packages/agents-runtime/_shared/common-base.json:5:  "description": "Shared identity fields every agent config must include. Per ADR-003 §2.1-B + spec gap §2.1-B resolution.",
agents/recruitment/sourcing-scout/agent.md:35:Bullhorn "new brief created" webhook → routed via internal bus → Sourcing Scout if tenant config enables auto-source-on-brief-create.
agents/recruitment/sourcing-scout/agent.md:108:   → context.sh hydrates: tenant config + multi-source auth + voice corpus
agents/recruitment/sourcing-scout/agent.md:339:3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
packages/agent-renderer/templates/claude-md-preamble.md:63:Auto-send tier policy per `_shared/autosend-policy.yaml`. Tenant override file (if present): `/vault/{{tenant_slug}}/_config/autosend-overrides.yaml` — read by `autosend_apply_tenant_override` per `docs/decisions/autosend-safety-policy.md` §4.
packages/agent-renderer/src/fileMap.ts:6:    { source: "config.schema.json", target: "config.json", action: "synthesis", note: "Schema + _config.yaml + common-*.json $refs per ADR-003 §2.1 row 2" },
packages/agent-renderer/src/fileMap.ts:21:  return ["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"];
packages/harness/cortextos/src/pty/agent-pty.ts:36:  private config: AgentConfig;
packages/harness/cortextos/src/pty/agent-pty.ts:40:  constructor(env: CtxEnv, config: AgentConfig, logPath?: string, bootstrapPattern?: string) {
packages/harness/cortextos/src/pty/agent-pty.ts:42:    this.config = config;
packages/harness/cortextos/src/pty/agent-pty.ts:63:    const cwd = this.config.working_directory || this.env.agentDir || process.cwd();
packages/harness/cortextos/src/pty/agent-pty.ts:118:    // CTX_TIMEZONE: from config.json timezone field, falls back to system TZ
packages/harness/cortextos/src/pty/agent-pty.ts:119:    const configTimezone = this.config.timezone;
packages/harness/cortextos/src/pty/agent-pty.ts:120:    if (configTimezone) {
packages/harness/cortextos/src/pty/agent-pty.ts:121:      ptyEnv['CTX_TIMEZONE'] = configTimezone;
packages/harness/cortextos/src/pty/agent-pty.ts:122:      ptyEnv['TZ'] = configTimezone; // also set TZ so date/time system calls use correct zone
packages/harness/cortextos/src/pty/agent-pty.ts:233:    if (this.config.model) {
packages/harness/cortextos/src/pty/agent-pty.ts:234:      args.push('--model', this.config.model);
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
agents/recruitment/janitor/agent.md:83:   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice corpus
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run)
agents/recruitment/janitor/agent.md:166:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:275:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:278:| Q4 | Tacit-note attribution — should notes attribute to "Intel Force OS Janitor" or just "Internal note"? Tenant brand preference. | Per-tenant config at first-pilot onboarding. |
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:112:  private _config: AgentConfig;
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:125:  constructor(env: CtxEnv, config: AgentConfig, logPath?: string) {
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:127:    this._config = config;
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:128:    this._cwd = config.working_directory || env.agentDir || process.cwd();
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:486:            config: { features: { goals: true } },
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:503:          config: { features: { goals: true } },
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:515:      config: { features: { goals: true } },
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:784:   *   - context_window_size = modelContextWindow ?? config.codex_context_cap ?? 256000
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:800:    const cap = modelContextWindow ?? this._config.codex_context_cap ?? 256000;
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:845:      model: this._config.model || 'gpt-5-codex',
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:955:    if (this._config.timezone) {
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:956:      env['CTX_TIMEZONE'] = this._config.timezone;
packages/harness/cortextos/src/pty/codex-app-server-pty.ts:957:      env['TZ'] = this._config.timezone;
docs/architecture/second-brain-design.md:26:| `orchestrator/.claude/skills/morning-review/SKILL.md:120-122` | `kb-query "health check"` | Smoke test: confirm KB is configured. Explicitly marked: "**OK or empty results**: note 'KB configured'. **Not configured warning**: note 'KB not configured' (informational, not a failure)." | **No.** Explicitly informational, the morning briefing succeeds either way. |
docs/architecture/second-brain-design.md:58:├── config.schema.json
docs/architecture/second-brain-design.md:116:├── config.schema.json
docs/architecture/second-brain-design.md:125:**The spec gap.** The cortextOS daemon's `AgentManager.discoverAndStart()` (Primitive 1 evidence, `src/daemon/agent-manager.ts:47-78`) bootstraps agents from `${projectRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `.env`, `CLAUDE.md` or `AGENTS.md`, etc.). The IFOS Agent Bundle v2 lives at a different path with a different shape. **Master brief §8 does not specify how the v2 bundle becomes a runnable cortextOS agent.** There is no "renderer" that translates the bundle into a cortextOS-compatible directory. This is a real spec gap and goes in the "Spec gaps surfaced" section at the end of this design.
docs/architecture/second-brain-design.md:131:| **R1. Bundle-on-top-of-template** | Renderer calls `cortextos-ifos add-agent --template agent`, then overlays IFOS files (`agent.md` → custom `CLAUDE.md`, `config.schema.json` → augmented `config.json`, `tools.yaml` references IFOS adapters). | **Yes by default.** All 24 base-template skills come along unless explicitly stripped. | IFOS agents call cortextOS's KB by inheritance, breaking the §1.5 "untouched" promise. |
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:168:├── _config.yaml                                    ← per-tenant config (Ultraplan §5.1 line 220)
docs/architecture/second-brain-design.md:202:| `_config.yaml` | one file | YAML | fixed name | Onboarding wizard Day 4 | every agent's `context.sh` |
docs/architecture/second-brain-design.md:848:│   └── ecosystem.config.js      ← PM2 entry (ifos-wiki-mcp process)
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:967:| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
packages/agent-renderer/README.md:77:| `config.schema.json` | `config.json` | Synthesis: schema + `_config.yaml` + common-*.json defaults + Ajv validation |
packages/agent-renderer/README.md:106:| `schema-validation-failure` | `config.json` failed Ajv validation against bundle schema |
packages/agent-renderer/README.md:136:├── tsconfig.json             ← strict TypeScript; ES2022
packages/agent-renderer/README.md:137:├── tsup.config.ts            ← build target node20; ESM banner with shebang
packages/agent-renderer/README.md:138:├── vitest.config.ts          ← test config; tests/**/*.test.ts
packages/agent-renderer/README.md:148:│       ├── configJson.ts     ← Ajv 2020-12 + common-*.json $refs
packages/agent-renderer/README.md:157:        └── test-tenant-vault/migration-test/  ← _config.yaml + _secrets.env
packages/agent-renderer/README.md:165:- `packages/agents-runtime/_shared/common-*.json` — shared config schemas (Phase 1)
packages/agent-renderer/src/synthesis/configJson.ts:74:  const bundleSchemaPath = join(ctx.bundleDir, "config.schema.json");
packages/agent-renderer/src/synthesis/configJson.ts:84:  const config: JsonObject = {
packages/agent-renderer/src/synthesis/configJson.ts:93:    applyDefaults(schema, config);
packages/agent-renderer/src/synthesis/configJson.ts:95:  applyDefaults(bundleSchema, config);
packages/agent-renderer/src/synthesis/configJson.ts:97:  const resolved = resolveTokens(config, ctx.tenantSlug) as JsonObject;
packages/agent-renderer/src/synthesis/configJson.ts:102:    throw new ConfigSynthesisError("schema-validation-failure", `config.json failed schema validation: ${errors}`);
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:432:    "tier_overrides": {
docs/decisions/autosend-safety-policy.md:437:    "blocked_recipients": [
docs/decisions/autosend-safety-policy.md:463:3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
packages/harness/cortextos/templates/orchestrator/TOOLS.md:146:- Or use Playwright MCP if configured
packages/harness/cortextos/templates/orchestrator/TOOLS.md:156:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/src/pty/output-buffer.ts:34:   * Also streams to log file if configured.
packages/harness/cortextos/src/pty/output-buffer.ts:98:   * For Hermes: looks for the "❯" prompt character (configurable via constructor).
packages/harness/cortextos/templates/orchestrator/CLAUDE.md:211:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/templates/analyst/TOOLS.md:158:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/templates/analyst/CLAUDE.md:131:If `ecosystem.local_version_control.enabled` is true in your config.json, run the daily snapshot at the configured time:
packages/harness/cortextos/templates/analyst/CLAUDE.md:151:If `ecosystem.upstream_sync.enabled` is true in your config.json, check for framework updates on your configured schedule:
packages/harness/cortextos/templates/analyst/CLAUDE.md:178:If `ecosystem.catalog_browse.enabled` is true in your config.json, scan the catalog on your configured schedule:
packages/harness/cortextos/templates/analyst/CLAUDE.md:192:If `ecosystem.community_publish.enabled` is true in your config.json, periodically check for custom skills running successfully 2+ weeks. If user agrees to share:
packages/harness/cortextos/templates/analyst/CLAUDE.md:221:   > "Your new agent is booting up! Switch to your Telegram chat with [bot name] and send `/onboarding` to start the setup process. The agent will walk you through configuring its identity, goals, and workflows."
packages/harness/cortextos/templates/analyst/CLAUDE.md:257:| `config.json` | Crons, max_session_seconds, agent config |
agents/recruitment/diagnostic/context.sh:94:# per common-target-patch.json schema. Loaded from tenant's _config.yaml or
packages/harness/cortextos/src/hooks/hook-crash-alert.ts:82: * Read max_crashes_per_day from the agent's config.json. Returns null if the
packages/harness/cortextos/src/hooks/hook-crash-alert.ts:84: * null as "no limit configured" so a missing config never blocks the alert.
packages/harness/cortextos/src/hooks/hook-crash-alert.ts:89:    const cfg = JSON.parse(readFileSync(join(agentDir, 'config.json'), 'utf-8')) as Record<string, unknown>;
agents/recruitment/diagnostic/agent.md:56:| 6 | **ICP fit vs target_patch** | Score 0-100 against tenant `target_patch.json` (sectors / geographies / size_bands / deal_size_band_gbp); per-dimension match/mismatch list | Tenant config + §1-§5 ✅ | (no change) |
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:11:The system onboarding already collected the essential org configuration. Read it - don't ask the user to repeat it.
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:257:  echo "enabled" || echo "not configured")
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:261:**If NOT configured**, tell the user:
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:315:No configuration needed here - theta-wave is triggered by the analyst.
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:327:> You don't need to set one up now - you can tell me to configure autoresearch anytime. Want to set up a cycle now?"
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:345:> "No problem. You can tell me to configure autoresearch anytime, or the analyst will set it up when they come online."
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:433:> "All set. Here's what I'm configured to do:
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:451:ENABLED=$(cat "${CTX_ROOT}/config/enabled-agents.json" 2>/dev/null || echo '[]')
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:573:ENABLED_FILE="$CTX_ROOT/config/enabled-agents.json"
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:577:    '. + {($name): {"enabled": true, "status": "configured", "org": $org}}' \
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:590:> "Your analyst agent is spinning up now. Switch to your Telegram chat with [analyst_bot_name] and send `/onboarding` to complete its setup. It will configure itself, connect to the org, and check in with me when ready.
docs/decisions/ADR-003-agent-bundle-renderer.md:13:ADR-002 §1.7-A surfaced the spec gap. Master brief §8 (lines 545-568) specifies the IFOS Agent Bundle v2 — six files plus three fixtures at `agents/recruitment/<name>/` — but is silent on how the bundle becomes a runnable cortextOS agent. The cortextOS daemon's `AgentManager.discoverAndStart()` (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`) reads from `${frameworkRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `CLAUDE.md`, `.env`). The two layouts are incompatible without translation.
docs/decisions/ADR-003-agent-bundle-renderer.md:47:- **Synthesis (3):** `agent.md` → `CLAUDE.md` (with cortextOS preamble wrapper); `config.schema.json` → `config.json` (materialised via per-tenant `_config.yaml` + common-*.json $refs); `(no source)` → `.env` (from `_secrets.env` + tools.yaml MCP server list).
docs/decisions/ADR-003-agent-bundle-renderer.md:54:The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.
docs/decisions/ADR-003-agent-bundle-renderer.md:62:**No-op detection** per design §3.4: four-condition check (bundle SHA `git hash-object -t tree` + render log + `/vault/<tenant>/_config.yaml` mtime + `agents/_shared/` SHA). If all four match the last successful render, renderer exits 0 with `No-op:` stdout and a `render_outcome: no-op` JSONL line.
docs/decisions/ADR-003-agent-bundle-renderer.md:107:> # 3. config.schema.json (what the wizard collects)
packages/harness/cortextos/src/pty/hermes-pty.ts:35:  constructor(env: CtxEnv, config: AgentConfig, logPath?: string) {
packages/harness/cortextos/src/pty/hermes-pty.ts:36:    super(env, config, logPath, HERMES_BOOTSTRAP_PATTERN);
packages/harness/cortextos/src/pty/hermes-pty.ts:38:    this.agentDir = config.working_directory || env.agentDir;
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier (`gmail_outlook_send_to_candidate` or `bullhorn_note_customer_visible` depending on channel per autosend-policy.yaml lines 122-149). Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is a Gate B leading metric (warning + aggregated; NOT a Gate A hard-fail) per the same ULTRAPLAN line — making it a hard-fail would block legitimate delayed drafts caused by Bullhorn polling fallbacks. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:99:expected_send_window: <ISO; respects sending-hours per tenant config>
agents/recruitment/concierge/agent.md:120:   → context.sh hydrates: tenant config + Bullhorn auth refresh +
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:228:    → microsoft-graph.send_email() OR gmail.send_email() per tenant config
agents/recruitment/concierge/agent.md:229:    → BCC: tenant's archive address (per tenant config)
agents/recruitment/concierge/agent.md:392:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:399:| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:81:**Current** (master brief §3.4 line 167-176): "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**. … 1. Vendored copy at `packages/harness/cortextos/bus/kb-*.sh` is left untouched. 2. Our overrides live at `packages/brain/bus-overrides/kb-*.sh`. 3. PM2 `ecosystem.config.js` sets `PATH` so our overrides are picked up first…"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
packages/harness/cortextos/src/types/index.ts:104:  display_name?: string; // user-configured name from IDENTITY.md (e.g. "Alpha", "Beta")
packages/harness/cortextos/src/types/index.ts:139:// Agent Config Types (config.json)
packages/harness/cortextos/src/types/index.ts:758:  display_name?: string;  // user-configured name from IDENTITY.md (e.g. "Alpha", "Beta")
packages/agent-renderer/pnpm-lock.yaml:822:  lilconfig@3.1.3:
packages/agent-renderer/pnpm-lock.yaml:829:  load-tsconfig@0.2.5:
packages/agent-renderer/pnpm-lock.yaml:881:  postcss-load-config@6.0.1:
packages/agent-renderer/pnpm-lock.yaml:1467:      load-tsconfig: 0.2.5
packages/agent-renderer/pnpm-lock.yaml:1616:  lilconfig@3.1.3: {}
packages/agent-renderer/pnpm-lock.yaml:1620:  load-tsconfig@0.2.5: {}
packages/agent-renderer/pnpm-lock.yaml:1665:  postcss-load-config@6.0.1(postcss@8.5.15)(tsx@4.22.3):
packages/agent-renderer/pnpm-lock.yaml:1667:      lilconfig: 3.1.3
packages/agent-renderer/pnpm-lock.yaml:1773:      postcss-load-config: 6.0.1(postcss@8.5.15)(tsx@4.22.3)
packages/agent-renderer/vitest.config.ts:1:import { defineConfig } from "vitest/config";
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:38:> "Inter-agent file bus | `bus/` shell wrappers (47 shims execing `node dist/cli.js bus <command>`) + `FastChecker` poll loop in daemon (default 1000ms via `pollInterval` in agent config, configurable per agent)"
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:47:| **B. Reduce to 250ms** | Set `pollInterval: 250` in the IFOS agent template's `config.json`. Re-measure daemon CPU on a 6-agent fleet under load (master brief §6 Day 4 stress-test addition). Keep the existing "complete in seconds" framing | ~0.5 day to add the config + re-baseline; ongoing 4× CPU per FastChecker poll (still negligible — `readdirSync` on a typically-empty inbox dir is sub-millisecond, so 4× sub-ms is still sub-ms). The risk is `bus-signing-key` HMAC verification cost × 4 if inbox traffic spikes | Pipeline floor drops to ~750ms — restores headroom for the sales narrative while leaving CPU comfortable. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:53:3. Option B's "still negligible" assertion is unverified at our pinned SHA on a 6-agent fleet. Re-baselining CPU is work we don't need to do this week. If a customer ever asks for it, we can move to Option B without changing the substrate — it's a single config field per agent.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:64:- Add `"pollInterval": 250` to `packages/agents-runtime/_shared/config.json` (the shared agent config base — not yet built; this becomes a Day-2-onwards artefact).
packages/harness/cortextos/community/catalog.json:235:      "description": "First-boot onboarding wizard — guides new agents through identity setup, Telegram configuration, and first session startup",
packages/harness/cortextos/community/catalog.json:239:      "tags": ["onboarding", "setup", "first-boot", "configuration"],
packages/harness/cortextos/src/hooks/hook-permission-telegram.ts:38:    outputDecision('deny', 'No Telegram credentials configured for remote approval');
docs/decisions/sequencing-target.md:122:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 526 estimate **M (1 week)**. Webhook-driven not always-on. Structured-field mapping is per-firm config not code per Ultraplan §8.1 line 526. Tacit-note extraction is the hard part per Ultraplan §8.1 line 527 ("Start with a small taxonomy (5-10 tacit-note types) and expand") |
docs/decisions/sequencing-target.md:140:| 6. Tenant-onboarding readiness | **Medium** | Needs Xero/QuickBooks/Sage OAuth (one of, per tenant) + Open Banking auth (TrueLayer/Plaid UK per Ultraplan §8.1 line 539). Chase-cadence config per tenant. FD's mobile for Telegram approval per Ultraplan §8.1 line 540 |
docs/decisions/sequencing-target.md:168:| 6. Tenant-onboarding readiness | **Hardest** | Needs Bullhorn + Microsoft Graph (or Gmail) per tenant + full voice corpus loaded + nurture cadence config per stage + auto-send approval categories (Solo: drafts-only; Boutique+: candidate-acknowledgement auto-send) + do-not-contact flags. Full onboarding-wizard Day 4 work (Product Spec §5.2) |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
packages/harness/cortextos/templates/analyst/ONBOARDING.md:13:> **Note:** Your operational config (day/night hours, approval categories, communication style)
packages/harness/cortextos/templates/analyst/ONBOARDING.md:44:**END YOUR TURN.** The user's answer determines your autonomy config - you need it before continuing.
packages/harness/cortextos/templates/analyst/ONBOARDING.md:119:**END YOUR TURN.** You need their thresholds and reporting preferences before writing config.
packages/harness/cortextos/templates/analyst/ONBOARDING.md:121:When you receive their response, write collected thresholds and reporting preferences to `${CTX_AGENT_DIR}/experiments/config.json` under a `monitoring` key:
packages/harness/cortextos/templates/analyst/ONBOARDING.md:124:ANALYST_EXP="${CTX_AGENT_DIR}/experiments/config.json"
packages/harness/cortextos/templates/analyst/ONBOARDING.md:169:  echo "enabled" || echo "not configured")
packages/harness/cortextos/templates/analyst/ONBOARDING.md:173:**If NOT configured:**
packages/harness/cortextos/templates/analyst/ONBOARDING.md:210:First, read day/night mode config from org context so crons fire at the right times:
packages/harness/cortextos/templates/analyst/ONBOARDING.md:229:Check whether `nightly-metrics` is already registered (it should be in config.json by default — the migration will carry it over):
packages/harness/cortextos/templates/analyst/ONBOARDING.md:254:> We can set these up now if you have credentials ready, or I can come back to it later - just tell me to configure a new tool anytime."
packages/harness/cortextos/templates/analyst/ONBOARDING.md:262:- Store configuration in memory
packages/harness/cortextos/templates/analyst/ONBOARDING.md:433:**END YOUR TURN.** You need their ecosystem preferences before writing config.
packages/harness/cortextos/templates/analyst/ONBOARDING.md:435:### Step 21: Write ecosystem config to config.json
packages/harness/cortextos/templates/analyst/ONBOARDING.md:443:}' '.ecosystem = $eco' "${CTX_AGENT_DIR}/config.json" > "${CTX_AGENT_DIR}/config.json.tmp" && \
packages/harness/cortextos/templates/analyst/ONBOARDING.md:444:  mv "${CTX_AGENT_DIR}/config.json.tmp" "${CTX_AGENT_DIR}/config.json"
packages/harness/cortextos/templates/analyst/ONBOARDING.md:462:For each enabled feature, create a persistent cron via `cortextos bus add-cron`. Do NOT use CronCreate or config.json edits — all crons are daemon-managed from `crons.json`:
packages/harness/cortextos/templates/analyst/ONBOARDING.md:494:**END YOUR TURN.** You need their theta wave preferences before writing config.
packages/harness/cortextos/templates/analyst/ONBOARDING.md:496:### Step 25: Merge theta wave config
packages/harness/cortextos/templates/analyst/ONBOARDING.md:498:Merge into `${CTX_AGENT_DIR}/experiments/config.json` (preserve existing monitoring config from Part 2):
packages/harness/cortextos/templates/analyst/ONBOARDING.md:501:ANALYST_EXP="${CTX_AGENT_DIR}/experiments/config.json"
packages/harness/cortextos/templates/analyst/ONBOARDING.md:521:After writing theta wave config, notify the orchestrator:
packages/harness/cortextos/templates/analyst/ONBOARDING.md:526:  cortextos bus send-message "${ORCH_NAME}" normal "Theta wave configured: enabled=true, interval=<interval>, approval_required=<val>, auto_create=<val>, auto_modify=<val>"
packages/harness/cortextos/templates/analyst/ONBOARDING.md:607:ENABLED=$(cat "${CTX_ROOT}/config/enabled-agents.json" 2>/dev/null || echo '[]')
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:34:CONFIG_FILE = Path(os.environ.get("MMRAG_CONFIG", str(MMRAG_DIR / "config.json")))
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:161:def load_config():
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:170:def get_api_key(config):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:171:    key = os.environ.get("GEMINI_API_KEY") or config.get("gemini_api_key")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:250:def embed_content(client, config, content, task_type="RETRIEVAL_DOCUMENT"):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:254:        model=config.get("embedding_model", "gemini-embedding-2-preview"),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:256:        config=types.EmbedContentConfig(
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:257:            output_dimensionality=config.get("embedding_dimensions", DEFAULT_EMBEDDING_DIMENSIONS),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:266:def embed_multimodal(client, config, description_text, media_bytes, mime_type):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:276:    return embed_content(client, config, contents)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:279:def embed_query(client, config, query_text):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:281:    return embed_content(client, config, query_text, task_type="RETRIEVAL_QUERY")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:284:def describe_media(client, config, file_path, media_type="video"):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:321:        model=config.get("gemini_model", "gemini-2.5-flash"),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:507:def ingest_text_file(client, config, collection, file_path):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:517:        chunk_size=config.get("text_chunk_size", DEFAULT_TEXT_CHUNK_SIZE),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:518:        overlap=config.get("text_chunk_overlap", DEFAULT_TEXT_CHUNK_OVERLAP),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:527:        embedding = embed_content(client, config, chunk)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:547:def ingest_image(client, config, collection, file_path):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:557:    description, media_bytes, mime = describe_media(client, config, file_path, "image")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:561:        embedding = embed_multimodal(client, config, description, media_bytes, mime)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:564:        embedding = embed_content(client, config, description)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:593:def ingest_video(client, config, collection, file_path):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:611:    chunk_secs = config.get("video_chunk_seconds", DEFAULT_VIDEO_CHUNK_SECONDS)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:612:    overlap_secs = config.get("video_overlap_seconds", DEFAULT_VIDEO_OVERLAP_SECONDS)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:639:                description, media_bytes, mime = describe_media(client, config, chunk_path, "video")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:653:                    description, media_bytes, mime = describe_media(client, config, audio_path, "audio")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:673:                embedding = embed_multimodal(client, config, description, media_bytes, mime)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:675:                embedding = embed_content(client, config, description)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:677:            embedding = embed_content(client, config, description)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:702:def ingest_audio(client, config, collection, file_path):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:709:    max_chunk = config.get("audio_chunk_seconds", DEFAULT_AUDIO_CHUNK_SECONDS)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:719:        description, media_bytes, mime = describe_media(client, config, file_path, "audio")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:722:            embedding = embed_multimodal(client, config, description, media_bytes, mime)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:724:            embedding = embed_content(client, config, description)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:743:        overlap = config.get("audio_overlap_seconds", DEFAULT_AUDIO_OVERLAP_SECONDS)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:755:                description, media_bytes, mime = describe_media(client, config, chunk["path"], "audio")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:764:                    embedding = embed_multimodal(client, config, description, media_bytes, mime)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:766:                    embedding = embed_content(client, config, description)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:768:                embedding = embed_content(client, config, description)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:791:def ingest_pdf(client, config, collection, file_path):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:820:        model=config.get("gemini_model", "gemini-2.5-flash"),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:840:            chunk_size=config.get("text_chunk_size", DEFAULT_TEXT_CHUNK_SIZE),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:841:            overlap=config.get("text_chunk_overlap", DEFAULT_TEXT_CHUNK_OVERLAP),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:852:        embedding = embed_content(client, config, page_content)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:939:def ingest_office_doc(client, config, collection, file_path):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:980:            chunk_size=config.get("text_chunk_size", DEFAULT_TEXT_CHUNK_SIZE),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:981:            overlap=config.get("text_chunk_overlap", DEFAULT_TEXT_CHUNK_OVERLAP),
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:992:        embedding = embed_content(client, config, section)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1014:def ingest_file(client, config, collection, file_path):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1047:        return ingest_video(client, config, collection, file_path)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1049:        return ingest_audio(client, config, collection, file_path)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1051:        return ingest_image(client, config, collection, file_path)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1053:        return ingest_pdf(client, config, collection, file_path)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1055:        return ingest_office_doc(client, config, collection, file_path)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1057:        return ingest_text_file(client, config, collection, file_path)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1062:            return ingest_text_file(client, config, collection, file_path)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1075:    config = load_config()
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1076:    client = get_genai_client(get_api_key(config))
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1077:    collection_name = args.collection or config.get("default_collection", "default")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1096:                        count = ingest_file(client, config, collection, f)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1108:                    count = ingest_file(client, config, collection, p)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1157:    config = load_config()
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1158:    client = get_genai_client(get_api_key(config))
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1159:    collection_name = args.collection or config.get("default_collection", "default")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1168:    threshold = args.threshold if args.threshold is not None else config.get("similarity_threshold", DEFAULT_SIMILARITY_THRESHOLD)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1169:    max_tokens = args.max_tokens or config.get("max_tokens", DEFAULT_MAX_TOKENS)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1173:    query_embedding = embed_query(client, config, args.question)
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1381:    config = load_config()
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1382:    collection_name = args.collection or config.get("default_collection", "default")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1396:    # Show config values
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1398:    print(f"  Text: {config.get('text_chunk_size', DEFAULT_TEXT_CHUNK_SIZE)} chars, {config.get('text_chunk_overlap', DEFAULT_TEXT_CHUNK_OVERLAP)} overlap")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1399:    print(f"  Video: {config.get('video_chunk_seconds', DEFAULT_VIDEO_CHUNK_SECONDS)}s, {config.get('video_overlap_seconds', DEFAULT_VIDEO_OVERLAP_SECONDS)}s overlap")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1400:    print(f"  Audio: {config.get('audio_chunk_seconds', DEFAULT_AUDIO_CHUNK_SECONDS)}s, {config.get('audio_overlap_seconds', DEFAULT_AUDIO_OVERLAP_SECONDS)}s overlap")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1401:    print(f"  Embedding dims: {config.get('embedding_dimensions', DEFAULT_EMBEDDING_DIMENSIONS)}")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1419:    config = load_config()
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1420:    collection_name = args.collection or config.get("default_collection", "default")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1465:    config = load_config()
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:1466:    collection_name = args.collection or config.get("default_collection", "default")
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:11:- **Migration:** The daemon auto-migrates `config.json` crons to `crons.json` on first boot per agent. A marker file `.crons-migrated` prevents re-runs. The source `config.json` is left untouched — non-destructive.
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:60:The auto-migration handles cron *data* (`config.json` -> `crons.json`). It does not touch the cron *teaching* in your agent's bootstrap, skill, and onboarding files. Pre-migration workspaces frequently still tell the agent to use `CronCreate`, `/loop`, or hand-edit `config.json` to register a cron. After the switch to external persistent crons, every one of those instructions is wrong: `CronCreate` and `/loop` are session-only and evaporate on restart, and `config.json` is no longer the cron source of truth (the daemon owns `crons.json` directly).
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:73:| `(configured in config.json)` | Stale parenthetical about cron source-of-truth | Cron source of truth is now `crons.json`, written by `cortextos bus add-cron`. |
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:74:| `edit config.json` paired with `cron` on the same line | Operator instructions to hand-edit cron entries | The daemon owns `crons.json`. Hand-editing `config.json` no longer registers a cron. |
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:88:| `(configured in config.json)` | `(configured via cortextos bus add-cron)` |
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:89:| `Edit config.json to add the cron entry` | `Run cortextos bus add-cron <agent> <name> <interval> <prompt>` |
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:118:`--apply` performs only the safe literal substitution `(configured in config.json)` -> `(configured via cortextos bus add-cron)`. Everything else is reported but not rewritten. `CronCreate` and `/loop` matches in particular need a manual edit, because the surrounding sentence almost always has to change with them: a sentence like *"Use CronCreate to schedule X"* cannot be mechanically repaired without rewriting the verb and operand. Read the scanner report, then edit by hand using the canonical replacements above.
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:131:- Check that `config.json` has a `crons` array — migration only imports from it if the array exists.
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:148:- The daemon will re-migrate from `config.json` on next start.
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:155:- Existing `config.json` crons are unchanged. The daemon reads from `crons.json` only after migration.
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:157:- If you delete `.crons-migrated` and re-run, migration re-imports from `config.json`.
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:158:- New crons should be added via `cortextos bus add-cron`, not edited in `config.json` directly.
packages/harness/cortextos/community/skills/delegation-matrix/SKILL.md:10:> Reference when scoping any task. Dividing line: **execution-heavy → Codex (if configured as implementer). Judgment-heavy → Agent always.**
packages/harness/cortextos/community/skills/delegation-matrix/SKILL.md:12:Codex is a configurable option. Pick the mode that matches your setup:
packages/harness/cortextos/community/skills/delegation-matrix/SKILL.md:67:For **one-liners and config changes**: Agent writes directly in all modes.
packages/harness/cortextos/community/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/community/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/community/skills/onboarding/SKILL.md:16:Read `config.json` to find your runtime — it determines where your skills live, which slash-commands exist, and which env vars matter.
packages/harness/cortextos/community/skills/onboarding/SKILL.md:19:RUNTIME=$(grep -o '"runtime"[[:space:]]*:[[:space:]]*"[^"]*"' config.json | sed -E 's/.*"runtime"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
packages/harness/cortextos/community/skills/onboarding/SKILL.md:67:| Crons configured and running | `config.json` |
packages/harness/cortextos/templates/orchestrator/HEARTBEAT.md:172:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:31:    it('dashboard has Next.js config', () => {
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:32:      const nextConfig = join(__dirname, '..', 'dashboard', 'next.config.ts');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:64:      // Dashboard reads: config/enabled-agents.json
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:65:      const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:66:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:69:        sentinel: { enabled: true, status: 'configured', org: 'acme' },
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:70:        analyst: { enabled: true, status: 'configured', org: 'acme' },
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:72:      writeFileSync(join(configDir, 'enabled-agents.json'), JSON.stringify(enabledAgents, null, 2), 'utf-8');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:74:      const parsed = JSON.parse(readFileSync(join(configDir, 'enabled-agents.json'), 'utf-8'));
packages/harness/cortextos/package-lock.json:1753:        "load-tsconfig": "^0.2.3"
packages/harness/cortextos/package-lock.json:2062:    "node_modules/get-tsconfig": {
packages/harness/cortextos/package-lock.json:2064:      "resolved": "https://registry.npmjs.org/get-tsconfig/-/get-tsconfig-4.13.7.tgz",
packages/harness/cortextos/package-lock.json:2072:        "url": "https://github.com/privatenumber/get-tsconfig?sponsor=1"
packages/harness/cortextos/package-lock.json:2386:    "node_modules/lilconfig": {
packages/harness/cortextos/package-lock.json:2388:      "resolved": "https://registry.npmjs.org/lilconfig/-/lilconfig-3.1.3.tgz",
packages/harness/cortextos/package-lock.json:2406:    "node_modules/load-tsconfig": {
packages/harness/cortextos/package-lock.json:2408:      "resolved": "https://registry.npmjs.org/load-tsconfig/-/load-tsconfig-0.2.5.tgz",
packages/harness/cortextos/package-lock.json:2698:    "node_modules/postcss-load-config": {
packages/harness/cortextos/package-lock.json:2700:      "resolved": "https://registry.npmjs.org/postcss-load-config/-/postcss-load-config-6.0.1.tgz",
packages/harness/cortextos/package-lock.json:2715:        "lilconfig": "^3.1.1"
packages/harness/cortextos/package-lock.json:3109:        "postcss-load-config": "^6.0.1",
packages/harness/cortextos/package-lock.json:3184:        "get-tsconfig": "^4.7.5"
packages/harness/cortextos/src/daemon/fast-checker.ts:780:      this.log('sendNextQuestion: no Telegram API or chatId configured');
packages/harness/cortextos/src/daemon/fast-checker.ts:873:   * Read ctx thresholds from config.json with mtime-based caching (BUG-048 pattern).
packages/harness/cortextos/src/daemon/fast-checker.ts:879:      const configPath = join(this.agent.getAgentDir(), 'config.json');
packages/harness/cortextos/src/daemon/fast-checker.ts:880:      const mtime = statSync(configPath).mtimeMs;
packages/harness/cortextos/src/daemon/fast-checker.ts:882:        const cfg = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/src/daemon/fast-checker.ts:883:        const config = this.agent.getConfig();
packages/harness/cortextos/src/daemon/fast-checker.ts:884:        config.ctx_warning_threshold = cfg.ctx_warning_threshold;
packages/harness/cortextos/src/daemon/fast-checker.ts:885:        config.ctx_handoff_threshold = cfg.ctx_handoff_threshold;
packages/harness/cortextos/src/daemon/fast-checker.ts:889:    const config = this.agent.getConfig();
packages/harness/cortextos/src/daemon/fast-checker.ts:891:      warn: config.ctx_warning_threshold ?? 70,
packages/harness/cortextos/src/daemon/fast-checker.ts:892:      handoff: config.ctx_handoff_threshold ?? 80,
packages/harness/cortextos/src/daemon/fast-checker.ts:945:    // Check PTY output for hard API overflow errors (always act regardless of threshold config)
packages/harness/cortextos/src/daemon/fast-checker.ts:955:    // No threshold configured — observe-only mode (log but don't act)
packages/harness/cortextos/tests/sprint3-experiments.test.ts:67:    it('inherits measurement/direction/window/surface from a matching cycle in config.json', () => {
packages/harness/cortextos/tests/sprint3-experiments.test.ts:68:      // Write an experiments/config.json with a cycle for this metric.
packages/harness/cortextos/tests/sprint3-experiments.test.ts:71:        join(testDir, 'experiments', 'config.json'),
packages/harness/cortextos/tests/sprint3-experiments.test.ts:106:        join(testDir, 'experiments', 'config.json'),
packages/harness/cortextos/tests/sprint3-experiments.test.ts:143:        join(testDir, 'experiments', 'config.json'),
packages/harness/cortextos/tests/sprint3-experiments.test.ts:374:      // Verify config.json was written
packages/harness/cortextos/tests/sprint3-experiments.test.ts:375:      const configPath = join(testDir, 'experiments', 'config.json');
packages/harness/cortextos/tests/sprint3-experiments.test.ts:376:      expect(existsSync(configPath)).toBe(true);
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:14: *   An agent directory with a legacy config.json (crons array, no crons.json,
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:16: *   there is no window where crons are absent from either config or crons.json.
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:90:mkdirSync(join(j3Root, 'config'), { recursive: true });
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:92:  join(j3Root, 'config', 'enabled-agents.json'),
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:205:  const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:206:  writeFileSync(configPath, JSON.stringify({ crons }, null, 2));
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:207:  return configPath;
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:432:  it('J2-3: pre-migration agent has config.json crons and no crons.json', () => {
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:436:    const configPath = join(tmpRoot, `legacy-config.json`);
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:437:    writeFileSync(configPath, JSON.stringify({
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:454:    const configPath = join(tmpRoot, `upgrade-config.json`);
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:455:    writeFileSync(configPath, JSON.stringify({
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:465:    // Zero-downtime: before migration config.json is the source of truth.
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:466:    const legacyData = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:470:    const result = migrateCronsForAgent(agent, configPath, tmpRoot);
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:492:    const afterData = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:506:    const configPath = join(tmpRoot, `idem-config.json`);
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:507:    writeFileSync(configPath, JSON.stringify({
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:514:    const r1 = migrateCronsForAgent(agent, configPath, tmpRoot);
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:519:    const r2 = migrateCronsForAgent(agent, configPath, tmpRoot);
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:531:    const configPath = join(tmpRoot, `migrated-config.json`);
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:532:    writeFileSync(configPath, JSON.stringify({
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:540:    const migrateResult = migrateCronsForAgent(agent, configPath, tmpRoot);
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:847:      join(j3Root, 'config', 'enabled-agents.json'),
packages/agent-renderer/tests/fixtures/test-agent/config.schema.json:4:  "title": "test-agent config",
packages/agent-renderer/tests/fixtures/test-agent/config.schema.json:5:  "description": "Minimal config schema for renderer test fixture.",
packages/harness/cortextos/src/daemon/index.ts:157:    console.error('[daemon] Crash-loop alert: no operator chat configured ' +
packages/harness/cortextos/src/daemon/index.ts:218: * Run via `pm2 start ecosystem.config.js` or `cortextos ecosystem && pm2 start`.
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:93:      it('mentions automatic migration from config.json', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:95:        expect(content).toMatch(/auto.migrat|migrat.*automatic|migrat.*config\.json/i);
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:221:    it('references crons.json or daemon-managed (not just config.json)', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:291:  it('explains config.json is left untouched (non-destructive)', () => {
packages/harness/cortextos/templates/orchestrator/.claude/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/templates/orchestrator/.claude/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/templates/orchestrator/.claude/skills/onboarding/SKILL.md:45:| Crons configured and running | `config.json` |
packages/harness/cortextos/dashboard/src/lib/markdown-parser.ts:1:// cortextOS Dashboard - Markdown parser for agent config files
packages/harness/cortextos/src/daemon/ipc-server.ts:155:  const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/daemon/ipc-server.ts:225:  const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/daemon/ipc-server.ts:308:  const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/tests/e2e/mock-codex.js:30: *   - `skills/list` request returning a configurable fixture
packages/harness/cortextos/dashboard/src/lib/sync.ts:15:} from './config';
packages/harness/cortextos/dashboard/src/lib/sync.ts:313:    const enabledFile = path.join(CTX_ROOT, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/lib/sync.ts:316:      for (const [name, config] of Object.entries(enabled)) {
packages/harness/cortextos/dashboard/src/lib/sync.ts:317:        const agentOrg = (config as Record<string, string>).org ?? '';
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:61:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:62:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:64:    join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/dashboard/src/lib/auth.ts:1:// cortextOS Dashboard - NextAuth v5 configuration
packages/harness/cortextos/templates/analyst/.claude/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/templates/analyst/.claude/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/templates/analyst/.claude/skills/onboarding/SKILL.md:45:| Crons configured and running | `config.json` |
packages/mcp-connectors/companies-house/vitest.config.ts:1:import { defineConfig } from "vitest/config";
packages/mcp-connectors/companies-house/pnpm-lock.yaml:772:  lilconfig@3.1.3:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:779:  load-tsconfig@0.2.5:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:831:  postcss-load-config@6.0.1:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1398:      load-tsconfig: 0.2.5
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1535:  lilconfig@3.1.3: {}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1539:  load-tsconfig@0.2.5: {}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1584:  postcss-load-config@6.0.1(postcss@8.5.15)(tsx@4.22.3):
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1586:      lilconfig: 3.1.3
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1690:      postcss-load-config: 6.0.1(postcss@8.5.15)(tsx@4.22.3)
packages/harness/cortextos/tests/e2e/lifecycle-codex.test.ts:172:  it('skills/list returns the configured fixture and is keyed by cwd', async () => {
packages/harness/cortextos/dashboard/src/lib/comms-identity.ts:8: * Telegram is configured, and serves as the anchor for pair key
packages/harness/cortextos/dashboard/src/lib/comms-identity.ts:38:  const configPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/lib/comms-identity.ts:39:  if (fs.existsSync(configPath)) {
packages/harness/cortextos/dashboard/src/lib/comms-identity.ts:41:      const data = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/community/skills/community-publish/SKILL.md:78:Requires `ecosystem.community_publish.enabled: true` in config.json.
packages/harness/cortextos/community/skills/community-publish/SKILL.md:82:- User must have a fork of the cortextOS repo configured as `origin`
packages/harness/cortextos/tests/sprint1-templates.test.ts:22:    it('has config.json with heartbeat cron', () => {
packages/harness/cortextos/tests/sprint1-templates.test.ts:23:      const config = JSON.parse(readFileSync(join(agentDir, 'config.json'), 'utf-8'));
packages/harness/cortextos/tests/sprint1-templates.test.ts:24:      expect(config.crons).toBeDefined();
packages/harness/cortextos/tests/sprint1-templates.test.ts:25:      expect(config.crons.length).toBeGreaterThanOrEqual(1);
packages/harness/cortextos/tests/sprint1-templates.test.ts:26:      expect(config.crons[0].name).toBe('heartbeat');
packages/harness/cortextos/tests/sprint1-templates.test.ts:27:      expect(config.crons[0].interval).toBe('4h');
packages/harness/cortextos/tests/sprint1-templates.test.ts:140:    it('has config.json with 5 orchestrator crons', () => {
packages/harness/cortextos/tests/sprint1-templates.test.ts:141:      const config = JSON.parse(readFileSync(join(orchDir, 'config.json'), 'utf-8'));
packages/harness/cortextos/tests/sprint1-templates.test.ts:142:      expect(config.crons.length).toBe(5);
packages/harness/cortextos/tests/sprint1-templates.test.ts:143:      const cronNames = config.crons.map((c: any) => c.name);
packages/harness/cortextos/tests/sprint1-templates.test.ts:218:    it('has config.json with 5 analyst crons + ecosystem config', () => {
packages/harness/cortextos/tests/sprint1-templates.test.ts:219:      const config = JSON.parse(readFileSync(join(analystDir, 'config.json'), 'utf-8'));
packages/harness/cortextos/tests/sprint1-templates.test.ts:220:      expect(config.crons.length).toBe(5);
packages/harness/cortextos/tests/sprint1-templates.test.ts:221:      const cronNames = config.crons.map((c: any) => c.name);
packages/harness/cortextos/tests/sprint1-templates.test.ts:227:      expect(config.ecosystem).toBeDefined();
packages/harness/cortextos/tests/sprint1-templates.test.ts:228:      expect(config.ecosystem.local_version_control).toBeDefined();
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:74:      'Use CronCreate to register a cron.\n(configured in config.json)\n');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:78:    expect(stdout).toContain('(configured in config.json)');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:85:    expect(after).toContain('(configured in config.json)');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:90:      'Heartbeat (configured in config.json).\nUse CronCreate to register.\n');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:93:    expect(after).toContain('(configured via cortextos bus add-cron)');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:94:    expect(after).not.toContain('(configured in config.json)');
packages/harness/cortextos/community/skills/catalog-browse/SKILL.md:14:- Weekly cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/community/skills/catalog-browse/SKILL.md:63:Requires `ecosystem.catalog_browse.enabled: true` in config.json.
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:9:Theta wave is the system's sleep cycle - a deep analysis and improvement process that you (the analyst) own. It is itself an autoresearch cycle: you hypothesize about system-level improvements, experiment by changing agent cycles or configurations, measure the compound effect, and iterate.
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:148:- All changes are logged and user is notified (or approval-gated based on config)
packages/harness/cortextos/src/daemon/cron-migration.ts:2: * cron-migration.ts — Subtask 2.2: Auto-migration of crons from config.json → crons.json
packages/harness/cortextos/src/daemon/cron-migration.ts:4: * Migrates each agent's `crons` array from its config.json into the external
packages/harness/cortextos/src/daemon/cron-migration.ts:15: * One-shot crons from config.json (type:"once" with fire_at) are therefore:
packages/harness/cortextos/src/daemon/cron-migration.ts:24: * The original `crons` array in config.json is never modified.
packages/harness/cortextos/src/daemon/cron-migration.ts:77:// The data migration above moves cron entries from config.json -> crons.json.
packages/harness/cortextos/src/daemon/cron-migration.ts:78:// The *teaching* (CronCreate / /loop / config.json prose) inside each agent's
packages/harness/cortextos/src/daemon/cron-migration.ts:133:  // Workspace dir may not exist (e.g. migration called against a config path
packages/harness/cortextos/src/daemon/cron-migration.ts:156: * Convert a single CronEntry (config.json format) to a CronDefinition (crons.json format).
packages/harness/cortextos/src/daemon/cron-migration.ts:182:      description: `Migrated from config.json (was disabled)`,
packages/harness/cortextos/src/daemon/cron-migration.ts:183:      metadata: { migrated_from_config: true, original_type: effectiveType },
packages/harness/cortextos/src/daemon/cron-migration.ts:235:    metadata: { migrated_from_config: true, original_type: effectiveType },
packages/harness/cortextos/src/daemon/cron-migration.ts:255:  /** Disposition: skipped-already-migrated | no-config | no-crons | migrated */
packages/harness/cortextos/src/daemon/cron-migration.ts:256:  status: 'skipped-already-migrated' | 'no-config' | 'no-crons' | 'migrated';
packages/harness/cortextos/src/daemon/cron-migration.ts:264: * Migrate crons for a single agent from its config.json → crons.json.
packages/harness/cortextos/src/daemon/cron-migration.ts:267: * @param configJsonPath  - Absolute path to the agent's config.json.
packages/harness/cortextos/src/daemon/cron-migration.ts:274:  configJsonPath: string,
packages/harness/cortextos/src/daemon/cron-migration.ts:280:  const result = runMigrationCore(agentName, configJsonPath, ctxRoot, options, log);
packages/harness/cortextos/src/daemon/cron-migration.ts:287:      agentDir: dirname(configJsonPath),
packages/harness/cortextos/src/daemon/cron-migration.ts:304:  configJsonPath: string,
packages/harness/cortextos/src/daemon/cron-migration.ts:321:  // Read config.json — no-op on missing file
packages/harness/cortextos/src/daemon/cron-migration.ts:322:  if (!existsSync(configJsonPath)) {
packages/harness/cortextos/src/daemon/cron-migration.ts:323:    log(`No config.json found for "${agentName}" at ${configJsonPath} — writing empty crons.json + marker`);
packages/harness/cortextos/src/daemon/cron-migration.ts:326:    return { agentName, status: 'no-config' };
packages/harness/cortextos/src/daemon/cron-migration.ts:331:    rawConfig = JSON.parse(readFileSync(configJsonPath, 'utf-8'));
packages/harness/cortextos/src/daemon/cron-migration.ts:333:    // Unreadable / corrupt config.json: write empty crons.json + marker so we
packages/harness/cortextos/src/daemon/cron-migration.ts:336:      `WARNING: failed to parse config.json for "${agentName}" — writing empty crons.json + marker. ` +
packages/harness/cortextos/src/daemon/cron-migration.ts:345:  const configCrons: CronEntry[] = [];
packages/harness/cortextos/src/daemon/cron-migration.ts:352:    configCrons.push(...((rawConfig as { crons: CronEntry[] }).crons));
packages/harness/cortextos/src/daemon/cron-migration.ts:355:  if (configCrons.length === 0) {
packages/harness/cortextos/src/daemon/cron-migration.ts:356:    log(`No crons array in config.json for "${agentName}" — writing empty crons.json + marker`);
packages/harness/cortextos/src/daemon/cron-migration.ts:366:  for (const entry of configCrons) {
packages/harness/cortextos/src/daemon/cron-migration.ts:406: * Scans `{frameworkRoot}/orgs/{org}/agents/{name}/config.json` for every agent
packages/harness/cortextos/src/daemon/cron-migration.ts:459:      const configPath = join(agentsBase, name, 'config.json');
packages/harness/cortextos/src/daemon/cron-migration.ts:461:        const result = migrateCronsForAgent(name, configPath, ctxRoot, { ...options, log });
packages/harness/cortextos/src/daemon/cron-migration.ts:467:        results.push({ agentName: name, status: 'no-config' });
packages/harness/cortextos/src/daemon/agent-manager.ts:57:    for (const { name, dir, org, config } of agentDirs) {
packages/harness/cortextos/src/daemon/agent-manager.ts:58:      // Per-agent config.json `enabled: false` (existing behavior, unchanged)
packages/harness/cortextos/src/daemon/agent-manager.ts:59:      if (config.enabled === false) {
packages/harness/cortextos/src/daemon/agent-manager.ts:60:        console.log(`[agent-manager] Skipping disabled agent: ${name} (per-agent config.json)`);
packages/harness/cortextos/src/daemon/agent-manager.ts:71:      await this.startAgent(name, dir, config, org);
packages/harness/cortextos/src/daemon/agent-manager.ts:82:    const enabledFile = join(this.ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/daemon/agent-manager.ts:147:  async startAgent(name: string, agentDir: string, config?: AgentConfig, org?: string): Promise<void> {
packages/harness/cortextos/src/daemon/agent-manager.ts:181:    if (!config) {
packages/harness/cortextos/src/daemon/agent-manager.ts:182:      config = this.loadAgentConfig(agentDir);
packages/harness/cortextos/src/daemon/agent-manager.ts:241:        log(`Telegram configured (chat_id: ****${String(chatId).slice(-4)}, allowed_user: enabled)`);
packages/harness/cortextos/src/daemon/agent-manager.ts:245:    const agentProcess = new AgentProcess(name, env, config, log);
packages/harness/cortextos/src/daemon/agent-manager.ts:282:    // Subtask 2.2: Auto-migrate crons from config.json → crons.json before
packages/harness/cortextos/src/daemon/agent-manager.ts:285:    const configJsonPath = join(agentDir, 'config.json');
packages/harness/cortextos/src/daemon/agent-manager.ts:286:    migrateCronsForAgent(name, configJsonPath, this.ctxRoot, {
packages/harness/cortextos/src/daemon/agent-manager.ts:313:    // Set telegram_polling: false in config.json to prevent a specialist agent from
packages/harness/cortextos/src/daemon/agent-manager.ts:315:    if (telegramApi && chatId && config.telegram_polling !== false) {
packages/harness/cortextos/src/daemon/agent-manager.ts:320:        // ALLOWED_USER gate: if configured, ignore messages from other users.
packages/harness/cortextos/src/daemon/agent-manager.ts:361:            // BUG-049: Use the agent's actual launch cwd (config.working_directory
packages/harness/cortextos/src/daemon/agent-manager.ts:363:            const launchDir = config?.working_directory || agentDir;
packages/harness/cortextos/src/daemon/agent-manager.ts:429:        // ALLOWED_USER gate: same rule as message handler. If configured,
packages/harness/cortextos/src/daemon/agent-manager.ts:479:   * activity-channel.env configured, start a second TelegramPoller bound
packages/harness/cortextos/src/daemon/agent-manager.ts:731:    const config = model ? { model } : {};
packages/harness/cortextos/src/daemon/agent-manager.ts:810:    if (entry.process['config']?.runtime === 'hermes') {
packages/harness/cortextos/src/daemon/agent-manager.ts:846:    if (entry.process['config']?.runtime === 'hermes') {
packages/harness/cortextos/src/daemon/agent-manager.ts:906:  private discoverAgents(): Array<{ name: string; dir: string; org: string; config: AgentConfig }> {
packages/harness/cortextos/src/daemon/agent-manager.ts:907:    const agents: Array<{ name: string; dir: string; org: string; config: AgentConfig }> = [];
packages/harness/cortextos/src/daemon/agent-manager.ts:932:          const config = this.loadAgentConfig(dir);
packages/harness/cortextos/src/daemon/agent-manager.ts:933:          agents.push({ name, dir, org, config });
packages/harness/cortextos/src/daemon/agent-manager.ts:944:   * Load agent config from config.json.
packages/harness/cortextos/src/daemon/agent-manager.ts:947:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/src/daemon/agent-manager.ts:949:      if (existsSync(configPath)) {
packages/harness/cortextos/src/daemon/agent-manager.ts:950:        return JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/src/daemon/agent-manager.ts:955:    return {}; // Default config
packages/harness/cortextos/dashboard/src/lib/data/organization.ts:5:import { getOrgContextPath, getOrgBrandVoicePath } from '@/lib/config';
packages/harness/cortextos/dashboard/src/lib/data/goals.ts:7:import { getGoalsPath } from '@/lib/config';
packages/harness/cortextos/community/skills/worker-agents/SKILL.md:38:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:69:// Fully synthetic — never reads real config.json from the repository.
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:239: * Write a synthetic config.json for an agent into the temp framework root.
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:245:    join(agentDir, 'config.json'),
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:253:  return join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:351:    // Write all 5 agent configs into tmpFrameworkRoot
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:358:      const configPath = join(tmpFrameworkRoot, 'orgs', 'lifeos', 'agents', f.name, 'config.json');
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:359:      return migrateCronsForAgent(f.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:433:      const configPath = writeAgentConfig(fixture);
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:434:      migrateCronsForAgent(fixture.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:483:      const configPath = join(tmpFrameworkRoot, 'orgs', 'lifeos', 'agents', fixture.name, 'config.json');
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:484:      migrateCronsForAgent(fixture.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:646:      const configPath = join(tmpFrameworkRoot, 'orgs', 'lifeos', 'agents', fixture.name, 'config.json');
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:647:      migrateCronsForAgent(fixture.name, configPath, tmpCtxRoot, { log: (msg) => logs.push(msg) });
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:666:      const configPath = join(tmpFrameworkRoot, 'orgs', 'lifeos', 'agents', fixture.name, 'config.json');
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:667:      const result = migrateCronsForAgent(fixture.name, configPath, tmpCtxRoot, { log: (msg) => secondPassLogs.push(msg) });
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:721:      const configPath = join(tmpFrameworkRoot, 'orgs', 'lifeos', 'agents', fixture.name, 'config.json');
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:722:      migrateCronsForAgent(fixture.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1156:  // CTX_ROOT set to our tmpRoot, enabled-agents.json written to config dir.
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1158:  const CONFIG_DIR_REL = 'config';
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1162:    const configDir = join(tmpRoot, CONFIG_DIR_REL);
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1163:    mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1165:      join(configDir, 'enabled-agents.json'),
packages/agent-renderer/tests/unit/fileMap.test.ts:10:  it("has the synthesis triple (CLAUDE.md + config.json + .env)", () => {
packages/agent-renderer/tests/unit/fileMap.test.ts:15:    expect(targets).toEqual([".env", "CLAUDE.md", "config.json"]);
packages/agent-renderer/tests/unit/fileMap.test.ts:50:    expect(required).toEqual(["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"]);
packages/agent-renderer/tests/unit/preflight.test.ts:30:  for (const f of ["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"]) {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:6: *  1. Migrate clean agent (config has 4 crons → crons.json has same 4)
packages/harness/cortextos/tests/integration/crons-migration.test.ts:13: *  8. Missing config.json → no-op result, no crash, empty crons.json + marker created
packages/harness/cortextos/tests/integration/crons-migration.test.ts:17: * All tests use temp directories only — no real config.json or crons.json files
packages/harness/cortextos/tests/integration/crons-migration.test.ts:73: * Write a config.json to the agent dir with the given crons array.
packages/harness/cortextos/tests/integration/crons-migration.test.ts:78:    join(agentDir, 'config.json'),
packages/harness/cortextos/tests/integration/crons-migration.test.ts:124:  it('migrates all 4 recurring crons from config.json', () => {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:133:    const result = migrateCronsForAgent('alpha', join(agentDir, 'config.json'), tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:156:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:159:    const first = migrateCronsForAgent('alpha', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:164:    const second = migrateCronsForAgent('alpha', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:185:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:188:    migrateCronsForAgent('beta', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:191:    // Modify config — add a second cron — then force re-run
packages/harness/cortextos/tests/integration/crons-migration.test.ts:197:    const forced = migrateCronsForAgent('beta', configPath, tmpCtxRoot, { force: true });
packages/harness/cortextos/tests/integration/crons-migration.test.ts:220:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:223:    const result = migrateCronsForAgent('gamma', configPath, tmpCtxRoot, {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:253:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:256:    const result = migrateCronsForAgent('delta', configPath, tmpCtxRoot, {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:283:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:285:    const result = migrateCronsForAgent('epsilon', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:299:  // Test 7: Missing config.json → no-op, no crash, marker created
packages/harness/cortextos/tests/integration/crons-migration.test.ts:302:  it('handles missing config.json gracefully: no crash, empty crons.json + marker', () => {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:303:    const configPath = join(tmpFrameworkRoot, 'orgs', 'testorg', 'agents', 'noconfig', 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:304:    // Do NOT write config.json
packages/harness/cortextos/tests/integration/crons-migration.test.ts:306:    const result = migrateCronsForAgent('noconfig', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:308:    expect(result.status).toBe('no-config');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:312:    const raw = rawCronsJson(tmpCtxRoot, 'noconfig');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:317:    expect(markerExists(tmpCtxRoot, 'noconfig')).toBe(true);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:324:  it('handles config.json with no crons array: writes empty crons.json + marker', () => {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:328:      join(agentDir, 'config.json'),
packages/harness/cortextos/tests/integration/crons-migration.test.ts:333:    const result = migrateCronsForAgent('nocrons', join(agentDir, 'config.json'), tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:347:  it('handles config.json with empty crons array: writes empty crons.json + marker', () => {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:351:    const result = migrateCronsForAgent('emptycrons', join(agentDir, 'config.json'), tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:370:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:372:    migrateCronsForAgent('zeta', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:385:    expect(c.metadata?.migrated_from_config).toBe(true);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:394:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:396:    migrateCronsForAgent('eta', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:409:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:411:    migrateCronsForAgent('theta', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:471:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:474:    migrateCronsForAgent('iota', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:495:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:498:    migrateCronsForAgent('kappa', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:500:    // Update config (add cron), then force-migrate all
packages/harness/cortextos/tests/integration/crons-migration.test.ts:541:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:543:    const result = migrateCronsForAgent('lambda', configPath, tmpCtxRoot);
packages/harness/cortextos/tests/integration/crons-migration.test.ts:565:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/crons-migration.test.ts:567:    migrateCronsForAgent('mu', configPath, tmpCtxRoot);
packages/agent-renderer/tests/unit/synthesis.test.ts:7:import { synthesiseConfigJson, ConfigSynthesisError } from "../../src/synthesis/configJson.js";
packages/agent-renderer/tests/unit/synthesis.test.ts:80:describe("synthesis/configJson", () => {
packages/agent-renderer/tests/unit/synthesis.test.ts:81:  it("materialises config.json with bundle + common defaults applied", () => {
packages/agent-renderer/tests/unit/synthesis.test.ts:108:    writeFileSync(join(ctx.bundleDir, "config.schema.json"), JSON.stringify(brokenSchema));
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:2:// Discovers agents, reads identity/config files, returns typed agent data
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:13:} from '@/lib/config';
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:30: * Read agent config.json and extract runtime ("claude-code" | "codex-app-server"
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:37:    const raw = await fs.readFile(path.join(agentDir, 'config.json'), 'utf-8');
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:43:    // missing/malformed config — fall through to default
packages/harness/cortextos/tests/integration/execution-log-pagination.test.ts:219:    // The dashboard route uses CTX_ROOT from @/lib/config, but we need to
packages/harness/cortextos/tests/integration/execution-log-pagination.test.ts:220:    // test the pure helper readExecutionLogPage by mocking the config.
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:35:const CONFIG_DIR = path.join(rootTmp, 'config');
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:13: * - Agent config (JSON)
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:596:  test('experiment config.json matches dashboard expectations', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:597:    // Create a mock experiment config matching dashboard Cycle interface
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:601:    const config = {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:617:    writeFileSync(join(expDir, 'config.json'), JSON.stringify(config, null, 2));
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:620:    const parsed = JSON.parse(readFileSync(join(expDir, 'config.json'), 'utf-8'));
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:759:// Dashboard reads from: CTX_ROOT/config/enabled-agents.json
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:762:test.describe('Agent config JSON format', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:764:    const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:765:    mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:767:    const config = {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:773:    writeFileSync(join(configDir, 'enabled-agents.json'), JSON.stringify(config, null, 2));
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:774:    const parsed = JSON.parse(readFileSync(join(configDir, 'enabled-agents.json'), 'utf-8'));
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:927:    const jsonText = '{"action":"deploy","target":"prod","config":{"replicas":3}}';
packages/harness/cortextos/dashboard/src/lib/data/reports.ts:5:// Resolve CTX_ROOT without importing from config (avoids turbopack chunk issues)
packages/harness/cortextos/community/skills/knowledge-base/SKILL.md:67:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:60:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:61:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:62:  writeFileSync(join(configDir, 'enabled-agents.json'), JSON.stringify(agents, null, 2));
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:4:description: "Framework protocol for responding to Claude Max API usage thresholds. Three-tier wind-down and recovery. Agent-specific behavior belongs in deployment config, not here."
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:11:> Agent-specific behavior at each tier belongs in your deployment's CLAUDE.md or config.json.
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:128:**Your deployment config should define:**
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:29:        status: 'configured',
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:36:      expect(parsed.testbot.status).toBe('configured');
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:43:        status: 'configured',
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:55:        testbot: { enabled: true, status: 'configured' },
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:63:      expect(parsed.testbot.status).toBe('configured');
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:141:        join(ctxRoot, 'config'),
packages/harness/cortextos/dashboard/src/lib/data/heartbeats.ts:6:import { CTX_ROOT, getHeartbeatPath } from '@/lib/config';
packages/harness/cortextos/src/daemon/agent-process.ts:24:  private config: AgentConfig;
packages/harness/cortextos/src/daemon/agent-process.ts:62:  constructor(name: string, env: CtxEnv, config: AgentConfig, log?: LogFn) {
packages/harness/cortextos/src/daemon/agent-process.ts:65:    this.config = config;
packages/harness/cortextos/src/daemon/agent-process.ts:66:    if (config.max_crashes_per_day !== undefined) {
packages/harness/cortextos/src/daemon/agent-process.ts:67:      this.maxCrashesPerDay = config.max_crashes_per_day;
packages/harness/cortextos/src/daemon/agent-process.ts:83:    const delay = this.config.startup_delay || 0;
packages/harness/cortextos/src/daemon/agent-process.ts:117:    this.pty = this.config.runtime === 'hermes'
packages/harness/cortextos/src/daemon/agent-process.ts:118:      ? new HermesPTY(this.env, this.config, logPath)
packages/harness/cortextos/src/daemon/agent-process.ts:119:      : this.config.runtime === 'codex-app-server'
packages/harness/cortextos/src/daemon/agent-process.ts:120:        ? new CodexAppServerPTY(this.env, this.config, logPath)
packages/harness/cortextos/src/daemon/agent-process.ts:121:        : new AgentPTY(this.env, this.config, logPath);
packages/harness/cortextos/src/daemon/agent-process.ts:126:    if (this.config.runtime === 'codex-app-server' && this.telegramApi && this.telegramChatId) {
packages/harness/cortextos/src/daemon/agent-process.ts:204:        if (this.config.runtime === 'hermes') {
packages/harness/cortextos/src/daemon/agent-process.ts:210:        } else if (this.config.runtime === 'codex-app-server') {
packages/harness/cortextos/src/daemon/agent-process.ts:322:      model: this.config.model,
packages/harness/cortextos/src/daemon/agent-process.ts:341:    if (this.config.runtime === 'codex-app-server' && this.pty) {
packages/harness/cortextos/src/daemon/agent-process.ts:364:   * Get the agent directory (where config.json and .env live).
packages/harness/cortextos/src/daemon/agent-process.ts:371:   * Get the current agent config (live reference — fields may be updated in-place).
packages/harness/cortextos/src/daemon/agent-process.ts:374:    return this.config;
packages/harness/cortextos/src/daemon/agent-process.ts:457:    if (this.config.runtime === 'hermes') {
packages/harness/cortextos/src/daemon/agent-process.ts:473:    const launchDir = this.config.working_directory || this.env.agentDir;
packages/harness/cortextos/src/daemon/agent-process.ts:534:    return `SESSION CONTINUATION: Your CLI process was restarted with --continue to reload configs. Current UTC time: ${nowUtc}. Your full conversation history is preserved. Re-read AGENTS.md and ALL bootstrap files listed there. External crons are auto-loaded by the daemon — do NOT call CronCreate or CronList for cron restoration.${reminderBlock}${deliverablesBlock} Check inbox. Resume normal operations. After checking inbox, send a Telegram message to the user saying you are back online.`;
packages/harness/cortextos/src/daemon/agent-process.ts:601:    // an infinite tight loop. Clamp at the call site so any future misconfigured
packages/harness/cortextos/src/daemon/agent-process.ts:605:    const initialMs = (this.config.max_session_seconds || DEFAULT_MAX_SESSION_S) * 1000;
packages/harness/cortextos/src/daemon/agent-process.ts:607:    // BUG-048 fix: re-read max_session_seconds from config.json on each timer
packages/harness/cortextos/src/daemon/agent-process.ts:608:    // fire so that config changes after start() take effect. Without this, a
packages/harness/cortextos/src/daemon/agent-process.ts:613:        // Re-read current config from disk
packages/harness/cortextos/src/daemon/agent-process.ts:616:          const configPath = join(this.env.agentDir, 'config.json');
packages/harness/cortextos/src/daemon/agent-process.ts:617:          if (existsSync(configPath)) {
packages/harness/cortextos/src/daemon/agent-process.ts:618:            const cfg = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/src/daemon/agent-process.ts:628:          this.log(`Session timer: config updated to ${currentMaxMs / 1000}s, rescheduling (${Math.round(remainingMs / 1000)}s remaining)`);
packages/harness/cortextos/templates/analyst/.claude/skills/community-publish/SKILL.md:77:Requires `ecosystem.community_publish.enabled: true` in config.json.
packages/harness/cortextos/templates/analyst/.claude/skills/community-publish/SKILL.md:81:- User must have a fork of the cortextOS repo configured as `origin`
packages/harness/cortextos/tests/sprint7-environment.test.ts:79:    it('supports full agent config format', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:80:      const config = {
packages/harness/cortextos/tests/sprint7-environment.test.ts:83:          status: 'configured',
packages/harness/cortextos/tests/sprint7-environment.test.ts:90:          status: 'configured',
packages/harness/cortextos/tests/sprint7-environment.test.ts:102:      writeFileSync(path, JSON.stringify(config, null, 2), 'utf-8');
packages/harness/cortextos/tests/sprint7-environment.test.ts:125:  describe('Loop interval from config.json', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:127:      const config = {
packages/harness/cortextos/tests/sprint7-environment.test.ts:134:      const path = join(testDir, 'config.json');
packages/harness/cortextos/tests/sprint7-environment.test.ts:135:      writeFileSync(path, JSON.stringify(config), 'utf-8');
packages/harness/cortextos/templates/orchestrator/.claude/skills/worker-agents/SKILL.md:37:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:35:const CONFIG_DIR = path.join(perfTmp, 'config');
packages/harness/cortextos/templates/orchestrator/.claude/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
packages/harness/cortextos/templates/orchestrator/.claude/skills/env-management/SKILL.md:4:triggers: ["add key", "api key", "env file", ".env", "secret", "credential", "token", "environment variable", "configure key", "set key", "missing key", "key not set", "where do I put", "shared secret", "org secret", "agent secret", "key not loading", "configure credentials", "new api key", "add to env", "rotate key", "rotate token", "key compromised", "token expired", "update api key", "new bot token", "revoke key", "credential rotation", "key rotation", "secret rotation", "key was leaked", "compromised credential", "force rotation", "provider rotated", "expired key", "rotate credentials", "update secret"]
packages/harness/cortextos/templates/analyst/.claude/skills/catalog-browse/SKILL.md:13:- Weekly cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/templates/analyst/.claude/skills/catalog-browse/SKILL.md:62:Requires `ecosystem.catalog_browse.enabled: true` in config.json.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:108:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:226:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:241:# 1. Create or update the worker's MCP config
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:250:console.log('MCP config updated');
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:253:# 2. Worker must restart to pick up MCP config
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:256:  'MCP config updated at .claude/settings.json. Please restart your session with --continue to pick it up, then test Playwright by taking a screenshot of google.com.'
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:262:1. Install/configure it in the project directory
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:265:4. If failed: fix config, repeat
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:289:    // config.json must be left untouched
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:301:  it('2d: migration auto-creates crons.json + marker from config.json crons array', () => {
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:304:    // Set up: fake agent dir with config.json containing legacy crons (config.json format)
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:313:    const configJsonPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:314:    writeFileSync(configJsonPath, JSON.stringify({
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:325:    const result = migrateCronsForAgent(agent, configJsonPath, tmpRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:346:  it('2e: no data loss — every config.json cron appears in crons.json', () => {
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:357:    const configJsonPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:358:    writeFileSync(configJsonPath, JSON.stringify({ crons: cronEntries }), 'utf-8');
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:360:    migrateCronsForAgent(agent, configJsonPath, tmpRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:384:    const configJsonPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:385:    writeFileSync(configJsonPath, JSON.stringify({
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:390:    const r1 = migrateCronsForAgent(agent, configJsonPath, tmpRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:394:    const r2 = migrateCronsForAgent(agent, configJsonPath, tmpRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:406:    const configJsonPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:407:    writeFileSync(configJsonPath, JSON.stringify({
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:412:    migrateCronsForAgent(agent, configJsonPath, tmpRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:416:    const forceResult = migrateCronsForAgent(agent, configJsonPath, tmpRoot, { force: true, log: () => {} });
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:680:    // Set up legacy config.json with crons
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:683:    const configJsonPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:684:    writeFileSync(configJsonPath, JSON.stringify({
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:695:    const result = migrateCronsForAgent(agent, configJsonPath, tmpRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:719:    const configJsonPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:720:    writeFileSync(configJsonPath, JSON.stringify({
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:724:    const r1 = migrateCronsForAgent(agent, configJsonPath, tmpRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:728:    const r2 = migrateCronsForAgent(agent, configJsonPath, tmpRoot, { force: true, log: () => {} });
packages/harness/cortextos/templates/orchestrator/.claude/skills/knowledge-base/SKILL.md:66:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:476:    mkdirSync(join(tmpRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:478:      join(tmpRoot, 'config', 'enabled-agents.json'),
packages/harness/cortextos/tests/sprint4-catalog.test.ts:251:      writeFileSync(join(sourceDir, 'config.ts'), 'const email = "user@example.com"', 'utf-8');
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:123:    it('does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:124:      expect(body).not.toContain('Restore crons from config.json');
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:6: * still contains stale CronCreate / /loop / config.json teaching, that the
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:61:  const fp = join(tmpAgentDir, 'config.json');
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:77:    const configPath = writeConfigJson([
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:85:        'Edit config.json to add the cron entry.',
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:90:    const result = migrateCronsForAgent('banner-test', configPath, tmpCtxRoot, {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:110:    const configPath = writeConfigJson([
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:116:    migrateCronsForAgent('banner-test', configPath, tmpCtxRoot, {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:123:    migrateCronsForAgent('banner-test', configPath, tmpCtxRoot, {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:133:    const configPath = writeConfigJson([
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:138:    migrateCronsForAgent('banner-test', configPath, tmpCtxRoot, {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:146:    migrateCronsForAgent('banner-test', configPath, tmpCtxRoot, {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:160:    const configPath = writeConfigJson([
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:165:      '# agent\nAll crons live in `crons.json` (configured via cortextos bus add-cron).\n',
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:169:    migrateCronsForAgent('banner-test', configPath, tmpCtxRoot, {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:181:    const configPath = writeConfigJson([
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:195:    migrateCronsForAgent('banner-test', configPath, tmpCtxRoot, {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:207:    const configPath = join(tmpAgentDir, 'config.json');
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:209:      configPath,
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:214:    // Write the config, then nuke the parent dir AFTER reading the path
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:215:    // (simulates a workspace removed between config-read and scan).
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:221:      configPath,
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:226:    // Migration code path returns 'no-config' (file does not exist).
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:227:    expect(result.status).toBe('no-config');
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:235:  it('survives a corrupt config.json without throwing through the advisory', () => {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:236:    const configPath = join(tmpAgentDir, 'config.json');
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:237:    writeFileSync(configPath, '{ not valid json', 'utf-8');
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:240:      'Use `CronCreate` for the heartbeat.\nEdit config.json to register a cron.',
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:246:      configPath,
packages/harness/cortextos/tests/integration/fleet-health-mixed-codex-claude.test.ts:34:  mkdirSync(join(tmpRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/integration/fleet-health-mixed-codex-claude.test.ts:35:  writeFileSync(join(tmpRoot, 'config', 'enabled-agents.json'), JSON.stringify(agents, null, 2));
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:12: *   - "Restore crons from config.json" (old step 6 / session-start language)
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:78:const STALE_RESTORE_PATTERN = /Restore crons from `?config\.json`?/i;
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:124:        it('AGENTS.md: step 6 does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:152:        it('CLAUDE.md: does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:171:        it('ONBOARDING.md: does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:227:      it('does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/templates/orchestrator/.claude/skills/heartbeat/SKILL.md:15:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:3:description: "You need to make a purchase on behalf of the user — buy a SaaS subscription, pay for an API, purchase a domain, or any transaction requiring a credit card. Use this skill to request approval, issue a scoped virtual Visa card via AgentCard, and complete the purchase autonomously. Requires the AgentCard MCP server to be configured."
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:12:Requires: AgentCard MCP server configured via `agent-cards setup-mcp` (CLI: `npm i -g agentcard`).
packages/harness/cortextos/dashboard/src/lib/config.ts:164:  // Check framework root (where agent identity/config files live)
packages/harness/cortextos/dashboard/src/lib/config.ts:184:  const enabledFile = path.join(CTX_ROOT, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/lib/config.ts:188:      for (const [name, config] of Object.entries(data)) {
packages/harness/cortextos/dashboard/src/lib/config.ts:189:        const cfg = config as { enabled?: boolean; org?: string };
packages/harness/cortextos/dashboard/src/lib/config.ts:214:  return path.join(CTX_ROOT, 'config', 'allowed-roots.json');
packages/harness/cortextos/templates/analyst/.claude/skills/worker-agents/SKILL.md:37:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/src/cli/enable-agent.ts:11: *   1. CTX_FRAMEWORK_ROOT env var (explicit, set by ecosystem.config.js)
packages/harness/cortextos/src/cli/enable-agent.ts:50:  return join(homedir(), '.cortextos', instanceId, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/enable-agent.ts:117:  const dir = join(homedir(), '.cortextos', instanceId, 'config');
packages/harness/cortextos/src/cli/enable-agent.ts:187:    // bot-recipient configs, and the self_chat trap (CHAT_ID == bot's own
packages/harness/cortextos/src/cli/enable-agent.ts:188:    // user id) BEFORE the agent boots up on a silently broken config. Without
packages/harness/cortextos/src/cli/enable-agent.ts:193:    // Hard-fails on config-level reasons (bad_token, chat_not_found,
packages/harness/cortextos/src/cli/enable-agent.ts:226:      status: 'configured',
packages/harness/cortextos/templates/analyst/.claude/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
packages/harness/cortextos/templates/analyst/.claude/skills/env-management/SKILL.md:4:triggers: ["add key", "api key", "env file", ".env", "secret", "credential", "token", "environment variable", "configure key", "set key", "missing key", "key not set", "where do I put", "shared secret", "org secret", "agent secret", "key not loading", "configure credentials", "new api key", "add to env", "rotate key", "rotate token", "key compromised", "token expired", "update api key", "new bot token", "revoke key", "credential rotation", "key rotation", "secret rotation", "key was leaked", "compromised credential", "force rotation", "provider rotated", "expired key", "rotate credentials", "update secret"]
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:3: * preserve all existing config fields when injecting `runtime: claude-code`.
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:5: * 17 live agent configs, recovery would be a per-agent restore. Idempotency
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:31:    writeFileSync(join(dir, 'config.json'), JSON.stringify(cfg, null, 2) + '\n', 'utf-8');
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:32:    return join(dir, 'config.json');
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:35:  it('adds runtime: claude-code to configs missing the field', () => {
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:68:  it('skips configs that already have a runtime set (claude-code, hermes, codex-app-server)', () => {
packages/harness/cortextos/src/cli/index.ts:22:import { getConfigCommand } from './get-config.js';
packages/harness/cortextos/community/skills/upstream-sync/SKILL.md:14:- Daily cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/community/skills/upstream-sync/SKILL.md:52:Requires `ecosystem.upstream_sync.enabled: true` in config.json.
packages/harness/cortextos/community/skills/upstream-sync/SKILL.md:58:- NEVER applies during night mode — check day_mode_start/day_mode_end from config.json before proceeding
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:5: * agents configured with `runtime: codex-app-server` migrate, register, and fire
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:102:  const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:104:    configPath,
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:114:  return configPath;
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:146:        join(tmpFrameworkRoot, 'orgs', f.org, 'agents', f.name, 'config.json'),
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:173:      const configPath = writeAgentConfig(fix);
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:174:      migrateCronsForAgent(fix.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:195:      const configPath = writeAgentConfig(fix);
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:196:      migrateCronsForAgent(fix.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:255:  it('config.json runtime field is preserved after migration (does not mutate config)', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:257:    const configPath = writeAgentConfig(fix);
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:258:    migrateCronsForAgent(fix.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:259:    const reread = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:267:      const configPath = writeAgentConfig(fix);
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:268:      migrateCronsForAgent(fix.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:225:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:240:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:249:console.log('MCP config updated');
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:252:# 2. Worker must restart to pick up MCP config
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:255:  'MCP config updated at .claude/settings.json. Please restart your session with --continue to pick it up, then test Playwright by taking a screenshot of google.com.'
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:261:1. Install/configure it in the project directory
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:264:4. If failed: fix config, repeat
packages/harness/cortextos/dashboard/src/lib/actions/skills.ts:6:import { getFrameworkRoot, CTX_ROOT, getOrgs, getAgentsForOrg } from '@/lib/config';
packages/harness/cortextos/tests/integration/fleet-health-mixed-agents.test.ts:71:  mkdirSync(join(tmpRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/integration/fleet-health-mixed-agents.test.ts:73:    join(tmpRoot, 'config', 'enabled-agents.json'),
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:210:/** Write a synthetic config.json for a fixture into tmpFrameworkRoot. */
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:214:  const configPath = join(dir, 'config.json');
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:216:    configPath,
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:229:  return configPath;
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:234:  const configPath = writeAgentConfig(fixture);
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:235:  return migrateCronsForAgent(fixture.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:450:    // Write config.json for ALL 5 agents (preMigrateAgent doesn't touch fw root)
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:457:      const configPath = join(tmpFrameworkRoot, 'orgs', 'lifeos', 'agents', f.name, 'config.json');
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:458:      return migrateCronsForAgent(f.name, configPath, tmpCtxRoot, { log: captureLog });
packages/harness/cortextos/dashboard/src/lib/actions/approvals.ts:6:import { getFrameworkRoot, getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/components.json:7:    "config": "",
packages/harness/cortextos/dashboard/package.json:50:    "eslint-config-next": "16.2.1",
packages/harness/cortextos/dashboard/eslint.config.mjs:1:import { defineConfig, globalIgnores } from "eslint/config";
packages/harness/cortextos/dashboard/eslint.config.mjs:2:import nextVitals from "eslint-config-next/core-web-vitals";
packages/harness/cortextos/dashboard/eslint.config.mjs:3:import nextTs from "eslint-config-next/typescript";
packages/harness/cortextos/dashboard/eslint.config.mjs:8:  // Override default ignores of eslint-config-next.
packages/harness/cortextos/dashboard/eslint.config.mjs:10:    // Default ignores of eslint-config-next:
packages/harness/cortextos/dashboard/src/lib/actions/goals.ts:6:import { getFrameworkRoot, getOrgs } from '@/lib/config';
packages/harness/cortextos/dashboard/src/lib/watcher.ts:7:import { CTX_ROOT, getOrgs } from './config';
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:7:import { CTX_ROOT, getOrgs, getAgentsForOrg, getAgentDir, getOrgContextPath, getOrgBrandVoicePath, getAllowedRootsConfigPath } from '@/lib/config';
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:28:const CONFIG_DIR = path.join(CTX_ROOT, 'config');
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:42:    const configs: TelegramConfig[] = [];
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:75:          configs.push({
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:85:    return configs;
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:209:export async function saveSystemConfig(config: SystemConfig): Promise<ActionResult> {
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:212:      heartbeatStalenessThreshold: Math.max(10, Math.min(3600, Math.round(config.heartbeatStalenessThreshold))),
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:213:      maxCrashesPerDay: Math.max(1, Math.min(100, Math.round(config.maxCrashesPerDay))),
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:214:      sessionRefreshInterval: Math.max(30, Math.min(3600, Math.round(config.sessionRefreshInterval))),
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:288:  // Find the first org that has a context.json (skip empty/unconfigured orgs)
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:368:  const configPath = getAllowedRootsConfigPath();
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:371:  if (fs.existsSync(configPath)) {
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:373:      const parsed = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:420:  const configPath = getAllowedRootsConfigPath();
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:422:  if (fs.existsSync(configPath)) {
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:424:      const parsed = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:438:  const configDir = path.dirname(configPath);
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:439:  if (!fs.existsSync(configDir)) {
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:440:    fs.mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:442:  const tmpPath = configPath + '.tmp';
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:444:  fs.renameSync(tmpPath, configPath);
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:452:  const configPath = getAllowedRootsConfigPath();
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:455:  if (fs.existsSync(configPath)) {
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:457:      const parsed = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:467:  const configDir = path.dirname(configPath);
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:468:  if (!fs.existsSync(configDir)) {
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:469:    fs.mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:471:  const tmpPath = configPath + '.tmp';
packages/harness/cortextos/dashboard/src/lib/actions/settings.ts:473:  fs.renameSync(tmpPath, configPath);
packages/harness/cortextos/templates/orchestrator/.claude/skills/bus-reference/SKILL.md:228:- **chat_id** (required): Telegram chat ID (available in config)
packages/harness/cortextos/templates/orchestrator/.claude/skills/bus-reference/SKILL.md:461:- **Usage**: Write Python scripts using `from playwright.sync_api import sync_playwright` or use Playwright MCP if configured
packages/harness/cortextos/templates/orchestrator/.claude/skills/bus-reference/SKILL.md:462:- **Env**: Service credentials available via environment variables if configured
packages/harness/cortextos/dashboard/package-lock.json:47:        "eslint-config-next": "16.2.1",
packages/harness/cortextos/dashboard/package-lock.json:1081:    "node_modules/@eslint/config-array": {
packages/harness/cortextos/dashboard/package-lock.json:1083:      "resolved": "https://registry.npmjs.org/@eslint/config-array/-/config-array-0.21.2.tgz",
packages/harness/cortextos/dashboard/package-lock.json:1096:    "node_modules/@eslint/config-helpers": {
packages/harness/cortextos/dashboard/package-lock.json:1098:      "resolved": "https://registry.npmjs.org/@eslint/config-helpers/-/config-helpers-0.4.2.tgz",
packages/harness/cortextos/dashboard/package-lock.json:3732:        "@typescript-eslint/tsconfig-utils": "^8.58.0",
packages/harness/cortextos/dashboard/package-lock.json:3765:    "node_modules/@typescript-eslint/tsconfig-utils": {
packages/harness/cortextos/dashboard/package-lock.json:3767:      "resolved": "https://registry.npmjs.org/@typescript-eslint/tsconfig-utils/-/tsconfig-utils-8.58.0.tgz",
packages/harness/cortextos/dashboard/package-lock.json:3829:        "@typescript-eslint/tsconfig-utils": "8.58.0",
packages/harness/cortextos/dashboard/package-lock.json:5333:    "node_modules/cosmiconfig": {
packages/harness/cortextos/dashboard/package-lock.json:5335:      "resolved": "https://registry.npmjs.org/cosmiconfig/-/cosmiconfig-9.0.1.tgz",
packages/harness/cortextos/dashboard/package-lock.json:6195:        "@eslint/config-array": "^0.21.2",
packages/harness/cortextos/dashboard/package-lock.json:6196:        "@eslint/config-helpers": "^0.4.2",
packages/harness/cortextos/dashboard/package-lock.json:6246:    "node_modules/eslint-config-next": {
packages/harness/cortextos/dashboard/package-lock.json:6248:      "resolved": "https://registry.npmjs.org/eslint-config-next/-/eslint-config-next-16.2.1.tgz",
packages/harness/cortextos/dashboard/package-lock.json:6273:    "node_modules/eslint-config-next/node_modules/globals": {
packages/harness/cortextos/dashboard/package-lock.json:6317:        "get-tsconfig": "^4.10.0",
packages/harness/cortextos/dashboard/package-lock.json:6396:        "tsconfig-paths": "^3.15.0"
packages/harness/cortextos/dashboard/package-lock.json:7218:    "node_modules/get-tsconfig": {
packages/harness/cortextos/dashboard/package-lock.json:7220:      "resolved": "https://registry.npmjs.org/get-tsconfig/-/get-tsconfig-4.13.7.tgz",
packages/harness/cortextos/dashboard/package-lock.json:7228:        "url": "https://github.com/privatenumber/get-tsconfig?sponsor=1"
packages/harness/cortextos/dashboard/package-lock.json:10897:        "cosmiconfig": "^9.0.0",
packages/harness/cortextos/dashboard/package-lock.json:10918:        "tsconfig-paths": "^4.2.0",
packages/harness/cortextos/dashboard/package-lock.json:10955:    "node_modules/shadcn/node_modules/tsconfig-paths": {
packages/harness/cortextos/dashboard/package-lock.json:10957:      "resolved": "https://registry.npmjs.org/tsconfig-paths/-/tsconfig-paths-4.2.0.tgz",
packages/harness/cortextos/dashboard/package-lock.json:11789:    "node_modules/tsconfig-paths": {
packages/harness/cortextos/dashboard/package-lock.json:11791:      "resolved": "https://registry.npmjs.org/tsconfig-paths/-/tsconfig-paths-3.15.0.tgz",
packages/harness/cortextos/dashboard/package-lock.json:11802:    "node_modules/tsconfig-paths/node_modules/json5": {
packages/harness/cortextos/src/cli/add-agent.ts:142:    // Create config.json
packages/harness/cortextos/src/cli/add-agent.ts:143:    const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/src/cli/add-agent.ts:144:    if (!existsSync(configPath)) {
packages/harness/cortextos/src/cli/add-agent.ts:145:      writeFileSync(configPath, JSON.stringify({
packages/harness/cortextos/src/cli/add-agent.ts:154:    // Persist non-default runtime into config.json regardless of whether the
packages/harness/cortextos/src/cli/add-agent.ts:156:    // config.json wins file existence, so we read-merge-write to inject the
packages/harness/cortextos/src/cli/add-agent.ts:158:    if (options.runtime !== 'claude-code' && existsSync(configPath)) {
packages/harness/cortextos/src/cli/add-agent.ts:160:        const existingCfg = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/src/cli/add-agent.ts:162:        writeFileSync(configPath, JSON.stringify(existingCfg, null, 2) + '\n', 'utf-8');
packages/harness/cortextos/src/cli/add-agent.ts:164:        console.error(`Warning: failed to set runtime field in config.json: ${(err as Error).message}`);
packages/harness/cortextos/src/cli/add-agent.ts:198:      // Read context.json once and reuse for both SYSTEM.md generation and config seeding.
packages/harness/cortextos/src/cli/add-agent.ts:210:          const dashboardUrl = ctx.dashboard_url || '(not configured)';
packages/harness/cortextos/src/cli/add-agent.ts:248:        // Seed org-level tuning knobs into agent config.json
packages/harness/cortextos/src/cli/add-agent.ts:250:          const agentConfigPath = join(agentDir, 'config.json');
packages/harness/cortextos/src/cli/add-agent.ts:290:    const enabledPath = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/add-agent.ts:291:    const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/src/cli/add-agent.ts:292:    mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/src/cli/add-agent.ts:304:        status: 'configured',
packages/harness/cortextos/src/cli/add-agent.ts:411:  writeFileSync(join(agentDir, 'GOALS.md'), `# Goals\n\n- Awaiting goal configuration\n`);
packages/harness/cortextos/src/cli/add-agent.ts:414:  writeFileSync(join(agentDir, 'USER.md'), `# User Profile\n\nNot configured yet.\n`);
packages/harness/cortextos/src/cli/add-agent.ts:436:9. config.json
packages/harness/cortextos/templates/analyst/.claude/skills/heartbeat/SKILL.md:15:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/src/cli/tunnel.ts:11:const CLOUDFLARED_CONFIG = join(homedir(), '.cloudflared', 'config.yaml');
packages/harness/cortextos/src/cli/tunnel.ts:33:function writeTunnelConfig(instance: string, config: TunnelConfig): void {
packages/harness/cortextos/src/cli/tunnel.ts:34:  const configPath = getTunnelConfigPath(instance);
packages/harness/cortextos/src/cli/tunnel.ts:36:  writeFileSync(configPath, JSON.stringify(config, null, 2) + '\n', 'utf-8');
packages/harness/cortextos/src/cli/tunnel.ts:167:  const config = [
packages/harness/cortextos/src/cli/tunnel.ts:173:  writeFileSync(CLOUDFLARED_CONFIG, config, 'utf-8');
packages/harness/cortextos/src/cli/tunnel.ts:330:    // 4. Write cloudflared config.yaml
packages/harness/cortextos/src/cli/tunnel.ts:368:    // 8. Persist tunnel config
packages/harness/cortextos/src/cli/tunnel.ts:401:    console.log('  (The tunnel config is preserved — run `cortextos tunnel start` to restart)\n');
packages/harness/cortextos/src/cli/tunnel.ts:429:    // Saved config
packages/harness/cortextos/src/cli/tunnel.ts:430:    const config = readTunnelConfig(options.instance);
packages/harness/cortextos/src/cli/tunnel.ts:431:    if (config.tunnelUrl) {
packages/harness/cortextos/src/cli/tunnel.ts:432:      console.log(`  Dashboard URL: ${config.tunnelUrl}`);
packages/harness/cortextos/src/cli/tunnel.ts:437:    if (config.createdAt) {
packages/harness/cortextos/src/cli/tunnel.ts:438:      console.log(`  Tunnel created: ${new Date(config.createdAt).toLocaleString()}`);
packages/harness/cortextos/src/cli/tunnel.ts:448:    const config = readTunnelConfig(options.instance);
packages/harness/cortextos/src/cli/tunnel.ts:449:    if (!config.tunnelUrl) {
packages/harness/cortextos/src/cli/tunnel.ts:453:    process.stdout.write(config.tunnelUrl + '\n');
packages/harness/cortextos/src/cli/import-agent.ts:109:    // Write a clean config.json for the full cortextOS agent
packages/harness/cortextos/src/cli/import-agent.ts:130:    writeFileSync(join(targetAgentDir, 'config.json'), JSON.stringify(fullConfig, null, 2) + '\n', 'utf-8');
packages/harness/cortextos/src/cli/import-agent.ts:157:    const enabledPath = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/import-agent.ts:164:    enabledAgents[agentName] = { enabled: true, status: 'configured', org };
packages/harness/cortextos/src/cli/import-agent.ts:165:    mkdirSync(join(ctxRoot, 'config'), { recursive: true });
packages/harness/cortextos/src/cli/import-agent.ts:215:  const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/src/cli/import-agent.ts:216:  if (!existsSync(configPath)) return null;
packages/harness/cortextos/src/cli/import-agent.ts:217:  try { return JSON.parse(readFileSync(configPath, 'utf-8')); } catch { return null; }
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:7:// We rely on vitest running this file fresh (no prior config.ts cache).
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:11:// Dynamic imports so CTX_ROOT is set before config.ts evaluates
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:39:  const configMod = await import('../config');
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:40:  CTX_ROOT = configMod.CTX_ROOT;
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser-codex.test.ts:35:  const cfgDir = path.join(tmpDir, 'config');
packages/harness/cortextos/src/cli/start.ts:40:      const enabledPath = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/start.ts:75:        const ecosystemPath = join(projectRoot, 'ecosystem.config.js');
packages/harness/cortextos/src/cli/start.ts:79:            execSync('pm2 start ecosystem.config.js', { stdio: 'inherit', cwd: projectRoot });
packages/harness/cortextos/src/cli/start.ts:88:            console.error('PM2 start failed. Try: pm2 start ecosystem.config.js');
packages/harness/cortextos/src/cli/start.ts:91:          console.log('Generating ecosystem.config.js and starting...');
packages/harness/cortextos/src/cli/start.ts:98:            execSync('pm2 start ecosystem.config.js', { stdio: 'inherit', cwd: projectRoot });
packages/harness/cortextos/src/cli/start.ts:108:            console.error('  cortextos ecosystem && pm2 start ecosystem.config.js');
packages/harness/cortextos/src/cli/start.ts:149:      const enabledPath = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/start.ts:162:          status: 'configured',
packages/harness/cortextos/src/cli/start.ts:165:        mkdirSync(join(ctxRoot, 'config'), { recursive: true });
packages/harness/cortextos/src/cli/start.ts:182:          console.log('No agents configured. Add one with: cortextos add-agent <name>');
packages/harness/cortextos/dashboard/src/lib/cost-parser.ts:9:import { CTX_ROOT, getAgentsForOrg, getAllAgents, getOrgs } from '@/lib/config';
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:225:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:240:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:261:1. Install/configure it in the project directory
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:264:4. If failed: fix config, repeat
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:40:| Config | config.json | Extract crons + approval rules |
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:108:- Any autonomy rules the user explicitly configured
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:112:### config.json → extract crons
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:276:| config.json crons | Selectively | Port user-defined schedules, update paths |
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:287:- If the source workspace has custom tools or MCP configs, check with user whether to port them
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser.test.ts:19:  const cfgDir = path.join(tmpDir, 'config');
packages/harness/cortextos/community/skills/local-version-control/SKILL.md:14:- Daily cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/community/skills/local-version-control/SKILL.md:62:Requires `ecosystem.local_version_control.enabled: true` in config.json.
packages/harness/cortextos/templates/analyst/.claude/skills/upstream-sync/SKILL.md:13:- Daily cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/templates/analyst/.claude/skills/upstream-sync/SKILL.md:68:Requires `ecosystem.upstream_sync.enabled: true` in config.json.
packages/harness/cortextos/templates/analyst/.claude/skills/upstream-sync/SKILL.md:74:- NEVER applies during night mode — check day_mode_start/day_mode_end from config.json before proceeding
packages/harness/cortextos/CONTRIBUTING.md:10:| `agent` | A full agent template with identity, config, and skills |
packages/harness/cortextos/CONTRIBUTING.md:86:├── config.json      # Required: model, crons, startup config
packages/harness/cortextos/CONTRIBUTING.md:107:- [ ] For agent templates: all required files present (IDENTITY.md, SOUL.md, GUARDRAILS.md, config.json)
packages/harness/cortextos/scripts/migrate-runtime-field.ts:5: * live agent's `config.json`. Pre-PR-10 the claude default was *implicit*
packages/harness/cortextos/scripts/migrate-runtime-field.ts:7: * humans inspecting config.json had to know the default. PR 10 makes the
packages/harness/cortextos/scripts/migrate-runtime-field.ts:12: *   - Walk orgs/<org>/agents/<agent>/config.json across the workspace
packages/harness/cortextos/scripts/migrate-runtime-field.ts:15: *     right after `enabled` (matching templates/agent-codex/config.json)
packages/harness/cortextos/scripts/migrate-runtime-field.ts:48:  const configs: string[] = [];
packages/harness/cortextos/scripts/migrate-runtime-field.ts:56:      const cfgPath = join(agentsDir, agentEntry.name, 'config.json');
packages/harness/cortextos/scripts/migrate-runtime-field.ts:58:        configs.push(cfgPath);
packages/harness/cortextos/scripts/migrate-runtime-field.ts:62:  return configs.sort();
packages/harness/cortextos/scripts/migrate-runtime-field.ts:67: * with templates/agent-codex/config.json. If `enabled` is missing, the
packages/harness/cortextos/scripts/migrate-runtime-field.ts:131:  const configs = findAgentConfigs(opts.root);
packages/harness/cortextos/scripts/migrate-runtime-field.ts:134:  for (const path of configs) {
packages/harness/cortextos/scripts/migrate-runtime-field.ts:193:  console.log(`Total configs scanned: ${summary.total}`);
packages/harness/cortextos/templates/analyst/.claude/skills/bus-reference/SKILL.md:228:- **chat_id** (required): Telegram chat ID (available in config)
packages/harness/cortextos/scripts/install-windows-pm2-startup.ps1:71:# admin rights / SYSTEM-level service config; Task Scheduler runs under your
packages/harness/cortextos/scripts/self-healing/README.md:24:- A registered Telegram bot for alerts. By default the scripts auto-detect the first enabled orchestrator's bot from `~/.cortextos/<instance>/config/enabled-agents.json`. You can override with `CORTEXTOS_ALERT_BOT_ENV`.
packages/harness/cortextos/scripts/self-healing/agent-recover.sh:50:enabled_json="$HOME/.cortextos/$INSTANCE/config/enabled-agents.json"
packages/harness/cortextos/install.mjs:412:    ok('"upstream" remote configured (tracks canonical cortextOS)');
packages/harness/cortextos/install.mjs:414:    warn('Could not configure upstream remote — run manually: git remote rename origin upstream');
packages/harness/cortextos/templates/analyst/.claude/skills/local-version-control/SKILL.md:13:- Daily cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/templates/analyst/.claude/skills/local-version-control/SKILL.md:61:Requires `ecosystem.local_version_control.enabled: true` in config.json.
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:11:- Daily cron (see `config.json` crons entry `daily-framework-upstream-auto-update`).
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:15:[AGENT_NAME] owns upstream framework health for the cortextos workspace. Bug fix application authority should be documented in your MEMORY.md or deployment config. Feature-level changes always route to [ORCHESTRATOR], who routes to the user for approval.
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:56:- `orgs/` — multi-tenant configuration, never auto-merge
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:127:Add to `config.json` crons:
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:141:- Bug fix application authority belongs to the user and should be granted explicitly in your deployment config or MEMORY.md.
packages/harness/cortextos/src/cli/bus.ts:42:    return null; // cannot read config — allow the transition
packages/harness/cortextos/src/cli/bus.ts:420:  .option('--interval <i>', 'Loop interval from cron config')
packages/harness/cortextos/src/cli/bus.ts:437:            // "## Name" section takes priority (user-configured display name)
packages/harness/cortextos/src/cli/bus.ts:715:    // If approval_required is configured, auto-create an approval
packages/harness/cortextos/src/cli/bus.ts:716:    const config = loadExperimentConfig(agentDir);
packages/harness/cortextos/src/cli/bus.ts:717:    if (config.approval_required) {
packages/harness/cortextos/src/cli/bus.ts:982:      console.error('Error: BOT_TOKEN not configured. Set it in your agent .env file or as an environment variable to enable Telegram.');
packages/harness/cortextos/src/cli/bus.ts:1213:      MMRAG_CONFIG: pjoin(kbRoot, 'config.json'),
packages/harness/cortextos/src/cli/bus.ts:1261:      console.error('Error: BOT_TOKEN not configured. Set it in your agent .env file or as an environment variable to enable Telegram.');
packages/harness/cortextos/src/cli/bus.ts:1300:      console.error('Error: BOT_TOKEN not configured. Set it in your agent .env file or as an environment variable to enable Telegram.');
packages/harness/cortextos/src/cli/bus.ts:1332:    const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/bus.ts:1430:    // Read template from config.json
packages/harness/cortextos/src/cli/bus.ts:1432:    const configFile = join(agentDir, 'config.json');
packages/harness/cortextos/src/cli/bus.ts:1433:    if (existsSync(configFile)) {
packages/harness/cortextos/src/cli/bus.ts:1434:      try { template = JSON.parse(readFileSync(configFile, 'utf-8')).template ?? ''; } catch { /* skip */ }
packages/harness/cortextos/src/cli/bus.ts:1579:    // Read enabled agents from config
packages/harness/cortextos/src/cli/bus.ts:1580:    const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/bus.ts:1786:  .argument('<cron-name>', 'Name of the cron as defined in config.json')
packages/harness/cortextos/src/cli/bus.ts:1936:  .description('List all persistent crons configured for an agent')
packages/harness/cortextos/src/cli/bus.ts:1971:      console.log(`No crons configured for ${agent}`);
packages/harness/cortextos/src/cli/bus.ts:2166:  .description('Migrate crons from config.json to crons.json for one or all agents')
packages/harness/cortextos/src/cli/bus.ts:2182:      // Resolve config.json path via filesystem scan
packages/harness/cortextos/src/cli/bus.ts:2185:      let configPath: string | undefined;
packages/harness/cortextos/src/cli/bus.ts:2189:            const candidate = join(orgsDir, org, 'agents', agentArg, 'config.json');
packages/harness/cortextos/src/cli/bus.ts:2190:            if (fsExists(candidate)) { configPath = candidate; break; }
packages/harness/cortextos/src/cli/bus.ts:2195:      if (!configPath) {
packages/harness/cortextos/src/cli/bus.ts:2200:      const result = migrateSingle(agentArg, configPath, ctxRoot, migOpts);
packages/harness/cortextos/src/cli/bus.ts:2206:        case 'no-config':
packages/harness/cortextos/src/cli/bus.ts:2207:          console.log(`Skipped ${agentArg}: no config.json found`);
packages/harness/cortextos/src/cli/bus.ts:2210:          console.log(`Skipped ${agentArg}: config.json has no crons — empty crons.json written`);
packages/harness/cortextos/src/cli/bus.ts:2225:      const noConfig = summary.results.filter(r => r.status === 'no-config').length;
packages/harness/cortextos/src/cli/bus.ts:2232:      console.log(`  No config.json      : ${noConfig}`);
packages/harness/cortextos/src/cli/bus.ts:2233:      console.log(`  No crons in config  : ${noCrons}`);
packages/harness/cortextos/src/cli/bus.ts:2239:// CronCreate / /loop / config.json cron-registration teaching that predates
packages/harness/cortextos/src/cli/bus.ts:2247:  .description('Scan agent workspace files for stale CronCreate/loop/config.json cron teaching')
packages/harness/cortextos/dashboard/postcss.config.mjs:1:const config = {
packages/harness/cortextos/dashboard/postcss.config.mjs:7:export default config;
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:28:  it('returns null when config.json is missing', () => {
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:32:  it('returns null when config.json is malformed', () => {
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:33:    writeFileSync(join(tmp, 'config.json'), '{ not valid json', 'utf-8');
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:38:    writeFileSync(join(tmp, 'config.json'), JSON.stringify({ agent_name: 'x' }), 'utf-8');
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:42:  it('returns the configured number when present', () => {
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:43:    writeFileSync(join(tmp, 'config.json'), JSON.stringify({ max_crashes_per_day: 10 }), 'utf-8');
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:48:    writeFileSync(join(tmp, 'config.json'), JSON.stringify({ max_crashes_per_day: 'ten' }), 'utf-8');
packages/harness/cortextos/README.md:72:Onboarding handles everything: dependency checks, org setup, bot creation, PM2 config, and dashboard launch. Your Orchestrator comes online in Telegram and finishes its own setup there.
packages/harness/cortextos/README.md:89:cortextos ecosystem                        # Generate PM2 config
packages/harness/cortextos/README.md:90:pm2 start ecosystem.config.js && pm2 save && pm2 startup
packages/harness/cortextos/README.md:131:Every agent's `config.json` carries an explicit `runtime` field that the daemon dispatches on. Valid values:
packages/harness/cortextos/README.md:137:| `hermes` | `HermesPTY` (experimental) | model per `config.json` | hermes-specific |
packages/harness/cortextos/README.md:139:Pass `--runtime <kind>` on `add-agent` to set it at scaffold time, or edit the field in `config.json` and restart the agent. The default is `claude-code`. Today only `--template agent` (and the alias `--template agent-codex`) supports `--runtime codex-app-server` — pairing the codex runtime with `--template orchestrator`/`analyst`/`m2c1-worker`/`hermes` errors with a clean message until codex variants of those templates ship.
packages/harness/cortextos/README.md:150:cortextos ecosystem          # Generate PM2 config
packages/harness/cortextos/community/skills/weekly-review/SKILL.md:12:**When:** Sunday evening (configured in cron) or when user requests.
packages/harness/cortextos/src/cli/restart.ts:8:  .description('Restart a running agent (stop + start). Re-reads config.json and .env, respawns the PTY. Does NOT restart the daemon process itself — use `pm2 restart cortextos-daemon` for that.')
packages/harness/cortextos/src/cli/restart.ts:31:    // Start phase — daemon's start-agent handler re-reads config.json + .env
packages/harness/cortextos/src/cli/restart.ts:33:    // when the daemon is already running, so env reload / config re-read /
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:3:description: "You need to create a new agent, restart a crashed agent, change an agent's model or config, fix a Telegram bot token, troubleshoot why an agent is not responding, enable or disable an agent, spawn an agent for another user, manage PM2 process management, reset crash limits, or do anything that touches an agent's lifecycle, configuration, or credentials. This is the definitive guide for every agent operation in cortextOS."
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:4:triggers: ["new agent", "create agent", "spawn agent", "add agent", "restart", "soft restart", "hard restart", "disable agent", "enable agent", "change model", "switch model", "bot token", "BotFather", "agent not responding", "agent crashed", "agent down", "crash limit", "reset crashes", "agent health", "list agents", "heartbeat", "onboard", "setup agent", "configure agent", ".env", "config.json", "pm2", "ecosystem.config", "cross-org", "agent for someone else", "agent management", "agent lifecycle", "agent credentials", "telegram bot", "token not working"]
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:18:4. **ALWAYS use `cortextos enable` to start agents.** Never manually edit PM2 config.
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:78:# Step 6: Update config.json
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:81:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT_NAME/config.json';
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:189:# Step 1: Update config.json
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:192:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT/config.json';
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:283:Crons are daemon-managed and persisted to `${CTX_ROOT}/state/<agent>/crons.json`. The daemon dispatches them automatically — no agent-side restoration needed. Use the bus commands; do NOT edit `config.json` or use `/loop` / `CronCreate`.
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:391:3. Regenerate ecosystem config: `cortextos ecosystem` then `pm2 restart ecosystem.config.js`
packages/harness/cortextos/templates/analyst/.claude/skills/agent-management/SKILL.md:413:| Change model | Edit config.json model field + soft restart |
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:13:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:20:You cannot autonomously modify your own cycle configuration without direction. For your own theta-wave autoresearch cycle, configuration is managed through theta-wave SKILL.md — you CAN modify your own theta-wave parameters there. If the user asks you to modify a cycle, you can. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:39:- Measure the metric using the configured measurement method
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:60:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:109:1. Never autonomously modify cycle config without direction. Your theta-wave cycle is the exception — manage it via theta-wave SKILL.md.
packages/harness/cortextos/templates/orchestrator/.claude/skills/weekly-review/SKILL.md:11:**When:** Sunday evening (configured in cron) or when user requests.
packages/harness/cortextos/src/cli/setup.ts:9: *   5. Ecosystem config generation + daemon start
packages/harness/cortextos/src/cli/setup.ts:202:  .description('Interactive first-run setup wizard — install, create org, configure agents, start daemon')
packages/harness/cortextos/src/cli/setup.ts:413:    console.log('  Step 5: Generating ecosystem config and starting daemon...\n');
packages/harness/cortextos/src/cli/setup.ts:423:      console.error('  Failed to generate ecosystem config. Run manually: cortextos ecosystem');
packages/harness/cortextos/src/cli/setup.ts:426:      const pm2Result = spawnSync('pm2', ['start', 'ecosystem.config.js'], {
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:13:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:20:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:39:- Measure the metric using the configured measurement method
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:60:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:156:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/templates/agent/TOOLS.md:158:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/src/cli/list-skills.ts:94:    // Template-level skills (detect role from config.json)
packages/harness/cortextos/src/cli/list-skills.ts:97:        const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/src/cli/list-skills.ts:98:        if (existsSync(configPath)) {
packages/harness/cortextos/src/cli/list-skills.ts:99:          const config = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/src/cli/list-skills.ts:100:          const role = config.template || '';
packages/harness/cortextos/src/cli/list-skills.ts:109:        // Ignore config read errors
packages/harness/cortextos/templates/agent/CLAUDE.md:179:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/src/cli/uninstall.ts:10:  .option('--keep-state', 'Remove agent config but preserve state directory (logs, tasks, heartbeats)')
packages/harness/cortextos/src/cli/uninstall.ts:24:      console.log('  Mode: --keep-state (preserving state directory, removing agent config only)\n');
packages/harness/cortextos/src/cli/uninstall.ts:53:      // --keep-state: remove only enabled-agents config, preserve all state data
packages/harness/cortextos/src/cli/uninstall.ts:54:      const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/uninstall.ts:72:    // Remove ecosystem.config.js if exists in current directory
packages/harness/cortextos/src/cli/uninstall.ts:73:    const ecosystemPath = join(process.cwd(), 'ecosystem.config.js');
packages/harness/cortextos/src/cli/uninstall.ts:77:        console.log('  Removed ecosystem.config.js');
packages/harness/cortextos/templates/agent/ONBOARDING.md:14:2. **Confirm identity from system config** - your name is already set (do not re-ask):
packages/harness/cortextos/templates/agent/ONBOARDING.md:15:   > "I'm **{{CTX_AGENT_NAME}}** (set up via cortextos). Let me verify my config is right - can you confirm my role and personality? What's my vibe: formal, casual, technical, creative?"
packages/harness/cortextos/templates/agent/ONBOARDING.md:41:6. **Set working hours** - check org config first, only ask if not already set:
packages/harness/cortextos/templates/agent/ONBOARDING.md:45:   If org config has working hours, use those values. If not set, ask:
packages/harness/cortextos/templates/agent/ONBOARDING.md:58:   **END YOUR TURN.** The user's answer determines your autonomy config.
packages/harness/cortextos/templates/agent/ONBOARDING.md:115:   > We can set these up now if you have credentials ready, or skip for later - just tell me to configure a new tool anytime."
packages/harness/cortextos/templates/agent/ONBOARDING.md:123:   - Store any configuration notes in the agent's memory
packages/harness/cortextos/templates/agent/ONBOARDING.md:184:After workflows and tools are configured:
packages/harness/cortextos/templates/agent/ONBOARDING.md:361:ENABLED=$(cat "${CTX_ROOT}/config/enabled-agents.json" 2>/dev/null || echo '[]')
packages/harness/cortextos/templates/agent/ONBOARDING.md:374:    Signal the orchestrator that this specialist is fully configured and ready:
packages/harness/cortextos/templates/agent/ONBOARDING.md:433:    > You don't need to have one ready now - you can tell me to set up autoresearch anytime. If you do have one in mind, I can configure it now."
packages/harness/cortextos/templates/agent/ONBOARDING.md:473:    If user set approval_required to false, update `experiments/config.json`:
packages/harness/cortextos/templates/agent/ONBOARDING.md:475:    jq '.approval_required = false' "$CTX_AGENT_DIR/experiments/config.json" > /tmp/cfg.tmp && mv /tmp/cfg.tmp "$CTX_AGENT_DIR/experiments/config.json"
packages/harness/cortextos/templates/agent/ONBOARDING.md:479:    > "No problem. You can tell me to set up autoresearch any time. The analyst will also be able to configure experiment cycles for me once they come online."
packages/harness/cortextos/community/skills/agent-management/SKILL.md:3:description: "You need to create a new agent, restart a crashed agent, change an agent's model or config, fix a Telegram bot token, troubleshoot why an agent is not responding, enable or disable an agent, spawn an agent for another user, manage PM2 process management, reset crash limits, or do anything that touches an agent's lifecycle, configuration, or credentials. This is the definitive guide for every agent operation in cortextOS."
packages/harness/cortextos/community/skills/agent-management/SKILL.md:4:triggers: ["new agent", "create agent", "spawn agent", "add agent", "restart", "soft restart", "hard restart", "disable agent", "enable agent", "change model", "switch model", "bot token", "BotFather", "agent not responding", "agent crashed", "agent down", "crash limit", "reset crashes", "agent health", "list agents", "heartbeat", "onboard", "setup agent", "configure agent", ".env", "config.json", "pm2", "ecosystem.config", "cross-org", "agent for someone else", "agent management", "agent lifecycle", "agent credentials", "telegram bot", "token not working"]
packages/harness/cortextos/community/skills/agent-management/SKILL.md:19:4. **ALWAYS use `cortextos enable` to start agents.** Never manually edit PM2 config.
packages/harness/cortextos/community/skills/agent-management/SKILL.md:79:# Step 6: Update config.json
packages/harness/cortextos/community/skills/agent-management/SKILL.md:82:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT_NAME/config.json';
packages/harness/cortextos/community/skills/agent-management/SKILL.md:190:# Step 1: Update config.json
packages/harness/cortextos/community/skills/agent-management/SKILL.md:193:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT/config.json';
packages/harness/cortextos/community/skills/agent-management/SKILL.md:289:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT/config.json';
packages/harness/cortextos/community/skills/agent-management/SKILL.md:305:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT/config.json';
packages/harness/cortextos/community/skills/agent-management/SKILL.md:310:cortextos bus send-message "$AGENT" normal 'Cron removed from config.json. Recreate your crons on next restart.'
packages/harness/cortextos/community/skills/agent-management/SKILL.md:398:3. Regenerate ecosystem config: `cortextos ecosystem` then `pm2 restart ecosystem.config.js`
packages/harness/cortextos/community/skills/agent-management/SKILL.md:420:| Change model | Edit config.json model field + soft restart |
packages/harness/cortextos/community/skills/agent-management/SKILL.md:422:| Add cron | Edit config.json crons + notify agent |
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:371:    const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:372:    mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:374:      join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:393:    const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:394:    mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:396:      join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:414:    const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:415:    mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:417:      join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:451:    const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:452:    mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:454:      join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/delegation-matrix/SKILL.md:10:> Reference when scoping any task. Dividing line: **execution-heavy → Codex (if configured as implementer). Judgment-heavy → Agent always.**
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/delegation-matrix/SKILL.md:12:Codex is a configurable option. Pick the mode that matches your setup:
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/delegation-matrix/SKILL.md:67:For **one-liners and config changes**: Agent writes directly in all modes.
packages/harness/cortextos/community/skills/morning-review/SKILL.md:94:Probe each configured external service BEFORE the briefing. Auth failures discovered here get into the briefing as actionable items — not discovered 3 hours later when the user needs the service.
packages/harness/cortextos/community/skills/morning-review/SKILL.md:123:- **OK or empty results**: note "KB configured"
packages/harness/cortextos/community/skills/morning-review/SKILL.md:124:- **Not configured warning**: note "KB not configured" (informational, not a failure)
packages/harness/cortextos/community/skills/morning-review/SKILL.md:132:Services: GCal OK | Notion OK | KB configured
packages/harness/cortextos/community/skills/morning-review/SKILL.md:136:Services: GCal FAILED (reauth needed — task created) | Notion OK | KB not configured
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:3:description: "You need to create a new agent, restart a crashed agent, change an agent's model or config, fix a Telegram bot token, troubleshoot why an agent is not responding, enable or disable an agent, spawn an agent for another user, manage PM2 process management, reset crash limits, or do anything that touches an agent's lifecycle, configuration, or credentials. This is the definitive guide for every agent operation in cortextOS."
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:4:triggers: ["new agent", "create agent", "spawn agent", "add agent", "restart", "soft restart", "hard restart", "disable agent", "enable agent", "change model", "switch model", "bot token", "BotFather", "agent not responding", "agent crashed", "agent down", "crash limit", "reset crashes", "agent health", "list agents", "heartbeat", "onboard", "setup agent", "configure agent", ".env", "config.json", "pm2", "ecosystem.config", "cross-org", "agent for someone else", "agent management", "agent lifecycle", "agent credentials", "telegram bot", "token not working"]
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:18:4. **ALWAYS use `cortextos enable` to start agents.** Never manually edit PM2 config.
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:89:# Step 6: Update config.json
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:92:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT_NAME/config.json';
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:200:# Step 1: Update config.json
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:203:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT/config.json';
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:294:Crons are daemon-managed and persisted to `${CTX_ROOT}/state/<agent>/crons.json`. The daemon dispatches them automatically — no agent-side restoration needed. Use the bus commands; do NOT edit `config.json` or use `/loop` / `CronCreate`.
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:402:3. Regenerate ecosystem config: `cortextos ecosystem` then `pm2 restart ecosystem.config.js`
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-management/SKILL.md:424:| Change model | Edit config.json model field + soft restart |
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:340:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:361:1. Install/configure it in the project directory
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:364:4. If failed: fix config, repeat
packages/harness/cortextos/tests/unit/daemon/ipc-fleet-health.test.ts:51:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-fleet-health.test.ts:52:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-fleet-health.test.ts:54:    join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:93:Probe each configured external service BEFORE the briefing. Auth failures discovered here get into the briefing as actionable items — not discovered hours later when the user needs the service.
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:122:- **OK or empty results**: note "KB configured"
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:123:- **Not configured warning**: note "KB not configured" (informational, not a failure)
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:131:Services: GCal OK | Notion OK | KB configured
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:135:Services: GCal FAILED (reauth needed — task created) | Notion OK | KB not configured
packages/harness/cortextos/templates/agent/HEARTBEAT.md:141:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/src/cli/install.ts:344:      join(ctxRoot, 'config'),
packages/harness/cortextos/src/cli/install.ts:363:    const enabledPath = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/install.ts:382:    const signingKeyPath = join(ctxRoot, 'config', 'bus-signing-key');
packages/harness/cortextos/src/cli/install.ts:447:    console.log('    3. cortextos ecosystem && pm2 start ecosystem.config.js');
packages/harness/cortextos/vitest.config.ts:1:import { defineConfig } from 'vitest/config';
packages/harness/cortextos/vitest.config.ts:7:      // Matches the dashboard's tsconfig path alias so tests under
packages/harness/cortextos/dashboard/src/components/analytics/cost-tracking.tsx:92:              <p className="text-sm font-medium">Plan usage tracking not configured</p>
packages/harness/cortextos/skills/cron-management/SKILL.md:116:## Migration from config.json (legacy)
packages/harness/cortextos/skills/cron-management/SKILL.md:119:`config.json`. The daemon auto-migrates them to `crons.json` on first boot.
packages/harness/cortextos/templates/agent/.claude/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/templates/agent/.claude/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/templates/agent/.claude/skills/onboarding/SKILL.md:45:| Crons configured and running | `config.json` |
packages/harness/cortextos/templates/agent/.claude/skills/onboarding/SKILL.md:49:| Autoresearch cycle offered | `experiments/config.json` (optional) |
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:14:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:21:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:40:- Measure the metric using the configured measurement method
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:61:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:137:# Update approval setting in config if needed (default is true)
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:157:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:58:    mkdirSync(join(ctxRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:70:      join(ctxRoot, 'config', 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:98:    writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), '{}');
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:108:  it('still respects per-agent config.json enabled: false (existing behavior)', async () => {
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:109:    // Per-agent config.json takes precedence — this is the legacy behavior we
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:112:      join(frameworkRoot, 'orgs', 'acme', 'agents', 'alice', 'config.json'),
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:128:      join(ctxRoot, 'config', 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:151:    mkdirSync(join(ctxRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:203:      join(ctxRoot, 'config', 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:244:    mkdirSync(join(ctxRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:376:    mkdirSync(join(ctxRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:397:    const fakeProcess = { config: { runtime: undefined } } as any;
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:415:    const fakeProcess = { config: { runtime: 'hermes' } } as any;
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:426:    const fakeProcess = { config: { runtime: undefined } } as any;
packages/harness/cortextos/community/agents/orchestrator/TOOLS.md:144:- Or use Playwright MCP if configured
packages/harness/cortextos/community/agents/orchestrator/TOOLS.md:154:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/bus/kb-query.sh:109:export MMRAG_CONFIG="$KB_ROOT/config.json"
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:66:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:67:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:68:  writeFileSync(join(configDir, 'enabled-agents.json'), JSON.stringify(agents, null, 2));
packages/harness/cortextos/src/cli/init.ts:157:              `**Dashboard:** ${ctx.dashboard_url || '(not configured)'}`,
packages/harness/cortextos/dashboard/src/components/analytics/goal-progress.tsx:30:            No goals configured. Visit Strategy to set goals.
packages/harness/cortextos/community/agents/security/TOOLS.md:31:| `cortextos bus list-agents --format json` | Audit running agent configurations |
packages/harness/cortextos/community/agents/orchestrator/CLAUDE.md:214:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:28:The Obsidian CLI writes directly to vault notes. Replace `[VAULT_NAME]` with your configured vault name.
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:121:You can also add a daily cron entry to `config.json` to keep the KB automatically current:
packages/harness/cortextos/src/cli/ecosystem.ts:10:  .option('--output <path>', 'Output file', 'ecosystem.config.js')
packages/harness/cortextos/src/cli/ecosystem.ts:11:  .description('Generate PM2 ecosystem.config.js from agent configs')
packages/harness/cortextos/src/cli/ecosystem.ts:68:    // BUG-002 fix: emit ecosystem.config.js as raw JS that resolves
packages/harness/cortextos/src/cli/ecosystem.ts:114:      // Dashboard reads its real config from dashboard/.env.local — populated
packages/harness/cortextos/templates/agent/.claude/skills/worker-agents/SKILL.md:37:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/community/agents/security/CLAUDE.md:182:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:11:The system onboarding already collected the essential org configuration. Read it - don't ask the user to repeat it.
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:113:**END YOUR TURN HERE.** Do not call any more tools or produce any more output. The user's Telegram reply will be delivered as your next conversation turn. When you receive it, write their answer to config.json (update the check-approvals cron interval if they want a different frequency), then continue from Step 8.
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:256:No configuration needed here - theta-wave is triggered by the analyst.
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:268:> You don't need to set one up now - you can tell me to configure autoresearch anytime. Want to set up a cycle now?"
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:286:> "No problem. You can tell me to configure autoresearch anytime, or the analyst will set it up when they come online."
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:374:> "All set. Here's what I'm configured to do:
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:514:ENABLED_FILE="$CTX_ROOT/config/enabled-agents.json"
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:518:    '. + {($name): {"enabled": true, "status": "configured", "org": $org}}' \
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:531:> "Your analyst agent is spinning up now. Switch to your Telegram chat with [analyst_bot_name] and send `/onboarding` to complete its setup. It will configure itself, connect to the org, and check in with me when ready.
packages/harness/cortextos/src/cli/doctor.ts:233:      } catch { /* no config yet */ }
packages/harness/cortextos/src/cli/doctor.ts:265:          message: 'Not configured',
packages/harness/cortextos/community/agents/security/HEARTBEAT.md:135:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/community/agents/security/ONBOARDING.md:14:2. **Confirm identity from system config** - your name is already set (do not re-ask):
packages/harness/cortextos/community/agents/security/ONBOARDING.md:15:   > "I'm **{{CTX_AGENT_NAME}}** (set up via cortextos). Let me verify my config is right - can you confirm my role and personality? What's my vibe: formal, casual, technical, creative?"
packages/harness/cortextos/community/agents/security/ONBOARDING.md:41:6. **Set working hours** - check org config first, only ask if not already set:
packages/harness/cortextos/community/agents/security/ONBOARDING.md:45:   If org config has working hours, use those values. If not set, ask:
packages/harness/cortextos/community/agents/security/ONBOARDING.md:58:   **END YOUR TURN.** The user's answer determines your autonomy config.
packages/harness/cortextos/community/agents/security/ONBOARDING.md:108:   > We can set these up now if you have credentials ready, or skip for later - just tell me to configure a new tool anytime."
packages/harness/cortextos/community/agents/security/ONBOARDING.md:116:   - Store any configuration notes in the agent's memory
packages/harness/cortextos/community/agents/security/ONBOARDING.md:177:After workflows and tools are configured:
packages/harness/cortextos/community/agents/security/ONBOARDING.md:182:    If the user wants a different heartbeat interval, update `config.json` crons array (heartbeat entry interval).
packages/harness/cortextos/community/agents/security/ONBOARDING.md:350:ENABLED=$(cat "${CTX_ROOT}/config/enabled-agents.json" 2>/dev/null || echo '[]')
packages/harness/cortextos/community/agents/security/ONBOARDING.md:363:    Signal the orchestrator that this specialist is fully configured and ready:
packages/harness/cortextos/community/agents/security/ONBOARDING.md:422:    > You don't need to have one ready now - you can tell me to set up autoresearch anytime. If you do have one in mind, I can configure it now."
packages/harness/cortextos/community/agents/security/ONBOARDING.md:462:    If user set approval_required to false, update `experiments/config.json`:
packages/harness/cortextos/community/agents/security/ONBOARDING.md:464:    jq '.approval_required = false' "$CTX_AGENT_DIR/experiments/config.json" > /tmp/cfg.tmp && mv /tmp/cfg.tmp "$CTX_AGENT_DIR/experiments/config.json"
packages/harness/cortextos/community/agents/security/ONBOARDING.md:468:    > "No problem. You can tell me to set up autoresearch any time. The analyst will also be able to configure experiment cycles for me once they come online."
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:253:describe('AgentProcess - BUG-048 fix (session timer re-reads config)', () => {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:254:  it('fires sessionRefresh when config on disk still matches original short duration', async () => {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:270:  it('reschedules when config.json on disk has a longer max_session_seconds', async () => {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:279:      typeof p === 'string' && p.endsWith('config.json'),
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:282:      if (typeof p === 'string' && p.endsWith('config.json')) {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:301:    // sessionRefresh must NOT have been called — config said 1h, not 1s
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:318:      typeof p === 'string' && p.endsWith('config.json'),
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:321:      if (typeof p === 'string' && p.endsWith('config.json')) {
packages/harness/cortextos/templates/agent/.claude/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
packages/harness/cortextos/templates/agent/.claude/skills/env-management/SKILL.md:4:triggers: ["add key", "api key", "env file", ".env", "secret", "credential", "token", "environment variable", "configure key", "set key", "missing key", "key not set", "where do I put", "shared secret", "org secret", "agent secret", "key not loading", "configure credentials", "new api key", "add to env", "rotate key", "rotate token", "key compromised", "token expired", "update api key", "new bot token", "revoke key", "credential rotation", "key rotation", "secret rotation", "key was leaked", "compromised credential", "force rotation", "provider rotated", "expired key", "rotate credentials", "update secret"]
packages/harness/cortextos/community/agents/orchestrator/HEARTBEAT.md:166:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:5: * `/loop` and to edit `config.json` for cron registration.  After that
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:96:    name: '(configured in config.json)',
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:97:    match: (line) => /\(configured in config\.json\)/.test(line),
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:99:      "Replace with '(configured via cortextos bus add-cron)'. config.json is no longer the cron source of truth.",
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:102:    name: 'edit config.json (cron context)',
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:104:      /\bconfig\.json\b/.test(line) &&
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:108:      "config.json no longer holds crons. Use 'cortextos bus add-cron' (the daemon owns crons.json directly).",
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:136:    from: /\(configured in config\.json\)/g,
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:137:    to: '(configured via cortextos bus add-cron)',
packages/harness/cortextos/templates/agent/.claude/skills/knowledge-base/SKILL.md:66:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
packages/harness/cortextos/templates/agent/.claude/skills/heartbeat/SKILL.md:15:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:340:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:361:1. Install/configure it in the project directory
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:364:4. If failed: fix config, repeat
packages/harness/cortextos/src/cli/get-config.ts:5:export const getConfigCommand = new Command('get-config')
packages/harness/cortextos/src/cli/get-config.ts:6:  .description('Show resolved operational config for an agent (org defaults + agent overrides)')
packages/harness/cortextos/src/cli/get-config.ts:33:      const agentCfgPath = join(frameworkRoot, 'orgs', org, 'agents', agentName, 'config.json');
packages/harness/cortextos/src/cli/get-config.ts:37:        // --agent was explicitly passed but no config found — warn, don't exit
packages/harness/cortextos/src/cli/get-config.ts:38:        process.stderr.write(`Warning: agent config not found at ${agentCfgPath}, showing org defaults only\n`);
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:68:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:69:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:70:  writeFileSync(join(configDir, 'enabled-agents.json'), JSON.stringify(agents, null, 2));
packages/harness/cortextos/src/utils/org.ts:15: * MMRAG config.json that then haunted dashboard sync forever.
packages/harness/cortextos/templates/agent/.claude/skills/bus-reference/SKILL.md:228:- **chat_id** (required): Telegram chat ID (available in config)
packages/harness/cortextos/community/agents/security/.claude/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/community/agents/security/.claude/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/community/agents/security/.claude/skills/onboarding/SKILL.md:45:| Crons configured and running | `config.json` |
packages/harness/cortextos/community/agents/security/.claude/skills/onboarding/SKILL.md:49:| Autoresearch cycle offered | `experiments/config.json` (optional) |
packages/harness/cortextos/community/agents/analyst/TOOLS.md:144:- Or use Playwright MCP if configured
packages/harness/cortextos/community/agents/analyst/TOOLS.md:154:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:134:If `ecosystem.local_version_control.enabled` is true in your config.json, run the daily snapshot at the configured time:
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:154:If `ecosystem.upstream_sync.enabled` is true in your config.json, check for framework updates on your configured schedule:
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:181:If `ecosystem.catalog_browse.enabled` is true in your config.json, scan the catalog on your configured schedule:
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:195:If `ecosystem.community_publish.enabled` is true in your config.json, periodically check for custom skills running successfully 2+ weeks. If user agrees to share:
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:224:   > "Your new agent is booting up! Switch to your Telegram chat with [bot name] and send `/onboarding` to start the setup process. The agent will walk you through configuring its identity, goals, and workflows."
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:260:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/src/utils/allowed-roots.ts:6: * Allowed-roots config layer for the deliverables system.
packages/harness/cortextos/src/utils/allowed-roots.ts:8: * The config file at {ctxRoot}/config/allowed-roots.json lists ADDITIONAL
packages/harness/cortextos/src/utils/allowed-roots.ts:24:  config?: AllowedRootsFile;
packages/harness/cortextos/src/utils/allowed-roots.ts:30:  config?: AllowedRootsFile;
packages/harness/cortextos/src/utils/allowed-roots.ts:58: * Read the allowed-roots config from disk. Returns an empty config if the
packages/harness/cortextos/src/utils/allowed-roots.ts:61:export function readAllowedRoots(configPath: string): AllowedRootsFile {
packages/harness/cortextos/src/utils/allowed-roots.ts:63:  if (!existsSync(configPath)) return empty;
packages/harness/cortextos/src/utils/allowed-roots.ts:65:    const parsed = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/src/utils/allowed-roots.ts:82:  configPath: string,
packages/harness/cortextos/src/utils/allowed-roots.ts:107:  const current = readAllowedRoots(configPath);
packages/harness/cortextos/src/utils/allowed-roots.ts:116:  ensureConfigDir(configPath);
packages/harness/cortextos/src/utils/allowed-roots.ts:117:  atomicWriteSync(configPath, JSON.stringify(updated, null, 2));
packages/harness/cortextos/src/utils/allowed-roots.ts:119:  return { success: true, config: updated };
packages/harness/cortextos/src/utils/allowed-roots.ts:126:  configPath: string,
packages/harness/cortextos/src/utils/allowed-roots.ts:130:  const current = readAllowedRoots(configPath);
packages/harness/cortextos/src/utils/allowed-roots.ts:135:  ensureConfigDir(configPath);
packages/harness/cortextos/src/utils/allowed-roots.ts:136:  atomicWriteSync(configPath, JSON.stringify(updated, null, 2));
packages/harness/cortextos/src/utils/allowed-roots.ts:138:  return { success: true, config: updated };
packages/harness/cortextos/src/utils/allowed-roots.ts:146:  configPath: string,
packages/harness/cortextos/src/utils/allowed-roots.ts:148:  const config = readAllowedRoots(configPath);
packages/harness/cortextos/src/utils/allowed-roots.ts:151:    ...config.additional_roots,
packages/harness/cortextos/src/utils/allowed-roots.ts:192:function ensureConfigDir(configPath: string): void {
packages/harness/cortextos/src/utils/allowed-roots.ts:193:  const dir = dirname(configPath);
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:70:  it('flags "(configured in config.json)"', () => {
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:71:    const fp = write('cfg.md', 'Heartbeat cron (configured in config.json) fires every 4h.\n');
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:73:    expect(r.matches.some((m) => m.pattern === '(configured in config.json)')).toBe(true);
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:76:  it('flags "edit config.json … cron" combined context', () => {
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:78:      'To add a new cron, edit config.json and add an entry to the crons array.\n');
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:80:    expect(r.matches.some((m) => m.pattern === 'edit config.json (cron context)')).toBe(true);
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:103:  it('rewrites "(configured in config.json)" in place when apply=true', () => {
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:105:      'Heartbeat cron (configured in config.json) fires every 4h.\nReports cron (configured in config.json).\n');
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:109:    expect(out).not.toContain('(configured in config.json)');
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:110:    expect(out).toContain('(configured via cortextos bus add-cron)');
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:114:    const original = 'Heartbeat (configured in config.json).\n';
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:162:    write('AGENTS.md', 'Heartbeat (configured in config.json).\n');
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:179:      '(configured in config.json)',
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:185:      'Heartbeat (configured in config.json).\nUse CronCreate to register.\n');
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:190:    expect(out).toContain('(configured via cortextos bus add-cron)');
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:202:    const fpB = write('AGENTS.md', '(configured in config.json)\n');
packages/harness/cortextos/community/agents/agent/TOOLS.md:144:- Or use Playwright MCP if configured
packages/harness/cortextos/community/agents/agent/TOOLS.md:154:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:13:> **Note:** Your operational config (day/night hours, approval categories, communication style)
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:44:**END YOUR TURN.** The user's answer determines your autonomy config - you need it before continuing.
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:119:**END YOUR TURN.** You need their thresholds and reporting preferences before writing config.
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:121:When you receive their response, write collected thresholds and reporting preferences to `${CTX_AGENT_DIR}/experiments/config.json` under a `monitoring` key:
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:124:ANALYST_EXP="${CTX_AGENT_DIR}/experiments/config.json"
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:149:> "I've set up my heartbeat cycle with default thresholds - goals flagged after 7 days without update, tasks after 3 days. Guardrail self-check enabled. You can tune these anytime by telling me to update my config."
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:173:First, read day/night mode config from org context so crons fire at the right times:
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:196:The default config also includes a `nightly-metrics` cron (24h) that runs `cortextos bus collect-metrics`. Verify it exists: `cortextos bus list-crons $CTX_AGENT_NAME`.
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:211:> We can set these up now if you have credentials ready, or I can come back to it later - just tell me to configure a new tool anytime."
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:219:- Store configuration in memory
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:390:**END YOUR TURN.** You need their ecosystem preferences before writing config.
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:392:### Step 21: Write ecosystem config to config.json
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:400:}' '.ecosystem = $eco' "${CTX_AGENT_DIR}/config.json" > "${CTX_AGENT_DIR}/config.json.tmp" && \
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:401:  mv "${CTX_AGENT_DIR}/config.json.tmp" "${CTX_AGENT_DIR}/config.json"
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:419:For each enabled feature, register the cron via `cortextos bus add-cron`. The daemon persists it to `crons.json` and dispatches automatically — do not edit config.json directly.
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:451:**END YOUR TURN.** You need their theta wave preferences before writing config.
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:453:### Step 25: Merge theta wave config
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:455:Merge into `${CTX_AGENT_DIR}/experiments/config.json` (preserve existing monitoring config from Part 2):
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:458:ANALYST_EXP="${CTX_AGENT_DIR}/experiments/config.json"
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:478:After writing theta wave config, notify the orchestrator:
packages/harness/cortextos/community/agents/analyst/ONBOARDING.md:483:  cortextos bus send-message "${ORCH_NAME}" normal "Theta wave configured: enabled=true, interval=<interval>, approval_required=<val>, auto_create=<val>, auto_modify=<val>"
packages/harness/cortextos/community/agents/security/.claude/skills/guardrails-reference/SKILL.md:31:| Creating a one-shot reminder or cron | "CronCreate is enough, it'll persist" | CronCreate is session-only. Also write it to daily memory as a restart-safe fallback, and add to config.json when the format supports it. |
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:3:description: "You need to create a new agent, restart a crashed agent, change an agent's model or config, fix a Telegram bot token, troubleshoot why an agent is not responding, enable or disable an agent, spawn an agent for another user, manage PM2 process management, reset crash limits, or do anything that touches an agent's lifecycle, configuration, or credentials. This is the definitive guide for every agent operation in cortextOS."
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:4:triggers: ["new agent", "create agent", "spawn agent", "add agent", "restart", "soft restart", "hard restart", "disable agent", "enable agent", "change model", "switch model", "bot token", "BotFather", "agent not responding", "agent crashed", "agent down", "crash limit", "reset crashes", "agent health", "list agents", "heartbeat", "onboard", "setup agent", "configure agent", ".env", "config.json", "pm2", "ecosystem.config", "cross-org", "agent for someone else", "agent management", "agent lifecycle", "agent credentials", "telegram bot", "token not working"]
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:18:4. **ALWAYS use `cortextos enable` to start agents.** Never manually edit PM2 config.
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:78:# Step 6: Update config.json
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:81:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT_NAME/config.json';
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:189:# Step 1: Update config.json
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:192:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT/config.json';
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:283:Crons are daemon-managed and persisted to `${CTX_ROOT}/state/<agent>/crons.json`. The daemon dispatches them automatically — no agent-side restoration needed. Use the bus commands; do NOT edit `config.json` or use `/loop` / `CronCreate`.
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:391:3. Regenerate ecosystem config: `cortextos ecosystem` then `pm2 restart ecosystem.config.js`
packages/harness/cortextos/templates/agent/.claude/skills/agent-management/SKILL.md:413:| Change model | Edit config.json model field + soft restart |
packages/harness/cortextos/src/utils/paths.ts:12: *     config/                - enabled-agents.json
packages/harness/cortextos/community/agents/agent/CLAUDE.md:182:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:20:let configPath: string;
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:33:  configPath = join(ctxRoot, 'config', 'allowed-roots.json');
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:46:    expect(readAllowedRoots(configPath)).toEqual({ additional_roots: [] });
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:50:    mkdirSync(join(ctxRoot, 'config'));
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:51:    writeFileSync(configPath, '{not json');
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:52:    expect(readAllowedRoots(configPath)).toEqual({ additional_roots: [] });
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:56:    mkdirSync(join(ctxRoot, 'config'));
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:58:      configPath,
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:61:    const out = readAllowedRoots(configPath);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:68:    expect(addAllowedRoot(configPath, '').success).toBe(false);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:69:    expect(addAllowedRoot(configPath, '   ').success).toBe(false);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:73:    const r = addAllowedRoot(configPath, '../../../etc');
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:80:      const r = addAllowedRoot(configPath, blocked);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:90:    const r = addAllowedRoot(configPath, join(tmpRoot, 'does-not-exist'));
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:95:    expect(addAllowedRoot(configPath, allowedExtra).success).toBe(true);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:96:    const r = addAllowedRoot(configPath, allowedExtra);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:102:    const r = addAllowedRoot(configPath, allowedExtra);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:104:    expect(existsSync(configPath)).toBe(true);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:105:    const re = readAllowedRoots(configPath);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:112:    addAllowedRoot(configPath, allowedExtra);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:113:    const r = removeAllowedRoot(configPath, allowedExtra);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:115:    expect(readAllowedRoots(configPath).additional_roots).not.toContain(
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:121:    const r = removeAllowedRoot(configPath, allowedExtra);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:161:  it('always includes CTX_ROOT even when config file missing', () => {
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:162:    const roots = computeValidRoots(ctxRoot, configPath);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:167:    addAllowedRoot(configPath, ctxRoot);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:168:    const roots = computeValidRoots(ctxRoot, configPath);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:174:    addAllowedRoot(configPath, allowedExtra);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:175:    const roots = computeValidRoots(ctxRoot, configPath);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:186:    addAllowedRoot(configPath, allowedExtra);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:189:    const roots = computeValidRoots(ctxRoot, configPath).map(r => r.replace(/\\/g, '/'));
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:198:    addAllowedRoot(configPath, allowedExtra);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:199:    const roots = computeValidRoots(ctxRoot, configPath).map(r => r.replace(/\\/g, '/'));
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:205:    addAllowedRoot(configPath, allowedExtra);
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:209:    const roots = computeValidRoots(ctxRoot, configPath).map(r => r.replace(/\\/g, '/'));
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:230:    const roots = computeValidRoots(ctxRoot, configPath).map(r => r.replace(/\\/g, '/'));
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:242:    const r = addAllowedRoot(configPath, '/tmp/evil\0/../etc');
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:248:    const r = addAllowedRoot(configPath, longPath);
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:13:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:20:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:39:- Measure the metric using the configured measurement method
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:60:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:136:# Update approval setting in config if needed (default is true)
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:156:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:14:2. **Confirm identity from system config** - your name is already set (do not re-ask):
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:15:   > "I'm **{{CTX_AGENT_NAME}}** (set up via cortextos). Let me verify my config is right - can you confirm my role and personality? What's my vibe: formal, casual, technical, creative?"
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:41:6. **Set working hours** - check org config first, only ask if not already set:
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:45:   If org config has working hours, use those values. If not set, ask:
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:58:   **END YOUR TURN.** The user's answer determines your autonomy config.
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:108:   > We can set these up now if you have credentials ready, or skip for later - just tell me to configure a new tool anytime."
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:116:   - Store any configuration notes in the agent's memory
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:148:After workflows and tools are configured:
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:151:    > "One quick config question. How long before a task with no updates gets flagged as stale? (default: 3 days - keeps the dashboard clean)"
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:287:    Signal the orchestrator that this specialist is fully configured and ready:
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:346:    > You don't need to have one ready now - you can tell me to set up autoresearch anytime. If you do have one in mind, I can configure it now."
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:386:    If user set approval_required to false, update `experiments/config.json`:
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:388:    jq '.approval_required = false' "$CTX_AGENT_DIR/experiments/config.json" > /tmp/cfg.tmp && mv /tmp/cfg.tmp "$CTX_AGENT_DIR/experiments/config.json"
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:392:    > "No problem. You can tell me to set up autoresearch any time. The analyst will also be able to configure experiment cycles for me once they come online."
packages/harness/cortextos/templates/agent-codex/TOOLS.md:182:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/community/agents/agent/HEARTBEAT.md:135:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:15: * + model defaults in config.json.
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:90:                     'config.json', 'goals.json']) {
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:98:  it('writes runtime=codex-app-server and model=gpt-5-codex into config.json', async () => {
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:107:    const cfgPath = join(tempRoot, 'orgs', 'testorg', 'agents', 'codex-cfg', 'config.json');
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:208:    // PR 10: claude-code is now an EXPLICIT field in templates/agent/config.json
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:211:    const cfg = JSON.parse(readFileSync(join(agentDir, 'config.json'), 'utf-8'));
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:220: * agent: codex runtime in config but claude-only bootstrap files
packages/harness/cortextos/community/agents/agentic-crm-assistant/GOALS.md:13:5. Never send external communications, spend money, delete data, or make irreversible changes without approval unless explicitly configured.
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:16:2. **Confirm identity from system config** — your name is already set (do not re-ask):
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:17:   > "I'm **{{CTX_AGENT_NAME}}** (set up via cortextos). Let me verify my config is right — can you confirm my role and personality? What's my vibe: formal, casual, technical, creative?"
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:43:6. **Set working hours** — check org config first, only ask if not already set:
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:47:   If org config has working hours, use those values. If not set, ask:
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:60:   **END YOUR TURN.** The user's answer determines your autonomy config.
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:117:   > We can set these up now if you have credentials ready, or skip for later — just tell me to configure a new tool anytime."
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:125:   - Store any configuration notes in the agent's memory
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:186:After workflows and tools are configured:
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:363:ENABLED=$(cat "${CTX_ROOT}/config/enabled-agents.json" 2>/dev/null || echo '[]')
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:376:    Signal the orchestrator that this specialist is fully configured and ready:
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:433:    > You don't need to have one ready now — you can tell me to set up autoresearch anytime. If you do have one in mind, I can configure it now."
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:470:    If user set approval_required to false, update `experiments/config.json`:
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:472:    jq '.approval_required = false' "$CTX_AGENT_DIR/experiments/config.json" > /tmp/cfg.tmp && mv /tmp/cfg.tmp "$CTX_AGENT_DIR/experiments/config.json"
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:476:    > "No problem. You can tell me to set up autoresearch any time. The analyst will also be able to configure experiment cycles for me once they come online."
packages/harness/cortextos/tests/unit/bus/system.test.ts:38:      selfRestart(paths, 'test-agent', 'config reload needed');
packages/harness/cortextos/tests/unit/bus/system.test.ts:44:      expect(markerContent).toBe('config reload needed');
packages/harness/cortextos/tests/unit/bus/system.test.ts:50:      expect(logContent).toContain('SELF-RESTART: config reload needed');
packages/harness/cortextos/tests/unit/bus/system.test.ts:89:      execSync('git config user.email "test@test.com"', { cwd: gitDir, stdio: 'pipe' });
packages/harness/cortextos/tests/unit/bus/system.test.ts:90:      execSync('git config user.name "Test"', { cwd: gitDir, stdio: 'pipe' });
packages/harness/cortextos/tests/unit/bus/system.test.ts:111:      writeFileSync(join(gitDir, 'config.json'), '{"token=abc123"}');
packages/harness/cortextos/tests/unit/bus/system.test.ts:115:      expect(report.blocked.some(b => b.includes('config.json') && b.includes('credential'))).toBe(true);
packages/harness/cortextos/tests/unit/bus/system.test.ts:261:    it('returns false when not configured', async () => {
packages/harness/cortextos/src/bus/catalog.ts:522:          error: 'no upstream remote configured',
packages/harness/cortextos/src/bus/catalog.ts:533:          error: 'no origin remote configured',
packages/harness/cortextos/src/bus/metrics.ts:104:  const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/bus/metrics.ts:336:    return { status: 'error', error: 'no upstream remote configured', hint: 'Run: git remote add upstream <canonical-repo-url>' };
packages/harness/cortextos/src/bus/system.ts:379: * Returns false if not configured (silent fail — callers can ignore the
packages/harness/cortextos/src/bus/system.ts:403:  let configPath: string | null = null;
packages/harness/cortextos/src/bus/system.ts:406:      configPath = candidate;
packages/harness/cortextos/src/bus/system.ts:411:  if (!configPath) {
packages/harness/cortextos/src/bus/system.ts:420:    const content = readFileSync(configPath, 'utf-8');
packages/harness/cortextos/templates/agent-codex/HEARTBEAT.md:141:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/tests/unit/bus/approval.test.ts:146:  it('REGRESSION GUARD: warns when postActivity returns false (not-configured signal)', async () => {
packages/harness/cortextos/tests/unit/bus/approval.test.ts:313:    // expected steady state, not a misconfiguration.
packages/harness/cortextos/src/bus/knowledge-base.ts:53: * Check whether the knowledge base config file exists for a given env.
packages/harness/cortextos/src/bus/knowledge-base.ts:55: * The Python MMRAG tool loads its config from env.MMRAG_CONFIG
packages/harness/cortextos/src/bus/knowledge-base.ts:56: * (`knowledge-base/config.json` under the org's state dir) and exits with
packages/harness/cortextos/src/bus/knowledge-base.ts:61: * missing-config state UP FRONT and respond gracefully (warn + return)
packages/harness/cortextos/src/bus/knowledge-base.ts:80:  // MMRAG config.json, splitting KB state across two directories and
packages/harness/cortextos/src/bus/knowledge-base.ts:94:    MMRAG_CONFIG: join(kbRoot, 'config.json'),
packages/harness/cortextos/src/bus/knowledge-base.ts:141:  // UX safety net: if the KB is not configured for this org (no config.json
packages/harness/cortextos/src/bus/knowledge-base.ts:146:  // empty query against a configured KB. The warn-and-empty shape makes the
packages/harness/cortextos/src/bus/knowledge-base.ts:150:      `[kb] Knowledge base not configured for org ${org}. Returning empty results — run setup to enable.`,
packages/harness/cortextos/src/bus/knowledge-base.ts:261:  // Correctness fix: if the KB is not configured for this org, the underlying
packages/harness/cortextos/src/bus/knowledge-base.ts:267:  // without setting up the KB first. Detect the missing-config state
packages/harness/cortextos/src/bus/knowledge-base.ts:271:      `[kb] Knowledge base not configured for org ${org}. Skipping ingest — ` +
packages/harness/cortextos/src/bus/knowledge-base.ts:272:      `run setup to enable (see HEARTBEAT.md step 10 for the config path).`,
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/onboarding/SKILL.md:44:| Crons configured and running | `config.json` |
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/onboarding/SKILL.md:48:| Autoresearch cycle offered | `experiments/config.json` (optional) |
packages/harness/cortextos/src/bus/message.ts:16: * Load the shared bus signing key from config.
packages/harness/cortextos/src/bus/message.ts:20:  const keyPath = join(ctxRoot, 'config', 'bus-signing-key');
packages/harness/cortextos/community/agents/agentic-crm-assistant/SOUL.md:38:**Night Mode:** quiet autonomous work. Triage, prepare, organize, draft, and queue items. Do not ping unless urgent under the user's configured rules.
packages/harness/cortextos/src/bus/agents.ts:28:  const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/bus/agents.ts:48:  // do not scan cwd — the caller explicitly configured a root that has no agents.
packages/harness/cortextos/src/bus/agents.ts:114: * Build an AgentInfo object by reading heartbeat, IDENTITY.md, and config.
packages/harness/cortextos/src/bus/agents.ts:160:          // Parse "## Name" — user-configured display name (e.g. "Alpha", "Beta")
packages/harness/cortextos/src/bus/agents.ts:201:  // Read config.json for model info
packages/harness/cortextos/src/bus/agents.ts:202:  const configFrameworkRoot = process.env.CTX_FRAMEWORK_ROOT || process.env.CTX_PROJECT_ROOT || '';
packages/harness/cortextos/src/bus/agents.ts:203:  if (configFrameworkRoot) {
packages/harness/cortextos/src/bus/agents.ts:204:    const configPaths = [
packages/harness/cortextos/src/bus/agents.ts:205:      join(configFrameworkRoot, 'orgs', org, 'agents', name, 'config.json'),
packages/harness/cortextos/src/bus/agents.ts:206:      join(configFrameworkRoot, 'agents', name, 'config.json'),
packages/harness/cortextos/src/bus/agents.ts:208:    for (const cfgPath of configPaths) {
packages/harness/cortextos/src/bus/experiment.ts:125:  const configPath = join(agentDir, 'experiments', 'config.json');
packages/harness/cortextos/src/bus/experiment.ts:126:  if (!existsSync(configPath)) {
packages/harness/cortextos/src/bus/experiment.ts:129:  return JSON.parse(readFileSync(configPath, 'utf-8').trim());
packages/harness/cortextos/src/bus/experiment.ts:132:function saveConfig(agentDir: string, config: ExperimentConfig): void {
packages/harness/cortextos/src/bus/experiment.ts:135:  atomicWriteSync(join(dir, 'config.json'), JSON.stringify(config, null, 2));
packages/harness/cortextos/src/bus/experiment.ts:144: * `experiments/config.json` (same metric + same agent) before using the
packages/harness/cortextos/src/bus/experiment.ts:146: * direction, window, and surface once in the cycle config; with the cycle
packages/harness/cortextos/src/bus/experiment.ts:194: * is configured — createExperiment then falls through to its static
packages/harness/cortextos/src/bus/experiment.ts:195: * defaults. Best-effort: any config-read error returns empty so the
packages/harness/cortextos/src/bus/experiment.ts:196: * experiment create path never breaks on malformed config.
packages/harness/cortextos/src/bus/experiment.ts:204:    const config = loadConfig(agentDir);
packages/harness/cortextos/src/bus/experiment.ts:205:    const cycle = config.cycles?.find(
packages/harness/cortextos/src/bus/experiment.ts:448: * Manage experiment cycles in config.json.
packages/harness/cortextos/src/bus/experiment.ts:466:  const config = loadConfig(agentDir);
packages/harness/cortextos/src/bus/experiment.ts:467:  if (!config.cycles) {
packages/harness/cortextos/src/bus/experiment.ts:468:    config.cycles = [];
packages/harness/cortextos/src/bus/experiment.ts:490:      config.cycles.push(cycle);
packages/harness/cortextos/src/bus/experiment.ts:491:      saveConfig(agentDir, config);
packages/harness/cortextos/src/bus/experiment.ts:492:      return config.cycles;
packages/harness/cortextos/src/bus/experiment.ts:499:      const idx = config.cycles.findIndex(c => c.name === options.name);
packages/harness/cortextos/src/bus/experiment.ts:503:      if (options.metric) config.cycles[idx].metric = options.metric;
packages/harness/cortextos/src/bus/experiment.ts:504:      if (options.metric_type) config.cycles[idx].metric_type = options.metric_type;
packages/harness/cortextos/src/bus/experiment.ts:505:      if (options.surface) config.cycles[idx].surface = options.surface;
packages/harness/cortextos/src/bus/experiment.ts:506:      if (options.direction) config.cycles[idx].direction = options.direction;
packages/harness/cortextos/src/bus/experiment.ts:507:      if (options.enabled !== undefined) config.cycles[idx].enabled = options.enabled;
packages/harness/cortextos/src/bus/experiment.ts:508:      if (options.window) config.cycles[idx].window = options.window;
packages/harness/cortextos/src/bus/experiment.ts:509:      if (options.measurement) config.cycles[idx].measurement = options.measurement;
packages/harness/cortextos/src/bus/experiment.ts:510:      if (options.loop_interval) config.cycles[idx].loop_interval = options.loop_interval;
packages/harness/cortextos/src/bus/experiment.ts:511:      if (options.agent) config.cycles[idx].agent = options.agent;
packages/harness/cortextos/src/bus/experiment.ts:512:      saveConfig(agentDir, config);
packages/harness/cortextos/src/bus/experiment.ts:513:      return config.cycles;
packages/harness/cortextos/src/bus/experiment.ts:520:      const removeIdx = config.cycles.findIndex(c => c.name === options.name);
packages/harness/cortextos/src/bus/experiment.ts:524:      config.cycles.splice(removeIdx, 1);
packages/harness/cortextos/src/bus/experiment.ts:525:      saveConfig(agentDir, config);
packages/harness/cortextos/src/bus/experiment.ts:526:      return config.cycles;
packages/harness/cortextos/src/bus/experiment.ts:534:        return config.cycles.filter((c) => c.agent === options.agent);
packages/harness/cortextos/src/bus/experiment.ts:536:      return config.cycles;
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:293:  it('empty state: prints "No crons configured" message', async () => {
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:301:    expect(output).toContain(`No crons configured for ${TEST_AGENT}`);
packages/harness/cortextos/community/agents/security/.claude/skills/worker-agents/SKILL.md:37:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/src/bus/approval.ts:37: * "not configured" — a bug that hid for hours because of the silent
packages/harness/cortextos/src/bus/approval.ts:46: * "not configured" signal (postActivity returns false) is now logged as
packages/harness/cortextos/src/bus/approval.ts:48: * misconfiguration immediately instead of debugging it silently.
packages/harness/cortextos/bus/kb-ingest.sh:98:# Ensure config.json exists (run setup if missing)
packages/harness/cortextos/bus/kb-ingest.sh:99:CONFIG_FILE="$KB_ROOT/config.json"
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/cron-management/SKILL.md:17:Editing `config.json.crons[]` while the agent is running does NOT hot-reload — the daemon
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/cron-management/SKILL.md:18:only re-reads `config.json` on agent boot. Mid-session changes go through `bus add-cron` /
packages/harness/cortextos/community/agents/agentic-crm-assistant/MEMORY.md:8:- Draft external communications freely when useful, but send only after approval unless the user explicitly configured an exception.
packages/harness/cortextos/community/agents/agentic-crm-assistant/MEMORY.md:9:- Prefer tool-agnostic workflows: use whichever email, calendar, meeting-note, contact, or CRM tool is configured and working.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/worker-agents/SKILL.md:36:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/knowledge-base/SKILL.md:65:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/heartbeat/SKILL.md:14:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/bus/_ctx-env.sh:65:# Falls back to system timezone if not configured.
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:3:description: "You need to create a new agent, restart a crashed agent, change an agent's model or config, fix a Telegram bot token, troubleshoot why an agent is not responding, enable or disable an agent, spawn an agent for another user, manage PM2 process management, reset crash limits, or do anything that touches an agent's lifecycle, configuration, or credentials. This is the definitive guide for every agent operation in cortextOS."
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:4:triggers: ["new agent", "create agent", "spawn agent", "add agent", "restart", "soft restart", "hard restart", "disable agent", "enable agent", "change model", "switch model", "bot token", "BotFather", "agent not responding", "agent crashed", "agent down", "crash limit", "reset crashes", "agent health", "list agents", "heartbeat", "onboard", "setup agent", "configure agent", ".env", "config.json", "pm2", "ecosystem.config", "cross-org", "agent for someone else", "agent management", "agent lifecycle", "agent credentials", "telegram bot", "token not working"]
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:18:4. **ALWAYS use `cortextos enable` to start agents.** Never manually edit PM2 config.
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:77:# Step 6: Update config.json
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:80:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT_NAME/config.json';
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:188:# Step 1: Update config.json
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:191:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT/config.json';
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:282:Crons are daemon-managed and persisted to `${CTX_ROOT}/state/<agent>/crons.json`. The daemon dispatches them automatically — no agent-side restoration needed. Use the bus commands; do NOT edit `config.json` or use `/loop` / `CronCreate`.
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:390:3. Regenerate ecosystem config: `cortextos ecosystem` then `pm2 restart ecosystem.config.js`
packages/harness/cortextos/community/agents/security/.claude/skills/agent-management/SKILL.md:412:| Change model | Edit config.json model field + soft restart |
packages/harness/cortextos/bus/kb-collections.sh:57:export MMRAG_CONFIG="$KB_ROOT/config.json"
packages/harness/cortextos/bus/kb-setup.sh:81:# Create mmrag config.json if it doesn't exist (mmrag.py requires it to exist)
packages/harness/cortextos/bus/kb-setup.sh:82:CONFIG_FILE="$KB_ROOT/config.json"
packages/harness/cortextos/bus/kb-setup.sh:95:  echo "  [OK] mmrag config.json created"
packages/harness/cortextos/bus/kb-setup.sh:97:  echo "  [OK] mmrag config.json already exists"
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:69:      const configDir = join(tmpHome, '.cortextos', instanceId, 'config');
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:70:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:71:      const path = join(configDir, 'enabled-agents.json');
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:93:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:106:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:116:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:126:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:135:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/community/agents/security/.claude/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
packages/harness/cortextos/community/agents/security/.claude/skills/env-management/SKILL.md:4:triggers: ["add key", "api key", "env file", ".env", "secret", "credential", "token", "environment variable", "configure key", "set key", "missing key", "key not set", "where do I put", "shared secret", "org secret", "agent secret", "key not loading", "configure credentials", "new api key", "add to env", "rotate key", "rotate token", "key compromised", "token expired", "update api key", "new bot token", "revoke key", "credential rotation", "key rotation", "secret rotation", "key was leaked", "compromised credential", "force rotation", "provider rotated", "expired key", "rotate credentials", "update secret"]
packages/harness/cortextos/bus/hook-permission-telegram.sh:27:    echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","message":"No Telegram credentials configured for remote approval"}}}'
packages/harness/cortextos/bus/hook-permission-telegram.sh:38:# Auto-approve .claude/ directory writes - agents need to modify their own configs at runtime
packages/harness/cortextos/bus/sync-org-config.sh:2:# sync-org-config.sh — push org config updates to all running agents
packages/harness/cortextos/bus/sync-org-config.sh:3:# Usage: CTX_ORG=<org> bash sync-org-config.sh [--org <org>]
packages/harness/cortextos/bus/sync-org-config.sh:42:ENABLED_AGENTS_FILE="${CTX_ROOT}/config/enabled-agents.json"
packages/harness/cortextos/bus/sync-org-config.sh:69:  # Update agent's config.json with org values
packages/harness/cortextos/bus/sync-org-config.sh:70:  AGENT_CFG="${CTX_FRAMEWORK_ROOT}/orgs/${ORG}/agents/${AGENT_NAME}/config.json"
packages/harness/cortextos/bus/sync-org-config.sh:121:        "Org config updated by ${SOURCE}. Re-read config.json and apply new operational settings at your next heartbeat cycle." \
packages/harness/cortextos/bus/sync-org-config.sh:124:      echo "WARNING: Failed to update config for agent '${AGENT_NAME}' — skipping" >&2
packages/harness/cortextos/bus/sync-org-config.sh:129:echo "Notified ${COUNT} agents of org config update"
packages/harness/cortextos/community/agents/agentic-crm-assistant/IDENTITY.md:17:- Triage inboxes and message sources according to configured tools and user rules.
packages/harness/cortextos/community/agents/agentic-crm-assistant/IDENTITY.md:19:- Draft external communications, but never send without approval unless the user explicitly configures an exception.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/crm-management/SKILL.md:8:The local CRM is the default source of truth unless setup configures an external CRM.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/crm-management/SKILL.md:69:- Do not add low-signal bulk contacts unless the user configured that category.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/crm-management/SKILL.md:72:- If external CRM sync is configured, local files remain the audit trail unless setup says otherwise.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/crm-management/SKILL.md:126:- VIP/critical contact has no meaningful touch inside configured cadence.
packages/harness/cortextos/community/agents/agentic-crm-assistant/config.json:21:      "prompt": "Read .claude/skills/email-triage/SKILL.md and run triage for configured inbox/message sources. Create tasks for anything requiring user review, draft eligible replies, update CRM context, and do not send external communications without approval."
packages/harness/cortextos/community/agents/agentic-crm-assistant/config.json:51:      "prompt": "Read .claude/skills/meeting-prep/SKILL.md and process configured meeting-note/transcript sources for recently completed meetings. Extract decisions, action items, follow-ups, and CRM updates."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:106:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:324:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:339:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:360:1. Install/configure it in the project directory
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:363:4. If failed: fix config, repeat
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:13:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:20:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:39:- Measure the metric using the configured measurement method
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:60:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:136:# Update approval setting in config if needed (default is true)
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:156:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:5:// wants to simulate a missing config) so loadSecretsEnv and other path
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:94: * knowledge-base/config.json (i.e. the MMRAG_CONFIG file), true for everything
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:95: * else. Simulates a freshly-created agent with no KB configured yet.
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:100:    if (path.endsWith('/knowledge-base/config.json')) return false;
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:107: * configured KB with config.json present on disk.
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:113:describe('ingestKnowledgeBase — graceful missing-config', () => {
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:114:  it('missing config: warn + return cleanly, execFileSync NEVER called', () => {
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:130:  it('config present: execFileSync IS called with the mmrag ingest args', () => {
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:146:describe('queryKnowledgeBase — graceful missing-config', () => {
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:147:  it('missing config: warn + return empty KBQueryResponse, execFileSync NEVER called', () => {
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:163:  it('config present: execFileSync IS called, happy-path query returns results', () => {
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/bus-reference/SKILL.md:270:- **chat_id** (required): Telegram chat ID (available in config)
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/bus-reference/SKILL.md:450:`config.json.crons[]` mid-session does NOT hot-reload — these commands do, and they
packages/harness/cortextos/dashboard/src/components/shared/priority-badge.tsx:24:  const config = priorityConfig[priority] || fallbackConfig;
packages/harness/cortextos/dashboard/src/components/shared/priority-badge.tsx:27:    <Badge variant={config.variant} className={cn(className)}>
packages/harness/cortextos/dashboard/src/components/shared/priority-badge.tsx:28:      {config.label}
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/tool-discovery/SKILL.md:24:env | grep -E 'GMAIL|GOOGLE|OUTLOOK|NOTION|ZOOM|FATHOM|HUBSPOT|PIPEDRIVE|AIRTABLE|CRM' | sed 's/=.*/=<configured>/'
packages/harness/cortextos/community/agents/security/.claude/skills/knowledge-base/SKILL.md:66:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
packages/harness/cortextos/community/agents/agentic-crm-assistant/GUARDRAILS.md:7:| External communication | "This reply is obvious, I can just send it" | Create a draft and request approval unless the user configured an explicit exception. |
packages/harness/cortextos/community/agents/agentic-crm-assistant/GUARDRAILS.md:11:| Calendar conflict | "It is probably fine" | Check configured protected time and calendars; surface conflicts with alternatives. |
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/meeting-prep/SKILL.md:16:5. Search configured meeting-note tools for prior calls.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/meeting-prep/SKILL.md:41:7. Surface the brief at the configured time.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:3:description: "Tool-agnostic inbox triage for an agentic CRM assistant. Reads configured inboxes, classifies messages, updates CRM, drafts replies, and creates review tasks."
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:14:Use the email/message tools configured in `TOOLS.md`. If no tool is configured, create a human task explaining what is missing.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:19:2. Fetch configured inbox/message source.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:32:9. Archive or mark done only when configured and safe.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:68:Sending replies requires approval unless the user configured an explicit exception in `SOUL.md`.
packages/harness/cortextos/community/agents/security/.claude/skills/heartbeat/SKILL.md:15:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/calendar-management/SKILL.md:8:Use the calendar provider configured in `TOOLS.md`.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/calendar-management/SKILL.md:16:5. Send a concise summary if configured.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/calendar-management/SKILL.md:30:- Check all configured calendars.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/calendar-management/SKILL.md:32:- Prefer configured meeting windows.
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:22:  const config = statusConfig[status];
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:32:            config.color,
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:37:          <span className="text-xs text-muted-foreground">{config.label}</span>
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:40:      <TooltipContent>{config.label}</TooltipContent>
packages/harness/cortextos/community/agents/agentic-crm-assistant/TOOL_CONNECTIONS.md:11:3. Store credentials only in connector configuration, provider auth, `.env`, or
packages/harness/cortextos/community/agents/agentic-crm-assistant/TOOL_CONNECTIONS.md:13:4. Record configured tools in `TOOLS.md`.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:3:description: "You need to create a new agent, restart a crashed agent, change an agent's model or config, fix a Telegram bot token, troubleshoot why an agent is not responding, enable or disable an agent, spawn an agent for another user, manage PM2 process management, reset crash limits, or do anything that touches an agent's lifecycle, configuration, or credentials. This is the definitive guide for every agent operation in cortextOS."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:17:4. **ALWAYS use `cortextos enable` to start agents.** Never manually edit PM2 config.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:77:# Step 6: Update config.json
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:80:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT_NAME/config.json';
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:188:# Step 1: Update config.json
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:191:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT/config.json';
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:282:Crons are daemon-managed and persisted to `${CTX_ROOT}/state/<agent>/crons.json`. The daemon dispatches them automatically — no agent-side restoration needed. Use the bus commands listed below; this is the only persistent scheduling path. Editing `config.json.crons[]` mid-session does NOT hot-reload (the daemon only re-reads `config.json` on agent boot).
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:390:3. Regenerate ecosystem config: `cortextos ecosystem` then `pm2 restart ecosystem.config.js`
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:412:| Change model | Edit config.json model field + soft restart |
packages/harness/cortextos/tests/unit/bus/agents.test.ts:16:    // listAgents() sees a configured but empty framework root and does NOT fall
packages/harness/cortextos/tests/unit/bus/agents.test.ts:32:      const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/unit/bus/agents.test.ts:33:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/bus/agents.test.ts:35:        join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/bus/agents.test.ts:62:      const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/unit/bus/agents.test.ts:63:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/bus/agents.test.ts:65:        join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/bus/agents.test.ts:75:      // No config dir, no heartbeats - should return empty array
packages/harness/cortextos/tests/unit/bus/agents.test.ts:81:      const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/unit/bus/agents.test.ts:82:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/bus/agents.test.ts:84:        join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/bus/agents.test.ts:94:      const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/unit/bus/agents.test.ts:95:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/bus/agents.test.ts:97:        join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/bus/agents.test.ts:120:      const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/unit/bus/agents.test.ts:121:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/bus/agents.test.ts:123:        join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/bus/agents.test.ts:142:      const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/unit/bus/agents.test.ts:143:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/bus/agents.test.ts:145:        join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/tests/unit/bus/agents.test.ts:161:      const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/unit/bus/agents.test.ts:162:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/bus/agents.test.ts:164:        join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:340:# 1. Create or update the worker's MCP config
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:361:1. Install/configure it in the project directory
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:364:4. If failed: fix config, repeat
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:3:description: "Full interactive setup for the agentic CRM personal assistant template. Use at first boot or whenever the user asks to configure/reconfigure the assistant."
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:15:- Never ask for secrets in chat. Ask the user to place credentials in agent `.env`, org `secrets.env`, connector configuration, or the relevant tool's auth flow.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:93:env | grep -E 'GMAIL|GOOGLE|OUTLOOK|NOTION|CRM|HUBSPOT|PIPEDRIVE|AIRTABLE|OPENAI|GEMINI' | sed 's/=.*/=<configured>/'
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:111:- `TOOLS.md` — detected and configured commands
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:112:- `config.json` — timezone, day mode, cron cadence
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:181:- configured scope
packages/harness/cortextos/dashboard/src/components/tasks/task-detail-sheet.tsx:106:      const res = await fetch(`/api/org/config?org=${encodeURIComponent(org)}`);
packages/harness/cortextos/dashboard/src/components/tasks/task-detail-sheet.tsx:109:        setDeliverablesEnabled(!!data.config?.require_deliverables);
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:12:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:19:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:38:- Measure the metric using the configured measurement method
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:59:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:135:# Update approval setting in config if needed (default is true)
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:155:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/relationship-review/SKILL.md:8:Run on the configured cadence.
packages/harness/cortextos/dashboard/src/components/settings/allowed-roots-tab.tsx:121:              No additional allowed roots configured. By default, the dashboard can only serve files from{' '}
packages/harness/cortextos/dashboard/src/components/shared/status-badge.tsx:25:  const config = statusConfig[status] || { variant: 'outline' as const, label: String(status || 'Unknown') };
packages/harness/cortextos/dashboard/src/components/shared/status-badge.tsx:29:      variant={config.variant}
packages/harness/cortextos/dashboard/src/components/shared/status-badge.tsx:30:      className={cn(config.className, className)}
packages/harness/cortextos/dashboard/src/components/shared/status-badge.tsx:32:      {config.label}
packages/harness/cortextos/dashboard/src/app/(dashboard)/analytics/page.tsx:1:import { getOrgs } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/(dashboard)/page.tsx:2:import { getOrgs } from '@/lib/config';
packages/harness/cortextos/dashboard/src/components/shared/category-badge.tsx:32:  const config = categoryConfig[category] ?? categoryConfig.other;
packages/harness/cortextos/dashboard/src/components/shared/category-badge.tsx:35:    <Badge variant="secondary" className={cn(config.className, className)}>
packages/harness/cortextos/dashboard/src/components/shared/category-badge.tsx:36:      {config.label}
packages/harness/cortextos/dashboard/src/app/(dashboard)/skills/page.tsx:3:import { getAllAgents } from '@/lib/config';
packages/harness/cortextos/community/agents/security/.claude/skills/bus-reference/SKILL.md:228:- **chat_id** (required): Telegram chat ID (available in config)
packages/harness/cortextos/dashboard/src/app/(dashboard)/layout.tsx:3:import { getOrgs } from '@/lib/config';
packages/harness/cortextos/dashboard/src/components/agents/agents-grid.tsx:66:          <h3 className="text-lg font-medium mb-1">No agents configured</h3>
packages/harness/cortextos/dashboard/src/app/(dashboard)/knowledge-base/page.tsx:1:import { getOrgs, getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/tests/sprint5-metrics.test.ts:17:    mkdirSync(join(ctxRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/sprint5-metrics.test.ts:30:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), '{}', 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:40:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), JSON.stringify({ bot1: { enabled: true } }), 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:57:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), JSON.stringify({ bot1: { enabled: true } }), 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:72:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), JSON.stringify({ bot1: { enabled: true } }), 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:88:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), '{}', 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:97:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), '{}', 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:107:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), '{}', 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:116:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), JSON.stringify({ bot1: { enabled: true } }), 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:133:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), JSON.stringify({ bot1: { enabled: true } }), 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:154:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), JSON.stringify({ bot1: { enabled: true } }), 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:170:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), JSON.stringify({ bot1: { enabled: true } }), 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:185:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), JSON.stringify({ bot1: { enabled: true } }), 'utf-8');
packages/harness/cortextos/tests/sprint5-metrics.test.ts:203:      writeFileSync(join(ctxRoot, 'config', 'enabled-agents.json'), JSON.stringify({ bot1: { enabled: true } }), 'utf-8');
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:43:  // Operational config state
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:75:  // Load operational config once org is known
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:79:    fetch(`/api/org/config?org=${encodeURIComponent(org)}`)
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:82:        if (d.config) {
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:84:            timezone: d.config.timezone || '',
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:85:            day_mode_start: d.config.day_mode_start || '',
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:86:            day_mode_end: d.config.day_mode_end || '',
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:87:            communication_style: d.config.communication_style || '',
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:88:            default_approval_categories: d.config.default_approval_categories || [],
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:89:            require_deliverables: !!d.config.require_deliverables,
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:127:      const res = await fetch(`/api/org/config?org=${encodeURIComponent(org)}`, {
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:136:        setOpMessage({ type: 'success', text: 'Saved. Agents notified to reload config.' });
packages/harness/cortextos/dashboard/src/components/settings/organization-tab.tsx:190:            Organization not configured. Run{' '}
packages/harness/cortextos/dashboard/src/app/(dashboard)/agents/error.tsx:28:            {error.message || 'Could not fetch agent data. Check that agents are configured.'}
packages/harness/cortextos/CHANGELOG.md:5:Crons move from session-local (`/loop`, `CronCreate`) to daemon-managed `crons.json` files under `${CTX_ROOT}/state/{agent}/`. Auto-migrates from existing `config.json` on first daemon boot. Fully backward-compatible additive feature.
packages/harness/cortextos/CHANGELOG.md:42:- Auto-migration from `config.json` on first daemon boot per agent (`.crons-migrated` marker).
packages/harness/cortextos/CHANGELOG.md:54:- **`max_crashes_per_day` config field**: Added to `AgentConfig` type and all three agent templates (`config.json`). Default raised from 3 to 10 — the previous default halted agents after three transient crashes, which was too aggressive for production. Agents in high-activity environments can set a custom limit.
packages/harness/cortextos/CHANGELOG.md:56:- **README — Agent Configuration section**: New section documenting all `config.json` fields with types, defaults, and descriptions. Includes cron format reference.
packages/harness/cortextos/CHANGELOG.md:147:- **Auto-init**: `kb-ingest.sh` auto-calls `kb-setup.sh` if `config.json` is missing
packages/harness/cortextos/CHANGELOG.md:148:- **`kb-setup.sh`**: Creates venv, installs mmrag deps, writes default `config.json`
packages/harness/cortextos/CHANGELOG.md:158:- **`loadExperimentConfig()`**: Reads `experiments/config.json` for `approval_required` and other settings
packages/harness/cortextos/CHANGELOG.md:159:- **Approval gate**: If `experiments/config.json` has `approval_required: true`, `create-experiment` CLI auto-creates an approval and blocks until approved
packages/harness/cortextos/CHANGELOG.md:163:- **`listAgents()`**: Reads `config/enabled-agents.json` as authoritative source. Falls back to `orgs/` directory scan only when `CTX_FRAMEWORK_ROOT` is explicitly set in environment.
packages/harness/cortextos/CHANGELOG.md:164:- **`buildAgentInfo()`**: Enriches agent entries with heartbeat data (status, current_task, mode), role from `IDENTITY.md`, enabled status from `config.json`
packages/harness/cortextos/CHANGELOG.md:197:| `cortextos install` | Install/configure cortextOS on this machine |
packages/harness/cortextos/CHANGELOG.md:199:| `cortextos doctor` | Diagnose common configuration issues |
packages/harness/cortextos/CHANGELOG.md:244:| `bus create-experiment '<metric>' '<hypothesis>'` | Create experiment (auto-approval if configured) |
packages/harness/cortextos/CHANGELOG.md:416:- `HEARTBEAT.md` — heartbeat protocol and cron configuration
packages/harness/cortextos/CHANGELOG.md:421:- `config.json` — cron definitions, max session seconds
packages/harness/cortextos/CHANGELOG.md:442:- Ecosystem config for org-wide analytics
packages/harness/cortextos/CHANGELOG.md:453:| Sprint 1 — Templates | `sprint1-templates.test.ts` | 24 | All template files, config schemas, no bash $CTX_FRAMEWORK_ROOT/bus/ references |
packages/harness/cortextos/CHANGELOG.md:454:| Sprint 2 — Lifecycle | `sprint2-lifecycle.test.ts` | 8 | Agent enable, onboarding flag, config validation |
packages/harness/cortextos/dashboard/src/components/agents/agent-actions.tsx:178:              action cannot be undone. All agent configuration and data will be
packages/harness/cortextos/dashboard/src/app/(dashboard)/agents/[name]/page.tsx:4:import { getAllAgents } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/(dashboard)/agents/[name]/page.tsx:29:  // Use the canonical system name from config, not the URL param
packages/harness/cortextos/dashboard/src/app/(dashboard)/workflows/page.tsx:152:  // ── Legacy per-agent cron config data (from /api/agents/[name]/crons) ─────
packages/harness/cortextos/dashboard/src/app/(dashboard)/workflows/page.tsx:209:  // ── Fetch per-agent config crons (for CRUD) ────────────────────────────────
packages/harness/cortextos/dashboard/src/app/(dashboard)/workflows/page.tsx:812:                      No crons configured
packages/harness/cortextos/dashboard/src/app/(dashboard)/workflows/health/page.tsx:307:            <p className="text-sm text-muted-foreground">No crons configured across any agents.</p>
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:20:  const [configs, setConfigs] = useState<TelegramConfig[]>([]);
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:95:        {configs.length === 0 ? (
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:97:            No Telegram configurations found. Add TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:98:            to agent .env files to configure Telegram notifications.
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:112:              {configs.map((c) => {
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:12:  const [config, setConfig] = useState<SystemConfig>({
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:35:    const result = await saveSystemConfig(config);
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:63:            value={config.heartbeatStalenessThreshold}
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:83:            value={config.maxCrashesPerDay}
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:103:            value={config.sessionRefreshInterval}
packages/harness/cortextos/community/agents/security/IDENTITY.md:7:Security specialist. Monitors system and network security posture, audits credentials and configurations, scans for vulnerabilities, reviews code changes for security implications, and responds to security incidents across the cortextOS fleet.
packages/harness/cortextos/dashboard/src/app/(dashboard)/settings/page.tsx:17:          Manage integrations, system configuration, users, and appearance.
packages/harness/cortextos/dashboard/src/app/(dashboard)/activity/page.tsx:1:import { getOrgs, getAllAgents } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:6:import { getCTXRoot, getFrameworkRoot, getAllowedRootsConfigPath } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:16:// {CTX_ROOT}/config/allowed-roots.json and read on every request.
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:24:  const configPath = getAllowedRootsConfigPath();
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:25:  if (!fs.existsSync(configPath)) return [];
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:27:    const parsed = JSON.parse(fs.readFileSync(configPath, 'utf-8')) as AllowedRootsFile;
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:100:  // Resolve the file against configured roots in two passes.
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:112:  // must fall within a configured allowed root.
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:158:        message: `File not found under any configured root. To fix: go to Settings > Allowed Roots and add the directory that contains this file (e.g. "${suggestedDir}"), or re-attach as a snapshot via save-output.`,
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:159:        configured_roots: validRoots,
packages/harness/cortextos/dashboard/src/app/api/media/[...filepath]/route.ts:173:  // the default DOMPurify config doesn't already strip on some configs.
packages/harness/cortextos/dashboard/src/app/api/analytics/overview/route.ts:5:import { getAllAgents } from '@/lib/config';
packages/harness/cortextos/community/agents/agentic-crm-assistant/crm/README.md:16:The assistant should also write narrative summaries to `memory/` and ingest durable summaries into the cortextOS knowledge base when configured.
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:799:      config: { features: { goals: true } },
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:829:      config: { features: { goals: true } },
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:941:  it('honours codex_context_cap config override when modelContextWindow is null', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:1069:  it('defaults model to gpt-5-codex when config.model is unset', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:1082:  it('preserves config.model override when set', () => {
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:12: * Stores the token in CTX_ROOT/config/push-tokens.json
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:34:  const configDir = path.join(ctxRoot, 'config');
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:35:  const tokensFile = path.join(configDir, 'push-tokens.json');
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:38:    // Ensure config directory exists
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:39:    if (!fs.existsSync(configDir)) {
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:40:      fs.mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/dashboard/src/components/agents/profile-form.tsx:79:            restarts or reloads its configuration.
packages/harness/cortextos/dashboard/src/components/charts/chart-theme.ts:2: * cortextOS Dashboard - Chart theme configuration.
packages/harness/cortextos/dashboard/src/app/api/approvals/[id]/route.ts:5:import { getFrameworkRoot, getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/components/agents/crons-tab.tsx:142:          No crons configured. Click "Add Cron" to create one.
packages/harness/cortextos/dashboard/src/components/agents/crons-tab.tsx:215:        Crons are read from config.json on agent startup. Changes here update config.json and notify the agent to reload.
packages/harness/cortextos/dashboard/src/app/api/skills/route.ts:3:import { getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/components/workflows/cron-history.tsx:7: *  - Shows up to 100 recent executions per page (configurable via HISTORY_LIMIT)
packages/harness/cortextos/dashboard/src/components/comms/channel-view.tsx:12:// Default: 10000ms (10s). Enforced minimum: 2000ms so an accidental misconfig
packages/harness/cortextos/dashboard/src/middleware.ts:10:// Allowed CORS origins - localhost dev + configured deployment URL + mobile app
packages/harness/cortextos/dashboard/src/middleware.ts:104:          { error: 'Server misconfiguration: auth secret not configured' },
packages/harness/cortextos/dashboard/src/middleware.ts:147:export const config = {
packages/harness/cortextos/dashboard/src/app/api/agents/route.ts:4:import { getFrameworkRoot, getCTXRoot, getAllAgents } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/agents/route.ts:104:  const enabledAgentsPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:4:import { getAgentDir, getAllAgents, CTX_FRAMEWORK_ROOT } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:39:// GET /api/agents/[name]/crons - Read crons from config.json
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:47:    const configPath = path.join(agentDir, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:48:    const raw = await fs.readFile(configPath, 'utf-8');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:49:    const config: AgentConfig = JSON.parse(raw);
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:50:    return Response.json({ crons: config.crons || [] });
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:57:// PUT /api/agents/[name]/crons - Update crons in config.json
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:67:    const configPath = path.join(agentDir, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:68:    const raw = await fs.readFile(configPath, 'utf-8');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:69:    const config: AgentConfig = JSON.parse(raw);
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:114:    // Update config
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:115:    config.crons = crons;
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:116:    await fs.writeFile(configPath, JSON.stringify(config, null, 2) + '\n');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:118:    // Notify agent to re-read config via message bus
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/crons/route.ts:131:          'Crons updated via dashboard. Re-read config.json and update your /loop crons.',
packages/harness/cortextos/dashboard/src/components/agents/agent-card.tsx:16:  /** Filesystem / config key (e.g. "devbot"). Used for URL routing. */
packages/harness/cortextos/dashboard/src/app/api/kb/collections/route.ts:6:import { getCTXRoot, getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/kb/collections/route.ts:35:  const configPath = path.join(kbRoot, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/kb/collections/route.ts:50:    MMRAG_CONFIG: configPath,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:40:  const [config, setConfig] = useState<AgentConfig>({});
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:57:    fetch(`/api/agents/${encodeURIComponent(agentName)}/config`, { signal: controller.signal })
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:60:        if (!controller.signal.aborted && d.config) setConfig(d.config);
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:89:    const start = config.day_mode_start || '';
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:90:    const end = config.day_mode_end || '';
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:114:      const res = await fetch(`/api/agents/${encodeURIComponent(agentName)}/config`, {
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:123:        if (d.config) setConfig(d.config);
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:124:        setMessage({ type: 'success', text: 'Saved. Agent notified to reload config.' });
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:137:        timezone: config.timezone,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:138:        day_mode_start: config.day_mode_start,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:139:        day_mode_end: config.day_mode_end,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:140:        communication_style: config.communication_style,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:141:        approval_rules: config.approval_rules,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:151:        model: config.model,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:152:        max_session_seconds: config.max_session_seconds,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:153:        max_crashes_per_day: config.max_crashes_per_day,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:154:        startup_delay: config.startup_delay,
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:164:  const alwaysAsk = config.approval_rules?.always_ask || [];
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:165:  const neverAsk = config.approval_rules?.never_ask || [];
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:182:              value={config.timezone || ''}
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:194:                value={config.day_mode_start || ''}
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:197:                  const val = config.day_mode_start || '';
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:213:                value={config.day_mode_end || ''}
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:216:                  const val = config.day_mode_end || '';
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:234:              value={config.communication_style || ''}
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:302:              value={config.model || ''}
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:304:              placeholder={MODEL_PLACEHOLDER[config.runtime ?? 'claude-code']}
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:314:                value={config.max_session_seconds ?? ''}
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:324:                value={config.max_crashes_per_day ?? ''}
packages/harness/cortextos/dashboard/src/components/agents/settings-tab.tsx:334:                value={config.startup_delay ?? ''}
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:4:import { CTX_ROOT } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:20:const CONFIG_PATH = path.join(CTX_ROOT, 'config', 'dashboard-settings.json');
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:33:    return Response.json({ config: readConfig() });
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:36:    return Response.json({ error: 'Failed to fetch system config' }, { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:51:    return Response.json({ success: true, config: updated });
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:54:    return Response.json({ error: 'Failed to save system config' }, { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/typing/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/tasks/route.ts:5:import { getFrameworkRoot, getCTXRoot, getOrgs } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/auth/mobile/route.ts:31:    return Response.json({ error: 'Server configuration error' }, { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/goals/route.ts:5:import { getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/messages/history/[agent]/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/messages/upload/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/goals/route.ts:6:import { getGoalsPath } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/experiments/route.ts:93:      // Read config
packages/harness/cortextos/dashboard/src/app/api/experiments/route.ts:95:      const configPath = path.join(expDir, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/experiments/route.ts:96:      if (fs.existsSync(configPath)) {
packages/harness/cortextos/dashboard/src/app/api/experiments/route.ts:98:          const cfg = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/dashboard/src/app/api/messages/send/route.ts:4:import { getCTXRoot, getAllAgents } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/messages/stream/[agent]/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/messages/stream/[agent]/route.ts:27:    return new Response('Server misconfiguration', { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/tasks/[id]/route.ts:6:import { getFrameworkRoot, getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:4:import { getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:21:    return Response.json({ config: ctx, org });
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:80:    // Keep using bash script here: `bus sync-org-config` CLI subcommand does not exist yet.
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:82:    const syncScript = join(frameworkRoot, 'bus', 'sync-org-config.sh');
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:89:        child.on('error', (err) => console.error('[api/org/config] sync-org-config.sh spawn error:', err));
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:90:        child.on('exit', (code) => { if (code !== 0) console.error(`[api/org/config] sync-org-config.sh exited ${code}`); });
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:91:      }).catch((err) => console.error('[api/org/config] child_process import failed:', err));
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:94:    return Response.json({ success: true, config: ctx, org });
packages/harness/cortextos/dashboard/src/app/api/comms/channels/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/comms/upload/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/comms/__tests__/routes.test.ts:54:  fs.mkdirSync(path.join(rootTmp, 'config'), { recursive: true });
packages/harness/cortextos/dashboard/src/app/api/comms/__tests__/routes.test.ts:56:    path.join(rootTmp, 'config', 'enabled-agents.json'),
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:4:import { getFrameworkRoot, getAllAgents, getAgentDir } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:15:    const p = join(agentDir, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:23:    const p = join(orgsDir, org, 'agents', name, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:38:  const configPath = resolveAgentConfigPath(frameworkRoot, name);
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:39:  if (!configPath) {
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:40:    return Response.json({ error: 'Agent config not found' }, { status: 404 });
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:43:    const config = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:44:    return Response.json({ config, name });
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:46:    return Response.json({ error: 'Failed to read config' }, { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:59:  const configPath = resolveAgentConfigPath(frameworkRoot, name);
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:60:  if (!configPath) {
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:61:    return Response.json({ error: 'Agent config not found' }, { status: 404 });
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:124:    const config = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:126:      if (body[key] !== undefined) config[key] = body[key];
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:128:    writeFileSync(configPath, JSON.stringify(config, null, 2) + '\n', 'utf-8');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:136:          [sendMsg, name, 'normal', 'Settings updated via dashboard. Re-read config.json and apply new operational settings.'],
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:145:      console.error(`[api/agents/${name}/config] PATCH: send-message.sh failed (non-fatal):`, notifyErr);
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:148:    return Response.json({ success: true, config, name });
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/config/route.ts:150:    return Response.json({ error: 'Failed to write config' }, { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/route.ts:9: * also reads config files directly from the server-side Next.js process.
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/route.ts:19:import { CTX_ROOT, getAllAgents } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/fire-route.test.ts:15: * Uses the @/ alias resolved by vitest.config.ts to dashboard/src.
packages/harness/cortextos/dashboard/src/app/api/comms/feed/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/comms/feed/route.ts:35:  // are already isolated at the filesystem level under the configured
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/lifecycle/route.ts:4:import { getFrameworkRoot, getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/lifecycle/route.ts:92:        const enabledAgentsPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/lifecycle/route.ts:115:        const enabledAgentsPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/lifecycle/route.ts:188:  const enabledAgentsPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/app/api/workflows/health/route.ts:26:import { CTX_ROOT, getAllAgents } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:4:import { getOrgs, getAgentsForOrg, getAgentDir } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:15:    const configs: Array<{ agent: string; org: string; botToken: string; chatId: string }> = [];
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:41:          configs.push({
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:51:    return Response.json({ configs });
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:54:    return Response.json({ error: 'Failed to fetch telegram configs' }, { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/memory/route.ts:5:import { getAgentDir, getOrgs, getAgentsForOrg } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/[agent]/executions/route.ts:19:import { CTX_ROOT } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/workflows/health/__tests__/health-route.test.ts:9: *   - Empty state: no crons configured
packages/harness/cortextos/dashboard/src/app/api/workflows/health/__tests__/health-route.test.ts:28:const CONFIG_DIR = path.join(rootTmp, 'config');
packages/harness/cortextos/dashboard/src/app/api/kb/search/route.ts:6:import { getCTXRoot, getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/kb/search/route.ts:77:  const configPath = path.join(kbRoot, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/kb/search/route.ts:105:    MMRAG_CONFIG: configPath,
packages/harness/cortextos/dashboard/src/app/api/kb/search/route.ts:127:      { error: 'GEMINI_API_KEY not configured. Add it to orgs/{org}/secrets.env' },
packages/harness/cortextos/dashboard/src/app/api/comms/channel/[pair]/route.ts:4:import { getCTXRoot } from '@/lib/config';

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '420,570p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '280,420p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   280	      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
   281	
   282	  # --------------------------------------------------------------------------
   283	  contact:
   284	    description: |
   285	      A person at a client company. Decision-makers, hiring managers, HR, procurement. Bullhorn calls this `ClientContact`. v1.0 representation is thin (10 fields); v1.1 Triage agent expands decision-authority modelling.
   286	    bullhorn_source: Bullhorn.ClientContact
   287	    v1_0_agent_access:
   288	      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
   289	      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
   290	    canonical_fields:
   291	      bullhorn_id:
   292	        type: integer
   293	        required: true
   294	        source: Bullhorn.ClientContact.id
   295	      first_name:
   296	        type: string
   297	        required: true
   298	        source: Bullhorn.ClientContact.firstName
   299	      last_name:
   300	        type: string
   301	        required: true
   302	        source: Bullhorn.ClientContact.lastName
   303	      email:
   304	        type: string
   305	        required: false
   306	        source: Bullhorn.ClientContact.email
   307	      phone:
   308	        type: string
   309	        required: false
   310	        source: Bullhorn.ClientContact.phone
   311	      title:
   312	        type: string
   313	        required: false
   314	        source: Bullhorn.ClientContact.title
   315	        notes: Job title at client.
   316	      decision_authority:
   317	        type: string
   318	        required: false
   319	        enum: [yes, no, influencer, blocker, unknown]
   320	        source: IFOS-derived (founder captures during intake; thin v0.1, expanded v1.1)
   321	        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
   322	      preferred_contact_method:
   323	        type: string
   324	        required: false
   325	        enum: [email, phone, telegram, whatsapp, linkedin]
   326	        source: IFOS-derived
   327	      date_added_at:
   328	        type: timestamp
   329	        required: true
   330	        source: Bullhorn.ClientContact.dateAdded
   331	      do_not_contact:
   332	        type: boolean
   333	        required: true
   334	        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
   335	        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
   336	    notes:
   337	      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
   338	      - v1.1 Triage expands: structured decision-authority (budget tier, decision domain, escalation chain), engagement history aggregate, preferred-channel sentiment.
   339	
   340	  # --------------------------------------------------------------------------
   341	  brief:
   342	    description: |
   343	      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
   344	    bullhorn_source: Bullhorn.JobOrder
   345	    aliases: [role]
   346	    v1_0_agent_access:
   347	      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
   348	      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
   349	      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
   350	      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
   351	    canonical_fields:
   352	      bullhorn_id:
   353	        type: integer
   354	        required: true
   355	        source: Bullhorn.JobOrder.id
   356	      title:
   357	        type: string
   358	        required: true
   359	        source: Bullhorn.JobOrder.title
   360	        notes: Role title as advertised; not internal IFOS-codified.
   361	      description:
   362	        type: string
   363	        required: false
   364	        source: Bullhorn.JobOrder.publicDescription
   365	        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
   366	      role_type:
   367	        type: string
   368	        required: true
   369	        enum: [permanent, contract, temp, retained_search]
   370	        source: Bullhorn.JobOrder.employmentType (with mapping)
   371	      salary_min:
   372	        type: number
   373	        required: false
   374	        source: Bullhorn.JobOrder.salary
   375	        notes: GBP annual for permanent roles.
   376	      salary_max:
   377	        type: number
   378	        required: false
   379	        source: Bullhorn.JobOrder.salaryUnit (range parsing)
   380	      day_rate_min:
   381	        type: number
   382	        required: false
   383	        source: IFOS-derived (extracted from JD; GBP per day for contract roles)
   384	      day_rate_max:
   385	        type: number
   386	        required: false
   387	        source: IFOS-derived
   388	      location:
   389	        type: string
   390	        required: false
   391	        source: Bullhorn.JobOrder.address.city
   392	      remote_policy:
   393	        type: string
   394	        required: false
   395	        enum: [full_remote, hybrid_2_days_office, hybrid_3_days_office, on_site, flexible]
   396	        source: IFOS-derived (extracted from JD)
   397	      required_skills:
   398	        type: array
   399	        items: string
   400	        required: false
   401	        source: IFOS-derived (extracted from JD; v0.1 free strings; v1.1+ canonicalised skill taxonomy)
   402	      start_date_target:
   403	        type: date
   404	        required: false
   405	        source: IFOS-derived
   406	      urgency:
   407	        type: string
   408	        required: false
   409	        enum: [hot, warm, cold]
   410	        source: IFOS-derived (Concierge maintains based on client check-in cadence)
   411	      status:
   412	        type: string
   413	        required: true
   414	        enum: [open, on_hold, filled, closed_lost, closed_won, cancelled]
   415	        source: Bullhorn.JobOrder.status (with mapping)
   416	      date_added_at:
   417	        type: timestamp
   418	        required: true
   419	        source: Bullhorn.JobOrder.dateAdded
   420	      date_last_modified_at:

 succeeded in 0ms:
   420	      date_last_modified_at:
   421	        type: timestamp
   422	        required: true
   423	        source: Bullhorn.JobOrder.dateLastModified
   424	    notes:
   425	      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
   426	      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
   427	
   428	  # --------------------------------------------------------------------------
   429	  placement:
   430	    description: |
   431	      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
   432	    bullhorn_source: Bullhorn.Placement
   433	    v1_0_agent_access:
   434	      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
   435	      - Scribe (R+W — note links per bullhorn §4.1 A3)
   436	      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
   437	    canonical_fields:
   438	      bullhorn_id:
   439	        type: integer
   440	        required: true
   441	        source: Bullhorn.Placement.id
   442	      start_date:
   443	        type: date
   444	        required: true
   445	        source: Bullhorn.Placement.dateBegin
   446	      end_date:
   447	        type: date
   448	        required: false
   449	        source: Bullhorn.Placement.dateEnd
   450	        notes: Nullable for permanent placements; required for contract.
   451	      status:
   452	        type: string
   453	        required: true
   454	        enum: [active, completed, terminated, never_started]
   455	        source: Bullhorn.Placement.status (with mapping)
   456	      placement_type:
   457	        type: string
   458	        required: true
   459	        enum: [permanent, contract, temp, retained]
   460	        source: Bullhorn.Placement.employmentType (with mapping)
   461	      fee_amount:
   462	        type: number
   463	        required: false
   464	        source: Bullhorn.Placement.fee
   465	        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
   466	      fee_percent:
   467	        type: number
   468	        required: false
   469	        source: Bullhorn.Placement.feeArrangement (parsed)
   470	        notes: For permanent; 15-25% typical UK range.
   471	      candidate_salary_at_placement:
   472	        type: number
   473	        required: false
   474	        source: Bullhorn.Placement.salary
   475	        notes: GBP annual at start. Sets the baseline for fee_amount = salary × fee_percent.
   476	      lifecycle_stage:
   477	        type: string
   478	        required: true
   479	        enum: [pre_start, week_1, month_1, month_3, month_6, month_12, month_24, completed]
   480	        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
   481	        notes: Drives Concierge nurture-event firing.
   482	      termination_reason:
   483	        type: string
   484	        required: false
   485	        source: IFOS-derived (free text for v0.1; v1.1+ structured)
   486	      date_added_at:
   487	        type: timestamp
   488	        required: true
   489	        source: Bullhorn.Placement.dateAdded
   490	    notes:
   491	      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
   492	      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
   493	
   494	  # --------------------------------------------------------------------------
   495	  opportunity:
   496	    description: |
   497	      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
   498	    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
   499	    v1_0_agent_access:
   500	      - "none (v1.1+ exercise per bullhorn §4.1; Inbound Triage primary reader)"
   501	    v1_1_plus_agent_access:
   502	      - (v1.1) Inbound Triage — read for routing inbound candidate enquiries to active opportunities
   503	      - (v1.1) Brief Decoder — write submission events
   504	    canonical_fields:
   505	      bullhorn_id:
   506	        type: integer
   507	        required: true
   508	        source: Bullhorn.JobSubmission.id
   509	      status:
   510	        type: string
   511	        required: true
   512	        enum: [submitted, screening, interview_scheduled, interview_completed, offer_pending, offer_accepted, rejected_by_client, rejected_by_candidate, withdrawn]
   513	        source: Bullhorn.JobSubmission.status (with mapping)
   514	      stage_history:
   515	        type: array
   516	        items: object
   517	        required: false
   518	        source: IFOS-derived (event log; one entry per status transition)
   519	        notes: |
   520	          Each entry: {stage, timestamp, transitioned_by_user_id, notes}.
   521	          v0.1 captures shape; v1.1+ exercises.
   522	      date_submitted:
   523	        type: timestamp
   524	        required: true
   525	        source: Bullhorn.JobSubmission.dateAdded
   526	      date_last_modified_at:
   527	        type: timestamp
   528	        required: true
   529	        source: Bullhorn.JobSubmission.dateLastModified
   530	    notes:
   531	      - v1.0 schema captures shape for forward-compatibility but no v1.0 agent reads or writes Opportunity.
   532	      - v1.1 Brief Decoder + Inbound Triage agents exercise. Schema may revise based on v1.1 build needs.
   533	
   534	  # --------------------------------------------------------------------------
   535	  timesheet:
   536	    description: |
   537	      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
   538	    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
   539	    v1_0_agent_access:
   540	      - "none (v1.1+ exercise; T2 Timesheet + T6 Pay & Bill primary readers per v2.0 backlog)"
   541	    v2_0_agent_access:
   542	      - T2 Timesheet — R+W
   543	      - T6 Pay & Bill — R
   544	    canonical_fields:
   545	      bullhorn_id:
   546	        type: integer
   547	        required: true
   548	        source: Bullhorn.Timesheet.id
   549	      week_starting:
   550	        type: date
   551	        required: true
   552	        source: Bullhorn.Timesheet.weekStartDate
   553	      hours_worked:
   554	        type: number
   555	        required: true
   556	        source: Bullhorn.Timesheet.totalHours
   557	      approved_by_client:
   558	        type: boolean
   559	        required: true
   560	        source: Bullhorn.Timesheet.status (parsed)
   561	      approved_by_contractor:
   562	        type: boolean
   563	        required: true
   564	        source: IFOS-derived (T2 confirms; v2.0)
   565	      date_submitted:
   566	        type: timestamp
   567	        required: true
   568	        source: Bullhorn.Timesheet.dateAdded
   569	    notes:
   570	      - v0.1 placeholder. T2 + T6 builds in v2.0 verify field set against real Bullhorn data.

exec
/bin/zsh -lc 'rg -n "decision_authority|salary_min|salary_max|start_date|role_type|seniority" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:248:#     decision_authority)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:250:#     + salary_min/max + start_date)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date + decision_authority writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers + salary + start_date writes
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:366:      role_type:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:376:      salary_max:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.

codex
REJECTED

1. Invalid `RW` access tokens appear in field-level access lists. Line 258 defines valid dispositions as `R | W | R+W | none`, but lines 103, 131, 143, 156, 172, 185, 198, 213, 226, and 238 use `RW`. This breaks the schema-change skill’s required R/W/R+W vocabulary and makes field access inconsistent with the matrix. Fix by replacing all field-level `RW` values with `R+W`.

2. `tenant_adapters.config` validation is too broad and will reject existing valid config shapes. Lines 404-406 and 526-528 say the v0.3 trigger hard-fails unknown config keys; the companion SQL only allows a narrow key list, but existing autosend config uses keys such as `approval_routing`, `approval_timeouts`, and `sampling_rates`. This would weaken existing adapter configuration rather than just adding v0.3 keys. Fix by scoping validation by `tenant_adapters.adapter_name` or including all existing documented config keys.

3. The supplement assumes `brief.start_date`, which is not a canonical schema field. Lines 249-250 and 292-293 say Scribe writes `salary_min/max + start_date`, but the existing brief schema defines `start_date_target`, not `start_date` (`vertical-schema.yaml` line 402). This violates Schema-before-code by naming an unbacked field. Fix the references to `start_date_target` or add a properly defined `start_date` field.

4. The open-question citation is wrong. Line 552 says open questions are structured per `review-schema-change §6`, but in the supplied type-specific skill open-question discipline is §8; §6 is Bullhorn mapping consistency. This fails the citation-accuracy check. Fix the citation to `review-schema-change §8`.

5. The Cash Conductor retention default is not honest enough for PII-bearing banking data. Lines 370-372 retain matched transactions indefinitely, and lines 593-602 make “defer GDPR audit to v1.1” the v0.3 default despite the SQL table including `payee_name_raw` and `description`. That buries a material privacy limitation in an open question while making indefinite retention the encoded behavior. Fix by either implementing a bounded/pseudonymized default now or marking production/pilot use blocked until legal/DPA review resolves Q4.
tokens used
88,515
REJECTED

1. Invalid `RW` access tokens appear in field-level access lists. Line 258 defines valid dispositions as `R | W | R+W | none`, but lines 103, 131, 143, 156, 172, 185, 198, 213, 226, and 238 use `RW`. This breaks the schema-change skill’s required R/W/R+W vocabulary and makes field access inconsistent with the matrix. Fix by replacing all field-level `RW` values with `R+W`.

2. `tenant_adapters.config` validation is too broad and will reject existing valid config shapes. Lines 404-406 and 526-528 say the v0.3 trigger hard-fails unknown config keys; the companion SQL only allows a narrow key list, but existing autosend config uses keys such as `approval_routing`, `approval_timeouts`, and `sampling_rates`. This would weaken existing adapter configuration rather than just adding v0.3 keys. Fix by scoping validation by `tenant_adapters.adapter_name` or including all existing documented config keys.

3. The supplement assumes `brief.start_date`, which is not a canonical schema field. Lines 249-250 and 292-293 say Scribe writes `salary_min/max + start_date`, but the existing brief schema defines `start_date_target`, not `start_date` (`vertical-schema.yaml` line 402). This violates Schema-before-code by naming an unbacked field. Fix the references to `start_date_target` or add a properly defined `start_date` field.

4. The open-question citation is wrong. Line 552 says open questions are structured per `review-schema-change §6`, but in the supplied type-specific skill open-question discipline is §8; §6 is Bullhorn mapping consistency. This fails the citation-accuracy check. Fix the citation to `review-schema-change §8`.

5. The Cash Conductor retention default is not honest enough for PII-bearing banking data. Lines 370-372 retain matched transactions indefinitely, and lines 593-602 make “defer GDPR audit to v1.1” the v0.3 default despite the SQL table including `payee_name_raw` and `description`. That buries a material privacy limitation in an open question while making indefinite retention the encoded behavior. Fix by either implementing a bounded/pseudonymized default now or marking production/pilot use blocked until legal/DPA review resolves Q4.
