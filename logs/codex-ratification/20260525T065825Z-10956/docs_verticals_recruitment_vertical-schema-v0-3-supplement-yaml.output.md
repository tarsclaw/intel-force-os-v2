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
session id: 019e5ded-7d0f-7761-a800-e0f2e18dbbe5
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
# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
# (v0.3-supplement-0.1 amendment Day-20: original 3 v0.3 keys + 2 Janitor keys
# added closing Janitor R11 Finding 4 + blocked_recipients added closing
# Sourcing Scout R8 Finding 1. blocked_recipients is pre-v0.3 origin
# canonicalised here. Total: 6 declarations in §4.)
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
# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
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
    type: number
    required: false
    default: 0.85
    range: [0.75, 0.95]
    set_by: [tenant-admin]
    read_by: [janitor]
    notes: |
      Per-tenant dedup confidence threshold for candidate merges. v1.0 default
      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
      via the wizard. The migration validator (v0.2-to-v0.3.sql §5 allowlist +
      type-validation trigger extension added in R19) enforces both the
      allowlist membership and the [0.75, 0.95] range. Schema declaration
      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.

  blocked_recipients:
    type: array
    items:
      type: string
    required: false
    default: []
    set_by: [tenant-admin, janitor]
    read_by: [concierge, sourcing-scout, cash-conductor, janitor]
    notes: |
      Per-tenant DNC (do not contact) list. v1.0 canonical source for outbound
      send refusal (autosend-safety-policy §5 red-tier action_type
      `send_to_blocked_recipient`) and pre-outbound sourcing filter (Sourcing
      Scout §4 Step 8). Per ADR-002 vault/Postgres split — structured state in
      Postgres, NOT vault markdown. Pre-v0.3 origin (the migration validator
      `v0.2-to-v0.3.sql §5 allowlist` has accepted this key since v0.1); the
      schema declaration in v0.3 supplement is added Day-20 W4 bilateral pass
      closing Sourcing Scout R8 Codex Finding 1 (the key was load-bearing
      across 4 agents but undeclared in any YAML).

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
  adds 14 entity JSONB keys + 2 auxiliary tables + 6 config keys (3 v0.3-
  new + 2 Janitor + 1 blocked_recipients pre-v0.3 canonicalised). The
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
I’ll verify the supplement against the repo rather than relying only on the pasted text, especially the referenced migrations and cited integration docs.
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
/bin/zsh -lc 'rg -n "bullhorn_id|agent_access_matrix|source:|relationship|voice_classifier_score|validate_entities_data_v0_3|cash_conductor_transactions|cash_conductor_invoices|blocked_recipients|janitor_last_run|cash_conductor_last_run|concierge_send_window" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql docs/verticals/recruitment/bullhorn-integration-path.md docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: docs/verticals/recruitment/bullhorn-integration-path.md: No such file or directory (os error 2)
docs/verticals/recruitment/vertical-schema.yaml:34:#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
docs/verticals/recruitment/vertical-schema.yaml:41:# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
docs/verticals/recruitment/vertical-schema.yaml:42:# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:58:      bullhorn_id:
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
docs/verticals/recruitment/vertical-schema.yaml:123:        source: IFOS-derived (GBP annual)
docs/verticals/recruitment/vertical-schema.yaml:127:        source: Bullhorn.Candidate.address.city
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:136:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.yaml:137:      source:
docs/verticals/recruitment/vertical-schema.yaml:141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
docs/verticals/recruitment/vertical-schema.yaml:142:      voice_classifier_score:
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:166:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:169:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:174:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:178:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:182:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:186:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:191:        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
docs/verticals/recruitment/vertical-schema.yaml:196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:200:        source: IFOS-derived (GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
docs/verticals/recruitment/vertical-schema.yaml:209:        source: IFOS-derived (when can contractor start, in weeks from now)
docs/verticals/recruitment/vertical-schema.yaml:213:        source: IFOS-derived
docs/verticals/recruitment/vertical-schema.yaml:224:    bullhorn_source: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:228:      - Concierge (R — relationship context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:230:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:233:        source: Bullhorn.ClientCorporation.id
docs/verticals/recruitment/vertical-schema.yaml:237:        source: Bullhorn.ClientCorporation.name
docs/verticals/recruitment/vertical-schema.yaml:241:        source: Bullhorn.ClientCorporation.industryList
docs/verticals/recruitment/vertical-schema.yaml:247:        source: Bullhorn.ClientCorporation.numEmployees (bucketed)
docs/verticals/recruitment/vertical-schema.yaml:251:        source: Bullhorn.ClientCorporation.companyURL
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:261:        source: IFOS-derived (Janitor maintains)
docs/verticals/recruitment/vertical-schema.yaml:265:        source: Bullhorn.ClientCorporation.owner.id
docs/verticals/recruitment/vertical-schema.yaml:269:        source: IFOS-derived (commercial framework; free text for v0.1; structured for v1.1+)
docs/verticals/recruitment/vertical-schema.yaml:273:        source: Bullhorn.ClientCorporation.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:277:        source: Bullhorn.ClientCorporation.address.city
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:286:    bullhorn_source: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:291:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:294:        source: Bullhorn.ClientContact.id
docs/verticals/recruitment/vertical-schema.yaml:298:        source: Bullhorn.ClientContact.firstName
docs/verticals/recruitment/vertical-schema.yaml:302:        source: Bullhorn.ClientContact.lastName
docs/verticals/recruitment/vertical-schema.yaml:306:        source: Bullhorn.ClientContact.email
docs/verticals/recruitment/vertical-schema.yaml:310:        source: Bullhorn.ClientContact.phone
docs/verticals/recruitment/vertical-schema.yaml:314:        source: Bullhorn.ClientContact.title
docs/verticals/recruitment/vertical-schema.yaml:320:        source: IFOS-derived (founder captures during intake; thin v0.1, expanded v1.1)
docs/verticals/recruitment/vertical-schema.yaml:326:        source: IFOS-derived
docs/verticals/recruitment/vertical-schema.yaml:330:        source: Bullhorn.ClientContact.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:344:    bullhorn_source: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:352:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:355:        source: Bullhorn.JobOrder.id
docs/verticals/recruitment/vertical-schema.yaml:359:        source: Bullhorn.JobOrder.title
docs/verticals/recruitment/vertical-schema.yaml:364:        source: Bullhorn.JobOrder.publicDescription
docs/verticals/recruitment/vertical-schema.yaml:370:        source: Bullhorn.JobOrder.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:374:        source: Bullhorn.JobOrder.salary
docs/verticals/recruitment/vertical-schema.yaml:379:        source: Bullhorn.JobOrder.salaryUnit (range parsing)
docs/verticals/recruitment/vertical-schema.yaml:383:        source: IFOS-derived (extracted from JD; GBP per day for contract roles)
docs/verticals/recruitment/vertical-schema.yaml:387:        source: IFOS-derived
docs/verticals/recruitment/vertical-schema.yaml:391:        source: Bullhorn.JobOrder.address.city
docs/verticals/recruitment/vertical-schema.yaml:396:        source: IFOS-derived (extracted from JD)
docs/verticals/recruitment/vertical-schema.yaml:401:        source: IFOS-derived (extracted from JD; v0.1 free strings; v1.1+ canonicalised skill taxonomy)
docs/verticals/recruitment/vertical-schema.yaml:405:        source: IFOS-derived
docs/verticals/recruitment/vertical-schema.yaml:410:        source: IFOS-derived (Concierge maintains based on client check-in cadence)
docs/verticals/recruitment/vertical-schema.yaml:415:        source: Bullhorn.JobOrder.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:419:        source: Bullhorn.JobOrder.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:423:        source: Bullhorn.JobOrder.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:432:    bullhorn_source: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:438:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:441:        source: Bullhorn.Placement.id
docs/verticals/recruitment/vertical-schema.yaml:445:        source: Bullhorn.Placement.dateBegin
docs/verticals/recruitment/vertical-schema.yaml:449:        source: Bullhorn.Placement.dateEnd
docs/verticals/recruitment/vertical-schema.yaml:455:        source: Bullhorn.Placement.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:460:        source: Bullhorn.Placement.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:464:        source: Bullhorn.Placement.fee
docs/verticals/recruitment/vertical-schema.yaml:469:        source: Bullhorn.Placement.feeArrangement (parsed)
docs/verticals/recruitment/vertical-schema.yaml:474:        source: Bullhorn.Placement.salary
docs/verticals/recruitment/vertical-schema.yaml:480:        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
docs/verticals/recruitment/vertical-schema.yaml:485:        source: IFOS-derived (free text for v0.1; v1.1+ structured)
docs/verticals/recruitment/vertical-schema.yaml:489:        source: Bullhorn.Placement.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:498:    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
docs/verticals/recruitment/vertical-schema.yaml:505:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:508:        source: Bullhorn.JobSubmission.id
docs/verticals/recruitment/vertical-schema.yaml:513:        source: Bullhorn.JobSubmission.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:518:        source: IFOS-derived (event log; one entry per status transition)
docs/verticals/recruitment/vertical-schema.yaml:525:        source: Bullhorn.JobSubmission.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:529:        source: Bullhorn.JobSubmission.dateLastModified
docs/verticals/recruitment/vertical-schema.yaml:538:    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
docs/verticals/recruitment/vertical-schema.yaml:545:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:548:        source: Bullhorn.Timesheet.id
docs/verticals/recruitment/vertical-schema.yaml:552:        source: Bullhorn.Timesheet.weekStartDate
docs/verticals/recruitment/vertical-schema.yaml:556:        source: Bullhorn.Timesheet.totalHours
docs/verticals/recruitment/vertical-schema.yaml:560:        source: Bullhorn.Timesheet.status (parsed)
docs/verticals/recruitment/vertical-schema.yaml:564:        source: IFOS-derived (T2 confirms; v2.0)
docs/verticals/recruitment/vertical-schema.yaml:568:        source: Bullhorn.Timesheet.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:576:# Each relationship has:
docs/verticals/recruitment/vertical-schema.yaml:583:relationships:
docs/verticals/recruitment/vertical-schema.yaml:586:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:595:    source: placement
docs/verticals/recruitment/vertical-schema.yaml:602:    source: brief
docs/verticals/recruitment/vertical-schema.yaml:609:    source: brief
docs/verticals/recruitment/vertical-schema.yaml:619:    source: contact
docs/verticals/recruitment/vertical-schema.yaml:626:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:633:    source: candidate
docs/verticals/recruitment/vertical-schema.yaml:640:    source: opportunity
docs/verticals/recruitment/vertical-schema.yaml:648:    source: opportunity
docs/verticals/recruitment/vertical-schema.yaml:655:    source: timesheet
docs/verticals/recruitment/vertical-schema.yaml:669:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.yaml:725:    client: R        # relationship context
docs/verticals/recruitment/vertical-schema.yaml:849:    rationale: M:N relationship adds query complexity; N:1 is the simplifying v0.1 assumption.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/vertical-schema.yaml:886:      Structural cut. 8 entities + 10 relationships + agent-access matrix + Bullhorn mapping. Minimal field sets (10-20 per entity). 12 open questions catalogued (Q1, Q4 resolved at Day 6; Q2, Q3, Q5-Q12 deferred with named triggers).
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:30:  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:43:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:49:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:50:DROP FUNCTION IF EXISTS validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:47:#   The 6 voice_classifier_score / voice_drift_at_close fields added to existing
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:59:    bullhorn_source: none (IFOS-derived from /vault/<tenant>/_voice/ ingest)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:68:        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:73:        source: IFOS-derived (operator names at re-index time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:79:        source: IFOS-derived (counted by ingest pipeline)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:84:        source: IFOS-derived (vault _voice/ subdirectory enumeration)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:90:        source: IFOS-derived (computed by chunking pass)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:95:        source: IFOS-derived (config; v0.2 default "paragraph")
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:101:        source: IFOS-derived (config; default text-embedding-3-small)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:107:        source: IFOS-derived (timestamped at ingest completion)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:112:        source: IFOS-derived (atomic flip on version rollover)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:117:        source: IFOS-derived (observability counter; pipeline timing)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:126:    bullhorn_source: none (IFOS-derived; authored in /vault/<tenant>/_voice/tone-rules.yaml then synced to Postgres)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:135:        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:139:        source: IFOS-derived (operator names at rule authoring time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:144:        source: IFOS-derived (operator natural-language description)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:149:        source: IFOS-derived (operator picks at rule authoring)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:161:        source: IFOS-derived (default true; operator toggles via Brain UI)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:166:        source: IFOS-derived (enum from rule provenance — onboarding-flow / Brain-UI / CSM-intervention)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:172:        source: IFOS-derived (timestamped at insert)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:176:        source: IFOS-derived (operator-curated at rule authoring)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:182:        source: IFOS-derived (operator-curated at rule authoring)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:192:    bullhorn_source: none (IFOS-derived from operator's approve/edit UX)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:201:        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:205:        source: IFOS-derived (from CTX_AGENT_NAME at edit-capture time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:211:        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:216:        source: IFOS-derived (entity context at edit time; nullable for system-level edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:222:        source: IFOS-derived (entity ID at edit time; Bullhorn ID or IFOS slug)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:223:        notes: bullhorn_id or IFOS slug. Used in the entity_links join below.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:227:        source: IFOS-derived (agent's draft as produced; capped at 8192 chars)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:233:        source: IFOS-derived (consultant's final version at approve time; null when approved verbatim)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:239:        source: IFOS-derived (Levenshtein computed at insert; null when edited_text null)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:245:        source: IFOS-derived (operator UX action at approve/reject time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:251:        source: IFOS-derived (timestamped at operator action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:255:        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:289:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:292:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:297:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:300:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:301:      notes: Same as candidate.voice_classifier_score, scoped to contractor sub-case.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:304:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:307:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:312:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:315:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:320:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:323:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:331:      source: IFOS-derived
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:336:# §4 — Additional relationships (2)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:339:additional_relationships:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:342:    source: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:177:CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:185:  IF d ? 'voice_classifier_score' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:186:    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:187:      RAISE EXCEPTION 'voice_classifier_score must be number or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:189:    IF d->'voice_classifier_score' != 'null'::jsonb THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:190:      IF (d->>'voice_classifier_score')::numeric < 0.0
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:191:         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:192:        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:375:DROP TRIGGER IF EXISTS validate_entities_data_v0_3 ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:377:CREATE TRIGGER validate_entities_data_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:380:  EXECUTE FUNCTION validate_entities_data_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:    'janitor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:403:    'cash_conductor_last_run',
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:466:  -- janitor_last_run: ISO-8601 timestamp string or null
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:467:  IF c ? 'janitor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:468:    IF jsonb_typeof(c->'janitor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:469:      RAISE EXCEPTION 'janitor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:473:  -- blocked_recipients: array of strings (pre-v0.3 origin; canonicalised here)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:474:  IF c ? 'blocked_recipients' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:475:    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:476:      RAISE EXCEPTION 'blocked_recipients must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:502:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:504:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:508:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:510:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:513:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:13:# added closing Janitor R11 Finding 4 + blocked_recipients added closing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# Sourcing Scout R8 Finding 1. blocked_recipients is pre-v0.3 origin
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:34:# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:53:# validate_entities_data_v0_3() trigger function (migration §4).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:67:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:81:          per candidate enforced by validate_entities_data_v0_3.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:82:        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:96:        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:112:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:124:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:140:        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:152:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:165:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:181:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:201:        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:215:        source: IFOS-derived (Scribe LLM extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:230:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:243:        source: IFOS-derived (Scribe LLM classification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:255:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:313:agent_access_matrix:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:357:  # Validation: the validate_entities_data_v0_3 trigger validates FIELD
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:607:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:615:      id: {type: integer, required: true, source: IFOS-internal, notes: BIGSERIAL primary key in SQL}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:616:      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:617:      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:618:      posted_at: {type: timestamp, required: true, source: Open Banking provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:619:      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:620:      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:621:      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:622:      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:623:      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:624:      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:625:      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:626:      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:627:      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:628:      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:629:      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:645:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:651:      id: {type: integer, required: true, source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:652:      tenant_slug: {type: string, required: true, source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:653:      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:654:      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:655:      invoice_number: {type: string, required: false, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:656:      issued_at: {type: timestamp, required: true, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:657:      due_at: {type: timestamp, required: true, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:658:      amount_total: {type: number, required: true, source: Accounting provider, notes: NUMERIC(15,2) GBP}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:659:      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:660:      currency: {type: string, required: true, default: GBP, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:661:      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:662:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:663:      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:664:      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:665:      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:666:      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:667:      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:680:      W4 polish, production use of cash_conductor_invoices is GATED by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:681:      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:682:      per §3 cash_conductor_transactions.retention). Migration-test tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:726:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:733:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:751:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:769:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:810:  blocked_recipients:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:829:  janitor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:889:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:892:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:895:      CREATE OR REPLACE FUNCTION validate_entities_data_v0_3() — replaces
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:970:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:985:      cash_conductor_transactions table is GATED by an explicit per-tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1008:  new + 2 Janitor + 1 blocked_recipients pre-v0.3 canonicalised). The

codex
The referenced files are present, except `bullhorn-integration-path.md` is not directly under `docs/verticals/recruitment/`; I’m locating the actual path before treating citation mismatches as load-bearing.
exec
/bin/zsh -lc "sed -n '55,180p' docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
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

exec
/bin/zsh -lc "sed -n '177,390p' docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '390,490p' docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    'concierge_send_window'
    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
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
  -- diagnostic_per_claim_sample_rate DEFERRED to W4-polish ADR; not validated
  -- in v0.3 (also not in allowlist above, so it would fail-fast anyway)

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

  -- v0.3.1 (Day-20 bilateral pass) — declarations canonicalised in supplement §4
  -- janitor_dedup_threshold: number in [0.75, 0.95] per supplement default 0.85
  IF c ? 'janitor_dedup_threshold' THEN
    IF jsonb_typeof(c->'janitor_dedup_threshold') != 'number' THEN
      RAISE EXCEPTION 'janitor_dedup_threshold must be number';
    END IF;
    IF (c->>'janitor_dedup_threshold')::numeric < 0.75
       OR (c->>'janitor_dedup_threshold')::numeric > 0.95 THEN
      RAISE EXCEPTION 'janitor_dedup_threshold out of [0.75, 0.95] range: %', c->>'janitor_dedup_threshold';
    END IF;
  END IF;

  -- janitor_last_run: ISO-8601 timestamp string or null
  IF c ? 'janitor_last_run' THEN
    IF jsonb_typeof(c->'janitor_last_run') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'janitor_last_run must be ISO-8601 timestamp string or null';
    END IF;
  END IF;

  -- blocked_recipients: array of strings (pre-v0.3 origin; canonicalised here)
  IF c ? 'blocked_recipients' THEN
    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
      RAISE EXCEPTION 'blocked_recipients must be array';
    END IF;
    -- Element types validated by tenant-admin wizard; trigger checks shape only
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;

CREATE TRIGGER validate_tenant_adapters_config_v0_3
  BEFORE INSERT OR UPDATE ON tenant_adapters
  FOR EACH ROW
  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();

 succeeded in 0ms:
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
          RAISE EXCEPTION 'next_action_target_date must parse as ISO-8601 date (YYYY-MM-DD); got: %', d->>'next_action_target_date';
        END;
      END IF;
    END IF;
  END IF;

  -- v0.3 brief fields
  IF et = 'brief' THEN
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
         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$' THEN
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
-- v0.3 codifies 3 new config keys agents read. The validation trigger ensures
-- only the documented keys are stored (hard-fail on unknown keys per Rule 2
-- Schema before code).

CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()

exec
/bin/zsh -lc "rg --files | rg 'bullhorn-integration-path|sequencing-target|operational-hygiene|autosend-safety|ULTRAPLAN|ultraplan|master'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
logs/codex-ratification/round-3-remediation/docs_decisions_bullhorn-integration-path-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_sequencing-target-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_bullhorn-integration-path-md.output.md
logs/codex-ratification/round-2-autonomous/docs_runbooks_operational-hygiene-protocol-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
docs/decisions/autosend-safety-policy.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
docs/runbooks/operational-hygiene-protocol.md
docs/specs/ULTRAPLAN.md

exec
/bin/zsh -lc "rg -n \"§1\\.2|§3|§4\\.1|A3|A4|A6|Candidate|ClientCorporation|JobOrder|Placement|Timesheet|Opportunity|No direct Bullhorn\" docs/decisions/bullhorn-integration-path.md" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "Diagnostic|Janitor|Scribe|Cash Conductor|Sourcing Scout|Concierge|candidate:|contractor:|client:|contact:|brief:|opportunity:|placement:|timesheet:" docs/verticals/recruitment/vertical-schema.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
48:  candidate:
50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
53:      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
54:      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
56:      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
119:        source: IFOS-derived (Scribe extraction; GBP annual)
132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
136:        source: IFOS-derived (Scribe extracts)
141:        source: IFOS-derived (set by Sourcing Scout at first-touch)
145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
153:  contractor:
158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
161:      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
191:        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
205:        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
221:  client:
226:      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
228:      - Concierge (R — relationship context per bullhorn §4.1 A6)
255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
261:        source: IFOS-derived (Janitor maintains)
279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
283:  contact:
288:      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
321:        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
331:      do_not_contact:
334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
341:  brief:
347:      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
350:      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
410:        source: IFOS-derived (Concierge maintains based on client check-in cadence)
425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
429:  placement:
434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
436:      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
471:      candidate_salary_at_placement:
480:        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
481:        notes: Drives Concierge nurture-event firing.
492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
495:  opportunity:
535:  timesheet:
557:      approved_by_client:
561:      approved_by_contractor:
592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
594:  placement_for_brief:
599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
601:  brief_from_client:
615:    v1_0_exercise: Concierge reads for addressee-resolution per bullhorn §4.1 A6 Voice gate; addressee = primary decision-maker contact.
618:  contact_works_for_client:
623:    v1_0_exercise: Concierge addressee context.
625:  candidate_engaged_with_contact:
630:    v1_0_exercise: Concierge reads for outbound-message addressee correctness; thin in v1.0.
632:  candidate_referred_by_contact:
637:    v1_0_exercise: Sourcing Scout captures at first-touch when relevant; not heavily exercised in v1.0.
639:  opportunity_for_brief:
647:  opportunity_about_candidate:
654:  timesheet_for_placement:
671:  Diagnostic:
672:    candidate: none
673:    contractor: none
674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
675:    contact: none
676:    brief: none
677:    placement: none
678:    opportunity: none
679:    timesheet: none
680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
682:  Janitor:
683:    candidate: R+W   # full sweep + normalisation + dedup proposals
684:    contractor: R+W  # status normalisation
685:    client: R+W      # orphan-link sweep + normalisation
686:    contact: R       # read-only (Concierge owns writes)
687:    brief: R         # status drift sweep
688:    placement: R     # orphan / stale-tag sweep
689:    opportunity: none
690:    timesheet: none
692:  Scribe:
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
722:  Concierge:
723:    candidate: R+W   # lifecycle state on every event
724:    contractor: R+W  # lifecycle state, contractor-specific cadence
725:    client: R        # relationship context
726:    contact: R       # decision-maker resolution for orange-tier sends
727:    brief: R         # linked-brief context
728:    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
729:    opportunity: none
730:    timesheet: none
736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
741:  candidate:
745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
747:  contractor:
751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
754:  client:
757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
760:  contact:
763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
765:  brief:
768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
771:  placement:
774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
775:    notes: lifecycle_stage is IFOS-derived (Concierge maintains); Bullhorn does not natively store IFOS's nurture-cadence stages.
777:  opportunity:
783:  timesheet:
805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
844:  Q9_multi_client_contact:
856:    rationale: v1.0 Concierge addressee-resolution uses primary-decision-maker; panel modelling adds value when v1.1 Triage handles inbound brief queries from multiple stakeholders.
862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.
870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
890:    expected_date: post Week 3-4 (after Janitor build verifies against real Bullhorn data)
892:      Codex-ratified version. Field sets expanded per Janitor's real-Bullhorn-data findings (Q3 trigger). Possibly Note entity promoted to entity_type if Janitor surfaces query patterns (Q2 trigger). 2-3 revisions expected from v0.1.

 succeeded in 0ms:
9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
21:**Sub-decision B — OAuth flow.** Master brief §6 Day 2 line 466 pre-states a recommendation: "browser dance for production, service-account for dev." This is the authorization-code grant (per-tenant browser dance, refresh-token cycle) for production tenants, plus client-credentials grant (service account) for IFOS-internal sandbox/dev work. Sub-decision B verifies that recommendation against Bullhorn's actual OAuth implementation and pins the per-tenant token storage path (per `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution: `/vault/<tenant>/_secrets.env`, mode `0600`).
23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
54:- Per-tenant credential storage location (resolved by `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C: `/vault/<tenant>/_secrets.env`).
60:- Whether **marketplace-tier API access differs from direct-API access** in rate limits, available scopes (e.g. write to JobOrder, write to Note, webhook subscription), or sandbox availability. Bullhorn's public docs are sparse on the deltas; partner reps know the actuals.
72:| B | "Refresh-token TTL and rotation behaviour specifics" | Same | Same | Affects renderer §3.3.2 `.env` materialisation: how often does per-tenant `_secrets.env` need rotation? Documented Bullhorn behaviour varies by account; partner-rep gives the canonical numbers |
149:- **Per-tenant model.** Each tenant has its own `corpToken` and its own per-tenant `restUrl` returned by /login. Operations are scoped by the corpToken; IFOS must hold per-tenant token state. This maps cleanly to the per-tenant credential model already pinned in `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution (`/vault/<tenant>/_secrets.env`, mode `0600`).
169:| Cost at 3-tenant pilot scale (2026 H2, Boutique tier per Product Spec §3.1) | **CG.** Public docs do not name partner fees. Inference based on comparable enterprise SaaS marketplace programmes: annual partner fee typically $5K-$25K + possibly per-listing or per-referral revenue-share. | **CG.** Public docs do not name developer-program fees. Inference: likely zero or nominal for the developer-tier API access. Per-tenant cost zero — the tenant pays Bullhorn, IFOS pays nothing per call. |
171:| Scope / rate-limit deltas | **CG.** Marketplace tier may grant elevated rate limits, write access to additional entities (e.g. JobOrder write), webhook subscription endpoints not available to direct-tier. Public docs do not state. | Public REST API documentation lists all REST endpoints uniformly — no tier-gated endpoints stated in public docs. Inference: all entity reads/writes are available to authenticated direct-tier callers, subject to per-corpToken scope at the tenant-account-admin level. Rate limit ceiling **CG**. |
173:| **Switching cost later** (start direct, move to marketplace at v1.1+) | n/a (this is the destination) | **Low if the connector code treats auth as a swap-point per §1.4 fallback architecture.** The connector's REST endpoint calls (Sub-decision C surface) are identical between paths. The auth module — `packages/mcp-connectors/bullhorn/src/auth.ts` and the `_secrets.env` materialisation in the renderer — is the only differing surface. Bounded to ~200-400 lines of code per the design in `agent-bundle-renderer-design.md` §3.3.4. |
184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
224:This rotation pattern matters operationally: IFOS must persist the **most recent** refresh_token after every token refresh, atomically overwriting the previous one in `/vault/<tenant>/_secrets.env`. A failure between obtaining the new refresh_token and persisting it permanently invalidates the previous one — the tenant admin must re-run the browser dance. **Spec gap §3.1-A:** the renderer + auth module need a refresh-token-persistence atomicity protocol. Recommended resolution: write to `_secrets.env.tmp` then rename, matching the atomic write pattern in `agent-bundle-renderer-design.md` §3.3.4.
226:**Scope of permissions requested at first auth:** Bullhorn's OAuth docs surveyed do not specify per-scope strings (e.g. `read:candidate`, `write:note`). REST API access appears to be at-tenant-admin-discretion — the admin authorises the connected app for "API access" generally, and the corpToken-scoped session inherits whatever entity permissions the admin's account holds. **Spec gap §3.1-B:** confirm with Bullhorn developer support that there is no per-entity-type scope granularity at the OAuth layer — i.e. IFOS cannot request "read-only" auth and get a token that can't write. If this is correct, then Gate A in `validate.sh` (per master brief §1 Rule 4) becomes the only enforcement layer for "this agent should never write" — the OAuth token itself does not protect.
241:- **IFOS holds a Bullhorn dev tenant** (separate from any production pilot) where IFOS performs authorization-code grant once against IFOS-internal admin credentials; the resulting access/refresh tokens serve as the "dev account" auth state. Tokens still rotate per §3.1; IFOS internal-dev tooling refreshes them.
244:**Spec gap §3.2-A:** confirm with Bullhorn developer support whether (a) client_credentials is genuinely unsupported, or (b) it exists for specific partner-tier use cases not documented publicly. If (b), this changes the dev-loop ergonomics. Mark as **CG**.
248:Pragmatic v1.0 hybrid given §3.1 and §3.2 findings:
250:- **Production tenants:** authorization-code grant per §3.1. Per-tenant admin runs the browser dance during onboarding wizard Day 2 (Product Spec §5.2 OAuth + vault provisioning step). Refresh tokens persisted at `/vault/<tenant>/_secrets.env` mode 0600 with atomic-rename rotation per Spec gap §3.1-A resolution.
251:- **IFOS internal dev / sandbox:** authorization-code grant against IFOS-owned Bullhorn dev tenant (or against Bullhorn sandbox if §3.2-A resolves favourably). Same flow as production; the only difference is the source tenant. Tokens stored at `packages/mcp-connectors/bullhorn/.dev-tokens/` (gitignored) for IFOS dev work.
256:**Recommendation:** authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement "browser dance for production"). For IFOS dev: authorization-code grant against an IFOS-owned Bullhorn dev tenant; service-account / client_credentials grant deferred (because Bullhorn doesn't document support for it per §3.2).
262:3. **The renderer's `_secrets.env` materialisation per Spec gap §2.1-C handles the credential storage cleanly.** No new persistence layer needed; the path was already specified in `agent-bundle-renderer-design.md` §3.3.2.
267:- Confirm Bullhorn sandbox availability and auth model (Spec gap §3.2-A).
268:- Confirm there is no per-entity-type OAuth scope granularity at the OAuth layer (Spec gap §3.1-B) — required so IFOS's Gate A enforcement model (validate.sh) is the correct safeguard.
271:**Status: Proposed.** Status flips to Accepted on commercial verification answers to the four questions above. Most likely outcome: confirmation of the §3.4 recommendation as stated, with one or two clarifications absorbed into the renderer's auth-module implementation.
285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
306:| Janitor Candidate sweep | Polling (full-table scan per sweep) | Nightly 02:00 | Initial sweep is bounded by per-tenant Candidate count; subsequent sweeps use `dateLastModified` filter to limit to changes-since-last-sweep |
307:| Janitor Note / ClientCorporation / JobOrder sweep | Polling | Nightly 02:00 | Same `dateLastModified` filter pattern |
311:| Concierge time-based nurture cadence | Cron (week-1, month-1, month-3, month-6, month-12, month-24) | Per Placement-creation anchor date | No Bullhorn webhook needed — IFOS-side cron fires; IFOS reads Bullhorn for current state then writes the comm Note back |
317:Restated from `agent-bundle-renderer-design.md` §2.1 + §3.3.2 spec gap §2.1-C resolution + §3.1 of this document:
320:- **Refresh-token persistence atomicity:** write to `_secrets.env.tmp`, rename atomically per `agent-bundle-renderer-design.md` §3.3.4 — resolves Spec gap §3.1-A of this document.
321:- **Access token:** in-memory only; never persisted to disk. 10-minute TTL per §3.1 does not justify disk I/O.
322:- **`BhRestToken`:** in-memory cache; refresh on 401 per §3.1; never persisted.
334:| Janitor (nightly sweep) | 200-400 during active sweep window (concentrated 1-2 hour burst) | Burst-tolerant; bounded by tenant Candidate-count and `dateLastModified` filter efficiency |
346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
354:  - Operator action: re-run authorisation if refresh-token cycle broke (per §3.1 atomic-persistence failure mode); agent picks up new tokens on next session refresh per Primitive 2.
355:- **Refresh-token rotation atomicity:** every successful refresh atomically writes the new refresh_token to `_secrets.env.tmp` then renames (Spec gap §3.1-A resolution per `agent-bundle-renderer-design.md` §3.3.4). The old refresh_token is unusable after the new one is generated — atomicity is mandatory.
381:Recommendation: authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement); authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (client_credentials grant **foreclosed** by Bullhorn OAuth docs per §3.2 — Bullhorn does not support client_credentials grant for tenant-scoped data). Refresh-loop architecture per §4.5.
383:Status flips to Accepted when commercial verification answers the four questions per §3.4:
387:3. Per-entity OAuth scope granularity confirmed (Spec gap §3.1-B) — required to know whether `validate.sh` is the only enforcement layer.
404:Per §2.4 + §5: connector scaffolds at `packages/mcp-connectors/bullhorn/` against direct-API auth-code flow. Auth module isolated per §1.4 fallback architecture (~200-400 lines bounded per `agent-bundle-renderer-design.md` §3.3.4). Endpoint surface from §4.1 drives the connector's exposed `tools.yaml` scopes. Refresh-loop per §4.5 ships with the connector.
410:- **`_secrets.env` vault structure provisioned** per renderer §3.3.2 — already on Week-1 prereq list from ADR-003.
415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
419:Concierge's write capability to Bullhorn (Note auto-send, status updates per §4.1) interacts with Day 5's auto-send safety policy artefact. Day 5 should reference this document's §4.1 Concierge row for the specific entities Concierge will be writing — Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI.
423:Bullhorn entity field mapping (Candidate, JobOrder, Placement, Note, ClientCorporation) → IFOS wiki schema per `second-brain-design.md` §2.2 entity types. Out of scope for this Day-2 decision; flagged for Week 11-13 work. Concrete handoff: §4.1's per-agent read-entity list is the v1.0 minimum set the wiki ingest paths must handle.
442:§3.2 finding (Bullhorn does NOT support client_credentials grant for tenant-scoped data per public OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`) forecloses the master brief §6 Day 2 line 466 pre-statement. New sixth edit for the atomic correction commit alongside ADR-001 + ADR-002 + ADR-003 Edit C.
471:- **Per-entity OAuth scope model** (Spec gap §3.1-B) — deferred to Bullhorn dev support verification; result folds into connector's auth-module implementation, not a new ADR.
483:| §3.1-A | §4.3 + §4.5 | Refresh-token persistence atomicity: write `_secrets.env.tmp`, rename atomically per `agent-bundle-renderer-design.md` §3.3.4 |
485:| Per-tenant credential isolation | §4.3 | Restated from `agent-bundle-renderer-design.md` §3.3.2 — `/vault/<tenant>/_secrets.env` mode 0600 + per-tenant OS user kernel isolation + Postgres RLS |
509:| §3.1-B: assume no per-entity OAuth scope granularity → `validate.sh` Gate A is the only enforcement layer | Bullhorn dev support confirms different — adjust connector auth-module to request scoped tokens |
510:| §3.2-A: assume `client_credentials` genuinely unsupported (not partner-tier-only) | Bullhorn dev support reveals partner-tier-only support — dev-loop ergonomics improve; production path unchanged |
513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |

exec
/bin/zsh -lc 'rg -n "voice_corpus|tone_rule|recent_edit|voice_corpus_chunks|is_active|chunking_strategy|severity|applies_to_agents|resolution|GRANT|SELECT, INSERT" docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:11:--   - 1 auxiliary table: voice_corpus_chunks (holds the pgvector index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:43:-- §2 — Create voice_corpus table (per-tenant voice pack)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:46:CREATE TABLE IF NOT EXISTS voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:53:  chunking_strategy     TEXT        NOT NULL CHECK (chunking_strategy IN ('paragraph', 'sentence-window-5', 'semantic-segment-v1')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:56:  is_active             BOOLEAN     NOT NULL DEFAULT FALSE,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:59:  CONSTRAINT voice_corpus_tenant_version_unique UNIQUE (tenant_slug, version)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:62:-- Partial unique index: at most one active voice_corpus per tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:63:CREATE UNIQUE INDEX IF NOT EXISTS voice_corpus_one_active_per_tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:64:  ON voice_corpus (tenant_slug)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:65:  WHERE is_active = TRUE;
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:118:  severity            TEXT        NOT NULL CHECK (severity IN ('info', 'warn', 'block')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:119:  applies_to_agents   TEXT[]      NOT NULL DEFAULT '{}',
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:126:  CONSTRAINT tone_rule_tenant_rule_id_unique UNIQUE (tenant_slug, rule_id)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:129:CREATE INDEX IF NOT EXISTS tone_rule_tenant_enabled_idx ON tone_rule (tenant_slug, enabled);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:131:ALTER TABLE tone_rule ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:132:ALTER TABLE tone_rule FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:133:DROP POLICY IF EXISTS tone_rule_tenant_isolation ON tone_rule;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:134:CREATE POLICY tone_rule_tenant_isolation ON tone_rule
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:138:-- §5 — Create recent_edit table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:141:CREATE TABLE IF NOT EXISTS recent_edit (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:151:  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:291:  chunk_count, chunking_strategy, embedding_model,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:292:  last_indexed_at, is_active, ingest_completion_ms
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:313:-- SELECT count(*) FROM voice_corpus WHERE tenant_slug = 'migration-test';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:315:-- SELECT indexname FROM pg_indexes WHERE tablename = 'voice_corpus_chunks';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:316:--   → expect: voice_corpus_chunks_pkey, voice_corpus_chunks_tenant_idx,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:317:--             voice_corpus_chunks_corpus_idx, voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:75:          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:92:      chunking_strategy:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:109:      is_active:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:146:      severity:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:152:      applies_to_agents:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:242:      resolution:
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:411:      Pending D2/D3 resolution. v0.2 ships with text fields stored verbatim
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.

codex
The main tension I’m seeing is not formatting; it is semantic. The supplement grants new write paths to existing Bullhorn-backed entities, and I’m checking whether those writes are schema-valid under the base entity requirements.
exec
/bin/zsh -lc "sed -n '153,220p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '48,155p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
  contractor:
    description: |
      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
    v1_0_agent_access:
      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
    canonical_fields:
      # Inherits candidate fields conceptually; below are the additional contractor-specific fields.
      # Full implementation: adapter layer materialises both candidate-overlap fields AND contractor-specific fields in entities.data.
      # Schema notes: see candidate canonical_fields for the shared base set.
      bullhorn_id:
        type: integer
        required: true
        source: Bullhorn.Candidate.id
        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
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
      mobile:
        type: string
        required: false
        source: Bullhorn.Candidate.mobile
      ir35_status:
        type: string
        required: true
        enum: [inside_ir35, outside_ir35, undetermined, exempt_small_business]
        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
      day_rate_min:
        type: number
        required: false
        source: IFOS-derived (Scribe extracts from call; GBP per day)
      day_rate_max:
        type: number
        required: false
        source: IFOS-derived (GBP per day)
      umbrella_company:
        type: string
        required: false
        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
      availability_weeks:
        type: integer
        required: false
        source: IFOS-derived (when can contractor start, in weeks from now)
      current_engagement_end_date:
        type: date
        required: false
        source: IFOS-derived
        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
    notes:
      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.

  # --------------------------------------------------------------------------

 succeeded in 0ms:
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
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '70,100p;330,360p;428,475p;535,575p;1000,1025p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '713,720p' docs/verticals/recruitment/vertical-schema.yaml && sed -n '285,288p' docs/decisions/bullhorn-integration-path.md" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    70	          - Sourcing Scout: R
    71	
    72	      key_skills:
    73	        type: array
    74	        items:
    75	          type: string
    76	        max_items: 20
    77	        required: false
    78	        notes: |
    79	          Aggregated skill tags from CV + transcripts. Free-text strings;
    80	          W4 polish may add controlled-vocabulary clustering. Max 20 items
    81	          per candidate enforced by validate_entities_data_v0_3.
    82	        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
    83	        v1_0_agent_access:
    84	          - Scribe: W
    85	          - Sourcing Scout: R+W
    86	
    87	      linkedin_url:
    88	        type: string
    89	        pattern: '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
    90	        required: false
    91	        notes: |
    92	          LinkedIn profile URL. Pattern enforced by trigger. Set by Sourcing
    93	          Scout from match; Janitor uses for dedup (stronger match signal
    94	          than name+email); Concierge reads for outreach context (NOT for
    95	          outbound — outreach via candidate.email or candidate.phone only).
    96	        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
    97	        v1_0_agent_access:
    98	          - Sourcing Scout: R+W
    99	          - Janitor: R   # W only via dedup-merge action
   100	          - Concierge: R
   330	  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
   331	  # AUXILIARY, NOT entities. Their access lives in
   332	  # `auxiliary_table_access_matrix` below + §2a access amendments — NOT in
   333	  # this entity matrix. The v0.2 YAML key `entities:` was documentation
   334	  # convention; v0.3 reclassifies per the v0.2 LAYERING DISCLOSURE intent.
   335	  #
   336	  # ENTITY-LEVEL vs FIELD-LEVEL ACCESS:
   337	  # The matrix below is ENTITY-LEVEL — declares the maximum disposition an
   338	  # agent may have on any field of that entity.
   339	  #
   340	  # FIELD_ACCESS_NARROWING_RULE (v0.3 explicit scope rule, ratified as part
   341	  # of this supplement):
   342	  #   Per-field access (in §1 entity_field_additions[*].v1_0_agent_access)
   343	  #   NARROWS the entity-level disposition. The entity-level token is the
   344	  #   CEILING; field-level may be narrower (or absent — implying the agent
   345	  #   has the entity-level default) but NEVER BROADER than the matrix entry.
   346	  #   Example: Scribe.candidate: R+W at entity level; per-field
   347	  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
   348	  #   without reading it). Another example: Diagnostic.candidate: R at entity
   349	  #   level; candidate.linkedin_url has no Diagnostic field entry; Diagnostic
   350	  #   gets R on linkedin_url (entity-level default), not the broader Sourcing
   351	  #   Scout R+W. Implementation: cycle.sh + hh_decision_action records which
   352	  #   agent + which fields were touched in decision_log payload; reviewers
   353	  #   audit via that trail. v0.3 does NOT enforce this rule at the database
   354	  #   layer (column-level RLS would be required; v1.1+ work per the
   355	  #   "documentary not enforced" note above).
   356	  #
   357	  # Validation: the validate_entities_data_v0_3 trigger validates FIELD
   358	  # SHAPE only (type checks, enum membership, length caps, array element
   359	  # types). It does NOT enforce which agent is writing — agent-level
   360	  # write permission is DOCUMENTARY in v0.3, enforced at the application
   428	    brief: R               # reads to filter candidates
   429	    opportunity: R         # OVERRIDE v0.1 none → v0.3 R (reads opportunity context for ICP)
   430	    placement: none
   431	    timesheet: none
   432	
   433	  concierge:
   434	    # Concierge's Bullhorn endpoint access (Candidate / ClientCorporation /
   435	    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
   436	    # row A6. opportunity + timesheet access below is IFOS-cached Postgres
   437	    # only (not Bullhorn endpoint calls).
   438	    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
   439	    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
   440	    client: R              # IFOS-cached read (Bullhorn endpoint A6 — ClientCorporation)
   441	    contact: R             # IFOS-cached read; outbound recipient resolution (Bullhorn endpoint A6 — Note context)
   442	    brief: R               # IFOS-cached read (Bullhorn endpoint A6 — JobOrder)
   443	    opportunity: R         # IFOS-cached read; outbound lifecycle-event context (Bullhorn Opportunity endpoint NOT used at v1.0)
   444	    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14 (Bullhorn endpoint A6)
   445	    timesheet: R           # IFOS-cached read; placement-progress for 7d/30d/90d nurture (Bullhorn Timesheet endpoint NOT used at v1.0)
   446	
   447	# ============================================================================
   448	# §2a — v0.2 entity v1_0_agent_access amendments
   449	# ============================================================================
   450	#
   451	# Per review-schema-change §5: matrix changes must be reflected in entity-level
   452	# v1_0_agent_access lists. v0.3 amends these v0.2 entities:
   453	
   454	v0_1_entity_access_amendments:
   455	  # Per review-schema-change §5: matrix changes to v0.1 entity-level access
   456	  # must be reflected in explicit amendments. Each entry below documents the
   457	  # v0.1 baseline → v0.3 expanded access list. The base vertical-schema.yaml
   458	  # is NOT edited; this supplement is the authoritative source for v0.3
   459	  # entity access state.
   460	
   461	  client:
   462	    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
   463	    v0_3_v1_0_agent_access:
   464	      - Diagnostic (R)     # v0.3 NEW — reads Companies House data for sales-tool context
   465	      - Janitor (R+W)      # v0.1 unchanged
   466	      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
   467	      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
   468	      - Sourcing Scout (R) # v0.1 unchanged
   469	      - Concierge (R)      # v0.1 unchanged
   470	    rationale: |
   471	      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
   472	      client billing/context for their respective workflows). No new W access.
   473	
   474	  contact:
   475	    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
   535	      Scribe + Concierge (each reads timesheet for their respective
   536	      placement-related workflows).
   537	
   538	  candidate:
   539	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   540	    v0_3_v1_0_agent_access:
   541	      - Diagnostic (R)     # v0.3 NEW — reads for outreach context (§11 decision-maker map)
   542	      - Janitor (R+W)      # v0.1 unchanged
   543	      - Scribe (R+W)       # v0.1 unchanged
   544	      - Sourcing Scout (R+W) # v0.3 UPGRADED — writes proposed-candidate rows
   545	      - Concierge (R+W)    # v0.3 UPGRADED — writes lifecycle-state-derived fields
   546	    rationale: |
   547	      v0.3 upgrades Sourcing Scout (writes proposed-candidate rows from
   548	      multi-source aggregation) + Concierge (writes lifecycle-state and
   549	      activity-log links per §4 Steps 13-14). Diagnostic gains R for context.
   550	
   551	  contractor:
   552	    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
   553	    v0_3_v1_0_agent_access:
   554	      - Janitor (R+W)      # v0.1 unchanged
   555	      - Scribe (R+W)       # v0.1 unchanged
   556	      - Sourcing Scout (R+W) # v0.3 UPGRADED — same pattern as candidate
   557	      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
   558	    rationale: |
   559	      Parallel upgrades to candidate; contractor entities follow the same
   560	      v0.3 write patterns where applicable.
   561	
   562	v0_2_entity_access_amendments:
   563	
   564	  voice_corpus:
   565	    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
   566	    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
   567	    rationale: |
   568	      All v1.0 agents that produce voice-classified output (Diagnostic for
   569	      §12 conversation opener; Janitor for tacit-note narratives; Cash
   570	      Conductor for chase drafts; Sourcing Scout for per-candidate
   571	      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
   572	      granted Scribe + Concierge; v0.3 extends to all 6.
   573	
   574	  tone_rule:
   575	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
  1000	# §9 — Why v0.3 is the right unblock
  1001	# ============================================================================
  1002	
  1003	rationale: |
  1004	  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
  1005	  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
  1006	  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
  1007	  adds 14 entity JSONB keys + 2 auxiliary tables + 6 config keys (3 v0.3-
  1008	  new + 2 Janitor + 1 blocked_recipients pre-v0.3 canonicalised). The
  1009	  per_claim_confidence_distribution payload key originally planned for
  1010	  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
  1011	  §5 of this supplement); v0.3 is silent on payload schema extensions.
  1012	
  1013	  After v0.3 ratifies + migration applies:
  1014	    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
  1015	      the v0.3-added fields (employment_type, key_skills, preferred_channel,
  1016	      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
  1017	      placement_status, week_1_status_vault_path, satisfaction_signal,
  1018	      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
  1019	      are now schema-backed. (Note: week_1_status_note narrative now lives
  1020	      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
  1021	      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
  1022	      seniority — not yet in schema; brief.start_date should be
  1023	      start_date_target; opportunity.sector — not yet in schema). These
  1024	      residual gaps are tracked in W4-polish-schema-extension backlog;
  1025	      they do not block v0.3 ratification but do require a Scribe agent.md

 succeeded in 0ms:
    candidate: R     # passive matching
    contractor: R    # contractor pool
    client: R        # target-firm context
    contact: none    # thin v1.0
    brief: R         # active brief context for matching
    placement: none
    opportunity: none
    timesheet: none
| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |

exec
/bin/zsh -lc "sed -n '429,492p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc 'rg -n "client_contact_id|candidate_id|client_id|contact_id|placement.client" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:662:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:125:  client_contact_id        TEXT,

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '600,670p;724,740p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   600	
   601	# ============================================================================
   602	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   603	# ============================================================================
   604	
   605	auxiliary_tables:
   606	
   607	  cash_conductor_transactions:
   608	    rationale: |
   609	      Open Banking transactions are high-volume + time-series + don't model
   610	      as entity.data JSONB. v0.3 introduces a first-class table with
   611	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   612	      §4 Step 3 + ADR-002 vault/Postgres split.
   613	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   614	    columns:
   615	      id: {type: integer, required: true, source: IFOS-internal, notes: BIGSERIAL primary key in SQL}
   616	      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
   617	      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
   618	      posted_at: {type: timestamp, required: true, source: Open Banking provider}
   619	      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
   620	      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
   621	      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   622	      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   623	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
   624	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
   625	      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   626	      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
   627	      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}
   628	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   629	      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
   630	    indexes:
   631	      - "(tenant_slug, posted_at DESC)"
   632	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   633	    retention: |
   634	      INTENT (W4-polish enforcement required): 7-year retention with
   635	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   636	      description, raw_payload). Aligned with Q4 v0_3_default. The
   637	      v0.2-to-v0.3 migration creates the table + indexes only; the
   638	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   639	      job or external scheduled job; not yet authored).
   640	    enforcement_gate: |
   641	      Production use of this table GATED until pseudonymization + purge
   642	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   643	      by founder + tenant before go-live; migration-test tenant exempt.
   644	
   645	  cash_conductor_invoices:
   646	    rationale: |
   647	      Open invoice register cached from accounting provider. Same auxiliary-
   648	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   649	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   650	    columns:
   651	      id: {type: integer, required: true, source: IFOS-internal}
   652	      tenant_slug: {type: string, required: true, source: IFOS-internal}
   653	      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
   654	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
   655	      invoice_number: {type: string, required: false, source: Accounting provider}
   656	      issued_at: {type: timestamp, required: true, source: Accounting provider}
   657	      due_at: {type: timestamp, required: true, source: Accounting provider}
   658	      amount_total: {type: number, required: true, source: Accounting provider, notes: NUMERIC(15,2) GBP}
   659	      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
   660	      currency: {type: string, required: true, default: GBP, source: Accounting provider}
   661	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open, source: Accounting provider}
   662	      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
   663	      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
   664	      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
   665	      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
   666	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   667	      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
   668	    indexes:
   669	      - "(tenant_slug, due_at)"
   670	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   724	    sourcing_scout: W
   725	    concierge: R
   726	  cash_conductor_transactions:
   727	    diagnostic: none
   728	    janitor: none
   729	    scribe: none
   730	    cash_conductor: R+W
   731	    sourcing_scout: none
   732	    concierge: none
   733	  cash_conductor_invoices:
   734	    diagnostic: none
   735	    janitor: none
   736	    scribe: none
   737	    cash_conductor: R+W
   738	    sourcing_scout: none
   739	    concierge: none
   740	

codex
REJECTED

1. Sourcing Scout write access to `candidate` / `contractor` contradicts the existing entity contract. Lines 544-548 and 556 upgrade Sourcing Scout to `R+W` to write “proposed-candidate rows”, and lines 82-85 / 96-99 let it write candidate fields from CV-Library/Reed/LinkedIn. But the base schema defines `candidate` and `contractor` as Bullhorn-backed entities with required `bullhorn_id`, and `bullhorn-integration-path.md` §4.1 A5 says Sourcing Scout is R-only with writes going to the IFOS shortlist artefact, not Bullhorn. Proposed fix: keep Sourcing Scout R-only on candidate/contractor and model proposed external matches as a shortlist artefact or a new `proposed_candidate` schema/migration.

2. The supplement assumes an undeclared placement field. Line 662 defines `cash_conductor_invoices.client_contact_id` as derived from `Bullhorn placement.client_contact_id`, but neither §1 nor the base placement canonical fields declare `placement.client_contact_id`. That violates Schema-before-code because Cash Conductor would depend on a structured placement field absent from the schema. Proposed fix: add `placement.client_contact_id` as a declared JSONB key with source/access/validation, or derive invoice addressee through existing `entity_links`/contact relationships.

3. `blocked_recipients` schema and migration validation do not match. Lines 810-817 declare `blocked_recipients` as an array of strings and position it as load-bearing DNC state, but `migrations/v0.2-to-v0.3.sql` §5 only checks that it is an array and explicitly leaves element validation to the tenant-admin wizard. That weakens the hard-fail schema gate for a safety-critical outbound blocklist. Proposed fix: update the migration trigger to reject non-string array elements, matching the YAML schema.
tokens used
72,973
REJECTED

1. Sourcing Scout write access to `candidate` / `contractor` contradicts the existing entity contract. Lines 544-548 and 556 upgrade Sourcing Scout to `R+W` to write “proposed-candidate rows”, and lines 82-85 / 96-99 let it write candidate fields from CV-Library/Reed/LinkedIn. But the base schema defines `candidate` and `contractor` as Bullhorn-backed entities with required `bullhorn_id`, and `bullhorn-integration-path.md` §4.1 A5 says Sourcing Scout is R-only with writes going to the IFOS shortlist artefact, not Bullhorn. Proposed fix: keep Sourcing Scout R-only on candidate/contractor and model proposed external matches as a shortlist artefact or a new `proposed_candidate` schema/migration.

2. The supplement assumes an undeclared placement field. Line 662 defines `cash_conductor_invoices.client_contact_id` as derived from `Bullhorn placement.client_contact_id`, but neither §1 nor the base placement canonical fields declare `placement.client_contact_id`. That violates Schema-before-code because Cash Conductor would depend on a structured placement field absent from the schema. Proposed fix: add `placement.client_contact_id` as a declared JSONB key with source/access/validation, or derive invoice addressee through existing `entity_links`/contact relationships.

3. `blocked_recipients` schema and migration validation do not match. Lines 810-817 declare `blocked_recipients` as an array of strings and position it as load-bearing DNC state, but `migrations/v0.2-to-v0.3.sql` §5 only checks that it is an array and explicitly leaves element validation to the tenant-admin wizard. That weakens the hard-fail schema gate for a safety-critical outbound blocklist. Proposed fix: update the migration trigger to reject non-string array elements, matching the YAML schema.
