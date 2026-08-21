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
session id: 019e5a42-b9ae-71f2-ab62-556043ce72b4
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

      week_1_status_vault_path:
        type: string
        max_length: 200
        pattern: '^/vault/[a-z0-9-]+/scribe-notes/[a-zA-Z0-9-]+\.md$'
        required: false
        notes: |
          POINTER ONLY (per ADR-002 vault/Postgres split). The 7d check-in
          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
          This field stores the vault path; narrative does NOT enter
          Postgres. Voice-classifier review at write time applies to the
          vault file content; Concierge reads the vault file directly via
          its path resolution.
        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
          to vault then stores pointer here)
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
  # Validation: the validate_entities_data_v0_3 trigger validates FIELD
  # SHAPE only (type checks, enum membership, length caps, array element
  # types). It does NOT enforce which agent is writing — agent-level
  # write permission is DOCUMENTARY in v0.3, enforced at the application
  # layer (cycle.sh + hh_decision_action) where the agent_name in the
  # decision_log row records who wrote. Entity-level RLS enforces TENANT
  # isolation but not agent-level access. Column-level RLS or per-agent
  # database roles would be the v1.1+ enforcement layer; v0.3 is documentary.

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
  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
  # that ships alongside Tier 2 activation. v0.3 introducing the payload
  # key without enforcement would violate review-schema-change §3
  # (bounded values require CHECK or trigger). Tier 2 schema work owns
  # the constraint + writer; this v0.3 supplement is silent on it.
  deferred_to_future_adr:
    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
    schema_owner: future W4-polish supplement (not v0.3)
    rationale: |
      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
      separate post-launch quality metric outside Gate A. The payload key,
      its [0.0, 1.0] range validation, and the sample-rate config field
      all land together with Tier 2 activation. Tier 2 doesn't activate
      until the voice classifier microservice ships + first pilot tenant
      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
      payload shape to avoid declaring schema without enforcement.

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
  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys. The
  per_claim_confidence_distribution payload key originally planned for
  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
  §5 of this supplement); v0.3 is silent on payload schema extensions.

  After v0.3 ratifies + migration applies:
    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
      the v0.3-added fields (employment_type, key_skills, preferred_channel,
      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
      placement_status, week_1_status_vault_path, satisfaction_signal,
      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
      are now schema-backed. (Note: week_1_status_note narrative now lives
      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
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
I’ll verify the supplement against the local schema/migration context and cited references before deciding, especially because this review hinges on cross-file consistency.
exec
/bin/zsh -lc 'wc -l docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     771 docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
     487 docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
     101 docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
    1359 total

exec
/bin/zsh -lc "rg --files docs/verticals/recruitment | rg 'migrations/v0\\.[23]-to-v0\\.[23]\\.sql|bullhorn-integration-path|sequencing-target|operational-hygiene-protocol|codex-disagreement-2026-05-24-diagnostic-gate-a'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql

exec
/bin/zsh -lc 'rg -n "''^status:|''^entities:|''^relationships:|''^agent_access_matrix:|voice_corpus|tone_rule|recent_edit|candidate:|contractor:|client:|contact:|brief:|opportunity:|placement:|timesheet:|bullhorn_mapping" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:31:status: Proposed
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:46:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:91:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:118:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:159:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:208:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:259:#   - Diagnostic client: none → R (reads Companies House data via cached
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:261:#   - Diagnostic contact: none → R (reads §11 decision-maker map context)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:262:#   - Diagnostic opportunity: none → R (reads prospect-firm opportunity if exists)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:263:#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:265:#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:266:#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:268:#   - Janitor timesheet: none → R (reads for placement-state inference)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:275:#   - Scribe timesheet: none → R (reads for placement-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:277:#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:279:#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#   - Cash Conductor timesheet: none → R (reads to verify billable hours
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:282:#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:284:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:285:#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:286:#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:288:#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:289:#   - Concierge opportunity: none → R (reads for outbound lifecycle-event context)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Concierge timesheet: none → R (reads to verify placement-progress for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:296:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:301:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:309:  # disposition. Example: Scribe.candidate: R+W at entity level; per-field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:324:    candidate: R           # reads for outreach context (§11 decision-maker map)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:325:    contractor: none       # not in scope at v1.0
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:326:    client: R              # reads via Companies House lookup (entity-shape if cached)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:327:    contact: R             # reads for §11 decision-maker map
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:328:    brief: none            # diagnostic is sales-tool not brief-driven
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:329:    opportunity: R         # may read prospect-firm opportunity if exists
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:330:    placement: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:331:    timesheet: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:332:    voice_corpus: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:333:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:334:    tone_rule: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:335:    recent_edit: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:338:    candidate: R+W         # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:339:    contractor: R+W        # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:340:    client: R+W            # Companies House enrichment writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:341:    contact: R+W           # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:342:    brief: R               # context for related candidate cleanup
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:343:    opportunity: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:344:    placement: R+W         # lifecycle-state cleanup
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:345:    timesheet: R           # reads for placement-state inference
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:346:    voice_corpus: R        # tacit-note narrative voice grounding
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:347:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:348:    tone_rule: R           # v0.3 NEW (was no access)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:349:    recent_edit: R         # v0.3 NEW (was Concierge/canary/LoRA only); for tacit-note harvest
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:352:    candidate: R+W         # call-summary field extraction
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:353:    contractor: R+W        # call-summary field extraction
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:354:    client: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:355:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:356:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:357:    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:358:    placement: R+W         # check-in field extraction
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:359:    timesheet: R           # reads for placement-context resolution on check-in calls
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:360:    voice_corpus: R        # tacit-note voice grounding
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:361:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:362:    tone_rule: R           # v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:363:    recent_edit: W         # writes its own edits for retraining
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:366:    candidate: none        # no Bullhorn dependency
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:367:    contractor: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:368:    client: R              # reads client billing details
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:369:    contact: R             # reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:370:    brief: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:371:    opportunity: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:372:    placement: R           # reads for client linkage on invoice
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:373:    timesheet: R           # reads to verify billable hours match invoiced amounts
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:374:    voice_corpus: R        # chase-email voice grounding
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:375:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:376:    tone_rule: R           # v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:377:    recent_edit: W         # writes its own chase-draft edits for retraining
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:382:    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:386:    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:387:    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:388:    client: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:389:    contact: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    brief: R               # reads to filter candidates
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:391:    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:392:    placement: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    timesheet: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:394:    voice_corpus: R        # rationale-narrative voice grounding
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:395:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:396:    tone_rule: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:397:    recent_edit: W         # writes rationale-narrative edits for retraining
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:400:    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:401:    contractor: R+W        # writes lifecycle states for contractor placements too
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:402:    client: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:    contact: R             # reads for outbound recipient resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:    brief: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:405:    opportunity: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:406:    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:407:    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:408:    voice_corpus: R        # lifecycle-comms voice grounding
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:409:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:410:    tone_rule: R           # v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:411:    recent_edit: R         # v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:613:    - v0.2 migration applied (voice_corpus + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:24:status: Proposed
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:53:entities:
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:303:  contact:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:311:  brief:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:319:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:
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
docs/verticals/recruitment/vertical-schema.yaml:19:status: Proposed
docs/verticals/recruitment/vertical-schema.yaml:45:entities:
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:153:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
docs/verticals/recruitment/vertical-schema.yaml:221:  client:
docs/verticals/recruitment/vertical-schema.yaml:283:  contact:
docs/verticals/recruitment/vertical-schema.yaml:331:      do_not_contact:
docs/verticals/recruitment/vertical-schema.yaml:341:  brief:
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:471:      candidate_salary_at_placement:
docs/verticals/recruitment/vertical-schema.yaml:495:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:535:  timesheet:
docs/verticals/recruitment/vertical-schema.yaml:557:      approved_by_client:
docs/verticals/recruitment/vertical-schema.yaml:561:      approved_by_contractor:
docs/verticals/recruitment/vertical-schema.yaml:583:relationships:
docs/verticals/recruitment/vertical-schema.yaml:594:  placement_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:601:  brief_from_client:
docs/verticals/recruitment/vertical-schema.yaml:618:  contact_works_for_client:
docs/verticals/recruitment/vertical-schema.yaml:625:  candidate_engaged_with_contact:
docs/verticals/recruitment/vertical-schema.yaml:632:  candidate_referred_by_contact:
docs/verticals/recruitment/vertical-schema.yaml:639:  opportunity_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:654:  timesheet_for_placement:
docs/verticals/recruitment/vertical-schema.yaml:669:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:673:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:675:    contact: none
docs/verticals/recruitment/vertical-schema.yaml:676:    brief: none
docs/verticals/recruitment/vertical-schema.yaml:677:    placement: none
docs/verticals/recruitment/vertical-schema.yaml:678:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:679:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:684:    contractor: R+W  # status normalisation
docs/verticals/recruitment/vertical-schema.yaml:685:    client: R+W      # orphan-link sweep + normalisation
docs/verticals/recruitment/vertical-schema.yaml:686:    contact: R       # read-only (Concierge owns writes)
docs/verticals/recruitment/vertical-schema.yaml:687:    brief: R         # status drift sweep
docs/verticals/recruitment/vertical-schema.yaml:688:    placement: R     # orphan / stale-tag sweep
docs/verticals/recruitment/vertical-schema.yaml:689:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:690:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
docs/verticals/recruitment/vertical-schema.yaml:694:    contractor: R+W  # contractor calls same pattern
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:696:    contact: none
docs/verticals/recruitment/vertical-schema.yaml:697:    brief: R         # write-context resolution
docs/verticals/recruitment/vertical-schema.yaml:698:    placement: R+W   # note links on placed-candidate calls
docs/verticals/recruitment/vertical-schema.yaml:699:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:700:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:704:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:705:    client: none
docs/verticals/recruitment/vertical-schema.yaml:706:    contact: none
docs/verticals/recruitment/vertical-schema.yaml:707:    brief: none
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
docs/verticals/recruitment/vertical-schema.yaml:709:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:710:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:714:    contractor: R    # contractor pool
docs/verticals/recruitment/vertical-schema.yaml:715:    client: R        # target-firm context
docs/verticals/recruitment/vertical-schema.yaml:716:    contact: none    # thin v1.0
docs/verticals/recruitment/vertical-schema.yaml:717:    brief: R         # active brief context for matching
docs/verticals/recruitment/vertical-schema.yaml:718:    placement: none
docs/verticals/recruitment/vertical-schema.yaml:719:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:720:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:724:    contractor: R+W  # lifecycle state, contractor-specific cadence
docs/verticals/recruitment/vertical-schema.yaml:725:    client: R        # relationship context
docs/verticals/recruitment/vertical-schema.yaml:726:    contact: R       # decision-maker resolution for orange-tier sends
docs/verticals/recruitment/vertical-schema.yaml:727:    brief: R         # linked-brief context
docs/verticals/recruitment/vertical-schema.yaml:728:    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
docs/verticals/recruitment/vertical-schema.yaml:729:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:730:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:739:bullhorn_mapping:
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:754:  client:
docs/verticals/recruitment/vertical-schema.yaml:760:  contact:
docs/verticals/recruitment/vertical-schema.yaml:765:  brief:
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:777:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:783:  timesheet:
docs/verticals/recruitment/vertical-schema.yaml:844:  Q9_multi_client_contact:

codex
The supplement exists locally with both referenced migrations. I’m checking whether the migration actually enforces the declared JSONB shapes, auxiliary table rules, and rollback behavior.
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
/bin/zsh -lc 'rg -n "CREATE TABLE|cash_conductor_transactions|cash_conductor_invoices|match_confidence|GRANT|POLICY|validate_entities_data_v0_3|validate_tenant_adapters_config_v0_3|unknown|employment_type|key_skills|linkedin_url|preferred_channel|next_action_target_date|must_haves|nice_to_haves|deal_breakers|placement_status|week_1_status_vault_path|satisfaction_signal|headcount_growth_signal_text|hiring_velocity_band|decision_window_text|DROP TABLE|DROP FUNCTION" docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:58:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:70:  match_confidence   NUMERIC(3, 2),
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:81:  CONSTRAINT cct_match_confidence_range CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:82:    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:207:    IF d ? 'employment_type' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:208:      IF (d->>'employment_type') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:211:        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:215:    IF d ? 'key_skills' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:216:      IF jsonb_typeof(d->'key_skills') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:217:        RAISE EXCEPTION 'key_skills must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:219:      IF jsonb_array_length(d->'key_skills') > 20 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:220:        RAISE EXCEPTION 'key_skills max length 20 (got %)', jsonb_array_length(d->'key_skills');
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:223:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'key_skills') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:225:          RAISE EXCEPTION 'key_skills items must be strings; got %', jsonb_typeof(arr_item);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:230:    IF d ? 'linkedin_url' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:231:      IF jsonb_typeof(d->'linkedin_url') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:232:        RAISE EXCEPTION 'linkedin_url must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:234:      IF d->>'linkedin_url' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:235:         AND d->>'linkedin_url' !~ '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:236:        RAISE EXCEPTION 'linkedin_url does not match expected pattern: %', d->>'linkedin_url';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:243:    IF d ? 'preferred_channel' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:244:      IF (d->>'preferred_channel') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:245:        'email', 'phone', 'sms', 'teams', 'slack', 'in_person', 'unknown'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:247:        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:251:    IF d ? 'next_action_target_date' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:252:      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:253:        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:260:    IF d ? 'must_haves' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:261:      IF jsonb_typeof(d->'must_haves') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:262:        RAISE EXCEPTION 'must_haves must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:264:      IF jsonb_array_length(d->'must_haves') > 15 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:265:        RAISE EXCEPTION 'must_haves max length 15';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:267:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:269:          RAISE EXCEPTION 'must_haves items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:274:    IF d ? 'nice_to_haves' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:275:      IF jsonb_typeof(d->'nice_to_haves') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:276:        RAISE EXCEPTION 'nice_to_haves must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:278:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'nice_to_haves') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:280:          RAISE EXCEPTION 'nice_to_haves items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:285:    IF d ? 'deal_breakers' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:286:      IF jsonb_typeof(d->'deal_breakers') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:287:        RAISE EXCEPTION 'deal_breakers must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:289:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:291:          RAISE EXCEPTION 'deal_breakers items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:299:    IF d ? 'placement_status' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:300:      IF (d->>'placement_status') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:303:        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:307:    IF d ? 'week_1_status_vault_path' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:308:      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:309:        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:311:      IF d->>'week_1_status_vault_path' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:312:         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9-]+/scribe-notes/[a-zA-Z0-9-]+\.md$' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:313:        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:315:      IF d->>'week_1_status_vault_path' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:316:         AND length(d->>'week_1_status_vault_path') > 200 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:317:        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:321:    IF d ? 'satisfaction_signal' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:322:      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:323:        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:330:    IF d ? 'headcount_growth_signal_text' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:331:      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:332:        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:334:      IF d->>'headcount_growth_signal_text' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:335:         AND length(d->>'headcount_growth_signal_text') > 280 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:336:        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:340:    IF d ? 'hiring_velocity_band' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:341:      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:342:        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:346:    IF d ? 'decision_window_text' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:347:      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:348:        RAISE EXCEPTION 'decision_window_text must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:350:      IF d->>'decision_window_text' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:351:         AND length(d->>'decision_window_text') > 280 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:352:        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:363:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:365:CREATE TRIGGER validate_entities_data_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:368:  EXECUTE FUNCTION validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:375:-- only the documented keys are stored (hard-fail on unknown keys per Rule 2
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:378:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:403:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:452:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:454:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:457:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:469:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:471:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:475:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:477:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:480:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';

exec
/bin/zsh -lc "sed -n '1,160p' docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql" in /Users/madsadmin/code/CortexOS
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
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validate_voice_score_fields') THEN
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

exec
/bin/zsh -lc "sed -n '260,470p' docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
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

    IF d ? 'week_1_status_vault_path' THEN
      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
      END IF;
      IF d->>'week_1_status_vault_path' IS NOT NULL
         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9-]+/scribe-notes/[a-zA-Z0-9-]+\.md$' THEN
        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
      END IF;
      IF d->>'week_1_status_vault_path' IS NOT NULL
         AND length(d->>'week_1_status_vault_path') > 200 THEN
        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
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

