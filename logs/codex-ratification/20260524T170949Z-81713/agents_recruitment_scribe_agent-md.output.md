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
session id: 019e5af6-e2e3-7312-a042-438ca339b965
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

> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.

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

Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):

| Entity | Canonical fields (schema-verified) |
|---|---|
| Candidate | `location`, `current_role_title`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (perm/contract/hybrid), `key_skills` (list) |
| Contact | `seniority`, `decision_authority` (enum: yes/no/influencer/blocker/unknown per Q5 v0.1), `preferred_channel`, `next_action_target_date` |
| Brief | `salary_min` + `salary_max`, `start_date`, `role_type`, `must_haves` (list), `nice_to_haves` (list), `deal_breakers` (list) |
| Placement | `start_date`, `placement_status`, `week_1_status_note` (free-text), `satisfaction_signal` (enum) |
| Opportunity | `sector`, `headcount_growth_signal_text`, `hiring_velocity_band`, `decision_window_text` |

Field names match canonical schema verbatim; some v0.1 fields (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `week_1_status_note`) are scheduled for v0.3 supplement at W6 build start — flagged here as pre-build references requiring schema-supplement landing before Scribe references them in `cycle.sh`. The Q1 verification pass (W6 Day 1) audits all field names against the schema as it exists then.

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
   → ESC_INPUT_VALIDATION_FAIL on signature mismatch; reject with 401
   → record provider + call_id in trigger payload
   → hh_decision_output("webhook_verified", "call:<id>", "provider:<name>")

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
   → resolve target Bullhorn entity (bullhorn_id + entity_type per
     vertical-schema.yaml canonical id field)
   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
     a Scribe run with no resolvable target cannot produce structured writes)
   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>", confidence)

5. LLM field extraction
   → prompt = (transcript + entity context + vertical-schema entity field list
     + 3 voice-corpus examples)
   → output = JSON with per-field confidence scores
   → discard fields confidence <0.6 (per Gate A)
   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
     "<N> fields ≥0.6 confidence")

6. LLM tacit-note generation
   → prompt = (transcript + 8-category taxonomy + 3 voice-corpus examples
     + tone-rule filter)
   → output = Markdown narrative per §3 Output 2 shape
   → voice classifier scores against tenant style guide
   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md
   → hh_decision_output("tacit_note_rendered", "<vault_path>",
     "voice_score:<N>; words:<N>")

7. Field-extraction validation against vertical-schema
   → verify each extracted field name exists in target entity schema
   → verify each extracted value passes per-field type/range checks
   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION
     per catalogue line 163 — vertical-schema field-constraint violation at write time)

