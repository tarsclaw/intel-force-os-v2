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
session id: 019e8844-5fcb-7f73-85fd-fcba5a935389
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

**Status:** Proposed.
**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice (see §10).
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.

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

Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha — see Step 1 polling fallback.

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
| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) — respectful, specific, leaves door open |
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
     "candidate:<bullhorn_id>:<event_type>", "vault_path:<path>; voice_score:<N>; words:<N>")
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
    → per Founder Decision D1 (final selection at W10 design):
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

**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.

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
| `ESC_MS_GRAPH_AUTH` | Microsoft Graph OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin (token re-auth required) |
| `ESC_GMAIL_AUTH` | Gmail OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin |
| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
| `ESC_VOICE_DRIFT` | Voice classifier below the position-specific threshold (≥0.75/0.78/0.82) after 3 retries. The Gate A hard-fail (validate.sh exits non-zero; draft not sent) is expressed through `validate_gate_a_fail`, NOT through this code's severity: per catalogue (escalation-codes.md lines 120-125) `ESC_VOICE_DRIFT` is `warn` → `operator_chat_id` for ALL positions. Position-specific paging urgency (e.g. oncall on rejections) would require a catalogue amendment adding position-severity semantics — not yet made. | warn | operator_chat_id |
| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | warn (catalogue) — Gate A still blocks the draft from sending via validate.sh; ESC severity governs operator-paging urgency only | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md lines 348-353 + autosend-policy.yaml (grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field; default `PT4H`)) | warn | operator + tenant-admin |
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
  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §gotchas (line numbers vary; see live file); demand specificity)
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
- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §gotchas (line numbers vary; see live file) explicitly names rejection voice as the hardest case)

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
- **✅ ADR-007 (Concierge Gate A 30-min SLA hybrid) ACCEPTED + RATIFIED** — Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3 per `.codex/ratification/review-architecture-decision.md` skill (commit `c862c77`). Closes the documented deviation from ULTRAPLAN A6 line 566 wording; agent.md's Gate B framing of the 30-min SLA is now the canonical disposition. This Status-flip blocker is satisfied.
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
I’m going to verify the cited source lines and catalog entries before deciding. The main risk areas here are line-anchor drift, autosend policy action types, schema fields, and whether the proposed bundle crosses any IFOS boundaries.
exec
/bin/zsh -lc 'rg -n "concierge_email_draft|gmail_outlook_send_to_candidate|bullhorn_note_customer_visible|twilio_sms_send|calendar_invite_send|concierge_approval_routed|bullhorn_activity_log_write|concierge_run_complete|autosend|timeout|YELLOW|ORANGE" agents/_shared docs -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:3:# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
agents/_shared/autosend-policy.yaml:4:# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
agents/_shared/autosend-policy.yaml:15:#   timeout         orange only: ISO-8601 duration; default PT4H if absent
agents/_shared/autosend-policy.yaml:89:  concierge_run_complete:
agents/_shared/autosend-policy.yaml:101:  concierge_approval_routed:
agents/_shared/autosend-policy.yaml:104:    reason: "Internal audit row recorded by Concierge cycle.sh Step 11 when an approval is routed via the autosend-bridge (per Founder Decision D1 path A/B/C). Payload carries d1_path + bridge_target (approval_id or vault path). Not an external send; the actual send is a downstream orange-tier action_type with its own row."
agents/_shared/autosend-policy.yaml:181:  bullhorn_activity_log_write:
agents/_shared/autosend-policy.yaml:184:    reason: "Internal Bullhorn activity-log entry — NOT customer-visible (separate from bullhorn_note_customer_visible which is orange). Maintains the audit trail in Bullhorn itself so downstream consultant ops see Concierge actions on the candidate's record. Idempotent within payload_hash dedup window. Registered per Codex Fbis-R1 closure 2026-06-02 — Concierge agent.md §4 Step 13 needs this for tier classification of the external write."
agents/_shared/autosend-policy.yaml:188:  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
agents/_shared/autosend-policy.yaml:254:  concierge_email_draft:
agents/_shared/autosend-policy.yaml:258:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
agents/_shared/autosend-policy.yaml:262:  # ORANGE — per-action human approval (10 action_types)
agents/_shared/autosend-policy.yaml:265:  bullhorn_note_customer_visible:
agents/_shared/autosend-policy.yaml:268:    timeout: PT4H
agents/_shared/autosend-policy.yaml:269:    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
agents/_shared/autosend-policy.yaml:273:  gmail_outlook_send_to_candidate:
agents/_shared/autosend-policy.yaml:276:    timeout: PT4H
agents/_shared/autosend-policy.yaml:280:  twilio_sms_send:
agents/_shared/autosend-policy.yaml:283:    timeout: PT30M
agents/_shared/autosend-policy.yaml:287:  calendar_invite_send:
agents/_shared/autosend-policy.yaml:290:    timeout: PT4H
agents/_shared/autosend-policy.yaml:297:    timeout: PT4H
agents/_shared/autosend-policy.yaml:304:    timeout: PT24H
agents/_shared/autosend-policy.yaml:311:    timeout: PT4H
agents/_shared/autosend-policy.yaml:318:    timeout: PT4H
agents/_shared/autosend-policy.yaml:325:    timeout: PT4H
agents/_shared/autosend-policy.yaml:332:    timeout: PT4H
agents/_shared/autosend-policy.yaml:401:  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
agents/_shared/autosend-policy.yaml:403:  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes
agents/_shared/autosend-policy.yaml:413:  - "orange action_types MUST declare timeout (ISO-8601 duration)"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:833:      send refusal (autosend-safety-policy §5 red-tier action_type
docs/architecture/tenancy-invariants.md:253:| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |
docs/operations/goal-overnight-2026-05-31.md:24:Two `No such file/found` lookups in `agents/recruitment/diagnostic/validate.sh` + autosend lookup helper. Resolve to the real `agents/_shared/` path (with `IFOS_REPO_ROOT` fallback chain like `context.sh` already does). Re-test against the Hays smoke to confirm zero warnings on the deterministic path. Commit atomically.
docs/operations/goal-overnight-2026-05-31.md:35:7. `decision_log` integration via `_shared/hook-helpers.sh`; action_types match `autosend-policy.yaml`.
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
agents/_shared/escalation-codes.md:13:The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
agents/_shared/escalation-codes.md:31:Source: `docs/decisions/autosend-safety-policy.md` §5
agents/_shared/escalation-codes.md:38:- **Timeout:** 4h default per `common-notifications.json.default_approval_timeout_seconds`; on timeout, converts to manual reconciliation
agents/_shared/escalation-codes.md:43:- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:61:- **Trigger:** `flock` acquisition failed within `OP_LOCK_TIMEOUT_S = 5` seconds (per `common-vault.json.lock_timeout_seconds`)
agents/_shared/escalation-codes.md:89:- **Trigger:** Cascade exceeded `CASCADE_TIMEOUT_MS = 30_000` ms per vault-concurrency §5 + `common-vault.json.cascade_timeout_ms`
agents/_shared/escalation-codes.md:339:Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
agents/_shared/escalation-codes.md:341:#### `ESC_AUTOSEND_ORANGE_PENDING`
agents/_shared/escalation-codes.md:343:- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
agents/_shared/escalation-codes.md:346:- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
agents/_shared/escalation-codes.md:350:- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
agents/_shared/escalation-codes.md:353:- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
agents/_shared/escalation-codes.md:474:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:211:        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:247:          Enum: ["approved_verbatim", "approved_after_edit", "rejected", "deferred"]. `deferred` indicates operator returned to inbox without resolving (4h timeout case).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/architecture/architecture-cohesion-review.md:74:| vault-concurrency.md §6 | ESC wiring | hook-helpers.sh::autosend_escalate | ✓ landed Phase 3 (e6e9df1) |
docs/architecture/architecture-cohesion-review.md:123:### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)
docs/architecture/architecture-cohesion-review.md:125:- **autosend-safety-policy.md** §7 says `payload_preview` MUST exclude raw PII (max 500 chars, no names/phones/emails)
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
agents/_shared/README.md:12:| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:27:2. **Fallback mode (degraded / offline)** — `IFOS_DB_URL` unset OR `psql` unavailable OR `psql` exited non-zero. Helpers append JSON lines to `${IFOS_DECISION_LOG_FALLBACK:-/vault/<tenant>/decision-log.jsonl}`. The trail replays into Postgres when connectivity returns via the autosend-syncer worker (Week 5+).
agents/_shared/README.md:41:| `HH_POLICY_FILE` | no | Override path to `autosend-policy.yaml` | `${CTX_AGENT_DIR}/.claude/hooks/_shared/autosend-policy.yaml` |
agents/_shared/README.md:43:| `HH_AWAIT_TEST_MODE` | no (test only) | `approve` / `reject` / `timeout` — short-circuits `autosend_await_approval` poll loop | — |
agents/_shared/README.md:58:### 7 `autosend_*` helpers (autosend-safety-policy §4)
agents/_shared/README.md:61:autosend_policy_lookup        <action_type>                                          # prints tier
agents/_shared/README.md:62:autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>               # prints possibly-elevated tier
agents/_shared/README.md:63:autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
agents/_shared/README.md:64:autosend_escalate             <ESC_CODE> [<key=value>...]
agents/_shared/README.md:65:autosend_should_sample        <action_type> <tenant_slug>                            # returns 0 if sampled
agents/_shared/README.md:66:autosend_spot_check_enqueue   <action_type> <target> <hash> <preview> <tenant_slug>
agents/_shared/README.md:67:autosend_await_approval       <action_type> <target> <hash>                          # blocks until resolved
agents/_shared/README.md:70:## Auto-send tier dispatch (autosend-safety-policy §4)
agents/_shared/README.md:84:Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
agents/_shared/README.md:86:**Tested:** `HH_AWAIT_TEST_MODE=timeout` short-circuits the poll loop and exercises the timeout path; verified in `tests/test-hook-helpers.sh` test #7.
agents/_shared/README.md:88:**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
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
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:6:Morning goal + this goal's §1 · `agents/recruitment/cash-conductor/agent.md` §3+§4+§5 (consumer spec) · `packages/mcp-connectors/{xero,quickbooks,open-banking}/` (pattern) · `docs/decisions/2026-05-31-d1-founder-decision.md` §"Implementation surface" (bridge contract) · `agents/_shared/{hook-helpers.sh,autosend-policy.yaml}` (existing helpers + action_type registry) · `agents/recruitment/diagnostic/{context,cleanup}.sh` (sibling pattern for Phase A files).
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:17:## §2 Phase B — `@ifos/autosend-bridge-telegram` scaffold (~2.5h, 1 commit)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:18:Package at `packages/utilities/autosend-bridge-telegram/`. Mirrors MCP-connector structure (package.json + tsconfig + vitest.config + tsup.config + README ≥120 lines + src + tests + fixtures).
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:21:- `proposeApproval({action_type, target, draft_preview, vault_path, timeout?}) → {approval_id}` — posts to operator's tenant Telegram chat with `[ID:<approval_id>]` prefix + draft preview + vault path + `/approve <id>` / `/reject <id>` instructions
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:22:- `awaitApprovalDecision(approval_id, options?) → {outcome: "approved"|"rejected"|"timeout", decided_by, decided_at}` — polls Telegram for the operator's reply (or webhook in v1.1+)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:24:- Default timeout `PT4H` per `escalation-codes.md` lines 348-353 (`ESC_APPROVAL_BRIDGE_TIMEOUT`)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:25:- Fail-safe: timeout returns `{outcome: "timeout"}` not an exception — caller (Cash Conductor cycle.sh Step 10, Concierge cycle.sh) decides how to fire the ESC code
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:27:≥12 vitest (scaffold + config + propose + await with poll-mock + timeout + reject path + concurrent same-approval-id idempotency). Live Telegram tests gated `BRIDGE_LIVE_TESTS=true`. Zero credential interpolations in errors. README documents D1-B precedent + Concierge W10 integration contract + Cash Conductor `cycle.sh` Step 10 wiring.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:30:6. `scripts/run-tenancy-audit.sh` T12 grep heuristic — refine the candidate-slug-refs grep to exclude lines containing `phase=`, `#` comment leaders, JSON example data (the 4 false positives flagged in yesterday's audit: hook-helpers.sh:166/177 + autosend-policy.yaml:116 + common-target-patch.json:12). Re-run audit to confirm zero noise.
agents/_shared/hook-helpers.sh:3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:32:# Resolve the autosend-policy + escalation-codes paths through a fallback
agents/_shared/hook-helpers.sh:58:_HH_POLICY_FILE="$(_hh_resolve_shared_path "autosend-policy.yaml" "${HH_POLICY_FILE:-}")"
agents/_shared/hook-helpers.sh:228:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
agents/_shared/hook-helpers.sh:229:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:231:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:236:  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
agents/_shared/hook-helpers.sh:237:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:239:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:246:      autosend_emit_decision_log "action" "green" "${action_type}" \
agents/_shared/hook-helpers.sh:251:      autosend_emit_decision_log "action" "yellow" "${action_type}" \
agents/_shared/hook-helpers.sh:253:      if autosend_should_sample "${action_type}" "${tenant}"; then
agents/_shared/hook-helpers.sh:254:        autosend_spot_check_enqueue "${action_type}" "${target}" \
agents/_shared/hook-helpers.sh:260:      autosend_emit_decision_log "action" "orange" "${action_type}" \
agents/_shared/hook-helpers.sh:262:      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:264:      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
agents/_shared/hook-helpers.sh:268:      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
agents/_shared/hook-helpers.sh:270:      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
agents/_shared/hook-helpers.sh:275:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:277:      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:285:# 7 autosend_* helpers (autosend-safety-policy §4)
agents/_shared/hook-helpers.sh:288:# autosend_policy_lookup <action_type>
agents/_shared/hook-helpers.sh:291:autosend_policy_lookup() {
agents/_shared/hook-helpers.sh:294:    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
agents/_shared/hook-helpers.sh:311:# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:313:# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
agents/_shared/hook-helpers.sh:315:autosend_apply_tenant_override() {
agents/_shared/hook-helpers.sh:326:  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
agents/_shared/hook-helpers.sh:348:    printf 'autosend_apply_tenant_override: refusing to demote %s → %s for %s/%s\n' \
agents/_shared/hook-helpers.sh:355:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:356:# Emits the standard autosend decision_log row with payload.tier set.
agents/_shared/hook-helpers.sh:357:autosend_emit_decision_log() {
agents/_shared/hook-helpers.sh:379:# autosend_escalate <ESC_CODE> [<key=value>...]
agents/_shared/hook-helpers.sh:383:autosend_escalate() {
agents/_shared/hook-helpers.sh:388:    printf 'autosend_escalate: unknown ESC code: %s\n' "${code}" >&2
agents/_shared/hook-helpers.sh:412:  # signal. Dispatcher (autosend-syncer) reads recent gating_failed rows and
agents/_shared/hook-helpers.sh:416:# autosend_should_sample <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:418:# 1 otherwise. Sample rate read from autosend-policy.yaml (sample_rate field);
agents/_shared/hook-helpers.sh:420:autosend_should_sample() {
agents/_shared/hook-helpers.sh:442:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
agents/_shared/hook-helpers.sh:445:autosend_spot_check_enqueue() {
agents/_shared/hook-helpers.sh:454:    printf 'autosend_spot_check_enqueue: cannot mkdir %s\n' "${spot_dir}" >&2
agents/_shared/hook-helpers.sh:477:# autosend_await_approval <action_type> <target> <payload_hash>
agents/_shared/hook-helpers.sh:478:# Blocks until cortextOS approval gate resolves OR timeout fires.
agents/_shared/hook-helpers.sh:479:# Returns 0 on approval, 1 on rejection or timeout-rejection.
agents/_shared/hook-helpers.sh:483:autosend_await_approval() {
agents/_shared/hook-helpers.sh:488:  local timeout_iso
agents/_shared/hook-helpers.sh:489:  timeout_iso=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:491:    in_block && /^    timeout: / { sub(/^    timeout: /, ""); print; exit }
agents/_shared/hook-helpers.sh:494:  timeout_iso="${timeout_iso:-PT4H}"
agents/_shared/hook-helpers.sh:497:  local timeout_s=14400  # 4h default
agents/_shared/hook-helpers.sh:498:  if [[ "${timeout_iso}" =~ ^PT([0-9]+)S$ ]]; then
agents/_shared/hook-helpers.sh:499:    timeout_s="${BASH_REMATCH[1]}"
agents/_shared/hook-helpers.sh:500:  elif [[ "${timeout_iso}" =~ ^PT([0-9]+)M$ ]]; then
agents/_shared/hook-helpers.sh:501:    timeout_s=$(( BASH_REMATCH[1] * 60 ))
agents/_shared/hook-helpers.sh:502:  elif [[ "${timeout_iso}" =~ ^PT([0-9]+)H$ ]]; then
agents/_shared/hook-helpers.sh:503:    timeout_s=$(( BASH_REMATCH[1] * 3600 ))
agents/_shared/hook-helpers.sh:518:    printf 'timeout_seconds=%s\n' "${timeout_s}"
agents/_shared/hook-helpers.sh:522:  # tests don't block. Values: "approve"|"reject"|"timeout".
agents/_shared/hook-helpers.sh:535:      timeout|*)
agents/_shared/hook-helpers.sh:537:        autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:538:          "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"
agents/_shared/hook-helpers.sh:548:  while (( elapsed < timeout_s )); do
agents/_shared/hook-helpers.sh:563:  # Timed out — convert to ESC_AUTOSEND_NEEDS_REVIEW with timeout marker.
agents/_shared/hook-helpers.sh:565:  autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:566:    "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"
docs/operations/codex-ratification-guide.md:309:- Codex returned an empty response (timeout)
docs/operations/codex-ratification-guide.md:397:If `IFOS_DB_URL` isn't set when the wrapper runs (or psql isn't on PATH or the live DB rejects the write), the row appends to `logs/codex-ratification.jsonl` instead. Same shape, JSON Lines. Replays into Postgres later via the autosend-syncer worker (Week 5+).
docs/operations/codex-ratification-guide.md:435:- Network timeout to OpenAI API → retry
docs/architecture/vault-concurrency.md:389:**V1.0 cascade timeout: 30 seconds** (`CASCADE_TIMEOUT_MS = 30_000`). If exceeded, raise `ESC_VAULT_CASCADE_TIMEOUT` with `failures.length` (entities not yet rewritten) and `refs.length` (total cascade size). Decision_log entry per `phase='gating_failed'`. **Founder reviews** — for large cascades (>30s), the rename is structurally expensive and may warrant rescheduling to off-hours.
docs/architecture/vault-concurrency.md:397:**Status update 2026-05-20 (Day 8 Codex Round 1):** all 5 codes below are now catalogued at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`, Phase 1 of Week-1 slice) AND wired into the `autosend_escalate` helper at `agents/_shared/hook-helpers.sh` (commit `e6e9df1`, Phase 3 of Week-1 slice). The "_shared/hook-helpers.sh Week-1 prereq must wire these 5 codes" language below has been satisfied — current state is shipped + tested.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:425:| Cascade performance (30s timeout; v1.0 sequential; v1.2+ async with eventual consistency deferred) | §5.5 |
docs/architecture/vault-concurrency.md:447:| `OP_LOCK_TIMEOUT_S` (per-operation flock acquire timeout) | 5 seconds | `/vault/<tenant>/_config.yaml` per-tenant override |
docs/architecture/vault-concurrency.md:449:| `CASCADE_TIMEOUT_MS` (rewrite-backlinks cascade total timeout) | 30,000 ms | Operation-level override at call site for known-large cascades |
docs/architecture/vault-concurrency.md:453:All defaults are conservative for v1.0 pilot scale (3-6 tenants per Product Spec §5.4). Observed contention data in production may justify tightening (lower lock timeouts to surface contention faster) or loosening (higher cascade timeouts for batch operations). Revisit at first three pilots' month-3 review per Product Spec §3.
docs/operations/w4-day-20-founder-runbook.md:133:on autosend orange-tier path blocks Concierge build slice. Both are session
docs/operations/codex-round-2-handoff.md:77:| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
docs/operations/codex-round-2-handoff.md:87:**Likely outcomes:** 11-12 of 14 RATIFY. Items #6 (autosend tier contradiction) and #14 (PII retention) are founder-decision-bound (D1/D3); Codex may RATIFY-with-advisory or REJECT pending decisions.
docs/operations/codex-round-2-handoff.md:107:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | `review-architecture-decision` | RATIFY (Proposed spec; alternatives weighed; ratifies cortextOS primitive-4 reuse) |
docs/operations/codex-round-2-handoff.md:139:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-handoff.md:168:  review, tenant lifecycle, founder decision briefing, 2 disagreement docs, autosend
docs/operations/codex-round-2-handoff.md:211:  docs/decisions/autosend-safety-policy.md
docs/operations/codex-round-2-handoff.md:231:  docs/decisions/autosend-approval-bridge-spec.md  (review-architecture-decision)
docs/operations/codex-round-2-handoff.md:288:**Sub-case 2a: Same issue as Round 1** — incorporation didn't actually fix the root cause. Escalate to founder; reopen as a fresh issue. Likely candidates: autosend-safety-policy (D1 + D3 unresolved); v0.2 supplement (D3 unresolved).
docs/operations/goal-w4-day-26-2026-06-01.md:21:9. Cash Conductor bundle skeletons — `cycle.sh` (14-step per agent.md §4) + `validate.sh` (Gate A per §5) + `tools.yaml`. Fixtures + `context.sh` + `cleanup.sh` deferred. Drafts-only graceful degradation when `autosend-bridge-telegram` absent (D1-B doc).
agents/_shared/tests/test-hook-helpers.sh:82:export HH_POLICY_FILE="${REPO_ROOT}/agents/_shared/autosend-policy.yaml"
agents/_shared/tests/test-hook-helpers.sh:117:printf '\n[3] autosend_policy_lookup resolves each tier\n'
agents/_shared/tests/test-hook-helpers.sh:118:test_lookup_green() { local t; t=$(autosend_policy_lookup "diagnostic_report_render"); _assert_eq "green" "${t}" "green"; }
agents/_shared/tests/test-hook-helpers.sh:119:test_lookup_yellow() { local t; t=$(autosend_policy_lookup "bullhorn_candidate_dedupe"); _assert_eq "yellow" "${t}" "yellow"; }
agents/_shared/tests/test-hook-helpers.sh:120:test_lookup_orange() { local t; t=$(autosend_policy_lookup "bullhorn_note_customer_visible"); _assert_eq "orange" "${t}" "orange"; }
agents/_shared/tests/test-hook-helpers.sh:121:test_lookup_red() { local t; t=$(autosend_policy_lookup "xero_payment_initiate"); _assert_eq "red" "${t}" "red"; }
agents/_shared/tests/test-hook-helpers.sh:122:test_lookup_unknown() { autosend_policy_lookup "nonexistent_action" >/dev/null 2>&1; _assert_rc "1" "$?" "unknown"; }
agents/_shared/tests/test-hook-helpers.sh:159:  HH_AWAIT_TEST_MODE=approve hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash1" "preview"
agents/_shared/tests/test-hook-helpers.sh:173:  HH_AWAIT_TEST_MODE=reject hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash2" "preview"
agents/_shared/tests/test-hook-helpers.sh:191:printf '\n[9] autosend_apply_tenant_override — elevation allowed\n'
agents/_shared/tests/test-hook-helpers.sh:193:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:200:  result=$(autosend_apply_tenant_override "green" "bullhorn_note_internal" "${CTX_TENANT_SLUG}")
agents/_shared/tests/test-hook-helpers.sh:205:printf '\n[10] autosend_apply_tenant_override — demotion refused\n'
agents/_shared/tests/test-hook-helpers.sh:207:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:211:  bullhorn_note_customer_visible: green
agents/_shared/tests/test-hook-helpers.sh:213:  autosend_apply_tenant_override "orange" "bullhorn_note_customer_visible" "${CTX_TENANT_SLUG}" >/dev/null 2>&1
agents/_shared/tests/test-hook-helpers.sh:218:printf '\n[11] autosend_apply_tenant_override — red is absolute\n'
agents/_shared/tests/test-hook-helpers.sh:220:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:227:  result=$(autosend_apply_tenant_override "red" "xero_payment_initiate" "${CTX_TENANT_SLUG}")
agents/_shared/tests/test-hook-helpers.sh:233:printf '\n[12] autosend_escalate — unknown ESC code → meta-escalation\n'
agents/_shared/tests/test-hook-helpers.sh:236:  autosend_escalate "ESC_NONEXISTENT_CODE" 2>/dev/null
agents/_shared/tests/test-hook-helpers.sh:245:printf '\n[13] autosend_should_sample — yellow tier with high rate eventually returns 0\n'
agents/_shared/tests/test-hook-helpers.sh:251:    if autosend_should_sample "bullhorn_candidate_dedupe" "${CTX_TENANT_SLUG}"; then
agents/_shared/tests/test-hook-helpers.sh:260:printf '\n[14] autosend_spot_check_enqueue writes idempotent markdown\n'
agents/_shared/tests/test-hook-helpers.sh:263:  autosend_spot_check_enqueue "bullhorn_candidate_dedupe" "candidate:foo" "abc123def456" "merge preview" "${CTX_TENANT_SLUG}"
agents/_shared/tests/test-hook-helpers.sh:286:  # (a) the autosend_emit_decision_log audit row with payload.tier='red'
agents/_shared/tests/test-hook-helpers.sh:287:  # (b) the autosend_escalate ESC_AUTOSEND_BLOCKED escalation row
docs/operations/goal-week-4-track-1.md:27:13. **`agents/_shared/autosend-policy.yaml`** — `xero_reminder_draft_internal` (line 188), `xero_reminder_send_customer` (line 263), `accounting_reconciliation_write`.
docs/operations/goal-week-4-track-1.md:48:5. **`agents/recruitment/cash-conductor/cycle.sh`** exists; 14 steps per agent.md §4. Wires to the 3 connectors above + the D1-B `autosend-bridge-telegram` package (built separately at Concierge W10; cycle.sh degrades gracefully when absent — drafts-only mode per agent.md §1 readiness caveat).
docs/operations/goal-week-4-track-1.md:52:9. **`agents/recruitment/cash-conductor/tools.yaml`** exists; declares: `xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`, `telegram_notify`, `autosend_bridge_telegram` (per D1-B).
docs/operations/goal-week-4-track-1.md:108:| `autosend-bridge-telegram` package | Reserved for Concierge W10 build slice per D1-B doc §"Implementation surface"; Cash Conductor cycle.sh degrades gracefully when absent (drafts-only mode) |
docs/operations/goal-week-4-track-1.md:169:7. **decision_log integration** — every state-changing capability emits via `_shared/hook-helpers.sh hh_decision_action` with the registered `action_type` from `autosend-policy.yaml`.
docs/operations/goal-week-4-track-1.md:272:- `agents/recruitment/cash-conductor/cycle.sh` — 14 steps; wires the 3 connectors above + the autosend-bridge-telegram package (graceful degradation when absent per D1-B + agent.md §1 readiness caveat — drafts-only when bridge missing)
docs/operations/goal-week-4-track-1.md:275:- `agents/recruitment/cash-conductor/cleanup.sh` — transient OAuth token + cache purge; emits `cash_conductor_cleanup` audit row (green tier; add to autosend-policy.yaml if not yet registered)
docs/operations/goal-week-4-track-1.md:276:- `agents/recruitment/cash-conductor/tools.yaml` — capability declarations: `xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`, `telegram_notify`, `autosend_bridge_telegram`
docs/operations/goal-week-4-track-1.md:366:| Cash Conductor bundle integration with `autosend-bridge-telegram` blocked (package not yet built — that's Concierge W10) | cycle.sh degrades to drafts-only mode per agent.md §1 readiness caveat; documented and tested via fixture 01-primary |
docs/operations/goal-week-4-track-1.md:426:1. **Every capability documented.** README lists all exported functions with input/output Zod schemas + which `autosend-policy.yaml` action_type they correspond to.
docs/operations/goal-week-4-track-1.md:431:6. **Integration with `_shared/hook-helpers.sh`** — every state-changing capability emits `hh_decision_action` with the correct `action_type` per `autosend-policy.yaml`.
docs/operations/goal-week-4-track-1.md:490:  ✓ D1-B (2026-05-31 decision) — autosend bridge approach baked into cycle.sh
docs/operations/goal-week-4-track-1.md:522:| 4 | The `autosend-bridge-telegram` graceful-degradation logic in cycle.sh is incorrect (sends instead of drafting when bridge missing) | High-impact-if-wrong | Fixture `01-primary` MUST cover both bridge-present and bridge-absent code paths; assert that the orange-tier action row is written but NOT auto-sent in the bridge-absent case |
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:437:    -- autosend-safety-policy.md keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:438:    'approval_routing', 'approval_timeouts', 'sampling_rates',
docs/operations/decision-log.md:82:1. **T12 heuristic false positives** — flagged 4 lines in `hook-helpers.sh` / `autosend-policy.yaml` / `common-target-patch.json` as "candidate hard-coded slug refs"; all four are comments or example data, not real hardcoded slugs. Worth tightening the T12 grep heuristic in `scripts/run-tenancy-audit.sh` next time we touch tenancy audit; not blocking.
docs/operations/decision-log.md:116:| 5 | Founder Decision D1 (autosend orange-tier) | **DELEGATED + TAKEN: D1-B (Telegram shim)** | `docs/decisions/2026-05-31-d1-founder-decision.md` |
docs/operations/decision-log.md:126:- D1-B is the autosend orange-tier path for v1.0; Concierge W10 build slice will deliver the `packages/utilities/autosend-bridge-telegram/` package per the decision doc §"Implementation surface".
docs/operations/decision-log.md:184:   - **Cash Conductor (2):** autosend line cites (182→188, 257→263); missing vault-write step
docs/operations/decision-log.md:186:   - **Concierge (5):** ULTRAPLAN 566 citation realign; SLA-miss audit row; 24h→PT4H timeout; ESC_VOICE_DRIFT severity→warn; third Gate B threshold
docs/operations/decision-log.md:197:**Verified:** v0.3 supplement YAML parses; migration FOR/LOOP balanced + `elem` declared; shellcheck clean on the harness; all cited line numbers (autosend-policy 188/263/235-239, escalation-codes 120-125/348-353/431-439, validate_gate_a_fail 119) confirmed against source.
docs/operations/decision-log.md:214:| action_types referenced ∈ autosend-policy.yaml | ✓ 0 missing |
docs/operations/decision-log.md:229:6. `40f94c4 fix(scribe-r4)` — all 5 R3 residuals closed; missing `hh_decision_*` calls added at §4 Steps 3+7; Ringover explicitly v1.1+; autosend cite split (decision-doc vs runtime YAML); ESC_PROVIDER_FETCH_FAIL catalogue extension queued
docs/operations/decision-log.md:277:4. **D1 founder decision (autosend orange-tier path A/B/C)** — still pending. Blocks Concierge build slice.
docs/operations/decision-log.md:313:- [x] **Phase 3** — `hook-helpers.sh` + `autosend-policy.yaml` + README. Landed Day 8 `e6e9df1`. 20/20 hook-helpers tests pass; closes gap #4. Fixed renderer `_shared` symlink path (`../../_shared` → `../../../_shared` — ADR-003 spec error flagged for ADR-004).
docs/operations/decision-log.md:447:- **Founder Decision D1** (autosend orange-tier) — required before Concierge W10 build
docs/operations/decision-log.md:535:5. **Founder Decision D1** (autosend orange-tier path) — required before Concierge W10 build slice; recommend D1-B Telegram shim for v1.0 ship per Concierge §9 Q1
docs/operations/decision-log.md:673:- Founder-decision-bound items annotated only: autosend D1, legal D2/D3, vertical-schema D3 retention
docs/operations/decision-log.md:683:- D1: choose autosend orange-tier v1.0 path
docs/operations/decision-log.md:691:- Tier 1: **11/14 RATIFIED**; remaining rejects are Bullhorn gate wording, autosend v1.0 tier contradiction, and v0.2 PII/migration issues
docs/operations/decision-log.md:700:- D1 autosend orange-tier v1.0 path
docs/operations/decision-log.md:727:- D1 — autosend v1.0 tier enforcement (~30 min; Concierge scope)
docs/operations/decision-log.md:768:  - D1: autosend v1.0 tier enforcement (Concierge W10-13 scope)
docs/operations/decision-log.md:780:### Day 8 (2026-05-20) — Phases 3-5: hook-helpers + autosend policy + vertical-schema v0.2 + voice-loader
docs/operations/decision-log.md:784:**Phase 3** — `e6e9df1` — hook-helpers.sh + autosend-policy.yaml + README + renderer symlink fix
docs/operations/decision-log.md:785:- `agents/_shared/autosend-policy.yaml` (259 lines) — 29 v1.0 action_types: 6 green / 5 yellow / 10 orange / 8 red. Each row with tier + agent + reason + (sample_rate | timeout | block_reason).
docs/operations/decision-log.md:786:- `agents/_shared/hook-helpers.sh` (528 lines, shellcheck clean) — 3 hh_decision_* contracts + 7 autosend_* helpers per autosend §4. Dual-mode (live psql / fallback JSONL). RLS via `SET LOCAL ifos.tenant_slug`.
docs/operations/decision-log.md:913:- **15 fabricated "master brief §10.4" references** across 5 files. Master brief §10.4 is "What never goes through ratification" (Codex exclusion list), not a Hetzner location or cost-target section. Root cause: Day-4 runbook §1.4 invented the citation; propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1), RISK-REGISTER (2), current-priorities (1) by citation transitivity rather than re-verification against master brief.
docs/operations/decision-log.md:916:  - `docs/decisions/autosend-safety-policy.md`: 1 fix (cyber insurance budget reference)
docs/operations/decision-log.md:936:  - Agent × Entity R/W matrix across all 6 v1.0 agents (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) — cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3
docs/operations/decision-log.md:942:- **Contractor as separate entity_type** (not status flag on candidate) — adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor'. Rationale: autosend policy distinguishes contractor vs candidate action_types; IR35 first-class; queryability beats status-flag filtering
docs/operations/decision-log.md:958:Three-prompt pattern executed cleanly (grounding → drafting → revisions → commit). Founder review batched at end of drafting; web-Claude second pair. Five autosend amendments + eight kill-criterion amendments applied in batch revision pass.
docs/operations/decision-log.md:962:- **`docs/decisions/autosend-safety-policy.md`** (658 lines, 11 sections):
docs/operations/decision-log.md:965:  - Concierge `bullhorn_note_customer_visible` canonical orange per `bullhorn-integration-path.md` §4.1 + §6.3
docs/operations/decision-log.md:1116:10. **Day-5 path drift (NEW Day 5 2026-05-18)** — Master brief §6 Day 5 lines 484-485: paths `docs/auto-send-safety-policy.md` and `docs/v1-kill-criterion.md` → `docs/decisions/autosend-safety-policy.md` and `docs/decisions/v1.0-kill-criterion.md` per repo convention since Day 0 (matching ADR-001/-002/-003 + bullhorn + sequencing-target + brain-ui-scope). Source: Day-5 autosend policy header + kill criterion header.
docs/operations/decision-log.md:1142:16. **`docs/decisions/autosend-safety-policy.md`** (Status: Proposed) — NEW Day 5 morning 2026-05-18
docs/operations/codex-round-2-remediation-prompt.md:238:  FIX 8 — autosend-approval-bridge-spec.md category mapping rewrite
docs/operations/codex-round-2-remediation-prompt.md:240:  File: docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-remediation-prompt.md:243:  Issue 2: new autosend_approval_mappings table not added to
docs/operations/codex-round-2-remediation-prompt.md:251:           bullhorn_note_customer_visible      → external-comms
docs/operations/codex-round-2-remediation-prompt.md:252:           gmail_outlook_send_to_candidate     → external-comms
docs/operations/codex-round-2-remediation-prompt.md:253:           twilio_sms_send                     → external-comms
docs/operations/codex-round-2-remediation-prompt.md:254:           calendar_invite_send                → external-comms
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
docs/operations/seedlegals-engagement-queries.md:68:> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
docs/operations/w4-bilateral-pass-6-agent-md.md:146:  - **Codex says:** "Line 380 says Cash Conductor only depends on Concierge `agent.md` being Accepted, but lines 235-253 require Concierge to receive drafts, run the approval bridge, transport sends, and callback; line 244 also cites the unresolved D1 path. Add Founder Decision D1 resolved + autosend bridge/Concierge transport availability as explicit prerequisites, or rewrite §4 to use the existing shared autosend approval helper without Concierge."
docs/operations/w4-bilateral-pass-6-agent-md.md:147:  - **Likely:** FIX-IN-PLACE. Add to §8 prereqs: (a) D1 resolved, (b) Concierge autosend-bridge live. Note: D1 is W4 queue #4 — this finding documents the dependency in the agent.md but does NOT block ratification of the scaffold (Status will be Proposed→Pre-Build pending D1).
docs/operations/w4-bilateral-pass-6-agent-md.md:152:  - **Codex says:** "Line 114 says each draft writes `phase='output'` with `action_type='xero_reminder_draft_internal'`, but `xero_reminder_draft_internal` is an autosend action type and §4 line 237 correctly routes it through `hh_decision_action`; `hh_decision_output` rows use output-type payloads, not autosend tier dispatch. Change §3 so draft generation is an output row such as `output_type='chase_draft_generated'`, and the queued draft is a separate `phase='action'` row with `action_type='xero_reminder_draft_internal'`."
docs/operations/w4-bilateral-pass-6-agent-md.md:180:### Finding 4. autosend-policy YAML citation wrong
docs/operations/w4-bilateral-pass-6-agent-md.md:182:  - **Codex says:** "Line 16 cites `autosend-safety-policy.yaml` and line 214 cites `autosend-safety-policy §4`, but the runtime YAML in the repo is `agents/_shared/autosend-policy.yaml`; `autosend-safety-policy` exists as a decision `.md`, not YAML. Replace the YAML citation with `agents/_shared/autosend-policy.yaml` and cite the decision doc only when referring to policy rationale."
docs/operations/w4-bilateral-pass-6-agent-md.md:183:  - **Likely:** FIX-IN-PLACE. Replace `autosend-safety-policy.yaml` → `agents/_shared/autosend-policy.yaml` (runtime) where mechanical; keep `autosend-safety-policy §4` where it's the decision-doc rationale citation, but fix to `docs/decisions/autosend-safety-policy.md §4`.
docs/operations/w4-bilateral-pass-6-agent-md.md:200:  - **Codex says:** "Lines 187-193 write the draft to `/vault/<tenant>/concierge-drafts/<draft_id>.md` but do not log the output; lines 222-228 route approval via autosend-bridge but do not log the approval-routing action. Type-specific §1 requires every output/action step to call `hh_decision_*`. Add explicit `hh_decision_output` for draft creation and `hh_decision_action` or `hh_decision_output` for approval routing."
docs/operations/w4-bilateral-pass-6-agent-md.md:201:  - **Likely:** FIX-IN-PLACE. Add `hh_decision_output concierge_email_draft` after line 193; add `hh_decision_action approval_routed` after line 228.
docs/operations/w4-bilateral-pass-6-agent-md.md:205:  - **Cite:** §3 line 67; cross-ref line 102 + `autosend-policy.yaml`
docs/operations/w4-bilateral-pass-6-agent-md.md:206:  - **Codex says:** "Line 67 says 'an email draft (orange tier)', but lines 102 and autosend-policy define `concierge_email_draft` as yellow; only the send actions are orange. This creates an internal contract conflict for Gate A/B and decision_log rows. Change line 67 to 'email draft (yellow tier); send is separate orange-tier action'."
docs/architecture/second-brain-design.md:698:- Each `update-entity` / `append-to-narrative` operation acquires `flock` on `wiki/compiled/{type}/{slug}.md.lock` (exclusive, blocking with 5-second timeout).
docs/architecture/second-brain-design.md:975:| **2.6** | Master brief §5 silent on concurrency | No mechanism for agent×agent, agent×human-in-Obsidian, or rewrite-backlinks cascade | Resolved in §2.6.1, §2.6.2, §2.6.3 of this design. Companion document `docs/architecture/vault-concurrency.md` LANDED (Day 3, commit `78680cc`). New escalation codes (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, `ESC_VAULT_RENAME_RACE`) CATALOGUED at `agents/_shared/escalation-codes.md` §2.2 (Day 8 commit `a279226`) + WIRED into `agents/_shared/hook-helpers.sh::autosend_escalate` (Day 8 commit `e6e9df1`). | **Closed 2026-05-20.** Catalogue + wiring complete; ESC codes callable from any rendered agent. |
docs/operations/founder-legal-setup-guide.md:229:> Would you provide a quote? Happy to share more about our autosend-safety-policy on a call.
docs/operations/codex-ratification-execution-plan.md:130:| 8 | autosend-safety-policy | `docs/decisions/autosend-safety-policy.md` | A |
docs/operations/codex-ratification-execution-plan.md:167:| 25 | autosend-policy.yaml | `agents/_shared/autosend-policy.yaml` | A |
docs/operations/goal-option-c-diagnostic-end-to-end.md:128:- `client.ts` — HTTP client with timeout, redirect-follow, user-agent string
docs/operations/goal-option-c-diagnostic-end-to-end.md:136:- First-N-lines fetch handles 200, 404, 5xx, timeout
docs/operations/codex-round-2-autonomous-prompt.md:97:For autosend-safety-policy.md (Tier 1 item #6) and v0.2 supplement (item 
docs/operations/codex-round-2-autonomous-prompt.md:253:4. **DO NOT make founder decisions.** Items like D1 (autosend orange tier), 
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:160:2. **`bullhorn_field_backfill` unregistered, would fail-safe to red:** my flag-for-addition framing didn't satisfy because `hook-helpers.sh::autosend_policy_lookup` fails to red on unknown action types AT RUNTIME, regardless of flag prose. Real bug requires either (a) policy row added BEFORE ratification, OR (b) explicit "blocked W5 prerequisite" framing not "executable output."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:174:3. Founder approves: (a) catalogue extensions (escalation-codes + autosend-policy batch additions), (b) schema field corrections, (c) §5/§6/§7 prose standardisation pattern (15 min)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:261:- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
docs/runbooks/tenant-lifecycle.md:153:| Spot-check operator review | `autosend_spot_check_enqueue` writes to `/vault/<slug>/spot-checks/<file>.md`; operator reviews + flags as approved/rejected/escalate | (No invariant violation) |
docs/_supplementary/PRD-autonomous-agent.md:829:    { timeout: 120000 }
docs/_supplementary/PRD-autonomous-agent.md:1313:  throw new Error('HeyGen timeout after 10 minutes');
docs/_supplementary/PRD-autonomous-agent.md:1421:    timeoutInMilliseconds: 300000, // 5 minutes
docs/operations/goal-week-3-polish-and-scaffold.md:26:9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
docs/operations/goal-week-3-polish-and-scaffold.md:31:14. **`agents/_shared/autosend-policy.yaml`** (29 action types; tier classifications)
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:307:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:310:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_BULLHORN_WRITE_FAIL, ESC_SCHEMA_VIOLATION, ESC_RATE_LIMIT_HIT, ESC_AUTOSEND_YELLOW_SPOT_CHECK.
docs/operations/goal-week-3-polish-and-scaffold.md:411:#### Step 12 — `agents/recruitment/concierge/agent.md` (~3-4 hours; most complex due to autosend orange-tier)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:416:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:417:- `2026-05-20-codex-round-1-founder-decisions.md` §D1 (autosend orange-tier decision)
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:425:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:426:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:431:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/build-brief/00-MASTER-BRIEF.md:477:- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
docs/runbooks/pii-purge-operational-pattern.md:21:- **Purpose 1: Operator review** of agent drafts — needs the text only during the review window (typically minutes to hours, max ~4h timeout).
docs/runbooks/pii-purge-operational-pattern.md:159:| Disk full during audit row write | UPDATE succeeds; audit row write fails; orphaned purge | Decision_log fallback to JSONL at `/var/log/ifos/decision-log.jsonl`; replay via autosend-syncer when disk recovers |
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:109:**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
docs/decisions/v1.0-kill-criterion.md:113:**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
docs/decisions/v1.0-kill-criterion.md:117:**Escalation path:** If three pilots experience this trigger within one quarter, escalate to system-wide PAUSE while structural autosend policy redesign happens (potential v1.1 advancement of orange tier).
docs/decisions/v1.0-kill-criterion.md:188:**Threshold:** ANY confirmed incident in which agent action results in PII (personally-identifiable information per UK GDPR Art. 4(1)) transmitted to an unauthorised party (cross-tenant recipient, unauthorised external recipient, or recipient outside tenant's declared data residency) AND not blocked by the RLS + autosend policy combination.
docs/decisions/v1.0-kill-criterion.md:196:**Action:** KILL. Rationale: multi-tenant trust is the structural foundation of v1.0. A single confirmed PII breach beyond the RLS + autosend boundary indicates the foundation is unsound. Continuing operation risks (a) further breaches, (b) regulatory action, (c) catastrophic loss of pilot trust. Wind-down protects existing pilots from further exposure.
docs/decisions/v1.0-kill-criterion.md:235:**Must-fill before first pilot LOI signs.** The pilot agreement may reference an external advisor for dispute resolution per `autosend-safety-policy.md` §10 placeholder language. Founder identifies and engages within Weeks 1-2.
docs/decisions/v1.0-kill-criterion.md:337:- The autosend safety policy per this Day 5 commit (green + red tiers only)
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/decisions/v1.0-kill-criterion.md:387:**For atomic-correction manifest.** Edit 10 (shared with autosend-safety-policy.md) adds the path drift correction. Manifest grows from 9 to 10.
docs/runbooks/operational-hygiene-protocol.md:26:- **Length discipline C+** — Day 5 autosend policy 658 lines vs 300-500 estimate; Day 6 vertical schema 899 lines vs same estimate
docs/runbooks/operational-hygiene-protocol.md:150:- Day 5 autosend policy: estimated 300-500 lines; actual 648. **+30% to +116% overshoot.**
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:275:| `docs/decisions/autosend-safety-policy.md` | 1 | Same cost-target replacement for the cyber-insurance budget reference |
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/runbooks/operational-hygiene-protocol.md:290:Day-6 structural summary claimed "30+ action_types across 6 v1.0 agents" in autosend policy §3. Actual count: 29 (Green 6 + Yellow 5 + Orange 10 + Red 8). The artefact itself does not make this claim — only my summary message did.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-31-d1-founder-decision.md:1:# Founder Decision D1 — autosend orange-tier path
docs/decisions/2026-05-31-d1-founder-decision.md:15:Per `docs/decisions/autosend-safety-policy.md` §4, orange-tier action_types (customer-facing sends like `xero_reminder_send_customer`, `gmail_outlook_send_to_candidate`, `bullhorn_note_customer_visible`) require **synchronous consultant approval** before the send executes. The agent drafts; the consultant says yes; the transport fires; an audit row records the full chain.
docs/decisions/2026-05-31-d1-founder-decision.md:23:| **D1-C** No autosend; manual pickup | Concierge writes the draft to vault; sets `requires_consultant_action=true`; no notification; consultant manually polls vault and copies drafts to outbound | 0 days build (already supported by drafts-to-vault flow) | Zero risk of incorrect autosend; zero new build | UX is brutal; consultants miss drafts; defeats Concierge's "no candidate ghosted" promise; effectively kills Concierge as a v1.0 differentiator |
docs/decisions/2026-05-31-d1-founder-decision.md:33:3. **Audit chain is identical to D1-A.** Both paths emit the same `decision_log` rows (`xero_reminder_send_customer` orange action → operator approve/reject → transport `gmail_outlook_send_to_candidate` action). The Telegram interaction is the trigger, not the audit substrate.
docs/decisions/2026-05-31-d1-founder-decision.md:44:1. **`packages/utilities/autosend-bridge-telegram/`** — small TypeScript package:
docs/decisions/2026-05-31-d1-founder-decision.md:45:   - `proposeApproval(action_type, target, draft_preview, vault_path, timeout=PT4H) → approval_id`
docs/decisions/2026-05-31-d1-founder-decision.md:48:   - Returns `{outcome: approved | rejected | timeout, decided_by: <telegram_user_id>}`.
docs/decisions/2026-05-31-d1-founder-decision.md:50:2. **Concierge `cycle.sh` Step 11** — calls `proposeApproval` for orange-tier drafts; on `approved`, proceeds to Step 12 transport; on `rejected` or `timeout`, fires `ESC_APPROVAL_BRIDGE_TIMEOUT` (timeout) or records rejection in `decision_log` (rejected).
docs/decisions/2026-05-31-d1-founder-decision.md:52:4. **`tools.yaml` capability declarations** — add `autosend_bridge_telegram` capability to both Concierge and Cash Conductor.
docs/decisions/2026-05-31-d1-founder-decision.md:53:5. **Tenant config — schema-work pending.** The natural storage location for the per-tenant operator Telegram chat-id is `tenant_adapters.config`, BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 — and `operator_telegram_chat_id` is NOT currently in the 6-key allowlist (`cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the 2026-05-31 Janitor key, `blocked_recipients`). Resolution path: **W10-13 Concierge build slice lands a v0.4 supplement** adding `operator_telegram_chat_id` to the allowlist (type: string; required: false; set_by: tenant-admin; read_by: concierge + cash-conductor for the autosend-bridge consumer). Until then, the bridge consumer (`@ifos/autosend-bridge-telegram`) takes the chat-id as a function argument rather than reading it from tenant_adapters — the function-arg shim is already in place per the package scaffold landed 2026-06-01 (commit `9b282d8`). This decision-doc does NOT block on the schema work; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend); the storage-location detail is a W10-13 implementation question.
docs/decisions/2026-05-31-d1-founder-decision.md:64:- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10 ships the `autosend-bridge-telegram` package."
docs/decisions/2026-05-31-d1-founder-decision.md:75:**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commit `669a4f4` + `9ec2bd6`); awaiting Codex ratification via `.codex/ratification/review-architecture-decision.md` skill (cluster G).
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:120:- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
docs/decisions/bullhorn-integration-path.md:269:- Confirm refresh-token rotation atomicity requirements (any Bullhorn-side timeouts that affect persistence windows).
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:66:| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:82:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:95:| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:99:| 6 | `docs/decisions/autosend-approval-bridge-spec.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:185:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:290:| 16 | `autosend-safety-policy.md` §10 pilot-agreement liability | Placeholder — legal review required before first pilot LOI | Pre-LOI legal review (commercial / regulatory). Codex can ratify the placeholder shape but cannot substitute for legal counsel. |
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md:19:| README line citation drift (xero `accounting_reconciliation_write` 209→241) | R2 (new) | Self-inflicted: commit `f414492` (R1 autosend-policy registrations) shifted the line. Citation accuracy is a top-level skill check. | Fix (re-grep + re-cite per R2 ADR-007 lesson) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:16:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:20:**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:44:- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:45:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:164:Implementation work: <commit reference or "in autosend §9 update commit">
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:25:- `agents/_shared/hook-helpers.sh` + `autosend-policy.yaml` (Phase 3, commit `e6e9df1`)
docs/decisions/autosend-approval-bridge-spec.md:6:**Surfaced by:** Founder Decision D1 (`docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`) + Codex Round 1 autosend rejection issue 2
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:18:- `agents/_shared/hook-helpers.sh::autosend_await_approval` writes pending marker `/vault/<tenant>/pending-approvals/<hash>.pending`
docs/decisions/autosend-approval-bridge-spec.md:20:- 4h timeout converts to `ESC_AUTOSEND_NEEDS_REVIEW`
docs/decisions/autosend-approval-bridge-spec.md:68:A new IFOS package: `packages/autosend-approval-bridge/`. ~200-250 lines of TypeScript. Runs as a long-lived process (PM2-managed alongside the daemon).
docs/decisions/autosend-approval-bridge-spec.md:79:  - Map IFOS action_type → cortextOS ApprovalCategory (autosend taxonomy)
docs/decisions/autosend-approval-bridge-spec.md:98:The bridge's `autosend_await_approval` polling loop (already in `hook-helpers.sh`) sees the new marker → returns 0 (approved) or 1 (rejected) → agent proceeds or escalates.
docs/decisions/autosend-approval-bridge-spec.md:102:Mapping `{ifos_payload_hash, cortextos_approval_id, tenant_slug, action_type, created_at, resolved_at}` lives in a small SQLite database at `${CTX_FRAMEWORK_ROOT}/autosend-bridge.db` OR (cleaner) a new Postgres table `autosend_approval_mappings`:
docs/decisions/autosend-approval-bridge-spec.md:105:CREATE TABLE IF NOT EXISTS autosend_approval_mappings (
docs/decisions/autosend-approval-bridge-spec.md:112:  status               TEXT NOT NULL CHECK (status IN ('pending','approved','denied','timeout_expired')),
docs/decisions/autosend-approval-bridge-spec.md:118:ALTER TABLE autosend_approval_mappings ENABLE ROW LEVEL SECURITY;
docs/decisions/autosend-approval-bridge-spec.md:119:CREATE POLICY tenant_isolation ON autosend_approval_mappings
docs/decisions/autosend-approval-bridge-spec.md:121:GRANT SELECT, INSERT, UPDATE ON autosend_approval_mappings TO ifos_app;
docs/decisions/autosend-approval-bridge-spec.md:128:`autosend_approval_mappings` becomes the 10th tenant-data table when the bridge implementation lands. The Week-9 bridge implementation slice MUST update `docs/architecture/tenancy-invariants.md` §1 and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` to include this table in T1-T3, T11, and audit coverage. This remediation corrects the spec only; the table does not exist yet, so the live invariant inventory remains the v0.2 nine-table set until the bridge migration ships.
docs/decisions/autosend-approval-bridge-spec.md:132:cortextOS Primitive 4 enumerates approval categories as `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` per `packages/harness/cortextos/src/types/index.ts`. IFOS action_types from `agents/_shared/autosend-policy.yaml` map as follows:
docs/decisions/autosend-approval-bridge-spec.md:136:| `bullhorn_note_customer_visible` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:137:| `gmail_outlook_send_to_candidate` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:138:| `twilio_sms_send` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:139:| `calendar_invite_send` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:154:🔔 Approval request: Concierge bullhorn_note_customer_visible
docs/decisions/autosend-approval-bridge-spec.md:171:`autosend_await_approval` already enforces 4h default timeout per action_type's `timeout` field in autosend-policy.yaml. If the timeout fires before operator responds:
docs/decisions/autosend-approval-bridge-spec.md:173:1. IFOS-side: poll loop exits → `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` → agent gives up
docs/decisions/autosend-approval-bridge-spec.md:174:2. cortextOS-side: approval file stays in `pending/` indefinitely (no auto-timeout) — **THIS IS A LEAK**
docs/decisions/autosend-approval-bridge-spec.md:176:**Bridge fix:** on IFOS-side timeout, the bridge MUST call `updateApproval(approvalId, 'denied', note='ifos_timeout')` to clean up the pending file. Otherwise stale pending approvals accumulate in cortextOS.
docs/decisions/autosend-approval-bridge-spec.md:183:| Operator never responds (4h timeout) | Bridge cleans up cortextOS pending file via `updateApproval(..., 'denied', 'ifos_timeout')` |
docs/decisions/autosend-approval-bridge-spec.md:185:| Postgres unreachable | Write bridge state to fallback JSONL at `/vault/_meta/autosend-bridge.jsonl`; same replay pattern as decision_log fallback |
docs/decisions/autosend-approval-bridge-spec.md:199:packages/autosend-approval-bridge/
docs/decisions/autosend-approval-bridge-spec.md:200:├── package.json              ← @ifos/autosend-approval-bridge; Node 20+
docs/decisions/autosend-approval-bridge-spec.md:226:Adding `autosend_approval_mappings` table requires:
docs/decisions/autosend-approval-bridge-spec.md:231:Total schema impact: 1 new table; tenancy-invariants.md grows from 12 to 13 invariants (T13: autosend_approval_mappings tenant_slug + RLS), or we count this as covered by T1-T3 already (cleaner).
docs/decisions/autosend-approval-bridge-spec.md:239:| A1 | Bridge process starts via PM2 + connects to Postgres + reads bridge state | `pm2 status ifos-autosend-bridge` shows online; bridge starts fresh on empty DB |
docs/decisions/autosend-approval-bridge-spec.md:242:| A4 | 4h timeout: bridge calls `updateApproval(..., 'denied', 'ifos_timeout')` cleanly | Integration test: write `.pending` marker, advance simulated clock 4h, assert cortextOS `pending/` is empty + `resolved/` has `denied` record |
docs/decisions/autosend-approval-bridge-spec.md:245:| A7 | category mapping table covers all 10 v1.0 orange action_types | Lint test: every orange action_type in autosend-policy.yaml has a mapping entry |
docs/decisions/autosend-approval-bridge-spec.md:246:| A8 | Bridge state row in `autosend_approval_mappings` exists for every pending approval | Audit query: count(pending markers) == count(pending bridge state rows) |
docs/decisions/autosend-approval-bridge-spec.md:268:- **Building the IFOS-side `autosend_await_approval` polling loop** — already exists in `hook-helpers.sh` (Phase 3)
docs/decisions/autosend-approval-bridge-spec.md:285:| 6 | RLS on autosend_approval_mappings forgotten | Migration includes ENABLE ROW LEVEL SECURITY; tenancy audit T2 catches if missing |
docs/decisions/autosend-approval-bridge-spec.md:291:- Approval batching ("approve all 5 pending bullhorn_note_customer_visible at once") → v1.1+
docs/decisions/autosend-approval-bridge-spec.md:306:- Adds 1 tenant-data table (`autosend_approval_mappings`) → tenancy-invariants.md update OR considered covered by T1-T3 patterns
docs/decisions/autosend-approval-bridge-spec.md:307:- Adds 1 PM2-managed process (`ifos-autosend-bridge`) → ecosystem.config.js update
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:102:| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
docs/decisions/autosend-safety-policy.md:103:| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
docs/decisions/autosend-safety-policy.md:104:| Concierge | `twilio_sms_send` | Outbound SMS; high-trust channel; cost-per-send; irreversible |
docs/decisions/autosend-safety-policy.md:105:| Concierge | `calendar_invite_send` | Creates calendar event with attendee notification; visible to attendee |
docs/decisions/autosend-safety-policy.md:143:#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
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
docs/decisions/autosend-safety-policy.md:188:      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
docs/decisions/autosend-safety-policy.md:189:      autosend_await_approval "$action_type" "$target" "$payload_hash"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:223:  - bullhorn_note_customer_visible   # orange (CANONICAL — bullhorn-integration-path §4.1)
docs/decisions/autosend-safety-policy.md:224:  - gmail_outlook_send_to_candidate  # orange
docs/decisions/autosend-safety-policy.md:225:  - calendar_invite_send             # orange
docs/decisions/autosend-safety-policy.md:226:  - twilio_sms_send                  # orange
docs/decisions/autosend-safety-policy.md:245:  "action_type": "<enum from autosend-policy.yaml>",
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:259:2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:272:Action: bullhorn_note_customer_visible
docs/decisions/autosend-safety-policy.md:300:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`
docs/decisions/autosend-safety-policy.md:301:2. `autosend_escalate ESC_AUTOSEND_BLOCKED` notifies tenant operator informationally (no action required)
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:339:2. `autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED` notifies tenant operator AND IFOS oncall
docs/decisions/autosend-safety-policy.md:352:| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:357:| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
docs/decisions/autosend-safety-policy.md:358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
docs/decisions/autosend-safety-policy.md:379:-- For autosend audit:
docs/decisions/autosend-safety-policy.md:381:--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
docs/decisions/autosend-safety-policy.md:391:--     "approval_status": "<pending|approved|rejected|timeout_rejected|escalated>",
docs/decisions/autosend-safety-policy.md:394:--     "policy_version_sha": "<git SHA of autosend-policy.yaml at execution>"
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:430:  'autosend_policy',
docs/decisions/autosend-safety-policy.md:445:    "approval_timeouts": {
docs/decisions/autosend-safety-policy.md:447:      "twilio_sms_send": "PT30M",
docs/decisions/autosend-safety-policy.md:465:5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
docs/decisions/autosend-safety-policy.md:510:docs/decisions/autosend-safety-policy.md in the IFOS code repository)
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |

exec
/bin/zsh -lc 'rg -n "ESC_BULLHORN_AUTH|ESC_RATE_LIMIT_HIT|ESC_MS_GRAPH_AUTH|ESC_GMAIL_AUTH|ESC_LIFECYCLE_STATE_UNKNOWN|ESC_ADDRESSEE_MISMATCH|ESC_VOICE_DRIFT|ESC_TONE_RULE_VIOLATION|ESC_PII_LEAKAGE_RISK|ESC_CONCIERGE_SLA_MISS|ESC_APPROVAL_BRIDGE_TIMEOUT|ESC_SEND_FAIL|ESC_AGENT_OUTPUT_SHAPE|ESC_GATE_B_MISS|ESC_AUTOSEND_ORANGE_PENDING|ESC_AUTOSEND_SAMPLED_SPOT_CHECK|ESC_AUTOSEND_BLOCKED|ESC_SCHEMA_VIOLATION|ESC_VOICE_DRIFT_TENANT|ESC_CANDIDATE_DATA_INCOMPLETE" agents/_shared/escalation-codes.md -S' in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc 'rg -n "tenant_adapters|decision_log|recent_edit|voice_corpus|tone_rule|candidate_id|placement_id|event_type|recipient|voice_score|concierge|bullhorn|Microsoft Graph|Gmail|Graph|tenant" docs/verticals/recruitment -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:13:# added closing Janitor R11 Finding 4 + blocked_recipients added closing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# Sourcing Scout R8 Finding 1. blocked_recipients is pre-v0.3 origin
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:85:          - Sourcing Scout: R   # R-only per bullhorn-integration-path §4.1 A5 + sourcing-scout/agent.md §6; proposed-match skills live in the shortlist artefact, never written to the candidate entity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:101:          - Sourcing Scout: R   # R-only per bullhorn-integration-path §4.1 A5 + sourcing-scout/agent.md §6; proposed-match URLs live in the shortlist artefact
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:197:          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:300:#     per bullhorn-integration-path §4.1 A5 + sourcing-scout/agent.md §6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:304:#     activity-log links per concierge §4 Step 13-14 — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:308:#     concierge §4 Step 14 — v0.3 amendment)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:311:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:313:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:327:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:328:  # voice_corpus_chunks is introduced separately around v0.2 supplement line
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:335:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:359:  #   agent + which fields were touched in decision_log payload; reviewers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:369:  # decision_log row records who wrote. Entity-level RLS enforces TENANT
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:395:    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:411:    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:429:    # on Bullhorn-backed entities per bullhorn-integration-path §4.1 A5 +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:431:    # in the Sourcing Scout shortlist artefact (vault markdown + decision_log
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:443:  concierge:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:445:    # JobOrder / Note / Placement) per bullhorn-integration-path.md §4.1
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:448:    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:451:    contact: R             # IFOS-cached read; outbound recipient resolution (Bullhorn endpoint A6 — Note context)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:454:    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:554:      - Sourcing Scout (R)   # R-only — proposed matches live in the shortlist artefact, NOT the Bullhorn-backed candidate entity (per bullhorn-integration-path §4.1 A5 + sourcing-scout/agent.md §6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:560:      candidate write (R+W would contradict bullhorn-integration-path §4.1 A5,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:584:      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:587:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:594:      Diagnostic + Sourcing Scout also read tone_rules for their
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:597:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:609:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:629:      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:636:      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:644:      - "(tenant_slug, posted_at DESC)"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:645:      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:655:      implementation lands as W4 polish. Per-tenant DPA addendum signed
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:656:      by founder + tenant before go-live; migration-test tenant exempt.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:665:      tenant_slug: {type: string, required: true, source: IFOS-internal}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:667:      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:682:      - "(tenant_slug, due_at)"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:683:      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:684:      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:694:      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:695:      per §3 cash_conductor_transactions.retention). Migration-test tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:696:      data is exempt; pilot tenants require the DPA addendum signed before
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:700:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:701:    # v0.2 auxiliary table — voice exemplar corpus (per-tenant)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:709:    concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:710:  voice_corpus_chunks:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:718:    concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:719:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:720:    # v0.2 auxiliary table — per-tenant tone constraints
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:727:    concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:728:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:738:    concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:745:    concierge: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:752:    concierge: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:773:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:776:    set_by: concierge
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:777:    read_by: [concierge]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:782:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:790:    set_by: [tenant-admin]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:791:    read_by: [concierge]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:805:      Per-tenant outbound sending hours. Concierge respects when scheduling
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:813:    set_by: [tenant-admin]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:816:      Per-tenant dedup confidence threshold for candidate merges. v1.0 default
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:823:  blocked_recipients:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:829:    set_by: [tenant-admin, janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:830:    read_by: [concierge, sourcing-scout, cash-conductor, janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:832:      Per-tenant DNC (do not contact) list. v1.0 canonical source for outbound
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:834:      `send_to_blocked_recipient`) and pre-outbound sourcing filter (Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:861:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:864:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:865:  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:880:      until the voice classifier microservice ships + first pilot tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:894:    - validate_voice_scores trigger active on entities table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:896:    - migration-test tenant row exists in tenants table
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:909:      the v0.2 validate_voice_scores binding while forwarding v0.2 voice-
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:918:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:957:        (array of allowed strings); validate at write time against tenant's list.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:959:    trigger_for_revisit: First pilot tenant onboarding; if pilot uses any value
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:978:         (bullhorn_state TEXT, ifos_state TEXT, tenant_slug TEXT).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:994:      tenant requires shorter retention, escalate to C with tenant-specific
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:998:      cash_conductor_transactions table is GATED by an explicit per-tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:999:      DPA addendum signed by founder + tenant. Migration-test tenant data
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1007:      C: Per-tenant override (tenant-admin can flip behavior for their tenant).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1009:    trigger_for_revisit: If v1.1 tenant-config experimentation surfaces need
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1021:  new + 2 Janitor + 1 blocked_recipients pre-v0.3 canonicalised). The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1040:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1042:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:14:#   Drafted alongside; executed against migration-test tenant in Phase 5.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:39:#   policies on per-table tenant_slug — both of which are simpler with first-class
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:50:#   primitive layer; they are validated by the `validate_voice_scores` trigger
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:59:    bullhorn_source: none (IFOS-derived from /vault/<tenant>/_voice/ ingest)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:65:      tenant_slug:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:69:        notes: RLS-isolated per tenant. Maps to entities.tenant_slug at row level.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:86:          Items enum: ["vault_emails", "bullhorn_notes", "marketing_copy", "founder_curated", "consultant_drafts"]. Order documents provenance for the LoRA pipeline (v2.0 Scale tier).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:126:    bullhorn_source: none (IFOS-derived; authored in /vault/<tenant>/_voice/tone-rules.yaml then synced to Postgres)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:132:      tenant_slug:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:168:          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:192:    bullhorn_source: none (IFOS-derived from operator's approve/edit UX)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:198:      tenant_slug:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:223:        notes: bullhorn_id or IFOS slug. Used in the entity_links join below.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:252:      tone_rules_triggered:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:270:    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:274:    index_type: hnsw                                 # HNSW preferred over IVFFlat for v1.0 corpus sizes (<10k chunks/tenant)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:280:    v1_0_query_volume_estimate: 10-50 queries per agent session × ~5 active agents × 24/7 = ~10k queries/day/tenant (well within pgvector + HNSW comfortable load).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:341:  voice_corpus_governs_tone_rules:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:342:    source: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:343:    target: tone_rule
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:346:      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:352:    target: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:366:  status: drafted (Phase 4); execution against migration-test tenant scheduled for Phase 5
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:384:  Q11_voice_corpus_chunk_storage:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:388:      - A: Store both — duplicates ~50MB/tenant but enables fast retrieval without vault round-trip
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:390:    v0_2_default: A (store both); revise to B if disk pressure surfaces at >50 tenants
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:391:    trigger_for_revisit: tenant count > 50 OR pgvector storage > 10% of total disk
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:393:  Q12_tone_rule_severity_block_path:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:409:      - C: Text bodies purged after pilot ends (tenant-controlled retention)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:433:      Live migration deferred to Phase 5 against migration-test tenant first;
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:438:      Phase 5 — execute migration SQL against migration-test tenant; verify pgvector HNSW index builds clean; voice-loader.sh queries return expected shape; commit.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.yaml:4:#   - entities (id, tenant_slug, entity_type, entity_id, data JSONB, version, ...)
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:11:#       + bullhorn-integration-path.md §4.1 (per-agent endpoint requirements)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:34:#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
docs/verticals/recruitment/vertical-schema.yaml:51:    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
docs/verticals/recruitment/vertical-schema.yaml:53:      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:54:      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:55:      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:56:      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:58:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:115:        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:140:        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
docs/verticals/recruitment/vertical-schema.yaml:147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:156:    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:166:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:192:        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
docs/verticals/recruitment/vertical-schema.yaml:224:    bullhorn_source: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:226:      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:227:      - Sourcing Scout (R — target-firm context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:228:      - Concierge (R — relationship context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:230:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:286:    bullhorn_source: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:288:      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
docs/verticals/recruitment/vertical-schema.yaml:291:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:344:    bullhorn_source: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:347:      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:348:      - Scribe (R — write-context resolution per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:349:      - Sourcing Scout (R — active brief context per bullhorn §4.1 A5)
docs/verticals/recruitment/vertical-schema.yaml:350:      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:352:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:432:    bullhorn_source: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:435:      - Scribe (R+W — note links per bullhorn §4.1 A3)
docs/verticals/recruitment/vertical-schema.yaml:436:      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:438:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:498:    bullhorn_source: Bullhorn.JobSubmission (or Bullhorn.Opportunity — tenant-config dependent; some tenants use one, some both)
docs/verticals/recruitment/vertical-schema.yaml:500:      - "none (v1.1+ exercise per bullhorn §4.1; Inbound Triage primary reader)"
docs/verticals/recruitment/vertical-schema.yaml:505:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:538:    bullhorn_source: Bullhorn.Timesheet (Bullhorn has a Timesheet entity; tenant-config dependent)
docs/verticals/recruitment/vertical-schema.yaml:545:      bullhorn_id:
docs/verticals/recruitment/vertical-schema.yaml:615:    v1_0_exercise: Concierge reads for addressee-resolution per bullhorn §4.1 A6 Voice gate; addressee = primary decision-maker contact.
docs/verticals/recruitment/vertical-schema.yaml:666:# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
docs/verticals/recruitment/vertical-schema.yaml:736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:739:bullhorn_mapping:
docs/verticals/recruitment/vertical-schema.yaml:742:    bullhorn_entity: Bullhorn.Candidate
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:748:    bullhorn_entity: Bullhorn.Candidate
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:755:    bullhorn_entity: Bullhorn.ClientCorporation
docs/verticals/recruitment/vertical-schema.yaml:757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:761:    bullhorn_entity: Bullhorn.ClientContact
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:766:    bullhorn_entity: Bullhorn.JobOrder
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:769:    notes: Skills extraction (required_skills, nice_to_have_skills arrays) is IFOS-derived from JD body, not Bullhorn-sourced (Bullhorn does not consistently structure skill fields across tenants).
docs/verticals/recruitment/vertical-schema.yaml:772:    bullhorn_entity: Bullhorn.Placement
docs/verticals/recruitment/vertical-schema.yaml:774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:778:    bullhorn_entity: Bullhorn.JobSubmission (or Bullhorn.Opportunity depending on tenant configuration)
docs/verticals/recruitment/vertical-schema.yaml:781:    notes: Tenant-config dependent — some Bullhorn tenants use JobSubmission, some use Opportunity, some both. Adapter layer resolves at ingest.
docs/verticals/recruitment/vertical-schema.yaml:784:    bullhorn_entity: Bullhorn.Timesheet
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:808:  Q3_full_bullhorn_field_set:
docs/verticals/recruitment/vertical-schema.yaml:810:    v0_1_decision: v0.1 ships minimal v1.0 working set (~10-20 fields per entity) covering what the 6 v1.0 agents actually touch per bullhorn §4.1.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/vertical-schema.yaml:841:    revisit_trigger: Skill-matching accuracy from Sourcing Scout's first 4 tenant-weeks of operation; if free-text matching produces <60% precision, canonical skill taxonomy lands as v1.1.
docs/verticals/recruitment/vertical-schema.yaml:848:    revisit_trigger: If pilot tenants surface frequent contact-employer-changes (>5% of contacts change employer over 90 days), revise to M:N (contact_history) with current-employer flag.
docs/verticals/recruitment/vertical-schema.yaml:870:      canonical_fields.<name>.source values are free-text strings in v0.1. Two patterns used: (a) entity.field paths like `Bullhorn.Candidate.firstName`; (b) free-text with citation like `IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)`.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:19:DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:20:DROP FUNCTION IF EXISTS validate_voice_score_fields();
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:26:DROP TABLE IF EXISTS recent_edit          CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:27:DROP TABLE IF EXISTS tone_rule            CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:28:DROP TABLE IF EXISTS voice_corpus_chunks  CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:29:DROP TABLE IF EXISTS voice_corpus         CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:6:-- side effects on existing recent_edit data).
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:15:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:18:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:19:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:21:DROP INDEX IF EXISTS recent_edit_text_purged_idx;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:23:ALTER TABLE recent_edit
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:63:-- D3-C compatibility: tenants can request extended retention via TOS
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:69:-- The v0.1 PII purge cron uses one global --retention-days value; per-tenant
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:70:-- override reads land when first tenant requests extended retention.
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:78:--   WHERE table_name='recent_edit' AND column_name='text_purged_at';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:82:--   WHERE table_name='recent_edit' AND column_name='original_text';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:86:--   WHERE table_name='recent_edit' AND constraint_name='recent_edit_text_purged_consistency';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:90:--   WHERE tablename='recent_edit' AND indexname='recent_edit_text_purged_idx';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:14:-- rows are DELETED. Operator must export to JSON via /vault/<tenant>/exports/
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:68:-- v0.2 validate_voice_scores function is preserved in the schema (we replaced
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:73:  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validate_voice_score_fields') THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:74:    RAISE EXCEPTION 'v0.2 validate_voice_scores function missing — rollback cannot complete; re-apply v0.1-to-v0.2.sql §4 to restore';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:80:DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:81:CREATE TRIGGER validate_voice_scores
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:84:  EXECUTE FUNCTION validate_voice_score_fields();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:87:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:91:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:93:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:95:-- tenant_adapters config validation trigger.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:7:--               Execute against migration-test tenant first via run-live-migration.sh.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:12:--     (both RLS-isolated per tenant_slug)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:17:--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:26:--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:29:--   - migration-test tenant row exists in tenants table
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:43:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:44:    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:46:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus_chunks') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:47:    RAISE EXCEPTION 'v0.2 voice_corpus_chunks table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:49:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:50:    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:64:  tenant_slug        TEXT NOT NULL,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:89:  CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:92:CREATE INDEX IF NOT EXISTS idx_cct_tenant_posted
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:93:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:95:CREATE INDEX IF NOT EXISTS idx_cct_tenant_unmatched
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:96:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:105:DROP POLICY IF EXISTS cct_tenant_isolation ON cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:108:  USING (tenant_slug = current_setting('app.current_tenant', true));
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:119:  tenant_slug              TEXT NOT NULL,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:149:  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:152:CREATE INDEX IF NOT EXISTS idx_cci_tenant_due
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:153:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:CREATE INDEX IF NOT EXISTS idx_cci_tenant_overdue
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:156:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:159:CREATE INDEX IF NOT EXISTS idx_cci_tenant_chase
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:160:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:166:-- Idempotent (see cct_tenant_isolation note above).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:167:DROP POLICY IF EXISTS cci_tenant_isolation ON cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:168:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:170:  USING (tenant_slug = current_setting('app.current_tenant', true));
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:207:-- The v0.2 migration installed validate_voice_scores trigger which validates
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:409:DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:419:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:434:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:441:    'concierge_last_poll',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:442:    'concierge_send_window'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:453:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:461:  IF c ? 'concierge_send_window' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:462:    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:      RAISE EXCEPTION 'concierge_send_window must be object';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:465:    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:466:      RAISE EXCEPTION 'concierge_send_window must include timezone';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:468:    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:469:       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:470:      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:472:    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:473:       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:474:      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:485:  IF c ? 'concierge_last_poll' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:486:    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:487:      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:510:  -- blocked_recipients: array of strings (pre-v0.3 origin; canonicalised here).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:512:  -- elements rather than deferring to the tenant-admin wizard, matching the YAML
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:514:  IF c ? 'blocked_recipients' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:515:    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:516:      RAISE EXCEPTION 'blocked_recipients must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:518:    FOR elem IN SELECT * FROM jsonb_array_elements(c->'blocked_recipients') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:520:        RAISE EXCEPTION 'blocked_recipients items must be strings; got %', jsonb_typeof(elem);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:529:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:531:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:532:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:534:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:7:--               Phase 5 executes against migration-test tenant first.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:11:--   - 1 auxiliary table: voice_corpus_chunks (holds the pgvector index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:23:--   - RLS policies on entities + entity_links + decision_log already in place
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:43:-- §2 — Create voice_corpus table (per-tenant voice pack)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:46:CREATE TABLE IF NOT EXISTS voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:48:  tenant_slug           TEXT        NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:59:  CONSTRAINT voice_corpus_tenant_version_unique UNIQUE (tenant_slug, version)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:62:-- Partial unique index: at most one active voice_corpus per tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:63:CREATE UNIQUE INDEX IF NOT EXISTS voice_corpus_one_active_per_tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:64:  ON voice_corpus (tenant_slug)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:67:CREATE INDEX IF NOT EXISTS voice_corpus_tenant_slug_idx ON voice_corpus (tenant_slug);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:69:ALTER TABLE voice_corpus ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:70:ALTER TABLE voice_corpus FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:71:DROP POLICY IF EXISTS voice_corpus_tenant_isolation ON voice_corpus;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:72:CREATE POLICY voice_corpus_tenant_isolation ON voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:73:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:76:-- §3 — Create voice_corpus_chunks table (pgvector substrate)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:78:-- One row per chunk produced from voice_corpus source docs. Embedding column
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:82:CREATE TABLE IF NOT EXISTS voice_corpus_chunks (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:84:  tenant_slug       TEXT        NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:85:  voice_corpus_id   BIGINT      NOT NULL REFERENCES voice_corpus (id) ON DELETE CASCADE,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:91:  CONSTRAINT voice_corpus_chunks_corpus_chunk_unique UNIQUE (voice_corpus_id, chunk_index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:94:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_tenant_idx ON voice_corpus_chunks (tenant_slug);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:95:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_corpus_idx ON voice_corpus_chunks (voice_corpus_id);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:99:  ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:103:ALTER TABLE voice_corpus_chunks ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:104:ALTER TABLE voice_corpus_chunks FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:105:DROP POLICY IF EXISTS voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:106:CREATE POLICY voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:107:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:110:-- §4 — Create tone_rule table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:113:CREATE TABLE IF NOT EXISTS tone_rule (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:115:  tenant_slug         TEXT        NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:121:  created_by          TEXT        NOT NULL CHECK (created_by IN ('founder', 'tenant-admin', 'ifos-csm')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:126:  CONSTRAINT tone_rule_tenant_rule_id_unique UNIQUE (tenant_slug, rule_id)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:129:CREATE INDEX IF NOT EXISTS tone_rule_tenant_enabled_idx ON tone_rule (tenant_slug, enabled);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:131:ALTER TABLE tone_rule ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:132:ALTER TABLE tone_rule FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:133:DROP POLICY IF EXISTS tone_rule_tenant_isolation ON tone_rule;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:134:CREATE POLICY tone_rule_tenant_isolation ON tone_rule
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:135:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:138:-- §5 — Create recent_edit table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:141:CREATE TABLE IF NOT EXISTS recent_edit (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:143:  tenant_slug            TEXT        NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:153:  tone_rules_triggered   TEXT[]      NOT NULL DEFAULT '{}',
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:160:CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:161:CREATE INDEX IF NOT EXISTS recent_edit_tenant_action_idx ON recent_edit (tenant_slug, action_type, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:162:CREATE INDEX IF NOT EXISTS recent_edit_lookback_idx ON recent_edit (tenant_slug, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:164:ALTER TABLE recent_edit ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:165:ALTER TABLE recent_edit FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:166:DROP POLICY IF EXISTS recent_edit_tenant_isolation ON recent_edit;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:167:CREATE POLICY recent_edit_tenant_isolation ON recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:168:  USING (tenant_slug = current_setting('app.current_tenant', TRUE));
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:199:--   ALTER TABLE voice_corpus OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:200:--   ALTER TABLE voice_corpus_chunks OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:201:--   ALTER TABLE tone_rule OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:202:--   ALTER TABLE recent_edit OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:203:--   ALTER SEQUENCE voice_corpus_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:204:--   ALTER SEQUENCE voice_corpus_chunks_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:205:--   ALTER SEQUENCE tone_rule_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:206:--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:221:CREATE OR REPLACE FUNCTION validate_voice_score_fields()
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:246:CREATE OR REPLACE TRIGGER validate_voice_scores
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:250:  EXECUTE FUNCTION validate_voice_score_fields();
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:280:-- §9 — Reference rows: seed migration-test tenant with a starter voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:282:-- Inserts a single empty active voice_corpus row for migration-test only.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:287:SET LOCAL app.current_tenant = 'migration-test';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:289:INSERT INTO voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:290:  tenant_slug, version, source_doc_count, source_doc_origin,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:304:) ON CONFLICT (tenant_slug, version) DO NOTHING;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:313:-- SELECT count(*) FROM voice_corpus WHERE tenant_slug = 'migration-test';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:315:-- SELECT indexname FROM pg_indexes WHERE tablename = 'voice_corpus_chunks';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:316:--   → expect: voice_corpus_chunks_pkey, voice_corpus_chunks_tenant_idx,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:317:--             voice_corpus_chunks_corpus_idx, voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:321:--   → expect validate_voice_scores

codex
The shared autosend and ESC catalog entries mostly exist, including the newer Concierge action types. I’m narrowing on the authoritative planning docs now because this artefact leans heavily on exact line claims.
exec
/bin/zsh -lc 'rg --files docs | rg -i "master|ultra|plan|brief|kill|operational|ADR-007|autosend"' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/_archive-build-pack/06-BUILD-PLAN.md
docs/operations/codex-ratification-execution-plan.md
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/pii-purge-operational-pattern.md
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/ULTRAPLAN.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/execution-plan.md

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '80,335p'" in /Users/madsadmin/code/CortexOS
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
   283	    timeout: PT30M
   284	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   285	    irreversible: true
   286	
   287	  calendar_invite_send:
   288	    tier: orange
   289	    agent: concierge
   290	    timeout: PT4H
   291	    reason: "Creates calendar event with attendee notification; visible to attendee"
   292	    irreversible: true
   293	
   294	  email_summary_to_customer:
   295	    tier: orange
   296	    agent: scribe
   297	    timeout: PT4H
   298	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   299	    irreversible: true
   300	
   301	  xero_reminder_send_customer:
   302	    tier: orange
   303	    agent: cash-conductor
   304	    timeout: PT24H
   305	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   306	    irreversible: true
   307	
   308	  diagnostic_email_send:
   309	    tier: orange
   310	    agent: diagnostic
   311	    timeout: PT4H
   312	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   313	    irreversible: true
   314	
   315	  diagnostic_calendar_invite:
   316	    tier: orange
   317	    agent: diagnostic
   318	    timeout: PT4H
   319	    reason: "Books intro call with prospect; reputation + scheduling friction"
   320	    irreversible: true
   321	
   322	  linkedin_inmail_send:
   323	    tier: orange
   324	    agent: sourcing-scout
   325	    timeout: PT4H
   326	    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"
   327	    irreversible: true
   328	
   329	  bullhorn_placement_terminate:
   330	    tier: orange
   331	    agent: janitor
   332	    timeout: PT4H
   333	    reason: "Marks placement as terminated; commercial/legal implications; reversible only via support ticket"
   334	    irreversible: false
   335	

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
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '1,470p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Concierge — no candidate ghosted
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice (see §10).
     5	**Date:** 2026-05-24.
     6	**Author:** Founder (Maddox) + Claude Code.
     7	**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
     8	**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
     9	**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
    10	
    11	---
    12	
    13	## §1 — Output contract (one-paragraph screenshot)
    14	
    15	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    16	
    17	> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
    18	
    19	---
    20	
    21	## §2 — Invocation surface
    22	
    23	### Lifecycle webhook (v1.0 primary)
    24	
    25	```http
    26	# Bullhorn placement state-change webhook → Concierge handler
    27	POST https://<tenant>.ifos.app/agents/concierge/webhook
    28	Authorization: Bearer <bullhorn-shared-secret>
    29	Content-Type: application/json
    30	
    31	{
    32	  "event_type": "placement.state_changed" | "candidate.state_changed",
    33	  "entity_id": "<bullhorn-id>",
    34	  "from_state": "interview_scheduled",
    35	  "to_state": "interview_completed",
    36	  "timestamp": "<ISO>"
    37	}
    38	```
    39	
    40	Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha — see Step 1 polling fallback.
    41	
    42	### Cron (polling fallback + time-elapsed nurture)
    43	
    44	```bash
    45	# Every 5 min: poll Bullhorn for missed state transitions
    46	*/5 * * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode poll
    47	# Daily 09:00 UTC: time-elapsed nurture sweeps (7d / 30d / 90d check-ins)
    48	0 9 * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode nurture-sweep
    49	```
    50	
    51	### Manual (debugging)
    52	
    53	```bash
    54	ifosctl concierge generate --tenant <slug> --candidate <id> --event <event-type>
    55	ifosctl concierge replay --tenant <slug> --webhook-id <id>
    56	```
    57	
    58	### v1.1+ surfaces (deferred)
    59	
    60	- agent-identity email adapter (deferred) integration (agent-identity sends for non-rejection comms)
    61	- Brain UI lifecycle-event timeline viewer per candidate
    62	- Per-tenant comms-type taxonomy customisation
    63	
    64	---
    65	
    66	## §3 — Output shape
    67	
    68	One output per lifecycle event: an email draft (yellow tier `concierge_email_draft` per autosend-policy.yaml; only the customer-facing SEND is orange tier — `gmail_outlook_send_to_candidate` / `bullhorn_note_customer_visible` / `twilio_sms_send` / `calendar_invite_send` per channel). 12 lifecycle events × per-tenant comms-template variants:
    69	
    70	| # | Event | Comms type | Recipient | Tone |
    71	|---|---|---|---|---|
    72	| 1 | Application received | Acknowledgement | Candidate | Warm, professional, sets expectations on response timeline |
    73	| 2 | Interview booked | Prep | Candidate | Practical (date, time, format, interviewers) + role context |
    74	| 3 | Interview completed | Debrief | Candidate | Thank-you + next-step clarity OR "we'll be in touch by X" |
    75	| 4 | Offer extended | Placement-positive | Candidate | Excited, clear on terms, addressee-resolution-critical |
    76	| 5 | Offer accepted | Placement-confirm | Candidate + Client (separate drafts) | Reassurance + practical next steps |
    77	| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) — respectful, specific, leaves door open |
    78	| 7 | Withdrawn (candidate-initiated) | Acknowledgement | Candidate | Respectful, no pressure, leaves door open |
    79	| 8 | On-hold | Status-update | Candidate | Honest about timeline, sets expectations on next update |
    80	| 9 | Start date confirmed | Placement-pre-start | Candidate + Client | Practical (HR forms, IT setup, day-1 logistics) |
    81	| 10 | 7-day check-in (post-start) | Nurture-check-in | Candidate | "How's it going? Any blockers?" — short, low-pressure |
    82	| 11 | 30-day check-in | Nurture-check-in | Candidate + Client | Slightly longer; both sides; reads for placement-risk signals |
    83	| 12 | 90-day check-in | Nurture-check-in + relationship | Candidate + Client | Establishes ongoing relationship; offers "is there anyone in your network looking?" |
    84	
    85	Draft structure per event:
    86	
    87	```yaml
    88	draft_id: <uuid>
    89	event_type: <one of 12 above>
    90	candidate_id: <bullhorn-id>
    91	placement_id: <bullhorn-id or null>
    92	recipient: <candidate-email | client-contact-email>
    93	recipient_role: candidate | client_contact
    94	subject: <subject line; voice-classified>
    95	body_markdown: <body; voice-classified>
    96	voice_score: <0-1>
    97	addressee_resolution_check: passed | failed
    98	attached_documents: <list — e.g., feedback summary, prep guide, comms history>
    99	escalation_position: 1-3 (for sensitive sends like rejection)
   100	expected_send_window: <ISO; respects sending-hours per tenant config>
   101	```
   102	
   103	Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
   104	
   105	The actual SEND is a separate orange-tier action_type:
   106	- `gmail_outlook_send_to_candidate` (orange tier per autosend-policy.yaml §ORANGE) when channel=email
   107	- `bullhorn_note_customer_visible` (orange tier; canonical orange per autosend-policy.yaml §ORANGE) when channel=Bullhorn note with isExternal=true
   108	- `twilio_sms_send` (orange tier per autosend-policy.yaml §ORANGE) when channel=SMS (v1.1+)
   109	- `calendar_invite_send` (orange tier per autosend-policy.yaml §ORANGE) when event includes calendar attachment
   110	
   111	Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
   112	
   113	---
   114	
   115	## §4 — Workflow
   116	
   117	15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   118	
   119	```
   120	0. Session start (webhook OR poll OR cron)
   121	   → context.sh hydrates: tenant config + Bullhorn auth refresh +
   122	     Microsoft Graph / Gmail auth + agent-identity email adapter (deferred) (if v1.1+ enabled) +
   123	     voice corpus + tone rules + recent_edits + tenant comms-template
   124	     library + addressee-resolution data
   125	   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")
   126	
   127	1. Source detection (mode-dependent)
   128	   → mode=webhook: parse Bullhorn payload → resolve entity + state transition
   129	   → mode=poll: query Bullhorn for placements/candidates with state_changed_at
   130	     > tenant_adapters.config.concierge_last_poll AND not in decision_log
   131	     (anti-duplicate)
   132	   → mode=nurture-sweep: query Bullhorn placements for time-elapsed events
   133	     (7d/30d/90d post-start with no concierge action in last 14d)
   134	   → ESC_LIFECYCLE_STATE_UNKNOWN if state transition not in 12-event taxonomy
   135	   → hh_decision_output("lifecycle_event_detected",
   136	     "<entity_type>:<bullhorn_id>", "<from>→<to>")
   137	
   138	2. Anti-duplicate guard
   139	   → query decision_log for prior `concierge_email_draft` row for same
   140	     (candidate_id, payload.event_type) in last 24h with phase IN
   141	     ('output', 'action') — if a prior draft was emitted AND either sent OR
   142	     is still pending consultant action, the new event is a duplicate trigger
   143	   → if found AND send-completed: skip (true duplicate)
   144	   → if found BUT prior draft never sent (no `gmail_outlook_send_to_candidate`
   145	     follow-up action row): allow the new draft attempt (per Q7 disposition)
   146	   → hh_decision_output("anti_duplicate_check", "<entity_type>:<bullhorn_id>",
   147	     "<duplicate_status>")
   148	
   149	3. Bullhorn context fetch
   150	   → bullhorn.get_candidate(candidate_id) → name, current state, comms history
   151	   → bullhorn.get_placement(placement_id) → role, client, dates
   152	   → bullhorn.get_client(client_id) → company name, primary contact
   153	   → bullhorn.get_contact(contact_id) → name, email
   154	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
   155	     ESC_BULLHORN_AUTH on auth fail
   156	   → ESC_AGENT_OUTPUT_SHAPE if critical Bullhorn context fields missing
   157	     (no email, no name) — Concierge cannot produce its declared output
   158	     shape (lifecycle-event draft) without a resolvable target candidate.
   159	     NOTE: ESC_CANDIDATE_DATA_INCOMPLETE is reserved for Sourcing Scout
   160	     shortlist completeness per catalogue §2.10.
   161	   → hh_decision_output("bullhorn_context_fetched",
   162	     "candidate:<bullhorn_id>", "fields_present:<N>")
   163	
   164	4. Addressee resolution (Gate A critical)
   165	   → recipient = candidate.email OR client_contact.email per event_type
   166	   → verify recipient matches the candidate_id whose lifecycle is changing
   167	     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
   168	     "correct addressee resolution; no candidates emailed under another's name")
   169	   → ESC_ADDRESSEE_MISMATCH if check fails (blocking); draft aborted
   170	   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
   171	     "recipient_role:<role>")
   172	
   173	5. Comms-template selection
   174	   → tenant comms-template library at /vault/<slug>/concierge-templates/
   175	   → per event_type: select template; per recipient_role: candidate vs client
   176	   → fallback: shared/common-comms-templates.yaml if tenant has no override
   177	   → hh_decision_output("template_selected", "<event_type>:<recipient_role>",
   178	     "template_id:<id>")
   179	
   180	6. Sensitive-event escalation routing
   181	   → if event_type=rejection (event 6) OR event_type=withdrawal (event 7)
   182	     OR (event_type=on-hold AND placement value >£10k): set escalation_position=3
   183	     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
   184	   → else: escalation_position=1 (standard orange tier)
   185	   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
   186	     "position:<N>")
   187	
   188	7. LLM draft generation
   189	   → prompt = (event context + candidate state history + voice corpus
   190	     ANN-matched on event_type + tone rules filtered for concierge +
   191	     comms-template structure)
   192	   → output = email body + subject + recommended_send_time
   193	   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
   194	   → hh_decision_output("concierge_draft_rendered",
   195	     "candidate:<bullhorn_id>:<event_type>", "vault_path:<path>; voice_score:<N>; words:<N>")
   196	   → ESC_VOICE_DRIFT if classifier score below the escalation_position-specific
   197	     threshold (position 1 ≥0.75; position 2 ≥0.78; position 3 ≥0.82 per Step 8)
   198	     after 3 retries — the position is set in Step 6 and is the per-draft Gate A
   199	     threshold. Generic <0.75 floor would understate position 2-3 sensitivity.
   200	
   201	8. Voice + tone validation
   202	   → voice classifier scores the draft
   203	   → minimum threshold by escalation_position:
   204	     position 1: ≥0.75
   205	     position 2: ≥0.78
   206	     position 3 (rejections / sensitive): ≥0.82
   207	   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
   208	   → on success: hh_decision_action("concierge_email_draft",
   209	     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
   210	     tier=yellow per autosend-policy.yaml
   211	
   212	9. SLA timing check (Gate B leading metric — NOT Gate A hard-fail)
   213	   → elapsed = now() - event_timestamp
   214	   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
   215	     → hh_decision_output("concierge_sla_miss",
   216	       "candidate:<bullhorn_id>:<event_type>",
   217	       "elapsed_seconds:<N>; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct")
   218	       — mandatory audit row per master brief §8.1 Change 2 (phase=output;
   219	       no tiered action_type required — this is an internal status marker)
   220	   → per ULTRAPLAN A6 line 566 (as amended by ADR-007): the 30-min draft SLA is
   221	     a Gate B leading metric (90% of drafts within 30 min), not a per-draft hard
   222	     fail (legitimate polling-fallback delays would otherwise block drafts)
   223	
   224	10. PII boundary check
   225	    → no PII from other candidates referenced in body
   226	    → no PII from competitor clients referenced
   227	    → no compensation specifics outside what's already in candidate's record
   228	    → ESC_PII_LEAKAGE_RISK on hit (blocking)
   229	    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
   230	     "result:passed")
   231	
   232	11. Autosend-bridge routing (D1 path)
   233	    → per Founder Decision D1 (final selection at W10 design):
   234	      D1-A (bridge to cortextOS approval system): POST internal API
   235	      D1-B (lightweight Telegram shim): send approval prompt to operator
   236	      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
   237	    → per autosend-policy.yaml: orange-tier; consultant approves
   238	    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within the policy timeout
   239	      (default PT4H per autosend-policy.yaml (grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field; default `PT4H`) + escalation-codes.md
   240	      lines 348-353; looked up per action_type, not hardcoded) (D1-A/B)
   241	    → hh_decision_action("concierge_approval_routed",
   242	      "candidate:<bullhorn_id>:<event_type>", payload_hash,
   243	      "d1_path:<A|B|C>; bridge_target:<approval_id_or_vault_path>")
   244	
   245	12. (After operator approval) Send execution — orange-tier
   246	    → microsoft-graph.send_email() OR gmail.send_email() per tenant config
   247	    → BCC: tenant's archive address (per tenant config)
   248	    → hh_decision_action("gmail_outlook_send_to_candidate",
   249	      "candidate:<bullhorn_id>", payload_hash, payload_preview)
   250	      [or `bullhorn_note_customer_visible` if channel=Bullhorn-note]
   251	    → ESC_SEND_FAIL on 4xx/5xx; retry once 30s backoff
   252	
   253	13. Bullhorn activity-log write
   254	    → bullhorn.create_activity_log(candidate_id, "concierge: <event_type>
   255	      sent at <ISO>")
   256	    → maintains audit trail in Bullhorn itself (NOT customer-visible;
   257	      separate from bullhorn_note_customer_visible orange tier)
   258	    → hh_decision_action("bullhorn_activity_log_write",
   259	      "candidate:<bullhorn_id>", payload_hash,
   260	      "event_type:<type>; bullhorn_activity_id:<id>") — green tier per
   261	      autosend-policy.yaml (registered 2026-06-02 per Codex Fbis-R1 closure;
   262	      grep `^  bullhorn_activity_log_write:` to verify). External-write
   263	      action_type required for tier classification per autosend-policy §3.
   264	
   265	14. Lifecycle state advance (Bullhorn write, conditional)
   266	    → some events trigger Bullhorn state changes (e.g., interview-completed
   267	      sent → advances state to "post-interview" if tenant policy says so)
   268	    → per-tenant policy; opt-in; not all tenants want this
   269	    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
   270	      payload_hash, "event=<type> elapsed=<seconds>")
   271	
   272	15. Session close + Gate B metric
   273	    → compute elapsed (event → send) for Gate B SLA tracking
   274	    → check ghosted-rate metric (any candidate with no Concierge action in
   275	      14 days post-state-change → contributes to ghosted-rate)
   276	    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
   277	    → hh_decision_action("concierge_run_complete", "session:<tenant_slug>",
   278	      payload_hash, "mode:<webhook|poll|nurture-sweep|manual>; drafts:<N>;
   279	      sends:<N>; ghosted_rate:<float>") — green tier per autosend-policy.yaml;
   280	      4-arg signature matches `_shared/hook-helpers.sh` `hh_decision_action
   281	      <action_type> <target> <payload_hash> <payload_preview>` contract.
   282	    → exit code 0
   283	```
   284	
   285	---
   286	
   287	## §5 — Gates
   288	
   289	### Gate A — validate.sh (hard-fail before action)
   290	
   291	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
   292	
   293	- **"voice classifier score ≥ position-specific threshold"** (≥0.75 position 1, ≥0.78 position 2, ≥0.82 position 3) — hard-fail
   294	- **"correct addressee resolution (no candidates emailed under another's name)"** — hard-fail (Step 4 critical; ESC_ADDRESSEE_MISMATCH)
   295	- No tone-rule block-severity violations — hard-fail (ESC_TONE_RULE_VIOLATION)
   296	- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
   297	- Anti-duplicate guard passed (Step 2) — hard-fail (skip if true duplicate)
   298	- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_AGENT_OUTPUT_SHAPE; ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10)
   299	
   300	The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
   301	
   302	Gate A failures fire ESC codes per their catalogue-defined severity (do NOT conflate "Gate A blocks the draft from sending" with "ESC severity escalates to oncall"):
   303	
   304	- **Catalogue blocking-severity:** `ESC_ADDRESSEE_MISMATCH`, `ESC_PII_LEAKAGE_RISK` — these route to operator + ifos_oncall_chat_id per catalogue §2.10 (truly customer-impacting violations).
   305	- **Catalogue warn-severity:** `ESC_TONE_RULE_VIOLATION`, `ESC_AGENT_OUTPUT_SHAPE` — these route to operator_chat_id only per catalogue §2.10 + §2.7 (per-draft signal-quality issues; not customer-impacting unless multiple aggregate).
   306	
   307	ALL FOUR cause Gate A to block the draft from sending (validate.sh exits non-zero; draft stays in vault; cycle.sh aborts the orange-tier emission). The "blocking" of the DRAFT is `validate.sh` behavior; the "blocking" severity of the ESC code is the operator-paging-urgency lookup. These are separate dimensions. Draft is moved to `/tmp` (out of the customer-facing path) regardless of ESC severity; operator is notified immediately for blocking-tier ESCs, asynchronously-aggregated for warn-tier.
   308	
   309	**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   310	
   311	### Gate B — Outcome thresholds (success metrics, not block)
   312	
   313	Per ULTRAPLAN A6 line 567 + ADR-007 amendment: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate"**. The third metric is ADR-007's Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail (NOT in original line 567 wording).
   314	
   315	Three metrics:
   316	- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%. (per ULTRAPLAN line 567)
   317	- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`. (per ULTRAPLAN line 567)
   318	- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
   319	
   320	Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Any of the three metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
   321	
   322	---
   323	
   324	## §6 — Escalation codes
   325	
   326	Concierge uses these ESC codes from `agents/_shared/escalation-codes.md`:
   327	
   328	| Code | Trigger | Severity | Routing |
   329	|---|---|---|---|
   330	| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
   331	| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
   332	| `ESC_MS_GRAPH_AUTH` | Microsoft Graph OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin (token re-auth required) |
   333	| `ESC_GMAIL_AUTH` | Gmail OAuth fail | **blocking** | operator + ifos_oncall + tenant-admin |
   334	| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
   335	| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
   336	| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
   337	| `ESC_VOICE_DRIFT` | Voice classifier below the position-specific threshold (≥0.75/0.78/0.82) after 3 retries. The Gate A hard-fail (validate.sh exits non-zero; draft not sent) is expressed through `validate_gate_a_fail`, NOT through this code's severity: per catalogue (escalation-codes.md lines 120-125) `ESC_VOICE_DRIFT` is `warn` → `operator_chat_id` for ALL positions. Position-specific paging urgency (e.g. oncall on rejections) would require a catalogue amendment adding position-severity semantics — not yet made. | warn | operator_chat_id |
   338	| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | warn (catalogue) — Gate A still blocks the draft from sending via validate.sh; ESC severity governs operator-paging urgency only | operator_chat_id |
   339	| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
   340	| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
   341	| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md lines 348-353 + autosend-policy.yaml (grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field; default `PT4H`)) | warn | operator + tenant-admin |
   342	| `ESC_SEND_FAIL` | Email provider 4xx/5xx | warn | operator_chat_id |
   343	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
   344	| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% OR 30-min SLA hit-rate <90% for 30 consecutive days | warn | founder + operator |
   345	| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
   346	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
   347	
   348	Concierge has the largest escalation surface of any v1.0 agent — appropriate for the highest-stakes customer-facing comms.
   349	
   350	Concierge does NOT use:
   351	
   352	- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
   353	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
   354	- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
   355	
   356	---
   357	
   358	## §7 — Voice + tone constraints
   359	
   360	Steps 7-8 (draft generation + voice/tone validation) are the load-bearing voice surface of v1.0. The agent integrates with `_shared/voice-loader.sh`:
   361	
   362	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
   363	  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §gotchas (line numbers vary; see live file); demand specificity)
   364	  - No "Per our previous conversation" without referencing the actual conversation context
   365	  - No urgency language ("URGENT", "ACT NOW") unless the lifecycle event genuinely requires it
   366	  - No mention of other candidates by name
   367	  - No salary/rate specifics outside what's already on the candidate's record
   368	  - No competing-agency references
   369	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
   370	- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
   371	
   372	**Position-specific thresholds:**
   373	- Position 1 (standard sends — acknowledgement, prep, debrief, nurture): voice ≥0.75
   374	- Position 2 (placement-positive, status-update): voice ≥0.78
   375	- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §gotchas (line numbers vary; see live file) explicitly names rejection voice as the hardest case)
   376	
   377	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   378	
   379	---
   380	
   381	## §8 — Build dependencies (W10-13 prerequisites)
   382	
   383	Concierge build cannot start until ALL of the following are confirmed:
   384	
   385	| Dependency | Source | Status |
   386	|---|---|---|
   387	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   388	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   389	| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
   390	| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
   391	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   392	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   393	| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
   394	| **Microsoft Graph commercial signup** (per tenant) | Tenant onboarding | ⏸ |
   395	| **Gmail / Google Workspace signup** (alternative per tenant) | Tenant onboarding | ⏸ |
   396	| Microsoft Graph MCP connector | W10 build start (~3 days) | ⏸ |
   397	| Gmail MCP connector | W10 build start (~3 days) | ⏸ |
   398	| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
   399	| Autosend bridge built (per D1 outcome) | W10 build start (~2 days for D1-A; less for D1-B/C) | ⏸ |
   400	| Voice classifier microservice live | W4-5 polish | ⏸ |
   401	| Per-tenant comms-template library at `/vault/<slug>/concierge-templates/` | Tenant onboarding | ⏸ |
   402	| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
   403	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   404	| `validate.sh` Gate A logic | Build at W10 start (~2 days; most complex of v1.0 validators) | ⏸ |
   405	| `context.sh` hydration | Build at W10 start (~1 day) | ⏸ |
   406	| `cycle.sh` orchestration (15-step) | Build at W10-11 (~5 days; lifecycle state machine + 12 event types) | ⏸ |
   407	| Lifecycle event-detection polling fallback | Build at W11-12 (~3 days; Bullhorn webhook coverage gaps) | ⏸ |
   408	| Comms-template library v0.1 (12 event types × 2 recipient roles = 24 templates minimum) | Build at W12-13 (~5 days) | ⏸ |
   409	| 5 fixtures with golden outputs (broader than 3 for other agents; XL complexity warrants) | Build at W13 (~2 days) | ⏸ |
   410	
   411	**Until ALL ⏸ items resolve to ✅, W10 build slice does not start.** XL build complexity = 4-week duration not negotiable.
   412	
   413	---
   414	
   415	## §9 — Status + open questions
   416	
   417	**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
   418	
   419	### Open questions for founder review
   420	
   421	| # | Question | Resolution path |
   422	|---|---|---|
   423	| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
   424	| Q2 | Lifecycle event taxonomy — 12 events proposed in §3. Founder confidence each is correct + complete? Missing: "candidate referred to another role internally"? "Client cancelled brief"? | Founder review with first pilot consultants. Recommend: ship 12-event v1.0; expand v1.1+ based on real patterns. |
   425	| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
   426	| Q4 | Rejection emails (event 6) — Position 3 (voice ≥0.82). Is this enough, or should rejections route to consultant for full draft (not just approve)? | Founder review with first pilot consultant. Recommend: Concierge drafts; consultant approves; never bypasses voice gate. |
   427	| Q5 | Comms-template customisation — every tenant edits these. Per-event-type, per-recipient-role × per-tenant = 24+ templates each. Authoring tool? | v1.0: Markdown files at `/vault/<slug>/concierge-templates/<event>-<role>.md`. v1.1: Brain UI WYSIWYG editor. |
   428	| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
   429	| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
   430	| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
   431	| Q9 | Cross-tenant lifecycle handling — what if a candidate placed at Tenant A's client interviews at Tenant B 6 weeks later? Bullhorn has separate tenant slugs; no cross-tenant leak. But operator visibility? | v1.0: strict tenant isolation (no cross-tenant data visibility). v1.1+: separate agent for tenant-network-graph if commercial demand. |
   432	| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
   433	
   434	### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)
   435	
   436	1. **Lifecycle event detection from Bullhorn is the unreliable bit.** Bullhorn's webhook coverage is patchy; polling fallbacks are required. Step 1 polling at 5-min cycle + anti-duplicate guard at Step 2 is the architecture.
   437	2. **Voice quality on rejections is the hardest test case.** Position-3 threshold (≥0.82) + sensitive-event escalation routing (Step 6). Get this wrong and it costs the tenant a candidate relationship.
   438	3. **Comms-template library is per-tenant, per-event-type, per-recipient-role.** 24+ templates per tenant minimum. Authoring effort is significant; consider this in pilot onboarding scoping.
   439	4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add agent-identity email adapter (deferred).
   440	
   441	---
   442	
   443	## §10 — When this document ratifies
   444	
   445	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   446	
   447	Status flips Proposed → Accepted when:
   448	- Codex Round 4 Phase 2 ratifies
   449	- **✅ ADR-007 (Concierge Gate A 30-min SLA hybrid) ACCEPTED + RATIFIED** — Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3 per `.codex/ratification/review-architecture-decision.md` skill (commit `c862c77`). Closes the documented deviation from ULTRAPLAN A6 line 566 wording; agent.md's Gate B framing of the 30-min SLA is now the canonical disposition. This Status-flip blocker is satisfied.
   450	- **Founder Decision D1 RESOLVED** (Q1 above) — without this, Concierge build cannot start
   451	- Founder approves §9 Q2 (lifecycle taxonomy) + Q3 (send window) + Q4 (rejection routing) + Q5 (template authoring UX) + Q6 (Gate B UX)
   452	- Q7-Q9 documented decisions captured
   453	
   454	Status flips Accepted → In Force when:
   455	- W10-13 build slice produces all 5 sibling bundle files + 5 fixtures (broader fixture coverage warranted by XL complexity)
   456	- First production lifecycle webhook processed end-to-end against migration-test tenant
   457	- 12-event taxonomy validated against first pilot tenant's actual Bullhorn state-change patterns
   458	- Voice classifier microservice production-ready (per-tenant; position-3 ≥0.82 sustained)
   459	- Gate B feedback loop operational (consultant approve/edit distinguishable)
   460	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   461	
   462	Until then: this document is a forward-looking scaffold. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at scaffold stage. Founder review at each iteration is expected.
   463	
   464	*End of Concierge agent.md draft.*