exec
/bin/zsh -lc "sed -n '45,220p' docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "sed -n '660,790p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
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

codex
One concrete inconsistency is emerging in the migration comments versus the supplement around `decision_log.payload`. I’m also checking whether the YAML itself parses and whether all matrices line up with the inherited v0.1/v0.2 entity set.
exec
/bin/zsh -lc 'rg -n "CREATE POLICY|WITH CHECK|FOR ALL TO ifos_app|tenant_slug = current_setting" docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/*.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:72:CREATE POLICY voice_corpus_tenant_isolation ON voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:73:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:106:CREATE POLICY voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:107:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:134:CREATE POLICY tone_rule_tenant_isolation ON tone_rule
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:135:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:167:CREATE POLICY recent_edit_tenant_isolation ON recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:168:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:98:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:99:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:100:  USING (tenant_slug = current_setting('app.current_tenant', true));
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:157:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:158:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:159:  USING (tenant_slug = current_setting('app.current_tenant', true));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:72:CREATE POLICY voice_corpus_tenant_isolation ON voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:73:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:106:CREATE POLICY voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:107:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:134:CREATE POLICY tone_rule_tenant_isolation ON tone_rule
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:135:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:167:CREATE POLICY recent_edit_tenant_isolation ON recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:168:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:98:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:99:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:100:  USING (tenant_slug = current_setting('app.current_tenant', true));
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:157:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:158:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:159:  USING (tenant_slug = current_setting('app.current_tenant', true));

