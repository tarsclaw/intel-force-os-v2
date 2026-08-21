Reading prompt from stdin...
OpenAI Codex v0.132.0
--------
workdir: /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
model: gpt-5.5
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR]
reasoning effort: none
reasoning summaries: none
session id: 019eb1ad-7c7f-7e00-8e03-41e8d47a5054
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
**Reading-discipline note (added 2026-06-03 per Codex Fbis-R3 closure pattern + CC + Concierge + Janitor precedent):** this `agent.md` is the **CONTRACT** that the W6 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `e6028e6` + `f9b4a84` + `b3819e7` + `d314661` + `313be44` per W5 Day-32); they carry `TODO(W6)` markers throughout that the W6 build slice replaces with live implementation matching the contract below. **VENDOR DELTA**: this `agent.md` (W3 cluster E review state — Status banner says Proposed but the review ran) describes a WEBHOOK-DRIVEN flow from Fathom/Fireflies (§2 + §4 Step 1 webhook signature verification + §6 ESC_PROVIDER_FETCH_FAIL row + §8 Fathom/Fireflies commercial signup dependency); the deployed SKELETON uses POLLING from Granola per Day-29 vendor pivot (founder confirmed 2026-06-03 — see `goal-week-5-execution-plan.md` §2 Phase 3 fix-forward + the `@ifos/granola` wrapper scaffold landed commit `1b657e6`). Granola does NOT publish webhooks per `@ifos/granola` README §"Scribe consumption pattern" — `cycle.sh` handles BOTH the outer poll-sweep loop AND the per-meeting Steps 0-10 internally. **W6 ratification updates this `agent.md` to match deployed Granola polling reality** (vendor swap; webhook → polling; Step 1 "signature verification" → "Granola transcript fetch"). **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON `cycle.sh` emits only the minimal trigger/output markers (`session_start`, `granola_meetings_polled`, `bullhorn_auth_refresh`, `transcript_fetched`, `entity_resolved`, `fields_extracted`, `tacit_note_rendered`, `fields_validated`, `dry_run_writes_skipped`, `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`, `scribe_run_complete`) at `cycle.sh` lines 130, 156, 178, 195, 211, 226, 243, 259, 268, 285, 301, 319.** The yellow-tier audit rows the contract names (`bullhorn_scribe_field_write` + `bullhorn_note_append_summary`) are NOT yet emitted at runtime — they're the W6 contract surface, not current behavior. The SKELETON `context.sh` uses **env-var fallbacks** today (`IFOS_FORCE_BULLHORN_CORPORATION_ID`, `IFOS_FORCE_GRANOLA_WORKSPACE_ID`, `IFOS_FORCE_GRANOLA_PLAN_TIER`, `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID`) even though the v0.4 schema supplement LANDED 2026-06-03 (commit `a1bbcf6` + LIVE on VPS) made the canonical `SELECT config->>'<key>' FROM tenant_adapters` path schema-clean for `bullhorn_corporation_id` + `granola_workspace_id` — that wiring lands at W6 alongside the `@ifos/bullhorn` + `@ifos/granola` refresh integrations. Don't read agent.md as a description of running code; read it as the spec the W6 build slice implements after the vendor pivot is acknowledged.
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

Length cap: 800 words. Voice-classified (≥0.75). Persistent classifier failure (after 3 retries) is a **hard Gate A failure** — fires `ESC_VOICE_DRIFT` + `validate_gate_a_fail`; the note is NOT attached to Bullhorn (Step 9 is skipped) and is held as a `/tmp`/vault draft flagged "needs consultant review" for manual handling. The placeholder is explicitly a non-success state, never a passing output.

Each tacit-note write emits its own `decision_log` rows: on vault render, `agent_name='scribe'`, `phase='output'`, `output_type='tacit_note_rendered'` carrying `{vault_path, body_sha256, voice_score}` (body NOT in payload per ADR-002 vault/Postgres split); on Bullhorn attach, `phase='action'`, `action_type='bullhorn_note_append_summary'`, `tier='yellow'`, payload carrying `note_payload_hash` + `payload_preview` + the resolved `<entity_type>:<bullhorn_id>` (per §4 Steps 6 + 9).

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
     in agents/_shared/autosend-policy.yaml line 119; agent:all; Scribe uses
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

Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing; likely indicates LLM prompt drift or taxonomy mismatch).

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
| `ESC_GATE_B_MISS` | Both Gate B metrics (≥90% within-5-min SLA AND ≤20% structured-field edit-rate) below target for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
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
I’ll verify the agent contract against the local source files the artefact cites, focusing on section order, schema fields, escalation codes, autosend action types, and the current Scribe bundle reality.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
     1	# Scribe — the data spine
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
     5	**Reading-discipline note (added 2026-06-03 per Codex Fbis-R3 closure pattern + CC + Concierge + Janitor precedent):** this `agent.md` is the **CONTRACT** that the W6 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `e6028e6` + `f9b4a84` + `b3819e7` + `d314661` + `313be44` per W5 Day-32); they carry `TODO(W6)` markers throughout that the W6 build slice replaces with live implementation matching the contract below. **VENDOR DELTA**: this `agent.md` (W3 cluster E review state — Status banner says Proposed but the review ran) describes a WEBHOOK-DRIVEN flow from Fathom/Fireflies (§2 + §4 Step 1 webhook signature verification + §6 ESC_PROVIDER_FETCH_FAIL row + §8 Fathom/Fireflies commercial signup dependency); the deployed SKELETON uses POLLING from Granola per Day-29 vendor pivot (founder confirmed 2026-06-03 — see `goal-week-5-execution-plan.md` §2 Phase 3 fix-forward + the `@ifos/granola` wrapper scaffold landed commit `1b657e6`). Granola does NOT publish webhooks per `@ifos/granola` README §"Scribe consumption pattern" — `cycle.sh` handles BOTH the outer poll-sweep loop AND the per-meeting Steps 0-10 internally. **W6 ratification updates this `agent.md` to match deployed Granola polling reality** (vendor swap; webhook → polling; Step 1 "signature verification" → "Granola transcript fetch"). **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON `cycle.sh` emits only the minimal trigger/output markers (`session_start`, `granola_meetings_polled`, `bullhorn_auth_refresh`, `transcript_fetched`, `entity_resolved`, `fields_extracted`, `tacit_note_rendered`, `fields_validated`, `dry_run_writes_skipped`, `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`, `scribe_run_complete`) at `cycle.sh` lines 130, 156, 178, 195, 211, 226, 243, 259, 268, 285, 301, 319.** The yellow-tier audit rows the contract names (`bullhorn_scribe_field_write` + `bullhorn_note_append_summary`) are NOT yet emitted at runtime — they're the W6 contract surface, not current behavior. The SKELETON `context.sh` uses **env-var fallbacks** today (`IFOS_FORCE_BULLHORN_CORPORATION_ID`, `IFOS_FORCE_GRANOLA_WORKSPACE_ID`, `IFOS_FORCE_GRANOLA_PLAN_TIER`, `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID`) even though the v0.4 schema supplement LANDED 2026-06-03 (commit `a1bbcf6` + LIVE on VPS) made the canonical `SELECT config->>'<key>' FROM tenant_adapters` path schema-clean for `bullhorn_corporation_id` + `granola_workspace_id` — that wiring lands at W6 alongside the `@ifos/bullhorn` + `@ifos/granola` refresh integrations. Don't read agent.md as a description of running code; read it as the spec the W6 build slice implements after the vendor pivot is acknowledged.
     6	**Date:** 2026-05-24.
     7	**Author:** Founder (Maddox) + Claude Code.
     8	**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
     9	**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
    10	**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
    11	
    12	---
    13	
    14	## §1 — Output contract (one-paragraph screenshot)
    15	
    16	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    17	
    18	> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
    19	
    20	---
    21	
    22	## §2 — Invocation surface
    23	
    24	### Webhook (v1.0 primary path)
    25	
    26	```http
    27	POST https://<tenant>.ifos.app/agents/scribe/webhook
    28	Authorization: Bearer <fathom-or-fireflies-shared-secret>
    29	Content-Type: application/json
    30	
    31	{
    32	  "provider": "fathom" | "fireflies",        // v1.0
    33	  // "ringover" added in v1.1+ — not in v0 build per §8 dependencies
    34	  "call_id": "<provider-call-id>",
    35	  "transcript_url": "<provider-transcript-url>",
    36	  "duration_seconds": 1234,
    37	  "participants": [...],
    38	  "metadata": {...}
    39	}
    40	```
    41	
    42	v1.0 supports Fathom (HMAC-SHA256 signed) and Fireflies (bearer token) providers; auth handled per-provider in `tools.yaml` capability declarations. Ringover (OAuth-protected) is deferred to v1.1+ — not in the v0 build dependencies and not registered in v1.0 `tools.yaml`.
    43	
    44	### Manual trigger (v1.0 — debugging / replay)
    45	
    46	```bash
    47	ifosctl scribe replay --tenant <slug> --call-id <provider-call-id>
    48	```
    49	
    50	Useful when a webhook was missed or a transcript needs reprocessing after taxonomy update.
    51	
    52	### v1.1+ surfaces (deferred)
    53	
    54	- Telegram command (`@ifos_bot scribe replay <call-id>`)
    55	- Brain UI per-call "Reprocess" button
    56	- Brain UI "Confidence audit" view showing extraction confidence histograms
    57	
    58	---
    59	
    60	## §3 — Output shape
    61	
    62	Two outputs per webhook. Both write atomically (one transaction); rollback on either failure.
    63	
    64	### Output 1 — Bullhorn structured-field writes (≥3 per call)
    65	
    66	Bullhorn entity inferred from call participants + tenant Bullhorn lookup:
    67	- 1:1 call with candidate → Candidate entity update
    68	- 1:1 call with client contact → Contact entity update
    69	- Briefing call (consultant + client) → Brief entity update
    70	- Placement check-in (consultant + placed candidate) → Placement entity update
    71	- Opportunity scoping (consultant + prospect) → Opportunity entity update (NOTE: Bullhorn endpoint A3 row covers Candidate / ClientCorporation / JobOrder / Note / Placement only at v1.0; Opportunity writes are to IFOS-cached Postgres entity rows for the v0.3-added fields headcount_growth_signal_text + hiring_velocity_band + decision_window_text per v0.3 supplement §1, NOT direct Bullhorn endpoint calls)
    72	
    73	Minimum 3 fields extracted per call (Gate A). Canonical fields by entity (names per `vertical-schema.yaml` v0.1 + v0.2):
    74	
    75	| Entity | Canonical fields (schema-verified) |
    76	|---|---|
    77	| Candidate | `location`, `current_role`, `notice_period_weeks`, `salary_expectation_min` + `salary_expectation_max`, `employment_type` (v0.3; enum per supplement §1), `key_skills` (v0.3; list) |
    78	| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
    79	| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
    80	| Placement | `start_date`, `placement_status` (v0.3), `week_1_status_vault_path` (v0.3; vault pointer, not narrative), `satisfaction_signal` (v0.3) |
    81	| Opportunity | `headcount_growth_signal_text` (v0.3), `hiring_velocity_band` (v0.3), `decision_window_text` (v0.3) |
    82	
    83	Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
    84	
    85	Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
    86	
    87	### Output 2 — Tacit-note Markdown attachment
    88	
    89	One Markdown note per call, attached to the same Bullhorn entity as Output 1 via `POST /Note`. Structure:
    90	
    91	```markdown
    92	# Tacit notes — <Call-context-summary>
    93	**Date:** <ISO-date>  **Duration:** <N> min  **Participants:** <list>
    94	
    95	## Things observed that don't fit a structured field
    96	
    97	- <Observation 1 — bullet, 1-2 sentences, with transcript timestamp [MM:SS]>
    98	- <Observation 2 — ...>
    99	- ...
   100	
   101	## Tone signals
   102	
   103	- <Tone signal 1 — e.g., "client sounded frustrated about Bullhorn data quality">
   104	- <Tone signal 2 — ...>
   105	
   106	## Open questions for consultant follow-up
   107	
   108	- <Open question 1>
   109	- <Open question 2>
   110	```
   111	
   112	Length cap: 800 words. Voice-classified (≥0.75). Persistent classifier failure (after 3 retries) is a **hard Gate A failure** — fires `ESC_VOICE_DRIFT` + `validate_gate_a_fail`; the note is NOT attached to Bullhorn (Step 9 is skipped) and is held as a `/tmp`/vault draft flagged "needs consultant review" for manual handling. The placeholder is explicitly a non-success state, never a passing output.
   113	
   114	Each tacit-note write emits its own `decision_log` rows: on vault render, `agent_name='scribe'`, `phase='output'`, `output_type='tacit_note_rendered'` carrying `{vault_path, body_sha256, voice_score}` (body NOT in payload per ADR-002 vault/Postgres split); on Bullhorn attach, `phase='action'`, `action_type='bullhorn_note_append_summary'`, `tier='yellow'`, payload carrying `note_payload_hash` + `payload_preview` + the resolved `<entity_type>:<bullhorn_id>` (per §4 Steps 6 + 9).
   115	
   116	Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
   117	1. Relationship signal (client warmth, candidate enthusiasm, prior friction)
   118	2. Process friction (consultant complaint, tool gap, time waste)
   119	3. Competitive intel (mentions of competitor agencies / candidates working with others)
   120	4. Pricing/budget signal (off-record indications of room or constraint)
   121	5. Decision-process insight (who actually decides; coffee-machine politics)
   122	6. Calendar / availability nuance (vacation, life events affecting timeline)
   123	7. Cultural fit observation (working style, communication preferences)
   124	8. Risk flag (legal, IR35, compliance, reference concerns)
   125	
   126	v1.1+: expand taxonomy based on first 3 pilot tenants' patterns.
   127	
   128	---
   129	
   130	## §4 — Workflow
   131	
   132	10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   133	
   134	```
   135	0. Session start (webhook handler)
   136	   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice
   137	     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
   138	   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
   139	
   140	1. Webhook signature verification
   141	   → per-provider HMAC / bearer / OAuth check
   142	   → ESC_INPUT_VALIDATION_FAIL on signature mismatch; reject with 401
   143	   → record provider + call_id in trigger payload
   144	   → hh_decision_output("webhook_verified", "call:<id>", "provider:<name>")
   145	
   146	2. Bullhorn auth refresh
   147	   → bullhorn.refresh_access_token() per per-agent 8-min refresh loop
   148	   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
   149	   → hh_decision_output("bullhorn_auth_refreshed", "tenant:<slug>", "result:ok")
   150	
   151	3. Transcript fetch
   152	   → provider-specific: fathom.get_transcript(call_id) | fireflies.get(...)
   153	   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
   154	   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
   155	   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
   156	   → hh_decision_output("transcript_fetched", "call:<id>",
   157	     "provider:<name>; bytes:<N>; tmp_path:/tmp/scribe-<tenant>-<call_id>.txt")
   158	
   159	4. Participant + entity inference
   160	   → match transcript participants against Bullhorn contacts + candidates
   161	     + consultant accounts (per tenant config)
   162	   → infer call context (1:1 vs briefing vs placement vs opportunity)
   163	   → resolve target Bullhorn entity (bullhorn_id + entity_type per
   164	     vertical-schema.yaml canonical id field)
   165	   → ESC_AGENT_OUTPUT_SHAPE if no resolvable entity (output shape violation:
   166	     a Scribe run with no resolvable target cannot produce structured writes)
   167	   → hh_decision_output("entity_resolved", "<entity_type>:<bullhorn_id>", confidence)
   168	
   169	5. LLM field extraction
   170	   → prompt = (transcript + entity context + vertical-schema entity field list
   171	     + 3 voice-corpus examples)
   172	   → output = JSON with per-field confidence scores
   173	   → discard fields confidence <0.6 (per Gate A)
   174	   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
   175	   → hh_decision_output("fields_extracted", "<entity_type>:<bullhorn_id>",
   176	     "<N> fields ≥0.6 confidence")
   177	
   178	6. LLM tacit-note generation
   179	   → prompt = (transcript + 8-category taxonomy + 3 voice-corpus examples
   180	     + tone-rule filter)
   181	   → output = Markdown narrative per §3 Output 2 shape
   182	   → voice classifier scores against tenant style guide
   183	   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
   184	   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md
   185	   → hh_decision_output("tacit_note_rendered", "<vault_path>",
   186	     "voice_score:<N>; words:<N>")
   187	
   188	7. Field-extraction validation against vertical-schema
   189	   → verify each extracted field name exists in target entity schema
   190	   → verify each extracted value passes per-field type/range checks
   191	   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION
   192	     per catalogue line 163 — vertical-schema field-constraint violation at write time)
   193	   → on success: hh_decision_output("fields_validated", "<entity_type>:<bullhorn_id>",
   194	     "<N> valid of <M> extracted; dropped:<N-invalid>")
   195	   → on Gate A failure (<3 valid): hh_decision_action("validate_gate_a_fail",
   196	     "<entity_type>:<bullhorn_id>", payload_hash,
   197	     "ESC_SCHEMA_VIOLATION; agent_name:scribe; valid:<N>") and exit 1
   198	     (validate_gate_a_fail is the canonical green-tier action_type registered
   199	     in agents/_shared/autosend-policy.yaml line 119; agent:all; Scribe uses
   200	     the shared signature with agent_name in payload to distinguish.)
   201	
   202	8. Bullhorn write — structured fields (yellow tier)
   203	   → PATCH /<EntityType>/<id> with field map
   204	   → atomic transaction; rollback on Bullhorn 4xx/5xx
   205	   → on success: hh_decision_action("bullhorn_scribe_field_write",
   206	     "<entity_type>:<bullhorn_id>", payload_hash, payload_preview)
   207	   → on failure: ESC_BULLHORN_WRITE_FAIL; do NOT proceed to Step 9
   208	
   209	9. Bullhorn write — tacit-note attachment (yellow tier)
   210	   → POST /Note linked to entity from Step 4 (mirror of vault artefact from Step 6)
   211	   → on success: hh_decision_action("bullhorn_note_append_summary",
   212	     "<entity_type>:<bullhorn_id>", note_payload_hash, payload_preview)
   213	   → on failure: rollback Step 8 (best-effort PATCH /<EntityType>/<id>
   214	     reversing the field changes); ESC_BULLHORN_WRITE_FAIL
   215	
   216	10. Session close + SLA metric
   217	   → compute elapsed_seconds from webhook receipt
   218	   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
   219	     10 min". Catalogue ESC_SCRIBE_SLA_MISS triggers (line 443): "summary-render
   220	     >30 min OR note-attach >1h after call end". The two thresholds are
   221	     different scopes — master brief 10-min is the product UX promise; catalogue
   222	     30-min/1h is the alerting threshold (less false alarms).
   223	   → if elapsed > 3600 (1h): fire ESC_SCRIBE_SLA_MISS with `sla_type=note_attach` (per catalogue)
   224	   → if elapsed > 1800 (30 min): fire ESC_SCRIBE_SLA_MISS with `sla_type=summary_render` (per catalogue)
   225	   → if elapsed > 600 (10 min) but ≤ 1800: NO ESC fire — recorded as Gate B
   226	     "10-min miss" in the day-30 report aggregation; counts against Gate B 90% target
   227	   → if elapsed > 300 (5 min) but ≤ 600: info-level (still under product promise)
   228	   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
   229	   → exit code 0
   230	```
   231	
   232	---
   233	
   234	## §5 — Gates
   235	
   236	### Gate A — validate.sh (hard-fail before action)
   237	
   238	Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:
   239	
   240	- Webhook signature valid per provider (Step 1)
   241	- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
   242	- 1 tacit-note generated with voice classifier ≥0.75
   243	- Field names exist in target entity per vertical-schema.yaml
   244	- Per-field type + range validation passes
   245	- No PII outside firm boundary in tacit-note narrative
   246	- Bullhorn auth refresh succeeded
   247	
   248	Gate A failures fire `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` (extraction quality) or `ESC_AGENT_OUTPUT_SHAPE` (output-shape violation: insufficient fields or no resolvable entity) or `ESC_SCHEMA_VIOLATION` (field-constraint violation at vertical-schema write-time per catalogue line 163); transcript stays in `/tmp` (auto-purged 24h); operator notified.
   249	
   250	**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   251	
   252	### Gate B — Outcome thresholds (success metrics, not block)
   253	
   254	Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
   255	
   256	Two metrics:
   257	- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
   258	- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
   259	
   260	Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_BULLHORN_WRITE_FAIL|ESC_PROVIDER_FETCH_FAIL|ESC_VOICE_DRIFT|ESC_FIELD_EXTRACTION_LOW_CONFIDENCE|ESC_PII_LEAKAGE_RISK|ESC_INPUT_VALIDATION_FAIL|ESC_AGENT_OUTPUT_SHAPE|ESC_SCHEMA_VIOLATION|ESC_SCRIBE_SLA_MISS|ESC_GATE_B_MISS|ESC_RATE_LIMIT_HIT|ESC_AUTOSEND_SAMPLED_SPOT_CHECK|validate_gate_a_fail|bullhorn_scribe_field_write|bullhorn_note_append_summary|scribe_run_complete" agents/_shared docs -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:83:  scribe_run_complete:
agents/_shared/autosend-policy.yaml:119:  validate_gate_a_fail:
agents/_shared/autosend-policy.yaml:122:    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
agents/_shared/autosend-policy.yaml:128:    reason: "Internal audit row written by cycle.sh Step 1 when firm-name validation fails. Carries ESC_INPUT_VALIDATION_FAIL payload; just the audit-row write, not external send."
agents/_shared/autosend-policy.yaml:134:    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
agents/_shared/autosend-policy.yaml:212:  bullhorn_note_append_summary:
agents/_shared/autosend-policy.yaml:240:  bullhorn_scribe_field_write:
agents/_shared/escalation-codes.md:97:#### `ESC_BULLHORN_AUTH`
agents/_shared/escalation-codes.md:120:#### `ESC_VOICE_DRIFT`
agents/_shared/escalation-codes.md:148:#### `ESC_PII_LEAKAGE_RISK`
agents/_shared/escalation-codes.md:156:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:163:#### `ESC_SCHEMA_VIOLATION`
agents/_shared/escalation-codes.md:170:#### `ESC_VOICE_DRIFT_TENANT`
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:177:#### `ESC_INPUT_VALIDATION_FAIL`
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
agents/_shared/escalation-codes.md:310:#### `ESC_BULLHORN_WRITE_FAIL`
agents/_shared/escalation-codes.md:312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:324:#### `ESC_PROVIDER_FETCH_FAIL`
agents/_shared/escalation-codes.md:366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
agents/_shared/escalation-codes.md:441:#### `ESC_SCRIBE_SLA_MISS`
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:161:3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:216:3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:261:- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:306:- Diagnostic validate.sh: emits `ESC_SCHEMA_VIOLATION` not the specific codes declared in §6; doesn't write skip rows when honesty-flagging
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:363:- `validate.sh` emits specific §6 ESC codes (ESC_PII_LEAKAGE_RISK or ESC_AGENT_OUTPUT_SHAPE) not generic ESC_SCHEMA_VIOLATION
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:121:- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:10:> 3. §4 Gate-A failure signature is incomplete. Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature.
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:14:Codex's quote stops at line 119 ("...carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`"), but the file's statement spans lines 117-121 — and ESC_VOICE_DRIFT IS listed at lines 119-120. The full text (verbatim from the file at R16 close commit `4854b37`, unchanged at R17):
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:17:117  → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:18:118    with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:19:119    section count / citation / length failures; ESC_VOICE_DRIFT for V3
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:20:120    voice-classifier-score-low failures; ESC_PII_LEAKAGE_RISK for PII
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:24:Lines 119-120 explicitly include `ESC_VOICE_DRIFT for V3 voice-classifier-score-low failures`. The signature is complete; this was already addressed at R15 commit `23f8c14` ("voice-classifier honesty + ESC_VOICE_DRIFT routing + LinkedIn-stub honesty + recent_edits signature").
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:37:- R15 commit `23f8c14` — original ESC_VOICE_DRIFT routing add
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
docs/decisions/bullhorn-integration-path.md:484:| §4.5 (architectural emergence) | §4.5 | Access-token refresh-loop: per-agent background task, 8-minute cycle, retry-once-then-`ESC_BULLHORN_AUTH` |
docs/decisions/bullhorn-integration-path.md:502:| `ESC_BULLHORN_AUTH` escalation code wired into `agents/_shared/escalation-codes.md` | Claude Code | Week 1-2 (alongside `_shared/hook-helpers.sh` Week-1 prereq from ADR-002) |
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:49:- Aggregate failures fire `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) when sustained — same operational lever as ADR-006's per-claim quality metric
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:72:- ✅ No PII outside firm boundary — Gate A hard-fail (`ESC_PII_LEAKAGE_RISK`)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:74:- ✅ All Bullhorn context fields present — Gate A hard-fail (`ESC_AGENT_OUTPUT_SHAPE`)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:80:- Rolling 30-day per-tenant aggregate <90% fires `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) — actionable signal
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:89:> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:131:| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Resolved: separate code, for clean Telegram routing (`_GATE_B_MISS` is the generic aggregate). `ESC_CONCIERGE_SLA_MISS` is already registered in `escalation-codes.md` lines 431-439 — no longer queued. |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:139:- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/specs/ULTRAPLAN.md:182:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/specs/ULTRAPLAN.md:183:- `ESC_BULLHORN_AUTH` — Bullhorn OAuth token expired or revoked
docs/specs/ULTRAPLAN.md:187:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/specs/ULTRAPLAN.md:188:- `ESC_RATE_LIMIT_HIT` — upstream API (LinkedIn especially) rate limited
docs/specs/ULTRAPLAN.md:189:- `ESC_SCHEMA_VIOLATION` — agent produced output that violates the vertical schema (e.g., a "placement" with no candidate)
docs/specs/ULTRAPLAN.md:354:If any hard fail, the agent regenerates with the failure reason injected as additional context ("your previous draft used the banned phrase 'I hope this finds you well'; rewrite avoiding it"). After 3 retries with hard fails, escalate with `ESC_VOICE_DRIFT` or `ESC_SCHEMA_VIOLATION`.
docs/specs/ULTRAPLAN.md:376:If the rolling 4-week average drops by ≥5 percentage points: `ESC_VOICE_DRIFT_TENANT` fires. Email goes to the customer's primary contact AND to the internal CS Slack:
docs/specs/ULTRAPLAN.md:566:- **Gate A:** voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82 per escalation_position); correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/build-brief/00-MASTER-BRIEF.md:580:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/build-brief/00-MASTER-BRIEF.md:581:- `ESC_BULLHORN_AUTH` — OAuth token expired/revoked
docs/build-brief/00-MASTER-BRIEF.md:585:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/build-brief/00-MASTER-BRIEF.md:586:- `ESC_RATE_LIMIT_HIT` — upstream API rate-limited (esp. LinkedIn)
docs/build-brief/00-MASTER-BRIEF.md:587:- `ESC_SCHEMA_VIOLATION` — agent produced output violating vertical schema
docs/architecture/agent-bundle-renderer-design.md:219:  - ESC_VOICE_DRIFT
docs/architecture/agent-bundle-renderer-design.md:220:  - ESC_PII_LEAKAGE_RISK
docs/architecture/agent-bundle-renderer-design.md:270:        "ESC_VOICE_DRIFT": { "type": "string", "format": "telegram-chat-id" }
docs/architecture/agent-bundle-renderer-design.md:392:PII is a `ESC_PII_LEAKAGE_RISK` escalation. Voice samples and tone rules in
docs/architecture/agent-bundle-renderer-design.md:423:    "ESC_VOICE_DRIFT": "<acme operator chat id from _secrets.env>"
docs/runbooks/tenant-lifecycle.md:151:| Bullhorn OAuth refresh | Per-agent 8-min cycle per `bullhorn-integration-path.md` §4.5; ESC_BULLHORN_AUTH on failure | (No invariant violation; runtime concern) |
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:438:| `_shared/hook-helpers.sh` wires 5 new `ESC_VAULT_*` codes (in addition to `ESC_BULLHORN_AUTH` + `ESC_RENDERER_FAILED`) | Week 1-2 | Claude Code | `current-priorities.md` Week-1 prereq #3 + §6 of this document |
docs/features/agent-build/02-specs/spec-001-janitor.md:32:| 1 | Bullhorn auth refresh (8-min loop) | — | `ESC_BULLHORN_AUTH` (2 retries) | CC Step 1 `_cc_refresh` |
docs/features/agent-build/02-specs/spec-001-janitor.md:33:| 2 | Entity scan since `janitor_last_run` (candidates/contractors/clients/contacts/placements/opportunities) | `janitor_scan` ("N scanned") | `ESC_RATE_LIMIT_HIT` (429, 60s backoff) | CC Step 3/4 ingest idiom |
docs/features/agent-build/02-specs/spec-001-janitor.md:37:| 6 | Companies House enrichment (clients): name→CRN→industry/CH number; 7d cache | (backfill row at Step 9) | `ESC_RATE_LIMIT_HIT` | Diagnostic CH usage |
docs/features/agent-build/02-specs/spec-001-janitor.md:39:| 8 | Tacit-note harvest: `SELECT FROM recent_edit WHERE resolved_at>now()-30d AND resolution='approved_after_edit'`; group by entity_type; voice-classified LLM narrative | `janitor_tacit_note_harvest` | `ESC_VOICE_DRIFT` (<0.75 after 3 retries) | CC Step 8 draft (voice honesty: unscored if no corpus) |
docs/features/agent-build/02-specs/spec-001-janitor.md:40:| 9 | Bullhorn write batch (yellow): per merge/backfill/note → `hh_decision_action` + atomic write; 4xx skip, 5xx retry-once | `bullhorn_candidate_dedupe`/`bullhorn_field_backfill`/`bullhorn_note_attach` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 write-back (idempotent + ESC routing) |
docs/features/agent-build/02-specs/spec-001-janitor.md:43:| 12 | Session close: update `janitor_last_run`; run-complete | `janitor_run_complete` (green action) | `ESC_GATE_B_MISS` (both thresholds, 3 consecutive) | CC Step 14 |
docs/features/agent-build/02-specs/spec-001-janitor.md:50:| auth | Bullhorn refresh succeeded in Step 1 | `ESC_BULLHORN_AUTH` | hard |
docs/features/agent-build/02-specs/spec-001-janitor.md:51:| merge-conf | every proposed merge ≥0.85 | `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/features/agent-build/02-specs/spec-001-janitor.md:53:| backfill-src | no backfill where source confidence <0.7 | `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/features/agent-build/02-specs/spec-001-janitor.md:54:| voice | tacit-note narrative classifier ≥0.75 | `ESC_VOICE_DRIFT` | hard (warn-when-unscored, per CC honesty) |
docs/features/agent-build/02-specs/spec-001-janitor.md:55:| batch-size | Bullhorn write batch ≤100/min | `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/features/agent-build/02-specs/spec-001-janitor.md:56:| PII | no PII outside firm boundary in narratives (regex) | `ESC_PII_LEAKAGE_RISK` | hard |
docs/operations/goal-week-4-track-1.md:219:    rate-limit.test.ts      # bucket exhaustion → ESC_RATE_LIMIT_HIT mock fire
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:20:- **autosend-policy action_types:** `scout_run_complete` + green `validate_gate_a_fail`. **No write action_types** (read-only agent). Verify via grep.
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:34:| 2 | Multi-source auth refresh; per-source degraded mode on fail | `auth_refresh_complete` ("sources_ok:N/4; degraded:list") | per-source `ESC_*_AUTH` (blocking→degraded-skip); `ESC_AGENT_OUTPUT_SHAPE` if <5 obtainable | CC Step 1 |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:35:| 3 | Bullhorn passive-match (active + not-modified-90d; ≤30) | `bullhorn_query` | `ESC_RATE_LIMIT_HIT` | CC Step 3 |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:37:| 5 | Reed query (≤30) | `reed_query` | `ESC_REED_AUTH`, `ESC_RATE_LIMIT_HIT` | CC Step 3 |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:38:| 6 | CV-Library query (≤30) | `cvlibrary_query` | `ESC_CVLIBRARY_AUTH`, `ESC_RATE_LIMIT_HIT` | CC Step 3 |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:41:| 9 | LLM rank + per-candidate rationale (top 15; ≥50w; voice ≥0.75) | `candidate_proposed` (per candidate) | `ESC_VOICE_DRIFT` (drop candidate) | CC Step 8 render (voice honesty + fallback) |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:42:| 10 | Output assembly + Gate A (5-15; contact method; rationale ≥50w) → vault report | `scout_report` | `ESC_AGENT_OUTPUT_SHAPE` + `validate_gate_a_fail`, exit 1 | CC Step 13 report assembler |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:48:| count | 5–15 candidates returned | `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:49:| contact | each has working contact (email+MX / E.164 phone / LinkedIn / Bullhorn id) | `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:50:| rationale | each rationale ≥50 words | `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:52:| voice | all rationales classifier ≥0.75 | `ESC_VOICE_DRIFT` | hard (warn-when-unscored) |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:53:| PII | none outside firm boundary in rationale | `ESC_PII_LEAKAGE_RISK` | hard (blocking) |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:54:| source-floor | no enabled live source returns 0 WITHOUT a degradation note | `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:63:- `scripts/run-scout-degraded-test.sh` — simulate per-source auth fail → assert degraded-mode skip + the <5-obtainable `ESC_AGENT_OUTPUT_SHAPE` floor.
docs/features/agent-build/02-specs/spec-002-scribe.md:19:- **autosend-policy action_types (registered, yellow):** `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`; + green `validate_gate_a_fail`, `scribe_run_complete`. Verify via grep.
docs/features/agent-build/02-specs/spec-002-scribe.md:25:- decision_log markers: `webhook_verified`, `bullhorn_auth_refreshed`, `transcript_fetched`, `entity_resolved`, `fields_extracted`, `tacit_note_rendered` (output, `{vault_path,body_sha256,voice_score}` — body NOT in payload per ADR-002), `fields_validated`, + action rows `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`, `scribe_run_complete`.
docs/features/agent-build/02-specs/spec-002-scribe.md:32:| 1 | Webhook signature verify (HMAC/bearer) | `webhook_verified` | `ESC_INPUT_VALIDATION_FAIL` (401) | — |
docs/features/agent-build/02-specs/spec-002-scribe.md:33:| 2 | Bullhorn auth refresh | `bullhorn_auth_refreshed` | `ESC_BULLHORN_AUTH` | CC Step 1 |
docs/features/agent-build/02-specs/spec-002-scribe.md:34:| 3 | Transcript fetch (**Granola** — see §8) → /tmp 0600 | `transcript_fetched` | `ESC_PROVIDER_FETCH_FAIL`, `ESC_PII_LEAKAGE_RISK` | — |
docs/features/agent-build/02-specs/spec-002-scribe.md:35:| 4 | Participant→entity inference; resolve bullhorn_id+type | `entity_resolved` | `ESC_AGENT_OUTPUT_SHAPE` (no target) | — |
docs/features/agent-build/02-specs/spec-002-scribe.md:36:| 5 | LLM field extraction (per-field confidence; drop <0.6; need ≥3) | `fields_extracted` | `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | CC Step 8 LLM pattern (deterministic fallback for fixtures) |
docs/features/agent-build/02-specs/spec-002-scribe.md:37:| 6 | LLM tacit-note (8-cat taxonomy, ≤800w, voice ≥0.75) → vault 0600 | `tacit_note_rendered` | `ESC_VOICE_DRIFT` (3 retries) | CC Step 8 render→vault (voice honesty) |
docs/features/agent-build/02-specs/spec-002-scribe.md:38:| 7 | Field validation vs vertical-schema (name + type/range; need ≥3 valid) | `fields_validated` | `ESC_SCHEMA_VIOLATION` + `validate_gate_a_fail`, exit 1 | CC Gate A G1 |
docs/features/agent-build/02-specs/spec-002-scribe.md:39:| 8 | Bullhorn field write (PATCH, yellow, atomic) | `bullhorn_scribe_field_write` | `ESC_BULLHORN_WRITE_FAIL` (no Step 9) | CC Step 6 write-back |
docs/features/agent-build/02-specs/spec-002-scribe.md:40:| 9 | Bullhorn note attach (POST /Note, yellow); rollback Step 8 on fail | `bullhorn_note_append_summary` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 |
docs/features/agent-build/02-specs/spec-002-scribe.md:41:| 10 | Session close + SLA metric (elapsed since webhook) | `scribe_run_complete` | `ESC_SCRIBE_SLA_MISS` (>30min render / >1h attach) | CC Step 14 |
docs/features/agent-build/02-specs/spec-002-scribe.md:46:| webhook-sig | valid per provider | `ESC_INPUT_VALIDATION_FAIL` | hard |
docs/features/agent-build/02-specs/spec-002-scribe.md:47:| field-count | ≥3 extractions ≥0.6 confidence | `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` / `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/features/agent-build/02-specs/spec-002-scribe.md:48:| tacit-voice | note classifier ≥0.75 | `ESC_VOICE_DRIFT` | hard (warn-when-unscored) |
docs/features/agent-build/02-specs/spec-002-scribe.md:49:| field-names | exist in target entity schema | `ESC_SCHEMA_VIOLATION` | hard |
docs/features/agent-build/02-specs/spec-002-scribe.md:50:| field-types | per-field type/range valid; ≥3 valid | `ESC_SCHEMA_VIOLATION` | hard |
docs/features/agent-build/02-specs/spec-002-scribe.md:51:| PII | none outside firm boundary in transcript/note | `ESC_PII_LEAKAGE_RISK` | hard |
docs/features/agent-build/02-specs/spec-002-scribe.md:52:| auth | Bullhorn refresh succeeded | `ESC_BULLHORN_AUTH` | hard |
docs/features/agent-build/03-implementation/scribe-summary.md:13:| 1 | `webhook_verified` (+ `granola_meetings_polled` discovery row) | LIVE — mode=webhook does real HMAC-SHA256 (`openssl`, secret `$SCRIBE_WEBHOOK_SECRET`) or bearer compare; mismatch → `ESC_INPUT_VALIDATION_FAIL` + exit 1 (the 401 path). poll-sweep/replay emit `signature:not_applicable` honestly (Granola publishes no webhooks — Deviation 1) |
docs/features/agent-build/03-implementation/scribe-summary.md:14:| 2 | `bullhorn_auth_refreshed` | LIVE via `bin/bh-bridge.sh refresh` (2 retries → `ESC_BULLHORN_AUTH`); bridge-unavailable recorded honestly → Gate A G7 then blocks writes |
docs/features/agent-build/03-implementation/scribe-summary.md:15:| 3 | `transcript_fetched` | LIVE — Granola vendor; sources: seeded fixture file/dir → `@ifos/granola` CLI (expected surface documented; not built) → notes-only degraded ingest; /tmp file mode 0600; retry-once 30s → `ESC_PROVIDER_FETCH_FAIL` (upstream=granola) |
docs/features/agent-build/03-implementation/scribe-summary.md:16:| 4 | `entity_resolved` | LIVE — RLS-scoped `entities` cache email match, priority placement>brief>opportunity>contact>candidate; no match → `ESC_AGENT_OUTPUT_SHAPE` + `validate_gate_a_fail` + skip |
docs/features/agent-build/03-implementation/scribe-summary.md:17:| 5 | `fields_extracted` | LIVE — `bin/extract-fields.sh`: deterministic regex extraction (default; fixture-reproducible) + opt-in LLM path (`IFOS_SCRIBE_USE_LLM=1` + key; `claude-opus-4-8`, json_schema output, deterministic fallback on any failure); <3 fields ≥0.6 → `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` + gate row + skip |
docs/features/agent-build/03-implementation/scribe-summary.md:19:| 7 | `fields_validated` + Gate A subprocess | LIVE — `bin/validate-fields.sh` (schema-file-derived allowlist) then `validate.sh`; <3 valid → `ESC_SCHEMA_VIOLATION` + gate row + skip |
docs/features/agent-build/03-implementation/scribe-summary.md:20:| 8 | `bullhorn_scribe_field_write` (yellow) | LIVE — RLS `entities` cache UPDATE (DB trigger re-validates shapes) + `bh-bridge update-entity` PATCH; prior-data snapshot for rollback; per-write `recent_edit` row (`resolution='deferred'`) for Gate B edit-rate; opportunity = cache-only by design |
docs/features/agent-build/03-implementation/scribe-summary.md:21:| 9 | `bullhorn_note_append_summary` (yellow) | LIVE — `bh-bridge create-note`; hard fail → best-effort Step 8 rollback (cache restore + reverse PATCH) + `ESC_BULLHORN_WRITE_FAIL`; bridge-unavailable → `note_attach_deferred` output row (no fake yellow row — no Bullhorn state changed) |
docs/features/agent-build/03-implementation/scribe-summary.md:22:| 10 | `scribe_run_complete` | LIVE — per-call elapsed since call end via `bin/sla-class.sh`; `ESC_SCRIBE_SLA_MISS` sla_type=summary_render (>30min) / note_attach (>1h); 10-min Gate B miss recorded, no ESC |
docs/features/agent-build/03-implementation/scribe-summary.md:33:| `scripts/run-scribe-gate-a-test.sh` | PASS — 19 assertions: 2 PASS paths (verified-sig and poll-trigger + warn-when-unscored) + 8 fail classes each with ESC routing asserted (`ESC_BULLHORN_AUTH`, `ESC_INPUT_VALIDATION_FAIL`, `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`, `ESC_VOICE_DRIFT`, `ESC_SCHEMA_VIOLATION`×2, `ESC_PII_LEAKAGE_RISK`, `ESC_AGENT_OUTPUT_SHAPE`) + 8 `validate_gate_a_fail` rows |
docs/features/agent-build/03-implementation/scribe-summary.md:52:   route through catalogue `ESC_PROVIDER_FETCH_FAIL` with `upstream=granola`
docs/operations/goal-option-c-diagnostic-end-to-end.md:155:- `errors.ts` — 429 → ESC_RATE_LIMIT_HIT, 5xx → ESC_SCHEMA_VIOLATION
docs/operations/goal-option-c-diagnostic-end-to-end.md:309:| LLM generates §12 with banned phrase | V5 fails; retry up to 3x; if still failing, ESC_VOICE_DRIFT row + report blocked (matches fixture 99); record as known limitation, defer voice tuning to Week-4 polish. |
docs/features/agent-build/02-specs/spec-004-concierge.md:35:| 3 | Bullhorn context fetch (candidate/placement/client/contact) | `bullhorn_context_fetched` | `ESC_RATE_LIMIT_HIT`, `ESC_BULLHORN_AUTH`, `ESC_AGENT_OUTPUT_SHAPE` | CC Step 1/4 |
docs/features/agent-build/02-specs/spec-004-concierge.md:39:| 7 | LLM draft → `/vault/<tenant>/concierge-drafts/<id>.md` | `concierge_draft_rendered` | `ESC_VOICE_DRIFT` (position threshold) | CC Step 8 render→vault |
docs/features/agent-build/02-specs/spec-004-concierge.md:40:| 8 | Voice+tone validation (position thresholds 0.75/0.78/0.82) → yellow draft row | (action) `concierge_email_draft` | `ESC_VOICE_DRIFT`, `ESC_TONE_RULE_VIOLATION` | CC Gate A G3 (position-aware) |
docs/features/agent-build/02-specs/spec-004-concierge.md:42:| 10 | PII boundary check | `pii_check_passed` | `ESC_PII_LEAKAGE_RISK` (blocking) | CC Gate A G4 |
docs/features/agent-build/02-specs/spec-004-concierge.md:45:| 13 | Bullhorn activity-log write (green, audit) | `bullhorn_activity_log_write` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 |
docs/features/agent-build/02-specs/spec-004-concierge.md:46:| 14 | Lifecycle state advance (conditional Bullhorn write, per-tenant opt-in) | `concierge_send_complete` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 |
docs/features/agent-build/02-specs/spec-004-concierge.md:47:| 15 | Session close + Gate B (ghosted-rate, send-as-is, SLA) | `concierge_run_complete` (green) | `ESC_GATE_B_MISS` | CC Step 14 |
docs/features/agent-build/02-specs/spec-004-concierge.md:52:| voice | classifier ≥ position threshold (0.75/0.78/0.82) | `ESC_VOICE_DRIFT` | hard (warn-when-unscored) |
docs/features/agent-build/02-specs/spec-004-concierge.md:55:| PII | none outside firm boundary | `ESC_PII_LEAKAGE_RISK` (blocking) | hard |
docs/features/agent-build/02-specs/spec-004-concierge.md:57:| context | Bullhorn context complete (name + email present) | `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/operations/w4-bilateral-pass-6-agent-md.md:50:  - **Codex says:** "Line 109 says `ESC_VOICE_DRIFT` is 'raised internally by §12 LLM step if classifier <0.75 after 3 retries,' but the generator README says v0 has 'No LLM-driven §12' and 'No voice classifier gate,' and `validate.sh` only calls the classifier once when `IFOS_VOICE_CLASSIFIER_URL` is set. Fix §4 to say voice drift is a `validate.sh` V3 concern in v0, with retries deferred to W4 if intended."
docs/operations/w4-bilateral-pass-6-agent-md.md:54:### Finding 2. ESC_RATE_LIMIT_HIT claimed but not implemented
docs/operations/w4-bilateral-pass-6-agent-md.md:56:  - **Codex says:** "Lines 108 and 173 say `ESC_RATE_LIMIT_HIT` is raised for Companies House or LinkedIn 429s, but `cycle.sh` has no 429 catch or `hh_decision_action` path for that code; the generator CLI just exits generic on thrown errors. Fix by either implementing a 429 catch that emits `ESC_RATE_LIMIT_HIT`, or marking this as a W4/planned tools.yaml mapping rather than current v0 behaviour."
docs/operations/w4-bilateral-pass-6-agent-md.md:62:  - **Codex says:** "Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature."
docs/operations/w4-bilateral-pass-6-agent-md.md:63:  - **Likely:** FIX-IN-PLACE. Add `ESC_VOICE_DRIFT` to the §4 line 117-119 signature list.
docs/operations/w4-bilateral-pass-6-agent-md.md:86:  - **Codex says:** "Line 187 says `ESC_AGENT_OUTPUT_SHAPE` applies to 'ALL Gate A conditions,' including voice classifier, PII, and write-batch size. The catalogue defines `ESC_VOICE_DRIFT` for classifier failures and `ESC_PII_LEAKAGE_RISK` as blocking for PII leakage; downgrading PII to `ESC_AGENT_OUTPUT_SHAPE` weakens Gate A routing. Fix §5 so each Gate A condition maps to its catalogue code, reserving `ESC_AGENT_OUTPUT_SHAPE` for report/output-shape failures only."
docs/operations/w4-bilateral-pass-6-agent-md.md:186:### Finding 5. ESC_PROVIDER_FETCH_FAIL used outside catalogue definition
docs/operations/goal-week-3-polish-and-scaffold.md:214:   - **Retry:** if response shape malformed, retry once; if still bad, fall back to deterministic logic + emit `ESC_VOICE_DRIFT` warning row.
docs/operations/goal-week-3-polish-and-scaffold.md:219:   - Tone-rule violation in LLM output → retry then ESC_VOICE_DRIFT
docs/operations/goal-week-3-polish-and-scaffold.md:310:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_BULLHORN_WRITE_FAIL, ESC_SCHEMA_VIOLATION, ESC_RATE_LIMIT_HIT, ESC_AUTOSEND_YELLOW_SPOT_CHECK.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§6 Escalation codes:** ESC_BULLHORN_WRITE_FAIL, ESC_VOICE_DRIFT, ESC_SCHEMA_VIOLATION, ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
docs/operations/goal-week-3-polish-and-scaffold.md:346:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:375:- **§7 Voice + tone:** chase drafts are voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:500:| LLM call rate-limited or 5xx (Step 4 runtime) | Built-in retry once; fall back to deterministic; emit ESC_VOICE_DRIFT warning |
docs/operations/decision-log.md:185:   - **Scribe (4):** Output-2 decision_log signature; validate_gate_a_fail 113→119; classifier-fail→hard Gate A **[DECISION]**; ESC_GATE_B_MISS in §6
docs/operations/decision-log.md:186:   - **Concierge (5):** ULTRAPLAN 566 citation realign; SLA-miss audit row; 24h→PT4H timeout; ESC_VOICE_DRIFT severity→warn; third Gate B threshold
docs/operations/decision-log.md:197:**Verified:** v0.3 supplement YAML parses; migration FOR/LOOP balanced + `elem` declared; shellcheck clean on the harness; all cited line numbers (autosend-policy 188/263/235-239, escalation-codes 120-125/348-353/431-439, validate_gate_a_fail 119) confirmed against source.
docs/operations/decision-log.md:213:| ESC codes referenced ∈ escalation-codes.md | ✓ (3 are sanctioned W4-backlog proposals / changelog notes; janitor's `ESC_BULLHORN_OAUTH_REVOKED` disclaimer corrected → folded into `ESC_BULLHORN_AUTH` payload) |
docs/operations/decision-log.md:229:6. `40f94c4 fix(scribe-r4)` — all 5 R3 residuals closed; missing `hh_decision_*` calls added at §4 Steps 3+7; Ringover explicitly v1.1+; autosend cite split (decision-doc vs runtime YAML); ESC_PROVIDER_FETCH_FAIL catalogue extension queued
docs/operations/decision-log.md:651:  - §6 Escalation codes (ESC_VOICE_DRIFT / ESC_PII_LEAKAGE_RISK / ESC_RATE_LIMIT_HIT / ESC_SCHEMA_VIOLATION) mapped from `agents/_shared/escalation-codes.md`
docs/operations/decision-log.md:1086:  - `ESC_BULLHORN_AUTH` per `bullhorn-integration-path.md` §6.1

exec
/bin/zsh -lc 'rg -n "Scribe|A3|week 6|W6|post-call|5 minutes|0.6|tacit|scribe" docs agents -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/recruitment/janitor/validate.sh:3:# (_fail + _warn are not invoked in the W5 Day-31 skeleton — TODO(W6-7)
agents/recruitment/janitor/validate.sh:10:# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice completes the impl).
agents/recruitment/janitor/validate.sh:59:#   G6 — No PII outside firm boundary in tacit-note narratives (regex pass).
agents/recruitment/janitor/validate.sh:137:# TODO(W6-7): SELECT FROM decision_log WHERE action_type='bullhorn_auth_refresh'
agents/recruitment/janitor/validate.sh:141:_ok "G1: Bullhorn auth refresh fresh — SKELETON (W6-7 wires the decision_log re-query)"
agents/recruitment/janitor/validate.sh:150:# TODO(W6-7): jq -r '.action_type' "$PROPOSAL" — if dedupe action_type, then
agents/recruitment/janitor/validate.sh:154:_ok "G2: dedup confidence ≥${DEDUP_THRESHOLD} — SKELETON (W6-7 wires jq parse + threshold compare)"
agents/recruitment/janitor/validate.sh:164:# TODO(W6-7): jq -r '.last_activity_days' "$PROPOSAL" → if < 90 (and action_type
agents/recruitment/janitor/validate.sh:168:_ok "G3: no Bullhorn activity in last 90d — SKELETON (W6-7 wires activity-days check)"
agents/recruitment/janitor/validate.sh:175:# TODO(W6-7): if action_type='bullhorn_field_backfill', read .source +
agents/recruitment/janitor/validate.sh:178:_ok "G4: field-backfill source confidence ≥0.7 — SKELETON (W6-7 wires)"
agents/recruitment/janitor/validate.sh:185:# TODO(W6-7): if action_type='bullhorn_note_attach', read .voice_score from
agents/recruitment/janitor/validate.sh:188:_ok "G5: tacit-note voice classifier ≥0.75 — SKELETON (W6-7 wires)"
agents/recruitment/janitor/validate.sh:191:# G6 — No PII outside firm boundary in tacit-note narrative
agents/recruitment/janitor/validate.sh:196:# TODO(W6-7): if action_type='bullhorn_note_attach', grep .narrative_body for
agents/recruitment/janitor/validate.sh:199:_ok "G6: no PII outside firm boundary — SKELETON (W6-7 wires firm-domain whitelist)"
agents/recruitment/janitor/validate.sh:207:# TODO(W6-7): import {rateCheck} from '@ifos/bullhorn'; if shouldBackoff at
agents/recruitment/janitor/validate.sh:210:_ok "G7: write batch rate-limit budget ok — SKELETON (W6-7 wires @ifos/bullhorn rateCheck)"
agents/recruitment/janitor/validate.sh:219:  # TODO(W6-7): per-failure routing — different ESC code per failure class
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:4:# Status: Proposed (W5 Day-30 landing; W6+ Codex ratification queue addendum)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:5:# Date:   2026-06-03 (Day 30; post-W5-MCP-sweep)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:32:date: 2026-06-03
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:46:  Founder confirmed 2026-06-03: IFOS Granola workspace will be on
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:60:  granola_workspace_id the higher-priority addition (W6 Scribe needs the
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:82:      autosends per D1-B (docs/decisions/2026-05-31-d1-founder-decision.md).
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:139:      (W6+ runbook; not yet authored).
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:150:    read_by: [scribe]  # W6+ Scribe bundle reads
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:164:      Founder confirmed 2026-06-03: tier is Business+/Paid (see §0 notes).
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:168:      W6+ Scribe agent.md tools.yaml will reference this key at the
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:169:      capability level when the Scribe bundle scaffold lands. v0.4
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:170:      pre-lands the schema to unblock W6 without a second supplement.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:177:    read_by: [janitor, scribe, concierge]  # v1.0 agent consumers
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:189:      2026-06-02). Once captured, it's stable per tenant — different IFOS
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:192:      v1.0 agent consumers: Janitor + Scribe + Concierge (each loads it
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:224:    None. Per ADR-006 Tier 2 the per_claim_confidence_distribution payload
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:278:    MCP scaffolds + the W6+ Scribe + W7-8 Cash Conductor consumer wiring.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:363:    - W6 Scribe bundle scaffold can land tools.yaml referencing
agents/recruitment/cash-conductor/sql/reconciliation-match.sql:20:--   4  fuzzy amount (±0.5%) + payee-name match        → 0.65  → ambiguous (ESC)
agents/recruitment/cash-conductor/sql/reconciliation-match.sql:132:      WHEN 1 THEN 0.98 WHEN 2 THEN 0.85 WHEN 3 THEN 0.70 WHEN 4 THEN 0.65
agents/recruitment/janitor/cleanup.sh:4:# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice replaces stubs with
agents/recruitment/janitor/cleanup.sh:13:# registration at W6-7 build start (per tools.yaml status table below). Once
agents/recruitment/janitor/cleanup.sh:14:# registered + the W6-7 build wires the real purge logic, this script emits
agents/recruitment/janitor/cleanup.sh:23:# Side effects (W6-7 build slice):
agents/recruitment/janitor/cleanup.sh:77:# Exported so the W6-7 build-slice can extend the find -delete logic via
agents/recruitment/janitor/cleanup.sh:82:# TODO(W6-7): replace these STUB counts with actual find -delete invocations
agents/recruitment/janitor/cleanup.sh:98:# Deferred to W6-7 build (analytical signal; not blocking).
agents/recruitment/janitor/cleanup.sh:107:# TODO(W6-7): once janitor_cleanup action_type is registered in
agents/recruitment/janitor/context.sh:4:# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice replaces stubs with
agents/recruitment/janitor/context.sh:6:#         LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS) — bullhorn_corporation_id
agents/recruitment/janitor/context.sh:10:#         W6-7 build wires the postgres read".
agents/recruitment/janitor/context.sh:26:# Side effects (W6-7 build slice):
agents/recruitment/janitor/context.sh:31:#   - Load voice corpus + tone-rules YAML for tenant (for Step 8 tacit-note
agents/recruitment/janitor/context.sh:33:#   - Load recent_edit rows from last 30 days (for Step 8 tacit-note harvest;
agents/recruitment/janitor/context.sh:91:# TODO(W6-7): canonical SELECT path available — v0.3 supplement LANDED;
agents/recruitment/janitor/context.sh:100:# Reference: v0.4 supplement LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS).
agents/recruitment/janitor/context.sh:105:# TODO(W6-7): swap to canonical tenant_adapters SELECT path now that v0.4
agents/recruitment/janitor/context.sh:123:# TODO(W6-7): node -e "import('@ifos/bullhorn').then(b => {
agents/recruitment/janitor/context.sh:132:# Step 4 — Voice corpus + tone rules (for Step 8 tacit-note narrative)
agents/recruitment/janitor/context.sh:138:# TODO(W6-7): CTX_TONE_RULES=$(hh_load_tone_rules "janitor" 2>/dev/null || echo "[]")
agents/recruitment/janitor/context.sh:139:# TODO(W6-7): CTX_TONE_RULES_COUNT=$(echo "${CTX_TONE_RULES}" | jq 'length')
agents/recruitment/janitor/context.sh:143:# Recent edits lookback window (Step 8 tacit-note harvest) — fixed at 30 days
agents/recruitment/janitor/context.sh:155:# TODO(W6-7): swap to canonical tenant_adapters SELECT path:
docs/incidents/2026-06-01-intelforce-ai-email-outage.md:3:**Date:** 2026-06-01
docs/incidents/2026-06-01-intelforce-ai-email-outage.md:13:- No emails received in the Outlook (M365) inbox since **2026-05-24**.
docs/incidents/2026-06-01-intelforce-ai-email-outage.md:21:- **DNS zone host:** Vercel — under account **madsrigby@outlook.com** (user `madsrigby-1086`, team id `intelforce`)
docs/incidents/2026-06-01-intelforce-ai-email-outage.md:28:On ~2026-05-24 the GoDaddy nameservers were switched to Vercel's. This handed **all** DNS control to Vercel. Vercel auto-created the website records (ALIAS → vercel-dns) but, by design, does **not** carry over mail records — so the M365 MX/autodiscover/SPF records were absent from the new zone. With no MX record, inbound mail had nowhere to route and bounced.
docs/incidents/2026-06-01-intelforce-ai-email-outage.md:32:## Fix applied (2026-06-01 ~11:50)
docs/incidents/2026-06-01-intelforce-ai-email-outage.md:54:6. **Damage control:** every inbound email 2026-05-24 → 2026-06-01 bounced. Proactively re-contact any time-sensitive senders from a working address. Known affected: Bullhorn partnership reply (form re-submitted; see `docs/operations/bullhorn-outreach-emails.md`).
docs/incidents/2026-06-01-intelforce-ai-email-outage.md:55:7. **Low-priority security check:** Upwork "unknown device" / "password reset" alerts dated 2026-05-23 were noted; root cause turned out to be the DNS change, not a breach, but worth a glance at M365 sign-in activity + enabling 2FA to be safe.
agents/_shared/autosend-policy.yaml:21:version: "v1.0-2026-05-24"
agents/_shared/autosend-policy.yaml:43:    agent: scribe
agents/_shared/autosend-policy.yaml:83:  scribe_run_complete:
agents/_shared/autosend-policy.yaml:85:    agent: scribe
agents/_shared/autosend-policy.yaml:116:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:150:  # MCP-connector OAuth refresh action_types (added 2026-06-01
agents/_shared/autosend-policy.yaml:184:    reason: "Internal Bullhorn activity-log entry — NOT customer-visible (separate from bullhorn_note_customer_visible which is orange). Maintains the audit trail in Bullhorn itself so downstream consultant ops see Concierge actions on the candidate's record. Idempotent within payload_hash dedup window. Registered per Codex Fbis-R1 closure 2026-06-02 — Concierge agent.md §4 Step 13 needs this for tier classification of the external write."
agents/_shared/autosend-policy.yaml:209:    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
agents/_shared/autosend-policy.yaml:214:    agent: scribe
agents/_shared/autosend-policy.yaml:240:  bullhorn_scribe_field_write:
agents/_shared/autosend-policy.yaml:242:    agent: scribe
agents/_shared/autosend-policy.yaml:244:    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
agents/_shared/autosend-policy.yaml:296:    agent: scribe
agents/_shared/autosend-policy.yaml:416:  - "47 total action_types (19 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:395:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:443:- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
agents/_shared/escalation-codes.md:487:The Codex Day-7 ratification queue includes this catalogue (item #20 placeholder per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1). Updates after ratification = new commit + Codex re-review of the diff.
docs/architecture/tenancy-invariants.md:4:**Date:** 2026-05-20 (Day 9 evening — pre-Diagnostic-build architecture audit).
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:131:- **Enforcement:** Renderer (`packages/agent-renderer/src/renderer.ts::render`) calls `writeFileTracked(envPath, content, 0o600, ...)`.
docs/architecture/tenancy-invariants.md:202:| T1 | Partial → Verified | Day-4 §7 schema-creation gate + tenancy audit | 2026-05-17 Day-4 (Day-4 tables); Day-12 (v0.2 tables); pending v0.3 migration apply (cash_conductor tables) | All 11 tables expected to pass; v0.3 cash_conductor tables follow v0.2 RLS pattern verbatim |
docs/architecture/tenancy-invariants.md:203:| T2 | Partial → Verified | Day-4 §7 RLS-enable check + tenancy audit | 2026-05-17 Day-4 (Day-4 tables); pending Day-9 (v0.2 + cross-validation) | Same |
docs/architecture/tenancy-invariants.md:212:| T11 | **VERIFIED** | Day-4 §7 RLS isolation gate (5/5 conditions) + Phase 2 stress test | 2026-05-17 Day-4 | The only adversarially-verified invariant; foundation of the layered defence |
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:44:      timestamp: "2026-05-22T14:00:00Z"
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:55:      Date: "2026-04-15"
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:56:      DueDate: "2026-05-15"
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:64:      Date: "2026-05-10"
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:65:      DueDate: "2026-06-09"
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:41:      timestamp: "2026-05-20T10:30:00Z"
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:53:      Date: "2026-05-01"
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:54:      DueDate: "2026-05-31"
docs/_archive-build-pack/08-OPEN-DECISIONS.md:9:**Status:** Resolved 16 May 2026.
agents/recruitment/janitor/fixtures/99-recent-activity-blocked.yaml:80:    - id: 3006
agents/recruitment/janitor/fixtures/99-recent-activity-blocked.yaml:105:        - {primary_id: 3005, merge_target_id: 3006, review_band_reason: "candidate_3005_recent_activity_days:60"}
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:4:# Date:   2026-05-20 (Day 8 of Week 0 extension)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:25:date: 2026-05-20
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:61:      - Scribe (R — voice samples for note-summary tone matching)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:75:          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:128:      - Scribe (R — note format constraints)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:429:    date: 2026-05-20 (Day 8, Week 0 extension period)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:446:    expected_date: post-first-pilot voice corpus mature (Q4 2026 if pilot lands)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:4:# Date:   2026-05-24 (Day 19; post-Round-8 Cat-β unblock)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:9:# Concierge schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:16:# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:19:# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:43:date: 2026-05-24
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:65:          IR35 distinction matters for UK contractors. Extracted by Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:67:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:69:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:82:        source: IFOS-derived (Scribe writes from CV/transcripts; Sourcing Scout surfaces CV-Library + Reed search-result skills in its shortlist artefact only, NOT into the Bullhorn-backed candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:84:          - Scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:95:          Janitor/Scribe (which hold W) if a sourced candidate is promoted;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:99:        source: IFOS-derived (Scribe/Janitor write to the candidate entity; Sourcing Scout surfaces match URLs in its shortlist artefact only; Janitor uses for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:113:          Contact's stated preference; extracted by Scribe from call context.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:115:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:117:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:124:          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:127:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:129:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:143:        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:145:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:155:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:157:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:168:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:170:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:181:          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:184:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:186:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:193:        pattern: '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$'
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:197:          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:198:          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:204:        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:207:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:216:          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:218:        source: IFOS-derived (Scribe LLM extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:220:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:233:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:235:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:244:          Scribe LLM inference from prospecting-call urgency cues. Drives
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:246:        source: IFOS-derived (Scribe LLM classification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:248:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:258:        source: IFOS-derived (Scribe extraction)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:260:          - Scribe: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:284:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:286:#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:288:#     R-only for Scribe)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:289:#   - Scribe Opportunity: none → R+W (writes 3 new prospecting-call fields)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Scribe timesheet: none → R (reads for placement-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:313:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:351:  #   Example: Scribe.candidate: R+W at entity level; per-field
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:352:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:  scribe:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:394:    # Scribe's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:396:    # row A3. opportunity + timesheet access below is to IFOS-cached
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:397:    # Postgres rows ONLY (not direct Bullhorn endpoint calls). Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:400:    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:401:    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:402:    client: R              # IFOS-cached read (Bullhorn endpoint A3 — ClientCorporation)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:406:    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:413:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:426:    # v0.3 EXPLICIT OVERRIDES — R20 reconciliation (2026-05-27): the original
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:476:      - Scribe (R)         # v0.3 NEW — reads client context for call-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:481:      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:494:      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:499:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:502:      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:506:      v0.3 upgrades Scribe to R+W for the 3 new brief fields only; existing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:508:      for Scribe.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:515:      - Scribe (R+W)       # v0.3 NEW — writes 3 new prospecting-call fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:522:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:529:      - Scribe (R+W)       # v0.3 NEW — check-in field extraction
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:534:      their §4 specs); adds Scribe R+W for check-in writes.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:545:      Scribe + Concierge (each reads timesheet for their respective
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:549:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:553:      - Scribe (R+W)       # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:568:      - Scribe (R+W)       # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:578:    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:579:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:582:      §12 conversation opener; Janitor for tacit-note narratives; Cash
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:585:      granted Scribe + Concierge; v0.3 extends to all 6.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:588:    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      applies_to_agents containing 'janitor' for tacit-note narrative
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:603:      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:604:      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:608:      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:610:      for retraining queue). Janitor adds R for tacit-note harvest per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:706:    scribe: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:715:    scribe: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:724:    scribe: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:731:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:735:    scribe: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:742:    scribe: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:749:    scribe: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:855:  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:861:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:866:  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:876:      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:927:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1018:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1023:  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1027:    - Scribe agent.md §3 entity-field table becomes PARTIALLY schema-verifiable:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1033:      in vault per ADR-002; only the vault-path pointer is in Postgres.) The Scribe §3 narrative still references SOME
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1038:      they do not block v0.3 ratification but do require a Scribe agent.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1039:      consistency-pass before Scribe ratifies.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1043:    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:3:**Date:** 2026-05-24 (Day 19; end of Week 3 goal execution)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:8:- Round 4: `logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:9:- Round 5: `logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:55:Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:118:| Diagnostic | 5 (same as Round 5 but with Issue-5-validate-impl-gap replacing Issue-5-doc-shape) | `logs/codex-ratification/20260524T101934Z-19923/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:119:| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:120:| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:122:| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:123:| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:131:5. **§5 honesty about validate.sh implementation** — agent.md §5 sections describe Gate A behaviour that may not be implemented in the corresponding `validate.sh`. For Diagnostic, validate.sh exists + has gaps (Issue 5). For the 5 new scaffolds, validate.sh DOESN'T exist yet — §5 describes intent. Disposition: explicitly mark "intended behaviour; cycle.sh + validate.sh implementation at W-X build will deliver this" in §5 of each pre-build scaffold.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:157:After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:159:1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:180:Without founder bilateral involvement, each autonomous remediation round burns ~30-60 min Claude time + 2-5 min Codex tokens, with low probability of RATIFIED on artefacts that have multiple systemic issues.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:243:## Bilateral session execution — Round 8 close (2026-05-24, post-founder-authorization)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:272:| Diagnostic | 5 | `20260524T112636Z-79455` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:273:| Janitor | 6 | `20260524T112807Z-81339` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:274:| Scribe | 5 | `20260524T112917Z-82352` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:275:| Cash Conductor | 5 | `20260524T113038Z-83732` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:276:| Sourcing Scout | 4 | `20260524T113139Z-84869` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:277:| Concierge | 7 | `20260524T113247Z-86019` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:290:- Scribe: ~12 new entity fields (current_role_title, employment_type, key_skills, preferred_channel, next_action_target_date, must_haves, nice_to_haves, deal_breakers, placement_status, week_1_status_note, satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band, decision_window_text); Scribe access matrix expansion to Contact / Brief / Opportunity write paths
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:316:  - Scribe Steps 2-3, 7 partial coverage
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:331:- Scribe: pre-build-scaffold; Round-8-reviewed; heavy schema-supplement dependency (Cat-β) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:372:| Scribe | 5 | 4 | −1 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:407:**Recommended: B (ADR-006).** Closes the disagreement properly; gives Cat-1 a ratified architectural home; future-proofs against Cat-1 re-litigation. ~1 hour Claude work + 1 Codex round to ratify the ADR.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:428:| Scribe | Pre-Build-Round-9-Reviewed | 4 (heavy Cat-β) | v0.3 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*
docs/architecture/architecture-cohesion-review.md:3:**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation audit).
docs/architecture/architecture-cohesion-review.md:90:| A3 | **The `_shared/` symlink target `../../../_shared` resolves to `<org>/agents/_shared/`, not anywhere else.** | renderer.ts symlinkSync call | If filesystem semantics differ (mac vs linux), or someone moves the rendered dir, symlink could escape. macOS + Linux behaviour verified identical for this case. |
docs/architecture/architecture-cohesion-review.md:128:- **Resolution path:** Founder Decision D3 in `2026-05-20-codex-round-1-founder-decisions.md`. Recommended D3-B (90-day text purge + indefinite metadata).
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:156:| G10 | **External advisor identification.** Kill-criterion §3.4 calls for Week 1-2 must-fill. Today = Day 9 (Week 1+). | High (pre-LOI blocker) | Founder Decision D2 in `2026-05-20-codex-round-1-founder-decisions.md`. Engage this week. |
docs/architecture/architecture-cohesion-review.md:233:| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
agents/recruitment/cash-conductor/agent.md:3:**Status:** Proposed-with-disagreement-on-file (`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` — bundle-layer Codex ratification deferred to W7-8 build slice; contract-layer ratification was achieved in W3 cluster E).
agents/recruitment/cash-conductor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (2026-05-24): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim; `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring landed (commit `076e231`). Remaining gates: Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice replacing the SKELETON TODOs with live impl + Concierge W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) so the orange-tier send path activates.
agents/recruitment/cash-conductor/agent.md:6:**Reading-discipline note (added 2026-06-02 per Codex Fbis-R3 closure):** this `agent.md` is the **CONTRACT** that the W7-8 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `6ab59d8` + `5ab2f0f` + `076e231` + `bccef02` + `5d398eb` per Day-26 + R-round closures); they carry `TODO(W7-8)` markers throughout that the W7-8 build slice replaces with live implementation matching the contract below. **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON cycle.sh emits only the minimal trigger/output markers (`session_start`, `auth_refresh_complete`, `mode_routed`, `transactions_ingested`, `invoices_ingested`, `reconciliation_pass`, `chase_pass_complete`, `drafts_only_mode`, `weekly_report`, `cash_conductor_run_complete`) listed at `cycle.sh` lines 88, 100, 114, 127, 140, 152, 178, 287, 329, 342.** The yellow-tier + orange-tier audit rows the contract names are NOT yet emitted at runtime — they're the W7-8 contract surface, not current behavior. Don't read agent.md as a description of running code; read it as the spec the W7-8 build slice implements.
agents/recruitment/cash-conductor/agent.md:7:**Date:** 2026-05-24.
agents/recruitment/cash-conductor/agent.md:20:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the `xero_reminder_send_customer` action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify) which is the **chase-approval-initiation** audit row; Concierge runs the autosend bridge for approval routing, then performs the transport-execution and writes its OWN orange-tier `gmail_outlook_send_to_candidate` action row (Concierge-owned; registered under §ORANGE). Both agents write tier-classified action rows — the distinction is: Cash Conductor writes the initiation; Concierge writes the transport. The full autosend chain has TWO orange-tier rows in sequence (initiation + transport), both gated, both audited. Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport; and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and emits a **`drafts_only_mode` marker** via `hh_decision_output` indicating that the orange-tier `xero_reminder_send_customer` row is suppressed (see `cycle.sh` line 287 — this marker is the ONLY row Step 10 emits at the SKELETON layer; the W7-8 build slice replaces this with the full yellow-draft-row + vault-draft + orange-row chain documented in §3 below). The chase-draft pipeline currently halts at the marker; consultants pick up nothing because no vault drafts are produced yet — this is the SKELETON state, intentional, distinct from the W7-8 LIVE-impl drafts-only mode that produces yellow rows + vault drafts.
agents/recruitment/cash-conductor/agent.md:52:0 6 * * 1 sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode weekly-report
agents/recruitment/cash-conductor/agent.md:57:- **Webhook (v1.0 primary path):** per-provider HMAC / bearer token verified at the ingress per `tools.yaml` capability declarations (matching the Scribe webhook auth pattern).
agents/recruitment/cash-conductor/agent.md:91:| 4 | Fuzzy amount (±0.5% rounding) + matching payee name | 0.65 |
agents/recruitment/cash-conductor/agent.md:326:**Honesty note (updated 2026-06-02 per Codex Fbis-R3 closure):** `agents/recruitment/cash-conductor/validate.sh` **EXISTS as SKELETON** (committed `524bac6` on 2026-06-01) — the 5 Gate A checks G1-G5 are defined as TODO(W7-8) markers inside the SKELETON validate.sh; the W7 build slice replaces the TODOs with live impl per the contract above. The §5 contract describes what validate.sh's TODOs will become; the SKELETON file structurally exists and passes shellcheck CLEAN today but does not yet enforce the checks at runtime.
agents/recruitment/cash-conductor/agent.md:405:| `validate.sh` Gate A logic (G1-G5 checks; SKELETON file exists at commit `524bac6`; W7 wires live impl) | SKELETON shipped 2026-06-01; W7 live-impl ~1 day | ✅ SCAFFOLDED (W4 Day-26) |
agents/recruitment/cash-conductor/agent.md:406:| `context.sh` hydration (SKELETON file exists at commit `5ab2f0f`; W7 wires real provider config + tenant_adapters reads) | SKELETON shipped 2026-06-01; W7 live-impl ~0.5 day | ✅ SCAFFOLDED (W4 Day-26) |
agents/recruitment/cash-conductor/agent.md:407:| `cycle.sh` orchestration (14-step SKELETON at commit `6ab59d8`; minimal trigger/output markers fire today; W7 wires per-step impl) | SKELETON shipped 2026-06-01; W7 live-impl ~3 days (most complex of v1.0 agents) | ✅ SCAFFOLDED (W4 Day-26) |
agents/recruitment/cash-conductor/agent.md:408:| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify, autosend_bridge_telegram_propose + _await) | SKELETON shipped 2026-06-01 + 076e231 bridge wiring; W7 ratifies live | ✅ SCAFFOLDED (W4 Day-26) |
agents/recruitment/cash-conductor/agent.md:409:| `cleanup.sh` post-run state purge SKELETON (transient OAuth tokens; provider rate-limit caches; TODO(W7-8) markers; commit `5ab2f0f`) | SKELETON shipped 2026-06-01; W7 live-impl ~0.5 day | ✅ SCAFFOLDED (W4 Day-26) |
agents/recruitment/cash-conductor/agent.md:410:| 3 fixtures (`01-primary.yaml` + `02-edge-case-fuzzy-match.yaml` + `99-token-aging-canary.yaml` at commit `5ab2f0f`) | SKELETON shipped 2026-06-01; W7 wires golden-output assertions | ✅ SCAFFOLDED (W4 Day-26) |
agents/recruitment/cash-conductor/agent.md:411:| **Founder Decision D1 (autosend orange-tier path) ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md` | ✅ ACCEPTED |
agents/recruitment/cash-conductor/agent.md:412:| **Autosend bridge package scaffold** — `@ifos/autosend-bridge-telegram` lib + types + tests landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring at cycle.sh Step 10 landed (commit `076e231`) | ✅ SCAFFOLDED (Cash Conductor side) |
agents/recruitment/cash-conductor/agent.md:448:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies via the cluster Fbis ratification run (`bash scripts/run-codex-ratification.sh --cluster Fbis`). Round-trip history: Day-20 W3 cluster E ratified the agent.md at the contract layer; cluster Fbis (2026-06-02) ratifies the bundle layer now that sibling files (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) exist alongside.
agents/recruitment/cash-conductor/agent.md:451:- Cluster Fbis returns RATIFIED for this agent.md (in-flight as of 2026-06-02)
agents/recruitment/cash-conductor/agent.md:455:NOTE: D1 RESOLVED is NO LONGER a Proposed→Accepted blocker — D1 was Accepted 2026-05-31 as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`, and the package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`). The autosend-bridge **production wiring** (real Telegram Bot API) remains a Concierge W10-13 deliverable; until then, Cash Conductor runs in drafts-only mode (interim — see §8 fallback row). The bridge wiring is an Accepted→In-Force blocker (build slice + first-production criterion below), not a Proposed→Accepted blocker.
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:3:**Status:** Counter-argument accepted (founder-authorized 2026-06-02; not implementing Codex's requested change).
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:4:**Date:** 2026-06-02.
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:6:**Codex sessions:** R3 `20260602T105413Z-29512` issue #1 (initial); R4 `20260602T111820Z-43583` issue #1 (reaffirmed under same reasoning). The counter-argument STANDS — see "What would change the call" below; until those conditions become true, this stays disagreed.
agents/recruitment/janitor/cycle.sh:4:# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice replaces stubs with
agents/recruitment/janitor/cycle.sh:35:# Telegram approval via ESC_DUPLICATE_DETECTED. v0.4 supplement (landed 2026-06-03;
agents/recruitment/janitor/cycle.sh:90:# mismatched-invocation early. Wired at W6-7 build slice.
agents/recruitment/janitor/cycle.sh:103:# W6-7 wires: @ifos/bullhorn refreshTokens (two-step Step A OAuth + Step B
agents/recruitment/janitor/cycle.sh:108:# TODO(W6-7): replace this STUB with actual @ifos/bullhorn refreshTokens call.
agents/recruitment/janitor/cycle.sh:134:  # TODO(W6-7): @ifos/bullhorn listCandidates/listContacts/listClients (per
agents/recruitment/janitor/cycle.sh:149:  # TODO(W6-7): fuzzy-matcher; output proposed-merge list (in-memory intermediate);
agents/recruitment/janitor/cycle.sh:163:  # TODO(W6-7): same fuzzy-matcher applied to contractor entity type.
agents/recruitment/janitor/cycle.sh:176:  # TODO(W6-7): SELECT entities WHERE data missing canonical fields;
agents/recruitment/janitor/cycle.sh:190:  # TODO(W6-7): for each client with missing CRN/industry:
agents/recruitment/janitor/cycle.sh:220:  # TODO(W6-7): SELECT + group + LLM narrative generation per group +
agents/recruitment/janitor/cycle.sh:222:  hh_decision_output "tacit_note_harvest" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/janitor/cycle.sh:235:  # TODO(W6-7): per merge → @ifos/bullhorn updateCandidate (or per-contractor
agents/recruitment/janitor/cycle.sh:253:  # TODO(W6-7): SELECT + group + tally + compute Gate B + assemble 8-section
agents/recruitment/janitor/cycle.sh:257:  printf '# Janitor day-30 report — STUB\n\nTODO(W6-7): full §3 Output 1 8-section report.\n' > "${REPORT_PATH}" 2>/dev/null || true
agents/recruitment/janitor/cycle.sh:271:  # TODO(W6-7): @ifos/telegram operator_notify_telegram (green tier; REGISTERED
agents/recruitment/janitor/cycle.sh:284:# TODO(W6-7): UPDATE tenant_adapters SET config = jsonb_set(config, '{janitor_last_run}', '"<ISO>"')
agents/recruitment/janitor/cycle.sh:286:# TODO(W6-7): query 3-consecutive-run Gate B miss state from decision_log
agents/recruitment/janitor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
agents/recruitment/janitor/agent.md:5:**Reading-discipline note (added 2026-06-03 per Codex Fbis-R3 closure pattern + CC + Concierge precedent):** this `agent.md` is the **CONTRACT** that the W6-7 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `1efe9a6` + `36d1fff` + `96ae47d` + `66d1a6d` + `0837b94` per W5 Day-31); they carry `TODO(W6-7)` markers throughout that the W6-7 build slice replaces with live implementation matching the contract below. **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON cycle.sh emits only the minimal trigger/output markers (`session_start`, `bullhorn_auth_refresh`, `mode_routed`, `bullhorn_entity_scan`, `dedup_candidate_pass`, `dedup_contractor_pass`, `field_completeness_audit`, `companies_house_enrichment`, `linkedin_enrichment_skipped`, `tacit_note_harvest`, `bullhorn_write_batch`, `day_30_report`, `operator_notify_telegram`, `janitor_run_complete`) listed at `cycle.sh` lines 105, 134, 144, 159, 175, 185, 196, 205, 220, 232, 252, 273, 289, 297.** The yellow-tier audit rows the contract names (`bullhorn_candidate_dedupe` + `bullhorn_field_backfill` + `bullhorn_note_attach`) are NOT yet emitted at runtime — they're the W6-7 contract surface, not current behavior. The SKELETON `context.sh` uses **env-var fallbacks** today (`IFOS_FORCE_BULLHORN_CORPORATION_ID`, `IFOS_FORCE_JANITOR_DEDUP_THRESHOLD`, `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID`) even though the v0.4 schema supplement LANDED 2026-06-03 (commit `a1bbcf6` + LIVE on VPS) made the canonical `SELECT config->>'<key>' FROM tenant_adapters` path schema-clean for all three — that wiring lands at W6-7 alongside the `@ifos/bullhorn` refresh integration. Don't read agent.md as a description of running code; read it as the spec the W6-7 build slice implements.
agents/recruitment/janitor/agent.md:6:**Date:** 2026-05-24.
agents/recruitment/janitor/agent.md:18:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:86:     (used for tacit-note attribution) + recent edits (for note harvest)
agents/recruitment/janitor/agent.md:147:   → hh_decision_output("janitor_tacit_note_harvest", "tenant:<slug>",
agents/recruitment/janitor/agent.md:194:- No PII outside firm boundary in tacit-note narratives (regex pass)
agents/recruitment/janitor/agent.md:218:All codes are registered in `agents/_shared/escalation-codes.md` (catalogue extended to 52 codes per `2026-05-24` bilateral disposition; see disagreement-doc + `catalogue(bilateral)` commit).
agents/recruitment/janitor/agent.md:226:| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/janitor/agent.md:243:Step 8 (tacit-note narrative generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/janitor/agent.md:250:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:264:| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action; Trigger 1 fires 2026-06-03 if no LOI |
agents/recruitment/janitor/agent.md:265:| **Bullhorn Sub-decision A Accepted** | Bullhorn partnerships response | ⏸ Form submitted 2026-05-24; 2-5 business days |
agents/recruitment/janitor/agent.md:278:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
docs/verticals/recruitment/vertical-schema.yaml:14:#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
docs/verticals/recruitment/vertical-schema.yaml:20:date: 2026-05-18
docs/verticals/recruitment/vertical-schema.yaml:54:      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:119:        source: IFOS-derived (Scribe extraction; GBP annual)
docs/verticals/recruitment/vertical-schema.yaml:132:        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:136:        source: IFOS-derived (Scribe extracts)
docs/verticals/recruitment/vertical-schema.yaml:159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
docs/verticals/recruitment/vertical-schema.yaml:196:        source: IFOS-derived (Scribe extracts from call; GBP per day)
docs/verticals/recruitment/vertical-schema.yaml:348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:426:      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
docs/verticals/recruitment/vertical-schema.yaml:435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
docs/verticals/recruitment/vertical-schema.yaml:692:  Scribe:
docs/verticals/recruitment/vertical-schema.yaml:695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
docs/verticals/recruitment/vertical-schema.yaml:833:    surfaced_during_drafting: 2026-05-18 Day 6
docs/verticals/recruitment/vertical-schema.yaml:838:    status: DEFERRED to v1.1 / ADR-006
docs/verticals/recruitment/vertical-schema.yaml:839:    surfaced_during_drafting: 2026-05-18 Day 6
docs/verticals/recruitment/vertical-schema.yaml:846:    surfaced_during_drafting: 2026-05-18 Day 6
docs/verticals/recruitment/vertical-schema.yaml:853:    surfaced_during_drafting: 2026-05-18 Day 6
docs/verticals/recruitment/vertical-schema.yaml:860:    surfaced_during_review: 2026-05-18 Day 6 founder review (S4)
docs/verticals/recruitment/vertical-schema.yaml:868:    surfaced_during_review: 2026-05-18 Day 6 founder review (S2)
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:884:    date: 2026-05-18 (Day 6 of Week 0)
docs/verticals/recruitment/vertical-schema.yaml:893:    target: Week-4-end (~2026-06-21 if Week 1 starts 2026-05-21 per Day-5 kill criterion §2 Trigger 1 calendar).
docs/verticals/recruitment/vertical-schema.yaml:896:    expected_date: post first-pilot operations (Q4 2026 if pilot lands per master brief §6 Day 7 question 1)
agents/recruitment/diagnostic/cleanup.sh:41:# shellcheck disable=SC2086
agents/recruitment/diagnostic/cleanup.sh:50:# shellcheck disable=SC2086,SC2012
docs/architecture/agent-bundle-renderer-design.md:3:**Date:** 2026-05-16 (Week 0, Day 1 evening — Week-1-prerequisite pull-forward)
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:695:- Next renderer invocation runs a preflight sweep: any `${frameworkRoot}/orgs/<org>/agents/*.tmp.*` directory older than 5 minutes is deleted as stale.
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
agents/recruitment/cash-conductor/cycle.sh:30:#      per D1-B Telegram shim — docs/decisions/2026-05-31-d1-founder-decision.md)
agents/recruitment/cash-conductor/cycle.sh:172:#             cash_conductor_transactions (v0.3 schema; applied 2026-05-31).
agents/recruitment/cash-conductor/cycle.sh:503:# Reference: agent.md §4 Step 10 + D1-B (2026-05-31 founder decision).
agents/recruitment/cash-conductor/cycle.sh:709:# by validate_tenant_adapters_config_v0_3 trigger landed 2026-05-31).
agents/recruitment/janitor/README.md:28:- Bullhorn Sub-decisions A+B Accepted (per Bullhorn partnerships form submitted 2026-05-24)
agents/recruitment/scribe/cleanup.sh:2:# Scribe agent — cleanup.sh (post-run state purge; W6 build slice LIVE)
agents/recruitment/scribe/cleanup.sh:4:# Status: built (W6 build slice; the W5 Day-32 skeleton stubs are replaced
agents/recruitment/scribe/cleanup.sh:8:# Per agent.md §3 actions list: Scribe's cleanup action_type is
agents/recruitment/scribe/cleanup.sh:9:# `scribe_cleanup` (green tier — internal-only audit row recording
agents/recruitment/scribe/cleanup.sh:12:# Per agents/_shared/autosend-policy.yaml: `scribe_cleanup` is still QUEUED
agents/recruitment/scribe/cleanup.sh:13:# for registration (verified 2026-06-10 — registering it requires an
agents/recruitment/scribe/cleanup.sh:31:#   - Purge /tmp/scribe-<tenant>-* run artefacts older than 24h (Step 3 wrote
agents/recruitment/scribe/cleanup.sh:33:#   - Stamp ~/.ifos-cache/scribe/<tenant>/last-poll-<workspace_id>.txt with the
agents/recruitment/scribe/cleanup.sh:38:#   - Vault tacit-note artefacts (/vault/<tenant>/scribe-notes/) — kept for audit
agents/recruitment/scribe/cleanup.sh:48:  printf 'scribe/cleanup.sh: CTX_AGENT_DIR unset\n' >&2
agents/recruitment/scribe/cleanup.sh:52:  printf 'scribe/cleanup.sh: CTX_TENANT_SLUG unset\n' >&2
agents/recruitment/scribe/cleanup.sh:55:: "${CTX_AGENT_NAME:=scribe}"
agents/recruitment/scribe/cleanup.sh:97:done < <(find /tmp -maxdepth 1 -type f -name "scribe-${CTX_TENANT_SLUG}-*" -mtime +1 -delete -print 2>/dev/null || true)
agents/recruitment/scribe/cleanup.sh:100:# Step 2 — Stamp the Scribe-internal last-poll cache file
agents/recruitment/scribe/cleanup.sh:101:# (~/.ifos-cache/scribe/<tenant>/last-poll-<workspace_id>.txt) — the next
agents/recruitment/scribe/cleanup.sh:105:LAST_POLL_CACHE_DIR="${HOME}/.ifos-cache/scribe/${CTX_TENANT_SLUG}"
agents/recruitment/scribe/cleanup.sh:117:# scribe_cleanup is QUEUED in autosend-policy.yaml → hh_decision_output until
agents/recruitment/scribe/cleanup.sh:123:hh_decision_output "scribe_cleanup" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/scribe/cleanup.sh:127:printf '[scribe cleanup.sh] tenant=%s purged total=%d (bullhorn=%d granola=%d tmp=%d) last_poll=%s (%s)\n' \
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:1:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:19:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:25:This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:31:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:33:Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:56:**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:58:**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:70:> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:74:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:76:This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:83:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:103:- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:109:- `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue updated to include this ADR. NOT yet updated as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:128:- `docs/decisions/2026-05-18-codex-ratification-manifest.md` → adds this ADR as ratification queue item
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:140:| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:150:- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:152:*End of ADR-006.*
agents/recruitment/cash-conductor/tools.yaml:102:    action_type: open_banking_truelayer  # green tier; REGISTERED in autosend-policy.yaml per Codex F-R1 closure 2026-06-01
agents/recruitment/cash-conductor/tools.yaml:111:  # Removed per docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md.
agents/recruitment/cash-conductor/tools.yaml:128:  # Autosend bridge (D1-B Telegram shim per 2026-05-31 founder decision;
agents/recruitment/cash-conductor/tools.yaml:129:  # package scaffold landed 2026-06-01). Split into two rows because the two
agents/recruitment/cash-conductor/tools.yaml:188:# Already REGISTERED in agents/_shared/autosend-policy.yaml (verified 2026-05-25
agents/recruitment/janitor/fixtures/01-primary.yaml:17:# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice wires the real
agents/recruitment/janitor/tools.yaml:3:# Status: Proposed (W5 Day-31 SKELETON; W6-7 build slice may add per-tenant
agents/recruitment/janitor/tools.yaml:16:# in autosend-policy.yaml (verified 2026-06-03 — see status table at bottom).
agents/recruitment/janitor/tools.yaml:17:# janitor_cleanup is QUEUED for registration at W6-7 build start (matches
agents/recruitment/janitor/tools.yaml:28:  # Schema-clean post v0.4 supplement (LIVE on VPS 2026-06-03; commit a1bbcf6)
agents/recruitment/janitor/tools.yaml:36:    action_type: bullhorn_oauth          # green tier; QUEUED for registration at W6-7
agents/recruitment/janitor/tools.yaml:91:    purpose: "Attach tacit-note narrative from recent_edit harvest (Step 8 → Step 9)"
agents/recruitment/janitor/tools.yaml:131:    action_type: janitor_cleanup    # green tier; QUEUED for registration at W6-7
agents/recruitment/janitor/tools.yaml:157:  - condition: "PII detected outside firm boundary in tacit-note narrative (validate.sh G6)"
agents/recruitment/janitor/tools.yaml:177:# Already REGISTERED in agents/_shared/autosend-policy.yaml (verified 2026-06-03
agents/recruitment/janitor/tools.yaml:184:# QUEUED for registration at W6-7 build start:
agents/recruitment/janitor/tools.yaml:196:#   marked QUEUED above for W6-7 build-start registration).
docs/architecture/cortexos-kb-surface-investigation.md:3:**Date:** 2026-05-16 (Week 0, Day 1)
docs/architecture/cortexos-kb-surface-investigation.md:30:- **Embedding provider:** Gemini. `embedding_model: "gemini-embedding-2-preview"` with `embedding_dimensions: 3072`. Migration logic at line 100-104 rewrites stale `text-embedding-004` references (the previous Gemini model, shut down 2026-01-14).
agents/recruitment/cash-conductor/README.md:14:**Most-independent v1.0 agent.** Zero Bullhorn dependency. Operates against accounting system + Open Banking only. Per ADR-005 §5.1: pull-forward candidate if Bullhorn paths delayed past 2026-06-10.
agents/recruitment/diagnostic/fixtures/01-primary.yaml:47:        filed_at: "2026-04-21"
agents/recruitment/diagnostic/fixtures/01-primary.yaml:49:        filed_at: "2026-03-08"
agents/recruitment/diagnostic/fixtures/01-primary.yaml:55:      last_post_at: "2026-05-19"
agents/recruitment/diagnostic/fixtures/01-primary.yaml:74:      last_updated_signal: "2026-05-15"
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:43:        filed_at: "2026-02-10"
agents/recruitment/scribe/bin/bh-bridge.sh:2:# Scribe — Bullhorn CLI-bridge shim (single reconciliation point).
agents/recruitment/scribe/bin/bh-bridge.sh:4:# WHY THIS FILE EXISTS (parallel-conflict rule, W6 build slice):
agents/recruitment/scribe/bin/bh-bridge.sh:6:#   Scribe must NOT touch that package. ALL of Scribe's Bullhorn calls route
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:5:-- Authored:     2026-05-24 (Day 19; post-bilateral Cat-β unblock)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:18:--     + schema supplement (per ADR-006 Tier 2 + v0.3 supplement §5). v0.3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:359:         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:444:    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
agents/recruitment/scribe/bin/render-tacit-note.sh:2:# Scribe — Step 6 tacit-note renderer (agent.md §3 Output 2 + 8-category taxonomy).
agents/recruitment/scribe/bin/render-tacit-note.sh:4:# Prints ONE tacit-note markdown document (YAML frontmatter + body) to stdout.
agents/recruitment/scribe/bin/render-tacit-note.sh:24:#   render-tacit-note.sh --call-id ID --date YYYY-MM-DD --transcript <path> \
agents/recruitment/scribe/bin/render-tacit-note.sh:43:    *) printf 'render-tacit-note.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
agents/recruitment/scribe/bin/render-tacit-note.sh:47:  printf 'render-tacit-note.sh: --call-id, --date and --transcript <existing file> required\n' >&2
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:3:**Date:** 2026-05-20 (Day 8, Codex Round 1 incorporation)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:72:**Round-2 remediation update (2026-05-22):** this source-document sharpening landed in this commit alongside the new `bullhorn-integration-path.md` Gate hierarchy subsection.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:86:**Resolution update (2026-05-22):** [x] Incorporated via "Counter-argued + sharpen wording." The source decision now encodes the prereq-code-only gate and the W5 Janitor auth gate explicitly.
agents/recruitment/scribe/bin/sla-class.sh:2:# Scribe — Step 10 SLA bucket classifier (agent.md §4 Step 10; catalogue §2.10).
agents/recruitment/scribe/bin/sla-class.sh:5:# testable by scripts/run-scribe-sla-test.sh and shared verbatim by cycle.sh.
docs/architecture/cortexos-primitive-status.md:3:**Date:** 2026-05-16 (Week 0, Day 1)
docs/architecture/cortexos-primitive-status.md:40:The code is real, well-instrumented, and the agent-process layer has unit tests with substantial regression coverage. It does not earn "shipped and tested" because (a) there is no direct unit test of `AgentPTY.spawn()` against the real `node-pty` binding, (b) Day-0 setup surfaced two concrete production-class quirks against this primitive (node-pty Node 25+ ABI breakage, npm-link PATH conflict), and (c) `ecosystem.config.js:42-46` cites a real "2026-04-22 restart storm" that required structural hardening (BUG-011, BUG-032, BUG-040, BUG-048 fixes are still visible as defence-in-depth in `agent-process.ts`).
docs/architecture/cortexos-primitive-status.md:45:- `packages/harness/cortextos/src/daemon/agent-process.ts:21-720` — `AgentProcess` orchestrates the full lifecycle. Notable hardening visible in the code: BUG-040 lifecycle-generation guard (`agent-process.ts:111` and `:142-146`), BUG-032 CRLF + 5s wait on `/exit` graceful shutdown (`:227-231`), BUG-011 exit-promise race fix (`:133-152, :248-256`), BUG-048 stale-config session-timer re-read (`:611-636`). Crash recovery uses exponential backoff capped at 5 minutes (`:437`), `max_crashes_per_day` default 10 (`:28`), halts the agent after exceeded.
docs/architecture/cortexos-primitive-status.md:47:- `packages/harness/cortextos/ecosystem.config.js:14-51` — daemon script entry, env-driven, `autorestart: true`, `max_restarts: 10`, `restart_delay: 5000`. The 35-line comment block above `max_restarts` explicitly names the 2026-04-22 storm and warns against raising the values without strengthening the upstream fix.
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/architecture/cortexos-primitive-status.md:107:- `src/daemon/fast-checker.ts:899-1003` — `checkContextStatus()` polls `${stateDir}/context_status.json` written by the `hook-context-status` statusLine bridge. Three tiers: Tier 1 warning at `ctx_warning_threshold` default 70% injects `[CONTEXT] Window at X%`, Tier 2 handoff at `ctx_handoff_threshold` default 80% writes the handoff prompt and `.force-fresh` marker (line 996-1000), Tier 3 force-restart 5 minutes after Tier 2 if the agent didn't comply (line 962-967).
docs/architecture/cortexos-primitive-status.md:147:# After Tier 2 fires, wait 5 minutes without acting; expect "Handoff deadline exceeded — force restarting"
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:303:- `src/telegram/transcribe.ts` (137 lines) + `src/telegram/media.ts` (217 lines) — voice-note transcription and image/document handling — past the "approval surface" minimum but indicates the surface is production-grade for general agent comms.
docs/architecture/cortexos-primitive-status.md:319:- `tests/unit/telegram/transcribe.test.ts` (92 lines).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:5:-- Authored:               2026-06-03 (W5 Day-30)
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:85:    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:1:# Scribe fixture — 02-edge-case-paid-only
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:5:# at fixture load), Scribe's cycle.sh Step 3 (getTranscript) MUST NOT hit
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:7:# GranolaPlanTierInsufficientError before any HTTP round-trip; Scribe maps
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:18:# + get_meeting_transcript. Scribe doesn't use list_meeting_folders. This
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:21:# Status: built (W6 build slice). IMPORTANT — ESC_GRANOLA_PLAN_TIER is QUEUED
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:33:agent: scribe
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:38:  command: ifosctl scribe poll-sweep
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:61:# Granola's side) but PAID-only access blocks Scribe from fetching it.
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:65:    start_time: "2026-06-03T14:00:00Z"
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:66:    end_time: "2026-06-03T14:30:00Z"
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:78:    has_transcript: true        # exists upstream but Scribe can't fetch on Free
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:79:    created_at: "2026-06-03T14:30:30Z"
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:80:    updated_at: "2026-06-03T14:31:00Z"
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:82:# No transcript fetched (Scribe skipped Step 3 via pre-guard)
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:101:  # 5 ≥0.6 → passes Gate A G2; confidences lower than transcript-based extraction
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:103:mocked_tacit_note:
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:104:  vault_path: "/vault/migration-test/scribe-notes/meeting-002-2026-06-03.md"
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:113:    meetings_with_transcripts: 0   # has_transcript:true upstream but Scribe couldn't fetch (plan-tier block)
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:126:    - action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:138:        vault_path: "/vault/migration-test/scribe-notes/meeting-002-2026-06-03.md"
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:171:      output_type: tacit_note_rendered
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:175:      action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:180:      action_type: scribe_run_complete
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:3:**Date:** 2026-05-20 (Day 8 evening)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:18:**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:58:**Cost of delay:** Trigger 1 fires 2026-06-03 if no LOI. If LOI lands but advisor isn't engaged, founder has to choose between violating kill-criterion §3.4 or delaying LOI past Trigger 1. Engage now to avoid the forced choice.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:80:**Cost of delay:** Same as D2 — Trigger 1 fires 2026-06-03. If LOI lands before D3 resolves, founder ships v1.0 with D3-A indefinite retention, which is the worst legal posture. Bundle D2 + D3 resolution.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:108:**Source artefact:** `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` §4
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:123:### ✅ D5 — RESOLVED 2026-05-22
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:158:## D1 — Resolution (2026-05-XX)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:167:OR open a follow-on ADR if the decision warrants more substantive recording (e.g., ADR-005 for D1; ADR-006 for D2 + D3 bundle).
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:3:**Status:** Accepted (2026-05-24, Day 13)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:21:| 6 | Scribe |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:29:- **Bullhorn Sub-decisions A + B remain Proposed.** Founder submitted Bullhorn partnerships form 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (commit `dc15692`); response expected 2-5 business days.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:51:5. **Buffer on kill-criterion Trigger 2.** `v1.0-kill-criterion.md` Trigger 2 fires 2026-06-14 if Diagnostic doesn't render cleanly. Today is 2026-05-24 — 21 days of buffer. Building now beats the deadline by 3 weeks.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:69:| Bullhorn unresponsive past 2026-06-10 | Force Direct-API fallback per `bullhorn-integration-path.md` §1.4; Janitor scaffold begins; Bullhorn auth gated on first pilot raising support ticket |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:85:- Q1 LOI gate (Jack's lane; Trigger 1 fires 2026-06-03 if no LOI)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:109:- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:117:| When does Bullhorn respond? | 2-5 business days from submission (sent 2026-05-24); hard cutoff 2026-06-10 per §1.4 fallback |
agents/recruitment/diagnostic/cycle.sh:39:#     per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per
agents/recruitment/diagnostic/cycle.sh:150:# shellcheck disable=SC2086
docs/decisions/autosend-approval-bridge-spec.md:4:**Date:** 2026-05-22 (Day 11, pre-Concierge W10 prerequisite)
docs/decisions/autosend-approval-bridge-spec.md:6:**Surfaced by:** Founder Decision D1 (`docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`) + Codex Round 1 autosend rejection issue 2
docs/decisions/autosend-approval-bridge-spec.md:241:| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
agents/recruitment/scribe/bin/validate-fields.sh:2:# Scribe — Step 7 / Gate A field-name + type/range validator (single source
agents/recruitment/scribe/bin/validate-fields.sh:11:# (enum sets, array caps, vault-path pattern) — verified 2026-06-10.
agents/recruitment/scribe/bin/validate-fields.sh:13:# R-only-for-Scribe fields are EXCLUDED from the writable set per the v0.3 §2
agents/recruitment/scribe/bin/validate-fields.sh:53:VALID_TMP="$(mktemp -t scribe-valid-XXXXXX)"
agents/recruitment/scribe/bin/validate-fields.sh:54:DROP_TMP="$(mktemp -t scribe-drop-XXXXXX)"
agents/recruitment/scribe/bin/validate-fields.sh:100:      jq -e '.value | type=="string" and length<=200 and test("^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\\.md$")' <<<"${row}" >/dev/null 2>&1 \
agents/recruitment/scribe/bin/validate-fields.sh:101:        || { ok=0; reason="does not match /vault/<tenant>/scribe-notes/<id>.md pattern"; } ;;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:5:-- Authored:     2026-05-20 (Phase 4 of bubbly-snuggling-lantern.md plan)
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:3:**Status:** Counter-argument accepted (founder-authorized 2026-06-02 via AskUserQuestion); cluster Fbis + G CLOSED at partial-ratification per the pre-agreed escalation rule.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:4:**Date:** 2026-06-02.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:6:**Codex sessions:** Fbis R1 `20260602T113548Z-53909` → R2 `20260602T121515Z-75910` → R3 `20260602T123841Z-89338` → R4 `20260602T131006Z-7889`. G R1-R4 same dates.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:14:| `docs/decisions/2026-05-31-d1-founder-decision.md` | G | **Proposed-with-disagreement-on-file** (this doc) |
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:41:### 2. The pre-agreed hard-stop rule (founder-authorized 2026-06-02 AskUserQuestion + cluster F precedent at commit `497fa0c`) fires here.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:57:Codex correctly identifies that agent.md text describes behavior the SKELETON cycle.sh / validate.sh / context.sh doesn't yet implement. The agent.md Reading-discipline note (added in CC commit `8cc0491` + Concierge commit `d46474c`) explicitly frames this as CONTRACT-vs-SKELETON-runtime. **We accept the agent.md/code divergence as a known property of pre-build-slice scaffolding.** Build-slice authors writing both agent.md updates + code in same workflow eliminate the drift surface.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:97:- Consider hardening `review-agent-bundle.md` skill to explicitly accept "agent.md describes target W-X build-slice behavior; SKELETON files exist with TODO(W-X) markers" as a non-rejection state. The skill currently treats agent.md ↔ code drift as a structural issue when in reality scaffolding inherently has this property.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:98:- Consider a radical-shrink approach: trim each agent.md to ~50 lines (output contract + 5-line workflow summary + ESC catalogue subset only), push implementation detail into actual cycle.sh/context.sh as comments where they live next to the code they describe. Removes ~90% of the drift surface.
docs/architecture/vault-concurrency.md:4:**Date:** 2026-05-17 (Week 0, Day 3 evening — Week-1 prerequisite #2)
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:78:  const fd = openSync(lockPath, 'a+', 0o600);
docs/architecture/vault-concurrency.md:172:      await fs.writeFile(tmpPath, newFileContent, { mode: 0o644 });
docs/architecture/vault-concurrency.md:358:        await fs.writeFile(tmpPath, rewritten, { mode: 0o644 });
docs/architecture/vault-concurrency.md:397:**Status update 2026-05-20 (Day 8 Codex Round 1):** all 5 codes below are now catalogued at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`, Phase 1 of Week-1 slice) AND wired into the `autosend_escalate` helper at `agents/_shared/hook-helpers.sh` (commit `e6e9df1`, Phase 3 of Week-1 slice). The "_shared/hook-helpers.sh Week-1 prereq must wire these 5 codes" language below has been satisfied — current state is shipped + tested.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:5:-- Authored:     2026-05-22 (Day 11, Founder Decision D3 pre-write)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:3:**Date:** 2026-05-16 (Week 0, Day 1)
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:4:**Author:** Claude Code, founder decision logged 2026-05-16
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:7:**Status:** Accepted — Option α. Founder decision logged 2026-05-16.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:75:**Disposition update 2026-05-20 (Day 8 Codex Round 1):** all three edits landed in the atomic-correction commit **`0e5b2b4`** ("docs: master brief reconciliation — 11 edits batch-applied", Day 7 2026-05-20). Manifest-of-record below — each edit's "where it landed" is `0e5b2b4`.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:77:Three edits, two in the atomic correction commit alongside ADR-001's `chokidar → FastChecker` edits, one in the Day 4 Postgres provisioning task. **All three landed in commit `0e5b2b4` on 2026-05-20** — verifiable via `git show 0e5b2b4 -- docs/build-brief/00-MASTER-BRIEF.md`.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:121:**For the master brief atomic correction commit.** ADR-001 (Edit: `chokidar watcher` → `FastChecker poll loop` in §2.4 row 3 + §3.2 latency reframe in Ultraplan) and ADR-002 (Edits 1, 2, 3 above — §3.4 wording, §5.5 v1.0 brain build wording, §6 Day 4 Postgres table list) **all landed together in commit `0e5b2b4` on 2026-05-20** ("docs: master brief reconciliation — 11 edits batch-applied"). Ratified by Codex on Day 7 along with ADR-001 + ADR-003 per master brief §10.6.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:131:**Accepted — Option α.** Founder decision logged 2026-05-16. Next steps:
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:133:1. ADR-001 + ADR-002 master-brief edits LANDED in atomic-correction commit `0e5b2b4` (Day 7 2026-05-20). Status: closed.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:135:3. Day 7 Codex ratification reviews ADR-001 + ADR-002 + the seven Week 0 artefacts together (per master brief §10.6).
docs/verticals/recruitment/migrations/v0.4-to-v0.5.sql:4:-- Authored:     2026-06-09 (W7 Cash Conductor P3 reconciliation build slice)
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:3:**Date:** 2026-05-16 (Week 0, Day 1)
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:4:**Author:** Claude Code, founder decision logged 2026-05-16
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:7:**Status:** Accepted — Option A. Founder decision logged 2026-05-16.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:13:Master brief §2.4 row 3 describes Primitive 3 (Inter-agent file bus) as:
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:40:Recommend a one-paragraph footnote in §2.4 that names the substrate: messages are JSON files under `${ctxRoot}/inbox/<to>/{pnum}-{epochMs}-from-{sender}-{rand5}.json`, three-directory lifecycle (`inbox → inflight → processed`), HMAC-SHA256 signed (Quirk 5), stale-inflight recovery at 5 minutes.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:76:**Accepted — Option A.** Founder decision logged 2026-05-16. The master brief §2.4 row 3 + Ultraplan §3.2 edits are deferred to a single atomic "spec drift reconciliation" commit that lands alongside whatever ADR-002 dictates for §3.4. Codex ratifies the combined commit on Day 7 with the other Week 0 artefacts.
docs/decisions/autosend-safety-policy.md:4:**Date:** 2026-05-18 (Week 0, Day 5)
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:83:| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
docs/decisions/autosend-safety-policy.md:93:| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
docs/decisions/autosend-safety-policy.md:106:| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
docs/decisions/autosend-safety-policy.md:277:Deadline: 2026-05-18 18:42 UTC
docs/decisions/autosend-safety-policy.md:313:Target: invoice:INV-2026-0042
docs/decisions/autosend-safety-policy.md:494:- **Per-recipient reputation:** recipients with high engagement may be in implicit "always-orange" zone; recipients with prior unsubscribes may be elevated to red.
docs/decisions/autosend-safety-policy.md:588:**Founder Decision D2 + D3 pending (Codex Round 2 rejection).** This section is non-binding placeholder language. First pilot LOI signing is BLOCKED until counsel-reviewed language replaces this section. See `docs/operations/seedlegals-engagement-queries.md` for the founder's engagement queries + `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D2 + §D3 for the founder decision framing.
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:618:Three open questions resolved by founder review on 2026-05-18 (Day 5):
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:1:# Scribe fixture — 99-voice-drift-blocked
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:4:# agent.md §3 line 111. When the tacit-note narrative voice score is <0.75
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:7:# The vault tacit-note artefact IS written (so the operator can see what
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:18:# rows in 7d window per the same tenant (per catalogue §2.5); Scribe does
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:21:# Status: built (W6 build slice). The voice score is supplied via the
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:29:#         scripts/run-scribe-gate-a-test.sh (G3 fail class + ESC_VOICE_DRIFT).
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:34:agent: scribe
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:39:  command: ifosctl scribe poll-sweep
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:63:    start_time: "2026-06-03T16:00:00Z"
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:64:    end_time: "2026-06-03T16:30:00Z"
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:71:    created_at: "2026-06-03T16:30:30Z"
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:72:    updated_at: "2026-06-03T16:31:00Z"
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:78:  generated_at: "2026-06-03T16:31:00Z"
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:96:# Field extraction succeeds — 3 fields ≥0.6 (passes Gate A G2)
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:100:  - { field_name: "week_1_status_vault_path", value: "/vault/migration-test/scribe-notes/meeting-099-2026-06-03.md", confidence: 0.95 }
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:103:mocked_tacit_note:
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:104:  vault_path: "/vault/migration-test/scribe-notes/meeting-099-2026-06-03.md"
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:107:    - 0.62   # retry 1
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:109:    - 0.61   # retry 3 — all below 0.75
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:110:  voice_score_final: 0.61      # max of attempts; FAILS G3
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:122:    final_score: 0.61
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:127:    g2_field_count_pass: true    # ≥3 fields ≥0.6
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:128:    g3_voice_pass: false         # voice 0.61 < 0.75
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:139:    path: "/vault/migration-test/scribe-notes/meeting-099-2026-06-03.md"
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:146:        voice_score_attempts: [0.62, 0.58, 0.61]
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:166:      output_type: tacit_note_rendered
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:167:      payload_contains: "voice_score:0.61"   # vault frontmatter carries needs_consultant_review: true
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:174:      payload_contains: "ESC_VOICE_DRIFT; agent_name:scribe"
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:176:      action_type: scribe_run_complete
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:5:-- Authored:     2026-06-03 (W5 Day-30; post-MCP-sweep)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:14:--   - granola_workspace_id       (per-tenant Granola workspace identifier; W6+ Scribe)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:101:    'granola_workspace_id',       -- per-tenant Granola workspace (W6+ Scribe)
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:3:**Date:** 2026-05-20 (Day 8, Codex Round 1 incorporation)
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:54:- [x] **Incorporated (Codex correct on Context + Status; counter-argued on Decision/Consequences for Reference + In Force — Founder Decision D5-A accepted 2026-05-22)**
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:58:**Resolution detail (2026-05-22):** Founder accepted D5-A. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` — Reference + In Force status artefacts are now exempt from Decision + Alternatives + Consequences sections (Context + Status update line still required). The two REJECTED artefacts from Round 1 (`cortexos-primitive-status.md`, `operational-hygiene-protocol.md`) are expected to RATIFY in Round 2 without changes. Two new Day-9 artefacts (`architecture-cohesion-review.md` Reference, `tenant-lifecycle.md` In Force) are now ratifiable under the softened skill.
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:60:## §4 — Founder decision (RESOLVED 2026-05-22)
docs/decisions/2026-05-31-d1-founder-decision.md:3:**Status:** Accepted (founder-arbitrated 2026-05-31 via explicit delegation: *"i pretty much trust your decision making for the technical build stuff"*). Codex ratification: **deferred-to-W10-13-build-slice** per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` (cluster G stopped at partial-ratification after 4 rounds; the structural decision is accepted; the cross-doc consistency surface gets reconciled when W10-13 lands).
docs/decisions/2026-05-31-d1-founder-decision.md:5:**Date:** 2026-05-31
docs/decisions/2026-05-31-d1-founder-decision.md:7:**Supersedes:** the "D1 founder decision" line item in `2026-05-20-codex-round-1-founder-decisions.md` and the open-question rows in:
docs/decisions/2026-05-31-d1-founder-decision.md:53:5. **Tenant config — W10-13 build-slice author picks the shape; BOTH paths now schema-clean.** The autosend-bridge consumer needs a per-tenant operator Telegram chat-id at runtime. Post-v0.4 supplement (LANDED 2026-06-03; commit `a1bbcf6`), the `validate_tenant_adapters_config_v0_4` allowlist contains **16 keys** (11 v0.3-forwarded + 5 v0.4-added: `operator_telegram_chat_id`, `email_channel`, `workos_org_id`, `granola_workspace_id`, `bullhorn_corporation_id`). Two viable paths the W10-13 build-slice author chooses between (BOTH schema-clean; no further schema work required):
docs/decisions/2026-05-31-d1-founder-decision.md:59:   This decision-doc does NOT prescribe Path A vs Path B for the W10-13 author; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend). Path A is the recommended production path for the reasons above; Path B is a supported alternative.
docs/decisions/2026-05-31-d1-founder-decision.md:71:- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: ADR-007 Accepted + Codex RATIFIED (DONE 2026-05-31 + Round 3), pilot LOI (PENDING), Bullhorn A+B (PENDING), founder approves §9 Q2-Q6 (PENDING).
docs/decisions/2026-05-31-d1-founder-decision.md:72:- **Schema impact: minimal-to-none → BOTH paths schema-clean post-v0.4.** Updated 2026-06-03: v0.4 supplement LANDED (commit `a1bbcf6`) adding `operator_telegram_chat_id` as a top-level allowlist entry. The W10-13 build slice now has TWO supported paths: Path A (reuse `approval_routing` JSONB sub-tree; recommended for new tenants — see implementation surface item 5) or Path B (use the new top-level key directly). Either path satisfies schema-before-code. The current consumer scaffolding (Concierge `context.sh` Step 5 + 3 fixtures) reads via `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback and does NOT attempt any `tenant_adapters` read; W10-13 build-slice author chooses Path A or Path B + implements the canonical SELECT alongside connection-pool setup.
docs/decisions/2026-05-31-d1-founder-decision.md:74:- **Schema-before-code discipline — respected.** The five rules (master brief §1) state schema-before-code. Today's state: bridge package scaffold + consumer wiring landed in env-var-fallback mode; no consumer attempts to read `tenant_adapters.config.operator_telegram_chat_id` (which isn't yet allowlisted as a top-level key) at runtime. Concierge `context.sh` lines 88-90 (post-2026-06-02 update) use `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback exclusively; fixtures use `tenant_env_overrides:` blocks (renamed from `tenant_config:` post-2026-06-02) to make the env-var-not-postgres distinction explicit. The schema-before-code rule holds: no schema-violating read occurs at runtime today; when the W10-13 build-slice author chooses Path A (reuse `approval_routing`) or Path B (add v0.4 key), the appropriate schema state will be in place BEFORE the consumer code is wired to read it.
docs/decisions/2026-05-31-d1-founder-decision.md:82:**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **all consumers still operate in env-var-fallback mode** (per `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` in `context.sh`); no `tenant_adapters` reads attempted at runtime; fixtures use `tenant_env_overrides:` blocks to match. **v0.4 supplement LANDED 2026-06-03** (commit `a1bbcf6`) adding `operator_telegram_chat_id` as a top-level allowlist entry — W10-13 build slice picks Path A (reuse `approval_routing` JSONB; recommended) or Path B (top-level key); **both paths are now schema-clean**. Concierge `context.sh` TODO(W10-13) markers updated 2026-06-03 (commit `98ab8ce`) to reflect supplement-landed state. Codex ratification currently in flight under cluster G (R3 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc); v0.4 supplement will ratify separately under W5 Phase 7 F-tris cluster.
docs/_archive-build-pack/03-ARCHITECTURE.md:163:pulled: 2026-05-16
docs/_archive-build-pack/03-ARCHITECTURE.md:320:│   ├── 2026-04-slate-acquisitions.md
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:5:-- Authored:               2026-05-24 (Day 19)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:33:  -- DROP TABLE IF EXISTS lines below (Codex R3 finding 2026-05-31).
agents/recruitment/scribe/bin/extract-fields.sh:2:# Scribe — Step 5 field extraction (agent.md §4 Step 5; spec-002 §4 row 5).
agents/recruitment/scribe/bin/extract-fields.sh:27:# --vault-path: the canonical tacit-note pointer for placement
agents/recruitment/scribe/bin/extract-fields.sh:51:FIELDS_TMP="$(mktemp -t scribe-fields-XXXXXX)"
agents/recruitment/scribe/bin/extract-fields.sh:71:    model: $model, max_tokens: 4096,
agents/recruitment/scribe/bin/extract-fields.sh:128:    # NOTE: decision_authority is R-only for Scribe (v0.3 §2 access matrix) — never extracted for write.
agents/recruitment/scribe/bin/extract-fields.sh:166:      _emit_str "satisfaction_signal" "unclear" 0.55   # weak cue — below the 0.6 Gate A bar by design
agents/recruitment/scribe/bin/extract-fields.sh:168:    # Pointer to THIS call's tacit-note (ADR-002: pointer in Postgres, narrative in vault).
docs/verticals/recruitment/migrations/v0.5-to-v0.4.sql:5:-- Authored:     2026-06-09 (W7 Cash Conductor P3 reconciliation build slice)
docs/decisions/brain-ui-scope.md:3:**Date:** 2026-05-16 (Week 0, Day 3)
docs/decisions/brain-ui-scope.md:4:**Status:** Proposed — revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch)
docs/decisions/brain-ui-scope.md:24:**Revisit trigger:** start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2 v1.1 timing). Three v1.0 observations will inform the v1.1 scoping session:
docs/decisions/brain-ui-scope.md:48:- No real-time streaming (polling-based refresh, likely 30-60s default; deferred to v1.2+).
docs/decisions/brain-ui-scope.md:148:The v1.0 demo per master brief §10.6 live-demo pattern + Product Spec §10 closing-demo asset shows:
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/decisions/brain-ui-scope.md:217:| Real-time vs polling for today view refresh (default polling 30-60s) | v1.1 planning — based on observed v1.0 escalation frequency; if `ESC_*` rate is high, real-time may matter |
docs/decisions/brain-ui-scope.md:229:**Proposed.** Revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2). At revisit, founder + Claude Code:
docs/decisions/brain-ui-scope.md:233:3. Scope sub-features and weekly build plan for v1.1 Brain UI work — likely Q4 2026 sprints, exact weekly slots TBD against the v1.1 master-brief sequence.
agents/recruitment/scribe/fixtures/01-primary.yaml:1:# Scribe fixture — 01-primary (happy path)
agents/recruitment/scribe/fixtures/01-primary.yaml:8:#   Step 5 LLM extraction yields 4 fields all ≥0.6 confidence (passes
agents/recruitment/scribe/fixtures/01-primary.yaml:10:#   tacit-note written → Step 7 validate.sh G1-G7 all pass → Step 8
agents/recruitment/scribe/fixtures/01-primary.yaml:11:#   @ifos/bullhorn updateCandidate (yellow tier bullhorn_scribe_field_write)
agents/recruitment/scribe/fixtures/01-primary.yaml:12:#   → Step 9 createNote attaches the vault tacit-note (yellow tier
agents/recruitment/scribe/fixtures/01-primary.yaml:20:# Status: built (W6 build slice). Marker names below follow the spec-002 §3
agents/recruitment/scribe/fixtures/01-primary.yaml:23:#         scripts/run-scribe-extraction-test.sh (BH_BRIDGE_TEST_MODE=ok —
agents/recruitment/scribe/fixtures/01-primary.yaml:29:agent: scribe
agents/recruitment/scribe/fixtures/01-primary.yaml:34:  command: ifosctl scribe poll-sweep
agents/recruitment/scribe/fixtures/01-primary.yaml:52:  plan_tier: "paid"             # founder 2026-06-03 confirmed Business+
agents/recruitment/scribe/fixtures/01-primary.yaml:61:    start_time: "2026-06-03T09:00:00Z"
agents/recruitment/scribe/fixtures/01-primary.yaml:62:    end_time: "2026-06-03T09:45:00Z"
agents/recruitment/scribe/fixtures/01-primary.yaml:70:    created_at: "2026-06-03T09:45:30Z"
agents/recruitment/scribe/fixtures/01-primary.yaml:71:    updated_at: "2026-06-03T09:46:00Z"
agents/recruitment/scribe/fixtures/01-primary.yaml:78:  generated_at: "2026-06-03T09:46:00Z"
agents/recruitment/scribe/fixtures/01-primary.yaml:101:  # confidence threshold 0.6; 5 ≥0.6 → passes Gate A G2 (≥3 required)
agents/recruitment/scribe/fixtures/01-primary.yaml:103:# Mocked tacit-note voice classifier (Step 6)
agents/recruitment/scribe/fixtures/01-primary.yaml:104:mocked_tacit_note:
agents/recruitment/scribe/fixtures/01-primary.yaml:105:  vault_path: "/vault/migration-test/scribe-notes/meeting-001-2026-06-03.md"
agents/recruitment/scribe/fixtures/01-primary.yaml:121:    fields_above_threshold: 5   # all 5 ≥0.6
agents/recruitment/scribe/fixtures/01-primary.yaml:127:    - action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/01-primary.yaml:138:        vault_path: "/vault/migration-test/scribe-notes/meeting-001-2026-06-03.md"
agents/recruitment/scribe/fixtures/01-primary.yaml:159:      output_type: tacit_note_rendered        # payload: {vault_path, body_sha256, voice_score} only (ADR-002)
agents/recruitment/scribe/fixtures/01-primary.yaml:163:      action_type: bullhorn_scribe_field_write
agents/recruitment/scribe/fixtures/01-primary.yaml:167:      action_type: scribe_run_complete
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md:4:**Date:** 2026-06-02.
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md:6:**Context:** Cluster F Round 2 (session `20260602T103527Z-17484`) returned REJECTED 3/3 with 10 new issues across the 3 MCP-connector packages.
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md:31:Proceed with R3-equivalent work. **NOT** counter-arguing any of the 10 issues — they're all defensible-as-stated. The cost is ~30-60 min of careful work; the value is closing real bugs (especially the 401-loop bug, which is production-critical) + restoring honest signal across all 3 READMEs.
agents/recruitment/scribe/agent.md:1:# Scribe — the data spine
agents/recruitment/scribe/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
agents/recruitment/scribe/agent.md:5:**Reading-discipline note (added 2026-06-03 per Codex Fbis-R3 closure pattern + CC + Concierge + Janitor precedent):** this `agent.md` is the **CONTRACT** that the W6 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `e6028e6` + `f9b4a84` + `b3819e7` + `d314661` + `313be44` per W5 Day-32); they carry `TODO(W6)` markers throughout that the W6 build slice replaces with live implementation matching the contract below. **VENDOR DELTA**: this `agent.md` (W3 cluster E review state — Status banner says Proposed but the review ran) describes a WEBHOOK-DRIVEN flow from Fathom/Fireflies (§2 + §4 Step 1 webhook signature verification + §6 ESC_PROVIDER_FETCH_FAIL row + §8 Fathom/Fireflies commercial signup dependency); the deployed SKELETON uses POLLING from Granola per Day-29 vendor pivot (founder confirmed 2026-06-03 — see `goal-week-5-execution-plan.md` §2 Phase 3 fix-forward + the `@ifos/granola` wrapper scaffold landed commit `1b657e6`). Granola does NOT publish webhooks per `@ifos/granola` README §"Scribe consumption pattern" — `cycle.sh` handles BOTH the outer poll-sweep loop AND the per-meeting Steps 0-10 internally. **W6 ratification updates this `agent.md` to match deployed Granola polling reality** (vendor swap; webhook → polling; Step 1 "signature verification" → "Granola transcript fetch"). **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON `cycle.sh` emits only the minimal trigger/output markers (`session_start`, `granola_meetings_polled`, `bullhorn_auth_refresh`, `transcript_fetched`, `entity_resolved`, `fields_extracted`, `tacit_note_rendered`, `fields_validated`, `dry_run_writes_skipped`, `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`, `scribe_run_complete`) at `cycle.sh` lines 130, 156, 178, 195, 211, 226, 243, 259, 268, 285, 301, 319.** The yellow-tier audit rows the contract names (`bullhorn_scribe_field_write` + `bullhorn_note_append_summary`) are NOT yet emitted at runtime — they're the W6 contract surface, not current behavior. The SKELETON `context.sh` uses **env-var fallbacks** today (`IFOS_FORCE_BULLHORN_CORPORATION_ID`, `IFOS_FORCE_GRANOLA_WORKSPACE_ID`, `IFOS_FORCE_GRANOLA_PLAN_TIER`, `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID`) even though the v0.4 schema supplement LANDED 2026-06-03 (commit `a1bbcf6` + LIVE on VPS) made the canonical `SELECT config->>'<key>' FROM tenant_adapters` path schema-clean for `bullhorn_corporation_id` + `granola_workspace_id` — that wiring lands at W6 alongside the `@ifos/bullhorn` + `@ifos/granola` refresh integrations. Don't read agent.md as a description of running code; read it as the spec the W6 build slice implements after the vendor pivot is acknowledged.
agents/recruitment/scribe/agent.md:6:**Date:** 2026-05-24.
agents/recruitment/scribe/agent.md:8:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:9:**Build complexity:** M (1 week) per ULTRAPLAN A3 line 526.
agents/recruitment/scribe/agent.md:10:**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
agents/recruitment/scribe/agent.md:18:> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:27:POST https://<tenant>.ifos.app/agents/scribe/webhook
agents/recruitment/scribe/agent.md:47:ifosctl scribe replay --tenant <slug> --call-id <provider-call-id>
agents/recruitment/scribe/agent.md:54:- Telegram command (`@ifos_bot scribe replay <call-id>`)
agents/recruitment/scribe/agent.md:71:- Opportunity scoping (consultant + prospect) → Opportunity entity update (NOTE: Bullhorn endpoint A3 row covers Candidate / ClientCorporation / JobOrder / Note / Placement only at v1.0; Opportunity writes are to IFOS-cached Postgres entity rows for the v0.3-added fields headcount_growth_signal_text + hiring_velocity_band + decision_window_text per v0.3 supplement §1, NOT direct Bullhorn endpoint calls)
agents/recruitment/scribe/agent.md:78:| Contact | `decision_authority` (enum per v0.1 Q5; R-only for Scribe per v0.3 §2 access matrix), `preferred_channel` (v0.3), `next_action_target_date` (v0.3) |
agents/recruitment/scribe/agent.md:79:| Brief | `salary_min` + `salary_max`, `start_date_target` (R-only for Scribe; Bullhorn-sourced), `role_type`, `must_haves` (v0.3), `nice_to_haves` (v0.3), `deal_breakers` (v0.3) |
agents/recruitment/scribe/agent.md:83:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
agents/recruitment/scribe/agent.md:85:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:114:Each tacit-note write emits its own `decision_log` rows: on vault render, `agent_name='scribe'`, `phase='output'`, `output_type='tacit_note_rendered'` carrying `{vault_path, body_sha256, voice_score}` (body NOT in payload per ADR-002 vault/Postgres split); on Bullhorn attach, `phase='action'`, `action_type='bullhorn_note_append_summary'`, `tier='yellow'`, payload carrying `note_payload_hash` + `payload_preview` + the resolved `<entity_type>:<bullhorn_id>` (per §4 Steps 6 + 9).
agents/recruitment/scribe/agent.md:116:Tacit-note taxonomy (v0.1 — 8 categories per ULTRAPLAN A3 line 527 starting small):
agents/recruitment/scribe/agent.md:137:     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
agents/recruitment/scribe/agent.md:138:   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
agents/recruitment/scribe/agent.md:154:   → store transcript in /tmp/scribe-<tenant>-<call_id>.txt mode 0600
agents/recruitment/scribe/agent.md:157:     "provider:<name>; bytes:<N>; tmp_path:/tmp/scribe-<tenant>-<call_id>.txt")
agents/recruitment/scribe/agent.md:166:     a Scribe run with no resolvable target cannot produce structured writes)
agents/recruitment/scribe/agent.md:173:   → discard fields confidence <0.6 (per Gate A)
agents/recruitment/scribe/agent.md:174:   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
agents/recruitment/scribe/agent.md:176:     "<N> fields ≥0.6 confidence")
agents/recruitment/scribe/agent.md:178:6. LLM tacit-note generation
agents/recruitment/scribe/agent.md:184:   → write to /vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md
agents/recruitment/scribe/agent.md:185:   → hh_decision_output("tacit_note_rendered", "<vault_path>",
agents/recruitment/scribe/agent.md:197:     "ESC_SCHEMA_VIOLATION; agent_name:scribe; valid:<N>") and exit 1
agents/recruitment/scribe/agent.md:199:     in agents/_shared/autosend-policy.yaml line 119; agent:all; Scribe uses
agents/recruitment/scribe/agent.md:205:   → on success: hh_decision_action("bullhorn_scribe_field_write",
agents/recruitment/scribe/agent.md:209:9. Bullhorn write — tacit-note attachment (yellow tier)
agents/recruitment/scribe/agent.md:218:   → Master brief §8.2 line 597 Bullhorn SLA: "post-call note in Bullhorn within
agents/recruitment/scribe/agent.md:228:   → hh_decision_action("scribe_run_complete", "call:<id>", elapsed_seconds)
agents/recruitment/scribe/agent.md:238:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:241:- ≥3 structured-field extractions with confidence ≥0.6 (per ULTRAPLAN A3 line 524 verbatim)
agents/recruitment/scribe/agent.md:242:- 1 tacit-note generated with voice classifier ≥0.75
agents/recruitment/scribe/agent.md:245:- No PII outside firm boundary in tacit-note narrative
agents/recruitment/scribe/agent.md:250:**Honesty note (per bilateral-disposition Cat-5):** Scribe `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W6 build slice. The W6 build delivers `agents/recruitment/scribe/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/scribe/agent.md:254:Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
agents/recruitment/scribe/agent.md:258:- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
agents/recruitment/scribe/agent.md:260:Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
agents/recruitment/scribe/agent.md:268:Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/scribe/agent.md:274:| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:276:| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:279:| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:286:Scribe does NOT use:
agents/recruitment/scribe/agent.md:288:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
agents/recruitment/scribe/agent.md:294:Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/scribe/agent.md:296:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:299:  - No compensation specifics in tacit notes (those go to structured fields only)
agents/recruitment/scribe/agent.md:301:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:307:## §8 — Build dependencies (W6 prerequisites)
agents/recruitment/scribe/agent.md:309:Scribe build cannot start until ALL of the following are confirmed:
agents/recruitment/scribe/agent.md:321:| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
agents/recruitment/scribe/agent.md:325:| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
agents/recruitment/scribe/agent.md:326:| `context.sh` hydration | Build at W6 start (~0.5 day) | ⏸ |
agents/recruitment/scribe/agent.md:327:| `cycle.sh` orchestration (10-step) | Build at W6 start (~2 days) | ⏸ |
agents/recruitment/scribe/agent.md:328:| 3 fixtures with golden outputs | Build at W6 start (~1 day) | ⏸ |
agents/recruitment/scribe/agent.md:331:**Until ALL ⏸ items resolve to ✅, W6 build slice does not start.**
agents/recruitment/scribe/agent.md:337:**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
agents/recruitment/scribe/agent.md:346:| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
agents/recruitment/scribe/agent.md:348:| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
agents/recruitment/scribe/agent.md:349:| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
agents/recruitment/scribe/agent.md:351:### Gotchas (carried forward from ULTRAPLAN A3 line 527)
agents/recruitment/scribe/agent.md:355:3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.
agents/recruitment/scribe/agent.md:369:- W6 build slice produces all 5 sibling bundle files + 3 fixtures
agents/recruitment/scribe/agent.md:376:*End of Scribe agent.md draft.*
docs/decisions/2026-05-18-codex-ratification-manifest.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar; actual execution 2026-05-20)
docs/decisions/2026-05-18-codex-ratification-manifest.md:6:**Source:** Master brief §10 (the Codex ratification loop) + §10.6 (Day 7 first ratification run)
docs/decisions/2026-05-18-codex-ratification-manifest.md:40:## §1.6 — Day-9 architecture+tenancy verification additions (2026-05-20 evening)
docs/decisions/2026-05-18-codex-ratification-manifest.md:55:## §1.7 — Codex Round 2 verdicts (2026-05-22)
docs/decisions/2026-05-18-codex-ratification-manifest.md:79:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | RATIFIED | First ratification on Round 2; recursive disagreement RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:80:| 20 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | REJECTED | First ratification on Round 2; recursive disagreement REJECTED. Open: see SUMMARY.md §3-§4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:81:| 21 | `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` | RATIFIED | First ratification on Round 2; RATIFIED with D1/D2/D3 advisory. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:88:## §1.8 — Codex Round 3 remediation verdicts (2026-05-22)
docs/decisions/2026-05-18-codex-ratification-manifest.md:98:| 5 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:138:**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 6 agent.md items with the new skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:144:| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:145:| 2 | `agents/recruitment/janitor/agent.md` | **REJECTED** | ~5-7 real findings (count regex 56 inflated by nested lists) | `20260524T102050Z-21293` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:146:| 3 | `agents/recruitment/scribe/agent.md` | **REJECTED** | ~5-7 real findings (count regex 59) | `20260524T102202Z-22338` |
docs/decisions/2026-05-18-codex-ratification-manifest.md:164:## §1.5 — Codex Round 1 verdicts (2026-05-20)
docs/decisions/2026-05-18-codex-ratification-manifest.md:170:| 1 | cortexos-primitive-status.md | REJECTED (2 issues) | Issue 1 (missing Status field) **incorporated** at commit `2b287d3`. Issue 2 (missing Decision/Consequences) **counter-argued** in `codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`; resolution pending Founder Decision D5. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:176:| 7 | bullhorn-integration-path.md | REJECTED (3 issues) | Issue 1 (status enum) + Issue 3 (rate-limit speculation note) **incorporated** at `2b287d3`. Issue 2 (Week-1 gate) **counter-argued** in `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`; line 95 wording sharpened. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:185:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:199:- `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`
docs/decisions/2026-05-18-codex-ratification-manifest.md:200:- `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`
docs/decisions/2026-05-18-codex-ratification-manifest.md:201:- `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`
docs/decisions/2026-05-18-codex-ratification-manifest.md:233:**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:306:Single-sentence test artefact (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`) is the sibling Day-7 close artefact in this commit. Week 0 extends per its §4 closure determination.
docs/_archive-build-pack/04-DATA-MODEL.md:276:│   │   │   │   ├── 2026-05-16T09-17-42__draft-rebecca-reply.json
docs/_archive-build-pack/04-DATA-MODEL.md:280:│   │   │       └── 2026-05-16T09-17-44__rebecca-reply.json
docs/_archive-build-pack/04-DATA-MODEL.md:305:│   ├── 2026-04-slate-acquisitions.md
docs/operations/goal-overnight-2026-05-31.md:1:# /goal — Overnight W4 Track-1 + smoke-fix (2026-05-31 → 2026-06-01)
docs/operations/goal-overnight-2026-05-31.md:3:**Authored:** evening 2026-05-31 (founder asleep; Claude executes autonomously)
docs/operations/goal-overnight-2026-05-31.md:11:- Diagnostic smoke ran 2026-05-31 evening: Gate A PASS, 12 sections, 621 words. Two findings: (a) Anthropic credits empty → §12 deterministic fallback fired (founder tops up AM); (b) validate.sh has 2 path bugs looking for shared helpers in wrong dir.
docs/decisions/v1.0-kill-criterion.md:4:**Date:** 2026-05-18 (Week 0, Day 5)
docs/decisions/v1.0-kill-criterion.md:47:**Threshold:** No design partner has confirmed pilot intent (signed LOI or equivalent written commitment to pilot in Q3 2026 per master brief §6 Day 7 question 1) by end of Week 2.
docs/decisions/v1.0-kill-criterion.md:49:**Calendar:** Day 0 was 2026-05-13 (Wednesday). Week 0 runs Days 0-7, ending Wednesday 2026-05-20. Week 1 starts Thursday 2026-05-21. Week 2 ends Wednesday 2026-06-03. **Trigger fires end-of-day 2026-06-03 if criterion unmet.**
docs/decisions/v1.0-kill-criterion.md:57:**Unfreeze criterion:** **One signed pilot LOI** from a UK recruitment agency with stated pilot start date in Q3 2026. Unfreeze formal: Founder + Jack joint sign-off on the LOI; resume v1.0 from the slice that was active when paused.
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:75:**Threshold:** Janitor agent cannot authenticate to Bullhorn via the documented OAuth flow (per `bullhorn-integration-path.md` §4.5 refresh-loop architecture) by end of Week 5 (2026-06-28). Authentication failure modes that trigger: (a) OAuth token endpoint returns non-2xx persistently; (b) refresh-loop architecture fails at 10-minute TTL boundary; (c) Bullhorn rate-limits IFOS's auth endpoint preventing pilot operations; (d) Bullhorn partnership programme requirement blocks production-tenant access.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:174:**Threshold tightened Day 5 (2026-05-18) from 4 weeks to 2 weeks.** Rationale: Risk #1 severity was downgraded Day 1 because primitives 3 + 4 confirmed "shipped and tested" per `cortexos-primitive-status.md`. If field evidence shows failure-rate spike for 2 consecutive weeks, that is an actionable signal — waiting 4 weeks delays remediation by 50% within the v1.0 build timeline (Weeks 1-13).
docs/decisions/v1.0-kill-criterion.md:204:**Day-5 restructure** (2026-05-18): Jack is high engagement on sales/commercial; founder is solo on product. This v1.0 kill criterion governs the **product domain**. Founder has SOLO authority for all trigger activations; Jack is informed-not-deciding. Commercial-domain kill criteria are deferred to a future artefact (placeholder: `v1.0-kill-criterion-commercial.md`).
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:373:**For Week 1-2.** All Week-1 work is conducted with awareness that Trigger 1 fires 2026-06-03 if no LOI (per §1 calendar — Wednesday end-of-Week-2). Founder allocates time accordingly: design-partner acquisition is a Week-1 sub-track, not an afterthought.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:155:| Headline + body | Inter (variable, 400/500/600/700) |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:187:| SOC 2 | In progress, target late 2026 | Inherited target |
docs/decisions/sequencing-target.md:3:**Date:** 2026-05-16 (Week 0, Day 3)
docs/decisions/sequencing-target.md:4:**Status:** Accepted (Day 3 session close, 2026-05-16). Single-pass technical decision, no commercial gating.
docs/decisions/sequencing-target.md:5:**Author:** Claude Code, founder decision logged 2026-05-16
docs/decisions/sequencing-target.md:23:| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
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
docs/decisions/2026-05-18-day-7-single-sentence-test.md:3:**Date:** 2026-05-18 (per master brief §6 Day 7 calendar position; actual execution 2026-05-20)
docs/decisions/2026-05-18-day-7-single-sentence-test.md:16:> 1. Do we have at least one design partner who has said "yes I will pilot this in Q3 2026"?
docs/decisions/2026-05-18-day-7-single-sentence-test.md:30:### Q1 — Design partner pilot Q3 2026 LOI?
docs/decisions/2026-05-18-day-7-single-sentence-test.md:34:- **Pipeline state:** zero design partners in pipeline as of 2026-05-18 Day 5; founder did not initiate the Sunday/Monday outreach paths queued in `bullhorn-integration-path.md` §1.3 (Bullhorn partnerships, Bullhorn dev support, design partner #1) because no named target existed for design-partner #1 path; warm-path strategy supersedes cold outreach.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:35:- **Risk register state:** Risk #3 in `docs/RISK-REGISTER.md` escalated from Medium → High on Day 5 with the explicit text "zero design partners in pipeline as of 2026-05-18 Day 5; original 'conversation 1' assumption invalidated; no founder-side outreach pipeline exists."
docs/decisions/2026-05-18-day-7-single-sentence-test.md:36:- **Kill criterion linkage:** Trigger 1 in `docs/decisions/v1.0-kill-criterion.md` §2 (DESIGN-PARTNER-BY-WEEK-2) fires end-of-day **2026-06-03** if no signed LOI by then. That is the binding tripwire — currently **14 calendar days** out from today (2026-05-20).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:37:- **Master brief §6 Day 7 question 1 cannot be answered yes** until at least one UK recruitment-agency design partner has expressed pilot intent for Q3 2026 with a signed LOI or equivalent written commitment. None exists.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:43:- **Primitive 1 (Persistent PTY via PM2):** functional per Day-1 audit `docs/architecture/cortexos-primitive-status.md` — "shipped but flaky" per master brief §12 Risk #1. Day-1 audit found the substrate is operational for development workloads. Quirks 2-3 + 2026-04-22 restart-storm evidence document occasional instability under load, not broken.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:49:**YES because operationally sufficient for the v1.0 6-agent build window** that Week 1+ will exercise. Caveat documented above.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:90:| 1 | Design partner pilot Q3 2026 LOI? | **NO** | High — zero pipeline; Risk #3 High; Trigger 1 fires 2026-06-03 |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:113:2. **`.codex/ratification/*.md` skills** — master brief §10.2 Day-1 task deferred during Days 0-6; surfaced as gap during Day-7 grounding. Build during extension period. 7 skill files (SKILL.md + 6 review-{type}.md per master brief §10.2). Estimated 2-3 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:147:- Today: 2026-05-20.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:148:- Trigger 1 (kill criterion DESIGN-PARTNER-BY-WEEK-2 PAUSE): fires end-of-day **2026-06-03** if no signed LOI.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:155:[Founder reflection to be written manually — not a Claude Code output. Section reserved for Maddox to write directly: why Q1 is NO, what the plan is, whether the plan is realistic, what changes in week-of-extension execution vs. what was assumed in Days 0-6.]
docs/decisions/ADR-004-renderer-implementation-deviations.md:3:**Date:** 2026-05-20 (Week 0, Day 8 — Phase-2/3 follow-up)
docs/decisions/ADR-004-renderer-implementation-deviations.md:14:ADR-003 ratified the renderer design on 2026-05-16 (Day 1 evening). Phase 2 of the Week-1 product-code slice (commit `3c16d35`) implemented the renderer per ADR-003 §3.1 — TypeScript Node, `tsup` + `vitest` + `commander`, 12-row file map, atomic-write protocol. Phase 3 (commit `e6e9df1`) implemented `agents/_shared/hook-helpers.sh` and triggered an end-to-end integration test against the rendered output.
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:3:**Status:** Counter-argument accepted (founder-authorized 2026-06-02; not removing the internal stub).
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:4:**Date:** 2026-06-02.
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:6:**Codex sessions:** R3 `20260602T105413Z-29512` issue #1 (initial); R4 `20260602T111820Z-43583` issue #1 (reaffirmed under stricter interpretation).
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:10:> Connector still violates the single-upstream-provider contract. `README.md` lines 3, 15, and 222 describe a TrueLayer + Plaid UK abstraction, while `src/types.ts` line 9 exposes `provider: "truelayer" | "plaid_uk"` and `src/client.ts` lines 47-82 carry Plaid routing/stub logic. This fails `review-mcp-connector`'s single-provider premise and top-level §3 "No defensive additions" because Plaid scaffolding has no v1.0 consumer. Remove Plaid from this connector or split it into a future `plaid-uk` connector.
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:23:R4's claim that "README.md lines 3, 15, and 222 describe a TrueLayer + Plaid UK abstraction" is reading the v1.1+-upgrade-path documentation as a v1.0-capability claim. The honest-signal post-R3 is "v1.0 = TrueLayer; v1.1+ adds Plaid"; that's exactly what those lines say.
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:71:This decision-doc + the QB concurrent-throttle disagreement doc + the cluster-F R3 work-justification doc together document the full Codex disagreement set for cluster F. Per founder-authorized hard-stop (2026-06-02 AskUserQuestion), `@ifos/quickbooks` and `@ifos/open-banking` are marked as **Proposed-with-Codex-disagreement-on-file** and will not be re-submitted to Codex for further rounds in this cluster. xero is RATIFIED. Cluster F is closed at this partial-ratification state.
docs/operations/pending-goal-w6-d36-cash-conductor-prep.md:1:# Pending /goal — W6 Day 36 Cash Conductor prep (Option X)
docs/operations/pending-goal-w6-d36-cash-conductor-prep.md:3:**Purpose:** durable record of the Option X /goal text drafted 2026-06-05 morning; founder pastes verbatim into fresh Claude Code session at location 2 (per `handoff-2026-06-05-location-shift.md` Step 3).
docs/operations/pending-goal-w6-d36-cash-conductor-prep.md:7:**Context:** Bullhorn dev creds unobtainable today; pivoted from Phase 1a Bullhorn → Option X Cash Conductor W7-8 prep using Xero + QuickBooks + TrueLayer sandbox creds founder DID populate. See `goal-week-6-execution-plan.md` §2 for full W6 plan; this /goal is a same-day strategic pivot.
docs/operations/pending-goal-w6-d36-cash-conductor-prep.md:20:W6 pivot per Day 36 analysis: Bullhorn dev creds unobtainable today (Phase 1a blocked; bootstrap helper at dd226f4 stays in tree for Week 7+ pilot-cred arrival). Xero + QB + TrueLayer sandbox creds populated in dev-sandbox/_secrets.env (verified 12:11). Pivot to Cash Conductor W7-8 prep early: 3 MCP_LIVE_TESTS=1 blocks + 3 OAuth bootstrap helpers + ≥3 live capability tests per package. Tree clean at HEAD f1e8e91.
docs/operations/pending-goal-w6-d36-cash-conductor-prep.md:24:2. docs/operations/session-retrospective-2026-06-03.md
docs/decisions/ADR-003-agent-bundle-renderer.md:3:**Date:** 2026-05-16 (Week 0, Day 1 evening — Week-1-prerequisite pull-forward)
docs/decisions/ADR-003-agent-bundle-renderer.md:4:**Author:** Claude Code, founder decision logged 2026-05-16
docs/decisions/ADR-003-agent-bundle-renderer.md:7:**Status:** Accepted. Founder decision logged 2026-05-16.
docs/decisions/ADR-003-agent-bundle-renderer.md:68:**Errata 2026-05-20 (ADR-004):** Edit B's CLI command text was revised post-ADR-004 from `cortextos-ifos render-agent` to `ifos-render-agent`. The proposed text block below reflects the corrected name. See ADR-004 §"Master brief edits authorised" Edit D for the full disposition.
docs/decisions/ADR-003-agent-bundle-renderer.md:139:Joins the deferred atomic correction commit (parallel to ADR-002 Edit 1 + Edit 2). Codex ratifies the combined commit on Day 7 per master brief §10.6.
docs/decisions/ADR-003-agent-bundle-renderer.md:161:**Accepted.** Founder decision logged 2026-05-16. Next steps:
agents/recruitment/scribe/cycle.sh:2:# Scribe agent — cycle.sh (10-step per-call orchestration; W6 build slice LIVE)
agents/recruitment/scribe/cycle.sh:4:# Status: built (W6 build slice; the W5 Day-32 skeleton TODO(W6-7) markers are
agents/recruitment/scribe/cycle.sh:5:#         replaced with live implementation per spec-002-scribe.md §4 + §5 and
agents/recruitment/scribe/cycle.sh:8:#         structured-field writes + tacit-note vault + Bullhorn note attach) +
agents/recruitment/scribe/cycle.sh:26:#                       agent.md §2 "ifosctl scribe replay --call-id <id>"
agents/recruitment/scribe/cycle.sh:38:#   5  field extraction (≥3 ≥0.6)          fields_extracted          ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
agents/recruitment/scribe/cycle.sh:39:#   6  tacit-note → vault (0600)           tacit_note_rendered       ESC_VOICE_DRIFT (via Gate A)
agents/recruitment/scribe/cycle.sh:41:#   8  Bullhorn field write (yellow)       bullhorn_scribe_field_write  ESC_BULLHORN_WRITE_FAIL
agents/recruitment/scribe/cycle.sh:43:#   10 session close + SLA                 scribe_run_complete       ESC_SCRIBE_SLA_MISS
agents/recruitment/scribe/cycle.sh:54:#   1. ≥3 Bullhorn structured-field writes (yellow bullhorn_scribe_field_write;
agents/recruitment/scribe/cycle.sh:66:  printf 'scribe/cycle.sh: CTX_AGENT_DIR unset\n' >&2
agents/recruitment/scribe/cycle.sh:70:  printf 'scribe/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
agents/recruitment/scribe/cycle.sh:73:: "${CTX_AGENT_NAME:=scribe}"
agents/recruitment/scribe/cycle.sh:97:[[ -d "${_BIN}" ]] || _BIN="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/bin"
agents/recruitment/scribe/cycle.sh:168:hh_decision_trigger "session_start" "scribe mode=${MODE} call_id=${CALL_ID_ARG:-NA}"
agents/recruitment/scribe/cycle.sh:194:    autosend_escalate "ESC_INPUT_VALIDATION_FAIL" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:258:  autosend_escalate "ESC_BULLHORN_AUTH" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:282:  vault_dir_phys="${VAULT_PHYS_ROOT}/${CTX_TENANT_SLUG}/scribe-notes"
agents/recruitment/scribe/cycle.sh:284:  vault_path_logical="/vault/${CTX_TENANT_SLUG}/scribe-notes/${call_id}-${today}.md"
agents/recruitment/scribe/cycle.sh:285:  tmp_tx="/tmp/scribe-${CTX_TENANT_SLUG}-${call_id}.txt"
agents/recruitment/scribe/cycle.sh:329:        autosend_escalate "ESC_PROVIDER_FETCH_FAIL" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:346:    autosend_escalate "ESC_PROVIDER_FETCH_FAIL" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:388:    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:391:      "ESC_AGENT_OUTPUT_SHAPE; agent_name:scribe; step:4; participants:${ext_emails:-none}" || true
agents/recruitment/scribe/cycle.sh:400:  # ── Step 5 — Field extraction (≥3 fields ≥0.6 per Gate A) ─────────────
agents/recruitment/scribe/cycle.sh:408:  n_above="$(jq '[.[] | select(.confidence >= 0.6)] | length' "${fields_file}" 2>/dev/null || echo 0)"
agents/recruitment/scribe/cycle.sh:412:    autosend_escalate "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:415:      "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE; agent_name:scribe; step:5; fields:${n_above}" || true
agents/recruitment/scribe/cycle.sh:420:  jq '[.[] | select(.confidence >= 0.6)]' "${fields_file}" > "${fields_file}.f" && mv "${fields_file}.f" "${fields_file}"
agents/recruitment/scribe/cycle.sh:452:  if ! bash "${_BIN}/render-tacit-note.sh" "${render_args[@]}" > "${note_file_phys}.tmp" 2>/dev/null; then
agents/recruitment/scribe/cycle.sh:454:    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:455:      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "reason=tacit_note_render_failed"
agents/recruitment/scribe/cycle.sh:465:  hh_decision_output "tacit_note_rendered" "${vault_path_logical}" \
agents/recruitment/scribe/cycle.sh:474:    autosend_escalate "ESC_SCHEMA_VIOLATION" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:477:      "ESC_SCHEMA_VIOLATION; agent_name:scribe; step:7; valid:${valid_count}; dropped:${dropped_count}" || true
agents/recruitment/scribe/cycle.sh:493:       tacit_note: { vault_path: $vp, body_sha256: $sha, voice_score: $vs,
agents/recruitment/scribe/cycle.sh:499:  [[ -f "${_validate}" ]] || _validate="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/validate.sh"
agents/recruitment/scribe/cycle.sh:548:      autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:572:         autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:582:  hh_decision_action "bullhorn_scribe_field_write" "${entity_type}:${bullhorn_id}" "${payload_hash}" \
agents/recruitment/scribe/cycle.sh:594:VALUES (:'tenant', 'scribe', 'bullhorn_scribe_field_write', :'et', :'eid', :'fm', 'deferred', now());
agents/recruitment/scribe/cycle.sh:603:      --body-file "${note_file_phys}" --title "Scribe tacit notes — ${call_id}" >/dev/null 2>&1 || _nrc=$?
agents/recruitment/scribe/cycle.sh:639:      autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:657:    autosend_escalate "${esc_code}" "agent=scribe" \
agents/recruitment/scribe/cycle.sh:692:hh_decision_action "scribe_run_complete" "call:${LAST_CALL_ID}" "${_run_hash}" \
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:3:**Date:** 2026-05-25 (Day 20)
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:5:**Codex round:** R16 (`logs/codex-ratification/20260524T130117Z-63874/`)
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:36:- ADR-006 — Diagnostic Gate A hybrid (Accepted Day 19, Cat-1/Cat-ζ structural close)
agents/recruitment/scribe/validate.sh:2:# Scribe agent — validate.sh (Gate A enforcement; W6 build slice LIVE)
agents/recruitment/scribe/validate.sh:4:# Status: built (W6 build slice; the W5 Day-32 skeleton TODO(W6-7) markers are
agents/recruitment/scribe/validate.sh:5:#         replaced with live checks per spec-002-scribe.md §5 + agent.md §5).
agents/recruitment/scribe/validate.sh:29:#           "tacit_note": {
agents/recruitment/scribe/validate.sh:30:#             "vault_path": "/vault/<tenant>/scribe-notes/<call_id>-<ISO>.md",
agents/recruitment/scribe/validate.sh:48:#   G2 — field-count: ≥3 extractions ≥0.6 confidence        ESC_FIELD_EXTRACTION_LOW_CONFIDENCE  hard
agents/recruitment/scribe/validate.sh:49:#   G3 — tacit-voice: classifier ≥0.75                      ESC_VOICE_DRIFT  hard (warn-when-unscored)
agents/recruitment/scribe/validate.sh:54:#   G8 — word-cap: tacit-note ≤800 words (agent.md §3)      ESC_AGENT_OUTPUT_SHAPE  hard
agents/recruitment/scribe/validate.sh:63:  printf 'scribe/validate.sh: usage: validate.sh <extraction_proposal_json>\n' >&2
agents/recruitment/scribe/validate.sh:107:[[ -d "${_BIN}" ]] || _BIN="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/bin"
agents/recruitment/scribe/validate.sh:128:# Thresholds (per ULTRAPLAN A3 line 524 + agent.md §3)
agents/recruitment/scribe/validate.sh:129:readonly FIELD_CONFIDENCE_THRESHOLD="0.6"
agents/recruitment/scribe/validate.sh:155:# G2 — ≥3 structured-field extractions with confidence ≥0.6
agents/recruitment/scribe/validate.sh:156:# Per ULTRAPLAN A3 line 524 verbatim.
agents/recruitment/scribe/validate.sh:176:_voice="$(jq -r '.tacit_note.voice_score // "missing"' "${PROPOSAL}")"
agents/recruitment/scribe/validate.sh:177:_vreason="$(jq -r '.tacit_note.voice_reason // ""' "${PROPOSAL}")"
agents/recruitment/scribe/validate.sh:180:    _ok "G3: tacit-note voice score ${_voice} ≥ ${VOICE_SCORE_THRESHOLD}"
agents/recruitment/scribe/validate.sh:182:    _fail "G3: tacit-note voice score ${_voice} < ${VOICE_SCORE_THRESHOLD} (after retries) — note NOT attached; vault draft held for consultant review"
agents/recruitment/scribe/validate.sh:195:_FIELDS_TMP="$(mktemp -t scribe-gate-fields-XXXXXX)"
agents/recruitment/scribe/validate.sh:225:# G6 — No PII outside firm boundary in the tacit-note narrative (regex pass
agents/recruitment/scribe/validate.sh:230:_preview="$(jq -r '.tacit_note.narrative_body_preview // ""' "${PROPOSAL}")"
agents/recruitment/scribe/validate.sh:250:  _fail "G6: PII outside firm boundary detected in tacit-note narrative — write blocked; vault draft held for review"
agents/recruitment/scribe/validate.sh:269:WHERE tenant_slug = :'tenant' AND agent_name = 'scribe'
agents/recruitment/scribe/validate.sh:292:_words="$(jq -r '.tacit_note.narrative_word_count // 0' "${PROPOSAL}")"
agents/recruitment/scribe/validate.sh:294:  _ok "G8: tacit-note word count ${_words} ≤ ${TACIT_NOTE_WORD_CAP}"
agents/recruitment/scribe/validate.sh:296:  _fail "G8: tacit-note word count ${_words} exceeds ${TACIT_NOTE_WORD_CAP} cap"
agents/recruitment/scribe/validate.sh:304:printf '\nScribe validate Gate A: '
agents/recruitment/scribe/validate.sh:311:  autosend_escalate "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}" "agent=scribe" \
agents/recruitment/scribe/validate.sh:317:    "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}; agent_name:scribe; call:${CALL_ID}; failures:${#FAILURES[@]}; first:${FAILURES[0]}" || true
docs/decisions/bullhorn-integration-path.md:3:**Date:** 2026-05-16 evening / 2026-05-17 (Week 0, Day 2)
docs/decisions/bullhorn-integration-path.md:4:**Status:** **Sub-decision A RESOLVED 2026-06-02** — marketplace partner programme deferred to v1.1+; direct API per-tenant OAuth is the v1.0 path. Sub-decision C remains Accepted technically. Sub-decision B in flight with Bullhorn developer-support team via the `developer.bullhorn.com` route (founder submitted 2026-06-02).
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:68:| A | "Is Intel Force Ltd in the Bullhorn Marketplace Partner Programme, or what's the application timeline + first-year cost?" | **RESOLVED 2026-06-02 without partnerships-team conversation.** The partner form at `https://www.bullhorn.com/become-a-partner/` (re-verified live 2026-06-02 via WebFetch) requires "ideally 2 Bullhorn customers" — a soft gate signalling marketplace is for established players. IFOS is pre-pilot (0 live customers + 1 LOI in active negotiation with Jack's agency). Decision: marketplace deferred to v1.1+ at 3+ live pilots; v1.0 uses direct API per-tenant OAuth. Founder pivoted 2026-06-02 to Bullhorn developer-support route at `developer.bullhorn.com` for the technical question (Sub-decision B) which has no customer-count gate. Earlier draft cited `partnerships@bullhorn.com` which does NOT exist (mail bounced; verified 2026-05-23). | n/a — closed without engagement | Cost analysis: marketplace ~$5-25k/yr partner fees + certification overhead + security review burden + listing maintenance (inferred from comparable enterprise SaaS marketplaces; Bullhorn's exact fee not public). Not justified at ≤3-pilot scale where founder-led direct sales doesn't need marketplace distribution. Revisit at v1.1+. |
docs/decisions/bullhorn-integration-path.md:84:- **Sunday (2026-05-17):**
docs/decisions/bullhorn-integration-path.md:86:  - Founder runs Bullhorn partnerships outreach — submission via Marketo form at `https://www.bullhorn.com/become-a-partner/` (verified 2026-05-23; the earlier `partnerships@bullhorn.com` draft was wrong — that mailbox does not exist). Result may not come back same-day.
docs/decisions/bullhorn-integration-path.md:87:- **Monday (2026-05-18):**
docs/decisions/bullhorn-integration-path.md:93:  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.
docs/decisions/bullhorn-integration-path.md:113:Bullhorn's public surfaces for the partner programme are deliberately thin. Three URLs surveyed Day 2 (2026-05-16 evening):
docs/decisions/bullhorn-integration-path.md:117:- `https://www.bullhorn.com/marketplace/partners/` — returns HTTP 404 (verified 2026-05-16).
docs/decisions/bullhorn-integration-path.md:134:**Source citation for this section:** the three URLs above, all accessed 2026-05-16.
docs/decisions/bullhorn-integration-path.md:169:| Cost at 3-tenant pilot scale (2026 H2, Boutique tier per Product Spec §3.1) | **CG.** Public docs do not name partner fees. Inference based on comparable enterprise SaaS marketplace programmes: annual partner fee typically $5K-$25K + possibly per-listing or per-referral revenue-share. | **CG.** Public docs do not name developer-program fees. Inference: likely zero or nominal for the developer-tier API access. Per-tenant cost zero — the tenant pays Bullhorn, IFOS pays nothing per call. |
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
docs/architecture/second-brain-design.md:3:**Date:** 2026-05-16 (Week 0, Day 1)
docs/architecture/second-brain-design.md:204:| `wiki/raw/calls/` | one file per call | markdown with frontmatter | `{epoch}-{call-id}.md` | Scribe (v1.0) on Fathom/Fireflies webhook | Brief Decoder (v1.1), Concierge (v1.0) |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:254:created_at: 2026-05-16T14:32:00Z                     # required; ISO 8601 UTC
docs/architecture/second-brain-design.md:255:updated_at: 2026-05-16T14:32:00Z                     # required; ISO 8601 UTC
docs/architecture/second-brain-design.md:257:  - scribe-agent:call-2026-05-16-1432
docs/architecture/second-brain-design.md:258:  - janitor:bullhorn-2026-05-15
docs/architecture/second-brain-design.md:274:{Janitor or Scribe one-paragraph summary, regenerated on each ingest}
docs/architecture/second-brain-design.md:277:{auto-appended by Concierge / Scribe — chronological, agent-attributed}
docs/architecture/second-brain-design.md:309:  - "[[Placement: Senior PM 2026-Q3]]"
docs/architecture/second-brain-design.md:323:id: brief_aragon_senior_pm_2026q3
docs/architecture/second-brain-design.md:345:id: placement_sarah_bowen_aragon_2026q3
docs/architecture/second-brain-design.md:348:display_name: "Sarah Bowen → Aragon Labs (Senior PM 2026-Q3)"
docs/architecture/second-brain-design.md:355:placed_at: 2026-09-01                                # required; ISO date
docs/architecture/second-brain-design.md:356:start_date: 2026-10-01                               # required; ISO date
docs/architecture/second-brain-design.md:362:invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:408:- `id: brief_aragon_senior_pm_2026q3` → file `wiki/compiled/briefs/aragon_senior_pm_2026q3.md`
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:458:  - **Filesystem:** Restic nightly to S3-compatible UK-region storage, 30 days of dailies + 12 months of monthlies (Ultraplan §5.6 line 281). RPO 5 minutes, RTO 4 hours (Ultraplan §5.6 line 283).
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:757:- `append-to-narrative` — Concierge / Scribe logging; tolerates few-hundred-ms.
docs/architecture/second-brain-design.md:772:| Scribe | 3:1 | reads candidate for context on every call; writes structured fields + tacit notes |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:892:| **Agent ergonomics** — what `tools.yaml` / `agent.md` looks like | `agent.md` references wiki ops as bus commands: `cortextos-ifos bus wiki-search "..."`. No `tools.yaml` entry needed (bus commands are implicit). Pattern is identical to how `bus send-message`, `bus create-task` already work in cortextOS. | `tools.yaml` has a dedicated `mcp_servers.wiki` block + tool list (sketched in §3.1). Adds a section per agent. Aligns with how vertical-adapter MCP connectors work in master brief §3.2. | `agent.md` would have to reference the skill explicitly (e.g. "When you need to query the wiki, invoke `.claude/skills/wiki/SKILL.md`"). Under R2, agents don't have a `.claude/skills/` tree, so the agent.md has to describe a one-off invocation pattern. Awkward. |
docs/architecture/second-brain-design.md:956:- **Scope:** larger than master brief §5.5 currently states (9 ops + 4 Postgres tables + concurrency machinery, vs. the original "2 ts files"). Still fits the 11-13 day budget because the bulk of the surface area is small Postgres operations with thin shell wrappers; the heavy code is in `concurrency.ts` and `update.ts` which together are ~400-600 lines.
docs/architecture/second-brain-design.md:975:| **2.6** | Master brief §5 silent on concurrency | No mechanism for agent×agent, agent×human-in-Obsidian, or rewrite-backlinks cascade | Resolved in §2.6.1, §2.6.2, §2.6.3 of this design. Companion document `docs/architecture/vault-concurrency.md` LANDED (Day 3, commit `78680cc`). New escalation codes (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, `ESC_VAULT_RENAME_RACE`) CATALOGUED at `agents/_shared/escalation-codes.md` §2.2 (Day 8 commit `a279226`) + WIRED into `agents/_shared/hook-helpers.sh::autosend_escalate` (Day 8 commit `e6e9df1`). | **Closed 2026-05-20.** Catalogue + wiring complete; ESC codes callable from any rendered agent. |
docs/operations/handoff-2026-06-05-location-shift.md:1:# Handoff — 2026-06-05 location shift
docs/operations/handoff-2026-06-05-location-shift.md:7:**Active /goal:** none firing; previous W5-W6 marathon /goal auto-cleared after 9 hook retries
docs/operations/handoff-2026-06-05-location-shift.md:11:## What was done this session (W6 Day 36 morning)
docs/operations/handoff-2026-06-05-location-shift.md:17:3. **W6 plan split** (commit `fc459ca`) — Phase 1 → 1a (Bullhorn; blocked) + 1b (Granola; pending workspace meeting + transport implementation).
docs/operations/handoff-2026-06-05-location-shift.md:45:$EDITOR docs/operations/handoff-2026-06-05-location-shift.md      # this file
docs/operations/handoff-2026-06-05-location-shift.md:58:W6 Day 36 resuming after location shift. Tree clean at HEAD f1e8e91. Read docs/operations/handoff-2026-06-05-location-shift.md + docs/operations/pending-goal-w6-d36-cash-conductor-prep.md. Re-verify _secrets.env state (XERO_*/QB_*/TRUELAYER_* should be SET) using awk pattern — NEVER cat (per memory feedback-never-cat-secrets-files). When verified, tell me + I'll paste the /goal as a stop-hook to fire Option X (Cash Conductor W7-8 prep: 3 MCP_LIVE_TESTS=1 blocks + 3 OAuth bootstrap helpers + ≥9 live capability tests).
docs/operations/handoff-2026-06-05-location-shift.md:79:- Don't push WIP to origin if you don't want intermediate state public (alternative: push to a branch like `wip/2026-06-05-handoff` then merge later)
docs/RISK-REGISTER.md:10:| 1 | CortexOS primitives 3 or 4 are flaky in production | High | High | Daily orchestrator health check flags > 1 incident/week | Every Tier-1 agent has a degraded-mode fallback; manual file-bus handoff documented | **Updated Day 1** — primitive 3 (bus) is **shipped and tested**; primitive 4 (approval gates) is **shipped and tested**; only primitive 1 (PTY/PM2) is **shipped but flaky** per quirks 2-3 + 2026-04-22 restart-storm evidence in `cortextos-primitive-status.md`. Risk severity revised down. |
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → ~~Medium~~ → **Low** (Sub-decision A resolved + direct API path clear) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated 2026-06-02:** **Sub-decision A RESOLVED** without partnerships-team engagement — the partner form requires ≥2 live customers (we're pre-pilot at 0 + 1 LOI); marketplace ~$5-25k/yr not justified at ≤3-pilot scale. v1.0 path = **direct API per-tenant OAuth** (per `docs/decisions/bullhorn-integration-path.md` Sub-decision A RESOLVED row, commit `f13cc15`); marketplace deferred to v1.1+ at 3+ live pilots. Sub-decision B (OAuth technical details) in flight via developer-support route at `developer.bullhorn.com` (no customer-count gate; founder submitted 2026-06-02). **Risk severity Medium → Low** because the marketplace-blocker scenario is now off the table; only B (technical OAuth details) outstanding and the answer is low-risk (Bullhorn's OAuth docs already public via `bullhorn.github.io/docs`). **Reduction trigger 1 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes at W5+). Previous Day-13 (2026-05-24) update folded into this row; partnership form initial submission 2026-05-24 superseded by the dev-support pivot. |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:13:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |
docs/RISK-REGISTER.md:15:## Day-1 surfaced risks (new, 2026-05-16)
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:22:| 6 | **Concurrency-document-prerequisite** — without `docs/architecture/vault-concurrency.md`, the wiki/lib/concurrency.ts code can't be reviewed; week-5 first multi-agent test runs against unreviewed concurrency machinery | ~~Medium~~ **Closed** | ~~Medium~~ **Closed** | (closed) | **Closed 2026-05-16 Day 3 evening:** `docs/architecture/vault-concurrency.md` shipped at 455 lines. 4 mechanisms specified with TypeScript worked examples (`flock(2)`, Postgres optimistic concurrency, mtime debounce, rewrite-backlinks cascade). 5 new `ESC_VAULT_*` codes consolidated for `_shared/hook-helpers.sh` Week-1 prereq. Surfaces 1 new Day-4 tightening (`entities.version` column per §3.1). v1.0 atomicity gap honestly documented; v1.2+ WAL pattern deferred. **Source:** Spec gap 2.6 in `second-brain-design.md`. |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:27:## Day-11 surfaced risks (new, 2026-05-22)
docs/RISK-REGISTER.md:35:| 14 | **Scripts authored Days 8+ never executed end-to-end against live until 2026-05-23** — Day-9 cohesion review claimed "foundation is sound for Diagnostic build" based on code+docs review, but no helper / migration / script had been exercised against live Postgres. Day-12 first execution surfaced 6 distinct drifts (password, DB name, TRIGGER grant, GUC rename, missing tenants row, table ownership/RLS-bypass). | High (now historical; mitigated) | High at time of discovery — any of the 6 could have manifested at first pilot LOI as silent failure or data leak. | Future script/migration authoring without an explicit "first live execution against migration-test tenant" milestone listed in the plan. | Day-12 closed loop: live migration 24/24 + tenancy audit 24/24. Future: every new script touching live Postgres must include a verified-on-VPS milestone in its acceptance criteria, not just unit-test-layer green. Day-9 cohesion review template updated to require live verification before "foundation verified" verdict. | **Mitigated.** Discovery surfaces a class lesson: ratification at code-and-docs layer is necessary but not sufficient; live execution is the third leg. |
docs/RISK-REGISTER.md:36:| 13 | **GUC name drift between executed Day-4 reality and Days-8-11 codebase** — Day-4 §6.3 provisioned live RLS policies using `current_setting('app.current_tenant', TRUE)` (verified Day-11 via `\dp entities`), but Days 8-11 code (hook-helpers.sh, voice-loader.sh, run-live-migration.sh, run-tenancy-audit.sh, ifos-pii-purge.sh, v0.1-to-v0.2.sql) + Day-9 ratified docs (tenancy-invariants.md, architecture-cohesion-review.md) wrote `ifos.tenant_slug` instead. Three rounds of Codex ratification + cohesion review didn't catch it because no artefact in Days 8-11 was ever executed end-to-end against live Postgres. Surfaced 2026-05-22 during first live migration attempt (CREATE TRIGGER failed for separate privilege reason; founder ran `\dp entities` while diagnosing; the GUC mismatch was visible in policy output). | ~~High~~ → Low post-remediation | High (every Days-8-11 write to live Postgres would have silently failed RLS or returned 0 rows — silent data leak risk if ever inverted) | Any helper / migration / script execution against live Postgres that uses an RLS-protected table and returns surprising row counts; first end-to-end live execution of any of the 6 affected scripts; future `\dp` audit revealing additional drift. | Day-11 remediation (this commit): mechanical rename `ifos.tenant_slug` → `app.current_tenant` across 15 files; 29/29 helper tests still pass; v0.1-to-v0.2 migration verified to use the corrected GUC. Future: run `bash scripts/run-tenancy-audit.sh` post-migration to verify all 12 invariants against the live database. | **Mitigated in this commit pending live re-run of v0.2 migration + tenancy audit verification.** |
docs/RISK-REGISTER.md:37:| 14 | **Proxycurl shutdown (LinkedIn lawsuit Jan 2025) breaks the Sourcing Scout v1.0 LinkedIn deep-data path** — original v1.0 Sourcing Scout listed 4 sources (Bullhorn + LinkedIn/Proxycurl + Reed + CV-Library). Proxycurl shut down following LinkedIn's January 2025 lawsuit against Nubela (~50% of revenue was LinkedIn scraping; see nubela.co/blog/goodbye-proxycurl/). Successor product NinjaPear (same team) does NOT carry LinkedIn data. No legally-clear LinkedIn-scraping vendor identified as of 2026-06-02. | Materialised 2026-06-02 (vendor gone) | Low → Medium (depends on whether Gate B ≥6 of 10 advance holds without LinkedIn data; unknown until pilot data lands) | Sourcing Scout Gate B underperforms (<6 of 10 advance per ULTRAPLAN A5 line 553) at first-pilot deployment AND analysis attributes gap to missing LinkedIn deep-data. | **v1.0 disposition** (per founder 2026-06-02 + `agents/recruitment/sourcing-scout/agent.md` v1.0 caveat at commit `622a2e7`): defer LinkedIn deep-data to v1.1+; v1.0 Sourcing Scout operates against 3 active sources (Bullhorn passive-match + Reed + CV-Library). v1.1+ vendor selection at W8-9 build-slice decision; candidate vendors named: Lix, Phantombuster, Apify (LinkedIn-aware contracts), or LinkedIn Sales Navigator enterprise API (much higher cost). §4 Step 4 (LinkedIn search) is a NO-OP in v1.0; §3 output template shows LinkedIn row as "deferred to v1.1+; vendor pending". | **Mitigated by deferral; v1.1+ vendor decision queued for W8-9 build slice.** |
docs/RISK-REGISTER.md:47:- Two-instance PATH conflict for bus commands → **Updated 2026-05-16 evening:** folds into the renderer's CLAUDE.md preamble responsibility (ADR-003 design §2.1-A). The preamble draft in design §2.3 sets `CTX_AGENT_DIR` explicitly; rendered hook scripts source `_shared/` helpers via `${CTX_AGENT_DIR}/.claude/hooks/_shared/` rather than relying on `PATH` resolution. Quirk 3 is no longer a Week-1 risk — it's a renderer test case.
docs/RISK-REGISTER.md:56:- 2026-05-22 (Day 11) — **Codex Round 2 autonomous ratification complete.** 26 artefacts reviewed; 17 RATIFIED / 9 REJECTED. Manifest §1.7 appended and full outputs written to `logs/codex-ratification/round-2-autonomous/`. D5 skill softening ratified. Bullhorn gate disagreement rejected because the promised source-doc sharpening did not land. Autosend policy, v0.2 supplement, approval bridge, PII purge runbook/script/forward migration, and tenancy audit script remain rejected. **New Risk #11** added for transactionless `SET LOCAL` usage across live DB scripts/helpers. **New Risk #12** added for the PII purge migration/script mismatch with `recent_edit.original_text NOT NULL`.
docs/RISK-REGISTER.md:57:- 2026-05-22 (Day 11 evening) — **Codex Round-2 remediation applied + Round 3 verified.** Fixes wrap all identified `SET LOCAL` calls in explicit transactions and make `recent_edit.original_text` nullable before PII purge; Risks #11 and #12 moved to mitigated. Founder-domain D1/D2/D3 remain open and are explicitly annotated in the affected artefacts.
docs/RISK-REGISTER.md:58:- 2026-05-16 (Day 0) — Initial register established. Four top risks identified, all active. Three Day-0 runtime risks surfaced and resolved.
docs/RISK-REGISTER.md:59:- 2026-05-16 (Day 1) — Risk #1 severity revised down (primitives 3 + 4 confirmed shipped and tested per `cortextos-primitive-status.md`; only primitive 1 carries Day-0 brittleness). Three new risks added (#5 renderer-not-built, #6 concurrency-doc-prereq, #7 master-brief-drift-accumulation) from Day-1 audit + design work.
docs/RISK-REGISTER.md:60:- 2026-05-16 (Day 1 evening extension) — Risk #5 severity revised from **Blocking** to **High** (ADR-003 + design doc Accepted; staged reductions to Medium and Low named). Risk #7 edit count revised from 3 to 5 (ADR-003 Edit C added). Day-0 quirk 3 (PATH conflict) updated: no longer a Week-1 risk — folds into renderer preamble responsibility per ADR-003 design §2.3. No new risks surfaced from renderer design work.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 2) — Risk #2 status entry updated: Sub-decision C **Accepted** per `bullhorn-integration-path.md` §4 + §5; Sub-decisions A and B **Proposed** with named reduction triggers (Sunday/Monday commercial conversations). Two staged severity reductions specified (High → Medium on commercial answers; Medium → Low on first Week 3-4 Bullhorn write landing clean). Risk #7 edit count revised from 5 to 6 (Bullhorn decision §6.6 sixth edit added — master brief §6 Day 2 line 466 `service-account for dev` correction). No new risks surfaced from Day 2 — Sub-decisions A and B Proposed is the intended honest state pending commercial verification, not a new risk surface.
docs/RISK-REGISTER.md:62:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:63:- 2026-05-16 (Day 3 evening) — **Risk #6 closed.** `docs/architecture/vault-concurrency.md` shipped (455 lines, reference document). 4 mechanisms specified with worked examples; 5 new `ESC_VAULT_*` codes consolidated for `_shared/hook-helpers.sh` Week-1 prereq wiring (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_VERSION_MISMATCH`, `ESC_VAULT_HUMAN_EDIT_BLOCKED`, `ESC_VAULT_CASCADE_PARTIAL_FAILURE`, `ESC_VAULT_CASCADE_TIMEOUT`). Risk #7 edit count unchanged at 8 — `vault-concurrency.md` is reference synthesis, surfaces no new master-brief drifts. Surfaces one new Day-4 tightening (`entities.version` column per §3.1) — Day 4 now has 4 consolidated tightenings.
docs/RISK-REGISTER.md:64:- 2026-05-17 (Day 4) — **Day 4 provisioning executed end-to-end against Hetzner Cloud NBG1 VPS (178.105.87.24).** All 9 runbook sections complete; §7 RLS isolation gate passed all 5 conditions (cross-tenant data access structurally impossible for `ifos_app` regardless of application bugs); 22 of 22 §9 automated checks passed. **Risk #7 edit count revised from 8 to 9** with new Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations"). **One new risk added (#8 LUKS manual unlock single-point-of-failure)** — Low probability, Medium-High impact, v1.2+ TPM/key-server mitigation path named. Two non-blocking operational items deferred to founder convenience: (a) Hetzner Console snapshot of `ifos-v2-prod-01`; (b) ifos_app password retrieval from `/vault/.ifos_app_password.tmp` → 1Password → temp file delete; (c) **high-priority** LUKS new-passphrase retrieval from `/root/.new_luks_passphrase.tmp` → 1Password → temp file delete (must be done before next reboot — old leaked passphrase already invalidated by Day-4 §11 rotation). Path B protocol gap (LUKS passphrase entered chat for `ifos-unlock` end-to-end test) closed via `cryptsetup luksChangeKey` rotation: OLD (leaked) rejected by `--test-passphrase`, NEW accepted; leaked passphrase in chat transcript is cryptographically invalid. v1.1 runbook revisions catalogued (8 items) for collection during Days 5-7. Codex Day-7 queue grows from 13 to 15 (Day 4 runbook + executed version).
docs/RISK-REGISTER.md:65:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:66:- 2026-05-20 (Day 9 evening) — **Architecture + tenancy verification slice complete.** 3 commits (`5c3fa66` + `c4348aa` + this commit). 4 new artefacts: tenancy-invariants.md (Reference; 12 invariants T1-T12 single source of truth), run-tenancy-audit.sh (multi-tenant adversarial smoke), architecture-cohesion-review.md (8-artefact cohesion + 14 remediation items + 4-boundary adversarial walk), tenant-lifecycle.md (Provision/Operate/Suspend/Offboard/Migrate). All 4 master-brief §3 boundaries verified HOLD at current artefact set. 3 of 5 contradictions in the ratified artefact set RESOLVED via ADR-004 + Day-8 remediation; 1 RESOLVED via consolidation in tenancy-invariants.md; 1 OPEN pending Founder Decision D3 (PII retention). 8 implicit assumptions documented; 3 catastrophic-if-false verified empirically. No new risks added — cohesion review's 14 remediation items + lifecycle's 8 gaps are all variance bounded by existing risks (#5 renderer + #10 PII + others) or low-severity lazy specs. Foundation deemed sound for Diagnostic build conditional on founder-decision bundle (D1+D2+D3) + Codex Round 2 closure + live tenancy audit pass.
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8 evening) — **Codex ratification Round 1 complete + remediation landed.** 16 artefacts reviewed (Cluster A+B+C); 2 RATIFIED (ADR-004, brain-ui-scope); 14 REJECTED. Remediation commit `2b287d3` incorporates 13 of 14 rejections (Bucket 1 cosmetic + Bucket 2 ADR-004 back-propagation + Bucket 3 structural). 2 disagreement docs filed (`codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` + `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`). 5 founder decisions surfaced (D1-D5 in `2026-05-20-codex-round-1-founder-decisions.md`). **NEW Risk #10 candidate surfaced by Codex** (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation) — see Risk #10 below. Manifest queue updated with per-artefact Round-1 verdicts (`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5). Round 2 expected to take 14 REJECTED → 0-2 REJECTED.
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/RISK-REGISTER.md:69:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/RISK-REGISTER.md:70:- 2026-06-03 (W5 Day 34) — **W5 CLOSED.** All 5 v1.0 agent bundles (CC + Concierge + Janitor + Scribe + Sourcing Scout) at SKELETON tier (6 files + 3 fixtures each); 3 new MCP scaffolds (@ifos/bullhorn + @ifos/workos + @ifos/granola); v0.4 schema supplement LIVE on production VPS (peer-auth migration apply 2026-06-03; 6/6 trigger acceptance tests passed). No new risks materialised from W5. **Risk #3 update:** founder confirmed Jack lane "on track" 2026-06-03; Trigger 1 fires today (calendar gate), founder closes LOI directly — Risk #3 status unchanged at HIGH/MATERIALISED pending actual signature. **Pre-existing test flake surfaced (NOT a new risk):** `@ifos/diagnostic-generator` `tests/generate.test.ts` § "composes a §12 conversation opener that anchors to a real signal" failing since 2026-06-01 commit `2688b6a` — LLM non-determinism (test fixture "Test Anchor Firm" triggers legitimate disclaimer pattern from the LLM; test regex `/Hi.*?Test Anchor Firm|Hi —/` doesn't match). Doesn't affect production behaviour (production uses real firm names with real Companies House data). Three fix paths queued for a future session (relax regex / mock LLM / use real firm name); deferred per Karpathy surgical-changes discipline + /goal STOP rule (out of W5 marathon scope). **W6+ external dependencies:** Bullhorn dev-support reply (~by 2026-06-09); Reed + CV-Library + Xero + QB + TrueLayer commercial signups per `docs/operations/founder-api-signups-2026-06-03.md`; Granola browser OAuth dance (requires Claude Code restart); WorkOS staging key; Cluster F-tris Codex ratification (manifest entry added). vitest at W5 close: 259/260 (99.6%) across 11 packages.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:1:# /goal — W4 Day-26 afternoon: bundle completion + bridge + polish (2026-06-01)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:3:**Window:** ~6h (14:30 → 20:30 local). Continuation of morning goal `goal-w4-day-26-2026-06-01.md` (Phases 1+2+3 closed at commit `5d15130`). Phase A bundle (~3h) → Phase B bridge (~2.5h) → Phase C polish (~0.5h).
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:6:Morning goal + this goal's §1 · `agents/recruitment/cash-conductor/agent.md` §3+§4+§5 (consumer spec) · `packages/mcp-connectors/{xero,quickbooks,open-banking}/` (pattern) · `docs/decisions/2026-05-31-d1-founder-decision.md` §"Implementation surface" (bridge contract) · `agents/_shared/{hook-helpers.sh,autosend-policy.yaml}` (existing helpers + action_type registry) · `agents/recruitment/diagnostic/{context,cleanup}.sh` (sibling pattern for Phase A files).
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:13:    --surface-sunk:   oklch(0.965 0.006 80);
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:15:    --hairline:       oklch(0.915 0.006 80);
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:20:    --ink-3: oklch(0.60 0.010 80);   /* tertiary / meta */
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:27:    --ok:        oklch(0.60 0.10 150);
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:29:    --warn:      oklch(0.65 0.10 80);
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:356:    margin: 0 0 6px;
docs/operations/bullhorn-outreach-emails.md:4:**Date:** 2026-05-23 (Day 12)
docs/operations/bullhorn-outreach-emails.md:25:**There is NO `partnerships@bullhorn.com` inbox.** Tested 2026-05-23 — bounced. The verified correct path:
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/bullhorn-outreach-emails.md:52:> If marketplace membership is required (or recommended), what is the annual partner fee at our expected 3-6 pilot tenant volume in 2026 H2? Is there a one-time certification fee, security review, or other upfront cost? What is the typical application-to-listing timeline?
docs/operations/bullhorn-outreach-emails.md:70:**Expected response time:** 2-5 business days. If no response by Wednesday 2026-05-28: nudge with a one-line follow-up referencing the original message.
docs/operations/bullhorn-outreach-emails.md:75:- If they offer a Bullhorn Developer Program intermediate tier → that's likely the right path for 2026 H2 pilots; defer marketplace to v1.1+.
docs/operations/bullhorn-outreach-emails.md:76:- Save the response to: `docs/operations/bullhorn-partnerships-response-2026-05-XX.md` (date the day it arrives) so we have audit trail.
docs/operations/bullhorn-outreach-emails.md:102:> What is the documented refresh-token TTL? When a refresh_token is exchanged for a new access_token, does the refresh_token itself rotate (single-use) or remain valid (long-lived)? Our connector polls Bullhorn every 5 minutes per pilot tenant — we need to plan for graceful refresh-token renewal under that cadence.
docs/operations/bullhorn-outreach-emails.md:114:> Public REST docs reference HTTP 429 + "wait 1 second" but don't name caps. At 3-6 pilot tenants polling every 5 minutes (peak ~72 calls/minute aggregate), are we comfortably within rate-limit budget, or do we need to negotiate elevated limits?
docs/operations/bullhorn-outreach-emails.md:117:> Public REST docs describe pull-only model. Is there an undocumented webhook or event-subscription mechanism available to integration partners? If not, we'll proceed with the polling model (already designed); if yes, we'd prefer to subscribe to placement-state-change events directly.
docs/operations/bullhorn-outreach-emails.md:131:- Save response to `docs/operations/bullhorn-developer-response-2026-05-XX.md`.
docs/operations/bullhorn-outreach-emails.md:141:2. **Tell Claude:** "Bullhorn partnerships responded — saved at `docs/operations/bullhorn-partnerships-response-2026-05-XX.md`"
docs/operations/bullhorn-outreach-emails.md:150:1. **Wednesday 2026-05-28** — one-line nudge ("just bumping this — any update?")
docs/operations/bullhorn-outreach-emails.md:151:2. **Monday 2026-06-01** — second nudge with explicit deadline reference ("we're targeting Janitor build W5; need clarity by then")
docs/operations/bullhorn-outreach-emails.md:152:3. **Wednesday 2026-06-03** — LinkedIn outreach to a named Bullhorn employee in partnerships or developer relations. Search "Bullhorn partnerships" or "Bullhorn developer advocacy" on LinkedIn; aim for a UK-based person if available.
docs/operations/bullhorn-outreach-emails.md:154:**Hard cutoff:** if no response by 2026-06-10 (3.5 weeks from today), Sub-decision A is forced to **Direct API** (lowest-friction path; commercial verification deferred to post-pilot) and the connector scaffolds against that — per the §2.3 §1.4 fallback architecture in `bullhorn-integration-path.md` which was designed for exactly this scenario.
agents/recruitment/sourcing-scout/fixtures/99-dnc-bulk-filter.yaml:72:    - { ref: "bullhorn:1006", name: "Frank Fisher", email: "frank.f@example.test", phone: "+447700900006" }     # DNC: name
docs/operations/goal-week-5-execution-plan.md:3:**Status:** Active (start Day 28; 7-day execution window through end-of-Week-5 ~2026-06-09).
docs/operations/goal-week-5-execution-plan.md:5:**Authored:** 2026-06-02 (W4 close evening).
docs/operations/goal-week-5-execution-plan.md:6:**Master plan citations:** Master brief §8.2 line 596 (Janitor = W5; key dependency Bullhorn MCP R+W) + ULTRAPLAN §8.1 A2 (Janitor spec) + master brief §5.3 line 401 (WorkOS AuthKit is the v1.0 auth substrate; "don't add a second auth system") + ADR-005 (W3 Diagnostic acceleration → builds non-Bullhorn first when Bullhorn is slow) + `docs/decisions/bullhorn-integration-path.md` Sub-decision A RESOLVED 2026-06-02 (direct API per-tenant OAuth = v1.0 path; marketplace deferred to v1.1+).
docs/operations/goal-week-5-execution-plan.md:7:**Strategic premise:** Bullhorn commercial gate is slow. Build everything that DOESN'T need a live Bullhorn account first; live integration tests gated on Bullhorn dev-support reply land later when the reply arrives (~2026-06-09 per founder dev-support submission 2026-06-02).
docs/operations/goal-week-5-execution-plan.md:9:**Maps to:** Day-28 (2026-06-03) → Day-34 (2026-06-09). 7-day window.
docs/operations/goal-week-5-execution-plan.md:10:**Builds on:** `docs/operations/goal-week-3-polish-and-scaffold.md` (5 agent.md scaffolds + Diagnostic polish) + `docs/operations/goal-w4-day-26-2026-06-01.md` + W4 polish goal (commits `f13cc15` → `e0d4520`).
docs/operations/goal-week-5-execution-plan.md:21:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A2 (Janitor; lines 507-514) + A3 (Scribe; lines 518-527) + A5 (Sourcing Scout; lines 547-558) + §9 (Bullhorn critical path)
docs/operations/goal-week-5-execution-plan.md:25:8. **`docs/decisions/bullhorn-integration-path.md`** in full (Sub-decision A RESOLVED 2026-06-02 row at top; §4 per-agent Bullhorn surface; §1.4 fallback architecture)
docs/operations/goal-week-5-execution-plan.md:26:9. **`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md`** (cluster Fbis + G partial-ratification framework — Janitor + Scribe + Sourcing Scout bundles will land at the same partial-ratification shape; no expectation of Codex round-N clean ratification at the bundle layer)
docs/operations/goal-week-5-execution-plan.md:29:12. **`agents/recruitment/janitor/agent.md`** + **`agents/recruitment/scribe/agent.md`** + **`agents/recruitment/sourcing-scout/agent.md`** (contract-layer specs that the W5 bundles implement against — all RATIFIED at cluster E 2026-05-31)
docs/operations/goal-week-5-execution-plan.md:35:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Janitor build dependency per master brief §8.2 line 596: Bullhorn MCP (R+W). ULTRAPLAN A2 build complexity: L (2 weeks; 1 week MCP + 1 week agent). Bullhorn Sub-decision A status: RESOLVED 2026-06-02 (direct API per-tenant OAuth = v1.0). WorkOS AuthKit per master brief §5.3 line 401 is the v1.0 auth substrate. Ready to begin Phase 1."**
docs/operations/goal-week-5-execution-plan.md:47:3. **`packages/mcp-connectors/granola/`** SKELETON shipped (vendor pivoted Fathom/Fireflies → Granola per founder 2026-06-03; sits in the background during calls without an extra meeting attendee + has an official MCP server at `mcp.granola.ai/mcp`). Wraps the 6 official Granola MCP tools (`list_meetings` + `get_meetings` + `query_granola_meetings` all-plans + `list_meeting_folders` + `get_meeting_transcript` Paid-only + `get_account_info` all-plans) with IFOS rate-limit, plan-tier guard, OAuth 2.1 PKCE token persistence, typed errors. Plan tiers per Granola docs are `free` | `paid` (not `basic|business|enterprise`); founder confirmed Business+/Paid 2026-06-03 so Paid-only tools unlocked-by-default. Status: Proposed.
docs/operations/goal-week-5-execution-plan.md:51:4. **`docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml`** + **`docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql`** drafted. Adds the following keys to `tenant_adapters.config` allowlist (validator trigger extended): `operator_telegram_chat_id` (D1-B per Concierge cycle.sh Step 11), `email_channel` (Concierge per-tenant MS Graph vs Gmail selection), `workos_org_id` (tenant SSO org ID per master brief §5.3 line 401), `granola_workspace_id` (per-tenant Granola workspace for W6+ Scribe; SUBSTITUTED for `workos_directory_id` per Day-29 Granola vendor pivot — SCIM `workos_directory_id` deferred to v1.1+ supplement when SCIM write-back is in scope), `bullhorn_corporation_id` (per-tenant Bullhorn account identifier). Migration is forward + backward (UP creates `validate_tenant_adapters_config_v0_4` function with 16-key allowlist + per-key validators, rebinds the trigger, drops the v0.3 function; DOWN restores the v0.3 trigger + function verbatim; both atomic + idempotent). Status: Proposed.
docs/operations/goal-week-5-execution-plan.md:56:6. **`agents/recruitment/scribe/`** full bundle scaffolded same pattern. cycle.sh per agent.md §4 (polling-driven from Granola — Granola does NOT publish a webhook surface; 5-min cron polls `list_meetings_by_date_range` per tenant per @ifos/granola README §Scribe consumption pattern; transcript ingest → entity extraction → Bullhorn note write); validate.sh Gate A per §5; tools.yaml Bullhorn-write + @ifos/granola read capabilities (3 meeting tools + transcript tool with Paid-plan guard); 3 fixtures.
docs/operations/goal-week-5-execution-plan.md:57:7. **`agents/recruitment/sourcing-scout/`** full bundle scaffolded. cycle.sh per agent.md §4 (3 active sources at v1.0 per 2026-06-02 Proxycurl caveat); validate.sh Gate A; tools.yaml Bullhorn-passive-match + Reed + CV-Library; 3 fixtures. LinkedIn Step 4 is NO-OP per the v1.0 caveat.
docs/operations/goal-week-5-execution-plan.md:66:13. **Cluster F-tris ratification manifest entry** added — Janitor + Scribe + Sourcing Scout agent-bundles + Bullhorn MCP + WorkOS MCP + v0.4 supplement + Granola MCP (vendor pivoted from Fathom/Fireflies 2026-06-03). Founder triggers when ready (expected partial-ratification outcome per Fbis + G precedent; same disagreement-doc framework applies if rounds blow out).
docs/operations/goal-week-5-execution-plan.md:68:### E — Founder-side gates carried to W6 (not blocking W5 scaffolding)
docs/operations/goal-week-5-execution-plan.md:71:- Granola Business+/Paid workspace + browser-based OAuth 2.1 PKCE consent (per workspace) → enables live transcript tests for @ifos/granola (founder confirmed tier 2026-06-03; browser consent dance still pending for the test workspace)
docs/operations/goal-week-5-execution-plan.md:74:- Q1 LOI with Jack → enables pilot data flow (Trigger 1 fires 2026-06-03 without it)
docs/operations/goal-week-5-execution-plan.md:82:### Phase 1 — Day 28 (2026-06-03): @ifos/bullhorn MCP scaffold
docs/operations/goal-week-5-execution-plan.md:91:- Capabilities: getCandidate, listCandidates, updateCandidate, getPlacement, getClient, getContact, createNote, createActivityLogEntry, refreshTokens (matches Janitor + Scribe + Concierge agent.md tools.yaml refs)
docs/operations/goal-week-5-execution-plan.md:118:**Vendor pivot:** original plan called for Fathom OR Fireflies; founder pivoted to **Granola** on 2026-06-03 — sits in the background during calls without an extra meeting attendee, has an official MCP server at `mcp.granola.ai/mcp` (no first-party MCP client wiring needed; just wrap their 6 tools with IFOS-tier rate-limit + plan-tier guard + audit). The original `packages/mcp-connectors/{fathom,fireflies}/` paths are NOT being built; the actual artefact is `packages/mcp-connectors/granola/`.
docs/operations/goal-week-5-execution-plan.md:120:**Founder gate (resolved 2026-06-03):** Granola plan tier confirmed Business+/Paid. The two Paid-only tools (`list_meeting_folders`, `get_meeting_transcript`) are unlocked-by-default; tenant provisioning pre-caches `plan_tier='paid'` in the `GranolaClient` via `get_account_info()` so the per-call Paid-plan guard short-circuits before any wire round-trip.
docs/operations/goal-week-5-execution-plan.md:124:**Commit landed:** `feat(mcp/granola): scaffold @ifos/granola wrapper — IFOS-tier over mcp.granola.ai/mcp for Scribe W6`
docs/operations/goal-week-5-execution-plan.md:132:- Update `docs/decisions/2026-05-31-d1-founder-decision.md` implementation-surface item 5 — Path A or Path B choice now testable; Path A confirmed (reuse approval_routing + add operator_telegram_chat_id as top-level for clarity)
docs/operations/goal-week-5-execution-plan.md:143:### Phase 5 — Days 31-32: Janitor + Scribe full bundles
docs/operations/goal-week-5-execution-plan.md:154:**Scribe bundle (Day 32):** same pattern. Polling-driven from Granola (5-min cron `list_meetings_by_date_range` per @ifos/granola README §Scribe consumption pattern — Granola does NOT publish webhooks); tools.yaml capabilities for Bullhorn-write + @ifos/granola read (3 meeting tools + transcript with Paid-plan guard) + voice-classifier. 3 fixtures.
docs/operations/goal-week-5-execution-plan.md:168:- Add cluster F-tris entry to `scripts/run-codex-ratification.sh` (Janitor + Scribe + Sourcing Scout agent-bundles + 3 new MCP packages + v0.4 supplement)
docs/operations/goal-week-5-execution-plan.md:169:- Print W5 close report + recommended W6 /goal shape
docs/operations/goal-week-5-execution-plan.md:183:| 5 (Janitor + Scribe bundles) | 31-32 | 8h total | shellcheck fails after 1 round of fixes per file | mirror exact pattern from CC bundle instead of inventing |
docs/operations/goal-week-5-execution-plan.md:201:| Founder confirms Granola plan tier (RESOLVED 2026-06-03: Business+/Paid) | Phase 3 — RESOLVED | Founder confirmed Business OR Enterprise; not Free; encoded in v0.4 supplement §0 notes |
docs/operations/goal-week-5-execution-plan.md:205:| v0.4 migration run against live VPS | Schema active in production tenant | Founder runs migration after my SQL draft + review; uses `run-v0.4-migration-as-postgres.sh` wrapper (analog to v0.3 wrapper landed 2026-05-31) |
docs/operations/goal-week-5-execution-plan.md:206:| Q1 LOI with Jack | Trigger 1 (2026-06-03 PAUSE) | Founder closes the LOI conversation directly |
docs/operations/goal-week-5-execution-plan.md:214:Per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` precedent: expect **partial-ratification with disagreement docs** at the bundle layer for Janitor + Scribe + Sourcing Scout. The pattern:
docs/operations/goal-week-5-execution-plan.md:215:- Contract layer (agent.md content) already RATIFIED at W3 cluster E (2026-05-31) for all 3 agents
docs/operations/goal-week-5-execution-plan.md:224:## §6 — Companion: deferred to W6+
docs/operations/goal-week-5-execution-plan.md:230:- **LinkedIn vendor selection for Sourcing Scout v1.1+** — W8-9 decision per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` Risk 14
docs/operations/goal-week-5-execution-plan.md:232:- **Janitor + Scribe + Sourcing Scout LIVE deployment** — W7+ once Bullhorn dev-support reply + commercial signups land
docs/operations/goal-week-5-execution-plan.md:233:- **WorkOS SSO live integration** — W6+ once tenant onboarding workflow needs admin auth
agents/recruitment/scribe/README.md:1:# Scribe — directory README
agents/recruitment/scribe/README.md:4:(W6 build slice, 2026-06-10) — gate-green + fixture-proven; live
agents/recruitment/scribe/README.md:19:| `bin/render-tacit-note.sh` | built — deterministic §3 Output 2 renderer (8-category taxonomy) |
agents/recruitment/scribe/README.md:22:| `fixtures/01-primary.yaml` | golden case (exercised by `scripts/run-scribe-extraction-test.sh`) |
agents/recruitment/scribe/README.md:28:- `scripts/run-scribe-extraction-test.sh`
agents/recruitment/scribe/README.md:29:- `scripts/run-scribe-gate-a-test.sh`
agents/recruitment/scribe/README.md:30:- `scripts/run-scribe-sla-test.sh`
agents/recruitment/scribe/README.md:34:`docs/features/agent-build/03-implementation/scribe-summary.md`
agents/recruitment/scribe/README.md:40:*End of Scribe README.*
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** **Accepted (founder-arbitrated 2026-05-31).** Codex `review-architecture-decision` skill RATIFIED this ADR at Round 3 of the cluster-E run (2026-05-31) after R1+R2 mechanical fixes (commits `ca66431` + `9b2e10a`). The ULTRAPLAN §8.1 A6 line 566 + line 567 amendments are now **permanent** (no longer provisional). The original Codex R3 Finding 3 (Concierge agent.md reframes 30-min SLA as Gate B without an authoritative ADR) is structurally closed by this Accept.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:7:**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — at the time of Codex R3, the Concierge `agent.md` reframed the 30-min SLA as Gate B without an ADR and §10 omitted an ADR-ratification blocker. Both have since been closed: Concierge `agent.md` §10 line 435 now lists "**ADR-007 RATIFIED**" as a Proposed → Accepted blocker, and this ADR exists. Analogue of ADR-006 (Diagnostic Gate A hybrid).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:26:This creates a documented gap between the upstream spec and the v0 scaffold. Codex R3 Finding 3 (Day-19 log `logs/codex-ratification/20260524T174513Z-13185/`):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:38:Polling-fallback delays are not Concierge's fault — the polling cron runs at a configurable interval (likely 5-15 minutes per tenant) and a state change that happens at minute 1 of a 15-minute cycle has a 14-minute "blind spot" before Concierge ever sees it. A per-draft hard-fail Gate A would treat this as a Concierge failure even though the draft IS generated within 30 minutes of detection (just not within 30 minutes of the actual Bullhorn state change).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:49:- Aggregate failures fire `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) when sustained — same operational lever as ADR-006's per-claim quality metric
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:51:This is structurally identical to ADR-006's Tier 1 (per-section, hard-fail at the agent level) vs Tier 2 (per-claim, quality metric over time) split — applied here to time (30-min threshold per draft = Tier 1; 90% within 30-min over rolling window = Tier 2).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:83:**ULTRAPLAN §8.1 A6 line 566 is amended in-band (Accepted by founder 2026-05-31)** following the ADR-006 precedent, which made the same kind of in-band amendment at line 496. There is no separate master-brief clause authorizing in-band spec amendments — master brief §10.3 step 4 only covers incorporating Codex feedback or writing a disagreement doc; the authority for the amendment is this ADR itself, now Accepted:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:98:4. Structural parity with ADR-006: per-event Gate A vs aggregate Gate B as the canonical Tier-1/Tier-2 split for time-based SLAs (replicable pattern for future agents)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:112:### In-band ULTRAPLAN amendment (Accepted with this ADR 2026-05-31; ADR-006 precedent)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:136:- ADR-006 — Diagnostic Gate A hybrid (structural template for Tier 1 vs Tier 2 split)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:145:**Status:** **Accepted (founder-arbitrated 2026-05-31).** Codex RATIFIED at Round 3 of the cluster-E 2026-05-31 session; founder Accept stamp completes the §10.5 cycle. ULTRAPLAN amendments permanent.
docs/operations/goal-week-6-execution-plan.md:3:**Status:** Drafted (W5 Day-34 marathon Phase 9; ratifies when first W6 /goal fires).
docs/operations/goal-week-6-execution-plan.md:5:**Authored:** 2026-06-03 (W5 close evening; marathon Phase 9).
docs/operations/goal-week-6-execution-plan.md:6:**Master plan citations:** Master brief §8.2 (build sequence; W6 = Scribe primary build week per line 597; W5+ Janitor + Scribe + Sourcing Scout transitions from SKELETON to LIVE) + ULTRAPLAN §8.1 A3 (Scribe build complexity M = 1 week per line 526) + W5 close state in `docs/operations/decision-log.md` Day 34.
docs/operations/goal-week-6-execution-plan.md:7:**Strategic premise:** W5 left ALL 5 v1.0 agent bundles at SKELETON tier (TODO(W6+) markers throughout). W6 transitions from scaffold-vs-live mismatch to live wiring as external dependencies land. Order of operations is dependency-driven: each agent's live wiring waits on its dependent MCP package having LIVE creds.
docs/operations/goal-week-6-execution-plan.md:9:**Maps to:** Day-35 (2026-06-04) → Day-41 (2026-06-10). 7-day window. May extend to Day-42+ if external dependencies land late.
docs/operations/goal-week-6-execution-plan.md:19:2. **`.agents/current-priorities.md`** header + action board + W5 CLOSED + W6+ deferred founder gates
docs/operations/goal-week-6-execution-plan.md:21:4. **`docs/operations/founder-api-signups-2026-06-03.md`** — current state of which signups have landed (founder updates this; pending signups gate corresponding phases)
docs/operations/goal-week-6-execution-plan.md:22:5. **`docs/operations/goal-week-5-execution-plan.md`** — for the SKELETON shape each W6 phase wires live against
docs/operations/goal-week-6-execution-plan.md:23:6. **Per-agent: `agents/recruitment/<agent>/agent.md`** Reading-discipline notes — these document the SKELETON-vs-CONTRACT deltas each W6 phase resolves
docs/operations/goal-week-6-execution-plan.md:24:7. **Per-MCP-package: `packages/mcp-connectors/<package>/README.md`** §"Live tests deferred" notes — these document what TODO(W5-live) or TODO(W6-live) markers W6 fills in
docs/operations/goal-week-6-execution-plan.md:32:### A — Scribe primary build (Days 35-37)
docs/operations/goal-week-6-execution-plan.md:34:1. **`@ifos/granola` LIVE TESTS pass** — founder completes browser OAuth dance (per founder-api-signups-2026-06-03.md P7); IFOS captures token bundle at vault path; `MCP_LIVE_TESTS=1 pnpm test` against real `mcp.granola.ai/mcp` passes ≥4 capability tests (list_meetings + get_meetings + get_transcript + get_account_info).
docs/operations/goal-week-6-execution-plan.md:35:2. **`@ifos/bullhorn` LIVE TESTS pass** — founder completes Bullhorn developer-account signup (per founder-api-signups-2026-06-03.md P1); IFOS bootstraps per-corporation OAuth tokens; `MCP_LIVE_TESTS=1 pnpm test` passes ≥6 capability tests (refreshTokens + getCandidate + listCandidates + updateCandidate + createNote + getNote against sandbox tenant).
docs/operations/goal-week-6-execution-plan.md:36:3. **Scribe `cycle.sh` Steps 1-9 wired live** — TODO(W6) markers replaced with real `@ifos/granola listMeetings` + `getTranscript` calls in Step 1 + Step 3; real `@ifos/bullhorn refreshTokens` in Step 2; real `@ifos/bullhorn updateCandidate` + `createNote` in Steps 8+9. Step 10 SLA metric computed against real elapsed seconds.
docs/operations/goal-week-6-execution-plan.md:37:4. **Scribe `validate.sh` Gate A G1-G7 wired live** — JSON proposal parsing + per-check validation + per-failure ESC routing.
docs/operations/goal-week-6-execution-plan.md:38:5. **Scribe `context.sh` SELECT path active** — env-var fallbacks replaced with `SELECT config->>'<key>' FROM tenant_adapters` for `bullhorn_corporation_id` + `granola_workspace_id` (v0.4-allowlisted) + Granola plan-tier pre-cache via `getAccountInfo`.
docs/operations/goal-week-6-execution-plan.md:39:6. **First real transcript ingested end-to-end** against migration-test tenant — Granola meeting → transcript fetch → LLM field extraction → Bullhorn updateCandidate + createNote → vault tacit-note artefact. Founder verifies in Bullhorn sandbox the candidate's record now shows the extracted fields + the new Note attachment.
docs/operations/goal-week-6-execution-plan.md:44:8. **Janitor `cycle.sh` Steps 1-9 wired live** — TODO(W6-7) markers replaced with real `@ifos/bullhorn` calls (refreshTokens, listCandidates with passive-match filter, updateCandidate for dedupe + field-backfill, createNote for tacit-note attach) + `@ifos/companies-house` enrichment lookups.
docs/operations/goal-week-6-execution-plan.md:50:W6 partial because Sourcing Scout's W9 build slice per master brief §8.2 line 599 — Day 40+ is preparation, not the full Sourcing Scout production wiring. Specifically:
docs/operations/goal-week-6-execution-plan.md:52:11. **`@ifos/reed` LIVE TESTS pass** — founder completes Reed Recruiter API signup (per founder-api-signups-2026-06-03.md P2); IFOS gets API key; `MCP_LIVE_TESTS=1 pnpm test` passes ≥3 capability tests (searchCandidates + getCandidate + listJobs against sandbox).
docs/operations/goal-week-6-execution-plan.md:55:14. **Sourcing Scout `cycle.sh` Step 4 LinkedIn NO-OP confirmed as W1.1+ scope** — no change; W6 acknowledges deferred status; W8-9 vendor selection precedes any wiring.
docs/operations/goal-week-6-execution-plan.md:59:15. All 5 v1.0 agent bundles in some live-wired state (full LIVE = Scribe + Janitor; PARTIAL = Sourcing Scout MCP packages ready, agent wait for W9).
docs/operations/goal-week-6-execution-plan.md:61:17. `.agents/current-priorities.md` W6 CLOSED state with deliverables enumerated.
docs/operations/goal-week-6-execution-plan.md:64:20. **Cluster F-tris re-trigger entry** — agent.md ↔ code drift naturally reconciled by W6 wiring; partial-ratification disagreement docs from F + Fbis + G can be re-evaluated.
docs/operations/goal-week-6-execution-plan.md:66:### E — Founder-side gates carried to W7+ (not blocking W6 work)
docs/operations/goal-week-6-execution-plan.md:68:- Q1 LOI with Jack — if not signed by 2026-06-10, kill-criterion Trigger 1 has now fired for a full week; reassessment required
docs/operations/goal-week-6-execution-plan.md:72:- Bullhorn dev-support reply (if delayed past 2026-06-09) → may push Scribe/Janitor live tests into W7
docs/operations/goal-week-6-execution-plan.md:80:### Phase 1a — Day 35 (originally 2026-06-04; slipped to Day 36 2026-06-05): @ifos/bullhorn live tests
docs/operations/goal-week-6-execution-plan.md:82:**Re-scope note (2026-06-05):** Phase 1 originally bundled Bullhorn + Granola live tests. Split into 1a (Bullhorn; this section) + 1b (Granola; below) per Day 36 morning analysis when the new session surfaced two genuine blockers on the Granola side: (1) `StreamableHTTPClientTransport` binding still TODO(W5-live) — the `@ifos/granola` v0.1.0 package is `GranolaTransport`-interface-only; (2) founder's Granola workspace returns 0 meetings — needs ≥1 recorded meeting before `getMeeting`/`getTranscript` live tests have data to exercise. Bullhorn is unblocked + load-bearing for downstream Scribe/Janitor/Concierge live wiring; ships first.
docs/operations/goal-week-6-execution-plan.md:93:### Phase 1b — Day 37 (estimated 2026-06-06): @ifos/granola transport implementation + live tests
docs/operations/goal-week-6-execution-plan.md:95:**Re-scope note (2026-06-05):** scope is significantly bigger than original Phase 1 estimate. Three sub-deliverables, not "token loader":
docs/operations/goal-week-6-execution-plan.md:110:### Phase 2 — Day 36 (2026-06-05): Scribe live wiring (half-day)
docs/operations/goal-week-6-execution-plan.md:113:- `agents/recruitment/scribe/context.sh`: TODO(W6) → real implementation; SELECT path active for bullhorn_corporation_id + granola_workspace_id; getAccountInfo pre-cache
docs/operations/goal-week-6-execution-plan.md:114:- `agents/recruitment/scribe/cycle.sh` Steps 1-3: real @ifos/granola listMeetings + getTranscript; real @ifos/bullhorn refreshTokens
docs/operations/goal-week-6-execution-plan.md:117:### Phase 3 — Day 36 evening (2026-06-05 PM): Scribe live wiring (continued)
docs/operations/goal-week-6-execution-plan.md:120:- `cycle.sh` Steps 4-7: real Bullhorn entity inference + LLM field extraction + tacit-note generation + vertical-schema validation
docs/operations/goal-week-6-execution-plan.md:124:### Phase 4 — Day 37 (2026-06-06): Scribe end-to-end + first real transcript ingested
docs/operations/goal-week-6-execution-plan.md:133:### Phase 5 — Day 38 (2026-06-07): Janitor live wiring (half-day each)
docs/operations/goal-week-6-execution-plan.md:136:- `agents/recruitment/janitor/{cycle,validate,context}.sh`: TODO(W6-7) → real implementation
docs/operations/goal-week-6-execution-plan.md:140:### Phase 6 — Day 39 (2026-06-08): Janitor end-to-end + first nightly cron
docs/operations/goal-week-6-execution-plan.md:149:### Phase 7 — Days 40-41 (2026-06-09 / 2026-06-10): @ifos/reed + @ifos/cv-library live + CV-Library auth verified
docs/operations/goal-week-6-execution-plan.md:157:### Phase 8 — Day 41 evening: W6 close
docs/operations/goal-week-6-execution-plan.md:161:- Update `.agents/current-priorities.md` W6 CLOSED
docs/operations/goal-week-6-execution-plan.md:164:- Re-evaluate cluster F-tris partial-ratification docs (some may close as agent.md ↔ code drift is naturally reconciled by W6 live wiring)
docs/operations/goal-week-6-execution-plan.md:174:| 2-3 (Scribe wire) | 36 | 8h | Bullhorn write API rejects payload shape | shape mismatch unresolvable in 1 round → STOP + ask founder |
docs/operations/goal-week-6-execution-plan.md:175:| 4 (Scribe E2E) | 37 | 6h | first real transcript end-to-end fails | upstream change between scaffold + W6 → STOP + reconcile |
docs/operations/goal-week-6-execution-plan.md:179:| 8 (W6 close) | 41 PM | 2h | smoke fails on previously-green test | STOP — surface + joint diagnosis with founder |
docs/operations/goal-week-6-execution-plan.md:185:- Codex ratification round attempted in this plan → NOT ALLOWED. Codex re-trigger happens after W6 close (cluster F-tris re-evaluation) per master brief §10.5 ceiling discipline.
docs/operations/goal-week-6-execution-plan.md:193:| Bullhorn dev-account creds in 1Password | Phase 1 (Bullhorn live tests) | Founder runs P1 of `founder-api-signups-2026-06-03.md`; save to 1Password as "IFOS Bullhorn — developer sandbox" |
docs/operations/goal-week-6-execution-plan.md:197:| Q1 LOI status (Jack) | Strategic — does v1.0 still ship? | Founder closes LOI directly; reports outcome by 2026-06-10 |
docs/operations/goal-week-6-execution-plan.md:206:W5 close added the cluster F-tris manifest entry (per scripts/run-codex-ratification.sh). W6's natural agent.md ↔ code reconciliation (when both files are touched in same workflow per the disagreement-doc framework) will resolve some of the disagreement-on-file artefacts.
docs/operations/goal-week-6-execution-plan.md:208:Expected outcomes at W6 close:
docs/operations/goal-week-6-execution-plan.md:209:- Scribe agent.md updated + bundle live-wired → Reading-discipline-note vendor-delta disagreement naturally closed
docs/operations/goal-week-6-execution-plan.md:211:- Sourcing Scout: still partial (W9 build slice owns full close); package-delta disagreement persists at W6 close
docs/operations/goal-week-6-execution-plan.md:219:Things explicitly OUT OF SCOPE for W6 but named for traceability:
docs/operations/goal-week-6-execution-plan.md:233:Every agent.md Reading-discipline note added in W5 (CC + Concierge + Janitor + Scribe + Sourcing Scout) documents the SKELETON-vs-CONTRACT gap. W6 live wiring naturally REDUCES this gap as TODO(W6+) markers get replaced with real implementation. By W6 close, the Reading-discipline notes for Scribe + Janitor should flip from "SKELETON state today; W6+ build slice wires" to "LIVE state per Phase X commit Y; agent.md Status flipped Proposed → Accepted".
docs/operations/goal-week-6-execution-plan.md:235:Sourcing Scout's Reading-discipline note may remain in SKELETON state at W6 close since its full agent wiring is W9 — but the package-delta portion of the note (reed/cvlibrary `package_status:scaffold_pending_phase_8`) DOES close at Phase 7 of W6.
docs/operations/goal-week-6-execution-plan.md:239:*End of W6 execution plan. Refresh `.agents/current-priorities.md` header at each phase close. This document is the source of truth; deviations require an entry in `docs/operations/decision-log.md`.*
docs/operations/codex-ratification-execution-plan.md:4:**Author:** Founder (Maddox) + Claude Code, 2026-05-20 (Day 8 PM).
docs/operations/codex-ratification-execution-plan.md:5:**Source artefacts:** master brief §10 (the loop) + `docs/decisions/2026-05-18-codex-ratification-manifest.md` (the queue) + this plan (the how).
docs/operations/codex-ratification-execution-plan.md:24:**Verified 2026-05-20:** `which codex` → `/opt/homebrew/bin/codex` exists, but invocation fails:
docs/operations/codex-ratification-execution-plan.md:117:Per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1 + the Day-8 additions in `.agents/current-priorities.md`. 34 items total, clustered by skill-type for efficient batching (run each skill against its batch before context-switching).
docs/operations/codex-ratification-execution-plan.md:182:| 30 | Single-sentence test | `docs/decisions/2026-05-18-day-7-single-sentence-test.md` | A |
docs/operations/codex-ratification-execution-plan.md:183:| 31 | Codex ratification manifest (recursive) | `docs/decisions/2026-05-18-codex-ratification-manifest.md` | A |
docs/operations/codex-ratification-execution-plan.md:204:Per master brief §10.6 — mean cost is 20-30 min per artefact including the round-trip. Cluster batching reduces context-switching cost.
docs/operations/codex-ratification-execution-plan.md:218:**Total floor estimate: ~12h30m of focused ratification work.** Realistically, with disagreement handling on ~10% of artefacts (3-4 items at 30-60 min each), allow **15-18 hours total** across the queue.
docs/operations/codex-ratification-execution-plan.md:348:Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:385:5. **Update `docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue table: status column flips from "queued" to "RATIFIED-<date>" or "REJECTED+resolved-<date>".
docs/operations/codex-ratification-execution-plan.md:390:7. **Master brief §10.6 timeline updated** with actual cost vs estimate. Founder-facing artefact.
docs/operations/codex-ratification-execution-plan.md:439:3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
docs/operations/seedlegals-engagement-queries.md:4:**Date:** 2026-05-22
docs/operations/seedlegals-engagement-queries.md:11:Per kill-criterion §3.4: external advisor is Week 1-2 must-fill. Per Risk #3: design partner LOI is 11 days from today (2026-06-03 trigger).
docs/operations/seedlegals-engagement-queries.md:140:2. **Update `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D3** with the confirmed retention period
docs/operations/seedlegals-engagement-queries.md:167:- 2026-06-03 (Trigger 1) date approaches; LOI process accelerates without legal infrastructure
docs/operations/session-retrospective-2026-06-03.md:1:# Session retrospective — 2026-06-03 (W5 marathon + W6 prep)
docs/operations/session-retrospective-2026-06-03.md:3:**Session:** 2026-06-03 single-day marathon mode (founder explicitly requested 20h envelope).
docs/operations/session-retrospective-2026-06-03.md:4:**Phases shipped:** W5 Days 28-34 (originally planned across 7 days) + W6 substrate prep (Reed + CV-Library MCP scaffolds + W6 execution plan).
docs/operations/session-retrospective-2026-06-03.md:7:**Total commits across day:** ~40 atomic commits spanning W5 Days 28 → W6 substrate prep.
docs/operations/session-retrospective-2026-06-03.md:20:- **Day 32 Phase 5b — Scribe bundle** (6 atomic commits `e6028e6` → `5f9ffc1`)
docs/operations/session-retrospective-2026-06-03.md:25:### W6 substrate (Phase 8 + 9 this session)
docs/operations/session-retrospective-2026-06-03.md:28:  - `@ifos/cv-library`: 20/20 vitest; dual auth_mode placeholder (Basic OR Bearer) pending W6-live verification
docs/operations/session-retrospective-2026-06-03.md:29:- **Phase 9 — W6 execution plan + this retrospective** (this commit)
docs/operations/session-retrospective-2026-06-03.md:42:- **Granola browser OAuth dance** — requires Claude Code restart founder explicitly didn't want today; unblocks Scribe live transcript tests at W6 Day 35
docs/operations/session-retrospective-2026-06-03.md:43:- **Bullhorn dev-support reply** (passive watch) — expected ~by 2026-06-09; unblocks Sub-decision B + Bullhorn API technical details
docs/operations/session-retrospective-2026-06-03.md:45:### Founder gates per `founder-api-signups-2026-06-03.md`
docs/operations/session-retrospective-2026-06-03.md:46:- P1 Bullhorn developer-account signup (~15min) → unblocks W6 Day 35 live tests
docs/operations/session-retrospective-2026-06-03.md:47:- P2 Reed Recruiter API signup (~30min; email-based commercial outreach) → unblocks W6 Day 40 live tests
docs/operations/session-retrospective-2026-06-03.md:48:- P3 CV-Library API signup (~30min) → unblocks W6 Day 40 + verifies dual auth_mode placeholder
docs/operations/session-retrospective-2026-06-03.md:52:- P7 Granola browser OAuth (~5min after CC restart) → unblocks Scribe live
docs/operations/session-retrospective-2026-06-03.md:67:3. **Reading-discipline note pattern + vendor-delta documentation.** All 3 Day 31-33 bundles (Janitor + Scribe + Sourcing Scout) landed with Reading-discipline notes documenting the SKELETON-vs-CONTRACT deltas (Scribe: webhook → polling per Granola pivot; Sourcing Scout: 4 sources → 3 active per Proxycurl shutdown + reed/cvlibrary `package_status:scaffold_pending_phase_8`). W6 wiring naturally resolves these deltas; the notes mean W6 doesn't need to re-derive context.
docs/operations/session-retrospective-2026-06-03.md:83:4. **agent.md ratification-status ambiguity.** Scribe + Sourcing Scout agent.md both say "Status: Proposed" in their banners but were ratified at W3 cluster E (per file metadata + commit history). Reading-discipline note pattern documents this ambiguity; W6 ratification update flips both Proposed → Accepted explicitly.
docs/operations/session-retrospective-2026-06-03.md:89:### W6 Day 35 (2026-06-04) — Scribe + Bullhorn live tests
docs/operations/session-retrospective-2026-06-03.md:94:### W6 Days 36-37 — Scribe end-to-end live wiring
docs/operations/session-retrospective-2026-06-03.md:95:- Per W6 plan doc §2 Phases 2-4
docs/operations/session-retrospective-2026-06-03.md:98:### W6 Days 38-39 — Janitor live wiring
docs/operations/session-retrospective-2026-06-03.md:99:- Per W6 plan doc §2 Phases 5-6
docs/operations/session-retrospective-2026-06-03.md:102:### W6 Days 40-41 — Reed + CV-Library live + W6 close
docs/operations/session-retrospective-2026-06-03.md:103:- Per W6 plan doc §2 Phases 7-8
docs/operations/session-retrospective-2026-06-03.md:125:4e05610 docs(founder-signups): API + commercial signups playbook
docs/operations/session-retrospective-2026-06-03.md:126:5f9ffc1 fix(scribe/agent.md): Reading-discipline note add
docs/operations/session-retrospective-2026-06-03.md:127:313be44 feat(scribe/tools.yaml + fixtures): Bullhorn write + Granola read
docs/operations/session-retrospective-2026-06-03.md:128:d314661 feat(scribe/cleanup.sh): cache purge + scribe_cleanup audit row
docs/operations/session-retrospective-2026-06-03.md:129:b3819e7 feat(scribe/context.sh): Bullhorn + Granola auth + plan_tier pre-cache
docs/operations/session-retrospective-2026-06-03.md:130:f9b4a84 feat(scribe/validate.sh): Gate A per agent.md §5
docs/operations/session-retrospective-2026-06-03.md:131:e6028e6 feat(scribe/cycle.sh): scaffold 10-step (vendor delta polling)
docs/operations/session-retrospective-2026-06-03.md:160:2. **Tomorrow morning (Day 35):** start with founder gates — P1 (Bullhorn) + P7 (Granola OAuth restart) are the two cheapest unlocks for tomorrow's Scribe live tests. ~20 min total.
docs/operations/session-retrospective-2026-06-03.md:161:3. **Then fire Day 35 /goal:** Scribe + Bullhorn live tests per `goal-week-6-execution-plan.md` §2 Phase 1.
docs/operations/session-retrospective-2026-06-03.md:165:*End of session retrospective 2026-06-03. W5 CLOSED; W6 substrate prepared; tree clean.*
agents/recruitment/diagnostic/agent.md:4:**Build state:** Full bundle built (agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures). Codex review-agent-bundle rounds run through R19 (latest applied 2026-05-25 bilateral pass); ADR-006 closed the Cat-1/Cat-ζ Gate A finding at R10; subsequent rounds sit at steady-state ~4 mechanical cross-reference findings/round per master brief §10.3 step 5. Status flips Proposed → Accepted when ALL: (a) Codex RATIFIED verdict (R19 or escalated founder-arbitrated per §10.3 step 5), AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds, AND (d) Gate B baseline measurement begins.
agents/recruitment/diagnostic/agent.md:5:**Date:** 2026-05-22.
agents/recruitment/diagnostic/agent.md:17:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (target voice-classifier ≥ 0.75 per `common-voice.json`; v0 implementation warns + exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unreachable per §5 honesty note — W4 polish closes this to unconditional hard-fail) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:34:Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY). Typical wall-clock: 10-15 minutes (empirical Day-13 measurement against Hays plc + Charterhouse fixtures); not specified in upstream master brief or Ultraplan.
agents/recruitment/diagnostic/agent.md:68:- Any section with zero citation links (per-section citation subcheck; ADR-006-canonical)
agents/recruitment/diagnostic/agent.md:77:The two-tier framing (hard-fails / complement) honestly reflects v0 behavior: the four hard-fails above ALWAYS block on failure; the two complement checks block ONLY when their upstream dependency is available. The agent.md previously described all six as "Gate A hard-fails" which was inconsistent with the §5 honesty note; corrected at R19.
agents/recruitment/diagnostic/agent.md:122:   → per-section citation hard-fail (ADR-006 Tier 1; no warn-only path)
agents/recruitment/diagnostic/agent.md:160:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
agents/recruitment/diagnostic/agent.md:162:**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
agents/recruitment/diagnostic/agent.md:164:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:177:Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
agents/recruitment/diagnostic/agent.md:232:| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
agents/recruitment/diagnostic/agent.md:236:| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ Rounds run through R19; ADR-006 (Accepted) closed the Cat-1 Gate A finding; residual ~4 mechanical findings/round tracked in disagreement doc Phase 4-5 |
agents/recruitment/diagnostic/agent.md:246:**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (through R19; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on ~4 mechanical findings/round).
agents/recruitment/scribe/context.sh:2:# Scribe agent — context.sh (pre-cycle hydration; W6 build slice LIVE)
agents/recruitment/scribe/context.sh:4:# Status: built (W6 build slice; replaces the W5 Day-32 skeleton stubs with
agents/recruitment/scribe/context.sh:6:#         schema supplement LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS):
agents/recruitment/scribe/context.sh:34:#   CTX_AGENT_NAME                — "scribe"
agents/recruitment/scribe/context.sh:37:#   CTX_GRANOLA_PLAN_TIER        — "paid" assumed (founder 2026-06-03)
agents/recruitment/scribe/context.sh:41:#   CTX_TONE_RULES_COUNT         — number of scribe-applicable tone_rule rows
agents/recruitment/scribe/context.sh:52:  printf 'scribe/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
agents/recruitment/scribe/context.sh:56:  printf 'scribe/context.sh: CTX_TENANT_SLUG unset\n' >&2
agents/recruitment/scribe/context.sh:59:export CTX_AGENT_NAME="scribe"
agents/recruitment/scribe/context.sh:115:# Per @ifos/granola README §"Scribe consumption pattern": getAccountInfo()
agents/recruitment/scribe/context.sh:118:# so v1.0 resolves: forced override → 'paid' default (founder 2026-06-03
agents/recruitment/scribe/context.sh:161:# tone rules: hh_load_tone_rules('scribe') count via _shared/voice-loader.sh.
agents/recruitment/scribe/context.sh:181:    _tr_json="$(hh_load_tone_rules "scribe" 2>/dev/null || echo '{"rules":[]}')"
agents/recruitment/scribe/context.sh:190:# verified 2026-06-10), so a canonical SELECT would be rejected at write time
agents/recruitment/scribe/context.sh:198:# Step 8 — Granola last_poll resolution (Scribe-internal cache file; NOT a
agents/recruitment/scribe/context.sh:202:_lp_file="${HOME}/.ifos-cache/scribe/${CTX_TENANT_SLUG}/last-poll-${CTX_GRANOLA_WORKSPACE_ID}.txt"
agents/recruitment/scribe/context.sh:210:  _lp="$(date -u -v-5M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u --date='5 minutes ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '1970-01-01T00:00:00Z')"
agents/recruitment/scribe/context.sh:219:  "agent:scribe; tenant:${CTX_TENANT_SLUG}; corp:${CTX_BULLHORN_CORPORATION_ID}; workspace:${CTX_GRANOLA_WORKSPACE_ID}; plan_tier:${CTX_GRANOLA_PLAN_TIER}; voice_corpus:${CTX_VOICE_CORPUS_ID}; last_poll:${CTX_GRANOLA_LAST_POLL}"
agents/recruitment/scribe/context.sh:222:printf '[scribe context.sh] tenant=%s corp=%s workspace=%s plan_tier=%s bullhorn_token=%s granola_token=%s voice_corpus=%s tone_rules=%s firm_domains=%s last_poll=%s\n' \
docs/operations/goal-week-4-track-1.md:3:**Status:** Authored 2026-05-31 (Day 25 / W4 Day-2); ready for execution.
docs/operations/goal-week-4-track-1.md:4:**Type:** Goal prompt (paste into Claude Code at session start; executor runs to completion across W4 Days 3-7, target 2026-06-01 → 2026-06-05).
docs/operations/goal-week-4-track-1.md:5:**Master plan citations:** Master brief §8.2 (build wave W4 Cash Conductor MCP connectors) + ULTRAPLAN §8.1 A4 (Cash Conductor spec lines 531-545) + ADR-005 (Week-3 acceleration → Cash Conductor pulled forward to W4 substrate) + `agents/recruitment/cash-conductor/agent.md` §8 build dependencies + `docs/decisions/2026-05-31-d1-founder-decision.md` (D1-B resolved) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic live render by 2026-06-14).
docs/operations/goal-week-4-track-1.md:7:**Builds on:** Week-3 close (`docs/operations/goal-week-3-polish-and-scaffold.md`; 8/9 Codex-RATIFIED + 1 fix-applied at commit `fbcb61e`); D1-B decision (`docs/decisions/2026-05-31-d1-founder-decision.md`).
docs/operations/goal-week-4-track-1.md:20:6. **`docs/decisions/2026-05-31-d1-founder-decision.md`** (D1-B Telegram shim — affects Cash Conductor `xero_reminder_send_customer` flow)
docs/operations/goal-week-4-track-1.md:80:18. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue extended with Cluster F entries.
docs/operations/goal-week-4-track-1.md:325:1. **`.agents/current-priorities.md`** — W4 Track 1 close section. List shipped artefacts. Update Open backlog: W4 Track 2 (Bullhorn-dependent agents — Janitor/Scribe) conditional on Bullhorn A+B Accepted; Cash Conductor full live test conditional on accounting/Open Banking commercial signups; Diagnostic live render gated on API keys.
docs/operations/goal-week-4-track-1.md:327:3. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue — Cluster F verdicts captured.
docs/operations/goal-week-4-track-1.md:392:- D1-B implementation choices that materially differ from `2026-05-31-d1-founder-decision.md` §"Implementation surface"
docs/operations/goal-week-4-track-1.md:490:  ✓ D1-B (2026-05-31 decision) — autosend bridge approach baked into cycle.sh
docs/operations/goal-week-4-track-1.md:496:  - Scribe build (W6; depends on Bullhorn W + Fathom/Fireflies)
docs/operations/goal-week-4-track-1.md:501:  - Bullhorn A+B chase / fallback at 2026-06-10 (Item 6)
docs/operations/goal-week-4-track-1.md:502:  - Q1 LOI (Item 7 — Jack's lane; Trigger 1 fires 2026-06-03)
docs/operations/goal-week-4-track-1.md:504:  - Fathom OR Fireflies signup (Item 9 — Scribe W6 prereq)
docs/operations/goal-week-4-track-1.md:539:**Day 7 (2026-06-05) is the soft target. Day 9 (2026-06-07) is the hard cutoff** (W5 Janitor build starts then per master brief §8.2 if Bullhorn A+B has Accepted). If Day 9 hits without completion, escalate to founder review + scope-cut decision.
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:72:    - { bullhorn_id: 1006, name: "Frank Fisher", email: "frank.f@example.test", phone: "+447700900006", last_modified_days_ago: 110 }
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:85:    - { reed_id: "reed-006", name: "Bob Brown", email: "bob.b@example.test", linkedin_url: "https://linkedin.com/in/bob-brown" }  # cross-source dedup with bullhorn_id 1002
agents/recruitment/sourcing-scout/fixtures/01-primary.yaml:136:    path: "/vault/migration-test/sourcing-scout-reports/12345-2026-06-03.md"
docs/runbooks/day-4-provisioning.md:4:date_written: 2026-05-17
docs/runbooks/day-4-provisioning.md:5:date_executed: 2026-05-17
docs/runbooks/day-4-provisioning.md:40:**Master brief asserts (line 477 verbatim):** "Hetzner UK VPS provisioned, LUKS-encrypted volume mounted at `/vault/`". This is the single Hetzner reference in the master brief. §10 (Codex ratification loop) does not mention Hetzner or cost targets — earlier drafts of this runbook cited "master brief §10.4" for cost target and Hetzner location; both fabricated. Corrected in citation-audit pass 2026-05-18.
docs/runbooks/day-4-provisioning.md:42:**Reality (verified 2026-05-17):** Hetzner Cloud locations are Falkenstein DE (FSN1), Nuremberg DE (NBG1), Helsinki FI (HEL1), Ashburn US (ASH), Hillsboro US (HIL), Singapore (SIN). **No UK data centre exists.** There is no UK region planned on the Hetzner roadmap as of writing.
docs/runbooks/day-4-provisioning.md:86:1. Operational simplicity for solo founder — Option α requires Hetzner rescue-mode familiarity and adds 30-60 min of provisioning per VPS rebuild
docs/runbooks/day-4-provisioning.md:104:### §0.6 — Single LUKS volume, two bind mounts
docs/runbooks/day-4-provisioning.md:1187:- Add Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; document UK-residency as commercial-conversation gate. (§10.4 reference dropped per 2026-05-18 citation audit; §10.4 is Codex exclusion list, not a Hetzner or cost-target section.)
docs/runbooks/day-4-provisioning.md:1200:## §12 — Execution log (populated 2026-05-17)
docs/runbooks/day-4-provisioning.md:1202:Day 4 executed in one session: Sunday 2026-05-17, started ~10:00 UTC, completed ~16:35 UTC. Deviations recorded below in chronological order. v1.1 runbook revision items collected at the end.
docs/runbooks/day-4-provisioning.md:1212:3. **§2 location — NBG1 substituted for FSN1:** FSN1 unavailable at provisioning time. Substituted Nuremberg (NBG1) — same Hetzner eu-central zone, identical Schrems II EU jurisdiction (German court orders only), latency to UK ~25-30ms vs FSN1 ~20-25ms (functionally equivalent). **Triggers §11.4 master-brief Edit 9:** master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations". (Earlier drafts of Edit 9 also referenced master brief §10.4; verified during 2026-05-18 citation audit that §10.4 is the Codex exclusion list, not a Hetzner or cost-target section. §10.4 component dropped.)
docs/runbooks/day-4-provisioning.md:1258:20. **LUKS passphrase rotation executed 2026-05-17 ~16:35 UTC.** `cryptsetup luksChangeKey` with `--key-file` for both OLD (leaked, embedded in heredoc) and NEW (generated on VPS via `openssl rand -base64 24`, written to temp file with `printf '%s'` — no trailing newline). Verification: `cryptsetup luksOpen --test-passphrase` confirms NEW accepted, OLD rejected. New passphrase stored at `/root/.new_luks_passphrase.tmp` (root-only, 32 bytes, no trailing newline) — outside `/vault` so it's recoverable after future LUKS-locked boots. Both `/tmp` temp files shredded post-rotation. **The leaked passphrase in this chat transcript is cryptographically invalid against the LUKS volume.**
docs/runbooks/day-4-provisioning.md:1262:- **Hetzner snapshot via Console:** Take Snapshot of `ifos-v2-prod-01` labeled `day-4-clean-verified-2026-05-17`. Not blocking — Hetzner weekly backups are already enabled (per §2.3 step 10). Founder action.
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:50:  event_timestamp_iso: "2026-06-01T15:00:00.000Z"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:58:      - {type: interview-booked, at: "2026-05-22T10:00:00Z"}
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:85:      posted_at_iso: "2026-06-01T15:00:30.000Z"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:86:      expires_at_iso: "2026-06-01T19:00:30.000Z"   # +PT4H
agents/recruitment/sourcing-scout/context.sh:6:#         LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS) —
agents/recruitment/sourcing-scout/context.sh:92:# Reference: v0.4 supplement LANDED 2026-06-03 (commit a1bbcf6 + LIVE on VPS).
agents/recruitment/sourcing-scout/context.sh:129:# TODO(W6+ commercial signup + Phase 8 package scaffold + W9 wiring):
agents/recruitment/sourcing-scout/context.sh:141:# TODO(W6+ commercial signup + Phase 8 package scaffold + W9 wiring):
agents/recruitment/sourcing-scout/tools.yaml:33:  # Schema-clean post v0.4 supplement (LIVE on VPS 2026-06-03; commit a1bbcf6).
agents/recruitment/sourcing-scout/tools.yaml:66:  # Reference: agent.md §4 Step 5. v1.0 source #2; W6+ commercial signup
agents/recruitment/sourcing-scout/tools.yaml:67:  # required (per founder-api-signups-2026-06-03.md P2).
agents/recruitment/sourcing-scout/tools.yaml:88:  # Reference: agent.md §4 Step 6. v1.0 source #3; W6+ commercial signup
agents/recruitment/sourcing-scout/tools.yaml:89:  # required (per founder-api-signups-2026-06-03.md P3).
docs/operations/goal-option-c-diagnostic-end-to-end.md:4:**Authored:** 2026-05-24 (Day 13 / end of Week 2)
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:32:1. **One Markdown file exists at `/vault/migration-test/diagnostic-reports/<firm-slug>-2026-05-24.md`** containing a 12-section Diagnostic report for a real UK recruitment firm chosen by the founder.
docs/operations/goal-option-c-diagnostic-end-to-end.md:51:7. **All work committed** as atomic commits with clear messages. Final commit confirms Trigger 2 beat (2026-06-14 deadline cleared 21 days early).
docs/operations/goal-option-c-diagnostic-end-to-end.md:99:**Companies House Developer API Key** (free; founder registers at https://developer.company-information.service.gov.uk/ — URL verified 2026-05-24 by curl).
docs/operations/goal-option-c-diagnostic-end-to-end.md:238:Verify the report at `/vault/migration-test/diagnostic-reports/<slug>-2026-05-24.md`:
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/operations/goal-option-c-diagnostic-end-to-end.md:397:Trigger 2 deadline (2026-06-14): cleared by [N] days
docs/operations/codex-round-2-autonomous-prompt.md:4:**Date:** 2026-05-22 (Day 11 PM).
docs/operations/codex-round-2-autonomous-prompt.md:85:SHA is in docs/decisions/2026-05-18-codex-ratification-manifest.md §1.5. 
docs/operations/codex-round-2-autonomous-prompt.md:145:Edit docs/decisions/2026-05-18-codex-ratification-manifest.md.
docs/operations/codex-round-2-autonomous-prompt.md:147:Add a new §1.7 section "Codex Round 2 verdicts (2026-05-22)" mirroring the 
docs/operations/codex-round-2-autonomous-prompt.md:181:    docs/decisions/2026-05-18-codex-ratification-manifest.md \
docs/operations/codex-round-2-autonomous-prompt.md:201:  + manifest update at docs/decisions/2026-05-18-codex-ratification-
docs/runbooks/operational-hygiene-protocol.md:3:**Status:** In force (Day 6, 2026-05-18). All sections from Week 0 onwards reference this document at section-gate moments.
docs/runbooks/operational-hygiene-protocol.md:4:**Author:** Claude Code + founder (Maddox), Day-6 evening 2026-05-18
docs/runbooks/operational-hygiene-protocol.md:5:**Source:** Lessons from Days 0-6 execution. Bumps three operational-grade dimensions from B+/C+/B → A by codifying what was previously implicit.
docs/runbooks/operational-hygiene-protocol.md:12:Days 0-6 self-grade on Week-0 retrospective (Day-6 evening):
docs/runbooks/operational-hygiene-protocol.md:74:**Codex Round 1 strengthening (2026-05-20):** the waiver text above is the *escape hatch*, not the default. **Any Path B use without same-session rotation is a protocol violation that counts as a Risk #1 strike** (operational hygiene degraded). Founder may invoke Path B exactly once per emergency context (e.g., boot-time `ifos-unlock` when Path A is impossible because no interactive terminal is available). Repeated Path B use in a single session indicates Path A/Path D pattern is insufficient — escalate to a new ADR rather than authorise repeatedly.
docs/runbooks/operational-hygiene-protocol.md:76:**Day-4 incident (reference example of a correctly-handled Path B use):** Path B was authorised once for §4.8 ifos-unlock end-to-end test. Founder rotated WITHIN THE SAME SESSION via `cryptsetup luksChangeKey`; `--test-passphrase` verified OLD rejected + NEW accepted. The leaked passphrase in the transcript became cryptographically invalid against the LUKS volume. **Cost:** ~30 minutes of rotation work + permanent transcript-history annotation. Audit record: Day-4 close commit `98c79b2` + `.agents/decisions/2026-05-17-path-b-rotation-1.md`.
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:165:| **Schema (YAML)** | Per entity / relationship | 40-60 lines (incl. fields + notes) | vertical-schema.yaml (8 entities × ~50 lines + 10 relationships × 10 lines + matrices + 12 questions ≈ 900 lines) |
docs/runbooks/operational-hygiene-protocol.md:258:## §7 — Day 4-6 citation audit findings (2026-05-18 Day 6 evening)
docs/runbooks/operational-hygiene-protocol.md:270:**Fix:** all 15 instances corrected on 2026-05-18 Day 6 evening:
docs/runbooks/operational-hygiene-protocol.md:312:Running the discipline rules against Days 0-6 retroactively:
docs/runbooks/operational-hygiene-protocol.md:320:The A-grade is structural, not retrospective: Days 0-6 retain their historical grades (the work happened the way it happened), but the *next* session that touches credentials / runbooks / drafts / citations starts from A-grade discipline.
docs/runbooks/operational-hygiene-protocol.md:337:**In force from 2026-05-18 Day 6 evening.**
docs/operations/founder-manual-playbook-2026-05-31.md:1:# Founder manual playbook — W4 (2026-05-31)
docs/operations/founder-manual-playbook-2026-05-31.md:4:**Window:** today → end-of-W4 (~2026-06-05)
docs/operations/founder-manual-playbook-2026-05-31.md:5:**Total time investment:** ~55 minutes for the 3 blocking items; rest are deferrable.
docs/operations/founder-manual-playbook-2026-05-31.md:90:**Why second:** closes Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 — 14 days from today). Two registrations + one command.
docs/operations/founder-manual-playbook-2026-05-31.md:191:**What I do on your reply:** flip ADR-007 Status from "Proposed (...) The ULTRAPLAN amendments below are applied PROVISIONALLY..." → "Accepted (founder-arbitrated 2026-05-31). ULTRAPLAN amendments are permanent." + remove the "reverts if rejected" clause + commit. Concierge §10 Proposed→Accepted blocker satisfied.
docs/operations/founder-manual-playbook-2026-05-31.md:197:**Why this priority:** Bullhorn partnerships form was submitted 2026-05-24. Any reply between 2026-05-24 → 2026-06-01 would have BOUNCED due to the M365 MX outage (`docs/incidents/2026-06-01-intelforce-ai-email-outage.md`). Re-submit the form with incident-aware framing acknowledging that original replies may not have reached us. Force-fallback fires ~2026-06-10. **Chase via FORM RE-SUBMISSION (not email — `partnerships@bullhorn.com` does NOT exist; verified 2026-05-23 + re-verified 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` line 68).**
docs/operations/founder-manual-playbook-2026-05-31.md:201:URL: **https://www.bullhorn.com/become-a-partner/** (verified live 2026-06-02 via WebFetch). Fill out the Marketo form on the page; paste the body below into the form's longest free-text field (typically labelled "Tell us about your enquiry" / "Comments" / "How can we help").
docs/operations/founder-manual-playbook-2026-05-31.md:207:form on 2026-05-24 (8 business days ago). A note on the gap: our M365
docs/operations/founder-manual-playbook-2026-05-31.md:208:inbound mail was misconfigured 2026-05-24 → 2026-06-01 after a DNS
docs/operations/founder-manual-playbook-2026-05-31.md:209:provider switch dropped the MX records — fully resolved 2026-06-01 — so
docs/operations/founder-manual-playbook-2026-05-31.md:243:- Any "How did you hear about us?" → "Previous form submission 2026-05-24"
docs/operations/founder-manual-playbook-2026-05-31.md:254:When the response arrives, paste their answer (full body OK; no need to redact). I'll fold it into Janitor / Scribe / Sourcing Scout / Concierge §8 build-prerequisite rows.
docs/operations/founder-manual-playbook-2026-05-31.md:260:**Why this priority:** Trigger 1 fires **2026-06-03 (3 days)**. If no LOI signed by then, Week 0 escalates to PAUSE per `v1.0-kill-criterion.md`. This is the single biggest external gate.
docs/operations/founder-manual-playbook-2026-05-31.md:264:- Text Jack today: "Where are we on the design-partner LOI? Trigger 1 fires Wed 2026-06-03 — if we don't have something signed (even a 1-page heads-of-terms) by then, we escalate to scope-cut review per the kill-criterion doc. Are we on track or do we need a Plan B?"
docs/operations/founder-manual-playbook-2026-05-31.md:294:### 6.2 Fathom OR Fireflies (~10 min) — unblocks W6 Scribe build
docs/operations/founder-manual-playbook-2026-05-31.md:364:For anything else (errors, questions, "is this right?"), just paste/describe and I'll triage.
docs/operations/founder-manual-playbook-2026-05-31.md:391:| D1 decision doc | `docs/decisions/2026-05-31-d1-founder-decision.md` |
agents/recruitment/sourcing-scout/cycle.sh:28:# capabilities with TODO(W6+) markers; cycle.sh Steps 5+6 emit STUB audit
agents/recruitment/sourcing-scout/cycle.sh:30:# W6 commercial signups + W9 build slice wires the actual calls.
agents/recruitment/sourcing-scout/cycle.sh:59:# v0.4 supplement (LANDED + LIVE on VPS 2026-06-03) made bullhorn_corporation_id
agents/recruitment/sourcing-scout/cycle.sh:203:# requires Phase 8 @ifos/reed scaffold + W6+ Reed commercial signup creds.
agents/recruitment/sourcing-scout/cycle.sh:215:# requires Phase 8 @ifos/cv-library scaffold + W6+ CV-Library commercial signup.
agents/recruitment/scribe/tools.yaml:1:# Scribe agent — tools.yaml (capability declarations)
agents/recruitment/scribe/tools.yaml:3:# Status: built (W6 build slice; cycle.sh/validate.sh/context.sh/cleanup.sh
agents/recruitment/scribe/tools.yaml:11:# through agents/recruitment/scribe/bin/bh-bridge.sh — the single
agents/recruitment/scribe/tools.yaml:21:# Scribe consumes BOTH @ifos/bullhorn (write surface) AND @ifos/granola
agents/recruitment/scribe/tools.yaml:22:# (read surface). Vendor delta from agent.md: agent.md describes Fathom /
agents/recruitment/scribe/tools.yaml:24:# vendor pivot (founder confirmed 2026-06-03). cycle.sh Reading-discipline
agents/recruitment/scribe/tools.yaml:25:# note + scribe/agent.md Reading-discipline note document the delta.
agents/recruitment/scribe/tools.yaml:28:# Scribe's 2 yellow-tier write action_types (bullhorn_scribe_field_write +
agents/recruitment/scribe/tools.yaml:30:# (re-verified 2026-06-10 — lines 240 + 212 respectively). scribe_cleanup /
agents/recruitment/scribe/tools.yaml:36:agent: scribe
agents/recruitment/scribe/tools.yaml:48:  # Reference: bullhorn-integration-path.md §4.1 A3 (Scribe scope).
agents/recruitment/scribe/tools.yaml:49:  # Schema-clean post v0.4 supplement (LIVE on VPS 2026-06-03; commit a1bbcf6).
agents/recruitment/scribe/tools.yaml:55:    action_type: bullhorn_oauth          # green tier; QUEUED for registration at W6
agents/recruitment/scribe/tools.yaml:87:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED in autosend-policy.yaml line 240
agents/recruitment/scribe/tools.yaml:94:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
agents/recruitment/scribe/tools.yaml:104:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
agents/recruitment/scribe/tools.yaml:113:    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
agents/recruitment/scribe/tools.yaml:121:    purpose: "Attach tacit-note narrative (mirror of vault artefact from Step 6) onto Bullhorn entity (Step 9)"
agents/recruitment/scribe/tools.yaml:128:  # NOT consumed by Scribe per agent.md §4 + Day-29 vendor pivot)
agents/recruitment/scribe/tools.yaml:129:  # Reference: @ifos/granola README §Scribe consumption pattern;
agents/recruitment/scribe/tools.yaml:135:    purpose: "Granola OAuth 2.1 + PKCE + DCR refresh (per-workspace_id Promise dedup + atomic file write per @ifos/granola src/auth.ts); Scribe pre-cache plan_tier='paid' via getAccountInfo at session start"
agents/recruitment/scribe/tools.yaml:136:    action_type: granola_oauth   # green tier; QUEUED for registration at W6
agents/recruitment/scribe/tools.yaml:143:    purpose: "List meetings since CTX_GRANOLA_LAST_POLL (cycle.sh Step 1 poll-sweep loop discovery); free plan returns last 30d only per Granola docs — Scribe assumes Paid (founder 2026-06-03)"
agents/recruitment/scribe/tools.yaml:158:    # NOTE: declared but not consumed at v1.0 — Scribe's poll-sweep uses
agents/recruitment/scribe/tools.yaml:164:    purpose: "Fetch meeting transcript with speaker segments (Step 3 per-meeting fetch); PAID PLANS ONLY — Scribe pre-guards via CTX_GRANOLA_PLAN_TIER from getAccountInfo cache (Step 0); 10-min cache TTL per @ifos/granola"
agents/recruitment/scribe/tools.yaml:167:    plan_tier_required: paid   # Scribe gates this before invocation
agents/recruitment/scribe/tools.yaml:176:  # Voice classifier (Step 6 tacit-note narrative voice scoring)
agents/recruitment/scribe/tools.yaml:182:    purpose: "Score tacit-note narrative against tenant voice corpus (≥0.75 required by Gate A G3); ESC_VOICE_DRIFT below threshold after 3 retries"
agents/recruitment/scribe/tools.yaml:194:  - id: scribe_cleanup
agents/recruitment/scribe/tools.yaml:196:    action_type: scribe_cleanup   # green tier; QUEUED for registration at W6
agents/recruitment/scribe/tools.yaml:212:    escalation: ESC_GRANOLA_AUTH     # blocking-equivalent; QUEUED for catalogue registration at W6
agents/recruitment/scribe/tools.yaml:225:    escalation: ESC_GRANOLA_PLAN_TIER     # warn; QUEUED for catalogue registration at W6; consumer degrades to notes-only ingest
agents/recruitment/scribe/tools.yaml:235:  - condition: "PII detected outside firm boundary in tacit-note narrative (validate.sh G6)"
agents/recruitment/scribe/tools.yaml:239:  - condition: "<3 structured-field extractions with confidence ≥0.6 (Step 5 → validate.sh G2)"
agents/recruitment/scribe/tools.yaml:267:# Already REGISTERED in agents/_shared/autosend-policy.yaml (re-verified 2026-06-10):
agents/recruitment/scribe/tools.yaml:268:#   bullhorn_scribe_field_write     line 240   yellow   (emitted by cycle.sh Step 8)
agents/recruitment/scribe/tools.yaml:271:#   scribe_run_complete             line  83   green    (emitted by cycle.sh Step 10)
agents/recruitment/scribe/tools.yaml:278:#   scribe_cleanup                  green   (cleanup.sh emits output row)
agents/recruitment/scribe/tools.yaml:298:#   marked QUEUED above for W6 build-start registration).
agents/recruitment/scribe/tools.yaml:300:#   §4.1 A3 (Candidate / Contact / Brief / Placement R+W + Note W) +
agents/recruitment/scribe/tools.yaml:302:#   since Scribe doesn't need folder listing; folder context is Sourcing
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md:1:# Founder playbook — 2026-06-03 (Granola consent + v0.4 migration)
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md:8:**Total time:** ~15 minutes if you do both.
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md:23:- ❌ Does NOT plug into the `@ifos/granola` wrapper yet — that's W5-live wiring (separate dance; needs the tokens to land at a specific vault path which Claude Code's MCP client doesn't expose). This task validates Granola works; the IFOS wrapper integration is W6 work.
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md:68:**Expected:** Claude calls the `list_meetings` Granola tool and returns a structured list. If you've had meetings transcribed in Granola recently, they appear.
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md:100:**Why:** v0.4 supplement landed in the repo 2026-06-03 (commit `a1bbcf6`). Until the migration is applied to the live VPS, the `validate_tenant_adapters_config_v0_4` trigger doesn't exist — meaning the new 5 keys (`operator_telegram_chat_id`, `email_channel`, `workos_org_id`, `granola_workspace_id`, `bullhorn_corporation_id`) would still hard-fail an UPDATE in production. This is the bridge from "schema in repo" to "schema live."
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md:185:- **Task 1 green:** unblocks W5-live planning for `@ifos/granola` wrapper integration tests. I'll write the W6 wiring playbook when we get there.
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md:186:- **Task 2 green:** flips Action Board item 14 from ⏸ to ✅; unblocks the W6 author from writing `@ifos/janitor` tools.yaml validation against live schema.
docs/specs/ULTRAPLAN.md:5:**Date:** 14 May 2026
docs/specs/ULTRAPLAN.md:238:- Process group includes one process per always-on agent the tenant has subscribed to.
docs/specs/ULTRAPLAN.md:245:- Shared Postgres instance: at 6–15 tenants in Q4 2026, running 15 separate Postgres instances is operationally suicidal at our headcount. RLS gives us audit-grade isolation without the operational cost.
docs/specs/ULTRAPLAN.md:283:- RPO: 5 minutes. RTO: 4 hours. These are documented in the customer contract and tested quarterly.
docs/specs/ULTRAPLAN.md:348:- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/specs/ULTRAPLAN.md:515:#### A3. The Scribe — the data spine
docs/specs/ULTRAPLAN.md:517:- **Build wave:** v1.0 (week 6–7)
docs/specs/ULTRAPLAN.md:522:- **Shared modules required:** Voice loader (for tone-detection of tacit notes), decision log writer
docs/specs/ULTRAPLAN.md:524:- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
docs/specs/ULTRAPLAN.md:525:- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
docs/specs/ULTRAPLAN.md:527:- **Gotchas:** Tacit-note extraction is the hard part. Start with a small taxonomy (5–10 tacit-note types) and expand. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
docs/specs/ULTRAPLAN.md:575:- **Build wave:** v1.1 (Q4 2026 weeks 1–4)
docs/specs/ULTRAPLAN.md:631:- **Gotchas:** LinkedIn rate limits are the single most fragile dependency in the platform. Build the rate-limit budget allocator carefully; this is where £40–60/mo of the £200 per-tenant compute cost lives.
docs/specs/ULTRAPLAN.md:687:| Scribe | ✓ | ✓ | | | | | | ✓ | | | |
docs/specs/ULTRAPLAN.md:719:Targets: 3 paid pilots by end of Q3 2026 (per the internal business plan). v1.0 = the six v1.0 agents shippable in the Starter and Boutique tiers; Growth/Scale defer to v1.1.
docs/specs/ULTRAPLAN.md:722:- Maddox solo for weeks 0–6; Hire #1 starts week 7 (per the most plausible reading of the user's memory, with caveat in §10).
docs/specs/ULTRAPLAN.md:725:- The first pilot lands at week 10 (mid-July 2026) for a 2-week pilot, converting to paid week 12.
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:760:- Week 6: Scribe agent; Fathom + Fireflies MCP; tacit-note taxonomy v0.1
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:783:Milestone: One paying tenant at end of Q3 2026; two more in advanced sales.
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:823:| 7 | Voice classifier underperforms (false positives blocking valid drafts) | Medium | Medium | First pilot reports >5% block rate on legitimate drafts | Soften the threshold from 0.75 → 0.65 for v1.0; tune up as corpus grows |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
docs/specs/ULTRAPLAN.md:889:1. Do we have at least one design partner who has said "yes I will pilot this in Q3 2026"?
docs/specs/ULTRAPLAN.md:905:| 1.0 | 14 May 2026 | Maddox + Claude | Initial ultraplan synthesising spec + Q&A answers |
docs/runbooks/tenant-lifecycle.md:4:**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation)
docs/operations/founder-legal-setup-guide.md:4:**Date:** 2026-05-23 (Day 12)
docs/operations/founder-legal-setup-guide.md:82:**URLs verified 2026-05-23 via HTTP check (200 response).** Firms listed only if their domain resolves. I have NOT verified their current pricing, quality, or fit for IFOS — that's what the free consultations are for. Always Google the firm name first to check reviews + current focus before contacting.
docs/operations/founder-legal-setup-guide.md:86:- **Ashfords LLP** (ashfords.co.uk) — tech sector group; mid-tier firm with startup-friendly hourly rates. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:87:- **Bird & Bird** (twobirds.com) — international firm; their fintech/SaaS group works with early-stage tech; ask for their "early-stage tech" rate card. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:88:- **Sparqa Legal** (sparqa.com) — online + solicitor hybrid; cheaper than traditional firms. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:92:- **Bristows LLP** (bristows.com) — IP + data protection specialists. Verified 2026-05-23 (firm exists; site may block automated checks).
docs/operations/founder-legal-setup-guide.md:93:- **Linklaters** (linklaters.com) — large international firm with UK practice. Verified 2026-05-23. Their startup/tech offering may be branded "Linklaters Sigma"; ask when contacting.
docs/operations/founder-legal-setup-guide.md:97:- **SeedLegals** (seedlegals.com) — cheapest fastest path, used by thousands of UK startups. Templates real but generic. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:98:- **Pocketlaw** (pocketlaw.com) — similar shape to SeedLegals, slightly more enterprise. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:102:- **Hiscox** (hiscox.co.uk) — well-known UK SaaS PI provider. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:103:- **Markel** (markel.com) — UK SaaS PI, well-regarded. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:104:- **PolicyBee** (policybee.co.uk) — startup-friendly broker; aggregates quotes from multiple insurers. Verified 2026-05-23.
docs/operations/founder-legal-setup-guide.md:106:### Removed from this list (URL verification failed 2026-05-23)
docs/operations/founder-legal-setup-guide.md:108:Previous versions of this doc listed: **Bowers Anderson**, **LawBite**, **Privacy Helper**, **Vouch**. Their URLs did not resolve when I tested. These may be real firms at different URLs, or they may not exist as I described — I cited them from training-data memory without verification. If you Google these names and they look real + currently active, by all means contact them — but I cannot vouch for the citations I previously gave.
docs/operations/founder-legal-setup-guide.md:133:8. *"What level of professional indemnity insurance is standard for a UK SaaS pre-revenue, expected 3-6 pilots in 2026 H2? I'm budgeting £1m PI + £1m public liability."*
docs/operations/founder-legal-setup-guide.md:148:**Today (2026-05-23, Saturday — book emails for Monday):**
docs/operations/founder-legal-setup-guide.md:154:**Monday-Wednesday next week (2026-05-25 to 27):**
docs/operations/founder-legal-setup-guide.md:161:**Thursday-Sunday (2026-05-28 to 31):**
docs/operations/founder-legal-setup-guide.md:167:**Following Monday (2026-06-01):**
docs/operations/founder-legal-setup-guide.md:216:> I'm Maddox Rigby, founder of Intel Force Ltd, a pre-revenue UK B2B SaaS building AI agents for UK recruitment agencies. We're targeting our first 3-6 pilot agreements in 2026 H2 and need professional indemnity cover before signing.
docs/operations/founder-legal-setup-guide.md:239:If you only do one thing today: **register with ICO**. It's £40-£60, takes 15 minutes online, and you legally need it before processing any UK personal data. This includes Hetzner-stored candidate PII in your test tenant.
docs/operations/founder-legal-setup-guide.md:241:**Verified URL (2026-05-23):** https://ico.org.uk/for-organisations/data-protection-fee/
docs/operations/founder-legal-setup-guide.md:245:On that page, click through to the self-assessment tool. You'll answer a few questions, pick the right tier (small SaaS = tier 1 typically; £52/year as of 2026), and pay online. Save the confirmation as `docs/operations/ico-registration-2026-05-XX.md`.
docs/operations/w4-bilateral-pass-6-agent-md.md:3:**Date:** 2026-05-25 (Day 20)
docs/operations/w4-bilateral-pass-6-agent-md.md:6:**Trigger 2:** DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 — 20 days runway. Diagnostic is pass-order #1.
docs/operations/w4-bilateral-pass-6-agent-md.md:27:**Source of these findings:** the latest round per agent in `logs/codex-ratification/20260524T*/`. Verbatim text quoted from each Codex response.
docs/operations/w4-bilateral-pass-6-agent-md.md:39:| 5 | Scribe | 5 | Ringover scope question is the only non-mechanical. |
docs/operations/w4-bilateral-pass-6-agent-md.md:46:**Round:** R16 post-v0.3 (Pre-Build-Round-16-Reviewed). Log: `logs/codex-ratification/20260524T130117Z-63874/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:74:  - **Codex says:** "Line 238 says Proxycurl/API choice is 'Resolved at W3 start before Companies House + LinkedIn MCP connectors authored,' while this Day-19 artefact and §8 lines 213-215 say the connector/web-scraper work is already shipped and Proxycurl is deferred. Fix Q3 to describe the current W4 Proxycurl/commercial decision path."
docs/operations/w4-bilateral-pass-6-agent-md.md:75:  - **Likely:** FIX-IN-PLACE. Rewrite Q3 to describe the actual Day-19 disposition (Proxycurl deferred; current W4 decision is whether to re-evaluate before pilot).
docs/operations/w4-bilateral-pass-6-agent-md.md:82:**Round:** R11 post-v0.3. Log: `logs/codex-ratification/20260524T174156Z-10120/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:92:  - **Codex says:** "Line 59 says tacit notes are harvested from `decision_log` rows with `outcome='approved_after_edit'`, but the schema only documents `decision_log` as `agent_name`, `phase`, and `payload JSONB`; `approved_after_edit` is the `recent_edit.resolution` enum in v0.2 supplement §1.3. Fix §3 to harvest from `recent_edit.resolution='approved_after_edit'` and use `decision_log` only for action-context joins."
docs/operations/w4-bilateral-pass-6-agent-md.md:105:  - **Likely:** **REJECT-CODEX** with rationale, OR small schema supplement edit. The migration allowlist IS the v0.3 supplement enforcement (per ADR-006 + the v0.3 trigger). But Codex's point is that they should also appear in the YAML schema definition (`tenant_adapters_config_additions`) for documentation completeness. Founder call: edit the YAML supplement to declare them explicitly, OR write disagreement claiming migration-allowlist is sufficient single-source-of-truth.
docs/operations/w4-bilateral-pass-6-agent-md.md:112:**Round:** R8 post-v0.3. Log: `logs/codex-ratification/20260524T151757Z-97714/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:122:  - **Codex says:** "It flips to Accepted on ratification/founder questions/ADR-006 before the W9 bundle exists, but the agent-bundle skill treats Accepted as production-ready after sibling files + fixtures exist and pass gates. Fix by keeping this scaffold Proposed after ratification, and make Proposed → Accepted depend on W9 build completion: `tools.yaml`, `context.sh`, `validate.sh`, `cycle.sh`, `cleanup.sh`, and 3 fixtures."
docs/operations/w4-bilateral-pass-6-agent-md.md:136:**Round:** R17 post-v0.3. Log: `logs/codex-ratification/20260524T145439Z-74254/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:158:## 5. Scribe — `agents/recruitment/scribe/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:160:**Round:** R3 post-v0.3. Log: `logs/codex-ratification/20260524T174401Z-12038/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:175:  - **Cite:** §3 lines 16, 30, 39; cross-ref §8 lines 295-298 + ULTRAPLAN A3 lines 521-523
docs/operations/w4-bilateral-pass-6-agent-md.md:176:  - **Codex says:** "Lines 16, 30, and 39 include Ringover as a provider, but §8 lines 295-298 only gate Fathom/Fireflies signup and connector work; ULTRAPLAN A3 lines 521-523 require Bullhorn, Fathom, and Fireflies tools/APIs, not Ringover. Either remove Ringover from v1.0 surfaces or add the Ringover commercial/API/connector prerequisites explicitly."
docs/operations/w4-bilateral-pass-6-agent-md.md:188:  - **Codex says:** "Line 250 defines it for Fathom/Fireflies/Ringover transcript fetches, but `agents/_shared/escalation-codes.md` lines 324-329 define a generic upstream read failure with examples that do not include transcript providers and no transcript-specific payload. Either update the catalogue to register transcript-provider usage and payload fields, or use/register a Scribe-specific transcript fetch code."
docs/operations/w4-bilateral-pass-6-agent-md.md:196:**Round:** R3 post-v0.3. Log: `logs/codex-ratification/20260524T174513Z-13185/`.
docs/operations/w4-bilateral-pass-6-agent-md.md:213:  - **Likely:** **SCOPE-EXPAND**. This is the analogue of ADR-006 for Diagnostic. W4 queue #3 already plans this ADR ("Future ADR — Concierge Gate A 30-min SLA hybrid"). Disposition options:
docs/operations/w4-bilateral-pass-6-agent-md.md:228:1. **Hh_decision_* coverage** (Scribe #2, Concierge #1) — workflow narratives are dropping the decision-log writes between numbered steps. After this pass, recommend a one-shot grep on all 6 agent.md to confirm every workflow step that produces output/action has an `hh_decision_*` annotation.
docs/operations/w4-bilateral-pass-6-agent-md.md:230:2. **Schema-citation hygiene** (Janitor #2, #3, #4; Sourcing Scout #1; Scribe #1) — v0.2/v0.3 supplement boundary is the single most-failed cross-reference. After this pass, recommend a CI grep that flags any `agent.md` field reference whose name doesn't appear in `vertical-schema.yaml` OR `vertical-schema.v0.3-supplement.yaml`.
docs/operations/w4-bilateral-pass-6-agent-md.md:232:3. **Catalogue completeness** (Diagnostic #2, Janitor #1, Scribe #5) — `escalation-codes.md` is the canonical mapping; agent.md narratives drift from it. After this pass, recommend a CI grep verifying every `ESC_*` reference in `agent.md` exists in the catalogue with at least the agent_name in `used_by`.
docs/operations/w4-bilateral-pass-6-agent-md.md:234:4. **Concierge Gate-A ADR** (Concierge #3) — only structural finding. Recommend writing the ADR before flipping Concierge to RATIFIED (analogue of ADR-006 process).
docs/operations/w4-bilateral-pass-6-agent-md.md:246:- [ ] REJECT-CODEX disagreements written to `docs/decisions/codex-disagreement-2026-05-25.md`
docs/features/agent-build/00-ORCHESTRATOR.md:57:`spec-001-janitor`, `spec-002-scribe`. Each runs in its own worktree + branch,
docs/operations/parallel-agent-build-method.md:8:Authored 2026-06-09. Method adapted from agentic.james's "One Big Feature
docs/operations/parallel-agent-build-method.md:48:2. FAN OUT (parallel background worktrees) — Janitor ║ Scribe ║ Sourcing Scout.
docs/operations/parallel-agent-build-method.md:98:| Cash Conductor | ✅ COMPLETE — all 14 steps LIVE | reference template #2 (PROVEN) | finished 2026-06-09 PM; the full agent-bundle live-wiring pattern (cycle 14 steps + validate.sh Gate A + cleanup.sh + reusable SQL + fixture suites) is now proven end-to-end |
docs/operations/parallel-agent-build-method.md:100:| Scribe | ⚪ SKELETON (~13 TODOs) | parallel fan-out (§3 step 2) | |
docs/operations/parallel-agent-build-method.md:104:**Substrate freeze (§3 step 0):** ✅ DONE 2026-06-10 — all 17 spec action_types verified registered in `agents/_shared/autosend-policy.yaml`; `blocked_recipients` confirmed a validated `tenant_adapters.config` key (migration chain v0.2→v0.4); all 9 Scribe v0.3-supplement field names confirmed in the schema supplements; no new migration needed; `scripts/build-gate.sh` PASS on main; CV-Library creds re-verified SET (Bullhorn/Reed EMPTY → degraded mode as specced).
docs/operations/parallel-agent-build-method.md:107:**Key constraint:** Bullhorn dev creds unobtainable → Janitor/Scribe/Concierge build to gate-green + fixture-proven; live-Bullhorn-smoke is founder-gated post-creds. Sourcing Scout is live-capable now (CV-Library). See `STATUS.md`.
docs/operations/parallel-agent-build-method.md:120:**Claude Fable 5** (Mythos-class, GA 2026-06-09, runs *inside* Claude Code) is the
docs/features/agent-build/01-LAUNCH.md:24:- Bullhorn dev creds are BLOCKED: Janitor/Scribe/Concierge build to gate-green + fixture-proven; live-Bullhorn-smoke is a founder-gated post-creds step (per each spec §8). Do NOT block on it.
docs/features/agent-build/01-LAUNCH.md:30:2. FAN OUT parallel background worktrees: Janitor (spec-001) + Scribe (spec-002).
agents/recruitment/concierge/fixtures/01-primary.yaml:42:  event_timestamp_iso: "2026-06-01T15:00:00.000Z"
agents/recruitment/concierge/fixtures/01-primary.yaml:49:    comms_history: [{type: application, at: "2026-05-28T10:00:00Z"}]
agents/recruitment/concierge/fixtures/01-primary.yaml:54:    interview_at: "2026-06-05T14:00:00Z"
docs/runbooks/pii-purge-operational-pattern.md:4:**Date:** 2026-05-22
docs/runbooks/pii-purge-operational-pattern.md:5:**Authority:** Surfaces UK GDPR Art. 5(1)(e) data-minimisation compliance for `recent_edit` text fields. Companion to `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D3 + Risk #10 in `docs/RISK-REGISTER.md`.
docs/features/agent-build/STATUS.md:6:**Phase:** 1 (PROVE-ONE). Substrate frozen 2026-06-10 (all action_types + schema fields verified; build-gate PASS on main; CV-Library creds re-verified SET). Sourcing Scout pilot in flight.
docs/features/agent-build/STATUS.md:12:| Sourcing Scout | `spec-003-sourcing-scout.md` | 1 (PROVE-ONE) | 🟡 built + gate-green (9 commits; orchestrator-verified build-gate PASS); review sub-agent + Codex ratification in flight | `worktree-agent-a45354564e8f66257` | **NO — corrected 2026-06-10:** `CVLIBRARY_*` values are actually EMPTY (template comments fooled the naive SET check). Live smoke founder-gated: fill via `scripts/fill-dev-sandbox-secrets.sh` |
docs/features/agent-build/STATUS.md:14:| Scribe | `spec-002-scribe.md` | 2 | ⚪ not started | — | no — **Bullhorn BLOCKED** + Granola token/0-meetings |
docs/features/agent-build/STATUS.md:25:1. **Bullhorn dev creds are unobtainable** (long-standing blocker). Janitor/Scribe/Concierge cores
docs/features/agent-build/STATUS.md:35:- **CV-Library creds (CORRECTED 2026-06-10: actually EMPTY — `KEY= # comment` template lines fooled the naive SET check). Fill via `bash scripts/fill-dev-sandbox-secrets.sh` → unblocks the Sourcing Scout live smoke.**
docs/features/agent-build/STATUS.md:36:- Bullhorn dev sandbox creds (unblocks Janitor/Scribe/Concierge + Sourcing Scout source #1).
docs/features/agent-build/STATUS.md:38:- Granola IFOS-side OAuth token on disk + ≥1 recorded meeting (unblocks Scribe live transcript).
docs/operations/w4-day-20-founder-runbook.md:3:**Date:** 2026-05-25 (Day 20)
docs/operations/w4-day-20-founder-runbook.md:5:**Trigger 2 runway:** DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 — 20 days
docs/operations/w4-day-20-founder-runbook.md:22:- [x] Live VPS state confirmed v0.2 (2026-05-23 audit log `logs/tenancy-audit/20260523T133042Z-80608/T1-tables.log` shows 10 tables with `tenant_slug NOT NULL`; both `cash_conductor_*` tables absent).
docs/operations/w4-day-20-founder-runbook.md:112:5. Scribe (5 findings) — Ringover scope question is the only non-mechanical
docs/operations/oauth-sandbox-app-setup-runbook.md:3:**Purpose:** the exact, one-shot setup for the three Cash Conductor sandbox OAuth apps so the live-test bootstrap dances succeed first try. Written 2026-06-09 (W6 Day 36) after a long live-dance loop; every failure mode we hit is captured in §4.
docs/operations/oauth-sandbox-app-setup-runbook.md:18:After the long 2026-06-08 loop, the fix was to stop clicking into misconfigured apps. Two helpers now gate that:
docs/operations/oauth-sandbox-app-setup-runbook.md:32:As of 2026-06-09 the doctor reports: **QuickBooks ✓, TrueLayer ✓, Xero ✗** (the Xero app rejects accounting scopes — see §1).
docs/operations/oauth-sandbox-app-setup-runbook.md:60:> **The tell (provable, browserless):** `bash scripts/oauth-preflight.sh xero`. It probes the authorize endpoint per scope. A correct Web app accepts `accounting.transactions`; the broken app accepts `openid`/`offline_access` but returns **`invalid_scope`** for every `accounting.*` scope. That asymmetry = not a Web app (confirmed 2026-06-09 on the current `XERO_CLIENT_ID`).
docs/operations/oauth-sandbox-app-setup-runbook.md:112:## §4 — Troubleshooting table (everything we hit on 2026-06-08/09)
docs/operations/oauth-sandbox-app-setup-runbook.md:121:| **Xero** `invalid_scope` on `accounting.transactions` for a confirmed Web app | Xero **granular scopes**: apps created after **2026-03-02** only have the new granular scopes; the broad `accounting.transactions` is retired for them. | Request granular scopes: `offline_access accounting.invoices.read accounting.payments accounting.contacts.read` (already the bootstrap default). Probe per-scope with the *registered* redirect to see which are granted. |
docs/operations/oauth-sandbox-app-setup-runbook.md:138:*Companion to the W6 plan (`docs/operations/goal-week-6-execution-plan.md` §2) and the three `packages/mcp-connectors/*/README.md` §Live tests sections. Bootstrap helpers hardened in commit 464d4e8.*
docs/operations/session-init-w7-p3-reconciliation.md:5:_Written 2026-06-09. Last commit: `f444b34` (pushed to origin/main)._
docs/features/agent-build/02-specs/spec-001-janitor.md:25:- decision_log markers: `janitor_scan`, `field_completeness_audit`, `janitor_tacit_note_harvest`, `day_30_report`, + action rows `bullhorn_candidate_dedupe`/`bullhorn_field_backfill`/`bullhorn_note_attach`/`operator_notify_telegram`/`janitor_run_complete`. These feed the day-30 report aggregation (Step 10) + kill-criterion Trigger 8 evidence.
docs/features/agent-build/02-specs/spec-001-janitor.md:39:| 8 | Tacit-note harvest: `SELECT FROM recent_edit WHERE resolved_at>now()-30d AND resolution='approved_after_edit'`; group by entity_type; voice-classified LLM narrative | `janitor_tacit_note_harvest` | `ESC_VOICE_DRIFT` (<0.75 after 3 retries) | CC Step 8 draft (voice honesty: unscored if no corpus) |
docs/features/agent-build/02-specs/spec-001-janitor.md:54:| voice | tacit-note narrative classifier ≥0.75 | `ESC_VOICE_DRIFT` | hard (warn-when-unscored, per CC honesty) |
docs/features/agent-build/02-specs/spec-001-janitor.md:78:- This is the **PROVE-ONE pilot** — it validates the build machine (bundle wiring + fixtures + gates + the Bullhorn CLI-bridge pattern) before Scribe/Sourcing-Scout fan out. Run it solo first.
docs/features/agent-build/02-specs/spec-001-janitor.md:79:- Can run in parallel with: Scribe, Sourcing Scout (disjoint files) once proven.
docs/features/agent-build/02-specs/spec-004-concierge.md:78:- Sequence after Janitor/Scribe/Sourcing-Scout prove the bundle pattern; the autosend-bridge wiring is the cross-cutting deliverable that also closes Cash Conductor's send loop.
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (2026-05-24): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B (Sub-decision A RESOLVED 2026-06-02 per `docs/decisions/bullhorn-integration-path.md` — direct API per-tenant OAuth; marketplace deferred to v1.1+) + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:5:**Reading-discipline note (added 2026-06-03 per CC + Concierge + Janitor + Scribe precedent):** this `agent.md` is the **CONTRACT** that the W9 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `4e62d06` + `ebd9b40` + `6f1e07c` + `fe1423e` + `3be4bb5` per W5 Day-33); they carry `TODO(W9)` markers throughout that the W9 build slice replaces with live implementation matching the contract below. **VENDOR DELTA**: this `agent.md` §1 output contract describes "FOUR sources" (Bullhorn + LinkedIn + Reed + CV-Library); the deployed SKELETON operates against THREE active sources per the v1.0 LinkedIn caveat at lines 6-8. cycle.sh Step 4 is an explicit no-op audit row (`linkedin_search_skipped`) per the Janitor Step 7 NO-OP pattern. **REED + CV-LIBRARY PACKAGE DELTA**: tools.yaml declares `reed_*` + `cvlibrary_*` capabilities with `package_status:scaffold_pending_phase_8` — the `@ifos/reed` + `@ifos/cv-library` MCP packages don't exist yet; they land in Phase 8 of this marathon /goal (sibling phase). **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON `cycle.sh` emits only the minimal trigger/output markers (`session_start`, `brief_ingested`, `auth_refresh_complete`, `bullhorn_passive_query`, `linkedin_search_skipped`, `reed_query`, `cvlibrary_query`, `aggregate_dedupe`, `dnc_filter`, `rationale_generation`, `scout_report`, `scout_run_complete`).** Pure read+report agent — no yellow/orange/red action_types; only state-changing action is `sourcing_scout_cleanup` (green; QUEUED for W9). The SKELETON `context.sh` uses **env-var fallbacks** today even though `bullhorn_corporation_id` is v0.4-allowlisted (LANDED + LIVE on VPS commit `a1bbcf6`) and `blocked_recipients` is v0.3-allowlisted (LIVE on VPS) — canonical SELECT path wiring lands W9 alongside `@ifos/bullhorn` + `@ifos/reed` + `@ifos/cv-library` refresh integrations. Don't read agent.md as a description of running code; read it as the spec the W9 build slice implements after the LinkedIn v1.0 deferral and the Reed/CV-Library package scaffolds are acknowledged.
agents/recruitment/sourcing-scout/agent.md:7:**v1.0 readiness caveat — LinkedIn deep-data vendor (added 2026-06-02):** the original v1.0 design listed **Proxycurl** as the LinkedIn deep-data source (one of FOUR sources in the §1 output contract). **Proxycurl was shut down in 2025** following LinkedIn's January 2025 lawsuit against Nubela (Proxycurl's parent; ~50% of their revenue came from LinkedIn scraping; see https://nubela.co/blog/goodbye-proxycurl/). The successor product **NinjaPear** (same team) explicitly does NOT carry LinkedIn data — it is a B2B competitive-intelligence platform sourced from non-LinkedIn channels. Net: the LinkedIn-via-Proxycurl path described throughout §1 + §3 + §4 Step 4 + §6 ESC routing **does not have a legally-clear vendor as of 2026-06-02**.
agents/recruitment/sourcing-scout/agent.md:9:**v1.0 disposition (per founder decision 2026-06-02):** LinkedIn deep-data is **DEFERRED to v1.1+**. v1.0 Sourcing Scout operates against **THREE active sources** (Bullhorn-candidate passive-match + Reed + CV-Library), not four. The §1 output contract's "5-15 candidates" Gate A target is preserved; Reed + CV-Library + Bullhorn passive-match combined are sufficient at v1.0 pilot scale (≤3 tenants). LinkedIn-vendor selection for v1.1+ takes place at W8-9 when the Sourcing Scout build slice forces the choice and we have more clarity on the post-lawsuit legal landscape (candidate vendors: Lix, Phantombuster, Apify with LinkedIn-aware contracts, or LinkedIn's own Sales Navigator enterprise API at much higher cost). Until that decision: §4 Step 4 (LinkedIn search via Proxycurl) is a NO-OP in v1.0; the ranked-list assembly at Step 6 weights the 3 active sources accordingly; the §3 output template still shows the LinkedIn row but populates it as "deferred to v1.1+; vendor pending" rather than a scraped result. Gate B target (≥6 of 10 advance per ULTRAPLAN A5 line 553) unchanged at v1.0 — the marginal contribution of LinkedIn deep-data is unknown until pilot data lands; v1.1+ vendor selection partly informed by whether Gate B underperforms without it.
agents/recruitment/sourcing-scout/agent.md:14:**Date:** 2026-05-24.
agents/recruitment/sourcing-scout/agent.md:276:**Honesty note (per bilateral-disposition Cat-5):** Sourcing Scout `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W9 build slice. The W9 build delivers `agents/recruitment/sourcing-scout/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/sourcing-scout/agent.md:377:| Q6 | Source-abstraction layer design — Night Sourcer v1.1 reuses this. Should the design be ratified separately (its own ADR)? | Recommend: yes. A new ADR (number assigned at authoring time; not ADR-006 — that's Diagnostic Gate A) at W9 build start documenting the source-abstraction interface. |
agents/recruitment/sourcing-scout/agent.md:390:Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`): this agent.md ratifies when Codex review-agent-bundle returns RATIFIED verdict on the SCAFFOLD shape (output contract + workflow + gates + escalation + dependencies). **Ratification of the scaffold does NOT make it Accepted.** Per the agent-bundle skill, Accepted means production-ready — which requires all sibling bundle files + fixtures + first production run.
agents/recruitment/sourcing-scout/agent.md:401:   - Q6: source-abstraction-layer ADR drafted + ratified (new ADR — not the same as ADR-006 which is Diagnostic Gate A; number assigned at authoring time)
docs/features/agent-build/02-specs/spec-002-scribe.md:1:# Spec 002 — Scribe build
docs/features/agent-build/02-specs/spec-002-scribe.md:3:**A sub-agent given ONLY this file + `agents/recruitment/scribe/agent.md` + the Cash Conductor
docs/features/agent-build/02-specs/spec-002-scribe.md:4:template + CLAUDE.md has everything it needs to build Scribe autonomously.**
docs/features/agent-build/02-specs/spec-002-scribe.md:6:- **Agent dir:** `agents/recruitment/scribe/` (cycle.sh 10-step + validate.sh + dual context.sh + cleanup.sh + tools.yaml + 3 fixtures — SKELETON, ~13 TODO markers)
docs/features/agent-build/02-specs/spec-002-scribe.md:7:- **Master-plan source (READ IN FULL):** `agents/recruitment/scribe/agent.md`
docs/features/agent-build/02-specs/spec-002-scribe.md:8:- **Mirror template:** Cash Conductor. Reuse: RLS psql idiom; `bin/` LLM-render helper (CC `render-chase-draft.sh`) for the tacit-note; the `scripts/run-*-test.sh` fixture pattern; CC Step 6 idempotent write-back + ESC routing for the Bullhorn writes.
docs/features/agent-build/02-specs/spec-002-scribe.md:9:- **Wave/tier:** v1.0 W6; Tier 1 webhook-driven. **Scribe is the data spine (agent.md §1).**
docs/features/agent-build/02-specs/spec-002-scribe.md:10:- **⚠ TRANSCRIPT VENDOR = GRANOLA (`@ifos/granola`).** The agent.md §4 Step 3 text still names Fathom/Fireflies — that is PRE-PIVOT and WRONG. The W5 Day-29 vendor pivot moved Scribe's transcript source to **Granola**. Build every transcript-fetch path against `@ifos/granola`. Do NOT implement Fathom or Fireflies. (See §2, §4 Step 3, §8.)
docs/features/agent-build/02-specs/spec-002-scribe.md:14:agent.md §3-§6: the 10-step per-call workflow, ≥3 structured Bullhorn field writes + 1 tacit-note
docs/features/agent-build/02-specs/spec-002-scribe.md:19:- **autosend-policy action_types (registered, yellow):** `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`; + green `validate_gate_a_fail`, `scribe_run_complete`. Verify via grep.
docs/features/agent-build/02-specs/spec-002-scribe.md:22:- **Voice:** `hh_load_tone_rules` (∋ scribe) + `hh_load_voice_samples`.
docs/features/agent-build/02-specs/spec-002-scribe.md:25:- decision_log markers: `webhook_verified`, `bullhorn_auth_refreshed`, `transcript_fetched`, `entity_resolved`, `fields_extracted`, `tacit_note_rendered` (output, `{vault_path,body_sha256,voice_score}` — body NOT in payload per ADR-002), `fields_validated`, + action rows `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`, `scribe_run_complete`.
docs/features/agent-build/02-specs/spec-002-scribe.md:36:| 5 | LLM field extraction (per-field confidence; drop <0.6; need ≥3) | `fields_extracted` | `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | CC Step 8 LLM pattern (deterministic fallback for fixtures) |
docs/features/agent-build/02-specs/spec-002-scribe.md:37:| 6 | LLM tacit-note (8-cat taxonomy, ≤800w, voice ≥0.75) → vault 0600 | `tacit_note_rendered` | `ESC_VOICE_DRIFT` (3 retries) | CC Step 8 render→vault (voice honesty) |
docs/features/agent-build/02-specs/spec-002-scribe.md:39:| 8 | Bullhorn field write (PATCH, yellow, atomic) | `bullhorn_scribe_field_write` | `ESC_BULLHORN_WRITE_FAIL` (no Step 9) | CC Step 6 write-back |
docs/features/agent-build/02-specs/spec-002-scribe.md:41:| 10 | Session close + SLA metric (elapsed since webhook) | `scribe_run_complete` | `ESC_SCRIBE_SLA_MISS` (>30min render / >1h attach) | CC Step 14 |
docs/features/agent-build/02-specs/spec-002-scribe.md:47:| field-count | ≥3 extractions ≥0.6 confidence | `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` / `ESC_AGENT_OUTPUT_SHAPE` | hard |
docs/features/agent-build/02-specs/spec-002-scribe.md:48:| tacit-voice | note classifier ≥0.75 | `ESC_VOICE_DRIFT` | hard (warn-when-unscored) |
docs/features/agent-build/02-specs/spec-002-scribe.md:59:- `scripts/run-scribe-extraction-test.sh` — seeded transcript + entity → assert field extraction (≥3 ≥0.6), schema validation (name+type/range), drop-invalid, and the <3-valid Gate A fail.
docs/features/agent-build/02-specs/spec-002-scribe.md:60:- `scripts/run-scribe-gate-a-test.sh` — PASS + each fail class (webhook-sig, field-count, voice, schema, PII) + ESC routes (register tenant first; decision_log FK).
docs/features/agent-build/02-specs/spec-002-scribe.md:61:- `scripts/run-scribe-sla-test.sh` — elapsed-time → SLA bucket logic (5/10/30min/1h thresholds + Gate B 10-min miss).
docs/features/agent-build/02-specs/spec-002-scribe.md:71:- Can run in parallel with: Janitor, Sourcing Scout (disjoint files). Spawn after Janitor proves the build machine + the `@ifos/bullhorn` CLI-bridge pattern (which Scribe reuses).
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md:73:- Can run in parallel with: Janitor, Scribe (disjoint files). Reuses the Janitor matcher → spawn after Janitor lands that helper, or carry a copy + reconcile at review.
docs/operations/codex-round-2-remediation-prompt.md:4:**Date:** 2026-05-22 (Day 11 PM — post Round-2 close at `0b32047`)
docs/operations/codex-round-2-remediation-prompt.md:14:Paste the prompt below. Walk away for ~3-4 hours. Cost: ~$40-60.
docs/operations/codex-round-2-remediation-prompt.md:198:       docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/operations/codex-round-2-remediation-prompt.md:228:  File: docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/operations/codex-round-2-remediation-prompt.md:304:  > resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-
docs/operations/codex-round-2-remediation-prompt.md:319:  > engagement queries + `docs/decisions/2026-05-20-codex-round-1-
docs/operations/codex-round-2-remediation-prompt.md:380:Also add a 2026-05-22 update-log entry summarising the remediation +
docs/operations/codex-round-2-remediation-prompt.md:438:Edit docs/decisions/2026-05-18-codex-ratification-manifest.md.
docs/operations/codex-round-2-remediation-prompt.md:440:Add §1.8 "Codex Round 3 remediation verdicts (2026-05-22)" mirroring
docs/operations/codex-round-2-remediation-prompt.md:463:  - 2026-05-22 update-log entry
docs/operations/codex-round-2-remediation-prompt.md:475:        docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md \
docs/operations/codex-round-2-remediation-prompt.md:485:        docs/decisions/2026-05-18-codex-ratification-manifest.md \
docs/operations/codex-round-2-remediation-prompt.md:653:Cost: ~$40-60 OpenAI + ~3-4h Codex runtime + 0h founder time during the run + ~20 min review post-run.
agents/recruitment/sourcing-scout/README.md:27:Per ULTRAPLAN A5 line 555 gotcha: source-abstraction layer designed for Night Sourcer reuse. Defer ADR-006 to W9 build start documenting the layer's interface.
docs/operations/goal-week-3-polish-and-scaffold.md:3:**Status:** CLOSED (Day-19 narrative close 2026-05-24; **true Codex ratification close 2026-05-31**). Day-19 close was optimistic (premature RATIFIED status flips at commit `75ccc5f`, later reverted by R19 bilateral pass). True close 2026-05-31: ran `bash scripts/run-codex-ratification.sh --cluster E` three rounds — R1 verdict 4/9 RATIFIED, R2 verdict 6/9, R3 verdict **8/9 RATIFIED**; the 9th artefact (v0.2-to-v0.3 migration) had its R3 rollback finding fixed at commit `0f4ce8d` and re-ratification deferred per master brief §10.3 step 5 ceiling (3 round-trips already crossed; founder decision 2026-05-31 — fix + stop). Net effective state: **8/9 Codex-RATIFIED + 1 with the latest R3 fix applied = 9/9 in substance**. v0.3 schema supplement RATIFIED (final via Round 3). ADR-006 Diagnostic Gate A hybrid Accepted (founder-arbitrated). ADR-007 Concierge Gate A hybrid RATIFIED (still Status: Proposed pending founder Accept per its own §10). All 6 agent.md scaffolds RATIFIED at the contract level (Status: Proposed; production-readiness gates unchanged: pilot LOI · Bullhorn A+B · API keys · live VPS migration). See `.agents/current-priorities.md` "W4 Day-25" section for per-round detail + the deferred rollback re-ratification W4 backlog item. **STOP-HOOK NOTE: this file's gate-structure was superseded by in-session founder AUQ authorization; do not re-fire on subsequent turns.**
docs/operations/goal-week-3-polish-and-scaffold.md:6:**Authored:** 2026-05-24 (Day 13 evening; for execution Days 14-20)
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:45:1. **Companies House data flows end-to-end.** Founder has registered the API key (Step 2). Re-running cycle.sh against Hays plc produces §1 + §10 + §11 with REAL CH data (not "no registration found"). Updated artefact at `docs/artefacts/diagnostic-hays-plc-2026-05-2X.md`.
docs/operations/goal-week-3-polish-and-scaffold.md:53:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:80:15. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue extended with Round-4 items (queue: 43 → 49).
docs/operations/goal-week-3-polish-and-scaffold.md:96:| Codex Round 4 execution | Master brief §10.6 ratification cadence |
docs/operations/goal-week-3-polish-and-scaffold.md:104:| Bullhorn MCP connector wiring | Gated on Bullhorn Sub-decisions A+B response (sent 2026-05-24; expect 2-5 business days; if arrives mid-week, fold update into the relevant agent.md but do NOT start connector code) |
docs/operations/goal-week-3-polish-and-scaffold.md:106:| Fathom/Fireflies MCP connector | Reserved for W6 |
docs/operations/goal-week-3-polish-and-scaffold.md:111:| Modifying ratified ADRs 001-005 | Audit trail; ADR-006+ if new architectural decisions surface during Week 3 |
docs/operations/goal-week-3-polish-and-scaffold.md:169:> Founder action needed: register for Companies House API key at `https://developer.company-information.service.gov.uk/` (verified 2026-05-24). 15 minutes self-service. Save the key via SSH to the VPS:
docs/operations/goal-week-3-polish-and-scaffold.md:249:Copy to `docs/artefacts/diagnostic-hays-plc-2026-05-2X.md` (where X is the run date).
docs/operations/goal-week-3-polish-and-scaffold.md:257:Edit `docs/decisions/2026-05-18-codex-ratification-manifest.md`:
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:306:- **§3 Output shape:** day-30 report has 8 sections per ULTRAPLAN line 511 (record counts, dedup pairs, field-completeness deltas, tacit-note coverage, agent vs. consultant attribution, gate-B metric, exception list, executive summary).
docs/operations/goal-week-3-polish-and-scaffold.md:307:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:326:### DAY 17 — Scribe agent.md scaffold (Step 9)
docs/operations/goal-week-3-polish-and-scaffold.md:328:#### Step 9 — `agents/recruitment/scribe/agent.md` (~2-3 hours)
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
docs/operations/goal-week-3-polish-and-scaffold.md:348:- **§9 Open questions:** 4-6 covering Fathom vs Fireflies first-mover choice, webhook auth, field-extraction model selection, tacit-note length cap.
docs/operations/goal-week-3-polish-and-scaffold.md:352:Commit: `decision(pre-build): agents/recruitment/scribe/agent.md — output contract per ULTRAPLAN §8.1 A3`
docs/operations/goal-week-3-polish-and-scaffold.md:417:- `2026-05-20-codex-round-1-founder-decisions.md` §D1 (autosend orange-tier decision)
docs/operations/goal-week-3-polish-and-scaffold.md:463:3. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue — Round-4 verdicts captured; queue grown to 49+ items.
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:544:Add 6 items to `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.10:
docs/operations/goal-week-3-polish-and-scaffold.md:619:  Scribe (W6):            <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:632:  <SHA>  decision(pre-build): agents/recruitment/scribe/agent.md
docs/operations/goal-week-3-polish-and-scaffold.md:646:    2026-06-14 deadline by N days
docs/operations/goal-week-3-polish-and-scaffold.md:658:    - Scribe build (depends on Bullhorn W + Fathom MCP)
docs/operations/goal-week-3-polish-and-scaffold.md:663:  - <Fathom/Fireflies signup for W6>
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/features/agent-build/03-implementation/scribe-summary.md:1:# Scribe build summary — W6 build slice (spec-002)
docs/features/agent-build/03-implementation/scribe-summary.md:3:**Date:** 2026-06-10 · **Branch:** `worktree-agent-a59f16e915e384257` (based on `f456a27`)
docs/features/agent-build/03-implementation/scribe-summary.md:5:suites green; 9/9 DB-backed fixture suites green incl. the 3 new Scribe suites).
docs/features/agent-build/03-implementation/scribe-summary.md:17:| 5 | `fields_extracted` | LIVE — `bin/extract-fields.sh`: deterministic regex extraction (default; fixture-reproducible) + opt-in LLM path (`IFOS_SCRIBE_USE_LLM=1` + key; `claude-opus-4-8`, json_schema output, deterministic fallback on any failure); <3 fields ≥0.6 → `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` + gate row + skip |
docs/features/agent-build/03-implementation/scribe-summary.md:18:| 6 | `tacit_note_rendered` | LIVE — `bin/render-tacit-note.sh`: §3 Output 2 shape, 8-category taxonomy, ≤12-word quote clipping, no compensation in narrative, participant emails masked to local parts, ≤800-word cap; vault file 0600; decision_log payload = `{vault_path, body_sha256, voice_score}` ONLY (ADR-002) |
docs/features/agent-build/03-implementation/scribe-summary.md:20:| 8 | `bullhorn_scribe_field_write` (yellow) | LIVE — RLS `entities` cache UPDATE (DB trigger re-validates shapes) + `bh-bridge update-entity` PATCH; prior-data snapshot for rollback; per-write `recent_edit` row (`resolution='deferred'`) for Gate B edit-rate; opportunity = cache-only by design |
docs/features/agent-build/03-implementation/scribe-summary.md:22:| 10 | `scribe_run_complete` | LIVE — per-call elapsed since call end via `bin/sla-class.sh`; `ESC_SCRIBE_SLA_MISS` sla_type=summary_render (>30min) / note_attach (>1h); 10-min Gate B miss recorded, no ESC |
docs/features/agent-build/03-implementation/scribe-summary.md:32:| `scripts/run-scribe-extraction-test.sh` | PASS — 26 assertions: extractor ≥3 fields ≥0.6, drop-invalid (4 invalid classes), end-to-end replay with all 11 spec markers in decision_log, entities-cache write, recent_edit deferred row, vault note 0600, <3-fields fail path (ESC + gate row + exit 1 + no write) |
docs/features/agent-build/03-implementation/scribe-summary.md:33:| `scripts/run-scribe-gate-a-test.sh` | PASS — 19 assertions: 2 PASS paths (verified-sig and poll-trigger + warn-when-unscored) + 8 fail classes each with ESC routing asserted (`ESC_BULLHORN_AUTH`, `ESC_INPUT_VALIDATION_FAIL`, `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`, `ESC_VOICE_DRIFT`, `ESC_SCHEMA_VIOLATION`×2, `ESC_PII_LEAKAGE_RISK`, `ESC_AGENT_OUTPUT_SHAPE`) + 8 `validate_gate_a_fail` rows |
docs/features/agent-build/03-implementation/scribe-summary.md:34:| `scripts/run-scribe-sla-test.sh` | PASS — 19 assertions: 11 boundary buckets (0/240/300/301/600/601/1800/1801/3600/3601/7200s) + 4 cycle.sh integration cases (under-5-min, Gate-B 10-min miss with NO ESC, 30-min summary_render, 2h note_attach) |
docs/features/agent-build/03-implementation/scribe-summary.md:60:   `agents/recruitment/scribe/bin/bh-bridge.sh` ONLY.
docs/features/agent-build/03-implementation/scribe-summary.md:75:8. **`scribe_cleanup`/`bullhorn_oauth`/`granola_oauth` remain hh_decision_output**
docs/features/agent-build/03-implementation/scribe-summary.md:78:9. **agent.md untouched** (founder-gated status + W6-ratification rewrite). Its
docs/features/agent-build/03-implementation/scribe-summary.md:82:## Honest scope (spec-002 §8 — verified again 2026-06-10, names-only check)
docs/features/agent-build/03-implementation/scribe-summary.md:104:`agents/recruitment/scribe/{cycle,validate,context,cleanup}.sh`, `tools.yaml`,
docs/features/agent-build/03-implementation/scribe-summary.md:106:render-tacit-note,validate-fields,sla-class}.sh`, new
docs/features/agent-build/03-implementation/scribe-summary.md:107:`scripts/run-scribe-{extraction,gate-a,sla}-test.sh`, this summary.
docs/operations/goal-w4-day-26-2026-06-01.md:1:# /goal — W4 Day-26 autonomous build (2026-06-01)
docs/operations/goal-w4-day-26-2026-06-01.md:9:1. Commit founder's incident report verbatim → `docs/incidents/2026-06-01-intelforce-ai-email-outage.md`
docs/operations/local-dev-db-setup.md:3:**Purpose:** stand up a faithful **local** copy of the IFOS Postgres schema so agent bundles (Cash Conductor reconciliation/ingest, later Scribe/Janitor) can be built and live-smoked **without writing to the production VPS** and **without the 1Password `ifos_app` password.**
docs/operations/founder-api-signups-2026-06-03.md:1:# Founder API + signups playbook — 2026-06-03
docs/operations/founder-api-signups-2026-06-03.md:4:**Purpose:** Run this in parallel while Claude works on the W5-W6 marathon /goal. Every item below is a founder-only action — none can be delegated to the build agent. Doing these now unblocks W6+ live wiring across all 5 in-flight integrations.
docs/operations/founder-api-signups-2026-06-03.md:20:**Why first:** Trigger 1 fired 2026-06-03. This is the ONE thing only you can do that decides whether v1.0 ships at all. Every other item below is build-prep that's useless without a customer.
docs/operations/founder-api-signups-2026-06-03.md:287:- **Don't apply to Bullhorn marketplace partnership** — that route needs ≥2 live customers; deferred to v1.1+ per Sub-decision A (resolved 2026-06-02)
docs/operations/founder-api-signups-2026-06-03.md:290:- **Don't reply to Bullhorn dev-support email until it arrives** — passive watch; ~by 2026-06-09 per the 2-5 business day SLA from 2026-06-02 submission
docs/operations/founder-api-signups-2026-06-03.md:313:*End of founder signup playbook 2026-06-03. Companion to the W5-W6 marathon /goal firing in parallel.*
docs/operations/codex-round-2-handoff.md:4:**Date:** 2026-05-22 (Day 11 evening).
docs/operations/codex-round-2-handoff.md:9:- `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5 + §1.6 — queue state
docs/operations/codex-round-2-handoff.md:104:| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:105:| 20 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | `review-architecture-decision` | **Recursive ratification.** Codex evaluates Claude's counter-argument re: Week-1 gate. Founder escalation if REJECT. |
docs/operations/codex-round-2-handoff.md:106:| 21 | `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` | `review-architecture-decision` | RATIFY-with-advisory (briefing doc; D5 softening applies as Reference) |
docs/operations/codex-round-2-handoff.md:136:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
docs/operations/codex-round-2-handoff.md:137:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
docs/operations/codex-round-2-handoff.md:138:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/operations/codex-round-2-handoff.md:165:- 13 of 14 Round-1 rejections were incorporated in commit 2b287d3 (2026-05-20 evening)
docs/operations/codex-round-2-handoff.md:228:  docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md  (review-architecture-decision; recursive)
docs/operations/codex-round-2-handoff.md:229:  docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md  (review-architecture-decision; recursive)
docs/operations/codex-round-2-handoff.md:230:  docs/decisions/2026-05-20-codex-round-1-founder-decisions.md  (review-architecture-decision)
docs/operations/codex-round-2-handoff.md:324:`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5 + §1.6 — add per-artefact Round-2 verdict + disposition. Mirrors §1.5 Round-1 pattern.
docs/operations/codex-round-2-handoff.md:328:For each Round-2 RATIFIED item: mark status field "RATIFIED-Round-2-2026-05-22" (or appropriate date) in the queue table. Item is now closed; no further ratification needed unless artefact changes.
docs/operations/codex-round-2-handoff.md:373:Per master brief §10.6 + execution plan §5:
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:47:  event_timestamp_iso: "2026-06-01T15:00:00.000Z"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:55:      - {type: application, at: "2026-05-15T10:00:00Z"}
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:56:      - {type: interview-booked, at: "2026-05-22T10:00:00Z"}
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:57:      - {type: interview-completed, at: "2026-05-29T15:00:00Z"}
docs/operations/codex-ratification-guide.md:64:Verified 2026-05-20: `which codex` returns `/opt/homebrew/bin/codex` but invocation fails with `ENOENT` — the native binary at `vendor/aarch64-apple-darwin/codex/codex` is missing. The `postinstall` script that downloads the native binary did not complete.
docs/operations/codex-ratification-guide.md:160:  ✓ Prompt assembled at logs/codex-ratification/20260520T143000Z-12345/...prompt.md
docs/operations/codex-ratification-guide.md:407:  "session_id": "20260520T143000Z-12345",
docs/operations/codex-ratification-guide.md:420:WHERE payload->>'session_id' = '20260520T143000Z-12345'
docs/operations/codex-ratification-guide.md:514:- **Updated manifest** — `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue table marked with completion dates
agents/recruitment/concierge/README.md:35:**Founder Decision D1 (autosend orange-tier path) MUST be resolved before W10 build starts.** Per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Three options:
docs/specs/PRODUCT-SPEC.md:5:**Date:** 14 May 2026
docs/specs/PRODUCT-SPEC.md:8:- `intelforce-os-internal-business-plan.md` (9 May 2026)
docs/specs/PRODUCT-SPEC.md:9:- `intelforce-os-cortexos-24-7-upgrade-directive.md` (12 May 2026)
docs/specs/PRODUCT-SPEC.md:10:- `intelforce-os-temp-contract-deep-dive.md` (8 May 2026)
docs/specs/PRODUCT-SPEC.md:85:- **Output contract (Competitor Interception, real-time):** Within 5 minutes of a target-patch company posting a role through Hudson, Robert Walters, or any other competitor agency: Telegram fires — "Greenstone, you've placed there twice, 3 candidates ready, drafted outreach. Send tonight?"
docs/specs/PRODUCT-SPEC.md:110:#### R6. The Scribe — the call-to-context engine
docs/specs/PRODUCT-SPEC.md:112:- **Output contract:** Every call (Fathom, Fireflies, Ringover) gets parsed into ATS structured fields *and* tacit notes that don't fit any field: "client said they'd never hire from Bank X because of a 2019 grudge", "candidate's actual reason for leaving is the new line manager, not the salary". Tacit notes power every other agent's voice and judgement.
docs/specs/PRODUCT-SPEC.md:114:- **Time saved:** 30–60 min/day per consultant on call notes. The bigger value is the unlock for every other agent.
docs/specs/PRODUCT-SPEC.md:117:- **Per-tenant config:** transcript-source OAuth, ATS field-mapping rules, tacit-note retention policy, banned-extraction patterns (anything sensitive that shouldn't be captured).
docs/specs/PRODUCT-SPEC.md:182:Triggered by the April 2026 regulatory window — Joint & Several Liability for umbrella PAYE, six-year holiday-pay record-keeping, Fair Work Agency standing up. Different buyer (FD / Compliance Officer / Operations Director), different sales conversation, separate SKU. Same Intel Force OS platform.
docs/specs/PRODUCT-SPEC.md:187:- **Revenue story:** "First 2 weeks of every contract done correctly, every time. No PAYE surprises in week 6 because RTW was checked on day 1." Avoids £5k–£40k per botched onboarding (back-claimed PAYE plus penalties).
docs/specs/PRODUCT-SPEC.md:242:| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:279:        │   The Scribe captures    │    │  The Janitor keeps it    │
docs/specs/PRODUCT-SPEC.md:297:The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**
docs/specs/PRODUCT-SPEC.md:467:### 9.1 v1.0 (now → end of Q3 2026) — the closeable front office
docs/specs/PRODUCT-SPEC.md:469:Ships in time for the first 3 paid pilots in Q3 2026.
docs/specs/PRODUCT-SPEC.md:473:- The Scribe (the data spine)
docs/specs/PRODUCT-SPEC.md:480:### 9.2 v1.1 (Q4 2026 → Q1 2027) — the always-on suite at full strength
docs/specs/PRODUCT-SPEC.md:526:5. **Sourcing Scout (daytime)** — "Shortlist in 15 minutes instead of by end of week."
docs/specs/PRODUCT-SPEC.md:527:6. **The Scribe** — "Your firm's institutional memory finally lives somewhere."
docs/specs/PRODUCT-SPEC.md:549:| 1.0 | 14 May 2026 | Maddox + Claude | Final synthesis of internal business plan + 24/7 directive + temp deep dive + workflow analysis |
agents/recruitment/concierge/context.sh:6:#         supplement LANDED 2026-06-03 (commit a1bbcf6) — email_channel +
agents/recruitment/concierge/context.sh:90:# supplement has LANDED 2026-06-03 (commit a1bbcf6) — `email_channel` is
agents/recruitment/concierge/context.sh:134:# supplement has LANDED 2026-06-03 (commit a1bbcf6) — `operator_telegram_chat_id`
docs/specs/_archive-build-handoff.md:5:**Date:** 15 May 2026
docs/specs/_archive-build-handoff.md:300:1. Do we have at least one design partner who has said "yes I will pilot this in Q3 2026"? Y/N
docs/specs/_archive-build-handoff.md:328:git checkout -b agent/bullhorn-mcp        # or agent/janitor, agent/scribe, etc.
docs/specs/_archive-build-handoff.md:379:| 3 | **Scribe** | 6 | Fathom/Fireflies MCP + Bullhorn write | The post-call note that lands in Bullhorn within 10 min is the second-most-demoable result |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/_supplementary/execution-plan.md:41:The Build Plan described each component's purpose and architecture. For each one, you need a *developer-ready spec* — concrete enough that a dev can open a cursor and start writing the code without further back-and-forth. Twelve components total.
docs/_supplementary/execution-plan.md:246:  - *Purpose:* the state machine and orchestrator that turns "wizard complete" → "9 agents running in 15 minutes". Your core IP.
docs/_supplementary/execution-plan.md:518:  - *Prompt:* "Write the Status Page Setup Specification: platform choice (recommend Instatus or Statuspage), what to monitor (API, each core integration, control plane, vault service), incident communication templates, subscriber notification policy."
docs/_supplementary/execution-plan.md:541:  - *Prompt:* "Write the Voice Receptionist Full Specification: the Vapi platform configuration (assistants, tools, actions), the pre-call context injection (practice info, FAQs, protocols), the in-call escalation triggers, the post-call Claude Code agent that processes the call outcome, the Calendly/Cal.com booking flow, the FAQ training pipeline, the edge cases (accents, complaints, emergencies, out-of-hours), the testing framework (100+ test calls before launch)."
docs/_supplementary/execution-plan.md:580:"C" = one focused Claude session (roughly 30–60 minutes of generation + iteration). These estimates are for generating the *first draft* of an artifact. Add 20–50% for revisions, human review, and real-world validation.
docs/_supplementary/technical-strategy-v2.md:244:End-to-end under 15 minutes of compute time. Your human time: approve the voice profile in the wizard, review smoke-test outputs, kickoff call. Target: under 4 hours of your time per client.
docs/_supplementary/technical-strategy-v2.md:246:This is the IP. Not the agents. Not the dashboard. **The provisioning system that deploys 9 perfectly-configured agents in 15 minutes.**
docs/_supplementary/technical-strategy-v2.md:342:        2026-04-22-discovery.md  ← Fathom transcripts, tagged
docs/_supplementary/technical-strategy-v2.md:344:        2026-04-22-acme.md    ← output from Proposal Builder
docs/_supplementary/technical-strategy-v2.md:350:      2026-04-pricing-article.md
docs/_supplementary/technical-strategy-v2.md:352:      2026-04-pricing-linkedin.md
docs/_supplementary/technical-strategy-v2.md:353:      2026-04-pricing-instagram.md
docs/_supplementary/technical-strategy-v2.md:358:    2026-04-22.md             ← auto-generated daily rollup
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:3:**Generated:** 2026-05-24 by Intel Force OS Diagnostic agent (v0 — pre-W3 build).
docs/_supplementary/strategic-plan.md:126:1. **Anthropic has already blocked OAuth tokens from being used outside Claude Code** (January 2026 change). They will keep tightening. Your whole business breaks the day they do.
docs/_supplementary/strategic-plan.md:313:You have 2–3 months. Here's how you actually use them. This assumes you + one developer (hire the guy you mentioned, or a UK/EE contractor at £40–60/hr for ~20 hrs/week).
docs/_supplementary/strategic-plan.md:454:Force yourself to onboard one friendly client at week 6 (half-built, half-manual behind the scenes). Their pain will teach you more than any plan.
agents/recruitment/concierge/tools.yaml:115:  # Autosend bridge (D1-B Telegram shim per 2026-05-31 founder decision;
agents/recruitment/concierge/tools.yaml:116:  # package scaffold landed 2026-06-01 at commit 9b282d8). Per D1-B doc
docs/_supplementary/PRD-autonomous-agent.md:7:**Date**: 2026-03-16  
docs/_supplementary/PRD-autonomous-agent.md:15:A Claude Code instance that runs **permanently on your Mac** — waking up every morning, deciding what reel to make, building it start-to-finish, and texting you the result on Telegram. You review in 5 minutes, tap approve, and it stages it for publish. You are not involved in anything else.
docs/_supplementary/PRD-autonomous-agent.md:190:authority in AI business automation, requiring < 5 minutes of his time.
docs/_supplementary/PRD-autonomous-agent.md:871:// Step 4: Transcribe with Whisper
docs/_supplementary/PRD-autonomous-agent.md:872:export async function transcribeAudio(audioPath: string): Promise<WhisperTranscript> {
docs/_supplementary/PRD-autonomous-agent.md:1421:    timeoutInMilliseconds: 300000, // 5 minutes
docs/_supplementary/PRD-autonomous-agent.md:1557:  "lastUpdated": "2026-03-16T00:00:00Z",
docs/_supplementary/PRD-autonomous-agent.md:2058:  "name": "Extraction pipeline (download → transcribe → analyse)",
docs/_supplementary/PRD-autonomous-agent.md:2068:- [ ] Build `src/extraction/transcribe.ts` — Whisper API integration
docs/_supplementary/PRD-autonomous-agent.md:2095:  "task_id": "TASK-006",
docs/_supplementary/PRD-autonomous-agent.md:2116:  "dependencies": ["TASK-006"],
docs/_supplementary/PRD-autonomous-agent.md:2152:  "dependencies": ["TASK-006"],
docs/_supplementary/PRD-autonomous-agent.md:2218:  "task_id": "TASK-016",
docs/_supplementary/PRD-autonomous-agent.md:2239:  "dependencies": ["TASK-016"],
docs/_supplementary/PRD-autonomous-agent.md:2404:│   │   ├── transcribe.ts
docs/_supplementary/PRD-autonomous-agent.md:2530:3. TASK-004 to 006 — extraction pipeline, brief, HeyGen, orchestrator
docs/_supplementary/PRD-autonomous-agent.md:2621:**Daily Human Time Required**: < 5 minutes (review + approve/reject via Telegram)
docs/build-brief/00-MASTER-BRIEF.md:5:**Synthesis stance:** First principles. The build pack in `docs/build-pack/` is **ignored** per founder instruction. The CLAUDE.md currently in the repo describes paths, remotes, and red lines — those are kept. Everything else in this brief is rebuilt from the verified state of the two upstream repos (`grandamenium/cortextos`, `tarsclaw/intel-force-os-v2`), Karpathy's LLM-wiki pattern, and the recruitment product spec, ultraplan, and 24/7 directive.
docs/build-brief/00-MASTER-BRIEF.md:7:**Verified on:** 16 May 2026 against `cortextos@0.1.1` and the `intel-force-os-v2` repo HEAD.
docs/build-brief/00-MASTER-BRIEF.md:66:Everything in this section is verified against `grandamenium/cortextos@main` as of 16 May 2026. The handoff doc was right in spirit but had two assumptions that are wrong; corrections inlined.
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:356:   created_at: 2026-05-16T14:32:00Z
docs/build-brief/00-MASTER-BRIEF.md:357:   updated_at: 2026-05-16T14:32:00Z
docs/build-brief/00-MASTER-BRIEF.md:358:   provenance: [scribe-agent:call-2026-05-16-1432, janitor:bullhorn-2026-05-15]
docs/build-brief/00-MASTER-BRIEF.md:414:| **v1.1 — the wiki proper + today-view** | Q4 2026 | `/brain` (decisions feed) + `/brain/vault/[...path]` (read-only markdown render) + backlinks panel + `wiki-find.sh` + `wiki-history.sh` + `compile.ts` + `lint.ts` + full entity profile pages + wiki-link rendering + search UI |
docs/build-brief/00-MASTER-BRIEF.md:469:- [ ] Hetzner Falkenstein (FSN1) or Nuremberg (NBG1) VPS provisioned, LUKS-encrypted volume mounted at `/vault/`. Both are Hetzner eu-central locations with Schrems II EU jurisdiction; either acceptable. Hetzner has no UK data centre as of 2026-05-17 verification per `docs/runbooks/day-4-provisioning.md` §0.1.
docs/build-brief/00-MASTER-BRIEF.md:488:1. Do we have at least one design partner who has said "yes I will pilot this in Q3 2026"?
docs/build-brief/00-MASTER-BRIEF.md:597:| 3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | Post-call note in Bullhorn within 10 min — second-most-demoable |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:762:### 10.6 The ratification timeline
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
docs/build-brief/00-MASTER-BRIEF.md:996:| 1.0 | 16 May 2026 | Maddox + Claude | First-principles synthesis: verified against `cortextos@0.1.1` and `tarsclaw/intel-force-os-v2` HEAD; ignores the inherited build pack per founder instruction; integrates the Karpathy LLM-wiki pattern as the second-brain blueprint; corrects two earlier assertions about cortextOS internals; specifies the four-file `bus/kb-*.sh` shadow as the single brain-replacement seam. |
agents/recruitment/concierge/cycle.sh:235:# Reference: agent.md §4 Step 9 + ADR-007 RATIFIED 2026-05-31.
agents/recruitment/concierge/cycle.sh:267:# Reference: agent.md §4 Step 11 + D1-B founder decision (2026-05-31) +
agents/recruitment/concierge/cycle.sh:268:# docs/decisions/2026-05-31-d1-founder-decision.md §"Implementation surface"
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:3:**Generated:** 2026-05-24 by Intel Force OS Diagnostic agent (v0 — pre-W3 build).
docs/_supplementary/build-plan-original.md:246:| Client Onboarder | 4 | 8k in / 6k out | £0.15 | £0.60 |
docs/_supplementary/build-plan-original.md:449:- Discovery call was <15 minutes (not enough signal)
docs/_supplementary/build-plan-original.md:554:- Prospect replied with "unsubscribe" or hostile tone → immediately flag, no further follow-ups, add to exclusion list
docs/_supplementary/build-plan-original.md:566:- Unsubscribes per month (target <1%)
docs/_supplementary/build-plan-original.md:795:### Cost: £0.60/mo. Build: 1 week (lots of integrations).
docs/_supplementary/build-plan-original.md:900:The Claude Code side handles the **configuration and training**, not the live call. The live call runs on Vapi; when the call ends, Vapi webhooks the transcript and actions to your Claude Code webhook receiver, which triggers a post-call agent that:
docs/_supplementary/build-plan-original.md:1051:The system that turns "wizard completed" into "9 agents running in a fresh tenant container" in under 15 minutes of compute time.
docs/operations/decision-log.md:12:Established 2026-06-01 (W4 Day-26) as part of the priorities refactor (goal §1.2). Pre-refactor, all of this content lived in `.agents/current-priorities.md` itself (had grown to 1161 lines + accreted across 25 days). The refactor preserves every historical entry verbatim; only the surface presentation changed.
docs/operations/decision-log.md:16:## W4 Day-25 overnight (2026-05-31 → 2026-06-01) — autonomous Track-1 start ✓
docs/operations/decision-log.md:18:Founder went to sleep ~22:30 after running the Hays smoke. Claude executed the overnight goal (`docs/operations/goal-overnight-2026-05-31.md`) end-to-end:
docs/operations/decision-log.md:24:| `8315ab3` | `docs/operations/goal-overnight-2026-05-31.md` | overnight scope |
docs/operations/decision-log.md:33:- Report at `~/.ifos-local-vault/migration-test/diagnostic-reports/hays-plc-2026-05-31.md`
docs/operations/decision-log.md:34:- Archive at `docs/artefacts/diagnostic-hays-plc-2026-05-31.md`
docs/operations/decision-log.md:38:### Founder action board (AM 2026-06-01)
docs/operations/decision-log.md:49:| 6 | Bullhorn chase | ⏸ template in `docs/operations/founder-manual-playbook-2026-05-31.md` §4 |
docs/operations/decision-log.md:50:| 7 | Q1 LOI (Jack) | ⏸ **Trigger 1 fires 2026-06-03 (≤2 days)** |
docs/operations/decision-log.md:68:## W4 Day-25 evening (2026-05-31) — v0.3 migration APPLIED to live VPS ✓
docs/operations/decision-log.md:83:2. **Audit-row write fallback** — the tenancy audit's `decision_log` audit-row write to `tenant_slug='ifos-meta'` failed; fell back to JSONL at `logs/tenancy-audit/20260531T212059Z-49105/`. Likely the audit harness doesn't `SET LOCAL app.current_tenant='ifos-meta'` before the INSERT (RLS blocks the cross-tenant write). Worth fixing in the audit script for future runs; not blocking — the audit itself ran fully and the fallback captured the result.
docs/operations/decision-log.md:90:- **The new entities trigger validates v0.3 keys** (`employment_type`, `key_skills`, etc.) — Scribe field extraction at W6 will run against the live validator.
docs/operations/decision-log.md:93:### Founder action board (refreshed end-of-day 2026-05-31)
docs/operations/decision-log.md:100:| 4 | Apply v0.3 migration to live VPS | ✅ **APPLIED + tenancy audit 12/12** (Day-25 evening 2026-05-31) |
docs/operations/decision-log.md:102:| 6 | Bullhorn chase | ⏸ chase email template in `docs/operations/founder-manual-playbook-2026-05-31.md` §"Priority 4" |
docs/operations/decision-log.md:103:| 7 | Q1 LOI (Jack) | ⏸ Trigger 1 fires **2026-06-03 (3 days)** |
docs/operations/decision-log.md:106:## W4 Day-25 (2026-05-31) — founder decisions captured + W4 Track-1 /goal authored
docs/operations/decision-log.md:116:| 5 | Founder Decision D1 (autosend orange-tier) | **DELEGATED + TAKEN: D1-B (Telegram shim)** | `docs/decisions/2026-05-31-d1-founder-decision.md` |
docs/operations/decision-log.md:118:| 7 | Q1 LOI (Jack's lane) | PENDING — Trigger 1 fires 2026-06-03 | n/a (founder coordinates Jack) |
docs/operations/decision-log.md:120:| 9 | Fathom OR Fireflies signup | DEFERRABLE | gates W6 Scribe build |
docs/operations/decision-log.md:128:- Diagnostic Trigger 2 (deadline 2026-06-14) is now one founder action away from closure — register CH + Anthropic keys, run `bash scripts/run-diagnostic-smoke.sh --firm "Hays plc"`, done.
docs/operations/decision-log.md:130:## W4 Day-25 (2026-05-31) — Codex Round 1 (agent-bundle) verdict closed
docs/operations/decision-log.md:134:**RATIFIED (4):** diagnostic, janitor, scribe, concierge — each with minor advisories (2 closed; 1 was a false-positive about scribe ESC-catalogue line drift, verified at lines 324 + 441 are still accurate).
docs/operations/decision-log.md:144:| sourcing-scout agent.md | 2 (migration line 397→398; Q6 "New ADR-006" collision → "new ADR, number assigned at authoring time") | `c9fe293` |
docs/operations/decision-log.md:149:**Round 3 ran 2026-05-31 — verdict 8 RATIFIED / 1 REJECTED:**
docs/operations/decision-log.md:156:**Founder decision (2026-05-31): Fix + STOP — no Round 4.** Migration has had 3 round-trips (R1 → R2 → R3) and applying-and-re-running would be a 4th, crossing master brief §10.3 step 5 ≤2-cap further. Codex spelled out the exact `to_regclass` fix; it's applied at `0f4ce8d`. Re-ratification of the rollback path is deferred to its next natural touch (live VPS apply OR v0.4 supplement work) and recorded in the W4 backlog. Net effective state: **8/9 Codex-RATIFIED + 1 with the latest R3 fix applied = 9/9 in substance**.
docs/operations/decision-log.md:162:**Round 2 ran 2026-05-31 — verdict 6 RATIFIED / 3 REJECTED:**
docs/operations/decision-log.md:166:| 6 agent.md (diagnostic, janitor, scribe, cash-conductor, sourcing-scout, concierge) | **RATIFIED** ✓ | — |
docs/operations/decision-log.md:173:## W4 Day-21 (2026-05-27) — ratification remediation + harness fix
docs/operations/decision-log.md:175:**Root cause of the "stuck" state (three compounding issues):** (a) commit `75ccc5f` (2026-05-24) flipped statuses to RATIFIED prematurely; the R19 bilateral pass reverted them to Proposed, but THIS file was committed before R19 (`ff4155f`) and never updated — so it told an optimistic, stale story. (b) The `run-codex-ratification.sh` verdict-count parser counted numbered lines across the entire transcript, reporting 41/52/55 issues when the real counts were 2-5. (c) Those phantom counts made the 8 artefacts look catastrophically broken when they were ~4 mechanical fixes each.
docs/operations/decision-log.md:180:2. **29 real findings closed** across 8 artefacts (extracted from the 2026-05-25 agent-bundle run `*.output.md` files):
docs/operations/decision-log.md:182:   - **Janitor (4):** relative date→2026-05-25; §2.1→§2.2 cite; contractor dedup in §3; dedup approval model **[DECISION]**
docs/operations/decision-log.md:185:   - **Scribe (4):** Output-2 decision_log signature; validate_gate_a_fail 113→119; classifier-fail→hard Gate A **[DECISION]**; ESC_GATE_B_MISS in §6
docs/operations/decision-log.md:194:3. **Scribe tacit-note classifier failure → hard Gate A fail** (no Bullhorn attach), not a silent placeholder that "passes."
docs/operations/decision-log.md:195:4. **ADR-007 ULTRAPLAN amendment marked provisional** pending founder Accept (kept Status: Proposed; did NOT self-Accept — founder arbitrates per ADR-006 precedent).
docs/operations/decision-log.md:201:### Day-21 local quality gate (Codex-independent) — PASSED 2026-05-27
docs/operations/decision-log.md:229:6. `40f94c4 fix(scribe-r4)` — all 5 R3 residuals closed; missing `hh_decision_*` calls added at §4 Steps 3+7; Ringover explicitly v1.1+; autosend cite split (decision-doc vs runtime YAML); ESC_PROVIDER_FETCH_FAIL catalogue extension queued
docs/operations/decision-log.md:230:7. `26551c8 feat(ADR-007 + concierge-r4)` — ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted; analogue of ADR-006; closes Concierge R3 Finding 3 structurally. Step 11 `hh_decision_action` added. **Closes W4 founder-action queue item #3** (drafted; ratification gates Concierge Accepted).
docs/operations/decision-log.md:240:| Scribe | Pre-Build-Round-4-Bilateral-Applied | 5 | 0 (4 in `db56336` + 1 polish) | Codex R5 re-ratification |
docs/operations/decision-log.md:249:- **ADR-006 Diagnostic Gate A hybrid Accepted** (founder-arbitrated; closes Cat-1/Cat-ζ structural blocker)
docs/operations/decision-log.md:257:  - Scribe: R3 post-v0.3 (5 baseline, ~2 mechanical after R3 fix)
docs/operations/decision-log.md:262:**Commits this session:** ~45 commits across catalogues, dispositions, ADR-006, v0.3 supplement, 6 agent.md scaffolds + sibling files; all pushed to `origin/main`.
docs/operations/decision-log.md:268:- [x] **ADR-006 Diagnostic Gate A hybrid** — Accepted founder-arbitrated at commit `6d2d43e`; ULTRAPLAN line 496 in-band amendment at `aed9d3b`.
docs/operations/decision-log.md:276:3. **Future ADR — Concierge Gate A 30-min SLA hybrid** — **DRAFTED.** `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`. Analogue of ADR-006. Awaits Codex `review-architecture-decision` skill ratification + founder Accept.
docs/operations/decision-log.md:284:- DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 if no clean Diagnostic render by then
docs/operations/decision-log.md:285:- Today: 2026-05-25 (Day 20); **20 days runway**
docs/operations/decision-log.md:305:- [ ] **Design-partner outreach.** The SINGLE Q1 unblocker. Founder-side work; warm-path strategy when targets named; cold-path templates drafted now possible. Without this, kill criterion Trigger 1 fires 2026-06-03 (14 days from today 2026-05-20) and Week 0 escalates to PAUSE.
docs/operations/decision-log.md:331:- [ ] **Design-partner outreach.** The SINGLE Q1 unblocker for Week 1 named-agent-build slices. Co-founder Jack owns. Without this, kill criterion Trigger 1 fires 2026-06-03 (14 days from 2026-05-20).
docs/operations/decision-log.md:348:- [ ] **R7**: Voice corpus refresh cadence — new ADR-006 at Concierge W10 build OR addendum to v0.2 supplement at v1.0 schema close
docs/operations/decision-log.md:375:- ❌ Diagnostic W3-4 agent build (and all named v1.0 agent builds: Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/operations/decision-log.md:379:## Operational debts from Day 4 — CLOSED 2026-05-18 Monday morning
docs/operations/decision-log.md:397:### Day 14-19 (2026-05-24) — Week 3 polish + 5 agent.md scaffolds + Codex Round 4 v2 (all 14 steps complete; 6 RATIFIED pending founder arbitration)
docs/operations/decision-log.md:407:- `7730baa` (Step 9) Scribe agent.md (336 lines)
docs/operations/decision-log.md:415:- `3c69d86` codex-disagreement-2026-05-24-diagnostic-gate-a.md (5 issues; founder arbitration)
docs/operations/decision-log.md:427:| Scribe agent.md | REJECTED ~5-7 issues | Same |
docs/operations/decision-log.md:432:**The 5-category disposition framework** (in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`):
docs/operations/decision-log.md:465:- ADR-006 source-abstraction layer (per Sourcing Scout §9 Q6)
docs/operations/decision-log.md:470:- Scribe build
docs/operations/decision-log.md:472:**Trigger 2 status:** Diagnostic ratification needs founder arbitration; engineering work complete. 21-day buffer to 2026-06-14 deadline preserved.
docs/operations/decision-log.md:482:- **Step 9** (`7730baa`) — Scribe agent.md (336 lines) per ULTRAPLAN §8.1 A3 (W6 build wave)
docs/operations/decision-log.md:500:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: Proposed; ready for Codex Round 4 Phase 2
docs/operations/decision-log.md:507:| Scribe | W6 | A3 lines 515-527 |
docs/operations/decision-log.md:520:- ADR-006 source-abstraction layer (per Sourcing Scout §9 Q6)
docs/operations/decision-log.md:525:- Scribe build (depends on Bullhorn W + Fathom MCP)
docs/operations/decision-log.md:539:**Trigger 2 status (per `v1.0-kill-criterion.md` §2):** Diagnostic shipped end-to-end Day-13; Codex Round 4 Phase 1 ratification clears Trigger 2 well before 2026-06-14 deadline (currently 21 days buffer).
docs/operations/decision-log.md:541:### Day 13 (2026-05-24) — Diagnostic end-to-end pipeline live (Option C / ADR-005)
docs/operations/decision-log.md:547:- **`@ifos/web-scraper`** (`packages/utilities/web-scraper/`) — HTTP HEAD + first-N-lines fetch, disk cache, robots.txt respect (via robots-parser), in-process token-bucket rate limit (30/60s). 12/12 vitest unit tests + typecheck clean. Commit `860f29c`.
docs/operations/decision-log.md:556:**ADR-005 ratifies the sequencing change** (commit `e578354`): Week 3 repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build per ULTRAPLAN §10 Risk #2 contingency. Bullhorn-touching agents (Janitor W5+) gated on Bullhorn Sub-decisions A+B response (form submitted 2026-05-24) or 2026-06-10 force-fallback.
docs/operations/decision-log.md:558:**Trigger 2 status:** Diagnostic renders cleanly + Gate A passes — 21 days ahead of 2026-06-14 hard deadline.
docs/operations/decision-log.md:563:- Register for Companies House developer API key at https://developer.company-information.service.gov.uk/ (verified 2026-05-24)
docs/operations/decision-log.md:568:**Bullhorn form sent** 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (per `docs/operations/bullhorn-outreach-emails.md`). Response 2-5 business days. Earlier `partnerships@bullhorn.com` draft bounced — corrected by commits `dc15692` + `4f40444`.
docs/operations/decision-log.md:570:### Day 12 (2026-05-23) — Live foundation verified: migration green + tenancy audit 24/24 PASS
docs/operations/decision-log.md:621:### Day 11 evening (2026-05-22) — Live migration first-attempt: 4 Day-4 drifts surfaced + fixed
docs/operations/decision-log.md:639:### Day 11 evening (2026-05-22) — Diagnostic agent.md pre-build scaffold
docs/operations/decision-log.md:669:### Day 11 evening (2026-05-22) — Codex Round-2 remediation + Round 3
docs/operations/decision-log.md:686:### Day 11 (2026-05-22) — Codex Round 2 autonomous ratification closure
docs/operations/decision-log.md:696:- `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.7 appended with the 26 Round-2 verdicts
docs/operations/decision-log.md:705:### Day 9 (2026-05-20 evening) — Architecture + tenancy verification slice
docs/operations/decision-log.md:735:### Day 8 evening (2026-05-20) — Codex Round-1 remediation: 13 of 14 rejections incorporated
docs/operations/decision-log.md:740:- ADR-001/002/003 line 4: "review pending" → "founder decision logged 2026-05-16"
docs/operations/decision-log.md:743:- sequencing-target line 4: "Drafting" → "Accepted (Day 3, 2026-05-16)"
docs/operations/decision-log.md:745:- v1.0-kill-criterion: Trigger 1 date 2026-06-08 → 2026-06-03 (matches §1)
docs/operations/decision-log.md:763:- `codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` — counter-argues Codex's Decision/Consequences requirement on audit + runbook artefacts. Proposes skill softening = Founder Decision D5.
docs/operations/decision-log.md:764:- `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` — counter-argues Codex over-applying Day-7 Q3 gate to Week-1 prereq code (vs named agent-build slices). Line 95 wording sharpened.
docs/operations/decision-log.md:767:- `2026-05-20-codex-round-1-founder-decisions.md` — 5 founder decisions surfaced (D1-D5):
docs/operations/decision-log.md:776:**Codex Day-7 manifest:** updated with per-artefact Round-1 verdict + disposition (new §1.5 section in `docs/decisions/2026-05-18-codex-ratification-manifest.md`).
docs/operations/decision-log.md:778:**Next (superseded by Day 11 close):** Round 2 ran 2026-05-22 and closed 17 RATIFIED / 9 REJECTED of 26.
docs/operations/decision-log.md:780:### Day 8 (2026-05-20) — Phases 3-5: hook-helpers + autosend policy + vertical-schema v0.2 + voice-loader
docs/operations/decision-log.md:823:### Day 8 (2026-05-20) — Phase 2: packages/agent-renderer scaffold
docs/operations/decision-log.md:848:### Day 8 (2026-05-20) — Phase 1: renderer prereqs + ESC catalogue
docs/operations/decision-log.md:860:### Day 7 (2026-05-20) — Single-sentence test 3-of-5 + atomic-correction commit + Codex ratification manifest
docs/operations/decision-log.md:868:| 1 | Design partner pilot Q3 2026 LOI? | **NO** | Zero pipeline; Risk #3 High; Trigger 1 fires 2026-06-03 |
docs/operations/decision-log.md:869:| 2 | Primitives 1, 4, 5 working today? | **YES with caveat** | Primitives 4+5 confirmed shipped+tested; primitive 1 documented "flaky-under-load" per Risk #1 (operationally sound for v1.0 6-agent fleet) |
docs/operations/decision-log.md:885:   - `docs/decisions/2026-05-18-day-7-single-sentence-test.md` (Accepted, factual recording)
docs/operations/decision-log.md:886:   - `docs/decisions/2026-05-18-codex-ratification-manifest.md` (Reference, 19+ items queued)
docs/operations/decision-log.md:890:**Q1 unblocker:** design partner LOI by 2026-06-03 (14 calendar days). Single structural unblocker for Week 1 named agent-build slices.
docs/operations/decision-log.md:896:### Day 6 evening (2026-05-18) — Citation audit + operational hygiene protocol
docs/operations/decision-log.md:902:- **`docs/runbooks/operational-hygiene-protocol.md`** (340 lines, In Force from 2026-05-18) — codifies:
docs/operations/decision-log.md:914:- **All 15 instances corrected** on 2026-05-18 Day 6 evening:
docs/operations/decision-log.md:924:**Grade outcome:** operational hygiene + length discipline + citation accuracy all bumped to A — structurally, by codifying the rules. Historical Days 0-6 grades unchanged (the work happened as it happened); next session that touches credentials / runbooks / drafts / citations starts from A-grade discipline.
docs/operations/decision-log.md:926:### Day 6 (2026-05-18) — Recruitment vertical schema v0.1
docs/operations/decision-log.md:936:  - Agent × Entity R/W matrix across all 6 v1.0 agents (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) — cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3
docs/operations/decision-log.md:956:### Day 5 (2026-05-18) — Auto-send safety policy + v1.0 kill criterion + live schema migration
docs/operations/decision-log.md:974:  - **Trigger 1 (DESIGN-PARTNER-BY-WEEK-2):** fires end-of-day 2026-06-03 (Wednesday) if no signed LOI — PAUSE state, founder pivots to acquisition full-time
docs/operations/decision-log.md:983:- `docs/RISK-REGISTER.md` — Risk #3 escalated Medium → High; tripwire now references kill criterion Trigger 1 + concrete trigger date 2026-06-03
docs/operations/decision-log.md:997:### Day 4 (2026-05-17) — Hetzner VPS + LUKS + Postgres 16 + RLS gate passed
docs/operations/decision-log.md:1033:- `docs/RISK-REGISTER.md` — Risk #7 edit count 8 → 9 (Hetzner NBG1 wording); new Risk #8 LUKS manual unlock single-point-of-failure (Low/Medium-High, v1.2+ TPM/key-server mitigation); 2026-05-17 log entry
docs/operations/decision-log.md:1036:### Days 1, 1-evening, 2, 3, 3-evening (all 2026-05-16)
docs/operations/decision-log.md:1097:## Day 4 tightening (landed 2026-05-17, see Shipped)
docs/operations/decision-log.md:1103:**11 of 12 edits applied** in atomic-correction commit `0e5b2b4` on 2026-05-20. Edit 11 dropped (already-executed live SQL migration is its own audit trail). Master brief is fully reconciled. Two side effects flagged in commit message for Codex review (Edit 1 col 4 reframe + Edit 4 row merge).
docs/operations/decision-log.md:1115:9. **Hetzner location (NEW Day 4 2026-05-17; scope corrected Day-6 citation audit 2026-05-18)** — Master brief §6 Day 4 line 477: "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations". Verified during Day-4 execution: Hetzner has no UK data centre; NBG1 used because FSN1 was unavailable at provisioning time. Source: Day-4 runbook §0.1 + §12 deviation 3. (Earlier drafts also cited §10.4 as a co-occurring Hetzner/cost reference; verified during 2026-05-18 citation audit that §10.4 is the Codex exclusion list and contains no Hetzner or cost-target content. §10.4 reference dropped.)
docs/operations/decision-log.md:1116:10. **Day-5 path drift (NEW Day 5 2026-05-18)** — Master brief §6 Day 5 lines 484-485: paths `docs/auto-send-safety-policy.md` and `docs/v1-kill-criterion.md` → `docs/decisions/autosend-safety-policy.md` and `docs/decisions/v1.0-kill-criterion.md` per repo convention since Day 0 (matching ADR-001/-002/-003 + bullhorn + sequencing-target + brain-ui-scope). Source: Day-5 autosend policy header + kill criterion header.
docs/operations/decision-log.md:1117:11. **decision_log.phase enum expansion (NEW Day 5 2026-05-18)** — Day-4 runbook §6.4 + executed migration on `ifos-v2-prod-01`: phase enum expanded from 5 values to 6 (added `'render'` for renderer audit per `ESC_RENDERER_FAILED` contract in `agent-bundle-renderer-design.md` §4). Live SQL migration committed alongside this manifest entry; runbook v1.1 revision note attached.
docs/operations/decision-log.md:1125:Per master brief §10.6 first ratification run — Day 7 added items 20 + 21 + the landed atomic-correction commit `0e5b2b4`. Total: 21 items + 1 commit. **Execution deferred** to Week 0 extension period (skills + Q1 unblocker both required first). See `docs/decisions/2026-05-18-codex-ratification-manifest.md` §3 + §4 for the gap + schedule.
docs/operations/decision-log.md:1138:12. **Day 4 close commit** — runbook §12 deviation log (20 deviations + 8 v1.1 revisions) + RISK-REGISTER #8 LUKS-unlock-SPOF + state-file updates — NEW Day 4 evening 2026-05-17
docs/operations/decision-log.md:1142:16. **`docs/decisions/autosend-safety-policy.md`** (Status: Proposed) — NEW Day 5 morning 2026-05-18
docs/operations/decision-log.md:1143:17. **`docs/decisions/v1.0-kill-criterion.md`** (Status: Proposed) — NEW Day 5 morning 2026-05-18 + Day-5 close commit (includes live Postgres schema migration; Risk #3 escalation; state-file updates)
docs/operations/decision-log.md:1144:18. **`docs/verticals/recruitment/vertical-schema.yaml`** (Status: Proposed) — NEW Day 6 2026-05-18 (8 entities, 89 fields, 10 relationships, agent R/W matrix, Bullhorn mapping, 12 open_questions)
docs/operations/decision-log.md:1145:19. **`docs/runbooks/operational-hygiene-protocol.md`** (Status: In Force) — NEW Day 6 evening 2026-05-18 (Path A/D credential protocols, no-defensive-additions rule, length calibration methodology, citation accuracy discipline, Day-4-6 audit findings)
docs/operations/decision-log.md:1146:20. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** (Status: Reference) — NEW Day 7 2026-05-20 (this manifest itself; lists 19+ ratification queue items + gap + schedule)
docs/operations/decision-log.md:1147:21. **`docs/decisions/2026-05-18-day-7-single-sentence-test.md`** (Status: Accepted, factual recording) — NEW Day 7 2026-05-20 (3 of 5 YES result + Week 0 extension protocol)
docs/operations/decision-log.md:1148:22. **Atomic-correction commit `0e5b2b4`** — LANDED Day 7 2026-05-20 (`docs: master brief reconciliation — 11 edits batch-applied`); two side effects flagged for Codex review per commit message
docs/operations/decision-log.md:1157:- **Day 2 verified Bullhorn finding** (load-bearing for Week 1-2): Bullhorn public REST API documentation describes **no webhook / subscription / event-stream mechanism** — pull-only model for v1.0. Per-tenant 5-minute polling cycle is the Concierge default. Marketplace-tier subscription verification is a v1.1+ commercial track
docs/operations/decision-log.md:1159:- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
docs/operations/decision-log.md:1162:- Day 4 carry-forward: ~~four consolidated Postgres tightenings~~ **LANDED 2026-05-17** in §6 of Day-4 execution (see Shipped)
docs/operations/decision-log.md:1164:- **Day 4 finding (2026-05-17):** Hetzner has no UK data centre — NBG1 used as equivalent. Surfaced as 9th atomic-correction edit. Functionally equivalent: same Hetzner eu-central zone, Schrems II EU jurisdiction, ~25-30ms UK latency.
docs/operations/decision-log.md:1165:- **Day 4 LUKS rotation pattern (2026-05-17):** Path B exposure (LUKS passphrase entered chat for ifos-unlock end-to-end test) closed via `cryptsetup luksChangeKey` with VPS-generated new passphrase + `--test-passphrase` verification. Pattern documented in runbook §12 deviation 20. v1.1 runbook revision: investigate paste-once-and-cache helper that doesn't require chat exposure. Lesson: Path A protocol cost (~90s of founder time per interactive step) is the right trade-off vs Path B (chat exposure + post-hoc rotation).
docs/operations/decision-log.md:1166:- **Day 4 Path D pattern (2026-05-17):** New protocol for VPS-side credential generation that never enters chat context. Used for ifos_app password in §5.4: `openssl rand -base64 24` on VPS → `/vault/.ifos_app_password.tmp` (LUKS-encrypted, mode 0600) → `CREATE ROLE` via psql stdin heredoc → founder retrieves at convenience. Reusable for future password generation operations.
docs/operations/decision-log.md:1170:## Day 27 — 2026-06-02 (Codex closure + Bullhorn pivot + Proxycurl handling)
docs/operations/decision-log.md:1172:A full chapter closed today: 13 Codex ratification rounds across clusters F, Fbis, G; one strategic vendor pivot (Bullhorn marketplace deferred); one materialised-but-mitigated vendor risk (Proxycurl shutdown). The cluster F + Fbis + G arc earned its own decision-doc at `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` covering the partial-ratification outcome (1 ratified + 5 proposed-with-disagreement-on-file across 6 artefacts).
docs/operations/decision-log.md:1178:2. **Bullhorn marketplace deferral (Sub-decision A RESOLVED).** Partner form requires ≥2 live customers; IFOS is pre-pilot (0 live + 1 LOI in active negotiation); marketplace ~$5-25k/yr partner fees + certification overhead not justified at ≤3-pilot scale where founder-led direct sales doesn't need marketplace distribution. v1.0 path = direct API per-tenant OAuth (auth-code flow; each tenant Bullhorn admin authorises IFOS as a connected app). Marketplace re-evaluated at v1.1+ scale (3+ live pilots, marketplace-as-customer-acquisition-channel viable). Founder pivoted 2026-06-02 from partnerships form to Bullhorn developer-support route at `developer.bullhorn.com` for the technical question (Sub-decision B). RISK 2 severity Medium → Low; ADR-005 framing extended. See `docs/decisions/bullhorn-integration-path.md` Sub-decision A RESOLVED row (commit `f13cc15`) for the full reasoning.
docs/operations/decision-log.md:1182:4. **Partial-ratification framework as a repeatable build pattern.** Disagreement docs at `docs/decisions/codex-disagreement-2026-06-02-*.md` (5 docs total across cluster F + Fbis + G) established the shape: artefact-Status moves to "Proposed-with-disagreement-on-file"; disagreement doc names the issue, the counter-argument, the re-trigger conditions, and what would change the call. This pattern can be reused for any future Codex round where the marginal value of round N+1 is low relative to its cost. Build progress is unblocked at the disagreement-doc-in-tree state; cluster re-runs happen when the natural trigger (build slice, vendor decision, skill hardening) fires.
docs/operations/decision-log.md:1186:1. `docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md` — QB R3+R4 counter-argument (commits `f9e85d8` + `497fa0c`)
docs/operations/decision-log.md:1187:2. `docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md` — OB R4 counter-argument (commit `497fa0c`)
docs/operations/decision-log.md:1188:3. `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` — combined Fbis + G hard-stop (commit `c189eb0`)
docs/operations/decision-log.md:1189:4. `docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md` — R3 work justification (commit `587b2ae`)
docs/operations/decision-log.md:1204:- Q1 LOI with Jack → unblocks Trigger 1 (fires 2026-06-03)
docs/operations/decision-log.md:1210:## Day 34 — 2026-06-03 (W5 CLOSED — 7 phases shipped in marathon mode)
docs/operations/decision-log.md:1212:W5 closed today after a 7-phase marathon /goal session. All 5 v1.0 agent bundles (Cash Conductor + Concierge + Janitor + Scribe + Sourcing Scout) now have full SKELETON tiers landed (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures + agent.md Reading-discipline note). v0.4 schema supplement LIVE on production VPS. 3 new MCP packages scaffolded (@ifos/bullhorn + @ifos/workos + @ifos/granola). W5 deliverables match `docs/operations/goal-week-5-execution-plan.md` §1 success-state criteria.
docs/operations/decision-log.md:1216:1. **Marathon-mode /goal pattern with checkpoint-gated phases.** Founder explicitly requested marathon mode (20h envelope) after the per-day pacing established 2026-06-02 evening. The marathon /goal (`w5-w6-marathon-phases-6-through-9`) introduced a CHECKPOINT discipline between phases: after each phase completion, mandatory re-read of CLAUDE.md + current-priorities + relevant agent.md for drift signals (citation drift / capability set mismatch / ESC code drift / repeated typos). STOP conditions explicit (tests red after 1 fix round, boundary violation, agent.md edit beyond Reading-discipline note, context-decay signals, founder live-API or commercial-signup gate). Pattern worked: Phase 6 completed cleanly; CHECKPOINT 1 detected no drift; Phase 7 surfaced one pre-existing test red HONESTLY rather than attempting an out-of-scope fix; founder gets the call on whether to proceed to Phase 8.
docs/operations/decision-log.md:1218:2. **Pre-existing test red surfaced honestly rather than push-through-fixed.** Phase 7 smoke sweep surfaced 1 failing test in `@ifos/diagnostic-generator` `tests/generate.test.ts` — last touched 2026-06-01 commit `2688b6a`. Root cause: LLM non-determinism. The test's fake firm name "Test Anchor Firm" triggers the LLM's legitimate disclaimer pattern ("> Before I go further..."); the test regex `/Hi.*?Test Anchor Firm|Hi —/` doesn't match. This is a brittle test against LLM output that's been red since 2026-06-01 but wasn't caught by per-package test sweeps that only counted the recently-changed packages. Per Karpathy discipline (surgical changes; touch only what the task requires) and /goal STOP rules (tests red → STOP, surface), did NOT attempt to fix in Phase 7. Three fix paths queued for a future session: (a) relax the test regex to accept the disclaimer pattern, (b) mock the LLM call to return a deterministic "Hi..." opener, (c) use a real firm name in the test fixture. Honest-signal pattern preserved.
docs/operations/decision-log.md:1220:3. **Vendor delta documentation pattern for agent.md ↔ deployed-reality drift.** Three agent bundles (Scribe + Sourcing Scout + earlier Concierge) have explicit deltas between their RATIFIED agent.md (CONTRACT) and the deployed SKELETON (vendor pivots, deferred sources, env-var fallbacks). The Reading-discipline note pattern (originated 2026-06-02 per Codex Fbis-R3 closure for CC + Concierge) extended in this session to document not just the SKELETON-vs-CONTRACT gap but the specific deltas (Scribe: webhook → polling per Granola pivot; Sourcing Scout: 4 sources → 3 active per Proxycurl shutdown; both: env-var fallbacks vs canonical SELECT path even though v0.4 supplement made the schema-clean paths available). W6+ ratification updates each agent.md to match deployed reality.
docs/operations/decision-log.md:1230:### Founder gates queued for W6+
docs/operations/decision-log.md:1232:- Bullhorn dev-support reply (~by 2026-06-09) → unblocks live `@ifos/bullhorn` integration tests
docs/operations/decision-log.md:1233:- Q1 LOI with Jack — Trigger 1 fired 2026-06-03; founder confirms "on track"
docs/operations/decision-log.md:1234:- Commercial signups (Reed + CV-Library + Bullhorn-developer-account + Xero + QuickBooks + TrueLayer + Granola browser OAuth + WorkOS staging) per `docs/operations/founder-api-signups-2026-06-03.md`
docs/operations/decision-log.md:1238:### W6 /goal shape
docs/operations/decision-log.md:1240:W6 transitions from SKELETON scaffolding to LIVE wiring. Each agent bundle's TODO(W6+) markers get replaced with real `@ifos/<package>` calls once commercial creds land. The W6 execution plan `docs/operations/goal-week-6-execution-plan.md` (drafted Phase 9 of this marathon — pending CHECKPOINT 2 founder ack) defines per-phase shape.
agents/recruitment/concierge/agent.md:3:**Status:** Proposed-with-disagreement-on-file (`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` — bundle-layer Codex ratification deferred to W10-13 build slice; contract-layer ratification was achieved in W3 cluster E).
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim per `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Concierge consumer wiring landed (commits `669a4f4` + `9ec2bd6`). Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) + v0.4 schema supplement adding `operator_telegram_chat_id` + `email_channel` to the `tenant_adapters.config` allowlist (per D1-B decision-doc §Implementation surface item 5) — see §10.
agents/recruitment/concierge/agent.md:6:**Reading-discipline note (added 2026-06-02 per Codex Fbis-R3 closure):** this `agent.md` is the **CONTRACT** that the W10-13 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `669a4f4` + `9ec2bd6` + `524bac6` + `8ba3723` + `eb1f884` per Day-26 evening + R-round closures); they carry `TODO(W10-13)` markers throughout that the W10-13 build slice replaces with live implementation matching the contract below. **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON cycle.sh emits only minimal trigger/output markers — the yellow-tier + orange-tier audit rows the contract names are NOT yet emitted at runtime.** The SKELETON `context.sh` uses **env-var fallbacks** today (`IFOS_FORCE_EMAIL_CHANNEL`, `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID`) — the `TODO(W10-13)` markers documenting future `tenant_adapters.config` reads are gated on a v0.4 schema supplement landing FIRST (those keys are NOT in the v0.3 allowlist; the validator would hard-fail). Don't read agent.md as a description of running code; read it as the spec the W10-13 build slice implements after the v0.4 supplement lands.
agents/recruitment/concierge/agent.md:7:**Date:** 2026-05-24.
agents/recruitment/concierge/agent.md:19:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:254:    → per Founder Decision D1 (selected 2026-05-31 as D1-B — Telegram shim per `docs/decisions/2026-05-31-d1-founder-decision.md`; v1.1+ upgrade path to D1-A queued):
agents/recruitment/concierge/agent.md:282:      autosend-policy.yaml (registered 2026-06-02 per Codex Fbis-R1 closure;
agents/recruitment/concierge/agent.md:330:**Honesty note (updated 2026-06-02 per Codex Fbis-R3 closure):** `agents/recruitment/concierge/validate.sh` **EXISTS as SKELETON** (committed `524bac6` on 2026-06-01) — the 5 Gate A checks G1-G5 are defined as TODO(W10-13) markers inside the SKELETON validate.sh; the W10-13 build slice replaces the TODOs with live impl per the contract above. The §5 contract describes what validate.sh's TODOs will become; the SKELETON file structurally exists and passes shellcheck CLEAN today but does not yet enforce the checks at runtime.
agents/recruitment/concierge/agent.md:410:| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
agents/recruitment/concierge/agent.md:419:| **Founder Decision D1 (autosend orange-tier path) ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md` | ✅ ACCEPTED |
agents/recruitment/concierge/agent.md:420:| **Autosend bridge package scaffold** — `@ifos/autosend-bridge-telegram` lib + types + tests landed 2026-06-01 (commit `9b282d8`); Concierge consumer wiring at cycle.sh Step 11 landed (commits `669a4f4` + `9ec2bd6`) | ✅ SCAFFOLDED (Concierge side) |
agents/recruitment/concierge/agent.md:447:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
agents/recruitment/concierge/agent.md:473:- **✅ ADR-007 (Concierge Gate A 30-min SLA hybrid) ACCEPTED + RATIFIED** — Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3 per `.codex/ratification/review-architecture-decision.md` skill (commit `c862c77`). Closes the documented deviation from ULTRAPLAN A6 line 566 wording; agent.md's Gate B framing of the 30-min SLA is now the canonical disposition. This Status-flip blocker is satisfied.
agents/recruitment/concierge/agent.md:474:- ✅ **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`; package scaffold + Concierge consumer wiring landed 2026-06-01. NO LONGER a Proposed→Accepted blocker. The autosend-bridge production wiring + v0.4 schema supplement are W10-13 build-slice deliverables (Accepted→In-Force blockers, not Proposed→Accepted)

exec
/bin/zsh -lc 'rg -n "location|current_role|notice_period_weeks|salary_expectation_min|salary_expectation_max|employment_type|key_skills|decision_authority|preferred_channel|next_action_target_date|salary_min|salary_max|start_date_target|role_type|must_haves|nice_to_haves|deal_breakers|start_date|placement_status|week_1_status_vault_path|satisfaction_signal|headcount_growth_signal_text|hiring_velocity_band|decision_window_text|tenant_adapters|bullhorn_corporation_id|granola_workspace_id" docs/verticals/recruitment -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:1:# IFOS recruitment vertical schema v0.4 — tenant_adapters.config keys for
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:9:# v0.4 is an ADDITIVE-ONLY tenant_adapters.config extension. It does NOT
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:15:# tenant_adapters at runtime, replacing the IFOS_FORCE_* env-var fallbacks
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:41:  v0.4 scope is INTENTIONALLY NARROW: 5 new tenant_adapters.config keys, no
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:60:  granola_workspace_id the higher-priority addition (W6 Scribe needs the
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:65:# §1 — tenant_adapters.config additions (5 new top-level keys)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:68:# Each key is hard-fail-on-unknown via the validate_tenant_adapters_config_v0_4
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:72:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:85:      tenant_adapters WHERE tenant_slug=$1.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:117:      tenant_adapters read path. The TODO(W10-13) marker in context.sh
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:146:  granola_workspace_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:162:      (mode 0600); writes workspace_id to tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:172:  bullhorn_corporation_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:204:    None. The 14 v0.3 entity field additions (employment_type, key_skills,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:205:    linkedin_url, preferred_channel, next_action_target_date, must_haves,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:206:    nice_to_haves, deal_breakers, placement_status, week_1_status_vault_path,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:207:    satisfaction_signal, headcount_growth_signal_text, hiring_velocity_band,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:208:    decision_window_text) carry forward verbatim. The
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:237:    - v0.3 migration applied (validate_tenant_adapters_config_v0_3 trigger active)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:246:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_4() —
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:249:      granola_workspace_id, bullhorn_corporation_id). Per-key type validation
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:252:      DROP TRIGGER validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:253:      CREATE TRIGGER validate_tenant_adapters_config_v0_4 (re-bind).
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:255:      DROP FUNCTION validate_tenant_adapters_config_v0_3() (no longer
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:298:        Yes — mirror tier into tenant_adapters.config so consumer code can
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:316:        services all tenant orgs. CURRENT v0.4 behavior (no tenant_adapters
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:328:    question: Should bullhorn_region be a tenant_adapters.config key?
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:352:  read per-tenant identifiers from tenant_adapters.config — but the v0.3
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:353:  validate_tenant_adapters_config_v0_3 trigger hard-fails on any of the
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:364:      granola_workspace_id without a second supplement.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:366:      from tenant_adapters at runtime.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:17:# its §3 narrative with canonical v0.1/v0.2/v0.3 field names (current_role vs
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:18:# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:20:# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:59:      employment_type:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:72:      key_skills:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:107:      preferred_channel:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:120:      next_action_target_date:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:134:      must_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:148:      nice_to_haves:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:160:      deal_breakers:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:175:      placement_status:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:190:      week_1_status_vault_path:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:210:      satisfaction_signal:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:225:      headcount_growth_signal_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:238:      hiring_velocity_band:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:251:      decision_window_text:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:284:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:285:#     ONLY; decision_authority remains v0.1-owned by founder/v1.1 Triage)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:286:#   - Scribe Brief: R → R+W (writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:287:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:352:  #   candidate.employment_type grants Scribe: W (Scribe writes employment_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:404:    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:495:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:502:      - Scribe (R+W)       # v0.3 UPGRADED — writes must_haves + nice_to_haves + deal_breakers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:507:      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:918:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:947:  Q1_employment_type_enum_completeness:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:948:    question: Are 6 employment_type enum values sufficient for UK recruitment?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:951:        Keep 6 values as in §1.candidate.employment_type — perm, contract,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:962:  Q2_key_skills_max_length:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:972:  Q3_placement_status_enum_lifecycle:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:973:    question: 6-state placement_status enum maps to Bullhorn's native state machine?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:977:      C: Add a mapping table (auxiliary) — placement_status_mapping with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1028:      the v0.3-added fields (employment_type, key_skills, preferred_channel,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1029:      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1030:      placement_status, week_1_status_vault_path, satisfaction_signal,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1031:      headcount_growth_signal_text, hiring_velocity_band, decision_window_text)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1034:      fields outside v0.3 scope (current_role_title vs v0.1 current_role;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1035:      seniority — not yet in schema; brief.start_date should be
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1036:      start_date_target; opportunity.sector — not yet in schema). These
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1042:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.yaml:104:      current_role:
docs/verticals/recruitment/vertical-schema.yaml:116:      salary_expectation_min:
docs/verticals/recruitment/vertical-schema.yaml:120:      salary_expectation_max:
docs/verticals/recruitment/vertical-schema.yaml:124:      location:
docs/verticals/recruitment/vertical-schema.yaml:128:        notes: Free-text city/region for v0.1. Structured location pending v1.1.
docs/verticals/recruitment/vertical-schema.yaml:133:      notice_period_weeks:
docs/verticals/recruitment/vertical-schema.yaml:149:      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
docs/verticals/recruitment/vertical-schema.yaml:316:      decision_authority:
docs/verticals/recruitment/vertical-schema.yaml:366:      role_type:
docs/verticals/recruitment/vertical-schema.yaml:371:      salary_min:
docs/verticals/recruitment/vertical-schema.yaml:376:      salary_max:
docs/verticals/recruitment/vertical-schema.yaml:388:      location:
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:442:      start_date:
docs/verticals/recruitment/vertical-schema.yaml:819:  Q5_contact_decision_authority_granularity:
docs/verticals/recruitment/vertical-schema.yaml:821:    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:246:    IF d ? 'employment_type' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:247:      IF (d->>'employment_type') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:250:        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:254:    IF d ? 'key_skills' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:255:      IF jsonb_typeof(d->'key_skills') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:256:        RAISE EXCEPTION 'key_skills must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:258:      IF jsonb_array_length(d->'key_skills') > 20 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:259:        RAISE EXCEPTION 'key_skills max length 20 (got %)', jsonb_array_length(d->'key_skills');
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:262:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'key_skills') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:264:          RAISE EXCEPTION 'key_skills items must be strings; got %', jsonb_typeof(arr_item);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:282:    IF d ? 'preferred_channel' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:283:      IF (d->>'preferred_channel') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:286:        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:290:    IF d ? 'next_action_target_date' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:291:      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:292:        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:295:      IF d->>'next_action_target_date' IS NOT NULL THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:297:          PERFORM (d->>'next_action_target_date')::date;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:299:          RAISE EXCEPTION 'next_action_target_date must parse as ISO-8601 date (YYYY-MM-DD); got: %', d->>'next_action_target_date';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:307:    IF d ? 'must_haves' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:308:      IF jsonb_typeof(d->'must_haves') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:309:        RAISE EXCEPTION 'must_haves must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:311:      IF jsonb_array_length(d->'must_haves') > 15 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:312:        RAISE EXCEPTION 'must_haves max length 15';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:314:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:316:          RAISE EXCEPTION 'must_haves items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:321:    IF d ? 'nice_to_haves' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:322:      IF jsonb_typeof(d->'nice_to_haves') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:323:        RAISE EXCEPTION 'nice_to_haves must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:325:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'nice_to_haves') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:327:          RAISE EXCEPTION 'nice_to_haves items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:332:    IF d ? 'deal_breakers' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:333:      IF jsonb_typeof(d->'deal_breakers') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:334:        RAISE EXCEPTION 'deal_breakers must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:336:      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:338:          RAISE EXCEPTION 'deal_breakers items must be strings';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:346:    IF d ? 'placement_status' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:347:      IF (d->>'placement_status') NOT IN (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:350:        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:354:    IF d ? 'week_1_status_vault_path' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:355:      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:356:        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:358:      IF d->>'week_1_status_vault_path' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:359:         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:360:        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:362:      IF d->>'week_1_status_vault_path' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:363:         AND length(d->>'week_1_status_vault_path') > 200 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:364:        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:368:    IF d ? 'satisfaction_signal' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:369:      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:370:        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:377:    IF d ? 'headcount_growth_signal_text' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:378:      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:379:        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:381:      IF d->>'headcount_growth_signal_text' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:382:         AND length(d->>'headcount_growth_signal_text') > 280 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:383:        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:387:    IF d ? 'hiring_velocity_band' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:388:      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:389:        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:393:    IF d ? 'decision_window_text' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:394:      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:395:        RAISE EXCEPTION 'decision_window_text must be string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:397:      IF d->>'decision_window_text' IS NOT NULL
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:398:         AND length(d->>'decision_window_text') > 280 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:399:        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:419:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:453:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:513:  -- schema (items.type=string) and the key_skills/must_haves element checks above.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:529:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:531:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:532:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:534:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:87:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:91:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:93:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:95:-- tenant_adapters config validation trigger.
docs/verticals/recruitment/migrations/v0.4-to-v0.5.sql:25:--   - validate_tenant_adapters_config_v0_4 function + trigger: unchanged
docs/verticals/recruitment/migrations/v0.4-to-v0.5.sql:33:--   - v0.4 migration applied (validate_tenant_adapters_config_v0_4 trigger exists)
docs/verticals/recruitment/migrations/v0.4-to-v0.5.sql:50:    SELECT 1 FROM pg_trigger WHERE tgname = 'validate_tenant_adapters_config_v0_4'
docs/verticals/recruitment/migrations/v0.4-to-v0.5.sql:52:    RAISE EXCEPTION 'v0.4 validate_tenant_adapters_config_v0_4 trigger missing; run v0.3-to-v0.4.sql first';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:9:-- ADDITIVE-ONLY. v0.4 extends the validate_tenant_adapters_config_v0_3 trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:14:--   - granola_workspace_id       (per-tenant Granola workspace identifier; W6+ Scribe)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:15:--   - bullhorn_corporation_id    (per-tenant Bullhorn corporation identifier)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:30:--   - v0.3 migration applied (validate_tenant_adapters_config_v0_3 trigger exists)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:47:    SELECT 1 FROM pg_proc WHERE proname = 'validate_tenant_adapters_config_v0_3'
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:49:    RAISE EXCEPTION 'v0.3 validate_tenant_adapters_config_v0_3 function missing; run v0.2-to-v0.3.sql first';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:52:    SELECT 1 FROM pg_trigger WHERE tgname = 'validate_tenant_adapters_config_v0_3'
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:54:    RAISE EXCEPTION 'v0.3 validate_tenant_adapters_config_v0_3 trigger missing; run v0.2-to-v0.3.sql first';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:66:-- §2 — Create v0.4 tenant_adapters.config validation function
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:77:--   - granola_workspace_id:      string (no format constraint; opaque per-tenant identifier)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:78:--   - bullhorn_corporation_id:   string matching '^[0-9]+$'
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:80:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_4()
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:101:    'granola_workspace_id',       -- per-tenant Granola workspace (W6+ Scribe)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:102:    'bullhorn_corporation_id'     -- per-tenant Bullhorn corporation
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:111:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:212:  -- granola_workspace_id: opaque string (no format constraint)
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:213:  IF c ? 'granola_workspace_id' THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:214:    IF jsonb_typeof(c->'granola_workspace_id') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:215:      RAISE EXCEPTION 'granola_workspace_id must be string or null';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:219:  -- bullhorn_corporation_id: string matching integer pattern
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:220:  IF c ? 'bullhorn_corporation_id' THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:221:    IF jsonb_typeof(c->'bullhorn_corporation_id') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:222:      RAISE EXCEPTION 'bullhorn_corporation_id must be string or null';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:224:    IF c->>'bullhorn_corporation_id' IS NOT NULL
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:225:       AND c->>'bullhorn_corporation_id' !~ '^[0-9]+$' THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:226:      RAISE EXCEPTION 'bullhorn_corporation_id must match ^[0-9]+$ (Bullhorn corporation ID format); got: %', c->>'bullhorn_corporation_id';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:238:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:239:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_4 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:241:CREATE TRIGGER validate_tenant_adapters_config_v0_4
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:242:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:244:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_4();
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:252:-- validate_tenant_adapters_config_v0_3, the DROP will fail and roll back
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:255:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:270:    WHERE proname = 'validate_tenant_adapters_config_v0_4';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:276:    WHERE tgname = 'validate_tenant_adapters_config_v0_4';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:283:    WHERE proname = 'validate_tenant_adapters_config_v0_3';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:289:    WHERE tgname = 'validate_tenant_adapters_config_v0_3';
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:294:  RAISE NOTICE 'v0.4 migration smoke passed: validate_tenant_adapters_config_v0_4 active; v0.3 dropped cleanly';
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:9:--   - Drops validate_tenant_adapters_config_v0_4 trigger + function
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:10:--   - Re-creates validate_tenant_adapters_config_v0_3 trigger + function
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:13:-- DATA IMPACT: Any tenant_adapters.config row that has populated v0.4-only
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:15:-- granola_workspace_id, bullhorn_corporation_id) WILL BE BLOCKED at next
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:29:-- Surface (non-fatal) any tenant_adapters rows that have v0.4 keys set.
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:37:  IF to_regclass('public.tenant_adapters') IS NOT NULL THEN
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:38:    SELECT count(*) INTO v04_key_users FROM tenant_adapters
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:43:        'granola_workspace_id',
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:44:        'bullhorn_corporation_id'
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:48:    RAISE NOTICE 'WARNING: % tenant_adapters row(s) have v0.4-only keys set; future UPDATEs to these rows will fail under restored v0.3 trigger until those keys are cleared', v04_key_users;
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:56:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_4 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:57:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_4();
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:67:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:94:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:162:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:164:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:165:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:167:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:182:    WHERE proname = 'validate_tenant_adapters_config_v0_3';
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:188:    WHERE tgname = 'validate_tenant_adapters_config_v0_3';
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:195:    WHERE proname = 'validate_tenant_adapters_config_v0_4';
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql:201:    WHERE tgname = 'validate_tenant_adapters_config_v0_4';

codex
The cited shared catalogues mostly exist, but I’ve found a few contract-level inconsistencies worth checking against the agent-bundle rules before deciding the verdict.
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,610p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '510,535p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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
   531	- **Build wave:** v1.0 (week 7–8)
   532	- **Always-on?** Tier 1 — persistent watcher on accounting + bank webhooks
   533	- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
   534	- **CortexOS primitives required:** Persistent PTY (#1), Telegram approval surface (#5), standing authorisations (#4)
   535	- **MCP tools required:** Xero / QuickBooks / Sage (one of, per tenant), bank-feed connector

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/agent.md | sed -n '260,520p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
   260	Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
   261	
   262	Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator_chat_id (per catalogue routing; likely indicates LLM prompt drift or taxonomy mismatch).
   263	
   264	---
   265	
   266	## §6 — Escalation codes
   267	
   268	Scribe uses these ESC codes from `agents/_shared/escalation-codes.md`:
   269	
   270	| Code | Trigger | Severity | Routing |
   271	|---|---|---|---|
   272	| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   273	| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
   274	| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
   275	| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
   276	| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
   277	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
   278	| `ESC_INPUT_VALIDATION_FAIL` | Webhook signature mismatch (Step 1) | warn | operator_chat_id |
   279	| `ESC_AGENT_OUTPUT_SHAPE` | No resolvable target entity (Step 4) — Scribe run cannot produce its declared output shape | warn | operator_chat_id |
   280	| `ESC_SCHEMA_VIOLATION` | Vertical-schema field-constraint violation at write time (Step 7) per catalogue line 163 | warn | operator_chat_id |
   281	| `ESC_SCRIBE_SLA_MISS` | Per catalogue §2.10: summary-render >30 min OR note-attach >1h after call end | warn | operator_chat_id (per catalogue routing); aggregated to Gate B metric |
   282	| `ESC_GATE_B_MISS` | Both Gate B metrics (≥90% within-5-min SLA AND ≤20% structured-field edit-rate) below target for 30 consecutive days | warn | operator_chat_id (per catalogue routing) |
   283	| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
   284	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
   285	
   286	Scribe does NOT use:
   287	
   288	- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
   289	
   290	---
   291	
   292	## §7 — Voice + tone constraints
   293	
   294	Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   295	
   296	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
   297	  - No identifying language about call participants beyond their professional context
   298	  - No verbatim quotes longer than 12 words from candidate (paraphrase for privacy)
   299	  - No compensation specifics in tacit notes (those go to structured fields only)
   300	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
   301	- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
   302	
   303	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   304	
   305	---
   306	
   307	## §8 — Build dependencies (W6 prerequisites)
   308	
   309	Scribe build cannot start until ALL of the following are confirmed:
   310	
   311	| Dependency | Source | Status |
   312	|---|---|---|
   313	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   314	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   315	| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
   316	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   317	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   318	| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
   319	| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
   320	| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
   321	| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
   322	| Per-tenant call-routing config (which provider) | Tenant onboarding | ⏸ |
   323	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   324	| Tacit-note taxonomy v0.1 (8 categories) finalised | Founder review with first pilot | ⏸ |
   325	| `validate.sh` Gate A logic | Build at W6 start (~0.5 day) | ⏸ |
   326	| `context.sh` hydration | Build at W6 start (~0.5 day) | ⏸ |
   327	| `cycle.sh` orchestration (10-step) | Build at W6 start (~2 days) | ⏸ |
   328	| 3 fixtures with golden outputs | Build at W6 start (~1 day) | ⏸ |
   329	| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |
   330	
   331	**Until ALL ⏸ items resolve to ✅, W6 build slice does not start.**
   332	
   333	---
   334	
   335	## §9 — Status + open questions
   336	
   337	**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
   338	
   339	### Open questions for founder review
   340	
   341	| # | Question | Resolution path |
   342	|---|---|---|
   343	| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
   344	| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
   345	| Q3 | Tacit-note taxonomy v0.1 — 8 categories proposed in §3 above. Founder confidence each is high-value? | Founder review with first pilot tenant's consultants during onboarding; can prune/expand based on actual consultant patterns. |
   346	| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
   347	| Q5 | Bullhorn write atomicity — Step 9 rollback of Step 8 on note-attach failure is best-effort PATCH. Could leave entity in mid-state. | v1.0 accept; document risk. v1.1+: investigate Bullhorn transaction API if exposed. |
   348	| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
   349	| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
   350	
   351	### Gotchas (carried forward from ULTRAPLAN A3 line 527)
   352	
   353	1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
   354	2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
   355	3. **LLM hallucination on field extraction is the failure mode.** Mitigation: confidence threshold ≥0.6 + cross-validation against vertical-schema field-name list + range checks.
   356	
   357	---
   358	
   359	## §10 — When this document ratifies
   360	
   361	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   362	
   363	Status flips Proposed → Accepted when:
   364	- Codex Round 4 Phase 2 ratifies
   365	- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
   366	- Q2 cost model approved with budget cap
   367	
   368	Status flips Accepted → In Force when:
   369	- W6 build slice produces all 5 sibling bundle files + 3 fixtures
   370	- First production transcript processed end-to-end against migration-test tenant
   371	- SLA + edit-rate Gate-B metrics measurable
   372	- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
   373	
   374	Until then: this document is a forward-looking scaffold.
   375	
   376	*End of Scribe agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '90,200p'; nl -ba agents/_shared/escalation-codes.md | sed -n '300,455p'; nl -ba agents/_shared/autosend-policy.yaml | sed -n '35,260p'; nl -ba agents/_shared/voice-loader.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
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
   150	  # MCP-connector OAuth refresh action_types (added 2026-06-01
   151	  # per Codex cluster F Round 1 — review-mcp-connector §7 requires
   152	  # documented action_types to exist in this policy with matching
   153	  # tier; round-1 REJECT cited all 4 as missing). All green: OAuth
   154	  # refresh is idempotent token rotation, not external send.
   155	  # ───────────────────────────────────────────────────────────
   156	
   157	  xero_oauth:
   158	    tier: green
   159	    agent: cash-conductor
   160	    reason: "Xero OAuth 2.0 refresh — idempotent token rotation against identity.xero.com; @ifos/xero connector handles concurrent-refresh dedup per-tenant; no external send."
   161	    irreversible: false
   162	
   163	  quickbooks_oauth:
   164	    tier: green
   165	    agent: cash-conductor
   166	    reason: "QuickBooks Online OAuth 2.0 refresh — idempotent token rotation against oauth.platform.intuit.com; @ifos/quickbooks connector handles concurrent-refresh dedup per-realm; QB refresh tokens have ~100-day TTL so operator alerting on refreshTokenNearExpiry() is the consumer's responsibility, not this action_type's."
   167	    irreversible: false
   168	
   169	  open_banking_truelayer:
   170	    tier: green
   171	    agent: cash-conductor
   172	    reason: "TrueLayer OAuth 2.0 refresh — idempotent token rotation against auth.truelayer.com; @ifos/open-banking connector handles concurrent-refresh dedup per-connection; PSD2 90-day consent expiry surfaces via ESC_OPEN_BANKING_TOKEN_AGING (separate aging signal, not this action_type)."
   173	    irreversible: false
   174	
   175	  open_banking_plaid_uk:
   176	    tier: green
   177	    agent: cash-conductor
   178	    reason: "Plaid UK OAuth 2.0 refresh — v1.1+ stub; never fires v1.0. Registered now so the README + tools.yaml capability declarations have a matching policy entry per review-mcp-connector §7 set-equality."
   179	    irreversible: false
   180	
   181	  bullhorn_activity_log_write:
   182	    tier: green
   183	    agent: concierge
   184	    reason: "Internal Bullhorn activity-log entry — NOT customer-visible (separate from bullhorn_note_customer_visible which is orange). Maintains the audit trail in Bullhorn itself so downstream consultant ops see Concierge actions on the candidate's record. Idempotent within payload_hash dedup window. Registered per Codex Fbis-R1 closure 2026-06-02 — Concierge agent.md §4 Step 13 needs this for tier classification of the external write."
   185	    irreversible: false
   186	
   187	  # ───────────────────────────────────────────────────────────
   188	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   189	  # ───────────────────────────────────────────────────────────
   190	
   191	  bullhorn_candidate_dedupe:
   192	    tier: yellow
   193	    agent: janitor
   194	    sample_rate: 10
   195	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   196	    irreversible: false
   197	
   198	  bullhorn_field_backfill:
   199	    tier: yellow
   200	    agent: janitor
   201	    sample_rate: 10
   202	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   203	    irreversible: false
   204	
   205	  bullhorn_note_attach:
   206	    tier: yellow
   207	    agent: janitor
   208	    sample_rate: 20
   209	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   210	    irreversible: false
   211	
   212	  bullhorn_note_append_summary:
   213	    tier: yellow
   214	    agent: scribe
   215	    sample_rate: 20
   216	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   217	    irreversible: false
   218	
   219	  linkedin_connection_request:
   220	    tier: yellow
   221	    agent: sourcing-scout
   222	    sample_rate: 5
   223	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   224	    irreversible: true
   225	
   226	  xero_reminder_draft_internal:
   227	    tier: yellow
   228	    agent: cash-conductor
   229	    sample_rate: 10
   230	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   231	    irreversible: false
   232	
   233	  bullhorn_note_draft_internal:
   234	    tier: yellow
   235	    agent: concierge
   236	    sample_rate: 10
   237	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   238	    irreversible: false
   239	
   240	  bullhorn_scribe_field_write:
   241	    tier: yellow
   242	    agent: scribe
   243	    sample_rate: 10
   244	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   245	    irreversible: false
   246	
   247	  accounting_reconciliation_write:
   248	    tier: yellow
   249	    agent: cash-conductor
   250	    sample_rate: 10
   251	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   252	    irreversible: false
   253	
   254	  concierge_email_draft:
   255	    tier: yellow
   256	    agent: concierge
   257	    sample_rate: 20
   258	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   259	    irreversible: false
   260	
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

codex
I’m checking the actual Scribe sibling files now because the artefact makes direct claims about whether they exist and what runtime markers they emit. That matters for the pre-build versus production-ready distinction.
exec
/bin/zsh -lc 'rg --files agents/recruitment/scribe | sort' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/validate.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/recruitment/scribe/README.md
agents/recruitment/scribe/agent.md
agents/recruitment/scribe/bin/bh-bridge.sh
agents/recruitment/scribe/bin/extract-fields.sh
agents/recruitment/scribe/bin/render-tacit-note.sh
agents/recruitment/scribe/bin/sla-class.sh
agents/recruitment/scribe/bin/validate-fields.sh
agents/recruitment/scribe/cleanup.sh
agents/recruitment/scribe/context.sh
agents/recruitment/scribe/cycle.sh
agents/recruitment/scribe/fixtures/01-primary.yaml
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml
agents/recruitment/scribe/tools.yaml
agents/recruitment/scribe/validate.sh

 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Scribe agent — validate.sh (Gate A enforcement; W6 build slice LIVE)
     3	#
     4	# Status: built (W6 build slice; the W5 Day-32 skeleton TODO(W6-7) markers are
     5	#         replaced with live checks per spec-002-scribe.md §5 + agent.md §5).
     6	# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
     7	#
     8	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
     9	# hard-fail gate that runs BETWEEN cycle.sh Step 7 (field validation) and
    10	# Step 8 (Bullhorn write). If any check fails, validate.sh exits non-zero +
    11	# emits the ESC_* row + the validate_gate_a_fail action row to decision_log;
    12	# the meeting's Bullhorn writes are skipped; cycle.sh continues to the next
    13	# meeting (poll-sweep mode) or exits with the gate-fail signal (replay/webhook).
    14	#
    15	# Invocation contract:
    16	#   bash validate.sh <extraction_proposal_json>
    17	#
    18	# Inputs:
    19	#   - $1: path to JSON describing the proposed Bullhorn writes for ONE call.
    20	#         Shape:
    21	#         {
    22	#           "call_id": "<granola_meeting_id>",
    23	#           "entity_type": "candidate" | "contact" | "brief" | "placement" | "opportunity",
    24	#           "bullhorn_id": "<id>",
    25	#           "webhook_sig_state": "verified" | "not_applicable" | "invalid" | "missing",
    26	#           "fields_extracted": [
    27	#             {"field_name": "...", "value": ..., "confidence": <0.0-1.0>}
    28	#           ],
    29	#           "tacit_note": {
    30	#             "vault_path": "/vault/<tenant>/scribe-notes/<call_id>-<ISO>.md",
    31	#             "body_sha256": "...",
    32	#             "voice_score": <0.0-1.0> | "unscored",
    33	#             "voice_reason": "...",
    34	#             "narrative_word_count": <int>,
    35	#             "narrative_body_preview": "..."  // first 500 chars for PII regex pass
    36	#           }
    37	#         }
    38	#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR,
    39	#          CTX_FIRM_DOMAIN_WHITELIST (comma-separated; for the PII check)
    40	#
    41	# Exit codes:
    42	#   0  All Gate A checks pass; cycle.sh proceeds to Steps 8 + 9 writes
    43	#   1  At least one check failed; ESC_* row emitted; cycle.sh skips writes
    44	#   2  validate.sh invocation error (bad args, missing file, etc.)
    45	#
    46	# Checks (spec-002 §5 — all 7, in spec order — plus the agent.md §3 word cap):
    47	#   G1 — webhook-sig: valid per provider                    ESC_INPUT_VALIDATION_FAIL  hard
    48	#   G2 — field-count: ≥3 extractions ≥0.6 confidence        ESC_FIELD_EXTRACTION_LOW_CONFIDENCE  hard
    49	#   G3 — tacit-voice: classifier ≥0.75                      ESC_VOICE_DRIFT  hard (warn-when-unscored)
    50	#   G4 — field-names: exist in target entity schema         ESC_SCHEMA_VIOLATION  hard
    51	#   G5 — field-types: per-field type/range valid; ≥3 valid  ESC_SCHEMA_VIOLATION  hard
    52	#   G6 — PII: none outside firm boundary in note narrative  ESC_PII_LEAKAGE_RISK  hard (blocking)
    53	#   G7 — auth: Bullhorn refresh succeeded this session      ESC_BULLHORN_AUTH  hard
    54	#   G8 — word-cap: tacit-note ≤800 words (agent.md §3)      ESC_AGENT_OUTPUT_SHAPE  hard
    55	
    56	set -uo pipefail
    57	
    58	# ────────────────────────────────────────────────────────────────────────
    59	# Pre-flight
    60	# ────────────────────────────────────────────────────────────────────────
    61	
    62	if [[ $# -lt 1 ]]; then
    63	  printf 'scribe/validate.sh: usage: validate.sh <extraction_proposal_json>\n' >&2
    64	  exit 2
    65	fi
    66	
    67	readonly PROPOSAL="$1"
    68	
    69	if [[ ! -f "${PROPOSAL}" ]]; then
    70	  printf 'validate.sh: proposal not found at %s\n' "${PROPOSAL}" >&2
    71	  exit 2
    72	fi
    73	
    74	if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
    75	  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
    76	  exit 2
    77	fi
    78	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    79	  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
    80	  exit 2
    81	fi
    82	command -v jq >/dev/null 2>&1 || { printf 'validate.sh: jq required\n' >&2; exit 2; }
    83	jq -e 'type=="object"' "${PROPOSAL}" >/dev/null 2>&1 || {
    84	  printf 'validate.sh: proposal is not a JSON object\n' >&2; exit 2; }
    85	
    86	# Resolve _shared/ helpers (4-candidate fallback; matches sibling agents
    87	# per smoke-hotfix commit d7d52c5).
    88	_SHARED_DIR=""
    89	for _candidate in \
    90	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    91	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    92	  "${CTX_AGENT_DIR}/../../_shared" \
    93	  "${CTX_AGENT_DIR}/../_shared" ; do
    94	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    95	    _SHARED_DIR="${_candidate}"
    96	    break
    97	  fi
    98	done
    99	if [[ -z "${_SHARED_DIR}" ]]; then
   100	  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
   101	  exit 2
   102	fi
   103	# shellcheck source=/dev/null
   104	source "${_SHARED_DIR}/hook-helpers.sh"
   105	
   106	_BIN="${CTX_AGENT_DIR}/bin"
   107	[[ -d "${_BIN}" ]] || _BIN="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/bin"
   108	
   109	# Track failures + warnings across all checks (collect all before exit for richer audit)
   110	declare -a FAILURES=()
   111	declare -a WARNINGS=()
   112	
   113	_fail() {
   114	  FAILURES+=("$1")
   115	  printf '  ✗ %s\n' "$1" >&2
   116	}
   117	_warn() {
   118	  WARNINGS+=("$1")
   119	  printf '  ! %s\n' "$1" >&2
   120	}
   121	_ok() {
   122	  printf '  ✓ %s\n' "$1"
   123	}
   124	
   125	# Dominant failure class for ESC routing (first hard fail wins).
   126	ESC_CLASS=""
   127	
   128	# Thresholds (per ULTRAPLAN A3 line 524 + agent.md §3)
   129	readonly FIELD_CONFIDENCE_THRESHOLD="0.6"
   130	readonly MIN_FIELDS_REQUIRED="3"
   131	readonly VOICE_SCORE_THRESHOLD="0.75"
   132	readonly TACIT_NOTE_WORD_CAP="800"
   133	
   134	CALL_ID="$(jq -r '.call_id // "unknown"' "${PROPOSAL}")"
   135	ENTITY_TYPE="$(jq -r '.entity_type // ""' "${PROPOSAL}")"
   136	BULLHORN_ID="$(jq -r '.bullhorn_id // "unknown"' "${PROPOSAL}")"
   137	
   138	# ────────────────────────────────────────────────────────────────────────
   139	# G1 — Webhook signature valid per provider (spec-002 §5 row 1)
   140	# cycle.sh Step 1 verified the HMAC/bearer and recorded the verdict in the
   141	# proposal. 'not_applicable' = poll-sweep/replay (Granola publishes no
   142	# webhooks — there is no external input to verify); anything else fails hard.
   143	# ────────────────────────────────────────────────────────────────────────
   144	
   145	_sig="$(jq -r '.webhook_sig_state // "missing"' "${PROPOSAL}")"
   146	case "${_sig}" in
   147	  verified)        _ok "G1: webhook signature verified" ;;
   148	  not_applicable)  _ok "G1: webhook signature not applicable (poll/replay trigger; no external webhook input)" ;;
   149	  *)
   150	    _fail "G1: webhook signature state '${_sig}' — reject"
   151	    ESC_CLASS="${ESC_CLASS:-ESC_INPUT_VALIDATION_FAIL}" ;;
   152	esac
   153	
   154	# ────────────────────────────────────────────────────────────────────────
   155	# G2 — ≥3 structured-field extractions with confidence ≥0.6
   156	# Per ULTRAPLAN A3 line 524 verbatim.
   157	# ────────────────────────────────────────────────────────────────────────
   158	
   159	_n_conf="$(jq --argjson t "${FIELD_CONFIDENCE_THRESHOLD}" \
   160	  '[.fields_extracted[]? | select(.confidence >= $t)] | length' "${PROPOSAL}" 2>/dev/null || echo 0)"
   161	if [[ "${_n_conf}" -ge "${MIN_FIELDS_REQUIRED}" ]]; then
   162	  _ok "G2: ${_n_conf} fields with confidence ≥${FIELD_CONFIDENCE_THRESHOLD} (≥${MIN_FIELDS_REQUIRED} required)"
   163	else
   164	  _fail "G2: only ${_n_conf} fields ≥${FIELD_CONFIDENCE_THRESHOLD} confidence (need ${MIN_FIELDS_REQUIRED})"
   165	  ESC_CLASS="${ESC_CLASS:-ESC_FIELD_EXTRACTION_LOW_CONFIDENCE}"
   166	fi
   167	
   168	# ────────────────────────────────────────────────────────────────────────
   169	# G3 — Tacit-note voice classifier ≥0.75
   170	# Hard fail when a numeric score is below threshold (per agent.md §3: the
   171	# note is NOT attached; the vault draft is flagged needs-consultant-review).
   172	# warn-when-unscored (spec-002 §5): with no tenant voice_corpus (or no
   173	# classifier wired) a score cannot be HONESTLY computed — warn, never fake.
   174	# ────────────────────────────────────────────────────────────────────────
   175	
   176	_voice="$(jq -r '.tacit_note.voice_score // "missing"' "${PROPOSAL}")"
   177	_vreason="$(jq -r '.tacit_note.voice_reason // ""' "${PROPOSAL}")"
   178	if [[ "${_voice}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
   179	  if awk -v s="${_voice}" -v t="${VOICE_SCORE_THRESHOLD}" 'BEGIN{exit !(s>=t)}'; then
   180	    _ok "G3: tacit-note voice score ${_voice} ≥ ${VOICE_SCORE_THRESHOLD}"
   181	  else
   182	    _fail "G3: tacit-note voice score ${_voice} < ${VOICE_SCORE_THRESHOLD} (after retries) — note NOT attached; vault draft held for consultant review"
   183	    ESC_CLASS="${ESC_CLASS:-ESC_VOICE_DRIFT}"
   184	  fi
   185	else
   186	  _warn "G3: voice unscored (${_vreason:-no_reason}) — cannot enforce threshold without a seeded voice_corpus + classifier (never faked)"
   187	fi
   188	
   189	# ────────────────────────────────────────────────────────────────────────
   190	# G4 + G5 — Field names exist in target entity schema + per-field type/range
   191	# Single source of truth: bin/validate-fields.sh (schema-file-derived
   192	# allowlist mirroring the validate_entities_data_v0_3 trigger).
   193	# ────────────────────────────────────────────────────────────────────────
   194	
   195	_FIELDS_TMP="$(mktemp -t scribe-gate-fields-XXXXXX)"
   196	trap 'rm -f "${_FIELDS_TMP}"' EXIT
   197	jq -c '.fields_extracted // []' "${PROPOSAL}" > "${_FIELDS_TMP}"
   198	
   199	_vres="$(bash "${_BIN}/validate-fields.sh" --entity-type "${ENTITY_TYPE}" --fields-file "${_FIELDS_TMP}" 2>/dev/null)" \
   200	  || _vres='{"valid":[],"dropped":[{"field_name":"(validator)","reason":"validate-fields.sh failed"}],"valid_count":0}'
   201	_valid_count="$(jq -r '.valid_count' <<<"${_vres}")"
   202	_bad_names="$(jq -r '[.dropped[] | select(.reason | test("not in .* writable schema"))] | length' <<<"${_vres}")"
   203	_bad_types="$(jq -r '[.dropped[] | select(.reason | test("not in .* writable schema") | not)] | length' <<<"${_vres}")"
   204	
   205	if [[ "${_bad_names}" -eq 0 ]]; then
   206	  _ok "G4: all field names exist in ${ENTITY_TYPE} schema (vertical-schema v0.1+v0.3)"
   207	else
   208	  _fail "G4: ${_bad_names} field name(s) not in ${ENTITY_TYPE} schema: $(jq -r '[.dropped[] | select(.reason | test("not in")) | .field_name] | join(",")' <<<"${_vres}")"
   209	  ESC_CLASS="${ESC_CLASS:-ESC_SCHEMA_VIOLATION}"
   210	fi
   211	
   212	if [[ "${_bad_types}" -eq 0 && "${_valid_count}" -ge "${MIN_FIELDS_REQUIRED}" ]]; then
   213	  _ok "G5: per-field type/range checks pass (${_valid_count} valid)"
   214	else
   215	  if [[ "${_bad_types}" -gt 0 ]]; then
   216	    _fail "G5: ${_bad_types} field(s) failed type/range checks: $(jq -r '[.dropped[] | select(.reason | test("not in") | not) | .field_name + " (" + .reason + ")"] | join("; ")' <<<"${_vres}")"
   217	  fi
   218	  if [[ "${_valid_count}" -lt "${MIN_FIELDS_REQUIRED}" ]]; then
   219	    _fail "G5: only ${_valid_count} valid field(s) after drops (need ${MIN_FIELDS_REQUIRED})"
   220	  fi
   221	  ESC_CLASS="${ESC_CLASS:-ESC_SCHEMA_VIOLATION}"
   222	fi
   223	
   224	# ────────────────────────────────────────────────────────────────────────
   225	# G6 — No PII outside firm boundary in the tacit-note narrative (regex pass
   226	# over narrative_body_preview against CTX_FIRM_DOMAIN_WHITELIST).
   227	# Blocking severity per agent.md §6 ESC_PII_LEAKAGE_RISK.
   228	# ────────────────────────────────────────────────────────────────────────
   229	
   230	_preview="$(jq -r '.tacit_note.narrative_body_preview // ""' "${PROPOSAL}")"
   231	_whitelist="${CTX_FIRM_DOMAIN_WHITELIST:-${CTX_TENANT_SLUG}.test}"
   232	_pii_hit=0
   233	_body_emails="$(printf '%s' "${_preview}" | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
   234	if [[ -n "${_body_emails}" ]]; then
   235	  while IFS= read -r _em; do
   236	    [[ -z "${_em}" ]] && continue
   237	    _dom="${_em##*@}"
   238	    _allowed=0
   239	    for _fd in ${_whitelist//,/ }; do
   240	      [[ "${_dom,,}" == "${_fd,,}" ]] && _allowed=1
   241	    done
   242	    [[ "${_allowed}" -eq 0 ]] && _pii_hit=1
   243	  done <<<"${_body_emails}"
   244	fi
   245	# UK NI numbers + phone-number shapes are also outside-boundary PII in a narrative.
   246	if printf '%s' "${_preview}" | grep -qiE '\b[A-CEGHJ-PR-TW-Z]{2}[0-9]{6}[A-D]\b'; then
   247	  _pii_hit=1
   248	fi
   249	if [[ "${_pii_hit}" -eq 1 ]]; then
   250	  _fail "G6: PII outside firm boundary detected in tacit-note narrative — write blocked; vault draft held for review"
   251	  ESC_CLASS="ESC_PII_LEAKAGE_RISK"
   252	else
   253	  _ok "G6: no PII outside firm boundary in narrative preview"
   254	fi
   255	
   256	# ────────────────────────────────────────────────────────────────────────
   257	# G7 — Bullhorn auth refresh succeeded this session
   258	# Re-query decision_log for a fresh bullhorn_auth_refreshed row (≤10 min)
   259	# whose result is fresh|refreshed. unavailable/failed/absent = hard fail —
   260	# no stale-token (or no-token) Bullhorn writes, ever.

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/cycle.sh | sed -n '120,330p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
   120	    fi ;;
   121	  webhook)
   122	    if [[ -z "${PAYLOAD_FILE}" || ! -f "${PAYLOAD_FILE}" ]]; then
   123	      printf 'cycle.sh: --payload <json file> required for mode=webhook\n' >&2; exit 2
   124	    fi ;;
   125	  *) printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
   126	esac
   127	
   128	# Defensive defaults if context.sh wasn't run (standalone invocation)
   129	: "${CTX_GRANOLA_PLAN_TIER:=paid}"
   130	: "${CTX_GRANOLA_WORKSPACE_ID:=unset}"
   131	: "${CTX_BULLHORN_CORPORATION_ID:=unset}"
   132	: "${CTX_FIRM_DOMAIN_WHITELIST:=${CTX_TENANT_SLUG}.test}"
   133	: "${CTX_GRANOLA_LAST_POLL:=1970-01-01T00:00:00Z}"
   134	: "${CTX_VOICE_CORPUS_ID:=none}"
   135	export CTX_GRANOLA_PLAN_TIER CTX_GRANOLA_WORKSPACE_ID CTX_BULLHORN_CORPORATION_ID \
   136	       CTX_FIRM_DOMAIN_WHITELIST CTX_VOICE_CORPUS_ID
   137	
   138	SESSION_START_EPOCH="$(date -u +%s)"
   139	VAULT_PHYS_ROOT="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}"
   140	GRANOLA_CLI="${IFOS_GRANOLA_CLI:-${IFOS_REPO_ROOT:-}/packages/mcp-connectors/granola/dist/cli.js}"
   141	FETCH_RETRY_DELAY="${SCRIBE_FETCH_RETRY_DELAY:-30}"
   142	
   143	# ISO-8601 (UTC, Z) → epoch seconds; BSD + GNU date. Empty on parse failure.
   144	_iso_to_epoch() {
   145	  local ts="$1"
   146	  [[ -z "${ts}" ]] && { echo ""; return 0; }
   147	  date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "${ts}" +%s 2>/dev/null \
   148	    || date -u -d "${ts}" +%s 2>/dev/null \
   149	    || echo ""
   150	}
   151	
   152	# RLS-scoped psql wrapper (stdin SQL; --set tenant pre-bound). Best-effort.
   153	_psql_t() {
   154	  psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" "$@"
   155	}
   156	
   157	# Session counters (Step 10)
   158	CALLS_PROCESSED=0
   159	CALLS_SKIPPED=0
   160	FIELD_WRITES=0
   161	NOTE_ATTACHES=0
   162	WORST_SLA_CLASS="n/a"
   163	
   164	# ────────────────────────────────────────────────────────────────────────
   165	# Step 0 — Session start
   166	# ────────────────────────────────────────────────────────────────────────
   167	
   168	hh_decision_trigger "session_start" "scribe mode=${MODE} call_id=${CALL_ID_ARG:-NA}"
   169	
   170	# ────────────────────────────────────────────────────────────────────────
   171	# Step 1 — Webhook signature verification (mode=webhook) / poll discovery
   172	# Reference: spec-002 §4 Step 1 (marker webhook_verified; ESC_INPUT_VALIDATION_FAIL
   173	# reject = the 401 path) + agent.md §2. In poll-sweep/replay there is no
   174	# external webhook input to verify (Granola publishes none) — the marker is
   175	# emitted honestly with method:poll|manual_replay + signature:not_applicable;
   176	# Gate A G1 accepts {verified, not_applicable} and hard-fails {invalid, missing}.
   177	# ────────────────────────────────────────────────────────────────────────
   178	
   179	WEBHOOK_SIG_STATE="not_applicable"
   180	MEETINGS_JSON="[]"
   181	
   182	if [[ "${MODE}" == "webhook" ]]; then
   183	  WEBHOOK_SIG_STATE="invalid"
   184	  if [[ -n "${SIGNATURE}" && -n "${SCRIBE_WEBHOOK_SECRET:-}" ]] && command -v openssl >/dev/null 2>&1; then
   185	    _want="${SIGNATURE#sha256=}"
   186	    _got="$(openssl dgst -sha256 -hmac "${SCRIBE_WEBHOOK_SECRET}" "${PAYLOAD_FILE}" 2>/dev/null | awk '{print $NF}')"
   187	    [[ -n "${_got}" && "${_got}" == "${_want}" ]] && WEBHOOK_SIG_STATE="verified"
   188	  elif [[ -n "${BEARER}" && -n "${SCRIBE_WEBHOOK_SECRET:-}" ]]; then
   189	    [[ "${BEARER}" == "${SCRIBE_WEBHOOK_SECRET}" ]] && WEBHOOK_SIG_STATE="verified"
   190	  fi
   191	  _wh_call_id="$(jq -r '.call_id // "unknown"' "${PAYLOAD_FILE}" 2>/dev/null || echo unknown)"
   192	  if [[ "${WEBHOOK_SIG_STATE}" != "verified" ]]; then
   193	    # Reject (the HTTP layer maps this to 401) — per agent.md §4 Step 1.
   194	    autosend_escalate "ESC_INPUT_VALIDATION_FAIL" "agent=scribe" \
   195	      "tenant=${CTX_TENANT_SLUG}" "call=${_wh_call_id}" "reason=webhook_signature_mismatch"
   196	    hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
   197	      "provider:granola; method:hmac_sha256; result:invalid; rejected:401"
   198	    exit 1
   199	  fi
   200	  hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
   201	    "provider:granola; method:$( [[ -n "${SIGNATURE}" ]] && echo hmac_sha256 || echo bearer ); result:verified"
   202	  # Webhook payload IS the meeting metadata (agent.md §2 shape).
   203	  MEETINGS_JSON="$(jq -c '[{id: (.call_id // "unknown"), title: (.metadata.title // ""),
   204	      end_time: (.metadata.end_time // .received_at // ""),
   205	      duration_minutes: ((.duration_seconds // 0) / 60 | floor),
   206	      attendees: (.participants // []), has_transcript: true,
   207	      notes_markdown: (.metadata.notes_markdown // "")}]' "${PAYLOAD_FILE}" 2>/dev/null || echo '[]')"
   208	else
   209	  hh_decision_output "webhook_verified" "call:${CALL_ID_ARG:-sweep}" \
   210	    "provider:granola; method:$( [[ "${MODE}" == "replay" ]] && echo manual_replay || echo poll ); signature:not_applicable"
   211	
   212	  # Poll discovery (poll-sweep/dry-run) or single-meeting hydrate (replay).
   213	  # Source order: fixture file → @ifos/granola CLI (expected surface:
   214	  # `node dist/cli.js list-meetings --since <ISO>` → JSON array) → empty.
   215	  if [[ -n "${IFOS_SCRIBE_MEETINGS_FILE:-}" && -f "${IFOS_SCRIBE_MEETINGS_FILE}" ]]; then
   216	    MEETINGS_JSON="$(jq -c '.' "${IFOS_SCRIBE_MEETINGS_FILE}" 2>/dev/null || echo '[]')"
   217	  elif [[ -f "${GRANOLA_CLI}" ]] && command -v node >/dev/null 2>&1; then
   218	    MEETINGS_JSON="$(node "${GRANOLA_CLI}" list-meetings --since "${CTX_GRANOLA_LAST_POLL}" 2>/dev/null || echo '[]')"
   219	    jq -e 'type=="array"' <<<"${MEETINGS_JSON}" >/dev/null 2>&1 || MEETINGS_JSON="[]"
   220	  fi
   221	  if [[ "${MODE}" == "replay" ]]; then
   222	    _m="$(jq -c --arg id "${CALL_ID_ARG}" '[.[] | select(.id == $id)] | first // empty' <<<"${MEETINGS_JSON}" 2>/dev/null || true)"
   223	    if [[ -n "${_m}" ]]; then
   224	      MEETINGS_JSON="[${_m}]"
   225	    else
   226	      MEETINGS_JSON="$(jq -nc --arg id "${CALL_ID_ARG}" '[{id: $id, title: "", end_time: "", duration_minutes: 0, attendees: [], has_transcript: true, notes_markdown: ""}]')"
   227	    fi
   228	  fi
   229	  _n_meet="$(jq 'length' <<<"${MEETINGS_JSON}")"
   230	  _n_tx="$(jq '[.[] | select(.has_transcript == true)] | length' <<<"${MEETINGS_JSON}")"
   231	  hh_decision_output "granola_meetings_polled" "tenant:${CTX_TENANT_SLUG}" \
   232	    "mode:${MODE}; meetings:${_n_meet}; meetings_with_transcripts:${_n_tx}; since:${CTX_GRANOLA_LAST_POLL}; workspace_id:${CTX_GRANOLA_WORKSPACE_ID}"
   233	fi
   234	
   235	# ────────────────────────────────────────────────────────────────────────
   236	# Step 2 — Bullhorn auth refresh (session-level; via bin/bh-bridge.sh)
   237	# Reference: agent.md §4 Step 2; 2 retries then ESC_BULLHORN_AUTH (blocking;
   238	# operator + ifos_oncall). Bridge-unavailable (exit 3) is recorded honestly —
   239	# Gate A G7 then blocks Bullhorn writes (no creds → no writes; never faked).
   240	# ────────────────────────────────────────────────────────────────────────
   241	
   242	BH_TOKEN_STATE="failed"
   243	for _attempt in 1 2 3; do
   244	  _rc=0
   245	  _out="$(bash "${_BIN}/bh-bridge.sh" refresh 2>/dev/null)" || _rc=$?
   246	  if [[ "${_rc}" -eq 0 ]]; then
   247	    BH_TOKEN_STATE="$(jq -r '.token_state // "refreshed"' <<<"${_out}" 2>/dev/null || echo refreshed)"
   248	    break
   249	  elif [[ "${_rc}" -eq 3 ]]; then
   250	    BH_TOKEN_STATE="unavailable"   # bridge not built / creds not provisioned — no point retrying
   251	    break
   252	  fi
   253	  [[ "${_attempt}" -lt 3 ]] && sleep 1
   254	done
   255	hh_decision_output "bullhorn_auth_refreshed" "tenant:${CTX_TENANT_SLUG}" \
   256	  "corporation_id:${CTX_BULLHORN_CORPORATION_ID}; result:${BH_TOKEN_STATE}"
   257	if [[ "${BH_TOKEN_STATE}" == "failed" ]]; then
   258	  autosend_escalate "ESC_BULLHORN_AUTH" "agent=scribe" \
   259	    "tenant=${CTX_TENANT_SLUG}" "corporation_id=${CTX_BULLHORN_CORPORATION_ID}" "retries=2"
   260	fi
   261	export SCRIBE_BH_TOKEN_STATE="${BH_TOKEN_STATE}"   # validate.sh G7 reads decision_log; exported for trace only
   262	
   263	# ────────────────────────────────────────────────────────────────────────
   264	# Per-call processing — Steps 3-9 (+ per-call SLA input for Step 10).
   265	# Returns 0 = processed to completion (writes done or honestly deferred);
   266	#         1 = call skipped (Gate A fail / fetch fail / no entity).
   267	# ────────────────────────────────────────────────────────────────────────
   268	
   269	process_call() {
   270	  local meeting="$1"
   271	  local call_id title end_time duration attendees notes_md has_tx
   272	  call_id="$(jq -r '.id' <<<"${meeting}")"
   273	  title="$(jq -r '.title // ""' <<<"${meeting}")"
   274	  end_time="$(jq -r '.end_time // ""' <<<"${meeting}")"
   275	  duration="$(jq -r '.duration_minutes // 0' <<<"${meeting}")"
   276	  attendees="$(jq -r '(.attendees // []) | join(",")' <<<"${meeting}")"
   277	  notes_md="$(jq -r '.notes_markdown // ""' <<<"${meeting}")"
   278	  has_tx="$(jq -r '.has_transcript // false' <<<"${meeting}")"
   279	
   280	  local today vault_dir_phys note_file_phys vault_path_logical tmp_tx
   281	  today="$(date -u +%Y-%m-%d)"
   282	  vault_dir_phys="${VAULT_PHYS_ROOT}/${CTX_TENANT_SLUG}/scribe-notes"
   283	  note_file_phys="${vault_dir_phys}/${call_id}-${today}.md"
   284	  vault_path_logical="/vault/${CTX_TENANT_SLUG}/scribe-notes/${call_id}-${today}.md"
   285	  tmp_tx="/tmp/scribe-${CTX_TENANT_SLUG}-${call_id}.txt"
   286	
   287	  # ── Step 3 — Granola transcript fetch → /tmp 0600 ─────────────────────
   288	  # Source order: seeded fixture file/dir → @ifos/granola CLI (expected
   289	  # surface: `node dist/cli.js get-transcript --meeting <id>` → JSON
   290	  # {segments:[{start_seconds,speaker,text}]}) → notes_markdown degraded
   291	  # fallback (Free-tier guard / has_transcript=false). Paid-plan pre-guard:
   292	  # transcript fetch is a PAID_PLAN_TOOLS call — on a free workspace it is
   293	  # skipped BEFORE any wire round-trip and the run degrades to notes-only
   294	  # ingest. (ESC_GRANOLA_PLAN_TIER is QUEUED for catalogue registration; the
   295	  # degradation is recorded on the audit rows until it lands — never a fake
   296	  # ESC through an unregistered code.)
   297	  local tx_source="" ingest_mode="transcript"
   298	  rm -f "${tmp_tx}" 2>/dev/null || true
   299	
   300	  _try_fetch_transcript() {
   301	    if [[ -n "${IFOS_SCRIBE_TRANSCRIPT_FILE:-}" && -f "${IFOS_SCRIBE_TRANSCRIPT_FILE}" ]]; then
   302	      tx_source="${IFOS_SCRIBE_TRANSCRIPT_FILE}"; return 0
   303	    fi
   304	    if [[ -n "${IFOS_SCRIBE_TRANSCRIPT_DIR:-}" && -f "${IFOS_SCRIBE_TRANSCRIPT_DIR}/${call_id}.txt" ]]; then
   305	      tx_source="${IFOS_SCRIBE_TRANSCRIPT_DIR}/${call_id}.txt"; return 0
   306	    fi
   307	    if [[ -f "${GRANOLA_CLI}" ]] && command -v node >/dev/null 2>&1; then
   308	      local _gj
   309	      if _gj="$(node "${GRANOLA_CLI}" get-transcript --meeting "${call_id}" 2>/dev/null)" \
   310	           && jq -e '.segments | type=="array"' <<<"${_gj}" >/dev/null 2>&1; then
   311	        # Normalise granola segments → "[MM:SS] speaker: text" lines
   312	        jq -r '.segments[] | "[" + ((.start_seconds // 0) / 60 | floor | tostring) + ":" +
   313	               (((.start_seconds // 0) % 60 | floor | tostring) | if length < 2 then "0" + . else . end) + "] " +
   314	               (.speaker // "unknown") + ": " + (.text // "")' <<<"${_gj}" > "${tmp_tx}.cli" 2>/dev/null || return 1
   315	        tx_source="${tmp_tx}.cli"; return 0
   316	      fi
   317	      return 1
   318	    fi
   319	    return 1
   320	  }
   321	
   322	  if [[ "${CTX_GRANOLA_PLAN_TIER}" != "paid" || "${has_tx}" != "true" ]]; then
   323	    ingest_mode="notes_only_degraded"
   324	  else
   325	    if ! _try_fetch_transcript; then
   326	      sleep "${FETCH_RETRY_DELAY}"           # retry once, 30s backoff (agent.md §4 Step 3)
   327	      if ! _try_fetch_transcript; then
   328	        ingest_mode="notes_only_degraded"
   329	        autosend_escalate "ESC_PROVIDER_FETCH_FAIL" "agent=scribe" \
   330	          "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "upstream=granola" "retries=1"

exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/tools.yaml | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
     1	# Scribe agent — tools.yaml (capability declarations)
     2	#
     3	# Status: built (W6 build slice; cycle.sh/validate.sh/context.sh/cleanup.sh
     4	#         are LIVE against these declarations. Live Bullhorn + Granola smoke
     5	#         remains founder-gated: Bullhorn dev creds EMPTY + Granola IFOS-side
     6	#         OAuth token not on disk + 0 recorded meetings — spec-002 §8/§9).
     7	# Reading order: agent.md §1 (output contract) + §2 (invocation surface) +
     8	#         §4 (workflow + capability dependencies) first.
     9	#
    10	# BRIDGE NOTE (parallel-conflict rule): every @ifos/bullhorn invocation routes
    11	# through agents/recruitment/scribe/bin/bh-bridge.sh — the single
    12	# reconciliation point for the CLI bridge the Janitor build slice owns under
    13	# packages/mcp-connectors/bullhorn. The shim header documents the exact CLI
    14	# command surface it expects (refresh / update-entity / create-note).
    15	#
    16	# Per ADR-003 agent-bundle pattern: tools.yaml declares every external
    17	# capability cycle.sh invokes + the autosend-policy action_type each
    18	# state-changing call emits. cortextOS bus uses this to authorise capability
    19	# invocation per agent (no capability declared here = bus refuses the call).
    20	#
    21	# Scribe consumes BOTH @ifos/bullhorn (write surface) AND @ifos/granola
    22	# (read surface). Vendor delta from agent.md: agent.md describes Fathom /
    23	# Fireflies as the transcript provider; SKELETON uses Granola per Day-29
    24	# vendor pivot (founder confirmed 2026-06-03). cycle.sh Reading-discipline
    25	# note + scribe/agent.md Reading-discipline note document the delta.
    26	#
    27	# Action types referenced below MUST exist in agents/_shared/autosend-policy.yaml.
    28	# Scribe's 2 yellow-tier write action_types (bullhorn_scribe_field_write +
    29	# bullhorn_note_append_summary) are REGISTERED in autosend-policy.yaml
    30	# (re-verified 2026-06-10 — lines 240 + 212 respectively). scribe_cleanup /
    31	# bullhorn_oauth / granola_oauth remain QUEUED (registering them needs an
    32	# agents/_shared edit — outside this build slice's boundary; see the
    33	# registration-status footer for how each is recorded meanwhile).
    34	
    35	version: "0.1"
    36	agent: scribe
    37	
    38	capabilities:
    39	
    40	  # ────────────────────────────────────────────────────────────────────────
    41	  # Bullhorn ATS — invoked via bin/bh-bridge.sh (see BRIDGE NOTE above).
    42	  # cycle.sh Step 8 maps entity_type → Bullhorn type (candidate→Candidate,
    43	  # contact→ClientContact, brief→JobOrder, placement→Placement); opportunity
    44	  # is IFOS-cached-Postgres-only per agent.md §3 (no v1.0 Bullhorn endpoint).
    45	  # While the bridge CLI is unbuilt, Step 8 writes the IFOS entities cache and
    46	  # records bullhorn_push:deferred_bridge_unavailable on the action row;
    47	  # Step 9 defers the note attach (note_attach_deferred output row).
    48	  # Reference: bullhorn-integration-path.md §4.1 A3 (Scribe scope).
    49	  # Schema-clean post v0.4 supplement (LIVE on VPS 2026-06-03; commit a1bbcf6).
    50	  # ────────────────────────────────────────────────────────────────────────
    51	
    52	  - id: bullhorn_oauth
    53	    package: "@ifos/bullhorn"
    54	    purpose: "Bullhorn two-step OAuth refresh (Step A OAuth + Step B REST login per @ifos/bullhorn src/auth.ts); per-corporation_id Promise dedup + 401-force-refresh per cluster F R4 lesson"
    55	    action_type: bullhorn_oauth          # green tier; QUEUED for registration at W6
    56	    cycle_step: 2
    57	    secrets_required: [BULLHORN_CLIENT_ID, BULLHORN_CLIENT_SECRET]
    58	    rate_limit_hint: "per-corporation_id 600/min hard / 480/min soft (see @ifos/bullhorn README §Rate limits)"
    59	
    60	  - id: bullhorn_list_candidates
    61	    package: "@ifos/bullhorn"
    62	    purpose: "List candidates matching transcript participants (Step 4 entity resolution)"
    63	    cycle_step: 4
    64	    state_changing: false
    65	
    66	  - id: bullhorn_get_candidate
    67	    package: "@ifos/bullhorn"
    68	    purpose: "Single-entity candidate fetch (Step 4 entity hydration)"
    69	    cycle_step: 4
    70	    state_changing: false
    71	
    72	  - id: bullhorn_list_contacts
    73	    package: "@ifos/bullhorn"
    74	    purpose: "List contacts matching transcript participants (Step 4)"
    75	    cycle_step: 4
    76	    state_changing: false
    77	
    78	  - id: bullhorn_get_contact
    79	    package: "@ifos/bullhorn"
    80	    purpose: "Single-entity contact fetch (Step 4)"
    81	    cycle_step: 4
    82	    state_changing: false
    83	
    84	  - id: bullhorn_update_candidate
    85	    package: "@ifos/bullhorn"
    86	    purpose: "Write structured fields extracted from transcript onto Candidate entity (Step 8); v1.0 SUPPORTED capability"
    87	    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED in autosend-policy.yaml line 240
    88	    cycle_step: 8
    89	    state_changing: true
    90	
    91	  - id: bullhorn_update_contact
    92	    package: "@ifos/bullhorn"
    93	    purpose: "Write structured fields onto Contact entity (Step 8); v1.0 LIMITATION: requires @ifos/bullhorn v0.2+ (updateContact not yet exported); declared for ratification continuity"
    94	    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
    95	    cycle_step: 8
    96	    state_changing: true
    97	    # PENDING upstream: updateContact not yet exported by @ifos/bullhorn —
    98	    # bin/bh-bridge.sh `update-entity --type ClientContact` is the call site
    99	    # to reconcile when the Janitor bridge lands
   100	
   101	  - id: bullhorn_update_brief
   102	    package: "@ifos/bullhorn"
   103	    purpose: "Write structured fields onto Brief/JobOrder entity (Step 8); v1.0 LIMITATION: requires @ifos/bullhorn v0.2+ (updateBrief not yet exported); declared for ratification continuity"
   104	    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
   105	    cycle_step: 8
   106	    state_changing: true
   107	    # PENDING upstream: updateBrief not yet exported by @ifos/bullhorn —
   108	    # bin/bh-bridge.sh `update-entity --type JobOrder` is the call site
   109	
   110	  - id: bullhorn_update_placement
   111	    package: "@ifos/bullhorn"
   112	    purpose: "Write structured fields onto Placement entity (Step 8); v1.0 LIMITATION: requires @ifos/bullhorn v0.2+ (updatePlacement not yet exported); declared for ratification continuity"
   113	    action_type: bullhorn_scribe_field_write  # yellow tier; REGISTERED
   114	    cycle_step: 8
   115	    state_changing: true
   116	    # PENDING upstream: updatePlacement not yet exported by @ifos/bullhorn —
   117	    # bin/bh-bridge.sh `update-entity --type Placement` is the call site
   118	
   119	  - id: bullhorn_create_note
   120	    package: "@ifos/bullhorn"
   121	    purpose: "Attach tacit-note narrative (mirror of vault artefact from Step 6) onto Bullhorn entity (Step 9)"
   122	    action_type: bullhorn_note_append_summary  # yellow tier; REGISTERED in autosend-policy.yaml line 212
   123	    cycle_step: 9
   124	    state_changing: true
   125	
   126	  # ────────────────────────────────────────────────────────────────────────
   127	  # Granola MCP wrapper (read surface; 5 of 6 official tools — listFolders
   128	  # NOT consumed by Scribe per agent.md §4 + Day-29 vendor pivot)
   129	  # Reference: @ifos/granola README §Scribe consumption pattern;
   130	  # mcp.granola.ai/mcp official server.
   131	  # ────────────────────────────────────────────────────────────────────────
   132	
   133	  - id: granola_oauth
   134	    package: "@ifos/granola"
   135	    purpose: "Granola OAuth 2.1 + PKCE + DCR refresh (per-workspace_id Promise dedup + atomic file write per @ifos/granola src/auth.ts); Scribe pre-cache plan_tier='paid' via getAccountInfo at session start"
   136	    action_type: granola_oauth   # green tier; QUEUED for registration at W6
   137	    cycle_step: 2
   138	    secrets_required: [GRANOLA_CLIENT_ID]   # PKCE flow has no client_secret
   139	    rate_limit_hint: "per-workspace_id 60/min hard / 48/min soft (see @ifos/granola README §Rate limits)"
   140	
   141	  - id: granola_list_meetings
   142	    package: "@ifos/granola"
   143	    purpose: "List meetings since CTX_GRANOLA_LAST_POLL (cycle.sh Step 1 poll-sweep loop discovery); free plan returns last 30d only per Granola docs — Scribe assumes Paid (founder 2026-06-03)"
   144	    cycle_step: 1
   145	    state_changing: false
   146	
   147	  - id: granola_get_meeting
   148	    package: "@ifos/granola"
   149	    purpose: "Single-meeting hydrate for replay mode (manual --call-id <meeting_id> invocation per agent.md §2)"
   150	    cycle_step: 3
   151	    state_changing: false
   152	
   153	  - id: granola_query_meetings
   154	    package: "@ifos/granola"
   155	    purpose: "Semantic search across meeting notes (v1.1+ for backfill of historical context; v1.0 unused by cycle.sh — declared for capability surface set-equality with @ifos/granola exports)"
   156	    cycle_step: null
   157	    state_changing: false
   158	    # NOTE: declared but not consumed at v1.0 — Scribe's poll-sweep uses
   159	    # list_meetings + getTranscript; queryMeetings is for v1.1+ retroactive
   160	    # taxonomy backfill (re-running extraction against historical transcripts).
   161	
   162	  - id: granola_get_transcript
   163	    package: "@ifos/granola"
   164	    purpose: "Fetch meeting transcript with speaker segments (Step 3 per-meeting fetch); PAID PLANS ONLY — Scribe pre-guards via CTX_GRANOLA_PLAN_TIER from getAccountInfo cache (Step 0); 10-min cache TTL per @ifos/granola"
   165	    cycle_step: 3
   166	    state_changing: false
   167	    plan_tier_required: paid   # Scribe gates this before invocation
   168	
   169	  - id: granola_get_account_info
   170	    package: "@ifos/granola"
   171	    purpose: "Workspace + plan_tier introspection (context.sh Step 3 pre-caches plan_tier='paid' for the cycle.sh session; 1h TTL per @ifos/granola)"
   172	    cycle_step: 0
   173	    state_changing: false
   174	
   175	  # ────────────────────────────────────────────────────────────────────────
   176	  # Voice classifier (Step 6 tacit-note narrative voice scoring)
   177	  # Reference: agent.md §7; _shared/voice-loader.sh + hh_load_tone_rules.
   178	  # ────────────────────────────────────────────────────────────────────────
   179	
   180	  - id: voice_classifier
   181	    package: "@ifos/voice-classifier"   # W4-5 polish microservice (per agent.md §8 build deps)
   182	    purpose: "Score tacit-note narrative against tenant voice corpus (≥0.75 required by Gate A G3); ESC_VOICE_DRIFT below threshold after 3 retries"
   183	    cycle_step: 6
   184	    state_changing: false
   185	    # NOTE: @ifos/voice-classifier microservice is W4-5 polish work per
   186	    # agent.md §8 — may not exist as a standalone package at this scaffold
   187	    # state; cycle.sh Step 6 will integrate with whatever shape that lands
   188	    # at W4-5 (likely an HTTP microservice OR an LLM-prompt-wrapper).
   189	
   190	  # ────────────────────────────────────────────────────────────────────────
   191	  # Cleanup (cleanup.sh)
   192	  # ────────────────────────────────────────────────────────────────────────
   193	
   194	  - id: scribe_cleanup
   195	    purpose: "Post-run cleanup (transient @ifos/bullhorn + @ifos/granola cache purge + /tmp transcript purge + last-poll cache file update)"
   196	    action_type: scribe_cleanup   # green tier; QUEUED for registration at W6
   197	    state_changing: false
   198	    cycle_step: 10
   199	
   200	# ──────────────────────────────────────────────────────────────────────────────
   201	# Failure-modes table (per cluster Fbis pattern; ESC mapping per agent.md §6)
   202	# ──────────────────────────────────────────────────────────────────────────────
   203	
   204	failure_modes:
   205	
   206	  - condition: "@ifos/bullhorn OAuth refresh fails after 2 retries (cycle.sh Step 2)"
   207	    surface: "BullhornAuthError thrown by @ifos/bullhorn"
   208	    escalation: ESC_BULLHORN_AUTH    # blocking; operator + ifos_oncall_chat_id per catalogue §2.5
   209	
   210	  - condition: "@ifos/granola OAuth refresh fails (cycle.sh Step 2; context.sh Step 5)"
   211	    surface: "GranolaAuthError thrown by @ifos/granola"
   212	    escalation: ESC_GRANOLA_AUTH     # blocking-equivalent; QUEUED for catalogue registration at W6
   213	    queued: true
   214	
   215	  - condition: "@ifos/bullhorn returns 4xx/5xx on Step 8 field write OR Step 9 note attach"
   216	    surface: "BullhornError (4xx skip; 5xx retry-once-then-skip)"
   217	    escalation: ESC_BULLHORN_WRITE_FAIL   # warn; operator_chat_id
   218	
   219	  - condition: "@ifos/granola returns 4xx/5xx on Step 1 listMeetings OR Step 3 getTranscript"
   220	    surface: "GranolaError; per agent.md §6 ESC_PROVIDER_FETCH_FAIL covers transcript-provider failures generically (v1.0 payload extension upstream='granola')"
   221	    escalation: ESC_PROVIDER_FETCH_FAIL   # warn; operator_chat_id
   222	
   223	  - condition: "@ifos/granola returns 403 on Step 3 getTranscript (Paid-plan tool on Free workspace)"
   224	    surface: "GranolaPlanTierInsufficientError"
   225	    escalation: ESC_GRANOLA_PLAN_TIER     # warn; QUEUED for catalogue registration at W6; consumer degrades to notes-only ingest
   226	
   227	  - condition: "@ifos/bullhorn OR @ifos/granola returns 429"
   228	    surface: "BullhornRateLimitError OR GranolaRateLimitError"
   229	    escalation: ESC_RATE_LIMIT_HIT   # warn; operator_chat_id; payload.upstream='bullhorn'|'granola'
   230	
   231	  - condition: "Tacit-note voice classifier <0.75 after 3 retries (Step 6 → validate.sh G3)"
   232	    surface: "validate.sh exit 1 with G3 failure"
   233	    escalation: ESC_VOICE_DRIFT      # warn; operator_chat_id
   234	
   235	  - condition: "PII detected outside firm boundary in tacit-note narrative (validate.sh G6)"
   236	    surface: "validate.sh exit 1 with G6 failure"
   237	    escalation: ESC_PII_LEAKAGE_RISK   # blocking; operator + ifos_oncall_chat_id
   238	
   239	  - condition: "<3 structured-field extractions with confidence ≥0.6 (Step 5 → validate.sh G2)"
   240	    surface: "validate.sh exit 1 with G2 failure"

codex
The bundle is no longer just a pre-build scaffold: `validate.sh` and `tools.yaml` both identify themselves as W6 live/built, while `agent.md` still describes the old webhook/Fathom contract. I’m narrowing this to load-bearing rejection issues rather than cosmetic drift.
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/validate.sh | sed -n '256,420p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
exec
/bin/zsh -lc "nl -ba agents/recruitment/scribe/cycle.sh | sed -n '330,620p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
   256	# ────────────────────────────────────────────────────────────────────────
   257	# G7 — Bullhorn auth refresh succeeded this session
   258	# Re-query decision_log for a fresh bullhorn_auth_refreshed row (≤10 min)
   259	# whose result is fresh|refreshed. unavailable/failed/absent = hard fail —
   260	# no stale-token (or no-token) Bullhorn writes, ever.
   261	# ────────────────────────────────────────────────────────────────────────
   262	
   263	_auth_row=""
   264	if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   265	  _auth_row="$(psql "${IFOS_DB_URL}" -tAq --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1
   266	BEGIN;
   267	SET LOCAL app.current_tenant = :'tenant';
   268	SELECT reason FROM decision_log
   269	WHERE tenant_slug = :'tenant' AND agent_name = 'scribe'
   270	  AND payload->>'output_type' = 'bullhorn_auth_refreshed'
   271	  AND created_at > now() - interval '10 minutes'
   272	ORDER BY id DESC LIMIT 1;
   273	COMMIT;
   274	SQL
   275	)"
   276	  if [[ "${_auth_row}" == *"result:fresh"* || "${_auth_row}" == *"result:refreshed"* ]]; then
   277	    _ok "G7: Bullhorn auth refreshed this session (${_auth_row##*result:})"
   278	  else
   279	    _fail "G7: no fresh successful bullhorn_auth_refreshed row (got: '${_auth_row:-none}') — Bullhorn writes blocked"
   280	    ESC_CLASS="${ESC_CLASS:-ESC_BULLHORN_AUTH}"
   281	  fi
   282	else
   283	  _warn "G7: DB unavailable — cannot confirm auth refresh (offline-mode fallback rows not queryable)"
   284	fi
   285	
   286	# ────────────────────────────────────────────────────────────────────────
   287	# G8 — Tacit-note word count ≤800 (agent.md §3 cap; kept from the skeleton
   288	# in ADDITION to the 7 spec-002 §5 checks — notes must stay scannable;
   289	# long-form analysis belongs in the vault, not Bullhorn)
   290	# ────────────────────────────────────────────────────────────────────────
   291	
   292	_words="$(jq -r '.tacit_note.narrative_word_count // 0' "${PROPOSAL}")"
   293	if [[ "${_words}" =~ ^[0-9]+$ ]] && (( _words <= TACIT_NOTE_WORD_CAP )); then
   294	  _ok "G8: tacit-note word count ${_words} ≤ ${TACIT_NOTE_WORD_CAP}"
   295	else
   296	  _fail "G8: tacit-note word count ${_words} exceeds ${TACIT_NOTE_WORD_CAP} cap"
   297	  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
   298	fi
   299	
   300	# ────────────────────────────────────────────────────────────────────────
   301	# Verdict + audit-row emission
   302	# ────────────────────────────────────────────────────────────────────────
   303	
   304	printf '\nScribe validate Gate A: '
   305	if [[ ${#FAILURES[@]} -gt 0 ]]; then
   306	  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
   307	  # Per-failure-class ESC routing (spec-002 §5): G1 → ESC_INPUT_VALIDATION_FAIL;
   308	  # G2 → ESC_FIELD_EXTRACTION_LOW_CONFIDENCE; G3 → ESC_VOICE_DRIFT;
   309	  # G4/G5 → ESC_SCHEMA_VIOLATION; G6 → ESC_PII_LEAKAGE_RISK (blocking);
   310	  # G7 → ESC_BULLHORN_AUTH (blocking); G8 → ESC_AGENT_OUTPUT_SHAPE.
   311	  autosend_escalate "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}" "agent=scribe" \
   312	    "tenant=${CTX_TENANT_SLUG}" "call=${CALL_ID}" \
   313	    "entity=${ENTITY_TYPE}:${BULLHORN_ID}" "failures=${#FAILURES[@]}"
   314	  _gate_hash="$(printf '%s' "${CALL_ID}|${ENTITY_TYPE}|${BULLHORN_ID}" | shasum -a 256 2>/dev/null | cut -c1-16)"
   315	  [[ -z "${_gate_hash}" ]] && _gate_hash="${CALL_ID}"
   316	  hh_decision_action "validate_gate_a_fail" "${ENTITY_TYPE}:${BULLHORN_ID}" "${_gate_hash}" \
   317	    "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}; agent_name:scribe; call:${CALL_ID}; failures:${#FAILURES[@]}; first:${FAILURES[0]}" || true
   318	  exit 1
   319	fi
   320	printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
   321	exit 0

 succeeded in 0ms:
   330	          "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "upstream=granola" "retries=1"
   331	      fi
   332	    fi
   333	  fi
   334	
   335	  ( umask 177
   336	    if [[ "${ingest_mode}" == "transcript" ]]; then
   337	      cp "${tx_source}" "${tmp_tx}"
   338	    else
   339	      printf '%s\n' "${notes_md}" > "${tmp_tx}"
   340	    fi
   341	  )
   342	  rm -f "${tmp_tx}.cli" 2>/dev/null || true
   343	  chmod 0600 "${tmp_tx}" 2>/dev/null || true
   344	  if [[ ! -s "${tmp_tx}" ]]; then
   345	    # No transcript AND no notes — nothing to ingest for this call.
   346	    autosend_escalate "ESC_PROVIDER_FETCH_FAIL" "agent=scribe" \
   347	      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "upstream=granola" "reason=no_transcript_and_no_notes"
   348	    rm -f "${tmp_tx}" 2>/dev/null || true
   349	    return 1
   350	  fi
   351	  local tx_bytes
   352	  tx_bytes="$(wc -c < "${tmp_tx}" | tr -d ' ')"
   353	  hh_decision_output "transcript_fetched" "call:${call_id}" \
   354	    "provider:granola; bytes:${tx_bytes}; tmp_path:${tmp_tx}; ingest_mode:${ingest_mode}; plan_tier:${CTX_GRANOLA_PLAN_TIER}"
   355	
   356	  # ── Step 4 — Participant → entity inference (IFOS-cached entities) ────
   357	  # Match non-firm participant emails against the RLS-scoped entities cache;
   358	  # priority placement > brief > opportunity > contact > candidate (the most
   359	  # context-specific entity wins — a placed candidate's check-in call should
   360	  # resolve to the Placement, not the Candidate).
   361	  local ext_emails="" e
   362	  for e in ${attendees//,/ }; do
   363	    [[ -z "${e}" ]] && continue
   364	    local dom="${e##*@}" is_firm=0 fd
   365	    for fd in ${CTX_FIRM_DOMAIN_WHITELIST//,/ }; do
   366	      [[ "${dom,,}" == "${fd,,}" ]] && is_firm=1
   367	    done
   368	    [[ "${is_firm}" -eq 0 ]] && ext_emails+="${ext_emails:+,}${e,,}"
   369	  done
   370	
   371	  local resolved="" entity_type="" bullhorn_id="" confidence="0"
   372	  if [[ -n "${ext_emails}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   373	    resolved="$(_psql_t --set=emails="${ext_emails}" <<'SQL' 2>/dev/null | grep -E '\|' | head -1 || true
   374	BEGIN;
   375	SET LOCAL app.current_tenant = :'tenant';
   376	SELECT entity_type || '|' || entity_id
   377	FROM entities
   378	WHERE tenant_slug = :'tenant'
   379	  AND ( lower(coalesce(data->>'email',''))           = ANY (string_to_array(:'emails', ','))
   380	     OR lower(coalesce(data->>'candidate_email','')) = ANY (string_to_array(:'emails', ',')) )
   381	ORDER BY array_position(ARRAY['placement','brief','opportunity','contact','candidate'], entity_type)
   382	LIMIT 1;
   383	COMMIT;
   384	SQL
   385	)"
   386	  fi
   387	  if [[ -z "${resolved}" ]]; then
   388	    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=scribe" \
   389	      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "reason=no_resolvable_target_entity"
   390	    hh_decision_action "validate_gate_a_fail" "call:${call_id}" "no-entity-${call_id}" \
   391	      "ESC_AGENT_OUTPUT_SHAPE; agent_name:scribe; step:4; participants:${ext_emails:-none}" || true
   392	    return 1
   393	  fi
   394	  entity_type="${resolved%%|*}"
   395	  bullhorn_id="${resolved#*|}"
   396	  confidence="0.95"   # exact email match against the cached entity (deterministic resolver)
   397	  hh_decision_output "entity_resolved" "${entity_type}:${bullhorn_id}" \
   398	    "call:${call_id}; confidence:${confidence}; match:email_exact"
   399	
   400	  # ── Step 5 — Field extraction (≥3 fields ≥0.6 per Gate A) ─────────────
   401	  local fields_file="${tmp_tx%.txt}-fields.json"
   402	  if ! bash "${_BIN}/extract-fields.sh" --transcript "${tmp_tx}" --entity-type "${entity_type}" \
   403	        --call-id "${call_id}" --vault-path "${vault_path_logical}" > "${fields_file}" 2>/dev/null; then
   404	    printf '[]\n' > "${fields_file}"
   405	  fi
   406	  chmod 0600 "${fields_file}" 2>/dev/null || true
   407	  local n_above
   408	  n_above="$(jq '[.[] | select(.confidence >= 0.6)] | length' "${fields_file}" 2>/dev/null || echo 0)"
   409	  hh_decision_output "fields_extracted" "${entity_type}:${bullhorn_id}" \
   410	    "call:${call_id}; fields_above_threshold:${n_above}; extractor:$( [[ "${IFOS_SCRIBE_USE_LLM:-0}" == "1" && -n "${ANTHROPIC_API_KEY:-}" ]] && echo llm_with_deterministic_fallback || echo deterministic ); ingest_mode:${ingest_mode}"
   411	  if [[ "${n_above}" -lt 3 ]]; then
   412	    autosend_escalate "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE" "agent=scribe" \
   413	      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "fields_above_threshold=${n_above}" "required=3"
   414	    hh_decision_action "validate_gate_a_fail" "${entity_type}:${bullhorn_id}" "lowconf-${call_id}" \
   415	      "ESC_FIELD_EXTRACTION_LOW_CONFIDENCE; agent_name:scribe; step:5; fields:${n_above}" || true
   416	    rm -f "${fields_file}" 2>/dev/null || true
   417	    return 1
   418	  fi
   419	  # Drop sub-threshold fields before Step 7 (agent.md §4 Step 5).
   420	  jq '[.[] | select(.confidence >= 0.6)]' "${fields_file}" > "${fields_file}.f" && mv "${fields_file}.f" "${fields_file}"
   421	
   422	  # ── Step 6 — Tacit-note generation → vault 0600 (canonical per ADR-002) ─
   423	  # Voice score resolution (HONEST — never faked):
   424	  #   IFOS_FORCE_VOICE_SCORE  → numeric (fixture/test hook + future classifier wire-in)
   425	  #   active voice_corpus     → unscored/no_classifier (corpus exists; the
   426	  #                             classifier microservice is W4-5 polish, not built)
   427	  #   no corpus               → unscored/no_corpus (CC precedent)
   428	  # The 3-retry loop of agent.md §4 Step 6 only makes sense for a
   429	  # non-deterministic (LLM) generator; the deterministic renderer emits one
   430	  # canonical rendering, so retries:0 is recorded.
   431	  local voice_score voice_reason needs_review="" retries=0
   432	  if [[ -n "${IFOS_FORCE_VOICE_SCORE:-}" ]]; then
   433	    voice_score="${IFOS_FORCE_VOICE_SCORE}"
   434	    voice_reason="forced_test_score"
   435	    retries="${IFOS_FORCE_VOICE_RETRIES:-0}"
   436	    if awk -v s="${voice_score}" 'BEGIN{exit !(s < 0.75)}'; then
   437	      needs_review="--needs-review"
   438	    fi
   439	  elif [[ "${CTX_VOICE_CORPUS_ID}" != "none" ]]; then
   440	    voice_score="unscored"; voice_reason="no_classifier"
   441	  else
   442	    voice_score="unscored"; voice_reason="no_corpus"
   443	  fi
   444	
   445	  mkdir -p "${vault_dir_phys}" 2>/dev/null || true
   446	  chmod 0700 "${vault_dir_phys}" 2>/dev/null || true
   447	  local render_args=(--call-id "${call_id}" --date "${today}" --transcript "${tmp_tx}"
   448	    --participants "${attendees}" --duration-min "${duration}"
   449	    --voice-score "${voice_score}" --voice-reason "${voice_reason}")
   450	  [[ -n "${title}" ]] && render_args+=(--context "${title}")
   451	  [[ -n "${needs_review}" ]] && render_args+=("${needs_review}")
   452	  if ! bash "${_BIN}/render-tacit-note.sh" "${render_args[@]}" > "${note_file_phys}.tmp" 2>/dev/null; then
   453	    rm -f "${note_file_phys}.tmp" 2>/dev/null || true
   454	    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=scribe" \
   455	      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "reason=tacit_note_render_failed"
   456	    return 1
   457	  fi
   458	  mv "${note_file_phys}.tmp" "${note_file_phys}"
   459	  chmod 0600 "${note_file_phys}" 2>/dev/null || true
   460	  local body_sha words
   461	  body_sha="$(shasum -a 256 "${note_file_phys}" 2>/dev/null | cut -c1-16)"
   462	  [[ -z "${body_sha}" ]] && body_sha="na"
   463	  words="$(wc -w < "${note_file_phys}" | tr -d ' ')"
   464	  # ADR-002: metadata ONLY — {vault_path, body_sha256, voice_score}; body NEVER in payload.
   465	  hh_decision_output "tacit_note_rendered" "${vault_path_logical}" \
   466	    "vault_path:${vault_path_logical}; body_sha256:${body_sha}; voice_score:${voice_score}; voice_reason:${voice_reason}; words:${words}; retries:${retries}"
   467	
   468	  # ── Step 7 — Schema validation (names + types/ranges) + Gate A ────────
   469	  local vres valid_count dropped_count
   470	  vres="$(bash "${_BIN}/validate-fields.sh" --entity-type "${entity_type}" --fields-file "${fields_file}" 2>/dev/null || echo '{"valid":[],"dropped":[],"valid_count":0}')"
   471	  valid_count="$(jq -r '.valid_count' <<<"${vres}")"
   472	  dropped_count="$(jq -r '.dropped | length' <<<"${vres}")"
   473	  if [[ "${valid_count}" -lt 3 ]]; then
   474	    autosend_escalate "ESC_SCHEMA_VIOLATION" "agent=scribe" \
   475	      "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "valid=${valid_count}" "dropped=${dropped_count}"
   476	    hh_decision_action "validate_gate_a_fail" "${entity_type}:${bullhorn_id}" "schema-${call_id}" \
   477	      "ESC_SCHEMA_VIOLATION; agent_name:scribe; step:7; valid:${valid_count}; dropped:${dropped_count}" || true
   478	    rm -f "${fields_file}" 2>/dev/null || true
   479	    return 1
   480	  fi
   481	  hh_decision_output "fields_validated" "${entity_type}:${bullhorn_id}" \
   482	    "call:${call_id}; valid:${valid_count} of $(jq 'length' "${fields_file}") extracted; dropped:${dropped_count}"
   483	
   484	  # Build the Gate A proposal + run validate.sh (hard gate between Step 7 and 8).
   485	  local proposal="${tmp_tx%.txt}-proposal.json" preview
   486	  preview="$(sed -n '/^---$/,/^---$/!p' "${note_file_phys}" | head -c 500 | tr '\n' ' ')"
   487	  jq -nc --arg call_id "${call_id}" --arg et "${entity_type}" --arg bid "${bullhorn_id}" \
   488	     --arg sig "${WEBHOOK_SIG_STATE}" --argjson fields "$(jq -c '.valid' <<<"${vres}")" \
   489	     --arg vp "${vault_path_logical}" --arg sha "${body_sha}" --arg vs "${voice_score}" \
   490	     --arg vr "${voice_reason}" --argjson words "${words}" --arg pv "${preview}" '{
   491	       call_id: $call_id, entity_type: $et, bullhorn_id: $bid,
   492	       webhook_sig_state: $sig, fields_extracted: $fields,
   493	       tacit_note: { vault_path: $vp, body_sha256: $sha, voice_score: $vs,
   494	                     voice_reason: $vr, narrative_word_count: $words,
   495	                     narrative_body_preview: $pv } }' > "${proposal}"
   496	  chmod 0600 "${proposal}" 2>/dev/null || true
   497	
   498	  local _validate="${CTX_AGENT_DIR}/validate.sh"
   499	  [[ -f "${_validate}" ]] || _validate="${IFOS_REPO_ROOT:-}/agents/recruitment/scribe/validate.sh"
   500	  if ! bash "${_validate}" "${proposal}" >/dev/null 2>&1; then
   501	    # validate.sh already emitted the ESC + validate_gate_a_fail rows.
   502	    # Transcript stays in /tmp (auto-purged 24h by cleanup.sh); vault note is
   503	    # flagged needs_consultant_review by Step 6 when the voice path failed.
   504	    rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
   505	    return 1
   506	  fi
   507	
   508	  if [[ "${MODE}" == "dry-run" ]]; then
   509	    hh_decision_output "dry_run_writes_skipped" "call:${call_id}" \
   510	      "would_write_field_count:${valid_count}; would_attach_note:true"
   511	    rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
   512	    return 0
   513	  fi
   514	
   515	  # ── Step 8 — Bullhorn field write (yellow, atomic; rollback snapshot) ──
   516	  # The IFOS-cached entities row is the write target (defence-in-depth: the
   517	  # validate_entities_data_v0_3 trigger re-enforces shapes at write time);
   518	  # the Bullhorn PATCH push goes through bh-bridge.sh. opportunity is
   519	  # IFOS-cache ONLY per agent.md §3 (no v1.0 Bullhorn endpoint).
   520	  local field_map prior_data="" push_state="cache_only_by_design" bh_type=""
   521	  field_map="$(jq -c '.valid | map({(.field_name): .value}) | add' <<<"${vres}")"
   522	  case "${entity_type}" in
   523	    candidate) bh_type="Candidate" ;;
   524	    contact)   bh_type="ClientContact" ;;
   525	    brief)     bh_type="JobOrder" ;;
   526	    placement) bh_type="Placement" ;;
   527	    opportunity) bh_type="" ;;
   528	  esac
   529	
   530	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   531	    prior_data="$(_psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" <<'SQL' 2>/dev/null | head -1 || true
   532	BEGIN;
   533	SET LOCAL app.current_tenant = :'tenant';
   534	SELECT data::text FROM entities
   535	WHERE tenant_slug = :'tenant' AND entity_type = :'et' AND entity_id = :'eid' LIMIT 1;
   536	COMMIT;
   537	SQL
   538	)"
   539	    if ! _psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" --set=fm="${field_map}" >/dev/null 2>&1 <<'SQL'
   540	BEGIN;
   541	SET LOCAL app.current_tenant = :'tenant';
   542	UPDATE entities
   543	SET data = data || :'fm'::jsonb, version = version + 1, updated_at = now()
   544	WHERE tenant_slug = :'tenant' AND entity_type = :'et' AND entity_id = :'eid';
   545	COMMIT;
   546	SQL
   547	    then
   548	      autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=scribe" \
   549	        "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "entity=${entity_type}:${bullhorn_id}" "surface=entities_cache_update"
   550	      rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
   551	      return 1
   552	    fi
   553	  fi
   554	
   555	  if [[ -n "${bh_type}" ]]; then
   556	    local _prc=0
   557	    bash "${_BIN}/bh-bridge.sh" update-entity --type "${bh_type}" --id "${bullhorn_id}" \
   558	      --fields "${field_map}" >/dev/null 2>&1 || _prc=$?
   559	    case "${_prc}" in
   560	      0) push_state="pushed" ;;
   561	      3) push_state="deferred_bridge_unavailable" ;;
   562	      *) # Bullhorn PATCH hard-failed → roll the cache back; do NOT proceed to Step 9.
   563	         if [[ -n "${prior_data}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   564	           _psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" --set=pd="${prior_data}" >/dev/null 2>&1 <<'SQL' || true
   565	BEGIN;
   566	SET LOCAL app.current_tenant = :'tenant';
   567	UPDATE entities SET data = :'pd'::jsonb, version = version + 1, updated_at = now()
   568	WHERE tenant_slug = :'tenant' AND entity_type = :'et' AND entity_id = :'eid';
   569	COMMIT;
   570	SQL
   571	         fi
   572	         autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=scribe" \
   573	           "tenant=${CTX_TENANT_SLUG}" "call=${call_id}" "entity=${entity_type}:${bullhorn_id}" "surface=bullhorn_patch"
   574	         rm -f "${fields_file}" "${proposal}" 2>/dev/null || true
   575	         return 1 ;;
   576	    esac
   577	  fi
   578	
   579	  local payload_hash
   580	  payload_hash="$(printf '%s' "${call_id}|${entity_type}|${bullhorn_id}|${field_map}" | shasum -a 256 2>/dev/null | cut -c1-16)"
   581	  [[ -z "${payload_hash}" ]] && payload_hash="${call_id}"
   582	  hh_decision_action "bullhorn_scribe_field_write" "${entity_type}:${bullhorn_id}" "${payload_hash}" \
   583	    "call:${call_id}; fields_written:${valid_count}; bullhorn_push:${push_state}; ingest_mode:${ingest_mode}" || true
   584	  FIELD_WRITES=$((FIELD_WRITES + 1))
   585	
   586	  # Gate B edit-rate basis (spec-002 §3 downstream contract): one recent_edit
   587	  # row per field write, resolution='deferred' until a consultant reviews.
   588	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   589	    _psql_t --set=et="${entity_type}" --set=eid="${bullhorn_id}" --set=fm="${field_map}" >/dev/null 2>&1 <<'SQL' || true
   590	BEGIN;
   591	SET LOCAL app.current_tenant = :'tenant';
   592	INSERT INTO recent_edit (tenant_slug, agent_name, action_type, target_entity_type,
   593	                         target_entity_id, original_text, resolution, resolved_at)
   594	VALUES (:'tenant', 'scribe', 'bullhorn_scribe_field_write', :'et', :'eid', :'fm', 'deferred', now());
   595	COMMIT;
   596	SQL
   597	  fi
   598	
   599	  # ── Step 9 — Bullhorn note attach (yellow); rollback Step 8 on hard fail ─
   600	  local _nrc=0
   601	  if [[ -n "${bh_type}" ]]; then
   602	    bash "${_BIN}/bh-bridge.sh" create-note --entity-type "${bh_type}" --entity-id "${bullhorn_id}" \
   603	      --body-file "${note_file_phys}" --title "Scribe tacit notes — ${call_id}" >/dev/null 2>&1 || _nrc=$?
   604	  else
   605	    _nrc=4   # opportunity: cache-only entity, no Bullhorn Note target at v1.0
   606	  fi
   607	  case "${_nrc}" in
   608	    0)
   609	      hh_decision_action "bullhorn_note_append_summary" "${entity_type}:${bullhorn_id}" "${body_sha}" \
   610	        "call:${call_id}; vault_path:${vault_path_logical}; note_payload_hash:${body_sha}; words:${words}" || true
   611	      NOTE_ATTACHES=$((NOTE_ATTACHES + 1)) ;;
   612	    3)
   613	      # Bridge unavailable: NO Bullhorn state changed → no yellow action row
   614	      # (honest signal); the vault note is the canonical artefact and a
   615	      # consultant attaches manually until the bridge lands.
   616	      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
   617	        "call:${call_id}; vault_path:${vault_path_logical}; reason:bridge_unavailable" ;;
   618	    4)
   619	      hh_decision_output "note_attach_deferred" "${entity_type}:${bullhorn_id}" \
   620	        "call:${call_id}; vault_path:${vault_path_logical}; reason:opportunity_cache_only_no_note_endpoint" ;;

exec
/bin/zsh -lc 'rg -n "Fathom|Fireflies|Granola|webhook|poll|poll-sweep|agent.md" agents/recruitment/scribe docs/features/agent-build/02-specs/spec-002-scribe.md docs/features/agent-build/03-implementation/scribe-summary.md -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
docs/features/agent-build/02-specs/spec-002-scribe.md:3:**A sub-agent given ONLY this file + `agents/recruitment/scribe/agent.md` + the Cash Conductor
docs/features/agent-build/02-specs/spec-002-scribe.md:7:- **Master-plan source (READ IN FULL):** `agents/recruitment/scribe/agent.md`
docs/features/agent-build/02-specs/spec-002-scribe.md:9:- **Wave/tier:** v1.0 W6; Tier 1 webhook-driven. **Scribe is the data spine (agent.md §1).**
docs/features/agent-build/02-specs/spec-002-scribe.md:10:- **⚠ TRANSCRIPT VENDOR = GRANOLA (`@ifos/granola`).** The agent.md §4 Step 3 text still names Fathom/Fireflies — that is PRE-PIVOT and WRONG. The W5 Day-29 vendor pivot moved Scribe's transcript source to **Granola**. Build every transcript-fetch path against `@ifos/granola`. Do NOT implement Fathom or Fireflies. (See §2, §4 Step 3, §8.)
docs/features/agent-build/02-specs/spec-002-scribe.md:14:agent.md §3-§6: the 10-step per-call workflow, ≥3 structured Bullhorn field writes + 1 tacit-note
docs/features/agent-build/02-specs/spec-002-scribe.md:20:- **Postgres (v0.3/v0.4 schema):** `entities` (Bullhorn cache: Candidate/Contact/Brief/Placement + IFOS-cached Opportunity v0.3 fields), `recent_edit` (Gate B edit-rate measurement), `decision_log`, `voice_corpus`. **Confirm the v0.3-supplement field names exist** (must_haves/nice_to_haves/deal_breakers on Brief; placement_status/satisfaction_signal/week_1_status_vault_path on Placement; headcount_growth_signal_text/hiring_velocity_band/decision_window_text on Opportunity) — agent.md §3 flags re-verifying these against the supplement; if a field is missing that is an Upstream-contract item to land on main first.
docs/features/agent-build/02-specs/spec-002-scribe.md:25:- decision_log markers: `webhook_verified`, `bullhorn_auth_refreshed`, `transcript_fetched`, `entity_resolved`, `fields_extracted`, `tacit_note_rendered` (output, `{vault_path,body_sha256,voice_score}` — body NOT in payload per ADR-002), `fields_validated`, + action rows `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`, `scribe_run_complete`.
docs/features/agent-build/02-specs/spec-002-scribe.md:28:## 4. Workflow steps to wire (agent.md §4 — EVERY step)
docs/features/agent-build/02-specs/spec-002-scribe.md:31:| 0 | Session start (webhook handler); context.sh hydrate | `hh_decision_trigger session_start` | — | CC Step 0 |
docs/features/agent-build/02-specs/spec-002-scribe.md:32:| 1 | Webhook signature verify (HMAC/bearer) | `webhook_verified` | `ESC_INPUT_VALIDATION_FAIL` (401) | — |
docs/features/agent-build/02-specs/spec-002-scribe.md:34:| 3 | Transcript fetch (**Granola** — see §8) → /tmp 0600 | `transcript_fetched` | `ESC_PROVIDER_FETCH_FAIL`, `ESC_PII_LEAKAGE_RISK` | — |
docs/features/agent-build/02-specs/spec-002-scribe.md:41:| 10 | Session close + SLA metric (elapsed since webhook) | `scribe_run_complete` | `ESC_SCRIBE_SLA_MISS` (>30min render / >1h attach) | CC Step 14 |
docs/features/agent-build/02-specs/spec-002-scribe.md:43:## 5. Gate A (validate.sh) — every check (agent.md §5)
docs/features/agent-build/02-specs/spec-002-scribe.md:46:| webhook-sig | valid per provider | `ESC_INPUT_VALIDATION_FAIL` | hard |
docs/features/agent-build/02-specs/spec-002-scribe.md:60:- `scripts/run-scribe-gate-a-test.sh` — PASS + each fail class (webhook-sig, field-count, voice, schema, PII) + ESC routes (register tenant first; decision_log FK).
docs/features/agent-build/02-specs/spec-002-scribe.md:65:- **🟡 VENDOR = GRANOLA, not Fathom/Fireflies.** agent.md §4 Step 3 text still names Fathom/Fireflies, but the W5 Day-29 pivot moved the transcript vendor to **Granola** (`@ifos/granola`). Wire Step 3 to Granola. Granola live path is itself blocked: IFOS-side OAuth token not on disk (the Claude-Code MCP token is in keychain, not the `~/.ifos-local-vault/<tenant>/granola-tokens-*.json` path the connector reads) + the test workspace has 0 recorded meetings. So Step 3 live-smoke is blocked; fixture-prove with a seeded transcript file.
docs/features/agent-build/02-specs/spec-002-scribe.md:70:- Blocked-for-live by: Bullhorn creds + Granola IFOS-side OAuth token + ≥1 recorded meeting (all founder actions). NOT blocked for build/fixtures.
docs/features/agent-build/03-implementation/scribe-summary.md:6:Live Bullhorn/Granola smoke **founder-gated** (see Honest scope).
docs/features/agent-build/03-implementation/scribe-summary.md:13:| 1 | `webhook_verified` (+ `granola_meetings_polled` discovery row) | LIVE — mode=webhook does real HMAC-SHA256 (`openssl`, secret `$SCRIBE_WEBHOOK_SECRET`) or bearer compare; mismatch → `ESC_INPUT_VALIDATION_FAIL` + exit 1 (the 401 path). poll-sweep/replay emit `signature:not_applicable` honestly (Granola publishes no webhooks — Deviation 1) |
docs/features/agent-build/03-implementation/scribe-summary.md:15:| 3 | `transcript_fetched` | LIVE — Granola vendor; sources: seeded fixture file/dir → `@ifos/granola` CLI (expected surface documented; not built) → notes-only degraded ingest; /tmp file mode 0600; retry-once 30s → `ESC_PROVIDER_FETCH_FAIL` (upstream=granola) |
docs/features/agent-build/03-implementation/scribe-summary.md:24:All 7 spec-002 §5 Gate A checks LIVE in `validate.sh` (G1 webhook-sig, G2 field-count,
docs/features/agent-build/03-implementation/scribe-summary.md:26:G7 auth re-query) plus G8 word-cap (agent.md §3, retained from skeleton).
docs/features/agent-build/03-implementation/scribe-summary.md:33:| `scripts/run-scribe-gate-a-test.sh` | PASS — 19 assertions: 2 PASS paths (verified-sig and poll-trigger + warn-when-unscored) + 8 fail classes each with ESC routing asserted (`ESC_BULLHORN_AUTH`, `ESC_INPUT_VALIDATION_FAIL`, `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`, `ESC_VOICE_DRIFT`, `ESC_SCHEMA_VIOLATION`×2, `ESC_PII_LEAKAGE_RISK`, `ESC_AGENT_OUTPUT_SHAPE`) + 8 `validate_gate_a_fail` rows |
docs/features/agent-build/03-implementation/scribe-summary.md:38:1. **Webhook + poll dual trigger.** spec-002 §4 Step 1 mandates webhook signature
docs/features/agent-build/03-implementation/scribe-summary.md:39:   verification; the Day-29 vendor (Granola) publishes no webhooks. Built BOTH:
docs/features/agent-build/03-implementation/scribe-summary.md:40:   mode=webhook with real HMAC/bearer verification (agent.md §2 surface), and the
docs/features/agent-build/03-implementation/scribe-summary.md:41:   poll-sweep operational path emitting `webhook_verified` with
docs/features/agent-build/03-implementation/scribe-summary.md:45:2. **`granola_meetings_polled` retained** as an additional discovery output row
docs/features/agent-build/03-implementation/scribe-summary.md:47:   the Granola-pivot operational record (count, window, workspace).
docs/features/agent-build/03-implementation/scribe-summary.md:53:   (agent.md §6 sanctioned). Fixture 02 documents the post-registration contract.
docs/features/agent-build/03-implementation/scribe-summary.md:61:5. **Voice retries.** agent.md's 3-retry voice loop presumes a non-deterministic
docs/features/agent-build/03-implementation/scribe-summary.md:78:9. **agent.md untouched** (founder-gated status + W6-ratification rewrite). Its
docs/features/agent-build/03-implementation/scribe-summary.md:79:   §4 Step 3 Fathom/Fireflies text remains PRE-PIVOT prose; the divergence is
docs/features/agent-build/03-implementation/scribe-summary.md:80:   tracked at contract level (spec-002 §8 + this summary), implemented as Granola.
docs/features/agent-build/03-implementation/scribe-summary.md:88:- **Granola IFOS-side OAuth token NOT on disk** (`~/.ifos-local-vault/*/granola-tokens-*.json`
docs/features/agent-build/03-implementation/scribe-summary.md:98:  complete the Granola OAuth dance to put the IFOS-side token on disk; record ≥1
agents/recruitment/scribe/cleanup.sh:5:#         with live cache-purge + last-poll-stamp logic).
agents/recruitment/scribe/cleanup.sh:6:# Reading order: agent.md §4 Step 10 (session close) + §6 ESC code mappings first.
agents/recruitment/scribe/cleanup.sh:8:# Per agent.md §3 actions list: Scribe's cleanup action_type is
agents/recruitment/scribe/cleanup.sh:23:#   CTX_GRANOLA_WORKSPACE_ID (for the last-poll cache filename)
agents/recruitment/scribe/cleanup.sh:33:#   - Stamp ~/.ifos-cache/scribe/<tenant>/last-poll-<workspace_id>.txt with the
agents/recruitment/scribe/cleanup.sh:34:#     session end timestamp so the next cycle.sh poll-sweep window starts here
agents/recruitment/scribe/cleanup.sh:100:# Step 2 — Stamp the Scribe-internal last-poll cache file
agents/recruitment/scribe/cleanup.sh:101:# (~/.ifos-cache/scribe/<tenant>/last-poll-<workspace_id>.txt) — the next
agents/recruitment/scribe/cleanup.sh:102:# cycle.sh poll-sweep listMeetings window starts from this point.
agents/recruitment/scribe/cleanup.sh:109:  printf '%s\n' "${LAST_POLL_TS}" > "${LAST_POLL_CACHE_DIR}/last-poll-${CTX_GRANOLA_WORKSPACE_ID:-unset}.txt" 2>/dev/null \
agents/recruitment/scribe/cleanup.sh:116:# Step 3 — Emit green-tier audit row (per agent.md §3 actions list)
agents/recruitment/scribe/cleanup.sh:124:  "bullhorn_cache_purged:${BULLHORN_PURGED}; granola_cache_purged:${GRANOLA_PURGED}; tmp_transcripts_purged:${TMP_TRANSCRIPTS_PURGED}; total:${TOTAL_PURGED}; last_poll_updated:${LAST_POLL_TS}; last_poll_state:${LAST_POLL_STATE}"
agents/recruitment/scribe/cleanup.sh:127:printf '[scribe cleanup.sh] tenant=%s purged total=%d (bullhorn=%d granola=%d tmp=%d) last_poll=%s (%s)\n' \
agents/recruitment/scribe/context.sh:10:# Reading order: agent.md §2 (invocation surface) + §4 Step 0 (session start) +
agents/recruitment/scribe/context.sh:25:# Honest-scope (spec-002 §8): Bullhorn dev creds are EMPTY and the Granola
agents/recruitment/scribe/context.sh:36:#   CTX_GRANOLA_WORKSPACE_ID     — per-tenant Granola workspace identifier
agents/recruitment/scribe/context.sh:43:#   CTX_GRANOLA_LAST_POLL        — ISO timestamp of last poll-sweep
agents/recruitment/scribe/context.sh:106:# Step 2 — Granola workspace_id resolution (v0.4 allowlisted key; LIVE)
agents/recruitment/scribe/context.sh:114:# Step 3 — Granola plan_tier pre-cache
agents/recruitment/scribe/context.sh:144:# Step 5 — Granola token state (OAuth 2.1 + PKCE per @ifos/granola src/auth.ts)
agents/recruitment/scribe/context.sh:158:# Step 6 — Voice corpus + tone rules (agent.md §7)
agents/recruitment/scribe/context.sh:198:# Step 8 — Granola last_poll resolution (Scribe-internal cache file; NOT a
agents/recruitment/scribe/context.sh:202:_lp_file="${HOME}/.ifos-cache/scribe/${CTX_TENANT_SLUG}/last-poll-${CTX_GRANOLA_WORKSPACE_ID}.txt"
agents/recruitment/scribe/context.sh:219:  "agent:scribe; tenant:${CTX_TENANT_SLUG}; corp:${CTX_BULLHORN_CORPORATION_ID}; workspace:${CTX_GRANOLA_WORKSPACE_ID}; plan_tier:${CTX_GRANOLA_PLAN_TIER}; voice_corpus:${CTX_VOICE_CORPUS_ID}; last_poll:${CTX_GRANOLA_LAST_POLL}"
agents/recruitment/scribe/context.sh:222:printf '[scribe context.sh] tenant=%s corp=%s workspace=%s plan_tier=%s bullhorn_token=%s granola_token=%s voice_corpus=%s tone_rules=%s firm_domains=%s last_poll=%s\n' \
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:3:# Edge case. Tests the Granola Paid-plan pre-guard — if the workspace's
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:7:# GranolaPlanTierInsufficientError before any HTTP round-trip; Scribe maps
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:11:# Per agent.md §1 the contract requires ≥3 structured-field extractions —
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:31:description: Granola Free workspace → getTranscript pre-guarded → ESC_GRANOLA_PLAN_TIER → degrade to notes-only ingest → 3 fields extracted from notes_markdown
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:38:  command: ifosctl scribe poll-sweep
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:41:    - poll-sweep
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:60:# Meeting has_transcript:true reported by Granola (transcript exists on
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:61:# Granola's side) but PAID-only access blocks Scribe from fetching it.
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:111:  granola_poll:
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:157:      output_type: webhook_verified          # poll trigger → signature:not_applicable (spec-002 §3)
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:159:      output_type: granola_meetings_polled
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:182:  Tenant's Granola workspace is on Free plan; transcripts unavailable.
agents/recruitment/scribe/fixtures/02-edge-case-paid-only.yaml:185:  confidence; relies on Granola's notes_markdown). v0.4 supplement does NOT
agents/recruitment/scribe/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
agents/recruitment/scribe/agent.md:5:**Reading-discipline note (added 2026-06-03 per Codex Fbis-R3 closure pattern + CC + Concierge + Janitor precedent):** this `agent.md` is the **CONTRACT** that the W6 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `e6028e6` + `f9b4a84` + `b3819e7` + `d314661` + `313be44` per W5 Day-32); they carry `TODO(W6)` markers throughout that the W6 build slice replaces with live implementation matching the contract below. **VENDOR DELTA**: this `agent.md` (W3 cluster E review state — Status banner says Proposed but the review ran) describes a WEBHOOK-DRIVEN flow from Fathom/Fireflies (§2 + §4 Step 1 webhook signature verification + §6 ESC_PROVIDER_FETCH_FAIL row + §8 Fathom/Fireflies commercial signup dependency); the deployed SKELETON uses POLLING from Granola per Day-29 vendor pivot (founder confirmed 2026-06-03 — see `goal-week-5-execution-plan.md` §2 Phase 3 fix-forward + the `@ifos/granola` wrapper scaffold landed commit `1b657e6`). Granola does NOT publish webhooks per `@ifos/granola` README §"Scribe consumption pattern" — `cycle.sh` handles BOTH the outer poll-sweep loop AND the per-meeting Steps 0-10 internally. **W6 ratification updates this `agent.md` to match deployed Granola polling reality** (vendor swap; webhook → polling; Step 1 "signature verification" → "Granola transcript fetch"). **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON `cycle.sh` emits only the minimal trigger/output markers (`session_start`, `granola_meetings_polled`, `bullhorn_auth_refresh`, `transcript_fetched`, `entity_resolved`, `fields_extracted`, `tacit_note_rendered`, `fields_validated`, `dry_run_writes_skipped`, `bullhorn_scribe_field_write`, `bullhorn_note_append_summary`, `scribe_run_complete`) at `cycle.sh` lines 130, 156, 178, 195, 211, 226, 243, 259, 268, 285, 301, 319.** The yellow-tier audit rows the contract names (`bullhorn_scribe_field_write` + `bullhorn_note_append_summary`) are NOT yet emitted at runtime — they're the W6 contract surface, not current behavior. The SKELETON `context.sh` uses **env-var fallbacks** today (`IFOS_FORCE_BULLHORN_CORPORATION_ID`, `IFOS_FORCE_GRANOLA_WORKSPACE_ID`, `IFOS_FORCE_GRANOLA_PLAN_TIER`, `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID`) even though the v0.4 schema supplement LANDED 2026-06-03 (commit `a1bbcf6` + LIVE on VPS) made the canonical `SELECT config->>'<key>' FROM tenant_adapters` path schema-clean for `bullhorn_corporation_id` + `granola_workspace_id` — that wiring lands at W6 alongside the `@ifos/bullhorn` + `@ifos/granola` refresh integrations. Don't read agent.md as a description of running code; read it as the spec the W6 build slice implements after the vendor pivot is acknowledged.
agents/recruitment/scribe/agent.md:10:**Tier:** Tier 2 (webhook-driven; not persistent PTY) per ULTRAPLAN A3 line 518.
agents/recruitment/scribe/agent.md:18:> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:27:POST https://<tenant>.ifos.app/agents/scribe/webhook
agents/recruitment/scribe/agent.md:42:v1.0 supports Fathom (HMAC-SHA256 signed) and Fireflies (bearer token) providers; auth handled per-provider in `tools.yaml` capability declarations. Ringover (OAuth-protected) is deferred to v1.1+ — not in the v0 build dependencies and not registered in v1.0 `tools.yaml`.
agents/recruitment/scribe/agent.md:50:Useful when a webhook was missed or a transcript needs reprocessing after taxonomy update.
agents/recruitment/scribe/agent.md:62:Two outputs per webhook. Both write atomically (one transaction); rollback on either failure.
agents/recruitment/scribe/agent.md:83:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
agents/recruitment/scribe/agent.md:135:0. Session start (webhook handler)
agents/recruitment/scribe/agent.md:138:   → hh_decision_trigger("session_start", "scribe webhook for <call_id>")
agents/recruitment/scribe/agent.md:144:   → hh_decision_output("webhook_verified", "call:<id>", "provider:<name>")
agents/recruitment/scribe/agent.md:217:   → compute elapsed_seconds from webhook receipt
agents/recruitment/scribe/agent.md:254:Per ULTRAPLAN A3 line 525 verbatim: **"90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%"**.
agents/recruitment/scribe/agent.md:257:- **SLA:** ≥90% of webhooks-to-Bullhorn-write within 5 min
agents/recruitment/scribe/agent.md:274:| `ESC_PROVIDER_FETCH_FAIL` | Transcript fetch fails (v1.0: Fathom or Fireflies; Ringover added v1.1+). Catalogue line 324-329 generic upstream-read code; v1.0 payload extension uses `upstream` field set to `fathom`/`fireflies`; transcript-provider examples added in catalogue §2.9 amendment (queued for catalogue extension at W6 build start) | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:319:| **Fathom commercial signup** + API access | Founder commercial action | ⏸ |
agents/recruitment/scribe/agent.md:320:| Fireflies commercial signup + API access (alternative provider) | Founder commercial action | ⏸ |
agents/recruitment/scribe/agent.md:321:| Fathom/Fireflies MCP connector | W6 build start (~2 days) | ⏸ |
agents/recruitment/scribe/agent.md:337:**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
agents/recruitment/scribe/agent.md:343:| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
agents/recruitment/scribe/agent.md:346:| Q4 | Webhook signature timeout — provider-specific signature schemes have different replay windows. Should Scribe reject webhooks >5 min old (replay protection)? | Recommend yes; defends against replay attacks. Per-provider timeout config in tools.yaml. |
agents/recruitment/scribe/agent.md:354:2. **Transcript provider quality varies.** Fathom transcripts tend to be cleaner; Fireflies more comprehensive. Choose per-tenant.
agents/recruitment/scribe/agent.md:361:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/scribe/agent.md:365:- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
agents/recruitment/scribe/agent.md:376:*End of Scribe agent.md draft.*
agents/recruitment/scribe/bin/render-tacit-note.sh:2:# Scribe — Step 6 tacit-note renderer (agent.md §3 Output 2 + 8-category taxonomy).
agents/recruitment/scribe/bin/render-tacit-note.sh:11:# Taxonomy v0.1 (agent.md §3, 8 categories) — observations are derived per
agents/recruitment/scribe/bin/render-tacit-note.sh:13:# carries [MM:SS] prefixes. Privacy tone rules applied (agent.md §7):
agents/recruitment/scribe/bin/render-tacit-note.sh:17:# Word cap ≤800 enforced (agent.md §3; G-word-cap in validate.sh).
agents/recruitment/scribe/bin/render-tacit-note.sh:60:# Per-category keyword cues (taxonomy v0.1; agent.md §3 categories 1-8).
agents/recruitment/scribe/bin/render-tacit-note.sh:105:# Privacy (agent.md §7 tone rules): participant emails never enter the
agents/recruitment/scribe/bin/render-tacit-note.sh:128:# Word cap ≤800 (agent.md §3). The deterministic template is short by
agents/recruitment/scribe/bin/render-tacit-note.sh:133:…(truncated at 800-word cap per agent.md §3)"
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:4:# agent.md §3 line 111. When the tacit-note narrative voice score is <0.75
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:9:# required. Per agent.md §3 line 111: "the note is NOT attached to Bullhorn".
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:15:# Per agent.md §6: ESC_VOICE_DRIFT is warn-tier (operator_chat_id). NOT
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:16:# blocking — cycle.sh continues to the next meeting in poll-sweep mode.
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:19:# NOT fire _TENANT directly (per agent.md §7).
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:36:expected_exit_code: 0   # warn-tier ESC; cycle.sh continues to next meeting in poll-sweep
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:39:  command: ifosctl scribe poll-sweep
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:42:    - poll-sweep
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:112:  needs_consultant_review: true   # frontmatter flag added per agent.md §3 line 111
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:115:  granola_poll:
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:126:    g1_webhook_sig_pass: true    # G3 voice, G4 names, G5 types, G6 PII, G7 auth, G8 word cap
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:135:  bullhorn_writes: []           # NO writes; Steps 8+9 SKIPPED per agent.md §3 line 111
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:153:      output_type: webhook_verified          # poll trigger → signature:not_applicable (spec-002 §3)
agents/recruitment/scribe/fixtures/99-voice-drift-blocked.yaml:155:      output_type: granola_meetings_polled
agents/recruitment/scribe/bin/sla-class.sh:2:# Scribe — Step 10 SLA bucket classifier (agent.md §4 Step 10; catalogue §2.10).
agents/recruitment/scribe/bin/sla-class.sh:7:# Thresholds (agent.md §4 Step 10 — two DIFFERENT scopes, both kept):
agents/recruitment/scribe/README.md:3:**Status:** agent.md Proposed (status flip is founder-gated); bundle BUILT
agents/recruitment/scribe/README.md:5:Bullhorn/Granola smoke founder-gated (creds + ≥1 recorded meeting).
agents/recruitment/scribe/README.md:11:| `agent.md` | Proposed (CONTRACT; §4 Step 3 Fathom/Fireflies text is PRE-PIVOT — vendor is Granola per spec-002) |
agents/recruitment/scribe/README.md:12:| `tools.yaml` | built — Bullhorn W (via `bin/bh-bridge.sh`) + Granola R + voice notes |
agents/recruitment/scribe/README.md:14:| `cycle.sh` | built — 10-step per-call workflow (poll-sweep / replay / webhook / dry-run) |
agents/recruitment/scribe/README.md:16:| `cleanup.sh` | built — cache purges + last-poll stamp |
agents/recruitment/scribe/README.md:38:Post-build Codex re-ratification via `review-agent-bundle.md` (agent.md §10).
agents/recruitment/scribe/fixtures/01-primary.yaml:3:# Tests the canonical flow per agent.md §3 + §4 + Day-29 Granola pivot:
agents/recruitment/scribe/fixtures/01-primary.yaml:4:#   cycle.sh mode=poll-sweep → @ifos/granola listMeetings since last_poll
agents/recruitment/scribe/fixtures/01-primary.yaml:16:# Per agent.md §5: all Gate A G1-G7 checks pass. SLA elapsed=240s (4 min) is
agents/recruitment/scribe/fixtures/01-primary.yaml:21:#         downstream contract (bullhorn_auth_refreshed, webhook_verified, ...)
agents/recruitment/scribe/fixtures/01-primary.yaml:24:#         live Bullhorn/Granola founder-gated per spec-002 §8).
agents/recruitment/scribe/fixtures/01-primary.yaml:34:  command: ifosctl scribe poll-sweep
agents/recruitment/scribe/fixtures/01-primary.yaml:37:    - poll-sweep
agents/recruitment/scribe/fixtures/01-primary.yaml:48:# Mocked Granola account info (pre-cached at context.sh Step 3)
agents/recruitment/scribe/fixtures/01-primary.yaml:57:# Mocked Granola listMeetings (Step 1 poll-sweep discovery)
agents/recruitment/scribe/fixtures/01-primary.yaml:73:# Mocked Granola getTranscript for meeting-001 (Step 3)
agents/recruitment/scribe/fixtures/01-primary.yaml:112:  granola_poll:
agents/recruitment/scribe/fixtures/01-primary.yaml:147:      output_type: webhook_verified           # spec-002 §3; poll trigger → signature:not_applicable
agents/recruitment/scribe/fixtures/01-primary.yaml:149:      output_type: granola_meetings_polled    # poll-sweep discovery marker (Granola pivot; extra to the §3 set)
agents/recruitment/scribe/bin/validate-fields.sh:7:# below is derived from the SCHEMA FILES (not agent.md prose):
agents/recruitment/scribe/cycle.sh:6:#         agent.md §3-§6).
agents/recruitment/scribe/cycle.sh:7:# Reading order: agent.md §1 (output contract) + §3 (2 outputs: Bullhorn
agents/recruitment/scribe/cycle.sh:16:# (@ifos/granola). agent.md §4 Step 3's Fathom/Fireflies text is PRE-PIVOT —
agents/recruitment/scribe/cycle.sh:17:# every transcript-fetch path here is Granola. Granola does NOT publish
agents/recruitment/scribe/cycle.sh:18:# webhooks, so the operational trigger is the poll-sweep; the generic v1.0
agents/recruitment/scribe/cycle.sh:19:# webhook surface (agent.md §2; HMAC/bearer-verified) is ALSO implemented
agents/recruitment/scribe/cycle.sh:20:# (mode=webhook) per spec-002 §4 Step 1 + Gate A webhook-sig.
agents/recruitment/scribe/cycle.sh:23:#   mode=poll-sweep   — 5-min cron: list meetings since last_poll → process
agents/recruitment/scribe/cycle.sh:26:#                       agent.md §2 "ifosctl scribe replay --call-id <id>"
agents/recruitment/scribe/cycle.sh:27:#   mode=webhook      — generic per-call webhook: --payload <json file> plus
agents/recruitment/scribe/cycle.sh:30:#   mode=dry-run      — poll-sweep + Steps 0-7 only (no Step 8/9 writes)
agents/recruitment/scribe/cycle.sh:34:#   1  webhook signature verify / poll     webhook_verified (+ granola_meetings_polled)
agents/recruitment/scribe/cycle.sh:36:#   3  Granola transcript fetch → /tmp     transcript_fetched        ESC_PROVIDER_FETCH_FAIL
agents/recruitment/scribe/cycle.sh:47:# single reconciliation point). Granola live calls expect the @ifos/granola
agents/recruitment/scribe/cycle.sh:53:# Output contract per agent.md §1: two outputs per meeting —
agents/recruitment/scribe/cycle.sh:100:MODE="poll-sweep"
agents/recruitment/scribe/cycle.sh:116:  poll-sweep|dry-run) : ;;
agents/recruitment/scribe/cycle.sh:121:  webhook)
agents/recruitment/scribe/cycle.sh:123:      printf 'cycle.sh: --payload <json file> required for mode=webhook\n' >&2; exit 2
agents/recruitment/scribe/cycle.sh:171:# Step 1 — Webhook signature verification (mode=webhook) / poll discovery
agents/recruitment/scribe/cycle.sh:172:# Reference: spec-002 §4 Step 1 (marker webhook_verified; ESC_INPUT_VALIDATION_FAIL
agents/recruitment/scribe/cycle.sh:173:# reject = the 401 path) + agent.md §2. In poll-sweep/replay there is no
agents/recruitment/scribe/cycle.sh:174:# external webhook input to verify (Granola publishes none) — the marker is
agents/recruitment/scribe/cycle.sh:175:# emitted honestly with method:poll|manual_replay + signature:not_applicable;
agents/recruitment/scribe/cycle.sh:182:if [[ "${MODE}" == "webhook" ]]; then
agents/recruitment/scribe/cycle.sh:193:    # Reject (the HTTP layer maps this to 401) — per agent.md §4 Step 1.
agents/recruitment/scribe/cycle.sh:195:      "tenant=${CTX_TENANT_SLUG}" "call=${_wh_call_id}" "reason=webhook_signature_mismatch"
agents/recruitment/scribe/cycle.sh:196:    hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
agents/recruitment/scribe/cycle.sh:200:  hh_decision_output "webhook_verified" "call:${_wh_call_id}" \
agents/recruitment/scribe/cycle.sh:202:  # Webhook payload IS the meeting metadata (agent.md §2 shape).
agents/recruitment/scribe/cycle.sh:209:  hh_decision_output "webhook_verified" "call:${CALL_ID_ARG:-sweep}" \
agents/recruitment/scribe/cycle.sh:210:    "provider:granola; method:$( [[ "${MODE}" == "replay" ]] && echo manual_replay || echo poll ); signature:not_applicable"
agents/recruitment/scribe/cycle.sh:212:  # Poll discovery (poll-sweep/dry-run) or single-meeting hydrate (replay).
agents/recruitment/scribe/cycle.sh:231:  hh_decision_output "granola_meetings_polled" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/scribe/cycle.sh:237:# Reference: agent.md §4 Step 2; 2 retries then ESC_BULLHORN_AUTH (blocking;
agents/recruitment/scribe/cycle.sh:287:  # ── Step 3 — Granola transcript fetch → /tmp 0600 ─────────────────────
agents/recruitment/scribe/cycle.sh:326:      sleep "${FETCH_RETRY_DELAY}"           # retry once, 30s backoff (agent.md §4 Step 3)
agents/recruitment/scribe/cycle.sh:419:  # Drop sub-threshold fields before Step 7 (agent.md §4 Step 5).
agents/recruitment/scribe/cycle.sh:428:  # The 3-retry loop of agent.md §4 Step 6 only makes sense for a
agents/recruitment/scribe/cycle.sh:492:       webhook_sig_state: $sig, fields_extracted: $fields,
agents/recruitment/scribe/cycle.sh:519:  # IFOS-cache ONLY per agent.md §3 (no v1.0 Bullhorn endpoint).
agents/recruitment/scribe/cycle.sh:622:      # Note attach hard-failed → best-effort rollback of Step 8 (agent.md §4
agents/recruitment/scribe/cycle.sh:666:# Steps 3-9 — per-meeting loop (poll-sweep iterates; replay/webhook = 1 call)
agents/recruitment/scribe/cycle.sh:685:# Reference: agent.md §4 Step 10 (threshold scopes) + catalogue §2.10.
agents/recruitment/scribe/cycle.sh:695:# Exit semantics: replay/webhook surface a per-call gate failure as exit 1;
agents/recruitment/scribe/cycle.sh:696:# poll-sweep/dry-run always exit 0 (skips are logged + ESC-routed per call).
agents/recruitment/scribe/cycle.sh:697:if [[ "${MODE}" == "replay" || "${MODE}" == "webhook" ]] && [[ "${GATE_FAILED}" -eq 1 ]]; then
agents/recruitment/scribe/validate.sh:5:#         replaced with live checks per spec-002-scribe.md §5 + agent.md §5).
agents/recruitment/scribe/validate.sh:6:# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
agents/recruitment/scribe/validate.sh:13:# meeting (poll-sweep mode) or exits with the gate-fail signal (replay/webhook).
agents/recruitment/scribe/validate.sh:25:#           "webhook_sig_state": "verified" | "not_applicable" | "invalid" | "missing",
agents/recruitment/scribe/validate.sh:46:# Checks (spec-002 §5 — all 7, in spec order — plus the agent.md §3 word cap):
agents/recruitment/scribe/validate.sh:47:#   G1 — webhook-sig: valid per provider                    ESC_INPUT_VALIDATION_FAIL  hard
agents/recruitment/scribe/validate.sh:54:#   G8 — word-cap: tacit-note ≤800 words (agent.md §3)      ESC_AGENT_OUTPUT_SHAPE  hard
agents/recruitment/scribe/validate.sh:128:# Thresholds (per ULTRAPLAN A3 line 524 + agent.md §3)
agents/recruitment/scribe/validate.sh:141:# proposal. 'not_applicable' = poll-sweep/replay (Granola publishes no
agents/recruitment/scribe/validate.sh:142:# webhooks — there is no external input to verify); anything else fails hard.
agents/recruitment/scribe/validate.sh:145:_sig="$(jq -r '.webhook_sig_state // "missing"' "${PROPOSAL}")"
agents/recruitment/scribe/validate.sh:147:  verified)        _ok "G1: webhook signature verified" ;;
agents/recruitment/scribe/validate.sh:148:  not_applicable)  _ok "G1: webhook signature not applicable (poll/replay trigger; no external webhook input)" ;;
agents/recruitment/scribe/validate.sh:150:    _fail "G1: webhook signature state '${_sig}' — reject"
agents/recruitment/scribe/validate.sh:170:# Hard fail when a numeric score is below threshold (per agent.md §3: the
agents/recruitment/scribe/validate.sh:227:# Blocking severity per agent.md §6 ESC_PII_LEAKAGE_RISK.
agents/recruitment/scribe/validate.sh:287:# G8 — Tacit-note word count ≤800 (agent.md §3 cap; kept from the skeleton
agents/recruitment/scribe/tools.yaml:4:#         are LIVE against these declarations. Live Bullhorn + Granola smoke
agents/recruitment/scribe/tools.yaml:5:#         remains founder-gated: Bullhorn dev creds EMPTY + Granola IFOS-side
agents/recruitment/scribe/tools.yaml:7:# Reading order: agent.md §1 (output contract) + §2 (invocation surface) +
agents/recruitment/scribe/tools.yaml:22:# (read surface). Vendor delta from agent.md: agent.md describes Fathom /
agents/recruitment/scribe/tools.yaml:23:# Fireflies as the transcript provider; SKELETON uses Granola per Day-29
agents/recruitment/scribe/tools.yaml:25:# note + scribe/agent.md Reading-discipline note document the delta.
agents/recruitment/scribe/tools.yaml:44:  # is IFOS-cached-Postgres-only per agent.md §3 (no v1.0 Bullhorn endpoint).
agents/recruitment/scribe/tools.yaml:127:  # Granola MCP wrapper (read surface; 5 of 6 official tools — listFolders
agents/recruitment/scribe/tools.yaml:128:  # NOT consumed by Scribe per agent.md §4 + Day-29 vendor pivot)
agents/recruitment/scribe/tools.yaml:135:    purpose: "Granola OAuth 2.1 + PKCE + DCR refresh (per-workspace_id Promise dedup + atomic file write per @ifos/granola src/auth.ts); Scribe pre-cache plan_tier='paid' via getAccountInfo at session start"
agents/recruitment/scribe/tools.yaml:143:    purpose: "List meetings since CTX_GRANOLA_LAST_POLL (cycle.sh Step 1 poll-sweep loop discovery); free plan returns last 30d only per Granola docs — Scribe assumes Paid (founder 2026-06-03)"
agents/recruitment/scribe/tools.yaml:149:    purpose: "Single-meeting hydrate for replay mode (manual --call-id <meeting_id> invocation per agent.md §2)"
agents/recruitment/scribe/tools.yaml:158:    # NOTE: declared but not consumed at v1.0 — Scribe's poll-sweep uses
agents/recruitment/scribe/tools.yaml:177:  # Reference: agent.md §7; _shared/voice-loader.sh + hh_load_tone_rules.
agents/recruitment/scribe/tools.yaml:181:    package: "@ifos/voice-classifier"   # W4-5 polish microservice (per agent.md §8 build deps)
agents/recruitment/scribe/tools.yaml:186:    # agent.md §8 — may not exist as a standalone package at this scaffold
agents/recruitment/scribe/tools.yaml:195:    purpose: "Post-run cleanup (transient @ifos/bullhorn + @ifos/granola cache purge + /tmp transcript purge + last-poll cache file update)"
agents/recruitment/scribe/tools.yaml:201:# Failure-modes table (per cluster Fbis pattern; ESC mapping per agent.md §6)
agents/recruitment/scribe/tools.yaml:211:    surface: "GranolaAuthError thrown by @ifos/granola"
agents/recruitment/scribe/tools.yaml:220:    surface: "GranolaError; per agent.md §6 ESC_PROVIDER_FETCH_FAIL covers transcript-provider failures generically (v1.0 payload extension upstream='granola')"
agents/recruitment/scribe/tools.yaml:224:    surface: "GranolaPlanTierInsufficientError"
agents/recruitment/scribe/tools.yaml:228:    surface: "BullhornRateLimitError OR GranolaRateLimitError"
agents/recruitment/scribe/tools.yaml:286:#                                    with upstream=granola per agent.md §6)
agents/recruitment/scribe/bin/extract-fields.sh:2:# Scribe — Step 5 field extraction (agent.md §4 Step 5; spec-002 §4 row 5).

exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|packages/harness/cortextos|kb-|stock KB|brain" agents/recruitment/scribe/agent.md agents/recruitment/scribe/tools.yaml agents/recruitment/scribe/*.sh agents/recruitment/scribe/fixtures/*.yaml -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
agents/recruitment/scribe/tools.yaml:294:# - No Composio / AgentMail references anywhere in this file.

codex
The remaining checks did not show the hard adapter/submodule boundary violations in `agent.md`; the blocking problems are contract accuracy and the agent-bundle’s current implementation state versus the document’s claims.
exec
/bin/zsh -lc 'rg -n "''^  [a-z_]+:|''^entities:" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.*-supplement.yaml | head -80' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
exec
/bin/zsh -lc 'rg -n "contractor|Contractor" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.*-supplement.yaml -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:45:entities:
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:153:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:221:  client:
docs/verticals/recruitment/vertical-schema.yaml:283:  contact:
docs/verticals/recruitment/vertical-schema.yaml:341:  brief:
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:495:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:535:  timesheet:
docs/verticals/recruitment/vertical-schema.yaml:585:  candidate_placed_in_role:
docs/verticals/recruitment/vertical-schema.yaml:594:  placement_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:601:  brief_from_client:
docs/verticals/recruitment/vertical-schema.yaml:608:  brief_decision_maker:
docs/verticals/recruitment/vertical-schema.yaml:618:  contact_works_for_client:
docs/verticals/recruitment/vertical-schema.yaml:625:  candidate_engaged_with_contact:
docs/verticals/recruitment/vertical-schema.yaml:632:  candidate_referred_by_contact:
docs/verticals/recruitment/vertical-schema.yaml:639:  opportunity_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:647:  opportunity_about_candidate:
docs/verticals/recruitment/vertical-schema.yaml:654:  timesheet_for_placement:
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:754:  client:
docs/verticals/recruitment/vertical-schema.yaml:760:  contact:
docs/verticals/recruitment/vertical-schema.yaml:765:  brief:
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:777:  opportunity:
docs/verticals/recruitment/vertical-schema.yaml:783:  timesheet:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:53:entities:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:267:  voice_samples_embedded:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:303:  contact:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:311:  brief:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:319:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:341:  voice_corpus_governs_tone_rules:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:364:  sql_file: docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:365:  rollback_sql_file: docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:366:  status: drafted (Phase 4); execution against migration-test tenant scheduled for Phase 5
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:367:  rollback_strategy: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:370:  prerequisite_extensions:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:74:  operator_telegram_chat_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:101:  email_channel:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:124:  workos_org_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:146:  granola_workspace_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:172:  bullhorn_corporation_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:203:  entity_field_additions: |
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:212:  auxiliary_tables: |
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:217:  agent_access_matrix: |
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:223:  decision_log_payload: |
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:233:  forward: migrations/v0.3-to-v0.4.sql
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:234:  rollback: migrations/v0.4-to-v0.3.sql
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:236:  pre_conditions:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:242:  steps:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:263:  post_migration_steps:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:273:  skill: review-schema-change
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:274:  expected_round_trips: 1 (additive-only; no entity changes; no matrix changes)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:275:  manifest_queue_position: F-tris (deferred to W5 Phase 7 per goal-week-5-execution-plan.md §5; partial-ratification framework available per Fbis + G precedent)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:276:  rationale: |
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:57:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:105:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:132:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:173:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:223:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:373:  diagnostic:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:383:  janitor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:393:  scribe:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:409:  cash_conductor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:425:  sourcing_scout:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:443:  concierge:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:  client:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:484:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:498:  brief:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:510:  opportunity:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:525:  placement:

 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:65:          IR35 distinction matters for UK contractors. Extracted by Scribe
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:279:#     pattern as candidate/contractor — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:301:#   - Sourcing Scout contractor: stays R (same revert as candidate)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:305:#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:323:  # (candidate, contractor, client, contact, brief, opportunity, placement,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:375:    contractor: none       # not in scope at v1.0
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:385:    contractor: R+W        # dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:401:    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:416:    contractor: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:427:    # v0.3 draft upgraded candidate/contractor to R+W to allow writing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:432:    # rows), NOT in the Bullhorn candidate/contractor entities. Only the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:435:    contractor: R          # v0.1 unchanged; same as candidate (contractor-mode briefs)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:449:    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:564:  contractor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:569:      - Sourcing Scout (R)   # R-only — same as candidate; proposed matches live in the shortlist artefact, not the Bullhorn-backed contractor entity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:570:      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:48:#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:296:  contractor:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:301:      notes: Same as candidate.voice_classifier_score, scoped to contractor sub-case.
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
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:561:      approved_by_contractor:
docs/verticals/recruitment/vertical-schema.yaml:673:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:684:    contractor: R+W  # status normalisation
docs/verticals/recruitment/vertical-schema.yaml:694:    contractor: R+W  # contractor calls same pattern
docs/verticals/recruitment/vertical-schema.yaml:704:    contractor: none
docs/verticals/recruitment/vertical-schema.yaml:714:    contractor: R    # contractor pool
docs/verticals/recruitment/vertical-schema.yaml:724:    contractor: R+W  # lifecycle state, contractor-specific cadence
docs/verticals/recruitment/vertical-schema.yaml:744:    status_filter: status != 'contractor'
docs/verticals/recruitment/vertical-schema.yaml:747:  contractor:
docs/verticals/recruitment/vertical-schema.yaml:750:    status_filter: status='contractor'
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
docs/verticals/recruitment/vertical-schema.yaml:797:  Q1_contractor_entity_type:
docs/verticals/recruitment/vertical-schema.yaml:799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:827:    v0_1_decision: Timesheet entity has placeholder 7-field shape (id, week_starting, hours_worked, approved_by_client, approved_by_contractor, date_submitted, primary key).
docs/verticals/recruitment/vertical-schema.yaml:834:    v0_1_decision: contractor.umbrella_company is free-text field in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:194:      adds Sourcing Scout (R-only on candidate/contractor entities per

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '60,460p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a59f16e915e384257
 succeeded in 0ms:
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
   261	        source: IFOS-derived (Janitor maintains)
   262	      account_owner_user_id:
   263	        type: integer
   264	        required: false
   265	        source: Bullhorn.ClientCorporation.owner.id
   266	      preferred_terms:
   267	        type: string
   268	        required: false
   269	        source: IFOS-derived (commercial framework; free text for v0.1; structured for v1.1+)
   270	      date_added_at:
   271	        type: timestamp
   272	        required: true
   273	        source: Bullhorn.ClientCorporation.dateAdded
   274	      hq_city:
   275	        type: string
   276	        required: false
   277	        source: Bullhorn.ClientCorporation.address.city
   278	    notes:
   279	      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
   280	      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
   281	
   282	  # --------------------------------------------------------------------------
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
   411	      status:
   412	        type: string
   413	        required: true
   414	        enum: [open, on_hold, filled, closed_lost, closed_won, cancelled]
   415	        source: Bullhorn.JobOrder.status (with mapping)
   416	      date_added_at:
   417	        type: timestamp
   418	        required: true
   419	        source: Bullhorn.JobOrder.dateAdded
   420	      date_last_modified_at:
   421	        type: timestamp
   422	        required: true
   423	        source: Bullhorn.JobOrder.dateLastModified
   424	    notes:
   425	      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
   426	      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
   427	
   428	  # --------------------------------------------------------------------------
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

codex
REJECTED

1. The agent contract is still pre-pivot Fathom/Fireflies webhook prose while the bundle and build spec are Granola polling. Lines 18, 24-42, 135-153, 319-321, and 337 all make Fathom/Fireflies webhook the v1.0 path, but `tools.yaml` lines 21-25 and 127-172 declare Granola, and `cycle.sh` lines 171-232 implement poll discovery. Fix by rewriting §1, §2, §4, §6, §8, §9, and §10 around Granola poll-sweep as primary, with webhook only if still intentionally supported.

2. The status/build-state claims are not honest against the current sibling bundle. Line 250 says `validate.sh` does not exist yet and lines 325-328 list `validate.sh`, `context.sh`, `cycle.sh`, and fixtures as future W6 build work, but `validate.sh` exists and identifies itself as “W6 build slice LIVE” at lines 2-5, and `tools.yaml` says the bundle is built at lines 3-6. Fix the document’s status model: either make it a true pre-build scaffold by reverting bundle claims, or update it as a post-build contract and reconcile §5 Gate A with the implementation.

3. §3 promises Bullhorn note attachment for every resolved entity, but Opportunity is explicitly cache-only. Line 18 says the tacit note is mirrored as a Bullhorn `Note` on the resolved entity, line 62 says both outputs write atomically, and lines 87-89 repeat that the note is attached to the same Bullhorn entity; line 71 says Opportunity writes are IFOS-cached Postgres only, and `cycle.sh` lines 604-620 defer note attach for Opportunity because there is no note endpoint. Fix by excluding Opportunity from v1.0 Scribe output or defining a separate cache-only/vault-only Opportunity output contract and Gate A path.

4. §3 names contractor as a possible target in the output contract but omits contractor from the field table and workflow resolution shape. Line 18 includes `contractor`, while lines 75-81 list Candidate, Contact, Brief, Placement, and Opportunity only; the schema has `contractor` as a first-class entity, so Gate A’s ≥3-field requirement is underspecified for contractor calls. Fix by adding a Contractor row with canonical writable fields and decision-log semantics, or remove contractor from the v1.0 output contract.
tokens used
127,803
REJECTED

1. The agent contract is still pre-pivot Fathom/Fireflies webhook prose while the bundle and build spec are Granola polling. Lines 18, 24-42, 135-153, 319-321, and 337 all make Fathom/Fireflies webhook the v1.0 path, but `tools.yaml` lines 21-25 and 127-172 declare Granola, and `cycle.sh` lines 171-232 implement poll discovery. Fix by rewriting §1, §2, §4, §6, §8, §9, and §10 around Granola poll-sweep as primary, with webhook only if still intentionally supported.

2. The status/build-state claims are not honest against the current sibling bundle. Line 250 says `validate.sh` does not exist yet and lines 325-328 list `validate.sh`, `context.sh`, `cycle.sh`, and fixtures as future W6 build work, but `validate.sh` exists and identifies itself as “W6 build slice LIVE” at lines 2-5, and `tools.yaml` says the bundle is built at lines 3-6. Fix the document’s status model: either make it a true pre-build scaffold by reverting bundle claims, or update it as a post-build contract and reconcile §5 Gate A with the implementation.

3. §3 promises Bullhorn note attachment for every resolved entity, but Opportunity is explicitly cache-only. Line 18 says the tacit note is mirrored as a Bullhorn `Note` on the resolved entity, line 62 says both outputs write atomically, and lines 87-89 repeat that the note is attached to the same Bullhorn entity; line 71 says Opportunity writes are IFOS-cached Postgres only, and `cycle.sh` lines 604-620 defer note attach for Opportunity because there is no note endpoint. Fix by excluding Opportunity from v1.0 Scribe output or defining a separate cache-only/vault-only Opportunity output contract and Gate A path.

4. §3 names contractor as a possible target in the output contract but omits contractor from the field table and workflow resolution shape. Line 18 includes `contractor`, while lines 75-81 list Candidate, Contact, Brief, Placement, and Opportunity only; the schema has `contractor` as a first-class entity, so Gate A’s ≥3-field requirement is underspecified for contractor calls. Fix by adding a Contractor row with canonical writable fields and decision-log semantics, or remove contractor from the v1.0 output contract.
