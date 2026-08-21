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
session id: 019e5a58-8c98-7bf2-8303-d15d20639ef8
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
# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
# Concierge schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
# Phase 4 Cat-β section. Closes the v0.3-scoped subset (14 entity JSONB keys + 2
# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
# its §3 narrative with canonical v0.1/v0.2/v0.3 field names (current_role vs
# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
# v0.3 ratification does not block on it.
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
        pattern: '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$'
        required: false
        notes: |
          POINTER ONLY (per ADR-002 vault/Postgres split). The 7d check-in
          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
          Pattern accepts call_ids + ISO dates (hyphens + underscores +
          alphanumerics). This field stores the vault path; narrative does
          NOT enter Postgres. Voice-classifier review at write time applies
          to the vault file content; Concierge reads the vault file directly
          via its path resolution.
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
  # SCOPE: This matrix is rectangular across `entities:` entity_types ONLY
  # (candidate, contractor, client, contact, brief, opportunity, placement,
  # timesheet — 8 v0.1 entity_types).
  #
  # SCHEMA-LAYERING CORRECTION: The v0.2 supplement uses the YAML key
  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
  # voice_corpus_chunks is introduced separately around v0.2 supplement line
  # 270 as the pgvector auxiliary table — it was always auxiliary, never
  # under `entities:`. v0.2 supplement §1 "LAYERING DISCLOSURE" states the
  # three `entities:`-keyed objects "are auxiliary Postgres tables (real
  # CREATE TABLE statements in migrations/v0.1-to-v0.2.sql), NOT entity_types
  # in the entities/entity_links generic primitive layer from Day-4 §6.3."
  # v0.3 adopts this disclosure as the authoritative classification: all
  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
  # AUXILIARY, NOT entities. Their access lives in
  # `auxiliary_table_access_matrix` below + §2a access amendments — NOT in
  # this entity matrix. The v0.2 YAML key `entities:` was documentation
  # convention; v0.3 reclassifies per the v0.2 LAYERING DISCLOSURE intent.
  #
  # ENTITY-LEVEL vs FIELD-LEVEL ACCESS:
  # The matrix below is ENTITY-LEVEL — declares the maximum disposition an
  # agent may have on any field of that entity.
  #
  # FIELD_ACCESS_NARROWING_RULE (v0.3 explicit scope rule, ratified as part
  # of this supplement):
  #   Per-field access (in §1 entity_field_additions[*].v1_0_agent_access)
  #   NARROWS the entity-level disposition. The entity-level token is the
  #   CEILING; field-level may be narrower (or absent — implying the agent
  #   has the entity-level default) but NEVER BROADER than the matrix entry.
  #   Example: Scribe.candidate: R+W at entity level; per-field
  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
  #   without reading it). Another example: Diagnostic.candidate: R at entity
  #   level; candidate.linkedin_url has no Diagnostic field entry; Diagnostic
  #   gets R on linkedin_url (entity-level default), not the broader Sourcing
  #   Scout R+W. Implementation: cycle.sh + hh_decision_action records which
  #   agent + which fields were touched in decision_log payload; reviewers
  #   audit via that trail. v0.3 does NOT enforce this rule at the database
  #   layer (column-level RLS would be required; v1.1+ work per the
  #   "documentary not enforced" note above).
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

  janitor:
    candidate: R+W         # dedup + field-backfill writes
    contractor: R+W        # dedup + field-backfill writes
    client: R+W            # Companies House enrichment writes
    contact: R+W           # dedup + field-backfill writes
    brief: R               # context for related candidate cleanup
    opportunity: R
    placement: R+W         # lifecycle-state cleanup
    timesheet: R           # reads for placement-state inference

  scribe:
    # Scribe's Bullhorn endpoint access (Candidate / ClientCorporation /
    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
    # row A3. opportunity + timesheet access below is to IFOS-cached
    # Postgres rows ONLY (not direct Bullhorn endpoint calls). Scribe
    # uses Bullhorn endpoints for the 5 v1.0-supported entities; other
    # entity access in this matrix is via Postgres cache.
    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
    client: R              # IFOS-cached read (Bullhorn endpoint A3 — ClientCorporation)
    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields written to IFOS-cached Postgres rows only (Bullhorn Opportunity endpoint NOT used at v1.0 per integration-path §4.1)
    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
    timesheet: R           # IFOS-cached read; placement-context resolution (Bullhorn Timesheet endpoint NOT used at v1.0)

  cash_conductor:
    # NOTE: Cash Conductor has NO direct Bullhorn endpoint access per
    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
    # entity reads below are against IFOS-cached Postgres rows
    # (populated by Janitor + Scribe + Concierge from their Bullhorn
    # sync paths). Cash Conductor never calls Bullhorn endpoints directly.
    candidate: none        # no Bullhorn dependency
    contractor: none
    client: R              # IFOS-cached read; client billing details
    contact: R             # IFOS-cached read; invoice addressee resolution
    brief: none
    opportunity: R         # v0.3 NEW — IFOS-cached read; invoice-context (NOT a direct Bullhorn call; only cached rows)
    placement: R           # IFOS-cached read; client linkage on invoice
    timesheet: R           # IFOS-cached read; verify billable hours match invoice (NOT a direct Bullhorn call)
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

  concierge:
    # Concierge's Bullhorn endpoint access (Candidate / ClientCorporation /
    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
    # row A6. opportunity + timesheet access below is IFOS-cached Postgres
    # only (not Bullhorn endpoint calls).
    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
    client: R              # IFOS-cached read (Bullhorn endpoint A6 — ClientCorporation)
    contact: R             # IFOS-cached read; outbound recipient resolution (Bullhorn endpoint A6 — Note context)
    brief: R               # IFOS-cached read (Bullhorn endpoint A6 — JobOrder)
    opportunity: R         # IFOS-cached read; outbound lifecycle-event context (Bullhorn Opportunity endpoint NOT used at v1.0)
    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14 (Bullhorn endpoint A6)
    timesheet: R           # IFOS-cached read; placement-progress for 7d/30d/90d nurture (Bullhorn Timesheet endpoint NOT used at v1.0)

# ============================================================================
# §2a — v0.2 entity v1_0_agent_access amendments
# ============================================================================
#
# Per review-schema-change §5: matrix changes must be reflected in entity-level
# v1_0_agent_access lists. v0.3 amends these v0.2 entities:

v0_1_entity_access_amendments:
  # Per review-schema-change §5: matrix changes to v0.1 entity-level access
  # must be reflected in explicit amendments. Each entry below documents the
  # v0.1 baseline → v0.3 expanded access list. The base vertical-schema.yaml
  # is NOT edited; this supplement is the authoritative source for v0.3
  # entity access state.

  client:
    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
    v0_3_v1_0_agent_access:
      - Diagnostic (R)     # v0.3 NEW — reads Companies House data for sales-tool context
      - Janitor (R+W)      # v0.1 unchanged
      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
      - Sourcing Scout (R) # v0.1 unchanged
      - Concierge (R)      # v0.1 unchanged
    rationale: |
      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
      client billing/context for their respective workflows). No new W access.

  contact:
    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
    v0_3_v1_0_agent_access:
      - Diagnostic (R)     # v0.3 NEW — reads §11 decision-maker map context
      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
      - Sourcing Scout (R) # v0.1 unchanged
      - Concierge (R)      # v0.1 unchanged
    rationale: |
      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
      preferred_channel + next_action_target_date; Janitor also dedup-merges).
      Diagnostic + Cash Conductor gain R for context.

  brief:
    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
    v0_3_v1_0_agent_access:
      - Janitor (R)        # v0.1 unchanged
      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
      - Sourcing Scout (R) # v0.1 unchanged
      - Concierge (R)      # v0.1 unchanged
    rationale: |
      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
      for Scribe.

  opportunity:
    v0_1_v1_0_agent_access: [Janitor (R)]
    v0_3_v1_0_agent_access:
      - Diagnostic (R)     # v0.3 NEW — reads prospect-firm opportunity if exists
      - Janitor (R)        # v0.1 unchanged
      - Scribe (R+W)       # v0.3 NEW — writes 3 new prospecting-call fields
      - Cash Conductor (R) # v0.3 NEW — reads for invoice context
      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
      - Concierge (R)      # v0.3 NEW — reads for outbound lifecycle context
    rationale: |
      v0.1 opportunity is sparsely accessed (Janitor only); v0.3 broadens
      to all v1.0 agents because the entity gains 3 new fields used across
      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
      timing), Diagnostic + Cash Conductor (reads for context).

  placement:
    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
    v0_3_v1_0_agent_access:
      - Janitor (R+W)      # v0.3 UPGRADED — lifecycle-state cleanup writes
      - Scribe (R+W)       # v0.3 NEW — check-in field extraction
      - Cash Conductor (R) # v0.1 unchanged
      - Concierge (R+W)    # v0.3 UPGRADED — writes Bullhorn state advancement
    rationale: |
      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
      their §4 specs); adds Scribe R+W for check-in writes.

  timesheet:
    v0_1_v1_0_agent_access: [Cash Conductor (R)]
    v0_3_v1_0_agent_access:
      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
      - Cash Conductor (R) # v0.1 unchanged
      - Concierge (R)      # v0.3 NEW — reads to verify placement-progress for nurture
    rationale: |
      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
      Scribe + Concierge (each reads timesheet for their respective
      placement-related workflows).

  candidate:
    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
    v0_3_v1_0_agent_access:
      - Diagnostic (R)     # v0.3 NEW — reads for outreach context (§11 decision-maker map)
      - Janitor (R+W)      # v0.1 unchanged
      - Scribe (R+W)       # v0.1 unchanged
      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
      - Concierge (R+W)    # v0.3 UPGRADED — writes lifecycle-state-derived fields
    rationale: |
      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
      multi-source aggregation) + Concierge (writes lifecycle-state and
      activity-log links per §4 Steps 13-14). Diagnostic gains R for context.

  contractor:
    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
    v0_3_v1_0_agent_access:
      - Janitor (R+W)      # v0.1 unchanged
      - Scribe (R+W)       # v0.1 unchanged
      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
    rationale: |
      Parallel upgrades to candidate; contractor entities follow the same
      v0.3 write patterns where applicable.

