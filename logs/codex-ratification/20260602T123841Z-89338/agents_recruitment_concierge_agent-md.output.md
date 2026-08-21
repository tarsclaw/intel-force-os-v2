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
session id: 019e8859-5ada-7032-ad3f-24d466cc0d1b
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
I’ll verify the cited source files and catalogue/policy entries before giving the verdict, because this artefact depends heavily on line-anchored claims and registered action/ESC codes.
exec
/bin/zsh -lc 'wc -l docs/verticals/recruitment/vertical-schema.yaml agents/_shared/escalation-codes.md agents/_shared/autosend-policy.yaml agents/_shared/voice-loader.sh agents/_shared/hook-helpers.sh 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     907 docs/verticals/recruitment/vertical-schema.yaml
     489 agents/_shared/escalation-codes.md
     416 agents/_shared/autosend-policy.yaml
     294 agents/_shared/voice-loader.sh
     575 agents/_shared/hook-helpers.sh
    2681 total

exec
/bin/zsh -lc "rg --files docs agents packages | rg '(ULTRAPLAN|master|brief|autosend.*policy|escalation-codes|voice-loader|hook-helpers|vertical-schema|v1.0-kill|ADR-007|agent.md|tools.yaml)"'$'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/tools.yaml
agents/recruitment/cash-conductor/agent.md
agents/recruitment/scribe/agent.md
agents/recruitment/sourcing-scout/agent.md
agents/recruitment/janitor/agent.md
agents/recruitment/diagnostic/tools.yaml
agents/recruitment/diagnostic/agent.md
docs/_supplementary/PRD-autonomous-agent.md
agents/recruitment/concierge/tools.yaml
agents/recruitment/concierge/agent.md
packages/agent-renderer/tests/fixtures/test-agent/tools.yaml
packages/agent-renderer/tests/fixtures/test-agent/agent.md

