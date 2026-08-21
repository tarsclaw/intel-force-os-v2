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
session id: 019e5a2e-7301-7781-9c02-96fcb3f22d59
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
I’m going to verify the supplement against the local schema and migration files it cites, because the review rules make citation accuracy and migration pairing load-bearing.
exec
/bin/zsh -lc 'wc -l docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     647 docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
     461 docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
     101 docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
    1209 total

exec
/bin/zsh -lc 'rg -n "''^(entities:|relationships:|agent_access_matrix:|bullhorn_mapping:|candidate:|contact:|brief:|opportunity:|placement:|timesheet:|voice_corpus:|tone_rule:|recent_edit:)" docs/verticals/recruitment/vertical-schema*.yaml' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'ls -l docs/verticals/recruitment/migrations && rg -n "CREATE TABLE|cash_conductor|validate_entities_data_v0_3|validate_tenant_adapters_config_v0_3|GRANT|TODO|voice_classifier_score|linkedin_url|employment_type" docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:256:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:45:entities:
docs/verticals/recruitment/vertical-schema.yaml:583:relationships:
docs/verticals/recruitment/vertical-schema.yaml:669:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:739:bullhorn_mapping:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:53:entities:

 succeeded in 0ms:
total 120
-rw-r--r--@ 1 madsadmin  staff  16182 May 23 14:21 v0.1-to-v0.2.sql
-rw-r--r--@ 1 madsadmin  staff   2182 May 20 11:44 v0.2-to-v0.1.sql
-rw-r--r--@ 1 madsadmin  staff   4716 May 22 14:29 v0.2-to-v0.3-pii-purge.sql
-rw-r--r--@ 1 madsadmin  staff  18322 May 24 14:30 v0.2-to-v0.3.sql
-rw-r--r--@ 1 madsadmin  staff   1229 May 22 14:29 v0.3-to-v0.2-pii-purge.sql
-rw-r--r--@ 1 madsadmin  staff   4356 May 24 14:22 v0.3-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:30:  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:43:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:49:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:50:DROP FUNCTION IF EXISTS validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:94:  RAISE NOTICE 'v0.3 → v0.2 rollback verified: cash_conductor tables dropped';
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:173:CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:181:  IF d ? 'voice_classifier_score' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:182:    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:183:      RAISE EXCEPTION 'voice_classifier_score must be number or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:185:    IF d->'voice_classifier_score' != 'null'::jsonb THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:186:      IF (d->>'voice_classifier_score')::numeric < 0.0
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:187:         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:188:        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:207:    IF d ? 'employment_type' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:208:      IF (d->>'employment_type') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:211:        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:230:    IF d ? 'linkedin_url' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:231:      IF jsonb_typeof(d->'linkedin_url') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:232:        RAISE EXCEPTION 'linkedin_url must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:234:      IF d->>'linkedin_url' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:235:         AND d->>'linkedin_url' !~ '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:236:        RAISE EXCEPTION 'linkedin_url does not match expected pattern: %', d->>'linkedin_url';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:359:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:361:CREATE TRIGGER validate_entities_data_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:364:  EXECUTE FUNCTION validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:374:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:386:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:428:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:431:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:445:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:451:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:454:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';

