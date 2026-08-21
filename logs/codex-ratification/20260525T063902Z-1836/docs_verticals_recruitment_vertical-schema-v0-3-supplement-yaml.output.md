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
session id: 019e5ddb-bc94-75e3-ab0d-69871d0623dc
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

  janitor_dedup_threshold:
    type: numeric
    required: false
    default: 0.85
    range: [0.75, 0.95]
    set_by: [tenant-admin]
    read_by: [janitor]
    notes: |
      Per-tenant dedup confidence threshold for candidate merges. v1.0 default
      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
      via the wizard. The migration validator (v0.2-to-v0.3.sql §5 allowlist)
      already accepts this key; this declaration is the canonical schema
      authority added in W4 bilateral pass (Day-20) closing Janitor R11
      Codex Finding 4.

  janitor_last_run:
    type: timestamp
    required: false
    set_by: janitor
    read_by: [janitor]
    notes: |
      Janitor nightly cron updates at session-close (Step 12). Next run queries
      Bullhorn for entities created/modified since this timestamp. The migration
      validator (v0.2-to-v0.3.sql §5 allowlist) already accepts this key; this
      declaration is the canonical schema authority added in W4 bilateral pass
      (Day-20) closing Janitor R11 Codex Finding 4.

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
I’ll verify the supplement against the repo, especially the cited migration files and existing schema/access baselines, then return only the required verdict format.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '1,340p'" in /Users/madsadmin/code/CortexOS
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

codex
I found the supplement exists in the workspace and am checking whether the claimed migration/schema pairing actually matches the file contents. The first visible mismatch is that the header says “3 config keys” while the section declares five, so I’m validating whether that is cosmetic or load-bearing.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '260,620p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc 'rg -n "tenant_adapters|janitor_dedup_threshold|cash_conductor_last_run|concierge_last_poll|concierge_send_window|janitor_last_run|numeric" docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:193:          alphanumerics). This field stores the vault path; narrative does
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:742:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:747:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:756:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:765:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:791:  janitor_dedup_threshold:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:792:    type: numeric
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:806:  janitor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:880:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:882:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:920:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:955:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:967:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1005:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:190:      IF (d->>'voice_classifier_score')::numeric < 0.0
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:191:         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:202:      IF (d->>'voice_drift_at_close')::numeric < 0.0
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:203:         OR (d->>'voice_drift_at_close')::numeric > 1.0 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:383:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:390:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:    'janitor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:403:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:404:    'concierge_last_poll',
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:448:  IF c ? 'concierge_last_poll' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:450:      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:460:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:461:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();