exec
/bin/zsh -lc "rg -n \"decision_log\\.payload|payload extension|per_claim_confidence_distribution|decision_log_payload_extension|new decision_log.payload|autosend-safety-policy.md.*§7\" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/autosend-safety-policy.md docs/decisions/ADR-006* 2>/dev/null" in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:17:--   - decision_log.payload extension is documented in autosend-safety-policy.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:120:- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:581:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:584:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:585:  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:586:  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:  per_claim_confidence_distribution payload key originally planned for

exec
/bin/zsh -lc "ruby -e 'require \"yaml\"; p YAML.load_file(\"docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml\").keys'" in /Users/madsadmin/code/CortexOS
 succeeded in 191ms:
["vertical", "version", "supplements", "status", "date", "author", "codex_ratification_queue_position", "entity_field_additions", "agent_access_matrix", "auxiliary_tables", "auxiliary_table_access_matrix", "tenant_adapters_config_additions", "decision_log_payload_extension", "migration_sequence", "codex_ratification", "open_questions", "rationale", "end_of_supplement"]

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '175,205p;300,415p;580,600p;735,765p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,25p;300,320p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '189,215p'" in /Users/madsadmin/code/CortexOS
 succeeded in 110ms:
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
   300	      IF (d->>'placement_status') NOT IN (
   301	        'pending_start', 'active', 'completed', 'terminated_early', 'on_hold', 'cancelled'
   302	      ) THEN
   303	        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
   304	      END IF;
   305	    END IF;
   306	
   307	    IF d ? 'week_1_status_vault_path' THEN
   308	      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
   309	        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
   310	      END IF;
   311	      IF d->>'week_1_status_vault_path' IS NOT NULL
   312	         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9-]+/scribe-notes/[a-zA-Z0-9-]+\.md$' THEN
   313	        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
   314	      END IF;
   315	      IF d->>'week_1_status_vault_path' IS NOT NULL
   316	         AND length(d->>'week_1_status_vault_path') > 200 THEN
   317	        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
   318	      END IF;
   319	    END IF;
   320	

 succeeded in 102ms:
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

 succeeded in 110ms:
   175	
   176	      week_1_status_vault_path:
   177	        type: string
   178	        max_length: 200
   179	        pattern: '^/vault/[a-z0-9-]+/scribe-notes/[a-zA-Z0-9-]+\.md$'
   180	        required: false
   181	        notes: |
   182	          POINTER ONLY (per ADR-002 vault/Postgres split). The 7d check-in
   183	          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
   184	          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
   185	          This field stores the vault path; narrative does NOT enter
   186	          Postgres. Voice-classifier review at write time applies to the
   187	          vault file content; Concierge reads the vault file directly via
   188	          its path resolution.
   189	        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
   190	          to vault then stores pointer here)
   191	        v1_0_agent_access:
   192	          - Scribe: R+W
   193	          - Concierge: R
   194	
   195	      satisfaction_signal:
   196	        type: string
   197	        enum: [positive, neutral, negative, unclear]
   198	        default: unclear
   199	        required: false
   200	        notes: |
   201	          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
   202	          Concierge reads to adjust nurture tone.
   203	        source: IFOS-derived (Scribe LLM extraction)
   204	        v1_0_agent_access:
   205	          - Scribe: R+W
   300	
   301	agent_access_matrix:
   302	
   303	  # Disposition tokens: R | W | R+W | none
   304	  #
   305	  # ENTITY-LEVEL vs FIELD-LEVEL ACCESS:
   306	  # The matrix below is ENTITY-LEVEL — declares the maximum disposition an
   307	  # agent may have on any field of that entity. Per-field access (in §1
   308	  # entity_field_additions[*].v1_0_agent_access) NARROWS the entity-level
   309	  # disposition. Example: Scribe.candidate: R+W at entity level; per-field
   310	  # candidate.employment_type grants Scribe: W (because Scribe doesn't read
   311	  # employment_type, just writes it). This is intentional — the entity-level
   312	  # token is the ceiling; field-level may be narrower but never broader.
   313	  #
   314	  # Validation: the validate_entities_data_v0_3 trigger validates FIELD
   315	  # SHAPE only (type checks, enum membership, length caps, array element
   316	  # types). It does NOT enforce which agent is writing — agent-level
   317	  # write permission is DOCUMENTARY in v0.3, enforced at the application
   318	  # layer (cycle.sh + hh_decision_action) where the agent_name in the
   319	  # decision_log row records who wrote. Entity-level RLS enforces TENANT
   320	  # isolation but not agent-level access. Column-level RLS or per-agent
   321	  # database roles would be the v1.1+ enforcement layer; v0.3 is documentary.
   322	
   323	  diagnostic:
   324	    candidate: R           # reads for outreach context (§11 decision-maker map)
   325	    contractor: none       # not in scope at v1.0
   326	    client: R              # reads via Companies House lookup (entity-shape if cached)
   327	    contact: R             # reads for §11 decision-maker map
   328	    brief: none            # diagnostic is sales-tool not brief-driven
   329	    opportunity: R         # may read prospect-firm opportunity if exists
   330	    placement: none
   331	    timesheet: none
   332	    voice_corpus: R
   333	    voice_corpus_chunks: R
   334	    tone_rule: R
   335	    recent_edit: none
   336	
   337	  janitor:
   338	    candidate: R+W         # dedup + field-backfill writes
   339	    contractor: R+W        # dedup + field-backfill writes
   340	    client: R+W            # Companies House enrichment writes
   341	    contact: R+W           # dedup + field-backfill writes
   342	    brief: R               # context for related candidate cleanup
   343	    opportunity: R
   344	    placement: R+W         # lifecycle-state cleanup
   345	    timesheet: R           # reads for placement-state inference
   346	    voice_corpus: R        # tacit-note narrative voice grounding
   347	    voice_corpus_chunks: R
   348	    tone_rule: R           # v0.3 NEW (was no access)
   349	    recent_edit: R         # v0.3 NEW (was Concierge/canary/LoRA only); for tacit-note harvest
   350	
   351	  scribe:
   352	    candidate: R+W         # call-summary field extraction
   353	    contractor: R+W        # call-summary field extraction
   354	    client: R
   355	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
   356	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
   357	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
   358	    placement: R+W         # check-in field extraction
   359	    timesheet: R           # reads for placement-context resolution on check-in calls
   360	    voice_corpus: R        # tacit-note voice grounding
   361	    voice_corpus_chunks: R
   362	    tone_rule: R           # v0.2
   363	    recent_edit: W         # writes its own edits for retraining
   364	
   365	  cash_conductor:
   366	    candidate: none        # no Bullhorn dependency
   367	    contractor: none
   368	    client: R              # reads client billing details
   369	    contact: R             # reads for invoice addressee resolution
   370	    brief: none
   371	    opportunity: none
   372	    placement: R           # reads for client linkage on invoice
   373	    timesheet: R           # reads to verify billable hours match invoiced amounts
   374	    voice_corpus: R        # chase-email voice grounding
   375	    voice_corpus_chunks: R
   376	    tone_rule: R           # v0.2
   377	    recent_edit: W         # writes its own chase-draft edits for retraining
   378	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   379	
   380	  sourcing_scout:
   381	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   382	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   383	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   384	    # writes its proposed-candidate rows + reads opportunity context. These
   385	    # are entity-level access overrides codified here.
   386	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   387	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   388	    client: R
   389	    contact: R
   390	    brief: R               # reads to filter candidates
   391	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   392	    placement: none
   393	    timesheet: none
   394	    voice_corpus: R        # rationale-narrative voice grounding
   395	    voice_corpus_chunks: R
   396	    tone_rule: R
   397	    recent_edit: W         # writes rationale-narrative edits for retraining
   398	
   399	  concierge:
   400	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   401	    contractor: R+W        # writes lifecycle states for contractor placements too
   402	    client: R
   403	    contact: R             # reads for outbound recipient resolution
   404	    brief: R
   405	    opportunity: R
   406	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   407	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   408	    voice_corpus: R        # lifecycle-comms voice grounding
   409	    voice_corpus_chunks: R
   410	    tone_rule: R           # v0.2
   411	    recent_edit: R         # v0.2
   412	
   413	# ============================================================================
   414	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   415	# ============================================================================
   580	# ============================================================================
   581	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   582	# ============================================================================
   583	
   584	decision_log_payload_extension:
   585	  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
   586	  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
   587	  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
   588	  # that ships alongside Tier 2 activation. v0.3 introducing the payload
   589	  # key without enforcement would violate review-schema-change §3
   590	  # (bounded values require CHECK or trigger). Tier 2 schema work owns
   591	  # the constraint + writer; this v0.3 supplement is silent on it.
   592	  deferred_to_future_adr:
   593	    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
   594	    schema_owner: future W4-polish supplement (not v0.3)
   595	    rationale: |
   596	      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
   597	      separate post-launch quality metric outside Gate A. The payload key,
   598	      its [0.0, 1.0] range validation, and the sample-rate config field
   599	      all land together with Tier 2 activation. Tier 2 doesn't activate
   600	      until the voice classifier microservice ships + first pilot tenant
   735	
   736	rationale: |
   737	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   738	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   739	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   740	  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys. The
   741	  per_claim_confidence_distribution payload key originally planned for
   742	  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
   743	  §5 of this supplement); v0.3 is silent on payload schema extensions.
   744	
   745	  After v0.3 ratifies + migration applies:
   746	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   747	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   748	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   749	      placement_status, week_1_status_vault_path, satisfaction_signal,
   750	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   751	      are now schema-backed. (Note: week_1_status_note narrative now lives
   752	      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
   753	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   754	      seniority — not yet in schema; brief.start_date should be
   755	      start_date_target; opportunity.sector — not yet in schema). These
   756	      residual gaps are tracked in W4-polish-schema-extension backlog;
   757	      they do not block v0.3 ratification but do require a Scribe agent.md
   758	      consistency-pass before Scribe ratifies.
   759	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   760	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   761	    - Concierge tenant_adapters.config field refs valid
   762	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   763	
   764	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   765	  ~3-5 residual mechanical findings per agent (down from current 4-6) —