codex
The local files exist, so I’m checking the actual supplement line numbers and the surrounding schema context now. The first likely pressure points are whether v0.3 treats auxiliary tables consistently and whether all new JSON shapes are actually validated as claimed.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '380,660p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '180,380p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
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
   552	# §8 — Open questions (structured per review-schema-change §8)
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
   594	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   595	      What's the production retention policy?
   596	    options:
   597	      A: 7-year retention with automated pseudonymization at year 7 (hash
   598	         payee_name_raw + description; preserve amount + dates for audit).
   599	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   600	         rows retained beyond 7 years for cross-period reconciliation).
   601	      C: Per-tenant retention override in tenant_adapters.config.
   602	    v0_3_default: A
   603	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   604	      tenant requires shorter retention, escalate to C with tenant-specific
   605	      override. Pseudonymization implementation lands in W4-polish slice.
   606	    production_use_gating: |
   607	      Until pseudonymization implementation lands, production use of
   608	      cash_conductor_transactions table is GATED by an explicit per-tenant
   609	      DPA addendum signed by founder + tenant. Migration-test tenant data
   610	      is not subject to this gate.
   611	
   612	  Q5_unknown_config_keys_handling:
   613	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   614	    options:
   615	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   616	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   617	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   618	    v0_3_default: A
   619	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   620	      for forward-compat, escalate to B or C with explicit ADR.
   621	
   622	# ============================================================================
   623	# §9 — Why v0.3 is the right unblock
   624	# ============================================================================
   625	
   626	rationale: |
   627	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   628	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   629	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   630	  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys + 1
   631	  payload extension, closing those findings.
   632	
   633	  After v0.3 ratifies + migration applies:
   634	    - Scribe agent.md §3 entity-field table becomes schema-verifiable
   635	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   636	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   637	    - Concierge tenant_adapters.config field refs valid
   638	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   639	
   640	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   641	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   642	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   643	  not schema gaps.
   644	
   645	# ============================================================================
   646	
   647	end_of_supplement: true

 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '170,370p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '55,170p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '370,455p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   383	    -- autosend-safety-policy.md keys (per §8 + §10 references in that document)
   384	    'approval_routing', 'approval_timeouts', 'sampling_rates',
   385	    -- v0.3 additions
   386	    'cash_conductor_last_run',
   387	    'concierge_last_poll',
   388	    'concierge_send_window',
   389	    'diagnostic_per_claim_sample_rate'
   390	  ];
   391	BEGIN
   392	  IF c IS NULL THEN
   393	    RETURN NEW;
   394	  END IF;
   395	
   396	  FOR k IN SELECT jsonb_object_keys(c) LOOP
   397	    IF NOT (k = ANY(allowed_keys)) THEN
   398	      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
   399	    END IF;
   400	  END LOOP;
   401	
   402	  -- v0.3 type validations
   403	  IF c ? 'diagnostic_per_claim_sample_rate' THEN
   404	    IF jsonb_typeof(c->'diagnostic_per_claim_sample_rate') != 'number' THEN
   405	      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be integer';
   406	    END IF;
   407	    IF (c->>'diagnostic_per_claim_sample_rate')::int < 1
   408	       OR (c->>'diagnostic_per_claim_sample_rate')::int > 100 THEN
   409	      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be 1-100';
   410	    END IF;
   411	  END IF;
   412	
   413	  IF c ? 'concierge_send_window' THEN
   414	    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
   415	      RAISE EXCEPTION 'concierge_send_window must be object';
   416	    END IF;
   417	    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
   418	      RAISE EXCEPTION 'concierge_send_window must include timezone';
   419	    END IF;
   420	  END IF;
   421	
   422	  RETURN NEW;
   423	END;
   424	$$ LANGUAGE plpgsql;
   425	
   426	DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
   427	
   428	CREATE TRIGGER validate_tenant_adapters_config_v0_3
   429	  BEFORE INSERT OR UPDATE ON tenant_adapters
   430	  FOR EACH ROW
   431	  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
   432	
   433	-- ----------------------------------------------------------------------------
   434	-- §6 — Smoke verification (read-only)
   435	-- ----------------------------------------------------------------------------
   436	
   437	DO $$
   438	DECLARE
   439	  ccr_count INT;
   440	  cci_count INT;
   441	BEGIN
   442	  SELECT count(*) INTO ccr_count FROM information_schema.tables
   443	    WHERE table_name = 'cash_conductor_transactions';
   444	  IF ccr_count != 1 THEN
   445	    RAISE EXCEPTION 'cash_conductor_transactions table not created';
   446	  END IF;
   447	
   448	  SELECT count(*) INTO cci_count FROM information_schema.tables
   449	    WHERE table_name = 'cash_conductor_invoices';
   450	  IF cci_count != 1 THEN
   451	    RAISE EXCEPTION 'cash_conductor_invoices table not created';
   452	  END IF;
   453	
   454	  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
   455	END $$;

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '45,170p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '669,780p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   736	# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
   737	# ============================================================================
   738	
   739	bullhorn_mapping:
   740	
   741	  candidate:
   742	    bullhorn_entity: Bullhorn.Candidate
   743	    primary_key: id
   744	    status_filter: status != 'contractor'
   745	    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
   746	
   747	  contractor:
   748	    bullhorn_entity: Bullhorn.Candidate
   749	    primary_key: id
   750	    status_filter: status='contractor'
   751	    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
   752	    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
   753	
   754	  client:
   755	    bullhorn_entity: Bullhorn.ClientCorporation
   756	    primary_key: id
   757	    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
   758	    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
   759	
   760	  contact:
   761	    bullhorn_entity: Bullhorn.ClientContact
   762	    primary_key: id
   763	    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
   764	
   765	  brief:
   766	    bullhorn_entity: Bullhorn.JobOrder
   767	    primary_key: id
   768	    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
   769	    notes: Skills extraction (required_skills, nice_to_have_skills arrays) is IFOS-derived from JD body, not Bullhorn-sourced (Bullhorn does not consistently structure skill fields across tenants).
   770	
   771	  placement:
   772	    bullhorn_entity: Bullhorn.Placement
   773	    primary_key: id
   774	    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
   775	    notes: lifecycle_stage is IFOS-derived (Concierge maintains); Bullhorn does not natively store IFOS's nurture-cadence stages.
   776	
   777	  opportunity:
   778	    bullhorn_entity: Bullhorn.JobSubmission (or Bullhorn.Opportunity depending on tenant configuration)
   779	    primary_key: id
   780	    field_mapping_density: v0.1 covers 5 fields (placeholder shape); full Bullhorn field-density TBD pending v1.1 Brief Decoder / Inbound Triage build.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '45,210p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    45	entities:
    46	
    47	  # --------------------------------------------------------------------------
    48	  candidate:
    49	    description: |
    50	      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
    51	    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
    52	    v1_0_agent_access:
    53	      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
    54	      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
    55	      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
    56	      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
    57	    canonical_fields:
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
   151	
   152	  # --------------------------------------------------------------------------
   153	  contractor:
   154	    description: |
   155	      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
   156	    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
   157	    v1_0_agent_access:
   158	      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
   159	      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
   160	      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
   161	      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
   162	    canonical_fields:
   163	      # Inherits candidate fields conceptually; below are the additional contractor-specific fields.
   164	      # Full implementation: adapter layer materialises both candidate-overlap fields AND contractor-specific fields in entities.data.
   165	      # Schema notes: see candidate canonical_fields for the shared base set.
   166	      bullhorn_id:
   167	        type: integer
   168	        required: true
   169	        source: Bullhorn.Candidate.id
   170	        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
   171	      first_name:
   172	        type: string
   173	        required: true
   174	        source: Bullhorn.Candidate.firstName
   175	      last_name:
   176	        type: string
   177	        required: true
   178	        source: Bullhorn.Candidate.lastName
   179	      email:
   180	        type: string
   181	        required: false
   182	        source: Bullhorn.Candidate.email
   183	      mobile:
   184	        type: string
   185	        required: false
   186	        source: Bullhorn.Candidate.mobile
   187	      ir35_status:
   188	        type: string
   189	        required: true
   190	        enum: [inside_ir35, outside_ir35, undetermined, exempt_small_business]
   191	        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
   192	        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
   193	      day_rate_min:
   194	        type: number
   195	        required: false
   196	        source: IFOS-derived (Scribe extracts from call; GBP per day)
   197	      day_rate_max:
   198	        type: number
   199	        required: false
   200	        source: IFOS-derived (GBP per day)
   201	      umbrella_company:
   202	        type: string
   203	        required: false
   204	        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
   205	        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
   206	      availability_weeks:
   207	        type: integer
   208	        required: false
   209	        source: IFOS-derived (when can contractor start, in weeks from now)
   210	      current_engagement_end_date:

