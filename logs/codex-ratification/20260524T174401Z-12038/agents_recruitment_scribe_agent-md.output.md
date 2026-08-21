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
session id: 019e5b16-36aa-7773-b6e5-6abe72ab7e20
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
- Opportunity scoping (consultant + prospect) → Opportunity entity update (NOTE: Bullhorn endpoint A3 row covers Candidate / ClientCorporation / JobOrder / Note / Placement only at v1.0; Opportunity writes are to IFOS-cached Postgres entity rows for the v0.3-added fields headcount_growth_signal_text + hiring_velocity_band + decision_window_text per v0.3 supplement §1, NOT direct Bullhorn endpoint calls)

Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):

| Entity | Canonical fields (schema-verified) |
|---|---|
| Candidate | `location`, `current_role`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (v0.3; enum per supplement §1), `key_skills` (v0.3; list) |
| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
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
   → on success: hh_decision_action("bullhorn_note_append_summary",
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
| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
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
I’ll verify the artefact against the local source files it cites, especially schema fields, escalation codes, safety policy, and the master/ULTRAPLAN line anchors.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 3ms:
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
    68	- Opportunity scoping (consultant + prospect) → Opportunity entity update (NOTE: Bullhorn endpoint A3 row covers Candidate / ClientCorporation / JobOrder / Note / Placement only at v1.0; Opportunity writes are to IFOS-cached Postgres entity rows for the v0.3-added fields headcount_growth_signal_text + hiring_velocity_band + decision_window_text per v0.3 supplement §1, NOT direct Bullhorn endpoint calls)
    69	
    70	Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):
    71	
    72	| Entity | Canonical fields (schema-verified) |
    73	|---|---|
    74	| Candidate | `location`, `current_role`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (v0.3; enum per supplement §1), `key_skills` (v0.3; list) |
    75	| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
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
   195	   → on success: hh_decision_action("bullhorn_note_append_summary",
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
   257	| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
   258	| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
   259	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   260	

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
/bin/zsh -lc "rg -n \"Scribe|A3|Fathom|Fireflies|90%|0\\.6|week 6|W6|scribe\" docs agents -g '*.md' -g '*.yaml' -g '*.sh'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:211:     (90% of drafts within 30 min) rather than per-draft hard fail (legitimate
agents/recruitment/concierge/agent.md:276:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
agents/recruitment/concierge/agent.md:280:**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/concierge/agent.md:359:| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:395:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:443:- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
agents/_shared/autosend-policy.yaml:43:    agent: scribe
agents/_shared/autosend-policy.yaml:83:  scribe_run_complete:
agents/_shared/autosend-policy.yaml:85:    agent: scribe
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:170:    agent: scribe
agents/_shared/autosend-policy.yaml:196:  bullhorn_scribe_field_write:
agents/_shared/autosend-policy.yaml:198:    agent: scribe
agents/_shared/autosend-policy.yaml:200:    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
agents/_shared/autosend-policy.yaml:252:    agent: scribe
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:568:      granted Scribe + Concierge; v0.3 extends to all 6.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:571:    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:587:      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
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
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/bullhorn-outreach-emails.md:117:> Public REST docs describe pull-only model. Is there an undocumented webhook or event-subscription mechanism available to integration partners? If not, we'll proceed with the polling model (already designed); if yes, we'd prefer to subscribe to placement-state-change events directly.
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:54:- **Webhook (v1.0 primary path):** per-provider HMAC / bearer token verified at the ingress per `tools.yaml` capability declarations (matching the Scribe webhook auth pattern).
agents/recruitment/cash-conductor/agent.md:88:| 4 | Fuzzy amount (±0.5% rounding) + matching payee name | 0.65 |
agents/recruitment/cash-conductor/agent.md:308:**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
docs/operations/founder-legal-setup-guide.md:108:Previous versions of this doc listed: **Bowers Anderson**, **LawBite**, **Privacy Helper**, **Vouch**. Their URLs did not resolve when I tested. These may be real firms at different URLs, or they may not exist as I described — I cited them from training-data memory without verification. If you Google these names and they look real + currently active, by all means contact them — but I cannot vouch for the citations I previously gave.
agents/recruitment/janitor/agent.md:263:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
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
agents/recruitment/scribe/agent.md:68:- Opportunity scoping (consultant + prospect) → Opportunity entity update (NOTE: Bullhorn endpoint A3 row covers Candidate / ClientCorporation / JobOrder / Note / Placement only at v1.0; Opportunity writes are to IFOS-cached Postgres entity rows for the v0.3-added fields headcount_growth_signal_text + hiring_velocity_band + decision_window_text per v0.3 supplement §1, NOT direct Bullhorn endpoint calls)
agents/recruitment/scribe/agent.md:75:| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
agents/recruitment/scribe/agent.md:80:Field names match canonical schema verbatim; some v0.1 fields (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `week_1_status_note`) are scheduled for v0.3 supplement at W6 build start — flagged here as pre-build references requiring schema-supplement landing before Scribe references them in `cycle.sh`. The Q1 verification pass (W6 Day 1) audits all field names against the schema as it exists then.
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:111:Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
agents/recruitment/scribe/agent.md:133:   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
agents/recruitment/scribe/agent.md:148:   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
agents/recruitment/scribe/agent.md:158:     a Scribe run with no resolvable target cannot produce structured writes)
agents/recruitment/scribe/agent.md:165:   → discard fields confidence <0.6 (per Gate A)
agents/recruitment/scribe/agent.md:166:   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
agents/recruitment/scribe/agent.md:168:     "<N> fields ≥0.6 confidence")
agents/recruitment/scribe/agent.md:176:   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md
agents/recruitment/scribe/agent.md:189:   → on success: hh_decision_action("bullhorn_scribe_field_write",
agents/recruitment/scribe/agent.md:203:   → if elapsed > 300 (5 min): info-level (counted against Gate B 90%)
agents/recruitment/scribe/agent.md:204:   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
agents/recruitment/scribe/agent.md:214:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:217:- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
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
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
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
agents/recruitment/scribe/agent.md:327:### Gotchas (carried forward from ULTRAPLAN A3 line 527)
agents/recruitment/scribe/agent.md:330:2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
agents/recruitment/scribe/agent.md:331:3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.
agents/recruitment/scribe/agent.md:341:- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
agents/recruitment/scribe/agent.md:345:- W6 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/scribe/agent.md:352:*End of Scribe agent.md draft.*
agents/recruitment/scribe/README.md:1:# Scribe — directory README
agents/recruitment/scribe/README.md:3:**Status:** Proposed (Day-17 pre-W6-build scaffold).
agents/recruitment/scribe/README.md:14:Full bundle at W6 build (~1 week per ULTRAPLAN A3 line 526):
agents/recruitment/scribe/README.md:16:- `tools.yaml` — Bullhorn W + Fathom R + Fireflies R + voice classifier
agents/recruitment/scribe/README.md:18:- `validate.sh` — Gate A (≥3 fields × confidence ≥0.6 + voice ≥0.75 + PII boundary)
agents/recruitment/scribe/README.md:29:*End of Scribe README.*
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:61:      - Scribe (R — voice samples for note-summary tone matching)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:128:      - Scribe (R — note format constraints)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:55:Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:131:5. **§5 honesty about validate.sh implementation** — agent.md §5 sections describe Gate A behaviour that may not be implemented in the corresponding `validate.sh`. For Diagnostic, validate.sh exists + has gaps (Issue 5). For the 5 new scaffolds, validate.sh DOESN'T exist yet — §5 describes intent. Disposition: explicitly mark "intended behaviour; cycle.sh + validate.sh implementation at W-X build will deliver this" in §5 of each pre-build scaffold.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:274:| Scribe | 5 | `20260524T112917Z-82352` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:316:  - Scribe Steps 2-3, 7 partial coverage
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:372:| Scribe | 5 | 4 | −1 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/operations/codex-round-2-handoff.md:373:Per master brief §10.6 + execution plan §5:
agents/recruitment/sourcing-scout/agent.md:265:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:140:| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/2026-05-18-codex-ratification-manifest.md:6:**Source:** Master brief §10 (the Codex ratification loop) + §10.6 (Day 7 first ratification run)
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:146:| 3 | `agents/recruitment/scribe/agent.md` | **REJECTED** | ~5-7 real findings (count regex 59) | `20260524T102202Z-22338` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:233:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/operations/codex-ratification-execution-plan.md:204:Per master brief §10.6 — mean cost is 20-30 min per artefact including the round-trip. Cluster batching reduces context-switching cost.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:390:7. **Master brief §10.6 timeline updated** with actual cost vs estimate. Founder-facing artefact.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
docs/architecture/architecture-cohesion-review.md:90:| A3 | **The `_shared/` symlink target `../../../_shared` resolves to `<org>/agents/_shared/`, not anywhere else.** | renderer.ts symlinkSync call | If filesystem semantics differ (mac vs linux), or someone moves the rendered dir, symlink could escape. macOS + Linux behaviour verified identical for this case. |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:21:| 6 | Scribe |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
agents/recruitment/diagnostic/agent.md:150:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
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
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:94:| Codex Round 4 execution | Master brief §10.6 ratification cadence |
docs/operations/goal-week-3-polish-and-scaffold.md:104:| Fathom/Fireflies MCP connector | Reserved for W6 |
docs/operations/goal-week-3-polish-and-scaffold.md:324:### DAY 17 — Scribe agent.md scaffold (Step 9)
docs/operations/goal-week-3-polish-and-scaffold.md:326:#### Step 9 — `agents/recruitment/scribe/agent.md` (~2-3 hours)
docs/operations/goal-week-3-polish-and-scaffold.md:329:- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:331:- `bullhorn-integration-path.md` §4.1 (Scribe's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:332:- `vertical-schema.yaml` §3 agent_access_matrix Scribe row
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:341:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:342:- **§5 Gate B:** ≥80% field-extraction accuracy (per consultant spot-check) + ≥90% within-10-min SLA.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:346:- **§9 Open questions:** 4-6 covering Fathom vs Fireflies first-mover choice, webhook auth, field-extraction model selection, tacit-note length cap.
docs/operations/goal-week-3-polish-and-scaffold.md:350:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:426:- **§5 Gate B:** <5% incorrect-send rate (per consultant feedback loop) + ≥90% lifecycle-event coverage (no missed transitions).
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:529:- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:617:  Scribe (W6):            <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:630:  <SHA>  decision(pre-build): agents/recruitment/scribe/agent.md
docs/operations/goal-week-3-polish-and-scaffold.md:656:    - Scribe build (depends on Bullhorn W + Fathom MCP)
docs/operations/goal-week-3-polish-and-scaffold.md:661:  - <Fathom/Fireflies signup for W6>
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:18:**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
docs/_archive-build-pack/02-PRODUCT-VISION.md:66:1. They upload the handbook, paste past replies, connect Fathom — material lands in the vault as markdown pages.
docs/build-brief/00-MASTER-BRIEF.md:5:**Synthesis stance:** First principles. The build pack in `docs/build-pack/` is **ignored** per founder instruction. The CLAUDE.md currently in the repo describes paths, remotes, and red lines — those are kept. Everything else in this brief is rebuilt from the verified state of the two upstream repos (`grandamenium/cortextos`, `tarsclaw/intel-force-os-v2`), Karpathy's LLM-wiki pattern, and the recruitment product spec, ultraplan, and 24/7 directive.
docs/build-brief/00-MASTER-BRIEF.md:311:│       │   ├── calls/            ← from Fathom/Fireflies transcripts
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:358:   provenance: [scribe-agent:call-2026-05-16-1432, janitor:bullhorn-2026-05-15]
docs/build-brief/00-MASTER-BRIEF.md:597:| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:762:### 10.6 The ratification timeline
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/_supplementary/PRD-autonomous-agent.md:871:// Step 4: Transcribe with Whisper
docs/_supplementary/PRD-autonomous-agent.md:872:export async function transcribeAudio(audioPath: string): Promise<WhisperTranscript> {
docs/_supplementary/PRD-autonomous-agent.md:2058:  "name": "Extraction pipeline (download → transcribe → analyse)",
docs/_supplementary/PRD-autonomous-agent.md:2068:- [ ] Build `src/extraction/transcribe.ts` — Whisper API integration
docs/_supplementary/PRD-autonomous-agent.md:2404:│   │   ├── transcribe.ts
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:238:- Process group includes one process per always-on agent the tenant has subscribed to.
docs/specs/ULTRAPLAN.md:348:- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
docs/specs/ULTRAPLAN.md:365:The LoRA improves voice score from ~80% (RAG + scaffolding) to ~90%+. This is what justifies the Scale tier at £6,950/mo.
docs/specs/ULTRAPLAN.md:515:#### A3. The Scribe — the data spine
docs/specs/ULTRAPLAN.md:517:- **Build wave:** v1.0 (week 6–7)
docs/specs/ULTRAPLAN.md:519:- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
docs/specs/ULTRAPLAN.md:521:- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
docs/specs/ULTRAPLAN.md:523:- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:525:- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
docs/specs/ULTRAPLAN.md:687:| Scribe | ✓ | ✓ | | | | | | ✓ | | | |
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:760:- Week 6: Scribe agent; Fathom + Fireflies MCP; tacit-note taxonomy v0.1
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:823:| 7 | Voice classifier underperforms (false positives blocking valid drafts) | Medium | Medium | First pilot reports >5% block rate on legitimate drafts | Soften the threshold from 0.75 → 0.65 for v1.0; tune up as corpus grows |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
docs/specs/_archive-build-handoff.md:328:git checkout -b agent/bullhorn-mcp        # or agent/janitor, agent/scribe, etc.
docs/specs/_archive-build-handoff.md:379:| 3 | **Scribe** | 6 | Fathom/Fireflies MCP + Bullhorn write | The post-call note that lands in Bullhorn within 10 min is the second-most-demoable result |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
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
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:83:| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/autosend-safety-policy.md:106:| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
docs/decisions/autosend-safety-policy.md:494:- **Per-recipient reputation:** recipients with high engagement may be in implicit "always-orange" zone; recipients with prior unsubscribes may be elevated to red.
docs/runbooks/day-4-provisioning.md:104:### §0.6 — Single LUKS volume, two bind mounts
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:13:Master brief §2.4 row 3 describes Primitive 3 (Inter-agent file bus) as:
docs/decisions/brain-ui-scope.md:148:The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/specs/PRODUCT-SPEC.md:110:#### R6. The Scribe — the call-to-context engine
docs/specs/PRODUCT-SPEC.md:112:- **Output contract:** Every call (Fathom, Fireflies, Ringover) gets parsed into ATS structured fields *and* tacit notes that don't fit any field: "client said they'd never hire from Bank X because of a 2019 grudge", "candidate's actual reason for leaving is the new line manager, not the salary". Tacit notes power every other agent's voice and judgement.
docs/specs/PRODUCT-SPEC.md:187:- **Revenue story:** "First 2 weeks of every contract done correctly, every time. No PAYE surprises in week 6 because RTW was checked on day 1." Avoids £5k–£40k per botched onboarding (back-claimed PAYE plus penalties).
docs/specs/PRODUCT-SPEC.md:242:| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:279:        │   The Scribe captures    │    │  The Janitor keeps it    │
docs/specs/PRODUCT-SPEC.md:297:The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**
docs/specs/PRODUCT-SPEC.md:329:- Customer clicks 5 OAuth buttons in the wizard: ATS (Bullhorn / Vincere / Voyager), accounting (Xero / Sage / QuickBooks), Microsoft 365 or Google Workspace, transcript source (Fathom / Fireflies / Ringover), LinkedIn.
docs/specs/PRODUCT-SPEC.md:473:- The Scribe (the data spine)
docs/specs/PRODUCT-SPEC.md:527:6. **The Scribe** — "Your firm's institutional memory finally lives somewhere."
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:59:| 03 | Proposal Builder | Sales | On call-end | £24,200 engagement | Fathom, HubSpot, Notion |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:131:- Specific: "Drafts a proposal 4 minutes after the Fathom call ends."
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:203:- Fathom (Proposal Builder)
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:42:**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:118:### 2.3 — A3 Scribe
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:127:| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
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
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:510:| Hire #1 onboarded and productive by W7 per Ultraplan §9 line 766 | Founder | End of W6 | Already tracked from RISK-REGISTER #4 |
docs/_supplementary/strategic-plan.md:82:2. **Proposal Builder** — the signature agent. Fathom call ends → draft proposal in inbox within 90 seconds
docs/_supplementary/strategic-plan.md:173:│  - MCP servers for: HubSpot, Fathom, Gmail, Slack, DocuSign,│
docs/_supplementary/strategic-plan.md:255:  - Current stack (checkboxes: HubSpot? Fathom? Gmail?)
docs/_supplementary/strategic-plan.md:259:  - Same for Fathom, Gmail, Slack, Calendly, Stripe, etc.
docs/_supplementary/strategic-plan.md:265:  - Per-agent config (e.g. Proposal Builder: which Fathom folder?
docs/_supplementary/strategic-plan.md:333:**Milestone**: the Proposal Builder agent actually takes a Fathom call and drafts a proposal. End-to-end.
docs/_supplementary/strategic-plan.md:337:- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
docs/_supplementary/strategic-plan.md:454:Force yourself to onboard one friendly client at week 6 (half-built, half-manual behind the scenes). Their pain will teach you more than any plan.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:303:- `src/telegram/transcribe.ts` (137 lines) + `src/telegram/media.ts` (217 lines) — voice-note transcription and image/document handling — past the "approval surface" minimum but indicates the surface is production-grade for general agent comms.
docs/architecture/cortexos-primitive-status.md:319:- `tests/unit/telegram/transcribe.test.ts` (92 lines).
docs/decisions/autosend-approval-bridge-spec.md:241:| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/_supplementary/planning-phase-brief.md:62:| 1.8 | Fathom Webhook Receiver Spec | **P** → CC2 builds |
docs/_supplementary/planning-phase-brief.md:177:- Session 24: Integration Specs Batch 1 — Fathom, HubSpot, Gmail, Slack, Notion, DocuSign (3.8)
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
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:757:- `append-to-narrative` — Concierge / Scribe logging; tolerates few-hundred-ms.
docs/architecture/second-brain-design.md:772:| Scribe | 3:1 | reads candidate for context on every call; writes structured fields + tacit notes |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:892:| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
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
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:93:  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:298:**Confirmed from Bullhorn public docs:** `https://bullhorn.github.io/rest-api-docs/` describes **no webhook, subscription, event-stream, or push-notification mechanism**. Operations covered: entity CRUD, query/search, file attachments, resume parsing, mass updates, entity metadata. Verified 2026-05-16.
docs/decisions/bullhorn-integration-path.md:308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
docs/decisions/bullhorn-integration-path.md:335:| Scribe (write-on-event) | 50-100 distributed | Event-rate-bounded; one call typically = 5-15 REST writes |
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:452:Joins the atomic correction commit at end of Week 0 / early Week 1. Codex ratifies the combined commit on Day 7 per master brief §10.6.

exec
/bin/zsh -lc "rg -n \"bullhorn_scribe_field_write|bullhorn_note_append_summary|yellow|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|hh_decision\" agents docs packages -g '*.yaml' -g '*.sh' -g '*.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:5:# hh_decision_action() invocation. Per-tenant overrides live in Postgres
agents/_shared/autosend-policy.yaml:8:# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:10:#   tier            green|yellow|orange|red
agents/_shared/autosend-policy.yaml:13:#   sample_rate     yellow only: 1-in-N for spot-check sampling
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:148:    tier: yellow
agents/_shared/autosend-policy.yaml:155:    tier: yellow
agents/_shared/autosend-policy.yaml:162:    tier: yellow
agents/_shared/autosend-policy.yaml:168:  bullhorn_note_append_summary:
agents/_shared/autosend-policy.yaml:169:    tier: yellow
agents/_shared/autosend-policy.yaml:176:    tier: yellow
agents/_shared/autosend-policy.yaml:183:    tier: yellow
agents/_shared/autosend-policy.yaml:190:    tier: yellow
agents/_shared/autosend-policy.yaml:196:  bullhorn_scribe_field_write:
agents/_shared/autosend-policy.yaml:197:    tier: yellow
agents/_shared/autosend-policy.yaml:204:    tier: yellow
agents/_shared/autosend-policy.yaml:211:    tier: yellow
agents/_shared/autosend-policy.yaml:367:  - "tier ∈ {green, yellow, orange, red}"
agents/_shared/autosend-policy.yaml:368:  - "yellow action_types MUST declare sample_rate (positive integer)"
agents/_shared/autosend-policy.yaml:371:  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
agents/_shared/autosend-policy.yaml:372:  - "47 total action_types (19 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:347:  #   Scout R+W. Implementation: cycle.sh + hh_decision_action records which
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:357:  # layer (cycle.sh + hh_decision_action) where the agent_name in the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:574:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
agents/_shared/hook-helpers.sh:3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:166:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:168:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:180:hh_decision_output() {
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:193:hh_decision_action() {
agents/_shared/hook-helpers.sh:224:    yellow)
agents/_shared/hook-helpers.sh:225:      autosend_emit_decision_log "action" "yellow" "${action_type}" \
agents/_shared/hook-helpers.sh:263:# Prints the tier (green|yellow|orange|red) to stdout; returns 0 if found,
agents/_shared/hook-helpers.sh:288:# Tenants can ELEVATE only (green→yellow→orange→red); red is the floor.
agents/_shared/hook-helpers.sh:318:  case "${base_tier}" in green) base_rank=0;; yellow) base_rank=1;; orange) base_rank=2;; red) base_rank=3;; *) return 1;; esac
agents/_shared/hook-helpers.sh:319:  case "${override}" in green) override_rank=0;; yellow) override_rank=1;; orange) override_rank=2;; red) override_rank=3;; *) return 1;; esac
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:51:hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/README.md:52:hh_decision_output  <output_type> <artefact_ref> [<reason>]
agents/_shared/README.md:53:hh_decision_action  <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/README.md:56:`hh_decision_action` is the **gated** call. Returns `0` if action allowed, `1` if blocked or approval rejected. All three write a `decision_log` row before returning.
agents/_shared/README.md:72:`hh_decision_action` dispatches per tier:
agents/_shared/README.md:77:| **yellow** | Emit `phase=action`, draw 1-in-N spot-check sample, return 0 | 0 |
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:120:   bash -c 'source agents/_shared/hook-helpers.sh; hh_decision_trigger "manual_smoke_test"'
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/tests/test-hook-helpers.sh:95:printf '\n[1] hh_decision_trigger writes a phase=trigger row\n'
agents/_shared/tests/test-hook-helpers.sh:98:  hh_decision_trigger "session_start" "boot"
agents/_shared/tests/test-hook-helpers.sh:106:printf '\n[2] hh_decision_output writes a phase=output row\n'
agents/_shared/tests/test-hook-helpers.sh:109:  hh_decision_output "diagnostic_report" "/vault/x/y.md"
agents/_shared/tests/test-hook-helpers.sh:119:test_lookup_yellow() { local t; t=$(autosend_policy_lookup "bullhorn_candidate_dedupe"); _assert_eq "yellow" "${t}" "yellow"; }
agents/_shared/tests/test-hook-helpers.sh:124:_test_run "policy_lookup → yellow" test_lookup_yellow
agents/_shared/tests/test-hook-helpers.sh:129:printf '\n[4] hh_decision_action — green tier emits action row, rc=0\n'
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
agents/_shared/tests/test-hook-helpers.sh:142:printf '\n[5] hh_decision_action — red tier emits gating_failed row, rc=1\n'
agents/_shared/tests/test-hook-helpers.sh:145:  hh_decision_action "xero_payment_initiate" "invoice:42" "def456" "test"
agents/_shared/tests/test-hook-helpers.sh:156:printf '\n[6] hh_decision_action — orange tier with test-mode approve → rc=0\n'
agents/_shared/tests/test-hook-helpers.sh:159:  HH_AWAIT_TEST_MODE=approve hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash1" "preview"
agents/_shared/tests/test-hook-helpers.sh:170:printf '\n[7] hh_decision_action — orange tier with test-mode reject → rc=1\n'
agents/_shared/tests/test-hook-helpers.sh:173:  HH_AWAIT_TEST_MODE=reject hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash2" "preview"
agents/_shared/tests/test-hook-helpers.sh:179:printf '\n[8] hh_decision_action — unknown action_type → ESC_AUTOSEND_POLICY_LOOKUP_FAILED\n'
agents/_shared/tests/test-hook-helpers.sh:182:  hh_decision_action "nonexistent_action" "x" "hash3" "preview"
agents/_shared/tests/test-hook-helpers.sh:245:printf '\n[13] autosend_should_sample — yellow tier with high rate eventually returns 0\n'
agents/_shared/tests/test-hook-helpers.sh:258:_test_run "yellow tier sampling fires within 200 draws" test_should_sample
agents/_shared/tests/test-hook-helpers.sh:270:printf '\n[15] hh_decision_action — yellow tier emits row + may enqueue spot-check\n'
agents/_shared/tests/test-hook-helpers.sh:271:test_action_yellow() {
agents/_shared/tests/test-hook-helpers.sh:273:  hh_decision_action "bullhorn_candidate_dedupe" "candidate:foo" "hash9" "preview"
agents/_shared/tests/test-hook-helpers.sh:277:  _assert_rc "0" "${rc}" "yellow_rc" \
agents/_shared/tests/test-hook-helpers.sh:278:    && _assert_contains "${row}" '"tier":"yellow"' \
agents/_shared/tests/test-hook-helpers.sh:281:_test_run "yellow action: rc=0 + phase=action + tier=yellow" test_action_yellow
agents/_shared/tests/test-hook-helpers.sh:293:    hh_decision_action "xero_payment_initiate" "invoice:${i}" "hashred${i}" "amount: £100"
agents/_shared/tests/test-voice-loader.sh:70:printf '\n[1] hh_load_tone_rules returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:73:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:78:printf '\n[2] hh_load_tone_rules reads tone-rules.yaml fallback path\n'
agents/_shared/tests/test-voice-loader.sh:86:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:91:printf '\n[3] hh_load_voice_samples returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:94:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:99:printf '\n[4] hh_load_voice_samples surfaces style guide when present\n'
agents/_shared/tests/test-voice-loader.sh:103:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:110:printf '\n[5] hh_load_voice_samples top_k validation clamps to 10\n'
agents/_shared/tests/test-voice-loader.sh:113:  out=$(hh_load_voice_samples "task" "abc")  # non-numeric → 10
agents/_shared/tests/test-voice-loader.sh:115:  out=$(hh_load_voice_samples "task" "999")  # over cap → 10
agents/_shared/tests/test-voice-loader.sh:117:  out=$(hh_load_voice_samples "task" "0")    # zero → 10
agents/_shared/tests/test-voice-loader.sh:122:printf '\n[6] hh_load_recent_edits returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:125:  out=$(hh_load_recent_edits)
agents/_shared/tests/test-voice-loader.sh:132:printf '\n[7] hh_load_recent_edits accepts custom lookback_days\n'
agents/_shared/tests/test-voice-loader.sh:135:  out=$(hh_load_recent_edits 7 "concierge")
agents/_shared/tests/test-voice-loader.sh:141:printf '\n[8] hh_load_recent_edits lookback_days validation clamps to 30\n'
agents/_shared/tests/test-voice-loader.sh:144:  out=$(hh_load_recent_edits "abc")  # non-numeric → 30
agents/_shared/tests/test-voice-loader.sh:146:  out=$(hh_load_recent_edits "999")   # over cap → 30
agents/_shared/tests/test-voice-loader.sh:148:  out=$(hh_load_recent_edits "0")     # zero → 30
agents/_shared/tests/test-voice-loader.sh:156:  out1=$(hh_load_tone_rules | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:157:  out2=$(hh_load_voice_samples "task" | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:158:  out3=$(hh_load_recent_edits | wc -l | tr -d ' ')
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:79:### Output 1 — Reconciliation rows (yellow tier)
agents/recruitment/cash-conductor/agent.md:91:Stages 1-2 auto-write reconciliation to accounting system (yellow tier; spot-check sampled). Stages 3-4 queue for consultant review. Stage 5 flagged in weekly report.
agents/recruitment/cash-conductor/agent.md:93:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:95:### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)
agents/recruitment/cash-conductor/agent.md:97:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 257) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:117:2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 182-187), payload links to the draft from row 1 — this row records that Cash Conductor classified the draft as yellow-tier internal.
agents/recruitment/cash-conductor/agent.md:149:14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
agents/recruitment/cash-conductor/agent.md:155:   → hh_decision_trigger("session_start", "<webhook|cron|manual>")
agents/recruitment/cash-conductor/agent.md:163:   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
agents/recruitment/cash-conductor/agent.md:178:   → hh_decision_output("transactions_ingested", "tenant:<slug>",
agents/recruitment/cash-conductor/agent.md:185:   → hh_decision_output("invoices_ingested", "tenant:<slug>", "<N> rows")
agents/recruitment/cash-conductor/agent.md:189:   → write Stage 1-2 matches to accounting (yellow tier) atomically
agents/recruitment/cash-conductor/agent.md:193:   → hh_decision_output("reconciliation_pass", "tenant:<slug>",
agents/recruitment/cash-conductor/agent.md:196:6. Reconciliation write (yellow tier; per match)
agents/recruitment/cash-conductor/agent.md:199:   → on success: hh_decision_action("accounting_reconciliation_write",
agents/recruitment/cash-conductor/agent.md:202:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
agents/recruitment/cash-conductor/agent.md:210:     hh_decision_output("chase_position_4_operator_review",
agents/recruitment/cash-conductor/agent.md:222:   → hh_decision_output("chase_draft_generated", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:238:   → hh_decision_output("chase_draft_validated", invoice_id, "passed")
agents/recruitment/cash-conductor/agent.md:242:    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:243:      payload_hash, payload_preview) — tier=yellow internal-draft per
agents/recruitment/cash-conductor/agent.md:245:    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:261:    → hh_decision_output("cash_conductor_chase_sent_recorded",
agents/recruitment/cash-conductor/agent.md:270:    → hh_decision_output("chase_cancellation_check", "invoice:<id>",
agents/recruitment/cash-conductor/agent.md:278:    → hh_decision_output("weekly_report", report_path,
agents/recruitment/cash-conductor/agent.md:283:    → hh_decision_action("cash_conductor_run_complete", "session:<session_id>",
agents/recruitment/cash-conductor/agent.md:285:      — hh_decision_action signature is (action_type, target, payload_hash,
agents/recruitment/cash-conductor/agent.md:346:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:356:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:360:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:361:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/agent.md:395:| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
docs/build-brief/00-MASTER-BRIEF.md:57:4. **Quality gates before features.** Gate A (per-run `validate.sh`) working + decision-log writes (`hh_decision_trigger / output / action`) present > extra features. `validate.sh` hard-fails on missing decision-log calls. No exceptions.
docs/build-brief/00-MASTER-BRIEF.md:508:| `phase-2-agent-suite/_shared/hook-helpers.sh` | Common validate/telemetry shell fns | `packages/agents-runtime/_shared/hooks/hook-helpers.sh` | Add `hh_decision_trigger/output/action` per Ultraplan §4.2 |
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:571:hh_decision_trigger   # at start; logs trigger
docs/build-brief/00-MASTER-BRIEF.md:572:hh_decision_output    # on output; logs the artefact
docs/build-brief/00-MASTER-BRIEF.md:573:hh_decision_action    # when human acts; logs the action
docs/build-brief/00-MASTER-BRIEF.md:672:                 │  → bus-overrides                    │   entity-graph svc                        │   hh_decision_*
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:127:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:133:   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
agents/recruitment/scribe/agent.md:139:   → hh_decision_output("webhook_verified", "call:<id>", "provider:<name>")
agents/recruitment/scribe/agent.md:159:   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>", confidence)
agents/recruitment/scribe/agent.md:167:   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
agents/recruitment/scribe/agent.md:177:   → hh_decision_output("tacit_note_rendered", "<vault_path>",
agents/recruitment/scribe/agent.md:186:8. Bullhorn write — structured fields (yellow tier)
agents/recruitment/scribe/agent.md:189:   → on success: hh_decision_action("bullhorn_scribe_field_write",
agents/recruitment/scribe/agent.md:193:9. Bullhorn write — tacit-note attachment (yellow tier)
agents/recruitment/scribe/agent.md:195:   → on success: hh_decision_action("bullhorn_note_append_summary",
agents/recruitment/scribe/agent.md:204:   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
agents/recruitment/scribe/agent.md:263:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
agents/recruitment/scribe/agent.md:272:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:276:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:255:        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:41:**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:43:**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:128:2. **Workflow steps missing decision-log calls** — most agent.md files have at least one Step (notification, operator alert, status update) that produces side-effects without `hh_decision_*` call. Same disposition as Diagnostic Issue 2 — mechanical fix during W4-13 build slices when cycle.sh is implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:159:1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:214:1. `operator_notify_telegram` + `janitor_run_complete` are unregistered hh_decision_action types — hook-helpers fails them to red via `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`. (Found because my Round-6 commit added those calls without registering them.)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:257:- Cat-2 (decision-log calls): added hh_decision_output / hh_decision_action calls across all §4 sections; pre-registered action_types via Phase 1
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:307:- Diagnostic cycle.sh: sends Telegram directly via curl with no `hh_decision_action` row
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:364:- `cycle.sh` adds `hh_decision_action("operator_notify_telegram", ...)` call before Step 14 Telegram send
agents/recruitment/sourcing-scout/agent.md:108:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:116:   → hh_decision_trigger("session_start", "scout <brief-id-or-slug>")
agents/recruitment/sourcing-scout/agent.md:124:   → hh_decision_output("brief_ingested", "<brief_id_or_slug>",
agents/recruitment/sourcing-scout/agent.md:147:   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
agents/recruitment/sourcing-scout/agent.md:161:   → hh_decision_output("bullhorn_query", "brief:<id>", "results:<N>")
agents/recruitment/sourcing-scout/agent.md:169:   → hh_decision_output("linkedin_query", "brief:<id>", "results:<N>")
agents/recruitment/sourcing-scout/agent.md:176:   → hh_decision_output("reed_query", "brief:<id>", "results:<N>")
agents/recruitment/sourcing-scout/agent.md:183:   → hh_decision_output("cvlibrary_query", "brief:<id>", "results:<N>")
agents/recruitment/sourcing-scout/agent.md:191:   → hh_decision_output("aggregate_dedupe", "brief:<id>",
agents/recruitment/sourcing-scout/agent.md:211:   → hh_decision_output("dnc_filter", "brief:<id>",
agents/recruitment/sourcing-scout/agent.md:221:   → hh_decision_output("candidate_proposed", "candidate:<bullhorn_id|external_ref>",
agents/recruitment/sourcing-scout/agent.md:234:    → hh_decision_output("scout_report", report_path, "N candidates from M sources")
agents/recruitment/sourcing-scout/agent.md:239:    → hh_decision_action("scout_run_complete", brief_id, payload_hash,
agents/recruitment/sourcing-scout/agent.md:310:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:315:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:316:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:65:### Output 2 — Bullhorn writes (yellow tier)
agents/recruitment/janitor/agent.md:69:1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:70:2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing canonical schema fields (per `vertical-schema.yaml`): `candidate.location` (line 124), `client.industry` (line 238), `client.size_employees` (line 243), `client.companies_house_number` (line 252), `contractor.day_rate_min/day_rate_max` (lines 193-197), `brief.salary_min/salary_max` (lines 371-376) from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload. Action type: **`bullhorn_field_backfill`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:71:3. **Tacit-note attach** (`POST /Note` linked to entity) — narrative summary of consultant edits + decision-log resolutions over the 30-day window. Action type: **`bullhorn_note_attach`** (registered in autosend-policy.yaml; yellow tier; sample_rate: 20).
agents/recruitment/janitor/agent.md:79:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:85:   → hh_decision_trigger("session_start", "janitor nightly cron")
agents/recruitment/janitor/agent.md:96:   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
agents/recruitment/janitor/agent.md:106:     hh_decision_action emitted at Step 9 when each merge actually writes)
agents/recruitment/janitor/agent.md:119:   → hh_decision_output("field_completeness_audit", tenant, "<N> missing-field rows")
agents/recruitment/janitor/agent.md:143:9. Bullhorn write batch (yellow tier — spot-check sampling)
agents/recruitment/janitor/agent.md:144:   → for each proposed merge / backfill / note: emit hh_decision_action with
agents/recruitment/janitor/agent.md:145:     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
agents/recruitment/janitor/agent.md:156:   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")
agents/recruitment/janitor/agent.md:160:   → if Gate-B target missed: yellow-tier notification + 200-char executive
agents/recruitment/janitor/agent.md:162:   → hh_decision_action("operator_notify_telegram", "tenant:<slug>",
agents/recruitment/janitor/agent.md:167:   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
agents/recruitment/janitor/agent.md:220:- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
agents/recruitment/janitor/agent.md:230:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:234:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/diagnostic/cleanup.sh:55:  hh_decision_action "linkedin_cache_purge_fail" "cleanup:${CTX_TENANT_SLUG}" \
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
packages/agent-renderer/templates/claude-md-preamble.md:22:- `hh_decision_trigger` at start of every run
packages/agent-renderer/templates/claude-md-preamble.md:23:- `hh_decision_output` before producing the artefact
packages/agent-renderer/templates/claude-md-preamble.md:24:- `hh_decision_action` when the human resolves
packages/agent-renderer/templates/claude-md-preamble.md:44:- `memory/` — replaced by Postgres `decision_log` (writes via `hh_decision_*` helpers).
agents/recruitment/diagnostic/cycle.sh:107:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:161:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:171:hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:188:hh_decision_output "diagnostic_report" "${REPORT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:191:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:214:    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:171:hh_decision_trigger     # Called at start of agent run; logs the trigger
docs/specs/ULTRAPLAN.md:172:hh_decision_output      # Called when agent produces output; logs the artefact
docs/specs/ULTRAPLAN.md:173:hh_decision_action      # Called when human acts on output; logs the action
agents/recruitment/diagnostic/validate.sh:265:  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
agents/recruitment/diagnostic/context.sh:25:#   - Emits hh_decision_trigger("session_start", ...) as first audit row
agents/recruitment/diagnostic/context.sh:83:hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
agents/recruitment/diagnostic/context.sh:85:    printf 'context.sh: hh_decision_trigger failed; vault may be unwritable\n' >&2
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/agent.md:73:- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
agents/recruitment/diagnostic/agent.md:74:- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
agents/recruitment/diagnostic/agent.md:75:- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
agents/recruitment/diagnostic/agent.md:81:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.
agents/recruitment/diagnostic/agent.md:86:   → hh_decision_trigger("session_start", firm_name + sector_hint)
agents/recruitment/diagnostic/agent.md:90:   → on fail: hh_decision_action("diagnostic_input_invalid", ...) with
agents/recruitment/diagnostic/agent.md:106:   → on empty stdout: hh_decision_action("diagnostic_generator_empty", ...) with
agents/recruitment/diagnostic/agent.md:110:   → hh_decision_output("diagnostic_draft", "<draft_path>", "<firm> 12-section draft (pre-validate)")
agents/recruitment/diagnostic/agent.md:117:   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
agents/recruitment/diagnostic/agent.md:127:   → hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")
agents/recruitment/diagnostic/agent.md:128:   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:133:     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:154:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:156:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:192:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:196:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:197:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
docs/specs/_archive-build-handoff.md:431:- **Decision logging is required** (Ultraplan §4.2 change 2). Every agent run writes three log entries via `hh_decision_trigger`, `hh_decision_output`, `hh_decision_action`. Missing calls = hard fail in validate.sh. This is what enables the per-tenant LoRA pipeline at v2.0.
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
agents/recruitment/concierge/agent.md:116:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:124:   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")
agents/recruitment/concierge/agent.md:134:   → hh_decision_output("lifecycle_event_detected",
agents/recruitment/concierge/agent.md:145:   → hh_decision_output("anti_duplicate_check", "<entity_type>:<bullhorn_id>",
agents/recruitment/concierge/agent.md:160:   → hh_decision_output("bullhorn_context_fetched",
agents/recruitment/concierge/agent.md:169:   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:176:   → hh_decision_output("template_selected", "<event_type>:<recipient_role>",
agents/recruitment/concierge/agent.md:184:   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:202:   → on success: hh_decision_action("concierge_email_draft",
agents/recruitment/concierge/agent.md:204:     tier=yellow per autosend-policy.yaml
agents/recruitment/concierge/agent.md:219:    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:233:    → hh_decision_action("gmail_outlook_send_to_candidate",
agents/recruitment/concierge/agent.md:242:    → hh_decision_output("bullhorn_activity_logged",
agents/recruitment/concierge/agent.md:249:    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:257:    → hh_decision_action("concierge_run_complete", session_id, run_mode)
agents/recruitment/concierge/agent.md:332:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:339:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:340:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/autosend-safety-policy.md:6:**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
docs/decisions/autosend-safety-policy.md:7:**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:90:| Agent | action_type | Sample rate | Why yellow |
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/autosend-safety-policy.md:128:## §4 — Integration with the `hh_decision_action` contract
docs/decisions/autosend-safety-policy.md:132:- `hh_decision_trigger` — at session start; logs the trigger
docs/decisions/autosend-safety-policy.md:133:- `hh_decision_output` — when the agent produces its output artefact
docs/decisions/autosend-safety-policy.md:134:- `hh_decision_action` — when an action is taken (or blocked)
docs/decisions/autosend-safety-policy.md:136:The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
docs/decisions/autosend-safety-policy.md:141:# hh_decision_action — gate every side-effecting action through the policy
docs/decisions/autosend-safety-policy.md:147:hh_decision_action() {
docs/decisions/autosend-safety-policy.md:178:    yellow)
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:222:  - bullhorn_note_draft_internal     # yellow (sample 1-in-10)
docs/decisions/autosend-safety-policy.md:352:| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:380:--   phase = 'action'         when allowed (green/yellow/orange-approved)
docs/decisions/autosend-safety-policy.md:384:--     "tier": "green|yellow|orange|red|fail-safe-red",
docs/decisions/autosend-safety-policy.md:433:      "bullhorn_note_internal": "yellow",
docs/decisions/autosend-safety-policy.md:461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
docs/decisions/autosend-safety-policy.md:466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
docs/decisions/autosend-safety-policy.md:493:- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
docs/decisions/autosend-safety-policy.md:511:classifies each agent action into one of four tiers: green, yellow,
docs/decisions/autosend-safety-policy.md:522:  (b) any action classified as yellow that passed spot-check review or
docs/decisions/autosend-safety-policy.md:598:| 3 | Policy lookup latency — must be <10ms per `hh_decision_action` call. Caching strategy needed (in-memory per session vs hot-reload). | §4 | Recommend in-memory cache per session (71h cache lifetime aligns with cortextOS context rotation). Hot-reload via PTY restart only. |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
docs/decisions/autosend-safety-policy.md:621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
docs/decisions/autosend-safety-policy.md:622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/autosend-safety-policy.md:643:2. `hh_decision_action` pseudocode per §4
docs/decisions/v1.0-kill-criterion.md:109:**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
docs/decisions/v1.0-kill-criterion.md:121:**Threshold:** Cost-per-completed-action (defined as: total IFOS infrastructure + API + Claude inference cost ÷ count of `decision_log` rows with `phase='action'` and `payload.tier IN ('green','yellow','orange-approved')`) exceeds **£0.50 per action** after 4 tenant-weeks of operation.
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/decisions/bullhorn-integration-path.md:324:- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).
docs/runbooks/tenant-lifecycle.md:148:| Agent draft + approve via Telegram | `hh_decision_action` writes to decision_log; orange-tier blocks on Telegram approval | T4 (every write sets SET LOCAL) |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/architecture/architecture-cohesion-review.md:71:| ADR-004 | phase enum pattern | `agents/_shared/hook-helpers.sh::hh_decision_action` | ✓ landed Phase 3 |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:307:# Gate A: hard-fail on missing hh_decision_* calls in this run
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:370:   `hh_decision_trigger` at start of every run
docs/architecture/agent-bundle-renderer-design.md:371:   `hh_decision_output` before producing the artefact
docs/architecture/agent-bundle-renderer-design.md:372:   `hh_decision_action` when the human resolves
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:427:| `update-entity` | Concierge (v1.0): append conversation note to Candidate page | v1.0 | `(id: str, section: str, content: str, tenant_id: str)` | `EntityRef` | few seconds | Targets the `<!-- BEGIN auto:{section} -->` block per §2.2.1; preserves frontmatter; rewrites backlinks if `display_name` changes; `hh_decision_*` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:676:| `ingest-entity` | Filesystem write (atomic) + Postgres UPSERT to `entities` + Postgres INSERTs to `entity_links` (all in one transaction per §2.6.1) | None — atomic or fail | Slug collision check via Postgres `SELECT 1 FROM entities WHERE tenant_slug = ? AND id = ?`. `hh_decision_trigger` + `hh_decision_output` calls insert to `decision_log` in the same transaction. |
docs/architecture/second-brain-design.md:682:| `entity-history` | Postgres `decision_log` SELECT by `(tenant_slug, entity_id)` ORDER BY `created_at DESC` | None | v1.1 read; v1.0 writes via `hh_decision_*`. No filesystem fallback — decision_log is unique source. |
docs/architecture/second-brain-design.md:712:- No corruption; both changes land; decision_log captures both `hh_decision_output` rows separately.
docs/architecture/second-brain-design.md:782:**Decision-log volume:** every agent run produces 1-3 `decision_log` rows (`hh_decision_trigger`, `hh_decision_output`, optionally `hh_decision_action` when human responds). At 6 v1.0 agents × ~10 runs/agent/day × 3 tenants × 3 rows = ~540 rows/day per shared Postgres instance. Trivial volume; the table needs hash partitioning (per Ultraplan §5.1) primarily for query performance at v1.2+ scale, not v1.0 write throughput.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
packages/agent-renderer/tests/fixtures/test-agent/agent.md:11:1. `hh_decision_trigger` at session start
packages/agent-renderer/tests/fixtures/test-agent/agent.md:13:3. Echo input + emit `hh_decision_output`
packages/agent-renderer/tests/fixtures/test-agent/agent.md:14:4. Wait for human resolve; emit `hh_decision_action`

codex
The first pass found likely load-bearing issues around schema readiness and workflow audit calls. I’m checking the exact source lines now so the verdict can cite the artefact precisely rather than relying on broad impressions.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '260,430p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '40,260p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.1
     2	# ============================================================================
     3	# Layered above the Day-4 generic primitives:
     4	#   - entities (id, tenant_slug, entity_type, entity_id, data JSONB, version, ...)
     5	#   - entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
     6	#   - decision_log (..., agent_name, phase, payload JSONB, ...)
     7	# This file specifies the recruitment-domain entity_type + link_type slugs
     8	# and the JSON Schema shape of entities.data per entity_type.
     9	#
    10	# Source: master brief §6 Day 6 line 490 (8 core entities)
    11	#       + bullhorn-integration-path.md §4.1 (per-agent endpoint requirements)
    12	#       + autosend-safety-policy.md §3 (action_type references)
    13	#       + Day-4 runbook §6.3 (canonical Postgres schema)
    14	#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
    15	# ============================================================================
    16	
    17	vertical: recruitment
    18	version: v0.1
    19	status: Proposed
    20	date: 2026-05-18
    21	author: founder (Maddox), Day-6 draft via Claude Code
    22	codex_ratification_queue_position: 18
    23	
    24	non_goals:
    25	  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
    26	  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
    27	  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
    28	
    29	# ============================================================================
    30	# §1 — Entity definitions
    31	# ============================================================================
    32	# Each entity below specifies:
    33	#   - description: 1-2 sentence definition in the IFOS canonical vocabulary
    34	#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
    35	#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
    36	#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
    37	#   - notes: anything entity-specific worth flagging
    38	#
    39	# Field types follow JSON Schema conventions: type = string | integer | number | boolean | array | object | (ISO 8601) timestamp / date
    40	# `required: true` means the entity cannot be persisted without this field set; `required: false` means nullable.
    41	# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
    42	# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
    43	# ============================================================================
    44	
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
   181	        required: false
   182	        source: Bullhorn.Candidate.email
   183	      mobile:
   184	        type: string
   185	        required: false
   186	        source: Bullhorn.Candidate.mobile
   187	      ir35_status:
   188	        type: string
   189	        required: true
   190	        enum: [inside_ir35, outside_ir35, undetermined, exempt_small_business]
   191	        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
   192	        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
   193	      day_rate_min:
   194	        type: number
   195	        required: false
   196	        source: IFOS-derived (Scribe extracts from call; GBP per day)
   197	      day_rate_max:
   198	        type: number
   199	        required: false
   200	        source: IFOS-derived (GBP per day)
   201	      umbrella_company:
   202	        type: string
   203	        required: false
   204	        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
   205	        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
   206	      availability_weeks:
   207	        type: integer
   208	        required: false
   209	        source: IFOS-derived (when can contractor start, in weeks from now)
   210	      current_engagement_end_date:
   211	        type: date
   212	        required: false
   213	        source: IFOS-derived
   214	        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
   215	    notes:
   216	      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
   217	      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
   218	      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
   219	
   220	  # --------------------------------------------------------------------------
   221	  client:
   222	    description: |
   223	      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
   224	    bullhorn_source: Bullhorn.ClientCorporation
   225	    v1_0_agent_access:
   226	      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
   227	      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
   228	      - Concierge (R — relationship context per bullhorn §4.1 A6)
   229	    canonical_fields:
   230	      bullhorn_id:
   231	        type: integer
   232	        required: true
   233	        source: Bullhorn.ClientCorporation.id
   234	      name:
   235	        type: string
   236	        required: true
   237	        source: Bullhorn.ClientCorporation.name
   238	      industry:
   239	        type: string
   240	        required: false
   241	        source: Bullhorn.ClientCorporation.industryList
   242	        notes: Bullhorn stores as multi-value; v0.1 flattens to primary industry only.
   243	      size_employees:
   244	        type: string
   245	        required: false
   246	        enum: [1-10, 11-50, 51-200, 201-500, 501-1000, 1001-5000, 5000+]
   247	        source: Bullhorn.ClientCorporation.numEmployees (bucketed)
   248	      website:
   249	        type: string
   250	        required: false
   251	        source: Bullhorn.ClientCorporation.companyURL
   252	      companies_house_number:
   253	        type: string
   254	        required: false
   255	        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
   256	        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
   257	      status:
   258	        type: string
   259	        required: true
   260	        enum: [active, dormant, churned, prospect]

 succeeded in 0ms:
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
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '90,200p'; nl -ba agents/_shared/escalation-codes.md | sed -n '300,460p'" in /Users/madsadmin/code/CortexOS
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
   191	### 2.6 — Cross-cutting infrastructure (6 codes)
   192	Source: derived from operational discipline + sequencing-target §5
   193	
   194	#### `ESC_HUMAN_EDITING_LOCK`
   195	- **Severity:** info
   196	- **Trigger:** Manual editing lock held by founder; agent backs off and reschedules
   197	- **Phase:** `gating_failed`
   198	- **Routing:** log-only (no Telegram noise)
   199	- **Payload fields:** `vault_path`, `lock_age_seconds`
   200	
   300	  - **≤14 days remaining:** warn — operator nudge to schedule reauth this week
   301	  - **≤7 days remaining:** blocking — Cash Conductor enters degraded mode (cached balance only; no fresh bank-feed reads); operator must complete SCA reauth before token expires
   302	- **Phase:** `gating_failed`
   303	- **Routing:** `operator_chat_id` (info + warn stages); ADD `ifos_oncall_chat_id` at blocking stage
   304	- **Payload fields:** `consent_expires_at`, `days_remaining`, `bank_provider`, `stage` (`info` | `warn` | `blocking`)
   305	- **Recovery:** founder schedules + completes Open Banking SCA reauth via tenant's bank login
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
   331	#### `ESC_SEND_FAIL`
   332	- **Severity:** warn — distinct from auth/rate-limit; the send itself failed at the protocol layer
   333	- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
   334	- **Phase:** `gating_failed`
   335	- **Routing:** `operator_chat_id`
   336	- **Payload fields:** `channel` (`gmail` | `outlook` | `twilio` | `telegram`), `recipient_id_hash`, `error_class`, `attempts_made`
   337	
   338	### 2.9 — Auto-send orchestration (4 codes)
   339	Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
   340	
   341	#### `ESC_AUTOSEND_ORANGE_PENDING`
   342	- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
   343	- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
   344	- **Phase:** `action`
   345	- **Routing:** `operator_chat_id` (gentle reminder; no oncall)
   346	- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
   347	
   348	#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
   349	- **Severity:** warn — orange action's approval window expired without response
   350	- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
   351	- **Phase:** `gating_failed`
   352	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
   353	- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
   354	- **Recovery:** action converts to manual reconciliation; operator handles offline
   355	
   356	#### `ESC_AUTOSEND_RACE`
   357	- **Severity:** warn — concurrency / state-change race
   358	- **Trigger:** A send is about to fire when the underlying state has changed in a way that should suppress it. Two canonical use cases:
   359	  - **Duplicate-payload race:** two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict; second wins-suppressed (first sends; idempotency by payload_hash)
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
   401	- **Severity:** warn
   402	- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
   403	- **Phase:** `gating_failed`
   404	- **Routing:** `operator_chat_id`
   405	- **Payload fields:** `candidate_id`, `missing_fields` (list), `shortlist_id`, `brief_id`
   406	
   407	#### `ESC_ADDRESSEE_MISMATCH`
   408	- **Severity:** **blocking** — outbound send refused (whichever agent firing)
   409	- **Trigger:** Outbound recipient resolution failed — addressee does not match the entity whose lifecycle/event triggered the send. Two canonical use cases:
   410	  - **Cash Conductor:** chase/reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure between accounting + ATS)
   411	  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
   412	- **Phase:** `gating_failed`
   413	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   414	- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
   415	- **Recovery:** operator reviews; either reconciles manually OR updates one system to match
   416	
   417	#### `ESC_RECONCILIATION_AMBIGUOUS`
   418	- **Severity:** warn — Cash Conductor cannot confidently match incoming payment to a specific invoice
   419	- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
   420	- **Phase:** `gating_failed`
   421	- **Routing:** `operator_chat_id`
   422	- **Payload fields:** `payment_id`, `amount`, `payee_name_raw`, `candidate_invoice_ids` (list), `match_basis` (e.g. `amount_only`, `payee_partial`)
   423	
   424	#### `ESC_DNC_FILTER_HIT`
   425	- **Severity:** **blocking** — outbound (email / SMS / call) refused
   426	- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
   427	- **Phase:** `gating_failed`
   428	- **Routing:** `operator_chat_id`
   429	- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`
   430	
   431	#### `ESC_CONCIERGE_SLA_MISS`
   432	- **Severity:** warn — aggregated to Gate B (not a per-event block)
   433	- **Trigger:** Concierge SLA breached. Three canonical sla_types:
   434	  - `brief_ack`: inbound brief not acknowledged within 4h (default)
   435	  - `customer_reply`: customer reply not actioned within 24h (default)
   436	  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
   437	- **Phase:** `gating_failed`
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
   449	- **Severity:** warn — agent cannot determine entity state for downstream action
   450	- **Trigger:** Lifecycle state is ambiguous or outside the agent's known taxonomy. Two canonical use cases:
   451	  - **Janitor:** placement record has ambiguous lifecycle markers (e.g. start_date present but no end_date AND no `active` flag AND no recent activity); Janitor cannot safely tag or update
   452	  - **Concierge:** Bullhorn state transition is outside the 12-event v1.0 taxonomy (acknowledgement / prep / debrief / placement / rejection / withdrawal / on-hold / start-confirm / 7d-checkin / 30d-checkin / 90d-checkin / nurture); handler logs + skips draft
   453	- **Phase:** `gating_failed`
   454	- **Routing:** `operator_chat_id`
   455	- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields
   456	
   457	---
   458	
   459	## §3 — Reserved codes (not-yet-wired)
   460	

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,230p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg -n \"A3|Scribe|Week 6|W6|Fathom|Fireflies|processed within 5 minutes|0\\.6|tacit\" docs -g '*.md'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg --files docs | rg 'master|ULTRAPLAN|ultra|brief'" in /Users/madsadmin/code/CortexOS
 succeeded in 218ms:
     1	# IFOS auto-send policy (runtime table)
     2	#
     3	# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
     4	# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
     5	# hh_decision_action() invocation. Per-tenant overrides live in Postgres
     6	# tenant_adapters.config.tier_overrides (§8).
     7	#
     8	# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
     9	# Each row carries:
    10	#   tier            green|yellow|orange|red
    11	#   agent           v1.0 owning agent (or "all" if cross-cutting red rule)
    12	#   reason          short rationale (mirrors §3 column 3)
    13	#   sample_rate     yellow only: 1-in-N for spot-check sampling
    14	#   block_reason    red only: enum from §3 red table column 2
    15	#   timeout         orange only: ISO-8601 duration; default PT4H if absent
    16	#   irreversible    boolean; informational — drives operator UX framing
    17	#
    18	# Schema validated by common-base.json $refs via render-time pre-flight.
    19	# Schema version stamps decision_log.payload.policy_version_sha at write time.
    20	
    21	version: "v1.0-2026-05-24"
    22	
    23	action_types:
    24	
    25	  # ───────────────────────────────────────────────────────────
    26	  # GREEN — auto-send without review (19 action_types)
    27	  # ───────────────────────────────────────────────────────────
    28	
    29	  diagnostic_report_render:
    30	    tier: green
    31	    agent: diagnostic
    32	    reason: "Internal artefact write; no external comms; idempotent (re-render overwrites)"
    33	    irreversible: false
    34	
    35	  bullhorn_candidate_tag:
    36	    tier: green
    37	    agent: janitor
    38	    reason: "Adds tag with checked_at date; reversible in <30s; high volume"
    39	    irreversible: false
    40	
    41	  bullhorn_note_internal:
    42	    tier: green
    43	    agent: scribe
    44	    reason: "Internal-only Bullhorn note (isExternal: false); consultant-visible; non-customer-facing"
    45	    irreversible: false
    46	
    47	  linkedin_profile_cache:
    48	    tier: green
    49	    agent: sourcing-scout
    50	    reason: "Stores profile snapshot to /vault/<tenant>/wiki/raw/; no external send; no rate-limit cost"
    51	    irreversible: false
    52	
    53	  xero_query_invoices:
    54	    tier: green
    55	    agent: cash-conductor
    56	    reason: "Read-only Xero query; rate-limited via Xero's own quotas; no side effect"
    57	    irreversible: false
    58	
    59	  bullhorn_brief_read:
    60	    tier: green
    61	    agent: concierge
    62	    reason: "Read of inbound brief; idempotent; no comms"
    63	    irreversible: false
    64	
    65	  operator_notify_telegram:
    66	    tier: green
    67	    agent: all
    68	    reason: "Internal operator-only Telegram notification (escalations + run-complete markers); not customer-facing; idempotent within decision_log payload_hash dedup window"
    69	    irreversible: false
    70	
    71	  janitor_run_complete:
    72	    tier: green
    73	    agent: janitor
    74	    reason: "Internal run-complete status marker written to decision_log; no external comms; informational"
    75	    irreversible: false
    76	
    77	  scout_run_complete:
    78	    tier: green
    79	    agent: sourcing-scout
    80	    reason: "Internal run-complete status marker; no external comms"
    81	    irreversible: false
    82	
    83	  scribe_run_complete:
    84	    tier: green
    85	    agent: scribe
    86	    reason: "Internal run-complete status marker; no external comms"
    87	    irreversible: false
    88	
    89	  concierge_run_complete:
    90	    tier: green
    91	    agent: concierge
    92	    reason: "Internal run-complete status marker; the inbound-brief acknowledgement cycle wraps; no external comms"
    93	    irreversible: false
    94	
    95	  concierge_send_complete:
    96	    tier: green
    97	    agent: concierge
    98	    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
    99	    irreversible: false
   100	
   101	  cash_conductor_run_complete:
   102	    tier: green
   103	    agent: cash-conductor
   104	    reason: "Internal run-complete status marker; no external comms"
   105	    irreversible: false
   106	
   107	  consultant_feedback:
   108	    tier: green
   109	    agent: all
   110	    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
   111	    irreversible: false
   112	
   113	  validate_gate_a_fail:
   114	    tier: green
   115	    agent: all
   116	    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
   117	    irreversible: false
   118	
   119	  diagnostic_input_invalid:
   120	    tier: green
   121	    agent: diagnostic
   122	    reason: "Internal audit row written by cycle.sh Step 1 when firm-name validation fails. Carries ESC_INPUT_VALIDATION_FAIL payload; just the audit-row write, not external send."
   123	    irreversible: false
   124	
   125	  diagnostic_generator_empty:
   126	    tier: green
   127	    agent: diagnostic
   128	    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
   129	    irreversible: false
   130	
   131	  linkedin_cache_purge_fail:
   132	    tier: green
   133	    agent: all
   134	    reason: "Internal audit row written by cleanup.sh when the transient LinkedIn /tmp cache cannot be purged (defense-in-depth per LinkedIn ToS gotcha; tools.yaml sets ttl=0 but explicit purge can still fail). Operator must manually verify cache cleared."
   135	    irreversible: false
   136	
   137	  diagnostic_cleanup:
   138	    tier: green
   139	    agent: diagnostic
   140	    reason: "Internal audit row written by cleanup.sh at end of normal-completion run. Records cache-purge status + workspace cleanup; no external comms."
   141	    irreversible: false
   142	
   143	  # ───────────────────────────────────────────────────────────
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
   207	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   208	    irreversible: false
   209	
   210	  concierge_email_draft:
   211	    tier: yellow
   212	    agent: concierge
   213	    sample_rate: 20
   214	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   215	    irreversible: false
   216	
   217	  # ───────────────────────────────────────────────────────────
   218	  # ORANGE — per-action human approval (10 action_types)
   219	  # ───────────────────────────────────────────────────────────
   220	
   221	  bullhorn_note_customer_visible:
   222	    tier: orange
   223	    agent: concierge
   224	    timeout: PT4H
   225	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   226	    irreversible: true
   227	    canonical: true
   228	
   229	  gmail_outlook_send_to_candidate:
   230	    tier: orange

 succeeded in 233ms:
docs/build-brief/00-MASTER-BRIEF.md
docs/_supplementary/planning-phase-brief.md
docs/specs/ULTRAPLAN.md

 succeeded in 247ms:
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:348:- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
docs/specs/ULTRAPLAN.md:515:#### A3. The Scribe — the data spine
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
docs/specs/PRODUCT-SPEC.md:110:#### R6. The Scribe — the call-to-context engine
docs/specs/PRODUCT-SPEC.md:112:- **Output contract:** Every call (Fathom, Fireflies, Ringover) gets parsed into ATS structured fields *and* tacit notes that don't fit any field: "client said they'd never hire from Bank X because of a 2019 grudge", "candidate's actual reason for leaving is the new line manager, not the salary". Tacit notes power every other agent's voice and judgement.
docs/specs/PRODUCT-SPEC.md:117:- **Per-tenant config:** transcript-source OAuth, ATS field-mapping rules, tacit-note retention policy, banned-extraction patterns (anything sensitive that shouldn't be captured).
docs/specs/PRODUCT-SPEC.md:242:| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:279:        │   The Scribe captures    │    │  The Janitor keeps it    │
docs/specs/PRODUCT-SPEC.md:297:The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**
docs/specs/PRODUCT-SPEC.md:329:- Customer clicks 5 OAuth buttons in the wizard: ATS (Bullhorn / Vincere / Voyager), accounting (Xero / Sage / QuickBooks), Microsoft 365 or Google Workspace, transcript source (Fathom / Fireflies / Ringover), LinkedIn.
docs/specs/PRODUCT-SPEC.md:473:- The Scribe (the data spine)
docs/specs/PRODUCT-SPEC.md:527:6. **The Scribe** — "Your firm's institutional memory finally lives somewhere."
docs/specs/_archive-build-handoff.md:379:| 3 | **Scribe** | 6 | Fathom/Fireflies MCP + Bullhorn write | The post-call note that lands in Bullhorn within 10 min is the second-most-demoable result |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:159:1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:274:| Scribe | 5 | `20260524T112917Z-82352` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:316:  - Scribe Steps 2-3, 7 partial coverage
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:372:| Scribe | 5 | 4 | −1 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:6:**Source:** Master brief §10 (the Codex ratification loop) + §10.6 (Day 7 first ratification run)
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:233:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:140:| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
docs/architecture/architecture-cohesion-review.md:90:| A3 | **The `_shared/` symlink target `../../../_shared` resolves to `<org>/agents/_shared/`, not anywhere else.** | renderer.ts symlinkSync call | If filesystem semantics differ (mac vs linux), or someone moves the rendered dir, symlink could escape. macOS + Linux behaviour verified identical for this case. |
docs/decisions/brain-ui-scope.md:148:The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/_archive-build-pack/02-PRODUCT-VISION.md:66:1. They upload the handbook, paste past replies, connect Fathom — material lands in the vault as markdown pages.
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/_supplementary/PRD-autonomous-agent.md:2349:### Phase 6: Production Run (Week 6+)
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:42:**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:118:### 2.3 — A3 Scribe
docs/decisions/sequencing-target.md:122:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 526 estimate **M (1 week)**. Webhook-driven not always-on. Structured-field mapping is per-firm config not code per Ultraplan §8.1 line 526. Tacit-note extraction is the hard part per Ultraplan §8.1 line 527 ("Start with a small taxonomy (5-10 tacit-note types) and expand") |
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:127:| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
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
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:316:- **Decider:** founder, on Week 6 weekly review.
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:510:| Hire #1 onboarded and productive by W7 per Ultraplan §9 line 766 | Founder | End of W6 | Already tracked from RISK-REGISTER #4 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:21:| 6 | Scribe |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:59:| 03 | Proposal Builder | Sales | On call-end | £24,200 engagement | Fathom, HubSpot, Notion |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:131:- Specific: "Drafts a proposal 4 minutes after the Fathom call ends."
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:203:- Fathom (Proposal Builder)
docs/decisions/autosend-approval-bridge-spec.md:241:| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/operations/codex-round-2-handoff.md:373:Per master brief §10.6 + execution plan §5:
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:83:| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/autosend-safety-policy.md:106:| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:94:| Codex Round 4 execution | Master brief §10.6 ratification cadence |
docs/operations/goal-week-3-polish-and-scaffold.md:104:| Fathom/Fireflies MCP connector | Reserved for W6 |
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:304:- **§3 Output shape:** day-30 report has 8 sections per ULTRAPLAN line 511 (record counts, dedup pairs, field-completeness deltas, tacit-note coverage, agent vs. consultant attribution, gate-B metric, exception list, executive summary).
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:324:### DAY 17 — Scribe agent.md scaffold (Step 9)
docs/operations/goal-week-3-polish-and-scaffold.md:329:- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:331:- `bullhorn-integration-path.md` §4.1 (Scribe's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:332:- `vertical-schema.yaml` §3 agent_access_matrix Scribe row
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:339:- **§3 Output shape:** Bullhorn write payload (entity-type-specific JSON) + 1 tacit-note attachment + 1 audit row in decision_log.
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:341:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:344:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:346:- **§9 Open questions:** 4-6 covering Fathom vs Fireflies first-mover choice, webhook auth, field-extraction model selection, tacit-note length cap.
docs/operations/goal-week-3-polish-and-scaffold.md:350:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:529:- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:617:  Scribe (W6):            <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:656:    - Scribe build (depends on Bullhorn W + Fathom MCP)
docs/operations/goal-week-3-polish-and-scaffold.md:661:  - <Fathom/Fireflies signup for W6>
docs/operations/goal-week-3-polish-and-scaffold.md:683:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:93:  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
docs/decisions/bullhorn-integration-path.md:335:| Scribe (write-on-event) | 50-100 distributed | Event-rate-bounded; one call typically = 5-15 REST writes |
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:452:Joins the atomic correction commit at end of Week 0 / early Week 1. Codex ratifies the combined commit on Day 7 per master brief §10.6.
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
docs/_supplementary/build-plan-original.md:795:### Cost: £0.60/mo. Build: 1 week (lots of integrations).
docs/_supplementary/build-plan-original.md:1080:                       (Fathom, Stripe, DocuSign, HubSpot) via their APIs
docs/_supplementary/build-plan-original.md:1197:1. Verify signature (every integration has its own: Fathom uses HMAC, Stripe uses stripe-signature, HubSpot has timestamp+signature)
docs/_supplementary/build-plan-original.md:1204:- **At-least-once** processing — fine because agent outputs are idempotent by design (same Fathom call ID → same proposal location, overwritten)
docs/_supplementary/build-plan-original.md:1255:| Fathom | Community MCP (matthewbergvinson, Dot-Fun) | Fork, harden, productize |
docs/_supplementary/build-plan-original.md:1516:- Week 1: Runtime proof-of-concept — **Proposal Builder end-to-end** in one container, one real Fathom call → proposal in inbox. This is the week-1 experiment from v2. Nothing else.
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/operations/codex-ratification-execution-plan.md:204:Per master brief §10.6 — mean cost is 20-30 min per artefact including the round-trip. Cluster batching reduces context-switching cost.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:390:7. **Master brief §10.6 timeline updated** with actual cost vs estimate. Founder-facing artefact.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
docs/_supplementary/planning-phase-brief.md:62:| 1.8 | Fathom Webhook Receiver Spec | **P** → CC2 builds |
docs/_supplementary/planning-phase-brief.md:177:- Session 24: Integration Specs Batch 1 — Fathom, HubSpot, Gmail, Slack, Notion, DocuSign (3.8)
docs/runbooks/day-4-provisioning.md:104:### §0.6 — Single LUKS volume, two bind mounts
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/_supplementary/strategic-plan.md:82:2. **Proposal Builder** — the signature agent. Fathom call ends → draft proposal in inbox within 90 seconds
docs/_supplementary/strategic-plan.md:173:│  - MCP servers for: HubSpot, Fathom, Gmail, Slack, DocuSign,│
docs/_supplementary/strategic-plan.md:255:  - Current stack (checkboxes: HubSpot? Fathom? Gmail?)
docs/_supplementary/strategic-plan.md:259:  - Same for Fathom, Gmail, Slack, Calendly, Stripe, etc.
docs/_supplementary/strategic-plan.md:265:  - Per-agent config (e.g. Proposal Builder: which Fathom folder?
docs/_supplementary/strategic-plan.md:333:**Milestone**: the Proposal Builder agent actually takes a Fathom call and drafts a proposal. End-to-end.
docs/_supplementary/strategic-plan.md:337:- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
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
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/second-brain-design.md:172:│   │   ├── calls/                                  ← Fathom/Fireflies transcripts (master brief §5.1 line 318)
docs/architecture/second-brain-design.md:204:| `wiki/raw/calls/` | one file per call | markdown with frontmatter | `{epoch}-{call-id}.md` | Scribe (v1.0) on Fathom/Fireflies webhook | Brief Decoder (v1.1), Concierge (v1.0) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:274:{Janitor or Scribe one-paragraph summary, regenerated on each ingest}
docs/architecture/second-brain-design.md:277:{auto-appended by Concierge / Scribe — chronological, agent-attributed}
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:757:- `append-to-narrative` — Concierge / Scribe logging; tolerates few-hundred-ms.
docs/architecture/second-brain-design.md:772:| Scribe | 3:1 | reads candidate for context on every call; writes structured fields + tacit notes |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/build-brief/00-MASTER-BRIEF.md:311:│       │   ├── calls/            ← from Fathom/Fireflies transcripts
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:597:| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:762:### 10.6 The ratification timeline
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '515,528p'; nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '590,600p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|packages/harness/cortextos|kb-|brain system|stock KB|/vault|Postgres|decision_log" agents/recruitment/scribe/agent.md' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "''^  contact:|''^  brief:|''^  placement:|''^  opportunity:|decision_authority|salary_min|salary_max|start_date|role_type|sector|week_1_status_note|headcount_growth_signal_text|satisfaction_signal" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:283:  contact:
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:341:  brief:
docs/verticals/recruitment/vertical-schema.yaml:366:      role_type:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:376:      salary_max:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:
docs/verticals/recruitment/vertical-schema.yaml:495:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:760:  contact:
docs/verticals/recruitment/vertical-schema.yaml:765:  brief:
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:777:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:16:# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:98:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:125:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:166:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:203:      satisfaction_signal:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:216:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:218:      headcount_growth_signal_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:278:#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:392:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:470:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:484:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:493:      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:496:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:511:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:966:      placement_status, week_1_status_vault_path, satisfaction_signal,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:967:      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:968:      are now schema-backed. (Note: week_1_status_note narrative now lives
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:971:      seniority — not yet in schema; brief.start_date should be
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:972:      start_date_target; opportunity.sector — not yet in schema). These

 succeeded in 0ms:
16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
68:- Opportunity scoping (consultant + prospect) → Opportunity entity update (NOTE: Bullhorn endpoint A3 row covers Candidate / ClientCorporation / JobOrder / Note / Placement only at v1.0; Opportunity writes are to IFOS-cached Postgres entity rows for the v0.3-added fields headcount_growth_signal_text + hiring_velocity_band + decision_window_text per v0.3 supplement §1, NOT direct Bullhorn endpoint calls)
82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
176:   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md

exec
/bin/zsh -lc "rg --files | rg 'autosend-safety-policy\\.yaml|autosend-policy\\.yaml'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml

exec
/bin/zsh -lc 'ls -la .codex 2>/dev/null; rg --files .codex 2>/dev/null | head -20' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
total 0
drwxr-xr-x@  3 madsadmin  staff   96 May 20 13:08 .
drwxr-xr-x@ 25 madsadmin  staff  800 May 24 11:04 ..
drwxr-xr-x@  7 madsadmin  staff  224 May 24 11:19 ratification
.codex/ratification/review-agent-bundle.md
.codex/ratification/SKILL.md
.codex/ratification/review-postgres-migration.md
.codex/ratification/review-schema-change.md
.codex/ratification/review-architecture-decision.md

codex
REJECTED

1. §3 assumes fields that are not schema-backed. Lines 76-80 list `brief.start_date`, `placement.week_1_status_note`, and `opportunity.sector` as canonical/schema-verified, but `vertical-schema.yaml` uses `start_date_target` and the v0.3 supplement explicitly says `week_1_status_note` became `week_1_status_vault_path` and `opportunity.sector` is not yet in schema. Fix the field table to use schema-backed names or land the missing supplement before ratification.

2. §4 workflow omits required `hh_decision_*` calls on output/action steps. Lines 141-149 refresh Bullhorn auth and fetch/store a transcript in `/tmp` without any decision-log write; lines 180-184 validate and mutate the extracted field set without a `hh_decision_output` or Gate-A failure action. Add decision-log calls for each output/action/failure point or mark the steps as purely internal with no side effect.

3. Ringover is declared as v1.0-supported without matching build dependencies. Lines 16, 30, and 39 include Ringover as a provider, but §8 lines 295-298 only gate Fathom/Fireflies signup and connector work; ULTRAPLAN A3 lines 521-523 require Bullhorn, Fathom, and Fireflies tools/APIs, not Ringover. Either remove Ringover from v1.0 surfaces or add the Ringover commercial/API/connector prerequisites explicitly.

4. Autosend policy citations point to a non-existent YAML file. Line 16 cites `autosend-safety-policy.yaml` and line 214 cites `autosend-safety-policy §4`, but the runtime YAML in the repo is `agents/_shared/autosend-policy.yaml`; `autosend-safety-policy` exists as a decision `.md`, not YAML. Replace the YAML citation with `agents/_shared/autosend-policy.yaml` and cite the decision doc only when referring to policy rationale.

5. §6 reuses `ESC_PROVIDER_FETCH_FAIL` more broadly than its catalogue definition. Line 250 defines it for Fathom/Fireflies/Ringover transcript fetches, but `agents/_shared/escalation-codes.md` lines 324-329 define a generic upstream read failure with examples that do not include transcript providers and no transcript-specific payload. Either update the catalogue to register transcript-provider usage and payload fields, or use/register a Scribe-specific transcript fetch code.
tokens used
77,028
REJECTED

1. §3 assumes fields that are not schema-backed. Lines 76-80 list `brief.start_date`, `placement.week_1_status_note`, and `opportunity.sector` as canonical/schema-verified, but `vertical-schema.yaml` uses `start_date_target` and the v0.3 supplement explicitly says `week_1_status_note` became `week_1_status_vault_path` and `opportunity.sector` is not yet in schema. Fix the field table to use schema-backed names or land the missing supplement before ratification.

2. §4 workflow omits required `hh_decision_*` calls on output/action steps. Lines 141-149 refresh Bullhorn auth and fetch/store a transcript in `/tmp` without any decision-log write; lines 180-184 validate and mutate the extracted field set without a `hh_decision_output` or Gate-A failure action. Add decision-log calls for each output/action/failure point or mark the steps as purely internal with no side effect.

3. Ringover is declared as v1.0-supported without matching build dependencies. Lines 16, 30, and 39 include Ringover as a provider, but §8 lines 295-298 only gate Fathom/Fireflies signup and connector work; ULTRAPLAN A3 lines 521-523 require Bullhorn, Fathom, and Fireflies tools/APIs, not Ringover. Either remove Ringover from v1.0 surfaces or add the Ringover commercial/API/connector prerequisites explicitly.

4. Autosend policy citations point to a non-existent YAML file. Line 16 cites `autosend-safety-policy.yaml` and line 214 cites `autosend-safety-policy §4`, but the runtime YAML in the repo is `agents/_shared/autosend-policy.yaml`; `autosend-safety-policy` exists as a decision `.md`, not YAML. Replace the YAML citation with `agents/_shared/autosend-policy.yaml` and cite the decision doc only when referring to policy rationale.

5. §6 reuses `ESC_PROVIDER_FETCH_FAIL` more broadly than its catalogue definition. Line 250 defines it for Fathom/Fireflies/Ringover transcript fetches, but `agents/_shared/escalation-codes.md` lines 324-329 define a generic upstream read failure with examples that do not include transcript providers and no transcript-specific payload. Either update the catalogue to register transcript-provider usage and payload fields, or use/register a Scribe-specific transcript fetch code.
