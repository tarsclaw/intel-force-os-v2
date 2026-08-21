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
session id: 019eb232-a730-7782-ae79-179290580fcd
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

codex
I’ll verify the Concierge bundle against the ratification rules and spot-check the cited source files rather than relying on the artefact’s own claims.
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
     1	# Concierge — no candidate ghosted
     2	
     3	**Status:** Proposed-with-disagreement-on-file (`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` — bundle-layer Codex ratification deferred to W10-13 build slice; contract-layer ratification was achieved in W3 cluster E).
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim per `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Concierge consumer wiring landed (commits `669a4f4` + `9ec2bd6`). **W10-13 build slice LANDED (2026-06-10, this branch):** 15-step `cycle.sh` + `validate.sh` Gate A + `context.sh` tenant_adapters reads + `cleanup.sh` + comms-template library + 3 fixtures + 3 DB-backed fixture suites + the autosend-bridge PRODUCTION wiring (real Telegram Bot API transport + postgres approvals reader + dist/bin CLIs; 34/34 vitest offline). Fixture-proven only — zero live Bullhorn / Telegram / email calls (creds + tokens EMPTY in the dev sandbox, verified 2026-06-10; provisioning founder-gated); the `/approve`—`/reject` Telegram command handler is `@ifos/telegram-surface` scope (not built). The **v0.4 schema supplement** (`operator_telegram_chat_id` + `email_channel` in the `tenant_adapters.config` allowlist, per D1-B decision-doc §Implementation surface item 5) **LANDED 2026-06-03 (commit `a1bbcf6`)** — a satisfied dependency, no longer a blocker. Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup; remaining production gates: tenant population + creds/OAuth provisioning + the telegram-surface approval handler — see §10.
     5	
     6	**Reading-discipline note (updated 2026-06-10; supersedes the 2026-06-02 scaffold-era note):** this `agent.md` is the **CONTRACT** the W10-13 build slice implemented against — and that slice has now LANDED on this branch. The sibling bundle files (`cycle.sh` 15-step + `validate.sh` Gate A + `context.sh` + `cleanup.sh` + `tools.yaml`) + `templates/` + 3 fixtures are **LIVE/BUILT**: the yellow-tier draft row (Step 8), the orange-tier send row (Step 12), and every §4 audit marker ARE emitted at runtime, proven by 3 deterministic DB-backed fixture suites (gate-a / antidup / routing) in `scripts/`. `context.sh` reads `tenant_adapters.config.email_channel` + `.operator_telegram_chat_id` canonically (v0.4 supplement landed 2026-06-03, commit `a1bbcf6`); the `IFOS_FORCE_*` env vars remain as fixture/local-dev overrides only. **Honest scope:** everything is fixture-proven against the seeded `entities` cache + `IFOS_BRIDGE_FAKE` / `IFOS_FORCE_SEND_RESULT` — zero live Bullhorn, Telegram, or email calls have been made (creds + tokens EMPTY in the dev sandbox; founder-gated), and the `/approve` handler is `@ifos/telegram-surface` scope. Read agent.md as the contract the built bundle satisfies, with live-transport exercise still pending provisioning.
     7	**Date:** 2026-05-24 (honesty pass 2026-06-10).
     8	**Author:** Founder (Maddox) + Claude Code.
     9	**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
    10	**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
    11	**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
    12	
    13	---
    14	
    15	## §1 — Output contract (one-paragraph screenshot)
    16	
    17	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    18	
    19	> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
    20	
    21	---
    22	
    23	## §2 — Invocation surface
    24	
    25	### Lifecycle webhook (v1.0 primary)
    26	
    27	```http
    28	# Bullhorn placement state-change webhook → Concierge handler
    29	POST https://<tenant>.ifos.app/agents/concierge/webhook
    30	Authorization: Bearer <bullhorn-shared-secret>
    31	Content-Type: application/json
    32	
    33	{
    34	  "event_type": "placement.state_changed" | "candidate.state_changed",
    35	  "entity_id": "<bullhorn-id>",
    36	  "from_state": "interview_scheduled",
    37	  "to_state": "interview_completed",
    38	  "timestamp": "<ISO>"
    39	}
    40	```
    41	
    42	Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §Gotchas line 570 gotcha — see Step 1 polling fallback.
    43	
    44	### Cron (polling fallback + time-elapsed nurture)
    45	
    46	```bash
    47	# Every 5 min: poll Bullhorn for missed state transitions
    48	*/5 * * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode poll
    49	# Daily 09:00 UTC: time-elapsed nurture sweeps (7d / 30d / 90d check-ins)
    50	0 9 * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode nurture-sweep
    51	```
    52	
    53	### Manual (debugging)
    54	
    55	```bash
    56	ifosctl concierge generate --tenant <slug> --candidate <id> --event <event-type>
    57	ifosctl concierge replay --tenant <slug> --webhook-id <id>
    58	```
    59	
    60	### v1.1+ surfaces (deferred)
    61	
    62	- agent-identity email adapter (deferred) integration (agent-identity sends for non-rejection comms)
    63	- Brain UI lifecycle-event timeline viewer per candidate
    64	- Per-tenant comms-type taxonomy customisation
    65	
    66	---
    67	
    68	## §3 — Output shape
    69	
    70	One output per lifecycle event: an email draft (yellow tier `concierge_email_draft` per autosend-policy.yaml; only the customer-facing SEND is orange tier — `gmail_outlook_send_to_candidate` / `bullhorn_note_customer_visible` / `twilio_sms_send` / `calendar_invite_send` per channel). 12 lifecycle events × per-tenant comms-template variants:
    71	
    72	| # | Event | Comms type | Recipient | Tone |
    73	|---|---|---|---|---|
    74	| 1 | Application received | Acknowledgement | Candidate | Warm, professional, sets expectations on response timeline |
    75	| 2 | Interview booked | Prep | Candidate | Practical (date, time, format, interviewers) + role context |
    76	| 3 | Interview completed | Debrief | Candidate | Thank-you + next-step clarity OR "we'll be in touch by X" |
    77	| 4 | Offer extended | Placement-positive | Candidate | Excited, clear on terms, addressee-resolution-critical |
    78	| 5 | Offer accepted | Placement-confirm | Candidate + Client (separate drafts) | Reassurance + practical next steps |
    79	| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §Gotchas line 570 — respectful, specific, leaves door open |
    80	| 7 | Withdrawn (candidate-initiated) | Acknowledgement | Candidate | Respectful, no pressure, leaves door open |
    81	| 8 | On-hold | Status-update | Candidate | Honest about timeline, sets expectations on next update |
    82	| 9 | Start date confirmed | Placement-pre-start | Candidate + Client | Practical (HR forms, IT setup, day-1 logistics) |
    83	| 10 | 7-day check-in (post-start) | Nurture-check-in | Candidate | "How's it going? Any blockers?" — short, low-pressure |
    84	| 11 | 30-day check-in | Nurture-check-in | Candidate + Client | Slightly longer; both sides; reads for placement-risk signals |
    85	| 12 | 90-day check-in | Nurture-check-in + relationship | Candidate + Client | Establishes ongoing relationship; offers "is there anyone in your network looking?" |
    86	
    87	**v1.0 deviation (reviewer-accepted deviation 2, 2026-06-10):** events 5, 9, 11 and 12 name "Candidate + Client (separate drafts)" — the built cycle.sh generates the **candidate draft only** per run. The client_contact templates ARE shipped in the comms-template library and Step 5 template selection + Gate A handle the `client_contact` recipient_role, but the second client-facing draft per event is not yet emitted; that is a W14+ path. Spec-004 §4's addressee contract ("recipient matches the changing candidate") is fully met by the candidate draft.
    88	
    89	Draft structure per event:
    90	
    91	```yaml
    92	draft_id: <uuid>
    93	event_type: <one of 12 above>
    94	candidate_id: <bullhorn-id>
    95	placement_id: <bullhorn-id or null>
    96	recipient: <candidate-email | client-contact-email>
    97	recipient_role: candidate | client_contact
    98	subject: <subject line; voice-classified>
    99	body_markdown: <body; voice-classified>
   100	voice_score: <0-1>
   101	addressee_resolution_check: passed | failed
   102	attached_documents: <list — e.g., feedback summary, prep guide, comms history>
   103	escalation_position: 1-3 (for sensitive sends like rejection)
   104	expected_send_window: <ISO; respects sending-hours per tenant config>
   105	```
   106	
   107	Each draft writes TWO decision_log rows per `_shared/hook-helpers.sh` contract:
   108	
   109	1. `phase='output'` via `hh_decision_output("concierge_draft_rendered", "/vault/<tenant>/concierge-drafts/<id>.md", "voice_score:<N>; words:<N>")`. The helper writes only `{output_type, artefact_ref}` to the payload jsonb; the additional metadata rides the optional `reason` string parameter. This row records that the draft exists; no tier (output rows are not tier-classified).
   110	
   111	2. `phase='action'` via `hh_decision_action("concierge_email_draft", "candidate:<bullhorn_id>:<event_type>", payload_hash, payload_preview)`. This is the tier-classified row — `concierge_email_draft` is registered yellow tier per autosend-policy.yaml lookup (grep `^  concierge_email_draft:` to verify). Tier is recorded inside the autosend-emitted payload by the helper; it is NOT a top-level decision_log column. `payload_preview` carries `event_type`, `voice_score`, `recipient`, `escalation_position` as a concatenated string for cross-row correlation. Action_type stays stable across all 12 lifecycle events — event_type is in the preview string, not part of the action_type identifier.
   112	
   113	The actual SEND is a separate orange-tier action_type:
   114	- `gmail_outlook_send_to_candidate` (orange tier per autosend-policy.yaml §ORANGE) when channel=email
   115	- `bullhorn_note_customer_visible` (orange tier; canonical orange per autosend-policy.yaml §ORANGE) when channel=Bullhorn note with isExternal=true
   116	- `twilio_sms_send` (orange tier per autosend-policy.yaml §ORANGE) when channel=SMS (v1.1+)
   117	- `calendar_invite_send` (orange tier per autosend-policy.yaml §ORANGE) when event includes calendar attachment
   118	
   119	Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
   120	
   121	---
   122	
   123	## §4 — Workflow
   124	
   125	15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   126	
   127	```
   128	0. Session start (webhook OR poll OR cron)
   129	   → context.sh hydrates: tenant config + Bullhorn auth refresh +
   130	     Microsoft Graph / Gmail auth + agent-identity email adapter (deferred) (if v1.1+ enabled) +
   131	     voice corpus + tone rules + recent_edits + tenant comms-template
   132	     library + addressee-resolution data
   133	   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")
   134	
   135	1. Source detection (mode-dependent)
   136	   → mode=webhook: parse Bullhorn payload → resolve entity + state transition
   137	   → mode=poll: query Bullhorn for placements/candidates with state_changed_at
   138	     > tenant_adapters.config.concierge_last_poll AND not in decision_log
   139	     (anti-duplicate)
   140	   → mode=nurture-sweep: query Bullhorn placements for time-elapsed events
   141	     (7d/30d/90d post-start with no concierge action in last 14d)
   142	   → ESC_LIFECYCLE_STATE_UNKNOWN if state transition not in 12-event taxonomy
   143	   → hh_decision_output("lifecycle_event_detected",
   144	     "<entity_type>:<bullhorn_id>", "<from>→<to>")
   145	
   146	2. Anti-duplicate guard
   147	   → `concierge_email_draft` is the yellow-tier action_type used at Step 8;
   148	     its target field per `hh_decision_action(action_type, target, ...)` is
   149	     `candidate:<bullhorn_id>:<event_type>` (the event_type is encoded into
   150	     the target string). The helper stores BOTH `action_type` AND `target`
   151	     INSIDE the payload jsonb (the autosend-emitted shape) — decision_log
   152	     has NO top-level action_type/target columns, so the lookup goes via
   153	     `payload->>`.
   154	   → query: SELECT 1 FROM decision_log WHERE agent_name='concierge'
   155	     AND payload->>'action_type'='concierge_email_draft'
   156	     AND payload->>'target' = 'candidate:<bullhorn_id>:<event_type>'
   157	     AND phase IN ('action','gating_failed')
   158	     AND created_at > now() - interval '24 hours'
   159	   → if found AND any subsequent `gmail_outlook_send_to_candidate` action
   160	     row (payload->>'action_type'='gmail_outlook_send_to_candidate' AND
   161	     payload->>'target'='candidate:<bullhorn_id>', phase='action') exists
   162	     in the same window: skip (true duplicate — already sent)
   163	   → if found BUT no `gmail_outlook_send_to_candidate` follow-up: allow
   164	     the new draft attempt (per Q7 disposition)
   165	   → hh_decision_output("anti_duplicate_check", "candidate:<bullhorn_id>:<event_type>",
   166	     "duplicate_status:<found|fresh>; prior_send_completed:<true|false>")
   167	     — note artefact_ref carries the candidate+event composite (matches the
   168	     payload->>'target' equality match above); reason carries the status
   169	     outcome.
   170	
   171	3. Bullhorn context fetch
   172	   → bullhorn.get_candidate(candidate_id) → name, current state, comms history
   173	   → bullhorn.get_placement(placement_id) → role, client, dates
   174	   → bullhorn.get_client(client_id) → company name, primary contact
   175	   → bullhorn.get_contact(contact_id) → name, email
   176	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
   177	     ESC_BULLHORN_AUTH on auth fail
   178	   → ESC_AGENT_OUTPUT_SHAPE if critical Bullhorn context fields missing
   179	     (no email, no name) — Concierge cannot produce its declared output
   180	     shape (lifecycle-event draft) without a resolvable target candidate.
   181	     NOTE: ESC_CANDIDATE_DATA_INCOMPLETE is reserved for Sourcing Scout
   182	     shortlist completeness per catalogue §2.10.
   183	   → hh_decision_output("bullhorn_context_fetched",
   184	     "candidate:<bullhorn_id>", "fields_present:<N>")
   185	
   186	4. Addressee resolution (Gate A critical)
   187	   → recipient = candidate.email OR client_contact.email per event_type
   188	   → verify recipient matches the candidate_id whose lifecycle is changing
   189	     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
   190	     "correct addressee resolution; no candidates emailed under another's name")
   191	   → ESC_ADDRESSEE_MISMATCH if check fails (blocking); draft aborted
   192	   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
   193	     "recipient_role:<role>")
   194	
   195	5. Comms-template selection
   196	   → tenant comms-template library at /vault/<slug>/concierge-templates/
   197	   → per event_type: select template; per recipient_role: candidate vs client
   198	   → fallback: shared/common-comms-templates.yaml if tenant has no override
   199	   → hh_decision_output("template_selected", "<event_type>:<recipient_role>",
   200	     "template_id:<id>")
   201	
   202	6. Sensitive-event escalation routing
   203	   → if event_type=rejection (event 6) OR event_type=withdrawal (event 7)
   204	     OR (event_type=on-hold AND placement value >£10k): set escalation_position=3
   205	     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
   206	   → else: escalation_position=1 (standard orange tier)
   207	   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
   208	     "position:<N>")
   209	
   210	7. LLM draft generation
   211	   → prompt = (event context + candidate state history + voice corpus
   212	     ANN-matched on event_type + tone rules filtered for concierge +
   213	     comms-template structure)
   214	   → output = email body + subject + recommended_send_time
   215	   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
   216	   → hh_decision_output("concierge_draft_rendered",
   217	     "/vault/<tenant>/concierge-drafts/<draft_id>.md",
   218	     "candidate:<bullhorn_id>:<event_type>; voice_score:<N>; words:<N>")
   219	     — per §3 line 105: vault path is the canonical artefact_ref (the
   220	     second hh_decision_output argument); the candidate+event composite
   221	     and voice metadata ride the reason string parameter.
   222	   → ESC_VOICE_DRIFT if classifier score below the escalation_position-specific
   223	     threshold (position 1 ≥0.75; position 2 ≥0.78; position 3 ≥0.82 per Step 8)
   224	     after 3 retries — the position is set in Step 6 and is the per-draft Gate A
   225	     threshold. Generic <0.75 floor would understate position 2-3 sensitivity.
   226	
   227	8. Voice + tone validation
   228	   → voice classifier scores the draft
   229	   → minimum threshold by escalation_position:
   230	     position 1: ≥0.75
   231	     position 2: ≥0.78
   232	     position 3 (rejections / sensitive): ≥0.82
   233	   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
   234	   → on success: hh_decision_action("concierge_email_draft",
   235	     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
   236	     tier=yellow per autosend-policy.yaml
   237	
   238	9. SLA timing check (Gate B leading metric — NOT Gate A hard-fail)
   239	   → elapsed = now() - event_timestamp
   240	   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
   241	     → hh_decision_output("concierge_sla_miss",
   242	       "candidate:<bullhorn_id>:<event_type>",
   243	       "elapsed_seconds:<N>; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct")
   244	       — mandatory audit row per master brief §8.1 Change 2 (phase=output;
   245	       no tiered action_type required — this is an internal status marker)
   246	   → per ULTRAPLAN A6 line 566 (as amended by ADR-007): the 30-min draft SLA is
   247	     a Gate B leading metric (90% of drafts within 30 min), not a per-draft hard
   248	     fail (legitimate polling-fallback delays would otherwise block drafts)
   249	
   250	10. PII boundary check
   251	    → no PII from other candidates referenced in body
   252	    → no PII from competitor clients referenced
   253	    → no compensation specifics outside what's already in candidate's record
   254	    → ESC_PII_LEAKAGE_RISK on hit (blocking)
   255	    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
   256	     "result:passed")
   257	
   258	11. Autosend-bridge routing (D1 path)
   259	    → per Founder Decision D1 (selected 2026-05-31 as D1-B — Telegram shim per `docs/decisions/2026-05-31-d1-founder-decision.md`; v1.1+ upgrade path to D1-A queued):
   260	      D1-A (bridge to cortextOS approval system): POST internal API