codex
The local copy of `agents/recruitment/concierge/agent.md` matches the supplied artefact, so I’m using line numbers from that file for citations. I’ve found one likely issue in the policy wording, but I’m checking the planning sources before returning a verdict.
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,615p'" in /Users/madsadmin/code/CortexOS
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
   566	- **Gate A:** voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82 per escalation_position); correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
   567	- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate (per ADR-007)
   568	- **Build complexity:** **XL** (4 weeks) — this is the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)
   569	- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.
   570	
   571	### 8.2 v1.1 agents (seven, in build order)
   572	
   573	#### A7. Inbound Triage (priority 1, 4 weeks)
   574	
   575	- **Build wave:** v1.1 (Q4 2026 weeks 1–4)

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
/bin/zsh -lc "nl -ba docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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

codex
The authoritative lines line up for the W10-13 vs W9-10 drift and ADR-007 amendment. I’m checking for any direct adapter-boundary breach and unsupported schema/payload claims before finalizing.
exec
/bin/zsh -lc "rg -n \"AgentMail|Composio|packages/harness/cortextos|tenant_adapters\\.config\\.[a-zA-Z0-9_]+|detection_delay_seconds|concierge_sla_threshold|candidate-ghosted|candidate ghosted|draft_id|payload includes|payload\\.|phase='output'|phase='action'\" agents/recruitment/concierge/agent.md docs/verticals/recruitment/vertical-schema*.yaml docs/verticals/recruitment/migrations/*.sql -S" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
agents/recruitment/concierge/agent.md:1:# Concierge — no candidate ghosted
agents/recruitment/concierge/agent.md:17:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:88:draft_id: <uuid>
agents/recruitment/concierge/agent.md:103:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
agents/recruitment/concierge/agent.md:130:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:140:     (candidate_id, payload.event_type) in last 24h with phase IN
agents/recruitment/concierge/agent.md:154:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:193:   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
agents/recruitment/concierge/agent.md:313:Per ULTRAPLAN A6 line 567 + ADR-007 amendment: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate"**. The third metric is ADR-007's Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail (NOT in original line 567 wording).
agents/recruitment/concierge/agent.md:330:| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:331:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:425:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:429:| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.

