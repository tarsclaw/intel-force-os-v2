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
session id: 019e5ddb-daad-7800-8430-72522bede4cf
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

**Status:** Pre-Build-Round-4-Bilateral-Applied (Day-20; W4 bilateral pass applied). All 5 R3 residuals addressed: Findings 1+2+3+4 closed by post-R3 commit `db56336` + R4 polish edits today (Finding 1: §3 line 80 stale references removed; Finding 2: hh_decision_output added at Step 3 transcript fetch + Step 7 validation success/failure; Finding 3: Ringover explicitly v1.1+ in §2 webhook example + body text; Finding 4: §5 line 223 split into decision-doc citation + runtime YAML citation; Finding 5: §6 ESC_PROVIDER_FETCH_FAIL row annotated with v1.0 scope + catalogue §2.9 amendment queued for W6 build start). Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
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

Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (RATIFIED commit `7b4f390`) landed all the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). The W6 Day-1 verification pass audits all field names against the schema-as-of-W6 in case any further v0.4 supplement work renames anything.

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
   → on Gate A failure (<3 valid): hh_decision_action("scribe_gate_a_fail",
     "<entity_type>:<bullhorn_id>", payload_hash,
     "ESC_SCHEMA_VIOLATION; valid:<N>") and exit 1

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
I’ll verify the cited local sources and the agent-bundle structural requirements before giving the verdict. The highest-risk checks here are schema fields, ESC catalogue entries, autosend policy path/action types, and cited master/ULTRAPLAN line anchors.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '1,360p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Scribe — the data spine
     2	
     3	**Status:** Pre-Build-Round-4-Bilateral-Applied (Day-20; W4 bilateral pass applied). All 5 R3 residuals addressed: Findings 1+2+3+4 closed by post-R3 commit `db56336` + R4 polish edits today (Finding 1: §3 line 80 stale references removed; Finding 2: hh_decision_output added at Step 3 transcript fetch + Step 7 validation success/failure; Finding 3: Ringover explicitly v1.1+ in §2 webhook example + body text; Finding 4: §5 line 223 split into decision-doc citation + runtime YAML citation; Finding 5: §6 ESC_PROVIDER_FETCH_FAIL row annotated with v1.0 scope + catalogue §2.9 amendment queued for W6 build start). Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
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
    16	> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
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
    30	  "provider": "fathom" | "fireflies",        // v1.0
    31	  // "ringover" added in v1.1+ — not in v0 build per §8 dependencies
    32	  "call_id": "<provider-call-id>",
    33	  "transcript_url": "<provider-transcript-url>",
    34	  "duration_seconds": 1234,
    35	  "participants": [...],
    36	  "metadata": {...}
    37	}
    38	```
    39	
    40	v1.0 supports Fathom (HMAC-SHA256 signed) and Fireflies (bearer token) providers; auth handled per-provider in `tools.yaml` capability declarations. Ringover (OAuth-protected) is deferred to v1.1+ — not in the v0 build dependencies and not registered in v1.0 `tools.yaml`.
    41	
    42	### Manual trigger (v1.0 — debugging / replay)
    43	
    44	```bash
    45	ifosctl scribe replay --tenant <slug> --call-id <provider-call-id>
    46	```
    47	
    48	Useful when a webhook was missed or a transcript needs reprocessing after taxonomy update.
    49	
    50	### v1.1+ surfaces (deferred)
    51	
    52	- Telegram command (`@ifos_bot scribe replay <call-id>`)
    53	- Brain UI per-call "Reprocess" button
    54	- Brain UI "Confidence audit" view showing extraction confidence histograms
    55	
    56	---
    57	
    58	## §3 — Output shape
    59	
    60	Two outputs per webhook. Both write atomically (one transaction); rollback on either failure.
    61	
    62	### Output 1 — Bullhorn structured-field writes (≥3 per call)
    63	
    64	Bullhorn entity inferred from call participants + tenant Bullhorn lookup:
    65	- 1:1 call with candidate → Candidate entity update
    66	- 1:1 call with client contact → Contact entity update
    67	- Briefing call (consultant + client) → Brief entity update
    68	- Placement check-in (consultant + placed candidate) → Placement entity update
    69	- Opportunity scoping (consultant + prospect) → Opportunity entity update (NOTE: Bullhorn endpoint A3 row covers Candidate / ClientCorporation / JobOrder / Note / Placement only at v1.0; Opportunity writes are to IFOS-cached Postgres entity rows for the v0.3-added fields headcount_growth_signal_text + hiring_velocity_band + decision_window_text per v0.3 supplement §1, NOT direct Bullhorn endpoint calls)
    70	
    71	Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):
    72	
    73	| Entity | Canonical fields (schema-verified) |
    74	|---|---|
    75	| Candidate | `location`, `current_role`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (v0.3; enum per supplement §1), `key_skills` (v0.3; list) |
    76	| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
    77	| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
    78	| Placement | `start_date`, `placement_status` (v0.3), `week_1_status_vault_path` (v0.3; vault pointer, not narrative), `satisfaction_signal` (v0.3) |
    79	| Opportunity | `headcount_growth_signal_text` (v0.3), `hiring_velocity_band` (v0.3), `decision_window_text` (v0.3) |
    80	
    81	Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (RATIFIED commit `7b4f390`) landed all the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). The W6 Day-1 verification pass audits all field names against the schema-as-of-W6 in case any further v0.4 supplement work renames anything.
    82	
    83	Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
    84	
    85	### Output 2 — Tacit-note Markdown attachment
    86	
    87	One Markdown note per call, attached to the same Bullhorn entity as Output 1 via `POST /Note`. Structure:
    88	
    89	```markdown
    90	# Tacit notes — <Call-context-summary>
    91	**Date:** <ISO-date>  **Duration:** <N> min  **Participants:** <list>
    92	
    93	## Things observed that don't fit a structured field
    94	
    95	- <Observation 1 — bullet, 1-2 sentences, with transcript timestamp [MM:SS]>
    96	- <Observation 2 — ...>
    97	- ...
    98	
    99	## Tone signals
   100	
   101	- <Tone signal 1 — e.g., "client sounded frustrated about Bullhorn data quality">
   102	- <Tone signal 2 — ...>
   103	
   104	## Open questions for consultant follow-up
   105	
   106	- <Open question 1>
   107	- <Open question 2>
   108	```
   109	
   110	Length cap: 800 words. Voice-classified (≥0.75); falls back to "needs consultant review" placeholder if classifier persistently fails (ESC_VOICE_DRIFT).
   111	
   112	Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
   113	1. Relationship signal (client warmth, candidate enthusiasm, prior friction)
   114	2. Process friction (consultant complaint, tool gap, time waste)
   115	3. Competitive intel (mentions of competitor agencies / candidates working with others)
   116	4. Pricing/budget signal (off-record indications of room or constraint)
   117	5. Decision-process insight (who actually decides; coffee-machine politics)
   118	6. Calendar / availability nuance (vacation, life events affecting timeline)
   119	7. Cultural fit observation (working style, communication preferences)
   120	8. Risk flag (legal, IR35, compliance, reference concerns)
   121	
   122	v1.1+: expand taxonomy based on first 3 pilot tenants' patterns.
   123	
   124	---
   125	
   126	## §4 — Workflow
   127	
   128	10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   129	
   130	```
   131	0. Session start (webhook handler)
   132	   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice
   133	     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
   134	   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
   135	
   136	1. Webhook signature verification
   137	   → per-provider HMAC / bearer / OAuth check
   138	   → ESC_INPUT_VALIDATION_FAIL on signature mismatch; reject with 401
   139	   → record provider + call_id in trigger payload
   140	   → hh_decision_output("webhook_verified", "call:<id>", "provider:<name>")
   141	
   142	2. Bullhorn auth refresh
   143	   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
   144	   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
   145	   → hh_decision_output("bullhorn_auth_refreshed", "tenant:<slug>", "result:ok")
   146	
   147	3. Transcript fetch
   148	   → provider-specific: fathom.get_transcript(call_id) | fireflies.get(...)
   149	   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
   150	   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
   151	   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
   152	   → hh_decision_output("transcript_fetched", "call:<id>",
   153	     "provider:<name>; bytes:<N>; tmp_path:/tmp/scribe-<tenant>-<call_id>.txt")
   154	
   155	4. Participant + entity inference
   156	   → match transcript participants against Bullhorn contacts + candidates
   157	     + consultant accounts (per tenant config)
   158	   → infer call context (1:1 vs briefing vs placement vs opportunity)
   159	   → resolve target Bullhorn entity (bullhorn_id + entity_type per
   160	     vertical-schema.yaml canonical id field)
   161	   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
   162	     a Scribe run with no resolvable target cannot produce structured writes)
   163	   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>", confidence)
   164	
   165	5. LLM field extraction
   166	   → prompt = (transcript + entity context + vertical-schema entity field list
   167	     + 3 voice-corpus examples)
   168	   → output = JSON with per-field confidence scores
   169	   → discard fields confidence <0.6 (per Gate A)
   170	   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
   171	   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
   172	     "<N> fields ≥0.6 confidence")
   173	
   174	6. LLM tacit-note generation
   175	   → prompt = (transcript + 8-category taxonomy + 3 voice-corpus examples
   176	     + tone-rule filter)
   177	   → output = Markdown narrative per §3 Output 2 shape
   178	   → voice classifier scores against tenant style guide
   179	   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
   180	   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md
   181	   → hh_decision_output("tacit_note_rendered", "<vault_path>",
   182	     "voice_score:<N>; words:<N>")
   183	
   184	7. Field-extraction validation against vertical-schema
   185	   → verify each extracted field name exists in target entity schema
   186	   → verify each extracted value passes per-field type/range checks
   187	   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION
   188	     per catalogue line 163 — vertical-schema field-constraint violation at write time)
   189	   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
   190	     "<N> valid of <M> extracted; dropped:<N-invalid>")
   191	   → on Gate A failure (<3 valid): hh_decision_action("scribe_gate_a_fail",
   192	     "<entity_type>:<bullhorn_id>", payload_hash,
   193	     "ESC_SCHEMA_VIOLATION; valid:<N>") and exit 1
   194	
   195	8. Bullhorn write — structured fields (yellow tier)
   196	   → PATCH /<EntityType>/<id> with field map
   197	   → atomic transaction; rollback on Bullhorn 4xx/5xx
   198	   → on success: hh_decision_action("bullhorn_scribe_field_write",
   199	     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
   200	   → on failure: ESC_BULLHORN_WRITE_FAIL; do NOT proceed to Step 9
   201	
   202	9. Bullhorn write — tacit-note attachment (yellow tier)
   203	   → POST /Note linked to entity from Step 4 (mirror of vault artefact from Step 6)
   204	   → on success: hh_decision_action("bullhorn_note_append_summary",
   205	     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
   206	   → on failure: rollback Step 8 (best-effort PATCH /<EntityType>/<id>
   207	     reversing the field changes); ESC_BULLHORN_WRITE_FAIL
   208	
   209	10. Session close + SLA metric
   210	   → compute elapsed_seconds from webhook receipt
   211	   → if elapsed > 600 (10 min): warn ESC_SCRIBE_SLA_MISS (not blocking)
   212	   → if elapsed > 300 (5 min): info-level (counted against Gate B 90%)
   213	   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
   214	   → exit code 0
   215	```
   216	
   217	---
   218	
   219	## §5 — Gates
   220	
   221	### Gate A — validate.sh (hard-fail before action)
   222	
   223	Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:
   224	
   225	- Webhook signature valid per provider (Step 1)
   226	- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
   227	- 1 tacit-note generated with voice classifier ≥0.75
   228	- Field names exist in target entity per vertical-schema.yaml
   229	- Per-field type + range validation passes
   230	- No PII outside firm boundary in tacit-note narrative
   231	- Bullhorn auth refresh succeeded
   232	
   233	Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
   234	
   235	**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   236	
   237	### Gate B — Outcome thresholds (success metrics, not block)
   238	
   239	Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
   240	
   241	Two metrics:
   242	- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
   243	- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
   244	
   245	Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
   246	
   247	Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
   248	
   249	---
   250	
   251	## §6 — Escalation codes
   252	
   253	Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
   254	
   255	| Code | Trigger | Severity | Routing |
   256	|---|---|---|---|
   257	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   258	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
   259	| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
   260	| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   261	| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
   262	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
   263	| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1) | warn | operator_chat_id |
   264	| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
   265	| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
   266	| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
   267	| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
   268	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   269	
   270	Scribe does NOT use:
   271	
   272	- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
   273	- `ESC_BULLHORN_OAUTH_REVOKED` — escalated from `ESC_BULLHORN_AUTH` only after 6 consecutive auth failures (Concierge handles)
   274	
   275	---
   276	
   277	## §7 — Voice + tone constraints
   278	
   279	Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   280	
   281	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
   282	  - No identifying language about call participants beyond their professional context
   283	  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
   284	  - No compensation specifics in tacit notes (those go to structured fields only)
   285	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
   286	- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
   287	
   288	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   289	
   290	---
   291	
   292	## §8 — Build dependencies (W6 prerequisites)
   293	
   294	Scribe build cannot start until ALL of the following are confirmed:
   295	
   296	| Dependency | Source | Status |
   297	|---|---|---|
   298	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   299	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   300	| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
   301	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   302	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   303	| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
   304	| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
   305	| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
   306	| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
   307	| Per-tenant call-routing config (which provider) | Tenant onboarding | ⏸ |
   308	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   309	| Tacit-note taxonomy v0.1 (8 categories) finalised | Founder review with first pilot | ⏸ |
   310	| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
   311	| `context.sh` hydration | Build at W6 start (~0.5 day) | ⏸ |
   312	| `cycle.sh` orchestration (10-step) | Build at W6 start (~2 days) | ⏸ |
   313	| 3 fixtures with golden outputs | Build at W6 start (~1 day) | ⏸ |
   314	| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |
   315	
   316	**Until ALL ⏸ items resolve to ✅, W6 build slice does not start.**
   317	
   318	---
   319	
   320	## §9 — Status + open questions
   321	
   322	**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
   323	
   324	### Open questions for founder review
   325	
   326	| # | Question | Resolution path |
   327	|---|---|---|
   328	| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
   329	| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
   330	| Q3 | Tacit-note taxonomy v0.1 — 8 categories proposed in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
   331	| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
   332	| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH. Could leave entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
   333	| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
   334	| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
   335	
   336	### Gotchas (carried forward from ULTRAPLAN A3 line 527)
   337	
   338	1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   339	2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
   340	3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.
   341	
   342	---
   343	
   344	## §10 — When this document ratifies
   345	
   346	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   347	
   348	Status flips Proposed → Accepted when:
   349	- Codex Round 4 Phase 2 ratifies
   350	- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
   351	- Q2 cost model approved with budget cap
   352	
   353	Status flips Accepted → In Force when:
   354	- W6 build slice produces all 5 sibling bundle files + 3 fixtures
   355	- First production transcript processed end-to-end against migration-test tenant
   356	- SLA + edit-rate Gate-B metrics measurable
   357	- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
   358	
   359	Until then: this document is a forward-looking scaffold.
   360	

exec
/bin/zsh -lc "rg --files | rg '("'^|/)(master|ULTRAPLAN|vertical-schema|autosend|escalation-codes|voice-loader|hook-helpers|v1.0-kill|ADR-002|agent.md)$'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/agent.md
agents/recruitment/scribe/agent.md
agents/recruitment/sourcing-scout/agent.md
agents/recruitment/janitor/agent.md
agents/recruitment/diagnostic/agent.md
agents/recruitment/concierge/agent.md
packages/agent-renderer/tests/fixtures/test-agent/agent.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/agent.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/agent.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/agent.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/agent.md
legacy/v1/docs/phase-2-agent-suite/content-creator/agent.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/agent.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/agent.md
legacy/v1/docs/phase-2-agent-suite/repurposer/agent.md
legacy/v1/docs/phase-2-agent-suite/hr-agent/agent.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/agent.md
legacy/v1/docs/phase-2-agent-suite/librarian/agent.md

codex
The agent file has the required section order, so I’m focusing on whether its claims are anchored in the project sources. I’ve already found several claims that need source verification rather than style judgment.
exec
/bin/zsh -lc "find docs agents -iname '*vertical*schema*' -o -iname '*ultraplan*' -o -iname '*master*brief*' -o -iname '*autosend*' -o -iname '*escalation*' -o -iname '*voice-loader*' -o -iname '*hook-helpers*' -o -iname '*kill*criterion*'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/specs/ULTRAPLAN.md
docs/build-brief/00-MASTER-BRIEF.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/autosend-safety-policy.md
docs/decisions/autosend-approval-bridge-spec.md
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
agents/_shared/tests/test-voice-loader.sh
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/hook-helpers.sh
agents/_shared/escalation-codes.md
agents/_shared/autosend-policy.yaml

exec
/bin/zsh -lc "rg --files docs agents packages | rg '(MASTER|master|ULTRAPLAN|ultraplan|vertical-schema|autosend|escalation-codes|voice-loader|hook-helpers|kill-criterion|autosend-policy)'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/ULTRAPLAN.md

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '500,535p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '520,630p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   520	|---|---|
   521	| The 9-agent consulting suite (Lead Hunter, Content Creator, Repurposer, etc.) | Different vertical, different prompts, different output contracts. Reference only. |
   522	| The v1 dashboard as a whole app | Replaced by `packages/dashboard-ext/` extending the cortextos dashboard. |
   523	| The v1 provisioning system | The 5-day onboarding wizard (Spec §5.2) is the new shape. |
   524	| `vault-syncer` (v1) | Needs to coordinate with the file-bus contract. Build fresh. |
   525	| `cc-invoke` | CortexOS PM2-supervised PTY replaces per-invocation-spawn. |
   526	
   527	### 7.3 The "skeleton-ready" principle
   528	
   529	Per founder pattern: build documentation at skeleton-ready level (SQL schemas, Python pseudocode, worked examples) before code.
   530	
   531	- Every agent bundle: `README.md` + `agent.md` (output contract first) before the four supporting files
   532	- Every MCP connector: `tools.yaml` + OpenAPI spec walkthrough before code
   533	- Every Postgres table: `CREATE TABLE` + RLS policy + indexes in `docs/architecture/postgres-schema.sql` before migration runs
   534	
   535	---
   536	
   537	## 8. The agent bundle v2 pattern
   538	
   539	Every agent — front-office and temp — is exactly these files. No exceptions.
   540	
   541	```
   542	agents/recruitment/{agent-name}/
   543	├── README.md                           # 2-min overview for humans
   544	├── agent.md                            # Output contract FIRST, then workflow, gates, escalation
   545	├── config.schema.json                  # Per-tenant config (extends common-*.json)
   546	├── tools.yaml                          # MCP servers + scopes + degraded modes
   547	├── validate.sh                         # Gate A — sources _shared/hook-helpers.sh
   548	├── context.sh                          # Hydrates CONTEXT via context-assembly API
   549	└── tests/
   550	    └── fixtures/
   551	        ├── 01-primary/                 # Happy path. The demo example.
   552	        │   ├── input.json
   553	        │   └── expected.md
   554	        ├── 02-edge-case-{name}/        # ≥1 required. From workflow analysis.
   555	        │   ├── input.json
   556	        │   └── expected.md
   557	        └── 99-voice-drift-canary/      # NEW IN V2 — every agent has one.
   558	            ├── input.json              # Same input, run weekly in CI
   559	            └── expected.md             # Output diffed against historical
   560	```
   561	
   562	**The bundle at `agents/recruitment/<name>/` is the source artefact; the cortextOS daemon does not read it directly.** The renderer (`packages/agent-renderer/`, per `docs/decisions/ADR-003-agent-bundle-renderer.md` and `docs/architecture/agent-bundle-renderer-design.md`) translates the bundle into a cortextOS-shaped per-agent directory at `${frameworkRoot}/orgs/<org>/agents/<name>/` per-tenant. Source bundle authored once; rendered N times (once per active tenant). The `cortextos-ifos add-agent` command is **NOT** the IFOS path — it inherits 24 cortextOS template skills the IFOS bundle does not want.
   563	
   564	### 8.1 The three v2 changes (Ultraplan §4.2)
   565	
   566	**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
   567	
   568	**Change 2 — Decision logging is enforced.** Three required calls per agent run:
   569	
   570	```bash
   571	hh_decision_trigger   # at start; logs trigger
   572	hh_decision_output    # on output; logs the artefact
   573	hh_decision_action    # when human acts; logs the action
   574	```
   575	
   576	`validate.sh` hard-fails on missing calls. This is what enables the v2.0 LoRA pipeline — no decision log, no SFT corpus, no Scale-tier moat.
   577	
   578	**Change 3 — Escalation codes expand to recruitment vocabulary.** ~20–30 codes. Examples:
   579	
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
   606	### 8.3 The working pattern in Claude Code
   607	
   608	For any new agent:
   609	
   610	```bash
   611	git checkout -b agent/{name}                       # e.g. agent/janitor
   612	mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
   613	
   614	# In Claude Code, work the bundle through 6 files in this order:
   615	# 1. README.md (2-min overview)
   616	# 2. agent.md (OUTPUT CONTRACT FIRST, then workflow, then gates, then escalation)
   617	# 3. config.schema.json (what the wizard collects)
   618	# 4. tools.yaml (MCP servers + scopes + degraded modes)
   619	# 5. validate.sh (Gate A; sources _shared/hook-helpers.sh)
   620	# 6. context.sh (hydrates CONTEXT via context-assembly API)
   621	
   622	# Then the three fixtures with golden outputs.
   623	# Test against fixtures; iterate; commit; PR; merge.
   624	
   625	# After merge, render the bundle for each tenant that uses this agent:
   626	cortextos-ifos render-agent {name} --tenant <slug>
   627	# For all active tenants (v1.1+): cortextos-ifos render-agent {name} --all-tenants
   628	# Activate: pm2 restart ifos-daemon   (for new agents)
   629	#       OR: cortextos-ifos bus self-restart {name}   (for re-renders of running agents)
   630	```

 succeeded in 0ms:
   500	
   501	#### A2. The Janitor — the wedge agent
   502	
   503	- **Build wave:** v1.0 (week 5–6)
   504	- **Always-on?** Tier 2 — scheduled nightly cron
   505	- **Trigger type:** Cron 02:00 UTC daily; manual full-cleanup on demand
   506	- **CortexOS primitives required:** None (scheduled batch)
   507	- **MCP tools required:** Bullhorn (read-write), Companies House (for entity enrichment)
   508	- **Shared modules required:** Decision log writer, escalation router
   509	- **External APIs:** Bullhorn REST API, Companies House
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
   531	- **Build wave:** v1.0 (week 7–8)
   532	- **Always-on?** Tier 1 — persistent watcher on accounting + bank webhooks
   533	- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
   534	- **CortexOS primitives required:** Persistent PTY (#1), Telegram approval surface (#5), standing authorisations (#4)
   535	- **MCP tools required:** Xero / QuickBooks / Sage (one of, per tenant), bank-feed connector

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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
   231	    agent: concierge
   232	    timeout: PT4H
   233	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   234	    irreversible: true
   235	
   236	  twilio_sms_send:
   237	    tier: orange
   238	    agent: concierge
   239	    timeout: PT30M
   240	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   241	    irreversible: true
   242	
   243	  calendar_invite_send:
   244	    tier: orange
   245	    agent: concierge
   246	    timeout: PT4H
   247	    reason: "Creates calendar event with attendee notification; visible to attendee"
   248	    irreversible: true
   249	
   250	  email_summary_to_customer:
   251	    tier: orange
   252	    agent: scribe
   253	    timeout: PT4H
   254	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   255	    irreversible: true
   256	
   257	  xero_reminder_send_customer:
   258	    tier: orange
   259	    agent: cash-conductor
   260	    timeout: PT24H

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,380p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS escalation codes catalogue
     2	
     3	**Status:** Reference — single source of truth for `ESC_*` codes used by any agent. Wired into `_shared/hook-helpers.sh` (Phase 3).
     4	**Mandated by:** master brief §8.1 Change 3 — "Build the catalogue in Week 0. New codes only when production demands one."
     5	**Update protocol:** new codes added here BEFORE wiring into helpers + before referencing from any agent bundle. Code names are case-sensitive; pattern `ESC_[A-Z][A-Z0-9_]*`.
     6	
     7	---
     8	
     9	## §1 — How escalation codes work
    10	
    11	Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
    12	
    13	The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
    14	
    15	```
    16	agent_name        — the agent firing the escalation (or '_renderer')
    17	tenant_slug       — RLS-isolated per tenant
    18	phase             — one of {trigger, output, action, gating_failed, agent_handoff}; per decision_log CHECK constraint at Day-4 §6.3
    19	human_action      — the ESC_* code itself + optional `:reason` suffix
    20	payload           — JSON object: {tier?, action_type?, target?, payload_hash?, reason, ...code-specific fields}
    21	created_at        — `now()` at insertion
    22	```
    23	
    24	The Telegram message is templated via `common-notifications.json` `escalation_routes.<ESC_CODE>` if present; otherwise routed to `operator_chat_id`. `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` additionally CCs `ifos_oncall_chat_id`.
    25	
    26	---
    27	
    28	## §2 — Catalogue (52 codes)
    29	
    30	### 2.1 — Auto-send safety (3 codes)
    31	Source: `docs/decisions/autosend-safety-policy.md` §5
    32	
    33	#### `ESC_AUTOSEND_NEEDS_REVIEW`
    34	- **Severity:** info → blocking-pending-approval
    35	- **Trigger:** Orange-tier action queued for tenant operator review
    36	- **Phase:** `action`
    37	- **Routing:** `operator_chat_id` via Telegram approval gate (primitive 4)
    38	- **Timeout:** 4h default per `common-notifications.json.default_approval_timeout_seconds`; on timeout, converts to manual reconciliation
    39	- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`
    40	
    41	#### `ESC_AUTOSEND_BLOCKED`
    42	- **Severity:** warn (informational; no human action needed)
    43	- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
    44	- **Phase:** `gating_failed`
    45	- **Routing:** `operator_chat_id`; informational only
    46	- **Payload fields:** `tier='red'`, `action_type`, `target`, `payload_hash`, `reason='red_tier_classification'`
    47	
    48	#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
    49	- **Severity:** **critical** — operational failure, not a policy decision
    50	- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
    51	- **Phase:** `gating_failed`
    52	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` — IFOS oncall must investigate
    53	- **Payload fields:** `tier='fail-safe-red'`, `action_type`, `target`, `reason` (one of `unknown_action_type`, `override_resolution_failed`, `unknown_tier:<value>`)
    54	- **Fail-safe behaviour:** Action refused regardless of declared tier
    55	
    56	### 2.2 — Vault concurrency (5 codes)
    57	Source: `docs/architecture/vault-concurrency.md` §6
    58	
    59	#### `ESC_VAULT_LOCK_TIMEOUT`
    60	- **Severity:** warn
    61	- **Trigger:** `flock` acquisition failed within `OP_LOCK_TIMEOUT_S = 5` seconds (per `common-vault.json.lock_timeout_seconds`)
    62	- **Phase:** `gating_failed`
    63	- **Routing:** `operator_chat_id`
    64	- **Payload fields:** `vault_path`, `lock_holder_pid` (if knowable), `wait_duration_ms`
    65	
    66	#### `ESC_VAULT_VERSION_MISMATCH`
    67	- **Severity:** warn
    68	- **Trigger:** Postgres optimistic-concurrency UPDATE found 0 rows after `OP_RETRY_BACKOFF_MS = 100` retry (per `common-vault.json.retry_backoff_ms`); per vault-concurrency §3 retry policy
    69	- **Phase:** `gating_failed`
    70	- **Routing:** `operator_chat_id`
    71	- **Payload fields:** `entity_id`, `expected_version`, `actual_version`
    72	
    73	#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
    74	- **Severity:** warn — likely founder is editing in Obsidian
    75	- **Trigger:** Obsidian debounce hit `MAX_RETRIES = 5` (file mtime still recent after 30s of waiting) per vault-concurrency §4 + `common-vault.json.obsidian_debounce_max_retries`
    76	- **Phase:** `gating_failed`
    77	- **Routing:** `operator_chat_id`
    78	- **Payload fields:** `vault_path`, `file_mtime`, `last_observed_age_ms`
    79	
    80	#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
    81	- **Severity:** warn — requires founder manual reconciliation
    82	- **Trigger:** Rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite per vault-concurrency §5.4 v1.0 mitigation
    83	- **Phase:** `gating_failed`
    84	- **Routing:** `operator_chat_id`
    85	- **Payload fields:** `failures` (list of entity_id strings), `successful_count`, `total_count`
    86	
    87	#### `ESC_VAULT_CASCADE_TIMEOUT`
    88	- **Severity:** warn
    89	- **Trigger:** Cascade exceeded `CASCADE_TIMEOUT_MS = 30_000` ms per vault-concurrency §5 + `common-vault.json.cascade_timeout_ms`
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '374,470p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   461	These names are reserved by design documents but no agent fires them in v1.0. Listed here to prevent collision; do not invent codes overlapping these names.
   462	
   463	| Code | Reserved by | Earliest agent |
   464	|---|---|---|
   465	| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
   466	| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
   467	
   468	---
   469	
   470	## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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
   181	      "$(_hh_json_escape "${style_guide}")" \
   182	      "$(_hh_json_escape "${task_context}")" \
   183	      "$([[ -z "${IFOS_VL_QUERY_VECTOR:-}" ]] && printf 'no_query_vector' || printf 'db_unavailable')"
   184	    return 0
   185	  fi
   186	  printf '{"samples":[],"voice_corpus_version":"empty","source":"empty","task_context":"%s","reason":"no_db_no_style_guide"}\n' \
   187	    "$(_hh_json_escape "${task_context}")"
   188	}
   189	
   190	# Internal: render psql TSV → JSON for voice samples.
   191	_vl_render_voice_samples_json() {
   192	  local rows="$1"
   193	  local version="$2"
   194	  local source="$3"
   195	  local task_context="$4"
   196	
   197	  if [[ -z "${rows}" ]]; then
   198	    printf '{"samples":[],"voice_corpus_version":"%s","source":"%s","task_context":"%s","count":0}\n' \
   199	      "$(_hh_json_escape "${version}")" \
   200	      "$(_hh_json_escape "${source}")" \
   201	      "$(_hh_json_escape "${task_context}")"
   202	    return 0
   203	  fi
   204	
   205	  printf '{"samples":['
   206	  local first=1
   207	  while IFS=$'\t' read -r chunk_index text_chunk source_doc_ref distance; do
   208	    [[ -z "${chunk_index}" ]] && continue
   209	    if (( first )); then first=0; else printf ','; fi
   210	    printf '{"chunk_index":%s,"text_chunk":"%s","source_doc_ref":"%s","distance":%s}' \
   211	      "${chunk_index}" \
   212	      "$(_hh_json_escape "${text_chunk}")" \
   213	      "$(_hh_json_escape "${source_doc_ref}")" \
   214	      "${distance}"
   215	  done <<<"${rows}"
   216	  printf '],"voice_corpus_version":"%s","source":"%s","task_context":"%s"}\n' \
   217	    "$(_hh_json_escape "${version}")" \
   218	    "$(_hh_json_escape "${source}")" \
   219	    "$(_hh_json_escape "${task_context}")"
   220	}
   221	
   222	# ────────────────────────────────────────────────────────────────────────
   223	# hh_load_recent_edits [<lookback_days>] [<agent_name>]
   224	# ────────────────────────────────────────────────────────────────────────
   225	# Returns recent_edit rows from the last <lookback_days> for <agent_name>
   226	# (or all agents if not specified).
   227	#
   228	# Output JSON shape:
   229	#   { "edits": [ { "id": N, "action_type": "...", "edit_distance": N,
   230	#                  "resolution": "...", "tone_rules_triggered": [...],
   231	#                  "resolved_at": "..." }, ... ],
   232	#     "lookback_days": N, "source": "db" | "fallback" }
   233	hh_load_recent_edits() {
   234	  local lookback_days="${1:-30}"
   235	  local agent_name="${2:-${CTX_AGENT_NAME:-}}"
   236	
   237	  # Validate lookback_days
   238	  if ! [[ "${lookback_days}" =~ ^[0-9]+$ ]] || (( lookback_days <= 0 )) || (( lookback_days > 365 )); then
   239	    lookback_days=30
   240	  fi
   241	
   242	  if _vl_db_available; then
   243	    local sql
   244	    if [[ -n "${agent_name}" ]]; then
   245	      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
   246	           FROM recent_edit
   247	           WHERE agent_name = '$(_hh_json_escape "${agent_name}")'
   248	             AND resolved_at > now() - interval '${lookback_days} days'
   249	           ORDER BY resolved_at DESC
   250	           LIMIT 200;"
   251	    else
   252	      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
   253	           FROM recent_edit
   254	           WHERE resolved_at > now() - interval '${lookback_days} days'
   255	           ORDER BY resolved_at DESC
   256	           LIMIT 200;"
   257	    fi
   258	    local rows
   259	    rows="$(_vl_psql_query "${sql}")"
   260	    _vl_render_recent_edits_json "${rows}" "${lookback_days}"

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	#
     3	# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
     4	# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
     5	#
     6	# Sourced by every rendered agent's .claude/hooks/validate.sh and
     7	# .claude/hooks/context.sh via the per-tenant `_shared/` symlink resolved at
     8	# render time (ADR-003 §3.3.3 Option γ).
     9	#
    10	# Live-mode writes:        Postgres decision_log via psql + IFOS_DB_URL
    11	# Offline-mode writes:     JSON-line append to $IFOS_DECISION_LOG_FALLBACK
    12	#                          (defaults to /vault/<tenant>/decision-log.jsonl)
    13	#
    14	# The dual-mode design means: agents in degraded mode (Hetzner unreachable)
    15	# still produce an audit trail; the trail replays into Postgres when
    16	# connectivity returns. See agents/_shared/README.md §"Degraded mode".
    17	#
    18	# Shellcheck-clean: this file passes `shellcheck -s bash -S style`.
    19	# Side-effects: appends to decision_log table OR fallback JSONL; never reads
    20	# raw PII into shell vars (payload_preview must be sanitised by caller).
    21	
    22	# shellcheck shell=bash
    23	
    24	set -uo pipefail
    25	
    26	# ────────────────────────────────────────────────────────────────────────
    27	# Internal: paths, table names, sanity guards
    28	# ────────────────────────────────────────────────────────────────────────
    29	
    30	_HH_HELPERS_VERSION="0.1.0"
    31	_HH_POLICY_FILE="${HH_POLICY_FILE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/autosend-policy.yaml}"
    32	_HH_ESC_CATALOGUE="${HH_ESC_CATALOGUE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/escalation-codes.md}"
    33	
    34	# Fallback file used when IFOS_DB_URL is unset OR psql is unavailable.
    35	# Resolved at first call to _hh_emit_row().
    36	_hh_resolve_fallback_path() {
    37	  if [[ -n "${IFOS_DECISION_LOG_FALLBACK:-}" ]]; then
    38	    printf '%s' "${IFOS_DECISION_LOG_FALLBACK}"
    39	    return 0
    40	  fi
    41	  local tenant="${CTX_TENANT_SLUG:-unknown}"
    42	  local vault_root="${IFOS_VAULT_ROOT:-/vault}"
    43	  printf '%s/%s/decision-log.jsonl' "${vault_root}" "${tenant}"
    44	}
    45	
    46	# JSON escape a single string for inclusion in a JSON value.
    47	# Use this when BUILDING a JSON document from plain text.
    48	_hh_json_escape() {
    49	  local input="$1"
    50	  input="${input//\\/\\\\}"
    51	  input="${input//\"/\\\"}"
    52	  input="${input//$'\n'/\\n}"
    53	  input="${input//$'\r'/\\r}"
    54	  input="${input//$'\t'/\\t}"
    55	  printf '%s' "${input}"
    56	}
    57	
    58	# SQL escape a string for inclusion in a single-quoted SQL string literal.
    59	# Use this when EMBEDDING values in psql SQL. Doubles single quotes;
    60	# leaves everything else (incl. backslashes, JSON internal " characters)
    61	# alone — Postgres standard_conforming_strings=on (default since 9.1)
    62	# treats backslash as literal.
    63	_hh_sql_escape() {
    64	  local input="$1"
    65	  printf '%s' "${input//\'/\'\'}"
    66	}
    67	
    68	# Current ISO-8601 UTC timestamp with millisecond precision where available.
    69	# GNU date supports %3N (3-digit nanoseconds → milliseconds). BSD date
    70	# (macOS default) does NOT error on the spec but outputs the literal
    71	# string "3N" instead, which Postgres rejects as invalid timestamptz.
    72	# Detect by checking that %3N produced exactly 3 digits.
    73	_hh_now_iso() {
    74	  local ms
    75	  ms=$(date -u +"%3N" 2>/dev/null)
    76	  if [[ "${ms}" =~ ^[0-9]{3}$ ]]; then
    77	    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
    78	  else
    79	    date -u +"%Y-%m-%dT%H:%M:%SZ"
    80	  fi
    81	}
    82	
    83	# Validate that ESC code exists in the catalogue.
    84	# Returns 0 if known, 1 otherwise. Catalogue absent → permissive (return 0).
    85	_hh_validate_esc_code() {
    86	  local code="$1"
    87	  if [[ ! -f "${_HH_ESC_CATALOGUE}" ]]; then
    88	    return 0
    89	  fi
    90	  if grep -Fq "\`${code}\`" "${_HH_ESC_CATALOGUE}"; then
    91	    return 0
    92	  fi
    93	  return 1
    94	}
    95	
    96	# ────────────────────────────────────────────────────────────────────────
    97	# Core decision-log writer
    98	# ────────────────────────────────────────────────────────────────────────
    99	
   100	# _hh_emit_row <phase> <outcome> <reason> <payload_json>
   101	#
   102	# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
   103	# INSERT via psql -v ON_ERROR_STOP=1. Offline mode: append JSON line to
   104	# fallback file. The two formats are reconcilable by the sync worker.
   105	_hh_emit_row() {
   106	  local phase="$1"
   107	  local outcome="${2:-}"
   108	  local reason="${3:-}"
   109	  local payload_json="${4:-{\}}"
   110	
   111	  local tenant agent created_at
   112	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   113	  agent="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   114	  created_at="$(_hh_now_iso)"
   115	
   116	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   117	    local sql
   118	    sql=$(cat <<EOF
   119	BEGIN;
   120	SET LOCAL app.current_tenant = '$(_hh_sql_escape "${tenant}")';
   121	INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
   122	VALUES (
   123	  '$(_hh_sql_escape "${tenant}")',
   124	  '$(_hh_sql_escape "${agent}")',
   125	  '$(_hh_sql_escape "${phase}")',
   126	  $([ -z "${outcome}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${outcome}")"),
   127	  $([ -z "${reason}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${reason}")"),
   128	  '$(_hh_sql_escape "${payload_json}")'::jsonb,
   129	  '${created_at}'::timestamptz
   130	);
   131	COMMIT;
   132	EOF
   133	)
   134	    local psql_err
   135	    psql_err=$(printf '%s\n' "${sql}" | psql -v ON_ERROR_STOP=1 -q "${IFOS_DB_URL}" 2>&1)
   136	    if [[ $? -eq 0 ]]; then
   137	      return 0
   138	    fi
   139	    # psql failed — fall through to fallback append + emit warning to stderr
   140	    printf 'hh_emit_row: psql write failed; appending to fallback\n' >&2
   141	    printf 'hh_emit_row: psql error: %s\n' "${psql_err}" >&2
   142	  fi
   143	
   144	  local fallback
   145	  fallback="$(_hh_resolve_fallback_path)"
   146	  mkdir -p "$(dirname "${fallback}")" 2>/dev/null || true
   147	
   148	  local row
   149	  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
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
   211	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   212	      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
   213	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   214	      "${target}" "${payload_hash}" "override_resolution_failed"
   215	    return 1
   216	  fi
   217	
   218	  case "${tier}" in
   219	    green)
   220	      autosend_emit_decision_log "action" "green" "${action_type}" \
   221	        "${target}" "${payload_hash}" "${payload_preview}" ""
   222	      return 0
   223	      ;;
   224	    yellow)
   225	      autosend_emit_decision_log "action" "yellow" "${action_type}" \
   226	        "${target}" "${payload_hash}" "${payload_preview}" ""
   227	      if autosend_should_sample "${action_type}" "${tenant}"; then
   228	        autosend_spot_check_enqueue "${action_type}" "${target}" \
   229	          "${payload_hash}" "${payload_preview}" "${tenant}"
   230	      fi
   231	      return 0
   232	      ;;
   233	    orange)
   234	      autosend_emit_decision_log "action" "orange" "${action_type}" \
   235	        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
   236	      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
   237	        "${target}" "${payload_hash}" "${payload_preview}"
   238	      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
   239	      return $?
   240	      ;;
   241	    red)
   242	      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
   243	        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
   244	      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
   245	        "${target}" "${payload_hash}" "red_tier_classification"
   246	      return 1
   247	      ;;
   248	    *)
   249	      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   250	        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
   251	      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   252	        "${target}" "${payload_hash}" "unknown_tier:${tier}"
   253	      return 1
   254	      ;;
   255	  esac
   256	}
   257	
   258	# ────────────────────────────────────────────────────────────────────────
   259	# 7 autosend_* helpers (autosend-safety-policy §4)
   260	# ────────────────────────────────────────────────────────────────────────

exec
/bin/zsh -lc 'rg -n "decision_authority|notice_period_weeks|salary_expectation_min|employment_type|key_skills|preferred_channel|next_action_target_date|salary_min|start_date_target|role_type|must_haves|placement_status|week_1_status_vault_path|headcount_growth_signal_text|hiring_velocity_band|decision_window_text|current_role|location|satisfaction_signal" docs/verticals/recruitment/vertical-schema*.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:104:      current_role:
docs/verticals/recruitment/vertical-schema.yaml:116:      salary_expectation_min:
docs/verticals/recruitment/vertical-schema.yaml:124:      location:
docs/verticals/recruitment/vertical-schema.yaml:128:        notes: Free-text city/region for v0.1. Structured location pending v1.1.
docs/verticals/recruitment/vertical-schema.yaml:133:      notice_period_weeks:
docs/verticals/recruitment/vertical-schema.yaml:149:      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:366:      role_type:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:388:      location:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:13:# its §3 narrative with canonical v0.1/v0.2/v0.3 field names (current_role vs
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:16:# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:55:      employment_type:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:68:      key_skills:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:100:      preferred_channel:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:113:      next_action_target_date:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:127:      must_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:168:      placement_status:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:183:      week_1_status_vault_path:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:203:      satisfaction_signal:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:218:      headcount_growth_signal_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:231:      hiring_velocity_band:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:244:      decision_window_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:277:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:278:#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:279:#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:343:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:392:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:475:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:481:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:488:      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:493:      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:911:  Q1_employment_type_enum_completeness:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:912:    question: Are 6 employment_type enum values sufficient for UK recruitment?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:915:        Keep 6 values as in §1.candidate.employment_type — perm, contract,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:920:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:926:  Q2_key_skills_max_length:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:936:  Q3_placement_status_enum_lifecycle:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:937:    question: 6-state placement_status enum maps to Bullhorn's native state machine?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:941:      C: Add a mapping table (auxiliary) — placement_status_mapping with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      the v0.3-added fields (employment_type, key_skills, preferred_channel,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:992:      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:993:      placement_status, week_1_status_vault_path, satisfaction_signal,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:994:      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:997:      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:999:      start_date_target; opportunity.sector — not yet in schema). These

exec
/bin/zsh -lc 'rg -n "scribe_gate_a_fail|bullhorn_scribe_field_write|bullhorn_note_append_summary|webhook_verified|bullhorn_auth_refreshed|transcript_fetched|entity_resolved|fields_extracted|fields_validated|tacit_note_rendered" agents/_shared/autosend-policy.yaml agents/_shared/hook-helpers.sh docs/decisions/autosend-safety-policy.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:168:  bullhorn_note_append_summary:
agents/_shared/autosend-policy.yaml:196:  bullhorn_scribe_field_write:
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |

exec
/bin/zsh -lc 'rg -n "''^  (candidate|contractor|contact|brief|opportunity|placement):|contractor|entities:" docs/verticals/recruitment/vertical-schema*.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:45:entities:
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:88:        enum: [active, archived, do_not_contact, placed, contractor_promoted]
docs/verticals/recruitment/vertical-schema.yaml:90:          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
docs/verticals/recruitment/vertical-schema.yaml:153:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
docs/verticals/recruitment/vertical-schema.yaml:160:      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:161:      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
docs/verticals/recruitment/vertical-schema.yaml:163:      # Inherits candidate fields conceptually; below are the additional contractor-specific fields.
docs/verticals/recruitment/vertical-schema.yaml:164:      # Full implementation: adapter layer materialises both candidate-overlap fields AND contractor-specific fields in entities.data.
docs/verticals/recruitment/vertical-schema.yaml:170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
docs/verticals/recruitment/vertical-schema.yaml:204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
docs/verticals/recruitment/vertical-schema.yaml:209:        source: IFOS-derived (when can contractor start, in weeks from now)
docs/verticals/recruitment/vertical-schema.yaml:214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
docs/verticals/recruitment/vertical-schema.yaml:217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:283:  contact:
docs/verticals/recruitment/vertical-schema.yaml:341:  brief:
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:495:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:561:      approved_by_contractor:
docs/verticals/recruitment/vertical-schema.yaml:673:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:684:    contractor: R+W  # status normalisation
docs/verticals/recruitment/vertical-schema.yaml:694:    contractor: R+W  # contractor calls same pattern
docs/verticals/recruitment/vertical-schema.yaml:704:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:714:    contractor: R    # contractor pool
docs/verticals/recruitment/vertical-schema.yaml:724:    contractor: R+W  # lifecycle state, contractor-specific cadence
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:744:    status_filter: status != 'contractor'
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:750:    status_filter: status='contractor'
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
docs/verticals/recruitment/vertical-schema.yaml:760:  contact:
docs/verticals/recruitment/vertical-schema.yaml:765:  brief:
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:777:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:797:  Q1_contractor_entity_type:
docs/verticals/recruitment/vertical-schema.yaml:799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:814:  Q4_system_agents_not_entities:
docs/verticals/recruitment/vertical-schema.yaml:827:    v0_1_decision: Timesheet entity has placeholder 7-field shape (id, week_starting, hours_worked, approved_by_client, approved_by_contractor, date_submitted, primary key).
docs/verticals/recruitment/vertical-schema.yaml:834:    v0_1_decision: contractor.umbrella_company is free-text field in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:53:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:61:          IR35 distinction matters for UK contractors. Extracted by Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:98:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:125:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:166:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:216:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:272:#     pattern as candidate/contractor — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Sourcing Scout contractor: R → R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:296:#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:313:  # SCOPE: This matrix is rectangular across `entities:` entity_types ONLY
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:314:  # (candidate, contractor, client, contact, brief, opportunity, placement,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:318:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:321:  # under `entities:`. v0.2 supplement §1 "LAYERING DISCLOSURE" states the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:322:  # three `entities:`-keyed objects "are auxiliary Postgres tables (real
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:329:  # this entity matrix. The v0.2 YAML key `entities:` was documentation
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:364:    contractor: none       # not in scope at v1.0
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:374:    contractor: R+W        # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:405:    contractor: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:421:    contractor: R+W        # OVERRIDE v0.1 R → v0.3 R+W (same; contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:435:    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:448:# v1_0_agent_access lists. v0.3 amends these v0.2 entities:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:470:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:484:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:496:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:511:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:534:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:547:  contractor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:553:      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:555:      Parallel upgrades to candidate; contractor entities follow the same
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:42:#   The label `entities:` below is a YAML key (the schema-document convention from
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:48:#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:53:entities:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:301:      notes: Same as candidate.voice_classifier_score, scoped to contractor sub-case.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:303:  contact:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:311:  brief:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:319:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:

exec
/bin/zsh -lc 'rg -n "Pre-Build|Proposed|Accepted|In Force|Status" docs/build-brief/00-MASTER-BRIEF.md docs/specs/ULTRAPLAN.md docs/decisions/operational-hygiene-protocol.md 2>/dev/null' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
docs/specs/ULTRAPLAN.md:6:**Status:** Authoritative build plan. Supersedes any informal build sequencing in prior documents. Where this contradicts an earlier doc on *how to build*, this wins. The product spec wins on *what to build*.
docs/build-brief/00-MASTER-BRIEF.md:448:- [ ] Write `docs/architecture/cortexos-primitive-status.md`. One line per primitive (1–7 from §2.4). Status: `shipped and tested` / `shipped but flaky` / `documented not built` / `aspirational`. Method:

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_OAUTH_REVOKED|ESC_AUTOSEND_BLOCKED|ESC_GATE_B_MISS|scribe_gate_a_fail|validate_gate_a_fail|bullhorn_note_internal|bullhorn_note_append_summary|bullhorn_scribe_field_write" agents/_shared/escalation-codes.md agents/_shared/autosend-policy.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:41:  bullhorn_note_internal:
agents/_shared/autosend-policy.yaml:113:  validate_gate_a_fail:
agents/_shared/autosend-policy.yaml:168:  bullhorn_note_append_summary:
agents/_shared/autosend-policy.yaml:196:  bullhorn_scribe_field_write:
agents/_shared/autosend-policy.yaml:293:  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
agents/_shared/escalation-codes.md:41:#### `ESC_AUTOSEND_BLOCKED`
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '470,560p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '260,410p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,90p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "rg -n \"Pre-Build-Round|Status:\\*\\* Proposed|Status:\\*\\* Pre|Status:\\*\\* Accepted|Status:\\*\\* In Force\" agents/recruitment/*/agent.md docs/decisions/*.md | head -80" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:7:**Status:** Accepted — Option A. Founder decision logged 2026-05-16.
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Pre-Build-Round-9-Bilateral-Applied (Day-20; W4 bilateral pass applied). All 3 R8 residuals confirmed closed by post-R8 commit `d1f4c53` (canonical schema-key block + webhook deferred to v1.1+ + Accepted criteria expanded). R9 adds: §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill); §4 Step 8 + Schema-key block rewrite for `blocked_recipients` (correctly cites the migration allowlist as canonical; v0.4-pending applies only to `auto_source_on_brief_create`). Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:356:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/diagnostic/agent.md:3:**Status:** Pre-Build-Round-17-Bilateral-Applied (Day-20; W4 bilateral pass applied). Full bundle built — agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures all present. R17 closes 4 of 5 R16 residuals via direct edits (§6 ESC table v0-vs-W4 status column added; §3 validate.sh citation aligned + validate.sh comment updated W3→W4; §9 Q3 cross-linked to §8 dependencies). R16 Finding 3 (Gate A failure signature missing ESC_VOICE_DRIFT) was already addressed at R15 commit `23f8c14` — Codex misread the multi-line statement at lines 117-121; ESC_VOICE_DRIFT IS listed at lines 119-120. Disagreement filed at `docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md`. **Next:** founder authorizes Codex R18 ratification (`bash scripts/run-codex-ratification.sh agent-bundle agents/recruitment/diagnostic/agent.md`); if RATIFIED, Status flips Pre-Build → Accepted when ALL: (a) bilateral founder review confirmed, AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds, AND (d) Gate B baseline measurement begins.
agents/recruitment/diagnostic/agent.md:230:**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + Codex RATIFIED verdict + first production render.
agents/recruitment/cash-conductor/agent.md:3:**Status:** Pre-Build-Round-18-Bilateral-Confirmed (Day-20; W4 bilateral pass confirmed all 3 R17 residuals already closed by post-R17 commit `9ae6874` — §8 sibling files + D1/bridge prereqs + §3 audit-row signatures correctly split into 4-row sequence per chase lifecycle). No new edits required from this round. Awaits Q1 LOI + accounting + Open Banking commercial signups + Founder Decision D1 resolved + autosend bridge built (Concierge W10) + W7 build slice. (Note: D1 + bridge are W4 founder-action queue items #4 + downstream; per §8 fallback row, Cash Conductor v1.0 can downgrade to drafts-only if D1+bridge slip past W7-8.)
agents/recruitment/cash-conductor/agent.md:403:**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:4:**Status:** Proposed
agents/recruitment/scribe/agent.md:3:**Status:** Pre-Build-Round-4-Bilateral-Applied (Day-20; W4 bilateral pass applied). All 5 R3 residuals addressed: Findings 1+2+3+4 closed by post-R3 commit `db56336` + R4 polish edits today (Finding 1: §3 line 80 stale references removed; Finding 2: hh_decision_output added at Step 3 transcript fetch + Step 7 validation success/failure; Finding 3: Ringover explicitly v1.1+ in §2 webhook example + body text; Finding 4: §5 line 223 split into decision-doc citation + runtime YAML citation; Finding 5: §6 ESC_PROVIDER_FETCH_FAIL row annotated with v1.0 scope + catalogue §2.9 amendment queued for W6 build start). Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
agents/recruitment/scribe/agent.md:322:**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
agents/recruitment/janitor/agent.md:3:**Status:** Pre-Build-Round-12-Bilateral-Applied (Day-20; W4 bilateral pass closed all 4 R11 residuals: 3 closed by post-R11 commit `e5a2c74` (Gate A ESC routing per-condition split, recent_edit.resolution citation, v0.3 supplement §2a authority); Finding 4 closed today by adding `janitor_dedup_threshold` + `janitor_last_run` declarations to v0.3 supplement §4 tenant_adapters_config_additions + agent.md citations updated. v0.3 supplement edit is additive — re-ratification queued. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice).
agents/recruitment/janitor/agent.md:278:**Status:** Proposed. Awaits Bullhorn A+B Accepted + Q1 LOI + W5 build slice start.
agents/recruitment/concierge/agent.md:3:**Status:** Pre-Build-Round-4-Bilateral-Applied (Day-20; W4 bilateral pass applied + ADR-007 drafted). All 4 R3 residuals addressed: Findings 1 + 2 + 4 closed by post-R3 commit `f79c018` (yellow draft tier + Step 7 decision-log + ULTRAPLAN line citations removed where stale); R4 polish today adds Step 11 `hh_decision_action("concierge_approval_routed"...)` for the autosend-bridge routing (closes the remaining Step-11 gap in Finding 1); Finding 3 (structural — Gate-A 30-min SLA deviation) closed by drafting `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` + adding ADR-007 to §10 Accepted blockers. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + ADR-007 RATIFIED + W10 build slice.
agents/recruitment/concierge/agent.md:392:**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
docs/decisions/brain-ui-scope.md:4:**Status:** Proposed — revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch)
docs/decisions/ADR-004-renderer-implementation-deviations.md:8:**Status:** Proposed
docs/decisions/2026-05-18-day-7-single-sentence-test.md:5:**Status:** Accepted (factual recording — not a Proposed decision)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** Proposed (2026-05-25, Day 20; W4 bilateral pass on Concierge agent.md surfaced this as Codex R3 Finding 3 — current scaffold reframes ULTRAPLAN A6 line 566 Gate A "every lifecycle event has a draft generated within 30 minutes" as a Gate B leading metric without an authoritative ADR backing the deviation. Awaits Codex `review-architecture-decision` ratification + founder Accept.)
docs/decisions/ADR-003-agent-bundle-renderer.md:7:**Status:** Accepted. Founder decision logged 2026-05-16.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:7:**Status:** Accepted — Option α. Founder decision logged 2026-05-16.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:3:**Status:** Accepted (2026-05-24, Day 13)
docs/decisions/autosend-safety-policy.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/v1.0-kill-criterion.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/sequencing-target.md:4:**Status:** Accepted (Day 3 session close, 2026-05-16). Single-pass technical decision, no commercial gating.
docs/decisions/autosend-approval-bridge-spec.md:3:**Status:** Proposed
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/bullhorn-integration-path.md:4:**Status:** Proposed (Sub-decision C Accepted technically; Sub-decisions A + B Proposed pending commercial verification per §1.3)

exec
/bin/zsh -lc "rg -n \"Pre-Build-Round-4-Bilateral-Applied|Pre-Build|Proposed|Accepted|In Force\" docs/decisions docs/build-brief docs/specs agents/_shared -g '*.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:77:**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:430:| Sourcing Scout | Pre-Build-Round-9-Reviewed | 5 (Cat-α Q7 + bullhorn-path conflict + Cat-γ DNC + Cat-ε per-candidate row + auth severity disagreement) | Mechanical Q7 fix + Bullhorn-path realignment + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:103:- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:111:### After Codex ratifies this ADR (Status flips Proposed → Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:130:These edits all land in the next commit AFTER this ADR ratifies (no point updating agent.md to cite a Proposed ADR; cite once ratified).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:146:**Proposed.** Awaits Codex ratification via `review-architecture-decision.md` skill.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:148:Status flips Proposed → Accepted when:
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:4:**Status:** Proposed
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:106:## D5 — Decision-doc shape skill softening for Reference + In Force artefacts
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:110:**Real issue:** Codex Round 1 REJECTED `cortexos-primitive-status.md` (audit) and `operational-hygiene-protocol.md` (runbook) for lacking Decision + Consequences sections. The skill `.codex/ratification/review-architecture-decision.md` §1 requires these sections for all artefacts under this skill. But the skill ALSO allows Status=Reference and Status=In Force, which are legitimately non-decision artefacts. Contradiction in the skill itself.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:113:- **D5-A: Soften the skill** — exempt Status=Reference + Status=In Force from the Decision/Consequences requirement. Re-run Round 2; both artefacts expected to RATIFY without further changes. **Recommended.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:115:- **D5-C: Hybrid** — soften for Reference only; keep enforcement for In Force (argue runbooks DO encode binding policy).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:125:Founder accepted **D5-A**. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` plus new §1-Exemption clause. Reference + In Force status artefacts now exempt from Decision + Alternatives + Consequences requirements (Context + Status line still required for ALL).
docs/decisions/brain-ui-scope.md:4:**Status:** Proposed — revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch)
docs/decisions/brain-ui-scope.md:174:**Proposed:**
docs/decisions/brain-ui-scope.md:201:- §1 (forward-deferral framing — Status: Proposed is structurally appropriate because v1.0 actual-usage evidence is the input v1.1 planning needs).
docs/decisions/brain-ui-scope.md:203:- §3 (α vs β both Proposed — preliminary trade-off table; not binding).
docs/decisions/brain-ui-scope.md:229:**Proposed.** Revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2). At revisit, founder + Claude Code:
docs/decisions/autosend-approval-bridge-spec.md:3:**Status:** Proposed
docs/decisions/autosend-approval-bridge-spec.md:301:**Proposed.** Founder decision pending: build timing (Week 9 OR now).
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:29:**Counter:** `cortexos-primitive-status.md` is an **audit artefact** (Status: Reference per the Day-8 Codex Round 1 cosmetic incorporation). `operational-hygiene-protocol.md` is an **operational runbook** (Status: In Force per Day-6 close `0020521`). Neither is a decision document.
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:31:The skill's enumeration of allowed Status values explicitly includes `Reference` and `In Force` alongside `Proposed | Accepted | Superseded | Deprecated`. By including those values, the skill implicitly accepts that artefacts ratified under `review-architecture-decision.md` may legitimately not be decisions. Enforcing ADR-shape (Context + Decision + Consequences) on audits + runbooks adds ceremony without value:
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:36:**The right fix is to soften the skill, not to retrofit ADR ceremony onto audit + runbook artefacts.** The skill's §1 requirement should exempt Status=Reference + Status=In Force artefacts from the explicit Decision/Consequences subheadings — Context still required (a reader must be able to tell what the artefact is about cold).
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:38:### Proposed skill softening (Founder Decision D5)
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:43:3. Decision section — names the choice, not the deliberation. **Required for Status=Proposed | Accepted artefacts. Exempt for Status=Reference (audits, manifests, inventories) and Status=In Force (runbooks, operational standing policies) — those artefacts encode their "decisions" in the working content itself (audit findings table; runbook procedure steps); a separate Decision heading would be redundant.**
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:45:5. Consequences section — what changes downstream. **Required for Status=Proposed | Accepted artefacts. For Status=Reference + In Force, downstream impact may be inline (e.g., "Day-7 single-sentence test Q2 references this audit") rather than under a dedicated heading.**
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:54:- [x] **Incorporated (Codex correct on Context + Status; counter-argued on Decision/Consequences for Reference + In Force — Founder Decision D5-A accepted 2026-05-22)**
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:58:**Resolution detail (2026-05-22):** Founder accepted D5-A. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` — Reference + In Force status artefacts are now exempt from Decision + Alternatives + Consequences sections (Context + Status update line still required). The two REJECTED artefacts from Round 1 (`cortexos-primitive-status.md`, `operational-hygiene-protocol.md`) are expected to RATIFY in Round 2 without changes. Two new Day-9 artefacts (`architecture-cohesion-review.md` Reference, `tenant-lifecycle.md` In Force) are now ratifiable under the softened skill.
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:62:**D5-A accepted.** Skill softened. Cluster B re-ratification (Round 2) expected to RATIFY `cortexos-primitive-status.md` + `operational-hygiene-protocol.md` without artefact changes. Day-9 Reference + In Force artefacts (`architecture-cohesion-review.md`, `tenant-lifecycle.md`) ratifiable under softened skill.
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:68:- **D5-C**: Hybrid. Soften for Reference; keep for In Force.
docs/decisions/2026-05-18-codex-ratification-manifest.md:17:| 2 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | Accepted | Verify Option A reasoning + edits applied (chokidar → FastChecker landed in atomic-correction commit `0e5b2b4`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:18:| 3 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | Accepted | Verify Option α reasoning + Edits 1+2+3 all applied (3, 4, 12 in atomic-correction manifest) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:21:| 6 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | Accepted | Verify 4 decisions + Edits A+B+C applied (5 in atomic-correction; A+B landed Day 1 evening) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:22:| 7 | `docs/decisions/bullhorn-integration-path.md` | Sub-decision C Accepted; A+B Proposed | Verify Sub-decision C technical analysis; flag A+B as awaiting commercial gates (Q3 unblocker) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:24:| 9 | `docs/decisions/brain-ui-scope.md` | Proposed (pending v1.1) | Verify v1.0/v1.1/v1.2 phasing aligns with §5.5 post-Edit 4 table |
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:32:| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:33:| 18 | `docs/verticals/recruitment/vertical-schema.yaml` | Proposed | Verify 8 entities + 89 fields + 10 relationships + agent R/W matrix + 12 open_questions; cross-check Bullhorn mapping against §4.1 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:34:| 19 | `docs/runbooks/operational-hygiene-protocol.md` | In Force | Verify Path A/D + no-defensive-additions + length calibration + citation accuracy rules; verify §7 audit findings (15 §10.4 fabrications fixed) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:48:| 37 | tenant-lifecycle.md | `docs/runbooks/tenant-lifecycle.md` | review-architecture-decision (In Force; D5 softening applies) | Queued for Round 2 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:119:| 1 | `agents/recruitment/diagnostic/agent.md` | Proposed → Accepted (post-W3 polish) | `review-architecture-decision.md` | Was Round-3 RATIFIED at scaffold form; re-ratify after Day-13 + Step-3 fixes (firm-slug, suffix-strip) + Step-4 LLM §12 wiring |
docs/decisions/2026-05-18-codex-ratification-manifest.md:120:| 2 | `agents/recruitment/diagnostic/tools.yaml` | Proposed | `review-architecture-decision.md` | First ratification (Day-12 scaffold) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:121:| 3 | `agents/recruitment/diagnostic/cycle.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 generator wiring (commit `fd38254`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:122:| 4 | `agents/recruitment/diagnostic/validate.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 V2 awk-pass fix (commit `97a57a2`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:123:| 5 | `packages/diagnostic-generator/` (package as a whole) | Proposed | `review-architecture-decision.md` | Day-13 ship; first ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:124:| 6 | `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` | Accepted | `review-architecture-decision.md` | Day-13 sequencing decision; first ratification |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:287:| 7 | `bullhorn-integration-path.md` Sub-decisions A+B | Proposed pending commercial conversations | Either (a) run the Bullhorn outreach + design-partner #1 conversation during extension and flip to Accepted, OR (b) accept ratification of Sub-decision C only, with A+B explicitly marked "deferred to first pilot's actual ATS confirmation" |
docs/decisions/2026-05-18-codex-ratification-manifest.md:288:| 9 | `brain-ui-scope.md` | Proposed pending v1.1 phase | Likely Codex ratifies as-is post-Edit 8 atomic correction (master brief §6 Day 3 line 472 + §5.5 now consistent). No founder action needed. |
docs/decisions/ADR-004-renderer-implementation-deviations.md:7:**Predecessor:** [ADR-003 — Agent bundle v2 renderer](./ADR-003-agent-bundle-renderer.md) (Accepted)
docs/decisions/ADR-004-renderer-implementation-deviations.md:8:**Status:** Proposed
docs/decisions/ADR-004-renderer-implementation-deviations.md:103:Proposed (Decision 1 ratifies the deviation):
docs/decisions/ADR-004-renderer-implementation-deviations.md:122:Proposed (Decision 2 ratifies the off-by-one correction):
docs/decisions/ADR-004-renderer-implementation-deviations.md:134:Proposed (Decision 1 ratifies the deviation):
docs/decisions/ADR-004-renderer-implementation-deviations.md:158:**Proposed.** Founder review pending. Codex Day-7 queue position 34 (appended after the 33-item Day-8 close). If founder accepts:
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:14:> The document claims Week-1 implementation can proceed before the auth path is cleared. Lines 57-72 list commercial blockers for Sub-decisions A/B, but line 95 says those can remain Proposed without blocking Week-1 implementation. That weakens the Day-7 auth-path quality gate. Fix by making Bullhorn connector scaffolding explicitly conditional on A/B resolution or by narrowing Week-1 work to non-auth code only.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:29:**None of these reference Bullhorn at all.** They are tenant-agnostic + adapter-agnostic substrate. Sub-decisions A+B remaining Proposed (commercial questions about marketplace partnership + dev tenant access) does not block these.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:42:| Janitor build (W5) | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:54:- [ ] Incorporated (Codex correct; rewrite bullhorn-integration-path §95 to make all Week-1 implementation conditional on A+B Accepted)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:58:## §4 — Proposed line 95 sharpening (landed in Round-2 remediation)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:60:Current line 95 (paraphrased): "Sub-decisions A+B remaining Proposed does not block Week-1 implementation."
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:62:Proposed:
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:65:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:67:which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:81:- **Tighten the gate (Codex's read)** — make all Week-1 implementation conditional on A+B Accepted. Forces all 5 Week-1 prereq commits to be re-classified as W5-prereq. Operationally complex + arguably wrong (renderer doesn't need Bullhorn auth to render).
docs/decisions/autosend-safety-policy.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:654:**Proposed.** Founder review pending. Codex Day-7 ratification queued. Expected status progression:
docs/decisions/autosend-safety-policy.md:656:- **Proposed** (this commit) → **Accepted** (post-Codex Day-7) → **In force** (when Week-1 `_shared/hook-helpers.sh` implementation completes)
docs/decisions/v1.0-kill-criterion.md:3:**Status:** Proposed — pending Codex Day-7 ratification
docs/decisions/v1.0-kill-criterion.md:79:**Source:** `sequencing-target.md` §6.6 failure condition (ii); Risk #2 in `docs/RISK-REGISTER.md`; `bullhorn-integration-path.md` Sub-decisions A + B (currently Proposed pending Sunday/Monday commercial conversations — which themselves have not happened due to design-partner-pipeline gap).
docs/decisions/v1.0-kill-criterion.md:393:**Proposed.** Founder review pending. Codex Day-7 ratification queued. Expected progression:
docs/decisions/v1.0-kill-criterion.md:395:- **Proposed** (this commit) → **Accepted** (post-Codex Day-7) → **In force** (immediately upon Acceptance; triggers active for v1.0 build)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:5:**Status:** Accepted (factual recording — not a Proposed decision)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:56:- **Auth path cleared: NO.** Sub-decisions A (marketplace vs direct API) and B (OAuth flow specifics — authorization-code grant against IFOS-owned dev tenant) remain Status: Proposed in `bullhorn-integration-path.md`. The technical path is documented but the commercial gates have not passed:
docs/decisions/2026-05-18-day-7-single-sentence-test.md:60:- **Risk #2 in `docs/RISK-REGISTER.md`** carries Bullhorn auth path status: High while Sub-decisions A and B are Proposed. Reduction trigger to Medium requires the commercial conversations to land.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:67:- **Scoped:** `docs/decisions/ADR-003-agent-bundle-renderer.md` Accepted Day 1 evening with full design spec at `docs/architecture/agent-bundle-renderer-design.md`. 12-row file-by-file translation contract ratified per ADR-003 Decision 3.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:71:- **Risk #5 (renderer-not-built)** in `docs/RISK-REGISTER.md` reduced from Blocking → High on Day 1 evening when ADR-003 + design doc Accepted. Three-stage ladder to Medium (W4 first Diagnostic render) → Low (W13 all 5 v1.0 bundles rendered).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:77:- **Artefact:** `docs/verticals/recruitment/vertical-schema.yaml` Status: Proposed, shipped Day 6 commit `fec8872`.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:92:| 3 | ATS decided + auth cleared? | **NO** | Build decided YES (Bullhorn); auth path NOT cleared (Sub-decisions A+B Proposed, no commercial outreach) |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:93:| 4 | Agent Bundle v2 refactor scoped + <5 days? | **YES** | High — ADR-003 + sequencing-target + design doc all Accepted |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:116:5. **Bullhorn commercial conversations** — `partnerships@bullhorn.com`, Bullhorn dev support, design-partner #1 ATS confirmation. Flips Sub-decisions A+B Proposed → Accepted, reduces Risk #2 from High to Medium, resolves Q3 partially.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:138:Bullhorn commercial conversations (`partnerships@bullhorn.com`, Bullhorn dev support) flip Sub-decisions A+B Proposed → Accepted regardless of Q1 status. These conversations don't unblock Week 1 alone but they reduce Risk #2 from High to Medium and tighten the auth-path readiness.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:161:**Accepted (factual recording).** Recorded in `.agents/current-priorities.md` Day 7 Shipped section. Risk #3 in `docs/RISK-REGISTER.md` updated to reflect Week 0 extension active + Q1 unblocker path. Codex Day-7 ratification manifest produced as Deliverable 3 (sibling artefact in this commit).
docs/decisions/ADR-003-agent-bundle-renderer.md:7:**Status:** Accepted. Founder decision logged 2026-05-16.
docs/decisions/ADR-003-agent-bundle-renderer.md:88:**Proposed:** add `agent-renderer` to the `packages/` enumeration. The line becomes:
docs/decisions/ADR-003-agent-bundle-renderer.md:116:**Proposed:** append a renderer step after merge:
docs/decisions/ADR-003-agent-bundle-renderer.md:135:**Proposed:** insert a one-paragraph footnote at the end of §8 (before §8.1):
docs/decisions/ADR-003-agent-bundle-renderer.md:147:**For Risk #5 (renderer-not-built).** Severity drops from **Blocking** to **High** with ADR-003 Accepted — design exists, ratified; just needs implementing. Drops to **Medium** once renderer code is committed and the Diagnostic agent renders cleanly (Week 4). Drops to **Low** once all five v1.0 agent bundles render and pass validation. The risk register entry is updated in this session as part of the ADR-003 commit.
docs/decisions/ADR-003-agent-bundle-renderer.md:161:**Accepted.** Founder decision logged 2026-05-16. Next steps:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:7:**Status:** Accepted — Option A. Founder decision logged 2026-05-16.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:76:**Accepted — Option A.** Founder decision logged 2026-05-16. The master brief §2.4 row 3 + Ultraplan §3.2 edits are deferred to a single atomic "spec drift reconciliation" commit that lands alongside whatever ADR-002 dictates for §3.4. Codex ratifies the combined commit on Day 7 with the other Week 0 artefacts.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:36:- ADR-006 — Diagnostic Gate A hybrid (Accepted Day 19, Cat-1/Cat-ζ structural close)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:3:**Status:** Accepted (2026-05-24, Day 13)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:29:- **Bullhorn Sub-decisions A + B remain Proposed.** Founder submitted Bullhorn partnerships form 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (commit `dc15692`); response expected 2-5 business days.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:43:| W5 Day 28+: Janitor build start | W5 Day 28+: **Conditional on Bullhorn Sub-decisions A+B Accepted** |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/sequencing-target.md:4:**Status:** Accepted (Day 3 session close, 2026-05-16). Single-pass technical decision, no commercial gating.
docs/decisions/sequencing-target.md:277:### 4.1 — Ratified sequence (Status: Accepted)
docs/decisions/sequencing-target.md:288:**Status: Accepted** as the v1.0 plan of record. Binds Week 3-13 build cadence subject to §4.3 revisit conditions.
docs/decisions/sequencing-target.md:300:**Trigger 1 — Risk #2 materialises in Week 4-5.** If Bullhorn auth path breaks (Day 2 Sub-decisions A or B don't flip to Accepted, marketplace required but unobtainable, OAuth flow blocks deployment, or per-tenant client_id ticket cycle slows past 5 business days per `bullhorn-integration-path.md` §1.3 row 5):
docs/decisions/sequencing-target.md:323:**Binds (Status: Accepted, no further sub-decision needed at this level of granularity):**
docs/decisions/sequencing-target.md:408:First exercise is Janitor at W5 per §4.1 row 2. **If Day 2 Sub-decisions A and B haven't flipped from Proposed to Accepted by start of W4** (per `bullhorn-integration-path.md` §1.3 commercial-blocker table), this is the natural blocker. Founder Sunday/Monday commercial conversations must land before W4 start to keep the Janitor W5 slot intact. Sub-decision C is already Accepted so the endpoint surface is buildable; the gate is auth path (A) and client_credentials foreclosure (B).
docs/decisions/sequencing-target.md:410:§4.3 Trigger 1 activation point: end of W4 weekly review if Sub-decisions A and B still Proposed.
docs/decisions/sequencing-target.md:416:- Risk #5 was **Blocking** at Day 1 morning, **High** at Day 1 evening extension (ADR-003 Accepted).
docs/decisions/sequencing-target.md:461:**Proposed:**
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** Proposed (2026-05-25, Day 20; W4 bilateral pass on Concierge agent.md surfaced this as Codex R3 Finding 3 — current scaffold reframes ULTRAPLAN A6 line 566 Gate A "every lifecycle event has a draft generated within 30 minutes" as a Gate B leading metric without an authoritative ADR backing the deviation. Awaits Codex `review-architecture-decision` ratification + founder Accept.)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:7:**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — Codex flags Concierge `agent.md` §5 line 278 reframes the 30-min SLA as Gate B without an ADR; §10 Accepted criteria omits any ADR-ratification blocker for this deviation. Analogue of ADR-006 (Diagnostic Gate A hybrid).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:28:> The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:92:3. The Concierge agent.md §10 Accepted criteria must include ratification of this ADR as a blocker (closing Codex R3 Finding 3 properly)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:113:Add to Accepted blockers (after R3 commit `f79c018` baseline):
docs/decisions/bullhorn-integration-path.md:4:**Status:** Proposed (Sub-decision C Accepted technically; Sub-decisions A + B Proposed pending commercial verification per §1.3)
docs/decisions/bullhorn-integration-path.md:46:Honest accounting of which sub-decisions can land tonight from technical analysis alone versus which require commercial verification before the Status flips from Proposed to Accepted.
docs/decisions/bullhorn-integration-path.md:57:**Commercially gated (founder must verify before final Status flip to Accepted on Sub-decisions A and B):**
docs/decisions/bullhorn-integration-path.md:81:  - Sub-decision C in full — technical analysis, per-agent endpoint table, webhook-vs-poll decisions, rate-limit budget allocation. **Status: Accepted** on Sub-decision C alone, no commercial gating.
docs/decisions/bullhorn-integration-path.md:82:  - Sub-decisions A and B — full technical analysis (Sections 2 and 3 of this document), with explicit Status: Proposed flags pointing at the §1.3 commercial-blocker table.
docs/decisions/bullhorn-integration-path.md:83:  - Recommendation block (§5) names the technical preference, the commercial-answer conditions that flip Status to Accepted, and the documented v1.0-scope-cut contingency if commercial answers go badly.
docs/decisions/bullhorn-integration-path.md:90:  - Document is re-committed with Status: Accepted on A and B once founder logs the decision.
docs/decisions/bullhorn-integration-path.md:92:  - Single-sentence test Q3 ("Have we cleared the auth path?") answered Yes iff Sub-decisions A and B are Accepted.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:105:| Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/bullhorn-integration-path.md:177:### 2.4 — Technical recommendation (Proposed)
docs/decisions/bullhorn-integration-path.md:196:**Status: Proposed.** Status flips to Accepted on either: (a) partnerships@bullhorn confirms marketplace is not required for v1.0 production tenant access AND first design partner uses Bullhorn; OR (b) founder explicitly accepts the documented fallback if marketplace turns out required, and re-cuts the v1.0 timeline to absorb the marketplace certification window.
docs/decisions/bullhorn-integration-path.md:254:### 3.4 — Technical recommendation (Proposed)
docs/decisions/bullhorn-integration-path.md:271:**Status: Proposed.** Status flips to Accepted on commercial verification answers to the four questions above. Most likely outcome: confirmation of the §3.4 recommendation as stated, with one or two clarifications absorbed into the renderer's auth-module implementation.
docs/decisions/bullhorn-integration-path.md:277:Fully technical. **Status: Accepted** on first pass — no commercial gating.
docs/decisions/bullhorn-integration-path.md:367:**Sub-decision A — Marketplace vs direct API. Status: Proposed.**
docs/decisions/bullhorn-integration-path.md:371:Status flips to Accepted when **all three** commercial conditions per §1.3 land:
docs/decisions/bullhorn-integration-path.md:379:**Sub-decision B — OAuth flow. Status: Proposed.**
docs/decisions/bullhorn-integration-path.md:383:Status flips to Accepted when commercial verification answers the four questions per §3.4:
docs/decisions/bullhorn-integration-path.md:392:**Sub-decision C — v1.0 endpoint surface. Status: Accepted.**
docs/decisions/bullhorn-integration-path.md:436:- Sub-decision C Accepted status is justified by §4's technical analysis grounded in verified Bullhorn public-doc citations.
docs/decisions/bullhorn-integration-path.md:437:- Sub-decisions A and B Proposed status has named, measurable reduction triggers (not aspirational).
docs/decisions/bullhorn-integration-path.md:448:**Proposed:**
docs/decisions/bullhorn-integration-path.md:456:**Current state after Day 2:** severity stays **High** while Sub-decisions A and B are Proposed. Status of three sub-decisions: A Proposed, B Proposed, C Accepted.
docs/decisions/bullhorn-integration-path.md:458:**Reduction trigger 1 (High → Medium):** Sub-decisions A and B flip to Accepted (commercial answers from Sunday/Monday conversations land + design partner ATS confirmed).
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:7:**Status:** Accepted — Option α. Founder decision logged 2026-05-16.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:83:**Proposed:** "IFOS implements its second brain as a **parallel system**, not by shadowing cortextOS's stock knowledge base. cortextOS's `bus/kb-*.sh` files (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh` at SHA `c21fbfe`) remain untouched and continue to serve cortextOS-template agents. IFOS agents invoke a parallel wrapper surface at `packages/brain/bus-overrides/wiki-*.sh` (9 v1.0 + 1 v1.1 stub) that dispatches to `packages/brain/wiki/lib/` against Postgres + filesystem markdown. The §3.1 'four `bus/kb-*.sh` shadow points' edit-exception is unused — IFOS does not edit any file under `packages/harness/cortextos/`. See `docs/architecture/second-brain-design.md` for the full design."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:91:**Proposed** (per design §3.4):
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:101:**Proposed:**
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:131:**Accepted — Option α.** Founder decision logged 2026-05-16. Next steps:

codex
REJECTED

1. Header status is not an allowed scaffold status. Line 3 uses `Pre-Build-Round-4-Bilateral-Applied`, while §9 line 322 says `Status: Proposed`; the agent-bundle skill defines pre-build scaffolds as `Status: Proposed`, and the top-level honest-signal rule requires a clear Proposed/Accepted/In Force state. Fix: make the header `Status: Proposed` and move round-history into a separate review-note sentence.

2. The v0.3 schema ratification claim is false. Line 81 says `vertical-schema.v0.3-supplement.yaml` is `RATIFIED commit 7b4f390`, but that source file states `Status: Proposed` at lines 3 and 38. Fix: either ratify the supplement first or change this agent.md to say these fields depend on the Proposed v0.3 supplement.

3. Step 7 uses an unregistered autosend action type. Line 191 calls `hh_decision_action("scribe_gate_a_fail", ...)`, but `agents/_shared/autosend-policy.yaml` registers `validate_gate_a_fail` and does not register `scribe_gate_a_fail`. Fix: use `validate_gate_a_fail` or add `scribe_gate_a_fail` to the runtime autosend policy before referencing it.

4. §6 references an invented ESC code. Line 273 cites `ESC_BULLHORN_OAUTH_REVOKED`, but `agents/_shared/escalation-codes.md` contains no such code. Fix: remove the reference or add the code to the catalogue before this agent.md cites it.