exec
/bin/zsh -lc "rg --files | rg '("'^agents/recruitment/concierge/|agents/_shared/|docs/.+|vertical-schema|ULTRAPLAN|master|autosend|kill-criterion)'"'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
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
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
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
docs/design-mockups/brain-ui-decisions-feed-light-v01.html
docs/specs/ULTRAPLAN.md
docs/specs/_archive-build-handoff.md
docs/specs/PRODUCT-SPEC.md
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md
docs/artefacts/diagnostic-hays-plc-2026-05-24.md
docs/incidents/2026-06-01-intelforce-ai-email-outage.md
docs/architecture/tenancy-invariants.md
docs/architecture/architecture-cohesion-review.md
docs/architecture/agent-bundle-renderer-design.md
docs/architecture/cortexos-kb-surface-investigation.md
docs/architecture/cortexos-primitive-status.md
docs/architecture/vault-concurrency.md
docs/architecture/second-brain-design.md
docs/_supplementary/PRD-autonomous-agent.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/README.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/technical-strategy-v2.md
docs/_supplementary/execution-plan.md
logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
agents/_shared/README.md
logs/codex-ratification/round-3-remediation/docs_decisions_autosend-approval-bridge-spec-md.output.md
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
docs/operations/decision-log.md
docs/operations/goal-week-6-execution-plan.md
docs/operations/seedlegals-engagement-queries.md
docs/operations/goal-option-c-diagnostic-end-to-end.md
docs/operations/founder-manual-playbook-2026-05-31.md
docs/operations/founder-playbook-2026-06-03-granola-and-v04.md
docs/operations/founder-legal-setup-guide.md
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
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-approval-bridge-spec-md.output.md
docs/runbooks/day-4-provisioning.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/tenant-lifecycle.md
docs/runbooks/pii-purge-operational-pattern.md
docs/features/agent-build/00-ORCHESTRATOR.md
docs/features/agent-build/01-LAUNCH.md
docs/features/agent-build/STATUS.md
docs/features/agent-build/03-implementation/concierge-summary.md
docs/features/agent-build/02-specs/spec-001-janitor.md
docs/features/agent-build/02-specs/spec-004-concierge.md
docs/features/agent-build/02-specs/spec-002-scribe.md
docs/features/agent-build/02-specs/spec-003-sourcing-scout.md
docs/features/agent-build/02-specs/_TEMPLATE.md
docs/features/agent-build/04-reviews/review-concierge.md
docs/features/agent-build/04-reviews/review-sourcing-scout.md
docs/features/agent-build/04-reviews/review-scribe.md
docs/features/agent-build/04-reviews/review-janitor.md
docs/build-brief/00-MASTER-BRIEF.md
agents/recruitment/concierge/cleanup.sh
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml
agents/recruitment/concierge/fixtures/01-primary.yaml
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml
agents/recruitment/concierge/templates/common-comms-templates.yaml
agents/recruitment/concierge/cycle.sh
agents/recruitment/concierge/README.md
agents/recruitment/concierge/tools.yaml
agents/recruitment/concierge/context.sh
agents/recruitment/concierge/agent.md
agents/recruitment/concierge/validate.sh
agents/recruitment/concierge/bin/bh-bridge.sh
agents/recruitment/concierge/bin/render-concierge-draft.sh
legacy/v1/docs/phase-1-poc-stack/SESSION-SUMMARY.md
legacy/v1/docs/phase-1-poc-stack/platform-specs/webhook-receiver-spec.md
legacy/v1/docs/phase-1-poc-stack/platform-specs/tenant-container-spec.md
legacy/v1/docs/phase-1-poc-stack/platform-specs/minimal-vault-structure.md
legacy/v1/docs/phase-1-poc-stack/runbooks/week-1-experiment-runbook.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/config.schema.json
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tools.yaml
legacy/v1/docs/phase-1-poc-stack/proposal-builder/agent.md
legacy/v1/docs/phase-2-agent-suite/00-PATTERN-REFERENCE.md
legacy/v1/docs/phase-2-agent-suite/librarian/config.schema.json
legacy/v1/docs/phase-2-agent-suite/librarian/README.md
legacy/v1/docs/phase-2-agent-suite/librarian/tools.yaml
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/02-multi-service-ambiguous/transcript.json
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/02-multi-service-ambiguous/expected.md
legacy/v1/docs/gtm-pack/04-outreach-templates.md
legacy/v1/docs/gtm-pack/03-prospect-tracker-template.csv
legacy/v1/docs/gtm-pack/06-pricing-sheet.md
legacy/v1/docs/gtm-pack/02-landing-page-hero-notes.md
legacy/v1/docs/gtm-pack/README.md
legacy/v1/docs/gtm-pack/01-demo-script.md
legacy/v1/docs/gtm-pack/02-landing-page-hero.html
legacy/v1/docs/gtm-pack/05-manual-service-runbook.md
legacy/v1/docs/gtm-pack/03-prospecting-framework.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/config.schema.json
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/README.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/tools.yaml
legacy/v1/docs/phase-2-agent-suite/reporting-engine/config.schema.json
legacy/v1/docs/phase-2-agent-suite/reporting-engine/README.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/tools.yaml
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/03-budget-mismatch/transcript.json
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/03-budget-mismatch/expected.md
legacy/v1/docs/build-kit/CLAUDE.md
legacy/v1/docs/build-kit/00-HOW-TO-PROCEED.md
legacy/v1/docs/teams-hr-agent/04-deployment-guide.md
legacy/v1/docs/teams-hr-agent/05-productisation-playbook.md
legacy/v1/docs/teams-hr-agent/06-adaptive-card-examples.json
legacy/v1/docs/teams-hr-agent/01-architecture-overview.md
legacy/v1/docs/teams-hr-agent/03-azure-bootstrap-via-claude-code.md
legacy/v1/docs/teams-hr-agent/02-component-design.md
legacy/v1/docs/teams-hr-agent/README.md
legacy/v1/docs/teams-hr-agent/07-claude-code-prompts.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/01-dental-clear-fit/transcript.json
legacy/v1/docs/phase-1-poc-stack/proposal-builder/tests/fixtures/01-dental-clear-fit/expected.md
legacy/v1/docs/phase-1-poc-stack/proposal-builder/validate.sh
legacy/v1/docs/phase-1-poc-stack/proposal-builder/context.sh
legacy/v1/docs/phase-6-ops-runbooks/PHASE-6-SUMMARY.md
legacy/v1/docs/phase-2-agent-suite/librarian/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/librarian/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/librarian/validate.sh
legacy/v1/docs/phase-2-agent-suite/librarian/context.sh
legacy/v1/docs/phase-2-agent-suite/librarian/agent.md
legacy/v1/docs/phase-4-dashboard/architecture/design-system-spec.md
legacy/v1/docs/phase-4-dashboard/architecture/dashboard-architecture-spec.md
legacy/v1/docs/phase-4-dashboard/architecture/auth-and-authorization-spec.md
legacy/v1/docs/phase-0-strategic/intelforce-dashboard.jsx
legacy/v1/docs/phase-0-strategic/intelforce-ai-os-strategic-plan.md
legacy/v1/docs/phase-0-strategic/ARCHITECTURE-OVERVIEW.md
legacy/v1/docs/phase-0-strategic/intelforce-build-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-execution-plan.md
legacy/v1/docs/phase-0-strategic/intelforce-technical-strategy-v2.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md
legacy/v1/docs/phase-4-dashboard/wizard/configuration-wizard-spec.md
legacy/v1/docs/phase-4-dashboard/PHASE-4-SUMMARY.md
legacy/v1/docs/phase-4-dashboard/views/operations-control-spec.md
legacy/v1/docs/phase-4-dashboard/views/settings-spec.md
legacy/v1/docs/phase-4-dashboard/views/agency-partner-portal-spec.md
legacy/v1/docs/phase-4-dashboard/views/brain-view-spec.md
legacy/v1/docs/phase-4-dashboard/views/activity-log-and-audit-spec.md
legacy/v1/docs/phase-6-ops-runbooks/routines/cost-governance-runbook.md
legacy/v1/docs/phase-6-ops-runbooks/routines/backup-verification-and-dr-drills.md
legacy/v1/docs/phase-6-ops-runbooks/routines/secret-rotation-runbook.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-4-dashboard/api/trpc-router-spec.md
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/validate.sh
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/context.sh
legacy/v1/docs/phase-2-agent-suite/follow-up-pilot/agent.md
legacy/v1/docs/phase-5-business-legal/billing/stripe-integration-spec.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/config.schema.json
legacy/v1/docs/phase-3-platform/services/vault-search-spec.md
legacy/v1/docs/phase-3-platform/services/escalation-notifier-spec.md
legacy/v1/docs/phase-3-platform/PHASE-3-SUMMARY.md
legacy/v1/docs/phase-3-platform/postgres/schema-spec.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/reporting-engine/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/reporting-engine/validate.sh
legacy/v1/docs/phase-2-agent-suite/reporting-engine/context.sh
legacy/v1/docs/phase-2-agent-suite/reporting-engine/agent.md
legacy/v1/docs/phase-6-ops-runbooks/compliance/breach-response-runbook.md
legacy/v1/docs/phase-6-ops-runbooks/compliance/gdpr-dsar-and-deletion-runbook.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/README.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/tools.yaml
legacy/v1/docs/phase-5-business-legal/pricing/pricing-spec.md
legacy/v1/docs/phase-3-platform/postgres/migrations/20260422_001_initial.sql
legacy/v1/docs/phase-6-ops-runbooks/runbooks/platform-service-incidents.md
legacy/v1/docs/phase-6-ops-runbooks/runbooks/postgres-incidents.md
legacy/v1/docs/phase-6-ops-runbooks/runbooks/deploy-and-rollback.md
legacy/v1/docs/phase-6-ops-runbooks/runbooks/tenant-incidents.md
legacy/v1/docs/phase-5-business-legal/legal/msa-template.md
legacy/v1/docs/phase-5-business-legal/legal/sla-spec.md
legacy/v1/docs/phase-5-business-legal/legal/privacy-and-terms-spec.md
legacy/v1/docs/phase-5-business-legal/legal/dpa-template.md
legacy/v1/docs/phase-5-business-legal/legal/acceptable-use-policy.md
legacy/v1/docs/phase-2-agent-suite/_shared/escalation-codes.md
legacy/v1/docs/phase-2-agent-suite/_shared/hook-helpers.sh
legacy/v1/docs/phase-2-agent-suite/_shared/universal-banned-phrases.txt
legacy/v1/docs/phase-3-platform/observability/observability-spec.md
legacy/v1/docs/phase-6-ops-runbooks/incident-response/incident-response-runbook.md
legacy/v1/docs/phase-6-ops-runbooks/incident-response/on-call-handbook.md
legacy/v1/docs/phase-6-ops-runbooks/incident-response/severity-classification-and-comms.md
legacy/v1/docs/phase-2-agent-suite/PHASE-2-SUMMARY.md
legacy/v1/docs/phase-5-business-legal/marketing/trademark-filing-brief.md
legacy/v1/docs/phase-5-business-legal/marketing/brand-identity-spec.md
legacy/v1/docs/phase-5-business-legal/marketing/landing-page-spec.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/config.schema.json
legacy/v1/docs/phase-2-agent-suite/client-onboarder/README.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/tools.yaml
legacy/v1/docs/phase-2-agent-suite/content-creator/config.schema.json
legacy/v1/docs/phase-2-agent-suite/content-creator/README.md
legacy/v1/docs/phase-2-agent-suite/content-creator/tools.yaml
legacy/v1/docs/phase-3-platform/provisioning/provisioning-system-spec.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/caption-writer/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/caption-writer/validate.sh
legacy/v1/docs/phase-2-agent-suite/caption-writer/context.sh
legacy/v1/docs/phase-2-agent-suite/caption-writer/agent.md
legacy/v1/docs/phase-2-agent-suite/README.md
legacy/v1/docs/phase-5-business-legal/api/rest-api-spec.md
legacy/v1/docs/phase-3-platform/secrets/secrets-vault-spec.md
legacy/v1/docs/phase-5-business-legal/PHASE-5-SUMMARY.md
legacy/v1/docs/phase-2-agent-suite/content-creator/agent.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/config.schema.json
legacy/v1/docs/phase-2-agent-suite/sop-writer/README.md
legacy/v1/docs/phase-2-agent-suite/sop-writer/tools.yaml
legacy/v1/docs/phase-5-business-legal/playbooks/sales-playbook.md
legacy/v1/docs/phase-5-business-legal/playbooks/case-study-playbook.md
legacy/v1/docs/phase-2-agent-suite/content-creator/context.sh
legacy/v1/docs/phase-2-agent-suite/content-creator/validate.sh
legacy/v1/docs/phase-2-agent-suite/sop-writer/agent.md
legacy/v1/docs/phase-3-platform/dr/backup-and-dr-runbook.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/config.schema.json
legacy/v1/docs/phase-2-agent-suite/lead-hunter/README.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/tools.yaml
legacy/v1/docs/phase-2-agent-suite/lead-hunter/context.sh
legacy/v1/docs/phase-2-agent-suite/lead-hunter/agent.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/validate.sh
legacy/v1/docs/phase-2-agent-suite/sop-writer/context.sh
legacy/v1/docs/phase-2-agent-suite/sop-writer/validate.sh
legacy/v1/docs/phase-2-agent-suite/client-onboarder/context.sh
legacy/v1/docs/phase-2-agent-suite/client-onboarder/agent.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/validate.sh
legacy/v1/docs/phase-2-agent-suite/hr-agent/config.schema.json
legacy/v1/docs/phase-2-agent-suite/hr-agent/tools.yaml
legacy/v1/docs/phase-2-agent-suite/hr-agent/agent.md
legacy/v1/docs/phase-2-agent-suite/client-onboarder/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/client-onboarder/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/lead-hunter/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/lead-hunter/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/repurposer/config.schema.json
legacy/v1/docs/phase-2-agent-suite/repurposer/README.md
legacy/v1/docs/phase-2-agent-suite/repurposer/tools.yaml
legacy/v1/docs/phase-2-agent-suite/sop-writer/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/sop-writer/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/hr-agent/tests/fixtures/01-holiday-policy/input.json
legacy/v1/docs/phase-2-agent-suite/hr-agent/tests/fixtures/01-holiday-policy/expected.md
legacy/v1/docs/phase-2-agent-suite/repurposer/context.sh
legacy/v1/docs/phase-2-agent-suite/repurposer/agent.md
legacy/v1/docs/phase-2-agent-suite/repurposer/validate.sh
legacy/v1/docs/phase-2-agent-suite/hr-agent/tests/fixtures/02-grievance-escalation/input.json
legacy/v1/docs/phase-2-agent-suite/hr-agent/tests/fixtures/02-grievance-escalation/expected.md
legacy/v1/docs/phase-2-agent-suite/content-creator/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/content-creator/tests/fixtures/01-primary/expected.md
legacy/v1/docs/phase-2-agent-suite/repurposer/tests/fixtures/01-primary/input.json
legacy/v1/docs/phase-2-agent-suite/repurposer/tests/fixtures/01-primary/expected.md