v0_2_entity_access_amendments:

  voice_corpus:
    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
    rationale: |
      All v1.0 agents that produce voice-classified output (Diagnostic for
      §12 conversation opener; Janitor for tacit-note narratives; Cash
      Conductor for chase drafts; Sourcing Scout for per-candidate
      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
      granted Scribe + Concierge; v0.3 extends to all 6.

  tone_rule:
    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
    rationale: |
      Janitor agent.md §7 calls hh_load_tone_rules filtered by
      applies_to_agents containing 'janitor' for tacit-note narrative
      voice-classification. Per Round-8 Cat-β finding for Janitor.
      Diagnostic + Sourcing Scout also read tone_rules for their
      voice-classified outputs (§12 opener, per-candidate rationale).

  recent_edit:
    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
    v0_3_v1_0_agent_access:
      - voice-drift-canary (W)  # v0.2 unchanged
      - Concierge (R)            # v0.2 unchanged
      - LoRA (R)                 # v0.2 unchanged
      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
    rationale: |
      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
      for retraining queue). Janitor adds R for tacit-note harvest per
      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
      supplement is the authoritative source for the expanded access list.

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
      id: {type: integer, required: true, source: IFOS-internal, notes: BIGSERIAL primary key in SQL}
      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
      posted_at: {type: timestamp, required: true, source: Open Banking provider}
      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}
      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
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
      id: {type: integer, required: true, source: IFOS-internal}
      tenant_slug: {type: string, required: true, source: IFOS-internal}
      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
      invoice_number: {type: string, required: false, source: Accounting provider}
      issued_at: {type: timestamp, required: true, source: Accounting provider}
      due_at: {type: timestamp, required: true, source: Accounting provider}
      amount_total: {type: number, required: true, source: Accounting provider, notes: NUMERIC(15,2) GBP}
      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
      currency: {type: string, required: true, default: GBP, source: Accounting provider}
      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open, source: Accounting provider}
      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
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
  voice_corpus:
    # v0.2 auxiliary table — voice exemplar corpus (per-tenant)
    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents that
    # produce voice-classified output
    diagnostic: R
    janitor: R
    scribe: R
    cash_conductor: R
    sourcing_scout: R
    concierge: R
  voice_corpus_chunks:
    # v0.2 auxiliary table holding pgvector HNSW index over voice corpus chunks
    # All v1.0 agents producing voice-classified output need R for ANN-match retrieval
    diagnostic: R
    janitor: R
    scribe: R
    cash_conductor: R
    sourcing_scout: R
    concierge: R
  tone_rule:
    # v0.2 auxiliary table — per-tenant tone constraints
    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents
    diagnostic: R
    janitor: R
    scribe: R
    cash_conductor: R
    sourcing_scout: R
    concierge: R
  recent_edit:
    # v0.2 auxiliary table — consultant edits for retraining/drift detection
    # Per §2a amendment: v0.3 expands access (Concierge R from v0.2;
    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
    # Scout add W to write own retraining edits; Diagnostic remains none)
    diagnostic: none
    janitor: R
    scribe: W
    cash_conductor: W
    sourcing_scout: W
    concierge: R
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
# §4 — tenant_adapters.config new keys (3 keys)
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

  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
  # declare this config key; the W4 ADR will introduce both the field
  # and its consumer at the same time. Including it in v0.3 without an
  # active consumer would be speculative schema.

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
    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
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
      hard-fails on unknown config keys (Rule 2); type-validates the 3 new
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
  adds 14 entity JSONB keys + 2 auxiliary tables + 3 config keys. The
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
I’m checking the supplement against the repository, especially the referenced migrations and prior schema layer, because this review hinges on whether the YAML’s claims are actually backed by files.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '260,620p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
     2	# ============================================================================
     3	# Status: Proposed (Codex Day-19 ratification queue addendum)
     4	# Date:   2026-05-24 (Day 19; post-Round-8 Cat-β unblock)
     5	# Author: Founder (Maddox) + Claude Code
     6	# Predecessor: docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
     7	#
     8	# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
     9	# Concierge schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
    10	# Phase 4 Cat-β section. Closes the v0.3-scoped subset (14 entity JSONB keys + 2
    11	# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
    12	# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
    13	# its §3 narrative with canonical v0.1/v0.2/v0.3 field names (current_role vs
    14	# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
    15	# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
    16	# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
    17	# v0.3 ratification does not block on it.
    18	#
    19	# Companion migrations: migrations/v0.2-to-v0.3.sql + migrations/v0.3-to-v0.2.sql
    20	#   Both files drafted at commit alongside this supplement.
    21	#
    22	# Field types: per `review-schema-change` skill §2 allowed types only —
    23	# string | integer | number | boolean | array | object | timestamp | date.
    24	# Enums expressed as `type: string` + `enum: [...]`. Lists as `type: array`
    25	# with `items.type`. SQL-level types (NUMERIC(15,2), TIMESTAMPTZ etc.) appear
    26	# only in the companion migration SQL, not here.
    27	#
    28	# Schema layering: entities.data is JSONB per Day-4 §6.3 generic primitive.
    29	# v0.3 entity-field additions are JSONB key shapes validated via the
    30	# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
    31	# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
    32	# tables — they're already JSONB-shaped.
    33	# ============================================================================
    34	
    35	vertical: recruitment
    36	version: v0.3
    37	supplements: v0.2
    38	status: Proposed
    39	date: 2026-05-24
    40	author: founder (Maddox) + Claude Code; bilateral Cat-β unblock
    41	codex_ratification_queue_position: 44
    42	
    43	# ============================================================================
    44	# §1 — New entity.data JSONB key shapes (14 across 5 entities)
    45	# ============================================================================
    46	#
    47	# All additions land as JSONB keys on the existing entities.data column
    48	# (Day-4 §6.3 generic primitive layer). Validation lives in
    49	# validate_entities_data_v0_3() trigger function (migration §4).
    50	
    51	entity_field_additions:
    52	
    53	  candidate:
    54	    v0_3_new_keys:
    55	      employment_type:
    56	        type: string
    57	        enum: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
    58	        required: false
    59	        notes: |
    60	          Candidate's preferred engagement model (distinct from role type).
    61	          IR35 distinction matters for UK contractors. Extracted by Scribe
    62	          from call context.
    63	        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
    64	        v1_0_agent_access:
    65	          - Scribe: W
    66	          - Sourcing Scout: R
    67	
    68	      key_skills:
    69	        type: array
    70	        items:
    71	          type: string
    72	        max_items: 20
    73	        required: false
    74	        notes: |
    75	          Aggregated skill tags from CV + transcripts. Free-text strings;
    76	          W4 polish may add controlled-vocabulary clustering. Max 20 items
    77	          per candidate enforced by validate_entities_data_v0_3.
    78	        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
    79	        v1_0_agent_access:
    80	          - Scribe: W
    81	          - Sourcing Scout: R+W
    82	
    83	      linkedin_url:
    84	        type: string
    85	        pattern: '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
    86	        required: false
    87	        notes: |
    88	          LinkedIn profile URL. Pattern enforced by trigger. Set by Sourcing
    89	          Scout from match; Janitor uses for dedup (stronger match signal
    90	          than name+email); Concierge reads for outreach context (NOT for
    91	          outbound — outreach via candidate.email or candidate.phone only).
    92	        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
    93	        v1_0_agent_access:
    94	          - Sourcing Scout: R+W
    95	          - Janitor: R   # W only via dedup-merge action
    96	          - Concierge: R
    97	
    98	  contact:
    99	    v0_3_new_keys:
   100	      preferred_channel:
   101	        type: string
   102	        enum: [email, phone, sms, teams, slack, in_person, unknown]
   103	        default: unknown
   104	        required: false
   105	        notes: |
   106	          Contact's stated preference; extracted by Scribe from call context.
   107	          Concierge reads to route outbound lifecycle comms.
   108	        source: IFOS-derived (Scribe extraction)
   109	        v1_0_agent_access:
   110	          - Scribe: R+W
   111	          - Concierge: R
   112	
   113	      next_action_target_date:
   114	        type: date
   115	        required: false
   116	        notes: |
   117	          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
   118	          is in transcript. Concierge respects this when scheduling lifecycle
   119	          nurture.
   120	        source: IFOS-derived (Scribe extraction)
   121	        v1_0_agent_access:
   122	          - Scribe: R+W
   123	          - Concierge: R
   124	
   125	  brief:
   126	    v0_3_new_keys:
   127	      must_haves:
   128	        type: array
   129	        items:
   130	          type: string
   131	        max_items: 15
   132	        required: false
   133	        notes: |
   134	          Hard requirements; Sourcing Scout filters candidates against this
   135	          list. Free-text strings; max 15 items enforced by trigger.
   136	        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
   137	        v1_0_agent_access:
   138	          - Scribe: R+W
   139	          - Sourcing Scout: R
   140	
   141	      nice_to_haves:
   142	        type: array
   143	        items:
   144	          type: string
   145	        required: false
   146	        notes: |
   147	          Soft preferences; Sourcing Scout uses for ranking, not hard filter.
   148	        source: IFOS-derived (Scribe extracts)
   149	        v1_0_agent_access:
   150	          - Scribe: R+W
   151	          - Sourcing Scout: R
   152	
   153	      deal_breakers:
   154	        type: array
   155	        items:
   156	          type: string
   157	        required: false
   158	        notes: |
   159	          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
   160	          item.
   161	        source: IFOS-derived (Scribe extracts)
   162	        v1_0_agent_access:
   163	          - Scribe: R+W
   164	          - Sourcing Scout: R
   165	
   166	  placement:
   167	    v0_3_new_keys:
   168	      placement_status:
   169	        type: string
   170	        enum: [pending_start, active, completed, terminated_early, on_hold, cancelled]
   171	        default: pending_start
   172	        required: false
   173	        notes: |
   174	          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
   175	          confirming candidate started. Janitor flags ambiguous via
   176	          ESC_LIFECYCLE_STATE_UNKNOWN.
   177	        source: IFOS-derived (Scribe + Janitor)
   178	        v1_0_agent_access:
   179	          - Scribe: R+W
   180	          - Janitor: R+W
   181	          - Concierge: R
   182	
   183	      week_1_status_vault_path:
   184	        type: string
   185	        max_length: 200
   186	        pattern: '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$'
   187	        required: false
   188	        notes: |
   189	          POINTER ONLY (per ADR-002 vault/Postgres split). The 7d check-in
   190	          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
   191	          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
   192	          Pattern accepts call_ids + ISO dates (hyphens + underscores +
   193	          alphanumerics). This field stores the vault path; narrative does
   194	          NOT enter Postgres. Voice-classifier review at write time applies
   195	          to the vault file content; Concierge reads the vault file directly
   196	          via its path resolution.
   197	        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
   198	          to vault then stores pointer here)
   199	        v1_0_agent_access:
   200	          - Scribe: R+W
   201	          - Concierge: R
   202	
   203	      satisfaction_signal:
   204	        type: string
   205	        enum: [positive, neutral, negative, unclear]
   206	        default: unclear
   207	        required: false
   208	        notes: |
   209	          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
   210	          Concierge reads to adjust nurture tone.
   211	        source: IFOS-derived (Scribe LLM extraction)
   212	        v1_0_agent_access:
   213	          - Scribe: R+W
   214	          - Concierge: R
   215	
   216	  opportunity:
   217	    v0_3_new_keys:
   218	      headcount_growth_signal_text:
   219	        type: string
   220	        max_length: 280
   221	        required: false
   222	        notes: |
   223	          Free-text capture of growth-signal phrases from prospecting calls
   224	          ("we're hiring 5 engineers this quarter"). Sourcing Scout reads
   225	          to ICP-fit-score opportunities.
   226	        source: IFOS-derived (Scribe extraction)
   227	        v1_0_agent_access:
   228	          - Scribe: R+W
   229	          - Sourcing Scout: R
   230	
   231	      hiring_velocity_band:
   232	        type: string
   233	        enum: [slow, moderate, fast, urgent, unknown]
   234	        default: unknown
   235	        required: false
   236	        notes: |
   237	          Scribe LLM inference from prospecting-call urgency cues. Drives
   238	          ranking in Sourcing Scout's brief-to-candidate pipeline.
   239	        source: IFOS-derived (Scribe LLM classification)
   240	        v1_0_agent_access:
   241	          - Scribe: R+W
   242	          - Sourcing Scout: R
   243	
   244	      decision_window_text:
   245	        type: string
   246	        max_length: 280
   247	        required: false
   248	        notes: |
   249	          Free-text capture of decision-timing phrases. Concierge reads to
   250	          time outbound comms.
   251	        source: IFOS-derived (Scribe extraction)
   252	        v1_0_agent_access:
   253	          - Scribe: R+W
   254	          - Concierge: R
   255	
   256	# ============================================================================
   257	# §2 — Complete v0.3 agent access matrix
   258	# ============================================================================
   259	#
   260	# Per review-schema-change skill §5: full matrix across all v1.0 agents

 succeeded in 0ms:
   260	# Per review-schema-change skill §5: full matrix across all v1.0 agents
   261	# and all v0.1 + v0.2 entities. v0.3 is a CUMULATIVE matrix that includes
   262	# v0.1 + v0.2 + v0.3 dispositions. Where this matrix differs from
   263	# vertical-schema.yaml v0.1 §3, the cell is an EXPLICIT v0.3 amendment
   264	# with a marker comment in-line. Full list of v0.3 amendments:
   265	#
   266	# Cells changed from v0.1 baseline:
   267	#   - Diagnostic client: none → R (reads Companies House data via cached
   268	#     client entity; sales-tool source-of-truth context — v0.3 amendment)
   269	#   - Diagnostic contact: none → R (reads §11 decision-maker map context)
   270	#   - Diagnostic opportunity: none → R (reads prospect-firm opportunity if exists)
   271	#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
   272	#     pattern as candidate/contractor — v0.3 amendment)
   273	#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
   274	#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
   275	#     v0.3 amendment)
   276	#   - Janitor timesheet: none → R (reads for placement-state inference)
   277	#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
   278	#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
   279	#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
   280	#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
   281	#     R-only for Scribe)
   282	#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
   283	#   - Scribe timesheet: none → R (reads for placement-context resolution
   284	#     on check-in calls)
   285	#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
   286	#     — v0.3 amendment)
   287	#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
   288	#   - Cash Conductor timesheet: none → R (reads to verify billable hours
   289	#     match invoiced amounts)
   290	#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
   291	#     from multi-source aggregation — v0.3 amendment)
   292	#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
   293	#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
   294	#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
   295	#     activity-log links per concierge §4 Step 13-14 — v0.3 amendment)
   296	#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
   297	#   - Concierge opportunity: none → R (reads for outbound lifecycle-event context)
   298	#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
   299	#     concierge §4 Step 14 — v0.3 amendment)
   300	#   - Concierge timesheet: none → R (reads to verify placement-progress for
   301	#     7d/30d/90d nurture)
   302	#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
   303	#     extended)
   304	#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
   305	#     — v0.2 extended)
   306	#
   307	# All other access levels carry forward unchanged from v0.1 + v0.2.
   308	
   309	agent_access_matrix:
   310	
   311	  # Disposition tokens: R | W | R+W | none
   312	  #
   313	  # SCOPE: This matrix is rectangular across `entities:` entity_types ONLY
   314	  # (candidate, contractor, client, contact, brief, opportunity, placement,
   315	  # timesheet — 8 v0.1 entity_types).
   316	  #
   317	  # SCHEMA-LAYERING CORRECTION: The v0.2 supplement uses the YAML key
   318	  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
   319	  # voice_corpus_chunks is introduced separately around v0.2 supplement line
   320	  # 270 as the pgvector auxiliary table — it was always auxiliary, never
   321	  # under `entities:`. v0.2 supplement §1 "LAYERING DISCLOSURE" states the
   322	  # three `entities:`-keyed objects "are auxiliary Postgres tables (real
   323	  # CREATE TABLE statements in migrations/v0.1-to-v0.2.sql), NOT entity_types
   324	  # in the entities/entity_links generic primitive layer from Day-4 §6.3."
   325	  # v0.3 adopts this disclosure as the authoritative classification: all
   326	  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
   327	  # AUXILIARY, NOT entities. Their access lives in
   328	  # `auxiliary_table_access_matrix` below + §2a access amendments — NOT in
   329	  # this entity matrix. The v0.2 YAML key `entities:` was documentation
   330	  # convention; v0.3 reclassifies per the v0.2 LAYERING DISCLOSURE intent.
   331	  #
   332	  # ENTITY-LEVEL vs FIELD-LEVEL ACCESS:
   333	  # The matrix below is ENTITY-LEVEL — declares the maximum disposition an
   334	  # agent may have on any field of that entity.
   335	  #
   336	  # FIELD_ACCESS_NARROWING_RULE (v0.3 explicit scope rule, ratified as part
   337	  # of this supplement):
   338	  #   Per-field access (in §1 entity_field_additions[*].v1_0_agent_access)
   339	  #   NARROWS the entity-level disposition. The entity-level token is the
   340	  #   CEILING; field-level may be narrower (or absent — implying the agent
   341	  #   has the entity-level default) but NEVER BROADER than the matrix entry.
   342	  #   Example: Scribe.candidate: R+W at entity level; per-field
   343	  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
   344	  #   without reading it). Another example: Diagnostic.candidate: R at entity
   345	  #   level; candidate.linkedin_url has no Diagnostic field entry; Diagnostic
   346	  #   gets R on linkedin_url (entity-level default), not the broader Sourcing
   347	  #   Scout R+W. Implementation: cycle.sh + hh_decision_action records which
   348	  #   agent + which fields were touched in decision_log payload; reviewers
   349	  #   audit via that trail. v0.3 does NOT enforce this rule at the database
   350	  #   layer (column-level RLS would be required; v1.1+ work per the
   351	  #   "documentary not enforced" note above).
   352	  #
   353	  # Validation: the validate_entities_data_v0_3 trigger validates FIELD
   354	  # SHAPE only (type checks, enum membership, length caps, array element
   355	  # types). It does NOT enforce which agent is writing — agent-level
   356	  # write permission is DOCUMENTARY in v0.3, enforced at the application
   357	  # layer (cycle.sh + hh_decision_action) where the agent_name in the
   358	  # decision_log row records who wrote. Entity-level RLS enforces TENANT
   359	  # isolation but not agent-level access. Column-level RLS or per-agent
   360	  # database roles would be the v1.1+ enforcement layer; v0.3 is documentary.
   361	
   362	  diagnostic:
   363	    candidate: R           # reads for outreach context (§11 decision-maker map)
   364	    contractor: none       # not in scope at v1.0
   365	    client: R              # reads via Companies House lookup (entity-shape if cached)
   366	    contact: R             # reads for §11 decision-maker map
   367	    brief: none            # diagnostic is sales-tool not brief-driven
   368	    opportunity: R         # may read prospect-firm opportunity if exists
   369	    placement: none
   370	    timesheet: none
   371	
   372	  janitor:
   373	    candidate: R+W         # dedup + field-backfill writes
   374	    contractor: R+W        # dedup + field-backfill writes
   375	    client: R+W            # Companies House enrichment writes
   376	    contact: R+W           # dedup + field-backfill writes
   377	    brief: R               # context for related candidate cleanup
   378	    opportunity: R
   379	    placement: R+W         # lifecycle-state cleanup
   380	    timesheet: R           # reads for placement-state inference
   381	
   382	  scribe:
   383	    # Scribe's Bullhorn endpoint access (Candidate / ClientCorporation /
   384	    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
   385	    # row A3. opportunity + timesheet access below is to IFOS-cached
   386	    # Postgres rows ONLY (not direct Bullhorn endpoint calls). Scribe
   387	    # uses Bullhorn endpoints for the 5 v1.0-supported entities; other
   388	    # entity access in this matrix is via Postgres cache.
   389	    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
   390	    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
   391	    client: R              # IFOS-cached read (Bullhorn endpoint A3 — ClientCorporation)
   392	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
   393	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
   394	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields written to IFOS-cached Postgres rows only (Bullhorn Opportunity endpoint NOT used at v1.0 per integration-path §4.1)
   395	    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
   396	    timesheet: R           # IFOS-cached read; placement-context resolution (Bullhorn Timesheet endpoint NOT used at v1.0)
   397	
   398	  cash_conductor:
   399	    # NOTE: Cash Conductor has NO direct Bullhorn endpoint access per
   400	    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
   401	    # entity reads below are against IFOS-cached Postgres rows
   402	    # (populated by Janitor + Scribe + Concierge from their Bullhorn
   403	    # sync paths). Cash Conductor never calls Bullhorn endpoints directly.
   404	    candidate: none        # no Bullhorn dependency
   405	    contractor: none
   406	    client: R              # IFOS-cached read; client billing details
   407	    contact: R             # IFOS-cached read; invoice addressee resolution
   408	    brief: none
   409	    opportunity: R         # v0.3 NEW — IFOS-cached read; invoice-context (NOT a direct Bullhorn call; only cached rows)
   410	    placement: R           # IFOS-cached read; client linkage on invoice
   411	    timesheet: R           # IFOS-cached read; verify billable hours match invoice (NOT a direct Bullhorn call)
   412	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   413	
   414	  sourcing_scout:
   415	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   416	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   417	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   418	    # writes its proposed-candidate rows + reads opportunity context. These
   419	    # are entity-level access overrides codified here.
   420	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   421	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   422	    client: R
   423	    contact: R
   424	    brief: R               # reads to filter candidates
   425	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   426	    placement: none
   427	    timesheet: none
   428	
   429	  concierge:
   430	    # Concierge's Bullhorn endpoint access (Candidate / ClientCorporation /
   431	    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
   432	    # row A6. opportunity + timesheet access below is IFOS-cached Postgres
   433	    # only (not Bullhorn endpoint calls).
   434	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
   435	    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
   436	    client: R              # IFOS-cached read (Bullhorn endpoint A6 — ClientCorporation)
   437	    contact: R             # IFOS-cached read; outbound recipient resolution (Bullhorn endpoint A6 — Note context)
   438	    brief: R               # IFOS-cached read (Bullhorn endpoint A6 — JobOrder)
   439	    opportunity: R         # IFOS-cached read; outbound lifecycle-event context (Bullhorn Opportunity endpoint NOT used at v1.0)
   440	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14 (Bullhorn endpoint A6)
   441	    timesheet: R           # IFOS-cached read; placement-progress for 7d/30d/90d nurture (Bullhorn Timesheet endpoint NOT used at v1.0)
   442	
   443	# ============================================================================
   444	# §2a — v0.2 entity v1_0_agent_access amendments
   445	# ============================================================================
   446	#
   447	# Per review-schema-change §5: matrix changes must be reflected in entity-level
   448	# v1_0_agent_access lists. v0.3 amends these v0.2 entities:
   449	
   450	v0_1_entity_access_amendments:
   451	  # Per review-schema-change §5: matrix changes to v0.1 entity-level access
   452	  # must be reflected in explicit amendments. Each entry below documents the
   453	  # v0.1 baseline → v0.3 expanded access list. The base vertical-schema.yaml
   454	  # is NOT edited; this supplement is the authoritative source for v0.3
   455	  # entity access state.
   456	
   457	  client:
   458	    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
   459	    v0_3_v1_0_agent_access:
   460	      - Diagnostic (R)     # v0.3 NEW — reads Companies House data for sales-tool context
   461	      - Janitor (R+W)      # v0.1 unchanged
   462	      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
   463	      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
   464	      - Sourcing Scout (R) # v0.1 unchanged
   465	      - Concierge (R)      # v0.1 unchanged
   466	    rationale: |
   467	      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
   468	      client billing/context for their respective workflows). No new W access.
   469	
   470	  contact:
   471	    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
   472	    v0_3_v1_0_agent_access:
   473	      - Diagnostic (R)     # v0.3 NEW — reads §11 decision-maker map context
   474	      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
   475	      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
   476	      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
   477	      - Sourcing Scout (R) # v0.1 unchanged
   478	      - Concierge (R)      # v0.1 unchanged
   479	    rationale: |
   480	      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
   481	      preferred_channel + next_action_target_date; Janitor also dedup-merges).
   482	      Diagnostic + Cash Conductor gain R for context.
   483	
   484	  brief:
   485	    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
   486	    v0_3_v1_0_agent_access:
   487	      - Janitor (R)        # v0.1 unchanged
   488	      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
   489	      - Sourcing Scout (R) # v0.1 unchanged
   490	      - Concierge (R)      # v0.1 unchanged
   491	    rationale: |
   492	      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
   493	      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
   494	      for Scribe.
   495	
   496	  opportunity:
   497	    v0_1_v1_0_agent_access: [Janitor (R)]
   498	    v0_3_v1_0_agent_access:
   499	      - Diagnostic (R)     # v0.3 NEW — reads prospect-firm opportunity if exists
   500	      - Janitor (R)        # v0.1 unchanged
   501	      - Scribe (R+W)       # v0.3 NEW — writes 3 new prospecting-call fields
   502	      - Cash Conductor (R) # v0.3 NEW — reads for invoice context
   503	      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
   504	      - Concierge (R)      # v0.3 NEW — reads for outbound lifecycle context
   505	    rationale: |
   506	      v0.1 opportunity is sparsely accessed (Janitor only); v0.3 broadens
   507	      to all v1.0 agents because the entity gains 3 new fields used across
   508	      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
   509	      timing), Diagnostic + Cash Conductor (reads for context).
   510	
   511	  placement:
   512	    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
   513	    v0_3_v1_0_agent_access:
   514	      - Janitor (R+W)      # v0.3 UPGRADED — lifecycle-state cleanup writes
   515	      - Scribe (R+W)       # v0.3 NEW — check-in field extraction
   516	      - Cash Conductor (R) # v0.1 unchanged
   517	      - Concierge (R+W)    # v0.3 UPGRADED — writes Bullhorn state advancement
   518	    rationale: |
   519	      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
   520	      their §4 specs); adds Scribe R+W for check-in writes.
   521	
   522	  timesheet:
   523	    v0_1_v1_0_agent_access: [Cash Conductor (R)]
   524	    v0_3_v1_0_agent_access:
   525	      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
   526	      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
   527	      - Cash Conductor (R) # v0.1 unchanged
   528	      - Concierge (R)      # v0.3 NEW — reads to verify placement-progress for nurture
   529	    rationale: |
   530	      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
   531	      Scribe + Concierge (each reads timesheet for their respective
   532	      placement-related workflows).
   533	
   534	  candidate:
   535	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   536	    v0_3_v1_0_agent_access:
   537	      - Diagnostic (R)     # v0.3 NEW — reads for outreach context (§11 decision-maker map)
   538	      - Janitor (R+W)      # v0.1 unchanged
   539	      - Scribe (R+W)       # v0.1 unchanged
   540	      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
   541	      - Concierge (R+W)    # v0.3 UPGRADED — writes lifecycle-state-derived fields
   542	    rationale: |
   543	      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
   544	      multi-source aggregation) + Concierge (writes lifecycle-state and
   545	      activity-log links per §4 Steps 13-14). Diagnostic gains R for context.
   546	
   547	  contractor:
   548	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   549	    v0_3_v1_0_agent_access:
   550	      - Janitor (R+W)      # v0.1 unchanged
   551	      - Scribe (R+W)       # v0.1 unchanged
   552	      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
   553	      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
   554	    rationale: |
   555	      Parallel upgrades to candidate; contractor entities follow the same
   556	      v0.3 write patterns where applicable.
   557	
   558	v0_2_entity_access_amendments:
   559	
   560	  voice_corpus:
   561	    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
   562	    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
   563	    rationale: |
   564	      All v1.0 agents that produce voice-classified output (Diagnostic for
   565	      §12 conversation opener; Janitor for tacit-note narratives; Cash
   566	      Conductor for chase drafts; Sourcing Scout for per-candidate
   567	      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
   568	      granted Scribe + Concierge; v0.3 extends to all 6.
   569	
   570	  tone_rule:
   571	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
   572	    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
   573	    rationale: |
   574	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   575	      applies_to_agents containing 'janitor' for tacit-note narrative
   576	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   577	      Diagnostic + Sourcing Scout also read tone_rules for their
   578	      voice-classified outputs (§12 opener, per-candidate rationale).
   579	
   580	  recent_edit:
   581	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   582	    v0_3_v1_0_agent_access:
   583	      - voice-drift-canary (W)  # v0.2 unchanged
   584	      - Concierge (R)            # v0.2 unchanged
   585	      - LoRA (R)                 # v0.2 unchanged
   586	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   587	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   588	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   589	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   590	    rationale: |
   591	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   592	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   593	      for retraining queue). Janitor adds R for tacit-note harvest per
   594	      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
   595	      supplement is the authoritative source for the expanded access list.
   596	
   597	# ============================================================================
   598	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   599	# ============================================================================
   600	
   601	auxiliary_tables:
   602	
   603	  cash_conductor_transactions:
   604	    rationale: |
   605	      Open Banking transactions are high-volume + time-series + don't model
   606	      as entity.data JSONB. v0.3 introduces a first-class table with
   607	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   608	      §4 Step 3 + ADR-002 vault/Postgres split.
   609	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   610	    columns:
   611	      id: {type: integer, required: true, source: IFOS-internal, notes: BIGSERIAL primary key in SQL}
   612	      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
   613	      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
   614	      posted_at: {type: timestamp, required: true, source: Open Banking provider}
   615	      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
   616	      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
   617	      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   618	      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   619	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
   620	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}

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
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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
    16	--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
    17	--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
    18	--     + schema supplement (per ADR-006 Tier 2 + v0.3 supplement §5). v0.3
    19	--     does NOT extend the payload shape; the W4 ADR will add both the new
    20	--     payload key and its enforcement (CHECK constraint or trigger).
    21	--
    22	-- All v0.3 additions are STRICTLY ADDITIVE. Rollback path: companion
    23	-- v0.3-to-v0.2.sql.
    24	--
    25	-- Prerequisites:
    26	--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
    27	--     recent_edit tables exist; validate_voice_scores trigger active)
    28	--   - RLS policies + ifos_app grants from Day-4 §6.3 in place
    29	--   - migration-test tenant row exists in tenants table
    30	--
    31	-- Execution order: BEGIN; <each block>; COMMIT;   on success.
    32	--                  BEGIN; <each block>; ROLLBACK; on any error.
    33	-- ============================================================================
    34	
    35	BEGIN;
    36	
    37	-- ----------------------------------------------------------------------------
    38	-- §1 — Verify prerequisite v0.2 state
    39	-- ----------------------------------------------------------------------------
    40	
    41	DO $$
    42	BEGIN
    43	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
    44	    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
    45	  END IF;
    46	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus_chunks') THEN
    47	    RAISE EXCEPTION 'v0.2 voice_corpus_chunks table missing; run v0.1-to-v0.2.sql first';
    48	  END IF;
    49	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
    50	    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
    51	  END IF;
    52	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
    53	    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
    54	  END IF;
    55	  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
    56	END $$;
    57	
    58	-- ----------------------------------------------------------------------------
    59	-- §2 — Create cash_conductor_transactions table (RLS-isolated)
    60	-- ----------------------------------------------------------------------------
    61	
    62	CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
    63	  id                 BIGSERIAL PRIMARY KEY,
    64	  tenant_slug        TEXT NOT NULL,
    65	  transaction_id     TEXT NOT NULL,
    66	  posted_at          TIMESTAMPTZ NOT NULL,
    67	  amount             NUMERIC(15, 2) NOT NULL,
    68	  currency           TEXT NOT NULL DEFAULT 'GBP',
    69	  payee_name_raw     TEXT,
    70	  description        TEXT,
    71	  bank_provider      TEXT NOT NULL,
    72	  match_status       TEXT NOT NULL DEFAULT 'unmatched',
    73	  matched_invoice_id TEXT,
    74	  match_confidence   NUMERIC(3, 2),
    75	  match_dimensions   TEXT[],
    76	  ingested_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    77	  raw_payload        JSONB,
    78	
    79	  CONSTRAINT cct_match_status_valid CHECK (
    80	    match_status IN ('unmatched', 'matched', 'ambiguous')
    81	  ),
    82	  CONSTRAINT cct_bank_provider_valid CHECK (
    83	    bank_provider IN ('truelayer', 'plaid_uk', 'open_banking_direct')
    84	  ),
    85	  CONSTRAINT cct_match_confidence_range CHECK (
    86	    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
    87	  ),
    88	  CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id)
    89	);
    90	
    91	CREATE INDEX IF NOT EXISTS idx_cct_tenant_posted
    92	  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
    93	
    94	CREATE INDEX IF NOT EXISTS idx_cct_tenant_unmatched
    95	  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
    96	  WHERE match_status IN ('unmatched', 'ambiguous');
    97	
    98	-- RLS isolation per Day-4 §6.3 pattern
    99	ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
   100	ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
   101	
   102	CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
   103	  FOR ALL TO ifos_app
   104	  USING (tenant_slug = current_setting('app.current_tenant', true));
   105	
   106	GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
   107	GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
   108	
   109	-- ----------------------------------------------------------------------------
   110	-- §3 — Create cash_conductor_invoices table (RLS-isolated)
   111	-- ----------------------------------------------------------------------------
   112	
   113	CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
   114	  id                       BIGSERIAL PRIMARY KEY,
   115	  tenant_slug              TEXT NOT NULL,
   116	  invoice_id               TEXT NOT NULL,
   117	  accounting_provider      TEXT NOT NULL,
   118	  invoice_number           TEXT,
   119	  issued_at                TIMESTAMPTZ NOT NULL,
   120	  due_at                   TIMESTAMPTZ NOT NULL,
   121	  amount_total             NUMERIC(15, 2) NOT NULL,
   122	  amount_paid              NUMERIC(15, 2) NOT NULL DEFAULT 0,
   123	  currency                 TEXT NOT NULL DEFAULT 'GBP',
   124	  status                   TEXT NOT NULL DEFAULT 'open',
   125	  client_contact_id        TEXT,
   126	  client_billing_email     TEXT,
   127	  last_chase_position      INT NOT NULL DEFAULT 0,
   128	  last_chase_sent_at       TIMESTAMPTZ,
   129	  ingested_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
   130	  raw_payload              JSONB,
   131	
   132	  CONSTRAINT cci_status_valid CHECK (
   133	    status IN ('open', 'partial', 'paid', 'overdue', 'cancelled', 'voided')
   134	  ),
   135	  CONSTRAINT cci_provider_valid CHECK (
   136	    accounting_provider IN ('xero', 'quickbooks', 'sage')
   137	  ),
   138	  CONSTRAINT cci_chase_position_range CHECK (
   139	    last_chase_position >= 0 AND last_chase_position <= 4
   140	  ),
   141	  CONSTRAINT cci_amount_paid_non_negative CHECK (
   142	    amount_paid >= 0 AND amount_paid <= amount_total
   143	  ),
   144	  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
   145	);
   146	
   147	CREATE INDEX IF NOT EXISTS idx_cci_tenant_due
   148	  ON cash_conductor_invoices (tenant_slug, due_at);
   149	
   150	CREATE INDEX IF NOT EXISTS idx_cci_tenant_overdue
   151	  ON cash_conductor_invoices (tenant_slug, status, due_at)
   152	  WHERE status IN ('open', 'partial', 'overdue');
   153	
   154	CREATE INDEX IF NOT EXISTS idx_cci_tenant_chase
   155	  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
   156	  WHERE last_chase_position BETWEEN 1 AND 3;
   157	
   158	ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
   159	ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
   160	
   161	CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
   162	  FOR ALL TO ifos_app
   163	  USING (tenant_slug = current_setting('app.current_tenant', true));
   164	
   165	GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
   166	GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
   167	
   168	-- ----------------------------------------------------------------------------
   169	-- §4 — Replace JSONB validation function for entities.data (adds v0.3 keys)
   170	-- ----------------------------------------------------------------------------
   171	--
   172	-- The v0.2 migration installed validate_voice_scores trigger which validates
   173	-- the 6 voice-score keys. v0.3 extends validation to cover the 14 new keys
   174	-- for candidate, contact, brief, placement, opportunity. We replace the
   175	-- function in place (CREATE OR REPLACE) so the v0.2 voice-score checks remain.
   176	
   177	CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
   178	RETURNS TRIGGER AS $$
   179	DECLARE
   180	  d JSONB := NEW.data;
   181	  et TEXT := NEW.entity_type;
   182	  arr_item JSONB;
   183	BEGIN
   184	  -- v0.2 voice-score keys (forwarded; preserves v0.2 [0.0, 1.0] range check)
   185	  IF d ? 'voice_classifier_score' THEN
   186	    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
   187	      RAISE EXCEPTION 'voice_classifier_score must be number or null';
   188	    END IF;
   189	    IF d->'voice_classifier_score' != 'null'::jsonb THEN
   190	      IF (d->>'voice_classifier_score')::numeric < 0.0
   191	         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
   192	        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
   193	      END IF;
   194	    END IF;
   195	  END IF;
   196	
   197	  IF d ? 'voice_drift_at_close' THEN
   198	    IF jsonb_typeof(d->'voice_drift_at_close') NOT IN ('number', 'null') THEN
   199	      RAISE EXCEPTION 'voice_drift_at_close must be number or null';
   200	    END IF;
   201	    IF d->'voice_drift_at_close' != 'null'::jsonb THEN
   202	      IF (d->>'voice_drift_at_close')::numeric < 0.0
   203	         OR (d->>'voice_drift_at_close')::numeric > 1.0 THEN
   204	        RAISE EXCEPTION 'voice_drift_at_close out of [0.0, 1.0] range: %', d->>'voice_drift_at_close';
   205	      END IF;
   206	    END IF;
   207	  END IF;
   208	
   209	  -- v0.3 candidate fields
   210	  IF et = 'candidate' THEN
   211	    IF d ? 'employment_type' THEN
   212	      IF (d->>'employment_type') NOT IN (
   213	        'perm', 'contract', 'contract_inside_ir35', 'contract_outside_ir35', 'day_rate', 'hybrid'
   214	      ) THEN
   215	        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
   216	      END IF;
   217	    END IF;
   218	
   219	    IF d ? 'key_skills' THEN
   220	      IF jsonb_typeof(d->'key_skills') != 'array' THEN
   221	        RAISE EXCEPTION 'key_skills must be array';
   222	      END IF;
   223	      IF jsonb_array_length(d->'key_skills') > 20 THEN
   224	        RAISE EXCEPTION 'key_skills max length 20 (got %)', jsonb_array_length(d->'key_skills');
   225	      END IF;
   226	      -- Every element must be a string
   227	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'key_skills') LOOP
   228	        IF jsonb_typeof(arr_item) != 'string' THEN
   229	          RAISE EXCEPTION 'key_skills items must be strings; got %', jsonb_typeof(arr_item);
   230	        END IF;
   231	      END LOOP;
   232	    END IF;
   233	
   234	    IF d ? 'linkedin_url' THEN
   235	      IF jsonb_typeof(d->'linkedin_url') NOT IN ('string', 'null') THEN
   236	        RAISE EXCEPTION 'linkedin_url must be string or null';
   237	      END IF;
   238	      IF d->>'linkedin_url' IS NOT NULL
   239	         AND d->>'linkedin_url' !~ '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$' THEN
   240	        RAISE EXCEPTION 'linkedin_url does not match expected pattern: %', d->>'linkedin_url';
   241	      END IF;
   242	    END IF;
   243	  END IF;
   244	
   245	  -- v0.3 contact fields
   246	  IF et = 'contact' THEN
   247	    IF d ? 'preferred_channel' THEN
   248	      IF (d->>'preferred_channel') NOT IN (
   249	        'email', 'phone', 'sms', 'teams', 'slack', 'in_person', 'unknown'
   250	      ) THEN
   251	        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
   252	      END IF;
   253	    END IF;
   254	
   255	    IF d ? 'next_action_target_date' THEN
   256	      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
   257	        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
   258	      END IF;
   259	      -- Validate ISO-8601 date format (YYYY-MM-DD) by cast
   260	      IF d->>'next_action_target_date' IS NOT NULL THEN

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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '620,980p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   620	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
   621	      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   622	      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
   623	      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}
   624	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   625	      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
   626	    indexes:
   627	      - "(tenant_slug, posted_at DESC)"
   628	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   629	    retention: |
   630	      INTENT (W4-polish enforcement required): 7-year retention with
   631	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   632	      description, raw_payload). Aligned with Q4 v0_3_default. The
   633	      v0.2-to-v0.3 migration creates the table + indexes only; the
   634	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   635	      job or external scheduled job; not yet authored).
   636	    enforcement_gate: |
   637	      Production use of this table GATED until pseudonymization + purge
   638	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   639	      by founder + tenant before go-live; migration-test tenant exempt.
   640	
   641	  cash_conductor_invoices:
   642	    rationale: |
   643	      Open invoice register cached from accounting provider. Same auxiliary-
   644	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   645	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   646	    columns:
   647	      id: {type: integer, required: true, source: IFOS-internal}
   648	      tenant_slug: {type: string, required: true, source: IFOS-internal}
   649	      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
   650	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
   651	      invoice_number: {type: string, required: false, source: Accounting provider}
   652	      issued_at: {type: timestamp, required: true, source: Accounting provider}
   653	      due_at: {type: timestamp, required: true, source: Accounting provider}
   654	      amount_total: {type: number, required: true, source: Accounting provider, notes: NUMERIC(15,2) GBP}
   655	      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
   656	      currency: {type: string, required: true, default: GBP, source: Accounting provider}
   657	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open, source: Accounting provider}
   658	      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
   659	      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
   660	      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
   661	      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
   662	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   663	      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
   664	    indexes:
   665	      - "(tenant_slug, due_at)"
   666	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   667	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   668	    retention: |
   669	      INTENT (W4-polish enforcement required): 7-year retention with
   670	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   671	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   672	      pseudonymization + purge implementation is a W4-polish slice
   673	      (pg_cron job or external scheduled job; not yet authored).
   674	    enforcement_gate: |
   675	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   676	      W4 polish, production use of cash_conductor_invoices is GATED by
   677	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   678	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   679	      data is exempt; pilot tenants require the DPA addendum signed before
   680	      go-live.
   681	
   682	auxiliary_table_access_matrix:
   683	  voice_corpus:
   684	    # v0.2 auxiliary table — voice exemplar corpus (per-tenant)
   685	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents that
   686	    # produce voice-classified output
   687	    diagnostic: R
   688	    janitor: R
   689	    scribe: R
   690	    cash_conductor: R
   691	    sourcing_scout: R
   692	    concierge: R
   693	  voice_corpus_chunks:
   694	    # v0.2 auxiliary table holding pgvector HNSW index over voice corpus chunks
   695	    # All v1.0 agents producing voice-classified output need R for ANN-match retrieval
   696	    diagnostic: R
   697	    janitor: R
   698	    scribe: R
   699	    cash_conductor: R
   700	    sourcing_scout: R
   701	    concierge: R
   702	  tone_rule:
   703	    # v0.2 auxiliary table — per-tenant tone constraints
   704	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents
   705	    diagnostic: R
   706	    janitor: R
   707	    scribe: R
   708	    cash_conductor: R
   709	    sourcing_scout: R
   710	    concierge: R
   711	  recent_edit:
   712	    # v0.2 auxiliary table — consultant edits for retraining/drift detection
   713	    # Per §2a amendment: v0.3 expands access (Concierge R from v0.2;
   714	    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
   715	    # Scout add W to write own retraining edits; Diagnostic remains none)
   716	    diagnostic: none
   717	    janitor: R
   718	    scribe: W
   719	    cash_conductor: W
   720	    sourcing_scout: W
   721	    concierge: R
   722	  cash_conductor_transactions:
   723	    diagnostic: none
   724	    janitor: none
   725	    scribe: none
   726	    cash_conductor: R+W
   727	    sourcing_scout: none
   728	    concierge: none
   729	  cash_conductor_invoices:
   730	    diagnostic: none
   731	    janitor: none
   732	    scribe: none
   733	    cash_conductor: R+W
   734	    sourcing_scout: none
   735	    concierge: none
   736	
   737	# ============================================================================
   738	# §4 — tenant_adapters.config new keys (3 keys)
   739	# ============================================================================
   740	#
   741	# tenant_adapters.config is JSONB; validation via
   742	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   743	# on unknown keys per Rule 2.
   744	
   745	tenant_adapters_config_additions:
   746	
   747	  cash_conductor_last_run:
   748	    type: timestamp
   749	    required: false
   750	    set_by: cash_conductor
   751	    read_by: [cash_conductor]
   752	    notes: |
   753	      Cash Conductor cron sweep updates at session-close. Next run queries
   754	      transactions/invoices since this timestamp.
   755	
   756	  concierge_last_poll:
   757	    type: timestamp
   758	    required: false
   759	    set_by: concierge
   760	    read_by: [concierge]
   761	    notes: |
   762	      Concierge polling cron updates at end of each cycle. Next poll queries
   763	      Bullhorn for state transitions since this timestamp.
   764	
   765	  concierge_send_window:
   766	    type: object
   767	    required: false
   768	    default:
   769	      timezone: Europe/London
   770	      weekday_start: '09:00'
   771	      weekday_end: '17:00'
   772	      weekend_send_enabled: false
   773	    set_by: [tenant-admin]
   774	    read_by: [concierge]
   775	    object_shape:
   776	      timezone:
   777	        type: string
   778	        notes: IANA timezone identifier
   779	      weekday_start:
   780	        type: string
   781	        notes: HH:MM 24-hour format
   782	      weekday_end:
   783	        type: string
   784	        notes: HH:MM 24-hour format
   785	      weekend_send_enabled:
   786	        type: boolean
   787	    notes: |
   788	      Per-tenant outbound sending hours. Concierge respects when scheduling
   789	      orange-tier sends.
   790	
   791	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   792	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
   793	  # declare this config key; the W4 ADR will introduce both the field
   794	  # and its consumer at the same time. Including it in v0.3 without an
   795	  # active consumer would be speculative schema.
   796	
   797	# ============================================================================
   798	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   799	# ============================================================================
   800	
   801	decision_log_payload_extension:
   802	  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
   803	  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
   804	  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
   805	  # that ships alongside Tier 2 activation. v0.3 introducing the payload
   806	  # key without enforcement would violate review-schema-change §3
   807	  # (bounded values require CHECK or trigger). Tier 2 schema work owns
   808	  # the constraint + writer; this v0.3 supplement is silent on it.
   809	  deferred_to_future_adr:
   810	    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
   811	    schema_owner: future W4-polish supplement (not v0.3)
   812	    rationale: |
   813	      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
   814	      separate post-launch quality metric outside Gate A. The payload key,
   815	      its [0.0, 1.0] range validation, and the sample-rate config field
   816	      all land together with Tier 2 activation. Tier 2 doesn't activate
   817	      until the voice classifier microservice ships + first pilot tenant
   818	      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
   819	      payload shape to avoid declaring schema without enforcement.
   820	
   821	# ============================================================================
   822	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   823	# ============================================================================
   824	
   825	migration_sequence:
   826	  forward: migrations/v0.2-to-v0.3.sql
   827	  rollback: migrations/v0.3-to-v0.2.sql
   828	
   829	  pre_conditions:
   830	    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
   831	    - validate_voice_scores trigger active on entities table
   832	    - RLS + ifos_app grants from Day-4 §6.3 in place
   833	    - migration-test tenant row exists in tenants table
   834	
   835	  steps:
   836	    1: |
   837	      Verify v0.2 prerequisites (DO block in migration §1).
   838	    2: |
   839	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   840	      ifos_app grants + 2 indexes (migration §2).
   841	    3: |
   842	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   843	      (migration §3).
   844	    4: |
   845	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   846	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   847	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   848	      candidate / contact / brief / placement / opportunity entity_types.
   849	      Re-attaches the trigger to entities table (migration §4).
   850	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   851	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   852	    5: |
   853	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   854	      hard-fails on unknown config keys (Rule 2); type-validates the 3 new
   855	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   856	    6: |
   857	      Smoke verification DO block confirms both cash_conductor_*
   858	      tables exist (migration §6).
   859	    7: |
   860	      COMMIT; or ROLLBACK on any error.
   861	
   862	  post_migration_steps:
   863	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   864	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   865	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   866	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   867	       Cat-β findings closed
   868	
   869	# ============================================================================
   870	# §7 — Codex ratification path
   871	# ============================================================================
   872	
   873	codex_ratification:
   874	  skill: review-schema-change
   875	  expected_round_trips: 1-2 (mechanical fixes only)
   876	  manifest_queue_position: 44 (after v0.2 supplement at 29)
   877	
   878	# ============================================================================
   879	# §8 — Open questions (structured per review-schema-change §8)
   880	# ============================================================================
   881	
   882	open_questions:
   883	
   884	  Q1_employment_type_enum_completeness:
   885	    question: Are 6 employment_type enum values sufficient for UK recruitment?
   886	    options:
   887	      A: |
   888	        Keep 6 values as in §1.candidate.employment_type — perm, contract,
   889	        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
   890	      B: |
   891	        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
   892	      C: |
   893	        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
   894	        (array of allowed strings); validate at write time against tenant's list.
   895	    v0_3_default: A
   896	    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
   897	      outside A, escalate to B or C.
   898	
   899	  Q2_key_skills_max_length:
   900	    question: Cap at 20 items per candidate adequate?
   901	    options:
   902	      A: Keep cap at 20 (validator hard-fails over).
   903	      B: Increase to 50 (handles senior technical candidates with deep stacks).
   904	      C: Remove cap entirely (rely on application-layer pruning).
   905	    v0_3_default: A
   906	    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
   907	      of candidates hit the 20-item cap, escalate to B.
   908	
   909	  Q3_placement_status_enum_lifecycle:
   910	    question: 6-state placement_status enum maps to Bullhorn's native state machine?
   911	    options:
   912	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   913	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   914	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   915	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   916	    v0_3_default: A
   917	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   918	      escalate to B or C if 1:1 mapping breaks.
   919	
   920	  Q4_cash_conductor_transactions_retention:
   921	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   922	      What's the production retention policy?
   923	    options:
   924	      A: 7-year retention with automated pseudonymization at year 7 (hash
   925	         payee_name_raw + description; preserve amount + dates for audit).
   926	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   927	         rows retained beyond 7 years for cross-period reconciliation).
   928	      C: Per-tenant retention override in tenant_adapters.config.
   929	    v0_3_default: A
   930	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   931	      tenant requires shorter retention, escalate to C with tenant-specific
   932	      override. Pseudonymization implementation lands in W4-polish slice.
   933	    production_use_gating: |
   934	      Until pseudonymization implementation lands, production use of
   935	      cash_conductor_transactions table is GATED by an explicit per-tenant
   936	      DPA addendum signed by founder + tenant. Migration-test tenant data
   937	      is not subject to this gate.
   938	
   939	  Q5_unknown_config_keys_handling:
   940	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   941	    options:
   942	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   943	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   944	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   945	    v0_3_default: A
   946	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   947	      for forward-compat, escalate to B or C with explicit ADR.
   948	
   949	# ============================================================================
   950	# §9 — Why v0.3 is the right unblock
   951	# ============================================================================
   952	
   953	rationale: |
   954	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   955	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   956	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   957	  adds 14 entity JSONB keys + 2 auxiliary tables + 3 config keys. The
   958	  per_claim_confidence_distribution payload key originally planned for
   959	  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
   960	  §5 of this supplement); v0.3 is silent on payload schema extensions.
   961	
   962	  After v0.3 ratifies + migration applies:
   963	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   964	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   965	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   966	      placement_status, week_1_status_vault_path, satisfaction_signal,
   967	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   968	      are now schema-backed. (Note: week_1_status_note narrative now lives
   969	      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
   970	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   971	      seniority — not yet in schema; brief.start_date should be
   972	      start_date_target; opportunity.sector — not yet in schema). These
   973	      residual gaps are tracked in W4-polish-schema-extension backlog;
   974	      they do not block v0.3 ratification but do require a Scribe agent.md
   975	      consistency-pass before Scribe ratifies.
   976	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   977	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   978	    - Concierge tenant_adapters.config field refs valid
   979	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   980	

