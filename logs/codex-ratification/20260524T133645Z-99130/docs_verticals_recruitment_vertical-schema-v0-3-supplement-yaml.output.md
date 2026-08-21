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
session id: 019e5a33-d060-7cb2-9730-068361f0fe80
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
    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
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
      - Cash Conductor: R+W

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
      - Cash Conductor: R+W

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
I’ll cross-check the supplement against the existing schema, migration files, and cited docs so the verdict is based on the repository state rather than the pasted text alone.
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
    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
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
      - Cash Conductor: R+W

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
      - Cash Conductor: R+W

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
The supplement is present in the repo and the migration files it cites exist. I’m checking the migration content and the prior schema now, because most schema-supplement failures come from mismatch rather than missing files.
exec
/bin/zsh -lc "sed -n '1,260p' docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '1,260p' docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "sed -n '260,620p' docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "''^(entities:|relationships:|agent_access_matrix:|bullhorn_mapping:|  candidate:|  contractor:|  client:|  contact:|  brief:|  opportunity:|  placement:|  timesheet:|  voice_corpus:|  voice_corpus_chunks:|  tone_rule:|  recent_edit:)" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "sed -n '660,835p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '270,360p' docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
    column: embedding
    dimensions: 1536                                 # text-embedding-3-small
    distance_metric: cosine
    index_type: hnsw                                 # HNSW preferred over IVFFlat for v1.0 corpus sizes (<10k chunks/tenant)
    index_params:
      m: 16
      ef_construction: 64
    notes: |
      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
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
      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
    v1_0_exercise: |
      Sparse in v0.2 (linkage is recorded but not actively queried). v1.1 voice-drift-canary cross-references to identify rule-corpus mismatches.

  recent_edit_drives_retraining:
    source: recent_edit
    target: voice_corpus
    cardinality: M:N
    description: |
      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
    v1_0_exercise: |
      Recorded but not actively driving retraining in v1.0 (Brain UI v1.1 surfaces the queue; v2.0 LoRA pipeline reads it). v0.2 establishes the linkage schema so production data accumulates cleanly from W3 forward.

# ============================================================================
# §5 — Migration approach (cross-reference to companion SQL)

 succeeded in 0ms:
    v2_0_notes: T2 Timesheet + T6 Pay & Bill primary readers/writers.

# ============================================================================
# §3 — Agent × Entity R/W matrix
# ============================================================================
# Source-of-truth for who-touches-what across v1.0 agents.
# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
# ============================================================================

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
# Resolved (RESOLVED) items: baked into v0.1 per Day-6 founder decisions.
# Deferred (DEFERRED) items: scope-bounded with named revisit triggers.
# ============================================================================

open_questions:

  Q1_contractor_entity_type:
    status: RESOLVED (Day 6 founder decision)
    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.

  Q2_note_handling:
    status: DEFERRED to v1.1
    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.

  Q3_full_bullhorn_field_set:
    status: DEFERRED to Week 3-4
    v0_1_decision: v0.1 ships minimal v1.0 working set (~10-20 fields per entity) covering what the 6 v1.0 agents actually touch per bullhorn §4.1.
    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
    rationale: Premature schema lockdown is the failure mode; minimum-shape approach lets pilot data guide expansion.

  Q4_system_agents_not_entities:
    status: RESOLVED (Day 6 founder decision)
    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.

  Q5_contact_decision_authority_granularity:
    status: DEFERRED to v1.1
    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
    v1_1_plus_expansion: Sub-fields for decision-domain (technical/budget/strategic), authority tier (final/recommend/influence/observer), engagement history aggregate, preferred-channel sentiment.

  Q6_timesheet_field_set:
    status: DEFERRED to v2.0
    v0_1_decision: Timesheet entity has placeholder 7-field shape (id, week_starting, hours_worked, approved_by_client, approved_by_contractor, date_submitted, primary key).
    revisit_trigger: v2.0 T2 Timesheet agent build verifies against real Bullhorn data and expands.
    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.

  Q7_umbrella_company_promotion:
    status: DEFERRED to v1.1
    surfaced_during_drafting: 2026-05-18 Day 6
    v0_1_decision: contractor.umbrella_company is free-text field in v0.1.
    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.

exec
/bin/zsh -lc "sed -n '360,470p' docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
# §5 — Migration approach (cross-reference to companion SQL)
# ============================================================================

migration:
  sql_file: docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
  rollback_sql_file: docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
  status: drafted (Phase 4); execution against migration-test tenant scheduled for Phase 5
  rollback_strategy: |
    All v0.2 additions are nullable columns + new tables. Rollback = DROP TABLE on the 3 new tables + DROP COLUMN on the 6 added fields. No v0.1 data is mutated; v0.1 reads continue working after rollback. Migration SQL ships with companion v0.2-to-v0.1.sql (Phase 4 deliverable; landed in same commit).

  prerequisite_extensions:
    - pgvector (already enabled at Day-4 §6.5; verify version >= 0.8.0 for HNSW support)

  decision_log_phase_implication: |
    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.

# ============================================================================
# §6 — Open questions added in v0.2
# ============================================================================
# Three new questions; resolved at Codex ratification OR at first pilot data.
# ============================================================================

open_questions_v0_2_additions:

  Q11_voice_corpus_chunk_storage:
    question: |
      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
    options:
      - A: Store both — duplicates ~50MB/tenant but enables fast retrieval without vault round-trip
      - B: Store embedding + pointer — saves disk, requires vault read per top-K retrieval (latency cost)
    v0_2_default: A (store both); revise to B if disk pressure surfaces at >50 tenants
    trigger_for_revisit: tenant count > 50 OR pgvector storage > 10% of total disk

  Q12_tone_rule_severity_block_path:
    question: |
      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
    options:
      - A: Single retry then escalate (current Ultraplan §5.3 default)
      - B: Three retries then escalate
      - C: No retry; immediate escalate (operator triages drift in real-time)
    v0_2_default: A; matches Ultraplan §5.3 retry budget for green-path agents
    trigger_for_revisit: first Concierge build (W10) — measure real retry success rate

  Q13_recent_edit_retention_under_GDPR:
    question: |
      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
    options:
      - A: Indefinite retention (current v0.2 default; maximises LoRA training signal)
      - B: Text bodies purged after 90 days; metadata retained indefinitely
      - C: Text bodies purged after pilot ends (tenant-controlled retention)
    v0_2_default: |
      Pending D2/D3 resolution. v0.2 ships with text fields stored verbatim
      but production deployment + first pilot LOI BLOCKED until D2 SeedLegals
      advisor input + D3 founder decision land. Recommended default per
      Claude analysis: D3-B (90-day text purge + indefinite metadata) with
      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
      Implementation pre-written: scripts/ifos-pii-purge.sh +
      docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql (post
      Round-2 remediation fix).
    trigger_for_revisit: external advisor onboarding (kill-criterion §3.4 Week 1-2 must-fill) — legal/DPO review of retention posture

# ============================================================================
# §7 — Versioning continuation (extends v0.1 §6)
# ============================================================================

versioning:

  v0_2:
    status: This document — Proposed
    date: 2026-05-20 (Day 8, Week 0 extension period)
    scope: |
      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.

      Live migration deferred to Phase 5 against migration-test tenant first;
      production rollout after Codex ratifies v0.2 (queue position 29) and
      the Diagnostic + Janitor agent builds verify the schema against real
      Bullhorn data (Q3 trigger from v0.1 §5).
    next_action: |
      Phase 5 — execute migration SQL against migration-test tenant; verify pgvector HNSW index builds clean; voice-loader.sh queries return expected shape; commit.

  v1_0_voice:
    expected_date: post-Concierge build (W10-13) — first agent to heavily exercise voice corpus
    scope: |
      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).

  v1_1_voice:
    expected_date: post-first-pilot voice corpus mature (Q4 2026 if pilot lands)
    scope: |
      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.

  v2_0_voice:
    expected_date: 2027+ per LoRA pipeline activation per Ultraplan §6
    scope: |
      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.

