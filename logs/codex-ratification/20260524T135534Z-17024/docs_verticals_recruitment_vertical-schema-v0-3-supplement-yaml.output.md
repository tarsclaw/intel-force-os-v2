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
session id: 019e5a45-0c5f-7140-b8ab-9a8b2d072409
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
# §2a — v0.2 entity v1_0_agent_access amendments
# ============================================================================
#
# Per review-schema-change §5: matrix changes must be reflected in entity-level
# v1_0_agent_access lists. v0.3 amends these v0.2 entities:

v0_2_entity_access_amendments:

  tone_rule:
    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R)]
    rationale: |
      Janitor agent.md §7 calls hh_load_tone_rules filtered by
      applies_to_agents containing 'janitor' for tacit-note narrative
      voice-classification. Per Round-8 Cat-β finding for Janitor.

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
I’ll verify the supplement against the live repo where the skill requires cross-checks, especially referenced migrations and prior schema/matrix context.
exec
/bin/zsh -lc 'wc -l docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     806 docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
     488 docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
     101 docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
    1395 total

exec
/bin/zsh -lc 'ls docs/verticals/recruitment/migrations && rg -n "CREATE TABLE|cash_conductor|validate_entities_data_v0_3|validate_tenant_adapters_config_v0_3|GRANT|CHECK|match_confidence|DROP TABLE|TODO" docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "''^(entities:|relationships:|agent_access_matrix:|bullhorn_mapping:|candidate:|contractor:|client:|contact:|brief:|opportunity:|placement:|timesheet:|voice_corpus:|tone_rule:|recent_edit:)" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:45:entities:
docs/verticals/recruitment/vertical-schema.yaml:583:relationships:
docs/verticals/recruitment/vertical-schema.yaml:669:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:739:bullhorn_mapping:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:53:entities:

 succeeded in 0ms:
v0.1-to-v0.2.sql
v0.2-to-v0.1.sql
v0.2-to-v0.3-pii-purge.sql
v0.2-to-v0.3.sql
v0.3-to-v0.2-pii-purge.sql
v0.3-to-v0.2.sql
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:20:--     payload key and its enforcement (CHECK constraint or trigger).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:56:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:59:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:71:  match_confidence   NUMERIC(3, 2),
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:76:  CONSTRAINT cct_match_status_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:79:  CONSTRAINT cct_bank_provider_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:82:  CONSTRAINT cct_match_confidence_range CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:83:    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:89:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:92:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:96:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:97:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:99:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:103:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:104:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:107:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:110:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:129:  CONSTRAINT cci_status_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:132:  CONSTRAINT cci_provider_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:135:  CONSTRAINT cci_chase_position_range CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:138:  CONSTRAINT cci_amount_paid_non_negative CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:145:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:148:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:152:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:156:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:158:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:162:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:163:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:174:CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:364:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:366:CREATE TRIGGER validate_entities_data_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:369:  EXECUTE FUNCTION validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:379:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:392:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:437:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:438:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:439:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:453:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:455:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:470:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:472:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:476:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:478:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:481:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';