codex
I’ve found that the file and companion migrations exist. I’m now checking whether the migration actually implements the schema claims, because a supplement can pass structurally but fail if its promised constraints or access model are only documentary.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '260,620p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	      IF d->>'next_action_target_date' IS NOT NULL THEN
   261	        BEGIN
   262	          PERFORM (d->>'next_action_target_date')::date;
   263	        EXCEPTION WHEN OTHERS THEN
   264	          RAISE EXCEPTION 'next_action_target_date must parse as ISO-8601 date (YYYY-MM-DD); got: %', d->>'next_action_target_date';
   265	        END;
   266	      END IF;
   267	    END IF;
   268	  END IF;
   269	
   270	  -- v0.3 brief fields
   271	  IF et = 'brief' THEN
   272	    IF d ? 'must_haves' THEN
   273	      IF jsonb_typeof(d->'must_haves') != 'array' THEN
   274	        RAISE EXCEPTION 'must_haves must be array';
   275	      END IF;
   276	      IF jsonb_array_length(d->'must_haves') > 15 THEN
   277	        RAISE EXCEPTION 'must_haves max length 15';
   278	      END IF;
   279	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
   280	        IF jsonb_typeof(arr_item) != 'string' THEN
   281	          RAISE EXCEPTION 'must_haves items must be strings';
   282	        END IF;
   283	      END LOOP;
   284	    END IF;
   285	
   286	    IF d ? 'nice_to_haves' THEN
   287	      IF jsonb_typeof(d->'nice_to_haves') != 'array' THEN
   288	        RAISE EXCEPTION 'nice_to_haves must be array';
   289	      END IF;
   290	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'nice_to_haves') LOOP
   291	        IF jsonb_typeof(arr_item) != 'string' THEN
   292	          RAISE EXCEPTION 'nice_to_haves items must be strings';
   293	        END IF;
   294	      END LOOP;
   295	    END IF;
   296	
   297	    IF d ? 'deal_breakers' THEN
   298	      IF jsonb_typeof(d->'deal_breakers') != 'array' THEN
   299	        RAISE EXCEPTION 'deal_breakers must be array';
   300	      END IF;
   301	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
   302	        IF jsonb_typeof(arr_item) != 'string' THEN
   303	          RAISE EXCEPTION 'deal_breakers items must be strings';
   304	        END IF;
   305	      END LOOP;
   306	    END IF;
   307	  END IF;
   308	
   309	  -- v0.3 placement fields
   310	  IF et = 'placement' THEN
   311	    IF d ? 'placement_status' THEN
   312	      IF (d->>'placement_status') NOT IN (
   313	        'pending_start', 'active', 'completed', 'terminated_early', 'on_hold', 'cancelled'
   314	      ) THEN
   315	        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
   316	      END IF;
   317	    END IF;
   318	
   319	    IF d ? 'week_1_status_vault_path' THEN
   320	      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
   321	        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
   322	      END IF;
   323	      IF d->>'week_1_status_vault_path' IS NOT NULL
   324	         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$' THEN
   325	        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
   326	      END IF;
   327	      IF d->>'week_1_status_vault_path' IS NOT NULL
   328	         AND length(d->>'week_1_status_vault_path') > 200 THEN
   329	        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
   330	      END IF;
   331	    END IF;
   332	
   333	    IF d ? 'satisfaction_signal' THEN
   334	      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
   335	        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
   336	      END IF;
   337	    END IF;
   338	  END IF;
   339	
   340	  -- v0.3 opportunity fields
   341	  IF et = 'opportunity' THEN
   342	    IF d ? 'headcount_growth_signal_text' THEN
   343	      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
   344	        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
   345	      END IF;
   346	      IF d->>'headcount_growth_signal_text' IS NOT NULL
   347	         AND length(d->>'headcount_growth_signal_text') > 280 THEN
   348	        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
   349	      END IF;
   350	    END IF;
   351	
   352	    IF d ? 'hiring_velocity_band' THEN
   353	      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
   354	        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
   355	      END IF;
   356	    END IF;
   357	
   358	    IF d ? 'decision_window_text' THEN
   359	      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
   360	        RAISE EXCEPTION 'decision_window_text must be string or null';
   361	      END IF;
   362	      IF d->>'decision_window_text' IS NOT NULL
   363	         AND length(d->>'decision_window_text') > 280 THEN
   364	        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
   365	      END IF;
   366	    END IF;
   367	  END IF;
   368	
   369	  RETURN NEW;
   370	END;
   371	$$ LANGUAGE plpgsql;
   372	
   373	-- Rebind the trigger to the new function (drops + recreates)
   374	DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
   375	DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
   376	
   377	CREATE TRIGGER validate_entities_data_v0_3
   378	  BEFORE INSERT OR UPDATE ON entities
   379	  FOR EACH ROW
   380	  EXECUTE FUNCTION validate_entities_data_v0_3();
   381	
   382	-- ----------------------------------------------------------------------------
   383	-- §5 — tenant_adapters.config validation trigger (new keys)
   384	-- ----------------------------------------------------------------------------
   385	--
   386	-- v0.3 codifies 3 new config keys agents read. The validation trigger ensures
   387	-- only the documented keys are stored (hard-fail on unknown keys per Rule 2
   388	-- Schema before code).
   389	
   390	CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
   391	RETURNS TRIGGER AS $$
   392	DECLARE
   393	  c JSONB := NEW.config;
   394	  k TEXT;
   395	  allowed_keys TEXT[] := ARRAY[
   396	    -- v0.1 + v0.2 keys (forwarded; do not remove)
   397	    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
   398	    'janitor_last_run',
   399	    'pii_retention_days',  -- v0.2 PII purge runbook key
   400	    -- autosend-safety-policy.md keys
   401	    'approval_routing', 'approval_timeouts', 'sampling_rates',
   402	    -- v0.3 additions
   403	    'cash_conductor_last_run',
   404	    'concierge_last_poll',
   405	    'concierge_send_window'
   406	    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   407	    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
   408	  ];
   409	BEGIN
   410	  IF c IS NULL THEN
   411	    RETURN NEW;
   412	  END IF;
   413	
   414	  FOR k IN SELECT jsonb_object_keys(c) LOOP
   415	    IF NOT (k = ANY(allowed_keys)) THEN
   416	      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
   417	    END IF;
   418	  END LOOP;
   419	
   420	  -- v0.3 type validations
   421	  -- diagnostic_per_claim_sample_rate DEFERRED to W4-polish ADR; not validated
   422	  -- in v0.3 (also not in allowlist above, so it would fail-fast anyway)
   423	
   424	  IF c ? 'concierge_send_window' THEN
   425	    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
   426	      RAISE EXCEPTION 'concierge_send_window must be object';
   427	    END IF;
   428	    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
   429	      RAISE EXCEPTION 'concierge_send_window must include timezone';
   430	    END IF;
   431	    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
   432	       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
   433	      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
   434	    END IF;
   435	    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
   436	       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
   437	      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
   438	    END IF;
   439	  END IF;
   440	
   441	  -- v0.3 timestamp-typed keys
   442	  IF c ? 'cash_conductor_last_run' THEN
   443	    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
   444	      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
   445	    END IF;
   446	  END IF;
   447	
   448	  IF c ? 'concierge_last_poll' THEN
   449	    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
   450	      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
   451	    END IF;
   452	  END IF;
   453	
   454	  RETURN NEW;
   455	END;
   456	$$ LANGUAGE plpgsql;
   457	
   458	DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
   459	
   460	CREATE TRIGGER validate_tenant_adapters_config_v0_3
   461	  BEFORE INSERT OR UPDATE ON tenant_adapters
   462	  FOR EACH ROW
   463	  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
   464	
   465	-- ----------------------------------------------------------------------------
   466	-- §6 — Smoke verification (read-only)
   467	-- ----------------------------------------------------------------------------
   468	
   469	DO $$
   470	DECLARE
   471	  ccr_count INT;
   472	  cci_count INT;
   473	BEGIN
   474	  SELECT count(*) INTO ccr_count FROM information_schema.tables
   475	    WHERE table_name = 'cash_conductor_transactions';
   476	  IF ccr_count != 1 THEN
   477	    RAISE EXCEPTION 'cash_conductor_transactions table not created';
   478	  END IF;
   479	
   480	  SELECT count(*) INTO cci_count FROM information_schema.tables
   481	    WHERE table_name = 'cash_conductor_invoices';
   482	  IF cci_count != 1 THEN
   483	    RAISE EXCEPTION 'cash_conductor_invoices table not created';
   484	  END IF;
   485	
   486	  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
   487	END $$;
   488	
   489	COMMIT;
   490	
   491	-- ============================================================================
   492	-- End of v0.2 → v0.3 migration
   493	-- ============================================================================

