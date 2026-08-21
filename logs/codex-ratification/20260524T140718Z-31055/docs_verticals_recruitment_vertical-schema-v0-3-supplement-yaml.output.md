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
session id: 019e5a4f-ca3d-7a63-b07b-dd34ad1bc0b1
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
I’ll verify the supplement against the schema-change checks and spot-check the companion files/cited baseline so the verdict is grounded in the repo, not just the pasted text.
exec
/bin/zsh -lc 'rg -n "voice_corpus|tone_rule|recent_edit|voice_corpus_chunks|LAYERING DISCLOSURE|agent_access_matrix|bullhorn_mapping|relationships|candidate:" docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.yaml' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'ls -l docs/verticals/recruitment/migrations && rg -n "CREATE TABLE|cash_conductor_transactions|cash_conductor_invoices|match_confidence|GRANT|validate_entities_data_v0_3|validate_tenant_adapters_config_v0_3" docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:583:relationships:
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:669:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:672:    candidate: none
docs/verticals/recruitment/vertical-schema.yaml:683:    candidate: R+W   # full sweep + normalisation + dedup proposals
docs/verticals/recruitment/vertical-schema.yaml:693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
docs/verticals/recruitment/vertical-schema.yaml:703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
docs/verticals/recruitment/vertical-schema.yaml:713:    candidate: R     # passive matching
docs/verticals/recruitment/vertical-schema.yaml:723:    candidate: R+W   # lifecycle state on every event
docs/verticals/recruitment/vertical-schema.yaml:739:bullhorn_mapping:
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:886:      Structural cut. 8 entities + 10 relationships + agent-access matrix + Bullhorn mapping. Minimal field sets (10-20 per entity). 12 open questions catalogued (Q1, Q4 resolved at Day 6; Q2, Q3, Q5-Q12 deferred with named triggers).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:33:# LAYERING DISCLOSURE (Codex Round 1 — issue 2 incorporation):
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:336:# §4 — Additional relationships (2)
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.

 succeeded in 0ms:
total 120
-rw-r--r--@ 1 madsadmin  staff  16182 May 23 14:21 v0.1-to-v0.2.sql
-rw-r--r--@ 1 madsadmin  staff   2182 May 20 11:44 v0.2-to-v0.1.sql
-rw-r--r--@ 1 madsadmin  staff   4716 May 22 14:29 v0.2-to-v0.3-pii-purge.sql
-rw-r--r--@ 1 madsadmin  staff  19498 May 24 15:01 v0.2-to-v0.3.sql
-rw-r--r--@ 1 madsadmin  staff   1229 May 22 14:29 v0.3-to-v0.2-pii-purge.sql
-rw-r--r--@ 1 madsadmin  staff   4368 May 24 14:48 v0.3-to-v0.2.sql
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:56:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:59:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:71:  match_confidence   NUMERIC(3, 2),
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:447:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:452:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:464:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:466:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:470:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:472:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:475:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';

exec
/bin/zsh -lc "sed -n '1,220p' docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml" in /Users/madsadmin/code/CortexOS
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

codex
I’ve found the companion migration files and the v0.2/v0.1 schema context. I’m now checking for internal contradictions in access, migration claims, and the schema-layering rules before deciding.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,520p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,760p'" in /Users/madsadmin/code/CortexOS
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
   373	-- ----------------------------------------------------------------------------
   374	--
   375	-- v0.3 codifies 3 new config keys agents read. The validation trigger ensures
   376	-- only the documented keys are stored (hard-fail on unknown keys per Rule 2
   377	-- Schema before code).
   378	
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
   457	
   458	DO $$
   459	DECLARE
   460	  ccr_count INT;
   461	  cci_count INT;
   462	BEGIN
   463	  SELECT count(*) INTO ccr_count FROM information_schema.tables
   464	    WHERE table_name = 'cash_conductor_transactions';
   465	  IF ccr_count != 1 THEN
   466	    RAISE EXCEPTION 'cash_conductor_transactions table not created';
   467	  END IF;
   468	
   469	  SELECT count(*) INTO cci_count FROM information_schema.tables
   470	    WHERE table_name = 'cash_conductor_invoices';
   471	  IF cci_count != 1 THEN
   472	    RAISE EXCEPTION 'cash_conductor_invoices table not created';
   473	  END IF;
   474	
   475	  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
   476	END $$;
   477	
   478	COMMIT;
   479	
   480	-- ============================================================================
   481	-- End of v0.2 → v0.3 migration
   482	-- ============================================================================

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
   334	  # agent may have on any field of that entity. Per-field access (in §1
   335	  # entity_field_additions[*].v1_0_agent_access) NARROWS the entity-level
   336	  # disposition. Example: Scribe.candidate: R+W at entity level; per-field
   337	  # candidate.employment_type grants Scribe: W (because Scribe doesn't read
   338	  # employment_type, just writes it). This is intentional — the entity-level
   339	  # token is the ceiling; field-level may be narrower but never broader.
   340	  #
   341	  # Validation: the validate_entities_data_v0_3 trigger validates FIELD
   342	  # SHAPE only (type checks, enum membership, length caps, array element
   343	  # types). It does NOT enforce which agent is writing — agent-level
   344	  # write permission is DOCUMENTARY in v0.3, enforced at the application
   345	  # layer (cycle.sh + hh_decision_action) where the agent_name in the
   346	  # decision_log row records who wrote. Entity-level RLS enforces TENANT
   347	  # isolation but not agent-level access. Column-level RLS or per-agent
   348	  # database roles would be the v1.1+ enforcement layer; v0.3 is documentary.
   349	
   350	  diagnostic:
   351	    candidate: R           # reads for outreach context (§11 decision-maker map)
   352	    contractor: none       # not in scope at v1.0
   353	    client: R              # reads via Companies House lookup (entity-shape if cached)
   354	    contact: R             # reads for §11 decision-maker map
   355	    brief: none            # diagnostic is sales-tool not brief-driven
   356	    opportunity: R         # may read prospect-firm opportunity if exists
   357	    placement: none
   358	    timesheet: none
   359	
   360	  janitor:
   361	    candidate: R+W         # dedup + field-backfill writes
   362	    contractor: R+W        # dedup + field-backfill writes
   363	    client: R+W            # Companies House enrichment writes
   364	    contact: R+W           # dedup + field-backfill writes
   365	    brief: R               # context for related candidate cleanup
   366	    opportunity: R
   367	    placement: R+W         # lifecycle-state cleanup
   368	    timesheet: R           # reads for placement-state inference
   369	
   370	  scribe:
   371	    candidate: R+W         # call-summary field extraction
   372	    contractor: R+W        # call-summary field extraction
   373	    client: R
   374	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority — that remains v0.1-owned by founder/v1.1 Triage)
   375	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only (existing salary_min/max + start_date_target remain Bullhorn-sourced, R-only)
   376	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields
   377	    placement: R+W         # check-in field extraction
   378	    timesheet: R           # reads for placement-context resolution on check-in calls
   379	
   380	  cash_conductor:
   381	    candidate: none        # no Bullhorn dependency
   382	    contractor: none
   383	    client: R              # reads client billing details
   384	    contact: R             # reads for invoice addressee resolution
   385	    brief: none
   386	    opportunity: none
   387	    placement: R           # reads for client linkage on invoice
   388	    timesheet: R           # reads to verify billable hours match invoiced amounts
   389	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   390	
   391	  sourcing_scout:
   392	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   393	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   394	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   395	    # writes its proposed-candidate rows + reads opportunity context. These
   396	    # are entity-level access overrides codified here.
   397	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   398	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   399	    client: R
   400	    contact: R
   401	    brief: R               # reads to filter candidates
   402	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   403	    placement: none
   404	    timesheet: none
   405	
   406	  concierge:
   407	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   408	    contractor: R+W        # writes lifecycle states for contractor placements too
   409	    client: R
   410	    contact: R             # reads for outbound recipient resolution
   411	    brief: R
   412	    opportunity: R
   413	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   414	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   415	
   416	# ============================================================================
   417	# §2a — v0.2 entity v1_0_agent_access amendments
   418	# ============================================================================
   419	#
   420	# Per review-schema-change §5: matrix changes must be reflected in entity-level
   421	# v1_0_agent_access lists. v0.3 amends these v0.2 entities:
   422	
   423	v0_1_entity_access_amendments:
   424	  # Per review-schema-change §5: matrix changes to v0.1 entity-level access
   425	  # must be reflected in explicit amendments. Each entry below documents the
   426	  # v0.1 baseline → v0.3 expanded access list. The base vertical-schema.yaml
   427	  # is NOT edited; this supplement is the authoritative source for v0.3
   428	  # entity access state.
   429	
   430	  client:
   431	    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
   432	    v0_3_v1_0_agent_access:
   433	      - Diagnostic (R)     # v0.3 NEW — reads Companies House data for sales-tool context
   434	      - Janitor (R+W)      # v0.1 unchanged
   435	      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
   436	      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
   437	      - Sourcing Scout (R) # v0.1 unchanged
   438	      - Concierge (R)      # v0.1 unchanged
   439	    rationale: |
   440	      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
   441	      client billing/context for their respective workflows). No new W access.
   442	
   443	  contact:
   444	    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
   445	    v0_3_v1_0_agent_access:
   446	      - Diagnostic (R)     # v0.3 NEW — reads §11 decision-maker map context
   447	      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
   448	      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
   449	      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
   450	      - Sourcing Scout (R) # v0.1 unchanged
   451	      - Concierge (R)      # v0.1 unchanged
   452	    rationale: |
   453	      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
   454	      preferred_channel + next_action_target_date; Janitor also dedup-merges).
   455	      Diagnostic + Cash Conductor gain R for context.
   456	
   457	  brief:
   458	    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
   459	    v0_3_v1_0_agent_access:
   460	      - Janitor (R)        # v0.1 unchanged
   461	      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
   462	      - Sourcing Scout (R) # v0.1 unchanged
   463	      - Concierge (R)      # v0.1 unchanged
   464	    rationale: |
   465	      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
   466	      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
   467	      for Scribe.
   468	
   469	  opportunity:
   470	    v0_1_v1_0_agent_access: [Janitor (R)]
   471	    v0_3_v1_0_agent_access:
   472	      - Diagnostic (R)     # v0.3 NEW — reads prospect-firm opportunity if exists
   473	      - Janitor (R)        # v0.1 unchanged
   474	      - Scribe (R+W)       # v0.3 NEW — writes 3 new prospecting-call fields
   475	      - Cash Conductor (R) # v0.3 NEW — reads for invoice context
   476	      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
   477	      - Concierge (R)      # v0.3 NEW — reads for outbound lifecycle context
   478	    rationale: |
   479	      v0.1 opportunity is sparsely accessed (Janitor only); v0.3 broadens
   480	      to all v1.0 agents because the entity gains 3 new fields used across
   481	      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
   482	      timing), Diagnostic + Cash Conductor (reads for context).
   483	
   484	  placement:
   485	    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
   486	    v0_3_v1_0_agent_access:
   487	      - Janitor (R+W)      # v0.3 UPGRADED — lifecycle-state cleanup writes
   488	      - Scribe (R+W)       # v0.3 NEW — check-in field extraction
   489	      - Cash Conductor (R) # v0.1 unchanged
   490	      - Concierge (R+W)    # v0.3 UPGRADED — writes Bullhorn state advancement
   491	    rationale: |
   492	      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
   493	      their §4 specs); adds Scribe R+W for check-in writes.
   494	
   495	  timesheet:
   496	    v0_1_v1_0_agent_access: [Cash Conductor (R)]
   497	    v0_3_v1_0_agent_access:
   498	      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
   499	      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
   500	      - Cash Conductor (R) # v0.1 unchanged
   501	      - Concierge (R)      # v0.3 NEW — reads to verify placement-progress for nurture
   502	    rationale: |
   503	      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
   504	      Scribe + Concierge (each reads timesheet for their respective
   505	      placement-related workflows).
   506	
   507	  candidate:
   508	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   509	    v0_3_v1_0_agent_access:
   510	      - Diagnostic (R)     # v0.3 NEW — reads for outreach context (§11 decision-maker map)
   511	      - Janitor (R+W)      # v0.1 unchanged
   512	      - Scribe (R+W)       # v0.1 unchanged
   513	      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
   514	      - Concierge (R+W)    # v0.3 UPGRADED — writes lifecycle-state-derived fields
   515	    rationale: |
   516	      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
   517	      multi-source aggregation) + Concierge (writes lifecycle-state and
   518	      activity-log links per §4 Steps 13-14). Diagnostic gains R for context.
   519	
   520	  contractor:
   521	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   522	    v0_3_v1_0_agent_access:
   523	      - Janitor (R+W)      # v0.1 unchanged
   524	      - Scribe (R+W)       # v0.1 unchanged
   525	      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
   526	      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
   527	    rationale: |
   528	      Parallel upgrades to candidate; contractor entities follow the same
   529	      v0.3 write patterns where applicable.
   530	
   531	v0_2_entity_access_amendments:
   532	
   533	  voice_corpus:
   534	    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
   535	    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
   536	    rationale: |
   537	      All v1.0 agents that produce voice-classified output (Diagnostic for
   538	      §12 conversation opener; Janitor for tacit-note narratives; Cash
   539	      Conductor for chase drafts; Sourcing Scout for per-candidate
   540	      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
   541	      granted Scribe + Concierge; v0.3 extends to all 6.
   542	
   543	  tone_rule:
   544	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
   545	    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
   546	    rationale: |
   547	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   548	      applies_to_agents containing 'janitor' for tacit-note narrative
   549	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   550	      Diagnostic + Sourcing Scout also read tone_rules for their
   551	      voice-classified outputs (§12 opener, per-candidate rationale).
   552	
   553	  recent_edit:
   554	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   555	    v0_3_v1_0_agent_access:
   556	      - voice-drift-canary (W)  # v0.2 unchanged
   557	      - Concierge (R)            # v0.2 unchanged
   558	      - LoRA (R)                 # v0.2 unchanged
   559	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   560	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   561	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   562	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   563	    rationale: |
   564	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   565	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   566	      for retraining queue). Janitor adds R for tacit-note harvest per
   567	      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
   568	      supplement is the authoritative source for the expanded access list.
   569	
   570	# ============================================================================
   571	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   572	# ============================================================================
   573	
   574	auxiliary_tables:
   575	
   576	  cash_conductor_transactions:
   577	    rationale: |
   578	      Open Banking transactions are high-volume + time-series + don't model
   579	      as entity.data JSONB. v0.3 introduces a first-class table with
   580	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   581	      §4 Step 3 + ADR-002 vault/Postgres split.
   582	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   583	    columns:
   584	      id: {type: integer, required: true, notes: BIGSERIAL primary key in SQL}
   585	      tenant_slug: {type: string, required: true, notes: RLS isolation key per Day-4 §6.3}
   586	      transaction_id: {type: string, required: true, notes: Provider-supplied (TrueLayer / Plaid)}
   587	      posted_at: {type: timestamp, required: true}
   588	      amount: {type: number, required: true, notes: NUMERIC(15,2) GBP; negative for outgoing}
   589	      currency: {type: string, required: true, default: GBP}
   590	      payee_name_raw: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   591	      description: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   592	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct]}
   593	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched}
   594	      matched_invoice_id: {type: string, required: false, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   595	      match_confidence: {type: number, required: false, notes: "range [0.00, 1.00]"}
   596	      match_dimensions: {type: array, items: {type: string}, required: false}
   597	      ingested_at: {type: timestamp, required: true, default: now()}
   598	      raw_payload: {type: object, required: false, pii: true, notes: Full Open Banking response; pseudonymized at year 7}
   599	    indexes:
   600	      - "(tenant_slug, posted_at DESC)"
   601	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   602	    retention: |
   603	      INTENT (W4-polish enforcement required): 7-year retention with
   604	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   605	      description, raw_payload). Aligned with Q4 v0_3_default. The
   606	      v0.2-to-v0.3 migration creates the table + indexes only; the
   607	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   608	      job or external scheduled job; not yet authored).
   609	    enforcement_gate: |
   610	      Production use of this table GATED until pseudonymization + purge
   611	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   612	      by founder + tenant before go-live; migration-test tenant exempt.
   613	
   614	  cash_conductor_invoices:
   615	    rationale: |
   616	      Open invoice register cached from accounting provider. Same auxiliary-
   617	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   618	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   619	    columns:
   620	      id: {type: integer, required: true}
   621	      tenant_slug: {type: string, required: true}
   622	      invoice_id: {type: string, required: true}
   623	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage]}
   624	      invoice_number: {type: string, required: false}
   625	      issued_at: {type: timestamp, required: true}
   626	      due_at: {type: timestamp, required: true}
   627	      amount_total: {type: number, required: true, notes: NUMERIC(15,2) GBP}
   628	      amount_paid: {type: number, required: true, default: 0}
   629	      currency: {type: string, required: true, default: GBP}
   630	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open}
   631	      client_contact_id: {type: string, required: false, notes: Links to Bullhorn placement.client_contact_id}
   632	      client_billing_email: {type: string, required: false, pii: true}
   633	      last_chase_position: {type: integer, required: true, default: 0, notes: 0-4 per Cash Conductor §3.2}
   634	      last_chase_sent_at: {type: timestamp, required: false}
   635	      ingested_at: {type: timestamp, required: true, default: now()}
   636	      raw_payload: {type: object, required: false, pii: true}
   637	    indexes:
   638	      - "(tenant_slug, due_at)"
   639	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   640	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   641	    retention: |
   642	      INTENT (W4-polish enforcement required): 7-year retention with
   643	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   644	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   645	      pseudonymization + purge implementation is a W4-polish slice
   646	      (pg_cron job or external scheduled job; not yet authored).
   647	    enforcement_gate: |
   648	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   649	      W4 polish, production use of cash_conductor_invoices is GATED by
   650	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   651	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   652	      data is exempt; pilot tenants require the DPA addendum signed before
   653	      go-live.
   654	
   655	auxiliary_table_access_matrix:
   656	  cash_conductor_transactions:
   657	    diagnostic: none
   658	    janitor: none
   659	    scribe: none
   660	    cash_conductor: R+W
   661	    sourcing_scout: none
   662	    concierge: none
   663	  cash_conductor_invoices:
   664	    diagnostic: none
   665	    janitor: none
   666	    scribe: none
   667	    cash_conductor: R+W
   668	    sourcing_scout: none
   669	    concierge: none
   670	  voice_corpus_chunks:
   671	    # v0.2 auxiliary table holding the pgvector HNSW index over voice corpus chunks
   672	    # All v1.0 agents that produce voice-classified output need R for ANN-match retrieval
   673	    diagnostic: R
   674	    janitor: R
   675	    scribe: R
   676	    cash_conductor: R
   677	    sourcing_scout: R
   678	    concierge: R
   679	
   680	# ============================================================================
   681	# §4 — tenant_adapters.config new keys (3 keys)
   682	# ============================================================================
   683	#
   684	# tenant_adapters.config is JSONB; validation via
   685	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   686	# on unknown keys per Rule 2.
   687	
   688	tenant_adapters_config_additions:
   689	
   690	  cash_conductor_last_run:
   691	    type: timestamp
   692	    required: false
   693	    set_by: cash_conductor
   694	    read_by: [cash_conductor]
   695	    notes: |
   696	      Cash Conductor cron sweep updates at session-close. Next run queries
   697	      transactions/invoices since this timestamp.
   698	
   699	  concierge_last_poll:
   700	    type: timestamp
   701	    required: false
   702	    set_by: concierge
   703	    read_by: [concierge]
   704	    notes: |
   705	      Concierge polling cron updates at end of each cycle. Next poll queries
   706	      Bullhorn for state transitions since this timestamp.
   707	
   708	  concierge_send_window:
   709	    type: object
   710	    required: false
   711	    default:
   712	      timezone: Europe/London
   713	      weekday_start: '09:00'
   714	      weekday_end: '17:00'
   715	      weekend_send_enabled: false
   716	    set_by: [tenant-admin]
   717	    read_by: [concierge]
   718	    object_shape:
   719	      timezone:
   720	        type: string
   721	        notes: IANA timezone identifier
   722	      weekday_start:
   723	        type: string
   724	        notes: HH:MM 24-hour format
   725	      weekday_end:
   726	        type: string
   727	        notes: HH:MM 24-hour format
   728	      weekend_send_enabled:
   729	        type: boolean
   730	    notes: |
   731	      Per-tenant outbound sending hours. Concierge respects when scheduling
   732	      orange-tier sends.
   733	
   734	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   735	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
   736	  # declare this config key; the W4 ADR will introduce both the field
   737	  # and its consumer at the same time. Including it in v0.3 without an
   738	  # active consumer would be speculative schema.
   739	
   740	# ============================================================================
   741	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   742	# ============================================================================
   743	
   744	decision_log_payload_extension:
   745	  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
   746	  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
   747	  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
   748	  # that ships alongside Tier 2 activation. v0.3 introducing the payload
   749	  # key without enforcement would violate review-schema-change §3
   750	  # (bounded values require CHECK or trigger). Tier 2 schema work owns
   751	  # the constraint + writer; this v0.3 supplement is silent on it.
   752	  deferred_to_future_adr:
   753	    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
   754	    schema_owner: future W4-polish supplement (not v0.3)
   755	    rationale: |
   756	      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
   757	      separate post-launch quality metric outside Gate A. The payload key,
   758	      its [0.0, 1.0] range validation, and the sample-rate config field
   759	      all land together with Tier 2 activation. Tier 2 doesn't activate
   760	      until the voice classifier microservice ships + first pilot tenant

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '1,430p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '660,790p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '380,980p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
   380	  cash_conductor:
   381	    candidate: none        # no Bullhorn dependency
   382	    contractor: none
   383	    client: R              # reads client billing details
   384	    contact: R             # reads for invoice addressee resolution
   385	    brief: none
   386	    opportunity: none
   387	    placement: R           # reads for client linkage on invoice
   388	    timesheet: R           # reads to verify billable hours match invoiced amounts
   389	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   390	
   391	  sourcing_scout:
   392	    # v0.3 EXPLICIT OVERRIDES (per Round-6 finding #2): v0.1 base says
   393	    #   sourcing_scout.candidate: R; sourcing_scout.opportunity: none
   394	    # v0.3 amends to R+W and R respectively because the Sourcing Scout agent
   395	    # writes its proposed-candidate rows + reads opportunity context. These
   396	    # are entity-level access overrides codified here.
   397	    candidate: R+W         # OVERRIDE v0.1 R → v0.3 R+W (writes proposed-candidate rows)
   398	    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
   399	    client: R
   400	    contact: R
   401	    brief: R               # reads to filter candidates
   402	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   403	    placement: none
   404	    timesheet: none
   405	
   406	  concierge:
   407	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14
   408	    contractor: R+W        # writes lifecycle states for contractor placements too
   409	    client: R
   410	    contact: R             # reads for outbound recipient resolution
   411	    brief: R
   412	    opportunity: R
   413	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14
   414	    timesheet: R           # reads to verify placement-progress for 7d/30d/90d nurture
   415	
   416	# ============================================================================
   417	# §2a — v0.2 entity v1_0_agent_access amendments
   418	# ============================================================================
   419	#
   420	# Per review-schema-change §5: matrix changes must be reflected in entity-level
   421	# v1_0_agent_access lists. v0.3 amends these v0.2 entities:
   422	
   423	v0_1_entity_access_amendments:
   424	  # Per review-schema-change §5: matrix changes to v0.1 entity-level access
   425	  # must be reflected in explicit amendments. Each entry below documents the
   426	  # v0.1 baseline → v0.3 expanded access list. The base vertical-schema.yaml
   427	  # is NOT edited; this supplement is the authoritative source for v0.3
   428	  # entity access state.
   429	
   430	  client:
   431	    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
   432	    v0_3_v1_0_agent_access:
   433	      - Diagnostic (R)     # v0.3 NEW — reads Companies House data for sales-tool context
   434	      - Janitor (R+W)      # v0.1 unchanged
   435	      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
   436	      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
   437	      - Sourcing Scout (R) # v0.1 unchanged
   438	      - Concierge (R)      # v0.1 unchanged
   439	    rationale: |
   440	      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
   441	      client billing/context for their respective workflows). No new W access.
   442	
   443	  contact:
   444	    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
   445	    v0_3_v1_0_agent_access:
   446	      - Diagnostic (R)     # v0.3 NEW — reads §11 decision-maker map context
   447	      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
   448	      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
   449	      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
   450	      - Sourcing Scout (R) # v0.1 unchanged
   451	      - Concierge (R)      # v0.1 unchanged
   452	    rationale: |
   453	      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
   454	      preferred_channel + next_action_target_date; Janitor also dedup-merges).
   455	      Diagnostic + Cash Conductor gain R for context.
   456	
   457	  brief:
   458	    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
   459	    v0_3_v1_0_agent_access:
   460	      - Janitor (R)        # v0.1 unchanged
   461	      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
   462	      - Sourcing Scout (R) # v0.1 unchanged
   463	      - Concierge (R)      # v0.1 unchanged
   464	    rationale: |
   465	      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
   466	      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
   467	      for Scribe.
   468	
   469	  opportunity:
   470	    v0_1_v1_0_agent_access: [Janitor (R)]
   471	    v0_3_v1_0_agent_access:
   472	      - Diagnostic (R)     # v0.3 NEW — reads prospect-firm opportunity if exists
   473	      - Janitor (R)        # v0.1 unchanged
   474	      - Scribe (R+W)       # v0.3 NEW — writes 3 new prospecting-call fields
   475	      - Cash Conductor (R) # v0.3 NEW — reads for invoice context
   476	      - Sourcing Scout (R) # v0.3 NEW — reads opportunity for ICP scoring
   477	      - Concierge (R)      # v0.3 NEW — reads for outbound lifecycle context
   478	    rationale: |
   479	      v0.1 opportunity is sparsely accessed (Janitor only); v0.3 broadens
   480	      to all v1.0 agents because the entity gains 3 new fields used across
   481	      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
   482	      timing), Diagnostic + Cash Conductor (reads for context).
   483	
   484	  placement:
   485	    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
   486	    v0_3_v1_0_agent_access:
   487	      - Janitor (R+W)      # v0.3 UPGRADED — lifecycle-state cleanup writes
   488	      - Scribe (R+W)       # v0.3 NEW — check-in field extraction
   489	      - Cash Conductor (R) # v0.1 unchanged
   490	      - Concierge (R+W)    # v0.3 UPGRADED — writes Bullhorn state advancement
   491	    rationale: |
   492	      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
   493	      their §4 specs); adds Scribe R+W for check-in writes.
   494	
   495	  timesheet:
   496	    v0_1_v1_0_agent_access: [Cash Conductor (R)]
   497	    v0_3_v1_0_agent_access:
   498	      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
   499	      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
   500	      - Cash Conductor (R) # v0.1 unchanged
   501	      - Concierge (R)      # v0.3 NEW — reads to verify placement-progress for nurture
   502	    rationale: |
   503	      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
   504	      Scribe + Concierge (each reads timesheet for their respective
   505	      placement-related workflows).
   506	
   507	  candidate:
   508	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   509	    v0_3_v1_0_agent_access:
   510	      - Diagnostic (R)     # v0.3 NEW — reads for outreach context (§11 decision-maker map)
   511	      - Janitor (R+W)      # v0.1 unchanged
   512	      - Scribe (R+W)       # v0.1 unchanged
   513	      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
   514	      - Concierge (R+W)    # v0.3 UPGRADED — writes lifecycle-state-derived fields
   515	    rationale: |
   516	      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
   517	      multi-source aggregation) + Concierge (writes lifecycle-state and
   518	      activity-log links per §4 Steps 13-14). Diagnostic gains R for context.
   519	
   520	  contractor:
   521	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   522	    v0_3_v1_0_agent_access:
   523	      - Janitor (R+W)      # v0.1 unchanged
   524	      - Scribe (R+W)       # v0.1 unchanged
   525	      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
   526	      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
   527	    rationale: |
   528	      Parallel upgrades to candidate; contractor entities follow the same
   529	      v0.3 write patterns where applicable.
   530	
   531	v0_2_entity_access_amendments:
   532	
   533	  voice_corpus:
   534	    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
   535	    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
   536	    rationale: |
   537	      All v1.0 agents that produce voice-classified output (Diagnostic for
   538	      §12 conversation opener; Janitor for tacit-note narratives; Cash
   539	      Conductor for chase drafts; Sourcing Scout for per-candidate
   540	      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
   541	      granted Scribe + Concierge; v0.3 extends to all 6.
   542	
   543	  tone_rule:
   544	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
   545	    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
   546	    rationale: |
   547	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   548	      applies_to_agents containing 'janitor' for tacit-note narrative
   549	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   550	      Diagnostic + Sourcing Scout also read tone_rules for their
   551	      voice-classified outputs (§12 opener, per-candidate rationale).
   552	
   553	  recent_edit:
   554	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   555	    v0_3_v1_0_agent_access:
   556	      - voice-drift-canary (W)  # v0.2 unchanged
   557	      - Concierge (R)            # v0.2 unchanged
   558	      - LoRA (R)                 # v0.2 unchanged
   559	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   560	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   561	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   562	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   563	    rationale: |
   564	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   565	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   566	      for retraining queue). Janitor adds R for tacit-note harvest per
   567	      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
   568	      supplement is the authoritative source for the expanded access list.
   569	
   570	# ============================================================================
   571	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   572	# ============================================================================
   573	
   574	auxiliary_tables:
   575	
   576	  cash_conductor_transactions:
   577	    rationale: |
   578	      Open Banking transactions are high-volume + time-series + don't model
   579	      as entity.data JSONB. v0.3 introduces a first-class table with
   580	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   581	      §4 Step 3 + ADR-002 vault/Postgres split.
   582	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   583	    columns:
   584	      id: {type: integer, required: true, notes: BIGSERIAL primary key in SQL}
   585	      tenant_slug: {type: string, required: true, notes: RLS isolation key per Day-4 §6.3}
   586	      transaction_id: {type: string, required: true, notes: Provider-supplied (TrueLayer / Plaid)}
   587	      posted_at: {type: timestamp, required: true}
   588	      amount: {type: number, required: true, notes: NUMERIC(15,2) GBP; negative for outgoing}
   589	      currency: {type: string, required: true, default: GBP}
   590	      payee_name_raw: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   591	      description: {type: string, required: false, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   592	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct]}
   593	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched}
   594	      matched_invoice_id: {type: string, required: false, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   595	      match_confidence: {type: number, required: false, notes: "range [0.00, 1.00]"}
   596	      match_dimensions: {type: array, items: {type: string}, required: false}
   597	      ingested_at: {type: timestamp, required: true, default: now()}
   598	      raw_payload: {type: object, required: false, pii: true, notes: Full Open Banking response; pseudonymized at year 7}
   599	    indexes:
   600	      - "(tenant_slug, posted_at DESC)"
   601	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   602	    retention: |
   603	      INTENT (W4-polish enforcement required): 7-year retention with
   604	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   605	      description, raw_payload). Aligned with Q4 v0_3_default. The
   606	      v0.2-to-v0.3 migration creates the table + indexes only; the
   607	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   608	      job or external scheduled job; not yet authored).
   609	    enforcement_gate: |
   610	      Production use of this table GATED until pseudonymization + purge
   611	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   612	      by founder + tenant before go-live; migration-test tenant exempt.
   613	
   614	  cash_conductor_invoices:
   615	    rationale: |
   616	      Open invoice register cached from accounting provider. Same auxiliary-
   617	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   618	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   619	    columns:
   620	      id: {type: integer, required: true}
   621	      tenant_slug: {type: string, required: true}
   622	      invoice_id: {type: string, required: true}
   623	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage]}
   624	      invoice_number: {type: string, required: false}
   625	      issued_at: {type: timestamp, required: true}
   626	      due_at: {type: timestamp, required: true}
   627	      amount_total: {type: number, required: true, notes: NUMERIC(15,2) GBP}
   628	      amount_paid: {type: number, required: true, default: 0}
   629	      currency: {type: string, required: true, default: GBP}
   630	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open}
   631	      client_contact_id: {type: string, required: false, notes: Links to Bullhorn placement.client_contact_id}
   632	      client_billing_email: {type: string, required: false, pii: true}
   633	      last_chase_position: {type: integer, required: true, default: 0, notes: 0-4 per Cash Conductor §3.2}
   634	      last_chase_sent_at: {type: timestamp, required: false}
   635	      ingested_at: {type: timestamp, required: true, default: now()}
   636	      raw_payload: {type: object, required: false, pii: true}
   637	    indexes:
   638	      - "(tenant_slug, due_at)"
   639	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   640	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   641	    retention: |
   642	      INTENT (W4-polish enforcement required): 7-year retention with
   643	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   644	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   645	      pseudonymization + purge implementation is a W4-polish slice
   646	      (pg_cron job or external scheduled job; not yet authored).
   647	    enforcement_gate: |
   648	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   649	      W4 polish, production use of cash_conductor_invoices is GATED by
   650	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   651	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   652	      data is exempt; pilot tenants require the DPA addendum signed before
   653	      go-live.
   654	
   655	auxiliary_table_access_matrix:
   656	  cash_conductor_transactions:
   657	    diagnostic: none
   658	    janitor: none
   659	    scribe: none
   660	    cash_conductor: R+W
   661	    sourcing_scout: none
   662	    concierge: none
   663	  cash_conductor_invoices:
   664	    diagnostic: none
   665	    janitor: none
   666	    scribe: none
   667	    cash_conductor: R+W
   668	    sourcing_scout: none
   669	    concierge: none
   670	  voice_corpus_chunks:
   671	    # v0.2 auxiliary table holding the pgvector HNSW index over voice corpus chunks
   672	    # All v1.0 agents that produce voice-classified output need R for ANN-match retrieval
   673	    diagnostic: R
   674	    janitor: R
   675	    scribe: R
   676	    cash_conductor: R
   677	    sourcing_scout: R
   678	    concierge: R
   679	
   680	# ============================================================================
   681	# §4 — tenant_adapters.config new keys (3 keys)
   682	# ============================================================================
   683	#
   684	# tenant_adapters.config is JSONB; validation via
   685	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   686	# on unknown keys per Rule 2.
   687	
   688	tenant_adapters_config_additions:
   689	
   690	  cash_conductor_last_run:
   691	    type: timestamp
   692	    required: false
   693	    set_by: cash_conductor
   694	    read_by: [cash_conductor]
   695	    notes: |
   696	      Cash Conductor cron sweep updates at session-close. Next run queries
   697	      transactions/invoices since this timestamp.
   698	
   699	  concierge_last_poll:
   700	    type: timestamp
   701	    required: false
   702	    set_by: concierge
   703	    read_by: [concierge]
   704	    notes: |
   705	      Concierge polling cron updates at end of each cycle. Next poll queries
   706	      Bullhorn for state transitions since this timestamp.
   707	
   708	  concierge_send_window:
   709	    type: object
   710	    required: false
   711	    default:
   712	      timezone: Europe/London
   713	      weekday_start: '09:00'
   714	      weekday_end: '17:00'
   715	      weekend_send_enabled: false
   716	    set_by: [tenant-admin]
   717	    read_by: [concierge]
   718	    object_shape:
   719	      timezone:
   720	        type: string
   721	        notes: IANA timezone identifier
   722	      weekday_start:
   723	        type: string
   724	        notes: HH:MM 24-hour format
   725	      weekday_end:
   726	        type: string
   727	        notes: HH:MM 24-hour format
   728	      weekend_send_enabled:
   729	        type: boolean
   730	    notes: |
   731	      Per-tenant outbound sending hours. Concierge respects when scheduling
   732	      orange-tier sends.
   733	
   734	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   735	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
   736	  # declare this config key; the W4 ADR will introduce both the field
   737	  # and its consumer at the same time. Including it in v0.3 without an
   738	  # active consumer would be speculative schema.
   739	
   740	# ============================================================================
   741	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   742	# ============================================================================
   743	
   744	decision_log_payload_extension:
   745	  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
   746	  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
   747	  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
   748	  # that ships alongside Tier 2 activation. v0.3 introducing the payload
   749	  # key without enforcement would violate review-schema-change §3
   750	  # (bounded values require CHECK or trigger). Tier 2 schema work owns
   751	  # the constraint + writer; this v0.3 supplement is silent on it.
   752	  deferred_to_future_adr:
   753	    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
   754	    schema_owner: future W4-polish supplement (not v0.3)
   755	    rationale: |
   756	      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
   757	      separate post-launch quality metric outside Gate A. The payload key,
   758	      its [0.0, 1.0] range validation, and the sample-rate config field
   759	      all land together with Tier 2 activation. Tier 2 doesn't activate
   760	      until the voice classifier microservice ships + first pilot tenant
   761	      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
   762	      payload shape to avoid declaring schema without enforcement.
   763	
   764	# ============================================================================
   765	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   766	# ============================================================================
   767	
   768	migration_sequence:
   769	  forward: migrations/v0.2-to-v0.3.sql
   770	  rollback: migrations/v0.3-to-v0.2.sql
   771	
   772	  pre_conditions:
   773	    - v0.2 migration applied (voice_corpus + tone_rule + recent_edit tables exist)
   774	    - validate_voice_scores trigger active on entities table
   775	    - RLS + ifos_app grants from Day-4 §6.3 in place
   776	    - migration-test tenant row exists in tenants table
   777	
   778	  steps:
   779	    1: |
   780	      Verify v0.2 prerequisites (DO block in migration §1).
   781	    2: |
   782	      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
   783	      ifos_app grants + 2 indexes (migration §2).
   784	    3: |
   785	      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
   786	      (migration §3).
   787	    4: |
   788	      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
   789	      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
   790	      score checks. Adds JSONB key validations for 14 v0.3 fields across
   791	      candidate / contact / brief / placement / opportunity entity_types.
   792	      Re-attaches the trigger to entities table (migration §4).
   793	      NOTE: entities table itself is unchanged; entity.data is JSONB and
   794	      v0.3 keys are validated by the trigger, not via ALTER TABLE.
   795	    5: |
   796	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
   797	      hard-fails on unknown config keys (Rule 2); type-validates the 3 new
   798	      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
   799	    6: |
   800	      Smoke verification DO block confirms both cash_conductor_*
   801	      tables exist (migration §6).
   802	    7: |
   803	      COMMIT; or ROLLBACK on any error.
   804	
   805	  post_migration_steps:
   806	    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
   807	    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
   808	       to cite v0.3 supplement instead of "v0.3-supplement-pending"
   809	    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
   810	       Cat-β findings closed
   811	
   812	# ============================================================================
   813	# §7 — Codex ratification path
   814	# ============================================================================
   815	
   816	codex_ratification:
   817	  skill: review-schema-change
   818	  expected_round_trips: 1-2 (mechanical fixes only)
   819	  manifest_queue_position: 44 (after v0.2 supplement at 29)
   820	
   821	# ============================================================================
   822	# §8 — Open questions (structured per review-schema-change §8)
   823	# ============================================================================
   824	
   825	open_questions:
   826	
   827	  Q1_employment_type_enum_completeness:
   828	    question: Are 6 employment_type enum values sufficient for UK recruitment?
   829	    options:
   830	      A: |
   831	        Keep 6 values as in §1.candidate.employment_type — perm, contract,
   832	        contract_inside_ir35, contract_outside_ir35, day_rate, hybrid.
   833	      B: |
   834	        Add 3 more — fixed_term_employee, apprenticeship, contract_for_services.
   835	      C: |
   836	        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
   837	        (array of allowed strings); validate at write time against tenant's list.
   838	    v0_3_default: A
   839	    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
   840	      outside A, escalate to B or C.
   841	
   842	  Q2_key_skills_max_length:
   843	    question: Cap at 20 items per candidate adequate?
   844	    options:
   845	      A: Keep cap at 20 (validator hard-fails over).
   846	      B: Increase to 50 (handles senior technical candidates with deep stacks).
   847	      C: Remove cap entirely (rely on application-layer pruning).
   848	    v0_3_default: A
   849	    trigger_for_revisit: First-pilot data after 30+ candidates indexed; if >5%
   850	      of candidates hit the 20-item cap, escalate to B.
   851	
   852	  Q3_placement_status_enum_lifecycle:
   853	    question: 6-state placement_status enum maps to Bullhorn's native state machine?
   854	    options:
   855	      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
   856	      B: Add Bullhorn-native states verbatim to the enum (likely 8-10 more).
   857	      C: Add a mapping table (auxiliary) — placement_status_mapping with
   858	         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
   859	    v0_3_default: A
   860	    trigger_for_revisit: First-pilot Bullhorn schema audit at onboarding;
   861	      escalate to B or C if 1:1 mapping breaks.
   862	
   863	  Q4_cash_conductor_transactions_retention:
   864	    question: Bank-feed transactions contain PII (payee_name_raw + description).
   865	      What's the production retention policy?
   866	    options:
   867	      A: 7-year retention with automated pseudonymization at year 7 (hash
   868	         payee_name_raw + description; preserve amount + dates for audit).
   869	      B: Indefinite with pseudonymization at year 7 (same as A but matched
   870	         rows retained beyond 7 years for cross-period reconciliation).
   871	      C: Per-tenant retention override in tenant_adapters.config.
   872	    v0_3_default: A
   873	    trigger_for_revisit: First-pilot DPA review (founder + legal); if pilot
   874	      tenant requires shorter retention, escalate to C with tenant-specific
   875	      override. Pseudonymization implementation lands in W4-polish slice.
   876	    production_use_gating: |
   877	      Until pseudonymization implementation lands, production use of
   878	      cash_conductor_transactions table is GATED by an explicit per-tenant
   879	      DPA addendum signed by founder + tenant. Migration-test tenant data
   880	      is not subject to this gate.
   881	
   882	  Q5_unknown_config_keys_handling:
   883	    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
   884	    options:
   885	      A: Hard-fail (CURRENT v0.3 behavior per migration §5; Rule 2 Schema-before-code).
   886	      B: Warn-and-store-anyway (permissive; allows forward-compatible additions).
   887	      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
   888	    v0_3_default: A
   889	    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
   890	      for forward-compat, escalate to B or C with explicit ADR.
   891	
   892	# ============================================================================
   893	# §9 — Why v0.3 is the right unblock
   894	# ============================================================================
   895	
   896	rationale: |
   897	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
   898	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
   899	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
   900	  adds 14 entity JSONB keys + 2 auxiliary tables + 3 config keys. The
   901	  per_claim_confidence_distribution payload key originally planned for
   902	  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
   903	  §5 of this supplement); v0.3 is silent on payload schema extensions.
   904	
   905	  After v0.3 ratifies + migration applies:
   906	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
   907	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
   908	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
   909	      placement_status, week_1_status_vault_path, satisfaction_signal,
   910	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
   911	      are now schema-backed. (Note: week_1_status_note narrative now lives
   912	      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
   913	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
   914	      seniority — not yet in schema; brief.start_date should be
   915	      start_date_target; opportunity.sector — not yet in schema). These
   916	      residual gaps are tracked in W4-polish-schema-extension backlog;
   917	      they do not block v0.3 ratification but do require a Scribe agent.md
   918	      consistency-pass before Scribe ratifies.
   919	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   920	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   921	    - Concierge tenant_adapters.config field refs valid
   922	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   923	
   924	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   925	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   926	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   927	  not schema gaps.
   928	
   929	# ============================================================================
   930	
   931	end_of_supplement: true

