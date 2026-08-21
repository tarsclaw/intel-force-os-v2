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
session id: 019e5ded-9df9-7982-85d1-be1d8a5905db
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

**Status:** Proposed.
**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.

---

## §2 — Invocation surface

### Webhook (v1.0 primary path)

```http
POST https://<tenant>.ifos.app/agents/scribe/webhook
Authorization: Bearer <fathom-or-fireflies-shared-secret>
Content-Type: application/json

{
  "provider": "fathom" | "fireflies",        // v1.0
  // "ringover" added in v1.1+ — not in v0 build per §8 dependencies
  "call_id": "<provider-call-id>",
  "transcript_url": "<provider-transcript-url>",
  "duration_seconds": 1234,
  "participants": [...],
  "metadata": {...}
}
```

v1.0 supports Fathom (HMAC-SHA256 signed) and Fireflies (bearer token) providers; auth handled per-provider in `tools.yaml` capability declarations. Ringover (OAuth-protected) is deferred to v1.1+ — not in the v0 build dependencies and not registered in v1.0 `tools.yaml`.

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
| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
| Placement | `start_date`, `placement_status` (v0.3), `week_1_status_vault_path` (v0.3; vault pointer, not narrative), `satisfaction_signal` (v0.3) |
| Opportunity | `headcount_growth_signal_text` (v0.3), `hiring_velocity_band` (v0.3), `decision_window_text` (v0.3) |

Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.

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
   → hh_decision_output("bullhorn_auth_refreshed", "tenant:<slug>", "result:ok")

3. Transcript fetch
   → provider-specific: fathom.get_transcript(call_id) | fireflies.get(...)
   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
   → hh_decision_output("transcript_fetched", "call:<id>",
     "provider:<name>; bytes:<N>; tmp_path:/tmp/scribe-<tenant>-<call_id>.txt")

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
   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
     "<N> valid of <M> extracted; dropped:<N-invalid>")
   → on Gate A failure (<3 valid): hh_decision_action("validate_gate_a_fail",
     "<entity_type>:<bullhorn_id>", payload_hash,
     "ESC_SCHEMA_VIOLATION; agent_name:scribe; valid:<N>") and exit 1
     (validate_gate_a_fail is the canonical green-tier action_type registered
     in agents/_shared/autosend-policy.yaml line 113; agent:all; Scribe uses
     the shared signature with agent_name in payload to distinguish.)

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
   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
     10 min". Catalogue ESC_SCRIBE_SLA_MISS triggers (line 443): "summary-render
     >30 min OR note-attach >1h after call end". The two thresholds are
     different scopes — master brief 10-min is the product UX promise; catalogue
     30-min/1h is the alerting threshold (less false alarms).
   → if elapsed > 3600 (1h): fire ESC_SCRIBE_SLA_MISS with `sla_type=note_attach` (per catalogue)
   → if elapsed > 1800 (30 min): fire ESC_SCRIBE_SLA_MISS with `sla_type=summary_render` (per catalogue)
   → if elapsed > 600 (10 min) but ≤ 1800: NO ESC fire — recorded as Gate B
     "10-min miss" in the day-30 report aggregation; counts against Gate B 90% target
   → if elapsed > 300 (5 min) but ≤ 600: info-level (still under product promise)
   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
   → exit code 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:

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
| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
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
I’ll verify the cited source files and catalogue entries before deciding. The main risk here is citation drift or schema/status claims that look plausible but do not match the repo.
exec
/bin/zsh -lc "rg --files | rg '("'^|/)(vertical-schema.*yaml|autosend.*policy.*|escalation-codes.md|voice-loader.sh|hook-helpers.sh|ULTRAPLAN|master|v1.0-kill-criterion|operational-hygiene|agent.md)$'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/agent-renderer/tests/fixtures/test-agent/agent.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/recruitment/cash-conductor/agent.md
docs/decisions/autosend-safety-policy.md
agents/recruitment/scribe/agent.md
agents/recruitment/sourcing-scout/agent.md
agents/recruitment/janitor/agent.md
agents/recruitment/diagnostic/agent.md
agents/recruitment/concierge/agent.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/agent.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/agent.md
legacy/v1/docs/phase-2-agent-suite/_shared/escalation-codes.md
legacy/v1/docs/phase-2-agent-suite/_shared/hook-helpers.sh
legacy/v1/docs/phase-2-agent-suite/sop-writer/agent.md
legacy/v1/docs/phase-2-agent-suite/hr-agent/agent.md
legacy/v1/docs/phase-2-agent-suite/content-creator/agent.md
legacy/v1/docs/phase-2-agent-suite/repurposer/agent.md
legacy/v1/docs/phase-2-agent-suite/librarian/agent.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/agent.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/agent.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/agent.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/agent.md

exec
/bin/zsh -lc 'rg -n "Scribe|W6|week 6|post-call|A3|Fathom|Fireflies|scribe|ESC_PROVIDER_FETCH_FAIL|ESC_SCRIBE_SLA_MISS|ESC_BULLHORN_AUTH|ESC_FIELD_EXTRACTION_LOW_CONFIDENCE|ESC_SCHEMA_VIOLATION|validate_gate_a_fail|bullhorn_scribe_field_write|bullhorn_note_append_summary|scribe_run_complete|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|Status: Proposed|headcount_growth_signal_text|week_1_status_vault_path|employment_type|key_skills|preferred_channel|next_action_target_date|must_haves|nice_to_haves|deal_breakers|satisfaction_signal|placement_status" docs agents packages -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:43:    agent: scribe
agents/_shared/autosend-policy.yaml:83:  scribe_run_complete:
agents/_shared/autosend-policy.yaml:85:    agent: scribe
agents/_shared/autosend-policy.yaml:116:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:119:  validate_gate_a_fail:
agents/_shared/autosend-policy.yaml:174:  bullhorn_note_append_summary:
agents/_shared/autosend-policy.yaml:176:    agent: scribe
agents/_shared/autosend-policy.yaml:202:  bullhorn_scribe_field_write:
agents/_shared/autosend-policy.yaml:204:    agent: scribe
agents/_shared/autosend-policy.yaml:206:    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
agents/_shared/autosend-policy.yaml:258:    agent: scribe
agents/_shared/escalation-codes.md:97:#### `ESC_BULLHORN_AUTH`
agents/_shared/escalation-codes.md:163:#### `ESC_SCHEMA_VIOLATION`
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:324:#### `ESC_PROVIDER_FETCH_FAIL`
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
agents/_shared/escalation-codes.md:395:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:441:#### `ESC_SCRIBE_SLA_MISS`
agents/_shared/escalation-codes.md:443:- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:3:# Status: Proposed (Codex Day-19 ratification queue addendum)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:16:# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:19:# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:59:      employment_type:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:65:          IR35 distinction matters for UK contractors. Extracted by Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:67:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:69:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:72:      key_skills:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:82:        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:84:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:104:      preferred_channel:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:110:          Contact's stated preference; extracted by Scribe from call context.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:112:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:114:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:117:      next_action_target_date:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:121:          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:124:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:126:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:131:      must_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:140:        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:142:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:145:      nice_to_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:152:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:154:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:157:      deal_breakers:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:165:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:167:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:172:      placement_status:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:178:          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:181:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:183:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:187:      week_1_status_vault_path:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:190:        pattern: '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$'
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:194:          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:195:          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:201:        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:204:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:207:      satisfaction_signal:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:213:          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:215:        source: IFOS-derived (Scribe LLM extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:217:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:222:      headcount_growth_signal_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:230:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:232:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:241:          Scribe LLM inference from prospecting-call urgency cues. Drives
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:243:        source: IFOS-derived (Scribe LLM classification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:245:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:255:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:257:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:281:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:283:#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:285:#     R-only for Scribe)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:286:#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:287:#   - Scribe timesheet: none → R (reads for placement-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:308:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:346:  #   Example: Scribe.candidate: R+W at entity level; per-field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:347:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:386:  scribe:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:387:    # Scribe's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:389:    # row A3. opportunity + timesheet access below is to IFOS-cached
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    # Postgres rows ONLY (not direct Bullhorn endpoint calls). Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:394:    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:395:    client: R              # IFOS-cached read (Bullhorn endpoint A3 — ClientCorporation)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:396:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:397:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:399:    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:406:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:466:      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:479:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:484:      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:492:      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:496:      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:498:      for Scribe.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:505:      - Scribe (R+W)       # v0.3 NEW — writes 3 new prospecting-call fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:512:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:519:      - Scribe (R+W)       # v0.3 NEW — check-in field extraction
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:524:      their §4 specs); adds Scribe R+W for check-in writes.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:530:      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:      Scribe + Concierge (each reads timesheet for their respective
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:539:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:543:      - Scribe (R+W)       # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:555:      - Scribe (R+W)       # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:      granted Scribe + Concierge; v0.3 extends to all 6.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:575:    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:576:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:578:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:595:      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:693:    scribe: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:702:    scribe: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:711:    scribe: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:718:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:722:    scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:729:    scribe: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:736:    scribe: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:914:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:934:  Q1_employment_type_enum_completeness:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:935:    question: Are 6 employment_type enum values sufficient for UK recruitment?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:938:        Keep 6 values as in §1.candidate.employment_type — perm, contract,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:943:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:949:  Q2_key_skills_max_length:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:959:  Q3_placement_status_enum_lifecycle:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:960:    question: 6-state placement_status enum maps to Bullhorn's native state machine?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:964:      C: Add a mapping table (auxiliary) — placement_status_mapping with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1005:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1014:    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1015:      the v0.3-added fields (employment_type, key_skills, preferred_channel,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1016:      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1017:      placement_status, week_1_status_vault_path, satisfaction_signal,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1018:      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1020:      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1025:      they do not block v0.3 ratification but do require a Scribe agent.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1026:      consistency-pass before Scribe ratifies.
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:3:# Status: Proposed (Codex Day-7 ratification queue addendum)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:61:      - Scribe (R — voice samples for note-summary tone matching)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:128:      - Scribe (R — note format constraints)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
packages/harness/cortextos/src/telegram/transcribe.ts:29:export interface TranscribeOptions {
packages/harness/cortextos/src/telegram/transcribe.ts:36: * Transcribe a Telegram voice .ogg file. Returns the trimmed transcript
packages/harness/cortextos/src/telegram/transcribe.ts:39:export async function transcribeVoice(
packages/harness/cortextos/src/telegram/transcribe.ts:41:  opts: TranscribeOptions = {},
packages/harness/cortextos/src/telegram/transcribe.ts:53:    log(`[transcribe] model not found at ${modelPath} — skipping; run scripts/install-whisper-model.sh to enable transcription`);
packages/harness/cortextos/src/telegram/transcribe.ts:64:    log(`[transcribe] ffmpeg failed (${ffmpegOk.reason}) — skipping`);
packages/harness/cortextos/src/telegram/transcribe.ts:76:      log(`[transcribe] whisper-cli failed (${whisper.reason}) — skipping`);
packages/harness/cortextos/src/telegram/transcribe.ts:81:      log('[transcribe] whisper-cli produced empty output — skipping');
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:6:describe('Sprint 8: Dashboard Compatibility', () => {
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:18:  describe('Dashboard package exists', () => {
packages/harness/cortextos/tests/sprint8-dashboard.test.ts:41:  describe('File format compatibility with dashboard', () => {
packages/harness/cortextos/src/telegram/media.ts:9:import { transcribeVoice } from './transcribe.js';
packages/harness/cortextos/src/telegram/media.ts:154:    const transcript = await transcribeVoice(localFile);
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:55:- **Webhook (v1.0 primary path):** per-provider HMAC / bearer token verified at the ingress per `tools.yaml` capability declarations (matching the Scribe webhook auth pattern).
agents/recruitment/cash-conductor/agent.md:315:**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/cash-conductor/agent.md:354:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
agents/recruitment/cash-conductor/agent.md:363:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:367:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
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
agents/recruitment/concierge/agent.md:155:     ESC_BULLHORN_AUTH on auth fail
agents/recruitment/concierge/agent.md:289:**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/concierge/agent.md:310:| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:333:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
agents/recruitment/concierge/agent.md:342:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:349:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:350:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:369:| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
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
agents/recruitment/diagnostic/cleanup.sh:5:# Status: Proposed (pre-W3-build scaffold; Day-12 author).
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:13:# Status: Proposed (pre-W3-build; behaviour design verified).
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:78:  decision_log_rows_min: 4  # trigger + output + validate_gate_a_fail action + cleanup
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:211:    IF d ? 'employment_type' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:212:      IF (d->>'employment_type') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:215:        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:219:    IF d ? 'key_skills' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:220:      IF jsonb_typeof(d->'key_skills') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:221:        RAISE EXCEPTION 'key_skills must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:223:      IF jsonb_array_length(d->'key_skills') > 20 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:224:        RAISE EXCEPTION 'key_skills max length 20 (got %)', jsonb_array_length(d->'key_skills');
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:227:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'key_skills') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:229:          RAISE EXCEPTION 'key_skills items must be strings; got %', jsonb_typeof(arr_item);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:247:    IF d ? 'preferred_channel' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:248:      IF (d->>'preferred_channel') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:251:        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:255:    IF d ? 'next_action_target_date' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:256:      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:257:        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:260:      IF d->>'next_action_target_date' IS NOT NULL THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:262:          PERFORM (d->>'next_action_target_date')::date;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:264:          RAISE EXCEPTION 'next_action_target_date must parse as ISO-8601 date (YYYY-MM-DD); got: %', d->>'next_action_target_date';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:272:    IF d ? 'must_haves' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:273:      IF jsonb_typeof(d->'must_haves') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:274:        RAISE EXCEPTION 'must_haves must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:276:      IF jsonb_array_length(d->'must_haves') > 15 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:277:        RAISE EXCEPTION 'must_haves max length 15';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:279:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:281:          RAISE EXCEPTION 'must_haves items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:286:    IF d ? 'nice_to_haves' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:287:      IF jsonb_typeof(d->'nice_to_haves') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:288:        RAISE EXCEPTION 'nice_to_haves must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:290:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'nice_to_haves') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:292:          RAISE EXCEPTION 'nice_to_haves items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:297:    IF d ? 'deal_breakers' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:298:      IF jsonb_typeof(d->'deal_breakers') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:299:        RAISE EXCEPTION 'deal_breakers must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:301:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:303:          RAISE EXCEPTION 'deal_breakers items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:311:    IF d ? 'placement_status' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:312:      IF (d->>'placement_status') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:315:        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:319:    IF d ? 'week_1_status_vault_path' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:320:      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:321:        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:323:      IF d->>'week_1_status_vault_path' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:324:         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:325:        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:327:      IF d->>'week_1_status_vault_path' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:328:         AND length(d->>'week_1_status_vault_path') > 200 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:329:        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:333:    IF d ? 'satisfaction_signal' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:334:      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:335:        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:342:    IF d ? 'headcount_growth_signal_text' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:343:      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:344:        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:346:      IF d->>'headcount_growth_signal_text' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:347:         AND length(d->>'headcount_growth_signal_text') > 280 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:348:        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
agents/recruitment/diagnostic/fixtures/01-primary.yaml:8:# Status: Proposed (pre-W3-build; data structure verified, content TBD).
packages/harness/cortextos/src/bus/task.ts:127: * `virtual` lets the caller describe a task that does not yet exist
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:9:# Status: Proposed (pre-W3-build; data shape verified).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
docs/_archive-build-pack/02-PRODUCT-VISION.md:66:1. They upload the handbook, paste past replies, connect Fathom — material lands in the vault as markdown pages.
packages/harness/cortextos/tests/sprint5-metrics.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/sprint5-metrics.test.ts:12:describe('Sprint 5: Observability & Metrics', () => {
packages/harness/cortextos/tests/sprint5-metrics.test.ts:28:  describe('collectMetrics', () => {
packages/harness/cortextos/tests/sprint5-metrics.test.ts:220:  describe('parseUsageOutput', () => {
packages/harness/cortextos/tests/sprint5-metrics.test.ts:242:  describe('storeUsageData', () => {
packages/harness/cortextos/tests/sprint5-metrics.test.ts:279:  describe('collectTelegramCommands', () => {
agents/recruitment/janitor/agent.md:91:   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
agents/recruitment/janitor/agent.md:148:   → on classifier fail after retries: hh_decision_action("validate_gate_a_fail",
agents/recruitment/janitor/agent.md:201:`ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT a Gate A failure code — per catalogue trigger it's for dedup confidence ≥0.85 review-required cases (SUCCESS path; Telegram approval gate). Sub-0.85 confidence pairs silently drop in Step 3 algorithm; no ESC fire. Draft report stays in `/tmp` (not vault); operator-review required. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:221:| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/janitor/agent.md:236:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:244:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:248:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:249:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:277:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/scribe/README.md:1:# Scribe — directory README
agents/recruitment/scribe/README.md:3:**Status:** Proposed (Day-17 pre-W6-build scaffold).
agents/recruitment/scribe/README.md:14:Full bundle at W6 build (~1 week per ULTRAPLAN A3 line 526):
agents/recruitment/scribe/README.md:16:- `tools.yaml` — Bullhorn W + Fathom R + Fireflies R + voice classifier
agents/recruitment/scribe/README.md:29:*End of Scribe README.*
packages/harness/cortextos/tests/sprint3-experiments.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/sprint3-experiments.test.ts:14:describe('Sprint 3: Experiment Framework', () => {
packages/harness/cortextos/tests/sprint3-experiments.test.ts:29:  describe('createExperiment', () => {
packages/harness/cortextos/tests/sprint3-experiments.test.ts:174:  describe('runExperiment', () => {
packages/harness/cortextos/tests/sprint3-experiments.test.ts:198:  describe('evaluateExperiment', () => {
packages/harness/cortextos/tests/sprint3-experiments.test.ts:260:  describe('listExperiments', () => {
packages/harness/cortextos/tests/sprint3-experiments.test.ts:311:  describe('gatherContext', () => {
packages/harness/cortextos/tests/sprint3-experiments.test.ts:359:  describe('manageCycle', () => {
agents/recruitment/diagnostic/cycle.sh:5:# Status: Proposed (Day-19; v0 implementation using @ifos/diagnostic-generator + web-scraper + companies-house MCP connectors all wired).
agents/recruitment/sourcing-scout/agent.md:132:     - ESC_BULLHORN_AUTH (catalogue §2.3): blocking → Sourcing Scout
agents/recruitment/sourcing-scout/agent.md:232:      per catalogue line 184 — distinct from ESC_SCHEMA_VIOLATION which is
agents/recruitment/sourcing-scout/agent.md:267:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:287:| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (per catalogue §2.3) | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:302:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Sourcing Scout's Gate A misses are output-shape failures (use `ESC_AGENT_OUTPUT_SHAPE`)
agents/recruitment/sourcing-scout/agent.md:312:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:317:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:318:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:55:Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:77:**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:131:5. **§5 honesty about validate.sh implementation** — agent.md §5 sections describe Gate A behaviour that may not be implemented in the corresponding `validate.sh`. For Diagnostic, validate.sh exists + has gaps (Issue 5). For the 5 new scaffolds, validate.sh DOESN'T exist yet — §5 describes intent. Disposition: explicitly mark "intended behaviour; cycle.sh + validate.sh implementation at W-X build will deliver this" in §5 of each pre-build scaffold.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:161:3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:261:- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:274:| Scribe | 5 | `20260524T112917Z-82352` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:306:- Diagnostic validate.sh: emits `ESC_SCHEMA_VIOLATION` not the specific codes declared in §6; doesn't write skip rows when honesty-flagging
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:316:  - Scribe Steps 2-3, 7 partial coverage
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:363:- `validate.sh` emits specific §6 ESC codes (ESC_PII_LEAKAGE_RISK or ESC_AGENT_OUTPUT_SHAPE) not generic ESC_SCHEMA_VIOLATION
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:372:| Scribe | 5 | 4 | −1 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:18:**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:10:> 3. §4 Gate-A failure signature is incomplete. Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:17:117  → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/decisions/brain-ui-scope.md:201:- §1 (forward-deferral framing — Status: Proposed is structurally appropriate because v1.0 actual-usage evidence is the input v1.1 planning needs).
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:21:| 6 | Scribe |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/autosend-approval-bridge-spec.md:241:| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:146:| 3 | `agents/recruitment/scribe/agent.md` | **REJECTED** | ~5-7 real findings (count regex 59) | `20260524T102202Z-22338` |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:13:Master brief §2.4 row 3 describes Primitive 3 (Inter-agent file bus) as:
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:16:describe('E2E Lifecycle', () => {
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:45:  describe('Full message lifecycle', () => {
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:87:  describe('Full task lifecycle', () => {
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:117:  describe('Event logging', () => {
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:138:  describe('Heartbeat', () => {
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:154:  describe('Multi-agent coordination', () => {
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:201:  describe('Approval workflow', () => {
packages/harness/cortextos/tests/e2e/lifecycle.test.ts:225:  describe('Format compatibility with bash', () => {
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
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:82:  - Sub-decisions A and B — full technical analysis (Sections 2 and 3 of this document), with explicit Status: Proposed flags pointing at the §1.3 commercial-blocker table.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:196:**Status: Proposed.** Status flips to Accepted on either: (a) partnerships@bullhorn confirms marketplace is not required for v1.0 production tenant access AND first design partner uses Bullhorn; OR (b) founder explicitly accepts the documented fallback if marketplace turns out required, and re-cuts the v1.0 timeline to absorb the marketplace certification window.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:271:**Status: Proposed.** Status flips to Accepted on commercial verification answers to the four questions above. Most likely outcome: confirmation of the §3.4 recommendation as stated, with one or two clarifications absorbed into the renderer's auth-module implementation.
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:298:**Confirmed from Bullhorn public docs:** `https://bullhorn.github.io/rest-api-docs/` describes **no webhook, subscription, event-stream, or push-notification mechanism**. Operations covered: entity CRUD, query/search, file attachments, resume parsing, mass updates, entity metadata. Verified 2026-05-16.
docs/decisions/bullhorn-integration-path.md:308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
docs/decisions/bullhorn-integration-path.md:335:| Scribe (write-on-event) | 50-100 distributed | Event-rate-bounded; one call typically = 5-15 REST writes |
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:367:**Sub-decision A — Marketplace vs direct API. Status: Proposed.**
docs/decisions/bullhorn-integration-path.md:379:**Sub-decision B — OAuth flow. Status: Proposed.**
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
docs/decisions/bullhorn-integration-path.md:484:| §4.5 (architectural emergence) | §4.5 | Access-token refresh-loop: per-agent background task, 8-minute cycle, retry-once-then-`ESC_BULLHORN_AUTH` |
docs/decisions/bullhorn-integration-path.md:502:| `ESC_BULLHORN_AUTH` escalation code wired into `agents/_shared/escalation-codes.md` | Claude Code | Week 1-2 (alongside `_shared/hook-helpers.sh` Week-1 prereq from ADR-002) |
agents/recruitment/scribe/agent.md:1:# Scribe — the data spine
agents/recruitment/scribe/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
agents/recruitment/scribe/agent.md:7:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:8:**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
agents/recruitment/scribe/agent.md:9:**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
agents/recruitment/scribe/agent.md:17:> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:26:POST https://<tenant>.ifos.app/agents/scribe/webhook
agents/recruitment/scribe/agent.md:41:v1.0 supports Fathom (HMAC-SHA256 signed) and Fireflies (bearer token) providers; auth handled per-provider in `tools.yaml` capability declarations. Ringover (OAuth-protected) is deferred to v1.1+ — not in the v0 build dependencies and not registered in v1.0 `tools.yaml`.
agents/recruitment/scribe/agent.md:46:ifosctl scribe replay --tenant <slug> --call-id <provider-call-id>
agents/recruitment/scribe/agent.md:53:- Telegram command (`@ifos_bot scribe replay <call-id>`)
agents/recruitment/scribe/agent.md:70:- Opportunity scoping (consultant + prospect) → Opportunity entity update (NOTE: Bullhorn endpoint A3 row covers Candidate / ClientCorporation / JobOrder / Note / Placement only at v1.0; Opportunity writes are to IFOS-cached Postgres entity rows for the v0.3-added fields headcount_growth_signal_text + hiring_velocity_band + decision_window_text per v0.3 supplement §1, NOT direct Bullhorn endpoint calls)
agents/recruitment/scribe/agent.md:76:| Candidate | `location`, `current_role`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (v0.3; enum per supplement §1), `key_skills` (v0.3; list) |
agents/recruitment/scribe/agent.md:77:| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
agents/recruitment/scribe/agent.md:78:| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
agents/recruitment/scribe/agent.md:79:| Placement | `start_date`, `placement_status` (v0.3), `week_1_status_vault_path` (v0.3; vault pointer, not narrative), `satisfaction_signal` (v0.3) |
agents/recruitment/scribe/agent.md:80:| Opportunity | `headcount_growth_signal_text` (v0.3), `hiring_velocity_band` (v0.3), `decision_window_text` (v0.3) |
agents/recruitment/scribe/agent.md:82:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
agents/recruitment/scribe/agent.md:84:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:113:Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
agents/recruitment/scribe/agent.md:135:   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
agents/recruitment/scribe/agent.md:145:   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
agents/recruitment/scribe/agent.md:150:   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
agents/recruitment/scribe/agent.md:151:   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
agents/recruitment/scribe/agent.md:154:     "provider:<name>; bytes:<N>; tmp_path:/tmp/scribe-<tenant>-<call_id>.txt")
agents/recruitment/scribe/agent.md:163:     a Scribe run with no resolvable target cannot produce structured writes)
agents/recruitment/scribe/agent.md:171:   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
agents/recruitment/scribe/agent.md:181:   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md
agents/recruitment/scribe/agent.md:188:   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION
agents/recruitment/scribe/agent.md:192:   → on Gate A failure (<3 valid): hh_decision_action("validate_gate_a_fail",
agents/recruitment/scribe/agent.md:194:     "ESC_SCHEMA_VIOLATION; agent_name:scribe; valid:<N>") and exit 1
agents/recruitment/scribe/agent.md:195:     (validate_gate_a_fail is the canonical green-tier action_type registered
agents/recruitment/scribe/agent.md:196:     in agents/_shared/autosend-policy.yaml line 113; agent:all; Scribe uses
agents/recruitment/scribe/agent.md:202:   → on success: hh_decision_action("bullhorn_scribe_field_write",
agents/recruitment/scribe/agent.md:208:   → on success: hh_decision_action("bullhorn_note_append_summary",
agents/recruitment/scribe/agent.md:215:   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
agents/recruitment/scribe/agent.md:216:     10 min". Catalogue ESC_SCRIBE_SLA_MISS triggers (line 443): "summary-render
agents/recruitment/scribe/agent.md:220:   → if elapsed > 3600 (1h): fire ESC_SCRIBE_SLA_MISS with `sla_type=note_attach` (per catalogue)
agents/recruitment/scribe/agent.md:221:   → if elapsed > 1800 (30 min): fire ESC_SCRIBE_SLA_MISS with `sla_type=summary_render` (per catalogue)
agents/recruitment/scribe/agent.md:225:   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
agents/recruitment/scribe/agent.md:235:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:238:- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
agents/recruitment/scribe/agent.md:245:Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:247:**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/scribe/agent.md:251:Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
agents/recruitment/scribe/agent.md:255:- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
agents/recruitment/scribe/agent.md:257:Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
agents/recruitment/scribe/agent.md:265:Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/scribe/agent.md:269:| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:271:| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:273:| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:276:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:277:| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:278:| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
agents/recruitment/scribe/agent.md:282:Scribe does NOT use:
agents/recruitment/scribe/agent.md:284:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
agents/recruitment/scribe/agent.md:292:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:296:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:297:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:303:## §8 — Build dependencies (W6 prerequisites)
agents/recruitment/scribe/agent.md:305:Scribe build cannot start until ALL of the following are confirmed:
agents/recruitment/scribe/agent.md:315:| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
agents/recruitment/scribe/agent.md:316:| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
agents/recruitment/scribe/agent.md:317:| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
agents/recruitment/scribe/agent.md:321:| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
agents/recruitment/scribe/agent.md:322:| `context.sh` hydration | Build at W6 start (~0.5 day) | ⏸ |
agents/recruitment/scribe/agent.md:323:| `cycle.sh` orchestration (10-step) | Build at W6 start (~2 days) | ⏸ |
agents/recruitment/scribe/agent.md:324:| 3 fixtures with golden outputs | Build at W6 start (~1 day) | ⏸ |
agents/recruitment/scribe/agent.md:327:**Until ALL ⏸ items resolve to ✅, W6 build slice does not start.**
agents/recruitment/scribe/agent.md:333:**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
agents/recruitment/scribe/agent.md:339:| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
agents/recruitment/scribe/agent.md:342:| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
agents/recruitment/scribe/agent.md:344:| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
agents/recruitment/scribe/agent.md:347:### Gotchas (carried forward from ULTRAPLAN A3 line 527)
agents/recruitment/scribe/agent.md:350:2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
agents/recruitment/scribe/agent.md:361:- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
agents/recruitment/scribe/agent.md:365:- W6 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/scribe/agent.md:372:*End of Scribe agent.md draft.*
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:83:| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/autosend-safety-policy.md:106:| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
docs/decisions/autosend-safety-policy.md:494:- **Per-recipient reputation:** recipients with high engagement may be in implicit "always-orange" zone; recipients with prior unsubscribes may be elevated to red.
agents/recruitment/diagnostic/tools.yaml:3:# Status: Proposed (Day-19; @ifos/web-scraper + @ifos/companies-house MCP connectors shipped Day 13; LinkedIn via web-scraper page-fetch in v0; Proxycurl deferred to W4 polish).
agents/recruitment/diagnostic/tools.yaml:48:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:80:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:83:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:162:        escalation: ESC_SCHEMA_VIOLATION
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:56:- **Auth path cleared: NO.** Sub-decisions A (marketplace vs direct API) and B (OAuth flow specifics — authorization-code grant against IFOS-owned dev tenant) remain Status: Proposed in `bullhorn-integration-path.md`. The technical path is documented but the commercial gates have not passed:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:77:- **Artefact:** `docs/verticals/recruitment/vertical-schema.yaml` Status: Proposed, shipped Day 6 commit `fec8872`.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:59:| 03 | Proposal Builder | Sales | On call-end | £24,200 engagement | Fathom, HubSpot, Notion |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:131:- Specific: "Drafts a proposal 4 minutes after the Fathom call ends."
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:203:- Fathom (Proposal Builder)
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
agents/recruitment/diagnostic/validate.sh:6:# Status: Proposed (pre-W3-build scaffold; Day-12 author).
agents/recruitment/diagnostic/validate.sh:240:  # ESC_SCHEMA_VIOLATION is reserved for vertical-schema field-constraint
agents/recruitment/diagnostic/validate.sh:266:  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
packages/harness/cortextos/tests/e2e/mock-codex.js:100:  /** Subscribe to every outbound notification (for assertion convenience). */
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
agents/recruitment/diagnostic/context.sh:6:# Status: Proposed (Day-19; voice + tone + recent_edits + target_patch hydration via voice-loader.sh + tone-loader + Postgres).
agents/recruitment/diagnostic/context.sh:28:#   - Missing tenant_slug → exit 1 with ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/context.sh:31:#   - target_patch unreachable → exit 1 with ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/agent.md:77:The two-tier framing (hard-fails / complement) honestly reflects v0 behavior: the four hard-fails above ALWAYS block on failure; the two complement checks block ONLY when their upstream dependency is available. The agent.md previously described all six as "Gate A hard-fails" which was inconsistent with the §5 honesty note; corrected at R19.
agents/recruitment/diagnostic/agent.md:124:   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
agents/recruitment/diagnostic/agent.md:157:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:161:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:163:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:189:- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/agent.md:199:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:203:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:204:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. **v0: per-run `ESC_VOICE_DRIFT` fires when `validate.sh` V3 single-pass classifier call (no retries) returns score <0.75 AND `IFOS_VOICE_CLASSIFIER_URL` was reachable. W4-planned: 3-retry classifier loop in `@ifos/diagnostic-generator` §12 LLM step + unconditional hard-fail when URL unreachable.** Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
packages/harness/cortextos/tests/e2e/lifecycle-codex.test.ts:20:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/e2e/lifecycle-codex.test.ts:44:describe('E2E codex lifecycle (mock-codex.js + WsUnixJsonRpcClient)', () => {
docs/runbooks/tenant-lifecycle.md:151:| Bullhorn OAuth refresh | Per-agent 8-min cycle per `bullhorn-integration-path.md` §4.5; ESC_BULLHORN_AUTH on failure | (No invariant violation; runtime concern) |
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:183:- `ESC_BULLHORN_AUTH` — Bullhorn OAuth token expired or revoked
docs/specs/ULTRAPLAN.md:189:- `ESC_SCHEMA_VIOLATION` — agent produced output that violates the vertical schema (e.g., a "placement" with no candidate)
docs/specs/ULTRAPLAN.md:238:- Process group includes one process per always-on agent the tenant has subscribed to.
docs/specs/ULTRAPLAN.md:354:If any hard fail, the agent regenerates with the failure reason injected as additional context ("your previous draft used the banned phrase 'I hope this finds you well'; rewrite avoiding it"). After 3 retries with hard fails, escalate with `ESC_VOICE_DRIFT` or `ESC_SCHEMA_VIOLATION`.
docs/specs/ULTRAPLAN.md:515:#### A3. The Scribe — the data spine
docs/specs/ULTRAPLAN.md:517:- **Build wave:** v1.0 (week 6–7)
docs/specs/ULTRAPLAN.md:519:- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
docs/specs/ULTRAPLAN.md:521:- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
docs/specs/ULTRAPLAN.md:523:- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
docs/specs/ULTRAPLAN.md:687:| Scribe | ✓ | ✓ | | | | | | ✓ | | | |
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:760:- Week 6: Scribe agent; Fathom + Fireflies MCP; tacit-note taxonomy v0.1
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
packages/harness/cortextos/tests/sprint1-templates.test.ts:1:import { describe, it, expect, beforeAll } from 'vitest';
packages/harness/cortextos/tests/sprint1-templates.test.ts:7:describe('Sprint 1: Template Completeness', () => {
packages/harness/cortextos/tests/sprint1-templates.test.ts:8:  describe('Agent template', () => {
packages/harness/cortextos/tests/sprint1-templates.test.ts:126:  describe('Orchestrator template', () => {
packages/harness/cortextos/tests/sprint1-templates.test.ts:204:  describe('Analyst template', () => {
packages/harness/cortextos/tests/sprint1-templates.test.ts:278:  describe('Org template', () => {
packages/harness/cortextos/tests/sprint1-templates.test.ts:317:  describe('No bash script references remain', () => {
docs/specs/_archive-build-handoff.md:328:git checkout -b agent/bullhorn-mcp        # or agent/janitor, agent/scribe, etc.
docs/specs/_archive-build-handoff.md:379:| 3 | **Scribe** | 6 | Fathom/Fireflies MCP + Bullhorn write | The post-call note that lands in Bullhorn within 10 min is the second-most-demoable result |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:5:**Synthesis stance:** First principles. The build pack in `docs/build-pack/` is **ignored** per founder instruction. The CLAUDE.md currently in the repo describes paths, remotes, and red lines — those are kept. Everything else in this brief is rebuilt from the verified state of the two upstream repos (`grandamenium/cortextos`, `tarsclaw/intel-force-os-v2`), Karpathy's LLM-wiki pattern, and the recruitment product spec, ultraplan, and 24/7 directive.
docs/build-brief/00-MASTER-BRIEF.md:311:│       │   ├── calls/            ← from Fathom/Fireflies transcripts
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:358:   provenance: [scribe-agent:call-2026-05-16-1432, janitor:bullhorn-2026-05-15]
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:581:- `ESC_BULLHORN_AUTH` — OAuth token expired/revoked
docs/build-brief/00-MASTER-BRIEF.md:587:- `ESC_SCHEMA_VIOLATION` — agent produced output violating vertical schema
docs/build-brief/00-MASTER-BRIEF.md:597:| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
packages/utilities/web-scraper/tests/fetcher.test.ts:1:import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
packages/utilities/web-scraper/tests/fetcher.test.ts:28:describe("@ifos/web-scraper — headCheck", () => {
packages/utilities/web-scraper/tests/fetcher.test.ts:86:describe("@ifos/web-scraper — fetchFirstNLines", () => {
packages/utilities/web-scraper/tests/fetcher.test.ts:109:describe("@ifos/web-scraper — rate limit", () => {
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
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:438:| `_shared/hook-helpers.sh` wires 5 new `ESC_VAULT_*` codes (in addition to `ESC_BULLHORN_AUTH` + `ESC_RENDERER_FAILED`) | Week 1-2 | Claude Code | `current-priorities.md` Week-1 prereq #3 + §6 of this document |
docs/architecture/architecture-cohesion-review.md:90:| A3 | **The `_shared/` symlink target `../../../_shared` resolves to `<org>/agents/_shared/`, not anywhere else.** | renderer.ts symlinkSync call | If filesystem semantics differ (mac vs linux), or someone moves the rendered dir, symlink could escape. macOS + Linux behaviour verified identical for this case. |
packages/utilities/web-scraper/tests/cache.test.ts:1:import { afterEach, beforeEach, describe, expect, it } from "vitest";
packages/utilities/web-scraper/tests/cache.test.ts:19:describe("Cache", () => {
docs/_supplementary/PRD-autonomous-agent.md:871:// Step 4: Transcribe with Whisper
docs/_supplementary/PRD-autonomous-agent.md:872:export async function transcribeAudio(audioPath: string): Promise<WhisperTranscript> {
docs/_supplementary/PRD-autonomous-agent.md:2058:  "name": "Extraction pipeline (download → transcribe → analyse)",
docs/_supplementary/PRD-autonomous-agent.md:2068:- [ ] Build `src/extraction/transcribe.ts` — Whisper API integration
docs/_supplementary/PRD-autonomous-agent.md:2404:│   │   ├── transcribe.ts
packages/utilities/web-scraper/tests/scaffold.test.ts:1:import { describe, it, expect } from "vitest";
packages/utilities/web-scraper/tests/scaffold.test.ts:4:describe("@ifos/web-scraper — scaffold", () => {
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/second-brain-design.md:172:│   │   ├── calls/                                  ← Fathom/Fireflies transcripts (master brief §5.1 line 318)
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:204:| `wiki/raw/calls/` | one file per call | markdown with frontmatter | `{epoch}-{call-id}.md` | Scribe (v1.0) on Fathom/Fireflies webhook | Brief Decoder (v1.1), Concierge (v1.0) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:257:  - scribe-agent:call-2026-05-16-1432
docs/architecture/second-brain-design.md:274:{Janitor or Scribe one-paragraph summary, regenerated on each ingest}
docs/architecture/second-brain-design.md:277:{auto-appended by Concierge / Scribe — chronological, agent-attributed}
docs/architecture/second-brain-design.md:334:must_haves: [ "5+ years B2B SaaS", "UK right-to-work" ]   # required v1.0; list of strings
docs/architecture/second-brain-design.md:335:nice_to_haves: []                                    # optional v1.0
docs/architecture/second-brain-design.md:382:preferred_channel: email                             # optional; one of {email, phone, linkedin}
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:757:- `append-to-narrative` — Concierge / Scribe logging; tolerates few-hundred-ms.
docs/architecture/second-brain-design.md:772:| Scribe | 3:1 | reads candidate for context on every call; writes structured fields + tacit notes |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:892:| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/_supplementary/build-plan-original.md:135:- **Fixture inputs** — real anonymised examples (redacted Fathom transcript, scrubbed lead list)
docs/_supplementary/build-plan-original.md:208:1. Takes the trigger payload (e.g. Fathom call transcript)
docs/_supplementary/build-plan-original.md:226:- Trigger payload: variable (Fathom transcript = 5–15k tokens)
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
docs/_supplementary/build-plan-original.md:900:The Claude Code side handles the **configuration and training**, not the live call. The live call runs on Vapi; when the call ends, Vapi webhooks the transcript and actions to your Claude Code webhook receiver, which triggers a post-call agent that:
docs/_supplementary/build-plan-original.md:1080:                       (Fathom, Stripe, DocuSign, HubSpot) via their APIs
docs/_supplementary/build-plan-original.md:1197:1. Verify signature (every integration has its own: Fathom uses HMAC, Stripe uses stripe-signature, HubSpot has timestamp+signature)
docs/_supplementary/build-plan-original.md:1204:- **At-least-once** processing — fine because agent outputs are idempotent by design (same Fathom call ID → same proposal location, overwritten)
docs/_supplementary/build-plan-original.md:1255:| Fathom | Community MCP (matthewbergvinson, Dot-Fun) | Fork, harden, productize |
docs/_supplementary/build-plan-original.md:1516:- Week 1: Runtime proof-of-concept — **Proposal Builder end-to-end** in one container, one real Fathom call → proposal in inbox. This is the week-1 experiment from v2. Nothing else.
packages/harness/cortextos/src/daemon/fast-checker.ts:352:   * `transcript` is populated by `src/telegram/transcribe.ts` when whisper-cli
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
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/bullhorn-outreach-emails.md:117:> Public REST docs describe pull-only model. Is there an undocumented webhook or event-subscription mechanism available to integration partners? If not, we'll proceed with the polling model (already designed); if yes, we'd prefer to subscribe to placement-state-change events directly.
docs/operations/w4-bilateral-pass-6-agent-md.md:39:| 5 | Scribe | 5 | Ringover scope question is the only non-mechanical. |
docs/operations/w4-bilateral-pass-6-agent-md.md:62:  - **Codex says:** "Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature."
docs/operations/w4-bilateral-pass-6-agent-md.md:74:  - **Codex says:** "Line 238 says Proxycurl/API choice is 'Resolved at W3 start before Companies House + LinkedIn MCP connectors authored,' while this Day-19 artefact and §8 lines 213-215 say the connector/web-scraper work is already shipped and Proxycurl is deferred. Fix Q3 to describe the current W4 Proxycurl/commercial decision path."
docs/operations/w4-bilateral-pass-6-agent-md.md:75:  - **Likely:** FIX-IN-PLACE. Rewrite Q3 to describe the actual Day-19 disposition (Proxycurl deferred; current W4 decision is whether to re-evaluate before pilot).
docs/operations/w4-bilateral-pass-6-agent-md.md:158:## 5. Scribe — `agents/recruitment/scribe/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:164:  - **Codex says:** "Lines 76-80 list `brief.start_date`, `placement.week_1_status_note`, and `opportunity.sector` as canonical/schema-verified, but `vertical-schema.yaml` uses `start_date_target` and the v0.3 supplement explicitly says `week_1_status_note` became `week_1_status_vault_path` and `opportunity.sector` is not yet in schema. Fix the field table to use schema-backed names or land the missing supplement before ratification."
docs/operations/w4-bilateral-pass-6-agent-md.md:165:  - **Likely:** FIX-IN-PLACE. Replace field names: `start_date` → `start_date_target`; `week_1_status_note` → `week_1_status_vault_path`. For `opportunity.sector`: drop from canonical, or escalate to "v0.4-pending" tag.
docs/operations/w4-bilateral-pass-6-agent-md.md:175:  - **Cite:** §3 lines 16, 30, 39; cross-ref §8 lines 295-298 + ULTRAPLAN A3 lines 521-523
docs/operations/w4-bilateral-pass-6-agent-md.md:176:  - **Codex says:** "Lines 16, 30, and 39 include Ringover as a provider, but §8 lines 295-298 only gate Fathom/Fireflies signup and connector work; ULTRAPLAN A3 lines 521-523 require Bullhorn, Fathom, and Fireflies tools/APIs, not Ringover. Either remove Ringover from v1.0 surfaces or add the Ringover commercial/API/connector prerequisites explicitly."
docs/operations/w4-bilateral-pass-6-agent-md.md:186:### Finding 5. ESC_PROVIDER_FETCH_FAIL used outside catalogue definition
docs/operations/w4-bilateral-pass-6-agent-md.md:188:  - **Codex says:** "Line 250 defines it for Fathom/Fireflies/Ringover transcript fetches, but `agents/_shared/escalation-codes.md` lines 324-329 define a generic upstream read failure with examples that do not include transcript providers and no transcript-specific payload. Either update the catalogue to register transcript-provider usage and payload fields, or use/register a Scribe-specific transcript fetch code."
docs/operations/w4-bilateral-pass-6-agent-md.md:228:1. **Hh_decision_* coverage** (Scribe #2, Concierge #1) — workflow narratives are dropping the decision-log writes between numbered steps. After this pass, recommend a one-shot grep on all 6 agent.md to confirm every workflow step that produces output/action has an `hh_decision_*` annotation.
docs/operations/w4-bilateral-pass-6-agent-md.md:230:2. **Schema-citation hygiene** (Janitor #2, #3, #4; Sourcing Scout #1; Scribe #1) — v0.2/v0.3 supplement boundary is the single most-failed cross-reference. After this pass, recommend a CI grep that flags any `agent.md` field reference whose name doesn't appear in `vertical-schema.yaml` OR `vertical-schema.v0.3-supplement.yaml`.
docs/operations/w4-bilateral-pass-6-agent-md.md:232:3. **Catalogue completeness** (Diagnostic #2, Janitor #1, Scribe #5) — `escalation-codes.md` is the canonical mapping; agent.md narratives drift from it. After this pass, recommend a CI grep verifying every `ESC_*` reference in `agent.md` exists in the catalogue with at least the agent_name in `used_by`.
docs/operations/w4-day-20-founder-runbook.md:112:5. Scribe (5 findings) — Ringover scope question is the only non-mechanical
packages/utilities/web-scraper/pnpm-lock.yaml:118:    resolution: {integrity: sha512-0T+A9WZm+bZ84nZBtk1ckYsOvyA3x7e2Acj1KdVfV4/2tdG4fzUp91YHx+GArWLtwqp77pBXVCPn2We7Letr0Q==}
packages/utilities/web-scraper/pnpm-lock.yaml:256:    resolution: {integrity: sha512-KabT5I6StirGfIz0FMgl1I+R1H73Gp0ofL9A3nG3i/cYFJzKHhouBV5VWK1CSgKvVaG4q1RNpCTR2LuTVB3fIw==}
packages/utilities/web-scraper/pnpm-lock.yaml:298:    resolution: {integrity: sha512-SQPZOwoTTT/HXFXQJG/vBX8sOFagGqvZyXcgLA3NhIqcBv1BJU1d46c0rGcrij2B56Z2rNiSLaZOYW5cUk7yLQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:376:    resolution: {integrity: sha512-cXb5vApOsRsxsEl4mcZ1XY3D4DzcoMxR/nnc4IyqYs0rTI8ZKmW6kyyg+11Z8yvgMfAEldKzP7AdP64HnSC/6g==}
packages/utilities/web-scraper/pnpm-lock.yaml:394:    resolution: {integrity: sha512-8wZM2qqtv9UP3mzy7HiGYNH/zjTA355mpeuA+859TyR+e+Tc08IHYpLJuMsfpDJwoLo1ikIJI8jC3GFjnRClzA==}
packages/utilities/web-scraper/pnpm-lock.yaml:494:    resolution: {integrity: sha512-zzNR+SdQSDJzc8joaeP8QQoCQr8NuYx2dIIytl1QeBEZHJ9uW6hebsrYgbz8hJwUQao3TWCMtmfV8Nu1twOLAw==}
packages/utilities/web-scraper/pnpm-lock.yaml:718:    resolution: {integrity: sha512-RGwwWnwQvkVfavKVt22FGLw+xYSdzARwm0ru6DhTVA3umU5hZc28V3kO4stgYryrTlLpuvgI9GiijltAjNbcqA==}
packages/utilities/web-scraper/pnpm-lock.yaml:858:    resolution: {integrity: sha512-GDhwkLfywWL2s6vEjyhri+eXmfH6j1L7JE27WhqLeYzoh/A3DBaYGEj2H/HFZCn/kMfim73FXxEJTw06WtxQwg==}
packages/utilities/web-scraper/pnpm-lock.yaml:1004:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:57:test.describe('sendMessage', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:227:test.describe('sendPhoto', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:304:test.describe('editMessageText', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:347:test.describe('sendChatAction', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:370:test.describe('answerCallbackQuery', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:391:test.describe('getUpdates', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:440:test.describe('getFile and downloadFile', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:476:test.describe('Media processing', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:648:test.describe('Telegram logging', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:729:test.describe('TelegramPoller', () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:807:test.describe('Callback data patterns', () => {
docs/_supplementary/planning-phase-brief.md:62:| 1.8 | Fathom Webhook Receiver Spec | **P** → CC2 builds |
docs/_supplementary/planning-phase-brief.md:177:- Session 24: Integration Specs Batch 1 — Fathom, HubSpot, Gmail, Slack, Notion, DocuSign (3.8)
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
docs/_supplementary/execution-plan.md:41:The Build Plan described each component's purpose and architecture. For each one, you need a *developer-ready spec* — concrete enough that a dev can open a cursor and start writing the code without further back-and-forth. Twelve components total.
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
docs/_supplementary/execution-plan.md:541:  - *Prompt:* "Write the Voice Receptionist Full Specification: the Vapi platform configuration (assistants, tools, actions), the pre-call context injection (practice info, FAQs, protocols), the in-call escalation triggers, the post-call Claude Code agent that processes the call outcome, the Calendly/Cal.com booking flow, the FAQ training pipeline, the edge cases (accents, complaints, emergencies, out-of-hours), the testing framework (100+ test calls before launch)."
docs/operations/goal-option-c-diagnostic-end-to-end.md:155:- `errors.ts` — 429 → ESC_RATE_LIMIT_HIT, 5xx → ESC_SCHEMA_VIOLATION
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
packages/harness/cortextos/tests/playwright/dashboard-auth.spec.ts:17:test.describe('Dashboard Auth (24.2, 24.4)', () => {
docs/operations/founder-legal-setup-guide.md:108:Previous versions of this doc listed: **Bowers Anderson**, **LawBite**, **Privacy Helper**, **Vouch**. Their URLs did not resolve when I tested. These may be real firms at different URLs, or they may not exist as I described — I cited them from training-data memory without verification. If you Google these names and they look real + currently active, by all means contact them — but I cannot vouch for the citations I previously gave.
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
packages/diagnostic-generator/tests/conversation-opener.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
packages/diagnostic-generator/tests/conversation-opener.test.ts:41:describe("§12 conversation opener — LLM-driven with fallback", () => {
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:54:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:55:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:65:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:106:| Fathom/Fireflies MCP connector | Reserved for W6 |
docs/operations/goal-week-3-polish-and-scaffold.md:210:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:310:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_BULLHORN_WRITE_FAIL, ESC_SCHEMA_VIOLATION, ESC_RATE_LIMIT_HIT, ESC_AUTOSEND_YELLOW_SPOT_CHECK.
docs/operations/goal-week-3-polish-and-scaffold.md:326:### DAY 17 — Scribe agent.md scaffold (Step 9)
docs/operations/goal-week-3-polish-and-scaffold.md:328:#### Step 9 — `agents/recruitment/scribe/agent.md` (~2-3 hours)
docs/operations/goal-week-3-polish-and-scaffold.md:331:- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
docs/operations/goal-week-3-polish-and-scaffold.md:332:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:333:- `bullhorn-integration-path.md` §4.1 (Scribe's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:334:- `vertical-schema.yaml` §3 agent_access_matrix Scribe row
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:342:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§6 Escalation codes:** ESC_BULLHORN_WRITE_FAIL, ESC_VOICE_DRIFT, ESC_SCHEMA_VIOLATION, ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
docs/operations/goal-week-3-polish-and-scaffold.md:347:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:348:- **§9 Open questions:** 4-6 covering Fathom vs Fireflies first-mover choice, webhook auth, field-extraction model selection, tacit-note length cap.
docs/operations/goal-week-3-polish-and-scaffold.md:352:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:531:- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:619:  Scribe (W6):            <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:632:  <SHA>  decision(pre-build): agents/recruitment/scribe/agent.md
docs/operations/goal-week-3-polish-and-scaffold.md:658:    - Scribe build (depends on Bullhorn W + Fathom MCP)
docs/operations/goal-week-3-polish-and-scaffold.md:663:  - <Fathom/Fireflies signup for W6>
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
packages/diagnostic-generator/tests/online-footprint.test.ts:1:import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
packages/diagnostic-generator/tests/online-footprint.test.ts:20:describe("@ifos/diagnostic-generator — online-footprint slug fallback", () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:66:test.describe('Task JSON format (dashboard sync compatibility)', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:172:test.describe('Event JSONL format (dashboard sync compatibility)', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:287:test.describe('Heartbeat JSON format (dashboard compatibility)', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:362:test.describe('Message JSONL format (dashboard API compatibility)', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:469:test.describe('Approval JSON format (dashboard sync compatibility)', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:540:test.describe('Bus message JSON format', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:595:test.describe('Experiments JSON format (dashboard API compatibility)', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:710:test.describe('Goals JSON format (dashboard compatibility)', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:762:test.describe('Agent config JSON format', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:796:test.describe('Org context JSON format', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:824:test.describe('Cross-format consistency', () => {
packages/harness/cortextos/tests/playwright/dashboard-formats.spec.ts:902:test.describe('Format edge cases', () => {
packages/diagnostic-generator/tests/generate.test.ts:1:import { afterEach, beforeEach, describe, expect, it } from "vitest";
packages/diagnostic-generator/tests/generate.test.ts:25:describe("@ifos/diagnostic-generator", () => {
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:284:def describe_media(client, config, file_path, media_type="video"):
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:303:            "Describe this image in detail. Include:\n"
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:311:            "Transcribe and describe this audio. Include:\n"
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:548:    """Ingest an image: Gemini Flash describes it, then embed description + raw image together."""
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:557:    description, media_bytes, mime = describe_media(client, config, file_path, "image")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:594:    """Ingest a video: chunk it, describe each chunk, embed.
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:639:                description, media_bytes, mime = describe_media(client, config, chunk_path, "video")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:640:                print(f"    Described via video")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:645:            # Large chunk or video failed: extract audio and describe that
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:653:                    description, media_bytes, mime = describe_media(client, config, audio_path, "audio")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:659:                    print(f"    Described via audio extraction")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:703:    """Ingest audio: chunk if needed, describe, embed description + audio together."""
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:719:        description, media_bytes, mime = describe_media(client, config, file_path, "audio")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:755:                description, media_bytes, mime = describe_media(client, config, chunk["path"], "audio")
packages/harness/cortextos/knowledge-base/scripts/mmrag.py:757:                print(f"  WARNING: Failed to transcribe chunk {chunk['index']}: {e}")
packages/harness/cortextos/tests/sprint6-fastchecker.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/sprint6-fastchecker.test.ts:6:describe('Sprint 6: Fast-Checker Completeness', () => {
packages/harness/cortextos/tests/sprint6-fastchecker.test.ts:18:  describe('Persistent dedup file', () => {
packages/harness/cortextos/tests/sprint6-fastchecker.test.ts:56:  describe('Urgent signal detection', () => {
packages/harness/cortextos/tests/sprint6-fastchecker.test.ts:79:  describe('Typing indicator', () => {
packages/harness/cortextos/tests/sprint6-fastchecker.test.ts:100:  describe('SIGUSR1 wake', () => {
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:1:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:41:describe('cron-management skill', () => {
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:42:  describe('canonical sync', () => {
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:50:  describe('frontmatter structure', () => {
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:81:  describe('body references all 6 bus commands', () => {
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:110:  describe('stale patterns removed from body', () => {
packages/harness/cortextos/tests/unit/skills/cron-management-skill.test.ts:132:  describe('gap documentation', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/sprint7-environment.test.ts:7:describe('Sprint 7: Environment & Config Completeness', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:18:  describe('Timezone resolution', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:46:  describe('Day/night mode detection', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:59:  describe('Heartbeat with mode and loop_interval', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:78:  describe('enabled-agents.json format compatibility', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:125:  describe('Loop interval from config.json', () => {
packages/harness/cortextos/tests/sprint7-environment.test.ts:144:  describe('Uninstall', () => {
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:9:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/scripts/migrate-runtime-field.test.ts:15:describe('migrate-runtime-field', () => {
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:6:describe('Sprint 2: Onboarding & Lifecycle', () => {
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:17:  describe('enabled-agents.json format', () => {
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:67:  describe('crash-alert hook logic', () => {
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:116:  describe('PM2 ecosystem generator', () => {
packages/harness/cortextos/tests/sprint2-lifecycle.test.ts:136:  describe('install creates proper directory structure', () => {
packages/harness/cortextos/tests/sprint4-catalog.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/sprint4-catalog.test.ts:12:describe('Sprint 4: Community Catalog', () => {
packages/harness/cortextos/tests/sprint4-catalog.test.ts:89:  describe('browseCatalog', () => {
packages/harness/cortextos/tests/sprint4-catalog.test.ts:152:  describe('installCommunityItem', () => {
packages/harness/cortextos/tests/sprint4-catalog.test.ts:231:  describe('prepareSubmission', () => {
packages/harness/cortextos/tests/sprint4-catalog.test.ts:308:  describe('submitCommunityItem', () => {
packages/harness/cortextos/tests/integration/codex-bus-roundtrip.test.ts:10:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/codex-bus-roundtrip.test.ts:46:describe('codex bus round-trip', () => {
packages/harness/cortextos/tests/unit/dashboard/cron-utils-validation.test.ts:10:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/unit/dashboard/cron-utils-validation.test.ts:16:describe('isValidScheduleClient', () => {
packages/harness/cortextos/tests/unit/dashboard/cron-utils-validation.test.ts:63:describe('isValidCronName', () => {
packages/harness/cortextos/tests/unit/dashboard/cron-utils-validation.test.ts:94:describe('scheduleExamples', () => {
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:39:import { describe, it, expect, vi, beforeEach, afterEach, beforeAll, afterAll } from 'vitest';
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:233:describe('Journey 1: New user setup (ONBOARDING.md + bus add-cron + scheduler)', () => {
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:235:  it('J1-1: ONBOARDING.md prescribes bus add-cron (not /loop) for persistent crons', () => {
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:408:describe('Journey 2: Existing user upgrade (cron-migration + zero-downtime)', () => {
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:572:describe('Journey 3: Operator workflow (dashboard API CRUD round-trip)', () => {
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:16:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:76:describe('add-cron → update-cron → remove-cron round-trip', () => {
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:123:describe('add-cron error cases', () => {
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:189:describe('update-cron error cases', () => {
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:215:describe('remove-cron error cases', () => {
packages/harness/cortextos/tests/integration/ipc-cron-mutations.test.ts:239:describe('isValidSchedule comprehensive', () => {
packages/harness/cortextos/tests/unit/cli/add-agent-validation.test.ts:18:import { describe, it, expect, vi, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/cli/add-agent-validation.test.ts:21:describe('BUG-041: add-agent agent name validation', () => {
packages/harness/cortextos/tests/integration/execution-log-pagination.test.ts:11:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/integration/execution-log-pagination.test.ts:79:describe('100-entry log — getExecutionLogPage', () => {
packages/harness/cortextos/tests/integration/execution-log-pagination.test.ts:161:describe('entriesToCsv — format validation', () => {
packages/harness/cortextos/tests/integration/execution-log-pagination.test.ts:214:describe('readExecutionLogPage — dashboard API helper', () => {
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:5:import { transcribeVoice } from '../../../src/telegram/transcribe';
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:7:describe('transcribeVoice', () => {
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:12:    workDir = mkdtempSync(join(tmpdir(), 'cortextos-transcribe-test-'));
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:37:    expect(await transcribeVoice(oggPath)).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:41:    expect(await transcribeVoice(join(workDir, 'missing.ogg'))).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:45:    expect(await transcribeVoice('')).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:52:    expect(await transcribeVoice(oggPath)).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:62:    expect(await transcribeVoice(oggPath)).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:76:    expect(await transcribeVoice(oggPath)).toBeNull();
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:87:    const result = await transcribeVoice(oggPath, { timeoutMs: 100 });
packages/harness/cortextos/src/pty/agent-pty.ts:332:      'ProgramFiles', 'ProgramFiles(x86)', 'ProgramW6432',
packages/harness/cortextos/src/daemon/agent-process.ts:570:      return ' DELIVERABLE STANDARD: Every task you submit for review MUST have at least one file deliverable attached via the save-output bus command. A task with zero file deliverables will be sent back. Attach files with: cortextos bus save-output <task-id> <file-path> --label "<descriptive label>". Labels must be human-readable at a glance: describe WHAT it is plus enough context to understand at a glance. Good: "Traffic Growth Plan — 10 channels, 30-day launch sequence". Bad: "traffic-growth-plan.md" or "output-1". Notes are for context only, never file paths or URLs.';
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:16:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:60:describe('3.1 — templates/*/AGENTS.md External Persistent Crons section', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:65:    describe(`templates/${name}/AGENTS.md`, () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:157:describe('3.2 — Onboarding docs contain persistent cron guidance', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:166:    describe(label, () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:213:describe('3.3 — Skill documentation updates', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:214:  describe('community/skills/heartbeat/SKILL.md', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:238:  describe('community/skills/autoresearch/SKILL.md', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:256:describe('3.4 — CRONS_MIGRATION_GUIDE.md', () => {
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:322:describe('cross-cutting: no deprecated patterns in template docs', () => {
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:23:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:102:describe.skipIf(!existsSync(DIST_CLI))('Iter 12 audit: concurrent bus update-cron lost-update race', () => {
packages/harness/cortextos/tests/integration/agent-bootstrap-crons.test.ts:23:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/agent-bootstrap-crons.test.ts:151:describe('Scenario 1: Boot with crons.json', () => {
packages/harness/cortextos/tests/integration/agent-bootstrap-crons.test.ts:210:describe('Scenario 2: Boot without crons.json', () => {
packages/harness/cortextos/tests/integration/agent-bootstrap-crons.test.ts:252:describe('Scenario 3: Boot with corrupted crons.json', () => {
packages/harness/cortextos/tests/integration/agent-bootstrap-crons.test.ts:310:describe('Scenario 4: Reload after bus add-cron', () => {
packages/harness/cortextos/tests/integration/migration-guide-references-upgrade-cmd.test.ts:19:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/integration/migration-guide-references-upgrade-cmd.test.ts:26:describe('CRONS_MIGRATION_GUIDE.md upgrade-cron-teaching references', () => {
packages/harness/cortextos/tests/integration/migration-guide-references-upgrade-cmd.test.ts:49:  it('describes the whitelist mechanics', () => {
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:9:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/upgrade-cron-teaching-cli.test.ts:63:describe.skipIf(!existsSync(DIST_CLI))('bus upgrade-cron-teaching CLI', () => {
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:21:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:27:describe('PR-02: add-agent --runtime codex-app-server', () => {
packages/harness/cortextos/tests/unit/cli/add-agent-codex.test.ts:224:describe('PR-10: add-agent rejects codex+claude-only-template combos', () => {
packages/harness/cortextos/tests/integration/codex-handoff-lifecycle.test.ts:17:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/codex-handoff-lifecycle.test.ts:93:describe('codex handoff lifecycle — schema parity with claude', () => {
packages/harness/cortextos/tests/unit/telegram/api.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/telegram/api.test.ts:7:describe('TelegramAPI fetch timeout', () => {
packages/harness/cortextos/tests/unit/telegram/api.test.ts:59:describe('TelegramAPI.validateCredentials', () => {
packages/harness/cortextos/tests/unit/telegram/api.test.ts:276:describe('formatValidateError', () => {
packages/harness/cortextos/tests/unit/cli/add-agent-template-parity.test.ts:15:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/unit/cli/add-agent-template-parity.test.ts:39:describe('agent template skill-tree parity', () => {
packages/harness/cortextos/package-lock.json:279:      "integrity": "sha512-KabT5I6StirGfIz0FMgl1I+R1H73Gp0ofL9A3nG3i/cYFJzKHhouBV5VWK1CSgKvVaG4q1RNpCTR2LuTVB3fIw==",
packages/harness/cortextos/package-lock.json:639:      "integrity": "sha512-lDSwMgg+M5rq6JKBYaJwSX6T9e/HK2qqZ1oxmOwn4AQoJE5D+7TumsxLGC02PWS//rkIVqbZv3XA3ejsc9FYvg==",
packages/harness/cortextos/package-lock.json:873:      "integrity": "sha512-zzNR+SdQSDJzc8joaeP8QQoCQr8NuYx2dIIytl1QeBEZHJ9uW6hebsrYgbz8hJwUQao3TWCMtmfV8Nu1twOLAw==",
packages/harness/cortextos/package-lock.json:1219:      "integrity": "sha512-mjCpF7GmkRtSJwon+Rq1N8+pI+8l7w5g9Z3vWj4T7abguC4Czwi3Yu/pFaLvA3TTeMVjnu3ctigusqWUfjZzvw==",
packages/harness/cortextos/package-lock.json:1499:      "integrity": "sha512-u09m3CuwLzShA0EYKMNiFgcjjzwqtUMLmuCJLeZWjjOYA3IT2Di09KaxGBTP9xVztWyIWjVdsB2E9goMjZvTQg==",
packages/harness/cortextos/package-lock.json:1594:      "integrity": "sha512-gbu+7B0YgUJ2nkdsRJrFFW6X7NTP44WlhiclHniUhxADQJH5Szt9mZ9hWnJPJ8YwOK5zUOSSlSvyzRf0u1DSBQ==",
packages/harness/cortextos/package-lock.json:1666:      "integrity": "sha512-g7yfUmxYS4mNxk31qbOYsSt2F4m1E02LFqO53Xpzg3zKMhLAPZAjjfyl9e6z7HrW6LvUdTwAQR3HHfLjpko16A==",
packages/harness/cortextos/package-lock.json:1887:      "integrity": "sha512-RGwwWnwQvkVfavKVt22FGLw+xYSdzARwm0ru6DhTVA3umU5hZc28V3kO4stgYryrTlLpuvgI9GiijltAjNbcqA==",
packages/harness/cortextos/package-lock.json:1990:      "integrity": "sha512-gX8LrtNEI5hq8DVUfRQMbr5lpaS4nMIWV+7XEbXk2b8kiQIizgnlr12B4dA3ZEx3308ze0O4Q1R+cHts8kyUJg==",
packages/harness/cortextos/package-lock.json:2368:      "integrity": "sha512-Amq9B/SoZYdDi1kFrojnoqPLxYhQ4Wo5XiL8EVJrVsB8ARoC1PWW6VGtT0WKCemjy8aC+louJnjS7U18x3b06Q==",
packages/harness/cortextos/package-lock.json:2777:      "integrity": "sha512-oMA2dcrw6u0YfxJQXm342bFKX/E4sG9rbTzO9ptUcR/e8A33cHuvStiYOwH7fszkZlZ1z/ta9AAoPk2F4qIOHA==",
packages/harness/cortextos/package-lock.json:2827:      "integrity": "sha512-VmtB2rFU/GroZ4oL8+ZqXgSA38O6GR8KSIvWmEFv63pQ0G6KaBH9s07PO8XTXP4vI+3UJUEypOfjkGfmSBBR0w==",
packages/harness/cortextos/package-lock.json:3165:      "integrity": "sha512-GDhwkLfywWL2s6vEjyhri+eXmfH6j1L7JE27WhqLeYzoh/A3DBaYGEj2H/HFZCn/kMfim73FXxEJTw06WtxQwg==",
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:5: * Four scenarios mirror real user journeys described in the docs:
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:14: *   2. Programmatically executes the doc-prescribed steps in a tmp agent dir
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:28:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:151:describe('Scenario 1: New user onboarding (ONBOARDING.md Step 9)', () => {
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:157:    // The doc must prescribe bus add-cron as the persistent cron creation command
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:160:    // Must describe the command signature
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:262:describe('Scenario 2: Existing user upgrade (CRONS_MIGRATION_GUIDE.md)', () => {
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:401:  it('2g: --force flag bypasses marker (doc prescribes this for manual re-run)', () => {
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:439:describe('Scenario 3: Operator cron CRUD via cron-management/SKILL.md', () => {
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:444:  it('3a: SKILL.md exists and prescribes bus add-cron workflow', () => {
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:502:    // same disk path the doc describes via get-cron-log
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:615:describe('Scenario 4: Support troubleshooting missing crons', () => {
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:630:    // Must prescribe list-crons as first diagnostic
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:633:    // Must prescribe get-cron-log for history
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:42:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:160:describe('AD-1: Cron lifecycle audit', () => {
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:228:describe('AD-2: Execution audit', () => {
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:316:describe('AD-3: Failure audit', () => {
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:397:describe('AD-4: Recovery audit', () => {
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:473:describe('AD-5: User actions audit', () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:24:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:106:describe('community templates: no stale cron restoration references', () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:117:    describe(`community/agents/${agent}`, () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:134:          // The step 6 line should describe daemon management
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:209:  describe('community/skills/cron-management/SKILL.md', () => {
packages/harness/cortextos/tests/integration/community-templates-no-stale-cron-refs.test.ts:239:  describe('m2c1-worker exclusion: legitimate /loop use is preserved', () => {
packages/harness/cortextos/tests/unit/telegram/media.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/telegram/media.test.ts:16:describe('sanitizeFilename', () => {
packages/harness/cortextos/tests/unit/telegram/media.test.ts:57:describe('processMediaMessage', () => {
packages/harness/cortextos/tests/unit/telegram/media.test.ts:59:  let prevNoTranscribe: string | undefined;
packages/harness/cortextos/tests/unit/telegram/media.test.ts:64:    // junk audio bytes. transcribe.ts has dedicated tests.
packages/harness/cortextos/tests/unit/telegram/media.test.ts:65:    prevNoTranscribe = process.env.CTX_TELEGRAM_NO_TRANSCRIBE;
packages/harness/cortextos/tests/unit/telegram/media.test.ts:71:    if (prevNoTranscribe === undefined) {
packages/harness/cortextos/tests/unit/telegram/media.test.ts:74:      process.env.CTX_TELEGRAM_NO_TRANSCRIBE = prevNoTranscribe;
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:25:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:148:describe('bus add-cron', () => {
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:255:describe('bus remove-cron', () => {
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:292:describe('bus list-crons', () => {
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:341:describe('bus update-cron', () => {
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:441:describe('bus test-cron-fire', () => {
packages/harness/cortextos/tests/unit/cli/bus-crons.test.ts:514:describe('bus get-cron-log', () => {
packages/harness/cortextos/tests/integration/fleet-health-mixed-codex-claude.test.ts:11:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/integration/fleet-health-mixed-codex-claude.test.ts:74:describe('fleet health — codex + claude coexistence', () => {
packages/agent-renderer/tests/fixtures/test-agent/tools.yaml:9:  - ESC_SCHEMA_VIOLATION
packages/harness/cortextos/tests/unit/telegram/poller.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/telegram/poller.test.ts:43:describe('TelegramPoller — offset-after-handler', () => {
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:10:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:16:describe('BUG-035 + BUG-013: enable-agent validation', () => {
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:39:  describe('discoverProjectRoot (BUG-035)', () => {
packages/harness/cortextos/tests/unit/cli/enable-agent-validation.test.ts:67:  describe('readEnabledAgents (BUG-013)', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:45:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:184:describe('FM-1: Disk full — ENOSPC write failure, no data loss on recovery', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:299:describe('FM-2: Clock skew — clock jumps backward, no double-fires or lost crons', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:396:describe('FM-3: Cascading failures — daemon + agent + corruption; independent recovery', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:557:describe('FM-4: .bak backup/restore — automatic readCrons() fallback', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:647:describe('FM-5: Catch-up storm — 100+ overdue crons, bounded + no tick drift', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:741:describe('FM-7: Log rotation under concurrent write pressure', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:834:describe('FM-8: Cron-expression local-time behavior — consistent with Date.getHours()', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:954:describe('FM-9: IPC reload during active catch-up — schedule change mid-flight', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:1052:describe('AF-1: lastGoodSchedule — transient corruption keeps crons firing', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:1182:describe('AF-2: Sequential fire under slow PTY — drift quantification', () => {
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:1261:describe('FM-6: PTY blocked — retries until accepting, recovery within spec', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:15:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/integration/multi-agent-crons-codex.test.ts:139:describe('codex multi-agent crons — migration + scheduling parity', () => {
packages/harness/cortextos/tests/unit/cli/send-telegram-normalize.test.ts:19:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/cli/send-telegram-normalize.test.ts:79:describe('PR-12: send-telegram normalizes literal \\n / \\t (codex agent fix)', () => {
packages/harness/cortextos/tests/integration/fleet-health-mixed-agents.test.ts:39:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/integration/fleet-health-mixed-agents.test.ts:114:describe('computeFleetHealth — 3 agent mixed scenario', () => {
packages/harness/cortextos/tests/unit/cli/lifecycle-markers.test.ts:18:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/cli/lifecycle-markers.test.ts:25:describe('BUG-036: lifecycle marker writes', () => {
packages/harness/cortextos/tests/unit/cli/lifecycle-markers.test.ts:42:  describe('writeDisableMarker', () => {
packages/harness/cortextos/tests/unit/cli/lifecycle-markers.test.ts:70:  describe('writeStopMarker', () => {
packages/harness/cortextos/tests/unit/telegram/send-message.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/telegram/send-message.test.ts:52:describe('TelegramAPI.sendMessage HTML mode', () => {
packages/harness/cortextos/tests/unit/telegram/send-message.test.ts:192:describe('TelegramAPI.sendMessage self_chat runtime safety net', () => {
packages/harness/cortextos/tests/unit/cli/restart-command.test.ts:8:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/unit/cli/restart-command.test.ts:11:describe('issue #328: cortextos restart <agent>', () => {
packages/harness/cortextos/tests/unit/cli/restart-command.test.ts:30:  it('describes itself as a stop+start (not a daemon restart)', () => {
packages/harness/cortextos/tests/unit/telegram/logging.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/telegram/logging.test.ts:15:describe('Telegram Logging', () => {
packages/harness/cortextos/tests/unit/telegram/logging.test.ts:26:  describe('logOutboundMessage', () => {
packages/harness/cortextos/tests/unit/telegram/logging.test.ts:53:  describe('logInboundMessage', () => {
packages/harness/cortextos/tests/unit/telegram/logging.test.ts:70:  describe('recordInboundTelegram', () => {
packages/harness/cortextos/tests/unit/telegram/logging.test.ts:185:  describe('cacheLastSent / readLastSent', () => {
packages/harness/cortextos/tests/unit/telegram/logging.test.ts:205:describe('TelegramAPI.sendPhoto', () => {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:21:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/integration/crons-migration.test.ts:123:describe('migrateCronsForAgent', () => {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:424:describe('migrateAllAgents', () => {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:535:describe('disabled cron handling', () => {
packages/harness/cortextos/tests/integration/crons-migration.test.ts:558:describe('disk round-trip via readCrons()', () => {
packages/harness/cortextos/tests/integration/phase1-backtesting.test.ts:28:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/phase1-backtesting.test.ts:181:describe('Scenario 1: Normal operation — 5 agents, 10 crons, 72h sim', () => {
packages/harness/cortextos/tests/integration/phase1-backtesting.test.ts:272:describe('Scenario 2: Daemon crash recovery', () => {
packages/harness/cortextos/tests/integration/phase1-backtesting.test.ts:335:describe('Scenario 3: Corrupted crons.json', () => {
packages/harness/cortextos/tests/integration/phase1-backtesting.test.ts:419:describe('Scenario 4: PTY injection failure / retries', () => {
packages/harness/cortextos/tests/integration/phase1-backtesting.test.ts:575:describe('Scenario 5: Concurrent cron fires', () => {
packages/harness/cortextos/tests/integration/phase1-backtesting.test.ts:664:describe('Scenario 6: Log integrity end-to-end', () => {
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:30:import { describe, it, expect, vi, beforeEach, afterEach, beforeAll, afterAll } from 'vitest';
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:170:describe('Scenario 1: Normal operation — 7 agents, 50+ crons, 24h sim', () => {
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:326:describe('Scenario 2: Daemon crash — stop mid-run, restart, bounded catch-up', () => {
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:466:describe('Scenario 3: Agent crash — PTY unavailable, graceful failure, recovery', () => {
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:610:describe('Scenario 4: State corruption — 3 sub-types, fallback to last-known-good', () => {
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:797:describe('Scenario 5: PTY degradation — slow injection, intermittent failure, retry coverage', () => {
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1003:describe('Scenario 6: Concurrent stress — 10 crons fire simultaneously, no race conditions', () => {
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1153:describe('Scenario 7: Dashboard polling accuracy throughout simulation', () => {
packages/agent-renderer/tests/fixtures/test-agent/agent.md:22:Single ESC code in scope: `ESC_SCHEMA_VIOLATION` on malformed input. Routes per
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:30:describe('scanFile — pattern detection', () => {
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:102:describe('scanFile — apply mode (literal substitutions)', () => {
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:131:describe('listAgentFiles', () => {
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:159:describe('scanAgentDir', () => {
packages/harness/cortextos/tests/unit/utils/cron-teaching-scanner.test.ts:199:describe('groupMatchesByFile', () => {
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:14:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/cron-migration-banner.test.ts:75:describe('migrateCronsForAgent — cron-teaching upgrade banner', () => {
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:1:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:13:describe('readMaxCrashesPerDay', () => {
packages/harness/cortextos/tests/unit/hooks/hook-crash-alert.test.ts:53:describe('notifyAgents', () => {
packages/agent-renderer/tests/unit/fileMap.test.ts:1:import { describe, it, expect } from "vitest";
packages/agent-renderer/tests/unit/fileMap.test.ts:4:describe("fileMap", () => {
packages/harness/cortextos/tests/unit/utils/cron-health.test.ts:16:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/unit/utils/cron-health.test.ts:80:describe('computeHealth — never-fired', () => {
packages/harness/cortextos/tests/unit/utils/cron-health.test.ts:127:describe('computeHealth — failure', () => {
packages/harness/cortextos/tests/unit/utils/cron-health.test.ts:152:describe('computeHealth — warning', () => {
packages/harness/cortextos/tests/unit/utils/cron-health.test.ts:232:describe('computeHealth — healthy', () => {
packages/harness/cortextos/tests/unit/utils/cron-health.test.ts:282:describe('computeHealth — successRate24h', () => {
packages/harness/cortextos/tests/unit/utils/cron-health.test.ts:340:describe('computeHealth — edge cases', () => {
packages/harness/cortextos/tests/unit/utils/cron-health.test.ts:397:describe('aggregateFleetHealth', () => {
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:21:import { describe, it, expect, beforeAll, afterAll } from 'vitest';
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:196:describe('Perf: GET /api/workflows/crons — 50 crons (5 agents)', () => {
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:222:describe('Perf: GET /api/workflows/crons — 100 crons (10 agents)', () => {
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:247:describe('Perf: GET /api/workflows/health — 50 crons', () => {
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:272:describe('Perf: GET /api/workflows/health — 100 crons + heavy logs', () => {
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:297:describe('Perf: GET executions — 1000-entry log', () => {
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:329:describe('Perf: all p95 < 2000ms (summary)', () => {
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:30: * Each describe block gets a fresh pair of temp directories (tmpCtxRoot,
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:34:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:333:describe('Scenario 1: Fresh deployment — 25+ crons, 5 agents, 72h', () => {
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:430:describe('Scenario 2: Mixed deployment — 3 pre-migrated + 2 unmigrated', () => {
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:543:describe('Scenario 3: Agent addition mid-simulation', () => {
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:673:describe('Scenario 4: Agent removal mid-simulation', () => {
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:800:describe('Scenario 5: Daemon kill + restart — full state recovery', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:19:describe('Hook Utilities', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:20:  describe('parseHookInput', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:44:  describe('loadEnv', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:98:  describe('isClaudeDirOperation', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:120:  describe('Permission hook skips ExitPlanMode', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:131:  describe('formatToolSummary', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:181:  describe('sanitizeCodeBlock', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:193:  describe('buildPermissionKeyboard', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:205:  describe('buildPlanKeyboard', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:215:  describe('Ask hook - state file structure', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:253:  describe('Ask hook - single-select keyboard', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:272:  describe('Ask hook - multi-select keyboard', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:286:  describe('formatQuestionMessage', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:336:  describe('Plan mode hook - plan reading', () => {
packages/harness/cortextos/tests/unit/hooks/hooks.test.ts:365:  describe('outputDecision', () => {
packages/agent-renderer/tests/unit/preflight.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from "vitest";
packages/agent-renderer/tests/unit/preflight.test.ts:52:describe("preflight", () => {
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:20:import { describe, it, expect, vi, beforeAll, beforeEach, afterAll } from 'vitest';
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:150:describe('Scenario 1 — Create cron (POST + GET round-trip)', () => {
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:262:describe('Scenario 2 — Edit cron (PATCH + disk verification)', () => {
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:359:describe('Scenario 3 — View history (GET executions, pagination + filter + export)', () => {
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:482:describe('Scenario 4 — Health dashboard (GET /api/workflows/health)', () => {
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:678:describe('Scenario 5 — Test-fire (POST /api/workflows/crons/[agent]/[name]/fire)', () => {
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:790:describe('Scenario 6 — Delete cron (DELETE + disk verification)', () => {
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:44:describe('readAllowedRoots', () => {
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:66:describe('addAllowedRoot — adversarial inputs', () => {
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:110:describe('removeAllowedRoot', () => {
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:126:describe('isPathUnderRoots — traversal resistance', () => {
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:160:describe('computeValidRoots', () => {
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:181:describe('realpath-based traversal (integration)', () => {
packages/harness/cortextos/tests/unit/utils/allowed-roots.test.ts:239:describe('null-byte and control-char inputs', () => {
packages/agent-renderer/tests/unit/atomicWrite.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from "vitest";
packages/agent-renderer/tests/unit/atomicWrite.test.ts:17:describe("atomicWrite", () => {
packages/harness/cortextos/tests/unit/hooks/extract-facts.test.ts:1:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/unit/hooks/extract-facts.test.ts:4:describe('extractKeywords', () => {
packages/harness/cortextos/tests/unit/utils/lock.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/utils/lock.test.ts:7:describe('mkdir-based locking', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:36:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:200:describe('P-1: Startup time — 1000 crons ready in <5s', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:257:describe('P-2: Fire latency — due cron fires within 1 min of schedule', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:322:describe('P-3: Polling overhead — 100 agents + 1000 crons scan in <10s', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:379:describe('P-4: File I/O — read/write 100 crons per operation in <100ms', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:455:describe('P-5: Concurrent fires — 100 simultaneous crons succeed in <30s (simulated)', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:594:describe('P-6: Disk usage — 1000 crons.json + logs <100MB', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:673:describe('SC-1: Scaling cliff — startup time at 500/1000/2000 crons', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:725:describe('SC-2: Scaling cliff — sequential fire drift at 1000 crons × 10ms PTY', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:793:describe('SC-3: File I/O scale — writeCrons at 500 and 1000 crons', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:830:describe('SC-4: Fleet scan scale — 200 and 500 agents', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:886:describe('Phase 5 Performance Summary', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:31: * Each `describe` block shares a single beforeEach/afterEach that creates a
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:38:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:349:describe('Scenario 1: Migration + boot all agents', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:428:describe('Scenario 2: Schedulers register all crons', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:478:describe('Scenario 3: 72-hour simulation', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:586:describe('Scenario 4: Cross-agent message passing still works', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:636:describe('Scenario 5: Idempotent re-migration', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:717:describe('Scenario 6: Per-agent log files written correctly', () => {
packages/harness/cortextos/tests/integration/multi-agent-crons.test.ts:797:describe('Scenario 7: Concurrent scheduler ticks don\'t corrupt crons.json', () => {
packages/harness/cortextos/tests/unit/utils/validate.test.ts:1:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/unit/utils/validate.test.ts:14:describe('validateInstanceId', () => {
packages/harness/cortextos/tests/unit/utils/validate.test.ts:32:describe('validateAgentName', () => {
packages/harness/cortextos/tests/unit/utils/validate.test.ts:62:describe('validatePriority', () => {
packages/harness/cortextos/tests/unit/utils/validate.test.ts:76:describe('validateEventCategory', () => {
packages/harness/cortextos/tests/unit/utils/validate.test.ts:89:describe('validateEventSeverity', () => {
packages/harness/cortextos/tests/unit/utils/validate.test.ts:97:describe('validateApprovalCategory', () => {
packages/harness/cortextos/tests/unit/utils/validate.test.ts:105:describe('validateModel', () => {
packages/harness/cortextos/tests/unit/utils/validate.test.ts:116:describe('stripControlChars', () => {
packages/harness/cortextos/tests/unit/utils/validate.test.ts:149:describe('isValidJson', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:18:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:93:describe('MANUAL_FIRE_COOLDOWN_MS', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:104:describe('manualFireCooldownRemaining', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:156:describe('handleFireCron — input validation', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:194:describe('handleFireCron — cron not found', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:219:describe('handleFireCron — manualFireDisabled', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:251:describe('handleFireCron — cooldown', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:316:describe('handleFireCron — happy path', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fire-cron.test.ts:369:describe('handleAddCron — manualFireDisabled round-trip', () => {
packages/agent-renderer/tests/unit/synthesis.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from "vitest";
packages/agent-renderer/tests/unit/synthesis.test.ts:53:describe("synthesis/claudeMd", () => {
packages/agent-renderer/tests/unit/synthesis.test.ts:80:describe("synthesis/configJson", () => {
packages/agent-renderer/tests/unit/synthesis.test.ts:113:describe("synthesis/envFile", () => {
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:25:describe('context_status.json staleness detection', () => {
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:66:describe('context monitor tier selection', () => {
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:111:describe('warning deduplication', () => {
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:129:describe('context monitor circuit breaker', () => {
packages/harness/cortextos/tests/unit/daemon/context-monitor.test.ts:168:describe('consumeHandoffBlock', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fleet-health.test.ts:9:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/ipc-fleet-health.test.ts:107:describe('computeFleetHealth', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-fleet-health.test.ts:278:describe('invalidateFleetHealthCache', () => {
packages/harness/cortextos/tests/unit/utils/org.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/utils/org.test.ts:20:describe('normalizeOrgName', () => {
packages/harness/cortextos/tests/unit/bus/system.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/bus/system.test.ts:24:describe('Bus System', () => {
packages/harness/cortextos/tests/unit/bus/system.test.ts:35:  describe('selfRestart', () => {
packages/harness/cortextos/tests/unit/bus/system.test.ts:64:  describe('hardRestart', () => {
packages/harness/cortextos/tests/unit/bus/system.test.ts:83:  describe('autoCommit', () => {
packages/harness/cortextos/tests/unit/bus/system.test.ts:178:  describe('checkGoalStaleness', () => {
packages/harness/cortextos/tests/unit/bus/system.test.ts:260:  describe('postActivity', () => {
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:1:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:49:describe('AgentManager.discoverAndStart - BUG-028 fix', () => {
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:142:describe('AgentManager.discoverAndStart - BUG-043 fix (multi-org support)', () => {
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:235:describe('AgentManager.restartAgent - BUG-007 fix (rebuild Telegram poller)', () => {
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:290:describe('buildReplyContext - Telegram reply context (BUG fix: media replies lost)', () => {
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:352:describe('AgentManager.reloadCrons - silent-success bug fix (iter 7)', () => {
packages/agent-renderer/pnpm-lock.yaml:130:    resolution: {integrity: sha512-0T+A9WZm+bZ84nZBtk1ckYsOvyA3x7e2Acj1KdVfV4/2tdG4fzUp91YHx+GArWLtwqp77pBXVCPn2We7Letr0Q==}
packages/agent-renderer/pnpm-lock.yaml:268:    resolution: {integrity: sha512-KabT5I6StirGfIz0FMgl1I+R1H73Gp0ofL9A3nG3i/cYFJzKHhouBV5VWK1CSgKvVaG4q1RNpCTR2LuTVB3fIw==}
packages/agent-renderer/pnpm-lock.yaml:310:    resolution: {integrity: sha512-SQPZOwoTTT/HXFXQJG/vBX8sOFagGqvZyXcgLA3NhIqcBv1BJU1d46c0rGcrij2B56Z2rNiSLaZOYW5cUk7yLQ==}
packages/agent-renderer/pnpm-lock.yaml:388:    resolution: {integrity: sha512-cXb5vApOsRsxsEl4mcZ1XY3D4DzcoMxR/nnc4IyqYs0rTI8ZKmW6kyyg+11Z8yvgMfAEldKzP7AdP64HnSC/6g==}
packages/agent-renderer/pnpm-lock.yaml:406:    resolution: {integrity: sha512-8wZM2qqtv9UP3mzy7HiGYNH/zjTA355mpeuA+859TyR+e+Tc08IHYpLJuMsfpDJwoLo1ikIJI8jC3GFjnRClzA==}
packages/agent-renderer/pnpm-lock.yaml:506:    resolution: {integrity: sha512-zzNR+SdQSDJzc8joaeP8QQoCQr8NuYx2dIIytl1QeBEZHJ9uW6hebsrYgbz8hJwUQao3TWCMtmfV8Nu1twOLAw==}
packages/agent-renderer/pnpm-lock.yaml:751:    resolution: {integrity: sha512-RGwwWnwQvkVfavKVt22FGLw+xYSdzARwm0ru6DhTVA3umU5hZc28V3kO4stgYryrTlLpuvgI9GiijltAjNbcqA==}
packages/agent-renderer/pnpm-lock.yaml:904:    resolution: {integrity: sha512-GDhwkLfywWL2s6vEjyhri+eXmfH6j1L7JE27WhqLeYzoh/A3DBaYGEj2H/HFZCn/kMfim73FXxEJTw06WtxQwg==}
packages/agent-renderer/pnpm-lock.yaml:1050:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/harness/cortextos/tests/unit/daemon/crash-handlers.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/crash-handlers.test.ts:29:describe('crash history persistence', () => {
packages/harness/cortextos/tests/unit/daemon/crash-handlers.test.ts:74:describe('shouldSendCrashLoopAlert', () => {
packages/harness/cortextos/tests/unit/daemon/crash-handlers.test.ts:134:describe('countRecentCrashes', () => {
packages/harness/cortextos/tests/unit/daemon/crash-handlers.test.ts:149:describe('writeDaemonCrashedMarkers', () => {
packages/harness/cortextos/tests/unit/bus/approval.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/bus/approval.test.ts:76:describe('createApproval', () => {
packages/harness/cortextos/tests/unit/bus/approval.test.ts:253:describe('createApproval — agent-bot Telegram ping (closes 50h+ Repo-B-style stall)', () => {
packages/harness/cortextos/tests/unit/bus/approval.test.ts:396:describe('updateApproval (regression guard for activity-channel callback path)', () => {
packages/harness/cortextos/tests/unit/bus/approval.test.ts:422:describe('listPendingApprovals', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:15:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:86:describe('isValidSchedule', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:122:describe('handleAddCron — happy path', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:198:describe('handleAddCron — validation failures', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:289:describe('handleUpdateCron — happy path', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:325:describe('handleUpdateCron — validation failures', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:377:describe('handleRemoveCron — happy path', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-mutations.test.ts:403:describe('handleRemoveCron — validation failures', () => {
packages/harness/cortextos/dashboard/src/app/globals.css:187:  --success: oklch(0.555 0.17 145);              /* #16A34A */
packages/harness/cortextos/tests/unit/daemon/agent-process-codex-app-server.test.ts:1:import { describe, it, expect, vi, beforeEach } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/agent-process-codex-app-server.test.ts:113:describe('AgentProcess codex-app-server runtime', () => {
packages/harness/cortextos/dashboard/src/lib/watcher.ts:156: * Subscribe to SSE events. Returns an unsubscribe function.
packages/harness/cortextos/tests/unit/bus/crons-io.test.ts:8:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/bus/crons-io.test.ts:76:describe('readCrons', () => {
packages/harness/cortextos/tests/unit/bus/crons-io.test.ts:123:describe('readCronsWithStatus', () => {
packages/harness/cortextos/tests/unit/bus/crons-io.test.ts:193:describe('writeCrons + readCrons roundtrip', () => {
packages/harness/cortextos/tests/unit/bus/crons-io.test.ts:254:describe('updated_at envelope', () => {
packages/harness/cortextos/tests/unit/bus/crons-io.test.ts:293:describe('addCron', () => {
packages/harness/cortextos/tests/unit/bus/crons-io.test.ts:328:describe('removeCron', () => {
packages/harness/cortextos/tests/unit/bus/crons-io.test.ts:365:describe('updateCron', () => {
packages/harness/cortextos/tests/unit/bus/crons-io.test.ts:423:describe('getCronByName', () => {
packages/harness/cortextos/tests/unit/bus/reminders.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/bus/reminders.test.ts:28:describe('reminders', () => {
packages/harness/cortextos/tests/unit/bus/reminders.test.ts:42:  describe('createReminder', () => {
packages/harness/cortextos/tests/unit/bus/reminders.test.ts:74:  describe('listReminders', () => {
packages/harness/cortextos/tests/unit/bus/reminders.test.ts:99:  describe('getOverdueReminders', () => {
packages/harness/cortextos/tests/unit/bus/reminders.test.ts:122:  describe('ackReminder', () => {
packages/harness/cortextos/tests/unit/bus/reminders.test.ts:138:  describe('pruneReminders', () => {
packages/harness/cortextos/tests/unit/daemon/cron-scheduler.test.ts:10:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/cron-scheduler.test.ts:77:describe('nextFireFromCron', () => {
packages/harness/cortextos/tests/unit/daemon/cron-scheduler.test.ts:178:describe('CronScheduler', () => {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:1:import { describe, it, expect, vi, beforeEach } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:110:describe('AgentProcess - BUG-011 fix (stop awaits PTY exit)', () => {
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:253:describe('AgentProcess - BUG-048 fix (session timer re-reads config)', () => {
packages/harness/cortextos/tests/unit/bus/hooks.test.ts:5:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/bus/hooks.test.ts:73:describe('src/bus/hooks — Day-2 per-handler wiring', () => {
packages/harness/cortextos/tests/unit/bus/hooks.test.ts:79:  describe('loadHookRegistry', () => {
packages/harness/cortextos/tests/unit/bus/hooks.test.ts:109:  describe('matchHooks', () => {
packages/harness/cortextos/tests/unit/bus/hooks.test.ts:152:  describe('dispatchHook — Day-2 result-driven emit', () => {
packages/harness/cortextos/tests/unit/bus/hooks.test.ts:269:  describe('handler registry', () => {
packages/harness/cortextos/tests/unit/daemon/worker-process.test.ts:1:import { describe, it, expect, vi, beforeEach } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/worker-process.test.ts:49:describe('WorkerProcess', () => {
packages/harness/cortextos/tests/unit/daemon/worker-process.test.ts:50:  describe('construction', () => {
packages/harness/cortextos/tests/unit/daemon/worker-process.test.ts:64:  describe('getStatus', () => {
packages/harness/cortextos/tests/unit/daemon/worker-process.test.ts:84:  describe('isFinished', () => {
packages/harness/cortextos/tests/unit/daemon/worker-process.test.ts:104:  describe('inject', () => {
packages/harness/cortextos/tests/unit/daemon/worker-process.test.ts:126:  describe('onDone callback', () => {
packages/harness/cortextos/tests/unit/daemon/worker-process.test.ts:147:  describe('terminate', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser-codex.test.ts:18:import { describe, it, expect, beforeAll, beforeEach } from 'vitest';
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser-codex.test.ts:64:describe('codex pricing — gpt-5-codex pricing key resolution', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser-codex.test.ts:100:describe('codex JSONL parsing — flat schema shape', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser-codex.test.ts:185:describe('codex parser robustness', () => {
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:4:triggers: ["buy", "purchase", "pay for", "subscribe to", "need a credit card", "make a payment", "sign up for paid plan", "buy a domain", "purchase API credits", "pay invoice", "need to pay", "financial transaction", "virtual card", "agentcard"]
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:20:- Subscribe to a paid API or SaaS tool
packages/harness/cortextos/tests/unit/bus/task.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/bus/task.test.ts:8:describe('Task Management', () => {
packages/harness/cortextos/tests/unit/bus/task.test.ts:32:  describe('createTask', () => {
packages/harness/cortextos/tests/unit/bus/task.test.ts:65:  describe('updateTask', () => {
packages/harness/cortextos/tests/unit/bus/task.test.ts:75:  describe('completeTask', () => {
packages/harness/cortextos/tests/unit/bus/task.test.ts:113:  describe('listTasks', () => {
packages/harness/cortextos/tests/unit/bus/task.test.ts:153:describe('Cross-org task lifecycle', () => {
packages/harness/cortextos/tests/unit/bus/task.test.ts:351:describe('claimTask — atomic claim (beads-inspired)', () => {
packages/harness/cortextos/tests/unit/bus/task.test.ts:428:describe('Task audit log (append-only JSONL)', () => {
packages/harness/cortextos/tests/unit/bus/task.test.ts:517:describe('Task dependency DAG (blocks / blocked_by)', () => {
packages/harness/cortextos/tests/unit/bus/task.test.ts:644:describe('compactTasks — semantic compaction of old completed tasks', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-list-executions.test.ts:12:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/ipc-list-executions.test.ts:90:describe('list-cron-executions IPC — pagination + filter', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/markdown-parser.test.ts:1:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/dashboard/src/lib/__tests__/markdown-parser.test.ts:17:describe('parseMarkdown / serializeMarkdown', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/markdown-parser.test.ts:108:describe('parseIdentityMd / serializeIdentityMd', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/markdown-parser.test.ts:172:describe('parseSoulMd / serializeSoulMd', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/markdown-parser.test.ts:213:describe('parseGoalsMd / serializeGoalsMd', () => {
packages/mcp-connectors/companies-house/README.md:32:| 401 | API key invalid; fail-fast | ESC_SCHEMA_VIOLATION |
packages/mcp-connectors/companies-house/README.md:35:| 5xx | Server error; fail-fast | ESC_SCHEMA_VIOLATION |
packages/harness/cortextos/tests/unit/bus/oauth.test.ts:1:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/bus/oauth.test.ts:66:describe('loadAccounts', () => {
packages/harness/cortextos/tests/unit/bus/oauth.test.ts:79:describe('getActiveAccount', () => {
packages/harness/cortextos/tests/unit/bus/oauth.test.ts:92:describe('checkUsageApi', () => {
packages/harness/cortextos/tests/unit/bus/oauth.test.ts:170:describe('refreshOAuthToken', () => {
packages/harness/cortextos/tests/unit/bus/oauth.test.ts:226:describe('rotateOAuth', () => {
packages/harness/cortextos/tests/unit/bus/oauth.test.ts:322:describe('alert thresholds', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:1:import { describe, it, expect, beforeEach, beforeAll } from 'vitest';
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:70:describe('syncTasks', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:147:describe('syncApprovals', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:180:describe('syncEvents', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:216:describe('syncHeartbeat', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:247:describe('syncAll', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:291:describe('syncFile routing', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:353:describe('path extraction helpers', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser.test.ts:1:import { describe, it, expect, beforeAll, beforeEach } from 'vitest';
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser.test.ts:52:describe('calculateCost — gpt-5-codex pricing', () => {
packages/harness/cortextos/dashboard/src/lib/__tests__/cost-parser.test.ts:85:describe('scanCodexLogsCosts', () => {
packages/mcp-connectors/companies-house/tests/scaffold.test.ts:1:import { describe, it, expect } from "vitest";
packages/mcp-connectors/companies-house/tests/scaffold.test.ts:4:describe("@ifos/companies-house — scaffold", () => {
packages/harness/cortextos/tests/unit/bus/event.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/bus/event.test.ts:15:describe('Bus events', () => {
packages/harness/cortextos/tests/unit/bus/event.test.ts:59:  describe('heartbeat refresh side-effect', () => {
packages/harness/cortextos/dashboard/package-lock.json:56:      "integrity": "sha512-UrcABB+4bUrFABwbluTIBErXwvbsU/V7TZWfmbgJfbkwiBuziS9gxdODUyuiecfdGQ85jglMW6juS3+z5TsKLw==",
packages/harness/cortextos/dashboard/package-lock.json:263:      "integrity": "sha512-+W6cISkXFa1jXsDEdYA8HeevQT/FULhxzR99pxphltZcVaugps53THCeiWA8SguxxpSp3gKPiuYfSWopkLQ4hw==",
packages/harness/cortextos/dashboard/package-lock.json:366:      "integrity": "sha512-qMlSxKbpRlAridDExk92nSobyDdpPijUq2DW6oDnUqd0iOGxmQjyqhMIihI9+zv4LPyZdRje2cavWPbCbWm3eA==",
packages/harness/cortextos/dashboard/package-lock.json:643:      "integrity": "sha512-bR9e6o2BDB12jzN/gIbjHa5wLJ4UjD1CB9pM7ehlc0ddk6EBz+yYS1EV2MF55/HUxrHcB/hehAyt5vhsA3hx7w==",
packages/harness/cortextos/dashboard/package-lock.json:739:      "integrity": "sha512-QxULHAm7cNu72w97JUNCBFODFaXpbDg+dP8b/oWFAZ2MTRppA3U00Y2L1HqaS4J6yBqxwa/Y3nMBaxVKbB/NsA==",
packages/harness/cortextos/dashboard/package-lock.json:971:      "integrity": "sha512-BrpvfNAE3dcvq7ll3xVumzjKjZQ5tI1sEUIKr3Uoks0XUl45St3FlatVqef9prk4jRDzhW6WZg+3bk93y6pLjA==",
packages/harness/cortextos/dashboard/package-lock.json:1241:      "integrity": "sha512-GwtvgtXxnWsucXvbQXkRgqksiH2Qed37H9xHZocE5sA3N8O8O8/8FA3uclQXxXVzc9XBZuEOMK7+r02FmSpHtw==",
packages/harness/cortextos/dashboard/package-lock.json:1455:      "integrity": "sha512-qmp9VrzgPgMoGZyPvrQHqk02uyjA0/QrTO26Tqk6l4ZV0MPWIW6LTkqOIov+J1yEu7MbFQaDpwdwJKhbJvuRxQ==",
packages/harness/cortextos/dashboard/package-lock.json:1563:      "integrity": "sha512-7zznwNaqW6YtsfrGGDA6BRkISKAAE1Jo0QdpNYXNMHu2+0dTrPflTLNkpc8l7MUP5M16ZJcUvysVWWrMefZquA==",
packages/harness/cortextos/dashboard/package-lock.json:1889:      "integrity": "sha512-zzNR+SdQSDJzc8joaeP8QQoCQr8NuYx2dIIytl1QeBEZHJ9uW6hebsrYgbz8hJwUQao3TWCMtmfV8Nu1twOLAw==",
packages/harness/cortextos/dashboard/package-lock.json:2039:      "integrity": "sha512-Mx/tjlNA3G8kg14QvuGAJ4xBwPk1tUHq56JxZ8CXnZwz1Etz714soCEzGQQzVMz4bEnGPowzkV6Xrp6wAkEWOQ==",
packages/harness/cortextos/dashboard/package-lock.json:2159:      "integrity": "sha512-gbKGcRUYIjA3/zCCNaWDciTMFI0dCkvou3TL8Zmy5Nc7sJ47a0jtOeZoTaMxkuqRo9cRhjOdZJXegxYE5FN/xw==",
packages/harness/cortextos/dashboard/package-lock.json:2288:      "integrity": "sha512-JTF99U/6XIjCBo0wqkU5sK10glYe27MRRsfwoiq5zzOEZLHU3A3KCMa5X/azekYRCJ0HlwI0crAXS/5dEHTzDg==",
packages/harness/cortextos/dashboard/package-lock.json:3226:      "integrity": "sha512-FPdhvsW6g06T9BWT0qTwiVZYE2WIFo2dY5aCSpjG/S/u1tby+wXoslXS0kl3/KXnULlLr1E3NPRRw0g7t2kgaQ==",
packages/harness/cortextos/dashboard/package-lock.json:3482:      "integrity": "sha512-NMv9ASNARoKksWtsq/SHakpYAYnhBrQgGD8zkLYk/jaK8jUGn08CfEdTRgYhMypUQAfzSP8W6gNLe0q19/t4VA==",
packages/harness/cortextos/dashboard/package-lock.json:3946:      "integrity": "sha512-tD40eHxA35h0PEIZNeIjkHoDR4YjjJp34biM0mDvplBe//mB+IHCqHDGV7pxF+7MklTvighcCPPZC7ynWyjdTA==",
packages/harness/cortextos/dashboard/package-lock.json:4228:      "integrity": "sha512-gbu+7B0YgUJ2nkdsRJrFFW6X7NTP44WlhiclHniUhxADQJH5Szt9mZ9hWnJPJ8YwOK5zUOSSlSvyzRf0u1DSBQ==",
packages/harness/cortextos/dashboard/package-lock.json:4300:      "integrity": "sha512-g7yfUmxYS4mNxk31qbOYsSt2F4m1E02LFqO53Xpzg3zKMhLAPZAjjfyl9e6z7HrW6LvUdTwAQR3HHfLjpko16A==",
packages/harness/cortextos/dashboard/package-lock.json:4847:      "integrity": "sha512-9ZLprWS6EENmhEOpjCYW2c8VkmOvckIJZfkr7rBW6dObmfgJ/L1GpSYW5Hpo9lDz4D1+n0Ckz8rU7FwHDQiG/w==",
packages/harness/cortextos/dashboard/package-lock.json:5622:      "integrity": "sha512-RGwwWnwQvkVfavKVt22FGLw+xYSdzARwm0ru6DhTVA3umU5hZc28V3kO4stgYryrTlLpuvgI9GiijltAjNbcqA==",
packages/harness/cortextos/dashboard/package-lock.json:5751:      "integrity": "sha512-N+MeXYoqr3pOgn8xfyRPREN7gHakLYjhsHhWGT3fWAiL4IkAt0iDw14QiiEm2bE30c5XX5q0FtAA3CK5f9/BUg==",
packages/harness/cortextos/dashboard/package-lock.json:5960:      "integrity": "sha512-sqQamAnR14VgCr1A618A3sGrygcpK+HEbenA/HiEAkkUwcZIIB/tgWqHFxWgOyDh4nB4JCRimh79dR5Ywc9MDQ==",
packages/harness/cortextos/dashboard/package-lock.json:6176:      "integrity": "sha512-TtpcNJ3XAzx3Gq8sWRzJaVajRs0uVxA2YAkdb1jm2YkPz4G6egUFAyA3n5vtEIZefPk5Wa4UXbKuS5fKkJWdgA==",
packages/harness/cortextos/dashboard/package-lock.json:6418:      "integrity": "sha512-scB3nz4WmG75pV8+3eRUQOHZlNSUhFNq37xnpgRkCCELU3XMvXAxLk1eqWWyE22Ki4Q01Fnsw9BA3cJHDPgn2Q==",
packages/harness/cortextos/dashboard/package-lock.json:6925:      "integrity": "sha512-78/PXT1wlLLDgTzDs7sjq9hzz0vXD+zn+7wypEe4fXQxCmdmqfGsEPQxmiCSQI3ajFV91bVSsvNtrJRiW6nGng==",
packages/harness/cortextos/dashboard/package-lock.json:6979:      "integrity": "sha512-buewHzMvYL29jdeQTVILecSaZKnt/RJWjoZCF5OW60Z67/GmSLBkOFM7qh1PI3zFNtJbaZL5eQu1vLfazOwj4g==",
packages/harness/cortextos/dashboard/package-lock.json:7362:      "integrity": "sha512-1cDNdwJ2Jaohmb3sg4OmKaMBwuC48sYni5HUw2DvsC8LjGTLK9h+eb1X6RyuOHe4hT0ULCW68iomhjUoKUqlPQ==",
packages/harness/cortextos/dashboard/package-lock.json:7700:      "integrity": "sha512-gNCGbnnnnFAUGKeZ9PdbyeGYJqewpmc2aKHUEMO5nQPWU9lOmv7jcmQIv+qHD8fXW6W7qfuCwX4rY9LNRjXrkQ==",
packages/harness/cortextos/dashboard/package-lock.json:7723:      "integrity": "sha512-1BC0BVFhS/p0qtw6enp8e+8OD0UrK0oFLztSjNzhcKA3WDuJxxAPXzPuPtKkjEY9UUoEWlX/8fgKeu2S8i9JTA==",
packages/harness/cortextos/dashboard/package-lock.json:7910:      "integrity": "sha512-1Qed0/Hr2m+YqxnM09CjA2d/i6YZNfF6R2oRAOj36eUdS6qIV/huPJNSEpKbupewFs+ZsJlxsjjPbc0/afW6Lw==",
packages/harness/cortextos/dashboard/package-lock.json:8004:      "integrity": "sha512-MjYsKHO5O7mCsmRGxWcLWheFqN9DJ/2TmngvjKXihe6efViPqc274+Fx/4fYj/r03+ESvBdTXK0V6tA3rgez1g==",
packages/harness/cortextos/dashboard/package-lock.json:8048:      "integrity": "sha512-ISWac8drv4ZGfwKl5slpHG9OwPNty4jOWPRIhBpxOoD+hqITiwuipOQ2bNthAzwA3B4fIjO4Nln74N0S9byq8A==",
packages/harness/cortextos/dashboard/package-lock.json:8213:      "integrity": "sha512-3REwJAnIqjWO7qbfyKWMBI7hUHFhqUor7weFG3WbJW6Enq3V7cx60QuurWjGUXxbX57Iy4RJIkAZFObAqiqpxw==",
packages/harness/cortextos/dashboard/package-lock.json:8368:      "integrity": "sha512-Bdboy+l7tA3OGW6FjyFHWkP5LuByj1Tk33Ljyq0axyzdk9//JSi2u3fP1QSmd1KNwq6VOKYGlAu87CisVir6Pw==",
packages/harness/cortextos/dashboard/package-lock.json:8470:      "integrity": "sha512-oxVHkHR/EJf2CNXnWxRLW6mg7JyCCUcG0DtEGmL2ctUo1PNTin1PUil+r/+4r5MpVgC/fn1kjsx7mjSujKqIpw==",
packages/harness/cortextos/dashboard/package-lock.json:8763:      "integrity": "sha512-Amq9B/SoZYdDi1kFrojnoqPLxYhQ4Wo5XiL8EVJrVsB8ARoC1PWW6VGtT0WKCemjy8aC+louJnjS7U18x3b06Q==",
packages/harness/cortextos/dashboard/package-lock.json:8908:      "integrity": "sha512-KpNARQA3Iwv+jTA0utUVVbrh+Jlrr1Fv0e56GGzAFOXN7dk/FviaDW8LHmK52DlcH4WP2n6gI8vN1aesBFgo9w==",
packages/harness/cortextos/dashboard/package-lock.json:8990:      "integrity": "sha512-8q7VEgMJW4J8tcfVPy8g09NcQwZdbwFEqhe/WZkoIzjn/3TGDwtOCYtXGxA3O8tPzpczCCDgv+P2P5y00ZJOOg==",
packages/harness/cortextos/dashboard/package-lock.json:9279:      "integrity": "sha512-+c51gquM3F6nMVmoAusRJ7RIoY0K4Ts9HCCwyy/BRoe4mp3msZpOzYMyb5LAYc1wSo74PMQkGDcaghIO7W6Xjg==",
packages/harness/cortextos/dashboard/package-lock.json:9368:      "integrity": "sha512-/jKZoMpw0F8GRwl4/eLROPA3cfcXtLApP0QzLmUT/HuPCZWyB7IY9ZrMeKw2O/nFIqPQB3PVM9aYm0F312AXDQ==",
packages/harness/cortextos/dashboard/package-lock.json:9477:      "integrity": "sha512-W67iLl4J2EXEGTbfeHCffrjDfitvLANg0UlX3wFUUSTx92KXRFegMHUVgSqE+wvhAbi4WqjGg9czysTV2Epbew==",
packages/harness/cortextos/dashboard/package-lock.json:9804:      "integrity": "sha512-TXfryirbmq34y8QBwgqCVLi+8oA3oWx2eAnSn62ITyEhEYaWRlVZ2DvMM9eZbMs/RfxPu/PK/aBLyGj4IrqMHw==",
packages/harness/cortextos/dashboard/package-lock.json:10129:      "integrity": "sha512-VS7sjc6KR7e1ukRFhQSY5LM2uBWAUPiOPa/A3mkKmiMwSmRFUITt0xuj+/lesgnCv+dPIEYlkzrcyXgquIHMcA==",
packages/harness/cortextos/dashboard/package-lock.json:10531:      "integrity": "sha512-pb/MYmXstAkysRFx8piNI1tGFNQIFA3vkE3Gq4EuA1dF6gHp/+vgZqsCGJapvy8N3Q+4o7FwvquPJcnZ7RYy4g==",
packages/harness/cortextos/dashboard/package-lock.json:10550:      "integrity": "sha512-oMA2dcrw6u0YfxJQXm342bFKX/E4sG9rbTzO9ptUcR/e8A33cHuvStiYOwH7fszkZlZ1z/ta9AAoPk2F4qIOHA==",
packages/harness/cortextos/dashboard/package-lock.json:11314:      "integrity": "sha512-o7+c9bW6zpAdJHTtujeePODAhkuicdAryFsfVKwA+wGw89wJ4GTY484WTucM9hLtDEOpOvI+aHnzqnC5lHp4Rg==",
packages/harness/cortextos/dashboard/package-lock.json:11597:      "integrity": "sha512-mDAjwmZdh7LTT6pNleZ05Yt65HC3E+NiQzl672vQG38jIrehtJk/J3mNwIg+vShQPcLF/LV7CMnDW6vjj6sfYQ==",
packages/harness/cortextos/dashboard/package-lock.json:12058:      "integrity": "sha512-pjy2bYhSsufwWlKwPc+l3cN7+wuJlK6uz0YdJEOlQDbl6jo/YlPi4mb8agUkVC8BF7V8NuzeyPNqRksA3hztKQ==",
packages/harness/cortextos/dashboard/package-lock.json:12227:      "integrity": "sha512-SbPDPdDBYp+5MJHhBCAyI7wKM3d5ivekigc2Dk2s7pgbZ9wIgIBYGVw4zGHBml/qTFbexrofXW6Gu4noGxrOwQ==",
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:11:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:100:describe('computeNextFire', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:184:describe('listAllCrons (via computeNextFire + readCrons + getExecutionLog)', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:260:describe('getExecutionLog (list-cron-executions backing function)', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:329:describe('cron-utils parseDurationMs', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:370:describe('cron-utils formatSchedule', () => {
packages/harness/cortextos/tests/unit/daemon/ipc-list-crons.test.ts:391:describe('cron-utils formatRelative', () => {
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:113:describe('ingestKnowledgeBase — graceful missing-config', () => {
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:146:describe('queryKnowledgeBase — graceful missing-config', () => {
packages/harness/cortextos/tests/unit/bus/knowledge-base.test.ts:184:describe('kb warn messages — UX invariants', () => {
packages/mcp-connectors/companies-house/tests/unit.test.ts:1:import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
packages/mcp-connectors/companies-house/tests/unit.test.ts:42:describe("@ifos/companies-house — client", () => {
packages/mcp-connectors/companies-house/tests/unit.test.ts:79:describe("@ifos/companies-house — search", () => {
packages/mcp-connectors/companies-house/tests/unit.test.ts:110:describe("@ifos/companies-house — profile", () => {
packages/mcp-connectors/companies-house/tests/unit.test.ts:142:describe("@ifos/companies-house — officers", () => {
packages/mcp-connectors/companies-house/tests/unit.test.ts:165:describe("@ifos/companies-house — filingHistory", () => {
packages/mcp-connectors/companies-house/tests/unit.test.ts:191:describe("@ifos/companies-house — rate limiting", () => {
packages/harness/cortextos/tests/unit/daemon/agent-process-hermes.test.ts:1:import { describe, it, expect, vi, beforeEach } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/agent-process-hermes.test.ts:103:describe('AgentProcess - Hermes runtime: shouldContinue', () => {
packages/harness/cortextos/tests/unit/daemon/agent-process-hermes.test.ts:131:describe('AgentProcess - Hermes runtime: stop uses Ctrl+D', () => {
packages/harness/cortextos/community/skills/autoresearch/SKILL.md:123:[Describe the current approach being tested]
packages/harness/cortextos/tests/unit/bus/crons-schema.test.ts:1:import { describe, it, expect } from 'vitest';
packages/harness/cortextos/tests/unit/bus/crons-schema.test.ts:14:describe('cronsPathFor', () => {
packages/harness/cortextos/tests/unit/bus/crons-schema.test.ts:49:describe('CronDefinition — type shape', () => {
packages/harness/cortextos/dashboard/src/app/api/events/stream/route.ts:31:      // Subscribe to SSE events from the watcher emitter
packages/harness/cortextos/dashboard/src/app/api/events/stream/route.ts:32:      const unsubscribe = onSSEEvent((event) => {
packages/harness/cortextos/dashboard/src/app/api/events/stream/route.ts:57:        unsubscribe();
packages/harness/cortextos/tests/unit/bus/message.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/bus/message.test.ts:9:describe('Message Bus', () => {
packages/harness/cortextos/tests/unit/bus/message.test.ts:43:  describe('sendMessage', () => {
packages/harness/cortextos/tests/unit/bus/message.test.ts:98:  describe('checkInbox', () => {
packages/harness/cortextos/tests/unit/bus/message.test.ts:128:  describe('ackInbox', () => {
packages/harness/cortextos/tests/unit/daemon/cron-execution-log.test.ts:11:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/cron-execution-log.test.ts:101:describe('appendExecutionLog — single entry', () => {
packages/harness/cortextos/tests/unit/daemon/cron-execution-log.test.ts:200:describe('appendExecutionLog — retry sequence', () => {
packages/harness/cortextos/tests/unit/daemon/cron-execution-log.test.ts:234:describe('log rotation', () => {
packages/harness/cortextos/tests/unit/daemon/cron-execution-log.test.ts:334:describe('getExecutionLog', () => {
packages/harness/cortextos/tests/unit/daemon/cron-execution-log.test.ts:450:describe('log survives simulated process restart', () => {
packages/harness/cortextos/tests/unit/daemon/cron-execution-log.test.ts:474:describe('disk persistence across module resets', () => {
packages/harness/cortextos/tests/unit/bus/catalog.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/bus/catalog.test.ts:7:describe('installCommunityItem — install_path normalization (task_1776232775374_418)', () => {
packages/mcp-connectors/companies-house/pnpm-lock.yaml:114:    resolution: {integrity: sha512-0T+A9WZm+bZ84nZBtk1ckYsOvyA3x7e2Acj1KdVfV4/2tdG4fzUp91YHx+GArWLtwqp77pBXVCPn2We7Letr0Q==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:252:    resolution: {integrity: sha512-KabT5I6StirGfIz0FMgl1I+R1H73Gp0ofL9A3nG3i/cYFJzKHhouBV5VWK1CSgKvVaG4q1RNpCTR2LuTVB3fIw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:294:    resolution: {integrity: sha512-SQPZOwoTTT/HXFXQJG/vBX8sOFagGqvZyXcgLA3NhIqcBv1BJU1d46c0rGcrij2B56Z2rNiSLaZOYW5cUk7yLQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:372:    resolution: {integrity: sha512-cXb5vApOsRsxsEl4mcZ1XY3D4DzcoMxR/nnc4IyqYs0rTI8ZKmW6kyyg+11Z8yvgMfAEldKzP7AdP64HnSC/6g==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:390:    resolution: {integrity: sha512-8wZM2qqtv9UP3mzy7HiGYNH/zjTA355mpeuA+859TyR+e+Tc08IHYpLJuMsfpDJwoLo1ikIJI8jC3GFjnRClzA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:490:    resolution: {integrity: sha512-zzNR+SdQSDJzc8joaeP8QQoCQr8NuYx2dIIytl1QeBEZHJ9uW6hebsrYgbz8hJwUQao3TWCMtmfV8Nu1twOLAw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:714:    resolution: {integrity: sha512-RGwwWnwQvkVfavKVt22FGLw+xYSdzARwm0ru6DhTVA3umU5hZc28V3kO4stgYryrTlLpuvgI9GiijltAjNbcqA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:854:    resolution: {integrity: sha512-GDhwkLfywWL2s6vEjyhri+eXmfH6j1L7JE27WhqLeYzoh/A3DBaYGEj2H/HFZCn/kMfim73FXxEJTw06WtxQwg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:996:    resolution: {integrity: sha512-MSmPM9REYqDGBI8439mA4mWhV5sKmDlBKWIYbA3lRb2PTHACE0mgKwA8yQ2xq9vxDTuk4iPrECBAEW2aoFXY0Q==}
packages/harness/cortextos/tests/unit/bus/execution-log-pagination.test.ts:11:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/bus/execution-log-pagination.test.ts:75:describe('getExecutionLogPage — basic pagination', () => {
packages/harness/cortextos/tests/unit/bus/execution-log-pagination.test.ts:160:describe('getExecutionLogPage — statusFilter', () => {
packages/harness/cortextos/tests/unit/bus/execution-log-pagination.test.ts:239:describe('getExecutionLogPage — 100-entry default', () => {
packages/harness/cortextos/tests/unit/bus/execution-log-pagination.test.ts:260:describe('getExecutionLog — backward compat', () => {
packages/harness/cortextos/tests/unit/bus/agents.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/bus/agents.test.ts:8:describe('Agent Discovery', () => {
packages/harness/cortextos/tests/unit/bus/agents.test.ts:29:  describe('listAgents', () => {
packages/harness/cortextos/tests/unit/bus/agents.test.ts:179:  describe('notifyAgent', () => {
packages/harness/cortextos/tests/unit/bus/cron-state.test.ts:1:import { describe, it, expect, beforeEach } from 'vitest';
packages/harness/cortextos/tests/unit/bus/cron-state.test.ts:17:describe('parseDurationMs', () => {
packages/harness/cortextos/tests/unit/bus/cron-state.test.ts:50:describe('readCronState', () => {
packages/harness/cortextos/tests/unit/bus/cron-state.test.ts:58:describe('updateCronFire', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:65:describe('FastChecker', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:78:  describe('handleActivityCallback (Telegram approval inline buttons)', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:228:  describe('isAgentActive', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:276:  describe('sendTyping (via pollCycle)', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:322:  describe('formatTelegramTextMessage', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:389:  describe('readLastSent', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:429:  describe('handleCallback', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:585:  describe('sendNextQuestion', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:651:  describe('formatTelegramReaction', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:700:  describe('formatTelegramPhotoMessage', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:724:  describe('formatTelegramDocumentMessage', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:743:  describe('formatTelegramVoiceMessage', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:788:  describe('heartbeat watchdog', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:839:  describe('formatTelegramVideoMessage', () => {
packages/harness/cortextos/tests/unit/pty/inject.test.ts:1:import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/pty/inject.test.ts:4:describe('MessageDedup', () => {
packages/harness/cortextos/tests/unit/pty/inject.test.ts:28:describe('KEYS', () => {
packages/harness/cortextos/tests/unit/pty/inject.test.ts:38:describe('injectMessage — deferred Enter crash safety', () => {
packages/harness/cortextos/tests/unit/bus/task-management.test.ts:1:import { describe, it, expect, beforeEach, afterEach } from 'vitest';
packages/harness/cortextos/tests/unit/bus/task-management.test.ts:49:describe('Advanced Task Management', () => {
packages/harness/cortextos/tests/unit/bus/task-management.test.ts:73:  describe('checkStaleTasks', () => {
packages/harness/cortextos/tests/unit/bus/task-management.test.ts:158:  describe('archiveTasks', () => {
packages/harness/cortextos/tests/unit/bus/task-management.test.ts:218:  describe('checkHumanTasks', () => {
packages/harness/cortextos/tests/unit/pty/hermes-pty.test.ts:1:import { describe, it, expect, vi, beforeEach } from 'vitest';
packages/harness/cortextos/tests/unit/pty/hermes-pty.test.ts:48:describe('hermesDbExists', () => {
packages/harness/cortextos/tests/unit/pty/hermes-pty.test.ts:73:describe('HermesPTY', () => {
packages/harness/cortextos/tests/unit/pty/output-buffer.test.ts:1:import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
packages/harness/cortextos/tests/unit/pty/output-buffer.test.ts:30:describe('OutputBuffer redaction', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:1:import { describe, it, expect, vi, beforeEach } from 'vitest';
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:94:describe('CodexAppServerPTY socket path policy', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:119:describe('CodexAppServerPTY command mapping', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:498:describe('CodexAppServerPTY extractTelegramPayload media types', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:688:  describe('reply directive coverage on every Telegram media type', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:787:describe('CodexAppServerPTY thread lifecycle', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:836:describe('CodexAppServerPTY event handling', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:887:describe('CodexAppServerPTY thread/tokenUsage/updated → context_status.json', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:1025:describe('CodexAppServerPTY thread/tokenUsage/updated → codex-tokens.jsonl', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/fire-route.test.ts:18:import { describe, it, expect, vi, beforeEach } from 'vitest';
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/fire-route.test.ts:60:describe('POST fire route — success', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/fire-route.test.ts:105:describe('POST fire route — 403 manualFireDisabled', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/fire-route.test.ts:124:describe('POST fire route — 409 cooldown', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/fire-route.test.ts:143:describe('POST fire route — 404 not found', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/fire-route.test.ts:171:describe('POST fire route — 500 runtime errors', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/fire-route.test.ts:199:describe('POST fire route — 400 invalid input', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/executions-export.test.ts:16:import { describe, it, expect, beforeAll, afterAll } from 'vitest';
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/executions-export.test.ts:97:describe('GET /api/workflows/crons/[agent]/executions — pagination shape', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/executions-export.test.ts:119:describe('GET /api/workflows/crons/[agent]/executions — status filter', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/executions-export.test.ts:141:describe('GET /api/workflows/crons/[agent]/executions — CSV export', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/executions-export.test.ts:174:describe('GET /api/workflows/crons/[agent]/executions — JSON download export', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/crons/__tests__/executions-export.test.ts:199:describe('GET /api/workflows/crons/[agent]/executions — validation', () => {
packages/harness/cortextos/dashboard/src/components/workflows/cron-form.tsx:251:          aria-describedby={touched.name && errors.name ? 'cron-name-error' : undefined}
packages/harness/cortextos/dashboard/src/components/workflows/cron-form.tsx:274:          aria-describedby={
packages/harness/cortextos/dashboard/src/components/workflows/cron-form.tsx:326:          aria-describedby={touched.prompt && errors.prompt ? 'cron-prompt-error' : undefined}
packages/harness/cortextos/dashboard/src/app/api/comms/__tests__/routes.test.ts:12:import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
packages/harness/cortextos/dashboard/src/app/api/comms/__tests__/routes.test.ts:81:describe('GET /api/comms/feed', () => {
packages/harness/cortextos/dashboard/src/app/api/comms/__tests__/routes.test.ts:124:describe('GET /api/comms/channels', () => {
packages/harness/cortextos/dashboard/src/app/api/comms/__tests__/routes.test.ts:161:describe('GET /api/comms/channel/[pair]', () => {
packages/harness/cortextos/dashboard/src/app/api/comms/__tests__/routes.test.ts:200:describe('POST /api/comms/upload', () => {
packages/harness/cortextos/dashboard/src/app/api/workflows/health/__tests__/health-route.test.ts:14:import { describe, it, expect, beforeAll, afterAll } from 'vitest';
packages/harness/cortextos/dashboard/src/app/api/workflows/health/__tests__/health-route.test.ts:141:describe('GET /api/workflows/health', () => {
packages/harness/cortextos/community/agents/agentic-crm-assistant/TOOL_CONNECTIONS.md:23:| Meeting Notes | Granola, Fathom, Fireflies, Zoom transcripts, local files | Optional | Needed for automated meeting-note processing. |
packages/harness/cortextos/community/agents/agent/ONBOARDING.md:97:   For each workflow the user describes:
packages/harness/cortextos/community/agents/agentic-crm-assistant/.claude/skills/meeting-prep/SKILL.md:58:- Fathom/Zoom/Granola/Fireflies exports
packages/harness/cortextos/templates/agent/ONBOARDING.md:97:   For each workflow the user describes:
packages/harness/cortextos/community/agents/security/ONBOARDING.md:97:   For each workflow the user describes:
packages/harness/cortextos/templates/agent-codex/ONBOARDING.md:99:   For each workflow the user describes:
packages/harness/cortextos/community/agents/security/.claude/skills/autoresearch/SKILL.md:122:[Describe the current approach being tested]
packages/harness/cortextos/templates/orchestrator/.claude/skills/autoresearch/SKILL.md:126:[Describe the current approach being tested]
packages/harness/cortextos/templates/agent-codex/GUARDRAILS.md:17:| Telegram reply via stdout | "I'll just describe what I'd say" | Reply text is invisible unless it goes through `cortextos bus send-telegram`. Run the command. |
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/autoresearch/SKILL.md:121:[Describe the current approach being tested]
packages/harness/cortextos/templates/agent/.claude/skills/autoresearch/SKILL.md:122:[Describe the current approach being tested]
packages/harness/cortextos/templates/analyst/SYSTEM.md:7:This file should contain cross-agent system context. It is shared across all agents in the Organization and describes the cortextOS architecture, communication patterns, and operational protocols.

codex
The first pass found the current Scribe file plus the shared policy/catalogue and v0.3 supplement. I’m narrowing now to the master brief and ULTRAPLAN line anchors because those are required citations for this bundle type.
exec
/bin/zsh -lc "rg --files docs | rg -i '(master|ultra|plan|brief|kill|criterion|hygiene|adr|decision)'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/_archive-build-pack/08-OPEN-DECISIONS.md
docs/_archive-build-pack/06-BUILD-PLAN.md
docs/design-mockups/brain-ui-decisions-feed-light-v01.html
docs/operations/codex-ratification-execution-plan.md
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/decisions/brain-ui-scope.md
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
docs/decisions/2026-05-18-codex-ratification-manifest.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/decisions/README.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/2026-05-18-day-7-single-sentence-test.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
docs/decisions/sequencing-target.md
docs/decisions/bullhorn-integration-path.md
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md
docs/runbooks/operational-hygiene-protocol.md
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/ULTRAPLAN.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/execution-plan.md

exec
/bin/zsh -lc "rg -n \"ULTRAPLAN|master brief|§8\\.2|week 6|Scribe|post-call note|90% of calls|0\\.6|tacit|Fathom|Fireflies|Trigger 3|Bullhorn-touching|Trigger\" docs agents -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:116:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:171:    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
agents/_shared/autosend-policy.yaml:206:    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:16:# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:19:# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:65:          IR35 distinction matters for UK contractors. Extracted by Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:67:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:69:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:82:        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:84:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:110:          Contact's stated preference; extracted by Scribe from call context.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:112:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:114:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:121:          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:124:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:126:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:140:        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:142:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:152:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:154:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:165:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:167:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:178:          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:181:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:183:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:195:          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:201:        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:204:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:213:          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:215:        source: IFOS-derived (Scribe LLM extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:217:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:230:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:232:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:241:          Scribe LLM inference from prospecting-call urgency cues. Drives
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:243:        source: IFOS-derived (Scribe LLM classification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:245:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:255:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:257:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:281:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:283:#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:285:#     R-only for Scribe)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:286:#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:287:#   - Scribe timesheet: none → R (reads for placement-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:308:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:346:  #   Example: Scribe.candidate: R+W at entity level; per-field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:347:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:387:    # Scribe's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    # Postgres rows ONLY (not direct Bullhorn endpoint calls). Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:406:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:466:      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:479:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:484:      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:492:      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:496:      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:498:      for Scribe.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:505:      - Scribe (R+W)       # v0.3 NEW — writes 3 new prospecting-call fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:512:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:519:      - Scribe (R+W)       # v0.3 NEW — check-in field extraction
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:524:      their §4 specs); adds Scribe R+W for check-in writes.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:530:      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:535:      Scribe + Concierge (each reads timesheet for their respective
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:539:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:543:      - Scribe (R+W)       # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:555:      - Scribe (R+W)       # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:569:      §12 conversation opener; Janitor for tacit-note narratives; Cash
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:      granted Scribe + Concierge; v0.3 extends to all 6.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:575:    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:576:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:579:      applies_to_agents containing 'janitor' for tacit-note narrative
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:590:      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:595:      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:597:      for retraining queue). Janitor adds R for tacit-note harvest per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:718:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:804:      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:905:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:914:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1005:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1014:    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1020:      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1025:      they do not block v0.3 ratification but do require a Scribe agent.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1026:      consistency-pass before Scribe ratifies.
agents/_shared/escalation-codes.md:4:**Mandated by:** master brief §8.1 Change 3 — "Build the catalogue in Week 0. New codes only when production demands one."
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:35:- **Trigger:** Orange-tier action queued for tenant operator review
agents/_shared/escalation-codes.md:43:- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:61:- **Trigger:** `flock` acquisition failed within `OP_LOCK_TIMEOUT_S = 5` seconds (per `common-vault.json.lock_timeout_seconds`)
agents/_shared/escalation-codes.md:68:- **Trigger:** Postgres optimistic-concurrency UPDATE found 0 rows after `OP_RETRY_BACKOFF_MS = 100` retry (per `common-vault.json.retry_backoff_ms`); per vault-concurrency §3 retry policy
agents/_shared/escalation-codes.md:75:- **Trigger:** Obsidian debounce hit `MAX_RETRIES = 5` (file mtime still recent after 30s of waiting) per vault-concurrency §4 + `common-vault.json.obsidian_debounce_max_retries`
agents/_shared/escalation-codes.md:82:- **Trigger:** Rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite per vault-concurrency §5.4 v1.0 mitigation
agents/_shared/escalation-codes.md:89:- **Trigger:** Cascade exceeded `CASCADE_TIMEOUT_MS = 30_000` ms per vault-concurrency §5 + `common-vault.json.cascade_timeout_ms`
agents/_shared/escalation-codes.md:99:- **Trigger:** Bullhorn OAuth token refresh failed twice on the per-agent 8-minute cycle (per `common-ats.json.auth_refresh_interval_seconds`); or REST call returned 401 indefinitely (revoked token in Bullhorn admin UI)
agents/_shared/escalation-codes.md:110:- **Trigger:** Renderer exited non-zero. Mid-render atomic-rename per ADR-003 §3.3.4 means the prior agent dir at target is preserved (`.prev.<timestamp>/`) — no half-rendered state visible to daemon discovery
agents/_shared/escalation-codes.md:118:Source: master brief §8.1 Change 3 lines 585-592
agents/_shared/escalation-codes.md:122:- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
agents/_shared/escalation-codes.md:129:- **Trigger:** Dedup confidence `≥ 0.85` per Ultraplan §8.1 line 511 A2 Gate A; human-review-required cases
agents/_shared/escalation-codes.md:136:- **Trigger:** Supply Chain Auditor detected red flag (v1.0 placeholder; SCA agent in v1.1 backlog)
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:150:- **Trigger:** Agent output references PII outside the firm boundary (cross-tenant PII detected by `validate.sh` Gate A or RLS check)
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:165:- **Trigger:** Agent produced output violating vertical-schema.yaml field constraints (e.g. wrote an unknown enum value, missing required field). Detected at write-time by adapter validation
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:179:- **Trigger:** Agent rejected its input at the validation gate (e.g. malformed firm name, missing required CLI argument, brief description too short). Detected at Step 1 of the agent's workflow BEFORE any tool calls or LLM invocations
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:196:- **Trigger:** Manual editing lock held by founder; agent backs off and reschedules
agents/_shared/escalation-codes.md:203:- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
agents/_shared/escalation-codes.md:211:- **Trigger:** Rename operation raced with another writer; per vault-concurrency §5
agents/_shared/escalation-codes.md:218:- **Trigger:** Agent self-requested restart per primitive 6 (`cortextos-ifos bus self-restart`) — typically post-degraded-mode recovery, post-context-overflow handoff
agents/_shared/escalation-codes.md:225:- **Trigger:** Context approaching `ctx_handoff_threshold` (default 80%); agent saves state and triggers fresh-session takeover per primitive 1+2 context-rotation
agents/_shared/escalation-codes.md:232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
agents/_shared/escalation-codes.md:242:- **Trigger:** Reed jobs-board API OAuth token refresh failed twice OR REST call returned 401 indefinitely
agents/_shared/escalation-codes.md:250:- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
agents/_shared/escalation-codes.md:258:- **Trigger:** LinkedIn session cookie / OAuth token revoked or expired (LinkedIn has aggressive anti-bot session invalidation)
agents/_shared/escalation-codes.md:266:- **Trigger:** Google Workspace OAuth token refresh failed; Gmail send returns 401
agents/_shared/escalation-codes.md:274:- **Trigger:** Microsoft Graph OAuth refresh failed; Outlook sendMail returns 401
agents/_shared/escalation-codes.md:282:- **Trigger:** Xero (or alt accounting provider) OAuth token refresh failed; API returns 401
agents/_shared/escalation-codes.md:290:- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
agents/_shared/escalation-codes.md:298:- **Trigger:** Open Banking PSD2 consent approaching 90-day expiry. Three stages:
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:319:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
agents/_shared/escalation-codes.md:326:- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
agents/_shared/escalation-codes.md:333:- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
agents/_shared/escalation-codes.md:343:- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
agents/_shared/escalation-codes.md:350:- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
agents/_shared/escalation-codes.md:358:- **Trigger:** A send is about to fire when the underlying state has changed in a way that should suppress it. Two canonical use cases:
agents/_shared/escalation-codes.md:368:- **Trigger:** Yellow-tier action was sampled per `sample_rate` (1-in-N) for post-hoc human review; sampling is informational + drives ongoing quality monitoring
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:379:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
agents/_shared/escalation-codes.md:387:- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
agents/_shared/escalation-codes.md:395:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:402:- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
agents/_shared/escalation-codes.md:409:- **Trigger:** Outbound recipient resolution failed — addressee does not match the entity whose lifecycle/event triggered the send. Two canonical use cases:
agents/_shared/escalation-codes.md:411:  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
agents/_shared/escalation-codes.md:419:- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/escalation-codes.md:433:- **Trigger:** Concierge SLA breached. Three canonical sla_types:
agents/_shared/escalation-codes.md:436:  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
agents/_shared/escalation-codes.md:443:- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
agents/_shared/escalation-codes.md:450:- **Trigger:** Lifecycle state is ambiguous or outside the agent's known taxonomy. Two canonical use cases:
agents/_shared/escalation-codes.md:465:| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:61:      - Scribe (R — voice samples for note-summary tone matching)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:75:          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:128:      - Scribe (R — note format constraints)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:168:          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:191:      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:179:# a customer-visible artefact (Gate B per master brief §1 Rule 4).
docs/verticals/recruitment/vertical-schema.yaml:10:# Source: master brief §6 Day 6 line 490 (8 core entities)
docs/verticals/recruitment/vertical-schema.yaml:14:#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
docs/verticals/recruitment/vertical-schema.yaml:26:  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:54:      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:119:        source: IFOS-derived (Scribe extraction; GBP annual)
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:136:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.yaml:159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
docs/verticals/recruitment/vertical-schema.yaml:196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:216:      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:289:      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
docs/verticals/recruitment/vertical-schema.yaml:348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
docs/verticals/recruitment/vertical-schema.yaml:606:    v1_0_exercise: All 4 Bullhorn-touching v1.0 agents.
docs/verticals/recruitment/vertical-schema.yaml:692:  Scribe:
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:822:    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:829:    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:893:    target: Week-4-end (~2026-06-21 if Week 1 starts 2026-05-21 per Day-5 kill criterion §2 Trigger 1 calendar).
docs/verticals/recruitment/vertical-schema.yaml:896:    expected_date: post first-pilot operations (Q4 2026 if pilot lands per master brief §6 Day 7 question 1)
docs/verticals/recruitment/vertical-schema.yaml:901:    expected_date: 2027+ per master brief §9 build sequence
agents/_shared/voice-loader.sh:3:# IFOS voice-loader — implements the 3 hh_load_* helpers per master brief
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:130:5. Report result back. If row count > 3 in a 7-day window, kill-criterion Trigger 5 fires (per `v1.0-kill-criterion.md` §2 Trigger 5).
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:178:- `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 5 — red-tier breach kill criterion
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
agents/_shared/tests/test-hook-helpers.sh:283:printf '\n[16] Kill-criterion Trigger 5 verification: red-tier audit query shape\n'
agents/_shared/tests/test-hook-helpers.sh:288:  # Kill-criterion Trigger 5 monitoring query filters by payload.tier='red'
agents/_shared/tests/test-hook-helpers.sh:303:_test_run "kill-criterion Trigger 5: red-tier rows queryable by tier+phase" test_kill_criterion_trigger5
agents/recruitment/cash-conductor/README.md:18:Full bundle at W7-8 build (~2 weeks per ULTRAPLAN A4 line 541):
agents/recruitment/cash-conductor/README.md:22:- `validate.sh` — Gate A (invoice + amount + contact triple check + paid-in-24h block per ULTRAPLAN A4 line 539)
agents/recruitment/cash-conductor/README.md:27:- `fixtures/99-chase-paid-canary.yaml` — adversarial: chase proposed for invoice paid 12h ago — Gate A must reject (per ULTRAPLAN A4 line 539 verbatim)
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
docs/_archive-build-pack/06-BUILD-PLAN.md:227:- Trigger: when a tenant moves from PROVISIONING to ACTIVE, spawn its daemon
agents/recruitment/cash-conductor/agent.md:7:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:8:**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
agents/recruitment/cash-conductor/agent.md:9:**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
agents/recruitment/cash-conductor/agent.md:10:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:16:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:55:- **Webhook (v1.0 primary path):** per-provider HMAC / bearer token verified at the ingress per `tools.yaml` capability declarations (matching the Scribe webhook auth pattern).
agents/recruitment/cash-conductor/agent.md:57:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:89:| 4 | Fuzzy amount (±0.5% rounding) + matching payee name | 0.65 |
agents/recruitment/cash-conductor/agent.md:125:| Position | Trigger | Tone | Voice classifier minimum |
agents/recruitment/cash-conductor/agent.md:162:     gotcha per ULTRAPLAN A4 line 541); staged ESC_OPEN_BANKING_TOKEN_AGING:
agents/recruitment/cash-conductor/agent.md:303:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:319:Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
agents/recruitment/cash-conductor/agent.md:325:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:333:| Code | Trigger | Severity | Routing |
agents/recruitment/cash-conductor/agent.md:370:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:425:### Gotchas (carried forward from ULTRAPLAN A4 line 541)
agents/recruitment/cash-conductor/agent.md:430:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:447:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
docs/_archive-build-pack/02-PRODUCT-VISION.md:66:1. They upload the handbook, paste past replies, connect Fathom — material lands in the vault as markdown pages.
agents/recruitment/scribe/README.md:1:# Scribe — directory README
agents/recruitment/scribe/README.md:14:Full bundle at W6 build (~1 week per ULTRAPLAN A3 line 526):
agents/recruitment/scribe/README.md:16:- `tools.yaml` — Bullhorn W + Fathom R + Fireflies R + voice classifier
agents/recruitment/scribe/README.md:18:- `validate.sh` — Gate A (≥3 fields × confidence ≥0.6 + voice ≥0.75 + PII boundary)
agents/recruitment/scribe/README.md:29:*End of Scribe README.*
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:19:Already installed at `~/.claude/skills/graphify/SKILL.md`. Description: "any input (code, docs, papers, images) → knowledge graph → clustered communities → HTML + JSON + audit report". Trigger: `/graphify`.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:163:| Quarterly | "Survey v1 vs v2 customer split. If v2 has > 5 customers and v1 has < 3, draft the v1 sunset announcement" | Triggers v1 sunset timeline (see `08-OPEN-DECISIONS.md` §10) |
agents/recruitment/scribe/agent.md:1:# Scribe — the data spine
agents/recruitment/scribe/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
agents/recruitment/scribe/agent.md:7:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:8:**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
agents/recruitment/scribe/agent.md:9:**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
agents/recruitment/scribe/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/scribe/agent.md:17:> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:41:v1.0 supports Fathom (HMAC-SHA256 signed) and Fireflies (bearer token) providers; auth handled per-provider in `tools.yaml` capability declarations. Ringover (OAuth-protected) is deferred to v1.1+ — not in the v0 build dependencies and not registered in v1.0 `tools.yaml`.
agents/recruitment/scribe/agent.md:77:| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
agents/recruitment/scribe/agent.md:78:| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
agents/recruitment/scribe/agent.md:82:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
agents/recruitment/scribe/agent.md:113:Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
agents/recruitment/scribe/agent.md:129:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:134:     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
agents/recruitment/scribe/agent.md:163:     a Scribe run with no resolvable target cannot produce structured writes)
agents/recruitment/scribe/agent.md:170:   → discard fields confidence <0.6 (per Gate A)
agents/recruitment/scribe/agent.md:171:   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
agents/recruitment/scribe/agent.md:173:     "<N> fields ≥0.6 confidence")
agents/recruitment/scribe/agent.md:175:6. LLM tacit-note generation
agents/recruitment/scribe/agent.md:182:   → hh_decision_output("tacit_note_rendered", "<vault_path>",
agents/recruitment/scribe/agent.md:196:     in agents/_shared/autosend-policy.yaml line 113; agent:all; Scribe uses
agents/recruitment/scribe/agent.md:206:9. Bullhorn write — tacit-note attachment (yellow tier)
agents/recruitment/scribe/agent.md:215:   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
agents/recruitment/scribe/agent.md:218:     different scopes — master brief 10-min is the product UX promise; catalogue
agents/recruitment/scribe/agent.md:235:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:238:- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
agents/recruitment/scribe/agent.md:239:- 1 tacit-note generated with voice classifier ≥0.75
agents/recruitment/scribe/agent.md:242:- No PII outside firm boundary in tacit-note narrative
agents/recruitment/scribe/agent.md:247:**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/scribe/agent.md:251:Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
agents/recruitment/scribe/agent.md:257:Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
agents/recruitment/scribe/agent.md:265:Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/scribe/agent.md:267:| Code | Trigger | Severity | Routing |
agents/recruitment/scribe/agent.md:271:| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:273:| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:276:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:282:Scribe does NOT use:
agents/recruitment/scribe/agent.md:284:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
agents/recruitment/scribe/agent.md:290:Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/scribe/agent.md:295:  - No compensation specifics in tacit notes (those go to structured fields only)
agents/recruitment/scribe/agent.md:297:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:299:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/scribe/agent.md:305:Scribe build cannot start until ALL of the following are confirmed:
agents/recruitment/scribe/agent.md:315:| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
agents/recruitment/scribe/agent.md:316:| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
agents/recruitment/scribe/agent.md:317:| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
agents/recruitment/scribe/agent.md:333:**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
agents/recruitment/scribe/agent.md:339:| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
agents/recruitment/scribe/agent.md:342:| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
agents/recruitment/scribe/agent.md:345:| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
agents/recruitment/scribe/agent.md:347:### Gotchas (carried forward from ULTRAPLAN A3 line 527)
agents/recruitment/scribe/agent.md:350:2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
agents/recruitment/scribe/agent.md:351:3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.
agents/recruitment/scribe/agent.md:361:- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
agents/recruitment/scribe/agent.md:372:*End of Scribe agent.md draft.*
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:59:| 03 | Proposal Builder | Sales | On call-end | £24,200 engagement | Fathom, HubSpot, Notion |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:131:- Specific: "Drafts a proposal 4 minutes after the Fathom call ends."
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:203:- Fathom (Proposal Builder)
agents/recruitment/sourcing-scout/README.md:14:Full bundle at W9 build (~2 weeks per ULTRAPLAN A5 line 554):
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
docs/RISK-REGISTER.md:4:the top. Full risk list is in master brief §12 and Ultraplan §10.
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:50:Full risk register per master brief §12 / Ultraplan §10. Port the remaining
docs/RISK-REGISTER.md:60:- 2026-05-16 (Day 2) — Risk #2 status entry updated: Sub-decision C **Accepted** per `bullhorn-integration-path.md` §4 + §5; Sub-decisions A and B **Proposed** with named reduction triggers (Sunday/Monday commercial conversations). Two staged severity reductions specified (High → Medium on commercial answers; Medium → Low on first Week 3-4 Bullhorn write landing clean). Risk #7 edit count revised from 5 to 6 (Bullhorn decision §6.6 sixth edit added — master brief §6 Day 2 line 466 `service-account for dev` correction). No new risks surfaced from Day 2 — Sub-decisions A and B Proposed is the intended honest state pending commercial verification, not a new risk surface.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:63:- 2026-05-17 (Day 4) — **Day 4 provisioning executed end-to-end against Hetzner Cloud NBG1 VPS (178.105.87.24).** All 9 runbook sections complete; §7 RLS isolation gate passed all 5 conditions (cross-tenant data access structurally impossible for `ifos_app` regardless of application bugs); 22 of 22 §9 automated checks passed. **Risk #7 edit count revised from 8 to 9** with new Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations"). **One new risk added (#8 LUKS manual unlock single-point-of-failure)** — Low probability, Medium-High impact, v1.2+ TPM/key-server mitigation path named. Two non-blocking operational items deferred to founder convenience: (a) Hetzner Console snapshot of `ifos-v2-prod-01`; (b) ifos_app password retrieval from `/vault/.ifos_app_password.tmp` → 1Password → temp file delete; (c) **high-priority** LUKS new-passphrase retrieval from `/root/.new_luks_passphrase.tmp` → 1Password → temp file delete (must be done before next reboot — old leaked passphrase already invalidated by Day-4 §11 rotation). Path B protocol gap (LUKS passphrase entered chat for `ifos-unlock` end-to-end test) closed via `cryptsetup luksChangeKey` rotation: OLD (leaked) rejected by `--test-passphrase`, NEW accepted; leaked passphrase in chat transcript is cryptographically invalid. v1.1 runbook revisions catalogued (8 items) for collection during Days 5-7. Codex Day-7 queue grows from 13 to 15 (Day 4 runbook + executed version).
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
agents/recruitment/sourcing-scout/agent.md:11:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:12:**Build complexity:** L (2 weeks) per ULTRAPLAN A5 line 554.
agents/recruitment/sourcing-scout/agent.md:13:**Tier:** Tier 2 (request-response; daytime form) per ULTRAPLAN A5 line 546. Night Sourcer (v1.1) is the Tier-1 counterpart using cortextOS primitive #6.
agents/recruitment/sourcing-scout/agent.md:19:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/sourcing-scout/agent.md:21:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:109:11 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/sourcing-scout/agent.md:252:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:271:Per ULTRAPLAN A5 line 553 verbatim: **"≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)"**.
agents/recruitment/sourcing-scout/agent.md:277:Shared target with Night Sourcer (v1.1) means: both agents are measured against the same 6-of-10 bar, and the source-abstraction layer (per gotcha of ULTRAPLAN A5 line 555) ensures rank+rationale logic is shared not duplicated.
agents/recruitment/sourcing-scout/agent.md:285:| Code | Trigger | Severity | Routing |
agents/recruitment/sourcing-scout/agent.md:320:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/sourcing-scout/agent.md:366:| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 552 says "≥ 50 words" — using as floor. |
agents/recruitment/sourcing-scout/agent.md:371:### Gotchas (carried forward from ULTRAPLAN A5 line 555)
agents/recruitment/sourcing-scout/agent.md:374:2. **Reed/CV-Library have separate auth and separate result schemas.** Source-abstraction layer is the load-bearing design (per ULTRAPLAN A5 line 555); Night Sourcer v1.1 will reuse it.
agents/recruitment/sourcing-scout/agent.md:375:3. **Build the source-abstraction layer carefully.** This is the integration test of "schema before code" (master brief §1 Rule 2) — per-source mapping config, not per-source code branches.
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:20:    --ink-3: oklch(0.60 0.010 80);   /* tertiary / meta */
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:27:    --ok:        oklch(0.60 0.10 150);
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:29:    --warn:      oklch(0.65 0.10 80);
agents/recruitment/janitor/README.md:9:| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed |
agents/recruitment/janitor/README.md:14:Full agent bundle per ADR-003: 6 files + 3 fixtures. Built at W5 start (~2 weeks per ULTRAPLAN A2 line 512):
agents/recruitment/janitor/agent.md:7:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:8:**Build complexity:** L (2 weeks) per ULTRAPLAN A2 line 512.
agents/recruitment/janitor/agent.md:9:**Tier:** Tier 2 (scheduled nightly cron; not persistent PTY) per ULTRAPLAN A2 line 504 + sequencing-target.md §2.1.
agents/recruitment/janitor/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/janitor/agent.md:17:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:62:| 6 | **Gate-B metric** | TWO independent thresholds per ULTRAPLAN A2 line 511 verbatim: dedup improvement ≥15% AND field-completeness improvement ≥10%. Both must pass. NOT a composite score — that would let one threshold cover for the other. |
agents/recruitment/janitor/agent.md:70:1. **Candidate merge** (`PUT /Candidate/{primary_id}` + cascade) — only when confidence ≥0.85 per Gate A; no merge if either candidate had Bullhorn activity in last 90 days without explicit review flag (per ULTRAPLAN A2 line 510 verbatim). Action type: **`bullhorn_candidate_dedupe`** (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW action_types; yellow tier; sample_rate: 10).
agents/recruitment/janitor/agent.md:80:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:85:     (used for tacit-note attribution) + recent edits (for note harvest)
agents/recruitment/janitor/agent.md:107:     (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:146:   → hh_decision_output("janitor_tacit_note_harvest", "tenant:<slug>",
agents/recruitment/janitor/agent.md:185:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:188:- Every proposed merge has confidence ≥ 0.85 per ULTRAPLAN A2 line 510
agents/recruitment/janitor/agent.md:189:- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:193:- No PII outside firm boundary in tacit-note narratives (regex pass)
agents/recruitment/janitor/agent.md:205:Per ULTRAPLAN A2 line 511 verbatim: **"day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement"**.
agents/recruitment/janitor/agent.md:209:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:219:| Code | Trigger | Severity | Routing |
agents/recruitment/janitor/agent.md:225:| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/janitor/agent.md:242:Step 8 (tacit-note narrative generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/janitor/agent.md:249:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:251:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:263:| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action; Trigger 1 fires 2026-06-03 if no LOI |
agents/recruitment/janitor/agent.md:277:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/janitor/agent.md:289:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:296:### Gotchas (carried forward from ULTRAPLAN A2 line 513)
agents/recruitment/janitor/agent.md:298:1. **Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0.** Estimate 1 week for the MCP server, 1 week for the agent itself (per ULTRAPLAN A2 line 513).
agents/recruitment/janitor/agent.md:300:3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:247:| # | Question | Trigger to resolve |
docs/architecture/architecture-cohesion-review.md:5:**Method:** Read all 4 ADRs + 4 reference designs end-to-end as a coherent set. Walk each of the 4 boundaries from master brief §3 with adversarial questions. Identify gaps, contradictions, implicit assumptions.
docs/architecture/architecture-cohesion-review.md:34:| **Helpers + storage** | vault-concurrency.md (locks + version), v0.1 schema, v0.2 supplement, kill-criterion.md (Trigger 5 audit) |
docs/architecture/architecture-cohesion-review.md:58:| ADR-001 | bus mechanism (chokidar→FastChecker) | master brief §2.4 row 3 (Edit) | ✓ landed atomic `0e5b2b4` |
docs/architecture/architecture-cohesion-review.md:114:- **master brief §3.1 boundary 1** read-only submodule
docs/architecture/architecture-cohesion-review.md:162:## §7 — Per-boundary adversarial walk (master brief §3 boundaries)
docs/architecture/architecture-cohesion-review.md:225:| # | Issue | Severity | Resolution path | Owner | Trigger |
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
agents/recruitment/diagnostic/README.md:9:| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed (Day-11 draft) |
agents/recruitment/diagnostic/README.md:14:Per master brief §3.1 boundary 1 + ADR-003 (agent bundle v2 pattern), a full agent bundle is 6 files + 3 fixtures:
docs/architecture/agent-bundle-renderer-design.md:6:**Prior work referenced:** master brief §8 (bundle spec); `docs/architecture/second-brain-design.md` §1.7 (R2 inheritance recommendation); `docs/architecture/cortexos-primitive-status.md` Primitive 1 (PTY/PM2 spawn mechanism).
docs/architecture/agent-bundle-renderer-design.md:43:| `agent.md` (line 552) | Output contract first; then workflow, gates, escalation. Master brief §1 Rule 1: "Every agent ships with its output contract written first, as a one-paragraph screenshot description." | the renderer (synthesises into `CLAUDE.md` per §2.1); humans for code review | **Static** — founder writes once; iterated per Codex ratification (master brief §10.5 names every new `agent.md` as always-ratify) |
docs/architecture/agent-bundle-renderer-design.md:45:| `tools.yaml` (line 554) | MCP servers + scopes + degraded modes for external execution backends (Bullhorn, Companies House, Microsoft Graph etc. per master brief §3.2 first-party MCP list) | the renderer (passes through to rendered agent dir); agent uses it via Claude Code's MCP loading at PTY spawn time | **Static** — founder writes once per agent |
docs/architecture/agent-bundle-renderer-design.md:46:| `validate.sh` (line 555) | Gate A check per master brief §1 Rule 4. Sources `_shared/hook-helpers.sh` (master brief §8.1 Change 2). Hard-fails on missing `hh_decision_*` calls. | invoked by the agent itself during a run (per master brief §8.1 wording "validate.sh hard-fails on missing calls"); rendered to a path the agent can invoke | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:48:| `tests/fixtures/01-primary/` (line 559) | Happy-path input.json + expected.md. The demo example. | CI fixture runner (master brief §8.3 line 628 "Test against fixtures"); not read at runtime | **Static** — author once, regenerate `expected.md` after intentional behaviour changes |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:54:- **§1.1-A:** master brief §8.1 names `validate.sh` and `context.sh` at the bundle root but does not specify the **invocation mechanism** — i.e. how does the agent invoke them from within its Claude Code session? Claude Code's hooks convention is `.claude/hooks/*.sh`; cortextOS templates don't use that path (they use `.claude/skills/` for skill scripts but not `.claude/hooks/` for lifecycle hooks). Recommended resolution in §2.1: render the two scripts to `.claude/hooks/` so they integrate with Claude Code's hook discovery; CLAUDE.md preamble (synthesised from agent.md per §2.1) references them by name.
docs/architecture/agent-bundle-renderer-design.md:55:- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.
docs/architecture/agent-bundle-renderer-design.md:97:The two layouts share no files by name except `tools.yaml` (which the IFOS bundle uses for MCP servers and which Claude Code consumes at PTY spawn). cortextOS expects `config.json` (runtime config), `CLAUDE.md` (Claude Code's entry point), `.env` (Telegram credentials + secrets); IFOS provides `config.schema.json` (a *schema* for per-tenant config, not the materialised config itself), `agent.md` (the output contract + workflow, not a Claude Code entry point), and no `.env` (credentials live per-tenant). The bundle's `validate.sh` and `context.sh` have no cortextOS analogue — they implement IFOS-side Gate A and context-assembly per master brief §8.1 Changes 1+2, and need a defined invocation mechanism (Spec gap §1.1-A). The bundle's `tests/fixtures/` are CI-only and have no runtime counterpart in cortextOS. **Translation is required for three of the six bundle files** (`agent.md` → `CLAUDE.md` with cortextOS-required preamble synthesised in; `config.schema.json` → `config.json` materialised with per-tenant values from `/vault/{tenant}/_config.yaml`; `validate.sh` + `context.sh` → rendered into a hook location the agent can invoke). `README.md` and `tools.yaml` pass through. Fixtures stay in the source repo.
docs/architecture/agent-bundle-renderer-design.md:115:| `agents/recruitment/<name>/tests/fixtures/{01-primary,02-edge-case-*,99-voice-drift-canary}/` | **Not rendered** | **Stays in source** | n/a | n/a — fixtures live in the IFOS repo at `agents/recruitment/<name>/tests/fixtures/`; CI fixture runner (master brief §8.3 line 628) reads them there; runtime does not need them |
docs/architecture/agent-bundle-renderer-design.md:118:| _(no IFOS source — cortextOS templates ship these)_ | `IDENTITY.md`, `SOUL.md`, `GUARDRAILS.md`, `GOALS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `AGENTS.md`, `memory/`, `experiments/` | **Drop** | n/a | n/a — IFOS's `agent.md` replaces the combined role of cortextOS's CLAUDE.md + IDENTITY + SOUL + GOALS + HEARTBEAT + TOOLS (the renderer's CLAUDE.md preamble must NOT instruct the agent to read any of these because they will not exist). MEMORY.md / memory/ are replaced by Postgres `decision_log` per master brief §8.1 Change 2 + design §2.4.2. GUARDRAILS.md is replaced by `validate.sh` hard-fail checks + `tools.yaml` approval categories per master brief §8.1 Change 2-3. USER.md / SYSTEM.md context is provided per tenant via `context.sh` calling the context-assembly API per master brief §9. experiments/ is dropped — analyst-only theta-wave isn't an IFOS-agent concern in v1.0-v1.1 per design §2.3 row "semantic-search-over-raw" |
docs/architecture/agent-bundle-renderer-design.md:123:- **§2.1-A:** master brief §8.1 does not specify what the **cortextOS preamble template** looks like — the wrapper around `agent.md` that becomes `CLAUDE.md`. Recommended resolution: pin a canonical preamble at `packages/agent-renderer/templates/claude-md-preamble.md` (rendered with tenant + agent variables); preamble content must (a) tell Claude Code to source `.claude/hooks/context.sh` at session start, (b) tell Claude Code to call `.claude/hooks/validate.sh` before any tool invocation (Gate A), (c) list the env vars the agent should expect (`CTX_TENANT_SLUG`, `CTX_AGENT_NAME`, `CTX_ORCHESTRATOR_AGENT`, etc.), (d) reference `agent.md` body verbatim, (e) **not** reference IDENTITY.md / SOUL.md / MEMORY.md / GOALS.md / etc. because they will not exist. A draft preamble lives in §2.3 worked example below.
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:142:| `memory` | Heartbeat-ingests `MEMORY.md` + daily memory files into the `memory-{agent}` ChromaDB collection (analyst/AGENTS.md:296-300) | IFOS uses Postgres `decision_log` rows written via `hh_decision_trigger` / `hh_decision_output` / `hh_decision_action` per master brief §8.1 Change 2. No `MEMORY.md`, no daily memory file, no auto-ingest |
docs/architecture/agent-bundle-renderer-design.md:143:| `approvals` | cortextOS's per-action approval-gate skill — agent creates an approval entry, blocks until human resolves via Telegram inline buttons | IFOS uses the same primitive 4 approval gates (cortextOS primitive — `src/bus/approval.ts`), but the approval *categories* and *escalation routing* are declared in `tools.yaml` + `agent.md` per master brief §3.2, not via inherited skill documentation |
docs/architecture/agent-bundle-renderer-design.md:153:**Spec gap §2.2-A:** master brief §8.1 doesn't specify the opt-in syntax in `tools.yaml`. Recommended resolution: add a top-level `cortextos_skills:` block in `tools.yaml` with a list of skill names. Example:
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:326:# Hydrate via context-assembly API per master brief §9
docs/architecture/agent-bundle-renderer-design.md:367:A non-zero exit from validate.sh blocks the action (Gate A; master brief §1 Rule 4).
docs/architecture/agent-bundle-renderer-design.md:369:Decision-log calls are mandatory per master brief §8.1 Change 2:
docs/architecture/agent-bundle-renderer-design.md:465:Rationale: matches existing IFOS package convention. Master brief §4.1 line 195-204 enumerates the operative package directories (`packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}/`); the renderer is a distinct concern (bundle → runtime translation) that doesn't belong inside any of those. It's not the brain (wiki content, per ADR-002), not the harness (read-only submodule per master brief §3.1), not agents-runtime/_shared/ (the shared helper *content*, not the *tooling* that materialises agents). Standalone `packages/agent-renderer/` keeps the surface clean.
docs/architecture/agent-bundle-renderer-design.md:477:- Brand new top-level dir — rejected for cohesion with master brief §4.1's existing `packages/` convention.
docs/architecture/agent-bundle-renderer-design.md:493:- **Daemon auto-renders on bundle change (filesystem watcher inside cortextOS daemon):** rejected because cortextOS daemon is read-only on the submodule (master brief §3.1), and adding render logic to the daemon would couple bundle synthesis to runtime supervision. Two concerns, one process — wrong.
docs/architecture/agent-bundle-renderer-design.md:503:(CLI name per ADR-004 Decision 1; earlier drafts of this design named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1. The corrected standalone `ifos-render-agent` Node binary ships from `packages/agent-renderer/package.json` `bin`.)
docs/architecture/agent-bundle-renderer-design.md:597:- **Merge with conflict markers:** rejected for v1.0. Renderer doesn't have a three-way-merge semantic (source bundle, last-render, current rendered output). Building it adds substantial complexity for a workflow nobody asked for; the master brief §1 Rule 1 ("output before architecture") favours the simple overwrite model.
docs/architecture/agent-bundle-renderer-design.md:622:The v1.0 minimum keeps the renderer's CLI surface small (one mode, two required args) and defers cross-tenant orchestration to bash. The Postgres `tenants` table dependency (v1.0 Day 4 per master brief §6) is what unblocks `--all-tenants`; until then there's no programmatic source of truth for "the list of active tenants."
docs/architecture/agent-bundle-renderer-design.md:636:**Recovery:** stderr lists the failed validation path (e.g. `properties.nurture_cadence.post_interview_chase_hours: expected integer, got string`). Founder edits `/vault/<tenant>/_config.yaml` or the `config.schema.json` source (rare; schema edits go through Codex ratification per master brief §10.5). Re-runs render.
docs/architecture/agent-bundle-renderer-design.md:702:New escalation code added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3:
docs/architecture/agent-bundle-renderer-design.md:764:| Postgres `decision_log` table live (per master brief §6 Day 4) | founder | Day 4 of Week 0 (already scheduled) |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:775:**Current** (master brief §4.1 line 195-204): "Create the operative directory structure" followed by an `mkdir -p` command listing `packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}`.
docs/architecture/agent-bundle-renderer-design.md:787:**Current** (master brief §8.3 lines 614-630): the `bash` block showing the bundle authoring workflow ends with: "Test against fixtures; iterate; commit; PR; merge."
docs/architecture/agent-bundle-renderer-design.md:802:**Current** (master brief §8 lines 545-568): bundle file list with no reference to renderer.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:9:# Per kill-criterion §2 Trigger 5 + agent.md §6: voice drift is an
docs/architecture/cortexos-kb-surface-investigation.md:12:Day-1 audit of cortextOS Primitive 3 (`docs/architecture/cortexos-primitive-status.md`) surfaced that master brief §3.4 names four shadow files (`kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`) that **do not exist** at the verified SHA. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`.
docs/architecture/cortexos-kb-surface-investigation.md:14:Drafting ADR-002 began with the plan to read all four real files and pick one of three outcomes (full shadow / mixed shadow + new wrappers / abandon shadow). After reading **only `kb-setup.sh`**, the substrate of cortextOS's KB became clear, and that substrate is incompatible with the IFOS wiki data model in master brief §5. The ADR's scope is too narrow to absorb that finding — it would be designing the second brain inside an architectural decision record, on the side of an audit.
docs/architecture/cortexos-kb-surface-investigation.md:35:- **Per-instance isolation:** the KB root path includes `$CTX_INSTANCE_ID`, so IFOS's `ifos-v2` install and the personal install at `default` have **separate** KB indexes by construction. This is already correct against the master brief §3.1 submodule boundary.
docs/architecture/cortexos-kb-surface-investigation.md:83:**cortextOS's KB is a chunked-vector RAG store; the IFOS wiki in master brief §5 is an entity-document store. These data models do not compose without an adapter layer, and the adapter layer is large enough to be a design decision rather than a shadow-wrapper detail.**
docs/architecture/cortexos-kb-surface-investigation.md:88:- **IFOS wiki unit of storage:** one markdown file per entity (Candidate, Client, Brief, Placement…) with structured YAML frontmatter (`id / entity_type / tenant_id / created_at / updated_at / provenance / importance_score / linked_entities`) and `[[wiki-link]]` references in body — per master brief §5.2 example at lines 357-369. The natural read pattern is "give me the canonical page for this entity, plus its backlinks".
docs/architecture/cortexos-kb-surface-investigation.md:97:  - **Indexing of ingested raw email/transcript chunks** (master brief §5.1 `raw/` directory tree). The chunked-vector model fits the "raw inbox-emails / calls / briefs" surface well; it only stops fitting at the `compiled/` entity-document boundary.
docs/architecture/cortexos-kb-surface-investigation.md:98:- **What this means for §3.4:** the master brief calls the seam between cortextOS and IFOS "the four `bus/kb-*.sh` shadow points." That framing assumed the same data model on both sides of the seam. With the substrate now known, the seam is not a four-file shadow but a much smaller boundary — to be defined in the second-brain design.
agents/recruitment/diagnostic/context.sh:10:# the first workflow step runs. Per master brief §8.1 Change 1: load voice
docs/architecture/second-brain-design.md:14:The goal: confirm what cortextOS uses its own KB for, so we know what we are deliberately leaving alone — and verify the master brief §3.1 submodule boundary is not in tension with the plan in Q3.
docs/architecture/second-brain-design.md:52:**IFOS agents do not run cortextOS's heartbeat-memory pattern.** The IFOS Agent Bundle v2 (master brief §8.1) specifies six files per agent:
docs/architecture/second-brain-design.md:64:None of these are `MEMORY.md`. None is a "daily memory file." The IFOS pattern uses Postgres `decision_log` rows (`hh_decision_trigger / output / action` per master brief §8.1 Change 2) for the equivalent of "what did this agent do" persistence, and the per-tenant vault (master brief §5.1) for narrative content.
docs/architecture/second-brain-design.md:76:- This respects master brief §3.1 ("never edit `packages/harness/cortextos/*` except the four `bus/kb-*.sh` shadow points") without exercising the exception — we don't shadow them at all.
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:136:1. **It honours the §3.1 boundary cleanly.** The §3.1 exception in master brief is "the four `bus/kb-*.sh` shadow points." If we don't shadow them (per §1.5), inheriting skills that call them invites confusion — the inherited skills point at cortextOS's KB, and we'd need to remember that IFOS-owned agents must not invoke them. R2 removes the question entirely.
docs/architecture/second-brain-design.md:140:**Until the renderer is built** (Week 0 has no agent code per master brief §6 Day 7; the renderer is a Week 1+ concern), the inherited-skills risk only matters for any debug/probe agents scaffolded via `cortextos-ifos add-agent` during Week 0 verification. Those probe agents will inherit the kb-* calls and write to cortextOS's KB — which is fine, because cortextOS's KB stays in place per §1.5.
docs/architecture/second-brain-design.md:161:/vault/{tenant-slug}/                               ← path per master brief §3.3 line 217, Ultraplan §5.1 line 217
docs/architecture/second-brain-design.md:163:│   ├── style-guide.md                              ← master brief §5.5 footnote, Ultraplan §5.2 wizard Day 3
docs/architecture/second-brain-design.md:169:├── wiki/                                           ← the second brain (master brief §5.1 line 306)
docs/architecture/second-brain-design.md:170:│   ├── raw/                                        ← append-only ingestion (master brief §5.1 lines 316-321)
docs/architecture/second-brain-design.md:171:│   │   ├── inbox-emails/                           ← from email ingestion (master brief §5.1 line 317)
docs/architecture/second-brain-design.md:172:│   │   ├── calls/                                  ← Fathom/Fireflies transcripts (master brief §5.1 line 318)
docs/architecture/second-brain-design.md:173:│   │   ├── briefs/                                 ← inbound brief detection (master brief §5.1 line 319)
docs/architecture/second-brain-design.md:174:│   │   ├── notes/                                  ← freeform consultant notes (master brief §5.1 line 320)
docs/architecture/second-brain-design.md:175:│   │   └── ats-snapshots/                          ← Bullhorn entity snapshots (master brief §5.1 line 321)
docs/architecture/second-brain-design.md:176:│   ├── compiled/                                   ← LLM-owned, agent-managed (master brief §5.1 line 323)
docs/architecture/second-brain-design.md:177:│   │   ├── index.md                                ← master index, one-line per page (master brief §5.1 line 324)
docs/architecture/second-brain-design.md:178:│   │   ├── candidates/                             ← one .md per Candidate (master brief §5.1 line 325)
docs/architecture/second-brain-design.md:179:│   │   ├── clients/                                ← one .md per Client (master brief §5.1 line 326)
docs/architecture/second-brain-design.md:180:│   │   ├── briefs/                                 ← one .md per Brief (master brief §5.1 line 327)
docs/architecture/second-brain-design.md:181:│   │   ├── placements/                             ← one .md per Placement (master brief §5.1 line 328)
docs/architecture/second-brain-design.md:182:│   │   ├── people/                                 ← Contacts at clients (master brief §5.1 line 329)
docs/architecture/second-brain-design.md:183:│   │   ├── concepts/                               ← firm domain concepts (master brief §5.1 line 330) — v1.2+ deferred
docs/architecture/second-brain-design.md:185:│   │   └── archive/                                ← absorbed/deleted pages (master brief §5.1 line 332)
docs/architecture/second-brain-design.md:186:│   └── .wiki/                                      ← compilation state (master brief §5.1 line 334)
docs/architecture/second-brain-design.md:187:│       ├── manifest.json                           ← per-raw-file compilation status (master brief §5.1 line 335)
docs/architecture/second-brain-design.md:188:│       ├── reflect-state.json                      ← reflect cycle state (master brief §5.1 line 336)
docs/architecture/second-brain-design.md:189:│       └── graph.json                              ← cached graph for fast UI loads (master brief §5.1 line 337) — v1.2 graph view
docs/architecture/second-brain-design.md:204:| `wiki/raw/calls/` | one file per call | markdown with frontmatter | `{epoch}-{call-id}.md` | Scribe (v1.0) on Fathom/Fireflies webhook | Brief Decoder (v1.1), Concierge (v1.0) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:227:Eight canonical entities exist per master brief §6 Day 6 / Ultraplan §11 Day 6 line 490:
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:246:**Frontmatter schema** (master brief §5.2 lines 357-369 starting example; extended for v1.0 completeness):
docs/architecture/second-brain-design.md:274:{Janitor or Scribe one-paragraph summary, regenerated on each ingest}
docs/architecture/second-brain-design.md:277:{auto-appended by Concierge / Scribe — chronological, agent-attributed}
docs/architecture/second-brain-design.md:394:**Decision: adopt `[[Entity-Type: Display Name]]` verbatim** as master brief specifies. Rationale: matches master brief decision, Obsidian-compatible, human-readable in raw markdown. Cost: rename safety is fragile — renaming "Sarah Bowen" to "Sarah Bowen-Smith" breaks all links unless an explicit rewrite step runs.
docs/architecture/second-brain-design.md:398:**Spec gap 2.2-A:** master brief §5 does not specify the rewrite-backlinks mechanism. Recommended resolution: implement as part of `update-entity` in `packages/brain/wiki/lib/update.ts` v1.0.
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:433:| `entity-history` | any agent v1.1: "what changed about this Candidate over time" | v1.1 (read) — but **writes are v1.0** | `(id: str, tenant_id: str)` | `List[DecisionLogEntry]` | few seconds | Sources from Postgres `decision_log` table (Ultraplan §5.1 line 227), NOT a separate history file. v1.0 agents write decision_log rows via `hh_decision_*` (master brief §8.1 Change 2); the read API is v1.1 |
docs/architecture/second-brain-design.md:437:- Graph multi-hop traversal — v1.2 graph view (master brief §5.5 line 423)
docs/architecture/second-brain-design.md:438:- Wiki health reflect (orphan detection, contradiction detection) — v1.1 (master brief §5.2 lines 371)
docs/architecture/second-brain-design.md:439:- Per-firm LoRA query — v2.0 (master brief §5.5 line 424)
docs/architecture/second-brain-design.md:456:- **Obsidian compatibility:** frontmatter restricted to YAML 1.2 features Obsidian's `gray-matter` parser accepts — strings, ints, floats, ISO 8601 strings, flow-style and block-style sequences, flow-style and block-style mappings (one level of nesting only). **No anchors, no aliases, no merge keys, no custom tags.** Wiki-links in body use Obsidian's `[[Display Name]]` and `[[Type: Display Name]]` syntax — both render. Frontmatter `linked_entities` is a list of strings that *look like* wiki-links; Obsidian doesn't render frontmatter strings as links by default, but the master brief §5.2 example uses this form and we adopt it.
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:465:**Table: `tenants`** (master brief §3.3 + Ultraplan §5.1)
docs/architecture/second-brain-design.md:540:**Table: `decision_log`** (master brief §8.1 Change 2 lines 170-173; Ultraplan §5.1 line 227)
docs/architecture/second-brain-design.md:569:**Spec gap 2.4-B:** Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`". This design splits them into `entities` + `entity_links` for clearer indexing semantics. **Recommended resolution:** adopt the split; update master brief §3.3 or Ultraplan §5.1 to reflect the two-table model. Codex-ratifiable on Day 7 by reading this section.
docs/architecture/second-brain-design.md:672:| `search-by-name` | Postgres `entities` trigram on `display_name` (`gin_trgm_ops`) | Filesystem grep over `wiki/compiled/{type}/*.md` frontmatter | Hot path; sub-second target. Fuzzy match returns top-N by similarity score; tie-break by `importance_score DESC` then `updated_at DESC`. Fallback only fires if Postgres unhealthy (per master brief §3.5 RLS / Ultraplan §3.5 degraded-mode contingency). |
docs/architecture/second-brain-design.md:701:- If the file lock times out (5 seconds), the operation fails with `ESC_VAULT_LOCK_TIMEOUT` per master brief §8.1 Change 3 vocabulary (new code; goes in `_shared/escalation-codes.md` v0.1).
docs/architecture/second-brain-design.md:727:**Spec gap 2.6:** none of this is in the master brief. **Recommended resolution:** adopt the mechanism above verbatim; document in a `docs/architecture/vault-concurrency.md` companion file in Week 1 (before agent code starts). **Blocks v1.0 build:** no — concurrency code is a v1.0 build artefact, not a Week 0 prerequisite, but the design needs to land before the first multi-agent test in week 5.
docs/architecture/second-brain-design.md:747:**Why not atomic across all files:** filesystems aren't transactional across files. Atomic-by-emulation (write all to `.tmp` then rename all) is brittle and doesn't compose with `flock`. Eventually-consistent with Postgres-as-truth is the realistic choice and matches master brief §3.3's "Postgres is the source of truth for state and provenance."
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:757:- `append-to-narrative` — Concierge / Scribe logging; tolerates few-hundred-ms.
docs/architecture/second-brain-design.md:772:| Scribe | 3:1 | reads candidate for context on every call; writes structured fields + tacit notes |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:836:Concurrency mechanisms from §2.6 (`flock`, optimistic concurrency, debounce, escalation codes) live in `wiki/lib/concurrency.ts`. Each operation's CLI handler calls into the library, which handles the locking + Postgres + audit logging. Escalation codes flow via existing cortextOS escalation router pattern (write to inbox as system message). Every wrapper writes `hh_decision_trigger` / `hh_decision_output` rows per master brief §8.1 Change 2.
docs/architecture/second-brain-design.md:889:| **Audit-loggability** — every read/write reaches `decision_log` + Codex review (master brief §8.1 + §10.5) | Each wrapper's CLI handler calls `hh_decision_trigger` / `hh_decision_output` directly before returning. Same pattern as cortextOS's 47 bus wrappers (e.g. `bus/send-message.sh` writes via `bus/message.ts`). One audit-log call site per op. | Server-internal request logger writes one row per tool invocation. Centralised — one log site for all 12 ops. But the log site lives in a separate process; correlation with the agent's `agent_run_id` requires passing it on every tool call. | Library writes audit row when called. Same library code as α/β, just invoked from a skill-instigated `node -e` or wrapper. Audit-log correctness depends on the skill documentation reminding the agent to pass `agent_run_id` — fragile. |
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/architecture/second-brain-design.md:892:| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
docs/architecture/second-brain-design.md:893:| **Consistency with cortextOS bus convention** | Identical pattern: 47 existing bus wrappers under `packages/harness/cortextos/bus/` all do `exec node dist/cli.js bus <command>`. Option α uses the same 3-line shim shape. Zero cognitive tax for an engineer who already understands cortextOS. | New surface (MCP). Aligns with the vertical-adapter pattern (master brief §3.2) where Bullhorn / Companies House etc. are MCP servers — so consistent with that pattern, not with the bus pattern. | Aligns with cortextOS's skill convention (each template ships `.claude/skills/` with kb / memory / tasks / heartbeat / etc.). Inconsistent with the bus pattern; consistent with the skill pattern; awkward under R2. |
docs/architecture/second-brain-design.md:896:| **Lock-in cost** — how hard to switch to a different option later | Low. Wrappers are 3-line shims; replace with calls to a different backend (MCP server, library) by changing the `exec` line. Library is reusable. Agents see the same `cortextos-ifos bus wiki-search` invocation regardless of backend — interface stable. | Medium. Agents have MCP `tools.yaml` entries committed; migration to α means rewriting `agent.md` and `tools.yaml` for every agent (18 in full strength per master brief §0). Library is reusable. | High. Skill-installation path is per-agent; migration requires per-agent skill removal + new wrapper/MCP declaration. Also under R2 the original installation path was a hack, which makes "switch away from γ" the cleanup of that hack. |
docs/architecture/second-brain-design.md:904:**Rationale anchored to three master brief sections:**
docs/architecture/second-brain-design.md:920:- **v1.2 graph view (master brief §5.5):** add `wiki-graph-traverse.sh` and a `graphify` subcommand. Surface grows by N scripts, not by architecture.
docs/architecture/second-brain-design.md:921:- **v2.0 LoRA scale (master brief §5.5):** the LoRA pipeline operates on the `decision_log` table, not on the wiki. Wiki ops from LoRA-enhanced agents are unchanged. Both options work.
docs/architecture/second-brain-design.md:924:**v1.0 build day estimate for Option α: 11-13 days.** Fits master brief §5.5's weeks 11-13 allocation. Detail in §3.4 below.
docs/architecture/second-brain-design.md:926:### 3.4 — Impact on master brief §5.5 build sequence
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:952:5. **`agents/_shared/hook-helpers.sh`** with `hh_decision_*` functions per master brief §8.1 Change 2. The wiki library calls these. **Week 1-2.**
docs/architecture/second-brain-design.md:956:- **Scope:** larger than master brief §5.5 currently states (9 ops + 4 Postgres tables + concurrency machinery, vs. the original "2 ts files"). Still fits the 11-13 day budget because the bulk of the surface area is small Postgres operations with thin shell wrappers; the heavy code is in `concurrency.ts` and `update.ts` which together are ~400-600 lines.
docs/architecture/second-brain-design.md:958:- **Earlier work needed:** Postgres schema and the entity_graph→entities+entity_links rename move to Week 0 Day 4 (this week, already planned per master brief §6).
docs/architecture/second-brain-design.md:967:| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
docs/architecture/second-brain-design.md:969:| **2.1-C** | `wiki/compiled/playbooks/` (master brief §5.1 line 331) collides with `/vault/{tenant}/_playbooks/` (Ultraplan §5.1) | Same folder name at two paths with different intended uses | **Recommendation:** drop `wiki/compiled/playbooks/`. Playbooks live at `/vault/{tenant}/_playbooks/` only. Update master brief §5.1 to remove the `playbooks/` line from the `wiki/compiled/` tree. | No |
docs/architecture/second-brain-design.md:973:| **2.4-B** | Ultraplan §5.1 line 227 groups entity index + adjacency under "`entity_graph`" | Single-table model insufficient for the JSONB GIN + trigram + adjacency mix v1.0 needs | Split into `entities` + `entity_links` per §2.4.2. Update master brief §3.3 / Ultraplan §5.1 wording. **Roll into Week 0 Day 4 Postgres provisioning.** | **Tight** — Day 4 of Week 0 (this week). |
docs/architecture/second-brain-design.md:981:## Impact on master brief §5.5 build sequence — closing paragraph
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
agents/recruitment/diagnostic/tools.yaml:146:      Per master brief primitive 5 — Telegram notification on report
docs/architecture/cortexos-primitive-status.md:7:**Method:** read code under `src/daemon/`, `src/pty/`, `src/bus/`, `src/telegram/`, `src/cli/`; cross-reference with `README.md`, `CHANGELOG.md`, `CRONS_MIGRATION_GUIDE.md`, `templates/{orchestrator,analyst,agent,m2c1-worker,agent-codex}/`; line-cite `tests/unit/**` and `tests/integration/**`; cross-check Day-0 findings in `.agents/learnings/00-cortextos-quirks.md`; classify per the four-status scheme from master brief §6 Day 1.
docs/architecture/cortexos-primitive-status.md:9:Two findings need founder review before the Day 7 single-sentence test (master brief §6 / Ultraplan §12). Both are master-brief drifts against the verified SHA, surfaced in Primitive 3:
docs/architecture/cortexos-primitive-status.md:11:1. **No `chokidar` watcher in the bus** — master brief §2.4 row 3 says "bus/ shell wrappers + chokidar watcher in daemon", but the bus is poll-based (`FastChecker` default 1000ms). `chokidar` is only used by the dashboard's UI file-feed.
docs/architecture/cortexos-primitive-status.md:12:2. **The four `bus/kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 names `kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`. The actual files at SHA `c21fbfe` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`. The brain-replacement seam (§3.4 + §5) needs reconciliation before Codex ratification.
docs/architecture/cortexos-primitive-status.md:36:**Master-brief description:** `node-pty` + `ecosystem.config.js` regen via `cortextos ecosystem`; agents run as PM2-managed PTY processes that auto-restart on crash or after the 71-hour context rotation (master brief §2.4 row 1).
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:97:**Master-brief description:** The daemon auto-restarts a session before the context limit; pre-rotation hook checkpoints state to vault (master brief §2.4 row 2).
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:150:# Trigger Tier 3 more than the threshold within 15 min; expect "Context circuit breaker reset after 30min pause"
docs/architecture/cortexos-primitive-status.md:157:**Master-brief description:** `bus/` shell wrappers + `chokidar` watcher in the daemon; agents drop typed files for inter-agent handoff (master brief §2.4 row 3).
docs/architecture/cortexos-primitive-status.md:184:2. **The four `kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 lists `kb-search.sh`, `kb-add.sh`, `kb-update.sh`, `kb-list.sh`. The actual files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. This is the brain-replacement seam — the master brief's named files do not exist at SHA `c21fbfe`. Either the brief was written against a different cortextOS version, or the four shadow points need to be revised. This is a Day-7 Codex-ratification-blocking discrepancy.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:228:**Master-brief description:** Daemon enforces explicit approval before external action; `manualFireDisabled` flag on crons; standing authorisations per agent (master brief §2.4 row 4).
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:292:**Master-brief description:** Bot per agent, `.env` carries `BOT_TOKEN / CHAT_ID / ALLOWED_USER`; the escalation path for every Tier-1 agent (master brief §2.4 row 5).
docs/architecture/cortexos-primitive-status.md:366:**Master-brief description:** Analyst-template agents schedule overnight experiments, evaluate results, surface findings for review (master brief §2.4 row 6).
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:430:**Master-brief description:** Orchestrator template + file-bus handoff contract; supervisor agent watches the others, escalates jams, balances load (master brief §2.4 row 7).
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/architecture/cortexos-primitive-status.md:504:- **Day-7 spec drifts for Codex ratification:** the chokidar mention in master brief §2.4 row 3 and the four `kb-*.sh` filenames in master brief §3.4 do not match the verified SHA. Both need a one-line correction or a §3.4 re-scoping decision.
docs/architecture/cortexos-primitive-status.md:505:- **Standing authorisations** (master brief §2.4 row 4) are not a cortextOS primitive at this SHA. We build them in our layer — confirm scope in the Day 5 auto-send safety policy artefact.
agents/recruitment/diagnostic/agent.md:4:**Build state:** Full bundle built (agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures). 18 Codex review-agent-bundle rounds run as of Day-20 W4 bilateral pass; ADR-006 closed Cat-1/Cat-ζ Gate A finding (R10); subsequent rounds reduce mechanical findings to steady-state ~4-5/round at the cross-reference-sync layer per master brief §10.3 step 5. R19 in progress today (this artefact). Status flips Proposed → Accepted when ALL: (a) Codex RATIFIED verdict (R19 or escalated founder-arbitrated per §10.3 step 5), AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds, AND (d) Gate B baseline measurement begins.
agents/recruitment/diagnostic/agent.md:7:**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
agents/recruitment/diagnostic/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/diagnostic/agent.md:34:Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY). Typical wall-clock: 10-15 minutes (empirical Day-13 measurement against Hays plc + Charterhouse fixtures); not specified in upstream master brief or Ultraplan.
agents/recruitment/diagnostic/agent.md:88:Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.
agents/recruitment/diagnostic/agent.md:153:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
agents/recruitment/diagnostic/agent.md:155:**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
agents/recruitment/diagnostic/agent.md:170:Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
agents/recruitment/diagnostic/agent.md:178:| Code | Trigger | Severity | Routing | v0 implementation status |
agents/recruitment/diagnostic/agent.md:206:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/diagnostic/agent.md:219:| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:5:**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:17:Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:47:### Issue 3 (RE-RAISE) — Gate B kill-criterion Trigger reference
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:49:**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:57:Option B — **Add a new kill-criterion Trigger 11 (DIAGNOSTIC-CONVERSION-FAIL).** Threshold: <30% discovery-call rate sustained for 4 weeks across all live pilots. Owner: founder + Jack.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:59:**My recommendation:** **A** for v0 — remove the trigger reference; Diagnostic conversion is local-metric tracking. Add Trigger 11 in v1.1 if conversion-rate-driven scope-cut becomes operationally relevant.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:127:1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:147:- §5 honesty (Issue 5) is exactly the kind of "honest signal" the master brief §1 Rule 5 demands; framing §5 as "intended behaviour, build slice will deliver" is more honest than asserting Gate A as already-implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:159:1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:165:**Empirical confirmation of the pattern documented in master brief §10.3 step 5:** Codex finds new issues at each round. Hard ceiling of ≤2 round-trips is the right structural protocol. Further autonomous Claude remediation passes will continue surfacing new issues that may not have been visible at earlier rounds (each fix changes the document, exposing different inconsistencies).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:186:Despite master brief §10.3 step 5 protocol saying founder review after Round 5, Round 6 attempted with all Round-5 issues remediated (commit `aaa376d`). Round 6 returned REJECTED with **4 new findings**, none of which appeared in any prior round:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:188:1. Gate B composite score (≥12.5) weakens dual ULTRAPLAN thresholds (15% dedup AND 10% field-completeness independently)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:206:This document now contains 4 rounds of empirical evidence supporting the master brief's documented hard-ceiling protocol. Founder Sunday review session is the right next step.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:229:**Round 7 findings 1 + 2 + 3 + 4 are all CAUSED BY my Round 6 fixes.** When I fixed one section, I introduced inconsistencies between it and other sections referencing the same concept. This is the perfect illustration of why master brief §10.3 step 5 caps round-trips: each fix changes the document, and the changed document has new inconsistencies between the fixed-section and the related-but-unfixed sections.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:263:- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:274:| Scribe | 5 | `20260524T112917Z-82352` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:284:- Sourcing Scout ULTRAPLAN A5 line refs: Gate A 553→552, Gate B 554→553 (4 citation sites)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:316:  - Scribe Steps 2-3, 7 partial coverage
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:372:| Scribe | 5 | 4 | −1 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:378:**Cumulative empirical (10 rounds total):** ~75 unique findings catalogued; ~7 closed via Cat-α + Cat-γ + Cat-δ inline this session; convergence rate ~10% per round. The pattern documented in master brief §10.3 step 5 holds.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:400:When founder authorizes a Cat-1 hybrid disposition (per-section v0 + per-claim W4), the agent.md prose explicitly documents this. Codex re-flags it as "Gate A weakens upstream requirement" regardless. This is structural — Codex reviews agent.md against ULTRAPLAN/master brief, and bilateral disposition documents at `docs/decisions/codex-disagreement-*.md` are downstream artefacts Codex doesn't auto-trust.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:403:- **A) Amend ULTRAPLAN §8.1 A1 line 497** — change "no claims unsupported by source data" to "no claims unsupported at section level" to match v0 reality. Aggressive; rewrites upstream spec.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:409:### Decision — stop Codex looping per master brief §10.3 step 5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:411:The pattern (Round 4 → Round 9; 10 rounds; 75+ unique findings; ~10% net convergence per round) empirically confirms master brief §10.3 step 5. Each remediation pass surfaces new issues at roughly the same rate it closes old ones — because the document keeps changing.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:348:- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
docs/specs/ULTRAPLAN.md:474:Trigger type
docs/specs/ULTRAPLAN.md:491:- **Trigger type:** Manual (run from CLI or sales-tool web page)
docs/specs/ULTRAPLAN.md:505:- **Trigger type:** Cron 02:00 UTC daily; manual full-cleanup on demand
docs/specs/ULTRAPLAN.md:515:#### A3. The Scribe — the data spine
docs/specs/ULTRAPLAN.md:517:- **Build wave:** v1.0 (week 6–7)
docs/specs/ULTRAPLAN.md:519:- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
docs/specs/ULTRAPLAN.md:521:- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
docs/specs/ULTRAPLAN.md:522:- **Shared modules required:** Voice loader (for tone-detection of tacit notes), decision log writer
docs/specs/ULTRAPLAN.md:523:- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:525:- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
docs/specs/ULTRAPLAN.md:527:- **Gotchas:** Tacit-note extraction is the hard part. Start with a small taxonomy (5–10 tacit-note types) and expand. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
docs/specs/ULTRAPLAN.md:533:- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
docs/specs/ULTRAPLAN.md:547:- **Trigger type:** Brain UI button, Telegram command, or webhook from a "new brief" event
docs/specs/ULTRAPLAN.md:561:- **Trigger type:** ATS state changes (candidate moved to interview, rejected, placed, etc.) + cron sweep for time-elapsed nurture events
docs/specs/ULTRAPLAN.md:577:- **Trigger type:** Inbound email webhook (Microsoft Graph subscription or AgentMail webhook), LinkedIn InMail webhook, website contact form webhook
docs/specs/ULTRAPLAN.md:591:- **Trigger type:** Inbound brief detected by Triage; file-bus handoff
docs/specs/ULTRAPLAN.md:609:- **Trigger type:** Broadbean / job-board scraper detects a target-patch company posted via a competitor agency
docs/specs/ULTRAPLAN.md:623:- **Trigger type:** Cron 22:00 weeknights per tenant
docs/specs/ULTRAPLAN.md:637:- **Trigger type:** Continuous (daily sweep) + event-driven on umbrella changes
docs/specs/ULTRAPLAN.md:651:- **Trigger type:** Continuous state-machine; daily sweep + event-driven on contractor events
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
docs/specs/ULTRAPLAN.md:687:| Scribe | ✓ | ✓ | | | | | | ✓ | | | |
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:760:- Week 6: Scribe agent; Fathom + Fireflies MCP; tacit-note taxonomy v0.1
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:823:| 7 | Voice classifier underperforms (false positives blocking valid drafts) | Medium | Medium | First pilot reports >5% block rate on legitimate drafts | Soften the threshold from 0.75 → 0.65 for v1.0; tune up as corpus grows |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
docs/specs/_archive-build-handoff.md:163:│   ├── ULTRAPLAN.md                                   ← copy of intelforce-os-ultraplan.md
docs/specs/_archive-build-handoff.md:185:See `docs/ULTRAPLAN.md` §9 for the 14-week v1.0 sprint plan.
docs/specs/_archive-build-handoff.md:379:| 3 | **Scribe** | 6 | Fathom/Fireflies MCP + Bullhorn write | The post-call note that lands in Bullhorn within 10 min is the second-most-demoable result |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/_archive-build-handoff.md:467:> Read `CLAUDE.md`, then `docs/ULTRAPLAN.md` §1, §3, §4, §9, §11. Confirm you understand the five rules and the boundary with CortexOS. Then look at `.agents/current-priorities.md` and tell me what we're doing today.
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/bullhorn-outreach-emails.md:74:- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:401:| Code | Trigger | Decision_log phase | Operator surface |
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/_supplementary/PRD-autonomous-agent.md:473:| `run --url [url]` | Trigger pipeline with specific reel |
docs/specs/PRODUCT-SPEC.md:110:#### R6. The Scribe — the call-to-context engine
docs/specs/PRODUCT-SPEC.md:112:- **Output contract:** Every call (Fathom, Fireflies, Ringover) gets parsed into ATS structured fields *and* tacit notes that don't fit any field: "client said they'd never hire from Bank X because of a 2019 grudge", "candidate's actual reason for leaving is the new line manager, not the salary". Tacit notes power every other agent's voice and judgement.
docs/specs/PRODUCT-SPEC.md:117:- **Per-tenant config:** transcript-source OAuth, ATS field-mapping rules, tacit-note retention policy, banned-extraction patterns (anything sensitive that shouldn't be captured).
docs/specs/PRODUCT-SPEC.md:182:Triggered by the April 2026 regulatory window — Joint & Several Liability for umbrella PAYE, six-year holiday-pay record-keeping, Fair Work Agency standing up. Different buyer (FD / Compliance Officer / Operations Director), different sales conversation, separate SKU. Same Intel Force OS platform.
docs/specs/PRODUCT-SPEC.md:187:- **Revenue story:** "First 2 weeks of every contract done correctly, every time. No PAYE surprises in week 6 because RTW was checked on day 1." Avoids £5k–£40k per botched onboarding (back-claimed PAYE plus penalties).
docs/specs/PRODUCT-SPEC.md:242:| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:279:        │   The Scribe captures    │    │  The Janitor keeps it    │
docs/specs/PRODUCT-SPEC.md:297:The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**
docs/specs/PRODUCT-SPEC.md:329:- Customer clicks 5 OAuth buttons in the wizard: ATS (Bullhorn / Vincere / Voyager), accounting (Xero / Sage / QuickBooks), Microsoft 365 or Google Workspace, transcript source (Fathom / Fireflies / Ringover), LinkedIn.
docs/specs/PRODUCT-SPEC.md:473:- The Scribe (the data spine)
docs/specs/PRODUCT-SPEC.md:527:6. **The Scribe** — "Your firm's institutional memory finally lives somewhere."
docs/decisions/sequencing-target.md:6:**Surfaced by:** Master brief §6 Day 3 (lines 469-473) — "Confirm or revise Ultraplan §9's 'close first 3 pilots fastest' → `.agents/decisions/sequencing-target.md`" (note: master brief §6 names `.agents/decisions/`; this document lives at `docs/decisions/sequencing-target.md` matching the convention established by ADR-001 through ADR-003 + bullhorn-integration-path.md — **Spec gap §1-A** flagged for atomic correction).
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:42:**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:46:The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
docs/decisions/sequencing-target.md:50:Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
docs/decisions/sequencing-target.md:65:Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:84:**Section 4's recommendation evaluates both orderings** (founder-prompt-Alpha and master-brief-Alpha) against the §1.3 criteria, picks whichever wins on the merits, and explicitly aligns with the master brief by default unless rationale exists to revise it. This document is the "confirm or revise" decision per master brief §6 Day 3 line 471 — both options are on the table.
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
docs/decisions/sequencing-target.md:210:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:231:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:240:1. **Concierge depends on Scribe** for Notes-for-context (per `bullhorn-integration-path.md` §4.1 row 4 — Concierge reads Notes Scribe wrote). Building Concierge at W6-9 before Scribe (W10) means Concierge's first-month operation has empty Note context. Materially degrades the Tier-1 always-on demo.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:267:| **Risk #4 materialises (Hire #1 doesn't start)** → drop Concierge + Sourcing Scout, founder solo | **Coherent.** Founder solo through W6-Scribe; W7-8 Cash Conductor becomes founder solo work (slows but doesn't block); Sourcing Scout + Concierge cut. v1.0 ships as 4 agents per Ultraplan §10 Risk #4 contingency | Incoherent. Concierge already W5-8 — can't be cut without rewrite | Incoherent. Concierge already W6-9 |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:300:**Trigger 1 — Risk #2 materialises in Week 4-5.** If Bullhorn auth path breaks (Day 2 Sub-decisions A or B don't flip to Accepted, marketplace required but unobtainable, OAuth flow blocks deployment, or per-tenant client_id ticket cycle slows past 5 business days per `bullhorn-integration-path.md` §1.3 row 5):
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:307:**Trigger 2 — Risk #4 materialises (Hire #1 doesn't start by end of Week 4).** Per RISK-REGISTER #4 tripwire "No offer accepted by end of week 4":
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:314:**Trigger 3 — Hire #1 starts later than Week 7.** Per Ultraplan §9 line 766 verbatim caveat: "Hire #1 is assumed to start week 7 (verify, don't assume)":
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:326:- The substrate-first principle (Diagnostic W3-4 before any Bullhorn-touching agent).
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:335:- Per-agent Codex-ratification timing within each build slot — every `agent.md` ratifies before merge per master brief §10.5; specific ratification cadence emerges from each agent's PR cycle.
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:373:3. **Either fix-and-retry (1 additional week)** or **scope-cut contingency activates** per §4.3 Trigger 1 (if Risk #2 derived) or §4.3 Trigger 2 (if Risk #4 derived).
docs/decisions/sequencing-target.md:374:4. **If scope-cut activates twice in one v1.0 cycle, escalate to v1.0 kill criterion** — the Day 5 work (master brief §6 Day 5) defines the kill-criterion threshold; sequencing failures count toward that threshold.
docs/decisions/sequencing-target.md:389:- `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` per master brief §8.1 Changes 1+2.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:410:§4.3 Trigger 1 activation point: end of W4 weekly review if Sub-decisions A and B still Proposed.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:455:Per §1.5 Spec gap §1-A finding: master brief §6 Day 3 line 471 names the path `.agents/decisions/sequencing-target.md` but the convention established by Days 1-2 is `docs/decisions/`. Same path-convention drift applies to line 472 (Brain UI scope decision; will be flagged in `brain-ui-scope.md` separately if needed).
docs/decisions/sequencing-target.md:457:**Current** (master brief §6 Day 3 line 471 verbatim):
docs/decisions/sequencing-target.md:489:| §1-A | §6.8 + atomic correction commit edit 7 | Path convention `.agents/decisions/` → `docs/decisions/` for master brief §6 Day 3 line 471 (and likely line 472 per brain-ui-scope.md) |
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:519:| §4.3 Trigger 3 cascade (Hire #1 starts W8 → Cash Conductor W8-9) | Actual Hire #1 start date; if W9+ then Trigger 2 activates as fallback |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar position; actual execution 2026-05-20)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:12:From master brief §6 Day 7 lines 494-501 verbatim:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:36:- **Kill criterion linkage:** Trigger 1 in `docs/decisions/v1.0-kill-criterion.md` §2 (DESIGN-PARTNER-BY-WEEK-2) fires end-of-day **2026-06-03** if no signed LOI by then. That is the binding tripwire — currently **14 calendar days** out from today (2026-05-20).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:43:- **Primitive 1 (Persistent PTY via PM2):** functional per Day-1 audit `docs/architecture/cortexos-primitive-status.md` — "shipped but flaky" per master brief §12 Risk #1. Day-1 audit found the substrate is operational for development workloads. Quirks 2-3 + 2026-04-22 restart-storm evidence document occasional instability under load, not broken.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:45:- **Primitive 5 (Telegram + iOS approval surface):** confirmed shipped per `cortexos-primitive-status.md` audit. Two-poller mechanism (`agent-manager.ts:478-575`, `maybeStartActivityChannelPoller()`) integrates with primitive 4 approval gates. Per master brief §12 Risk #1 framing: "Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:61:- **"Cleared the auth path" interpretation:** strict — "cleared" means the technical and commercial gates have both passed. Technical path documented (auth-code-against-IFOS-dev-tenant; `client_credentials` foreclosed per master brief §6 Day 2 atomic-correction Edit 6 verified at `0e5b2b4`). Commercial gates not passed. Q3 = NO.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:78:- **8 entities per master brief §6 Day 6 line 490:** `candidate`, `contractor`, `client`, `contact`, `brief` (with `role` alias), `placement`, `opportunity`, `timesheet`.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:90:| 1 | Design partner pilot Q3 2026 LOI? | **NO** | High — zero pipeline; Risk #3 High; Trigger 1 fires 2026-06-03 |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:100:**Week 0 EXTENDS per master brief §6 line 502.**
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:113:2. **`.codex/ratification/*.md` skills** — master brief §10.2 Day-1 task deferred during Days 0-6; surfaced as gap during Day-7 grounding. Build during extension period. 7 skill files (SKILL.md + 6 review-{type}.md per master brief §10.2). Estimated 2-3 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:133:- If re-run produces 4 of 5 YES (Q3 still NO because Bullhorn commercial conversations haven't completed), founder may accept Q3 as risk-noted and declare Week 0 closed with Week 1 starting under that accepted risk. This is a founder-discretion call, not automatic from the master brief test.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:148:- Trigger 1 (kill criterion DESIGN-PARTNER-BY-WEEK-2 PAUSE): fires end-of-day **2026-06-03** if no signed LOI.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:26:This drift surfaced during the Day-1 primitive audit. It has no Day-0 quirk attached and no real-world brittleness — the bus itself ships and is tested (`tests/unit/bus/message.test.ts`, `tests/integration/multi-agent-crons.test.ts`, `tests/e2e/lifecycle.test.ts`). Only the master brief's mechanism description is wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:32:**1. Correct master brief §2.4 row 3.** Replace:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:47:| **B. Reduce to 250ms** | Set `pollInterval: 250` in the IFOS agent template's `config.json`. Re-measure daemon CPU on a 6-agent fleet under load (master brief §6 Day 4 stress-test addition). Keep the existing "complete in seconds" framing | ~0.5 day to add the config + re-baseline; ongoing 4× CPU per FastChecker poll (still negligible — `readdirSync` on a typically-empty inbox dir is sub-millisecond, so 4× sub-ms is still sub-ms). The risk is `bus-signing-key` HMAC verification cost × 4 if inbox traffic spikes | Pipeline floor drops to ~750ms — restores headroom for the sales narrative while leaving CPU comfortable. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:51:1. The honest-signal Rule 5 (master brief §1) makes "rewrite the claim" cheaper than "tune the substrate to fit the claim".
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:58:- Single edit to master brief §2.4 row 3 (the correction itself).
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:66:- Day 4 infra stress-test (master brief §6) gains a new sub-task: measure daemon CPU on a synthetic 6-agent fleet at 250ms poll vs 1000ms baseline.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:70:- The "no chokidar" finding propagates to two other places that referenced the old mechanism: `docs/build-brief/00-MASTER-BRIEF.md` §2.4 row 3 + footnote, and the `docs/specs/ULTRAPLAN.md` §3.2 wording. Both edits are part of the same atomic correction.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:71:- Codex-ratification list (master brief §10.5) needs an entry: bus-dispatcher mechanism change = master brief edit = always-ratify.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:76:**Accepted — Option A.** Founder decision logged 2026-05-16. The master brief §2.4 row 3 + Ultraplan §3.2 edits are deferred to a single atomic "spec drift reconciliation" commit that lands alongside whatever ADR-002 dictates for §3.4. Codex ratifies the combined commit on Day 7 with the other Week 0 artefacts.
docs/_supplementary/build-plan-original.md:135:- **Fixture inputs** — real anonymised examples (redacted Fathom transcript, scrubbed lead list)
docs/_supplementary/build-plan-original.md:208:1. Takes the trigger payload (e.g. Fathom call transcript)
docs/_supplementary/build-plan-original.md:226:- Trigger payload: variable (Fathom transcript = 5–15k tokens)
docs/_supplementary/build-plan-original.md:246:| Client Onboarder | 4 | 8k in / 6k out | £0.15 | £0.60 |
docs/_supplementary/build-plan-original.md:276:### Trigger
docs/_supplementary/build-plan-original.md:340:**"Fathom call end" → "proposal in inbox" median time.** Target: <120s. Also: proposal-to-signed-contract conversion rate, measured monthly. Baseline against client's historical rate; target ≥ parity within 60 days.
docs/_supplementary/build-plan-original.md:342:### Trigger
docs/_supplementary/build-plan-original.md:343:Fathom webhook `recording.complete` with `include_transcript: true, include_summary: true, include_action_items: true`. Payload lands at `hooks.intelforce.ai/{tenant}/fathom`, persists to `/intake/fathom/{call-id}.json`, triggers the agent.
docs/_supplementary/build-plan-original.md:352:- Fathom AI summary + action items
docs/_supplementary/build-plan-original.md:361:- **Fathom MCP** (use `matthewbergvinson/fathom-mcp` or `Dot-Fun/fathom-mcp` as starting point; fork and productize) — transcript, summary, action items
docs/_supplementary/build-plan-original.md:390:Fathom URL: [link for audit]
docs/_supplementary/build-plan-original.md:394:<Fathom summary>
docs/_supplementary/build-plan-original.md:397:<Fathom action items>
docs/_supplementary/build-plan-original.md:477:- Fathom summary contradicts transcript → trust transcript, flag contradiction
docs/_supplementary/build-plan-original.md:496:**High.** The prompt engineering alone is a full week of iteration against real calls. The integrations (Fathom + HubSpot + DocuSign + Notion + Gmail) are another week. The validation tooling is 3 days. Budget 3 weeks total to get to production quality. You CANNOT rush this one.
docs/_supplementary/build-plan-original.md:511:### Trigger
docs/_supplementary/build-plan-original.md:584:### Trigger
docs/_supplementary/build-plan-original.md:661:### Trigger
docs/_supplementary/build-plan-original.md:717:### Trigger
docs/_supplementary/build-plan-original.md:759:### Trigger
docs/_supplementary/build-plan-original.md:795:### Cost: £0.60/mo. Build: 1 week (lots of integrations).
docs/_supplementary/build-plan-original.md:807:### Trigger
docs/_supplementary/build-plan-original.md:853:### Trigger
docs/_supplementary/build-plan-original.md:938:Claude Code sub-agent exposed as a Slack/Teams bot. Triggered by @mentions and DMs.
docs/_supplementary/build-plan-original.md:1021:### Trigger
docs/_supplementary/build-plan-original.md:1080:                       (Fathom, Stripe, DocuSign, HubSpot) via their APIs
docs/_supplementary/build-plan-original.md:1197:1. Verify signature (every integration has its own: Fathom uses HMAC, Stripe uses stripe-signature, HubSpot has timestamp+signature)
docs/_supplementary/build-plan-original.md:1204:- **At-least-once** processing — fine because agent outputs are idempotent by design (same Fathom call ID → same proposal location, overwritten)
docs/_supplementary/build-plan-original.md:1255:| Fathom | Community MCP (matthewbergvinson, Dot-Fun) | Fork, harden, productize |
docs/_supplementary/build-plan-original.md:1516:- Week 1: Runtime proof-of-concept — **Proposal Builder end-to-end** in one container, one real Fathom call → proposal in inbox. This is the week-1 experiment from v2. Nothing else.
docs/operations/w4-bilateral-pass-6-agent-md.md:6:**Trigger 2:** DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 — 20 days runway. Diagnostic is pass-order #1.
docs/operations/w4-bilateral-pass-6-agent-md.md:35:| 1 | Diagnostic | 5 | Trigger 2 runway (20 days). Bundle code is complete; only RATIFIED is missing. |
docs/operations/w4-bilateral-pass-6-agent-md.md:39:| 5 | Scribe | 5 | Ringover scope question is the only non-mechanical. |
docs/operations/w4-bilateral-pass-6-agent-md.md:92:  - **Codex says:** "Line 59 says tacit notes are harvested from `decision_log` rows with `outcome='approved_after_edit'`, but the schema only documents `decision_log` as `agent_name`, `phase`, and `payload JSONB`; `approved_after_edit` is the `recent_edit.resolution` enum in v0.2 supplement §1.3. Fix §3 to harvest from `recent_edit.resolution='approved_after_edit'` and use `decision_log` only for action-context joins."
docs/operations/w4-bilateral-pass-6-agent-md.md:158:## 5. Scribe — `agents/recruitment/scribe/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:175:  - **Cite:** §3 lines 16, 30, 39; cross-ref §8 lines 295-298 + ULTRAPLAN A3 lines 521-523
docs/operations/w4-bilateral-pass-6-agent-md.md:176:  - **Codex says:** "Lines 16, 30, and 39 include Ringover as a provider, but §8 lines 295-298 only gate Fathom/Fireflies signup and connector work; ULTRAPLAN A3 lines 521-523 require Bullhorn, Fathom, and Fireflies tools/APIs, not Ringover. Either remove Ringover from v1.0 surfaces or add the Ringover commercial/API/connector prerequisites explicitly."
docs/operations/w4-bilateral-pass-6-agent-md.md:188:  - **Codex says:** "Line 250 defines it for Fathom/Fireflies/Ringover transcript fetches, but `agents/_shared/escalation-codes.md` lines 324-329 define a generic upstream read failure with examples that do not include transcript providers and no transcript-specific payload. Either update the catalogue to register transcript-provider usage and payload fields, or use/register a Scribe-specific transcript fetch code."
docs/operations/w4-bilateral-pass-6-agent-md.md:211:  - **Cite:** §10 lines 417-421; cross-ref ULTRAPLAN A6 line 566 + lines 206-212/276
docs/operations/w4-bilateral-pass-6-agent-md.md:212:  - **Codex says:** "Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker."
docs/operations/w4-bilateral-pass-6-agent-md.md:218:### Finding 4. ULTRAPLAN line-citation drift
docs/operations/w4-bilateral-pass-6-agent-md.md:219:  - **Cite:** §3 lines 16, 39, 76, 333, 345; cross-ref ULTRAPLAN A6
docs/operations/w4-bilateral-pass-6-agent-md.md:220:  - **Codex says:** "Lines 16, 39, 76, 333, and 345 cite line 570 for lifecycle/rejection gotchas, but verified ULTRAPLAN has the gotcha text on line 569 and line 570 is blank. Update these citations to ULTRAPLAN A6 line 569."
docs/operations/w4-bilateral-pass-6-agent-md.md:221:  - **Likely:** FIX-IN-PLACE. Find-and-replace `ULTRAPLAN A6 line 570` → `ULTRAPLAN A6 line 569`. Verify count: 5 sites.
docs/operations/w4-bilateral-pass-6-agent-md.md:228:1. **Hh_decision_* coverage** (Scribe #2, Concierge #1) — workflow narratives are dropping the decision-log writes between numbered steps. After this pass, recommend a one-shot grep on all 6 agent.md to confirm every workflow step that produces output/action has an `hh_decision_*` annotation.
docs/operations/w4-bilateral-pass-6-agent-md.md:230:2. **Schema-citation hygiene** (Janitor #2, #3, #4; Sourcing Scout #1; Scribe #1) — v0.2/v0.3 supplement boundary is the single most-failed cross-reference. After this pass, recommend a CI grep that flags any `agent.md` field reference whose name doesn't appear in `vertical-schema.yaml` OR `vertical-schema.v0.3-supplement.yaml`.
docs/operations/w4-bilateral-pass-6-agent-md.md:232:3. **Catalogue completeness** (Diagnostic #2, Janitor #1, Scribe #5) — `escalation-codes.md` is the canonical mapping; agent.md narratives drift from it. After this pass, recommend a CI grep verifying every `ESC_*` reference in `agent.md` exists in the catalogue with at least the agent_name in `used_by`.
docs/operations/w4-bilateral-pass-6-agent-md.md:236:5. **Status semantics** (Sourcing Scout #2) — confirm with founder: "Ratified at Round-N" is not "Accepted"; Accepted requires bundle completion. Likely a one-line clarification in the agent-bundle skill or master brief §8 to prevent this drift in future agents.
docs/operations/w4-bilateral-pass-6-agent-md.md:256:- [ ] Diagnostic is RATIFIED (Trigger 2 burn-down)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:13:ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:25:This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:62:## ULTRAPLAN amendment
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:64:`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:72:**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:83:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:87:**Why not (c) amend ULTRAPLAN downward permanently?**
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:89:- Permanently removing it from ULTRAPLAN loses the documented quality bar
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:113:- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the original ULTRAPLAN line 496 prose alone)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:140:| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
docs/operations/codex-round-2-autonomous-prompt.md:91:recursive ratification per master brief §10.5. Decide whether Claude's 
docs/operations/codex-round-2-autonomous-prompt.md:196:  Disagreement docs (recursive ratification per master brief §10.5):
docs/operations/codex-round-2-autonomous-prompt.md:320:**If SUMMARY.md shows unexpected REJECTED items:** Codex caught something. Read the per-artefact output file. Decide whether to incorporate or counter-argue. Then Round 3 (~limited; ≤2 round-trips per master brief §10.3).
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:15:> "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**." (master brief §3.4 line 167)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:19:The Day-1 cortextOS primitive audit (`docs/architecture/cortexos-primitive-status.md` — Primitive 3) surfaced that **none of those four files exist at SHA `c21fbfe`**. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. Reading `kb-setup.sh` revealed the substrate underneath: `mmrag.py` over ChromaDB with Gemini embeddings and 1000-char chunks (`docs/architecture/cortexos-kb-surface-investigation.md` §"What is cortextOS's KB substrate"). That data model is incompatible with the IFOS wiki's entity-document model in master brief §5.2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:27:cortextOS's `bus/kb-*.sh` surface and the `mmrag.py` / ChromaDB / Gemini stack at `packages/harness/cortextos/knowledge-base/` remain **untouched**. IFOS agents do **not** invoke `kb-query`, `kb-ingest`, `kb-collections`, or `kb-setup`. The §3.1 "edit-exception for four `bus/kb-*.sh` shadow points" in the master brief becomes a **dead clause**: there is no shadowing, the exception is never exercised, and §3.1's "never edit `packages/harness/cortextos/*`" stands without qualifier.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:75:**Disposition update 2026-05-20 (Day 8 Codex Round 1):** all three edits landed in the atomic-correction commit **`0e5b2b4`** ("docs: master brief reconciliation — 11 edits batch-applied", Day 7 2026-05-20). Manifest-of-record below — each edit's "where it landed" is `0e5b2b4`.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:81:**Current** (master brief §3.4 line 167-176): "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**. … 1. Vendored copy at `packages/harness/cortextos/bus/kb-*.sh` is left untouched. 2. Our overrides live at `packages/brain/bus-overrides/kb-*.sh`. 3. PM2 `ecosystem.config.js` sets `PATH` so our overrides are picked up first…"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:87:**Current** (master brief §5.5 lines 416-420):
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:97:**Current** (master brief §6 Day 4 line 478):
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:105:This edit lands on **Day 4 of Week 0 (this week)** as part of the Postgres provisioning task per master brief §6 Day 4, **not** in the brain-ADR atomic commit. ADR-002 authorises the split; Day 4 implements it.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:119:**For cortextOS upstream.** No PR upstreamable from this ADR. cortextOS code is untouched; the submodule pin (`c21fbfe991a0030ea055bd8e2389a0801a424383`) stays. The brain-replacement boundary in master brief §3.1 simply isn't exercised — that's not a bug in cortextOS, it's an IFOS-side decision to use a parallel surface.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:127:- **Future v1.1+ ADR (Brain UI implementation choice)** — Next.js routes extending the cortextOS dashboard per master brief §5.3 vs. standalone — out of scope for Q3.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:17:Three sub-decisions, named in master brief §6 Day 2 line 466 and extended in Ultraplan §11 Day 2 lines 847-849.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:27:Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:42:This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.
docs/decisions/bullhorn-integration-path.md:48:**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:70:| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
docs/decisions/bullhorn-integration-path.md:74:The Sunday design-partner conversation 2 is the most time-sensitive: it can flip the entire premise of Sub-decisions A and C. Founder cadence per master brief §6 Day 2 (line 467) and §11.2 line 791 ("Day 2 — Tuesday — Bullhorn integration path... — Design-partner conversation 2") puts this as a parallel-to-Claude-Code track.
docs/decisions/bullhorn-integration-path.md:91:- **Day 7 review (master brief §6 Day 7 Sunday):**
docs/decisions/bullhorn-integration-path.md:93:  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:99:Three distinct gates govern Bullhorn-touching work, in temporal order:
docs/decisions/bullhorn-integration-path.md:101:| Gate | Trigger | Status |
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:191:| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:226:**Scope of permissions requested at first auth:** Bullhorn's OAuth docs surveyed do not specify per-scope strings (e.g. `read:candidate`, `write:note`). REST API access appears to be at-tenant-admin-discretion — the admin authorises the connected app for "API access" generally, and the corpToken-scoped session inherits whatever entity permissions the admin's account holds. **Spec gap §3.1-B:** confirm with Bullhorn developer support that there is no per-entity-type scope granularity at the OAuth layer — i.e. IFOS cannot request "read-only" auth and get a token that can't write. If this is correct, then Gate A in `validate.sh` (per master brief §1 Rule 4) becomes the only enforcement layer for "this agent should never write" — the OAuth token itself does not protect.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:239:This forecloses one option that the master brief §6 Day 2 line 466 pre-statement contemplated — "service-account for dev." The closest substitute is one of:
docs/decisions/bullhorn-integration-path.md:256:**Recommendation:** authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement "browser dance for production"). For IFOS dev: authorization-code grant against an IFOS-owned Bullhorn dev tenant; service-account / client_credentials grant deferred (because Bullhorn doesn't document support for it per §3.2).
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:283:| Agent | Entities Read | Entities Written | Read Cadence | Write Triggers | Error Handling | Per-tenant Scoping |
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:294:**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.
docs/decisions/bullhorn-integration-path.md:308:| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
docs/decisions/bullhorn-integration-path.md:335:| Scribe (write-on-event) | 50-100 distributed | Event-rate-bounded; one call typically = 5-15 REST writes |
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:375:3. First design partner ATS confirmed as Bullhorn (Sunday design-partner conversation 2 per master brief §6 Day 2 line 467).
docs/decisions/bullhorn-integration-path.md:381:Recommendation: authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement); authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (client_credentials grant **foreclosed** by Bullhorn OAuth docs per §3.2 — Bullhorn does not support client_credentials grant for tenant-scoped data). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:442:§3.2 finding (Bullhorn does NOT support client_credentials grant for tenant-scoped data per public OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`) forecloses the master brief §6 Day 2 line 466 pre-statement. New sixth edit for the atomic correction commit alongside ADR-001 + ADR-002 + ADR-003 Edit C.
docs/decisions/bullhorn-integration-path.md:444:**Current** (master brief §6 Day 2 line 466 verbatim):
docs/decisions/bullhorn-integration-path.md:452:Joins the atomic correction commit at end of Week 0 / early Week 1. Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
agents/recruitment/concierge/README.md:18:Full bundle at W10-13 build (~4 weeks per ULTRAPLAN A6 line 568 XL flag):
docs/decisions/ADR-003-agent-bundle-renderer.md:15:The §1.7 inheritance investigation in `docs/architecture/second-brain-design.md` found that `cortextos-ifos add-agent` copies the full `templates/agent/.claude/skills/` tree verbatim per `src/cli/add-agent.ts:88-110, 382-402` — 24 cortextOS template skills including `knowledge-base` (calls `kb-*` against cortextOS's mmrag/ChromaDB KB, which IFOS agents must not invoke per ADR-002) and `memory` (heartbeat-ingests `MEMORY.md` into the KB, which IFOS agents don't have because they use Postgres `decision_log` per master brief §8.1 Change 2). ADR-002 recommended R2 (bundle-only; no skill inheritance) but deferred the binding decision to this ADR.
docs/decisions/ADR-003-agent-bundle-renderer.md:23:Per design §5.1: the cortextOS `cortextos-ifos add-agent` command is **unchanged**. IFOS does not use it for IFOS-owned agents. The renderer is a **new** command at `packages/agent-renderer/`, invoked via `ifos-render-agent <agent-name> --tenant <slug>` (standalone Node binary per `package.json` `bin`; **errata via ADR-004 Decision 1** — earlier drafts named this `cortextos-ifos render-agent` which would have required modifying the read-only submodule per master brief §3.1 boundary 1).
docs/decisions/ADR-003-agent-bundle-renderer.md:37:Three alternatives rejected per design §3.1: `packages/brain/agent-cli/` (wrong cohesion — brain is wiki, renderer is not a wiki concern); `scripts/render-agent.sh` (JSON Schema validation + YAML parsing harder in shell); new top-level directory (loses master brief §4.1 line 195-204 `packages/` convention).
docs/decisions/ADR-003-agent-bundle-renderer.md:39:**Invocation mode** per design §3.2: manual developer invocation. Day-1 cadence (founder + Claude Code), per-tenant scope explicit, hand-off boundary clean. Three alternatives rejected per design §3.2: pre-push hook (wrong filesystem — tenant vault on Hetzner UK VPS, hook on dev laptop), CI on merge (same reachability problem), daemon auto-watcher (wrong coupling — daemon is read-only on submodule per master brief §3.1).
docs/decisions/ADR-003-agent-bundle-renderer.md:60:Two alternatives rejected per design §3.4: merge-with-conflict-markers (premature complexity — master brief §1 Rule 1 "output before architecture" favours simple); refuse-if-exists (friction without benefit — Decision 1's marker-file check handles the actual risk).
docs/decisions/ADR-003-agent-bundle-renderer.md:74:**Current** (master brief §4.1 lines 195-204):
docs/decisions/ADR-003-agent-bundle-renderer.md:94:Lands in this ADR's commit. Edit A is the minimum required to make `packages/agent-renderer/` a canonical IFOS package per master brief §4.1; Week-1 renderer implementation depends on the path existing.
docs/decisions/ADR-003-agent-bundle-renderer.md:98:**Current** (master brief §8.3 lines 614-630):
docs/decisions/ADR-003-agent-bundle-renderer.md:133:**Current** (master brief §8 lines 545-568): bundle file list followed immediately by §8.1 ("The three v2 changes"). No footnote between §8 and §8.1.
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:151:**For the master brief atomic correction commit.** Edit C (the §8 footnote) joins ADR-001 + ADR-002 edits in the deferred single commit at end of Week 0 / early Week 1. Edits A and B land in this batch's commit because (a) Edit A is needed live before Week-1 renderer implementation can scaffold the package path, (b) Edit B is a small wording add to a code block, (c) neither is substantive enough to warrant the atomic-correction overhead.
docs/decisions/ADR-003-agent-bundle-renderer.md:163:1. Edits A and B applied to master brief §4.1 and §8.3 in this batch's commit.
docs/_supplementary/README.md:5:- `docs/build-brief/00-MASTER-BRIEF.md` — the master brief Claude Code reads first
docs/_supplementary/README.md:7:- `docs/specs/ULTRAPLAN.md` — how, in what order
docs/decisions/ADR-004-renderer-implementation-deviations.md:18:The three deviations are individually small. The reason this ADR exists rather than three inline `errata` notes in ADR-003 is master brief §10.5 ("Always-ratify list"): renderer architectural decisions go through Codex review, and a single coherent ADR is the audit-trail-friendly path. Reading ADR-003 + ADR-004 together gives the full ratified renderer surface.
docs/decisions/ADR-004-renderer-implementation-deviations.md:30:**Why the deviation:** `cortextos-ifos` is the upstream CLI shipped from the cortextOS submodule at `/opt/homebrew/bin/cortextos-ifos`. Adding a `render-agent` subcommand to that binary requires modifying source in `packages/harness/cortextos/`, which violates master brief §3.1 boundary 1 (cortextOS submodule read-only). The boundary is non-negotiable per master brief §3.1 + the build-pack discipline that the submodule is a "reference pin, not the runtime."
docs/decisions/ADR-004-renderer-implementation-deviations.md:79:- **Prefix `_shared/` with a dotfile** (`.shared/`) to make the listAgents scan skip it. Rejected — Bash glob conventions + Postgres conventions both treat dot-prefix as "hidden", and we'd lose the discoverable convention that `_shared/` follows IFOS naming rules. Also drifts further from the master brief vocabulary.
docs/decisions/ADR-004-renderer-implementation-deviations.md:80:- **File an upstream issue / PR against cortextOS** to filter out `_shared/` (and other underscore-prefixed names) in `listAgents()`. **Recommended path** — open an issue on the cortextOS repo per master brief §3 boundary 1 ("the submodule is a reference pin, not the runtime; upstream changes go upstream"). Phase 2 ships the deviation as documented; founder + upstream maintainer fix it on their schedule.
docs/decisions/ADR-004-renderer-implementation-deviations.md:93:Current (post-ADR-003 Edit B at master brief §8.3 lines 614-630):
docs/decisions/ADR-004-renderer-implementation-deviations.md:136:> "invoked via `ifos-render-agent <agent-name> --tenant <slug>` (CLI signature per design §3.3.1 + ADR-004 Decision 1; standalone Node binary per `packages/agent-renderer/package.json` `bin`. The `cortextos-ifos render-agent` form named in earlier drafts requires modifying the read-only submodule and was rejected per master brief §3.1 boundary 1)."
docs/decisions/ADR-004-renderer-implementation-deviations.md:148:**For master brief drift.** Edit D + Edit E + Edit F enter the deferred atomic-correction queue (if not landed in this commit). Risk #7 (master-brief-drift-accumulation) is currently closed; reopening it for 3 small text edits is honest but tracked here. Founder decides at ratification time whether to land in this commit or queue for the next atomic correction.
docs/decisions/ADR-004-renderer-implementation-deviations.md:150:**For future Diagnostic builds.** Decision 1 means agents/runbooks/onboarding-wizard documentation references `ifos-render-agent`, not `cortextos-ifos render-agent`. Cheap to update everywhere because no documentation has shipped yet — only ADR-003 + master brief §8.3 reference the old name, and both are addressed in §"Master brief edits authorised."
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** Proposed (2026-05-25, Day 20; W4 bilateral pass on Concierge agent.md surfaced this as Codex R3 Finding 3 — current scaffold reframes ULTRAPLAN A6 line 566 Gate A "every lifecycle event has a draft generated within 30 minutes" as a Gate B leading metric without an authoritative ADR backing the deviation. Awaits Codex `review-architecture-decision` ratification + founder Accept.)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566 — Gate A 30-minute draft SLA clause
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:13:ULTRAPLAN §8.1 A6 line 566 (pre-amendment wording):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:28:> The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:30:Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:36:The Concierge lifecycle-event trigger source is the Bullhorn ATS state-change webhook + a polling-fallback cron (per ULTRAPLAN A6 line 569 verbatim gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks").
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:44:The 30-minute SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Treating it as Gate B at the 90% threshold:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:55:**Alternative A — Keep ULTRAPLAN A6 line 566 verbatim: 30-min SLA is per-draft Gate A hard-fail.** Rejected because Bullhorn webhook coverage is patchy per the ULTRAPLAN A6 gotcha (the same source spec acknowledging the polling-fallback requirement); per-draft hard-fail would drop legitimate drafts whose Concierge generation IS within 30 min of detection but whose upstream detection latency exceeded 30 min. The product harm: candidate experiences "ghosted by recruiter" — exactly the pattern Concierge was designed to prevent.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:57:**Alternative B — Remove the 30-minute SLA entirely.** Rejected because the SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Removing it would let drafts slip indefinitely with no quality signal — the "no candidate ghosted" goal becomes unmeasurable.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:67:**Concierge Gate A is the subset of ULTRAPLAN A6 line 566 that is operationally enforceable per-draft:**
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:83:**ULTRAPLAN §8.1 A6 line 566 is amended in-band per the master brief §10.3 step 4 pattern** (analogue of the in-band amendment ADR-006 made at line 496):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:108:4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:112:### In-band ULTRAPLAN amendment (applied with this ADR per master brief §10.3 step 4)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:114:ULTRAPLAN §8.1 A6 line 566 amended in the same commit as this ADR. Pre-amendment / post-amendment text is captured in this ADR's body. The amendment also updated line 567 Gate B target to include the new ≥90% 30-min SLA hit rate threshold (per ADR-007). See commit history for the diff.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:120:> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:137:- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:145:**Status:** Proposed; awaits Codex `review-architecture-decision` ratification (R19+) + founder Accept per master brief §10.3 step 5 if Codex still disagrees.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:13:ULTRAPLAN.md §8.1 specifies the v1.0 build sequence:
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:18:| 3 | **Bullhorn MCP server build** (auth, read endpoints, write endpoints, webhook subscription) per ULTRAPLAN line 752 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:19:| 4 | **Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint** per ULTRAPLAN line 753 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:21:| 6 | Scribe |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:48:2. **The Week-4 milestone is achievable today.** ULTRAPLAN line 755: *"Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."* Option C produces exactly this; the dependencies (LinkedIn + Companies House + scrape) are independent of Bullhorn.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:51:5. **Buffer on kill-criterion Trigger 2.** `v1.0-kill-criterion.md` Trigger 2 fires 2026-06-14 if Diagnostic doesn't render cleanly. Today is 2026-05-24 — 21 days of buffer. Building now beats the deadline by 3 weeks.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:85:- Q1 LOI gate (Jack's lane; Trigger 1 fires 2026-06-03 if no LOI)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:106:- ULTRAPLAN §8.1 line 753-755 (Week-4 milestone definition)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:107:- ULTRAPLAN §10 Risk #2 row contingency (defer Bullhorn-touching agents)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:109:- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
docs/_supplementary/strategic-plan.md:82:2. **Proposal Builder** — the signature agent. Fathom call ends → draft proposal in inbox within 90 seconds
docs/_supplementary/strategic-plan.md:173:│  - MCP servers for: HubSpot, Fathom, Gmail, Slack, DocuSign,│
docs/_supplementary/strategic-plan.md:255:  - Current stack (checkboxes: HubSpot? Fathom? Gmail?)
docs/_supplementary/strategic-plan.md:259:  - Same for Fathom, Gmail, Slack, Calendly, Stripe, etc.
docs/_supplementary/strategic-plan.md:265:  - Per-agent config (e.g. Proposal Builder: which Fathom folder?
docs/_supplementary/strategic-plan.md:326:- [ ] **Dev**: Trigger system (webhooks, cron via BullMQ)
docs/_supplementary/strategic-plan.md:333:**Milestone**: the Proposal Builder agent actually takes a Fathom call and drafts a proposal. End-to-end.
docs/_supplementary/strategic-plan.md:337:- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
docs/_supplementary/strategic-plan.md:454:Force yourself to onboard one friendly client at week 6 (half-built, half-manual behind the scenes). Their pain will teach you more than any plan.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:37:| Gate | Trigger | Status |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:30:No edit to the agent.md or validate.sh. R17 dispositions cover the other 4 findings; this disagreement is recorded per master brief §10.3 step 4 ("Claude Code reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)").
docs/_supplementary/planning-phase-brief.md:62:| 1.8 | Fathom Webhook Receiver Spec | **P** → CC2 builds |
docs/_supplementary/planning-phase-brief.md:177:- Session 24: Integration Specs Batch 1 — Fathom, HubSpot, Gmail, Slack, Notion, DocuSign (3.8)
docs/decisions/2026-05-18-codex-ratification-manifest.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar; actual execution 2026-05-20)
docs/decisions/2026-05-18-codex-ratification-manifest.md:6:**Source:** Master brief §10 (the Codex ratification loop) + §10.6 (Day 7 first ratification run)
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:144:| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:153:**Hard ceiling reached** per master brief §10.3 step 5. Single founder decision (approve the 5-category disposition) unlocks all 6 ratifications via a single Round-5 mechanical-remediation pass.
docs/decisions/2026-05-18-codex-ratification-manifest.md:157:**Round-4 disagreement protocol** (per master brief §10 + Day-8 pattern):
docs/decisions/2026-05-18-codex-ratification-manifest.md:186:| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:205:## §2 — Ratification protocol per master brief §10.3
docs/decisions/2026-05-18-codex-ratification-manifest.md:207:Verbatim from master brief §10.3 (post-Edit 7 path correction):
docs/decisions/2026-05-18-codex-ratification-manifest.md:233:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:243:| Phase | Trigger | Estimated work |
docs/decisions/2026-05-18-codex-ratification-manifest.md:245:| **Build `.codex/ratification/*.md` skills** | Week 0 extension period (concurrent with Q1 design-partner work) | 2-3 person-days. 7 skill files per master brief §10.2; each follows the "RATIFIED / REJECTED with numbered issues" output contract. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:247:| **Disagreement artefacts** | If Codex REJECTS or disagrees with any artefact | `docs/decisions/codex-disagreement-<date>.md` per master brief §10.3 step 4. Founder decides on escalations. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:253:**LANDED TODAY at `0e5b2b4`** — `docs: master brief reconciliation — 11 edits batch-applied`.
docs/decisions/2026-05-18-codex-ratification-manifest.md:258:- `docs/specs/ULTRAPLAN.md` (1 edit)
docs/decisions/2026-05-18-codex-ratification-manifest.md:288:| 9 | `brain-ui-scope.md` | Proposed pending v1.1 phase | Likely Codex ratifies as-is post-Edit 8 atomic correction (master brief §6 Day 3 line 472 + §5.5 now consistent). No founder action needed. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:303:3. **What landed today** (atomic-correction commit `0e5b2b4`; master brief fully reconciled).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:58:**Cost of delay:** Trigger 1 fires 2026-06-03 if no LOI. If LOI lands but advisor isn't engaged, founder has to choose between violating kill-criterion §3.4 or delaying LOI past Trigger 1. Engage now to avoid the forced choice.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:80:**Cost of delay:** Same as D2 — Trigger 1 fires 2026-06-03. If LOI lands before D3 resolves, founder ships v1.0 with D3-A indefinite retention, which is the worst legal posture. Bundle D2 + D3 resolution.
docs/operations/w4-day-20-founder-runbook.md:5:**Trigger 2 runway:** DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 — 20 days
docs/operations/w4-day-20-founder-runbook.md:27:**Why:** Per master brief §10.5, "every Postgres migration touching tenant
docs/operations/w4-day-20-founder-runbook.md:108:1. Diagnostic (5 findings) — burns down Trigger 2 runway first
docs/operations/w4-day-20-founder-runbook.md:112:5. Scribe (5 findings) — Ringover scope question is the only non-mechanical
docs/runbooks/day-4-provisioning.md:15:This runbook is the **reviewable plan** for Day 4 of Week 0 per master brief §6 Day 4. It is **not executed by writing it.** Execution happens in a separate session against a real VPS after this document is reviewed and ratified.
docs/runbooks/day-4-provisioning.md:30:- **Rule 5 (Honest signal before optimistic projection):** §0 surfaces every drift between the master brief and reality (notably: Hetzner has no UK data centre).
docs/runbooks/day-4-provisioning.md:38:### §0.1 — DRIFT: Hetzner has no UK data centre (master brief §6 Day 4 line 477)
docs/runbooks/day-4-provisioning.md:40:**Master brief asserts (line 477 verbatim):** "Hetzner UK VPS provisioned, LUKS-encrypted volume mounted at `/vault/`". This is the single Hetzner reference in the master brief. §10 (Codex ratification loop) does not mention Hetzner or cost targets — earlier drafts of this runbook cited "master brief §10.4" for cost target and Hetzner location; both fabricated. Corrected in citation-audit pass 2026-05-18.
docs/runbooks/day-4-provisioning.md:51:| £20/mo target (Day-4 runbook §1.4 founder-set budget; not specified in master brief) | ✅ well under | ✅ within budget |
docs/runbooks/day-4-provisioning.md:56:**Master-brief correction:** add to the atomic-correction commit manifest (currently 8 edits at end of Week 0). Proposed Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; flag UK-residency as a commercial-conversation gate. (Earlier drafts also referenced "§10.4" as a separate location-naming surface; verified that §10.4 — "What never goes through ratification" — contains no Hetzner or cost-target content. §10.4 component dropped.)
docs/runbooks/day-4-provisioning.md:58:### §0.2 — DRIFT: master brief §6 Day 4 table list says `entity_graph`, ADR-002 Edit 3 split this to `entities` + `entity_links`
docs/runbooks/day-4-provisioning.md:64:**This runbook follows the corrected list.** The atomic correction commit manifest covers the master brief §6 wording.
docs/runbooks/day-4-provisioning.md:75:The runbook applies exactly these. **Do not invent additional phase values during execution** (e.g., `session_start`, `tool_call`, `escalation`) unless a Codex-ratified change to either master brief §8.1 or `sequencing-target.md` §5-A pre-dates the migration. Speculative additions break the schema-before-code rule.
docs/runbooks/day-4-provisioning.md:100:- v1.1+ multi-user: sudo password may be revisited when Hire #1 onboards (master brief Risk #4)
docs/runbooks/day-4-provisioning.md:104:### §0.6 — Single LUKS volume, two bind mounts
docs/runbooks/day-4-provisioning.md:171:| Instance type | CX22 (2 vCPU, 4 GB RAM, 40 GB NVMe) | Fits v1.0 pilot scale per founder-set budget in this section §1.4; master brief does not specify a numeric cost target |
docs/runbooks/day-4-provisioning.md:178:Estimated monthly cost: ~€5/mo VPS + ~€2.40/mo (50 GB volume at €0.0476/GB/mo) ≈ €7.40/mo ≈ £6.40/mo. Well under the £20/mo founder-set budget for v1.0 pilot scale (this section §1.4; master brief does not specify a numeric cost target).
docs/runbooks/day-4-provisioning.md:766:-- Note: NO UPDATE/DELETE grant. Decision log is append-only per master brief §5.7.
docs/runbooks/day-4-provisioning.md:768:-- tenant_eval_sets (per master brief §6 Day 4 line 478; v1.0 placeholder)
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:806:Per `sequencing-target.md` §5-A + master brief §8.1 Change 2 + `current-priorities.md` line 16. **Exactly 5 values. No additions.**
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1090:The vault per ADR-002 + master brief §3.3 is markdown, git-backed. Initial baseline:
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/day-4-provisioning.md:1187:- Add Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; document UK-residency as commercial-conversation gate. (§10.4 reference dropped per 2026-05-18 citation audit; §10.4 is Codex exclusion list, not a Hetzner or cost-target section.)
docs/runbooks/day-4-provisioning.md:1212:3. **§2 location — NBG1 substituted for FSN1:** FSN1 unavailable at provisioning time. Substituted Nuremberg (NBG1) — same Hetzner eu-central zone, identical Schrems II EU jurisdiction (German court orders only), latency to UK ~25-30ms vs FSN1 ~20-25ms (functionally equivalent). **Triggers §11.4 master-brief Edit 9:** master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations". (Earlier drafts of Edit 9 also referenced master brief §10.4; verified during 2026-05-18 citation audit that §10.4 is the Codex exclusion list, not a Hetzner or cost-target section. §10.4 component dropped.)
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:33:// EXISTS in upstream — read-only submodule per master brief §3.1 boundary 1
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/autosend-approval-bridge-spec.md:261:**Founder decision:** schedule for Week 9 (sequential with master brief) OR insert now (parallel with Diagnostic prep).
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:21:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:24:7. **`docs/decisions/v1.0-kill-criterion.md`** §2 Triggers 1-10 (deadline awareness) + §3 (authority structure)
docs/operations/goal-week-3-polish-and-scaffold.md:35:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:54:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:55:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §1 Output contract (one-paragraph screenshot per master brief §1 Rule 1)
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:95:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:96:| Codex Round 4 execution | Master brief §10.6 ratification cadence |
docs/operations/goal-week-3-polish-and-scaffold.md:103:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:106:| Fathom/Fireflies MCP connector | Reserved for W6 |
docs/operations/goal-week-3-polish-and-scaffold.md:293:- ULTRAPLAN §8.1 A2 lines 507-514 (full Janitor spec)
docs/operations/goal-week-3-polish-and-scaffold.md:294:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:296:- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:306:- **§3 Output shape:** day-30 report has 8 sections per ULTRAPLAN line 511 (record counts, dedup pairs, field-completeness deltas, tacit-note coverage, agent vs. consultant attribution, gate-B metric, exception list, executive summary).
docs/operations/goal-week-3-polish-and-scaffold.md:307:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:309:- **§5 Gate B:** ≥15% dedup improvement + ≥10% field-completeness improvement per ULTRAPLAN line 512.
docs/operations/goal-week-3-polish-and-scaffold.md:322:- §1 reads as a complete one-paragraph screenshot per master brief §1 Rule 1
docs/operations/goal-week-3-polish-and-scaffold.md:324:Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`
docs/operations/goal-week-3-polish-and-scaffold.md:326:### DAY 17 — Scribe agent.md scaffold (Step 9)
docs/operations/goal-week-3-polish-and-scaffold.md:331:- ULTRAPLAN §8.1 A3 lines 518-527 (Scribe spec)
docs/operations/goal-week-3-polish-and-scaffold.md:332:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:333:- `bullhorn-integration-path.md` §4.1 (Scribe's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:334:- `vertical-schema.yaml` §3 agent_access_matrix Scribe row
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:341:- **§3 Output shape:** Bullhorn write payload (entity-type-specific JSON) + 1 tacit-note attachment + 1 audit row in decision_log.
docs/operations/goal-week-3-polish-and-scaffold.md:342:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:343:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:346:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:347:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:348:- **§9 Open questions:** 4-6 covering Fathom vs Fireflies first-mover choice, webhook auth, field-extraction model selection, tacit-note length cap.
docs/operations/goal-week-3-polish-and-scaffold.md:352:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:359:- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
docs/operations/goal-week-3-polish-and-scaffold.md:360:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:361:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:381:Commit: `decision(pre-build): agents/recruitment/cash-conductor/agent.md — output contract per ULTRAPLAN §8.1 A4`
docs/operations/goal-week-3-polish-and-scaffold.md:388:- ULTRAPLAN §8.1 A5 lines 547-558 (Sourcing Scout spec)
docs/operations/goal-week-3-polish-and-scaffold.md:389:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:395:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:409:Commit: `decision(pre-build): agents/recruitment/sourcing-scout/agent.md — output contract per ULTRAPLAN §8.1 A5`
docs/operations/goal-week-3-polish-and-scaffold.md:414:- ULTRAPLAN §8.1 A6 lines 561-570 (Concierge spec)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:436:Commit: `decision(pre-build): agents/recruitment/concierge/agent.md — output contract per ULTRAPLAN §8.1 A6`
docs/operations/goal-week-3-polish-and-scaffold.md:450:Triage protocol (master brief §10.3 step 5 hard ceiling: ≤2 round-trips):
docs/operations/goal-week-3-polish-and-scaffold.md:487:| **Master plan citations** | Every architectural claim cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
docs/operations/goal-week-3-polish-and-scaffold.md:502:| Codex Round 4 returns >2 REJECTED on any single artefact | Founder review; do NOT remediate-and-resubmit beyond hard ceiling (per master brief §10.3 step 5); write founder-decision doc; defer |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:531:- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:540:Per master brief §10 + §10.3 step 5 hard ceiling + Day-11 Round-2/3 pattern.
docs/operations/goal-week-3-polish-and-scaffold.md:573:- **Mechanical REJECTIONS (citation drift, line-anchor error, formatting):** Round 4 remediation prompt; expect Round 5 final. Hard ceiling per master brief §10.3 step 5: 2 round-trips MAX. Round 5 RATIFIED → close. Round 5 STILL REJECTED → founder review.
docs/operations/goal-week-3-polish-and-scaffold.md:590:1. **Every claim cites a master plan section.** No bare assertions. Every paragraph either cites the master brief / ULTRAPLAN / sequencing-target / kill-criterion / specific ADR, OR is explicitly stated as "scaffold inference; founder review required."
docs/operations/goal-week-3-polish-and-scaffold.md:591:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:595:6. **Every Gate B target is measurable.** Cite the master plan section or ULTRAPLAN line that establishes the metric. No invented numbers.
docs/operations/goal-week-3-polish-and-scaffold.md:619:  Scribe (W6):            <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:641:  ✓ ULTRAPLAN §8.1 — all 6 agents have output contracts authored
docs/operations/goal-week-3-polish-and-scaffold.md:642:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:645:  ✓ v1.0-kill-criterion.md Trigger 2 — Diagnostic ratified ahead of
docs/operations/goal-week-3-polish-and-scaffold.md:658:    - Scribe build (depends on Bullhorn W + Fathom MCP)
docs/operations/goal-week-3-polish-and-scaffold.md:663:  - <Fathom/Fireflies signup for W6>
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/operations/goal-week-3-polish-and-scaffold.md:702:**Day 20 is the soft target. Day 22 is the hard cutoff** (Trigger 2 fires Day 21 if Diagnostic not ratified). If Day 22 hits without completion, escalate to founder review + scope-cut decision.
docs/decisions/autosend-safety-policy.md:21:**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:83:| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/autosend-safety-policy.md:106:| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
docs/decisions/autosend-safety-policy.md:130:Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:188:      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:585:4. **Cyber insurance.** IFOS Limited needs cyber insurance covering policy miscategorisation events. Quote requests pending; budget impact on v1.0 founder-set cost budget (Day-4 runbook §1.4 — £20/mo for infrastructure at single-tenant pilot scale; master brief does not specify a numeric cost target).
docs/decisions/autosend-safety-policy.md:620:- **Q3 (lookup latency / 71-hour cache lifetime):** ACCEPTED for v1.0. Policy hot-reload deliberately deferred to v1.1+; v1.0 accepts up-to-71-hour delay on policy changes taking effect at agent layer. Material policy changes must wait for next 71-hour boundary (cortextOS context rotation per master brief §2.4 primitive 2) or trigger deliberate cortextOS PTY restart. Operational footgun documented in §4.
docs/decisions/autosend-safety-policy.md:648:**For atomic-correction manifest.** Edit 10 adds the path drift correction (master brief §6 Day 5 line 484-485 → docs/decisions/). Manifest grows from 9 to 10.
docs/decisions/autosend-safety-policy.md:660:**Path drift logged for atomic correction Edit 10:** master brief §6 Day 5 line 484-485 paths to live at `docs/decisions/`.
docs/_supplementary/technical-strategy-v2.md:17:3. **Headless mode + cron is a proven 24/7 pattern.** The `-p` flag runs Claude Code as a one-shot command, no terminal, exit when done. Triggered on a schedule, it behaves like any other cron job. Public example in the wild: *"OpenClaw has 140k GitHub stars. I built the same thing with Claude Code, cron, and ~200 lines of shell scripts."* That's the pattern.
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
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A1 (the 10-step workflow for Diagnostic, lines 495-526).
docs/operations/goal-option-c-diagnostic-end-to-end.md:51:7. **All work committed** as atomic commits with clear messages. Final commit confirms Trigger 2 beat (2026-06-14 deadline cleared 21 days early).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:282:- Trigger 2 deadline cleared (X days early)
docs/operations/goal-option-c-diagnostic-end-to-end.md:297:| **Master plan citations** | Every architectural decision cites master brief / ULTRAPLAN line numbers | grep diff for citation strings |
docs/operations/goal-option-c-diagnostic-end-to-end.md:350:- [ ] Trigger 2 deadline cleared (≥7 days remaining)
docs/operations/goal-option-c-diagnostic-end-to-end.md:357:ULTRAPLAN line 755 sets the bar: "Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."
docs/operations/goal-option-c-diagnostic-end-to-end.md:397:Trigger 2 deadline (2026-06-14): cleared by [N] days
docs/operations/goal-option-c-diagnostic-end-to-end.md:398:Master plan alignment: ULTRAPLAN §8.1 Week-4 milestone hit on Day-13
docs/decisions/brain-ui-scope.md:9:**Reading order:** master brief §5.5 (Brain UI build sequence stages) + ADR-002 (parallel-not-shadow + v1.0 brain build wording correction) + `second-brain-design.md` §3.4 closing paragraph (Brain UI v1.0+ scope) first; then this document end-to-end.
docs/decisions/brain-ui-scope.md:15:Per master brief §5.5 (lines 416-424) after ADR-002 Edit 2 applies in the atomic correction commit, the staged Brain UI build is:
docs/decisions/brain-ui-scope.md:19:- **v1.2:** graph view (cytoscape force-directed, master brief §5.3 line 396).
docs/decisions/brain-ui-scope.md:20:- **v2.0:** second-brain-at-scale features (reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views per master brief §5.5).
docs/decisions/brain-ui-scope.md:34:Three features named in master brief §5.5 (post-ADR-002-Edit-2 wording) + `second-brain-design.md` §3.4. Each feature scoped here without implementation commitment.
docs/decisions/brain-ui-scope.md:51:- No mobile-optimised layout (desktop-first per master brief §5.3 line 397 framework choice).
docs/decisions/brain-ui-scope.md:68:- No graph visualisation (text / list format only — graph view is v1.2 per master brief §5.5).
docs/decisions/brain-ui-scope.md:105:- Tight coupling to cortextOS submodule (`packages/harness/cortextos/dashboard/`) — submodule boundary per master brief §3.1 must hold; the `dashboard-ext` integration point is the cortextOS-blessed extension surface, not a fork.
docs/decisions/brain-ui-scope.md:112:- Needs IFOS-owned auth — WorkOS AuthKit per master brief §5.3 line 401 ("Auth: WorkOS AuthKit (per memory: founder already uses this)").
docs/decisions/brain-ui-scope.md:121:| Auth model | cortextOS dashboard auth | WorkOS AuthKit per master brief §5.3 line 401 |
docs/decisions/brain-ui-scope.md:148:The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/decisions/brain-ui-scope.md:154:**No Brain UI tour in v1.0 sales motion.** Brain UI is a forward-feature, not a v1.0 sales asset. The closing demo is the agent outputs landing in the design partner's existing tools — the wedge per master brief §0 paragraph 1. Brain UI joins the sales asset list at v1.1.
docs/decisions/brain-ui-scope.md:168:Per pre-write check: master brief §6 Day 3 line 472 contains **three drifts** bundled into a single-line rewrite.
docs/decisions/brain-ui-scope.md:170:**Current** (master brief §6 Day 3 line 472 verbatim):
docs/decisions/brain-ui-scope.md:220:| Graph visualisation for backlinks panel (cytoscape force-directed) | v1.2 per master brief §5.5 — explicitly v1.2 milestone, not v1.1 |
docs/runbooks/operational-hygiene-protocol.md:27:- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
docs/runbooks/operational-hygiene-protocol.md:231:**Day-6 lesson (§7 below):** 15 fabricated "master brief §10.4" references propagated across 5 files. The root cause: Day-4 runbook drafting invented a citation that didn't exist, and subsequent artefacts cited the Day-4 runbook citation without re-verifying against master brief.
docs/runbooks/operational-hygiene-protocol.md:234:- When citing master brief, verify against master brief — never against an intermediate artefact's citation of master brief
docs/runbooks/operational-hygiene-protocol.md:262:### §7.1 — Finding: master brief §10.4 fabrication
docs/runbooks/operational-hygiene-protocol.md:264:**Scope:** 15 references to "master brief §10.4" across 5 files, claiming §10.4 contains either (a) a Hetzner UK / FSN1 location reference or (b) a £20/mo cost target.
docs/runbooks/operational-hygiene-protocol.md:266:**Verified ground truth:** master brief §10.4 is "What never goes through ratification" — a 5-bullet list of Codex exclusions (comment-only changes, test fixture additions, documentation typos, build/deps version bumps, anything inside `.agents/`). It contains no Hetzner reference and no cost-target reference.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:274:| `docs/runbooks/day-4-provisioning.md` | 8 | "+§10.4" dropped from Edit 9 scope (was about Hetzner UK); "§10.4 cost target" replaced with "Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target)" |
docs/runbooks/operational-hygiene-protocol.md:276:| `docs/decisions/v1.0-kill-criterion.md` | 3 | Same cost-target replacement for Trigger 6/7 source citations |
docs/runbooks/operational-hygiene-protocol.md:296:- `master brief §3.2 line 155` (canonical vocabulary "candidate, placement, brief") — ✅ verified line 155 matches
docs/runbooks/operational-hygiene-protocol.md:297:- `master brief §5.1 lines 325-329` (vault directory structure) — ✅ verified
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/runbooks/operational-hygiene-protocol.md:301:- `docs/specs/ULTRAPLAN.md` — ✅ verified exists (60KB; ratified canonical doc)
docs/operations/seedlegals-engagement-queries.md:167:- 2026-06-03 (Trigger 1) date approaches; LOI process accelerates without legal infrastructure
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
docs/decisions/v1.0-kill-criterion.md:37:**v1.0 commitments to existing pilots are honoured under original scope.** New v1.0 contracts under rescoped terms. The master brief and Ultraplan are amended by atomic-correction commit; Codex ratifies before v1.0 resumption.
docs/decisions/v1.0-kill-criterion.md:45:### Trigger 1 — DESIGN-PARTNER-BY-WEEK-2 (PAUSE)
docs/decisions/v1.0-kill-criterion.md:47:**Threshold:** No design partner has confirmed pilot intent (signed LOI or equivalent written commitment to pilot in Q3 2026 per master brief §6 Day 7 question 1) by end of Week 2.
docs/decisions/v1.0-kill-criterion.md:49:**Calendar:** Day 0 was 2026-05-13 (Wednesday). Week 0 runs Days 0-7, ending Wednesday 2026-05-20. Week 1 starts Thursday 2026-05-21. Week 2 ends Wednesday 2026-06-03. **Trigger fires end-of-day 2026-06-03 if criterion unmet.**
docs/decisions/v1.0-kill-criterion.md:53:**Source:** Risk #3 in `docs/RISK-REGISTER.md` (escalating status); Day-5 Risk #3 update reflects "zero design partners in pipeline" as of this commit; master brief §6 Day 7 question 1.
docs/decisions/v1.0-kill-criterion.md:61:### Trigger 2 — DIAGNOSTIC-NO-RENDER-W3 (KILL)
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:73:### Trigger 3 — JANITOR-BULLHORN-AUTH-W5 (PIVOT)
docs/decisions/v1.0-kill-criterion.md:89:**Recovery path:** PIVOT is structural; resumption is via rescoped v1.0 under new ATS assumption. Pivoted v1.0 continues with adjusted master brief / Ultraplan; atomic-correction commit lands the rescope.
docs/decisions/v1.0-kill-criterion.md:91:### Trigger 4 — TWO-SCOPE-CUT-ACTIVATIONS (PAUSE)
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:107:### Trigger 5 — AUTOSEND-RED-MISCATEGORISATIONS (PAUSE)
docs/decisions/v1.0-kill-criterion.md:119:### Trigger 6 — UNIT-ECONOMICS-COST-PER-ACTION (PIVOT)
docs/decisions/v1.0-kill-criterion.md:134:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 pilot scale; master brief does not specify a numeric cost target); emerging from v1.0 pilot operations.
docs/decisions/v1.0-kill-criterion.md:140:### Trigger 7 — INFRASTRUCTURE-COST-MONTHLY (PIVOT)
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:156:**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
docs/decisions/v1.0-kill-criterion.md:158:### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
docs/decisions/v1.0-kill-criterion.md:164:**Source:** Master brief §6 Day 5 line 486 — canonical example trigger from master brief.
docs/decisions/v1.0-kill-criterion.md:170:### Trigger 9 — CORTEXOS-PRIMITIVE-CHRONIC-FAILURE (PAUSE)
docs/decisions/v1.0-kill-criterion.md:182:**Unfreeze criterion:** Either (1) cortextOS upstream PR lands the fix (per master brief §3.1 cross-vertical primitive process), OR (2) IFOS vendor-patches via `packages/harness-patches/` per master brief §3.1 fallback path. Unfreeze after **2 consecutive incident-free weeks** (matched to tightened threshold).
docs/decisions/v1.0-kill-criterion.md:186:### Trigger 10 — PII-LEAKAGE-INCIDENT (KILL)
docs/decisions/v1.0-kill-criterion.md:212:- For all KILL actions: founder decides; activates within 24h (within 4h for Trigger 10 PII per §3.5 emergency authority).
docs/decisions/v1.0-kill-criterion.md:224:- **Trigger 6 (Unit economics):** founder decides PIVOT direction (cheaper model tier, reduced agent frequency, etc.) → consults Jack on pricing implications before locking → updates Ultraplan pricing plan.
docs/decisions/v1.0-kill-criterion.md:225:- **Trigger 7 (Infrastructure cost):** founder decides PIVOT direction (self-host alternative, provider switch, architecture compaction) → consults Jack on commercial impact before locking.
docs/decisions/v1.0-kill-criterion.md:226:- **Trigger 1 (Design partner) PAUSE → KILL escalation:** if PAUSE extends 4 weeks without signed LOI, founder consults Jack on whether to escalate to KILL (commercial assessment of pipeline) or extend PAUSE.
docs/decisions/v1.0-kill-criterion.md:227:- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
docs/decisions/v1.0-kill-criterion.md:237:### §3.5 — Emergency authority (Trigger 10 PII-LEAKAGE-INCIDENT specifically)
docs/decisions/v1.0-kill-criterion.md:239:Trigger 10 escalates regulatory-clock-driven actions. UK GDPR Art. 33 mandates ICO notification within 72 hours of discovery; multi-person consultation cannot delay this clock.
docs/decisions/v1.0-kill-criterion.md:267:| T+0 (trigger detected) | Trigger detector (Claude Code, IFOS oncall, or Founder) writes incident report to `.agents/incidents/<date>-<trigger-id>.md`. Report includes: trigger name, threshold details, evidence (logs/queries/screenshots), preliminary KILL/PAUSE/PIVOT recommendation. |
docs/decisions/v1.0-kill-criterion.md:306:1. Rescope plan replaces affected slices of master brief and Ultraplan. New atomic-correction commit lands the rescope edits (separate from the existing 10-edit atomic-correction manifest — pivot is a wholly new manifest event).
docs/decisions/v1.0-kill-criterion.md:316:   - Trigger that activated KILL
docs/decisions/v1.0-kill-criterion.md:322:4. v1.1 — if launched — is a wholly new initiative under different premises. Not a continuation of v1.0. Has its own master brief, Ultraplan, kill criterion.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:338:- The vertical assumption: UK recruitment agencies (per master brief §0 + Product Spec)
docs/decisions/v1.0-kill-criterion.md:345:v1.1 begins when v1.0 is operationally stable with ≥1 pilot operational. v1.1 scope per master brief §9 build sequence + Product Spec:
docs/decisions/v1.0-kill-criterion.md:350:- Adds AgentMail integration (Inbound Triage only) per master brief §3.2
docs/decisions/v1.0-kill-criterion.md:371:**For Week 0 remaining.** Day 6 (vertical schema v0.1) and Day 7 (single-sentence test + Codex run) do not depend on this criterion directly. Day 7's question 1 (design partner LOI) is the structural Week-0 gate; this criterion's Trigger 1 (DESIGN-PARTNER-BY-WEEK-2) explicitly references that gap.
docs/decisions/v1.0-kill-criterion.md:373:**For Week 1-2.** All Week-1 work is conducted with awareness that Trigger 1 fires 2026-06-03 if no LOI (per §1 calendar — Wednesday end-of-Week-2). Founder allocates time accordingly: design-partner acquisition is a Week-1 sub-track, not an afterthought.
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/v1.0-kill-criterion.md:377:**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
docs/decisions/v1.0-kill-criterion.md:381:1. Trigger thresholds — are they measurable, achievable, honest signals?
docs/decisions/v1.0-kill-criterion.md:399:**Path drift logged for atomic correction Edit 10:** master brief §6 Day 5 line 486 path to live at `docs/decisions/`.
docs/operations/codex-ratification-execution-plan.md:5:**Source artefacts:** master brief §10 (the loop) + `docs/decisions/2026-05-18-codex-ratification-manifest.md` (the queue) + this plan (the how).
docs/operations/codex-ratification-execution-plan.md:10:## §1 — Why this loop matters (re-statement from master brief §10.1)
docs/operations/codex-ratification-execution-plan.md:78:### Skill shape (per master brief §10.2 last paragraph)
docs/operations/codex-ratification-execution-plan.md:93:## Five-rule pass (master brief §1)
docs/operations/codex-ratification-execution-plan.md:100:## Four-boundary pass (master brief §3)
docs/operations/codex-ratification-execution-plan.md:204:Per master brief §10.6 — mean cost is 20-30 min per artefact including the round-trip. Cluster batching reduces context-switching cost.
docs/operations/codex-ratification-execution-plan.md:260:Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:
docs/operations/codex-ratification-execution-plan.md:317:Per master brief §10.3 step 5:
docs/operations/codex-ratification-execution-plan.md:338:4. **Spec drift** — Codex reviews an artefact that's based on a now-stale version of the master brief. Disagreement → update the master brief OR the artefact; re-review. Moderately expensive.
docs/operations/codex-ratification-execution-plan.md:340:**Worth tracking for retro:** category mix on first run. If category 1 dominates, the master brief needs sharpening. If category 4 dominates, the atomic-correction discipline is failing.
docs/operations/codex-ratification-execution-plan.md:348:Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:360:| Phase | Cluster | Trigger |
docs/operations/codex-ratification-execution-plan.md:390:7. **Master brief §10.6 timeline updated** with actual cost vs estimate. Founder-facing artefact.
docs/operations/codex-ratification-execution-plan.md:427:- **Multi-model ratification (e.g., adding Gemini)** — v1.0 is Claude + Codex per master brief §10. Multi-model is v2.0+ if signal justifies.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
docs/runbooks/tenant-lifecycle.md:44:### Trigger
docs/runbooks/tenant-lifecycle.md:179:### Trigger
docs/runbooks/tenant-lifecycle.md:213:### Trigger
docs/runbooks/tenant-lifecycle.md:283:### Trigger
docs/runbooks/tenant-lifecycle.md:363:  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
docs/runbooks/tenant-lifecycle.md:382:| # | Gap | Severity | Resolution path | Trigger |
docs/operations/codex-ratification-guide.md:30:- Citation drift — `master brief §10.4` quoted 15 times in one batch, all wrong (real past incident)
docs/operations/codex-ratification-guide.md:200:2. Citation §10.4 incorrect — master brief §10.4 is the Codex exclusion list, not the cost target the ADR cites. Past pattern of 15 fabricated §10.4 references; verify line numbers before citing. Citation: ADR-001 line 47.
docs/operations/codex-ratification-guide.md:373:The disagreement doc itself becomes a ratifiable artefact in a future round (master brief §10.5 recursive ratification). That's by design — the disagreement IS the signal.
docs/operations/codex-ratification-guide.md:516:- **Possibly updated master brief** — Codex may flag spec drifts requiring atomic correction
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (today): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`; Concierge Status flip Proposed → Accepted requires ADR-007 RATIFIED. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + ADR-007 RATIFIED + W10 build slice.
agents/recruitment/concierge/agent.md:7:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:8:**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
agents/recruitment/concierge/agent.md:9:**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
agents/recruitment/concierge/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/concierge/agent.md:17:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is per ULTRAPLAN A6 line 566 a Gate A hard-fail (verbatim "every lifecycle event has a draft generated within 30 minutes"). v0.3 Concierge agent.md disposition (per bilateral founder authorization): the per-draft 30-min check is interpreted as a Gate B leading metric (90% target) rather than per-draft hard-fail to avoid blocking legitimate polling-fallback delays. **This is a documented deviation from ULTRAPLAN A6 line 566 verbatim wording** — to be ratified separately via a future Concierge-Gate-A ADR (analogous to ADR-006 for Diagnostic) before Concierge Status flips Proposed → Accepted. Until that ADR ratifies, agent.md's Gate B framing of the 30-min SLA is a documented disposition, not an upstream-spec match. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts (both per ULTRAPLAN A6 line 567); + ≥90% 30-min SLA hit rate (per ADR-007 — the 90% threshold is NOT in ULTRAPLAN line 567; it is the Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail, introduced by ADR-007 and amended into ULTRAPLAN line 567 in the same commit). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:40:Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha — see Step 1 polling fallback.
agents/recruitment/concierge/agent.md:77:| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) — respectful, specific, leaves door open |
agents/recruitment/concierge/agent.md:117:15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/concierge/agent.md:167:     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
agents/recruitment/concierge/agent.md:215:   → per ULTRAPLAN A6 line 566 verbatim "every lifecycle event has a draft
agents/recruitment/concierge/agent.md:276:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:285:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
agents/recruitment/concierge/agent.md:293:Per ULTRAPLAN A6 line 567 + ADR-007 amendment: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate"**. The third metric is ADR-007's Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail (NOT in original line 567 wording).
agents/recruitment/concierge/agent.md:296:- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%. (per ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:297:- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`. (per ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:298:- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:308:| Code | Trigger | Severity | Routing |
agents/recruitment/concierge/agent.md:343:  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §gotchas (line numbers vary; see live file); demand specificity)
agents/recruitment/concierge/agent.md:355:- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §gotchas (line numbers vary; see live file) explicitly names rejection voice as the hardest case)
agents/recruitment/concierge/agent.md:357:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/concierge/agent.md:369:| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
agents/recruitment/concierge/agent.md:414:### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)
agents/recruitment/concierge/agent.md:429:- **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes the documented deviation from ULTRAPLAN A6 line 566 wording. ADR drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` (Day 20 W4 bilateral pass); ratifies via `.codex/ratification/review-architecture-decision.md` skill. Until RATIFIED, agent.md's Gate B framing of the 30-min SLA is documented disposition only.
docs/runbooks/pii-purge-operational-pattern.md:195:| # | Gap | Trigger |
docs/operations/codex-round-2-handoff.md:82:| 11 | `docs/decisions/v1.0-kill-criterion.md` | Trigger 1 date + Trigger 2 CLI + Trigger 4 threshold | RATIFY (all three fixed) |
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:200:ratification per master brief §10.5. Decide whether Claude's counter-argument
docs/operations/codex-round-2-handoff.md:292:Hard ceiling: 2 round-trips (master brief §10.3 step 5). After Round 2, no Round 3 — escalate to founder for explicit decision.
docs/operations/codex-round-2-handoff.md:332:Any Round-2 REJECTED items get their own row in the manifest queue updated to "REJECTED→ROUND-3-pending OR founder-escalated". Per §10.3 master brief: no Round 3 until founder decides.
docs/operations/codex-round-2-handoff.md:373:Per master brief §10.6 + execution plan §5:
docs/operations/codex-round-2-handoff.md:406:Manifest queue position: this protocol document itself joins the queue as a Round-3 candidate (recursive ratification per master brief §10.5).
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/operations/codex-round-2-remediation-prompt.md:213:  Three distinct gates govern Bullhorn-touching work, in temporal order:
docs/operations/codex-round-2-remediation-prompt.md:215:  | Gate | Trigger | Status |
docs/operations/codex-round-2-remediation-prompt.md:407:Per master brief §10.3 step 5: Round 3 is the LAST automated round.
docs/operations/codex-round-2-remediation-prompt.md:433:     Per master brief §10.3, this is the last automated round. Confirm
docs/operations/codex-round-2-remediation-prompt.md:525:  Round 3 ratification (≤2 round-trips per master brief §10.3): 10 items
docs/operations/codex-round-2-remediation-prompt.md:634:**Round 3 ratification:** 10 corrected items re-ratified against appropriate skills. Hard-ceiling enforced per master brief §10.3 step 5.
docs/build-brief/00-MASTER-BRIEF.md:12:3. `docs/specs/ULTRAPLAN.md` — how, in what order
docs/build-brief/00-MASTER-BRIEF.md:15:If anything in `docs/build-pack/` conflicts with this brief, **this brief wins**. The build pack stays in-tree as historical record; the master brief is operative.
docs/build-brief/00-MASTER-BRIEF.md:238:git commit -m "chore: reconcile scaffold against master brief; vendor cortextos@${HARNESS_SHA:0:7}"
docs/build-brief/00-MASTER-BRIEF.md:252:cp "$SRCDIR/intelforce-os-ultraplan.md"                        docs/specs/ULTRAPLAN.md
docs/build-brief/00-MASTER-BRIEF.md:260:git commit -m "docs: import authoritative specs + master brief"
docs/build-brief/00-MASTER-BRIEF.md:311:│       │   ├── calls/            ← from Fathom/Fireflies transcripts
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:597:| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:762:### 10.6 The ratification timeline
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/build-brief/00-MASTER-BRIEF.md:852:Drop this verbatim at `~/code/CortexOS/CLAUDE.md`. It supersedes the existing CLAUDE.md (which keeps the path table and red lines, but defers all build-pack references to this master brief).
docs/build-brief/00-MASTER-BRIEF.md:867:start. The build pack at `docs/_archive-build-pack/` is historical; the master brief wins on
docs/build-brief/00-MASTER-BRIEF.md:907:merge. See master brief §10.
docs/build-brief/00-MASTER-BRIEF.md:910:1. Read this file, then master brief §1, §3, §6, §8, §10
docs/build-brief/00-MASTER-BRIEF.md:922:1. Check the master brief §-references first
docs/build-brief/00-MASTER-BRIEF.md:931:- Don't add features without a corresponding slice in the master brief
docs/build-brief/00-MASTER-BRIEF.md:933:- Don't relitigate the master brief without writing the disagreement to `docs/decisions/`
docs/build-brief/00-MASTER-BRIEF.md:948:> Read `CLAUDE.md`, then `docs/build-brief/00-MASTER-BRIEF.md` in full. Then read `docs/specs/PRODUCT-SPEC.md` §0–§4 and §10 (the single-sentence list), and `docs/specs/ULTRAPLAN.md` §1, §3, §4, §9, §11. Skim `docs/architecture/PATTERN-REFERENCE.md`.
docs/build-brief/00-MASTER-BRIEF.md:998:*End of master brief. Drop at `docs/build-brief/00-MASTER-BRIEF.md`. Re-read §1, §3, §6, and §10 weekly.*

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,230p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '510,530p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   101	  concierge_approval_routed:
   102	    tier: green
   103	    agent: concierge
   104	    reason: "Internal audit row recorded by Concierge cycle.sh Step 11 when an approval is routed via the autosend-bridge (per Founder Decision D1 path A/B/C). Payload carries d1_path + bridge_target (approval_id or vault path). Not an external send; the actual send is a downstream orange-tier action_type with its own row."
   105	    irreversible: false
   106	
   107	  cash_conductor_run_complete:
   108	    tier: green
   109	    agent: cash-conductor
   110	    reason: "Internal run-complete status marker; no external comms"
   111	    irreversible: false
   112	
   113	  consultant_feedback:
   114	    tier: green
   115	    agent: all
   116	    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
   117	    irreversible: false
   118	
   119	  validate_gate_a_fail:
   120	    tier: green
   121	    agent: all
   122	    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
   123	    irreversible: false
   124	
   125	  diagnostic_input_invalid:
   126	    tier: green
   127	    agent: diagnostic
   128	    reason: "Internal audit row written by cycle.sh Step 1 when firm-name validation fails. Carries ESC_INPUT_VALIDATION_FAIL payload; just the audit-row write, not external send."
   129	    irreversible: false
   130	
   131	  diagnostic_generator_empty:
   132	    tier: green
   133	    agent: diagnostic
   134	    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
   135	    irreversible: false
   136	
   137	  linkedin_cache_purge_fail:
   138	    tier: green
   139	    agent: all
   140	    reason: "Internal audit row written by cleanup.sh when the transient LinkedIn /tmp cache cannot be purged (defense-in-depth per LinkedIn ToS gotcha; tools.yaml sets ttl=0 but explicit purge can still fail). Operator must manually verify cache cleared."
   141	    irreversible: false
   142	
   143	  diagnostic_cleanup:
   144	    tier: green
   145	    agent: diagnostic
   146	    reason: "Internal audit row written by cleanup.sh at end of normal-completion run. Records cache-purge status + workspace cleanup; no external comms."
   147	    irreversible: false
   148	
   149	  # ───────────────────────────────────────────────────────────
   150	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   151	  # ───────────────────────────────────────────────────────────
   152	
   153	  bullhorn_candidate_dedupe:
   154	    tier: yellow
   155	    agent: janitor
   156	    sample_rate: 10
   157	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   158	    irreversible: false
   159	
   160	  bullhorn_field_backfill:
   161	    tier: yellow
   162	    agent: janitor
   163	    sample_rate: 10
   164	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   165	    irreversible: false
   166	
   167	  bullhorn_note_attach:
   168	    tier: yellow
   169	    agent: janitor
   170	    sample_rate: 20
   171	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   172	    irreversible: false
   173	
   174	  bullhorn_note_append_summary:
   175	    tier: yellow
   176	    agent: scribe
   177	    sample_rate: 20
   178	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   179	    irreversible: false
   180	
   181	  linkedin_connection_request:
   182	    tier: yellow
   183	    agent: sourcing-scout
   184	    sample_rate: 5
   185	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   186	    irreversible: true
   187	
   188	  xero_reminder_draft_internal:
   189	    tier: yellow
   190	    agent: cash-conductor
   191	    sample_rate: 10
   192	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   193	    irreversible: false
   194	
   195	  bullhorn_note_draft_internal:
   196	    tier: yellow
   197	    agent: concierge
   198	    sample_rate: 10
   199	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   200	    irreversible: false
   201	
   202	  bullhorn_scribe_field_write:
   203	    tier: yellow
   204	    agent: scribe
   205	    sample_rate: 10
   206	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   207	    irreversible: false
   208	
   209	  accounting_reconciliation_write:
   210	    tier: yellow
   211	    agent: cash-conductor
   212	    sample_rate: 10
   213	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   214	    irreversible: false
   215	
   216	  concierge_email_draft:
   217	    tier: yellow
   218	    agent: concierge
   219	    sample_rate: 20
   220	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   221	    irreversible: false
   222	
   223	  # ───────────────────────────────────────────────────────────
   224	  # ORANGE — per-action human approval (10 action_types)
   225	  # ───────────────────────────────────────────────────────────
   226	
   227	  bullhorn_note_customer_visible:
   228	    tier: orange
   229	    agent: concierge
   230	    timeout: PT4H

 succeeded in 0ms:
   510	- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
   511	- **Gate B target:** day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement
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

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '580,605p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   580	- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
   581	- `ESC_BULLHORN_AUTH` — OAuth token expired/revoked
   582	- `ESC_DUPLICATE_DETECTED` — high-confidence dedup needs human review
   583	- `ESC_JSL_RED_FLAG` — Supply Chain Auditor detected red flag
   584	- `ESC_BRIEF_AMBIGUITY` — Brief Decoder cannot confidently shortlist
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '90,455p'" in /Users/madsadmin/code/CortexOS
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
   201	#### `ESC_VAULT_CONCURRENCY`
   202	- **Severity:** warn
   203	- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
   204	- **Phase:** `gating_failed`
   205	- **Routing:** `operator_chat_id`
   206	- **Payload fields:** `vault_path`, `anomaly_class`, `freeform_reason`
   207	- **Note:** Catch-all; specific codes preferred. New patterns may justify a new code.
   208	
   209	#### `ESC_VAULT_RENAME_RACE`
   210	- **Severity:** warn
   211	- **Trigger:** Rename operation raced with another writer; per vault-concurrency §5
   212	- **Phase:** `gating_failed`
   213	- **Routing:** `operator_chat_id`
   214	- **Payload fields:** `from_path`, `to_path`, `racing_writer_pid`
   215	
   216	#### `ESC_CORTEXTOS_RESTART_REQUESTED`
   217	- **Severity:** info
   218	- **Trigger:** Agent self-requested restart per primitive 6 (`cortextos-ifos bus self-restart`) — typically post-degraded-mode recovery, post-context-overflow handoff
   219	- **Phase:** `agent_handoff`
   220	- **Routing:** log-only
   221	- **Payload fields:** `reason`, `next_session_token`
   222	
   223	#### `ESC_CORTEXTOS_HANDOFF`
   224	- **Severity:** info
   225	- **Trigger:** Context approaching `ctx_handoff_threshold` (default 80%); agent saves state and triggers fresh-session takeover per primitive 1+2 context-rotation
   226	- **Phase:** `agent_handoff`
   227	- **Routing:** log-only
   228	- **Payload fields:** `from_session_id`, `context_pct`, `handoff_summary_path`
   229	
   230	#### `ESC_CORTEXTOS_DEGRADED`
   231	- **Severity:** warn
   232	- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
   233	- **Phase:** `gating_failed`
   234	- **Routing:** `operator_chat_id`
   235	- **Payload fields:** `reason` (e.g. `bullhorn_auth_failed`, `mcp_connector_unreachable`), `degraded_since`, `recovery_condition`
   236	
   237	### 2.7 — Upstream provider auth (8 codes)
   238	Source: derived from v1.0 agent.md adapter references (Bullhorn, Reed, CV-Library, LinkedIn, Gmail, Outlook/MS Graph, Xero, Open Banking)
   239	
   240	#### `ESC_REED_AUTH`
   241	- **Severity:** **blocking** — agent enters degraded mode (cached search results only)
   242	- **Trigger:** Reed jobs-board API OAuth token refresh failed twice OR REST call returned 401 indefinitely
   243	- **Phase:** `gating_failed`
   244	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   245	- **Payload fields:** `failure_type` (`refresh_failed` | `revoked_401`), `last_attempt_at`, `consecutive_failures`
   246	- **Recovery:** founder rotates Reed API key via Reed admin → `_secrets.env` reload
   247	
   248	#### `ESC_CVLIBRARY_AUTH`
   249	- **Severity:** **blocking** — agent degraded (cached search only)
   250	- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
   251	- **Phase:** `gating_failed`
   252	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   253	- **Payload fields:** `failure_type`, `last_attempt_at`, `consecutive_failures`
   254	- **Recovery:** founder rotates CV-Library credentials
   255	
   256	#### `ESC_LINKEDIN_AUTH`
   257	- **Severity:** **blocking** — Sourcing Scout enters degraded mode (no profile fetches; cached only)
   258	- **Trigger:** LinkedIn session cookie / OAuth token revoked or expired (LinkedIn has aggressive anti-bot session invalidation)
   259	- **Phase:** `gating_failed`
   260	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   261	- **Payload fields:** `failure_type` (`session_expired` | `bot_detected_999` | `revoked_401`), `last_attempt_at`
   262	- **Recovery:** founder reauthenticates LinkedIn via Sourcing Scout admin flow
   263	
   264	#### `ESC_GMAIL_AUTH`
   265	- **Severity:** **blocking** — Concierge cannot send candidate emails; falls back to draft-only
   266	- **Trigger:** Google Workspace OAuth token refresh failed; Gmail send returns 401
   267	- **Phase:** `gating_failed`
   268	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   269	- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
   270	- **Recovery:** founder reauthenticates Google Workspace OAuth
   271	
   272	#### `ESC_MS_GRAPH_AUTH`
   273	- **Severity:** **blocking** — Concierge Outlook send disabled; drafts-only
   274	- **Trigger:** Microsoft Graph OAuth refresh failed; Outlook sendMail returns 401
   275	- **Phase:** `gating_failed`
   276	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   277	- **Payload fields:** `failure_type`, `last_attempt_at`, `affected_tenant_slug`
   278	- **Recovery:** founder reauthenticates MS Graph OAuth
   279	
   280	#### `ESC_ACCOUNTING_AUTH`
   281	- **Severity:** **blocking** — Cash Conductor degraded (read-only Xero queries from cache; no reminders sent)
   282	- **Trigger:** Xero (or alt accounting provider) OAuth token refresh failed; API returns 401
   283	- **Phase:** `gating_failed`
   284	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   285	- **Payload fields:** `provider` (`xero` | `quickbooks` | `sage` | `freeagent`), `failure_type`, `last_attempt_at`
   286	- **Recovery:** founder reauthenticates accounting OAuth
   287	
   288	#### `ESC_OPEN_BANKING_AUTH`
   289	- **Severity:** **blocking** — Cash Conductor cannot fetch latest bank-feed; falls back to last-known balance
   290	- **Trigger:** Open Banking PSD2 consent expired (90-day mandatory reauth) OR token refresh failed
   291	- **Phase:** `gating_failed`
   292	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   293	- **Payload fields:** `failure_type` (`consent_expired_90d` | `refresh_failed`), `consent_expires_at`, `bank_provider`
   294	- **Recovery:** founder completes Open Banking SCA reauthentication flow
   295	
   296	#### `ESC_OPEN_BANKING_TOKEN_AGING`
   297	- **Severity:** staged — info → warn → blocking as expiry approaches (per Cash Conductor agent.md §6)
   298	- **Trigger:** Open Banking PSD2 consent approaching 90-day expiry. Three stages:
   299	  - **≤30 days remaining:** info — non-urgent operator awareness; nightly health check emits this
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '1,430p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Scribe — the data spine
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
     5	**Date:** 2026-05-24.
     6	**Author:** Founder (Maddox) + Claude Code.
     7	**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
     8	**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
     9	**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
    10	
    11	---
    12	
    13	## §1 — Output contract (one-paragraph screenshot)
    14	
    15	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    16	
    17	> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
    18	
    19	---
    20	
    21	## §2 — Invocation surface
    22	
    23	### Webhook (v1.0 primary path)
    24	
    25	```http
    26	POST https://<tenant>.ifos.app/agents/scribe/webhook
    27	Authorization: Bearer <fathom-or-fireflies-shared-secret>
    28	Content-Type: application/json
    29	
    30	{
    31	  "provider": "fathom" | "fireflies",        // v1.0
    32	  // "ringover" added in v1.1+ — not in v0 build per §8 dependencies
    33	  "call_id": "<provider-call-id>",
    34	  "transcript_url": "<provider-transcript-url>",
    35	  "duration_seconds": 1234,
    36	  "participants": [...],
    37	  "metadata": {...}
    38	}
    39	```
    40	
    41	v1.0 supports Fathom (HMAC-SHA256 signed) and Fireflies (bearer token) providers; auth handled per-provider in `tools.yaml` capability declarations. Ringover (OAuth-protected) is deferred to v1.1+ — not in the v0 build dependencies and not registered in v1.0 `tools.yaml`.
    42	
    43	### Manual trigger (v1.0 — debugging / replay)
    44	
    45	```bash
    46	ifosctl scribe replay --tenant <slug> --call-id <provider-call-id>
    47	```
    48	
    49	Useful when a webhook was missed or a transcript needs reprocessing after taxonomy update.
    50	
    51	### v1.1+ surfaces (deferred)
    52	
    53	- Telegram command (`@ifos_bot scribe replay <call-id>`)
    54	- Brain UI per-call "Reprocess" button
    55	- Brain UI "Confidence audit" view showing extraction confidence histograms
    56	
    57	---
    58	
    59	## §3 — Output shape
    60	
    61	Two outputs per webhook. Both write atomically (one transaction); rollback on either failure.
    62	
    63	### Output 1 — Bullhorn structured-field writes (≥3 per call)
    64	
    65	Bullhorn entity inferred from call participants + tenant Bullhorn lookup:
    66	- 1:1 call with candidate → Candidate entity update
    67	- 1:1 call with client contact → Contact entity update
    68	- Briefing call (consultant + client) → Brief entity update
    69	- Placement check-in (consultant + placed candidate) → Placement entity update
    70	- Opportunity scoping (consultant + prospect) → Opportunity entity update (NOTE: Bullhorn endpoint A3 row covers Candidate / ClientCorporation / JobOrder / Note / Placement only at v1.0; Opportunity writes are to IFOS-cached Postgres entity rows for the v0.3-added fields headcount_growth_signal_text + hiring_velocity_band + decision_window_text per v0.3 supplement §1, NOT direct Bullhorn endpoint calls)
    71	
    72	Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):
    73	
    74	| Entity | Canonical fields (schema-verified) |
    75	|---|---|
    76	| Candidate | `location`, `current_role`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (v0.3; enum per supplement §1), `key_skills` (v0.3; list) |
    77	| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
    78	| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
    79	| Placement | `start_date`, `placement_status` (v0.3), `week_1_status_vault_path` (v0.3; vault pointer, not narrative), `satisfaction_signal` (v0.3) |
    80	| Opportunity | `headcount_growth_signal_text` (v0.3), `hiring_velocity_band` (v0.3), `decision_window_text` (v0.3) |
    81	
    82	Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
    83	
    84	Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
    85	
    86	### Output 2 — Tacit-note Markdown attachment
    87	
    88	One Markdown note per call, attached to the same Bullhorn entity as Output 1 via `POST /Note`. Structure:
    89	
    90	```markdown
    91	# Tacit notes — <Call-context-summary>
    92	**Date:** <ISO-date>  **Duration:** <N> min  **Participants:** <list>
    93	
    94	## Things observed that don't fit a structured field
    95	
    96	- <Observation 1 — bullet, 1-2 sentences, with transcript timestamp [MM:SS]>
    97	- <Observation 2 — ...>
    98	- ...
    99	
   100	## Tone signals
   101	
   102	- <Tone signal 1 — e.g., "client sounded frustrated about Bullhorn data quality">
   103	- <Tone signal 2 — ...>
   104	
   105	## Open questions for consultant follow-up
   106	
   107	- <Open question 1>
   108	- <Open question 2>
   109	```
   110	
   111	Length cap: 800 words. Voice-classified (≥0.75); falls back to "needs consultant review" placeholder if classifier persistently fails (ESC_VOICE_DRIFT).
   112	
   113	Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
   114	1. Relationship signal (client warmth, candidate enthusiasm, prior friction)
   115	2. Process friction (consultant complaint, tool gap, time waste)
   116	3. Competitive intel (mentions of competitor agencies / candidates working with others)
   117	4. Pricing/budget signal (off-record indications of room or constraint)
   118	5. Decision-process insight (who actually decides; coffee-machine politics)
   119	6. Calendar / availability nuance (vacation, life events affecting timeline)
   120	7. Cultural fit observation (working style, communication preferences)
   121	8. Risk flag (legal, IR35, compliance, reference concerns)
   122	
   123	v1.1+: expand taxonomy based on first 3 pilot tenants' patterns.
   124	
   125	---
   126	
   127	## §4 — Workflow
   128	
   129	10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   130	
   131	```
   132	0. Session start (webhook handler)
   133	   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice
   134	     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
   135	   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
   136	
   137	1. Webhook signature verification
   138	   → per-provider HMAC / bearer / OAuth check
   139	   → ESC_INPUT_VALIDATION_FAIL on signature mismatch; reject with 401
   140	   → record provider + call_id in trigger payload
   141	   → hh_decision_output("webhook_verified", "call:<id>", "provider:<name>")
   142	
   143	2. Bullhorn auth refresh
   144	   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
   145	   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
   146	   → hh_decision_output("bullhorn_auth_refreshed", "tenant:<slug>", "result:ok")
   147	
   148	3. Transcript fetch
   149	   → provider-specific: fathom.get_transcript(call_id) | fireflies.get(...)
   150	   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
   151	   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
   152	   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
   153	   → hh_decision_output("transcript_fetched", "call:<id>",
   154	     "provider:<name>; bytes:<N>; tmp_path:/tmp/scribe-<tenant>-<call_id>.txt")
   155	
   156	4. Participant + entity inference
   157	   → match transcript participants against Bullhorn contacts + candidates
   158	     + consultant accounts (per tenant config)
   159	   → infer call context (1:1 vs briefing vs placement vs opportunity)
   160	   → resolve target Bullhorn entity (bullhorn_id + entity_type per
   161	     vertical-schema.yaml canonical id field)
   162	   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
   163	     a Scribe run with no resolvable target cannot produce structured writes)
   164	   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>", confidence)
   165	
   166	5. LLM field extraction
   167	   → prompt = (transcript + entity context + vertical-schema entity field list
   168	     + 3 voice-corpus examples)
   169	   → output = JSON with per-field confidence scores
   170	   → discard fields confidence <0.6 (per Gate A)
   171	   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
   172	   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
   173	     "<N> fields ≥0.6 confidence")
   174	
   175	6. LLM tacit-note generation
   176	   → prompt = (transcript + 8-category taxonomy + 3 voice-corpus examples
   177	     + tone-rule filter)
   178	   → output = Markdown narrative per §3 Output 2 shape
   179	   → voice classifier scores against tenant style guide
   180	   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
   181	   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md
   182	   → hh_decision_output("tacit_note_rendered", "<vault_path>",
   183	     "voice_score:<N>; words:<N>")
   184	
   185	7. Field-extraction validation against vertical-schema
   186	   → verify each extracted field name exists in target entity schema
   187	   → verify each extracted value passes per-field type/range checks
   188	   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION
   189	     per catalogue line 163 — vertical-schema field-constraint violation at write time)
   190	   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
   191	     "<N> valid of <M> extracted; dropped:<N-invalid>")
   192	   → on Gate A failure (<3 valid): hh_decision_action("validate_gate_a_fail",
   193	     "<entity_type>:<bullhorn_id>", payload_hash,
   194	     "ESC_SCHEMA_VIOLATION; agent_name:scribe; valid:<N>") and exit 1
   195	     (validate_gate_a_fail is the canonical green-tier action_type registered
   196	     in agents/_shared/autosend-policy.yaml line 113; agent:all; Scribe uses
   197	     the shared signature with agent_name in payload to distinguish.)
   198	
   199	8. Bullhorn write — structured fields (yellow tier)
   200	   → PATCH /<EntityType>/<id> with field map
   201	   → atomic transaction; rollback on Bullhorn 4xx/5xx
   202	   → on success: hh_decision_action("bullhorn_scribe_field_write",
   203	     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
   204	   → on failure: ESC_BULLHORN_WRITE_FAIL; do NOT proceed to Step 9
   205	
   206	9. Bullhorn write — tacit-note attachment (yellow tier)
   207	   → POST /Note linked to entity from Step 4 (mirror of vault artefact from Step 6)
   208	   → on success: hh_decision_action("bullhorn_note_append_summary",
   209	     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
   210	   → on failure: rollback Step 8 (best-effort PATCH /<EntityType>/<id>
   211	     reversing the field changes); ESC_BULLHORN_WRITE_FAIL
   212	
   213	10. Session close + SLA metric
   214	   → compute elapsed_seconds from webhook receipt
   215	   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
   216	     10 min". Catalogue ESC_SCRIBE_SLA_MISS triggers (line 443): "summary-render
   217	     >30 min OR note-attach >1h after call end". The two thresholds are
   218	     different scopes — master brief 10-min is the product UX promise; catalogue
   219	     30-min/1h is the alerting threshold (less false alarms).
   220	   → if elapsed > 3600 (1h): fire ESC_SCRIBE_SLA_MISS with `sla_type=note_attach` (per catalogue)
   221	   → if elapsed > 1800 (30 min): fire ESC_SCRIBE_SLA_MISS with `sla_type=summary_render` (per catalogue)
   222	   → if elapsed > 600 (10 min) but ≤ 1800: NO ESC fire — recorded as Gate B
   223	     "10-min miss" in the day-30 report aggregation; counts against Gate B 90% target
   224	   → if elapsed > 300 (5 min) but ≤ 600: info-level (still under product promise)
   225	   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
   226	   → exit code 0
   227	```
   228	
   229	---
   230	
   231	## §5 — Gates
   232	
   233	### Gate A — validate.sh (hard-fail before action)
   234	
   235	Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:
   236	
   237	- Webhook signature valid per provider (Step 1)
   238	- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
   239	- 1 tacit-note generated with voice classifier ≥0.75
   240	- Field names exist in target entity per vertical-schema.yaml
   241	- Per-field type + range validation passes
   242	- No PII outside firm boundary in tacit-note narrative
   243	- Bullhorn auth refresh succeeded
   244	
   245	Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
   246	
   247	**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   248	
   249	### Gate B — Outcome thresholds (success metrics, not block)
   250	
   251	Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
   252	
   253	Two metrics:
   254	- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
   255	- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
   256	
   257	Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
   258	
   259	Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
   260	
   261	---
   262	
   263	## §6 — Escalation codes
   264	
   265	Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
   266	
   267	| Code | Trigger | Severity | Routing |
   268	|---|---|---|---|
   269	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   270	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
   271	| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
   272	| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   273	| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
   274	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
   275	| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1) | warn | operator_chat_id |
   276	| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
   277	| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
   278	| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
   279	| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
   280	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   281	
   282	Scribe does NOT use:
   283	
   284	- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
   285	
   286	---
   287	
   288	## §7 — Voice + tone constraints
   289	
   290	Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   291	
   292	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
   293	  - No identifying language about call participants beyond their professional context
   294	  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
   295	  - No compensation specifics in tacit notes (those go to structured fields only)
   296	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
   297	- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
   298	
   299	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   300	
   301	---
   302	
   303	## §8 — Build dependencies (W6 prerequisites)
   304	
   305	Scribe build cannot start until ALL of the following are confirmed:
   306	
   307	| Dependency | Source | Status |
   308	|---|---|---|
   309	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   310	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   311	| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
   312	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   313	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   314	| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
   315	| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
   316	| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
   317	| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
   318	| Per-tenant call-routing config (which provider) | Tenant onboarding | ⏸ |
   319	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   320	| Tacit-note taxonomy v0.1 (8 categories) finalised | Founder review with first pilot | ⏸ |
   321	| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
   322	| `context.sh` hydration | Build at W6 start (~0.5 day) | ⏸ |
   323	| `cycle.sh` orchestration (10-step) | Build at W6 start (~2 days) | ⏸ |
   324	| 3 fixtures with golden outputs | Build at W6 start (~1 day) | ⏸ |
   325	| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |
   326	
   327	**Until ALL ⏸ items resolve to ✅, W6 build slice does not start.**
   328	
   329	---
   330	
   331	## §9 — Status + open questions
   332	
   333	**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
   334	
   335	### Open questions for founder review
   336	
   337	| # | Question | Resolution path |
   338	|---|---|---|
   339	| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
   340	| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
   341	| Q3 | Tacit-note taxonomy v0.1 — 8 categories proposed in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
   342	| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
   343	| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH. Could leave entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
   344	| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
   345	| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
   346	
   347	### Gotchas (carried forward from ULTRAPLAN A3 line 527)
   348	
   349	1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   350	2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
   351	3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.
   352	
   353	---
   354	
   355	## §10 — When this document ratifies
   356	
   357	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   358	
   359	Status flips Proposed → Accepted when:
   360	- Codex Round 4 Phase 2 ratifies
   361	- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
   362	- Q2 cost model approved with budget cap
   363	
   364	Status flips Accepted → In Force when:
   365	- W6 build slice produces all 5 sibling bundle files + 3 fixtures
   366	- First production transcript processed end-to-end against migration-test tenant
   367	- SLA + edit-rate Gate-B metrics measurable
   368	- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
   369	
   370	Until then: this document is a forward-looking scaffold.
   371	
   372	*End of Scribe agent.md draft.*

exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|packages/harness/cortextos|kb-|knowledge-base|brain" agents/recruitment/scribe/agent.md -S' in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
exec
/bin/zsh -lc 'rg -n "''^  (candidate|contractor|contact|brief|opportunity|placement|client):|decision_authority:|current_role:|notice_period_weeks:|salary_expectation_min:|salary_min:|start_date_target:|role_type:|start_date:" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:57:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:102:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:129:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:170:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:220:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:461:  client:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:474:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:488:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:500:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:515:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:538:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:551:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:303:  contact:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:311:  brief:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:319:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:104:      current_role:
docs/verticals/recruitment/vertical-schema.yaml:116:      salary_expectation_min:
docs/verticals/recruitment/vertical-schema.yaml:133:      notice_period_weeks:
docs/verticals/recruitment/vertical-schema.yaml:153:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:221:  client:
docs/verticals/recruitment/vertical-schema.yaml:283:  contact:
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:341:  brief:
docs/verticals/recruitment/vertical-schema.yaml:366:      role_type:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:
docs/verticals/recruitment/vertical-schema.yaml:495:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:754:  client:
docs/verticals/recruitment/vertical-schema.yaml:760:  contact:
docs/verticals/recruitment/vertical-schema.yaml:765:  brief:
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:777:  opportunity:

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,115p' && nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '129,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "hh_decision_(trigger|output|action)|function hh_decision|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits" agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/_shared/hook-helpers.sh:166:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:168:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:180:hh_decision_output() {
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:193:hh_decision_action() {

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
    11	# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
    12	# (v0.3-supplement-0.1 amendment Day-20: original 3 v0.3 keys + 2 Janitor keys
    13	# added closing Janitor R11 Finding 4 + blocked_recipients added closing
    14	# Sourcing Scout R8 Finding 1. blocked_recipients is pre-v0.3 origin
    15	# canonicalised here. Total: 6 declarations in §4.)
    16	# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
    17	# its §3 narrative with canonical v0.1/v0.2/v0.3 field names (current_role vs
    18	# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
    19	# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
    20	# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
    21	# v0.3 ratification does not block on it.
    22	#
    23	# Companion migrations: migrations/v0.2-to-v0.3.sql + migrations/v0.3-to-v0.2.sql
    24	#   Both files drafted at commit alongside this supplement.
    25	#
    26	# Field types: per `review-schema-change` skill §2 allowed types only —
    27	# string | integer | number | boolean | array | object | timestamp | date.
    28	# Enums expressed as `type: string` + `enum: [...]`. Lists as `type: array`
    29	# with `items.type`. SQL-level types (NUMERIC(15,2), TIMESTAMPTZ etc.) appear
    30	# only in the companion migration SQL, not here.
    31	#
    32	# Schema layering: entities.data is JSONB per Day-4 §6.3 generic primitive.
    33	# v0.3 entity-field additions are JSONB key shapes validated via the
    34	# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
    35	# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
    36	# tables — they're already JSONB-shaped.
    37	# ============================================================================
    38	
    39	vertical: recruitment
    40	version: v0.3
    41	supplements: v0.2
    42	status: Proposed
    43	date: 2026-05-24
    44	author: founder (Maddox) + Claude Code; bilateral Cat-β unblock
    45	codex_ratification_queue_position: 44
    46	
    47	# ============================================================================
    48	# §1 — New entity.data JSONB key shapes (14 across 5 entities)
    49	# ============================================================================
    50	#
    51	# All additions land as JSONB keys on the existing entities.data column
    52	# (Day-4 §6.3 generic primitive layer). Validation lives in
    53	# validate_entities_data_v0_3() trigger function (migration §4).
    54	
    55	entity_field_additions:
    56	
    57	  candidate:
    58	    v0_3_new_keys:
    59	      employment_type:
    60	        type: string
    61	        enum: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
    62	        required: false
    63	        notes: |
    64	          Candidate's preferred engagement model (distinct from role type).
    65	          IR35 distinction matters for UK contractors. Extracted by Scribe
    66	          from call context.
    67	        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
    68	        v1_0_agent_access:
    69	          - Scribe: W
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
   101	
   102	  contact:
   103	    v0_3_new_keys:
   104	      preferred_channel:
   105	        type: string
   106	        enum: [email, phone, sms, teams, slack, in_person, unknown]
   107	        default: unknown
   108	        required: false
   109	        notes: |
   110	          Contact's stated preference; extracted by Scribe from call context.
   111	          Concierge reads to route outbound lifecycle comms.
   112	        source: IFOS-derived (Scribe extraction)
   113	        v1_0_agent_access:
   114	          - Scribe: R+W
   115	          - Concierge: R
   129	  brief:
   130	    v0_3_new_keys:
   131	      must_haves:
   132	        type: array
   133	        items:
   134	          type: string
   135	        max_items: 15
   136	        required: false
   137	        notes: |
   138	          Hard requirements; Sourcing Scout filters candidates against this
   139	          list. Free-text strings; max 15 items enforced by trigger.
   140	        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
   141	        v1_0_agent_access:
   142	          - Scribe: R+W
   143	          - Sourcing Scout: R
   144	
   145	      nice_to_haves:
   146	        type: array
   147	        items:
   148	          type: string
   149	        required: false
   150	        notes: |
   151	          Soft preferences; Sourcing Scout uses for ranking, not hard filter.
   152	        source: IFOS-derived (Scribe extracts)
   153	        v1_0_agent_access:
   154	          - Scribe: R+W
   155	          - Sourcing Scout: R
   156	
   157	      deal_breakers:
   158	        type: array
   159	        items:
   160	          type: string
   161	        required: false
   162	        notes: |
   163	          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
   164	          item.
   165	        source: IFOS-derived (Scribe extracts)
   166	        v1_0_agent_access:
   167	          - Scribe: R+W
   168	          - Sourcing Scout: R
   169	
   170	  placement:
   171	    v0_3_new_keys:
   172	      placement_status:
   173	        type: string
   174	        enum: [pending_start, active, completed, terminated_early, on_hold, cancelled]
   175	        default: pending_start
   176	        required: false
   177	        notes: |
   178	          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
   179	          confirming candidate started. Janitor flags ambiguous via
   180	          ESC_LIFECYCLE_STATE_UNKNOWN.
   181	        source: IFOS-derived (Scribe + Janitor)
   182	        v1_0_agent_access:
   183	          - Scribe: R+W
   184	          - Janitor: R+W
   185	          - Concierge: R
   186	
   187	      week_1_status_vault_path:
   188	        type: string
   189	        max_length: 200
   190	        pattern: '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$'
   191	        required: false
   192	        notes: |
   193	          POINTER ONLY (per ADR-002 vault/Postgres split). The 7d check-in
   194	          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
   195	          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
   196	          Pattern accepts call_ids + ISO dates (hyphens + underscores +
   197	          alphanumerics). This field stores the vault path; narrative does
   198	          NOT enter Postgres. Voice-classifier review at write time applies
   199	          to the vault file content; Concierge reads the vault file directly
   200	          via its path resolution.
   201	        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
   202	          to vault then stores pointer here)
   203	        v1_0_agent_access:
   204	          - Scribe: R+W
   205	          - Concierge: R
   206	
   207	      satisfaction_signal:
   208	        type: string
   209	        enum: [positive, neutral, negative, unclear]
   210	        default: unclear
   211	        required: false
   212	        notes: |
   213	          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
   214	          Concierge reads to adjust nurture tone.
   215	        source: IFOS-derived (Scribe LLM extraction)
   216	        v1_0_agent_access:
   217	          - Scribe: R+W
   218	          - Concierge: R
   219	
   220	  opportunity:
   221	    v0_3_new_keys:
   222	      headcount_growth_signal_text:
   223	        type: string
   224	        max_length: 280
   225	        required: false
   226	        notes: |
   227	          Free-text capture of growth-signal phrases from prospecting calls
   228	          ("we're hiring 5 engineers this quarter"). Sourcing Scout reads
   229	          to ICP-fit-score opportunities.
   230	        source: IFOS-derived (Scribe extraction)
   231	        v1_0_agent_access:
   232	          - Scribe: R+W
   233	          - Sourcing Scout: R
   234	
   235	      hiring_velocity_band:
   236	        type: string
   237	        enum: [slow, moderate, fast, urgent, unknown]
   238	        default: unknown
   239	        required: false
   240	        notes: |
   241	          Scribe LLM inference from prospecting-call urgency cues. Drives
   242	          ranking in Sourcing Scout's brief-to-candidate pipeline.
   243	        source: IFOS-derived (Scribe LLM classification)
   244	        v1_0_agent_access:
   245	          - Scribe: R+W
   246	          - Sourcing Scout: R
   247	
   248	      decision_window_text:
   249	        type: string
   250	        max_length: 280
   251	        required: false
   252	        notes: |
   253	          Free-text capture of decision-timing phrases. Concierge reads to
   254	          time outbound comms.
   255	        source: IFOS-derived (Scribe extraction)
   256	        v1_0_agent_access:
   257	          - Scribe: R+W
   258	          - Concierge: R
   259	
   260	# ============================================================================

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '48,150p' && nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '283,410p' && nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '429,520p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   283	  contact:
   284	    description: |
   285	      A person at a client company. Decision-makers, hiring managers, HR, procurement. Bullhorn calls this `ClientContact`. v1.0 representation is thin (10 fields); v1.1 Triage agent expands decision-authority modelling.
   286	    bullhorn_source: Bullhorn.ClientContact
   287	    v1_0_agent_access:
   288	      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
   289	      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
   290	    canonical_fields:
   291	      bullhorn_id:
   292	        type: integer
   293	        required: true
   294	        source: Bullhorn.ClientContact.id
   295	      first_name:
   296	        type: string
   297	        required: true
   298	        source: Bullhorn.ClientContact.firstName
   299	      last_name:
   300	        type: string
   301	        required: true
   302	        source: Bullhorn.ClientContact.lastName
   303	      email:
   304	        type: string
   305	        required: false
   306	        source: Bullhorn.ClientContact.email
   307	      phone:
   308	        type: string
   309	        required: false
   310	        source: Bullhorn.ClientContact.phone
   311	      title:
   312	        type: string
   313	        required: false
   314	        source: Bullhorn.ClientContact.title
   315	        notes: Job title at client.
   316	      decision_authority:
   317	        type: string
   318	        required: false
   319	        enum: [yes, no, influencer, blocker, unknown]
   320	        source: IFOS-derived (founder captures during intake; thin v0.1, expanded v1.1)
   321	        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
   322	      preferred_contact_method:
   323	        type: string
   324	        required: false
   325	        enum: [email, phone, telegram, whatsapp, linkedin]
   326	        source: IFOS-derived
   327	      date_added_at:
   328	        type: timestamp
   329	        required: true
   330	        source: Bullhorn.ClientContact.dateAdded
   331	      do_not_contact:
   332	        type: boolean
   333	        required: true
   334	        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
   335	        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
   336	    notes:
   337	      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
   338	      - v1.1 Triage expands: structured decision-authority (budget tier, decision domain, escalation chain), engagement history aggregate, preferred-channel sentiment.
   339	
   340	  # --------------------------------------------------------------------------
   341	  brief:
   342	    description: |
   343	      A role being recruited for. Master brief canonical vocabulary uses `brief`; §6 Day 6 line 490 lists "Role/Brief" — `brief` is the canonical entity_type slug; `role` is documented alias. Bullhorn calls this `JobOrder`.
   344	    bullhorn_source: Bullhorn.JobOrder
   345	    aliases: [role]
   346	    v1_0_agent_access:
   347	      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
   348	      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
   349	      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
   350	      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
   351	    canonical_fields:
   352	      bullhorn_id:
   353	        type: integer
   354	        required: true
   355	        source: Bullhorn.JobOrder.id
   356	      title:
   357	        type: string
   358	        required: true
   359	        source: Bullhorn.JobOrder.title
   360	        notes: Role title as advertised; not internal IFOS-codified.
   361	      description:
   362	        type: string
   363	        required: false
   364	        source: Bullhorn.JobOrder.publicDescription
   365	        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
   366	      role_type:
   367	        type: string
   368	        required: true
   369	        enum: [permanent, contract, temp, retained_search]
   370	        source: Bullhorn.JobOrder.employmentType (with mapping)
   371	      salary_min:
   372	        type: number
   373	        required: false
   374	        source: Bullhorn.JobOrder.salary
   375	        notes: GBP annual for permanent roles.
   376	      salary_max:
   377	        type: number
   378	        required: false
   379	        source: Bullhorn.JobOrder.salaryUnit (range parsing)
   380	      day_rate_min:
   381	        type: number
   382	        required: false
   383	        source: IFOS-derived (extracted from JD; GBP per day for contract roles)
   384	      day_rate_max:
   385	        type: number
   386	        required: false
   387	        source: IFOS-derived
   388	      location:
   389	        type: string
   390	        required: false
   391	        source: Bullhorn.JobOrder.address.city
   392	      remote_policy:
   393	        type: string
   394	        required: false
   395	        enum: [full_remote, hybrid_2_days_office, hybrid_3_days_office, on_site, flexible]
   396	        source: IFOS-derived (extracted from JD)
   397	      required_skills:
   398	        type: array
   399	        items: string
   400	        required: false
   401	        source: IFOS-derived (extracted from JD; v0.1 free strings; v1.1+ canonicalised skill taxonomy)
   402	      start_date_target:
   403	        type: date
   404	        required: false
   405	        source: IFOS-derived
   406	      urgency:
   407	        type: string
   408	        required: false
   409	        enum: [hot, warm, cold]
   410	        source: IFOS-derived (Concierge maintains based on client check-in cadence)
   429	  placement:
   430	    description: |
   431	      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
   432	    bullhorn_source: Bullhorn.Placement
   433	    v1_0_agent_access:
   434	      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
   435	      - Scribe (R+W — note links per bullhorn §4.1 A3)
   436	      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
   437	    canonical_fields:
   438	      bullhorn_id:
   439	        type: integer
   440	        required: true
   441	        source: Bullhorn.Placement.id
   442	      start_date:
   443	        type: date
   444	        required: true
   445	        source: Bullhorn.Placement.dateBegin
   446	      end_date:
   447	        type: date
   448	        required: false
   449	        source: Bullhorn.Placement.dateEnd
   450	        notes: Nullable for permanent placements; required for contract.
   451	      status:
   452	        type: string
   453	        required: true
   454	        enum: [active, completed, terminated, never_started]
   455	        source: Bullhorn.Placement.status (with mapping)
   456	      placement_type:
   457	        type: string
   458	        required: true
   459	        enum: [permanent, contract, temp, retained]
   460	        source: Bullhorn.Placement.employmentType (with mapping)
   461	      fee_amount:
   462	        type: number
   463	        required: false
   464	        source: Bullhorn.Placement.fee
   465	        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
   466	      fee_percent:
   467	        type: number
   468	        required: false
   469	        source: Bullhorn.Placement.feeArrangement (parsed)
   470	        notes: For permanent; 15-25% typical UK range.
   471	      candidate_salary_at_placement:
   472	        type: number
   473	        required: false
   474	        source: Bullhorn.Placement.salary
   475	        notes: GBP annual at start. Sets the baseline for fee_amount = salary × fee_percent.
   476	      lifecycle_stage:
   477	        type: string
   478	        required: true
   479	        enum: [pre_start, week_1, month_1, month_3, month_6, month_12, month_24, completed]
   480	        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
   481	        notes: Drives Concierge nurture-event firing.
   482	      termination_reason:
   483	        type: string
   484	        required: false
   485	        source: IFOS-derived (free text for v0.1; v1.1+ structured)
   486	      date_added_at:
   487	        type: timestamp
   488	        required: true
   489	        source: Bullhorn.Placement.dateAdded
   490	    notes:
   491	      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
   492	      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
   493	
   494	  # --------------------------------------------------------------------------
   495	  opportunity:
   496	    description: |
   497	      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
   498	    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
   499	    v1_0_agent_access:
   500	      - "none (v1.1+ exercise per bullhorn §4.1; Inbound Triage primary reader)"
   501	    v1_1_plus_agent_access:
   502	      - (v1.1) Inbound Triage — read for routing inbound candidate enquiries to active opportunities
   503	      - (v1.1) Brief Decoder — write submission events
   504	    canonical_fields:
   505	      bullhorn_id:
   506	        type: integer
   507	        required: true
   508	        source: Bullhorn.JobSubmission.id
   509	      status:
   510	        type: string
   511	        required: true
   512	        enum: [submitted, screening, interview_scheduled, interview_completed, offer_pending, offer_accepted, rejected_by_client, rejected_by_candidate, withdrawn]
   513	        source: Bullhorn.JobSubmission.status (with mapping)
   514	      stage_history:
   515	        type: array
   516	        items: object
   517	        required: false
   518	        source: IFOS-derived (event log; one entry per status transition)
   519	        notes: |
   520	          Each entry: {stage, timestamp, transitioned_by_user_id, notes}.

codex
The source citations for master brief §8.2 and ULTRAPLAN A3 line anchors do match. I’ve found one structural gap in the agent bundle shape and am checking whether it is isolated or part of a broader gate/catalogue mismatch.
exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Auto-send safety policy
     2	
     3	**Status:** Proposed — pending Codex Day-7 ratification
     4	**Date:** 2026-05-18 (Week 0, Day 5)
     5	**Author:** Claude Code, with founder review pending
     6	**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
     7	**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
     8	**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
     9	
    10	---
    11	
    12	## §1 — Scope
    13	
    14	This policy governs **every agent action that produces a side effect outside the IFOS-internal data layer**. The internal data layer is:
    15	
    16	- The vault (`/vault/<tenant>/`) — markdown + YAML, IFOS-controlled
    17	- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
    18	- The pgvector indexes over the above
    19	- The cortextOS file bus and PM2 process tree
    20	
    21	**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
    22	
    23	**Actions that ARE governed:**
    24	
    25	1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
    26	2. Sends to humans via any communication channel (email, SMS, Telegram, Slack, LinkedIn InMail, calendar invite, etc.) — both customer-facing and consultant-internal where the consultant is not the agent's directly-supervising user
    27	3. Reads from external systems that touch PII or have rate-limit/cost implications (LinkedIn profile lookups, Companies House director searches)
    28	4. Any action declared as side-effecting in `tools.yaml` for an agent, regardless of category
    29	
    30	**Out of scope:**
    31	
    32	- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
    33	- Render-time renderer operations (writing rendered agent dirs to `${frameworkRoot}/orgs/<org>/agents/<name>/`)
    34	- Vault local writes by the agent's own validate.sh / context.sh / fixture runs
    35	- Codex ratification artefacts (read-only review)
    36	
    37	If an action's scope is ambiguous, default to **governed** and require classification.
    38	
    39	**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
    40	
    41	---
    42	
    43	## §2 — Tier model
    44	
    45	Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
    46	
    47	### Green — auto-send allowed without review
    48	
    49	Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
    50	
    51	**Default characteristics:** idempotent OR internal-to-tenant OR read-only against external systems with rate-limit budget remaining OR low-cost-to-reverse (e.g., add a Bullhorn tag that can be removed in <30s).
    52	
    53	### Yellow — auto-send allowed with sampled spot-check
    54	
    55	Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
    56	
    57	**Default characteristics:** high-volume actions where systematic per-action review is too slow but where systematic blind trust is too risky; sampled review provides quality signal without operational drag.
    58	
    59	### Orange — requires human approval before send
    60	
    61	Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
    62	
    63	**Default characteristics:** moderate-to-high cost-to-reverse OR customer-facing comms OR irreversible state changes.
    64	
    65	### Red — blocked entirely
    66	
    67	Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
    68	
    69	**Default characteristics:** financial/legal/cross-tenant/PII boundaries; structural integrity of the IFOS multi-tenant model.
    70	
    71	---
    72	
    73	## §3 — Examples per tier across the v1.0 agent surface
    74	
    75	Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
    76	
    77	### Green examples (auto-send without review)
    78	
    79	| Agent | action_type | Why green |
    80	|---|---|---|
    81	| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
    82	| Janitor | `bullhorn_candidate_tag` | Adds a tag with `checked_at` date; reversible in <30s; high volume |
    83	| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
    84	| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
    85	| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
    86	| Concierge | `bullhorn_brief_read` | Read of inbound brief; idempotent; no comms |
    87	
    88	### Yellow examples (auto-send with spot-check sampling)
    89	
    90	| Agent | action_type | Sample rate | Why yellow |
    91	|---|---|---|---|
    92	| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
    93	| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
    94	| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
    95	| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
    96	| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
    97	
    98	### Orange examples (per-action human approval)
    99	
   100	| Agent | action_type | Why orange |
   101	|---|---|---|
   102	| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
   103	| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
   104	| Concierge | `twilio_sms_send` | Outbound SMS; high-trust channel; cost-per-send; irreversible |
   105	| Concierge | `calendar_invite_send` | Creates calendar event with attendee notification; visible to attendee |
   106	| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
   107	| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
   108	| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
   109	| Diagnostic | `diagnostic_calendar_invite` | Books intro call with prospect; reputation + scheduling friction |
   110	| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
   111	| Janitor | `bullhorn_placement_terminate` | Marks placement as terminated; commercial/legal implications; reversible only via support ticket |
   112	
   113	### Red examples (blocked entirely; `ESC_AUTOSEND_BLOCKED`)
   114	
   115	| action_type | block_reason | Why red |
   116	|---|---|---|
   117	| `xero_payment_initiate` | `payment_action` | Payment transfer; financial-bearing; never auto-send in v1.0 |
   118	| `stripe_charge_initiate` | `payment_action` | Charges a card; financial-bearing |
   119	| `subscription_modify` | `billing_modification` | Changes tenant's IFOS subscription; structurally distinct from agent work |
   120	| `legal_document_generate` | `legal_artefact` | Offer letters, employment contracts; legal-binding |
   121	| `pii_export_outside_tenant_geography` | `pii_geographic_breach` | PII transmitted outside tenant's declared data residency (e.g., GDPR boundary breach) |
   122	| `cross_tenant_data_send` | `cross_tenant_violation` | Sending tenant-A data to tenant-B recipient; structurally enforced by RLS but red-listed for defence-in-depth |
   123	| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
   124	| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
   125	
   126	---
   127	
   128	## §4 — Integration with the `hh_decision_action` contract
   129	
   130	Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
   131	
   132	- `hh_decision_trigger` — at session start; logs the trigger
   133	- `hh_decision_output` — when the agent produces its output artefact
   134	- `hh_decision_action` — when an action is taken (or blocked)
   135	
   136	The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
   137	
   138	### Reference implementation (bash pseudocode for `_shared/hook-helpers.sh`)
   139	
   140	```bash
   141	# hh_decision_action — gate every side-effecting action through the policy
   142	# Args:
   143	#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
   144	#   $2 target        (entity reference, e.g., "candidate:john-smith")
   145	#   $3 payload_hash  (SHA-256 hex of the action payload)
   146	#   $4 payload_preview (human-readable summary, <=500 chars, NO raw PII)
   147	hh_decision_action() {
   148	  local action_type="$1"
   149	  local target="$2"
   150	  local payload_hash="$3"
   151	  local payload_preview="$4"
   152	
   153	  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
   154	  local tenant_slug="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   155	  local agent_name="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   156	
   157	  # 1. Policy lookup — read tier from the canonical policy table
   158	  local tier
   159	  tier=$(autosend_policy_lookup "$action_type") || {
   160	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
   161	    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
   162	    return 1
   163	  }
   164	
   165	  # 2. Apply tenant override (elevation only; red is floor)
   166	  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
   167	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
   168	    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
   169	    return 1
   170	  }
   171	
   172	  # 3. Tier dispatch
   173	  case "$tier" in
   174	    green)
   175	      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
   176	      return 0
   177	      ;;
   178	    yellow)
   179	      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
   180	      if autosend_should_sample "$action_type" "$tenant_slug"; then

exec
/bin/zsh -lc "rg -n \"ESC_GATE_B_MISS|operator \\+ ifos_oncall|ifos_oncall|both metrics|Gate B\" agents/recruitment/scribe/agent.md agents/_shared/escalation-codes.md -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/escalation-codes.md:24:The Telegram message is templated via `common-notifications.json` `escalation_routes.<ESC_CODE>` if present; otherwise routed to `operator_chat_id`. `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` additionally CCs `ifos_oncall_chat_id`.
agents/_shared/escalation-codes.md:52:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — IFOS oncall must investigate
agents/_shared/escalation-codes.md:101:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
agents/_shared/escalation-codes.md:112:- **Routing:** `operator_chat_id`; CC `ifos_oncall_chat_id` only on `atomic-rename-failed` (infrastructure failure, not author error)
agents/_shared/escalation-codes.md:152:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — potential GDPR incident
agents/_shared/escalation-codes.md:174:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (CSM may need to retrain voice corpus)
agents/_shared/escalation-codes.md:244:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
agents/_shared/escalation-codes.md:252:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
agents/_shared/escalation-codes.md:260:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
agents/_shared/escalation-codes.md:268:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
agents/_shared/escalation-codes.md:276:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
agents/_shared/escalation-codes.md:284:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
agents/_shared/escalation-codes.md:292:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
agents/_shared/escalation-codes.md:303:- **Routing:** `operator_chat_id` (info + warn stages); ADD `ifos_oncall_chat_id` at blocking stage
agents/_shared/escalation-codes.md:352:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:379:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
agents/_shared/escalation-codes.md:383:- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
agents/_shared/escalation-codes.md:413:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
agents/_shared/escalation-codes.md:432:- **Severity:** warn — aggregated to Gate B (not a per-event block)
agents/_shared/escalation-codes.md:436:  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
agents/recruitment/scribe/agent.md:17:> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:222:   → if elapsed > 600 (10 min) but ≤ 1800: NO ESC fire — recorded as Gate B
agents/recruitment/scribe/agent.md:223:     "10-min miss" in the day-30 report aggregation; counts against Gate B 90% target
agents/recruitment/scribe/agent.md:249:### Gate B — Outcome thresholds (success metrics, not block)
agents/recruitment/scribe/agent.md:257:Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
agents/recruitment/scribe/agent.md:259:Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
agents/recruitment/scribe/agent.md:269:| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:274:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:278:| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |

exec
/bin/zsh -lc 'ls -la agents/recruitment/scribe && find agents/recruitment/scribe -maxdepth 2 -type f -print' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
total 56
drwxr-xr-x@ 4 madsadmin  staff    128 May 25 07:55 .
drwxr-xr-x@ 8 madsadmin  staff    256 May 24 10:46 ..
-rw-r--r--@ 1 madsadmin  staff    988 May 24 10:51 README.md
-rw-r--r--@ 1 madsadmin  staff  24320 May 25 07:55 agent.md
agents/recruitment/scribe/agent.md
agents/recruitment/scribe/README.md

codex
REJECTED

1. §3 omits the decision_log audit-row signature for Output 2. Lines 84 names `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'` for Output 1, but lines 86-123 define the tacit-note/Bullhorn Note output without its `decision_log` signature. Add the Output 2 signature in §3, e.g. `action_type='bullhorn_note_append_summary'`, tier, payload hash/preview fields, and vault path.

2. Citation drift on `validate_gate_a_fail`. Lines 195-197 claim `validate_gate_a_fail` is registered in `agents/_shared/autosend-policy.yaml line 113`, but the actual YAML has `consultant_feedback` at line 113 and `validate_gate_a_fail` at line 119. Correct the line citation to the live policy line.

3. Gate A is weakened by the tacit-note fallback path. Line 111 says classifier failure falls back to a `"needs consultant review"` placeholder, while lines 237-243 define Gate A as requiring one tacit-note with voice classifier ≥0.75. A placeholder would satisfy the write path while failing the declared output contract. Make persistent classifier failure a hard Gate A failure with `validate_gate_a_fail`/`ESC_VOICE_DRIFT`, or explicitly mark the placeholder as non-success and do not proceed to Bullhorn attach.

4. `ESC_GATE_B_MISS` is used but not listed in §6, and its routing conflicts with the catalogue. Line 259 says `ESC_GATE_B_MISS → operator + ifos_oncall`, but the catalogue entry routes only to `operator_chat_id`; §6 lines 267-280 also omit `ESC_GATE_B_MISS` from the Scribe code list. Add `ESC_GATE_B_MISS` to §6 with catalogue routing, or amend the catalogue if on-call routing is intended.
tokens used
79,635
REJECTED

1. §3 omits the decision_log audit-row signature for Output 2. Lines 84 names `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'` for Output 1, but lines 86-123 define the tacit-note/Bullhorn Note output without its `decision_log` signature. Add the Output 2 signature in §3, e.g. `action_type='bullhorn_note_append_summary'`, tier, payload hash/preview fields, and vault path.

2. Citation drift on `validate_gate_a_fail`. Lines 195-197 claim `validate_gate_a_fail` is registered in `agents/_shared/autosend-policy.yaml line 113`, but the actual YAML has `consultant_feedback` at line 113 and `validate_gate_a_fail` at line 119. Correct the line citation to the live policy line.

3. Gate A is weakened by the tacit-note fallback path. Line 111 says classifier failure falls back to a `"needs consultant review"` placeholder, while lines 237-243 define Gate A as requiring one tacit-note with voice classifier ≥0.75. A placeholder would satisfy the write path while failing the declared output contract. Make persistent classifier failure a hard Gate A failure with `validate_gate_a_fail`/`ESC_VOICE_DRIFT`, or explicitly mark the placeholder as non-success and do not proceed to Bullhorn attach.

4. `ESC_GATE_B_MISS` is used but not listed in §6, and its routing conflicts with the catalogue. Line 259 says `ESC_GATE_B_MISS → operator + ifos_oncall`, but the catalogue entry routes only to `operator_chat_id`; §6 lines 267-280 also omit `ESC_GATE_B_MISS` from the Scribe code list. Add `ESC_GATE_B_MISS` to §6 with catalogue routing, or amend the catalogue if on-call routing is intended.
