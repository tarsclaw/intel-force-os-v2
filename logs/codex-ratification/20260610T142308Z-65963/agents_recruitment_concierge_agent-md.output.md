Reading prompt from stdin...
OpenAI Codex v0.132.0
--------
workdir: /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
model: gpt-5.5
provider: openai
approval: never
sandbox: workspace-write [workdir, /tmp, $TMPDIR]
reasoning effort: none
reasoning summaries: none
session id: 019eb1ea-699b-7c90-bcbe-0a562f163283
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

Path: agents/recruitment/concierge/agent.md

--- BEGIN ARTEFACT ---

# Concierge — no candidate ghosted

**Status:** Proposed-with-disagreement-on-file (`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` — bundle-layer Codex ratification deferred to W10-13 build slice; contract-layer ratification was achieved in W3 cluster E).
**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim per `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Concierge consumer wiring landed (commits `669a4f4` + `9ec2bd6`). Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) + v0.4 schema supplement adding `operator_telegram_chat_id` + `email_channel` to the `tenant_adapters.config` allowlist (per D1-B decision-doc §Implementation surface item 5) — see §10.

**Reading-discipline note (added 2026-06-02 per Codex Fbis-R3 closure):** this `agent.md` is the **CONTRACT** that the W10-13 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `669a4f4` + `9ec2bd6` + `524bac6` + `8ba3723` + `eb1f884` per Day-26 evening + R-round closures); they carry `TODO(W10-13)` markers throughout that the W10-13 build slice replaces with live implementation matching the contract below. **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON cycle.sh emits only minimal trigger/output markers — the yellow-tier + orange-tier audit rows the contract names are NOT yet emitted at runtime.** The SKELETON `context.sh` uses **env-var fallbacks** today (`IFOS_FORCE_EMAIL_CHANNEL`, `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID`) — the `TODO(W10-13)` markers documenting future `tenant_adapters.config` reads are gated on a v0.4 schema supplement landing FIRST (those keys are NOT in the v0.3 allowlist; the validator would hard-fail). Don't read agent.md as a description of running code; read it as the spec the W10-13 build slice implements after the v0.4 supplement lands.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.

---

## §2 — Invocation surface

### Lifecycle webhook (v1.0 primary)

```http
# Bullhorn placement state-change webhook → Concierge handler
POST https://<tenant>.ifos.app/agents/concierge/webhook
Authorization: Bearer <bullhorn-shared-secret>
Content-Type: application/json

{
  "event_type": "placement.state_changed" | "candidate.state_changed",
  "entity_id": "<bullhorn-id>",
  "from_state": "interview_scheduled",
  "to_state": "interview_completed",
  "timestamp": "<ISO>"
}
```

Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §Gotchas line 570 gotcha — see Step 1 polling fallback.

### Cron (polling fallback + time-elapsed nurture)

```bash
# Every 5 min: poll Bullhorn for missed state transitions
*/5 * * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode poll
# Daily 09:00 UTC: time-elapsed nurture sweeps (7d / 30d / 90d check-ins)
0 9 * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode nurture-sweep
```

### Manual (debugging)

```bash
ifosctl concierge generate --tenant <slug> --candidate <id> --event <event-type>
ifosctl concierge replay --tenant <slug> --webhook-id <id>
```

### v1.1+ surfaces (deferred)

- agent-identity email adapter (deferred) integration (agent-identity sends for non-rejection comms)
- Brain UI lifecycle-event timeline viewer per candidate
- Per-tenant comms-type taxonomy customisation

---

## §3 — Output shape

One output per lifecycle event: an email draft (yellow tier `concierge_email_draft` per autosend-policy.yaml; only the customer-facing SEND is orange tier — `gmail_outlook_send_to_candidate` / `bullhorn_note_customer_visible` / `twilio_sms_send` / `calendar_invite_send` per channel). 12 lifecycle events × per-tenant comms-template variants:

| # | Event | Comms type | Recipient | Tone |
|---|---|---|---|---|
| 1 | Application received | Acknowledgement | Candidate | Warm, professional, sets expectations on response timeline |
| 2 | Interview booked | Prep | Candidate | Practical (date, time, format, interviewers) + role context |
| 3 | Interview completed | Debrief | Candidate | Thank-you + next-step clarity OR "we'll be in touch by X" |
| 4 | Offer extended | Placement-positive | Candidate | Excited, clear on terms, addressee-resolution-critical |
| 5 | Offer accepted | Placement-confirm | Candidate + Client (separate drafts) | Reassurance + practical next steps |
| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §Gotchas line 570 — respectful, specific, leaves door open |
| 7 | Withdrawn (candidate-initiated) | Acknowledgement | Candidate | Respectful, no pressure, leaves door open |
| 8 | On-hold | Status-update | Candidate | Honest about timeline, sets expectations on next update |
| 9 | Start date confirmed | Placement-pre-start | Candidate + Client | Practical (HR forms, IT setup, day-1 logistics) |
| 10 | 7-day check-in (post-start) | Nurture-check-in | Candidate | "How's it going? Any blockers?" — short, low-pressure |
| 11 | 30-day check-in | Nurture-check-in | Candidate + Client | Slightly longer; both sides; reads for placement-risk signals |
| 12 | 90-day check-in | Nurture-check-in + relationship | Candidate + Client | Establishes ongoing relationship; offers "is there anyone in your network looking?" |

Draft structure per event:

```yaml
draft_id: <uuid>
event_type: <one of 12 above>
candidate_id: <bullhorn-id>
placement_id: <bullhorn-id or null>
recipient: <candidate-email | client-contact-email>
recipient_role: candidate | client_contact
subject: <subject line; voice-classified>
body_markdown: <body; voice-classified>
voice_score: <0-1>
addressee_resolution_check: passed | failed
attached_documents: <list — e.g., feedback summary, prep guide, comms history>
escalation_position: 1-3 (for sensitive sends like rejection)
expected_send_window: <ISO; respects sending-hours per tenant config>
```

Each draft writes TWO decision_log rows per `_shared/hook-helpers.sh` contract:

1. `phase='output'` via `hh_decision_output("concierge_draft_rendered", "/vault/<tenant>/concierge-drafts/<id>.md", "voice_score:<N>; words:<N>")`. The helper writes only `{output_type, artefact_ref}` to the payload jsonb; the additional metadata rides the optional `reason` string parameter. This row records that the draft exists; no tier (output rows are not tier-classified).

2. `phase='action'` via `hh_decision_action("concierge_email_draft", "candidate:<bullhorn_id>:<event_type>", payload_hash, payload_preview)`. This is the tier-classified row — `concierge_email_draft` is registered yellow tier per autosend-policy.yaml lookup (grep `^  concierge_email_draft:` to verify). Tier is recorded inside the autosend-emitted payload by the helper; it is NOT a top-level decision_log column. `payload_preview` carries `event_type`, `voice_score`, `recipient`, `escalation_position` as a concatenated string for cross-row correlation. Action_type stays stable across all 12 lifecycle events — event_type is in the preview string, not part of the action_type identifier.

The actual SEND is a separate orange-tier action_type:
- `gmail_outlook_send_to_candidate` (orange tier per autosend-policy.yaml §ORANGE) when channel=email
- `bullhorn_note_customer_visible` (orange tier; canonical orange per autosend-policy.yaml §ORANGE) when channel=Bullhorn note with isExternal=true
- `twilio_sms_send` (orange tier per autosend-policy.yaml §ORANGE) when channel=SMS (v1.1+)
- `calendar_invite_send` (orange tier per autosend-policy.yaml §ORANGE) when event includes calendar attachment

Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.

---

## §4 — Workflow

15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.

```
0. Session start (webhook OR poll OR cron)
   → context.sh hydrates: tenant config + Bullhorn auth refresh +
     Microsoft Graph / Gmail auth + agent-identity email adapter (deferred) (if v1.1+ enabled) +
     voice corpus + tone rules + recent_edits + tenant comms-template
     library + addressee-resolution data
   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")

1. Source detection (mode-dependent)
   → mode=webhook: parse Bullhorn payload → resolve entity + state transition
   → mode=poll: query Bullhorn for placements/candidates with state_changed_at
     > tenant_adapters.config.concierge_last_poll AND not in decision_log
     (anti-duplicate)
   → mode=nurture-sweep: query Bullhorn placements for time-elapsed events
     (7d/30d/90d post-start with no concierge action in last 14d)
   → ESC_LIFECYCLE_STATE_UNKNOWN if state transition not in 12-event taxonomy
   → hh_decision_output("lifecycle_event_detected",
     "<entity_type>:<bullhorn_id>", "<from>→<to>")

2. Anti-duplicate guard
   → `concierge_email_draft` is the yellow-tier action_type used at Step 8;
     its target field per `hh_decision_action(action_type, target, ...)` is
     `candidate:<bullhorn_id>:<event_type>` (the event_type is encoded into
     the target string, not stored as a structured payload field — payload
     jsonb only carries what the autosend helper layer emits, not
     structured per-event metadata).
   → query: SELECT 1 FROM decision_log WHERE agent_name='concierge'
     AND action_type='concierge_email_draft'
     AND target LIKE 'candidate:<bullhorn_id>:<event_type>'
     AND phase IN ('action','gating_failed')
     AND created_at > now() - interval '24 hours'
   → if found AND any subsequent `gmail_outlook_send_to_candidate` action
     row exists for the same candidate target in same window: skip (true
     duplicate — already sent)
   → if found BUT no `gmail_outlook_send_to_candidate` follow-up: allow
     the new draft attempt (per Q7 disposition)
   → hh_decision_output("anti_duplicate_check", "candidate:<bullhorn_id>:<event_type>",
     "duplicate_status:<found|fresh>; prior_send_completed:<true|false>")
     — note artefact_ref carries the candidate+event composite (matches the
     query LIKE pattern); reason carries the status outcome.

3. Bullhorn context fetch
   → bullhorn.get_candidate(candidate_id) → name, current state, comms history
   → bullhorn.get_placement(placement_id) → role, client, dates
   → bullhorn.get_client(client_id) → company name, primary contact
   → bullhorn.get_contact(contact_id) → name, email
   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
     ESC_BULLHORN_AUTH on auth fail
   → ESC_AGENT_OUTPUT_SHAPE if critical Bullhorn context fields missing
     (no email, no name) — Concierge cannot produce its declared output
     shape (lifecycle-event draft) without a resolvable target candidate.
     NOTE: ESC_CANDIDATE_DATA_INCOMPLETE is reserved for Sourcing Scout
     shortlist completeness per catalogue §2.10.
   → hh_decision_output("bullhorn_context_fetched",
     "candidate:<bullhorn_id>", "fields_present:<N>")

4. Addressee resolution (Gate A critical)
   → recipient = candidate.email OR client_contact.email per event_type
   → verify recipient matches the candidate_id whose lifecycle is changing
     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
     "correct addressee resolution; no candidates emailed under another's name")
   → ESC_ADDRESSEE_MISMATCH if check fails (blocking); draft aborted
   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
     "recipient_role:<role>")

5. Comms-template selection
   → tenant comms-template library at /vault/<slug>/concierge-templates/
   → per event_type: select template; per recipient_role: candidate vs client
   → fallback: shared/common-comms-templates.yaml if tenant has no override
   → hh_decision_output("template_selected", "<event_type>:<recipient_role>",
     "template_id:<id>")

6. Sensitive-event escalation routing
   → if event_type=rejection (event 6) OR event_type=withdrawal (event 7)
     OR (event_type=on-hold AND placement value >£10k): set escalation_position=3
     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
   → else: escalation_position=1 (standard orange tier)
   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
     "position:<N>")

7. LLM draft generation
   → prompt = (event context + candidate state history + voice corpus
     ANN-matched on event_type + tone rules filtered for concierge +
     comms-template structure)
   → output = email body + subject + recommended_send_time
   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
   → hh_decision_output("concierge_draft_rendered",
     "/vault/<tenant>/concierge-drafts/<draft_id>.md",
     "candidate:<bullhorn_id>:<event_type>; voice_score:<N>; words:<N>")
     — per §3 line 105: vault path is the canonical artefact_ref (the
     second hh_decision_output argument); the candidate+event composite
     and voice metadata ride the reason string parameter.
   → ESC_VOICE_DRIFT if classifier score below the escalation_position-specific
     threshold (position 1 ≥0.75; position 2 ≥0.78; position 3 ≥0.82 per Step 8)
     after 3 retries — the position is set in Step 6 and is the per-draft Gate A
     threshold. Generic <0.75 floor would understate position 2-3 sensitivity.

8. Voice + tone validation
   → voice classifier scores the draft
   → minimum threshold by escalation_position:
     position 1: ≥0.75
     position 2: ≥0.78
     position 3 (rejections / sensitive): ≥0.82
   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
   → on success: hh_decision_action("concierge_email_draft",
     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
     tier=yellow per autosend-policy.yaml

9. SLA timing check (Gate B leading metric — NOT Gate A hard-fail)
   → elapsed = now() - event_timestamp
   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
     → hh_decision_output("concierge_sla_miss",
       "candidate:<bullhorn_id>:<event_type>",
       "elapsed_seconds:<N>; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct")
       — mandatory audit row per master brief §8.1 Change 2 (phase=output;
       no tiered action_type required — this is an internal status marker)
   → per ULTRAPLAN A6 line 566 (as amended by ADR-007): the 30-min draft SLA is
     a Gate B leading metric (90% of drafts within 30 min), not a per-draft hard
     fail (legitimate polling-fallback delays would otherwise block drafts)

10. PII boundary check
    → no PII from other candidates referenced in body
    → no PII from competitor clients referenced
    → no compensation specifics outside what's already in candidate's record
    → ESC_PII_LEAKAGE_RISK on hit (blocking)
    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
     "result:passed")

11. Autosend-bridge routing (D1 path)
    → per Founder Decision D1 (selected 2026-05-31 as D1-B — Telegram shim per `docs/decisions/2026-05-31-d1-founder-decision.md`; v1.1+ upgrade path to D1-A queued):
      D1-A (bridge to cortextOS approval system): POST internal API
      D1-B (lightweight Telegram shim): send approval prompt to operator
      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
    → per autosend-policy.yaml: orange-tier; consultant approves
    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within the policy timeout
      (default PT4H per autosend-policy.yaml (grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field; default `PT4H`) + escalation-codes.md
      lines 348-353; looked up per action_type, not hardcoded) (D1-A/B)
    → hh_decision_action("concierge_approval_routed",
      "candidate:<bullhorn_id>:<event_type>", payload_hash,
      "d1_path:<A|B|C>; bridge_target:<approval_id_or_vault_path>")

12. (After operator approval) Send execution — orange-tier
    → microsoft-graph.send_email() OR gmail.send_email() per tenant config
    → BCC: tenant's archive address (per tenant config)
    → hh_decision_action("gmail_outlook_send_to_candidate",
      "candidate:<bullhorn_id>", payload_hash, payload_preview)
      [or `bullhorn_note_customer_visible` if channel=Bullhorn-note]
    → ESC_SEND_FAIL on 4xx/5xx; retry once 30s backoff

13. Bullhorn activity-log write
    → bullhorn.create_activity_log(candidate_id, "concierge: <event_type>
      sent at <ISO>")
    → maintains audit trail in Bullhorn itself (NOT customer-visible;
      separate from bullhorn_note_customer_visible orange tier)
    → hh_decision_action("bullhorn_activity_log_write",
      "candidate:<bullhorn_id>", payload_hash,
      "event_type:<type>; bullhorn_activity_id:<id>") — green tier per
      autosend-policy.yaml (registered 2026-06-02 per Codex Fbis-R1 closure;
      grep `^  bullhorn_activity_log_write:` to verify). External-write
      action_type required for tier classification per autosend-policy §3.

14. Lifecycle state advance (Bullhorn write, conditional)
    → some events trigger Bullhorn state changes (e.g., interview-completed
      sent → advances state to "post-interview" if tenant policy says so)
    → per-tenant policy; opt-in; not all tenants want this
    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
      payload_hash, "event=<type> elapsed=<seconds>")

15. Session close + Gate B metric
    → compute elapsed (event → send) for Gate B SLA tracking
    → check ghosted-rate metric (any candidate with no Concierge action in
      14 days post-state-change → contributes to ghosted-rate)
    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
    → hh_decision_action("concierge_run_complete", "session:<tenant_slug>",
      payload_hash, "mode:<webhook|poll|nurture-sweep|manual>; drafts:<N>;
      sends:<N>; ghosted_rate:<float>") — green tier per autosend-policy.yaml;
      4-arg signature matches `_shared/hook-helpers.sh` `hh_decision_action
      <action_type> <target> <payload_hash> <payload_preview>` contract.
    → exit code 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):

