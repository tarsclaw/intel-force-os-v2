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
**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim per `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Concierge consumer wiring landed (commits `669a4f4` + `9ec2bd6`). **W10-13 build slice LANDED (2026-06-10, this branch):** 15-step `cycle.sh` + `validate.sh` Gate A + `context.sh` tenant_adapters reads + `cleanup.sh` + comms-template library + 3 fixtures + 3 DB-backed fixture suites + the autosend-bridge PRODUCTION wiring (real Telegram Bot API transport + postgres approvals reader + dist/bin CLIs; 34/34 vitest offline). Fixture-proven only — zero live Bullhorn / Telegram / email calls (creds + tokens EMPTY in the dev sandbox, verified 2026-06-10; provisioning founder-gated); the `/approve`—`/reject` Telegram command handler is `@ifos/telegram-surface` scope (not built). The **v0.4 schema supplement** (`operator_telegram_chat_id` + `email_channel` in the `tenant_adapters.config` allowlist, per D1-B decision-doc §Implementation surface item 5) **LANDED 2026-06-03 (commit `a1bbcf6`)** — a satisfied dependency, no longer a blocker. Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup; remaining production gates: tenant population + creds/OAuth provisioning + the telegram-surface approval handler — see §10.

**Reading-discipline note (updated 2026-06-10; supersedes the 2026-06-02 scaffold-era note):** this `agent.md` is the **CONTRACT** the W10-13 build slice implemented against — and that slice has now LANDED on this branch. The sibling bundle files (`cycle.sh` 15-step + `validate.sh` Gate A + `context.sh` + `cleanup.sh` + `tools.yaml`) + `templates/` + 3 fixtures are **LIVE/BUILT**: the yellow-tier draft row (Step 8), the orange-tier send row (Step 12), and every §4 audit marker ARE emitted at runtime, proven by 3 deterministic DB-backed fixture suites (gate-a / antidup / routing) in `scripts/`. `context.sh` reads `tenant_adapters.config.email_channel` + `.operator_telegram_chat_id` canonically (v0.4 supplement landed 2026-06-03, commit `a1bbcf6`); the `IFOS_FORCE_*` env vars remain as fixture/local-dev overrides only. **Honest scope:** everything is fixture-proven against the seeded `entities` cache + `IFOS_BRIDGE_FAKE` / `IFOS_FORCE_SEND_RESULT` — zero live Bullhorn, Telegram, or email calls have been made (creds + tokens EMPTY in the dev sandbox; founder-gated), and the `/approve` handler is `@ifos/telegram-surface` scope. Read agent.md as the contract the built bundle satisfies, with live-transport exercise still pending provisioning.
**Date:** 2026-05-24 (honesty pass 2026-06-10).
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

**v1.0 deviation (reviewer-accepted deviation 2, 2026-06-10):** events 5, 9, 11 and 12 name "Candidate + Client (separate drafts)" — the built cycle.sh generates the **candidate draft only** per run. The client_contact templates ARE shipped in the comms-template library and Step 5 template selection + Gate A handle the `client_contact` recipient_role, but the second client-facing draft per event is not yet emitted; that is a W14+ path. Spec-004 §4's addressee contract ("recipient matches the changing candidate") is fully met by the candidate draft.

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
     the target string). The helper stores BOTH `action_type` AND `target`
     INSIDE the payload jsonb (the autosend-emitted shape) — decision_log
     has NO top-level action_type/target columns, so the lookup goes via
     `payload->>`.
   → query: SELECT 1 FROM decision_log WHERE agent_name='concierge'
     AND payload->>'action_type'='concierge_email_draft'
     AND payload->>'target' = 'candidate:<bullhorn_id>:<event_type>'
     AND phase IN ('action','gating_failed')
     AND created_at > now() - interval '24 hours'
   → if found AND any subsequent `gmail_outlook_send_to_candidate` action
     row (payload->>'action_type'='gmail_outlook_send_to_candidate' AND
     payload->>'target'='candidate:<bullhorn_id>', phase='action') exists
     in the same window: skip (true duplicate — already sent)
   → if found BUT no `gmail_outlook_send_to_candidate` follow-up: allow
     the new draft attempt (per Q7 disposition)
   → hh_decision_output("anti_duplicate_check", "candidate:<bullhorn_id>:<event_type>",
     "duplicate_status:<found|fresh>; prior_send_completed:<true|false>")
     — note artefact_ref carries the candidate+event composite (matches the
     payload->>'target' equality match above); reason carries the status
     outcome.

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

**Honesty note (updated 2026-06-10; supersedes the 2026-06-02 skeleton-era note):** `agents/recruitment/concierge/validate.sh` is **LIVE** (W10-13 build slice, this branch) — the Gate A checks above enforce at runtime and are proven by `scripts/run-concierge-gate-a-test.sh` (DB-backed; ESC routing asserted per failure class). Voice honesty: no voice classifier exists in v1.0 (`@ifos/voice-classifier` unbuilt; voice_corpus empty) — unscored drafts carry `unscored/no_classifier` and G1 warn-and-passes them (accepted v1.0 behaviour); the position thresholds 0.75/0.78/0.82 hard-enforce on REAL numeric scores only (fixtures supply one via `IFOS_FORCE_VOICE_SCORE`).

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

## §8 — Build dependencies (W10-13 prerequisites — status as of 2026-06-10)

The W10-13 build slice has run on this branch (fixture-proven; founder-arbitrated parallel-build mandate). Dependency status, updated honestly:

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
| **Autosend bridge production wiring** — real Telegram Bot API transport + postgres approvals reader + dist/bin CLIs (34/34 vitest offline; live Bot API unexercised — TELEGRAM_BOT_TOKEN EMPTY) | W10-13 build slice, this branch | ✅ LANDED 2026-06-10 |
| **v0.4 schema supplement** adding `operator_telegram_chat_id` + `email_channel` to `tenant_adapters.config` allowlist (per D1-B decision-doc §Implementation surface item 5) | Landed commit `a1bbcf6` | ✅ LANDED 2026-06-03 |
| Autosend bridge built (per D1 outcome) | D1-B path; production wiring row above | ✅ LANDED 2026-06-10 |
| Voice classifier microservice live | W4-5 polish | ⏸ |
| Per-tenant comms-template library at `/vault/<slug>/concierge-templates/` | Tenant onboarding | ⏸ |
| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| `validate.sh` Gate A logic | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |
| `context.sh` hydration (tenant_adapters reads + honest token states) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |
| `cycle.sh` orchestration (15-step) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |
| Lifecycle event-detection polling fallback (poll + nurture-sweep modes via bh-bridge) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 (fixture-proven) |
| Comms-template library v0.1 (12 event types × 2 recipient roles) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |
| Fixtures with golden outputs — built as **3 fixtures + 3 DB-backed fixture suites** (deviation from the 5-fixture aspiration; the suites cover the gate-a / antidup / routing surface the extra fixtures targeted) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |

**Build-slice items above are ✅ (fixture-proven).** Remaining ⏸ items are commercial/runtime gates (pilot LOI, Bullhorn partnership, per-tenant email signups, voice classifier, tenant seeding) plus sibling-agent ratifications — they gate live operation, not the build. XL build complexity = 4-week duration was honoured.

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + Q1 LOI. (The W10-13 build slice landed 2026-06-10 on this branch; D1 was ACCEPTED 2026-05-31 as D1-B — neither is awaited any longer.)

### Open questions for founder review

Q1 (the D1 autosend orange-tier path decision) was **resolved 2026-05-31** as D1-B per `docs/decisions/2026-05-31-d1-founder-decision.md` and is removed from this table; Q2-Q10 numbering is retained for stable cross-references (§10 cites Q2-Q9).

| # | Question | Resolution path |
|---|---|---|
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
- ✅ **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`; package scaffold + Concierge consumer wiring landed 2026-06-01. NO LONGER a Proposed→Accepted blocker. ✅ The autosend-bridge **production wiring LANDED 2026-06-10** (this branch) and the **v0.4 schema supplement LANDED 2026-06-03** (commit `a1bbcf6`) — both satisfied dependencies. Remaining production gates: tenant population (operator_telegram_chat_id + email_channel values per tenant) + creds/OAuth provisioning + the `@ifos/telegram-surface` `/approve`—`/reject` handler
- Founder approves §9 Q2 (lifecycle taxonomy) + Q3 (send window) + Q4 (rejection routing) + Q5 (template authoring UX) + Q6 (Gate B UX)
- Q7-Q9 documented decisions captured

Status flips Accepted → In Force when:
- ✅ W10-13 build slice produces the sibling bundle files + fixtures — LANDED 2026-06-10 (this branch): 5 bundle files + 2 bins + templates + 3 fixtures + 3 DB-backed suites (3-fixture deviation from the 5-fixture aspiration recorded in §8)
- First production lifecycle webhook processed end-to-end against migration-test tenant
- 12-event taxonomy validated against first pilot tenant's actual Bullhorn state-change patterns
- Voice classifier microservice production-ready (per-tenant; position-3 ≥0.82 sustained)
- Gate B feedback loop operational (consultant approve/edit distinguishable)
- Codex re-ratifies post-build via `review-agent-bundle.md` skill

Until then: this document is the contract a built, fixture-proven bundle satisfies (no longer a forward-looking scaffold as of 2026-06-10) — live-transport exercise, tenant population, and the remaining §10 gates stand between Built and In Force. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at contract stage. Founder review at each iteration is expected.

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