codex
I’ve confirmed the referenced v0.3 migration files exist and are non-trivial. I’m now checking whether the supplement’s cumulative matrix and table claims line up with the earlier schema layers rather than just with itself.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '45,180p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '45,180p' && nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '669,760p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,220p' && nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '300,520p' && nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '730,790p'" in /Users/madsadmin/code/CortexOS
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
   333	    voice_corpus: R
   334	    voice_corpus_chunks: R
   335	    tone_rule: R
   336	    recent_edit: none
   337	
   338	  janitor:
   339	    candidate: R+W         # dedup + field-backfill writes
   340	    contractor: R+W        # dedup + field-backfill writes
   341	    client: R+W            # Companies House enrichment writes
   342	    contact: R+W           # dedup + field-backfill writes
   343	    brief: R               # context for related candidate cleanup
   344	    opportunity: R
   345	    placement: R+W         # lifecycle-state cleanup
   346	    timesheet: R           # reads for placement-state inference
   347	    voice_corpus: R        # tacit-note narrative voice grounding
   348	    voice_corpus_chunks: R
   349	    tone_rule: R           # v0.3 NEW (was no access)
   350	    recent_edit: R         # v0.3 NEW (was Concierge/canary/LoRA only); for tacit-note harvest
   351	
   352	  scribe:
   353	    candidate: R+W         # call-summary field extraction
   354	    contractor: R+W        # call-summary field extraction
   355	    client: R
   356	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
   357	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
   358	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
   359	    placement: R+W         # check-in field extraction
   360	    timesheet: R           # reads for placement-context resolution on check-in calls
   361	    voice_corpus: R        # tacit-note voice grounding
   362	    voice_corpus_chunks: R
   363	    tone_rule: R           # v0.2
   364	    recent_edit: W         # writes its own edits for retraining
   365	
   366	  cash_conductor:
   367	    candidate: none        # no Bullhorn dependency
   368	    contractor: none
   369	    client: R              # reads client billing details
   370	    contact: R             # reads for invoice addressee resolution
   371	    brief: none
   372	    opportunity: none
   373	    placement: R           # reads for client linkage on invoice
   374	    timesheet: R           # reads to verify billable hours match invoiced amounts
   375	    voice_corpus: R        # chase-email voice grounding
   376	    voice_corpus_chunks: R
   377	    tone_rule: R           # v0.2
   378	    recent_edit: W         # writes its own chase-draft edits for retraining
   379	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   380	
   381	  sourcing_scout:
   382	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   383	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   384	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   385	    # writes its proposed-candidate rows + reads opportunity context. These
   386	    # are entity-level access overrides codified here.
   387	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   388	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   389	    client: R
   390	    contact: R
   391	    brief: R               # reads to filter candidates
   392	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   393	    placement: none
   394	    timesheet: none
   395	    voice_corpus: R        # rationale-narrative voice grounding
   396	    voice_corpus_chunks: R
   397	    tone_rule: R
   398	    recent_edit: W         # writes rationale-narrative edits for retraining
   399	
   400	  concierge:
   401	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   402	    contractor: R+W        # writes lifecycle states for contractor placements too
   403	    client: R
   404	    contact: R             # reads for outbound recipient resolution
   405	    brief: R
   406	    opportunity: R
   407	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   408	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   409	    voice_corpus: R        # lifecycle-comms voice grounding
   410	    voice_corpus_chunks: R
   411	    tone_rule: R           # v0.2
   412	    recent_edit: R         # v0.2
   413	
   414	# ============================================================================
   415	# §2a — v0.2 entity v1_0_agent_access amendments
   416	# ============================================================================
   417	#
   418	# Per review-schema-change §5: matrix changes must be reflected in entity-level
   419	# v1_0_agent_access lists. v0.3 amends these v0.2 entities:
   420	
   421	v0_2_entity_access_amendments:
   422	
   423	  tone_rule:
   424	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
   425	    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R)]
   426	    rationale: |
   427	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   428	      applies_to_agents containing 'janitor' for tacit-note narrative
   429	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   430	
   431	  recent_edit:
   432	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   433	    v0_3_v1_0_agent_access:
   434	      - voice-drift-canary (W)  # v0.2 unchanged
   435	      - Concierge (R)            # v0.2 unchanged
   436	      - LoRA (R)                 # v0.2 unchanged
   437	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   438	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   439	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   440	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   441	    rationale: |
   442	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   443	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   444	      for retraining queue). Janitor adds R for tacit-note harvest per
   445	      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
   446	      supplement is the authoritative source for the expanded access list.
   447	
   448	# ============================================================================
   449	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   450	# ============================================================================
   451	
   452	auxiliary_tables:
   453	
   454	  cash_conductor_transactions:
   455	    rationale: |
   456	      Open Banking transactions are high-volume + time-series + don't model
   457	      as entity.data JSONB. v0.3 introduces a first-class table with
   458	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   459	      §4 Step 3 + ADR-002 vault/Postgres split.
   460	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   461	    columns:
   462	      id: {type: integer, required: true, notes: BIGSERIAL primary key in SQL}
   463	      tenant_slug: {type: string, required: true, notes: RLS isolation key per Day-4 §6.3}
   464	      transaction_id: {type: string, required: true, notes: Provider-supplied (TrueLayer / Plaid)}
   465	      posted_at: {type: timestamp, required: true}
   466	      amount: {type: number, required: true, notes: NUMERIC(15,2) GBP; negative for outgoing}
   467	      currency: {type: string, required: true, default: GBP}
   468	      payee_name_raw: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   469	      description: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   470	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct]}
   471	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched}
   472	      matched_invoice_id: {type: string, required: false, notes: FK to cash_conductor_invoices.invoice_id when match_status='matched'}
   473	      match_confidence: {type: number, required: false, notes: "range [0.00, 1.00]"}
   474	      match_dimensions: {type: array, items: {type: string}, required: false}
   475	      ingested_at: {type: timestamp, required: true, default: now()}
   476	      raw_payload: {type: object, required: false, pii: true, notes: Full Open Banking response; pseudonymized at year 7}
   477	    indexes:
   478	      - "(tenant_slug, posted_at DESC)"
   479	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   480	    retention: |
   481	      INTENT (W4-polish enforcement required): 7-year retention with
   482	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   483	      description, raw_payload). Aligned with Q4 v0_3_default. The
   484	      v0.2-to-v0.3 migration creates the table + indexes only; the
   485	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   486	      job or external scheduled job; not yet authored).
   487	    enforcement_gate: |
   488	      Production use of this table GATED until pseudonymization + purge
   489	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   490	      by founder + tenant before go-live; migration-test tenant exempt.
   491	
   492	  cash_conductor_invoices:
   493	    rationale: |
   494	      Open invoice register cached from accounting provider. Same auxiliary-
   495	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   496	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   497	    columns:
   498	      id: {type: integer, required: true}
   499	      tenant_slug: {type: string, required: true}
   500	      invoice_id: {type: string, required: true}
   501	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage]}
   502	      invoice_number: {type: string, required: false}
   503	      issued_at: {type: timestamp, required: true}
   504	      due_at: {type: timestamp, required: true}
   505	      amount_total: {type: number, required: true, notes: NUMERIC(15,2) GBP}
   506	      amount_paid: {type: number, required: true, default: 0}
   507	      currency: {type: string, required: true, default: GBP}
   508	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open}
   509	      client_contact_id: {type: string, required: false, notes: Links to Bullhorn placement.client_contact_id}
   510	      client_billing_email: {type: string, required: false, pii: true}
   511	      last_chase_position: {type: integer, required: true, default: 0, notes: 0-4 per Cash Conductor §3.2}
   512	      last_chase_sent_at: {type: timestamp, required: false}
   513	      ingested_at: {type: timestamp, required: true, default: now()}
   514	      raw_payload: {type: object, required: false, pii: true}
   515	    indexes:
   516	      - "(tenant_slug, due_at)"
   517	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   518	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   519	    retention: |
   520	      INTENT (W4-polish enforcement required): 7-year retention with
   730	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   731	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   732	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   733	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   734	    v0_3_default: A
   735	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   736	      escalate to B or C if 1:1 mapping breaks.
   737	
   738	  Q4_cash_conductor_transactions_retention:
   739	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   740	      What's the production retention policy?
   741	    options:
   742	      A: 7-year retention with automated pseudonymization at year 7 (hash
   743	         payee_name_raw + description; preserve amount + dates for audit).
   744	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   745	         rows retained beyond 7 years for cross-period reconciliation).
   746	      C: Per-tenant retention override in tenant_adapters.config.
   747	    v0_3_default: A
   748	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   749	      tenant requires shorter retention, escalate to C with tenant-specific
   750	      override. Pseudonymization implementation lands in W4-polish slice.
   751	    production_use_gating: |
   752	      Until pseudonymization implementation lands, production use of
   753	      cash_conductor_transactions table is GATED by an explicit per-tenant
   754	      DPA addendum signed by founder + tenant. Migration-test tenant data
   755	      is not subject to this gate.
   756	
   757	  Q5_unknown_config_keys_handling:
   758	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   759	    options:
   760	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   761	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   762	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   763	    v0_3_default: A
   764	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   765	      for forward-compat, escalate to B or C with explicit ADR.
   766	
   767	# ============================================================================
   768	# §9 — Why v0.3 is the right unblock
   769	# ============================================================================
   770	
   771	rationale: |
   772	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   773	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   774	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   775	  adds 14 entity JSONB keys + 2 auxiliary tables + 4 config keys. The
   776	  per_claim_confidence_distribution payload key originally planned for
   777	  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
   778	  §5 of this supplement); v0.3 is silent on payload schema extensions.
   779	
   780	  After v0.3 ratifies + migration applies:
   781	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   782	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   783	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   784	      placement_status, week_1_status_vault_path, satisfaction_signal,
   785	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   786	      are now schema-backed. (Note: week_1_status_note narrative now lives
   787	      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
   788	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   789	      seniority — not yet in schema; brief.start_date should be
   790	      start_date_target; opportunity.sector — not yet in schema). These

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '56,170p' && nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '174,370p' && nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '379,460p'" in /Users/madsadmin/code/CortexOS
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
   394	    'concierge_send_window',
   395	    'diagnostic_per_claim_sample_rate'
   396	  ];
   397	BEGIN
   398	  IF c IS NULL THEN
   399	    RETURN NEW;
   400	  END IF;
   401	
   402	  FOR k IN SELECT jsonb_object_keys(c) LOOP
   403	    IF NOT (k = ANY(allowed_keys)) THEN
   404	      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
   405	    END IF;
   406	  END LOOP;
   407	
   408	  -- v0.3 type validations
   409	  IF c ? 'diagnostic_per_claim_sample_rate' THEN
   410	    IF jsonb_typeof(c->'diagnostic_per_claim_sample_rate') != 'number' THEN
   411	      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be integer';
   412	    END IF;
   413	    IF (c->>'diagnostic_per_claim_sample_rate')::int < 1
   414	       OR (c->>'diagnostic_per_claim_sample_rate')::int > 100 THEN
   415	      RAISE EXCEPTION 'diagnostic_per_claim_sample_rate must be 1-100';
   416	    END IF;
   417	  END IF;
   418	
   419	  IF c ? 'concierge_send_window' THEN
   420	    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
   421	      RAISE EXCEPTION 'concierge_send_window must be object';
   422	    END IF;
   423	    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
   424	      RAISE EXCEPTION 'concierge_send_window must include timezone';
   425	    END IF;
   426	    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
   427	       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
   428	      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
   429	    END IF;
   430	    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
   431	       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
   432	      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
   433	    END IF;
   434	  END IF;
   435	
   436	  -- v0.3 timestamp-typed keys
   437	  IF c ? 'cash_conductor_last_run' THEN
   438	    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
   439	      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
   440	    END IF;
   441	  END IF;
   442	
   443	  IF c ? 'concierge_last_poll' THEN
   444	    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
   445	      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
   446	    END IF;
   447	  END IF;
   448	
   449	  RETURN NEW;
   450	END;
   451	$$ LANGUAGE plpgsql;
   452	
   453	DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
   454	
   455	CREATE TRIGGER validate_tenant_adapters_config_v0_3
   456	  BEFORE INSERT OR UPDATE ON tenant_adapters
   457	  FOR EACH ROW
   458	  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
   459	
   460	-- ----------------------------------------------------------------------------