codex
I found the migration SQL, and the supplement’s own line-numbered file is present. I’m doing one more mechanical check for YAML parseability and referenced companion behavior, since a schema supplement that cannot parse is a hard stop even before semantic review.
exec
/bin/zsh -lc 'rg -n "decision_authority|salary_min|salary_max|start_date|cash_conductor_transactions|cash_conductor_invoices|payee_name_raw|client_billing_email" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:376:      salary_max:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:58:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:65:  payee_name_raw     TEXT,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:88:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:91:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:95:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:96:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:98:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:102:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:103:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:109:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:122:  client_billing_email     TEXT,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:144:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:147:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:151:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:154:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:157:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:161:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:162:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:445:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:451:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:454:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:248:#     decision_authority)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:250:#     + salary_min/max + start_date)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date + decision_authority writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers + salary + start_date writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:315:    cash_conductor_transactions: R+W  # v0.3 NEW auxiliary table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:316:    cash_conductor_invoices: R+W      # v0.3 NEW auxiliary table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:352:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:376:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:512:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:515:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:593:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:594:    question: Bank-feed transactions contain PII (payee_name_raw + description).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:598:         payee_name_raw + description; preserve amount + dates for audit).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:608:      cash_conductor_transactions table is GATED by an explicit per-tenant