exec
/bin/zsh -lc 'rg -n "Status|Founder Decision D1|D1-A|D1-B|D1-C|resolved|Accepted|Proposed" docs/decisions/2026-05-20-codex-round-1-founder-decisions.md docs/decisions/autosend-approval-bridge-spec.md docs/architecture/architecture-cohesion-review.md -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/autosend-approval-bridge-spec.md:3:**Status:** Proposed
docs/decisions/autosend-approval-bridge-spec.md:6:**Surfaced by:** Founder Decision D1 (`docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`) + Codex Round 1 autosend rejection issue 2
docs/decisions/autosend-approval-bridge-spec.md:56:// → moves file from pending/ to resolved/
docs/decisions/autosend-approval-bridge-spec.md:84:**Loop 2: cortextOS resolved → IFOS marker write**
docs/decisions/autosend-approval-bridge-spec.md:87:Watch ${CTX_FRAMEWORK_ROOT}/orgs/<org>/approvals/resolved/*.json
docs/decisions/autosend-approval-bridge-spec.md:89:For each new resolved file:
docs/decisions/autosend-approval-bridge-spec.md:95:  - Update bridge state mapping → resolved
docs/decisions/autosend-approval-bridge-spec.md:102:Mapping `{ifos_payload_hash, cortextos_approval_id, tenant_slug, action_type, created_at, resolved_at}` lives in a small SQLite database at `${CTX_FRAMEWORK_ROOT}/autosend-bridge.db` OR (cleaner) a new Postgres table `autosend_approval_mappings`:
docs/decisions/autosend-approval-bridge-spec.md:114:  resolved_at          TIMESTAMPTZ,
docs/decisions/autosend-approval-bridge-spec.md:115:  resolved_by          TEXT
docs/decisions/autosend-approval-bridge-spec.md:167:Operator taps button → cortextOS Telegram bot fires → `updateApproval(approvalId, 'approved'|'denied')` → resolved file → bridge writes marker → IFOS agent proceeds.
docs/decisions/autosend-approval-bridge-spec.md:190:- Per-tenant pending dir is watched; per-tenant resolved dir is watched. Multi-tenant write contention is rare (each tenant has independent dirs).
docs/decisions/autosend-approval-bridge-spec.md:207:│   ├── cortextosWatcher.ts   ← Loop 2: watch ${CTX_FRAMEWORK_ROOT}/orgs/<org>/approvals/resolved/
docs/decisions/autosend-approval-bridge-spec.md:241:| A3 | Telegram inline-button approve → `.approved` marker appears in IFOS pending-approvals dir within 200ms of `updateApproval` call | Integration test: simulate cortextOS resolved/ write → assert IFOS marker appears |
docs/decisions/autosend-approval-bridge-spec.md:242:| A4 | 4h timeout: bridge calls `updateApproval(..., 'denied', 'ifos_timeout')` cleanly | Integration test: write `.pending` marker, advance simulated clock 4h, assert cortextOS `pending/` is empty + `resolved/` has `denied` record |
docs/decisions/autosend-approval-bridge-spec.md:283:| 4 | Operator approves but bridge crashes before marker write | Recovery on restart: scan resolved/ + replay missed conversions. Idempotent via `ON CONFLICT DO NOTHING`. |
docs/decisions/autosend-approval-bridge-spec.md:299:## §11 — Status
docs/decisions/autosend-approval-bridge-spec.md:301:**Proposed.** Founder decision pending: build timing (Week 9 OR now).
docs/decisions/autosend-approval-bridge-spec.md:303:Codex Day-7 manifest queue position: TBD (will be ~#39 when filed). Ratifies via `review-architecture-decision.md` skill (with D5 softening applies if Status flipped to Reference after build complete).
docs/decisions/autosend-approval-bridge-spec.md:308:- Unblocks Concierge build (W10-13) — without this, Concierge can only ship as drafts-only (D1-A) which loses the demo value prop
docs/architecture/architecture-cohesion-review.md:4:**Status:** Reference (audit surfaces issues; does not resolve inline — remediation paths named).
docs/architecture/architecture-cohesion-review.md:127:- **Status:** This is by design — `recent_edit` is the SFT corpus source, not the operator-facing audit. But Codex Round 1 flagged it as a GDPR risk (now Risk #10).
docs/architecture/architecture-cohesion-review.md:129:- **Status: OPEN until D3 resolves.**
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:228:| R2 | G8: Autosend v1.0 tier enforcement | High | Founder Decision D1 | Founder | Pre-Concierge W10 |
docs/architecture/architecture-cohesion-review.md:266:## §10 — Status
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:4:**Status:** Proposed
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:36:**D1 Concrete recommendation:** Schedule for Week 9 (default). Founder explicitly approves D1-B; bridge spec ratifies through Codex Round 2; bridge implementation slice authored Week 9.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:47:**Codex's framing:** "The legal placeholder is load-bearing for pilot readiness but unresolved. Lines 498-500 warn not to use the liability language as-is, and lines 578-584 leave jurisdiction, liability cap, dispute forum, insurance, and PII liability open. Fix by marking pilot LOI signing blocked until counsel-reviewed language replaces §10."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:110:**Real issue:** Codex Round 1 REJECTED `cortexos-primitive-status.md` (audit) and `operational-hygiene-protocol.md` (runbook) for lacking Decision + Consequences sections. The skill `.codex/ratification/review-architecture-decision.md` §1 requires these sections for all artefacts under this skill. But the skill ALSO allows Status=Reference and Status=In Force, which are legitimately non-decision artefacts. Contradiction in the skill itself.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:113:- **D5-A: Soften the skill** — exempt Status=Reference + Status=In Force from the Decision/Consequences requirement. Re-run Round 2; both artefacts expected to RATIFY without further changes. **Recommended.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:125:Founder accepted **D5-A**. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` plus new §1-Exemption clause. Reference + In Force status artefacts now exempt from Decision + Alternatives + Consequences requirements (Context + Status line still required for ALL).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:160:Founder picks D1-C: ship orange-as-red default + manual override.

exec
/bin/zsh -lc "rg -n \"hh_decision_trigger|hh_decision_output|hh_decision_action\\(|function hh_decision|hh_decision_action\\(\\)\" agents/_shared/hook-helpers.sh tests -S" in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: tests: No such file or directory (os error 2)
agents/_shared/hook-helpers.sh:192:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:194:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:203:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:206:hh_decision_output() {
agents/_shared/hook-helpers.sh:219:hh_decision_action() {

exec
/bin/zsh -lc 'find agents/recruitment/concierge -maxdepth 2 -type f -print | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/concierge/README.md
agents/recruitment/concierge/agent.md
agents/recruitment/concierge/cleanup.sh
agents/recruitment/concierge/context.sh
agents/recruitment/concierge/cycle.sh
agents/recruitment/concierge/fixtures/01-primary.yaml
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml
agents/recruitment/concierge/tools.yaml
agents/recruitment/concierge/validate.sh

codex
I’ve found a concrete blocker: the artefact’s D1 status appears stale against the founder decision file. I’m checking whether that is enough by itself and whether there are additional load-bearing mismatches to include, rather than padding the verdict.
exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-20-codex-round-1-founder-decisions.md | sed -n '1,45p;150,166p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Codex Round 1 — 5 founder decisions surfaced
     2	
     3	**Date:** 2026-05-20 (Day 8 evening)
     4	**Status:** Proposed
     5	**Context:** Codex ratification first run rejected 14 of 16 artefacts. 13 of 14 rejections were incorporated (Bucket 1 cosmetic + Bucket 2 drift + Bucket 3 structural fixes — same commit as this briefing). The remaining 5 items surfaced by Codex are genuine founder-domain product judgments, not Claude's call. This briefing surfaces them in one place for resolution.
     6	
     7	Each decision: source + Codex's framing + named options + Claude's recommendation + cost-of-delay.
     8	
     9	---
    10	
    11	## D1 — Auto-send v1.0 tier enforcement (orange-tier behavior)
    12	
    13	**Source artefacts:**
    14	- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
    15	- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
    16	- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
    17	
    18	**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
    19	
    20	**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
    21	
    22	- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
    23	- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
    24	- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
    25	
    26	**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
    27	
    28	**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
    29	
    30	**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
    31	
    32	**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
    33	
    34	**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
    35	
    36	**D1 Concrete recommendation:** Schedule for Week 9 (default). Founder explicitly approves D1-B; bridge spec ratifies through Codex Round 2; bridge implementation slice authored Week 9.
    37	
    38	---
    39	
    40	## D2 — External advisor identification
    41	
    42	**Source artefacts:**
    43	- `docs/decisions/v1.0-kill-criterion.md` §3.4 ("Week 1-2 must-fill")
    44	- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
    45	- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3
   150	
   151	---
   152	
   153	## §11 — How to record resolutions
   154	
   155	For each decision, founder writes resolution to this file under §"Resolution" subsection of the corresponding D# entry:
   156	
   157	```markdown
   158	## D1 — Resolution (2026-05-XX)
   159	
   160	Founder picks D1-C: ship orange-as-red default + manual override.
   161	
   162	Rationale: <2-3 sentences>
   163	
   164	Implementation work: <commit reference or "in autosend §9 update commit">
   165	```
   166	

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '730,830p' && nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '755,890p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   791	# Resolved (RESOLVED) items: baked into v0.1 per Day-6 founder decisions.
   792	# Deferred (DEFERRED) items: scope-bounded with named revisit triggers.
   793	# ============================================================================
   794	
   795	open_questions:
   796	
   797	  Q1_contractor_entity_type:
   798	    status: RESOLVED (Day 6 founder decision)
   799	    decision: Contractor is a separate entity_type from candidate. Adapter layer maps Bullhorn.Candidate (status='contractor') → IFOS entity_type='contractor' at ingest.
   800	    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
   801	
   802	  Q2_note_handling:
   803	    status: DEFERRED to v1.1
   804	    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
   805	    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
   806	    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
   807	
   808	  Q3_full_bullhorn_field_set:
   809	    status: DEFERRED to Week 3-4
   810	    v0_1_decision: v0.1 ships minimal v1.0 working set (~10-20 fields per entity) covering what the 6 v1.0 agents actually touch per bullhorn §4.1.
   811	    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
   812	    rationale: Premature schema lockdown is the failure mode; minimum-shape approach lets pilot data guide expansion.
   813	
   814	  Q4_system_agents_not_entities:
   815	    status: RESOLVED (Day 6 founder decision)
   816	    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
   817	    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
   818	
   819	  Q5_contact_decision_authority_granularity:
   820	    status: DEFERRED to v1.1
   821	    v0_1_decision: contact.decision_authority is a single-enum field [yes, no, influencer, blocker, unknown] in v0.1.
   822	    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
   823	    v1_1_plus_expansion: Sub-fields for decision-domain (technical/budget/strategic), authority tier (final/recommend/influence/observer), engagement history aggregate, preferred-channel sentiment.
   824	
   825	  Q6_timesheet_field_set:
   826	    status: DEFERRED to v2.0
   827	    v0_1_decision: Timesheet entity has placeholder 7-field shape (id, week_starting, hours_worked, approved_by_client, approved_by_contractor, date_submitted, primary key).
   828	    revisit_trigger: v2.0 T2 Timesheet agent build verifies against real Bullhorn data and expands.
   829	    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
   830	
   755	# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
   756	# ============================================================================
   757	#
   758	# tenant_adapters.config is JSONB; validation via
   759	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   760	# on unknown keys per Rule 2.
   761	
   762	tenant_adapters_config_additions:
   763	
   764	  cash_conductor_last_run:
   765	    type: timestamp
   766	    required: false
   767	    set_by: cash_conductor
   768	    read_by: [cash_conductor]
   769	    notes: |
   770	      Cash Conductor cron sweep updates at session-close. Next run queries
   771	      transactions/invoices since this timestamp.
   772	
   773	  concierge_last_poll:
   774	    type: timestamp
   775	    required: false
   776	    set_by: concierge
   777	    read_by: [concierge]
   778	    notes: |
   779	      Concierge polling cron updates at end of each cycle. Next poll queries
   780	      Bullhorn for state transitions since this timestamp.
   781	
   782	  concierge_send_window:
   783	    type: object
   784	    required: false
   785	    default:
   786	      timezone: Europe/London
   787	      weekday_start: '09:00'
   788	      weekday_end: '17:00'
   789	      weekend_send_enabled: false
   790	    set_by: [tenant-admin]
   791	    read_by: [concierge]
   792	    object_shape:
   793	      timezone:
   794	        type: string
   795	        notes: IANA timezone identifier
   796	      weekday_start:
   797	        type: string
   798	        notes: HH:MM 24-hour format
   799	      weekday_end:
   800	        type: string
   801	        notes: HH:MM 24-hour format
   802	      weekend_send_enabled:
   803	        type: boolean
   804	    notes: |
   805	      Per-tenant outbound sending hours. Concierge respects when scheduling
   806	      orange-tier sends.
   807	
   808	  janitor_dedup_threshold:
   809	    type: number
   810	    required: false
   811	    default: 0.85
   812	    range: [0.75, 0.95]
   813	    set_by: [tenant-admin]
   814	    read_by: [janitor]
   815	    notes: |
   816	      Per-tenant dedup confidence threshold for candidate merges. v1.0 default
   817	      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
   818	      via the wizard. The migration validator (v0.2-to-v0.3.sql §5 allowlist +
   819	      type-validation trigger extension added in R19) enforces both the
   820	      allowlist membership and the [0.75, 0.95] range. Schema declaration
   821	      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.
   822	
   823	  blocked_recipients:
   824	    type: array
   825	    items:
   826	      type: string
   827	    required: false
   828	    default: []
   829	    set_by: [tenant-admin, janitor]
   830	    read_by: [concierge, sourcing-scout, cash-conductor, janitor]
   831	    notes: |
   832	      Per-tenant DNC (do not contact) list. v1.0 canonical source for outbound
   833	      send refusal (autosend-safety-policy §5 red-tier action_type
   834	      `send_to_blocked_recipient`) and pre-outbound sourcing filter (Sourcing
   835	      Scout §4 Step 8). Per ADR-002 vault/Postgres split — structured state in
   836	      Postgres, NOT vault markdown. Pre-v0.3 origin (the migration validator
   837	      `v0.2-to-v0.3.sql §5 allowlist` has accepted this key since v0.1); the
   838	      schema declaration in v0.3 supplement is added Day-20 W4 bilateral pass
   839	      closing Sourcing Scout R8 Codex Finding 1 (the key was load-bearing
   840	      across 4 agents but undeclared in any YAML).
   841	
   842	  janitor_last_run:
   843	    type: timestamp
   844	    required: false
   845	    set_by: janitor
   846	    read_by: [janitor]
   847	    notes: |
   848	      Janitor nightly cron updates at session-close (Step 12). Next run queries
   849	      Bullhorn for entities created/modified since this timestamp. The migration
   850	      validator (v0.2-to-v0.3.sql §5 allowlist) already accepts this key; this
   851	      declaration is the canonical schema authority added in W4 bilateral pass
   852	      (Day-20) closing Janitor R11 Codex Finding 4.
   853	
   854	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   855	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
   856	  # declare this config key; the W4 ADR will introduce both the field
   857	  # and its consumer at the same time. Including it in v0.3 without an
   858	  # active consumer would be speculative schema.
   859	
   860	# ============================================================================
   861	# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
   862	# ============================================================================
   863	
   864	decision_log_payload_extension:
   865	  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
   866	  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
   867	  # explicitly DEFERRED to the future W4-polish ADR + schema supplement
   868	  # that ships alongside Tier 2 activation. v0.3 introducing the payload
   869	  # key without enforcement would violate review-schema-change §3
   870	  # (bounded values require CHECK or trigger). Tier 2 schema work owns
   871	  # the constraint + writer; this v0.3 supplement is silent on it.
   872	  deferred_to_future_adr:
   873	    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
   874	    schema_owner: future W4-polish supplement (not v0.3)
   875	    rationale: |
   876	      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
   877	      separate post-launch quality metric outside Gate A. The payload key,
   878	      its [0.0, 1.0] range validation, and the sample-rate config field
   879	      all land together with Tier 2 activation. Tier 2 doesn't activate
   880	      until the voice classifier microservice ships + first pilot tenant
   881	      accumulates ≥30 reports (W4-polish trigger). v0.3 is silent on the
   882	      payload shape to avoid declaring schema without enforcement.
   883	
   884	# ============================================================================
   885	# §6 — Migration sequencing (JSONB validation, not ALTER TABLE)
   886	# ============================================================================
   887	
   888	migration_sequence:
   889	  forward: migrations/v0.2-to-v0.3.sql
   890	  rollback: migrations/v0.3-to-v0.2.sql

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '188,235p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   221	  local target="$2"
   222	  local payload_hash="$3"
   223	  local payload_preview="$4"
   224	
   225	  local tenant tier
   226	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   227	
   228	  if ! tier=$(autosend_policy_lookup "${action_type}"); then
   229	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   230	      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
   231	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   232	      "${target}" "${payload_hash}" "unknown_action_type"
   233	    return 1
   234	  fi
   235	

exec
/bin/zsh -lc 'rg -n "concierge|Concierge|gmail|outlook|ms_graph|graph|tenant_adapters|tools|decision_log|action_type" agents/recruitment/concierge/tools.yaml agents/recruitment/concierge/context.sh agents/recruitment/concierge/validate.sh agents/recruitment/concierge/cycle.sh -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/concierge/cycle.sh:2:# Concierge agent — cycle.sh (15-step orchestration)
agents/recruitment/concierge/cycle.sh:18:#   mode=manual          — ifosctl concierge process-event|nurture-sweep
agents/recruitment/concierge/cycle.sh:22:#   @ifos/microsoft-graph        — MS Graph send_email (alt to gmail)
agents/recruitment/concierge/cycle.sh:23:#   @ifos/gmail                  — Gmail send_email (alt to microsoft-graph)
agents/recruitment/concierge/cycle.sh:24:#   @ifos/autosend-bridge-telegram — D1-B Telegram approval shim (Concierge OWNS Step 11)
agents/recruitment/concierge/cycle.sh:31:#   vault at /vault/<tenant>/concierge-drafts/<draft_id>.md + decision_log
agents/recruitment/concierge/cycle.sh:32:#   yellow-tier concierge_email_draft row; SEND is orange tier
agents/recruitment/concierge/cycle.sh:33:#   (gmail_outlook_send_to_candidate / bullhorn_note_customer_visible)
agents/recruitment/concierge/cycle.sh:44:  printf 'concierge/cycle.sh: CTX_AGENT_DIR unset (context.sh must run first)\n' >&2
agents/recruitment/concierge/cycle.sh:48:  printf 'concierge/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
agents/recruitment/concierge/cycle.sh:51:: "${CTX_AGENT_NAME:=concierge}"
agents/recruitment/concierge/cycle.sh:65:  printf 'concierge/cycle.sh: cannot locate _shared/ helpers\n' >&2
agents/recruitment/concierge/cycle.sh:90:# emits the trigger row that anchors the session in decision_log.
agents/recruitment/concierge/cycle.sh:94:  hh_decision_trigger "session_start" "mode:${MODE}; agent:concierge"
agents/recruitment/concierge/cycle.sh:118:# Reference: agent.md §4 Step 2 + Q7 disposition. Query decision_log for
agents/recruitment/concierge/cycle.sh:119:# prior concierge_email_draft row for (candidate_id, payload.event_type)
agents/recruitment/concierge/cycle.sh:126:  # TODO(W10-13): SELECT decision_log WHERE agent_name='concierge'
agents/recruitment/concierge/cycle.sh:127:  #   AND action_type='concierge_email_draft'
agents/recruitment/concierge/cycle.sh:170:# Reference: agent.md §4 Step 5. Per-tenant /vault/<slug>/concierge-templates/
agents/recruitment/concierge/cycle.sh:201:# Output → /vault/<tenant>/concierge-drafts/<draft_id>.md.
agents/recruitment/concierge/cycle.sh:208:  #   DRAFT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/concierge-drafts/<draft_id>.md"
agents/recruitment/concierge/cycle.sh:209:  #   hh_decision_output "concierge_draft_rendered" "candidate:STUB:STUB" \
agents/recruitment/concierge/cycle.sh:211:  hh_decision_output "concierge_draft_rendered" "candidate:STUB:STUB" \
agents/recruitment/concierge/cycle.sh:219:# On pass: emit concierge_email_draft (yellow tier; REGISTERED in policy).
agents/recruitment/concierge/cycle.sh:225:  #   hh_decision_action "concierge_email_draft" \
agents/recruitment/concierge/cycle.sh:229:  hh_decision_action "concierge_email_draft" "candidate:STUB:STUB" "stub-hash" \
agents/recruitment/concierge/cycle.sh:244:  #   hh_decision_output "concierge_sla_miss" "candidate:<id>:<event>" \
agents/recruitment/concierge/cycle.sh:269:# item 2 verbatim: "Concierge cycle.sh Step 11 — calls proposeApproval for
agents/recruitment/concierge/cycle.sh:272:# in decision_log (rejected)."
agents/recruitment/concierge/cycle.sh:288:    #      --action gmail_outlook_send_to_candidate \
agents/recruitment/concierge/cycle.sh:298:    # 2. Emit concierge_approval_routed audit row (R19 registration):
agents/recruitment/concierge/cycle.sh:300:    #    hh_decision_action "concierge_approval_routed" \
agents/recruitment/concierge/cycle.sh:329:    # DO NOT emit concierge_approval_routed; draft stays in vault for manual
agents/recruitment/concierge/cycle.sh:330:    # consultant pickup. Concierge §1 readiness caveat captures this state.
agents/recruitment/concierge/cycle.sh:338:# Reference: agent.md §4 Step 12. microsoft_graph_send OR gmail_send per
agents/recruitment/concierge/cycle.sh:345:  #   if tenant_adapters.config.email_channel == 'microsoft-graph':
agents/recruitment/concierge/cycle.sh:346:  #     ms_graph.send_email(to=RECIPIENT, subject=SUBJECT, body=BODY_MD, bcc=TENANT_ARCHIVE)
agents/recruitment/concierge/cycle.sh:347:  #   else: gmail.send_email(...)
agents/recruitment/concierge/cycle.sh:349:  #   hh_decision_action "gmail_outlook_send_to_candidate" "candidate:<id>" "<hash>" "<preview>"
agents/recruitment/concierge/cycle.sh:357:# audit trail in Bullhorn so downstream consultant ops see Concierge actions
agents/recruitment/concierge/cycle.sh:362:  # TODO(W10-13): bullhorn.create_activity_log(candidate_id, "concierge: <event_type> sent at <ISO>")
agents/recruitment/concierge/cycle.sh:375:  # TODO(W10-13): if tenant_adapters.config.concierge_state_advance_enabled:
agents/recruitment/concierge/cycle.sh:378:  hh_decision_action "concierge_send_complete" "candidate:STUB" "stub-hash" \
agents/recruitment/concierge/cycle.sh:385:# SLA tracking. Checks ghosted-rate (any candidate with no Concierge action
agents/recruitment/concierge/cycle.sh:389:# TODO(W10-13): UPDATE tenant_adapters SET config = jsonb_set(config, '{concierge_last_run}', '"<ISO>"')
agents/recruitment/concierge/cycle.sh:391:hh_decision_action "concierge_run_complete" "session:${CTX_TENANT_SLUG}" "stub-hash" \
agents/recruitment/concierge/validate.sh:8:# Concierge agent — validate.sh (Gate A enforcement; W4 Day-26 SKELETON)
agents/recruitment/concierge/validate.sh:17:# exits non-zero + emits an ESC_* escalation row to decision_log; the draft
agents/recruitment/concierge/validate.sh:24:#   - $1: path to the vault concierge-draft file (cycle.sh Step 7 wrote it)
agents/recruitment/concierge/validate.sh:41:#   G5 — anti-duplicate: no prior concierge_email_draft for same (candidate_id,
agents/recruitment/concierge/validate.sh:51:  printf 'concierge/validate.sh: usage: validate.sh <draft_path>\n' >&2
agents/recruitment/concierge/validate.sh:158:# G5 — anti-duplicate: no prior concierge_email_draft for same
agents/recruitment/concierge/validate.sh:165:# TODO(W10-13): SELECT from decision_log per Step 2 query but at validate time;
agents/recruitment/concierge/validate.sh:183:  #   "ESC_<class>; agent_name:concierge; failures:${#FAILURES[@]}"
agents/recruitment/concierge/context.sh:2:# Concierge agent — context.sh (pre-cycle hydration; W4 Day-26 SKELETON)
agents/recruitment/concierge/context.sh:5:#         with real provider config + tenant_adapters reads).
agents/recruitment/concierge/context.sh:12:# row to anchor the session in decision_log.
agents/recruitment/concierge/context.sh:24:#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
agents/recruitment/concierge/context.sh:27:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:33:#   CTX_AGENT_NAME                       — "concierge"
agents/recruitment/concierge/context.sh:34:#   CTX_EMAIL_CHANNEL                    — "microsoft-graph" | "gmail"
agents/recruitment/concierge/context.sh:38:#   CTX_COMMS_TEMPLATE_LIBRARY_PATH      — /vault/<slug>/concierge-templates/
agents/recruitment/concierge/context.sh:49:  printf 'concierge/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
agents/recruitment/concierge/context.sh:53:  printf 'concierge/context.sh: CTX_TENANT_SLUG unset\n' >&2
agents/recruitment/concierge/context.sh:56:export CTX_AGENT_NAME="concierge"
agents/recruitment/concierge/context.sh:81:# TODO(W10-13): SELECT config->>'email_channel' FROM tenant_adapters WHERE tenant_slug=$1
agents/recruitment/concierge/context.sh:82:# Default: microsoft-graph (most common in UK recruitment per CSM survey).
agents/recruitment/concierge/context.sh:83:export CTX_EMAIL_CHANNEL="${IFOS_FORCE_EMAIL_CHANNEL:-microsoft-graph}"
agents/recruitment/concierge/context.sh:98:#   if [[ "${CTX_EMAIL_CHANNEL}" == "microsoft-graph" ]]; then
agents/recruitment/concierge/context.sh:99:#     @ifos/microsoft-graph refreshTokens() → on fail ESC_MS_GRAPH_AUTH blocking
agents/recruitment/concierge/context.sh:101:#     @ifos/gmail refreshTokens() → on fail ESC_GMAIL_AUTH blocking
agents/recruitment/concierge/context.sh:109:# TODO(W10-13): resolve via tenant_adapters.config; default fallback chain.
agents/recruitment/concierge/context.sh:112:export CTX_COMMS_TEMPLATE_LIBRARY_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/concierge-templates/"
agents/recruitment/concierge/context.sh:118:# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
agents/recruitment/concierge/context.sh:124:# Step 6 — Session-start trigger row (mandatory; anchors session in decision_log)
agents/recruitment/concierge/context.sh:128:  "agent:concierge; tenant:${CTX_TENANT_SLUG}; mode:${CTX_CONCIERGE_MODE:-webhook}; email_channel:${CTX_EMAIL_CHANNEL}"
agents/recruitment/concierge/context.sh:130:# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
agents/recruitment/concierge/context.sh:131:printf '[concierge context.sh] tenant=%s channel=%s bullhorn_token=%s email_token=%s voice_corpus=%s\n' \
agents/recruitment/concierge/tools.yaml:1:# Concierge agent — tools.yaml (capability declarations)
agents/recruitment/concierge/tools.yaml:9:# Per ADR-003 v2 agent-bundle pattern: tools.yaml declares every external
agents/recruitment/concierge/tools.yaml:10:# capability cycle.sh invokes + the autosend-policy action_type each state-
agents/recruitment/concierge/tools.yaml:14:# Per agent.md §6: Concierge has the largest escalation surface of any v1.0
agents/recruitment/concierge/tools.yaml:23:agent: concierge
agents/recruitment/concierge/tools.yaml:34:    action_type: bullhorn_oauth      # green tier; registration QUEUED until Bullhorn partnership lands
agents/recruitment/concierge/tools.yaml:74:    action_type: bullhorn_activity_log_write  # green tier; QUEUED registration
agents/recruitment/concierge/tools.yaml:82:  - id: microsoft_graph_send
agents/recruitment/concierge/tools.yaml:83:    package: "@ifos/microsoft-graph"
agents/recruitment/concierge/tools.yaml:85:    action_type: gmail_outlook_send_to_candidate  # ORANGE; REGISTERED in autosend-policy.yaml; consolidated channel-agnostic action_type
agents/recruitment/concierge/tools.yaml:88:    optional: true  # alternate to gmail_send; tenant picks one
agents/recruitment/concierge/tools.yaml:98:  - id: gmail_send
agents/recruitment/concierge/tools.yaml:99:    package: "@ifos/gmail"
agents/recruitment/concierge/tools.yaml:101:    action_type: gmail_outlook_send_to_candidate  # ORANGE; same action_type — channel-agnostic at audit layer
agents/recruitment/concierge/tools.yaml:117:  # §"Implementation surface" item 4: declare on BOTH Concierge AND Cash
agents/recruitment/concierge/tools.yaml:118:  # Conductor (Concierge is the primary Step-11 consumer for orange-tier
agents/recruitment/concierge/tools.yaml:119:  # gmail_outlook_send_to_candidate drafts).
agents/recruitment/concierge/tools.yaml:126:    action_type: concierge_approval_routed  # ORANGE-adjacent metadata row per agent.md §6 + Step 11 hh_decision_action call; REGISTERED in autosend-policy.yaml per R19 fix
agents/recruitment/concierge/tools.yaml:178:    action_type: operator_notify_telegram  # green; REGISTERED in autosend-policy.yaml
agents/recruitment/concierge/tools.yaml:187:  - id: concierge_cleanup
agents/recruitment/concierge/tools.yaml:189:    action_type: concierge_cleanup  # green tier; QUEUED registration for cleanup.sh wire at W10-13
agents/recruitment/concierge/tools.yaml:198:#   concierge_email_draft              yellow              [Concierge §3 output contract]
agents/recruitment/concierge/tools.yaml:199:#   concierge_approval_routed          orange-adjacent     [R19 registration fix]
agents/recruitment/concierge/tools.yaml:200:#   gmail_outlook_send_to_candidate    orange              [shared with Cash Conductor at audit layer when bullhorn channel = email]
agents/recruitment/concierge/tools.yaml:206:#   bullhorn_activity_log_write        green               (W10-13 Concierge build slice)
agents/recruitment/concierge/tools.yaml:207:#   concierge_cleanup                  green               (W10-13 cleanup.sh wire)
agents/recruitment/concierge/tools.yaml:217:#   semantics smuggled in via tools.yaml.
agents/recruitment/concierge/tools.yaml:220:# - microsoft-graph + gmail are the v1.0 send paths per agent.md §1; agent-

codex
There are two agent.md-level blockers now: the §1 output contract omits the middle voice threshold, and §3 assigns yellow action metadata to a `phase='output'` decision row even though the shared helper contract only applies autosend tiers through `hh_decision_action`. I’m doing one last policy lookup for bundled `tools.yaml` because present sibling files are in scope for this skill.
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/tools.yaml | sed -n '1,230p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Concierge agent — tools.yaml (capability declarations)
     2	#
     3	# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces per-cap
     4	#         stubs with concrete provider configuration + per-tenant overrides).
     5	# Reading order: agent.md §1 (output contract) + §2 (invocation) + §3 (12
     6	#         lifecycle events × per-tenant template variants) + §4 (15-step
     7	#         workflow) first.
     8	#
     9	# Per ADR-003 v2 agent-bundle pattern: tools.yaml declares every external
    10	# capability cycle.sh invokes + the autosend-policy action_type each state-
    11	# changing call emits. cortextOS bus uses this to authorise capability
    12	# invocation per agent (no capability declared here = bus refuses the call).
    13	#
    14	# Per agent.md §6: Concierge has the largest escalation surface of any v1.0
    15	# agent (16 ESC codes) — appropriate for the highest-stakes customer-facing
    16	# comms. failure_modes below map each capability's failure surface to the
    17	# right ESC code, citing the catalogue line where defined.
    18	#
    19	# Action-type registrations cross-referenced at agents/_shared/autosend-policy.yaml
    20	# (status table at bottom of this file).
    21	
    22	version: "0.1"
    23	agent: concierge
    24	
    25	capabilities:
    26	
    27	  # ────────────────────────────────────────────────────────────────────────
    28	  # Bullhorn ATS (lifecycle event source + activity-log destination)
    29	  # ────────────────────────────────────────────────────────────────────────
    30	
    31	  - id: bullhorn_oauth
    32	    package: "@ifos/bullhorn"
    33	    purpose: "Bullhorn OAuth refresh + per-tenant token rotation (deferred to W7 Janitor bundle Track-2 per master brief §8.2)"
    34	    action_type: bullhorn_oauth      # green tier; registration QUEUED until Bullhorn partnership lands
    35	    cycle_step: 0
    36	    secrets_required: [BULLHORN_CLIENT_ID, BULLHORN_CLIENT_SECRET, BULLHORN_TENANT_TOKEN]
    37	    rate_limit_hint: "tenant-specific; default 20/sec per tenant per Bullhorn ts_endpoint"
    38	    failure_modes:
    39	      - condition: "OAuth refresh 6+ consecutive failures (Bullhorn revoked the grant)"
    40	        surface: "BullhornAuthError"
    41	        escalation: ESC_BULLHORN_AUTH  # blocking; operator + ifos_oncall per agent.md §6 row 1
    42	
    43	  - id: bullhorn_get_candidate
    44	    package: "@ifos/bullhorn"
    45	    purpose: "Single-entity candidate fetch (name, current state, comms history) — Step 3 of §4 workflow"
    46	    cycle_step: 3
    47	    state_changing: false
    48	    failure_modes:
    49	      - condition: "429 from Bullhorn API"
    50	        surface: "BullhornRateLimitError"
    51	        escalation: ESC_RATE_LIMIT_HIT  # warn; operator; payload.upstream='bullhorn'
    52	
    53	  - id: bullhorn_get_placement
    54	    package: "@ifos/bullhorn"
    55	    purpose: "Placement entity fetch (role, client, dates) — Step 3"
    56	    cycle_step: 3
    57	    state_changing: false
    58	
    59	  - id: bullhorn_get_client
    60	    package: "@ifos/bullhorn"
    61	    purpose: "Client entity fetch (company name, primary contact) — Step 3"
    62	    cycle_step: 3
    63	    state_changing: false
    64	
    65	  - id: bullhorn_get_contact
    66	    package: "@ifos/bullhorn"
    67	    purpose: "Client-contact entity fetch (name, email) — Step 3 + Step 4 addressee resolution"
    68	    cycle_step: 3
    69	    state_changing: false
    70	
    71	  - id: bullhorn_create_activity_log
    72	    package: "@ifos/bullhorn"
    73	    purpose: "Post-send audit-trail entry in Bullhorn itself (NOT customer-visible — green tier)"
    74	    action_type: bullhorn_activity_log_write  # green tier; QUEUED registration
    75	    cycle_step: 13
    76	    state_changing: true
    77	
    78	  # ────────────────────────────────────────────────────────────────────────
    79	  # Customer-facing email transport (orange tier — only fires post-approval)
    80	  # ────────────────────────────────────────────────────────────────────────
    81	
    82	  - id: microsoft_graph_send
    83	    package: "@ifos/microsoft-graph"
    84	    purpose: "Microsoft Graph send_email (per-tenant config; tenant chooses MS Graph OR Gmail)"
    85	    action_type: gmail_outlook_send_to_candidate  # ORANGE; REGISTERED in autosend-policy.yaml; consolidated channel-agnostic action_type
    86	    cycle_step: 12
    87	    state_changing: true
    88	    optional: true  # alternate to gmail_send; tenant picks one
    89	    secrets_required: [MS_GRAPH_CLIENT_ID, MS_GRAPH_CLIENT_SECRET, MS_GRAPH_TENANT_TOKEN]
    90	    failure_modes:
    91	      - condition: "OAuth refresh fails (revoked, expired)"
    92	        surface: "MsGraphAuthError"
    93	        escalation: ESC_MS_GRAPH_AUTH  # blocking; operator + ifos_oncall + tenant-admin (token re-auth required) per agent.md §6 row 3
    94	      - condition: "4xx/5xx from Graph API at send time"
    95	        surface: "MsGraphSendError"
    96	        escalation: ESC_SEND_FAIL  # warn; operator; retry once 30s backoff per §4 Step 12
    97	
    98	  - id: gmail_send
    99	    package: "@ifos/gmail"
   100	    purpose: "Gmail send_email (per-tenant config; tenant chooses MS Graph OR Gmail)"
   101	    action_type: gmail_outlook_send_to_candidate  # ORANGE; same action_type — channel-agnostic at audit layer
   102	    cycle_step: 12
   103	    state_changing: true
   104	    optional: true
   105	    secrets_required: [GMAIL_OAUTH_CLIENT_ID, GMAIL_OAUTH_CLIENT_SECRET, GMAIL_TENANT_TOKEN]
   106	    failure_modes:
   107	      - condition: "OAuth refresh fails"
   108	        surface: "GmailAuthError"
   109	        escalation: ESC_GMAIL_AUTH  # blocking; operator + ifos_oncall + tenant-admin
   110	      - condition: "4xx/5xx from Gmail API at send time"
   111	        surface: "GmailSendError"
   112	        escalation: ESC_SEND_FAIL  # warn; operator; retry once
   113	
   114	  # ────────────────────────────────────────────────────────────────────────
   115	  # Autosend bridge (D1-B Telegram shim per 2026-05-31 founder decision;
   116	  # package scaffold landed 2026-06-01 at commit 9b282d8). Per D1-B doc
   117	  # §"Implementation surface" item 4: declare on BOTH Concierge AND Cash
   118	  # Conductor (Concierge is the primary Step-11 consumer for orange-tier
   119	  # gmail_outlook_send_to_candidate drafts).
   120	  # ────────────────────────────────────────────────────────────────────────
   121	
   122	  - id: autosend_bridge_telegram_propose
   123	    package: "@ifos/autosend-bridge-telegram"
   124	    api: proposeApproval
   125	    purpose: "Post orange-tier candidate-comms approval request to operator Telegram chat (D1-B founder decision)"
   126	    action_type: concierge_approval_routed  # ORANGE-adjacent metadata row per agent.md §6 + Step 11 hh_decision_action call; REGISTERED in autosend-policy.yaml per R19 fix
   127	    cycle_step: 11
   128	    state_changing: true
   129	    optional: true  # cycle.sh Step 11 checks for the package dist/; falls back to drafts-only mode if absent (per D1-C graceful degradation)
   130	    failure_modes:
   131	      - condition: "Telegram postMessage transport failure (network, 5xx, invalid chat_id)"
   132	        surface: "BridgeTransportError thrown by package"
   133	        escalation: ESC_AGENT_TOOL_FAILURE  # transport-class failure, NOT timeout (different routing)
   134	
   135	  - id: autosend_bridge_telegram_await
   136	    package: "@ifos/autosend-bridge-telegram"
   137	    api: awaitApprovalDecision
   138	    purpose: "Block on operator approve/reject reply from Telegram (PT4H default deadline; authoritative on absolute expires_at_iso, not poll-count × interval)"
   139	    cycle_step: 11
   140	    state_changing: false
   141	    optional: true
   142	    failure_modes:
   143	      - condition: "Operator never replies before PT4H expires_at_iso"
   144	        surface: "outcome=timeout (or BridgeTimeoutError via awaitApprovalDecisionOrThrow)"
   145	        escalation: ESC_APPROVAL_BRIDGE_TIMEOUT  # warn-tier per escalation-codes.md lines 348-353; routes operator + tenant-admin per agent.md §6 row 11; action converts to manual reconciliation
   146	
   147	  # ────────────────────────────────────────────────────────────────────────
   148	  # Voice + tone validators (shared substrate — used at Step 8)
   149	  # ────────────────────────────────────────────────────────────────────────
   150	
   151	  - id: voice_classifier
   152	    package: "@ifos/voice-classifier"
   153	    purpose: "Score draft body against tenant voice corpus (position-specific threshold: ≥0.75 / ≥0.78 / ≥0.82)"
   154	    cycle_step: 8
   155	    state_changing: false
   156	    failure_modes:
   157	      - condition: "Classifier returns score below position-threshold after 3 retries"
   158	        surface: "VoiceClassifierError"
   159	        escalation: ESC_VOICE_DRIFT  # warn per catalogue lines 120-125; routes operator_chat_id for ALL positions (position-specific paging would need catalogue amendment)
   160	
   161	  - id: tone_rule_engine
   162	    package: "@ifos/tone-rules"
   163	    purpose: "Apply tenant tone-rules to draft; block-severity rules halt the pipeline"
   164	    cycle_step: 8
   165	    state_changing: false
   166	    failure_modes:
   167	      - condition: "Block-severity tone-rule hit (e.g. forbidden-phrase match)"
   168	        surface: "ToneRuleViolation"
   169	        escalation: ESC_TONE_RULE_VIOLATION  # blocking; operator + ifos_oncall
   170	
   171	  # ────────────────────────────────────────────────────────────────────────
   172	  # Operator notification (Telegram operator-chat-id; not customer-facing)
   173	  # ────────────────────────────────────────────────────────────────────────
   174	
   175	  - id: telegram_notify
   176	    package: "@ifos/telegram"
   177	    purpose: "Operator-channel Telegram notifications (NOT customer-facing; green tier)"
   178	    action_type: operator_notify_telegram  # green; REGISTERED in autosend-policy.yaml
   179	    cycle_step: 15
   180	    state_changing: false
   181	    secrets_required: [TELEGRAM_BOT_TOKEN]
   182	
   183	  # ────────────────────────────────────────────────────────────────────────
   184	  # Cleanup (cleanup.sh)
   185	  # ────────────────────────────────────────────────────────────────────────
   186	
   187	  - id: concierge_cleanup
   188	    purpose: "Post-run cleanup (transient OAuth-cache + provider-rate-limit-cache purge for Bullhorn + MS Graph/Gmail)"
   189	    action_type: concierge_cleanup  # green tier; QUEUED registration for cleanup.sh wire at W10-13
   190	    state_changing: false
   191	
   192	# ──────────────────────────────────────────────────────────────────────────────
   193	# Action-type registration status (cross-reference autosend-policy.yaml at W10-13)
   194	# ──────────────────────────────────────────────────────────────────────────────
   195	#
   196	# Already REGISTERED in agents/_shared/autosend-policy.yaml (verified per agent.md
   197	# §6 + R19 R-round amendments):
   198	#   concierge_email_draft              yellow              [Concierge §3 output contract]
   199	#   concierge_approval_routed          orange-adjacent     [R19 registration fix]
   200	#   gmail_outlook_send_to_candidate    orange              [shared with Cash Conductor at audit layer when bullhorn channel = email]
   201	#   bullhorn_note_customer_visible     orange              [canonical orange]
   202	#   operator_notify_telegram           green
   203	#
   204	# QUEUED for registration when their build wave clears:
   205	#   bullhorn_oauth                     green               (W7 Janitor + Bullhorn partnership)
   206	#   bullhorn_activity_log_write        green               (W10-13 Concierge build slice)
   207	#   concierge_cleanup                  green               (W10-13 cleanup.sh wire)
   208	#   twilio_sms_send                    orange              (v1.1+)
   209	#   calendar_invite_send               orange              (v1.1+)
   210	
   211	# ──────────────────────────────────────────────────────────────────────────────
   212	# Boundary check (per master brief §3 + review-mcp-connector.md §8)
   213	# ──────────────────────────────────────────────────────────────────────────────
   214	#
   215	# - No Composio / AgentMail references anywhere in this file.
   216	# - All packages declared are @ifos/* — no third-party adapters with policy
   217	#   semantics smuggled in via tools.yaml.
   218	# - Action types all map to autosend-policy.yaml tiers (or are explicitly
   219	#   marked QUEUED above for the W-X build-slice registration).
   220	# - microsoft-graph + gmail are the v1.0 send paths per agent.md §1; agent-
   221	#   identity email adapter explicitly deferred to v1.1+ per agent.md header.

exec
/bin/zsh -lc 'rg -n "bullhorn_oauth|operator_notify_telegram|concierge_cleanup|concierge_email_draft|concierge_approval_routed|gmail_outlook_send_to_candidate|bullhorn_activity_log_write" agents/_shared/autosend-policy.yaml agents/recruitment/concierge/tools.yaml -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:65:  operator_notify_telegram:
agents/_shared/autosend-policy.yaml:101:  concierge_approval_routed:
agents/_shared/autosend-policy.yaml:181:  bullhorn_activity_log_write:
agents/_shared/autosend-policy.yaml:254:  concierge_email_draft:
agents/_shared/autosend-policy.yaml:258:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
agents/_shared/autosend-policy.yaml:273:  gmail_outlook_send_to_candidate:
agents/recruitment/concierge/tools.yaml:31:  - id: bullhorn_oauth
agents/recruitment/concierge/tools.yaml:34:    action_type: bullhorn_oauth      # green tier; registration QUEUED until Bullhorn partnership lands
agents/recruitment/concierge/tools.yaml:74:    action_type: bullhorn_activity_log_write  # green tier; QUEUED registration
agents/recruitment/concierge/tools.yaml:85:    action_type: gmail_outlook_send_to_candidate  # ORANGE; REGISTERED in autosend-policy.yaml; consolidated channel-agnostic action_type
agents/recruitment/concierge/tools.yaml:101:    action_type: gmail_outlook_send_to_candidate  # ORANGE; same action_type — channel-agnostic at audit layer
agents/recruitment/concierge/tools.yaml:119:  # gmail_outlook_send_to_candidate drafts).
agents/recruitment/concierge/tools.yaml:126:    action_type: concierge_approval_routed  # ORANGE-adjacent metadata row per agent.md §6 + Step 11 hh_decision_action call; REGISTERED in autosend-policy.yaml per R19 fix
agents/recruitment/concierge/tools.yaml:178:    action_type: operator_notify_telegram  # green; REGISTERED in autosend-policy.yaml
agents/recruitment/concierge/tools.yaml:187:  - id: concierge_cleanup
agents/recruitment/concierge/tools.yaml:189:    action_type: concierge_cleanup  # green tier; QUEUED registration for cleanup.sh wire at W10-13
agents/recruitment/concierge/tools.yaml:198:#   concierge_email_draft              yellow              [Concierge §3 output contract]
agents/recruitment/concierge/tools.yaml:199:#   concierge_approval_routed          orange-adjacent     [R19 registration fix]
agents/recruitment/concierge/tools.yaml:200:#   gmail_outlook_send_to_candidate    orange              [shared with Cash Conductor at audit layer when bullhorn channel = email]
agents/recruitment/concierge/tools.yaml:202:#   operator_notify_telegram           green
agents/recruitment/concierge/tools.yaml:205:#   bullhorn_oauth                     green               (W7 Janitor + Bullhorn partnership)
agents/recruitment/concierge/tools.yaml:206:#   bullhorn_activity_log_write        green               (W10-13 Concierge build slice)
agents/recruitment/concierge/tools.yaml:207:#   concierge_cleanup                  green               (W10-13 cleanup.sh wire)

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,120p;170,285p'" in /Users/madsadmin/code/CortexOS
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
   283	    timeout: PT30M
   284	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   285	    irreversible: true

codex
REJECTED

1. §1 omits a Gate A threshold required by the amended A6 spec. Line 17 says voice Gate A is “≥0.75 standard / ≥0.82 sensitive”, but ULTRAPLAN A6 line 566 requires the full position-specific set “≥0.75 / ≥0.78 / ≥0.82”. Fix §1 to name all three thresholds.

2. §3 gives an invalid `decision_log` audit-row signature for the draft. Line 103 says `phase='output'` with `action_type='concierge_email_draft'` and `tier='yellow'`, but `_shared/hook-helpers.sh` lines 203-214 define `hh_decision_output` without action_type/tier; autosend tiering applies via `hh_decision_action` lines 216-223. Split this into a plain output row plus a `hh_decision_action("concierge_email_draft", ...)` row, or make the yellow draft row explicitly phase `action`.

3. §6 ESC routing does not match the catalogue. Lines 332-333 route `ESC_MS_GRAPH_AUTH` / `ESC_GMAIL_AUTH` to “tenant-admin”, but `escalation-codes.md` lines 264-278 route them to operator + ifos_oncall only; line 341 routes `ESC_APPROVAL_BRIDGE_TIMEOUT` to operator + tenant-admin, but catalogue lines 348-353 route operator + ifos_oncall. Fix the table to match the catalogue or amend the catalogue first.

4. Several ULTRAPLAN gotcha citations are not verifiable. Lines 17, 40, 77, 363, and 375 cite “ULTRAPLAN A6 §gotchas (line numbers vary; see live file)”, but this skill requires exact source citations; the live gotcha is at ULTRAPLAN lines 568-569. Replace “line numbers vary” citations with exact line references.
tokens used
125,992
REJECTED

1. §1 omits a Gate A threshold required by the amended A6 spec. Line 17 says voice Gate A is “≥0.75 standard / ≥0.82 sensitive”, but ULTRAPLAN A6 line 566 requires the full position-specific set “≥0.75 / ≥0.78 / ≥0.82”. Fix §1 to name all three thresholds.

2. §3 gives an invalid `decision_log` audit-row signature for the draft. Line 103 says `phase='output'` with `action_type='concierge_email_draft'` and `tier='yellow'`, but `_shared/hook-helpers.sh` lines 203-214 define `hh_decision_output` without action_type/tier; autosend tiering applies via `hh_decision_action` lines 216-223. Split this into a plain output row plus a `hh_decision_action("concierge_email_draft", ...)` row, or make the yellow draft row explicitly phase `action`.

3. §6 ESC routing does not match the catalogue. Lines 332-333 route `ESC_MS_GRAPH_AUTH` / `ESC_GMAIL_AUTH` to “tenant-admin”, but `escalation-codes.md` lines 264-278 route them to operator + ifos_oncall only; line 341 routes `ESC_APPROVAL_BRIDGE_TIMEOUT` to operator + tenant-admin, but catalogue lines 348-353 route operator + ifos_oncall. Fix the table to match the catalogue or amend the catalogue first.

4. Several ULTRAPLAN gotcha citations are not verifiable. Lines 17, 40, 77, 363, and 375 cite “ULTRAPLAN A6 §gotchas (line numbers vary; see live file)”, but this skill requires exact source citations; the live gotcha is at ULTRAPLAN lines 568-569. Replace “line numbers vary” citations with exact line references.