exec
/bin/zsh -lc 'rg -n "voice_corpus_chunks|relationships:|additional_relationships:|agent_access_matrix:" docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:270:    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:339:additional_relationships:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:334:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:348:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:362:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:376:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:396:    voice_corpus_chunks: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:410:    voice_corpus_chunks: R

exec
/bin/zsh -lc "ruby -e 'require \"yaml\"; p YAML.load_file(\"docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml\").keys'" in /Users/madsadmin/code/CortexOS
 succeeded in 134ms:
["vertical", "version", "supplements", "status", "date", "author", "codex_ratification_queue_position", "entity_field_additions", "agent_access_matrix", "v0_2_entity_access_amendments", "auxiliary_tables", "auxiliary_table_access_matrix", "tenant_adapters_config_additions", "decision_log_payload_extension", "migration_sequence", "codex_ratification", "open_questions", "rationale", "end_of_supplement"]

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '250,335p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

codex
REJECTED

1. `agent_access_matrix` grants voice-corpus access that is not reflected in entity/table access amendments. Lines 324-410 grant `voice_corpus: R` and `voice_corpus_chunks: R` to all six v1.0 agents, but §2a lines 421-446 only amends `tone_rule` and `recent_edit`; v0.2 `voice_corpus.v1_0_agent_access` only lists Scribe, Concierge, and voice-drift-canary. This violates review-schema-change §5 matrix/entity-access consistency. Add explicit v0.3 access amendments for `voice_corpus` and `voice_corpus_chunks`, or narrow the matrix back to the declared v0.2 access.