codex
REJECTED

1. `week_1_status_vault_path` rejects the canonical path shape it documents. Lines 179 and 183-184 conflict: the regex only allows `[a-zA-Z0-9-]+.md`, but the documented canonical filename is `<call_id>-<ISO-date>.md`, which requires additional hyphens and likely date separators. The companion migration enforces the same bad regex at `v0.2-to-v0.3.sql` lines 311-313. Fix the YAML and SQL regex to accept the canonical Scribe vault filename, or change the documented canonical path.

2. The v0.3 access matrix changes v0.2 auxiliary entity access without updating the entity definitions. Lines 348-349, 363, 377, and 397 add `tone_rule`/`recent_edit` access for Janitor, Scribe, Cash Conductor, and Sourcing Scout, but `vertical-schema.v0.2-supplement.yaml` lines 193-196 still define `recent_edit.v1_0_agent_access` as only voice-drift-canary, Concierge, and LoRA. This violates the schema-change requirement that entity `v1_0_agent_access` match the matrix. Add explicit v0.3 amendments for the affected v0.2 entities or keep the matrix aligned with v0.2.

3. The supplement and companion migration contradict each other on `decision_log.payload`. Lines 584-591 state v0.3 introduces no new `decision_log.payload` key and defers `per_claim_confidence_distribution`, but `migrations/v0.2-to-v0.3.sql` lines 17-19 claim a `decision_log.payload` extension is documented and validated. This is an honest-signal failure and leaves implementers unsure whether the payload key is schema-backed. Update the migration header to match the deferral, or add the payload schema plus enforcement in this supplement/migration pair.
tokens used
56,589
REJECTED