exec
/bin/zsh -lc 'rg -n "relationships:|agent_access_matrix:|bullhorn_mapping:|candidate:|contractor:|client:|contact:|brief:|opportunity:|placement:|timesheet:" docs/verticals/recruitment/vertical-schema.yaml' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '620,1040p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
48:  candidate:
153:  contractor:
170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
221:  client:
283:  contact:
331:      do_not_contact:
341:  brief:
429:  placement:
471:      candidate_salary_at_placement:
495:  opportunity:
535:  timesheet:
557:      approved_by_client:
561:      approved_by_contractor:
583:relationships:
594:  placement_for_brief:
601:  brief_from_client:
618:  contact_works_for_client:
625:  candidate_engaged_with_contact:
632:  candidate_referred_by_contact:
639:  opportunity_for_brief:
647:  opportunity_about_candidate:
654:  timesheet_for_placement:
669:agent_access_matrix:
672:    candidate: none
673:    contractor: none
674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
675:    contact: none
676:    brief: none
677:    placement: none
678:    opportunity: none
679:    timesheet: none
683:    candidate: R+W   # full sweep + normalisation + dedup proposals
684:    contractor: R+W  # status normalisation
685:    client: R+W      # orphan-link sweep + normalisation
686:    contact: R       # read-only (Concierge owns writes)
687:    brief: R         # status drift sweep
688:    placement: R     # orphan / stale-tag sweep
689:    opportunity: none
690:    timesheet: none
693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
694:    contractor: R+W  # contractor calls same pattern
695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
696:    contact: none
697:    brief: R         # write-context resolution
698:    placement: R+W   # note links on placed-candidate calls
699:    opportunity: none
700:    timesheet: none
703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
704:    contractor: none
705:    client: none
706:    contact: none
707:    brief: none
708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
709:    opportunity: none
710:    timesheet: none
713:    candidate: R     # passive matching
714:    contractor: R    # contractor pool
715:    client: R        # target-firm context
716:    contact: none    # thin v1.0
717:    brief: R         # active brief context for matching
718:    placement: none
719:    opportunity: none
720:    timesheet: none
723:    candidate: R+W   # lifecycle state on every event
724:    contractor: R+W  # lifecycle state, contractor-specific cadence
725:    client: R        # relationship context
726:    contact: R       # decision-maker resolution for orange-tier sends
727:    brief: R         # linked-brief context
728:    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
729:    opportunity: none
730:    timesheet: none
739:bullhorn_mapping:
741:  candidate:
747:  contractor:
754:  client:
760:  contact:
765:  brief:
771:  placement:
777:  opportunity:
783:  timesheet:
844:  Q9_multi_client_contact:

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
   791	  janitor_dedup_threshold:
   792	    type: numeric
   793	    required: false
   794	    default: 0.85
   795	    range: [0.75, 0.95]
   796	    set_by: [tenant-admin]
   797	    read_by: [janitor]
   798	    notes: |
   799	      Per-tenant dedup confidence threshold for candidate merges. v1.0 default
   800	      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
   801	      via the wizard. The migration validator (v0.2-to-v0.3.sql §5 allowlist)
   802	      already accepts this key; this declaration is the canonical schema
   803	      authority added in W4 bilateral pass (Day-20) closing Janitor R11
   804	      Codex Finding 4.
   805	
   806	  janitor_last_run:
   807	    type: timestamp
   808	    required: false
   809	    set_by: janitor
   810	    read_by: [janitor]
   811	    notes: |
   812	      Janitor nightly cron updates at session-close (Step 12). Next run queries
   813	      Bullhorn for entities created/modified since this timestamp. The migration
   814	      validator (v0.2-to-v0.3.sql §5 allowlist) already accepts this key; this
   815	      declaration is the canonical schema authority added in W4 bilateral pass
   816	      (Day-20) closing Janitor R11 Codex Finding 4.
   817	
   818	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   819	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
   820	  # declare this config key; the W4 ADR will introduce both the field
   821	  # and its consumer at the same time. Including it in v0.3 without an
   822	  # active consumer would be speculative schema.
   823	
   824	# ============================================================================
   825	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   826	# ============================================================================
   827	
   828	decision_log_payload_extension:
   829	  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
   830	  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
   831	  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
   832	  # that ships alongside Tier 2 activation. v0.3 introducing the payload
   833	  # key without enforcement would violate review-schema-change §3
   834	  # (bounded values require CHECK or trigger). Tier 2 schema work owns
   835	  # the constraint + writer; this v0.3 supplement is silent on it.
   836	  deferred_to_future_adr:
   837	    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
   838	    schema_owner: future W4-polish supplement (not v0.3)
   839	    rationale: |
   840	      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
   841	      separate post-launch quality metric outside Gate A. The payload key,
   842	      its [0.0, 1.0] range validation, and the sample-rate config field
   843	      all land together with Tier 2 activation. Tier 2 doesn't activate
   844	      until the voice classifier microservice ships + first pilot tenant
   845	      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
   846	      payload shape to avoid declaring schema without enforcement.
   847	
   848	# ============================================================================
   849	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   850	# ============================================================================
   851	
   852	migration_sequence:
   853	  forward: migrations/v0.2-to-v0.3.sql
   854	  rollback: migrations/v0.3-to-v0.2.sql
   855	
   856	  pre_conditions:
   857	    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
   858	    - validate_voice_scores trigger active on entities table
   859	    - RLS + ifos_app grants from Day-4 §6.3 in place
   860	    - migration-test tenant row exists in tenants table
   861	
   862	  steps:
   863	    1: |
   864	      Verify v0.2 prerequisites (DO block in migration §1).
   865	    2: |
   866	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   867	      ifos_app grants + 2 indexes (migration §2).
   868	    3: |
   869	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   870	      (migration §3).
   871	    4: |
   872	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   873	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   874	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   875	      candidate / contact / brief / placement / opportunity entity_types.
   876	      Re-attaches the trigger to entities table (migration §4).
   877	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   878	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   879	    5: |
   880	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   881	      hard-fails on unknown config keys (Rule 2); type-validates the 3 new
   882	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   883	    6: |
   884	      Smoke verification DO block confirms both cash_conductor_*
   885	      tables exist (migration §6).
   886	    7: |
   887	      COMMIT; or ROLLBACK on any error.
   888	
   889	  post_migration_steps:
   890	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   891	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   892	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   893	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   894	       Cat-β findings closed
   895	
   896	# ============================================================================
   897	# §7 — Codex ratification path
   898	# ============================================================================
   899	
   900	codex_ratification:
   901	  skill: review-schema-change
   902	  expected_round_trips: 1-2 (mechanical fixes only)
   903	  manifest_queue_position: 44 (after v0.2 supplement at 29)
   904	
   905	# ============================================================================
   906	# §8 — Open questions (structured per review-schema-change §8)
   907	# ============================================================================
   908	
   909	open_questions:
   910	
   911	  Q1_employment_type_enum_completeness:
   912	    question: Are 6 employment_type enum values sufficient for UK recruitment?
   913	    options:
   914	      A: |
   915	        Keep 6 values as in §1.candidate.employment_type — perm, contract,
   916	        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
   917	      B: |
   918	        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
   919	      C: |
   920	        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
   921	        (array of allowed strings); validate at write time against tenant's list.
   922	    v0_3_default: A
   923	    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
   924	      outside A, escalate to B or C.
   925	
   926	  Q2_key_skills_max_length:
   927	    question: Cap at 20 items per candidate adequate?
   928	    options:
   929	      A: Keep cap at 20 (validator hard-fails over).
   930	      B: Increase to 50 (handles senior technical candidates with deep stacks).
   931	      C: Remove cap entirely (rely on application-layer pruning).
   932	    v0_3_default: A
   933	    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
   934	      of candidates hit the 20-item cap, escalate to B.
   935	
   936	  Q3_placement_status_enum_lifecycle:
   937	    question: 6-state placement_status enum maps to Bullhorn's native state machine?
   938	    options:
   939	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   940	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   941	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   942	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   943	    v0_3_default: A
   944	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   945	      escalate to B or C if 1:1 mapping breaks.
   946	
   947	  Q4_cash_conductor_transactions_retention:
   948	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   949	      What's the production retention policy?
   950	    options:
   951	      A: 7-year retention with automated pseudonymization at year 7 (hash
   952	         payee_name_raw + description; preserve amount + dates for audit).
   953	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   954	         rows retained beyond 7 years for cross-period reconciliation).
   955	      C: Per-tenant retention override in tenant_adapters.config.
   956	    v0_3_default: A
   957	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   958	      tenant requires shorter retention, escalate to C with tenant-specific
   959	      override. Pseudonymization implementation lands in W4-polish slice.
   960	    production_use_gating: |
   961	      Until pseudonymization implementation lands, production use of
   962	      cash_conductor_transactions table is GATED by an explicit per-tenant
   963	      DPA addendum signed by founder + tenant. Migration-test tenant data
   964	      is not subject to this gate.
   965	
   966	  Q5_unknown_config_keys_handling:
   967	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   968	    options:
   969	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   970	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   971	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   972	    v0_3_default: A
   973	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   974	      for forward-compat, escalate to B or C with explicit ADR.
   975	
   976	# ============================================================================
   977	# §9 — Why v0.3 is the right unblock
   978	# ============================================================================
   979	
   980	rationale: |
   981	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   982	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   983	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   984	  adds 14 entity JSONB keys + 2 auxiliary tables + 3 config keys. The
   985	  per_claim_confidence_distribution payload key originally planned for
   986	  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
   987	  §5 of this supplement); v0.3 is silent on payload schema extensions.
   988	
   989	  After v0.3 ratifies + migration applies:
   990	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   991	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   992	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   993	      placement_status, week_1_status_vault_path, satisfaction_signal,
   994	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   995	      are now schema-backed. (Note: week_1_status_note narrative now lives
   996	      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
   997	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   998	      seniority — not yet in schema; brief.start_date should be
   999	      start_date_target; opportunity.sector — not yet in schema). These
  1000	      residual gaps are tracked in W4-polish-schema-extension backlog;
  1001	      they do not block v0.3 ratification but do require a Scribe agent.md
  1002	      consistency-pass before Scribe ratifies.
  1003	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
  1004	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
  1005	    - Concierge tenant_adapters.config field refs valid
  1006	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
  1007	
  1008	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
  1009	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
  1010	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
  1011	  not schema gaps.
  1012	
  1013	# ============================================================================
  1014	
  1015	end_of_supplement: true

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '260,540p'" in /Users/madsadmin/code/CortexOS
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