- **"voice classifier score ≥ position-specific threshold"** (≥0.75 position 1, ≥0.78 position 2, ≥0.82 position 3) — hard-fail
- **"correct addressee resolution (no candidates emailed under another's name)"** — hard-fail (Step 4 critical; ESC_ADDRESSEE_MISMATCH)
- No tone-rule block-severity violations — hard-fail (ESC_TONE_RULE_VIOLATION)
- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
- Anti-duplicate guard passed (Step 2) — hard-fail (skip if true duplicate)
- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_AGENT_OUTPUT_SHAPE; ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10)

The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).

Gate A failures fire ESC codes per their catalogue-defined severity (do NOT conflate "Gate A blocks the draft from sending" with "ESC severity escalates to oncall"):

- **Catalogue blocking-severity:** `ESC_ADDRESSEE_MISMATCH`, `ESC_PII_LEAKAGE_RISK` — these route to operator + ifos_oncall_chat_id per catalogue §2.10 (truly customer-impacting violations).
- **Catalogue warn-severity:** `ESC_TONE_RULE_VIOLATION`, `ESC_AGENT_OUTPUT_SHAPE` — these route to operator_chat_id only per catalogue §2.10 + §2.7 (per-draft signal-quality issues; not customer-impacting unless multiple aggregate).

ALL FOUR cause Gate A to block the draft from sending (validate.sh exits non-zero; draft stays in vault; cycle.sh aborts the orange-tier emission). The "blocking" of the DRAFT is `validate.sh` behavior; the "blocking" severity of the ESC code is the operator-paging-urgency lookup. These are separate dimensions. Draft is moved to `/tmp` (out of the customer-facing path) regardless of ESC severity; operator is notified immediately for blocking-tier ESCs, asynchronously-aggregated for warn-tier.

**Honesty note (updated 2026-06-02 per Codex Fbis-R3 closure):** `agents/recruitment/concierge/validate.sh` **EXISTS as SKELETON** (committed `524bac6` on 2026-06-01) — the 5 Gate A checks G1-G5 are defined as TODO(W10-13) markers inside the SKELETON validate.sh; the W10-13 build slice replaces the TODOs with live impl per the contract above. The §5 contract describes what validate.sh's TODOs will become; the SKELETON file structurally exists and passes shellcheck CLEAN today but does not yet enforce the checks at runtime.

### Gate B — Outcome thresholds (success metrics, not block)

Per ULTRAPLAN A6 line 567 + ADR-007 amendment: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate"**. The third metric is ADR-007's Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail (NOT in original line 567 wording).

Three metrics:
- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%. (per ULTRAPLAN line 567)
- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`. (per ULTRAPLAN line 567)
- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)

Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Any of the three metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).

---

## §6 — Escalation codes

Concierge uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
| `ESC_MS_GRAPH_AUTH` | Microsoft Graph OAuth fail | **blocking** | operator + ifos_oncall (catalogue verbatim — token re-auth requires operator intervention; tenant-admin involvement is a manual operator-discretion follow-up, not part of the catalogue routing) |
| `ESC_GMAIL_AUTH` | Gmail OAuth fail | **blocking** | operator + ifos_oncall (catalogue verbatim; same tenant-admin caveat as ESC_MS_GRAPH_AUTH) |
| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
| `ESC_VOICE_DRIFT` | Voice classifier below the position-specific threshold (≥0.75/0.78/0.82) after 3 retries. The Gate A hard-fail (validate.sh exits non-zero; draft not sent) is expressed through `validate_gate_a_fail`, NOT through this code's severity: per catalogue (escalation-codes.md lines 120-125) `ESC_VOICE_DRIFT` is `warn` → `operator_chat_id` for ALL positions. Position-specific paging urgency (e.g. oncall on rejections) would require a catalogue amendment adding position-severity semantics — not yet made. | warn | operator_chat_id |
| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | warn (catalogue) — Gate A still blocks the draft from sending via validate.sh; ESC severity governs operator-paging urgency only | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md `ESC_APPROVAL_BRIDGE_TIMEOUT` block + autosend-policy.yaml grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field) | warn | operator + ifos_oncall (catalogue verbatim — operator absent + commitment may need rerouting; tenant-admin involvement is a manual escalation choice when bridge-timeout becomes pattern-recurring, not part of catalogue routing) |
| `ESC_SEND_FAIL` | Email provider 4xx/5xx | warn | operator_chat_id |
| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% OR 30-min SLA hit-rate <90% for 30 consecutive days | warn | founder + operator |
| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |

Concierge has the largest escalation surface of any v1.0 agent — appropriate for the highest-stakes customer-facing comms.

Concierge does NOT use:

- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.

---

## §7 — Voice + tone constraints

Steps 7-8 (draft generation + voice/tone validation) are the load-bearing voice surface of v1.0. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §Gotchas line 570; demand specificity)
  - No "Per our previous conversation" without referencing the actual conversation context
  - No urgency language ("URGENT", "ACT NOW") unless the lifecycle event genuinely requires it
  - No mention of other candidates by name
  - No salary/rate specifics outside what's already on the candidate's record
  - No competing-agency references
- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.

**Position-specific thresholds:**
- Position 1 (standard sends — acknowledgement, prep, debrief, nurture): voice ≥0.75
- Position 2 (placement-positive, status-update): voice ≥0.78
- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §Gotchas line 570 explicitly names rejection voice as the hardest case)

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies (W10-13 prerequisites)

Concierge build cannot start until ALL of the following are confirmed:

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
| **Microsoft Graph commercial signup** (per tenant) | Tenant onboarding | ⏸ |
| **Gmail / Google Workspace signup** (alternative per tenant) | Tenant onboarding | ⏸ |
| Microsoft Graph MCP connector | W10 build start (~3 days) | ⏸ |
| Gmail MCP connector | W10 build start (~3 days) | ⏸ |
| **Founder Decision D1 (autosend orange-tier path) ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md` | ✅ ACCEPTED |
| **Autosend bridge package scaffold** — `@ifos/autosend-bridge-telegram` lib + types + tests landed 2026-06-01 (commit `9b282d8`); Concierge consumer wiring at cycle.sh Step 11 landed (commits `669a4f4` + `9ec2bd6`) | ✅ SCAFFOLDED (Concierge side) |
| **Autosend bridge production wiring** — real Telegram Bot API + postgres approvals reader; this build slice (W10-13) delivers | W10-13 self | ⏸ |
| **v0.4 schema supplement** adding `operator_telegram_chat_id` + `email_channel` to `tenant_adapters.config` allowlist (per D1-B decision-doc §Implementation surface item 5) | W10-13 self | ⏸ |
| Autosend bridge built (per D1 outcome) | W10 build start (~2 days for D1-A; less for D1-B/C) | ⏸ |
| Voice classifier microservice live | W4-5 polish | ⏸ |
| Per-tenant comms-template library at `/vault/<slug>/concierge-templates/` | Tenant onboarding | ⏸ |
| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| `validate.sh` Gate A logic | Build at W10 start (~2 days; most complex of v1.0 validators) | ⏸ |
| `context.sh` hydration | Build at W10 start (~1 day) | ⏸ |
| `cycle.sh` orchestration (15-step) | Build at W10-11 (~5 days; lifecycle state machine + 12 event types) | ⏸ |
| Lifecycle event-detection polling fallback | Build at W11-12 (~3 days; Bullhorn webhook coverage gaps) | ⏸ |
| Comms-template library v0.1 (12 event types × 2 recipient roles = 24 templates minimum) | Build at W12-13 (~5 days) | ⏸ |
| 5 fixtures with golden outputs (broader than 3 for other agents; XL complexity warrants) | Build at W13 (~2 days) | ⏸ |

**Until ALL ⏸ items resolve to ✅, W10 build slice does not start.** XL build complexity = 4-week duration not negotiable.

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
| Q2 | Lifecycle event taxonomy — 12 events proposed in §3. Founder confidence each is correct + complete? Missing: "candidate referred to another role internally"? "Client cancelled brief"? | Founder review with first pilot consultants. Recommend: ship 12-event v1.0; expand v1.1+ based on real patterns. |
| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
| Q4 | Rejection emails (event 6) — Position 3 (voice ≥0.82). Is this enough, or should rejections route to consultant for full draft (not just approve)? | Founder review with first pilot consultant. Recommend: Concierge drafts; consultant approves; never bypasses voice gate. |
| Q5 | Comms-template customisation — every tenant edits these. Per-event-type, per-recipient-role × per-tenant = 24+ templates each. Authoring tool? | v1.0: Markdown files at `/vault/<slug>/concierge-templates/<event>-<role>.md`. v1.1: Brain UI WYSIWYG editor. |
| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
| Q9 | Cross-tenant lifecycle handling — what if a candidate placed at Tenant A's client interviews at Tenant B 6 weeks later? Bullhorn has separate tenant slugs; no cross-tenant leak. But operator visibility? | v1.0: strict tenant isolation (no cross-tenant data visibility). v1.1+: separate agent for tenant-network-graph if commercial demand. |
| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |

### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)

1. **Lifecycle event detection from Bullhorn is the unreliable bit.** Bullhorn's webhook coverage is patchy; polling fallbacks are required. Step 1 polling at 5-min cycle + anti-duplicate guard at Step 2 is the architecture.
2. **Voice quality on rejections is the hardest test case.** Position-3 threshold (≥0.82) + sensitive-event escalation routing (Step 6). Get this wrong and it costs the tenant a candidate relationship.
3. **Comms-template library is per-tenant, per-event-type, per-recipient-role.** 24+ templates per tenant minimum. Authoring effort is significant; consider this in pilot onboarding scoping.
4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add agent-identity email adapter (deferred).

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.