exec
/bin/zsh -lc "rg -n \"validate.sh|validate_entities|vertical-schema|schema\" scripts packages docs/verticals/recruitment -g '*.sh' -g '*.js' -g '*.ts' -g '*.py' -g '*.yaml' | head -80" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:6:# Predecessor: docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:9:# schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:15:# Field types: per `review-schema-change` skill §2 allowed types only —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:23:# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:42:# validate_entities_data_v0_3() trigger function (migration §4).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:70:          per candidate enforced by validate_entities_data_v0_3.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:245:# Per review-schema-change skill §5: full matrix across all v1.0 agents
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:518:      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:547:  skill: review-schema-change
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:# §8 — Open questions (structured per review-schema-change §8)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:590:    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:629:  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:634:    - Scribe agent.md §3 entity-field table becomes schema-verifiable
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:636:    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:638:    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:642:  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:643:  not schema gaps.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:1:# IFOS recruitment vertical schema v0.2 — voice corpus supplement
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:6:# Predecessor: docs/verticals/recruitment/vertical-schema.yaml v0.1 (`fec8872`)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:8:# Closes Day-7-honest-read gap #1 (voice corpus schema undefined). Required by
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:42:#   The label `entities:` below is a YAML key (the schema-document convention from
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:255:        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:357:      Recorded but not actively driving retraining in v1.0 (Brain UI v1.1 surfaces the queue; v2.0 LoRA pipeline reads it). v0.2 establishes the linkage schema so production data accumulates cleanly from W3 forward.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:456:# End of vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml:1:# IFOS recruitment vertical schema v0.1
docs/verticals/recruitment/vertical-schema.yaml:13:#       + Day-4 runbook §6.3 (canonical Postgres schema)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:531:      - v1.0 schema captures shape for forward-compatibility but no v1.0 agent reads or writes Opportunity.
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:812:    rationale: Premature schema lockdown is the failure mode; minimum-shape approach lets pilot data guide expansion.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/vertical-schema.yaml:829:    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
docs/verticals/recruitment/vertical-schema.yaml:862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.
docs/verticals/recruitment/vertical-schema.yaml:864:      Hardcoded enum is the lowest-friction v0.1 choice; alternative (lifecycle_stage as free-form string) loses query-time validation. Tradeoff: schema-migration-on-change vs runtime-validation-loss. v1.0 picks former.
docs/verticals/recruitment/vertical-schema.yaml:866:  Q12_source_field_schema:
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/vertical-schema.yaml:906:# End of vertical-schema.yaml v0.1
scripts/run-live-migration.sh:23:#   bash scripts/run-live-migration.sh --dry-run   # connectivity + schema verify; no writes
scripts/run-live-migration.sh:232:    -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('voice_corpus','voice_corpus_chunks','tone_rule','recent_edit');" 2>/dev/null || echo "0")
scripts/run-live-migration.sh:239:    -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('tenants','entities','entity_links','decision_log','tenant_eval_sets','tenant_adapters');" 2>/dev/null || echo "0")
scripts/run-live-migration.sh:264:  -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('voice_corpus','voice_corpus_chunks','tone_rule','recent_edit');" 2>/dev/null || echo "0")
scripts/run-live-migration.sh:279:# Verify schema shape (§10 of v0.1-to-v0.2.sql)
scripts/run-live-migration.sh:281:  -c "SELECT count(*) FROM pg_tables WHERE schemaname='public' AND tablename IN ('voice_corpus','voice_corpus_chunks','tone_rule','recent_edit');")
scripts/run-codex-ratification.sh:75:CLUSTERS[C]="docs/verticals/recruitment/vertical-schema.yaml|schema-change
scripts/run-codex-ratification.sh:76:docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml|schema-change"
scripts/run-codex-ratification.sh:99:  schema-change
packages/diagnostic-generator/src/cli.ts:3:// to /tmp draft path before validate.sh + vault move.
scripts/run-tenancy-audit.sh:26:#     has v0.2 schema + migration-test seed row)
scripts/run-tenancy-audit.sh:173:SELECT table_name FROM information_schema.columns
scripts/run-tenancy-audit.sh:174:WHERE table_schema='public' AND column_name='tenant_slug' AND is_nullable='NO'
scripts/run-tenancy-audit.sh:235:WHERE schemaname='public' ORDER BY tablename;
scripts/run-tenancy-audit.sh:304:SELECT table_name, privilege_type FROM information_schema.role_table_grants
packages/agent-renderer/src/renderer.ts:93:  const bundleSchemaPath = join(ctx.bundleDir, "config.schema.json");
packages/agent-renderer/src/renderer.ts:159:      join(ctx.bundleDir, "validate.sh"),
packages/agent-renderer/src/renderer.ts:160:      join(staging.tmpDir, ".claude", "hooks", "validate.sh"),
packages/agent-renderer/src/fileMap.ts:6:    { source: "config.schema.json", target: "config.json", action: "synthesis", note: "Schema + _config.yaml + common-*.json $refs per ADR-003 §2.1 row 2" },
packages/agent-renderer/src/fileMap.ts:9:    { source: "validate.sh", target: ".claude/hooks/validate.sh", action: "verbatim-copy" },
packages/agent-renderer/src/fileMap.ts:21:  return ["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"];
packages/agent-renderer/tests/unit/fileMap.test.ts:29:    expect(targets).toEqual([".claude/hooks/context.sh", ".claude/hooks/validate.sh", "README.md"]);
packages/agent-renderer/tests/unit/fileMap.test.ts:50:    expect(required).toEqual(["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"]);
packages/agent-renderer/src/synthesis/configJson.ts:42:function applyDefaults(schema: JsonObject, target: JsonObject): void {
packages/agent-renderer/src/synthesis/configJson.ts:43:  const props = schema.properties as JsonObject | undefined;
packages/agent-renderer/src/synthesis/configJson.ts:74:  const bundleSchemaPath = join(ctx.bundleDir, "config.schema.json");
packages/agent-renderer/src/synthesis/configJson.ts:80:  for (const [name, schema] of commonSchemas.entries()) {
packages/agent-renderer/src/synthesis/configJson.ts:81:    ajv.addSchema(schema, name);
packages/agent-renderer/src/synthesis/configJson.ts:92:  for (const schema of commonSchemas.values()) {
packages/agent-renderer/src/synthesis/configJson.ts:93:    applyDefaults(schema, config);
packages/agent-renderer/src/synthesis/configJson.ts:102:    throw new ConfigSynthesisError("schema-validation-failure", `config.json failed schema validation: ${errors}`);
packages/agent-renderer/tests/unit/synthesis.test.ts:100:  it("throws schema-validation-failure when required fields are missing", () => {
packages/agent-renderer/tests/unit/synthesis.test.ts:108:    writeFileSync(join(ctx.bundleDir, "config.schema.json"), JSON.stringify(brokenSchema));
packages/agent-renderer/tests/unit/preflight.test.ts:30:  for (const f of ["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"]) {
packages/agent-renderer/pnpm-lock.yaml:819:  json-schema-traverse@1.0.0:
packages/agent-renderer/pnpm-lock.yaml:1455:      json-schema-traverse: 1.0.0
packages/agent-renderer/pnpm-lock.yaml:1614:  json-schema-traverse@1.0.0: {}
packages/agent-renderer/tests/fixtures/test-agent/validate.sh:7:  echo "validate.sh: CTX_TENANT_SLUG not set" >&2
packages/agent-renderer/tests/fixtures/test-agent/validate.sh:12:  echo "validate.sh: CTX_AGENT_NAME not set" >&2

exec
/bin/zsh -lc "ruby -e 'require \"yaml\"; YAML.load_file(\"docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml\"); puts \"ok\"'" in /Users/madsadmin/code/CortexOS
 succeeded in 132ms:
ok

exec
/bin/zsh -lc "rg -n \"tenant_adapters\\.config|tier_overrides|blocked_recipients|janitor_dedup_threshold|approval_routing|approval_timeouts|sampling_rates|last_poll|send_window|adapter.*config\" docs packages agents scripts" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:401:# §4 — tenant_adapters.config new keys (4 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:405:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:408:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:419:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:428:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:476:      tenant_adapters.config.diagnostic_per_claim_sample_rate).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:526:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:601:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:613:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:637:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:349:    reason: "Recipient in tenant's blocked_recipients override list"
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:393:# tenant override via tenant_adapters.config.sampling_rates.
agents/_shared/tests/test-hook-helpers.sh:196:tier_overrides:
agents/_shared/tests/test-hook-helpers.sh:210:tier_overrides:
agents/_shared/tests/test-hook-helpers.sh:223:tier_overrides:
scripts/ifos-pii-purge.sh:19:# tenant_adapters.config.pii_retention_days (D3-C compatibility).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 4 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:367:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:374:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:381:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:384:    'approval_routing', 'approval_timeouts', 'sampling_rates',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:387:    'concierge_last_poll',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:388:    'concierge_send_window',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:413:  IF c ? 'concierge_send_window' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:414:    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:415:      RAISE EXCEPTION 'concierge_send_window must be object';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:417:    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:418:      RAISE EXCEPTION 'concierge_send_window must include timezone';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:428:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:431:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
scripts/provision-tenant.sh:273:printf '  2. Add tenant_adapters.config overrides if needed\n'
agents/recruitment/cash-conductor/agent.md:104:expected_send_window: orange-tier approval expected within 24h
agents/recruitment/cash-conductor/agent.md:249:    → update tenant_adapters.config.cash_conductor_last_run = now()
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:76:-- tenant_adapters config validation trigger.
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run)
agents/recruitment/janitor/agent.md:166:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:275:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:144:ON CONFLICT (tenant_slug, adapter_name) DO UPDATE SET config = EXCLUDED.config;
agents/recruitment/concierge/agent.md:99:expected_send_window: <ISO; respects sending-hours per tenant config>
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:392:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:107:- **approval_routing_speed** — quantitative: minutes from approval created to user Telegram notification (computed from event log timestamps)
docs/decisions/autosend-safety-policy.md:124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:432:    "tier_overrides": {
docs/decisions/autosend-safety-policy.md:437:    "blocked_recipients": [
docs/decisions/autosend-safety-policy.md:441:    "approval_routing": {
docs/decisions/autosend-safety-policy.md:445:    "approval_timeouts": {
docs/decisions/autosend-safety-policy.md:450:    "sampling_rates": {
docs/decisions/autosend-safety-policy.md:463:3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
docs/decisions/autosend-safety-policy.md:466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:612:- **Whether tenants can disable spot-check sampling entirely:** No, §8 sampling_rates minimum is 1-in-100.

exec
/bin/zsh -lc 'rg -n "cash_conductor_transactions|cash_conductor_invoices|Open Banking|accounting_provider|Xero|QuickBooks|Sage" docs/verticals/recruitment agents packages | head -120' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:315:    cash_conductor_transactions: R+W  # v0.3 NEW auxiliary table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:316:    cash_conductor_invoices: R+W      # v0.3 NEW auxiliary table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:352:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:354:      Open Banking transactions are high-volume + time-series + don't model
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:376:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:385:      - accounting_provider
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:512:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:515:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:593:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:608:      cash_conductor_transactions table is GATED by an explicit per-tenant
agents/_shared/autosend-policy.yaml:56:    reason: "Read-only Xero query; rate-limited via Xero's own quotas; no side effect"
agents/_shared/autosend-policy.yaml:207:    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
agents/_shared/escalation-codes.md:238:Source: derived from v1.0 agent.md adapter references (Bullhorn, Reed, CV-Library, LinkedIn, Gmail, Outlook/MS Graph, Xero, Open Banking)
agents/_shared/escalation-codes.md:281:- **Severity:** **blocking** — Cash Conductor degraded (read-only Xero queries from cache; no reminders sent)
agents/_shared/escalation-codes.md:282:- **Trigger:** Xero (or alt accounting provider) OAuth token refresh failed; API returns 401
agents/_shared/escalation-codes.md:290:- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
agents/_shared/escalation-codes.md:294:- **Recovery:** founder completes Open Banking SCA reauthentication flow
agents/_shared/escalation-codes.md:298:- **Trigger:** Open Banking PSD2 consent approaching 90-day expiry. Three stages:
agents/_shared/escalation-codes.md:305:- **Recovery:** founder schedules + completes Open Banking SCA reauth via tenant's bank login
agents/_shared/escalation-codes.md:319:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
agents/_shared/escalation-codes.md:410:  - **Cash Conductor:** chase/reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure between accounting + ATS)
agents/_shared/escalation-codes.md:419:- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
agents/recruitment/cash-conductor/README.md:14:**Most-independent v1.0 agent.** Zero Bullhorn dependency. Operates against accounting system + Open Banking only. Per ADR-005 §5.1: pull-forward candidate if Bullhorn paths delayed past 2026-06-10.
agents/recruitment/cash-conductor/README.md:20:- `tools.yaml` — Xero / QuickBooks / Sage / Open Banking (TrueLayer or Plaid UK) MCP connectors
agents/recruitment/cash-conductor/README.md:32:- Open Banking MCP connector + ESC_OPEN_BANKING_TOKEN_AGING UX
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:113:  accounting_provider      TEXT NOT NULL,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:132:    accounting_provider IN ('xero', 'quickbooks', 'sage')
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:140:  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:144:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:147:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:151:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:154:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:157:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:161:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:162:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:445:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:451:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:454:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
agents/recruitment/cash-conductor/agent.md:3:**Status:** Proposed (Day-18 pre-W7-8-build scaffold; awaits Q1 LOI + accounting + Open Banking commercial signups + W7 build slice OR earlier-pull-forward per ADR-005 if Bullhorn delays persist).
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are orange-tier (`xero_reminder_draft_internal` per `autosend-safety-policy.yaml` line 104; consultant approval required before send via Concierge); reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:31:# - Xero/QuickBooks/Sage: invoice.created, invoice.sent, invoice.viewed,
agents/recruitment/cash-conductor/agent.md:33:# - Open Banking (TrueLayer/Plaid UK): transaction.posted, balance.updated
agents/recruitment/cash-conductor/agent.md:142:     Open Banking auth + voice corpus + tone rules
agents/recruitment/cash-conductor/agent.md:146:   → accounting: Xero/QuickBooks/Sage OAuth refresh per provider
agents/recruitment/cash-conductor/agent.md:147:   → Open Banking: TrueLayer/Plaid UK 90-day token refresh (CRITICAL —
agents/recruitment/cash-conductor/agent.md:157:3. Bank transaction ingest (mode=webhook from Open Banking)
agents/recruitment/cash-conductor/agent.md:160:   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
agents/recruitment/cash-conductor/agent.md:169:   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
agents/recruitment/cash-conductor/agent.md:268:- Open Banking token >30 days from expiry (otherwise warn)
agents/recruitment/cash-conductor/agent.md:293:| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:296:| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking token <30 days from 90-day expiry | warn (info if <60 days; warn if <30; blocking if <7) | operator_chat_id → ifos_oncall as expiry nears |
agents/recruitment/cash-conductor/agent.md:303:| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:339:| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
agents/recruitment/cash-conductor/agent.md:341:| **Open Banking commercial signup** (TrueLayer or Plaid UK) | Founder commercial; ~£100-300/mo | ⏸ |
agents/recruitment/cash-conductor/agent.md:342:| Xero MCP connector | W7 build start (~2 days) | ⏸ |
agents/recruitment/cash-conductor/agent.md:343:| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
agents/recruitment/cash-conductor/agent.md:344:| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
agents/recruitment/cash-conductor/agent.md:345:| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
agents/recruitment/cash-conductor/agent.md:347:| Per-tenant Open Banking credentials in `_secrets.env` | Tenant onboarding | ⏸ |
agents/recruitment/cash-conductor/agent.md:355:**Per ADR-005 §5.1 pull-forward provision:** if Bullhorn Sub-decisions A+B answers delay past 2026-06-10, Cash Conductor may be pulled forward from W7-8 to W4-5 because it has zero Bullhorn dependency. The other prerequisites (accounting + Open Banking commercial signups) remain founder-action gates regardless.
agents/recruitment/cash-conductor/agent.md:361:**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start (or earlier per ADR-005 pull-forward).
agents/recruitment/cash-conductor/agent.md:367:| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
agents/recruitment/cash-conductor/agent.md:368:| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
agents/recruitment/cash-conductor/agent.md:369:| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
agents/recruitment/cash-conductor/agent.md:373:| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
agents/recruitment/cash-conductor/agent.md:374:| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
agents/recruitment/cash-conductor/agent.md:378:1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:30:  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:43:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:    WHERE table_name = 'cash_conductor_invoices';
packages/agents-runtime/_shared/common-accounting.json:5:  "description": "Accounting-system stub used by Cash Conductor (W7-8 v1.0). Xero-only in v1.0 per master brief §8.2 row 4; extensible later. Per PRODUCT-SPEC §5.3 line 362.",
packages/agents-runtime/_shared/common-accounting.json:12:      "description": "None = Cash Conductor not deployed for this tenant. Xero = deployed."
packages/agents-runtime/_shared/common-accounting.json:16:      "description": "Xero tenant ID; one per IFOS-tenant. Loaded from _secrets.env."
packages/agents-runtime/_shared/common-accounting.json:42:      "description": "v1.0 closes loop via Open Banking reconciliation per Ultraplan §8.1 A4; truelayer placeholder."

codex
REJECTED

1. tenant_adapters.config validation claim is false and breaks an existing documented key. Lines 404-406 and 526-528 say the v0.3 trigger hard-fails unknown keys and type-validates all 4 new keys, but the cited migration only validates `diagnostic_per_claim_sample_rate` and part of `concierge_send_window`; it does not type-check `cash_conductor_last_run` or `concierge_last_poll`. The same hard-fail allowlist also omits the existing `tenant_adapters.config.pii_retention_days` referenced by the v0.2 supplement and PII purge runbook, so applying v0.3 can reject valid tenant config. Fix the migration allowlist and add full type/shape validation for all 4 new keys, or weaken the supplement’s claim.

2. The auxiliary table schema omits load-bearing columns created by the companion migration. Lines 352-366 and 376-390 list only “primary_columns”, but the migration creates additional fields including `currency`, `payee_name_raw`, `description`, `bank_provider`, `match_confidence`, `match_dimensions`, `raw_payload`, `invoice_number`, `client_billing_email`, and timestamps. Lines 593-598 then acknowledge `payee_name_raw + description` as PII even though those fields are not declared in the schema section. Fix by declaring the full auxiliary table shape with type, required/nullability, source, enum/check notes, and PII handling.

3. Retention policy is internally contradictory. Lines 370-372 say matched `cash_conductor_transactions` rows are retained indefinitely, while Q4 lines 596-603 sets the v0.3 default to 7-year retention with pseudonymization at year 7 for the same PII-bearing transaction data. This violates honest-signal: the schema encodes two different defaults. Fix by aligning §3 retention with Q4’s `v0_3_default`, or set Q4’s default to the indefinite-retention option and state the production gate explicitly.

4. The access matrix is not rectangular once v0.3 auxiliary tables are added. Lines 245-246 claim a full matrix across all v1.0 agents and entities, but lines 315-316 add `cash_conductor_transactions` and `cash_conductor_invoices` only under `cash_conductor`; all other agents silently omit those resources. Fix by moving auxiliary-table permissions out of `agent_access_matrix` into a dedicated `auxiliary_table_access_matrix`, or include explicit `none` entries for every other v1.0 agent.
tokens used
130,880
REJECTED

1. tenant_adapters.config validation claim is false and breaks an existing documented key. Lines 404-406 and 526-528 say the v0.3 trigger hard-fails unknown keys and type-validates all 4 new keys, but the cited migration only validates `diagnostic_per_claim_sample_rate` and part of `concierge_send_window`; it does not type-check `cash_conductor_last_run` or `concierge_last_poll`. The same hard-fail allowlist also omits the existing `tenant_adapters.config.pii_retention_days` referenced by the v0.2 supplement and PII purge runbook, so applying v0.3 can reject valid tenant config. Fix the migration allowlist and add full type/shape validation for all 4 new keys, or weaken the supplement’s claim.

2. The auxiliary table schema omits load-bearing columns created by the companion migration. Lines 352-366 and 376-390 list only “primary_columns”, but the migration creates additional fields including `currency`, `payee_name_raw`, `description`, `bank_provider`, `match_confidence`, `match_dimensions`, `raw_payload`, `invoice_number`, `client_billing_email`, and timestamps. Lines 593-598 then acknowledge `payee_name_raw + description` as PII even though those fields are not declared in the schema section. Fix by declaring the full auxiliary table shape with type, required/nullability, source, enum/check notes, and PII handling.

3. Retention policy is internally contradictory. Lines 370-372 say matched `cash_conductor_transactions` rows are retained indefinitely, while Q4 lines 596-603 sets the v0.3 default to 7-year retention with pseudonymization at year 7 for the same PII-bearing transaction data. This violates honest-signal: the schema encodes two different defaults. Fix by aligning §3 retention with Q4’s `v0_3_default`, or set Q4’s default to the indefinite-retention option and state the production gate explicitly.

4. The access matrix is not rectangular once v0.3 auxiliary tables are added. Lines 245-246 claim a full matrix across all v1.0 agents and entities, but lines 315-316 add `cash_conductor_transactions` and `cash_conductor_invoices` only under `cash_conductor`; all other agents silently omit those resources. Fix by moving auxiliary-table permissions out of `agent_access_matrix` into a dedicated `auxiliary_table_access_matrix`, or include explicit `none` entries for every other v1.0 agent.