exec
/bin/zsh -lc 'rg -n "Concierge|A6|W10|ESC_CONCIERGE|ESC_APPROVAL|concierge_email_draft|gmail_outlook_send_to_candidate|bullhorn_activity_log_write|concierge_approval_routed|twilio_sms_send|calendar_invite_send|hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|tenant_adapters|recent_edit|tone_rule" docs agents packages -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:9:# Concierge schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:97:          Concierge reads for outreach context (NOT for outbound — outreach
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:103:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:114:          Concierge reads to route outbound lifecycle comms.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:118:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:125:          is in transcript. Concierge respects this when scheduling lifecycle
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:130:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:188:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:202:          to the vault file content; Concierge reads the vault file directly
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:208:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:217:          Concierge reads to adjust nurture tone.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:221:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:256:          Free-text capture of decision-timing phrases. Concierge reads to
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:261:          - Concierge: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:303:#   - Concierge candidate: R → R+W (writes lifecycle-state-derived fields +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:305:#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:306:#   - Concierge opportunity: none → R (reads for outbound lifecycle-event context)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:307:#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:309:#   - Concierge timesheet: none → R (reads to verify placement-progress for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:311:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:313:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:327:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:335:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:413:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:444:    # Concierge's Bullhorn endpoint access (Candidate / ClientCorporation /
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:446:    # row A6. opportunity + timesheet access below is IFOS-cached Postgres
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:448:    candidate: R+W         # CORRECTED v0.3 (was R); writes lifecycle-state-derived fields + activity-log links per concierge §4 Step 13-14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:449:    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:450:    client: R              # IFOS-cached read (Bullhorn endpoint A6 — ClientCorporation)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:451:    contact: R             # IFOS-cached read; outbound recipient resolution (Bullhorn endpoint A6 — Note context)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:452:    brief: R               # IFOS-cached read (Bullhorn endpoint A6 — JobOrder)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:454:    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:472:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:479:      - Concierge (R)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:492:      - Concierge (R)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:499:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:504:      - Concierge (R)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:518:      - Concierge (R)      # v0.3 NEW — reads for outbound lifecycle context
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:522:      Scribe (writes), Sourcing Scout (reads for ICP), Concierge (reads for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:526:    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:531:      - Concierge (R+W)    # v0.3 UPGRADED — writes Bullhorn state advancement
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:533:      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:542:      - Concierge (R)      # v0.3 NEW — reads to verify placement-progress for nurture
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:545:      Scribe + Concierge (each reads timesheet for their respective
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:549:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:555:      - Concierge (R+W)    # v0.3 UPGRADED — writes lifecycle-state-derived fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:557:      v0.3 upgrades Concierge only (writes lifecycle-state and activity-log
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:570:      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:572:      Parallel to candidate: Concierge upgraded for lifecycle states; Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:578:    v0_2_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:579:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:585:      granted Scribe + Concierge; v0.3 extends to all 6.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:587:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:588:    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:594:      Diagnostic + Sourcing Scout also read tone_rules for their
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:597:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:598:    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:601:      - Concierge (R)            # v0.2 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:609:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:719:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:728:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:730:    # Per §2a amendment: v0.3 expands access (Concierge R from v0.2;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:779:      Concierge polling cron updates at end of each cycle. Next poll queries
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:805:      Per-tenant outbound sending hours. Concierge respects when scheduling
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:918:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:927:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1019:  Concierge) cannot re-ratify until referenced schema fields exist. v0.3
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1040:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1042:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:62:      - Concierge (R — voice samples for outbound message generation)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:130:      - Concierge (R — every outbound message)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:252:      tone_rules_triggered:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:257:          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:309:        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:317:        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:341:  voice_corpus_governs_tone_rules:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:343:    target: tone_rule
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:346:      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:393:  Q12_tone_rule_severity_block_path:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:401:    trigger_for_revisit: first Concierge build (W10) — measure real retry success rate
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:441:    expected_date: post-Concierge build (W10-13) — first agent to heavily exercise voice corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.yaml:56:      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
docs/verticals/recruitment/vertical-schema.yaml:161:      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
docs/verticals/recruitment/vertical-schema.yaml:191:        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
docs/verticals/recruitment/vertical-schema.yaml:204:        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
docs/verticals/recruitment/vertical-schema.yaml:205:        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
docs/verticals/recruitment/vertical-schema.yaml:214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
docs/verticals/recruitment/vertical-schema.yaml:217:      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
docs/verticals/recruitment/vertical-schema.yaml:228:      - Concierge (R — relationship context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:288:      - Concierge (R — decision-maker context per bullhorn §4.1 A6; thin in v1.0)
docs/verticals/recruitment/vertical-schema.yaml:321:        notes: v0.1 is essentially a tag for Concierge addressee-resolution gating; v1.1 Triage agent owns expansion (sub-fields for decision-domain, budget authority, etc.).
docs/verticals/recruitment/vertical-schema.yaml:334:        source: IFOS-derived (Concierge addressee-resolution gate per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
docs/verticals/recruitment/vertical-schema.yaml:350:      - Concierge (R — linked-brief context per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:410:        source: IFOS-derived (Concierge maintains based on client check-in cadence)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:436:      - Concierge (R+W — lifecycle stage maintenance per bullhorn §4.1 A6)
docs/verticals/recruitment/vertical-schema.yaml:480:        source: IFOS-derived (Concierge maintains per Product Spec §2.2 R7 lifecycle cadence)
docs/verticals/recruitment/vertical-schema.yaml:481:        notes: Drives Concierge nurture-event firing.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:599:    v1_0_exercise: Concierge reads to anchor lifecycle communications; Scribe reads for write-context resolution.
docs/verticals/recruitment/vertical-schema.yaml:615:    v1_0_exercise: Concierge reads for addressee-resolution per bullhorn §4.1 A6 Voice gate; addressee = primary decision-maker contact.
docs/verticals/recruitment/vertical-schema.yaml:623:    v1_0_exercise: Concierge addressee context.
docs/verticals/recruitment/vertical-schema.yaml:630:    v1_0_exercise: Concierge reads for outbound-message addressee correctness; thin in v1.0.
docs/verticals/recruitment/vertical-schema.yaml:686:    contact: R       # read-only (Concierge owns writes)
docs/verticals/recruitment/vertical-schema.yaml:722:  Concierge:
docs/verticals/recruitment/vertical-schema.yaml:775:    notes: lifecycle_stage is IFOS-derived (Concierge maintains); Bullhorn does not natively store IFOS's nurture-cadence stages.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
docs/verticals/recruitment/vertical-schema.yaml:856:    rationale: v1.0 Concierge addressee-resolution uses primary-decision-maker; panel modelling adds value when v1.1 Triage handles inbound brief queries from multiple stakeholders.
docs/verticals/recruitment/vertical-schema.yaml:862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:26:DROP TABLE IF EXISTS recent_edit          CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:27:DROP TABLE IF EXISTS tone_rule            CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:6:-- side effects on existing recent_edit data).
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:15:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:18:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:19:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:21:DROP INDEX IF EXISTS recent_edit_text_purged_idx;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:23:ALTER TABLE recent_edit
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:101:  concierge_approval_routed:
agents/_shared/autosend-policy.yaml:104:    reason: "Internal audit row recorded by Concierge cycle.sh Step 11 when an approval is routed via the autosend-bridge (per Founder Decision D1 path A/B/C). Payload carries d1_path + bridge_target (approval_id or vault path). Not an external send; the actual send is a downstream orange-tier action_type with its own row."
agents/_shared/autosend-policy.yaml:181:  bullhorn_activity_log_write:
agents/_shared/autosend-policy.yaml:184:    reason: "Internal Bullhorn activity-log entry — NOT customer-visible (separate from bullhorn_note_customer_visible which is orange). Maintains the audit trail in Bullhorn itself so downstream consultant ops see Concierge actions on the candidate's record. Idempotent within payload_hash dedup window. Registered per Codex Fbis-R1 closure 2026-06-02 — Concierge agent.md §4 Step 13 needs this for tier classification of the external write."
agents/_shared/autosend-policy.yaml:209:    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
agents/_shared/autosend-policy.yaml:254:  concierge_email_draft:
agents/_shared/autosend-policy.yaml:258:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
agents/_shared/autosend-policy.yaml:273:  gmail_outlook_send_to_candidate:
agents/_shared/autosend-policy.yaml:280:  twilio_sms_send:
agents/_shared/autosend-policy.yaml:287:  calendar_invite_send:
agents/_shared/autosend-policy.yaml:386:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:397:# Defaults applied when override fields are absent in tenant_adapters
agents/_shared/escalation-codes.md:265:- **Severity:** **blocking** — Concierge cannot send candidate emails; falls back to draft-only
agents/_shared/escalation-codes.md:273:- **Severity:** **blocking** — Concierge Outlook send disabled; drafts-only
agents/_shared/escalation-codes.md:348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:386:- **Severity:** warn — voice/tone classifier flagged output as violating a tenant `tone_rule` row
agents/_shared/escalation-codes.md:387:- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
agents/_shared/escalation-codes.md:390:- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
agents/_shared/escalation-codes.md:391:- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review
agents/_shared/escalation-codes.md:411:  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
agents/_shared/escalation-codes.md:414:- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/escalation-codes.md:431:#### `ESC_CONCIERGE_SLA_MISS`
agents/_shared/escalation-codes.md:433:- **Trigger:** Concierge SLA breached. Three canonical sla_types:
agents/_shared/escalation-codes.md:436:  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
agents/_shared/escalation-codes.md:452:  - **Concierge:** Bullhorn state transition is outside the 12-event v1.0 taxonomy (acknowledgement / prep / debrief / placement / rejection / withdrawal / on-hold / start-confirm / 7d-checkin / 30d-checkin / 90d-checkin / nurture); handler logs + skips draft
agents/_shared/escalation-codes.md:455:- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields
agents/_shared/hook-helpers.sh:312:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:419:# tenant override via tenant_adapters.config.sampling_rates.
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:75:# Returns active tone_rule rows filtered to agent_name (or all rules if
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:86:           FROM tone_rule
agents/_shared/voice-loader.sh:92:           FROM tone_rule
agents/_shared/voice-loader.sh:98:    _vl_render_tone_rules_json "${rows}"
agents/_shared/voice-loader.sh:113:_vl_render_tone_rules_json() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:225:# Returns recent_edit rows from the last <lookback_days> for <agent_name>
agents/_shared/voice-loader.sh:230:#                  "resolution": "...", "tone_rules_triggered": [...],
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/_shared/voice-loader.sh:245:      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
agents/_shared/voice-loader.sh:246:           FROM recent_edit
agents/_shared/voice-loader.sh:252:      sql="SELECT id, action_type, COALESCE(edit_distance::text, ''), resolution, COALESCE(array_to_string(tone_rules_triggered, ','), ''), resolved_at::text
agents/_shared/voice-loader.sh:253:           FROM recent_edit
agents/_shared/voice-loader.sh:260:    _vl_render_recent_edits_json "${rows}" "${lookback_days}"
agents/_shared/voice-loader.sh:268:_vl_render_recent_edits_json() {
agents/_shared/voice-loader.sh:279:  while IFS=$'\t' read -r id action_type edit_distance resolution tone_rules resolved_at; do
agents/_shared/voice-loader.sh:282:    printf '{"id":%s,"action_type":"%s","edit_distance":%s,"resolution":"%s","tone_rules_triggered":"%s","resolved_at":"%s"}' \
agents/_shared/voice-loader.sh:287:      "$(_hh_json_escape "${tone_rules}")" \
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:144:   - 4 new tables (`voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`)
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:10:-- Concierge). v0.3 additions:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:26:--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:49:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:50:    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:419:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:453:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:529:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:531:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:532:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:534:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
agents/_shared/tests/test-voice-loader.sh:70:printf '\n[1] hh_load_tone_rules returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:71:test_tone_rules_empty() {
agents/_shared/tests/test-voice-loader.sh:73:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:76:_test_run "tone_rules fallback (no DB, no file): empty rules" test_tone_rules_empty
agents/_shared/tests/test-voice-loader.sh:78:printf '\n[2] hh_load_tone_rules reads tone-rules.yaml fallback path\n'
agents/_shared/tests/test-voice-loader.sh:79:test_tone_rules_fallback() {
agents/_shared/tests/test-voice-loader.sh:86:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:89:_test_run "tone_rules fallback: fallback_path surfaced" test_tone_rules_fallback
agents/_shared/tests/test-voice-loader.sh:91:printf '\n[3] hh_load_voice_samples returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:94:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:99:printf '\n[4] hh_load_voice_samples surfaces style guide when present\n'
agents/_shared/tests/test-voice-loader.sh:103:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:110:printf '\n[5] hh_load_voice_samples top_k validation clamps to 10\n'
agents/_shared/tests/test-voice-loader.sh:113:  out=$(hh_load_voice_samples "task" "abc")  # non-numeric → 10
agents/_shared/tests/test-voice-loader.sh:115:  out=$(hh_load_voice_samples "task" "999")  # over cap → 10
agents/_shared/tests/test-voice-loader.sh:117:  out=$(hh_load_voice_samples "task" "0")    # zero → 10
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
agents/_shared/tests/test-voice-loader.sh:156:  out1=$(hh_load_tone_rules | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:157:  out2=$(hh_load_voice_samples "task" | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:158:  out3=$(hh_load_recent_edits | wc -l | tr -d ' ')
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:110:-- §4 — Create tone_rule table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:113:CREATE TABLE IF NOT EXISTS tone_rule (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:126:  CONSTRAINT tone_rule_tenant_rule_id_unique UNIQUE (tenant_slug, rule_id)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:129:CREATE INDEX IF NOT EXISTS tone_rule_tenant_enabled_idx ON tone_rule (tenant_slug, enabled);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:131:ALTER TABLE tone_rule ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:132:ALTER TABLE tone_rule FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:133:DROP POLICY IF EXISTS tone_rule_tenant_isolation ON tone_rule;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:134:CREATE POLICY tone_rule_tenant_isolation ON tone_rule
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:138:-- §5 — Create recent_edit table
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:141:CREATE TABLE IF NOT EXISTS recent_edit (
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:179:GRANT SELECT, INSERT, UPDATE, DELETE ON tone_rule           TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:180:GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:184:GRANT USAGE, SELECT ON SEQUENCE tone_rule_id_seq           TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:185:GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:201:--   ALTER TABLE tone_rule OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:202:--   ALTER TABLE recent_edit OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:205:--   ALTER SEQUENCE tone_rule_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:206:--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
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
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:78:--   WHERE table_name='recent_edit' AND column_name='text_purged_at';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:82:--   WHERE table_name='recent_edit' AND column_name='original_text';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:86:--   WHERE table_name='recent_edit' AND constraint_name='recent_edit_text_purged_consistency';
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:90:--   WHERE tablename='recent_edit' AND indexname='recent_edit_text_purged_idx';
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:23:- Telegram bot token from `_secrets.env` (existing per Day-4 provisioning); operator chat ID from `tenant_adapters.config.operator_telegram_chat_id` (canonical config key)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:24:- Default timeout `PT4H` per `escalation-codes.md` lines 348-353 (`ESC_APPROVAL_BRIDGE_TIMEOUT`)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:25:- Fail-safe: timeout returns `{outcome: "timeout"}` not an exception — caller (Cash Conductor cycle.sh Step 10, Concierge cycle.sh) decides how to fire the ESC code
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:27:≥12 vitest (scaffold + config + propose + await with poll-mock + timeout + reject path + concurrent same-approval-id idempotency). Live Telegram tests gated `BRIDGE_LIVE_TESTS=true`. Zero credential interpolations in errors. README documents D1-B precedent + Concierge W10 integration contract + Cash Conductor `cycle.sh` Step 10 wiring.
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:87:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:91:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:93:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:95:-- tenant_adapters config validation trigger.
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:8:#   to Concierge approval bridge (if autosend-bridge-telegram present)
agents/recruitment/cash-conductor/cycle.sh:29:#      per autosend-policy.yaml line 263; Concierge handles approval-bridge transport
agents/recruitment/cash-conductor/cycle.sh:138:  # TODO(W7-8): provider-aware (tenant_adapters.config.accounting_provider)
agents/recruitment/cash-conductor/cycle.sh:208:# Step 10 — Chase-draft queue to Concierge (opens orange-tier approval bridge)
agents/recruitment/cash-conductor/cycle.sh:211:# line 263; Concierge handles autosend-bridge-telegram approval routing + transport.
agents/recruitment/cash-conductor/cycle.sh:269:    #        # Step 11 transport proceeds (webhook-driven from Concierge after send)
agents/recruitment/cash-conductor/cycle.sh:275:    #        # ESC_APPROVAL_BRIDGE_TIMEOUT per agents/_shared/escalation-codes.md
agents/recruitment/cash-conductor/cycle.sh:280:    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
agents/recruitment/cash-conductor/cycle.sh:295:# Cash Conductor receives webhook from Concierge after transport completes;
agents/recruitment/cash-conductor/cycle.sh:337:# tenant_adapters.config.cash_conductor_last_run (declared in v0.3 supplement; validated
agents/recruitment/cash-conductor/cycle.sh:338:# by validate_tenant_adapters_config_v0_3 trigger landed 2026-05-31).
agents/recruitment/cash-conductor/cycle.sh:339:# TODO(W7-8): UPDATE tenant_adapters SET config = jsonb_set(config, '{cash_conductor_last_run}', '"<ISO>"')
docs/operations/goal-week-4-track-1.md:48:5. **`agents/recruitment/cash-conductor/cycle.sh`** exists; 14 steps per agent.md §4. Wires to the 3 connectors above + the D1-B `autosend-bridge-telegram` package (built separately at Concierge W10; cycle.sh degrades gracefully when absent — drafts-only mode per agent.md §1 readiness caveat).
docs/operations/goal-week-4-track-1.md:108:| `autosend-bridge-telegram` package | Reserved for Concierge W10 build slice per D1-B doc §"Implementation surface"; Cash Conductor cycle.sh degrades gracefully when absent (drafts-only mode) |
docs/operations/goal-week-4-track-1.md:366:| Cash Conductor bundle integration with `autosend-bridge-telegram` blocked (package not yet built — that's Concierge W10) | cycle.sh degrades to drafts-only mode per agent.md §1 readiness caveat; documented and tested via fixture 01-primary |
agents/recruitment/cash-conductor/tools.yaml:24:  # Accounting providers (per-tenant — choose ONE via tenant_adapters.config.accounting_provider)
agents/recruitment/cash-conductor/tools.yaml:134:  # both Concierge AND Cash Conductor (Cash Conductor is the Step-10 consumer).
agents/recruitment/cash-conductor/tools.yaml:160:        escalation: ESC_APPROVAL_BRIDGE_TIMEOUT  # warn-tier per escalation-codes.md lines 348-353; routes operator_chat_id + ifos_oncall_chat_id; action converts to manual reconciliation
agents/recruitment/cash-conductor/validate.sh:15:# and the queue-to-Concierge (Step 10). If any check fails, validate.sh exits
agents/recruitment/cash-conductor/validate.sh:17:# NOT route to Concierge; cycle.sh aborts the draft pipeline.
agents/recruitment/cash-conductor/context.sh:16:#   CTX_TONE_RULES_COUNT      number of tone_rule rows loaded
agents/recruitment/cash-conductor/context.sh:17:#   CTX_RECENT_EDITS_COUNT    recent_edit rows seen (drift signal)
agents/recruitment/cash-conductor/context.sh:73:# tenant_adapters.config; defaults to xero + truelayer per Cash Conductor §9 Q1+Q2.
agents/recruitment/cash-conductor/context.sh:77:# FROM tenant_adapters WHERE tenant_slug = $CTX_TENANT_SLUG; honour defaults.
agents/recruitment/cash-conductor/context.sh:78:# v0.3 supplement §4 tenant_adapters_config_additions includes neither key yet;
agents/recruitment/cash-conductor/context.sh:92:# Tone rules — voice-loader.sh hh_load_tone_rules signature: filter applies_to_agents
agents/recruitment/cash-conductor/context.sh:96:# TODO(W7-8): CTX_TONE_RULES=$(hh_load_tone_rules "cash_conductor" 2>/dev/null || echo "[]")
agents/recruitment/cash-conductor/context.sh:99:# Voice corpus — hh_load_voice_samples returns top-5 ANN matches for the task
agents/recruitment/cash-conductor/context.sh:103:# TODO(W7-8): CTX_VOICE_CORPUS_ID=$(hh_load_voice_samples "${CTX_TENANT_SLUG}" "chase-email" 2>/dev/null)
agents/recruitment/cash-conductor/context.sh:105:# Recent edits — Cash Conductor has recent_edit W-only per v0.3 supplement
agents/recruitment/cash-conductor/context.sh:107:# hh_load_recent_edits (canary cron reads instead).
agents/recruitment/cash-conductor/context.sh:142:  "cash-conductor tenant=${CTX_TENANT_SLUG} accounting=${CTX_ACCOUNTING_PROVIDER} open_banking=${CTX_OPEN_BANKING_PROVIDER} token_stage=${CTX_OPEN_BANKING_TOKEN_STAGE} voice_corpus=${CTX_VOICE_CORPUS_ID:-<empty>} tone_rules=${CTX_TONE_RULES_COUNT}"
agents/recruitment/cash-conductor/context.sh:145:printf '[cash-conductor context.sh] tenant=%s accounting=%s open_banking=%s token_stage=%s voice_corpus=%s tone_rules=%s\n' \
docs/operations/w4-bilateral-pass-6-agent-md.md:40:| 6 | Concierge | 4 | Depends on Concierge-Gate-A ADR (W4 #3) — may defer to that ADR. |
docs/operations/w4-bilateral-pass-6-agent-md.md:91:  - **Cite:** §3 line 59; cross-ref v0.2 supplement §1.3 (recent_edit.resolution)
docs/operations/w4-bilateral-pass-6-agent-md.md:92:  - **Codex says:** "Line 59 says tacit notes are harvested from `decision_log` rows with `outcome='approved_after_edit'`, but the schema only documents `decision_log` as `agent_name`, `phase`, and `payload JSONB`; `approved_after_edit` is the `recent_edit.resolution` enum in v0.2 supplement §1.3. Fix §3 to harvest from `recent_edit.resolution='approved_after_edit'` and use `decision_log` only for action-context joins."
docs/operations/w4-bilateral-pass-6-agent-md.md:93:  - **Likely:** FIX-IN-PLACE. Rewrite §3 line 59 to source from `recent_edit.resolution`. Note that `decision_log.outcome` was added in `recent_edit`'s sister table in v0.3; verify this hasn't changed Codex's read.
docs/operations/w4-bilateral-pass-6-agent-md.md:96:### Finding 3. Wrong schema authority for recent_edit access
docs/operations/w4-bilateral-pass-6-agent-md.md:98:  - **Codex says:** "Lines 135-137 say Janitor queries the `recent_edit` v0.2 table directly, but v0.2 access lists only voice-drift-canary, Concierge, and LoRA; Janitor R access is added in v0.3 supplement §2. Fix the citation to v0.3 supplement and add v0.3 schema/migration ratification as a §8 prerequisite."
docs/operations/w4-bilateral-pass-6-agent-md.md:104:  - **Codex says:** "Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement's `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist."
docs/operations/w4-bilateral-pass-6-agent-md.md:105:  - **Likely:** **REJECT-CODEX** with rationale, OR small schema supplement edit. The migration allowlist IS the v0.3 supplement enforcement (per ADR-006 + the v0.3 trigger). But Codex's point is that they should also appear in the YAML schema definition (`tenant_adapters_config_additions`) for documentation completeness. Founder call: edit the YAML supplement to declare them explicitly, OR write disagreement claiming migration-allowlist is sufficient single-source-of-truth.
docs/operations/w4-bilateral-pass-6-agent-md.md:144:### Finding 2. Concierge/D1 dependency under-specified
docs/operations/w4-bilateral-pass-6-agent-md.md:146:  - **Codex says:** "Line 380 says Cash Conductor only depends on Concierge `agent.md` being Accepted, but lines 235-253 require Concierge to receive drafts, run the approval bridge, transport sends, and callback; line 244 also cites the unresolved D1 path. Add Founder Decision D1 resolved + autosend bridge/Concierge transport availability as explicit prerequisites, or rewrite §4 to use the existing shared autosend approval helper without Concierge."
docs/operations/w4-bilateral-pass-6-agent-md.md:147:  - **Likely:** FIX-IN-PLACE. Add to §8 prereqs: (a) D1 resolved, (b) Concierge autosend-bridge live. Note: D1 is W4 queue #4 — this finding documents the dependency in the agent.md but does NOT block ratification of the scaffold (Status will be Proposed→Pre-Build pending D1).
docs/operations/w4-bilateral-pass-6-agent-md.md:194:## 6. Concierge — `agents/recruitment/concierge/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:201:  - **Likely:** FIX-IN-PLACE. Add `hh_decision_output concierge_email_draft` after line 193; add `hh_decision_action approval_routed` after line 228.
docs/operations/w4-bilateral-pass-6-agent-md.md:206:  - **Codex says:** "Line 67 says 'an email draft (orange tier)', but lines 102 and autosend-policy define `concierge_email_draft` as yellow; only the send actions are orange. This creates an internal contract conflict for Gate A/B and decision_log rows. Change line 67 to 'email draft (yellow tier); send is separate orange-tier action'."
docs/operations/w4-bilateral-pass-6-agent-md.md:211:  - **Cite:** §10 lines 417-421; cross-ref ULTRAPLAN A6 line 566 + lines 206-212/276
docs/operations/w4-bilateral-pass-6-agent-md.md:212:  - **Codex says:** "Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria. Either keep the 30-minute SLA as Gate A, or add the Concierge-Gate-A ADR ratification as an explicit Accepted blocker."
docs/operations/w4-bilateral-pass-6-agent-md.md:213:  - **Likely:** **SCOPE-EXPAND**. This is the analogue of ADR-006 for Diagnostic. W4 queue #3 already plans this ADR ("Future ADR — Concierge Gate A 30-min SLA hybrid"). Disposition options:
docs/operations/w4-bilateral-pass-6-agent-md.md:214:    - (a) Add Concierge-Gate-A-ADR to §10 Accepted blockers; flip Concierge agent.md → RATIFIED (but Status stays Proposed pending ADR). W4 #3 then writes the ADR + closes the loop.
docs/operations/w4-bilateral-pass-6-agent-md.md:219:  - **Cite:** §3 lines 16, 39, 76, 333, 345; cross-ref ULTRAPLAN A6
docs/operations/w4-bilateral-pass-6-agent-md.md:220:  - **Codex says:** "Lines 16, 39, 76, 333, and 345 cite line 570 for lifecycle/rejection gotchas, but verified ULTRAPLAN has the gotcha text on line 569 and line 570 is blank. Update these citations to ULTRAPLAN A6 line 569."
docs/operations/w4-bilateral-pass-6-agent-md.md:221:  - **Likely:** FIX-IN-PLACE. Find-and-replace `ULTRAPLAN A6 line 570` → `ULTRAPLAN A6 line 569`. Verify count: 5 sites.
docs/operations/w4-bilateral-pass-6-agent-md.md:228:1. **Hh_decision_* coverage** (Scribe #2, Concierge #1) — workflow narratives are dropping the decision-log writes between numbered steps. After this pass, recommend a one-shot grep on all 6 agent.md to confirm every workflow step that produces output/action has an `hh_decision_*` annotation.
docs/operations/w4-bilateral-pass-6-agent-md.md:234:4. **Concierge Gate-A ADR** (Concierge #3) — only structural finding. Recommend writing the ADR before flipping Concierge to RATIFIED (analogue of ADR-006 process).
docs/operations/w4-bilateral-pass-6-agent-md.md:255:- [ ] Remaining agents have concrete blockers documented (e.g., "Concierge pending Concierge-Gate-A ADR")
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:34:| 12 | **PII purge remediation cannot execute against current schema** — `v0.2-to-v0.3-pii-purge.sql` adds `text_purged_at` and a CHECK requiring text fields to be NULL after purge, but v0.2 declares `recent_edit.original_text TEXT NOT NULL`; the purge script sets `original_text=NULL`. | ~~High~~ → Low post-remediation | ~~High~~ → Low for cron execution; legal posture still depends on D2/D3 | `v0.2-to-v0.3-pii-purge.sql` executed without `ALTER COLUMN original_text DROP NOT NULL`. | Round-2 remediation Fix 2 adds `ALTER COLUMN DROP NOT NULL` before the CHECK constraint. Verified by Round 3. | **Mitigated in this commit; remains pending D2/D3 founder decisions before production deployment.** |
docs/RISK-REGISTER.md:55:- 2026-05-22 (Day 11) — **Codex Round 2 autonomous ratification complete.** 26 artefacts reviewed; 17 RATIFIED / 9 REJECTED. Manifest §1.7 appended and full outputs written to `logs/codex-ratification/round-2-autonomous/`. D5 skill softening ratified. Bullhorn gate disagreement rejected because the promised source-doc sharpening did not land. Autosend policy, v0.2 supplement, approval bridge, PII purge runbook/script/forward migration, and tenancy audit script remain rejected. **New Risk #11** added for transactionless `SET LOCAL` usage across live DB scripts/helpers. **New Risk #12** added for the PII purge migration/script mismatch with `recent_edit.original_text NOT NULL`.
docs/RISK-REGISTER.md:56:- 2026-05-22 (Day 11 evening) — **Codex Round-2 remediation applied + Round 3 verified.** Fixes wrap all identified `SET LOCAL` calls in explicit transactions and make `recent_edit.original_text` nullable before PII purge; Risks #11 and #12 moved to mitigated. Founder-domain D1/D2/D3 remain open and are explicitly annotated in the affected artefacts.
docs/RISK-REGISTER.md:66:- 2026-05-20 (Day 8 evening) — **Codex ratification Round 1 complete + remediation landed.** 16 artefacts reviewed (Cluster A+B+C); 2 RATIFIED (ADR-004, brain-ui-scope); 14 REJECTED. Remediation commit `2b287d3` incorporates 13 of 14 rejections (Bucket 1 cosmetic + Bucket 2 ADR-004 back-propagation + Bucket 3 structural). 2 disagreement docs filed (`codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` + `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`). 5 founder decisions surfaced (D1-D5 in `2026-05-20-codex-round-1-founder-decisions.md`). **NEW Risk #10 candidate surfaced by Codex** (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation) — see Risk #10 below. Manifest queue updated with per-artefact Round-1 verdicts (`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5). Round 2 expected to take 14 REJECTED → 0-2 REJECTED.
agents/recruitment/cash-conductor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (2026-05-24): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim; `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring landed (commit `076e231`). Remaining gates: Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice replacing the SKELETON TODOs with live impl + Concierge W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) so the orange-tier send path activates.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify); Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and degrades to **drafts-only** mode — produces yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT emit the orange-tier `xero_reminder_send_customer` rows (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:57:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:96:### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)
agents/recruitment/cash-conductor/agent.md:98:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type — grep `^  xero_reminder_send_customer:` in `agents/_shared/autosend-policy.yaml` to verify it's registered there under §ORANGE) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:121:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml lookup; grep `^  xero_reminder_send_customer:` to verify; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
agents/recruitment/cash-conductor/agent.md:251:10. Chase-draft queue to Concierge (opens orange-tier approval bridge)
agents/recruitment/cash-conductor/agent.md:252:    → POST internal API → Concierge agent receives draft
agents/recruitment/cash-conductor/agent.md:260:      Concierge handles autosend-bridge call to operator (D1 path per
agents/recruitment/cash-conductor/agent.md:263:11. (Operator approves via Concierge's bridge → Concierge transports the
agents/recruitment/cash-conductor/agent.md:268:      Concierge does NOT write its own action row for this — Concierge's
agents/recruitment/cash-conductor/agent.md:270:    → Concierge fires webhook back: chase_sent (transport completed)
agents/recruitment/cash-conductor/agent.md:294:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:368:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:372:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:373:- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 729; recent_edit block at lines 721-731), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/agent.md:397:| Concierge agent.md ratified Accepted (for chase-send routing contract; full Concierge production-build at W10-13, but Cash Conductor only depends on the Concierge agent.md contract being Accepted, not the full bundle being In Force) | Post-Concierge agent.md re-ratification | ⏸ |
agents/recruitment/cash-conductor/agent.md:407:| **Autosend bridge production wiring** — real Telegram Bot API + postgres approvals reader; Concierge W10-13 build delivers; blocking for orange-tier send activation | Concierge W10-13 build slice (per D1-B decision-doc §"Implementation surface") | ⏸ |
agents/recruitment/cash-conductor/agent.md:408:| Fallback (interim): cycle.sh Step 10 detects absent `packages/utilities/autosend-bridge-telegram/dist/` and runs in drafts-only mode (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` until W10-13 wiring activates) | v1.0 interim — active until W10-13 | n/a |
agents/recruitment/cash-conductor/agent.md:449:NOTE: D1 RESOLVED is NO LONGER a Proposed→Accepted blocker — D1 was Accepted 2026-05-31 as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`, and the package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`). The autosend-bridge **production wiring** (real Telegram Bot API) remains a Concierge W10-13 deliverable; until then, Cash Conductor runs in drafts-only mode (interim — see §8 fallback row). The bridge wiring is an Accepted→In-Force blocker (build slice + first-production criterion below), not a Proposed→Accepted blocker.
agents/recruitment/cash-conductor/agent.md:453:- Concierge W10-13 lands the autosend-bridge production wiring so orange-tier sends activate
docs/operations/w4-day-20-founder-runbook.md:72:- ✓ `validate_tenant_adapters_config_v0_3` trigger present on `tenant_adapters`
docs/operations/w4-day-20-founder-runbook.md:87:The 11 tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`, `cash_conductor_transactions`, `cash_conductor_invoices`.
docs/operations/w4-day-20-founder-runbook.md:113:6. Concierge (4 findings) — depends on Concierge-Gate-A ADR (W4 item #3)
docs/operations/w4-day-20-founder-runbook.md:119:- **SCOPE-EXPAND** — finding reveals new ADR-worthy decision (e.g., Concierge-Gate-A)
docs/operations/w4-day-20-founder-runbook.md:131:W4 queue items #3 + #4. Concierge-Gate-A 30-min SLA hybrid ADR is needed
docs/operations/w4-day-20-founder-runbook.md:132:before Concierge agent.md can flip Status to Accepted. D1 founder decision
docs/operations/w4-day-20-founder-runbook.md:133:on autosend orange-tier path blocks Concierge build slice. Both are session
docs/operations/w4-day-20-founder-runbook.md:134:prerequisites for the Concierge bundle render; neither blocks Diagnostic.
agents/recruitment/scribe/agent.md:136:     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
agents/recruitment/scribe/agent.md:257:- **Quality:** consultant edit-rate ≤20% on structured fields (measured via `recent_edit` rows for `agent_name='scribe'`)
agents/recruitment/scribe/agent.md:295:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:299:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:300:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Scribe does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Scribe.
agents/recruitment/scribe/agent.md:347:| Q6 | Consultant edit-rate ≤20% metric — how to measure when consultants edit Bullhorn entities outside our `recent_edit` audit path? | Use Bullhorn's audit log API + cross-reference with our writes. Founder approve approach at W6 design review. |
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:38:- **Subtle case:** `recent_edit.original_text` was originally `TEXT NOT NULL` in v0.2; v0.3 (post Round-2 remediation) drops that NOT NULL constraint to allow PII purge to set `original_text=NULL`. This does not weaken T1: `recent_edit.tenant_slug` remains `TEXT NOT NULL`.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:86:### T5 — `ifos_app` role has no DELETE on `decision_log` or `recent_edit` (append-only audit tables)
docs/architecture/tenancy-invariants.md:88:- **Definition:** The two audit tables (`decision_log` from Day-4 + `recent_edit` from v0.2) are structurally append-only. Even if app code attempted DELETE, the role lacks permission.
docs/architecture/tenancy-invariants.md:90:- **Documentation source:** Day-4 §6.3 line 764 (`GRANT SELECT, INSERT ON decision_log TO ifos_app`) + v0.2 §6 line 172 (`GRANT SELECT, INSERT ON recent_edit TO ifos_app`).
docs/architecture/tenancy-invariants.md:94:  WHERE grantee='ifos_app' AND table_name IN ('decision_log','recent_edit')
docs/architecture/tenancy-invariants.md:97:  Expected: 4 rows total — `decision_log` × {SELECT, INSERT}, `recent_edit` × {SELECT, INSERT}. No UPDATE or DELETE.
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/architecture/tenancy-invariants.md:206:| T5 | Partial → Verified | Day-4 §6.3 GRANT inspection + tenancy audit | Day-4 §6.3 documented; pending adversarial in Day-9 | Decision_log + recent_edit confirmed |
docs/architecture/architecture-cohesion-review.md:93:| A6 | **Voice corpus chunks fit in pgvector memory at v1.0 scale.** HNSW index assumes per-tenant chunk count < 10K. | Phase 4 v0.2 supplement + voice-loader.sh queries | At 1 tenant × 5K chunks = ~30MB. 100 tenants × 5K = 3GB. Within Hetzner VPS RAM. Above 1000 tenants this becomes a real constraint. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:123:### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)
docs/architecture/architecture-cohesion-review.md:126:- **v0.2 supplement** `recent_edit.original_text` + `edited_text` store agent draft + consultant edit VERBATIM (8192 cap), explicitly admitting PII can be present
docs/architecture/architecture-cohesion-review.md:127:- **Status:** This is by design — `recent_edit` is the SFT corpus source, not the operator-facing audit. But Codex Round 1 flagged it as a GDPR risk (now Risk #10).
docs/architecture/architecture-cohesion-review.md:147:| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:202:  - **A:** `recent_edit.original_text` + `edited_text` are narrative (raw text). `tone_rule.rule_text` is natural language. `voice_corpus_chunks.text_chunk` is text. **These ARE narrative content in Postgres** — but they're indexed for retrieval, not for primary storage. The vault remains the source of truth for the original docs; Postgres holds the indexable chunked + classified copy. ✓ Acceptable hybrid.
docs/architecture/architecture-cohesion-review.md:228:| R2 | G8: Autosend v1.0 tier enforcement | High | Founder Decision D1 | Founder | Pre-Concierge W10 |
docs/architecture/architecture-cohesion-review.md:229:| R3 | C4: PII retention in recent_edit | High (Risk #10) | Founder Decision D3 bundles with D2 | Founder | Pre-first-LOI |
docs/architecture/architecture-cohesion-review.md:233:| R7 | G1: Voice corpus refresh cadence | Medium | New ADR-006 at Concierge build OR addendum to v0.2 supplement at v1.0 schema close | Claude Code | Week-9 (pre-Concierge) |
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
docs/architecture/architecture-cohesion-review.md:257:1. Founder Decisions D1 + D2 + D3 resolve before Concierge W10 + first pilot LOI signing
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (today): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:7:- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 398; allowlist block lines 396-409); canonical Postgres-backed v1.0 DNC source per ADR-002. Declared in `vertical-schema.v0.3-supplement.yaml` lines 810-827 (R19 added this declaration; no longer deferred).
agents/recruitment/sourcing-scout/agent.md:8:- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
agents/recruitment/sourcing-scout/agent.md:21:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:114:     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
agents/recruitment/sourcing-scout/agent.md:196:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:261:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
agents/recruitment/sourcing-scout/agent.md:316:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:321:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:322:- **Voice-drift detection (classifier-only):** per `vertical-schema.v0.3-supplement.yaml` lines 584-593 + 715-724, Sourcing Scout has `recent_edit` access of **W** (writes its rationale drafts) but **not R**, so it does NOT read consultant edit history via `hh_load_recent_edits`. Per-run `ESC_VOICE_DRIFT` fires when a per-candidate rationale voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Sourcing Scout does NOT fire `_TENANT` directly. The cron — not Sourcing Scout — reads edit history for analytics + canary threshold tuning.
agents/recruitment/sourcing-scout/agent.md:348:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
agents/recruitment/sourcing-scout/agent.md:369:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
docs/operations/codex-round-2-remediation-prompt.md:76:      ALTER TABLE recent_edit ALTER COLUMN original_text DROP NOT NULL;
docs/operations/codex-round-2-remediation-prompt.md:82:      ALTER TABLE recent_edit ALTER COLUMN original_text SET NOT NULL;
docs/operations/codex-round-2-remediation-prompt.md:252:           gmail_outlook_send_to_candidate     → external-comms
docs/operations/codex-round-2-remediation-prompt.md:253:           twilio_sms_send                     → external-comms
docs/operations/codex-round-2-remediation-prompt.md:254:           calendar_invite_send                → external-comms
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/operations/codex-round-2-remediation-prompt.md:340:If FIX 2 added DROP NOT NULL to recent_edit.original_text, the invariant
docs/operations/codex-round-2-remediation-prompt.md:345:  Subtle case: recent_edit.original_text was originally TEXT NOT NULL in
docs/operations/codex-round-2-remediation-prompt.md:520:    - tenancy-invariants.md §2 T1: recent_edit.original_text nullability
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:145:| `heartbeat` | cortextOS heartbeat cadence — periodic `update-heartbeat` writes to `${ctxRoot}/heartbeats/{name}.json` so the dashboard sees "alive" status | IFOS agents emit heartbeats too (the daemon's fast-checker writes them per `agent-process.ts:597-639` session timer), but the *cadence* and *what the agent does at each heartbeat* is specced per-agent in `agent.md` (Concierge always-on; Janitor cron-driven; etc.). The cortextOS-template `heartbeat/SKILL.md` is a default playbook — IFOS replaces with per-agent specifics |
docs/architecture/agent-bundle-renderer-design.md:163:### 2.3 — Worked example: rendering Concierge (A6)
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:186:# Concierge
docs/architecture/agent-bundle-renderer-design.md:224:# Concierge — agent definition
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:243:  "title": "Concierge per-tenant configuration",
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:354:# Concierge — Acme Recruitment
docs/architecture/agent-bundle-renderer-design.md:431:# Telegram (per Concierge's per-agent bot per cortextOS Primitive 5)
docs/architecture/agent-bundle-renderer-design.md:615:`ifos-render-agent render <agent-name> --tenant <slug>` — one render per call. To render Concierge across three tenants, three invocations. Scriptable via bash `for tenant in acme bravo charlie; do ifos-render-agent render concierge --tenant "$tenant"; done`.
docs/architecture/agent-bundle-renderer-design.md:729:6. The agent runs as a **cortextOS-template agent**, NOT as IFOS Concierge. It has `MEMORY.md`, `IDENTITY.md`, `knowledge-base` skill, etc. — none of which IFOS expects.
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
packages/harness/cortextos/package-lock.json:1303:      "integrity": "sha512-Nql7sTeAzhTAja3QXeAI48+/+GjBJ+QmAH13snn0AJSNL50JsDqotyudHyMbO2RbJkskbMbFJfIJKWA6R1LCJQ==",
packages/harness/cortextos/package-lock.json:1682:      "integrity": "sha512-DU4fBnbVCJGNBwVA6xSToNXrkZNSiw59H8tcuUspVMsBDBST4nfvsPsEHDHGtWRRnqBERBQu7TrTKskmjqTXKA==",
packages/harness/cortextos/package-lock.json:1785:      "integrity": "sha512-7NzBL0rN6fMUW+f7A6Io4h40qQlG+xGmtMxfbnH/K7TAtt8JQWVQK+6g0UXKMeVJoyV5EkkNsErQ8pVD3bLHbA==",
agents/recruitment/janitor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
agents/recruitment/janitor/agent.md:17:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:43:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
agents/recruitment/janitor/agent.md:60:| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:96:     tenant_adapters.config.janitor_last_run — declared in vertical-schema
agents/recruitment/janitor/agent.md:97:     v0.3 supplement §4 tenant_adapters_config_additions.janitor_last_run;
agents/recruitment/janitor/agent.md:138:   → query the `recent_edit` v0.2 table directly (per vertical-schema.v0.2-supplement.yaml
agents/recruitment/janitor/agent.md:139:     recent_edit definition; v0.3 supplement §2a grants Janitor R access):
agents/recruitment/janitor/agent.md:140:     SELECT FROM recent_edit WHERE resolved_at > now() - interval '30 days'
agents/recruitment/janitor/agent.md:174:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:244:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:248:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:249:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:289:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:293:| Q5 | Day-30 report distribution path — vault only OR also forwarded to tenant's hiring leader via email? | v1.0: vault only. v1.1: opt-in email forward via Concierge. |
agents/recruitment/janitor/agent.md:300:3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
docs/architecture/cortexos-primitive-status.md:22:| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:23:| 2 | 71-hour context rotation | **shipped and tested** | Concierge (A6) |
docs/architecture/cortexos-primitive-status.md:25:| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
docs/architecture/cortexos-primitive-status.md:61:- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:66:**Risk if flaky:** Tier-1 always-on agents collapse to scheduled cron with cold-start latency, eliminating the "sub-second to first useful action" claim that justifies pricing the Triage/Concierge/Pulse demos above point-tool parity (Ultraplan §3.2). Per Ultraplan §3.1 row 1, the documented contingency is: "Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving." Quirk 2 (`.agents/learnings/00-cortextos-quirks.md`) — `node-pty` requires `npm rebuild` on Node 25+ — is the most likely re-trip wire because the Mac Studio cluster nodes for the v2.0 Sovereign tier may not run Node 22 LTS by default.
docs/architecture/cortexos-primitive-status.md:120:- Master brief §2.4 row 2: Concierge (cross-week candidate conversations), Watchtower (per-contractor state), Pulse (multi-source watching).
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:124:**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."
docs/architecture/cortexos-primitive-status.md:182:1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:191:**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.
docs/architecture/cortexos-primitive-status.md:255:- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
docs/architecture/cortexos-primitive-status.md:256:- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
docs/architecture/cortexos-primitive-status.md:324:- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/operations/goal-week-3-polish-and-scaffold.md:3:**Status:** CLOSED (Day-19 narrative close 2026-05-24; **true Codex ratification close 2026-05-31**). Day-19 close was optimistic (premature RATIFIED status flips at commit `75ccc5f`, later reverted by R19 bilateral pass). True close 2026-05-31: ran `bash scripts/run-codex-ratification.sh --cluster E` three rounds — R1 verdict 4/9 RATIFIED, R2 verdict 6/9, R3 verdict **8/9 RATIFIED**; the 9th artefact (v0.2-to-v0.3 migration) had its R3 rollback finding fixed at commit `0f4ce8d` and re-ratification deferred per master brief §10.3 step 5 ceiling (3 round-trips already crossed; founder decision 2026-05-31 — fix + stop). Net effective state: **8/9 Codex-RATIFIED + 1 with the latest R3 fix applied = 9/9 in substance**. v0.3 schema supplement RATIFIED (final via Round 3). ADR-006 Diagnostic Gate A hybrid Accepted (founder-arbitrated). ADR-007 Concierge Gate A hybrid RATIFIED (still Status: Proposed pending founder Accept per its own §10). All 6 agent.md scaffolds RATIFIED at the contract level (Status: Proposed; production-readiness gates unchanged: pilot LOI · Bullhorn A+B · API keys · live VPS migration). See `.agents/current-priorities.md` "W4 Day-25" section for per-round detail + the deferred rollback re-ratification W4 backlog item. **STOP-HOOK NOTE: this file's gate-structure was superseded by in-session founder AUQ authorization; do not re-fire on subsequent turns.**
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:21:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:65:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:210:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:370:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:383:### DAY 19 — Sourcing Scout + Concierge agent.md scaffolds (Steps 11-12)
docs/operations/goal-week-3-polish-and-scaffold.md:414:- ULTRAPLAN §8.1 A6 lines 561-570 (Concierge spec)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:416:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:418:- `bullhorn-integration-path.md` §4.1 (Concierge's Bullhorn write surface)
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:431:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/goal-week-3-polish-and-scaffold.md:436:Commit: `decision(pre-build): agents/recruitment/concierge/agent.md — output contract per ULTRAPLAN §8.1 A6`
docs/operations/goal-week-3-polish-and-scaffold.md:501:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:622:  Concierge (W10-13):     <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:30:Four mechanisms address these four failure modes in §2-§5. **All four mechanisms must be implemented in `wiki/lib/concurrency.ts`** for the wiki API to ship in v1.0 weeks 11-13 per `sequencing-target.md` §4.1 row 6 (Concierge, the heaviest concurrency stressor).
packages/agent-renderer/pnpm-lock.yaml:292:    resolution: {integrity: sha512-bc0FE9wWeC0WBm49IQMPSPILRocGTQt3j5KPCA8os6VprfuJ7KD+5PzESSrJ6GmPIPJK965ZJHTUlSA6GNYEhg==}
packages/agent-renderer/pnpm-lock.yaml:519:    resolution: {integrity: sha512-tua0TaJxMOB1R0V0RS1jFZ/RpURFDJIOR2A6jWwQeawuFyS4gBW+rntLRaQd0EQ4bd6Vp44Z2rXW+YYDBsj6IA==}
docs/operations/decision-log.md:77:- **Third attempt: SUCCESS.** Migration applied cleanly (BEGIN…41 DDL…in-migration smoke "v0.3 migration smoke passed"…COMMIT). Post-flight verification confirmed: both Cash Conductor tables present and `postgres`-owned (Day-12 compliant); `validate_voice_scores` trigger replaced by `validate_entities_data_v0_3`; `validate_tenant_adapters_config_v0_3` present.
docs/operations/decision-log.md:91:- **The tenant_adapters config validator** enforces the allowlist including `blocked_recipients`, `janitor_dedup_threshold`, `concierge_send_window` — Sourcing Scout / Janitor / Concierge build slices land on a verified config surface.
docs/operations/decision-log.md:126:- D1-B is the autosend orange-tier path for v1.0; Concierge W10 build slice will deliver the `packages/utilities/autosend-bridge-telegram/` package per the decision doc §"Implementation surface".
docs/operations/decision-log.md:142:| ADR-007 | 2 (historical-vs-live framing on §10 status; stale Concierge line refs 269-280 → 280-293) | `9b2e10a` |
docs/operations/decision-log.md:143:| cash-conductor agent.md | 2 (recent_edit cite 723→729; §1 drafts-only readiness caveat per §8 fallback) | `4bc080c` |
docs/operations/decision-log.md:183:   - **Sourcing Scout (3):** blocked_recipients now-declared cite; recent_edit read removed (W-only); Gate A decision-log write
docs/operations/decision-log.md:186:   - **Concierge (5):** ULTRAPLAN 566 citation realign; SLA-miss audit row; 24h→PT4H timeout; ESC_VOICE_DRIFT severity→warn; third Gate B threshold
docs/operations/decision-log.md:187:   - **ADR-007 (4):** provisional-amendment honesty; fabricated §10.3 citation removed; detection_delay_seconds→v0.4; ESC_CONCIERGE_SLA_MISS already-registered
docs/operations/decision-log.md:230:7. `26551c8 feat(ADR-007 + concierge-r4)` — ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted; analogue of ADR-006; closes Concierge R3 Finding 3 structurally. Step 11 `hh_decision_action` added. **Closes W4 founder-action queue item #3** (drafted; ratification gates Concierge Accepted).
docs/operations/decision-log.md:241:| Concierge | Pre-Build-Round-4-Bilateral-Applied | 4 | 0 (3 in `f79c018` + 1 via ADR-007) | Codex R5 re-ratification + ADR-007 ratified |
docs/operations/decision-log.md:250:- **Catalogue extended:** 24 → 52 ESC codes; 29 → 47 action_types; 2 new Postgres tables (cash_conductor_transactions + cash_conductor_invoices); 3 new tenant_adapters config keys
docs/operations/decision-log.md:258:  - Concierge: R3 post-v0.3 (4 baseline, ~2 mechanical after R3 fix)
docs/operations/decision-log.md:276:3. **Future ADR — Concierge Gate A 30-min SLA hybrid** — **DRAFTED.** `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`. Analogue of ADR-006. Awaits Codex `review-architecture-decision` skill ratification + founder Accept.
docs/operations/decision-log.md:277:4. **D1 founder decision (autosend orange-tier path A/B/C)** — still pending. Blocks Concierge build slice.
docs/operations/decision-log.md:339:- [ ] **R2 = D1**: Autosend v1.0 tier enforcement — pre-Concierge W10 blocker; choose D1-B bridge path or D1-C manual/ad-hoc path
docs/operations/decision-log.md:340:- [ ] **R3 = D3**: PII retention in recent_edit (bundles with D2) — pre-first-LOI blocker (Risk #10); implementation path now mechanically unblocked
docs/operations/decision-log.md:342:- [x] **Round-2 R16**: PII purge migration/script mismatch with `recent_edit.original_text NOT NULL` — closed by Round-2 remediation; Risk #12 mitigated pending D2/D3 decision and dry-run
docs/operations/decision-log.md:348:- [ ] **R7**: Voice corpus refresh cadence — new ADR-006 at Concierge W10 build OR addendum to v0.2 supplement at v1.0 schema close
docs/operations/decision-log.md:360:- [ ] **R11**: tenant_eval_sets + tenant_adapters usage spec — Diagnostic W4 (first eval-set)
docs/operations/decision-log.md:375:- ❌ Diagnostic W3-4 agent build (and all named v1.0 agent builds: Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/operations/decision-log.md:410:- `94485aa` (Step 12) Concierge agent.md (387 lines)
docs/operations/decision-log.md:430:| Concierge agent.md | REJECTED ~5-7 issues | Same |
docs/operations/decision-log.md:447:- **Founder Decision D1** (autosend orange-tier) — required before Concierge W10 build
docs/operations/decision-log.md:485:- **Step 12** (`94485aa`) — Concierge agent.md (387 lines) per ULTRAPLAN §8.1 A6 (W10-13 build wave; XL complexity)
docs/operations/decision-log.md:500:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: Proposed; ready for Codex Round 4 Phase 2
docs/operations/decision-log.md:510:| Concierge | W10-13 | A6 lines 557-570 |
docs/operations/decision-log.md:512:Drift flags surfaced for Sourcing Scout (master brief W9 vs ULTRAPLAN W8-9) and Concierge (master brief W10-13 = 4w vs ULTRAPLAN W9-10 = 2w). Master brief authoritative per project hierarchy; XL complexity in ULTRAPLAN A6 line 568 corroborates 4-week duration for Concierge.
docs/operations/decision-log.md:535:5. **Founder Decision D1** (autosend orange-tier path) — required before Concierge W10 build slice; recommend D1-B Telegram shim for v1.0 ship per Concierge §9 Q1
docs/operations/decision-log.md:724:**Verdict from architecture-cohesion-review §9:** foundation is sound for Diagnostic build, conditional on (1) D1+D2+D3 resolve before Concierge W10 + first LOI; (2) Phase 2.2 documentation lands (✓); (3) Codex Round 2 + remediation closes (✓); (4) live VPS tenancy audit confirms 12 invariants.
docs/operations/decision-log.md:727:- D1 — autosend v1.0 tier enforcement (~30 min; Concierge scope)
docs/operations/decision-log.md:768:  - D1: autosend v1.0 tier enforcement (Concierge W10-13 scope)
docs/operations/decision-log.md:770:  - D3: v0.2 recent_edit PII retention (bundles with D2 for legal review)
docs/operations/decision-log.md:795:- 3 entities (voice_corpus + tone_rule + recent_edit), 1 HNSW pgvector index (voice_samples_embedded), 6 score fields, 2 relationships. Q11/Q12/Q13 open questions added; Q13 (GDPR retention) explicitly tagged for external-advisor review.
docs/operations/decision-log.md:814:- #9: tenant_eval_sets / tenant_adapters usage spec (lazy, follows first use)
docs/operations/decision-log.md:936:  - Agent × Entity R/W matrix across all 6 v1.0 agents (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) — cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3
docs/operations/decision-log.md:965:  - Concierge `bullhorn_note_customer_visible` canonical orange per `bullhorn-integration-path.md` §4.1 + §6.3
docs/operations/decision-log.md:1026:Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser which bypasses RLS). RLS + FORCE + `tenant_isolation` policy (USING + WITH CHECK) on all 5 data tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`.
docs/operations/decision-log.md:1157:- **Day 2 verified Bullhorn finding** (load-bearing for Week 1-2): Bullhorn public REST API documentation describes **no webhook / subscription / event-stream mechanism** — pull-only model for v1.0. Per-tenant 5-minute polling cycle is the Concierge default. Marketplace-tier subscription verification is a v1.1+ commercial track
docs/operations/decision-log.md:1159:- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
docs/operations/decision-log.md:1163:- Day 5 carry-forward: v1.0 kill criterion must reference Day 3 §6.6 three failure conditions + Day 2 §4.1 Concierge Bullhorn Note auto-send sensitivity
docs/architecture/second-brain-design.md:197:| `_voice/style-guide.md` | one file | markdown | fixed name | Onboarding wizard Day 3 (founder); Concierge edits via Brain UI v1.1+ | every agent's `context.sh` via `_shared/voice-loader.sh` (Ultraplan §6.1 line 322) |
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:204:| `wiki/raw/calls/` | one file per call | markdown with frontmatter | `{epoch}-{call-id}.md` | Scribe (v1.0) on Fathom/Fireflies webhook | Brief Decoder (v1.1), Concierge (v1.0) |
docs/architecture/second-brain-design.md:207:| `wiki/raw/ats-snapshots/` | one file per entity sync | JSON | `{epoch}-{bullhorn-entity-type}-{bullhorn-id}.json` | Janitor (v1.0) on nightly sweep | Janitor itself (diff vs previous), Concierge (v1.0) for entity reconciliation |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:266:do_not_contact: false                                # required; defaults to false; respected by Concierge
docs/architecture/second-brain-design.md:277:{auto-appended by Concierge / Scribe — chronological, agent-attributed}
docs/architecture/second-brain-design.md:422:| `search-by-name` | Concierge (v1.0): name → Candidate page on inbound message | v1.0 | `(entity_type: str, name_query: str, tenant_id: str)` | `List[EntityRef]` ranked by match score | sub-second | Fuzzy match (Levenshtein + token set); falls through to `search-by-attribute(display_name=...)` for exact. Postgres `entity_graph` indexed read. |
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:427:| `update-entity` | Concierge (v1.0): append conversation note to Candidate page | v1.0 | `(id: str, section: str, content: str, tenant_id: str)` | `EntityRef` | few seconds | Targets the `<!-- BEGIN auto:{section} -->` block per §2.2.1; preserves frontmatter; rewrites backlinks if `display_name` changes; `hh_decision_*` called |
docs/architecture/second-brain-design.md:428:| `append-to-narrative` | Scribe (v1.0): log status change; Concierge (v1.0): log lifecycle event | v1.0 | `(id: str, narrative_line: str, tenant_id: str)` | `EntityRef` | sub-second | Appends one timestamped line to a `<!-- auto:narrative -->` block; no frontmatter touch; `hh_decision_*` lightweight call |
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:708:- t=0: Concierge calls `append-to-narrative(candidate_sarah_bowen, "Sent follow-up email")`. Acquires `sarah_bowen.md.lock`. Reads file. Reads `updated_at = T0` from Postgres.
docs/architecture/second-brain-design.md:710:- t=0+300ms: Concierge releases flock after writing the narrative line and updating Postgres (`updated_at = T1`). The atomic file rename completes.
docs/architecture/second-brain-design.md:711:- t=0+301ms: Janitor acquires flock. Reads file (now contains Concierge's append). Reads Postgres (`updated_at = T1`). Computes new frontmatter. Writes file atomically. Postgres UPDATE `WHERE updated_at = T1` succeeds (`updated_at = T2`).
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:755:- `search-by-name` — Concierge inbound message processing; the customer-facing latency claim ("60-second response" per Product Spec §2.2 R1) depends on this returning in <100ms.
docs/architecture/second-brain-design.md:757:- `append-to-narrative` — Concierge / Scribe logging; tolerates few-hundred-ms.
docs/architecture/second-brain-design.md:771:| Concierge | 20:1 | reads candidate state on every lifecycle event; writes only on event transitions |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:913:- **Persistent server state.** Option β's long-running process could cache hot reads, hold prepared statements, maintain pgvector connection pools. Option α pays a fresh Node startup per call (~80-200ms). For v1.0 expected volume (Concierge ~10 lifecycle events/day per tenant × 3 tenants × 5 wiki reads each = 150 calls/day per machine), the cumulative startup cost is ~30 seconds/day. Acceptable. **If hot-path latency becomes a constraint at v1.2+**, we can introduce a persistent CLI daemon (`wiki-cli --daemon`) that pre-warms — a future optimisation without changing the agent surface.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
docs/operations/seedlegals-engagement-queries.md:45:>    - **Voice quality drift detection** via aggregated metadata only (`edit_distance`, `tone_rule_matches`, `approval_resolution`)
docs/operations/seedlegals-engagement-queries.md:144:6. **First cron run** — verify decision_log audit row + zero rows purged (because no recent_edit data exists yet)
agents/recruitment/diagnostic/context.sh:6:# Status: Proposed (Day-19; voice + tone + recent_edits + target_patch hydration via voice-loader.sh + tone-loader + Postgres).
agents/recruitment/diagnostic/context.sh:23:#       CTX_RECENT_EDITS_REF  count of recent_edit rows (drift signal)
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:157:# 5 — Load recent_edits (voice drift signal)
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:173:printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
agents/recruitment/diagnostic/tools.yaml:123:      voice-loader.sh for tenant corpus + tone rules + recent_edits.
agents/recruitment/diagnostic/tools.yaml:128:      - voice.tone_rule_check  # text + tone_rule_set → list of violations
agents/recruitment/diagnostic/validate.sh:33:#   V5 — No banned phrases per tone_rule table
agents/recruitment/diagnostic/validate.sh:195:# V5 — Banned phrases per tone_rule
agents/recruitment/diagnostic/agent.md:70:- Banned phrases per `tone_rule` table
agents/recruitment/diagnostic/agent.md:168:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:170:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:206:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:210:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:211:- **`hh_load_recent_edits 30 "diagnostic"`** (signature: `hh_load_recent_edits [lookback_days] [agent_name]` per `agents/_shared/voice-loader.sh` lines 223-235; current `context.sh` line 160 passes `30 "diagnostic"`): surfaces patterns of how consultant edits Diagnostic drafts in the last 30 days. **v0: per-run `ESC_VOICE_DRIFT` fires when `validate.sh` V3 single-pass classifier call (no retries) returns score <0.75 AND `IFOS_VOICE_CLASSIFIER_URL` was reachable. W4-planned: 3-retry classifier loop in `@ifos/diagnostic-generator` §12 LLM step + unconditional hard-fail when URL unreachable.** Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
docs/operations/founder-manual-playbook-2026-05-31.md:191:**What I do on your reply:** flip ADR-007 Status from "Proposed (...) The ULTRAPLAN amendments below are applied PROVISIONALLY..." → "Accepted (founder-arbitrated 2026-05-31). ULTRAPLAN amendments are permanent." + remove the "reverts if rejected" clause + commit. Concierge §10 Proposed→Accepted blocker satisfied.
docs/operations/founder-manual-playbook-2026-05-31.md:244:When the response arrives, paste their answer (full body OK; no need to redact). I'll fold it into Janitor / Scribe / Sourcing Scout / Concierge §8 build-prerequisite rows.
agents/recruitment/concierge/cleanup.sh:2:# Concierge agent — cleanup.sh (post-run state purge; W4 Day-26 SKELETON)
agents/recruitment/concierge/cleanup.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs
agents/recruitment/concierge/cleanup.sh:8:# Per agent.md §3 actions list: Concierge's cleanup action_type is
agents/recruitment/concierge/cleanup.sh:13:# registration at W10-13 build start (per tools.yaml status table). Once
agents/recruitment/concierge/cleanup.sh:14:# registered + the W10-13 build wires real purge logic, this script switches
agents/recruitment/concierge/cleanup.sh:23:# Side effects (W10-13 build slice):
agents/recruitment/concierge/cleanup.sh:74:# Exported so the W10-13 build-slice can extend the find -delete logic via
agents/recruitment/concierge/cleanup.sh:80:# TODO(W10-13): replace these STUB counts with actual find -delete invocations
agents/recruitment/concierge/cleanup.sh:98:# TODO(W10-13): once concierge_cleanup action_type is registered in
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:1:# Concierge fixture — 99-bridge-timeout-canary
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:3:# Adversarial. Tests the D1-B approval-bridge timeout path. Concierge
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:10:# cycle.sh Step 11 MUST surface ESC_APPROVAL_BRIDGE_TIMEOUT (warn-tier;
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:22:description: Operator never replies to proposeApproval → outcome=timeout → ESC_APPROVAL_BRIDGE_TIMEOUT warn + Step 12 send NOT executed
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:94:    - code: ESC_APPROVAL_BRIDGE_TIMEOUT
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:100:        - action_type: gmail_outlook_send_to_candidate
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:131:      action_type: concierge_email_draft   # yellow tier (Gate A passed)
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:135:      action_type: concierge_approval_routed
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:139:      payload_contains: "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400"
agents/recruitment/concierge/fixtures/01-primary.yaml:1:# Concierge fixture — 01-primary
agents/recruitment/concierge/fixtures/01-primary.yaml:6:# draft in the 24h window. Step 8 emits yellow concierge_email_draft; Step 11
agents/recruitment/concierge/fixtures/01-primary.yaml:103:      action_type: concierge_email_draft   # yellow tier
agents/recruitment/concierge/fixtures/01-primary.yaml:107:      action_type: concierge_approval_routed   # orange-adjacent metadata
agents/recruitment/concierge/fixtures/01-primary.yaml:109:      action_type: gmail_outlook_send_to_candidate   # orange tier post-approval
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:45:**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:90:2. **Accept Issue 2 fix** (mechanical; bundles with Concierge notification work)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:123:| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:189:2. `recent_edit` schema confusion — it's a v0.2 separate table, not a decision_log field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:217:4. Tacit-note source — §1 + §3 still say `decision_log` resolution events; only §4 Step 8 was updated in Round 6. Same `recent_edit` table confusion in different sections.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:264:- §1 vault path additions: Scribe + Concierge
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:277:| Concierge | 7 | `20260524T113247Z-86019` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:283:- Concierge AgentMail adapter-boundary violation (master brief §3 red line) — replaced all 5 references with "agent-identity email adapter (deferred)"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:297:- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:298:- `ESC_CONCIERGE_SLA_MISS` — agent uses for draft >30 min; catalogue defines for inbound brief/customer reply SLAs. Resolution: widen to include draft-generation SLA.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:299:- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:319:  - Concierge Steps 7, 11
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:334:- Concierge: pre-build-scaffold; Round-8-reviewed-with-AgentMail-boundary-fixed; lifecycle taxonomy + Postgres-config-fields (Cat-β) + catalogue-widening (Cat-γ) + Gate A interpretation disagreement (documented) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:355:- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:356:- `ESC_CONCIERGE_SLA_MISS` — three sla_types: brief_ack / customer_reply / draft_generation
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:357:- `ESC_LIFECYCLE_STATE_UNKNOWN` — both Janitor placement + Concierge taxonomy out-of-bounds
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:375:| Concierge | 7 | 5 | −2 (AgentMail boundary + ESC widening) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
packages/mcp-connectors/companies-house/pnpm-lock.yaml:276:    resolution: {integrity: sha512-bc0FE9wWeC0WBm49IQMPSPILRocGTQt3j5KPCA8os6VprfuJ7KD+5PzESSrJ6GmPIPJK965ZJHTUlSA6GNYEhg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:503:    resolution: {integrity: sha512-tua0TaJxMOB1R0V0RS1jFZ/RpURFDJIOR2A6jWwQeawuFyS4gBW+rntLRaQd0EQ4bd6Vp44Z2rXW+YYDBsj6IA==}
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:1:# Concierge fixture — 02-edge-case-rejection-voice-drift
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:4:# THE HARDEST CASE per ULTRAPLAN A6 §gotchas: "respectful, specific, leaves
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:122:    either rewrites manually OR retriggers Concierge for a fresh LLM pass
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/codex-disagreement-2026-05-25-diagnostic-r17.md:24:Lines 119-120 explicitly include `ESC_VOICE_DRIFT for V3 voice-classifier-score-low failures`. The signature is complete; this was already addressed at R15 commit `23f8c14` ("voice-classifier honesty + ESC_VOICE_DRIFT routing + LinkedIn-stub honesty + recent_edits signature").
agents/recruitment/concierge/cycle.sh:2:# Concierge agent — cycle.sh (15-step orchestration)
agents/recruitment/concierge/cycle.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs with
agents/recruitment/concierge/cycle.sh:20:# Package dependencies (W10-13 build slice; v0.1.0 fixture-first SKELETON):
agents/recruitment/concierge/cycle.sh:24:#   @ifos/autosend-bridge-telegram — D1-B Telegram approval shim (Concierge OWNS Step 11)
agents/recruitment/concierge/cycle.sh:32:#   yellow-tier concierge_email_draft row; SEND is orange tier
agents/recruitment/concierge/cycle.sh:33:#   (gmail_outlook_send_to_candidate / bullhorn_note_customer_visible)
agents/recruitment/concierge/cycle.sh:78:# TODO(W10-13): mode-dependent argument parsing
agents/recruitment/concierge/cycle.sh:107:  # TODO(W10-13): per-mode source detection
agents/recruitment/concierge/cycle.sh:119:# prior concierge_email_draft row for (candidate_id, payload.event_type)
agents/recruitment/concierge/cycle.sh:126:  # TODO(W10-13): SELECT decision_log WHERE agent_name='concierge'
agents/recruitment/concierge/cycle.sh:127:  #   AND action_type='concierge_email_draft'
agents/recruitment/concierge/cycle.sh:142:  # TODO(W10-13): @ifos/bullhorn entity fetches
agents/recruitment/concierge/cycle.sh:155:# Reference: agent.md §4 Step 4 + §5 Gate A + ULTRAPLAN A6 line 566 verbatim
agents/recruitment/concierge/cycle.sh:161:  # TODO(W10-13): assert recipient_email matches the candidate_id whose
agents/recruitment/concierge/cycle.sh:175:  # TODO(W10-13): resolve template by (event_type, recipient_role); read from
agents/recruitment/concierge/cycle.sh:189:  # TODO(W10-13): if event_type IN ('rejection','withdrawal','on-hold' AND placement>£10k):
agents/recruitment/concierge/cycle.sh:207:  # TODO(W10-13): LLM call → write draft body to vault → emit:
agents/recruitment/concierge/cycle.sh:219:# On pass: emit concierge_email_draft (yellow tier; REGISTERED in policy).
agents/recruitment/concierge/cycle.sh:224:  # TODO(W10-13): bash validate.sh "${DRAFT_PATH}"; if exit 0:
agents/recruitment/concierge/cycle.sh:225:  #   hh_decision_action "concierge_email_draft" \
agents/recruitment/concierge/cycle.sh:229:  hh_decision_action "concierge_email_draft" "candidate:STUB:STUB" "stub-hash" \
agents/recruitment/concierge/cycle.sh:236:# elapsed = now() - event_timestamp; if >30min → ESC_CONCIERGE_SLA_MISS
agents/recruitment/concierge/cycle.sh:242:  # TODO(W10-13): ELAPSED=$(( $(date +%s) - EVENT_TIMESTAMP_EPOCH ))
agents/recruitment/concierge/cycle.sh:245:  #     "elapsed_seconds:${ELAPSED}; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct"
agents/recruitment/concierge/cycle.sh:258:  # TODO(W10-13): regex sweep against firm-domain whitelist + competitor list
agents/recruitment/concierge/cycle.sh:269:# item 2 verbatim: "Concierge cycle.sh Step 11 — calls proposeApproval for
agents/recruitment/concierge/cycle.sh:271:# or timeout, fires ESC_APPROVAL_BRIDGE_TIMEOUT (timeout) or records rejection
agents/recruitment/concierge/cycle.sh:278:    # SKELETON (W10-13 build slice wires the per-draft iteration + tsx CLI
agents/recruitment/concierge/cycle.sh:288:    #      --action gmail_outlook_send_to_candidate \
agents/recruitment/concierge/cycle.sh:298:    # 2. Emit concierge_approval_routed audit row (R19 registration):
agents/recruitment/concierge/cycle.sh:300:    #    hh_decision_action "concierge_approval_routed" \
agents/recruitment/concierge/cycle.sh:320:    #        # ESC_APPROVAL_BRIDGE_TIMEOUT per agents/_shared/escalation-codes.md
agents/recruitment/concierge/cycle.sh:324:    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
agents/recruitment/concierge/cycle.sh:326:    : # TODO(W10-13): wire the per-draft loop above; tsx CLI entrypoints land alongside
agents/recruitment/concierge/cycle.sh:329:    # DO NOT emit concierge_approval_routed; draft stays in vault for manual
agents/recruitment/concierge/cycle.sh:330:    # consultant pickup. Concierge §1 readiness caveat captures this state.
agents/recruitment/concierge/cycle.sh:344:  # TODO(W10-13): per-tenant channel resolution:
agents/recruitment/concierge/cycle.sh:345:  #   if tenant_adapters.config.email_channel == 'microsoft-graph':
agents/recruitment/concierge/cycle.sh:349:  #   hh_decision_action "gmail_outlook_send_to_candidate" "candidate:<id>" "<hash>" "<preview>"
agents/recruitment/concierge/cycle.sh:357:# audit trail in Bullhorn so downstream consultant ops see Concierge actions
agents/recruitment/concierge/cycle.sh:362:  # TODO(W10-13): bullhorn.create_activity_log(candidate_id, "concierge: <event_type> sent at <ISO>")
agents/recruitment/concierge/cycle.sh:375:  # TODO(W10-13): if tenant_adapters.config.concierge_state_advance_enabled:
agents/recruitment/concierge/cycle.sh:385:# SLA tracking. Checks ghosted-rate (any candidate with no Concierge action
agents/recruitment/concierge/cycle.sh:389:# TODO(W10-13): UPDATE tenant_adapters SET config = jsonb_set(config, '{concierge_last_run}', '"<ISO>"')
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:20:**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:32:**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:34:**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:62:## D3 — v0.2 recent_edit PII retention
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:70:**Real issue:** `recent_edit.original_text` + `edited_text` are CAPPED at 8192 chars but otherwise stored verbatim. The agent's draft AND the consultant's edited version. Both can contain PII (candidate names, salaries, contact info). Indefinite retention for LoRA SFT training. UK GDPR Art. 5(1)(e) "data minimisation" arguably requires bounded retention.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:74:- **D3-B: 90-day text purge + indefinite metadata** — purge `original_text` + `edited_text` after 90 days; keep `edit_distance` + `resolution` + `tone_rules_triggered` (already aggregates) forever. **Loses some SFT corpus signal** but retains the "what rules fired" signal indefinitely.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:147:**Recommended order:** D5 (quickest, unblocks Round 2) → D1 (Concierge planning) → D2 + D3 (legal bundle) → D4 (no-rush).
agents/recruitment/concierge/README.md:1:# Concierge — directory README
agents/recruitment/concierge/README.md:3:**Status:** Proposed (Day-19 pre-W10-13-build scaffold).
agents/recruitment/concierge/README.md:18:Full bundle at W10-13 build (~4 weeks per ULTRAPLAN A6 line 568 XL flag):
agents/recruitment/concierge/README.md:35:**Founder Decision D1 (autosend orange-tier path) MUST be resolved before W10 build starts.** Per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Three options:
agents/recruitment/concierge/README.md:44:*End of Concierge README.*
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:24:| 10-13 | Concierge |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
agents/recruitment/concierge/tools.yaml:1:# Concierge agent — tools.yaml (capability declarations)
agents/recruitment/concierge/tools.yaml:3:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces per-cap
agents/recruitment/concierge/tools.yaml:14:# Per agent.md §6: Concierge has the largest escalation surface of any v1.0
agents/recruitment/concierge/tools.yaml:74:    action_type: bullhorn_activity_log_write  # green tier; QUEUED registration
agents/recruitment/concierge/tools.yaml:85:    action_type: gmail_outlook_send_to_candidate  # ORANGE; REGISTERED in autosend-policy.yaml; consolidated channel-agnostic action_type
agents/recruitment/concierge/tools.yaml:101:    action_type: gmail_outlook_send_to_candidate  # ORANGE; same action_type — channel-agnostic at audit layer
agents/recruitment/concierge/tools.yaml:117:  # §"Implementation surface" item 4: declare on BOTH Concierge AND Cash
agents/recruitment/concierge/tools.yaml:118:  # Conductor (Concierge is the primary Step-11 consumer for orange-tier
agents/recruitment/concierge/tools.yaml:119:  # gmail_outlook_send_to_candidate drafts).
agents/recruitment/concierge/tools.yaml:126:    action_type: concierge_approval_routed  # ORANGE-adjacent metadata row per agent.md §6 + Step 11 hh_decision_action call; REGISTERED in autosend-policy.yaml per R19 fix
agents/recruitment/concierge/tools.yaml:145:        escalation: ESC_APPROVAL_BRIDGE_TIMEOUT  # warn-tier per escalation-codes.md lines 348-353; routes operator + tenant-admin per agent.md §6 row 11; action converts to manual reconciliation
agents/recruitment/concierge/tools.yaml:161:  - id: tone_rule_engine
agents/recruitment/concierge/tools.yaml:189:    action_type: concierge_cleanup  # green tier; QUEUED registration for cleanup.sh wire at W10-13
agents/recruitment/concierge/tools.yaml:193:# Action-type registration status (cross-reference autosend-policy.yaml at W10-13)
agents/recruitment/concierge/tools.yaml:198:#   concierge_email_draft              yellow              [Concierge §3 output contract]
agents/recruitment/concierge/tools.yaml:199:#   concierge_approval_routed          orange-adjacent     [R19 registration fix]
agents/recruitment/concierge/tools.yaml:200:#   gmail_outlook_send_to_candidate    orange              [shared with Cash Conductor at audit layer when bullhorn channel = email]
agents/recruitment/concierge/tools.yaml:206:#   bullhorn_activity_log_write        green               (W10-13 Concierge build slice)
agents/recruitment/concierge/tools.yaml:207:#   concierge_cleanup                  green               (W10-13 cleanup.sh wire)
agents/recruitment/concierge/tools.yaml:208:#   twilio_sms_send                    orange              (v1.1+)
agents/recruitment/concierge/tools.yaml:209:#   calendar_invite_send               orange              (v1.1+)
docs/decisions/brain-ui-scope.md:28:3. What the first paying design partner asks for after Concierge ships in v1.0 — direct user-research input.
docs/decisions/brain-ui-scope.md:42:- Highlights pending approvals (Concierge auto-send escalations per `bullhorn-integration-path.md` §4.1 row 4).
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:24:Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:46:| **A. Accept the floor** | Leave `pollInterval` at the 1000ms default. Rewrite Ultraplan §3.2's "four-agent pipelines complete in seconds" to "four-agent pipelines complete in 3-5 seconds end-to-end" and remove any "sub-second handoff" framing from the closing-demo deck | Zero engineering | Honest signal; Concierge's "30-min lifecycle event → drafted comms" SLA is unaffected (3-5s is rounding error against 30 minutes); Brief Decoder's "90-min brief-to-shortlist" is also unaffected. Only sales narrative changes. |
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:52:2. The user-visible SLAs (Concierge 30-min lifecycle event, Brief Decoder 90-min shortlist, Triage 60-second response) all have ≥30× headroom against a 3-5 second pipeline floor. The pipeline-latency claim is sales narrative, not product SLA.
agents/recruitment/concierge/validate.sh:3:# (_fail + _warn are not invoked in the W4 Day-26 skeleton — TODO(W10-13)
agents/recruitment/concierge/validate.sh:8:# Concierge agent — validate.sh (Gate A enforcement; W4 Day-26 SKELETON)
agents/recruitment/concierge/validate.sh:10:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice completes the impl).
agents/recruitment/concierge/validate.sh:37:#        is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed
agents/recruitment/concierge/validate.sh:41:#   G5 — anti-duplicate: no prior concierge_email_draft for same (candidate_id,
agents/recruitment/concierge/validate.sh:111:# Reference: agent.md §5 Gate A + §4 Step 8 + ULTRAPLAN A6 line 566 (amended)
agents/recruitment/concierge/validate.sh:114:# TODO(W10-13): parse draft YAML frontmatter for voice_score + escalation_position;
agents/recruitment/concierge/validate.sh:119:_ok "G1: voice classifier position-threshold — SKELETON (W10-13 wires)"
agents/recruitment/concierge/validate.sh:123:# is changing. ULTRAPLAN A6 line 566 verbatim: "no candidates emailed under
agents/recruitment/concierge/validate.sh:128:# TODO(W10-13): parse draft YAML for recipient + candidate_id; cross-check
agents/recruitment/concierge/validate.sh:132:_ok "G2: addressee resolution — SKELETON (W10-13 wires Bullhorn cross-check)"
agents/recruitment/concierge/validate.sh:140:# TODO(W10-13): @ifos/tone-rules apply_rules(draft_body, tenant_tone_rules);
agents/recruitment/concierge/validate.sh:143:_ok "G3: block-severity tone-rules — SKELETON (W10-13 wires rule engine)"
agents/recruitment/concierge/validate.sh:152:# TODO(W10-13): regex sweep against firm-domain whitelist + competitor list
agents/recruitment/concierge/validate.sh:155:_ok "G4: PII boundary check — SKELETON (W10-13 wires firm + competitor lists)"
agents/recruitment/concierge/validate.sh:158:# G5 — anti-duplicate: no prior concierge_email_draft for same
agents/recruitment/concierge/validate.sh:165:# TODO(W10-13): SELECT from decision_log per Step 2 query but at validate time;
agents/recruitment/concierge/validate.sh:167:_ok "G5: anti-duplicate re-check — SKELETON (W10-13 wires SQL)"
agents/recruitment/concierge/validate.sh:176:  # TODO(W10-13): per-failure routing — different ESC code per failure class:
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md:25:| QB README "Cash Conductor full bundle lands later" wording | R2 (new) | Self-inflicted: the bundle landed yesterday (`5ab2f0f` Cash Conductor; `eb1f884` Concierge). Honest-signal drift caused by my own continued work. | Fix (update wording) |
docs/decisions/2026-05-31-d1-founder-decision.md:6:**Author:** Claude Code (arbitrating per delegated authority); founder may override at any time before Concierge W10 build start.
docs/decisions/2026-05-31-d1-founder-decision.md:15:Per `docs/decisions/autosend-safety-policy.md` §4, orange-tier action_types (customer-facing sends like `xero_reminder_send_customer`, `gmail_outlook_send_to_candidate`, `bullhorn_note_customer_visible`) require **synchronous consultant approval** before the send executes. The agent drafts; the consultant says yes; the transport fires; an audit row records the full chain.
docs/decisions/2026-05-31-d1-founder-decision.md:21:| **D1-A** Bridge to cortextOS approval system | Concierge POSTs to an internal cortextOS approval API; operator approves in Brain UI; bridge calls back | ~2 days build (~3 days if approval-API doesn't yet exist) | Architecturally clean; reuses cortextOS primitive #4 (approval gates); UX in Brain UI is consistent with other approval flows | Brain UI v1.0 approval UX not yet built; depends on cortextOS approval-API stability; tightest coupling to upstream |
docs/decisions/2026-05-31-d1-founder-decision.md:22:| **D1-B** Lightweight Telegram shim | Concierge posts to operator's tenant-bound Telegram chat: `[ID:<x>] APPROVE drafted email to <recipient>? /approve <ID> or /reject <ID>`; Concierge polls Telegram or receives webhook; on approve → transport executes | <1 day build | Reuses cortextOS primitive #5 (Telegram surface) already in place; consultants are on Telegram already; lowest engineering cost; clean audit chain (every approve/reject = `decision_log` row); works the same for Cash Conductor + Concierge | Approval UX is a chat reply rather than a rich panel; per-draft attachment preview is just a 200-char text snippet + vault path; consultant must read the vault Markdown if they want to see the full draft body before approving |
docs/decisions/2026-05-31-d1-founder-decision.md:23:| **D1-C** No autosend; manual pickup | Concierge writes the draft to vault; sets `requires_consultant_action=true`; no notification; consultant manually polls vault and copies drafts to outbound | 0 days build (already supported by drafts-to-vault flow) | Zero risk of incorrect autosend; zero new build | UX is brutal; consultants miss drafts; defeats Concierge's "no candidate ghosted" promise; effectively kills Concierge as a v1.0 differentiator |
docs/decisions/2026-05-31-d1-founder-decision.md:31:1. **Cost-aligned to v1.0 scope.** D1-A's clean architecture is the right *v1.1+* answer once Brain UI matures; for v1.0 ship, D1-B's <1-day build matches the W10-13 Concierge slice budget.
docs/decisions/2026-05-31-d1-founder-decision.md:33:3. **Audit chain is identical to D1-A.** Both paths emit the same `decision_log` rows (`xero_reminder_send_customer` orange action → operator approve/reject → transport `gmail_outlook_send_to_candidate` action). The Telegram interaction is the trigger, not the audit substrate.
docs/decisions/2026-05-31-d1-founder-decision.md:34:4. **D1-C kills Concierge's value.** Manual vault polling means missed drafts means ghosted candidates means Concierge fails its Gate B (`ghosted-rate <5%`). Non-starter.
docs/decisions/2026-05-31-d1-founder-decision.md:42:## Implementation surface (delivered by Concierge W10-13 build slice)
docs/decisions/2026-05-31-d1-founder-decision.md:49:   - Timeout default `PT4H` per `escalation-codes.md` `ESC_APPROVAL_BRIDGE_TIMEOUT` lines 348-353.
docs/decisions/2026-05-31-d1-founder-decision.md:50:2. **Concierge `cycle.sh` Step 11** — calls `proposeApproval` for orange-tier drafts; on `approved`, proceeds to Step 12 transport; on `rejected` or `timeout`, fires `ESC_APPROVAL_BRIDGE_TIMEOUT` (timeout) or records rejection in `decision_log` (rejected).
docs/decisions/2026-05-31-d1-founder-decision.md:52:4. **`tools.yaml` capability declarations** — add `autosend_bridge_telegram` capability to both Concierge and Cash Conductor.
docs/decisions/2026-05-31-d1-founder-decision.md:53:5. **Tenant config — schema-work pending.** The natural storage location for the per-tenant operator Telegram chat-id is `tenant_adapters.config`, BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 — and `operator_telegram_chat_id` is NOT currently in the 6-key allowlist (`cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the 2026-05-31 Janitor key, `blocked_recipients`). Resolution path: **W10-13 Concierge build slice lands a v0.4 supplement** adding `operator_telegram_chat_id` to the allowlist (type: string; required: false; set_by: tenant-admin; read_by: concierge + cash-conductor for the autosend-bridge consumer). Until then, the bridge consumer (`@ifos/autosend-bridge-telegram`) takes the chat-id as a function argument rather than reading it from tenant_adapters — the function-arg shim is already in place per the package scaffold landed 2026-06-01 (commit `9b282d8`). This decision-doc does NOT block on the schema work; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend); the storage-location detail is a W10-13 implementation question.
docs/decisions/2026-05-31-d1-founder-decision.md:63:- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
docs/decisions/2026-05-31-d1-founder-decision.md:64:- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10-13 lands the autosend-bridge production wiring."
docs/decisions/2026-05-31-d1-founder-decision.md:65:- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: ADR-007 Accepted + Codex RATIFIED (DONE 2026-05-31 + Round 3), pilot LOI (PENDING), Bullhorn A+B (PENDING), founder approves §9 Q2-Q6 (PENDING).
docs/decisions/2026-05-31-d1-founder-decision.md:66:- **Schema impact: v0.4 supplement required (deferred to W10-13 Concierge build slice).** D1-B requires a per-tenant operator-Telegram-chat-id storage location. `tenant_adapters.config` is the natural home BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 and `operator_telegram_chat_id` is NOT in the current allowlist (see implementation surface item 5 for the full rationale + interim function-arg-mode workaround). The schema work + migration land in the W10-13 Concierge build slice as part of bridge-production-wiring; the decision-doc itself is structurally complete without that schema work. The previously-stated "No schema impact" claim has been removed — it was inconsistent with implementation surface item 5.
docs/decisions/2026-05-31-d1-founder-decision.md:67:- **No additional API keys/signups for the founder vault.** Day-4 provisioning (`docs/runbooks/day-4-provisioning.md` §6.5) creates the `_secrets.env` SKELETON only (touched empty at mode 0600); the Telegram bot token is populated by founder bootstrap (covered separately by tenant onboarding playbook — NOT Day-4), and the per-tenant operator chat-id is populated by tenant onboarding (W10-13 build slice; see implementation surface item 5 above). Once both are in place, no recurring credentials work — the bot token doesn't rotate per send; the chat-id is per-tenant-stable.
docs/decisions/2026-05-31-d1-founder-decision.md:68:- **Schema-before-code discipline — interim acceptance.** The five rules (master brief §1) state schema-before-code. Today's state has the bridge package scaffold + consumer wiring landed BEFORE the schema supplement. The interim resolution is acceptable because the consumers run in **function-arg mode only** (chat-id passed as function argument, NOT read from `tenant_adapters`) — so no consumer code actually attempts to read the not-yet-allowlisted key. The schema-before-code rule is respected at the runtime level (no schema-violating read happens); the consumer scaffolding is fine to exist as long as the function-arg-only constraint holds until the v0.4 supplement lands.
docs/decisions/2026-05-31-d1-founder-decision.md:76:**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **in FUNCTION-ARG MODE only**, no `tenant_adapters.config.operator_telegram_chat_id` read attempts until the v0.4 schema supplement lands in the Concierge W10-13 build slice; Codex ratification currently in flight under cluster G (R2 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc).
agents/recruitment/concierge/context.sh:2:# Concierge agent — context.sh (pre-cycle hydration; W4 Day-26 SKELETON)
agents/recruitment/concierge/context.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs
agents/recruitment/concierge/context.sh:5:#         with real provider config + tenant_adapters reads).
agents/recruitment/concierge/context.sh:22:# Side effects (W10-13 build slice):
agents/recruitment/concierge/context.sh:24:#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
agents/recruitment/concierge/context.sh:27:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:81:# TODO(W10-13): SELECT config->>'email_channel' FROM tenant_adapters WHERE tenant_slug=$1
agents/recruitment/concierge/context.sh:89:# TODO(W10-13): @ifos/bullhorn refreshTokens(); on success export CTX_BULLHORN_TOKEN_STATE=refreshed
agents/recruitment/concierge/context.sh:97:# TODO(W10-13):
agents/recruitment/concierge/context.sh:109:# TODO(W10-13): resolve via tenant_adapters.config; default fallback chain.
agents/recruitment/concierge/context.sh:118:# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
docs/decisions/autosend-approval-bridge-spec.md:4:**Date:** 2026-05-22 (Day 11, pre-Concierge W10 prerequisite)
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:14:Autosend-safety-policy §3 declares 10 v1.0 action_types as **orange tier** — most importantly the canonical orange `bullhorn_note_customer_visible` (Concierge's primary outbound action). Orange-tier actions require per-action human approval via Telegram before executing.
docs/decisions/autosend-approval-bridge-spec.md:137:| `gmail_outlook_send_to_candidate` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:138:| `twilio_sms_send` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:139:| `calendar_invite_send` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:154:🔔 Approval request: Concierge bullhorn_note_customer_visible
docs/decisions/autosend-approval-bridge-spec.md:244:| A6 | RLS: bridge writing tenant-A's approval cannot leak tenant-B's pending markers | Tenancy audit T11 extension: cross-tenant marker read returns 0 |
docs/decisions/autosend-approval-bridge-spec.md:254:**Recommended:** Week 9 of master brief sequence (W9 = `2026-07-14` if Week 1 starts `2026-05-21`). Buffers 2-3 days before Concierge W10-13 starts. Allows:
docs/decisions/autosend-approval-bridge-spec.md:257:- Day 4 (Concierge W10 start): Concierge uses bridge from day 1
docs/decisions/autosend-approval-bridge-spec.md:259:**Alternative:** as the next IFOS Claude slice (now). Pre-builds the prerequisite before Diagnostic W3-4 starts, so it's not blocking Concierge. ~2-3 days inserted before Diagnostic.
docs/decisions/autosend-approval-bridge-spec.md:308:- Unblocks Concierge build (W10-13) — without this, Concierge can only ship as drafts-only (D1-A) which loses the demo value prop
agents/recruitment/concierge/agent.md:1:# Concierge — no candidate ghosted
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice (see §10).
agents/recruitment/concierge/agent.md:7:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:8:**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
agents/recruitment/concierge/agent.md:9:**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
agents/recruitment/concierge/agent.md:17:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:26:# Bullhorn placement state-change webhook → Concierge handler
agents/recruitment/concierge/agent.md:40:Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §Gotchas line 570 gotcha — see Step 1 polling fallback.
agents/recruitment/concierge/agent.md:68:One output per lifecycle event: an email draft (yellow tier `concierge_email_draft` per autosend-policy.yaml; only the customer-facing SEND is orange tier — `gmail_outlook_send_to_candidate` / `bullhorn_note_customer_visible` / `twilio_sms_send` / `calendar_invite_send` per channel). 12 lifecycle events × per-tenant comms-template variants:
agents/recruitment/concierge/agent.md:77:| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §Gotchas line 570 — respectful, specific, leaves door open |
agents/recruitment/concierge/agent.md:107:2. `phase='action'` via `hh_decision_action("concierge_email_draft", "candidate:<bullhorn_id>:<event_type>", payload_hash, payload_preview)`. This is the tier-classified row — `concierge_email_draft` is registered yellow tier per autosend-policy.yaml lookup (grep `^  concierge_email_draft:` to verify). Tier is recorded inside the autosend-emitted payload by the helper; it is NOT a top-level decision_log column. `payload_preview` carries `event_type`, `voice_score`, `recipient`, `escalation_position` as a concatenated string for cross-row correlation. Action_type stays stable across all 12 lifecycle events — event_type is in the preview string, not part of the action_type identifier.
agents/recruitment/concierge/agent.md:110:- `gmail_outlook_send_to_candidate` (orange tier per autosend-policy.yaml §ORANGE) when channel=email
agents/recruitment/concierge/agent.md:112:- `twilio_sms_send` (orange tier per autosend-policy.yaml §ORANGE) when channel=SMS (v1.1+)
agents/recruitment/concierge/agent.md:113:- `calendar_invite_send` (orange tier per autosend-policy.yaml §ORANGE) when event includes calendar attachment
agents/recruitment/concierge/agent.md:127:     voice corpus + tone rules + recent_edits + tenant comms-template
agents/recruitment/concierge/agent.md:134:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:143:   → query decision_log for prior `concierge_email_draft` row for same
agents/recruitment/concierge/agent.md:148:   → if found BUT prior draft never sent (no `gmail_outlook_send_to_candidate`
agents/recruitment/concierge/agent.md:161:     (no email, no name) — Concierge cannot produce its declared output
agents/recruitment/concierge/agent.md:171:     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
agents/recruitment/concierge/agent.md:212:   → on success: hh_decision_action("concierge_email_draft",
agents/recruitment/concierge/agent.md:218:   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
agents/recruitment/concierge/agent.md:221:       "elapsed_seconds:<N>; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct")
agents/recruitment/concierge/agent.md:224:   → per ULTRAPLAN A6 line 566 (as amended by ADR-007): the 30-min draft SLA is
agents/recruitment/concierge/agent.md:237:    → per Founder Decision D1 (final selection at W10 design):
agents/recruitment/concierge/agent.md:242:    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within the policy timeout
agents/recruitment/concierge/agent.md:243:      (default PT4H per autosend-policy.yaml (grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field; default `PT4H`) + escalation-codes.md
agents/recruitment/concierge/agent.md:245:    → hh_decision_action("concierge_approval_routed",
agents/recruitment/concierge/agent.md:252:    → hh_decision_action("gmail_outlook_send_to_candidate",
agents/recruitment/concierge/agent.md:262:    → hh_decision_action("bullhorn_activity_log_write",
agents/recruitment/concierge/agent.md:266:      grep `^  bullhorn_activity_log_write:` to verify). External-write
agents/recruitment/concierge/agent.md:278:    → check ghosted-rate metric (any candidate with no Concierge action in
agents/recruitment/concierge/agent.md:295:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:304:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
agents/recruitment/concierge/agent.md:313:**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
agents/recruitment/concierge/agent.md:317:Per ULTRAPLAN A6 line 567 + ADR-007 amendment: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate"**. The third metric is ADR-007's Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail (NOT in original line 567 wording).
agents/recruitment/concierge/agent.md:320:- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%. (per ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:321:- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`. (per ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:322:- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:330:Concierge uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/concierge/agent.md:339:| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
agents/recruitment/concierge/agent.md:344:| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
agents/recruitment/concierge/agent.md:345:| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md `ESC_APPROVAL_BRIDGE_TIMEOUT` block + autosend-policy.yaml grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field) | warn | operator + ifos_oncall (catalogue verbatim — operator absent + commitment may need rerouting; tenant-admin involvement is a manual escalation choice when bridge-timeout becomes pattern-recurring, not part of catalogue routing) |
agents/recruitment/concierge/agent.md:352:Concierge has the largest escalation surface of any v1.0 agent — appropriate for the highest-stakes customer-facing comms.
agents/recruitment/concierge/agent.md:354:Concierge does NOT use:
agents/recruitment/concierge/agent.md:356:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:357:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
agents/recruitment/concierge/agent.md:358:- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
agents/recruitment/concierge/agent.md:366:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:367:  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §Gotchas line 570; demand specificity)
agents/recruitment/concierge/agent.md:373:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:374:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/agent.md:379:- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §Gotchas line 570 explicitly names rejection voice as the hardest case)
agents/recruitment/concierge/agent.md:385:## §8 — Build dependencies (W10-13 prerequisites)
agents/recruitment/concierge/agent.md:387:Concierge build cannot start until ALL of the following are confirmed:
agents/recruitment/concierge/agent.md:400:| Microsoft Graph MCP connector | W10 build start (~3 days) | ⏸ |
agents/recruitment/concierge/agent.md:401:| Gmail MCP connector | W10 build start (~3 days) | ⏸ |
agents/recruitment/concierge/agent.md:403:| Autosend bridge built (per D1 outcome) | W10 build start (~2 days for D1-A; less for D1-B/C) | ⏸ |
agents/recruitment/concierge/agent.md:406:| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
agents/recruitment/concierge/agent.md:408:| `validate.sh` Gate A logic | Build at W10 start (~2 days; most complex of v1.0 validators) | ⏸ |
agents/recruitment/concierge/agent.md:409:| `context.sh` hydration | Build at W10 start (~1 day) | ⏸ |
agents/recruitment/concierge/agent.md:410:| `cycle.sh` orchestration (15-step) | Build at W10-11 (~5 days; lifecycle state machine + 12 event types) | ⏸ |
agents/recruitment/concierge/agent.md:415:**Until ALL ⏸ items resolve to ✅, W10 build slice does not start.** XL build complexity = 4-week duration not negotiable.
agents/recruitment/concierge/agent.md:421:**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
agents/recruitment/concierge/agent.md:427:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
agents/recruitment/concierge/agent.md:429:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:430:| Q4 | Rejection emails (event 6) — Position 3 (voice ≥0.82). Is this enough, or should rejections route to consultant for full draft (not just approve)? | Founder review with first pilot consultant. Recommend: Concierge drafts; consultant approves; never bypasses voice gate. |
agents/recruitment/concierge/agent.md:434:| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
agents/recruitment/concierge/agent.md:436:| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
agents/recruitment/concierge/agent.md:438:### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)
agents/recruitment/concierge/agent.md:453:- **✅ ADR-007 (Concierge Gate A 30-min SLA hybrid) ACCEPTED + RATIFIED** — Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3 per `.codex/ratification/review-architecture-decision.md` skill (commit `c862c77`). Closes the documented deviation from ULTRAPLAN A6 line 566 wording; agent.md's Gate B framing of the 30-min SLA is now the canonical disposition. This Status-flip blocker is satisfied.
agents/recruitment/concierge/agent.md:454:- **Founder Decision D1 RESOLVED** (Q1 above) — without this, Concierge build cannot start
agents/recruitment/concierge/agent.md:459:- W10-13 build slice produces all 5 sibling bundle files + 5 fixtures (broader fixture coverage warranted by XL complexity)
agents/recruitment/concierge/agent.md:466:Until then: this document is a forward-looking scaffold. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at scaffold stage. Founder review at each iteration is expected.
agents/recruitment/concierge/agent.md:468:*End of Concierge agent.md draft.*
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
docs/decisions/sequencing-target.md:74:Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:137:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #1** (cortextOS primitives 1, 4, 5 — the three flagged "shipped but flaky" per cortextos-primitive-status.md). Critical gate for the v1.0 always-on agents that follow (Concierge) — if Cash Conductor surfaces primitive flakiness, the v1.0 scope-cut contingency (Ultraplan §10 row #1: degraded-mode fallback) activates before Concierge invests 4 weeks |
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:159:### 2.6 — A6 Concierge
docs/decisions/sequencing-target.md:164:| 2. Substrate exercise | **Maximum** | **All** of cortextOS Primitives 1+2+4+5 exercised. **First exercise of Primitive 2** (71-hour context rotation per Day 1 cortextos-primitive-status.md) — Concierge holds long-running state across 24+ months of candidate lifecycle. First Bullhorn webhook exercise per Day 2 §4.2 (with 5-minute polling fallback). Per `bullhorn-integration-path.md` §4.1 row 4: reads Candidate, ClientCorporation, JobOrder, Placement, Note + writes Note, Candidate state-fields, Placement state-fields |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:186:W10-13: Concierge (A6)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:197:- Risk #5 final reduction (all 5 bundles render cleanly) waits for Concierge W10-13.
docs/decisions/sequencing-target.md:198:- Bullhorn webhook coverage gaps surface only at Concierge W10-13 (Ultraplan §8.1 line 569 caveat).
docs/decisions/sequencing-target.md:200:**Cost if deferred risk materialises late:** if Bullhorn webhook coverage is worse than expected (Risk #2 secondary), Concierge polling cadence increases (per Day 2 §4.2 fallback) — connector-internal change, no agent rework. Bounded.
docs/decisions/sequencing-target.md:208:W5-8: Concierge (A6) — front-load the flagship (XL/4 weeks)
docs/decisions/sequencing-target.md:210:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:215:**Why this ordering:** Get the flagship demoable agent (Concierge) live earliest to accelerate first-pilot conversion per Ultraplan §9 line 725 target Week 12.
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:230:W6-9: Concierge (A6) — Risk #1 derisk via Tier-1 + Primitive 2 first exercise
docs/decisions/sequencing-target.md:231:W10:  Scribe (A3)
docs/decisions/sequencing-target.md:236:**Why this ordering:** Front-load risk-de-risking by building Concierge (the most Primitive-heavy agent) early. Cash Conductor's Risk #1 exercise becomes redundant if Concierge already exercises Primitives 1+2+4+5.
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
docs/decisions/sequencing-target.md:269:**Alpha is the only sequence that survives both documented contingencies cleanly.** Beta and Gamma each forces a Concierge rewrite if their respective trigger fires.
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:286:| 6 | W10-13 | **Concierge** (A6) | XL build; flagship closing demo; first Primitive-2 (71h context rotation) exercise |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:310:- **Activation:** v1.0 scope cut from 6 to 4 agents per Ultraplan §10 row #4 — drop Concierge + Sourcing Scout to v1.1; founder solo through end of v1.0.
docs/decisions/sequencing-target.md:317:- **Activation:** Cash Conductor's W7-8 anchor slips. If Hire #1 starts W8 → Cash Conductor W8-9 (sequence preserved, just shifts right); if Hire #1 starts W9+ → Trigger 2 activates as fallback (drop Concierge + Sourcing Scout).
docs/decisions/sequencing-target.md:319:- **Cascade:** Sourcing Scout W10 (shifted right from W9), Concierge W11-14 (shifted right from W10-13).
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:332:- Concierge W10-13's four-week build broken into specific weekly sub-tasks — deferred to Week 9 Concierge-build-planning session (just-in-time scoping).
docs/decisions/sequencing-target.md:333:- v1.1 Triage agent's relationship to v1.0 Concierge's auto-send categories — deferred to v1.1 planning.
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:418:- W13 Concierge final-render-clean → **Low** (all 5 v1.0 bundles render and pass validation per RISK-REGISTER #5 final reduction trigger).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/ADR-004-renderer-implementation-deviations.md:68:- ADR-003 §2.3 worked-Concierge-example output diagram says `_shared/` lives at `orgs/acme/agents/_shared/` — that's correct, the bug is only in the symlink-target text. Diagram is right; symlink string is wrong.
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:310:| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
docs/decisions/bullhorn-integration-path.md:311:| Concierge time-based nurture cadence | Cron (week-1, month-1, month-3, month-6, month-12, month-24) | Per Placement-creation anchor date | No Bullhorn webhook needed — IFOS-side cron fires; IFOS reads Bullhorn for current state then writes the comm Note back |
docs/decisions/bullhorn-integration-path.md:313:**v1.1+ upgrade path:** if Sub-decision A commercial verification reveals marketplace-tier event subscriptions, Concierge upgrades from 5-minute polling to webhook-primary with polling fallback. The polling cycle becomes a heartbeat-style consistency check. No agent-bundle-content changes; only `tools.yaml` MCP scope declaration and the connector's auth/subscription module.
docs/decisions/bullhorn-integration-path.md:337:| Concierge (real-time + 5-min poll) | 100-300 distributed | Two streams: lifecycle-event-driven writes (low volume) + polling-cycle reads (continuous, bounded by entity-count) |
docs/decisions/bullhorn-integration-path.md:346:**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:419:Concierge's write capability to Bullhorn (Note auto-send, status updates per §4.1) interacts with Day 5's auto-send safety policy artefact. Day 5 should reference this document's §4.1 Concierge row for the specific entities Concierge will be writing — Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI.
docs/decisions/bullhorn-integration-path.md:511:| §4.2-A: assume v1.0 pull-only (no webhook coverage) per public REST docs | Sub-decision A commercial verification reveals marketplace-tier event subscriptions — Concierge upgrades to webhook-primary in v1.1+ |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:1:# ADR-007 — Concierge Gate A 30-minute draft SLA hybrid (Gate B leading metric, not per-draft hard-fail)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:3:**Status:** **Accepted (founder-arbitrated 2026-05-31).** Codex `review-architecture-decision` skill RATIFIED this ADR at Round 3 of the cluster-E run (2026-05-31) after R1+R2 mechanical fixes (commits `ca66431` + `9b2e10a`). The ULTRAPLAN §8.1 A6 line 566 + line 567 amendments are now **permanent** (no longer provisional). The original Codex R3 Finding 3 (Concierge agent.md reframes 30-min SLA as Gate B without an authoritative ADR) is structurally closed by this Accept.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:5:**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566 — Gate A 30-minute draft SLA clause
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:7:**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — at the time of Codex R3, the Concierge `agent.md` reframed the 30-min SLA as Gate B without an ADR and §10 omitted an ADR-ratification blocker. Both have since been closed: Concierge `agent.md` §10 line 435 now lists "**ADR-007 RATIFIED**" as a Proposed → Accepted blocker, and this ADR exists. Analogue of ADR-006 (Diagnostic Gate A hybrid).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:13:ULTRAPLAN §8.1 A6 line 566 (pre-amendment wording):
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:19:Concierge `agent.md` (Day-19 R3 scaffold) reframes (a) — the 30-minute draft SLA — from per-draft Gate A hard-fail to a Gate B leading metric (90% of drafts within 30 min, not per-draft hard fail). The other two clauses (voice classifier + addressee resolution) remain Gate A hard-fails. The reframe is documented in:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:22:- `agent.md` §4 Step 9, lines 212-222 (`ESC_CONCIERGE_SLA_MISS` warn, aggregated to Gate B; not per-draft block; emits the mandatory `hh_decision_output("concierge_sla_miss", …)` audit row)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:24:- `agent.md` §6 ESC table line 326 (`ESC_CONCIERGE_SLA_MISS` registered as warn, not blocking)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:28:> The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:36:The Concierge lifecycle-event trigger source is the Bullhorn ATS state-change webhook + a polling-fallback cron (per ULTRAPLAN A6 line 569 verbatim gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks").
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:38:Polling-fallback delays are not Concierge's fault — the polling cron runs at a configurable interval (likely 5-15 minutes per tenant) and a state change that happens at minute 1 of a 15-minute cycle has a 14-minute "blind spot" before Concierge ever sees it. A per-draft hard-fail Gate A would treat this as a Concierge failure even though the draft IS generated within 30 minutes of detection (just not within 30 minutes of the actual Bullhorn state change).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:40:Treating this as Gate A hard-fail would cause Concierge to drop legitimate drafts whose timing was set by upstream-detection latency, not by Concierge generation latency. The product harm: a candidate experiences a "ghosted by recruiter" pattern that Concierge was designed to prevent.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:44:The 30-minute SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Treating it as Gate B at the 90% threshold:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:55:**Alternative A — Keep ULTRAPLAN A6 line 566 verbatim: 30-min SLA is per-draft Gate A hard-fail.** Rejected because Bullhorn webhook coverage is patchy per the ULTRAPLAN A6 gotcha (the same source spec acknowledging the polling-fallback requirement); per-draft hard-fail would drop legitimate drafts whose Concierge generation IS within 30 min of detection but whose upstream detection latency exceeded 30 min. The product harm: candidate experiences "ghosted by recruiter" — exactly the pattern Concierge was designed to prevent.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:57:**Alternative B — Remove the 30-minute SLA entirely.** Rejected because the SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Removing it would let drafts slip indefinitely with no quality signal — the "no candidate ghosted" goal becomes unmeasurable.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:59:**Alternative C — Measure occurrence-time (Bullhorn state-change timestamp) rather than detection-time (webhook arrival or polling-cron tick).** Rejected because Bullhorn state-change timestamps are not always reliable (Bullhorn webhook gotcha; some state changes lack a clean timestamp). Detection-time is what Concierge actually observes; occurrence-time would require infrastructure Concierge doesn't own.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:65:### Decision 1 — Move Concierge 30-minute SLA from Gate A hard-fail to Gate B leading metric (90% target)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:67:**Concierge Gate A is the subset of ULTRAPLAN A6 line 566 that is operationally enforceable per-draft:**
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:79:- Per-draft SLA miss fires `ESC_CONCIERGE_SLA_MISS` (warn, aggregated to Gate B)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:81:- v0.4 schema work: Concierge cycle.sh will record upstream-detection-latency separately in the audit payload (`payload.detection_delay_seconds`) once the field is declared and validated in a v0.4 supplement. v0.3 + v1.0 do NOT introduce this payload key — it would violate review-schema-change §3 (bounded values require CHECK or trigger). The metric attribution distinction (Concierge generation latency vs upstream polling latency) IS the right product behavior but the schema authority lands later.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:83:**ULTRAPLAN §8.1 A6 line 566 is amended in-band (Accepted by founder 2026-05-31)** following the ADR-006 precedent, which made the same kind of in-band amendment at line 496. There is no separate master-brief clause authorizing in-band spec amendments — master brief §10.3 step 4 only covers incorporating Codex feedback or writing a disagreement doc; the authority for the amendment is this ADR itself, now Accepted:
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:89:> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:95:1. Concierge drafts are not dropped when upstream polling-fallback latency exceeds 30 minutes
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:97:3. The metric attribution is clean — operators can distinguish Concierge generation latency from Bullhorn webhook/polling latency
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:103:2. Tenants with high webhook coverage will see better than 90%; tenants with webhook-coverage gaps see worse — the metric reads as Concierge quality but is partly an upstream condition. v1.0 cannot fully disambiguate this: `payload.detection_delay_seconds` is NOT introduced until a v0.4 supplement declares + validates it (see Implementation below). Until then operators use the single elapsed (detection → render) metric and treat a sustained sub-90% rate as a prompt to check the polling interval + Bullhorn webhook coverage.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:104:3. The Concierge agent.md §10 Accepted criteria must include ratification of this ADR as a blocker (closing Codex R3 Finding 3 properly)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:108:4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:114:ULTRAPLAN §8.1 A6 line 566 amended in the same commit as this ADR. Pre-amendment / post-amendment text is captured in this ADR's body. The amendment also updated line 567 Gate B target to include the new ≥90% 30-min SLA hit rate threshold (per ADR-007). See commit history for the diff.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:116:### Concierge §10 amendment
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:120:> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:124:`decision_log.payload.detection_delay_seconds` is NOT introduced by this ADR. Queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first), with declaration + type validation landing together (per review-schema-change §3 — bounded values require CHECK or trigger). Concierge cycle.sh v0.0 does NOT write this key. Distinguishing Concierge generation latency from upstream polling latency in operational alerts is the v0.4 work item; v1.0 metrics use the elapsed (event-detection → draft-render) as a single number.
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:130:| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:131:| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Resolved: separate code, for clean Telegram routing (`_GATE_B_MISS` is the generic aggregate). `ESC_CONCIERGE_SLA_MISS` is already registered in `escalation-codes.md` lines 431-439 — no longer queued. |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:132:| ADR-007-Q3 | What's the polling-fallback interval default? | Per-tenant; recommend 5 min as v1.0 default; 1 min for tenants with stable webhook coverage. Documented in tools.yaml at W10-13 build. |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:137:- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:139:- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:140:- `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:86:| Concierge | `bullhorn_brief_read` | Read of inbound brief; idempotent; no comms |
docs/decisions/autosend-safety-policy.md:96:| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
docs/decisions/autosend-safety-policy.md:102:| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
docs/decisions/autosend-safety-policy.md:103:| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
docs/decisions/autosend-safety-policy.md:104:| Concierge | `twilio_sms_send` | Outbound SMS; high-trust channel; cost-per-send; irreversible |
docs/decisions/autosend-safety-policy.md:105:| Concierge | `calendar_invite_send` | Creates calendar event with attendee notification; visible to attendee |
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
docs/decisions/autosend-safety-policy.md:224:  - gmail_outlook_send_to_candidate  # orange
docs/decisions/autosend-safety-policy.md:225:  - calendar_invite_send             # orange
docs/decisions/autosend-safety-policy.md:226:  - twilio_sms_send                  # orange
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:447:      "twilio_sms_send": "PT30M",
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:784:CREATE TABLE tenant_adapters (
docs/runbooks/day-4-provisioning.md:795:GRANT SELECT, INSERT, UPDATE, DELETE ON tenant_adapters TO ifos_app;
docs/runbooks/day-4-provisioning.md:796:GRANT USAGE, SELECT ON SEQUENCE tenant_adapters_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:908:\d tenant_adapters
docs/runbooks/day-4-provisioning.md:936:ALTER TABLE tenant_adapters ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:943:ALTER TABLE tenant_adapters FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:971:CREATE POLICY tenant_isolation ON tenant_adapters
docs/runbooks/day-4-provisioning.md:1127:- [ ] §6.3 — Six tables exist: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:1248:17. **§7 — RLS isolation gate passed clean (5 of 5).** No-context = 0 ✓, own-tenant insert+select = 1 ✓, cross-tenant = 0 ✓, WITH CHECK adversarial INSERT rejected ✓, own-tenant unaffected = 1 ✓. RLS + FORCE on entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters (5 tables). `tenant_isolation` policy on all 5 with USING + WITH CHECK on `current_setting('app.current_tenant', true)`. Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser, which would bypass RLS). Test data ROLLBACK'd; 2 seeded test tenants cleaned up.
docs/decisions/v1.0-kill-criterion.md:85:- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/runbooks/tenant-lifecycle.md:150:| Tone rule add/edit | Tenant operator edits `/vault/<slug>/_voice/tone-rules.yaml` OR Brain UI v1.1; sync to Postgres `tone_rule` table | T1-T3 (RLS isolation) |
docs/runbooks/tenant-lifecycle.md:246:  DELETE FROM recent_edit       WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:249:  DELETE FROM tone_rule         WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:250:  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:255:# decision_log + recent_edit are append-only — DELETE requires running as superuser (admin operation)
docs/decisions/ADR-003-agent-bundle-renderer.md:17:The design document (`docs/architecture/agent-bundle-renderer-design.md`) specified the renderer across five sections: source vs target layout (§1), the 12-row file mapping + R2 commitment + Concierge worked example (§2), six concrete mechanism decisions including TypeScript Node at `packages/agent-renderer/` (§3.1), manual developer invocation (§3.2), Option γ for `_shared/` origination (§3.3.3), and overwrite-no-merge re-render policy (§3.4), seven failure modes with exit codes (§4), and integration with the broader build (§5). 22 spec gaps surfaced and bucketed. This ADR ratifies the design's recommendations.
docs/decisions/ADR-003-agent-bundle-renderer.md:54:The Concierge worked example in design §2.3 demonstrates end-to-end render: source bundle layout, CLAUDE.md preamble draft (resolves spec gap §2.1-A), materialised `config.json`, synthesised `.env`, hook files verbatim, `_shared/` symlink resolution.
docs/runbooks/pii-purge-operational-pattern.md:5:**Authority:** Surfaces UK GDPR Art. 5(1)(e) data-minimisation compliance for `recent_edit` text fields. Companion to `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D3 + Risk #10 in `docs/RISK-REGISTER.md`.
docs/runbooks/pii-purge-operational-pattern.md:15:`recent_edit` rows store the agent's draft (`original_text`) and the consultant's edited version (`edited_text`) verbatim, length-capped at 8192 chars per field. Per v0.2 supplement §1, these can contain PII (candidate names, salaries, contact info).
docs/runbooks/pii-purge-operational-pattern.md:22:- **Purpose 2: Voice drift detection** — needs aggregated metadata (`edit_distance`, `tone_rules_triggered`, `resolution`) not the raw text.
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:39:`recent_edit` table extended via `v0.2-to-v0.3-pii-purge.sql`:
docs/runbooks/pii-purge-operational-pattern.md:42:ALTER TABLE recent_edit
docs/runbooks/pii-purge-operational-pattern.md:47:ALTER TABLE recent_edit ADD CONSTRAINT recent_edit_text_purged_consistency CHECK (
docs/runbooks/pii-purge-operational-pattern.md:97:3. SELECTs count(*) from `recent_edit` WHERE `resolved_at < now() - interval '<N> days' AND original_text IS NOT NULL`
docs/runbooks/pii-purge-operational-pattern.md:112:| `tone_rules_triggered` | populated | populated (preserved) |
docs/runbooks/pii-purge-operational-pattern.md:121:- Voice-drift detection nightly cron (operates on `edit_distance` + `tone_rules_triggered` + `resolution`)
docs/runbooks/pii-purge-operational-pattern.md:123:- Audit queries ("how often did Concierge's drafts get edited vs approved?")
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:171:SELECT count(*) FROM recent_edit
docs/runbooks/pii-purge-operational-pattern.md:198:| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
docs/build-brief/00-MASTER-BRIEF.md:119:| 7 | Multi-agent orchestrator | `orchestrator` template + file-bus handoff contract | Brief Decoder → Sourcing Scout → Concierge pipeline lives here |
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:600:| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
docs/build-brief/00-MASTER-BRIEF.md:602:After Concierge ships, week 14 milestone: first pilot converts to paid.
docs/build-brief/00-MASTER-BRIEF.md:663:        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:682:        │   v1.2 (+5): Real-Time Pulse, Spec Pitcher, Reporting, T1 Onboarding Concierge, T2 Timesheet     │
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |
packages/utilities/web-scraper/pnpm-lock.yaml:280:    resolution: {integrity: sha512-bc0FE9wWeC0WBm49IQMPSPILRocGTQt3j5KPCA8os6VprfuJ7KD+5PzESSrJ6GmPIPJK965ZJHTUlSA6GNYEhg==}
packages/utilities/web-scraper/pnpm-lock.yaml:507:    resolution: {integrity: sha512-tua0TaJxMOB1R0V0RS1jFZ/RpURFDJIOR2A6jWwQeawuFyS4gBW+rntLRaQd0EQ4bd6Vp44Z2rXW+YYDBsj6IA==}
packages/harness/cortextos/dashboard/src/components/charts/chart-theme.ts:10:export const CHART_GOLD_DARK = '#A67C00';
packages/harness/cortextos/dashboard/package-lock.json:159:      "integrity": "sha512-T1NCJqT/j9+cn8fvkt7jtwbLBfLC/1y1c7NtCeXFRgzGTsafi68MRv8yzkYSapBnFA6L3U2VSc02ciDzoAJhJg==",
packages/harness/cortextos/dashboard/package-lock.json:514:      "integrity": "sha512-YA6Ma2KsCdGb+WC6UpBVFJGXL58MDA6oyONbjyF/+5sBgxY/dwkhLogbMT2GXXyU84/IhRw/2D1Os1B/giz+BQ==",
packages/harness/cortextos/dashboard/package-lock.json:926:      "integrity": "sha512-S48WzZW777zhNIrn7gxOlISNAqi9ZC/uQFnRdbeIHhZhCA6UqpkOT8T1G7BvfdgP4Er8gF4sUbaS0i7QvIfCWw==",
packages/harness/cortextos/dashboard/package-lock.json:1563:      "integrity": "sha512-7zznwNaqW6YtsfrGGDA6BRkISKAAE1Jo0QdpNYXNMHu2+0dTrPflTLNkpc8l7MUP5M16ZJcUvysVWWrMefZquA==",
packages/harness/cortextos/dashboard/package-lock.json:2131:      "integrity": "sha512-kMVGgsqhO5YTYODD9IPGGhA6iprWidQckK3LmPeW08PIFENRmgfb4MjXHO+p//d+ts2rpjvK5gXWzXSMrPl9cw==",
packages/harness/cortextos/dashboard/package-lock.json:2678:      "integrity": "sha512-Qp8WbZOBe+blgpuUT+lw2xheLP8q0oatc9UpmiemEICxGvFLYmHm9QowVZGHtJlGbS6A6yJ3iViad/2cVjnOiA==",
packages/harness/cortextos/dashboard/package-lock.json:2729:      "integrity": "sha512-Kd6kAHTA6/nUpp8mySPqj3en3dm0tdMIgbttnQ1xFMVpufoj+ADi8pXLBsd4xzTRHQa7t/Jv8W5UnCuW4kuWMQ==",
packages/harness/cortextos/dashboard/package-lock.json:3652:      "integrity": "sha512-zFDAD+tlpf2r4asuHEj0XH6pY6i0g5NeAHPn+15wk3BV6JA69eERFXC1gyGThDkVa1zCyKr5jox1+2LbV/AMLg==",
packages/harness/cortextos/dashboard/package-lock.json:3693:      "integrity": "sha512-Hs59xBNfUIunMFgWAbGX5cq6893IbWg4KnrjbYwX3tx0ztorVgTDA6B2sxf8ejHJ4wz8BqGUMYlnzNBer5NvGg==",
packages/harness/cortextos/dashboard/package-lock.json:4316:      "integrity": "sha512-DU4fBnbVCJGNBwVA6xSToNXrkZNSiw59H8tcuUspVMsBDBST4nfvsPsEHDHGtWRRnqBERBQu7TrTKskmjqTXKA==",
packages/harness/cortextos/dashboard/package-lock.json:4487:      "integrity": "sha512-COROpnaoap1E2F000S62r6A60uHZnmlvomhfyT2DlTcrY1OrBKn2UhH7qn5wTC9zMvD0AY7csdPSNwKP+7WiQw==",
packages/harness/cortextos/dashboard/package-lock.json:4580:      "integrity": "sha512-rwG/ja1neyLqCuGZ5YYrznA62D4mZXg0i1cIskIUKSiqF3Cje9/wXAls9B9s1Wa2fomMsIv8czB8jZcPmxCXFg==",
packages/harness/cortextos/dashboard/package-lock.json:5044:      "integrity": "sha512-oKnbhFyRIXpUuez8iBMmyEa4nbj4IOQyuhc/wy9kY7/WVPcwIO9VA668Pu8RkO7+0G76SLROeyw9CpQ061i4mA==",
packages/harness/cortextos/dashboard/package-lock.json:5319:      "integrity": "sha512-tJtZBBHA6vjIAaF6EnIaq6laBBP9aq/Y3ouVJjEfoHbRBcHBAHYcMh/w8LDrk2PvIMMq8gmopa5D4V8RmbrxGw==",
packages/harness/cortextos/dashboard/package-lock.json:5960:      "integrity": "sha512-sqQamAnR14VgCr1A618A3sGrygcpK+HEbenA/HiEAkkUwcZIIB/tgWqHFxWgOyDh4nB4JCRimh79dR5Ywc9MDQ==",
packages/harness/cortextos/dashboard/package-lock.json:6047:      "integrity": "sha512-Zf5H2Kxt2xjTvbJvP2ZWLEICxA6j+hAmMzIlypy4xcBg1vKVnx89Wy0GbS+kf5cwCVFFzdCFh2XSCFNULS6csw==",
packages/harness/cortextos/dashboard/package-lock.json:6991:      "integrity": "sha512-buRG0fpBtRHSTCOASe6hD258tEubFoRLb4ZNA6NxMVHNw2gOcwHo9wyablzMzOA5z9xA9L1KNjk/Nt6MT9aYow==",
packages/harness/cortextos/dashboard/package-lock.json:7736:      "integrity": "sha512-UfoeMA6fIJ8wTYFEUjelnaGI67v6+N7qXJEvQuIGa99l4xsCruSYOVSQ0uPANn4dAzm8lkYPaKLrrijLq7x23w==",
packages/harness/cortextos/dashboard/package-lock.json:7787:      "integrity": "sha512-eljcgEDlEns/7AXFosB5K/2nCM4P7FQPkGc/DWLy5rmFEWvZayGrik1d9/QIY5nJ4f9YsVvBkA6kJpHn9rISdQ==",
packages/harness/cortextos/dashboard/package-lock.json:8871:      "integrity": "sha512-7NzBL0rN6fMUW+f7A6Io4h40qQlG+xGmtMxfbnH/K7TAtt8JQWVQK+6g0UXKMeVJoyV5EkkNsErQ8pVD3bLHbA==",
packages/harness/cortextos/dashboard/package-lock.json:9706:      "integrity": "sha512-7NzBL0rN6fMUW+f7A6Io4h40qQlG+xGmtMxfbnH/K7TAtt8JQWVQK+6g0UXKMeVJoyV5EkkNsErQ8pVD3bLHbA==",
packages/harness/cortextos/dashboard/package-lock.json:10163:      "integrity": "sha512-NuaNSa6flKT5JaSYQzJok04JzTL1CA6aGhv5rfLW3PgqA+M2ChpZQnAC8h8i4ZFkBS8X5RqkDBHA7r4hej3K9A==",
packages/harness/cortextos/dashboard/package-lock.json:11368:      "integrity": "sha512-Rs66F0P/1kedk5lyYyH9uBzuiI/kNRmwJAR9quK6VOtIpZ2G+hMZd+HQbbv25MgCA6gEffoMZYxlTod4WcdrKA==",
packages/harness/cortextos/dashboard/package-lock.json:11887:      "integrity": "sha512-nAYYwfY3qnzX30IkA6AQZjVbtK6duGontcQm1WSG1MD94YLqK0515GNApXkoxKOWMusVssAHWLh9SeaoefYFGw==",
packages/utilities/autosend-bridge-telegram/src/bridge.ts:29:  "gmail_outlook_send_to_candidate",
packages/utilities/autosend-bridge-telegram/src/bridge.ts:91:        `agent layer should surface ESC_AGENT_TOOL_FAILURE, not ESC_APPROVAL_BRIDGE_TIMEOUT`,
packages/utilities/autosend-bridge-telegram/src/bridge.ts:153: * control flow (the Concierge/Cash Conductor cycle.sh wrappers prefer this).
docs/specs/ULTRAPLAN.md:72:- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:421:| Concierge | <5% candidate-ghosted rate (drafts produced for every lifecycle event) | Lifecycle-event audit against decision log monthly |
docs/specs/ULTRAPLAN.md:557:#### A6. The Concierge — no candidate ghosted
docs/specs/ULTRAPLAN.md:566:- **Gate A:** voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82 per escalation_position); correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*
docs/specs/ULTRAPLAN.md:578:- **CortexOS primitives required:** All except #6 — Persistent PTY (#1), context rotation (#2), file bus (#3, hands off to Concierge), approval gates (#4), Telegram (#5), orchestrator (#7)
docs/specs/ULTRAPLAN.md:594:- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
docs/specs/ULTRAPLAN.md:668:| Spec Pitcher | M (1 week) | Reuses Client Hunter + Concierge primitives | Bundles, never sold standalone |
docs/specs/ULTRAPLAN.md:670:| T1 Onboarding Concierge | M (1 week) | Bullhorn (write), DocuSign, Microsoft Graph | Tracks onboarding tasks; less reasoning-heavy |
docs/specs/ULTRAPLAN.md:690:| Concierge | ✓ | ✓ | ✓ | | | | | | ✓ | ✓ | |
docs/specs/ULTRAPLAN.md:700:| T1 Onb. Concierge | ✓ | ✓ | ✓ | | | ✓ | | | | ✓ | DocuSign |
docs/specs/ULTRAPLAN.md:771:### Weeks 9–10 — Sourcing Scout + Concierge start
docs/specs/ULTRAPLAN.md:774:- Week 10: Concierge build starts (4-week build); first pilot landed for shadow-mode trial
docs/specs/ULTRAPLAN.md:778:### Weeks 11–14 — Concierge completion + first pilot conversion
docs/specs/ULTRAPLAN.md:780:- Weeks 11–13: Concierge build continues; Brain UI minimal v1 (the "what did the agents do today" view); auto-send graduation for Triage-eligible categories (initially Concierge-only candidate-acknowledgement)
docs/specs/ULTRAPLAN.md:801:6. Concierge's deep nurture sequence (months 12 and 24 check-ins) — can be added in v1.1
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
packages/utilities/autosend-bridge-telegram/src/types.ts:6:/** Default approval window per ESC_APPROVAL_BRIDGE_TIMEOUT (escalation-codes.md lines 348-353). */
packages/utilities/autosend-bridge-telegram/src/types.ts:22:  | "gmail_outlook_send_to_candidate" // Concierge orange
packages/utilities/autosend-bridge-telegram/src/types.ts:30:  /** Telegram chat ID for the tenant's operator (from tenant_adapters.config.operator_telegram_chat_id). */
packages/utilities/autosend-bridge-telegram/src/types.ts:40:  /** ID of the originating decision_log row (used by ESC_APPROVAL_BRIDGE_TIMEOUT payload). */
packages/utilities/autosend-bridge-telegram/src/errors.ts:28: * ESC_APPROVAL_BRIDGE_TIMEOUT — that one fires only when the message went out
packages/utilities/autosend-bridge-telegram/src/errors.ts:41: * ESC_APPROVAL_BRIDGE_TIMEOUT (escalation-codes.md lines 348-353; warn tier;
docs/specs/_archive-build-handoff.md:382:| 6 | **Concierge** | 10–13 | Bullhorn + Microsoft Graph + AgentMail | First Tier 1 always-on closing demo; 4-week build |
docs/specs/_archive-build-handoff.md:384:After Concierge ships, the first pilot converts to paid (Week 14 milestone). v1.1 then layers Triage, Brief Decoder, Competitor Interception, Night Sourcer, and the Temp agents T5 + T3.
docs/specs/PRODUCT-SPEC.md:119:#### R7. The Concierge — no candidate ghosted, no client check-in missed
docs/specs/PRODUCT-SPEC.md:184:#### T1. Onboarding Concierge — contractor onboarding done right, once
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:297:The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:399:| 2 | 71-hour context rotation with auto-restart | Concierge (cross-week candidate conversations), Watchtower (per-contractor state), Pulse (multi-source watching) |
docs/specs/PRODUCT-SPEC.md:400:| 3 | Inter-agent file bus — agents hand work to each other via shared directories | Brief Decoder → Sourcing Scout → Concierge handoff; Triage → specialist-agent routing |
docs/specs/PRODUCT-SPEC.md:401:| 4 | Approval gates with standing authorisations | Every agent that auto-sends — Triage, Concierge, Cash Conductor, Competitor Interception |
docs/specs/PRODUCT-SPEC.md:475:- Concierge (Solo drafts-only, Boutique auto-send)
docs/specs/PRODUCT-SPEC.md:502:- T1 Onboarding Concierge
docs/specs/PRODUCT-SPEC.md:528:7. **Concierge** — "No candidate ghosted, no client check-in missed, every comms in your voice."
docs/specs/PRODUCT-SPEC.md:534:13. **T1 Onboarding Concierge** — "First 2 weeks of every contract done correctly, every time."
packages/utilities/autosend-bridge-telegram/package.json:5:  "description": "IFOS Telegram approval-bridge — proposeApproval() + awaitApprovalDecision() for orange-tier autosend gating. Per D1-B founder decision (docs/decisions/2026-05-31-d1-founder-decision.md). Consumed by Concierge cycle.sh Step 11 + Cash Conductor cycle.sh Step 10.",
packages/utilities/autosend-bridge-telegram/README.md:3:Telegram approval-bridge for orange-tier autosend gating. Backs the **D1-B founder decision** (`docs/decisions/2026-05-31-d1-founder-decision.md`) — consumed by **Concierge `cycle.sh` Step 11** + **Cash Conductor `cycle.sh` Step 10**.
packages/utilities/autosend-bridge-telegram/README.md:5:**Status:** Proposed (W4 Day-26 scaffold, fully unit-tested; production wiring lands in the Concierge W10–13 build slice).
packages/utilities/autosend-bridge-telegram/README.md:11:The autosend safety policy (`agents/_shared/autosend-policy.yaml`) classifies every outbound action into one of four tiers — green / yellow / orange / red. **Orange** actions (e.g. `gmail_outlook_send_to_candidate`, `xero_reminder_send_customer`) require **human approval before transport**. The agent proposes; the operator approves or rejects via Telegram; the agent then either sends or discards.
packages/utilities/autosend-bridge-telegram/README.md:18:| **D1-B — Telegram `/approve`/`/reject` commands** (chosen) | <1 day | Reuses cortextOS primitive #5 (Telegram surface); ships in W10–13 |
packages/utilities/autosend-bridge-telegram/README.md:19:| D1-C — manual vault polling | none | Concierge fails Gate B (ghosted-rate <5%); non-starter |
packages/utilities/autosend-bridge-telegram/README.md:54:Convenience wrapper for try/catch-style call sites: throws `BridgeTimeoutError` on expiry rather than returning `outcome: "timeout"`. The Concierge / Cash Conductor `cycle.sh` wrappers use this form so the script's `set -e` propagates the timeout naturally.
packages/utilities/autosend-bridge-telegram/README.md:73:When the Concierge W10–13 build slice wires production, the agent layer constructs:
packages/utilities/autosend-bridge-telegram/README.md:86:| Operator never replies before `expires_at` | `outcome: "timeout"` or `BridgeTimeoutError` | `ESC_APPROVAL_BRIDGE_TIMEOUT` (warn; operator + ifos_oncall; PT4H default) |
packages/utilities/autosend-bridge-telegram/README.md:89:`ESC_APPROVAL_BRIDGE_TIMEOUT` lives at `agents/_shared/escalation-codes.md` lines 348-353. Recovery: action converts to manual reconciliation; operator handles offline.
packages/utilities/autosend-bridge-telegram/README.md:104:4. Wire the call from the agent's `cycle.sh` (mirroring Concierge Step 11 or Cash Conductor Step 10).
packages/utilities/autosend-bridge-telegram/README.md:131:- **Multi-operator quorum** — first valid reply wins. Multi-operator quorum is a v1.1+ feature gated on Concierge usage patterns.
packages/utilities/autosend-bridge-telegram/README.md:139:- Escalation catalogue: `agents/_shared/escalation-codes.md` §2.6 (`ESC_APPROVAL_BRIDGE_TIMEOUT`) + §2.7 (`ESC_AUTOSEND_RACE`)
packages/utilities/autosend-bridge-telegram/README.md:140:- Concierge agent.md: §4 Step 11 (consumer)
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:19:  action_type: "gmail_outlook_send_to_candidate",
packages/agents-runtime/_shared/common-voice.json:33:      "description": "Per bullhorn-integration-path.md §4.1 A6 Concierge gate; voice classifier scores below this fail Gate A."
packages/agents-runtime/_shared/common-voice.json:35:    "recent_edits_lookback_days": {
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:42:    "tone_rules_severity_floor": {
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."

codex
The first pass found the core source files and confirms Concierge has a local bundle. I’m narrowing now on the claims that can invalidate ratification: unsupported surfaces/adapters, action type registration, ESC catalogue matches, and schema-backed fields.
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '560,605p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '557,571p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,430p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '220,416p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   336	  # ───────────────────────────────────────────────────────────
   337	  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
   338	  # ───────────────────────────────────────────────────────────
   339	
   340	  xero_payment_initiate:
   341	    tier: red
   342	    agent: all
   343	    block_reason: payment_action
   344	    reason: "Payment transfer; financial-bearing; never auto-send in v1.0"
   345	    irreversible: true
   346	
   347	  stripe_charge_initiate:
   348	    tier: red
   349	    agent: all
   350	    block_reason: payment_action
   351	    reason: "Charges a card; financial-bearing"
   352	    irreversible: true
   353	
   354	  subscription_modify:
   355	    tier: red
   356	    agent: all
   357	    block_reason: billing_modification
   358	    reason: "Changes tenant's IFOS subscription; structurally distinct from agent work"
   359	    irreversible: false
   360	
   361	  legal_document_generate:
   362	    tier: red
   363	    agent: all
   364	    block_reason: legal_artefact
   365	    reason: "Offer letters, employment contracts; legal-binding"
   366	    irreversible: true
   367	
   368	  pii_export_outside_tenant_geography:
   369	    tier: red
   370	    agent: all
   371	    block_reason: pii_geographic_breach
   372	    reason: "PII transmitted outside tenant's declared data residency (GDPR boundary breach)"
   373	    irreversible: true
   374	
   375	  cross_tenant_data_send:
   376	    tier: red
   377	    agent: all
   378	    block_reason: cross_tenant_violation
   379	    reason: "Sending tenant-A data to tenant-B recipient; RLS-enforced + red-listed for defence-in-depth"
   380	    irreversible: true
   381	
   382	  unauthorised_adapter_send:
   383	    tier: red
   384	    agent: all
   385	    block_reason: unauthorized_adapter
   386	    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
   387	    irreversible: true
   388	
   389	  send_to_blocked_recipient:
   390	    tier: red
   391	    agent: all
   392	    block_reason: blocked_recipient
   393	    reason: "Recipient in tenant's blocked_recipients override list"
   394	    irreversible: true
   395	
   396	# ───────────────────────────────────────────────────────────
   397	# Defaults applied when override fields are absent in tenant_adapters
   398	# ───────────────────────────────────────────────────────────
   399	
   400	defaults:
   401	  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
   402	  min_sample_rate: 100          # Tenants cannot set sample rate above 1-in-100 per §8 rule 6
   403	  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes
   404	
   405	# ───────────────────────────────────────────────────────────
   406	# Compile-time consistency assertions (enforced by Phase-3 validator script,
   407	# not by YAML itself — documented here so Codex can verify)
   408	# ───────────────────────────────────────────────────────────
   409	
   410	invariants:
   411	  - "tier ∈ {green, yellow, orange, red}"
   412	  - "yellow action_types MUST declare sample_rate (positive integer)"
   413	  - "orange action_types MUST declare timeout (ISO-8601 duration)"
   414	  - "red action_types MUST declare block_reason"
   415	  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
   416	  - "47 total action_types (19 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '430,489p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   471	
   472	`_shared/hook-helpers.sh` must:
   473	
   474	1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
   475	2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)
   476	3. Resolve `phase` from this catalogue's `Phase:` line (table-driven, not freeform)
   477	4. Default `agent_name` to `${CTX_AGENT_NAME}` or `_renderer` (renderer-only sentinel)
   478	
   479	The catalogue is read at process start via `_shared/escalation-codes-table.sh` (machine-readable companion; deferred to Phase 3 or first use, whichever lands first). If absent, helpers fall back to permissive write (log row only; no Telegram) + emit a one-shot operational warning.
   480	
   481	---
   482	
   483	## §5 — Change protocol
   484	
   485	New codes added here BEFORE wiring into helpers + before any agent references them. Code names case-sensitive (`ESC_[A-Z][A-Z0-9_]*`).
   486	
   487	The Codex Day-7 ratification queue includes this catalogue (item #20 placeholder per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1). Updates after ratification = new commit + Codex re-review of the diff.
   488	
   489	*End of catalogue (52 active codes + 2 reserved).*

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
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '220,294p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   261	    return 0
   262	  fi
   263	
   264	  printf '{"edits":[],"lookback_days":%s,"source":"fallback","reason":"db_unavailable"}\n' "${lookback_days}"
   265	}
   266	
   267	# Internal: render psql TSV → JSON for recent edits.
   268	_vl_render_recent_edits_json() {
   269	  local rows="$1"
   270	  local lookback_days="$2"
   271	
   272	  if [[ -z "${rows}" ]]; then
   273	    printf '{"edits":[],"lookback_days":%s,"source":"db","count":0}\n' "${lookback_days}"
   274	    return 0
   275	  fi
   276	
   277	  printf '{"edits":['
   278	  local first=1
   279	  while IFS=$'\t' read -r id action_type edit_distance resolution tone_rules resolved_at; do
   280	    [[ -z "${id}" ]] && continue
   281	    if (( first )); then first=0; else printf ','; fi
   282	    printf '{"id":%s,"action_type":"%s","edit_distance":%s,"resolution":"%s","tone_rules_triggered":"%s","resolved_at":"%s"}' \
   283	      "${id}" \
   284	      "$(_hh_json_escape "${action_type}")" \
   285	      "$([[ -z "${edit_distance}" ]] && echo "null" || echo "${edit_distance}")" \
   286	      "$(_hh_json_escape "${resolution}")" \
   287	      "$(_hh_json_escape "${tone_rules}")" \
   288	      "$(_hh_json_escape "${resolved_at}")"
   289	  done <<<"${rows}"
   290	  printf '],"lookback_days":%s,"source":"db"}\n' "${lookback_days}"
   291	}
   292	
   293	# Exported so tests can introspect.
   294	export _VL_VERSION

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/tools.yaml | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '216,360p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   236	  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
   237	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   238	      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
   239	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   240	      "${target}" "${payload_hash}" "override_resolution_failed"
   241	    return 1
   242	  fi
   243	
   244	  case "${tier}" in
   245	    green)
   246	      autosend_emit_decision_log "action" "green" "${action_type}" \
   247	        "${target}" "${payload_hash}" "${payload_preview}" ""
   248	      return 0
   249	      ;;
   250	    yellow)
   251	      autosend_emit_decision_log "action" "yellow" "${action_type}" \
   252	        "${target}" "${payload_hash}" "${payload_preview}" ""
   253	      if autosend_should_sample "${action_type}" "${tenant}"; then
   254	        autosend_spot_check_enqueue "${action_type}" "${target}" \
   255	          "${payload_hash}" "${payload_preview}" "${tenant}"
   256	      fi
   257	      return 0
   258	      ;;
   259	    orange)
   260	      autosend_emit_decision_log "action" "orange" "${action_type}" \
   261	        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
   262	      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
   263	        "${target}" "${payload_hash}" "${payload_preview}"
   264	      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
   265	      return $?
   266	      ;;
   267	    red)
   268	      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
   269	        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
   270	      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
   271	        "${target}" "${payload_hash}" "red_tier_classification"
   272	      return 1
   273	      ;;
   274	    *)
   275	      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   276	        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
   277	      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   278	        "${target}" "${payload_hash}" "unknown_tier:${tier}"
   279	      return 1
   280	      ;;
   281	  esac
   282	}
   283	
   284	# ────────────────────────────────────────────────────────────────────────
   285	# 7 autosend_* helpers (autosend-safety-policy §4)
   286	# ────────────────────────────────────────────────────────────────────────
   287	
   288	# autosend_policy_lookup <action_type>
   289	# Prints the tier (green|yellow|orange|red) to stdout; returns 0 if found,
   290	# 1 if action_type missing from policy file.
   291	autosend_policy_lookup() {
   292	  local action_type="$1"
   293	  if [[ ! -f "${_HH_POLICY_FILE}" ]]; then
   294	    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
   295	    return 1
   296	  fi
   297	  # YAML lookup via awk — finds the action_type key, then reads tier:
   298	  # one line below. Safer than yq/python deps at agent runtime.
   299	  local tier
   300	  tier=$(awk -v key="${action_type}" '
   301	    $0 ~ "^  " key ":" { in_block = 1; next }
   302	    in_block && /^    tier: / { sub(/^    tier: /, ""); print; exit }
   303	    in_block && /^  [a-z]/ { in_block = 0 }
   304	  ' "${_HH_POLICY_FILE}")
   305	  if [[ -z "${tier}" ]]; then
   306	    return 1
   307	  fi
   308	  printf '%s' "${tier}"
   309	}
   310	
   311	# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
   312	# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
   313	# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
   314	# Tenants can ELEVATE only (green→yellow→orange→red); red is the floor.
   315	autosend_apply_tenant_override() {
   316	  local base_tier="$1"
   317	  local action_type="$2"
   318	  local tenant_slug="$3"
   319	
   320	  # Red is absolute — no override possible.
   321	  if [[ "${base_tier}" == "red" ]]; then
   322	    printf '%s' "red"
   323	    return 0
   324	  fi
   325	
   326	  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
   327	  if [[ ! -f "${override_file}" ]]; then
   328	    printf '%s' "${base_tier}"
   329	    return 0
   330	  fi
   331	
   332	  local override
   333	  override=$(awk -v key="${action_type}" '
   334	    $0 ~ "^  " key ":" { sub(/^  [^:]+: */, ""); print; exit }
   335	  ' "${override_file}")
   336	
   337	  if [[ -z "${override}" ]]; then
   338	    printf '%s' "${base_tier}"
   339	    return 0
   340	  fi
   341	
   342	  # Enforce elevation-only ordering.
   343	  local base_rank override_rank
   344	  case "${base_tier}" in green) base_rank=0;; yellow) base_rank=1;; orange) base_rank=2;; red) base_rank=3;; *) return 1;; esac
   345	  case "${override}" in green) override_rank=0;; yellow) override_rank=1;; orange) override_rank=2;; red) override_rank=3;; *) return 1;; esac
   346	
   347	  if (( override_rank < base_rank )); then
   348	    printf 'autosend_apply_tenant_override: refusing to demote %s → %s for %s/%s\n' \
   349	      "${base_tier}" "${override}" "${tenant_slug}" "${action_type}" >&2
   350	    return 1
   351	  fi
   352	  printf '%s' "${override}"
   353	}
   354	
   355	# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
   356	# Emits the standard autosend decision_log row with payload.tier set.
   357	autosend_emit_decision_log() {
   358	  local phase="$1"
   359	  local tier="$2"
   360	  local action_type="$3"

exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|packages/harness/cortextos|stock KB|kb-" agents/recruitment/concierge/agent.md agents/recruitment/concierge/tools.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/concierge/tools.yaml:215:# - No Composio / AgentMail references anywhere in this file.

exec
/bin/zsh -lc 'rg -n "decision_log|phase:|payload|tenant_adapters_config_additions|concierge_last_poll|concierge_send_window|approval|recent_edit|tone_rule|voice_corpus" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:123:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:384:  Q11_voice_corpus_chunk_storage:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:393:  Q12_tone_rule_severity_block_path:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:405:      Indefinite retention of original_text + edited_text plausibly exceeds GDPR "data minimisation" tests. Is retention of (edit_distance + resolution + tone_rules_triggered) sufficient for v2.0 LoRA SFT pair generation, with the text bodies purged after 90 days?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:311:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:313:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:327:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:328:  # voice_corpus_chunks is introduced separately around v0.2 supplement line
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:335:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:359:  #   agent + which fields were touched in decision_log payload; reviewers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:369:  # decision_log row records who wrote. Entity-level RLS enforces TENANT
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:431:    # in the Sourcing Scout shortlist artefact (vault markdown + decision_log
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:584:      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:587:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:594:      Diagnostic + Sourcing Scout also read tone_rules for their
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:597:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:609:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:642:      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:649:      description, raw_payload). Aligned with Q4 v0_3_default. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:680:      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:700:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:710:  voice_corpus_chunks:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:719:  tone_rule:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:728:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:773:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:782:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:861:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:864:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:865:  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:868:  # that ships alongside Tier 2 activation. v0.3 introducing the payload
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:877:      separate post-launch quality metric outside Gate A. The payload key,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:882:      payload shape to avoid declaring schema without enforcement.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1022:  per_claim_confidence_distribution payload key originally planned for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1024:  §5 of this supplement); v0.3 is silent on payload schema extensions.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1040:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:26:  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:149:      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
docs/verticals/recruitment/vertical-schema.yaml:365:        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.

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

exec
/bin/zsh -lc 'rg -n "ESC_AGENT_TOOL_FAILURE|concierge_cleanup|bullhorn_oauth:" agents/_shared agents/recruitment/concierge docs/verticals/recruitment -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/concierge/tools.yaml:133:        escalation: ESC_AGENT_TOOL_FAILURE  # transport-class failure, NOT timeout (different routing)
agents/recruitment/concierge/tools.yaml:187:  - id: concierge_cleanup
agents/recruitment/concierge/tools.yaml:189:    action_type: concierge_cleanup  # green tier; QUEUED registration for cleanup.sh wire at W10-13
agents/recruitment/concierge/tools.yaml:207:#   concierge_cleanup                  green               (W10-13 cleanup.sh wire)
agents/recruitment/concierge/cleanup.sh:9:# `concierge_cleanup` (green tier — internal-only audit row recording
agents/recruitment/concierge/cleanup.sh:12:# Per agents/_shared/autosend-policy.yaml: `concierge_cleanup` is QUEUED for
agents/recruitment/concierge/cleanup.sh:98:# TODO(W10-13): once concierge_cleanup action_type is registered in
agents/recruitment/concierge/cleanup.sh:101:hh_decision_output "concierge_cleanup" "tenant:${CTX_TENANT_SLUG}" \

codex
The source checks show several references are valid, including the Concierge build wave and the amended ULTRAPLAN Gate A/B lines. I’m checking the actual bundle contract against those sources now, because the policy/schema registration details are where this can still fail.
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '260,560p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	    → maintains audit trail in Bullhorn itself (NOT customer-visible;
   261	      separate from bullhorn_note_customer_visible orange tier)
   262	    → hh_decision_action("bullhorn_activity_log_write",
   263	      "candidate:<bullhorn_id>", payload_hash,
   264	      "event_type:<type>; bullhorn_activity_id:<id>") — green tier per
   265	      autosend-policy.yaml (registered 2026-06-02 per Codex Fbis-R1 closure;
   266	      grep `^  bullhorn_activity_log_write:` to verify). External-write
   267	      action_type required for tier classification per autosend-policy §3.
   268	
   269	14. Lifecycle state advance (Bullhorn write, conditional)
   270	    → some events trigger Bullhorn state changes (e.g., interview-completed
   271	      sent → advances state to "post-interview" if tenant policy says so)
   272	    → per-tenant policy; opt-in; not all tenants want this
   273	    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
   274	      payload_hash, "event=<type> elapsed=<seconds>")
   275	
   276	15. Session close + Gate B metric
   277	    → compute elapsed (event → send) for Gate B SLA tracking
   278	    → check ghosted-rate metric (any candidate with no Concierge action in
   279	      14 days post-state-change → contributes to ghosted-rate)
   280	    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
   281	    → hh_decision_action("concierge_run_complete", "session:<tenant_slug>",
   282	      payload_hash, "mode:<webhook|poll|nurture-sweep|manual>; drafts:<N>;
   283	      sends:<N>; ghosted_rate:<float>") — green tier per autosend-policy.yaml;
   284	      4-arg signature matches `_shared/hook-helpers.sh` `hh_decision_action
   285	      <action_type> <target> <payload_hash> <payload_preview>` contract.
   286	    → exit code 0
   287	```
   288	
   289	---
   290	
   291	## §5 — Gates
   292	
   293	### Gate A — validate.sh (hard-fail before action)
   294	
   295	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
   296	
   297	- **"voice classifier score ≥ position-specific threshold"** (≥0.75 position 1, ≥0.78 position 2, ≥0.82 position 3) — hard-fail
   298	- **"correct addressee resolution (no candidates emailed under another's name)"** — hard-fail (Step 4 critical; ESC_ADDRESSEE_MISMATCH)
   299	- No tone-rule block-severity violations — hard-fail (ESC_TONE_RULE_VIOLATION)
   300	- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
   301	- Anti-duplicate guard passed (Step 2) — hard-fail (skip if true duplicate)
   302	- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_AGENT_OUTPUT_SHAPE; ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10)
   303	
   304	The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
   305	
   306	Gate A failures fire ESC codes per their catalogue-defined severity (do NOT conflate "Gate A blocks the draft from sending" with "ESC severity escalates to oncall"):
   307	
   308	- **Catalogue blocking-severity:** `ESC_ADDRESSEE_MISMATCH`, `ESC_PII_LEAKAGE_RISK` — these route to operator + ifos_oncall_chat_id per catalogue §2.10 (truly customer-impacting violations).
   309	- **Catalogue warn-severity:** `ESC_TONE_RULE_VIOLATION`, `ESC_AGENT_OUTPUT_SHAPE` — these route to operator_chat_id only per catalogue §2.10 + §2.7 (per-draft signal-quality issues; not customer-impacting unless multiple aggregate).
   310	
   311	ALL FOUR cause Gate A to block the draft from sending (validate.sh exits non-zero; draft stays in vault; cycle.sh aborts the orange-tier emission). The "blocking" of the DRAFT is `validate.sh` behavior; the "blocking" severity of the ESC code is the operator-paging-urgency lookup. These are separate dimensions. Draft is moved to `/tmp` (out of the customer-facing path) regardless of ESC severity; operator is notified immediately for blocking-tier ESCs, asynchronously-aggregated for warn-tier.
   312	
   313	**Honesty note (per bilateral-disposition Cat-5):** Concierge `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W10-13 build slice. The W10-13 build delivers `agents/recruitment/concierge/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   314	
   315	### Gate B — Outcome thresholds (success metrics, not block)
   316	
   317	Per ULTRAPLAN A6 line 567 + ADR-007 amendment: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate"**. The third metric is ADR-007's Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail (NOT in original line 567 wording).
   318	
   319	Three metrics:
   320	- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%. (per ULTRAPLAN line 567)
   321	- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`. (per ULTRAPLAN line 567)
   322	- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
   323	
   324	Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Any of the three metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
   325	
   326	---
   327	
   328	## §6 — Escalation codes
   329	
   330	Concierge uses these ESC codes from `agents/_shared/escalation-codes.md`:
   331	
   332	| Code | Trigger | Severity | Routing |
   333	|---|---|---|---|
   334	| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
   335	| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
   336	| `ESC_MS_GRAPH_AUTH` | Microsoft Graph OAuth fail | **blocking** | operator + ifos_oncall (catalogue verbatim — token re-auth requires operator intervention; tenant-admin involvement is a manual operator-discretion follow-up, not part of the catalogue routing) |
   337	| `ESC_GMAIL_AUTH` | Gmail OAuth fail | **blocking** | operator + ifos_oncall (catalogue verbatim; same tenant-admin caveat as ESC_MS_GRAPH_AUTH) |
   338	| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
   339	| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
   340	| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
   341	| `ESC_VOICE_DRIFT` | Voice classifier below the position-specific threshold (≥0.75/0.78/0.82) after 3 retries. The Gate A hard-fail (validate.sh exits non-zero; draft not sent) is expressed through `validate_gate_a_fail`, NOT through this code's severity: per catalogue (escalation-codes.md lines 120-125) `ESC_VOICE_DRIFT` is `warn` → `operator_chat_id` for ALL positions. Position-specific paging urgency (e.g. oncall on rejections) would require a catalogue amendment adding position-severity semantics — not yet made. | warn | operator_chat_id |
   342	| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | warn (catalogue) — Gate A still blocks the draft from sending via validate.sh; ESC severity governs operator-paging urgency only | operator_chat_id |
   343	| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
   344	| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
   345	| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md `ESC_APPROVAL_BRIDGE_TIMEOUT` block + autosend-policy.yaml grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field) | warn | operator + ifos_oncall (catalogue verbatim — operator absent + commitment may need rerouting; tenant-admin involvement is a manual escalation choice when bridge-timeout becomes pattern-recurring, not part of catalogue routing) |
   346	| `ESC_SEND_FAIL` | Email provider 4xx/5xx | warn | operator_chat_id |
   347	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
   348	| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% OR 30-min SLA hit-rate <90% for 30 consecutive days | warn | founder + operator |
   349	| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
   350	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
   351	
   352	Concierge has the largest escalation surface of any v1.0 agent — appropriate for the highest-stakes customer-facing comms.
   353	
   354	Concierge does NOT use:
   355	
   356	- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
   357	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
   358	- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
   359	
   360	---
   361	
   362	## §7 — Voice + tone constraints
   363	
   364	Steps 7-8 (draft generation + voice/tone validation) are the load-bearing voice surface of v1.0. The agent integrates with `_shared/voice-loader.sh`:
   365	
   366	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
   367	  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §Gotchas line 570; demand specificity)
   368	  - No "Per our previous conversation" without referencing the actual conversation context
   369	  - No urgency language ("URGENT", "ACT NOW") unless the lifecycle event genuinely requires it
   370	  - No mention of other candidates by name
   371	  - No salary/rate specifics outside what's already on the candidate's record
   372	  - No competing-agency references
   373	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
   374	- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
   375	
   376	**Position-specific thresholds:**
   377	- Position 1 (standard sends — acknowledgement, prep, debrief, nurture): voice ≥0.75
   378	- Position 2 (placement-positive, status-update): voice ≥0.78
   379	- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §Gotchas line 570 explicitly names rejection voice as the hardest case)
   380	
   381	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   382	
   383	---
   384	
   385	## §8 — Build dependencies (W10-13 prerequisites)
   386	
   387	Concierge build cannot start until ALL of the following are confirmed:
   388	
   389	| Dependency | Source | Status |
   390	|---|---|---|
   391	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   392	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   393	| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
   394	| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
   395	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   396	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   397	| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
   398	| **Microsoft Graph commercial signup** (per tenant) | Tenant onboarding | ⏸ |
   399	| **Gmail / Google Workspace signup** (alternative per tenant) | Tenant onboarding | ⏸ |
   400	| Microsoft Graph MCP connector | W10 build start (~3 days) | ⏸ |
   401	| Gmail MCP connector | W10 build start (~3 days) | ⏸ |
   402	| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
   403	| Autosend bridge built (per D1 outcome) | W10 build start (~2 days for D1-A; less for D1-B/C) | ⏸ |
   404	| Voice classifier microservice live | W4-5 polish | ⏸ |
   405	| Per-tenant comms-template library at `/vault/<slug>/concierge-templates/` | Tenant onboarding | ⏸ |
   406	| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
   407	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   408	| `validate.sh` Gate A logic | Build at W10 start (~2 days; most complex of v1.0 validators) | ⏸ |
   409	| `context.sh` hydration | Build at W10 start (~1 day) | ⏸ |
   410	| `cycle.sh` orchestration (15-step) | Build at W10-11 (~5 days; lifecycle state machine + 12 event types) | ⏸ |
   411	| Lifecycle event-detection polling fallback | Build at W11-12 (~3 days; Bullhorn webhook coverage gaps) | ⏸ |
   412	| Comms-template library v0.1 (12 event types × 2 recipient roles = 24 templates minimum) | Build at W12-13 (~5 days) | ⏸ |
   413	| 5 fixtures with golden outputs (broader than 3 for other agents; XL complexity warrants) | Build at W13 (~2 days) | ⏸ |
   414	
   415	**Until ALL ⏸ items resolve to ✅, W10 build slice does not start.** XL build complexity = 4-week duration not negotiable.
   416	
   417	---
   418	
   419	## §9 — Status + open questions
   420	
   421	**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
   422	
   423	### Open questions for founder review
   424	
   425	| # | Question | Resolution path |
   426	|---|---|---|
   427	| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
   428	| Q2 | Lifecycle event taxonomy — 12 events proposed in §3. Founder confidence each is correct + complete? Missing: "candidate referred to another role internally"? "Client cancelled brief"? | Founder review with first pilot consultants. Recommend: ship 12-event v1.0; expand v1.1+ based on real patterns. |
   429	| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
   430	| Q4 | Rejection emails (event 6) — Position 3 (voice ≥0.82). Is this enough, or should rejections route to consultant for full draft (not just approve)? | Founder review with first pilot consultant. Recommend: Concierge drafts; consultant approves; never bypasses voice gate. |
   431	| Q5 | Comms-template customisation — every tenant edits these. Per-event-type, per-recipient-role × per-tenant = 24+ templates each. Authoring tool? | v1.0: Markdown files at `/vault/<slug>/concierge-templates/<event>-<role>.md`. v1.1: Brain UI WYSIWYG editor. |
   432	| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
   433	| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
   434	| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
   435	| Q9 | Cross-tenant lifecycle handling — what if a candidate placed at Tenant A's client interviews at Tenant B 6 weeks later? Bullhorn has separate tenant slugs; no cross-tenant leak. But operator visibility? | v1.0: strict tenant isolation (no cross-tenant data visibility). v1.1+: separate agent for tenant-network-graph if commercial demand. |
   436	| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
   437	
   438	### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)
   439	
   440	1. **Lifecycle event detection from Bullhorn is the unreliable bit.** Bullhorn's webhook coverage is patchy; polling fallbacks are required. Step 1 polling at 5-min cycle + anti-duplicate guard at Step 2 is the architecture.
   441	2. **Voice quality on rejections is the hardest test case.** Position-3 threshold (≥0.82) + sensitive-event escalation routing (Step 6). Get this wrong and it costs the tenant a candidate relationship.
   442	3. **Comms-template library is per-tenant, per-event-type, per-recipient-role.** 24+ templates per tenant minimum. Authoring effort is significant; consider this in pilot onboarding scoping.
   443	4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add agent-identity email adapter (deferred).
   444	
   445	---
   446	
   447	## §10 — When this document ratifies
   448	
   449	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   450	
   451	Status flips Proposed → Accepted when:
   452	- Codex Round 4 Phase 2 ratifies
   453	- **✅ ADR-007 (Concierge Gate A 30-min SLA hybrid) ACCEPTED + RATIFIED** — Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3 per `.codex/ratification/review-architecture-decision.md` skill (commit `c862c77`). Closes the documented deviation from ULTRAPLAN A6 line 566 wording; agent.md's Gate B framing of the 30-min SLA is now the canonical disposition. This Status-flip blocker is satisfied.
   454	- **Founder Decision D1 RESOLVED** (Q1 above) — without this, Concierge build cannot start
   455	- Founder approves §9 Q2 (lifecycle taxonomy) + Q3 (send window) + Q4 (rejection routing) + Q5 (template authoring UX) + Q6 (Gate B UX)
   456	- Q7-Q9 documented decisions captured
   457	
   458	Status flips Accepted → In Force when:
   459	- W10-13 build slice produces all 5 sibling bundle files + 5 fixtures (broader fixture coverage warranted by XL complexity)
   460	- First production lifecycle webhook processed end-to-end against migration-test tenant
   461	- 12-event taxonomy validated against first pilot tenant's actual Bullhorn state-change patterns
   462	- Voice classifier microservice production-ready (per-tenant; position-3 ≥0.82 sustained)
   463	- Gate B feedback loop operational (consultant approve/edit distinguishable)
   464	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   465	
   466	Until then: this document is a forward-looking scaffold. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at scaffold stage. Founder review at each iteration is expected.
   467	
   468	*End of Concierge agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '755,885p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
    17	> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
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
    40	Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §Gotchas line 570 gotcha — see Step 1 polling fallback.
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
    77	| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §Gotchas line 570 — respectful, specific, leaves door open |
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
   103	Each draft writes TWO decision_log rows per `_shared/hook-helpers.sh` contract:
   104	
   105	1. `phase='output'` via `hh_decision_output("concierge_draft_rendered", "/vault/<tenant>/concierge-drafts/<id>.md", "voice_score:<N>; words:<N>")`. The helper writes only `{output_type, artefact_ref}` to the payload jsonb; the additional metadata rides the optional `reason` string parameter. This row records that the draft exists; no tier (output rows are not tier-classified).
   106	
   107	2. `phase='action'` via `hh_decision_action("concierge_email_draft", "candidate:<bullhorn_id>:<event_type>", payload_hash, payload_preview)`. This is the tier-classified row — `concierge_email_draft` is registered yellow tier per autosend-policy.yaml lookup (grep `^  concierge_email_draft:` to verify). Tier is recorded inside the autosend-emitted payload by the helper; it is NOT a top-level decision_log column. `payload_preview` carries `event_type`, `voice_score`, `recipient`, `escalation_position` as a concatenated string for cross-row correlation. Action_type stays stable across all 12 lifecycle events — event_type is in the preview string, not part of the action_type identifier.
   108	
   109	The actual SEND is a separate orange-tier action_type:
   110	- `gmail_outlook_send_to_candidate` (orange tier per autosend-policy.yaml §ORANGE) when channel=email
   111	- `bullhorn_note_customer_visible` (orange tier; canonical orange per autosend-policy.yaml §ORANGE) when channel=Bullhorn note with isExternal=true
   112	- `twilio_sms_send` (orange tier per autosend-policy.yaml §ORANGE) when channel=SMS (v1.1+)
   113	- `calendar_invite_send` (orange tier per autosend-policy.yaml §ORANGE) when event includes calendar attachment
   114	
   115	Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
   116	
   117	---
   118	
   119	## §4 — Workflow
   120	
   121	15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   122	
   123	```
   124	0. Session start (webhook OR poll OR cron)
   125	   → context.sh hydrates: tenant config + Bullhorn auth refresh +
   126	     Microsoft Graph / Gmail auth + agent-identity email adapter (deferred) (if v1.1+ enabled) +
   127	     voice corpus + tone rules + recent_edits + tenant comms-template
   128	     library + addressee-resolution data
   129	   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")
   130	
   131	1. Source detection (mode-dependent)
   132	   → mode=webhook: parse Bullhorn payload → resolve entity + state transition
   133	   → mode=poll: query Bullhorn for placements/candidates with state_changed_at
   134	     > tenant_adapters.config.concierge_last_poll AND not in decision_log
   135	     (anti-duplicate)
   136	   → mode=nurture-sweep: query Bullhorn placements for time-elapsed events
   137	     (7d/30d/90d post-start with no concierge action in last 14d)
   138	   → ESC_LIFECYCLE_STATE_UNKNOWN if state transition not in 12-event taxonomy
   139	   → hh_decision_output("lifecycle_event_detected",
   140	     "<entity_type>:<bullhorn_id>", "<from>→<to>")
   141	
   142	2. Anti-duplicate guard
   143	   → query decision_log for prior `concierge_email_draft` row for same
   144	     (candidate_id, payload.event_type) in last 24h with phase IN
   145	     ('output', 'action') — if a prior draft was emitted AND either sent OR
   146	     is still pending consultant action, the new event is a duplicate trigger
   147	   → if found AND send-completed: skip (true duplicate)
   148	   → if found BUT prior draft never sent (no `gmail_outlook_send_to_candidate`
   149	     follow-up action row): allow the new draft attempt (per Q7 disposition)
   150	   → hh_decision_output("anti_duplicate_check", "<entity_type>:<bullhorn_id>",
   151	     "<duplicate_status>")
   152	
   153	3. Bullhorn context fetch
   154	   → bullhorn.get_candidate(candidate_id) → name, current state, comms history
   155	   → bullhorn.get_placement(placement_id) → role, client, dates
   156	   → bullhorn.get_client(client_id) → company name, primary contact
   157	   → bullhorn.get_contact(contact_id) → name, email
   158	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
   159	     ESC_BULLHORN_AUTH on auth fail
   160	   → ESC_AGENT_OUTPUT_SHAPE if critical Bullhorn context fields missing
   161	     (no email, no name) — Concierge cannot produce its declared output
   162	     shape (lifecycle-event draft) without a resolvable target candidate.
   163	     NOTE: ESC_CANDIDATE_DATA_INCOMPLETE is reserved for Sourcing Scout
   164	     shortlist completeness per catalogue §2.10.
   165	   → hh_decision_output("bullhorn_context_fetched",
   166	     "candidate:<bullhorn_id>", "fields_present:<N>")
   167	
   168	4. Addressee resolution (Gate A critical)
   169	   → recipient = candidate.email OR client_contact.email per event_type
   170	   → verify recipient matches the candidate_id whose lifecycle is changing
   171	     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
   172	     "correct addressee resolution; no candidates emailed under another's name")
   173	   → ESC_ADDRESSEE_MISMATCH if check fails (blocking); draft aborted
   174	   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
   175	     "recipient_role:<role>")
   176	
   177	5. Comms-template selection
   178	   → tenant comms-template library at /vault/<slug>/concierge-templates/
   179	   → per event_type: select template; per recipient_role: candidate vs client
   180	   → fallback: shared/common-comms-templates.yaml if tenant has no override
   181	   → hh_decision_output("template_selected", "<event_type>:<recipient_role>",
   182	     "template_id:<id>")
   183	
   184	6. Sensitive-event escalation routing
   185	   → if event_type=rejection (event 6) OR event_type=withdrawal (event 7)
   186	     OR (event_type=on-hold AND placement value >£10k): set escalation_position=3
   187	     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
   188	   → else: escalation_position=1 (standard orange tier)
   189	   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
   190	     "position:<N>")
   191	
   192	7. LLM draft generation
   193	   → prompt = (event context + candidate state history + voice corpus
   194	     ANN-matched on event_type + tone rules filtered for concierge +
   195	     comms-template structure)
   196	   → output = email body + subject + recommended_send_time
   197	   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
   198	   → hh_decision_output("concierge_draft_rendered",
   199	     "candidate:<bullhorn_id>:<event_type>", "vault_path:<path>; voice_score:<N>; words:<N>")
   200	   → ESC_VOICE_DRIFT if classifier score below the escalation_position-specific
   201	     threshold (position 1 ≥0.75; position 2 ≥0.78; position 3 ≥0.82 per Step 8)
   202	     after 3 retries — the position is set in Step 6 and is the per-draft Gate A
   203	     threshold. Generic <0.75 floor would understate position 2-3 sensitivity.
   204	
   205	8. Voice + tone validation
   206	   → voice classifier scores the draft
   207	   → minimum threshold by escalation_position:
   208	     position 1: ≥0.75
   209	     position 2: ≥0.78
   210	     position 3 (rejections / sensitive): ≥0.82
   211	   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
   212	   → on success: hh_decision_action("concierge_email_draft",
   213	     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
   214	     tier=yellow per autosend-policy.yaml
   215	
   216	9. SLA timing check (Gate B leading metric — NOT Gate A hard-fail)
   217	   → elapsed = now() - event_timestamp
   218	   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
   219	     → hh_decision_output("concierge_sla_miss",
   220	       "candidate:<bullhorn_id>:<event_type>",
   221	       "elapsed_seconds:<N>; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct")
   222	       — mandatory audit row per master brief §8.1 Change 2 (phase=output;
   223	       no tiered action_type required — this is an internal status marker)
   224	   → per ULTRAPLAN A6 line 566 (as amended by ADR-007): the 30-min draft SLA is
   225	     a Gate B leading metric (90% of drafts within 30 min), not a per-draft hard
   226	     fail (legitimate polling-fallback delays would otherwise block drafts)
   227	
   228	10. PII boundary check
   229	    → no PII from other candidates referenced in body
   230	    → no PII from competitor clients referenced
   231	    → no compensation specifics outside what's already in candidate's record
   232	    → ESC_PII_LEAKAGE_RISK on hit (blocking)
   233	    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
   234	     "result:passed")
   235	
   236	11. Autosend-bridge routing (D1 path)
   237	    → per Founder Decision D1 (final selection at W10 design):
   238	      D1-A (bridge to cortextOS approval system): POST internal API
   239	      D1-B (lightweight Telegram shim): send approval prompt to operator
   240	      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
   241	    → per autosend-policy.yaml: orange-tier; consultant approves
   242	    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within the policy timeout
   243	      (default PT4H per autosend-policy.yaml (grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field; default `PT4H`) + escalation-codes.md
   244	      lines 348-353; looked up per action_type, not hardcoded) (D1-A/B)
   245	    → hh_decision_action("concierge_approval_routed",
   246	      "candidate:<bullhorn_id>:<event_type>", payload_hash,
   247	      "d1_path:<A|B|C>; bridge_target:<approval_id_or_vault_path>")
   248	
   249	12. (After operator approval) Send execution — orange-tier
   250	    → microsoft-graph.send_email() OR gmail.send_email() per tenant config
   251	    → BCC: tenant's archive address (per tenant config)
   252	    → hh_decision_action("gmail_outlook_send_to_candidate",
   253	      "candidate:<bullhorn_id>", payload_hash, payload_preview)
   254	      [or `bullhorn_note_customer_visible` if channel=Bullhorn-note]
   255	    → ESC_SEND_FAIL on 4xx/5xx; retry once 30s backoff
   256	
   257	13. Bullhorn activity-log write
   258	    → bullhorn.create_activity_log(candidate_id, "concierge: <event_type>
   259	      sent at <ISO>")
   260	    → maintains audit trail in Bullhorn itself (NOT customer-visible;

codex
The actual workspace has sibling files for Concierge, so I’m treating this as more than a pure standalone `agent.md` scaffold where the sibling bundle is entirely absent. That makes any claims about nonexistent files and queued registrations materially testable.
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/cycle.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Concierge agent — cycle.sh (15-step orchestration)
     3	#
     4	# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs with
     5	#         full package wiring per agent.md §4).
     6	# Reading order: agent.md §1 (output contract) + §3 (12 lifecycle events) +
     7	#         §4 (this workflow's 15 steps) + §5 (Gate A) + §6 (16 ESC codes) first.
     8	#
     9	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
    10	# produces output OR takes action MUST call hh_decision_* from
    11	# agents/_shared/hook-helpers.sh.
    12	#
    13	# Invocation modes (per agent.md §2):
    14	#   mode=webhook         — Bullhorn lifecycle webhook event-driven (v1.0 primary)
    15	#   mode=poll            — Bullhorn state-changed-at polling fallback when
    16	#                          tenant lacks webhook capability
    17	#   mode=nurture-sweep   — cron: 7d/30d/90d post-start nurture cadence
    18	#   mode=manual          — ifosctl concierge process-event|nurture-sweep
    19	#
    20	# Package dependencies (W10-13 build slice; v0.1.0 fixture-first SKELETON):
    21	#   @ifos/bullhorn               — Bullhorn ATS (auth + entity fetches + activity-log write)
    22	#   @ifos/microsoft-graph        — MS Graph send_email (alt to gmail)
    23	#   @ifos/gmail                  — Gmail send_email (alt to microsoft-graph)
    24	#   @ifos/autosend-bridge-telegram — D1-B Telegram approval shim (Concierge OWNS Step 11)
    25	#   @ifos/voice-classifier       — voice scoring per position threshold
    26	#   @ifos/tone-rules             — block-severity tone-rule enforcement
    27	#   @ifos/telegram               — operator notifications (NOT customer-facing)
    28	#
    29	# Output contract per agent.md §1 (READ THAT FIRST):
    30	#   Customer-facing email drafts per lifecycle event (12-event taxonomy) →
    31	#   vault at /vault/<tenant>/concierge-drafts/<draft_id>.md + decision_log
    32	#   yellow-tier concierge_email_draft row; SEND is orange tier
    33	#   (gmail_outlook_send_to_candidate / bullhorn_note_customer_visible)
    34	#   gated by autosend-bridge approval per D1-B founder decision.
    35	
    36	set -euo pipefail
    37	
    38	# ────────────────────────────────────────────────────────────────────────
    39	# Pre-flight: CTX env + _shared/ helper resolution
    40	# (Mirrors the 4-candidate fallback chain established in d7d52c5 smoke-hotfix.)
    41	# ────────────────────────────────────────────────────────────────────────
    42	
    43	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    44	  printf 'concierge/cycle.sh: CTX_AGENT_DIR unset (context.sh must run first)\n' >&2
    45	  exit 2
    46	fi
    47	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    48	  printf 'concierge/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
    49	  exit 2
    50	fi
    51	: "${CTX_AGENT_NAME:=concierge}"
    52	
    53	_SHARED_DIR=""
    54	for _candidate in \
    55	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    56	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    57	  "${CTX_AGENT_DIR}/../../_shared" \
    58	  "${CTX_AGENT_DIR}/../_shared" ; do
    59	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    60	    _SHARED_DIR="${_candidate}"
    61	    break
    62	  fi
    63	done
    64	if [[ -z "${_SHARED_DIR}" ]]; then
    65	  printf 'concierge/cycle.sh: cannot locate _shared/ helpers\n' >&2
    66	  exit 1
    67	fi
    68	# shellcheck source=/dev/null
    69	source "${_SHARED_DIR}/hook-helpers.sh"
    70	
    71	# ────────────────────────────────────────────────────────────────────────
    72	# Mode + invocation surface
    73	# ────────────────────────────────────────────────────────────────────────
    74	
    75	MODE="${CTX_CONCIERGE_MODE:-webhook}"
    76	STEPS_TO_RUN="${CTX_STEPS_OVERRIDE:-0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}"
    77	
    78	# TODO(W10-13): mode-dependent argument parsing
    79	#   webhook  → CTX_WEBHOOK_PAYLOAD (JSON; Bullhorn lifecycle event)
    80	#   poll     → CTX_POLL_SINCE_ISO
    81	#   nurture  → CTX_NURTURE_LOOKBACK_DAYS (7|30|90)
    82	#   manual   → CTX_MANUAL_ENTITY_TYPE + CTX_MANUAL_ENTITY_ID + CTX_MANUAL_EVENT_TYPE
    83	# Until parsed, mark unused intentionally:
    84	export STEPS_TO_RUN MODE
    85	
    86	# ────────────────────────────────────────────────────────────────────────
    87	# Step 0 — Session start
    88	# Reference: agent.md §4 Step 0. context.sh runs first (bus invokes
    89	# context.sh BEFORE cycle.sh per ADR-003 v2 bundle pattern); this script
    90	# emits the trigger row that anchors the session in decision_log.
    91	# ────────────────────────────────────────────────────────────────────────
    92	
    93	if [[ "${STEPS_TO_RUN}" == *0* ]]; then
    94	  hh_decision_trigger "session_start" "mode:${MODE}; agent:concierge"
    95	fi
    96	
    97	# ────────────────────────────────────────────────────────────────────────
    98	# Step 1 — Source detection (mode-dependent)
    99	# Reference: agent.md §4 Step 1. Three branches: webhook (parse payload),
   100	# poll (query Bullhorn since last poll), nurture-sweep (time-elapsed events).
   101	# Anti-duplicate window handled in Step 2.
   102	# ESC_LIFECYCLE_STATE_UNKNOWN per agent.md §6 row 5 if state transition not
   103	# in the 12-event taxonomy (escalation-codes.md catalogue addition flagged).
   104	# ────────────────────────────────────────────────────────────────────────
   105	
   106	if [[ "${STEPS_TO_RUN}" == *1* ]]; then
   107	  # TODO(W10-13): per-mode source detection
   108	  #   if [[ "${MODE}" == "webhook" ]]; then parse_bullhorn_webhook_payload; fi
   109	  #   if [[ "${MODE}" == "poll" ]]; then query_bullhorn_state_changes_since; fi
   110	  #   if [[ "${MODE}" == "nurture-sweep" ]]; then query_placements_for_time_elapsed; fi
   111	  # On state ∉ 12-event taxonomy: emit ESC_LIFECYCLE_STATE_UNKNOWN warn + skip
   112	  hh_decision_output "lifecycle_event_detected" "mode:${MODE}" \
   113	    "entity_type:STUB; bullhorn_id:STUB; state_from:STUB; state_to:STUB"
   114	fi
   115	
   116	# ────────────────────────────────────────────────────────────────────────
   117	# Step 2 — Anti-duplicate guard
   118	# Reference: agent.md §4 Step 2 + Q7 disposition. Query decision_log for
   119	# prior concierge_email_draft row for (candidate_id, payload.event_type)
   120	# in last 24h with phase ∈ ('output','action'). If prior draft was sent OR
   121	# is still pending consultant action AND send-completed → skip; if prior
   122	# draft never sent → allow new attempt.
   123	# ────────────────────────────────────────────────────────────────────────
   124	
   125	if [[ "${STEPS_TO_RUN}" == *2* ]]; then
   126	  # TODO(W10-13): SELECT decision_log WHERE agent_name='concierge'
   127	  #   AND action_type='concierge_email_draft'
   128	  #   AND payload->>'event_type'=<event_type>
   129	  #   AND created_at > now() - interval '24h'
   130	  hh_decision_output "anti_duplicate_check" "candidate:STUB:STUB" \
   131	    "duplicate_status:STUB; prior_send_completed:STUB"
   132	fi
   133	
   134	# ────────────────────────────────────────────────────────────────────────
   135	# Step 3 — Bullhorn context fetch
   136	# Reference: agent.md §4 Step 3. Pulls candidate + placement + client +
   137	# contact entities. ESC_RATE_LIMIT_HIT on 429; ESC_BULLHORN_AUTH on auth
   138	# fail; ESC_AGENT_OUTPUT_SHAPE if critical fields missing (no email/name).
   139	# ────────────────────────────────────────────────────────────────────────
   140	
   141	if [[ "${STEPS_TO_RUN}" == *3* ]]; then
   142	  # TODO(W10-13): @ifos/bullhorn entity fetches
   143	  #   bullhorn.get_candidate(candidate_id) → name, state, comms_history
   144	  #   bullhorn.get_placement(placement_id) → role, client, dates
   145	  #   bullhorn.get_client(client_id) → company, primary_contact
   146	  #   bullhorn.get_contact(contact_id) → name, email
   147	  # On critical-field-missing: hh_decision_action "validate_gate_a_fail" \
   148	  #   "candidate:<id>" "<hash>" "ESC_AGENT_OUTPUT_SHAPE; missing:email|name"
   149	  hh_decision_output "bullhorn_context_fetched" "candidate:STUB" \
   150	    "fields_present:STUB; rate_limit_remaining:STUB"
   151	fi
   152	
   153	# ────────────────────────────────────────────────────────────────────────
   154	# Step 4 — Addressee resolution (Gate A CRITICAL)
   155	# Reference: agent.md §4 Step 4 + §5 Gate A + ULTRAPLAN A6 line 566 verbatim
   156	# "correct addressee resolution; no candidates emailed under another's name".
   157	# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on mismatch.
   158	# ────────────────────────────────────────────────────────────────────────
   159	
   160	if [[ "${STEPS_TO_RUN}" == *4* ]]; then
   161	  # TODO(W10-13): assert recipient_email matches the candidate_id whose
   162	  # lifecycle is changing; cross-check against bullhorn.get_candidate.email.
   163	  # On mismatch: emit ESC_ADDRESSEE_MISMATCH + abort the draft pipeline.
   164	  hh_decision_output "addressee_resolved" "candidate:STUB" \
   165	    "recipient_role:STUB; addressee_resolution:STUB"
   166	fi
   167	
   168	# ────────────────────────────────────────────────────────────────────────
   169	# Step 5 — Comms-template selection
   170	# Reference: agent.md §4 Step 5. Per-tenant /vault/<slug>/concierge-templates/
   171	# library; fallback to shared/common-comms-templates.yaml.
   172	# ────────────────────────────────────────────────────────────────────────
   173	
   174	if [[ "${STEPS_TO_RUN}" == *5* ]]; then
   175	  # TODO(W10-13): resolve template by (event_type, recipient_role); read from
   176	  # tenant vault first, fall back to shared common.
   177	  hh_decision_output "template_selected" "event:STUB:STUB" \
   178	    "template_id:STUB; source:STUB"
   179	fi
   180	
   181	# ────────────────────────────────────────────────────────────────────────
   182	# Step 6 — Sensitive-event escalation routing
   183	# Reference: agent.md §4 Step 6. Set escalation_position=3 for rejection,
   184	# withdrawal, or on-hold (placement value >£10k). Else position=1.
   185	# Position drives the per-draft voice classifier threshold at Step 8.
   186	# ────────────────────────────────────────────────────────────────────────
   187	
   188	if [[ "${STEPS_TO_RUN}" == *6* ]]; then
   189	  # TODO(W10-13): if event_type IN ('rejection','withdrawal','on-hold' AND placement>£10k):
   190	  #   ESCALATION_POSITION=3
   191	  # else
   192	  #   ESCALATION_POSITION=1
   193	  hh_decision_output "escalation_position_set" "candidate:STUB" \
   194	    "position:STUB; rationale:STUB"
   195	fi
   196	
   197	# ────────────────────────────────────────────────────────────────────────
   198	# Step 7 — LLM draft generation
   199	# Reference: agent.md §4 Step 7. Prompt = event context + candidate state
   200	# history + voice corpus ANN-matched on event_type + tone rules + template.
   201	# Output → /vault/<tenant>/concierge-drafts/<draft_id>.md.
   202	# ESC_VOICE_DRIFT if classifier score < threshold after 3 retries (the actual
   203	# Gate A hard-fail expression is at Step 8 below via validate_gate_a_fail).
   204	# ────────────────────────────────────────────────────────────────────────
   205	
   206	if [[ "${STEPS_TO_RUN}" == *7* ]]; then
   207	  # TODO(W10-13): LLM call → write draft body to vault → emit:
   208	  #   DRAFT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/concierge-drafts/<draft_id>.md"
   209	  #   hh_decision_output "concierge_draft_rendered" "candidate:STUB:STUB" \
   210	  #     "vault_path:${DRAFT_PATH}; voice_score:STUB; words:STUB"
   211	  hh_decision_output "concierge_draft_rendered" "candidate:STUB:STUB" \
   212	    "vault_path:STUB; voice_score:STUB; words:STUB"
   213	fi
   214	
   215	# ────────────────────────────────────────────────────────────────────────
   216	# Step 8 — Voice + tone validation
   217	# Reference: agent.md §4 Step 8 + §5 Gate A. Position-specific thresholds:
   218	#   position 1: ≥0.75 ; position 2: ≥0.78 ; position 3: ≥0.82
   219	# On pass: emit concierge_email_draft (yellow tier; REGISTERED in policy).
   220	# On block-severity tone hit: ESC_TONE_RULE_VIOLATION (blocking).
   221	# ────────────────────────────────────────────────────────────────────────
   222	
   223	if [[ "${STEPS_TO_RUN}" == *8* ]]; then
   224	  # TODO(W10-13): bash validate.sh "${DRAFT_PATH}"; if exit 0:
   225	  #   hh_decision_action "concierge_email_draft" \
   226	  #     "candidate:<bullhorn_id>:<event_type>" "<payload_hash>" \
   227	  #     "voice_score:<N>; position:<P>; words:<W>; recipient:<email>"
   228	  # else: validate.sh already emitted validate_gate_a_fail; cycle.sh aborts the draft
   229	  hh_decision_action "concierge_email_draft" "candidate:STUB:STUB" "stub-hash" \
   230	    "voice_score:STUB; position:STUB; words:STUB; recipient:STUB"
   231	fi
   232	
   233	# ────────────────────────────────────────────────────────────────────────
   234	# Step 9 — SLA timing check (Gate B leading metric; NOT Gate A hard-fail)
   235	# Reference: agent.md §4 Step 9 + ADR-007 RATIFIED 2026-05-31.
   236	# elapsed = now() - event_timestamp; if >30min → ESC_CONCIERGE_SLA_MISS
   237	# (warn; aggregated to Gate B at 90% threshold). Per-draft hard-fail would
   238	# block legitimate polling-fallback delays.
   239	# ────────────────────────────────────────────────────────────────────────
   240	
   241	if [[ "${STEPS_TO_RUN}" == *9* ]]; then
   242	  # TODO(W10-13): ELAPSED=$(( $(date +%s) - EVENT_TIMESTAMP_EPOCH ))
   243	  # if (( ELAPSED > 1800 )); then
   244	  #   hh_decision_output "concierge_sla_miss" "candidate:<id>:<event>" \
   245	  #     "elapsed_seconds:${ELAPSED}; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct"
   246	  # fi
   247	  :
   248	fi
   249	
   250	# ────────────────────────────────────────────────────────────────────────
   251	# Step 10 — PII boundary check
   252	# Reference: agent.md §4 Step 10. No PII from other candidates / competitor
   253	# clients / compensation specifics outside candidate's record. On hit:
   254	# ESC_PII_LEAKAGE_RISK (blocking; operator + ifos_oncall).
   255	# ────────────────────────────────────────────────────────────────────────
   256	
   257	if [[ "${STEPS_TO_RUN}" == *10* ]]; then
   258	  # TODO(W10-13): regex sweep against firm-domain whitelist + competitor list
   259	  # + candidate-record allowlist; on hit:
   260	  # hh_decision_action "validate_gate_a_fail" "candidate:<id>" "<hash>" \

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/cleanup.sh | sed -n '1,160p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/validate.sh | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# shellcheck disable=SC2329
     3	# (_fail + _warn are not invoked in the W4 Day-26 skeleton — TODO(W10-13)
     4	#  blocks invoke them when the per-check impl lands. Keeping them defined
     5	#  so the skeleton matches the final shape + the build-slice author can fill
     6	#  the TODOs without re-declaring helpers.)
     7	#
     8	# Concierge agent — validate.sh (Gate A enforcement; W4 Day-26 SKELETON)
     9	#
    10	# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice completes the impl).
    11	# Reading order: agent.md §5 (Gate A) + §6 (16 ESC codes) + §1 Gate A thresholds
    12	# in the output contract first.
    13	#
    14	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is
    15	# the hard-fail gate that runs BETWEEN draft generation (cycle.sh Step 7) and
    16	# the autosend-bridge propose call (Step 11). If any check fails, validate.sh
    17	# exits non-zero + emits an ESC_* escalation row to decision_log; the draft
    18	# does NOT route to the bridge; cycle.sh aborts the draft pipeline.
    19	#
    20	# Invocation contract:
    21	#   bash validate.sh <draft_path>
    22	#
    23	# Inputs:
    24	#   - $1: path to the vault concierge-draft file (cycle.sh Step 7 wrote it)
    25	#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR,
    26	#          CTX_VOICE_CORPUS_ID, CTX_TONE_RULES (json string)
    27	#
    28	# Exit codes:
    29	#   0  All Gate A checks pass; cycle.sh proceeds to Step 8 action row + Step 11
    30	#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts the draft
    31	#   2  validate.sh invocation error (bad args, missing draft, env unset)
    32	#
    33	# Checks (per agent.md §5 Gate A):
    34	#   G1 — voice classifier score ≥ position-specific threshold
    35	#        (position 1: ≥0.75 ; position 2: ≥0.78 ; position 3: ≥0.82)
    36	#   G2 — addressee resolution: recipient matches candidate_id whose lifecycle
    37	#        is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed
    38	#        under another's name")
    39	#   G3 — no block-severity tone-rule violation
    40	#   G4 — no PII outside firm boundary (other candidates, competitors, comp specifics)
    41	#   G5 — anti-duplicate: no prior concierge_email_draft for same (candidate_id,
    42	#        event_type) in last 24h that already completed send
    43	
    44	set -uo pipefail
    45	
    46	# ────────────────────────────────────────────────────────────────────────
    47	# Pre-flight
    48	# ────────────────────────────────────────────────────────────────────────
    49	
    50	if [[ $# -lt 1 ]]; then
    51	  printf 'concierge/validate.sh: usage: validate.sh <draft_path>\n' >&2
    52	  exit 2
    53	fi
    54	
    55	readonly DRAFT="$1"
    56	
    57	if [[ ! -f "${DRAFT}" ]]; then
    58	  printf 'validate.sh: draft not found at %s\n' "${DRAFT}" >&2
    59	  exit 2
    60	fi
    61	
    62	if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
    63	  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
    64	  exit 2
    65	fi
    66	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    67	  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
    68	  exit 2
    69	fi
    70	
    71	# Resolve _shared/ helpers (4-candidate fallback; matches sibling pattern
    72	# post d7d52c5 smoke-hotfix).
    73	_SHARED_DIR=""
    74	for _candidate in \
    75	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    76	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    77	  "${CTX_AGENT_DIR}/../../_shared" \
    78	  "${CTX_AGENT_DIR}/../_shared" ; do
    79	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    80	    _SHARED_DIR="${_candidate}"
    81	    break
    82	  fi
    83	done
    84	if [[ -z "${_SHARED_DIR}" ]]; then
    85	  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
    86	  exit 2
    87	fi
    88	# shellcheck source=/dev/null
    89	source "${_SHARED_DIR}/hook-helpers.sh"
    90	
    91	# Track failures + warnings across all checks (collect all before exit for
    92	# richer audit; same pattern as cash-conductor/validate.sh).
    93	declare -a FAILURES=()
    94	declare -a WARNINGS=()
    95	
    96	_fail() {
    97	  FAILURES+=("$1")
    98	  printf '  ✗ %s\n' "$1" >&2
    99	}
   100	_warn() {
   101	  WARNINGS+=("$1")
   102	  printf '  ! %s\n' "$1" >&2
   103	}
   104	_ok() {
   105	  printf '  ✓ %s\n' "$1"
   106	}
   107	
   108	# ────────────────────────────────────────────────────────────────────────
   109	# G1 — voice classifier score ≥ position-specific threshold
   110	# Position 1 ≥0.75 ; Position 2 ≥0.78 ; Position 3 ≥0.82
   111	# Reference: agent.md §5 Gate A + §4 Step 8 + ULTRAPLAN A6 line 566 (amended)
   112	# ────────────────────────────────────────────────────────────────────────
   113	
   114	# TODO(W10-13): parse draft YAML frontmatter for voice_score + escalation_position;
   115	# compare against position-specific threshold; on fail emit ESC_VOICE_DRIFT
   116	# (warn per catalogue lines 120-125; routes operator_chat_id for ALL positions —
   117	# position-specific paging would need a catalogue amendment) AND emit
   118	# hh_decision_action "validate_gate_a_fail" so cycle.sh aborts.
   119	_ok "G1: voice classifier position-threshold — SKELETON (W10-13 wires)"
   120	
   121	# ────────────────────────────────────────────────────────────────────────
   122	# G2 — addressee resolution: recipient matches candidate_id whose lifecycle
   123	# is changing. ULTRAPLAN A6 line 566 verbatim: "no candidates emailed under
   124	# another's name". Reference: agent.md §4 Step 4 + §5 Gate A.
   125	# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on fail.
   126	# ────────────────────────────────────────────────────────────────────────
   127	
   128	# TODO(W10-13): parse draft YAML for recipient + candidate_id; cross-check
   129	# against bullhorn.get_candidate(candidate_id).email; on mismatch:
   130	# hh_decision_action "validate_gate_a_fail" "candidate:<id>" "<hash>" \
   131	#   "ESC_ADDRESSEE_MISMATCH; recipient:<email>; expected:<candidate-email>"
   132	_ok "G2: addressee resolution — SKELETON (W10-13 wires Bullhorn cross-check)"
   133	
   134	# ────────────────────────────────────────────────────────────────────────
   135	# G3 — no block-severity tone-rule violation
   136	# Reference: agent.md §4 Step 8 + §6 ESC_TONE_RULE_VIOLATION (blocking;
   137	# operator + ifos_oncall).
   138	# ────────────────────────────────────────────────────────────────────────
   139	
   140	# TODO(W10-13): @ifos/tone-rules apply_rules(draft_body, tenant_tone_rules);
   141	# on block-severity hit: hh_decision_action "validate_gate_a_fail" ... \
   142	#   "ESC_TONE_RULE_VIOLATION; rule_id:<id>; matched_text:<excerpt>"
   143	_ok "G3: block-severity tone-rules — SKELETON (W10-13 wires rule engine)"
   144	
   145	# ────────────────────────────────────────────────────────────────────────
   146	# G4 — no PII outside firm boundary
   147	# Reference: agent.md §4 Step 10 + §6 ESC_PII_LEAKAGE_RISK (blocking).
   148	# Three classes: other-candidate PII, competitor-client PII, compensation
   149	# specifics outside candidate's record.
   150	# ────────────────────────────────────────────────────────────────────────
   151	
   152	# TODO(W10-13): regex sweep against firm-domain whitelist + competitor list
   153	# + candidate-record allowlist; on hit emit ESC_PII_LEAKAGE_RISK +
   154	# validate_gate_a_fail with payload.class IN ('other_candidate'|'competitor'|'comp_specifics')
   155	_ok "G4: PII boundary check — SKELETON (W10-13 wires firm + competitor lists)"
   156	
   157	# ────────────────────────────────────────────────────────────────────────
   158	# G5 — anti-duplicate: no prior concierge_email_draft for same
   159	# (candidate_id, event_type) in last 24h with send-completed status.
   160	# Reference: agent.md §4 Step 2. Defence-in-depth: Step 2 already checked,
   161	# but a webhook re-fire between Step 2 and validate.sh could insert a new
   162	# row in the window — re-check at validate time prevents the race.
   163	# ────────────────────────────────────────────────────────────────────────
   164	
   165	# TODO(W10-13): SELECT from decision_log per Step 2 query but at validate time;
   166	# on hit emit ESC_AUTOSEND_RACE warn-tier + validate_gate_a_fail
   167	_ok "G5: anti-duplicate re-check — SKELETON (W10-13 wires SQL)"
   168	
   169	# ────────────────────────────────────────────────────────────────────────
   170	# Verdict + audit-row emission
   171	# ────────────────────────────────────────────────────────────────────────
   172	
   173	printf '\nValidate Gate A: '
   174	if [[ ${#FAILURES[@]} -gt 0 ]]; then
   175	  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
   176	  # TODO(W10-13): per-failure routing — different ESC code per failure class:
   177	  #   G1 → ESC_VOICE_DRIFT (warn)
   178	  #   G2 → ESC_ADDRESSEE_MISMATCH (blocking)
   179	  #   G3 → ESC_TONE_RULE_VIOLATION (blocking)
   180	  #   G4 → ESC_PII_LEAKAGE_RISK (blocking)
   181	  #   G5 → ESC_AUTOSEND_RACE (warn; race_class=duplicate_payload)
   182	  # hh_decision_action "validate_gate_a_fail" "tenant:${CTX_TENANT_SLUG}" payload_hash \
   183	  #   "ESC_<class>; agent_name:concierge; failures:${#FAILURES[@]}"
   184	  exit 1
   185	fi
   186	printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
   187	exit 0

 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Concierge agent — cleanup.sh (post-run state purge; W4 Day-26 SKELETON)
     3	#
     4	# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs
     5	#         with live cache-purge + reset calls).
     6	# Reading order: agent.md §4 Step 15 (session close) + §6 ESC mappings first.
     7	#
     8	# Per agent.md §3 actions list: Concierge's cleanup action_type is
     9	# `concierge_cleanup` (green tier — internal-only audit row recording
    10	# cache-purge status + workspace cleanup; no external comms).
    11	#
    12	# Per agents/_shared/autosend-policy.yaml: `concierge_cleanup` is QUEUED for
    13	# registration at W10-13 build start (per tools.yaml status table). Once
    14	# registered + the W10-13 build wires real purge logic, this script switches
    15	# from hh_decision_output to hh_decision_action for proper tier classification.
    16	#
    17	# Invocation contract:
    18	#   bash cleanup.sh
    19	#
    20	# Inputs (env):
    21	#   CTX_AGENT_DIR, CTX_TENANT_SLUG, CTX_AGENT_NAME (already set by cycle.sh/context.sh)
    22	#
    23	# Side effects (W10-13 build slice):
    24	#   - Purge ~/.ifos-cache/bullhorn/* older than 24h (transient HTTP cache; keeps tokens)
    25	#   - Purge ~/.ifos-cache/microsoft-graph/* older than 24h
    26	#   - Purge ~/.ifos-cache/gmail/* older than 24h
    27	#   - Reset in-process rate-limit buckets via @ifos/{bullhorn,microsoft-graph,gmail}
    28	#     resetRateLimit() — but rate-limit is per-process so process-exit handles it
    29	#
    30	# What cleanup.sh does NOT touch:
    31	#   - Token files at ~/.ifos-local-vault/<tenant>/{bullhorn,msgraph,gmail}-tokens-*.json (load-bearing)
    32	#   - Vault concierge drafts at /vault/<tenant>/concierge-drafts/ (kept for audit)
    33	#   - decision_log rows (append-only per T5 tenancy invariant)
    34	
    35	set -euo pipefail
    36	
    37	# ────────────────────────────────────────────────────────────────────────
    38	# Pre-flight: CTX env + _shared/ helper resolution
    39	# ────────────────────────────────────────────────────────────────────────
    40	
    41	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    42	  printf 'concierge/cleanup.sh: CTX_AGENT_DIR unset\n' >&2
    43	  exit 2
    44	fi
    45	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    46	  printf 'concierge/cleanup.sh: CTX_TENANT_SLUG unset\n' >&2
    47	  exit 2
    48	fi
    49	: "${CTX_AGENT_NAME:=concierge}"
    50	
    51	# Resolve _shared/ helpers (4-candidate fallback; matches sibling pattern)
    52	_SHARED_DIR=""
    53	for _candidate in \
    54	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    55	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    56	  "${CTX_AGENT_DIR}/../../_shared" \
    57	  "${CTX_AGENT_DIR}/../_shared" ; do
    58	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    59	    _SHARED_DIR="${_candidate}"
    60	    break
    61	  fi
    62	done
    63	if [[ -z "${_SHARED_DIR}" ]]; then
    64	  printf 'cleanup.sh: cannot locate _shared/ helpers\n' >&2
    65	  exit 1
    66	fi
    67	# shellcheck source=/dev/null
    68	source "${_SHARED_DIR}/hook-helpers.sh"
    69	
    70	# ────────────────────────────────────────────────────────────────────────
    71	# Step 1 — Transient HTTP cache purge (per-provider; >24h entries only)
    72	# ────────────────────────────────────────────────────────────────────────
    73	
    74	# Exported so the W10-13 build-slice can extend the find -delete logic via
    75	# child processes without re-resolving the env var fallback chain.
    76	export BULLHORN_CACHE_DIR="${IFOS_BULLHORN_CACHE_DIR:-${HOME}/.ifos-cache/bullhorn}"
    77	export MSGRAPH_CACHE_DIR="${IFOS_MSGRAPH_CACHE_DIR:-${HOME}/.ifos-cache/microsoft-graph}"
    78	export GMAIL_CACHE_DIR="${IFOS_GMAIL_CACHE_DIR:-${HOME}/.ifos-cache/gmail}"
    79	
    80	# TODO(W10-13): replace these STUB counts with actual find -delete invocations
    81	# that prune > 24h entries. Skeleton emits zero so the audit row shape is
    82	# preserved for the build-slice author.
    83	BULLHORN_PURGED=0
    84	MSGRAPH_PURGED=0
    85	GMAIL_PURGED=0
    86	# When ready, replace with the real purge logic:
    87	#   if [[ -d "${BULLHORN_CACHE_DIR}" ]]; then
    88	#     BULLHORN_PURGED=$(find "${BULLHORN_CACHE_DIR}" -type f -mtime +1 -delete -print 2>/dev/null | wc -l | tr -d ' ')
    89	#   fi
    90	#   (same for MSGRAPH_CACHE_DIR + GMAIL_CACHE_DIR)
    91	
    92	# ────────────────────────────────────────────────────────────────────────
    93	# Step 2 — Emit green-tier audit row (per agent.md §3 actions list)
    94	# ────────────────────────────────────────────────────────────────────────
    95	
    96	TOTAL_PURGED=$((BULLHORN_PURGED + MSGRAPH_PURGED + GMAIL_PURGED))
    97	
    98	# TODO(W10-13): once concierge_cleanup action_type is registered in
    99	# autosend-policy.yaml (currently QUEUED per tools.yaml status table), switch
   100	# from hh_decision_output to hh_decision_action for proper tier classification.
   101	hh_decision_output "concierge_cleanup" "tenant:${CTX_TENANT_SLUG}" \
   102	  "bullhorn_cache_purged:${BULLHORN_PURGED}; msgraph_cache_purged:${MSGRAPH_PURGED}; gmail_cache_purged:${GMAIL_PURGED}; total:${TOTAL_PURGED}; mode:SKELETON"
   103	
   104	# Operator-readable trace
   105	printf '[concierge cleanup.sh] tenant=%s purged total=%d (bullhorn=%d msgraph=%d gmail=%d) mode=SKELETON\n' \
   106	  "${CTX_TENANT_SLUG}" "${TOTAL_PURGED}" "${BULLHORN_PURGED}" "${MSGRAPH_PURGED}" "${GMAIL_PURGED}"
   107	
   108	exit 0

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/context.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Concierge agent — context.sh (pre-cycle hydration; W4 Day-26 SKELETON)
     3	#
     4	# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs
     5	#         with real provider config + tenant_adapters reads).
     6	# Reading order: agent.md §2 (invocation surface) + §4 Step 0 (session start)
     7	# + §7 (voice + tone constraints) first.
     8	#
     9	# Per ADR-003 v2 agent-bundle pattern: bus invokes context.sh BEFORE cycle.sh
    10	# at session start. context.sh hydrates session-scoped CTX_* env vars that
    11	# cycle.sh + validate.sh read, then emits the mandatory session_start trigger
    12	# row to anchor the session in decision_log.
    13	#
    14	# Invocation contract:
    15	#   bash context.sh
    16	#
    17	# Inputs (env from bus):
    18	#   CTX_AGENT_DIR        — agent's directory (this file's dirname)
    19	#   CTX_TENANT_SLUG      — tenant the run targets
    20	#   CTX_CONCIERGE_MODE   — webhook | poll | nurture-sweep | manual
    21	#
    22	# Side effects (W10-13 build slice):
    23	#   - Refresh Bullhorn OAuth (per agent.md §4 Step 0 + Q-12 disposition)
    24	#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
    25	#   - Load voice corpus pgvector index for CTX_VOICE_CORPUS_ID
    26	#   - Load tone-rules YAML for tenant
    27	#   - Resolve operator_telegram_chat_id from tenant_adapters.config
    28	#   - Load tenant comms-template library path
    29	#   - Hydrate addressee-resolution allowlists (firm-domain whitelist +
    30	#     competitor list for Gate A G2/G4 enforcement)
    31	#
    32	# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
    33	#   CTX_AGENT_NAME                       — "concierge"
    34	#   CTX_EMAIL_CHANNEL                    — "microsoft-graph" | "gmail"
    35	#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID
    36	#   CTX_VOICE_CORPUS_ID                  — pgvector index ref
    37	#   CTX_TONE_RULES_PATH                  — vault path to tone-rules YAML
    38	#   CTX_COMMS_TEMPLATE_LIBRARY_PATH      — /vault/<slug>/concierge-templates/
    39	#   CTX_BULLHORN_TOKEN_STATE             — fresh | refreshed | failed
    40	#   CTX_EMAIL_PROVIDER_TOKEN_STATE       — fresh | refreshed | failed
    41	
    42	set -euo pipefail
    43	
    44	# ────────────────────────────────────────────────────────────────────────
    45	# Pre-flight: CTX env + _shared/ helper resolution
    46	# ────────────────────────────────────────────────────────────────────────
    47	
    48	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    49	  printf 'concierge/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
    50	  exit 2
    51	fi
    52	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    53	  printf 'concierge/context.sh: CTX_TENANT_SLUG unset\n' >&2
    54	  exit 2
    55	fi
    56	export CTX_AGENT_NAME="concierge"
    57	
    58	# 4-candidate _shared/ helper fallback (matches sibling agents post d7d52c5).
    59	_SHARED_DIR=""
    60	for _candidate in \
    61	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    62	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    63	  "${CTX_AGENT_DIR}/../../_shared" \
    64	  "${CTX_AGENT_DIR}/../_shared" ; do
    65	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    66	    _SHARED_DIR="${_candidate}"
    67	    break
    68	  fi
    69	done
    70	if [[ -z "${_SHARED_DIR}" ]]; then
    71	  printf 'context.sh: cannot locate _shared/ helpers\n' >&2
    72	  exit 1
    73	fi
    74	# shellcheck source=/dev/null
    75	source "${_SHARED_DIR}/hook-helpers.sh"
    76	
    77	# ────────────────────────────────────────────────────────────────────────
    78	# Step 1 — Email channel resolution (MS Graph OR Gmail per tenant)
    79	# ────────────────────────────────────────────────────────────────────────
    80	
    81	# TODO(W10-13): SELECT config->>'email_channel' FROM tenant_adapters WHERE tenant_slug=$1
    82	# Default: microsoft-graph (most common in UK recruitment per CSM survey).
    83	export CTX_EMAIL_CHANNEL="${IFOS_FORCE_EMAIL_CHANNEL:-microsoft-graph}"
    84	
    85	# ────────────────────────────────────────────────────────────────────────
    86	# Step 2 — Bullhorn OAuth refresh
    87	# ────────────────────────────────────────────────────────────────────────
    88	
    89	# TODO(W10-13): @ifos/bullhorn refreshTokens(); on success export CTX_BULLHORN_TOKEN_STATE=refreshed
    90	# On 6+ consecutive failures: emit ESC_BULLHORN_AUTH (blocking) + exit 1
    91	export CTX_BULLHORN_TOKEN_STATE="STUB"
    92	
    93	# ────────────────────────────────────────────────────────────────────────
    94	# Step 3 — Email provider OAuth refresh (per channel)
    95	# ────────────────────────────────────────────────────────────────────────
    96	
    97	# TODO(W10-13):
    98	#   if [[ "${CTX_EMAIL_CHANNEL}" == "microsoft-graph" ]]; then
    99	#     @ifos/microsoft-graph refreshTokens() → on fail ESC_MS_GRAPH_AUTH blocking
   100	#   else
   101	#     @ifos/gmail refreshTokens() → on fail ESC_GMAIL_AUTH blocking
   102	#   fi
   103	export CTX_EMAIL_PROVIDER_TOKEN_STATE="STUB"
   104	
   105	# ────────────────────────────────────────────────────────────────────────
   106	# Step 4 — Voice corpus + tone rules + comms-template library
   107	# ────────────────────────────────────────────────────────────────────────
   108	
   109	# TODO(W10-13): resolve via tenant_adapters.config; default fallback chain.
   110	export CTX_VOICE_CORPUS_ID="${IFOS_FORCE_VOICE_CORPUS_ID:-default}"
   111	export CTX_TONE_RULES_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/tone-rules.yaml"
   112	export CTX_COMMS_TEMPLATE_LIBRARY_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/concierge-templates/"
   113	
   114	# ────────────────────────────────────────────────────────────────────────
   115	# Step 5 — Operator routing (Telegram chat ID for autosend-bridge per D1-B)
   116	# ────────────────────────────────────────────────────────────────────────
   117	
   118	# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
   119	# WHERE tenant_slug=$1 (per D1-B doc §"Implementation surface" item 5 — already
   120	# supported by existing Telegram surface; no new schema needed).
   121	export CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-STUB}"
   122	
   123	# ────────────────────────────────────────────────────────────────────────
   124	# Step 6 — Session-start trigger row (mandatory; anchors session in decision_log)
   125	# ────────────────────────────────────────────────────────────────────────
   126	
   127	hh_decision_trigger "session_start" \
   128	  "agent:concierge; tenant:${CTX_TENANT_SLUG}; mode:${CTX_CONCIERGE_MODE:-webhook}; email_channel:${CTX_EMAIL_CHANNEL}"
   129	
   130	# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
   131	printf '[concierge context.sh] tenant=%s channel=%s bullhorn_token=%s email_token=%s voice_corpus=%s\n' \
   132	  "${CTX_TENANT_SLUG}" "${CTX_EMAIL_CHANNEL}" "${CTX_BULLHORN_TOKEN_STATE}" \
   133	  "${CTX_EMAIL_PROVIDER_TOKEN_STATE}" "${CTX_VOICE_CORPUS_ID}"
   134	
   135	exit 0

codex
There’s a concrete status mismatch emerging: the artefact says some prerequisites are unresolved while the repository contains later D1-B bridge material. I’m checking whether that mismatch is enough to reject, alongside any hard policy violations.
exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-31-d1-founder-decision.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Founder Decision D1 — autosend orange-tier path
     2	
     3	**Status:** Accepted (founder-arbitrated 2026-05-31 via explicit delegation: *"i pretty much trust your decision making for the technical build stuff"*).
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
    53	5. **Tenant config — schema-work pending.** The natural storage location for the per-tenant operator Telegram chat-id is `tenant_adapters.config`, BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 — and `operator_telegram_chat_id` is NOT currently in the 6-key allowlist (`cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the 2026-05-31 Janitor key, `blocked_recipients`). Resolution path: **W10-13 Concierge build slice lands a v0.4 supplement** adding `operator_telegram_chat_id` to the allowlist (type: string; required: false; set_by: tenant-admin; read_by: concierge + cash-conductor for the autosend-bridge consumer). Until then, the bridge consumer (`@ifos/autosend-bridge-telegram`) takes the chat-id as a function argument rather than reading it from tenant_adapters — the function-arg shim is already in place per the package scaffold landed 2026-06-01 (commit `9b282d8`). This decision-doc does NOT block on the schema work; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend); the storage-location detail is a W10-13 implementation question.
    54	
    55	---
    56	
    57	## Codex ratification
    58	
    59	This decision doc ratifies via `.codex/ratification/review-architecture-decision.md` skill. Currently in flight under **cluster G** (`bash scripts/run-codex-ratification.sh --cluster G`); session-by-session ratification status is tracked in the closing Status-update line.
    60	
    61	## Consequences
    62	
    63	- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
    64	- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10-13 lands the autosend-bridge production wiring."
    65	- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: ADR-007 Accepted + Codex RATIFIED (DONE 2026-05-31 + Round 3), pilot LOI (PENDING), Bullhorn A+B (PENDING), founder approves §9 Q2-Q6 (PENDING).
    66	- **Schema impact: v0.4 supplement required (deferred to W10-13 Concierge build slice).** D1-B requires a per-tenant operator-Telegram-chat-id storage location. `tenant_adapters.config` is the natural home BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 and `operator_telegram_chat_id` is NOT in the current allowlist (see implementation surface item 5 for the full rationale + interim function-arg-mode workaround). The schema work + migration land in the W10-13 Concierge build slice as part of bridge-production-wiring; the decision-doc itself is structurally complete without that schema work. The previously-stated "No schema impact" claim has been removed — it was inconsistent with implementation surface item 5.
    67	- **No additional API keys/signups for the founder vault.** Day-4 provisioning (`docs/runbooks/day-4-provisioning.md` §6.5) creates the `_secrets.env` SKELETON only (touched empty at mode 0600); the Telegram bot token is populated by founder bootstrap (covered separately by tenant onboarding playbook — NOT Day-4), and the per-tenant operator chat-id is populated by tenant onboarding (W10-13 build slice; see implementation surface item 5 above). Once both are in place, no recurring credentials work — the bot token doesn't rotate per send; the chat-id is per-tenant-stable.
    68	- **Schema-before-code discipline — interim acceptance.** The five rules (master brief §1) state schema-before-code. Today's state has the bridge package scaffold + consumer wiring landed BEFORE the schema supplement. The interim resolution is acceptable because the consumers run in **function-arg mode only** (chat-id passed as function argument, NOT read from `tenant_adapters`) — so no consumer code actually attempts to read the not-yet-allowlisted key. The schema-before-code rule is respected at the runtime level (no schema-violating read happens); the consumer scaffolding is fine to exist as long as the function-arg-only constraint holds until the v0.4 supplement lands.
    69	
    70	---
    71	
    72	*End of D1 decision doc.*
    73	
    74	---
    75	
    76	**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **in FUNCTION-ARG MODE only**, no `tenant_adapters.config.operator_telegram_chat_id` read attempts until the v0.4 schema supplement lands in the Concierge W10-13 build slice; Codex ratification currently in flight under cluster G (R2 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc).

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "ls docs/decisions | rg 'd1|D1|2026-05-31|autosend|ADR-007'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
2026-05-31-d1-founder-decision.md
ADR-007-concierge-gate-a-30min-sla-hybrid.md
autosend-approval-bridge-spec.md
autosend-safety-policy.md

exec
/bin/zsh -lc "find agents/recruitment/concierge/fixtures -type f -maxdepth 1 -print -exec wc -l {} \\;" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml
     124 agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml
agents/recruitment/concierge/fixtures/01-primary.yaml
     118 agents/recruitment/concierge/fixtures/01-primary.yaml
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml
     148 agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '189,263p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   189	  recent_edit:
   190	    description: |
   191	      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
   192	    bullhorn_source: none (IFOS-derived from operator's approve/edit UX)
   193	    v1_0_agent_access:
   194	      - voice-drift-canary cron (R — drift detection)
   195	      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
   196	      - LoRA pipeline v2.0 (R — SFT pair generation)
   197	    canonical_fields:
   198	      tenant_slug:
   199	        type: string
   200	        required: true
   201	        source: IFOS-derived (set at row insert from CTX_TENANT_SLUG)
   202	      agent_name:
   203	        type: string
   204	        required: true
   205	        source: IFOS-derived (from CTX_AGENT_NAME at edit-capture time)
   206	        notes: |
   207	          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
   208	      action_type:
   209	        type: string
   210	        required: true
   211	        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
   212	        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
   213	      target_entity_type:
   214	        type: string
   215	        required: false
   216	        source: IFOS-derived (entity context at edit time; nullable for system-level edits)
   217	        notes: |
   218	          Optional pointer to the entity the draft was about (e.g. "candidate", "client"). Enables linking voice drift to entity classes (some entity types correlate with more drift).
   219	      target_entity_id:
   220	        type: string
   221	        required: false
   222	        source: IFOS-derived (entity ID at edit time; Bullhorn ID or IFOS slug)
   223	        notes: bullhorn_id or IFOS slug. Used in the entity_links join below.
   224	      original_text:
   225	        type: string
   226	        required: true
   227	        source: IFOS-derived (agent's draft as produced; capped at 8192 chars)
   228	        notes: |
   229	          The agent's draft as produced. **Stored verbatim** (privacy posture: this is the agent's own output, not external PII). Length-capped at 8192 chars; if longer, suffix truncated with "[...]" marker.
   230	      edited_text:
   231	        type: string
   232	        required: false
   233	        source: IFOS-derived (consultant's final version at approve time; null when approved verbatim)
   234	        notes: |
   235	          The consultant's final version. Nullable when the consultant approved verbatim (no edit). Length-capped at 8192 chars.
   236	      edit_distance:
   237	        type: integer
   238	        required: false
   239	        source: IFOS-derived (Levenshtein computed at insert; null when edited_text null)
   240	        notes: |
   241	          Computed Levenshtein distance between original_text and edited_text. NULL when edited_text is NULL (approved verbatim). Computed at insert time by the operator UX; not derived at query time.
   242	      resolution:
   243	        type: string
   244	        required: true
   245	        source: IFOS-derived (operator UX action at approve/reject time)
   246	        notes: |
   247	          Enum: ["approved_verbatim", "approved_after_edit", "rejected", "deferred"]. `deferred` indicates operator returned to inbox without resolving (4h timeout case).
   248	      resolved_at:
   249	        type: timestamp
   250	        required: true
   251	        source: IFOS-derived (timestamped at operator action)
   252	      tone_rules_triggered:
   253	        type: array
   254	        required: false
   255	        source: IFOS-derived (Gate-A fires recorded by validate.sh + hh_decision_action)
   256	        notes: |
   257	          Items: tone_rule.rule_id values that fired in Gate A. Empty array = clean pass. Drives "which rules are the agent struggling with" reporting.
   258	    notes: |
   259	      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
   260	
   261	# ============================================================================
   262	# §2 — Pgvector index (1)
   263	# ============================================================================

exec
/bin/zsh -lc 'rg -n "operator_telegram_chat_id|email_channel" docs/verticals/recruitment/vertical-schema*.yaml migrations agents/recruitment/concierge -S' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: migrations: No such file or directory (os error 2)
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:37:  email_channel: microsoft-graph
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:38:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/01-primary.yaml:29:  email_channel: microsoft-graph
agents/recruitment/concierge/fixtures/01-primary.yaml:30:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:34:  email_channel: microsoft-graph
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:35:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/context.sh:24:#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
agents/recruitment/concierge/context.sh:27:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:34:#   CTX_EMAIL_CHANNEL                    — "microsoft-graph" | "gmail"
agents/recruitment/concierge/context.sh:35:#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID
agents/recruitment/concierge/context.sh:81:# TODO(W10-13): SELECT config->>'email_channel' FROM tenant_adapters WHERE tenant_slug=$1
agents/recruitment/concierge/context.sh:83:export CTX_EMAIL_CHANNEL="${IFOS_FORCE_EMAIL_CHANNEL:-microsoft-graph}"
agents/recruitment/concierge/context.sh:98:#   if [[ "${CTX_EMAIL_CHANNEL}" == "microsoft-graph" ]]; then
agents/recruitment/concierge/context.sh:118:# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
agents/recruitment/concierge/context.sh:121:export CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-STUB}"
agents/recruitment/concierge/context.sh:128:  "agent:concierge; tenant:${CTX_TENANT_SLUG}; mode:${CTX_CONCIERGE_MODE:-webhook}; email_channel:${CTX_EMAIL_CHANNEL}"
agents/recruitment/concierge/context.sh:132:  "${CTX_TENANT_SLUG}" "${CTX_EMAIL_CHANNEL}" "${CTX_BULLHORN_TOKEN_STATE}" \
agents/recruitment/concierge/cycle.sh:290:    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/concierge/cycle.sh:345:  #   if tenant_adapters.config.email_channel == 'microsoft-graph':

exec
/bin/zsh -lc 'rg -n "approved_verbatim|approved_after_edit|approve-edit|operator_telegram_chat_id|email_channel" docs agents packages -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:247:          Enum: ["approved_verbatim", "approved_after_edit", "rejected", "deferred"]. `deferred` indicates operator returned to inbox without resolving (4h timeout case).
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:151:  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:35:  operator_telegram_chat_id: "operator-test-chat-id"
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:23:- Telegram bot token from `_secrets.env` (existing per Day-4 provisioning); operator chat ID from `tenant_adapters.config.operator_telegram_chat_id` (canonical config key)
agents/recruitment/cash-conductor/cycle.sh:242:    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
docs/operations/w4-bilateral-pass-6-agent-md.md:90:### Finding 2. `decision_log.outcome='approved_after_edit'` is wrong field
docs/operations/w4-bilateral-pass-6-agent-md.md:92:  - **Codex says:** "Line 59 says tacit notes are harvested from `decision_log` rows with `outcome='approved_after_edit'`, but the schema only documents `decision_log` as `agent_name`, `phase`, and `payload JSONB`; `approved_after_edit` is the `recent_edit.resolution` enum in v0.2 supplement §1.3. Fix §3 to harvest from `recent_edit.resolution='approved_after_edit'` and use `decision_log` only for action-context joins."
agents/recruitment/janitor/agent.md:17:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:60:| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:141:     AND resolution='approved_after_edit' AND tenant_slug=$tenant
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:37:  email_channel: microsoft-graph
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:38:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/01-primary.yaml:29:  email_channel: microsoft-graph
agents/recruitment/concierge/fixtures/01-primary.yaml:30:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:34:  email_channel: microsoft-graph
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:35:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/cycle.sh:290:    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/concierge/cycle.sh:345:  #   if tenant_adapters.config.email_channel == 'microsoft-graph':
agents/recruitment/concierge/context.sh:24:#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
agents/recruitment/concierge/context.sh:27:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:34:#   CTX_EMAIL_CHANNEL                    — "microsoft-graph" | "gmail"
agents/recruitment/concierge/context.sh:35:#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID
agents/recruitment/concierge/context.sh:81:# TODO(W10-13): SELECT config->>'email_channel' FROM tenant_adapters WHERE tenant_slug=$1
agents/recruitment/concierge/context.sh:83:export CTX_EMAIL_CHANNEL="${IFOS_FORCE_EMAIL_CHANNEL:-microsoft-graph}"
agents/recruitment/concierge/context.sh:98:#   if [[ "${CTX_EMAIL_CHANNEL}" == "microsoft-graph" ]]; then
agents/recruitment/concierge/context.sh:118:# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
agents/recruitment/concierge/context.sh:121:export CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-STUB}"
agents/recruitment/concierge/context.sh:128:  "agent:concierge; tenant:${CTX_TENANT_SLUG}; mode:${CTX_CONCIERGE_MODE:-webhook}; email_channel:${CTX_EMAIL_CHANNEL}"
agents/recruitment/concierge/context.sh:132:  "${CTX_TENANT_SLUG}" "${CTX_EMAIL_CHANNEL}" "${CTX_BULLHORN_TOKEN_STATE}" \
agents/recruitment/concierge/agent.md:321:- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`. (per ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:432:| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
docs/decisions/2026-05-31-d1-founder-decision.md:53:5. **Tenant config — schema-work pending.** The natural storage location for the per-tenant operator Telegram chat-id is `tenant_adapters.config`, BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 — and `operator_telegram_chat_id` is NOT currently in the 6-key allowlist (`cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the 2026-05-31 Janitor key, `blocked_recipients`). Resolution path: **W10-13 Concierge build slice lands a v0.4 supplement** adding `operator_telegram_chat_id` to the allowlist (type: string; required: false; set_by: tenant-admin; read_by: concierge + cash-conductor for the autosend-bridge consumer). Until then, the bridge consumer (`@ifos/autosend-bridge-telegram`) takes the chat-id as a function argument rather than reading it from tenant_adapters — the function-arg shim is already in place per the package scaffold landed 2026-06-01 (commit `9b282d8`). This decision-doc does NOT block on the schema work; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend); the storage-location detail is a W10-13 implementation question.
docs/decisions/2026-05-31-d1-founder-decision.md:66:- **Schema impact: v0.4 supplement required (deferred to W10-13 Concierge build slice).** D1-B requires a per-tenant operator-Telegram-chat-id storage location. `tenant_adapters.config` is the natural home BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 and `operator_telegram_chat_id` is NOT in the current allowlist (see implementation surface item 5 for the full rationale + interim function-arg-mode workaround). The schema work + migration land in the W10-13 Concierge build slice as part of bridge-production-wiring; the decision-doc itself is structurally complete without that schema work. The previously-stated "No schema impact" claim has been removed — it was inconsistent with implementation surface item 5.
docs/decisions/2026-05-31-d1-founder-decision.md:76:**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **in FUNCTION-ARG MODE only**, no `tenant_adapters.config.operator_telegram_chat_id` read attempts until the v0.4 schema supplement lands in the Concierge W10-13 build slice; Codex ratification currently in flight under cluster G (R2 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc).
packages/utilities/autosend-bridge-telegram/src/bridge.ts:47:  if (!input.operator_telegram_chat_id) {
packages/utilities/autosend-bridge-telegram/src/bridge.ts:48:    throw new BridgeInputError("operator_telegram_chat_id is required");
packages/utilities/autosend-bridge-telegram/src/bridge.ts:85:      chat_id: input.operator_telegram_chat_id,
packages/utilities/autosend-bridge-telegram/src/types.ts:30:  /** Telegram chat ID for the tenant's operator (from tenant_adapters.config.operator_telegram_chat_id). */
packages/utilities/autosend-bridge-telegram/src/types.ts:31:  operator_telegram_chat_id: string;
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:21:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:130:      proposeApproval({ ...validInput, operator_telegram_chat_id: "" }, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:21:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:14:  operator_telegram_chat_id: "987654321",

codex
I’ve got enough for a verdict. The decisive problems are not prose polish: they are inconsistent audit payload contracts, schema-before-code misses around tenant config, and stale status claims after D1 was accepted.
exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '355,430p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   355	# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
   356	# Emits the standard autosend decision_log row with payload.tier set.
   357	autosend_emit_decision_log() {
   358	  local phase="$1"
   359	  local tier="$2"
   360	  local action_type="$3"
   361	  local target="$4"
   362	  local payload_hash="$5"
   363	  local payload_preview="$6"
   364	  local reason_or_status="${7:-}"
   365	
   366	  local payload
   367	  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
   368	    "$(_hh_json_escape "${tier}")" \
   369	    "$(_hh_json_escape "${action_type}")" \
   370	    "$(_hh_json_escape "${target}")" \
   371	    "$(_hh_json_escape "${payload_hash}")" \
   372	    "$(_hh_json_escape "${payload_preview}")" \
   373	    "$([ -z "${reason_or_status}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason_or_status}")")" \
   374	    "$([ "${tier}" = "red" ] || [ "${tier}" = "fail-safe-red" ] && printf '"%s"' "$(_hh_json_escape "${reason_or_status}")" || echo "null")" \
   375	    "${HH_POLICY_VERSION_SHA:-unknown}")
   376	  _hh_emit_row "${phase}" "${tier}" "${reason_or_status}" "${payload}"
   377	}
   378	
   379	# autosend_escalate <ESC_CODE> [<key=value>...]
   380	# Writes the ESC row + dispatches Telegram via primitive-5 helper. Catalogue
   381	# lookup is permissive — unknown codes are emitted with phase='gating_failed'
   382	# + ESC_AUTOSEND_POLICY_LOOKUP_FAILED meta-escalation.
   383	autosend_escalate() {
   384	  local code="$1"
   385	  shift
   386	
   387	  if ! _hh_validate_esc_code "${code}"; then
   388	    printf 'autosend_escalate: unknown ESC code: %s\n' "${code}" >&2
   389	    local meta_payload
   390	    meta_payload=$(printf '{"unknown_code":"%s","helpers_version":"%s"}' \
   391	      "$(_hh_json_escape "${code}")" "${_HH_HELPERS_VERSION}")
   392	    _hh_emit_row "gating_failed" "fail-safe-red" "esc_code_unknown" "${meta_payload}"
   393	    return 1
   394	  fi
   395	
   396	  local escaped_code
   397	  escaped_code="$(_hh_json_escape "${code}")"
   398	  local payload="{\"escalation_code\":\"${escaped_code}\""
   399	  local arg
   400	  for arg in "$@"; do
   401	    if [[ "${arg}" == *"="* ]]; then
   402	      local k="${arg%%=*}"
   403	      local v="${arg#*=}"
   404	      payload+=",\"$(_hh_json_escape "${k}")\":\"$(_hh_json_escape "${v}")\""
   405	    fi
   406	  done
   407	  payload+="}"
   408	
   409	  _hh_emit_row "gating_failed" "${code}" "" "${payload}"
   410	
   411	  # Telegram dispatch is a separate primitive — for v0.1 the row is the
   412	  # signal. Dispatcher (autosend-syncer) reads recent gating_failed rows and
   413	  # routes to operator chat per common-notifications.json.
   414	}
   415	
   416	# autosend_should_sample <action_type> <tenant_slug>
   417	# Returns 0 if this invocation should produce a spot-check (1-in-N draw);
   418	# 1 otherwise. Sample rate read from autosend-policy.yaml (sample_rate field);
   419	# tenant override via tenant_adapters.config.sampling_rates.
   420	autosend_should_sample() {
   421	  local action_type="$1"
   422	  # tenant_slug reserved for future per-tenant rate override; currently unused
   423	  local rate
   424	  rate=$(awk -v key="${action_type}" '
   425	    $0 ~ "^  " key ":" { in_block = 1; next }
   426	    in_block && /^    sample_rate: / { sub(/^    sample_rate: /, ""); print; exit }
   427	    in_block && /^  [a-z]/ { in_block = 0 }
   428	  ' "${_HH_POLICY_FILE}")
   429	
   430	  if [[ -z "${rate}" || ! "${rate}" =~ ^[0-9]+$ || "${rate}" -le 0 ]]; then

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/cycle.sh | sed -n '280,355p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   280	    # bin/{propose,await}.ts in the same build slice — they are intentionally
   281	    # NOT in v0.1 scaffold per the package README §"Out of scope (v1.0)").
   282	    #
   283	    # Per draft produced at Step 7:
   284	    #
   285	    # 1. proposeApproval — @ifos/autosend-bridge-telegram proposeApproval API:
   286	    #
   287	    #    PROPOSE_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/propose.ts" \
   288	    #      --action gmail_outlook_send_to_candidate \
   289	    #      --tenant "${CTX_TENANT_SLUG}" \
   290	    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
   291	    #      --target "${RECIPIENT_EMAIL}" \
   292	    #      --preview "${DRAFT_PREVIEW_500_CHARS}" \
   293	    #      --vault-path "${DRAFT_PATH}" \
   294	    #      --timeout-seconds 14400)
   295	    #    APPROVAL_ID=$(printf '%s' "${PROPOSE_JSON}" | jq -r .approval_id)
   296	    #    EXPIRES_AT_ISO=$(printf '%s' "${PROPOSE_JSON}" | jq -r .expires_at_iso)
   297	    #
   298	    # 2. Emit concierge_approval_routed audit row (R19 registration):
   299	    #
   300	    #    hh_decision_action "concierge_approval_routed" \
   301	    #      "candidate:${BULLHORN_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
   302	    #      "d1_path:B; bridge_target:${APPROVAL_ID}; expires:${EXPIRES_AT_ISO}"
   303	    #
   304	    # 3. awaitApprovalDecision — block until decision or PT4H deadline:
   305	    #
   306	    #    AWAIT_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/await.ts" \
   307	    #      --approval-id "${APPROVAL_ID}" \
   308	    #      --expires-at "${EXPIRES_AT_ISO}")
   309	    #    OUTCOME=$(printf '%s' "${AWAIT_JSON}" | jq -r .outcome)
   310	    #    DECIDED_BY=$(printf '%s' "${AWAIT_JSON}" | jq -r '.decided_by // ""')
   311	    #
   312	    # 4. Branch on outcome:
   313	    #    case "${OUTCOME}" in
   314	    #      approved) : ;;  # Step 12 transport proceeds
   315	    #      rejected)
   316	    #        hh_decision_output "approval_rejected" \
   317	    #          "candidate:${BULLHORN_ID}:${EVENT_TYPE}" \
   318	    #          "approval_id:${APPROVAL_ID}; decided_by:${DECIDED_BY}" ;;
   319	    #      timeout)
   320	    #        # ESC_APPROVAL_BRIDGE_TIMEOUT per agents/_shared/escalation-codes.md
   321	    #        # lines 348-353: warn-tier; operator + tenant-admin per agent.md §6 row 11
   322	    #        hh_decision_action "validate_gate_a_fail" \
   323	    #          "candidate:${BULLHORN_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
   324	    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
   325	    #    esac
   326	    : # TODO(W10-13): wire the per-draft loop above; tsx CLI entrypoints land alongside
   327	  else
   328	    # Bridge package ABSENT — D1-C graceful degradation (drafts-only).
   329	    # DO NOT emit concierge_approval_routed; draft stays in vault for manual
   330	    # consultant pickup. Concierge §1 readiness caveat captures this state.
   331	    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
   332	      "autosend-bridge-telegram package dist/ not present — D1-C mode active; drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable D1-B send path"
   333	  fi
   334	fi
   335	
   336	# ────────────────────────────────────────────────────────────────────────
   337	# Step 12 — Send execution (orange tier; ONLY fires post-Step-11 approval)
   338	# Reference: agent.md §4 Step 12. microsoft_graph_send OR gmail_send per
   339	# tenant config; BCC tenant archive address. ESC_SEND_FAIL on 4xx/5xx
   340	# (retry once 30s backoff per agent.md §4 Step 12).
   341	# ────────────────────────────────────────────────────────────────────────
   342	
   343	if [[ "${STEPS_TO_RUN}" == *12* ]]; then
   344	  # TODO(W10-13): per-tenant channel resolution:
   345	  #   if tenant_adapters.config.email_channel == 'microsoft-graph':
   346	  #     ms_graph.send_email(to=RECIPIENT, subject=SUBJECT, body=BODY_MD, bcc=TENANT_ARCHIVE)
   347	  #   else: gmail.send_email(...)
   348	  # On success:
   349	  #   hh_decision_action "gmail_outlook_send_to_candidate" "candidate:<id>" "<hash>" "<preview>"
   350	  # On 4xx/5xx after 1 retry: ESC_SEND_FAIL warn-tier
   351	  :
   352	fi
   353	
   354	# ────────────────────────────────────────────────────────────────────────
   355	# Step 13 — Bullhorn activity-log write (post-send audit trail in ATS)

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/fixtures/01-primary.yaml | sed -n '1,60p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Concierge fixture — 01-primary
     2	#
     3	# Happy path. Event #2 from agent.md §3 (Interview booked → prep email to
     4	# candidate). Voice score comfortably above the position-1 threshold (≥0.75);
     5	# addressee resolves correctly; tone-rules pass; PII boundary clean; no prior
     6	# draft in the 24h window. Step 8 emits yellow concierge_email_draft; Step 11
     7	# proposeApproval posts to operator Telegram; operator approves at +5min;
     8	# Step 12 transports via MS Graph; Step 13 writes Bullhorn activity-log;
     9	# Step 15 records the SLA hit (well under 30-min Gate B threshold).
    10	#
    11	# Status: Proposed (W4 Day-26 SKELETON).
    12	
    13	fixture_id: 01-primary
    14	description: Interview-booked → prep email → operator approves → MS Graph send → Gate B SLA hit
    15	tenant_slug: migration-test
    16	agent: concierge
    17	expected_gate_a: PASS
    18	expected_exit_code: 0
    19	
    20	invocation:
    21	  command: ifosctl concierge process-event
    22	  flags:
    23	    - --mode
    24	    - webhook
    25	    - --tenant
    26	    - migration-test
    27	
    28	tenant_config:
    29	  email_channel: microsoft-graph
    30	  operator_telegram_chat_id: "987654321"
    31	  bullhorn_org_id: "10001"
    32	
    33	webhook_payload:
    34	  event_type: interview-booked  # event #2 in agent.md §3 12-event taxonomy
    35	  candidate_id: "CAND-100"
    36	  placement_id: "PLAC-200"
    37	  contact_id: "CONT-300"
    38	  client_id: "CLIENT-400"
    39	  state_from: applied
    40	  state_to: interview-scheduled
    41	  event_timestamp_iso: "2026-06-01T15:00:00.000Z"
    42	
    43	mocked_bullhorn:
    44	  candidate:
    45	    id: CAND-100
    46	    name: Alice Walker
    47	    email: alice.walker@example.com
    48	    comms_history: [{type: application, at: "2026-05-28T10:00:00Z"}]
    49	  placement:
    50	    id: PLAC-200
    51	    role: Senior Backend Engineer
    52	    client_id: CLIENT-400
    53	    interview_at: "2026-06-05T14:00:00Z"
    54	    format: video-call
    55	  client:
    56	    id: CLIENT-400
    57	    company: Acme Tech Ltd
    58	    primary_contact_id: CONT-300
    59	  contact:
    60	    id: CONT-300

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml | sed -n '1,50p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Concierge fixture — 02-edge-case-rejection-voice-drift
     2	#
     3	# Adversarial. Tests the highest-stakes-comm path: Event #6 (Rejected) —
     4	# THE HARDEST CASE per ULTRAPLAN A6 §gotchas: "respectful, specific, leaves
     5	# door open". Rejection sends are routed to escalation_position=3 (Step 6),
     6	# so the per-draft voice threshold is ≥0.82 (Step 8). The fixture supplies
     7	# a draft scoring 0.78 — between the position-1 (0.75) and position-3 (0.82)
     8	# thresholds. Without position-specific gating this would PASS at a generic
     9	# 0.75 floor; with position-specific gating per agent.md §4 Step 8 + ADR-007,
    10	# it MUST FAIL Gate A G1 + emit ESC_VOICE_DRIFT + abort the draft pipeline
    11	# (cycle.sh halts at Step 8 before the bridge propose call).
    12	#
    13	# This is the regression test against a quietly-loose voice gate on the
    14	# customer-facing rejection path.
    15	#
    16	# Status: Proposed (W4 Day-26 SKELETON).
    17	
    18	fixture_id: 02-edge-case-rejection-voice-drift
    19	description: Rejection (event #6) at position-3 with voice 0.78 < 0.82 threshold → ESC_VOICE_DRIFT warn + Gate A G1 fail + cycle abort
    20	tenant_slug: migration-test
    21	agent: concierge
    22	expected_gate_a: FAIL
    23	expected_exit_code: 1
    24	
    25	invocation:
    26	  command: ifosctl concierge process-event
    27	  flags:
    28	    - --mode
    29	    - webhook
    30	    - --tenant
    31	    - migration-test
    32	
    33	tenant_config:
    34	  email_channel: microsoft-graph
    35	  operator_telegram_chat_id: "987654321"
    36	  bullhorn_org_id: "10001"
    37	
    38	webhook_payload:
    39	  event_type: rejection   # event #6 in agent.md §3 12-event taxonomy
    40	  candidate_id: "CAND-101"
    41	  placement_id: "PLAC-201"
    42	  contact_id: "CONT-301"
    43	  client_id: "CLIENT-401"
    44	  state_from: interview-completed
    45	  state_to: rejected
    46	  event_timestamp_iso: "2026-06-01T15:00:00.000Z"
    47	
    48	mocked_bullhorn:
    49	  candidate:
    50	    id: CAND-101

codex
REJECTED

1. Anti-duplicate lookup depends on a field the artefact says is not written. Lines 143-145 query `payload.event_type`, but line 107 says `event_type` lives only inside `payload_preview`, not structured JSON. This makes the Gate A anti-duplicate guard unimplementable as specified. Fix by storing `candidate_id`/`event_type` in structured payload or querying a stable structured target.

2. Draft audit row contradicts the vault artefact contract. Line 105 says `artefact_ref` is `/vault/<tenant>/concierge-drafts/<id>.md`, but lines 198-199 pass `candidate:<bullhorn_id>:<event_type>` as the artefact ref and move the path into `reason`. This loses the canonical path from the payload. Fix Step 7 to pass the vault path as the second `hh_decision_output` argument.

3. D1 status is stale. Lines 4, 421, 427, and 454 still treat Founder Decision D1 as unresolved/blocking, but `docs/decisions/2026-05-31-d1-founder-decision.md` marks D1 Accepted and selects D1-B. This violates honest-signal discipline. Fix §8-§10 to mark D1 resolved and leave only remaining schema/build dependencies.

4. The document falsely says `validate.sh` does not exist. Line 313 says Concierge `validate.sh` “does NOT exist yet”, but `agents/recruitment/concierge/validate.sh` exists as a W4 skeleton. Since sibling bundle files are present, this status claim is inaccurate. Fix the wording to “exists as skeleton; W10-13 implements G1-G5.”

5. The surrounding bundle assumes undeclared tenant config keys. `context.sh` and fixtures use `tenant_adapters.config.email_channel` and `operator_telegram_chat_id`, while the v0.3 supplement declares Concierge keys only for `concierge_last_poll` and `concierge_send_window`; the D1 decision explicitly says `operator_telegram_chat_id` is not yet allowlisted. This violates schema-before-code. Fix by removing runtime reads/fixture assumptions or adding the v0.4 schema supplement first.
tokens used
129,718
REJECTED

1. Anti-duplicate lookup depends on a field the artefact says is not written. Lines 143-145 query `payload.event_type`, but line 107 says `event_type` lives only inside `payload_preview`, not structured JSON. This makes the Gate A anti-duplicate guard unimplementable as specified. Fix by storing `candidate_id`/`event_type` in structured payload or querying a stable structured target.

2. Draft audit row contradicts the vault artefact contract. Line 105 says `artefact_ref` is `/vault/<tenant>/concierge-drafts/<id>.md`, but lines 198-199 pass `candidate:<bullhorn_id>:<event_type>` as the artefact ref and move the path into `reason`. This loses the canonical path from the payload. Fix Step 7 to pass the vault path as the second `hh_decision_output` argument.

3. D1 status is stale. Lines 4, 421, 427, and 454 still treat Founder Decision D1 as unresolved/blocking, but `docs/decisions/2026-05-31-d1-founder-decision.md` marks D1 Accepted and selects D1-B. This violates honest-signal discipline. Fix §8-§10 to mark D1 resolved and leave only remaining schema/build dependencies.

4. The document falsely says `validate.sh` does not exist. Line 313 says Concierge `validate.sh` “does NOT exist yet”, but `agents/recruitment/concierge/validate.sh` exists as a W4 skeleton. Since sibling bundle files are present, this status claim is inaccurate. Fix the wording to “exists as skeleton; W10-13 implements G1-G5.”

5. The surrounding bundle assumes undeclared tenant config keys. `context.sh` and fixtures use `tenant_adapters.config.email_channel` and `operator_telegram_chat_id`, while the v0.3 supplement declares Concierge keys only for `concierge_last_poll` and `concierge_send_window`; the D1 decision explicitly says `operator_telegram_chat_id` is not yet allowlisted. This violates schema-before-code. Fix by removing runtime reads/fixture assumptions or adding the v0.4 schema supplement first.