1. `week_1_status_vault_path` rejects the canonical path shape it documents. Lines 179 and 183-184 conflict: the regex only allows `[a-zA-Z0-9-]+.md`, but the documented canonical filename is `<call_id>-<ISO-date>.md`, which requires additional hyphens and likely date separators. The companion migration enforces the same bad regex at `v0.2-to-v0.3.sql` lines 311-313. Fix the YAML and SQL regex to accept the canonical Scribe vault filename, or change the documented canonical path.

2. The v0.3 access matrix changes v0.2 auxiliary entity access without updating the entity definitions. Lines 348-349, 363, 377, and 397 add `tone_rule`/`recent_edit` access for Janitor, Scribe, Cash Conductor, and Sourcing Scout, but `vertical-schema.v0.2-supplement.yaml` lines 193-196 still define `recent_edit.v1_0_agent_access` as only voice-drift-canary, Concierge, and LoRA. This violates the schema-change requirement that entity `v1_0_agent_access` match the matrix. Add explicit v0.3 amendments for the affected v0.2 entities or keep the matrix aligned with v0.2.

3. The supplement and companion migration contradict each other on `decision_log.payload`. Lines 584-591 state v0.3 introduces no new `decision_log.payload` key and defers `per_claim_confidence_distribution`, but `migrations/v0.2-to-v0.3.sql` lines 17-19 claim a `decision_log.payload` extension is documented and validated. This is an honest-signal failure and leaves implementers unsure whether the payload key is schema-backed. Update the migration header to match the deferral, or add the payload schema plus enforcement in this supplement/migration pair.