# ============================================================================
# End of vertical-schema.v0.2-supplement.yaml
# ============================================================================

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,620p'" in /Users/madsadmin/code/CortexOS
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
   292	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
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
   373	      - Cash Conductor: R+W
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
   397	      - Cash Conductor: R+W
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,360p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
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
    57	  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validate_voice_scores') THEN
    58	    RAISE EXCEPTION 'v0.2 validate_voice_scores function missing — rollback cannot complete; re-apply v0.1-to-v0.2.sql §4 to restore';
    59	  END IF;
    60	END $$;
    61	
    62	CREATE TRIGGER validate_voice_scores
    63	  BEFORE INSERT OR UPDATE ON entities
    64	  FOR EACH ROW
    65	  EXECUTE FUNCTION validate_voice_scores();
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '620,720p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

codex
The main structural concern I’m seeing is not YAML shape; it is whether the supplement’s claimed schema surface is complete enough for the two new auxiliary tables and whether the migration enforces what the supplement promises. I’m doing one final targeted pass over cited docs and adapter/config references before returning the verdict.
exec
/bin/zsh -lc 'rg -n "A2|A3|A6|Diagnostic|Janitor|Scribe|Concierge|endpoint surface|Candidate|ClientCorporation|JobOrder|Note|Placement" docs/verticals/recruitment -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Closes Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor + Concierge
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:53:          Candidate's preferred engagement model (distinct from role type).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:54:          IR35 distinction matters for UK contractors. Extracted by Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:56:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:58:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:71:        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:73:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:82:          Scout from match; Janitor uses for dedup (stronger match signal
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:83:          than name+email); Concierge reads for outreach context (NOT for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:85:        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:88:          - Janitor: R   # W only via dedup-merge action
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:89:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:99:          Contact's stated preference; extracted by Scribe from call context.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:100:          Concierge reads to route outbound lifecycle comms.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:101:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:103:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:104:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:110:          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:111:          is in transcript. Concierge respects this when scheduling lifecycle
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:113:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:115:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:116:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:129:        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:131:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:141:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:143:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:154:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:156:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:167:          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:168:          confirming candidate started. Janitor flags ambiguous via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:170:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:172:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:173:          - Janitor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:174:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:182:          voice-classifier review at write time per Scribe §7.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:183:        source: IFOS-derived (Scribe extracts from 7d check-in call)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:185:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:186:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:194:          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:195:          Concierge reads to adjust nurture tone.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:196:        source: IFOS-derived (Scribe LLM extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:198:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:199:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:211:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:213:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:222:          Scribe LLM inference from prospecting-call urgency cues. Drives
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:224:        source: IFOS-derived (Scribe LLM classification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:226:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:234:          Free-text capture of decision-timing phrases. Concierge reads to
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:236:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:238:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:239:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:247:#   - Scribe Contact: none → RW (writes preferred_channel + next_action +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:249:#   - Scribe Brief: R → RW (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:251:#   - Scribe Opportunity: none → RW (writes 3 new fields)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:252:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:253:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:286:    recent_edit: R         # v0.3 NEW (was Concierge/canary/LoRA only); for tacit-note harvest
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:424:      Concierge polling cron updates at end of each cycle. Next poll queries
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:450:      Per-tenant outbound sending hours. Concierge respects when scheduling
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:462:      Diagnostic reports for per-claim citation validation. Activates at
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:536:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:584:      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:627:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:628:  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:633:    - Scribe agent.md §3 entity-field table becomes schema-verifiable
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:634:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:636:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:637:    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:53:      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:54:      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:56:      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:61:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:66:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:70:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:74:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:79:        source: Bullhorn.Candidate.phone
docs/verticals/recruitment/vertical-schema.yaml:83:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:87:        source: Bullhorn.Candidate.status
docs/verticals/recruitment/vertical-schema.yaml:94:        source: Bullhorn.Candidate.owner.id
docs/verticals/recruitment/vertical-schema.yaml:99:        source: Bullhorn.Candidate.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:103:        source: Bullhorn.Candidate.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:107:        source: Bullhorn.Candidate.occupation
docs/verticals/recruitment/vertical-schema.yaml:111:        source: Bullhorn.Candidate.companyName
docs/verticals/recruitment/vertical-schema.yaml:115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:119:        source: IFOS-derived (Scribe extraction; GBP annual)
docs/verticals/recruitment/vertical-schema.yaml:127:        source: Bullhorn.Candidate.address.city
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:136:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
docs/verticals/recruitment/vertical-schema.yaml:161:      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
docs/verticals/recruitment/vertical-schema.yaml:169:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:174:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:178:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:182:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:186:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:191:        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
docs/verticals/recruitment/vertical-schema.yaml:196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
docs/verticals/recruitment/vertical-schema.yaml:205:        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
docs/verticals/recruitment/vertical-schema.yaml:214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
docs/verticals/recruitment/vertical-schema.yaml:217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
docs/verticals/recruitment/vertical-schema.yaml:224:    bullhorn_source: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:226:      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:228:      - Concierge (R — relationship context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:233:        source: Bullhorn.ClientCorporation.id
docs/verticals/recruitment/vertical-schema.yaml:237:        source: Bullhorn.ClientCorporation.name
docs/verticals/recruitment/vertical-schema.yaml:241:        source: Bullhorn.ClientCorporation.industryList
docs/verticals/recruitment/vertical-schema.yaml:247:        source: Bullhorn.ClientCorporation.numEmployees (bucketed)
docs/verticals/recruitment/vertical-schema.yaml:251:        source: Bullhorn.ClientCorporation.companyURL
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:261:        source: IFOS-derived (Janitor maintains)
docs/verticals/recruitment/vertical-schema.yaml:265:        source: Bullhorn.ClientCorporation.owner.id
docs/verticals/recruitment/vertical-schema.yaml:273:        source: Bullhorn.ClientCorporation.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:277:        source: Bullhorn.ClientCorporation.address.city
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
docs/verticals/recruitment/vertical-schema.yaml:288:      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
docs/verticals/recruitment/vertical-schema.yaml:321:        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
docs/verticals/recruitment/vertical-schema.yaml:334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
docs/verticals/recruitment/vertical-schema.yaml:343:      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
docs/verticals/recruitment/vertical-schema.yaml:344:    bullhorn_source: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:347:      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:350:      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:355:        source: Bullhorn.JobOrder.id
docs/verticals/recruitment/vertical-schema.yaml:359:        source: Bullhorn.JobOrder.title
docs/verticals/recruitment/vertical-schema.yaml:364:        source: Bullhorn.JobOrder.publicDescription
docs/verticals/recruitment/vertical-schema.yaml:370:        source: Bullhorn.JobOrder.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:374:        source: Bullhorn.JobOrder.salary
docs/verticals/recruitment/vertical-schema.yaml:379:        source: Bullhorn.JobOrder.salaryUnit (range parsing)
docs/verticals/recruitment/vertical-schema.yaml:391:        source: Bullhorn.JobOrder.address.city
docs/verticals/recruitment/vertical-schema.yaml:410:        source: IFOS-derived (Concierge maintains based on client check-in cadence)
docs/verticals/recruitment/vertical-schema.yaml:415:        source: Bullhorn.JobOrder.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:419:        source: Bullhorn.JobOrder.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:423:        source: Bullhorn.JobOrder.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:432:    bullhorn_source: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:436:      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:441:        source: Bullhorn.Placement.id
docs/verticals/recruitment/vertical-schema.yaml:445:        source: Bullhorn.Placement.dateBegin
docs/verticals/recruitment/vertical-schema.yaml:449:        source: Bullhorn.Placement.dateEnd
docs/verticals/recruitment/vertical-schema.yaml:455:        source: Bullhorn.Placement.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:460:        source: Bullhorn.Placement.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:464:        source: Bullhorn.Placement.fee
docs/verticals/recruitment/vertical-schema.yaml:469:        source: Bullhorn.Placement.feeArrangement (parsed)
docs/verticals/recruitment/vertical-schema.yaml:474:        source: Bullhorn.Placement.salary
docs/verticals/recruitment/vertical-schema.yaml:480:        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
docs/verticals/recruitment/vertical-schema.yaml:481:        notes: Drives Concierge nurture-event firing.
docs/verticals/recruitment/vertical-schema.yaml:489:        source: Bullhorn.Placement.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
docs/verticals/recruitment/vertical-schema.yaml:615:    v1_0_exercise: Concierge reads for addressee-resolution per bullhorn §4.1 A6 Voice gate; addressee = primary decision-maker contact.
docs/verticals/recruitment/vertical-schema.yaml:623:    v1_0_exercise: Concierge addressee context.
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:630:    v1_0_exercise: Concierge reads for outbound-message addressee correctness; thin in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:671:  Diagnostic:
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:682:  Janitor:
docs/verticals/recruitment/vertical-schema.yaml:686:    contact: R       # read-only (Concierge owns writes)
docs/verticals/recruitment/vertical-schema.yaml:692:  Scribe:
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:722:  Concierge:
docs/verticals/recruitment/vertical-schema.yaml:736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:742:    bullhorn_entity: Bullhorn.Candidate
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:748:    bullhorn_entity: Bullhorn.Candidate
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
docs/verticals/recruitment/vertical-schema.yaml:755:    bullhorn_entity: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:766:    bullhorn_entity: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:772:    bullhorn_entity: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:775:    notes: lifecycle_stage is IFOS-derived (Concierge maintains); Bullhorn does not natively store IFOS's nurture-cadence stages.
docs/verticals/recruitment/vertical-schema.yaml:799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
docs/verticals/recruitment/vertical-schema.yaml:856:    rationale: v1.0 Concierge addressee-resolution uses primary-decision-maker; panel modelling adds value when v1.1 Triage handles inbound brief queries from multiple stakeholders.
docs/verticals/recruitment/vertical-schema.yaml:862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:890:    expected_date: post Week 3-4 (after Janitor build verifies against real Bullhorn data)
docs/verticals/recruitment/vertical-schema.yaml:892:      Codex-ratified version. Field sets expanded per Janitor's real-Bullhorn-data findings (Q3 trigger). Possibly Note entity promoted to entity_type if Janitor surfaces query patterns (Q2 trigger). 2-3 revisions expected from v0.1.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:61:      - Scribe (R — voice samples for note-summary tone matching)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:62:      - Concierge (R — voice samples for outbound message generation)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:128:      - Scribe (R — note format constraints)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:130:      - Concierge (R — every outbound message)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:309:        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:317:        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:401:    trigger_for_revisit: first Concierge build (W10) — measure real retry success rate
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:441:    expected_date: post-Concierge build (W10-13) — first agent to heavily exercise voice corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:10:-- Concierge). v0.3 additions:
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:34:    -- Note: not raising EXCEPTION; operator runs with explicit acknowledgment

exec
/bin/zsh -lc "rg -n \"Phase 4 Cat|Cat-β|Round-8|candidate\\.linkedin_url|recent_edit/tone_rule|cash_conductor|Concierge tenant_adapters|Diagnostic Tier 2\" docs/decisions docs -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:4:# Date:   2026-05-24 (Day 19; post-Round-8 Cat-β unblock)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Closes Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor + Concierge
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:10:# Phase 4 Cat-β section.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:33:author: founder (Maddox) + Claude Code; bilateral Cat-β unblock
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:  cash_conductor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:351:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:375:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:409:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:412:    set_by: cash_conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:413:    read_by: [cash_conductor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:511:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:514:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:529:      Smoke verification DO block confirms both cash_conductor_*
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:539:       Cat-β findings closed
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:607:      cash_conductor_transactions table is GATED by an explicit per-tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:626:  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:634:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:636:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:637:    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:289:- Janitor: `candidate.linkedin_url` not in schema
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:329:- Diagnostic: pre-build-with-honesty-notes; Round-8-reviewed; ~3 implementation-gap findings (Cat-δ) queued for W3-4 polish slice
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:333:- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:374:| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:394:5. Q7 passive-status enum claim (line 333) — Cat-α; my Round-8 fix updated Step 3 prose but missed Q7
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:5:-- Authored:     2026-05-24 (Day 19; post-bilateral Cat-β unblock)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:387:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:432:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:433:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:434:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:465:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:467:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:471:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:473:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:476:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:30:  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:43:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:94:  RAISE NOTICE 'v0.3 → v0.2 rollback verified: cash_conductor tables dropped';
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:289:- Janitor: `candidate.linkedin_url` not in schema
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:329:- Diagnostic: pre-build-with-honesty-notes; Round-8-reviewed; ~3 implementation-gap findings (Cat-δ) queued for W3-4 polish slice
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:333:- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:374:| Sourcing Scout | 4 | 5 | +1 (Q7 enum claim missed by my Round-8 fix; Bullhorn webhook conflict newly surfaced) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:394:5. Q7 passive-status enum claim (line 333) — Cat-α; my Round-8 fix updated Step 3 prose but missed Q7
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)

exec
/bin/zsh -lc 'rg -n "tenant_adapters|cash_conductor_transactions|cash_conductor_invoices|auxiliary_table_access_matrix|decision_log.payload|autosend-safety-policy.md|payload_preview|Composio|AgentMail" docs packages agents scripts -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:315:    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:351:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:375:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:400:# §4 — tenant_adapters.config new keys (4 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:407:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:466:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:469:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:475:      tenant_adapters.config.diagnostic_per_claim_sample_rate).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:511:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:514:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:525:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:527:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:600:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:607:      cash_conductor_transactions table is GATED by an explicit per-tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:612:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:636:    - Concierge tenant_adapters.config field refs valid
scripts/ifos-pii-purge.sh:19:# tenant_adapters.config.pii_retention_days (D3-C compatibility).
agents/_shared/autosend-policy.yaml:3:# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:19:# Schema version stamps decision_log.payload.policy_version_sha at write time.
agents/_shared/autosend-policy.yaml:68:    reason: "Internal operator-only Telegram notification (escalations + run-complete markers); not customer-facing; idempotent within decision_log payload_hash dedup window"
agents/_shared/autosend-policy.yaml:342:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:353:# Defaults applied when override fields are absent in tenant_adapters
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:149:      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
docs/verticals/recruitment/vertical-schema.yaml:365:        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:666:# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
scripts/provision-tenant.sh:273:printf '  2. Add tenant_adapters.config overrides if needed\n'
scripts/run-codex-ratification.sh:66:docs/decisions/autosend-safety-policy.md|architecture-decision"
scripts/run-tenancy-audit.sh:70:  entities entity_links decision_log tenant_eval_sets tenant_adapters
agents/_shared/README.md:44:| `HH_POLICY_VERSION_SHA` | no | Git SHA stamped into `decision_log.payload.policy_version_sha` per §7 | `unknown` |
agents/_shared/README.md:53:hh_decision_action  <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:177:- `docs/decisions/autosend-safety-policy.md` — full tier model + §4 reference impl
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 4 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:17:--   - decision_log.payload extension is documented in autosend-safety-policy.md
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:367:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:374:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:384:    -- autosend-safety-policy.md keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:399:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:448:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:450:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:451:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:453:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:465:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:467:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:471:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:473:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:476:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
agents/_shared/hook-helpers.sh:20:# raw PII into shell vars (payload_preview must be sanitised by caller).
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:197:  local payload_preview="$4"
agents/_shared/hook-helpers.sh:204:      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
agents/_shared/hook-helpers.sh:212:      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
agents/_shared/hook-helpers.sh:221:        "${target}" "${payload_hash}" "${payload_preview}" ""
agents/_shared/hook-helpers.sh:226:        "${target}" "${payload_hash}" "${payload_preview}" ""
agents/_shared/hook-helpers.sh:229:          "${payload_hash}" "${payload_preview}" "${tenant}"
agents/_shared/hook-helpers.sh:235:        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
agents/_shared/hook-helpers.sh:237:        "${target}" "${payload_hash}" "${payload_preview}"
agents/_shared/hook-helpers.sh:243:        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
agents/_shared/hook-helpers.sh:250:        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:329:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:337:  local payload_preview="$6"
agents/_shared/hook-helpers.sh:341:  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
agents/_shared/hook-helpers.sh:346:    "$(_hh_json_escape "${payload_preview}")" \
agents/_shared/hook-helpers.sh:393:# tenant override via tenant_adapters.config.sampling_rates.
agents/_shared/hook-helpers.sh:416:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
agents/_shared/hook-helpers.sh:423:  local payload_preview="$4"
agents/_shared/hook-helpers.sh:447:    printf '## Preview\n\n%s\n' "${payload_preview}"
agents/_shared/escalation-codes.md:13:The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
agents/_shared/escalation-codes.md:31:Source: `docs/decisions/autosend-safety-policy.md` §5
agents/_shared/escalation-codes.md:39:- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`
agents/_shared/escalation-codes.md:339:Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
agents/_shared/escalation-codes.md:353:- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:371:- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:30:  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:43:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:68:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:74:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:76:-- tenant_adapters config validation trigger.
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:    WHERE table_name = 'cash_conductor_invoices';
scripts/run-live-migration.sh:204:# decision_log + entities + entity_links + tenant_adapters have FK to
scripts/run-live-migration.sh:239:    -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('tenants','entities','entity_links','decision_log','tenant_eval_sets','tenant_adapters');" 2>/dev/null || echo "0")
agents/recruitment/cash-conductor/agent.md:160:   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
agents/recruitment/cash-conductor/agent.md:169:   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
agents/recruitment/cash-conductor/agent.md:186:     "invoice:<id>", payload_hash, payload_preview)
agents/recruitment/cash-conductor/agent.md:193:     sent (counted from decision_log decision_log.payload.position)
agents/recruitment/cash-conductor/agent.md:223:      payload_hash, payload_preview); tier=yellow internal-draft; the
agents/recruitment/cash-conductor/agent.md:249:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:251:      run_mode, payload_hash, payload_preview)
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/architecture-cohesion-review.md:123:### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)
docs/architecture/architecture-cohesion-review.md:125:- **autosend-safety-policy.md** §7 says `payload_preview` MUST exclude raw PII (max 500 chars, no names/phones/emails)
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:181:**Boundary:** Composio and AgentMail are NEVER referenced in `agent.md`, `tools.yaml`, vault files, or fixtures.
docs/architecture/architecture-cohesion-review.md:185:- **Q:** Are there any references to Composio/AgentMail in agent.md or tools.yaml?
docs/architecture/architecture-cohesion-review.md:187:- **Q:** Could a future agent silently introduce a Composio or AgentMail tool?
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
agents/recruitment/scribe/agent.md:190:     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
agents/recruitment/scribe/agent.md:196:     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
docs/operations/codex-ratification-guide.md:176:no submodule modifications proposed; no Composio/AgentMail in tools.yaml; vault/
docs/operations/codex-round-2-handoff.md:77:| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
docs/operations/codex-round-2-handoff.md:211:  docs/decisions/autosend-safety-policy.md
docs/operations/codex-round-2-remediation-prompt.md:297:  FLAG 1 — autosend-safety-policy.md tier contradiction
docs/operations/codex-round-2-remediation-prompt.md:311:  FLAG 2 — autosend-safety-policy.md legal placeholder
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/operations/codex-round-2-remediation-prompt.md:473:        docs/decisions/autosend-safety-policy.md \
docs/operations/codex-round-2-remediation-prompt.md:515:    - autosend-safety-policy.md §1 + §10: D1 + D2/D3 blocker annotations
docs/operations/codex-round-2-remediation-prompt.md:626:- FLAG 1: autosend-safety-policy.md §1 D1 annotation
docs/operations/codex-round-2-remediation-prompt.md:627:- FLAG 2: autosend-safety-policy.md §10 D2+D3 annotation
docs/operations/codex-ratification-execution-plan.md:102:- [ ] Adapter boundary (no Composio/AgentMail names in agent.md/tools.yaml/fixtures)
docs/operations/codex-ratification-execution-plan.md:130:| 8 | autosend-safety-policy | `docs/decisions/autosend-safety-policy.md` | A |
docs/operations/codex-round-2-autonomous-prompt.md:97:For autosend-safety-policy.md (Tier 1 item #6) and v0.2 supplement (item 
docs/operations/goal-week-3-polish-and-scaffold.md:24:9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
docs/operations/goal-week-3-polish-and-scaffold.md:414:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:375:| Concierge | 7 | 5 | −2 (AgentMail boundary + ESC widening) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:120:- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:44:- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/autosend-approval-bridge-spec.md:78:  - Read action_type, target, payload_hash, payload_preview from the marker
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:66:| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:95:| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:185:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:290:| 16 | `autosend-safety-policy.md` §10 pilot-agreement liability | Placeholder — legal review required before first pilot LOI | Pre-LOI legal review (commercial / regulatory). Codex can ratify the placeholder shape but cannot substitute for legal counsel. |
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:146:#   $4 payload_preview (human-readable summary, <=500 chars, NO raw PII)
docs/decisions/autosend-safety-policy.md:151:  local payload_preview="$4"
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:181:        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:187:      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:241:**Payload (JSONB into `decision_log.payload`):**
docs/decisions/autosend-safety-policy.md:248:  "payload_preview": "<human summary, <=500 chars, NO raw PII>",
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:291:  "payload_preview": "<human summary, <=500 chars>",
docs/decisions/autosend-safety-policy.md:329:  "payload_preview": "<human summary>",
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:388:--     "payload_preview": "<<=500 chars, NO raw PII>",
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:408:`payload_preview` is **explicitly required to exclude raw PII**. It is a human-readable summary that:
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:510:docs/decisions/autosend-safety-policy.md in the IFOS code repository)
docs/decisions/autosend-safety-policy.md:514:(decision_log.payload.policy_version_sha), is the authoritative record
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:586:5. **PII liability for `payload_preview` formatting.** If `payload_preview` accidentally leaks PII into `decision_log`, that's a Provider liability event. Tooling: linter on `payload_preview` strings at hook-helpers.sh layer.
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:113:**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
docs/decisions/v1.0-kill-criterion.md:235:**Must-fill before first pilot LOI signs.** The pilot agreement may reference an external advisor for dispute resolution per `autosend-safety-policy.md` §10 placeholder language. Founder identifies and engages within Weeks 1-2.
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/decisions/v1.0-kill-criterion.md:350:- Adds AgentMail integration (Inbound Triage only) per master brief §3.2
docs/decisions/v1.0-kill-criterion.md:387:**For atomic-correction manifest.** Edit 10 (shared with autosend-safety-policy.md) adds the path drift correction. Manifest grows from 9 to 10.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:784:CREATE TABLE tenant_adapters (
docs/runbooks/day-4-provisioning.md:795:GRANT SELECT, INSERT, UPDATE, DELETE ON tenant_adapters TO ifos_app;
docs/runbooks/day-4-provisioning.md:796:GRANT USAGE, SELECT ON SEQUENCE tenant_adapters_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:908:\d tenant_adapters
docs/runbooks/day-4-provisioning.md:936:ALTER TABLE tenant_adapters ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:943:ALTER TABLE tenant_adapters FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:971:CREATE POLICY tenant_isolation ON tenant_adapters
docs/runbooks/day-4-provisioning.md:1127:- [ ] §6.3 — Six tables exist: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:1248:17. **§7 — RLS isolation gate passed clean (5 of 5).** No-context = 0 ✓, own-tenant insert+select = 1 ✓, cross-tenant = 0 ✓, WITH CHECK adversarial INSERT rejected ✓, own-tenant unaffected = 1 ✓. RLS + FORCE on entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters (5 tables). `tenant_isolation` policy on all 5 with USING + WITH CHECK on `current_setting('app.current_tenant', true)`. Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser, which would bypass RLS). Test data ROLLBACK'd; 2 seeded test tenants cleaned up.
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:275:| `docs/decisions/autosend-safety-policy.md` | 1 | Same cost-target replacement for the cyber-insurance budget reference |
docs/runbooks/tenant-lifecycle.md:250:  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:198:| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
docs/build-brief/00-MASTER-BRIEF.md:141:### 3.2 The Composio/AgentMail adapter boundary
docs/build-brief/00-MASTER-BRIEF.md:145:Composio and AgentMail appear ONLY behind the adapter boundary at `packages/vertical-adapters/recruitment/`. No `agent.md`, no `tools.yaml` `required:` block, no eval fixture, no vault file references either tool directly.
docs/build-brief/00-MASTER-BRIEF.md:152:| Gmail, Outlook, Slack, HubSpot, DocuSign, Calendly, Notion | Via Composio, behind adapter | Commodity SaaS, no vertical specificity |
docs/build-brief/00-MASTER-BRIEF.md:153:| AgentMail | v1.1 Inbound Triage only, behind adapter | Inbox provisioning for agent-identity sends |
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:477:- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
docs/build-brief/00-MASTER-BRIEF.md:600:| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
docs/build-brief/00-MASTER-BRIEF.md:663:        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
docs/build-brief/00-MASTER-BRIEF.md:696:        │  • Composio (commodity SaaS): Gmail, Outlook, Slack, HubSpot                               │
docs/build-brief/00-MASTER-BRIEF.md:697:        │  • AgentMail (v1.1 Triage only): agent-identity inbox                                      │
docs/build-brief/00-MASTER-BRIEF.md:806:> 3. The Composio/AgentMail adapter boundary
docs/build-brief/00-MASTER-BRIEF.md:828:| "Let me use Composio for the Bullhorn connector..." | §3.2 |
docs/build-brief/00-MASTER-BRIEF.md:882:- Never reference Composio or AgentMail in `agent.md`, `tools.yaml`, vault files, or fixtures —
docs/build-brief/00-MASTER-BRIEF.md:953:> 3. You understand the Composio/AgentMail adapter boundary
docs/build-brief/00-MASTER-BRIEF.md:973:- Use Composio for Bullhorn because "the catalogue says they have it" (they don't, and even if they did, see §3.2)
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:563:- **MCP tools required:** Bullhorn (read for state, write for activity log), Microsoft Graph / Gmail (send), AgentMail (optional for agent-identity sends)
docs/specs/ULTRAPLAN.md:565:- **External APIs:** Microsoft Graph or Google Workspace per tenant; AgentMail for v1.1+
docs/specs/ULTRAPLAN.md:577:- **Trigger type:** Inbound email webhook (Microsoft Graph subscription or AgentMail webhook), LinkedIn InMail webhook, website contact form webhook
docs/specs/ULTRAPLAN.md:579:- **MCP tools required:** Microsoft Graph or Gmail (read + send), AgentMail (send, where agent-identity is needed), Bullhorn (read for candidate matching), LinkedIn (read)
docs/specs/ULTRAPLAN.md:581:- **External APIs:** Microsoft Graph subscriptions, AgentMail
docs/specs/ULTRAPLAN.md:585:- **Gotchas:** This is the most dangerous auto-send agent. Auto-send categories must be gated tightly (acknowledge-new-candidate only at v1.1 launch, expand after 30 days of clean data). Misclassification of a complaint as a routine inbound is a relationship killer. The deliverability test for AgentMail vs Microsoft Graph is the rate-limiting research.
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
docs/specs/_archive-build-handoff.md:266:Also Day 4: scope the first MCP server (Bullhorn) — document the `tools.yaml` shape per the Pattern Reference and the Composio/AgentMail adoption doc §3.5. Note: per the adoption doc, Bullhorn is **first-party MCP** (vertical-specific). Composio is *not* the path for it.
docs/specs/_archive-build-handoff.md:382:| 6 | **Concierge** | 10–13 | Bullhorn + Microsoft Graph + AgentMail | First Tier 1 always-on closing demo; 4-week build |
docs/specs/_archive-build-handoff.md:390:## 6. The Composio/AgentMail boundary — critical for tools.yaml
docs/specs/_archive-build-handoff.md:394:**Composio adopted for commodity SaaS only:**
docs/specs/_archive-build-handoff.md:398:**Composio rejected for vertical systems:**
docs/specs/_archive-build-handoff.md:403:**AgentMail adopted as the inbox layer for one agent only:**
docs/specs/_archive-build-handoff.md:407:**The architectural rule (§3 of that document):** agents call adapters, adapters call execution backends. No `agent.md`, no `tools.yaml` `required:` block, no eval fixture references Composio or AgentMail by name. The adapter boundary is enforced in code review.
docs/specs/_archive-build-handoff.md:409:**For Day 4 (first MCP scope):** Bullhorn is first-party. Composio is not the path. Build the connector at `packages/mcp-connectors/bullhorn/` per the Pattern Reference's `tools.yaml` shape.
docs/specs/_archive-build-handoff.md:450:| "Let me use Composio for the Bullhorn connector..." | §6 of this doc |
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run)
agents/recruitment/janitor/agent.md:166:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:167:   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
agents/recruitment/janitor/agent.md:275:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:200:     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
agents/recruitment/concierge/agent.md:231:      "candidate:<bullhorn_id>", payload_hash, payload_preview)
agents/recruitment/concierge/agent.md:392:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
packages/agent-renderer/templates/claude-md-preamble.md:63:Auto-send tier policy per `_shared/autosend-policy.yaml`. Tenant override file (if present): `/vault/{{tenant_slug}}/_config/autosend-overrides.yaml` — read by `autosend_apply_tenant_override` per `docs/decisions/autosend-safety-policy.md` §4.
agents/recruitment/diagnostic/agent.md:74:- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
agents/recruitment/diagnostic/agent.md:75:- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
agents/recruitment/diagnostic/agent.md:128:   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:133:     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:161:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.

exec
/bin/zsh -lc "nl -ba docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md | sed -n '410,435p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md | sed -n '270,345p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   410	
   411	The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
   412	
   413	**Stopping condition met:** founder's "proceed" → Cat-γ widening + Cat-δ Diagnostic polish + Round 9 + this categorization is the conclusive "RATIFY-or-document-disagreement" outcome per the bilateral disposition. No further autonomous remediation will be attempted.
   414	
   415	**Next structural unblocks (founder-action queue):**
   416	1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
   417	2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
   418	3. **Per-agent build-slice delivery** (W5-W13) — closes Cat-δ + Cat-ε per agent at its build wave
   419	4. **Catalogue v2 widening for ESC_DNC_FILTER_HIT + Sourcing Scout auth severity** — Cat-γ continuations
   420	5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
   421	
   422	**Per-agent state at Phase 4 close:**
   423	
   424	| Agent | Status | Round 9 findings | Path to RATIFIED |
   425	|---|---|---|---|
   426	| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
   427	| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
   428	| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
   429	| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
   430	| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
   431	| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
   432	
   433	*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*

 succeeded in 0ms:
   270	| Agent | Round 8 findings | Sessions |
   271	|---|---|---|
   272	| Diagnostic | 5 | `20260524T112636Z-79455` |
   273	| Janitor | 6 | `20260524T112807Z-81339` |
   274	| Scribe | 5 | `20260524T112917Z-82352` |
   275	| Cash Conductor | 5 | `20260524T113038Z-83732` |
   276	| Sourcing Scout | 4 | `20260524T113139Z-84869` |
   277	| Concierge | 7 | `20260524T113247Z-86019` |
   278	
   279	**Round 8 finding categorization** (32 total findings):
   280	
   281	#### Category α — Mechanical (fixed inline; commit appended to Phase 2)
   282	
   283	- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
   284	- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
   285	- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
   286	
   287	#### Category β — Schema-supplement-needed (v0.3 supplement is a founder-action gate before W4-W13 builds)
   288	
   289	- Janitor: `candidate.linkedin_url` not in schema
   290	- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
   291	- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
   292	- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
   293	- All five are blocked on v0.3 supplement landing (founder review at first-pilot-onboarding) — DOCUMENTED IN W4 BACKLOG
   294	
   295	#### Category γ — Catalogue widening (semantic conflicts between ESC code definitions I authored and agent usage)
   296	
   297	- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
   298	- `ESC_CONCIERGE_SLA_MISS` — agent uses for draft >30 min; catalogue defines for inbound brief/customer reply SLAs. Resolution: widen to include draft-generation SLA.
   299	- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
   300	- `ESC_OPEN_BANKING_TOKEN_AGING` — Cash Conductor uses <30 days warn / <7 days blocking staged; catalogue defines ≤14 days info. Resolution: align catalogue to Cash Conductor's actual staged definition.
   301	- `ESC_AUTOSEND_RACE` — Cash Conductor uses for payment-received-during-chase race; catalogue defines for two-agents-same-payload_hash race. Resolution: widen to cover both.
   302	- DOCUMENTED IN W4 BACKLOG (catalogue v2 amendments)
   303	
   304	#### Category δ — Implementation gaps (validate.sh / cycle.sh)
   305	
   306	- Diagnostic validate.sh: emits `ESC_SCHEMA_VIOLATION` not the specific codes declared in §6; doesn't write skip rows when honesty-flagging
   307	- Diagnostic cycle.sh: sends Telegram directly via curl with no `hh_decision_action` row
   308	- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
   309	- All five build-slice items (W4-W13) DOCUMENTED IN BUILD-SLICE BACKLOG
   310	
   311	#### Category ε — Hh_decision_* still missing at some steps
   312	
   313	- Despite Phase-2 adding ~20 calls, additional steps missing:
   314	  - Diagnostic Step 11 cycle.sh-vs-agent.md mismatch (above)
   315	  - Janitor Step 1 auth refresh emits ESC without decision row
   316	  - Scribe Steps 2-3, 7 partial coverage
   317	  - Cash Conductor Steps 7-8, 11
   318	  - Sourcing Scout per-candidate decision rows (claimed in §3 but not in §4 cycle)
   319	  - Concierge Steps 7, 11
   320	- DOCUMENTED IN W4 BACKLOG (cycle.sh build slices deliver these calls per agent §4 specs)
   321	
   322	### Week-3 close status (honest signal per Rule 5)
   323	
   324	**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
   325	
   326	**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
   327	
   328	**Status of 6 agent.md scaffolds:**
   329	- Diagnostic: pre-build-with-honesty-notes; Round-8-reviewed; ~3 implementation-gap findings (Cat-δ) queued for W3-4 polish slice
   330	- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
   331	- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
   332	- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
   333	- Sourcing Scout: pre-build-scaffold; Round-8-reviewed; minimal residual (catalogue-widening + per-candidate decision rows)
   334	- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
   335	
   336	**Backlog landing items (queue Codex Round 9 ONLY after these land):**
   337	1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
   338	2. ESC catalogue v2 amendments (widen 5 codes per Cat-γ list above)
   339	3. Per-agent validate.sh + cycle.sh + tools.yaml + cleanup.sh build slices (W3-W13)
   340	4. Re-ratify per agent.md at end of its build wave; not in Week-3 close
   341	
   342	**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
   343	
   344	*End of Phase 1+2+3 narrative.*
   345	

 succeeded in 0ms:
     1	# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
     2	
     3	**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
     4	**Author:** Founder (Maddox) + Claude Code
     5	**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
     6	**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
     7	**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
     8	
     9	---
    10	
    11	## Context
    12	
    13	ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
    14	
    15	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
    16	
    17	Current line 496 (post-amendment; live as of commit `aed9d3b`):
    18	
    19	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
    20	
    21	The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
    22	
    23	(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
    24	
    25	This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
    26	
    27	1. NLP claim-extraction from the rendered Markdown report (sentence-level fact identification)
    28	2. Per-claim evidence-link matching (semantic similarity between claim and cited URL content)
    29	3. Confidence threshold tuning to avoid false rejections of well-cited paraphrases
    30	
    31	This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
    32	
    33	Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".
    34	
    35	This ADR formalises that disposition as a ratified architectural decision so future Codex rounds + agent.md §5 framing treat it as upstream-canonical, not as a downstream weakening.
    36	
    37	---
    38	
    39	## Decision
    40	
    41	### Decision 1 — Diagnostic Gate A citation validation is per-section coverage ONLY (hard-fail)
    42	
    43	Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
    44	
    45	The OTHER Gate A subchecks (voice classifier ≥ 0.75 and PII boundary) have v0 warn-only paths when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these are honesty-flagged with `validate_check_skipped=true` per the Context section above. W4-polish closes those subchecks to hard-fail. This ADR addresses only the per-section citation subcheck of Gate A; it does NOT modify the voice classifier or PII subchecks.
    46	
    47	### Decision 2 — Per-claim citation validation is a SEPARATE post-launch quality metric (NOT Gate A)
    48	
    49	The per-claim citation pipeline (NLP claim-extraction + per-claim evidence-link matching + aggregate quality metric) is **explicitly outside Gate A** in v1.0. It lands as:
    50	
    51	- A separate post-launch Diagnostic quality signal — analogous to Gate B's outcome threshold (30% discovery-call conversion) but for citation quality
    52	- Authored as a separate W4 ADR (number to be assigned at W4-polish authoring time; this ADR does NOT pre-assign a number) together with the schema supplements that define its payload key + per-tenant config field
    53	- Sampling-based (1-in-N) post-launch quality monitoring; warn-level; never blocks v0 sends
    54	- Activates after voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports
    55	
    56	**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
    57	
    58	**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
    59	
    60	---
    61	
    62	## ULTRAPLAN amendment
    63	
    64	`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
    65	
    66	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
    67	
    68	After this ADR ratifies, the canonical interpretation is:
    69	
    70	> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
    71	
    72	**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:
    73	
    74	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
    75	
    76	This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
    77	
    78	---
    79	
    80	## Why hybrid not full-spec
    81	
    82	**Why not (a) defer launch until per-claim lands?**
    83	- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
    84	- A working v0 with per-section validation has measurable Gate A coverage; deferring means no Gate A at all in the meantime, which is strictly worse
    85	- The 30%-discovery-call Gate B target is independent of per-claim validation; pilot value is reachable without it
    86	
    87	**Why not (c) amend ULTRAPLAN downward permanently?**
    88	- The per-claim requirement is genuinely valuable for v1.1+ once the NLP pipeline exists
    89	- Permanently removing it from ULTRAPLAN loses the documented quality bar
    90	- Hybrid preserves the W4-polish path; permanent amendment closes that door
    91	
    92	**Why hybrid is honest signal (Rule 5):**
    93	- v0 implementation does what it says; W4 polish path is documented + scheduled
    94	- Codex flags become explicit-disposition references (this ADR) not unaddressed weakening
    95	- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
    96	
    97	---
    98	
    99	## Consequences
   100	
   101	### Immediate (this ADR commit)
   102	
   103	- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
   104	- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)
   105	
   106	### Next commit (after this ADR ratifies)
   107	
   108	- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
   109	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue updated to include this ADR. NOT yet updated as of this commit; lands in the post-ratify commit.
   110	
   111	### After Codex ratifies this ADR (Status flips Proposed → Accepted)
   112	
   113	- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the original ULTRAPLAN line 496 prose alone)
   114	- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
   115	
   116	### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
   117	
   118	- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
   119	- Sample rate configurable per tenant via field landing in v0.3 vertical-schema supplement (concrete field name + type specified there, not in this ADR)
   120	- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
   121	- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
   122	
   123	### Downstream artefact references (queued for post-ratify commit)
   124	
   125	- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
   126	- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
   127	- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
   128	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` → adds this ADR as ratification queue item
   129	
   130	These edits all land in the next commit AFTER this ADR ratifies (no point updating agent.md to cite a Proposed ADR; cite once ratified).
   131	
   132	---
   133	
   134	## Open questions
   135	
   136	| # | Question | Resolution path |
   137	|---|---|---|
   138	| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
   139	| Q2 | NLP claim-extraction library — what's the right tool? (spaCy + custom rules / Claude API-based extraction / hosted service) | W4 polish technical investigation; cost vs accuracy tradeoff |
   140	| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
   141	
   142	---
   143	
   144	## Status
   145	
   146	**Proposed.** Awaits Codex ratification via `review-architecture-decision.md` skill.
   147	
   148	Status flips Proposed → Accepted when:
   149	- Codex returns RATIFIED for this ADR
   150	- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
   151	
   152	*End of ADR-006.*

exec
/bin/zsh -lc "sed -n '45,155p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
entities:

  # --------------------------------------------------------------------------
  candidate:
    description: |
      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
    v1_0_agent_access:
      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
    canonical_fields:
      bullhorn_id:
        type: integer
        required: true
        source: Bullhorn.Candidate.id
        notes: Adapter-layer primary key for Bullhorn round-trip. Stable across ingests.
      first_name:
        type: string
        required: true
        source: Bullhorn.Candidate.firstName
      last_name:
        type: string
        required: true
        source: Bullhorn.Candidate.lastName
      email:
        type: string
        required: false
        source: Bullhorn.Candidate.email
        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
      phone:
        type: string
        required: false
        source: Bullhorn.Candidate.phone
      mobile:
        type: string
        required: false
        source: Bullhorn.Candidate.mobile
      status:
        type: string
        required: true
        source: Bullhorn.Candidate.status
        enum: [active, archived, do_not_contact, placed, contractor_promoted]
        notes: |
          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
      owner_user_id:
        type: integer
        required: false
        source: Bullhorn.Candidate.owner.id
        notes: Bullhorn user (consultant) who owns this candidate record.
      date_added_at:
        type: timestamp
        required: true
        source: Bullhorn.Candidate.dateAdded
      date_last_modified_at:
        type: timestamp
        required: true
        source: Bullhorn.Candidate.dateLastModified
      current_role:
        type: string
        required: false
        source: Bullhorn.Candidate.occupation
      current_employer:
        type: string
        required: false
        source: Bullhorn.Candidate.companyName
      desired_role:
        type: string
        required: false
        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
      salary_expectation_min:
        type: number
        required: false
        source: IFOS-derived (Scribe extraction; GBP annual)
      salary_expectation_max:
        type: number
        required: false
        source: IFOS-derived (GBP annual)
      location:
        type: string
        required: false
        source: Bullhorn.Candidate.address.city
        notes: Free-text city/region for v0.1. Structured location pending v1.1.
      willing_to_relocate:
        type: boolean
        required: false
        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
      notice_period_weeks:
        type: integer
        required: false
        source: IFOS-derived (Scribe extracts)
      source:
        type: string
        required: false
        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
        source: IFOS-derived (set by Sourcing Scout at first-touch)
      voice_classifier_score:
        type: number
        required: false
        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
        notes: |
          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
    notes:
      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.

  # --------------------------------------------------------------------------
  contractor:
    description: |
      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.

exec
/bin/zsh -lc 'rg -n "current_role_title|current_job_title|salary_min|salary_max|start_date|decision_authority" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml agents/recruitment/scribe/agent.md -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:376:      salary_max:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:248:#     decision_authority)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:250:#     + salary_min/max + start_date)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers + salary + start_date writes
agents/recruitment/scribe/agent.md:74:| Candidate | `location`, `current_role_title`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (perm/contract/hybrid), `key_skills` (list) |
agents/recruitment/scribe/agent.md:75:| Contact | `seniority`, `decision_authority` (enum: yes/no/influencer/blocker/unknown per Q5 v0.1), `preferred_channel`, `next_action_target_date` |
agents/recruitment/scribe/agent.md:76:| Brief | `salary_min` + `salary_max`, `start_date`, `role_type`, `must_haves` (list), `nice_to_haves` (list), `deal_breakers` (list) |
agents/recruitment/scribe/agent.md:77:| Placement | `start_date`, `placement_status`, `week_1_status_note` (free-text), `satisfaction_signal` (enum) |

exec
/bin/zsh -lc "sed -n '283,425p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '65,85p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    65	- 1:1 call with client contact → Contact entity update
    66	- Briefing call (consultant + client) → Brief entity update
    67	- Placement check-in (consultant + placed candidate) → Placement entity update
    68	- Opportunity scoping (consultant + prospect) → Opportunity entity update
    69	
    70	Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):
    71	
    72	| Entity | Canonical fields (schema-verified) |
    73	|---|---|
    74	| Candidate | `location`, `current_role_title`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (perm/contract/hybrid), `key_skills` (list) |
    75	| Contact | `seniority`, `decision_authority` (enum: yes/no/influencer/blocker/unknown per Q5 v0.1), `preferred_channel`, `next_action_target_date` |
    76	| Brief | `salary_min` + `salary_max`, `start_date`, `role_type`, `must_haves` (list), `nice_to_haves` (list), `deal_breakers` (list) |
    77	| Placement | `start_date`, `placement_status`, `week_1_status_note` (free-text), `satisfaction_signal` (enum) |
    78	| Opportunity | `sector`, `headcount_growth_signal_text`, `hiring_velocity_band`, `decision_window_text` |
    79	
    80	Field names match canonical schema verbatim; some v0.1 fields (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `week_1_status_note`) are scheduled for v0.3 supplement at W6 build start — flagged here as pre-build references requiring schema-supplement landing before Scribe references them in `cycle.sh`. The Q1 verification pass (W6 Day 1) audits all field names against the schema as it exists then.
    81	
    82	Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
    83	
    84	### Output 2 — Tacit-note Markdown attachment
    85	

exec
/bin/zsh -lc "sed -n '429,535p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
  placement:
    description: |
      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
    bullhorn_source: Bullhorn.Placement
    v1_0_agent_access:
      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
      - Scribe (R+W — note links per bullhorn §4.1 A3)
      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
    canonical_fields:
      bullhorn_id:
        type: integer
        required: true
        source: Bullhorn.Placement.id
      start_date:
        type: date
        required: true
        source: Bullhorn.Placement.dateBegin
      end_date:
        type: date
        required: false
        source: Bullhorn.Placement.dateEnd
        notes: Nullable for permanent placements; required for contract.
      status:
        type: string
        required: true
        enum: [active, completed, terminated, never_started]
        source: Bullhorn.Placement.status (with mapping)
      placement_type:
        type: string
        required: true
        enum: [permanent, contract, temp, retained]
        source: Bullhorn.Placement.employmentType (with mapping)
      fee_amount:
        type: number
        required: false
        source: Bullhorn.Placement.fee
        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
      fee_percent:
        type: number
        required: false
        source: Bullhorn.Placement.feeArrangement (parsed)
        notes: For permanent; 15-25% typical UK range.
      candidate_salary_at_placement:
        type: number
        required: false
        source: Bullhorn.Placement.salary
        notes: GBP annual at start. Sets the baseline for fee_amount = salary × fee_percent.
      lifecycle_stage:
        type: string
        required: true
        enum: [pre_start, week_1, month_1, month_3, month_6, month_12, month_24, completed]
        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
        notes: Drives Concierge nurture-event firing.
      termination_reason:
        type: string
        required: false
        source: IFOS-derived (free text for v0.1; v1.1+ structured)
      date_added_at:
        type: timestamp
        required: true
        source: Bullhorn.Placement.dateAdded
    notes:
      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).

  # --------------------------------------------------------------------------
  opportunity:
    description: |
      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
    v1_0_agent_access:
      - "none (v1.1+ exercise per bullhorn §4.1; Inbound Triage primary reader)"
    v1_1_plus_agent_access:
      - (v1.1) Inbound Triage — read for routing inbound candidate enquiries to active opportunities
      - (v1.1) Brief Decoder — write submission events
    canonical_fields:
      bullhorn_id:
        type: integer
        required: true
        source: Bullhorn.JobSubmission.id
      status:
        type: string
        required: true
        enum: [submitted, screening, interview_scheduled, interview_completed, offer_pending, offer_accepted, rejected_by_client, rejected_by_candidate, withdrawn]
        source: Bullhorn.JobSubmission.status (with mapping)
      stage_history:
        type: array
        items: object
        required: false
        source: IFOS-derived (event log; one entry per status transition)
        notes: |
          Each entry: {stage, timestamp, transitioned_by_user_id, notes}.
          v0.1 captures shape; v1.1+ exercises.
      date_submitted:
        type: timestamp
        required: true
        source: Bullhorn.JobSubmission.dateAdded
      date_last_modified_at:
        type: timestamp
        required: true
        source: Bullhorn.JobSubmission.dateLastModified
    notes:
      - v1.0 schema captures shape for forward-compatibility but no v1.0 agent reads or writes Opportunity.
      - v1.1 Brief Decoder + Inbound Triage agents exercise. Schema may revise based on v1.1 build needs.

  # --------------------------------------------------------------------------
  timesheet:

exec
/bin/zsh -lc 'rg -n "sector:|start_date:" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:

codex
REJECTED

1. §9 over-claims that Scribe’s field table becomes schema-verifiable. Lines 632-634 claim Scribe `agent.md` §3 is schema-verifiable after v0.3, but `agents/recruitment/scribe/agent.md` lines 74-78 still reference fields not present in v0.1/v0.2/v0.3: `current_role_title`, `seniority`, Brief `start_date` (schema has `start_date_target`), and Opportunity `sector`. Add those fields to this supplement or change the Scribe contract/rationale to the canonical existing names.

2. The v0.3 access matrix is not reconciled with canonical entity-level access. Lines 245-254 present §2 as a complete v0.3 matrix, but lines 317-323 upgrade Sourcing Scout to `candidate: R+W`, `contractor: R+W`, and `opportunity: R` while the base schema still says Candidate Sourcing Scout is `R` and Opportunity has `none (v1.1+ exercise)`. Add explicit v0.3 entity-level access overrides for every changed disposition, or keep the matrix aligned with the canonical entity definitions.

3. The auxiliary table shape is under-specified relative to the migration and the PII open question. Lines 358-365 and 380-389 list only selected “primary_columns”, but the companion migration creates additional operational and PII-bearing columns such as `payee_name_raw`, `description`, `client_billing_email`, `raw_payload`, and provider/status fields. Line 593 then discusses `payee_name_raw + description` retention even though §3 does not define them. Enumerate all auxiliary-table columns with type, required/nullability, source, and PII notes, or explicitly mark the migration SQL as the authoritative full column schema.

4. §2 references a non-existent access section. Line 315 says “auxiliary-table access is documented in auxiliary_table_access_matrix below”, but no `auxiliary_table_access_matrix` appears later in the artefact. Add that section or change the comment to point to `auxiliary_tables.*.v1_0_agent_access` at lines 372-397.
tokens used
93,234
REJECTED

1. §9 over-claims that Scribe’s field table becomes schema-verifiable. Lines 632-634 claim Scribe `agent.md` §3 is schema-verifiable after v0.3, but `agents/recruitment/scribe/agent.md` lines 74-78 still reference fields not present in v0.1/v0.2/v0.3: `current_role_title`, `seniority`, Brief `start_date` (schema has `start_date_target`), and Opportunity `sector`. Add those fields to this supplement or change the Scribe contract/rationale to the canonical existing names.

2. The v0.3 access matrix is not reconciled with canonical entity-level access. Lines 245-254 present §2 as a complete v0.3 matrix, but lines 317-323 upgrade Sourcing Scout to `candidate: R+W`, `contractor: R+W`, and `opportunity: R` while the base schema still says Candidate Sourcing Scout is `R` and Opportunity has `none (v1.1+ exercise)`. Add explicit v0.3 entity-level access overrides for every changed disposition, or keep the matrix aligned with the canonical entity definitions.

3. The auxiliary table shape is under-specified relative to the migration and the PII open question. Lines 358-365 and 380-389 list only selected “primary_columns”, but the companion migration creates additional operational and PII-bearing columns such as `payee_name_raw`, `description`, `client_billing_email`, `raw_payload`, and provider/status fields. Line 593 then discusses `payee_name_raw + description` retention even though §3 does not define them. Enumerate all auxiliary-table columns with type, required/nullability, source, and PII notes, or explicitly mark the migration SQL as the authoritative full column schema.

4. §2 references a non-existent access section. Line 315 says “auxiliary-table access is documented in auxiliary_table_access_matrix below”, but no `auxiliary_table_access_matrix` appears later in the artefact. Add that section or change the comment to point to `auxiliary_tables.*.v1_0_agent_access` at lines 372-397.
