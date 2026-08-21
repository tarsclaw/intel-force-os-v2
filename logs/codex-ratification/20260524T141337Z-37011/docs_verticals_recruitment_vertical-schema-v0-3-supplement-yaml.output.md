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
session id: 019e5a55-9180-71f2-a09d-6f637f3e75cc
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
    candidate: R+W         # call-summary field extraction
    contractor: R+W        # call-summary field extraction
    client: R
    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
    placement: R+W         # check-in field extraction
    timesheet: R           # reads for placement-context resolution on check-in calls

  cash_conductor:
    candidate: none        # no Bullhorn dependency
    contractor: none
    client: R              # reads client billing details
    contact: R             # reads for invoice addressee resolution
    brief: none
    opportunity: R         # v0.3 NEW — reads opportunity for invoice-context
    placement: R           # reads for client linkage on invoice
    timesheet: R           # reads to verify billable hours match invoiced amounts
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
    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
    contractor: R+W        # writes lifecycle states for contractor placements too
    client: R
    contact: R             # reads for outbound recipient resolution
    brief: R
    opportunity: R
    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture

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
      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, notes: Full Open Banking response; pseudonymized at year 7}
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
      raw_payload: {type: object, required: false, source: Accounting provider, pii: true}
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
I’ll verify the supplement against the local schema/migration context and the cited companion files before deciding.
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
--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
--     + schema supplement (per ADR-006 Tier 2 + v0.3 supplement §5). v0.3
--     does NOT extend the payload shape; the W4 ADR will add both the new
--     payload key and its enforcement (CHECK constraint or trigger).
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
      -- Validate ISO-8601 date format (YYYY-MM-DD) by cast
      IF d->>'next_action_target_date' IS NOT NULL THEN
        BEGIN
          PERFORM (d->>'next_action_target_date')::date;
        EXCEPTION WHEN OTHERS THEN

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
I have the companion migration and rollback present. I’m checking the concrete validation/grant behavior now, since schema supplements that add auxiliary tables have to match their SQL.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '1,340p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,760p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,520p'" in /Users/madsadmin/code/CortexOS
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
   383	    candidate: R+W         # call-summary field extraction
   384	    contractor: R+W        # call-summary field extraction
   385	    client: R
   386	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
   387	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
   388	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
   389	    placement: R+W         # check-in field extraction
   390	    timesheet: R           # reads for placement-context resolution on check-in calls
   391	
   392	  cash_conductor:
   393	    candidate: none        # no Bullhorn dependency
   394	    contractor: none
   395	    client: R              # reads client billing details
   396	    contact: R             # reads for invoice addressee resolution
   397	    brief: none
   398	    opportunity: R         # v0.3 NEW — reads opportunity for invoice-context
   399	    placement: R           # reads for client linkage on invoice
   400	    timesheet: R           # reads to verify billable hours match invoiced amounts
   401	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   402	
   403	  sourcing_scout:
   404	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   405	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   406	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   407	    # writes its proposed-candidate rows + reads opportunity context. These
   408	    # are entity-level access overrides codified here.
   409	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   410	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   411	    client: R
   412	    contact: R
   413	    brief: R               # reads to filter candidates
   414	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   415	    placement: none
   416	    timesheet: none
   417	
   418	  concierge:
   419	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   420	    contractor: R+W        # writes lifecycle states for contractor placements too
   421	    client: R
   422	    contact: R             # reads for outbound recipient resolution
   423	    brief: R
   424	    opportunity: R
   425	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   426	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   427	
   428	# ============================================================================
   429	# §2a — v0.2 entity v1_0_agent_access amendments
   430	# ============================================================================
   431	#
   432	# Per review-schema-change §5: matrix changes must be reflected in entity-level
   433	# v1_0_agent_access lists. v0.3 amends these v0.2 entities:
   434	
   435	v0_1_entity_access_amendments:
   436	  # Per review-schema-change §5: matrix changes to v0.1 entity-level access
   437	  # must be reflected in explicit amendments. Each entry below documents the
   438	  # v0.1 baseline → v0.3 expanded access list. The base vertical-schema.yaml
   439	  # is NOT edited; this supplement is the authoritative source for v0.3
   440	  # entity access state.
   441	
   442	  client:
   443	    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
   444	    v0_3_v1_0_agent_access:
   445	      - Diagnostic (R)     # v0.3 NEW — reads Companies House data for sales-tool context
   446	      - Janitor (R+W)      # v0.1 unchanged
   447	      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
   448	      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
   449	      - Sourcing Scout (R) # v0.1 unchanged
   450	      - Concierge (R)      # v0.1 unchanged
   451	    rationale: |
   452	      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
   453	      client billing/context for their respective workflows). No new W access.
   454	
   455	  contact:
   456	    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
   457	    v0_3_v1_0_agent_access:
   458	      - Diagnostic (R)     # v0.3 NEW — reads §11 decision-maker map context
   459	      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
   460	      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
   461	      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
   462	      - Sourcing Scout (R) # v0.1 unchanged
   463	      - Concierge (R)      # v0.1 unchanged
   464	    rationale: |
   465	      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
   466	      preferred_channel + next_action_target_date; Janitor also dedup-merges).
   467	      Diagnostic + Cash Conductor gain R for context.
   468	
   469	  brief:
   470	    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
   471	    v0_3_v1_0_agent_access:
   472	      - Janitor (R)        # v0.1 unchanged
   473	      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
   474	      - Sourcing Scout (R) # v0.1 unchanged
   475	      - Concierge (R)      # v0.1 unchanged
   476	    rationale: |
   477	      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
   478	      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
   479	      for Scribe.
   480	
   481	  opportunity:
   482	    v0_1_v1_0_agent_access: [Janitor (R)]
   483	    v0_3_v1_0_agent_access:
   484	      - Diagnostic (R)     # v0.3 NEW — reads prospect-firm opportunity if exists
   485	      - Janitor (R)        # v0.1 unchanged
   486	      - Scribe (R+W)       # v0.3 NEW — writes 3 new prospecting-call fields
   487	      - Cash Conductor (R) # v0.3 NEW — reads for invoice context
   488	      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
   489	      - Concierge (R)      # v0.3 NEW — reads for outbound lifecycle context
   490	    rationale: |
   491	      v0.1 opportunity is sparsely accessed (Janitor only); v0.3 broadens
   492	      to all v1.0 agents because the entity gains 3 new fields used across
   493	      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
   494	      timing), Diagnostic + Cash Conductor (reads for context).
   495	
   496	  placement:
   497	    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
   498	    v0_3_v1_0_agent_access:
   499	      - Janitor (R+W)      # v0.3 UPGRADED — lifecycle-state cleanup writes
   500	      - Scribe (R+W)       # v0.3 NEW — check-in field extraction
   501	      - Cash Conductor (R) # v0.1 unchanged
   502	      - Concierge (R+W)    # v0.3 UPGRADED — writes Bullhorn state advancement
   503	    rationale: |
   504	      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
   505	      their §4 specs); adds Scribe R+W for check-in writes.
   506	
   507	  timesheet:
   508	    v0_1_v1_0_agent_access: [Cash Conductor (R)]
   509	    v0_3_v1_0_agent_access:
   510	      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
   511	      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
   512	      - Cash Conductor (R) # v0.1 unchanged
   513	      - Concierge (R)      # v0.3 NEW — reads to verify placement-progress for nurture
   514	    rationale: |
   515	      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
   516	      Scribe + Concierge (each reads timesheet for their respective
   517	      placement-related workflows).
   518	
   519	  candidate:
   520	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   521	    v0_3_v1_0_agent_access:
   522	      - Diagnostic (R)     # v0.3 NEW — reads for outreach context (§11 decision-maker map)
   523	      - Janitor (R+W)      # v0.1 unchanged
   524	      - Scribe (R+W)       # v0.1 unchanged
   525	      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
   526	      - Concierge (R+W)    # v0.3 UPGRADED — writes lifecycle-state-derived fields
   527	    rationale: |
   528	      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
   529	      multi-source aggregation) + Concierge (writes lifecycle-state and
   530	      activity-log links per §4 Steps 13-14). Diagnostic gains R for context.
   531	
   532	  contractor:
   533	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   534	    v0_3_v1_0_agent_access:
   535	      - Janitor (R+W)      # v0.1 unchanged
   536	      - Scribe (R+W)       # v0.1 unchanged
   537	      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
   538	      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
   539	    rationale: |
   540	      Parallel upgrades to candidate; contractor entities follow the same
   541	      v0.3 write patterns where applicable.
   542	
   543	v0_2_entity_access_amendments:
   544	
   545	  voice_corpus:
   546	    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
   547	    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
   548	    rationale: |
   549	      All v1.0 agents that produce voice-classified output (Diagnostic for
   550	      §12 conversation opener; Janitor for tacit-note narratives; Cash
   551	      Conductor for chase drafts; Sourcing Scout for per-candidate
   552	      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
   553	      granted Scribe + Concierge; v0.3 extends to all 6.
   554	
   555	  tone_rule:
   556	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
   557	    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
   558	    rationale: |
   559	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   560	      applies_to_agents containing 'janitor' for tacit-note narrative
   561	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   562	      Diagnostic + Sourcing Scout also read tone_rules for their
   563	      voice-classified outputs (§12 opener, per-candidate rationale).
   564	
   565	  recent_edit:
   566	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   567	    v0_3_v1_0_agent_access:
   568	      - voice-drift-canary (W)  # v0.2 unchanged
   569	      - Concierge (R)            # v0.2 unchanged
   570	      - LoRA (R)                 # v0.2 unchanged
   571	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   572	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   573	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   574	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   575	    rationale: |
   576	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   577	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   578	      for retraining queue). Janitor adds R for tacit-note harvest per
   579	      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
   580	      supplement is the authoritative source for the expanded access list.
   581	
   582	# ============================================================================
   583	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   584	# ============================================================================
   585	
   586	auxiliary_tables:
   587	
   588	  cash_conductor_transactions:
   589	    rationale: |
   590	      Open Banking transactions are high-volume + time-series + don't model
   591	      as entity.data JSONB. v0.3 introduces a first-class table with
   592	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   593	      §4 Step 3 + ADR-002 vault/Postgres split.
   594	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   595	    columns:
   596	      id: {type: integer, required: true, source: IFOS-internal, notes: BIGSERIAL primary key in SQL}
   597	      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
   598	      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
   599	      posted_at: {type: timestamp, required: true, source: Open Banking provider}
   600	      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
   601	      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
   602	      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   603	      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   604	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
   605	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
   606	      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   607	      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
   608	      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}
   609	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   610	      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, notes: Full Open Banking response; pseudonymized at year 7}
   611	    indexes:
   612	      - "(tenant_slug, posted_at DESC)"
   613	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   614	    retention: |
   615	      INTENT (W4-polish enforcement required): 7-year retention with
   616	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   617	      description, raw_payload). Aligned with Q4 v0_3_default. The
   618	      v0.2-to-v0.3 migration creates the table + indexes only; the
   619	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   620	      job or external scheduled job; not yet authored).
   621	    enforcement_gate: |
   622	      Production use of this table GATED until pseudonymization + purge
   623	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   624	      by founder + tenant before go-live; migration-test tenant exempt.
   625	
   626	  cash_conductor_invoices:
   627	    rationale: |
   628	      Open invoice register cached from accounting provider. Same auxiliary-
   629	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   630	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   631	    columns:
   632	      id: {type: integer, required: true, source: IFOS-internal}
   633	      tenant_slug: {type: string, required: true, source: IFOS-internal}
   634	      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
   635	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
   636	      invoice_number: {type: string, required: false, source: Accounting provider}
   637	      issued_at: {type: timestamp, required: true, source: Accounting provider}
   638	      due_at: {type: timestamp, required: true, source: Accounting provider}
   639	      amount_total: {type: number, required: true, source: Accounting provider, notes: NUMERIC(15,2) GBP}
   640	      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
   641	      currency: {type: string, required: true, default: GBP, source: Accounting provider}
   642	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open, source: Accounting provider}
   643	      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
   644	      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
   645	      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
   646	      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
   647	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   648	      raw_payload: {type: object, required: false, source: Accounting provider, pii: true}
   649	    indexes:
   650	      - "(tenant_slug, due_at)"
   651	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   652	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   653	    retention: |
   654	      INTENT (W4-polish enforcement required): 7-year retention with
   655	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   656	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   657	      pseudonymization + purge implementation is a W4-polish slice
   658	      (pg_cron job or external scheduled job; not yet authored).
   659	    enforcement_gate: |
   660	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   661	      W4 polish, production use of cash_conductor_invoices is GATED by
   662	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   663	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   664	      data is exempt; pilot tenants require the DPA addendum signed before
   665	      go-live.
   666	
   667	auxiliary_table_access_matrix:
   668	  voice_corpus:
   669	    # v0.2 auxiliary table — voice exemplar corpus (per-tenant)
   670	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents that
   671	    # produce voice-classified output
   672	    diagnostic: R
   673	    janitor: R
   674	    scribe: R
   675	    cash_conductor: R
   676	    sourcing_scout: R
   677	    concierge: R
   678	  voice_corpus_chunks:
   679	    # v0.2 auxiliary table holding pgvector HNSW index over voice corpus chunks
   680	    # All v1.0 agents producing voice-classified output need R for ANN-match retrieval
   681	    diagnostic: R
   682	    janitor: R
   683	    scribe: R
   684	    cash_conductor: R
   685	    sourcing_scout: R
   686	    concierge: R
   687	  tone_rule:
   688	    # v0.2 auxiliary table — per-tenant tone constraints
   689	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents
   690	    diagnostic: R
   691	    janitor: R
   692	    scribe: R
   693	    cash_conductor: R
   694	    sourcing_scout: R
   695	    concierge: R
   696	  recent_edit:
   697	    # v0.2 auxiliary table — consultant edits for retraining/drift detection
   698	    # Per §2a amendment: v0.3 expands access (Concierge R from v0.2;
   699	    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
   700	    # Scout add W to write own retraining edits; Diagnostic remains none)
   701	    diagnostic: none
   702	    janitor: R
   703	    scribe: W
   704	    cash_conductor: W
   705	    sourcing_scout: W
   706	    concierge: R
   707	  cash_conductor_transactions:
   708	    diagnostic: none
   709	    janitor: none
   710	    scribe: none
   711	    cash_conductor: R+W
   712	    sourcing_scout: none
   713	    concierge: none
   714	  cash_conductor_invoices:
   715	    diagnostic: none
   716	    janitor: none
   717	    scribe: none
   718	    cash_conductor: R+W
   719	    sourcing_scout: none
   720	    concierge: none
   721	
   722	# ============================================================================
   723	# §4 — tenant_adapters.config new keys (3 keys)
   724	# ============================================================================
   725	#
   726	# tenant_adapters.config is JSONB; validation via
   727	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   728	# on unknown keys per Rule 2.
   729	
   730	tenant_adapters_config_additions:
   731	
   732	  cash_conductor_last_run:
   733	    type: timestamp
   734	    required: false
   735	    set_by: cash_conductor
   736	    read_by: [cash_conductor]
   737	    notes: |
   738	      Cash Conductor cron sweep updates at session-close. Next run queries
   739	      transactions/invoices since this timestamp.
   740	
   741	  concierge_last_poll:
   742	    type: timestamp
   743	    required: false
   744	    set_by: concierge
   745	    read_by: [concierge]
   746	    notes: |
   747	      Concierge polling cron updates at end of each cycle. Next poll queries
   748	      Bullhorn for state transitions since this timestamp.
   749	
   750	  concierge_send_window:
   751	    type: object
   752	    required: false
   753	    default:
   754	      timezone: Europe/London
   755	      weekday_start: '09:00'
   756	      weekday_end: '17:00'
   757	      weekend_send_enabled: false
   758	    set_by: [tenant-admin]
   759	    read_by: [concierge]
   760	    object_shape:

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
    46	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
    47	    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
    48	  END IF;
    49	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
    50	    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
    51	  END IF;
    52	  RAISE NOTICE 'v0.2 prerequisites verified';
    53	END $$;
    54	
    55	-- ----------------------------------------------------------------------------
    56	-- §2 — Create cash_conductor_transactions table (RLS-isolated)
    57	-- ----------------------------------------------------------------------------
    58	
    59	CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
    60	  id                 BIGSERIAL PRIMARY KEY,
    61	  tenant_slug        TEXT NOT NULL,
    62	  transaction_id     TEXT NOT NULL,
    63	  posted_at          TIMESTAMPTZ NOT NULL,
    64	  amount             NUMERIC(15, 2) NOT NULL,
    65	  currency           TEXT NOT NULL DEFAULT 'GBP',
    66	  payee_name_raw     TEXT,
    67	  description        TEXT,
    68	  bank_provider      TEXT NOT NULL,
    69	  match_status       TEXT NOT NULL DEFAULT 'unmatched',
    70	  matched_invoice_id TEXT,
    71	  match_confidence   NUMERIC(3, 2),
    72	  match_dimensions   TEXT[],
    73	  ingested_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    74	  raw_payload        JSONB,
    75	
    76	  CONSTRAINT cct_match_status_valid CHECK (
    77	    match_status IN ('unmatched', 'matched', 'ambiguous')
    78	  ),
    79	  CONSTRAINT cct_bank_provider_valid CHECK (
    80	    bank_provider IN ('truelayer', 'plaid_uk', 'open_banking_direct')
    81	  ),
    82	  CONSTRAINT cct_match_confidence_range CHECK (
    83	    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
    84	  ),
    85	  CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id)
    86	);
    87	
    88	CREATE INDEX IF NOT EXISTS idx_cct_tenant_posted
    89	  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
    90	
    91	CREATE INDEX IF NOT EXISTS idx_cct_tenant_unmatched
    92	  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
    93	  WHERE match_status IN ('unmatched', 'ambiguous');
    94	
    95	-- RLS isolation per Day-4 §6.3 pattern
    96	ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
    97	ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
    98	
    99	CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
   100	  FOR ALL TO ifos_app
   101	  USING (tenant_slug = current_setting('app.current_tenant', true));
   102	
   103	GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
   104	GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
   105	
   106	-- ----------------------------------------------------------------------------
   107	-- §3 — Create cash_conductor_invoices table (RLS-isolated)
   108	-- ----------------------------------------------------------------------------
   109	
   110	CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
   111	  id                       BIGSERIAL PRIMARY KEY,
   112	  tenant_slug              TEXT NOT NULL,
   113	  invoice_id               TEXT NOT NULL,
   114	  accounting_provider      TEXT NOT NULL,
   115	  invoice_number           TEXT,
   116	  issued_at                TIMESTAMPTZ NOT NULL,
   117	  due_at                   TIMESTAMPTZ NOT NULL,
   118	  amount_total             NUMERIC(15, 2) NOT NULL,
   119	  amount_paid              NUMERIC(15, 2) NOT NULL DEFAULT 0,
   120	  currency                 TEXT NOT NULL DEFAULT 'GBP',
   121	  status                   TEXT NOT NULL DEFAULT 'open',
   122	  client_contact_id        TEXT,
   123	  client_billing_email     TEXT,
   124	  last_chase_position      INT NOT NULL DEFAULT 0,
   125	  last_chase_sent_at       TIMESTAMPTZ,
   126	  ingested_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
   127	  raw_payload              JSONB,
   128	
   129	  CONSTRAINT cci_status_valid CHECK (
   130	    status IN ('open', 'partial', 'paid', 'overdue', 'cancelled', 'voided')
   131	  ),
   132	  CONSTRAINT cci_provider_valid CHECK (
   133	    accounting_provider IN ('xero', 'quickbooks', 'sage')
   134	  ),
   135	  CONSTRAINT cci_chase_position_range CHECK (
   136	    last_chase_position >= 0 AND last_chase_position <= 4
   137	  ),
   138	  CONSTRAINT cci_amount_paid_non_negative CHECK (
   139	    amount_paid >= 0 AND amount_paid <= amount_total
   140	  ),
   141	  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
   142	);
   143	
   144	CREATE INDEX IF NOT EXISTS idx_cci_tenant_due
   145	  ON cash_conductor_invoices (tenant_slug, due_at);
   146	
   147	CREATE INDEX IF NOT EXISTS idx_cci_tenant_overdue
   148	  ON cash_conductor_invoices (tenant_slug, status, due_at)
   149	  WHERE status IN ('open', 'partial', 'overdue');
   150	
   151	CREATE INDEX IF NOT EXISTS idx_cci_tenant_chase
   152	  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
   153	  WHERE last_chase_position BETWEEN 1 AND 3;
   154	
   155	ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
   156	ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
   157	
   158	CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
   159	  FOR ALL TO ifos_app
   160	  USING (tenant_slug = current_setting('app.current_tenant', true));
   161	
   162	GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
   163	GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
   164	
   165	-- ----------------------------------------------------------------------------
   166	-- §4 — Replace JSONB validation function for entities.data (adds v0.3 keys)
   167	-- ----------------------------------------------------------------------------
   168	--
   169	-- The v0.2 migration installed validate_voice_scores trigger which validates
   170	-- the 6 voice-score keys. v0.3 extends validation to cover the 14 new keys
   171	-- for candidate, contact, brief, placement, opportunity. We replace the
   172	-- function in place (CREATE OR REPLACE) so the v0.2 voice-score checks remain.
   173	
   174	CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
   175	RETURNS TRIGGER AS $$
   176	DECLARE
   177	  d JSONB := NEW.data;
   178	  et TEXT := NEW.entity_type;
   179	  arr_item JSONB;
   180	BEGIN
   181	  -- v0.2 voice-score keys (forwarded; preserves v0.2 [0.0, 1.0] range check)
   182	  IF d ? 'voice_classifier_score' THEN
   183	    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
   184	      RAISE EXCEPTION 'voice_classifier_score must be number or null';
   185	    END IF;
   186	    IF d->'voice_classifier_score' != 'null'::jsonb THEN
   187	      IF (d->>'voice_classifier_score')::numeric < 0.0
   188	         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
   189	        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
   190	      END IF;
   191	    END IF;
   192	  END IF;
   193	
   194	  IF d ? 'voice_drift_at_close' THEN
   195	    IF jsonb_typeof(d->'voice_drift_at_close') NOT IN ('number', 'null') THEN
   196	      RAISE EXCEPTION 'voice_drift_at_close must be number or null';
   197	    END IF;
   198	    IF d->'voice_drift_at_close' != 'null'::jsonb THEN
   199	      IF (d->>'voice_drift_at_close')::numeric < 0.0
   200	         OR (d->>'voice_drift_at_close')::numeric > 1.0 THEN
   201	        RAISE EXCEPTION 'voice_drift_at_close out of [0.0, 1.0] range: %', d->>'voice_drift_at_close';
   202	      END IF;
   203	    END IF;
   204	  END IF;
   205	
   206	  -- v0.3 candidate fields
   207	  IF et = 'candidate' THEN
   208	    IF d ? 'employment_type' THEN
   209	      IF (d->>'employment_type') NOT IN (
   210	        'perm', 'contract', 'contract_inside_ir35', 'contract_outside_ir35', 'day_rate', 'hybrid'
   211	      ) THEN
   212	        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
   213	      END IF;
   214	    END IF;
   215	
   216	    IF d ? 'key_skills' THEN
   217	      IF jsonb_typeof(d->'key_skills') != 'array' THEN
   218	        RAISE EXCEPTION 'key_skills must be array';
   219	      END IF;
   220	      IF jsonb_array_length(d->'key_skills') > 20 THEN
   221	        RAISE EXCEPTION 'key_skills max length 20 (got %)', jsonb_array_length(d->'key_skills');
   222	      END IF;
   223	      -- Every element must be a string
   224	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'key_skills') LOOP
   225	        IF jsonb_typeof(arr_item) != 'string' THEN
   226	          RAISE EXCEPTION 'key_skills items must be strings; got %', jsonb_typeof(arr_item);
   227	        END IF;
   228	      END LOOP;
   229	    END IF;
   230	
   231	    IF d ? 'linkedin_url' THEN
   232	      IF jsonb_typeof(d->'linkedin_url') NOT IN ('string', 'null') THEN
   233	        RAISE EXCEPTION 'linkedin_url must be string or null';
   234	      END IF;
   235	      IF d->>'linkedin_url' IS NOT NULL
   236	         AND d->>'linkedin_url' !~ '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$' THEN
   237	        RAISE EXCEPTION 'linkedin_url does not match expected pattern: %', d->>'linkedin_url';
   238	      END IF;
   239	    END IF;
   240	  END IF;
   241	
   242	  -- v0.3 contact fields
   243	  IF et = 'contact' THEN
   244	    IF d ? 'preferred_channel' THEN
   245	      IF (d->>'preferred_channel') NOT IN (
   246	        'email', 'phone', 'sms', 'teams', 'slack', 'in_person', 'unknown'
   247	      ) THEN
   248	        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
   249	      END IF;
   250	    END IF;
   251	
   252	    IF d ? 'next_action_target_date' THEN
   253	      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
   254	        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
   255	      END IF;
   256	      -- Validate ISO-8601 date format (YYYY-MM-DD) by cast
   257	      IF d->>'next_action_target_date' IS NOT NULL THEN
   258	        BEGIN
   259	          PERFORM (d->>'next_action_target_date')::date;
   260	        EXCEPTION WHEN OTHERS THEN
   261	          RAISE EXCEPTION 'next_action_target_date must parse as ISO-8601 date (YYYY-MM-DD); got: %', d->>'next_action_target_date';
   262	        END;
   263	      END IF;
   264	    END IF;
   265	  END IF;
   266	
   267	  -- v0.3 brief fields
   268	  IF et = 'brief' THEN
   269	    IF d ? 'must_haves' THEN
   270	      IF jsonb_typeof(d->'must_haves') != 'array' THEN
   271	        RAISE EXCEPTION 'must_haves must be array';
   272	      END IF;
   273	      IF jsonb_array_length(d->'must_haves') > 15 THEN
   274	        RAISE EXCEPTION 'must_haves max length 15';
   275	      END IF;
   276	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
   277	        IF jsonb_typeof(arr_item) != 'string' THEN
   278	          RAISE EXCEPTION 'must_haves items must be strings';
   279	        END IF;
   280	      END LOOP;
   281	    END IF;
   282	
   283	    IF d ? 'nice_to_haves' THEN
   284	      IF jsonb_typeof(d->'nice_to_haves') != 'array' THEN
   285	        RAISE EXCEPTION 'nice_to_haves must be array';
   286	      END IF;
   287	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'nice_to_haves') LOOP
   288	        IF jsonb_typeof(arr_item) != 'string' THEN
   289	          RAISE EXCEPTION 'nice_to_haves items must be strings';
   290	        END IF;
   291	      END LOOP;
   292	    END IF;
   293	
   294	    IF d ? 'deal_breakers' THEN
   295	      IF jsonb_typeof(d->'deal_breakers') != 'array' THEN
   296	        RAISE EXCEPTION 'deal_breakers must be array';
   297	      END IF;
   298	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
   299	        IF jsonb_typeof(arr_item) != 'string' THEN
   300	          RAISE EXCEPTION 'deal_breakers items must be strings';
   301	        END IF;
   302	      END LOOP;
   303	    END IF;
   304	  END IF;
   305	
   306	  -- v0.3 placement fields
   307	  IF et = 'placement' THEN
   308	    IF d ? 'placement_status' THEN
   309	      IF (d->>'placement_status') NOT IN (
   310	        'pending_start', 'active', 'completed', 'terminated_early', 'on_hold', 'cancelled'
   311	      ) THEN
   312	        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
   313	      END IF;
   314	    END IF;
   315	
   316	    IF d ? 'week_1_status_vault_path' THEN
   317	      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
   318	        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
   319	      END IF;
   320	      IF d->>'week_1_status_vault_path' IS NOT NULL
   321	         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$' THEN
   322	        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
   323	      END IF;
   324	      IF d->>'week_1_status_vault_path' IS NOT NULL
   325	         AND length(d->>'week_1_status_vault_path') > 200 THEN
   326	        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
   327	      END IF;
   328	    END IF;
   329	
   330	    IF d ? 'satisfaction_signal' THEN
   331	      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
   332	        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
   333	      END IF;
   334	    END IF;
   335	  END IF;
   336	
   337	  -- v0.3 opportunity fields
   338	  IF et = 'opportunity' THEN
   339	    IF d ? 'headcount_growth_signal_text' THEN
   340	      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
   341	        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
   342	      END IF;
   343	      IF d->>'headcount_growth_signal_text' IS NOT NULL
   344	         AND length(d->>'headcount_growth_signal_text') > 280 THEN
   345	        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
   346	      END IF;
   347	    END IF;
   348	
   349	    IF d ? 'hiring_velocity_band' THEN
   350	      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
   351	        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
   352	      END IF;
   353	    END IF;
   354	
   355	    IF d ? 'decision_window_text' THEN
   356	      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
   357	        RAISE EXCEPTION 'decision_window_text must be string or null';
   358	      END IF;
   359	      IF d->>'decision_window_text' IS NOT NULL
   360	         AND length(d->>'decision_window_text') > 280 THEN
   361	        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
   362	      END IF;
   363	    END IF;
   364	  END IF;
   365	
   366	  RETURN NEW;
   367	END;
   368	$$ LANGUAGE plpgsql;
   369	
   370	-- Rebind the trigger to the new function (drops + recreates)
   371	DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
   372	DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
   373	
   374	CREATE TRIGGER validate_entities_data_v0_3
   375	  BEFORE INSERT OR UPDATE ON entities
   376	  FOR EACH ROW
   377	  EXECUTE FUNCTION validate_entities_data_v0_3();
   378	
   379	-- ----------------------------------------------------------------------------
   380	-- §5 — tenant_adapters.config validation trigger (new keys)
   381	-- ----------------------------------------------------------------------------
   382	--
   383	-- v0.3 codifies 3 new config keys agents read. The validation trigger ensures
   384	-- only the documented keys are stored (hard-fail on unknown keys per Rule 2
   385	-- Schema before code).
   386	
   387	CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
   388	RETURNS TRIGGER AS $$
   389	DECLARE
   390	  c JSONB := NEW.config;
   391	  k TEXT;
   392	  allowed_keys TEXT[] := ARRAY[
   393	    -- v0.1 + v0.2 keys (forwarded; do not remove)
   394	    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
   395	    'janitor_last_run',
   396	    'pii_retention_days',  -- v0.2 PII purge runbook key
   397	    -- autosend-safety-policy.md keys
   398	    'approval_routing', 'approval_timeouts', 'sampling_rates',
   399	    -- v0.3 additions
   400	    'cash_conductor_last_run',
   401	    'concierge_last_poll',
   402	    'concierge_send_window'
   403	    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   404	    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
   405	  ];
   406	BEGIN
   407	  IF c IS NULL THEN
   408	    RETURN NEW;
   409	  END IF;
   410	
   411	  FOR k IN SELECT jsonb_object_keys(c) LOOP
   412	    IF NOT (k = ANY(allowed_keys)) THEN
   413	      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
   414	    END IF;
   415	  END LOOP;
   416	
   417	  -- v0.3 type validations
   418	  -- diagnostic_per_claim_sample_rate DEFERRED to W4-polish ADR; not validated
   419	  -- in v0.3 (also not in allowlist above, so it would fail-fast anyway)
   420	
   421	  IF c ? 'concierge_send_window' THEN
   422	    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
   423	      RAISE EXCEPTION 'concierge_send_window must be object';
   424	    END IF;
   425	    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
   426	      RAISE EXCEPTION 'concierge_send_window must include timezone';
   427	    END IF;
   428	    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
   429	       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
   430	      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
   431	    END IF;
   432	    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
   433	       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
   434	      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
   435	    END IF;
   436	  END IF;
   437	
   438	  -- v0.3 timestamp-typed keys
   439	  IF c ? 'cash_conductor_last_run' THEN
   440	    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
   441	      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
   442	    END IF;
   443	  END IF;
   444	
   445	  IF c ? 'concierge_last_poll' THEN
   446	    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
   447	      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
   448	    END IF;
   449	  END IF;
   450	
   451	  RETURN NEW;
   452	END;
   453	$$ LANGUAGE plpgsql;
   454	
   455	DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
   456	
   457	CREATE TRIGGER validate_tenant_adapters_config_v0_3
   458	  BEFORE INSERT OR UPDATE ON tenant_adapters
   459	  FOR EACH ROW
   460	  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
   461	
   462	-- ----------------------------------------------------------------------------
   463	-- §6 — Smoke verification (read-only)
   464	-- ----------------------------------------------------------------------------
   465	
   466	DO $$
   467	DECLARE
   468	  ccr_count INT;
   469	  cci_count INT;
   470	BEGIN
   471	  SELECT count(*) INTO ccr_count FROM information_schema.tables
   472	    WHERE table_name = 'cash_conductor_transactions';
   473	  IF ccr_count != 1 THEN
   474	    RAISE EXCEPTION 'cash_conductor_transactions table not created';
   475	  END IF;
   476	
   477	  SELECT count(*) INTO cci_count FROM information_schema.tables
   478	    WHERE table_name = 'cash_conductor_invoices';
   479	  IF cci_count != 1 THEN
   480	    RAISE EXCEPTION 'cash_conductor_invoices table not created';
   481	  END IF;
   482	
   483	  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
   484	END $$;
   485	
   486	COMMIT;
   487	
   488	-- ============================================================================
   489	-- End of v0.2 → v0.3 migration
   490	-- ============================================================================

