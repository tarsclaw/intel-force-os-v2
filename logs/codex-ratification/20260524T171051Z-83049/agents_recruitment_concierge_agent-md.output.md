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
session id: 019e5af7-d315-76c2-a875-759e57cd0e79
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

**Status:** Proposed (Day-19 pre-W10-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice).
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier (`gmail_outlook_send_to_candidate` or `bullhorn_note_customer_visible` depending on channel per autosend-policy.yaml lines 122-149). Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is a Gate B leading metric (warning + aggregated; NOT a Gate A hard-fail) per the same ULTRAPLAN line — making it a hard-fail would block legitimate delayed drafts caused by Bullhorn polling fallbacks. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.

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

Bullhorn webhook coverage is patchy per ULTRAPLAN A6 line 570 gotcha — see Step 1 polling fallback.

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

One output per lifecycle event: an email draft (orange tier). 12 lifecycle events × per-tenant comms-template variants:

| # | Event | Comms type | Recipient | Tone |
|---|---|---|---|---|
| 1 | Application received | Acknowledgement | Candidate | Warm, professional, sets expectations on response timeline |
| 2 | Interview booked | Prep | Candidate | Practical (date, time, format, interviewers) + role context |
| 3 | Interview completed | Debrief | Candidate | Thank-you + next-step clarity OR "we'll be in touch by X" |
| 4 | Offer extended | Placement-positive | Candidate | Excited, clear on terms, addressee-resolution-critical |
| 5 | Offer accepted | Placement-confirm | Candidate + Client (separate drafts) | Reassurance + practical next steps |
| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 line 570 — respectful, specific, leaves door open |
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

Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).

The actual SEND is a separate orange-tier action_type:
- `gmail_outlook_send_to_candidate` (per autosend-policy.yaml line 130) when channel=email
- `bullhorn_note_customer_visible` (line 122) when channel=Bullhorn note with isExternal=true
- `twilio_sms_send` (line 137) when channel=SMS (v1.1+)
- `calendar_invite_send` (line 144) when event includes calendar attachment

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
   → query decision_log for prior `concierge_email_draft` row for same
     (candidate_id, payload.event_type) in last 24h with phase IN
     ('output', 'action') — if a prior draft was emitted AND either sent OR
     is still pending consultant action, the new event is a duplicate trigger
   → if found AND send-completed: skip (true duplicate)
   → if found BUT prior draft never sent (no `gmail_outlook_send_to_candidate`
     follow-up action row): allow the new draft attempt (per Q7 disposition)
   → hh_decision_output("anti_duplicate_check", "<entity_type>:<bullhorn_id>",
     "<duplicate_status>")

3. Bullhorn context fetch
   → bullhorn.get_candidate(candidate_id) → name, current state, comms history
   → bullhorn.get_placement(placement_id) → role, client, dates
   → bullhorn.get_client(client_id) → company name, primary contact
   → bullhorn.get_contact(contact_id) → name, email
   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
     ESC_BULLHORN_AUTH on auth fail
   → ESC_CANDIDATE_DATA_INCOMPLETE if critical fields missing (no email,
     no name) — draft cannot proceed
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
   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries

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
   → per ULTRAPLAN A6 line 566 verbatim "every lifecycle event has a draft
     generated within 30 minutes" — interpreted as a Gate B leading metric
     (90% of drafts within 30 min) rather than per-draft hard fail (legitimate
     polling-fallback delays would otherwise block drafts entirely)

10. PII boundary check
    → no PII from other candidates referenced in body
    → no PII from competitor clients referenced
    → no compensation specifics outside what's already in candidate's record
    → ESC_PII_LEAKAGE_RISK on hit (blocking)
    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
     "result:passed")

11. Autosend-bridge routing (D1 path)
    → per Founder Decision D1 (final selection at W10 design):
      D1-A (bridge to cortextOS approval system): POST internal API
      D1-B (lightweight Telegram shim): send approval prompt to operator
      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
    → per autosend-policy.yaml: orange-tier; consultant approves
    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within 24h (D1-A/B)

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
    → maintains audit trail in Bullhorn itself
    → hh_decision_output("bullhorn_activity_logged",
      "candidate:<bullhorn_id>", "event_type:<type>")

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
    → hh_decision_action("concierge_run_complete", session_id, run_mode)
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
- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_CANDIDATE_DATA_INCOMPLETE)

The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).

Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_CANDIDATE_DATA_INCOMPLETE` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint when voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.

**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.

### Gate B — Outcome thresholds (success metrics, not block)

Per ULTRAPLAN A6 line 567 verbatim: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts"**.

Two metrics:
- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%.
- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`.

Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).

---

## §6 — Escalation codes

Concierge uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
| `ESC_MS_GRAPH_AUTH` | Microsoft Graph OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin (token re-auth required) |
| `ESC_GMAIL_AUTH` | Gmail OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin |
| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
| `ESC_CANDIDATE_DATA_INCOMPLETE` | Missing email / name in Bullhorn entity | warn | operator_chat_id |
| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
| `ESC_VOICE_DRIFT` | Voice classifier below position-specific threshold after 3 retries | warn (position 1-2) or **blocking** (position 3) | operator_chat_id (1-2) / operator + ifos_oncall (position 3) |
| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | **blocking** | operator + ifos_oncall |
| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within 24h | warn | operator + tenant-admin |
| `ESC_SEND_FAIL` | Email provider 4xx/5xx | warn | operator_chat_id |
| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
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
  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 line 570; demand specificity)
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
- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 line 570 explicitly names rejection voice as the hardest case)

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
| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
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
- **Founder Decision D1 RESOLVED** (Q1 above) — without this, Concierge build cannot start
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
I’m going to verify the Concierge claims against the project sources rather than relying on the embedded citations, especially autosend policy, escalation codes, voice helpers, schema, and the master/ULTRAPLAN line anchors.
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Concierge — no candidate ghosted
     2	
     3	**Status:** Proposed (Day-19 pre-W10-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice).
     4	**Date:** 2026-05-24.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
     7	**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
     8	**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
     9	
    10	---
    11	
    12	## §1 — Output contract (one-paragraph screenshot)
    13	
    14	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    15	
    16	> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier (`gmail_outlook_send_to_candidate` or `bullhorn_note_customer_visible` depending on channel per autosend-policy.yaml lines 122-149). Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is a Gate B leading metric (warning + aggregated; NOT a Gate A hard-fail) per the same ULTRAPLAN line — making it a hard-fail would block legitimate delayed drafts caused by Bullhorn polling fallbacks. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
    17	
    18	---
    19	
    20	## §2 — Invocation surface
    21	
    22	### Lifecycle webhook (v1.0 primary)
    23	
    24	```http
    25	# Bullhorn placement state-change webhook → Concierge handler
    26	POST https://<tenant>.ifos.app/agents/concierge/webhook
    27	Authorization: Bearer <bullhorn-shared-secret>
    28	Content-Type: application/json
    29	
    30	{
    31	  "event_type": "placement.state_changed" | "candidate.state_changed",
    32	  "entity_id": "<bullhorn-id>",
    33	  "from_state": "interview_scheduled",
    34	  "to_state": "interview_completed",
    35	  "timestamp": "<ISO>"
    36	}
    37	```
    38	
    39	Bullhorn webhook coverage is patchy per ULTRAPLAN A6 line 570 gotcha — see Step 1 polling fallback.
    40	
    41	### Cron (polling fallback + time-elapsed nurture)
    42	
    43	```bash
    44	# Every 5 min: poll Bullhorn for missed state transitions
    45	*/5 * * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode poll
    46	# Daily 09:00 UTC: time-elapsed nurture sweeps (7d / 30d / 90d check-ins)
    47	0 9 * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode nurture-sweep
    48	```
    49	
    50	### Manual (debugging)
    51	
    52	```bash
    53	ifosctl concierge generate --tenant <slug> --candidate <id> --event <event-type>
    54	ifosctl concierge replay --tenant <slug> --webhook-id <id>
    55	```
    56	
    57	### v1.1+ surfaces (deferred)
    58	
    59	- agent-identity email adapter (deferred) integration (agent-identity sends for non-rejection comms)
    60	- Brain UI lifecycle-event timeline viewer per candidate
    61	- Per-tenant comms-type taxonomy customisation
    62	
    63	---
    64	
    65	## §3 — Output shape
    66	
    67	One output per lifecycle event: an email draft (orange tier). 12 lifecycle events × per-tenant comms-template variants:
    68	
    69	| # | Event | Comms type | Recipient | Tone |
    70	|---|---|---|---|---|
    71	| 1 | Application received | Acknowledgement | Candidate | Warm, professional, sets expectations on response timeline |
    72	| 2 | Interview booked | Prep | Candidate | Practical (date, time, format, interviewers) + role context |
    73	| 3 | Interview completed | Debrief | Candidate | Thank-you + next-step clarity OR "we'll be in touch by X" |
    74	| 4 | Offer extended | Placement-positive | Candidate | Excited, clear on terms, addressee-resolution-critical |
    75	| 5 | Offer accepted | Placement-confirm | Candidate + Client (separate drafts) | Reassurance + practical next steps |
    76	| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 line 570 — respectful, specific, leaves door open |
    77	| 7 | Withdrawn (candidate-initiated) | Acknowledgement | Candidate | Respectful, no pressure, leaves door open |
    78	| 8 | On-hold | Status-update | Candidate | Honest about timeline, sets expectations on next update |
    79	| 9 | Start date confirmed | Placement-pre-start | Candidate + Client | Practical (HR forms, IT setup, day-1 logistics) |
    80	| 10 | 7-day check-in (post-start) | Nurture-check-in | Candidate | "How's it going? Any blockers?" — short, low-pressure |
    81	| 11 | 30-day check-in | Nurture-check-in | Candidate + Client | Slightly longer; both sides; reads for placement-risk signals |
    82	| 12 | 90-day check-in | Nurture-check-in + relationship | Candidate + Client | Establishes ongoing relationship; offers "is there anyone in your network looking?" |
    83	
    84	Draft structure per event:
    85	
    86	```yaml
    87	draft_id: <uuid>
    88	event_type: <one of 12 above>
    89	candidate_id: <bullhorn-id>
    90	placement_id: <bullhorn-id or null>
    91	recipient: <candidate-email | client-contact-email>
    92	recipient_role: candidate | client_contact
    93	subject: <subject line; voice-classified>
    94	body_markdown: <body; voice-classified>
    95	voice_score: <0-1>
    96	addressee_resolution_check: passed | failed
    97	attached_documents: <list — e.g., feedback summary, prep guide, comms history>
    98	escalation_position: 1-3 (for sensitive sends like rejection)
    99	expected_send_window: <ISO; respects sending-hours per tenant config>
   100	```
   101	
   102	Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
   103	
   104	The actual SEND is a separate orange-tier action_type:
   105	- `gmail_outlook_send_to_candidate` (per autosend-policy.yaml line 130) when channel=email
   106	- `bullhorn_note_customer_visible` (line 122) when channel=Bullhorn note with isExternal=true
   107	- `twilio_sms_send` (line 137) when channel=SMS (v1.1+)
   108	- `calendar_invite_send` (line 144) when event includes calendar attachment
   109	
   110	Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
   111	
   112	---
   113	
   114	## §4 — Workflow
   115	
   116	15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   117	
   118	```
   119	0. Session start (webhook OR poll OR cron)
   120	   → context.sh hydrates: tenant config + Bullhorn auth refresh +
   121	     Microsoft Graph / Gmail auth + agent-identity email adapter (deferred) (if v1.1+ enabled) +
   122	     voice corpus + tone rules + recent_edits + tenant comms-template
   123	     library + addressee-resolution data
   124	   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")
   125	
   126	1. Source detection (mode-dependent)
   127	   → mode=webhook: parse Bullhorn payload → resolve entity + state transition
   128	   → mode=poll: query Bullhorn for placements/candidates with state_changed_at
   129	     > tenant_adapters.config.concierge_last_poll AND not in decision_log
   130	     (anti-duplicate)
   131	   → mode=nurture-sweep: query Bullhorn placements for time-elapsed events
   132	     (7d/30d/90d post-start with no concierge action in last 14d)
   133	   → ESC_LIFECYCLE_STATE_UNKNOWN if state transition not in 12-event taxonomy
   134	   → hh_decision_output("lifecycle_event_detected",
   135	     "<entity_type>:<bullhorn_id>", "<from>→<to>")
   136	
   137	2. Anti-duplicate guard
   138	   → query decision_log for prior `concierge_email_draft` row for same
   139	     (candidate_id, payload.event_type) in last 24h with phase IN
   140	     ('output', 'action') — if a prior draft was emitted AND either sent OR
   141	     is still pending consultant action, the new event is a duplicate trigger
   142	   → if found AND send-completed: skip (true duplicate)
   143	   → if found BUT prior draft never sent (no `gmail_outlook_send_to_candidate`
   144	     follow-up action row): allow the new draft attempt (per Q7 disposition)
   145	   → hh_decision_output("anti_duplicate_check", "<entity_type>:<bullhorn_id>",
   146	     "<duplicate_status>")
   147	
   148	3. Bullhorn context fetch
   149	   → bullhorn.get_candidate(candidate_id) → name, current state, comms history
   150	   → bullhorn.get_placement(placement_id) → role, client, dates
   151	   → bullhorn.get_client(client_id) → company name, primary contact
   152	   → bullhorn.get_contact(contact_id) → name, email
   153	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
   154	     ESC_BULLHORN_AUTH on auth fail
   155	   → ESC_CANDIDATE_DATA_INCOMPLETE if critical fields missing (no email,
   156	     no name) — draft cannot proceed
   157	   → hh_decision_output("bullhorn_context_fetched",
   158	     "candidate:<bullhorn_id>", "fields_present:<N>")
   159	
   160	4. Addressee resolution (Gate A critical)
   161	   → recipient = candidate.email OR client_contact.email per event_type
   162	   → verify recipient matches the candidate_id whose lifecycle is changing
   163	     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
   164	     "correct addressee resolution; no candidates emailed under another's name")
   165	   → ESC_ADDRESSEE_MISMATCH if check fails (blocking); draft aborted
   166	   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
   167	     "recipient_role:<role>")
   168	
   169	5. Comms-template selection
   170	   → tenant comms-template library at /vault/<slug>/concierge-templates/
   171	   → per event_type: select template; per recipient_role: candidate vs client
   172	   → fallback: shared/common-comms-templates.yaml if tenant has no override
   173	   → hh_decision_output("template_selected", "<event_type>:<recipient_role>",
   174	     "template_id:<id>")
   175	
   176	6. Sensitive-event escalation routing
   177	   → if event_type=rejection (event 6) OR event_type=withdrawal (event 7)
   178	     OR (event_type=on-hold AND placement value >£10k): set escalation_position=3
   179	     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
   180	   → else: escalation_position=1 (standard orange tier)
   181	   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
   182	     "position:<N>")
   183	
   184	7. LLM draft generation
   185	   → prompt = (event context + candidate state history + voice corpus
   186	     ANN-matched on event_type + tone rules filtered for concierge +
   187	     comms-template structure)
   188	   → output = email body + subject + recommended_send_time
   189	   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
   190	   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries
   191	
   192	8. Voice + tone validation
   193	   → voice classifier scores the draft
   194	   → minimum threshold by escalation_position:
   195	     position 1: ≥0.75
   196	     position 2: ≥0.78
   197	     position 3 (rejections / sensitive): ≥0.82
   198	   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
   199	   → on success: hh_decision_action("concierge_email_draft",
   200	     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
   201	     tier=yellow per autosend-policy.yaml
   202	
   203	9. SLA timing check (Gate B leading metric — NOT Gate A hard-fail)
   204	   → elapsed = now() - event_timestamp
   205	   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
   206	   → per ULTRAPLAN A6 line 566 verbatim "every lifecycle event has a draft
   207	     generated within 30 minutes" — interpreted as a Gate B leading metric
   208	     (90% of drafts within 30 min) rather than per-draft hard fail (legitimate
   209	     polling-fallback delays would otherwise block drafts entirely)
   210	
   211	10. PII boundary check
   212	    → no PII from other candidates referenced in body
   213	    → no PII from competitor clients referenced
   214	    → no compensation specifics outside what's already in candidate's record
   215	    → ESC_PII_LEAKAGE_RISK on hit (blocking)
   216	    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
   217	     "result:passed")
   218	
   219	11. Autosend-bridge routing (D1 path)
   220	    → per Founder Decision D1 (final selection at W10 design):
   221	      D1-A (bridge to cortextOS approval system): POST internal API
   222	      D1-B (lightweight Telegram shim): send approval prompt to operator
   223	      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
   224	    → per autosend-policy.yaml: orange-tier; consultant approves
   225	    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within 24h (D1-A/B)
   226	
   227	12. (After operator approval) Send execution — orange-tier
   228	    → microsoft-graph.send_email() OR gmail.send_email() per tenant config
   229	    → BCC: tenant's archive address (per tenant config)
   230	    → hh_decision_action("gmail_outlook_send_to_candidate",
   231	      "candidate:<bullhorn_id>", payload_hash, payload_preview)
   232	      [or `bullhorn_note_customer_visible` if channel=Bullhorn-note]
   233	    → ESC_SEND_FAIL on 4xx/5xx; retry once 30s backoff
   234	
   235	13. Bullhorn activity-log write
   236	    → bullhorn.create_activity_log(candidate_id, "concierge: <event_type>
   237	      sent at <ISO>")
   238	    → maintains audit trail in Bullhorn itself
   239	    → hh_decision_output("bullhorn_activity_logged",
   240	      "candidate:<bullhorn_id>", "event_type:<type>")
   241	
   242	14. Lifecycle state advance (Bullhorn write, conditional)
   243	    → some events trigger Bullhorn state changes (e.g., interview-completed
   244	      sent → advances state to "post-interview" if tenant policy says so)
   245	    → per-tenant policy; opt-in; not all tenants want this
   246	    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
   247	      payload_hash, "event=<type> elapsed=<seconds>")
   248	
   249	15. Session close + Gate B metric
   250	    → compute elapsed (event → send) for Gate B SLA tracking
   251	    → check ghosted-rate metric (any candidate with no Concierge action in
   252	      14 days post-state-change → contributes to ghosted-rate)
   253	    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
   254	    → hh_decision_action("concierge_run_complete", session_id, run_mode)
   255	    → exit code 0
   256	```
   257	
   258	---
   259	
   260	## §5 — Gates

exec
/bin/zsh -lc "find docs agents -maxdepth 5 -type f \\( -iname '*ultraplan*' -o -iname '*master*brief*' -o -iname 'autosend-safety-policy.yaml' -o -iname 'vertical-schema.yaml' -o -iname 'v1.0-kill-criterion.md' -o -iname 'escalation-codes.md' -o -iname 'voice-loader.sh' -o -iname 'hook-helpers.sh' \\)" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/specs/ULTRAPLAN.md
docs/build-brief/00-MASTER-BRIEF.md
docs/decisions/v1.0-kill-criterion.md
docs/verticals/recruitment/vertical-schema.yaml
agents/_shared/voice-loader.sh
agents/_shared/hook-helpers.sh
agents/_shared/escalation-codes.md

exec
/bin/zsh -lc "rg --files | rg '("'^|/)(MASTER|master|ULTRAPLAN|autosend-safety-policy|vertical-schema|escalation-codes|voice-loader|hook-helpers|v1.0-kill-criterion|agent.md)$'"'" in /Users/madsadmin/code/CortexOS
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
legacy/v1/docs/phase-2-agent-suite/client-onboarder/agent.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/agent.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/agent.md
legacy/v1/docs/phase-2-agent-suite/content-creator/agent.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/agent.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/agent.md
legacy/v1/docs/phase-2-agent-suite/repurposer/agent.md
legacy/v1/docs/phase-2-agent-suite/hr-agent/agent.md
legacy/v1/docs/phase-2-agent-suite/librarian/agent.md