codex
The file is production-shaped, so I’m checking both the contract and whether the sibling bundle/tests actually match the claims. I’ve already found places where line-level citations and runtime claims need source verification.
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '260,620p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '555,572p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '585,610p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
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

 succeeded in 0ms:
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

 succeeded in 0ms:
   260	      D1-A (bridge to cortextOS approval system): POST internal API
   261	      D1-B (lightweight Telegram shim): send approval prompt to operator
   262	      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
   263	    → per autosend-policy.yaml: orange-tier; consultant approves
   264	    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within the policy timeout
   265	      (default PT4H per autosend-policy.yaml (grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field; default `PT4H`) + escalation-codes.md
   266	      lines 348-353; looked up per action_type, not hardcoded) (D1-A/B)
   267	    → hh_decision_action("concierge_approval_routed",
   268	      "candidate:<bullhorn_id>:<event_type>", payload_hash,
   269	      "d1_path:<A|B|C>; bridge_target:<approval_id_or_vault_path>")
   270	
   271	12. (After operator approval) Send execution — orange-tier
   272	    → microsoft-graph.send_email() OR gmail.send_email() per tenant config
   273	    → BCC: tenant's archive address (per tenant config)
   274	    → hh_decision_action("gmail_outlook_send_to_candidate",
   275	      "candidate:<bullhorn_id>", payload_hash, payload_preview)
   276	      [or `bullhorn_note_customer_visible` if channel=Bullhorn-note]
   277	    → ESC_SEND_FAIL on 4xx/5xx; retry once 30s backoff
   278	
   279	13. Bullhorn activity-log write
   280	    → bullhorn.create_activity_log(candidate_id, "concierge: <event_type>
   281	      sent at <ISO>")
   282	    → maintains audit trail in Bullhorn itself (NOT customer-visible;
   283	      separate from bullhorn_note_customer_visible orange tier)
   284	    → hh_decision_action("bullhorn_activity_log_write",
   285	      "candidate:<bullhorn_id>", payload_hash,
   286	      "event_type:<type>; bullhorn_activity_id:<id>") — green tier per
   287	      autosend-policy.yaml (registered 2026-06-02 per Codex Fbis-R1 closure;
   288	      grep `^  bullhorn_activity_log_write:` to verify). External-write
   289	      action_type required for tier classification per autosend-policy §3.
   290	
   291	14. Lifecycle state advance (Bullhorn write, conditional)
   292	    → some events trigger Bullhorn state changes (e.g., interview-completed
   293	      sent → advances state to "post-interview" if tenant policy says so)
   294	    → per-tenant policy; opt-in; not all tenants want this
   295	    → hh_decision_action("concierge_send_complete", "candidate:<bullhorn_id>",
   296	      payload_hash, "event=<type> elapsed=<seconds>")
   297	
   298	15. Session close + Gate B metric
   299	    → compute elapsed (event → send) for Gate B SLA tracking
   300	    → check ghosted-rate metric (any candidate with no Concierge action in
   301	      14 days post-state-change → contributes to ghosted-rate)
   302	    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
   303	    → hh_decision_action("concierge_run_complete", "session:<tenant_slug>",
   304	      payload_hash, "mode:<webhook|poll|nurture-sweep|manual>; drafts:<N>;
   305	      sends:<N>; ghosted_rate:<float>") — green tier per autosend-policy.yaml;
   306	      4-arg signature matches `_shared/hook-helpers.sh` `hh_decision_action
   307	      <action_type> <target> <payload_hash> <payload_preview>` contract.
   308	    → exit code 0
   309	```
   310	
   311	---
   312	
   313	## §5 — Gates
   314	
   315	### Gate A — validate.sh (hard-fail before action)
   316	
   317	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
   318	
   319	- **"voice classifier score ≥ position-specific threshold"** (≥0.75 position 1, ≥0.78 position 2, ≥0.82 position 3) — hard-fail
   320	- **"correct addressee resolution (no candidates emailed under another's name)"** — hard-fail (Step 4 critical; ESC_ADDRESSEE_MISMATCH)
   321	- No tone-rule block-severity violations — hard-fail (ESC_TONE_RULE_VIOLATION)
   322	- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
   323	- Anti-duplicate guard passed (Step 2) — hard-fail (skip if true duplicate)
   324	- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_AGENT_OUTPUT_SHAPE; ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10)
   325	
   326	The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
   327	
   328	Gate A failures fire ESC codes per their catalogue-defined severity (do NOT conflate "Gate A blocks the draft from sending" with "ESC severity escalates to oncall"):
   329	
   330	- **Catalogue blocking-severity:** `ESC_ADDRESSEE_MISMATCH`, `ESC_PII_LEAKAGE_RISK` — these route to operator + ifos_oncall_chat_id per catalogue §2.10 (truly customer-impacting violations).
   331	- **Catalogue warn-severity:** `ESC_TONE_RULE_VIOLATION`, `ESC_AGENT_OUTPUT_SHAPE` — these route to operator_chat_id only per catalogue §2.10 + §2.7 (per-draft signal-quality issues; not customer-impacting unless multiple aggregate).
   332	
   333	ALL FOUR cause Gate A to block the draft from sending (validate.sh exits non-zero; draft stays in vault; cycle.sh aborts the orange-tier emission). The "blocking" of the DRAFT is `validate.sh` behavior; the "blocking" severity of the ESC code is the operator-paging-urgency lookup. These are separate dimensions. Draft is moved to `/tmp` (out of the customer-facing path) regardless of ESC severity; operator is notified immediately for blocking-tier ESCs, asynchronously-aggregated for warn-tier.
   334	
   335	**Honesty note (updated 2026-06-10; supersedes the 2026-06-02 skeleton-era note):** `agents/recruitment/concierge/validate.sh` is **LIVE** (W10-13 build slice, this branch) — the Gate A checks above enforce at runtime and are proven by `scripts/run-concierge-gate-a-test.sh` (DB-backed; ESC routing asserted per failure class). Voice honesty: no voice classifier exists in v1.0 (`@ifos/voice-classifier` unbuilt; voice_corpus empty) — unscored drafts carry `unscored/no_classifier` and G1 warn-and-passes them (accepted v1.0 behaviour); the position thresholds 0.75/0.78/0.82 hard-enforce on REAL numeric scores only (fixtures supply one via `IFOS_FORCE_VOICE_SCORE`).
   336	
   337	### Gate B — Outcome thresholds (success metrics, not block)
   338	
   339	Per ULTRAPLAN A6 line 567 + ADR-007 amendment: **"<5% candidate-ghosted rate; ≥60% send-as-is rate on drafts; ≥90% 30-min SLA hit rate"**. The third metric is ADR-007's Gate B reframe of ULTRAPLAN line 566's per-draft 30-min hard-fail (NOT in original line 567 wording).
   340	
   341	Three metrics:
   342	- **Ghosted-rate:** % of candidates with a lifecycle state change in the last 30 days who received no Concierge comm within 14 days of that change. Target <5%. (per ULTRAPLAN line 567)
   343	- **Send-as-is rate:** % of drafts approved by consultant without edits (consultant clicks "approve" not "edit-and-approve"). Target ≥60%. Measured via `recent_edit` rows with `resolution='approved_verbatim'` vs `approved_after_edit`. (per ULTRAPLAN line 567)
   344	- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
   345	
   346	Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Any of the three metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
   347	
   348	---
   349	
   350	## §6 — Escalation codes
   351	
   352	Concierge uses these ESC codes from `agents/_shared/escalation-codes.md`:
   353	
   354	| Code | Trigger | Severity | Routing |
   355	|---|---|---|---|
   356	| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
   357	| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
   358	| `ESC_MS_GRAPH_AUTH` | Microsoft Graph OAuth fail | **blocking** | operator + ifos_oncall (catalogue verbatim — token re-auth requires operator intervention; tenant-admin involvement is a manual operator-discretion follow-up, not part of the catalogue routing) |
   359	| `ESC_GMAIL_AUTH` | Gmail OAuth fail | **blocking** | operator + ifos_oncall (catalogue verbatim; same tenant-admin caveat as ESC_MS_GRAPH_AUTH) |
   360	| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
   361	| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
   362	| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
   363	| `ESC_VOICE_DRIFT` | Voice classifier below the position-specific threshold (≥0.75/0.78/0.82) after 3 retries. The Gate A hard-fail (validate.sh exits non-zero; draft not sent) is expressed through `validate_gate_a_fail`, NOT through this code's severity: per catalogue (escalation-codes.md lines 120-125) `ESC_VOICE_DRIFT` is `warn` → `operator_chat_id` for ALL positions. Position-specific paging urgency (e.g. oncall on rejections) would require a catalogue amendment adding position-severity semantics — not yet made. | warn | operator_chat_id |
   364	| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | warn (catalogue) — Gate A still blocks the draft from sending via validate.sh; ESC severity governs operator-paging urgency only | operator_chat_id |
   365	| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
   366	| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
   367	| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md `ESC_APPROVAL_BRIDGE_TIMEOUT` block + autosend-policy.yaml grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field) | warn | operator + ifos_oncall (catalogue verbatim — operator absent + commitment may need rerouting; tenant-admin involvement is a manual escalation choice when bridge-timeout becomes pattern-recurring, not part of catalogue routing) |
   368	| `ESC_SEND_FAIL` | Email provider 4xx/5xx | warn | operator_chat_id |
   369	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
   370	| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% OR 30-min SLA hit-rate <90% for 30 consecutive days | warn | founder + operator |
   371	| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
   372	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
   373	
   374	Concierge has the largest escalation surface of any v1.0 agent — appropriate for the highest-stakes customer-facing comms.
   375	
   376	Concierge does NOT use:
   377	
   378	- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
   379	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
   380	- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
   381	
   382	---
   383	
   384	## §7 — Voice + tone constraints
   385	
   386	Steps 7-8 (draft generation + voice/tone validation) are the load-bearing voice surface of v1.0. The agent integrates with `_shared/voice-loader.sh`:
   387	
   388	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
   389	  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §Gotchas line 570; demand specificity)
   390	  - No "Per our previous conversation" without referencing the actual conversation context
   391	  - No urgency language ("URGENT", "ACT NOW") unless the lifecycle event genuinely requires it
   392	  - No mention of other candidates by name
   393	  - No salary/rate specifics outside what's already on the candidate's record
   394	  - No competing-agency references
   395	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
   396	- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
   397	
   398	**Position-specific thresholds:**
   399	- Position 1 (standard sends — acknowledgement, prep, debrief, nurture): voice ≥0.75
   400	- Position 2 (placement-positive, status-update): voice ≥0.78
   401	- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §Gotchas line 570 explicitly names rejection voice as the hardest case)
   402	
   403	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   404	
   405	---
   406	
   407	## §8 — Build dependencies (W10-13 prerequisites — status as of 2026-06-10)
   408	
   409	The W10-13 build slice has run on this branch (fixture-proven; founder-arbitrated parallel-build mandate). Dependency status, updated honestly:
   410	
   411	| Dependency | Source | Status |
   412	|---|---|---|
   413	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   414	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   415	| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
   416	| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
   417	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   418	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   419	| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
   420	| **Microsoft Graph commercial signup** (per tenant) | Tenant onboarding | ⏸ |
   421	| **Gmail / Google Workspace signup** (alternative per tenant) | Tenant onboarding | ⏸ |
   422	| Microsoft Graph MCP connector | W10 build start (~3 days) | ⏸ |
   423	| Gmail MCP connector | W10 build start (~3 days) | ⏸ |
   424	| **Founder Decision D1 (autosend orange-tier path) ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md` | ✅ ACCEPTED |
   425	| **Autosend bridge package scaffold** — `@ifos/autosend-bridge-telegram` lib + types + tests landed 2026-06-01 (commit `9b282d8`); Concierge consumer wiring at cycle.sh Step 11 landed (commits `669a4f4` + `9ec2bd6`) | ✅ SCAFFOLDED (Concierge side) |
   426	| **Autosend bridge production wiring** — real Telegram Bot API transport + postgres approvals reader + dist/bin CLIs (34/34 vitest offline; live Bot API unexercised — TELEGRAM_BOT_TOKEN EMPTY) | W10-13 build slice, this branch | ✅ LANDED 2026-06-10 |
   427	| **v0.4 schema supplement** adding `operator_telegram_chat_id` + `email_channel` to `tenant_adapters.config` allowlist (per D1-B decision-doc §Implementation surface item 5) | Landed commit `a1bbcf6` | ✅ LANDED 2026-06-03 |
   428	| Autosend bridge built (per D1 outcome) | D1-B path; production wiring row above | ✅ LANDED 2026-06-10 |
   429	| Voice classifier microservice live | W4-5 polish | ⏸ |
   430	| Per-tenant comms-template library at `/vault/<slug>/concierge-templates/` | Tenant onboarding | ⏸ |
   431	| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
   432	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   433	| `validate.sh` Gate A logic | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |
   434	| `context.sh` hydration (tenant_adapters reads + honest token states) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |
   435	| `cycle.sh` orchestration (15-step) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |
   436	| Lifecycle event-detection polling fallback (poll + nurture-sweep modes via bh-bridge) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 (fixture-proven) |
   437	| Comms-template library v0.1 (12 event types × 2 recipient roles) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |
   438	| Fixtures with golden outputs — built as **3 fixtures + 3 DB-backed fixture suites** (deviation from the 5-fixture aspiration; the suites cover the gate-a / antidup / routing surface the extra fixtures targeted) | W10-13 build slice, this branch | ✅ BUILT 2026-06-10 |
   439	
   440	**Build-slice items above are ✅ (fixture-proven).** Remaining ⏸ items are commercial/runtime gates (pilot LOI, Bullhorn partnership, per-tenant email signups, voice classifier, tenant seeding) plus sibling-agent ratifications — they gate live operation, not the build. XL build complexity = 4-week duration was honoured.
   441	
   442	---
   443	
   444	## §9 — Status + open questions
   445	
   446	**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + Q1 LOI. (The W10-13 build slice landed 2026-06-10 on this branch; D1 was ACCEPTED 2026-05-31 as D1-B — neither is awaited any longer.)
   447	
   448	### Open questions for founder review
   449	
   450	Q1 (the D1 autosend orange-tier path decision) was **resolved 2026-05-31** as D1-B per `docs/decisions/2026-05-31-d1-founder-decision.md` and is removed from this table; Q2-Q10 numbering is retained for stable cross-references (§10 cites Q2-Q9).
   451	
   452	| # | Question | Resolution path |
   453	|---|---|---|
   454	| Q2 | Lifecycle event taxonomy — 12 events proposed in §3. Founder confidence each is correct + complete? Missing: "candidate referred to another role internally"? "Client cancelled brief"? | Founder review with first pilot consultants. Recommend: ship 12-event v1.0; expand v1.1+ based on real patterns. |
   455	| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
   456	| Q4 | Rejection emails (event 6) — Position 3 (voice ≥0.82). Is this enough, or should rejections route to consultant for full draft (not just approve)? | Founder review with first pilot consultant. Recommend: Concierge drafts; consultant approves; never bypasses voice gate. |
   457	| Q5 | Comms-template customisation — every tenant edits these. Per-event-type, per-recipient-role × per-tenant = 24+ templates each. Authoring tool? | v1.0: Markdown files at `/vault/<slug>/concierge-templates/<event>-<role>.md`. v1.1: Brain UI WYSIWYG editor. |
   458	| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
   459	| Q7 | Anti-duplicate guard window — 24h proposed in Step 2. Edge case: webhook + poll cycle both fire same event within 5 min → second skipped. What if first failed silently? | Anti-duplicate also checks decision_log for `phase='action'` not just `phase='trigger'` — if first didn't send, second can attempt. |
   460	| Q8 | agent-identity email adapter (deferred) (v1.1+) — agent-identity sends. Should Concierge use agent-identity email adapter (deferred) for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: agent-identity email adapter (deferred) experiment per tenant opt-in. |
   461	| Q9 | Cross-tenant lifecycle handling — what if a candidate placed at Tenant A's client interviews at Tenant B 6 weeks later? Bullhorn has separate tenant slugs; no cross-tenant leak. But operator visibility? | v1.0: strict tenant isolation (no cross-tenant data visibility). v1.1+: separate agent for tenant-network-graph if commercial demand. |
   462	| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
   463	
   464	### Gotchas (carried forward from ULTRAPLAN A6 line 569-570)
   465	
   466	1. **Lifecycle event detection from Bullhorn is the unreliable bit.** Bullhorn's webhook coverage is patchy; polling fallbacks are required. Step 1 polling at 5-min cycle + anti-duplicate guard at Step 2 is the architecture.
   467	2. **Voice quality on rejections is the hardest test case.** Position-3 threshold (≥0.82) + sensitive-event escalation routing (Step 6). Get this wrong and it costs the tenant a candidate relationship.
   468	3. **Comms-template library is per-tenant, per-event-type, per-recipient-role.** 24+ templates per tenant minimum. Authoring effort is significant; consider this in pilot onboarding scoping.
   469	4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add agent-identity email adapter (deferred).
   470	
   471	---
   472	
   473	## §10 — When this document ratifies
   474	
   475	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   476	
   477	Status flips Proposed → Accepted when:
   478	- Codex Round 4 Phase 2 ratifies
   479	- **✅ ADR-007 (Concierge Gate A 30-min SLA hybrid) ACCEPTED + RATIFIED** — Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3 per `.codex/ratification/review-architecture-decision.md` skill (commit `c862c77`). Closes the documented deviation from ULTRAPLAN A6 line 566 wording; agent.md's Gate B framing of the 30-min SLA is now the canonical disposition. This Status-flip blocker is satisfied.
   480	- ✅ **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`; package scaffold + Concierge consumer wiring landed 2026-06-01. NO LONGER a Proposed→Accepted blocker. ✅ The autosend-bridge **production wiring LANDED 2026-06-10** (this branch) and the **v0.4 schema supplement LANDED 2026-06-03** (commit `a1bbcf6`) — both satisfied dependencies. Remaining production gates: tenant population (operator_telegram_chat_id + email_channel values per tenant) + creds/OAuth provisioning + the `@ifos/telegram-surface` `/approve`—`/reject` handler
   481	- Founder approves §9 Q2 (lifecycle taxonomy) + Q3 (send window) + Q4 (rejection routing) + Q5 (template authoring UX) + Q6 (Gate B UX)
   482	- Q7-Q9 documented decisions captured
   483	
   484	Status flips Accepted → In Force when:
   485	- ✅ W10-13 build slice produces the sibling bundle files + fixtures — LANDED 2026-06-10 (this branch): 5 bundle files + 2 bins + templates + 3 fixtures + 3 DB-backed suites (3-fixture deviation from the 5-fixture aspiration recorded in §8)
   486	- First production lifecycle webhook processed end-to-end against migration-test tenant
   487	- 12-event taxonomy validated against first pilot tenant's actual Bullhorn state-change patterns
   488	- Voice classifier microservice production-ready (per-tenant; position-3 ≥0.82 sustained)
   489	- Gate B feedback loop operational (consultant approve/edit distinguishable)
   490	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   491	
   492	Until then: this document is the contract a built, fixture-proven bundle satisfies (no longer a forward-looking scaffold as of 2026-06-10) — live-transport exercise, tenant population, and the remaining §10 gates stand between Built and In Force. Concierge is the most complex v1.0 agent; its ratification cycles may surface architectural decisions not visible at contract stage. Founder review at each iteration is expected.
   493	
   494	*End of Concierge agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '240,420p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
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
/bin/zsh -lc 'rg -n "ESC_(BULLHORN_AUTH|RATE_LIMIT_HIT|MS_GRAPH_AUTH|GMAIL_AUTH|LIFECYCLE_STATE_UNKNOWN|ADDRESSEE_MISMATCH|VOICE_DRIFT|TONE_RULE_VIOLATION|PII_LEAKAGE_RISK|CONCIERGE_SLA_MISS|APPROVAL_BRIDGE_TIMEOUT|SEND_FAIL|AGENT_OUTPUT_SHAPE|GATE_B_MISS|AUTOSEND_ORANGE_PENDING|AUTOSEND_SAMPLED_SPOT_CHECK|CANDIDATE_DATA_INCOMPLETE|AUTOSEND_BLOCKED|SCHEMA_VIOLATION|VOICE_DRIFT_TENANT)" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
41:#### `ESC_AUTOSEND_BLOCKED`
97:#### `ESC_BULLHORN_AUTH`
120:#### `ESC_VOICE_DRIFT`
149:#### `ESC_PII_LEAKAGE_RISK`
157:#### `ESC_RATE_LIMIT_HIT`
164:#### `ESC_SCHEMA_VIOLATION`
171:#### `ESC_VOICE_DRIFT_TENANT`
173:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
185:#### `ESC_AGENT_OUTPUT_SHAPE`
187:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
233:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
265:#### `ESC_GMAIL_AUTH`
273:#### `ESC_MS_GRAPH_AUTH`
313:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
332:#### `ESC_SEND_FAIL`
342:#### `ESC_AUTOSEND_ORANGE_PENDING`
349:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
367:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
378:#### `ESC_GATE_B_MISS`
386:#### `ESC_TONE_RULE_VIOLATION`
401:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
408:#### `ESC_ADDRESSEE_MISMATCH`
432:#### `ESC_CONCIERGE_SLA_MISS`
449:#### `ESC_LIFECYCLE_STATE_UNKNOWN`

exec
/bin/zsh -lc 'rg -n "operator_telegram_chat_id|email_channel|concierge_send_window|tenant_adapters" docs/verticals/recruitment/vertical-schema*.yaml' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:782:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:918:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1042:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:1:# IFOS recruitment vertical schema v0.4 — tenant_adapters.config keys for
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:9:# v0.4 is an ADDITIVE-ONLY tenant_adapters.config extension. It does NOT
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:15:# tenant_adapters at runtime, replacing the IFOS_FORCE_* env-var fallbacks
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:41:  v0.4 scope is INTENTIONALLY NARROW: 5 new tenant_adapters.config keys, no
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:65:# §1 — tenant_adapters.config additions (5 new top-level keys)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:68:# Each key is hard-fail-on-unknown via the validate_tenant_adapters_config_v0_4
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:72:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:74:  operator_telegram_chat_id:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:84:      context.sh: SELECT config->>'operator_telegram_chat_id' FROM
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:85:      tenant_adapters WHERE tenant_slug=$1.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:101:  email_channel:
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:117:      tenant_adapters read path. The TODO(W10-13) marker in context.sh
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:162:      (mode 0600); writes workspace_id to tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:237:    - v0.3 migration applied (validate_tenant_adapters_config_v0_3 trigger active)
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:246:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_4() —
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:248:      (operator_telegram_chat_id, email_channel, workos_org_id,
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:252:      DROP TRIGGER validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:253:      CREATE TRIGGER validate_tenant_adapters_config_v0_4 (re-bind).
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:255:      DROP FUNCTION validate_tenant_adapters_config_v0_3() (no longer
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:298:        Yes — mirror tier into tenant_adapters.config so consumer code can
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:316:        services all tenant orgs. CURRENT v0.4 behavior (no tenant_adapters
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:328:    question: Should bullhorn_region be a tenant_adapters.config key?
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:352:  read per-tenant identifiers from tenant_adapters.config — but the v0.3
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:353:  validate_tenant_adapters_config_v0_3 trigger hard-fails on any of the
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:362:      operator_telegram_chat_id) BOTH become schema-clean.
docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml:366:      from tenant_adapters at runtime.

exec
/bin/zsh -lc 'rg -n "function hh_|hh_load_|hh_decision_|autosend_policy_lookup|payload" agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
agents/_shared/voice-loader.sh:3:# IFOS voice-loader — implements the 3 hh_load_* helpers per master brief
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
agents/_shared/hook-helpers.sh:3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
agents/_shared/hook-helpers.sh:20:# raw PII into shell vars (payload_preview must be sanitised by caller).
agents/_shared/hook-helpers.sh:127:# _hh_emit_row <phase> <outcome> <reason> <payload_json>
agents/_shared/hook-helpers.sh:136:  local payload_json="${4:-{\}}"
agents/_shared/hook-helpers.sh:148:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
agents/_shared/hook-helpers.sh:155:  '$(_hh_sql_escape "${payload_json}")'::jsonb,
agents/_shared/hook-helpers.sh:175:  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
agents/_shared/hook-helpers.sh:181:    "${payload_json}" \
agents/_shared/hook-helpers.sh:189:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:192:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:194:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:197:  local payload
agents/_shared/hook-helpers.sh:198:  payload=$(printf '{"trigger_type":"%s","helpers_version":"%s"}' \
agents/_shared/hook-helpers.sh:200:  _hh_emit_row "trigger" "" "${reason}" "${payload}"
agents/_shared/hook-helpers.sh:203:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:206:hh_decision_output() {
agents/_shared/hook-helpers.sh:210:  local payload
agents/_shared/hook-helpers.sh:211:  payload=$(printf '{"output_type":"%s","artefact_ref":"%s"}' \
agents/_shared/hook-helpers.sh:213:  _hh_emit_row "output" "produced" "${reason}" "${payload}"
agents/_shared/hook-helpers.sh:216:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:219:hh_decision_action() {
agents/_shared/hook-helpers.sh:222:  local payload_hash="$3"
agents/_shared/hook-helpers.sh:223:  local payload_preview="$4"
agents/_shared/hook-helpers.sh:228:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
agents/_shared/hook-helpers.sh:230:      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
agents/_shared/hook-helpers.sh:232:      "${target}" "${payload_hash}" "unknown_action_type"
agents/_shared/hook-helpers.sh:238:      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
agents/_shared/hook-helpers.sh:240:      "${target}" "${payload_hash}" "override_resolution_failed"
agents/_shared/hook-helpers.sh:247:        "${target}" "${payload_hash}" "${payload_preview}" ""
agents/_shared/hook-helpers.sh:252:        "${target}" "${payload_hash}" "${payload_preview}" ""
agents/_shared/hook-helpers.sh:255:          "${payload_hash}" "${payload_preview}" "${tenant}"
agents/_shared/hook-helpers.sh:261:        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
agents/_shared/hook-helpers.sh:263:        "${target}" "${payload_hash}" "${payload_preview}"
agents/_shared/hook-helpers.sh:264:      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
agents/_shared/hook-helpers.sh:269:        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
agents/_shared/hook-helpers.sh:271:        "${target}" "${payload_hash}" "red_tier_classification"
agents/_shared/hook-helpers.sh:276:        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
agents/_shared/hook-helpers.sh:278:        "${target}" "${payload_hash}" "unknown_tier:${tier}"
agents/_shared/hook-helpers.sh:288:# autosend_policy_lookup <action_type>
agents/_shared/hook-helpers.sh:291:autosend_policy_lookup() {
agents/_shared/hook-helpers.sh:294:    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
agents/_shared/hook-helpers.sh:355:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:356:# Emits the standard autosend decision_log row with payload.tier set.
agents/_shared/hook-helpers.sh:362:  local payload_hash="$5"
agents/_shared/hook-helpers.sh:363:  local payload_preview="$6"
agents/_shared/hook-helpers.sh:366:  local payload
agents/_shared/hook-helpers.sh:367:  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
agents/_shared/hook-helpers.sh:371:    "$(_hh_json_escape "${payload_hash}")" \
agents/_shared/hook-helpers.sh:372:    "$(_hh_json_escape "${payload_preview}")" \
agents/_shared/hook-helpers.sh:376:  _hh_emit_row "${phase}" "${tier}" "${reason_or_status}" "${payload}"
agents/_shared/hook-helpers.sh:389:    local meta_payload
agents/_shared/hook-helpers.sh:390:    meta_payload=$(printf '{"unknown_code":"%s","helpers_version":"%s"}' \
agents/_shared/hook-helpers.sh:392:    _hh_emit_row "gating_failed" "fail-safe-red" "esc_code_unknown" "${meta_payload}"
agents/_shared/hook-helpers.sh:398:  local payload="{\"escalation_code\":\"${escaped_code}\""
agents/_shared/hook-helpers.sh:404:      payload+=",\"$(_hh_json_escape "${k}")\":\"$(_hh_json_escape "${v}")\""
agents/_shared/hook-helpers.sh:407:  payload+="}"
agents/_shared/hook-helpers.sh:409:  _hh_emit_row "gating_failed" "${code}" "" "${payload}"
agents/_shared/hook-helpers.sh:442:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
agents/_shared/hook-helpers.sh:444:# review. Idempotent on payload_hash — duplicate enqueues become single file.
agents/_shared/hook-helpers.sh:448:  local payload_hash="$3"
agents/_shared/hook-helpers.sh:449:  local payload_preview="$4"
agents/_shared/hook-helpers.sh:460:  local outfile="${spot_dir}/${timestamp}-${action_type}-${payload_hash:0:12}.md"
agents/_shared/hook-helpers.sh:471:    printf -- '- **Payload hash:** %s\n' "${payload_hash}"
agents/_shared/hook-helpers.sh:473:    printf '## Preview\n\n%s\n' "${payload_preview}"
agents/_shared/hook-helpers.sh:477:# autosend_await_approval <action_type> <target> <payload_hash>
agents/_shared/hook-helpers.sh:486:  local payload_hash="$3"
agents/_shared/hook-helpers.sh:509:  local marker="${pending_dir}/${payload_hash}.pending"
agents/_shared/hook-helpers.sh:510:  local approved="${pending_dir}/${payload_hash}.approved"
agents/_shared/hook-helpers.sh:511:  local rejected="${pending_dir}/${payload_hash}.rejected"
agents/_shared/hook-helpers.sh:516:    printf 'payload_hash=%s\n' "${payload_hash}"
agents/_shared/hook-helpers.sh:538:          "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"
agents/_shared/hook-helpers.sh:566:    "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"

exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|packages/harness/cortextos|cortextOS.*brain|stock KB|kb-" agents/recruitment/concierge/agent.md' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 exited 1 in 0ms:
exec
/bin/zsh -lc 'rg -n "twilio_sms_send|calendar_invite_send|concierge_email_draft|gmail_outlook_send_to_candidate|bullhorn_note_customer_visible|concierge_approval_routed|bullhorn_activity_log_write|concierge_send_complete|concierge_run_complete" agents/recruitment/concierge/cycle.sh agents/recruitment/concierge/validate.sh agents/recruitment/concierge/tools.yaml agents/recruitment/concierge/context.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
agents/recruitment/concierge/validate.sh:313:  AND d.payload->>'action_type'='concierge_email_draft'
agents/recruitment/concierge/validate.sh:320:      AND s.payload->>'action_type'='gmail_outlook_send_to_candidate'
agents/recruitment/concierge/tools.yaml:90:    action_type: bullhorn_activity_log_write  # green tier; REGISTERED in autosend-policy.yaml (Codex Fbis-R1 closure 2026-06-02)
agents/recruitment/concierge/tools.yaml:105:    action_type: gmail_outlook_send_to_candidate  # ORANGE; REGISTERED in autosend-policy.yaml; consolidated channel-agnostic action_type
agents/recruitment/concierge/tools.yaml:121:    action_type: gmail_outlook_send_to_candidate  # ORANGE; same action_type — channel-agnostic at audit layer
agents/recruitment/concierge/tools.yaml:152:    action_type: concierge_approval_routed  # GREEN internal audit row (REGISTERED per R19 fix) — records the orange-tier approval routing; the orange row itself is gmail_outlook_send_to_candidate at Step 12
agents/recruitment/concierge/tools.yaml:224:#   concierge_email_draft              yellow              [Concierge §3 output contract; emitted Step 8]
agents/recruitment/concierge/tools.yaml:225:#   concierge_approval_routed          green               [R19 registration; emitted Step 11]
agents/recruitment/concierge/tools.yaml:226:#   gmail_outlook_send_to_candidate    orange              [TRANSPORT row; emitted Step 12 post-approval]
agents/recruitment/concierge/tools.yaml:227:#   bullhorn_note_customer_visible     orange              [canonical orange; alt channel — not yet emitted in v1.0]
agents/recruitment/concierge/tools.yaml:228:#   bullhorn_activity_log_write        green               [Codex Fbis-R1 closure; emitted Step 13]
agents/recruitment/concierge/tools.yaml:229:#   concierge_send_complete            green               [emitted Step 14]
agents/recruitment/concierge/tools.yaml:230:#   concierge_run_complete             green               [emitted Step 15]
agents/recruitment/concierge/tools.yaml:239:#   twilio_sms_send                    orange              (v1.1+)
agents/recruitment/concierge/tools.yaml:240:#   calendar_invite_send               orange              (v1.1+)
agents/recruitment/concierge/cycle.sh:164:  hh_decision_action "concierge_run_complete" "session:${CTX_TENANT_SLUG}" "${run_hash}" \
agents/recruitment/concierge/cycle.sh:282:     AND payload->>'action_type'='concierge_email_draft'
agents/recruitment/concierge/cycle.sh:288:     AND payload->>'action_type'='gmail_outlook_send_to_candidate'
agents/recruitment/concierge/cycle.sh:506:  hh_decision_action "concierge_email_draft" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
agents/recruitment/concierge/cycle.sh:588:    _timeout_s=14400   # PT4H per autosend-policy.yaml gmail_outlook_send_to_candidate.timeout
agents/recruitment/concierge/cycle.sh:590:        --action gmail_outlook_send_to_candidate \
agents/recruitment/concierge/cycle.sh:599:      hh_decision_action "concierge_approval_routed" \
agents/recruitment/concierge/cycle.sh:653:# gmail_outlook_send_to_candidate row is emitted BEFORE the transport
agents/recruitment/concierge/cycle.sh:686:  if hh_decision_action "gmail_outlook_send_to_candidate" "candidate:${CANDIDATE_ID}" \
agents/recruitment/concierge/cycle.sh:724:# NOT customer-visible — separate from bullhorn_note_customer_visible).
agents/recruitment/concierge/cycle.sh:734:    hh_decision_action "bullhorn_activity_log_write" "candidate:${CANDIDATE_ID}" \
agents/recruitment/concierge/cycle.sh:761:  hh_decision_action "concierge_send_complete" "candidate:${CANDIDATE_ID}" \

exec
/bin/zsh -lc "ls -la agents/recruitment/concierge scripts 2>/dev/null && rg -n \"run-concierge|concierge\" scripts agents/recruitment/concierge -g '*.sh' -g '*.ts' -g '*.js' -g '*.yaml' | head -200" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
agents/recruitment/concierge:
total 320
drwxr-xr-x@ 12 madsadmin  staff    384 Jun 10 16:38 .
drwxr-xr-x@  8 madsadmin  staff    256 Jun 10 14:17 ..
-rw-r--r--@  1 madsadmin  staff   2720 Jun 10 15:52 README.md
-rw-r--r--@  1 madsadmin  staff  45585 Jun 10 16:33 agent.md
drwxr-xr-x@  4 madsadmin  staff    128 Jun 10 16:35 bin
-rwxr-xr-x@  1 madsadmin  staff   5825 Jun 10 15:52 cleanup.sh
-rwxr-xr-x@  1 madsadmin  staff  12396 Jun 10 16:35 context.sh
-rwxr-xr-x@  1 madsadmin  staff  44206 Jun 10 16:37 cycle.sh
drwxr-xr-x@  5 madsadmin  staff    160 Jun 10 15:52 fixtures
drwxr-xr-x@  3 madsadmin  staff     96 Jun 10 15:52 templates
-rw-r--r--@  1 madsadmin  staff  16833 Jun 10 16:38 tools.yaml
-rwxr-xr-x@  1 madsadmin  staff  18711 Jun 10 15:52 validate.sh

scripts:
total 480
drwxr-xr-x@ 24 madsadmin  staff    768 Jun 10 15:52 .
drwxr-xr-x@ 22 madsadmin  staff    704 Jun 10 14:24 ..
-rwxr-xr-x@  1 madsadmin  staff   3876 Jun 10 14:17 build-gate.sh
-rwxr-xr-x@  1 madsadmin  staff   9376 Jun 10 14:17 ifos-pii-purge.sh
-rwxr-xr-x@  1 madsadmin  staff   6867 Jun 10 14:17 oauth-preflight.sh
-rwxr-xr-x@  1 madsadmin  staff  14015 Jun 10 14:17 provision-tenant.sh
-rwxr-xr-x@  1 madsadmin  staff   3212 Jun 10 14:17 run-chase-draft-test.sh
-rwxr-xr-x@  1 madsadmin  staff   2501 Jun 10 14:17 run-chase-lifecycle-test.sh
-rwxr-xr-x@  1 madsadmin  staff   4840 Jun 10 14:17 run-chase-scan-test.sh
-rwxr-xr-x@  1 madsadmin  staff  23902 Jun 10 14:17 run-codex-ratification.sh
-rwxr-xr-x@  1 madsadmin  staff   7111 Jun 10 15:52 run-concierge-antidup-test.sh
-rwxr-xr-x@  1 madsadmin  staff   7312 Jun 10 15:52 run-concierge-gate-a-test.sh
-rwxr-xr-x@  1 madsadmin  staff   7956 Jun 10 15:52 run-concierge-routing-test.sh
-rwxr-xr-x@  1 madsadmin  staff  10688 Jun 10 14:17 run-diagnostic-smoke.sh
-rwxr-xr-x@  1 madsadmin  staff   5589 Jun 10 14:17 run-gate-a-test.sh
-rwxr-xr-x@  1 madsadmin  staff  22736 Jun 10 14:17 run-live-migration.sh
-rwxr-xr-x@  1 madsadmin  staff   6155 Jun 10 14:17 run-oauth-dances.sh
-rwxr-xr-x@  1 madsadmin  staff   6445 Jun 10 14:17 run-reconciliation-recon-test.sh
-rwxr-xr-x@  1 madsadmin  staff  28080 Jun 10 14:17 run-tenancy-audit.sh
-rwxr-xr-x@  1 madsadmin  staff   6976 Jun 10 14:17 run-v0.3-migration-as-postgres.sh
-rwxr-xr-x@  1 madsadmin  staff  18186 Jun 10 14:17 run-v0.3-migration.sh
-rwxr-xr-x@  1 madsadmin  staff   7548 Jun 10 14:17 run-v0.4-migration-as-postgres.sh
-rwxr-xr-x@  1 madsadmin  staff   3272 Jun 10 14:17 run-weekly-report-test.sh
-rwxr-xr-x@  1 madsadmin  staff   6871 Jun 10 14:17 setup-local-dev-db.sh
agents/recruitment/concierge/cleanup.sh:8:# `concierge_cleanup` (green tier — internal-only audit row recording
agents/recruitment/concierge/cleanup.sh:11:# Per agents/_shared/autosend-policy.yaml: `concierge_cleanup` is still QUEUED
agents/recruitment/concierge/cleanup.sh:31:#   - Vault concierge drafts at /vault/<tenant>/concierge-drafts/ (kept for audit)
agents/recruitment/concierge/cleanup.sh:41:  printf 'concierge/cleanup.sh: CTX_AGENT_DIR unset\n' >&2
agents/recruitment/concierge/cleanup.sh:45:  printf 'concierge/cleanup.sh: CTX_TENANT_SLUG unset\n' >&2
agents/recruitment/concierge/cleanup.sh:48:: "${CTX_AGENT_NAME:=concierge}"
agents/recruitment/concierge/cleanup.sh:100:# concierge_cleanup is NOT yet registered in autosend-policy.yaml (QUEUED per
agents/recruitment/concierge/cleanup.sh:106:hh_decision_output "concierge_cleanup" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/concierge/cleanup.sh:110:printf '[concierge cleanup.sh] tenant=%s purged total=%d (bullhorn=%d msgraph=%d gmail=%d)\n' \
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:26:agent: concierge
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:31:  command: ifosctl concierge process-event
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:101:    vault_path_pattern: "/vault/migration-test/concierge-drafts/*.md"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:126:      action_type: concierge_draft_rendered
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:128:      action_type: concierge_email_draft   # yellow tier (Gate A passed)
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:132:      action_type: concierge_approval_routed
agents/recruitment/concierge/fixtures/01-primary.yaml:6:# draft in the 24h window. Step 8 emits yellow concierge_email_draft; Step 11
agents/recruitment/concierge/fixtures/01-primary.yaml:19:agent: concierge
agents/recruitment/concierge/fixtures/01-primary.yaml:24:  command: ifosctl concierge process-event
agents/recruitment/concierge/fixtures/01-primary.yaml:76:    vault_path_pattern: "/vault/migration-test/concierge-drafts/*.md"
agents/recruitment/concierge/fixtures/01-primary.yaml:105:      action_type: concierge_draft_rendered
agents/recruitment/concierge/fixtures/01-primary.yaml:107:      action_type: concierge_email_draft   # yellow tier
agents/recruitment/concierge/fixtures/01-primary.yaml:111:      action_type: concierge_approval_routed   # orange-adjacent metadata
agents/recruitment/concierge/fixtures/01-primary.yaml:117:      action_type: concierge_send_complete
agents/recruitment/concierge/fixtures/01-primary.yaml:119:      action_type: concierge_run_complete
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:23:agent: concierge
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:28:  command: ifosctl concierge process-event
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:95:    vault_path_pattern: "/vault/migration-test/concierge-drafts/*.md"   # draft IS written; just not sent
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:117:      action_type: concierge_draft_rendered
agents/recruitment/concierge/validate.sh:18:#   - $1: path to the vault concierge-draft file (cycle.sh Step 7 wrote it)
agents/recruitment/concierge/validate.sh:38:#        hh_load_tone_rules ∋ concierge: examples_negative phrase match;
agents/recruitment/concierge/validate.sh:57:  printf 'concierge/validate.sh: usage: validate.sh <draft_path>\n' >&2
agents/recruitment/concierge/validate.sh:222:# Tenant rules via hh_load_tone_rules (tone_rule table, ∋ concierge):
agents/recruitment/concierge/validate.sh:242:  _rules_json="$(hh_load_tone_rules concierge 2>/dev/null || echo '{"rules":[]}')"
agents/recruitment/concierge/validate.sh:312:WHERE d.agent_name='concierge'
agents/recruitment/concierge/validate.sh:313:  AND d.payload->>'action_type'='concierge_email_draft'
agents/recruitment/concierge/validate.sh:319:    WHERE s.agent_name='concierge'
agents/recruitment/concierge/validate.sh:371:  autosend_escalate "${ESC_CLASS}" "agent=concierge" \
agents/recruitment/concierge/validate.sh:380:  _quarantine="/tmp/concierge-gate-a-failed-$(basename "${DRAFT}")"
agents/recruitment/concierge/tools.yaml:39:agent: concierge
agents/recruitment/concierge/tools.yaml:152:    action_type: concierge_approval_routed  # GREEN internal audit row (REGISTERED per R19 fix) — records the orange-tier approval routing; the orange row itself is gmail_outlook_send_to_candidate at Step 12
agents/recruitment/concierge/tools.yaml:213:  - id: concierge_cleanup
agents/recruitment/concierge/tools.yaml:215:    action_type: concierge_cleanup  # green tier; QUEUED registration for cleanup.sh wire at W10-13
agents/recruitment/concierge/tools.yaml:224:#   concierge_email_draft              yellow              [Concierge §3 output contract; emitted Step 8]
agents/recruitment/concierge/tools.yaml:225:#   concierge_approval_routed          green               [R19 registration; emitted Step 11]
agents/recruitment/concierge/tools.yaml:229:#   concierge_send_complete            green               [emitted Step 14]
agents/recruitment/concierge/tools.yaml:230:#   concierge_run_complete             green               [emitted Step 15]
agents/recruitment/concierge/tools.yaml:238:#   concierge_cleanup                  green               (registration queued; cleanup.sh emits output row)
agents/recruitment/concierge/context.sh:44:#   CTX_AGENT_NAME                       — "concierge"
agents/recruitment/concierge/context.sh:49:#   CTX_COMMS_TEMPLATE_LIBRARY_PATH      — /vault/<slug>/concierge-templates/
agents/recruitment/concierge/context.sh:63:  printf 'concierge/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
agents/recruitment/concierge/context.sh:67:  printf 'concierge/context.sh: CTX_TENANT_SLUG unset\n' >&2
agents/recruitment/concierge/context.sh:70:export CTX_AGENT_NAME="concierge"
agents/recruitment/concierge/context.sh:125:[[ -f "${_bh_bridge}" ]] || _bh_bridge="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/bin/bh-bridge.sh"
agents/recruitment/concierge/context.sh:142:      autosend_escalate "ESC_BULLHORN_AUTH" "agent=concierge" \
agents/recruitment/concierge/context.sh:165:export CTX_COMMS_TEMPLATE_LIBRARY_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/concierge-templates/"
agents/recruitment/concierge/context.sh:198:  "agent:concierge; tenant:${CTX_TENANT_SLUG}; mode:${CTX_CONCIERGE_MODE:-webhook}; email_channel:${CTX_EMAIL_CHANNEL}"
agents/recruitment/concierge/context.sh:201:printf '[concierge context.sh] tenant=%s channel=%s bullhorn_token=%s email_token=%s voice_corpus=%s\n' \
agents/recruitment/concierge/cycle.sh:16:#   mode=manual          — ifosctl concierge process-event|nurture-sweep
agents/recruitment/concierge/cycle.sh:47:  printf 'concierge/cycle.sh: CTX_AGENT_DIR unset (context.sh must run first)\n' >&2
agents/recruitment/concierge/cycle.sh:51:  printf 'concierge/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
agents/recruitment/concierge/cycle.sh:54:: "${CTX_AGENT_NAME:=concierge}"
agents/recruitment/concierge/cycle.sh:69:  printf 'concierge/cycle.sh: cannot locate _shared/ helpers\n' >&2
agents/recruitment/concierge/cycle.sh:87:[[ -f "${_BH_BRIDGE}" ]] || _BH_BRIDGE="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/bin/bh-bridge.sh"
agents/recruitment/concierge/cycle.sh:88:_RENDER="${CTX_AGENT_DIR}/bin/render-concierge-draft.sh"
agents/recruitment/concierge/cycle.sh:89:[[ -f "${_RENDER}" ]] || _RENDER="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/bin/render-concierge-draft.sh"
agents/recruitment/concierge/cycle.sh:91:[[ -f "${_VALIDATE}" ]] || _VALIDATE="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/validate.sh"
agents/recruitment/concierge/cycle.sh:117:# state change in 30d and no concierge action within 14d of it. >5% →
agents/recruitment/concierge/cycle.sh:119:# (tenant_adapters.config.concierge_last_poll — v0.3-allowlisted key).
agents/recruitment/concierge/cycle.sh:136:      WHERE d.agent_name='concierge' AND d.phase='action'
agents/recruitment/concierge/cycle.sh:147:      autosend_escalate "ESC_GATE_B_MISS" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:155:SET config = jsonb_set(coalesce(config,'{}'::jsonb), '{concierge_last_poll}',
agents/recruitment/concierge/cycle.sh:164:  hh_decision_action "concierge_run_complete" "session:${CTX_TENANT_SLUG}" "${run_hash}" \
agents/recruitment/concierge/cycle.sh:187:  hh_decision_trigger "session_start" "mode:${MODE}; agent:concierge"
agents/recruitment/concierge/cycle.sh:194:# concierge_last_poll; nurture-sweep asks bh-bridge list-nurture-due.
agents/recruitment/concierge/cycle.sh:212:SELECT coalesce(config->>'concierge_last_poll','') FROM tenant_adapters WHERE tenant_slug = :'tenant' LIMIT 1;
agents/recruitment/concierge/cycle.sh:246:    autosend_escalate "ESC_LIFECYCLE_STATE_UNKNOWN" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:281:   WHERE agent_name='concierge'
agents/recruitment/concierge/cycle.sh:282:     AND payload->>'action_type'='concierge_email_draft'
agents/recruitment/concierge/cycle.sh:287:   WHERE agent_name='concierge'
agents/recruitment/concierge/cycle.sh:337:    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:359:    autosend_escalate "ESC_ADDRESSEE_MISMATCH" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:374:# /vault/<slug>/concierge-templates/<event>-<role>.md; shared fallback is
agents/recruitment/concierge/cycle.sh:382:  _tenant_tpl="${_vault_root}/${CTX_TENANT_SLUG}/concierge-templates/${EVENT_TYPE}-${RECIPIENT_ROLE}.md"
agents/recruitment/concierge/cycle.sh:385:  [[ -f "${_bundled_tpl}" ]] || _bundled_tpl="${IFOS_REPO_ROOT:-}/agents/recruitment/concierge/templates/common-comms-templates.yaml"
agents/recruitment/concierge/cycle.sh:448:  _drafts_dir="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/concierge-drafts"   # /vault default per hook-helpers contract
agents/recruitment/concierge/cycle.sh:472:    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:484:  hh_decision_output "concierge_draft_rendered" "${DRAFT_PATH}" \
agents/recruitment/concierge/cycle.sh:506:  hh_decision_action "concierge_email_draft" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
agents/recruitment/concierge/cycle.sh:527:        hh_decision_output "concierge_sla_miss" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
agents/recruitment/concierge/cycle.sh:529:        autosend_escalate "ESC_CONCIERGE_SLA_MISS" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:558:    autosend_escalate "ESC_PII_LEAKAGE_RISK" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:562:    mv -f "${DRAFT_PATH}" "/tmp/concierge-pii-failed-$(basename "${DRAFT_PATH}")" 2>/dev/null || true
agents/recruitment/concierge/cycle.sh:599:      hh_decision_action "concierge_approval_routed" \
agents/recruitment/concierge/cycle.sh:618:          autosend_escalate "ESC_APPROVAL_BRIDGE_TIMEOUT" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:711:      autosend_escalate "ESC_SEND_FAIL" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:731:    --note "concierge: ${EVENT_TYPE} sent at $(date -u +%Y-%m-%dT%H:%M:%SZ)" 2>/dev/null || echo '{}')"
agents/recruitment/concierge/cycle.sh:737:    autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:757:      autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:761:  hh_decision_action "concierge_send_complete" "candidate:${CANDIDATE_ID}" \
scripts/run-live-migration.sh:369:TONE_OUT=$(hh_load_tone_rules concierge 2>&1)
scripts/run-live-migration.sh:385:EDITS_OUT=$(hh_load_recent_edits 30 concierge 2>&1)
scripts/run-codex-ratification.sh:92:agents/recruitment/concierge/agent.md|agent-bundle
scripts/run-codex-ratification.sh:93:docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md|architecture-decision
scripts/run-codex-ratification.sh:118:agents/recruitment/concierge/agent.md|agent-bundle"
scripts/run-concierge-routing-test.sh:14:readonly TENANT="concierge-routing-test"
scripts/run-concierge-routing-test.sh:18:export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/concierge"
scripts/run-concierge-routing-test.sh:19:export CTX_AGENT_NAME="concierge" CTX_TENANT_SLUG="${TENANT}"
scripts/run-concierge-routing-test.sh:115:mkdir -p "${TEST_VAULT}/${TENANT}/concierge-templates"
scripts/run-concierge-routing-test.sh:117:  > "${TEST_VAULT}/${TENANT}/concierge-templates/interview-booked-candidate.md"
agents/recruitment/concierge/templates/common-comms-templates.yaml:5:#   1. tenant override:  ${IFOS_VAULT_ROOT}/<slug>/concierge-templates/<event>-<role>.md
agents/recruitment/concierge/templates/common-comms-templates.yaml:10:# bin/render-concierge-draft.sh with awk — keep the exact field layout:
agents/recruitment/concierge/bin/render-concierge-draft.sh:5:# Prints one concierge-draft markdown document (YAML frontmatter + body) to
agents/recruitment/concierge/bin/render-concierge-draft.sh:8:# /vault/<tenant>/concierge-drafts/<draft_id>.md (chmod 0600) and emits
agents/recruitment/concierge/bin/render-concierge-draft.sh:25:#   render-concierge-draft.sh --draft-id ID --event-type E --candidate-id C \
agents/recruitment/concierge/bin/render-concierge-draft.sh:59:    *) printf 'render-concierge-draft.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
agents/recruitment/concierge/bin/render-concierge-draft.sh:65:    printf 'render-concierge-draft.sh: --%s required\n' \
agents/recruitment/concierge/bin/render-concierge-draft.sh:71:  printf 'render-concierge-draft.sh: template file not found: %s\n' "${TEMPLATE_FILE}" >&2
agents/recruitment/concierge/bin/render-concierge-draft.sh:92:    printf 'render-concierge-draft.sh: no template for (%s, %s) in %s\n' \
scripts/run-concierge-gate-a-test.sh:4:# Exercises agents/recruitment/concierge/validate.sh against hand-crafted
scripts/run-concierge-gate-a-test.sh:18:readonly TENANT="concierge-gate-a-test"
scripts/run-concierge-gate-a-test.sh:21:export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/concierge"
scripts/run-concierge-gate-a-test.sh:22:export CTX_AGENT_NAME="concierge" CTX_TENANT_SLUG="${TENANT}"
scripts/run-concierge-gate-a-test.sh:40:  rm -f /tmp/concierge-gate-a-failed-cgt-*.md /tmp/concierge-pii-failed-cgt-*.md 2>/dev/null
scripts/run-concierge-gate-a-test.sh:57:VALUES (:'tenant', 'no-circle-back', 'Never use corporate filler like circle back', 'block', '{concierge}', 'tenant-admin', '{"circle back"}')
scripts/run-concierge-antidup-test.sh:18:readonly TENANT="concierge-antidup-test"
scripts/run-concierge-antidup-test.sh:22:export CTX_AGENT_DIR="${REPO_ROOT}/agents/recruitment/concierge"
scripts/run-concierge-antidup-test.sh:23:export CTX_AGENT_NAME="concierge" CTX_TENANT_SLUG="${TENANT}"
scripts/run-concierge-antidup-test.sh:58:  (:'tenant','concierge','action','yellow',
scripts/run-concierge-antidup-test.sh:59:   jsonb_build_object('action_type','concierge_email_draft','target','candidate:CAND-X:interview-booked','tier','yellow'),
scripts/run-concierge-antidup-test.sh:61:  (:'tenant','concierge','action','orange',
scripts/run-concierge-antidup-test.sh:65:  (:'tenant','concierge','action','yellow',
scripts/run-concierge-antidup-test.sh:66:   jsonb_build_object('action_type','concierge_email_draft','target','candidate:CAND-Y:interview-booked','tier','yellow'),
scripts/run-concierge-antidup-test.sh:69:  (:'tenant','concierge','action','yellow',
scripts/run-concierge-antidup-test.sh:70:   jsonb_build_object('action_type','concierge_email_draft','target','candidate:CAND-Z:interview-booked','tier','yellow'),
scripts/run-concierge-antidup-test.sh:72:  (:'tenant','concierge','action','orange',

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '300,325p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/cycle.sh | sed -n '720,770p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
   300	  - **≤30 days remaining:** info — non-urgent operator awareness; nightly health check emits this
   301	  - **≤14 days remaining:** warn — operator nudge to schedule reauth this week
   302	  - **≤7 days remaining:** blocking — Cash Conductor enters degraded mode (cached balance only; no fresh bank-feed reads); operator must complete SCA reauth before token expires
   303	- **Phase:** `gating_failed`
   304	- **Routing:** `operator_chat_id` (info + warn stages); ADD `ifos_oncall_chat_id` at blocking stage
   305	- **Payload fields:** `consent_expires_at`, `days_remaining`, `bank_provider`, `stage` (`info` | `warn` | `blocking`)
   306	- **Recovery:** founder schedules + completes Open Banking SCA reauth via tenant's bank login
   307	
   308	### 2.8 — Provider read/write failures (4 codes)
   309	Source: derived from v1.0 agent.md adapter call sites
   310	
   311	#### `ESC_BULLHORN_WRITE_FAIL`
   312	- **Severity:** warn
   313	- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
   314	- **Phase:** `gating_failed`
   315	- **Routing:** `operator_chat_id`
   316	- **Payload fields:** `endpoint`, `entity_type`, `entity_id`, `status_code`, `error_body_preview` (truncated 120 chars)
   317	
   318	#### `ESC_ACCOUNTING_WRITE_FAIL`
   319	- **Severity:** warn
   320	- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
   321	- **Phase:** `gating_failed`
   322	- **Routing:** `operator_chat_id`
   323	- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`
   324	
   325	#### `ESC_PROVIDER_FETCH_FAIL`

 succeeded in 0ms:
   720	fi
   721	
   722	# ────────────────────────────────────────────────────────────────────────
   723	# Step 13 — Bullhorn activity-log write (green; audit trail in the ATS;
   724	# NOT customer-visible — separate from bullhorn_note_customer_visible).
   725	# Reference: agent.md §4 Step 13, via bh-bridge create-activity-log.
   726	# ESC_BULLHORN_WRITE_FAIL (warn) on write failure.
   727	# ────────────────────────────────────────────────────────────────────────
   728	
   729	if _step_on 13 && [[ "${SEND_DONE}" -eq 1 ]]; then
   730	  _al_out="$(bash "${_BH_BRIDGE}" create-activity-log --candidate "${CANDIDATE_ID}" \
   731	    --note "concierge: ${EVENT_TYPE} sent at $(date -u +%Y-%m-%dT%H:%M:%SZ)" 2>/dev/null || echo '{}')"
   732	  if [[ "$(printf '%s' "${_al_out}" | jq -r '.ok // false')" == "true" ]]; then
   733	    _al_id="$(printf '%s' "${_al_out}" | jq -r '.activity_id // ""')"
   734	    hh_decision_action "bullhorn_activity_log_write" "candidate:${CANDIDATE_ID}" \
   735	      "${PAYLOAD_HASH}" "event_type:${EVENT_TYPE}; bullhorn_activity_id:${_al_id}" || true
   736	  else
   737	    autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=concierge" \
   738	      "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" "write=activity_log"
   739	  fi
   740	fi
   741	
   742	# ────────────────────────────────────────────────────────────────────────
   743	# Step 14 — Lifecycle state advance (conditional Bullhorn write; per-tenant
   744	# opt-in). Reference: agent.md §4 Step 14. Opt-in via
   745	# IFOS_FORCE_STATE_ADVANCE=1 (the tenant_adapters key for this policy is NOT
   746	# in the v0.4 allowlist yet — schema-before-code: defaults OFF until a v0.5
   747	# supplement adds it; documented deviation). Always emits the audit row.
   748	# ────────────────────────────────────────────────────────────────────────
   749	
   750	if _step_on 14 && [[ "${SEND_APPROVED}" -eq 1 ]]; then
   751	  _advanced="false"
   752	  if [[ "${IFOS_FORCE_STATE_ADVANCE:-0}" == "1" && -n "${STATE_TO}" ]]; then
   753	    if [[ "$(bash "${_BH_BRIDGE}" patch-state --type candidate --id "${CANDIDATE_ID}" \
   754	           --state "${STATE_TO}" 2>/dev/null | jq -r '.ok // false')" == "true" ]]; then
   755	      _advanced="true"
   756	    else
   757	      autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=concierge" \
   758	        "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" "write=state_advance"
   759	    fi
   760	  fi
   761	  hh_decision_action "concierge_send_complete" "candidate:${CANDIDATE_ID}" \
   762	    "${PAYLOAD_HASH}" \
   763	    "event_type:${EVENT_TYPE}; elapsed:${SLA_ELAPSED:-unknown}; state_advanced:${_advanced}" || true
   764	fi
   765	
   766	# ────────────────────────────────────────────────────────────────────────
   767	# Step 15 — Session close + Gate B metric (body defined up-front as
   768	# _cg_step15 so the skip paths can close cleanly via _close_run).
   769	# ────────────────────────────────────────────────────────────────────────
   770	

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/validate.sh | sed -n '330,390p' && nl -ba agents/recruitment/concierge/cycle.sh | sed -n '540,570p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
   330	    _fail "G5: true duplicate at validate time — prior draft + completed send within 24h"
   331	    ESC_CLASS="${ESC_CLASS:-ESC_AUTOSEND_RACE}"
   332	  else
   333	    _ok "G5: anti-duplicate re-check clean"
   334	  fi
   335	else
   336	  _warn "G5: DB unavailable — anti-duplicate re-check skipped (Step 2 guard was the primary)"
   337	fi
   338	
   339	# ────────────────────────────────────────────────────────────────────────
   340	# G6 — Bullhorn context complete: candidate name + email present (draft
   341	# frontmatter AND entities cache row). ESC_AGENT_OUTPUT_SHAPE.
   342	# (ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10.)
   343	# ────────────────────────────────────────────────────────────────────────
   344	
   345	if [[ -z "${D_CANDIDATE_NAME}" || -z "${D_RECIPIENT}" ]]; then
   346	  _fail "G6: draft missing candidate_name or recipient"
   347	  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
   348	elif [[ "${DB_ROW_PRESENT}" -eq 1 && ( -z "${DB_CAND_EMAIL}" || -z "${DB_CAND_NAME}" ) ]]; then
   349	  _fail "G6: candidate ${D_CANDIDATE_ID} cache row incomplete (name/email missing)"
   350	  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
   351	elif [[ "${DB_ROW_PRESENT}" -eq 0 ]]; then
   352	  _fail "G6: no entities cache row for candidate ${D_CANDIDATE_ID} — context fetch incomplete"
   353	  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
   354	else
   355	  _ok "G6: Bullhorn context complete (name + email present)"
   356	fi
   357	
   358	# ────────────────────────────────────────────────────────────────────────
   359	# Verdict + audit-row emission
   360	# ────────────────────────────────────────────────────────────────────────
   361	
   362	printf '\nValidate Gate A: '
   363	if [[ ${#FAILURES[@]} -gt 0 ]]; then
   364	  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
   365	  # Per-failure ESC routing (agent.md §5): G1→ESC_VOICE_DRIFT (warn),
   366	  # G2→ESC_ADDRESSEE_MISMATCH (blocking), G3→ESC_TONE_RULE_VIOLATION (warn),
   367	  # G4→ESC_PII_LEAKAGE_RISK (blocking), G5→ESC_AUTOSEND_RACE (warn),
   368	  # G6→ESC_AGENT_OUTPUT_SHAPE (warn). Gate A blocks the draft regardless of
   369	  # the ESC code's paging severity (the two dimensions are separate).
   370	  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
   371	  autosend_escalate "${ESC_CLASS}" "agent=concierge" \
   372	    "tenant=${CTX_TENANT_SLUG}" "candidate=${D_CANDIDATE_ID:-unknown}" \
   373	    "event=${D_EVENT_TYPE:-unknown}" "failures=${#FAILURES[@]}" "draft=${DRAFT}"
   374	  _gfail_hash="$(printf '%s' "${DRAFT}|${ESC_CLASS}" | shasum -a 256 2>/dev/null | cut -c1-16)"
   375	  [[ -z "${_gfail_hash}" ]] && _gfail_hash="gate-a-fail"
   376	  hh_decision_action "validate_gate_a_fail" \
   377	    "candidate:${D_CANDIDATE_ID:-unknown}:${D_EVENT_TYPE:-unknown}" "${_gfail_hash}" \
   378	    "${ESC_CLASS}; position:${D_POSITION:-1}; score:${D_VOICE:-unscored}; failures:${#FAILURES[@]}" || true
   379	  # Move the draft OUT of the customer-facing path (agent.md §5).
   380	  _quarantine="/tmp/concierge-gate-a-failed-$(basename "${DRAFT}")"
   381	  mv -f "${DRAFT}" "${_quarantine}" 2>/dev/null \
   382	    && printf 'validate.sh: draft quarantined to %s\n' "${_quarantine}" >&2
   383	  exit 1
   384	fi
   385	printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
   386	exit 0
   540	# with a partial STEPS override and emits the contract marker).
   541	# ESC_PII_LEAKAGE_RISK (blocking) on hit.
   542	# ────────────────────────────────────────────────────────────────────────
   543	
   544	if _step_on 10; then
   545	  _pii_hit=""
   546	  _body_emails="$(awk 'c==2{print} /^---$/{c++}' "${DRAFT_PATH}" 2>/dev/null \
   547	    | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
   548	  if [[ -n "${_body_emails}" ]]; then
   549	    _allow="${RECIPIENT##*@} ${CTX_FIRM_DOMAINS:-}"
   550	    while IFS= read -r _em; do
   551	      [[ -z "${_em}" ]] && continue
   552	      _dom_ok=0
   553	      for _a in ${_allow}; do [[ "${_em##*@}" == "${_a}" ]] && _dom_ok=1; done
   554	      [[ "${_dom_ok}" -eq 0 ]] && _pii_hit="${_em}"
   555	    done <<<"${_body_emails}"
   556	  fi
   557	  if [[ -n "${_pii_hit}" ]]; then
   558	    autosend_escalate "ESC_PII_LEAKAGE_RISK" "agent=concierge" \
   559	      "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" "class=other_party_email"
   560	    hh_decision_action "validate_gate_a_fail" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
   561	      "${PAYLOAD_HASH}" "ESC_PII_LEAKAGE_RISK; class:other_party_email" || true
   562	    mv -f "${DRAFT_PATH}" "/tmp/concierge-pii-failed-$(basename "${DRAFT_PATH}")" 2>/dev/null || true
   563	    exit 1
   564	  fi
   565	  hh_decision_output "pii_check_passed" "candidate:${CANDIDATE_ID}" "result:passed"
   566	fi
   567	
   568	# ────────────────────────────────────────────────────────────────────────
   569	# Step 11 — Autosend-bridge routing (D1-B Telegram; orange approval)
   570	# Reference: agent.md §4 Step 11 + D1-B decision doc §Implementation surface

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/cycle.sh | sed -n '480,515p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
   480	  _d_voice="$(grep -m1 '^voice_score:' "${DRAFT_PATH}" | sed 's/^voice_score:[[:space:]]*//')"
   481	  _d_words="$(grep -m1 '^words:' "${DRAFT_PATH}" | sed 's/^words:[[:space:]]*//')"
   482	  # Vault path is the canonical artefact_ref (agent.md §3 line 107); the
   483	  # candidate+event composite + voice metadata ride the reason string.
   484	  hh_decision_output "concierge_draft_rendered" "${DRAFT_PATH}" \
   485	    "candidate:${CANDIDATE_ID}:${EVENT_TYPE}; voice_score:${_d_voice}; words:${_d_words}"
   486	fi
   487	
   488	# ────────────────────────────────────────────────────────────────────────
   489	# Step 8 — Voice + tone validation (Gate A; validate.sh) → yellow draft row
   490	# Reference: agent.md §4 Step 8 + §5. Position thresholds 0.75/0.78/0.82
   491	# hard-enforce on real numeric scores (unscored warn-and-pass is the
   492	# accepted v1.0 behaviour — no classifier exists; documented in tools.yaml).
   493	# On fail: validate.sh already emitted the ESC + validate_gate_a_fail rows
   494	# and quarantined the draft; cycle.sh aborts (exit 1).
   495	# ────────────────────────────────────────────────────────────────────────
   496	
   497	PAYLOAD_HASH=""
   498	if _step_on 8; then
   499	  if ! bash "${_VALIDATE}" "${DRAFT_PATH}"; then
   500	    exit 1
   501	  fi
   502	  PAYLOAD_HASH="$(shasum -a 256 "${DRAFT_PATH}" 2>/dev/null | cut -c1-16)"
   503	  [[ -z "${PAYLOAD_HASH}" ]] && PAYLOAD_HASH="${CANDIDATE_ID}-${EVENT_TYPE}"
   504	  _d_voice="$(grep -m1 '^voice_score:' "${DRAFT_PATH}" | sed 's/^voice_score:[[:space:]]*//')"
   505	  _d_words="$(grep -m1 '^words:' "${DRAFT_PATH}" | sed 's/^words:[[:space:]]*//')"
   506	  hh_decision_action "concierge_email_draft" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
   507	    "${PAYLOAD_HASH}" \
   508	    "voice_score:${_d_voice}; position:${ESCALATION_POSITION}; words:${_d_words}; recipient:${RECIPIENT}" || true
   509	fi
   510	: "${PAYLOAD_HASH:=${CANDIDATE_ID}-${EVENT_TYPE}}"
   511	
   512	# ────────────────────────────────────────────────────────────────────────
   513	# Step 9 — SLA timing check (Gate B leading metric; NOT Gate A hard-fail)
   514	# Reference: agent.md §4 Step 9 + ADR-007 (Accepted + RATIFIED 2026-05-31).
   515	# elapsed = now() - event_timestamp; >30min → ESC_CONCIERGE_SLA_MISS (warn;

codex
A production-gate ordering problem is emerging: the written workflow and the built cycle emit the yellow draft action before the PII Gate A check, while §5 says PII is a hard-fail before action. I’m doing one more pass for catalogue and citation drift so the final verdict is tight.
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/cycle.sh | sed -n '570,720p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/tools.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
   570	# Reference: agent.md §4 Step 11 + D1-B decision doc §Implementation surface
   571	# item 2. PRODUCTION wiring landed THIS slice: dist/bin/{propose,await}.js
   572	# (real Bot API transport + postgres approvals reader). Requirements for the
   573	# bridge path: dist built + operator chat id + (TELEGRAM_BOT_TOKEN set OR
   574	# IFOS_BRIDGE_FAKE fixture mode). Anything missing → drafts-only (D1-C).
   575	# ────────────────────────────────────────────────────────────────────────
   576	
   577	BRIDGE_OUTCOME="" APPROVAL_ID="" DECIDED_BY=""
   578	if _step_on 11; then
   579	  _bridge_ready=0
   580	  if [[ -d "${_BRIDGE_DIST}" && -f "${_BRIDGE_DIST}/bin/propose.js" \
   581	        && -n "${CTX_OPERATOR_TELEGRAM_CHAT_ID:-}" ]] \
   582	     && { [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]] || [[ -n "${IFOS_BRIDGE_FAKE:-}" ]]; }; then
   583	    _bridge_ready=1
   584	  fi
   585	
   586	  if [[ "${_bridge_ready}" -eq 1 ]]; then
   587	    _preview="$(awk 'c==2{print} /^---$/{c++}' "${DRAFT_PATH}" 2>/dev/null | head -c 400)"
   588	    _timeout_s=14400   # PT4H per autosend-policy.yaml gmail_outlook_send_to_candidate.timeout
   589	    if _propose_json="$(node "${_BRIDGE_DIST}/bin/propose.js" \
   590	        --action gmail_outlook_send_to_candidate \
   591	        --tenant "${CTX_TENANT_SLUG}" \
   592	        --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
   593	        --target "${RECIPIENT}" \
   594	        --preview "${_preview}" \
   595	        --vault-path "${DRAFT_PATH}" \
   596	        --timeout-seconds "${_timeout_s}" 2>/dev/null)"; then
   597	      APPROVAL_ID="$(printf '%s' "${_propose_json}" | jq -r '.approval_id // ""')"
   598	      _expires_iso="$(printf '%s' "${_propose_json}" | jq -r '.expires_at_iso // ""')"
   599	      hh_decision_action "concierge_approval_routed" \
   600	        "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
   601	        "d1_path:B; bridge_target:${APPROVAL_ID}; expires:${_expires_iso}" || true
   602	      _await_json="$(node "${_BRIDGE_DIST}/bin/await.js" \
   603	        --approval-id "${APPROVAL_ID}" --tenant "${CTX_TENANT_SLUG}" \
   604	        --expires-at "${_expires_iso}" 2>/dev/null || echo '{"outcome":"timeout"}')"
   605	      BRIDGE_OUTCOME="$(printf '%s' "${_await_json}" | jq -r '.outcome // "timeout"')"
   606	      DECIDED_BY="$(printf '%s' "${_await_json}" | jq -r '.decided_by // ""')"
   607	      case "${BRIDGE_OUTCOME}" in
   608	        approved)
   609	          SEND_APPROVED=1 ;;
   610	        rejected)
   611	          hh_decision_output "approval_rejected" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
   612	            "approval_id:${APPROVAL_ID}; decided_by:${DECIDED_BY}"
   613	          _close_run "operator_rejected" ;;
   614	        timeout|*)
   615	          # ESC_APPROVAL_BRIDGE_TIMEOUT per escalation-codes.md lines 348-353
   616	          # (warn; operator + ifos_oncall); send NOT executed; draft stays in
   617	          # vault for manual reconciliation; run exits non-zero (fixture 99).
   618	          autosend_escalate "ESC_APPROVAL_BRIDGE_TIMEOUT" "agent=concierge" \
   619	            "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" \
   620	            "approval_id=${APPROVAL_ID}" "timeout_seconds=${_timeout_s}"
   621	          hh_decision_action "validate_gate_a_fail" \
   622	            "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
   623	            "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:${_timeout_s}; approval_id:${APPROVAL_ID}" || true
   624	          exit 1 ;;
   625	      esac
   626	    else
   627	      # Telegram postMessage transport failure — NO catalogue ESC exists for
   628	      # transport-class failure (the phantom ESC_AGENT_TOOL_FAILURE is not in
   629	      # the catalogue); surface as drafts-only with an explicit reason (the
   630	      # draft is safe in vault; operator picks up). NOT
   631	      # ESC_APPROVAL_BRIDGE_TIMEOUT — no approval message went out.
   632	      hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
   633	        "bridge propose failed (transport) — draft retained in vault for manual consultant pickup"
   634	      _close_run "bridge_transport_failed"
   635	    fi
   636	  else
   637	    # Bridge prerequisites absent — D1-C graceful degradation (drafts-only).
   638	    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
   639	      "autosend-bridge prerequisites missing (dist:$([[ -d "${_BRIDGE_DIST}" ]] && echo yes || echo no); operator_chat:$([[ -n "${CTX_OPERATOR_TELEGRAM_CHAT_ID:-}" ]] && echo set || echo unset); bot_token:$([[ -n "${TELEGRAM_BOT_TOKEN:-}" ]] && echo set || echo EMPTY)) — drafts retained in vault for manual consultant pickup"
   640	    _close_run "drafts_only"
   641	  fi
   642	fi
   643	
   644	# ────────────────────────────────────────────────────────────────────────
   645	# Step 12 — Send execution (orange tier; ONLY fires post-Step-11 approval)
   646	# Reference: agent.md §4 Step 12. The bridge approval IS the human approval:
   647	# the .approved marker is pre-written so hh_decision_action's orange gate
   648	# resolves instantly against it (same vault substrate; no double-approval).
   649	# Transport: MS Graph / Gmail per tenant config — OAuth ABSENT today, so the
   650	# live send path is gated; IFOS_FORCE_SEND_RESULT=sent proves the chain in
   651	# fixtures. ESC_SEND_FAIL (warn) on 4xx/5xx after 1 retry.
   652	# KNOWN GAP (review finding 5, doc-only today): the orange
   653	# gmail_outlook_send_to_candidate row is emitted BEFORE the transport
   654	# executes (the only reachable success path today is the forced fixture one,
   655	# so the row is honest). When the live email connector lands, this MUST move
   656	# to emit-on-confirmed-send — or emit a correction row on transport failure —
   657	# so the orange audit row never claims a send that did not happen.
   658	# ────────────────────────────────────────────────────────────────────────
   659	
   660	SEND_DONE=0
   661	if _step_on 12 && [[ "${SEND_APPROVED}" -eq 1 ]]; then
   662	  _transport=""
   663	  _email_cli="${IFOS_REPO_ROOT:-}/packages/mcp-connectors/${CTX_EMAIL_CHANNEL:-microsoft-graph}/dist/cli.js"
   664	  if [[ "${IFOS_FORCE_SEND_RESULT:-}" == "sent" ]]; then
   665	    _transport="forced"
   666	  elif [[ -f "${_email_cli}" && "${CTX_EMAIL_PROVIDER_TOKEN_STATE:-absent}" != "absent" ]]; then
   667	    _transport="connector"
   668	  fi
   669	
   670	  if [[ -z "${_transport}" ]]; then
   671	    hh_decision_output "send_degraded_no_transport" "candidate:${CANDIDATE_ID}:${EVENT_TYPE}" \
   672	      "approved by ${DECIDED_BY:-operator} (approval:${APPROVAL_ID}) but email transport unavailable (channel:${CTX_EMAIL_CHANNEL:-microsoft-graph}; oauth:${CTX_EMAIL_PROVIDER_TOKEN_STATE:-absent}) — manual send required"
   673	    _close_run "approved_no_transport"
   674	  fi
   675	
   676	  # Record the bridge approval on the vault approval substrate BEFORE the
   677	  # orange action row, so autosend_await_approval resolves instantly.
   678	  _pending_dir="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/pending-approvals"
   679	  mkdir -p "${_pending_dir}" 2>/dev/null || true
   680	  {
   681	    printf 'approved via autosend-bridge-telegram\n'
   682	    printf 'approval_id=%s\n' "${APPROVAL_ID}"
   683	    printf 'decided_by=%s\n' "${DECIDED_BY}"
   684	  } > "${_pending_dir}/${PAYLOAD_HASH}.approved"
   685	
   686	  if hh_decision_action "gmail_outlook_send_to_candidate" "candidate:${CANDIDATE_ID}" \
   687	       "${PAYLOAD_HASH}" \
   688	       "event:${EVENT_TYPE}; recipient:${RECIPIENT}; channel:${CTX_EMAIL_CHANNEL:-microsoft-graph}; approval_id:${APPROVAL_ID}"; then
   689	    _send_ok=0
   690	    case "${_transport}" in
   691	      forced) _send_ok=1 ;;   # fixture-proved chain; no live transport exists
   692	      connector)
   693	        # Documented connector CLI surface (reconciled when the MS Graph /
   694	        # Gmail connectors land): node dist/cli.js send-email --to --subject
   695	        # --body-file --bcc → {"ok":true,"message_id":...}
   696	        _subject="$(grep -m1 '^subject:' "${DRAFT_PATH}" | sed 's/^subject:[[:space:]]*//; s/^"//; s/"$//')"
   697	        for _attempt in 1 2; do
   698	          if _send_out="$(node "${_email_cli}" send-email --to "${RECIPIENT}" \
   699	               --subject "${_subject}" --body-file "${DRAFT_PATH}" \
   700	               --bcc "${CTX_TENANT_ARCHIVE_BCC:-}" 2>/dev/null)" \
   701	             && [[ "$(printf '%s' "${_send_out}" | jq -r '.ok // false')" == "true" ]]; then
   702	            _send_ok=1; break
   703	          fi
   704	          [[ "${_attempt}" -eq 1 ]] && sleep 30
   705	        done ;;
   706	    esac
   707	    if [[ "${_send_ok}" -eq 1 ]]; then
   708	      SEND_DONE=1
   709	      SENDS_MADE=$((SENDS_MADE + 1))
   710	    else
   711	      autosend_escalate "ESC_SEND_FAIL" "agent=concierge" \
   712	        "tenant=${CTX_TENANT_SLUG}" "candidate=${CANDIDATE_ID}" \
   713	        "channel=${CTX_EMAIL_CHANNEL:-microsoft-graph}" "retries=1"
   714	      _close_run "send_failed"
   715	    fi
   716	  else
   717	    # Orange gate did not resolve approved (defensive; bridge said approved).
   718	    _close_run "orange_gate_unresolved"
   719	  fi
   720	fi

 succeeded in 0ms:
     1	# Concierge agent — tools.yaml (capability declarations)
     2	#
     3	# Status: BUILT (W10-13 build slice). cycle.sh 15-step + validate.sh 6-check
     4	#         Gate A + context.sh tenant_adapters reads + cleanup.sh purge are
     5	#         LIVE; fixtures prove the full chain against seeded entities rows.
     6	#         Honest-scope (verified 2026-06-10): Bullhorn creds EMPTY + connector
     7	#         CLI on the unmerged Janitor branch → all Bullhorn calls route via
     8	#         bin/bh-bridge.sh (fixture mode against the entities cache; the shim
     9	#         header documents the connector CLI surface to reconcile at review).
    10	#         MS Graph / Gmail OAuth ABSENT → Step 12 live transport gated
    11	#         (fixtures prove the chain via IFOS_FORCE_SEND_RESULT). The
    12	#         @ifos/autosend-bridge-telegram PRODUCTION wiring (real Bot API
    13	#         transport + postgres approvals reader + dist/bin CLIs) landed THIS
    14	#         slice; TELEGRAM_BOT_TOKEN is EMPTY in the sandbox so live Telegram
    15	#         is unexercised (fetch-mock-tested; IFOS_BRIDGE_FAKE drives fixtures).
    16	#         VOICE HONESTY: no voice classifier exists in v1.0
    17	#         (@ifos/voice-classifier unbuilt; voice_corpus empty) — drafts are
    18	#         unscored/no_classifier and Gate A G1 warn-and-passes them (accepted
    19	#         v1.0 behaviour); the position thresholds 0.75/0.78/0.82
    20	#         hard-enforce on REAL numeric scores only (fixtures supply one).
    21	# Reading order: agent.md §1 (output contract) + §2 (invocation) + §3 (12
    22	#         lifecycle events × per-tenant template variants) + §4 (15-step
    23	#         workflow) first.
    24	#
    25	# Per ADR-003 v2 agent-bundle pattern: tools.yaml declares every external
    26	# capability cycle.sh invokes + the autosend-policy action_type each state-
    27	# changing call emits. cortextOS bus uses this to authorise capability
    28	# invocation per agent (no capability declared here = bus refuses the call).
    29	#
    30	# Per agent.md §6: Concierge has the largest escalation surface of any v1.0
    31	# agent (16 ESC codes) — appropriate for the highest-stakes customer-facing
    32	# comms. failure_modes below map each capability's failure surface to the
    33	# right ESC code, citing the catalogue line where defined.
    34	#
    35	# Action-type registrations cross-referenced at agents/_shared/autosend-policy.yaml
    36	# (status table at bottom of this file).
    37	
    38	version: "0.1"
    39	agent: concierge
    40	
    41	capabilities:
    42	
    43	  # ────────────────────────────────────────────────────────────────────────
    44	  # Bullhorn ATS (lifecycle event source + activity-log destination)
    45	  # ────────────────────────────────────────────────────────────────────────
    46	
    47	  - id: bullhorn_oauth
    48	    package: "@ifos/bullhorn"
    49	    purpose: "Bullhorn OAuth refresh + per-tenant token rotation (deferred to W7 Janitor bundle Track-2 per master brief §8.2)"
    50	    action_type: bullhorn_oauth      # green tier; registration QUEUED until Bullhorn partnership lands
    51	    cycle_step: 0
    52	    secrets_required: [BULLHORN_CLIENT_ID, BULLHORN_CLIENT_SECRET, BULLHORN_TENANT_TOKEN]
    53	    rate_limit_hint: "tenant-specific; default 20/sec per tenant per Bullhorn ts_endpoint"
    54	    failure_modes:
    55	      - condition: "OAuth refresh 6+ consecutive failures (Bullhorn revoked the grant)"
    56	        surface: "BullhornAuthError"
    57	        escalation: ESC_BULLHORN_AUTH  # blocking; operator + ifos_oncall per agent.md §6 row 1
    58	
    59	  - id: bullhorn_get_candidate
    60	    package: "@ifos/bullhorn"
    61	    purpose: "Single-entity candidate fetch (name, current state, comms history) — Step 3 of §4 workflow"
    62	    cycle_step: 3
    63	    state_changing: false
    64	    failure_modes:
    65	      - condition: "429 from Bullhorn API"
    66	        surface: "BullhornRateLimitError"
    67	        escalation: ESC_RATE_LIMIT_HIT  # warn; operator; payload.upstream='bullhorn'
    68	
    69	  - id: bullhorn_get_placement
    70	    package: "@ifos/bullhorn"
    71	    purpose: "Placement entity fetch (role, client, dates) — Step 3"
    72	    cycle_step: 3
    73	    state_changing: false
    74	
    75	  - id: bullhorn_get_client
    76	    package: "@ifos/bullhorn"
    77	    purpose: "Client entity fetch (company name, primary contact) — Step 3"
    78	    cycle_step: 3
    79	    state_changing: false
    80	
    81	  - id: bullhorn_get_contact
    82	    package: "@ifos/bullhorn"
    83	    purpose: "Client-contact entity fetch (name, email) — Step 3 + Step 4 addressee resolution"
    84	    cycle_step: 3
    85	    state_changing: false
    86	
    87	  - id: bullhorn_create_activity_log
    88	    package: "@ifos/bullhorn"
    89	    purpose: "Post-send audit-trail entry in Bullhorn itself (NOT customer-visible — green tier)"
    90	    action_type: bullhorn_activity_log_write  # green tier; REGISTERED in autosend-policy.yaml (Codex Fbis-R1 closure 2026-06-02)
    91	    cycle_step: 13
    92	    state_changing: true
    93	    failure_modes:
    94	      - condition: "Activity-log write fails (connector error / cache insert failure)"
    95	        surface: "bh-bridge {ok:false}"
    96	        escalation: ESC_BULLHORN_WRITE_FAIL  # warn; operator
    97	
    98	  # ────────────────────────────────────────────────────────────────────────
    99	  # Customer-facing email transport (orange tier — only fires post-approval)
   100	  # ────────────────────────────────────────────────────────────────────────
   101	
   102	  - id: microsoft_graph_send
   103	    package: "@ifos/microsoft-graph"
   104	    purpose: "Microsoft Graph send_email (per-tenant config; tenant chooses MS Graph OR Gmail)"
   105	    action_type: gmail_outlook_send_to_candidate  # ORANGE; REGISTERED in autosend-policy.yaml; consolidated channel-agnostic action_type
   106	    cycle_step: 12
   107	    state_changing: true
   108	    optional: true  # alternate to gmail_send; tenant picks one
   109	    secrets_required: [MS_GRAPH_CLIENT_ID, MS_GRAPH_CLIENT_SECRET, MS_GRAPH_TENANT_TOKEN]
   110	    failure_modes:
   111	      - condition: "OAuth refresh fails (revoked, expired)"
   112	        surface: "MsGraphAuthError"
   113	        escalation: ESC_MS_GRAPH_AUTH  # blocking; operator + ifos_oncall (catalogue verbatim per agent.md §6 — tenant-admin involvement is a manual operator-discretion follow-up, NOT catalogue routing)
   114	      - condition: "4xx/5xx from Graph API at send time"
   115	        surface: "MsGraphSendError"
   116	        escalation: ESC_SEND_FAIL  # warn; operator; retry once 30s backoff per §4 Step 12
   117	
   118	  - id: gmail_send
   119	    package: "@ifos/gmail"
   120	    purpose: "Gmail send_email (per-tenant config; tenant chooses MS Graph OR Gmail)"
   121	    action_type: gmail_outlook_send_to_candidate  # ORANGE; same action_type — channel-agnostic at audit layer
   122	    cycle_step: 12
   123	    state_changing: true
   124	    optional: true
   125	    secrets_required: [GMAIL_OAUTH_CLIENT_ID, GMAIL_OAUTH_CLIENT_SECRET, GMAIL_TENANT_TOKEN]
   126	    failure_modes:
   127	      - condition: "OAuth refresh fails"
   128	        surface: "GmailAuthError"
   129	        escalation: ESC_GMAIL_AUTH  # blocking; operator + ifos_oncall (catalogue verbatim; same tenant-admin caveat as ESC_MS_GRAPH_AUTH per agent.md §6)
   130	      - condition: "4xx/5xx from Gmail API at send time"
   131	        surface: "GmailSendError"
   132	        escalation: ESC_SEND_FAIL  # warn; operator; retry once
   133	
   134	  # ────────────────────────────────────────────────────────────────────────
   135	  # Autosend bridge (D1-B Telegram shim per 2026-05-31 founder decision).
   136	  # PRODUCTION WIRING LANDED in this W10-13 slice: real Telegram Bot API
   137	  # transport (createTelegramTransport) + postgres approvals reader over
   138	  # decision_log (createPostgresDecisionSource; NO new approvals table) +
   139	  # dist/bin/{propose,await,record-decision}.js CLIs consumed by cycle.sh
   140	  # Step 11. Honest caveats: the /approve — /reject Telegram command handler
   141	  # is @ifos/telegram-surface scope (NOT built — decisions recorded via
   142	  # record-decision.js until it lands) and TELEGRAM_BOT_TOKEN is EMPTY in
   143	  # the sandbox (live Bot API unexercised; fetch-mock-tested).
   144	  # Per D1-B doc §"Implementation surface" item 4: declared on BOTH
   145	  # Concierge AND Cash Conductor (Concierge is the primary Step-11 consumer).
   146	  # ────────────────────────────────────────────────────────────────────────
   147	
   148	  - id: autosend_bridge_telegram_propose
   149	    package: "@ifos/autosend-bridge-telegram"
   150	    api: proposeApproval
   151	    purpose: "Post orange-tier candidate-comms approval request to operator Telegram chat (D1-B founder decision)"
   152	    action_type: concierge_approval_routed  # GREEN internal audit row (REGISTERED per R19 fix) — records the orange-tier approval routing; the orange row itself is gmail_outlook_send_to_candidate at Step 12
   153	    cycle_step: 11
   154	    state_changing: true
   155	    optional: true  # cycle.sh Step 11 checks for the package dist/; falls back to drafts-only mode if absent (per D1-C graceful degradation)
   156	    failure_modes:
   157	      - condition: "Telegram postMessage transport failure (network, 5xx, invalid chat_id)"
   158	        surface: "BridgeTransportError thrown by package"
   159	        escalation: none  # NO catalogue ESC exists for transport-class failure (phantom ESC_AGENT_TOOL_FAILURE removed 2026-06-10); cycle.sh Step 11 degrades to drafts-only with an explicit drafts_only_mode marker (deviation 6) — NOT ESC_APPROVAL_BRIDGE_TIMEOUT (no message went out)
   160	
   161	  - id: autosend_bridge_telegram_await
   162	    package: "@ifos/autosend-bridge-telegram"
   163	    api: awaitApprovalDecision
   164	    purpose: "Block on operator approve/reject reply from Telegram (PT4H default deadline; authoritative on absolute expires_at_iso, not poll-count × interval)"
   165	    cycle_step: 11
   166	    state_changing: false
   167	    optional: true
   168	    failure_modes:
   169	      - condition: "Operator never replies before PT4H expires_at_iso"
   170	        surface: "outcome=timeout (or BridgeTimeoutError via awaitApprovalDecisionOrThrow)"
   171	        escalation: ESC_APPROVAL_BRIDGE_TIMEOUT  # warn-tier per escalation-codes.md lines 348-353; routes operator + ifos_oncall (catalogue verbatim per agent.md §6 — tenant-admin is a manual escalation choice, NOT catalogue routing); action converts to manual reconciliation
   172	
   173	  # ────────────────────────────────────────────────────────────────────────
   174	  # Voice + tone validators (shared substrate — used at Step 8)
   175	  # ────────────────────────────────────────────────────────────────────────
   176	
   177	  - id: voice_classifier
   178	    package: "@ifos/voice-classifier"
   179	    purpose: "Score draft body against tenant voice corpus (position-specific threshold: ≥0.75 / ≥0.78 / ≥0.82)"
   180	    cycle_step: 8
   181	    state_changing: false
   182	    failure_modes:
   183	      - condition: "Classifier returns score below position-threshold after 3 retries"
   184	        surface: "VoiceClassifierError"
   185	        escalation: ESC_VOICE_DRIFT  # warn per catalogue lines 120-125; routes operator_chat_id for ALL positions (position-specific paging would need catalogue amendment)
   186	
   187	  - id: tone_rule_engine
   188	    package: "@ifos/tone-rules"
   189	    purpose: "Apply tenant tone-rules to draft; block-severity rules halt the pipeline"
   190	    cycle_step: 8
   191	    state_changing: false
   192	    failure_modes:
   193	      - condition: "Block-severity tone-rule hit (e.g. forbidden-phrase match)"
   194	        surface: "ToneRuleViolation"
   195	        escalation: ESC_TONE_RULE_VIOLATION  # warn per catalogue; routes operator_chat_id — Gate A still BLOCKS the draft via validate.sh (ESC severity = operator-paging urgency only, per agent.md §5/§6)
   196	
   197	  # ────────────────────────────────────────────────────────────────────────
   198	  # Operator notification (Telegram operator-chat-id; not customer-facing)
   199	  # ────────────────────────────────────────────────────────────────────────
   200	
   201	  - id: telegram_notify
   202	    package: "@ifos/telegram"
   203	    purpose: "Operator-channel Telegram notifications (NOT customer-facing; green tier)"
   204	    action_type: operator_notify_telegram  # green; REGISTERED in autosend-policy.yaml
   205	    cycle_step: 15
   206	    state_changing: false
   207	    secrets_required: [TELEGRAM_BOT_TOKEN]
   208	
   209	  # ────────────────────────────────────────────────────────────────────────
   210	  # Cleanup (cleanup.sh)
   211	  # ────────────────────────────────────────────────────────────────────────
   212	
   213	  - id: concierge_cleanup
   214	    purpose: "Post-run cleanup (transient OAuth-cache + provider-rate-limit-cache purge for Bullhorn + MS Graph/Gmail)"
   215	    action_type: concierge_cleanup  # green tier; QUEUED registration for cleanup.sh wire at W10-13
   216	    state_changing: false
   217	
   218	# ──────────────────────────────────────────────────────────────────────────────
   219	# Action-type registration status (cross-reference autosend-policy.yaml at W10-13)
   220	# ──────────────────────────────────────────────────────────────────────────────
   221	#
   222	# Already REGISTERED in agents/_shared/autosend-policy.yaml (grep-verified
   223	# 2026-06-10 against the policy file):
   224	#   concierge_email_draft              yellow              [Concierge §3 output contract; emitted Step 8]
   225	#   concierge_approval_routed          green               [R19 registration; emitted Step 11]
   226	#   gmail_outlook_send_to_candidate    orange              [TRANSPORT row; emitted Step 12 post-approval]
   227	#   bullhorn_note_customer_visible     orange              [canonical orange; alt channel — not yet emitted in v1.0]
   228	#   bullhorn_activity_log_write        green               [Codex Fbis-R1 closure; emitted Step 13]
   229	#   concierge_send_complete            green               [emitted Step 14]
   230	#   concierge_run_complete             green               [emitted Step 15]
   231	#   operator_notify_telegram           green
   232	#   validate_gate_a_fail               green               [emitted by validate.sh + cycle hard-fail paths]
   233	#
   234	# future_registration: QUEUED action_types — these emit via hh_decision_output
   235	# (Scout/Janitor precedent) until their registration commit lands; emitting an
   236	# unregistered type via hh_decision_action would fail-safe-red:
   237	#   bullhorn_oauth                     green               (W7 Janitor + Bullhorn partnership)
   238	#   concierge_cleanup                  green               (registration queued; cleanup.sh emits output row)
   239	#   twilio_sms_send                    orange              (v1.1+)
   240	#   calendar_invite_send               orange              (v1.1+)
   241	
   242	# ──────────────────────────────────────────────────────────────────────────────
   243	# Boundary check (per master brief §3 + review-mcp-connector.md §8)
   244	# ──────────────────────────────────────────────────────────────────────────────
   245	#
   246	# - No Composio / AgentMail references anywhere in this file.
   247	# - All packages declared are @ifos/* — no third-party adapters with policy
   248	#   semantics smuggled in via tools.yaml.
   249	# - Action types all map to autosend-policy.yaml tiers (or are explicitly
   250	#   marked QUEUED above for the W-X build-slice registration).
   251	# - microsoft-graph + gmail are the v1.0 send paths per agent.md §1; agent-
   252	#   identity email adapter explicitly deferred to v1.1+ per agent.md header.