exec
/bin/zsh -lc 'rg -n "source: Bullhorn|bullhorn_mapping|agent_access_matrix|candidate:|contractor:|placement:|timesheet:|opportunity:" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:319:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:
docs/verticals/recruitment/vertical-schema.yaml:41:# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
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
docs/verticals/recruitment/vertical-schema.yaml:127:        source: Bullhorn.Candidate.address.city
docs/verticals/recruitment/vertical-schema.yaml:153:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:169:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
docs/verticals/recruitment/vertical-schema.yaml:174:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:178:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:182:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:186:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:224:    bullhorn_source: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:233:        source: Bullhorn.ClientCorporation.id
docs/verticals/recruitment/vertical-schema.yaml:237:        source: Bullhorn.ClientCorporation.name
docs/verticals/recruitment/vertical-schema.yaml:241:        source: Bullhorn.ClientCorporation.industryList
docs/verticals/recruitment/vertical-schema.yaml:247:        source: Bullhorn.ClientCorporation.numEmployees (bucketed)
docs/verticals/recruitment/vertical-schema.yaml:251:        source: Bullhorn.ClientCorporation.companyURL
docs/verticals/recruitment/vertical-schema.yaml:265:        source: Bullhorn.ClientCorporation.owner.id
docs/verticals/recruitment/vertical-schema.yaml:273:        source: Bullhorn.ClientCorporation.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:277:        source: Bullhorn.ClientCorporation.address.city
docs/verticals/recruitment/vertical-schema.yaml:286:    bullhorn_source: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:294:        source: Bullhorn.ClientContact.id
docs/verticals/recruitment/vertical-schema.yaml:298:        source: Bullhorn.ClientContact.firstName
docs/verticals/recruitment/vertical-schema.yaml:302:        source: Bullhorn.ClientContact.lastName
docs/verticals/recruitment/vertical-schema.yaml:306:        source: Bullhorn.ClientContact.email
docs/verticals/recruitment/vertical-schema.yaml:310:        source: Bullhorn.ClientContact.phone
docs/verticals/recruitment/vertical-schema.yaml:314:        source: Bullhorn.ClientContact.title
docs/verticals/recruitment/vertical-schema.yaml:330:        source: Bullhorn.ClientContact.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:344:    bullhorn_source: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:355:        source: Bullhorn.JobOrder.id
docs/verticals/recruitment/vertical-schema.yaml:359:        source: Bullhorn.JobOrder.title
docs/verticals/recruitment/vertical-schema.yaml:364:        source: Bullhorn.JobOrder.publicDescription
docs/verticals/recruitment/vertical-schema.yaml:370:        source: Bullhorn.JobOrder.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:374:        source: Bullhorn.JobOrder.salary
docs/verticals/recruitment/vertical-schema.yaml:379:        source: Bullhorn.JobOrder.salaryUnit (range parsing)
docs/verticals/recruitment/vertical-schema.yaml:391:        source: Bullhorn.JobOrder.address.city
docs/verticals/recruitment/vertical-schema.yaml:415:        source: Bullhorn.JobOrder.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:419:        source: Bullhorn.JobOrder.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:423:        source: Bullhorn.JobOrder.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:432:    bullhorn_source: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:441:        source: Bullhorn.Placement.id
docs/verticals/recruitment/vertical-schema.yaml:445:        source: Bullhorn.Placement.dateBegin
docs/verticals/recruitment/vertical-schema.yaml:449:        source: Bullhorn.Placement.dateEnd
docs/verticals/recruitment/vertical-schema.yaml:455:        source: Bullhorn.Placement.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:460:        source: Bullhorn.Placement.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:464:        source: Bullhorn.Placement.fee
docs/verticals/recruitment/vertical-schema.yaml:469:        source: Bullhorn.Placement.feeArrangement (parsed)
docs/verticals/recruitment/vertical-schema.yaml:471:      candidate_salary_at_placement:
docs/verticals/recruitment/vertical-schema.yaml:474:        source: Bullhorn.Placement.salary
docs/verticals/recruitment/vertical-schema.yaml:489:        source: Bullhorn.Placement.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:495:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:498:    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
docs/verticals/recruitment/vertical-schema.yaml:508:        source: Bullhorn.JobSubmission.id
docs/verticals/recruitment/vertical-schema.yaml:513:        source: Bullhorn.JobSubmission.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:525:        source: Bullhorn.JobSubmission.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:529:        source: Bullhorn.JobSubmission.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:535:  timesheet:
docs/verticals/recruitment/vertical-schema.yaml:538:    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
docs/verticals/recruitment/vertical-schema.yaml:548:        source: Bullhorn.Timesheet.id
docs/verticals/recruitment/vertical-schema.yaml:552:        source: Bullhorn.Timesheet.weekStartDate
docs/verticals/recruitment/vertical-schema.yaml:556:        source: Bullhorn.Timesheet.totalHours
docs/verticals/recruitment/vertical-schema.yaml:560:        source: Bullhorn.Timesheet.status (parsed)
docs/verticals/recruitment/vertical-schema.yaml:561:      approved_by_contractor:
docs/verticals/recruitment/vertical-schema.yaml:568:        source: Bullhorn.Timesheet.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:654:  timesheet_for_placement:
docs/verticals/recruitment/vertical-schema.yaml:669:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:673:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:677:    placement: none
docs/verticals/recruitment/vertical-schema.yaml:678:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:679:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:684:    contractor: R+W  # status normalisation
docs/verticals/recruitment/vertical-schema.yaml:688:    placement: R     # orphan / stale-tag sweep
docs/verticals/recruitment/vertical-schema.yaml:689:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:690:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
docs/verticals/recruitment/vertical-schema.yaml:694:    contractor: R+W  # contractor calls same pattern
docs/verticals/recruitment/vertical-schema.yaml:698:    placement: R+W   # note links on placed-candidate calls
docs/verticals/recruitment/vertical-schema.yaml:699:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:700:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:704:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
docs/verticals/recruitment/vertical-schema.yaml:709:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:710:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:714:    contractor: R    # contractor pool
docs/verticals/recruitment/vertical-schema.yaml:718:    placement: none
docs/verticals/recruitment/vertical-schema.yaml:719:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:720:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:724:    contractor: R+W  # lifecycle state, contractor-specific cadence
docs/verticals/recruitment/vertical-schema.yaml:728:    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
docs/verticals/recruitment/vertical-schema.yaml:729:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:730:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:739:bullhorn_mapping:
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:777:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:783:  timesheet:

exec
/bin/zsh -lc 'rg -n "CREATE TABLE|GRANT|recent_edit|voice_corpus|tone_rule|ifos_app" docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:26:--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:28:--   - RLS policies + ifos_app grants from Day-4 §6.3 in place
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:43:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:44:    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:46:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:47:    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:49:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:50:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:59:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:100:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:103:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:104:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:110:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:159:  FOR ALL TO ifos_app
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:162:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:163:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '640,810p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '760,980p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg -n \"Cat-β|Phase 4|v0\\.3|Scribe|Cash Conductor|Concierge|Janitor\" docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md" in /Users/madsadmin/code/CortexOS
 succeeded in 191ms:
   640	    source: opportunity
   641	    target: brief
   642	    cardinality: N:1
   643	    description: An opportunity is a candidate's progression toward a specific brief.
   644	    v1_0_exercise: None (Opportunity entity not v1.0-exercised).
   645	    v1_1_plus_notes: Brief Decoder + Inbound Triage primary readers.
   646	
   647	  opportunity_about_candidate:
   648	    source: opportunity
   649	    target: candidate
   650	    cardinality: N:1
   651	    description: Each opportunity is about exactly one candidate; a candidate may have multiple opportunities (different briefs).
   652	    v1_0_exercise: None.
   653	
   654	  timesheet_for_placement:
   655	    source: timesheet
   656	    target: placement
   657	    cardinality: N:1
   658	    description: Each timesheet relates to one (contract) placement; a placement has 0..N timesheets over its duration.
   659	    v1_0_exercise: None (Timesheet entity v2.0).
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
   781	    notes: Tenant-config dependent — some Bullhorn tenants use JobSubmission, some use Opportunity, some both. Adapter layer resolves at ingest.
   782	
   783	  timesheet:
   784	    bullhorn_entity: Bullhorn.Timesheet
   785	    primary_key: id
   786	    field_mapping_density: v0.1 covers 7 fields (placeholder shape); full Bullhorn field-density TBD pending v2.0 T2 Timesheet + T6 Pay & Bill builds.
   787	
   788	# ============================================================================
   789	# §5 — Open questions
   790	# ============================================================================
   791	# Resolved (RESOLVED) items: baked into v0.1 per Day-6 founder decisions.
   792	# Deferred (DEFERRED) items: scope-bounded with named revisit triggers.
   793	# ============================================================================
   794	
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

 succeeded in 191ms:
   760	    object_shape:
   761	      timezone:
   762	        type: string
   763	        notes: IANA timezone identifier
   764	      weekday_start:
   765	        type: string
   766	        notes: HH:MM 24-hour format
   767	      weekday_end:
   768	        type: string
   769	        notes: HH:MM 24-hour format
   770	      weekend_send_enabled:
   771	        type: boolean
   772	    notes: |
   773	      Per-tenant outbound sending hours. Concierge respects when scheduling
   774	      orange-tier sends.
   775	
   776	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   777	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
   778	  # declare this config key; the W4 ADR will introduce both the field
   779	  # and its consumer at the same time. Including it in v0.3 without an
   780	  # active consumer would be speculative schema.
   781	
   782	# ============================================================================
   783	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   784	# ============================================================================
   785	
   786	decision_log_payload_extension:
   787	  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
   788	  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
   789	  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
   790	  # that ships alongside Tier 2 activation. v0.3 introducing the payload
   791	  # key without enforcement would violate review-schema-change §3
   792	  # (bounded values require CHECK or trigger). Tier 2 schema work owns
   793	  # the constraint + writer; this v0.3 supplement is silent on it.
   794	  deferred_to_future_adr:
   795	    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
   796	    schema_owner: future W4-polish supplement (not v0.3)
   797	    rationale: |
   798	      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
   799	      separate post-launch quality metric outside Gate A. The payload key,
   800	      its [0.0, 1.0] range validation, and the sample-rate config field
   801	      all land together with Tier 2 activation. Tier 2 doesn't activate
   802	      until the voice classifier microservice ships + first pilot tenant
   803	      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
   804	      payload shape to avoid declaring schema without enforcement.
   805	
   806	# ============================================================================
   807	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   808	# ============================================================================
   809	
   810	migration_sequence:
   811	  forward: migrations/v0.2-to-v0.3.sql
   812	  rollback: migrations/v0.3-to-v0.2.sql
   813	
   814	  pre_conditions:
   815	    - v0.2 migration applied (voice_corpus + tone_rule + recent_edit tables exist)
   816	    - validate_voice_scores trigger active on entities table
   817	    - RLS + ifos_app grants from Day-4 §6.3 in place
   818	    - migration-test tenant row exists in tenants table
   819	
   820	  steps:
   821	    1: |
   822	      Verify v0.2 prerequisites (DO block in migration §1).
   823	    2: |
   824	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   825	      ifos_app grants + 2 indexes (migration §2).
   826	    3: |
   827	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   828	      (migration §3).
   829	    4: |
   830	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   831	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   832	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   833	      candidate / contact / brief / placement / opportunity entity_types.
   834	      Re-attaches the trigger to entities table (migration §4).
   835	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   836	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   837	    5: |
   838	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   839	      hard-fails on unknown config keys (Rule 2); type-validates the 3 new
   840	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   841	    6: |
   842	      Smoke verification DO block confirms both cash_conductor_*
   843	      tables exist (migration §6).
   844	    7: |
   845	      COMMIT; or ROLLBACK on any error.
   846	
   847	  post_migration_steps:
   848	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   849	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   850	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   851	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   852	       Cat-β findings closed
   853	
   854	# ============================================================================
   855	# §7 — Codex ratification path
   856	# ============================================================================
   857	
   858	codex_ratification:
   859	  skill: review-schema-change
   860	  expected_round_trips: 1-2 (mechanical fixes only)
   861	  manifest_queue_position: 44 (after v0.2 supplement at 29)
   862	
   863	# ============================================================================
   864	# §8 — Open questions (structured per review-schema-change §8)
   865	# ============================================================================
   866	
   867	open_questions:
   868	
   869	  Q1_employment_type_enum_completeness:
   870	    question: Are 6 employment_type enum values sufficient for UK recruitment?
   871	    options:
   872	      A: |
   873	        Keep 6 values as in §1.candidate.employment_type — perm, contract,
   874	        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
   875	      B: |
   876	        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
   877	      C: |
   878	        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
   879	        (array of allowed strings); validate at write time against tenant's list.
   880	    v0_3_default: A
   881	    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
   882	      outside A, escalate to B or C.
   883	
   884	  Q2_key_skills_max_length:
   885	    question: Cap at 20 items per candidate adequate?
   886	    options:
   887	      A: Keep cap at 20 (validator hard-fails over).
   888	      B: Increase to 50 (handles senior technical candidates with deep stacks).
   889	      C: Remove cap entirely (rely on application-layer pruning).
   890	    v0_3_default: A
   891	    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
   892	      of candidates hit the 20-item cap, escalate to B.
   893	
   894	  Q3_placement_status_enum_lifecycle:
   895	    question: 6-state placement_status enum maps to Bullhorn's native state machine?
   896	    options:
   897	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   898	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   899	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   900	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   901	    v0_3_default: A
   902	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   903	      escalate to B or C if 1:1 mapping breaks.
   904	
   905	  Q4_cash_conductor_transactions_retention:
   906	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   907	      What's the production retention policy?
   908	    options:
   909	      A: 7-year retention with automated pseudonymization at year 7 (hash
   910	         payee_name_raw + description; preserve amount + dates for audit).
   911	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   912	         rows retained beyond 7 years for cross-period reconciliation).
   913	      C: Per-tenant retention override in tenant_adapters.config.
   914	    v0_3_default: A
   915	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   916	      tenant requires shorter retention, escalate to C with tenant-specific
   917	      override. Pseudonymization implementation lands in W4-polish slice.
   918	    production_use_gating: |
   919	      Until pseudonymization implementation lands, production use of
   920	      cash_conductor_transactions table is GATED by an explicit per-tenant
   921	      DPA addendum signed by founder + tenant. Migration-test tenant data
   922	      is not subject to this gate.
   923	
   924	  Q5_unknown_config_keys_handling:
   925	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   926	    options:
   927	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   928	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   929	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   930	    v0_3_default: A
   931	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   932	      for forward-compat, escalate to B or C with explicit ADR.
   933	
   934	# ============================================================================
   935	# §9 — Why v0.3 is the right unblock
   936	# ============================================================================
   937	
   938	rationale: |
   939	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   940	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   941	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   942	  adds 14 entity JSONB keys + 2 auxiliary tables + 3 config keys. The
   943	  per_claim_confidence_distribution payload key originally planned for
   944	  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
   945	  §5 of this supplement); v0.3 is silent on payload schema extensions.
   946	
   947	  After v0.3 ratifies + migration applies:
   948	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   949	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   950	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   951	      placement_status, week_1_status_vault_path, satisfaction_signal,
   952	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   953	      are now schema-backed. (Note: week_1_status_note narrative now lives
   954	      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
   955	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   956	      seniority — not yet in schema; brief.start_date should be
   957	      start_date_target; opportunity.sector — not yet in schema). These
   958	      residual gaps are tracked in W4-polish-schema-extension backlog;
   959	      they do not block v0.3 ratification but do require a Scribe agent.md
   960	      consistency-pass before Scribe ratifies.
   961	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   962	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   963	    - Concierge tenant_adapters.config field refs valid
   964	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   965	
   966	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   967	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   968	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   969	  not schema gaps.
   970	
   971	# ============================================================================
   972	
   973	end_of_supplement: true

 succeeded in 174ms:
45:**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).
90:2. **Accept Issue 2 fix** (mechanical; bundles with Concierge notification work)
93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
119:| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
123:| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
155:## Janitor Round-5 (remediation) — empirical confirmation of bilateral pattern
157:After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
161:3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
184:## Janitor Round 6 (exceeds hard ceiling) — 4 more NEW findings, all different from Rounds 4-5
210:## Janitor Round 7 — 23+ unique issues; pattern definitively closed
212:After all 4 Round-6 issues remediated on Janitor (commit `1939d9b`), Round 7 returned REJECTED with **4 more new findings**, none from Rounds 4-6:
250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
263:- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
264:- §1 vault path additions: Scribe + Concierge
273:| Janitor | 6 | `20260524T112807Z-81339` |
274:| Scribe | 5 | `20260524T112917Z-82352` |
275:| Cash Conductor | 5 | `20260524T113038Z-83732` |
277:| Concierge | 7 | `20260524T113247Z-86019` |
283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
287:#### Category β — Schema-supplement-needed (v0.3 supplement is a founder-action gate before W4-W13 builds)
289:- Janitor: `candidate.linkedin_url` not in schema
290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
293:- All five are blocked on v0.3 supplement landing (founder review at first-pilot-onboarding) — DOCUMENTED IN W4 BACKLOG
297:- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
299:- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
300:- `ESC_OPEN_BANKING_TOKEN_AGING` — Cash Conductor uses <30 days warn / <7 days blocking staged; catalogue defines ≤14 days info. Resolution: align catalogue to Cash Conductor's actual staged definition.
301:- `ESC_AUTOSEND_RACE` — Cash Conductor uses for payment-received-during-chase race; catalogue defines for two-agents-same-payload_hash race. Resolution: widen to cover both.
308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
315:  - Janitor Step 1 auth refresh emits ESC without decision row
316:  - Scribe Steps 2-3, 7 partial coverage
317:  - Cash Conductor Steps 7-8, 11
319:  - Concierge Steps 7, 11
324:**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
355:- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
357:- `ESC_LIFECYCLE_STATE_UNKNOWN` — both Janitor placement + Concierge taxonomy out-of-bounds
358:- `ESC_OPEN_BANKING_TOKEN_AGING` — three staged behaviors aligned to Cash Conductor §6
371:| Janitor | 6 | 6 | 0 (different findings; 1 Cat-γ closed, 1 new) |
372:| Scribe | 5 | 4 | −1 |
373:| Cash Conductor | 5 | 5 | 0 (different findings; 1 Cat-γ closed, 1 new) |
375:| Concierge | 7 | 5 | −2 (AgentMail boundary + ESC widening) |
393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
422:**Per-agent state at Phase 4 close:**
427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/bullhorn-integration-path.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
nl: docs/verticals/recruitment/bullhorn-integration-path.md: No such file or directory

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '382,428p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   382	  scribe:
   383	    candidate: R+W         # call-summary field extraction
   384	    contractor: R+W        # call-summary field extraction
   385	    client: R
   386	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
   387	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
   388	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
   389	    placement: R+W         # check-in field extraction
   390	    timesheet: R           # reads for placement-context resolution on check-in calls
   391	
   392	  cash_conductor:
   393	    candidate: none        # no Bullhorn dependency
   394	    contractor: none
   395	    client: R              # reads client billing details
   396	    contact: R             # reads for invoice addressee resolution
   397	    brief: none
   398	    opportunity: R         # v0.3 NEW — reads opportunity for invoice-context
   399	    placement: R           # reads for client linkage on invoice
   400	    timesheet: R           # reads to verify billable hours match invoiced amounts
   401	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   402	
   403	  sourcing_scout:
   404	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   405	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   406	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   407	    # writes its proposed-candidate rows + reads opportunity context. These
   408	    # are entity-level access overrides codified here.
   409	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   410	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   411	    client: R
   412	    contact: R
   413	    brief: R               # reads to filter candidates
   414	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   415	    placement: none
   416	    timesheet: none
   417	
   418	  concierge:
   419	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   420	    contractor: R+W        # writes lifecycle states for contractor placements too
   421	    client: R
   422	    contact: R             # reads for outbound recipient resolution
   423	    brief: R
   424	    opportunity: R
   425	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   426	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   427	
   428	# ============================================================================