Status flips Proposed → Accepted when:
- Codex Round 4 Phase 2 ratifies
- **✅ ADR-007 (Concierge Gate A 30-min SLA hybrid) ACCEPTED + RATIFIED** — Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3 per `.codex/ratification/review-architecture-decision.md` skill (commit `c862c77`). Closes the documented deviation from ULTRAPLAN A6 line 566 wording; agent.md's Gate B framing of the 30-min SLA is now the canonical disposition. This Status-flip blocker is satisfied.
- ✅ **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`; package scaffold + Concierge consumer wiring landed 2026-06-01. NO LONGER a Proposed→Accepted blocker. The autosend-bridge production wiring + v0.4 schema supplement are W10-13 build-slice deliverables (Accepted→In-Force blockers, not Proposed→Accepted)
- Founder approves §9 Q2 (lifecycle taxonomy) + Q3 (send window) + Q4 (rejection routing) + Q5 (template authoring UX) + Q6 (Gate B UX)
- Q7-Q9 documented decisions captured

Status flips Accepted → In Force when:
- W10-13 build slice produces all 5 sibling bundle files + 5 fixtures (broader fixture coverage warranted by XL complexity)
- First production lifecycle webhook processed end-to-end against migration-test tenant
- 12-event taxonomy validated against first pilot tenant's actual Bullhorn state-change patterns
- Voice classifier microservice production-ready (per-tenant; position-3 ≥0.82 sustained)
- Gate B feedback loop operational (consultant approve/edit distinguishable)
- Codex re-ratifies post-build via `review-agent-bundle.md` skill

Until then: this document is a forward-looking scaffold. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at scaffold stage. Founder review at each iteration is expected.

*End of Concierge agent.md draft.*

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
I’ll verify the Concierge contract against the cited local sources: master brief, ULTRAPLAN, shared ESC catalogue, autosend policy, schema, and the sibling bundle where production-readiness claims matter.
exec
/bin/zsh -lc "rg --files | rg '("'^docs/|''^agents/_shared/|''^agents/recruitment/concierge/|vertical-schema|autosend|ULTRAPLAN|master|kill-criterion|ADR-007|2026-05-31-d1)'"'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
packages/utilities/autosend-bridge-telegram/src/index.ts
packages/utilities/autosend-bridge-telegram/src/message-format.ts
packages/utilities/autosend-bridge-telegram/src/decisions-postgres.ts
packages/utilities/autosend-bridge-telegram/src/bridge.ts
packages/utilities/autosend-bridge-telegram/src/types.ts
packages/utilities/autosend-bridge-telegram/src/transport-telegram.ts
packages/utilities/autosend-bridge-telegram/src/errors.ts
packages/utilities/autosend-bridge-telegram/vitest.config.ts
packages/utilities/autosend-bridge-telegram/tsconfig.json
packages/utilities/autosend-bridge-telegram/tsup.config.ts
packages/utilities/autosend-bridge-telegram/package.json
packages/utilities/autosend-bridge-telegram/README.md
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts
packages/utilities/autosend-bridge-telegram/tests/test-helpers.ts
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts
packages/utilities/autosend-bridge-telegram/tests/production-wiring.test.ts
packages/utilities/autosend-bridge-telegram/bin/propose.ts
packages/utilities/autosend-bridge-telegram/bin/await.ts
packages/utilities/autosend-bridge-telegram/bin/cli-shared.ts
packages/utilities/autosend-bridge-telegram/bin/record-decision.ts
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/README.md
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.4-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/verticals/recruitment/migrations/v0.4-to-v0.5.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.5-to-v0.4.sql
agents/recruitment/concierge/cleanup.sh
docs/incidents/2026-06-01-intelforce-ai-email-outage.md
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md
docs/decisions/brain-ui-scope.md
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md
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
docs/decisions/2026-05-31-d1-founder-decision.md
docs/decisions/sequencing-target.md
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md
docs/decisions/bullhorn-integration-path.md
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md
docs/specs/ULTRAPLAN.md
docs/specs/_archive-build-handoff.md
docs/specs/PRODUCT-SPEC.md
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml
agents/recruitment/concierge/fixtures/01-primary.yaml
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml
docs/runbooks/day-4-provisioning.md
docs/features/agent-build/00-ORCHESTRATOR.md
docs/runbooks/operational-hygiene-protocol.md
docs/features/agent-build/01-LAUNCH.md
docs/runbooks/tenant-lifecycle.md
docs/features/agent-build/STATUS.md
docs/runbooks/pii-purge-operational-pattern.md
docs/_supplementary/PRD-autonomous-agent.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/README.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/technical-strategy-v2.md
docs/_supplementary/execution-plan.md
agents/recruitment/concierge/templates/common-comms-templates.yaml
agents/recruitment/concierge/cycle.sh
agents/recruitment/concierge/README.md
agents/recruitment/concierge/tools.yaml
docs/_archive-build-pack/08-OPEN-DECISIONS.md
docs/_archive-build-pack/01-RECOMMENDATION.md
docs/_archive-build-pack/06-BUILD-PLAN.md
docs/_archive-build-pack/02-PRODUCT-VISION.md
docs/_archive-build-pack/README.md
docs/_archive-build-pack/03-ARCHITECTURE.md
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md
docs/_archive-build-pack/04-DATA-MODEL.md
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md
docs/_archive-build-pack/05-MIGRATION-MAP.md
docs/RISK-REGISTER.md
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md
docs/features/agent-build/02-specs/spec-001-janitor.md
docs/artefacts/diagnostic-hays-plc-2026-05-24.md
docs/features/agent-build/02-specs/spec-004-concierge.md
docs/features/agent-build/02-specs/spec-002-scribe.md
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md
docs/features/agent-build/02-specs/_TEMPLATE.md
logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md
agents/recruitment/concierge/bin/bh-bridge.sh
agents/recruitment/concierge/bin/render-concierge-draft.sh
agents/recruitment/concierge/validate.sh
agents/recruitment/concierge/context.sh
agents/recruitment/concierge/agent.md
logs/codex-ratification/round-3-remediation/docs_decisions_autosend-approval-bridge-spec-md.output.md
docs/design-mockups/brain-ui-decisions-feed-light-v01.html
docs/features/agent-build/04-reviews/review-sourcing-scout.md
docs/features/agent-build/03-implementation/concierge-summary.md
docs/build-brief/00-MASTER-BRIEF.md
docs/architecture/tenancy-invariants.md
docs/architecture/architecture-cohesion-review.md
docs/architecture/agent-bundle-renderer-design.md
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/architecture/vault-concurrency.md
docs/architecture/second-brain-design.md
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md
docs/operations/founder-legal-setup-guide.md
docs/operations/founder-manual-playbook-2026-05-31.md
docs/operations/goal-option-c-diagnostic-end-to-end.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-approval-bridge-spec-md.output.md
docs/operations/seedlegals-engagement-queries.md
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
docs/operations/goal-week-6-execution-plan.md
docs/operations/decision-log.md
docs/operations/goal-overnight-2026-05-31.md
docs/operations/handoff-2026-06-05-location-shift.md
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md
docs/operations/bullhorn-outreach-emails.md
docs/operations/goal-week-4-track-1.md
docs/operations/w4-bilateral-pass-6-agent-md.md
docs/operations/parallel-agent-build-method.md
docs/operations/w4-day-20-founder-runbook.md
docs/operations/oauth-sandbox-app-setup-runbook.md
docs/operations/goal-w4-day-26-2026-06-01.md
docs/operations/codex-ratification-guide.md
docs/operations/codex-round-2-handoff.md
docs/operations/codex-round-2-remediation-prompt.md
docs/operations/founder-api-signups-2026-06-03.md
docs/operations/local-dev-db-setup.md
docs/operations/pending-goal-w6-d36-cash-conductor-prep.md
docs/operations/goal-week-5-execution-plan.md
docs/operations/codex-ratification-execution-plan.md
docs/operations/session-retrospective-2026-06-03.md
docs/operations/codex-round-2-autonomous-prompt.md
docs/operations/goal-week-3-polish-and-scaffold.md
docs/operations/session-init-w7-p3-reconciliation.md

codex
The first pass already shows a likely honest-signal problem: the document says D1 is accepted in the header/§10, while §9 still lists D1 as an unresolved open question. I’m checking whether there are harder citation/schema issues as well before issuing the verdict.
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '590,605p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '555,572p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
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
   555	- **Gotchas:** LinkedIn rate limits via Proxycurl. Reed/CV-Library have separate auth and separate result schemas. Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it.
   556	
   557	#### A6. The Concierge — no candidate ghosted
   558	
   559	- **Build wave:** v1.0 (week 9–10)
   560	- **Always-on?** Tier 1 — persistent state across the candidate lifecycle
   561	- **Trigger type:** ATS state changes (candidate moved to interview, rejected, placed, etc.) + cron sweep for time-elapsed nurture events
   562	- **CortexOS primitives required:** Persistent PTY (#1), context rotation (#2), approval gates (#4), Telegram surface (#5)
   563	- **MCP tools required:** Bullhorn (read for state, write for activity log), Microsoft Graph / Gmail (send), AgentMail (optional for agent-identity sends)
   564	- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
   565	- **External APIs:** Microsoft Graph or Google Workspace per tenant; AgentMail for v1.1+
   566	- **Gate A:** voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82 per escalation_position); correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
   567	- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate (per ADR-007)
   568	- **Build complexity:** **XL** (4 weeks) — this is the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)
   569	- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
   570	
   571	### 8.2 v1.1 agents (seven, in build order)
   572	

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '80,115p;175,190p;248,282p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
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
   261	  # ───────────────────────────────────────────────────────────
   262	  # ORANGE — per-action human approval (10 action_types)
   263	  # ───────────────────────────────────────────────────────────
   264	
   265	  bullhorn_note_customer_visible:
   266	    tier: orange
   267	    agent: concierge
   268	    timeout: PT4H
   269	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   270	    irreversible: true
   271	    canonical: true
   272	
   273	  gmail_outlook_send_to_candidate:
   274	    tier: orange
   275	    agent: concierge
   276	    timeout: PT4H
   277	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   278	    irreversible: true
   279	
   280	  twilio_sms_send:
   281	    tier: orange
   282	    agent: concierge

exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-31-d1-founder-decision.md | sed -n '1,140p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
     1	# Founder Decision D1 — autosend orange-tier path
     2	
     3	**Status:** Accepted (founder-arbitrated 2026-05-31 via explicit delegation: *"i pretty much trust your decision making for the technical build stuff"*). Codex ratification: **deferred-to-W10-13-build-slice** per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` (cluster G stopped at partial-ratification after 4 rounds; the structural decision is accepted; the cross-doc consistency surface gets reconciled when W10-13 lands).
     4	**Decision:** **D1-B — Telegram shim** for v1.0; D1-A as v1.1+ upgrade.
     5	**Date:** 2026-05-31
     6	**Author:** Claude Code (arbitrating per delegated authority); founder may override at any time before Concierge W10 build start.
     7	**Supersedes:** the "D1 founder decision" line item in `2026-05-20-codex-round-1-founder-decisions.md` and the open-question rows in:
     8	- `agents/recruitment/concierge/agent.md` §9 Q1
     9	- `agents/recruitment/cash-conductor/agent.md` §8 (D1-pending fallback row)
    10	
    11	---
    12	
    13	## Context
    14	
    15	Per `docs/decisions/autosend-safety-policy.md` §4, orange-tier action_types (customer-facing sends like `xero_reminder_send_customer`, `gmail_outlook_send_to_candidate`, `bullhorn_note_customer_visible`) require **synchronous consultant approval** before the send executes. The agent drafts; the consultant says yes; the transport fires; an audit row records the full chain.
    16	
    17	Three paths were on the table for the v1.0 orange-tier approval mechanism:
    18	
    19	| Option | Mechanism | v1.0 cost | Strengths | Weaknesses |
    20	|---|---|---|---|---|
    21	| **D1-A** Bridge to cortextOS approval system | Concierge POSTs to an internal cortextOS approval API; operator approves in Brain UI; bridge calls back | ~2 days build (~3 days if approval-API doesn't yet exist) | Architecturally clean; reuses cortextOS primitive #4 (approval gates); UX in Brain UI is consistent with other approval flows | Brain UI v1.0 approval UX not yet built; depends on cortextOS approval-API stability; tightest coupling to upstream |
    22	| **D1-B** Lightweight Telegram shim | Concierge posts to operator's tenant-bound Telegram chat: `[ID:<x>] APPROVE drafted email to <recipient>? /approve <ID> or /reject <ID>`; Concierge polls Telegram or receives webhook; on approve → transport executes | <1 day build | Reuses cortextOS primitive #5 (Telegram surface) already in place; consultants are on Telegram already; lowest engineering cost; clean audit chain (every approve/reject = `decision_log` row); works the same for Cash Conductor + Concierge | Approval UX is a chat reply rather than a rich panel; per-draft attachment preview is just a 200-char text snippet + vault path; consultant must read the vault Markdown if they want to see the full draft body before approving |
    23	| **D1-C** No autosend; manual pickup | Concierge writes the draft to vault; sets `requires_consultant_action=true`; no notification; consultant manually polls vault and copies drafts to outbound | 0 days build (already supported by drafts-to-vault flow) | Zero risk of incorrect autosend; zero new build | UX is brutal; consultants miss drafts; defeats Concierge's "no candidate ghosted" promise; effectively kills Concierge as a v1.0 differentiator |
    24	
    25	---
    26	
    27	## Decision: D1-B (Telegram shim)
    28	
    29	**Why D1-B wins for v1.0:**
    30	
    31	1. **Cost-aligned to v1.0 scope.** D1-A's clean architecture is the right *v1.1+* answer once Brain UI matures; for v1.0 ship, D1-B's <1-day build matches the W10-13 Concierge slice budget.
    32	2. **Reuses an already-built primitive.** cortextOS primitive #5 (Telegram surface) is in place; operators already receive escalation notifications there. Adding `/approve <ID>` / `/reject <ID>` commands extends an existing surface rather than introducing a new one.
    33	3. **Audit chain is identical to D1-A.** Both paths emit the same `decision_log` rows (`xero_reminder_send_customer` orange action → operator approve/reject → transport `gmail_outlook_send_to_candidate` action). The Telegram interaction is the trigger, not the audit substrate.
    34	4. **D1-C kills Concierge's value.** Manual vault polling means missed drafts means ghosted candidates means Concierge fails its Gate B (`ghosted-rate <5%`). Non-starter.
    35	
    36	**Tradeoff accepted:** the approval UX is text-only on Telegram. Consultants who want to see the full draft body before approving open the vault path in the Telegram message. This is the same friction as reviewing an email draft in any other ticket system; acceptable for v1.0.
    37	
    38	**v1.1+ upgrade path (queued, not blocking):** D1-A bridge to cortextOS approval system + Brain UI rich-panel approval surface. The D1-B Telegram path stays available as a fallback (e.g., operator on the move, away from a desk). v1.1+ adds the *option* of D1-A, doesn't replace D1-B.
    39	
    40	---
    41	
    42	## Implementation surface (delivered by Concierge W10-13 build slice)
    43	
    44	1. **`packages/utilities/autosend-bridge-telegram/`** — small TypeScript package:
    45	   - `proposeApproval(action_type, target, draft_preview, vault_path, timeout=PT4H) → approval_id`
    46	   - Posts to operator's tenant Telegram chat with `[ID:<approval_id>]` + draft preview + vault path + `/approve <id>` / `/reject <id>` instructions.
    47	   - Polls or webhooks for the operator's reply.
    48	   - Returns `{outcome: approved | rejected | timeout, decided_by: <telegram_user_id>}`.
    49	   - Timeout default `PT4H` per `escalation-codes.md` `ESC_APPROVAL_BRIDGE_TIMEOUT` lines 348-353.
    50	2. **Concierge `cycle.sh` Step 11** — calls `proposeApproval` for orange-tier drafts; on `approved`, proceeds to Step 12 transport; on `rejected` or `timeout`, fires `ESC_APPROVAL_BRIDGE_TIMEOUT` (timeout) or records rejection in `decision_log` (rejected).
    51	3. **Cash Conductor `cycle.sh` Step 10** — same `proposeApproval` call for `xero_reminder_send_customer` rows; identical handling.
    52	4. **`tools.yaml` capability declarations** — add `autosend_bridge_telegram` capability to both Concierge and Cash Conductor.
    53	5. **Tenant config — W10-13 build-slice author picks the shape; BOTH paths now schema-clean.** The autosend-bridge consumer needs a per-tenant operator Telegram chat-id at runtime. Post-v0.4 supplement (LANDED 2026-06-03; commit `a1bbcf6`), the `validate_tenant_adapters_config_v0_4` allowlist contains **16 keys** (11 v0.3-forwarded + 5 v0.4-added: `operator_telegram_chat_id`, `email_channel`, `workos_org_id`, `granola_workspace_id`, `bullhorn_corporation_id`). Two viable paths the W10-13 build-slice author chooses between (BOTH schema-clean; no further schema work required):
    54	   - **Path A (reuse existing allowlist key) — RECOMMENDED for new tenants.** Store the chat-id inside `approval_routing` JSONB (allowlisted since v0.1; matches `autosend-safety-policy.md` `approval_routing.default_recipient` shape). Cleaner upgrade story to v1.1+ rich-panel approvals (one JSONB sub-tree per autosend-relevant config). No schema change ever needed at the consumer side.
    55	   - **Path B (top-level `operator_telegram_chat_id`).** Use the v0.4-added top-level key directly. Simpler single-key override in the onboarding wizard + clearer audit trail (one field, one value, one pattern check `^-?[0-9]+$`). Equally valid post-v0.4.
    56	
    57	   **Current state (env-var fallback retained for fixtures + local-dev):** the bridge consumer's `context.sh` reads the chat-id via the `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback (see `agents/recruitment/concierge/context.sh` Step 5 + Cash Conductor's equivalent). The autosend-bridge package itself takes the chat-id as a function argument per its README §Dependency injection — it never reads `tenant_adapters` directly. Fixtures (`agents/recruitment/concierge/fixtures/*.yaml`) use a `tenant_env_overrides:` block (not a `tenant_config:` block) to make the env-var-not-postgres distinction explicit. **No consumer code attempts a not-yet-allowlisted read; post-v0.4 the allowlist permits both paths, so future W10-13 wiring is unblocked.**
    58	
    59	   This decision-doc does NOT prescribe Path A vs Path B for the W10-13 author; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend). Path A is the recommended production path for the reasons above; Path B is a supported alternative.
    60	
    61	---
    62	
    63	## Codex ratification
    64	
    65	This decision doc ratifies via `.codex/ratification/review-architecture-decision.md` skill. Currently in flight under **cluster G** (`bash scripts/run-codex-ratification.sh --cluster G`); session-by-session ratification status is tracked in the closing Status-update line.
    66	
    67	## Consequences
    68	
    69	- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
    70	- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10-13 lands the autosend-bridge production wiring."
    71	- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: ADR-007 Accepted + Codex RATIFIED (DONE 2026-05-31 + Round 3), pilot LOI (PENDING), Bullhorn A+B (PENDING), founder approves §9 Q2-Q6 (PENDING).
    72	- **Schema impact: minimal-to-none → BOTH paths schema-clean post-v0.4.** Updated 2026-06-03: v0.4 supplement LANDED (commit `a1bbcf6`) adding `operator_telegram_chat_id` as a top-level allowlist entry. The W10-13 build slice now has TWO supported paths: Path A (reuse `approval_routing` JSONB sub-tree; recommended for new tenants — see implementation surface item 5) or Path B (use the new top-level key directly). Either path satisfies schema-before-code. The current consumer scaffolding (Concierge `context.sh` Step 5 + 3 fixtures) reads via `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback and does NOT attempt any `tenant_adapters` read; W10-13 build-slice author chooses Path A or Path B + implements the canonical SELECT alongside connection-pool setup.
    73	- **No additional API keys/signups for the founder vault.** Day-4 provisioning (`docs/runbooks/day-4-provisioning.md` §6.5) creates the `_secrets.env` SKELETON only (touched empty at mode 0600); the Telegram bot token is populated by founder bootstrap (covered separately by tenant onboarding playbook — NOT Day-4), and the per-tenant operator chat-id is populated by tenant onboarding (W10-13 build slice; see implementation surface item 5 above). Once both are in place, no recurring credentials work — the bot token doesn't rotate per send; the chat-id is per-tenant-stable.
    74	- **Schema-before-code discipline — respected.** The five rules (master brief §1) state schema-before-code. Today's state: bridge package scaffold + consumer wiring landed in env-var-fallback mode; no consumer attempts to read `tenant_adapters.config.operator_telegram_chat_id` (which isn't yet allowlisted as a top-level key) at runtime. Concierge `context.sh` lines 88-90 (post-2026-06-02 update) use `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback exclusively; fixtures use `tenant_env_overrides:` blocks (renamed from `tenant_config:` post-2026-06-02) to make the env-var-not-postgres distinction explicit. The schema-before-code rule holds: no schema-violating read occurs at runtime today; when the W10-13 build-slice author chooses Path A (reuse `approval_routing`) or Path B (add v0.4 key), the appropriate schema state will be in place BEFORE the consumer code is wired to read it.
    75	
    76	---
    77	
    78	*End of D1 decision doc.*
    79	
    80	---
    81	
    82	**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **all consumers still operate in env-var-fallback mode** (per `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` in `context.sh`); no `tenant_adapters` reads attempted at runtime; fixtures use `tenant_env_overrides:` blocks to match. **v0.4 supplement LANDED 2026-06-03** (commit `a1bbcf6`) adding `operator_telegram_chat_id` as a top-level allowlist entry — W10-13 build slice picks Path A (reuse `approval_routing` JSONB; recommended) or Path B (top-level key); **both paths are now schema-clean**. Concierge `context.sh` TODO(W10-13) markers updated 2026-06-03 (commit `98ab8ce`) to reflect supplement-landed state. Codex ratification currently in flight under cluster G (R3 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc); v0.4 supplement will ratify separately under W5 Phase 7 F-tris cluster.