2. `voice_corpus_chunks` is treated as an entity in the main matrix without being declared as one. Lines 333-334, 347-348, 361-362, 375-376, 395-396, and 409-410 include `voice_corpus_chunks` in `agent_access_matrix`, but v0.2 defines it as an auxiliary table for a pgvector index, not an `entities:` entry. This blurs the entity/auxiliary-table layering invariant. Move `voice_corpus_chunks` access into an auxiliary-table access matrix, or explicitly amend the supplement to define why it participates in the entity matrix despite being auxiliary.
tokens used
49,992
REJECTED

1. `agent_access_matrix` grants voice-corpus access that is not reflected in entity/table access amendments. Lines 324-410 grant `voice_corpus: R` and `voice_corpus_chunks: R` to all six v1.0 agents, but §2a lines 421-446 only amends `tone_rule` and `recent_edit`; v0.2 `voice_corpus.v1_0_agent_access` only lists Scribe, Concierge, and voice-drift-canary. This violates review-schema-change §5 matrix/entity-access consistency. Add explicit v0.3 access amendments for `voice_corpus` and `voice_corpus_chunks`, or narrow the matrix back to the declared v0.2 access.

2. `voice_corpus_chunks` is treated as an entity in the main matrix without being declared as one. Lines 333-334, 347-348, 361-362, 375-376, 395-396, and 409-410 include `voice_corpus_chunks` in `agent_access_matrix`, but v0.2 defines it as an auxiliary table for a pgvector index, not an `entities:` entry. This blurs the entity/auxiliary-table layering invariant. Move `voice_corpus_chunks` access into an auxiliary-table access matrix, or explicitly amend the supplement to define why it participates in the entity matrix despite being auxiliary.