codex
REJECTED

1. `janitor_dedup_threshold` uses an invalid schema type. Line 792 declares `type: numeric`, but lines 22-23 and the schema-change skill §2 only allow `string | integer | number | boolean | array | object | timestamp | date`. Proposed fix: change line 792 to `type: number`.

2. The supplement declares five tenant adapter config additions while claiming three. Lines 11, 738, 880-882, and 984 say “3” config keys, but lines 747, 756, 765, 791, and 806 define five keys. This is load-bearing because the migration and schema narrative disagree about what v0.3 actually adds. Proposed fix: either remove the two Janitor keys from v0.3 or update all count/claim text and migration validation to cover five keys.

3. The migration does not validate the two Janitor config keys declared in the schema. Lines 791-816 define `janitor_dedup_threshold` and `janitor_last_run`, but `migrations/v0.2-to-v0.3.sql` §5 only type-validates `concierge_send_window`, `cash_conductor_last_run`, and `concierge_last_poll` at lines 424-452; `janitor_dedup_threshold`/`janitor_last_run` are merely allowlisted at lines 397-398. This weakens the stated hard-fail schema gate for `tenant_adapters.config`. Proposed fix: add number/range validation for `janitor_dedup_threshold` and timestamp/null validation for `janitor_last_run` in migration §5, or defer both keys out of this supplement.
tokens used
56,265
REJECTED

