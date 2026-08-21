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
session id: 019e5981-8cb6-7df0-b41c-fa2e4ef515a0
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

=== TYPE-SPECIFIC SKILL: agent-bundle ===

# Codex ratification skill — review-agent-bundle

Type-specific checks for: agent.md output contracts at `agents/recruitment/<name>/agent.md` and (when present) the surrounding bundle files at `agents/recruitment/<name>/{tools.yaml,context.sh,validate.sh,cycle.sh,cleanup.sh}` + fixtures at `agents/recruitment/<name>/fixtures/*.yaml`.

This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.

**Distinction from review-architecture-decision:** agent.md files are NOT architecture-decision documents. They follow the ADR-003 v2 bundle pattern (6 files + 3 fixtures) and have their own structural requirements documented below. Do NOT REJECT an agent.md for missing Context/Decision/Consequences sections — those belong in ADRs (which live at `docs/decisions/ADR-*.md`).

---

## §1 — agent.md required-section structure (per ADR-003 + Diagnostic precedent)

Every `agents/recruitment/<name>/agent.md` MUST have these 10 sections in order. Reject if any are missing OR materially out of order.

| § | Section title | Purpose | Reject criteria |
|---|---|---|---|
| Header | (file metadata) | Status field; date; author; build wave; tier; build complexity | Missing Status field; status conflicts with content (e.g. "Accepted" but build dependencies still ⏸) |
| §1 | Output contract | One-paragraph screenshot per master brief §1 Rule 1. Names WHAT the agent produces in a single paragraph, readable cold | Missing; >3 paragraphs; doesn't name vault write path; doesn't name Gate A + Gate B thresholds |
| §2 | Invocation surface | CLI / webhook / cron / Brain UI / Telegram triggers; per-trigger auth requirements; v1.1+ deferred surfaces | Missing; lists surfaces not supported by master brief §8.2 (e.g. uses AgentMail before v1.1) |
| §3 | Output shape | Specific to agent. Diagnostic: 12 sections. Janitor: day-30 report + Bullhorn writes. Cash Conductor: reconciliation rows + chase drafts + weekly report | Missing; doesn't name the artefact paths; doesn't name the decision_log audit-row signature for each output |
| §4 | Workflow | n-step process. Each step must reference (a) the tools.yaml capability it depends on OR (b) a `_shared/` helper. Must integrate `hh_decision_*` calls at every step that produces output OR takes action | Missing; steps reference undocumented capabilities; steps that produce output/action don't call `hh_decision_*` |
| §5 | Gates | Gate A: validate.sh hard-fail conditions. Gate B: outcome success threshold + measurement mechanism | Missing; Gate A conditions not testable; Gate B threshold not cited to ULTRAPLAN/master brief; Gate A weaker than §1 output contract |
| §6 | Escalation codes | Subset of `agents/_shared/escalation-codes.md` relevant to this agent. Each cited code must exist in the catalogue OR be flagged for catalogue addition | Missing; cites invented ESC codes not in catalogue + not flagged for addition; ESC code repurposed beyond catalogue definition |
| §7 | Voice + tone constraints | `_shared/voice-loader.sh` integration; per-tenant scope; voice classifier threshold per agent.md §5 | Missing for agents that produce text output; threshold drift from master brief §8.1 Change 1 |
| §8 | Build dependencies | Prerequisites that must clear before W-X build slice can begin. Table with Status (✅ ⏸ ❌) per dep | Missing; doesn't name Bullhorn / accounting / LinkedIn commercial gates where applicable; doesn't cite Trigger 3 (Bullhorn-touching agents) or D1 (Concierge) where applicable |
| §9 | Status + open questions | Numbered list of founder-review questions; each has a resolution path (founder review at next Sunday OR pilot tenant onboarding OR commercial conversation) | Missing; questions are vague (no resolution path); doesn't acknowledge gotchas from corresponding ULTRAPLAN §8.1 A-N spec |
| §10 | When this document ratifies | Codex skill reference + status-flip criteria (Proposed → Accepted → In Force) | Missing; cites wrong Codex skill; doesn't name the W-X build-slice completion criteria for status-flip |

---

## §2 — Citation accuracy requirements

agent.md files cite extensively. Every cited line/section MUST match the source.

**Required citations:**

1. **master brief §8.2 line N** for build wave (e.g. "W5 per master brief §8.2 line 596"). Verify the line range actually contains the row claimed.
2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
3. **agents/_shared/escalation-codes.md** for every cited ESC code. Verify the code exists. Verify the trigger description matches.
4. **autosend-safety-policy.yaml** for tier classifications. Verify the action_type exists in the policy + tier assignment matches.
5. **agents/_shared/voice-loader.sh** for voice-related claims. Verify the helper functions exist.
6. **v1.0-kill-criterion.md Trigger N** references must match the actual trigger definition.
7. **vertical-schema.yaml / v0.2 supplement** for entity-field references.

**Common drift patterns to catch:**

- ESC code reused for a different trigger than its catalogue definition states
- master brief week N cited but row mismatches (e.g. "W5" but the row says W6)
- ULTRAPLAN line-anchor drift (off by ±5 lines after edits)
- Sentinel agent_names invented without registering in the catalogue (e.g. `_consultant_feedback` without an entry in escalation-codes.md or a documented sentinel registry)
- Kill-criterion Trigger references swapped (Trigger 5 cited when content describes Trigger 8 territory)

**Drift between master brief and ULTRAPLAN is the norm, not an error.** Master brief is authoritative per project hierarchy. agent.md should cite BOTH with a "drift flag" note if the build-wave timing differs (e.g. Sourcing Scout: master brief W9 vs ULTRAPLAN A5 W8-9 — note the drift; use master brief).

---

## §3 — Pre-build vs production-ready agent.md

agent.md files come in two flavours per the Diagnostic precedent:

**Pre-build scaffold (Status: Proposed)** — written BEFORE the sibling bundle files exist. The 5 W3-scaffold agents (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) are all pre-build scaffolds. Allowed gaps:

- Sibling bundle files (tools.yaml, context.sh, etc.) may not exist yet — §8 names them in the build-prereq list
- Some prereqs may be ⏸ (e.g. Bullhorn Sub-decisions A+B pending)
- §9 will have many open questions (this is the point — surface them for founder review)
- May cite ESC codes that are documented in catalogue but not yet wired in any agent

REJECT only if:
- §1 output contract is unclear (can't tell what the agent produces)
- §4 workflow has steps citing capabilities that DON'T appear in any tools.yaml — known OR planned
- §6 cites invented ESC codes that don't exist in catalogue AND aren't flagged for addition
- §8 missing prereqs that any reasonable build slice would need
- §10 doesn't name the Codex skill (this skill) for ratification

**Production-ready (Status: Accepted OR In Force)** — written AFTER bundle files exist + pass tests. Diagnostic at Day-13 + Day-19 polish is production-ready. Additional requirements:

- All 5 sibling files exist + pass shellcheck (for .sh files) + typecheck (for .ts files)
- All 3 fixtures exist + pass validate.sh against golden outputs
- §8 prereq list should be mostly ✅ (with explicit notes on any remaining ⏸)
- §10 names the W-X build-slice completion + first-production-run as status-flip criteria

REJECT if:
- §1 contract narrower than any test fixture demonstrates
- §5 Gate A conditions don't match validate.sh implementation
- §6 cites codes not implemented in cycle.sh
- §10 doesn't name the actual first-production-run evidence

---

## §4 — Boundary checks (cross-cutting)

Every agent.md is checked against the four boundaries (master brief §3):

1. **cortextOS submodule** — agent.md must NOT reference files under `packages/harness/cortextos/*`. cortextOS primitives are referenced by index (#1 Persistent PTY, #5 Telegram surface, etc.) NOT by file path.

2. **Composio/AgentMail adapter** — agent.md MUST NOT reference Composio or AgentMail directly. References to v1.1+ AgentMail integration via adapter boundary are allowed when explicitly framed as "deferred".

3. **Vault/Postgres split** — agent.md output contracts: structured per-row state → Postgres (decision_log, recent_edit, voice_corpus); narrative content → vault (Markdown files under `/vault/<tenant>/`). REJECT if §3 output shape mixes these (e.g., proposing to write 12-section Markdown reports to a Postgres column).

4. **Brain-replacement** — agent.md MUST NOT propose direct interaction with cortextOS's stock KB. All knowledge-base interaction goes through the four `bus/kb-*.sh` shadow points OR through the agent's `_shared/voice-loader.sh` helpers.

---

## §5 — Output contract for this skill

Per top-level SKILL.md: your output MUST start with literal `RATIFIED` or `REJECTED`. For agent.md ratification:

**RATIFY** when:
- All 10 sections present (§ Header + §1-§10)
- §1 output contract is single-paragraph + names artefact path
- All citations verified against source files (master brief / ULTRAPLAN / escalation-codes / vertical-schema)
- No invented ESC codes / no invented sentinels
- Four boundary checks pass
- Status field consistent with content
- For pre-build: ESC code references either exist in catalogue OR are flagged for catalogue addition

**REJECT** when:
- Sections missing OR materially out of order
- Citation drift (cited line doesn't contain claimed content)
- Invented codes/sentinels/payload fields without catalogue registration
- Output contract doesn't name vault path OR Gate A/B thresholds
- §4 workflow steps missing `hh_decision_*` calls at output/action points
- Boundary violation (submodule modification, Composio/AgentMail in body, vault/Postgres mix, KB direct access)
- Gate A weaker than §1 output contract claims

**Advisory notes (allowed under RATIFIED):**
- "§9 question 3 is vague — suggest tightening before founder review"
- "ESC code list omits ESC_RATE_LIMIT_HIT which Step N implies — suggest adding"
- "§8 prereq list missing the voice classifier microservice as W4-5 dependency"

Advisory notes do NOT block ratification — they're suggestions for the author. Use sparingly; if 5+ advisory notes accumulate, REJECT instead and require a remediation pass.

---

## §6 — Special case: Diagnostic agent.md

Diagnostic was scaffold-ratified at Day-11 (Round 3 RATIFIED) + production-shape polished at Day-13 (commits `97a57a2` + `2688b6a`) + Day-19 remediation (commit `6e0cb86`). Codex Round 4 Phase 1 hit hard ceiling — see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` for the 5-issue disposition.

When re-ratifying Diagnostic agent.md with THIS skill (not review-architecture-decision):

- Issue 5 from the disagreement doc (missing Context/Decision/Consequences sections) is **REJECTED RECONSIDERED** — this skill explicitly does NOT require those sections for agent.md files. The Round-5 REJECTED on this basis was caused by Codex applying the wrong skill (review-architecture-decision was used instead of this one).
- Issues 1-4 from the disagreement doc may still apply when re-evaluated under this skill — verify each per §1-§4 above.
- If Issues 1-4 resolve via the founder arbitration recommendations in the disagreement doc (which I'd accept as the right framing for v0), then Diagnostic agent.md should RATIFY under this skill.

---

*End of review-agent-bundle skill.*

=== ARTEFACT UNDER REVIEW ===

Path: agents/recruitment/scribe/agent.md

--- BEGIN ARTEFACT ---

# Scribe — the data spine

**Status:** Proposed (Day-17 pre-W6-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice).
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown attachment containing the consultant's "things I'd write down but there's no field for" observations. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.

---

## §2 — Invocation surface

### Webhook (v1.0 primary path)

```http
POST https://<tenant>.ifos.app/agents/scribe/webhook
Authorization: Bearer <fathom-or-fireflies-shared-secret>
Content-Type: application/json

{
  "provider": "fathom" | "fireflies" | "ringover",
  "call_id": "<provider-call-id>",
  "transcript_url": "<provider-transcript-url>",
  "duration_seconds": 1234,
  "participants": [...],
  "metadata": {...}
}
```

Each provider has its own webhook signature scheme (Fathom HMAC-SHA256; Fireflies bearer token; Ringover OAuth-protected). Auth handled per-provider in `tools.yaml` capability declarations.

### Manual trigger (v1.0 — debugging / replay)

```bash
ifosctl scribe replay --tenant <slug> --call-id <provider-call-id>
```

Useful when a webhook was missed or a transcript needs reprocessing after taxonomy update.

### v1.1+ surfaces (deferred)

- Telegram command (`@ifos_bot scribe replay <call-id>`)
- Brain UI per-call "Reprocess" button
- Brain UI "Confidence audit" view showing extraction confidence histograms

---

## §3 — Output shape

Two outputs per webhook. Both write atomically (one transaction); rollback on either failure.

### Output 1 — Bullhorn structured-field writes (≥3 per call)

Bullhorn entity inferred from call participants + tenant Bullhorn lookup:
- 1:1 call with candidate → Candidate entity update
- 1:1 call with client contact → Contact entity update
- Briefing call (consultant + client) → Brief entity update
- Placement check-in (consultant + placed candidate) → Placement entity update
- Opportunity scoping (consultant + prospect) → Opportunity entity update

Minimum 3 fields extracted per call (Gate A). Typical fields by entity:

| Entity | Likely fields |
|---|---|
| Candidate | location, current_role, notice_period, salary_expectation, work_style (perm/contract/hybrid), key_skills_summary |
| Contact | seniority, decision_authority_level, prefers_comms_via, next_meeting_target |
| Brief | budget_range, deadline_date, role_type, must_haves, nice_to_haves, deal_breakers, decision_committee |
| Placement | start_date_confirmation, week_1_status, blockers, satisfaction_signal |
| Opportunity | sector, headcount_growth_signal, hiring_velocity, decision_window |

Per `vertical-schema.yaml` v0.1 + v0.2; field names match canonical schema.

Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.

### Output 2 — Tacit-note Markdown attachment

One Markdown note per call, attached to the same Bullhorn entity as Output 1 via `POST /Note`. Structure:

```markdown
# Tacit notes — <Call-context-summary>
**Date:** <ISO-date>  **Duration:** <N> min  **Participants:** <list>

## Things observed that don't fit a structured field

- <Observation 1 — bullet, 1-2 sentences, with transcript timestamp [MM:SS]>
- <Observation 2 — ...>
- ...

## Tone signals

- <Tone signal 1 — e.g., "client sounded frustrated about Bullhorn data quality">
- <Tone signal 2 — ...>

## Open questions for consultant follow-up

- <Open question 1>
- <Open question 2>
```

Length cap: 800 words. Voice-classified (≥0.75); falls back to "needs consultant review" placeholder if classifier persistently fails (ESC_VOICE_DRIFT).

Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
1. Relationship signal (client warmth, candidate enthusiasm, prior friction)
2. Process friction (consultant complaint, tool gap, time waste)
3. Competitive intel (mentions of competitor agencies / candidates working with others)
4. Pricing/budget signal (off-record indications of room or constraint)
5. Decision-process insight (who actually decides; coffee-machine politics)
6. Calendar / availability nuance (vacation, life events affecting timeline)
7. Cultural fit observation (working style, communication preferences)
8. Risk flag (legal, IR35, compliance, reference concerns)

v1.1+: expand taxonomy based on first 3 pilot tenants' patterns.

---

## §4 — Workflow

10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.

```
0. Session start (webhook handler)
   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice
     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")

1. Webhook signature verification
   → per-provider HMAC / bearer / OAuth check
   → ESC_SCHEMA_VIOLATION on signature mismatch; reject with 401
   → record provider + call_id in trigger payload

2. Bullhorn auth refresh
   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
   → ESC_BULLHORN_AUTH if refresh fails after 2 retries

3. Transcript fetch
   → provider-specific: fathom.get_transcript(call_id) | fireflies.get(...)
   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII

4. Participant + entity inference
   → match transcript participants against Bullhorn contacts + candidates
     + consultant accounts (per tenant config)
   → infer call context (1:1 vs briefing vs placement vs opportunity)
   → resolve target Bullhorn entity (CRN + entity_type)
   → ESC_SCHEMA_VIOLATION if no resolvable entity (e.g., unknown phone number)

5. LLM field extraction
   → prompt = (transcript + entity context + vertical-schema entity field list
     + 3 voice-corpus examples)
   → output = JSON with per-field confidence scores
   → discard fields confidence <0.6 (per Gate A)
   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE

6. LLM tacit-note generation
   → prompt = (transcript + 8-category taxonomy + 3 voice-corpus examples
     + tone-rule filter)
   → output = Markdown narrative per §3 Output 2 shape
   → voice classifier scores against tenant style guide
   → ESC_VOICE_DRIFT if score <0.75 after 3 retries

7. Field-extraction validation against vertical-schema
   → verify each extracted field name exists in target entity schema
   → verify each extracted value passes per-field type/range checks
   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION)

8. Bullhorn write — structured fields (yellow tier)
   → PATCH /<EntityType>/<id> with field map
   → atomic transaction; rollback on Bullhorn 4xx/5xx
   → ESC_BULLHORN_WRITE_FAIL on failure; do NOT proceed to Step 9

9. Bullhorn write — tacit-note attachment (yellow tier)
   → POST /Note linked to entity from Step 4
   → on success: hh_decision_action("bullhorn_scribe_field_write" +
     "bullhorn_scribe_note_attach", target_entity, payload_hash, payload_preview)
   → on failure: rollback Step 8 (best-effort PATCH /<EntityType>/<id>
     reversing the field changes); ESC_BULLHORN_WRITE_FAIL

10. Session close + SLA metric
   → compute elapsed_seconds from webhook receipt
   → if elapsed > 600 (10 min): warn ESC_SCRIBE_SLA_MISS (not blocking)
   → if elapsed > 300 (5 min): info-level (counted against Gate B 90%)
   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
   → exit code 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:

- Webhook signature valid per provider (Step 1)
- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
- 1 tacit-note generated with voice classifier ≥0.75
- Field names exist in target entity per vertical-schema.yaml
- Per-field type + range validation passes
- No PII outside firm boundary in tacit-note narrative
- Bullhorn auth refresh succeeded

Gate A failures fire `ESC_SCHEMA_VIOLATION` or `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`; transcript stays in `/tmp` (auto-purged 24h); operator notified.

### Gate B — Outcome thresholds (success metrics, not block)

Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.

Two metrics:
- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)

Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).

Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).