exec
/bin/zsh -lc "rg -n \"tenant_adapters|cash_conductor_last_run|concierge_last_poll|approval_routing|janitor_last_run|pii_retention_days|config\" docs packages -g '"'!node_modules'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:681:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:684:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:685:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:688:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:690:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:699:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:736:  # declare this config key; the W4 ADR will introduce both the field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:      its [0.0, 1.0] range validation, and the sample-rate config field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:796:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:797:      hard-fails on unknown config keys (Rule 2); type-validates the 3 new
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:798:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:836:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:871:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:882:  Q5_unknown_config_keys_handling:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:883:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:889:    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:900:  adds 14 entity JSONB keys + 2 auxiliary tables + 3 config keys. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:921:    - Concierge tenant_adapters.config field refs valid
packages/agent-renderer/src/renderer.ts:18:import { synthesiseConfigJson, ConfigSynthesisError } from "./synthesis/configJson.js";
packages/agent-renderer/src/renderer.ts:31:    join(ctx.vaultRoot, "_config.yaml"),
packages/agent-renderer/src/renderer.ts:32:    join(ctx.vaultRoot, "_config", "_config.yaml"),
packages/agent-renderer/src/renderer.ts:93:  const bundleSchemaPath = join(ctx.bundleDir, "config.schema.json");
packages/agent-renderer/src/renderer.ts:99:  let configJson: Record<string, unknown>;
packages/agent-renderer/src/renderer.ts:101:    configJson = synthesiseConfigJson(ctx, tenantConfig, agentMaterialised as never) as Record<string, unknown>;
packages/agent-renderer/src/renderer.ts:148:    writeFileTracked(join(staging.tmpDir, "config.json"), JSON.stringify(configJson, null, 2) + "\n", undefined, counter);
packages/utilities/web-scraper/vitest.config.ts:1:import { defineConfig } from "vitest/config";
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
packages/agent-renderer/src/fileMap.ts:6:    { source: "config.schema.json", target: "config.json", action: "synthesis", note: "Schema + _config.yaml + common-*.json $refs per ADR-003 §2.1 row 2" },
packages/agent-renderer/src/fileMap.ts:21:  return ["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"];
docs/build-brief/00-MASTER-BRIEF.md:55:2. **Schema before code.** Anything that varies per customer lives in `docs/verticals/recruitment/vertical-schema.yaml`, the agent's `config.schema.json`, or the tenant's `/vault/{tenant}/`. Never in agent prompts. Never in agent code. A code review that finds a customer-specific string in code is rejected on that basis alone.
docs/build-brief/00-MASTER-BRIEF.md:94:├── ecosystem.config.js       # PM2 ecosystem stub
docs/build-brief/00-MASTER-BRIEF.md:113:| 1 | Persistent PTY via PM2 | `node-pty` + `ecosystem.config.js` regen via `cortextos ecosystem` | Per-tenant ecosystem entries via `cortextos init <tenant>` |
docs/build-brief/00-MASTER-BRIEF.md:115:| 3 | Inter-agent file bus | `bus/` shell wrappers (47 shims execing `node dist/cli.js bus <command>`) + `FastChecker` poll loop in daemon (default 1000ms via `pollInterval` in agent config, configurable per agent) | Our agents drop typed files into the bus; IFOS implements a parallel `wiki-*` surface (see §3.4) rather than overriding `kb-*` |
docs/build-brief/00-MASTER-BRIEF.md:116:| 4 | Approval gates | Daemon enforces explicit approval before external action; `manualFireDisabled` flag on crons | Standing approval categories per tenant config |
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:545:├── config.schema.json                  # Per-tenant config (extends common-*.json)
docs/build-brief/00-MASTER-BRIEF.md:617:# 3. config.schema.json (what the wizard collects)
docs/build-brief/00-MASTER-BRIEF.md:663:        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:52:- Authored as a separate W4 ADR (number to be assigned at W4-polish authoring time; this ADR does NOT pre-assign a number) together with the schema supplements that define its payload key + per-tenant config field
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:119:- Sample rate configurable per tenant via field landing in the future W4-polish vertical-schema supplement (concrete field name + type specified there alongside the Tier 2 writer + sampling-activation work; NOT in v0.3 supplement — v0.3 explicitly defers per its §5 `deferred_to_future_adr` block to avoid speculative schema without a current consumer)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:95:        source: IFOS-derived (config; v0.2 default "paragraph")
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:101:        source: IFOS-derived (config; default text-embedding-3-small)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.yaml:498:    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
docs/verticals/recruitment/vertical-schema.yaml:538:    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
docs/verticals/recruitment/vertical-schema.yaml:778:    bullhorn_entity: Bullhorn.JobSubmission (or Bullhorn.Opportunity depending on tenant configuration)
docs/verticals/recruitment/vertical-schema.yaml:781:    notes: Tenant-config dependent — some Bullhorn tenants use JobSubmission, some use Opportunity, some both. Adapter layer resolves at ingest.
docs/_supplementary/PRD-autonomous-agent.md:321:## Crons (managed by config.json, survive session restarts)
docs/_supplementary/PRD-autonomous-agent.md:615:3. Check config.json crons — run any that are due
docs/_supplementary/PRD-autonomous-agent.md:730:  config: DiscoveryConfig,
docs/_supplementary/PRD-autonomous-agent.md:737:    usernames: config.watchlist,
docs/_supplementary/PRD-autonomous-agent.md:738:    hashtags: config.hashtagTargets,
docs/_supplementary/PRD-autonomous-agent.md:743:  const run = await client.actor(config.apifyActorId).call(input);
docs/_supplementary/PRD-autonomous-agent.md:748:    .filter(item => item.videoViewCount >= config.minViews)
docs/_supplementary/PRD-autonomous-agent.md:749:    .filter(item => isWithinHours(item.timestamp, config.maxAgeHours))
docs/_supplementary/PRD-autonomous-agent.md:772:  return scored.slice(0, config.candidateCount).map(s => s.candidate);
docs/_supplementary/PRD-autonomous-agent.md:785:// Watchlist — update this in config.json
docs/_supplementary/PRD-autonomous-agent.md:1251:  config: HeyGenConfig,
docs/_supplementary/PRD-autonomous-agent.md:1265:          avatar_id: config.avatarId,
docs/_supplementary/PRD-autonomous-agent.md:1271:          voice_id: config.voiceId,
docs/_supplementary/PRD-autonomous-agent.md:1275:          type: config.backgroundType === 'transparent' ? 'transparent' : 'color',
docs/_supplementary/PRD-autonomous-agent.md:1276:          value: config.backgroundType === 'transparent' ? undefined : '#FFFFFF',
docs/_supplementary/PRD-autonomous-agent.md:2008:- [ ] Create tsconfig.json with strict mode
docs/_supplementary/PRD-autonomous-agent.md:2026:- [ ] Configure Vitest in vitest.config.ts
docs/_supplementary/PRD-autonomous-agent.md:2031:- [ ] Set coverage threshold to 70% in vitest.config.ts
docs/_supplementary/PRD-autonomous-agent.md:2158:- [ ] Configure watchlist in `config.json`
docs/_supplementary/PRD-autonomous-agent.md:2284:- [ ] Build `src/cron/runner.ts` — reads config.json, executes due crons
docs/_supplementary/PRD-autonomous-agent.md:2285:- [ ] Create `config.json` with all 6 cron entries
docs/_supplementary/PRD-autonomous-agent.md:2355:- [ ] **Task 27**: Client configuration system (database-backed)
docs/_supplementary/PRD-autonomous-agent.md:2371:├── config.json                  # Cron definitions + settings
docs/_supplementary/PRD-autonomous-agent.md:2376:├── tsconfig.json
packages/agents-runtime/_shared/common-vault.json:5:  "description": "Vault paths + concurrency lock config per docs/architecture/vault-concurrency.md.",
packages/agents-runtime/_shared/common-vault.json:18:    "config_subdir": {
packages/agents-runtime/_shared/common-vault.json:20:      "default": "_config/",
packages/agents-runtime/_shared/common-vault.json:21:      "description": "Relative to vault_root; holds _config.yaml + autosend-overrides.yaml."
packages/utilities/web-scraper/README.md:15:- **Cache:** 1-hour TTL for careers pages (matches `tools.yaml` cache config); disk-backed at `~/.ifos-cache/web-scraper/`. Override via `IFOS_WEB_SCRAPER_CACHE_DIR` env var.
packages/utilities/web-scraper/README.md:17:- **Timeout:** 10s default; configurable per call.
packages/harness/cortextos/src/telegram/api.ts:408:   * silent-broken-config that used to surface only at first real send:
packages/harness/cortextos/src/telegram/api.ts:460:    // no further probing is needed — the config is broken no matter what
docs/specs/ULTRAPLAN.md:20:**For the CS hire (Q3 2027):** Read §1 → §6 → §8 → §10. The product is the agents; CS is the gate model and the configuration story.
docs/specs/ULTRAPLAN.md:32:**Rule 2 — Schema before code.** Anything that varies between customers lives in `vertical-schema.yaml`, `config.schema.json`, or the tenant vault. Never in agent prompts. Never in agent logic. A code review that finds a customer-specific string in code is rejected on that basis alone.
docs/specs/ULTRAPLAN.md:58:| 1 | **Persistent PTY via PM2** | Working for ≥1 agent in dev; documented config; auto-restart on crash | Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving. |
docs/specs/ULTRAPLAN.md:61:| 4 | **Approval gates with standing authorisations** | Telegram approval surface working; standing-auth config schema defined | If not ready, every auto-send becomes draft-only for v1.0. Hurts the Triage pitch but doesn't kill it. |
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:125:├── config.schema.json             # Per-tenant configuration schema
docs/specs/ULTRAPLAN.md:220:- Inside: `_voice/`, `_playbooks/`, `_decisions/`, `candidates/`, `clients/`, `opportunities/`, `temp/` (if Temp tier active), `_config.yaml`.
docs/specs/ULTRAPLAN.md:257:Per the sovereign compute plan. Sovereign-tier tenants run on a dedicated slice of the Mac Studio cluster, with inference routed exclusively to local hardware. Their vault may be mirrored to local NVMe on the cluster nodes rather than the shared Hetzner volume. This is a deployment configuration, not a code path — same agent bundles, different physical placement.
docs/specs/ULTRAPLAN.md:263:2. Run `provision-tenant.sh {slug}` — creates `/vault/{slug}/` with skeleton, mounts in `/tenant/.claude/bin/` shared helpers, creates `.claude/tenant-config.json` placeholder.
docs/specs/ULTRAPLAN.md:264:3. Run `pm2-ecosystem-generate.sh {slug}` — writes `ecosystem.{slug}.config.js` for PM2.
docs/specs/ULTRAPLAN.md:270:3. `pm2 reload ecosystem.{slug}.config.js` — zero-downtime restart.
docs/specs/ULTRAPLAN.md:428:Gate B failures in month 3: the agent goes into tuning mode. The engineer pairs with the tenant for 2 weeks. Re-measure at month 4. If still failing, escalate to product review — is this config, schema, or genuine product weakness?
docs/specs/ULTRAPLAN.md:526:- **Build complexity:** **M** (1 week) — the structured field mapping is per-firm config, not code
docs/specs/ULTRAPLAN.md:625:- **MCP tools required:** Bullhorn, LinkedIn, Reed, CV-Library, GitHub (for tech briefs), Sector-specific (configurable per tenant)
docs/specs/ULTRAPLAN.md:667:| Real-Time Pulse | L (2 weeks) | Microsoft Graph subscriptions + LinkedIn + Companies House watchers | The signal-weighting per tenant is the per-customer config work |
docs/specs/ULTRAPLAN.md:767:- Week 8: Cash Conductor agent; chase-cadence config; tenant-level baseline DSO captured
packages/agent-renderer/src/synthesis/configJson.ts:74:  const bundleSchemaPath = join(ctx.bundleDir, "config.schema.json");
packages/agent-renderer/src/synthesis/configJson.ts:84:  const config: JsonObject = {
packages/agent-renderer/src/synthesis/configJson.ts:93:    applyDefaults(schema, config);
packages/agent-renderer/src/synthesis/configJson.ts:95:  applyDefaults(bundleSchema, config);
packages/agent-renderer/src/synthesis/configJson.ts:97:  const resolved = resolveTokens(config, ctx.tenantSlug) as JsonObject;
packages/agent-renderer/src/synthesis/configJson.ts:102:    throw new ConfigSynthesisError("schema-validation-failure", `config.json failed schema validation: ${errors}`);
packages/agents-runtime/_shared/common-base.json:5:  "description": "Shared identity fields every agent config must include. Per ADR-003 §2.1-B + spec gap §2.1-B resolution.",
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:50:- **Definition:** Postgres RLS is enabled on every tenant-data table. Even if a policy is missing or misconfigured, RLS-enabled tables default to deny.
docs/architecture/tenancy-invariants.md:125:  Expected: only `config.json` differs (different tenant_slug) and `.env` differs (different secrets); no cross-references.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:372:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:375:-- v0.3 codifies 3 new config keys agents read. The validation trigger ensures
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:379:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:382:  c JSONB := NEW.config;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:387:    'janitor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:388:    'pii_retention_days',  -- v0.2 PII purge runbook key
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:390:    'approval_routing', 'approval_timeouts', 'sampling_rates',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:392:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:393:    'concierge_last_poll',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:405:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:431:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:432:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:433:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:437:  IF c ? 'concierge_last_poll' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:438:    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:439:      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:447:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:450:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:452:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:199:  - **A:** Helpers write to `/vault/<tenant>/decision-log.jsonl` (fallback mode) — that's structured. BUT it's an audit trail that replays into Postgres, not the source of truth. Vault `_voice/`, `_config/`, `_brand/`, `_playbooks/` are content (markdown). Vault `spot-checks/` is markdown notes. Vault `_secrets.env` is config (Path D). ✓ Mostly clean.
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
docs/specs/_archive-build-handoff.md:192:2. Schema before code — customer-specific data lives in vertical-schema.yaml, config.schema.json, or vault. Never in agent prompts.
docs/specs/_archive-build-handoff.md:204:- README.md, agent.md, config.schema.json, tools.yaml, validate.sh, context.sh
docs/specs/_archive-build-handoff.md:336:# 3. config.schema.json (what the wizard collects)
docs/specs/_archive-build-handoff.md:418:2. **Schema before code** — anything that varies between customers lives in `vertical-schema.yaml`, `config.schema.json`, or the tenant vault. Never in agent prompts. A code review that finds a customer-specific string in code is rejected on that basis alone.
docs/_supplementary/build-plan-original.md:68:  config.schema.json      ← what the wizard collects from the client
docs/_supplementary/build-plan-original.md:619:- Banned-phrases regex (configurable per client)
docs/_supplementary/build-plan-original.md:760:DocuSign webhook `envelope-completed` or Stripe webhook `invoice.paid` (whichever signals "new client" in this client's workflow, configured in wizard).
docs/_supplementary/build-plan-original.md:900:The Claude Code side handles the **configuration and training**, not the live call. The live call runs on Vapi; when the call ends, Vapi webhooks the transcript and actions to your Claude Code webhook receiver, which triggers a post-call agent that:
docs/_supplementary/build-plan-original.md:1074:                      (b) starts a shared image with tenant config mounted
docs/_supplementary/build-plan-original.md:1089:- **Config is declarative, always.** Every piece of tenant state is in the tenant's config.json, vault files, or secrets store. No out-of-band "setup steps" in someone's head.
docs/_supplementary/build-plan-original.md:1107:Capture every piece of client config the provisioning system needs, in a flow a non-technical founder can complete in 90 minutes.
docs/_supplementary/build-plan-original.md:1123:**Step 3 — Agent selection + configuration (25 min)**
docs/_supplementary/build-plan-original.md:1125:- Per-agent: show what it does, key config (cadence, scope)
docs/_supplementary/build-plan-original.md:1148:- **Integration OAuth** — a config-driven OAuth flow dispatcher (standard pattern: Clerk-like abstraction)
docs/_supplementary/build-plan-original.md:1170:3. Agents — configuration per-agent, run history, cost profile
docs/_supplementary/build-plan-original.md:1177:10. Settings — tenant-wide config, notification prefs
docs/_supplementary/build-plan-original.md:1194:Each tenant's routes are dynamically registered from their config on startup. Service reloads on tenant provisioning.
docs/_supplementary/build-plan-original.md:1198:2. Rate-limit per tenant (prevent a misconfigured webhook from DDoSing)
docs/_supplementary/build-plan-original.md:1220:1. Reads every tenant's agent schedules from Postgres at startup + on config change
docs/_supplementary/build-plan-original.md:1397:- Every agent action, every human approval, every config change
docs/_supplementary/build-plan-original.md:1449:### Client configurability
docs/_supplementary/build-plan-original.md:1477:- Can provision a new sub-tenant themselves via the wizard (reduced version — pre-configured with the agency's defaults)
docs/_supplementary/build-plan-original.md:1489:**Name in UI.** "IntelForce AI OS" references are replaced with the agency's product name where configured.
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/decisions/autosend-approval-bridge-spec.md:201:├── tsconfig.json
docs/decisions/autosend-approval-bridge-spec.md:220:Estimated: ~600 lines TypeScript (incl. tests), ~150 lines bash/PM2 config. Similar shape to `packages/agent-renderer/` but smaller.
docs/decisions/autosend-approval-bridge-spec.md:307:- Adds 1 PM2-managed process (`ifos-autosend-bridge`) → ecosystem.config.js update
docs/_supplementary/technical-strategy-v2.md:84:Hooks are shell commands configured in `~/.claude/settings.json`:
docs/_supplementary/technical-strategy-v2.md:209:      config-schema.json       ← what the wizard collects
docs/_supplementary/technical-strategy-v2.md:234:1. Control plane reads their `config.json` (answers from the wizard)
docs/_supplementary/technical-strategy-v2.md:239:6. Bakes a tenant Docker image (or writes to an existing shared image with tenant config mounted)
docs/_supplementary/technical-strategy-v2.md:246:This is the IP. Not the agents. Not the dashboard. **The provisioning system that deploys 9 perfectly-configured agents in 15 minutes.**
docs/_supplementary/technical-strategy-v2.md:501:- **Mitigation:** abstract model selection per-agent. If Sonnet doubles in price, flip Content Creator to a cheaper model in config without touching orchestration.
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:68:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:74:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:76:-- tenant_adapters config validation trigger.
packages/agent-renderer/vitest.config.ts:1:import { defineConfig } from "vitest/config";
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
docs/_supplementary/strategic-plan.md:13:The core insight from Nick Puru's model is this: **he is not selling AI — he is selling a dashboard**. The dashboard is the product. The agents behind it are commoditising. The IP is the productization, the configuration layer, and the brand wrapped around a repeatable deployment system.
docs/_supplementary/strategic-plan.md:184:Here's why, honestly: you have open configuration issues, the Discord/Telegram channel bits are fragile, and you cannot ship a paying product on a runtime you're still troubleshooting. Instead:
docs/_supplementary/strategic-plan.md:215:2. **Control** — "I can pause, configure, retrain from one place"
docs/_supplementary/strategic-plan.md:260:  - Any missing integration → "Skip and configure later"
docs/_supplementary/strategic-plan.md:265:  - Per-agent config (e.g. Proposal Builder: which Fathom folder?
docs/_supplementary/strategic-plan.md:291:      config-schema.json  ← what client needs to provide
docs/_supplementary/strategic-plan.md:294:      config.json     ← their answers from the wizard
docs/_supplementary/strategic-plan.md:296:      deployment.json ← which agents enabled, with their configs
docs/_supplementary/strategic-plan.md:301:1. Reads their `config.json`
docs/_supplementary/strategic-plan.md:302:2. For each enabled agent, takes the template + their config → generates a runnable agent instance
docs/_supplementary/strategic-plan.md:307:**You configure once, deploy infinitely.** This is the IP.
docs/_supplementary/strategic-plan.md:343:- [ ] **Dev**: Build the 5-step configuration wizard
docs/_supplementary/strategic-plan.md:345:- [ ] **Dev**: Deployment orchestrator (config → running agents)
docs/_supplementary/strategic-plan.md:383:- Live screen-share where you configure a *fake* tenant live for them
docs/_supplementary/strategic-plan.md:398:3. **Content marketing with your existing playbook** — the Ian Gadzhi-style content strategy you've been building. Your yacht/lifestyle content now has a product behind it. Stop selling abstract AI; start selling the dashboard with "I just shipped this for [client] — watch me configure it in 10 mins".
docs/_supplementary/strategic-plan.md:439:- **OpenClaw instability** — you're still fixing config issues. Treat OpenClaw as v2, not v1 runtime. Build on boring reliable stack first.
docs/_supplementary/strategic-plan.md:452:**Not shipping.** Spending the 2-3 months planning, designing, iterating the dashboard UI, tweaking the OpenClaw config, and ending with zero paying clients.
docs/_supplementary/execution-plan.md:27:| **Dashboard prototype** | React component | Visual proof of product — hierarchy, activity log, configuration centre, agent detail | Brain view, Approvals view, Billing, Audit, Integrations, Settings, Mobile responsive, white-label layer, full design system |
docs/_supplementary/execution-plan.md:38:For every agent: `agent.md`, `config.schema.json`, `tools.yaml`, `validate.sh`, `context.sh`, test fixtures + golden outputs. These are the files Claude Code actually reads to run the agent. **This is the single biggest block of missing work.**
docs/_supplementary/execution-plan.md:88:- [ ] **C2b.** Tenant isolation: shared image with mounted config (recommended for v1) or per-tenant Docker image (for v2).
docs/_supplementary/execution-plan.md:135:- [ ] **1.2 — Proposal Builder `config.schema.json`**
docs/_supplementary/execution-plan.md:136:  - *Purpose:* JSON schema for what the wizard collects to configure this agent per tenant (pricing framework, sales lead email, sign-off block, tier thresholds, disqualifiers).
docs/_supplementary/execution-plan.md:139:  - *Prompt:* "Write `proposal-builder/config.schema.json` — the exact JSON Schema (draft-07) for what the Configuration Centre wizard collects per tenant to configure this agent. Cover all fields referenced in 1.1's prompt. Include descriptions, examples, and validation rules."
docs/_supplementary/execution-plan.md:169:  - *Prompt:* "Write the Tenant Container Structure Specification: the Dockerfile, base image, filesystem layout (/tenant/.claude/, /tenant/vault/, /tenant/intake/, /tenant/outbox/, /tenant/logs/), environment variables required (ANTHROPIC_API_KEY, tenant ID, integration tokens), runtime permissions, startup/shutdown hooks, and health check. Target: one tenant runnable from a single `docker run` with a config-volume mount."
docs/_supplementary/execution-plan.md:187:  - *Prompt:* "Write the Week-1 Experiment Runbook: exact step-by-step commands to (1) spin up a test tenant container on a local Mac, (2) configure test API keys, (3) run a real test Fathom call, (4) verify the webhook fires, (5) verify Claude Code runs with Proposal Builder, (6) verify output lands in Gmail drafts, (7) measure end-to-end time. Include the pass/fail criteria, expected token spend (with target range), and the specific failure modes to debug first."
docs/_supplementary/execution-plan.md:209:  - *Prompt:* "Produce the full Lead Hunter agent bundle per Build Plan §5: `agent.md` (Haiku-targeted, ICP-rubric-driven prompt), `config.schema.json` (ICP definition schema with industry SIC codes, employee bands, geography, revenue, disqualifiers), `tools.yaml` (Companies House, Prospeo, Kaspr, HubSpot — declare as UK-context stack, NOT Apollo), `validate.sh` (JSON schema + dedup + completeness checks), `context.sh` (no heavy retrieval — inject current CRM record hashes for dedup), 3 test fixtures + golden lead outputs."
docs/_supplementary/execution-plan.md:225:  - *Prompt:* "Produce a blank Standard Sub-Agent Template with placeholder content in every file (agent.md, config.schema.json, tools.yaml, validate.sh, context.sh, tests/README.md) and a CREATING_A_NEW_AGENT.md guide that walks through filling it in."
docs/_supplementary/execution-plan.md:249:  - *Prompt:* "Write the Provisioning System Engineering Specification per Build Plan §19: the full state machine (every step as a state with entry/exit conditions), the exact data flow from `wizard.config.json` through template rendering → secret encryption → vault initialisation → voice ingestion trigger → embedding index → container start → cron install → webhook register → smoke tests → dashboard go-live. Cover: idempotency, atomic rollback on any failure, versioning of every output, observability hooks, the exact CLI commands. Target: a senior dev can implement in 2 weeks from this spec alone."
docs/_supplementary/execution-plan.md:253:  - *Depends on:* 2.2–2.10 (config schemas feed into this), C1 decisions
docs/_supplementary/execution-plan.md:279:  - *Prompt:* "Write the Scheduler Engineering Specification per Build Plan §23: BullMQ + Redis setup (single repeatable queue per tenant, priority queues for critical agents like Proposal Builder), tenant schedule loading from Postgres on boot + on config change, per-agent cron expressions (list them all for a reference tenant), retry policies (exponential backoff per agent type), pause/resume per tenant, dashboard integration for visibility."
docs/_supplementary/execution-plan.md:297:  - *Prompt:* "Write the Observability Stack Engineering Specification per Build Plan §26: structured log format (JSON schema for agent invocations, errors, webhook events), Vector.dev shipping config, Postgres partitioned storage schema, the 3 Grafana dashboards (operator cross-tenant, per-tenant client-facing, cost trends), the alert rules (exact thresholds for: error rate, cost overrun, integration down, vault write failures, LLM-judge drift), tracing setup (OpenTelemetry), and the trace-id propagation through webhook → queue → Claude → MCP."
docs/_supplementary/execution-plan.md:312:  - *Purpose:* the queue, the UI, the SLA policies, the client configurability.
docs/_supplementary/execution-plan.md:315:  - *Prompt:* "Write the Human-in-the-Loop Approval System Engineering Specification per Build Plan §29: queue item schema, the state machine per item (created → pending → approved / rejected / edited / escalated → executed / cancelled), SLA policy engine (thresholds per agent type, urgency escalation, breach notifications), the UI interaction spec (list view, detail view, inline edit, batch select, keyboard shortcuts), client-configurable policy rules, auto-approval rule engine, integration into agent workflows (how an agent hands off to the queue and resumes after approval)."
docs/_supplementary/execution-plan.md:350:  - *Purpose:* per-agent configuration page, run history, cost trend.
docs/_supplementary/execution-plan.md:352:  - *Prompt:* "Write the Agents View Specification: the list layout, per-agent detail page (config editor with diff-view vs template defaults, run history with outcome filters, cost trend chart, test-run button with sandbox execution, version pinning UI, pause/resume controls), changes-require-approval flow when editing config."
docs/_supplementary/execution-plan.md:386:  - *Prompt:* "Write the Settings View Specification: tenant-wide config (brand voice re-training trigger, notification preferences, approval policies, working hours, data residency info), danger-zone (pause all agents, archive tenant, delete data)."
docs/_supplementary/execution-plan.md:460:  - *Prompt:* "Write the Visual Blueprint Demo Script: the 45-minute call flow — opening (5 min), discovery Qs (10 min), live configuration of a fake tenant with their branding (15 min — the 'wow moment'), running a fake Proposal Builder end-to-end (5 min), pricing walkthrough (5 min), close (5 min). Include the exact talk-track per section, the objection hooks, the moments to pause for reaction, the close language."
docs/_supplementary/execution-plan.md:517:  - *Effort:* 0.5C + config
docs/_supplementary/execution-plan.md:541:  - *Prompt:* "Write the Voice Receptionist Full Specification: the Vapi platform configuration (assistants, tools, actions), the pre-call context injection (practice info, FAQs, protocols), the in-call escalation triggers, the post-call Claude Code agent that processes the call outcome, the Calendly/Cal.com booking flow, the FAQ training pipeline, the edge cases (accents, complaints, emergencies, out-of-hours), the testing framework (100+ test calls before launch)."
docs/specs/PRODUCT-SPEC.md:3:**Document type:** Authoritative product spec — what we are building, what each agent delivers, how it makes money, how it configures per client at scale
docs/specs/PRODUCT-SPEC.md:62:- **Per-tenant config keys** — the 4–8 things the onboarding wizard collects
docs/specs/PRODUCT-SPEC.md:71:- **Per-tenant config:** mailbox OAuth list, auto-send approval categories, escalation thresholds, voice profile path, firm-specific suppressions (named recruiters whose emails always escalate).
docs/specs/PRODUCT-SPEC.md:80:- **Per-tenant config:** accounting OAuth (Xero / QuickBooks / Sage), bank-feed connection, chase-cadence rules, escalation-threshold pounds, FD's mobile for Telegram approval.
docs/specs/PRODUCT-SPEC.md:90:- **Per-tenant config:** target patch (sectors, geography, company size), competitor list (the agencies whose postings to watch), preferred outreach channel, named-consultant routing rules, signal-weighting overrides.
docs/specs/PRODUCT-SPEC.md:99:- **Per-tenant config:** sourcing playbook path, source budget (LinkedIn / Reed / CV Library / GitHub / sector-specific), candidate-rejection patterns, must-haves vs nice-to-haves taxonomy, draft tone overrides per role family.
docs/specs/PRODUCT-SPEC.md:108:- **Per-tenant config:** shared with Night Sourcer (same playbook, same source budget).
docs/specs/PRODUCT-SPEC.md:117:- **Per-tenant config:** transcript-source OAuth, ATS field-mapping rules, tacit-note retention policy, banned-extraction patterns (anything sensitive that shouldn't be captured).
docs/specs/PRODUCT-SPEC.md:126:- **Per-tenant config:** nurture cadence per stage, voice tone per stage, referral-prompt templates, lifecycle-stage to comms-template mapping, do-not-contact flags.
docs/specs/PRODUCT-SPEC.md:135:- **Per-tenant config:** client portfolio scope, signal-weighting overrides, account-team routing rules, escalation thresholds per client tier (key account vs occasional).
docs/specs/PRODUCT-SPEC.md:144:- **Per-tenant config:** ATS connector, retention-policy rules, dedup-confidence threshold, field-completeness targets, deletion approval flow (always human-in-loop for v1).
docs/specs/PRODUCT-SPEC.md:153:- **Per-tenant config:** firm fee-structure library, intake-call template, ambiguity-detection thresholds, role-family taxonomy.
docs/specs/PRODUCT-SPEC.md:162:- **Per-tenant config:** target-patch definition (shared with Client Hunter), anonymisation rules, fee structure templates per pitch type, do-not-pitch flags per candidate.
docs/specs/PRODUCT-SPEC.md:171:- **Per-tenant config:** report-template path, KPI definitions, fee-earner roster, board-meeting cadence, target benchmarks per metric.
docs/specs/PRODUCT-SPEC.md:303:## 5. Per-tenant configuration at scale — the operational playbook
docs/specs/PRODUCT-SPEC.md:307:### 5.1 The principle: configuration is per-tenant data, not per-tenant code
docs/specs/PRODUCT-SPEC.md:311:1. **The per-tenant `config.schema.json` for each agent** — schema-validated JSON the wizard fills.
docs/specs/PRODUCT-SPEC.md:315:- It belongs in their `config.schema.json` → we add a config field, not a special case.
docs/specs/PRODUCT-SPEC.md:340:- These populate the per-agent `config.schema.json` files automatically.
docs/specs/PRODUCT-SPEC.md:341:- Customer reviews the populated configs in the Brain UI.
docs/specs/PRODUCT-SPEC.md:353:### 5.3 What the wizard collects — the master config template
docs/specs/PRODUCT-SPEC.md:355:Every agent's `config.schema.json` follows the same pattern (we already have this for Phase 2 agents). The cross-agent shared keys live in `common-*.json` shared schemas:
docs/specs/PRODUCT-SPEC.md:365:Each per-agent config then has only its agent-specific keys (e.g., the Night Sourcer's source budget allocation, Pulse's signal weights). This means a typical agent's `config.schema.json` is 30 lines, not 300. Scales.
docs/specs/PRODUCT-SPEC.md:380:1. **"It's already a config field — let me show you where."** This is the answer 60% of the time. The wizard hides depth that's available to customers who know to ask.
packages/agent-renderer/templates/claude-md-preamble.md:63:Auto-send tier policy per `_shared/autosend-policy.yaml`. Tenant override file (if present): `/vault/{{tenant_slug}}/_config/autosend-overrides.yaml` — read by `autosend_apply_tenant_override` per `docs/decisions/autosend-safety-policy.md` §4.
packages/harness/cortextos/src/hooks/hook-crash-alert.ts:82: * Read max_crashes_per_day from the agent's config.json. Returns null if the
packages/harness/cortextos/src/hooks/hook-crash-alert.ts:84: * null as "no limit configured" so a missing config never blocks the alert.
packages/harness/cortextos/src/hooks/hook-crash-alert.ts:89:    const cfg = JSON.parse(readFileSync(join(agentDir, 'config.json'), 'utf-8')) as Record<string, unknown>;
docs/architecture/cortexos-kb-surface-investigation.md:31:- **Chat model field:** `gemini_model: "gemini-2.5-flash"` — exists in config but unclear from setup alone whether mmrag uses it for query rewriting, summarisation, or just metadata.
docs/architecture/cortexos-kb-surface-investigation.md:50:  - Writes a default `config.json` at `$KB_ROOT/config.json` if absent (line 82-95) with the eight-key schema documented above.
docs/_supplementary/planning-phase-brief.md:13:- Schemas, configs, and YAML declarations
docs/_supplementary/planning-phase-brief.md:30:| **CC1** | **Control Plane (Next.js app)** — tenant management, billing, config wizard, dashboard, HITL approval queue, API layer | TypeScript / Next.js 14 / Postgres | Phase 3 (§3.1, 3.2, 3.10, 3.12), all of Phase 4 |
docs/_supplementary/planning-phase-brief.md:33:| **CC4** | **Provisioning Orchestrator** — state machine that deploys new tenants from wizard config | TypeScript | §3.1 |
docs/_supplementary/planning-phase-brief.md:37:| **CC8** | **Tenant Docker Image** — base image with Claude Code + integration configs + hooks | Dockerfile + shell | §1.7 |
docs/_supplementary/planning-phase-brief.md:56:| 1.2 | Proposal Builder config.schema.json | **P** |
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:50:Source: [tenant config](vault://target-patch)
docs/decisions/ADR-003-agent-bundle-renderer.md:13:ADR-002 §1.7-A surfaced the spec gap. Master brief §8 (lines 545-568) specifies the IFOS Agent Bundle v2 — six files plus three fixtures at `agents/recruitment/<name>/` — but is silent on how the bundle becomes a runnable cortextOS agent. The cortextOS daemon's `AgentManager.discoverAndStart()` (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`) reads from `${frameworkRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `CLAUDE.md`, `.env`). The two layouts are incompatible without translation.
docs/decisions/ADR-003-agent-bundle-renderer.md:47:- **Synthesis (3):** `agent.md` → `CLAUDE.md` (with cortextOS preamble wrapper); `config.schema.json` → `config.json` (materialised via per-tenant `_config.yaml` + common-*.json $refs); `(no source)` → `.env` (from `_secrets.env` + tools.yaml MCP server list).
docs/decisions/ADR-003-agent-bundle-renderer.md:54:The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.
docs/decisions/ADR-003-agent-bundle-renderer.md:62:**No-op detection** per design §3.4: four-condition check (bundle SHA `git hash-object -t tree` + render log + `/vault/<tenant>/_config.yaml` mtime + `agents/_shared/` SHA). If all four match the last successful render, renderer exits 0 with `No-op:` stdout and a `render_outcome: no-op` JSONL line.
docs/decisions/ADR-003-agent-bundle-renderer.md:107:> # 3. config.schema.json (what the wizard collects)
packages/harness/cortextos/src/hooks/hook-permission-telegram.ts:38:    outputDecision('deny', 'No Telegram credentials configured for remote approval');
docs/decisions/ADR-004-renderer-implementation-deviations.md:72:**Observation:** `cortextos-ifos list-agents` (which calls into `packages/harness/cortextos/src/bus/agents.ts` `listAgents()`) scans `${frameworkRoot}/orgs/<org>/agents/*` and treats every immediate directory child as an agent. `_shared/` sits in that location per ADR-003 §3.3.3 Option γ. Result: `_shared` appears in the list-agents output as if it were an agent named `_shared` in org `<tenant>`, with no display name + no config + status `stopped`.
docs/decisions/ADR-004-renderer-implementation-deviations.md:74:**Decision:** **Accept as upstream limitation.** Do NOT modify the renderer to relocate `_shared/` outside the scanned directory. The placement matches ADR-003's design intent (one canonical `_shared/` per org reachable by all agents via relative symlink). Renderer correctness is unaffected — the daemon's own `discoverAndStart()` doesn't try to launch `_shared` because it has no `config.json`; PM2 + agent-manager skip it cleanly. Only the cosmetic `list-agents` output is affected.
docs/_archive-build-pack/01-RECOMMENDATION.md:43:│   ├── daemon/                     ← thin wrapper that boots cortextOS with v2 config
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:50:Source: [tenant config](vault://target-patch)
docs/_archive-build-pack/06-BUILD-PLAN.md:28:- Top-level `package.json`, `pnpm-workspace.yaml`, `tsconfig.base.json`
docs/_archive-build-pack/06-BUILD-PLAN.md:30:- Each package has `package.json` + `tsconfig.json` + `src/index.ts` stub
docs/_archive-build-pack/06-BUILD-PLAN.md:44:- `apps/daemon/src/config.ts` — defines a hard-coded "dev" tenant for Phase 0 (no DB yet)
docs/_archive-build-pack/06-BUILD-PLAN.md:45:- `apps/daemon/ecosystem.config.js` — PM2 config that runs `node dist/boot.js`
docs/_archive-build-pack/06-BUILD-PLAN.md:51:- Boot daemon: `pnpm pm2 start apps/daemon/ecosystem.config.js`
docs/_archive-build-pack/06-BUILD-PLAN.md:65:- [ ] Orchestrator sends one Telegram message visible in the configured chat
docs/_archive-build-pack/06-BUILD-PLAN.md:83:- `packages/brain/tsup.config.ts` — bundles CLI to `dist/`
docs/_archive-build-pack/06-BUILD-PLAN.md:152:- Tailwind v4 config in dashboard imports from `packages/ui/tailwind.tokens.css`
docs/_archive-build-pack/06-BUILD-PLAN.md:226:- `infra/pm2/ecosystem.config.js` generator — accepts a tenant slug, produces a PM2 config that spawns a tenant-isolated daemon
packages/utilities/web-scraper/pnpm-lock.yaml:776:  lilconfig@3.1.3:
packages/utilities/web-scraper/pnpm-lock.yaml:783:  load-tsconfig@0.2.5:
packages/utilities/web-scraper/pnpm-lock.yaml:835:  postcss-load-config@6.0.1:
packages/utilities/web-scraper/pnpm-lock.yaml:1406:      load-tsconfig: 0.2.5
packages/utilities/web-scraper/pnpm-lock.yaml:1543:  lilconfig@3.1.3: {}
packages/utilities/web-scraper/pnpm-lock.yaml:1547:  load-tsconfig@0.2.5: {}
packages/utilities/web-scraper/pnpm-lock.yaml:1592:  postcss-load-config@6.0.1(postcss@8.5.15)(tsx@4.22.3):
packages/utilities/web-scraper/pnpm-lock.yaml:1594:      lilconfig: 3.1.3
packages/utilities/web-scraper/pnpm-lock.yaml:1700:      postcss-load-config: 6.0.1(postcss@8.5.15)(tsx@4.22.3)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:81:**Current** (master brief §3.4 line 167-176): "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**. … 1. Vendored copy at `packages/harness/cortextos/bus/kb-*.sh` is left untouched. 2. Our overrides live at `packages/brain/bus-overrides/kb-*.sh`. 3. PM2 `ecosystem.config.js` sets `PATH` so our overrides are picked up first…"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/decisions/sequencing-target.md:122:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 526 estimate **M (1 week)**. Webhook-driven not always-on. Structured-field mapping is per-firm config not code per Ultraplan §8.1 line 526. Tacit-note extraction is the hard part per Ultraplan §8.1 line 527 ("Start with a small taxonomy (5-10 tacit-note types) and expand") |
docs/decisions/sequencing-target.md:140:| 6. Tenant-onboarding readiness | **Medium** | Needs Xero/QuickBooks/Sage OAuth (one of, per tenant) + Open Banking auth (TrueLayer/Plaid UK per Ultraplan §8.1 line 539). Chase-cadence config per tenant. FD's mobile for Telegram approval per Ultraplan §8.1 line 540 |
docs/decisions/sequencing-target.md:168:| 6. Tenant-onboarding readiness | **Hardest** | Needs Bullhorn + Microsoft Graph (or Gmail) per tenant + full voice corpus loaded + nurture cadence config per stage + auto-send approval categories (Solo: drafts-only; Boutique+: candidate-acknowledgement auto-send) + do-not-contact flags. Full onboarding-wizard Day 4 work (Product Spec §5.2) |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
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
packages/agent-renderer/README.md:77:| `config.schema.json` | `config.json` | Synthesis: schema + `_config.yaml` + common-*.json defaults + Ajv validation |
packages/agent-renderer/README.md:106:| `schema-validation-failure` | `config.json` failed Ajv validation against bundle schema |
packages/agent-renderer/README.md:136:├── tsconfig.json             ← strict TypeScript; ES2022
packages/agent-renderer/README.md:137:├── tsup.config.ts            ← build target node20; ESM banner with shebang
packages/agent-renderer/README.md:138:├── vitest.config.ts          ← test config; tests/**/*.test.ts
packages/agent-renderer/README.md:148:│       ├── configJson.ts     ← Ajv 2020-12 + common-*.json $refs
packages/agent-renderer/README.md:157:        └── test-tenant-vault/migration-test/  ← _config.yaml + _secrets.env
packages/agent-renderer/README.md:165:- `packages/agents-runtime/_shared/common-*.json` — shared config schemas (Phase 1)
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:38:> "Inter-agent file bus | `bus/` shell wrappers (47 shims execing `node dist/cli.js bus <command>`) + `FastChecker` poll loop in daemon (default 1000ms via `pollInterval` in agent config, configurable per agent)"
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:47:| **B. Reduce to 250ms** | Set `pollInterval: 250` in the IFOS agent template's `config.json`. Re-measure daemon CPU on a 6-agent fleet under load (master brief §6 Day 4 stress-test addition). Keep the existing "complete in seconds" framing | ~0.5 day to add the config + re-baseline; ongoing 4× CPU per FastChecker poll (still negligible — `readdirSync` on a typically-empty inbox dir is sub-millisecond, so 4× sub-ms is still sub-ms). The risk is `bus-signing-key` HMAC verification cost × 4 if inbox traffic spikes | Pipeline floor drops to ~750ms — restores headroom for the sales narrative while leaving CPU comfortable. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:53:3. Option B's "still negligible" assertion is unverified at our pinned SHA on a 6-agent fleet. Re-baselining CPU is work we don't need to do this week. If a customer ever asks for it, we can move to Option B without changing the substrate — it's a single config field per agent.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:64:- Add `"pollInterval": 250` to `packages/agents-runtime/_shared/config.json` (the shared agent config base — not yet built; this becomes a Day-2-onwards artefact).
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:82:- **Option β** — Encrypted Hetzner Block Storage Volume only: provision OS disk normally, attach a 50GB encrypted volume, mount the sensitive paths (`/vault/`, `/var/lib/postgresql/`) on it. OS configuration stays unencrypted.
docs/runbooks/day-4-provisioning.md:88:3. OS configuration is reproducible from this runbook — recoverable in <2 hours if the OS disk fails
docs/runbooks/day-4-provisioning.md:96:The runbook configures `maddox` with passwordless sudo. Rationale:
docs/runbooks/day-4-provisioning.md:207:7. Skip "Cloud config" and "Volumes" (volume is created separately in §2.4)
docs/runbooks/day-4-provisioning.md:209:9. Firewalls: skip (UFW configured at OS level in §3.3)
docs/runbooks/day-4-provisioning.md:306:# SSH config: disable root, disable passwords, restrict to maddox
docs/runbooks/day-4-provisioning.md:307:cat > /etc/ssh/sshd_config.d/99-ifos-hardening.conf <<'EOF'
docs/runbooks/day-4-provisioning.md:318:# Validate config before reload (sshd -t exits non-zero on syntax error)
docs/runbooks/day-4-provisioning.md:319:sshd -t || { echo "FATAL: sshd config invalid; do NOT restart sshd"; exit 1; }
docs/runbooks/day-4-provisioning.md:597:# IFOS Day 4 base configuration
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:784:CREATE TABLE tenant_adapters (
docs/runbooks/day-4-provisioning.md:788:  config JSONB NOT NULL DEFAULT '{}'::jsonb,
docs/runbooks/day-4-provisioning.md:795:GRANT SELECT, INSERT, UPDATE, DELETE ON tenant_adapters TO ifos_app;
docs/runbooks/day-4-provisioning.md:796:GRANT USAGE, SELECT ON SEQUENCE tenant_adapters_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:841:# - empty _config.yaml skeleton
docs/runbooks/day-4-provisioning.md:868:# Empty config skeleton
docs/runbooks/day-4-provisioning.md:869:touch "$VAULT_ROOT/_config.yaml"
docs/runbooks/day-4-provisioning.md:908:\d tenant_adapters
docs/runbooks/day-4-provisioning.md:924:If this test fails, runbook execution stops here. RLS misconfiguration is the most consequential failure mode in Day 4 because every downstream agent assumes cross-tenant isolation.
docs/runbooks/day-4-provisioning.md:936:ALTER TABLE tenant_adapters ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:943:ALTER TABLE tenant_adapters FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:971:CREATE POLICY tenant_isolation ON tenant_adapters
docs/runbooks/day-4-provisioning.md:1096:git config user.email "ifos-vault@ifos-v2-prod-01"
docs/runbooks/day-4-provisioning.md:1097:git config user.name "IFOS Vault"
docs/runbooks/day-4-provisioning.md:1127:- [ ] §6.3 — Six tables exist: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:1150:| §3.3 SSH lockout | New maddox SSH session fails after sshd reload | Use the still-open root session to revert `/etc/ssh/sshd_config.d/99-ifos-hardening.conf`, `systemctl reload ssh`, debug |
docs/runbooks/day-4-provisioning.md:1248:17. **§7 — RLS isolation gate passed clean (5 of 5).** No-context = 0 ✓, own-tenant insert+select = 1 ✓, cross-tenant = 0 ✓, WITH CHECK adversarial INSERT rejected ✓, own-tenant unaffected = 1 ✓. RLS + FORCE on entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters (5 tables). `tenant_isolation` policy on all 5 with USING + WITH CHECK on `current_setting('app.current_tenant', true)`. Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser, which would bypass RLS). Test data ROLLBACK'd; 2 seeded test tenants cleaned up.
docs/runbooks/tenant-lifecycle.md:80:mkdir -p /vault/${SLUG}/{_voice,_config,_brand,_playbooks,spot-checks,pending-approvals,wiki/raw}
docs/runbooks/tenant-lifecycle.md:95:# Step 6: Seed _config.yaml
docs/runbooks/tenant-lifecycle.md:96:ssh maddox@${VPS_HOST} "sudo -u ifos_user tee /vault/${SLUG}/_config.yaml" <<EOF
docs/runbooks/tenant-lifecycle.md:171:- **Existing agent re-render** (config or .env changed): `cortextos-ifos bus self-restart <name>` is the surgical reload — picks up new config.json + .env without restarting peer agents
docs/runbooks/tenant-lifecycle.md:197:- PM2 processes stopped but ecosystem config retained
docs/runbooks/tenant-lifecycle.md:250:  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
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
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:441:    "approval_routing": {
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/architecture/vault-concurrency.md:201:**Substrate:** filesystem `stat(2)` mtime check before writing. If the file was modified within the last `DEBOUNCE_THRESHOLD_S` (30s default, configurable per tenant), wait and retry.
docs/architecture/vault-concurrency.md:216:  const DEBOUNCE_THRESHOLD_S = 30; // configurable per tenant via /vault/<tenant>/_config.yaml
docs/architecture/vault-concurrency.md:253:### 4.4 — Tenant configurability
docs/architecture/vault-concurrency.md:255:The 30s default is conservative — tenants whose founders type at human speed (~200 char/min) have natural pauses every 5-10s, so 30s of inactivity reliably indicates "founder has stepped away." Tenants with collaborative editing (multiple humans in Obsidian via sync) may need a longer threshold; setting `debounce_threshold_s: 60` in `/vault/<tenant>/_config.yaml` extends it.
docs/architecture/vault-concurrency.md:423:| Debounce threshold default (30s, configurable per tenant via `_config.yaml`) | §4.2 + §4.4 |
docs/architecture/vault-concurrency.md:447:| `OP_LOCK_TIMEOUT_S` (per-operation flock acquire timeout) | 5 seconds | `/vault/<tenant>/_config.yaml` per-tenant override |
docs/architecture/vault-concurrency.md:448:| `DEBOUNCE_THRESHOLD_S` (Obsidian-edit debounce window) | 30 seconds | `/vault/<tenant>/_config.yaml` per-tenant override |
docs/architecture/vault-concurrency.md:450:| Retry policy on Postgres version-mismatch | 1 retry with 100ms backoff (`OP_RETRY_BACKOFF_MS`) | Hard-coded in v1.0; may surface to per-tenant config in v1.1+ if observed contention requires |
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:64:# Cron config: /etc/cron.daily/ifos-pii-purge
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:141:  '{"pii_retention_days": 180}'::jsonb,
docs/runbooks/pii-purge-operational-pattern.md:144:ON CONFLICT (tenant_slug, adapter_name) DO UPDATE SET config = EXCLUDED.config;
docs/runbooks/pii-purge-operational-pattern.md:161:| Wrong retention configured | Over-aggressive purge: text NULLed prematurely; data lost | Pre-migration backup + dry-run mandatory before any retention reduction |
docs/runbooks/pii-purge-operational-pattern.md:198:| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
packages/harness/cortextos/src/daemon/index.ts:157:    console.error('[daemon] Crash-loop alert: no operator chat configured ' +
packages/harness/cortextos/src/daemon/index.ts:218: * Run via `pm2 start ecosystem.config.js` or `cortextos ecosystem && pm2 start`.
docs/_archive-build-pack/03-ARCHITECTURE.md:13:| **Daemon manager** | PM2 | cortextOS depends on it (`ecosystem.config.js` upstream) |
docs/_archive-build-pack/03-ARCHITECTURE.md:39:├── tsconfig.base.json
docs/_archive-build-pack/03-ARCHITECTURE.md:108:│   └── config/                        (shared TS configs, eslint, etc.)
docs/_archive-build-pack/03-ARCHITECTURE.md:129:│   ├── daemon/                        ← thin wrapper that boots cortextOS with v2 config
docs/_archive-build-pack/03-ARCHITECTURE.md:132:│   │   │   ├── config.ts              (v2 org + agent configuration)
docs/_archive-build-pack/03-ARCHITECTURE.md:134:│   │   └── ecosystem.config.js        (PM2 config — adapted from cortextOS upstream)
docs/_archive-build-pack/03-ARCHITECTURE.md:144:│   ├── pm2/                           (production PM2 config)
docs/operations/goal-option-c-diagnostic-end-to-end.md:118:- `tsconfig.json` + `tsup.config.ts` + `vitest.config.ts`
packages/harness/cortextos/src/daemon/ipc-server.ts:155:  const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/daemon/ipc-server.ts:225:  const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/daemon/ipc-server.ts:308:  const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/diagnostic-generator/src/sections/icp-fit.ts:26:      `Source: [tenant config](vault://${firmSignal.companyNumber ? "target-patch" : "target-patch"})`,
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:3:**How to leverage Claude Code's features specifically for the Intel Force on cortextOS build. Skills, sub-agents, MCP servers, scheduled agents, project memory, slash commands. Each item below is concrete: when to use it, how to configure it, why it pays off for *this* build.**
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:79:## 3. MCP servers — already configured, more to add
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:81:### 3.1 Already configured (in `/Users/madsadmin/code/intel-force-os/.claude/settings.json`)
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:291:- Doesn't configure remote orchestration (Anthropic Console agent fleets) — out of scope for this build
docs/operations/seedlegals-engagement-queries.md:141:3. **If retention period is NOT 90 days:** update default in `scripts/ifos-pii-purge.sh` + the `pii_retention_days` in `docs/runbooks/pii-purge-operational-pattern.md` §2
packages/diagnostic-generator/vitest.config.ts:1:import { defineConfig } from "vitest/config";
packages/agent-renderer/tests/fixtures/test-agent/config.schema.json:4:  "title": "test-agent config",
packages/agent-renderer/tests/fixtures/test-agent/config.schema.json:5:  "description": "Minimal config schema for renderer test fixture.",
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
docs/operations/goal-week-3-polish-and-scaffold.md:369:- **§4 Workflow:** ~14 steps. Cron daily 06:00 UTC. Fetch open invoices (Xero/QB/Sage rotation per tenant config) → fetch bank transactions (Open Banking) → match invoices ↔ deposits → identify unmatched + overdue → generate chase drafts → write reconciliation rows → weekly report assembly (Mondays).
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
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
docs/_archive-build-pack/04-DATA-MODEL.md:269:│   ├── config.json
docs/_archive-build-pack/04-DATA-MODEL.md:379:For dev / small scale: single daemon, multi-org config inside cortextOS. Production: per-tenant process.
docs/_archive-build-pack/04-DATA-MODEL.md:394:   - Agent config → JSON
docs/_archive-build-pack/04-DATA-MODEL.md:404:   - Daemon reads org config, creates Orchestrator + Specialist agent PTY sessions
packages/harness/cortextos/src/bus/catalog.ts:522:          error: 'no upstream remote configured',
packages/harness/cortextos/src/bus/catalog.ts:533:          error: 'no origin remote configured',
packages/harness/cortextos/templates/orchestrator/TOOLS.md:146:- Or use Playwright MCP if configured
packages/harness/cortextos/templates/orchestrator/TOOLS.md:156:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/src/bus/approval.ts:37: * "not configured" — a bug that hid for hours because of the silent
packages/harness/cortextos/src/bus/approval.ts:46: * "not configured" signal (postActivity returns false) is now logged as
packages/harness/cortextos/src/bus/approval.ts:48: * misconfiguration immediately instead of debugging it silently.
packages/harness/cortextos/templates/orchestrator/CLAUDE.md:211:| `config.json` | Crons, max_session_seconds, agent config |
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
docs/_archive-build-pack/05-MIGRATION-MAP.md:138:| PM2 ecosystem config | ADAPT | `ecosystem.config.js` | `infra/pm2/ecosystem.config.js` — adapted with v2 paths |
docs/_archive-build-pack/05-MIGRATION-MAP.md:139:| Test infra (Vitest + Playwright configs) | REFERENCE | `vitest.config.ts`, `playwright.config.ts` | v2 has its own configs; cortextOS's stays in the vendored copy |
docs/_archive-build-pack/05-MIGRATION-MAP.md:184:| `sync-org-config.sh` | KEEP | cortextOS-native |
docs/_archive-build-pack/05-MIGRATION-MAP.md:248:| Per-tenant PM2 spawn logic | `infra/pm2/ecosystem.config.js` (adapted) | Per-tenant process model |
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
packages/harness/cortextos/src/bus/message.ts:16: * Load the shared bus signing key from config.
packages/harness/cortextos/src/bus/message.ts:20:  const keyPath = join(ctxRoot, 'config', 'bus-signing-key');
packages/harness/cortextos/src/bus/metrics.ts:104:  const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/bus/metrics.ts:336:    return { status: 'error', error: 'no upstream remote configured', hint: 'Run: git remote add upstream <canonical-repo-url>' };
packages/harness/cortextos/dashboard/src/lib/markdown-parser.ts:1:// cortextOS Dashboard - Markdown parser for agent config files
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
packages/harness/cortextos/src/bus/system.ts:379: * Returns false if not configured (silent fail — callers can ignore the
packages/harness/cortextos/src/bus/system.ts:403:  let configPath: string | null = null;
packages/harness/cortextos/src/bus/system.ts:406:      configPath = candidate;
packages/harness/cortextos/src/bus/system.ts:411:  if (!configPath) {
packages/harness/cortextos/src/bus/system.ts:420:    const content = readFileSync(configPath, 'utf-8');
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
packages/agent-renderer/tests/unit/fileMap.test.ts:10:  it("has the synthesis triple (CLAUDE.md + config.json + .env)", () => {
packages/agent-renderer/tests/unit/fileMap.test.ts:15:    expect(targets).toEqual([".env", "CLAUDE.md", "config.json"]);
packages/agent-renderer/tests/unit/fileMap.test.ts:50:    expect(required).toEqual(["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"]);
packages/harness/cortextos/dashboard/src/lib/sync.ts:15:} from './config';
packages/harness/cortextos/dashboard/src/lib/sync.ts:313:    const enabledFile = path.join(CTX_ROOT, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/lib/sync.ts:316:      for (const [name, config] of Object.entries(enabled)) {
packages/harness/cortextos/dashboard/src/lib/sync.ts:317:        const agentOrg = (config as Record<string, string>).org ?? '';
packages/agent-renderer/tests/unit/preflight.test.ts:30:  for (const f of ["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"]) {
packages/harness/cortextos/dashboard/src/middleware.ts:10:// Allowed CORS origins - localhost dev + configured deployment URL + mobile app
packages/harness/cortextos/dashboard/src/middleware.ts:104:          { error: 'Server misconfiguration: auth secret not configured' },
packages/harness/cortextos/dashboard/src/middleware.ts:147:export const config = {
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
packages/harness/cortextos/dashboard/src/lib/auth.ts:1:// cortextOS Dashboard - NextAuth v5 configuration
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:5: * `/loop` and to edit `config.json` for cron registration.  After that
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:96:    name: '(configured in config.json)',
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:97:    match: (line) => /\(configured in config\.json\)/.test(line),
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:99:      "Replace with '(configured via cortextos bus add-cron)'. config.json is no longer the cron source of truth.",
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:102:    name: 'edit config.json (cron context)',
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:104:      /\bconfig\.json\b/.test(line) &&
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:108:      "config.json no longer holds crons. Use 'cortextos bus add-cron' (the daemon owns crons.json directly).",
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:136:    from: /\(configured in config\.json\)/g,
packages/harness/cortextos/src/utils/cron-teaching-scanner.ts:137:    to: '(configured via cortextos bus add-cron)',
packages/harness/cortextos/src/cli/enable-agent.ts:11: *   1. CTX_FRAMEWORK_ROOT env var (explicit, set by ecosystem.config.js)
packages/harness/cortextos/src/cli/enable-agent.ts:50:  return join(homedir(), '.cortextos', instanceId, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/enable-agent.ts:117:  const dir = join(homedir(), '.cortextos', instanceId, 'config');
packages/harness/cortextos/src/cli/enable-agent.ts:187:    // bot-recipient configs, and the self_chat trap (CHAT_ID == bot's own
packages/harness/cortextos/src/cli/enable-agent.ts:188:    // user id) BEFORE the agent boots up on a silently broken config. Without
packages/harness/cortextos/src/cli/enable-agent.ts:193:    // Hard-fails on config-level reasons (bad_token, chat_not_found,
packages/harness/cortextos/src/cli/enable-agent.ts:226:      status: 'configured',
packages/harness/cortextos/dashboard/src/lib/comms-identity.ts:8: * Telegram is configured, and serves as the anchor for pair key
packages/harness/cortextos/dashboard/src/lib/comms-identity.ts:38:  const configPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/lib/comms-identity.ts:39:  if (fs.existsSync(configPath)) {
packages/harness/cortextos/dashboard/src/lib/comms-identity.ts:41:      const data = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
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
packages/harness/cortextos/src/cli/list-skills.ts:94:    // Template-level skills (detect role from config.json)
packages/harness/cortextos/src/cli/list-skills.ts:97:        const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/src/cli/list-skills.ts:98:        if (existsSync(configPath)) {
packages/harness/cortextos/src/cli/list-skills.ts:99:          const config = JSON.parse(readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/src/cli/list-skills.ts:100:          const role = config.template || '';
packages/harness/cortextos/src/cli/list-skills.ts:109:        // Ignore config read errors
packages/harness/cortextos/templates/orchestrator/HEARTBEAT.md:172:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/src/cli/index.ts:22:import { getConfigCommand } from './get-config.js';
packages/agent-renderer/tests/unit/synthesis.test.ts:7:import { synthesiseConfigJson, ConfigSynthesisError } from "../../src/synthesis/configJson.js";
packages/agent-renderer/tests/unit/synthesis.test.ts:80:describe("synthesis/configJson", () => {
packages/agent-renderer/tests/unit/synthesis.test.ts:81:  it("materialises config.json with bundle + common defaults applied", () => {
packages/agent-renderer/tests/unit/synthesis.test.ts:108:    writeFileSync(join(ctx.bundleDir, "config.schema.json"), JSON.stringify(brokenSchema));
packages/harness/cortextos/dashboard/eslint.config.mjs:1:import { defineConfig, globalIgnores } from "eslint/config";
packages/harness/cortextos/dashboard/eslint.config.mjs:2:import nextVitals from "eslint-config-next/core-web-vitals";
packages/harness/cortextos/dashboard/eslint.config.mjs:3:import nextTs from "eslint-config-next/typescript";
packages/harness/cortextos/dashboard/eslint.config.mjs:8:  // Override default ignores of eslint-config-next.
packages/harness/cortextos/dashboard/eslint.config.mjs:10:    // Default ignores of eslint-config-next:
packages/harness/cortextos/src/cli/uninstall.ts:10:  .option('--keep-state', 'Remove agent config but preserve state directory (logs, tasks, heartbeats)')
packages/harness/cortextos/src/cli/uninstall.ts:24:      console.log('  Mode: --keep-state (preserving state directory, removing agent config only)\n');
packages/harness/cortextos/src/cli/uninstall.ts:53:      // --keep-state: remove only enabled-agents config, preserve all state data
packages/harness/cortextos/src/cli/uninstall.ts:54:      const enabledFile = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/uninstall.ts:72:    // Remove ecosystem.config.js if exists in current directory
packages/harness/cortextos/src/cli/uninstall.ts:73:    const ecosystemPath = join(process.cwd(), 'ecosystem.config.js');
packages/harness/cortextos/src/cli/uninstall.ts:77:        console.log('  Removed ecosystem.config.js');
packages/harness/cortextos/src/utils/org.ts:15: * MMRAG config.json that then haunted dashboard sync forever.
packages/harness/cortextos/src/pty/output-buffer.ts:34:   * Also streams to log file if configured.
packages/harness/cortextos/src/pty/output-buffer.ts:98:   * For Hermes: looks for the "❯" prompt character (configurable via constructor).
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
packages/harness/cortextos/templates/orchestrator/.claude/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/templates/orchestrator/.claude/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/templates/orchestrator/.claude/skills/onboarding/SKILL.md:45:| Crons configured and running | `config.json` |
packages/harness/cortextos/src/cli/install.ts:344:      join(ctxRoot, 'config'),
packages/harness/cortextos/src/cli/install.ts:363:    const enabledPath = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/install.ts:382:    const signingKeyPath = join(ctxRoot, 'config', 'bus-signing-key');
packages/harness/cortextos/src/cli/install.ts:447:    console.log('    3. cortextos ecosystem && pm2 start ecosystem.config.js');
packages/mcp-connectors/companies-house/vitest.config.ts:1:import { defineConfig } from "vitest/config";
packages/harness/cortextos/dashboard/components.json:7:    "config": "",
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
packages/harness/cortextos/src/pty/hermes-pty.ts:35:  constructor(env: CtxEnv, config: AgentConfig, logPath?: string) {
packages/harness/cortextos/src/pty/hermes-pty.ts:36:    super(env, config, logPath, HERMES_BOOTSTRAP_PATTERN);
packages/harness/cortextos/src/pty/hermes-pty.ts:38:    this.agentDir = config.working_directory || env.agentDir;
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
packages/harness/cortextos/dashboard/src/lib/data/organization.ts:5:import { getOrgContextPath, getOrgBrandVoicePath } from '@/lib/config';
packages/harness/cortextos/src/cli/init.ts:157:              `**Dashboard:** ${ctx.dashboard_url || '(not configured)'}`,
packages/harness/cortextos/dashboard/package.json:50:    "eslint-config-next": "16.2.1",
packages/harness/cortextos/src/utils/paths.ts:12: *     config/                - enabled-agents.json
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
packages/agent-renderer/pnpm-lock.yaml:822:  lilconfig@3.1.3:
packages/agent-renderer/pnpm-lock.yaml:829:  load-tsconfig@0.2.5:
packages/agent-renderer/pnpm-lock.yaml:881:  postcss-load-config@6.0.1:
packages/agent-renderer/pnpm-lock.yaml:1467:      load-tsconfig: 0.2.5
packages/agent-renderer/pnpm-lock.yaml:1616:  lilconfig@3.1.3: {}
packages/agent-renderer/pnpm-lock.yaml:1620:  load-tsconfig@0.2.5: {}
packages/agent-renderer/pnpm-lock.yaml:1665:  postcss-load-config@6.0.1(postcss@8.5.15)(tsx@4.22.3):
packages/agent-renderer/pnpm-lock.yaml:1667:      lilconfig: 3.1.3
packages/agent-renderer/pnpm-lock.yaml:1773:      postcss-load-config: 6.0.1(postcss@8.5.15)(tsx@4.22.3)
packages/harness/cortextos/dashboard/src/lib/data/goals.ts:7:import { getGoalsPath } from '@/lib/config';
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:93:Probe each configured external service BEFORE the briefing. Auth failures discovered here get into the briefing as actionable items — not discovered hours later when the user needs the service.
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:122:- **OK or empty results**: note "KB configured"
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:123:- **Not configured warning**: note "KB not configured" (informational, not a failure)
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:131:Services: GCal OK | Notion OK | KB configured
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:135:Services: GCal FAILED (reauth needed — task created) | Notion OK | KB not configured
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
packages/harness/cortextos/src/cli/ecosystem.ts:10:  .option('--output <path>', 'Output file', 'ecosystem.config.js')
packages/harness/cortextos/src/cli/ecosystem.ts:11:  .description('Generate PM2 ecosystem.config.js from agent configs')
packages/harness/cortextos/src/cli/ecosystem.ts:68:    // BUG-002 fix: emit ecosystem.config.js as raw JS that resolves
packages/harness/cortextos/src/cli/ecosystem.ts:114:      // Dashboard reads its real config from dashboard/.env.local — populated
packages/harness/cortextos/src/types/index.ts:104:  display_name?: string; // user-configured name from IDENTITY.md (e.g. "Alpha", "Beta")
packages/harness/cortextos/src/types/index.ts:139:// Agent Config Types (config.json)
packages/harness/cortextos/src/types/index.ts:758:  display_name?: string;  // user-configured name from IDENTITY.md (e.g. "Alpha", "Beta")
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:2:// Discovers agents, reads identity/config files, returns typed agent data
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:13:} from '@/lib/config';
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:30: * Read agent config.json and extract runtime ("claude-code" | "codex-app-server"
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:37:    const raw = await fs.readFile(path.join(agentDir, 'config.json'), 'utf-8');
packages/harness/cortextos/dashboard/src/lib/data/agents.ts:43:    // missing/malformed config — fall through to default
packages/harness/cortextos/dashboard/src/lib/data/reports.ts:5:// Resolve CTX_ROOT without importing from config (avoids turbopack chunk issues)
packages/harness/cortextos/src/cli/doctor.ts:233:      } catch { /* no config yet */ }
packages/harness/cortextos/src/cli/doctor.ts:265:          message: 'Not configured',
packages/harness/cortextos/src/cli/import-agent.ts:109:    // Write a clean config.json for the full cortextOS agent
packages/harness/cortextos/src/cli/import-agent.ts:130:    writeFileSync(join(targetAgentDir, 'config.json'), JSON.stringify(fullConfig, null, 2) + '\n', 'utf-8');
packages/harness/cortextos/src/cli/import-agent.ts:157:    const enabledPath = join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/src/cli/import-agent.ts:164:    enabledAgents[agentName] = { enabled: true, status: 'configured', org };
packages/harness/cortextos/src/cli/import-agent.ts:165:    mkdirSync(join(ctxRoot, 'config'), { recursive: true });
packages/harness/cortextos/src/cli/import-agent.ts:215:  const configPath = join(agentDir, 'config.json');
packages/harness/cortextos/src/cli/import-agent.ts:216:  if (!existsSync(configPath)) return null;
packages/harness/cortextos/src/cli/import-agent.ts:217:  try { return JSON.parse(readFileSync(configPath, 'utf-8')); } catch { return null; }
packages/harness/cortextos/src/cli/restart.ts:8:  .description('Restart a running agent (stop + start). Re-reads config.json and .env, respawns the PTY. Does NOT restart the daemon process itself — use `pm2 restart cortextos-daemon` for that.')
packages/harness/cortextos/src/cli/restart.ts:31:    // Start phase — daemon's start-agent handler re-reads config.json + .env
packages/harness/cortextos/src/cli/restart.ts:33:    // when the daemon is already running, so env reload / config re-read /
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:13:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:20:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:39:- Measure the metric using the configured measurement method
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:60:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:107:- **approval_routing_speed** — quantitative: minutes from approval created to user Telegram notification (computed from event log timestamps)
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:156:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/src/cli/get-config.ts:5:export const getConfigCommand = new Command('get-config')
packages/harness/cortextos/src/cli/get-config.ts:6:  .description('Show resolved operational config for an agent (org defaults + agent overrides)')
packages/harness/cortextos/src/cli/get-config.ts:33:      const agentCfgPath = join(frameworkRoot, 'orgs', org, 'agents', agentName, 'config.json');
packages/harness/cortextos/src/cli/get-config.ts:37:        // --agent was explicitly passed but no config found — warn, don't exit
packages/harness/cortextos/src/cli/get-config.ts:38:        process.stderr.write(`Warning: agent config not found at ${agentCfgPath}, showing org defaults only\n`);
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
packages/harness/cortextos/dashboard/src/lib/data/heartbeats.ts:6:import { CTX_ROOT, getHeartbeatPath } from '@/lib/config';
packages/harness/cortextos/community/catalog.json:235:      "description": "First-boot onboarding wizard — guides new agents through identity setup, Telegram configuration, and first session startup",
packages/harness/cortextos/community/catalog.json:239:      "tags": ["onboarding", "setup", "first-boot", "configuration"],
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
packages/harness/cortextos/src/cli/setup.ts:9: *   5. Ecosystem config generation + daemon start
packages/harness/cortextos/src/cli/setup.ts:202:  .description('Interactive first-run setup wizard — install, create org, configure agents, start daemon')
packages/harness/cortextos/src/cli/setup.ts:413:    console.log('  Step 5: Generating ecosystem config and starting daemon...\n');
packages/harness/cortextos/src/cli/setup.ts:423:      console.error('  Failed to generate ecosystem config. Run manually: cortextos ecosystem');
packages/harness/cortextos/src/cli/setup.ts:426:      const pm2Result = spawnSync('pm2', ['start', 'ecosystem.config.js'], {
packages/harness/cortextos/community/skills/delegation-matrix/SKILL.md:10:> Reference when scoping any task. Dividing line: **execution-heavy → Codex (if configured as implementer). Judgment-heavy → Agent always.**
packages/harness/cortextos/community/skills/delegation-matrix/SKILL.md:12:Codex is a configurable option. Pick the mode that matches your setup:
packages/harness/cortextos/community/skills/delegation-matrix/SKILL.md:67:For **one-liners and config changes**: Agent writes directly in all modes.
packages/harness/cortextos/community/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/community/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/community/skills/onboarding/SKILL.md:16:Read `config.json` to find your runtime — it determines where your skills live, which slash-commands exist, and which env vars matter.
packages/harness/cortextos/community/skills/onboarding/SKILL.md:19:RUNTIME=$(grep -o '"runtime"[[:space:]]*:[[:space:]]*"[^"]*"' config.json | sed -E 's/.*"runtime"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
packages/harness/cortextos/community/skills/onboarding/SKILL.md:67:| Crons configured and running | `config.json` |
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
packages/harness/cortextos/templates/orchestrator/.claude/skills/worker-agents/SKILL.md:37:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/bus/sync-org-config.sh:2:# sync-org-config.sh — push org config updates to all running agents
packages/harness/cortextos/bus/sync-org-config.sh:3:# Usage: CTX_ORG=<org> bash sync-org-config.sh [--org <org>]
packages/harness/cortextos/bus/sync-org-config.sh:42:ENABLED_AGENTS_FILE="${CTX_ROOT}/config/enabled-agents.json"
packages/harness/cortextos/bus/sync-org-config.sh:69:  # Update agent's config.json with org values
packages/harness/cortextos/bus/sync-org-config.sh:70:  AGENT_CFG="${CTX_FRAMEWORK_ROOT}/orgs/${ORG}/agents/${AGENT_NAME}/config.json"
packages/harness/cortextos/bus/sync-org-config.sh:121:        "Org config updated by ${SOURCE}. Re-read config.json and apply new operational settings at your next heartbeat cycle." \
packages/harness/cortextos/bus/sync-org-config.sh:124:      echo "WARNING: Failed to update config for agent '${AGENT_NAME}' — skipping" >&2
packages/harness/cortextos/bus/sync-org-config.sh:129:echo "Notified ${COUNT} agents of org config update"
packages/harness/cortextos/templates/orchestrator/.claude/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
packages/harness/cortextos/templates/orchestrator/.claude/skills/env-management/SKILL.md:4:triggers: ["add key", "api key", "env file", ".env", "secret", "credential", "token", "environment variable", "configure key", "set key", "missing key", "key not set", "where do I put", "shared secret", "org secret", "agent secret", "key not loading", "configure credentials", "new api key", "add to env", "rotate key", "rotate token", "key compromised", "token expired", "update api key", "new bot token", "revoke key", "credential rotation", "key rotation", "secret rotation", "key was leaked", "compromised credential", "force rotation", "provider rotated", "expired key", "rotate credentials", "update secret"]
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:31:    it('dashboard has Next.js config', () => {
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:32:      const nextConfig = join(__dirname, '..', 'dashboard', 'next.config.ts');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:64:      // Dashboard reads: config/enabled-agents.json
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:65:      const configDir = join(ctxRoot, 'config');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:66:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:69:        sentinel: { enabled: true, status: 'configured', org: 'acme' },
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:70:        analyst: { enabled: true, status: 'configured', org: 'acme' },
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:72:      writeFileSync(join(configDir, 'enabled-agents.json'), JSON.stringify(enabledAgents, null, 2), 'utf-8');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:74:      const parsed = JSON.parse(readFileSync(join(configDir, 'enabled-agents.json'), 'utf-8'));
packages/harness/cortextos/templates/orchestrator/.claude/skills/knowledge-base/SKILL.md:66:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
packages/harness/cortextos/bus/kb-setup.sh:81:# Create mmrag config.json if it doesn't exist (mmrag.py requires it to exist)
packages/harness/cortextos/bus/kb-setup.sh:82:CONFIG_FILE="$KB_ROOT/config.json"
packages/harness/cortextos/bus/kb-setup.sh:95:  echo "  [OK] mmrag config.json created"
packages/harness/cortextos/bus/kb-setup.sh:97:  echo "  [OK] mmrag config.json already exists"
packages/harness/cortextos/bus/kb-ingest.sh:98:# Ensure config.json exists (run setup if missing)
packages/harness/cortextos/bus/kb-ingest.sh:99:CONFIG_FILE="$KB_ROOT/config.json"
packages/harness/cortextos/tests/sprint3-experiments.test.ts:67:    it('inherits measurement/direction/window/surface from a matching cycle in config.json', () => {
packages/harness/cortextos/tests/sprint3-experiments.test.ts:68:      // Write an experiments/config.json with a cycle for this metric.
packages/harness/cortextos/tests/sprint3-experiments.test.ts:71:        join(testDir, 'experiments', 'config.json'),
packages/harness/cortextos/tests/sprint3-experiments.test.ts:106:        join(testDir, 'experiments', 'config.json'),
packages/harness/cortextos/tests/sprint3-experiments.test.ts:143:        join(testDir, 'experiments', 'config.json'),
packages/harness/cortextos/tests/sprint3-experiments.test.ts:374:      // Verify config.json was written
packages/harness/cortextos/tests/sprint3-experiments.test.ts:375:      const configPath = join(testDir, 'experiments', 'config.json');
packages/harness/cortextos/tests/sprint3-experiments.test.ts:376:      expect(existsSync(configPath)).toBe(true);
packages/harness/cortextos/templates/orchestrator/.claude/skills/heartbeat/SKILL.md:15:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/bus/kb-query.sh:109:export MMRAG_CONFIG="$KB_ROOT/config.json"
packages/mcp-connectors/companies-house/pnpm-lock.yaml:772:  lilconfig@3.1.3:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:779:  load-tsconfig@0.2.5:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:831:  postcss-load-config@6.0.1:
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1398:      load-tsconfig: 0.2.5
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1535:  lilconfig@3.1.3: {}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1539:  load-tsconfig@0.2.5: {}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1584:  postcss-load-config@6.0.1(postcss@8.5.15)(tsx@4.22.3):
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1586:      lilconfig: 3.1.3
packages/mcp-connectors/companies-house/pnpm-lock.yaml:1690:      postcss-load-config: 6.0.1(postcss@8.5.15)(tsx@4.22.3)
packages/harness/cortextos/dashboard/src/lib/config.ts:164:  // Check framework root (where agent identity/config files live)
packages/harness/cortextos/dashboard/src/lib/config.ts:184:  const enabledFile = path.join(CTX_ROOT, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/lib/config.ts:188:      for (const [name, config] of Object.entries(data)) {
packages/harness/cortextos/dashboard/src/lib/config.ts:189:        const cfg = config as { enabled?: boolean; org?: string };
packages/harness/cortextos/dashboard/src/lib/config.ts:214:  return path.join(CTX_ROOT, 'config', 'allowed-roots.json');
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:225:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:240:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:249:console.log('MCP config updated');
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:252:# 2. Worker must restart to pick up MCP config
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:255:  'MCP config updated at .claude/settings.json. Please restart your session with --continue to pick it up, then test Playwright by taking a screenshot of google.com.'
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:261:1. Install/configure it in the project directory
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:264:4. If failed: fix config, repeat
packages/harness/cortextos/bus/hook-permission-telegram.sh:27:    echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","message":"No Telegram credentials configured for remote approval"}}}'
packages/harness/cortextos/bus/hook-permission-telegram.sh:38:# Auto-approve .claude/ directory writes - agents need to modify their own configs at runtime
packages/harness/cortextos/dashboard/src/lib/actions/skills.ts:6:import { getFrameworkRoot, CTX_ROOT, getOrgs, getAgentsForOrg } from '@/lib/config';
packages/harness/cortextos/tests/e2e/mock-codex.js:30: *   - `skills/list` request returning a configurable fixture
packages/harness/cortextos/dashboard/src/lib/actions/approvals.ts:6:import { getFrameworkRoot, getCTXRoot } from '@/lib/config';
packages/harness/cortextos/templates/orchestrator/.claude/skills/bus-reference/SKILL.md:228:- **chat_id** (required): Telegram chat ID (available in config)
packages/harness/cortextos/templates/orchestrator/.claude/skills/bus-reference/SKILL.md:461:- **Usage**: Write Python scripts using `from playwright.sync_api import sync_playwright` or use Playwright MCP if configured
packages/harness/cortextos/templates/orchestrator/.claude/skills/bus-reference/SKILL.md:462:- **Env**: Service credentials available via environment variables if configured
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:40:| Config | config.json | Extract crons + approval rules |
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:108:- Any autonomy rules the user explicitly configured
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:112:### config.json → extract crons
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:276:| config.json crons | Selectively | Port user-defined schedules, update paths |
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:287:- If the source workspace has custom tools or MCP configs, check with user whether to port them
packages/harness/cortextos/bus/kb-collections.sh:57:export MMRAG_CONFIG="$KB_ROOT/config.json"
packages/harness/cortextos/community/skills/community-publish/SKILL.md:78:Requires `ecosystem.community_publish.enabled: true` in config.json.
packages/harness/cortextos/community/skills/community-publish/SKILL.md:82:- User must have a fork of the cortextOS repo configured as `origin`
packages/harness/cortextos/tests/e2e/lifecycle-codex.test.ts:172:  it('skills/list returns the configured fixture and is keyed by cwd', async () => {
packages/harness/cortextos/dashboard/src/lib/actions/goals.ts:6:import { getFrameworkRoot, getOrgs } from '@/lib/config';
packages/harness/cortextos/bus/_ctx-env.sh:65:# Falls back to system timezone if not configured.
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
packages/harness/cortextos/community/skills/catalog-browse/SKILL.md:14:- Weekly cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/community/skills/catalog-browse/SKILL.md:63:Requires `ecosystem.catalog_browse.enabled: true` in config.json.
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
packages/harness/cortextos/dashboard/postcss.config.mjs:1:const config = {
packages/harness/cortextos/dashboard/postcss.config.mjs:7:export default config;
packages/harness/cortextos/dashboard/src/lib/watcher.ts:7:import { CTX_ROOT, getOrgs } from './config';
packages/harness/cortextos/README.md:72:Onboarding handles everything: dependency checks, org setup, bot creation, PM2 config, and dashboard launch. Your Orchestrator comes online in Telegram and finishes its own setup there.
packages/harness/cortextos/README.md:89:cortextos ecosystem                        # Generate PM2 config
packages/harness/cortextos/README.md:90:pm2 start ecosystem.config.js && pm2 save && pm2 startup
packages/harness/cortextos/README.md:131:Every agent's `config.json` carries an explicit `runtime` field that the daemon dispatches on. Valid values:
packages/harness/cortextos/README.md:137:| `hermes` | `HermesPTY` (experimental) | model per `config.json` | hermes-specific |
packages/harness/cortextos/README.md:139:Pass `--runtime <kind>` on `add-agent` to set it at scaffold time, or edit the field in `config.json` and restart the agent. The default is `claude-code`. Today only `--template agent` (and the alias `--template agent-codex`) supports `--runtime codex-app-server` — pairing the codex runtime with `--template orchestrator`/`analyst`/`m2c1-worker`/`hermes` errors with a clean message until codex variants of those templates ship.
packages/harness/cortextos/README.md:150:cortextos ecosystem          # Generate PM2 config
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser-codex.test.ts:35:  const cfgDir = path.join(tmpDir, 'config');
packages/harness/cortextos/templates/orchestrator/.claude/skills/weekly-review/SKILL.md:11:**When:** Sunday evening (configured in cron) or when user requests.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/delegation-matrix/SKILL.md:10:> Reference when scoping any task. Dividing line: **execution-heavy → Codex (if configured as implementer). Judgment-heavy → Agent always.**
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/delegation-matrix/SKILL.md:12:Codex is a configurable option. Pick the mode that matches your setup:
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/delegation-matrix/SKILL.md:67:For **one-liners and config changes**: Agent writes directly in all modes.
packages/harness/cortextos/dashboard/src/components/settings/allowed-roots-tab.tsx:121:              No additional allowed roots configured. By default, the dashboard can only serve files from{' '}
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:7:// We rely on vitest running this file fresh (no prior config.ts cache).
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:11:// Dynamic imports so CTX_ROOT is set before config.ts evaluates
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:39:  const configMod = await import('../config');
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:40:  CTX_ROOT = configMod.CTX_ROOT;
packages/harness/cortextos/community/skills/worker-agents/SKILL.md:38:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser.test.ts:19:  const cfgDir = path.join(tmpDir, 'config');
packages/harness/cortextos/dashboard/src/lib/cost-parser.ts:9:import { CTX_ROOT, getAgentsForOrg, getAllAgents, getOrgs } from '@/lib/config';
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:340:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:361:1. Install/configure it in the project directory
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:364:4. If failed: fix config, repeat
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
packages/harness/cortextos/install.mjs:412:    ok('"upstream" remote configured (tracks canonical cortextOS)');
packages/harness/cortextos/install.mjs:414:    warn('Could not configure upstream remote — run manually: git remote rename origin upstream');
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:20:  const [configs, setConfigs] = useState<TelegramConfig[]>([]);
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:95:        {configs.length === 0 ? (
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:97:            No Telegram configurations found. Add TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:98:            to agent .env files to configure Telegram notifications.
packages/harness/cortextos/dashboard/src/components/settings/telegram-tab.tsx:112:              {configs.map((c) => {
packages/harness/cortextos/community/skills/knowledge-base/SKILL.md:67:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:12:  const [config, setConfig] = useState<SystemConfig>({
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:35:    const result = await saveSystemConfig(config);
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:63:            value={config.heartbeatStalenessThreshold}
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:83:            value={config.maxCrashesPerDay}
packages/harness/cortextos/dashboard/src/components/settings/system-tab.tsx:103:            value={config.sessionRefreshInterval}
packages/harness/cortextos/templates/analyst/TOOLS.md:158:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
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
packages/harness/cortextos/dashboard/src/app/(dashboard)/analytics/page.tsx:1:import { getOrgs } from '@/lib/config';
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
packages/harness/cortextos/templates/analyst/CLAUDE.md:131:If `ecosystem.local_version_control.enabled` is true in your config.json, run the daily snapshot at the configured time:
packages/harness/cortextos/templates/analyst/CLAUDE.md:151:If `ecosystem.upstream_sync.enabled` is true in your config.json, check for framework updates on your configured schedule:
packages/harness/cortextos/templates/analyst/CLAUDE.md:178:If `ecosystem.catalog_browse.enabled` is true in your config.json, scan the catalog on your configured schedule:
packages/harness/cortextos/templates/analyst/CLAUDE.md:192:If `ecosystem.community_publish.enabled` is true in your config.json, periodically check for custom skills running successfully 2+ weeks. If user agrees to share:
packages/harness/cortextos/templates/analyst/CLAUDE.md:221:   > "Your new agent is booting up! Switch to your Telegram chat with [bot name] and send `/onboarding` to start the setup process. The agent will walk you through configuring its identity, goals, and workflows."
packages/harness/cortextos/templates/analyst/CLAUDE.md:257:| `config.json` | Crons, max_session_seconds, agent config |
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
packages/harness/cortextos/templates/agent/TOOLS.md:158:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:4:description: "Framework protocol for responding to Claude Max API usage thresholds. Three-tier wind-down and recovery. Agent-specific behavior belongs in deployment config, not here."
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:11:> Agent-specific behavior at each tier belongs in your deployment's CLAUDE.md or config.json.
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:128:**Your deployment config should define:**
packages/harness/cortextos/tests/sprint7-environment.test.ts:79:    it('supports full agent config format', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:80:      const config = {
packages/harness/cortextos/tests/sprint7-environment.test.ts:83:          status: 'configured',
packages/harness/cortextos/tests/sprint7-environment.test.ts:90:          status: 'configured',
packages/harness/cortextos/tests/sprint7-environment.test.ts:102:      writeFileSync(path, JSON.stringify(config, null, 2), 'utf-8');
packages/harness/cortextos/tests/sprint7-environment.test.ts:125:  describe('Loop interval from config.json', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:127:      const config = {
packages/harness/cortextos/tests/sprint7-environment.test.ts:134:      const path = join(testDir, 'config.json');
packages/harness/cortextos/tests/sprint7-environment.test.ts:135:      writeFileSync(path, JSON.stringify(config), 'utf-8');
packages/harness/cortextos/community/skills/morning-review/SKILL.md:94:Probe each configured external service BEFORE the briefing. Auth failures discovered here get into the briefing as actionable items — not discovered 3 hours later when the user needs the service.
packages/harness/cortextos/community/skills/morning-review/SKILL.md:123:- **OK or empty results**: note "KB configured"
packages/harness/cortextos/community/skills/morning-review/SKILL.md:124:- **Not configured warning**: note "KB not configured" (informational, not a failure)
packages/harness/cortextos/community/skills/morning-review/SKILL.md:132:Services: GCal OK | Notion OK | KB configured
packages/harness/cortextos/community/skills/morning-review/SKILL.md:136:Services: GCal FAILED (reauth needed — task created) | Notion OK | KB not configured
packages/harness/cortextos/dashboard/src/app/(dashboard)/page.tsx:2:import { getOrgs } from '@/lib/config';
packages/harness/cortextos/scripts/install-windows-pm2-startup.ps1:71:# admin rights / SYSTEM-level service config; Task Scheduler runs under your
packages/harness/cortextos/tests/sprint4-catalog.test.ts:251:      writeFileSync(join(sourceDir, 'config.ts'), 'const email = "user@example.com"', 'utf-8');
packages/harness/cortextos/dashboard/src/app/(dashboard)/skills/page.tsx:3:import { getAllAgents } from '@/lib/config';
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:14:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:21:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:40:- Measure the metric using the configured measurement method
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:61:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:137:# Update approval setting in config if needed (default is true)
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:157:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/templates/agent/CLAUDE.md:179:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:108:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:226:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:241:# 1. Create or update the worker's MCP config
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:250:console.log('MCP config updated');
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:253:# 2. Worker must restart to pick up MCP config
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:256:  'MCP config updated at .claude/settings.json. Please restart your session with --continue to pick it up, then test Playwright by taking a screenshot of google.com.'
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:262:1. Install/configure it in the project directory
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:265:4. If failed: fix config, repeat
packages/harness/cortextos/templates/agent/HEARTBEAT.md:141:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
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
packages/harness/cortextos/scripts/self-healing/README.md:24:- A registered Telegram bot for alerts. By default the scripts auto-detect the first enabled orchestrator's bot from `~/.cortextos/<instance>/config/enabled-agents.json`. You can override with `CORTEXTOS_ALERT_BOT_ENV`.
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:93:      it('mentions automatic migration from config.json', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:95:        expect(content).toMatch(/auto.migrat|migrat.*automatic|migrat.*config\.json/i);
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:221:    it('references crons.json or daemon-managed (not just config.json)', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:291:  it('explains config.json is left untouched (non-destructive)', () => {
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:28:The Obsidian CLI writes directly to vault notes. Replace `[VAULT_NAME]` with your configured vault name.
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:121:You can also add a daily cron entry to `config.json` to keep the KB automatically current:
packages/harness/cortextos/dashboard/src/app/(dashboard)/layout.tsx:3:import { getOrgs } from '@/lib/config';
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:3:description: "You need to make a purchase on behalf of the user — buy a SaaS subscription, pay for an API, purchase a domain, or any transaction requiring a credit card. Use this skill to request approval, issue a scoped virtual Visa card via AgentCard, and complete the purchase autonomously. Requires the AgentCard MCP server to be configured."
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:12:Requires: AgentCard MCP server configured via `agent-cards setup-mcp` (CLI: `npm i -g agentcard`).
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
packages/harness/cortextos/templates/agent/.claude/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/templates/agent/.claude/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/templates/agent/.claude/skills/onboarding/SKILL.md:45:| Crons configured and running | `config.json` |
packages/harness/cortextos/templates/agent/.claude/skills/onboarding/SKILL.md:49:| Autoresearch cycle offered | `experiments/config.json` (optional) |
packages/harness/cortextos/dashboard/src/components/analytics/cost-tracking.tsx:92:              <p className="text-sm font-medium">Plan usage tracking not configured</p>
packages/harness/cortextos/dashboard/src/app/(dashboard)/knowledge-base/page.tsx:1:import { getOrgs, getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:61:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:62:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:64:    join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/community/agents/orchestrator/TOOLS.md:144:- Or use Playwright MCP if configured
packages/harness/cortextos/community/agents/orchestrator/TOOLS.md:154:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/community/skills/upstream-sync/SKILL.md:14:- Daily cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/community/skills/upstream-sync/SKILL.md:52:Requires `ecosystem.upstream_sync.enabled: true` in config.json.
packages/harness/cortextos/community/skills/upstream-sync/SKILL.md:58:- NEVER applies during night mode — check day_mode_start/day_mode_end from config.json before proceeding
packages/harness/cortextos/scripts/self-healing/agent-recover.sh:50:enabled_json="$HOME/.cortextos/$INSTANCE/config/enabled-agents.json"
packages/harness/cortextos/dashboard/src/components/analytics/goal-progress.tsx:30:            No goals configured. Visit Strategy to set goals.
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:74:      'Use CronCreate to register a cron.\n(configured in config.json)\n');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:78:    expect(stdout).toContain('(configured in config.json)');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:85:    expect(after).toContain('(configured in config.json)');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:90:      'Heartbeat (configured in config.json).\nUse CronCreate to register.\n');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:93:    expect(after).toContain('(configured via cortextos bus add-cron)');
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:94:    expect(after).not.toContain('(configured in config.json)');
packages/harness/cortextos/community/agents/orchestrator/CLAUDE.md:214:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/templates/analyst/.claude/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/templates/analyst/.claude/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/templates/analyst/.claude/skills/onboarding/SKILL.md:45:| Crons configured and running | `config.json` |
packages/harness/cortextos/community/agents/agent/TOOLS.md:144:- Or use Playwright MCP if configured
packages/harness/cortextos/community/agents/agent/TOOLS.md:154:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/dashboard/src/app/(dashboard)/agents/error.tsx:28:            {error.message || 'Could not fetch agent data. Check that agents are configured.'}
packages/harness/cortextos/community/skills/local-version-control/SKILL.md:14:- Daily cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/community/skills/local-version-control/SKILL.md:62:Requires `ecosystem.local_version_control.enabled: true` in config.json.
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:9:Theta wave is the system's sleep cycle - a deep analysis and improvement process that you (the analyst) own. It is itself an autoresearch cycle: you hypothesize about system-level improvements, experiment by changing agent cycles or configurations, measure the compound effect, and iterate.
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:148:- All changes are logged and user is notified (or approval-gated based on config)
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:11:The system onboarding already collected the essential org configuration. Read it - don't ask the user to repeat it.
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:113:**END YOUR TURN HERE.** Do not call any more tools or produce any more output. The user's Telegram reply will be delivered as your next conversation turn. When you receive it, write their answer to config.json (update the check-approvals cron interval if they want a different frequency), then continue from Step 8.
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:256:No configuration needed here - theta-wave is triggered by the analyst.
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:268:> You don't need to set one up now - you can tell me to configure autoresearch anytime. Want to set up a cycle now?"
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:286:> "No problem. You can tell me to configure autoresearch anytime, or the analyst will set it up when they come online."
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:374:> "All set. Here's what I'm configured to do:
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:514:ENABLED_FILE="$CTX_ROOT/config/enabled-agents.json"
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:518:    '. + {($name): {"enabled": true, "status": "configured", "org": $org}}' \
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:531:> "Your analyst agent is spinning up now. Switch to your Telegram chat with [analyst_bot_name] and send `/onboarding` to complete its setup. It will configure itself, connect to the org, and check in with me when ready.
packages/harness/cortextos/community/agents/agent/CLAUDE.md:182:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/dashboard/src/app/(dashboard)/agents/[name]/page.tsx:4:import { getAllAgents } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/(dashboard)/agents/[name]/page.tsx:29:  // Use the canonical system name from config, not the URL param
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:11:- Daily cron (see `config.json` crons entry `daily-framework-upstream-auto-update`).
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:15:[AGENT_NAME] owns upstream framework health for the cortextos workspace. Bug fix application authority should be documented in your MEMORY.md or deployment config. Feature-level changes always route to [ORCHESTRATOR], who routes to the user for approval.
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:56:- `orgs/` — multi-tenant configuration, never auto-merge
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:127:Add to `config.json` crons:
packages/harness/cortextos/community/skills/framework-upstream-auto-update/SKILL.md:141:- Bug fix application authority belongs to the user and should be granted explicitly in your deployment config or MEMORY.md.
packages/harness/cortextos/CONTRIBUTING.md:10:| `agent` | A full agent template with identity, config, and skills |
packages/harness/cortextos/CONTRIBUTING.md:86:├── config.json      # Required: model, crons, startup config
packages/harness/cortextos/CONTRIBUTING.md:107:- [ ] For agent templates: all required files present (IDENTITY.md, SOUL.md, GUARDRAILS.md, config.json)
packages/harness/cortextos/community/agents/orchestrator/HEARTBEAT.md:166:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1156:  // CTX_ROOT set to our tmpRoot, enabled-agents.json written to config dir.
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1158:  const CONFIG_DIR_REL = 'config';
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1162:    const configDir = join(tmpRoot, CONFIG_DIR_REL);
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1163:    mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1165:      join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/templates/agent/.claude/skills/worker-agents/SKILL.md:37:| Crons | config.json scheduled tasks | None |
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
packages/harness/cortextos/community/skills/weekly-review/SKILL.md:12:**When:** Sunday evening (configured in cron) or when user requests.
packages/harness/cortextos/templates/agent/.claude/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
packages/harness/cortextos/templates/agent/.claude/skills/env-management/SKILL.md:4:triggers: ["add key", "api key", "env file", ".env", "secret", "credential", "token", "environment variable", "configure key", "set key", "missing key", "key not set", "where do I put", "shared secret", "org secret", "agent secret", "key not loading", "configure credentials", "new api key", "add to env", "rotate key", "rotate token", "key compromised", "token expired", "update api key", "new bot token", "revoke key", "credential rotation", "key rotation", "secret rotation", "key was leaked", "compromised credential", "force rotation", "provider rotated", "expired key", "rotate credentials", "update secret"]
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:35:const CONFIG_DIR = path.join(rootTmp, 'config');
packages/harness/cortextos/tests/integration/execution-log-pagination.test.ts:219:    // The dashboard route uses CTX_ROOT from @/lib/config, but we need to
packages/harness/cortextos/tests/integration/execution-log-pagination.test.ts:220:    // test the pure helper readExecutionLogPage by mocking the config.
packages/harness/cortextos/dashboard/src/app/(dashboard)/workflows/page.tsx:152:  // ── Legacy per-agent cron config data (from /api/agents/[name]/crons) ─────
packages/harness/cortextos/dashboard/src/app/(dashboard)/workflows/page.tsx:209:  // ── Fetch per-agent config crons (for CRUD) ────────────────────────────────
packages/harness/cortextos/dashboard/src/app/(dashboard)/workflows/page.tsx:812:                      No crons configured
packages/harness/cortextos/community/agents/agent/HEARTBEAT.md:135:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/templates/agent/.claude/skills/knowledge-base/SKILL.md:66:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
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
packages/harness/cortextos/templates/analyst/.claude/skills/community-publish/SKILL.md:77:Requires `ecosystem.community_publish.enabled: true` in config.json.
packages/harness/cortextos/templates/analyst/.claude/skills/community-publish/SKILL.md:81:- User must have a fork of the cortextOS repo configured as `origin`
packages/harness/cortextos/templates/agent/.claude/skills/heartbeat/SKILL.md:15:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:35:const CONFIG_DIR = path.join(perfTmp, 'config');
packages/harness/cortextos/dashboard/src/app/(dashboard)/workflows/health/page.tsx:307:            <p className="text-sm text-muted-foreground">No crons configured across any agents.</p>
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:476:    mkdirSync(join(tmpRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:478:      join(tmpRoot, 'config', 'enabled-agents.json'),
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:13:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:20:You cannot autonomously modify your own cycle configuration without direction. For your own theta-wave autoresearch cycle, configuration is managed through theta-wave SKILL.md — you CAN modify your own theta-wave parameters there. If the user asks you to modify a cycle, you can. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:39:- Measure the metric using the configured measurement method
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:60:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/templates/analyst/.claude/skills/autoresearch/SKILL.md:109:1. Never autonomously modify cycle config without direction. Your theta-wave cycle is the exception — manage it via theta-wave SKILL.md.
packages/harness/cortextos/templates/analyst/.claude/skills/catalog-browse/SKILL.md:13:- Weekly cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/templates/analyst/.claude/skills/catalog-browse/SKILL.md:62:Requires `ecosystem.catalog_browse.enabled: true` in config.json.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:340:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:361:1. Install/configure it in the project directory
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:364:4. If failed: fix config, repeat
packages/harness/cortextos/tests/integration/fleet-health-mixed-codex-claude.test.ts:34:  mkdirSync(join(tmpRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/integration/fleet-health-mixed-codex-claude.test.ts:35:  writeFileSync(join(tmpRoot, 'config', 'enabled-agents.json'), JSON.stringify(agents, null, 2));
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
packages/harness/cortextos/templates/analyst/.claude/skills/worker-agents/SKILL.md:37:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/community/agents/security/TOOLS.md:31:| `cortextos bus list-agents --format json` | Audit running agent configurations |
packages/harness/cortextos/templates/agent/.claude/skills/bus-reference/SKILL.md:228:- **chat_id** (required): Telegram chat ID (available in config)
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
packages/harness/cortextos/community/agents/security/CLAUDE.md:182:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/templates/analyst/.claude/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
packages/harness/cortextos/templates/analyst/.claude/skills/env-management/SKILL.md:4:triggers: ["add key", "api key", "env file", ".env", "secret", "credential", "token", "environment variable", "configure key", "set key", "missing key", "key not set", "where do I put", "shared secret", "org secret", "agent secret", "key not loading", "configure credentials", "new api key", "add to env", "rotate key", "rotate token", "key compromised", "token expired", "update api key", "new bot token", "revoke key", "credential rotation", "key rotation", "secret rotation", "key was leaked", "compromised credential", "force rotation", "provider rotated", "expired key", "rotate credentials", "update secret"]
packages/harness/cortextos/templates/analyst/.claude/skills/heartbeat/SKILL.md:15:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:210:/** Write a synthetic config.json for a fixture into tmpFrameworkRoot. */
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:214:  const configPath = join(dir, 'config.json');
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:216:    configPath,
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:229:  return configPath;
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:234:  const configPath = writeAgentConfig(fixture);
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:235:  return migrateCronsForAgent(fixture.name, configPath, tmpCtxRoot, { log: () => {} });
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:450:    // Write config.json for ALL 5 agents (preMigrateAgent doesn't touch fw root)
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:457:      const configPath = join(tmpFrameworkRoot, 'orgs', 'lifeos', 'agents', f.name, 'config.json');
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:458:      return migrateCronsForAgent(f.name, configPath, tmpCtxRoot, { log: captureLog });
packages/harness/cortextos/community/agents/agentic-crm-assistant/GOALS.md:13:5. Never send external communications, spend money, delete data, or make irreversible changes without approval unless explicitly configured.
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
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:29:        status: 'configured',
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:36:      expect(parsed.testbot.status).toBe('configured');
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:43:        status: 'configured',
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:55:        testbot: { enabled: true, status: 'configured' },
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:63:      expect(parsed.testbot.status).toBe('configured');
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:141:        join(ctxRoot, 'config'),
packages/harness/cortextos/templates/analyst/.claude/skills/local-version-control/SKILL.md:13:- Daily cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/templates/analyst/.claude/skills/local-version-control/SKILL.md:61:Requires `ecosystem.local_version_control.enabled: true` in config.json.
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
packages/harness/cortextos/dashboard/src/app/(dashboard)/activity/page.tsx:1:import { getOrgs, getAllAgents } from '@/lib/config';
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:225:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:240:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:261:1. Install/configure it in the project directory
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:264:4. If failed: fix config, repeat
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
packages/harness/cortextos/community/agents/agentic-crm-assistant/SOUL.md:38:**Night Mode:** quiet autonomous work. Triage, prepare, organize, draft, and queue items. Do not ping unless urgent under the user's configured rules.
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:60:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:61:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:62:  writeFileSync(join(configDir, 'enabled-agents.json'), JSON.stringify(agents, null, 2));
packages/harness/cortextos/templates/analyst/.claude/skills/bus-reference/SKILL.md:228:- **chat_id** (required): Telegram chat ID (available in config)
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:123:    it('does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:124:      expect(body).not.toContain('Restore crons from config.json');
packages/harness/cortextos/templates/analyst/.claude/skills/upstream-sync/SKILL.md:13:- Daily cron (configured via `cortextos bus add-cron`)
packages/harness/cortextos/templates/analyst/.claude/skills/upstream-sync/SKILL.md:68:Requires `ecosystem.upstream_sync.enabled: true` in config.json.
packages/harness/cortextos/templates/analyst/.claude/skills/upstream-sync/SKILL.md:74:- NEVER applies during night mode — check day_mode_start/day_mode_end from config.json before proceeding
packages/harness/cortextos/dashboard/src/components/shared/priority-badge.tsx:24:  const config = priorityConfig[priority] || fallbackConfig;
packages/harness/cortextos/dashboard/src/components/shared/priority-badge.tsx:27:    <Badge variant={config.variant} className={cn(className)}>
packages/harness/cortextos/dashboard/src/components/shared/priority-badge.tsx:28:      {config.label}
packages/harness/cortextos/dashboard/src/app/api/analytics/overview/route.ts:5:import { getAllAgents } from '@/lib/config';
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:3: * preserve all existing config fields when injecting `runtime: claude-code`.
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:5: * 17 live agent configs, recovery would be a per-agent restore. Idempotency
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:31:    writeFileSync(join(dir, 'config.json'), JSON.stringify(cfg, null, 2) + '\n', 'utf-8');
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:32:    return join(dir, 'config.json');
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:35:  it('adds runtime: claude-code to configs missing the field', () => {
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:68:  it('skips configs that already have a runtime set (claude-code, hermes, codex-app-server)', () => {
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:13:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:20:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:39:- Measure the metric using the configured measurement method
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:60:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:136:# Update approval setting in config if needed (default is true)
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:156:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/community/agents/agentic-crm-assistant/MEMORY.md:8:- Draft external communications freely when useful, but send only after approval unless the user explicitly configured an exception.
packages/harness/cortextos/community/agents/agentic-crm-assistant/MEMORY.md:9:- Prefer tool-agnostic workflows: use whichever email, calendar, meeting-note, contact, or CRM tool is configured and working.
packages/harness/cortextos/community/agents/security/HEARTBEAT.md:135:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:12: * Stores the token in CTX_ROOT/config/push-tokens.json
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:34:  const configDir = path.join(ctxRoot, 'config');
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:35:  const tokensFile = path.join(configDir, 'push-tokens.json');
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:38:    // Ensure config directory exists
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:39:    if (!fs.existsSync(configDir)) {
packages/harness/cortextos/dashboard/src/app/api/notifications/register/route.ts:40:      fs.mkdirSync(configDir, { recursive: true });
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
packages/harness/cortextos/dashboard/src/app/(dashboard)/settings/page.tsx:17:          Manage integrations, system configuration, users, and appearance.
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:22:  const config = statusConfig[status];
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:32:            config.color,
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:37:          <span className="text-xs text-muted-foreground">{config.label}</span>
packages/harness/cortextos/dashboard/src/components/shared/health-dot.tsx:40:      <TooltipContent>{config.label}</TooltipContent>
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:12: *   - "Restore crons from config.json" (old step 6 / session-start language)
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:78:const STALE_RESTORE_PATTERN = /Restore crons from `?config\.json`?/i;
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:124:        it('AGENTS.md: step 6 does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:152:        it('CLAUDE.md: does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:171:        it('ONBOARDING.md: does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:227:      it('does not contain "Restore crons from config.json"', () => {
packages/harness/cortextos/dashboard/src/app/api/approvals/[id]/route.ts:5:import { getFrameworkRoot, getCTXRoot } from '@/lib/config';
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/crm-management/SKILL.md:8:The local CRM is the default source of truth unless setup configures an external CRM.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/crm-management/SKILL.md:69:- Do not add low-signal bulk contacts unless the user configured that category.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/crm-management/SKILL.md:72:- If external CRM sync is configured, local files remain the audit trail unless setup says otherwise.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/crm-management/SKILL.md:126:- VIP/critical contact has no meaningful touch inside configured cadence.
packages/harness/cortextos/tests/integration/fleet-health-mixed-agents.test.ts:71:  mkdirSync(join(tmpRoot, 'config'), { recursive: true });
packages/harness/cortextos/tests/integration/fleet-health-mixed-agents.test.ts:73:    join(tmpRoot, 'config', 'enabled-agents.json'),
packages/harness/cortextos/community/agents/security/.claude/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/community/agents/security/.claude/skills/onboarding/SKILL.md:4:triggers: ["onboarding", "/onboarding", "first boot", "run onboarding", "setup", "not onboarded", "configure agent", "set up identity", "establish identity", "set goals", "onboard me", "start onboarding", "redo onboarding", "onboarding interrupted", "first time setup", "initial setup", "agent setup"]
packages/harness/cortextos/community/agents/security/.claude/skills/onboarding/SKILL.md:45:| Crons configured and running | `config.json` |
packages/harness/cortextos/community/agents/security/.claude/skills/onboarding/SKILL.md:49:| Autoresearch cycle offered | `experiments/config.json` (optional) |
packages/harness/cortextos/dashboard/src/components/shared/status-badge.tsx:25:  const config = statusConfig[status] || { variant: 'outline' as const, label: String(status || 'Unknown') };
packages/harness/cortextos/dashboard/src/components/shared/status-badge.tsx:29:      variant={config.variant}
packages/harness/cortextos/dashboard/src/components/shared/status-badge.tsx:30:      className={cn(config.className, className)}
packages/harness/cortextos/dashboard/src/components/shared/status-badge.tsx:32:      {config.label}
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
packages/harness/cortextos/community/agents/security/.claude/skills/guardrails-reference/SKILL.md:31:| Creating a one-shot reminder or cron | "CronCreate is enough, it'll persist" | CronCreate is session-only. Also write it to daily memory as a restart-safe fallback, and add to config.json when the format supports it. |
packages/harness/cortextos/dashboard/src/components/shared/category-badge.tsx:32:  const config = categoryConfig[category] ?? categoryConfig.other;
packages/harness/cortextos/dashboard/src/components/shared/category-badge.tsx:35:    <Badge variant="secondary" className={cn(config.className, className)}>
packages/harness/cortextos/dashboard/src/components/shared/category-badge.tsx:36:      {config.label}
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
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/tool-discovery/SKILL.md:24:env | grep -E 'GMAIL|GOOGLE|OUTLOOK|NOTION|ZOOM|FATHOM|HUBSPOT|PIPEDRIVE|AIRTABLE|CRM' | sed 's/=.*/=<configured>/'
packages/harness/cortextos/dashboard/src/components/agents/agents-grid.tsx:66:          <h3 className="text-lg font-medium mb-1">No agents configured</h3>
packages/harness/cortextos/community/agents/analyst/TOOLS.md:144:- Or use Playwright MCP if configured
packages/harness/cortextos/community/agents/analyst/TOOLS.md:154:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/templates/agent-codex/TOOLS.md:182:- Accounts: configure your Google accounts in your agent's `.env` or org `secrets.env`
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:13:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:20:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:39:- Measure the metric using the configured measurement method
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:60:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:136:# Update approval setting in config if needed (default is true)
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:156:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/meeting-prep/SKILL.md:16:5. Search configured meeting-note tools for prior calls.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/meeting-prep/SKILL.md:41:7. Surface the brief at the configured time.
packages/harness/cortextos/dashboard/src/app/api/auth/mobile/route.ts:31:    return Response.json({ error: 'Server configuration error' }, { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/skills/route.ts:3:import { getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:28:  it('returns null when config.json is missing', () => {
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:32:  it('returns null when config.json is malformed', () => {
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:33:    writeFileSync(join(tmp, 'config.json'), '{ not valid json', 'utf-8');
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:38:    writeFileSync(join(tmp, 'config.json'), JSON.stringify({ agent_name: 'x' }), 'utf-8');
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:42:  it('returns the configured number when present', () => {
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:43:    writeFileSync(join(tmp, 'config.json'), JSON.stringify({ max_crashes_per_day: 10 }), 'utf-8');
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:48:    writeFileSync(join(tmp, 'config.json'), JSON.stringify({ max_crashes_per_day: 'ten' }), 'utf-8');
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:134:If `ecosystem.local_version_control.enabled` is true in your config.json, run the daily snapshot at the configured time:
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:154:If `ecosystem.upstream_sync.enabled` is true in your config.json, check for framework updates on your configured schedule:
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:181:If `ecosystem.catalog_browse.enabled` is true in your config.json, scan the catalog on your configured schedule:
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:195:If `ecosystem.community_publish.enabled` is true in your config.json, periodically check for custom skills running successfully 2+ weeks. If user agrees to share:
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:224:   > "Your new agent is booting up! Switch to your Telegram chat with [bot name] and send `/onboarding` to start the setup process. The agent will walk you through configuring its identity, goals, and workflows."
packages/harness/cortextos/community/agents/analyst/CLAUDE.md:260:| `config.json` | Crons, max_session_seconds, agent config |
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:3:description: "Tool-agnostic inbox triage for an agentic CRM assistant. Reads configured inboxes, classifies messages, updates CRM, drafts replies, and creates review tasks."
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:14:Use the email/message tools configured in `TOOLS.md`. If no tool is configured, create a human task explaining what is missing.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:19:2. Fetch configured inbox/message source.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:32:9. Archive or mark done only when configured and safe.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/email-triage/SKILL.md:68:Sending replies requires approval unless the user configured an explicit exception in `SOUL.md`.
packages/harness/cortextos/dashboard/src/components/agents/agent-actions.tsx:178:              action cannot be undone. All agent configuration and data will be
packages/harness/cortextos/dashboard/src/app/api/goals/route.ts:6:import { getGoalsPath } from '@/lib/config';
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/calendar-management/SKILL.md:8:Use the calendar provider configured in `TOOLS.md`.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/calendar-management/SKILL.md:16:5. Send a concise summary if configured.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/calendar-management/SKILL.md:30:- Check all configured calendars.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/calendar-management/SKILL.md:32:- Prefer configured meeting windows.
packages/harness/cortextos/dashboard/src/app/api/agents/route.ts:4:import { getFrameworkRoot, getCTXRoot, getAllAgents } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/agents/route.ts:104:  const enabledAgentsPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
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
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:3:description: "Full interactive setup for the agentic CRM personal assistant template. Use at first boot or whenever the user asks to configure/reconfigure the assistant."
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:15:- Never ask for secrets in chat. Ask the user to place credentials in agent `.env`, org `secrets.env`, connector configuration, or the relevant tool's auth flow.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:93:env | grep -E 'GMAIL|GOOGLE|OUTLOOK|NOTION|CRM|HUBSPOT|PIPEDRIVE|AIRTABLE|OPENAI|GEMINI' | sed 's/=.*/=<configured>/'
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:111:- `TOOLS.md` — detected and configured commands
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:112:- `config.json` — timezone, day mode, cron cadence
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/agentic-crm-setup/SKILL.md:181:- configured scope
packages/harness/cortextos/dashboard/src/app/api/kb/collections/route.ts:6:import { getCTXRoot, getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/kb/collections/route.ts:35:  const configPath = path.join(kbRoot, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/kb/collections/route.ts:50:    MMRAG_CONFIG: configPath,
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
packages/harness/cortextos/dashboard/src/components/agents/profile-form.tsx:79:            restarts or reloads its configuration.
packages/harness/cortextos/community/agents/security/.claude/skills/worker-agents/SKILL.md:37:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/relationship-review/SKILL.md:8:Run on the configured cadence.
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
packages/harness/cortextos/templates/agent-codex/HEARTBEAT.md:141:This runs automatically on every heartbeat cycle. It ensures past experiences, user preferences, and learned patterns are semantically searchable for future tasks. Skip if GEMINI_API_KEY is not configured.
packages/harness/cortextos/dashboard/src/app/api/kb/search/route.ts:6:import { getCTXRoot, getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/kb/search/route.ts:77:  const configPath = path.join(kbRoot, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/kb/search/route.ts:105:    MMRAG_CONFIG: configPath,
packages/harness/cortextos/dashboard/src/app/api/kb/search/route.ts:127:      { error: 'GEMINI_API_KEY not configured. Add it to orgs/{org}/secrets.env' },
packages/harness/cortextos/community/agents/security/.claude/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
packages/harness/cortextos/community/agents/security/.claude/skills/env-management/SKILL.md:4:triggers: ["add key", "api key", "env file", ".env", "secret", "credential", "token", "environment variable", "configure key", "set key", "missing key", "key not set", "where do I put", "shared secret", "org secret", "agent secret", "key not loading", "configure credentials", "new api key", "add to env", "rotate key", "rotate token", "key compromised", "token expired", "update api key", "new bot token", "revoke key", "credential rotation", "key rotation", "secret rotation", "key was leaked", "compromised credential", "force rotation", "provider rotated", "expired key", "rotate credentials", "update secret"]
packages/harness/cortextos/tests/unit/daemon/ipc-fleet-health.test.ts:51:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-fleet-health.test.ts:52:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-fleet-health.test.ts:54:    join(configDir, 'enabled-agents.json'),
packages/harness/cortextos/dashboard/src/components/agents/crons-tab.tsx:142:          No crons configured. Click "Add Cron" to create one.
packages/harness/cortextos/dashboard/src/components/agents/crons-tab.tsx:215:        Crons are read from config.json on agent startup. Changes here update config.json and notify the agent to reload.
packages/harness/cortextos/community/agents/security/.claude/skills/knowledge-base/SKILL.md:66:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
packages/harness/cortextos/community/agents/security/IDENTITY.md:7:Security specialist. Monitors system and network security posture, audits credentials and configurations, scans for vulnerabilities, reviews code changes for security implications, and responds to security incidents across the cortextOS fleet.
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/typing/route.ts:4:import { getCTXRoot } from '@/lib/config';
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
packages/harness/cortextos/dashboard/src/components/agents/agent-card.tsx:16:  /** Filesystem / config key (e.g. "devbot"). Used for URL routing. */
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/lifecycle/route.ts:4:import { getFrameworkRoot, getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/lifecycle/route.ts:92:        const enabledAgentsPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/lifecycle/route.ts:115:        const enabledAgentsPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/lifecycle/route.ts:188:  const enabledAgentsPath = path.join(ctxRoot, 'config', 'enabled-agents.json');
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
packages/harness/cortextos/dashboard/src/app/api/messages/upload/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/community/agents/security/.claude/skills/heartbeat/SKILL.md:15:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/dashboard/src/app/api/messages/send/route.ts:4:import { getCTXRoot, getAllAgents } from '@/lib/config';
packages/harness/cortextos/vitest.config.ts:1:import { defineConfig } from 'vitest/config';
packages/harness/cortextos/vitest.config.ts:7:      // Matches the dashboard's tsconfig path alias so tests under
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/goals/route.ts:5:import { getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/onboarding/SKILL.md:44:| Crons configured and running | `config.json` |
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/onboarding/SKILL.md:48:| Autoresearch cycle offered | `experiments/config.json` (optional) |
packages/harness/cortextos/dashboard/src/app/api/messages/history/[agent]/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/agents/[name]/memory/route.ts:5:import { getAgentDir, getOrgs, getAgentsForOrg } from '@/lib/config';
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
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:66:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:67:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:68:  writeFileSync(join(configDir, 'enabled-agents.json'), JSON.stringify(agents, null, 2));
packages/harness/cortextos/dashboard/src/app/api/messages/stream/[agent]/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/messages/stream/[agent]/route.ts:27:    return new Response('Server misconfiguration', { status: 500 });
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:107:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:340:# 1. Create or update the worker's MCP config
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:361:1. Install/configure it in the project directory
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:364:4. If failed: fix config, repeat
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/route.ts:9: * also reads config files directly from the server-side Next.js process.
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/route.ts:19:import { CTX_ROOT, getAllAgents } from '@/lib/config';
packages/harness/cortextos/dashboard/src/components/tasks/task-detail-sheet.tsx:106:      const res = await fetch(`/api/org/config?org=${encodeURIComponent(org)}`);
packages/harness/cortextos/dashboard/src/components/tasks/task-detail-sheet.tsx:109:        setDeliverablesEnabled(!!data.config?.require_deliverables);
packages/harness/cortextos/community/agents/agentic-crm-assistant/crm/README.md:16:The assistant should also write narrative summaries to `memory/` and ingest durable summaries into the cortextOS knowledge base when configured.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/cron-management/SKILL.md:17:Editing `config.json.crons[]` while the agent is running does NOT hot-reload — the daemon
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/cron-management/SKILL.md:18:only re-reads `config.json` on agent boot. Mid-session changes go through `bus add-cron` /
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/fire-route.test.ts:15: * Uses the @/ alias resolved by vitest.config.ts to dashboard/src.
packages/harness/cortextos/community/agents/security/.claude/skills/bus-reference/SKILL.md:228:- **chat_id** (required): Telegram chat ID (available in config)
packages/harness/cortextos/community/agents/agentic-crm-assistant/GUARDRAILS.md:7:| External communication | "This reply is obvious, I can just send it" | Create a draft and request approval unless the user configured an explicit exception. |
packages/harness/cortextos/community/agents/agentic-crm-assistant/GUARDRAILS.md:11:| Calendar conflict | "It is probably fine" | Check configured protected time and calendars; surface conflicts with alternatives. |
packages/harness/cortextos/community/agents/agentic-crm-assistant/IDENTITY.md:17:- Triage inboxes and message sources according to configured tools and user rules.
packages/harness/cortextos/community/agents/agentic-crm-assistant/IDENTITY.md:19:- Draft external communications, but never send without approval unless the user explicitly configures an exception.
packages/harness/cortextos/dashboard/src/components/charts/chart-theme.ts:2: * cortextOS Dashboard - Chart theme configuration.
packages/harness/cortextos/dashboard/src/app/api/tasks/[id]/route.ts:6:import { getFrameworkRoot, getCTXRoot } from '@/lib/config';
packages/harness/cortextos/community/agents/agentic-crm-assistant/config.json:21:      "prompt": "Read .claude/skills/email-triage/SKILL.md and run triage for configured inbox/message sources. Create tasks for anything requiring user review, draft eligible replies, update CRM context, and do not send external communications without approval."
packages/harness/cortextos/community/agents/agentic-crm-assistant/config.json:51:      "prompt": "Read .claude/skills/meeting-prep/SKILL.md and process configured meeting-note/transcript sources for recently completed meetings. Extract decisions, action items, follow-ups, and CRM updates."
packages/harness/cortextos/dashboard/src/app/api/tasks/route.ts:5:import { getFrameworkRoot, getCTXRoot, getOrgs } from '@/lib/config';
packages/harness/cortextos/dashboard/src/components/workflows/cron-history.tsx:7: *  - Shows up to 100 recent executions per page (configurable via HISTORY_LIMIT)
packages/harness/cortextos/skills/cron-management/SKILL.md:116:## Migration from config.json (legacy)
packages/harness/cortextos/skills/cron-management/SKILL.md:119:`config.json`. The daemon auto-migrates them to `crons.json` on first boot.
packages/harness/cortextos/community/agents/agentic-crm-assistant/TOOL_CONNECTIONS.md:11:3. Store credentials only in connector configuration, provider auth, `.env`, or
packages/harness/cortextos/community/agents/agentic-crm-assistant/TOOL_CONNECTIONS.md:13:4. Record configured tools in `TOOLS.md`.
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
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:4:import { getOrgs, getAgentsForOrg, getAgentDir } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:15:    const configs: Array<{ agent: string; org: string; botToken: string; chatId: string }> = [];
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:41:          configs.push({
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:51:    return Response.json({ configs });
packages/harness/cortextos/dashboard/src/app/api/settings/telegram/route.ts:54:    return Response.json({ error: 'Failed to fetch telegram configs' }, { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/[agent]/executions/route.ts:19:import { CTX_ROOT } from '@/lib/config';
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/worker-agents/SKILL.md:36:| Crons | config.json scheduled tasks | None |
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:4:import { CTX_ROOT } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:20:const CONFIG_PATH = path.join(CTX_ROOT, 'config', 'dashboard-settings.json');
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:33:    return Response.json({ config: readConfig() });
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:36:    return Response.json({ error: 'Failed to fetch system config' }, { status: 500 });
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:51:    return Response.json({ success: true, config: updated });
packages/harness/cortextos/dashboard/src/app/api/settings/system/route.ts:54:    return Response.json({ error: 'Failed to save system config' }, { status: 500 });
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:253:describe('AgentProcess - BUG-048 fix (session timer re-reads config)', () => {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:254:  it('fires sessionRefresh when config on disk still matches original short duration', async () => {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:270:  it('reschedules when config.json on disk has a longer max_session_seconds', async () => {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:279:      typeof p === 'string' && p.endsWith('config.json'),
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:282:      if (typeof p === 'string' && p.endsWith('config.json')) {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:301:    // sessionRefresh must NOT have been called — config said 1h, not 1s
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:318:      typeof p === 'string' && p.endsWith('config.json'),
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:321:      if (typeof p === 'string' && p.endsWith('config.json')) {
packages/harness/cortextos/tests/unit/bus/system.test.ts:38:      selfRestart(paths, 'test-agent', 'config reload needed');
packages/harness/cortextos/tests/unit/bus/system.test.ts:44:      expect(markerContent).toBe('config reload needed');
packages/harness/cortextos/tests/unit/bus/system.test.ts:50:      expect(logContent).toContain('SELF-RESTART: config reload needed');
packages/harness/cortextos/tests/unit/bus/system.test.ts:89:      execSync('git config user.email "test@test.com"', { cwd: gitDir, stdio: 'pipe' });
packages/harness/cortextos/tests/unit/bus/system.test.ts:90:      execSync('git config user.name "Test"', { cwd: gitDir, stdio: 'pipe' });
packages/harness/cortextos/tests/unit/bus/system.test.ts:111:      writeFileSync(join(gitDir, 'config.json'), '{"token=abc123"}');
packages/harness/cortextos/tests/unit/bus/system.test.ts:115:      expect(report.blocked.some(b => b.includes('config.json') && b.includes('credential'))).toBe(true);
packages/harness/cortextos/tests/unit/bus/system.test.ts:261:    it('returns false when not configured', async () => {
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:15: * + model defaults in config.json.
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:90:                     'config.json', 'goals.json']) {
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:98:  it('writes runtime=codex-app-server and model=gpt-5-codex into config.json', async () => {
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:107:    const cfgPath = join(tempRoot, 'orgs', 'testorg', 'agents', 'codex-cfg', 'config.json');
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:208:    // PR 10: claude-code is now an EXPLICIT field in templates/agent/config.json
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:211:    const cfg = JSON.parse(readFileSync(join(agentDir, 'config.json'), 'utf-8'));
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:220: * agent: codex runtime in config but claude-only bootstrap files
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/env-management/SKILL.md:3:description: "You need to add a new API key to the system, update an existing credential, check what secrets are configured for the org or a specific agent, onboard a new third-party tool that needs credentials, diagnose why an agent cannot access a service because a key appears missing, rotate a compromised or expired key, or restart affected agents after a credential change. This skill covers the full lifecycle of environment variables and secrets in cortextOS."
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
packages/harness/cortextos/tests/unit/bus/approval.test.ts:146:  it('REGRESSION GUARD: warns when postActivity returns false (not-configured signal)', async () => {
packages/harness/cortextos/tests/unit/bus/approval.test.ts:313:    // expected steady state, not a misconfiguration.
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:293:  it('empty state: prints "No crons configured" message', async () => {
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:301:    expect(output).toContain(`No crons configured for ${TEST_AGENT}`);
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/knowledge-base/SKILL.md:65:If no collections appear, the KB may not be configured yet — check that `GEMINI_API_KEY` is set in `orgs/$CTX_ORG/secrets.env`.
packages/harness/cortextos/dashboard/src/app/api/workflows/health/route.ts:26:import { CTX_ROOT, getAllAgents } from '@/lib/config';
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:3:description: "You need to create a new agent, restart a crashed agent, change an agent's model or config, fix a Telegram bot token, troubleshoot why an agent is not responding, enable or disable an agent, spawn an agent for another user, manage PM2 process management, reset crash limits, or do anything that touches an agent's lifecycle, configuration, or credentials. This is the definitive guide for every agent operation in cortextOS."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:17:4. **ALWAYS use `cortextos enable` to start agents.** Never manually edit PM2 config.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:77:# Step 6: Update config.json
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:80:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT_NAME/config.json';
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:188:# Step 1: Update config.json
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:191:const path = '$CTX_FRAMEWORK_ROOT/orgs/$ORG/agents/$AGENT/config.json';
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:282:Crons are daemon-managed and persisted to `${CTX_ROOT}/state/<agent>/crons.json`. The daemon dispatches them automatically — no agent-side restoration needed. Use the bus commands listed below; this is the only persistent scheduling path. Editing `config.json.crons[]` mid-session does NOT hot-reload (the daemon only re-reads `config.json` on agent boot).
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:390:3. Regenerate ecosystem config: `cortextos ecosystem` then `pm2 restart ecosystem.config.js`
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/agent-management/SKILL.md:412:| Change model | Edit config.json model field + soft restart |
packages/harness/cortextos/dashboard/src/app/api/experiments/route.ts:93:      // Read config
packages/harness/cortextos/dashboard/src/app/api/experiments/route.ts:95:      const configPath = path.join(expDir, 'config.json');
packages/harness/cortextos/dashboard/src/app/api/experiments/route.ts:96:      if (fs.existsSync(configPath)) {
packages/harness/cortextos/dashboard/src/app/api/experiments/route.ts:98:          const cfg = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:69:      const configDir = join(tmpHome, '.cortextos', instanceId, 'config');
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:70:      mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:71:      const path = join(configDir, 'enabled-agents.json');
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:93:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:106:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:116:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:126:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:135:      const backups = readdirSync(join(tmpHome, '.cortextos', 'default', 'config'))
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:68:  const configDir = join(tmpRoot, 'config');
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:69:  mkdirSync(configDir, { recursive: true });
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:70:  writeFileSync(join(configDir, 'enabled-agents.json'), JSON.stringify(agents, null, 2));
packages/harness/cortextos/dashboard/src/app/api/workflows/health/__tests__/health-route.test.ts:9: *   - Empty state: no crons configured
packages/harness/cortextos/dashboard/src/app/api/workflows/health/__tests__/health-route.test.ts:28:const CONFIG_DIR = path.join(rootTmp, 'config');
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/heartbeat/SKILL.md:14:Your `config.json` has a heartbeat cron (default every 4h). When it fires:
packages/harness/cortextos/dashboard/src/components/comms/channel-view.tsx:12:// Default: 10000ms (10s). Enforced minimum: 2000ms so an accidental misconfig
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:4:import { getFrameworkRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:21:    return Response.json({ config: ctx, org });
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:80:    // Keep using bash script here: `bus sync-org-config` CLI subcommand does not exist yet.
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:82:    const syncScript = join(frameworkRoot, 'bus', 'sync-org-config.sh');
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:89:        child.on('error', (err) => console.error('[api/org/config] sync-org-config.sh spawn error:', err));
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:90:        child.on('exit', (code) => { if (code !== 0) console.error(`[api/org/config] sync-org-config.sh exited ${code}`); });
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:91:      }).catch((err) => console.error('[api/org/config] child_process import failed:', err));
packages/harness/cortextos/dashboard/src/app/api/org/config/route.ts:94:    return Response.json({ success: true, config: ctx, org });
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:12:You have research cycles assigned to you (check `experiments/config.json`). Each cycle has:
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:19:You cannot autonomously modify your own cycle configuration. If the user asks you to modify a cycle, you can. Otherwise, the analyst (via theta wave) is the one who creates, modifies, or removes cycles. You CAN and SHOULD run experiments within your assigned cycles.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:38:- Measure the metric using the configured measurement method
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:59:If `approval_required` is true in `experiments/config.json`, you must manually create an approval before proceeding:
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:135:# Update approval setting in config if needed (default is true)
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:155:1. Never autonomously modify your own cycle config. If the user asks you to, you can.
packages/harness/cortextos/dashboard/src/app/api/comms/__tests__/routes.test.ts:54:  fs.mkdirSync(path.join(rootTmp, 'config'), { recursive: true });
packages/harness/cortextos/dashboard/src/app/api/comms/__tests__/routes.test.ts:56:    path.join(rootTmp, 'config', 'enabled-agents.json'),
packages/harness/cortextos/dashboard/src/app/api/comms/channel/[pair]/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/comms/channels/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/comms/upload/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/comms/feed/route.ts:4:import { getCTXRoot } from '@/lib/config';
packages/harness/cortextos/dashboard/src/app/api/comms/feed/route.ts:35:  // are already isolated at the filesystem level under the configured
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
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:106:If the file already exists (e.g., with MCP config), merge the permissions key into it rather than overwriting.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:324:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:339:# 1. Create or update the worker's MCP config
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:360:1. Install/configure it in the project directory
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:363:4. If failed: fix config, repeat
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/bus-reference/SKILL.md:270:- **chat_id** (required): Telegram chat ID (available in config)
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/bus-reference/SKILL.md:450:`config.json.crons[]` mid-session does NOT hot-reload — these commands do, and they
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
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:799:      config: { features: { goals: true } },
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:829:      config: { features: { goals: true } },
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:941:  it('honours codex_context_cap config override when modelContextWindow is null', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:1069:  it('defaults model to gpt-5-codex when config.model is unset', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:1082:  it('preserves config.model override when set', () => {

exec
/bin/zsh -lc "nl -ba scripts/run-tenancy-audit.sh | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# shellcheck disable=SC2329,SC2015,SC2001
     3	#
     4	# IFOS multi-tenant tenancy audit (Path A interactive)
     5	#
     6	# Adversarially exercises the 12 tenancy invariants from
     7	# docs/architecture/tenancy-invariants.md against the live Hetzner Postgres
     8	# via SSH tunnel + multi-tenant render fixture.
     9	#
    10	# Test cases:
    11	#   T1   Every tenant-data table has tenant_slug NOT NULL          (9 tables)
    12	#   T2   Every tenant-data table has RLS enabled                    (9 tables)
    13	#   T3   Every tenant-data table has tenant_isolation policy        (9 tables)
    14	#   T4   App-code missing-SET-LOCAL adversarial — INSERT without setting
    15	#   T5   ifos_app role has no DELETE on decision_log or recent_edit
    16	#   T6   /vault/<tenant>/ permissions + no cross-tenant symlinks
    17	#   T7   Cross-tenant rendered-dir isolation (test-tenant-a vs test-tenant-b)
    18	#   T8   Rendered .env chmod 0600
    19	#   T9   Tenant slug regex validation (adversarial bad slugs rejected)
    20	#   T10  Voice corpus single-active-per-tenant partial unique
    21	#   T11  Cross-tenant RLS structural block (re-verify Day-4 §7)
    22	#   T12  _shared/ helpers tenant-agnostic (grep audit)
    23	#
    24	# Pre-conditions:
    25	#   - bash scripts/run-live-migration.sh executed successfully (live VPS
    26	#     has v0.2 schema + migration-test seed row)
    27	#   - ~/.ssh/ifos_hetzner_ed25519 SSH key present
    28	#   - test-tenant-b fixture exists at packages/agent-renderer/tests/fixtures/...
    29	#   - ifos_app password retrievable from 1Password
    30	#
    31	# Usage:
    32	#   bash scripts/run-tenancy-audit.sh
    33	#
    34	# Output:
    35	#   - PASS/FAIL per invariant (T1 through T12 + cross-cutting attacks)
    36	#   - logs/tenancy-audit/<session-id>/ — per-test logs
    37	#   - decision_log audit row (live mode) OR fallback JSONL
    38	
    39	set -uo pipefail
    40	
    41	# ────────────────────────────────────────────────────────────────────────
    42	# Config
    43	# ────────────────────────────────────────────────────────────────────────
    44	
    45	readonly VPS_HOST="178.105.87.24"
    46	readonly VPS_SSH_USER="maddox"
    47	readonly VPS_SSH_KEY="${HOME}/.ssh/ifos_hetzner_ed25519"
    48	readonly LOCAL_PORT="55432"
    49	readonly VPS_PORT="5432"
    50	readonly DB_NAME="ifos_v2"
    51	readonly DB_USER="ifos_app"
    52	readonly TENANT_A="migration-test"
    53	readonly TENANT_B="test-tenant-b"
    54	
    55	REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    56	readonly REPO_ROOT
    57	
    58	SESSION_ID="$(date -u +"%Y%m%dT%H%M%SZ")-$$"
    59	readonly SESSION_ID
    60	LOG_DIR="${REPO_ROOT}/logs/tenancy-audit/${SESSION_ID}"
    61	mkdir -p "${LOG_DIR}"
    62	
    63	SSH_TUNNEL_PID=""
    64	PASS_STEPS=0
    65	FAIL_STEPS=0
    66	declare -a FAILED_TESTS=()
    67	
    68	# Expected tenant-data tables (T1, T2, T3 expect ALL of these)
    69	readonly TENANT_TABLES=(
    70	  entities entity_links decision_log tenant_eval_sets tenant_adapters
    71	  voice_corpus voice_corpus_chunks tone_rule recent_edit
    72	)
    73	
    74	# ────────────────────────────────────────────────────────────────────────
    75	# Cleanup trap
    76	# ────────────────────────────────────────────────────────────────────────
    77	
    78	_cleanup() {
    79	  unset PGPASSWORD
    80	  if [[ -n "${SSH_TUNNEL_PID}" ]]; then
    81	    kill "${SSH_TUNNEL_PID}" 2>/dev/null || true
    82	    wait "${SSH_TUNNEL_PID}" 2>/dev/null || true
    83	  fi
    84	  history -c 2>/dev/null || true
    85	}
    86	trap _cleanup EXIT INT TERM
    87	
    88	# ────────────────────────────────────────────────────────────────────────
    89	# UX helpers
    90	# ────────────────────────────────────────────────────────────────────────
    91	
    92	_step() { printf '\n\033[1;34m── %s ──\033[0m\n' "$1"; }
    93	_pass() { PASS_STEPS=$((PASS_STEPS+1)); printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
    94	_fail() {
    95	  FAIL_STEPS=$((FAIL_STEPS+1))
    96	  FAILED_TESTS+=("$1")
    97	  printf '  \033[1;31m✗\033[0m %s\n' "$1"
    98	  [[ -n "${2:-}" ]] && printf '    %s\n' "$2"
    99	}
   100	_warn() { printf '  \033[1;33m!\033[0m %s\n' "$1"; }
   101	
   102	_psql_local() {
   103	  psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A "$@"
   104	}
   105	
   106	# ────────────────────────────────────────────────────────────────────────
   107	# Step 0 — Pre-flight + password prompt + SSH tunnel
   108	# ────────────────────────────────────────────────────────────────────────
   109	
   110	_step "Step 0 — Pre-flight"
   111	
   112	if ! command -v psql >/dev/null 2>&1; then
   113	  _fail "psql not on PATH" "brew install postgresql@15"
   114	  exit 1
   115	fi
   116	_pass "psql present: $(psql --version | head -1)"
   117	
   118	if [[ ! -f "${VPS_SSH_KEY}" ]]; then
   119	  _fail "SSH key not found at ${VPS_SSH_KEY}"
   120	  exit 1
   121	fi
   122	_pass "SSH key present"
   123	
   124	if [[ ! -d "${REPO_ROOT}/packages/agent-renderer/tests/fixtures/test-tenant-vault/${TENANT_B}" ]]; then
   125	  _fail "test-tenant-b fixture not found" "Run Phase 1.4 first to create the fixture"
   126	  exit 1
   127	fi
   128	_pass "test-tenant-b fixture present"
   129	
   130	if ! ssh -i "${VPS_SSH_KEY}" -o BatchMode=yes -o ConnectTimeout=10 \
   131	        "${VPS_SSH_USER}@${VPS_HOST}" "true" 2>/dev/null; then
   132	  _fail "SSH to ${VPS_SSH_USER}@${VPS_HOST} failed"
   133	  exit 1
   134	fi
   135	_pass "SSH reachable as ${VPS_SSH_USER}@${VPS_HOST}"
   136	
   137	ssh -i "${VPS_SSH_KEY}" -N -L "${LOCAL_PORT}:localhost:${VPS_PORT}" \
   138	    -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 \
   139	    "${VPS_SSH_USER}@${VPS_HOST}" &
   140	SSH_TUNNEL_PID=$!
   141	sleep 2
   142	
   143	if ! nc -zw3 localhost "${LOCAL_PORT}" 2>/dev/null; then
   144	  _fail "SSH tunnel did not establish"
   145	  exit 1
   146	fi
   147	_pass "SSH tunnel up: localhost:${LOCAL_PORT}"
   148	
   149	printf '\n\033[1;33mEnter ifos_app Postgres password (from 1Password):\033[0m\n'
   150	printf '  Password is read silently. Press Enter to submit.\n  > '
   151	read -rs PGPASSWORD
   152	printf '\n'
   153	
   154	if [[ -z "${PGPASSWORD}" ]]; then
   155	  _fail "Empty password" "Aborting"
   156	  exit 1
   157	fi
   158	export PGPASSWORD
   159	
   160	if ! _psql_local -c "SELECT 1;" >/dev/null 2>&1; then
   161	  _fail "Postgres connection failed" "Check password"
   162	  exit 1
   163	fi
   164	_pass "Connected to ${DB_NAME} as ${DB_USER}"
   165	
   166	# ────────────────────────────────────────────────────────────────────────
   167	# T1 — Every tenant-data table has tenant_slug NOT NULL
   168	# ────────────────────────────────────────────────────────────────────────
   169	
   170	_step "T1 — tenant_slug NOT NULL on every tenant-data table"
   171	
   172	T1_RESULT=$(_psql_local <<EOF
   173	SELECT table_name FROM information_schema.columns
   174	WHERE table_schema='public' AND column_name='tenant_slug' AND is_nullable='NO'
   175	ORDER BY table_name;
   176	EOF
   177	)
   178	T1_TABLES=$(echo "${T1_RESULT}" | tr '\n' ' ' | tr -s ' ')
   179	
   180	EXPECTED_COUNT=${#TENANT_TABLES[@]}
   181	ACTUAL_COUNT=$(echo "${T1_RESULT}" | grep -cE '\S')
   182	
   183	if (( ACTUAL_COUNT == EXPECTED_COUNT + 1 )); then
   184	  _pass "${ACTUAL_COUNT} tables have tenant_slug NOT NULL (9 tenant-data + 1 tenants meta — expected ${EXPECTED_COUNT}+1)"
   185	else
   186	  for t in "${TENANT_TABLES[@]}"; do
   187	    if echo "${T1_TABLES}" | grep -qw "${t}"; then
   188	      :
   189	    else
   190	      _fail "T1: table ${t} missing tenant_slug NOT NULL"
   191	    fi
   192	  done
   193	  if (( ACTUAL_COUNT == EXPECTED_COUNT )); then
   194	    _pass "${ACTUAL_COUNT} tables have tenant_slug NOT NULL (matches expected ${EXPECTED_COUNT}; tenants meta has tenant_slug as PRIMARY KEY)"
   195	  fi
   196	fi
   197	echo "${T1_RESULT}" > "${LOG_DIR}/T1-tables.log"
   198	
   199	# ────────────────────────────────────────────────────────────────────────
   200	# T2 — Every tenant-data table has RLS enabled
   201	# ────────────────────────────────────────────────────────────────────────
   202	
   203	_step "T2 — RLS enabled on every tenant-data table"
   204	
   205	T2_RESULT=$(_psql_local <<EOF
   206	SELECT relname FROM pg_class c JOIN pg_namespace n ON c.relnamespace=n.oid
   207	WHERE n.nspname='public' AND c.relrowsecurity=true ORDER BY relname;
   208	EOF
   209	)
   210	echo "${T2_RESULT}" > "${LOG_DIR}/T2-rls-enabled.log"
   211	
   212	T2_MISSING=()
   213	for t in "${TENANT_TABLES[@]}"; do
   214	  if ! echo "${T2_RESULT}" | grep -qw "${t}"; then
   215	    T2_MISSING+=("${t}")
   216	  fi
   217	done
   218	
   219	if (( ${#T2_MISSING[@]} == 0 )); then
   220	  _pass "All 9 tenant-data tables have RLS enabled"
   221	else
   222	  for t in "${T2_MISSING[@]}"; do
   223	    _fail "T2: table ${t} does NOT have RLS enabled"
   224	  done
   225	fi
   226	
   227	# ────────────────────────────────────────────────────────────────────────
   228	# T3 — Every tenant-data table has tenant_isolation policy
   229	# ────────────────────────────────────────────────────────────────────────
   230	
   231	_step "T3 — tenant_isolation policy on every tenant-data table"
   232	
   233	T3_RESULT=$(_psql_local <<EOF
   234	SELECT tablename, policyname FROM pg_policies
   235	WHERE schemaname='public' ORDER BY tablename;
   236	EOF
   237	)
   238	echo "${T3_RESULT}" > "${LOG_DIR}/T3-policies.log"
   239	
   240	T3_MISSING=()

exec
/bin/zsh -lc "rg -n \"12/12|T1|cash_conductor_transactions|tenant-data tables|Expected\" docs/architecture/tenancy-invariants.md scripts docs -g '"'!node_modules'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/architecture/tenancy-invariants.md:22:**Meta vs tenant-data tables.** Postgres tables fall into two classes:
docs/architecture/tenancy-invariants.md:27:The 12 invariants below apply to **tenant-data tables**. The `tenants` meta table is the exception, documented separately under the verification matrix.
docs/architecture/tenancy-invariants.md:33:### T1 — Every tenant-data table has `tenant_slug TEXT NOT NULL`
docs/architecture/tenancy-invariants.md:38:- **Subtle case:** `recent_edit.original_text` was originally `TEXT NOT NULL` in v0.2; v0.3 (post Round-2 remediation) drops that NOT NULL constraint to allow PII purge to set `original_text=NULL`. This does not weaken T1: `recent_edit.tenant_slug` remains `TEXT NOT NULL`.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:58:  Expected: 9 rows (same set as T1).
docs/architecture/tenancy-invariants.md:71:  Expected: 9 rows, one per tenant-data table, policy name follows naming convention.
docs/architecture/tenancy-invariants.md:77:- **Enforcement:** `agents/_shared/hook-helpers.sh::_hh_emit_row` sets it via `SET LOCAL app.current_tenant = '${tenant}';` before INSERT. `agents/_shared/voice-loader.sh::_vl_psql_query` sets it via wrapped SQL. `packages/agent-renderer/src/renderer.ts` doesn't write to tenant-data tables directly (it writes to vault).
docs/architecture/tenancy-invariants.md:97:  Expected: 4 rows total — `decision_log` × {SELECT, INSERT}, `recent_edit` × {SELECT, INSERT}. No UPDATE or DELETE.
docs/architecture/tenancy-invariants.md:111:  Expected: mode 700, owned by ifos user. Find returns no symlinks pointing outside.
docs/architecture/tenancy-invariants.md:125:  Expected: only `config.json` differs (different tenant_slug) and `.env` differs (different secrets); no cross-references.
docs/architecture/tenancy-invariants.md:137:  Expected: `600`.
docs/architecture/tenancy-invariants.md:149:  Expected: `^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$`.
docs/architecture/tenancy-invariants.md:153:### T10 — Voice corpus `is_active=TRUE` enforced unique per tenant
docs/architecture/tenancy-invariants.md:163:  Expected: 1 row with partial UNIQUE on `tenant_slug WHERE is_active=true`.
docs/architecture/tenancy-invariants.md:167:### T11 — Cross-tenant RLS structurally blocks reads even when app code forgets the guard
docs/architecture/tenancy-invariants.md:179:  Expected: 0 rows from every cross-tenant read attempt.
docs/architecture/tenancy-invariants.md:180:- **Acceptance:** **VERIFIED Day-4 §7 (5/5 conditions).** Re-verified by tenancy audit Step T11 in this slice.
docs/architecture/tenancy-invariants.md:182:### T12 — `_shared/` helpers are tenant-agnostic (no hard-coded tenant slugs)
docs/architecture/tenancy-invariants.md:193:  Expected: zero hits (or only intentional examples in comments).
docs/architecture/tenancy-invariants.md:202:| T1 | Partial → Verified | Day-4 §7 schema-creation gate + tenancy audit | 2026-05-17 Day-4 (Day-4 tables); pending Day-9 (v0.2 tables + cross-validation) | All 9 tables expected to pass; v0.2 tables structurally identical pattern |
docs/architecture/tenancy-invariants.md:211:| T10 | Partial → Verified | v0.2 migration §2 partial unique index + tenancy audit | v0.2 migration design; pending Day-9 functional verify (post live migration) | Single-active voice corpus per tenant |
docs/architecture/tenancy-invariants.md:212:| T11 | **VERIFIED** | Day-4 §7 RLS isolation gate (5/5 conditions) + Phase 2 stress test | 2026-05-17 Day-4 | The only adversarially-verified invariant; foundation of the layered defence |
docs/architecture/tenancy-invariants.md:213:| T12 | Partial → Verified | grep audit + code review | Phase 1 + Phase 3 + Phase 5 commits; pending Day-9 audit grep | Tenant-agnostic helpers |
docs/architecture/tenancy-invariants.md:221:The 12 invariants above are the v1.0 set. Adding a new invariant (T13+) OR modifying an existing one requires:
docs/architecture/tenancy-invariants.md:236:- **Pre-migration**: Day-4 §6.5 provision-tenant workflow + v0.1-to-v0.2.sql migration enforce T1, T2, T3, T5, T9, T10 at schema creation.
docs/architecture/tenancy-invariants.md:237:- **At every agent runtime write**: hook-helpers.sh + voice-loader.sh enforce T4 via `SET LOCAL app.current_tenant` pattern; relies on T11 (Postgres RLS) as the structural backstop.
docs/architecture/tenancy-invariants.md:238:- **At every code review**: `_shared/` changes audited for T12 hard-coded slug introduction.
docs/architecture/tenancy-invariants.md:239:- **At every tenancy audit run**: `scripts/run-tenancy-audit.sh` (companion artefact) verifies T1-T12 against live VPS.
docs/architecture/tenancy-invariants.md:249:| Q1 | Should T4 be promoted to structural via stored-procedure wrappers (so app code physically cannot INSERT without `SET LOCAL`)? | If Day-9 tenancy audit reveals an app-code path forgot the guard, AND the cost of T11 catching the leak is unacceptable (e.g., partial writes). |
docs/architecture/tenancy-invariants.md:253:| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:576:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:650:      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:651:      per §3 cash_conductor_transactions.retention). Migration-test tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:656:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:782:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:806:    1: Run scripts/run-tenancy-audit.sh; expect 12/12 invariants pass (T1-T12)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:863:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:878:      cash_conductor_transactions table is GATED by an explicit per-tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:924:  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:56:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:59:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:89:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:92:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:96:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:97:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:99:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:103:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:104:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:464:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:466:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:475:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
scripts/run-live-migration.sh:282:[[ "${TABLES_FOUND}" == "4" ]] && _pass "4 v0.2 tables present" || _fail "Expected 4 tables, got ${TABLES_FOUND}"
scripts/run-live-migration.sh:332:# Expected: 1 trigger + 1 output + 1 green action + 2 red (gating_failed audit + ESC escalation) = 5
scripts/run-live-migration.sh:336:  _fail "Expected 5 rows, got ${ROWS_ADDED}"
scripts/run-tenancy-audit.sh:11:#   T1   Every tenant-data table has tenant_slug NOT NULL          (9 tables)
scripts/run-tenancy-audit.sh:20:#   T10  Voice corpus single-active-per-tenant partial unique
scripts/run-tenancy-audit.sh:21:#   T11  Cross-tenant RLS structural block (re-verify Day-4 §7)
scripts/run-tenancy-audit.sh:22:#   T12  _shared/ helpers tenant-agnostic (grep audit)
scripts/run-tenancy-audit.sh:35:#   - PASS/FAIL per invariant (T1 through T12 + cross-cutting attacks)
scripts/run-tenancy-audit.sh:68:# Expected tenant-data tables (T1, T2, T3 expect ALL of these)
scripts/run-tenancy-audit.sh:167:# T1 — Every tenant-data table has tenant_slug NOT NULL
scripts/run-tenancy-audit.sh:170:_step "T1 — tenant_slug NOT NULL on every tenant-data table"
scripts/run-tenancy-audit.sh:172:T1_RESULT=$(_psql_local <<EOF
scripts/run-tenancy-audit.sh:178:T1_TABLES=$(echo "${T1_RESULT}" | tr '\n' ' ' | tr -s ' ')
scripts/run-tenancy-audit.sh:181:ACTUAL_COUNT=$(echo "${T1_RESULT}" | grep -cE '\S')
scripts/run-tenancy-audit.sh:187:    if echo "${T1_TABLES}" | grep -qw "${t}"; then
scripts/run-tenancy-audit.sh:190:      _fail "T1: table ${t} missing tenant_slug NOT NULL"
scripts/run-tenancy-audit.sh:197:echo "${T1_RESULT}" > "${LOG_DIR}/T1-tables.log"
scripts/run-tenancy-audit.sh:220:  _pass "All 9 tenant-data tables have RLS enabled"
scripts/run-tenancy-audit.sh:248:  _pass "All 9 tenant-data tables have isolation policy attached"
scripts/run-tenancy-audit.sh:262:# Expected: RLS rejects OR inserted row remains invisible to the app role.
scripts/run-tenancy-audit.sh:328:  _fail "T5: Expected permission-denied on DELETE; got: ${T5_DELETE}"
scripts/run-tenancy-audit.sh:441:# T10 — Voice corpus single-active-per-tenant partial unique
scripts/run-tenancy-audit.sh:444:_step "T10 — Voice corpus is_active=TRUE partial unique"
scripts/run-tenancy-audit.sh:446:T10_INDEX=$(_psql_local <<EOF
scripts/run-tenancy-audit.sh:452:if [[ -n "${T10_INDEX}" ]]; then
scripts/run-tenancy-audit.sh:455:  _fail "T10: Partial unique index missing on voice_corpus"
scripts/run-tenancy-audit.sh:459:T10_ADV=$(_psql_local <<EOF 2>&1
scripts/run-tenancy-audit.sh:467:if echo "${T10_ADV}" | grep -qi "duplicate\|unique\|conflict"; then
scripts/run-tenancy-audit.sh:475:  _fail "T10: Adversarial second-is_active INSERT NOT rejected" "${T10_ADV}"
scripts/run-tenancy-audit.sh:479:# T11 — Cross-tenant RLS structural block (re-verify Day-4 §7)
scripts/run-tenancy-audit.sh:482:_step "T11 — Cross-tenant RLS structural block"
scripts/run-tenancy-audit.sh:487:T11_FAILED=0
scripts/run-tenancy-audit.sh:494:    _fail "T11: Cross-tenant read on ${table} returned ${count} rows (expected 0)"
scripts/run-tenancy-audit.sh:495:    T11_FAILED=$((T11_FAILED+1))
scripts/run-tenancy-audit.sh:499:if (( T11_FAILED == 0 )); then
scripts/run-tenancy-audit.sh:504:# T12 — _shared/ helpers tenant-agnostic (grep audit)
scripts/run-tenancy-audit.sh:507:_step "T12 — _shared/ helpers tenant-agnostic"
scripts/run-tenancy-audit.sh:511:T12_HITS=$(grep -rEn "'[a-z][a-z0-9-]{2,}'" \
scripts/run-tenancy-audit.sh:517:if [[ -z "${T12_HITS}" ]]; then
scripts/run-tenancy-audit.sh:520:  _warn "T12: candidate hard-coded slug refs (manual review needed):"
scripts/run-tenancy-audit.sh:521:  echo "${T12_HITS}" | sed 's/^/    /'
scripts/run-tenancy-audit.sh:525:echo "${T12_HITS}" > "${LOG_DIR}/T12-hardcoded-slug-grep.log"
docs/RISK-REGISTER.md:65:- 2026-05-20 (Day 9 evening) — **Architecture + tenancy verification slice complete.** 3 commits (`5c3fa66` + `c4348aa` + this commit). 4 new artefacts: tenancy-invariants.md (Reference; 12 invariants T1-T12 single source of truth), run-tenancy-audit.sh (multi-tenant adversarial smoke), architecture-cohesion-review.md (8-artefact cohesion + 14 remediation items + 4-boundary adversarial walk), tenant-lifecycle.md (Provision/Operate/Suspend/Offboard/Migrate). All 4 master-brief §3 boundaries verified HOLD at current artefact set. 3 of 5 contradictions in the ratified artefact set RESOLVED via ADR-004 + Day-8 remediation; 1 RESOLVED via consolidation in tenancy-invariants.md; 1 OPEN pending Founder Decision D3 (PII retention). 8 implicit assumptions documented; 3 catastrophic-if-false verified empirically. No new risks added — cohesion review's 14 remediation items + lifecycle's 8 gaps are all variance bounded by existing risks (#5 renderer + #10 PII + others) or low-severity lazy specs. Foundation deemed sound for Diagnostic build conditional on founder-decision bundle (D1+D2+D3) + Codex Round 2 closure + live tenancy audit pass.
docs/architecture/tenancy-invariants.md:22:**Meta vs tenant-data tables.** Postgres tables fall into two classes:
docs/architecture/tenancy-invariants.md:27:The 12 invariants below apply to **tenant-data tables**. The `tenants` meta table is the exception, documented separately under the verification matrix.
docs/architecture/tenancy-invariants.md:33:### T1 — Every tenant-data table has `tenant_slug TEXT NOT NULL`
docs/architecture/tenancy-invariants.md:38:- **Subtle case:** `recent_edit.original_text` was originally `TEXT NOT NULL` in v0.2; v0.3 (post Round-2 remediation) drops that NOT NULL constraint to allow PII purge to set `original_text=NULL`. This does not weaken T1: `recent_edit.tenant_slug` remains `TEXT NOT NULL`.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:58:  Expected: 9 rows (same set as T1).
docs/architecture/tenancy-invariants.md:71:  Expected: 9 rows, one per tenant-data table, policy name follows naming convention.
docs/architecture/tenancy-invariants.md:77:- **Enforcement:** `agents/_shared/hook-helpers.sh::_hh_emit_row` sets it via `SET LOCAL app.current_tenant = '${tenant}';` before INSERT. `agents/_shared/voice-loader.sh::_vl_psql_query` sets it via wrapped SQL. `packages/agent-renderer/src/renderer.ts` doesn't write to tenant-data tables directly (it writes to vault).
docs/architecture/tenancy-invariants.md:97:  Expected: 4 rows total — `decision_log` × {SELECT, INSERT}, `recent_edit` × {SELECT, INSERT}. No UPDATE or DELETE.
docs/architecture/tenancy-invariants.md:111:  Expected: mode 700, owned by ifos user. Find returns no symlinks pointing outside.
docs/architecture/tenancy-invariants.md:125:  Expected: only `config.json` differs (different tenant_slug) and `.env` differs (different secrets); no cross-references.
docs/architecture/tenancy-invariants.md:137:  Expected: `600`.
docs/architecture/tenancy-invariants.md:149:  Expected: `^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$`.
docs/architecture/tenancy-invariants.md:153:### T10 — Voice corpus `is_active=TRUE` enforced unique per tenant
docs/architecture/tenancy-invariants.md:163:  Expected: 1 row with partial UNIQUE on `tenant_slug WHERE is_active=true`.
docs/architecture/tenancy-invariants.md:167:### T11 — Cross-tenant RLS structurally blocks reads even when app code forgets the guard
docs/architecture/tenancy-invariants.md:179:  Expected: 0 rows from every cross-tenant read attempt.
docs/architecture/tenancy-invariants.md:180:- **Acceptance:** **VERIFIED Day-4 §7 (5/5 conditions).** Re-verified by tenancy audit Step T11 in this slice.
docs/architecture/tenancy-invariants.md:182:### T12 — `_shared/` helpers are tenant-agnostic (no hard-coded tenant slugs)
docs/architecture/tenancy-invariants.md:193:  Expected: zero hits (or only intentional examples in comments).
docs/architecture/tenancy-invariants.md:202:| T1 | Partial → Verified | Day-4 §7 schema-creation gate + tenancy audit | 2026-05-17 Day-4 (Day-4 tables); pending Day-9 (v0.2 tables + cross-validation) | All 9 tables expected to pass; v0.2 tables structurally identical pattern |
docs/architecture/tenancy-invariants.md:211:| T10 | Partial → Verified | v0.2 migration §2 partial unique index + tenancy audit | v0.2 migration design; pending Day-9 functional verify (post live migration) | Single-active voice corpus per tenant |
docs/architecture/tenancy-invariants.md:212:| T11 | **VERIFIED** | Day-4 §7 RLS isolation gate (5/5 conditions) + Phase 2 stress test | 2026-05-17 Day-4 | The only adversarially-verified invariant; foundation of the layered defence |
docs/architecture/tenancy-invariants.md:213:| T12 | Partial → Verified | grep audit + code review | Phase 1 + Phase 3 + Phase 5 commits; pending Day-9 audit grep | Tenant-agnostic helpers |
docs/architecture/tenancy-invariants.md:221:The 12 invariants above are the v1.0 set. Adding a new invariant (T13+) OR modifying an existing one requires:
docs/architecture/tenancy-invariants.md:236:- **Pre-migration**: Day-4 §6.5 provision-tenant workflow + v0.1-to-v0.2.sql migration enforce T1, T2, T3, T5, T9, T10 at schema creation.
docs/architecture/tenancy-invariants.md:237:- **At every agent runtime write**: hook-helpers.sh + voice-loader.sh enforce T4 via `SET LOCAL app.current_tenant` pattern; relies on T11 (Postgres RLS) as the structural backstop.
docs/architecture/tenancy-invariants.md:238:- **At every code review**: `_shared/` changes audited for T12 hard-coded slug introduction.
docs/architecture/tenancy-invariants.md:239:- **At every tenancy audit run**: `scripts/run-tenancy-audit.sh` (companion artefact) verifies T1-T12 against live VPS.
docs/architecture/tenancy-invariants.md:249:| Q1 | Should T4 be promoted to structural via stored-procedure wrappers (so app code physically cannot INSERT without `SET LOCAL`)? | If Day-9 tenancy audit reveals an app-code path forgot the guard, AND the cost of T11 catching the leak is unacceptable (e.g., partial writes). |
docs/architecture/tenancy-invariants.md:253:| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
scripts/run-codex-ratification.sh:376:    [[ $# -ne 2 ]] && { _fail "Expected 2 args"; exit 2; }
docs/build-brief/00-MASTER-BRIEF.md:356:   created_at: 2026-05-16T14:32:00Z
docs/build-brief/00-MASTER-BRIEF.md:357:   updated_at: 2026-05-16T14:32:00Z
docs/build-brief/00-MASTER-BRIEF.md:682:        │   v1.2 (+5): Real-Time Pulse, Spec Pitcher, Reporting, T1 Onboarding Concierge, T2 Timesheet     │
docs/runbooks/day-4-provisioning.md:144:# Expected: ssh-ed25519
docs/runbooks/day-4-provisioning.md:153:# Expected: main (or a Day 4 feature branch if working off-main)
docs/runbooks/day-4-provisioning.md:156:# Expected: latest commit reflects Day 3 evening close
docs/runbooks/day-4-provisioning.md:162:# Expected: ifos-v2
docs/runbooks/day-4-provisioning.md:235:# Expected: shell prompt as root@ifos-v2-prod-01
docs/runbooks/day-4-provisioning.md:245:# Expected: ifos-v2-prod-01
docs/runbooks/day-4-provisioning.md:248:# Expected: Ubuntu 24.04 LTS
docs/runbooks/day-4-provisioning.md:251:# Expected: sda (40 GB OS disk) and sdb (50 GB Block Storage volume, unformatted)
docs/runbooks/day-4-provisioning.md:299:# Expected: root
docs/runbooks/day-4-provisioning.md:338:# Expected: Status: active, three ALLOW IN rules
docs/runbooks/day-4-provisioning.md:363:# Expected: Jail is active
docs/runbooks/day-4-provisioning.md:373:# Expected: maddox
docs/runbooks/day-4-provisioning.md:377:# Expected: "Permission denied" or similar — connection rejected
docs/runbooks/day-4-provisioning.md:381:# Expected: "Permission denied (publickey)"
docs/runbooks/day-4-provisioning.md:404:# Expected output (your volume name will differ):
docs/runbooks/day-4-provisioning.md:412:# Expected: 50G, no children (unformatted)
docs/runbooks/day-4-provisioning.md:450:# Expected: status: active, cipher: aes-xts-plain64
docs/runbooks/day-4-provisioning.md:461:# Expected: LABEL="ifos_data" TYPE="ext4"
docs/runbooks/day-4-provisioning.md:476:# Expected: 50GB volume mounted at /mnt/ifos_data
docs/runbooks/day-4-provisioning.md:491:# Expected: three mount lines
docs/runbooks/day-4-provisioning.md:512:# Expected: no errors
docs/runbooks/day-4-provisioning.md:546:# Expected: no output (syntax OK)
docs/runbooks/day-4-provisioning.md:582:# Expected: /var/lib/postgresql/16/main
docs/runbooks/day-4-provisioning.md:585:# Expected: filesystem is /dev/mapper/ifos_data (the LUKS volume), not /dev/sda
docs/runbooks/day-4-provisioning.md:589:# Expected: one row, name=vector
docs/runbooks/day-4-provisioning.md:685:# Expected: vector, pg_trgm, btree_gin all present
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:825:# Expected: one CHECK constraint with the five values
docs/runbooks/day-4-provisioning.md:896:# Expected: no output
docs/runbooks/day-4-provisioning.md:912:# Expected:
docs/runbooks/day-4-provisioning.md:1009:-- Expected: 1
docs/runbooks/day-4-provisioning.md:1014:-- Expected: 0  ← THE GATE
docs/runbooks/day-4-provisioning.md:1021:-- Expected: ERROR — new row violates row-level security policy
docs/runbooks/day-4-provisioning.md:1027:-- Expected: 1
docs/runbooks/day-4-provisioning.md:1038:### §7.3 — Expected pass criteria
docs/runbooks/day-4-provisioning.md:1082:# Expected: file exists, ~10-50KB for empty schema
docs/operations/bullhorn-outreach-emails.md:70:**Expected response time:** 2-5 business days. If no response by Wednesday 2026-05-28: nudge with a one-line follow-up referencing the original message.
docs/operations/bullhorn-outreach-emails.md:126:**Expected response time:** 2-5 business days (often faster for technical-tier developer support than partnerships).
docs/operations/bullhorn-outreach-emails.md:160:**Reference.** Two drop-in email drafts ready for founder to send. Expected wall-clock: 1 week for both responses. Outcome: Sub-decisions A + B flip Accepted; Risk #2 mitigated; Janitor W5 build unblocked.
docs/specs/ULTRAPLAN.md:670:| T1 Onboarding Concierge | M (1 week) | Bullhorn (write), DocuSign, Microsoft Graph | Tracks onboarding tasks; less reasoning-heavy |
docs/specs/ULTRAPLAN.md:700:| T1 Onb. Concierge | ✓ | ✓ | ✓ | | | ✓ | | | | ✓ | DocuSign |
docs/runbooks/tenant-lifecycle.md:118:# Expect: all 12 invariants pass; new tenant appears in T1-T3 enumerations
docs/runbooks/tenant-lifecycle.md:133:- Initial voice_corpus row with `is_active=TRUE` (T10 invariant)
docs/runbooks/tenant-lifecycle.md:149:| Voice corpus re-index | Operator uploads new docs to `/vault/<slug>/_voice/`; `ifosctl reindex-voice --tenant <slug>` runs ingest pipeline + flips `is_active` atomically | T10 (single-active per tenant) |
docs/runbooks/tenant-lifecycle.md:150:| Tone rule add/edit | Tenant operator edits `/vault/<slug>/_voice/tone-rules.yaml` OR Brain UI v1.1; sync to Postgres `tone_rule` table | T1-T3 (RLS isolation) |
docs/runbooks/tenant-lifecycle.md:338:- **T1-T3**: every tenant-data table has tenant_slug + RLS + policy (structural; can't be transiently violated)
docs/runbooks/tenant-lifecycle.md:343:- **T10**: voice_corpus is_active=TRUE single-per-tenant (Migrate transition needs atomic flip)
docs/runbooks/tenant-lifecycle.md:344:- **T11**: cross-tenant RLS block (structural; permanent)
docs/runbooks/tenant-lifecycle.md:345:- **T12**: `_shared/` helpers tenant-agnostic (compile-time invariant; not state-dependent)
docs/runbooks/tenant-lifecycle.md:351:- **Voice corpus re-index** (Active sub-state): new `voice_corpus` row inserted with `is_active=TRUE`; old row updated to `is_active=FALSE` in same transaction. Partial unique index (T10) enforces no two `is_active=TRUE` rows simultaneously.
docs/operations/codex-round-2-autonomous-prompt.md:18:**Expected runtime:** ~6-9 hours of Codex time. Founder can walk away.
docs/operations/codex-round-2-autonomous-prompt.md:63:docs/architecture/tenancy-invariants.md §2 (T1-T12) at the start of your 
docs/operations/goal-option-c-diagnostic-end-to-end.md:308:| Web scraper hits a JS-heavy site that returns no text | Expected (gotcha §6.1); §2 reports "site requires JS, signal unavailable"; counts as graceful degradation (fixture 02 already verifies this); no Gate A impact. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:383:Sections:          12/12
docs/operations/codex-ratification-guide.md:113:Expected output:
docs/operations/codex-ratification-guide.md:130:Expected: prints clusters A/B/C/D with their artefact lists. No codex invocation needed for `--list-clusters`.
docs/operations/codex-ratification-guide.md:160:  ✓ Prompt assembled at logs/codex-ratification/20260520T143000Z-12345/...prompt.md
docs/operations/codex-ratification-guide.md:229:Expected time: ~3h20m mean per execution plan §5. Includes round-trips on ~10% of artefacts (estimate 1-2 will REJECT).
docs/operations/codex-ratification-guide.md:239:Expected time: ~2h30m.
docs/operations/codex-ratification-guide.md:249:Expected time: ~1h.
docs/operations/codex-ratification-guide.md:407:  "session_id": "20260520T143000Z-12345",
docs/operations/codex-ratification-guide.md:420:WHERE payload->>'session_id' = '20260520T143000Z-12345'
docs/operations/codex-round-2-remediation-prompt.md:129:         existing SELECT as the T11 read-isolation check):
docs/operations/codex-round-2-remediation-prompt.md:132:      # Expected: RLS rejects (returns 0 rows affected) OR insert succeeds
docs/operations/codex-round-2-remediation-prompt.md:341:T11 (RLS structural block) is unaffected but the column nullability is
docs/operations/codex-round-2-remediation-prompt.md:342:now a new invariant. Update docs/architecture/tenancy-invariants.md §2 T1
docs/operations/codex-round-2-remediation-prompt.md:353:  must T1-T3 + T11 + T12 update the table inventory + audit script?
docs/operations/codex-round-2-remediation-prompt.md:520:    - tenancy-invariants.md §2 T1: recent_edit.original_text nullability
docs/operations/codex-round-2-remediation-prompt.md:608:Expected runtime: 3-4 hours. The founder is walking away during the run.
docs/operations/codex-round-2-remediation-prompt.md:631:- tenancy-invariants.md §2 T1 (nullability subtle case) + §6 Q5 (autosend_approval_mappings inventory)
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
docs/decisions/autosend-safety-policy.md:344:**Expected resolution:** IFOS oncall investigates within 1h during business hours; within 4h outside business hours. The affected tenant pilot may be PAUSED for that agent until policy is fixed (per `v1.0-kill-criterion.md` §2 trigger 5).
docs/decisions/autosend-safety-policy.md:654:**Proposed.** Founder review pending. Codex Day-7 ratification queued. Expected status progression:
docs/specs/PRODUCT-SPEC.md:184:#### T1. Onboarding Concierge — contractor onboarding done right, once
docs/specs/PRODUCT-SPEC.md:253:| **Full Temp Sub-Platform** | £5,950 | T1–T6 complete | "Two FTEs of back-office drag replaced. £20k–£80k/year of margin leakage recovered through reconciliation. Full IR35 + JSL + holiday-pay evidence pack always audit-ready." |
docs/specs/PRODUCT-SPEC.md:502:- T1 Onboarding Concierge
docs/specs/PRODUCT-SPEC.md:534:13. **T1 Onboarding Concierge** — "First 2 weeks of every contract done correctly, every time."
docs/operations/codex-round-2-handoff.md:37:# Expected: codex v0.x.y
docs/operations/codex-round-2-handoff.md:42:# Expected: signed in OR API key present
docs/operations/codex-round-2-handoff.md:46:# Expected: SKILL.md + review-architecture-decision.md + review-schema-change.md + review-postgres-migration.md
docs/operations/codex-round-2-handoff.md:49:# Expected: "§1-Exemption — Softening for Reference + In Force (Codex Round 1 D5)"
docs/operations/codex-round-2-handoff.md:54:# Expected: lists Clusters A/B/C/D with member files
docs/operations/codex-round-2-handoff.md:146:**Expected time:** 4-5h total (clusters A+B+C ~3h; 12 individual ratifications ~10-15 min each ≈ 2h).
docs/operations/codex-round-2-handoff.md:296:Expected for Tier 2 + most of Tier 3. Manifest queue marks as ratified. No further action.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:93:| Web-scraper implementation + 12/12 tests | ✅ | `860f29c` |
docs/decisions/autosend-approval-bridge-spec.md:124:This adds the 10th tenant-data table (T1-T12 invariants apply). Tenancy-invariants.md needs update on landing.
docs/decisions/autosend-approval-bridge-spec.md:128:`autosend_approval_mappings` becomes the 10th tenant-data table when the bridge implementation lands. The Week-9 bridge implementation slice MUST update `docs/architecture/tenancy-invariants.md` §1 and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` to include this table in T1-T3, T11, and audit coverage. This remediation corrects the spec only; the table does not exist yet, so the live invariant inventory remains the v0.2 nine-table set until the bridge migration ships.
docs/decisions/autosend-approval-bridge-spec.md:231:Total schema impact: 1 new table; tenancy-invariants.md grows from 12 to 13 invariants (T13: autosend_approval_mappings tenant_slug + RLS), or we count this as covered by T1-T3 already (cleaner).
docs/decisions/autosend-approval-bridge-spec.md:244:| A6 | RLS: bridge writing tenant-A's approval cannot leak tenant-B's pending markers | Tenancy audit T11 extension: cross-tenant marker read returns 0 |
docs/decisions/autosend-approval-bridge-spec.md:306:- Adds 1 tenant-data table (`autosend_approval_mappings`) → tenancy-invariants.md update OR considered covered by T1-T3 patterns
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:52:- **D2-A: Engage UK SaaS lawyer this week** (recommended advisors: a) Bowers Anderson, b) recommended-by-Jack contact, c) any-firm-that-handles-recruiter-SaaS). Expected cost: £500-2000 for LOI template + jurisdiction clauses + PII liability clauses. **Recommended.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:8:- Round 4: `logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:9:- Round 5: `logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:118:| Diagnostic | 5 (same as Round 5 but with Issue-5-validate-impl-gap replacing Issue-5-doc-shape) | `logs/codex-ratification/20260524T101934Z-19923/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:119:| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:123:| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:157:After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:272:| Diagnostic | 5 | `20260524T112636Z-79455` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:273:| Janitor | 6 | `20260524T112807Z-81339` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:274:| Scribe | 5 | `20260524T112917Z-82352` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:275:| Cash Conductor | 5 | `20260524T113038Z-83732` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:276:| Sourcing Scout | 4 | `20260524T113139Z-84869` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:277:| Concierge | 7 | `20260524T113247Z-86019` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/v1.0-kill-criterion.md:393:**Proposed.** Founder review pending. Codex Day-7 ratification queued. Expected progression:
docs/architecture/second-brain-design.md:242:| Timesheet | **v1.1+** | IFOS Temp T2 Timesheet Ranger and T6 Pay & Bill Reconciler are v1.2; T1 Onboarding (v1.2) touches them indirectly |
docs/architecture/second-brain-design.md:254:created_at: 2026-05-16T14:32:00Z                     # required; ISO 8601 UTC
docs/architecture/second-brain-design.md:255:updated_at: 2026-05-16T14:32:00Z                     # required; ISO 8601 UTC
docs/architecture/second-brain-design.md:710:- t=0+300ms: Concierge releases flock after writing the narrative line and updating Postgres (`updated_at = T1`). The atomic file rename completes.
docs/architecture/second-brain-design.md:711:- t=0+301ms: Janitor acquires flock. Reads file (now contains Concierge's append). Reads Postgres (`updated_at = T1`). Computes new frontmatter. Writes file atomically. Postgres UPDATE `WHERE updated_at = T1` succeeds (`updated_at = T2`).
docs/decisions/2026-05-18-codex-ratification-manifest.md:144:| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:145:| 2 | `agents/recruitment/janitor/agent.md` | **REJECTED** | ~5-7 real findings (count regex 56 inflated by nested lists) | `20260524T102050Z-21293` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:146:| 3 | `agents/recruitment/scribe/agent.md` | **REJECTED** | ~5-7 real findings (count regex 59) | `20260524T102202Z-22338` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:196:**Round-2 expected:** re-run Cluster A+B+C after `2b287d3` lands. Expected 14 → 0-2 REJECTED (0-2 being the disagreement-resolution artefacts pending founder D5 verdict).

exec
/bin/zsh -lc 'rg -n "CREATE TABLE IF NOT EXISTS voice_corpus|CREATE TABLE IF NOT EXISTS recent_edit|GRANT .*recent_edit|voice_corpus_active|is_active|severity|applies_to_agents|resolution" docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
46:CREATE TABLE IF NOT EXISTS voice_corpus (
56:  is_active             BOOLEAN     NOT NULL DEFAULT FALSE,
65:  WHERE is_active = TRUE;
82:CREATE TABLE IF NOT EXISTS voice_corpus_chunks (
118:  severity            TEXT        NOT NULL CHECK (severity IN ('info', 'warn', 'block')),
119:  applies_to_agents   TEXT[]      NOT NULL DEFAULT '{}',
141:CREATE TABLE IF NOT EXISTS recent_edit (
151:  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
180:GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
185:GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
292:  last_indexed_at, is_active, ingest_completion_ms

codex
One concrete blocker is emerging around the tenancy quality gate: the supplement adds two tenant-data tables, but the existing audit inventory still names the v0.2 nine-table set. I’m checking whether there are any additional schema-specific blockers before finalizing.
exec
/bin/zsh -lc "nl -ba scripts/run-tenancy-audit.sh | sed -n '240,540p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/architecture/tenancy-invariants.md | sed -n '1,120p' && nl -ba docs/architecture/tenancy-invariants.md | sed -n '220,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   240	T3_MISSING=()
   241	for t in "${TENANT_TABLES[@]}"; do
   242	  if ! echo "${T3_RESULT}" | grep -qw "${t}"; then
   243	    T3_MISSING+=("${t}")
   244	  fi
   245	done
   246	
   247	if (( ${#T3_MISSING[@]} == 0 )); then
   248	  _pass "All 9 tenant-data tables have isolation policy attached"
   249	else
   250	  for t in "${T3_MISSING[@]}"; do
   251	    _fail "T3: table ${t} has no tenant_isolation policy"
   252	  done
   253	fi
   254	
   255	# ────────────────────────────────────────────────────────────────────────
   256	# T4 — Adversarial: INSERT without SET LOCAL app.current_tenant
   257	# ────────────────────────────────────────────────────────────────────────
   258	
   259	_step "T4 — Missing-SET-LOCAL adversarial WRITE"
   260	
   261	# T4 — adversarial: INSERT without SET LOCAL app.current_tenant.
   262	# Expected: RLS rejects OR inserted row remains invisible to the app role.
   263	T4_WRITE_RESULT=$(_psql_local <<EOF 2>&1
   264	BEGIN;
   265	-- DO NOT set app.current_tenant
   266	INSERT INTO decision_log (tenant_slug, agent_name, phase, payload, created_at)
   267	VALUES ('rls-probe-tenant', '_t4_probe', 'trigger', '{}'::jsonb, now());
   268	SELECT count(*) FROM decision_log
   269	  WHERE agent_name='_t4_probe' AND tenant_slug='rls-probe-tenant';
   270	ROLLBACK;
   271	EOF
   272	)
   273	
   274	if echo "${T4_WRITE_RESULT}" | grep -qi "row-level security\|violates row-level"; then
   275	  _pass "Missing-SET-LOCAL INSERT rejected by RLS"
   276	elif echo "${T4_WRITE_RESULT}" | grep -qE "^0[[:space:]]*$"; then
   277	  _pass "Missing-SET-LOCAL INSERT then SELECT returns 0 rows (RLS structural block)"
   278	else
   279	  _fail "T4: Missing-SET-LOCAL INSERT path returned visible rows — possible leak" "${T4_WRITE_RESULT}"
   280	fi
   281	echo "${T4_WRITE_RESULT}" > "${LOG_DIR}/T4-missing-set-local-write.log"
   282	
   283	# Without setting app.current_tenant, attempt to read from decision_log.
   284	# RLS should return 0 rows.
   285	T4_RESULT=$(_psql_local <<EOF 2>&1
   286	SELECT count(*) FROM decision_log;
   287	EOF
   288	)
   289	
   290	if [[ "${T4_RESULT}" =~ ^0[[:space:]]*$ ]]; then
   291	  _pass "Missing-SET-LOCAL SELECT returns 0 rows (RLS structural block)"
   292	else
   293	  _fail "T4: Missing-SET-LOCAL SELECT returned ${T4_RESULT} rows — possible RLS leak"
   294	fi
   295	echo "${T4_RESULT}" > "${LOG_DIR}/T4-missing-set-local.log"
   296	
   297	# ────────────────────────────────────────────────────────────────────────
   298	# T5 — ifos_app has no DELETE on decision_log or recent_edit
   299	# ────────────────────────────────────────────────────────────────────────
   300	
   301	_step "T5 — Append-only on decision_log + recent_edit"
   302	
   303	T5_RESULT=$(_psql_local <<EOF
   304	SELECT table_name, privilege_type FROM information_schema.role_table_grants
   305	WHERE grantee='ifos_app' AND table_name IN ('decision_log','recent_edit')
   306	ORDER BY table_name, privilege_type;
   307	EOF
   308	)
   309	echo "${T5_RESULT}" > "${LOG_DIR}/T5-grants.log"
   310	
   311	T5_BAD=$(echo "${T5_RESULT}" | grep -E "DELETE|UPDATE" || true)
   312	
   313	if [[ -z "${T5_BAD}" ]]; then
   314	  _pass "decision_log + recent_edit are append-only (no UPDATE or DELETE for ifos_app)"
   315	else
   316	  _fail "T5: Unexpected mutate-grant" "${T5_BAD}"
   317	fi
   318	
   319	# Adversarial DELETE attempt should fail with permission denied
   320	T5_DELETE=$(_psql_local <<EOF 2>&1
   321	SET app.current_tenant='${TENANT_A}';
   322	DELETE FROM decision_log WHERE 1=0;
   323	EOF
   324	)
   325	if echo "${T5_DELETE}" | grep -qi "permission denied"; then
   326	  _pass "Adversarial DELETE on decision_log returns permission denied"
   327	else
   328	  _fail "T5: Expected permission-denied on DELETE; got: ${T5_DELETE}"
   329	fi
   330	
   331	# ────────────────────────────────────────────────────────────────────────
   332	# T6 — Vault permissions + no cross-tenant symlinks (VPS-side)
   333	# ────────────────────────────────────────────────────────────────────────
   334	
   335	_step "T6 — Vault permissions + symlink containment (VPS-side via SSH)"
   336	
   337	T6_PERMS=$(ssh -i "${VPS_SSH_KEY}" "${VPS_SSH_USER}@${VPS_HOST}" \
   338	  "stat -c '%a %U:%G' /vault/${TENANT_A} 2>/dev/null || echo 'NOT_FOUND'")
   339	
   340	if [[ "${T6_PERMS}" =~ ^(700|750) ]]; then
   341	  _pass "/vault/${TENANT_A} permissions OK (${T6_PERMS})"
   342	else
   343	  _warn "T6: /vault/${TENANT_A} permissions: ${T6_PERMS} (expected 700 or 750)"
   344	fi
   345	echo "${T6_PERMS}" > "${LOG_DIR}/T6-vault-perms.log"
   346	
   347	# Find any symlinks pointing outside the tenant's own vault
   348	T6_SYMLINKS=$(ssh -i "${VPS_SSH_KEY}" "${VPS_SSH_USER}@${VPS_HOST}" \
   349	  "find /vault/${TENANT_A} -type l -exec readlink -f {} \; 2>/dev/null | grep -v '^/vault/${TENANT_A}' | head -5")
   350	
   351	if [[ -z "${T6_SYMLINKS}" ]]; then
   352	  _pass "No cross-tenant symlinks in /vault/${TENANT_A}"
   353	else
   354	  _fail "T6: Cross-tenant symlinks found" "${T6_SYMLINKS}"
   355	fi
   356	
   357	# ────────────────────────────────────────────────────────────────────────
   358	# T7 + T8 — Cross-tenant rendered-dir isolation + .env chmod (LOCAL render)
   359	# ────────────────────────────────────────────────────────────────────────
   360	
   361	_step "T7 + T8 — Cross-tenant rendered-dir + .env chmod (local render)"
   362	
   363	LOCAL_RENDER_ROOT="/tmp/ifos-tenancy-audit-${SESSION_ID}"
   364	rm -rf "${LOCAL_RENDER_ROOT}"
   365	
   366	# Render same agent into both tenants locally (no VPS write)
   367	for tenant in "${TENANT_A}" "${TENANT_B}"; do
   368	  node "${REPO_ROOT}/packages/agent-renderer/dist/cli.js" render test-agent \
   369	    --tenant "${tenant}" \
   370	    --bundle-root "${REPO_ROOT}/packages/agent-renderer/tests/fixtures" \
   371	    --vault-root "${REPO_ROOT}/packages/agent-renderer/tests/fixtures/test-tenant-vault/${tenant}" \
   372	    --framework-root "${LOCAL_RENDER_ROOT}" \
   373	    > "${LOG_DIR}/T7-render-${tenant}.log" 2>&1
   374	done
   375	
   376	# T7: verify disjoint dirs with no cross-references
   377	DIR_A="${LOCAL_RENDER_ROOT}/orgs/${TENANT_A}/agents/test-agent"
   378	DIR_B="${LOCAL_RENDER_ROOT}/orgs/${TENANT_B}/agents/test-agent"
   379	
   380	if [[ -d "${DIR_A}" ]] && [[ -d "${DIR_B}" ]]; then
   381	  _pass "Both tenants rendered into separate orgs/ subtrees"
   382	
   383	  # Verify tenant-A's files don't reference tenant-B (other than legitimate template)
   384	  CROSS_A_B=$(grep -r "${TENANT_B}" "${DIR_A}" 2>/dev/null | head -5)
   385	  CROSS_B_A=$(grep -r "${TENANT_A}" "${DIR_B}" 2>/dev/null | head -5)
   386	  if [[ -z "${CROSS_A_B}" ]] && [[ -z "${CROSS_B_A}" ]]; then
   387	    _pass "Zero cross-tenant references in rendered files"
   388	  else
   389	    _fail "T7: Cross-tenant content leak in render output"
   390	    [[ -n "${CROSS_A_B}" ]] && echo "    A→B: ${CROSS_A_B}"
   391	    [[ -n "${CROSS_B_A}" ]] && echo "    B→A: ${CROSS_B_A}"
   392	  fi
   393	else
   394	  _fail "T7: Render failed for one or both tenants" "Check render logs in ${LOG_DIR}"
   395	fi
   396	
   397	# T8: verify .env chmod 0600 in both
   398	for tenant in "${TENANT_A}" "${TENANT_B}"; do
   399	  env_file="${LOCAL_RENDER_ROOT}/orgs/${tenant}/agents/test-agent/.env"
   400	  if [[ -f "${env_file}" ]]; then
   401	    mode=$(stat -f '%Lp' "${env_file}" 2>/dev/null || stat -c '%a' "${env_file}" 2>/dev/null)
   402	    if [[ "${mode}" == "600" ]]; then
   403	      _pass "${tenant}/.env mode 600"
   404	    else
   405	      _fail "T8: ${tenant}/.env mode is ${mode}, expected 600"
   406	    fi
   407	  else
   408	    _fail "T8: ${tenant}/.env not present"
   409	  fi
   410	done
   411	
   412	# ────────────────────────────────────────────────────────────────────────
   413	# T9 — Tenant slug pattern validation (adversarial bad slugs)
   414	# ────────────────────────────────────────────────────────────────────────
   415	
   416	_step "T9 — Tenant slug regex validation"
   417	
   418	BAD_SLUGS=("../etc/passwd" "Tenant_With_Capitals" "tenant with spaces" "-leading-dash" "trailing-dash-" "ab")
   419	PATTERN="^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$"
   420	
   421	T9_FAILED=0
   422	for slug in "${BAD_SLUGS[@]}"; do
   423	  if [[ "${slug}" =~ ${PATTERN} ]]; then
   424	    _fail "T9: Bad slug '${slug}' INCORRECTLY validates against pattern"
   425	    T9_FAILED=$((T9_FAILED+1))
   426	  fi
   427	done
   428	
   429	if (( T9_FAILED == 0 )); then
   430	  _pass "All ${#BAD_SLUGS[@]} adversarial bad slugs rejected by pattern"
   431	fi
   432	
   433	# Sanity: real slug accepted
   434	if [[ "migration-test" =~ ${PATTERN} ]]; then
   435	  _pass "Real slug 'migration-test' accepted"
   436	else
   437	  _fail "T9: Real slug 'migration-test' incorrectly rejected (pattern bug)"
   438	fi
   439	
   440	# ────────────────────────────────────────────────────────────────────────
   441	# T10 — Voice corpus single-active-per-tenant partial unique
   442	# ────────────────────────────────────────────────────────────────────────
   443	
   444	_step "T10 — Voice corpus is_active=TRUE partial unique"
   445	
   446	T10_INDEX=$(_psql_local <<EOF
   447	SELECT indexname FROM pg_indexes
   448	WHERE tablename='voice_corpus' AND indexname='voice_corpus_one_active_per_tenant';
   449	EOF
   450	)
   451	
   452	if [[ -n "${T10_INDEX}" ]]; then
   453	  _pass "voice_corpus_one_active_per_tenant partial unique index present"
   454	else
   455	  _fail "T10: Partial unique index missing on voice_corpus"
   456	fi
   457	
   458	# Adversarial: insert second is_active=TRUE row for migration-test
   459	T10_ADV=$(_psql_local <<EOF 2>&1
   460	SET app.current_tenant='${TENANT_A}';
   461	INSERT INTO voice_corpus (tenant_slug, version, source_doc_count, source_doc_origin,
   462	  chunk_count, chunking_strategy, embedding_model, last_indexed_at, is_active)
   463	VALUES ('${TENANT_A}', 'audit-duplicate-test', 0, '{}', 0, 'paragraph',
   464	  'text-embedding-3-small', now(), TRUE);
   465	EOF
   466	)
   467	if echo "${T10_ADV}" | grep -qi "duplicate\|unique\|conflict"; then
   468	  _pass "Adversarial second-is_active INSERT rejected by partial unique"
   469	else
   470	  # Clean up the duplicate if it landed
   471	  _psql_local <<EOF >/dev/null 2>&1
   472	SET app.current_tenant='${TENANT_A}';
   473	DELETE FROM voice_corpus WHERE version='audit-duplicate-test';
   474	EOF
   475	  _fail "T10: Adversarial second-is_active INSERT NOT rejected" "${T10_ADV}"
   476	fi
   477	
   478	# ────────────────────────────────────────────────────────────────────────
   479	# T11 — Cross-tenant RLS structural block (re-verify Day-4 §7)
   480	# ────────────────────────────────────────────────────────────────────────
   481	
   482	_step "T11 — Cross-tenant RLS structural block"
   483	
   484	# Set wrong tenant via PGOPTIONS (avoids "SET\n<count>" output noise);
   485	# try to read each tenant-data table — RLS must return zero rows
   486	WRONG_TENANT="not-the-real-tenant"
   487	T11_FAILED=0
   488	for table in "${TENANT_TABLES[@]}"; do
   489	  count=$(PGOPTIONS="-c app.current_tenant=${WRONG_TENANT}" psql -h localhost -p "${LOCAL_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -A -c "SELECT count(*) FROM ${table};")
   490	  count="${count// /}"
   491	  if [[ "${count}" == "0" ]]; then
   492	    :
   493	  else
   494	    _fail "T11: Cross-tenant read on ${table} returned ${count} rows (expected 0)"
   495	    T11_FAILED=$((T11_FAILED+1))
   496	  fi
   497	done
   498	
   499	if (( T11_FAILED == 0 )); then
   500	  _pass "All 9 tables: cross-tenant SELECT returns 0 rows under wrong tenant_slug"
   501	fi
   502	
   503	# ────────────────────────────────────────────────────────────────────────
   504	# T12 — _shared/ helpers tenant-agnostic (grep audit)
   505	# ────────────────────────────────────────────────────────────────────────
   506	
   507	_step "T12 — _shared/ helpers tenant-agnostic"
   508	
   509	# Look for hard-coded tenant slug references; exempt CTX env refs, examples,
   510	# test fixtures, and fallback placeholders
   511	T12_HITS=$(grep -rEn "'[a-z][a-z0-9-]{2,}'" \
   512	  "${REPO_ROOT}/agents/_shared/" \
   513	  "${REPO_ROOT}/packages/agents-runtime/_shared/" 2>/dev/null \
   514	  | grep -v "CTX_TENANT_SLUG\|tenant_slug\|examples\|test-tenant\|migration-test\|fallback\|escalation-codes.md\|README.md\|/tests/\|comments\|HH_AWAIT_TEST_MODE\|policy_lookup\|gating_failed\|fail-safe-red\|tenant-admin\|ifos-csm" \
   515	  | head -10)
   516	
   517	if [[ -z "${T12_HITS}" ]]; then
   518	  _pass "_shared/ grep audit: no hard-coded tenant slugs"
   519	else
   520	  _warn "T12: candidate hard-coded slug refs (manual review needed):"
   521	  echo "${T12_HITS}" | sed 's/^/    /'
   522	  # Don't fail on warnings; founder reviews
   523	fi
   524	
   525	echo "${T12_HITS}" > "${LOG_DIR}/T12-hardcoded-slug-grep.log"
   526	
   527	# ────────────────────────────────────────────────────────────────────────
   528	# Audit row write (decision_log live mode OR fallback)
   529	# ────────────────────────────────────────────────────────────────────────
   530	
   531	_step "Audit-row write (decision_log audit trail)"
   532	
   533	AUDIT_PAYLOAD=$(printf '{"session_id":"%s","pass_count":%d,"fail_count":%d,"failed_tests":"%s"}' \
   534	  "${SESSION_ID}" "${PASS_STEPS}" "${FAIL_STEPS}" "$(IFS=,; echo "${FAILED_TESTS[*]:-}")")
   535	
   536	AUDIT_PHASE="output"
   537	AUDIT_OUTCOME="passed"
   538	if (( FAIL_STEPS > 0 )); then
   539	  AUDIT_PHASE="gating_failed"
   540	  AUDIT_OUTCOME="failed"

 succeeded in 0ms:
     1	# Tenancy invariants — IFOS multi-tenant safety
     2	
     3	**Status:** Reference (In Force on tenant-data write paths).
     4	**Date:** 2026-05-20 (Day 9 evening — pre-Diagnostic-build architecture audit).
     5	**Author:** Founder (Maddox) + Claude Code; consolidates Day-4 §7 RLS gate + ADRs 001-004 + v0.1 + v0.2 schemas + `_shared/` helpers + renderer.
     6	**Authority:** This document supersedes scattered tenancy references in source artefacts. Any new tenant-touching code path is reviewed against the invariants below.
     7	
     8	---
     9	
    10	## §1 — Why this document exists
    11	
    12	IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
    13	
    14	Tenancy is enforced by **layered defence**:
    15	
    16	1. **Postgres RLS** is the structural last line of defence. If application code forgets to filter by tenant_slug, RLS still blocks cross-reads at the database engine level.
    17	2. **`SET LOCAL app.current_tenant`** in helper code is the upstream guard. If a path forgets to set it, RLS returns zero rows — explicit failure rather than silent leak.
    18	3. **Vault filesystem permissions** isolate `/vault/<tenant>/` directories.
    19	4. **Rendered agent dirs** at `${frameworkRoot}/orgs/<tenant>/agents/` are physically separate per tenant.
    20	5. **Tenant-agnostic helpers** in `agents/_shared/` never hard-code tenant slugs; everything reads `CTX_TENANT_SLUG` at runtime.
    21	
    22	**Meta vs tenant-data tables.** Postgres tables fall into two classes:
    23	
    24	- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
    25	- **Meta table** (1): `tenants` — the tenant registry itself. NO RLS by design (the registry needs to be visible to admin operations). All writes admin-only.
    26	
    27	The 12 invariants below apply to **tenant-data tables**. The `tenants` meta table is the exception, documented separately under the verification matrix.
    28	
    29	---
    30	
    31	## §2 — The 12 invariants
    32	
    33	### T1 — Every tenant-data table has `tenant_slug TEXT NOT NULL`
    34	
    35	- **Definition:** Every row in every tenant-data table carries a non-null `tenant_slug` identifying which tenant the row belongs to.
    36	- **Enforcement:** Migration SQL `CREATE TABLE` statement uses `tenant_slug TEXT NOT NULL` (no DEFAULT, no nullable).
    37	- **Documentation source:** Day-4 §6.3 lines 708-797 (5 tables) + v0.2 §2-§5 (4 tables).
    38	- **Subtle case:** `recent_edit.original_text` was originally `TEXT NOT NULL` in v0.2; v0.3 (post Round-2 remediation) drops that NOT NULL constraint to allow PII purge to set `original_text=NULL`. This does not weaken T1: `recent_edit.tenant_slug` remains `TEXT NOT NULL`.
    39	- **Verification command:**
    40	  ```sql
    41	  SELECT table_name FROM information_schema.columns
    42	  WHERE table_schema='public' AND column_name='tenant_slug' AND is_nullable='NO'
    43	  ORDER BY table_name;
    44	  ```
    45	  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
    46	- **Acceptance:** Every tenant-data table appears; `tenants` table appears only as a meta exception (which is correct — it has `tenant_slug PRIMARY KEY`).
    47	
    48	### T2 — Every tenant-data table has `ENABLE ROW LEVEL SECURITY`
    49	
    50	- **Definition:** Postgres RLS is enabled on every tenant-data table. Even if a policy is missing or misconfigured, RLS-enabled tables default to deny.
    51	- **Enforcement:** Migration SQL `ALTER TABLE <name> ENABLE ROW LEVEL SECURITY` per table.
    52	- **Documentation source:** Day-4 §6.3 lines 932-936 + v0.2 §2-§5 (4 ALTER TABLE statements).
    53	- **Verification command:**
    54	  ```sql
    55	  SELECT relname FROM pg_class c JOIN pg_namespace n ON c.relnamespace=n.oid
    56	  WHERE n.nspname='public' AND c.relrowsecurity=true ORDER BY relname;
    57	  ```
    58	  Expected: 9 rows (same set as T1).
    59	- **Acceptance:** Every tenant-data table appears; `tenants` does NOT (correct exception).
    60	
    61	### T3 — Every tenant-data table has a `tenant_isolation` policy
    62	
    63	- **Definition:** RLS policy named `<table>_tenant_isolation` (or `tenant_isolation` for Day-4 tables) attached to every tenant-data table, using `current_setting('app.current_tenant', TRUE)` as the predicate.
    64	- **Enforcement:** Migration SQL `CREATE POLICY` after `ENABLE ROW LEVEL SECURITY`. The `TRUE` second argument to `current_setting()` returns NULL on missing setting (safe — RLS returns 0 rows).
    65	- **Documentation source:** Day-4 §6.3 lines 951-973 + v0.2 §2-§5.
    66	- **Verification command:**
    67	  ```sql
    68	  SELECT tablename, policyname FROM pg_policies
    69	  WHERE schemaname='public' ORDER BY tablename;
    70	  ```
    71	  Expected: 9 rows, one per tenant-data table, policy name follows naming convention.
    72	- **Acceptance:** Every tenant-data table has its `_tenant_isolation` policy.
    73	
    74	### T4 — Every app-code write to a tenant-data table calls `SET LOCAL app.current_tenant` first
    75	
    76	- **Definition:** Application code (helpers, renderer, ad-hoc scripts) sets the session variable `app.current_tenant` BEFORE the first INSERT/UPDATE/SELECT against a tenant-data table. `SET LOCAL` scopes the setting to the current transaction.
    77	- **Enforcement:** `agents/_shared/hook-helpers.sh::_hh_emit_row` sets it via `SET LOCAL app.current_tenant = '${tenant}';` before INSERT. `agents/_shared/voice-loader.sh::_vl_psql_query` sets it via wrapped SQL. `packages/agent-renderer/src/renderer.ts` doesn't write to tenant-data tables directly (it writes to vault).
    78	- **Documentation source:** `agents/_shared/hook-helpers.sh` lines ~75-95 (`_hh_emit_row` live-mode SQL) + `agents/_shared/voice-loader.sh` lines ~60-70 (`_vl_psql_query`).
    79	- **Verification command:**
    80	  ```bash
    81	  grep -n "SET LOCAL app.current_tenant\|SET app.current_tenant" agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh packages/agent-renderer/src/*.ts
    82	  ```
    83	  Plus adversarial: try INSERT without setting it; expect failure OR succeed-with-RLS-block-on-read.
    84	- **Acceptance:** All write paths confirmed via grep + adversarial test in tenancy audit Step T4.
    85	
    86	### T5 — `ifos_app` role has no DELETE on `decision_log` or `recent_edit` (append-only audit tables)
    87	
    88	- **Definition:** The two audit tables (`decision_log` from Day-4 + `recent_edit` from v0.2) are structurally append-only. Even if app code attempted DELETE, the role lacks permission.
    89	- **Enforcement:** Migration SQL grants exactly `SELECT, INSERT` on these two tables (no UPDATE, no DELETE).
    90	- **Documentation source:** Day-4 §6.3 line 764 (`GRANT SELECT, INSERT ON decision_log TO ifos_app`) + v0.2 §6 line 172 (`GRANT SELECT, INSERT ON recent_edit TO ifos_app`).
    91	- **Verification command:**
    92	  ```sql
    93	  SELECT grantee, table_name, privilege_type FROM information_schema.role_table_grants
    94	  WHERE grantee='ifos_app' AND table_name IN ('decision_log','recent_edit')
    95	  ORDER BY table_name, privilege_type;
    96	  ```
    97	  Expected: 4 rows total — `decision_log` × {SELECT, INSERT}, `recent_edit` × {SELECT, INSERT}. No UPDATE or DELETE.
    98	- **Acceptance:** Adversarial DELETE attempt returns permission denied.
    99	
   100	### T6 — `/vault/<tenant>/` has restrictive permissions; no symlinks cross tenant boundaries
   101	
   102	- **Definition:** Per-tenant vault directories are owned by ifos system user, mode 700 (or 750 for ifos_app group access). No symlink inside `/vault/<tenant>/` points to a path outside `/vault/<tenant>/`.
   103	- **Enforcement:** Provisioning script (`scripts/provision-tenant.sh`, currently scattered in Day-4 §6.5) creates dirs with `chmod 700`. Renderer (`packages/agent-renderer/src/renderer.ts`) never writes symlinks into vault. The only symlink IFOS creates is at `${frameworkRoot}/orgs/<tenant>/agents/<agent>/.claude/hooks/_shared → ../../../_shared/` (Decision 2 of ADR-004) — that's the org-agents dir, NOT vault.
   104	- **Documentation source:** Day-4 §6.5 + ADR-003 §3.3.3 + ADR-004 Decision 2.
   105	- **Verification command:**
   106	  ```bash
   107	  # On VPS:
   108	  stat -c '%a %U:%G %n' /vault/migration-test
   109	  find /vault/migration-test -type l -exec readlink -f {} \; | grep -v '^/vault/migration-test'
   110	  ```
   111	  Expected: mode 700, owned by ifos user. Find returns no symlinks pointing outside.
   112	- **Acceptance:** No cross-tenant symlinks; restrictive perms.
   113	
   114	### T7 — Rendered agent dirs at `${frameworkRoot}/orgs/<tenant>/agents/` never cross-link
   115	
   116	- **Definition:** Rendering agent X for tenant A and tenant B produces two physically separate directories with disjoint contents. No file in tenant-A's rendered dir references tenant-B's data.
   117	- **Enforcement:** Renderer (`packages/agent-renderer/src/renderer.ts::render`) uses `ctx.orgAgentDir = ${frameworkRoot}/orgs/<tenant>/agents/<name>/` per-render. The `_shared/` symlink resolves via `../../../_shared/` which points to `<tenant>/agents/_shared/` (per-tenant, copied not shared).
   118	- **Documentation source:** ADR-003 §3.3.3 Option γ + ADR-004 Decision 2 + ADR-004 Decision 3.
   119	- **Verification command:**
   120	  ```bash
   220	
   221	The 12 invariants above are the v1.0 set. Adding a new invariant (T13+) OR modifying an existing one requires:
   222	
   223	1. **Surface in an ADR** — invariant changes are architectural decisions. Cannot edit this document inline; route through ADR-005+ and link.
   224	2. **Migration coverage** — if a new invariant requires schema changes, ship migration SQL alongside the ADR.
   225	3. **Audit coverage** — extend `scripts/run-tenancy-audit.sh` with the new test.
   226	4. **Codex ratification** — invariant document is ratified via `review-architecture-decision.md` skill; updates re-ratify.
   227	5. **Update RISK-REGISTER if applicable** — new invariant often surfaces a risk it's mitigating; document explicitly.
   228	
   229	The full provenance trail: ADR → tenancy-invariants.md update → migration SQL (if needed) → audit script update → Codex ratification → backlog closure.
   230	
   231	---
   232	
   233	## §5 — Where this document is enforced
   234	
   235	- **Pre-render**: ADR-003 §3.3.3 Option γ + ADR-004 Decision 2 + Decision 3 enforce T6, T7, T8 at render time.
   236	- **Pre-migration**: Day-4 §6.5 provision-tenant workflow + v0.1-to-v0.2.sql migration enforce T1, T2, T3, T5, T9, T10 at schema creation.
   237	- **At every agent runtime write**: hook-helpers.sh + voice-loader.sh enforce T4 via `SET LOCAL app.current_tenant` pattern; relies on T11 (Postgres RLS) as the structural backstop.
   238	- **At every code review**: `_shared/` changes audited for T12 hard-coded slug introduction.
   239	- **At every tenancy audit run**: `scripts/run-tenancy-audit.sh` (companion artefact) verifies T1-T12 against live VPS.
   240	
   241	This document is the **single source of truth**. ADRs, runbooks, and code comments reference it; the inverse — this document references them — completes the round-trip.
   242	
   243	---
   244	
   245	## §6 — Open questions surfaced during invariant consolidation
   246	
   247	| # | Question | Trigger to resolve |
   248	|---|---|---|
   249	| Q1 | Should T4 be promoted to structural via stored-procedure wrappers (so app code physically cannot INSERT without `SET LOCAL`)? | If Day-9 tenancy audit reveals an app-code path forgot the guard, AND the cost of T11 catching the leak is unacceptable (e.g., partial writes). |
   250	| Q2 | Should `tenants` meta table have an `enabled` boolean (vs `status` enum) to enable structural disable-without-delete? | If first tenant offboards and we discover row deletion is destructive to audit trail. Founder Decision D3 from Codex Round 1 may resolve. |
   251	| Q3 | Should `ifos_app` role be split into per-vertical roles (e.g., `ifos_app_recruitment`) to limit blast radius if `ifos_app` credentials leak? | If pilot reveals broader-than-recruitment workload that warrants role split. v1.1+ concern. |
   252	| Q4 | What is the test pattern for verifying T4 at code-review time (vs runtime audit)? | If Day-9 audit reveals false-negatives — code-review-style grep checks would be more reliable. |
   253	| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |
   254	
   255	---
   256	
   257	## §7 — Status
   258	
   259	**Reference (In Force on tenant-data write paths).** Codex ratification queue item #35; ratified via `.codex/ratification/review-architecture-decision.md`. Companion audit script at `scripts/run-tenancy-audit.sh` ratified as item #38. Both queued for Codex Round 3 after this commit ships.
   260	

exec
/bin/zsh -lc "ruby -e 'require \"yaml\"; YAML.load_file(\"docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml\"); puts \"yaml-ok\"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
yaml-ok

codex
REJECTED

1. New tenant-data tables are not covered by the required tenancy quality gate. The supplement adds `cash_conductor_transactions` and `cash_conductor_invoices` as auxiliary Postgres tables at lines 576-653, then says post-migration should run `scripts/run-tenancy-audit.sh` and expect T1-T12 to pass at line 806. But the audit script still hard-codes only the v0.2 nine-table inventory (`TENANT_TABLES` lines 68-72), and `tenancy-invariants.md` still says tenant-data tables are 9 at lines 22-25 and T1/T2/T3 expect 9 rows at lines 45, 58, and 71. This means the new tables can bypass T1-T3 and T11 audit coverage, violating Quality gates before features. Fix by updating `docs/architecture/tenancy-invariants.md` and `scripts/run-tenancy-audit.sh` to include both new tables in the tenant-data inventory and T1/T2/T3/T11 checks, or make v0.3 explicitly depend on a companion quality-gate update before migration.
tokens used
110,924
REJECTED

1. New tenant-data tables are not covered by the required tenancy quality gate. The supplement adds `cash_conductor_transactions` and `cash_conductor_invoices` as auxiliary Postgres tables at lines 576-653, then says post-migration should run `scripts/run-tenancy-audit.sh` and expect T1-T12 to pass at line 806. But the audit script still hard-codes only the v0.2 nine-table inventory (`TENANT_TABLES` lines 68-72), and `tenancy-invariants.md` still says tenant-data tables are 9 at lines 22-25 and T1/T2/T3 expect 9 rows at lines 45, 58, and 71. This means the new tables can bypass T1-T3 and T11 audit coverage, violating Quality gates before features. Fix by updating `docs/architecture/tenancy-invariants.md` and `scripts/run-tenancy-audit.sh` to include both new tables in the tenant-data inventory and T1/T2/T3/T11 checks, or make v0.3 explicitly depend on a companion quality-gate update before migration.
