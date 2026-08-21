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
session id: 019e5a49-079b-7212-9b0c-e3cd8a4e7ce1
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
    opportunity: none
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
      matched_invoice_id: {type: string, required: false, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
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
  voice_corpus_chunks:
    # v0.2 auxiliary table holding the pgvector HNSW index over voice corpus chunks
    # All v1.0 agents that produce voice-classified output need R for ANN-match retrieval
    diagnostic: R
    janitor: R
    scribe: R
    cash_conductor: R
    sourcing_scout: R
    concierge: R

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
I’ll verify the supplement against the repository rather than relying only on the pasted text, focusing on the companion migrations and the cited baseline schema/decision docs.
exec
/bin/zsh -lc 'ls -l docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql && wc -l docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
-rw-r--r--@ 1 madsadmin  staff  19498 May 24 14:59 docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
-rw-r--r--@ 1 madsadmin  staff   4368 May 24 14:48 docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
     797 docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
     482 docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
     101 docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
    1380 total

exec
/bin/zsh -lc 'rg -n "''^entities:|''^agent_access_matrix:|candidate:|contractor:|client:|contact:|brief:|opportunity:|placement:|timesheet:|bullhorn_mapping:|relationships:|voice_corpus|tone_rule|recent_edit|Diagnostic|Janitor|Scribe|Cash Conductor|Sourcing Scout|Concierge" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:45:entities:
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
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
docs/verticals/recruitment/vertical-schema.yaml:153:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:161:      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
docs/verticals/recruitment/vertical-schema.yaml:170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
docs/verticals/recruitment/vertical-schema.yaml:191:        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
docs/verticals/recruitment/vertical-schema.yaml:196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
docs/verticals/recruitment/vertical-schema.yaml:205:        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
docs/verticals/recruitment/vertical-schema.yaml:214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
docs/verticals/recruitment/vertical-schema.yaml:217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
docs/verticals/recruitment/vertical-schema.yaml:221:  client:
docs/verticals/recruitment/vertical-schema.yaml:226:      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:228:      - Concierge (R — relationship context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:261:        source: IFOS-derived (Janitor maintains)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
docs/verticals/recruitment/vertical-schema.yaml:283:  contact:
docs/verticals/recruitment/vertical-schema.yaml:288:      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
docs/verticals/recruitment/vertical-schema.yaml:321:        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
docs/verticals/recruitment/vertical-schema.yaml:331:      do_not_contact:
docs/verticals/recruitment/vertical-schema.yaml:334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
docs/verticals/recruitment/vertical-schema.yaml:341:  brief:
docs/verticals/recruitment/vertical-schema.yaml:347:      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:350:      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:410:        source: IFOS-derived (Concierge maintains based on client check-in cadence)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:436:      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:471:      candidate_salary_at_placement:
docs/verticals/recruitment/vertical-schema.yaml:480:        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
docs/verticals/recruitment/vertical-schema.yaml:481:        notes: Drives Concierge nurture-event firing.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:495:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:535:  timesheet:
docs/verticals/recruitment/vertical-schema.yaml:557:      approved_by_client:
docs/verticals/recruitment/vertical-schema.yaml:561:      approved_by_contractor:
docs/verticals/recruitment/vertical-schema.yaml:583:relationships:
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:594:  placement_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
docs/verticals/recruitment/vertical-schema.yaml:601:  brief_from_client:
docs/verticals/recruitment/vertical-schema.yaml:615:    v1_0_exercise: Concierge reads for addressee-resolution per bullhorn §4.1 A6 Voice gate; addressee = primary decision-maker contact.
docs/verticals/recruitment/vertical-schema.yaml:618:  contact_works_for_client:
docs/verticals/recruitment/vertical-schema.yaml:623:    v1_0_exercise: Concierge addressee context.
docs/verticals/recruitment/vertical-schema.yaml:625:  candidate_engaged_with_contact:
docs/verticals/recruitment/vertical-schema.yaml:630:    v1_0_exercise: Concierge reads for outbound-message addressee correctness; thin in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:632:  candidate_referred_by_contact:
docs/verticals/recruitment/vertical-schema.yaml:637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:639:  opportunity_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:654:  timesheet_for_placement:
docs/verticals/recruitment/vertical-schema.yaml:669:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:671:  Diagnostic:
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:673:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:675:    contact: none
docs/verticals/recruitment/vertical-schema.yaml:676:    brief: none
docs/verticals/recruitment/vertical-schema.yaml:677:    placement: none
docs/verticals/recruitment/vertical-schema.yaml:678:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:679:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:682:  Janitor:
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:684:    contractor: R+W  # status normalisation
docs/verticals/recruitment/vertical-schema.yaml:685:    client: R+W      # orphan-link sweep + normalisation
docs/verticals/recruitment/vertical-schema.yaml:686:    contact: R       # read-only (Concierge owns writes)
docs/verticals/recruitment/vertical-schema.yaml:687:    brief: R         # status drift sweep
docs/verticals/recruitment/vertical-schema.yaml:688:    placement: R     # orphan / stale-tag sweep
docs/verticals/recruitment/vertical-schema.yaml:689:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:690:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:692:  Scribe:
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
docs/verticals/recruitment/vertical-schema.yaml:722:  Concierge:
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:724:    contractor: R+W  # lifecycle state, contractor-specific cadence
docs/verticals/recruitment/vertical-schema.yaml:725:    client: R        # relationship context
docs/verticals/recruitment/vertical-schema.yaml:726:    contact: R       # decision-maker resolution for orange-tier sends
docs/verticals/recruitment/vertical-schema.yaml:727:    brief: R         # linked-brief context
docs/verticals/recruitment/vertical-schema.yaml:728:    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
docs/verticals/recruitment/vertical-schema.yaml:729:    opportunity: none
docs/verticals/recruitment/vertical-schema.yaml:730:    timesheet: none
docs/verticals/recruitment/vertical-schema.yaml:736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:739:bullhorn_mapping:
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:754:  client:
docs/verticals/recruitment/vertical-schema.yaml:757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:760:  contact:
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:765:  brief:
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:775:    notes: lifecycle_stage is IFOS-derived (Concierge maintains); Bullhorn does not natively store IFOS's nurture-cadence stages.
docs/verticals/recruitment/vertical-schema.yaml:777:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:783:  timesheet:
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
docs/verticals/recruitment/vertical-schema.yaml:844:  Q9_multi_client_contact:
docs/verticals/recruitment/vertical-schema.yaml:856:    rationale: v1.0 Concierge addressee-resolution uses primary-decision-maker; panel modelling adds value when v1.1 Triage handles inbound brief queries from multiple stakeholders.
docs/verticals/recruitment/vertical-schema.yaml:862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:890:    expected_date: post Week 3-4 (after Janitor build verifies against real Bullhorn data)
docs/verticals/recruitment/vertical-schema.yaml:892:      Codex-ratified version. Field sets expanded per Janitor's real-Bullhorn-data findings (Q3 trigger). Possibly Note entity promoted to entity_type if Janitor surfaces query patterns (Q2 trigger). 2-3 revisions expected from v0.1.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:53:entities:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:61:      - Scribe (R — voice samples for note-summary tone matching)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:62:      - Concierge (R — voice samples for outbound message generation)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:128:      - Scribe (R — note format constraints)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:129:      - Cash Conductor (R — payment reminder tone)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:130:      - Concierge (R — every outbound message)
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:303:  contact:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:309:        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:311:  brief:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:317:        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:319:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:339:additional_relationships:
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:401:    trigger_for_revisit: first Concierge build (W10) — measure real retry success rate
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:441:    expected_date: post-Concierge build (W10-13) — first agent to heavily exercise voice corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.

exec
/bin/zsh -lc 'rg -n "''^#|voice_classifier_score|match_confidence|CREATE TABLE cash_conductor|validate_entities_data_v0_3|validate_tenant_adapters_config_v0_3|GRANT|CHECK|recent_edit|voice_corpus|tone_rule" docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:49:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:50:DROP FUNCTION IF EXISTS validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:20:--     payload key and its enforcement (CHECK constraint or trigger).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:26:--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:43:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:44:    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:46:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:47:    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:49:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:50:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:71:  match_confidence   NUMERIC(3, 2),
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:76:  CONSTRAINT cct_match_status_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:79:  CONSTRAINT cct_bank_provider_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:82:  CONSTRAINT cct_match_confidence_range CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:83:    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:103:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:104:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:129:  CONSTRAINT cci_status_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:132:  CONSTRAINT cci_provider_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:135:  CONSTRAINT cci_chase_position_range CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:138:  CONSTRAINT cci_amount_paid_non_negative CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:162:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:163:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:174:CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:182:  IF d ? 'voice_classifier_score' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:183:    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:184:      RAISE EXCEPTION 'voice_classifier_score must be number or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:186:    IF d->'voice_classifier_score' != 'null'::jsonb THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:187:      IF (d->>'voice_classifier_score')::numeric < 0.0
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:188:         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:189:        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:364:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:366:CREATE TRIGGER validate_entities_data_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:369:  EXECUTE FUNCTION validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:379:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:447:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:452:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();

codex
The companion SQL files exist, and the forward migration includes the expected v0.3 validators and auxiliary tables. I’m now checking whether the supplement’s cumulative matrix and auxiliary-table claims stay consistent with the type-specific schema rules.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '520,820p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   520	
   521	auxiliary_table_access_matrix:
   522	  cash_conductor_transactions:
   523	    diagnostic: none
   524	    janitor: none
   525	    scribe: none
   526	    cash_conductor: R+W
   527	    sourcing_scout: none
   528	    concierge: none
   529	  cash_conductor_invoices:
   530	    diagnostic: none
   531	    janitor: none
   532	    scribe: none
   533	    cash_conductor: R+W
   534	    sourcing_scout: none
   535	    concierge: none
   536	  voice_corpus_chunks:
   537	    # v0.2 auxiliary table holding the pgvector HNSW index over voice corpus chunks
   538	    # All v1.0 agents that produce voice-classified output need R for ANN-match retrieval
   539	    diagnostic: R
   540	    janitor: R
   541	    scribe: R
   542	    cash_conductor: R
   543	    sourcing_scout: R
   544	    concierge: R
   545	
   546	# ============================================================================
   547	# §4 — tenant_adapters.config new keys (4 keys)
   548	# ============================================================================
   549	#
   550	# tenant_adapters.config is JSONB; validation via
   551	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   552	# on unknown keys per Rule 2.
   553	
   554	tenant_adapters_config_additions:
   555	
   556	  cash_conductor_last_run:
   557	    type: timestamp
   558	    required: false
   559	    set_by: cash_conductor
   560	    read_by: [cash_conductor]
   561	    notes: |
   562	      Cash Conductor cron sweep updates at session-close. Next run queries
   563	      transactions/invoices since this timestamp.
   564	
   565	  concierge_last_poll:
   566	    type: timestamp
   567	    required: false
   568	    set_by: concierge
   569	    read_by: [concierge]
   570	    notes: |
   571	      Concierge polling cron updates at end of each cycle. Next poll queries
   572	      Bullhorn for state transitions since this timestamp.
   573	
   574	  concierge_send_window:
   575	    type: object
   576	    required: false
   577	    default:
   578	      timezone: Europe/London
   579	      weekday_start: '09:00'
   580	      weekday_end: '17:00'
   581	      weekend_send_enabled: false
   582	    set_by: [tenant-admin]
   583	    read_by: [concierge]
   584	    object_shape:
   585	      timezone:
   586	        type: string
   587	        notes: IANA timezone identifier
   588	      weekday_start:
   589	        type: string
   590	        notes: HH:MM 24-hour format
   591	      weekday_end:
   592	        type: string
   593	        notes: HH:MM 24-hour format
   594	      weekend_send_enabled:
   595	        type: boolean
   596	    notes: |
   597	      Per-tenant outbound sending hours. Concierge respects when scheduling
   598	      orange-tier sends.
   599	
   600	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   601	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
   602	  # declare this config key; the W4 ADR will introduce both the field
   603	  # and its consumer at the same time. Including it in v0.3 without an
   604	  # active consumer would be speculative schema.
   605	
   606	# ============================================================================
   607	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   608	# ============================================================================
   609	
   610	decision_log_payload_extension:
   611	  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
   612	  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
   613	  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
   614	  # that ships alongside Tier 2 activation. v0.3 introducing the payload
   615	  # key without enforcement would violate review-schema-change §3
   616	  # (bounded values require CHECK or trigger). Tier 2 schema work owns
   617	  # the constraint + writer; this v0.3 supplement is silent on it.
   618	  deferred_to_future_adr:
   619	    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
   620	    schema_owner: future W4-polish supplement (not v0.3)
   621	    rationale: |
   622	      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
   623	      separate post-launch quality metric outside Gate A. The payload key,
   624	      its [0.0, 1.0] range validation, and the sample-rate config field
   625	      all land together with Tier 2 activation. Tier 2 doesn't activate
   626	      until the voice classifier microservice ships + first pilot tenant
   627	      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
   628	      payload shape to avoid declaring schema without enforcement.
   629	
   630	# ============================================================================
   631	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   632	# ============================================================================
   633	
   634	migration_sequence:
   635	  forward: migrations/v0.2-to-v0.3.sql
   636	  rollback: migrations/v0.3-to-v0.2.sql
   637	
   638	  pre_conditions:
   639	    - v0.2 migration applied (voice_corpus + tone_rule + recent_edit tables exist)
   640	    - validate_voice_scores trigger active on entities table
   641	    - RLS + ifos_app grants from Day-4 §6.3 in place
   642	    - migration-test tenant row exists in tenants table
   643	
   644	  steps:
   645	    1: |
   646	      Verify v0.2 prerequisites (DO block in migration §1).
   647	    2: |
   648	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   649	      ifos_app grants + 2 indexes (migration §2).
   650	    3: |
   651	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   652	      (migration §3).
   653	    4: |
   654	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   655	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   656	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   657	      candidate / contact / brief / placement / opportunity entity_types.
   658	      Re-attaches the trigger to entities table (migration §4).
   659	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   660	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   661	    5: |
   662	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   663	      hard-fails on unknown config keys (Rule 2); type-validates the 4 new
   664	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   665	    6: |
   666	      Smoke verification DO block confirms both cash_conductor_*
   667	      tables exist (migration §6).
   668	    7: |
   669	      COMMIT; or ROLLBACK on any error.
   670	
   671	  post_migration_steps:
   672	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   673	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   674	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   675	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   676	       Cat-β findings closed
   677	
   678	# ============================================================================
   679	# §7 — Codex ratification path
   680	# ============================================================================
   681	
   682	codex_ratification:
   683	  skill: review-schema-change
   684	  expected_round_trips: 1-2 (mechanical fixes only)
   685	  manifest_queue_position: 44 (after v0.2 supplement at 29)
   686	
   687	# ============================================================================
   688	# §8 — Open questions (structured per review-schema-change §8)
   689	# ============================================================================
   690	
   691	open_questions:
   692	
   693	  Q1_employment_type_enum_completeness:
   694	    question: Are 6 employment_type enum values sufficient for UK recruitment?
   695	    options:
   696	      A: |
   697	        Keep 6 values as in §1.candidate.employment_type — perm, contract,
   698	        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
   699	      B: |
   700	        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
   701	      C: |
   702	        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
   703	        (array of allowed strings); validate at write time against tenant's list.
   704	    v0_3_default: A
   705	    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
   706	      outside A, escalate to B or C.
   707	
   708	  Q2_key_skills_max_length:
   709	    question: Cap at 20 items per candidate adequate?
   710	    options:
   711	      A: Keep cap at 20 (validator hard-fails over).
   712	      B: Increase to 50 (handles senior technical candidates with deep stacks).
   713	      C: Remove cap entirely (rely on application-layer pruning).
   714	    v0_3_default: A
   715	    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
   716	      of candidates hit the 20-item cap, escalate to B.
   717	
   718	  Q3_placement_status_enum_lifecycle:
   719	    question: 6-state placement_status enum maps to Bullhorn's native state machine?
   720	    options:
   721	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   722	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   723	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   724	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   725	    v0_3_default: A
   726	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   727	      escalate to B or C if 1:1 mapping breaks.
   728	
   729	  Q4_cash_conductor_transactions_retention:
   730	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   731	      What's the production retention policy?
   732	    options:
   733	      A: 7-year retention with automated pseudonymization at year 7 (hash
   734	         payee_name_raw + description; preserve amount + dates for audit).
   735	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   736	         rows retained beyond 7 years for cross-period reconciliation).
   737	      C: Per-tenant retention override in tenant_adapters.config.
   738	    v0_3_default: A
   739	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   740	      tenant requires shorter retention, escalate to C with tenant-specific
   741	      override. Pseudonymization implementation lands in W4-polish slice.
   742	    production_use_gating: |
   743	      Until pseudonymization implementation lands, production use of
   744	      cash_conductor_transactions table is GATED by an explicit per-tenant
   745	      DPA addendum signed by founder + tenant. Migration-test tenant data
   746	      is not subject to this gate.
   747	
   748	  Q5_unknown_config_keys_handling:
   749	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   750	    options:
   751	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   752	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   753	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   754	    v0_3_default: A
   755	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   756	      for forward-compat, escalate to B or C with explicit ADR.
   757	
   758	# ============================================================================
   759	# §9 — Why v0.3 is the right unblock
   760	# ============================================================================
   761	
   762	rationale: |
   763	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   764	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   765	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   766	  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys. The
   767	  per_claim_confidence_distribution payload key originally planned for
   768	  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
   769	  §5 of this supplement); v0.3 is silent on payload schema extensions.
   770	
   771	  After v0.3 ratifies + migration applies:
   772	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   773	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   774	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   775	      placement_status, week_1_status_vault_path, satisfaction_signal,
   776	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   777	      are now schema-backed. (Note: week_1_status_note narrative now lives
   778	      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
   779	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   780	      seniority — not yet in schema; brief.start_date should be
   781	      start_date_target; opportunity.sector — not yet in schema). These
   782	      residual gaps are tracked in W4-polish-schema-extension backlog;
   783	      they do not block v0.3 ratification but do require a Scribe agent.md
   784	      consistency-pass before Scribe ratifies.
   785	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   786	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   787	    - Concierge tenant_adapters.config field refs valid
   788	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   789	
   790	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   791	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   792	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   793	  not schema gaps.
   794	
   795	# ============================================================================
   796	
   797	end_of_supplement: true

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
   176	      week_1_status_vault_path:
   177	        type: string
   178	        max_length: 200
   179	        pattern: '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$'
   180	        required: false
   181	        notes: |
   182	          POINTER ONLY (per ADR-002 vault/Postgres split). The 7d check-in
   183	          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
   184	          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
   185	          Pattern accepts call_ids + ISO dates (hyphens + underscores +
   186	          alphanumerics). This field stores the vault path; narrative does
   187	          NOT enter Postgres. Voice-classifier review at write time applies
   188	          to the vault file content; Concierge reads the vault file directly
   189	          via its path resolution.
   190	        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
   191	          to vault then stores pointer here)
   192	        v1_0_agent_access:
   193	          - Scribe: R+W
   194	          - Concierge: R
   195	
   196	      satisfaction_signal:
   197	        type: string
   198	        enum: [positive, neutral, negative, unclear]
   199	        default: unclear
   200	        required: false
   201	        notes: |
   202	          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
   203	          Concierge reads to adjust nurture tone.
   204	        source: IFOS-derived (Scribe LLM extraction)
   205	        v1_0_agent_access:
   206	          - Scribe: R+W
   207	          - Concierge: R
   208	
   209	  opportunity:
   210	    v0_3_new_keys:
   211	      headcount_growth_signal_text:
   212	        type: string
   213	        max_length: 280
   214	        required: false
   215	        notes: |
   216	          Free-text capture of growth-signal phrases from prospecting calls
   217	          ("we're hiring 5 engineers this quarter"). Sourcing Scout reads
   218	          to ICP-fit-score opportunities.
   219	        source: IFOS-derived (Scribe extraction)
   220	        v1_0_agent_access:

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '220,520p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   220	        v1_0_agent_access:
   221	          - Scribe: R+W
   222	          - Sourcing Scout: R
   223	
   224	      hiring_velocity_band:
   225	        type: string
   226	        enum: [slow, moderate, fast, urgent, unknown]
   227	        default: unknown
   228	        required: false
   229	        notes: |
   230	          Scribe LLM inference from prospecting-call urgency cues. Drives
   231	          ranking in Sourcing Scout's brief-to-candidate pipeline.
   232	        source: IFOS-derived (Scribe LLM classification)
   233	        v1_0_agent_access:
   234	          - Scribe: R+W
   235	          - Sourcing Scout: R
   236	
   237	      decision_window_text:
   238	        type: string
   239	        max_length: 280
   240	        required: false
   241	        notes: |
   242	          Free-text capture of decision-timing phrases. Concierge reads to
   243	          time outbound comms.
   244	        source: IFOS-derived (Scribe extraction)
   245	        v1_0_agent_access:
   246	          - Scribe: R+W
   247	          - Concierge: R
   248	
   249	# ============================================================================
   250	# §2 — Complete v0.3 agent access matrix
   251	# ============================================================================
   252	#
   253	# Per review-schema-change skill §5: full matrix across all v1.0 agents
   254	# and all v0.1 + v0.2 entities. v0.3 is a CUMULATIVE matrix that includes
   255	# v0.1 + v0.2 + v0.3 dispositions. Where this matrix differs from
   256	# vertical-schema.yaml v0.1 §3, the cell is an EXPLICIT v0.3 amendment
   257	# with a marker comment in-line. Full list of v0.3 amendments:
   258	#
   259	# Cells changed from v0.1 baseline:
   260	#   - Diagnostic client: none → R (reads Companies House data via cached
   261	#     client entity; sales-tool source-of-truth context — v0.3 amendment)
   262	#   - Diagnostic contact: none → R (reads §11 decision-maker map context)
   263	#   - Diagnostic opportunity: none → R (reads prospect-firm opportunity if exists)
   264	#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
   265	#     pattern as candidate/contractor — v0.3 amendment)
   266	#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
   267	#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
   268	#     v0.3 amendment)
   269	#   - Janitor timesheet: none → R (reads for placement-state inference)
   270	#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
   271	#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
   272	#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
   273	#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
   274	#     R-only for Scribe)
   275	#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
   276	#   - Scribe timesheet: none → R (reads for placement-context resolution
   277	#     on check-in calls)
   278	#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
   279	#     — v0.3 amendment)
   280	#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
   281	#   - Cash Conductor timesheet: none → R (reads to verify billable hours
   282	#     match invoiced amounts)
   283	#   - Sourcing Scout candidate: R → R+W (writes proposed-candidate rows
   284	#     from multi-source aggregation — v0.3 amendment)
   285	#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
   286	#   - Sourcing Scout opportunity: none → R (reads opportunity context for ICP)
   287	#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
   288	#     activity-log links per concierge §4 Step 13-14 — v0.3 amendment)
   289	#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
   290	#   - Concierge opportunity: none → R (reads for outbound lifecycle-event context)
   291	#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
   292	#     concierge §4 Step 14 — v0.3 amendment)
   293	#   - Concierge timesheet: none → R (reads to verify placement-progress for
   294	#     7d/30d/90d nurture)
   295	#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
   296	#     extended)
   297	#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
   298	#     — v0.2 extended)
   299	#
   300	# All other access levels carry forward unchanged from v0.1 + v0.2.
   301	
   302	agent_access_matrix:
   303	
   304	  # Disposition tokens: R | W | R+W | none
   305	  #
   306	  # ENTITY-LEVEL vs FIELD-LEVEL ACCESS:
   307	  # The matrix below is ENTITY-LEVEL — declares the maximum disposition an
   308	  # agent may have on any field of that entity. Per-field access (in §1
   309	  # entity_field_additions[*].v1_0_agent_access) NARROWS the entity-level
   310	  # disposition. Example: Scribe.candidate: R+W at entity level; per-field
   311	  # candidate.employment_type grants Scribe: W (because Scribe doesn't read
   312	  # employment_type, just writes it). This is intentional — the entity-level
   313	  # token is the ceiling; field-level may be narrower but never broader.
   314	  #
   315	  # Validation: the validate_entities_data_v0_3 trigger validates FIELD
   316	  # SHAPE only (type checks, enum membership, length caps, array element
   317	  # types). It does NOT enforce which agent is writing — agent-level
   318	  # write permission is DOCUMENTARY in v0.3, enforced at the application
   319	  # layer (cycle.sh + hh_decision_action) where the agent_name in the
   320	  # decision_log row records who wrote. Entity-level RLS enforces TENANT
   321	  # isolation but not agent-level access. Column-level RLS or per-agent
   322	  # database roles would be the v1.1+ enforcement layer; v0.3 is documentary.
   323	
   324	  diagnostic:
   325	    candidate: R           # reads for outreach context (§11 decision-maker map)
   326	    contractor: none       # not in scope at v1.0
   327	    client: R              # reads via Companies House lookup (entity-shape if cached)
   328	    contact: R             # reads for §11 decision-maker map
   329	    brief: none            # diagnostic is sales-tool not brief-driven
   330	    opportunity: R         # may read prospect-firm opportunity if exists
   331	    placement: none
   332	    timesheet: none
   333	
   334	  janitor:
   335	    candidate: R+W         # dedup + field-backfill writes
   336	    contractor: R+W        # dedup + field-backfill writes
   337	    client: R+W            # Companies House enrichment writes
   338	    contact: R+W           # dedup + field-backfill writes
   339	    brief: R               # context for related candidate cleanup
   340	    opportunity: R
   341	    placement: R+W         # lifecycle-state cleanup
   342	    timesheet: R           # reads for placement-state inference
   343	
   344	  scribe:
   345	    candidate: R+W         # call-summary field extraction
   346	    contractor: R+W        # call-summary field extraction
   347	    client: R
   348	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
   349	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
   350	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
   351	    placement: R+W         # check-in field extraction
   352	    timesheet: R           # reads for placement-context resolution on check-in calls
   353	
   354	  cash_conductor:
   355	    candidate: none        # no Bullhorn dependency
   356	    contractor: none
   357	    client: R              # reads client billing details
   358	    contact: R             # reads for invoice addressee resolution
   359	    brief: none
   360	    opportunity: none
   361	    placement: R           # reads for client linkage on invoice
   362	    timesheet: R           # reads to verify billable hours match invoiced amounts
   363	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   364	
   365	  sourcing_scout:
   366	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   367	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   368	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   369	    # writes its proposed-candidate rows + reads opportunity context. These
   370	    # are entity-level access overrides codified here.
   371	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   372	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   373	    client: R
   374	    contact: R
   375	    brief: R               # reads to filter candidates
   376	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   377	    placement: none
   378	    timesheet: none
   379	
   380	  concierge:
   381	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   382	    contractor: R+W        # writes lifecycle states for contractor placements too
   383	    client: R
   384	    contact: R             # reads for outbound recipient resolution
   385	    brief: R
   386	    opportunity: R
   387	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   388	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   389	
   390	# ============================================================================
   391	# §2a — v0.2 entity v1_0_agent_access amendments
   392	# ============================================================================
   393	#
   394	# Per review-schema-change §5: matrix changes must be reflected in entity-level
   395	# v1_0_agent_access lists. v0.3 amends these v0.2 entities:
   396	
   397	v0_2_entity_access_amendments:
   398	
   399	  voice_corpus:
   400	    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
   401	    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
   402	    rationale: |
   403	      All v1.0 agents that produce voice-classified output (Diagnostic for
   404	      §12 conversation opener; Janitor for tacit-note narratives; Cash
   405	      Conductor for chase drafts; Sourcing Scout for per-candidate
   406	      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
   407	      granted Scribe + Concierge; v0.3 extends to all 6.
   408	
   409	  tone_rule:
   410	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
   411	    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
   412	    rationale: |
   413	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   414	      applies_to_agents containing 'janitor' for tacit-note narrative
   415	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   416	      Diagnostic + Sourcing Scout also read tone_rules for their
   417	      voice-classified outputs (§12 opener, per-candidate rationale).
   418	
   419	  recent_edit:
   420	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   421	    v0_3_v1_0_agent_access:
   422	      - voice-drift-canary (W)  # v0.2 unchanged
   423	      - Concierge (R)            # v0.2 unchanged
   424	      - LoRA (R)                 # v0.2 unchanged
   425	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   426	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   427	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   428	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   429	    rationale: |
   430	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   431	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   432	      for retraining queue). Janitor adds R for tacit-note harvest per
   433	      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
   434	      supplement is the authoritative source for the expanded access list.
   435	
   436	# ============================================================================
   437	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   438	# ============================================================================
   439	
   440	auxiliary_tables:
   441	
   442	  cash_conductor_transactions:
   443	    rationale: |
   444	      Open Banking transactions are high-volume + time-series + don't model
   445	      as entity.data JSONB. v0.3 introduces a first-class table with
   446	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   447	      §4 Step 3 + ADR-002 vault/Postgres split.
   448	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   449	    columns:
   450	      id: {type: integer, required: true, notes: BIGSERIAL primary key in SQL}
   451	      tenant_slug: {type: string, required: true, notes: RLS isolation key per Day-4 §6.3}
   452	      transaction_id: {type: string, required: true, notes: Provider-supplied (TrueLayer / Plaid)}
   453	      posted_at: {type: timestamp, required: true}
   454	      amount: {type: number, required: true, notes: NUMERIC(15,2) GBP; negative for outgoing}
   455	      currency: {type: string, required: true, default: GBP}
   456	      payee_name_raw: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   457	      description: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   458	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct]}
   459	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched}
   460	      matched_invoice_id: {type: string, required: false, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   461	      match_confidence: {type: number, required: false, notes: "range [0.00, 1.00]"}
   462	      match_dimensions: {type: array, items: {type: string}, required: false}
   463	      ingested_at: {type: timestamp, required: true, default: now()}
   464	      raw_payload: {type: object, required: false, pii: true, notes: Full Open Banking response; pseudonymized at year 7}
   465	    indexes:
   466	      - "(tenant_slug, posted_at DESC)"
   467	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   468	    retention: |
   469	      INTENT (W4-polish enforcement required): 7-year retention with
   470	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   471	      description, raw_payload). Aligned with Q4 v0_3_default. The
   472	      v0.2-to-v0.3 migration creates the table + indexes only; the
   473	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   474	      job or external scheduled job; not yet authored).
   475	    enforcement_gate: |
   476	      Production use of this table GATED until pseudonymization + purge
   477	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   478	      by founder + tenant before go-live; migration-test tenant exempt.
   479	
   480	  cash_conductor_invoices:
   481	    rationale: |
   482	      Open invoice register cached from accounting provider. Same auxiliary-
   483	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   484	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   485	    columns:
   486	      id: {type: integer, required: true}
   487	      tenant_slug: {type: string, required: true}
   488	      invoice_id: {type: string, required: true}
   489	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage]}
   490	      invoice_number: {type: string, required: false}
   491	      issued_at: {type: timestamp, required: true}
   492	      due_at: {type: timestamp, required: true}
   493	      amount_total: {type: number, required: true, notes: NUMERIC(15,2) GBP}
   494	      amount_paid: {type: number, required: true, default: 0}
   495	      currency: {type: string, required: true, default: GBP}
   496	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open}
   497	      client_contact_id: {type: string, required: false, notes: Links to Bullhorn placement.client_contact_id}
   498	      client_billing_email: {type: string, required: false, pii: true}
   499	      last_chase_position: {type: integer, required: true, default: 0, notes: 0-4 per Cash Conductor §3.2}
   500	      last_chase_sent_at: {type: timestamp, required: false}
   501	      ingested_at: {type: timestamp, required: true, default: now()}
   502	      raw_payload: {type: object, required: false, pii: true}
   503	    indexes:
   504	      - "(tenant_slug, due_at)"
   505	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   506	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   507	    retention: |
   508	      INTENT (W4-polish enforcement required): 7-year retention with
   509	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   510	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   511	      pseudonymization + purge implementation is a W4-polish slice
   512	      (pg_cron job or external scheduled job; not yet authored).
   513	    enforcement_gate: |
   514	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   515	      W4 polish, production use of cash_conductor_invoices is GATED by
   516	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   517	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   518	      data is exempt; pilot tenants require the DPA addendum signed before
   519	      go-live.
   520	

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '174,372p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '56,170p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   256	    END IF;
   257	  END IF;
   258	
   259	  -- v0.3 brief fields
   260	  IF et = 'brief' THEN
   261	    IF d ? 'must_haves' THEN
   262	      IF jsonb_typeof(d->'must_haves') != 'array' THEN
   263	        RAISE EXCEPTION 'must_haves must be array';
   264	      END IF;
   265	      IF jsonb_array_length(d->'must_haves') > 15 THEN
   266	        RAISE EXCEPTION 'must_haves max length 15';
   267	      END IF;
   268	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
   269	        IF jsonb_typeof(arr_item) != 'string' THEN
   270	          RAISE EXCEPTION 'must_haves items must be strings';
   271	        END IF;
   272	      END LOOP;
   273	    END IF;
   274	
   275	    IF d ? 'nice_to_haves' THEN
   276	      IF jsonb_typeof(d->'nice_to_haves') != 'array' THEN
   277	        RAISE EXCEPTION 'nice_to_haves must be array';
   278	      END IF;
   279	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'nice_to_haves') LOOP
   280	        IF jsonb_typeof(arr_item) != 'string' THEN
   281	          RAISE EXCEPTION 'nice_to_haves items must be strings';
   282	        END IF;
   283	      END LOOP;
   284	    END IF;
   285	
   286	    IF d ? 'deal_breakers' THEN
   287	      IF jsonb_typeof(d->'deal_breakers') != 'array' THEN
   288	        RAISE EXCEPTION 'deal_breakers must be array';
   289	      END IF;
   290	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
   291	        IF jsonb_typeof(arr_item) != 'string' THEN
   292	          RAISE EXCEPTION 'deal_breakers items must be strings';
   293	        END IF;
   294	      END LOOP;
   295	    END IF;
   296	  END IF;
   297	
   298	  -- v0.3 placement fields
   299	  IF et = 'placement' THEN
   300	    IF d ? 'placement_status' THEN
   301	      IF (d->>'placement_status') NOT IN (
   302	        'pending_start', 'active', 'completed', 'terminated_early', 'on_hold', 'cancelled'
   303	      ) THEN
   304	        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
   305	      END IF;
   306	    END IF;
   307	
   308	    IF d ? 'week_1_status_vault_path' THEN
   309	      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
   310	        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
   311	      END IF;
   312	      IF d->>'week_1_status_vault_path' IS NOT NULL
   313	         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$' THEN
   314	        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
   315	      END IF;
   316	      IF d->>'week_1_status_vault_path' IS NOT NULL
   317	         AND length(d->>'week_1_status_vault_path') > 200 THEN
   318	        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
   319	      END IF;
   320	    END IF;
   321	
   322	    IF d ? 'satisfaction_signal' THEN
   323	      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
   324	        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
   325	      END IF;
   326	    END IF;
   327	  END IF;
   328	
   329	  -- v0.3 opportunity fields
   330	  IF et = 'opportunity' THEN
   331	    IF d ? 'headcount_growth_signal_text' THEN
   332	      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
   333	        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
   334	      END IF;
   335	      IF d->>'headcount_growth_signal_text' IS NOT NULL
   336	         AND length(d->>'headcount_growth_signal_text') > 280 THEN
   337	        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
   338	      END IF;
   339	    END IF;
   340	
   341	    IF d ? 'hiring_velocity_band' THEN
   342	      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
   343	        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
   344	      END IF;
   345	    END IF;
   346	
   347	    IF d ? 'decision_window_text' THEN
   348	      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
   349	        RAISE EXCEPTION 'decision_window_text must be string or null';
   350	      END IF;
   351	      IF d->>'decision_window_text' IS NOT NULL
   352	         AND length(d->>'decision_window_text') > 280 THEN
   353	        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
   354	      END IF;
   355	    END IF;
   356	  END IF;
   357	
   358	  RETURN NEW;
   359	END;
   360	$$ LANGUAGE plpgsql;
   361	
   362	-- Rebind the trigger to the new function (drops + recreates)
   363	DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
   364	DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
   365	
   366	CREATE TRIGGER validate_entities_data_v0_3
   367	  BEFORE INSERT OR UPDATE ON entities
   368	  FOR EACH ROW
   369	  EXECUTE FUNCTION validate_entities_data_v0_3();
   370	
   371	-- ----------------------------------------------------------------------------
   372	-- §5 — tenant_adapters.config validation trigger (new keys)

 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '379,456p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   379	CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
   380	RETURNS TRIGGER AS $$
   381	DECLARE
   382	  c JSONB := NEW.config;
   383	  k TEXT;
   384	  allowed_keys TEXT[] := ARRAY[
   385	    -- v0.1 + v0.2 keys (forwarded; do not remove)
   386	    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
   387	    'janitor_last_run',
   388	    'pii_retention_days',  -- v0.2 PII purge runbook key
   389	    -- autosend-safety-policy.md keys
   390	    'approval_routing', 'approval_timeouts', 'sampling_rates',
   391	    -- v0.3 additions
   392	    'cash_conductor_last_run',
   393	    'concierge_last_poll',
   394	    'concierge_send_window'
   395	    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   396	    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
   397	  ];
   398	BEGIN
   399	  IF c IS NULL THEN
   400	    RETURN NEW;
   401	  END IF;
   402	
   403	  FOR k IN SELECT jsonb_object_keys(c) LOOP
   404	    IF NOT (k = ANY(allowed_keys)) THEN
   405	      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
   406	    END IF;
   407	  END LOOP;
   408	
   409	  -- v0.3 type validations
   410	  -- diagnostic_per_claim_sample_rate DEFERRED to W4-polish ADR; not validated
   411	  -- in v0.3 (also not in allowlist above, so it would fail-fast anyway)
   412	
   413	  IF c ? 'concierge_send_window' THEN
   414	    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
   415	      RAISE EXCEPTION 'concierge_send_window must be object';
   416	    END IF;
   417	    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
   418	      RAISE EXCEPTION 'concierge_send_window must include timezone';
   419	    END IF;
   420	    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
   421	       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
   422	      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
   423	    END IF;
   424	    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
   425	       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
   426	      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
   427	    END IF;
   428	  END IF;
   429	
   430	  -- v0.3 timestamp-typed keys
   431	  IF c ? 'cash_conductor_last_run' THEN
   432	    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
   433	      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
   434	    END IF;
   435	  END IF;
   436	
   437	  IF c ? 'concierge_last_poll' THEN
   438	    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
   439	      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
   440	    END IF;
   441	  END IF;
   442	
   443	  RETURN NEW;
   444	END;
   445	$$ LANGUAGE plpgsql;
   446	
   447	DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
   448	
   449	CREATE TRIGGER validate_tenant_adapters_config_v0_3
   450	  BEFORE INSERT OR UPDATE ON tenant_adapters
   451	  FOR EACH ROW
   452	  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
   453	
   454	-- ----------------------------------------------------------------------------
   455	-- §6 — Smoke verification (read-only)
   456	-- ----------------------------------------------------------------------------