8. Bullhorn write — structured fields (yellow tier)
   → PATCH /<EntityType>/<id> with field map
   → atomic transaction; rollback on Bullhorn 4xx/5xx
   → on success: hh_decision_action("bullhorn_scribe_field_write",
     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
   → on failure: ESC_BULLHORN_WRITE_FAIL; do NOT proceed to Step 9

9. Bullhorn write — tacit-note attachment (yellow tier)
   → POST /Note linked to entity from Step 4 (mirror of vault artefact from Step 6)
   → on success: hh_decision_action("bullhorn_note_attach",
     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
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

Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.

**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.

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
| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1) | warn | operator_chat_id |
| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
| `ESC_SCRIBE_SLA_MISS` | Webhook-to-Bullhorn-write >10 min (Gate B miss) | info | (logged; aggregated to Gate B metric) |
| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |

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
- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.

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

Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.

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
I’ll verify the cited source files and schema/catalogue references before deciding; the main risk here is citation drift or invented fields/codes in the scaffold.
exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_BULLHORN_WRITE_FAIL|ESC_PROVIDER_FETCH_FAIL|ESC_VOICE_DRIFT|ESC_FIELD_EXTRACTION_LOW_CONFIDENCE|ESC_PII_LEAKAGE_RISK|ESC_INPUT_VALIDATION_FAIL|ESC_AGENT_OUTPUT_SHAPE|ESC_SCHEMA_VIOLATION|ESC_SCRIBE_SLA_MISS|ESC_RATE_LIMIT_HIT|ESC_AUTOSEND_SAMPLED_SPOT_CHECK|ESC_VOICE_DRIFT_TENANT|ESC_BULLHORN_OAUTH_REVOKED" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
97:#### `ESC_BULLHORN_AUTH`
120:#### `ESC_VOICE_DRIFT`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
310:#### `ESC_BULLHORN_WRITE_FAIL`
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
324:#### `ESC_PROVIDER_FETCH_FAIL`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
441:#### `ESC_SCRIBE_SLA_MISS`

exec
/bin/zsh -lc "rg -n \"bullhorn_scribe_field_write|bullhorn_note_attach|yellow|autosend|action_type|tier\" agents docs -g 'autosend-safety-policy.yaml' -g '*.yaml' -g '*.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:3:# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
agents/_shared/autosend-policy.yaml:4:# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:8:# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:10:#   tier            green|yellow|orange|red
agents/_shared/autosend-policy.yaml:13:#   sample_rate     yellow only: 1-in-N for spot-check sampling
agents/_shared/autosend-policy.yaml:23:action_types:
agents/_shared/autosend-policy.yaml:26:  # GREEN — auto-send without review (19 action_types)
agents/_shared/autosend-policy.yaml:30:    tier: green
agents/_shared/autosend-policy.yaml:36:    tier: green
agents/_shared/autosend-policy.yaml:42:    tier: green
agents/_shared/autosend-policy.yaml:48:    tier: green
agents/_shared/autosend-policy.yaml:54:    tier: green
agents/_shared/autosend-policy.yaml:60:    tier: green
agents/_shared/autosend-policy.yaml:66:    tier: green
agents/_shared/autosend-policy.yaml:72:    tier: green
agents/_shared/autosend-policy.yaml:78:    tier: green
agents/_shared/autosend-policy.yaml:84:    tier: green
agents/_shared/autosend-policy.yaml:90:    tier: green
agents/_shared/autosend-policy.yaml:96:    tier: green
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:102:    tier: green
agents/_shared/autosend-policy.yaml:108:    tier: green
agents/_shared/autosend-policy.yaml:114:    tier: green
agents/_shared/autosend-policy.yaml:120:    tier: green
agents/_shared/autosend-policy.yaml:126:    tier: green
agents/_shared/autosend-policy.yaml:132:    tier: green
agents/_shared/autosend-policy.yaml:138:    tier: green
agents/_shared/autosend-policy.yaml:144:  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
agents/_shared/autosend-policy.yaml:148:    tier: yellow
agents/_shared/autosend-policy.yaml:155:    tier: yellow
agents/_shared/autosend-policy.yaml:161:  bullhorn_note_attach:
agents/_shared/autosend-policy.yaml:162:    tier: yellow
agents/_shared/autosend-policy.yaml:169:    tier: yellow
agents/_shared/autosend-policy.yaml:176:    tier: yellow
agents/_shared/autosend-policy.yaml:183:    tier: yellow
agents/_shared/autosend-policy.yaml:190:    tier: yellow
agents/_shared/autosend-policy.yaml:196:  bullhorn_scribe_field_write:
agents/_shared/autosend-policy.yaml:197:    tier: yellow
agents/_shared/autosend-policy.yaml:204:    tier: yellow
agents/_shared/autosend-policy.yaml:211:    tier: yellow
agents/_shared/autosend-policy.yaml:214:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
agents/_shared/autosend-policy.yaml:218:  # ORANGE — per-action human approval (10 action_types)
agents/_shared/autosend-policy.yaml:222:    tier: orange
agents/_shared/autosend-policy.yaml:230:    tier: orange
agents/_shared/autosend-policy.yaml:237:    tier: orange
agents/_shared/autosend-policy.yaml:244:    tier: orange
agents/_shared/autosend-policy.yaml:251:    tier: orange
agents/_shared/autosend-policy.yaml:258:    tier: orange
agents/_shared/autosend-policy.yaml:265:    tier: orange
agents/_shared/autosend-policy.yaml:272:    tier: orange
agents/_shared/autosend-policy.yaml:279:    tier: orange
agents/_shared/autosend-policy.yaml:286:    tier: orange
agents/_shared/autosend-policy.yaml:293:  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
agents/_shared/autosend-policy.yaml:297:    tier: red
agents/_shared/autosend-policy.yaml:304:    tier: red
agents/_shared/autosend-policy.yaml:311:    tier: red
agents/_shared/autosend-policy.yaml:318:    tier: red
agents/_shared/autosend-policy.yaml:325:    tier: red
agents/_shared/autosend-policy.yaml:332:    tier: red
agents/_shared/autosend-policy.yaml:339:    tier: red
agents/_shared/autosend-policy.yaml:346:    tier: red
agents/_shared/autosend-policy.yaml:357:  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
agents/_shared/autosend-policy.yaml:359:  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes
agents/_shared/autosend-policy.yaml:367:  - "tier ∈ {green, yellow, orange, red}"
agents/_shared/autosend-policy.yaml:368:  - "yellow action_types MUST declare sample_rate (positive integer)"
agents/_shared/autosend-policy.yaml:369:  - "orange action_types MUST declare timeout (ISO-8601 duration)"
agents/_shared/autosend-policy.yaml:370:  - "red action_types MUST declare block_reason"
agents/_shared/autosend-policy.yaml:371:  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
agents/_shared/autosend-policy.yaml:372:  - "47 total action_types (19 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:789:      orange-tier sends.
agents/_shared/escalation-codes.md:13:The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
agents/_shared/escalation-codes.md:20:payload           — JSON object: {tier?, action_type?, target?, payload_hash?, reason, ...code-specific fields}
agents/_shared/escalation-codes.md:31:Source: `docs/decisions/autosend-safety-policy.md` §5
agents/_shared/escalation-codes.md:35:- **Trigger:** Orange-tier action queued for tenant operator review
agents/_shared/escalation-codes.md:39:- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`
agents/_shared/escalation-codes.md:43:- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
agents/_shared/escalation-codes.md:46:- **Payload fields:** `tier='red'`, `action_type`, `target`, `payload_hash`, `reason='red_tier_classification'`
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:53:- **Payload fields:** `tier='fail-safe-red'`, `action_type`, `target`, `reason` (one of `unknown_action_type`, `override_resolution_failed`, `unknown_tier:<value>`)
agents/_shared/escalation-codes.md:54:- **Fail-safe behaviour:** Action refused regardless of declared tier
agents/_shared/escalation-codes.md:339:Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
agents/_shared/escalation-codes.md:343:- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
agents/_shared/escalation-codes.md:346:- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
agents/_shared/escalation-codes.md:350:- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
agents/_shared/escalation-codes.md:353:- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:360:  - **State-change race (Cash Conductor):** payment received between chase-draft and chase-send window; the invoice is no longer overdue when the orange-tier approval fires; chase cancelled (do NOT send) per Cash Conductor §4 Step 12
agents/_shared/escalation-codes.md:363:- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
agents/_shared/escalation-codes.md:368:- **Trigger:** Yellow-tier action was sampled per `sample_rate` (1-in-N) for post-hoc human review; sampling is informational + drives ongoing quality monitoring
agents/_shared/escalation-codes.md:371:- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:429:- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`
agents/_shared/escalation-codes.md:474:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:86:          Items enum: ["vault_emails", "bullhorn_notes", "marketing_copy", "founder_curated", "consultant_drafts"]. Order documents provenance for the LoRA pipeline (v2.0 Scale tier).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:208:      action_type:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:211:        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
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
agents/_shared/README.md:72:`hh_decision_action` dispatches per tier:
agents/_shared/README.md:77:| **yellow** | Emit `phase=action`, draw 1-in-N spot-check sample, return 0 | 0 |
agents/_shared/README.md:84:Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
agents/_shared/README.md:88:**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:127:     AND payload->>'tier' = 'red'
agents/_shared/README.md:167:- `agents/_shared/autosend-policy.yaml` (Reference — runtime table)
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:177:- `docs/decisions/autosend-safety-policy.md` — full tier model + §4 reference impl
agents/_shared/README.md:178:- `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 5 — red-tier breach kill criterion
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:192:        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
docs/verticals/recruitment/vertical-schema.yaml:335:        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
docs/verticals/recruitment/vertical-schema.yaml:337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
docs/verticals/recruitment/vertical-schema.yaml:338:      - v1.1 Triage expands: structured decision-authority (budget tier, decision domain, escalation chain), engagement history aggregate, preferred-channel sentiment.
docs/verticals/recruitment/vertical-schema.yaml:365:        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:666:# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
docs/verticals/recruitment/vertical-schema.yaml:726:    contact: R       # decision-maker resolution for orange-tier sends
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:823:    v1_1_plus_expansion: Sub-fields for decision-domain (technical/budget/strategic), authority tier (final/recommend/influence/observer), engagement history aggregate, preferred-channel sentiment.
docs/architecture/tenancy-invariants.md:253:| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |
docs/architecture/architecture-cohesion-review.md:74:| vault-concurrency.md §6 | ESC wiring | hook-helpers.sh::autosend_escalate | ✓ landed Phase 3 (e6e9df1) |
docs/architecture/architecture-cohesion-review.md:123:### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)
docs/architecture/architecture-cohesion-review.md:125:- **autosend-safety-policy.md** §7 says `payload_preview` MUST exclude raw PII (max 500 chars, no names/phones/emails)
docs/architecture/architecture-cohesion-review.md:148:| G2 | **The `tenants` table life-cycle states.** `tenants.metadata` JSONB has no documented shape. What goes in: `status` enum? `tier` cache? `provisioned_at`? `last_offboard_warning_at`? | Medium (tenant-lifecycle runbook depends on it) | Surfaced in tenant-lifecycle.md (same commit). Real implementation lands at first tenant onboarding. |
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:228:| R2 | G8: Autosend v1.0 tier enforcement | High | Founder Decision D1 | Founder | Pre-Concierge W10 |
docs/architecture/agent-bundle-renderer-design.md:203:tier: 1
docs/runbooks/operational-hygiene-protocol.md:26:- **Length discipline C+** — Day 5 autosend policy 658 lines vs 300-500 estimate; Day 6 vertical schema 899 lines vs same estimate
docs/runbooks/operational-hygiene-protocol.md:27:- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
docs/runbooks/operational-hygiene-protocol.md:150:- Day 5 autosend policy: estimated 300-500 lines; actual 648. **+30% to +116% overshoot.**
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:170:1. Count sub-units (decisions, mechanisms, sections, tiers, entities, etc.)
docs/runbooks/operational-hygiene-protocol.md:202:3. **Numerical claims:** count. "29 action_types" not "30+". "10 entity_links" not "~10". If counting is hard, write the counting query (grep, wc -l, SQL) and run it.
docs/runbooks/operational-hygiene-protocol.md:217:grep -nE "\b[0-9]+ (entities|fields|action_types|relationships|triggers|tiers|sections|edits|items)" <artefact>
docs/runbooks/operational-hygiene-protocol.md:224:- "30+ action_types" → forbidden. Count: 29. Write "29 action_types".
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:275:| `docs/decisions/autosend-safety-policy.md` | 1 | Same cost-target replacement for the cyber-insurance budget reference |
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/runbooks/operational-hygiene-protocol.md:288:### §7.3 — Finding: Day-6 "30+ action_types" inflation (caught in founder review)
docs/runbooks/operational-hygiene-protocol.md:290:Day-6 structural summary claimed "30+ action_types across 6 v1.0 agents" in autosend policy §3. Actual count: 29 (Green 6 + Yellow 5 + Orange 10 + Red 8). The artefact itself does not make this claim — only my summary message did.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:84:### Post-founding tiers (customers 11+)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:93:v2 preserves the pricing model. Migration of founding customers to v2 happens at their existing £400/mo rate; new customers signed up to v2 use the post-founding tiers.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:227:                  → £400/mo (founding) or tier price
docs/runbooks/tenant-lifecycle.md:54:| `tier` | Pricing decision | solo | boutique | growth | scale |
docs/runbooks/tenant-lifecycle.md:72:  VALUES ('${SLUG}', '<legal_name>', '{\"status\":\"provisioning\",\"tier\":\"<tier>\",\"provisioned_at\":\"$(date -u +%FT%TZ)\"}'::jsonb);"
docs/runbooks/tenant-lifecycle.md:100:tier: <tier>
docs/runbooks/tenant-lifecycle.md:148:| Agent draft + approve via Telegram | `hh_decision_action` writes to decision_log; orange-tier blocks on Telegram approval | T4 (every write sets SET LOCAL) |
docs/runbooks/tenant-lifecycle.md:153:| Spot-check operator review | `autosend_spot_check_enqueue` writes to `/vault/<slug>/spot-checks/<file>.md`; operator reviews + flags as approved/rejected/escalate | (No invariant violation) |
docs/architecture/cortexos-primitive-status.md:66:**Risk if flaky:** Tier-1 always-on agents collapse to scheduled cron with cold-start latency, eliminating the "sub-second to first useful action" claim that justifies pricing the Triage/Concierge/Pulse demos above point-tool parity (Ultraplan §3.2). Per Ultraplan §3.1 row 1, the documented contingency is: "Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving." Quirk 2 (`.agents/learnings/00-cortextos-quirks.md`) — `node-pty` requires `npm rebuild` on Node 25+ — is the most likely re-trip wire because the Mac Studio cluster nodes for the v2.0 Sovereign tier may not run Node 22 LTS by default.
docs/architecture/cortexos-primitive-status.md:101:Two complementary mechanisms ship: a wall-clock session timer at exactly 71 hours (255600s) plus a context-percentage tiered handoff system that fires earlier when actual token usage crosses configurable thresholds. Both have regression-named bug fixes and dedicated test files. No Day-0 brittleness evidence.
docs/architecture/cortexos-primitive-status.md:107:- `src/daemon/fast-checker.ts:899-1003` — `checkContextStatus()` polls `${stateDir}/context_status.json` written by the `hook-context-status` statusLine bridge. Three tiers: Tier 1 warning at `ctx_warning_threshold` default 70% injects `[CONTEXT] Window at X%`, Tier 2 handoff at `ctx_handoff_threshold` default 80% writes the handoff prompt and `.force-fresh` marker (line 996-1000), Tier 3 force-restart 5 minutes after Tier 2 if the agent didn't comply (line 962-967).
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:460:**Risk if flaky:** Brief Decoder slips to v1.2 — the documented contingency in Ultraplan §3.1 row 3. Loses the "shortlist in 90 minutes" demo for the Growth tier. The "orchestrator-coupled Telegram polling" trade-off (`agent-manager.ts:465-472`) means if the orchestrator agent itself crashes, the activity-channel callbacks stop until restart — primitive 1's crash-loop alert covers that case.
docs/architecture/vault-concurrency.md:397:**Status update 2026-05-20 (Day 8 Codex Round 1):** all 5 codes below are now catalogued at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`, Phase 1 of Week-1 slice) AND wired into the `autosend_escalate` helper at `agents/_shared/hook-helpers.sh` (commit `e6e9df1`, Phase 3 of Week-1 slice). The "_shared/hook-helpers.sh Week-1 prereq must wire these 5 codes" language below has been satisfied — current state is shipped + tested.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/runbooks/pii-purge-operational-pattern.md:113:| `action_type` | populated | populated (preserved) |
docs/runbooks/pii-purge-operational-pattern.md:159:| Disk full during audit row write | UPDATE succeeds; audit row write fails; orphaned purge | Decision_log fallback to JSONL at `/var/log/ifos/decision-log.jsonl`; replay via autosend-syncer when disk recovers |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/architecture/second-brain-design.md:190:└── temp/                                           ← if Temp tier active (Ultraplan §5.1 line 220) — v1.1+ deferred for IFOS Temp launch
docs/architecture/second-brain-design.md:310:relationship_tier: key-account                       # optional v1.0; one of {key-account, active, dormant, ex-client}
docs/architecture/second-brain-design.md:471:  tier              TEXT NOT NULL,                       -- one of {solo, boutique, growth, scale, compliance-core, compliance-ops, full-temp}
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:891:| **Operational complexity** — new infrastructure introduced | None new. 12 shell wrappers + a Node CLI binary + a library; same shape as `packages/harness/cortextos/bus/`. No new PM2 process. | One new PM2 process per machine (`ifos-wiki-mcp`). Adds to the operations surface: process supervision, restart policy, port allocation, logs to manage. At Sovereign tier (one cluster slice per tenant per Ultraplan §5.4) this is one extra process per tenant. | Skill files added to every agent at scaffold time. Under R2 renderer (recommended), the renderer must be extended to inject the wiki skill — additional renderer logic. Under R1, automatic. |
docs/architecture/second-brain-design.md:908:3. **Master brief §3.5 + §5.5 (multi-tenancy + onboarding wizard 5-day flow).** §3.5's "100 customers by end of 2027" stress test (Product Spec §5.4) demands zero per-customer operational drag. Option α adds no per-customer infrastructure. Option β at Sovereign tier (Ultraplan §5.4 per-tenant cluster slice) means one `ifos-wiki-mcp` process per Sovereign tenant — a new operational surface to monitor at scale.
docs/architecture/second-brain-design.md:975:| **2.6** | Master brief §5 silent on concurrency | No mechanism for agent×agent, agent×human-in-Obsidian, or rewrite-backlinks cascade | Resolved in §2.6.1, §2.6.2, §2.6.3 of this design. Companion document `docs/architecture/vault-concurrency.md` LANDED (Day 3, commit `78680cc`). New escalation codes (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, `ESC_VAULT_RENAME_RACE`) CATALOGUED at `agents/_shared/escalation-codes.md` §2.2 (Day 8 commit `a279226`) + WIRED into `agents/_shared/hook-helpers.sh::autosend_escalate` (Day 8 commit `e6e9df1`). | **Closed 2026-05-20.** Catalogue + wiring complete; ESC codes callable from any rendered agent. |
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
docs/build-brief/00-MASTER-BRIEF.md:404:- **The graph view as the closing-demo asset.** Open `/brain/graph` filtered to "everyone we've placed in fintech in the last 12 months". Filter by entity type, time window, importance score. Hover reveals entity cards. Click selects + filters to ego-graph. This is what justifies the Scale tier visually.
docs/build-brief/00-MASTER-BRIEF.md:477:- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
docs/build-brief/00-MASTER-BRIEF.md:576:`validate.sh` hard-fails on missing calls. This is what enables the v2.0 LoRA pipeline — no decision log, no SFT corpus, no Scale-tier moat.
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:983:3. **The decision log + per-firm LoRA pipeline** — Scale-tier defensibility
docs/build-brief/00-MASTER-BRIEF.md:985:5. **The wiki + graph brain** — the visible "second brain" that closes Scale-tier deals
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:79:### Output 1 — Reconciliation rows (yellow tier)
agents/recruitment/cash-conductor/agent.md:91:Stages 1-2 auto-write reconciliation to accounting system (yellow tier; spot-check sampled). Stages 3-4 queue for consultant review. Stage 5 flagged in weekly report.
agents/recruitment/cash-conductor/agent.md:93:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:95:### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)
agents/recruitment/cash-conductor/agent.md:97:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 257) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:111:expected_send_window: orange-tier approval expected within 24h
agents/recruitment/cash-conductor/agent.md:116:1. `phase='output'`, `output_type='chase_draft_generated'`, payload includes the draft body + voice score + position (phase=output rows do NOT carry an autosend action_type; they're internal artefact-render markers).
agents/recruitment/cash-conductor/agent.md:117:2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 182-187), payload links to the draft from row 1 — this row records that Cash Conductor classified the draft as yellow-tier internal.
agents/recruitment/cash-conductor/agent.md:119:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 257; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
agents/recruitment/cash-conductor/agent.md:189:   → write Stage 1-2 matches to accounting (yellow tier) atomically
agents/recruitment/cash-conductor/agent.md:196:6. Reconciliation write (yellow tier; per match)
agents/recruitment/cash-conductor/agent.md:202:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
agents/recruitment/cash-conductor/agent.md:236:     `ESC_AUTOSEND_BLOCKED` is reserved for red-tier action attempts per
agents/recruitment/cash-conductor/agent.md:237:     catalogue line 41; Cash Conductor's chase pipeline is orange-tier.
agents/recruitment/cash-conductor/agent.md:240:10. Chase-draft queue to Concierge (opens orange-tier approval bridge)
agents/recruitment/cash-conductor/agent.md:243:      payload_hash, payload_preview) — tier=yellow internal-draft per
agents/recruitment/cash-conductor/agent.md:244:      autosend-policy.yaml line 182
agents/recruitment/cash-conductor/agent.md:246:      payload_hash, payload_preview) — tier=orange per autosend-policy.yaml
agents/recruitment/cash-conductor/agent.md:247:      line 257; Cash Conductor owns this action_type and OPENS the
agents/recruitment/cash-conductor/agent.md:248:      orange-approval-bridge; Concierge handles autosend-bridge call to
agents/recruitment/cash-conductor/agent.md:253:    → The orange-tier `xero_reminder_send_customer` action row was
agents/recruitment/cash-conductor/agent.md:255:      action_type per autosend-policy.yaml line 257; agent: cash-conductor).
agents/recruitment/cash-conductor/agent.md:263:      green-tier internal status marker recording state mutation completion
agents/recruitment/cash-conductor/agent.md:285:      — hh_decision_action signature is (action_type, target, payload_hash,
agents/recruitment/cash-conductor/agent.md:296:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:310:### Gate B — Outcome threshold (FD-tier closer metric)
agents/recruitment/cash-conductor/agent.md:318:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:346:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:393:| **Founder Decision D1 (autosend orange-tier path) RESOLVED** — blocking for Cash Conductor's xero_reminder_send_customer action_type | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` D1 (currently Proposed) | ⏸ |
agents/recruitment/cash-conductor/agent.md:394:| **Autosend bridge implementation** (per D1 outcome) — Concierge W10 build delivers; blocking for orange-tier send writes | Concierge W10 build slice (~2 days for D1-A; less for D1-B/C) | ⏸ |
agents/recruitment/cash-conductor/agent.md:395:| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
docs/operations/bullhorn-outreach-emails.md:49:> Is membership in the Marketplace Partner Programme required for production tenants to connect Intel Force OS to their Bullhorn instances? Or can pilot tenants authorise us as a connected app via the standard developer-tier path (support-ticket-issued client_id/client_secret per https://bullhorn.github.io/Getting-Started-with-REST)?
docs/operations/bullhorn-outreach-emails.md:55:> Are there API rate-limit, scope, or endpoint deltas between marketplace-tier and direct-tier access at small pilot volume? Specifically: do marketplace partners get elevated rate limits, write access to entity types not available to direct-tier, or webhook subscription endpoints that the documented REST API doesn't expose?
docs/operations/bullhorn-outreach-emails.md:58:> If marketplace tier grants Intel Force OS application-level credentials (one client_id per IFOS app), per-tenant onboarding could be reduced to a single OAuth dance per pilot tenant. Confirming this is the marketplace model (vs each tenant raising their own support ticket as documented for direct-tier).
docs/operations/bullhorn-outreach-emails.md:73:- If they confirm direct-tier works for pilot scale → Sub-decision A flips to **Direct API**; Status: Accepted. Update `bullhorn-integration-path.md` §5.
docs/operations/bullhorn-outreach-emails.md:75:- If they offer a Bullhorn Developer Program intermediate tier → that's likely the right path for 2026 H2 pilots; defer marketplace to v1.1+.
docs/operations/bullhorn-outreach-emails.md:108:> Is there a sandbox / staging Bullhorn environment we can use for development without consuming production-tier API budget? If yes, what's the access path (separate credentials, sandbox-only client_id, or in-production with a "test corpToken")?
docs/operations/bullhorn-outreach-emails.md:111:> Does Bullhorn's OAuth 2.0 implementation support the client_credentials grant type for service-account-style access (against our own developer-tier tenant, not pilot tenants)? We want to use this for IFOS-internal CI testing and connector unit-test fixtures. The public docs reference only authorization-code grant.
docs/operations/bullhorn-outreach-emails.md:126:**Expected response time:** 2-5 business days (often faster for technical-tier developer support than partnerships).
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:65:### Output 2 — Bullhorn writes (yellow tier)
agents/recruitment/janitor/agent.md:67:Three write categories. Action types map to `agents/_shared/autosend-policy.yaml` — existing entries are used as-is; new entries are flagged for catalogue addition at W5 build (per `review-agent-bundle.md` §1 row §6 flag-for-addition pattern):
agents/recruitment/janitor/agent.md:69:1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (existing in autosend-policy.yaml line 69; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:70:2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:71:3. **Tacit-note attach** (`POST /Note` linked to entity) — narrative summary of consultant edits + decision-log resolutions over the 30-day window. Action type: **`bullhorn_note_attach`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 20).
agents/recruitment/janitor/agent.md:73:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:143:9. Bullhorn write batch (yellow tier — spot-check sampling)
agents/recruitment/janitor/agent.md:145:     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
agents/recruitment/janitor/agent.md:153:   → group by action_type; tally success/fail; compute Gate-B metric
agents/recruitment/janitor/agent.md:159:   → if Gate-B target met: green-tier notification with summary
agents/recruitment/janitor/agent.md:160:   → if Gate-B target missed: yellow-tier notification + 200-char executive
agents/recruitment/janitor/agent.md:177:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:215:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
agents/recruitment/janitor/agent.md:220:- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:186:8. Bullhorn write — structured fields (yellow tier)
agents/recruitment/scribe/agent.md:189:   → on success: hh_decision_action("bullhorn_scribe_field_write",
agents/recruitment/scribe/agent.md:193:9. Bullhorn write — tacit-note attachment (yellow tier)
agents/recruitment/scribe/agent.md:195:   → on success: hh_decision_action("bullhorn_note_attach",
agents/recruitment/scribe/agent.md:214:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:259:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
agents/recruitment/scribe/agent.md:263:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
docs/operations/codex-ratification-guide.md:397:If `IFOS_DB_URL` isn't set when the wrapper runs (or psql isn't on PATH or the live DB rejects the write), the row appends to `logs/codex-ratification.jsonl` instead. Same shape, JSON Lines. Replays into Postgres later via the autosend-syncer worker (Week 5+).
agents/recruitment/diagnostic/fixtures/01-primary.yaml:106:    action_type: diagnostic_report_render
agents/recruitment/diagnostic/fixtures/01-primary.yaml:110:    action_type: diagnostic_cleanup
agents/recruitment/sourcing-scout/agent.md:196:     (concept referenced by autosend-policy.yaml red-tier
agents/recruitment/sourcing-scout/agent.md:197:     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
agents/recruitment/sourcing-scout/agent.md:250:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:365:| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:220:- Inside: `_voice/`, `_playbooks/`, `_decisions/`, `candidates/`, `clients/`, `opportunities/`, `temp/` (if Temp tier active), `_config.yaml`.
docs/specs/ULTRAPLAN.md:255:### 5.4 The Sovereign tier (v2.0)
docs/specs/ULTRAPLAN.md:257:Per the sovereign compute plan. Sovereign-tier tenants run on a dedicated slice of the Mac Studio cluster, with inference routed exclusively to local hardware. Their vault may be mirrored to local NVMe on the cluster nodes rather than the shared Hetzner volume. This is a deployment configuration, not a code path — same agent bundles, different physical placement.
docs/specs/ULTRAPLAN.md:268:1. Update `tenants.tier` column.
docs/specs/ULTRAPLAN.md:269:2. Run `pm2-ecosystem-generate.sh {slug}` again — adds the new tier's agents to the process group.
docs/specs/ULTRAPLAN.md:319:- The growing corpus is the SFT seed for the Scale-tier LoRA adapter at v2.0.
docs/specs/ULTRAPLAN.md:356:**Layer 4 — The Scale-tier LoRA upgrade (v2.0).**
docs/specs/ULTRAPLAN.md:361:2. Train a LoRA adapter (rank 8–16) on a base model — Qwen3 70B for the cluster, or Claude/Anthropic API with similar fine-tuning if cloud-tier.
docs/specs/ULTRAPLAN.md:365:The LoRA improves voice score from ~80% (RAG + scaffolding) to ~90%+. This is what justifies the Scale tier at £6,950/mo.
docs/specs/ULTRAPLAN.md:471:Agent name + tier
docs/specs/ULTRAPLAN.md:719:Targets: 3 paid pilots by end of Q3 2026 (per the internal business plan). v1.0 = the six v1.0 agents shippable in the Starter and Boutique tiers; Growth/Scale defer to v1.1.
docs/specs/ULTRAPLAN.md:798:3. Sovereign-tier setup (deferred to v2.0 regardless)
docs/specs/ULTRAPLAN.md:800:5. Cash Conductor's escalation-tier-3 (bad debt write-off draft) — manual until 6 months in
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:101:    action_type: diagnostic_report_render
docs/operations/codex-round-2-handoff.md:64:## §3 — Round-2 queue (3 tiers)
docs/operations/codex-round-2-handoff.md:77:| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
docs/operations/codex-round-2-handoff.md:87:**Likely outcomes:** 11-12 of 14 RATIFY. Items #6 (autosend tier contradiction) and #14 (PII retention) are founder-decision-bound (D1/D3); Codex may RATIFY-with-advisory or REJECT pending decisions.
docs/operations/codex-round-2-handoff.md:107:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | `review-architecture-decision` | RATIFY (Proposed spec; alternatives weighed; ratifies cortextOS primitive-4 reuse) |
docs/operations/codex-round-2-handoff.md:139:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-handoff.md:161:across 3 tiers.
docs/operations/codex-round-2-handoff.md:168:  review, tenant lifecycle, founder decision briefing, 2 disagreement docs, autosend
docs/operations/codex-round-2-handoff.md:211:  docs/decisions/autosend-safety-policy.md
docs/operations/codex-round-2-handoff.md:231:  docs/decisions/autosend-approval-bridge-spec.md  (review-architecture-decision)
docs/operations/codex-round-2-handoff.md:288:**Sub-case 2a: Same issue as Round 1** — incorporation didn't actually fix the root cause. Escalate to founder; reopen as a fresh issue. Likely candidates: autosend-safety-policy (D1 + D3 unresolved); v0.2 supplement (D3 unresolved).
agents/recruitment/diagnostic/tools.yaml:15:tier: 2  # request-driven; no persistent PTY (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/tools.yaml:170:  - bullhorn       # Diagnostic is sales-tool tier; no ATS touch per sequencing-target.md §2.1
agents/recruitment/diagnostic/agent.md:74:- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
agents/recruitment/diagnostic/agent.md:75:- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
agents/recruitment/diagnostic/agent.md:129:     — tier: green per autosend-policy.yaml (no external send; vault write only)
agents/recruitment/diagnostic/agent.md:134:     → tier: green (operator-only Telegram; no customer-facing comms)
agents/recruitment/diagnostic/agent.md:146:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
agents/recruitment/diagnostic/agent.md:161:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:183:- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
agents/recruitment/diagnostic/agent.md:248:2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
agents/recruitment/concierge/README.md:14:The customer-comms agent. Highest-stakes v1.0 agent (XL complexity, 4 weeks build). 12 lifecycle events × 2 recipient roles = 24+ comms-template variants per tenant. Orange-tier autosend per `autosend-safety-policy.yaml` — consultant approval mandatory before send.
agents/recruitment/concierge/README.md:20:- `tools.yaml` — Bullhorn R+W + Microsoft Graph + Gmail + voice classifier + autosend bridge (per D1 outcome)
agents/recruitment/concierge/README.md:35:**Founder Decision D1 (autosend orange-tier path) MUST be resolved before W10 build starts.** Per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Three options:
agents/recruitment/concierge/README.md:38:- D1-C: no autosend; manual consultant pickup (0 dev; ships fastest but worst UX)
docs/operations/codex-round-2-remediation-prompt.md:238:  FIX 8 — autosend-approval-bridge-spec.md category mapping rewrite
docs/operations/codex-round-2-remediation-prompt.md:240:  File: docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-remediation-prompt.md:243:  Issue 2: new autosend_approval_mappings table not added to
docs/operations/codex-round-2-remediation-prompt.md:266:         new autosend_approval_mappings table as the 10th tenant-data
docs/operations/codex-round-2-remediation-prompt.md:297:  FLAG 1 — autosend-safety-policy.md tier contradiction
docs/operations/codex-round-2-remediation-prompt.md:302:  > tier semantics in this document define orange as approval-gated. §9
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
agents/recruitment/concierge/agent.md:3:**Status:** Proposed (Day-19 pre-W10-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice).
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier (`gmail_outlook_send_to_candidate` or `bullhorn_note_customer_visible` depending on channel per autosend-policy.yaml lines 122-149). Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is a Gate B leading metric (warning + aggregated; NOT a Gate A hard-fail) per the same ULTRAPLAN line — making it a hard-fail would block legitimate delayed drafts caused by Bullhorn polling fallbacks. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:67:One output per lifecycle event: an email draft (orange tier). 12 lifecycle events × per-tenant comms-template variants:
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
agents/recruitment/concierge/agent.md:104:The actual SEND is a separate orange-tier action_type:
agents/recruitment/concierge/agent.md:105:- `gmail_outlook_send_to_candidate` (per autosend-policy.yaml line 130) when channel=email
agents/recruitment/concierge/agent.md:110:Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
agents/recruitment/concierge/agent.md:179:     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
agents/recruitment/concierge/agent.md:180:   → else: escalation_position=1 (standard orange tier)
agents/recruitment/concierge/agent.md:201:     tier=yellow per autosend-policy.yaml
agents/recruitment/concierge/agent.md:223:      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
agents/recruitment/concierge/agent.md:224:    → per autosend-policy.yaml: orange-tier; consultant approves
agents/recruitment/concierge/agent.md:227:12. (After operator approval) Send execution — orange-tier
agents/recruitment/concierge/agent.md:264:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:310:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:313:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
agents/recruitment/concierge/agent.md:319:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:357:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
agents/recruitment/concierge/agent.md:365:| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
agents/recruitment/concierge/agent.md:390:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
docs/operations/codex-ratification-execution-plan.md:130:| 8 | autosend-safety-policy | `docs/decisions/autosend-safety-policy.md` | A |
docs/operations/codex-ratification-execution-plan.md:167:| 25 | autosend-policy.yaml | `agents/_shared/autosend-policy.yaml` | A |
docs/operations/seedlegals-engagement-queries.md:68:> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
docs/operations/seedlegals-engagement-queries.md:78:> 6. **Dispute forum:** English courts; tier 1 = direct negotiation between founders; tier 2 = LCIA mediation if unresolved 30 days.
docs/specs/PRODUCT-SPEC.md:17:Intel Force OS is the always-on operating system for UK recruitment agencies. It runs on CortexOS as the persistent agent runtime, lives inside each firm's existing stack (Bullhorn / Vincere / Voyager Infinity, Xero / Sage, Microsoft 365 / Google Workspace), and ships as two coordinated product lines — **IntelForce Recruit** for the front office and **IntelForce Temp** for the back office. Together they replace the operational drag of an entire junior team and, more importantly, generate revenue: surfaced BD opportunities, intercepted competitor briefs, faster cash collection, dormant-candidate reactivation, and post-placement nurture that compounds into referrals. The firm pays £499–£6,950/month per front-office tier and a separate £1,950–£5,950/month for the temp sub-platform. Every agent is pitched against a single, quantified outcome the buyer can verify within 90 days. Configuration scales because the moat is the per-vertical schema, not per-customer plumbing — onboarding becomes a 5-day wizard, not a 5-week project.
docs/specs/PRODUCT-SPEC.md:35:We lead with revenue because that's what gets the contract signed at a £3,250/mo Growth tier. Time savings close the deal at Solo (£499/mo). Both numbers are quantified in the agent spec; both are measured in the customer's first 90 days.
docs/specs/PRODUCT-SPEC.md:61:- **Tier availability** — which subscription tier unlocks it
docs/specs/PRODUCT-SPEC.md:116:- **Tier availability:** All tiers including Solo. This is the data spine.
docs/specs/PRODUCT-SPEC.md:135:- **Per-tenant config:** client portfolio scope, signal-weighting overrides, account-team routing rules, escalation thresholds per client tier (key account vs occasional).
docs/specs/PRODUCT-SPEC.md:140:- **Revenue story:** "Your sourcing runs become 3× more productive against clean data. One reactivated dormant-but-clean candidate per month covers the tier price." Plus: removes the compliance liability of stale records.
docs/specs/PRODUCT-SPEC.md:234:## 3. The revenue case — pinned per tier
docs/specs/PRODUCT-SPEC.md:245:| **Scale** (26–50 fee earners) | £6,950 | All Growth + per-firm LoRA adapter + Sovereign-tier inference (UK on-prem) + priority support | "Half a junior recruiter replaced per consultant in operational drag. Per-firm voice that's genuinely indistinguishable from your top performer. £820k–£1.4M of demonstrable annual value created." |
docs/specs/PRODUCT-SPEC.md:293:       │     per-firm LoRA adapter → Scale-tier moat              │
docs/specs/PRODUCT-SPEC.md:357:- `common-client.json` — firm slug, legal name, primary contact, tier, sovereign-vs-cloud preference
docs/specs/PRODUCT-SPEC.md:374:- **Per-customer compute cost: ~£200/month for full Tier 1 deployment** (per the CortexOS directive's unit-economics work). At Boutique £1,495/mo this is 13% COGS; at Growth £3,250/mo this is 6%; healthy at every tier above Solo's three-agent gate.
docs/specs/PRODUCT-SPEC.md:382:3. **"Genuinely new feature — let me see how many other customers want this."** This goes on the roadmap. We never build it for one customer unless they pay materially extra for it (typically Scale-tier customers only). ~15% of the time.
docs/specs/PRODUCT-SPEC.md:421:- **Sovereign tier:** inference routed to the on-prem Mac Studio cluster (per the sovereign compute plan); cloud APIs (Anthropic, Moonshot) handle non-Sovereign tiers and overflow.
docs/specs/PRODUCT-SPEC.md:422:- **Per-firm LoRA adapter (Scale tier only):** trained on cloud GPUs, served from the cluster at inference time.
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:434:**3. The single ROI promise per tier is pinned.** Previous docs had pricing and had value modelling but the "single sentence the salesperson uses" was scattered. Section 3 fixes this.
docs/specs/PRODUCT-SPEC.md:457:- **No three-year contracts in v1.** Six and twelve-month terms with auto-renewal. Three-year is a Stage 5 lever once Sovereign tier exists and the data-sovereignty story is the close.
docs/specs/PRODUCT-SPEC.md:478:Six agents. The Solo tier is fully shippable. The Boutique tier is fully shippable. Growth and Scale come in v1.1.
docs/specs/PRODUCT-SPEC.md:495:The Growth tier becomes fully shippable. Compliance Core SKU launches.
docs/specs/PRODUCT-SPEC.md:505:Scale tier becomes fully shippable. Full Temp Sub-Platform launches.
docs/specs/PRODUCT-SPEC.md:511:- The per-firm LoRA adapter pipeline (Scale tier unlock)
docs/specs/PRODUCT-SPEC.md:512:- The Sovereign-tier on-prem cluster (Scale tier unlock)
docs/_supplementary/PRD-autonomous-agent.md:2007:- [ ] Install dev tools: `npm i -D vitest @vitest/coverage-v8 eslint prettier`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:35:Option C — **Hybrid:** v0 Gate A = per-section (current); Gate B (post-launch quality signal) = per-claim spot-check sampling. Document this two-tier policy explicitly.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:73:**My recommendation:** **B** — cleaner, avoids sentinel proliferation. Feedback events are conceptually Diagnostic's domain (they validate Diagnostic outputs), so the agent_name should be Diagnostic with a specific action_type marker.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:91:3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:130:4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:146:- Sentinel hygiene (Issue 4) is a real architectural concern; agent_name=agent + payload.action_type is the cleaner pattern; no reason to proliferate sentinels.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:159:1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:160:2. **`bullhorn_field_backfill` unregistered, would fail-safe to red:** my flag-for-addition framing didn't satisfy because `hook-helpers.sh::autosend_policy_lookup` fails to red on unknown action types AT RUNTIME, regardless of flag prose. Real bug requires either (a) policy row added BEFORE ratification, OR (b) explicit "blocked W5 prerequisite" framing not "executable output."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:174:3. Founder approves: (a) catalogue extensions (escalation-codes + autosend-policy batch additions), (b) schema field corrections, (c) §5/§6/§7 prose standardisation pattern (15 min)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:227:| Round 7 | 4 | 23 | All different from R6 — many caused BY R6 fixes (added action_types without registering) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:257:- Cat-2 (decision-log calls): added hh_decision_output / hh_decision_action calls across all §4 sections; pre-registered action_types via Phase 1
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:261:- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:387:5. §6 says only one action_type but cycle.sh now has operator_notify_telegram (Round-9 introduced by Cat-δ commit) — Cat-α; align §6
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:120:- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:11:## D1 — Auto-send v1.0 tier enforcement (orange-tier behavior)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:16:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:18:**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
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
docs/_supplementary/execution-plan.md:84:- [ ] **C1e.** Pricing lock: confirm the four tiers in Strategic Plan §8.3 are the ones you go to market with, or adjust now.
docs/_supplementary/execution-plan.md:136:  - *Purpose:* JSON schema for what the wizard collects to configure this agent per tenant (pricing framework, sales lead email, sign-off block, tier thresholds, disqualifiers).
docs/_supplementary/execution-plan.md:303:  - *Prompt:* "Write the Cost & Billing System Engineering Specification per Build Plan §27: the Anthropic API metadata tagging pattern for per-tenant attribution, the third-party API cost tracking table schema, the infra cost allocation formula, Stripe subscription setup (price IDs per tier, metered overages, setup fees as one-off invoices), the dashboard view that shows clients their current usage against allowance, the operator view that shows gross margin per tenant + anomaly detection."
docs/_supplementary/execution-plan.md:421:- [ ] **5.4 — Terms of Service (self-serve tier)**
docs/_supplementary/execution-plan.md:437:  - *Prompt:* "Write the IntelForce AI OS Pricing Page Copy: four tiers (Starter, Growth, Scale, Enterprise) with the exact price, the 'what's included' bullet list, the addons table, the FAQ section (10 questions), the comparison table, the 'not sure which tier?' CTA → audit call. Tone: confident, specific, never needs to shout. UK English."
docs/_supplementary/execution-plan.md:503:  - *Prompt:* "Write the Monitoring & Alert Playbook: every alert the observability stack fires, with for each: the condition that triggers it, the likely root causes, the diagnostic commands, the resolution steps, the escalation rules. Organise by severity tier."
docs/_supplementary/strategic-plan.md:69:| Pricing | $5–15k + retainer | £3–20k + retainer (tiered, transparent) |
docs/_supplementary/strategic-plan.md:166:│   - Heavy reasoning: Claude Opus 4.7 (reserved tier)       │
docs/_supplementary/strategic-plan.md:351:- [ ] **Dev**: Stripe subscriptions wired to dashboard tiers
docs/specs/_archive-build-handoff.md:188:See `docs/PRODUCT-SPEC.md` — the agent suite, output contracts, tier mapping.
docs/specs/_archive-build-handoff.md:273:- The full categorical list of what may auto-send vs what is draft-only per tier
docs/specs/_archive-build-handoff.md:293:- Timesheet (Temp tier only)
docs/specs/_archive-build-handoff.md:373:Per Ultraplan §9, v1.0 ships six agents in the Starter and Boutique tiers. In order:
docs/specs/_archive-build-handoff.md:380:| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/_supplementary/technical-strategy-v2.md:63:- **Opus 4.7** — SOP Writer (complex extraction from Loom), reserved tier — only when the output visibly needs it
docs/_supplementary/technical-strategy-v2.md:130:Keep both in the back pocket for a future "IntelForce Cloud" tier where you can charge a premium for fully-managed scheduled execution with no client infrastructure.
docs/_supplementary/technical-strategy-v2.md:431:Pricing: £5k setup + £1.5k/mo (they lean content-heavy so the Marketing trio plus Reporting Engine plus Client Onboarder is the core value). Some will go Growth tier for the full 9.
docs/_supplementary/technical-strategy-v2.md:439:Build this as a formal tier: **Agency Partner**.
docs/_supplementary/technical-strategy-v2.md:460:### 5.4 Revised ICP tiers
docs/_supplementary/technical-strategy-v2.md:576:- **Enterprise tier:** the Rigby Group / government-adjacent pitch is where OpenClaw as *infrastructure* makes sense. SCC won't deploy on Claude Code; they'll deploy on a governance-wrapped orchestration layer that happens to route to Claude models. That's the OpenClaw story.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:30:- **Without Sub-decision A answered, Week-3 Bullhorn-MCP work is structurally blocked:** we don't know whether marketplace registration is required for production OR whether direct-tier developer-program access suffices.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:25:- `agents/_shared/hook-helpers.sh` + `autosend-policy.yaml` (Phase 3, commit `e6e9df1`)
docs/decisions/bullhorn-integration-path.md:19:**Sub-decision A — Bullhorn integration path.** Marketplace partner programme membership (with its access tier, scope, certification, ongoing fees) versus direct API access (per-tenant Bullhorn-account-admin authorisation of IFOS as a connected app). Master brief §6 Day 2 line 466 explicitly names this as the day's decision. The path chosen determines whether `packages/mcp-connectors/bullhorn/` ships as a marketplace-registered connector or a direct-API connector — the *code* in either case is similar OAuth + REST plumbing, but the *operational, commercial, and rate-limit* surfaces differ materially.
docs/decisions/bullhorn-integration-path.md:59:- Whether Intel Force Ltd is currently a member of the **Bullhorn Marketplace Partner Programme** (or what the application timeline + cost would be). The marketplace partner application process is publicly known to involve a technical review, security audit, and ongoing partner fees — but the specifics for IFOS's tier and tenant volume are commercial-confidential and need a direct conversation.
docs/decisions/bullhorn-integration-path.md:60:- Whether **marketplace-tier API access differs from direct-API access** in rate limits, available scopes (e.g. write to JobOrder, write to Note, webhook subscription), or sandbox availability. Bullhorn's public docs are sparse on the deltas; partner reps know the actuals.
docs/decisions/bullhorn-integration-path.md:61:- Whether the marketplace-tier cost structure works at IFOS's volume (3-6 tenants v1.0; 100 by end of 2027 per Product Spec §5.4 line 369-373). Partner fees may be flat or per-tenant; this matters at scale.
docs/decisions/bullhorn-integration-path.md:69:| A | "What are the API rate-limit / scope deltas between marketplace tier and direct API at our expected 3-6 tenant pilot volume?" | Same Bullhorn partnerships team, or escalation to developer support | Same conversation | The answer determines whether direct-API can serve v1.0 or marketplace registration is a v1.0 blocker |
docs/decisions/bullhorn-integration-path.md:116:- `https://www.bullhorn.com/become-a-partner/` — landing page. Main CTA: **"Fill out the form to learn more about our partner programs."** References three external resources (FAQs, Bullhorn Developer Program, Fair Use Policy) but the page itself contains **no specific information** on application process, tiers, certification, security review, fees, ongoing costs, or timeline. The only substantive description on the page is: **"The Bullhorn Marketplace gives our customers the choice, confidence, and customization they need to innovate with agility."**
docs/decisions/bullhorn-integration-path.md:123:- There is a separately-named **Bullhorn Developer Program** distinct from the Marketplace partner programme (linked from `/become-a-partner/`) — implying a possible two-tier structure: developer-tier access to APIs (lighter) vs marketplace-listed partner (heavier).
docs/decisions/bullhorn-integration-path.md:128:- Whether the programme has tiers (e.g. Standard / Premier / Strategic) and what gates each tier.
docs/decisions/bullhorn-integration-path.md:129:- Whether marketplace-tier partners get different API scope, rate-limit ceilings, or webhook access vs direct-API/developer-tier.
docs/decisions/bullhorn-integration-path.md:150:- **client_id / client_secret acquisition.** Bullhorn doc verbatim: **"Bullhorn customers can obtain OAuth keys for developing applications...by creating a support ticket via the Bullhorn Resource Center."** This is not a self-service developer signup — there is a Bullhorn-side gate even for the developer-tier path. Implication: every IFOS pilot tenant must open a support ticket with Bullhorn to authorise IFOS as a connected app, or IFOS must hold a single set of client credentials at the IFOS-application level and route per-tenant auth through it. The structural distinction here is exactly what Sub-decision A pivots on — partnerships@bullhorn confirms whether marketplace status grants application-level credentials.
docs/decisions/bullhorn-integration-path.md:167:| Per-tenant onboarding friction (admin auth, scope review) | **CG.** If marketplace tier grants IFOS application-level credentials, per-tenant friction may reduce to "tenant clicks Authorise from marketplace listing." | Each pilot tenant raises a Bullhorn support ticket + tenant admin authorises IFOS as a connected app via per-tenant OAuth screen. Per-tenant friction: 1 support ticket + 1 OAuth dance per pilot tenant. |
docs/decisions/bullhorn-integration-path.md:169:| Cost at 3-tenant pilot scale (2026 H2, Boutique tier per Product Spec §3.1) | **CG.** Public docs do not name partner fees. Inference based on comparable enterprise SaaS marketplace programmes: annual partner fee typically $5K-$25K + possibly per-listing or per-referral revenue-share. | **CG.** Public docs do not name developer-program fees. Inference: likely zero or nominal for the developer-tier API access. Per-tenant cost zero — the tenant pays Bullhorn, IFOS pays nothing per call. |
docs/decisions/bullhorn-integration-path.md:170:| Cost at 100-tenant target scale (Product Spec §5.4 end-2027 target) | **CG.** May or may not scale linearly with tenant count. Some marketplace programmes have flat annual fees; others meter on tenant or revenue volume. | **CG.** If developer-tier cost is zero or nominal, scales fine. Risk: per-tenant Bullhorn support tickets at 100 tenants become operational drag at IFOS-Customer-Success layer (Product Spec §5.4 line 373 names ≤8 hours of human time per customer onboarding — Bullhorn ticket may consume a meaningful fraction). |
docs/decisions/bullhorn-integration-path.md:171:| Scope / rate-limit deltas | **CG.** Marketplace tier may grant elevated rate limits, write access to additional entities (e.g. JobOrder write), webhook subscription endpoints not available to direct-tier. Public docs do not state. | Public REST API documentation lists all REST endpoints uniformly — no tier-gated endpoints stated in public docs. Inference: all entity reads/writes are available to authenticated direct-tier callers, subject to per-corpToken scope at the tenant-account-admin level. Rate limit ceiling **CG**. |
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:191:| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
docs/decisions/bullhorn-integration-path.md:242:- **Bullhorn sandbox tier** (if it exists — §2.2 noted sandbox availability is not publicly documented and is commercially gated). If Bullhorn offers a sandbox, the auth model against it is presumed identical to production: authorization-code grant. Just a different `loginInfo` cluster.
docs/decisions/bullhorn-integration-path.md:244:**Spec gap §3.2-A:** confirm with Bullhorn developer support whether (a) client_credentials is genuinely unsupported, or (b) it exists for specific partner-tier use cases not documented publicly. If (b), this changes the dev-loop ergonomics. Mark as **CG**.
docs/decisions/bullhorn-integration-path.md:261:2. **It composes with the §1.4 fallback architecture and §2.4 Sub-decision A recommendation.** The auth-code flow works identically against direct-API and marketplace-tier (only the `loginInfo` cluster and client_id may differ). The auth module's job is the per-tenant browser-dance kickoff and refresh-token persistence; both are path-independent.
docs/decisions/bullhorn-integration-path.md:266:- Confirm authorization-code grant is the correct production path (i.e. Bullhorn doesn't have a marketplace-tier-only managed-auth path that bypasses the browser dance).
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:300:**Implication:** Bullhorn's public-tier REST API is **pull-only**. IFOS must poll for change detection at v1.0 unless commercial verification reveals a partner-tier event-subscription mechanism. **Commercially gated: §4.2-A** — confirm with Bullhorn developer support whether webhook/event-subscription capabilities exist at marketplace/partner tier that are not documented in the public REST docs.
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:313:**v1.1+ upgrade path:** if Sub-decision A commercial verification reveals marketplace-tier event subscriptions, Concierge upgrades from 5-minute polling to webhook-primary with polling fallback. The polling cycle becomes a heartbeat-style consistency check. No agent-bundle-content changes; only `tools.yaml` MCP scope declaration and the connector's auth/subscription module.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:470:- **Webhook / event-subscription model** — deferred to v1.1+ pending Sub-decision A commercial verification (whether marketplace tier grants subscription endpoints not in public REST docs).
docs/decisions/bullhorn-integration-path.md:510:| §3.2-A: assume `client_credentials` genuinely unsupported (not partner-tier-only) | Bullhorn dev support reveals partner-tier-only support — dev-loop ergonomics improve; production path unchanged |
docs/decisions/bullhorn-integration-path.md:511:| §4.2-A: assume v1.0 pull-only (no webhook coverage) per public REST docs | Sub-decision A commercial verification reveals marketplace-tier event subscriptions — Concierge upgrades to webhook-primary in v1.1+ |
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:66:| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:82:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:95:| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:99:| 6 | `docs/decisions/autosend-approval-bridge-spec.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:185:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:290:| 16 | `autosend-safety-policy.md` §10 pilot-agreement liability | Placeholder — legal review required before first pilot LOI | Pre-LOI legal review (commercial / regulatory). Codex can ratify the placeholder shape but cannot substitute for legal counsel. |
docs/operations/codex-round-2-autonomous-prompt.md:38:  - The 26 artefacts in 3 tiers (§3)
docs/operations/codex-round-2-autonomous-prompt.md:73:STEP 3 — Ratify 26 artefacts in 3 tiers (~6h)
docs/operations/codex-round-2-autonomous-prompt.md:97:For autosend-safety-policy.md (Tier 1 item #6) and v0.2 supplement (item 
docs/operations/codex-round-2-autonomous-prompt.md:118:  ## §2 — Per-tier per-artefact table
docs/operations/codex-round-2-autonomous-prompt.md:253:4. **DO NOT make founder decisions.** Items like D1 (autosend orange tier), 
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:45:Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
docs/decisions/autosend-safety-policy.md:49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
docs/decisions/autosend-safety-policy.md:73:## §3 — Examples per tier across the v1.0 agent surface
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:79:| Agent | action_type | Why green |
docs/decisions/autosend-safety-policy.md:90:| Agent | action_type | Sample rate | Why yellow |
docs/decisions/autosend-safety-policy.md:100:| Agent | action_type | Why orange |
docs/decisions/autosend-safety-policy.md:115:| action_type | block_reason | Why red |
docs/decisions/autosend-safety-policy.md:143:#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
docs/decisions/autosend-safety-policy.md:148:  local action_type="$1"
docs/decisions/autosend-safety-policy.md:157:  # 1. Policy lookup — read tier from the canonical policy table
docs/decisions/autosend-safety-policy.md:158:  local tier
docs/decisions/autosend-safety-policy.md:159:  tier=$(autosend_policy_lookup "$action_type") || {
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:161:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
docs/decisions/autosend-safety-policy.md:166:  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:168:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:173:  case "$tier" in
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
docs/decisions/autosend-safety-policy.md:198:      # Fail-safe: unknown tier → red
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
docs/decisions/autosend-safety-policy.md:219:action_types:
docs/decisions/autosend-safety-policy.md:222:  - bullhorn_note_draft_internal     # yellow (sample 1-in-10)
docs/decisions/autosend-safety-policy.md:229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
docs/decisions/autosend-safety-policy.md:240:**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
docs/decisions/autosend-safety-policy.md:245:  "action_type": "<enum from autosend-policy.yaml>",
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:259:2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:283:**Fires when:** a red-tier action is invoked; blocked unconditionally
docs/decisions/autosend-safety-policy.md:288:  "action_type": "<enum>",
docs/decisions/autosend-safety-policy.md:292:  "block_reason": "<enum: red_tier_classification | blocked_recipient | unauthorized_adapter | cross_tenant_violation | payment_action | billing_modification | legal_artefact | pii_geographic_breach>",
docs/decisions/autosend-safety-policy.md:300:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
docs/decisions/autosend-safety-policy.md:301:2. `autosend_escalate ESC_AUTOSEND_BLOCKED` notifies tenant operator informationally (no action required)
docs/decisions/autosend-safety-policy.md:302:3. Operator may file a `false-block` feedback report via Brain UI if the tier classification seems wrong; report becomes input to next policy review
docs/decisions/autosend-safety-policy.md:304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
docs/decisions/autosend-safety-policy.md:314:Block reason: payment_action (red-tier; never auto-sent in v1.0)
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
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:430:  'autosend_policy',
docs/decisions/autosend-safety-policy.md:432:    "tier_overrides": {
docs/decisions/autosend-safety-policy.md:433:      "bullhorn_note_internal": "yellow",
docs/decisions/autosend-safety-policy.md:461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
docs/decisions/autosend-safety-policy.md:462:2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
docs/decisions/autosend-safety-policy.md:466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:481:- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
docs/decisions/autosend-safety-policy.md:493:- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
docs/decisions/autosend-safety-policy.md:495:- **Pre-action policy simulation:** Brain UI feature — operator types proposed action; system shows tier, override impact, approval routing, expected resolution time. Reduces accidental tier-aware design.
docs/decisions/autosend-safety-policy.md:510:docs/decisions/autosend-safety-policy.md in the IFOS code repository)
docs/decisions/autosend-safety-policy.md:511:classifies each agent action into one of four tiers: green, yellow,
docs/decisions/autosend-safety-policy.md:522:  (b) any action classified as yellow that passed spot-check review or
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:527:      that elevates or otherwise alters the policy default tier
docs/decisions/autosend-safety-policy.md:536:      tier;
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:555:payload.policy_version_sha field. Material changes to tier classification
docs/decisions/autosend-safety-policy.md:596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
docs/decisions/autosend-safety-policy.md:603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
docs/decisions/autosend-safety-policy.md:622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
docs/decisions/autosend-safety-policy.md:624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:109:**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
docs/decisions/v1.0-kill-criterion.md:111:**Owner:** IFOS oncall + tenant operator. Daily check via `decision_log` queries: `SELECT COUNT(*) FROM decision_log WHERE phase='gating_failed' AND payload->>'tier'='red' AND payload->>'block_reason'='red_tier_classification' AND tenant_slug=? AND created_at > NOW() - INTERVAL '7 days'`.
docs/decisions/v1.0-kill-criterion.md:113:**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
docs/decisions/v1.0-kill-criterion.md:115:**Action:** PAUSE for the affected pilot. The agent that produced the miscategorisations halts at next session boundary. Founder + Jack review the policy tier classifications within 48 hours. Policy revision (via Codex ratification) lands as a new commit; affected pilot receives incident report. Pilot resumes after policy revision.
docs/decisions/v1.0-kill-criterion.md:117:**Escalation path:** If three pilots experience this trigger within one quarter, escalate to system-wide PAUSE while structural autosend policy redesign happens (potential v1.1 advancement of orange tier).
docs/decisions/v1.0-kill-criterion.md:121:**Threshold:** Cost-per-completed-action (defined as: total IFOS infrastructure + API + Claude inference cost ÷ count of `decision_log` rows with `phase='action'` and `payload.tier IN ('green','yellow','orange-approved')`) exceeds **£0.50 per action** after 4 tenant-weeks of operation.
docs/decisions/v1.0-kill-criterion.md:128:- Bullhorn API call at <£0.001 per action (free tier)
docs/decisions/v1.0-kill-criterion.md:136:**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
docs/decisions/v1.0-kill-criterion.md:188:**Threshold:** ANY confirmed incident in which agent action results in PII (personally-identifiable information per UK GDPR Art. 4(1)) transmitted to an unauthorised party (cross-tenant recipient, unauthorised external recipient, or recipient outside tenant's declared data residency) AND not blocked by the RLS + autosend policy combination.
docs/decisions/v1.0-kill-criterion.md:196:**Action:** KILL. Rationale: multi-tenant trust is the structural foundation of v1.0. A single confirmed PII breach beyond the RLS + autosend boundary indicates the foundation is unsound. Continuing operation risks (a) further breaches, (b) regulatory action, (c) catastrophic loss of pilot trust. Wind-down protects existing pilots from further exposure.
docs/decisions/v1.0-kill-criterion.md:224:- **Trigger 6 (Unit economics):** founder decides PIVOT direction (cheaper model tier, reduced agent frequency, etc.) → consults Jack on pricing implications before locking → updates Ultraplan pricing plan.
docs/decisions/v1.0-kill-criterion.md:235:**Must-fill before first pilot LOI signs.** The pilot agreement may reference an external advisor for dispute resolution per `autosend-safety-policy.md` §10 placeholder language. Founder identifies and engages within Weeks 1-2.
docs/decisions/v1.0-kill-criterion.md:337:- The autosend safety policy per this Day 5 commit (green + red tiers only)
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/decisions/v1.0-kill-criterion.md:387:**For atomic-correction manifest.** Edit 10 (shared with autosend-safety-policy.md) adds the path drift correction. Manifest grows from 9 to 10.
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
docs/_supplementary/build-plan-original.md:198:### 3.1 Three context tiers
docs/_supplementary/build-plan-original.md:291:- **Cognism MCP** — only for Agency Partner and Enterprise tiers (£20k+/year; bakes into their pricing, not yours)
docs/_supplementary/build-plan-original.md:406:3. Propose scope. Three tiers allowed MAX (Good/Better/Best). Don't invent new 
docs/_supplementary/build-plan-original.md:426:4. **Scope** (bullet list per tier if tiered, else flat). Specific deliverables.
docs/_supplementary/build-plan-original.md:428:6. **Investment** (clear price per tier, payment structure).
docs/_supplementary/build-plan-original.md:446:- Deal value in discussion >£50k (partner-tier decisions always human)
docs/_supplementary/build-plan-original.md:474:- Call transcript has no price discussion → produce proposal at the client's "standard" package tier, flag clearly
docs/_supplementary/build-plan-original.md:977:- **Ahrefs / SEMrush API** (paid, passed through to client — OR build against free DataForSEO tier for Tier 1)
docs/_supplementary/build-plan-original.md:1499:The Agency Partner tier is structured so you earn per sub-tenant:
docs/_supplementary/build-plan-original.md:1562:- OpenClaw migration path for Enterprise tier
docs/operations/goal-option-c-diagnostic-end-to-end.md:330:- Any external service requiring paid signup (Proxycurl, OpenAI tier, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:24:9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
docs/operations/goal-week-3-polish-and-scaffold.md:29:14. **`agents/_shared/autosend-policy.yaml`** (29 action types; tier classifications)
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **§1 Output contract:** reconciles invoices against bank deposits; chases overdue payments via approved orange-tier email drafts (consultant approves before send); writes payment status updates to accounting system; generates weekly cash-flow report to `/vault/<tenant>/cash-conductor-reports/`. No Bullhorn dependency — operates entirely against Xero / QuickBooks / Sage + Open Banking.
docs/operations/goal-week-3-polish-and-scaffold.md:368:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§8 Build prerequisites:** Bullhorn MCP read + LinkedIn integration (Proxycurl signup OR LinkedIn API partner-tier) + ranking model (LLM-based or embedding-based).
docs/operations/goal-week-3-polish-and-scaffold.md:409:#### Step 12 — `agents/recruitment/concierge/agent.md` (~3-4 hours; most complex due to autosend orange-tier)
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:414:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- `2026-05-20-codex-round-1-founder-decisions.md` §D1 (autosend orange-tier decision)
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:425:- **§5 Gate A:** validate.sh hard-fails on missing approval-bridge auth (if D1-A bridge), voice classifier <0.75, tone-rule block-severity hit, schema violation, orange-tier-spot-check sample selected.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/founder-legal-setup-guide.md:86:- **Ashfords LLP** (ashfords.co.uk) — tech sector group; mid-tier firm with startup-friendly hourly rates. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:220:> - All bounded by tier-based safety policies; high-risk actions require human approval; lowest-risk actions can be unsupervised
docs/operations/founder-legal-setup-guide.md:229:> Would you provide a quote? Happy to share more about our autosend-safety-policy on a call.
docs/operations/founder-legal-setup-guide.md:245:On that page, click through to the self-assessment tool. You'll answer a few questions, pick the right tier (small SaaS = tier 1 typically; £52/year as of 2026), and pay online. Save the confirmation as `docs/operations/ico-registration-2026-05-XX.md`.

exec
/bin/zsh -lc "rg -n \"location|current_role_title|notice_period_weeks|salary_expectation_min|salary_expectation_max|employment_type|key_skills|seniority|decision_authority|preferred_channel|next_action_target_date|salary_min|salary_max|start_date|role_type|must_haves|nice_to_haves|deal_breakers|placement_status|week_1_status_note|satisfaction_signal|sector|headcount_growth_signal_text|hiring_velocity_band|decision_window_text|Brief|Opportunity|Placement|Candidate|Contact\" docs/verticals/recruitment -g '*.yaml' -g '*.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:15:# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:16:# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:55:      employment_type:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:60:          Candidate's preferred engagement model (distinct from role type).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:68:      key_skills:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:100:      preferred_channel:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:106:          Contact's stated preference; extracted by Scribe from call context.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:113:      next_action_target_date:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:127:      must_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:141:      nice_to_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:153:      deal_breakers:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:168:      placement_status:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:203:      satisfaction_signal:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:218:      headcount_growth_signal_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:231:      hiring_velocity_band:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:244:      decision_window_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:277:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:278:#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:279:#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:282:#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:343:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:383:    # Scribe's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:384:    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:392:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:394:    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields written to IFOS-cached Postgres rows only (Bullhorn Opportunity endpoint NOT used at v1.0 per integration-path §4.1)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:395:    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:430:    # Concierge's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:431:    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:439:    opportunity: R         # IFOS-cached read; outbound lifecycle-event context (Bullhorn Opportunity endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:475:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:481:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:488:      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:493:      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:884:  Q1_employment_type_enum_completeness:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:885:    question: Are 6 employment_type enum values sufficient for UK recruitment?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:888:        Keep 6 values as in §1.candidate.employment_type — perm, contract,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:899:  Q2_key_skills_max_length:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:909:  Q3_placement_status_enum_lifecycle:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:910:    question: 6-state placement_status enum maps to Bullhorn's native state machine?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:914:      C: Add a mapping table (auxiliary) — placement_status_mapping with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:964:      the v0.3-added fields (employment_type, key_skills, preferred_channel,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:965:      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:966:      placement_status, week_1_status_vault_path, satisfaction_signal,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:967:      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:968:      are now schema-backed. (Note: week_1_status_note narrative now lives
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:970:      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:971:      seniority — not yet in schema; brief.start_date should be
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:972:      start_date_target; opportunity.sector — not yet in schema). These
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
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
docs/verticals/recruitment/vertical-schema.yaml:116:      salary_expectation_min:
docs/verticals/recruitment/vertical-schema.yaml:120:      salary_expectation_max:
docs/verticals/recruitment/vertical-schema.yaml:124:      location:
docs/verticals/recruitment/vertical-schema.yaml:127:        source: Bullhorn.Candidate.address.city
docs/verticals/recruitment/vertical-schema.yaml:128:        notes: Free-text city/region for v0.1. Structured location pending v1.1.
docs/verticals/recruitment/vertical-schema.yaml:133:      notice_period_weeks:
docs/verticals/recruitment/vertical-schema.yaml:149:      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:169:        source: Bullhorn.Candidate.id
docs/verticals/recruitment/vertical-schema.yaml:174:        source: Bullhorn.Candidate.firstName
docs/verticals/recruitment/vertical-schema.yaml:178:        source: Bullhorn.Candidate.lastName
docs/verticals/recruitment/vertical-schema.yaml:182:        source: Bullhorn.Candidate.email
docs/verticals/recruitment/vertical-schema.yaml:186:        source: Bullhorn.Candidate.mobile
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:285:      A person at a client company. Decision-makers, hiring managers, HR, procurement. Bullhorn calls this `ClientContact`. v1.0 representation is thin (10 fields); v1.1 Triage agent expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:286:    bullhorn_source: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:294:        source: Bullhorn.ClientContact.id
docs/verticals/recruitment/vertical-schema.yaml:298:        source: Bullhorn.ClientContact.firstName
docs/verticals/recruitment/vertical-schema.yaml:302:        source: Bullhorn.ClientContact.lastName
docs/verticals/recruitment/vertical-schema.yaml:306:        source: Bullhorn.ClientContact.email
docs/verticals/recruitment/vertical-schema.yaml:310:        source: Bullhorn.ClientContact.phone
docs/verticals/recruitment/vertical-schema.yaml:314:        source: Bullhorn.ClientContact.title
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:330:        source: Bullhorn.ClientContact.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:343:      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
docs/verticals/recruitment/vertical-schema.yaml:366:      role_type:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:376:      salary_max:
docs/verticals/recruitment/vertical-schema.yaml:388:      location:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:432:    bullhorn_source: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:441:        source: Bullhorn.Placement.id
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:
docs/verticals/recruitment/vertical-schema.yaml:445:        source: Bullhorn.Placement.dateBegin
docs/verticals/recruitment/vertical-schema.yaml:449:        source: Bullhorn.Placement.dateEnd
docs/verticals/recruitment/vertical-schema.yaml:455:        source: Bullhorn.Placement.status (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:460:        source: Bullhorn.Placement.employmentType (with mapping)
docs/verticals/recruitment/vertical-schema.yaml:464:        source: Bullhorn.Placement.fee
docs/verticals/recruitment/vertical-schema.yaml:469:        source: Bullhorn.Placement.feeArrangement (parsed)
docs/verticals/recruitment/vertical-schema.yaml:474:        source: Bullhorn.Placement.salary
docs/verticals/recruitment/vertical-schema.yaml:489:        source: Bullhorn.Placement.dateAdded
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:498:    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
docs/verticals/recruitment/vertical-schema.yaml:503:      - (v1.1) Brief Decoder — write submission events
docs/verticals/recruitment/vertical-schema.yaml:531:      - v1.0 schema captures shape for forward-compatibility but no v1.0 agent reads or writes Opportunity.
docs/verticals/recruitment/vertical-schema.yaml:532:      - v1.1 Brief Decoder + Inbound Triage agents exercise. Schema may revise based on v1.1 build needs.
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:644:    v1_0_exercise: None (Opportunity entity not v1.0-exercised).
docs/verticals/recruitment/vertical-schema.yaml:645:    v1_1_plus_notes: Brief Decoder + Inbound Triage primary readers.
docs/verticals/recruitment/vertical-schema.yaml:742:    bullhorn_entity: Bullhorn.Candidate
docs/verticals/recruitment/vertical-schema.yaml:748:    bullhorn_entity: Bullhorn.Candidate
docs/verticals/recruitment/vertical-schema.yaml:752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
docs/verticals/recruitment/vertical-schema.yaml:761:    bullhorn_entity: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:772:    bullhorn_entity: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:778:    bullhorn_entity: Bullhorn.JobSubmission (or Bullhorn.Opportunity depending on tenant configuration)
docs/verticals/recruitment/vertical-schema.yaml:780:    field_mapping_density: v0.1 covers 5 fields (placeholder shape); full Bullhorn field-density TBD pending v1.1 Brief Decoder / Inbound Triage build.
docs/verticals/recruitment/vertical-schema.yaml:781:    notes: Tenant-config dependent — some Bullhorn tenants use JobSubmission, some use Opportunity, some both. Adapter layer resolves at ingest.
docs/verticals/recruitment/vertical-schema.yaml:799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:847:    v0_1_decision: contact_works_for_client is N:1 (each contact at exactly one client). Contacts who change employer get a new contact entity per IFOS.
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:898:      Triage expansion (Q5 contact decision-authority granularity, Q10 panel hiring). Skill taxonomy decision (Q8). Multi-client contact decision (Q9). Umbrella company entity promotion candidate (Q7). Opportunity entity exercise begins.

exec
/bin/zsh -lc "rg -n \"Scribe|A3|week 6|90%|0\\.6|tacit|scribe|Trigger 3|Change 1|Change 2|§8\\.2|W6|Ringover|Fathom|Fireflies\" docs agents packages -g '*.md' -g '*.yaml' -g '*.yml' -g '*.sh'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:12:# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:15:# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:61:          IR35 distinction matters for UK contractors. Extracted by Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:63:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:65:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:78:        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:80:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:106:          Contact's stated preference; extracted by Scribe from call context.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:108:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:110:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:117:          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:120:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:122:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:136:        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:138:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:148:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:150:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:161:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:163:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:174:          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:177:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:179:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:186:        pattern: '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$'
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:190:          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:191:          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:197:        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:200:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:209:          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:211:        source: IFOS-derived (Scribe LLM extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:213:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:226:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:228:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:237:          Scribe LLM inference from prospecting-call urgency cues. Drives
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:239:        source: IFOS-derived (Scribe LLM classification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:241:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:251:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:253:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:277:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:279:#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:281:#     R-only for Scribe)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:282:#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:283:#   - Scribe timesheet: none → R (reads for placement-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:304:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:342:  #   Example: Scribe.candidate: R+W at entity level; per-field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:343:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:382:  scribe:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:383:    # Scribe's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:385:    # row A3. opportunity + timesheet access below is to IFOS-cached
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:386:    # Postgres rows ONLY (not direct Bullhorn endpoint calls). Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:389:    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:391:    client: R              # IFOS-cached read (Bullhorn endpoint A3 — ClientCorporation)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:392:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:395:    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:402:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:462:      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:467:      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:475:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:480:      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:488:      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:492:      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:494:      for Scribe.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:501:      - Scribe (R+W)       # v0.3 NEW — writes 3 new prospecting-call fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:508:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:515:      - Scribe (R+W)       # v0.3 NEW — check-in field extraction
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:520:      their §4 specs); adds Scribe R+W for check-in writes.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:526:      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:531:      Scribe + Concierge (each reads timesheet for their respective
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:539:      - Scribe (R+W)       # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:548:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:551:      - Scribe (R+W)       # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:561:    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:562:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:      §12 conversation opener; Janitor for tacit-note narratives; Cash
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:568:      granted Scribe + Concierge; v0.3 extends to all 6.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:571:    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:575:      applies_to_agents containing 'janitor' for tacit-note narrative
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:586:      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:587:      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:593:      for retraining queue). Janitor adds R for tacit-note harvest per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:689:    scribe: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:698:    scribe: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:707:    scribe: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:714:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:718:    scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:725:    scribe: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:732:    scribe: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:864:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:955:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:963:    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:969:      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:974:      they do not block v0.3 ratification but do require a Scribe agent.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:975:      consistency-pass before Scribe ratifies.
agents/_shared/voice-loader.sh:4:# §8.1 Change 1. Sourced by every agent's context.sh at session start; emits
agents/_shared/autosend-policy.yaml:43:    agent: scribe
agents/_shared/autosend-policy.yaml:83:  scribe_run_complete:
agents/_shared/autosend-policy.yaml:85:    agent: scribe
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:165:    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
agents/_shared/autosend-policy.yaml:170:    agent: scribe
agents/_shared/autosend-policy.yaml:196:  bullhorn_scribe_field_write:
agents/_shared/autosend-policy.yaml:198:    agent: scribe
agents/_shared/autosend-policy.yaml:200:    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
agents/_shared/autosend-policy.yaml:252:    agent: scribe
packages/utilities/web-scraper/pnpm-lock.yaml:118:    resolution: {integrity: sha512-0T+A9WZm+bZ84nZBtk1ckYsOvyA3x7e2Acj1KdVfV4/2tdG4fzUp91YHx+GArWLtwqp77pBXVCPn2We7Letr0Q==}
packages/utilities/web-scraper/pnpm-lock.yaml:256:    resolution: {integrity: sha512-KabT5I6StirGfIz0FMgl1I+R1H73Gp0ofL9A3nG3i/cYFJzKHhouBV5VWK1CSgKvVaG4q1RNpCTR2LuTVB3fIw==}
packages/utilities/web-scraper/pnpm-lock.yaml:298:    resolution: {integrity: sha512-SQPZOwoTTT/HXFXQJG/vBX8sOFagGqvZyXcgLA3NhIqcBv1BJU1d46c0rGcrij2B56Z2rNiSLaZOYW5cUk7yLQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:376:    resolution: {integrity: sha512-cXb5vApOsRsxsEl4mcZ1XY3D4DzcoMxR/nnc4IyqYs0rTI8ZKmW6kyyg+11Z8yvgMfAEldKzP7AdP64HnSC/6g==}
packages/utilities/web-scraper/pnpm-lock.yaml:394:    resolution: {integrity: sha512-8wZM2qqtv9UP3mzy7HiGYNH/zjTA355mpeuA+859TyR+e+Tc08IHYpLJuMsfpDJwoLo1ikIJI8jC3GFjnRClzA==}
packages/utilities/web-scraper/pnpm-lock.yaml:494:    resolution: {integrity: sha512-zzNR+SdQSDJzc8joaeP8QQoCQr8NuYx2dIIytl1QeBEZHJ9uW6hebsrYgbz8hJwUQao3TWCMtmfV8Nu1twOLAw==}
packages/utilities/web-scraper/pnpm-lock.yaml:718:    resolution: {integrity: sha512-RGwwWnwQvkVfavKVt22FGLw+xYSdzARwm0ru6DhTVA3umU5hZc28V3kO4stgYryrTlLpuvgI9GiijltAjNbcqA==}
packages/utilities/web-scraper/pnpm-lock.yaml:769:    engines: {node: ^8.16.0 || ^10.6.0 || >=11.0.0}
packages/utilities/web-scraper/pnpm-lock.yaml:858:    resolution: {integrity: sha512-GDhwkLfywWL2s6vEjyhri+eXmfH6j1L7JE27WhqLeYzoh/A3DBaYGEj2H/HFZCn/kMfim73FXxEJTw06WtxQwg==}
packages/utilities/web-scraper/pnpm-lock.yaml:1004:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:61:      - Scribe (R — voice samples for note-summary tone matching)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:128:      - Scribe (R — note format constraints)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:395:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:443:- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:79:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:84:     (used for tacit-note attribution) + recent edits (for note harvest)
agents/recruitment/janitor/agent.md:177:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:185:- No PII outside firm boundary in tacit-note narratives (regex pass)
agents/recruitment/janitor/agent.md:211:| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/janitor/agent.md:228:Step 8 (tacit-note narrative generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:237:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:263:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
packages/agent-renderer/templates/claude-md-preamble.md:20:Decision-log calls are mandatory per master brief §8.1 Change 2:
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:54:      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:119:        source: IFOS-derived (Scribe extraction; GBP annual)
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:136:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.yaml:159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
docs/verticals/recruitment/vertical-schema.yaml:196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
docs/verticals/recruitment/vertical-schema.yaml:692:  Scribe:
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:55:Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:131:5. **§5 honesty about validate.sh implementation** — agent.md §5 sections describe Gate A behaviour that may not be implemented in the corresponding `validate.sh`. For Diagnostic, validate.sh exists + has gaps (Issue 5). For the 5 new scaffolds, validate.sh DOESN'T exist yet — §5 describes intent. Disposition: explicitly mark "intended behaviour; cycle.sh + validate.sh implementation at W-X build will deliver this" in §5 of each pre-build scaffold.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:159:1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:274:| Scribe | 5 | `20260524T112917Z-82352` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:316:  - Scribe Steps 2-3, 7 partial coverage
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:372:| Scribe | 5 | 4 | −1 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:54:- **Webhook (v1.0 primary path):** per-provider HMAC / bearer token verified at the ingress per `tools.yaml` capability declarations (matching the Scribe webhook auth pattern).
agents/recruitment/cash-conductor/agent.md:56:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:88:| 4 | Fuzzy amount (±0.5% rounding) + matching payee name | 0.65 |
agents/recruitment/cash-conductor/agent.md:149:14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
agents/recruitment/cash-conductor/agent.md:296:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:308:**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/cash-conductor/agent.md:318:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:363:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:423:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:440:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:140:| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier (`gmail_outlook_send_to_candidate` or `bullhorn_note_customer_visible` depending on channel per autosend-policy.yaml lines 122-149). Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is a Gate B leading metric (warning + aggregated; NOT a Gate A hard-fail) per the same ULTRAPLAN line — making it a hard-fail would block legitimate delayed drafts caused by Bullhorn polling fallbacks. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:116:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:208:     (90% of drafts within 30 min) rather than per-draft hard fail (legitimate
agents/recruitment/concierge/agent.md:264:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:273:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
agents/recruitment/concierge/agent.md:277:**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/concierge/agent.md:344:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/concierge/agent.md:356:| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
agents/recruitment/scribe/README.md:1:# Scribe — directory README
agents/recruitment/scribe/README.md:3:**Status:** Proposed (Day-17 pre-W6-build scaffold).
agents/recruitment/scribe/README.md:14:Full bundle at W6 build (~1 week per ULTRAPLAN A3 line 526):
agents/recruitment/scribe/README.md:16:- `tools.yaml` — Bullhorn W + Fathom R + Fireflies R + voice classifier
agents/recruitment/scribe/README.md:18:- `validate.sh` — Gate A (≥3 fields × confidence ≥0.6 + voice ≥0.75 + PII boundary)
agents/recruitment/scribe/README.md:29:*End of Scribe README.*
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:18:**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
agents/recruitment/scribe/agent.md:1:# Scribe — the data spine
agents/recruitment/scribe/agent.md:3:**Status:** Proposed (Day-17 pre-W6-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice).
agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:7:**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
agents/recruitment/scribe/agent.md:8:**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:25:POST https://<tenant>.ifos.app/agents/scribe/webhook
agents/recruitment/scribe/agent.md:39:Each provider has its own webhook signature scheme (Fathom HMAC-SHA256; Fireflies bearer token; Ringover OAuth-protected). Auth handled per-provider in `tools.yaml` capability declarations.
agents/recruitment/scribe/agent.md:44:ifosctl scribe replay --tenant <slug> --call-id <provider-call-id>
agents/recruitment/scribe/agent.md:51:- Telegram command (`@ifos_bot scribe replay <call-id>`)
agents/recruitment/scribe/agent.md:80:Field names match canonical schema verbatim; some v0.1 fields (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `week_1_status_note`) are scheduled for v0.3 supplement at W6 build start — flagged here as pre-build references requiring schema-supplement landing before Scribe references them in `cycle.sh`. The Q1 verification pass (W6 Day 1) audits all field names against the schema as it exists then.
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:111:Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
agents/recruitment/scribe/agent.md:127:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:132:     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
agents/recruitment/scribe/agent.md:133:   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
agents/recruitment/scribe/agent.md:148:   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
agents/recruitment/scribe/agent.md:158:     a Scribe run with no resolvable target cannot produce structured writes)
agents/recruitment/scribe/agent.md:165:   → discard fields confidence <0.6 (per Gate A)
agents/recruitment/scribe/agent.md:166:   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
agents/recruitment/scribe/agent.md:168:     "<N> fields ≥0.6 confidence")
agents/recruitment/scribe/agent.md:170:6. LLM tacit-note generation
agents/recruitment/scribe/agent.md:176:   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md
agents/recruitment/scribe/agent.md:177:   → hh_decision_output("tacit_note_rendered", "<vault_path>",
agents/recruitment/scribe/agent.md:189:   → on success: hh_decision_action("bullhorn_scribe_field_write",
agents/recruitment/scribe/agent.md:193:9. Bullhorn write — tacit-note attachment (yellow tier)
agents/recruitment/scribe/agent.md:203:   → if elapsed > 300 (5 min): info-level (counted against Gate B 90%)
agents/recruitment/scribe/agent.md:204:   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
agents/recruitment/scribe/agent.md:214:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:217:- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
agents/recruitment/scribe/agent.md:218:- 1 tacit-note generated with voice classifier ≥0.75
agents/recruitment/scribe/agent.md:221:- No PII outside firm boundary in tacit-note narrative
agents/recruitment/scribe/agent.md:226:**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/scribe/agent.md:230:Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
agents/recruitment/scribe/agent.md:233:- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
agents/recruitment/scribe/agent.md:234:- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
agents/recruitment/scribe/agent.md:236:Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
agents/recruitment/scribe/agent.md:244:Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/scribe/agent.md:250:| `ESC_PROVIDER_FETCH_FAIL` | Fathom/Fireflies/Ringover transcript fetch fails | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:252:| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:255:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:261:Scribe does NOT use:
agents/recruitment/scribe/agent.md:263:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
agents/recruitment/scribe/agent.md:270:Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:275:  - No compensation specifics in tacit notes (those go to structured fields only)
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:279:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/scribe/agent.md:283:## §8 — Build dependencies (W6 prerequisites)
agents/recruitment/scribe/agent.md:285:Scribe build cannot start until ALL of the following are confirmed:
agents/recruitment/scribe/agent.md:295:| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
agents/recruitment/scribe/agent.md:296:| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
agents/recruitment/scribe/agent.md:297:| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
agents/recruitment/scribe/agent.md:301:| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
agents/recruitment/scribe/agent.md:302:| `context.sh` hydration | Build at W6 start (~0.5 day) | ⏸ |
agents/recruitment/scribe/agent.md:303:| `cycle.sh` orchestration (10-step) | Build at W6 start (~2 days) | ⏸ |
agents/recruitment/scribe/agent.md:304:| 3 fixtures with golden outputs | Build at W6 start (~1 day) | ⏸ |
agents/recruitment/scribe/agent.md:307:**Until ALL ⏸ items resolve to ✅, W6 build slice does not start.**
agents/recruitment/scribe/agent.md:313:**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
agents/recruitment/scribe/agent.md:319:| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
agents/recruitment/scribe/agent.md:322:| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
agents/recruitment/scribe/agent.md:324:| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
agents/recruitment/scribe/agent.md:325:| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
agents/recruitment/scribe/agent.md:327:### Gotchas (carried forward from ULTRAPLAN A3 line 527)
agents/recruitment/scribe/agent.md:330:2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
agents/recruitment/scribe/agent.md:331:3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.
agents/recruitment/scribe/agent.md:341:- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
agents/recruitment/scribe/agent.md:345:- W6 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/scribe/agent.md:352:*End of Scribe agent.md draft.*
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
packages/harness/cortextos/templates/orchestrator/AGENTS.md:285:The knowledge base is a semantic vector store (ChromaDB, Gemini Embedding 2). Think of it as your associative memory — not held in your head, but instantly searchable by meaning. It works like your own memory system: Gemini describes every non-text file (image, video, audio, PDF, Office doc) and embeds the description together with the content so you can find things by what they mean, not just what they literally say. Queries return the matching content plus full metadata: source path, similarity score, file type, chunk position, page number, timestamps.
agents/recruitment/diagnostic/context.sh:10:# the first workflow step runs. Per master brief §8.1 Change 1: load voice
docs/_archive-build-pack/02-PRODUCT-VISION.md:66:1. They upload the handbook, paste past replies, connect Fathom — material lands in the vault as markdown pages.
docs/decisions/brain-ui-scope.md:148:The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
agents/recruitment/sourcing-scout/agent.md:10:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:108:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:250:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:265:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:318:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/diagnostic/agent.md:6:**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
agents/recruitment/diagnostic/agent.md:81:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.
agents/recruitment/diagnostic/agent.md:146:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
agents/recruitment/diagnostic/agent.md:150:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:199:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:241:| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |
docs/decisions/2026-05-18-codex-ratification-manifest.md:6:**Source:** Master brief §10 (the Codex ratification loop) + §10.6 (Day 7 first ratification run)
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:146:| 3 | `agents/recruitment/scribe/agent.md` | **REJECTED** | ~5-7 real findings (count regex 59) | `20260524T102202Z-22338` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:233:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:59:| 03 | Proposal Builder | Sales | On call-end | £24,200 engagement | Fathom, HubSpot, Notion |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:131:- Specific: "Drafts a proposal 4 minutes after the Fathom call ends."
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:203:- Fathom (Proposal Builder)
packages/harness/cortextos/templates/agent/ONBOARDING.md:97:   For each workflow the user describes:
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:83:| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/autosend-safety-policy.md:106:| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:494:- **Per-recipient reputation:** recipients with high engagement may be in implicit "always-orange" zone; recipients with prior unsubscribes may be elevated to red.
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
packages/agent-renderer/pnpm-lock.yaml:130:    resolution: {integrity: sha512-0T+A9WZm+bZ84nZBtk1ckYsOvyA3x7e2Acj1KdVfV4/2tdG4fzUp91YHx+GArWLtwqp77pBXVCPn2We7Letr0Q==}
packages/agent-renderer/pnpm-lock.yaml:268:    resolution: {integrity: sha512-KabT5I6StirGfIz0FMgl1I+R1H73Gp0ofL9A3nG3i/cYFJzKHhouBV5VWK1CSgKvVaG4q1RNpCTR2LuTVB3fIw==}
packages/agent-renderer/pnpm-lock.yaml:310:    resolution: {integrity: sha512-SQPZOwoTTT/HXFXQJG/vBX8sOFagGqvZyXcgLA3NhIqcBv1BJU1d46c0rGcrij2B56Z2rNiSLaZOYW5cUk7yLQ==}
packages/agent-renderer/pnpm-lock.yaml:388:    resolution: {integrity: sha512-cXb5vApOsRsxsEl4mcZ1XY3D4DzcoMxR/nnc4IyqYs0rTI8ZKmW6kyyg+11Z8yvgMfAEldKzP7AdP64HnSC/6g==}
packages/agent-renderer/pnpm-lock.yaml:406:    resolution: {integrity: sha512-8wZM2qqtv9UP3mzy7HiGYNH/zjTA355mpeuA+859TyR+e+Tc08IHYpLJuMsfpDJwoLo1ikIJI8jC3GFjnRClzA==}
packages/agent-renderer/pnpm-lock.yaml:506:    resolution: {integrity: sha512-zzNR+SdQSDJzc8joaeP8QQoCQr8NuYx2dIIytl1QeBEZHJ9uW6hebsrYgbz8hJwUQao3TWCMtmfV8Nu1twOLAw==}
packages/agent-renderer/pnpm-lock.yaml:751:    resolution: {integrity: sha512-RGwwWnwQvkVfavKVt22FGLw+xYSdzARwm0ru6DhTVA3umU5hZc28V3kO4stgYryrTlLpuvgI9GiijltAjNbcqA==}
packages/agent-renderer/pnpm-lock.yaml:808:    engines: {node: ^8.16.0 || ^10.6.0 || >=11.0.0}
packages/agent-renderer/pnpm-lock.yaml:904:    resolution: {integrity: sha512-GDhwkLfywWL2s6vEjyhri+eXmfH6j1L7JE27WhqLeYzoh/A3DBaYGEj2H/HFZCn/kMfim73FXxEJTw06WtxQwg==}
packages/agent-renderer/pnpm-lock.yaml:1050:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/harness/cortextos/templates/agent/AGENTS.md:290:The knowledge base is a semantic vector store (ChromaDB, Gemini Embedding 2). Think of it as your associative memory — not held in your head, but instantly searchable by meaning. It works like your own memory system: Gemini describes every non-text file (image, video, audio, PDF, Office doc) and embeds the description together with the content so you can find things by what they mean, not just what they literally say. Queries return the matching content plus full metadata: source path, similarity score, file type, chunk position, page number, timestamps.
docs/decisions/v1.0-kill-criterion.md:73:### Trigger 3 — JANITOR-BULLHORN-AUTH-W5 (PIVOT)
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:4:triggers: ["buy", "purchase", "pay for", "subscribe to", "need a credit card", "make a payment", "sign up for paid plan", "buy a domain", "purchase API credits", "pay invoice", "need to pay", "financial transaction", "virtual card", "agentcard"]
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:20:- Subscribe to a paid API or SaaS tool
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
packages/harness/cortextos/templates/analyst/AGENTS.md:285:The knowledge base is a semantic vector store (ChromaDB, Gemini Embedding 2). Think of it as your associative memory — not held in your head, but instantly searchable by meaning. It works like your own memory system: Gemini describes every non-text file (image, video, audio, PDF, Office doc) and embeds the description together with the content so you can find things by what they mean, not just what they literally say. Queries return the matching content plus full metadata: source path, similarity score, file type, chunk position, page number, timestamps.
docs/architecture/architecture-cohesion-review.md:90:| A3 | **The `_shared/` symlink target `../../../_shared` resolves to `<org>/agents/_shared/`, not anywhere else.** | renderer.ts symlinkSync call | If filesystem semantics differ (mac vs linux), or someone moves the rendered dir, symlink could escape. macOS + Linux behaviour verified identical for this case. |
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
packages/harness/cortextos/templates/analyst/SYSTEM.md:7:This file should contain cross-agent system context. It is shared across all agents in the Organization and describes the cortextOS architecture, communication patterns, and operational protocols.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:21:| 6 | Scribe |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
packages/mcp-connectors/companies-house/pnpm-lock.yaml:114:    resolution: {integrity: sha512-0T+A9WZm+bZ84nZBtk1ckYsOvyA3x7e2Acj1KdVfV4/2tdG4fzUp91YHx+GArWLtwqp77pBXVCPn2We7Letr0Q==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:252:    resolution: {integrity: sha512-KabT5I6StirGfIz0FMgl1I+R1H73Gp0ofL9A3nG3i/cYFJzKHhouBV5VWK1CSgKvVaG4q1RNpCTR2LuTVB3fIw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:294:    resolution: {integrity: sha512-SQPZOwoTTT/HXFXQJG/vBX8sOFagGqvZyXcgLA3NhIqcBv1BJU1d46c0rGcrij2B56Z2rNiSLaZOYW5cUk7yLQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:372:    resolution: {integrity: sha512-cXb5vApOsRsxsEl4mcZ1XY3D4DzcoMxR/nnc4IyqYs0rTI8ZKmW6kyyg+11Z8yvgMfAEldKzP7AdP64HnSC/6g==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:390:    resolution: {integrity: sha512-8wZM2qqtv9UP3mzy7HiGYNH/zjTA355mpeuA+859TyR+e+Tc08IHYpLJuMsfpDJwoLo1ikIJI8jC3GFjnRClzA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:490:    resolution: {integrity: sha512-zzNR+SdQSDJzc8joaeP8QQoCQr8NuYx2dIIytl1QeBEZHJ9uW6hebsrYgbz8hJwUQao3TWCMtmfV8Nu1twOLAw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:714:    resolution: {integrity: sha512-RGwwWnwQvkVfavKVt22FGLw+xYSdzARwm0ru6DhTVA3umU5hZc28V3kO4stgYryrTlLpuvgI9GiijltAjNbcqA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:765:    engines: {node: ^8.16.0 || ^10.6.0 || >=11.0.0}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:854:    resolution: {integrity: sha512-GDhwkLfywWL2s6vEjyhri+eXmfH6j1L7JE27WhqLeYzoh/A3DBaYGEj2H/HFZCn/kMfim73FXxEJTw06WtxQwg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:996:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:13:Master brief §2.4 row 3 describes Primitive 3 (Inter-agent file bus) as:
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:303:- `src/telegram/transcribe.ts` (137 lines) + `src/telegram/media.ts` (217 lines) — voice-note transcription and image/document handling — past the "approval surface" minimum but indicates the surface is production-grade for general agent comms.
docs/architecture/cortexos-primitive-status.md:319:- `tests/unit/telegram/transcribe.test.ts` (92 lines).
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:42:**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:118:### 2.3 — A3 Scribe
docs/decisions/sequencing-target.md:122:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 526 estimate **M (1 week)**. Webhook-driven not always-on. Structured-field mapping is per-firm config not code per Ultraplan §8.1 line 526. Tacit-note extraction is the hard part per Ultraplan §8.1 line 527 ("Start with a small taxonomy (5-10 tacit-note types) and expand") |
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:127:| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:183:W6:   Scribe (A3)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:210:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:230:W6-9: Concierge (A6) — Risk #1 derisk via Tier-1 + Primitive 2 first exercise
docs/decisions/sequencing-target.md:231:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:240:1. **Concierge depends on Scribe** for Notes-for-context (per `bullhorn-integration-path.md` §4.1 row 4 — Concierge reads Notes Scribe wrote). Building Concierge at W6-9 before Scribe (W10) means Concierge's first-month operation has empty Note context. Materially degrades the Tier-1 always-on demo.
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:255:| 4. Commercial value | Tied (Diagnostic substrate, then flagship Concierge last; closing demo at W12-13 per Ultraplan §9 line 781) | Wins on raw timing (Concierge W5-8 demoable earlier) — but loses on substrate quality (Concierge ships with degraded Notes-for-context) | Tied — Concierge W6-9 marginally earlier than Alpha but with same substrate gaps as Beta |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:510:| Hire #1 onboarded and productive by W7 per Ultraplan §9 line 766 | Founder | End of W6 | Already tracked from RISK-REGISTER #4 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:122:[Describe the current approach being tested]
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:93:  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:298:**Confirmed from Bullhorn public docs:** `https://bullhorn.github.io/rest-api-docs/` describes **no webhook, subscription, event-stream, or push-notification mechanism**. Operations covered: entity CRUD, query/search, file attachments, resume parsing, mass updates, entity metadata. Verified 2026-05-16.
docs/decisions/bullhorn-integration-path.md:308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
docs/decisions/bullhorn-integration-path.md:335:| Scribe (write-on-event) | 50-100 distributed | Event-rate-bounded; one call typically = 5-15 REST writes |
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:452:Joins the atomic correction commit at end of Week 0 / early Week 1. Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:172:│   │   ├── calls/                                  ← Fathom/Fireflies transcripts (master brief §5.1 line 318)
docs/architecture/second-brain-design.md:204:| `wiki/raw/calls/` | one file per call | markdown with frontmatter | `{epoch}-{call-id}.md` | Scribe (v1.0) on Fathom/Fireflies webhook | Brief Decoder (v1.1), Concierge (v1.0) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:257:  - scribe-agent:call-2026-05-16-1432
docs/architecture/second-brain-design.md:274:{Janitor or Scribe one-paragraph summary, regenerated on each ingest}
docs/architecture/second-brain-design.md:277:{auto-appended by Concierge / Scribe — chronological, agent-attributed}
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:757:- `append-to-narrative` — Concierge / Scribe logging; tolerates few-hundred-ms.
docs/architecture/second-brain-design.md:772:| Scribe | 3:1 | reads candidate for context on every call; writes structured fields + tacit notes |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:892:| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:123:[Describe the current approach being tested]
docs/runbooks/day-4-provisioning.md:70:- Master brief §8.1 Change 2: three values — `trigger`, `output`, `action`
docs/runbooks/day-4-provisioning.md:104:### §0.6 — Single LUKS volume, two bind mounts
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/bullhorn-outreach-emails.md:74:- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
docs/operations/bullhorn-outreach-emails.md:117:> Public REST docs describe pull-only model. Is there an undocumented webhook or event-subscription mechanism available to integration partners? If not, we'll proceed with the polling model (already designed); if yes, we'd prefer to subscribe to placement-state-change events directly.
packages/harness/cortextos/templates/agent-codex/GUARDRAILS.md:17:| Telegram reply via stdout | "I'll just describe what I'd say" | Reply text is invisible unless it goes through `cortextos bus send-telegram`. Run the command. |
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:99:   For each workflow the user describes:
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:126:[Describe the current approach being tested]
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:121:[Describe the current approach being tested]
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/operations/codex-round-2-handoff.md:373:Per master brief §10.6 + execution plan §5:
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/build-brief/00-MASTER-BRIEF.md:5:**Synthesis stance:** First principles. The build pack in `docs/build-pack/` is **ignored** per founder instruction. The CLAUDE.md currently in the repo describes paths, remotes, and red lines — those are kept. Everything else in this brief is rebuilt from the verified state of the two upstream repos (`grandamenium/cortextos`, `tarsclaw/intel-force-os-v2`), Karpathy's LLM-wiki pattern, and the recruitment product spec, ultraplan, and 24/7 directive.
docs/build-brief/00-MASTER-BRIEF.md:311:│       │   ├── calls/            ← from Fathom/Fireflies transcripts
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:358:   provenance: [scribe-agent:call-2026-05-16-1432, janitor:bullhorn-2026-05-15]
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:568:**Change 2 — Decision logging is enforced.** Three required calls per agent run:
docs/build-brief/00-MASTER-BRIEF.md:597:| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:762:### 10.6 The ratification timeline
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
packages/harness/cortextos/community/agents/orchestrator/AGENTS.md:285:The knowledge base is a semantic vector store (ChromaDB, Gemini Embedding 2). Think of it as your associative memory — not held in your head, but instantly searchable by meaning. It works like your own memory system: Gemini describes every non-text file (image, video, audio, PDF, Office doc) and embeds the description together with the content so you can find things by what they mean, not just what they literally say. Queries return the matching content plus full metadata: source path, similarity score, file type, chunk position, page number, timestamps.
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:146:**Change 1 — Voice handling moves into a shared module.**
docs/specs/ULTRAPLAN.md:166:**Change 2 — Decision logging is enforced, not optional.**
docs/specs/ULTRAPLAN.md:238:- Process group includes one process per always-on agent the tenant has subscribed to.
docs/specs/ULTRAPLAN.md:348:- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
docs/specs/ULTRAPLAN.md:365:The LoRA improves voice score from ~80% (RAG + scaffolding) to ~90%+. This is what justifies the Scale tier at £6,950/mo.
docs/specs/ULTRAPLAN.md:515:#### A3. The Scribe — the data spine
docs/specs/ULTRAPLAN.md:517:- **Build wave:** v1.0 (week 6–7)
docs/specs/ULTRAPLAN.md:519:- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
docs/specs/ULTRAPLAN.md:521:- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
docs/specs/ULTRAPLAN.md:522:- **Shared modules required:** Voice loader (for tone-detection of tacit notes), decision log writer
docs/specs/ULTRAPLAN.md:523:- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:525:- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
docs/specs/ULTRAPLAN.md:527:- **Gotchas:** Tacit-note extraction is the hard part. Start with a small taxonomy (5–10 tacit-note types) and expand. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
docs/specs/ULTRAPLAN.md:687:| Scribe | ✓ | ✓ | | | | | | ✓ | | | |
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:760:- Week 6: Scribe agent; Fathom + Fireflies MCP; tacit-note taxonomy v0.1
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:823:| 7 | Voice classifier underperforms (false positives blocking valid drafts) | Medium | Medium | First pilot reports >5% block rate on legitimate drafts | Soften the threshold from 0.75 → 0.65 for v1.0; tune up as corpus grows |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
packages/harness/cortextos/community/agents/analyst/AGENTS.md:285:The knowledge base is a semantic vector store (ChromaDB, Gemini Embedding 2). Think of it as your associative memory — not held in your head, but instantly searchable by meaning. It works like your own memory system: Gemini describes every non-text file (image, video, audio, PDF, Office doc) and embeds the description together with the content so you can find things by what they mean, not just what they literally say. Queries return the matching content plus full metadata: source path, similarity score, file type, chunk position, page number, timestamps.
docs/operations/codex-ratification-execution-plan.md:204:Per master brief §10.6 — mean cost is 20-30 min per artefact including the round-trip. Cluster batching reduces context-switching cost.
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:390:7. **Master brief §10.6 timeline updated** with actual cost vs estimate. Founder-facing artefact.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
packages/harness/cortextos/community/agents/agentic-crm-assistant/AGENTS.md:78:- Meeting notes: Notion, Fathom, Zoom, Granola, Fireflies, Drive, local transcripts, or manual notes.
docs/specs/_archive-build-handoff.md:328:git checkout -b agent/bullhorn-mcp        # or agent/janitor, agent/scribe, etc.
docs/specs/_archive-build-handoff.md:379:| 3 | **Scribe** | 6 | Fathom/Fireflies MCP + Bullhorn write | The post-call note that lands in Bullhorn within 10 min is the second-most-demoable result |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/PRODUCT-SPEC.md:110:#### R6. The Scribe — the call-to-context engine
docs/specs/PRODUCT-SPEC.md:112:- **Output contract:** Every call (Fathom, Fireflies, Ringover) gets parsed into ATS structured fields *and* tacit notes that don't fit any field: "client said they'd never hire from Bank X because of a 2019 grudge", "candidate's actual reason for leaving is the new line manager, not the salary". Tacit notes power every other agent's voice and judgement.
docs/specs/PRODUCT-SPEC.md:117:- **Per-tenant config:** transcript-source OAuth, ATS field-mapping rules, tacit-note retention policy, banned-extraction patterns (anything sensitive that shouldn't be captured).
docs/specs/PRODUCT-SPEC.md:187:- **Revenue story:** "First 2 weeks of every contract done correctly, every time. No PAYE surprises in week 6 because RTW was checked on day 1." Avoids £5k–£40k per botched onboarding (back-claimed PAYE plus penalties).
docs/specs/PRODUCT-SPEC.md:242:| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:279:        │   The Scribe captures    │    │  The Janitor keeps it    │
docs/specs/PRODUCT-SPEC.md:297:The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**
docs/specs/PRODUCT-SPEC.md:329:- Customer clicks 5 OAuth buttons in the wizard: ATS (Bullhorn / Vincere / Voyager), accounting (Xero / Sage / QuickBooks), Microsoft 365 or Google Workspace, transcript source (Fathom / Fireflies / Ringover), LinkedIn.
docs/specs/PRODUCT-SPEC.md:473:- The Scribe (the data spine)
docs/specs/PRODUCT-SPEC.md:527:6. **The Scribe** — "Your firm's institutional memory finally lives somewhere."
packages/harness/cortextos/community/agents/security/ONBOARDING.md:97:   For each workflow the user describes:
docs/_supplementary/PRD-autonomous-agent.md:871:// Step 4: Transcribe with Whisper
docs/_supplementary/PRD-autonomous-agent.md:872:export async function transcribeAudio(audioPath: string): Promise<WhisperTranscript> {
docs/_supplementary/PRD-autonomous-agent.md:2058:  "name": "Extraction pipeline (download → transcribe → analyse)",
docs/_supplementary/PRD-autonomous-agent.md:2068:- [ ] Build `src/extraction/transcribe.ts` — Whisper API integration
docs/_supplementary/PRD-autonomous-agent.md:2404:│   │   ├── transcribe.ts
docs/_supplementary/planning-phase-brief.md:62:| 1.8 | Fathom Webhook Receiver Spec | **P** → CC2 builds |
docs/_supplementary/planning-phase-brief.md:177:- Session 24: Integration Specs Batch 1 — Fathom, HubSpot, Gmail, Slack, Notion, DocuSign (3.8)
docs/_supplementary/technical-strategy-v2.md:19:4. **Prompt caching makes the API economics very different to what I assumed.** Enterprise Claude Code users report roughly $150–250/developer/month in heavy use, because 90%+ of tokens in a repeated-context workload are cache reads at 10% of input price ($0.50/M for Opus, lower for Sonnet/Haiku). For a batch-style agent workload like ours, unit cost per tenant lands ~£100–300/mo, not the £400+ I budgeted.
docs/_supplementary/technical-strategy-v2.md:43:description: Drafts a fully-scoped proposal from a Fathom call transcript and past winning proposals. Invoke when a new call transcript lands in the intake folder.
docs/_supplementary/technical-strategy-v2.md:50:Fathom discovery call transcript and produce a professional proposal...
docs/_supplementary/technical-strategy-v2.md:98:claude -p "Pick up any Fathom transcripts dropped in /intake/fathom/ in the last hour. For each: draft a proposal using the Proposal Builder sub-agent, save to /outbox/proposals/, send to the assigned sales lead via Slack." --output-format json
docs/_supplementary/technical-strategy-v2.md:187:│   HubSpot · Fathom · Gmail · Slack · Notion · DocuSign · Stripe      │
docs/_supplementary/technical-strategy-v2.md:272:- Proposal Builder: on Fathom call end (no cron — webhook)
docs/_supplementary/technical-strategy-v2.md:277:Example: **Proposal Builder** fires when a Fathom call ends.
docs/_supplementary/technical-strategy-v2.md:282:claude -p "A new Fathom call transcript is at /intake/fathom/{call-id}.json. Use the Proposal Builder sub-agent to draft a proposal. Save to /outbox/proposals/. Email {assigned-rep} for review." --output-format json
docs/_supplementary/technical-strategy-v2.md:342:        2026-04-22-discovery.md  ← Fathom transcripts, tagged
docs/_supplementary/technical-strategy-v2.md:551:3. Connect Fathom (MCP or API wrapper) and a Notion output
docs/_supplementary/technical-strategy-v2.md:552:4. Wire one webhook endpoint that fires on Fathom call end
docs/_supplementary/build-plan-original.md:135:- **Fixture inputs** — real anonymised examples (redacted Fathom transcript, scrubbed lead list)
docs/_supplementary/build-plan-original.md:208:1. Takes the trigger payload (e.g. Fathom call transcript)
docs/_supplementary/build-plan-original.md:226:- Trigger payload: variable (Fathom transcript = 5–15k tokens)
docs/_supplementary/build-plan-original.md:246:| Client Onboarder | 4 | 8k in / 6k out | £0.15 | £0.60 |
docs/_supplementary/build-plan-original.md:340:**"Fathom call end" → "proposal in inbox" median time.** Target: <120s. Also: proposal-to-signed-contract conversion rate, measured monthly. Baseline against client's historical rate; target ≥ parity within 60 days.
docs/_supplementary/build-plan-original.md:343:Fathom webhook `recording.complete` with `include_transcript: true, include_summary: true, include_action_items: true`. Payload lands at `hooks.intelforce.ai/{tenant}/fathom`, persists to `/intake/fathom/{call-id}.json`, triggers the agent.
docs/_supplementary/build-plan-original.md:352:- Fathom AI summary + action items
docs/_supplementary/build-plan-original.md:361:- **Fathom MCP** (use `matthewbergvinson/fathom-mcp` or `Dot-Fun/fathom-mcp` as starting point; fork and productize) — transcript, summary, action items
docs/_supplementary/build-plan-original.md:390:Fathom URL: [link for audit]
docs/_supplementary/build-plan-original.md:394:<Fathom summary>
docs/_supplementary/build-plan-original.md:397:<Fathom action items>
docs/_supplementary/build-plan-original.md:477:- Fathom summary contradicts transcript → trust transcript, flag contradiction
docs/_supplementary/build-plan-original.md:496:**High.** The prompt engineering alone is a full week of iteration against real calls. The integrations (Fathom + HubSpot + DocuSign + Notion + Gmail) are another week. The validation tooling is 3 days. Budget 3 weeks total to get to production quality. You CANNOT rush this one.
docs/_supplementary/build-plan-original.md:554:- Prospect replied with "unsubscribe" or hostile tone → immediately flag, no further follow-ups, add to exclusion list
docs/_supplementary/build-plan-original.md:566:- Unsubscribes per month (target <1%)
docs/_supplementary/build-plan-original.md:795:### Cost: £0.60/mo. Build: 1 week (lots of integrations).
docs/_supplementary/build-plan-original.md:1080:                       (Fathom, Stripe, DocuSign, HubSpot) via their APIs
docs/_supplementary/build-plan-original.md:1197:1. Verify signature (every integration has its own: Fathom uses HMAC, Stripe uses stripe-signature, HubSpot has timestamp+signature)
docs/_supplementary/build-plan-original.md:1204:- **At-least-once** processing — fine because agent outputs are idempotent by design (same Fathom call ID → same proposal location, overwritten)
docs/_supplementary/build-plan-original.md:1255:| Fathom | Community MCP (matthewbergvinson, Dot-Fun) | Fork, harden, productize |
docs/_supplementary/build-plan-original.md:1516:- Week 1: Runtime proof-of-concept — **Proposal Builder end-to-end** in one container, one real Fathom call → proposal in inbox. This is the week-1 experiment from v2. Nothing else.
docs/_supplementary/execution-plan.md:41:The Build Plan described each component's purpose and architecture. For each one, you need a *developer-ready spec* — concrete enough that a dev can open a cursor and start writing the code without further back-and-forth. Twelve components total.
docs/_supplementary/execution-plan.md:117:Work linearly. Do not start Phase 2 before Phase 1 is ≥90% complete.
docs/_supplementary/execution-plan.md:123:**Goal:** everything needed to run the Proposal Builder end-to-end on one real Fathom call, in one real tenant container. This is the week-1 experiment from Technical Strategy v2 §7.
docs/_supplementary/execution-plan.md:145:  - *Prompt:* "Write `proposal-builder/tools.yaml` declaring required MCP servers (Fathom, HubSpot, DocuSign, Notion, Gmail), their read/write scopes, and the degraded-mode behaviour when any is unreachable."
docs/_supplementary/execution-plan.md:160:  - *Purpose:* 3 anonymised real-world Fathom transcripts + their golden-output proposals. Regression test harness.
docs/_supplementary/execution-plan.md:163:  - *Prompt:* "Write 3 synthetic but realistic Fathom call transcripts representing: (a) a clear-fit dental practice prospect, (b) an ambiguous scope multi-service prospect, (c) an edge-case prospect with mismatched budget signals. For each, write the golden proposal the agent should produce. Save as `proposal-builder/tests/fixtures/{01-03}.{transcript.json,expected.md}`."
docs/_supplementary/execution-plan.md:171:- [ ] **1.8 — Fathom Webhook Receiver Spec**
docs/_supplementary/execution-plan.md:172:  - *Purpose:* the minimum webhook service to receive a Fathom `recording.complete` event and trigger Proposal Builder.
docs/_supplementary/execution-plan.md:175:  - *Prompt:* "Write the Fathom Webhook Receiver Specification: a Node/Fastify service that receives `POST /hooks/:tenant/fathom`, verifies HMAC signature, persists payload to `/tenant/intake/fathom/{call-id}.json`, invokes Claude Code via child_process (`claude -p ...`), returns 200 within 2s. Include the exact signature verification code, the dispatching command, error handling, and logging format."
docs/_supplementary/execution-plan.md:187:  - *Prompt:* "Write the Week-1 Experiment Runbook: exact step-by-step commands to (1) spin up a test tenant container on a local Mac, (2) configure test API keys, (3) run a real test Fathom call, (4) verify the webhook fires, (5) verify Claude Code runs with Proposal Builder, (6) verify output lands in Gmail drafts, (7) measure end-to-end time. Include the pass/fail criteria, expected token spend (with target range), and the specific failure modes to debug first."
docs/_supplementary/execution-plan.md:270:  - *Purpose:* the full multi-integration webhook service (not just Fathom).
docs/_supplementary/execution-plan.md:273:  - *Prompt:* "Expand 1.8 into the full Webhook Receiver Engineering Specification covering all integrations in Build Plan §22: per-integration signature verification (Fathom HMAC, Stripe signature+timestamp, HubSpot HMAC, DocuSign HMAC, Loom — document each one explicitly with code snippets), per-tenant rate limiting, dead-letter queue design (Redis-backed), replay UX for DLQ items, BullMQ enqueue pattern, and the router that maps `/{tenant}/{integration}` to the right agent invocation."
docs/_supplementary/execution-plan.md:291:  - *Prompt per integration:* "Write the {Integration Name} Integration Specification: the MCP server choice (fork X / build from Y spec / official), auth setup (OAuth flow or API key), the scopes/permissions required and why, the specific operations used by agents (read leads, write deals, fetch transcript, etc.), fallback behaviour on failure, test checklist, rate limit handling. Priority 1 integrations: Fathom, HubSpot, Gmail, Slack, Notion, DocuSign. Priority 2: Companies House, Prospeo, Kaspr, Stripe, GA4, Meta Ads, Cal.com, Loom, Google Drive."
docs/_supplementary/execution-plan.md:518:  - *Prompt:* "Write the Status Page Setup Specification: platform choice (recommend Instatus or Statuspage), what to monitor (API, each core integration, control plane, vault service), incident communication templates, subscriber notification policy."
docs/_supplementary/strategic-plan.md:82:2. **Proposal Builder** — the signature agent. Fathom call ends → draft proposal in inbox within 90 seconds
docs/_supplementary/strategic-plan.md:173:│  - MCP servers for: HubSpot, Fathom, Gmail, Slack, DocuSign,│
docs/_supplementary/strategic-plan.md:255:  - Current stack (checkboxes: HubSpot? Fathom? Gmail?)
docs/_supplementary/strategic-plan.md:259:  - Same for Fathom, Gmail, Slack, Calendly, Stripe, etc.
docs/_supplementary/strategic-plan.md:265:  - Per-agent config (e.g. Proposal Builder: which Fathom folder?
docs/_supplementary/strategic-plan.md:333:**Milestone**: the Proposal Builder agent actually takes a Fathom call and drafts a proposal. End-to-end.
docs/_supplementary/strategic-plan.md:337:- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
docs/_supplementary/strategic-plan.md:454:Force yourself to onboard one friendly client at week 6 (half-built, half-manual behind the scenes). Their pain will teach you more than any plan.
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:93:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:94:| Codex Round 4 execution | Master brief §10.6 ratification cadence |
docs/operations/goal-week-3-polish-and-scaffold.md:104:| Fathom/Fireflies MCP connector | Reserved for W6 |
docs/operations/goal-week-3-polish-and-scaffold.md:292:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:294:- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
docs/operations/goal-week-3-polish-and-scaffold.md:301:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:304:- **§3 Output shape:** day-30 report has 8 sections per ULTRAPLAN line 511 (record counts, dedup pairs, field-completeness deltas, tacit-note coverage, agent vs. consultant attribution, gate-B metric, exception list, executive summary).
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:324:### DAY 17 — Scribe agent.md scaffold (Step 9)
docs/operations/goal-week-3-polish-and-scaffold.md:326:#### Step 9 — `agents/recruitment/scribe/agent.md` (~2-3 hours)
docs/operations/goal-week-3-polish-and-scaffold.md:329:- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:331:- `bullhorn-integration-path.md` §4.1 (Scribe's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:332:- `vertical-schema.yaml` §3 agent_access_matrix Scribe row
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:339:- **§3 Output shape:** Bullhorn write payload (entity-type-specific JSON) + 1 tacit-note attachment + 1 audit row in decision_log.
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:341:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:342:- **§5 Gate B:** ≥80% field-extraction accuracy (per consultant spot-check) + ≥90% within-10-min SLA.
docs/operations/goal-week-3-polish-and-scaffold.md:344:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:346:- **§9 Open questions:** 4-6 covering Fathom vs Fireflies first-mover choice, webhook auth, field-extraction model selection, tacit-note length cap.
docs/operations/goal-week-3-polish-and-scaffold.md:350:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:420:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:426:- **§5 Gate B:** <5% incorrect-send rate (per consultant feedback loop) + ≥90% lifecycle-event coverage (no missed transitions).
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:529:- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:617:  Scribe (W6):            <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:630:  <SHA>  decision(pre-build): agents/recruitment/scribe/agent.md
docs/operations/goal-week-3-polish-and-scaffold.md:640:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:656:    - Scribe build (depends on Bullhorn W + Fathom MCP)
docs/operations/goal-week-3-polish-and-scaffold.md:661:  - <Fathom/Fireflies signup for W6>
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/operations/founder-legal-setup-guide.md:108:Previous versions of this doc listed: **Bowers Anderson**, **LawBite**, **Privacy Helper**, **Vouch**. Their URLs did not resolve when I tested. These may be real firms at different URLs, or they may not exist as I described — I cited them from training-data memory without verification. If you Google these names and they look real + currently active, by all means contact them — but I cannot vouch for the citations I previously gave.
packages/harness/cortextos/community/agents/agentic-crm-assistant/TOOL_CONNECTIONS.md:23:| Meeting Notes | Granola, Fathom, Fireflies, Zoom transcripts, local files | Optional | Needed for automated meeting-note processing. |
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:97:   For each workflow the user describes:
packages/harness/cortextos/community/agents/agent/AGENTS.md:285:The knowledge base is a semantic vector store (ChromaDB, Gemini Embedding 2). Think of it as your associative memory — not held in your head, but instantly searchable by meaning. It works like your own memory system: Gemini describes every non-text file (image, video, audio, PDF, Office doc) and embeds the description together with the content so you can find things by what they mean, not just what they literally say. Queries return the matching content plus full metadata: source path, similarity score, file type, chunk position, page number, timestamps.
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/meeting-prep/SKILL.md:58:- Fathom/Zoom/Granola/Fireflies exports
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:122:[Describe the current approach being tested]

codex
The first pass shows several Scribe-specific schema and policy files exist, including a v0.3 supplement with notes about remaining Scribe drift. I’m narrowing this to blocking issues against the artefact’s own claims rather than treating the pre-build scaffold as production code.
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '588,604p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '150,210p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   150	    "$(_hh_json_escape "${tenant}")" \
   151	    "$(_hh_json_escape "${agent}")" \
   152	    "$(_hh_json_escape "${phase}")" \
   153	    "$([ -z "${outcome}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${outcome}")")" \
   154	    "$([ -z "${reason}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason}")")" \
   155	    "${payload_json}" \
   156	    "${created_at}" \
   157	    "${_HH_HELPERS_VERSION}")
   158	
   159	  printf '%s\n' "${row}" >> "${fallback}"
   160	}
   161	
   162	# ────────────────────────────────────────────────────────────────────────
   163	# 3 hh_decision_* contracts (master brief §8.1 Change 2)
   164	# ────────────────────────────────────────────────────────────────────────
   165	
   166	# hh_decision_trigger <trigger_type> [<reason>]
   167	# Writes phase='trigger' row at session start. Required first call of every run.
   168	hh_decision_trigger() {
   169	  local trigger_type="${1:-session_start}"
   170	  local reason="${2:-}"
   171	  local payload
   172	  payload=$(printf '{"trigger_type":"%s","helpers_version":"%s"}' \
   173	    "$(_hh_json_escape "${trigger_type}")" "${_HH_HELPERS_VERSION}")
   174	  _hh_emit_row "trigger" "" "${reason}" "${payload}"
   175	}
   176	
   177	# hh_decision_output <output_type> <artefact_ref> [<reason>]
   178	# Writes phase='output' row per artefact produced. Required before producing
   179	# a customer-visible artefact (Gate B per master brief §1 Rule 4).
   180	hh_decision_output() {
   181	  local output_type="$1"
   182	  local artefact_ref="$2"
   183	  local reason="${3:-}"
   184	  local payload
   185	  payload=$(printf '{"output_type":"%s","artefact_ref":"%s"}' \
   186	    "$(_hh_json_escape "${output_type}")" "$(_hh_json_escape "${artefact_ref}")")
   187	  _hh_emit_row "output" "produced" "${reason}" "${payload}"
   188	}
   189	
   190	# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
   191	# Writes phase='action' or phase='gating_failed' row depending on tier.
   192	# Returns 0 if action allowed; 1 if blocked or approval rejected.
   193	hh_decision_action() {
   194	  local action_type="$1"
   195	  local target="$2"
   196	  local payload_hash="$3"
   197	  local payload_preview="$4"
   198	
   199	  local tenant tier
   200	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   201	
   202	  if ! tier=$(autosend_policy_lookup "${action_type}"); then
   203	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   204	      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
   205	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   206	      "${target}" "${payload_hash}" "unknown_action_type"
   207	    return 1
   208	  fi
   209	
   210	  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then

exec
/bin/zsh -lc "nl -ba docs/ULTRAPLAN.md | sed -n '512,530p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
nl: docs/ULTRAPLAN.md: No such file or directory

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	#
     3	# IFOS voice-loader — implements the 3 hh_load_* helpers per master brief
     4	# §8.1 Change 1. Sourced by every agent's context.sh at session start; emits
     5	# voice corpus, tone rules, and recent edits into the agent's context bundle.
     6	#
     7	# Requires:
     8	#   - vertical-schema.v0.2-supplement.yaml schema migrated (Phase 4 SQL)
     9	#   - IFOS_DB_URL set + psql on PATH for live queries
    10	#   - Falls back to /vault/<tenant>/_voice/ markdown files if DB unavailable
    11	#
    12	# Helpers (3):
    13	#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
    14	#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
    15	#   hh_load_recent_edits   — query recent_edit for last N days
    16	#
    17	# Each helper writes its result to stdout as a single JSON document. Caller
    18	# (context.sh) typically pipes into `jq` to inject into context bundle.
    19	#
    20	# shellcheck shell=bash
    21	
    22	set -uo pipefail
    23	
    24	_VL_VERSION="0.1.0"
    25	_VL_HELPERS_PATH="${_VL_HELPERS_PATH:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/hook-helpers.sh}"
    26	
    27	# Try to source hook-helpers.sh so we can _hh_json_escape + _hh_emit_row
    28	# (helpers may not be loaded yet if voice-loader is called standalone).
    29	if [[ -z "${_HH_HELPERS_VERSION:-}" ]] && [[ -f "${_VL_HELPERS_PATH}" ]]; then
    30	  # shellcheck source=/dev/null
    31	  source "${_VL_HELPERS_PATH}"
    32	fi
    33	
    34	# Minimal fallback if hook-helpers.sh wasn't loadable (e.g. running standalone
    35	# in tests). Functions here mirror the helpers' behaviour with no DB writes.
    36	if ! declare -f _hh_json_escape >/dev/null 2>&1; then
    37	  _hh_json_escape() {
    38	    local input="$1"
    39	    input="${input//\\/\\\\}"
    40	    input="${input//\"/\\\"}"
    41	    input="${input//$'\n'/\\n}"
    42	    input="${input//$'\r'/\\r}"
    43	    input="${input//$'\t'/\\t}"
    44	    printf '%s' "${input}"
    45	  }
    46	fi
    47	
    48	# ────────────────────────────────────────────────────────────────────────
    49	# Internal: Postgres query helpers
    50	# ────────────────────────────────────────────────────────────────────────
    51	
    52	# Returns 0 if live DB mode is available, 1 if fallback should be used.
    53	_vl_db_available() {
    54	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    55	    return 0
    56	  fi
    57	  return 1
    58	}
    59	
    60	# _vl_psql_query <SQL> → stdout (rows), or empty on failure
    61	_vl_psql_query() {
    62	  local sql="$1"
    63	  local tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
    64	  local wrapped
    65	  wrapped="BEGIN;
    66	SET LOCAL app.current_tenant = '$(_hh_json_escape "${tenant}")';
    67	${sql}
    68	COMMIT;"
    69	  psql -v ON_ERROR_STOP=1 -q -t -A -F $'\t' "${IFOS_DB_URL}" <<<"${wrapped}" 2>/dev/null
    70	}
    71	
    72	# ────────────────────────────────────────────────────────────────────────
    73	# hh_load_tone_rules [<agent_name>]
    74	# ────────────────────────────────────────────────────────────────────────
    75	# Returns active tone_rule rows filtered to agent_name (or all rules if
    76	# agent_name absent). JSON shape:
    77	#   { "rules": [ { "rule_id":..., "rule_text":..., "severity":...,
    78	#                  "examples_positive":[...], "examples_negative":[...] }, ... ] }
    79	hh_load_tone_rules() {
    80	  local agent_name="${1:-${CTX_AGENT_NAME:-}}"
    81	
    82	  if _vl_db_available; then
    83	    local sql
    84	    if [[ -n "${agent_name}" ]]; then
    85	      sql="SELECT rule_id, rule_text, severity, COALESCE(examples_positive, '{}'), COALESCE(examples_negative, '{}')
    86	           FROM tone_rule
    87	           WHERE enabled = TRUE
    88	             AND (cardinality(applies_to_agents) = 0 OR '$(_hh_json_escape "${agent_name}")' = ANY(applies_to_agents))
    89	           ORDER BY severity DESC, rule_id ASC;"
    90	    else
    91	      sql="SELECT rule_id, rule_text, severity, COALESCE(examples_positive, '{}'), COALESCE(examples_negative, '{}')
    92	           FROM tone_rule
    93	           WHERE enabled = TRUE
    94	           ORDER BY severity DESC, rule_id ASC;"
    95	    fi
    96	    local rows
    97	    rows="$(_vl_psql_query "${sql}")"
    98	    _vl_render_tone_rules_json "${rows}"
    99	    return 0
   100	  fi
   101	
   102	  # Fallback: read /vault/<tenant>/_voice/tone-rules.yaml
   103	  local fallback_file="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/_voice/tone-rules.yaml"
   104	  if [[ -f "${fallback_file}" ]]; then
   105	    printf '{"rules":[],"source":"fallback","fallback_path":"%s","note":"DB unavailable; YAML fallback not yet parsed in v0.1 — caller should read file directly"}\n' \
   106	      "$(_hh_json_escape "${fallback_file}")"
   107	    return 0
   108	  fi
   109	  printf '{"rules":[],"source":"empty","reason":"db_unavailable_and_no_fallback_file"}\n'
   110	}
   111	
   112	# Internal: convert TSV rows from psql into JSON.
   113	_vl_render_tone_rules_json() {
   114	  local rows="$1"
   115	  if [[ -z "${rows}" ]]; then
   116	    printf '{"rules":[],"source":"db","count":0}\n'
   117	    return 0
   118	  fi
   119	  printf '{"rules":['
   120	  local first=1
   121	  while IFS=$'\t' read -r rule_id rule_text severity examples_pos examples_neg; do
   122	    [[ -z "${rule_id}" ]] && continue
   123	    if (( first )); then first=0; else printf ','; fi
   124	    printf '{"rule_id":"%s","rule_text":"%s","severity":"%s","examples_positive":"%s","examples_negative":"%s"}' \
   125	      "$(_hh_json_escape "${rule_id}")" \
   126	      "$(_hh_json_escape "${rule_text}")" \
   127	      "$(_hh_json_escape "${severity}")" \
   128	      "$(_hh_json_escape "${examples_pos}")" \
   129	      "$(_hh_json_escape "${examples_neg}")"
   130	  done <<<"${rows}"
   131	  printf '],"source":"db"}\n'
   132	}
   133	
   134	# ────────────────────────────────────────────────────────────────────────
   135	# hh_load_voice_samples <task_context> [<top_k>]
   136	# ────────────────────────────────────────────────────────────────────────
   137	# Runs pgvector ANN against voice_corpus_chunks for the active voice_corpus
   138	# pack. Requires task_context to be embedded externally and supplied as a
   139	# vector literal via IFOS_VL_QUERY_VECTOR env var (because shell can't
   140	# generate embeddings). Callers from Python/Node embed first, then exec
   141	# voice-loader with the literal vector pre-encoded.
   142	#
   143	# Falls back to /vault/<tenant>/_voice/style-guide.md when DB or query vector
   144	# unavailable (returns the style guide path; agent reads directly).
   145	#
   146	# Output JSON shape:
   147	#   { "samples": [ { "chunk_index": N, "text_chunk": "...",
   148	#                    "source_doc_ref": "...", "distance": 0.123 }, ... ],
   149	#     "voice_corpus_version": "v0.2-seed",
   150	#     "source": "db" | "fallback" }
   151	hh_load_voice_samples() {
   152	  local task_context="${1:-}"
   153	  local top_k="${2:-10}"
   154	
   155	  # Validate top_k
   156	  if ! [[ "${top_k}" =~ ^[0-9]+$ ]] || (( top_k <= 0 )) || (( top_k > 50 )); then
   157	    top_k=10
   158	  fi
   159	
   160	  if _vl_db_available && [[ -n "${IFOS_VL_QUERY_VECTOR:-}" ]]; then
   161	    # Live mode: run HNSW ANN query against active voice_corpus
   162	    local sql
   163	    sql="SELECT vcc.chunk_index, vcc.text_chunk, COALESCE(vcc.source_doc_ref, ''), (vcc.embedding <=> '${IFOS_VL_QUERY_VECTOR}'::vector) AS distance
   164	         FROM voice_corpus_chunks vcc
   165	         JOIN voice_corpus vc ON vc.id = vcc.voice_corpus_id
   166	         WHERE vc.is_active = TRUE
   167	         ORDER BY vcc.embedding <=> '${IFOS_VL_QUERY_VECTOR}'::vector
   168	         LIMIT ${top_k};"
   169	    local rows
   170	    rows="$(_vl_psql_query "${sql}")"
   171	    local version
   172	    version="$(_vl_psql_query "SELECT version FROM voice_corpus WHERE is_active = TRUE LIMIT 1;")"
   173	    _vl_render_voice_samples_json "${rows}" "${version:-unknown}" "db" "${task_context}"
   174	    return 0
   175	  fi
   176	
   177	  # Fallback: return style guide path
   178	  local style_guide="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/_voice/style-guide.md"
   179	  if [[ -f "${style_guide}" ]]; then
   180	    printf '{"samples":[],"voice_corpus_version":"fallback","source":"fallback","style_guide_path":"%s","task_context":"%s","reason":"%s"}\n' \

exec
/bin/zsh -lc "rg --files | rg 'ULTRA|ultra|PLAN|plan'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/harness/cortextos/src/hooks/hook-planmode-telegram.ts
docs/specs/ULTRAPLAN.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/execution-plan.md
docs/operations/codex-ratification-execution-plan.md
docs/_archive-build-pack/06-BUILD-PLAN.md
packages/harness/cortextos/bus/hook-planmode-telegram.sh
legacy/v1/BRAIN-PLAN.md
legacy/v1/docs/phase-0-strategic/intelforce-ai-os-strategic-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-build-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-execution-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md
legacy/v1/EXECUTION-PLAN.md
legacy/v1/DASHBOARD-EXECUTION-PLAN.md
legacy/v1/DASHBOARD-PLAN.md
legacy/v1/PLATFORM-BUILD-PLAN.md
legacy/v1/apps/dashboard/components/wizard/steps/step2-plan.tsx
packages/harness/cortextos/community/skills/local-ultrareview/SKILL.md

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '512,530p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '144,206p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   512	- **Build complexity:** **L** (2 weeks) — the Bullhorn MCP work is the rate-limiting piece
   513	- **Gotchas:** Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0. Estimate 1 week for the MCP server, 1 week for the agent itself. Dedup is hard; start conservative (high-confidence merges only) and tune up.
   514	
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
   529	#### A4. Cash Conductor (real-time mode) — the FD's evenings back
   530	

 succeeded in 0ms:
   144	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   145	  # ───────────────────────────────────────────────────────────
   146	
   147	  bullhorn_candidate_dedupe:
   148	    tier: yellow
   149	    agent: janitor
   150	    sample_rate: 10
   151	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   152	    irreversible: false
   153	
   154	  bullhorn_field_backfill:
   155	    tier: yellow
   156	    agent: janitor
   157	    sample_rate: 10
   158	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   159	    irreversible: false
   160	
   161	  bullhorn_note_attach:
   162	    tier: yellow
   163	    agent: janitor
   164	    sample_rate: 20
   165	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   166	    irreversible: false
   167	
   168	  bullhorn_note_append_summary:
   169	    tier: yellow
   170	    agent: scribe
   171	    sample_rate: 20
   172	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   173	    irreversible: false
   174	
   175	  linkedin_connection_request:
   176	    tier: yellow
   177	    agent: sourcing-scout
   178	    sample_rate: 5
   179	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   180	    irreversible: true
   181	
   182	  xero_reminder_draft_internal:
   183	    tier: yellow
   184	    agent: cash-conductor
   185	    sample_rate: 10
   186	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   187	    irreversible: false
   188	
   189	  bullhorn_note_draft_internal:
   190	    tier: yellow
   191	    agent: concierge
   192	    sample_rate: 10
   193	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   194	    irreversible: false
   195	
   196	  bullhorn_scribe_field_write:
   197	    tier: yellow
   198	    agent: scribe
   199	    sample_rate: 10
   200	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   201	    irreversible: false
   202	
   203	  accounting_reconciliation_write:
   204	    tier: yellow
   205	    agent: cash-conductor
   206	    sample_rate: 10

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '90,190p;306,330p;360,400p;438,448p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    90	- **Phase:** `gating_failed`
    91	- **Routing:** `operator_chat_id`
    92	- **Payload fields:** `partial_progress_count`, `total_refs_count`
    93	
    94	### 2.3 — Bullhorn integration (1 code)
    95	Source: `docs/decisions/bullhorn-integration-path.md` §4.5 + §6
    96	
    97	#### `ESC_BULLHORN_AUTH`
    98	- **Severity:** **blocking** — agent enters degraded mode (drafts-only, no auto-send)
    99	- **Trigger:** Bullhorn OAuth token refresh failed twice on the per-agent 8-minute cycle (per `common-ats.json.auth_refresh_interval_seconds`); or REST call returned 401 indefinitely (revoked token in Bullhorn admin UI)
   100	- **Phase:** `gating_failed`
   101	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   102	- **Payload fields:** `failure_type` (one of `refresh_failed`, `revoked_401`), `last_attempt_at`, `consecutive_failures`
   103	- **Recovery:** agent stays in degraded mode until founder rotates token via Bullhorn admin → next `_secrets.env` reload picks up new token
   104	
   105	### 2.4 — Renderer (1 code)
   106	Source: `docs/architecture/agent-bundle-renderer-design.md` §4
   107	
   108	#### `ESC_RENDERER_FAILED`
   109	- **Severity:** blocking — render did not produce a runnable agent dir
   110	- **Trigger:** Renderer exited non-zero. Mid-render atomic-rename per ADR-003 §3.3.4 means the prior agent dir at target is preserved (`.prev.<timestamp>/`) — no half-rendered state visible to daemon discovery
   111	- **Phase:** `gating_failed`
   112	- **Routing:** `operator_chat_id`; CC `ifos_oncall_chat_id` only on `atomic-rename-failed` (infrastructure failure, not author error)
   113	- **Agent name:** `_renderer` (sentinel; not a real agent)
   114	- **Payload fields:** `reason` (one of `schema-validation-failure`, `bundle-malformed`, `shared-helpers-missing`, `tenant-not-provisioned`, `atomic-rename-failed`, `non-rendered-target`), `agent_name_attempted`, `tenant_slug_attempted`
   115	- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
   116	
   117	### 2.5 — Recruitment-domain vocabulary (10 codes)
   118	Source: master brief §8.1 Change 3 lines 585-592
   119	
   120	#### `ESC_VOICE_DRIFT`
   121	- **Severity:** warn
   122	- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
   123	- **Phase:** `gating_failed`
   124	- **Routing:** `operator_chat_id`
   125	- **Payload fields:** `final_classifier_score`, `retry_count`, `agent_name`, `task_summary`
   126	
   127	#### `ESC_DUPLICATE_DETECTED`
   128	- **Severity:** warn — Janitor dedup needs human approval
   129	- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
   130	- **Phase:** `action`
   131	- **Routing:** `operator_chat_id` via Telegram approval gate
   132	- **Payload fields:** `candidate_a_id`, `candidate_b_id`, `confidence_score`, `match_basis` (e.g. `email+phone`, `name+email`, `phone+linkedin`)
   133	
   134	#### `ESC_JSL_RED_FLAG`
   135	- **Severity:** warn — Supply Chain Auditor (placeholder for v1.1+ JSL extension)
   136	- **Trigger:** Supply Chain Auditor detected red flag (v1.0 placeholder; SCA agent in v1.1 backlog)
   137	- **Phase:** `gating_failed`
   138	- **Routing:** `operator_chat_id`
   139	- **Status:** v1.0 placeholder; no agent fires this yet. Reserved name.
   140	
   141	#### `ESC_BRIEF_AMBIGUITY`
   142	- **Severity:** warn — Brief Decoder cannot confidently shortlist
   143	- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
   144	- **Phase:** `agent_handoff`
   145	- **Routing:** `operator_chat_id`
   146	- **Payload fields:** `brief_id`, `ambiguity_dimensions` (list of {`field`, `confidence`}), `proposed_clarifying_questions`
   147	
   148	#### `ESC_PII_LEAKAGE_RISK`
   149	- **Severity:** **blocking** — agent halts immediately, no retry
   150	- **Trigger:** Agent output references PII outside the firm boundary (cross-tenant PII detected by `validate.sh` Gate A or RLS check)
   151	- **Phase:** `gating_failed`
   152	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — potential GDPR incident
   153	- **Payload fields:** `detected_pii_type` (one of `email`, `phone`, `name`, `address`, `nin`, `passport`), `boundary_violated` (the tenant_slug whose data leaked), `output_snippet_redacted_hash`
   154	- **Recovery:** Agent restart required after operator review; founder must determine whether DPO notification is needed per UK GDPR Art. 33
   155	
   156	#### `ESC_RATE_LIMIT_HIT`
   157	- **Severity:** warn
   158	- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
   159	- **Phase:** `gating_failed`
   160	- **Routing:** `operator_chat_id`
   161	- **Payload fields:** `upstream` (e.g. `bullhorn`, `linkedin`, `reed`, `cv-library`), `retry_after_seconds`, `consecutive_429s`
   162	
   163	#### `ESC_SCHEMA_VIOLATION`
   164	- **Severity:** warn
   165	- **Trigger:** Agent produced output violating vertical-schema.yaml field constraints (e.g. wrote an unknown enum value, missing required field). Detected at write-time by adapter validation
   166	- **Phase:** `gating_failed`
   167	- **Routing:** `operator_chat_id`
   168	- **Payload fields:** `entity_type` (from vertical-schema.yaml entities), `field_violated`, `value_attempted`, `constraint_failed`
   169	
   170	#### `ESC_VOICE_DRIFT_TENANT`
   171	- **Severity:** warn (info-level — single-tenant pattern, not just one drift event)
   172	- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
   173	- **Phase:** `gating_failed`
   174	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (CSM may need to retrain voice corpus)
   175	- **Payload fields:** `tenant_slug`, `drift_event_count`, `window_days`, `affected_agents` (list of agent_name)
   176	
   177	#### `ESC_INPUT_VALIDATION_FAIL`
   178	- **Severity:** warn
   179	- **Trigger:** Agent rejected its input at the validation gate (e.g. malformed firm name, missing required CLI argument, brief description too short). Detected at Step 1 of the agent's workflow BEFORE any tool calls or LLM invocations
   180	- **Phase:** `gating_failed`
   181	- **Routing:** `operator_chat_id`
   182	- **Payload fields:** `input_field`, `input_value_preview` (truncated to 80 chars), `validation_rule_violated`
   183	
   184	#### `ESC_AGENT_OUTPUT_SHAPE`
   185	- **Severity:** warn
   186	- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
   187	- **Phase:** `gating_failed`
   188	- **Routing:** `operator_chat_id`
   189	- **Payload fields:** `agent_name`, `output_path`, `shape_rule_violated`, `expected_value`, `actual_value`
   190	
   306	
   307	### 2.8 — Provider read/write failures (4 codes)
   308	Source: derived from v1.0 agent.md adapter call sites
   309	
   310	#### `ESC_BULLHORN_WRITE_FAIL`
   311	- **Severity:** warn
   312	- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
   313	- **Phase:** `gating_failed`
   314	- **Routing:** `operator_chat_id`
   315	- **Payload fields:** `endpoint`, `entity_type`, `entity_id`, `status_code`, `error_body_preview` (truncated 120 chars)
   316	
   317	#### `ESC_ACCOUNTING_WRITE_FAIL`
   318	- **Severity:** warn
   319	- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
   320	- **Phase:** `gating_failed`
   321	- **Routing:** `operator_chat_id`
   322	- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`
   323	
   324	#### `ESC_PROVIDER_FETCH_FAIL`
   325	- **Severity:** warn
   326	- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
   327	- **Phase:** `gating_failed`
   328	- **Routing:** `operator_chat_id`
   329	- **Payload fields:** `upstream` (e.g. `companies-house`, `web-scraper`, `linkedin-cache`), `endpoint`, `status_code`, `consecutive_failures`
   330	
   360	  - **State-change race (Cash Conductor):** payment received between chase-draft and chase-send window; the invoice is no longer overdue when the orange-tier approval fires; chase cancelled (do NOT send) per Cash Conductor §4 Step 12
   361	- **Phase:** `gating_failed`
   362	- **Routing:** `operator_chat_id`
   363	- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
   364	- **Recovery:** duplicate → second suppressed; state-change → cancelled draft logged; no operator action required beyond informational review
   365	
   366	#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
   367	- **Severity:** info — quality sampling, not a failure
   368	- **Trigger:** Yellow-tier action was sampled per `sample_rate` (1-in-N) for post-hoc human review; sampling is informational + drives ongoing quality monitoring
   369	- **Phase:** `action`
   370	- **Routing:** `operator_chat_id`; sampled action is queued in `spot_check_queue_path` (`/vault/{tenant_slug}/spot-checks/`)
   371	- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
   372	- **Note:** Operator review of sampled rows is asynchronous (typically end-of-day batch); no SLA timer.
   373	
   374	### 2.10 — Agent workflow (10 codes)
   375	Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
   376	
   377	#### `ESC_GATE_B_MISS`
   378	- **Severity:** warn — post-send quality signal; not a hard failure
   379	- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
   380	- **Phase:** `gating_failed`
   381	- **Routing:** `operator_chat_id`
   382	- **Payload fields:** `agent_name`, `metric_name`, `actual_value`, `threshold`, `window`, `sample_size`
   383	- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
   384	
   385	#### `ESC_TONE_RULE_VIOLATION`
   386	- **Severity:** warn — voice/tone classifier flagged output as violating a tenant `tone_rule` row
   387	- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
   388	- **Phase:** `gating_failed`
   389	- **Routing:** `operator_chat_id`
   390	- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
   391	- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review
   392	
   393	#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
   394	- **Severity:** warn
   395	- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
   396	- **Phase:** `gating_failed`
   397	- **Routing:** `operator_chat_id`
   398	- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`
   399	
   400	#### `ESC_CANDIDATE_DATA_INCOMPLETE`
   438	- **Routing:** `operator_chat_id`
   439	- **Payload fields:** `brief_id` or `candidate_bullhorn_id` or `lifecycle_event_id` (per sla_type), `sla_type` (one of the three above), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   440	
   441	#### `ESC_SCRIBE_SLA_MISS`
   442	- **Severity:** warn
   443	- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
   444	- **Phase:** `gating_failed`
   445	- **Routing:** `operator_chat_id`
   446	- **Payload fields:** `call_id`, `sla_type` (`summary_render` | `note_attach`), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   447	
   448	#### `ESC_LIFECYCLE_STATE_UNKNOWN`

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,25p;45,125p;168,255p;382,396p;963,974p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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
    16	> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
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
    70	Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):
    71	
    72	| Entity | Canonical fields (schema-verified) |
    73	|---|---|
    74	| Candidate | `location`, `current_role_title`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (perm/contract/hybrid), `key_skills` (list) |
    75	| Contact | `seniority`, `decision_authority` (enum: yes/no/influencer/blocker/unknown per Q5 v0.1), `preferred_channel`, `next_action_target_date` |
    76	| Brief | `salary_min` + `salary_max`, `start_date`, `role_type`, `must_haves` (list), `nice_to_haves` (list), `deal_breakers` (list) |
    77	| Placement | `start_date`, `placement_status`, `week_1_status_note` (free-text), `satisfaction_signal` (enum) |
    78	| Opportunity | `sector`, `headcount_growth_signal_text`, `hiring_velocity_band`, `decision_window_text` |
    79	
    80	Field names match canonical schema verbatim; some v0.1 fields (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `week_1_status_note`) are scheduled for v0.3 supplement at W6 build start — flagged here as pre-build references requiring schema-supplement landing before Scribe references them in `cycle.sh`. The Q1 verification pass (W6 Day 1) audits all field names against the schema as it exists then.
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
   137	   → ESC_INPUT_VALIDATION_FAIL on signature mismatch; reject with 401
   138	   → record provider + call_id in trigger payload
   139	   → hh_decision_output("webhook_verified", "call:<id>", "provider:<name>")
   140	
   141	2. Bullhorn auth refresh
   142	   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
   143	   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
   144	
   145	3. Transcript fetch
   146	   → provider-specific: fathom.get_transcript(call_id) | fireflies.get(...)
   147	   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
   148	   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
   149	   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
   150	
   151	4. Participant + entity inference
   152	   → match transcript participants against Bullhorn contacts + candidates
   153	     + consultant accounts (per tenant config)
   154	   → infer call context (1:1 vs briefing vs placement vs opportunity)
   155	   → resolve target Bullhorn entity (bullhorn_id + entity_type per
   156	     vertical-schema.yaml canonical id field)
   157	   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
   158	     a Scribe run with no resolvable target cannot produce structured writes)
   159	   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>", confidence)
   160	
   161	5. LLM field extraction
   162	   → prompt = (transcript + entity context + vertical-schema entity field list
   163	     + 3 voice-corpus examples)
   164	   → output = JSON with per-field confidence scores
   165	   → discard fields confidence <0.6 (per Gate A)
   166	   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
   167	   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
   168	     "<N> fields ≥0.6 confidence")
   169	
   170	6. LLM tacit-note generation
   171	   → prompt = (transcript + 8-category taxonomy + 3 voice-corpus examples
   172	     + tone-rule filter)
   173	   → output = Markdown narrative per §3 Output 2 shape
   174	   → voice classifier scores against tenant style guide
   175	   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
   176	   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md
   177	   → hh_decision_output("tacit_note_rendered", "<vault_path>",
   178	     "voice_score:<N>; words:<N>")
   179	
   180	7. Field-extraction validation against vertical-schema
   181	   → verify each extracted field name exists in target entity schema
   182	   → verify each extracted value passes per-field type/range checks
   183	   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION
   184	     per catalogue line 163 — vertical-schema field-constraint violation at write time)
   185	
   186	8. Bullhorn write — structured fields (yellow tier)
   187	   → PATCH /<EntityType>/<id> with field map
   188	   → atomic transaction; rollback on Bullhorn 4xx/5xx
   189	   → on success: hh_decision_action("bullhorn_scribe_field_write",
   190	     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
   191	   → on failure: ESC_BULLHORN_WRITE_FAIL; do NOT proceed to Step 9
   192	
   193	9. Bullhorn write — tacit-note attachment (yellow tier)
   194	   → POST /Note linked to entity from Step 4 (mirror of vault artefact from Step 6)
   195	   → on success: hh_decision_action("bullhorn_note_attach",
   196	     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
   197	   → on failure: rollback Step 8 (best-effort PATCH /<EntityType>/<id>
   198	     reversing the field changes); ESC_BULLHORN_WRITE_FAIL
   199	
   200	10. Session close + SLA metric
   201	   → compute elapsed_seconds from webhook receipt
   202	   → if elapsed > 600 (10 min): warn ESC_SCRIBE_SLA_MISS (not blocking)
   203	   → if elapsed > 300 (5 min): info-level (counted against Gate B 90%)
   204	   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
   205	   → exit code 0
   206	```
   207	
   208	---
   209	
   210	## §5 — Gates
   211	
   212	### Gate A — validate.sh (hard-fail before action)
   213	
   214	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
   215	
   216	- Webhook signature valid per provider (Step 1)
   217	- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
   218	- 1 tacit-note generated with voice classifier ≥0.75
   219	- Field names exist in target entity per vertical-schema.yaml
   220	- Per-field type + range validation passes
   221	- No PII outside firm boundary in tacit-note narrative
   222	- Bullhorn auth refresh succeeded
   223	
   224	Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
   225	
   226	**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   227	
   228	### Gate B — Outcome thresholds (success metrics, not block)
   229	
   230	Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
   231	
   232	Two metrics:
   233	- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
   234	- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
   235	
   236	Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
   237	
   238	Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
   239	
   240	---
   241	
   242	## §6 — Escalation codes
   243	
   244	Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
   245	
   246	| Code | Trigger | Severity | Routing |
   247	|---|---|---|---|
   248	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   249	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
   250	| `ESC_PROVIDER_FETCH_FAIL` | Fathom/Fireflies/Ringover transcript fetch fails | warn | operator_chat_id |
   251	| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   252	| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
   253	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
   254	| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1) | warn | operator_chat_id |
   255	| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
   256	| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
   257	| `ESC_SCRIBE_SLA_MISS` | Webhook-to-Bullhorn-write >10 min (Gate B miss) | info | (logged; aggregated to Gate B metric) |
   258	| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
   259	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   260	

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '260,430p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	
   261	Scribe does NOT use:
   262	
   263	- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
   264	- `ESC_BULLHORN_OAUTH_REVOKED` — escalated from `ESC_BULLHORN_AUTH` only after 6 consecutive auth failures (Concierge handles)
   265	
   266	---
   267	
   268	## §7 — Voice + tone constraints
   269	
   270	Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   271	
   272	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
   273	  - No identifying language about call participants beyond their professional context
   274	  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
   275	  - No compensation specifics in tacit notes (those go to structured fields only)
   276	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
   277	- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
   278	
   279	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   280	
   281	---
   282	
   283	## §8 — Build dependencies (W6 prerequisites)
   284	
   285	Scribe build cannot start until ALL of the following are confirmed:
   286	
   287	| Dependency | Source | Status |
   288	|---|---|---|
   289	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   290	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   291	| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
   292	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   293	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   294	| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
   295	| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
   296	| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
   297	| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
   298	| Per-tenant call-routing config (which provider) | Tenant onboarding | ⏸ |
   299	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   300	| Tacit-note taxonomy v0.1 (8 categories) finalised | Founder review with first pilot | ⏸ |
   301	| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
   302	| `context.sh` hydration | Build at W6 start (~0.5 day) | ⏸ |
   303	| `cycle.sh` orchestration (10-step) | Build at W6 start (~2 days) | ⏸ |
   304	| 3 fixtures with golden outputs | Build at W6 start (~1 day) | ⏸ |
   305	| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |
   306	
   307	**Until ALL ⏸ items resolve to ✅, W6 build slice does not start.**
   308	
   309	---
   310	
   311	## §9 — Status + open questions
   312	
   313	**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
   314	
   315	### Open questions for founder review
   316	
   317	| # | Question | Resolution path |
   318	|---|---|---|
   319	| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
   320	| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
   321	| Q3 | Tacit-note taxonomy v0.1 — 8 categories proposed in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
   322	| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
   323	| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH. Could leave entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
   324	| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
   325	| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
   326	
   327	### Gotchas (carried forward from ULTRAPLAN A3 line 527)
   328	
   329	1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   330	2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
   331	3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.
   332	
   333	---
   334	
   335	## §10 — When this document ratifies
   336	
   337	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   338	
   339	Status flips Proposed → Accepted when:
   340	- Codex Round 4 Phase 2 ratifies
   341	- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
   342	- Q2 cost model approved with budget cap
   343	
   344	Status flips Accepted → In Force when:
   345	- W6 build slice produces all 5 sibling bundle files + 3 fixtures
   346	- First production transcript processed end-to-end against migration-test tenant
   347	- SLA + edit-rate Gate-B metrics measurable
   348	- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
   349	
   350	Until then: this document is a forward-looking scaffold.
   351	
   352	*End of Scribe agent.md draft.*

codex
REJECTED

1. §3 claims schema-verified canonical fields that are not schema-backed. Lines 70-80 list `current_role_title`, `seniority`, `start_date`, `week_1_status_note`, and `sector` as canonical/schema-verified, but `vertical-schema.v0.3-supplement.yaml` lines 12-16 and 963-974 explicitly say these are residual Scribe gaps (`current_role` vs `current_role_title`, `start_date_target` vs `brief.start_date`, `week_1_status_vault_path`, `seniority` and `opportunity.sector` not yet in schema). Fix the table to use current schema field names or mark the unresolved fields as blocked pending v0.4 before any Scribe ratification.

2. §3/§4 incorrectly treats Opportunity as a Bullhorn write target. Lines 16, 68, and 186-190 describe Bullhorn writes to the resolved `Opportunity` entity, but the schema supplement says Scribe opportunity access is to IFOS-cached Postgres rows only and “Bullhorn Opportunity endpoint NOT used at v1.0” (`vertical-schema.v0.3-supplement.yaml` lines 382-395). Fix Scribe’s opportunity path to write only the IFOS-cached entity row, or remove Opportunity from v1.0 Bullhorn write scope.

3. §4 uses the wrong autosend action type for the Scribe note attachment. Lines 193-196 call `hh_decision_action("bullhorn_note_attach", ...)`, but `agents/_shared/autosend-policy.yaml` lines 161-166 define `bullhorn_note_attach` for Janitor; the Scribe-specific yellow action is `bullhorn_note_append_summary` at lines 168-173. Fix Step 9 and §3’s audit-row signature to use the registered Scribe action type, or add a new Scribe-owned action type to the policy before referencing it.

4. §6 misstates `ESC_SCRIBE_SLA_MISS`. Line 257 defines it as webhook-to-Bullhorn-write `>10 min`, info-level, logged only; the catalogue defines `ESC_SCRIBE_SLA_MISS` as warn/gating_failed with default thresholds of summary rendered within 30 min and Bullhorn note attached within 1h (`agents/_shared/escalation-codes.md` lines 441-446). Either update the catalogue to the new 10-minute SLA semantics or change the agent.md trigger to match the existing code definition.
tokens used
64,942
REJECTED

1. §3 claims schema-verified canonical fields that are not schema-backed. Lines 70-80 list `current_role_title`, `seniority`, `start_date`, `week_1_status_note`, and `sector` as canonical/schema-verified, but `vertical-schema.v0.3-supplement.yaml` lines 12-16 and 963-974 explicitly say these are residual Scribe gaps (`current_role` vs `current_role_title`, `start_date_target` vs `brief.start_date`, `week_1_status_vault_path`, `seniority` and `opportunity.sector` not yet in schema). Fix the table to use current schema field names or mark the unresolved fields as blocked pending v0.4 before any Scribe ratification.

2. §3/§4 incorrectly treats Opportunity as a Bullhorn write target. Lines 16, 68, and 186-190 describe Bullhorn writes to the resolved `Opportunity` entity, but the schema supplement says Scribe opportunity access is to IFOS-cached Postgres rows only and “Bullhorn Opportunity endpoint NOT used at v1.0” (`vertical-schema.v0.3-supplement.yaml` lines 382-395). Fix Scribe’s opportunity path to write only the IFOS-cached entity row, or remove Opportunity from v1.0 Bullhorn write scope.

3. §4 uses the wrong autosend action type for the Scribe note attachment. Lines 193-196 call `hh_decision_action("bullhorn_note_attach", ...)`, but `agents/_shared/autosend-policy.yaml` lines 161-166 define `bullhorn_note_attach` for Janitor; the Scribe-specific yellow action is `bullhorn_note_append_summary` at lines 168-173. Fix Step 9 and §3’s audit-row signature to use the registered Scribe action type, or add a new Scribe-owned action type to the policy before referencing it.

4. §6 misstates `ESC_SCRIBE_SLA_MISS`. Line 257 defines it as webhook-to-Bullhorn-write `>10 min`, info-level, logged only; the catalogue defines `ESC_SCRIBE_SLA_MISS` as warn/gating_failed with default thresholds of summary rendered within 30 min and Bullhorn note attached within 1h (`agents/_shared/escalation-codes.md` lines 441-446). Either update the catalogue to the new 10-minute SLA semantics or change the agent.md trigger to match the existing code definition.