exec
/bin/zsh -lc 'rg -n "recent_edit|GRANT|ifos_app|tone_rule|voice_corpus|voice_corpus_chunks|validate_tenant|cash_conductor_last_run|concierge_send_window|unknown" docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "CREATE TABLE|ALTER TABLE|GRANT|recent_edit|cash_conductor_transactions|cash_conductor_invoices|validate_entities_data_v0_3|validate_tenant_adapters_config_v0_3" docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:26:--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:28:--   - RLS policies + ifos_app grants from Day-4 §6.3 in place
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:43:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:44:    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:46:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus_chunks') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:47:    RAISE EXCEPTION 'v0.2 voice_corpus_chunks table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:49:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:50:    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:103:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:107:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:162:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:165:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:166:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:249:        'email', 'phone', 'sms', 'teams', 'slack', 'in_person', 'unknown'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:353:      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:387:-- only the documented keys are stored (hard-fail on unknown keys per Rule 2
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:390:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:403:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:405:    'concierge_send_window'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:416:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:424:  IF c ? 'concierge_send_window' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:425:    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:      RAISE EXCEPTION 'concierge_send_window must be object';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:428:    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:429:      RAISE EXCEPTION 'concierge_send_window must include timezone';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:431:    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:432:       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:433:      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:435:    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:436:       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:437:      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:442:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:444:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:460:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:171:-- §6 — Grants for ifos_app role
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:190:-- v0.2 tables should be owned by `postgres`, not `ifos_app`. Day-11 finding:
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:191:-- when the migration runs as ifos_app via SSH tunnel, the new tables become
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:192:-- owned by ifos_app, conferring implicit UPDATE + DELETE privileges that
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:193:-- bypass the GRANT-based append-only model (T5 invariant). FORCE ROW LEVEL
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:199:--   ALTER TABLE voice_corpus OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:200:--   ALTER TABLE voice_corpus_chunks OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:201:--   ALTER TABLE tone_rule OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:202:--   ALTER TABLE recent_edit OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:203:--   ALTER SEQUENCE voice_corpus_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:204:--   ALTER SEQUENCE voice_corpus_chunks_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:205:--   ALTER SEQUENCE tone_rule_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:206:--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:210:-- has CREATE on schema but isn't the same as `ifos_app`. Pre-bakes ownership.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:245:-- by postgres; ifos_app has only TRIGGER privilege from Day-11 GRANT).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:280:-- §9 — Reference rows: seed migration-test tenant with a starter voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:282:-- Inserts a single empty active voice_corpus row for migration-test only.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:289:INSERT INTO voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:313:-- SELECT count(*) FROM voice_corpus WHERE tenant_slug = 'migration-test';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:315:-- SELECT indexname FROM pg_indexes WHERE tablename = 'voice_corpus_chunks';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:316:--   → expect: voice_corpus_chunks_pkey, voice_corpus_chunks_tenant_idx,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:317:--             voice_corpus_chunks_corpus_idx, voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');

 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:59:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:62:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:92:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:95:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:99:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:100:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:102:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:107:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:110:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:113:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:148:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:151:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:158:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:159:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:161:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:165:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:166:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:177:CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:375:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:377:CREATE TRIGGER validate_entities_data_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:380:  EXECUTE FUNCTION validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:390:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:460:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:475:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:477:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:481:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:483:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:486:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
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