codex
One concrete blocker is emerging: the supplement calls its access matrix cumulative, but the matrix itself does not enumerate the v0.2 entity types that the same supplement amends separately. I’m doing one last pass for citation/claim mismatches before returning the verdict.
exec
/bin/zsh -lc "rg -n \"Phase 4 Cat|Cat-β|v0\\.3|diagnostic_per_claim|Tier 2|per_claim\" docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md docs/decisions/ADR-006* 2>/dev/null" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:118:- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:119:- Sample rate configurable per tenant via field landing in v0.3 vertical-schema supplement (concrete field name + type specified there, not in this ADR)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:138:| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:287:#### Category β — Schema-supplement-needed (v0.3 supplement is a founder-action gate before W4-W13 builds)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:293:- All five are blocked on v0.3 supplement landing (founder review at first-pilot-onboarding) — DOCUMENTED IN W4 BACKLOG
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:393:4. Bullhorn webhook v1.0 trigger conflicts with bullhorn-integration-path.md (webhooks v1.1+ only) — Cat-β-adjacent; agent.md should remove v1.0 webhook trigger
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*

exec
/bin/zsh -lc 'rg -n "cash_conductor_last_run|concierge_last_poll|concierge_send_window|diagnostic_per_claim_sample_rate|tenant_adapters_config_additions|4 new|4 keys" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 4 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:170:-- the 6 voice-score keys. v0.3 extends validation to cover the 14 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:375:-- v0.3 codifies 4 new config keys agents read. The validation trigger ensures
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:392:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:393:    'concierge_last_poll',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:394:    'concierge_send_window'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:395:    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:410:  -- diagnostic_per_claim_sample_rate DEFERRED to W4-polish ADR; not validated
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:413:  IF c ? 'concierge_send_window' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:414:    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:415:      RAISE EXCEPTION 'concierge_send_window must be object';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:417:    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:418:      RAISE EXCEPTION 'concierge_send_window must include timezone';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:420:    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:421:       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:422:      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:424:    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:425:       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:431:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:432:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:433:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:437:  IF c ? 'concierge_last_poll' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:438:    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:439:      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:547:# §4 — tenant_adapters.config new keys (4 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:554:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:556:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:574:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:600:  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:663:      hard-fails on unknown config keys (Rule 2); type-validates the 4 new