---

## §6 — Escalation codes

Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
| `ESC_PROVIDER_FETCH_FAIL` | Fathom/Fireflies/Ringover transcript fetch fails | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
| `ESC_SCHEMA_VIOLATION` | Webhook signature fail OR vertical-schema validation fail | **blocking** | operator + ifos_oncall |
| `ESC_SCRIBE_SLA_MISS` | Webhook-to-Bullhorn-write >10 min (Gate B miss) | info | (logged; aggregated to Gate B metric) |
| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
| `ESC_AUTOSEND_YELLOW_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |

Scribe does NOT use:

- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
- `ESC_BULLHORN_OAUTH_REVOKED` — escalated from `ESC_BULLHORN_AUTH` only after 6 consecutive auth failures (Concierge handles)

---

## §7 — Voice + tone constraints

Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
  - No identifying language about call participants beyond their professional context
  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
  - No compensation specifics in tacit notes (those go to structured fields only)
- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT` (separate from per-run drift).

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies (W6 prerequisites)

Scribe build cannot start until ALL of the following are confirmed:

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
| Per-tenant call-routing config (which provider) | Tenant onboarding | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| Tacit-note taxonomy v0.1 (8 categories) finalised | Founder review with first pilot | ⏸ |
| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
| `context.sh` hydration | Build at W6 start (~0.5 day) | ⏸ |
| `cycle.sh` orchestration (10-step) | Build at W6 start (~2 days) | ⏸ |
| 3 fixtures with golden outputs | Build at W6 start (~1 day) | ⏸ |
| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |

**Until ALL ⏸ items resolve to ✅, W6 build slice does not start.**

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
| Q3 | Tacit-note taxonomy v0.1 — 8 categories proposed in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH. Could leave entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |

### Gotchas (carried forward from ULTRAPLAN A3 line 527)

1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.

Status flips Proposed → Accepted when:
- Codex Round 4 Phase 2 ratifies
- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
- Q2 cost model approved with budget cap

Status flips Accepted → In Force when:
- W6 build slice produces all 5 sibling bundle files + 3 fixtures
- First production transcript processed end-to-end against migration-test tenant
- SLA + edit-rate Gate-B metrics measurable
- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)

Until then: this document is a forward-looking scaffold.

*End of Scribe agent.md draft.*

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
I’ll verify the cited source lines and shared catalogues before giving the verdict, because this ratification hinges on citation accuracy and boundary compliance.
exec
/bin/zsh -lc "nl -ba docs/ULTRAPLAN.md | sed -n '510,532p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/master-brief.md | sed -n '585,605p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
nl: docs/ULTRAPLAN.md: No such file or directory

 succeeded in 0ms:
nl: docs/master-brief.md: No such file or directory

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_BULLHORN_WRITE_FAIL|ESC_PROVIDER_FETCH_FAIL|ESC_VOICE_DRIFT|ESC_FIELD_EXTRACTION_LOW_CONFIDENCE|ESC_PII_LEAKAGE_RISK|ESC_SCHEMA_VIOLATION|ESC_SCRIBE_SLA_MISS|ESC_RATE_LIMIT_HIT|ESC_AUTOSEND_YELLOW_SPOT_CHECK|ESC_VOICE_DRIFT_TENANT|ESC_BULLHORN_OAUTH_REVOKED" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
97:#### `ESC_BULLHORN_AUTH`
120:#### `ESC_VOICE_DRIFT`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar

exec
/bin/zsh -lc "rg -n \"bullhorn_scribe_field_write|bullhorn_scribe_note_attach|yellow|Tier|action_type|autosend\" agents docs packages -g 'autosend-safety-policy.yaml' -g '*.yaml' -g '*.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:3:# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
agents/_shared/autosend-policy.yaml:4:# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
agents/_shared/autosend-policy.yaml:8:# 29 v1.0 action_types: 6 green + 5 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:10:#   tier            green|yellow|orange|red
agents/_shared/autosend-policy.yaml:13:#   sample_rate     yellow only: 1-in-N for spot-check sampling
agents/_shared/autosend-policy.yaml:23:action_types:
agents/_shared/autosend-policy.yaml:26:  # GREEN — auto-send without review (6 action_types)
agents/_shared/autosend-policy.yaml:66:  # YELLOW — auto-send with 1-in-N spot-check (5 action_types)
agents/_shared/autosend-policy.yaml:70:    tier: yellow
agents/_shared/autosend-policy.yaml:77:    tier: yellow
agents/_shared/autosend-policy.yaml:84:    tier: yellow
agents/_shared/autosend-policy.yaml:91:    tier: yellow
agents/_shared/autosend-policy.yaml:98:    tier: yellow
agents/_shared/autosend-policy.yaml:105:  # ORANGE — per-action human approval (10 action_types)
agents/_shared/autosend-policy.yaml:180:  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
agents/_shared/autosend-policy.yaml:246:  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes
agents/_shared/autosend-policy.yaml:254:  - "tier ∈ {green, yellow, orange, red}"
agents/_shared/autosend-policy.yaml:255:  - "yellow action_types MUST declare sample_rate (positive integer)"
agents/_shared/autosend-policy.yaml:256:  - "orange action_types MUST declare timeout (ISO-8601 duration)"
agents/_shared/autosend-policy.yaml:257:  - "red action_types MUST declare block_reason"
agents/_shared/autosend-policy.yaml:258:  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
agents/_shared/autosend-policy.yaml:259:  - "29 total action_types (6 green + 5 yellow + 10 orange + 8 red); v1.0 frozen"
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:208:      action_type:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:211:        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
agents/_shared/escalation-codes.md:13:The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
agents/_shared/escalation-codes.md:20:payload           — JSON object: {tier?, action_type?, target?, payload_hash?, reason, ...code-specific fields}
agents/_shared/escalation-codes.md:31:Source: `docs/decisions/autosend-safety-policy.md` §5
agents/_shared/escalation-codes.md:39:- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`
agents/_shared/escalation-codes.md:43:- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
agents/_shared/escalation-codes.md:46:- **Payload fields:** `tier='red'`, `action_type`, `target`, `payload_hash`, `reason='red_tier_classification'`
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:53:- **Payload fields:** `tier='fail-safe-red'`, `action_type`, `target`, `reason` (one of `unknown_action_type`, `override_resolution_failed`, `unknown_tier:<value>`)
agents/_shared/escalation-codes.md:254:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
packages/agent-renderer/templates/claude-md-preamble.md:63:Auto-send tier policy per `_shared/autosend-policy.yaml`. Tenant override file (if present): `/vault/{{tenant_slug}}/_config/autosend-overrides.yaml` — read by `autosend_apply_tenant_override` per `docs/decisions/autosend-safety-policy.md` §4.
agents/_shared/README.md:12:| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:27:2. **Fallback mode (degraded / offline)** — `IFOS_DB_URL` unset OR `psql` unavailable OR `psql` exited non-zero. Helpers append JSON lines to `${IFOS_DECISION_LOG_FALLBACK:-/vault/<tenant>/decision-log.jsonl}`. The trail replays into Postgres when connectivity returns via the autosend-syncer worker (Week 5+).
agents/_shared/README.md:41:| `HH_POLICY_FILE` | no | Override path to `autosend-policy.yaml` | `${CTX_AGENT_DIR}/.claude/hooks/_shared/autosend-policy.yaml` |
agents/_shared/README.md:43:| `HH_AWAIT_TEST_MODE` | no (test only) | `approve` / `reject` / `timeout` — short-circuits `autosend_await_approval` poll loop | — |
agents/_shared/README.md:53:hh_decision_action  <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/README.md:58:### 7 `autosend_*` helpers (autosend-safety-policy §4)
agents/_shared/README.md:61:autosend_policy_lookup        <action_type>                                          # prints tier
agents/_shared/README.md:62:autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>               # prints possibly-elevated tier
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:64:autosend_escalate             <ESC_CODE> [<key=value>...]
agents/_shared/README.md:65:autosend_should_sample        <action_type> <tenant_slug>                            # returns 0 if sampled
agents/_shared/README.md:66:autosend_spot_check_enqueue   <action_type> <target> <hash> <preview> <tenant_slug>
agents/_shared/README.md:67:autosend_await_approval       <action_type> <target> <hash>                          # blocks until resolved
agents/_shared/README.md:70:## Auto-send tier dispatch (autosend-safety-policy §4)
agents/_shared/README.md:74:| Tier | Behaviour | Return |
agents/_shared/README.md:77:| **yellow** | Emit `phase=action`, draw 1-in-N spot-check sample, return 0 | 0 |
agents/_shared/README.md:84:Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:167:- `agents/_shared/autosend-policy.yaml` (Reference — runtime table)
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:177:- `docs/decisions/autosend-safety-policy.md` — full tier model + §4 reference impl
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:192:        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
docs/verticals/recruitment/vertical-schema.yaml:335:        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
docs/verticals/recruitment/vertical-schema.yaml:365:        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:666:# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/operations/codex-ratification-guide.md:397:If `IFOS_DB_URL` isn't set when the wrapper runs (or psql isn't on PATH or the live DB rejects the write), the row appends to `logs/codex-ratification.jsonl` instead. Same shape, JSON Lines. Replays into Postgres later via the autosend-syncer worker (Week 5+).
packages/agent-renderer/README.md:120:- **Telegram-down hang for orange-tier autosend** (autosend-safety-policy §5) is a Phase-3 concern in `hook-helpers.sh` `autosend_await_approval`, not a renderer concern. Documented for completeness.
agents/recruitment/cash-conductor/agent.md:8:**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 539). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 539 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 540) — the FD-tier closer metric. Chase drafts are orange-tier per `autosend-safety-policy.yaml` (consultant approval required before send via Concierge); reconciliation writes are yellow-tier.
agents/recruitment/cash-conductor/agent.md:72:### Output 1 — Reconciliation rows (yellow tier)
agents/recruitment/cash-conductor/agent.md:84:Stages 1-2 auto-write reconciliation to accounting system (yellow tier; spot-check sampled). Stages 3-4 queue for consultant review. Stage 5 flagged in weekly report.
agents/recruitment/cash-conductor/agent.md:86:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:90:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. Output is a queued draft, NOT a send. Drafts route to Concierge (which handles the actual send pipeline + consultant approval per autosend §4 orange tier).
agents/recruitment/cash-conductor/agent.md:107:Each draft: `decision_log` row `agent_name='cash_conductor'`, `phase='output'`, `action_type='chase_draft'`, `tier='orange'`, payload includes the draft.
agents/recruitment/cash-conductor/agent.md:169:   → write Stage 1-2 matches to accounting (yellow tier) atomically
agents/recruitment/cash-conductor/agent.md:173:6. Reconciliation write (yellow tier; per match)
agents/recruitment/cash-conductor/agent.md:177:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
agents/recruitment/cash-conductor/agent.md:204:    → Concierge handles autosend-bridge call to operator (D1 path per
agents/recruitment/cash-conductor/agent.md:240:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 539 verbatim):
docs/operations/codex-round-2-handoff.md:66:### Tier 1 — Re-ratify Round-1 REJECTED (14 artefacts)
docs/operations/codex-round-2-handoff.md:77:| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
docs/operations/codex-round-2-handoff.md:87:**Likely outcomes:** 11-12 of 14 RATIFY. Items #6 (autosend tier contradiction) and #14 (PII retention) are founder-decision-bound (D1/D3); Codex may RATIFY-with-advisory or REJECT pending decisions.
docs/operations/codex-round-2-handoff.md:89:### Tier 2 — Day-9 architecture+tenancy artefacts (4 new)
docs/operations/codex-round-2-handoff.md:100:### Tier 3 — Day-11 disagreement + decision + spec + D3 prep (8 new)
docs/operations/codex-round-2-handoff.md:107:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | `review-architecture-decision` | RATIFY (Proposed spec; alternatives weighed; ratifies cortextOS primitive-4 reuse) |
docs/operations/codex-round-2-handoff.md:124:# Tier 1 — re-ratify 14 previously REJECTED
docs/operations/codex-round-2-handoff.md:129:# Tier 2 — Day-9 new artefacts (run individually)
docs/operations/codex-round-2-handoff.md:135:# Tier 3 — Day-11 new artefacts
docs/operations/codex-round-2-handoff.md:139:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-handoff.md:168:  review, tenant lifecycle, founder decision briefing, 2 disagreement docs, autosend
docs/operations/codex-round-2-handoff.md:195:For Round-1-redux items (Tier 1): explicitly note whether the Round-1 issue
docs/operations/codex-round-2-handoff.md:199:For disagreement docs (Tier 3 items 19 + 20): you are evaluating recursive
docs/operations/codex-round-2-handoff.md:211:  docs/decisions/autosend-safety-policy.md
docs/operations/codex-round-2-handoff.md:231:  docs/decisions/autosend-approval-bridge-spec.md  (review-architecture-decision)
docs/operations/codex-round-2-handoff.md:240:| Tier | Artefact | Round-1 verdict | Round-2 verdict | Issue count | Output file |
docs/operations/codex-round-2-handoff.md:265:This is the expected case for most Tier 1 items. Mark as ratified in the manifest queue table:
docs/operations/codex-round-2-handoff.md:286:If Codex rejects a Tier 1 item again, two sub-cases:
docs/operations/codex-round-2-handoff.md:288:**Sub-case 2a: Same issue as Round 1** — incorporation didn't actually fix the root cause. Escalate to founder; reopen as a fresh issue. Likely candidates: autosend-safety-policy (D1 + D3 unresolved); v0.2 supplement (D3 unresolved).
docs/operations/codex-round-2-handoff.md:296:Expected for Tier 2 + most of Tier 3. Manifest queue marks as ratified. No further action.
docs/operations/codex-round-2-handoff.md:300:Tier 2/3 artefact rejected on first encounter. Read Codex output carefully:
docs/operations/codex-round-2-handoff.md:375:| Tier | Items | Mean time | Subtotal |
agents/recruitment/scribe/agent.md:8:**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown attachment containing the consultant's "things I'd write down but there's no field for" observations. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:176:8. Bullhorn write — structured fields (yellow tier)
agents/recruitment/scribe/agent.md:181:9. Bullhorn write — tacit-note attachment (yellow tier)
agents/recruitment/scribe/agent.md:183:   → on success: hh_decision_action("bullhorn_scribe_field_write" +
agents/recruitment/scribe/agent.md:184:     "bullhorn_scribe_note_attach", target_entity, payload_hash, payload_preview)
agents/recruitment/scribe/agent.md:202:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:247:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
docs/operations/codex-round-2-remediation-prompt.md:238:  FIX 8 — autosend-approval-bridge-spec.md category mapping rewrite
docs/operations/codex-round-2-remediation-prompt.md:240:  File: docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-remediation-prompt.md:243:  Issue 2: new autosend_approval_mappings table not added to
docs/operations/codex-round-2-remediation-prompt.md:266:         new autosend_approval_mappings table as the 10th tenant-data
docs/operations/codex-round-2-remediation-prompt.md:297:  FLAG 1 — autosend-safety-policy.md tier contradiction
docs/operations/codex-round-2-remediation-prompt.md:306:  > the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`).
docs/operations/codex-round-2-remediation-prompt.md:311:  FLAG 2 — autosend-safety-policy.md legal placeholder
docs/operations/codex-round-2-remediation-prompt.md:351:  Q5: When autosend_approval_mappings ships in v0.3 with the bridge
docs/operations/codex-round-2-remediation-prompt.md:352:  implementation (per docs/decisions/autosend-approval-bridge-spec.md),
docs/operations/codex-round-2-remediation-prompt.md:391:    - autosend-approval-bridge-spec.md  (FIX 8)
docs/operations/codex-round-2-remediation-prompt.md:472:        docs/decisions/autosend-approval-bridge-spec.md \
docs/operations/codex-round-2-remediation-prompt.md:473:        docs/decisions/autosend-safety-policy.md \
docs/operations/codex-round-2-remediation-prompt.md:509:    - autosend-approval-bridge-spec.md: category mapping rewritten using
docs/operations/codex-round-2-remediation-prompt.md:515:    - autosend-safety-policy.md §1 + §10: D1 + D2/D3 blocker annotations
docs/operations/codex-round-2-remediation-prompt.md:521:      subtle case + §6 Q5 autosend_approval_mappings table inventory
docs/operations/codex-round-2-remediation-prompt.md:549:  - Resolve D1 autosend orange-tier v1.0 path
docs/operations/codex-round-2-remediation-prompt.md:623:6. bullhorn-integration-path.md line 95 sharpening + Gate hierarchy subsection + disagreement doc closure + autosend-approval-bridge-spec.md category mapping rewrite + pii-purge-operational-pattern.md "Proposed pending D3"
docs/operations/codex-round-2-remediation-prompt.md:626:- FLAG 1: autosend-safety-policy.md §1 D1 annotation
docs/operations/codex-round-2-remediation-prompt.md:627:- FLAG 2: autosend-safety-policy.md §10 D2+D3 annotation
docs/operations/codex-round-2-remediation-prompt.md:631:- tenancy-invariants.md §2 T1 (nullability subtle case) + §6 Q5 (autosend_approval_mappings inventory)
docs/operations/codex-ratification-execution-plan.md:130:| 8 | autosend-safety-policy | `docs/decisions/autosend-safety-policy.md` | A |
docs/operations/codex-ratification-execution-plan.md:167:| 25 | autosend-policy.yaml | `agents/_shared/autosend-policy.yaml` | A |
agents/recruitment/sourcing-scout/agent.md:8:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:46:- Night Sourcer Tier-1 always-on (Brain UI dashboard; cortextOS primitive #6)
agents/recruitment/sourcing-scout/agent.md:193:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 553 verbatim):
docs/operations/codex-round-2-autonomous-prompt.md:84:For Tier 1 (14 re-ratifications): the Round-1 verdict + remediation commit 
docs/operations/codex-round-2-autonomous-prompt.md:90:For Tier 3 disagreement docs (items 19 + 20 in §3): you are evaluating 
docs/operations/codex-round-2-autonomous-prompt.md:97:For autosend-safety-policy.md (Tier 1 item #6) and v0.2 supplement (item 
docs/operations/codex-round-2-autonomous-prompt.md:113:  - Tier 1 (re-ratify): X RATIFIED / Y REJECTED of 14
docs/operations/codex-round-2-autonomous-prompt.md:114:  - Tier 2 (new Day-9): X RATIFIED / Y REJECTED of 4
docs/operations/codex-round-2-autonomous-prompt.md:115:  - Tier 3 (new Day-11): X RATIFIED / Y REJECTED of 8
docs/operations/codex-round-2-autonomous-prompt.md:119:  Columns: Tier | Path | Skill | Round-1 verdict | Round-2 verdict | 
docs/operations/codex-round-2-autonomous-prompt.md:160:For new artefacts (Tier 2 + Tier 3): disposition says "First ratification 
docs/operations/codex-round-2-autonomous-prompt.md:192:  Tier 1 (re-ratify Round-1 REJECTED): <X> of 14 flipped to RATIFIED.
docs/operations/codex-round-2-autonomous-prompt.md:193:  Tier 2 (Day-9 new artefacts): <X> of 4 RATIFIED.
docs/operations/codex-round-2-autonomous-prompt.md:194:  Tier 3 (Day-11 new artefacts): <X> of 8 RATIFIED.
docs/operations/codex-round-2-autonomous-prompt.md:219:  Tier 1: X/14 — most should have flipped from REJECTED → RATIFIED
docs/operations/codex-round-2-autonomous-prompt.md:220:  Tier 2: X/4
docs/operations/codex-round-2-autonomous-prompt.md:221:  Tier 3: X/8 (incl 2 disagreement-recursive verdicts)
docs/operations/codex-round-2-autonomous-prompt.md:253:4. **DO NOT make founder decisions.** Items like D1 (autosend orange tier), 
packages/agent-renderer/tests/fixtures/test-agent/tools.yaml:11:autosend_categories: []
agents/recruitment/janitor/agent.md:8:**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:29:Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.
agents/recruitment/janitor/agent.md:65:### Output 2 — Bullhorn writes (yellow tier)
agents/recruitment/janitor/agent.md:67:Per `autosend-safety-policy.yaml` row `janitor_bullhorn_write`. Three write categories:
agents/recruitment/janitor/agent.md:73:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type='bullhorn_candidate_merge' | 'bullhorn_field_backfill' | 'bullhorn_note_attach'`, `tier='yellow'`, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:136:9. Bullhorn write batch (yellow tier — spot-check sampling)
agents/recruitment/janitor/agent.md:138:     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
agents/recruitment/janitor/agent.md:146:   → group by action_type; tally success/fail; compute Gate-B metric
agents/recruitment/janitor/agent.md:153:   → if Gate-B target missed: yellow-tier notification + 200-char executive
agents/recruitment/janitor/agent.md:168:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
docs/operations/goal-week-3-polish-and-scaffold.md:24:9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
docs/operations/goal-week-3-polish-and-scaffold.md:29:14. **`agents/_shared/autosend-policy.yaml`** (29 action types; tier classifications)
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:302:- **Tier:** Tier 1 (batch nightly cron; not request-driven) per `sequencing-target.md` §2.1
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:337:- **Tier:** Tier 2 (request-driven, per-call invocation) per `sequencing-target.md` §2.1
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:366:- **Tier:** Tier 1 (batch daily; cron-driven)
docs/operations/goal-week-3-polish-and-scaffold.md:394:- **Tier:** Tier 2 (request-driven per brief)
docs/operations/goal-week-3-polish-and-scaffold.md:409:#### Step 12 — `agents/recruitment/concierge/agent.md` (~3-4 hours; most complex due to autosend orange-tier)
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:414:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- `2026-05-20-codex-round-1-founder-decisions.md` §D1 (autosend orange-tier decision)
docs/operations/goal-week-3-polish-and-scaffold.md:421:- **Tier:** Tier 1 (continuous; lifecycle-event-driven via Bullhorn poll cycle)
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:86:| Tier | £/mo | Agents | Seats | Integrations | Runs/mo |
docs/operations/seedlegals-engagement-queries.md:29:**Recommended Tier 1 (pre-LOI minimum):** LOI template + DPA template + Mutual NDA = ~£500, all delivered within 72h.
docs/operations/seedlegals-engagement-queries.md:31:**Recommended Tier 2 (post-pilot):** Full SaaS subscription agreement + customer-grade DPA — engage when first pilot converts to paid customer. Higher-stakes; consider specialist firm.
docs/operations/seedlegals-engagement-queries.md:68:> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
agents/recruitment/diagnostic/fixtures/01-primary.yaml:106:    action_type: diagnostic_report_render
agents/recruitment/diagnostic/fixtures/01-primary.yaml:110:    action_type: diagnostic_cleanup
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:104:## Limits (Free Tier)
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:101:    action_type: diagnostic_report_render
docs/RISK-REGISTER.md:10:| 1 | CortexOS primitives 3 or 4 are flaky in production | High | High | Daily orchestrator health check flags > 1 incident/week | Every Tier-1 agent has a degraded-mode fallback; manual file-bus handoff documented | **Updated Day 1** — primitive 3 (bus) is **shipped and tested**; primitive 4 (approval gates) is **shipped and tested**; only primitive 1 (PTY/PM2) is **shipped but flaky** per quirks 2-3 + 2026-04-22 restart-storm evidence in `cortextos-primitive-status.md`. Risk severity revised down. |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/operations/founder-legal-setup-guide.md:229:> Would you provide a quote? Happy to share more about our autosend-safety-policy on a call.
docs/architecture/tenancy-invariants.md:253:| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:38:## Three-Tier Protocol
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:40:### Tier 1 — Wind-Down (>= 85% utilization)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:49:- Check usage every 5 minutes until dropping below 85% or escalating to Tier 2
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:55:### Tier 2 — Minimal (85-95% utilization)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:70:### Tier 3 — Dark (>= 95% utilization)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:115:- `--warn-7day 75` — early warning at 75% (10 points before Tier 1)
packages/harness/cortextos/community/skills/rate-limit-management/SKILL.md:138:| Utilization | Tier | Behavior |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:73:**My recommendation:** **B** — cleaner, avoids sentinel proliferation. Feedback events are conceptually Diagnostic's domain (they validate Diagnostic outputs), so the agent_name should be Diagnostic with a specific action_type marker.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:91:3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
docs/architecture/architecture-cohesion-review.md:74:| vault-concurrency.md §6 | ESC wiring | hook-helpers.sh::autosend_escalate | ✓ landed Phase 3 (e6e9df1) |
docs/architecture/architecture-cohesion-review.md:123:### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)
docs/architecture/architecture-cohesion-review.md:125:- **autosend-safety-policy.md** §7 says `payload_preview` MUST exclude raw PII (max 500 chars, no names/phones/emails)
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:16:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:20:**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:44:- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:45:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:164:Implementation work: <commit reference or "in autosend §9 update commit">
agents/recruitment/diagnostic/agent.md:8:**Tier:** 2 (request-driven; no persistent PTY) per sequencing-target.md §2.1.
agents/recruitment/diagnostic/agent.md:33:Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY) → exits within 10-15 min per Ultraplan §8.1 A1 turnaround target.
agents/recruitment/diagnostic/agent.md:146:    → action tier per autosend-policy.yaml: green (no external send; vault write only)
agents/recruitment/diagnostic/agent.md:156:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces:
agents/recruitment/diagnostic/agent.md:189:- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:25:- `agents/_shared/hook-helpers.sh` + `autosend-policy.yaml` (Phase 3, commit `e6e9df1`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
agents/recruitment/concierge/README.md:14:The customer-comms agent. Highest-stakes v1.0 agent (XL complexity, 4 weeks build). 12 lifecycle events × 2 recipient roles = 24+ comms-template variants per tenant. Orange-tier autosend per `autosend-safety-policy.yaml` — consultant approval mandatory before send.
agents/recruitment/concierge/README.md:20:- `tools.yaml` — Bullhorn R+W + Microsoft Graph + Gmail + voice classifier + autosend bridge (per D1 outcome)
agents/recruitment/concierge/README.md:35:**Founder Decision D1 (autosend orange-tier path) MUST be resolved before W10 build starts.** Per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Three options:
agents/recruitment/concierge/README.md:38:- D1-C: no autosend; manual consultant pickup (0 dev; ships fastest but worst UX)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:188:Tier-1 always-on candidate-lifecycle agent. No candidate ghosted, no client
docs/architecture/agent-bundle-renderer-design.md:380:- Operating window: 24/7 (Tier 1)
agents/recruitment/concierge/agent.md:3:**Status:** Proposed (Day-19 pre-W10-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice).
agents/recruitment/concierge/agent.md:8:**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Drafts are orange-tier per `autosend-safety-policy.yaml` — consultant approval required before send via the autosend-bridge mechanism (Founder Decision D1 path A bridge OR D1-B shim OR D1-C manual; W10 design selects). Sends route via tenant's Microsoft Graph OR Gmail (per-tenant config; AgentMail deferred to v1.1+). Gate A hard-fails any draft generated >30 minutes after lifecycle event, any draft with voice classifier <0.75, or any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). Gate B success threshold: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='action'`, `action_type='concierge_draft_<event_type>'`, `tier='orange'`, payload includes voice_score + recipient + escalation_position.
agents/recruitment/concierge/agent.md:104:The actual SEND happens through the autosend-bridge (D1 path) — consultant approves → send routes through Microsoft Graph / Gmail; Bullhorn activity-log entry written post-send.
agents/recruitment/concierge/agent.md:159:     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
agents/recruitment/concierge/agent.md:193:      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
agents/recruitment/concierge/agent.md:194:    → per autosend-policy.yaml: orange-tier; consultant approves
agents/recruitment/concierge/agent.md:229:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 verbatim:
agents/recruitment/concierge/agent.md:314:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
agents/recruitment/concierge/agent.md:322:| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
agents/recruitment/concierge/agent.md:347:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
docs/decisions/autosend-approval-bridge-spec.md:6:**Surfaced by:** Founder Decision D1 (`docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`) + Codex Round 1 autosend rejection issue 2
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:18:- `agents/_shared/hook-helpers.sh::autosend_await_approval` writes pending marker `/vault/<tenant>/pending-approvals/<hash>.pending`
docs/decisions/autosend-approval-bridge-spec.md:68:A new IFOS package: `packages/autosend-approval-bridge/`. ~200-250 lines of TypeScript. Runs as a long-lived process (PM2-managed alongside the daemon).
docs/decisions/autosend-approval-bridge-spec.md:78:  - Read action_type, target, payload_hash, payload_preview from the marker
docs/decisions/autosend-approval-bridge-spec.md:79:  - Map IFOS action_type → cortextOS ApprovalCategory (autosend taxonomy)
docs/decisions/autosend-approval-bridge-spec.md:98:The bridge's `autosend_await_approval` polling loop (already in `hook-helpers.sh`) sees the new marker → returns 0 (approved) or 1 (rejected) → agent proceeds or escalates.
docs/decisions/autosend-approval-bridge-spec.md:102:Mapping `{ifos_payload_hash, cortextos_approval_id, tenant_slug, action_type, created_at, resolved_at}` lives in a small SQLite database at `${CTX_FRAMEWORK_ROOT}/autosend-bridge.db` OR (cleaner) a new Postgres table `autosend_approval_mappings`:
docs/decisions/autosend-approval-bridge-spec.md:105:CREATE TABLE IF NOT EXISTS autosend_approval_mappings (
docs/decisions/autosend-approval-bridge-spec.md:110:  action_type          TEXT NOT NULL,
docs/decisions/autosend-approval-bridge-spec.md:118:ALTER TABLE autosend_approval_mappings ENABLE ROW LEVEL SECURITY;
docs/decisions/autosend-approval-bridge-spec.md:119:CREATE POLICY tenant_isolation ON autosend_approval_mappings
docs/decisions/autosend-approval-bridge-spec.md:121:GRANT SELECT, INSERT, UPDATE ON autosend_approval_mappings TO ifos_app;
docs/decisions/autosend-approval-bridge-spec.md:128:`autosend_approval_mappings` becomes the 10th tenant-data table when the bridge implementation lands. The Week-9 bridge implementation slice MUST update `docs/architecture/tenancy-invariants.md` §1 and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` to include this table in T1-T3, T11, and audit coverage. This remediation corrects the spec only; the table does not exist yet, so the live invariant inventory remains the v0.2 nine-table set until the bridge migration ships.
docs/decisions/autosend-approval-bridge-spec.md:130:### §3.3 — IFOS action_type → cortextOS ApprovalCategory mapping
docs/decisions/autosend-approval-bridge-spec.md:132:cortextOS Primitive 4 enumerates approval categories as `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` per `packages/harness/cortextos/src/types/index.ts`. IFOS action_types from `agents/_shared/autosend-policy.yaml` map as follows:
docs/decisions/autosend-approval-bridge-spec.md:134:| IFOS action_type | cortextOS category |
docs/decisions/autosend-approval-bridge-spec.md:147:`bullhorn_placement_terminate` maps to `data-deletion` because placement termination destroys/closes a placement record; `other` remains only an explicit fallback for future action_types without a clean cortextOS category. The category is metadata for cortextOS's audit; IFOS-side semantics are preserved via the action_type field in our state table.
docs/decisions/autosend-approval-bridge-spec.md:171:`autosend_await_approval` already enforces 4h default timeout per action_type's `timeout` field in autosend-policy.yaml. If the timeout fires before operator responds:
docs/decisions/autosend-approval-bridge-spec.md:173:1. IFOS-side: poll loop exits → `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` → agent gives up
docs/decisions/autosend-approval-bridge-spec.md:185:| Postgres unreachable | Write bridge state to fallback JSONL at `/vault/_meta/autosend-bridge.jsonl`; same replay pattern as decision_log fallback |
docs/decisions/autosend-approval-bridge-spec.md:199:packages/autosend-approval-bridge/
docs/decisions/autosend-approval-bridge-spec.md:200:├── package.json              ← @ifos/autosend-approval-bridge; Node 20+
docs/decisions/autosend-approval-bridge-spec.md:208:│   ├── categoryMapper.ts     ← IFOS action_type → cortextOS ApprovalCategory
docs/decisions/autosend-approval-bridge-spec.md:226:Adding `autosend_approval_mappings` table requires:
docs/decisions/autosend-approval-bridge-spec.md:231:Total schema impact: 1 new table; tenancy-invariants.md grows from 12 to 13 invariants (T13: autosend_approval_mappings tenant_slug + RLS), or we count this as covered by T1-T3 already (cleaner).
docs/decisions/autosend-approval-bridge-spec.md:239:| A1 | Bridge process starts via PM2 + connects to Postgres + reads bridge state | `pm2 status ifos-autosend-bridge` shows online; bridge starts fresh on empty DB |
docs/decisions/autosend-approval-bridge-spec.md:245:| A7 | category mapping table covers all 10 v1.0 orange action_types | Lint test: every orange action_type in autosend-policy.yaml has a mapping entry |
docs/decisions/autosend-approval-bridge-spec.md:246:| A8 | Bridge state row in `autosend_approval_mappings` exists for every pending approval | Audit query: count(pending markers) == count(pending bridge state rows) |
docs/decisions/autosend-approval-bridge-spec.md:268:- **Building the IFOS-side `autosend_await_approval` polling loop** — already exists in `hook-helpers.sh` (Phase 3)
docs/decisions/autosend-approval-bridge-spec.md:285:| 6 | RLS on autosend_approval_mappings forgotten | Migration includes ENABLE ROW LEVEL SECURITY; tenancy audit T2 catches if missing |
docs/decisions/autosend-approval-bridge-spec.md:306:- Adds 1 tenant-data table (`autosend_approval_mappings`) → tenancy-invariants.md update OR considered covered by T1-T3 patterns
docs/decisions/autosend-approval-bridge-spec.md:307:- Adds 1 PM2-managed process (`ifos-autosend-bridge`) → ecosystem.config.js update
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:43:## §2 — Tier model
docs/decisions/autosend-safety-policy.md:45:Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:79:| Agent | action_type | Why green |
docs/decisions/autosend-safety-policy.md:90:| Agent | action_type | Sample rate | Why yellow |
docs/decisions/autosend-safety-policy.md:100:| Agent | action_type | Why orange |
docs/decisions/autosend-safety-policy.md:115:| action_type | block_reason | Why red |
docs/decisions/autosend-safety-policy.md:143:#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
docs/decisions/autosend-safety-policy.md:148:  local action_type="$1"
docs/decisions/autosend-safety-policy.md:159:  tier=$(autosend_policy_lookup "$action_type") || {
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:161:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
docs/decisions/autosend-safety-policy.md:166:  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:168:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:172:  # 3. Tier dispatch
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:178:    yellow)
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:180:      if autosend_should_sample "$action_type" "$tenant_slug"; then
docs/decisions/autosend-safety-policy.md:181:        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:187:      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
docs/decisions/autosend-safety-policy.md:189:      autosend_await_approval "$action_type" "$target" "$payload_hash"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
docs/decisions/autosend-safety-policy.md:219:action_types:
docs/decisions/autosend-safety-policy.md:222:  - bullhorn_note_draft_internal     # yellow (sample 1-in-10)
docs/decisions/autosend-safety-policy.md:229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
docs/decisions/autosend-safety-policy.md:239:**Tier:** orange
docs/decisions/autosend-safety-policy.md:245:  "action_type": "<enum from autosend-policy.yaml>",
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:259:2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:282:**Tier:** red
docs/decisions/autosend-safety-policy.md:288:  "action_type": "<enum>",
docs/decisions/autosend-safety-policy.md:300:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
docs/decisions/autosend-safety-policy.md:301:2. `autosend_escalate ESC_AUTOSEND_BLOCKED` notifies tenant operator informationally (no action required)
docs/decisions/autosend-safety-policy.md:304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
docs/decisions/autosend-safety-policy.md:320:**Tier:** fail-safe-red (treated as red)
docs/decisions/autosend-safety-policy.md:326:  "action_type": "<enum, may be unknown>",
docs/decisions/autosend-safety-policy.md:330:  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:339:2. `autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED` notifies tenant operator AND IFOS oncall
docs/decisions/autosend-safety-policy.md:341:4. Root cause + fix applied (e.g., add missing `action_type` to policy, repair table corruption, fix override format)
docs/decisions/autosend-safety-policy.md:352:| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
docs/decisions/autosend-safety-policy.md:353:| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:357:| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
docs/decisions/autosend-safety-policy.md:358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
docs/decisions/autosend-safety-policy.md:379:-- For autosend audit:
docs/decisions/autosend-safety-policy.md:380:--   phase = 'action'         when allowed (green/yellow/orange-approved)
docs/decisions/autosend-safety-policy.md:384:--     "tier": "green|yellow|orange|red|fail-safe-red",
docs/decisions/autosend-safety-policy.md:385:--     "action_type": "<enum>",
docs/decisions/autosend-safety-policy.md:394:--     "policy_version_sha": "<git SHA of autosend-policy.yaml at execution>"
docs/decisions/autosend-safety-policy.md:402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:430:  'autosend_policy',
docs/decisions/autosend-safety-policy.md:433:      "bullhorn_note_internal": "yellow",
docs/decisions/autosend-safety-policy.md:461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
docs/decisions/autosend-safety-policy.md:462:2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
docs/decisions/autosend-safety-policy.md:465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
docs/decisions/autosend-safety-policy.md:466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
docs/decisions/autosend-safety-policy.md:493:- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
docs/decisions/autosend-safety-policy.md:510:docs/decisions/autosend-safety-policy.md in the IFOS code repository)
docs/decisions/autosend-safety-policy.md:511:classifies each agent action into one of four tiers: green, yellow,
docs/decisions/autosend-safety-policy.md:522:  (b) any action classified as yellow that passed spot-check review or
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
docs/decisions/autosend-safety-policy.md:621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
docs/decisions/autosend-safety-policy.md:624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/architecture/cortexos-primitive-status.md:26:| 5 | Telegram + iOS approval surface | **shipped and tested** (Telegram); **aspirational** (iOS) | Every Tier-1 agent's escalation path |
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:66:**Risk if flaky:** Tier-1 always-on agents collapse to scheduled cron with cold-start latency, eliminating the "sub-second to first useful action" claim that justifies pricing the Triage/Concierge/Pulse demos above point-tool parity (Ultraplan §3.2). Per Ultraplan §3.1 row 1, the documented contingency is: "Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving." Quirk 2 (`.agents/learnings/00-cortextos-quirks.md`) — `node-pty` requires `npm rebuild` on Node 25+ — is the most likely re-trip wire because the Mac Studio cluster nodes for the v2.0 Sovereign tier may not run Node 22 LTS by default.
docs/architecture/cortexos-primitive-status.md:107:- `src/daemon/fast-checker.ts:899-1003` — `checkContextStatus()` polls `${stateDir}/context_status.json` written by the `hook-context-status` statusLine bridge. Three tiers: Tier 1 warning at `ctx_warning_threshold` default 70% injects `[CONTEXT] Window at X%`, Tier 2 handoff at `ctx_handoff_threshold` default 80% writes the handoff prompt and `.force-fresh` marker (line 996-1000), Tier 3 force-restart 5 minutes after Tier 2 if the agent didn't comply (line 962-967).
docs/architecture/cortexos-primitive-status.md:136:# 2. Context-percentage handoff (Tier 2)
docs/architecture/cortexos-primitive-status.md:146:# 3. Tier 3 force-restart (deadline)
docs/architecture/cortexos-primitive-status.md:147:# After Tier 2 fires, wait 5 minutes without acting; expect "Handoff deadline exceeded — force restarting"
docs/architecture/cortexos-primitive-status.md:150:# Trigger Tier 3 more than the threshold within 15 min; expect "Context circuit breaker reset after 30min pause"
docs/architecture/cortexos-primitive-status.md:259:**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.
docs/architecture/cortexos-primitive-status.md:292:**Master-brief description:** Bot per agent, `.env` carries `BOT_TOKEN / CHAT_ID / ALLOWED_USER`; the escalation path for every Tier-1 agent (master brief §2.4 row 5).
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:325:- Product Spec §6.1 row 5: "Telegram + iOS approval surface — every Tier 1 agent's escalation path."
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:135:| 1. Implementation simplicity | **Medium-High** | Ultraplan §8.1 line 541 estimate **L (2 weeks)**. Three accounting integrations (Xero / QuickBooks / Sage — one per tenant per Ultraplan §8.1 line 537). Open Banking auth complexity (90-day token rotation per Ultraplan §8.1 line 542 gotcha). Tier 1 always-on (cortextOS Primitive 1 dependency) |
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:165:| 3. Risk de-risking | **High (secondary)** | Second Tier-1 always-on agent (after Cash Conductor at W7-8) — provides Risk #1 secondary exercise. Exercises Bullhorn webhook coverage gaps per Ultraplan §8.1 line 569 verbatim ("Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks") |
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:194:- W7-8: Risk #1 (cortextOS Primitives 1+4+5) — Cash Conductor first Tier-1. Reduction trigger fires.
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:230:W6-9: Concierge (A6) — Risk #1 derisk via Tier-1 + Primitive 2 first exercise
docs/decisions/sequencing-target.md:240:1. **Concierge depends on Scribe** for Notes-for-context (per `bullhorn-integration-path.md` §4.1 row 4 — Concierge reads Notes Scribe wrote). Building Concierge at W6-9 before Scribe (W10) means Concierge's first-month operation has empty Note context. Materially degrades the Tier-1 always-on demo.
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:284:| 4 | W7-8 | **Cash Conductor** (A4) | Hire-#1-anchored per Ultraplan §9 line 766 verbatim ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7"); first Tier-1 (Risk #1 derisk) |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:66:| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:82:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:95:| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:99:| 6 | `docs/decisions/autosend-approval-bridge-spec.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:166:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:271:| 16 | `autosend-safety-policy.md` §10 pilot-agreement liability | Placeholder — legal review required before first pilot LOI | Pre-LOI legal review (commercial / regulatory). Codex can ratify the placeholder shape but cannot substitute for legal counsel. |
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:109:**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
docs/decisions/v1.0-kill-criterion.md:113:**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
docs/decisions/v1.0-kill-criterion.md:117:**Escalation path:** If three pilots experience this trigger within one quarter, escalate to system-wide PAUSE while structural autosend policy redesign happens (potential v1.1 advancement of orange tier).
docs/decisions/v1.0-kill-criterion.md:121:**Threshold:** Cost-per-completed-action (defined as: total IFOS infrastructure + API + Claude inference cost ÷ count of `decision_log` rows with `phase='action'` and `payload.tier IN ('green','yellow','orange-approved')`) exceeds **£0.50 per action** after 4 tenant-weeks of operation.
docs/decisions/v1.0-kill-criterion.md:188:**Threshold:** ANY confirmed incident in which agent action results in PII (personally-identifiable information per UK GDPR Art. 4(1)) transmitted to an unauthorised party (cross-tenant recipient, unauthorised external recipient, or recipient outside tenant's declared data residency) AND not blocked by the RLS + autosend policy combination.
docs/decisions/v1.0-kill-criterion.md:196:**Action:** KILL. Rationale: multi-tenant trust is the structural foundation of v1.0. A single confirmed PII breach beyond the RLS + autosend boundary indicates the foundation is unsound. Continuing operation risks (a) further breaches, (b) regulatory action, (c) catastrophic loss of pilot trust. Wind-down protects existing pilots from further exposure.
docs/decisions/v1.0-kill-criterion.md:235:**Must-fill before first pilot LOI signs.** The pilot agreement may reference an external advisor for dispute resolution per `autosend-safety-policy.md` §10 placeholder language. Founder identifies and engages within Weeks 1-2.
docs/decisions/v1.0-kill-criterion.md:337:- The autosend safety policy per this Day 5 commit (green + red tiers only)
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/decisions/v1.0-kill-criterion.md:387:**For atomic-correction manifest.** Edit 10 (shared with autosend-safety-policy.md) adds the path drift correction. Manifest grows from 9 to 10.
docs/build-brief/00-MASTER-BRIEF.md:477:- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
docs/build-brief/00-MASTER-BRIEF.md:600:| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
docs/build-brief/00-MASTER-BRIEF.md:843:| 1 | CortexOS primitives 3 or 4 are flaky in production | Daily orchestrator health check flags > 1 incident/week | Every Tier-1 agent has a degraded-mode fallback (drafts-only, scheduled retry) that runs if cortextOS state is unhealthy; manual file-bus handoff documented |
docs/architecture/vault-concurrency.md:397:**Status update 2026-05-20 (Day 8 Codex Round 1):** all 5 codes below are now catalogued at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`, Phase 1 of Week-1 slice) AND wired into the `autosend_escalate` helper at `agents/_shared/hook-helpers.sh` (commit `e6e9df1`, Phase 3 of Week-1 slice). The "_shared/hook-helpers.sh Week-1 prereq must wire these 5 codes" language below has been satisfied — current state is shipped + tested.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/architecture/second-brain-design.md:895:| **Failure mode if cortextOS daemon is unhealthy** | Wrappers don't depend on the daemon — they exec directly into Node. As long as Postgres is up and the filesystem is mounted, wiki ops succeed. Decision_log writes still go through (Postgres direct). Tracks per Ultraplan §3.5 "Tier 1 agents have degraded-mode fallbacks" — the wiki is part of the fallback substrate, not part of what fails. | If `ifos-wiki-mcp` crashes, every agent loses wiki access until it restarts. PM2 auto-restart bounds the outage to ~5s, but during the outage every wiki call fails. If `cortextos-daemon` is unhealthy, MCP connections from agents (which are in PTYs supervised by the daemon) may also be affected. Two-process dependency. | Same as α (library invoked directly, no daemon dependency) but adds skill-discovery path: if the agent's Claude Code session can't find the skill (e.g. corrupted scaffold), all wiki ops fail. |
docs/architecture/second-brain-design.md:975:| **2.6** | Master brief §5 silent on concurrency | No mechanism for agent×agent, agent×human-in-Obsidian, or rewrite-backlinks cascade | Resolved in §2.6.1, §2.6.2, §2.6.3 of this design. Companion document `docs/architecture/vault-concurrency.md` LANDED (Day 3, commit `78680cc`). New escalation codes (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, `ESC_VAULT_RENAME_RACE`) CATALOGUED at `agents/_shared/escalation-codes.md` §2.2 (Day 8 commit `a279226`) + WIRED into `agents/_shared/hook-helpers.sh::autosend_escalate` (Day 8 commit `e6e9df1`). | **Closed 2026-05-20.** Catalogue + wiring complete; ESC codes callable from any rendered agent. |
docs/specs/ULTRAPLAN.md:107:- Every Tier 1 agent has a "degraded mode" fallback (drafts-only, no auto-send, scheduled retry) that runs if CortexOS state is unhealthy.
docs/specs/ULTRAPLAN.md:267:**Tier change** (e.g., Boutique → Growth):
docs/specs/ULTRAPLAN.md:473:Always-on? (Tier 1 / Tier 2)
docs/specs/ULTRAPLAN.md:504:- **Always-on?** Tier 2 — scheduled nightly cron
docs/specs/ULTRAPLAN.md:518:- **Always-on?** Tier 2 — webhook-driven
docs/specs/ULTRAPLAN.md:532:- **Always-on?** Tier 1 — persistent watcher on accounting + bank webhooks
docs/specs/ULTRAPLAN.md:546:- **Always-on?** Tier 2 — request-response
docs/specs/ULTRAPLAN.md:560:- **Always-on?** Tier 1 — persistent state across the candidate lifecycle
docs/specs/ULTRAPLAN.md:576:- **Always-on?** Tier 1 — the highest 24/7 agent
docs/specs/ULTRAPLAN.md:590:- **Always-on?** Tier 1
docs/specs/ULTRAPLAN.md:608:- **Always-on?** Tier 1
docs/specs/ULTRAPLAN.md:622:- **Always-on?** Tier 1 — overnight autoresearch is the canonical use case
docs/specs/ULTRAPLAN.md:636:- **Always-on?** Tier 1
docs/specs/ULTRAPLAN.md:650:- **Always-on?** Tier 1
docs/specs/_archive-build-handoff.md:382:| 6 | **Concierge** | 10–13 | Bullhorn + Microsoft Graph + AgentMail | First Tier 1 always-on closing demo; 4-week build |
docs/runbooks/operational-hygiene-protocol.md:26:- **Length discipline C+** — Day 5 autosend policy 658 lines vs 300-500 estimate; Day 6 vertical schema 899 lines vs same estimate
docs/runbooks/operational-hygiene-protocol.md:27:- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
docs/runbooks/operational-hygiene-protocol.md:150:- Day 5 autosend policy: estimated 300-500 lines; actual 648. **+30% to +116% overshoot.**
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:202:3. **Numerical claims:** count. "29 action_types" not "30+". "10 entity_links" not "~10". If counting is hard, write the counting query (grep, wc -l, SQL) and run it.
docs/runbooks/operational-hygiene-protocol.md:217:grep -nE "\b[0-9]+ (entities|fields|action_types|relationships|triggers|tiers|sections|edits|items)" <artefact>
docs/runbooks/operational-hygiene-protocol.md:224:- "30+ action_types" → forbidden. Count: 29. Write "29 action_types".
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:275:| `docs/decisions/autosend-safety-policy.md` | 1 | Same cost-target replacement for the cyber-insurance budget reference |
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/runbooks/operational-hygiene-protocol.md:288:### §7.3 — Finding: Day-6 "30+ action_types" inflation (caught in founder review)
docs/runbooks/operational-hygiene-protocol.md:290:Day-6 structural summary claimed "30+ action_types across 6 v1.0 agents" in autosend policy §3. Actual count: 29 (Green 6 + Yellow 5 + Orange 10 + Red 8). The artefact itself does not make this claim — only my summary message did.
docs/specs/PRODUCT-SPEC.md:39:Eight Tier 1 agents are genuinely always-on and structurally need CortexOS primitives. The rest are scheduled, batch, or webhook-driven and live inside the same runtime to share infrastructure but are not marketed as 24/7. This is the structural integrity rule that keeps the product credible with FD-level buyers.
docs/specs/PRODUCT-SPEC.md:47:| Product line | What it serves | Number of agents | Tier range |
docs/specs/PRODUCT-SPEC.md:60:- **Always-on?** — Tier 1 (CortexOS-required) vs Tier 2 (scheduled / batch)
docs/specs/PRODUCT-SPEC.md:61:- **Tier availability** — which subscription tier unlocks it
docs/specs/PRODUCT-SPEC.md:69:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:70:- **Tier availability:** Solo (drafts-only, no auto-send) / Boutique+ (full auto-send).
docs/specs/PRODUCT-SPEC.md:78:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:79:- **Tier availability:** Boutique+.
docs/specs/PRODUCT-SPEC.md:88:- **Always-on?** Digest is Tier 2 (cron). Competitor Interception is Tier 1.
docs/specs/PRODUCT-SPEC.md:89:- **Tier availability:** Boutique (digest) / Growth+ (Competitor Interception).
docs/specs/PRODUCT-SPEC.md:97:- **Always-on?** Tier 1 (overnight autoresearch is the canonical use case).
docs/specs/PRODUCT-SPEC.md:98:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:106:- **Always-on?** Tier 2 (request-response).
docs/specs/PRODUCT-SPEC.md:107:- **Tier availability:** Boutique+.
docs/specs/PRODUCT-SPEC.md:115:- **Always-on?** Tier 2 (webhook-driven).
docs/specs/PRODUCT-SPEC.md:116:- **Tier availability:** All tiers including Solo. This is the data spine.
docs/specs/PRODUCT-SPEC.md:124:- **Always-on?** Tier 1 (downstream handoff target from Triage; needs persistent state across the candidate lifecycle).
docs/specs/PRODUCT-SPEC.md:125:- **Tier availability:** Boutique+.
docs/specs/PRODUCT-SPEC.md:133:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:134:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:142:- **Always-on?** Tier 2 (scheduled nightly batch).
docs/specs/PRODUCT-SPEC.md:143:- **Tier availability:** Solo+ (with one-off £1,500 setup-cleanup fee on Starter/Growth, waived on Scale).
docs/specs/PRODUCT-SPEC.md:151:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:152:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:160:- **Always-on?** Tier 2 (scheduled weekly batch).
docs/specs/PRODUCT-SPEC.md:161:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:169:- **Always-on?** Tier 2 (scheduled monthly cron).
docs/specs/PRODUCT-SPEC.md:170:- **Tier availability:** Growth+.
docs/specs/PRODUCT-SPEC.md:177:- **Always-on?** Tier 2 (request-driven; runs on demand).
docs/specs/PRODUCT-SPEC.md:178:- **Tier availability:** Free pre-sales tool for prospects; not on the customer pricing card.
docs/specs/PRODUCT-SPEC.md:189:- **Always-on?** Tier 2.
docs/specs/PRODUCT-SPEC.md:190:- **Tier availability:** Compliance + Operations and above.
docs/specs/PRODUCT-SPEC.md:197:- **Always-on?** Tier 1 (off-hours work is the entire arbitrage).
docs/specs/PRODUCT-SPEC.md:198:- **Tier availability:** Compliance + Operations and above.
docs/specs/PRODUCT-SPEC.md:205:- **Always-on?** Tier 1.
docs/specs/PRODUCT-SPEC.md:206:- **Tier availability:** Compliance Core (T5 only) doesn't include T3. Compliance + Operations and above includes it.
docs/specs/PRODUCT-SPEC.md:213:- **Always-on?** Tier 2 (scheduled per contract event).
docs/specs/PRODUCT-SPEC.md:214:- **Tier availability:** Full Temp Sub-Platform.
docs/specs/PRODUCT-SPEC.md:221:- **Always-on?** Tier 1 (continuous monitoring).
docs/specs/PRODUCT-SPEC.md:222:- **Tier availability:** Compliance Core (sold standalone) and Full Temp.
docs/specs/PRODUCT-SPEC.md:229:- **Always-on?** Tier 2.
docs/specs/PRODUCT-SPEC.md:230:- **Tier availability:** Full Temp.
docs/specs/PRODUCT-SPEC.md:240:| Tier | Monthly | Agents included | The single ROI promise |
docs/specs/PRODUCT-SPEC.md:249:| Tier | Monthly | Agents included | The single ROI promise |
docs/specs/PRODUCT-SPEC.md:374:- **Per-customer compute cost: ~£200/month for full Tier 1 deployment** (per the CortexOS directive's unit-economics work). At Boutique £1,495/mo this is 13% COGS; at Growth £3,250/mo this is 6%; healthy at every tier above Solo's three-agent gate.
docs/specs/PRODUCT-SPEC.md:392:### 6.1 The seven CortexOS primitives every Tier 1 agent uses
docs/specs/PRODUCT-SPEC.md:402:| 5 | Telegram + iOS approval surface | Every Tier 1 agent's escalation path |
packages/harness/cortextos/templates/agent-codex/AGENTS.md:105:| Tier | When | What you see | What you do |
packages/harness/cortextos/templates/agent-codex/AGENTS.md:107:| Tier 1 — warning | usage ≥ `ctx_warning_threshold` (default 70%) | Injected line: `[CONTEXT] Window at NN%. Handoff triggers at HH%.` | Wrap up the current sub-task; avoid starting large new work. No restart yet. |
packages/harness/cortextos/templates/agent-codex/AGENTS.md:108:| Tier 2 — handoff | usage ≥ `ctx_handoff_threshold` (default 80%) | Injected line: `[CONTEXT HANDOFF REQUIRED] Context is at NN%. Write a handoff document to memory/handoffs/handoff-<ts>.md ...` followed by an absolute target path | Write the handoff doc to that exact path with the five required sections (`## Current Tasks`, `## Next Actions`, `## Active Crons`, `## Key Context`, `## Files Modified This Session`), then run `cortextos bus hard-restart --reason "context handoff at NN%" --handoff-doc <absolute path>`. Do NOT skip writing the doc. |
packages/harness/cortextos/templates/agent-codex/AGENTS.md:109:| Tier 3 — force restart | 5 min after Tier 2 fires with no `hard-restart` call | Daemon force-kills the session and brings a fresh one up | Nothing — the daemon already acted. On the next session start, you will resume via the handoff doc the daemon attached. |
packages/harness/cortextos/templates/agent-codex/AGENTS.md:113:1. The fresh session's first injected message contains the absolute path to the handoff doc you wrote (or a daemon-attached one for Tier 3).
packages/harness/cortextos/templates/agent-codex/AGENTS.md:121:- Set `ctx_handoff_threshold` to `undefined` thinking it disables monitoring; that puts the daemon into observe-only mode, which means no Tier 2/3 actions will fire — you will OOM.
docs/runbooks/tenant-lifecycle.md:153:| Spot-check operator review | `autosend_spot_check_enqueue` writes to `/vault/<slug>/spot-checks/<file>.md`; operator reviews + flags as approved/rejected/escalate | (No invariant violation) |
docs/runbooks/pii-purge-operational-pattern.md:113:| `action_type` | populated | populated (preserved) |
docs/runbooks/pii-purge-operational-pattern.md:159:| Disk full during audit row write | UPDATE succeeds; audit row write fails; orphaned purge | Decision_log fallback to JSONL at `/var/log/ifos/decision-log.jsonl`; replay via autosend-syncer when disk recovers |
docs/_supplementary/build-plan-original.md:200:- **Tier 1 (always present)** — `CLAUDE.md` (4KB max). Client name, industry, voice summary, key people, brand do/don'ts. This is the brain stem.
docs/_supplementary/build-plan-original.md:201:- **Tier 2 (task-specific, retrieved)** — for a Proposal Builder session, pull 3 past winning proposals semantically similar to this prospect's industry and deal size. Retrieved via pgvector query against the vault.
docs/_supplementary/build-plan-original.md:202:- **Tier 3 (explicit, linked)** — if the triggering event references specific documents (e.g., "draft proposal for the deal at HubSpot deal-id 12345"), pull that deal's full history.
docs/_supplementary/build-plan-original.md:223:- Tier 1: ~1,500 tokens
docs/_supplementary/build-plan-original.md:224:- Tier 2: ~3,000 tokens (5 notes × 600 tokens avg)
docs/_supplementary/build-plan-original.md:225:- Tier 3: ~5,000 tokens when triggered
docs/_supplementary/build-plan-original.md:228:Total context per invocation: 10–25k tokens typical. With prompt caching on the Tier 1 + Tier 2 stuff that's shared across invocations, effective cost is ~10% of input rate. This is how the £80–180/mo per tenant cost target holds.
docs/_supplementary/build-plan-original.md:290:- **Kaspr API** — LinkedIn-sourced mobile numbers (Tier 2+ only; not cheap enough for Tier 1)
docs/_supplementary/build-plan-original.md:514:- Have had no activity for >7 days (Tier 1 clients) or >3 days (aggressive pipelines)
docs/_supplementary/build-plan-original.md:590:**Sonnet 4.6** baseline. Opus 4.7 for Tier 2+ clients whose voice is highly distinctive or technical.
docs/_supplementary/build-plan-original.md:977:- **Ahrefs / SEMrush API** (paid, passed through to client — OR build against free DataForSEO tier for Tier 1)
docs/_supplementary/technical-strategy-v2.md:463:Tier 0 — Founding customers (first 5)                     £2.5k setup · £800/mo
docs/_supplementary/technical-strategy-v2.md:466:Tier 1 — SME direct                                       £3–7.5k · £800–2k/mo
docs/_supplementary/technical-strategy-v2.md:471:Tier 2 — Operator direct (highest-ROI ICP)                £5–15k · £1.5–3k/mo
docs/_supplementary/technical-strategy-v2.md:476:Tier 3 — Agency Partner (the distribution lever)          £15k · £5k/mo + seats
docs/_supplementary/technical-strategy-v2.md:480:Tier 4 — Enterprise                                       £50k+ · £5k+/mo
docs/_supplementary/technical-strategy-v2.md:489:Sell Tier 1 for volume. Sell Tier 2 for fit. Sell Tier 3 for leverage. Sell Tier 4 for the brand.
docs/_supplementary/technical-strategy-v2.md:590:6. **ICP expansion:** agencies and course sellers are added as Tier 2. Agency Partner white-label becomes the Tier 3 distribution lever.
docs/_supplementary/strategic-plan.md:34:**Tier 1 — Core SME (priced £3–8k setup + £500–£2,000/mo retainer):**
docs/_supplementary/strategic-plan.md:41:**Tier 2 — Specialist vertical (priced £8–20k setup + £2k–5k/mo):**
docs/_supplementary/strategic-plan.md:48:**Tier 3 — Enterprise (priced £50k–250k setup + £5k–20k/mo):**
docs/_supplementary/strategic-plan.md:194:For a typical Tier 1 SME client running the nine agents:
docs/_supplementary/strategic-plan.md:203:| **Retainer (Tier 1)** | **£800–£2,000/mo** |
docs/_supplementary/strategic-plan.md:404:| Tier | Setup | Monthly | What's included |

codex
The first pass shows the expected master brief and ULTRAPLAN filenames differ in this repo, so I’m locating the canonical files and checking the exact line anchors from there.
exec
/bin/zsh -lc "sed -n '60,112p' agents/_shared/autosend-policy.yaml" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "sed -n '90,190p' agents/_shared/escalation-codes.md" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `partial_progress_count`, `total_refs_count`

### 2.3 — Bullhorn integration (1 code)
Source: `docs/decisions/bullhorn-integration-path.md` §4.5 + §6

#### `ESC_BULLHORN_AUTH`
- **Severity:** **blocking** — agent enters degraded mode (drafts-only, no auto-send)
- **Trigger:** Bullhorn OAuth token refresh failed twice on the per-agent 8-minute cycle (per `common-ats.json.auth_refresh_interval_seconds`); or REST call returned 401 indefinitely (revoked token in Bullhorn admin UI)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
- **Payload fields:** `failure_type` (one of `refresh_failed`, `revoked_401`), `last_attempt_at`, `consecutive_failures`
- **Recovery:** agent stays in degraded mode until founder rotates token via Bullhorn admin → next `_secrets.env` reload picks up new token

### 2.4 — Renderer (1 code)
Source: `docs/architecture/agent-bundle-renderer-design.md` §4

#### `ESC_RENDERER_FAILED`
- **Severity:** blocking — render did not produce a runnable agent dir
- **Trigger:** Renderer exited non-zero. Mid-render atomic-rename per ADR-003 §3.3.4 means the prior agent dir at target is preserved (`.prev.<timestamp>/`) — no half-rendered state visible to daemon discovery
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`; CC `ifos_oncall_chat_id` only on `atomic-rename-failed` (infrastructure failure, not author error)
- **Agent name:** `_renderer` (sentinel; not a real agent)
- **Payload fields:** `reason` (one of `schema-validation-failure`, `bundle-malformed`, `shared-helpers-missing`, `tenant-not-provisioned`, `atomic-rename-failed`, `non-rendered-target`), `agent_name_attempted`, `tenant_slug_attempted`
- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7

### 2.5 — Recruitment-domain vocabulary (8 codes)
Source: master brief §8.1 Change 3 lines 585-592

#### `ESC_VOICE_DRIFT`
- **Severity:** warn
- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `final_classifier_score`, `retry_count`, `agent_name`, `task_summary`

#### `ESC_DUPLICATE_DETECTED`
- **Severity:** warn — Janitor dedup needs human approval
- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
- **Phase:** `action`
- **Routing:** `operator_chat_id` via Telegram approval gate
- **Payload fields:** `candidate_a_id`, `candidate_b_id`, `confidence_score`, `match_basis` (e.g. `email+phone`, `name+email`, `phone+linkedin`)

#### `ESC_JSL_RED_FLAG`
- **Severity:** warn — Supply Chain Auditor (placeholder for v1.1+ JSL extension)
- **Trigger:** Supply Chain Auditor detected red flag (v1.0 placeholder; SCA agent in v1.1 backlog)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Status:** v1.0 placeholder; no agent fires this yet. Reserved name.

#### `ESC_BRIEF_AMBIGUITY`
- **Severity:** warn — Brief Decoder cannot confidently shortlist
- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
- **Phase:** `agent_handoff`
- **Routing:** `operator_chat_id`
- **Payload fields:** `brief_id`, `ambiguity_dimensions` (list of {`field`, `confidence`}), `proposed_clarifying_questions`

#### `ESC_PII_LEAKAGE_RISK`
- **Severity:** **blocking** — agent halts immediately, no retry
- **Trigger:** Agent output references PII outside the firm boundary (cross-tenant PII detected by `validate.sh` Gate A or RLS check)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — potential GDPR incident
- **Payload fields:** `detected_pii_type` (one of `email`, `phone`, `name`, `address`, `nin`, `passport`), `boundary_violated` (the tenant_slug whose data leaked), `output_snippet_redacted_hash`
- **Recovery:** Agent restart required after operator review; founder must determine whether DPO notification is needed per UK GDPR Art. 33

#### `ESC_RATE_LIMIT_HIT`
- **Severity:** warn
- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `upstream` (e.g. `bullhorn`, `linkedin`, `reed`, `cv-library`), `retry_after_seconds`, `consecutive_429s`

#### `ESC_SCHEMA_VIOLATION`
- **Severity:** warn
- **Trigger:** Agent produced output violating vertical-schema.yaml field constraints (e.g. wrote an unknown enum value, missing required field). Detected at write-time by adapter validation
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `entity_type` (from vertical-schema.yaml entities), `field_violated`, `value_attempted`, `constraint_failed`

#### `ESC_VOICE_DRIFT_TENANT`
- **Severity:** warn (info-level — single-tenant pattern, not just one drift event)
- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (CSM may need to retrain voice corpus)
- **Payload fields:** `tenant_slug`, `drift_event_count`, `window_days`, `affected_agents` (list of agent_name)

#### `ESC_INPUT_VALIDATION_FAIL`
- **Severity:** warn
- **Trigger:** Agent rejected its input at the validation gate (e.g. malformed firm name, missing required CLI argument, brief description too short). Detected at Step 1 of the agent's workflow BEFORE any tool calls or LLM invocations
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `input_field`, `input_value_preview` (truncated to 80 chars), `validation_rule_violated`

#### `ESC_AGENT_OUTPUT_SHAPE`
- **Severity:** warn
- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `agent_name`, `output_path`, `shape_rule_violated`, `expected_value`, `actual_value`


 succeeded in 0ms:
    tier: green
    agent: concierge
    reason: "Read of inbound brief; idempotent; no comms"
    irreversible: false

  # ───────────────────────────────────────────────────────────
  # YELLOW — auto-send with 1-in-N spot-check (5 action_types)
  # ───────────────────────────────────────────────────────────

  bullhorn_candidate_dedupe:
    tier: yellow
    agent: janitor
    sample_rate: 10
    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
    irreversible: false

  bullhorn_note_append_summary:
    tier: yellow
    agent: scribe
    sample_rate: 20
    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
    irreversible: false

  linkedin_connection_request:
    tier: yellow
    agent: sourcing-scout
    sample_rate: 5
    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
    irreversible: true

  xero_reminder_draft_internal:
    tier: yellow
    agent: cash-conductor
    sample_rate: 10
    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
    irreversible: false

  bullhorn_note_draft_internal:
    tier: yellow
    agent: concierge
    sample_rate: 10
    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
    irreversible: false

  # ───────────────────────────────────────────────────────────
  # ORANGE — per-action human approval (10 action_types)
  # ───────────────────────────────────────────────────────────

  bullhorn_note_customer_visible:
    tier: orange
    agent: concierge
    timeout: PT4H
    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"

exec
/bin/zsh -lc 'rg -n "hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits" agents/_shared/voice-loader.sh' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
15:#   hh_load_recent_edits   — query recent_edit for last N days
73:# hh_load_tone_rules [<agent_name>]
79:hh_load_tone_rules() {
135:# hh_load_voice_samples <task_context> [<top_k>]
151:hh_load_voice_samples() {
223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
233:hh_load_recent_edits() {

exec
/bin/zsh -lc "rg --files | rg 'master|MASTER|brief|ULTRA|ultra|plan'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/harness/cortextos/src/hooks/hook-planmode-telegram.ts
packages/harness/cortextos/bus/hook-planmode-telegram.sh
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/ULTRAPLAN.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/execution-plan.md
docs/operations/codex-ratification-execution-plan.md
packages/harness/cortextos/community/skills/local-ultrareview/SKILL.md
legacy/v1/MASTER-INDEX.md
legacy/v1/docs/phase-0-strategic/intelforce-ai-os-strategic-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-build-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-execution-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md
legacy/v1/apps/dashboard/components/wizard/steps/step2-plan.tsx
legacy/v1/docs/phase-5-business-legal/marketing/trademark-filing-brief.md

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '515,528p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '585,605p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   585	- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
   586	- `ESC_RATE_LIMIT_HIT` — upstream API rate-limited (esp. LinkedIn)
   587	- `ESC_SCHEMA_VIOLATION` — agent produced output violating vertical schema
   588	
   589	Build the catalogue in Week 0. New codes only when production demands one.
   590	
   591	### 8.2 The build order — v1.0 only
   592	
   593	| # | Agent | Weeks | Key dependency | Why this order |
   594	|---|---|---|---|---|
   595	| 1 | Diagnostic | 3–4 | LinkedIn + Companies House + scrape | Sales tool — needed before any other agent matters |
   596	| 2 | Janitor | 5 | Bullhorn MCP (R+W) | First demoable inside-ATS result; day-30 before/after closes deals |
   597	| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
   598	| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
   599	| 5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | First daytime always-on agent |
   600	| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
   601	
   602	After Concierge ships, week 14 milestone: first pilot converts to paid.
   603	
   604	**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
   605	

 succeeded in 0ms:
   515	#### A3. The Scribe — the data spine
   516	
   517	- **Build wave:** v1.0 (week 6–7)
   518	- **Always-on?** Tier 2 — webhook-driven
   519	- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
   520	- **CortexOS primitives required:** None per call (stateless between calls)
   521	- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
   522	- **Shared modules required:** Voice loader (for tone-detection of tacit notes), decision log writer
   523	- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
   524	- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
   525	- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
   526	- **Build complexity:** **M** (1 week) — the structured field mapping is per-firm config, not code
   527	- **Gotchas:** Tacit-note extraction is the hard part. Start with a small taxonomy (5–10 tacit-note types) and expand. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   528	

exec
/bin/zsh -lc 'rg -n "bullhorn_scribe|note_append_summary|scribe" agents/_shared/autosend-policy.yaml docs/decisions/autosend-safety-policy.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:43:    agent: scribe
agents/_shared/autosend-policy.yaml:76:  bullhorn_note_append_summary:
agents/_shared/autosend-policy.yaml:78:    agent: scribe
agents/_shared/autosend-policy.yaml:139:    agent: scribe
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/autosend-safety-policy.md:494:- **Per-recipient reputation:** recipients with high engagement may be in implicit "always-orange" zone; recipients with prior unsubscribes may be elevated to red.

exec
/bin/zsh -lc 'rg -n "current_role|notice_period|salary_expectation|work_style|key_skills_summary|decision_authority_level|prefers_comms_via|next_meeting_target|budget_range|deadline_date|must_haves|nice_to_haves|deal_breakers|decision_committee|week_1_status|blockers|satisfaction_signal|headcount_growth_signal|hiring_velocity|decision_window" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:104:      current_role:
docs/verticals/recruitment/vertical-schema.yaml:116:      salary_expectation_min:
docs/verticals/recruitment/vertical-schema.yaml:120:      salary_expectation_max:
docs/verticals/recruitment/vertical-schema.yaml:133:      notice_period_weeks:

exec
/bin/zsh -lc "sed -n '1,170p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
# IFOS recruitment vertical schema v0.1
# ============================================================================
# Layered above the Day-4 generic primitives:
#   - entities (id, tenant_slug, entity_type, entity_id, data JSONB, version, ...)
#   - entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
#   - decision_log (..., agent_name, phase, payload JSONB, ...)
# This file specifies the recruitment-domain entity_type + link_type slugs
# and the JSON Schema shape of entities.data per entity_type.
#
# Source: master brief §6 Day 6 line 490 (8 core entities)
#       + bullhorn-integration-path.md §4.1 (per-agent endpoint requirements)
#       + autosend-safety-policy.md §3 (action_type references)
#       + Day-4 runbook §6.3 (canonical Postgres schema)
#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
# ============================================================================

vertical: recruitment
version: v0.1
status: Proposed
date: 2026-05-18
author: founder (Maddox), Day-6 draft via Claude Code
codex_ratification_queue_position: 18

non_goals:
  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.

# ============================================================================
# §1 — Entity definitions
# ============================================================================
# Each entity below specifies:
#   - description: 1-2 sentence definition in the IFOS canonical vocabulary
#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
#   - notes: anything entity-specific worth flagging
#
# Field types follow JSON Schema conventions: type = string | integer | number | boolean | array | object | (ISO 8601) timestamp / date
# `required: true` means the entity cannot be persisted without this field set; `required: false` means nullable.
# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
# ============================================================================

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

exec
/bin/zsh -lc 'rg -n "''^  (candidate|contractor|contact|brief|opportunity|placement):|''^  [a-z_]+:" docs/verticals/recruitment/vertical-schema.yaml | head -n 80' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
48:  candidate:
153:  contractor:
221:  client:
283:  contact:
341:  brief:
429:  placement:
495:  opportunity:
535:  timesheet:
585:  candidate_placed_in_role:
594:  placement_for_brief:
601:  brief_from_client:
608:  brief_decision_maker:
618:  contact_works_for_client:
625:  candidate_engaged_with_contact:
632:  candidate_referred_by_contact:
639:  opportunity_for_brief:
647:  opportunity_about_candidate:
654:  timesheet_for_placement:
741:  candidate:
747:  contractor:
754:  client:
760:  contact:
765:  brief:
771:  placement:
777:  opportunity:
783:  timesheet:

exec
/bin/zsh -lc "sed -n '120,155p' agents/_shared/autosend-policy.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    reason: "Outbound email to candidate; customer-facing; reputation effects"
    irreversible: true

  twilio_sms_send:
    tier: orange
    agent: concierge
    timeout: PT30M
    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
    irreversible: true

  calendar_invite_send:
    tier: orange
    agent: concierge
    timeout: PT4H
    reason: "Creates calendar event with attendee notification; visible to attendee"
    irreversible: true

  email_summary_to_customer:
    tier: orange
    agent: scribe
    timeout: PT4H
    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
    irreversible: true

  xero_reminder_send_customer:
    tier: orange
    agent: cash-conductor
    timeout: PT24H
    reason: "Outbound payment reminder to customer; reputation + collection risk"
    irreversible: true

  diagnostic_email_send:
    tier: orange
    agent: diagnostic
    timeout: PT4H
    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_WRITE_FAIL|ESC_PROVIDER_FETCH_FAIL|ESC_FIELD_EXTRACTION_LOW_CONFIDENCE|ESC_SCRIBE_SLA_MISS|ESC_AUTOSEND_YELLOW_SPOT_CHECK|ESC_BULLHORN_OAUTH_REVOKED" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
codex
I’ve found several concrete mismatches already: some action types and escalation codes named by the draft are not in the shared catalogues, and the schema does not contain a number of the claimed canonical fields. I’m checking whether the saved artefact matches the provided text so I can cite stable lines.
exec
/bin/zsh -lc "sed -n '283,420p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '260,430p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
   261	- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT` (separate from per-run drift).
   262	
   263	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   264	
   265	---
   266	
   267	## §8 — Build dependencies (W6 prerequisites)
   268	
   269	Scribe build cannot start until ALL of the following are confirmed:
   270	
   271	| Dependency | Source | Status |
   272	|---|---|---|
   273	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   274	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   275	| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
   276	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   277	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   278	| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
   279	| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
   280	| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
   281	| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
   282	| Per-tenant call-routing config (which provider) | Tenant onboarding | ⏸ |
   283	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   284	| Tacit-note taxonomy v0.1 (8 categories) finalised | Founder review with first pilot | ⏸ |
   285	| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
   286	| `context.sh` hydration | Build at W6 start (~0.5 day) | ⏸ |
   287	| `cycle.sh` orchestration (10-step) | Build at W6 start (~2 days) | ⏸ |
   288	| 3 fixtures with golden outputs | Build at W6 start (~1 day) | ⏸ |
   289	| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |
   290	
   291	**Until ALL ⏸ items resolve to ✅, W6 build slice does not start.**
   292	
   293	---
   294	
   295	## §9 — Status + open questions
   296	
   297	**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
   298	
   299	### Open questions for founder review
   300	
   301	| # | Question | Resolution path |
   302	|---|---|---|
   303	| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
   304	| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
   305	| Q3 | Tacit-note taxonomy v0.1 — 8 categories proposed in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
   306	| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
   307	| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH. Could leave entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
   308	| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
   309	| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
   310	
   311	### Gotchas (carried forward from ULTRAPLAN A3 line 527)
   312	
   313	1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   314	2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
   315	3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.
   316	
   317	---
   318	
   319	## §10 — When this document ratifies
   320	
   321	Per `.codex/ratification/review-architecture-decision.md` skill: this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   322	
   323	Status flips Proposed → Accepted when:
   324	- Codex Round 4 Phase 2 ratifies
   325	- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
   326	- Q2 cost model approved with budget cap
   327	
   328	Status flips Accepted → In Force when:
   329	- W6 build slice produces all 5 sibling bundle files + 3 fixtures
   330	- First production transcript processed end-to-end against migration-test tenant
   331	- SLA + edit-rate Gate-B metrics measurable
   332	- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
   333	
   334	Until then: this document is a forward-looking scaffold.
   335	
   336	*End of Scribe agent.md draft.*

 succeeded in 0ms:
     1	# Scribe — the data spine
     2	
     3	**Status:** Proposed (Day-17 pre-W6-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice).
     4	**Date:** 2026-05-24.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
     7	**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
     8	**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
     9	
    10	---
    11	
    12	## §1 — Output contract (one-paragraph screenshot)
    13	
    14	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    15	
    16	> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown attachment containing the consultant's "things I'd write down but there's no field for" observations. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
    17	
    18	---
    19	
    20	## §2 — Invocation surface
    21	
    22	### Webhook (v1.0 primary path)
    23	
    24	```http
    25	POST https://<tenant>.ifos.app/agents/scribe/webhook
    26	Authorization: Bearer <fathom-or-fireflies-shared-secret>
    27	Content-Type: application/json
    28	
    29	{
    30	  "provider": "fathom" | "fireflies" | "ringover",
    31	  "call_id": "<provider-call-id>",
    32	  "transcript_url": "<provider-transcript-url>",
    33	  "duration_seconds": 1234,
    34	  "participants": [...],
    35	  "metadata": {...}
    36	}
    37	```
    38	
    39	Each provider has its own webhook signature scheme (Fathom HMAC-SHA256; Fireflies bearer token; Ringover OAuth-protected). Auth handled per-provider in `tools.yaml` capability declarations.
    40	
    41	### Manual trigger (v1.0 — debugging / replay)
    42	
    43	```bash
    44	ifosctl scribe replay --tenant <slug> --call-id <provider-call-id>
    45	```
    46	
    47	Useful when a webhook was missed or a transcript needs reprocessing after taxonomy update.
    48	
    49	### v1.1+ surfaces (deferred)
    50	
    51	- Telegram command (`@ifos_bot scribe replay <call-id>`)
    52	- Brain UI per-call "Reprocess" button
    53	- Brain UI "Confidence audit" view showing extraction confidence histograms
    54	
    55	---
    56	
    57	## §3 — Output shape
    58	
    59	Two outputs per webhook. Both write atomically (one transaction); rollback on either failure.
    60	
    61	### Output 1 — Bullhorn structured-field writes (≥3 per call)
    62	
    63	Bullhorn entity inferred from call participants + tenant Bullhorn lookup:
    64	- 1:1 call with candidate → Candidate entity update
    65	- 1:1 call with client contact → Contact entity update
    66	- Briefing call (consultant + client) → Brief entity update
    67	- Placement check-in (consultant + placed candidate) → Placement entity update
    68	- Opportunity scoping (consultant + prospect) → Opportunity entity update
    69	
    70	Minimum 3 fields extracted per call (Gate A). Typical fields by entity:
    71	
    72	| Entity | Likely fields |
    73	|---|---|
    74	| Candidate | location, current_role, notice_period, salary_expectation, work_style (perm/contract/hybrid), key_skills_summary |
    75	| Contact | seniority, decision_authority_level, prefers_comms_via, next_meeting_target |
    76	| Brief | budget_range, deadline_date, role_type, must_haves, nice_to_haves, deal_breakers, decision_committee |
    77	| Placement | start_date_confirmation, week_1_status, blockers, satisfaction_signal |
    78	| Opportunity | sector, headcount_growth_signal, hiring_velocity, decision_window |
    79	
    80	Per `vertical-schema.yaml` v0.1 + v0.2; field names match canonical schema.
    81	
    82	Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
    83	
    84	### Output 2 — Tacit-note Markdown attachment
    85	
    86	One Markdown note per call, attached to the same Bullhorn entity as Output 1 via `POST /Note`. Structure:
    87	
    88	```markdown
    89	# Tacit notes — <Call-context-summary>
    90	**Date:** <ISO-date>  **Duration:** <N> min  **Participants:** <list>
    91	
    92	## Things observed that don't fit a structured field
    93	
    94	- <Observation 1 — bullet, 1-2 sentences, with transcript timestamp [MM:SS]>
    95	- <Observation 2 — ...>
    96	- ...
    97	
    98	## Tone signals
    99	
   100	- <Tone signal 1 — e.g., "client sounded frustrated about Bullhorn data quality">
   101	- <Tone signal 2 — ...>
   102	
   103	## Open questions for consultant follow-up
   104	
   105	- <Open question 1>
   106	- <Open question 2>
   107	```
   108	
   109	Length cap: 800 words. Voice-classified (≥0.75); falls back to "needs consultant review" placeholder if classifier persistently fails (ESC_VOICE_DRIFT).
   110	
   111	Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
   112	1. Relationship signal (client warmth, candidate enthusiasm, prior friction)
   113	2. Process friction (consultant complaint, tool gap, time waste)
   114	3. Competitive intel (mentions of competitor agencies / candidates working with others)
   115	4. Pricing/budget signal (off-record indications of room or constraint)
   116	5. Decision-process insight (who actually decides; coffee-machine politics)
   117	6. Calendar / availability nuance (vacation, life events affecting timeline)
   118	7. Cultural fit observation (working style, communication preferences)
   119	8. Risk flag (legal, IR35, compliance, reference concerns)
   120	
   121	v1.1+: expand taxonomy based on first 3 pilot tenants' patterns.
   122	
   123	---
   124	
   125	## §4 — Workflow
   126	
   127	10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   128	
   129	```
   130	0. Session start (webhook handler)
   131	   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice
   132	     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
   133	   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
   134	
   135	1. Webhook signature verification
   136	   → per-provider HMAC / bearer / OAuth check
   137	   → ESC_SCHEMA_VIOLATION on signature mismatch; reject with 401
   138	   → record provider + call_id in trigger payload
   139	
   140	2. Bullhorn auth refresh
   141	   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
   142	   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
   143	
   144	3. Transcript fetch
   145	   → provider-specific: fathom.get_transcript(call_id) | fireflies.get(...)
   146	   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
   147	   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
   148	   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
   149	
   150	4. Participant + entity inference
   151	   → match transcript participants against Bullhorn contacts + candidates
   152	     + consultant accounts (per tenant config)
   153	   → infer call context (1:1 vs briefing vs placement vs opportunity)
   154	   → resolve target Bullhorn entity (CRN + entity_type)
   155	   → ESC_SCHEMA_VIOLATION if no resolvable entity (e.g., unknown phone number)
   156	
   157	5. LLM field extraction
   158	   → prompt = (transcript + entity context + vertical-schema entity field list
   159	     + 3 voice-corpus examples)
   160	   → output = JSON with per-field confidence scores
   161	   → discard fields confidence <0.6 (per Gate A)
   162	   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
   163	
   164	6. LLM tacit-note generation
   165	   → prompt = (transcript + 8-category taxonomy + 3 voice-corpus examples
   166	     + tone-rule filter)
   167	   → output = Markdown narrative per §3 Output 2 shape
   168	   → voice classifier scores against tenant style guide
   169	   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
   170	
   171	7. Field-extraction validation against vertical-schema
   172	   → verify each extracted field name exists in target entity schema
   173	   → verify each extracted value passes per-field type/range checks
   174	   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION)
   175	
   176	8. Bullhorn write — structured fields (yellow tier)
   177	   → PATCH /<EntityType>/<id> with field map
   178	   → atomic transaction; rollback on Bullhorn 4xx/5xx
   179	   → ESC_BULLHORN_WRITE_FAIL on failure; do NOT proceed to Step 9
   180	
   181	9. Bullhorn write — tacit-note attachment (yellow tier)
   182	   → POST /Note linked to entity from Step 4
   183	   → on success: hh_decision_action("bullhorn_scribe_field_write" +
   184	     "bullhorn_scribe_note_attach", target_entity, payload_hash, payload_preview)
   185	   → on failure: rollback Step 8 (best-effort PATCH /<EntityType>/<id>
   186	     reversing the field changes); ESC_BULLHORN_WRITE_FAIL
   187	
   188	10. Session close + SLA metric
   189	   → compute elapsed_seconds from webhook receipt
   190	   → if elapsed > 600 (10 min): warn ESC_SCRIBE_SLA_MISS (not blocking)
   191	   → if elapsed > 300 (5 min): info-level (counted against Gate B 90%)
   192	   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
   193	   → exit code 0
   194	```
   195	
   196	---
   197	
   198	## §5 — Gates
   199	
   200	### Gate A — validate.sh (hard-fail before action)
   201	
   202	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
   203	
   204	- Webhook signature valid per provider (Step 1)
   205	- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
   206	- 1 tacit-note generated with voice classifier ≥0.75
   207	- Field names exist in target entity per vertical-schema.yaml
   208	- Per-field type + range validation passes
   209	- No PII outside firm boundary in tacit-note narrative
   210	- Bullhorn auth refresh succeeded
   211	
   212	Gate A failures fire `ESC_SCHEMA_VIOLATION` or `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`; transcript stays in `/tmp` (auto-purged 24h); operator notified.
   213	
   214	### Gate B — Outcome thresholds (success metrics, not block)
   215	
   216	Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
   217	
   218	Two metrics:
   219	- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
   220	- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
   221	
   222	Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
   223	
   224	Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
   225	
   226	---
   227	
   228	## §6 — Escalation codes
   229	
   230	Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
   231	
   232	| Code | Trigger | Severity | Routing |
   233	|---|---|---|---|
   234	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   235	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
   236	| `ESC_PROVIDER_FETCH_FAIL` | Fathom/Fireflies/Ringover transcript fetch fails | warn | operator_chat_id |
   237	| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   238	| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
   239	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
   240	| `ESC_SCHEMA_VIOLATION` | Webhook signature fail OR vertical-schema validation fail | **blocking** | operator + ifos_oncall |
   241	| `ESC_SCRIBE_SLA_MISS` | Webhook-to-Bullhorn-write >10 min (Gate B miss) | info | (logged; aggregated to Gate B metric) |
   242	| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
   243	| `ESC_AUTOSEND_YELLOW_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   244	
   245	Scribe does NOT use:
   246	
   247	- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
   248	- `ESC_BULLHORN_OAUTH_REVOKED` — escalated from `ESC_BULLHORN_AUTH` only after 6 consecutive auth failures (Concierge handles)
   249	
   250	---
   251	
   252	## §7 — Voice + tone constraints
   253	
   254	Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   255	
   256	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
   257	  - No identifying language about call participants beyond their professional context
   258	  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
   259	  - No compensation specifics in tacit notes (those go to structured fields only)
   260	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.

exec
/bin/zsh -lc "sed -n '341,520p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).

  # --------------------------------------------------------------------------
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

exec
/bin/zsh -lc "sed -n '1,90p' agents/_shared/hook-helpers.sh" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
#!/usr/bin/env bash
#
# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
#
# Sourced by every rendered agent's .claude/hooks/validate.sh and
# .claude/hooks/context.sh via the per-tenant `_shared/` symlink resolved at
# render time (ADR-003 §3.3.3 Option γ).
#
# Live-mode writes:        Postgres decision_log via psql + IFOS_DB_URL
# Offline-mode writes:     JSON-line append to $IFOS_DECISION_LOG_FALLBACK
#                          (defaults to /vault/<tenant>/decision-log.jsonl)
#
# The dual-mode design means: agents in degraded mode (Hetzner unreachable)
# still produce an audit trail; the trail replays into Postgres when
# connectivity returns. See agents/_shared/README.md §"Degraded mode".
#
# Shellcheck-clean: this file passes `shellcheck -s bash -S style`.
# Side-effects: appends to decision_log table OR fallback JSONL; never reads
# raw PII into shell vars (payload_preview must be sanitised by caller).

# shellcheck shell=bash

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Internal: paths, table names, sanity guards
# ────────────────────────────────────────────────────────────────────────

_HH_HELPERS_VERSION="0.1.0"
_HH_POLICY_FILE="${HH_POLICY_FILE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/autosend-policy.yaml}"
_HH_ESC_CATALOGUE="${HH_ESC_CATALOGUE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/escalation-codes.md}"

# Fallback file used when IFOS_DB_URL is unset OR psql is unavailable.
# Resolved at first call to _hh_emit_row().
_hh_resolve_fallback_path() {
  if [[ -n "${IFOS_DECISION_LOG_FALLBACK:-}" ]]; then
    printf '%s' "${IFOS_DECISION_LOG_FALLBACK}"
    return 0
  fi
  local tenant="${CTX_TENANT_SLUG:-unknown}"
  local vault_root="${IFOS_VAULT_ROOT:-/vault}"
  printf '%s/%s/decision-log.jsonl' "${vault_root}" "${tenant}"
}

# JSON escape a single string for inclusion in a JSON value.
# Use this when BUILDING a JSON document from plain text.
_hh_json_escape() {
  local input="$1"
  input="${input//\\/\\\\}"
  input="${input//\"/\\\"}"
  input="${input//$'\n'/\\n}"
  input="${input//$'\r'/\\r}"
  input="${input//$'\t'/\\t}"
  printf '%s' "${input}"
}

# SQL escape a string for inclusion in a single-quoted SQL string literal.
# Use this when EMBEDDING values in psql SQL. Doubles single quotes;
# leaves everything else (incl. backslashes, JSON internal " characters)
# alone — Postgres standard_conforming_strings=on (default since 9.1)
# treats backslash as literal.
_hh_sql_escape() {
  local input="$1"
  printf '%s' "${input//\'/\'\'}"
}

# Current ISO-8601 UTC timestamp with millisecond precision where available.
# GNU date supports %3N (3-digit nanoseconds → milliseconds). BSD date
# (macOS default) does NOT error on the spec but outputs the literal
# string "3N" instead, which Postgres rejects as invalid timestamptz.
# Detect by checking that %3N produced exactly 3 digits.
_hh_now_iso() {
  local ms
  ms=$(date -u +"%3N" 2>/dev/null)
  if [[ "${ms}" =~ ^[0-9]{3}$ ]]; then
    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
  else
    date -u +"%Y-%m-%dT%H:%M:%SZ"
  fi
}

# Validate that ESC code exists in the catalogue.
# Returns 0 if known, 1 otherwise. Catalogue absent → permissive (return 0).
_hh_validate_esc_code() {
  local code="$1"
  if [[ ! -f "${_HH_ESC_CATALOGUE}" ]]; then
    return 0
  fi
  if grep -Fq "\`${code}\`" "${_HH_ESC_CATALOGUE}"; then

exec
/bin/zsh -lc "sed -n '520,570p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    description: |
      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
    v1_0_agent_access:
      - "none (v1.1+ exercise; T2 Timesheet + T6 Pay & Bill primary readers per v2.0 backlog)"
    v2_0_agent_access:
      - T2 Timesheet — R+W
      - T6 Pay & Bill — R
    canonical_fields:
      bullhorn_id:
        type: integer
        required: true
        source: Bullhorn.Timesheet.id
      week_starting:
        type: date
        required: true
        source: Bullhorn.Timesheet.weekStartDate
      hours_worked:
        type: number
        required: true
        source: Bullhorn.Timesheet.totalHours
      approved_by_client:
        type: boolean
        required: true
        source: Bullhorn.Timesheet.status (parsed)
      approved_by_contractor:
        type: boolean
        required: true
        source: IFOS-derived (T2 confirms; v2.0)
      date_submitted:
        type: timestamp
        required: true
        source: Bullhorn.Timesheet.dateAdded
    notes:
      - v0.1 placeholder. T2 + T6 builds in v2.0 verify field set against real Bullhorn data.

exec
/bin/zsh -lc 'rg -n "hh_decision_(trigger|action|gate|gating|.*)" agents/_shared/hook-helpers.sh' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
166:# hh_decision_trigger <trigger_type> [<reason>]
168:hh_decision_trigger() {
177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
180:hh_decision_output() {
190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
193:hh_decision_action() {

exec
/bin/zsh -lc "rg -n \"Gate A|voice_classifier_threshold|0.75|Change 1\" docs/build-brief/00-MASTER-BRIEF.md docs/specs/ULTRAPLAN.md agents/_shared/common-voice.json docs/verticals/recruitment -g '*.yaml' -g '*.json' -g '*.md'" in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: agents/_shared/common-voice.json: No such file or directory (os error 2)
docs/specs/ULTRAPLAN.md:36:**Rule 4 — Quality gates before features.** An agent that ships with a working Gate A and a measurement plan for Gate B/C is shippable. An agent that ships with extra features but a flaky Gate A is not. Every weekly review checks gates before features.
docs/specs/ULTRAPLAN.md:127:├── validate.sh                    # Output validation hook (Gate A)
docs/specs/ULTRAPLAN.md:146:**Change 1 — Voice handling moves into a shared module.**
docs/specs/ULTRAPLAN.md:348:- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
docs/specs/ULTRAPLAN.md:352:Total Gate A latency: <500ms. Acceptable.
docs/specs/ULTRAPLAN.md:400:### 7.1 Gate A — Output gate (per single run, automated, binary)
docs/specs/ULTRAPLAN.md:402:Already specified in §4 and §6. Every agent's `validate.sh` enforces Gate A. Pass = output ships. Fail = output quarantined, retry up to 3 times, then escalate.
docs/specs/ULTRAPLAN.md:404:Gate A measurements stored in `gate_a_results` Postgres table:
docs/specs/ULTRAPLAN.md:409:Dashboard query: per-agent Gate A pass rate, weekly trend.
docs/specs/ULTRAPLAN.md:447:- Gate A pass rate (target: 100%; alert at <99%)
docs/specs/ULTRAPLAN.md:479:Gate A specifics
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
docs/specs/ULTRAPLAN.md:510:- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:552:- **Gate A:** 5–15 candidates returned per brief; each has a working contact method; each has rationale ≥ 50 words; no candidate flagged "do not contact" in tenant vault
docs/specs/ULTRAPLAN.md:566:- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/specs/ULTRAPLAN.md:582:- **Gate A:** draft generated within 60s of webhook receipt; classification has confidence ≥ 0.8; no auto-send on uncategorised messages
docs/specs/ULTRAPLAN.md:596:- **Gate A:** every brief produces 3 ambiguity flags OR an "unambiguous" signal; pre-shortlist contains 3–10 candidates; intake-call agenda has 5–8 items
docs/specs/ULTRAPLAN.md:614:- **Gate A:** detection latency <5 min from competitor posting; outreach references the specific role title AND the competitor agency by name (the firm needs to know we're not making this up)
docs/specs/ULTRAPLAN.md:628:- **Gate A:** 8–12 candidates per brief; each has rationale ≥ 50 words; drafts for each are valid (Gate A on the draft itself); no rate-limit exceptions raised
docs/specs/ULTRAPLAN.md:642:- **Gate A:** every red-flag pattern (e.g., FCSA accreditation lapsed, complaint volume spike, director change) produces an alert within 24 hours; quarterly audit pack contains all required sections
docs/specs/ULTRAPLAN.md:656:- **Gate A:** every active contractor has a live state with AWR week counter, RTW expiry, contract end, holiday pay year-to-date; deadline-imminent alerts fire ≥7 days ahead
docs/specs/ULTRAPLAN.md:806:- Voice classifier and Gate A enforcement (Rule 4)
docs/specs/ULTRAPLAN.md:823:| 7 | Voice classifier underperforms (false positives blocking valid drafts) | Medium | Medium | First pilot reports >5% block rate on legitimate drafts | Soften the threshold from 0.75 → 0.65 for v1.0; tune up as corpus grows |
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
docs/build-brief/00-MASTER-BRIEF.md:57:4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
docs/build-brief/00-MASTER-BRIEF.md:547:├── validate.sh                         # Gate A — sources _shared/hook-helpers.sh
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:619:# 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
docs/build-brief/00-MASTER-BRIEF.md:986:6. **The quality gates** — Gate A binary per-run, Gate B 90-day, Gate C weekly voice classifier
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.

codex
REJECTED

1. §10 cites the wrong ratification skill. Line 321 says `.codex/ratification/review-architecture-decision.md`, but this artefact is an agent bundle and the required skill is `review-agent-bundle.md`; the type-specific rule makes this a reject. Fix line 321 to cite `review-agent-bundle.md` and keep post-build re-ratification aligned with that skill.

2. §1 output contract does not name a vault write path. Line 16 names a “tacit-note Markdown attachment” but no `/vault/<tenant>/...` path, despite the agent-bundle requirement that §1 name the artefact path and the vault/Postgres split for narrative Markdown. Fix §1/§3 to name the canonical vault path for the tacit note and clarify what, if anything, is mirrored into Bullhorn.

3. §3 invents autosend action types. Line 82 uses `bullhorn_scribe_field_write`, and lines 183-184 combine `bullhorn_scribe_field_write` + `bullhorn_scribe_note_attach`; neither exists in `agents/_shared/autosend-policy.yaml`, whose Scribe yellow action is `bullhorn_note_append_summary`. Fix the decision-log action signatures to use registered action types, or add a separately ratified autosend-policy update before this agent references them.

4. §6 cites escalation codes that are not in the catalogue. Lines 235, 236, 238, 241, 243, and 224 reference `ESC_BULLHORN_WRITE_FAIL`, `ESC_PROVIDER_FETCH_FAIL`, `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`, `ESC_SCRIBE_SLA_MISS`, `ESC_AUTOSEND_YELLOW_SPOT_CHECK`, and `ESC_GATE_B_MISS`, but these are not defined in `agents/_shared/escalation-codes.md` and are not flagged for catalogue addition. Fix by reusing existing catalogue codes or explicitly marking new codes as pending catalogue additions.

5. §3 claims schema alignment but lists fields not present in the schema. Lines 74-78 say the field names “match canonical schema,” but examples like `notice_period`, `salary_expectation`, `work_style`, `key_skills_summary`, `decision_authority_level`, `budget_range`, `deadline_date`, `must_haves`, `start_date_confirmation`, and `hiring_velocity` do not match `vertical-schema.yaml` canonical names. Fix the table to use canonical fields such as `notice_period_weeks`, `salary_expectation_min/max`, `decision_authority`, `salary_min/max`, `start_date`, etc., or land a schema supplement first.

6. §4 workflow omits required `hh_decision_*` calls on output/action steps. Lines 176-186 perform Bullhorn field writes and note attachment, but only Step 9 has one success-side `hh_decision_action`; failed actions and earlier output-producing extraction/generation steps do not emit `hh_decision_output`/`hh_decision_action` rows. Fix Steps 5-9 so every produced output and attempted action writes the appropriate decision-log row before Gate A or dispatch proceeds.
tokens used
45,619
REJECTED

1. §10 cites the wrong ratification skill. Line 321 says `.codex/ratification/review-architecture-decision.md`, but this artefact is an agent bundle and the required skill is `review-agent-bundle.md`; the type-specific rule makes this a reject. Fix line 321 to cite `review-agent-bundle.md` and keep post-build re-ratification aligned with that skill.

2. §1 output contract does not name a vault write path. Line 16 names a “tacit-note Markdown attachment” but no `/vault/<tenant>/...` path, despite the agent-bundle requirement that §1 name the artefact path and the vault/Postgres split for narrative Markdown. Fix §1/§3 to name the canonical vault path for the tacit note and clarify what, if anything, is mirrored into Bullhorn.

3. §3 invents autosend action types. Line 82 uses `bullhorn_scribe_field_write`, and lines 183-184 combine `bullhorn_scribe_field_write` + `bullhorn_scribe_note_attach`; neither exists in `agents/_shared/autosend-policy.yaml`, whose Scribe yellow action is `bullhorn_note_append_summary`. Fix the decision-log action signatures to use registered action types, or add a separately ratified autosend-policy update before this agent references them.

4. §6 cites escalation codes that are not in the catalogue. Lines 235, 236, 238, 241, 243, and 224 reference `ESC_BULLHORN_WRITE_FAIL`, `ESC_PROVIDER_FETCH_FAIL`, `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`, `ESC_SCRIBE_SLA_MISS`, `ESC_AUTOSEND_YELLOW_SPOT_CHECK`, and `ESC_GATE_B_MISS`, but these are not defined in `agents/_shared/escalation-codes.md` and are not flagged for catalogue addition. Fix by reusing existing catalogue codes or explicitly marking new codes as pending catalogue additions.

5. §3 claims schema alignment but lists fields not present in the schema. Lines 74-78 say the field names “match canonical schema,” but examples like `notice_period`, `salary_expectation`, `work_style`, `key_skills_summary`, `decision_authority_level`, `budget_range`, `deadline_date`, `must_haves`, `start_date_confirmation`, and `hiring_velocity` do not match `vertical-schema.yaml` canonical names. Fix the table to use canonical fields such as `notice_period_weeks`, `salary_expectation_min/max`, `decision_authority`, `salary_min/max`, `start_date`, etc., or land a schema supplement first.

6. §4 workflow omits required `hh_decision_*` calls on output/action steps. Lines 176-186 perform Bullhorn field writes and note attachment, but only Step 9 has one success-side `hh_decision_action`; failed actions and earlier output-producing extraction/generation steps do not emit `hh_decision_output`/`hh_decision_action` rows. Fix Steps 5-9 so every produced output and attempted action writes the appropriate decision-log row before Gate A or dispatch proceeds.