exec
/bin/zsh -lc "rg -n \"A4|No direct Bullhorn|A3|A6|endpoint|Candidate|ClientCorporation|JobOrder|Note|Placement|Timesheet|Opportunity\" docs/verticals/recruitment -g '*.md'" in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
exec
/bin/zsh -lc 'rg -n "relationships:|additional_relationships:|bullhorn_mapping:|entities:|entity_types:|agent_access_matrix:|candidate:|bullhorn_id|required: true|description:|bullhorn_source:|canonical_fields:" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:42:#   The label `entities:` below is a YAML key (the schema-document convention from
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:53:entities:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:57:    description: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:59:    bullhorn_source: none (IFOS-derived from /vault/<tenant>/_voice/ ingest)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:64:    canonical_fields:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:67:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:72:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:78:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:83:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:89:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:94:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:100:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:106:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:111:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:124:    description: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:126:    bullhorn_source: none (IFOS-derived; authored in /vault/<tenant>/_voice/tone-rules.yaml then synced to Postgres)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:131:    canonical_fields:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:134:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:138:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:143:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:148:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:154:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:160:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:165:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:171:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:190:    description: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:192:    bullhorn_source: none (IFOS-derived from operator's approve/edit UX)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:197:    canonical_fields:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:200:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:204:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:210:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:223:        notes: bullhorn_id or IFOS slug. Used in the entity_links join below.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:226:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:244:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:250:        required: true
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:268:    description: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:339:additional_relationships:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:345:    description: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:354:    description: |
docs/verticals/recruitment/vertical-schema.yaml:33:#   - description: 1-2 sentence definition in the IFOS canonical vocabulary
docs/verticals/recruitment/vertical-schema.yaml:34:#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:40:# `required: true` means the entity cannot be persisted without this field set; `required: false` means nullable.
docs/verticals/recruitment/vertical-schema.yaml:45:entities:
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:49:    description: |
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:57:    canonical_fields:
docs/verticals/recruitment/vertical-schema.yaml:58:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:60:        required: true
docs/verticals/recruitment/vertical-schema.yaml:65:        required: true
docs/verticals/recruitment/vertical-schema.yaml:69:        required: true
docs/verticals/recruitment/vertical-schema.yaml:86:        required: true
docs/verticals/recruitment/vertical-schema.yaml:98:        required: true
docs/verticals/recruitment/vertical-schema.yaml:102:        required: true
docs/verticals/recruitment/vertical-schema.yaml:154:    description: |
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:162:    canonical_fields:
docs/verticals/recruitment/vertical-schema.yaml:166:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:168:        required: true
docs/verticals/recruitment/vertical-schema.yaml:173:        required: true
docs/verticals/recruitment/vertical-schema.yaml:177:        required: true
docs/verticals/recruitment/vertical-schema.yaml:189:        required: true
docs/verticals/recruitment/vertical-schema.yaml:222:    description: |
docs/verticals/recruitment/vertical-schema.yaml:224:    bullhorn_source: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:229:    canonical_fields:
docs/verticals/recruitment/vertical-schema.yaml:230:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:232:        required: true
docs/verticals/recruitment/vertical-schema.yaml:236:        required: true
docs/verticals/recruitment/vertical-schema.yaml:259:        required: true
docs/verticals/recruitment/vertical-schema.yaml:272:        required: true
docs/verticals/recruitment/vertical-schema.yaml:284:    description: |
docs/verticals/recruitment/vertical-schema.yaml:286:    bullhorn_source: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:290:    canonical_fields:
docs/verticals/recruitment/vertical-schema.yaml:291:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:293:        required: true
docs/verticals/recruitment/vertical-schema.yaml:297:        required: true
docs/verticals/recruitment/vertical-schema.yaml:301:        required: true
docs/verticals/recruitment/vertical-schema.yaml:329:        required: true
docs/verticals/recruitment/vertical-schema.yaml:333:        required: true
docs/verticals/recruitment/vertical-schema.yaml:342:    description: |
docs/verticals/recruitment/vertical-schema.yaml:344:    bullhorn_source: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:351:    canonical_fields:
docs/verticals/recruitment/vertical-schema.yaml:352:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:354:        required: true
docs/verticals/recruitment/vertical-schema.yaml:358:        required: true
docs/verticals/recruitment/vertical-schema.yaml:361:      description:
docs/verticals/recruitment/vertical-schema.yaml:368:        required: true
docs/verticals/recruitment/vertical-schema.yaml:413:        required: true
docs/verticals/recruitment/vertical-schema.yaml:418:        required: true
docs/verticals/recruitment/vertical-schema.yaml:422:        required: true
docs/verticals/recruitment/vertical-schema.yaml:430:    description: |
docs/verticals/recruitment/vertical-schema.yaml:432:    bullhorn_source: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:437:    canonical_fields:
docs/verticals/recruitment/vertical-schema.yaml:438:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:440:        required: true
docs/verticals/recruitment/vertical-schema.yaml:444:        required: true
docs/verticals/recruitment/vertical-schema.yaml:453:        required: true
docs/verticals/recruitment/vertical-schema.yaml:458:        required: true
docs/verticals/recruitment/vertical-schema.yaml:478:        required: true
docs/verticals/recruitment/vertical-schema.yaml:488:        required: true
docs/verticals/recruitment/vertical-schema.yaml:496:    description: |
docs/verticals/recruitment/vertical-schema.yaml:498:    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
docs/verticals/recruitment/vertical-schema.yaml:504:    canonical_fields:
docs/verticals/recruitment/vertical-schema.yaml:505:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:507:        required: true
docs/verticals/recruitment/vertical-schema.yaml:511:        required: true
docs/verticals/recruitment/vertical-schema.yaml:524:        required: true
docs/verticals/recruitment/vertical-schema.yaml:528:        required: true
docs/verticals/recruitment/vertical-schema.yaml:536:    description: |
docs/verticals/recruitment/vertical-schema.yaml:538:    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
docs/verticals/recruitment/vertical-schema.yaml:544:    canonical_fields:
docs/verticals/recruitment/vertical-schema.yaml:545:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:547:        required: true
docs/verticals/recruitment/vertical-schema.yaml:551:        required: true
docs/verticals/recruitment/vertical-schema.yaml:555:        required: true
docs/verticals/recruitment/vertical-schema.yaml:559:        required: true
docs/verticals/recruitment/vertical-schema.yaml:563:        required: true
docs/verticals/recruitment/vertical-schema.yaml:567:        required: true
docs/verticals/recruitment/vertical-schema.yaml:583:relationships:
docs/verticals/recruitment/vertical-schema.yaml:589:    description: A candidate may have multiple placements over time (different clients, different roles). A placement has exactly one candidate.
docs/verticals/recruitment/vertical-schema.yaml:598:    description: Each placement fills exactly one brief; a brief may have multiple placements over time (replacement hires, multiple seats).
docs/verticals/recruitment/vertical-schema.yaml:605:    description: Each brief is owned by exactly one client (the hiring company).
docs/verticals/recruitment/vertical-schema.yaml:612:    description: Each brief has a designated decision-maker contact at the client (the hiring manager).
docs/verticals/recruitment/vertical-schema.yaml:622:    description: Each contact works at one client (the simplifying v0.1 assumption — multi-employer contacts deferred to v1.1+).
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:636:    description: Some candidates are referred by a contact (a candidate's previous manager, peer, etc., who is in the IFOS contact registry).
docs/verticals/recruitment/vertical-schema.yaml:643:    description: An opportunity is a candidate's progression toward a specific brief.
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:651:    description: Each opportunity is about exactly one candidate; a candidate may have multiple opportunities (different briefs).
docs/verticals/recruitment/vertical-schema.yaml:658:    description: Each timesheet relates to one (contract) placement; a placement has 0..N timesheets over its duration.
docs/verticals/recruitment/vertical-schema.yaml:669:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:739:bullhorn_mapping:
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:814:  Q4_system_agents_not_entities:

exec
/bin/zsh -lc "ruby -e 'require \"yaml\"; YAML.load_file(\"docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml\"); puts \"ok\"'" in /Users/madsadmin/code/CortexOS
 succeeded in 183ms:
ok

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql | sed -n '138,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '669,735p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
   138	-- §5 — Create recent_edit table
   139	-- ----------------------------------------------------------------------------
   140	
   141	CREATE TABLE IF NOT EXISTS recent_edit (
   142	  id                     BIGSERIAL PRIMARY KEY,
   143	  tenant_slug            TEXT        NOT NULL,
   144	  agent_name             TEXT        NOT NULL,
   145	  action_type            TEXT        NOT NULL,
   146	  target_entity_type     TEXT,
   147	  target_entity_id       TEXT,
   148	  original_text          TEXT        NOT NULL,
   149	  edited_text            TEXT,
   150	  edit_distance          INTEGER     CHECK (edit_distance IS NULL OR edit_distance >= 0),
   151	  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
   152	  resolved_at            TIMESTAMPTZ NOT NULL,
   153	  tone_rules_triggered   TEXT[]      NOT NULL DEFAULT '{}',
   154	  created_at             TIMESTAMPTZ NOT NULL DEFAULT now()
   155	);
   156	
   157	-- Length caps enforced at insert time by operator UX, not DDL (Postgres TEXT
   158	-- has no natural cap; the v0.2 schema doc declares 8192 chars + truncation).
   159	
   160	CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
   161	CREATE INDEX IF NOT EXISTS recent_edit_tenant_action_idx ON recent_edit (tenant_slug, action_type, resolved_at DESC);
   162	CREATE INDEX IF NOT EXISTS recent_edit_lookback_idx ON recent_edit (tenant_slug, resolved_at DESC);
   163	
   164	ALTER TABLE recent_edit ENABLE ROW LEVEL SECURITY;
   165	ALTER TABLE recent_edit FORCE ROW LEVEL SECURITY;
   166	DROP POLICY IF EXISTS recent_edit_tenant_isolation ON recent_edit;
   167	CREATE POLICY recent_edit_tenant_isolation ON recent_edit
   168	  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
   169	
   170	-- ----------------------------------------------------------------------------
   171	-- §6 — Grants for ifos_app role
   172	-- ----------------------------------------------------------------------------
   173	-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
   174	-- Voice corpus + tone_rule are mutable (re-index + rule revisions).
   175	-- ----------------------------------------------------------------------------
   176	
   177	GRANT SELECT, INSERT, UPDATE        ON voice_corpus        TO ifos_app;
   178	GRANT SELECT, INSERT, UPDATE, DELETE ON voice_corpus_chunks TO ifos_app;
   179	GRANT SELECT, INSERT, UPDATE, DELETE ON tone_rule           TO ifos_app;
   180	GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
   181	
   182	GRANT USAGE, SELECT ON SEQUENCE voice_corpus_id_seq        TO ifos_app;
   183	GRANT USAGE, SELECT ON SEQUENCE voice_corpus_chunks_id_seq TO ifos_app;
   184	GRANT USAGE, SELECT ON SEQUENCE tone_rule_id_seq           TO ifos_app;
   185	GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
   186	
   187	-- ----------------------------------------------------------------------------
   188	-- §6.5 — Table ownership note
   189	-- ----------------------------------------------------------------------------
   190	-- v0.2 tables should be owned by `postgres`, not `ifos_app`. Day-11 finding:
   191	-- when the migration runs as ifos_app via SSH tunnel, the new tables become
   192	-- owned by ifos_app, conferring implicit UPDATE + DELETE privileges that
   193	-- bypass the GRANT-based append-only model (T5 invariant). FORCE ROW LEVEL
   194	-- SECURITY (above) prevents the owner-RLS-bypass, but only ownership
   195	-- transfer prevents the privilege bypass. The transfer requires postgres
   196	-- superuser; it's run once on the VPS, separate from this migration:
   197	--
   198	--   sudo -u postgres psql -d ifos_v2 <<EOF
   199	--   ALTER TABLE voice_corpus OWNER TO postgres;
   200	--   ALTER TABLE voice_corpus_chunks OWNER TO postgres;
   201	--   ALTER TABLE tone_rule OWNER TO postgres;
   202	--   ALTER TABLE recent_edit OWNER TO postgres;
   203	--   ALTER SEQUENCE voice_corpus_id_seq OWNER TO postgres;
   204	--   ALTER SEQUENCE voice_corpus_chunks_id_seq OWNER TO postgres;
   205	--   ALTER SEQUENCE tone_rule_id_seq OWNER TO postgres;
   206	--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
   207	--   EOF
   208	--
   209	-- v1.1 architecture proposal: migrations run via a `migrations` role that
   210	-- has CREATE on schema but isn't the same as `ifos_app`. Pre-bakes ownership.
   211	-- ----------------------------------------------------------------------------
   212	
   213	-- ----------------------------------------------------------------------------
   214	-- §7 — Extend entities.data JSONB with 6 voice-score keys
   215	-- ----------------------------------------------------------------------------
   216	-- entities.data is JSONB so the 6 new fields land as keys, no DDL needed for
   217	-- the field additions themselves. We DO add validation triggers to ensure
   218	-- the score values stay in [0.0, 1.0] when present.
   219	-- ----------------------------------------------------------------------------
   220	

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '36,225p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "rg --files docs | rg 'bullhorn-integration-path|sequencing-target|operational-hygiene|codex-disagreement-2026-05-24-diagnostic-gate-a|ADR-006|adr-006|ADR-002|adr-002'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg -n \"§4\\.1|A3|A4|A6|No direct Bullhorn|Candidate|ClientCorporation|JobOrder|Note|Placement|Opportunity|Timesheet\" docs/verticals/recruitment docs/decisions -g '*.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
docs/runbooks/operational-hygiene-protocol.md

 succeeded in 0ms:
docs/decisions/autosend-safety-policy.md:96:| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
docs/decisions/autosend-safety-policy.md:102:| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
docs/decisions/autosend-safety-policy.md:223:  - bullhorn_note_customer_visible   # orange (CANONICAL — bullhorn-integration-path §4.1)
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:221:| Round | New issues | Cumulative unique | Notes |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:263:- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/2026-05-18-codex-ratification-manifest.md:33:| 18 | `docs/verticals/recruitment/vertical-schema.yaml` | Proposed | Verify 8 entities + 89 fields + 10 relationships + agent R/W matrix + 12 open_questions; cross-check Bullhorn mapping against §4.1 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/brain-ui-scope.md:40:- Surfaces entity activity in the last 24h across the brain — recently-updated entities (Candidates, Clients, Briefs, Placements, Contacts per `second-brain-design.md` §2.2).
docs/decisions/brain-ui-scope.md:42:- Highlights pending approvals (Concierge auto-send escalations per `bullhorn-integration-path.md` §4.1 row 4).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/v1.0-kill-criterion.md:7:**Surfaced by:** Master brief Day 5 spec; folds carry-forwards from `sequencing-target.md` §6.6 + `bullhorn-integration-path.md` §4.1 + Day-4 §11 closing-commit work.
docs/decisions/ADR-003-agent-bundle-renderer.md:37:Three alternatives rejected per design §3.1: `packages/brain/agent-cli/` (wrong cohesion — brain is wiki, renderer is not a wiki concern); `scripts/render-agent.sh` (JSON Schema validation + YAML parsing harder in shell); new top-level directory (loses master brief §4.1 line 195-204 `packages/` convention).
docs/decisions/ADR-003-agent-bundle-renderer.md:72:### Edit A — Master brief §4.1 directory list
docs/decisions/ADR-003-agent-bundle-renderer.md:74:**Current** (master brief §4.1 lines 195-204):
docs/decisions/ADR-003-agent-bundle-renderer.md:94:Lands in this ADR's commit. Edit A is the minimum required to make `packages/agent-renderer/` a canonical IFOS package per master brief §4.1; Week-1 renderer implementation depends on the path existing.
docs/decisions/ADR-003-agent-bundle-renderer.md:163:1. Edits A and B applied to master brief §4.1 and §8.3 in this batch's commit.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:68:- **Sequencing:** `docs/decisions/sequencing-target.md` §4.1 ratifies the 6-agent build order; renderer is Week 1-2 prerequisite for the Diagnostic W3-4 first render per ADR-003 §5.2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/autosend-approval-bridge-spec.md:158:Action: write customer-visible Bullhorn Note
docs/decisions/autosend-approval-bridge-spec.md:241:| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |
docs/decisions/autosend-approval-bridge-spec.md:242:| A4 | 4h timeout: bridge calls `updateApproval(..., 'denied', 'ifos_timeout')` cleanly | Integration test: write `.pending` marker, advance simulated clock 4h, assert cortextOS `pending/` is empty + `resolved/` has `denied` record |
docs/decisions/autosend-approval-bridge-spec.md:244:| A6 | RLS: bridge writing tenant-A's approval cannot leak tenant-B's pending markers | Tenancy audit T11 extension: cross-tenant marker read returns 0 |
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:118:### 2.3 — A3 Scribe
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:131:### 2.4 — A4 Cash Conductor
docs/decisions/sequencing-target.md:159:### 2.6 — A6 Concierge
docs/decisions/sequencing-target.md:164:| 2. Substrate exercise | **Maximum** | **All** of cortextOS Primitives 1+2+4+5 exercised. **First exercise of Primitive 2** (71-hour context rotation per Day 1 cortextos-primitive-status.md) — Concierge holds long-running state across 24+ months of candidate lifecycle. First Bullhorn webhook exercise per Day 2 §4.2 (with 5-minute polling fallback). Per `bullhorn-integration-path.md` §4.1 row 4: reads Candidate, ClientCorporation, JobOrder, Placement, Note + writes Note, Candidate state-fields, Placement state-fields |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:183:W6:   Scribe (A3)
docs/decisions/sequencing-target.md:184:W7-8: Cash Conductor (A4) — Hire-#1-anchored per Ultraplan §9 line 766
docs/decisions/sequencing-target.md:186:W10-13: Concierge (A6)
docs/decisions/sequencing-target.md:208:W5-8: Concierge (A6) — front-load the flagship (XL/4 weeks)
docs/decisions/sequencing-target.md:210:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:212:W12-13: Cash Conductor (A4)
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:230:W6-9: Concierge (A6) — Risk #1 derisk via Tier-1 + Primitive 2 first exercise
docs/decisions/sequencing-target.md:231:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:232:W11:  Cash Conductor (A4)
docs/decisions/sequencing-target.md:240:1. **Concierge depends on Scribe** for Notes-for-context (per `bullhorn-integration-path.md` §4.1 row 4 — Concierge reads Notes Scribe wrote). Building Concierge at W6-9 before Scribe (W10) means Concierge's first-month operation has empty Note context. Materially degrades the Tier-1 always-on demo.
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:255:| 4. Commercial value | Tied (Diagnostic substrate, then flagship Concierge last; closing demo at W12-13 per Ultraplan §9 line 781) | Wins on raw timing (Concierge W5-8 demoable earlier) — but loses on substrate quality (Concierge ships with degraded Notes-for-context) | Tied — Concierge W6-9 marginally earlier than Alpha but with same substrate gaps as Beta |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:286:| 6 | W10-13 | **Concierge** (A6) | XL build; flagship closing demo; first Primitive-2 (71h context rotation) exercise |
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:325:- The 6-agent sequence per §4.1, including Cash Conductor's W7-8 Hire-#1 anchor.
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:408:First exercise is Janitor at W5 per §4.1 row 2. **If Day 2 Sub-decisions A and B haven't flipped from Proposed to Accepted by start of W4** (per `bullhorn-integration-path.md` §1.3 commercial-blocker table), this is the natural blocker. Founder Sunday/Monday commercial conversations must land before W4 start to keep the Janitor W5 slot intact. Sub-decision C is already Accepted so the endpoint surface is buildable; the gate is auth path (A) and client_credentials foreclosure (B).
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:60:- Whether **marketplace-tier API access differs from direct-API access** in rate limits, available scopes (e.g. write to JobOrder, write to Note, webhook subscription), or sandbox availability. Bullhorn's public docs are sparse on the deltas; partner reps know the actuals.
docs/decisions/bullhorn-integration-path.md:66:| Sub-decision | Commercial gate question | Who answers | When | Notes |
docs/decisions/bullhorn-integration-path.md:171:| Scope / rate-limit deltas | **CG.** Marketplace tier may grant elevated rate limits, write access to additional entities (e.g. JobOrder write), webhook subscription endpoints not available to direct-tier. Public docs do not state. | Public REST API documentation lists all REST endpoints uniformly — no tier-gated endpoints stated in public docs. Inference: all entity reads/writes are available to authenticated direct-tier callers, subject to per-corpToken scope at the tenant-account-admin level. Rate limit ceiling **CG**. |
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:304:| Integration point | v1.0 mechanism | Cadence | Notes |
docs/decisions/bullhorn-integration-path.md:306:| Janitor Candidate sweep | Polling (full-table scan per sweep) | Nightly 02:00 | Initial sweep is bounded by per-tenant Candidate count; subsequent sweeps use `dateLastModified` filter to limit to changes-since-last-sweep |
docs/decisions/bullhorn-integration-path.md:307:| Janitor Note / ClientCorporation / JobOrder sweep | Polling | Nightly 02:00 | Same `dateLastModified` filter pattern |
docs/decisions/bullhorn-integration-path.md:308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
docs/decisions/bullhorn-integration-path.md:311:| Concierge time-based nurture cadence | Cron (week-1, month-1, month-3, month-6, month-12, month-24) | Per Placement-creation anchor date | No Bullhorn webhook needed — IFOS-side cron fires; IFOS reads Bullhorn for current state then writes the comm Note back |
docs/decisions/bullhorn-integration-path.md:334:| Janitor (nightly sweep) | 200-400 during active sweep window (concentrated 1-2 hour burst) | Burst-tolerant; bounded by tenant Candidate-count and `dateLastModified` filter efficiency |
docs/decisions/bullhorn-integration-path.md:404:Per §2.4 + §5: connector scaffolds at `packages/mcp-connectors/bullhorn/` against direct-API auth-code flow. Auth module isolated per §1.4 fallback architecture (~200-400 lines bounded per `agent-bundle-renderer-design.md` §3.3.4). Endpoint surface from §4.1 drives the connector's exposed `tools.yaml` scopes. Refresh-loop per §4.5 ships with the connector.
docs/decisions/bullhorn-integration-path.md:419:Concierge's write capability to Bullhorn (Note auto-send, status updates per §4.1) interacts with Day 5's auto-send safety policy artefact. Day 5 should reference this document's §4.1 Concierge row for the specific entities Concierge will be writing — Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI.
docs/decisions/bullhorn-integration-path.md:423:Bullhorn entity field mapping (Candidate, JobOrder, Placement, Note, ClientCorporation) → IFOS wiki schema per `second-brain-design.md` §2.2 entity types. Out of scope for this Day-2 decision; flagged for Week 11-13 work. Concrete handoff: §4.1's per-agent read-entity list is the v1.0 minimum set the wiki ingest paths must handle.
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |

exec
/bin/zsh -lc 'rg -n "Phase 4|Cat-β|Scribe|Cash Conductor|Concierge|schema gaps|ADR-006|Tier 2" docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md docs/decisions 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:45:**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:90:2. **Accept Issue 2 fix** (mechanical; bundles with Concierge notification work)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:123:| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:263:- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:274:| Scribe | 5 | `20260524T112917Z-82352` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:275:| Cash Conductor | 5 | `20260524T113038Z-83732` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:277:| Concierge | 7 | `20260524T113247Z-86019` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:297:- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:299:- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:300:- `ESC_OPEN_BANKING_TOKEN_AGING` — Cash Conductor uses <30 days warn / <7 days blocking staged; catalogue defines ≤14 days info. Resolution: align catalogue to Cash Conductor's actual staged definition.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:301:- `ESC_AUTOSEND_RACE` — Cash Conductor uses for payment-received-during-chase race; catalogue defines for two-agents-same-payload_hash race. Resolution: widen to cover both.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:316:  - Scribe Steps 2-3, 7 partial coverage
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:317:  - Cash Conductor Steps 7-8, 11
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:319:  - Concierge Steps 7, 11
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:355:- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:357:- `ESC_LIFECYCLE_STATE_UNKNOWN` — both Janitor placement + Concierge taxonomy out-of-bounds
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:358:- `ESC_OPEN_BANKING_TOKEN_AGING` — three staged behaviors aligned to Cash Conductor §6
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:372:| Scribe | 5 | 4 | −1 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:373:| Cash Conductor | 5 | 5 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:375:| Concierge | 7 | 5 | −2 (AgentMail boundary + ESC widening) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:422:**Per-agent state at Phase 4 close:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:45:**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:90:2. **Accept Issue 2 fix** (mechanical; bundles with Concierge notification work)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:123:| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:263:- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:274:| Scribe | 5 | `20260524T112917Z-82352` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:275:| Cash Conductor | 5 | `20260524T113038Z-83732` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:277:| Concierge | 7 | `20260524T113247Z-86019` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:297:- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:299:- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:300:- `ESC_OPEN_BANKING_TOKEN_AGING` — Cash Conductor uses <30 days warn / <7 days blocking staged; catalogue defines ≤14 days info. Resolution: align catalogue to Cash Conductor's actual staged definition.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:301:- `ESC_AUTOSEND_RACE` — Cash Conductor uses for payment-received-during-chase race; catalogue defines for two-agents-same-payload_hash race. Resolution: widen to cover both.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:316:  - Scribe Steps 2-3, 7 partial coverage
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:317:  - Cash Conductor Steps 7-8, 11
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:319:  - Concierge Steps 7, 11
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:355:- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:357:- `ESC_LIFECYCLE_STATE_UNKNOWN` — both Janitor placement + Concierge taxonomy out-of-bounds
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:358:- `ESC_OPEN_BANKING_TOKEN_AGING` — three staged behaviors aligned to Cash Conductor §6
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:372:| Scribe | 5 | 4 | −1 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:373:| Cash Conductor | 5 | 5 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:375:| Concierge | 7 | 5 | −2 (AgentMail boundary + ESC widening) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:422:**Per-agent state at Phase 4 close:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:19:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:58:**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:74:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:103:- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:118:- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:119:- Sample rate configurable per tenant via field landing in the future W4-polish vertical-schema supplement (concrete field name + type specified there alongside the Tier 2 writer + sampling-activation work; NOT in v0.3 supplement — v0.3 explicitly defers per its §5 `deferred_to_future_adr` block to avoid speculative schema without a current consumer)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:138:| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:150:- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:152:*End of ADR-006.*
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:20:**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:32:**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:34:**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:147:**Recommended order:** D5 (quickest, unblocks Round 2) → D1 (Concierge planning) → D2 + D3 (legal bundle) → D4 (no-rush).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:167:OR open a follow-on ADR if the decision warrants more substantive recording (e.g., ADR-005 for D1; ADR-006 for D2 + D3 bundle).
docs/decisions/brain-ui-scope.md:28:3. What the first paying design partner asks for after Concierge ships in v1.0 — direct user-research input.
docs/decisions/brain-ui-scope.md:42:- Highlights pending approvals (Concierge auto-send escalations per `bullhorn-integration-path.md` §4.1 row 4).
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/decisions/autosend-approval-bridge-spec.md:4:**Date:** 2026-05-22 (Day 11, pre-Concierge W10 prerequisite)
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:154:🔔 Approval request: Concierge bullhorn_note_customer_visible
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/autosend-approval-bridge-spec.md:257:- Day 4 (Concierge W10 start): Concierge uses bridge from day 1
docs/decisions/autosend-approval-bridge-spec.md:259:**Alternative:** as the next IFOS Claude slice (now). Pre-builds the prerequisite before Diagnostic W3-4 starts, so it's not blocking Concierge. ~2-3 days inserted before Diagnostic.
docs/decisions/autosend-approval-bridge-spec.md:308:- Unblocks Concierge build (W10-13) — without this, Concierge can only ship as drafts-only (D1-A) which loses the demo value prop
docs/decisions/ADR-004-renderer-implementation-deviations.md:68:- ADR-003 §2.3 worked-Concierge-example output diagram says `_shared/` lives at `orgs/acme/agents/_shared/` — that's correct, the bug is only in the symlink-target text. Diagram is right; symlink string is wrong.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:26:- `vertical-schema.v0.2-supplement.yaml` (Phase 4, commit `45b59e0`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:83:| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:86:| Concierge | `bullhorn_brief_read` | Read of inbound brief; idempotent; no comms |
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/autosend-safety-policy.md:95:| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
docs/decisions/autosend-safety-policy.md:96:| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
docs/decisions/autosend-safety-policy.md:102:| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
docs/decisions/autosend-safety-policy.md:103:| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
docs/decisions/autosend-safety-policy.md:104:| Concierge | `twilio_sms_send` | Outbound SMS; high-trust channel; cost-per-send; irreversible |
docs/decisions/autosend-safety-policy.md:105:| Concierge | `calendar_invite_send` | Creates calendar event with attendee notification; visible to attendee |
docs/decisions/autosend-safety-policy.md:106:| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
docs/decisions/autosend-safety-policy.md:107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
docs/decisions/autosend-safety-policy.md:215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/decisions/v1.0-kill-criterion.md:85:- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/ADR-003-agent-bundle-renderer.md:17:The design document (`docs/architecture/agent-bundle-renderer-design.md`) specified the renderer across five sections: source vs target layout (§1), the 12-row file mapping + R2 commitment + Concierge worked example (§2), six concrete mechanism decisions including TypeScript Node at `packages/agent-renderer/` (§3.1), manual developer invocation (§3.2), Option γ for `_shared/` origination (§3.3.3), and overwrite-no-merge re-render policy (§3.4), seven failure modes with exit codes (§4), and integration with the broader build (§5). 22 spec gaps surfaced and bucketed. This ADR ratifies the design's recommendations.
docs/decisions/ADR-003-agent-bundle-renderer.md:54:The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:21:| 6 | Scribe |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:22:| 7-8 | Cash Conductor |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:24:| 10-13 | Concierge |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:46:| **A. Accept the floor** | Leave `pollInterval` at the 1000ms default. Rewrite Ultraplan §3.2's "four-agent pipelines complete in seconds" to "four-agent pipelines complete in 3-5 seconds end-to-end" and remove any "sub-second handoff" framing from the closing-demo deck | Zero engineering | Honest signal; Concierge's "30-min lifecycle event → drafted comms" SLA is unaffected (3-5s is rounding error against 30 minutes); Brief Decoder's "90-min brief-to-shortlist" is also unaffected. Only sales narrative changes. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:52:2. The user-visible SLAs (Concierge 30-min lifecycle event, Brief Decoder 90-min shortlist, Triage 60-second response) all have ≥30× headroom against a 3-5 second pipeline floor. The pipeline-latency claim is sales narrative, not product SLA.
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:74:Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:118:### 2.3 — A3 Scribe
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:131:### 2.4 — A4 Cash Conductor
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:139:| 5. Dependencies | **Upstream:** none on other agents (Xero/QuickBooks/Sage + Open Banking infra independent of Bullhorn path). **Downstream:** none in v1.0 (Cash Conductor's outputs are tenant-internal chase emails + DSO reports, not consumed by other v1.0 agents) | Low cross-agent coupling |
docs/decisions/sequencing-target.md:142:**Hire-#1 anchor (per Ultraplan §9 line 766 verbatim):** "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)." Cash Conductor's three-accounting-API + Open-Banking integration is the right scope for Hire #1's first sprint per Ultraplan §9 — this places Cash Conductor at W7-8 in the canonical sequence.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:159:### 2.6 — A6 Concierge
docs/decisions/sequencing-target.md:164:| 2. Substrate exercise | **Maximum** | **All** of cortextOS Primitives 1+2+4+5 exercised. **First exercise of Primitive 2** (71-hour context rotation per Day 1 cortextos-primitive-status.md) — Concierge holds long-running state across 24+ months of candidate lifecycle. First Bullhorn webhook exercise per Day 2 §4.2 (with 5-minute polling fallback). Per `bullhorn-integration-path.md` §4.1 row 4: reads Candidate, ClientCorporation, JobOrder, Placement, Note + writes Note, Candidate state-fields, Placement state-fields |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:183:W6:   Scribe (A3)
docs/decisions/sequencing-target.md:184:W7-8: Cash Conductor (A4) — Hire-#1-anchored per Ultraplan §9 line 766
docs/decisions/sequencing-target.md:186:W10-13: Concierge (A6)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:194:- W7-8: Risk #1 (cortextOS Primitives 1+4+5) — Cash Conductor first Tier-1. Reduction trigger fires.
docs/decisions/sequencing-target.md:197:- Risk #5 final reduction (all 5 bundles render cleanly) waits for Concierge W10-13.
docs/decisions/sequencing-target.md:198:- Bullhorn webhook coverage gaps surface only at Concierge W10-13 (Ultraplan §8.1 line 569 caveat).
docs/decisions/sequencing-target.md:200:**Cost if deferred risk materialises late:** if Bullhorn webhook coverage is worse than expected (Risk #2 secondary), Concierge polling cadence increases (per Day 2 §4.2 fallback) — connector-internal change, no agent rework. Bounded.
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:208:W5-8: Concierge (A6) — front-load the flagship (XL/4 weeks)
docs/decisions/sequencing-target.md:210:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:212:W12-13: Cash Conductor (A4)
docs/decisions/sequencing-target.md:215:**Why this ordering:** Get the flagship demoable agent (Concierge) live earliest to accelerate first-pilot conversion per Ultraplan §9 line 725 target Week 12.
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:230:W6-9: Concierge (A6) — Risk #1 derisk via Tier-1 + Primitive 2 first exercise
docs/decisions/sequencing-target.md:231:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:232:W11:  Cash Conductor (A4)
docs/decisions/sequencing-target.md:236:**Why this ordering:** Front-load risk-de-risking by building Concierge (the most Primitive-heavy agent) early. Cash Conductor's Risk #1 exercise becomes redundant if Concierge already exercises Primitives 1+2+4+5.
docs/decisions/sequencing-target.md:240:1. **Concierge depends on Scribe** for Notes-for-context (per `bullhorn-integration-path.md` §4.1 row 4 — Concierge reads Notes Scribe wrote). Building Concierge at W6-9 before Scribe (W10) means Concierge's first-month operation has empty Note context. Materially degrades the Tier-1 always-on demo.
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:242:3. **Hire-#1 anchor broken.** Cash Conductor at W11 is 4 weeks after Hire #1's assumed W7 start. Hire #1 again has no first-sprint scope.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:255:| 4. Commercial value | Tied (Diagnostic substrate, then flagship Concierge last; closing demo at W12-13 per Ultraplan §9 line 781) | Wins on raw timing (Concierge W5-8 demoable earlier) — but loses on substrate quality (Concierge ships with degraded Notes-for-context) | Tied — Concierge W6-9 marginally earlier than Alpha but with same substrate gaps as Beta |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:269:**Alpha is the only sequence that survives both documented contingencies cleanly.** Beta and Gamma each forces a Concierge rewrite if their respective trigger fires.
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:286:| 6 | W10-13 | **Concierge** (A6) | XL build; flagship closing demo; first Primitive-2 (71h context rotation) exercise |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:294:The Hire-#1 anchor at W7-8 per Ultraplan §9 line 766 is load-bearing — Cash Conductor's three-accounting-API + Open-Banking work is well-scoped for Hire #1's first sprint. Beta and Gamma both displace Cash Conductor past W7-8 (W12-13 and W11 respectively), leaving Hire #1 with no first-sprint scope per §3.2 and §3.3 structural defects.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:325:- The 6-agent sequence per §4.1, including Cash Conductor's W7-8 Hire-#1 anchor.
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:332:- Concierge W10-13's four-week build broken into specific weekly sub-tasks — deferred to Week 9 Concierge-build-planning session (just-in-time scoping).
docs/decisions/sequencing-target.md:333:- v1.1 Triage agent's relationship to v1.0 Concierge's auto-send categories — deferred to v1.1 planning.
docs/decisions/sequencing-target.md:334:- Whether Cash Conductor's 2-week build can compress if Hire #1 onboarding is fast — deferred to Week 7 Cash-Conductor-kickoff check-in.
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:418:- W13 Concierge final-render-clean → **Low** (all 5 v1.0 bundles render and pass validation per RISK-REGISTER #5 final reduction trigger).
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:311:| Concierge time-based nurture cadence | Cron (week-1, month-1, month-3, month-6, month-12, month-24) | Per Placement-creation anchor date | No Bullhorn webhook needed — IFOS-side cron fires; IFOS reads Bullhorn for current state then writes the comm Note back |
docs/decisions/bullhorn-integration-path.md:313:**v1.1+ upgrade path:** if Sub-decision A commercial verification reveals marketplace-tier event subscriptions, Concierge upgrades from 5-minute polling to webhook-primary with polling fallback. The polling cycle becomes a heartbeat-style consistency check. No agent-bundle-content changes; only `tools.yaml` MCP scope declaration and the connector's auth/subscription module.
docs/decisions/bullhorn-integration-path.md:335:| Scribe (write-on-event) | 50-100 distributed | Event-rate-bounded; one call typically = 5-15 REST writes |
docs/decisions/bullhorn-integration-path.md:337:| Concierge (real-time + 5-min poll) | 100-300 distributed | Two streams: lifecycle-event-driven writes (low volume) + polling-cycle reads (continuous, bounded by entity-count) |
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:419:Concierge's write capability to Bullhorn (Note auto-send, status updates per §4.1) interacts with Day 5's auto-send safety policy artefact. Day 5 should reference this document's §4.1 Concierge row for the specific entities Concierge will be writing — Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI.
docs/decisions/bullhorn-integration-path.md:511:| §4.2-A: assume v1.0 pull-only (no webhook coverage) per public REST docs | Sub-decision A commercial verification reveals marketplace-tier event subscriptions — Concierge upgrades to webhook-primary in v1.1+ |

exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|TrueLayer|Plaid|Xero|QuickBooks|Sage|Fathom|Fireflies" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
613:      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
649:      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
663:      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}

exec
/bin/zsh -lc "rg -n \"cash_conductor_transactions|cash_conductor_invoices|cash_conductor_last_run|concierge_last_poll|concierge_send_window|linkedin_url|preferred_channel|must_haves|placement_status|hiring_velocity_band\" agents docs packages scripts -g '"'!docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
scripts/run-tenancy-audit.sh:69:# v0.3 supplement adds 2 auxiliary tables: cash_conductor_transactions +
scripts/run-tenancy-audit.sh:70:# cash_conductor_invoices (both RLS-isolated; same tenant_isolation policy
scripts/run-tenancy-audit.sh:75:  cash_conductor_transactions cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:59:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:62:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:92:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:95:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:99:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:100:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:102:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:107:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:110:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:113:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:148:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:151:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:158:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:159:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:161:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:165:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:166:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:234:    IF d ? 'linkedin_url' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:235:      IF jsonb_typeof(d->'linkedin_url') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:236:        RAISE EXCEPTION 'linkedin_url must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:238:      IF d->>'linkedin_url' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:239:         AND d->>'linkedin_url' !~ '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:240:        RAISE EXCEPTION 'linkedin_url does not match expected pattern: %', d->>'linkedin_url';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:247:    IF d ? 'preferred_channel' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:248:      IF (d->>'preferred_channel') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:251:        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:272:    IF d ? 'must_haves' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:273:      IF jsonb_typeof(d->'must_haves') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:274:        RAISE EXCEPTION 'must_haves must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:276:      IF jsonb_array_length(d->'must_haves') > 15 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:277:        RAISE EXCEPTION 'must_haves max length 15';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:279:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:281:          RAISE EXCEPTION 'must_haves items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:311:    IF d ? 'placement_status' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:312:      IF (d->>'placement_status') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:315:        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:352:    IF d ? 'hiring_velocity_band' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:353:      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:354:        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:403:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:404:    'concierge_last_poll',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:405:    'concierge_send_window'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:424:  IF c ? 'concierge_send_window' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:425:    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:      RAISE EXCEPTION 'concierge_send_window must be object';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:428:    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:429:      RAISE EXCEPTION 'concierge_send_window must include timezone';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:431:    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:432:       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:433:      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:435:    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:436:       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:437:      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:442:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:444:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:448:  IF c ? 'concierge_last_poll' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:450:      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:475:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:477:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:481:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:483:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:486:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
agents/recruitment/cash-conductor/agent.md:160:   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
agents/recruitment/cash-conductor/agent.md:169:   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
agents/recruitment/cash-conductor/agent.md:249:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/scribe/agent.md:75:| Contact | `seniority`, `decision_authority` (enum: yes/no/influencer/blocker/unknown per Q5 v0.1), `preferred_channel`, `next_action_target_date` |
agents/recruitment/scribe/agent.md:76:| Brief | `salary_min` + `salary_max`, `start_date`, `role_type`, `must_haves` (list), `nice_to_haves` (list), `deal_breakers` (list) |
agents/recruitment/scribe/agent.md:77:| Placement | `start_date`, `placement_status`, `week_1_status_note` (free-text), `satisfaction_signal` (enum) |
agents/recruitment/scribe/agent.md:78:| Opportunity | `sector`, `headcount_growth_signal_text`, `hiring_velocity_band`, `decision_window_text` |
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:30:  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:43:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:    WHERE table_name = 'cash_conductor_invoices';
agents/recruitment/janitor/agent.md:100:   → fuzzy-match across (name, email, phone, linkedin_url) tuples
agents/recruitment/janitor/agent.md:131:   → at v1.1: linkedin.profile_fetch(candidate.linkedin_url) → location +
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:392:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
docs/architecture/tenancy-invariants.md:37:- **Documentation source:** Day-4 §6.3 lines 708-797 (5 tables) + v0.2 §2-§5 (4 tables) + v0.3 supplement §3 (2 tables: cash_conductor_transactions + cash_conductor_invoices). Total: 11 tenant-data tables.
docs/architecture/second-brain-design.md:264:linkedin_url: https://linkedin.com/in/sarah-bowen    # optional; Janitor populates
docs/architecture/second-brain-design.md:334:must_haves: [ "5+ years B2B SaaS", "UK right-to-work" ]   # required v1.0; list of strings
docs/architecture/second-brain-design.md:380:linkedin_url: https://linkedin.com/in/janesmith      # optional
docs/architecture/second-brain-design.md:382:preferred_channel: email                             # optional; one of {email, phone, linkedin}
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:289:- Janitor: `candidate.linkedin_url` not in schema
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)

codex
RATIFIED
Advisory: PII-bearing auxiliary fields such as `payee_name_raw`, `client_billing_email`, and `raw_payload` should add explicit notes referencing `autosend-safety-policy §7 payload_preview PII rules`.
tokens used
111,883
RATIFIED
Advisory: PII-bearing auxiliary fields such as `payee_name_raw`, `client_billing_email`, and `raw_payload` should add explicit notes referencing `autosend-safety-policy §7 payload_preview PII rules`.