exec
/bin/zsh -lc "rg -n \"AgentMail|Composio|agent-identity|D1 founder decision|Status: Proposed|operator_telegram_chat_id|email_channel|W10-13|EXISTS as SKELETON|BUILT|TODO\\(W10-13\\)|hh_decision_action\\(\" agents/recruitment/concierge/agent.md agents/recruitment/concierge/*.sh agents/recruitment/concierge/tools.yaml docs/decisions/2026-05-31-d1-founder-decision.md docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
agents/recruitment/concierge/cleanup.sh:2:# Concierge agent — cleanup.sh (post-run state purge; W10-13 LIVE)
agents/recruitment/concierge/cleanup.sh:4:# Status: BUILT (W10-13 build slice; live cache purge below).
agents/recruitment/concierge/cleanup.sh:22:# Side effects (W10-13 build slice):
agents/recruitment/concierge/cleanup.sh:73:# Exported so the W10-13 build-slice can extend the find -delete logic via
agents/recruitment/concierge/cleanup.sh:79:# W10-13 LIVE: prune transient HTTP-cache entries older than 24h. Token files
docs/decisions/2026-05-31-d1-founder-decision.md:3:**Status:** Accepted (founder-arbitrated 2026-05-31 via explicit delegation: *"i pretty much trust your decision making for the technical build stuff"*). Codex ratification: **deferred-to-W10-13-build-slice** per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` (cluster G stopped at partial-ratification after 4 rounds; the structural decision is accepted; the cross-doc consistency surface gets reconciled when W10-13 lands).
docs/decisions/2026-05-31-d1-founder-decision.md:7:**Supersedes:** the "D1 founder decision" line item in `2026-05-20-codex-round-1-founder-decisions.md` and the open-question rows in:
docs/decisions/2026-05-31-d1-founder-decision.md:31:1. **Cost-aligned to v1.0 scope.** D1-A's clean architecture is the right *v1.1+* answer once Brain UI matures; for v1.0 ship, D1-B's <1-day build matches the W10-13 Concierge slice budget.
docs/decisions/2026-05-31-d1-founder-decision.md:42:## Implementation surface (delivered by Concierge W10-13 build slice)
docs/decisions/2026-05-31-d1-founder-decision.md:53:5. **Tenant config — W10-13 build-slice author picks the shape; BOTH paths now schema-clean.** The autosend-bridge consumer needs a per-tenant operator Telegram chat-id at runtime. Post-v0.4 supplement (LANDED 2026-06-03; commit `a1bbcf6`), the `validate_tenant_adapters_config_v0_4` allowlist contains **16 keys** (11 v0.3-forwarded + 5 v0.4-added: `operator_telegram_chat_id`, `email_channel`, `workos_org_id`, `granola_workspace_id`, `bullhorn_corporation_id`). Two viable paths the W10-13 build-slice author chooses between (BOTH schema-clean; no further schema work required):
docs/decisions/2026-05-31-d1-founder-decision.md:55:   - **Path B (top-level `operator_telegram_chat_id`).** Use the v0.4-added top-level key directly. Simpler single-key override in the onboarding wizard + clearer audit trail (one field, one value, one pattern check `^-?[0-9]+$`). Equally valid post-v0.4.
docs/decisions/2026-05-31-d1-founder-decision.md:57:   **Current state (env-var fallback retained for fixtures + local-dev):** the bridge consumer's `context.sh` reads the chat-id via the `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback (see `agents/recruitment/concierge/context.sh` Step 5 + Cash Conductor's equivalent). The autosend-bridge package itself takes the chat-id as a function argument per its README §Dependency injection — it never reads `tenant_adapters` directly. Fixtures (`agents/recruitment/concierge/fixtures/*.yaml`) use a `tenant_env_overrides:` block (not a `tenant_config:` block) to make the env-var-not-postgres distinction explicit. **No consumer code attempts a not-yet-allowlisted read; post-v0.4 the allowlist permits both paths, so future W10-13 wiring is unblocked.**
docs/decisions/2026-05-31-d1-founder-decision.md:59:   This decision-doc does NOT prescribe Path A vs Path B for the W10-13 author; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend). Path A is the recommended production path for the reasons above; Path B is a supported alternative.
docs/decisions/2026-05-31-d1-founder-decision.md:70:- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10-13 lands the autosend-bridge production wiring."
docs/decisions/2026-05-31-d1-founder-decision.md:72:- **Schema impact: minimal-to-none → BOTH paths schema-clean post-v0.4.** Updated 2026-06-03: v0.4 supplement LANDED (commit `a1bbcf6`) adding `operator_telegram_chat_id` as a top-level allowlist entry. The W10-13 build slice now has TWO supported paths: Path A (reuse `approval_routing` JSONB sub-tree; recommended for new tenants — see implementation surface item 5) or Path B (use the new top-level key directly). Either path satisfies schema-before-code. The current consumer scaffolding (Concierge `context.sh` Step 5 + 3 fixtures) reads via `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback and does NOT attempt any `tenant_adapters` read; W10-13 build-slice author chooses Path A or Path B + implements the canonical SELECT alongside connection-pool setup.
docs/decisions/2026-05-31-d1-founder-decision.md:73:- **No additional API keys/signups for the founder vault.** Day-4 provisioning (`docs/runbooks/day-4-provisioning.md` §6.5) creates the `_secrets.env` SKELETON only (touched empty at mode 0600); the Telegram bot token is populated by founder bootstrap (covered separately by tenant onboarding playbook — NOT Day-4), and the per-tenant operator chat-id is populated by tenant onboarding (W10-13 build slice; see implementation surface item 5 above). Once both are in place, no recurring credentials work — the bot token doesn't rotate per send; the chat-id is per-tenant-stable.
docs/decisions/2026-05-31-d1-founder-decision.md:74:- **Schema-before-code discipline — respected.** The five rules (master brief §1) state schema-before-code. Today's state: bridge package scaffold + consumer wiring landed in env-var-fallback mode; no consumer attempts to read `tenant_adapters.config.operator_telegram_chat_id` (which isn't yet allowlisted as a top-level key) at runtime. Concierge `context.sh` lines 88-90 (post-2026-06-02 update) use `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback exclusively; fixtures use `tenant_env_overrides:` blocks (renamed from `tenant_config:` post-2026-06-02) to make the env-var-not-postgres distinction explicit. The schema-before-code rule holds: no schema-violating read occurs at runtime today; when the W10-13 build-slice author chooses Path A (reuse `approval_routing`) or Path B (add v0.4 key), the appropriate schema state will be in place BEFORE the consumer code is wired to read it.
docs/decisions/2026-05-31-d1-founder-decision.md:82:**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **all consumers still operate in env-var-fallback mode** (per `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` in `context.sh`); no `tenant_adapters` reads attempted at runtime; fixtures use `tenant_env_overrides:` blocks to match. **v0.4 supplement LANDED 2026-06-03** (commit `a1bbcf6`) adding `operator_telegram_chat_id` as a top-level allowlist entry — W10-13 build slice picks Path A (reuse `approval_routing` JSONB; recommended) or Path B (top-level key); **both paths are now schema-clean**. Concierge `context.sh` TODO(W10-13) markers updated 2026-06-03 (commit `98ab8ce`) to reflect supplement-landed state. Codex ratification currently in flight under cluster G (R3 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc); v0.4 supplement will ratify separately under W5 Phase 7 F-tris cluster.
agents/recruitment/concierge/cycle.sh:2:# Concierge agent — cycle.sh (15-step orchestration; W10-13 LIVE)
agents/recruitment/concierge/cycle.sh:4:# Status: BUILT (W10-13 build slice; spec-004 §4 — every step, marker, ESC route).
agents/recruitment/concierge/tools.yaml:3:# Status: BUILT (W10-13 build slice). cycle.sh 15-step + validate.sh 6-check
agents/recruitment/concierge/tools.yaml:136:  # PRODUCTION WIRING LANDED in this W10-13 slice: real Telegram Bot API
agents/recruitment/concierge/tools.yaml:215:    action_type: concierge_cleanup  # green tier; QUEUED registration for cleanup.sh wire at W10-13
agents/recruitment/concierge/tools.yaml:219:# Action-type registration status (cross-reference autosend-policy.yaml at W10-13)
agents/recruitment/concierge/tools.yaml:246:# - No Composio / AgentMail references anywhere in this file.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:124:`decision_log.payload.detection_delay_seconds` is NOT introduced by this ADR. Queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first), with declaration + type validation landing together (per review-schema-change §3 — bounded values require CHECK or trigger). Concierge cycle.sh v0.0 does NOT write this key. Distinguishing Concierge generation latency from upstream polling latency in operational alerts is the v0.4 work item; v1.0 metrics use the elapsed (event-detection → draft-render) as a single number.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:132:| ADR-007-Q3 | What's the polling-fallback interval default? | Per-tenant; recommend 5 min as v1.0 default; 1 min for tenants with stable webhook coverage. Documented in tools.yaml at W10-13 build. |
agents/recruitment/concierge/agent.md:3:**Status:** Proposed-with-disagreement-on-file (`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` — bundle-layer Codex ratification deferred to W10-13 build slice; contract-layer ratification was achieved in W3 cluster E).
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim per `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Concierge consumer wiring landed (commits `669a4f4` + `9ec2bd6`). Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) + v0.4 schema supplement adding `operator_telegram_chat_id` + `email_channel` to the `tenant_adapters.config` allowlist (per D1-B decision-doc §Implementation surface item 5) — see §10.
agents/recruitment/concierge/agent.md:6:**Reading-discipline note (added 2026-06-02 per Codex Fbis-R3 closure):** this `agent.md` is the **CONTRACT** that the W10-13 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `669a4f4` + `9ec2bd6` + `524bac6` + `8ba3723` + `eb1f884` per Day-26 evening + R-round closures); they carry `TODO(W10-13)` markers throughout that the W10-13 build slice replaces with live implementation matching the contract below. **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON cycle.sh emits only minimal trigger/output markers — the yellow-tier + orange-tier audit rows the contract names are NOT yet emitted at runtime.** The SKELETON `context.sh` uses **env-var fallbacks** today (`IFOS_FORCE_EMAIL_CHANNEL`, `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID`) — the `TODO(W10-13)` markers documenting future `tenant_adapters.config` reads are gated on a v0.4 schema supplement landing FIRST (those keys are NOT in the v0.3 allowlist; the validator would hard-fail). Don't read agent.md as a description of running code; read it as the spec the W10-13 build slice implements after the v0.4 supplement lands.
agents/recruitment/concierge/agent.md:9:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:19:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:62:- agent-identity email adapter (deferred) integration (agent-identity sends for non-rejection comms)
agents/recruitment/concierge/agent.md:109:2. `phase='action'` via `hh_decision_action("concierge_email_draft", "candidate:<bullhorn_id>:<event_type>", payload_hash, payload_preview)`. This is the tier-classified row — `concierge_email_draft` is registered yellow tier per autosend-policy.yaml lookup (grep `^  concierge_email_draft:` to verify). Tier is recorded inside the autosend-emitted payload by the helper; it is NOT a top-level decision_log column. `payload_preview` carries `event_type`, `voice_score`, `recipient`, `escalation_position` as a concatenated string for cross-row correlation. Action_type stays stable across all 12 lifecycle events — event_type is in the preview string, not part of the action_type identifier.
agents/recruitment/concierge/agent.md:128:     Microsoft Graph / Gmail auth + agent-identity email adapter (deferred) (if v1.1+ enabled) +
agents/recruitment/concierge/agent.md:146:     its target field per `hh_decision_action(action_type, target, ...)` is
agents/recruitment/concierge/agent.md:229:   → on success: hh_decision_action("concierge_email_draft",
agents/recruitment/concierge/agent.md:262:    → hh_decision_action("concierge_approval_routed",
agents/recruitment/concierge/agent.md:269:    → hh_decision_action("gmail_outlook_send_to_candidate",
agents/recruitment/concierge/agent.md:279:    → hh_decision_action("bullhorn_activity_log_write",
agents/recruitment/concierge/agent.md:290:    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
agents/recruitment/concierge/agent.md:298:    → hh_decision_action("concierge_run_complete", "session:<tenant_slug>",
agents/recruitment/concierge/agent.md:330:**Honesty note (updated 2026-06-02 per Codex Fbis-R3 closure):** `agents/recruitment/concierge/validate.sh` **EXISTS as SKELETON** (committed `524bac6` on 2026-06-01) — the 5 Gate A checks G1-G5 are defined as TODO(W10-13) markers inside the SKELETON validate.sh; the W10-13 build slice replaces the TODOs with live impl per the contract above. The §5 contract describes what validate.sh's TODOs will become; the SKELETON file structurally exists and passes shellcheck CLEAN today but does not yet enforce the checks at runtime.
agents/recruitment/concierge/agent.md:402:## §8 — Build dependencies (W10-13 prerequisites)
agents/recruitment/concierge/agent.md:421:| **Autosend bridge production wiring** — real Telegram Bot API + postgres approvals reader; this build slice (W10-13) delivers | W10-13 self | ⏸ |
agents/recruitment/concierge/agent.md:422:| **v0.4 schema supplement** adding `operator_telegram_chat_id` + `email_channel` to `tenant_adapters.config` allowlist (per D1-B decision-doc §Implementation surface item 5) | W10-13 self | ⏸ |
agents/recruitment/concierge/agent.md:441:**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
agents/recruitment/concierge/agent.md:447:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
agents/recruitment/concierge/agent.md:454:| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
agents/recruitment/concierge/agent.md:463:4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add agent-identity email adapter (deferred).
agents/recruitment/concierge/agent.md:474:- ✅ **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`; package scaffold + Concierge consumer wiring landed 2026-06-01. NO LONGER a Proposed→Accepted blocker. The autosend-bridge production wiring + v0.4 schema supplement are W10-13 build-slice deliverables (Accepted→In-Force blockers, not Proposed→Accepted)
agents/recruitment/concierge/agent.md:479:- W10-13 build slice produces all 5 sibling bundle files + 5 fixtures (broader fixture coverage warranted by XL complexity)
agents/recruitment/concierge/validate.sh:2:# Concierge agent — validate.sh (Gate A enforcement; W10-13 LIVE)
agents/recruitment/concierge/validate.sh:4:# Status: BUILT (W10-13 build slice; spec-004 §5 — all 6 checks live).
agents/recruitment/concierge/context.sh:2:# Concierge agent — context.sh (pre-cycle hydration; W10-13 LIVE)
agents/recruitment/concierge/context.sh:4:# Status: BUILT (W10-13 build slice). v0.4 schema supplement landed 2026-06-03
agents/recruitment/concierge/context.sh:5:#         (commit a1bbcf6) — email_channel + operator_telegram_chat_id are
agents/recruitment/concierge/context.sh:31:# Side effects (W10-13 build slice):
agents/recruitment/concierge/context.sh:33:#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
agents/recruitment/concierge/context.sh:36:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:88:# Canonical: tenant_adapters.config.email_channel (v0.4-allowlisted key).
agents/recruitment/concierge/context.sh:111:[[ -z "${_ctx_channel}" ]] && _ctx_channel="$(_ctx_ta_read email_channel)"
agents/recruitment/concierge/context.sh:162:#   2. Path B: tenant_adapters.config.operator_telegram_chat_id (v0.4 key)
agents/recruitment/concierge/context.sh:167:[[ -z "${_ctx_op_chat}" ]] && _ctx_op_chat="$(_ctx_ta_read operator_telegram_chat_id)"
agents/recruitment/concierge/context.sh:187:  "agent:concierge; tenant:${CTX_TENANT_SLUG}; mode:${CTX_CONCIERGE_MODE:-webhook}; email_channel:${CTX_EMAIL_CHANNEL}"

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md | sed -n '1,170p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
     1	# ADR-007 — Concierge Gate A 30-minute draft SLA hybrid (Gate B leading metric, not per-draft hard-fail)
     2	
     3	**Status:** **Accepted (founder-arbitrated 2026-05-31).** Codex `review-architecture-decision` skill RATIFIED this ADR at Round 3 of the cluster-E run (2026-05-31) after R1+R2 mechanical fixes (commits `ca66431` + `9b2e10a`). The ULTRAPLAN §8.1 A6 line 566 + line 567 amendments are now **permanent** (no longer provisional). The original Codex R3 Finding 3 (Concierge agent.md reframes 30-min SLA as Gate B without an authoritative ADR) is structurally closed by this Accept.
     4	**Author:** Founder (Maddox) + Claude Code
     5	**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566 — Gate A 30-minute draft SLA clause
     6	**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
     7	**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — at the time of Codex R3, the Concierge `agent.md` reframed the 30-min SLA as Gate B without an ADR and §10 omitted an ADR-ratification blocker. Both have since been closed: Concierge `agent.md` §10 line 435 now lists "**ADR-007 RATIFIED**" as a Proposed → Accepted blocker, and this ADR exists. Analogue of ADR-006 (Diagnostic Gate A hybrid).
     8	
     9	---
    10	
    11	## Context
    12	
    13	ULTRAPLAN §8.1 A6 line 566 (pre-amendment wording):
    14	
    15	> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
    16	
    17	The clause implies three Gate A hard-fail conditions: (a) draft generated within 30 minutes of lifecycle event, (b) voice classifier ≥ 0.75, (c) addressee resolution correct.
    18	
    19	Concierge `agent.md` (Day-19 R3 scaffold) reframes (a) — the 30-minute draft SLA — from per-draft Gate A hard-fail to a Gate B leading metric (90% of drafts within 30 min, not per-draft hard fail). The other two clauses (voice classifier + addressee resolution) remain Gate A hard-fails. The reframe is documented in:
    20	
    21	- `agent.md` §1 line 17 (30-min framing as Gate B target)
    22	- `agent.md` §4 Step 9, lines 212-222 (`ESC_CONCIERGE_SLA_MISS` warn, aggregated to Gate B; not per-draft block; emits the mandatory `hh_decision_output("concierge_sla_miss", …)` audit row)
    23	- `agent.md` §5 lines 280-293 (Gate A scope; the 30-min SLA exclusion is stated at line 291)
    24	- `agent.md` §6 ESC table line 326 (`ESC_CONCIERGE_SLA_MISS` registered as warn, not blocking)
    25	
    26	This creates a documented gap between the upstream spec and the v0 scaffold. Codex R3 Finding 3 (Day-19 log `logs/codex-ratification/20260524T174513Z-13185/`):
    27	
    28	> The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria.
    29	
    30	Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).
    31	
    32	## The deviation in detail
    33	
    34	### Why per-draft hard-fail is operationally problematic
    35	
    36	The Concierge lifecycle-event trigger source is the Bullhorn ATS state-change webhook + a polling-fallback cron (per ULTRAPLAN A6 line 569 verbatim gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks").
    37	
    38	Polling-fallback delays are not Concierge's fault — the polling cron runs at a configurable interval (likely 5-15 minutes per tenant) and a state change that happens at minute 1 of a 15-minute cycle has a 14-minute "blind spot" before Concierge ever sees it. A per-draft hard-fail Gate A would treat this as a Concierge failure even though the draft IS generated within 30 minutes of detection (just not within 30 minutes of the actual Bullhorn state change).
    39	
    40	Treating this as Gate A hard-fail would cause Concierge to drop legitimate drafts whose timing was set by upstream-detection latency, not by Concierge generation latency. The product harm: a candidate experiences a "ghosted by recruiter" pattern that Concierge was designed to prevent.
    41	
    42	### Why the metric is still load-bearing as Gate B
    43	
    44	The 30-minute SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Treating it as Gate B at the 90% threshold:
    45	
    46	- Captures the population-level SLA promise
    47	- Tolerates the occasional polling-fallback-induced delay without blocking legitimate drafts
    48	- Drives a measurable improvement signal: if 30-min-SLA-hit-rate drops below 90% across a tenant, the polling interval is too slow OR Bullhorn webhook coverage is degraded — both actionable signals
    49	- Aggregate failures fire `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) when sustained — same operational lever as ADR-006's per-claim quality metric
    50	
    51	This is structurally identical to ADR-006's Tier 1 (per-section, hard-fail at the agent level) vs Tier 2 (per-claim, quality metric over time) split — applied here to time (30-min threshold per draft = Tier 1; 90% within 30-min over rolling window = Tier 2).
    52	
    53	## Alternatives considered
    54	
    55	**Alternative A — Keep ULTRAPLAN A6 line 566 verbatim: 30-min SLA is per-draft Gate A hard-fail.** Rejected because Bullhorn webhook coverage is patchy per the ULTRAPLAN A6 gotcha (the same source spec acknowledging the polling-fallback requirement); per-draft hard-fail would drop legitimate drafts whose Concierge generation IS within 30 min of detection but whose upstream detection latency exceeded 30 min. The product harm: candidate experiences "ghosted by recruiter" — exactly the pattern Concierge was designed to prevent.
    56	
    57	**Alternative B — Remove the 30-minute SLA entirely.** Rejected because the SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Removing it would let drafts slip indefinitely with no quality signal — the "no candidate ghosted" goal becomes unmeasurable.
    58	
    59	**Alternative C — Measure occurrence-time (Bullhorn state-change timestamp) rather than detection-time (webhook arrival or polling-cron tick).** Rejected because Bullhorn state-change timestamps are not always reliable (Bullhorn webhook gotcha; some state changes lack a clean timestamp). Detection-time is what Concierge actually observes; occurrence-time would require infrastructure Concierge doesn't own.
    60	
    61	**Alternative D (selected) — Hybrid: voice + addressee checks stay Gate A; 30-min SLA moves to Gate B at 90% threshold.** Detection-time-based; population-level promise captured; per-draft outliers don't block.
    62	
    63	## Decision
    64	
    65	### Decision 1 — Move Concierge 30-minute SLA from Gate A hard-fail to Gate B leading metric (90% target)
    66	
    67	**Concierge Gate A is the subset of ULTRAPLAN A6 line 566 that is operationally enforceable per-draft:**
    68	
    69	- ✅ Voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82) — Gate A hard-fail
    70	- ✅ Correct addressee resolution (no candidates emailed under another's name) — Gate A hard-fail (`ESC_ADDRESSEE_MISMATCH`)
    71	- ✅ No tone-rule block-severity violations — Gate A hard-fail (`ESC_TONE_RULE_VIOLATION`)
    72	- ✅ No PII outside firm boundary — Gate A hard-fail (`ESC_PII_LEAKAGE_RISK`)
    73	- ✅ Anti-duplicate guard passed — Gate A hard-fail
    74	- ✅ All Bullhorn context fields present — Gate A hard-fail (`ESC_AGENT_OUTPUT_SHAPE`)
    75	
    76	**The 30-minute draft SLA moves to Gate B leading metric:**
    77	
    78	- 90% of drafts generated within 30 minutes of lifecycle-event DETECTION (not lifecycle-event occurrence)
    79	- Per-draft SLA miss fires `ESC_CONCIERGE_SLA_MISS` (warn, aggregated to Gate B)
    80	- Rolling 30-day per-tenant aggregate <90% fires `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) — actionable signal
    81	- v0.4 schema work: Concierge cycle.sh will record upstream-detection-latency separately in the audit payload (`payload.detection_delay_seconds`) once the field is declared and validated in a v0.4 supplement. v0.3 + v1.0 do NOT introduce this payload key — it would violate review-schema-change §3 (bounded values require CHECK or trigger). The metric attribution distinction (Concierge generation latency vs upstream polling latency) IS the right product behavior but the schema authority lands later.
    82	
    83	**ULTRAPLAN §8.1 A6 line 566 is amended in-band (Accepted by founder 2026-05-31)** following the ADR-006 precedent, which made the same kind of in-band amendment at line 496. There is no separate master-brief clause authorizing in-band spec amendments — master brief §10.3 step 4 only covers incorporating Codex feedback or writing a disagreement doc; the authority for the amendment is this ADR itself, now Accepted:
    84	
    85	Pre-amendment:
    86	> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
    87	
    88	Post-amendment:
    89	> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
    90	
    91	## Consequences
    92	
    93	**Positive:**
    94	
    95	1. Concierge drafts are not dropped when upstream polling-fallback latency exceeds 30 minutes
    96	2. The product UX promise of "post-state-change comms within 30 minutes" is captured at the population level
    97	3. The metric attribution is clean — operators can distinguish Concierge generation latency from Bullhorn webhook/polling latency
    98	4. Structural parity with ADR-006: per-event Gate A vs aggregate Gate B as the canonical Tier-1/Tier-2 split for time-based SLAs (replicable pattern for future agents)
    99	
   100	**Negative:**
   101	
   102	1. A per-tenant 30-minute SLA promise is harder to enforce contractually — pilot agreements must reflect that the SLA is at the population level not per-event
   103	2. Tenants with high webhook coverage will see better than 90%; tenants with webhook-coverage gaps see worse — the metric reads as Concierge quality but is partly an upstream condition. v1.0 cannot fully disambiguate this: `payload.detection_delay_seconds` is NOT introduced until a v0.4 supplement declares + validates it (see Implementation below). Until then operators use the single elapsed (detection → render) metric and treat a sustained sub-90% rate as a prompt to check the polling interval + Bullhorn webhook coverage.
   104	3. The Concierge agent.md §10 Accepted criteria must include ratification of this ADR as a blocker (closing Codex R3 Finding 3 properly)
   105	
   106	**Neutral:**
   107	
   108	4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).
   109	
   110	## Implementation
   111	
   112	### In-band ULTRAPLAN amendment (Accepted with this ADR 2026-05-31; ADR-006 precedent)
   113	
   114	ULTRAPLAN §8.1 A6 line 566 amended in the same commit as this ADR. Pre-amendment / post-amendment text is captured in this ADR's body. The amendment also updated line 567 Gate B target to include the new ≥90% 30-min SLA hit rate threshold (per ADR-007). See commit history for the diff.
   115	
   116	### Concierge §10 amendment
   117	
   118	Add to Accepted blockers (after R3 commit `f79c018` baseline):
   119	
   120	> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.
   121	
   122	### Audit payload extension (deferred to v0.4 supplement)
   123	
   124	`decision_log.payload.detection_delay_seconds` is NOT introduced by this ADR. Queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first), with declaration + type validation landing together (per review-schema-change §3 — bounded values require CHECK or trigger). Concierge cycle.sh v0.0 does NOT write this key. Distinguishing Concierge generation latency from upstream polling latency in operational alerts is the v0.4 work item; v1.0 metrics use the elapsed (event-detection → draft-render) as a single number.
   125	
   126	## Open questions
   127	
   128	| # | Question | Resolution path |
   129	|---|---|---|
   130	| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
   131	| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Resolved: separate code, for clean Telegram routing (`_GATE_B_MISS` is the generic aggregate). `ESC_CONCIERGE_SLA_MISS` is already registered in `escalation-codes.md` lines 431-439 — no longer queued. |
   132	| ADR-007-Q3 | What's the polling-fallback interval default? | Per-tenant; recommend 5 min as v1.0 default; 1 min for tenants with stable webhook coverage. Documented in tools.yaml at W10-13 build. |
   133	
   134	## References
   135	
   136	- ADR-006 — Diagnostic Gate A hybrid (structural template for Tier 1 vs Tier 2 split)
   137	- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
   138	- `agents/recruitment/concierge/agent.md` §1, §4 Step 9, §5, §6 (Gate B framing already implemented)
   139	- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
   140	- `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3
   141	- Master brief §1 Rule 4 (Quality gates before features) + §10.5 (ADRs are ratifiable artefacts)
   142	
   143	---
   144	
   145	**Status:** **Accepted (founder-arbitrated 2026-05-31).** Codex RATIFIED at Round 3 of the cluster-E 2026-05-31 session; founder Accept stamp completes the §10.5 cycle. ULTRAPLAN amendments permanent.

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/cycle.sh | sed -n '1,80p;180,360p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/validate.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Concierge agent — validate.sh (Gate A enforcement; W10-13 LIVE)
     3	#
     4	# Status: BUILT (W10-13 build slice; spec-004 §5 — all 6 checks live).
     5	# Reading order: agent.md §5 (Gate A) + §6 (ESC codes) + §1 thresholds first.
     6	#
     7	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is
     8	# the hard-fail gate that runs BETWEEN draft generation (cycle.sh Step 7) and
     9	# the autosend-bridge propose call (Step 11). If any check fails, validate.sh
    10	# exits non-zero + emits the dominant ESC_* escalation row + a
    11	# validate_gate_a_fail action row; the draft is moved OUT of the
    12	# customer-facing path (/tmp) per agent.md §5; cycle.sh aborts the draft.
    13	#
    14	# Invocation contract:
    15	#   bash validate.sh <draft_path>
    16	#
    17	# Inputs:
    18	#   - $1: path to the vault concierge-draft file (cycle.sh Step 7 wrote it)
    19	#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR, IFOS_DB_URL
    20	#
    21	# Exit codes:
    22	#   0  All Gate A checks pass; cycle.sh proceeds to Step 8 action row + Step 11
    23	#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts the draft
    24	#   2  validate.sh invocation error (bad args, missing draft, env unset)
    25	#
    26	# Checks (per agent.md §5 Gate A + spec-004 §5 — 6 checks):
    27	#   G1 — voice classifier score ≥ position-specific threshold
    28	#        (position 1: ≥0.75 ; position 2: ≥0.78 ; position 3: ≥0.82).
    29	#        HONESTY: no voice classifier exists in v1.0 (@ifos/voice-classifier
    30	#        unbuilt; voice_corpus empty) → unscored drafts WARN-AND-PASS (the
    31	#        accepted v1.0 Gate A behaviour); the threshold HARD-ENFORCES on any
    32	#        real numeric score (fixtures supply one to prove the gate).
    33	#   G2 — addressee resolution: draft recipient matches the changing
    34	#        candidate's email (entities cache cross-check; ULTRAPLAN A6 line 566
    35	#        verbatim "no candidates emailed under another's name") —
    36	#        ESC_ADDRESSEE_MISMATCH (blocking)
    37	#   G3 — no block-severity tone-rule violation (tenant tone_rule rows via
    38	#        hh_load_tone_rules ∋ concierge: examples_negative phrase match;
    39	#        plus the agent.md §7 built-in block phrases) —
    40	#        ESC_TONE_RULE_VIOLATION
    41	#   G4 — no PII outside firm boundary (email addresses in body whose domain
    42	#        is neither the recipient's nor an allowlisted firm domain) —
    43	#        ESC_PII_LEAKAGE_RISK (blocking)
    44	#   G5 — anti-duplicate re-check at validate time (race guard vs Step 2) —
    45	#        ESC_AUTOSEND_RACE (warn class; still blocks the draft)
    46	#   G6 — Bullhorn context complete: candidate name + email present —
    47	#        ESC_AGENT_OUTPUT_SHAPE
    48	# (30-min SLA is Gate B leading, NOT a Gate A hard-fail — ADR-007.)
    49	
    50	set -uo pipefail
    51	
    52	# ────────────────────────────────────────────────────────────────────────
    53	# Pre-flight
    54	# ────────────────────────────────────────────────────────────────────────
    55	
    56	if [[ $# -lt 1 ]]; then
    57	  printf 'concierge/validate.sh: usage: validate.sh <draft_path>\n' >&2
    58	  exit 2
    59	fi
    60	
    61	readonly DRAFT="$1"
    62	
    63	if [[ ! -f "${DRAFT}" ]]; then
    64	  printf 'validate.sh: draft not found at %s\n' "${DRAFT}" >&2
    65	  exit 2
    66	fi
    67	
    68	if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
    69	  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
    70	  exit 2
    71	fi
    72	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    73	  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
    74	  exit 2
    75	fi
    76	
    77	# Resolve _shared/ helpers (4-candidate fallback; matches sibling pattern
    78	# post d7d52c5 smoke-hotfix).
    79	_SHARED_DIR=""
    80	for _candidate in \
    81	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    82	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    83	  "${CTX_AGENT_DIR}/../../_shared" \
    84	  "${CTX_AGENT_DIR}/../_shared" ; do
    85	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    86	    _SHARED_DIR="${_candidate}"
    87	    break
    88	  fi
    89	done
    90	if [[ -z "${_SHARED_DIR}" ]]; then
    91	  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
    92	  exit 2
    93	fi
    94	# shellcheck source=/dev/null
    95	source "${_SHARED_DIR}/hook-helpers.sh"
    96	# voice-loader supplies hh_load_tone_rules (G3).
    97	if [[ -f "${_SHARED_DIR}/voice-loader.sh" ]]; then
    98	  # shellcheck source=/dev/null
    99	  source "${_SHARED_DIR}/voice-loader.sh"
   100	fi
   101	
   102	# Track failures + warnings across all checks (collect all before exit for
   103	# richer audit; same pattern as cash-conductor/validate.sh).
   104	declare -a FAILURES=()
   105	declare -a WARNINGS=()
   106	
   107	_fail() {
   108	  FAILURES+=("$1")
   109	  printf '  ✗ %s\n' "$1" >&2
   110	}
   111	_warn() {
   112	  WARNINGS+=("$1")
   113	  printf '  ! %s\n' "$1" >&2
   114	}
   115	_ok() {
   116	  printf '  ✓ %s\n' "$1"
   117	}
   118	
   119	# Dominant failure class for ESC routing (first hard fail wins).
   120	ESC_CLASS=""
   121	
   122	# Frontmatter reader: pull "key: value" from the leading YAML block.
   123	_fm() {
   124	  sed -n '1,/^---$/{/^---$/d;p;}' "${DRAFT}" 2>/dev/null \
   125	    | grep -m1 "^$1:" | sed "s/^$1:[[:space:]]*//; s/^\"//; s/\"$//"
   126	}
   127	# Body = everything after the second '---'.
   128	_body() { awk 'c==2{print} /^---$/{c++}' "${DRAFT}" 2>/dev/null; }
   129	
   130	D_CANDIDATE_ID="$(_fm candidate_id)"
   131	D_CANDIDATE_NAME="$(_fm candidate_name)"
   132	D_EVENT_TYPE="$(_fm event_type)"
   133	D_RECIPIENT="$(_fm recipient)"
   134	D_RECIPIENT_ROLE="$(_fm recipient_role)"
   135	D_VOICE="$(_fm voice_score)"
   136	D_POSITION="$(_fm escalation_position)"
   137	
   138	# One RLS-scoped read of the candidate's entities cache row (G2 + G6).
   139	DB_CAND_EMAIL="" DB_CAND_NAME="" DB_ROW_PRESENT=0
   140	if [[ -n "${D_CANDIDATE_ID}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   141	  _db_row="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   142	    --set=tenant="${CTX_TENANT_SLUG}" --set=cid="${D_CANDIDATE_ID}" <<'SQL' 2>/dev/null
   143	BEGIN;
   144	SET LOCAL app.current_tenant = :'tenant';
   145	SELECT coalesce(data->>'email','') || '|' || coalesce(data->>'name','')
   146	FROM entities WHERE entity_type='candidate' AND entity_id = :'cid' LIMIT 1;
   147	COMMIT;
   148	SQL
   149	)"
   150	  _db_row="$(printf '%s\n' "${_db_row}" | grep -vE '^$' | head -1 || true)"
   151	  if [[ -n "${_db_row}" ]]; then
   152	    DB_ROW_PRESENT=1
   153	    IFS='|' read -r DB_CAND_EMAIL DB_CAND_NAME <<<"${_db_row}"
   154	  fi
   155	fi
   156	
   157	# ────────────────────────────────────────────────────────────────────────
   158	# G1 — voice classifier score ≥ position-specific threshold
   159	# Position 1 ≥0.75 ; Position 2 ≥0.78 ; Position 3 ≥0.82
   160	# Reference: agent.md §5 Gate A + §4 Step 8 + ULTRAPLAN A6 line 566 (amended)
   161	# ────────────────────────────────────────────────────────────────────────
   162	
   163	if [[ "${D_VOICE}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
   164	  case "${D_POSITION}" in
   165	    3) _thr="0.82" ;;
   166	    2) _thr="0.78" ;;
   167	    *) _thr="0.75" ;;
   168	  esac
   169	  if awk -v s="${D_VOICE}" -v t="${_thr}" 'BEGIN{exit !(s>=t)}'; then
   170	    _ok "G1: voice_score ${D_VOICE} ≥ ${_thr} (position ${D_POSITION:-1})"
   171	  else
   172	    _fail "G1: voice_score ${D_VOICE} < ${_thr} (position ${D_POSITION:-1})"
   173	    ESC_CLASS="${ESC_CLASS:-ESC_VOICE_DRIFT}"
   174	  fi
   175	else
   176	  # unscored/no_corpus is the HONEST v1.0 state — warn-and-pass (accepted
   177	  # Gate A behaviour; @ifos/voice-classifier unbuilt, voice_corpus empty).
   178	  _warn "G1: voice unscored (${D_VOICE:-none}) — no classifier/corpus in v1.0; threshold enforced only on real numeric scores"
   179	fi
   180	
   181	# ────────────────────────────────────────────────────────────────────────
   182	# G2 — addressee resolution: recipient matches the changing candidate.
   183	# ULTRAPLAN A6 line 566 verbatim: "no candidates emailed under another's
   184	# name". client_contact recipients are checked the inverse way: the
   185	# recipient must NOT be a different candidate's address.
   186	# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on fail.
   187	# ────────────────────────────────────────────────────────────────────────
   188	
   189	if [[ "${D_RECIPIENT_ROLE}" == "candidate" ]]; then
   190	  if [[ -z "${DB_CAND_EMAIL}" ]]; then
   191	    _warn "G2: no candidate email in entities cache — cross-check deferred (G6 governs completeness)"
   192	  elif [[ "${D_RECIPIENT}" == "${DB_CAND_EMAIL}" ]]; then
   193	    _ok "G2: recipient matches candidate ${D_CANDIDATE_ID} (${D_RECIPIENT})"
   194	  else
   195	    _fail "G2: ADDRESSEE MISMATCH — draft recipient '${D_RECIPIENT}' != candidate email '${DB_CAND_EMAIL}'"
   196	    ESC_CLASS="ESC_ADDRESSEE_MISMATCH"
   197	  fi
   198	else
   199	  # client_contact path: recipient must not collide with ANOTHER candidate.
   200	  _collision=""
   201	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   202	    _collision="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   203	      --set=tenant="${CTX_TENANT_SLUG}" --set=cid="${D_CANDIDATE_ID}" --set=rcpt="${D_RECIPIENT}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || true
   204	BEGIN;
   205	SET LOCAL app.current_tenant = :'tenant';
   206	SELECT entity_id FROM entities
   207	WHERE entity_type='candidate' AND data->>'email' = :'rcpt' AND entity_id <> :'cid' LIMIT 1;
   208	COMMIT;
   209	SQL
   210	)"
   211	  fi
   212	  if [[ -n "${_collision}" ]]; then
   213	    _fail "G2: ADDRESSEE MISMATCH — client_contact recipient '${D_RECIPIENT}' is candidate ${_collision}'s email"
   214	    ESC_CLASS="ESC_ADDRESSEE_MISMATCH"
   215	  else
   216	    _ok "G2: client_contact recipient does not collide with any candidate address"
   217	  fi
   218	fi
   219	
   220	# ────────────────────────────────────────────────────────────────────────

 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Concierge agent — cycle.sh (15-step orchestration; W10-13 LIVE)
     3	#
     4	# Status: BUILT (W10-13 build slice; spec-004 §4 — every step, marker, ESC route).
     5	# Reading order: agent.md §1 (output contract) + §3 (12 lifecycle events) +
     6	#         §4 (this workflow's 15 steps) + §5 (Gate A) + §6 (ESC codes) first.
     7	#
     8	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
     9	# produces output OR takes action MUST call hh_decision_* from
    10	# agents/_shared/hook-helpers.sh.
    11	#
    12	# Invocation modes (per agent.md §2):
    13	#   mode=webhook         — Bullhorn lifecycle webhook event-driven (v1.0 primary)
    14	#   mode=poll            — Bullhorn state-changed-at polling fallback
    15	#   mode=nurture-sweep   — cron: 7d/30d/90d post-start nurture cadence
    16	#   mode=manual          — ifosctl concierge process-event|nurture-sweep
    17	#
    18	# v1.0 throughput note: ONE lifecycle event per run. webhook mode is per-event
    19	# by nature; poll/nurture take the FIRST pending event and report queue depth —
    20	# the 5-min poll cadence drains the rest (documented v1.0 scope).
    21	#
    22	# Bullhorn boundary: ALL Bullhorn calls route through bin/bh-bridge.sh — the
    23	# Janitor branch owns packages/mcp-connectors/bullhorn this cycle; the shim
    24	# documents the exact connector CLI surface and is the single reconciliation
    25	# point at review. Fixture mode serves the seeded `entities` cache rows.
    26	#
    27	# Autosend bridge (HEADLINE — D1-B): @ifos/autosend-bridge-telegram production
    28	# wiring (real Telegram Bot API transport + postgres approvals reader +
    29	# dist/bin/{propose,await,record-decision}.js) landed in THIS build slice.
    30	# Step 11 routes orange approvals through it when the dist + operator chat +
    31	# bot token (or IFOS_BRIDGE_FAKE fixture mode) are available; otherwise
    32	# drafts-only graceful degradation (D1-C).
    33	#
    34	# Honest-scope (spec-004 §8, verified 2026-06-10): Bullhorn creds EMPTY →
    35	# Steps 3/13/14 run fixture-mode against entities; MS Graph / Gmail OAuth
    36	# ABSENT → Step 12 live transport gated (IFOS_FORCE_SEND_RESULT proves the
    37	# chain in fixtures); TELEGRAM_BOT_TOKEN EMPTY → live Telegram unexercised.
    38	
    39	set -euo pipefail
    40	
    41	# ────────────────────────────────────────────────────────────────────────
    42	# Pre-flight: CTX env + _shared/ helper resolution
    43	# (Mirrors the 4-candidate fallback chain established in d7d52c5 smoke-hotfix.)
    44	# ────────────────────────────────────────────────────────────────────────
    45	
    46	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    47	  printf 'concierge/cycle.sh: CTX_AGENT_DIR unset (context.sh must run first)\n' >&2
    48	  exit 2
    49	fi
    50	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    51	  printf 'concierge/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
    52	  exit 2
    53	fi
    54	: "${CTX_AGENT_NAME:=concierge}"
    55	export CTX_AGENT_NAME CTX_AGENT_DIR CTX_TENANT_SLUG   # inherited by validate.sh subprocess (Step 8)
    56	
    57	_SHARED_DIR=""
    58	for _candidate in \
    59	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    60	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    61	  "${CTX_AGENT_DIR}/../../_shared" \
    62	  "${CTX_AGENT_DIR}/../_shared" ; do
    63	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    64	    _SHARED_DIR="${_candidate}"
    65	    break
    66	  fi
    67	done
    68	if [[ -z "${_SHARED_DIR}" ]]; then
    69	  printf 'concierge/cycle.sh: cannot locate _shared/ helpers\n' >&2
    70	  exit 1
    71	fi
    72	# shellcheck source=/dev/null
    73	source "${_SHARED_DIR}/hook-helpers.sh"
    74	
    75	# Secrets into env for the bridge CLIs + LLM renderer (CC Step 1 idiom; the
    76	# file is sourced, never cat'd; values never echoed).
    77	_CG_SECRETS="${IFOS_SECRETS_FILE:-${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env}"
    78	if [[ -f "${_CG_SECRETS}" ]]; then
    79	  set -a
    80	  # shellcheck source=/dev/null
   180	# Step 0 — Session start
   181	# Reference: agent.md §4 Step 0. context.sh runs first (bus invokes
   182	# context.sh BEFORE cycle.sh per ADR-003 v2 bundle pattern); this script
   183	# emits the trigger row that anchors the session in decision_log.
   184	# ────────────────────────────────────────────────────────────────────────
   185	
   186	if _step_on 0; then
   187	  hh_decision_trigger "session_start" "mode:${MODE}; agent:concierge"
   188	fi
   189	
   190	# ────────────────────────────────────────────────────────────────────────
   191	# Step 1 — Source detection (mode-dependent) → 12-event taxonomy
   192	# Reference: agent.md §4 Step 1. webhook parses CTX_WEBHOOK_PAYLOAD (JSON);
   193	# poll asks bh-bridge list-state-changes since tenant_adapters.config.
   194	# concierge_last_poll; nurture-sweep asks bh-bridge list-nurture-due.
   195	# ESC_LIFECYCLE_STATE_UNKNOWN (warn) + skip if event ∉ 12-event taxonomy.
   196	# ────────────────────────────────────────────────────────────────────────
   197	
   198	# The 12-event taxonomy (agent.md §3).
   199	_CG_TAXONOMY=" application-received interview-booked interview-completed offer-extended offer-accepted rejection withdrawal on-hold start-date-confirmed 7-day-check-in 30-day-check-in 90-day-check-in "
   200	
   201	EVENT_JSON="{}"
   202	QUEUE_DEPTH=0
   203	if _step_on 1; then
   204	  case "${MODE}" in
   205	    webhook|manual)
   206	      EVENT_JSON="${CTX_WEBHOOK_PAYLOAD:-{\}}"
   207	      ;;
   208	    poll)
   209	      _since="$(psql "${IFOS_DB_URL:-}" -tAq -v ON_ERROR_STOP=1 --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || true
   210	BEGIN;
   211	SET LOCAL app.current_tenant = :'tenant';
   212	SELECT coalesce(config->>'concierge_last_poll','') FROM tenant_adapters WHERE tenant_slug = :'tenant' LIMIT 1;
   213	COMMIT;
   214	SQL
   215	)"
   216	      [[ -z "${_since}" ]] && _since="$(date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)"
   217	      _events="$(bash "${_BH_BRIDGE}" list-state-changes --since "${_since}" 2>/dev/null || echo '[]')"
   218	      QUEUE_DEPTH="$(printf '%s' "${_events}" | jq 'length' 2>/dev/null || echo 0)"
   219	      EVENT_JSON="$(printf '%s' "${_events}" | jq -c '.[0] // {}' 2>/dev/null || echo '{}')"
   220	      ;;
   221	    nurture-sweep)
   222	      _events="$(bash "${_BH_BRIDGE}" list-nurture-due 2>/dev/null || echo '[]')"
   223	      QUEUE_DEPTH="$(printf '%s' "${_events}" | jq 'length' 2>/dev/null || echo 0)"
   224	      EVENT_JSON="$(printf '%s' "${_events}" | jq -c '.[0] // {}' 2>/dev/null || echo '{}')"
   225	      ;;
   226	    *)
   227	      printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
   228	  esac
   229	
   230	  EVENT_TYPE="$(printf '%s' "${EVENT_JSON}" | jq -r '.event_type // ""' 2>/dev/null || true)"
   231	  CANDIDATE_ID="$(printf '%s' "${EVENT_JSON}" | jq -r '.candidate_id // ""' 2>/dev/null || true)"
   232	  PLACEMENT_ID="$(printf '%s' "${EVENT_JSON}" | jq -r '.placement_id // ""' 2>/dev/null || true)"
   233	  CONTACT_ID="$(printf '%s' "${EVENT_JSON}" | jq -r '.contact_id // ""' 2>/dev/null || true)"
   234	  CLIENT_ID="$(printf '%s' "${EVENT_JSON}" | jq -r '.client_id // ""' 2>/dev/null || true)"
   235	  STATE_FROM="$(printf '%s' "${EVENT_JSON}" | jq -r '.state_from // ""' 2>/dev/null || true)"
   236	  STATE_TO="$(printf '%s' "${EVENT_JSON}" | jq -r '.state_to // ""' 2>/dev/null || true)"
   237	  EVENT_TS="$(printf '%s' "${EVENT_JSON}" | jq -r '.event_timestamp_iso // ""' 2>/dev/null || true)"
   238	
   239	  if [[ -z "${EVENT_TYPE}" || -z "${CANDIDATE_ID}" ]]; then
   240	    hh_decision_output "lifecycle_event_detected" "mode:${MODE}" \
   241	      "no_pending_event; queue_depth:${QUEUE_DEPTH}"
   242	    _close_run "no_event"
   243	  fi
   244	
   245	  if [[ "${_CG_TAXONOMY}" != *" ${EVENT_TYPE} "* ]]; then
   246	    autosend_escalate "ESC_LIFECYCLE_STATE_UNKNOWN" "agent=concierge" \
   247	      "tenant=${CTX_TENANT_SLUG}" "event_type=${EVENT_TYPE}" \
   248	      "state_from=${STATE_FROM}" "state_to=${STATE_TO}"
   249	    hh_decision_output "lifecycle_event_detected" "candidate:${CANDIDATE_ID}" \
   250	      "event_type:${EVENT_TYPE}; UNKNOWN — not in 12-event taxonomy; skipped"
   251	    _close_run "lifecycle_state_unknown"
   252	  fi
   253	
   254	  hh_decision_output "lifecycle_event_detected" "candidate:${CANDIDATE_ID}" \
   255	    "event_type:${EVENT_TYPE}; ${STATE_FROM}→${STATE_TO}; mode:${MODE}; queue_depth:${QUEUE_DEPTH}"
   256	fi
   257	: "${EVENT_TYPE:=}" "${CANDIDATE_ID:=}" "${PLACEMENT_ID:=}" "${CONTACT_ID:=}"
   258	: "${CLIENT_ID:=}" "${STATE_FROM:=}" "${STATE_TO:=}" "${EVENT_TS:=}"
   259	
   260	# ────────────────────────────────────────────────────────────────────────
   261	# Step 2 — Anti-duplicate guard (decision_log ledger; 24h window)
   262	# Reference: agent.md §4 Step 2 + Q7 disposition; CC Step 6 idempotency
   263	# ledger idiom. action_type/target live in payload jsonb (hook-helpers
   264	# autosend_emit_decision_log shape), not top-level columns.
   265	#   found + completed send → SKIP (true duplicate)
   266	#   found + no send       → ALLOW the new attempt (per Q7)
   267	# ────────────────────────────────────────────────────────────────────────
   268	
   269	if _step_on 2; then
   270	  _dup_status="fresh"
   271	  _dup_sent="false"
   272	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   273	    _dup_row="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   274	      --set=tenant="${CTX_TENANT_SLUG}" \
   275	      --set=tgt="candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
   276	      --set=ctgt="candidate:${CANDIDATE_ID}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || true
   277	BEGIN;
   278	SET LOCAL app.current_tenant = :'tenant';
   279	SELECT
   280	  (SELECT count(*) FROM decision_log
   281	   WHERE agent_name='concierge'
   282	     AND payload->>'action_type'='concierge_email_draft'
   283	     AND payload->>'target' = :'tgt'
   284	     AND phase IN ('action','gating_failed')
   285	     AND created_at > now() - interval '24 hours') || '|' ||
   286	  (SELECT count(*) FROM decision_log
   287	   WHERE agent_name='concierge'
   288	     AND payload->>'action_type'='gmail_outlook_send_to_candidate'
   289	     AND payload->>'target' = :'ctgt'
   290	     AND phase='action'
   291	     AND created_at > now() - interval '24 hours');
   292	COMMIT;
   293	SQL
   294	)"
   295	    IFS='|' read -r _dup_drafts _dup_sends <<<"${_dup_row:-0|0}"
   296	    if [[ "${_dup_drafts:-0}" -gt 0 ]]; then
   297	      _dup_status="found"
   298	      [[ "${_dup_sends:-0}" -gt 0 ]] && _dup_sent="true"
   299	    fi
   300	  fi
   301	  hh_decision_output "anti_duplicate_check" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
   302	    "duplicate_status:${_dup_status}; prior_send_completed:${_dup_sent}"
   303	  if [[ "${_dup_status}" == "found" && "${_dup_sent}" == "true" ]]; then
   304	    _close_run "true_duplicate_skip"
   305	  fi
   306	fi
   307	
   308	# ────────────────────────────────────────────────────────────────────────
   309	# Step 3 — Bullhorn context fetch (candidate/placement/client/contact)
   310	# Reference: agent.md §4 Step 3, via bin/bh-bridge.sh. ESC_AGENT_OUTPUT_SHAPE
   311	# if critical fields missing (no email/name). ESC_RATE_LIMIT_HIT /
   312	# ESC_BULLHORN_AUTH fire on live-connector failures (live branch only).
   313	# ────────────────────────────────────────────────────────────────────────
   314	
   315	CAND_JSON="{}" PLAC_JSON="{}" CLIENT_JSON="{}" CONTACT_JSON="{}"
   316	CAND_NAME="" CAND_EMAIL=""
   317	if _step_on 3; then
   318	  CAND_JSON="$(bash "${_BH_BRIDGE}" get-candidate --id "${CANDIDATE_ID}" 2>/dev/null || echo '{}')"
   319	  [[ -n "${PLACEMENT_ID}" ]] && PLAC_JSON="$(bash "${_BH_BRIDGE}" get-placement --id "${PLACEMENT_ID}" 2>/dev/null || echo '{}')"
   320	  [[ -n "${CLIENT_ID}" ]] && CLIENT_JSON="$(bash "${_BH_BRIDGE}" get-client --id "${CLIENT_ID}" 2>/dev/null || echo '{}')"
   321	  [[ -n "${CONTACT_ID}" ]] && CONTACT_JSON="$(bash "${_BH_BRIDGE}" get-contact --id "${CONTACT_ID}" 2>/dev/null || echo '{}')"
   322	
   323	  CAND_NAME="$(printf '%s' "${CAND_JSON}" | jq -r '.name // ""' 2>/dev/null || true)"
   324	  CAND_EMAIL="$(printf '%s' "${CAND_JSON}" | jq -r '.email // ""' 2>/dev/null || true)"
   325	  _fields_present=0
   326	  for _f in "${CAND_NAME}" "${CAND_EMAIL}" \
   327	            "$(printf '%s' "${PLAC_JSON}" | jq -r '.role // ""' 2>/dev/null)" \
   328	            "$(printf '%s' "${CLIENT_JSON}" | jq -r '.company // ""' 2>/dev/null)" \
   329	            "$(printf '%s' "${CONTACT_JSON}" | jq -r '.email // ""' 2>/dev/null)"; do
   330	    [[ -n "${_f}" ]] && _fields_present=$((_fields_present + 1))
   331	  done
   332	  hh_decision_output "bullhorn_context_fetched" "candidate:${CANDIDATE_ID}" \
   333	    "fields_present:${_fields_present}"
   334	
   335	  if [[ -z "${CAND_NAME}" || -z "${CAND_EMAIL}" ]]; then
   336	    # Cannot produce the declared output shape without a resolvable candidate.
   337	    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=concierge" \
   338	      "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" \
   339	      "missing=$([[ -z "${CAND_NAME}" ]] && printf name)$([[ -z "${CAND_EMAIL}" ]] && printf ' email')"
   340	    hh_decision_action "validate_gate_a_fail" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
   341	      "ctx-missing-${CANDIDATE_ID}" "ESC_AGENT_OUTPUT_SHAPE; missing_critical_context" || true
   342	    exit 1
   343	  fi
   344	fi
   345	
   346	# ────────────────────────────────────────────────────────────────────────
   347	# Step 4 — Addressee resolution (Gate A CRITICAL)
   348	# Reference: agent.md §4 Step 4 + ULTRAPLAN A6 line 566 verbatim "correct
   349	# addressee resolution; no candidates emailed under another's name".
   350	# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on mismatch.
   351	# IFOS_FORCE_RECIPIENT_EMAIL lets adversarial fixtures inject a wrong
   352	# recipient to prove the gate.
   353	# ────────────────────────────────────────────────────────────────────────
   354	
   355	RECIPIENT="" RECIPIENT_ROLE="candidate"
   356	if _step_on 4; then
   357	  RECIPIENT="${IFOS_FORCE_RECIPIENT_EMAIL:-${CAND_EMAIL}}"
   358	  if [[ "${RECIPIENT}" != "${CAND_EMAIL}" ]]; then
   359	    autosend_escalate "ESC_ADDRESSEE_MISMATCH" "agent=concierge" \
   360	      "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" \

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml | sed -n '65,125p;235,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
    65	# §1 — tenant_adapters.config additions (5 new top-level keys)
    66	# ============================================================================
    67	#
    68	# Each key is hard-fail-on-unknown via the validate_tenant_adapters_config_v0_4
    69	# trigger (replaces v0_3 trigger; preserves all 11 v0.1+v0.2+v0.3 allowlist
    70	# entries + adds these 5). Total v0.4 allowlist: 16 keys.
    71	
    72	tenant_adapters_config_additions:
    73	
    74	  operator_telegram_chat_id:
    75	    type: string
    76	    pattern: '^-?[0-9]+$'  # Telegram chat IDs are signed 64-bit integers as strings
    77	    required: false
    78	    set_by: [tenant-admin]
    79	    read_by: [concierge, cash-conductor]
    80	    notes: |
    81	      Per-tenant Telegram chat ID for the operator who approves orange-tier
    82	      autosends per D1-B (docs/decisions/2026-05-31-d1-founder-decision.md).
    83	      Consumed by @ifos/autosend-bridge-telegram via the consumer's
    84	      context.sh: SELECT config->>'operator_telegram_chat_id' FROM
    85	      tenant_adapters WHERE tenant_slug=$1.
    86	
    87	      Path A (reuse approval_routing.default_recipient) and Path B (this
    88	      top-level key) are BOTH schema-clean post-v0.4. The recommended
    89	      production path is Path A for new tenants (one JSONB sub-tree per
    90	      autosend-relevant config, cleaner upgrade story to v1.1+ rich-panel
    91	      approvals); Path B exists for tenants who want a simpler single-key
    92	      override + clarity in the wizard. Until a tenant explicitly sets
    93	      either, the env-var fallback IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID
    94	      remains supported for local dev / fixtures.
    95	
    96	      Telegram chat IDs are integers but presented as strings here to avoid
    97	      JSON number-precision issues across the consumer stack (Bash + jq +
    98	      Postgres JSONB). Pattern accepts both positive (user chat) and
    99	      negative (group chat) IDs.
   100	
   101	  email_channel:
   102	    type: string
   103	    enum: [microsoft-graph, gmail]
   104	    required: false
   105	    default: microsoft-graph
   106	    set_by: [tenant-admin]
   107	    read_by: [concierge]
   108	    notes: |
   109	      Per-tenant outbound email provider selection. Concierge cycle.sh
   110	      Step 3 reads to route email_provider OAuth refresh + send calls.
   111	      Default 'microsoft-graph' matches the UK recruitment-agency norm
   112	      per W3 vendor survey; tenants with a Workspace-only IT estate select
   113	      'gmail' at onboarding wizard.
   114	
   115	      Currently consumed via IFOS_FORCE_EMAIL_CHANNEL env-var fallback in
   116	      concierge/context.sh line 92; v0.4 enables the canonical
   117	      tenant_adapters read path. The TODO(W10-13) marker in context.sh
   118	      flips from "supplement-pending" to "supplement-landed; canonical
   119	      source is the SELECT, env-var fallback remains for fixtures".
   120	
   121	      v1.1+ scope: add 'gsuite-modern' + 'exchange-on-prem' as the on-prem
   122	      tenants surface. v1.0 supports only the two cloud-OAuth providers.
   123	
   124	  workos_org_id:
   125	    type: string
   235	
   236	  pre_conditions:
   237	    - v0.3 migration applied (validate_tenant_adapters_config_v0_3 trigger active)
   238	    - cash_conductor_transactions + cash_conductor_invoices tables exist
   239	    - RLS + ifos_app grants from Day-4 §6.3 in place
   240	    - migration-test tenant row exists in tenants table
   241	
   242	  steps:
   243	    1: |
   244	      Verify v0.3 prerequisites (DO block in migration §1).
   245	    2: |
   246	      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_4() —
   247	      preserves all 11 v0.1+v0.2+v0.3 allowlist entries + adds 5 v0.4 entries
   248	      (operator_telegram_chat_id, email_channel, workos_org_id,
   249	      granola_workspace_id, bullhorn_corporation_id). Per-key type validation
   250	      for each new entry. Total v0.4 allowlist: 16 keys.
   251	    3: |
   252	      DROP TRIGGER validate_tenant_adapters_config_v0_3 ON tenant_adapters;
   253	      CREATE TRIGGER validate_tenant_adapters_config_v0_4 (re-bind).
   254	    4: |
   255	      DROP FUNCTION validate_tenant_adapters_config_v0_3() (no longer
   256	      referenced; v0_4 function supersedes it cleanly).
   257	    5: |
   258	      Smoke verification DO block confirms the v0_4 trigger is bound +
   259	      v0_3 function is gone (migration §5).
   260	    6: |

exec
/bin/zsh -lc "find agents/recruitment/concierge/fixtures -maxdepth 1 -type f -name '*.yaml' -print | sort | nl -ba" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
     1	agents/recruitment/concierge/fixtures/01-primary.yaml
     2	agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml
     3	agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml

exec
/bin/zsh -lc 'rg -n "decision_log|CREATE TABLE.*decision_log|action_type|target" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.*.yaml docs/verticals/recruitment/migrations/*.sql agents/_shared/hook-helpers.sh -S' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:208:      action_type:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:213:      target_entity_type:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:219:      target_entity_id:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:343:    target: tone_rule
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:352:    target: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:23:--   - RLS policies on entities + entity_links + decision_log already in place
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:145:  action_type            TEXT        NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:146:  target_entity_type     TEXT,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:147:  target_entity_id       TEXT,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:161:CREATE INDEX IF NOT EXISTS recent_edit_tenant_action_idx ON recent_edit (tenant_slug, action_type, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:17:--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:290:    IF d ? 'next_action_target_date' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:291:      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:292:        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:295:      IF d->>'next_action_target_date' IS NOT NULL THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:297:          PERFORM (d->>'next_action_target_date')::date;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:299:          RAISE EXCEPTION 'next_action_target_date must parse as ISO-8601 date (YYYY-MM-DD); got: %', d->>'next_action_target_date';
docs/verticals/recruitment/vertical-schema.yaml:5:#   - entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:402:      start_date_target:
docs/verticals/recruitment/vertical-schema.yaml:577:#   - source → target entity_types
docs/verticals/recruitment/vertical-schema.yaml:578:#   - cardinality: 1:1 | 1:N (one source, many targets) | M:N
docs/verticals/recruitment/vertical-schema.yaml:587:    target: placement
docs/verticals/recruitment/vertical-schema.yaml:596:    target: brief
docs/verticals/recruitment/vertical-schema.yaml:603:    target: client
docs/verticals/recruitment/vertical-schema.yaml:610:    target: contact
docs/verticals/recruitment/vertical-schema.yaml:620:    target: client
docs/verticals/recruitment/vertical-schema.yaml:627:    target: contact
docs/verticals/recruitment/vertical-schema.yaml:634:    target: contact
docs/verticals/recruitment/vertical-schema.yaml:641:    target: brief
docs/verticals/recruitment/vertical-schema.yaml:649:    target: candidate
docs/verticals/recruitment/vertical-schema.yaml:656:    target: placement
docs/verticals/recruitment/vertical-schema.yaml:715:    client: R        # target-firm context
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/vertical-schema.yaml:893:    target: Week-4-end (~2026-06-21 if Week 1 starts 2026-05-21 per Day-5 kill criterion §2 Trigger 1 calendar).
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:11:# the decision_log payload shape — those are all preserved verbatim from
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:43:  no decision_log payload changes. This keeps the supplement reviewable and
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:205:    linkedin_url, preferred_channel, next_action_target_date, must_haves,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:223:  decision_log_payload: |
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:226:    decision_log schema (consistent with v0.3 §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:18:# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:120:      next_action_target_date:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:284:#   - Scribe Contact: none → R+W (writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:287:#     ONLY; existing salary_min/max + start_date_target remain Bullhorn-sourced,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:359:  #   agent + which fields were touched in decision_log payload; reviewers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:369:  # decision_log row records who wrote. Entity-level RLS enforces TENANT
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:431:    # in the Sourcing Scout shortlist artefact (vault markdown + decision_log
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:489:      - Scribe (R+W)       # v0.3 UPGRADED — writes preferred_channel + next_action_target_date
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:495:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:507:      salary_min/max + start_date_target remain Bullhorn-sourced, R-only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:833:      send refusal (autosend-safety-policy §5 red-tier action_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:861:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:864:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:865:  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1029:      next_action_target_date, must_haves, nice_to_haves, deal_breakers,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1036:      start_date_target; opportunity.sector — not yet in schema). These
docs/verticals/recruitment/migrations/v0.4-to-v0.5.sql:28:--   - decision_log payload shape: unchanged
docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql:25:--   - decision_log payload shape: unchanged
agents/_shared/hook-helpers.sh:10:# Live-mode writes:        Postgres decision_log via psql + IFOS_DB_URL
agents/_shared/hook-helpers.sh:19:# Side-effects: appends to decision_log table OR fallback JSONL; never reads
agents/_shared/hook-helpers.sh:129:# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
agents/_shared/hook-helpers.sh:148:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
agents/_shared/hook-helpers.sh:216:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:220:  local action_type="$1"
agents/_shared/hook-helpers.sh:221:  local target="$2"
agents/_shared/hook-helpers.sh:228:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
agents/_shared/hook-helpers.sh:229:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:230:      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
agents/_shared/hook-helpers.sh:231:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:232:      "${target}" "${payload_hash}" "unknown_action_type"
agents/_shared/hook-helpers.sh:236:  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
agents/_shared/hook-helpers.sh:237:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:238:      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
agents/_shared/hook-helpers.sh:239:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:240:      "${target}" "${payload_hash}" "override_resolution_failed"
agents/_shared/hook-helpers.sh:246:      autosend_emit_decision_log "action" "green" "${action_type}" \
agents/_shared/hook-helpers.sh:247:        "${target}" "${payload_hash}" "${payload_preview}" ""
agents/_shared/hook-helpers.sh:251:      autosend_emit_decision_log "action" "yellow" "${action_type}" \
agents/_shared/hook-helpers.sh:252:        "${target}" "${payload_hash}" "${payload_preview}" ""
agents/_shared/hook-helpers.sh:253:      if autosend_should_sample "${action_type}" "${tenant}"; then
agents/_shared/hook-helpers.sh:254:        autosend_spot_check_enqueue "${action_type}" "${target}" \
agents/_shared/hook-helpers.sh:260:      autosend_emit_decision_log "action" "orange" "${action_type}" \
agents/_shared/hook-helpers.sh:261:        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
agents/_shared/hook-helpers.sh:262:      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:263:        "${target}" "${payload_hash}" "${payload_preview}"
agents/_shared/hook-helpers.sh:264:      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
agents/_shared/hook-helpers.sh:268:      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
agents/_shared/hook-helpers.sh:269:        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
agents/_shared/hook-helpers.sh:270:      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
agents/_shared/hook-helpers.sh:271:        "${target}" "${payload_hash}" "red_tier_classification"
agents/_shared/hook-helpers.sh:275:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:276:        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
agents/_shared/hook-helpers.sh:277:      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:278:        "${target}" "${payload_hash}" "unknown_tier:${tier}"
agents/_shared/hook-helpers.sh:288:# autosend_policy_lookup <action_type>
agents/_shared/hook-helpers.sh:290:# 1 if action_type missing from policy file.
agents/_shared/hook-helpers.sh:292:  local action_type="$1"
agents/_shared/hook-helpers.sh:297:  # YAML lookup via awk — finds the action_type key, then reads tier:
agents/_shared/hook-helpers.sh:300:  tier=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:311:# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:317:  local action_type="$2"
agents/_shared/hook-helpers.sh:333:  override=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:349:      "${base_tier}" "${override}" "${tenant_slug}" "${action_type}" >&2
agents/_shared/hook-helpers.sh:355:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:356:# Emits the standard autosend decision_log row with payload.tier set.
agents/_shared/hook-helpers.sh:357:autosend_emit_decision_log() {
agents/_shared/hook-helpers.sh:360:  local action_type="$3"
agents/_shared/hook-helpers.sh:361:  local target="$4"
agents/_shared/hook-helpers.sh:367:  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
agents/_shared/hook-helpers.sh:369:    "$(_hh_json_escape "${action_type}")" \
agents/_shared/hook-helpers.sh:370:    "$(_hh_json_escape "${target}")" \
agents/_shared/hook-helpers.sh:416:# autosend_should_sample <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:421:  local action_type="$1"
agents/_shared/hook-helpers.sh:424:  rate=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:442:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
agents/_shared/hook-helpers.sh:446:  local action_type="$1"
agents/_shared/hook-helpers.sh:447:  local target="$2"
agents/_shared/hook-helpers.sh:460:  local outfile="${spot_dir}/${timestamp}-${action_type}-${payload_hash:0:12}.md"
agents/_shared/hook-helpers.sh:467:    printf '# Spot check — %s\n\n' "${action_type}"
agents/_shared/hook-helpers.sh:470:    printf -- '- **Target:** %s\n' "${target}"
agents/_shared/hook-helpers.sh:477:# autosend_await_approval <action_type> <target> <payload_hash>
agents/_shared/hook-helpers.sh:484:  local action_type="$1"
agents/_shared/hook-helpers.sh:485:  local target="$2"
agents/_shared/hook-helpers.sh:489:  timeout_iso=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:514:    printf 'action_type=%s\n' "${action_type}"
agents/_shared/hook-helpers.sh:515:    printf 'target=%s\n' "${target}"
agents/_shared/hook-helpers.sh:537:        autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:538:          "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"
agents/_shared/hook-helpers.sh:565:  autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:566:    "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
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
    31	
    32	# Resolve the autosend-policy + escalation-codes paths through a fallback
    33	# chain (rendered → repo source-tree → computed relatives). Mirrors the
    34	# pattern used in agents/*/context.sh + validate.sh. Without this, direct
    35	# source-tree execution (Day-13 + Day-25 Hays smoke) prints "policy file
    36	# not found" warnings even though Gate A passes via deterministic fallback.
    37	_hh_resolve_shared_path() {
    38	  local filename="$1" override_val="$2" candidate
    39	  if [[ -n "${override_val}" ]]; then
    40	    printf '%s' "${override_val}"
    41	    return 0
    42	  fi
    43	  for candidate in \
    44	    "${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/${filename}" \
    45	    "${IFOS_REPO_ROOT:-}/agents/_shared/${filename}" \
    46	    "${CTX_AGENT_DIR:-.}/../../_shared/${filename}" \
    47	    "${CTX_AGENT_DIR:-.}/../_shared/${filename}" ; do
    48	    if [[ -n "${candidate}" && -f "${candidate}" ]]; then
    49	      printf '%s' "${candidate}"
    50	      return 0
    51	    fi
    52	  done
    53	  # Nothing resolved — fall back to legacy default so downstream consumers
    54	  # fail loudly at use-time with a clear path in the error message.
    55	  printf '%s' "${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/${filename}"
    56	}
    57	
    58	_HH_POLICY_FILE="$(_hh_resolve_shared_path "autosend-policy.yaml" "${HH_POLICY_FILE:-}")"
    59	_HH_ESC_CATALOGUE="$(_hh_resolve_shared_path "escalation-codes.md" "${HH_ESC_CATALOGUE:-}")"
    60	
    61	# Fallback file used when IFOS_DB_URL is unset OR psql is unavailable.
    62	# Resolved at first call to _hh_emit_row().
    63	_hh_resolve_fallback_path() {
    64	  if [[ -n "${IFOS_DECISION_LOG_FALLBACK:-}" ]]; then
    65	    printf '%s' "${IFOS_DECISION_LOG_FALLBACK}"
    66	    return 0
    67	  fi
    68	  local tenant="${CTX_TENANT_SLUG:-unknown}"
    69	  local vault_root="${IFOS_VAULT_ROOT:-/vault}"
    70	  printf '%s/%s/decision-log.jsonl' "${vault_root}" "${tenant}"
    71	}
    72	
    73	# JSON escape a single string for inclusion in a JSON value.
    74	# Use this when BUILDING a JSON document from plain text.
    75	_hh_json_escape() {
    76	  local input="$1"
    77	  input="${input//\\/\\\\}"
    78	  input="${input//\"/\\\"}"
    79	  input="${input//$'\n'/\\n}"
    80	  input="${input//$'\r'/\\r}"
    81	  input="${input//$'\t'/\\t}"
    82	  printf '%s' "${input}"
    83	}
    84	
    85	# SQL escape a string for inclusion in a single-quoted SQL string literal.
    86	# Use this when EMBEDDING values in psql SQL. Doubles single quotes;
    87	# leaves everything else (incl. backslashes, JSON internal " characters)
    88	# alone — Postgres standard_conforming_strings=on (default since 9.1)
    89	# treats backslash as literal.
    90	_hh_sql_escape() {
    91	  local input="$1"
    92	  printf '%s' "${input//\'/\'\'}"
    93	}
    94	
    95	# Current ISO-8601 UTC timestamp with millisecond precision where available.
    96	# GNU date supports %3N (3-digit nanoseconds → milliseconds). BSD date
    97	# (macOS default) does NOT error on the spec but outputs the literal
    98	# string "3N" instead, which Postgres rejects as invalid timestamptz.
    99	# Detect by checking that %3N produced exactly 3 digits.
   100	_hh_now_iso() {
   101	  local ms
   102	  ms=$(date -u +"%3N" 2>/dev/null)
   103	  if [[ "${ms}" =~ ^[0-9]{3}$ ]]; then
   104	    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
   105	  else
   106	    date -u +"%Y-%m-%dT%H:%M:%SZ"
   107	  fi
   108	}
   109	
   110	# Validate that ESC code exists in the catalogue.
   111	# Returns 0 if known, 1 otherwise. Catalogue absent → permissive (return 0).
   112	_hh_validate_esc_code() {
   113	  local code="$1"
   114	  if [[ ! -f "${_HH_ESC_CATALOGUE}" ]]; then
   115	    return 0
   116	  fi
   117	  if grep -Fq "\`${code}\`" "${_HH_ESC_CATALOGUE}"; then
   118	    return 0
   119	  fi
   120	  return 1
   121	}
   122	
   123	# ────────────────────────────────────────────────────────────────────────
   124	# Core decision-log writer
   125	# ────────────────────────────────────────────────────────────────────────
   126	
   127	# _hh_emit_row <phase> <outcome> <reason> <payload_json>
   128	#
   129	# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
   130	# INSERT via psql -v ON_ERROR_STOP=1. Offline mode: append JSON line to
   131	# fallback file. The two formats are reconcilable by the sync worker.
   132	_hh_emit_row() {
   133	  local phase="$1"
   134	  local outcome="${2:-}"
   135	  local reason="${3:-}"
   136	  local payload_json="${4:-{\}}"
   137	
   138	  local tenant agent created_at
   139	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   140	  agent="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   141	  created_at="$(_hh_now_iso)"
   142	
   143	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   144	    local sql
   145	    sql=$(cat <<EOF
   146	BEGIN;
   147	SET LOCAL app.current_tenant = '$(_hh_sql_escape "${tenant}")';
   148	INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
   149	VALUES (
   150	  '$(_hh_sql_escape "${tenant}")',
   151	  '$(_hh_sql_escape "${agent}")',
   152	  '$(_hh_sql_escape "${phase}")',
   153	  $([ -z "${outcome}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${outcome}")"),
   154	  $([ -z "${reason}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${reason}")"),
   155	  '$(_hh_sql_escape "${payload_json}")'::jsonb,
   156	  '${created_at}'::timestamptz
   157	);
   158	COMMIT;
   159	EOF
   160	)
   161	    local psql_err
   162	    if psql_err=$(printf '%s\n' "${sql}" | psql -v ON_ERROR_STOP=1 -q "${IFOS_DB_URL}" 2>&1); then
   163	      return 0
   164	    fi
   165	    # psql failed — fall through to fallback append + emit warning to stderr
   166	    printf 'hh_emit_row: psql write failed; appending to fallback\n' >&2
   167	    printf 'hh_emit_row: psql error: %s\n' "${psql_err}" >&2
   168	  fi
   169	
   170	  local fallback
   171	  fallback="$(_hh_resolve_fallback_path)"
   172	  mkdir -p "$(dirname "${fallback}")" 2>/dev/null || true
   173	
   174	  local row
   175	  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
   176	    "$(_hh_json_escape "${tenant}")" \
   177	    "$(_hh_json_escape "${agent}")" \
   178	    "$(_hh_json_escape "${phase}")" \
   179	    "$([ -z "${outcome}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${outcome}")")" \
   180	    "$([ -z "${reason}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason}")")" \
   181	    "${payload_json}" \
   182	    "${created_at}" \
   183	    "${_HH_HELPERS_VERSION}")
   184	
   185	  printf '%s\n' "${row}" >> "${fallback}"
   186	}
   187	
   188	# ────────────────────────────────────────────────────────────────────────
   189	# 3 hh_decision_* contracts (master brief §8.1 Change 2)
   190	# ────────────────────────────────────────────────────────────────────────
   191	
   192	# hh_decision_trigger <trigger_type> [<reason>]
   193	# Writes phase='trigger' row at session start. Required first call of every run.
   194	hh_decision_trigger() {
   195	  local trigger_type="${1:-session_start}"
   196	  local reason="${2:-}"
   197	  local payload
   198	  payload=$(printf '{"trigger_type":"%s","helpers_version":"%s"}' \
   199	    "$(_hh_json_escape "${trigger_type}")" "${_HH_HELPERS_VERSION}")
   200	  _hh_emit_row "trigger" "" "${reason}" "${payload}"
   201	}
   202	
   203	# hh_decision_output <output_type> <artefact_ref> [<reason>]
   204	# Writes phase='output' row per artefact produced. Required before producing
   205	# a customer-visible artefact (Gate B per master brief §1 Rule 4).
   206	hh_decision_output() {
   207	  local output_type="$1"
   208	  local artefact_ref="$2"
   209	  local reason="${3:-}"
   210	  local payload
   211	  payload=$(printf '{"output_type":"%s","artefact_ref":"%s"}' \
   212	    "$(_hh_json_escape "${output_type}")" "$(_hh_json_escape "${artefact_ref}")")
   213	  _hh_emit_row "output" "produced" "${reason}" "${payload}"
   214	}
   215	
   216	# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
   217	# Writes phase='action' or phase='gating_failed' row depending on tier.
   218	# Returns 0 if action allowed; 1 if blocked or approval rejected.
   219	hh_decision_action() {
   220	  local action_type="$1"

codex
REJECTED

1. §9 still treats D1 as unresolved even though the artefact says it is accepted elsewhere. Header line 4 and §10 state “Founder Decision D1 ACCEPTED 2026-05-31,” but §9 says “Awaits … D1 founder decision” and Q1 says D1 “ABSOLUTELY needs this resolved before build.” The cited D1 doc supersedes Concierge §9 Q1. Fix by removing Q1 and all “awaits D1” language, leaving only production wiring as a build-slice dependency.

2. The scaffold/runtime status is stale and materially false. The Reading-discipline note and §5 Honesty note say `cycle.sh`, `validate.sh`, and `context.sh` are skeleton/TODO files and that v0.4 must land first; the current sibling files identify themselves as W10-13 LIVE/BUILT, and v0.4 supplement defines `operator_telegram_chat_id` + `email_channel`. Fix by updating the artefact to the current production-ready bundle state or explicitly freezing it as an obsolete contract not eligible for ratification.

3. §4 Step 2 uses an invalid `decision_log` lookup shape. The query filters `action_type='concierge_email_draft'` and `target LIKE ...` as top-level columns, while §3 correctly says helper-emitted autosend metadata lives inside `payload`, and `hook-helpers.sh` writes only `tenant_slug, agent_name, phase, outcome, reason, payload, created_at`. Fix Step 2 to query `payload->>'action_type'` and `payload->>'target'`, matching the live helper contract.

4. §8 misclassifies already-landed schema work as a blocking prerequisite. The row “v0.4 schema supplement adding `operator_telegram_chat_id` + `email_channel` … ⏸” conflicts with `vertical-schema.v0.4-supplement.yaml`, which already declares both keys. Fix §8 and §10 to move v0.4 from pending blocker to satisfied dependency, with any remaining blocker limited to tenant population/production wiring.
tokens used
87,335
REJECTED

1. §9 still treats D1 as unresolved even though the artefact says it is accepted elsewhere. Header line 4 and §10 state “Founder Decision D1 ACCEPTED 2026-05-31,” but §9 says “Awaits … D1 founder decision” and Q1 says D1 “ABSOLUTELY needs this resolved before build.” The cited D1 doc supersedes Concierge §9 Q1. Fix by removing Q1 and all “awaits D1” language, leaving only production wiring as a build-slice dependency.

2. The scaffold/runtime status is stale and materially false. The Reading-discipline note and §5 Honesty note say `cycle.sh`, `validate.sh`, and `context.sh` are skeleton/TODO files and that v0.4 must land first; the current sibling files identify themselves as W10-13 LIVE/BUILT, and v0.4 supplement defines `operator_telegram_chat_id` + `email_channel`. Fix by updating the artefact to the current production-ready bundle state or explicitly freezing it as an obsolete contract not eligible for ratification.

3. §4 Step 2 uses an invalid `decision_log` lookup shape. The query filters `action_type='concierge_email_draft'` and `target LIKE ...` as top-level columns, while §3 correctly says helper-emitted autosend metadata lives inside `payload`, and `hook-helpers.sh` writes only `tenant_slug, agent_name, phase, outcome, reason, payload, created_at`. Fix Step 2 to query `payload->>'action_type'` and `payload->>'target'`, matching the live helper contract.

4. §8 misclassifies already-landed schema work as a blocking prerequisite. The row “v0.4 schema supplement adding `operator_telegram_chat_id` + `email_channel` … ⏸” conflicts with `vertical-schema.v0.4-supplement.yaml`, which already declares both keys. Fix §8 and §10 to move v0.4 from pending blocker to satisfied dependency, with any remaining blocker limited to tenant population/production wiring.