exec
/bin/zsh -lc 'rg -n "endpoint|Timesheet|Placement|Candidate|ClientCorporation|JobOrder|Note|Cash Conductor|Concierge|Janitor|Scribe" docs/verticals/recruitment/bullhorn-integration-path.md' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: docs/verticals/recruitment/bullhorn-integration-path.md: IO error for operation on docs/verticals/recruitment/bullhorn-integration-path.md: No such file or directory (os error 2)

exec
/bin/zsh -lc "rg --files docs | rg 'bullhorn|integration|sequencing-target|autosend-safety-policy|operational-hygiene'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/decisions/autosend-safety-policy.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
docs/runbooks/operational-hygiene-protocol.md
docs/operations/bullhorn-outreach-emails.md

exec
/bin/zsh -lc "nl -ba docs/decisions/bullhorn-integration-path.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/sequencing-target.md | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# v1.0 agent sequencing target — decision document
     2	
     3	**Date:** 2026-05-16 (Week 0, Day 3)
     4	**Status:** Accepted (Day 3 session close, 2026-05-16). Single-pass technical decision, no commercial gating.
     5	**Author:** Claude Code, founder decision logged 2026-05-16
     6	**Surfaced by:** Master brief §6 Day 3 (lines 469-473) — "Confirm or revise Ultraplan §9's 'close first 3 pilots fastest' → `.agents/decisions/sequencing-target.md`" (note: master brief §6 names `.agents/decisions/`; this document lives at `docs/decisions/sequencing-target.md` matching the convention established by ADR-001 through ADR-003 + bullhorn-integration-path.md — **Spec gap §1-A** flagged for atomic correction).
     7	**Submodule SHA referenced:** `c21fbfe991a0030ea055bd8e2389a0801a424383`
     8	
     9	**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
    10	
    11	---
    12	
    13	## Section 1 — Context and sequencing criteria
    14	
    15	### 1.1 — What we're deciding
    16	
    17	Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
    18	
    19	| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
    20	|---|---|---|---|---|
    21	| A1 | Diagnostic | 3-4 | LinkedIn + Companies House + scrape | "Sales tool — needed before any other agent matters" |
    22	| A2 | Janitor | 5 | Bullhorn MCP (R+W) | "First demoable inside-ATS result; day-30 before/after closes deals" |
    23	| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
    24	| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
    25	| A5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | "First daytime always-on agent" |
    26	| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
    27	
    28	Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
    29	
    30	**Three sub-decisions in this document:**
    31	
    32	- **A. First agent.** Which agent ships first in Week 3-4? Anchors the renderer (ADR-003) + `_shared/` helpers (Week-1-2 prereqs from ADR-002) + Postgres `decision_log` (Day 4 Week 0) end-to-end test. Affects how risk surfaces — first agent is the smoke test for every substrate dependency.
    33	- **B. Sequence for agents 2-6.** The remaining five agents in some order across Weeks 5-13. Three candidate orderings compared in §3.
    34	- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
    35	
    36	### 1.2 — Why this matters now
    37	
    38	Three reasons the sequencing decision lands this week, not later:
    39	
    40	**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
    41	
    42	**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
    43	
    44	**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
    45	
    46	The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
    47	
    48	### 1.3 — Sequencing criteria
    49	
    50	Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
    51	
    52	| # | Criterion | What it measures | Why it informs sequencing |
    53	|---|---|---|---|
    54	| 1 | **Implementation simplicity** | Lines of agent code in `agent.md` workflow + number of MCP servers touched + complexity of output contract (single-output vs multi-stage vs lifecycle-state) | Simpler agents land faster and exercise less substrate at once — better first-agent candidates because failure modes are easier to isolate |
    55	| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
    56	| 3 | **Risk de-risking** | Which named risks the agent's success/failure surfaces — Risk #1 (cortextOS primitives), Risk #2 (Bullhorn auth), Risk #5 (renderer-not-built) — per `docs/RISK-REGISTER.md` | Building risk-surfacing agents earlier converts known-unknowns into known-knowns; building risk-deferring agents earlier preserves optionality but pushes the surprise window later |
    57	| 4 | **Commercial value** | Whether the agent's output is demoable to a design partner / first paying customer per Product Spec §2.2 R-rows | Earlier commercial-value agents accelerate the first-pilot conversion (Ultraplan §9 line 725 target Week 12); but commercial-value agents are typically the more complex ones, conflicting with criterion 1 |
    58	| 5 | **Dependencies on other agents** | Does this agent's output feed another agent? Does this agent require another agent's output to function? | Agents with downstream dependents should ship before their dependents; agents with no upstream dependencies are good first candidates |
    59	| 6 | **Tenant-onboarding readiness** | Can this agent be deployed to one tenant without all infrastructure being live? (E.g. does it need the wiki API in v1.0 weeks 11-13, or only the Week-1-2 substrate?) | Earlier-readiness agents can pilot in shadow mode against the first design partner before all v1.0 infra is complete |
    60	
    61	The six criteria intentionally tension against each other — implementation simplicity (1) trades off against commercial value (4); substrate exercise (2) trades off against risk-isolation (3). The §2 per-agent assessments make the trade-offs visible per agent; the §3 sequencing options weight them differently; the §4 recommendation picks one weighting.
    62	
    63	### 1.4 — Scope cuts and v1.0 minimum
    64	
    65	Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
    66	
    67	> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
    68	
    69	There are actually **two named contingency paths**, corresponding to two different failing risks:
    70	
    71	- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
    72	- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
    73	
    74	Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
    75	
    76	The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
    77	
    78	### 1.5 — One small but real finding before §2 begins
    79	
    80	Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
    81	
    82	Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
    83	
    84	**Section 4's recommendation evaluates both orderings** (founder-prompt-Alpha and master-brief-Alpha) against the §1.3 criteria, picks whichever wins on the merits, and explicitly aligns with the master brief by default unless rationale exists to revise it. This document is the "confirm or revise" decision per master brief §6 Day 3 line 471 — both options are on the table.
    85	
    86	---
    87	
    88	## Section 2 — Per-agent readiness assessment
    89	
    90	Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
    91	
    92	### 2.1 — A1 Diagnostic
    93	
    94	| Criterion | Score | Rationale |
    95	|---|---|---|
    96	| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
    97	| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
    98	| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
    99	| 4. Commercial value | **Medium** | Internal sales tool per Product Spec §2.2 R13 ("Not on the customer pricing card"). Drives qualified discovery-call pipeline. Demoable to a prospect but not the closing demo. Ultraplan §8.1 line 499 Gate B target: "≥30% of diagnostics produced lead to a discovery call booked" |
   100	| 5. Dependencies on other agents | **None** | Standalone. No upstream agent dependency; no downstream agent consumes Diagnostic output |
   101	| 6. Tenant-onboarding readiness | **High** | Runnable from end of Week 2 with renderer + `_shared/` + Postgres decision_log. No vault `_secrets.env` complexity (no per-tenant Bullhorn OAuth needed), no wiki API needed. Single-tenant deployable immediately |
   102	
   103	**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
   104	
   105	### 2.2 — A2 Janitor
   106	
   107	| Criterion | Score | Rationale |
   108	|---|---|---|
   109	| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 513 estimate **L (2 weeks)** — the Bullhorn MCP work is rate-limiting per Ultraplan §8.1 line 514 ("Bullhorn MCP server doesn't exist yet — this is the critical-path build"). One MCP server (Bullhorn) + Companies House for enrichment. Single primary output (cleanup report) but with continuous nightly cron pattern |
   110	| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
   111	| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
   112	| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
   113	| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
   114	| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn `client_id` + `client_secret` (commercial action per Day 2 §6.1) + per-tenant Bullhorn admin OAuth authorisation (the browser dance per Day 2 §3.1). First-pilot onboarding wizard Day 2 step (Product Spec §5.2) is the moment Janitor can be enabled per tenant |
   115	
   116	**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
   117	
   118	### 2.3 — A3 Scribe
   119	
   120	| Criterion | Score | Rationale |

 succeeded in 0ms:
     1	# Bullhorn integration path — decision document
     2	
     3	**Date:** 2026-05-16 evening / 2026-05-17 (Week 0, Day 2)
     4	**Status:** Proposed (Sub-decision C Accepted technically; Sub-decisions A + B Proposed pending commercial verification per §1.3)
     5	**Author:** Claude Code, founder commercial verification pending for A + B
     6	**Surfaced by:** Master brief §6 Day 2 (lines 466-467) — "Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev." Plus Ultraplan §11 Day 2 (lines 847-849).
     7	**Submodule SHA referenced:** `c21fbfe991a0030ea055bd8e2389a0801a424383`
     8	
     9	**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
    10	
    11	---
    12	
    13	## Section 1 — Context and commercial blockers
    14	
    15	### 1.1 — What we're deciding
    16	
    17	Three sub-decisions, named in master brief §6 Day 2 line 466 and extended in Ultraplan §11 Day 2 lines 847-849.
    18	
    19	**Sub-decision A — Bullhorn integration path.** Marketplace partner programme membership (with its access tier, scope, certification, ongoing fees) versus direct API access (per-tenant Bullhorn-account-admin authorisation of IFOS as a connected app). Master brief §6 Day 2 line 466 explicitly names this as the day's decision. The path chosen determines whether `packages/mcp-connectors/bullhorn/` ships as a marketplace-registered connector or a direct-API connector — the *code* in either case is similar OAuth + REST plumbing, but the *operational, commercial, and rate-limit* surfaces differ materially.
    20	
    21	**Sub-decision B — OAuth flow.** Master brief §6 Day 2 line 466 pre-states a recommendation: "browser dance for production, service-account for dev." This is the authorization-code grant (per-tenant browser dance, refresh-token cycle) for production tenants, plus client-credentials grant (service account) for IFOS-internal sandbox/dev work. Sub-decision B verifies that recommendation against Bullhorn's actual OAuth implementation and pins the per-tenant token storage path (per `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution: `/vault/<tenant>/_secrets.env`, mode `0600`).
    22	
    23	**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
    24	
    25	### 1.2 — Why this matters now
    26	
    27	Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
    28	
    29	**Bullhorn dependency count for v1.0 agents:**
    30	
    31	| Agent | Bullhorn dependency in v1.0 | Source |
    32	|---|---|---|
    33	| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
    34	| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
    35	| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
    36	| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
    37	| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
    38	| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
    39	
    40	**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
    41	
    42	This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.
    43	
    44	### 1.3 — What we know vs what we don't
    45	
    46	Honest accounting of which sub-decisions can land tonight from technical analysis alone versus which require commercial verification before the Status flips from Proposed to Accepted.
    47	
    48	**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**
    49	
    50	- The structural shape of Bullhorn's OAuth flows (authorization code vs client credentials) and which scenarios each is suited to.
    51	- The endpoint surface area available via the public REST API at `https://rest.bullhornstaffing.com/rest-services/<corpToken>/` (the documented entry pattern).
    52	- Token lifecycle outline: short-lived REST sessions, long-lived refresh tokens, periodic re-auth dance via the Bullhorn login URL.
    53	- Pagination / rate-limit *shape* (per-second + per-minute + per-day caps in some accounts).
    54	- Per-tenant credential storage location (resolved by `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C: `/vault/<tenant>/_secrets.env`).
    55	- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
    56	
    57	**Commercially gated (founder must verify before final Status flip to Accepted on Sub-decisions A and B):**
    58	
    59	- Whether Intel Force Ltd is currently a member of the **Bullhorn Marketplace Partner Programme** (or what the application timeline + cost would be). The marketplace partner application process is publicly known to involve a technical review, security audit, and ongoing partner fees — but the specifics for IFOS's tier and tenant volume are commercial-confidential and need a direct conversation.
    60	- Whether **marketplace-tier API access differs from direct-API access** in rate limits, available scopes (e.g. write to JobOrder, write to Note, webhook subscription), or sandbox availability. Bullhorn's public docs are sparse on the deltas; partner reps know the actuals.
    61	- Whether the marketplace-tier cost structure works at IFOS's volume (3-6 tenants v1.0; 100 by end of 2027 per Product Spec §5.4 line 369-373). Partner fees may be flat or per-tenant; this matters at scale.
    62	- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
    63	
    64	**Commercial-blocker table** — specific question, specific contact path, specific timing:
    65	
    66	| Sub-decision | Commercial gate question | Who answers | When | Notes |
    67	|---|---|---|---|---|
    68	| A | "Is Intel Force Ltd in the Bullhorn Marketplace Partner Programme, or what's the application timeline + first-year cost?" | Bullhorn partnerships team — submit via Marketo form at `https://www.bullhorn.com/become-a-partner/` (verified 2026-05-23). Earlier draft cited `partnerships@bullhorn.com` which does NOT exist (mail bounced). | Submit any weekday; response 2-5 business days | Cold inbound via form; routes internally. UK office at 7 Devonshire Square, London EC2M 4YH for escalation. |
    69	| A | "What are the API rate-limit / scope deltas between marketplace tier and direct API at our expected 3-6 tenant pilot volume?" | Same Bullhorn partnerships team, or escalation to developer support | Same conversation | The answer determines whether direct-API can serve v1.0 or marketplace registration is a v1.0 blocker |
    70	| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
    71	| B | "Does Bullhorn's OAuth implementation support client_credentials grant against the sandbox environment?" | Bullhorn developer support — `developer.bullhorn.com` portal contact form, or via the partnerships rep once Sub-decision A's contact path is open | Monday-Tuesday | Used to verify that the §6 Day 2 line 466 recommendation ("browser dance for production, service-account for dev") is implementable end-to-end |
    72	| B | "Refresh-token TTL and rotation behaviour specifics" | Same | Same | Affects renderer §3.3.2 `.env` materialisation: how often does per-tenant `_secrets.env` need rotation? Documented Bullhorn behaviour varies by account; partner-rep gives the canonical numbers |
    73	
    74	The Sunday design-partner conversation 2 is the most time-sensitive: it can flip the entire premise of Sub-decisions A and C. Founder cadence per master brief §6 Day 2 (line 467) and §11.2 line 791 ("Day 2 — Tuesday — Bullhorn integration path... — Design-partner conversation 2") puts this as a parallel-to-Claude-Code track.
    75	
    76	### 1.4 — Tonight's scope
    77	
    78	Stated explicitly so the founder knows what's landable tonight vs what waits for commercial answers:
    79	
    80	- **Tonight (this document):**
    81	  - Sub-decision C in full — technical analysis, per-agent endpoint table, webhook-vs-poll decisions, rate-limit budget allocation. **Status: Accepted** on Sub-decision C alone, no commercial gating.
    82	  - Sub-decisions A and B — full technical analysis (Sections 2 and 3 of this document), with explicit Status: Proposed flags pointing at the §1.3 commercial-blocker table.
    83	  - Recommendation block (§5) names the technical preference, the commercial-answer conditions that flip Status to Accepted, and the documented v1.0-scope-cut contingency if commercial answers go badly.
    84	- **Sunday (2026-05-17):**
    85	  - Founder runs design-partner conversation 2 — primary gate is "which ATS does the first pilot use?". Result lands as a one-line update to this document's §1.3 row 3.
    86	  - Founder runs Bullhorn partnerships outreach — submission via Marketo form at `https://www.bullhorn.com/become-a-partner/` (verified 2026-05-23; the earlier `partnerships@bullhorn.com` draft was wrong — that mailbox does not exist). Result may not come back same-day.
    87	- **Monday (2026-05-18):**
    88	  - Founder runs Bullhorn developer-support outreach for Sub-decision B specifics if not already covered by partnerships rep.
    89	  - Final Status flip on Sub-decisions A and B based on commercial answers landed.
    90	  - Document is re-committed with Status: Accepted on A and B once founder logs the decision.
    91	- **Day 7 review (master brief §6 Day 7 Sunday):**
    92	  - Single-sentence test Q3 ("Have we cleared the auth path?") answered Yes iff Sub-decisions A and B are Accepted.
    93	  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
    94	
    95	**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
    96	
    97	### 1.5 — Gate hierarchy (Day-11 clarification)
    98	
    99	Three distinct gates govern Bullhorn-touching work, in temporal order:
   100	
   101	| Gate | Trigger | Status |
   102	|---|---|---|
   103	| Week-1 prereq code | None — substrate is ATS-agnostic | DONE (Phases 1-5 landed Day 8) |
   104	| Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (`sequencing-target.md` §2.1) | Awaits Q1 LOI |
   105	| Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
   106	
   107	---
   108	
   109	## Section 2 — Sub-decision A: marketplace vs direct API
   110	
   111	### 2.1 — Bullhorn marketplace partner programme
   112	
   113	Bullhorn's public surfaces for the partner programme are deliberately thin. Three URLs surveyed Day 2 (2026-05-16 evening):
   114	
   115	- `https://www.bullhorn.com/marketplace/` — consumer-facing directory of "300+ pre-integrated technology partners" filterable by category / location / platform. The only partner-programme reference on the page is the line: **"Become a partner — Are you a supplier to the recruitment space? Join the Marketplace today."** This routes to `/become-a-partner/`.
   116	- `https://www.bullhorn.com/become-a-partner/` — landing page. Main CTA: **"Fill out the form to learn more about our partner programs."** References three external resources (FAQs, Bullhorn Developer Program, Fair Use Policy) but the page itself contains **no specific information** on application process, tiers, certification, security review, fees, ongoing costs, or timeline. The only substantive description on the page is: **"The Bullhorn Marketplace gives our customers the choice, confidence, and customization they need to innovate with agility."**
   117	- `https://www.bullhorn.com/marketplace/partners/` — returns HTTP 404 (verified 2026-05-16).
   118	
   119	**What is publicly stated:**
   120	
   121	- The programme exists and admits "suppliers to the recruitment space."
   122	- Bullhorn Marketplace currently lists 300+ partner integrations (the headline number on the marketplace page).
   123	- There is a separately-named **Bullhorn Developer Program** distinct from the Marketplace partner programme (linked from `/become-a-partner/`) — implying a possible two-tier structure: developer-tier access to APIs (lighter) vs marketplace-listed partner (heavier).
   124	
   125	**What is NOT publicly stated** (confirmed commercially gated to founder verification per §1.3):
   126	
   127	- The application process (forms to fill, technical review steps, security audit requirements).
   128	- Whether the programme has tiers (e.g. Standard / Premier / Strategic) and what gates each tier.
   129	- Whether marketplace-tier partners get different API scope, rate-limit ceilings, or webhook access vs direct-API/developer-tier.
   130	- Annual partner fees, certification costs, MRR thresholds, revenue-share or referral economics.
   131	- Application-to-approval timeline.
   132	- Co-marketing benefits, listing visibility on the marketplace page, lead-routing programmes.
   133	
   134	**Source citation for this section:** the three URLs above, all accessed 2026-05-16.
   135	
   136	**Inference (clearly marked as inference, not Bullhorn's stated position):** the gap between "free developer account" and "marketplace-listed partner" is structurally common across enterprise SaaS platforms (Salesforce AppExchange, HubSpot Marketplace, ServiceNow Store all follow this pattern). The plausible IFOS path through this commercial space is: register for the Bullhorn Developer Program first (which usually grants API access for a tenant the developer controls or for sandbox dev), then apply for marketplace listing once an integration is shippable. Whether either path is required for IFOS production tenants — the actual gate — is the §1.3 partnerships@bullhorn conversation.
   137	
   138	### 2.2 — Direct Bullhorn API access
   139	
   140	Two URLs surveyed:
   141	
   142	- `https://developer.bullhorn.com/` — redirects to `https://bullhorn.github.io/docs` (301 Moved Permanently).
   143	- `https://bullhorn.github.io/docs` — Bullhorn's developer documentation landing. Names three API surfaces: REST API, OAuth, SOAP (legacy). The REST and OAuth links are the operative ones for v1.0.
   144	
   145	**The technical model verified from Bullhorn's "Getting Started with REST" documentation (cited inline below):**
   146	
   147	- **Two-step auth.** Step 1: OAuth 2.0 authorization-code grant against `https://auth-{loginInfo}.bullhornstaffing.com/oauth/authorize` returns an auth code; POST to `/oauth/token` exchanges code for an access_token + refresh_token. Step 2: REST login at the per-tenant `restUrl` exchanges the access_token for a `BhRestToken` (the REST session token) plus a per-tenant base URL.
   148	- **`BhRestToken` (REST session token)** is presented on each subsequent REST call in three accepted forms: URL query parameter, HTTP header (`BhRestToken` or `BHRestToken`), or cookie. On expiry, REST calls return 401 — application must re-run /login. (Bullhorn doc verbatim: "When the current session key expires, your query will return a 401 response.")
   149	- **Per-tenant model.** Each tenant has its own `corpToken` and its own per-tenant `restUrl` returned by /login. Operations are scoped by the corpToken; IFOS must hold per-tenant token state. This maps cleanly to the per-tenant credential model already pinned in `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution (`/vault/<tenant>/_secrets.env`, mode `0600`).
   150	- **client_id / client_secret acquisition.** Bullhorn doc verbatim: **"Bullhorn customers can obtain OAuth keys for developing applications...by creating a support ticket via the Bullhorn Resource Center."** This is not a self-service developer signup — there is a Bullhorn-side gate even for the developer-tier path. Implication: every IFOS pilot tenant must open a support ticket with Bullhorn to authorise IFOS as a connected app, or IFOS must hold a single set of client credentials at the IFOS-application level and route per-tenant auth through it. The structural distinction here is exactly what Sub-decision A pivots on — partnerships@bullhorn confirms whether marketplace status grants application-level credentials.
   151	- **Documented rate limit signal:** Bullhorn's REST docs name **HTTP 429** as "Rate Limited — Wait 1 second then retry request. Repeat until successful." That's the only rate-limit reference in the public docs surveyed; specifics (per-second/minute/day caps, per-corpToken or per-application) are not documented and are commercially gated to verification per §1.3.
   152	- **Sandbox environment availability:** not addressed in any public doc surveyed. Commercially gated.
   153	
   154	**Citations:**
   155	
   156	- `https://bullhorn.github.io/docs` — landing page naming REST/OAuth/SOAP API surfaces.
   157	- `https://bullhorn.github.io/rest-api-docs/` — REST API reference, named two-step auth and 429 rate-limit handling.
   158	- `https://bullhorn.github.io/Getting-Started-with-REST` — auth flow specifics (endpoint URLs, token TTLs, refresh-token rotation, credential acquisition path).
   159	
   160	### 2.3 — Comparison rubric
   161	
   162	Eight criteria. Cells marked **CG** (commercially gated) require founder verification per §1.3 before flipping from inference to confirmed.
   163	
   164	| Criterion | Marketplace | Direct (Developer Program) |
   165	|---|---|---|
   166	| Time-to-first-call (greenlight → working API call against a tenant) | **CG.** Inference: marketplace certification + security review typically 4-12 weeks for enterprise SaaS programmes of this maturity. Bullhorn-specific timeline not stated publicly. | **CG.** Confirmed from public docs: customer raises Bullhorn support ticket per /Getting-Started-with-REST to obtain client_id/client_secret. ETA per ticket cycle — likely 1-5 business days per pilot tenant. |
   167	| Per-tenant onboarding friction (admin auth, scope review) | **CG.** If marketplace tier grants IFOS application-level credentials, per-tenant friction may reduce to "tenant clicks Authorise from marketplace listing." | Each pilot tenant raises a Bullhorn support ticket + tenant admin authorises IFOS as a connected app via per-tenant OAuth screen. Per-tenant friction: 1 support ticket + 1 OAuth dance per pilot tenant. |
   168	| Co-marketing benefit | Listed in the 300+ partner directory on bullhorn.com/marketplace; potentially Bullhorn-sales-rep co-selling motion. **CG** on specific benefit terms. | None. |
   169	| Cost at 3-tenant pilot scale (2026 H2, Boutique tier per Product Spec §3.1) | **CG.** Public docs do not name partner fees. Inference based on comparable enterprise SaaS marketplace programmes: annual partner fee typically $5K-$25K + possibly per-listing or per-referral revenue-share. | **CG.** Public docs do not name developer-program fees. Inference: likely zero or nominal for the developer-tier API access. Per-tenant cost zero — the tenant pays Bullhorn, IFOS pays nothing per call. |
   170	| Cost at 100-tenant target scale (Product Spec §5.4 end-2027 target) | **CG.** May or may not scale linearly with tenant count. Some marketplace programmes have flat annual fees; others meter on tenant or revenue volume. | **CG.** If developer-tier cost is zero or nominal, scales fine. Risk: per-tenant Bullhorn support tickets at 100 tenants become operational drag at IFOS-Customer-Success layer (Product Spec §5.4 line 373 names ≤8 hours of human time per customer onboarding — Bullhorn ticket may consume a meaningful fraction). |
   171	| Scope / rate-limit deltas | **CG.** Marketplace tier may grant elevated rate limits, write access to additional entities (e.g. JobOrder write), webhook subscription endpoints not available to direct-tier. Public docs do not state. | Public REST API documentation lists all REST endpoints uniformly — no tier-gated endpoints stated in public docs. Inference: all entity reads/writes are available to authenticated direct-tier callers, subject to per-corpToken scope at the tenant-account-admin level. Rate limit ceiling **CG**. |
   172	| Founder operational overhead (per tenant + ongoing) | **CG.** If marketplace handles per-tenant auth: low per-tenant overhead. Annual partner-programme obligations: technical review responses, security questionnaire renewals, marketplace listing maintenance — non-trivial ongoing. | Per-tenant: one Bullhorn support ticket request from the tenant admin per pilot. Ongoing: zero programme obligations; only IFOS-side OAuth token refresh management. |
   173	| **Switching cost later** (start direct, move to marketplace at v1.1+) | n/a (this is the destination) | **Low if the connector code treats auth as a swap-point per §1.4 fallback architecture.** The connector's REST endpoint calls (Sub-decision C surface) are identical between paths. The auth module — `packages/mcp-connectors/bullhorn/src/auth.ts` and the `_secrets.env` materialisation in the renderer — is the only differing surface. Bounded to ~200-400 lines of code per the design in `agent-bundle-renderer-design.md` §3.3.4. |
   174	
   175	The **Switching cost** row is the load-bearing design constraint. It validates the §1.4 fallback architecture: the connector can scaffold against direct-API in Week 1-2 without locking in the wrong long-term path. If Sub-decision A lands as marketplace-required in Week 1-2 founder commercial verification, the swap is a Week-2-3 task scoped to the auth module.
   176	
   177	### 2.4 — Technical recommendation (Proposed)
   178	
   179	**Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes.**
   180	
   181	Three justifications:
   182	
   183	1. **The §1.4 honest-signal fallback architecture demands it.** With Bullhorn commercial answers slow-rolling (likely Monday at earliest, possibly later), Week 1 connector scaffolding cannot block on partnerships@bullhorn responses. Scaffolding against the documented direct-API auth flow lets the connector progress; the §2.3 Switching-cost analysis shows the auth-module swap is bounded.
   184	2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
   185	3. **Marketplace is a commercial decision, not a technical one, at v1.0 scale.** At 3-6 pilot tenants, the marketplace's primary benefit (co-marketing, listing visibility, possibly elevated rate limits) is dominated by the per-tenant pilot economics. The marketplace partnership is appropriate when IFOS has shippable product and 10+ tenants — i.e. v1.1+ commercial timing.
   186	
   187	**Commercial answers that flip the recommendation:**
   188	
   189	| Commercial finding | Effect on recommendation |
   190	|---|---|
   191	| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
   192	| Marketplace adds material per-tenant cost above ~$1K/yr at 3-tenant scale (partnerships@bullhorn answer) AND direct-API scope is sufficient | Direct preferred for v1.0; marketplace deferred to v1.1+ when revenue funds the programme cost. Current recommendation stands. |
   193	| Direct-API requires per-tenant Bullhorn support ticket that slows pilot onboarding by >3 business days per tenant (Bullhorn dev support answer) | Marketplace may win on time-to-first-call even if costlier. Re-evaluate based on actual ticket-cycle data from first pilot's setup. |
   194	| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
   195	
   196	**Status: Proposed.** Status flips to Accepted on either: (a) partnerships@bullhorn confirms marketplace is not required for v1.0 production tenant access AND first design partner uses Bullhorn; OR (b) founder explicitly accepts the documented fallback if marketplace turns out required, and re-cuts the v1.0 timeline to absorb the marketplace certification window.
   197	
   198	---
   199	
   200	## Section 3 — Sub-decision B: OAuth flow
   201	
   202	### 3.1 — Authorization-code grant (browser dance)
   203	
   204	The flow Bullhorn documents at `https://bullhorn.github.io/Getting-Started-with-REST`. Verified specifics:
   205	
   206	**Endpoint structure:**
   207	- Authorise: `https://auth-{loginInfo}.bullhornstaffing.com/oauth/authorize`
   208	- Token: `https://auth-{loginInfo}.bullhornstaffing.com/oauth/token`
   209	
   210	The `{loginInfo}` placeholder is per-tenant-cluster — IFOS resolves it via the Bullhorn `loginInfo` lookup endpoint before kicking off OAuth. This is part of the connector's auth module.
   211	
   212	**Standard 4-step flow:**
   213	1. Per-tenant Bullhorn admin (or IFOS-on-behalf-of-admin if marketplace path enables it) hits the authorise URL with `client_id`, `response_type=code`, `redirect_uri`, `state`, and per-Bullhorn-docs the `username` + `password` query parameters as well (Bullhorn-specific: their authorize endpoint accepts credentials inline rather than a separate consent screen).
   214	2. Bullhorn returns auth code to `redirect_uri`.
   215	3. IFOS POSTs to token endpoint with `client_id`, `client_secret`, `grant_type=authorization_code`, `code`, `redirect_uri` — receives `access_token` + `refresh_token`.
   216	4. IFOS POSTs to per-tenant REST `/login` with the `access_token` — receives `BhRestToken` + `restUrl` for that tenant.
   217	
   218	**Token TTLs (Bullhorn doc verbatim):**
   219	
   220	- **Access token: 10 minutes.** "The access token is valid for 10 minutes."

exec
/bin/zsh -lc 'rg -n "Timesheet|timesheet|endpoint|v1.0|Candidate|ClientCorporation|JobOrder|Note|Placement" docs/decisions/bullhorn-integration-path.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
29:**Bullhorn dependency count for v1.0 agents:**
31:| Agent | Bullhorn dependency in v1.0 | Source |
40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
51:- The endpoint surface area available via the public REST API at `https://rest.bullhornstaffing.com/rest-services/<corpToken>/` (the documented entry pattern).
55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
60:- Whether **marketplace-tier API access differs from direct-API access** in rate limits, available scopes (e.g. write to JobOrder, write to Note, webhook subscription), or sandbox availability. Bullhorn's public docs are sparse on the deltas; partner reps know the actuals.
61:- Whether the marketplace-tier cost structure works at IFOS's volume (3-6 tenants v1.0; 100 by end of 2027 per Product Spec §5.4 line 369-373). Partner fees may be flat or per-tenant; this matters at scale.
62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
66:| Sub-decision | Commercial gate question | Who answers | When | Notes |
69:| A | "What are the API rate-limit / scope deltas between marketplace tier and direct API at our expected 3-6 tenant pilot volume?" | Same Bullhorn partnerships team, or escalation to developer support | Same conversation | The answer determines whether direct-API can serve v1.0 or marketplace registration is a v1.0 blocker |
70:| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
81:  - Sub-decision C in full — technical analysis, per-agent endpoint table, webhook-vs-poll decisions, rate-limit budget allocation. **Status: Accepted** on Sub-decision C alone, no commercial gating.
83:  - Recommendation block (§5) names the technical preference, the commercial-answer conditions that flip Status to Accepted, and the documented v1.0-scope-cut contingency if commercial answers go badly.
95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
143:- `https://bullhorn.github.io/docs` — Bullhorn's developer documentation landing. Names three API surfaces: REST API, OAuth, SOAP (legacy). The REST and OAuth links are the operative ones for v1.0.
158:- `https://bullhorn.github.io/Getting-Started-with-REST` — auth flow specifics (endpoint URLs, token TTLs, refresh-token rotation, credential acquisition path).
171:| Scope / rate-limit deltas | **CG.** Marketplace tier may grant elevated rate limits, write access to additional entities (e.g. JobOrder write), webhook subscription endpoints not available to direct-tier. Public docs do not state. | Public REST API documentation lists all REST endpoints uniformly — no tier-gated endpoints stated in public docs. Inference: all entity reads/writes are available to authenticated direct-tier callers, subject to per-corpToken scope at the tenant-account-admin level. Rate limit ceiling **CG**. |
173:| **Switching cost later** (start direct, move to marketplace at v1.1+) | n/a (this is the destination) | **Low if the connector code treats auth as a swap-point per §1.4 fallback architecture.** The connector's REST endpoint calls (Sub-decision C surface) are identical between paths. The auth module — `packages/mcp-connectors/bullhorn/src/auth.ts` and the `_secrets.env` materialisation in the renderer — is the only differing surface. Bounded to ~200-400 lines of code per the design in `agent-bundle-renderer-design.md` §3.3.4. |
179:**Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes.**
184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
185:3. **Marketplace is a commercial decision, not a technical one, at v1.0 scale.** At 3-6 pilot tenants, the marketplace's primary benefit (co-marketing, listing visibility, possibly elevated rate limits) is dominated by the per-tenant pilot economics. The marketplace partnership is appropriate when IFOS has shippable product and 10+ tenants — i.e. v1.1+ commercial timing.
191:| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
192:| Marketplace adds material per-tenant cost above ~$1K/yr at 3-tenant scale (partnerships@bullhorn answer) AND direct-API scope is sufficient | Direct preferred for v1.0; marketplace deferred to v1.1+ when revenue funds the programme cost. Current recommendation stands. |
194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
196:**Status: Proposed.** Status flips to Accepted on either: (a) partnerships@bullhorn confirms marketplace is not required for v1.0 production tenant access AND first design partner uses Bullhorn; OR (b) founder explicitly accepts the documented fallback if marketplace turns out required, and re-cuts the v1.0 timeline to absorb the marketplace certification window.
210:The `{loginInfo}` placeholder is per-tenant-cluster — IFOS resolves it via the Bullhorn `loginInfo` lookup endpoint before kicking off OAuth. This is part of the connector's auth module.
213:1. Per-tenant Bullhorn admin (or IFOS-on-behalf-of-admin if marketplace path enables it) hits the authorise URL with `client_id`, `response_type=code`, `redirect_uri`, `state`, and per-Bullhorn-docs the `username` + `password` query parameters as well (Bullhorn-specific: their authorize endpoint accepts credentials inline rather than a separate consent screen).
215:3. IFOS POSTs to token endpoint with `client_id`, `client_secret`, `grant_type=authorization_code`, `code`, `redirect_uri` — receives `access_token` + `refresh_token`.
248:Pragmatic v1.0 hybrid given §3.1 and §3.2 findings:
275:## Section 4 — Sub-decision C: v1.0 endpoint surface
279:### 4.1 — Per-agent endpoint requirements
285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
300:**Implication:** Bullhorn's public-tier REST API is **pull-only**. IFOS must poll for change detection at v1.0 unless commercial verification reveals a partner-tier event-subscription mechanism. **Commercially gated: §4.2-A** — confirm with Bullhorn developer support whether webhook/event-subscription capabilities exist at marketplace/partner tier that are not documented in the public REST docs.
302:**v1.0 default per integration point:**
304:| Integration point | v1.0 mechanism | Cadence | Notes |
306:| Janitor Candidate sweep | Polling (full-table scan per sweep) | Nightly 02:00 | Initial sweep is bounded by per-tenant Candidate count; subsequent sweeps use `dateLastModified` filter to limit to changes-since-last-sweep |
307:| Janitor Note / ClientCorporation / JobOrder sweep | Polling | Nightly 02:00 | Same `dateLastModified` filter pattern |
308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
311:| Concierge time-based nurture cadence | Cron (week-1, month-1, month-3, month-6, month-12, month-24) | Per Placement-creation anchor date | No Bullhorn webhook needed — IFOS-side cron fires; IFOS reads Bullhorn for current state then writes the comm Note back |
330:**Conservative v1.0 budget allocation per tenant per hour** (anchored to typical enterprise REST API patterns of 100-500 req/min ceilings; revise once Bullhorn confirms):
334:| Janitor (nightly sweep) | 200-400 during active sweep window (concentrated 1-2 hour burst) | Burst-tolerant; bounded by tenant Candidate-count and `dateLastModified` filter efficiency |
346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
359:This is a real architectural decision worth its own §4 sub-section because the 10-min TTL forced the refresh-loop into the v1.0 design — it's not just an implementation detail.
369:Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes (per §2.4 + §1.4 fallback architecture).
392:**Sub-decision C — v1.0 endpoint surface. Status: Accepted.**
394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
419:Concierge's write capability to Bullhorn (Note auto-send, status updates per §4.1) interacts with Day 5's auto-send safety policy artefact. Day 5 should reference this document's §4.1 Concierge row for the specific entities Concierge will be writing — Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI.
423:Bullhorn entity field mapping (Candidate, JobOrder, Placement, Note, ClientCorporation) → IFOS wiki schema per `second-brain-design.md` §2.2 entity types. Out of scope for this Day-2 decision; flagged for Week 11-13 work. Concrete handoff: §4.1's per-agent read-entity list is the v1.0 minimum set the wiki ingest paths must handle.
460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
470:- **Webhook / event-subscription model** — deferred to v1.1+ pending Sub-decision A commercial verification (whether marketplace tier grants subscription endpoints not in public REST docs).
486:| Rate-limit budget allocation | §4.4 | Conservative v1.0 defaults (400-1000 req/hour/tenant total; 30% reserve); revise when Bullhorn confirms actuals |
511:| §4.2-A: assume v1.0 pull-only (no webhook coverage) per public REST docs | Sub-decision A commercial verification reveals marketplace-tier event subscriptions — Concierge upgrades to webhook-primary in v1.1+ |

codex
REJECTED

1. v0.3 expands v1.0 access to Bullhorn-sourced `opportunity` and `timesheet` outside the accepted endpoint surface. Lines 388-400 and 424-426 grant Scribe/Cash Conductor/Concierge access to `opportunity` and/or `timesheet`; `vertical-schema.yaml` maps those to Bullhorn JobSubmission/Opportunity and Timesheet, while `bullhorn-integration-path.md §4.1` v1.0 rows only cover Candidate, ClientCorporation, JobOrder, Note, and Placement. Fix by removing these v1.0 accesses or marking them explicit v1.1+/v2.0 deferrals with no v1.0 agent access.

2. Cash Conductor’s matrix contradicts its no-Bullhorn dependency. Lines 392-400 grant Cash Conductor R access to `client`, `contact`, `opportunity`, `placement`, and `timesheet`, but `bullhorn-integration-path.md §1.2` says A4 has “No direct Bullhorn” and v0.1 had all Bullhorn entity access as `none`. Fix by either reverting Cash Conductor entity access to `none` or explicitly documenting these as IFOS-cached Postgres reads that do not require Bullhorn endpoint access.

3. Free-form object fields are not JSON-Schema-compatible as written. Lines 610 and 648 declare `raw_payload` as `type: object` but do not define an object shape or explicitly mark it free-form, violating review-schema-change §3. Fix by adding an explicit nested shape or `free_form: true` / equivalent notes for both raw payload columns.

4. The migration precondition omits a v0.2 table that v0.3 grants access to. Lines 678-686 define `voice_corpus_chunks` access, but `migration_sequence.pre_conditions` at lines 814-818 names only `voice_corpus + tone_rule + recent_edit`, and the SQL prerequisite block checks only those three tables. Fix by adding `voice_corpus_chunks` to the supplement preconditions and the forward migration prerequisite DO block.
tokens used
97,710
REJECTED

1. v0.3 expands v1.0 access to Bullhorn-sourced `opportunity` and `timesheet` outside the accepted endpoint surface. Lines 388-400 and 424-426 grant Scribe/Cash Conductor/Concierge access to `opportunity` and/or `timesheet`; `vertical-schema.yaml` maps those to Bullhorn JobSubmission/Opportunity and Timesheet, while `bullhorn-integration-path.md §4.1` v1.0 rows only cover Candidate, ClientCorporation, JobOrder, Note, and Placement. Fix by removing these v1.0 accesses or marking them explicit v1.1+/v2.0 deferrals with no v1.0 agent access.

2. Cash Conductor’s matrix contradicts its no-Bullhorn dependency. Lines 392-400 grant Cash Conductor R access to `client`, `contact`, `opportunity`, `placement`, and `timesheet`, but `bullhorn-integration-path.md §1.2` says A4 has “No direct Bullhorn” and v0.1 had all Bullhorn entity access as `none`. Fix by either reverting Cash Conductor entity access to `none` or explicitly documenting these as IFOS-cached Postgres reads that do not require Bullhorn endpoint access.

3. Free-form object fields are not JSON-Schema-compatible as written. Lines 610 and 648 declare `raw_payload` as `type: object` but do not define an object shape or explicitly mark it free-form, violating review-schema-change §3. Fix by adding an explicit nested shape or `free_form: true` / equivalent notes for both raw payload columns.

4. The migration precondition omits a v0.2 table that v0.3 grants access to. Lines 678-686 define `voice_corpus_chunks` access, but `migration_sequence.pre_conditions` at lines 814-818 names only `voice_corpus + tone_rule + recent_edit`, and the SQL prerequisite block checks only those three tables. Fix by adding `voice_corpus_chunks` to the supplement preconditions and the forward migration prerequisite DO block.