codex
The local artefact is present; I’ve got its line numbers now. Next I’m checking whether the cited policy and catalogue entries actually exist and whether the workflow’s assumed fields are in the vertical schema.
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '260,520p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	## §5 — Gates
   261	
   262	### Gate A — validate.sh (hard-fail before action)
   263	
   264	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
   265	
   266	- **"voice classifier score ≥ position-specific threshold"** (≥0.75 position 1, ≥0.78 position 2, ≥0.82 position 3) — hard-fail
   267	- **"correct addressee resolution (no candidates emailed under another's name)"** — hard-fail (Step 4 critical; ESC_ADDRESSEE_MISMATCH)
   268	- No tone-rule block-severity violations — hard-fail (ESC_TONE_RULE_VIOLATION)
   269	- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
   270	- Anti-duplicate guard passed (Step 2) — hard-fail (skip if true duplicate)
   271	- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_CANDIDATE_DATA_INCOMPLETE)
   272	
   273	The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
   274	
   275	Gate A failures fire `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` or `ESC_PII_LEAKAGE_RISK` or `ESC_CANDIDATE_DATA_INCOMPLETE` or `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint when voice threshold misses persistently) — all blocking; draft to `/tmp`; operator notified immediately.
   276	
   277	**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   278	
   279	### Gate B — Outcome thresholds (success metrics, not block)
   280	
   281	Per ULTRAPLAN A6 line 567 verbatim: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts"**.
   282	
   283	Two metrics:
   284	- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%.
   285	- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`.
   286	
   287	Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
   288	
   289	---
   290	
   291	## §6 — Escalation codes
   292	
   293	Concierge uses these ESC codes from `agents/_shared/escalation-codes.md`:
   294	
   295	| Code | Trigger | Severity | Routing |
   296	|---|---|---|---|
   297	| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
   298	| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
   299	| `ESC_MS_GRAPH_AUTH` | Microsoft Graph OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin (token re-auth required) |
   300	| `ESC_GMAIL_AUTH` | Gmail OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin |
   301	| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
   302	| `ESC_CANDIDATE_DATA_INCOMPLETE` | Missing email / name in Bullhorn entity | warn | operator_chat_id |
   303	| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
   304	| `ESC_VOICE_DRIFT` | Voice classifier below position-specific threshold after 3 retries | warn (position 1-2) or **blocking** (position 3) | operator_chat_id (1-2) / operator + ifos_oncall (position 3) |
   305	| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | **blocking** | operator + ifos_oncall |
   306	| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
   307	| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
   308	| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within 24h | warn | operator + tenant-admin |
   309	| `ESC_SEND_FAIL` | Email provider 4xx/5xx | warn | operator_chat_id |
   310	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
   311	| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
   312	| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
   313	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
   314	
   315	Concierge has the largest escalation surface of any v1.0 agent — appropriate for the highest-stakes customer-facing comms.
   316	
   317	Concierge does NOT use:
   318	
   319	- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
   320	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
   321	- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
   322	
   323	---
   324	
   325	## §7 — Voice + tone constraints
   326	
   327	Steps 7-8 (draft generation + voice/tone validation) are the load-bearing voice surface of v1.0. The agent integrates with `_shared/voice-loader.sh`:
   328	
   329	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
   330	  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 line 570; demand specificity)
   331	  - No "Per our previous conversation" without referencing the actual conversation context
   332	  - No urgency language ("URGENT", "ACT NOW") unless the lifecycle event genuinely requires it
   333	  - No mention of other candidates by name
   334	  - No salary/rate specifics outside what's already on the candidate's record
   335	  - No competing-agency references
   336	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
   337	- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
   338	
   339	**Position-specific thresholds:**
   340	- Position 1 (standard sends — acknowledgement, prep, debrief, nurture): voice ≥0.75
   341	- Position 2 (placement-positive, status-update): voice ≥0.78
   342	- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 line 570 explicitly names rejection voice as the hardest case)
   343	
   344	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   345	
   346	---
   347	
   348	## §8 — Build dependencies (W10-13 prerequisites)
   349	
   350	Concierge build cannot start until ALL of the following are confirmed:
   351	
   352	| Dependency | Source | Status |
   353	|---|---|---|
   354	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   355	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   356	| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
   357	| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
   358	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   359	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   360	| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
   361	| **Microsoft Graph commercial signup** (per tenant) | Tenant onboarding | ⏸ |
   362	| **Gmail / Google Workspace signup** (alternative per tenant) | Tenant onboarding | ⏸ |
   363	| Microsoft Graph MCP connector | W10 build start (~3 days) | ⏸ |
   364	| Gmail MCP connector | W10 build start (~3 days) | ⏸ |
   365	| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
   366	| Autosend bridge built (per D1 outcome) | W10 build start (~2 days for D1-A; less for D1-B/C) | ⏸ |
   367	| Voice classifier microservice live | W4-5 polish | ⏸ |
   368	| Per-tenant comms-template library at `/vault/<slug>/concierge-templates/` | Tenant onboarding | ⏸ |
   369	| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
   370	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   371	| `validate.sh` Gate A logic | Build at W10 start (~2 days; most complex of v1.0 validators) | ⏸ |
   372	| `context.sh` hydration | Build at W10 start (~1 day) | ⏸ |
   373	| `cycle.sh` orchestration (15-step) | Build at W10-11 (~5 days; lifecycle state machine + 12 event types) | ⏸ |
   374	| Lifecycle event-detection polling fallback | Build at W11-12 (~3 days; Bullhorn webhook coverage gaps) | ⏸ |
   375	| Comms-template library v0.1 (12 event types × 2 recipient roles = 24 templates minimum) | Build at W12-13 (~5 days) | ⏸ |
   376	| 5 fixtures with golden outputs (broader than 3 for other agents; XL complexity warrants) | Build at W13 (~2 days) | ⏸ |
   377	
   378	**Until ALL ⏸ items resolve to ✅, W10 build slice does not start.** XL build complexity = 4-week duration not negotiable.
   379	
   380	---
   381	
   382	## §9 — Status + open questions
   383	
   384	**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
   385	
   386	### Open questions for founder review
   387	
   388	| # | Question | Resolution path |
   389	|---|---|---|
   390	| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
   391	| Q2 | Lifecycle event taxonomy — 12 events proposed in §3. Founder confidence each is correct + complete? Missing: "candidate referred to another role internally"? "Client cancelled brief"? | Founder review with first pilot consultants. Recommend: ship 12-event v1.0; expand v1.1+ based on real patterns. |
   392	| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
   393	| Q4 | Rejection emails (event 6) — Position 3 (voice ≥0.82). Is this enough, or should rejections route to consultant for full draft (not just approve)? | Founder review with first pilot consultant. Recommend: Concierge drafts; consultant approves; never bypasses voice gate. |
   394	| Q5 | Comms-template customisation — every tenant edits these. Per-event-type, per-recipient-role × per-tenant = 24+ templates each. Authoring tool? | v1.0: Markdown files at `/vault/<slug>/concierge-templates/<event>-<role>.md`. v1.1: Brain UI WYSIWYG editor. |
   395	| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
   396	| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
   397	| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
   398	| Q9 | Cross-tenant lifecycle handling — what if a candidate placed at Tenant A's client interviews at Tenant B 6 weeks later? Bullhorn has separate tenant slugs; no cross-tenant leak. But operator visibility? | v1.0: strict tenant isolation (no cross-tenant data visibility). v1.1+: separate agent for tenant-network-graph if commercial demand. |
   399	| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
   400	
   401	### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)
   402	
   403	1. **Lifecycle event detection from Bullhorn is the unreliable bit.** Bullhorn's webhook coverage is patchy; polling fallbacks are required. Step 1 polling at 5-min cycle + anti-duplicate guard at Step 2 is the architecture.
   404	2. **Voice quality on rejections is the hardest test case.** Position-3 threshold (≥0.82) + sensitive-event escalation routing (Step 6). Get this wrong and it costs the tenant a candidate relationship.
   405	3. **Comms-template library is per-tenant, per-event-type, per-recipient-role.** 24+ templates per tenant minimum. Authoring effort is significant; consider this in pilot onboarding scoping.
   406	4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add agent-identity email adapter (deferred).
   407	
   408	---
   409	
   410	## §10 — When this document ratifies
   411	
   412	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   413	
   414	Status flips Proposed → Accepted when:
   415	- Codex Round 4 Phase 2 ratifies
   416	- **Founder Decision D1 RESOLVED** (Q1 above) — without this, Concierge build cannot start
   417	- Founder approves §9 Q2 (lifecycle taxonomy) + Q3 (send window) + Q4 (rejection routing) + Q5 (template authoring UX) + Q6 (Gate B UX)
   418	- Q7-Q9 documented decisions captured
   419	
   420	Status flips Accepted → In Force when:
   421	- W10-13 build slice produces all 5 sibling bundle files + 5 fixtures (broader fixture coverage warranted by XL complexity)
   422	- First production lifecycle webhook processed end-to-end against migration-test tenant
   423	- 12-event taxonomy validated against first pilot tenant's actual Bullhorn state-change patterns
   424	- Voice classifier microservice production-ready (per-tenant; position-3 ≥0.82 sustained)
   425	- Gate B feedback loop operational (consultant approve/edit distinguishable)
   426	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   427	
   428	Until then: this document is a forward-looking scaffold. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at scaffold stage. Founder review at each iteration is expected.
   429	
   430	*End of Concierge agent.md draft.*

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '540,575p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   540	- **Build complexity:** **L** (2 weeks) — three accounting integrations × Open Banking is the work
   541	- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
   542	
   543	#### A5. Sourcing Scout (daytime form) — request-response sourcing
   544	
   545	- **Build wave:** v1.0 (week 8–9)
   546	- **Always-on?** Tier 2 — request-response
   547	- **Trigger type:** Brain UI button, Telegram command, or webhook from a "new brief" event
   548	- **CortexOS primitives required:** None for the daytime form (Night Sourcer in v1.1 will use #6)
   549	- **MCP tools required:** Bullhorn (read for ATS passive matches), LinkedIn (via Proxycurl or similar), Reed.co.uk API, CV-Library API
   550	- **Shared modules required:** Voice loader (for the rationale narrative), decision log writer
   551	- **External APIs:** Proxycurl, Reed, CV-Library
   552	- **Gate A:** 5–15 candidates returned per brief; each has a working contact method; each has rationale ≥ 50 words; no candidate flagged "do not contact" in tenant vault
   553	- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)
   554	- **Build complexity:** **L** (2 weeks) — the multi-source aggregation logic is the work
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
   566	- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
   567	- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts
   568	- **Build complexity:** **XL** (4 weeks) — this is the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)
   569	- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
   570	
   571	### 8.2 v1.1 agents (seven, in build order)
   572	
   573	#### A7. Inbound Triage (priority 1, 4 weeks)
   574	
   575	- **Build wave:** v1.1 (Q4 2026 weeks 1–4)

exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,620p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "find . -name 'autosend-safety-policy.yaml' -o -name '*autosend*policy*'" in /Users/madsadmin/code/CortexOS
 succeeded in 325ms:
./agents/_shared/autosend-policy.yaml
./docs/decisions/autosend-safety-policy.md
./logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
./logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc 'rg -n "tenant_adapters|decision_log|recent_edit|candidate_id|placement_id|event_type|voice_score|recipient|escalation_position|concierge|candidate|placement|tone_rule|voice_corpus" docs/verticals/recruitment/vertical-schema.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
48:  candidate:
50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
90:          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
95:        notes: Bullhorn user (consultant) who owns this candidate record.
147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
159:      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
163:      # Inherits candidate fields conceptually; below are the additional contractor-specific fields.
164:      # Full implementation: adapter layer materialises both candidate-overlap fields AND contractor-specific fields in entities.data.
165:      # Schema notes: see candidate canonical_fields for the shared base set.
170:        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
205:        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
426:      - v0.1 skills as free strings; v1.1 introduces a canonical skill taxonomy (out of scope here; ADR-006 candidate).
429:  placement:
431:      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
450:        notes: Nullable for permanent placements; required for contract.
456:      placement_type:
465:        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
471:      candidate_salary_at_placement:
491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
497:      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
502:      - (v1.1) Inbound Triage — read for routing inbound candidate enquiries to active opportunities
512:        enum: [submitted, screening, interview_scheduled, interview_completed, offer_pending, offer_accepted, rejected_by_client, rejected_by_candidate, withdrawn]
585:  candidate_placed_in_role:
586:    source: candidate
587:    target: placement
589:    description: A candidate may have multiple placements over time (different clients, different roles). A placement has exactly one candidate.
591:      Despite "M:N" cardinality, practically 1:N from placement → candidate (each placement has one candidate; each candidate has 0..N placements). Modelled as M:N for query symmetry.
592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
594:  placement_for_brief:
595:    source: placement
598:    description: Each placement fills exactly one brief; a brief may have multiple placements over time (replacement hires, multiple seats).
625:  candidate_engaged_with_contact:
626:    source: candidate
632:  candidate_referred_by_contact:
633:    source: candidate
636:    description: Some candidates are referred by a contact (a candidate's previous manager, peer, etc., who is in the IFOS contact registry).
643:    description: An opportunity is a candidate's progression toward a specific brief.
647:  opportunity_about_candidate:
649:    target: candidate
651:    description: Each opportunity is about exactly one candidate; a candidate may have multiple opportunities (different briefs).
654:  timesheet_for_placement:
656:    target: placement
658:    description: Each timesheet relates to one (contract) placement; a placement has 0..N timesheets over its duration.
672:    candidate: none
677:    placement: none
683:    candidate: R+W   # full sweep + normalisation + dedup proposals
688:    placement: R     # orphan / stale-tag sweep
693:    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
695:    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
698:    placement: R+W   # note links on placed-candidate calls
703:    candidate: none  # No Bullhorn touch — Xero + Open Banking only
708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
713:    candidate: R     # passive matching
718:    placement: none
723:    candidate: R+W   # lifecycle state on every event
728:    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
741:  candidate:
751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
752:    notes: Adapter layer materialises both `candidate` and `contractor` entity_type rows from the same Bullhorn.Candidate record when status flips. See entity-level notes.
771:  placement:
799:    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
861:    v0_1_decision: placement.lifecycle_stage enum is hardcoded to Product Spec §2.2 R7 values (pre_start, week_1, month_1, month_3, month_6, month_12, month_24, completed).
862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.
898:      Triage expansion (Q5 contact decision-authority granularity, Q10 panel hiring). Skill taxonomy decision (Q8). Multi-client contact decision (Q9). Umbrella company entity promotion candidate (Q7). Opportunity entity exercise begins.

exec
/bin/zsh -lc 'rg -n "ESC_(BULLHORN_AUTH|RATE_LIMIT_HIT|MS_GRAPH_AUTH|GMAIL_AUTH|LIFECYCLE_STATE_UNKNOWN|CANDIDATE_DATA_INCOMPLETE|ADDRESSEE_MISMATCH|VOICE_DRIFT|TONE_RULE_VIOLATION|PII_LEAKAGE_RISK|CONCIERGE_SLA_MISS|APPROVAL_BRIDGE_TIMEOUT|SEND_FAIL|AGENT_OUTPUT_SHAPE|GATE_B_MISS|AUTOSEND_ORANGE_PENDING|AUTOSEND_SAMPLED_SPOT_CHECK|AUTOSEND_BLOCKED|SCHEMA_VIOLATION|VOICE_DRIFT_TENANT)" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
41:#### `ESC_AUTOSEND_BLOCKED`
97:#### `ESC_BULLHORN_AUTH`
120:#### `ESC_VOICE_DRIFT`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
184:#### `ESC_AGENT_OUTPUT_SHAPE`
186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
331:#### `ESC_SEND_FAIL`
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
431:#### `ESC_CONCIERGE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`

exec
/bin/zsh -lc 'rg -n "hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|hh_decision_trigger|hh_decision_output|hh_decision_action" agents/_shared/voice-loader.sh agents/_shared/hook-helpers.sh' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/hook-helpers.sh:166:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:168:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:180:hh_decision_output() {
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:193:hh_decision_action() {
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '220,310p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   261	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   262	    irreversible: true
   263	
   264	  diagnostic_email_send:
   265	    tier: orange
   266	    agent: diagnostic
   267	    timeout: PT4H
   268	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   269	    irreversible: true
   270	
   271	  diagnostic_calendar_invite:
   272	    tier: orange
   273	    agent: diagnostic
   274	    timeout: PT4H
   275	    reason: "Books intro call with prospect; reputation + scheduling friction"
   276	    irreversible: true
   277	
   278	  linkedin_inmail_send:
   279	    tier: orange
   280	    agent: sourcing-scout
   281	    timeout: PT4H
   282	    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"
   283	    irreversible: true
   284	
   285	  bullhorn_placement_terminate:
   286	    tier: orange
   287	    agent: janitor
   288	    timeout: PT4H
   289	    reason: "Marks placement as terminated; commercial/legal implications; reversible only via support ticket"
   290	    irreversible: false
   291	
   292	  # ───────────────────────────────────────────────────────────
   293	  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
   294	  # ───────────────────────────────────────────────────────────
   295	
   296	  xero_payment_initiate:
   297	    tier: red
   298	    agent: all
   299	    block_reason: payment_action
   300	    reason: "Payment transfer; financial-bearing; never auto-send in v1.0"
   301	    irreversible: true
   302	
   303	  stripe_charge_initiate:
   304	    tier: red
   305	    agent: all
   306	    block_reason: payment_action
   307	    reason: "Charges a card; financial-bearing"
   308	    irreversible: true
   309	
   310	  subscription_modify:

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '1,170p' && nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '429,530p' && nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '713,730p'" in /Users/madsadmin/code/CortexOS
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
   521	          v0.1 captures shape; v1.1+ exercises.
   522	      date_submitted:
   523	        type: timestamp
   524	        required: true
   525	        source: Bullhorn.JobSubmission.dateAdded
   526	      date_last_modified_at:
   527	        type: timestamp
   528	        required: true
   529	        source: Bullhorn.JobSubmission.dateLastModified
   530	    notes:
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '30,210p' && nl -ba agents/_shared/escalation-codes.md | sed -n '250,460p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   456	
   457	---
   458	
   459	## §3 — Reserved codes (not-yet-wired)
   460	

exec
/bin/zsh -lc 'rg -n "tenant_adapters|concierge_last_poll|concierge_send_window|recent_edit|approved_verbatim|approved_after_edit|action_type|phase" -S docs agents packages migrations' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: migrations: No such file or directory (os error 2)
agents/_shared/README.md:3:**Status:** Phase 5 complete (v0.1). All 4 phase deliverables landed; live VPS migration is a manual founder action (see §Live integration test).
agents/_shared/README.md:9:| File | Purpose | Phase |
agents/_shared/README.md:12:| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:53:hh_decision_action  <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/README.md:61:autosend_policy_lookup        <action_type>                                          # prints tier
agents/_shared/README.md:62:autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>               # prints possibly-elevated tier
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:65:autosend_should_sample        <action_type> <tenant_slug>                            # returns 0 if sampled
agents/_shared/README.md:66:autosend_spot_check_enqueue   <action_type> <target> <hash> <preview> <tenant_slug>
agents/_shared/README.md:67:autosend_await_approval       <action_type> <target> <hash>                          # blocks until resolved
agents/_shared/README.md:76:| **green** | Emit `phase=action`, return 0 immediately | 0 |
agents/_shared/README.md:77:| **yellow** | Emit `phase=action`, draw 1-in-N spot-check sample, return 0 | 0 |
agents/_shared/README.md:78:| **orange** | Emit `phase=action` + escalate `ESC_AUTOSEND_NEEDS_REVIEW`, block on approval gate, return 0/1 | depends on approval |
agents/_shared/README.md:79:| **red** | Emit `phase=gating_failed` + escalate `ESC_AUTOSEND_BLOCKED`, return 1 | 1 |
agents/_shared/README.md:80:| _unknown_ | Emit `phase=gating_failed` (`fail-safe-red`) + escalate `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`, return 1 | 1 |
agents/_shared/README.md:84:Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:112:Phase 3 acceptance #2 + #3 + Phase 5 live-migration require live Postgres against the Hetzner VPS. Procedure:
agents/_shared/README.md:122:3. Founder verifies via `psql` that one new row landed in `decision_log` with `phase='trigger'` + `tenant_slug='migration-test'`.
agents/_shared/README.md:132:### Phase 5 live migration (manual founder action)
agents/_shared/README.md:144:   - 4 new tables (`voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`)
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:181:- `~/.claude/plans/bubbly-snuggling-lantern.md` — active 5-phase plan
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:8:# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:23:action_types:
agents/_shared/autosend-policy.yaml:26:  # GREEN — auto-send without review (19 action_types)
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:110:    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
agents/_shared/autosend-policy.yaml:144:  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
agents/_shared/autosend-policy.yaml:165:    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
agents/_shared/autosend-policy.yaml:214:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
agents/_shared/autosend-policy.yaml:218:  # ORANGE — per-action human approval (10 action_types)
agents/_shared/autosend-policy.yaml:293:  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
agents/_shared/autosend-policy.yaml:342:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:353:# Defaults applied when override fields are absent in tenant_adapters
agents/_shared/autosend-policy.yaml:362:# Compile-time consistency assertions (enforced by Phase-3 validator script,
agents/_shared/autosend-policy.yaml:368:  - "yellow action_types MUST declare sample_rate (positive integer)"
agents/_shared/autosend-policy.yaml:369:  - "orange action_types MUST declare timeout (ISO-8601 duration)"
agents/_shared/autosend-policy.yaml:370:  - "red action_types MUST declare block_reason"
agents/_shared/autosend-policy.yaml:372:  - "47 total action_types (19 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:10:# Phase 4 Cat-β section. Closes the v0.3-scoped subset (14 entity JSONB keys + 2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:318:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:326:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:580:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:711:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:742:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:756:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:765:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:830:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:853:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:855:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:928:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:940:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:954:  Round-8 categorization (disagreement doc Phase 4 Cat-β) identified that
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:976:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:978:    - Concierge tenant_adapters.config field refs valid
agents/_shared/hook-helpers.sh:100:# _hh_emit_row <phase> <outcome> <reason> <payload_json>
agents/_shared/hook-helpers.sh:106:  local phase="$1"
agents/_shared/hook-helpers.sh:121:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
agents/_shared/hook-helpers.sh:125:  '$(_hh_sql_escape "${phase}")',
agents/_shared/hook-helpers.sh:149:  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
agents/_shared/hook-helpers.sh:152:    "$(_hh_json_escape "${phase}")" \
agents/_shared/hook-helpers.sh:167:# Writes phase='trigger' row at session start. Required first call of every run.
agents/_shared/hook-helpers.sh:178:# Writes phase='output' row per artefact produced. Required before producing
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:191:# Writes phase='action' or phase='gating_failed' row depending on tier.
agents/_shared/hook-helpers.sh:194:  local action_type="$1"
agents/_shared/hook-helpers.sh:202:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
agents/_shared/hook-helpers.sh:203:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:205:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:206:      "${target}" "${payload_hash}" "unknown_action_type"
agents/_shared/hook-helpers.sh:210:  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
agents/_shared/hook-helpers.sh:211:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:213:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:220:      autosend_emit_decision_log "action" "green" "${action_type}" \
agents/_shared/hook-helpers.sh:225:      autosend_emit_decision_log "action" "yellow" "${action_type}" \
agents/_shared/hook-helpers.sh:227:      if autosend_should_sample "${action_type}" "${tenant}"; then
agents/_shared/hook-helpers.sh:228:        autosend_spot_check_enqueue "${action_type}" "${target}" \
agents/_shared/hook-helpers.sh:234:      autosend_emit_decision_log "action" "orange" "${action_type}" \
agents/_shared/hook-helpers.sh:236:      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:238:      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
agents/_shared/hook-helpers.sh:242:      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
agents/_shared/hook-helpers.sh:244:      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
agents/_shared/hook-helpers.sh:249:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:251:      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:262:# autosend_policy_lookup <action_type>
agents/_shared/hook-helpers.sh:264:# 1 if action_type missing from policy file.
agents/_shared/hook-helpers.sh:266:  local action_type="$1"
agents/_shared/hook-helpers.sh:271:  # YAML lookup via awk — finds the action_type key, then reads tier:
agents/_shared/hook-helpers.sh:274:  tier=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:285:# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:286:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:291:  local action_type="$2"
agents/_shared/hook-helpers.sh:307:  override=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:323:      "${base_tier}" "${override}" "${tenant_slug}" "${action_type}" >&2
agents/_shared/hook-helpers.sh:329:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:332:  local phase="$1"
agents/_shared/hook-helpers.sh:334:  local action_type="$3"
agents/_shared/hook-helpers.sh:341:  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
agents/_shared/hook-helpers.sh:343:    "$(_hh_json_escape "${action_type}")" \
agents/_shared/hook-helpers.sh:350:  _hh_emit_row "${phase}" "${tier}" "${reason_or_status}" "${payload}"
agents/_shared/hook-helpers.sh:355:# lookup is permissive — unknown codes are emitted with phase='gating_failed'
agents/_shared/hook-helpers.sh:390:# autosend_should_sample <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:393:# tenant override via tenant_adapters.config.sampling_rates.
agents/_shared/hook-helpers.sh:395:  local action_type="$1"
agents/_shared/hook-helpers.sh:398:  rate=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:416:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
agents/_shared/hook-helpers.sh:420:  local action_type="$1"
agents/_shared/hook-helpers.sh:434:  local outfile="${spot_dir}/${timestamp}-${action_type}-${payload_hash:0:12}.md"
agents/_shared/hook-helpers.sh:441:    printf '# Spot check — %s\n\n' "${action_type}"
agents/_shared/hook-helpers.sh:451:# autosend_await_approval <action_type> <target> <payload_hash>
agents/_shared/hook-helpers.sh:458:  local action_type="$1"
agents/_shared/hook-helpers.sh:463:  timeout_iso=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:488:    printf 'action_type=%s\n' "${action_type}"
agents/_shared/hook-helpers.sh:511:        autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:539:  autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/recruitment/cash-conductor/README.md:37:Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.
agents/_shared/tests/test-hook-helpers.sh:95:printf '\n[1] hh_decision_trigger writes a phase=trigger row\n'
agents/_shared/tests/test-hook-helpers.sh:101:  _assert_contains "${row}" '"phase":"trigger"' \
agents/_shared/tests/test-hook-helpers.sh:104:_test_run "phase=trigger row written" test_trigger
agents/_shared/tests/test-hook-helpers.sh:106:printf '\n[2] hh_decision_output writes a phase=output row\n'
agents/_shared/tests/test-hook-helpers.sh:112:  _assert_contains "${row}" '"phase":"output"' \
agents/_shared/tests/test-hook-helpers.sh:115:_test_run "phase=output row written" test_output
agents/_shared/tests/test-hook-helpers.sh:138:    && _assert_contains "${row}" '"phase":"action"'
agents/_shared/tests/test-hook-helpers.sh:140:_test_run "green action: rc=0 + phase=action + tier=green" test_action_green
agents/_shared/tests/test-hook-helpers.sh:151:    && _assert_contains "${row}" '"phase":"gating_failed"' \
agents/_shared/tests/test-hook-helpers.sh:154:_test_run "red action: rc=1 + phase=gating_failed + ESC_AUTOSEND_BLOCKED" test_action_red
agents/_shared/tests/test-hook-helpers.sh:179:printf '\n[8] hh_decision_action — unknown action_type → ESC_AUTOSEND_POLICY_LOOKUP_FAILED\n'
agents/_shared/tests/test-hook-helpers.sh:279:    && _assert_contains "${row}" '"phase":"action"'
agents/_shared/tests/test-hook-helpers.sh:281:_test_run "yellow action: rc=0 + phase=action + tier=yellow" test_action_yellow
agents/_shared/tests/test-hook-helpers.sh:297:  gating_failed_count=$(grep -c '"phase":"gating_failed"' "${IFOS_DECISION_LOG_FALLBACK}")
agents/_shared/tests/test-hook-helpers.sh:303:_test_run "kill-criterion Trigger 5: red-tier rows queryable by tier+phase" test_kill_criterion_trigger5
agents/_shared/escalation-codes.md:3:**Status:** Reference — single source of truth for `ESC_*` codes used by any agent. Wired into `_shared/hook-helpers.sh` (Phase 3).
agents/_shared/escalation-codes.md:18:phase             — one of {trigger, output, action, gating_failed, agent_handoff}; per decision_log CHECK constraint at Day-4 §6.3
agents/_shared/escalation-codes.md:20:payload           — JSON object: {tier?, action_type?, target?, payload_hash?, reason, ...code-specific fields}
agents/_shared/escalation-codes.md:36:- **Phase:** `action`
agents/_shared/escalation-codes.md:39:- **Payload fields:** `tier`, `action_type`, `target`, `payload_hash`, `payload_preview`, `approval_status='pending'`
agents/_shared/escalation-codes.md:44:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:46:- **Payload fields:** `tier='red'`, `action_type`, `target`, `payload_hash`, `reason='red_tier_classification'`
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:51:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:53:- **Payload fields:** `tier='fail-safe-red'`, `action_type`, `target`, `reason` (one of `unknown_action_type`, `override_resolution_failed`, `unknown_tier:<value>`)
agents/_shared/escalation-codes.md:62:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:69:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:76:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:83:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:90:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:100:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:111:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:123:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:130:- **Phase:** `action`
agents/_shared/escalation-codes.md:137:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:144:- **Phase:** `agent_handoff`
agents/_shared/escalation-codes.md:151:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:159:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:166:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:173:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:180:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:187:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:197:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:204:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:212:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:219:- **Phase:** `agent_handoff`
agents/_shared/escalation-codes.md:226:- **Phase:** `agent_handoff`
agents/_shared/escalation-codes.md:233:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:243:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:251:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:259:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:267:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:275:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:283:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:291:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:302:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:313:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:320:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:327:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:334:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:344:- **Phase:** `action`
agents/_shared/escalation-codes.md:346:- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
agents/_shared/escalation-codes.md:351:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:353:- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:361:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:363:- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
agents/_shared/escalation-codes.md:369:- **Phase:** `action`
agents/_shared/escalation-codes.md:371:- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:380:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:388:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:396:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:403:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:412:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:420:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/escalation-codes.md:427:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:429:- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`
agents/_shared/escalation-codes.md:437:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:444:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:453:- **Phase:** `gating_failed`
agents/_shared/escalation-codes.md:470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
agents/_shared/escalation-codes.md:476:3. Resolve `phase` from this catalogue's `Phase:` line (table-driven, not freeform)
agents/_shared/escalation-codes.md:479:The catalogue is read at process start via `_shared/escalation-codes-table.sh` (machine-readable companion; deferred to Phase 3 or first use, whichever lands first). If absent, helpers fall back to permissive write (log row only; no Telegram) + emit a one-shot operational warning.
docs/operations/codex-ratification-guide.md:154:5. **Audit row write** — inserts a row into `decision_log` with `tenant_slug='ifos-meta'`, `agent_name='_codex_ratifier'`, `phase='output'`, `outcome=<RATIFIED|REJECTED>`, `payload` includes the artefact path, skill used, issue count, session ID, and the full Codex response text. Falls back to `logs/codex-ratification.jsonl` if no live DB.
docs/operations/codex-ratification-guide.md:253:Per execution plan §9: after cluster C, PAUSE until `bash scripts/run-live-migration.sh` succeeds. The live migration verifies Phase 4 SQL applies cleanly against the migration-test tenant; cluster D (migration ratification) makes more sense AFTER that.
agents/_shared/voice-loader.sh:8:#   - vertical-schema.v0.2-supplement.yaml schema migrated (Phase 4 SQL)
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:225:# Returns recent_edit rows from the last <lookback_days> for <agent_name>
agents/_shared/voice-loader.sh:229:#   { "edits": [ { "id": N, "action_type": "...", "edit_distance": N,
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/_shared/voice-loader.sh:245:      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
agents/_shared/voice-loader.sh:246:           FROM recent_edit
agents/_shared/voice-loader.sh:252:      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
agents/_shared/voice-loader.sh:253:           FROM recent_edit
agents/_shared/voice-loader.sh:260:    _vl_render_recent_edits_json "${rows}" "${lookback_days}"
agents/_shared/voice-loader.sh:268:_vl_render_recent_edits_json() {
agents/_shared/voice-loader.sh:279:  while IFS=$'\t' read -r id action_type edit_distance resolution tone_rules resolved_at; do
agents/_shared/voice-loader.sh:282:    printf '{"id":%s,"action_type":"%s","edit_distance":%s,"resolution":"%s","tone_rules_triggered":"%s","resolved_at":"%s"}' \
agents/_shared/voice-loader.sh:284:      "$(_hh_json_escape "${action_type}")" \
agents/_shared/tests/test-voice-loader.sh:122:printf '\n[6] hh_load_recent_edits returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:123:test_recent_edits_no_db() {
agents/_shared/tests/test-voice-loader.sh:125:  out=$(hh_load_recent_edits)
agents/_shared/tests/test-voice-loader.sh:130:_test_run "recent_edits fallback: empty array + default 30 days" test_recent_edits_no_db
agents/_shared/tests/test-voice-loader.sh:132:printf '\n[7] hh_load_recent_edits accepts custom lookback_days\n'
agents/_shared/tests/test-voice-loader.sh:133:test_recent_edits_custom_lookback() {
agents/_shared/tests/test-voice-loader.sh:135:  out=$(hh_load_recent_edits 7 "concierge")
agents/_shared/tests/test-voice-loader.sh:139:_test_run "recent_edits accepts 7-day lookback + agent_name" test_recent_edits_custom_lookback
agents/_shared/tests/test-voice-loader.sh:141:printf '\n[8] hh_load_recent_edits lookback_days validation clamps to 30\n'
agents/_shared/tests/test-voice-loader.sh:142:test_recent_edits_invalid_lookback() {
agents/_shared/tests/test-voice-loader.sh:144:  out=$(hh_load_recent_edits "abc")  # non-numeric → 30
agents/_shared/tests/test-voice-loader.sh:146:  out=$(hh_load_recent_edits "999")   # over cap → 30
agents/_shared/tests/test-voice-loader.sh:148:  out=$(hh_load_recent_edits "0")     # zero → 30
agents/_shared/tests/test-voice-loader.sh:151:_test_run "recent_edits lookback validation: non-numeric/over-cap/zero clamp to 30" test_recent_edits_invalid_lookback
agents/_shared/tests/test-voice-loader.sh:158:  out3=$(hh_load_recent_edits | wc -l | tr -d ' ')
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:5:# Author: Founder (Maddox), Phase-4 of bubbly-snuggling-lantern.md plan
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:14:#   Drafted alongside; executed against migration-test tenant in Phase 5.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:26:author: founder (Maddox), Phase-4 voice-corpus-substrate via Claude Code
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:27:codex_ratification_queue_position: 29  # appended after Phase-3 items
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:208:      action_type:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:247:          Enum: ["approved_verbatim", "approved_after_edit", "rejected", "deferred"]. `deferred` indicates operator returned to inbox without resolving (4h timeout case).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:366:  status: drafted (Phase 4); execution against migration-test tenant scheduled for Phase 5
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:368:    All v0.2 additions are nullable columns + new tables. Rollback = DROP TABLE on the 3 new tables + DROP COLUMN on the 6 added fields. No v0.1 data is mutated; v0.1 reads continue working after rollback. Migration SQL ships with companion v0.2-to-v0.1.sql (Phase 4 deliverable; landed in same commit).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:433:      Live migration deferred to Phase 5 against migration-test tenant first;
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:438:      Phase 5 — execute migration SQL against migration-test tenant; verify pgvector HNSW index builds clean; voice-loader.sh queries return expected shape; commit.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:34:| 12 | **PII purge remediation cannot execute against current schema** — `v0.2-to-v0.3-pii-purge.sql` adds `text_purged_at` and a CHECK requiring text fields to be NULL after purge, but v0.2 declares `recent_edit.original_text TEXT NOT NULL`; the purge script sets `original_text=NULL`. | ~~High~~ → Low post-remediation | ~~High~~ → Low for cron execution; legal posture still depends on D2/D3 | `v0.2-to-v0.3-pii-purge.sql` executed without `ALTER COLUMN original_text DROP NOT NULL`. | Round-2 remediation Fix 2 adds `ALTER COLUMN DROP NOT NULL` before the CHECK constraint. Verified by Round 3. | **Mitigated in this commit; remains pending D2/D3 founder decisions before production deployment.** |
docs/RISK-REGISTER.md:55:- 2026-05-22 (Day 11) — **Codex Round 2 autonomous ratification complete.** 26 artefacts reviewed; 17 RATIFIED / 9 REJECTED. Manifest §1.7 appended and full outputs written to `logs/codex-ratification/round-2-autonomous/`. D5 skill softening ratified. Bullhorn gate disagreement rejected because the promised source-doc sharpening did not land. Autosend policy, v0.2 supplement, approval bridge, PII purge runbook/script/forward migration, and tenancy audit script remain rejected. **New Risk #11** added for transactionless `SET LOCAL` usage across live DB scripts/helpers. **New Risk #12** added for the PII purge migration/script mismatch with `recent_edit.original_text NOT NULL`.
docs/RISK-REGISTER.md:56:- 2026-05-22 (Day 11 evening) — **Codex Round-2 remediation applied + Round 3 verified.** Fixes wrap all identified `SET LOCAL` calls in explicit transactions and make `recent_edit.original_text` nullable before PII purge; Risks #11 and #12 moved to mitigated. Founder-domain D1/D2/D3 remain open and are explicitly annotated in the affected artefacts.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:66:- 2026-05-20 (Day 8 evening) — **Codex ratification Round 1 complete + remediation landed.** 16 artefacts reviewed (Cluster A+B+C); 2 RATIFIED (ADR-004, brain-ui-scope); 14 REJECTED. Remediation commit `2b287d3` incorporates 13 of 14 rejections (Bucket 1 cosmetic + Bucket 2 ADR-004 back-propagation + Bucket 3 structural). 2 disagreement docs filed (`codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` + `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`). 5 founder decisions surfaced (D1-D5 in `2026-05-20-codex-round-1-founder-decisions.md`). **NEW Risk #10 candidate surfaced by Codex** (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation) — see Risk #10 below. Manifest queue updated with per-artefact Round-1 verdicts (`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5). Round 2 expected to take 14 REJECTED → 0-2 REJECTED.
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/specs/ULTRAPLAN.md:7:**Source documents this synthesises:** the final product spec; the CortexOS 24/7 directive; the temp deep dive; the internal business plan; the workflow analysis; the Phase 2 pattern reference; the hook-helpers reference implementation; the four Q&A answers provided by Maddox (Q2, Q4, Q5, Q8).
docs/specs/ULTRAPLAN.md:115:This is the answer to Q2 ("fork, harden, rebrand"). The Phase 2 pattern is the structural foundation. Three changes from Phase 2 → IntelForce OS Agent Bundle v2.
docs/specs/ULTRAPLAN.md:144:### 4.2 The three changes from Phase 2 → v2
docs/specs/ULTRAPLAN.md:148:Phase 2 has each `context.sh` `cat` the voice profile inline. That works for nine agents; it's brittle at eighteen. v2 introduces `_shared/voice-loader.sh`:
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:168:Phase 2's `hook-helpers.sh` has `hh_log` available but agents use it inconsistently. v2 enforces three writes via wrapper functions:
docs/specs/ULTRAPLAN.md:180:Phase 2's `escalation-codes.md` is consulting-product vocabulary. v2 expands to recruitment:
docs/specs/ULTRAPLAN.md:205:We do not back-port v2 to Phase 2 consulting agents. They stay on v1 of the pattern because we are not maintaining them for recruitment. Every new agent ships against v2. The migration doc is a 1-page artefact for the engineer that says "here is what changed; here is the helper function you call instead of inlining".
docs/specs/ULTRAPLAN.md:733:| Wed | Phase 2 pattern refactor scoping (the three v2 changes) |
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
agents/recruitment/cash-conductor/agent.md:56:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:93:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
agents/recruitment/cash-conductor/agent.md:97:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 257) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:116:1. `phase='output'`, `output_type='chase_draft_generated'`, payload includes the draft body + voice score + position (phase=output rows do NOT carry an autosend action_type; they're internal artefact-render markers).
agents/recruitment/cash-conductor/agent.md:117:2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 182-187), payload links to the draft from row 1 — this row records that Cash Conductor classified the draft as yellow-tier internal.
agents/recruitment/cash-conductor/agent.md:119:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 257; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
agents/recruitment/cash-conductor/agent.md:247:      line 257; Cash Conductor owns this action_type and OPENS the
agents/recruitment/cash-conductor/agent.md:255:      action_type per autosend-policy.yaml line 257; agent: cash-conductor).
agents/recruitment/cash-conductor/agent.md:262:      "invoice:<id>", "position:<N>; sent_at:<ISO>") — phase=output;
agents/recruitment/cash-conductor/agent.md:282:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:285:      — hh_decision_action signature is (action_type, target, payload_hash,
agents/recruitment/cash-conductor/agent.md:361:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/agent.md:374:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
agents/recruitment/cash-conductor/agent.md:393:| **Founder Decision D1 (autosend orange-tier path) RESOLVED** — blocking for Cash Conductor's xero_reminder_send_customer action_type | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` D1 (currently Proposed) | ⏸ |
agents/recruitment/cash-conductor/agent.md:429:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/cash-conductor/agent.md:432:- Codex Round 4 Phase 2 ratifies
docs/operations/codex-round-2-handoff.md:80:| 9 | `docs/architecture/agent-bundle-renderer-design.md` | status enum + phase=render + CLI drift | RATIFY (all three fixed) |
docs/operations/codex-round-2-handoff.md:268:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:26:DROP TABLE IF EXISTS recent_edit          CASCADE;
docs/_supplementary/PRD-autonomous-agent.md:40:18. [Build Phases & Task Checklist](#18-build-phases--task-checklist)
docs/_supplementary/PRD-autonomous-agent.md:146:| Asset storage | Local filesystem (Phase 1) / S3 (Phase 2) |
docs/_supplementary/PRD-autonomous-agent.md:1288:  // Step 2: Poll until complete (webhook in Phase 2)
docs/_supplementary/PRD-autonomous-agent.md:1987:## 18. Build Phases & Task Checklist
docs/_supplementary/PRD-autonomous-agent.md:1989:### Phase 1: Foundation — End-to-end manual pipeline (Week 1-2)
docs/_supplementary/PRD-autonomous-agent.md:2129:### Phase 2: Templates & Polish (Week 3)
docs/_supplementary/PRD-autonomous-agent.md:2143:### Phase 3: Discovery & Automation (Week 4)
docs/_supplementary/PRD-autonomous-agent.md:2249:### Phase 4: 24/7 Persistence (Week 5)
docs/_supplementary/PRD-autonomous-agent.md:2311:### Phase 5: Learning System (Week 5-6)
docs/_supplementary/PRD-autonomous-agent.md:2349:### Phase 6: Production Run (Week 6+)
docs/_supplementary/PRD-autonomous-agent.md:2353:- [ ] **Task 25**: Phase 2 infrastructure — AWS Lambda for Remotion rendering
docs/_supplementary/PRD-autonomous-agent.md:2532:5. Phase 2 templates (TASK-008-011) before automation
docs/_supplementary/PRD-autonomous-agent.md:2533:6. Phase 3 automation (TASK-012-017) before persistence
docs/_supplementary/PRD-autonomous-agent.md:2534:7. Phase 4 persistence (TASK-018-020) LAST
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:15:Week 3 goal at `docs/operations/goal-week-3-polish-and-scaffold.md` Step 7 (Codex Round 4 Phase 1) ratified `agents/recruitment/diagnostic/agent.md`. Codex found 4 issues; mechanical remediation applied (commit `6e0cb86`); Round 5 re-ratification found 5 new issues — 2 re-raises (Codex disagreed with my remediation framing), 3 new findings not visible at Round 4.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:73:**My recommendation:** **B** — cleaner, avoids sentinel proliferation. Feedback events are conceptually Diagnostic's domain (they validate Diagnostic outputs), so the agent_name should be Diagnostic with a specific action_type marker.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:91:3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:101:- Phase 1 Diagnostic-only: **1 of 6 artefacts attempted**; result is **REJECTED-after-hard-ceiling** awaiting founder arbitration via this disagreement doc
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:102:- Phase 2 full (5 new scaffolds): **deferred** pending Issue-5 resolution (review-agent-bundle.md skill build)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:130:4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:146:- Sentinel hygiene (Issue 4) is a real architectural concern; agent_name=agent + payload.action_type is the cleaner pattern; no reason to proliferate sentinels.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:189:2. `recent_edit` schema confusion — it's a v0.2 separate table, not a decision_log field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:217:4. Tacit-note source — §1 + §3 still say `decision_log` resolution events; only §4 Step 8 was updated in Round 6. Same `recent_edit` table confusion in different sections.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:227:| Round 7 | 4 | 23 | All different from R6 — many caused BY R6 fixes (added action_types without registering) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:247:### Phase 1 — Catalogue extensions (commit `151d4fe`)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:253:### Phase 2 — Agent.md remediation (commit `1ff1569`)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:257:- Cat-2 (decision-log calls): added hh_decision_output / hh_decision_action calls across all §4 sections; pre-registered action_types via Phase 1
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:266:### Phase 3 — Round 8 Codex ratification
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:281:#### Category α — Mechanical (fixed inline; commit appended to Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:313:- Despite Phase-2 adding ~20 calls, additional steps missing:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:326:**Phase 1 + Phase 2 + Phase 3 (Round 8 + Cat-α inline fixes) constitute the documented "Path A — bilateral session per master brief protocol" outcome.** No further autonomous remediation rounds will be attempted per the master brief §10.3 step 5 hard ceiling and founder's "no more rounds" authorization.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:344:*End of Phase 1+2+3 narrative.*
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:387:5. §6 says only one action_type but cycle.sh now has operator_notify_telegram (Round-9 introduced by Cat-δ commit) — Cat-α; align §6
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:422:**Per-agent state at Phase 4 close:**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:6:-- side effects on existing recent_edit data).
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:15:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:18:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:19:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:21:DROP INDEX IF EXISTS recent_edit_text_purged_idx;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:23:ALTER TABLE recent_edit
docs/specs/_archive-build-handoff.md:346:The Phase 2 bundles in your project files are working examples — read one (the Proposal Builder is the most complete) before writing your first new one.
docs/specs/_archive-build-handoff.md:482:Don't. Each of those is a Phase 2 of someone else's startup post-mortem. The five rules and the boundary with CortexOS are what keep this thing buildable by one person, then two, then ten.
agents/recruitment/scribe/README.md:27:Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/operations/codex-round-2-remediation-prompt.md:76:      ALTER TABLE recent_edit ALTER COLUMN original_text DROP NOT NULL;
docs/operations/codex-round-2-remediation-prompt.md:82:      ALTER TABLE recent_edit ALTER COLUMN original_text SET NOT NULL;
docs/operations/codex-round-2-remediation-prompt.md:139:      INSERT INTO decision_log (tenant_slug, agent_name, phase, payload, created_at)
docs/operations/codex-round-2-remediation-prompt.md:217:  | Week-1 prereq code | None — substrate is ATS-agnostic | DONE (Phases 1-5 landed Day 8) |
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/operations/codex-round-2-remediation-prompt.md:340:If FIX 2 added DROP NOT NULL to recent_edit.original_text, the invariant
docs/operations/codex-round-2-remediation-prompt.md:345:  Subtle case: recent_edit.original_text was originally TEXT NOT NULL in
docs/operations/codex-round-2-remediation-prompt.md:520:    - tenancy-invariants.md §2 T1: recent_edit.original_text nullability
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:383:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:390:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:404:    'concierge_last_poll',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:405:    'concierge_send_window'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:416:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:448:  IF c ? 'concierge_last_poll' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:449:    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:450:      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:458:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:460:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:461:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:38:- **Subtle case:** `recent_edit.original_text` was originally `TEXT NOT NULL` in v0.2; v0.3 (post Round-2 remediation) drops that NOT NULL constraint to allow PII purge to set `original_text=NULL`. This does not weaken T1: `recent_edit.tenant_slug` remains `TEXT NOT NULL`.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:86:### T5 — `ifos_app` role has no DELETE on `decision_log` or `recent_edit` (append-only audit tables)
docs/architecture/tenancy-invariants.md:88:- **Definition:** The two audit tables (`decision_log` from Day-4 + `recent_edit` from v0.2) are structurally append-only. Even if app code attempted DELETE, the role lacks permission.
docs/architecture/tenancy-invariants.md:90:- **Documentation source:** Day-4 §6.3 line 764 (`GRANT SELECT, INSERT ON decision_log TO ifos_app`) + v0.2 §6 line 172 (`GRANT SELECT, INSERT ON recent_edit TO ifos_app`).
docs/architecture/tenancy-invariants.md:94:  WHERE grantee='ifos_app' AND table_name IN ('decision_log','recent_edit')
docs/architecture/tenancy-invariants.md:97:  Expected: 4 rows total — `decision_log` × {SELECT, INSERT}, `recent_edit` × {SELECT, INSERT}. No UPDATE or DELETE.
docs/architecture/tenancy-invariants.md:206:| T5 | Partial → Verified | Day-4 §6.3 GRANT inspection + tenancy audit | Day-4 §6.3 documented; pending adversarial in Day-9 | Decision_log + recent_edit confirmed |
docs/architecture/tenancy-invariants.md:209:| T8 | Partial → Verified | Renderer source `renderer.ts` + tenancy audit | Phase 2 commit `3c16d35`; pending Day-9 functional verify | .env chmod 0600 |
docs/architecture/tenancy-invariants.md:210:| T9 | Partial → Verified | `common-base.json` schema + tenancy audit | Phase 1 commit `a279226` (schema); pending Day-9 adversarial | Slug pattern validation |
docs/architecture/tenancy-invariants.md:212:| T11 | **VERIFIED** | Day-4 §7 RLS isolation gate (5/5 conditions) + Phase 2 stress test | 2026-05-17 Day-4 | The only adversarially-verified invariant; foundation of the layered defence |
docs/architecture/tenancy-invariants.md:213:| T12 | Partial → Verified | grep audit + code review | Phase 1 + Phase 3 + Phase 5 commits; pending Day-9 audit grep | Tenant-agnostic helpers |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:20:**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:62:## D3 — v0.2 recent_edit PII retention
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:70:**Real issue:** `recent_edit.original_text` + `edited_text` are CAPPED at 8192 chars but otherwise stored verbatim. The agent's draft AND the consultant's edited version. Both can contain PII (candidate names, salaries, contact info). Indefinite retention for LoRA SFT training. UK GDPR Art. 5(1)(e) "data minimisation" arguably requires bounded retention.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:5:-- Authored:     2026-05-20 (Phase 4 of bubbly-snuggling-lantern.md plan)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:7:--               Phase 5 executes against migration-test tenant first.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:138:-- §5 — Create recent_edit table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:141:CREATE TABLE IF NOT EXISTS recent_edit (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:145:  action_type            TEXT        NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:151:  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:160:CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:161:CREATE INDEX IF NOT EXISTS recent_edit_tenant_action_idx ON recent_edit (tenant_slug, action_type, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:162:CREATE INDEX IF NOT EXISTS recent_edit_lookback_idx ON recent_edit (tenant_slug, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:164:ALTER TABLE recent_edit ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:165:ALTER TABLE recent_edit FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:166:DROP POLICY IF EXISTS recent_edit_tenant_isolation ON recent_edit;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:167:CREATE POLICY recent_edit_tenant_isolation ON recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:173:-- Append-only for recent_edit (mirrors decision_log discipline from Day-4 §6.3).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:180:GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:185:GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:202:--   ALTER TABLE recent_edit OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:206:--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:283:-- This lets Phase 5 voice-loader.sh return a defined-empty result rather
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
docs/specs/PRODUCT-SPEC.md:355:Every agent's `config.schema.json` follows the same pattern (we already have this for Phase 2 agents). The cross-agent shared keys live in `common-*.json` shared schemas:
docs/operations/codex-ratification-execution-plan.md:15:- **Codex catches type/build issues more reliably; Claude catches semantic/specification issues.** The Day-8 5-phase slice has both: TypeScript types (Codex strong) + design-doc consistency (Claude strong).
docs/operations/codex-ratification-execution-plan.md:263:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload)
docs/operations/codex-ratification-execution-plan.md:267:  'output',                               -- phase
docs/operations/codex-ratification-execution-plan.md:356:**Founder bias documented (carry-forward from Day-7 manifest):** Option C (deferred) was chosen at Day-7. With the Day-8 5-phase slice landed, **revise to Option γ** — start clusters A + B + C this week; defer clusters D-I until Q1 + the live VPS migration both complete.
docs/operations/codex-ratification-execution-plan.md:360:| Phase | Cluster | Trigger |
docs/operations/codex-ratification-execution-plan.md:363:| 2 | Cluster A (8 ADRs + decisions) | After Phase 1 |
docs/operations/codex-ratification-execution-plan.md:364:| 3 | Cluster B (6 reference designs) | After Phase 2 |
docs/operations/codex-ratification-execution-plan.md:365:| 4 | Cluster C (2 schema artefacts) | After Phase 3 |
docs/operations/codex-ratification-execution-plan.md:373:Phase 1-4 are 1-2 sessions of focused work. Phases 6-9 land after live migration + Q1 LOI. Phase 10 is lazy.
agents/recruitment/scribe/agent.md:82:Each write emits one `decision_log` row: `agent_name='scribe'`, `phase='action'`, `action_type='bullhorn_scribe_field_write'`, `tier='yellow'`, payload includes confidence per field + transcript timestamp anchors.
agents/recruitment/scribe/agent.md:132:     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
agents/recruitment/scribe/agent.md:234:- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
agents/recruitment/scribe/agent.md:277:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:290:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
agents/recruitment/scribe/agent.md:324:| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
agents/recruitment/scribe/agent.md:337:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/scribe/agent.md:340:- Codex Round 4 Phase 2 ratifies
docs/architecture/architecture-cohesion-review.md:46:8. ADR-004 (3 implementation deviations from ADR-003 found during Phase 2-3 build)
docs/architecture/architecture-cohesion-review.md:60:| ADR-002 | `_shared/` helpers contract | "Week 1 work" §"For Week 1 work" → vault-concurrency.md + hook-helpers.sh | ✓ landed Phase 1 + 3 commits |
docs/architecture/architecture-cohesion-review.md:62:| ADR-003 | spec gap §2.1-A (preamble) | `packages/agent-renderer/templates/claude-md-preamble.md` | ✓ landed Phase 1 (a279226) |
docs/architecture/architecture-cohesion-review.md:63:| ADR-003 | spec gap §2.1-B (common schemas) | `packages/agents-runtime/_shared/common-*.json` | ✓ landed Phase 1 (a279226), 8 files |
docs/architecture/architecture-cohesion-review.md:64:| ADR-003 | spec gap §2.1-C (_secrets.env) | Day-4 §6.5 provisioning + renderer envFile.ts | ✓ landed Day-4 + Phase 2 |
docs/architecture/architecture-cohesion-review.md:65:| ADR-003 | renderer code | packages/agent-renderer/ | ✓ landed Phase 2 (3c16d35) |
docs/architecture/architecture-cohesion-review.md:66:| ADR-003 | `_shared/` Option γ | `agents/_shared/` + renderer copy logic | ✓ landed Phase 3 (e6e9df1) + renderer symlink |
docs/architecture/architecture-cohesion-review.md:67:| ADR-003 | failure modes / ESC catalogue | `agents/_shared/escalation-codes.md` | ✓ landed Phase 1 (a279226), 24 codes |
docs/architecture/architecture-cohesion-review.md:68:| ADR-003 | phase enum for renderer | Day-4 §6.3 CHECK constraint | **✓ landed but with deviation per ADR-004 Decision 7** — phase='render' NOT in enum; uses agent_name='_renderer' + existing phase |
docs/architecture/architecture-cohesion-review.md:69:| ADR-004 | CLI naming | `packages/agent-renderer/package.json` `bin` | ✓ landed Phase 2 |
docs/architecture/architecture-cohesion-review.md:70:| ADR-004 | symlink target | renderer.ts symlinkSync call | ✓ landed Phase 3 fix (e6e9df1) |
docs/architecture/architecture-cohesion-review.md:71:| ADR-004 | phase enum pattern | `agents/_shared/hook-helpers.sh::hh_decision_action` | ✓ landed Phase 3 |
docs/architecture/architecture-cohesion-review.md:73:| second-brain-design.md §2.6.4 | ESC_VAULT_* catalogue | escalation-codes.md | ✓ landed Phase 1 (a279226) — 4 of the 5 catalogued |
docs/architecture/architecture-cohesion-review.md:74:| vault-concurrency.md §6 | ESC wiring | hook-helpers.sh::autosend_escalate | ✓ landed Phase 3 (e6e9df1) |
docs/architecture/architecture-cohesion-review.md:76:| cortexos-primitive-status.md | primitive 1 (PTY) stability | Risk #1 in RISK-REGISTER.md | ✓ logged + stress-tested Phase 2 |
docs/architecture/architecture-cohesion-review.md:93:| A6 | **Voice corpus chunks fit in pgvector memory at v1.0 scale.** HNSW index assumes per-tenant chunk count < 10K. | Phase 4 v0.2 supplement + voice-loader.sh queries | At 1 tenant × 5K chunks = ~30MB. 100 tenants × 5K = 3GB. Within Hetzner VPS RAM. Above 1000 tenants this becomes a real constraint. |
docs/architecture/architecture-cohesion-review.md:105:### C1 — Renderer phase enum (RESOLVED post-Round-1)
docs/architecture/architecture-cohesion-review.md:107:- **agent-bundle-renderer-design.md** (pre-Round-1) said `phase='render'` written to decision_log on renderer failure
docs/architecture/architecture-cohesion-review.md:109:- **Resolution:** ADR-004 Decision 7 (Codex Round 1 RATIFIED) + Day-8-evening remediation `2b287d3` corrected both renderer-design + ADR-003 to use `agent_name='_renderer'` + existing `phase=gating_failed|action`. **RESOLVED.**
docs/architecture/architecture-cohesion-review.md:123:### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)
docs/architecture/architecture-cohesion-review.md:126:- **v0.2 supplement** `recent_edit.original_text` + `edited_text` store agent draft + consultant edit VERBATIM (8192 cap), explicitly admitting PII can be present
docs/architecture/architecture-cohesion-review.md:127:- **Status:** This is by design — `recent_edit` is the SFT corpus source, not the operator-facing audit. But Codex Round 1 flagged it as a GDPR risk (now Risk #10).
docs/architecture/architecture-cohesion-review.md:147:| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:188:  - **A:** Codex review skill `review-agent-bundle.md` (not yet built) would catch this. Currently relies on grep audit + author discipline. Recommend: add this check to `scripts/run-tenancy-audit.sh` (Phase 1 enhancement OR Codex skill).
docs/architecture/architecture-cohesion-review.md:190:**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:202:  - **A:** `recent_edit.original_text` + `edited_text` are narrative (raw text). `tone_rule.rule_text` is natural language. `voice_corpus_chunks.text_chunk` is text. **These ARE narrative content in Postgres** — but they're indexed for retrieval, not for primary storage. The vault remains the source of truth for the original docs; Postgres holds the indexable chunked + classified copy. ✓ Acceptable hybrid.
docs/architecture/architecture-cohesion-review.md:204:**Verdict: BOUNDARY HOLDS as a conceptual guide; v0.2 introduces a documented exception (text in Postgres for retrieval).** Update second-brain-design.md to acknowledge the exception explicitly. Queue as Phase-2 follow-up to ADR-005 if needed.
docs/architecture/architecture-cohesion-review.md:229:| R3 | C4: PII retention in recent_edit | High (Risk #10) | Founder Decision D3 bundles with D2 | Founder | Pre-first-LOI |
docs/architecture/architecture-cohesion-review.md:230:| R4 | G7: Re-rendering active agent (PM2 + cortextOS coordination) | Medium | Document in tenant-lifecycle.md §"Operate" | Claude Code | Phase 2.2 of this slice (same commit chain) |
docs/architecture/architecture-cohesion-review.md:236:| R10 | G5: Multi-tenant connection pool sizing | Low | v1.1+ scale exercise | Claude Code | v1.1 design phase |
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
docs/architecture/architecture-cohesion-review.md:240:| R14 | C4 v0.2 → vault/Postgres split exception documentation | Low | Phase-2 follow-up to ADR-005 OR addendum to second-brain-design.md | Claude Code | Next architecture session |
docs/architecture/architecture-cohesion-review.md:258:2. R4-R8 documented during this slice (Phase 2.2 + Diagnostic W3)
docs/decisions/brain-ui-scope.md:4:**Status:** Proposed — revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch)
docs/decisions/brain-ui-scope.md:22:This document scopes the **v1.1 Brain UI work without committing to implementation details.** The decision deferral is by design — at v1.1 phase start, founder + Claude Code will have observed v1.0 actual wiki usage patterns and can scope sub-features and implementation choices against real evidence rather than speculation.
docs/decisions/brain-ui-scope.md:24:**Revisit trigger:** start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2 v1.1 timing). Three v1.0 observations will inform the v1.1 scoping session:
docs/decisions/brain-ui-scope.md:41:- Shows recent `decision_log` entries with phase + outcome filtering (`trigger | output | action | gating_failed | agent_handoff` per `sequencing-target.md` §5.3 + §6.5 enum extension).
docs/decisions/brain-ui-scope.md:55:**Dependency on v1.0:** wiki API live + `decision_log` populated per ADR-002 §3 Decision 3 + extended phase enum per `sequencing-target.md` §6.5.
docs/decisions/brain-ui-scope.md:158:This document is the input to v1.1 phase planning. At start of v1.1 phase:
docs/decisions/brain-ui-scope.md:229:**Proposed.** Revisit at start of v1.1 phase (estimated Q4 2026 post-v1.0 launch per Ultraplan §9 line 725 + Product Spec §9.2). At revisit, founder + Claude Code:
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:12:-- Risk register: #10 (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e))
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:14:-- This migration is ADDITIVE. Adds one nullable column to recent_edit for
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:25:-- §1 — Add text_purged_at audit column to recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:28:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:31:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:34:COMMENT ON COLUMN recent_edit.text_purged_at IS
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:39:CREATE INDEX IF NOT EXISTS recent_edit_text_purged_idx
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:40:  ON recent_edit (text_purged_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:51:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:52:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:54:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:55:  ADD CONSTRAINT recent_edit_text_purged_consistency CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:65:-- (existing JSONB shape; no new column needed) for the Phase-2 cron
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:78:--   WHERE table_name='recent_edit' AND column_name='text_purged_at';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:82:--   WHERE table_name='recent_edit' AND column_name='original_text';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:86:--   WHERE table_name='recent_edit' AND constraint_name='recent_edit_text_purged_consistency';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:90:--   WHERE tablename='recent_edit' AND indexname='recent_edit_text_purged_idx';
agents/recruitment/sourcing-scout/README.md:31:Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:16:The infrastructure for IFOS-side approval pending is **already shipped** in Phase 3 (commit `e6e9df1`):
docs/decisions/autosend-approval-bridge-spec.md:78:  - Read action_type, target, payload_hash, payload_preview from the marker
docs/decisions/autosend-approval-bridge-spec.md:79:  - Map IFOS action_type → cortextOS ApprovalCategory (autosend taxonomy)
docs/decisions/autosend-approval-bridge-spec.md:102:Mapping `{ifos_payload_hash, cortextos_approval_id, tenant_slug, action_type, created_at, resolved_at}` lives in a small SQLite database at `${CTX_FRAMEWORK_ROOT}/autosend-bridge.db` OR (cleaner) a new Postgres table `autosend_approval_mappings`:
docs/decisions/autosend-approval-bridge-spec.md:110:  action_type          TEXT NOT NULL,
docs/decisions/autosend-approval-bridge-spec.md:130:### §3.3 — IFOS action_type → cortextOS ApprovalCategory mapping
docs/decisions/autosend-approval-bridge-spec.md:132:cortextOS Primitive 4 enumerates approval categories as `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` per `packages/harness/cortextos/src/types/index.ts`. IFOS action_types from `agents/_shared/autosend-policy.yaml` map as follows:
docs/decisions/autosend-approval-bridge-spec.md:134:| IFOS action_type | cortextOS category |
docs/decisions/autosend-approval-bridge-spec.md:147:`bullhorn_placement_terminate` maps to `data-deletion` because placement termination destroys/closes a placement record; `other` remains only an explicit fallback for future action_types without a clean cortextOS category. The category is metadata for cortextOS's audit; IFOS-side semantics are preserved via the action_type field in our state table.
docs/decisions/autosend-approval-bridge-spec.md:171:`autosend_await_approval` already enforces 4h default timeout per action_type's `timeout` field in autosend-policy.yaml. If the timeout fires before operator responds:
docs/decisions/autosend-approval-bridge-spec.md:208:│   ├── categoryMapper.ts     ← IFOS action_type → cortextOS ApprovalCategory
docs/decisions/autosend-approval-bridge-spec.md:245:| A7 | category mapping table covers all 10 v1.0 orange action_types | Lint test: every orange action_type in autosend-policy.yaml has a mapping entry |
docs/decisions/autosend-approval-bridge-spec.md:268:- **Building the IFOS-side `autosend_await_approval` polling loop** — already exists in `hook-helpers.sh` (Phase 3)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:68:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:71:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:72:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:74:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:76:-- tenant_adapters config validation trigger.
docs/_supplementary/strategic-plan.md:387:**Step 3 — Phased Build (paid, starts in 72hrs)**
agents/recruitment/sourcing-scout/agent.md:6:- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist; canonical Postgres-backed v1.0 DNC source per ADR-002.
agents/recruitment/sourcing-scout/agent.md:7:- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
agents/recruitment/sourcing-scout/agent.md:20:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:113:     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
agents/recruitment/sourcing-scout/agent.md:195:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:197:     `send_to_blocked_recipient` action_type + ESC_DNC_FILTER_HIT catalogue
agents/recruitment/sourcing-scout/agent.md:200:     concierge_last_poll + concierge_send_window. Production-readiness
agents/recruitment/sourcing-scout/agent.md:255:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
agents/recruitment/sourcing-scout/agent.md:316:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Sourcing Scout.
agents/recruitment/sourcing-scout/agent.md:342:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
agents/recruitment/sourcing-scout/agent.md:363:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
agents/recruitment/sourcing-scout/agent.md:365:| Q5 | Gate B 6-of-10 metric — measured via consultant feedback (Brain UI v1.0 doesn't have feedback UX yet) | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful" → `decision_log` row via `consultant_feedback` green-tier action_type. v1.1: Brain UI button. NOTE: Bullhorn-note-based feedback is NOT a v1.0 path — Sourcing Scout is read-only on Bullhorn (no write capability); Bullhorn note creation would require tools.yaml write capability + autosend/decision logging which v1.0 explicitly excludes. |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/_supplementary/planning-phase-brief.md:1:# IntelForce AI OS — Planning Phase Execution Brief
docs/_supplementary/planning-phase-brief.md:2:**The split between what you produce in chat with me (planning) and what Claude Code builds against the plans (building), plus the exact sequence for completing the planning phase.**
docs/_supplementary/planning-phase-brief.md:10:**Planning phase (you + me, in chat) produces 89 of the 95 artifacts:**
docs/_supplementary/planning-phase-brief.md:18:**Building phase (Claude Code + dev hire) takes those specs and writes ~11 substantial codebases.** Claude Code doesn't write the agent prompts or the legal contracts; it writes the *software that runs the prompts and enforces the contracts*.
docs/_supplementary/planning-phase-brief.md:30:| **CC1** | **Control Plane (Next.js app)** — tenant management, billing, config wizard, dashboard, HITL approval queue, API layer | TypeScript / Next.js 14 / Postgres | Phase 3 (§3.1, 3.2, 3.10, 3.12), all of Phase 4 |
docs/_supplementary/planning-phase-brief.md:40:| **CC11** | **Agent Library Repo CI/CD** — pipelines that test, version, release agent bundles across all tenants | GitHub Actions / your agent bundles as inputs | §2.1 + all of Phase 2 bundles |
docs/_supplementary/planning-phase-brief.md:44:**Critical insight:** Claude Code cannot start CC1–CC11 cleanly until the specs they consume are written. Phase 3 specs block CC1–CC7. Phase 4 specs block CC1. Phase 2 bundles block CC11. That's why planning has to come first.
docs/_supplementary/planning-phase-brief.md:48:## 3. The 95-artifact bucket (per phase)
docs/_supplementary/planning-phase-brief.md:52:### Phase 1 — POC Stack (10 artifacts)
docs/_supplementary/planning-phase-brief.md:66:### Phase 2 — Full Agent Suite (12 artifacts)
docs/_supplementary/planning-phase-brief.md:74:### Phase 3 — Platform Engineering Specs (12 artifacts)
docs/_supplementary/planning-phase-brief.md:90:### Phase 4 — Dashboard Specs (13 artifacts) — **all P → CC1 builds**
docs/_supplementary/planning-phase-brief.md:95:### Phase 5 — Business/Commercial (15 artifacts)
docs/_supplementary/planning-phase-brief.md:114:### Phase 6 — Ops Runbooks (7 artifacts) — **all P**
docs/_supplementary/planning-phase-brief.md:117:### Phase 7 — Post-Launch Expansion (8 artifacts) — **all P, most feed later CC work**
docs/_supplementary/planning-phase-brief.md:133:**Total from now to first paying client:** ~5–6 months of serious work. That aligns with your 14-week build target *if* you parallelise: planning runs ahead 4–5 weeks, then build starts while planning continues for later-phase artifacts.
docs/_supplementary/planning-phase-brief.md:137:## 5. The planning phase, session by session
docs/_supplementary/planning-phase-brief.md:146:### Sessions 2–6 — Phase 1 POC Stack (week 1)
docs/_supplementary/planning-phase-brief.md:155:### Sessions 7–16 — Phase 2 Agent Suite (weeks 2–3)
docs/_supplementary/planning-phase-brief.md:169:### Sessions 17–28 — Phase 3 Platform Specs (weeks 4–5)
docs/_supplementary/planning-phase-brief.md:185:### Sessions 29–37 — Phase 4 Dashboard Specs (weeks 6–7)
docs/_supplementary/planning-phase-brief.md:198:### Sessions 38–48 — Phase 5 Business/Commercial (weeks 8–9)
docs/_supplementary/planning-phase-brief.md:213:### Sessions 49–55 — Phase 6 Ops Runbooks (week 10)
docs/_supplementary/planning-phase-brief.md:222:**End state of week 10:** planning phase 100% complete for v1 launch. Phase 7 (post-launch) produced as needed.
docs/_supplementary/planning-phase-brief.md:228:Claude Code can start meaningful build work as soon as Phase 3 is complete (end of week 5 on this schedule). Phases 4–6 continue alongside the build.
docs/_supplementary/planning-phase-brief.md:232:- [ ] Phases 1–3 artifacts in a private docs repo
docs/_supplementary/planning-phase-brief.md:233:- [ ] Agent library repo initialised with Phase 2 bundles
docs/_supplementary/planning-phase-brief.md:234:- [ ] Dev hire onboarded and has read every doc in Phases 1–3
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:638:**Escalation:** `ESC_RENDERER_FAILED` row written to `decision_log` Postgres table with `agent_name='_renderer'`, `phase='gating_failed'`, `payload->>'reason'='schema-validation-failure'`. (`phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — see ADR-004 Decision 7; the 5-value enum is `trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 schema migration.) If `--notify-on-failure` (default true), Telegram message to the operator with the validation path.
docs/architecture/agent-bundle-renderer-design.md:708:- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='gating_failed'` (failures) or `phase='action'` (successful renders), `payload->>'reason'` carries the reason code. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND payload->>'reason' LIKE 'ESC_RENDERER_FAILED%'`. (Per ADR-004 Decision 7: `phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — use the 5-value enum from Day-4 §6.3 + Day-5 schema migration.)
docs/operations/seedlegals-engagement-queries.md:144:6. **First cron run** — verify decision_log audit row + zero rows purged (because no recent_edit data exists yet)
docs/_archive-build-pack/08-OPEN-DECISIONS.md:3:**Questions only the founder can answer. Each has a recommendation, a recommended decision deadline (relative to Phase 0 start), and a "what blocks if undecided" note. Resolve these before the corresponding phase starts.**
docs/_archive-build-pack/08-OPEN-DECISIONS.md:32:**Deadline:** Before Phase 2 starts (the dashboard surfaces the brand prominently).
docs/_archive-build-pack/08-OPEN-DECISIONS.md:34:**Blocks if undecided:** Phase 2 design tokens import; favicon and logo work; any tweet/LinkedIn copy mentioning v2.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:38:## §3 · Telegram as a v2 channel — Phase 1 or Phase 3?
docs/_archive-build-pack/08-OPEN-DECISIONS.md:44:- Phase 1 ship: founders can already use Telegram against the dev daemon. Cool for demos, doesn't affect customers.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:45:- Phase 2 (dashboard) doesn't depend on Telegram.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:46:- Phase 3 customer-facing Telegram = needs onboarding flow ("create your bot, paste the token"), permissions model, etc.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:52:| **A. Phase 1 internal only; Phase 3 customer-facing** | Lets v2 land the brain swap without UX work on Telegram. | Telegram is a v2 differentiator; delaying it hurts the demo. |
docs/_archive-build-pack/08-OPEN-DECISIONS.md:53:| **B. Phase 2 customer-facing** | Telegram is in scope as part of the dashboard build. Demo-ready. | Adds 1 slice to Phase 2. |
docs/_archive-build-pack/08-OPEN-DECISIONS.md:54:| **C. Phase 3 customer-facing, optional Phase 1 demo** | Same as A but explicit that early demos can use the founder's bot. | Same as A. |
docs/_archive-build-pack/08-OPEN-DECISIONS.md:56:**Recommendation:** **C.** Internal-only Telegram in Phase 1 (the daemon needs it for "Phase 0 alive" anyway). Customer-facing Telegram in Phase 3 alongside per-tenant daemon spawning. Demos in the Phase 1–2 window use the founder's bot pointing at the demo tenant.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:58:**Deadline:** Before Phase 1 ends.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:60:**Blocks if undecided:** Phase 2 onboarding wizard scope.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:74:**Blocks if undecided:** Phase 3 scope sprawl.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:82:The migration script in Phase 3 needs a real (or realistic) test. Options:
docs/_archive-build-pack/08-OPEN-DECISIONS.md:89:| **D. Don't do v1 migration in v2 Phase 3 at all; new customers go straight to v2** | Phase 3 simpler; v1 customers stay on v1 until they churn or v1 sunsets | Risks indefinitely-supported v1 |
docs/_archive-build-pack/08-OPEN-DECISIONS.md:91:**Recommendation:** **B then A.** Phase 3 ships migration script against the demo tenant (B). Then once stable, a founding customer who's opted in (A) gets migrated. New customer signups from v2 launch date onward go straight to v2. No new sign-ups on v1.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:93:**Deadline:** Before Phase 3 starts.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:95:**Blocks if undecided:** Phase 3 §P3.S5 scope.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:112:**Deadline:** Before Phase 1 §P1.S3.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:114:**Blocks if undecided:** Phase 1 brain ingest implementation.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:129:**Deadline:** Before Phase 2 §P2.S1.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:148:**Deadline:** Before Phase 3 (Phase 0–2 can run locally).
docs/_archive-build-pack/08-OPEN-DECISIONS.md:150:**Blocks if undecided:** Phase 3 deployment infra.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:158:**Recommendation:** Update the sub-processor list in `intel-force-os/docs/phase-5-business-legal/legal/dpa-template.md` before v2 launches. Notify all v1 customers in writing (email is fine — DPA standard practice).
docs/_archive-build-pack/08-OPEN-DECISIONS.md:170:| Phase | Suggested |
docs/_archive-build-pack/08-OPEN-DECISIONS.md:194:**Deadline:** Phase 1 §P1.S5 area.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:218:1. At each phase boundary, bundle the phase's git diff + the relevant build-pack files
docs/_archive-build-pack/08-OPEN-DECISIONS.md:219:2. Hand to Codex with the prompt: *"Pressure-test this phase's implementation against the build pack. Surface deviations, weak abstractions, missing tests, latent bugs. Return a delta document."*
docs/_archive-build-pack/08-OPEN-DECISIONS.md:220:3. Apply Codex's delta as a final commit on the phase (with a co-author tag)
docs/_archive-build-pack/08-OPEN-DECISIONS.md:221:4. Move to the next phase
docs/_archive-build-pack/08-OPEN-DECISIONS.md:223:**Deadline:** Before Phase 0 ends.
agents/recruitment/janitor/README.md:34:Per `.codex/ratification/review-architecture-decision.md` skill. Queued for Codex Round 4 Phase 2 (Day 20).
docs/_archive-build-pack/01-RECOMMENDATION.md:122:| Phase 0 produces no customer-visible value (~1 focused session) | Unblockable. Pay it once. |
docs/_archive-build-pack/01-RECOMMENDATION.md:123:| Phase 1 also customer-invisible (brain swap) | Phase 1 produces internal validation — wiki+graphify backend running through the bus interface. |
docs/_archive-build-pack/01-RECOMMENDATION.md:124:| Duplicate maintenance window between v2 Phase 0 and customer migration | Plan for 6–10 weeks overlap. Security patches in both. Feature work only in v2. |
docs/_archive-build-pack/01-RECOMMENDATION.md:187:Then Phase 0 (`06-BUILD-PLAN.md`) starts.
docs/decisions/2026-05-18-codex-ratification-manifest.md:26:| 11 | `docs/runbooks/day-4-provisioning.md` | Executed | Verify §12 execution log (20 deviations + 8 v1.1 revisions); cross-check schema migration against decision_log.phase enum (live SQL at `c6734d1`) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:29:| 14 | Day-4 Postgres provisioning artefact | Embedded in #12 | Same review as #12 + verify 4 consolidated tightenings (entity_graph split, _secrets.env, decision_log.phase, entities.version) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:32:| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:113:Two phases:
docs/decisions/2026-05-18-codex-ratification-manifest.md:115:**Phase 1 (Day 15) — Diagnostic-only mid-week ratification.** Reason: substrate must be verified before 5 new scaffolds reference it. 6 items, all `review-architecture-decision.md` skill except the package-as-a-whole.
docs/decisions/2026-05-18-codex-ratification-manifest.md:126:**Phase 2 (Day 20) — Full Round 4: 5 new agent.md scaffolds.** Each authored Days 16-19 per goal-week-3 Steps 8-12. All `review-architecture-decision.md` skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:136:**Total Round 4 items: 11** (6 Phase 1 + 5 Phase 2). Queue grown 43 → 54 with the Day-9 + Day-11 additions counted.
docs/decisions/2026-05-18-codex-ratification-manifest.md:138:**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 6 agent.md items with the new skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:155:Remaining Phase-1 items (tools.yaml + cycle.sh + validate.sh + package + ADR-005) NOT yet attempted because they would have inherited the same skill-mismatch issue. ADR-005 should ratify cleanly under `review-architecture-decision.md` (it IS a decision doc); .sh + .yaml files may need their own skills built (defer).
docs/decisions/2026-05-18-codex-ratification-manifest.md:174:| 5 | agent-bundle-renderer-design.md | REJECTED (3 issues) | Issue 1 (status enum) + Issue 2 (phase='render' drift) + Issue 3 (CLI name drift) all **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:177:| 8 | sequencing-target.md | REJECTED (2 issues) | Issue 1 (status drift) **incorporated** at `2b287d3`. Issue 2 (phase enum cite) implicitly addressed via ADR-004 Decision 7 cross-reference. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:243:| Phase | Trigger | Estimated work |
docs/decisions/2026-05-18-codex-ratification-manifest.md:274:| **~~11~~** | **DROPPED** | (was decision_log.phase enum already executed at `c6734d1`) | n/a |
docs/decisions/2026-05-18-codex-ratification-manifest.md:288:| 9 | `brain-ui-scope.md` | Proposed pending v1.1 phase | Likely Codex ratifies as-is post-Edit 8 atomic correction (master brief §6 Day 3 line 472 + §5.5 now consistent). No founder action needed. |
docs/_archive-build-pack/06-BUILD-PLAN.md:3:**Phased slices, A/B/C-style. Each phase has a focused goal, a stack of slices, acceptance criteria, and a ratification step through Codex. The plan optimises for "ship a thing each phase that the founder can see working", not for breadth.**
docs/_archive-build-pack/06-BUILD-PLAN.md:7:## The phases at a glance
docs/_archive-build-pack/06-BUILD-PLAN.md:9:| Phase | Goal | Duration target | Ratification gate |
docs/_archive-build-pack/06-BUILD-PLAN.md:11:| **Phase 0** | Scaffold + vendor cortextOS + boot a single agent | 1 focused build session | Codex review of `03-ARCHITECTURE.md` deltas applied |
docs/_archive-build-pack/06-BUILD-PLAN.md:12:| **Phase 1** | Brain swap — replace mmrag with wiki+graphify behind the bus interface | 2–3 focused sessions | Codex review of the swap; vault ingest happy-path tested |
docs/_archive-build-pack/06-BUILD-PLAN.md:13:| **Phase 2** | Dashboard — lift v1 chrome, build brain views, build agent activity, wire approvals | 3–4 sessions | Founder review of UI; brain view passes "stunning" criteria |
docs/_archive-build-pack/06-BUILD-PLAN.md:14:| **Phase 3** | Parity + migration — port remaining v1 surfaces, run first v1→v2 migration | 2–3 sessions | A real (or simulated) v1 tenant migrated end-to-end |
docs/_archive-build-pack/06-BUILD-PLAN.md:16:Total: ~8–13 focused sessions if scope holds. The discipline is to not slip Phase 1 into Phase 2 or Phase 3 features upward.
docs/_archive-build-pack/06-BUILD-PLAN.md:20:## Phase 0 — Scaffold + vendor
docs/_archive-build-pack/06-BUILD-PLAN.md:22:**Goal:** A v2 codebase that boots a cortextOS daemon with one Orchestrator agent that can send a Telegram message saying "Phase 0 alive". No brain, no dashboard, no governance yet. Just the bones standing up.
docs/_archive-build-pack/06-BUILD-PLAN.md:32:- Commit: `chore(phase-0): monorepo scaffold`
docs/_archive-build-pack/06-BUILD-PLAN.md:40:- Commit: `chore(phase-0): vendor cortextos at <SHA>`
docs/_archive-build-pack/06-BUILD-PLAN.md:44:- `apps/daemon/src/config.ts` — defines a hard-coded "dev" tenant for Phase 0 (no DB yet)
docs/_archive-build-pack/06-BUILD-PLAN.md:46:- Commit: `feat(phase-0): daemon wrapper boots cortextos`
docs/_archive-build-pack/06-BUILD-PLAN.md:52:- Verify: Orchestrator sends a Telegram message "Phase 0 alive — <timestamp>"
docs/_archive-build-pack/06-BUILD-PLAN.md:53:- Commit: `feat(phase-0): orchestrator sends hello message`
docs/_archive-build-pack/06-BUILD-PLAN.md:59:- Commit: `feat(phase-0): db scaffold + tenants`
docs/_archive-build-pack/06-BUILD-PLAN.md:61:### Acceptance for Phase 0
docs/_archive-build-pack/06-BUILD-PLAN.md:68:- [ ] CLAUDE.md updated with "Phase 0 complete, Phase 1 next"
docs/_archive-build-pack/06-BUILD-PLAN.md:70:**Time check:** if Phase 0 is approaching 2 sessions, stop and ask why. Likely cause is environmental (PM2 setup, Telegram bot creation). Don't push through; debug the environment, then resume.
docs/_archive-build-pack/06-BUILD-PLAN.md:74:## Phase 1 — Brain swap (the centrepiece)
docs/_archive-build-pack/06-BUILD-PLAN.md:125:### Acceptance for Phase 1
docs/_archive-build-pack/06-BUILD-PLAN.md:133:- [ ] CLAUDE.md updated: "Phase 1 complete, Phase 2 next"
docs/_archive-build-pack/06-BUILD-PLAN.md:137:## Phase 2 — Dashboard
docs/_archive-build-pack/06-BUILD-PLAN.md:203:### Acceptance for Phase 2
docs/_archive-build-pack/06-BUILD-PLAN.md:210:- [ ] CLAUDE.md updated: "Phase 2 complete, Phase 3 next"
docs/_archive-build-pack/06-BUILD-PLAN.md:214:## Phase 3 — Parity + migration
docs/_archive-build-pack/06-BUILD-PLAN.md:249:### Acceptance for Phase 3
docs/_archive-build-pack/06-BUILD-PLAN.md:254:- [ ] CLAUDE.md updated: "Phase 3 complete. v2 live."
docs/_archive-build-pack/06-BUILD-PLAN.md:258:## Beyond Phase 3 (not in scope of this pack)
docs/_archive-build-pack/06-BUILD-PLAN.md:267:These are real, but not Phase 0–3. Calling them out so the implementer doesn't sneak them in.
docs/_archive-build-pack/06-BUILD-PLAN.md:271:## How phases interact with Codex
docs/_archive-build-pack/06-BUILD-PLAN.md:273:After each Phase's slices are committed:
docs/_archive-build-pack/06-BUILD-PLAN.md:276:2. Hand to Codex with the prompt: *"Pressure-test this phase's implementation against the build pack. Surface deviations, weak abstractions, missing tests, latent bugs. Return a delta document."*
docs/_archive-build-pack/06-BUILD-PLAN.md:277:3. Apply Codex's delta as a final commit on the phase
docs/_archive-build-pack/06-BUILD-PLAN.md:278:4. Move to the next phase
docs/_archive-build-pack/06-BUILD-PLAN.md:286:- **One phase at a time.** No starting Phase 2 work while Phase 1 is in flight.
docs/_archive-build-pack/06-BUILD-PLAN.md:290:- **Update CLAUDE.md at phase boundaries.** Future Claude Code sessions need to see "Phase X complete" to orient.
docs/decisions/ADR-004-renderer-implementation-deviations.md:3:**Date:** 2026-05-20 (Week 0, Day 8 — Phase-2/3 follow-up)
docs/decisions/ADR-004-renderer-implementation-deviations.md:5:**Surfaced by:** Phase-2 + Phase-3 of `~/.claude/plans/bubbly-snuggling-lantern.md` (commits `3c16d35` + `e6e9df1`)
docs/decisions/ADR-004-renderer-implementation-deviations.md:14:ADR-003 ratified the renderer design on 2026-05-16 (Day 1 evening). Phase 2 of the Week-1 product-code slice (commit `3c16d35`) implemented the renderer per ADR-003 §3.1 — TypeScript Node, `tsup` + `vitest` + `commander`, 12-row file map, atomic-write protocol. Phase 3 (commit `e6e9df1`) implemented `agents/_shared/hook-helpers.sh` and triggered an end-to-end integration test against the rendered output.
docs/decisions/ADR-004-renderer-implementation-deviations.md:35:- **`ifosctl` shim that multiplexes** (`.envrc` already declares `alias ifosctl="cortextos-ifos"`). Rejected for Phase 2 — would require building a routing shim that intercepts `render-agent` and forwards everything else. Real engineering cost; not a 10-minute alias swap. Founder can layer this on later if naming uniformity matters.
docs/decisions/ADR-004-renderer-implementation-deviations.md:61:So the relative path from the symlink's containing directory is `../../../_shared`, NOT `../../_shared`. With the ADR-003 spec verbatim, the symlink resolves to `<agent_dir>/_shared/` (INSIDE the agent dir, where no `_shared` exists) and breaks at first source. This was caught during the Phase-3 end-to-end integration test when `source .claude/hooks/_shared/hook-helpers.sh` failed with `No such file or directory`.
docs/decisions/ADR-004-renderer-implementation-deviations.md:80:- **File an upstream issue / PR against cortextOS** to filter out `_shared/` (and other underscore-prefixed names) in `listAgents()`. **Recommended path** — open an issue on the cortextOS repo per master brief §3 boundary 1 ("the submodule is a reference pin, not the runtime; upstream changes go upstream"). Phase 2 ships the deviation as documented; founder + upstream maintainer fix it on their schedule.
docs/decisions/ADR-004-renderer-implementation-deviations.md:144:**For Risk #5 (renderer-not-built).** Severity unchanged at High per ADR-003 line 145 staged ladder ("Drops to Medium once renderer code is committed AND the Diagnostic agent renders cleanly (Week 4)"). The Phase-2 commit `3c16d35` satisfies the first condition; the second condition (Diagnostic render) is gated on Q1 design-partner LOI. ADR-004 closes a stylistic gap (3 deviations) but does not change risk severity.
docs/decisions/ADR-004-renderer-implementation-deviations.md:146:**For Codex Day-7 ratification.** ADR-004 joins the queue. The 3 deviations were pre-flagged in Phase-2 and Phase-3 commit messages + `packages/agent-renderer/README.md`; this ADR consolidates them into a single ratifiable artefact. Without ADR-004, Codex would likely REJECT each deviation individually as "implementation diverges from ADR-003"; with ADR-004, the deviations are deliberately-ratified design decisions Codex either RATIFIES or REJECTS as a coherent set.
docs/architecture/cortexos-primitive-status.md:370:Full experiment lifecycle code, dedicated sprint-3 test file, fully-documented 8-phase theta-wave skill shipped in the `analyst` template. Approval-gate integration ties it back into primitive 4. Not on the v1.0 critical path — Ultraplan §3.1 row 6 already defers it to v1.1 Night Sourcer.
docs/architecture/cortexos-primitive-status.md:376:- `templates/analyst/.claude/skills/theta-wave/SKILL.md` (156 lines) — fully fleshed-out 8-phase cycle (Initiate → Deep System Scan → Evaluate Previous → Evaluate Agent Cycles → External Research → Conversation with Orchestrator → Hypothesis and Action → Score+Log+Report). References `cortextos bus manage-cycle create/modify/remove` for cycle CRUD.
docs/_archive-build-pack/02-PRODUCT-VISION.md:141:- **Microsoft Teams as primary channel** → secondary in v2. Telegram is primary. Teams gets ported in Phase 3 if/when a customer demands it.
docs/_archive-build-pack/02-PRODUCT-VISION.md:168:- Whether the Telegram interface ships in Phase 1 or Phase 3 (`08-OPEN-DECISIONS.md` §3)
agents/recruitment/janitor/agent.md:42:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold`)
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:73:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:95:     tenant_adapters.config.janitor_last_run)
agents/recruitment/janitor/agent.md:135:   → query the `recent_edit` v0.2 table directly (per vertical-schema.v0.2-supplement.yaml
agents/recruitment/janitor/agent.md:136:     §1.3): SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
agents/recruitment/janitor/agent.md:137:     AND resolution='approved_after_edit' AND tenant_slug=$tenant
agents/recruitment/janitor/agent.md:153:   → group by action_type; tally success/fail; compute Gate-B metric
agents/recruitment/janitor/agent.md:166:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:235:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:248:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ Week 3 in progress |
agents/recruitment/janitor/agent.md:275:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:292:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/janitor/agent.md:295:- Codex Round 4 Phase 2 ratifies
docs/_supplementary/execution-plan.md:2:**Every document you still need, sequenced into phases you can tick off until Claude Code has everything it needs to build.**
docs/_supplementary/execution-plan.md:4:> *This is your master checklist. Work through it top to bottom. Each artifact has a suggested prompt, its dependencies, and a rough effort estimate. When the last box in Phase 6 is ticked, you have a complete developer-ready specification.*
docs/_supplementary/execution-plan.md:13:- **Part D** — Phased Execution Plan: seven phases, every artifact as a checklist item with a prompt to generate it
docs/_supplementary/execution-plan.md:77:Before producing the artifacts in Part D, these decisions need to be made. Some change specs downstream. **Tick these off before starting Phase 1.**
docs/_supplementary/execution-plan.md:113:# PART D — PHASED EXECUTION PLAN
docs/_supplementary/execution-plan.md:115:Seven phases. Each has a goal, a checklist of artifacts, and a "done when" criterion. For each artifact: purpose, dependency, estimated effort (C = Claude session count, a single focused session), and a suggested prompt to generate it.
docs/_supplementary/execution-plan.md:117:Work linearly. Do not start Phase 2 before Phase 1 is ≥90% complete.
docs/_supplementary/execution-plan.md:121:## PHASE 1 — The Proof-of-Concept Stack (target: end of week 1)
docs/_supplementary/execution-plan.md:189:**Phase 1 Done When:** artifact 1.10 has been executed successfully with a real call. One working Proposal Builder end-to-end on real infrastructure. ~2 weeks realistic effort with 1 developer.
docs/_supplementary/execution-plan.md:193:## PHASE 2 — The Full Agent Suite (target: end of week 4)
docs/_supplementary/execution-plan.md:233:**Phase 2 Done When:** every agent bundle exists in the repo. Sales trio (Proposal Builder, Lead Hunter, Follow-Up Pilot) actually running in the test tenant. Remaining 7 agents specified but not necessarily running yet.
docs/_supplementary/execution-plan.md:237:## PHASE 3 — Platform Engineering Specs (target: end of week 7)
docs/_supplementary/execution-plan.md:313:  - *Depends on:* Dashboard specs (Phase 4), but this spec can be written in parallel
docs/_supplementary/execution-plan.md:317:**Phase 3 Done When:** every spec in §3 is committed to docs repo. The Provisioning System is actually operational. The Wizard UX is in Figma or coded.
docs/_supplementary/execution-plan.md:321:## PHASE 4 — Dashboard Production Build (target: end of week 9)
docs/_supplementary/execution-plan.md:393:**Phase 4 Done When:** all 13 specs written, design system codified as CSS variables, first 5 views (Home, Activity, Brain, Approvals, Agents) actually built and deployed to a staging environment.
docs/_supplementary/execution-plan.md:397:## PHASE 5 — Business & Commercial Artifacts (target: end of week 11)
docs/_supplementary/execution-plan.md:474:**Phase 5 Done When:** legal docs signed off by solicitor, marketing site live (can be static HTML), first 50 cold outbound emails sent.
docs/_supplementary/execution-plan.md:478:## PHASE 6 — Operations & Launch Readiness (target: end of week 13)
docs/_supplementary/execution-plan.md:506:  - *Depends on:* 3.12-equivalent for Agency Partner, Phase 7 eventually
docs/_supplementary/execution-plan.md:520:**Phase 6 Done When:** first founding customer live for 30+ days without catastrophic issue, all learnings fed back into the playbooks.
docs/_supplementary/execution-plan.md:524:## PHASE 7 — Post-Launch Expansion (months 4–6)
docs/_supplementary/execution-plan.md:566:**Phase 7 Done When:** first vertical pack deployed to 3+ clients. Voice Receptionist live with first dental client. Agency Partner program has closed its first partner.
docs/_supplementary/execution-plan.md:575:Then work **phases in strict order.** Phase 2 cannot start productively before Phase 1 proves the runtime. Phase 3 can't be finalised without Phase 2's agents being real.
docs/_supplementary/execution-plan.md:577:Within a phase, order items by the dependency markers. 1.1 before 1.4 before 1.6. Unblock parallel tracks where the *Depends on* line has nothing upstream.
docs/_supplementary/execution-plan.md:582:Total effort estimate across all 7 phases: **~135 C sessions.**
docs/_supplementary/execution-plan.md:599:The single biggest risk to this plan is you reading the Build Plan again, getting excited about some new idea, and bolting a 47th agent onto the spec. **Freeze scope at the end of Phase 3.** Anything new goes into "v1.1 backlog" — a single markdown file you add ideas to. You look at that backlog quarterly, not weekly.
docs/_supplementary/execution-plan.md:611:- [ ] Every artifact in Phases 1–3 is committed to a private docs repo
docs/_supplementary/execution-plan.md:612:- [ ] The dev hire is onboarded and has read every doc in Phases 1–3
docs/_supplementary/execution-plan.md:614:- [ ] The MSA + DPA from Phase 5 are drafted (don't need to be solicitor-signed yet)
docs/_supplementary/execution-plan.md:617:- [ ] The first agent library repo exists with Phase 2 bundles committed
docs/_supplementary/execution-plan.md:619:When all seven boxes above are ticked: Claude Code has every input it needs. The remaining Phases 4–7 happen alongside and after the build, not before.
docs/_supplementary/execution-plan.md:622:**Do not produce these in order just to feel productive.** The only artifact that matters in the first 3 weeks is 1.10 — the Week-1 Experiment Runbook, executed successfully. Everything in Phases 2–7 is worthless if that fails.
docs/_supplementary/execution-plan.md:624:Produce Phase 1 in order. Stop. Execute 1.10. Only then continue.
docs/_supplementary/execution-plan.md:630:| Phase | Artifacts | Effort (C) | Weeks | Blocks on |
docs/_supplementary/execution-plan.md:634:| **2. Full Agent Suite** | 12 artifacts | ~30C | Weeks 3–4 | Phase 1 done |
docs/_supplementary/execution-plan.md:635:| **3. Platform Specs** | 12 artifacts | ~27C | Weeks 5–7 | Phase 2 agents specified |
docs/_supplementary/execution-plan.md:636:| **4. Dashboard Build** | 13 artifacts | ~15C | Weeks 8–9 | Phase 3 done |
docs/_supplementary/execution-plan.md:638:| **6. Ops Runbooks** | 7 artifacts | ~7C | Weeks 12–13 | Phases 1–5 done |
docs/_supplementary/execution-plan.md:639:| **7. Post-Launch** | 8 artifacts | ~18C | Months 4–6 | Phase 6 done |
docs/_supplementary/execution-plan.md:648:You have strategy, architecture, and a working prototype. You are missing the *stuff a developer actually reads* — 95 discrete documents and decisions, organised into 7 sequenced phases. Start with the 18 Open Decisions this week. Then Phase 1's 10 artifacts until one real Proposal Builder works end-to-end. Then Phase 2's 12 agent bundles. Then Phase 3's 12 platform specs. By week 7 you have everything Claude Code needs to build; Phases 4–7 happen in parallel with and after the build. Tick boxes. Resist scope creep. Ship.
docs/decisions/sequencing-target.md:351:5. **Founder explicit sign-off** recorded in `decision_log` with `phase='agent_handoff'`, `agent_name='_sequencing'`, `entity_id='<N>->_<N+1>'`, `metadata` carrying the §5.2-row evidence summary.
docs/decisions/sequencing-target.md:371:1. **Surface** in `decision_log` with `phase='gating_failed'`, `agent_name='_sequencing'`, `entity_id='<N>->_<N+1>'`, `metadata` carrying which gate(s) failed.
docs/decisions/sequencing-target.md:376:**New `decision_log` `phase` values introduced by this document:** `gating_failed`, `agent_handoff`. The Postgres decision_log table column `phase` (per `second-brain-design.md` §2.4.2 schema) currently lists only `trigger | output | action` per ADR-002 Decision 3. **Spec gap §5-A** flagged for Day 4 Postgres provisioning: extend the `phase` column's accepted values to include the two new ones. Schema migration is a one-line `CHECK` constraint update.
docs/decisions/sequencing-target.md:390:- Postgres provisioning Day 4 with `entities` + `entity_links` split + `_secrets.env` skeleton + (now) extended `phase` enum.
docs/decisions/sequencing-target.md:424:The `decision_log` schema must support `phase='gating_failed'` and `phase='agent_handoff'` per §5.3 Spec gap §5-A. Day 4 Postgres provisioning script needs the extended `CHECK` constraint:
docs/decisions/sequencing-target.md:428:  ADD CONSTRAINT decision_log_phase_check
docs/decisions/sequencing-target.md:429:  CHECK (phase IN ('trigger', 'output', 'action', 'gating_failed', 'agent_handoff'));
docs/decisions/sequencing-target.md:451:- Spec gap §5-A (decision_log phase enum extension) is queued for Day 4 implementation, not deferred.
docs/decisions/sequencing-target.md:509:| `decision_log.phase` enum extended to include `gating_failed` + `agent_handoff` per §5.3 / §6.5 | Claude Code | Day 4 Postgres provisioning | **NEW from this document** Spec gap §5-A |
docs/_archive-build-pack/README.md:15:| **v2 codebase (this build)** | `/Users/madsadmin/code/CortexOS/` | Empty scaffold from 10 May — `CLAUDE.md` stub + `.claude/settings.json` + git initialised. Phase 0 starts here. |
docs/_archive-build-pack/README.md:60:Pack + cortextOS source + v1 source. Pressure-test §03 / §04 / §05. Return a delta document. Claude Code applies the delta before Phase 0.
docs/_archive-build-pack/README.md:74:| `06-BUILD-PLAN.md` | Phase 0 (scaffold + vendor) → Phase 1 (brain swap) → Phase 2 (dashboard + agents) → Phase 3 (parity + migration). Acceptance criteria. |
docs/_archive-build-pack/README.md:95:v1 was over-specified and under-shipped. v2 must not repeat that. Pack exists to bridge spec → execution, not extend spec. Once Phase 0 acceptance is met (`06-BUILD-PLAN.md`), the pack is reference, not active reading.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:24:- `packages/agent-renderer/` (Phase 2, commit `3c16d35`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:25:- `agents/_shared/hook-helpers.sh` + `autosend-policy.yaml` (Phase 3, commit `e6e9df1`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:26:- `vertical-schema.v0.2-supplement.yaml` (Phase 4, commit `45b59e0`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:27:- `agents/_shared/voice-loader.sh` (Phase 5, commit `fe56e93`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:40:| Week-1 prereq code | None — substrate is ATS-agnostic | DONE (Phases 1-5 landed Day 8) |
packages/harness/cortextos/src/daemon/cron-scheduler.ts:260:   * restarts (see PHASE5-FAILURE-MODES-REPORT.md for design rationale).
packages/agents-runtime/_shared/common-voice.json:5:  "description": "Per-tenant voice corpus reference. Read by agents/_shared/voice-loader.sh per master brief §8.1 Change 1. Schema substrate landed in vertical-schema.yaml v0.2 (Phase 4).",
packages/agents-runtime/_shared/common-voice.json:35:    "recent_edits_lookback_days": {
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
docs/architecture/vault-concurrency.md:3:**Status:** Reference (no Proposed/Accepted lifecycle). Synthesis of `docs/architecture/second-brain-design.md` §2.6 + `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` Decisions 2-3 + `docs/decisions/sequencing-target.md` §5-A `decision_log.phase` extension.
docs/architecture/vault-concurrency.md:192:- If second attempt also fails: raise `ESC_VAULT_VERSION_MISMATCH`, record in `decision_log` with `phase='gating_failed'` per `sequencing-target.md` §5-A enum extension, log human-readable error to operator Telegram per primitive 5 escalation surface.
docs/architecture/vault-concurrency.md:381:**V1.0 mitigation:** surface partial failure as `ESC_VAULT_CASCADE_PARTIAL_FAILURE` carrying the list of `failures` (referencing entities whose markdown bodies were not rewritten). Record in `decision_log` with `phase='gating_failed'`, `metadata` containing the failures list. **Founder reviews and manually reconciles** — for each failure, run the rewrite by hand (most edits are small) or accept temporary inconsistency until next operation through that entity.
docs/architecture/vault-concurrency.md:389:**V1.0 cascade timeout: 30 seconds** (`CASCADE_TIMEOUT_MS = 30_000`). If exceeded, raise `ESC_VAULT_CASCADE_TIMEOUT` with `failures.length` (entities not yet rewritten) and `refs.length` (total cascade size). Decision_log entry per `phase='gating_failed'`. **Founder reviews** — for large cascades (>30s), the rename is structurally expensive and may warrant rescheduling to off-hours.
docs/architecture/vault-concurrency.md:397:**Status update 2026-05-20 (Day 8 Codex Round 1):** all 5 codes below are now catalogued at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`, Phase 1 of Week-1 slice) AND wired into the `autosend_escalate` helper at `agents/_shared/hook-helpers.sh` (commit `e6e9df1`, Phase 3 of Week-1 slice). The "_shared/hook-helpers.sh Week-1 prereq must wire these 5 codes" language below has been satisfied — current state is shipped + tested.
docs/architecture/vault-concurrency.md:401:| Code | Trigger | Decision_log phase | Operator surface |
docs/architecture/vault-concurrency.md:441:The `entities.version` column is a new Day-4 tightening — joins the three already on the list per `sequencing-target.md` §6.5 (entity_graph split + `_secrets.env` + `decision_log.phase` enum extension). Day-4 task now has **4 consolidated tightenings**.
docs/decisions/bullhorn-integration-path.md:103:| Week-1 prereq code | None — substrate is ATS-agnostic | DONE (Phases 1-5 landed Day 8) |
agents/recruitment/diagnostic/fixtures/01-primary.yaml:98:  - phase: trigger
agents/recruitment/diagnostic/fixtures/01-primary.yaml:101:  - phase: output
agents/recruitment/diagnostic/fixtures/01-primary.yaml:104:  - phase: action
agents/recruitment/diagnostic/fixtures/01-primary.yaml:106:    action_type: diagnostic_report_render
agents/recruitment/diagnostic/fixtures/01-primary.yaml:108:  - phase: action
agents/recruitment/diagnostic/fixtures/01-primary.yaml:110:    action_type: diagnostic_cleanup
docs/_archive-build-pack/03-ARCHITECTURE.md:44:│   ├── agents/                        (Plan, Explore, phase-architect subagent specs)
docs/_archive-build-pack/03-ARCHITECTURE.md:45:│   └── commands/                      (slash commands — /load-phase, /search-specs, etc.)
docs/_archive-build-pack/03-ARCHITECTURE.md:136:│   └── docs/                          ← public docs site (deferred to Phase 3)
docs/_archive-build-pack/03-ARCHITECTURE.md:253:One daemon process per tenant in production. Each daemon manages its agents' PTY sessions. Multi-tenancy is process-level isolation, not row-level — same pattern v1 was moving toward in Phase 3 spec.
docs/_archive-build-pack/03-ARCHITECTURE.md:516:- Does not preserve v1's Teams-first channel posture. Teams comes in Phase 3 if a customer demands it.
docs/_archive-build-pack/03-ARCHITECTURE.md:523:Before Phase 0 starts:
docs/_archive-build-pack/03-ARCHITECTURE.md:530:- [ ] Codex reviews this file and returns a delta — applied before Phase 0 codes
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:45:Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
docs/decisions/autosend-safety-policy.md:49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
docs/decisions/autosend-safety-policy.md:79:| Agent | action_type | Why green |
docs/decisions/autosend-safety-policy.md:90:| Agent | action_type | Sample rate | Why yellow |
docs/decisions/autosend-safety-policy.md:100:| Agent | action_type | Why orange |
docs/decisions/autosend-safety-policy.md:115:| action_type | block_reason | Why red |
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:143:#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
docs/decisions/autosend-safety-policy.md:148:  local action_type="$1"
docs/decisions/autosend-safety-policy.md:159:  tier=$(autosend_policy_lookup "$action_type") || {
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:161:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
docs/decisions/autosend-safety-policy.md:166:  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:168:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
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
docs/decisions/autosend-safety-policy.md:215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
docs/decisions/autosend-safety-policy.md:219:action_types:
docs/decisions/autosend-safety-policy.md:229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
docs/decisions/autosend-safety-policy.md:245:  "action_type": "<enum from autosend-policy.yaml>",
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:262:5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:288:  "action_type": "<enum>",
docs/decisions/autosend-safety-policy.md:300:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
docs/decisions/autosend-safety-policy.md:304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
docs/decisions/autosend-safety-policy.md:326:  "action_type": "<enum, may be unknown>",
docs/decisions/autosend-safety-policy.md:330:  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:341:4. Root cause + fix applied (e.g., add missing `action_type` to policy, repair table corruption, fix override format)
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
docs/decisions/autosend-safety-policy.md:373:--   phase TEXT CHECK IN ('trigger','output','action','gating_failed','agent_handoff')
docs/decisions/autosend-safety-policy.md:380:--   phase = 'action'         when allowed (green/yellow/orange-approved)
docs/decisions/autosend-safety-policy.md:381:--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
docs/decisions/autosend-safety-policy.md:385:--     "action_type": "<enum>",
docs/decisions/autosend-safety-policy.md:402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
docs/decisions/autosend-safety-policy.md:462:2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
docs/decisions/autosend-safety-policy.md:466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:485:### v1.1 phases in
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:491:### v1.2+ phases in
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
docs/decisions/autosend-safety-policy.md:621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
docs/decisions/autosend-safety-policy.md:624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:66:### §0.3 — `decision_log.phase` enum: 5 values, not more
docs/runbooks/day-4-provisioning.md:68:**Authoritative sources for the `phase` enum:**
docs/runbooks/day-4-provisioning.md:75:The runbook applies exactly these. **Do not invent additional phase values during execution** (e.g., `session_start`, `tool_call`, `escalation`) unless a Codex-ratified change to either master brief §8.1 or `sequencing-target.md` §5-A pre-dates the migration. Speculative additions break the schema-before-code rule.
docs/runbooks/day-4-provisioning.md:749:-- decision_log (per ADR-002 §3 Decision 3; phase enum per §6.4 below = Tightening 3)
docs/runbooks/day-4-provisioning.md:754:  phase TEXT NOT NULL,
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:784:CREATE TABLE tenant_adapters (
docs/runbooks/day-4-provisioning.md:795:GRANT SELECT, INSERT, UPDATE, DELETE ON tenant_adapters TO ifos_app;
docs/runbooks/day-4-provisioning.md:796:GRANT USAGE, SELECT ON SEQUENCE tenant_adapters_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:804:### §6.4 — Tightening 3: `decision_log.phase` enum constraint
docs/runbooks/day-4-provisioning.md:811:ADD CONSTRAINT decision_log_phase_check
docs/runbooks/day-4-provisioning.md:812:CHECK (phase IN (
docs/runbooks/day-4-provisioning.md:908:\d tenant_adapters
docs/runbooks/day-4-provisioning.md:915:# - decision_log has the phase CHECK constraint     (Tightening 3)
docs/runbooks/day-4-provisioning.md:936:ALTER TABLE tenant_adapters ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:943:ALTER TABLE tenant_adapters FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:971:CREATE POLICY tenant_isolation ON tenant_adapters
docs/runbooks/day-4-provisioning.md:1127:- [ ] §6.3 — Six tables exist: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:1130:- [ ] §6.4 (Tightening 3) — `decision_log_phase_check` constraint present with exactly 5 values
docs/runbooks/day-4-provisioning.md:1156:| §6.4 constraint | CHECK constraint fails to add | `ALTER TABLE decision_log DROP CONSTRAINT decision_log_phase_check;` then retry — most common cause is pre-existing rows violating the check, but the table is empty at this point so unusual |
docs/runbooks/day-4-provisioning.md:1248:17. **§7 — RLS isolation gate passed clean (5 of 5).** No-context = 0 ✓, own-tenant insert+select = 1 ✓, cross-tenant = 0 ✓, WITH CHECK adversarial INSERT rejected ✓, own-tenant unaffected = 1 ✓. RLS + FORCE on entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters (5 tables). `tenant_isolation` policy on all 5 with USING + WITH CHECK on `current_setting('app.current_tenant', true)`. Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser, which would bypass RLS). Test data ROLLBACK'd; 2 seeded test tenants cleaned up.
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:96:  - phase: trigger
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:98:  - phase: output
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:100:  - phase: action
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:101:    action_type: diagnostic_report_render
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:508:| `phase-2-agent-suite/_shared/hook-helpers.sh` | Common validate/telemetry shell fns | `packages/agents-runtime/_shared/hooks/hook-helpers.sh` | Add `hh_decision_trigger/output/action` per Ultraplan §4.2 |
docs/build-brief/00-MASTER-BRIEF.md:509:| `phase-2-agent-suite/_shared/escalation-codes.md` | Escalation codes | `packages/agents-runtime/_shared/escalation-codes.md` | Expand to recruitment vocabulary |
docs/build-brief/00-MASTER-BRIEF.md:510:| `phase-2-agent-suite/_shared/universal-banned-phrases.txt` | AI-tell phrases | `packages/agents-runtime/_shared/universal-banned-phrases.txt` | Verbatim |
docs/build-brief/00-MASTER-BRIEF.md:511:| `phase-1-poc-stack/platform-specs/minimal-vault-structure.md` | Vault layout | `docs/architecture/vault-structure.md` | Update to recruitment frontmatter schema |
docs/build-brief/00-MASTER-BRIEF.md:512:| `phase-1-poc-stack/platform-specs/webhook-receiver-spec.md` | Fastify webhook router | `packages/webhook-receiver/` | Routing logic adapted to bus-drop instead of Unix socket |
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:663:        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
docs/build-brief/00-MASTER-BRIEF.md:893:**Phase:** pre-Phase-0. Founder must clear Week 0 checklist
docs/build-brief/00-MASTER-BRIEF.md:932:- Don't skip Codex ratification at phase boundaries
packages/harness/cortextos/templates/orchestrator/ONBOARDING.md:558:# Use the same user ID from your own .env (ORCH_USER_ID from Phase 6a setup).
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:9:You said the goal is to one-shot this with Claude Code + Codex ratification. "One-shot" doesn't mean a single chat turn. It means **the build proceeds without architectural re-litigation**. Phase boundaries are gates; inside a phase, slices execute against the pack. Codex catches what Claude Code missed; Claude Code catches what Codex missed.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:29:**During Phase 1 §P1.S3 (ingest pipeline):** open `~/.claude/skills/graphify/SKILL.md` first, then implement. Don't reinvent. Adapt.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:37:**During Phase 1 §P1.S6 (wiki rendering):** read the wiki-brain skill's implementation. Adopt the markdown conventions, backlink computation, and folder structure. The customer-facing brain should look identical to wiki-brain visually because that's what the founder said "looks stunning" means.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:43:| `cloudflare-intel-force` | Phase 3 if/when we deploy any Cloudflare components |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:44:| `phase-3-platform` | Reference for multi-tenancy patterns — informs §3 of architecture |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:45:| `phase-4-dashboard` | Reference for dashboard build — informs Phase 2 |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:47:| `bot-framework-teams` | Reference if Phase 3 §P3.S4 (Teams adapter) ships |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:48:| `frontend-design` | Phase 2 — the brain view "looks stunning" criterion |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:55:- **`cortextos-bus`** — the file-bus interface, all 47 scripts, when to override vs augment vs keep. Lives at `.claude/skills/cortextos-bus/SKILL.md`. Phase 0 deliverable.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:56:- **`brain-package`** — the wiki+graphify brain's architecture, ingest pipeline, query layer, vault layout. Lives at `.claude/skills/brain-package/SKILL.md`. Phase 1 deliverable.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:57:- **`v2-build-pack`** — pointer to `/Users/madsadmin/code/CortexOS/docs/build-pack/` and how to use it. Lives at `.claude/skills/v2-build-pack/SKILL.md`. Phase 0 deliverable.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:67:| **Plan** | At every phase boundary. Before P1, run a Plan agent to scope the brain swap. Before P2, run Plan for the dashboard. Plan returns a structured slice list — compare against the build pack's slices to catch what's missing. |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:68:| **Explore** | Phase 1 §P1.S3 (where does cortextOS call kb-* scripts from internally? Explore: "find every call site of `bus/kb-query.sh` across cortex-os-upstream"). Phase 2 §P2.S2 (where in v1 is every primitive component?). |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:69:| **phase-architect** | Use at phase boundaries to pressure-test your implementation against the spec. "Phase-architect: review Phase 1's brain package against `03-ARCHITECTURE.md` and `04-DATA-MODEL.md`. Surface deviations." Equivalent of Codex internal to Claude Code. |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:71:| **vercel:nextjs**, **vercel:vercel-functions** | Phase 2 dashboard scaffold. |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:72:| **vercel:ai-sdk** | Phase 1 brain ingest — if we use AI SDK for entity extraction. |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:73:| **vercel:vercel-storage** | Phase 3 R2/vault wiring. |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:83:- `cloudflare-docs` — useful for Phase 3 if we deploy to Cloudflare
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:93:| **postgres-mcp** | Direct SQL queries against the v2 Postgres for debugging during Phases 1–3 | github.com/modelcontextprotocol/servers |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:98:Configure in `/Users/madsadmin/code/CortexOS/.claude/settings.json` during Phase 0 §P0.S1.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:109:- `/load-phase <n>` — load phase-specific context
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:122:- **`/codex-bundle <phase>`** — bundle the phase's git diff + relevant build-pack files into a single text file ready to paste into Codex.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:123:- **`/phase-gate <n>`** — runs all acceptance criteria checks for Phase n. Output: which check passed, which failed, what to fix.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:125:Build during Phase 0 §P0.S1.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:133:### 5.1 Memories to seed at Phase 0 start
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:143:Seed all of these in Phase 0 §P0.S1.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:147:- At each phase boundary, add a `project_phase_<n>_outcome.md` recording what shipped + what slipped + the Codex delta applied
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:161:| Daily (during Phase 1) | "Run `pnpm test --filter brain` and surface failures" | Catches regressions in the brain package |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:162:| One-time, 2 weeks after Phase 0 ships | "Open a Codex-review PR for Phase 0 artifacts" | Forces the Codex ratification step to actually happen |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:165:Set these up via `/schedule` once Phase 0 ships.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:171:Use Plan mode at every phase boundary. Concretely:
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:174:Phase 0 start:  Plan mode → "Scope Phase 0 from build pack §06"
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:175:Phase 1 start:  Plan mode → "Scope Phase 1 brain swap from build pack §06 + §03 §6"
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:176:Phase 2 start:  Plan mode → "Scope Phase 2 dashboard from build pack §06 + §03 §7"
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:177:Phase 3 start:  Plan mode → "Scope Phase 3 parity + migration from build pack §06 + §04 §8"
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:228:### What it should contain (after Phase 0)
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:241:## Current phase
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:242:[Phase 0 / 1 / 2 / 3] — see docs/build-pack/06-BUILD-PLAN.md.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:251:- Codex review at every phase boundary
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:258:- Skip the Codex ratification step at phase boundaries
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:264:Update CLAUDE.md at every phase boundary to reflect the new state.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:270:Concretely, the ratification ritual at each phase boundary:
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:273:1. Claude Code finishes the phase's slices, commits.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:274:2. Run /codex-bundle <phase> (slash command from §4.2) → produces docs/codex-bundles/phase-<n>.md
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:275:   Contents: git diff for the phase + relevant build-pack sections
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:276:3. Paste docs/codex-bundles/phase-<n>.md into Codex (web or CLI)
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:279:6. Apply the changes — typically a single commit `chore(phase-<n>): codex review delta`
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:280:7. Update CLAUDE.md to mark the phase complete
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:281:8. Move to next phase
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:298:If you remember one thing from this file: **the wiki-brain skill at `~/.claude/skills/wiki-brain/SKILL.md` is the prior art for the entire Phase 1 brain swap.** Read it before Phase 1 §P1.S3 starts. It will save days of design.
docs/runbooks/pii-purge-operational-pattern.md:5:**Authority:** Surfaces UK GDPR Art. 5(1)(e) data-minimisation compliance for `recent_edit` text fields. Companion to `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D3 + Risk #10 in `docs/RISK-REGISTER.md`.
docs/runbooks/pii-purge-operational-pattern.md:15:`recent_edit` rows store the agent's draft (`original_text`) and the consultant's edited version (`edited_text`) verbatim, length-capped at 8192 chars per field. Per v0.2 supplement §1, these can contain PII (candidate names, salaries, contact info).
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:39:`recent_edit` table extended via `v0.2-to-v0.3-pii-purge.sql`:
docs/runbooks/pii-purge-operational-pattern.md:42:ALTER TABLE recent_edit
docs/runbooks/pii-purge-operational-pattern.md:47:ALTER TABLE recent_edit ADD CONSTRAINT recent_edit_text_purged_consistency CHECK (
docs/runbooks/pii-purge-operational-pattern.md:97:3. SELECTs count(*) from `recent_edit` WHERE `resolved_at < now() - interval '<N> days' AND original_text IS NOT NULL`
docs/runbooks/pii-purge-operational-pattern.md:100:6. Audit row to `decision_log`: `agent_name='_pii_purger'`, `phase='gating_failed'`, `outcome='purged'`, payload has `rows_purged` + `tenants_touched` + `retention_days` + invocation_time
docs/runbooks/pii-purge-operational-pattern.md:113:| `action_type` | populated | populated (preserved) |
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:149:**Implementation note:** `scripts/ifos-pii-purge.sh` v0.1 uses a single `--retention-days` CLI arg for all tenants. Per-tenant override support is a Phase-2 cron enhancement (lands when first tenant requests extended retention; founder TOS amendment + advisor input on the requested duration).
docs/runbooks/pii-purge-operational-pattern.md:171:SELECT count(*) FROM recent_edit
docs/runbooks/pii-purge-operational-pattern.md:198:| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
docs/architecture/second-brain-design.md:34:- `analyst/.claude/skills/theta-wave/SKILL.md` (156 lines) — zero `kb-*` invocations. Phase 2 "Deep System Scan" reads `MEMORY.md`, experiment files, event logs, GOALS.md directly (lines 31-40).
docs/architecture/second-brain-design.md:548:  phase             TEXT NOT NULL,                       -- one of {trigger, output, action}
docs/architecture/second-brain-design.md:550:  trigger_source    TEXT,                                -- for phase=trigger: webhook | cron | bus-message | telegram
docs/architecture/second-brain-design.md:551:  output_artefact   TEXT,                                -- for phase=output: filesystem path or message id of produced output
docs/architecture/second-brain-design.md:552:  human_action      TEXT,                                -- for phase=action: one of {send-as-is, edit-then-send, reject, ignore}
docs/architecture/second-brain-design.md:553:  human_diff        TEXT,                                -- for phase=action=edit-then-send: the diff captured for voice corpus
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
packages/harness/cortextos/src/daemon/agent-manager.ts:158:      // (a future change accidentally breaks the exit-await). Phase 4 of
packages/harness/cortextos/src/daemon/agent-manager.ts:292:    // the agent PTY via injectAgent().  This is the Phase 2 daemon-managed
agents/recruitment/diagnostic/context.sh:6:# Status: Proposed (Day-19; voice + tone + recent_edits + target_patch hydration via voice-loader.sh + tone-loader + Postgres).
agents/recruitment/diagnostic/context.sh:23:#       CTX_RECENT_EDITS_REF  count of recent_edit rows (drift signal)
agents/recruitment/diagnostic/context.sh:157:# 5 — Load recent_edits (voice drift signal)
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:161:export CTX_RECENT_EDITS_REF
agents/recruitment/diagnostic/context.sh:163:EDIT_COUNT=$(printf '%s' "${CTX_RECENT_EDITS_REF}" | python3 -c "
agents/recruitment/diagnostic/context.sh:173:printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
agents/recruitment/diagnostic/tools.yaml:123:      voice-loader.sh for tenant corpus + tone rules + recent_edits.
docs/decisions/v1.0-kill-criterion.md:111:**Owner:** IFOS oncall + tenant operator. Daily check via `decision_log` queries: `SELECT COUNT(*) FROM decision_log WHERE phase='gating_failed' AND payload->>'tier'='red' AND payload->>'block_reason'='red_tier_classification' AND tenant_slug=? AND created_at > NOW() - INTERVAL '7 days'`.
docs/decisions/v1.0-kill-criterion.md:121:**Threshold:** Cost-per-completed-action (defined as: total IFOS infrastructure + API + Claude inference cost ÷ count of `decision_log` rows with `phase='action'` and `payload.tier IN ('green','yellow','orange-approved')`) exceeds **£0.50 per action** after 4 tenant-weeks of operation.
docs/decisions/v1.0-kill-criterion.md:247:### §3.6 — Pre-pilot phase (Weeks 1-2 before first LOI)
docs/decisions/v1.0-kill-criterion.md:249:In the pre-pilot phase (before any signed LOI), all authority and consultation rules above hold, but the **consultation timing windows can compress to "next reasonable opportunity"** rather than the 24h/48h defaults. Rationale: no pilot commitments yet; reversibility is high; speed of decision matters more than process compliance.
docs/decisions/v1.0-kill-criterion.md:251:### §3.7 — Post-pilot phase (after first LOI signed)
docs/_archive-build-pack/05-MIGRATION-MAP.md:3:**Concept-by-concept inventory of v1 (`/Users/madsadmin/code/intel-force-os/`) and cortextOS (`/Users/madsadmin/code/cortex-os-upstream/`). For each: keep / rebuild / drop, with v1 paths and v2 destinations. This is the single most useful lookup during the build — when a Phase asks "lift the activity log", this file says exactly which v1 file to read and where it goes in v2.**
docs/_archive-build-pack/05-MIGRATION-MAP.md:94:| Teams app manifest + icons | DEFER | `teams-app/` | Phase 3 if/when a customer demands Teams. |
docs/_archive-build-pack/05-MIGRATION-MAP.md:106:| Phase 0 strategic | KEEP (reference) | `docs/phase-0-strategic/` | Reference from `07-V1-INHERITED-CONTEXT.md`; don't copy |
docs/_archive-build-pack/05-MIGRATION-MAP.md:107:| Phase 1 POC stack | DROP | `docs/phase-1-poc-stack/` | Already retired |
docs/_archive-build-pack/05-MIGRATION-MAP.md:108:| Phase 2 agent suite (10 agent specs) | KEEP (mine for prompts) | `docs/phase-2-agent-suite/` | Source for `packages/agents/templates/<key>/prompt.md` |
docs/_archive-build-pack/05-MIGRATION-MAP.md:109:| Phase 3 platform | KEEP (lifts informed) | `docs/phase-3-platform/` | Informs `03-ARCHITECTURE.md` decisions on multi-tenancy, secrets, observability |
docs/_archive-build-pack/05-MIGRATION-MAP.md:110:| Phase 4 dashboard | KEEP (lifts informed) | `docs/phase-4-dashboard/` | Informs the dashboard rebuild |
docs/_archive-build-pack/05-MIGRATION-MAP.md:111:| Phase 5 business/legal | KEEP (as-is) | `docs/phase-5-business-legal/` | Intel Force Ltd legal docs unchanged; v2 reuses MSA/DPA/SLA/AUP/Privacy/ToS |
docs/_archive-build-pack/05-MIGRATION-MAP.md:112:| Phase 6 ops runbooks | KEEP (adapt) | `docs/phase-6-ops-runbooks/` | Adapt incident + DR runbooks for v2 topology |
docs/_archive-build-pack/05-MIGRATION-MAP.md:123:| Logo, palette, typography | KEEP | `WEBSITE-CONTEXT.md` §6 + `intel-force-os/docs/phase-5-business-legal/marketing/brand-identity-spec.md` | `packages/ui/tailwind.tokens.css` |
docs/_archive-build-pack/05-MIGRATION-MAP.md:247:| v1→v2 migration script | `infra/migrate/v1-to-v2.ts` | Built in Phase 3 |
docs/runbooks/tenant-lifecycle.md:207:- Decision_log shows audit row with `agent_name='_tenant_admin'`, `phase='trigger'`, `payload.action='suspend|resume'`
docs/runbooks/tenant-lifecycle.md:246:  DELETE FROM recent_edit       WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:250:  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:255:# decision_log + recent_edit are append-only — DELETE requires running as superuser (admin operation)
docs/runbooks/tenant-lifecycle.md:274:- Audit row in decision_log: `agent_name='_tenant_admin'`, `phase='gating_failed'`, `payload.action='tenant_purged'`, `payload.tenant_slug=<slug>` (written PRE-DELETE so the audit row survives)
docs/runbooks/tenant-lifecycle.md:277:**No `scripts/offboard-tenant.sh` exists.** Workflow above is the runbook spec. Script written when first tenant churns. **Risk:** if first churn happens without script, ad-hoc workflow risks omitting steps. Acceptable for v1.0 (low probability in pilot phase); v1.1+ adds the script.
docs/runbooks/tenant-lifecycle.md:360:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
docs/runbooks/tenant-lifecycle.md:364:  '<phase>',         -- 'trigger' for state-entry; 'gating_failed' for offboard-purge
docs/runbooks/tenant-lifecycle.md:386:| L3 | `scripts/run-tenancy-audit.sh --tenant <slug>` arg not implemented (currently audits only migration-test) | Medium | Phase 2 extension OR v1.1+ multi-tenant audit | Multi-tenant pilot OR Codex Round-3 |
docs/runbooks/operational-hygiene-protocol.md:27:- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:202:3. **Numerical claims:** count. "29 action_types" not "30+". "10 entity_links" not "~10". If counting is hard, write the counting query (grep, wc -l, SQL) and run it.
docs/runbooks/operational-hygiene-protocol.md:217:grep -nE "\b[0-9]+ (entities|fields|action_types|relationships|triggers|tiers|sections|edits|items)" <artefact>
docs/runbooks/operational-hygiene-protocol.md:224:- "30+ action_types" → forbidden. Count: 29. Write "29 action_types".
docs/runbooks/operational-hygiene-protocol.md:288:### §7.3 — Finding: Day-6 "30+ action_types" inflation (caught in founder review)
docs/runbooks/operational-hygiene-protocol.md:290:Day-6 structural summary claimed "30+ action_types across 6 v1.0 agents" in autosend policy §3. Actual count: 29 (Green 6 + Yellow 5 + Orange 10 + Red 8). The artefact itself does not make this claim — only my summary message did.
docs/_archive-build-pack/04-DATA-MODEL.md:413:Migration script lives at `infra/migrate/v1-to-v2.ts` (built in Phase 3).
docs/_archive-build-pack/04-DATA-MODEL.md:434:These don't block Phase 0. They're tuned in Phase 1.
agents/recruitment/diagnostic/agent.md:161:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
agents/recruitment/diagnostic/agent.md:197:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/recruitment/diagnostic/agent.md:222:| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ 10 rounds attempted; ADR-006 (Accepted) closed Cat-1 Gate A finding; residual mechanical findings tracked in disagreement doc Phase 4-5 |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:47:These map to concrete v2 architecture (see `03-ARCHITECTURE.md` and `04-DATA-MODEL.md`). The build plan enforces them in Phase 1 (governance package), Phase 2 (UI surfaces them), and Phase 3 (DPA wording reuses v1's).
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:69:Per-agent full descriptions in v1's `lib/agent-catalog.ts`. Used unchanged in v2 except for prompt files (which need adaptation to cortextOS's agent template format — see `06-BUILD-PLAN.md` Phase 2).
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:77:### Founding-phase (first 10 customers)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:247:- The MSA, DPA, SLA, AUP, Privacy Policy, Terms of Service templates from `intel-force-os/docs/phase-5-business-legal/legal/`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:248:- The pricing FAQ from `intel-force-os/docs/phase-5-business-legal/pricing/pricing-spec.md`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:249:- The sales playbook from `intel-force-os/docs/phase-5-business-legal/playbooks/sales-playbook.md`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:250:- The case-study playbook from `intel-force-os/docs/phase-5-business-legal/playbooks/case-study-playbook.md`
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:260:From `intel-force-os/docs/phase-0-strategic/intelforce-ai-os-strategic-plan.md`:
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:275:- The post-Phase-3 roadmap (iOS, theta-wave UX, multi-region)
packages/harness/cortextos/CHANGELOG.md:7:### Phase 5.4 — Race Hardening & Workspace Teaching
packages/harness/cortextos/CHANGELOG.md:17:### Phase 5.3 — Failure Mode & Recovery
packages/harness/cortextos/CHANGELOG.md:24:### Phase 4 — Cron Dashboard
packages/harness/cortextos/CHANGELOG.md:37:### Phase 1–3 — External Persistent Cron Engine
agents/recruitment/concierge/README.md:42:Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.
packages/harness/cortextos/CRONS_MIGRATION_GUIDE.md:165:## Dashboard (Phase 4)
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
agents/recruitment/concierge/agent.md:104:The actual SEND is a separate orange-tier action_type:
agents/recruitment/concierge/agent.md:122:     voice corpus + tone rules + recent_edits + tenant comms-template
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:139:     (candidate_id, payload.event_type) in last 24h with phase IN
agents/recruitment/concierge/agent.md:285:- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`.
agents/recruitment/concierge/agent.md:337:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:392:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:396:| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
agents/recruitment/concierge/agent.md:412:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/concierge/agent.md:415:- Codex Round 4 Phase 2 ratifies
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
packages/agent-renderer/README.md:68:ADR-003 §3.3.1 specifies `cortextos-ifos render-agent`. The upstream `cortextos-ifos` binary lives in the read-only submodule per master brief §3.1 boundary, so we can't add a subcommand there. Phase 2 ships the renderer as standalone `ifos-render-agent` (Node binary; `bin` field in package.json). The `.envrc` `alias ifosctl="cortextos-ifos"` is unchanged; a separate wrapper for `ifosctl render-agent <args>` is **not** in Phase 2 scope.
packages/agent-renderer/README.md:70:**Action item:** ADR-004 (Phase 2 follow-up) will ratify either (a) keeping `ifos-render-agent` as a standalone surface or (b) building an `ifosctl` shim that multiplexes. Founder + Codex review at first ratification round.
packages/agent-renderer/README.md:119:- **`discoverAgents()` lists `_shared` as a phantom agent.** Upstream cortextOS `bus/agents.ts` `listAgents()` scans `orgs/<org>/agents/*` without excluding `_shared/`. Renderer correctness unaffected; surfaces only in `cortextos-ifos list-agents` output. Carry-forward concern for IFOS daemon integration; not part of Phase 2 scope.
packages/agent-renderer/README.md:120:- **Telegram-down hang for orange-tier autosend** (autosend-safety-policy §5) is a Phase-3 concern in `hook-helpers.sh` `autosend_await_approval`, not a renderer concern. Documented for completeness.
packages/agent-renderer/README.md:124:Hand-edits to the rendered output are **lost on next render** (Decision 4: overwrite-no-merge per ADR-003 §3.4). Edit the bundle, then re-render. Decision-log row written with `agent_name='_renderer'` + `phase='render'` per ADR-003 §4 audit policy (Phase 3 wires this via `hook-helpers.sh`).
packages/agent-renderer/README.md:151:│   └── claude-md-preamble.md ← Phase 1 spec gap §2.1-A resolution
packages/agent-renderer/README.md:164:- `agents/_shared/escalation-codes.md` — ESC catalogue (Phase 1)
packages/agent-renderer/README.md:165:- `packages/agents-runtime/_shared/common-*.json` — shared config schemas (Phase 1)
packages/agent-renderer/README.md:166:- `~/.claude/plans/bubbly-snuggling-lantern.md` — active 5-phase plan
packages/harness/cortextos/templates/orchestrator/.claude/skills/worker-agents/SKILL.md:106:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
packages/agent-renderer/tests/fixtures/test-agent/context.sh:9:  # Real helpers land in Phase 3; this is a no-op for the renderer fixture.
packages/harness/cortextos/src/cli/restart.ts:20:    // Stop phase mirrors `cortextos stop <agent>` — write the .user-stop marker
packages/harness/cortextos/src/cli/restart.ts:31:    // Start phase — daemon's start-agent handler re-reads config.json + .env
packages/agent-renderer/tests/fixtures/test-agent/agent.md:5:Test-agent emits one structured `decision_log` row per invocation with phase
packages/harness/cortextos/dashboard/src/lib/data/reports.ts:90:// Fleet Health (Phase 1)
packages/harness/cortextos/dashboard/src/lib/data/reports.ts:329:// Cost Intelligence (Phase 3)
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:35:## Phase 0: Setup
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:139:When you have questions during Phase 3 (Discovery), send them via send-message. Do NOT use AskUserQuestion.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:144:3. Begin Phase 0, then Phase 1
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:146:5. Continue autonomously through all phases
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:151:## Phase 1: Spawn the Worker
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:158:  --prompt "Read AGENTS.md for your instructions, then read BRAINDUMP.md for the project spec. Begin the M2C1 workflow starting with Phase 0." \
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:175:## Phase 2: Monitor and Communicate
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:195:### Answering Discovery Questions (Phase 3)
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:215:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:217:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:223:## Phase 3: Tool Setup Support (CRITICAL - Act Like a Human)
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:225:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:294:## Phase 4: Autonomous Execution
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:324:- Worker is in a research subagent phase
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:334:## Phase 5: Validate the Output
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:345:After each phase of execution, verify:
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:358:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:372:## Phase 6: Cleanup
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:395:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:400:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/orchestrator/.claude/skills/m2c1-worker/SKILL.md:410:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:15:## Phase 1: Audit the Source Workspace
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:50:## Phase 2: Create the New Agent
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:72:## Phase 3: Extract Knowledge (Read Before Writing)
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:118:## Phase 4: Copy Files
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:168:## Phase 5: Write Bootstrap Files
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:206:## Phase 6: KB Ingestion
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:224:## Phase 7: Boot + Onboarding
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:32:## Phase 1: Day Summary
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:79:## Phase 2: Self-Evaluation (as orchestrator)
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:97:### Phase 2B: System Improvement Proposals (MANDATORY)
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:123:## Phase 3: Tomorrow Prep
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:140:## Phase 4: Overnight Task Proposals
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:223:## Phase 5: Update goals.json (before nighttime mode)
packages/harness/cortextos/src/cli/ecosystem.ts:115:      // by /onboarding Phase 7. PM2 just supervises the dashboard process.
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:10:  const [phase, setPhase] = useState<'enter' | 'hold' | 'fade'>('enter');
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:13:    const t1 = setTimeout(() => setPhase('hold'), 100);
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:14:    const t2 = setTimeout(() => setPhase('fade'), 1000);
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:23:        opacity: phase === 'fade' ? 0 : 1,
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:37:            strokeDashoffset={phase === 'enter' ? '1194' : '0'}
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:49:            strokeDashoffset={phase === 'enter' ? '974' : '0'}
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:61:            strokeDashoffset={phase === 'enter' ? '754' : '0'}
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:68:          const radius = phase === 'enter' ? 0 : 190;
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:79:                opacity: phase === 'enter' ? 0 : 0.5,
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:90:            opacity: phase === 'enter' ? 0 : 1,
packages/harness/cortextos/dashboard/src/components/layout/splash-screen.tsx:91:            transform: phase === 'enter' ? 'scale(0.8)' : 'scale(1)',
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:35:## Phase 0: Setup
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:162:When you have questions during Phase 3 (Discovery), send them via send-message. Do NOT use AskUserQuestion.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:164:## Planning Phase (REQUIRED before any file writes)
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:190:2. Execute the Planning Phase above
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:191:3. After PLAN_APPROVED, begin Phase 0, then Phase 1
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:193:5. Continue autonomously through all phases
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:198:## Phase 1: Spawn the Worker
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:205:  --prompt "Read AGENTS.md for your instructions, then read BRAINDUMP.md for the project spec. Begin the M2C1 workflow starting with Phase 0." \
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:222:## Phase 2: Monitor and Communicate
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:242:### Answering Discovery Questions (Phase 3)
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:286:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:288:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:323:## Phase 3: Tool Setup Support (CRITICAL - Act Like a Human)
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:395:## Phase 4: Autonomous Execution
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:425:- Worker is in a research subagent phase
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:435:## Phase 5: Validate the Output
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:446:After each phase of execution, verify:
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:459:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:473:## Phase 6: Cleanup
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:496:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:501:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:511:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
packages/harness/cortextos/templates/orchestrator/.claude/skills/weekly-review/SKILL.md:17:## Phase 1: Data Aggregation
packages/harness/cortextos/templates/orchestrator/.claude/skills/weekly-review/SKILL.md:44:## Phase 2: Present Review to User
packages/harness/cortextos/templates/orchestrator/.claude/skills/weekly-review/SKILL.md:145:## Phase 3: Interactive Discussion
packages/harness/cortextos/templates/orchestrator/.claude/skills/weekly-review/SKILL.md:155:## Phase 4: Update State
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:36:Execute each phase in order.
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:40:## Phase 0: Overnight Summary
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:91:## Phase 0E: Services Health Check
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:126:Already implicitly validated by the boot message. If it failed, the agent would not have reached this phase.
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:140:## Phase 1: Goals Cascade (MANDATORY — before task scheduling)
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:200:## Phase 2: Task Scheduling
packages/harness/cortextos/templates/orchestrator/.claude/skills/morning-review/SKILL.md:226:## Phase 3: Briefing Delivery
packages/harness/cortextos/community/catalog.json:91:      "description": "Autonomous software builds — spawn a dedicated M2C1 worker session to build any project through 12 structured phases",
packages/harness/cortextos/src/bus/task.ts:751:  // reference to an archived task. Phase 4 directive was
packages/harness/cortextos/tests/playwright/dashboard-auth.spec.ts:5: * Run against the live e2e-phase dashboard at port 3001.
packages/harness/cortextos/community/skills/worker-agents/SKILL.md:107:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
packages/harness/cortextos/templates/agent/.claude/skills/worker-agents/SKILL.md:106:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:2: * tests/integration/phase5-user-journeys.test.ts — Subtask 5.2
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:4: * Phase 5 User Journey Backtests: 3 end-to-end journeys that simulate real
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:27: * same as phase3-docs-backtest).  Fake timers are activated inside the two
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:31: * Journey 3 follows the phase4-dashboard-backtest pattern exactly:
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:60:// This is the same pattern used by phase4-dashboard-backtest.test.ts.
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:81:const j3Root = mkdtempSync(join(tmpdir(), 'phase5-j3-'));
packages/harness/cortextos/tests/integration/phase5-user-journeys.test.ts:161:  tmpRoot = mkdtempSync(join(tmpdir(), 'phase5-j12-'));
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:10:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:36:## Phase 0: Setup
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:120:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:140:When you have questions during Phase 3 (Discovery), send them via send-message. Do NOT use AskUserQuestion.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:145:3. Begin Phase 0, then Phase 1
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:147:5. Continue autonomously through all phases
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:152:## Phase 1: Spawn the Worker
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:159:  --prompt "Read AGENTS.md for your instructions, then read BRAINDUMP.md for the project spec. Begin the M2C1 workflow starting with Phase 0." \
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:176:## Phase 2: Monitor and Communicate
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:196:### Answering Discovery Questions (Phase 3)
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:216:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:218:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:224:## Phase 3: Tool Setup Support (CRITICAL - Act Like a Human)
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:226:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:295:## Phase 4: Autonomous Execution
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:324:- Worker is in a research subagent phase
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:334:## Phase 5: Validate the Output
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:345:After each phase of execution, verify:
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:358:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:372:## Phase 6: Cleanup
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:395:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:400:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/community/skills/m2c1-worker/SKILL.md:410:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:35:## Phase 0: Setup
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:162:When you have questions during Phase 3 (Discovery), send them via send-message. Do NOT use AskUserQuestion.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:164:## Planning Phase (REQUIRED before any file writes)
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:190:2. Execute the Planning Phase above
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:191:3. After PLAN_APPROVED, begin Phase 0, then Phase 1
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:193:5. Continue autonomously through all phases
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:198:## Phase 1: Spawn the Worker
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:205:  --prompt "Read AGENTS.md for your instructions, then read BRAINDUMP.md for the project spec. Begin the M2C1 workflow starting with Phase 0." \
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:222:## Phase 2: Monitor and Communicate
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:242:### Answering Discovery Questions (Phase 3)
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:286:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:288:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:323:## Phase 3: Tool Setup Support (CRITICAL - Act Like a Human)
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:395:## Phase 4: Autonomous Execution
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:425:- Worker is in a research subagent phase
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:435:## Phase 5: Validate the Output
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:446:After each phase of execution, verify:
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:459:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:473:## Phase 6: Cleanup
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:496:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:501:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:511:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:2: * tests/integration/phase3-docs.test.ts — Subtask 3.1-3.4 Documentation Guard
packages/harness/cortextos/tests/integration/phase3-docs.test.ts:4: * Asserts that the Phase 3 documentation pass is complete and consistent:
packages/harness/cortextos/community/skills/morning-review/SKILL.md:37:Execute each phase in order.
packages/harness/cortextos/community/skills/morning-review/SKILL.md:41:## Phase 0: Overnight Summary
packages/harness/cortextos/community/skills/morning-review/SKILL.md:92:## Phase 0E: Services Health Check
packages/harness/cortextos/community/skills/morning-review/SKILL.md:127:Already implicitly validated by the boot message in Phase 0. If the boot message failed to send, the agent would not have reached this phase.
packages/harness/cortextos/community/skills/morning-review/SKILL.md:143:## Phase 1: Goals Cascade (MANDATORY — before task scheduling)
packages/harness/cortextos/community/skills/morning-review/SKILL.md:203:## Phase 2: Task Scheduling
packages/harness/cortextos/community/skills/morning-review/SKILL.md:229:## Phase 3: Briefing Delivery
packages/harness/cortextos/community/skills/weekly-review/SKILL.md:18:## Phase 1: Data Aggregation
packages/harness/cortextos/community/skills/weekly-review/SKILL.md:45:## Phase 2: Present Review to User
packages/harness/cortextos/community/skills/weekly-review/SKILL.md:146:## Phase 3: Interactive Discussion
packages/harness/cortextos/community/skills/weekly-review/SKILL.md:156:## Phase 4: Update State
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/worker-agents/SKILL.md:105:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
packages/harness/cortextos/community/skills/evening-review/SKILL.md:33:## Phase 1: Day Summary
packages/harness/cortextos/community/skills/evening-review/SKILL.md:80:## Phase 2: Self-Evaluation (as orchestrator)
packages/harness/cortextos/community/skills/evening-review/SKILL.md:98:### Phase 2B: System Improvement Proposals (MANDATORY)
packages/harness/cortextos/community/skills/evening-review/SKILL.md:124:## Phase 3: Tomorrow Prep
packages/harness/cortextos/community/skills/evening-review/SKILL.md:141:## Phase 4: Overnight Task Proposals
packages/harness/cortextos/community/skills/evening-review/SKILL.md:224:## Phase 5: Update goals.json (before nighttime mode)
packages/harness/cortextos/src/bus/oauth.ts:318: * Two-phase write:
packages/harness/cortextos/src/bus/oauth.ts:319: *   Phase 1: accounts.json (permanent, written after refresh)
packages/harness/cortextos/src/bus/oauth.ts:320: *   Phase 2: agent .env files (conditional on preflight passing)
packages/harness/cortextos/src/bus/oauth.ts:378:  // PHASE 1: Update accounts.json (active + rotation_log)
packages/harness/cortextos/src/bus/oauth.ts:395:  // PHASE 2: Write bare access token to agent .env files
packages/harness/cortextos/community/agents/orchestrator/ONBOARDING.md:499:# Use the same user ID from your own .env (ORCH_USER_ID from Phase 6a setup).
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:8:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:34:## Phase 0: Setup
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:118:You are the M2C1 orchestrator. Follow the 12-phase workflow in plugins/cortextos-agent-skills/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:161:When you have questions during Phase 3 (Discovery), send them via send-message. Do NOT use AskUserQuestion.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:163:## Planning Phase (REQUIRED before any file writes)
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:189:2. Execute the Planning Phase above
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:190:3. After PLAN_APPROVED, begin Phase 0, then Phase 1
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:192:5. Continue autonomously through all phases
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:197:## Phase 1: Spawn the Worker
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:204:  --prompt "Read AGENTS.md for your instructions, then read BRAINDUMP.md for the project spec. Begin the M2C1 workflow starting with Phase 0." \
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:221:## Phase 2: Monitor and Communicate
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:241:### Answering Discovery Questions (Phase 3)
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:285:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:287:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:322:## Phase 3: Tool Setup Support (CRITICAL - Act Like a Human)
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:324:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:394:## Phase 4: Autonomous Execution
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:425:- Worker is in a research subagent phase
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:435:## Phase 5: Validate the Output
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:446:After each phase of execution, verify:
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:459:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:473:## Phase 6: Cleanup
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:496:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:501:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:511:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:2: * tests/integration/phase5-failure-modes.test.ts — Subtask 5.3
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:4: * Phase 5 Failure Mode & Recovery Testing.
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:8: * same infrastructure as phase5-e2e-simulation.test.ts:
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:68:// Per-test environment wiring (same pattern as phase5-e2e-simulation.test.ts)
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:97:  tmpRoot = mkdtempSync(join(tmpdir(), 'phase5-fm-'));
packages/harness/cortextos/tests/integration/phase5-failure-modes.test.ts:398:    // Phase 1: Normal operation
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:25:### Phase 1: Initiate
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:31:### Phase 2: Deep System Scan
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:42:### Phase 3: Evaluate Previous Theta Wave Experiment
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:50:### Phase 4: Evaluate Agent Research Cycles
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:60:### Phase 5: External Research
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:67:### Phase 6: Conversation with Orchestrator
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:92:### Phase 7: Hypothesis and Action
packages/harness/cortextos/templates/analyst/.claude/skills/theta-wave/SKILL.md:131:### Phase 8: Score, Log, and Report
packages/harness/cortextos/tests/unit/daemon/worker-process.test.ts:114:      expect(w.inject('continue with phase 3')).toBe(true);
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:2: * tests/integration/phase5-e2e-simulation.test.ts — Subtask 5.1
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:4: * Phase 5 End-to-End System Simulation: 7 full-system scenarios covering the
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:8: * timers, matching the established Phase 1 pattern.  No module mocking beyond
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:87:  tmpRoot = mkdtempSync(join(tmpdir(), 'phase5-e2e-'));
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:350:    // Phase 1: run for 6h
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:495:    // Phase 1: agent running — all 3 crons catch up and fire
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:567:    // Phase 1: successful fire
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:573:    const afterPhase1 = getCronByName(agent, 'monitor');
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:574:    const fireCountAfterPhase1 = afterPhase1?.fire_count ?? 0;
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:575:    expect(fireCountAfterPhase1).toBeGreaterThanOrEqual(1);
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:577:    // Phase 2: agent crash — fire fails
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:587:    expect(afterCrash?.fire_count ?? 0).toBe(fireCountAfterPhase1);
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:589:    // Phase 3: recovery
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:590:    // Iter 11 semantic: Phase 2's failed fire persisted last_fire_attempted_at,
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:602:    expect(afterRecovery?.fire_count ?? 0).toBeGreaterThan(fireCountAfterPhase1);
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:799:   * PHASE 5 FINDING: agent-manager.ts injectAgent() has no internal retry logic.
packages/harness/cortextos/tests/integration/phase5-e2e-simulation.test.ts:1155:  // We follow the Phase 4 pattern: routes called directly with NextRequest,
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:2: * tests/integration/phase4-dashboard-backtest.test.ts — Subtask 4.6
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:4: * Phase 4 Full Backtesting: End-to-end scenarios for all 6 dashboard CRUD
packages/harness/cortextos/tests/integration/phase4-dashboard-backtest.test.ts:31:const rootTmp = fs.mkdtempSync(path.join(os.tmpdir(), 'phase4-backtest-'));
packages/harness/cortextos/tests/unit/daemon/agent-process.test.ts:120:    // Give stop() a moment to enter its kill phase. The 4s of internal sleeps
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:2: * tests/integration/phase3-docs-backtest.test.ts — Subtask 3.5 Phase 3 Full Backtesting
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:4: * Programmatically follows the Phase 3 documentation workflows end-to-end.
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:96:  tmpRoot = mkdtempSync(join(tmpdir(), 'phase3-backtest-'));
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:2: * tests/integration/phase5-performance.test.ts — Subtask 5.4
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:4: * Phase 5 Performance & Scaling Tests.
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:6: * Extends phase4-performance.test.ts to the 1000-cron scale and adds the six
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:32: * - The AF-2 sequential-fire drift finding from phase5-failure-modes.test.ts
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:66:  tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'phase5-perf-'));
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:518:    // Extension of AF-2 from phase5-failure-modes.test.ts:
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:546:        // Simulate 10ms PTY injection delay (as measured in AF-2 of phase5-failure-modes)
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:727:    // AF-2 from phase5-failure-modes established 100 × 10ms = 1s (30x headroom).
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:886:describe('Phase 5 Performance Summary', () => {
packages/harness/cortextos/tests/integration/phase5-performance.test.ts:889:    console.log('  Phase 5 Performance Summary (5.4)    ');
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:2: * tests/integration/phase4-performance.test.ts — Subtask 4.6
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:31:const perfTmp = fs.mkdtempSync(path.join(os.tmpdir(), 'phase4-perf-'));
packages/harness/cortextos/tests/integration/phase4-performance.test.ts:331:    console.log('\n=== Phase 4 Performance Summary ===');
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:2: * tests/integration/phase5-audit.test.ts — Subtask 5.5
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:4: * Phase 5 Compliance & Audit Verification.
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:65:// Per-test environment wiring (same pattern as phase5-failure-modes.test.ts)
packages/harness/cortextos/tests/integration/phase5-audit.test.ts:105:  tmpRoot = mkdtempSync(join(tmpdir(), 'phase5-audit-'));
packages/harness/cortextos/templates/analyst/.claude/skills/worker-agents/SKILL.md:106:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
packages/harness/cortextos/tests/integration/agent-bootstrap-crons.test.ts:41:// Constants matching the phase1 test conventions
packages/harness/cortextos/tests/integration/phase1-backtesting.test.ts:2: * tests/integration/phase1-backtesting.test.ts — Phase 1 Full Backtesting (Subtask 1.6)
packages/harness/cortextos/tests/integration/phase1-backtesting.test.ts:81:  tmpRoot = mkdtempSync(join(tmpdir(), 'phase1-backtest-'));
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:2: * tests/integration/phase2-backtesting.test.ts — Subtask 2.6 Phase 2 Full Backtesting
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:187:  tmpCtxRoot       = mkdtempSync(join(tmpdir(), 'phase2-ctx-'));
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:188:  tmpFrameworkRoot = mkdtempSync(join(tmpdir(), 'phase2-fw-'));
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:695:    // ---- Phase 1: advance 12h — all 5 running ----
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:710:    // ---- Phase 2: advance another 12h — only 4 running ----
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:749:    // ---- Phase 3: restart gamma's scheduler ----
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:807:    // ---- Phase 1: run all 5 schedulers for 24h ----
packages/harness/cortextos/tests/integration/phase2-backtesting.test.ts:885:    // ---- Phase 2: advance another 24h (48h cumulative) ----
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:35:## Phase 0: Setup
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:139:When you have questions during Phase 3 (Discovery), send them via send-message. Do NOT use AskUserQuestion.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:144:3. Begin Phase 0, then Phase 1
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:146:5. Continue autonomously through all phases
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:151:## Phase 1: Spawn the Worker
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:158:  --prompt "Read AGENTS.md for your instructions, then read BRAINDUMP.md for the project spec. Begin the M2C1 workflow starting with Phase 0." \
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:175:## Phase 2: Monitor and Communicate
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:195:### Answering Discovery Questions (Phase 3)
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:215:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:217:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:223:## Phase 3: Tool Setup Support (CRITICAL - Act Like a Human)
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:225:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:295:## Phase 4: Autonomous Execution
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:325:- Worker is in a research subagent phase
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:335:## Phase 5: Validate the Output
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:346:After each phase of execution, verify:
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:359:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:373:## Phase 6: Cleanup
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:396:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:401:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/templates/analyst/.claude/skills/m2c1-worker/SKILL.md:411:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.
packages/harness/cortextos/dashboard/src/app/api/kb/search/route.ts:72:  // Derive instance ID from CTX_ROOT (e.g. ~/.cortextos/e2e-phase → "e2e-phase")
packages/harness/cortextos/community/agents/security/.claude/skills/worker-agents/SKILL.md:106:cortextos inject-worker <worker-name> "Continue with phase 3. What's blocking you?"
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:3:description: "You need to build software autonomously — a new project, a major feature, or any structured development task. You will act as the 'human' supervisor for a dedicated M2C1 worker session, managing it through all 12 phases: provide the brain dump, answer discovery questions, configure tools and credentials, monitor progress via bus messages and git, validate the output, and clean up when done. Use when the work is large enough to warrant a dedicated isolated build session."
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:9:> Any cortextOS agent can autonomously build complete software by acting as the "human" in the M2C1 framework, managing a dedicated worker Claude Code session through the full 12-phase lifecycle.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:35:## Phase 0: Setup
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:119:You are the M2C1 orchestrator. Follow the 12-phase workflow in .claude/skills/m2c1/orchestration-workflow.md.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:162:When you have questions during Phase 3 (Discovery), send them via send-message. Do NOT use AskUserQuestion.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:164:## Planning Phase (REQUIRED before any file writes)
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:190:2. Execute the Planning Phase above
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:191:3. After PLAN_APPROVED, begin Phase 0, then Phase 1
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:193:5. Continue autonomously through all phases
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:198:## Phase 1: Spawn the Worker
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:205:  --prompt "Read AGENTS.md for your instructions, then read BRAINDUMP.md for the project spec. Begin the M2C1 workflow starting with Phase 0." \
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:222:## Phase 2: Monitor and Communicate
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:242:### Answering Discovery Questions (Phase 3)
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:286:1. Send a bus message: `cortextos bus send-message <worker-name> normal 'Continue with the M2C1 workflow. What phase are you on?'`
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:288:3. Inject directly into the PTY if still unresponsive: `cortextos inject-worker <worker-name> "Continue with the M2C1 workflow. What phase are you on?"`
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:323:## Phase 3: Tool Setup Support (CRITICAL - Act Like a Human)
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:325:This is one of the most important phases. You act exactly like a human developer setting up a project: installing tools, configuring MCPs, setting env variables, logging into services, testing that everything works. The worker cannot do this itself — it needs you to configure its environment.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:395:## Phase 4: Autonomous Execution
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:424:- Worker is in a research subagent phase
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:434:## Phase 5: Validate the Output
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:445:After each phase of execution, verify:
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:458:The worker's last phase should be comprehensive testing. Verify:
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:472:## Phase 6: Cleanup
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:495:  --meta '{"project":"<name>","phase":"<where it failed>","reason":"<why>"}'
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:500:  'M2C1 build FAILED: <project>. Failed at phase <N>. Reason: <why>. Directory preserved at <path>.'
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:510:4. **Validate at phase gates.** Check PRD, discovery, task plans, and final output.

exec
/bin/zsh -lc "rg -n \"AgentMail|Composio|packages/harness/cortextos|kb-|brain|Brain|tenant_adapters\\.config|concierge_email_draft|gmail_outlook_send_to_candidate|body_markdown|draft_id|recent_edit\" agents/recruitment/concierge/agent.md docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter (deferred) deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier (`gmail_outlook_send_to_candidate` or `bullhorn_note_customer_visible` depending on channel per autosend-policy.yaml lines 122-149). Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute SLA from lifecycle event to draft is a Gate B leading metric (warning + aggregated; NOT a Gate A hard-fail) per the same ULTRAPLAN line — making it a hard-fail would block legitimate delayed drafts caused by Bullhorn polling fallbacks. Gate B success thresholds: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:60:- Brain UI lifecycle-event timeline viewer per candidate
agents/recruitment/concierge/agent.md:87:draft_id: <uuid>
agents/recruitment/concierge/agent.md:94:body_markdown: <body; voice-classified>
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
agents/recruitment/concierge/agent.md:105:- `gmail_outlook_send_to_candidate` (per autosend-policy.yaml line 130) when channel=email
agents/recruitment/concierge/agent.md:122:     voice corpus + tone rules + recent_edits + tenant comms-template
agents/recruitment/concierge/agent.md:129:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:138:   → query decision_log for prior `concierge_email_draft` row for same
agents/recruitment/concierge/agent.md:143:   → if found BUT prior draft never sent (no `gmail_outlook_send_to_candidate`
agents/recruitment/concierge/agent.md:189:   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
agents/recruitment/concierge/agent.md:199:   → on success: hh_decision_action("concierge_email_draft",
agents/recruitment/concierge/agent.md:230:    → hh_decision_action("gmail_outlook_send_to_candidate",
agents/recruitment/concierge/agent.md:285:- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`.
agents/recruitment/concierge/agent.md:337:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:392:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:394:| Q5 | Comms-template customisation — every tenant edits these. Per-event-type, per-recipient-role × per-tenant = 24+ templates each. Authoring tool? | v1.0: Markdown files at `/vault/<slug>/concierge-templates/<event>-<role>.md`. v1.1: Brain UI WYSIWYG editor. |
agents/recruitment/concierge/agent.md:395:| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 3 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:302:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:318:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:326:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:580:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:711:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:# §4 — tenant_adapters.config new keys (3 keys)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:830:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:928:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:976:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:978:    - Concierge tenant_adapters.config field refs valid

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '570,620p;700,780p;960,985p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   570	  tone_rule:
   571	    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
   572	    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
   573	    rationale: |
   574	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   575	      applies_to_agents containing 'janitor' for tacit-note narrative
   576	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   577	      Diagnostic + Sourcing Scout also read tone_rules for their
   578	      voice-classified outputs (§12 opener, per-candidate rationale).
   579	
   580	  recent_edit:
   581	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   582	    v0_3_v1_0_agent_access:
   583	      - voice-drift-canary (W)  # v0.2 unchanged
   584	      - Concierge (R)            # v0.2 unchanged
   585	      - LoRA (R)                 # v0.2 unchanged
   586	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   587	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   588	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   589	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   590	    rationale: |
   591	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   592	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   593	      for retraining queue). Janitor adds R for tacit-note harvest per
   594	      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
   595	      supplement is the authoritative source for the expanded access list.
   596	
   597	# ============================================================================
   598	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   599	# ============================================================================
   600	
   601	auxiliary_tables:
   602	
   603	  cash_conductor_transactions:
   604	    rationale: |
   605	      Open Banking transactions are high-volume + time-series + don't model
   606	      as entity.data JSONB. v0.3 introduces a first-class table with
   607	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   608	      §4 Step 3 + ADR-002 vault/Postgres split.
   609	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   610	    columns:
   611	      id: {type: integer, required: true, source: IFOS-internal, notes: BIGSERIAL primary key in SQL}
   612	      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
   613	      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
   614	      posted_at: {type: timestamp, required: true, source: Open Banking provider}
   615	      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
   616	      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
   617	      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   618	      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   619	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
   620	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
   700	    sourcing_scout: R
   701	    concierge: R
   702	  tone_rule:
   703	    # v0.2 auxiliary table — per-tenant tone constraints
   704	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents
   705	    diagnostic: R
   706	    janitor: R
   707	    scribe: R
   708	    cash_conductor: R
   709	    sourcing_scout: R
   710	    concierge: R
   711	  recent_edit:
   712	    # v0.2 auxiliary table — consultant edits for retraining/drift detection
   713	    # Per §2a amendment: v0.3 expands access (Concierge R from v0.2;
   714	    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
   715	    # Scout add W to write own retraining edits; Diagnostic remains none)
   716	    diagnostic: none
   717	    janitor: R
   718	    scribe: W
   719	    cash_conductor: W
   720	    sourcing_scout: W
   721	    concierge: R
   722	  cash_conductor_transactions:
   723	    diagnostic: none
   724	    janitor: none
   725	    scribe: none
   726	    cash_conductor: R+W
   727	    sourcing_scout: none
   728	    concierge: none
   729	  cash_conductor_invoices:
   730	    diagnostic: none
   731	    janitor: none
   732	    scribe: none
   733	    cash_conductor: R+W
   734	    sourcing_scout: none
   735	    concierge: none
   736	
   737	# ============================================================================
   738	# §4 — tenant_adapters.config new keys (3 keys)
   739	# ============================================================================
   740	#
   741	# tenant_adapters.config is JSONB; validation via
   742	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   743	# on unknown keys per Rule 2.
   744	
   745	tenant_adapters_config_additions:
   746	
   747	  cash_conductor_last_run:
   748	    type: timestamp
   749	    required: false
   750	    set_by: cash_conductor
   751	    read_by: [cash_conductor]
   752	    notes: |
   753	      Cash Conductor cron sweep updates at session-close. Next run queries
   754	      transactions/invoices since this timestamp.
   755	
   756	  concierge_last_poll:
   757	    type: timestamp
   758	    required: false
   759	    set_by: concierge
   760	    read_by: [concierge]
   761	    notes: |
   762	      Concierge polling cron updates at end of each cycle. Next poll queries
   763	      Bullhorn for state transitions since this timestamp.
   764	
   765	  concierge_send_window:
   766	    type: object
   767	    required: false
   768	    default:
   769	      timezone: Europe/London
   770	      weekday_start: '09:00'
   771	      weekday_end: '17:00'
   772	      weekend_send_enabled: false
   773	    set_by: [tenant-admin]
   774	    read_by: [concierge]
   775	    object_shape:
   776	      timezone:
   777	        type: string
   778	        notes: IANA timezone identifier
   779	      weekday_start:
   780	        type: string
   960	  §5 of this supplement); v0.3 is silent on payload schema extensions.
   961	
   962	  After v0.3 ratifies + migration applies:
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
   975	      consistency-pass before Scribe ratifies.
   976	    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
   977	    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
   978	    - Concierge tenant_adapters.config field refs valid
   979	    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
   980	
   981	  Expected re-ratification: 1 Codex round per agent.md after v0.3 lands;
   982	  ~3-5 residual mechanical findings per agent (down from current 4-6) —
   983	  those are per-agent specifics (workflow, validate.sh/cycle.sh build slices),
   984	  not schema gaps.
   985	

codex
REJECTED

1. Autosend citations are materially wrong. Lines 16 and 105-108 cite `autosend-policy.yaml` lines 122-149 / 130 / 137 / 144 for Concierge action types, but the actual policy has `concierge_email_draft` at lines 210-215 and orange send actions at lines 221-248. Fix the line anchors and keep the §1/§3 claims tied to the actual policy rows.

2. Gate A is weakened against the cited ULTRAPLAN spec. Lines 16 and 273 downgrade the 30-minute lifecycle-event draft requirement to Gate B, but ULTRAPLAN line 566 explicitly lists “every lifecycle event has a draft generated within 30 minutes” under Gate A. Either retain it as Gate A or add an accepted decision that formally supersedes ULTRAPLAN A6.

3. The workflow assumes lifecycle states that are not schema-backed for Concierge. Lines 126-135 and 242-245 use interview/offer/post-interview lifecycle transitions, but `vertical-schema.yaml` gives Concierge access to `candidate` and `placement`; `candidate.status` does not include those states, `placement.lifecycle_stage` only covers placement cadence, and `opportunity` is v1.1+/no Concierge access. Add the needed v0.2/v0.3 schema supplement or constrain Concierge to schema-defined fields.

4. §4 workflow omits mandatory `hh_decision_*` calls at output/action points. Step 7 writes `/vault/<tenant>/concierge-drafts/<draft_id>.md` at line 189 without a decision-log call in that step, Step 9 emits `ESC_CONCIERGE_SLA_MISS` at line 205 without logging, and Step 11 queues approval routing at lines 219-225 without an action row. Add explicit `hh_decision_output` / `hh_decision_action` calls at each output/action point.

5. Several ESC codes are repurposed beyond the catalogue definitions. `ESC_CANDIDATE_DATA_INCOMPLETE` at lines 155 and 302 is catalogued for Sourcing Scout shortlist completeness, not Concierge missing email/name; `ESC_AGENT_OUTPUT_SHAPE` at lines 275 and 310 is used for voice-threshold failure even though `ESC_VOICE_DRIFT` covers that; `ESC_APPROVAL_BRIDGE_TIMEOUT` is stated as 24h at lines 225 and 308 while the catalogue/policy timeout is PT4H. Align triggers/severity with `agents/_shared/escalation-codes.md` or explicitly flag new catalogue additions.
tokens used
74,996
REJECTED

1. Autosend citations are materially wrong. Lines 16 and 105-108 cite `autosend-policy.yaml` lines 122-149 / 130 / 137 / 144 for Concierge action types, but the actual policy has `concierge_email_draft` at lines 210-215 and orange send actions at lines 221-248. Fix the line anchors and keep the §1/§3 claims tied to the actual policy rows.

2. Gate A is weakened against the cited ULTRAPLAN spec. Lines 16 and 273 downgrade the 30-minute lifecycle-event draft requirement to Gate B, but ULTRAPLAN line 566 explicitly lists “every lifecycle event has a draft generated within 30 minutes” under Gate A. Either retain it as Gate A or add an accepted decision that formally supersedes ULTRAPLAN A6.

3. The workflow assumes lifecycle states that are not schema-backed for Concierge. Lines 126-135 and 242-245 use interview/offer/post-interview lifecycle transitions, but `vertical-schema.yaml` gives Concierge access to `candidate` and `placement`; `candidate.status` does not include those states, `placement.lifecycle_stage` only covers placement cadence, and `opportunity` is v1.1+/no Concierge access. Add the needed v0.2/v0.3 schema supplement or constrain Concierge to schema-defined fields.

4. §4 workflow omits mandatory `hh_decision_*` calls at output/action points. Step 7 writes `/vault/<tenant>/concierge-drafts/<draft_id>.md` at line 189 without a decision-log call in that step, Step 9 emits `ESC_CONCIERGE_SLA_MISS` at line 205 without logging, and Step 11 queues approval routing at lines 219-225 without an action row. Add explicit `hh_decision_output` / `hh_decision_action` calls at each output/action point.

5. Several ESC codes are repurposed beyond the catalogue definitions. `ESC_CANDIDATE_DATA_INCOMPLETE` at lines 155 and 302 is catalogued for Sourcing Scout shortlist completeness, not Concierge missing email/name; `ESC_AGENT_OUTPUT_SHAPE` at lines 275 and 310 is used for voice-threshold failure even though `ESC_VOICE_DRIFT` covers that; `ESC_APPROVAL_BRIDGE_TIMEOUT` is stated as 24h at lines 225 and 308 while the catalogue/policy timeout is PT4H. Align triggers/severity with `agents/_shared/escalation-codes.md` or explicitly flag new catalogue additions.