exec
/bin/zsh -lc 'rg -n "ESC_AUTOSEND_RACE|AUTOSEND_RACE|ESC_BULLHORN_WRITE_FAIL|ESC_" agents/_shared/escalation-codes.md agents/recruitment/concierge/agent.md agents/recruitment/concierge/validate.sh agents/recruitment/concierge/cycle.sh' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
agents/_shared/escalation-codes.md:3:**Status:** Reference — single source of truth for `ESC_*` codes used by any agent. Wired into `_shared/hook-helpers.sh` (Phase 3).
agents/_shared/escalation-codes.md:5:**Update protocol:** new codes added here BEFORE wiring into helpers + before referencing from any agent bundle. Code names are case-sensitive; pattern `ESC_[A-Z][A-Z0-9_]*`.
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:19:human_action      — the ESC_* code itself + optional `:reason` suffix
agents/_shared/escalation-codes.md:24:The Telegram message is templated via `common-notifications.json` `escalation_routes.<ESC_CODE>` if present; otherwise routed to `operator_chat_id`. `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` additionally CCs `ifos_oncall_chat_id`.
agents/_shared/escalation-codes.md:33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
agents/_shared/escalation-codes.md:41:#### `ESC_AUTOSEND_BLOCKED`
agents/_shared/escalation-codes.md:48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
agents/_shared/escalation-codes.md:59:#### `ESC_VAULT_LOCK_TIMEOUT`
agents/_shared/escalation-codes.md:66:#### `ESC_VAULT_VERSION_MISMATCH`
agents/_shared/escalation-codes.md:73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
agents/_shared/escalation-codes.md:80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
agents/_shared/escalation-codes.md:87:#### `ESC_VAULT_CASCADE_TIMEOUT`
agents/_shared/escalation-codes.md:97:#### `ESC_BULLHORN_AUTH`
agents/_shared/escalation-codes.md:108:#### `ESC_RENDERER_FAILED`
agents/_shared/escalation-codes.md:115:- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
agents/_shared/escalation-codes.md:120:#### `ESC_VOICE_DRIFT`
agents/_shared/escalation-codes.md:127:#### `ESC_DUPLICATE_DETECTED`
agents/_shared/escalation-codes.md:135:#### `ESC_JSL_RED_FLAG`
agents/_shared/escalation-codes.md:142:#### `ESC_BRIEF_AMBIGUITY`
agents/_shared/escalation-codes.md:149:#### `ESC_PII_LEAKAGE_RISK`
agents/_shared/escalation-codes.md:157:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:164:#### `ESC_SCHEMA_VIOLATION`
agents/_shared/escalation-codes.md:171:#### `ESC_VOICE_DRIFT_TENANT`
agents/_shared/escalation-codes.md:173:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:178:#### `ESC_INPUT_VALIDATION_FAIL`
agents/_shared/escalation-codes.md:185:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:187:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:195:#### `ESC_HUMAN_EDITING_LOCK`
agents/_shared/escalation-codes.md:202:#### `ESC_VAULT_CONCURRENCY`
agents/_shared/escalation-codes.md:204:- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
agents/_shared/escalation-codes.md:210:#### `ESC_VAULT_RENAME_RACE`
agents/_shared/escalation-codes.md:217:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
agents/_shared/escalation-codes.md:224:#### `ESC_CORTEXTOS_HANDOFF`
agents/_shared/escalation-codes.md:231:#### `ESC_CORTEXTOS_DEGRADED`
agents/_shared/escalation-codes.md:233:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
agents/_shared/escalation-codes.md:241:#### `ESC_REED_AUTH`
agents/_shared/escalation-codes.md:249:#### `ESC_CVLIBRARY_AUTH`
agents/_shared/escalation-codes.md:251:- **Trigger:** CV-Library API OAuth failure (same pattern as ESC_REED_AUTH)
agents/_shared/escalation-codes.md:257:#### `ESC_LINKEDIN_AUTH`
agents/_shared/escalation-codes.md:265:#### `ESC_GMAIL_AUTH`
agents/_shared/escalation-codes.md:273:#### `ESC_MS_GRAPH_AUTH`
agents/_shared/escalation-codes.md:281:#### `ESC_ACCOUNTING_AUTH`
agents/_shared/escalation-codes.md:289:#### `ESC_OPEN_BANKING_AUTH`
agents/_shared/escalation-codes.md:297:#### `ESC_OPEN_BANKING_TOKEN_AGING`
agents/_shared/escalation-codes.md:311:#### `ESC_BULLHORN_WRITE_FAIL`
agents/_shared/escalation-codes.md:313:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
agents/_shared/escalation-codes.md:318:#### `ESC_ACCOUNTING_WRITE_FAIL`
agents/_shared/escalation-codes.md:320:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
agents/_shared/escalation-codes.md:325:#### `ESC_PROVIDER_FETCH_FAIL`
agents/_shared/escalation-codes.md:332:#### `ESC_SEND_FAIL`
agents/_shared/escalation-codes.md:342:#### `ESC_AUTOSEND_ORANGE_PENDING`
agents/_shared/escalation-codes.md:343:- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
agents/_shared/escalation-codes.md:349:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
agents/_shared/escalation-codes.md:357:#### `ESC_AUTOSEND_RACE`
agents/_shared/escalation-codes.md:367:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
agents/_shared/escalation-codes.md:378:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:386:#### `ESC_TONE_RULE_VIOLATION`
agents/_shared/escalation-codes.md:394:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
agents/_shared/escalation-codes.md:401:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
agents/_shared/escalation-codes.md:408:#### `ESC_ADDRESSEE_MISMATCH`
agents/_shared/escalation-codes.md:418:#### `ESC_RECONCILIATION_AMBIGUOUS`
agents/_shared/escalation-codes.md:425:#### `ESC_DNC_FILTER_HIT`
agents/_shared/escalation-codes.md:432:#### `ESC_CONCIERGE_SLA_MISS`
agents/_shared/escalation-codes.md:442:#### `ESC_SCRIBE_SLA_MISS`
agents/_shared/escalation-codes.md:449:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
agents/_shared/escalation-codes.md:466:| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
agents/_shared/escalation-codes.md:467:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
agents/_shared/escalation-codes.md:475:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
agents/_shared/escalation-codes.md:476:2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)
agents/_shared/escalation-codes.md:486:New codes added here BEFORE wiring into helpers + before any agent references them. Code names case-sensitive (`ESC_[A-Z][A-Z0-9_]*`).
agents/recruitment/concierge/agent.md:19:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:142:   → ESC_LIFECYCLE_STATE_UNKNOWN if state transition not in 12-event taxonomy
agents/recruitment/concierge/agent.md:176:   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
agents/recruitment/concierge/agent.md:177:     ESC_BULLHORN_AUTH on auth fail
agents/recruitment/concierge/agent.md:178:   → ESC_AGENT_OUTPUT_SHAPE if critical Bullhorn context fields missing
agents/recruitment/concierge/agent.md:181:     NOTE: ESC_CANDIDATE_DATA_INCOMPLETE is reserved for Sourcing Scout
agents/recruitment/concierge/agent.md:191:   → ESC_ADDRESSEE_MISMATCH if check fails (blocking); draft aborted
agents/recruitment/concierge/agent.md:222:   → ESC_VOICE_DRIFT if classifier score below the escalation_position-specific
agents/recruitment/concierge/agent.md:233:   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
agents/recruitment/concierge/agent.md:240:   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
agents/recruitment/concierge/agent.md:243:       "elapsed_seconds:<N>; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct")
agents/recruitment/concierge/agent.md:254:    → ESC_PII_LEAKAGE_RISK on hit (blocking)
agents/recruitment/concierge/agent.md:264:    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within the policy timeout
agents/recruitment/concierge/agent.md:277:    → ESC_SEND_FAIL on 4xx/5xx; retry once 30s backoff
agents/recruitment/concierge/agent.md:302:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:320:- **"correct addressee resolution (no candidates emailed under another's name)"** — hard-fail (Step 4 critical; ESC_ADDRESSEE_MISMATCH)
agents/recruitment/concierge/agent.md:321:- No tone-rule block-severity violations — hard-fail (ESC_TONE_RULE_VIOLATION)
agents/recruitment/concierge/agent.md:322:- No PII outside firm boundary — hard-fail (ESC_PII_LEAKAGE_RISK)
agents/recruitment/concierge/agent.md:324:- All Bullhorn context fields present (no missing candidate name / no missing email) — hard-fail (ESC_AGENT_OUTPUT_SHAPE; ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10)
agents/recruitment/concierge/agent.md:326:The 30-minute draft SLA (ULTRAPLAN A6 line 566) is interpreted as a Gate B leading metric (90% target) per §1 framing, NOT a per-draft Gate A hard-fail. Polling-fallback delays would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS` (warn, aggregated).
agents/recruitment/concierge/agent.md:330:- **Catalogue blocking-severity:** `ESC_ADDRESSEE_MISMATCH`, `ESC_PII_LEAKAGE_RISK` — these route to operator + ifos_oncall_chat_id per catalogue §2.10 (truly customer-impacting violations).
agents/recruitment/concierge/agent.md:331:- **Catalogue warn-severity:** `ESC_TONE_RULE_VIOLATION`, `ESC_AGENT_OUTPUT_SHAPE` — these route to operator_chat_id only per catalogue §2.10 + §2.7 (per-draft signal-quality issues; not customer-impacting unless multiple aggregate).
agents/recruitment/concierge/agent.md:344:- **30-min SLA hit rate:** % of drafts generated within 30 minutes of lifecycle-event DETECTION. Target ≥90%. Per-draft misses fire `ESC_CONCIERGE_SLA_MISS`; rolling-window aggregate <90% fires `ESC_GATE_B_MISS`. (per ADR-007 + amended ULTRAPLAN line 567)
agents/recruitment/concierge/agent.md:346:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Any of the three metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:356:| `ESC_BULLHORN_AUTH` | OAuth refresh fails (payload.failure_type='refresh_failed' or 'revoked_401' covers the 6+ consecutive failure case) | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:357:| `ESC_RATE_LIMIT_HIT` | 429 from Bullhorn or email provider (payload.upstream identifies which) | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:358:| `ESC_MS_GRAPH_AUTH` | Microsoft Graph OAuth fail | **blocking** | operator + ifos_oncall (catalogue verbatim — token re-auth requires operator intervention; tenant-admin involvement is a manual operator-discretion follow-up, not part of the catalogue routing) |
agents/recruitment/concierge/agent.md:359:| `ESC_GMAIL_AUTH` | Gmail OAuth fail | **blocking** | operator + ifos_oncall (catalogue verbatim; same tenant-admin caveat as ESC_MS_GRAPH_AUTH) |
agents/recruitment/concierge/agent.md:360:| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
agents/recruitment/concierge/agent.md:361:| (Concierge does NOT use `ESC_CANDIDATE_DATA_INCOMPLETE` — per catalogue §2.10 that code is reserved for Sourcing Scout shortlist completeness. Concierge's missing-Bullhorn-context case fires `ESC_AGENT_OUTPUT_SHAPE` per Gate A discipline below.) | — | — |
agents/recruitment/concierge/agent.md:362:| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:363:| `ESC_VOICE_DRIFT` | Voice classifier below the position-specific threshold (≥0.75/0.78/0.82) after 3 retries. The Gate A hard-fail (validate.sh exits non-zero; draft not sent) is expressed through `validate_gate_a_fail`, NOT through this code's severity: per catalogue (escalation-codes.md lines 120-125) `ESC_VOICE_DRIFT` is `warn` → `operator_chat_id` for ALL positions. Position-specific paging urgency (e.g. oncall on rejections) would require a catalogue amendment adding position-severity semantics — not yet made. | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:364:| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | warn (catalogue) — Gate A still blocks the draft from sending via validate.sh; ESC severity governs operator-paging urgency only | operator_chat_id |
agents/recruitment/concierge/agent.md:365:| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:366:| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
agents/recruitment/concierge/agent.md:367:| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md `ESC_APPROVAL_BRIDGE_TIMEOUT` block + autosend-policy.yaml grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field) | warn | operator + ifos_oncall (catalogue verbatim — operator absent + commitment may need rerouting; tenant-admin involvement is a manual escalation choice when bridge-timeout becomes pattern-recurring, not part of catalogue routing) |
agents/recruitment/concierge/agent.md:368:| `ESC_SEND_FAIL` | Email provider 4xx/5xx | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:369:| `ESC_AGENT_OUTPUT_SHAPE` | Gate A failure (output-shape constraint per catalogue line 184) — distinct from ESC_AUTOSEND_BLOCKED which is for red-tier action attempts only | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:370:| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% OR 30-min SLA hit-rate <90% for 30 consecutive days | warn | founder + operator |
agents/recruitment/concierge/agent.md:371:| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
agents/recruitment/concierge/agent.md:372:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
agents/recruitment/concierge/agent.md:378:- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
agents/recruitment/concierge/agent.md:379:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
agents/recruitment/concierge/agent.md:380:- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
agents/recruitment/concierge/agent.md:396:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
agents/recruitment/concierge/cycle.sh:118:# ESC_GATE_B_MISS (warn; founder + operator). Stamps the poll cursor
agents/recruitment/concierge/cycle.sh:147:      autosend_escalate "ESC_GATE_B_MISS" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:195:# ESC_LIFECYCLE_STATE_UNKNOWN (warn) + skip if event ∉ 12-event taxonomy.
agents/recruitment/concierge/cycle.sh:246:    autosend_escalate "ESC_LIFECYCLE_STATE_UNKNOWN" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:310:# Reference: agent.md §4 Step 3, via bin/bh-bridge.sh. ESC_AGENT_OUTPUT_SHAPE
agents/recruitment/concierge/cycle.sh:311:# if critical fields missing (no email/name). ESC_RATE_LIMIT_HIT /
agents/recruitment/concierge/cycle.sh:312:# ESC_BULLHORN_AUTH fire on live-connector failures (live branch only).
agents/recruitment/concierge/cycle.sh:337:    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:341:      "ctx-missing-${CANDIDATE_ID}" "ESC_AGENT_OUTPUT_SHAPE; missing_critical_context" || true
agents/recruitment/concierge/cycle.sh:350:# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on mismatch.
agents/recruitment/concierge/cycle.sh:359:    autosend_escalate "ESC_ADDRESSEE_MISMATCH" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:363:      "addressee-${CANDIDATE_ID}" "ESC_ADDRESSEE_MISMATCH; recipient:${RECIPIENT}; expected:${CAND_EMAIL}" || true
agents/recruitment/concierge/cycle.sh:469:    # ESC_AGENT_OUTPUT_SHAPE: the agent cannot produce its declared output
agents/recruitment/concierge/cycle.sh:470:    # shape. (ESC_RENDERER_FAILED is catalogue-reserved for the _renderer
agents/recruitment/concierge/cycle.sh:472:    autosend_escalate "ESC_AGENT_OUTPUT_SHAPE" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:515:# elapsed = now() - event_timestamp; >30min → ESC_CONCIERGE_SLA_MISS (warn;
agents/recruitment/concierge/cycle.sh:528:          "elapsed_seconds:${SLA_ELAPSED}; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct"
agents/recruitment/concierge/cycle.sh:529:        autosend_escalate "ESC_CONCIERGE_SLA_MISS" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:541:# ESC_PII_LEAKAGE_RISK (blocking) on hit.
agents/recruitment/concierge/cycle.sh:558:    autosend_escalate "ESC_PII_LEAKAGE_RISK" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:561:      "${PAYLOAD_HASH}" "ESC_PII_LEAKAGE_RISK; class:other_party_email" || true
agents/recruitment/concierge/cycle.sh:615:          # ESC_APPROVAL_BRIDGE_TIMEOUT per escalation-codes.md lines 348-353
agents/recruitment/concierge/cycle.sh:618:          autosend_escalate "ESC_APPROVAL_BRIDGE_TIMEOUT" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:623:            "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:${_timeout_s}; approval_id:${APPROVAL_ID}" || true
agents/recruitment/concierge/cycle.sh:628:      # transport-class failure (the phantom ESC_AGENT_TOOL_FAILURE is not in
agents/recruitment/concierge/cycle.sh:631:      # ESC_APPROVAL_BRIDGE_TIMEOUT — no approval message went out.
agents/recruitment/concierge/cycle.sh:651:# fixtures. ESC_SEND_FAIL (warn) on 4xx/5xx after 1 retry.
agents/recruitment/concierge/cycle.sh:711:      autosend_escalate "ESC_SEND_FAIL" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:726:# ESC_BULLHORN_WRITE_FAIL (warn) on write failure.
agents/recruitment/concierge/cycle.sh:737:    autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=concierge" \
agents/recruitment/concierge/cycle.sh:757:      autosend_escalate "ESC_BULLHORN_WRITE_FAIL" "agent=concierge" \
agents/recruitment/concierge/validate.sh:10:# exits non-zero + emits the dominant ESC_* escalation row + a
agents/recruitment/concierge/validate.sh:23:#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts the draft
agents/recruitment/concierge/validate.sh:36:#        ESC_ADDRESSEE_MISMATCH (blocking)
agents/recruitment/concierge/validate.sh:40:#        ESC_TONE_RULE_VIOLATION
agents/recruitment/concierge/validate.sh:43:#        ESC_PII_LEAKAGE_RISK (blocking)
agents/recruitment/concierge/validate.sh:45:#        ESC_AUTOSEND_RACE (warn class; still blocks the draft)
agents/recruitment/concierge/validate.sh:47:#        ESC_AGENT_OUTPUT_SHAPE
agents/recruitment/concierge/validate.sh:120:ESC_CLASS=""
agents/recruitment/concierge/validate.sh:173:    ESC_CLASS="${ESC_CLASS:-ESC_VOICE_DRIFT}"
agents/recruitment/concierge/validate.sh:186:# ESC_ADDRESSEE_MISMATCH (blocking; operator + ifos_oncall) on fail.
agents/recruitment/concierge/validate.sh:196:    ESC_CLASS="ESC_ADDRESSEE_MISMATCH"
agents/recruitment/concierge/validate.sh:214:    ESC_CLASS="ESC_ADDRESSEE_MISMATCH"
agents/recruitment/concierge/validate.sh:225:# ESC_TONE_RULE_VIOLATION (Gate A blocks; ESC severity warn per catalogue).
agents/recruitment/concierge/validate.sh:262:  ESC_CLASS="${ESC_CLASS:-ESC_TONE_RULE_VIOLATION}"
agents/recruitment/concierge/validate.sh:271:# ESC_PII_LEAKAGE_RISK (blocking; operator + ifos_oncall).
agents/recruitment/concierge/validate.sh:290:    ESC_CLASS="${ESC_CLASS:-ESC_PII_LEAKAGE_RISK}"
agents/recruitment/concierge/validate.sh:331:    ESC_CLASS="${ESC_CLASS:-ESC_AUTOSEND_RACE}"
agents/recruitment/concierge/validate.sh:341:# frontmatter AND entities cache row). ESC_AGENT_OUTPUT_SHAPE.
agents/recruitment/concierge/validate.sh:342:# (ESC_CANDIDATE_DATA_INCOMPLETE is Sourcing Scout's per catalogue §2.10.)
agents/recruitment/concierge/validate.sh:347:  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
agents/recruitment/concierge/validate.sh:350:  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
agents/recruitment/concierge/validate.sh:353:  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
agents/recruitment/concierge/validate.sh:365:  # Per-failure ESC routing (agent.md §5): G1→ESC_VOICE_DRIFT (warn),
agents/recruitment/concierge/validate.sh:366:  # G2→ESC_ADDRESSEE_MISMATCH (blocking), G3→ESC_TONE_RULE_VIOLATION (warn),
agents/recruitment/concierge/validate.sh:367:  # G4→ESC_PII_LEAKAGE_RISK (blocking), G5→ESC_AUTOSEND_RACE (warn),
agents/recruitment/concierge/validate.sh:368:  # G6→ESC_AGENT_OUTPUT_SHAPE (warn). Gate A blocks the draft regardless of
agents/recruitment/concierge/validate.sh:370:  ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
agents/recruitment/concierge/validate.sh:371:  autosend_escalate "${ESC_CLASS}" "agent=concierge" \
agents/recruitment/concierge/validate.sh:374:  _gfail_hash="$(printf '%s' "${DRAFT}|${ESC_CLASS}" | shasum -a 256 2>/dev/null | cut -c1-16)"
agents/recruitment/concierge/validate.sh:378:    "${ESC_CLASS}; position:${D_POSITION:-1}; score:${D_VOICE:-unscored}; failures:${#FAILURES[@]}" || true

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/validate.sh | sed -n '260,315p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
   260	if [[ -n "${_g3_hit}" ]]; then
   261	  _fail "G3: block-severity tone-rule violation (${_g3_hit})"
   262	  ESC_CLASS="${ESC_CLASS:-ESC_TONE_RULE_VIOLATION}"
   263	else
   264	  _ok "G3: no block-severity tone-rule violations"
   265	fi
   266	
   267	# ────────────────────────────────────────────────────────────────────────
   268	# G4 — no PII outside firm boundary: scan body for email addresses whose
   269	# domain is neither the recipient's nor an allowlisted firm domain
   270	# (CTX_FIRM_DOMAINS, space-separated; from context hydration).
   271	# ESC_PII_LEAKAGE_RISK (blocking; operator + ifos_oncall).
   272	# ────────────────────────────────────────────────────────────────────────
   273	
   274	_BODY_EMAILS="$(printf '%s' "${BODY_TEXT}" \
   275	  | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
   276	if [[ -n "${_BODY_EMAILS}" ]]; then
   277	  _allow="${D_RECIPIENT##*@} ${CTX_FIRM_DOMAINS:-}"
   278	  _ext=""
   279	  while IFS= read -r _em; do
   280	    [[ -z "${_em}" ]] && continue
   281	    _dom="${_em##*@}"
   282	    _dom_ok=0
   283	    for _a in ${_allow}; do
   284	      [[ "${_dom}" == "${_a}" ]] && _dom_ok=1
   285	    done
   286	    [[ "${_dom_ok}" -eq 0 ]] && _ext="${_em}"
   287	  done <<<"${_BODY_EMAILS}"
   288	  if [[ -n "${_ext}" ]]; then
   289	    _fail "G4: body contains email address outside the firm boundary (${_ext})"
   290	    ESC_CLASS="${ESC_CLASS:-ESC_PII_LEAKAGE_RISK}"
   291	  else
   292	    _ok "G4: no PII outside firm boundary"
   293	  fi
   294	else
   295	  _ok "G4: no email addresses in body"
   296	fi
   297	
   298	# ────────────────────────────────────────────────────────────────────────
   299	# G5 — anti-duplicate re-check at validate time. Defence-in-depth vs the
   300	# Step 2 guard: a webhook re-fire between Step 2 and validate.sh could
   301	# insert a completed send in the window — re-check prevents the race.
   302	# True dup = prior draft row AND completed send for same candidate+event in 24h.
   303	# ────────────────────────────────────────────────────────────────────────
   304	
   305	if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   306	  _dup="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
   307	    --set=tenant="${CTX_TENANT_SLUG}" --set=tgt="candidate:${D_CANDIDATE_ID}:${D_EVENT_TYPE}" \
   308	    --set=ctgt="candidate:${D_CANDIDATE_ID}" <<'SQL' 2>/dev/null | grep -vE '^$' | head -1 || true
   309	BEGIN;
   310	SET LOCAL app.current_tenant = :'tenant';
   311	SELECT 1 FROM decision_log d
   312	WHERE d.agent_name='concierge'
   313	  AND d.payload->>'action_type'='concierge_email_draft'
   314	  AND d.payload->>'target' = :'tgt'
   315	  AND d.phase IN ('action','gating_failed')

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '349,365p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
   349	#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
   350	- **Severity:** warn — orange action's approval window expired without response
   351	- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
   352	- **Phase:** `gating_failed`
   353	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
   354	- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
   355	- **Recovery:** action converts to manual reconciliation; operator handles offline
   356	
   357	#### `ESC_AUTOSEND_RACE`
   358	- **Severity:** warn — concurrency / state-change race
   359	- **Trigger:** A send is about to fire when the underlying state has changed in a way that should suppress it. Two canonical use cases:
   360	  - **Duplicate-payload race:** two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict; second wins-suppressed (first sends; idempotency by payload_hash)
   361	  - **State-change race (Cash Conductor):** payment received between chase-draft and chase-send window; the invoice is no longer overdue when the orange-tier approval fires; chase cancelled (do NOT send) per Cash Conductor §4 Step 12
   362	- **Phase:** `gating_failed`
   363	- **Routing:** `operator_chat_id`
   364	- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
   365	- **Recovery:** duplicate → second suppressed; state-change → cancelled draft logged; no operator action required beyond informational review

codex
The source citations for the master brief and ULTRAPLAN A6 line anchors check out. The remaining problems are not citation drift there; they are bundle-contract drift between `agent.md`, `cycle.sh`, `validate.sh`, and the ESC catalogue.
exec
/bin/zsh -lc "nl -ba docs/features/agent-build/02-specs/spec-004-concierge.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
     1	# Spec 004 — Concierge build (LAST — most downstream)
     2	
     3	**A sub-agent given ONLY this file + `agents/recruitment/concierge/agent.md` + the Cash Conductor
     4	template + CLAUDE.md has everything it needs to build Concierge autonomously.**
     5	
     6	- **Agent dir:** `agents/recruitment/concierge/` (cycle.sh 15-step + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures — SKELETON, ~16 TODO(W10-13) markers)
     7	- **Master-plan source (READ IN FULL):** `agents/recruitment/concierge/agent.md`
     8	- **Mirror template:** Cash Conductor — CC Step 8 render→vault (the chase draft) maps to Concierge Step 7; CC Step 10 autosend-bridge-telegram consumer (drafts-only/bridge branch) maps to Concierge Step 11; CC Gate A position-aware voice → Concierge Step 8.
     9	- **Wave/tier:** v1.0 W10-13; the highest-stakes customer-facing comms agent. Largest ESC surface.
    10	
    11	## 1. Scope
    12	Replace the 16 TODO markers with live impl matching agent.md §3-§6: the 15-step lifecycle workflow
    13	(webhook/poll/nurture), per-event comms drafts, the orange-tier approval+send path (D1-B), Gate A
    14	(position-aware), and fixtures. **Concierge OWNS `gmail_outlook_send_to_candidate` — the
    15	TRANSPORT row that Cash Conductor's orange `xero_reminder_send_customer` initiation hands off to.**
    16	
    17	## 2. Upstream contract (CONSUMES — freeze on main first)
    18	- `agents/_shared/` substrate — frozen.
    19	- **autosend-policy action_types:** `concierge_email_draft` (yellow), `concierge_approval_routed`, `gmail_outlook_send_to_candidate` (orange), `bullhorn_note_customer_visible` (orange), `bullhorn_activity_log_write` (green), `concierge_send_complete`, `concierge_run_complete` (green). Verify each via grep.
    20	- **Postgres:** `entities` (Bullhorn cache), `decision_log` (anti-duplicate query + audit), `tenant_adapters.config.concierge_last_poll`, `voice_corpus`. No new migration.
    21	- **Connectors:** `@ifos/bullhorn` (read context + activity-log/state writes), Microsoft Graph / Gmail (email send), **`@ifos/autosend-bridge-telegram`** (D1-B approval shim — scaffold landed; PRODUCTION wiring is THIS build, see §8).
    22	- **Vault:** tenant comms-template library `/vault/<slug>/concierge-templates/` + `shared/common-comms-templates.yaml` fallback.
    23	- **Voice:** `hh_load_tone_rules` (∋ concierge) + `hh_load_voice_samples` (ANN on event_type).
    24	
    25	## 3. Downstream contract (MUST EXPOSE)
    26	- decision_log markers: `lifecycle_event_detected`, `anti_duplicate_check`, `bullhorn_context_fetched`, `addressee_resolved`, `template_selected`, `escalation_position_set`, `concierge_draft_rendered`, `concierge_sla_miss`, `pii_check_passed`, + action rows `concierge_email_draft`/`concierge_approval_routed`/`gmail_outlook_send_to_candidate`/`bullhorn_activity_log_write`/`concierge_send_complete`/`concierge_run_complete`.
    27	- The orange `gmail_outlook_send_to_candidate` TRANSPORT row — the second half of the autosend chain Cash Conductor opens. Wiring this completes CC's send path too.
    28	
    29	## 4. Workflow steps to wire (agent.md §4 — EVERY step)
    30	| Step | What to implement | marker | ESC on fail | CC pattern |
    31	|---|---|---|---|---|
    32	| 0 | Session start (webhook/poll/cron-nurture); context.sh hydrate | `hh_decision_trigger session_start` | — | CC Step 0 |
    33	| 1 | Source detection (parse webhook / poll / nurture-sweep) → 12-event taxonomy | `lifecycle_event_detected` | `ESC_LIFECYCLE_STATE_UNKNOWN` | CC Step 2 router |
    34	| 2 | Anti-duplicate guard (decision_log query, 24h window) | `anti_duplicate_check` | skip if true dup | CC Step 6 idempotency (decision_log ledger) |
    35	| 3 | Bullhorn context fetch (candidate/placement/client/contact) | `bullhorn_context_fetched` | `ESC_RATE_LIMIT_HIT`, `ESC_BULLHORN_AUTH`, `ESC_AGENT_OUTPUT_SHAPE` | CC Step 1/4 |
    36	| 4 | **Addressee resolution (Gate A critical)** — recipient matches the changing candidate | `addressee_resolved` | `ESC_ADDRESSEE_MISMATCH` (blocking) | CC Gate A G1 contact |
    37	| 5 | Comms-template selection (event×recipient_role; tenant→shared fallback) | `template_selected` | — | — |
    38	| 6 | Sensitive-event escalation routing (rejection/withdrawal/high-value → position 3) | `escalation_position_set` | — | — |
    39	| 7 | LLM draft → `/vault/<tenant>/concierge-drafts/<id>.md` | `concierge_draft_rendered` | `ESC_VOICE_DRIFT` (position threshold) | CC Step 8 render→vault |
    40	| 8 | Voice+tone validation (position thresholds 0.75/0.78/0.82) → yellow draft row | (action) `concierge_email_draft` | `ESC_VOICE_DRIFT`, `ESC_TONE_RULE_VIOLATION` | CC Gate A G3 (position-aware) |
    41	| 9 | SLA timing check (Gate B leading; >30min) | `concierge_sla_miss` | `ESC_CONCIERGE_SLA_MISS` (warn, aggregate) | CC Step 13 SLA |
    42	| 10 | PII boundary check | `pii_check_passed` | `ESC_PII_LEAKAGE_RISK` (blocking) | CC Gate A G4 |
    43	| 11 | Autosend-bridge routing (D1-B Telegram; orange approval) | `concierge_approval_routed` | `ESC_APPROVAL_BRIDGE_TIMEOUT` | CC Step 10 bridge consumer |
    44	| 12 | Send execution (MS Graph/Gmail; BCC archive) — orange transport | `gmail_outlook_send_to_candidate` (orange) | `ESC_SEND_FAIL` (retry once) | — |
    45	| 13 | Bullhorn activity-log write (green, audit) | `bullhorn_activity_log_write` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 |
    46	| 14 | Lifecycle state advance (conditional Bullhorn write, per-tenant opt-in) | `concierge_send_complete` | `ESC_BULLHORN_WRITE_FAIL` | CC Step 6 |
    47	| 15 | Session close + Gate B (ghosted-rate, send-as-is, SLA) | `concierge_run_complete` (green) | `ESC_GATE_B_MISS` | CC Step 14 |
    48	
    49	## 5. Gate A (validate.sh) — every check (agent.md §5)
    50	| Check | Rule | ESC | Enforcement |
    51	|---|---|---|---|
    52	| voice | classifier ≥ position threshold (0.75/0.78/0.82) | `ESC_VOICE_DRIFT` | hard (warn-when-unscored) |
    53	| addressee | recipient matches the changing candidate (no cross-addressing) | `ESC_ADDRESSEE_MISMATCH` (blocking) | hard |
    54	| tone | no block-severity tone-rule violations | `ESC_TONE_RULE_VIOLATION` | hard |
    55	| PII | none outside firm boundary | `ESC_PII_LEAKAGE_RISK` (blocking) | hard |
    56	| anti-dup | Step 2 guard passed | (skip true dup) | hard |
    57	| context | Bullhorn context complete (name + email present) | `ESC_AGENT_OUTPUT_SHAPE` | hard |
    58	(30-min SLA is Gate B leading, NOT a Gate A hard-fail — per ADR-007.)
    59	
    60	## 6. Acceptance criteria
    61	- All §4 steps emit markers; all Gate A checks live; position-aware voice thresholds enforced.
    62	- `bash scripts/build-gate.sh` green; new fixtures green; shellcheck CLEAN; RLS; boundaries; atomic commits; tree clean.
    63	
    64	## 7. Test plan (deterministic fixtures)
    65	- `scripts/run-concierge-gate-a-test.sh` — PASS + each fail class (addressee mismatch, tone, PII, missing-context) + position-threshold voice + ESC routes (register tenant; decision_log FK).
    66	- `scripts/run-concierge-antidup-test.sh` — seed prior draft/send rows → assert the 24h anti-duplicate guard (true-dup skip vs fresh-allow).
    67	- `scripts/run-concierge-routing-test.sh` — event_type → escalation_position (rejection/withdrawal/high-value → 3; else 1) + template selection.
    68	
    69	## 8. Honest-scope flags (DOCUMENT, NEVER FAKE)
    70	- **🔴 BULLHORN CREDS BLOCKED** (Steps 3/13/14) → build+fixtures only; live post-creds.
    71	- **🔴 AUTOSEND-BRIDGE PRODUCTION WIRING IS THIS BUILD'S DELIVERABLE (W10-13).** The `@ifos/autosend-bridge-telegram` scaffold + CC consumer wiring exist, but the real Telegram Bot API + postgres approvals reader are NOT built — that's Steps 11-12's production wiring here. **Completing it unblocks BOTH Concierge sends AND Cash Conductor's drafts-only→orange-send path** (CC's `xero_reminder_send_customer` initiation currently halts at drafts-only because this bridge isn't live). Until done, Concierge runs drafts-only like CC.
    72	- **🟡 EMAIL SEND (Step 12)** needs MS Graph / Gmail OAuth per tenant (founder/tenant onboarding) — live send is post-OAuth.
    73	- Voice (Steps 7-8): empty `voice_corpus` → `unscored/no_corpus`, never faked.
    74	
    75	## 9. Dependencies + sequencing
    76	- **LAST agent.** Build independent parts (source detection, anti-dup, addressee resolution, templates, draft gen, Gate A, fixtures) in parallel; gate the orange send + bridge production wiring on the W10-13 autosend-bridge contract + Bullhorn creds + email OAuth.
    77	- Blocked-for-live by: Bullhorn creds + autosend-bridge production wiring (this build) + email OAuth (all founder/build-gated). NOT blocked for the build of its independent parts + fixtures.
    78	- Sequence after Janitor/Scribe/Sourcing-Scout prove the bundle pattern; the autosend-bridge wiring is the cross-cutting deliverable that also closes Cash Conductor's send loop.

exec
/bin/zsh -lc 'ls -la .codex .codex/ratification 2>/dev/null || true; rg -n "review-agent-bundle|Codex ratification skill" .codex docs agents scripts 2>/dev/null' in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
 succeeded in 0ms:
.codex:
total 0
drwxr-xr-x@  3 madsadmin  staff   96 Jun 10 14:17 .
drwxr-xr-x@ 22 madsadmin  staff  704 Jun 10 14:24 ..
drwxr-xr-x@  8 madsadmin  staff  256 Jun 10 14:17 ratification

.codex/ratification:
total 136
drwxr-xr-x@ 8 madsadmin  staff    256 Jun 10 14:17 .
drwxr-xr-x@ 3 madsadmin  staff     96 Jun 10 14:17 ..
-rw-r--r--@ 1 madsadmin  staff   7686 Jun 10 14:17 SKILL.md
-rw-r--r--@ 1 madsadmin  staff  11759 Jun 10 14:17 review-agent-bundle.md
-rw-r--r--@ 1 madsadmin  staff  11166 Jun 10 14:17 review-architecture-decision.md
-rw-r--r--@ 1 madsadmin  staff   8966 Jun 10 14:17 review-mcp-connector.md
-rw-r--r--@ 1 madsadmin  staff  11256 Jun 10 14:17 review-postgres-migration.md
-rw-r--r--@ 1 madsadmin  staff   9804 Jun 10 14:17 review-schema-change.md
.codex/ratification/review-agent-bundle.md:1:# Codex ratification skill — review-agent-bundle
.codex/ratification/review-agent-bundle.md:147:*End of review-agent-bundle skill.*
.codex/ratification/review-mcp-connector.md:1:# Codex ratification skill — review-mcp-connector
.codex/ratification/SKILL.md:100:- `review-agent-bundle.md` — for new agents under `agents/<vertical>/<name>/`
scripts/run-codex-ratification.sh:112:# sibling files exist. review-agent-bundle skill (.codex/ratification/
scripts/run-codex-ratification.sh:113:# review-agent-bundle.md) inspects agent.md AND the surrounding bundle files
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:929:    3: Re-run Codex review-agent-bundle on the 4 agent.md files; expect
.codex/ratification/review-schema-change.md:1:# Codex ratification skill — review-schema-change
.codex/ratification/review-postgres-migration.md:1:# Codex ratification skill — review-postgres-migration
.codex/ratification/review-architecture-decision.md:1:# Codex ratification skill — review-architecture-decision
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:77:**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:81:**Recommendation:** **Build `review-agent-bundle.md` Codex skill** (deferred per execution-plan §3 lazy; now needed). The Round-4 manifest used `review-architecture-decision.md` as a temporary skill because `review-agent-bundle.md` doesn't exist yet. The correct ratification path for agent.md files is the agent-bundle skill, not architecture-decision.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:83:**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:92:4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:102:- Phase 2 full (5 new scaffolds): **deferred** pending Issue-5 resolution (review-agent-bundle.md skill build)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:106:Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:112:After building `.codex/ratification/review-agent-bundle.md` (commit `825ebd4`) — the correct skill for agent.md ratification — all 6 agent.md files were re-ratified.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:198:| Round 4 v2 | review-agent-bundle (correct) | 6 | 10 (6 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:199:| Round 5 (remediation of R4-v2) | review-agent-bundle | 5 | 15 (5 new; none from R4-v2) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:200:| Round 6 (remediation of R5) | review-agent-bundle | 4 | 19 (4 new; none from R5) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:268:Ran all 6 against `review-agent-bundle.md`. **All 6 returned REJECTED**, with the following actual top-level finding counts (the script's regex inflates because of nested sub-bullets):
docs/architecture/architecture-cohesion-review.md:188:  - **A:** Codex review skill `review-agent-bundle.md` (not yet built) would catch this. Currently relies on grep audit + author discipline. Recommend: add this check to `scripts/run-tenancy-audit.sh` (Phase 1 enhancement OR Codex skill).
docs/architecture/architecture-cohesion-review.md:190:**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:215:  - **A:** R2 commitment (ADR-003 Decision 1): tools.yaml can opt-in to cortextOS skills via `cortextos_skills:` block. If an agent opts in to `knowledge-base`, it gets the upstream KB. **This is the seam.** Currently no agent opts in. Recommend: add `review-agent-bundle.md` skill check to flag any `knowledge-base` opt-in for explicit founder review.
docs/architecture/architecture-cohesion-review.md:234:| R8 | Adapter + brain-replacement boundary automation | Medium | `review-agent-bundle.md` Codex skill at Diagnostic W3 | Claude Code | Diagnostic W3 |
docs/build-brief/00-MASTER-BRIEF.md:723:| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
agents/recruitment/diagnostic/README.md:38:Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this directory ratifies as a unit when the full 6-file + 3-fixture bundle exists.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:88:- **A new fact contradicting these disagreements emerges** — e.g. Codex skill `review-agent-bundle.md` gets hardened to be less interpretive on what counts as "drift" vs "scaffold-acceptable divergence"; or the master brief explicitly defines a `Proposed-with-bundle-drift` state separate from `Proposed`.
docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md:97:- Consider hardening `review-agent-bundle.md` skill to explicitly accept "agent.md describes target W-X build-slice behavior; SKELETON files exist with TODO(W-X) markers" as a non-rejection state. The skill currently treats agent.md ↔ code drift as a structural issue when in reality scaffolding inherently has this property.
docs/features/agent-build/03-implementation/concierge-summary.md:109:`review-agent-bundle.md`.
agents/recruitment/diagnostic/tools.yaml:5:# Ratifies as part of full bundle via review-agent-bundle.md skill.
agents/recruitment/diagnostic/agent.md:4:**Build state:** Full bundle built (agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures). Codex review-agent-bundle rounds run through R19 (latest applied 2026-05-25 bilateral pass); ADR-006 closed the Cat-1/Cat-ζ Gate A finding at R10; subsequent rounds sit at steady-state ~4 mechanical cross-reference findings/round per master brief §10.3 step 5. Status flips Proposed → Accepted when ALL: (a) Codex RATIFIED verdict (R19 or escalated founder-arbitrated per §10.3 step 5), AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds, AND (d) Gate B baseline measurement begins.
agents/recruitment/diagnostic/agent.md:236:| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ Rounds run through R19; ADR-006 (Accepted) closed the Cat-1 Gate A finding; residual ~4 mechanical findings/round tracked in disagreement doc Phase 4-5 |
agents/recruitment/diagnostic/agent.md:246:**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (through R19; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on ~4 mechanical findings/round).
agents/recruitment/diagnostic/agent.md:269:Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
docs/decisions/2026-05-18-codex-ratification-manifest.md:138:**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 6 agent.md items with the new skill.
docs/decisions/2026-05-18-codex-ratification-manifest.md:226:| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
agents/recruitment/concierge/README.md:50:Codex re-ratification post-build via `review-agent-bundle.md` (queued).
docs/operations/goal-overnight-2026-05-31.md:18:4. `.codex/ratification/review-agent-bundle.md` (skill structure template)
docs/operations/goal-overnight-2026-05-31.md:28:Author modeled on `review-agent-bundle.md`. 7 checks layered on top of `SKILL.md`:
agents/recruitment/cash-conductor/agent.md:153:14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
agents/recruitment/cash-conductor/agent.md:448:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies via the cluster Fbis ratification run (`bash scripts/run-codex-ratification.sh --cluster Fbis`). Round-trip history: Day-20 W3 cluster E ratified the agent.md at the contract layer; cluster Fbis (2026-06-02) ratifies the bundle layer now that sibling files (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) exist alongside.
agents/recruitment/cash-conductor/agent.md:463:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
docs/operations/goal-week-4-track-1.md:65:13. **`.codex/ratification/review-mcp-connector.md`** exists. Type-specific skill for MCP connector packages. Adds checks on top of SKILL.md: OAuth refresh idempotency; rate-limit budget declared; explicit retry policy; secrets never logged; fixture-first tests; integration with `_shared/hook-helpers.sh` for decision_log emissions. Modeled on `review-agent-bundle.md` length + structure.
docs/operations/goal-week-4-track-1.md:161:Create `.codex/ratification/review-mcp-connector.md` modeled on `review-agent-bundle.md`. The skill ADDS these checks on top of `SKILL.md`:
agents/recruitment/concierge/agent.md:475:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/concierge/agent.md:490:- Codex re-ratifies post-build via `review-agent-bundle.md` skill
docs/operations/parallel-agent-build-method.md:64:2. **Review-subagent** — uses the existing `.codex/ratification/review-agent-bundle.md`
docs/operations/codex-ratification-guide.md:122:Three more skills (`review-agent-bundle.md`, `review-mcp-connector.md`, `review-harness-bump.md`) are deferred per the execution plan §3 — they're lazy, built at first need.
docs/operations/codex-ratification-execution-plan.md:72:| `review-agent-bundle.md` | The 6-file + 3-fixture pattern | ~250 | Pre-Diagnostic-W3 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:88:# Codex ratification skill — review-{type}
docs/operations/codex-ratification-execution-plan.md:429:- **Codex review of `agents/_shared/` runtime code via agent-bundle skill** — the 8-file `_shared/` set is reviewed under `review-architecture-decision.md` because it's not an agent bundle, it's the helper layer. Future agents (Diagnostic W3+) will be reviewed under `review-agent-bundle.md` once that skill exists.
docs/operations/goal-week-3-polish-and-scaffold.md:113:| Building any new Codex ratification skill (e.g., `review-agent-bundle.md`) | Defer per execution-plan §3 lazy; agent.md ratification uses existing `review-architecture-decision.md` skill |
docs/operations/goal-week-3-polish-and-scaffold.md:582:- `review-agent-bundle.md` — NOT YET BUILT (per execution-plan §3 lazy); defer; use review-architecture-decision.md for each agent.md individually
agents/recruitment/sourcing-scout/agent.md:390:Per `.codex/ratification/review-agent-bundle.md` skill (built 2026-05-24, commit `825ebd4`): this agent.md ratifies when Codex review-agent-bundle returns RATIFIED verdict on the SCAFFOLD shape (output contract + workflow + gates + escalation + dependencies). **Ratification of the scaffold does NOT make it Accepted.** Per the agent-bundle skill, Accepted means production-ready — which requires all sibling bundle files + fixtures + first production run.
agents/recruitment/sourcing-scout/agent.md:394:1. **Proposed → Ratified-as-Scaffold** when Codex review-agent-bundle returns RATIFIED on this agent.md alone. Pre-build scaffold confirmed shape-correct; the document is a binding contract for the W9 build slice.
agents/recruitment/scribe/agent.md:361:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/scribe/agent.md:372:- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)
docs/operations/decision-log.md:349:- [ ] **R8**: Adapter + brain-replacement boundary automation — `review-agent-bundle.md` Codex skill at Diagnostic W3
docs/operations/decision-log.md:416:- `825ebd4` review-agent-bundle.md skill built (closes Issue 5; unblocks Phase 2)
docs/operations/decision-log.md:661:- Codex bundle ratification via `review-agent-bundle.md` (skill not yet built; lazy per execution plan)
docs/operations/decision-log.md:667:**Codex Day-7 ratification queue:** grows by 1 (agent.md draft); ratifies individually via `review-architecture-decision.md` skill OR as part of full bundle via `review-agent-bundle.md` at W3 build close.
agents/recruitment/janitor/agent.md:307:Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
agents/recruitment/janitor/agent.md:318:- Codex re-ratifies post-build via `review-agent-bundle.md` skill (when built)

exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-31-d1-founder-decision.md | sed -n '1,170p'" in /Users/madsadmin/code/CortexOS/.claude/worktrees/agent-a4d7fb0c8ae47cca6
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

codex
REJECTED

1. §6 omits `ESC_BULLHORN_WRITE_FAIL` even though the built workflow uses it. Artefact §4 Step 13-14 describes Bullhorn activity-log/state writes at lines 279-296, but §6’s ESC table at lines 356-372 does not include the write-failure code. The built `cycle.sh` emits `ESC_BULLHORN_WRITE_FAIL` at lines 737 and 757, and the catalogue defines it at `agents/_shared/escalation-codes.md` lines 311-316. Add `ESC_BULLHORN_WRITE_FAIL` to §4 Step 13-14 and §6 with catalogue-matching trigger/severity/routing.

2. §5/§6 omit the anti-duplicate Gate A ESC actually emitted by `validate.sh`. Artefact §5 line 323 says the anti-duplicate guard is a hard-fail, but §6 lines 356-372 never lists `ESC_AUTOSEND_RACE`. `validate.sh` emits `ESC_AUTOSEND_RACE` for the G5 true-duplicate path at lines 330-331 and documents it at lines 365-368; the catalogue defines it at lines 357-364. Add `ESC_AUTOSEND_RACE` to §5 and §6, or change validate.sh to emit a documented Concierge code.

3. The orange send audit row is emitted before confirmed transport, contrary to §4’s send-execution contract. Artefact §4 Step 12 lines 271-277 presents `gmail_outlook_send_to_candidate` as the actual post-approval send action with `ESC_SEND_FAIL` on provider failure. In `cycle.sh`, the orange `hh_decision_action "gmail_outlook_send_to_candidate"` fires at lines 686-688 before the connector send loop at lines 697-705; a later failure only escalates at lines 711-714, leaving an action row that can imply a send happened. Move the orange action row to after confirmed provider success, or emit a distinct pending/attempt row plus a final success/failure row.
tokens used
110,433
REJECTED

1. §6 omits `ESC_BULLHORN_WRITE_FAIL` even though the built workflow uses it. Artefact §4 Step 13-14 describes Bullhorn activity-log/state writes at lines 279-296, but §6’s ESC table at lines 356-372 does not include the write-failure code. The built `cycle.sh` emits `ESC_BULLHORN_WRITE_FAIL` at lines 737 and 757, and the catalogue defines it at `agents/_shared/escalation-codes.md` lines 311-316. Add `ESC_BULLHORN_WRITE_FAIL` to §4 Step 13-14 and §6 with catalogue-matching trigger/severity/routing.

2. §5/§6 omit the anti-duplicate Gate A ESC actually emitted by `validate.sh`. Artefact §5 line 323 says the anti-duplicate guard is a hard-fail, but §6 lines 356-372 never lists `ESC_AUTOSEND_RACE`. `validate.sh` emits `ESC_AUTOSEND_RACE` for the G5 true-duplicate path at lines 330-331 and documents it at lines 365-368; the catalogue defines it at lines 357-364. Add `ESC_AUTOSEND_RACE` to §5 and §6, or change validate.sh to emit a documented Concierge code.

3. The orange send audit row is emitted before confirmed transport, contrary to §4’s send-execution contract. Artefact §4 Step 12 lines 271-277 presents `gmail_outlook_send_to_candidate` as the actual post-approval send action with `ESC_SEND_FAIL` on provider failure. In `cycle.sh`, the orange `hh_decision_action "gmail_outlook_send_to_candidate"` fires at lines 686-688 before the connector send loop at lines 697-705; a later failure only escalates at lines 711-714, leaving an action row that can imply a send happened. Move the orange action row to after confirmed provider success, or emit a distinct pending/attempt row plus a final success/failure row.