5. `ESC_SCRIBE_SLA_MISS` is used with a threshold that does not match the catalogue. Line 211 fires it at `elapsed > 600` seconds, while line 266 cites the catalogue definition of summary-render >30 min or note-attach >1h. Fix: amend the catalogue to include the 10-minute Bullhorn-note SLA or stop using this ESC code for the 10-minute warning.
tokens used
86,652
REJECTED

1. Header status is not an allowed scaffold status. Line 3 uses `Pre-Build-Round-4-Bilateral-Applied`, while §9 line 322 says `Status: Proposed`; the agent-bundle skill defines pre-build scaffolds as `Status: Proposed`, and the top-level honest-signal rule requires a clear Proposed/Accepted/In Force state. Fix: make the header `Status: Proposed` and move round-history into a separate review-note sentence.

2. The v0.3 schema ratification claim is false. Line 81 says `vertical-schema.v0.3-supplement.yaml` is `RATIFIED commit 7b4f390`, but that source file states `Status: Proposed` at lines 3 and 38. Fix: either ratify the supplement first or change this agent.md to say these fields depend on the Proposed v0.3 supplement.

3. Step 7 uses an unregistered autosend action type. Line 191 calls `hh_decision_action("scribe_gate_a_fail", ...)`, but `agents/_shared/autosend-policy.yaml` registers `validate_gate_a_fail` and does not register `scribe_gate_a_fail`. Fix: use `validate_gate_a_fail` or add `scribe_gate_a_fail` to the runtime autosend policy before referencing it.

4. §6 references an invented ESC code. Line 273 cites `ESC_BULLHORN_OAUTH_REVOKED`, but `agents/_shared/escalation-codes.md` contains no such code. Fix: remove the reference or add the code to the catalogue before this agent.md cites it.

5. `ESC_SCRIBE_SLA_MISS` is used with a threshold that does not match the catalogue. Line 211 fires it at `elapsed > 600` seconds, while line 266 cites the catalogue definition of summary-render >30 min or note-attach >1h. Fix: amend the catalogue to include the 10-minute Bullhorn-note SLA or stop using this ESC code for the 10-minute warning.