1. `janitor_dedup_threshold` uses an invalid schema type. Line 792 declares `type: numeric`, but lines 22-23 and the schema-change skill §2 only allow `string | integer | number | boolean | array | object | timestamp | date`. Proposed fix: change line 792 to `type: number`.

2. The supplement declares five tenant adapter config additions while claiming three. Lines 11, 738, 880-882, and 984 say “3” config keys, but lines 747, 756, 765, 791, and 806 define five keys. This is load-bearing because the migration and schema narrative disagree about what v0.3 actually adds. Proposed fix: either remove the two Janitor keys from v0.3 or update all count/claim text and migration validation to cover five keys.

3. The migration does not validate the two Janitor config keys declared in the schema. Lines 791-816 define `janitor_dedup_threshold` and `janitor_last_run`, but `migrations/v0.2-to-v0.3.sql` §5 only type-validates `concierge_send_window`, `cash_conductor_last_run`, and `concierge_last_poll` at lines 424-452; `janitor_dedup_threshold`/`janitor_last_run` are merely allowlisted at lines 397-398. This weakens the stated hard-fail schema gate for `tenant_adapters.config`. Proposed fix: add number/range validation for `janitor_dedup_threshold` and timestamp/null validation for `janitor_last_run` in migration §5, or defer both keys out of this supplement.