exec
/bin/zsh -lc 'rg -n "''^  voice_corpus:|''^  tone_rule:|''^  recent_edit:|v1_0_agent_access|description:|bullhorn_source:" docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '"'1,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
56:  voice_corpus:
57:    description: |
59:    bullhorn_source: none (IFOS-derived from /vault/<tenant>/_voice/ ingest)
60:    v1_0_agent_access:
123:  tone_rule:
124:    description: |
126:    bullhorn_source: none (IFOS-derived; authored in /vault/<tenant>/_voice/tone-rules.yaml then synced to Postgres)
127:    v1_0_agent_access:
189:  recent_edit:
190:    description: |
192:    bullhorn_source: none (IFOS-derived from operator's approve/edit UX)
193:    v1_0_agent_access:
268:    description: |
345:    description: |
354:    description: |

codex
REJECTED

1. The “complete v0.3 agent access matrix” omits v0.2 entity types. Lines 253-255 claim the matrix is cumulative across “all v0.1 + v0.2 + v0.3 dispositions,” but lines 324-388 only enumerate candidate/contractor/client/contact/brief/opportunity/placement/timesheet and omit `voice_corpus`, `tone_rule`, and `recent_edit` from `vertical-schema.v0.2-supplement.yaml`. Fix by adding every v0.2 entity type to each of the 6 v1.0 agent rows, or stop calling this the full cumulative matrix and provide a compliant full matrix elsewhere.

2. The tenant adapter config section claims 4 new keys but defines only 3. Line 547 says “new keys (4 keys)” and line 663 says the trigger “type-validates the 4 new v0.3 keys,” but lines 556-598 define only `cash_conductor_last_run`, `concierge_last_poll`, and `concierge_send_window`; the companion migration allowlist likewise contains only those 3 keys. Fix the count to 3 everywhere or add the missing fourth key with schema and SQL validation.

3. The ADR-006 deferral claim contradicts the accepted ADR. Lines 600-604 and 618-628 defer `diagnostic_per_claim_sample_rate` to a future W4-polish ADR, but `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` lines 118-119 state the Tier 2 sample rate is configurable “via field landing in v0.3 vertical-schema supplement.” Fix by either adding the field in v0.3 or updating ADR-006 before citing it as the basis for deferral.
tokens used
120,194
REJECTED

1. The “complete v0.3 agent access matrix” omits v0.2 entity types. Lines 253-255 claim the matrix is cumulative across “all v0.1 + v0.2 + v0.3 dispositions,” but lines 324-388 only enumerate candidate/contractor/client/contact/brief/opportunity/placement/timesheet and omit `voice_corpus`, `tone_rule`, and `recent_edit` from `vertical-schema.v0.2-supplement.yaml`. Fix by adding every v0.2 entity type to each of the 6 v1.0 agent rows, or stop calling this the full cumulative matrix and provide a compliant full matrix elsewhere.

2. The tenant adapter config section claims 4 new keys but defines only 3. Line 547 says “new keys (4 keys)” and line 663 says the trigger “type-validates the 4 new v0.3 keys,” but lines 556-598 define only `cash_conductor_last_run`, `concierge_last_poll`, and `concierge_send_window`; the companion migration allowlist likewise contains only those 3 keys. Fix the count to 3 everywhere or add the missing fourth key with schema and SQL validation.

3. The ADR-006 deferral claim contradicts the accepted ADR. Lines 600-604 and 618-628 defer `diagnostic_per_claim_sample_rate` to a future W4-polish ADR, but `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` lines 118-119 state the Tier 2 sample rate is configurable “via field landing in v0.3 vertical-schema supplement.” Fix by either adding the field in v0.3 or updating ADR-006 before citing it as the basis for deferral.
