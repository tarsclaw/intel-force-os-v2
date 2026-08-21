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
session id: 019e5a0f-7480-75f1-9275-49042f17a22c
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

Path: agents/recruitment/diagnostic/agent.md

--- BEGIN ARTEFACT ---

# Diagnostic — the sales tool

**Status:** Proposed (Day-19; full bundle built — agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures all present. Status flips Proposed → Accepted when ALL of these complete: (a) Codex RATIFIED verdict on this agent.md via review-agent-bundle.md skill, AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row), AND (d) Gate B baseline measurement begins (30% target; 4-week window). See §10 for the same checklist.)
**Date:** 2026-05-22.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
**Build complexity:** M (1 week) per Ultraplan §8.1 A1 line 489.
**Tier:** 2 (request-driven; no persistent PTY) per sequencing-target.md §2.1.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).

---

## §2 — Invocation surface

### CLI (v1.0)

```bash
# Manual consultant invocation, run from anywhere
ifosctl diagnostic \
  --firm "Charterhouse Partners" \
  --sector "fintech" \                  # optional; helps tighten ICP fit scoring
  --tenant <slug>                       # which tenant's target_patch + voice corpus to use
  --notify-via telegram                 # optional; pings consultant when done
```

Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY). Typical wall-clock: 10-15 minutes (empirical Day-13 measurement against Hays plc + Charterhouse fixtures); not specified in upstream master brief or Ultraplan.

### v1.1+ surfaces (deferred)

- Brain UI "Diagnose Firm" button → triggers via internal API
- Telegram bot command (`@ifos_bot diagnose Charterhouse Partners`)
- Bulk-mode (`ifosctl diagnostic --firm-list firms.csv`) — out of v1.0 scope

---

## §3 — The 12 required sections

Every report MUST contain these 12 sections. The generator (`@ifos/diagnostic-generator`) emits them in the order listed below. Gate A at v0 enforces (a) ≥12 `##` headings present in the rendered draft AND (b) per-section citation coverage; exact-heading-title-and-order matching is W4 polish (validate.sh §1.3 currently counts `##` headings without exact-title matching, per `validate.sh` lines 89-97 "exact-heading matching not implemented at v0; W4 polish adds title + order check").

| # | Section | What it contains | Source(s) |
|---|---|---|---|
| 1 | **Firm signal** | Companies House data: registered name, company number, incorporation date, latest filed accounts (revenue band + headcount band), registered office, recent director changes, share-class moves | Companies House API |
| 2 | **Online footprint** | Primary website URL + last-updated signal; LinkedIn company page URL + follower count + last-post recency; careers page URL + state (active / placeholder / 404) | Web scraper (HEAD + first 200 lines); LinkedIn company-page fetch |
| 3 | **Sector + role-type mix** | Sectors actively recruiting for (extracted from current job posts); ratio of permanent vs contract roles in last 90 days; technical-vs-commercial-vs-operational split | LinkedIn job posts + careers page job listings |
| 4 | **Geography** | Office locations + current hiring locations + remote-vs-onsite-vs-hybrid mix | LinkedIn job posts (location field) + Companies House registered office |
| 5 | **Deal-size band proxy** | Salary bands or day-rate ranges visible in job posts; level distribution (junior / mid / senior / executive); recent placements visible via LinkedIn employees-of-firm field changes | LinkedIn job posts + LinkedIn employee timeline scan |
| 6 | **ICP fit vs target_patch** | Score 0-100 against tenant's `target_patch.json` (sectors / geographies / size_bands / deal_size_band_gbp from `common-target-patch.json`). Includes named matches/mismatches per dimension | Tenant config + sections 1-5 above |
| 7 | **Tech stack signals** | Technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts | LinkedIn JDs + LinkedIn employee profiles |
| 8 | **Pain signals** | Phrases on careers page suggesting urgency ("rapid growth", "we're scaling fast", "looking to triple the team"); LinkedIn director posts mentioning hiring pressure or "we need help"; Glassdoor reviews mentioning workload/burnout (if accessible) | Careers page scrape + LinkedIn director post search + optional Glassdoor scrape |
| 9 | **Competitor positioning** | Other recruitment firms visible in the candidate flow: LinkedIn employee profiles showing previous-employer agency names; @firm tags in LinkedIn recruitment-agency posts; LinkedIn "Who's hiring this firm" inference where visible | LinkedIn profile scrapes + agency-tag search |
| 10 | **Recent activity** | LinkedIn company posts in last 90 days (count + summary); press releases or news mentions (basic Google search); funding events visible on Companies House (share allotments, new director appointments) | LinkedIn company page + Google web search + Companies House filing history |
| 11 | **Decision-maker map** | Named people likely to be buyers: head of talent / chief people officer / hiring manager equivalents. LinkedIn profile URL per person. Tenure at firm. Recent activity. | LinkedIn employee search filtered by title |
| 12 | **Conversation opener** | 2-3 sentence cold outreach pitch. Tailored to surfaced pain signals (§8). Written in consultant's voice (voice-classified). Includes specific evidence anchor (e.g., "I noticed you've doubled engineering headcount in 6 months based on your LinkedIn — congrats on the Series A. Curious how you're handling sourcing pressure at that pace.") | LLM-generated; voice-classified against tenant style guide |

**Gate A hard-fails** (per ADR-006 + §5 spec):

- Fewer than 12 sections present
- Any section with zero citation links (per-section citation subcheck; ADR-006-canonical)
- Section 12 (conversation opener) failing voice-classifier with score < 0.75 *(v0 hard-fail when voice-classifier URL reachable; warn + exit 0 when URL unreachable per §5 honesty note; W4 polish closes to unconditional hard-fail with explicit `validate_check_skipped` audit row)*
- Output exceeds 2000 words OR is under 400 words (length-discipline boundary)
- PII (email-domain mismatch) detected outside firm boundary *(v0 hard-fail when firm-domain whitelist available; warn + exit 0 when whitelist absent per §5 honesty note; W4 polish closes to unconditional hard-fail. v0 PII regex covers emails only; phone-number PII detection deferred to W4 polish.)*

**Per-step audit-row signatures** (per `decision_log`):
- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier

---

## §4 — Workflow

Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.

```
0. Session start — invocation arrives via CLI ifosctl diagnostic
   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
   → hh_decision_trigger("session_start", firm_name + sector_hint)

1. Validate input (cycle.sh Step 1)
   → cycle.sh checks: firm name length ≥ 2 chars
   → on fail: hh_decision_action("diagnostic_input_invalid", ...) with
     payload {escalation_code: ESC_INPUT_VALIDATION_FAIL, ...}
   → exit 1 on validation failure

2-11. Generator run (cycle.sh Steps 2-11 — single generator call)
   → bash invokes @ifos/diagnostic-generator with firm + sector + target_patch flags
   → generator fetches all 12 sections internally:
     - §1 Companies House lookup (cached 7d per gotcha §6.2)
     - §2 Online footprint via web-scraper + LinkedIn URL discovery
     - §3-§5-§7 Job posts harvest + tech stack extraction
     - §6 ICP fit scoring against tenant target_patch
     - §7-§11 Director + employee scan
     - §8 Pain signal extraction
     - §10 Recent activity scan
     - §12 Conversation opener (LLM-generated, voice-classified)
   → generator writes complete draft Markdown to /tmp/diagnostic-<firm-slug>-<ISO-date>.draft.md
   → on empty stdout: hh_decision_action("diagnostic_generator_empty", ...) with
     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
   → ESC_RATE_LIMIT_HIT raised internally by web-scraper / companies-house on 429
   → ESC_VOICE_DRIFT raised internally by §12 LLM step if classifier <0.75 after 3 retries
   → hh_decision_output("diagnostic_draft", "<draft_path>", "<firm> 12-section draft (pre-validate)")

12. Validate (Gate A) (cycle.sh Step 12)
   → bash invokes validate.sh against the draft path
   → per-section citation hard-fail (ADR-006 Tier 1; no warn-only path)
   → voice classifier + PII subchecks per §5 honesty note (warn-only on
     upstream-unavailable in v0; W4 closes to hard-fail)
   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE or
     ESC_PII_LEAKAGE_RISK) and exit 1
   → cycle.sh deletes draft on Gate A fail

13. Atomic vault write + report-render audit row (cycle.sh Step 13)
   → atomic mv -f /tmp/<draft> → /vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md
   → chmod 600 on the report
   → hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")
   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
     — tier: green per autosend-policy.yaml (no external send; vault write only)

14. Operator notification (optional, per --notify-via telegram flag) (cycle.sh Step 14)
   → if telegram: send via curl to api.telegram.org with report path + 200-char summary
     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
     → tier: green (operator-only Telegram; no customer-facing comms)
   → if no flag: silent completion (consultant checks vault); no decision-log row
   → cleanup.sh runs (drops transient LinkedIn cache per ToS gotcha §6.1)
   → exit 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.

**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.

**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.

- All 12 sections present in the assembled report (count + heading check) — **v0: hard-fails as specified**
- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section) — **v0: hard-fails as specified**
- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
- Report length 400-2000 words — **v0: hard-fails as specified**
- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
- No PII (emails) outside the firm boundary. **v0 behavior:** validate.sh runs a generic email-regex pass and warns on any email found (no firm-domain whitelist implemented in v0; warn-only; exit 0). W4 polish adds the firm-domain whitelist + hard-fail behavior + `ESC_PII_LEAKAGE_RISK` emission. **v0 PII coverage:** emails only via regex; phone-number PII detection + whitelist enforcement deferred to W4 polish.

### Gate B — Outcome threshold (success metric, not block)

Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.

Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.

---

## §6 — Escalation codes

Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |

Diagnostic does NOT use:

- `ESC_RENDERER_FAILED` — that code is owned by the `_renderer` sentinel (agent_name='_renderer') per catalogue §2.4; Diagnostic never fires it
- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention

---

## §7 — Voice + tone constraints

Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
  - No "I hope this finds you well" or other generic openers
  - No salary or commission anchors in cold outreach
  - Specific evidence anchor required (not generic "great company")
- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
- **`hh_load_recent_edits` last 30 days for `diagnostic`** (single agent_name arg per `voice-loader.sh::hh_load_recent_edits`; current `context.sh` passes `"diagnostic"` only): surfaces patterns of how consultant edits Diagnostic drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Production-readiness dependencies

Full bundle (all 6 files + 3 fixtures) is built as of Day 19. Production readiness — i.e. running against a real pilot tenant — additionally requires the items below resolved to ✅.

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 commits | ✅ Ratified (Round 3) |
| Live VPS migration applied | `bash scripts/run-live-migration.sh` | ✅ Applied Day 12 |
| Tenancy audit passes 12 invariants | `bash scripts/run-tenancy-audit.sh` | ✅ 24/24 invariants verified Day 12 |
| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
| `target_patch.json` for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI (per tenant-lifecycle.md §2) |
| Voice corpus seeded for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI |
| Companies House MCP connector | `packages/mcp-connectors/companies-house/` | ✅ Shipped Day 13; 13/13 tests passing |
| LinkedIn read-only via web-scraper | `packages/utilities/web-scraper/` | ✅ Shipped Day 13; 12/12 tests passing (Proxycurl deferred to W4) |
| Web scraper utility (HEAD + first-N-lines) | `packages/utilities/web-scraper/` | ✅ Shipped Day 13 |
| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
| `context.sh` hydration | `agents/recruitment/diagnostic/context.sh` | ✅ Built |
| 3 fixtures with golden outputs | `agents/recruitment/diagnostic/fixtures/` | ✅ Built (01-primary + 02-edge-case + 99-voice-drift-canary) |
| Other bundle files (cycle.sh, tools.yaml, cleanup.sh) | `agents/recruitment/diagnostic/` | ✅ All built |
| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ 10 rounds attempted; ADR-006 (Accepted) closed Cat-1 Gate A finding; residual mechanical findings tracked in disagreement doc Phase 4-5 |

**Production-readiness gates:** all ⏸ items above must resolve to ✅ before first production render against a pilot tenant. Bundle code itself is complete.

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + Codex RATIFIED verdict + first production render.

**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (10+ rounds; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on smaller mechanical findings).

### Open questions for founder review

| # | Question | Resolution path |
|---|---|---|
| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
| Q2 | Should §11 (decision-maker map) be a separate section OR rolled into §3 + §4 + §5 + §7 as a sub-row? Currently named as a separate section. | Founder review at agent.md ratification. |
| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | Resolved at W3 start before Companies House + LinkedIn MCP connectors authored. Founder + Claude decide together. |
| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
| Q5 | What's the "firm-slug" canonical form for the output filename? Companies House registration number? URL-slugified firm name? | Recommend Companies House number for stability; canonical-slug fallback for non-UK firms (v1.1+). |
| Q6 | Should §10 (recent activity) include Glassdoor reviews? ToS implications. | Per gotcha §6 below: caution; default OFF for v1.0; explicit founder enable for v1.1+. |

### Gotchas (carried forward from Ultraplan §8.1 A1)

1. **LinkedIn ToS — cannot store profile data beyond the audit.** Profile fetches are cached only for the duration of the report generation (typ. 10-15 min). After report writes to vault, raw profile data is dropped from agent memory + no persistence in Postgres.
2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
3. **Glassdoor scraping — uncertain ToS compatibility.** Default OFF for v1.0. Per Q6 above.

---

## §10 — When this document ratifies

Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.

Status flips to Accepted when:
- Codex Round-3+ ratifies the full bundle
- Founder approves §3's 12-section list as canonical
- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
- Gate B baseline measurement begins (30% target; 4-week window)

Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.

*End of Diagnostic agent.md draft.*

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
I’ll verify the cited local sources and the Diagnostic bundle shape against the ratification rules, then return only the required verdict format.
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/MASTER-BRIEF.md | sed -n '585,605p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/ULTRAPLAN.md | sed -n '480,505p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
nl: docs/verticals/recruitment/ULTRAPLAN.md: No such file or directory

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

 succeeded in 0ms:
nl: docs/verticals/recruitment/MASTER-BRIEF.md: No such file or directory

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
   109	    agent: diagnostic
   110	    reason: "Gate B feedback row written when consultant tags a Diagnostic report as booked|not-booked via Telegram (/diagnostic-feedback <report-id> ...) or Brain UI button. agent_name='diagnostic'; phase='action'; payload includes report_id + outcome. Internal-only; no external send."
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

codex
The first cited master brief and Ultraplan filenames are not at the literal paths implied by the artefact, so I’m locating the canonical files before treating any citation as drift.
exec
/bin/zsh -lc 'find agents/recruitment/diagnostic -maxdepth 2 -type f | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/diagnostic/README.md
agents/recruitment/diagnostic/agent.md
agents/recruitment/diagnostic/cleanup.sh
agents/recruitment/diagnostic/context.sh
agents/recruitment/diagnostic/cycle.sh
agents/recruitment/diagnostic/fixtures/01-primary.yaml
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml
agents/recruitment/diagnostic/tools.yaml
agents/recruitment/diagnostic/validate.sh

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# shellcheck disable=SC2155
     3	#
     4	# Diagnostic agent — validate.sh (Gate A enforcement)
     5	#
     6	# Status: Proposed (pre-W3-build scaffold; Day-12 author).
     7	# Reading order: agent.md §5 (Gates) + §6 (Escalation codes) first.
     8	#
     9	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
    10	# is the hard-fail gate that runs AFTER cycle.sh produces a draft report
    11	# but BEFORE the vault write + operator notify. If any check fails,
    12	# validate.sh exits non-zero and emits an ESC_* escalation row to
    13	# decision_log; the report does NOT land in the vault.
    14	#
    15	# Invocation contract:
    16	#   bash validate.sh <draft_report_path>
    17	#
    18	# Inputs:
    19	#   - $1: path to the draft Markdown report (cycle.sh writes it to /tmp first)
    20	#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
    21	#          CTX_TONE_RULES (json string)
    22	#
    23	# Exit codes:
    24	#   0  All Gate A checks pass; cycle.sh proceeds to vault write
    25	#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts
    26	#   2  validate.sh invocation error (bad args, missing draft, etc.)
    27	#
    28	# Checks (per agent.md §5 Gate A):
    29	#   V1 — All 12 sections present (count + heading regex)
    30	#   V2 — Each section has ≥1 markdown link (regex)
    31	#   V3 — Section 12 voice classifier score ≥ 0.75
    32	#   V4 — Report length 400-2000 words
    33	#   V5 — No banned phrases per tone_rule table
    34	#   V6 — No PII outside firm boundary (regex pass)
    35	
    36	set -uo pipefail
    37	
    38	# ────────────────────────────────────────────────────────────────────────
    39	# Pre-flight
    40	# ────────────────────────────────────────────────────────────────────────
    41	
    42	if [[ $# -lt 1 ]]; then
    43	  printf 'validate.sh: usage: validate.sh <draft_report_path>\n' >&2
    44	  exit 2
    45	fi
    46	
    47	readonly DRAFT="$1"
    48	
    49	if [[ ! -f "${DRAFT}" ]]; then
    50	  printf 'validate.sh: draft not found at %s\n' "${DRAFT}" >&2
    51	  exit 2
    52	fi
    53	
    54	if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
    55	  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
    56	  exit 2
    57	fi
    58	
    59	# Source helpers for escalation emission
    60	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    61	  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
    62	  exit 2
    63	fi
    64	# shellcheck source=/dev/null
    65	source "${CTX_AGENT_DIR}/.claude/hooks/_shared/hook-helpers.sh"
    66	
    67	# Track failures across all checks; collect all before exit (richer audit)
    68	declare -a FAILURES=()
    69	declare -a WARNINGS=()
    70	
    71	_fail() {
    72	  FAILURES+=("$1")
    73	  printf '  ✗ %s\n' "$1" >&2
    74	}
    75	
    76	_pass() {
    77	  printf '  ✓ %s\n' "$1"
    78	}
    79	
    80	_warn() {
    81	  WARNINGS+=("$1")
    82	  printf '  ! %s\n' "$1" >&2
    83	}
    84	
    85	# ────────────────────────────────────────────────────────────────────────
    86	# V1 — 12 sections present
    87	# ────────────────────────────────────────────────────────────────────────
    88	
    89	# Section labels documented for reference; not currently regex-matched
    90	# individually because count + per-section citation check covers V1+V2.
    91	# At W3 build: tighten to enforce exact-heading match per EXPECTED_SECTIONS.
    92	SECTION_COUNT=$(grep -cE '^##[[:space:]]' "${DRAFT}" || echo 0)
    93	if (( SECTION_COUNT == 12 )); then
    94	  _pass "V1: 12 sections present"
    95	else
    96	  _fail "V1: expected 12 sections, found ${SECTION_COUNT}"
    97	fi
    98	
    99	# ────────────────────────────────────────────────────────────────────────
   100	# V2 — Each section has ≥1 markdown link
   101	# ────────────────────────────────────────────────────────────────────────
   102	
   103	# Per-section citation check: single awk pass tracks current section
   104	# index, sets has_link[i]=1 when a Markdown link is found within a
   105	# section's body, then prints the indices of sections with no link.
   106	MISSING_INDICES=$(awk '
   107	  /^## / { sec_num++; next }
   108	  sec_num > 0 && /\[[^]]+\]\([^)]+\)/ { has_link[sec_num]=1 }
   109	  END {
   110	    for (i=1; i<=sec_num; i++) {
   111	      if (!has_link[i]) printf "%d ", i
   112	    }
   113	  }
   114	' "${DRAFT}")
   115	
   116	MISSING_CITATION=()
   117	for idx in ${MISSING_INDICES}; do
   118	  MISSING_CITATION+=("section ${idx}")
   119	done
   120	
   121	if (( ${#MISSING_CITATION[@]} == 0 )); then
   122	  _pass "V2: every section has ≥1 citation link"
   123	else
   124	  _fail "V2: missing citation in: ${MISSING_CITATION[*]}"
   125	fi
   126	
   127	# ────────────────────────────────────────────────────────────────────────
   128	# V3 — §12 voice classifier ≥ 0.75
   129	# ────────────────────────────────────────────────────────────────────────
   130	
   131	# Extract §12 (conversation opener)
   132	SECTION_12=$(awk '/^## .*[Cc]onversation [Oo]pener/{flag=1; next} /^## /{flag=0} flag' "${DRAFT}")
   133	
   134	if [[ -z "${SECTION_12}" ]]; then
   135	  _fail "V3: §12 (Conversation opener) section not found or empty"
   136	else
   137	  # Voice classifier microservice call (W3 build wires this up)
   138	  # For scaffold: assume IFOS_VOICE_CLASSIFIER_URL set; fail gracefully if not
   139	  if [[ -n "${IFOS_VOICE_CLASSIFIER_URL:-}" ]]; then
   140	    SCORE=$(curl -sS -X POST "${IFOS_VOICE_CLASSIFIER_URL}/classify" \
   141	      -H "Content-Type: application/json" \
   142	      -d "$(printf '{"text":%s,"tenant_slug":"%s"}' \
   143	        "$(printf '%s' "${SECTION_12}" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))")" \
   144	        "${CTX_TENANT_SLUG}")" \
   145	      2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('score', 0))" 2>/dev/null || echo "0")
   146	
   147	    if [[ -n "${SCORE}" ]] && python3 -c "import sys; sys.exit(0 if float('${SCORE}') >= 0.75 else 1)" 2>/dev/null; then
   148	      _pass "V3: §12 voice classifier score=${SCORE} (≥ 0.75)"
   149	    else
   150	      _fail "V3: §12 voice classifier score=${SCORE} (< 0.75)"
   151	    fi
   152	  else
   153	    _warn "V3: IFOS_VOICE_CLASSIFIER_URL unset; voice classification SKIPPED (W3 build wires this)"
   154	  fi
   155	fi
   156	
   157	# ────────────────────────────────────────────────────────────────────────
   158	# V4 — Length 400-2000 words
   159	# ────────────────────────────────────────────────────────────────────────
   160	
   161	WORD_COUNT=$(wc -w < "${DRAFT}" | tr -d ' ')
   162	if (( WORD_COUNT >= 400 && WORD_COUNT <= 2000 )); then
   163	  _pass "V4: word count=${WORD_COUNT} (400-2000)"
   164	elif (( WORD_COUNT < 400 )); then
   165	  _fail "V4: report too short (${WORD_COUNT} words; min 400)"
   166	else
   167	  _fail "V4: report too long (${WORD_COUNT} words; max 2000)"
   168	fi
   169	
   170	# ────────────────────────────────────────────────────────────────────────
   171	# V5 — Banned phrases per tone_rule
   172	# ────────────────────────────────────────────────────────────────────────
   173	
   174	if [[ -n "${CTX_TONE_RULES:-}" ]]; then
   175	  BANNED_HITS=$(printf '%s' "${CTX_TONE_RULES}" | python3 -c "
   176	import json, sys, re
   177	data = json.loads(sys.stdin.read() or '{}')
   178	rules = data.get('rules', [])
   179	with open('${DRAFT}', 'r') as f:
   180	    text = f.read()
   181	hits = []
   182	for r in rules:
   183	    if r.get('severity') == 'block':
   184	        for phrase in r.get('examples_negative', []):
   185	            if phrase and phrase.lower() in text.lower():
   186	                hits.append(f\"rule={r.get('rule_id')} phrase='{phrase}'\")
   187	print('|'.join(hits))
   188	" 2>/dev/null || echo "")
   189	
   190	  if [[ -z "${BANNED_HITS}" ]]; then
   191	    _pass "V5: no banned phrases detected"
   192	  else
   193	    _fail "V5: banned phrases detected: ${BANNED_HITS}"
   194	  fi
   195	else
   196	  _warn "V5: CTX_TONE_RULES empty; banned-phrase check skipped"
   197	fi
   198	
   199	# ────────────────────────────────────────────────────────────────────────
   200	# V6 — No PII outside firm boundary
   201	# ────────────────────────────────────────────────────────────────────────
   202	#
   203	# Detect emails/phones in the report that DON'T belong to the firm being
   204	# diagnosed. Simple regex pass; production W3 build adds NER pass.
   205	
   206	FIRM_NAME="${IFOS_DIAGNOSTIC_FIRM_NAME:-unknown}"
   207	# At W3 build: extract firm domain from Companies House link to scope
   208	# the PII-boundary check. Stub for scaffold.
   209	
   210	# Find all emails in the report
   211	ALL_EMAILS=$(grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "${DRAFT}" | sort -u || echo "")
   212	
   213	# This is a coarse check — true PII boundary requires firm-domain enumeration
   214	# at W3 build. For scaffold: warn if any email present (rather than fail)
   215	# since we don't yet have the firm-domain whitelist mechanism.
   216	if [[ -n "${ALL_EMAILS}" ]]; then
   217	  _warn "V6: emails present in report (verify they belong to ${FIRM_NAME}): $(echo "${ALL_EMAILS}" | tr '\n' ' ')"
   218	else
   219	  _pass "V6: no emails embedded (firm-boundary PII check trivially passes)"
   220	fi

exec
/bin/zsh -lc "rg --files | rg '(master|MASTER|brief|BRIEF|ULTRAPLAN|ultraplan|sequencing-target|vertical-schema|ADR-006|ADR-003|ADR-004|v1.0-kill|voice-loader|common-voice)'" in /Users/madsadmin/code/CortexOS
 succeeded in 103ms:
agents/_shared/voice-loader.sh
agents/_shared/tests/test-voice-loader.sh
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
docs/specs/ULTRAPLAN.md
docs/_supplementary/planning-phase-brief.md
docs/build-brief/00-MASTER-BRIEF.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_sequencing-target-md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_ADR-003-agent-bundle-renderer-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
packages/agents-runtime/_shared/common-voice.json
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/sequencing-target.md
legacy/v1/docs/phase-5-business-legal/marketing/trademark-filing-brief.md
legacy/v1/MASTER-INDEX.md
legacy/v1/docs/phase-0-strategic/intelforce-planning-phase-brief.md

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '485,500p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   485	### 8.1 v1.0 agents (six)
   486	
   487	#### A1. The Diagnostic — the sales tool
   488	
   489	- **Build wave:** v1.0 (week 4–5)
   490	- **Always-on?** No — invoked on demand
   491	- **Trigger type:** Manual (run from CLI or sales-tool web page)
   492	- **CortexOS primitives required:** None — runs as a one-shot batch job
   493	- **MCP tools required:** Companies House, LinkedIn (read-only), web scraper for careers pages
   494	- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
   495	- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
   496	- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
   497	- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
   498	- **Build complexity:** **M** (1 week)
   499	- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.
   500	

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '585,605p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
     1	# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
     2	
     3	**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
     4	**Author:** Founder (Maddox) + Claude Code
     5	**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 — Gate A citation requirement
     6	**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
     7	**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
     8	
     9	---
    10	
    11	## Context
    12	
    13	ULTRAPLAN §8.1 A1 line 496 (pre-amendment wording — before this ADR's in-band edit landed in commit `aed9d3b`):
    14	
    15	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
    16	
    17	Current line 496 (post-amendment; live as of commit `aed9d3b`):
    18	
    19	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
    20	
    21	The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
    22	
    23	(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
    24	
    25	This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
    26	
    27	1. NLP claim-extraction from the rendered Markdown report (sentence-level fact identification)
    28	2. Per-claim evidence-link matching (semantic similarity between claim and cited URL content)
    29	3. Confidence threshold tuning to avoid false rejections of well-cited paraphrases
    30	
    31	This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
    32	
    33	Bilateral founder+Claude session on 2026-05-24 (Day 19) selected option **(b) — hybrid framing** as the disposition (Cat-1 in the disagreement doc). Founder authorization via AskUserQuestion accepted: "Hybrid (Recommended): v0 = per-section, W4 = per-claim spot-check".
    34	
    35	This ADR formalises that disposition as a ratified architectural decision so future Codex rounds + agent.md §5 framing treat it as upstream-canonical, not as a downstream weakening.
    36	
    37	---
    38	
    39	## Decision
    40	
    41	### Decision 1 — Diagnostic Gate A citation validation is per-section coverage ONLY (hard-fail)
    42	
    43	Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
    44	
    45	The OTHER Gate A subchecks (voice classifier ≥ 0.75 and PII boundary) have v0 warn-only paths when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these are honesty-flagged with `validate_check_skipped=true` per the Context section above. W4-polish closes those subchecks to hard-fail. This ADR addresses only the per-section citation subcheck of Gate A; it does NOT modify the voice classifier or PII subchecks.
    46	
    47	### Decision 2 — Per-claim citation validation is a SEPARATE post-launch quality metric (NOT Gate A)
    48	
    49	The per-claim citation pipeline (NLP claim-extraction + per-claim evidence-link matching + aggregate quality metric) is **explicitly outside Gate A** in v1.0. It lands as:
    50	
    51	- A separate post-launch Diagnostic quality signal — analogous to Gate B's outcome threshold (30% discovery-call conversion) but for citation quality
    52	- Authored as a separate W4 ADR (number to be assigned at W4-polish authoring time; this ADR does NOT pre-assign a number) together with the schema supplements that define its payload key + per-tenant config field
    53	- Sampling-based (1-in-N) post-launch quality monitoring; warn-level; never blocks v0 sends
    54	- Activates after voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports
    55	
    56	**Rule 2 (Schema before code) satisfied:** the schema work for the per-claim quality metric (payload key + per-tenant config field) lands in the future W4 ADR's supplements before any code reads/writes those fields. This ADR-006 does NOT introduce schema fields; it only specifies Gate A as per-section hard-fail.
    57	
    58	**Rule 4 (Quality gates before features) satisfied for the per-section citation subcheck:** it is hard-fail at v0 with no warn-only paths. (Other Gate A subchecks — voice classifier + PII — retain v0 warn-only paths when upstream services are unreachable per Context note; W4-polish closes those. ADR-006 addresses only the per-section subcheck.) Per-claim quality is a separate signal, not a weakening of Gate A's per-section subcheck.
    59	
    60	---
    61	
    62	## ULTRAPLAN amendment
    63	
    64	`docs/specs/ULTRAPLAN.md` §8.1 A1 line 496 reads (verbatim, before this ADR):
    65	
    66	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
    67	
    68	After this ADR ratifies, the canonical interpretation is:
    69	
    70	> **Gate A (per ADR-006):** report contains all 12 required sections; each section has at least 1 evidence link — per-section citation subcheck is hard-fail (no warn-only paths). The ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link"; per-claim citation analysis is a SEPARATE post-launch quality metric outside Gate A (a W4 ADR to be authored at first-pilot polish time).
    71	
    72	**In-band amendment (landed in commit `aed9d3b`):** `docs/specs/ULTRAPLAN.md` line 496 now reads verbatim:
    73	
    74	> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
    75	
    76	This is the explicit in-band amendment Codex `review-architecture-decision` ratification path requires — reviewers consulting ULTRAPLAN §8.1 A1 see the pointer to ADR-006 directly in the source line. The amendment landed alongside the ADR-006 R2 fix commit, not in a future commit.
    77	
    78	---
    79	
    80	## Why hybrid not full-spec
    81	
    82	**Why not (a) defer launch until per-claim lands?**
    83	- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
    84	- A working v0 with per-section validation has measurable Gate A coverage; deferring means no Gate A at all in the meantime, which is strictly worse
    85	- The 30%-discovery-call Gate B target is independent of per-claim validation; pilot value is reachable without it
    86	
    87	**Why not (c) amend ULTRAPLAN downward permanently?**
    88	- The per-claim requirement is genuinely valuable for v1.1+ once the NLP pipeline exists
    89	- Permanently removing it from ULTRAPLAN loses the documented quality bar
    90	- Hybrid preserves the W4-polish path; permanent amendment closes that door
    91	
    92	**Why hybrid is honest signal (Rule 5):**
    93	- v0 implementation does what it says; W4 polish path is documented + scheduled
    94	- Codex flags become explicit-disposition references (this ADR) not unaddressed weakening
    95	- Pilot tenants reading Gate A spec see the v0 contract clearly + the W4 expansion plan
    96	
    97	---
    98	
    99	## Consequences
   100	
   101	### Immediate (this ADR commit)
   102	
   103	- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
   104	- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)
   105	
   106	### Next commit (after this ADR ratifies)
   107	
   108	- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
   109	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` queue updated to include this ADR. NOT yet updated as of this commit; lands in the post-ratify commit.
   110	
   111	### After Codex ratifies this ADR (Status flips Proposed → Accepted)
   112	
   113	- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the original ULTRAPLAN line 496 prose alone)
   114	- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
   115	
   116	### W4-polish slice (after voice-classifier microservice ships + first pilot tenant data accumulates)
   117	
   118	- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
   119	- Sample rate configurable per tenant via field landing in v0.3 vertical-schema supplement (concrete field name + type specified there, not in this ADR)
   120	- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
   121	- Threshold breach → `ESC_AGENT_OUTPUT_SHAPE` warn (info-only; no block)
   122	
   123	### Downstream artefact references (queued for post-ratify commit)
   124	
   125	- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
   126	- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
   127	- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
   128	- `docs/decisions/2026-05-18-codex-ratification-manifest.md` → adds this ADR as ratification queue item
   129	
   130	These edits all land in the next commit AFTER this ADR ratifies (no point updating agent.md to cite a Proposed ADR; cite once ratified).
   131	
   132	---
   133	
   134	## Open questions
   135	
   136	| # | Question | Resolution path |
   137	|---|---|---|
   138	| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
   139	| Q2 | NLP claim-extraction library — what's the right tool? (spaCy + custom rules / Claude API-based extraction / hosted service) | W4 polish technical investigation; cost vs accuracy tradeoff |
   140	| Q3 | Per-claim confidence threshold — 0.6 in this ADR is a starting point; calibrate against pilot data | W4 polish empirical tuning with first-pilot consultant feedback |
   141	
   142	---
   143	
   144	## Status
   145	
   146	**Proposed.** Awaits Codex ratification via `review-architecture-decision.md` skill.
   147	
   148	Status flips Proposed → Accepted when:
   149	- Codex returns RATIFIED for this ADR
   150	- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
   151	
   152	*End of ADR-006.*

exec
/bin/zsh -lc "nl -ba docs/decisions/sequencing-target.md | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# v1.0 agent sequencing target — decision document
     2	
     3	**Date:** 2026-05-16 (Week 0, Day 3)
     4	**Status:** Accepted (Day 3 session close, 2026-05-16). Single-pass technical decision, no commercial gating.
     5	**Author:** Claude Code, founder decision logged 2026-05-16
     6	**Surfaced by:** Master brief §6 Day 3 (lines 469-473) — "Confirm or revise Ultraplan §9's 'close first 3 pilots fastest' → `.agents/decisions/sequencing-target.md`" (note: master brief §6 names `.agents/decisions/`; this document lives at `docs/decisions/sequencing-target.md` matching the convention established by ADR-001 through ADR-003 + bullhorn-integration-path.md — **Spec gap §1-A** flagged for atomic correction).
     7	**Submodule SHA referenced:** `c21fbfe991a0030ea055bd8e2389a0801a424383`
     8	
     9	**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
    10	
    11	---
    12	
    13	## Section 1 — Context and sequencing criteria
    14	
    15	### 1.1 — What we're deciding
    16	
    17	Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
    18	
    19	| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
    20	|---|---|---|---|---|
    21	| A1 | Diagnostic | 3-4 | LinkedIn + Companies House + scrape | "Sales tool — needed before any other agent matters" |
    22	| A2 | Janitor | 5 | Bullhorn MCP (R+W) | "First demoable inside-ATS result; day-30 before/after closes deals" |
    23	| A3 | Scribe | 6 | Fathom/Fireflies MCP + Bullhorn W | "Post-call note in Bullhorn within 10 min — second-most-demoable" |
    24	| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
    25	| A5 | Sourcing Scout (daytime) | 9 | LinkedIn + Reed + CV-Library | "First daytime always-on agent" |
    26	| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
    27	
    28	Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
    29	
    30	**Three sub-decisions in this document:**
    31	
    32	- **A. First agent.** Which agent ships first in Week 3-4? Anchors the renderer (ADR-003) + `_shared/` helpers (Week-1-2 prereqs from ADR-002) + Postgres `decision_log` (Day 4 Week 0) end-to-end test. Affects how risk surfaces — first agent is the smoke test for every substrate dependency.
    33	- **B. Sequence for agents 2-6.** The remaining five agents in some order across Weeks 5-13. Three candidate orderings compared in §3.
    34	- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
    35	
    36	### 1.2 — Why this matters now
    37	
    38	Three reasons the sequencing decision lands this week, not later:
    39	
    40	**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
    41	
    42	**Weeks 5-13 planning is speculative without §B.** Each agent's prerequisites (Bullhorn MCP, Fathom/Fireflies, Xero, LinkedIn) have lead times. Bullhorn MCP work itself starts Week 1 per Ultraplan §9 line 724 ("Bullhorn MCP server is the critical path; week 1 starts on it"). Without knowing the agent build order, those infrastructure prereqs can't be sequenced.
    43	
    44	**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
    45	
    46	The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
    47	
    48	### 1.3 — Sequencing criteria
    49	
    50	Six criteria to evaluate each agent against in §2. Each criterion scored High / Medium / Low or with a concrete number; substantive cells in §2 must justify the score by reference to master brief / Ultraplan / Product Spec / Day-2 Bullhorn decision.
    51	
    52	| # | Criterion | What it measures | Why it informs sequencing |
    53	|---|---|---|---|
    54	| 1 | **Implementation simplicity** | Lines of agent code in `agent.md` workflow + number of MCP servers touched + complexity of output contract (single-output vs multi-stage vs lifecycle-state) | Simpler agents land faster and exercise less substrate at once — better first-agent candidates because failure modes are easier to isolate |
    55	| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
    56	| 3 | **Risk de-risking** | Which named risks the agent's success/failure surfaces — Risk #1 (cortextOS primitives), Risk #2 (Bullhorn auth), Risk #5 (renderer-not-built) — per `docs/RISK-REGISTER.md` | Building risk-surfacing agents earlier converts known-unknowns into known-knowns; building risk-deferring agents earlier preserves optionality but pushes the surprise window later |
    57	| 4 | **Commercial value** | Whether the agent's output is demoable to a design partner / first paying customer per Product Spec §2.2 R-rows | Earlier commercial-value agents accelerate the first-pilot conversion (Ultraplan §9 line 725 target Week 12); but commercial-value agents are typically the more complex ones, conflicting with criterion 1 |
    58	| 5 | **Dependencies on other agents** | Does this agent's output feed another agent? Does this agent require another agent's output to function? | Agents with downstream dependents should ship before their dependents; agents with no upstream dependencies are good first candidates |
    59	| 6 | **Tenant-onboarding readiness** | Can this agent be deployed to one tenant without all infrastructure being live? (E.g. does it need the wiki API in v1.0 weeks 11-13, or only the Week-1-2 substrate?) | Earlier-readiness agents can pilot in shadow mode against the first design partner before all v1.0 infra is complete |
    60	
    61	The six criteria intentionally tension against each other — implementation simplicity (1) trades off against commercial value (4); substrate exercise (2) trades off against risk-isolation (3). The §2 per-agent assessments make the trade-offs visible per agent; the §3 sequencing options weight them differently; the §4 recommendation picks one weighting.
    62	
    63	### 1.4 — Scope cuts and v1.0 minimum
    64	
    65	Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
    66	
    67	> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
    68	
    69	There are actually **two named contingency paths**, corresponding to two different failing risks:
    70	
    71	- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
    72	- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.
    73	
    74	Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
    75	
    76	The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
    77	
    78	### 1.5 — One small but real finding before §2 begins
    79	
    80	Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
    81	
    82	Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
    83	
    84	**Section 4's recommendation evaluates both orderings** (founder-prompt-Alpha and master-brief-Alpha) against the §1.3 criteria, picks whichever wins on the merits, and explicitly aligns with the master brief by default unless rationale exists to revise it. This document is the "confirm or revise" decision per master brief §6 Day 3 line 471 — both options are on the table.
    85	
    86	---
    87	
    88	## Section 2 — Per-agent readiness assessment
    89	
    90	Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
    91	
    92	### 2.1 — A1 Diagnostic
    93	
    94	| Criterion | Score | Rationale |
    95	|---|---|---|
    96	| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
    97	| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
    98	| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
    99	| 4. Commercial value | **Medium** | Internal sales tool per Product Spec §2.2 R13 ("Not on the customer pricing card"). Drives qualified discovery-call pipeline. Demoable to a prospect but not the closing demo. Ultraplan §8.1 line 499 Gate B target: "≥30% of diagnostics produced lead to a discovery call booked" |
   100	| 5. Dependencies on other agents | **None** | Standalone. No upstream agent dependency; no downstream agent consumes Diagnostic output |
   101	| 6. Tenant-onboarding readiness | **High** | Runnable from end of Week 2 with renderer + `_shared/` + Postgres decision_log. No vault `_secrets.env` complexity (no per-tenant Bullhorn OAuth needed), no wiki API needed. Single-tenant deployable immediately |
   102	
   103	**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
   104	
   105	### 2.2 — A2 Janitor
   106	
   107	| Criterion | Score | Rationale |
   108	|---|---|---|
   109	| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 513 estimate **L (2 weeks)** — the Bullhorn MCP work is rate-limiting per Ultraplan §8.1 line 514 ("Bullhorn MCP server doesn't exist yet — this is the critical-path build"). One MCP server (Bullhorn) + Companies House for enrichment. Single primary output (cleanup report) but with continuous nightly cron pattern |
   110	| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
   111	| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
   112	| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
   113	| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
   114	| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn `client_id` + `client_secret` (commercial action per Day 2 §6.1) + per-tenant Bullhorn admin OAuth authorisation (the browser dance per Day 2 §3.1). First-pilot onboarding wizard Day 2 step (Product Spec §5.2) is the moment Janitor can be enabled per tenant |
   115	
   116	**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
   117	
   118	### 2.3 — A3 Scribe
   119	
   120	| Criterion | Score | Rationale |

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Diagnostic — the sales tool
     2	
     3	**Status:** Proposed (Day-19; full bundle built — agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures all present. Status flips Proposed → Accepted when ALL of these complete: (a) Codex RATIFIED verdict on this agent.md via review-agent-bundle.md skill, AND (b) founder approves §3's 12-section list as canonical, AND (c) first production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row), AND (d) Gate B baseline measurement begins (30% target; 4-week window). See §10 for the same checklist.)
     4	**Date:** 2026-05-22.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W3-4 per master brief §8.2 line 595 (row 1; anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`. **Drift flag:** Ultraplan §8.1 A1 (line 489) calls Diagnostic build wave 4-5; master brief line 595 calls it W3-4. Master brief is authoritative per CLAUDE.md (master brief wins on every conflict); W3-4 is the build wave for IFOS.
     7	**Build complexity:** M (1 week) per Ultraplan §8.1 A1 line 489.
     8	**Tier:** 2 (request-driven; no persistent PTY) per sequencing-target.md §2.1.
     9	
    10	---
    11	
    12	## §1 — Output contract (one-paragraph screenshot)
    13	
    14	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    15	
    16	> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
    17	
    18	---
    19	
    20	## §2 — Invocation surface
    21	
    22	### CLI (v1.0)
    23	
    24	```bash
    25	# Manual consultant invocation, run from anywhere
    26	ifosctl diagnostic \
    27	  --firm "Charterhouse Partners" \
    28	  --sector "fintech" \                  # optional; helps tighten ICP fit scoring
    29	  --tenant <slug>                       # which tenant's target_patch + voice corpus to use
    30	  --notify-via telegram                 # optional; pings consultant when done
    31	```
    32	
    33	Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY). Typical wall-clock: 10-15 minutes (empirical Day-13 measurement against Hays plc + Charterhouse fixtures); not specified in upstream master brief or Ultraplan.
    34	
    35	### v1.1+ surfaces (deferred)
    36	
    37	- Brain UI "Diagnose Firm" button → triggers via internal API
    38	- Telegram bot command (`@ifos_bot diagnose Charterhouse Partners`)
    39	- Bulk-mode (`ifosctl diagnostic --firm-list firms.csv`) — out of v1.0 scope
    40	
    41	---
    42	
    43	## §3 — The 12 required sections
    44	
    45	Every report MUST contain these 12 sections. The generator (`@ifos/diagnostic-generator`) emits them in the order listed below. Gate A at v0 enforces (a) ≥12 `##` headings present in the rendered draft AND (b) per-section citation coverage; exact-heading-title-and-order matching is W4 polish (validate.sh §1.3 currently counts `##` headings without exact-title matching, per `validate.sh` lines 89-97 "exact-heading matching not implemented at v0; W4 polish adds title + order check").
    46	
    47	| # | Section | What it contains | Source(s) |
    48	|---|---|---|---|
    49	| 1 | **Firm signal** | Companies House data: registered name, company number, incorporation date, latest filed accounts (revenue band + headcount band), registered office, recent director changes, share-class moves | Companies House API |
    50	| 2 | **Online footprint** | Primary website URL + last-updated signal; LinkedIn company page URL + follower count + last-post recency; careers page URL + state (active / placeholder / 404) | Web scraper (HEAD + first 200 lines); LinkedIn company-page fetch |
    51	| 3 | **Sector + role-type mix** | Sectors actively recruiting for (extracted from current job posts); ratio of permanent vs contract roles in last 90 days; technical-vs-commercial-vs-operational split | LinkedIn job posts + careers page job listings |
    52	| 4 | **Geography** | Office locations + current hiring locations + remote-vs-onsite-vs-hybrid mix | LinkedIn job posts (location field) + Companies House registered office |
    53	| 5 | **Deal-size band proxy** | Salary bands or day-rate ranges visible in job posts; level distribution (junior / mid / senior / executive); recent placements visible via LinkedIn employees-of-firm field changes | LinkedIn job posts + LinkedIn employee timeline scan |
    54	| 6 | **ICP fit vs target_patch** | Score 0-100 against tenant's `target_patch.json` (sectors / geographies / size_bands / deal_size_band_gbp from `common-target-patch.json`). Includes named matches/mismatches per dimension | Tenant config + sections 1-5 above |
    55	| 7 | **Tech stack signals** | Technologies named in JDs + LinkedIn skills aggregated from current employees + tools mentioned in director posts | LinkedIn JDs + LinkedIn employee profiles |
    56	| 8 | **Pain signals** | Phrases on careers page suggesting urgency ("rapid growth", "we're scaling fast", "looking to triple the team"); LinkedIn director posts mentioning hiring pressure or "we need help"; Glassdoor reviews mentioning workload/burnout (if accessible) | Careers page scrape + LinkedIn director post search + optional Glassdoor scrape |
    57	| 9 | **Competitor positioning** | Other recruitment firms visible in the candidate flow: LinkedIn employee profiles showing previous-employer agency names; @firm tags in LinkedIn recruitment-agency posts; LinkedIn "Who's hiring this firm" inference where visible | LinkedIn profile scrapes + agency-tag search |
    58	| 10 | **Recent activity** | LinkedIn company posts in last 90 days (count + summary); press releases or news mentions (basic Google search); funding events visible on Companies House (share allotments, new director appointments) | LinkedIn company page + Google web search + Companies House filing history |
    59	| 11 | **Decision-maker map** | Named people likely to be buyers: head of talent / chief people officer / hiring manager equivalents. LinkedIn profile URL per person. Tenure at firm. Recent activity. | LinkedIn employee search filtered by title |
    60	| 12 | **Conversation opener** | 2-3 sentence cold outreach pitch. Tailored to surfaced pain signals (§8). Written in consultant's voice (voice-classified). Includes specific evidence anchor (e.g., "I noticed you've doubled engineering headcount in 6 months based on your LinkedIn — congrats on the Series A. Curious how you're handling sourcing pressure at that pace.") | LLM-generated; voice-classified against tenant style guide |
    61	
    62	**Gate A hard-fails** (per ADR-006 + §5 spec):
    63	
    64	- Fewer than 12 sections present
    65	- Any section with zero citation links (per-section citation subcheck; ADR-006-canonical)
    66	- Section 12 (conversation opener) failing voice-classifier with score < 0.75 *(v0 hard-fail when voice-classifier URL reachable; warn + exit 0 when URL unreachable per §5 honesty note; W4 polish closes to unconditional hard-fail with explicit `validate_check_skipped` audit row)*
    67	- Output exceeds 2000 words OR is under 400 words (length-discipline boundary)
    68	- PII (email-domain mismatch) detected outside firm boundary *(v0 hard-fail when firm-domain whitelist available; warn + exit 0 when whitelist absent per §5 honesty note; W4 polish closes to unconditional hard-fail. v0 PII regex covers emails only; phone-number PII detection deferred to W4 polish.)*
    69	
    70	**Per-step audit-row signatures** (per `decision_log`):
    71	- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
    72	- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
    73	- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
    74	
    75	---
    76	
    77	## §4 — Workflow
    78	
    79	Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. The v0 cycle.sh implementation uses a generator-level pattern: a single call to `@ifos/diagnostic-generator` (`packages/diagnostic-generator/`) fetches all 12 sections in one process; cycle.sh emits decision-log rows at draft-write + report-write + render-action boundaries, not per-section. Per-section data acquisition is internal to the generator package and not separately audited at v0; W4 polish may add per-section telemetry.
    80	
    81	```
    82	0. Session start — invocation arrives via CLI ifosctl diagnostic
    83	   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
    84	   → hh_decision_trigger("session_start", firm_name + sector_hint)
    85	
    86	1. Validate input (cycle.sh Step 1)
    87	   → cycle.sh checks: firm name length ≥ 2 chars
    88	   → on fail: hh_decision_action("diagnostic_input_invalid", ...) with
    89	     payload {escalation_code: ESC_INPUT_VALIDATION_FAIL, ...}
    90	   → exit 1 on validation failure
    91	
    92	2-11. Generator run (cycle.sh Steps 2-11 — single generator call)
    93	   → bash invokes @ifos/diagnostic-generator with firm + sector + target_patch flags
    94	   → generator fetches all 12 sections internally:
    95	     - §1 Companies House lookup (cached 7d per gotcha §6.2)
    96	     - §2 Online footprint via web-scraper + LinkedIn URL discovery
    97	     - §3-§5-§7 Job posts harvest + tech stack extraction
    98	     - §6 ICP fit scoring against tenant target_patch
    99	     - §7-§11 Director + employee scan
   100	     - §8 Pain signal extraction
   101	     - §10 Recent activity scan
   102	     - §12 Conversation opener (LLM-generated, voice-classified)
   103	   → generator writes complete draft Markdown to /tmp/diagnostic-<firm-slug>-<ISO-date>.draft.md
   104	   → on empty stdout: hh_decision_action("diagnostic_generator_empty", ...) with
   105	     payload {escalation_code: ESC_AGENT_OUTPUT_SHAPE, ...}; exit 1
   106	   → ESC_RATE_LIMIT_HIT raised internally by web-scraper / companies-house on 429
   107	   → ESC_VOICE_DRIFT raised internally by §12 LLM step if classifier <0.75 after 3 retries
   108	   → hh_decision_output("diagnostic_draft", "<draft_path>", "<firm> 12-section draft (pre-validate)")
   109	
   110	12. Validate (Gate A) (cycle.sh Step 12)
   111	   → bash invokes validate.sh against the draft path
   112	   → per-section citation hard-fail (ADR-006 Tier 1; no warn-only path)
   113	   → voice classifier + PII subchecks per §5 honesty note (warn-only on
   114	     upstream-unavailable in v0; W4 closes to hard-fail)
   115	   → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
   116	     with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE or
   117	     ESC_PII_LEAKAGE_RISK) and exit 1
   118	   → cycle.sh deletes draft on Gate A fail
   119	
   120	13. Atomic vault write + report-render audit row (cycle.sh Step 13)
   121	   → atomic mv -f /tmp/<draft> → /vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md
   122	   → chmod 600 on the report
   123	   → hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")
   124	   → hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)
   125	     — tier: green per autosend-policy.yaml (no external send; vault write only)
   126	
   127	14. Operator notification (optional, per --notify-via telegram flag) (cycle.sh Step 14)
   128	   → if telegram: send via curl to api.telegram.org with report path + 200-char summary
   129	     → hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)
   130	     → tier: green (operator-only Telegram; no customer-facing comms)
   131	   → if no flag: silent completion (consultant checks vault); no decision-log row
   132	   → cleanup.sh runs (drops transient LinkedIn cache per ToS gotcha §6.1)
   133	   → exit 0
   134	```
   135	
   136	---
   137	
   138	## §5 — Gates
   139	
   140	### Gate A — validate.sh (hard-fail before action)
   141	
   142	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
   143	
   144	**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
   145	
   146	**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
   147	
   148	- All 12 sections present in the assembled report (count + heading check) — **v0: hard-fails as specified**
   149	- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section) — **v0: hard-fails as specified**
   150	- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
   151	- Report length 400-2000 words — **v0: hard-fails as specified**
   152	- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
   153	- No PII (emails) outside the firm boundary. **v0 behavior:** validate.sh runs a generic email-regex pass and warns on any email found (no firm-domain whitelist implemented in v0; warn-only; exit 0). W4 polish adds the firm-domain whitelist + hard-fail behavior + `ESC_PII_LEAKAGE_RISK` emission. **v0 PII coverage:** emails only via regex; phone-number PII detection + whitelist enforcement deferred to W4 polish.
   154	
   155	### Gate B — Outcome threshold (success metric, not block)
   156	
   157	Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
   158	
   159	Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
   160	
   161	---
   162	
   163	## §6 — Escalation codes
   164	
   165	Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:
   166	
   167	| Code | Trigger | Severity | Routing |
   168	|---|---|---|---|
   169	| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
   170	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
   171	| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
   172	| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
   173	| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |
   174	
   175	Diagnostic does NOT use:
   176	
   177	- `ESC_RENDERER_FAILED` — that code is owned by the `_renderer` sentinel (agent_name='_renderer') per catalogue §2.4; Diagnostic never fires it
   178	- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
   179	- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
   180	- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
   181	
   182	---
   183	
   184	## §7 — Voice + tone constraints
   185	
   186	Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   187	
   188	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
   189	  - No "I hope this finds you well" or other generic openers
   190	  - No salary or commission anchors in cold outreach
   191	  - Specific evidence anchor required (not generic "great company")
   192	- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
   193	- **`hh_load_recent_edits` last 30 days for `diagnostic`** (single agent_name arg per `voice-loader.sh::hh_load_recent_edits`; current `context.sh` passes `"diagnostic"` only): surfaces patterns of how consultant edits Diagnostic drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
   194	
   195	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   196	
   197	---
   198	
   199	## §8 — Production-readiness dependencies
   200	
   201	Full bundle (all 6 files + 3 fixtures) is built as of Day 19. Production readiness — i.e. running against a real pilot tenant — additionally requires the items below resolved to ✅.
   202	
   203	| Dependency | Source | Status |
   204	|---|---|---|
   205	| Renderer + `_shared/` substrate | Day-8 + Round-3 commits | ✅ Ratified (Round 3) |
   206	| Live VPS migration applied | `bash scripts/run-live-migration.sh` | ✅ Applied Day 12 |
   207	| Tenancy audit passes 12 invariants | `bash scripts/run-tenancy-audit.sh` | ✅ 24/24 invariants verified Day 12 |
   208	| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
   209	| `target_patch.json` for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI (per tenant-lifecycle.md §2) |
   210	| Voice corpus seeded for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI |
   211	| Companies House MCP connector | `packages/mcp-connectors/companies-house/` | ✅ Shipped Day 13; 13/13 tests passing |
   212	| LinkedIn read-only via web-scraper | `packages/utilities/web-scraper/` | ✅ Shipped Day 13; 12/12 tests passing (Proxycurl deferred to W4) |
   213	| Web scraper utility (HEAD + first-N-lines) | `packages/utilities/web-scraper/` | ✅ Shipped Day 13 |
   214	| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
   215	| `context.sh` hydration | `agents/recruitment/diagnostic/context.sh` | ✅ Built |
   216	| 3 fixtures with golden outputs | `agents/recruitment/diagnostic/fixtures/` | ✅ Built (01-primary + 02-edge-case + 99-voice-drift-canary) |
   217	| Other bundle files (cycle.sh, tools.yaml, cleanup.sh) | `agents/recruitment/diagnostic/` | ✅ All built |
   218	| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ 10 rounds attempted; ADR-006 (Accepted) closed Cat-1 Gate A finding; residual mechanical findings tracked in disagreement doc Phase 4-5 |
   219	
   220	**Production-readiness gates:** all ⏸ items above must resolve to ✅ before first production render against a pilot tenant. Bundle code itself is complete.
   221	
   222	---
   223	
   224	## §9 — Status + open questions
   225	
   226	**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + Codex RATIFIED verdict + first production render.
   227	
   228	**Build state:** full bundle (cycle.sh, validate.sh, context.sh, tools.yaml, cleanup.sh, 3 fixtures) shipped Day 13-19. Codex review-agent-bundle ratification in progress (10+ rounds; ADR-006 closed the Cat-1/Cat-ζ Gate A finding; iterating on smaller mechanical findings).
   229	
   230	### Open questions for founder review
   231	
   232	| # | Question | Resolution path |
   233	|---|---|---|
   234	| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
   235	| Q2 | Should §11 (decision-maker map) be a separate section OR rolled into §3 + §4 + §5 + §7 as a sub-row? Currently named as a separate section. | Founder review at agent.md ratification. |
   236	| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | Resolved at W3 start before Companies House + LinkedIn MCP connectors authored. Founder + Claude decide together. |
   237	| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
   238	| Q5 | What's the "firm-slug" canonical form for the output filename? Companies House registration number? URL-slugified firm name? | Recommend Companies House number for stability; canonical-slug fallback for non-UK firms (v1.1+). |
   239	| Q6 | Should §10 (recent activity) include Glassdoor reviews? ToS implications. | Per gotcha §6 below: caution; default OFF for v1.0; explicit founder enable for v1.1+. |
   240	
   241	### Gotchas (carried forward from Ultraplan §8.1 A1)
   242	
   243	1. **LinkedIn ToS — cannot store profile data beyond the audit.** Profile fetches are cached only for the duration of the report generation (typ. 10-15 min). After report writes to vault, raw profile data is dropped from agent memory + no persistence in Postgres.
   244	2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
   245	3. **Glassdoor scraping — uncertain ToS compatibility.** Default OFF for v1.0. Per Q6 above.
   246	
   247	---
   248	
   249	## §10 — When this document ratifies
   250	
   251	Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
   252	
   253	Status flips to Accepted when:
   254	- Codex Round-3+ ratifies the full bundle
   255	- Founder approves §3's 12-section list as canonical
   256	- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   257	- Gate B baseline measurement begins (30% target; 4-week window)
   258	
   259	Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.
   260	

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/cycle.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	#
     3	# Diagnostic agent — cycle.sh (workflow orchestration)
     4	#
     5	# Status: Proposed (Day-19; v0 implementation using @ifos/diagnostic-generator + web-scraper + companies-house MCP connectors all wired).
     6	# Reading order: agent.md §1 (output contract) + §4 (10-step workflow) first.
     7	#
     8	# This is the main orchestration loop. Sources context.sh, runs the 10
     9	# workflow steps from agent.md §4, calls validate.sh for Gate A, writes
    10	# the report to vault, optionally notifies operator.
    11	#
    12	# Per ADR-003 + sequencing-target.md §2.1: Diagnostic is Tier 2 (request-
    13	# driven, no persistent PTY). Each invocation is one report, one firm.
    14	#
    15	# Invocation contract:
    16	#   bash cycle.sh --firm "<firm name>" [--sector <hint>] [--notify-via telegram]
    17	#
    18	# Outputs:
    19	#   - One Markdown file in /vault/<tenant_slug>/diagnostic-reports/<firm-slug>-<ISO-date>.md
    20	#   - Audit rows to decision_log (trigger + output + action)
    21	#   - Optional Telegram notification with executive summary
    22	#
    23	# Exit codes:
    24	#   0  Report generated + validated + vault-written
    25	#   1  Workflow failure (specific step failed; ESC_* row emitted)
    26	#   2  Invocation error (bad args)
    27	#   3  Gate A validation failed
    28	#
    29	# Build state: v0 PRODUCTION. MCP connectors wired Day 13: @ifos/companies-house
    30	# (HTTP Basic auth, 7-day cache); @ifos/web-scraper (HEAD + first-N-lines fetch,
    31	# robots.txt aware, rate-limit aware) for online footprint + LinkedIn page-fetch.
    32	# Proxycurl deep-data integration deferred to W4 polish per ADR-005.
    33	# This script:
    34	#   - Implements the 14-step cycle (per agent.md §4) via a single
    35	#     @ifos/diagnostic-generator package call that composes all 12 sections
    36	#   - Emits audit rows at draft + report + render boundaries (not per-section;
    37	#     per-section telemetry is W4 polish optional per §4)
    38	#   - Uses validate.sh for Gate A enforcement (per-section citation hard-fail
    39	#     per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per
    40	#     §5 honesty note; W4 polish closes those to hard-fail)
    41	
    42	set -uo pipefail
    43	
    44	# ────────────────────────────────────────────────────────────────────────
    45	# Arguments
    46	# ────────────────────────────────────────────────────────────────────────
    47	
    48	FIRM_NAME=""
    49	SECTOR_HINT=""
    50	NOTIFY_VIA=""
    51	
    52	while [[ $# -gt 0 ]]; do
    53	  case "$1" in
    54	    --firm) FIRM_NAME="$2"; shift 2 ;;
    55	    --sector) SECTOR_HINT="$2"; shift 2 ;;
    56	    --notify-via) NOTIFY_VIA="$2"; shift 2 ;;  # used below in Step 14
    57	    *) printf 'cycle.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
    58	  esac
    59	done
    60	
    61	if [[ -z "${FIRM_NAME}" ]]; then
    62	  printf 'cycle.sh: --firm <name> required\n' >&2
    63	  exit 2
    64	fi
    65	
    66	export IFOS_DIAGNOSTIC_FIRM_NAME="${FIRM_NAME}"
    67	
    68	# ────────────────────────────────────────────────────────────────────────
    69	# Step 0 — Context hydration
    70	# ────────────────────────────────────────────────────────────────────────
    71	
    72	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    73	  printf 'cycle.sh: CTX_AGENT_DIR unset (agent not rendered)\n' >&2
    74	  exit 1
    75	fi
    76	
    77	# shellcheck source=/dev/null
    78	source "${CTX_AGENT_DIR}/context.sh"
    79	
    80	# Sanity
    81	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    82	  printf 'cycle.sh: CTX_TENANT_SLUG unset after context.sh\n' >&2
    83	  exit 1
    84	fi
    85	
    86	# ────────────────────────────────────────────────────────────────────────
    87	# Compute firm-slug for filename + draft path
    88	# ────────────────────────────────────────────────────────────────────────
    89	
    90	FIRM_SLUG=$(printf '%s' "${FIRM_NAME}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9- ' | tr ' ' '-' | sed 's/--*/-/g; s/^-//; s/-$//')
    91	ISO_DATE=$(date -u +"%Y-%m-%d")
    92	VAULT_ROOT="${IFOS_VAULT_ROOT:-/vault}"
    93	REPORT_DIR="${VAULT_ROOT}/${CTX_TENANT_SLUG}/diagnostic-reports"
    94	REPORT_PATH="${REPORT_DIR}/${FIRM_SLUG}-${ISO_DATE}.md"
    95	DRAFT_PATH="/tmp/diagnostic-draft-${FIRM_SLUG}-$$.md"
    96	
    97	mkdir -p "${REPORT_DIR}" 2>/dev/null || {
    98	  printf 'cycle.sh: cannot create %s\n' "${REPORT_DIR}" >&2
    99	  exit 1
   100	}
   101	
   102	# ────────────────────────────────────────────────────────────────────────
   103	# Step 1 — Validate input + sector
   104	# ────────────────────────────────────────────────────────────────────────
   105	
   106	if [[ ${#FIRM_SLUG} -lt 2 ]]; then
   107	  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
   108	    "$(printf '%s' "${FIRM_NAME}" | shasum | awk '{print $1}')" \
   109	    '{"escalation_code":"ESC_INPUT_VALIDATION_FAIL","input_field":"firm","input_value_preview":"<malformed>","validation_rule_violated":"min_length_2"}' >/dev/null
   110	  exit 1
   111	fi
   112	
   113	# ────────────────────────────────────────────────────────────────────────
   114	# Step 2-11 — Generate the 12 sections via @ifos/diagnostic-generator
   115	# ────────────────────────────────────────────────────────────────────────
   116	#
   117	# v0 build (Day 13): web-scraper + companies-house wired; LinkedIn deep
   118	# data deferred to W4 (Proxycurl). Voice classifier gate skipped at v0.
   119	# CLI: packages/diagnostic-generator/dist/cli.js
   120	
   121	GENERATOR_CLI="${IFOS_REPO_ROOT:-${REPO_ROOT}}/packages/diagnostic-generator/dist/cli.js"
   122	if [[ ! -f "${GENERATOR_CLI}" ]]; then
   123	  printf 'cycle.sh: generator CLI not built at %s\n' "${GENERATOR_CLI}" >&2
   124	  printf '  Run: cd packages/diagnostic-generator && pnpm build\n' >&2
   125	  exit 1
   126	fi
   127	
   128	# target_patch.json — optional; if missing, §6 ICP fit degrades to "no patch"
   129	TARGET_PATCH_PATH="${VAULT_ROOT}/${CTX_TENANT_SLUG}/target_patch.json"
   130	TARGET_PATCH_FLAG=""
   131	if [[ -f "${TARGET_PATCH_PATH}" ]]; then
   132	  TARGET_PATCH_FLAG="--target-patch ${TARGET_PATCH_PATH}"
   133	fi
   134	
   135	# Load Companies House API key from tenant secrets if present
   136	if [[ -f "${VAULT_ROOT}/${CTX_TENANT_SLUG}/_secrets.env" && -z "${COMPANIES_HOUSE_API_KEY:-}" ]]; then
   137	  set -a
   138	  # shellcheck source=/dev/null
   139	  source "${VAULT_ROOT}/${CTX_TENANT_SLUG}/_secrets.env"
   140	  set +a
   141	fi
   142	
   143	if [[ -z "${COMPANIES_HOUSE_API_KEY:-}" ]]; then
   144	  printf 'cycle.sh: COMPANIES_HOUSE_API_KEY not set\n' >&2
   145	  printf '  Founder action: register at https://developer.company-information.service.gov.uk/ and save key to %s/_secrets.env\n' \
   146	    "${VAULT_ROOT}/${CTX_TENANT_SLUG}" >&2
   147	  exit 1
   148	fi
   149	
   150	# shellcheck disable=SC2086
   151	node "${GENERATOR_CLI}" \
   152	  --firm "${FIRM_NAME}" \
   153	  --tenant "${CTX_TENANT_SLUG}" \
   154	  --sector "${SECTOR_HINT}" \
   155	  ${TARGET_PATCH_FLAG} \
   156	  --iso-date "${ISO_DATE}" \
   157	  > "${DRAFT_PATH}"
   158	
   159	if [[ ! -s "${DRAFT_PATH}" ]]; then
   160	  printf 'cycle.sh: generator produced empty output\n' >&2
   161	  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
   162	    "$(date +%s)" \
   163	    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
   164	  exit 1
   165	fi
   166	
   167	# ────────────────────────────────────────────────────────────────────────
   168	# Step 12 — Validate (Gate A)
   169	# ────────────────────────────────────────────────────────────────────────
   170	
   171	hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
   172	  "${FIRM_NAME} 12-section draft (pre-validate)" >/dev/null
   173	
   174	if ! bash "${CTX_AGENT_DIR}/validate.sh" "${DRAFT_PATH}"; then
   175	  printf 'cycle.sh: Gate A failed; draft NOT moved to vault\n' >&2
   176	  rm -f "${DRAFT_PATH}"
   177	  exit 3
   178	fi
   179	
   180	# ────────────────────────────────────────────────────────────────────────
   181	# Step 13 — Atomic vault write (per ADR-003 §3.3.4 atomic-write protocol)
   182	# ────────────────────────────────────────────────────────────────────────
   183	
   184	mv -f "${DRAFT_PATH}" "${REPORT_PATH}"
   185	chmod 600 "${REPORT_PATH}"
   186	
   187	# Final report output row per agent.md §3 audit-row signature
   188	hh_decision_output "diagnostic_report" "${REPORT_PATH}" \
   189	  "12-section report on ${FIRM_NAME}" >/dev/null
   190	
   191	hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
   192	  "$(shasum "${REPORT_PATH}" | awk '{print $1}')" \
   193	  "$(printf '{"vault_path":"%s","firm_name":"%s","tenant":"%s"}' \
   194	      "${REPORT_PATH}" "${FIRM_NAME}" "${CTX_TENANT_SLUG}")" >/dev/null
   195	
   196	printf '\n\033[1;32mDiagnostic report written:\033[0m %s\n' "${REPORT_PATH}"
   197	
   198	# ────────────────────────────────────────────────────────────────────────
   199	# Step 14 — Optional notify
   200	# ────────────────────────────────────────────────────────────────────────
   201	
   202	if [[ "${NOTIFY_VIA}" == "telegram" ]]; then
   203	  if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_OPERATOR_CHAT_ID:-}" ]]; then
   204	    SUMMARY=$(head -200 "${REPORT_PATH}" | sed 's/[^[:print:][:space:]]//g' | head -c 200)
   205	
   206	    # Emit decision_log row BEFORE the send per agent.md §4 Step 11 spec —
   207	    # operator_notify_telegram is green-tier per autosend-policy.yaml so the
   208	    # send executes regardless; this row records the action for audit.
   209	    NOTIFY_PAYLOAD=$(printf '{"recipient":"operator","chat_id":"%s","report_path":"%s","firm":"%s","summary_len":%d}' \
   210	      "${TELEGRAM_OPERATOR_CHAT_ID}" \
   211	      "${REPORT_PATH}" \
   212	      "${FIRM_NAME}" \
   213	      "${#SUMMARY}")
   214	    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
   215	      "$(echo "${NOTIFY_PAYLOAD}" | shasum | awk '{print $1}')" \
   216	      "${NOTIFY_PAYLOAD}" 2>/dev/null || true
   217	
   218	    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
   219	      -d "chat_id=${TELEGRAM_OPERATOR_CHAT_ID}" \
   220	      -d "text=Diagnostic report ready: ${FIRM_NAME} → ${REPORT_PATH}%0A%0A${SUMMARY}..." \
   221	      >/dev/null 2>&1 || \
   222	      printf 'cycle.sh: telegram notify failed (non-fatal)\n' >&2
   223	  else
   224	    printf 'cycle.sh: --notify-via telegram set but credentials missing; skipped\n' >&2
   225	  fi
   226	fi
   227	
   228	# Call cleanup (drop transient LinkedIn cache per ToS gotcha §6.1)
   229	bash "${CTX_AGENT_DIR}/cleanup.sh" 2>/dev/null || true
   230	
   231	exit 0

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '260,520p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	
   261	*End of Diagnostic agent.md draft.*

exec
/bin/zsh -lc "rg -n \"hh_decision_|autosend_policy_lookup|phase|decision_log\" agents/_shared/hook-helpers.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
10:# Live-mode writes:        Postgres decision_log via psql + IFOS_DB_URL
19:# Side-effects: appends to decision_log table OR fallback JSONL; never reads
100:# _hh_emit_row <phase> <outcome> <reason> <payload_json>
102:# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
106:  local phase="$1"
121:INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
125:  '$(_hh_sql_escape "${phase}")',
149:  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
152:    "$(_hh_json_escape "${phase}")" \
163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
166:# hh_decision_trigger <trigger_type> [<reason>]
167:# Writes phase='trigger' row at session start. Required first call of every run.
168:hh_decision_trigger() {
177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
178:# Writes phase='output' row per artefact produced. Required before producing
180:hh_decision_output() {
190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
191:# Writes phase='action' or phase='gating_failed' row depending on tier.
193:hh_decision_action() {
202:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
203:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
211:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
220:      autosend_emit_decision_log "action" "green" "${action_type}" \
225:      autosend_emit_decision_log "action" "yellow" "${action_type}" \
234:      autosend_emit_decision_log "action" "orange" "${action_type}" \
242:      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
249:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
262:# autosend_policy_lookup <action_type>
265:autosend_policy_lookup() {
268:    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
329:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
330:# Emits the standard autosend decision_log row with payload.tier set.
331:autosend_emit_decision_log() {
332:  local phase="$1"
350:  _hh_emit_row "${phase}" "${tier}" "${reason_or_status}" "${payload}"
355:# lookup is permissive — unknown codes are emitted with phase='gating_failed'

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '1,140p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/context.sh | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '220,360p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   220	fi
   221	
   222	# ────────────────────────────────────────────────────────────────────────
   223	# Verdict + escalation emission
   224	# ────────────────────────────────────────────────────────────────────────
   225	
   226	if (( ${#FAILURES[@]} == 0 )); then
   227	  printf '\nValidate Gate A: \033[1;32mPASS\033[0m (warnings=%d)\n' "${#WARNINGS[@]}"
   228	  exit 0
   229	else
   230	  printf '\nValidate Gate A: \033[1;31mFAIL\033[0m (%d failures, %d warnings)\n' \
   231	    "${#FAILURES[@]}" "${#WARNINGS[@]}"
   232	
   233	  # Emit the specific ESC code per agent.md §6 mapping:
   234	  #   - PII detected outside firm boundary → ESC_PII_LEAKAGE_RISK (blocking)
   235	  #   - Output-shape violation (section count, per-section citation,
   236	  #     length, voice-classifier miss) → ESC_AGENT_OUTPUT_SHAPE (warn)
   237	  # ESC_SCHEMA_VIOLATION is reserved for vertical-schema field-constraint
   238	  # violations at write time per catalogue line 163 — not for Diagnostic's
   239	  # output-shape failures.
   240	  PII_FAILURE_PRESENT=0
   241	  for failure in "${FAILURES[@]}"; do
   242	    if [[ "${failure}" == *"PII"* || "${failure}" == *"pii"* ]]; then
   243	      PII_FAILURE_PRESENT=1
   244	      break
   245	    fi
   246	  done
   247	
   248	  if (( PII_FAILURE_PRESENT == 1 )); then
   249	    ESC_CODE="ESC_PII_LEAKAGE_RISK"
   250	  else
   251	    ESC_CODE="ESC_AGENT_OUTPUT_SHAPE"
   252	  fi
   253	
   254	  ESC_PAYLOAD=$(printf '{"escalation_code":"%s","draft_path":"%s","failures":%s}' \
   255	    "${ESC_CODE}" \
   256	    "${DRAFT}" \
   257	    "$(printf '%s\n' "${FAILURES[@]}" | python3 -c "import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))" 2>/dev/null || echo '[]')")
   258	
   259	  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
   260	    "$(echo "${ESC_PAYLOAD}" | shasum | awk '{print $1}')" \
   261	    "${ESC_PAYLOAD}" 2>/dev/null || true
   262	
   263	  exit 1
   264	fi

 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# shellcheck disable=SC2034
     3	#
     4	# Diagnostic agent — context.sh
     5	#
     6	# Status: Proposed (Day-19; voice + tone + recent_edits + target_patch hydration via voice-loader.sh + tone-loader + Postgres).
     7	# Reading order: agent.md §4 Step 0 (session start) + §7 (voice + tone) first.
     8	#
     9	# Purpose: hydrate the agent's session with tenant-scoped context BEFORE
    10	# the first workflow step runs. Per master brief §8.1 Change 1: load voice
    11	# corpus + tone rules + recent edits + target_patch from the tenant's
    12	# Postgres + vault. Per ADR-003: context.sh is the second of six bundle
    13	# files (after agent.md, before validate.sh).
    14	#
    15	# Invocation contract:
    16	#   - Sourced by cycle.sh at session start (not exec'd as subprocess)
    17	#   - Populates these env vars for downstream steps:
    18	#       CTX_TENANT_SLUG       (already set by ifosctl invocation)
    19	#       CTX_AGENT_NAME=diagnostic
    20	#       CTX_TARGET_PATCH      JSON path or inline (per common-target-patch.json)
    21	#       CTX_VOICE_CORPUS_ID   active corpus id from voice_corpus table
    22	#       CTX_TONE_RULES        JSON array of applicable rules
    23	#       CTX_RECENT_EDITS_REF  count of recent_edit rows (drift signal)
    24	#   - Sources _shared/hook-helpers.sh + _shared/voice-loader.sh
    25	#   - Emits hh_decision_trigger("session_start", ...) as first audit row
    26	#
    27	# Failure modes:
    28	#   - Missing tenant_slug → exit 1 with ESC_SCHEMA_VIOLATION
    29	#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
    30	#     production tenants; only migration-test allows empty corpus)
    31	#   - target_patch unreachable → exit 1 with ESC_SCHEMA_VIOLATION
    32	
    33	set -uo pipefail
    34	
    35	CTX_AGENT_NAME="diagnostic"
    36	export CTX_AGENT_NAME
    37	
    38	# ────────────────────────────────────────────────────────────────────────
    39	# 0 — Source shared helpers
    40	# ────────────────────────────────────────────────────────────────────────
    41	
    42	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    43	  echo "context.sh: CTX_AGENT_DIR unset; agent not rendered correctly" >&2
    44	  exit 1
    45	fi
    46	
    47	# Resolve _shared/ helpers: rendered agent has them at
    48	# ${CTX_AGENT_DIR}/.claude/hooks/_shared/ (symlink per ADR-003). For
    49	# direct source-tree execution (Day-13 smoke tests), fall back to repo
    50	# root via IFOS_REPO_ROOT or computed relative path.
    51	_SHARED_DIR=""
    52	for _candidate in \
    53	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    54	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    55	  "${CTX_AGENT_DIR}/../../_shared" \
    56	  "${CTX_AGENT_DIR}/../_shared" ; do
    57	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    58	    _SHARED_DIR="${_candidate}"
    59	    break
    60	  fi
    61	done
    62	
    63	if [[ -z "${_SHARED_DIR}" ]]; then
    64	  echo "context.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT or render the agent first" >&2
    65	  exit 1
    66	fi
    67	
    68	# shellcheck source=/dev/null
    69	source "${_SHARED_DIR}/hook-helpers.sh"
    70	# shellcheck source=/dev/null
    71	source "${_SHARED_DIR}/voice-loader.sh"
    72	
    73	# ────────────────────────────────────────────────────────────────────────
    74	# 1 — Validate tenant context
    75	# ────────────────────────────────────────────────────────────────────────
    76	
    77	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    78	  printf 'context.sh: CTX_TENANT_SLUG unset\n' >&2
    79	  exit 1
    80	fi
    81	
    82	# Emit session-start audit row
    83	hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
    84	  || {
    85	    printf 'context.sh: hh_decision_trigger failed; vault may be unwritable\n' >&2
    86	    exit 1
    87	  }
    88	
    89	# ────────────────────────────────────────────────────────────────────────
    90	# 2 — Load target_patch (tenant's commercial sweet spot)
    91	# ────────────────────────────────────────────────────────────────────────
    92	#
    93	# target_patch defines sectors / geographies / size_bands / deal_size_band
    94	# per common-target-patch.json schema. Loaded from tenant's _config.yaml or
    95	# inline via env. Used in §4 Step 7 (ICP fit scoring).
    96	
    97	# target_patch resolution order:
    98	#   1. CTX_AGENT_DIR/target_patch.json (rendered agent path)
    99	#   2. ${VAULT_ROOT}/${CTX_TENANT_SLUG}/target_patch.json (per-tenant vault)
   100	#   3. Permissive default (empty patch — ICP fit degrades to "not computable")
   101	TARGET_PATCH_FILE=""
   102	for _candidate in \
   103	  "${CTX_AGENT_DIR}/target_patch.json" \
   104	  "${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/target_patch.json" ; do
   105	  if [[ -f "${_candidate}" ]]; then
   106	    TARGET_PATCH_FILE="${_candidate}"
   107	    break
   108	  fi
   109	done
   110	
   111	if [[ -n "${TARGET_PATCH_FILE}" ]]; then
   112	  CTX_TARGET_PATCH=$(<"${TARGET_PATCH_FILE}")
   113	else
   114	  # shellcheck disable=SC2089,SC2090
   115	  CTX_TARGET_PATCH='{"sectors":[],"size_bands":[],"geographies":[]}'
   116	  printf 'context.sh: no target_patch.json found; ICP fit will degrade to "not computable"\n' >&2
   117	fi
   118	# shellcheck disable=SC2090
   119	export CTX_TARGET_PATCH
   120	
   121	# ────────────────────────────────────────────────────────────────────────
   122	# 3 — Load voice corpus active row
   123	# ────────────────────────────────────────────────────────────────────────
   124	#
   125	# Used in §4 Step 9 (conversation opener voice classification). The voice
   126	# corpus is per-tenant; ANN query happens later in cycle.sh Step 9 against
   127	# the active corpus.
   128	
   129	VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
   130	CTX_VOICE_CORPUS_ID=$(printf '%s' "${VOICE_CORPUS_JSON}" | python3 -c "
   131	import sys, json
   132	d = json.load(sys.stdin) if sys.stdin.read().strip() else {}
   133	print(d.get('corpus_id', ''))
   134	" 2>/dev/null || echo "")
   135	export CTX_VOICE_CORPUS_ID
   136	
   137	if [[ -z "${CTX_VOICE_CORPUS_ID}" && "${CTX_TENANT_SLUG}" != "migration-test" ]]; then
   138	  printf 'context.sh: No active voice corpus for tenant %s\n' "${CTX_TENANT_SLUG}" >&2
   139	  printf '  Production tenants require seeded corpus before agent run.\n' >&2
   140	  exit 1
   141	fi
   142	
   143	# ────────────────────────────────────────────────────────────────────────
   144	# 4 — Load tone rules (filtered to diagnostic agent)
   145	# ────────────────────────────────────────────────────────────────────────
   146	
   147	CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
   148	export CTX_TONE_RULES
   149	
   150	TONE_RULE_COUNT=$(printf '%s' "${CTX_TONE_RULES}" | python3 -c "
   151	import sys, json
   152	d = json.load(sys.stdin)
   153	print(len(d.get('rules', [])))
   154	" 2>/dev/null || echo "0")
   155	
   156	# ────────────────────────────────────────────────────────────────────────
   157	# 5 — Load recent_edits (voice drift signal)
   158	# ────────────────────────────────────────────────────────────────────────
   159	
   160	CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
   161	export CTX_RECENT_EDITS_REF
   162	
   163	EDIT_COUNT=$(printf '%s' "${CTX_RECENT_EDITS_REF}" | python3 -c "
   164	import sys, json
   165	d = json.load(sys.stdin)
   166	print(len(d.get('edits', [])))
   167	" 2>/dev/null || echo "0")
   168	
   169	# ────────────────────────────────────────────────────────────────────────
   170	# 6 — Summary (printed at context-load completion)
   171	# ────────────────────────────────────────────────────────────────────────
   172	
   173	printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
   174	  "${CTX_TENANT_SLUG}" "${CTX_VOICE_CORPUS_ID:-<empty>}" "${TONE_RULE_COUNT}" "${EDIT_COUNT}"
   175	
   176	# End of context.sh

 succeeded in 0ms:
     1	# v1.0 kill criterion
     2	
     3	**Status:** Proposed — pending Codex Day-7 ratification
     4	**Date:** 2026-05-18 (Week 0, Day 5)
     5	**Author:** Claude Code, with founder review pending
     6	**Master brief §:** §6 Day 5 (line 486) + §12 Risk Register + §1 Rule 5 (honest signal before optimistic projection)
     7	**Surfaced by:** Master brief Day 5 spec; folds carry-forwards from `sequencing-target.md` §6.6 + `bullhorn-integration-path.md` §4.1 + Day-4 §11 closing-commit work.
     8	**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
     9	
    10	---
    11	
    12	## §1 — Definitions
    13	
    14	Three distinct end-states for v1.0:
    15	
    16	### KILL
    17	
    18	**Cease v1.0 development.** The wedge is invalidated by structural evidence. Existing pilots receive 30-day wind-down notice; assets liquidated or open-sourced; refund obligations honoured per pilot agreement. Founder pivots to next initiative.
    19	
    20	**KILL is reversible only as v1.1 or v2.0**: a wholly new initiative under different premises, with its own kill criterion. v1.0 itself does not resurrect.
    21	
    22	### PAUSE
    23	
    24	**Freeze v1.0 development for N weeks while data is gathered.** Existing pilots continue in read-only mode (agents that have shipped stay operational; no new agents ship). Founder + Jack conduct strategic review and define an unfreeze criterion.
    25	
    26	**PAUSE has a defined exit:** either unfreeze (resume v1.0 from the slice that was active when paused) OR escalate to KILL/PIVOT if the strategic review concludes the trigger is structural rather than temporary.
    27	
    28	### PIVOT
    29	
    30	**Rescope v1.0.** The wedge holds but its assumed shape is wrong. Common pivots:
    31	
    32	- **Vertical pivot:** recruitment → accountancy, insurance, or another UK SME services domain
    33	- **ATS pivot:** Bullhorn-first → Vincere-first, Voyager Infinity-first, or vertical-without-ATS
    34	- **Deployment pivot:** SaaS → self-hosted, or vice-versa
    35	- **Customer pivot:** consultant-facing → operations-team-facing → owner-facing
    36	
    37	**v1.0 commitments to existing pilots are honoured under original scope.** New v1.0 contracts under rescoped terms. The master brief and Ultraplan are amended by atomic-correction commit; Codex ratifies before v1.0 resumption.
    38	
    39	---
    40	
    41	## §2 — Binary triggers
    42	
    43	Each trigger has: measurable threshold, owner (detects), action (kill/pause/pivot), source justification.
    44	
    45	### Trigger 1 — DESIGN-PARTNER-BY-WEEK-2 (PAUSE)
    46	
    47	**Threshold:** No design partner has confirmed pilot intent (signed LOI or equivalent written commitment to pilot in Q3 2026 per master brief §6 Day 7 question 1) by end of Week 2.
    48	
    49	**Calendar:** Day 0 was 2026-05-13 (Wednesday). Week 0 runs Days 0-7, ending Wednesday 2026-05-20. Week 1 starts Thursday 2026-05-21. Week 2 ends Wednesday 2026-06-03. **Trigger fires end-of-day 2026-06-03 if criterion unmet.**
    50	
    51	**Owner:** Founder; daily check during Weeks 1-2.
    52	
    53	**Source:** Risk #3 in `docs/RISK-REGISTER.md` (escalating status); Day-5 Risk #3 update reflects "zero design partners in pipeline" as of this commit; master brief §6 Day 7 question 1.
    54	
    55	**Action:** PAUSE state activated immediately. Agent code halts at end of current week's slice (rather than mid-slice). Founder pivots to full-time design-partner acquisition. Claude Code work limited to design-partner-supporting artefacts (sales decks, demo agents, pricing models).
    56	
    57	**Unfreeze criterion:** **One signed pilot LOI** from a UK recruitment agency with stated pilot start date in Q3 2026. Unfreeze formal: Founder + Jack joint sign-off on the LOI; resume v1.0 from the slice that was active when paused.
    58	
    59	**Escalation path if PAUSE extends:** if unfreeze not achieved within 4 weeks of PAUSE activation, strategic review reconvenes. Outcomes: (a) continue PAUSE if pipeline is materially active; (b) escalate to KILL if no pipeline activity; (c) escalate to PIVOT if pipeline rejection signals point to a different vertical/ATS.
    60	
    61	### Trigger 2 — DIAGNOSTIC-NO-RENDER-W3 (KILL)
    62	
    63	**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
    64	
    65	**Owner:** Claude Code (technical detection); founder review (decision authority). Weekly check during Weeks 1-3.
    66	
    67	**Source:** `sequencing-target.md` §6.6 failure condition (i); Risk #5 in `docs/RISK-REGISTER.md`; ADR-003 §"Consequences" line 141 (renderer is load-bearing Week-1 deliverable).
    68	
    69	**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
    70	
    71	**Recovery path:** None within v1.0. Lessons logged to `.agents/learnings/v1.0-postmortem.md`. v1.1 may begin as new initiative with reconsidered renderer architecture (or no per-tenant render, or different bundle pattern).
    72	
    73	### Trigger 3 — JANITOR-BULLHORN-AUTH-W5 (PIVOT)
    74	
    75	**Threshold:** Janitor agent cannot authenticate to Bullhorn via the documented OAuth flow (per `bullhorn-integration-path.md` §4.5 refresh-loop architecture) by end of Week 5 (2026-06-28). Authentication failure modes that trigger: (a) OAuth token endpoint returns non-2xx persistently; (b) refresh-loop architecture fails at 10-minute TTL boundary; (c) Bullhorn rate-limits IFOS's auth endpoint preventing pilot operations; (d) Bullhorn partnership programme requirement blocks production-tenant access.
    76	
    77	**Owner:** Founder + Claude Code. Weekly check during Weeks 3-5.
    78	
    79	**Source:** `sequencing-target.md` §6.6 failure condition (ii); Risk #2 in `docs/RISK-REGISTER.md`; `bullhorn-integration-path.md` Sub-decisions A + B (currently Proposed pending Sunday/Monday commercial conversations — which themselves have not happened due to design-partner-pipeline gap).
    80	
    81	**Action:** PIVOT state. Rescope from Bullhorn-first to alternate ATS-first:
    82	
    83	- **Option A:** Vincere-first. Mid-market UK recruitment ATS; smaller market than Bullhorn but more accessible API.
    84	- **Option B:** Voyager Infinity-first. UK-native ATS; smaller market; alternative auth model.
    85	- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
    86	
    87	Rescope plan attached to PIVOT decision; existing pilots receive 14-day notice with rescope explanation.
    88	
    89	**Recovery path:** PIVOT is structural; resumption is via rescoped v1.0 under new ATS assumption. Pivoted v1.0 continues with adjusted master brief / Ultraplan; atomic-correction commit lands the rescope.
    90	
    91	### Trigger 4 — TWO-SCOPE-CUT-ACTIVATIONS (PAUSE)
    92	
    93	**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
    94	
    95	**Owner:** Founder; logged in `.agents/decisions/` when activated.
    96	
    97	**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
    98	
    99	**Action:** PAUSE state. Rationale: two scope cuts indicates either (a) the v1.0 wedge is structurally too narrow to be valuable, or (b) build velocity is fundamentally below the rate v1.0 requires. Either way, continuing to ship more agents is the wrong move; strategic review needed.
   100	
   101	**Unfreeze criterion:** Strategic review by Founder + Jack within 2 weeks of PAUSE activation produces one of three outcomes:
   102	
   103	1. **Unfreeze with scope:** restored to 4 agents (no further cuts); resume with adjusted timeline.
   104	2. **Escalate to PIVOT:** rescope vertical or customer-type; pivoted v1.0 has new agent fleet definition.
   105	3. **Escalate to KILL:** the wedge as designed cannot ship even at reduced scope.
   106	
   107	### Trigger 5 — AUTOSEND-RED-MISCATEGORISATIONS (PAUSE)
   108	
   109	**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
   110	
   111	**Owner:** IFOS oncall + tenant operator. Daily check via `decision_log` queries: `SELECT COUNT(*) FROM decision_log WHERE phase='gating_failed' AND payload->>'tier'='red' AND payload->>'block_reason'='red_tier_classification' AND tenant_slug=? AND created_at > NOW() - INTERVAL '7 days'`.
   112	
   113	**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
   114	
   115	**Action:** PAUSE for the affected pilot. The agent that produced the miscategorisations halts at next session boundary. Founder + Jack review the policy tier classifications within 48 hours. Policy revision (via Codex ratification) lands as a new commit; affected pilot receives incident report. Pilot resumes after policy revision.
   116	
   117	**Escalation path:** If three pilots experience this trigger within one quarter, escalate to system-wide PAUSE while structural autosend policy redesign happens (potential v1.1 advancement of orange tier).
   118	
   119	### Trigger 6 — UNIT-ECONOMICS-COST-PER-ACTION (PIVOT)
   120	
   121	**Threshold:** Cost-per-completed-action (defined as: total IFOS infrastructure + API + Claude inference cost ÷ count of `decision_log` rows with `phase='action'` and `payload.tier IN ('green','yellow','orange-approved')`) exceeds **£0.50 per action** after 4 tenant-weeks of operation.
   122	
   123	**Operational-guess threshold; pilot data overrides.** Tune after first 100 pilot actions provide real cost-per-action data. Pre-pilot rationale: £0.50/action × ~200 actions/tenant-month = £100/tenant-month gross cost; viable only above £500/tenant-month revenue. If first-pilot data shows on-target spend, tighten threshold to ~£0.10/action (current £0.005 estimate × 20x safety margin).
   124	
   125	The £0.50 figure assumes:
   126	
   127	- Claude Sonnet 4.6 inference at ~£0.003 per action (small prompt, output cached)
   128	- Bullhorn API call at <£0.001 per action (free tier)
   129	- Hetzner infrastructure at ~£8/mo / ~10k actions/mo ≈ £0.0008 per action
   130	- Total: ~£0.005 per action would be on-track; £0.50 is 100x over-target
   131	
   132	**Owner:** Founder; monthly check.
   133	
   134	**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 pilot scale; master brief does not specify a numeric cost target); emerging from v1.0 pilot operations.
   135	
   136	**Action:** PIVOT — likely vector: cheaper Claude model tier (Haiku 4.5 for routine actions, Sonnet for complex), or reduced agent run frequency (e.g., Sourcing Scout runs nightly batch instead of real-time), or per-tenant cost passthrough in pricing.
   137	
   138	**Recovery path:** Rescoped pricing/architecture; pivoted v1.0 continues.
   139	
   140	### Trigger 7 — INFRASTRUCTURE-COST-MONTHLY (PIVOT)

exec
/bin/zsh -lc 'rg -n "decision_log|consultant_feedback|recent_edit|target_patch|tone_rule|voice_corpus|diagnostic" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml packages/agents-runtime/_shared/common-voice.json packages/agents-runtime/_shared/common-target-patch.json' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/agents-runtime/_shared/common-voice.json:8:    "voice_corpus_path": {
packages/agents-runtime/_shared/common-voice.json:16:      "description": "Tag matching docs/verticals/recruitment/vertical-schema.yaml voice_corpus.version row."
packages/agents-runtime/_shared/common-voice.json:35:    "recent_edits_lookback_days": {
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:42:    "tone_rules_severity_floor": {
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
packages/agents-runtime/_shared/common-voice.json:49:  "required": ["voice_corpus_path", "voice_classifier_threshold"],
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
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.

codex
I’ve found one likely citation/signature mismatch in the voice-loader description and I’m checking whether there are stronger load-bearing mismatches in the actual bundle before deciding the verdict.
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/tools.yaml | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/cleanup.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Diagnostic agent — MCP tool declarations
     2	#
     3	# Status: Proposed (Day-19; @ifos/web-scraper + @ifos/companies-house MCP connectors shipped Day 13; LinkedIn via web-scraper page-fetch in v0; Proxycurl deferred to W4 polish).
     4	# Author: Claude Code (Day 11 initial scaffold + Day 13 connector wiring)
     5	# Ratifies as part of full bundle via review-agent-bundle.md skill.
     6	#
     7	# Reading order: agent.md §3 (12 required sections) + §4 (10-step workflow) +
     8	# §6 (escalation codes). Each tool below maps to one or more workflow steps.
     9	#
    10	# Schema: per packages/agents-runtime/_shared/common-base.json#/definitions/tools_v1
    11	# Required keys per tool entry: name, kind, description, required_env, capabilities
    12	
    13	version: v1
    14	agent: diagnostic
    15	tier: 2  # request-driven; no persistent PTY (per sequencing-target.md §2.1)
    16	
    17	tools:
    18	  # ── §4 Step 2: Companies House lookup ─────────────────────────────────
    19	  - name: companies_house
    20	    kind: mcp_connector
    21	    description: |
    22	      Read-only access to Companies House UK API. Used in §4 Step 2 for
    23	      firm registration data, latest filed accounts, director changes,
    24	      share-class moves. Rate-limited: 600 requests per 5-minute window per IP.
    25	      Cache responses for 7 days per (company_number) per gotcha §6.2.
    26	    required_env:
    27	      - COMPANIES_HOUSE_API_KEY  # provisioned at W3 build start
    28	    capabilities:
    29	      - companies_house.search       # name → CRN
    30	      - companies_house.profile       # CRN → company profile
    31	      - companies_house.officers      # CRN → directors + appointments
    32	      - companies_house.filing_history # CRN → filing dates last 90 days
    33	    rate_limit:
    34	      per_window: 600
    35	      window_seconds: 300
    36	    cache:
    37	      ttl_seconds: 604800  # 7 days
    38	      key_template: 'companies_house:{company_number}:{capability}'
    39	    failure_modes:
    40	      - code: 429
    41	        action: backoff_60s_retry_once
    42	        escalation: ESC_RATE_LIMIT_HIT
    43	      - code: 404
    44	        action: log_and_continue
    45	        escalation: none
    46	      - code: 5xx
    47	        action: fail_fast
    48	        escalation: ESC_SCHEMA_VIOLATION
    49	
    50	  # ── §4 Step 3+4+5+7+8+10+11: LinkedIn read-only ───────────────────────
    51	  - name: linkedin_readonly
    52	    kind: mcp_connector
    53	    description: |
    54	      Read-only LinkedIn API (provider TBD at W3 build start — Proxycurl
    55	      candidate per agent.md §9 Q3). Used across §4 steps 3 (online footprint),
    56	      4 (job posts harvest), 5 (director scan), 7 (ICP fit), 8 (recent activity),
    57	      10 (decision-maker map), 11 (operator notification — N/A here).
    58	      ToS critical: PROFILE DATA MUST NOT BE STORED beyond report generation.
    59	      Cleanup.sh enforces post-render purge of any cached profile data.
    60	    required_env:
    61	      - LINKEDIN_API_KEY  # provider-specific; Proxycurl or alternative
    62	    capabilities:
    63	      - linkedin.company_page         # firm slug → company page metadata
    64	      - linkedin.company_posts        # firm slug → last N posts
    65	      - linkedin.job_posts            # firm slug → current job listings (up to 50)
    66	      - linkedin.employee_search      # firm slug + title filter → employees
    67	      - linkedin.profile_fetch        # profile URL → profile data (transient)
    68	    rate_limit:
    69	      per_window: 100  # Proxycurl default per second
    70	      window_seconds: 60
    71	    cache:
    72	      ttl_seconds: 0   # NO PERSISTENCE per ToS — gotcha §6.1
    73	      key_template: 'linkedin:{capability}:{slug}'  # in-memory only, no disk
    74	    failure_modes:
    75	      - code: 429
    76	        action: backoff_60s_retry_once
    77	        escalation: ESC_RATE_LIMIT_HIT
    78	      - code: 403
    79	        action: fail_fast
    80	        escalation: ESC_SCHEMA_VIOLATION
    81	      - code: 5xx
    82	        action: fail_fast
    83	        escalation: ESC_SCHEMA_VIOLATION
    84	
    85	  # ── §4 Step 3+6+8: web scraper utility ───────────────────────────────
    86	  - name: web_scraper
    87	    kind: builtin_utility
    88	    description: |
    89	      Lightweight HTTP HEAD + first-200-lines fetch utility. Used in §4 Step 3
    90	      (careers page state, last-updated signal) + §6 (pain signal regex on
    91	      careers page) + §8 (Google search for recent activity). Not a full
    92	      browser — does NOT execute JS. Failures on JS-heavy sites are
    93	      gracefully degraded to "no signal found" in the report.
    94	    required_env: []
    95	    capabilities:
    96	      - http.head              # status + last-modified header
    97	      - http.fetch_first_n_lines # first N lines of HTML body
    98	      - google.web_search       # via SerpAPI or similar (provider TBD)
    99	    rate_limit:
   100	      per_window: 30
   101	      window_seconds: 60
   102	    cache:
   103	      ttl_seconds: 3600  # 1 hour for careers pages
   104	      key_template: 'webscrape:{url_hash}'
   105	    failure_modes:
   106	      - code: timeout
   107	        action: log_and_continue
   108	        escalation: none
   109	      - code: 4xx
   110	        action: log_and_continue
   111	        escalation: none
   112	      - code: blocked_by_robots_txt
   113	        action: skip
   114	        escalation: none
   115	
   116	  # ── §4 Step 9 + §7 voice classifier ───────────────────────────────────
   117	  - name: voice_classifier
   118	    kind: internal_service
   119	    description: |
   120	      Per-tenant voice classifier for the §12 conversation opener.
   121	      Scores §12 output against tenant's voice corpus + tone rules. Gate A
   122	      hard-fails on score < 0.75 (after 3 retries). Backs onto _shared/
   123	      voice-loader.sh for tenant corpus + tone rules + recent_edits.
   124	    required_env:
   125	      - IFOS_VOICE_CLASSIFIER_URL  # local microservice; OR fallback to LLM
   126	    capabilities:
   127	      - voice.classify  # text + tenant_slug → score in [0,1]
   128	      - voice.tone_rule_check  # text + tone_rule_set → list of violations
   129	    rate_limit:
   130	      per_window: 1000
   131	      window_seconds: 60
   132	    cache:
   133	      ttl_seconds: 0  # always fresh — score depends on current corpus state
   134	    failure_modes:
   135	      - code: timeout
   136	        action: fail_fast
   137	        escalation: ESC_VOICE_DRIFT
   138	      - code: 5xx
   139	        action: fail_fast
   140	        escalation: ESC_VOICE_DRIFT
   141	
   142	  # ── §4 Step 11 notification (optional) ────────────────────────────────
   143	  - name: telegram_notify
   144	    kind: cortextos_primitive
   145	    description: |
   146	      Per master brief primitive 5 — Telegram notification on report
   147	      completion if --notify-via telegram flag set at CLI invocation.
   148	      Sends summary first 200 chars + vault path. No PII in summary.
   149	    required_env:
   150	      - TELEGRAM_BOT_TOKEN  # per-tenant; from _secrets.env
   151	      - TELEGRAM_OPERATOR_CHAT_ID
   152	    capabilities:
   153	      - telegram.send_message
   154	    rate_limit:
   155	      per_window: 30
   156	      window_seconds: 60
   157	    cache:
   158	      ttl_seconds: 0
   159	    failure_modes:
   160	      - code: 401
   161	        action: fail_fast
   162	        escalation: ESC_SCHEMA_VIOLATION
   163	      - code: 429
   164	        action: backoff_60s_retry_once
   165	        escalation: ESC_RATE_LIMIT_HIT
   166	
   167	# ── No-touch declarations ─────────────────────────────────────────────
   168	# Tools NOT in this manifest that Diagnostic must NEVER call:
   169	no_touch:
   170	  - bullhorn       # Diagnostic is sales-tool tier; no ATS touch per sequencing-target.md §2.1
   171	  - xero           # Cash Conductor's territory (W7-8)
   172	  - quickbooks     # Cash Conductor's territory
   173	  - sage           # Cash Conductor's territory
   174	  - open_banking   # Cash Conductor's territory
   175	  - email_send     # No external sends — vault write only per agent.md §1
   176	  - linkedin_send  # No external sends per agent.md §1
   177	
   178	# ── Build prerequisites (per agent.md §8) ─────────────────────────────
   179	# These must exist before W3 build slice can wire up the tools above:
   180	build_prerequisites:
   181	  - companies_house_mcp_connector  # ~1 day at W3 start
   182	  - linkedin_readonly_mcp_connector  # ~2 days at W3 start (Proxycurl wrapper)
   183	  - web_scraper_utility  # ~0.5 day at W3 start
   184	  - voice_classifier_microservice  # ~2 days at W3 start (OR LLM fallback)
   185	
   186	# End of tools.yaml

 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	#
     3	# Diagnostic agent — cleanup.sh
     4	#
     5	# Status: Proposed (pre-W3-build scaffold; Day-12 author).
     6	# Reading order: agent.md §4 (workflow + gotchas) first — specifically
     7	# gotcha §6.1 (LinkedIn ToS: no profile data persistence beyond audit).
     8	#
     9	# Per ADR-003 v2 bundle pattern: cleanup.sh runs after cycle.sh succeeds
    10	# OR fails. Drops any transient state that wouldn't survive a real-world
    11	# multi-tenant render. Most critical: LinkedIn profile data MUST NOT be
    12	# cached to disk per their ToS.
    13	#
    14	# Invocation: bash cleanup.sh
    15	#
    16	# Exit codes:
    17	#   0  Cleanup successful (or nothing to clean)
    18	#   1  Cleanup failure on a critical path (LinkedIn cache still present)
    19	
    20	set -uo pipefail
    21	
    22	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    23	  printf 'cleanup.sh: CTX_AGENT_DIR unset; nothing to clean\n' >&2
    24	  exit 0
    25	fi
    26	
    27	# shellcheck source=/dev/null
    28	source "${CTX_AGENT_DIR}/.claude/hooks/_shared/hook-helpers.sh"
    29	
    30	# ────────────────────────────────────────────────────────────────────────
    31	# 1 — LinkedIn transient cache purge (CRITICAL per ToS gotcha §6.1)
    32	# ────────────────────────────────────────────────────────────────────────
    33	#
    34	# At W3 build: tools/linkedin_readonly_connector caches profile responses
    35	# in /tmp/ifos-linkedin-cache-<pid>/. Even though tools.yaml sets ttl=0,
    36	# defense-in-depth: explicit purge here.
    37	
    38	LINKEDIN_CACHE_PATTERN="/tmp/ifos-linkedin-cache-*"
    39	PURGED=0
    40	
    41	# shellcheck disable=SC2086
    42	for cache_dir in ${LINKEDIN_CACHE_PATTERN}; do
    43	  if [[ -d "${cache_dir}" ]]; then
    44	    rm -rf "${cache_dir}"
    45	    PURGED=$((PURGED + 1))
    46	  fi
    47	done
    48	
    49	# Verify nothing left
    50	# shellcheck disable=SC2086,SC2012
    51	LEFTOVER=$(ls -d ${LINKEDIN_CACHE_PATTERN} 2>/dev/null | wc -l | tr -d ' ')
    52	if (( LEFTOVER != 0 )); then
    53	  printf 'cleanup.sh: CRITICAL — LinkedIn cache not fully purged (%d dirs remain)\n' "${LEFTOVER}" >&2
    54	
    55	  hh_decision_action "linkedin_cache_purge_fail" "cleanup:${CTX_TENANT_SLUG}" \
    56	    "$(date +%s)" \
    57	    '{"escalation_code":"ESC_PII_LEAKAGE_RISK","reason":"LinkedIn cache purge incomplete"}' \
    58	    2>/dev/null || true
    59	
    60	  exit 1
    61	fi
    62	
    63	if (( PURGED > 0 )); then
    64	  printf 'cleanup.sh: purged %d LinkedIn cache dir(s)\n' "${PURGED}"
    65	fi
    66	
    67	# ────────────────────────────────────────────────────────────────────────
    68	# 2 — Web scraper response cache (lower-criticality; can persist 1h)
    69	# ────────────────────────────────────────────────────────────────────────
    70	#
    71	# Companies House cache stays per tools.yaml (7-day TTL).
    72	# Web scraper cache stays per tools.yaml (1-hour TTL).
    73	# Both are public data; no ToS purge mandate.
    74	
    75	# ────────────────────────────────────────────────────────────────────────
    76	# 3 — Audit row to confirm cleanup ran
    77	# ────────────────────────────────────────────────────────────────────────
    78	
    79	hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
    80	  "$(date +%s)" \
    81	  "$(printf '{"purged_linkedin_cache_dirs":%d}' "${PURGED}")" \
    82	  2>/dev/null || true
    83	
    84	exit 0

exec
/bin/zsh -lc "find packages/diagnostic-generator -maxdepth 3 -type f | sort | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/diagnostic-generator/README.md
packages/diagnostic-generator/dist/cli.js
packages/diagnostic-generator/dist/cli.js.map
packages/diagnostic-generator/node_modules/.bin/tsc
packages/diagnostic-generator/node_modules/.bin/tsserver
packages/diagnostic-generator/node_modules/.bin/tsup
packages/diagnostic-generator/node_modules/.bin/tsup-node
packages/diagnostic-generator/node_modules/.bin/tsx
packages/diagnostic-generator/node_modules/.bin/vitest
packages/diagnostic-generator/package.json
packages/diagnostic-generator/src/cli.ts
packages/diagnostic-generator/src/firm-slug.ts
packages/diagnostic-generator/src/generate.ts
packages/diagnostic-generator/src/sections/conversation-opener.ts
packages/diagnostic-generator/src/sections/firm-signal.ts
packages/diagnostic-generator/src/sections/icp-fit.ts
packages/diagnostic-generator/src/sections/online-footprint.ts
packages/diagnostic-generator/src/sections/pain-signals.ts
packages/diagnostic-generator/src/sections/recent-activity.ts
packages/diagnostic-generator/src/sections/stubs.ts
packages/diagnostic-generator/tests/conversation-opener.test.ts
packages/diagnostic-generator/tests/generate.test.ts
packages/diagnostic-generator/tests/online-footprint.test.ts
packages/diagnostic-generator/tsconfig.json
packages/diagnostic-generator/tsup.config.ts
packages/diagnostic-generator/vitest.config.ts

exec
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|kb-|stock KB|brain" agents/recruitment/diagnostic/agent.md agents/recruitment/diagnostic/*.sh agents/recruitment/diagnostic/tools.yaml agents/recruitment/diagnostic/fixtures/*.yaml' in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
exec
/bin/zsh -lc "nl -ba packages/diagnostic-generator/src/sections/stubs.ts | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// Stub sections §3-§5, §7, §9, §11. Each needs LinkedIn deep data
     2	// (employee search, JD parsing, profile timelines) we don't have at v0.
     3	// Each renders with a Companies House anchor as fallback citation so
     4	// Gate A V2 (≥1 link per section) passes.
     5	
     6	import type { FirmSignalData } from "./firm-signal.js";
     7	
     8	function chAnchor(firmSignal: FirmSignalData, firmName: string): string {
     9	  if (firmSignal.companyNumber) {
    10	    return `[Companies House profile](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber})`;
    11	  }
    12	  return `[Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)})`;
    13	}
    14	
    15	export function renderSectorMix(firmSignal: FirmSignalData, firmName: string, sectorHint: string): string {
    16	  return [
    17	    "## Sector + role-type mix",
    18	    "",
    19	    sectorHint
    20	      ? `Operator-provided sector hint: \`${sectorHint}\`.`
    21	      : "No operator-provided sector hint. SIC codes from Companies House are the only sector signal available without LinkedIn job-post data.",
    22	    firmSignal.sicCodes.length > 0
    23	      ? `Companies House SIC codes: ${firmSignal.sicCodes.join(", ")} — these are self-declared at registration and may not reflect current focus.`
    24	      : "No SIC codes filed (unusual; verify firm status).",
    25	    "",
    26	    "**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.",
    27	    "",
    28	    `Source: ${chAnchor(firmSignal, firmName)}`,
    29	  ].join("\n");
    30	}
    31	
    32	export function renderGeography(firmSignal: FirmSignalData, firmName: string): string {
    33	  return [
    34	    "## Geography",
    35	    "",
    36	    firmSignal.address
    37	      ? `Registered office: ${firmSignal.address}.`
    38	      : `Registered office address not visible at Companies House for ${firmName}.`,
    39	    "",
    40	    "**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).",
    41	    "",
    42	    `Source: ${chAnchor(firmSignal, firmName)}`,
    43	  ].join("\n");
    44	}
    45	
    46	export function renderDealSizeBand(firmSignal: FirmSignalData, firmName: string): string {
    47	  const years = firmSignal.incorporationDate
    48	    ? Math.floor((Date.now() - Date.parse(firmSignal.incorporationDate)) / (365 * 24 * 60 * 60 * 1000))
    49	    : null;
    50	  return [
    51	    "## Deal-size band proxy",
    52	    "",
    53	    years !== null
    54	      ? `Firm age: ${years} years. Combined with ${firmSignal.recentFilingCount} recent filings and director count of ${firmSignal.directors.length}, suggests an established (not startup) operation — likely deal sizes in mid-market band rather than enterprise.`
    55	      : `Firm-age signal unavailable without Companies House incorporation date.`,
    56	    "",
    57	    "**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).",
    58	    "",
    59	    `Source: ${chAnchor(firmSignal, firmName)}`,
    60	  ].join("\n");
    61	}
    62	
    63	export function renderTechStack(firmSignal: FirmSignalData, firmName: string): string {
    64	  return [
    65	    "## Tech stack signals",
    66	    "",
    67	    "**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).",
    68	    "",
    69	    "Companies House SIC codes give a coarse industry signal but no specific technology stack visibility.",
    70	    "",
    71	    `Source: ${chAnchor(firmSignal, firmName)}`,
    72	  ].join("\n");
    73	}
    74	
    75	export function renderCompetitorPositioning(firmSignal: FirmSignalData, firmName: string): string {
    76	  return [
    77	    "## Competitor positioning",
    78	    "",
    79	    "**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.",
    80	    "",
    81	    "Companies House does not surface competitor data at the firm level.",
    82	    "",
    83	    `Source: ${chAnchor(firmSignal, firmName)}`,
    84	  ].join("\n");
    85	}
    86	
    87	export function renderDecisionMakerMap(firmSignal: FirmSignalData, firmName: string): string {
    88	  const lines = ["## Decision-maker map", ""];
    89	  if (firmSignal.directors.length > 0) {
    90	    lines.push("Directors on file at Companies House (proxy for decision-makers until LinkedIn employee search is wired):");
    91	    lines.push("");
    92	    for (const d of firmSignal.directors.slice(0, 5)) {
    93	      const cleanName = d.name.replace(/^([A-Z]+),\s*(.+)$/, "$2 $1");
    94	      lines.push(
    95	        `- **${cleanName}** — ${d.role}${d.appointedOn ? ` (appointed ${d.appointedOn})` : ""}`,
    96	      );
    97	    }
    98	    lines.push("");
    99	    lines.push(
   100	      "**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).",
   101	    );
   102	  } else {
   103	    lines.push("No directors on file at Companies House (firm may be dissolved or unregistered).");
   104	  }
   105	  lines.push("");
   106	  lines.push(`Source: ${chAnchor(firmSignal, firmName)}`);
   107	  return lines.join("\n");
   108	}

exec
/bin/zsh -lc "nl -ba packages/diagnostic-generator/src/generate.ts | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// Top-level Diagnostic report generator. Composes the 12 sections,
     2	// outputs Markdown. Called by cli.ts.
     3	
     4	import { fetchFirmSignal, renderFirmSignal } from "./sections/firm-signal.js";
     5	import {
     6	  fetchOnlineFootprint,
     7	  renderOnlineFootprint,
     8	} from "./sections/online-footprint.js";
     9	import {
    10	  renderSectorMix,
    11	  renderGeography,
    12	  renderDealSizeBand,
    13	  renderTechStack,
    14	  renderCompetitorPositioning,
    15	  renderDecisionMakerMap,
    16	} from "./sections/stubs.js";
    17	import { renderIcpFit, type TargetPatch } from "./sections/icp-fit.js";
    18	import { fetchPainSignals, renderPainSignals } from "./sections/pain-signals.js";
    19	import { fetchRecentActivity, renderRecentActivity } from "./sections/recent-activity.js";
    20	import { renderConversationOpener } from "./sections/conversation-opener.js";
    21	
    22	export interface GenerateInput {
    23	  firmName: string;
    24	  tenantSlug: string;
    25	  sectorHint?: string;
    26	  targetPatch?: TargetPatch | null;
    27	  isoDate?: string;
    28	}
    29	
    30	export async function generateReport(input: GenerateInput): Promise<string> {
    31	  const { firmName, tenantSlug, sectorHint = "", targetPatch = null } = input;
    32	  const isoDate = input.isoDate ?? new Date().toISOString().slice(0, 10);
    33	
    34	  // §1 — Firm signal (Companies House)
    35	  const firmSignal = await fetchFirmSignal(firmName);
    36	  // §2 — Online footprint (web scraper + LinkedIn HEAD check)
    37	  const onlineFootprint = await fetchOnlineFootprint(firmName);
    38	  // §8 — Pain signals (web scraper for careers page)
    39	  const painSignals = await fetchPainSignals(firmName, onlineFootprint);
    40	  // §10 — Recent activity (Companies House filings)
    41	  const recentActivity = await fetchRecentActivity(firmSignal);
    42	
    43	  const header = [
    44	    `# Diagnostic report — ${firmName}`,
    45	    "",
    46	    `**Generated:** ${isoDate} by Intel Force OS Diagnostic agent (v0 — pre-W3 build).`,
    47	    `**Tenant:** ${tenantSlug}`,
    48	    `**Sector hint:** ${sectorHint || "_<none provided>_"}`,
    49	    `**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).`,
    50	    "",
    51	  ].join("\n");
    52	
    53	  // §12 is async (LLM call when key set; deterministic fallback otherwise)
    54	  const conversationOpener = await renderConversationOpener({
    55	    firmName,
    56	    firmSignal,
    57	    painSignals,
    58	    recentActivity,
    59	    sectorHint,
    60	  });
    61	
    62	  const sections: string[] = [
    63	    renderFirmSignal(firmName, firmSignal),
    64	    renderOnlineFootprint(firmName, onlineFootprint),
    65	    renderSectorMix(firmSignal, firmName, sectorHint),
    66	    renderGeography(firmSignal, firmName),
    67	    renderDealSizeBand(firmSignal, firmName),
    68	    renderIcpFit(firmSignal, firmName, sectorHint, targetPatch),
    69	    renderTechStack(firmSignal, firmName),
    70	    renderPainSignals(firmName, painSignals),
    71	    renderCompetitorPositioning(firmSignal, firmName),
    72	    renderRecentActivity(firmSignal, firmName, recentActivity),
    73	    renderDecisionMakerMap(firmSignal, firmName),
    74	    conversationOpener,
    75	  ];
    76	
    77	  return [header, ...sections].join("\n\n").trim() + "\n";
    78	}

exec
/bin/zsh -lc "find packages/mcp-connectors -maxdepth 3 -type f | sort | sed -n '1,160p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/mcp-connectors/companies-house/README.md
packages/mcp-connectors/companies-house/dist/index.d.ts
packages/mcp-connectors/companies-house/dist/index.js
packages/mcp-connectors/companies-house/dist/index.js.map
packages/mcp-connectors/companies-house/node_modules/.modules.yaml
packages/mcp-connectors/companies-house/node_modules/.pnpm-workspace-state-v1.json
packages/mcp-connectors/companies-house/package.json
packages/mcp-connectors/companies-house/pnpm-lock.yaml
packages/mcp-connectors/companies-house/src/cache.ts
packages/mcp-connectors/companies-house/src/capabilities.ts
packages/mcp-connectors/companies-house/src/client.ts
packages/mcp-connectors/companies-house/src/errors.ts
packages/mcp-connectors/companies-house/src/index.ts
packages/mcp-connectors/companies-house/src/rate-limit.ts
packages/mcp-connectors/companies-house/src/types.ts
packages/mcp-connectors/companies-house/tests/scaffold.test.ts
packages/mcp-connectors/companies-house/tests/unit.test.ts
packages/mcp-connectors/companies-house/tsconfig.json
packages/mcp-connectors/companies-house/tsup.config.ts
packages/mcp-connectors/companies-house/vitest.config.ts

exec
/bin/zsh -lc "for f in packages/diagnostic-generator/src/sections/*.ts; do printf '%s\\n' \""'$f"; rg -n "##|LinkedIn|Glassdoor|TODO|stub|placeholder|citation|'"\\]\\(\" \""'$f"; done' in /Users/madsadmin/code/CortexOS
 succeeded in 120ms:
79:  const lines: string[] = ["## Firm signal", ""];
86:    lines.push(`Source: [Companies House search](${chUrl})`);
121:  lines.push(`Source: [Companies House profile](${chUrl})`);
packages/diagnostic-generator/src/sections/icp-fit.ts
20:  const lines: string[] = ["## ICP fit vs target_patch", ""];
26:      `Source: [tenant config](vault://${firmSignal.companyNumber ? "target-patch" : "target-patch"})`,
77:    "**v0 limitation:** geography + deal_size_band scoring requires LinkedIn job-post data. Wire Proxycurl (W4 polish).",
84:  lines.push(`Source: [Companies House profile](${chUrl}) + tenant target_patch.json`);
packages/diagnostic-generator/src/sections/online-footprint.ts
2:// LinkedIn company-page existence check (unauthenticated; bot-detection
44:  // LinkedIn slug discovery: try base (suffix-stripped) first, then full.
54:      // LinkedIn returns 999 for bots, 200 for real pages, 404 for non-existent.
71:  const lines: string[] = ["## Online footprint", ""];
74:    lines.push(`Primary website: [${data.primarySite.url}](${data.primarySite.url}) (HTTP ${data.primarySite.status}).`);
87:      `LinkedIn company page: [${data.linkedInUrl}](${data.linkedInUrl}) (page exists; LinkedIn bot-detection returned ${data.linkedInStatus}, full content needs authenticated fetch — Proxycurl integration v1.1).`,
91:      `LinkedIn page at [${data.linkedInUrl}](${data.linkedInUrl}) not reachable (HTTP ${data.linkedInStatus ?? "n/a"}). Firm may use a different LinkedIn slug or have no company page.`,
packages/diagnostic-generator/src/sections/pain-signals.ts
2:// Without LinkedIn director-post access, this is the main fresh-signal
91:  const lines: string[] = ["## Pain signals", ""];
95:      `No careers page found at standard paths (/careers, /jobs, /work-with-us) for ${firmName}. No pain-signal regex pass possible at v0 without LinkedIn director-post access.`,
98:    lines.push("Source: [searched site root](#) — no careers page reachable.");
104:      `Careers page reachable at [${data.careersPageUrl}](${data.careersPageUrl}) but no high-urgency phrases matched the v0 regex pass. Site may use measured language or hire offline.`,
108:      `Careers page at [${data.careersPageUrl}](${data.careersPageUrl}) shows ${data.matches.length} pain-signal match${data.matches.length === 1 ? "" : "es"}:`,
121:  lines.push(`Source: [careers page](${data.careersPageUrl})`);
packages/diagnostic-generator/src/sections/recent-activity.ts
2:// (v1.1) LinkedIn posts + Google news. v0 covers CH filings only.
35:  const lines: string[] = ["## Recent activity", ""];
55:    "**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.",
58:  lines.push(`Source: [Companies House filing history](${chUrl})`);
packages/diagnostic-generator/src/sections/stubs.ts
1:// Stub sections §3-§5, §7, §9, §11. Each needs LinkedIn deep data
3:// Each renders with a Companies House anchor as fallback citation so
10:    return `[Companies House profile](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber})`;
12:  return `[Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)})`;
17:    "## Sector + role-type mix",
21:      : "No operator-provided sector hint. SIC codes from Companies House are the only sector signal available without LinkedIn job-post data.",
26:    "**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.",
34:    "## Geography",
40:    "**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).",
51:    "## Deal-size band proxy",
57:    "**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).",
65:    "## Tech stack signals",
67:    "**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).",
77:    "## Competitor positioning",
79:    "**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.",
88:  const lines = ["## Decision-maker map", ""];
90:    lines.push("Directors on file at Companies House (proxy for decision-makers until LinkedIn employee search is wired):");
100:      "**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).",

exec
/bin/zsh -lc "find packages/utilities -maxdepth 3 -type f | sort | sed -n '1,200p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/utilities/web-scraper/README.md
packages/utilities/web-scraper/dist/index.d.ts
packages/utilities/web-scraper/dist/index.js
packages/utilities/web-scraper/dist/index.js.map
packages/utilities/web-scraper/node_modules/.modules.yaml
packages/utilities/web-scraper/node_modules/.pnpm-workspace-state-v1.json
packages/utilities/web-scraper/package.json
packages/utilities/web-scraper/pnpm-lock.yaml
packages/utilities/web-scraper/src/cache.ts
packages/utilities/web-scraper/src/client.ts
packages/utilities/web-scraper/src/errors.ts
packages/utilities/web-scraper/src/fetcher.ts
packages/utilities/web-scraper/src/index.ts
packages/utilities/web-scraper/src/rate-limit.ts
packages/utilities/web-scraper/src/robots.ts
packages/utilities/web-scraper/tests/cache.test.ts
packages/utilities/web-scraper/tests/fetcher.test.ts
packages/utilities/web-scraper/tests/scaffold.test.ts
packages/utilities/web-scraper/tsconfig.json
packages/utilities/web-scraper/tsup.config.ts
packages/utilities/web-scraper/vitest.config.ts

exec
/bin/zsh -lc "find agents/recruitment/diagnostic/fixtures -type f -maxdepth 1 -print -exec nl -ba {} \\; | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml
     1	# Diagnostic fixture — 02-edge-case-no-online-footprint
     2	#
     3	# Edge case: firm exists at Companies House but has placeholder website,
     4	# dead LinkedIn page (no posts in 12+ months), no job posts. Tests how
     5	# the agent degrades gracefully — sections 1 (Companies House) populated;
     6	# sections 2-11 mostly "no signal found" content; section 12 still
     7	# generates a voice-classified opener despite thin context.
     8	#
     9	# Status: Proposed (pre-W3-build; data shape verified).
    10	# Reading order: agent.md §3 + agent.md §9 Q1-Q6 open questions.
    11	
    12	fixture_id: 02-edge-case-no-online-footprint
    13	description: Real firm; minimal online presence; tests graceful degradation
    14	tenant_slug: migration-test
    15	agent: diagnostic
    16	expected_gate_a: PASS  # Gate A passes; just thinner content
    17	
    18	invocation:
    19	  command: ifosctl diagnostic
    20	  flags:
    21	    - --firm
    22	    - "Quietfield Resourcing"
    23	    - --sector
    24	    - manufacturing
    25	    - --tenant
    26	    - migration-test
    27	
    28	mocked_tool_responses:
    29	  companies_house:
    30	    profile:
    31	      company_number: "06542987"
    32	      company_name: "Quietfield Resourcing Ltd"
    33	      incorporation_date: "2008-02-19"
    34	      registered_office: "12 Mill Lane, Sheffield S1 2AB"
    35	      latest_accounts_revenue_band: "£1m-£2m"
    36	      latest_accounts_employees_band: "5-9"
    37	    officers:
    38	      - name: "David Quietfield"
    39	        role: "Director"
    40	        appointment_date: "2008-02-19"
    41	    filing_history_last_90d:
    42	      - filing_type: "annual_accounts"
    43	        filed_at: "2026-02-10"
    44	
    45	  linkedin_readonly:
    46	    company_page:
    47	      slug: "quietfield-resourcing"
    48	      follower_count: 47
    49	      last_post_at: "2024-11-12"  # 18 months ago
    50	    job_posts:
    51	      count_active: 0
    52	      sectors: []
    53	      perm_vs_contract_ratio: "n/a"
    54	      avg_salary_band_gbp: "n/a"
    55	      locations: []
    56	    employee_search:
    57	      head_of_talent: null  # not found
    58	      head_of_talent_url: null
    59	      head_of_talent_tenure_years: null
    60	
    61	  web_scraper:
    62	    careers_page:
    63	      url: "https://quietfield-resourcing.com/"
    64	      state: "placeholder"  # site exists but says "coming soon"
    65	      last_updated_signal: "2023-08-04"
    66	      urgency_phrases_found: []
    67	
    68	expected_report:
    69	  word_count_range: [400, 600]  # min length still met
    70	  section_count: 12              # all 12 still present
    71	  citations_per_section_min: 1   # even thin sections cite Companies House
    72	  voice_classifier_score_min: 0.75
    73	
    74	expected_validations:
    75	  V1_12_sections: PASS
    76	  V2_per_section_citation: PASS  # thinner sections cite Companies House profile
    77	  V3_voice_score: PASS
    78	  V4_word_count: PASS  # close to 400 floor but still meets it
    79	  V5_banned_phrases: PASS
    80	  V6_pii_boundary: PASS
    81	
    82	# Special expected behaviour: the opener (§12) must avoid claiming
    83	# pain signals or sector-specific hooks the data doesn't support.
    84	# This tests the LLM prompt's grounding to evidence per agent.md §3.
    85	expected_opener_does_not_contain:
    86	  - "rapid growth"        # no evidence
    87	  - "scaling fast"        # no evidence
    88	  - "tripling"            # no evidence
    89	  - "doubling"            # no evidence
    90	
    91	expected_opener_anchors_to:
    92	  - Companies House
    93	  - or general industry observation
    94	
    95	expected_decision_log_rows:
    96	  - phase: trigger
    97	    payload_includes: {trigger_type: "session_start"}
    98	  - phase: output
    99	    payload_includes: {output_type: "diagnostic_draft"}
   100	  - phase: action
   101	    action_type: diagnostic_report_render
agents/recruitment/diagnostic/fixtures/01-primary.yaml
     1	# Diagnostic fixture — 01-primary
     2	#
     3	# Golden case. Well-formed UK fintech recruitment firm with all 12 sections
     4	# producing real content + real evidence links. This is the happy-path
     5	# test for the agent: validate.sh V1-V6 all PASS, vault write succeeds,
     6	# Gate A clean.
     7	#
     8	# Status: Proposed (pre-W3-build; data structure verified, content TBD).
     9	# Reading order: agent.md §3 (12 sections) + validate.sh V1-V6.
    10	
    11	fixture_id: 01-primary
    12	description: Well-formed UK fintech recruitment firm; golden case
    13	tenant_slug: migration-test
    14	agent: diagnostic
    15	expected_gate_a: PASS
    16	
    17	# Invocation that produces this fixture's output
    18	invocation:
    19	  command: ifosctl diagnostic
    20	  flags:
    21	    - --firm
    22	    - "Charterhouse Partners"
    23	    - --sector
    24	    - fintech
    25	    - --tenant
    26	    - migration-test
    27	
    28	# Mocked tool responses (W3 build replaces with real connector outputs)
    29	mocked_tool_responses:
    30	  companies_house:
    31	    profile:
    32	      company_number: "08732145"
    33	      company_name: "Charterhouse Partners Ltd"
    34	      incorporation_date: "2013-09-14"
    35	      registered_office: "23 King William Street, London EC4R 9AT"
    36	      latest_accounts_revenue_band: "£5m-£10m"
    37	      latest_accounts_employees_band: "20-49"
    38	    officers:
    39	      - name: "Sarah Bowen"
    40	        role: "Director"
    41	        appointment_date: "2013-09-14"
    42	      - name: "James Marshall"
    43	        role: "Director"
    44	        appointment_date: "2019-04-12"
    45	    filing_history_last_90d:
    46	      - filing_type: "annual_accounts"
    47	        filed_at: "2026-04-21"
    48	      - filing_type: "share_allotment"
    49	        filed_at: "2026-03-08"
    50	
    51	  linkedin_readonly:
    52	    company_page:
    53	      slug: "charterhouse-partners"
    54	      follower_count: 8420
    55	      last_post_at: "2026-05-19"
    56	    job_posts:
    57	      count_active: 14
    58	      sectors: [fintech, payments, regtech]
    59	      perm_vs_contract_ratio: "70/30"
    60	      avg_salary_band_gbp: "£70k-£120k"
    61	      locations:
    62	        - London (8)
    63	        - Manchester (3)
    64	        - Remote (3)
    65	    employee_search:
    66	      head_of_talent: "Jane Smith"
    67	      head_of_talent_url: "https://linkedin.com/in/janesmith"
    68	      head_of_talent_tenure_years: 3.2
    69	
    70	  web_scraper:
    71	    careers_page:
    72	      url: "https://charterhouse-partners.com/careers"
    73	      state: "active"
    74	      last_updated_signal: "2026-05-15"
    75	      urgency_phrases_found:
    76	        - "we're tripling our engineering team this year"
    77	        - "rapid growth in our payments practice"
    78	
    79	# Expected report attributes
    80	expected_report:
    81	  word_count_range: [700, 900]
    82	  section_count: 12
    83	  citations_per_section_min: 1
    84	  voice_classifier_score_min: 0.78
    85	  vault_path_template: "/vault/migration-test/diagnostic-reports/charterhouse-partners-{ISO_DATE}.md"
    86	
    87	# Validation expectations
    88	expected_validations:
    89	  V1_12_sections: PASS
    90	  V2_per_section_citation: PASS
    91	  V3_voice_score: PASS  # ≥ 0.75 required
    92	  V4_word_count: PASS   # 400-2000
    93	  V5_banned_phrases: PASS
    94	  V6_pii_boundary: PASS
    95	
    96	# Decision-log audit rows expected after run
    97	expected_decision_log_rows:
    98	  - phase: trigger
    99	    agent_name: diagnostic
   100	    payload_includes: {trigger_type: "session_start"}
   101	  - phase: output
   102	    agent_name: diagnostic
   103	    payload_includes: {output_type: "diagnostic_draft"}
   104	  - phase: action
   105	    agent_name: diagnostic
   106	    action_type: diagnostic_report_render
   107	    payload_includes: {firm_name: "Charterhouse Partners"}
   108	  - phase: action
   109	    agent_name: diagnostic
   110	    action_type: diagnostic_cleanup
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml
     1	# Diagnostic fixture — 99-voice-drift-canary
     2	#
     3	# Adversarial case. Tests Gate A V3 (voice classifier ≥ 0.75) hard-fail
     4	# behaviour by forcing a §12 conversation opener that scores BELOW 0.75
     5	# (LLM-generated using a deliberately off-voice prompt instruction).
     6	# Expected outcome: validate.sh fails V3 after 3 retries, exits non-zero,
     7	# ESC_VOICE_DRIFT row emitted, draft NOT written to vault.
     8	#
     9	# Per kill-criterion §2 Trigger 5 + agent.md §6: voice drift is an
    10	# operational signal, not a catastrophic failure. The test verifies the
    11	# system surfaces it correctly rather than silently shipping bad content.
    12	#
    13	# Status: Proposed (pre-W3-build; behaviour design verified).
    14	
    15	fixture_id: 99-voice-drift-canary
    16	description: Adversarial — force voice classifier below 0.75; expect Gate A V3 failure
    17	tenant_slug: migration-test
    18	agent: diagnostic
    19	expected_gate_a: FAIL  # specifically V3
    20	
    21	invocation:
    22	  command: ifosctl diagnostic
    23	  flags:
    24	    - --firm
    25	    - "Test Drift Co"
    26	    - --sector
    27	    - generic
    28	    - --tenant
    29	    - migration-test
    30	
    31	# Forces the voice classifier into a known-low-scoring path by injecting
    32	# an off-voice opener directly (bypasses LLM in test mode)
    33	test_mode_overrides:
    34	  override_opener_text: |
    35	    Hello! I hope this email finds you well. I am reaching out from
    36	    Intel Force OS, a leading provider of AI-powered recruitment
    37	    solutions. I would love to schedule a call at your earliest
    38	    convenience to discuss how our innovative platform can help
    39	    streamline your business processes and drive growth. Please
    40	    let me know when would be a good time to connect.
    41	  # Why this fails: generic boilerplate, no evidence anchor, no consultant
    42	  # voice. Voice classifier scores in 0.2-0.4 range against a real tenant
    43	  # corpus.
    44	
    45	mocked_tool_responses:
    46	  # Skip; this fixture focuses on §12 validation, not §1-§11 generation

exec
/bin/zsh -lc "rg -n \"diagnostic_report|agent_name|phase|action_type|payload\" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:202:      agent_name:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:208:      action_type:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:149:      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:365:        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:800:    rationale: Autosend policy distinguishes contractor vs candidate action_types; kill criterion + pilot liability treat contractor data differently (IR35, contractor-specific residency); type-first-class beats status-flag-filtered for queryability. Adapter overhead is minimal single conditional.
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.

exec
/bin/zsh -lc "nl -ba packages/agents-runtime/_shared/common-voice.json | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	{
     2	  "$schema": "https://json-schema.org/draft/2020-12/schema",
     3	  "$id": "https://intelforce.os/schemas/common-voice.json",
     4	  "title": "common-voice",
     5	  "description": "Per-tenant voice corpus reference. Read by agents/_shared/voice-loader.sh per master brief §8.1 Change 1. Schema substrate landed in vertical-schema.yaml v0.2 (Phase 4).",
     6	  "type": "object",
     7	  "properties": {
     8	    "voice_corpus_path": {
     9	      "type": "string",
    10	      "default": "/vault/{tenant_slug}/_voice/",
    11	      "description": "Vault directory holding voice samples and tone rules. Token {tenant_slug} resolved at render time."
    12	    },
    13	    "voice_pack_version": {
    14	      "type": "string",
    15	      "default": "v0",
    16	      "description": "Tag matching docs/verticals/recruitment/vertical-schema.yaml voice_corpus.version row."
    17	    },
    18	    "style_guide_path": {
    19	      "type": "string",
    20	      "default": "/vault/{tenant_slug}/_voice/style-guide.md",
    21	      "description": "Canonical style guide; referenced by claude-md-preamble.md."
    22	    },
    23	    "banned_phrases_path": {
    24	      "type": "string",
    25	      "default": "/vault/{tenant_slug}/_voice/banned-phrases.md",
    26	      "description": "Phrases that trigger ESC_VOICE_DRIFT before classifier scoring."
    27	    },
    28	    "voice_classifier_threshold": {
    29	      "type": "number",
    30	      "minimum": 0.0,
    31	      "maximum": 1.0,
    32	      "default": 0.75,
    33	      "description": "Per bullhorn-integration-path.md §4.1 A6 Concierge gate; voice classifier scores below this fail Gate A."
    34	    },
    35	    "recent_edits_lookback_days": {
    36	      "type": "integer",
    37	      "minimum": 1,
    38	      "maximum": 365,
    39	      "default": 30,
    40	      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
    41	    },
    42	    "tone_rules_severity_floor": {
    43	      "type": "string",
    44	      "enum": ["info", "warn", "block"],
    45	      "default": "warn",
    46	      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
    47	    }
    48	  },
    49	  "required": ["voice_corpus_path", "voice_classifier_threshold"],
    50	  "additionalProperties": false
    51	}

exec
/bin/zsh -lc "nl -ba packages/diagnostic-generator/src/sections/conversation-opener.ts | sed -n '1,280p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// §12 — Conversation opener. LLM-driven with deterministic fallback.
     2	//
     3	// LLM path: when ANTHROPIC_API_KEY is set, calls Claude API with §1-§11
     4	// context + tenant voice corpus (when wired via voice-loader.sh) + tone
     5	// rules. Voice classifier microservice still skipped per W3 scaffold spec
     6	// (W4-5 polish wires it; for now §12 ships LLM-generated text without
     7	// real classifier gate).
     8	//
     9	// Fallback path: when key absent OR LLM call fails after retry, falls
    10	// back to deterministic anchor-based composition (Day-13 v0 behaviour).
    11	// Both paths satisfy goal §1 success criterion 3 — the CODE ships;
    12	// runtime behaviour gates on key presence.
    13	
    14	import Anthropic from "@anthropic-ai/sdk";
    15	import type { FirmSignalData } from "./firm-signal.js";
    16	import type { PainSignalsData } from "./pain-signals.js";
    17	import type { RecentActivityData } from "./recent-activity.js";
    18	
    19	export interface ConversationOpenerInput {
    20	  firmName: string;
    21	  firmSignal: FirmSignalData;
    22	  painSignals: PainSignalsData;
    23	  recentActivity: RecentActivityData;
    24	  sectorHint: string;
    25	  // Voice corpus context (optional; W4-5 polish wires real corpus)
    26	  voiceCorpusSamples?: string[];
    27	  toneRules?: { rule_id: string; rule_text: string; severity: string }[];
    28	}
    29	
    30	const CLAUDE_MODEL = "claude-opus-4-7";  // per latest models knowledge cutoff
    31	
    32	/**
    33	 * Top-level renderer — LLM-driven when key available, fallback otherwise.
    34	 * Async because LLM call is network I/O.
    35	 */
    36	export async function renderConversationOpener(
    37	  input: ConversationOpenerInput,
    38	): Promise<string> {
    39	  const apiKey = process.env.ANTHROPIC_API_KEY;
    40	  if (apiKey) {
    41	    try {
    42	      const llmText = await generateOpenerViaLLM(input, apiKey);
    43	      return formatOpenerSection(llmText, input, /* source */ "llm");
    44	    } catch (err) {
    45	      process.stderr.write(
    46	        `conversation-opener: LLM call failed (${(err as Error).message}); falling back to deterministic\n`,
    47	      );
    48	      // Fall through to deterministic path
    49	    }
    50	  }
    51	
    52	  // Deterministic fallback path (Day-13 v0 behaviour)
    53	  const { opener, evidenceLink } = buildDeterministicOpener(input);
    54	  return formatOpenerSection(opener + "\n\n" + evidenceLink, input, "deterministic");
    55	}
    56	
    57	/**
    58	 * Synchronous variant for tests and callers that can't await — always
    59	 * returns the deterministic path. Exposed so existing callers that
    60	 * don't want async overhead can still get a valid §12.
    61	 */
    62	export function renderConversationOpenerSync(input: ConversationOpenerInput): string {
    63	  const { opener, evidenceLink } = buildDeterministicOpener(input);
    64	  return formatOpenerSection(opener + "\n\n" + evidenceLink, input, "deterministic");
    65	}
    66	
    67	interface OpenerComponents {
    68	  opener: string;
    69	  evidenceLink: string;
    70	}
    71	
    72	function buildDeterministicOpener(input: ConversationOpenerInput): OpenerComponents {
    73	  const { firmName, firmSignal, painSignals, recentActivity, sectorHint } = input;
    74	
    75	  // Pick the strongest anchor signal we have, in this order:
    76	  // 1. Specific pain-signal quote from §8
    77	  // 2. Recent filing event (share allotment, director appointment) from §10
    78	  // 3. Director name from §1
    79	  // 4. Generic CH-derived anchor
    80	
    81	  if (painSignals.matches.length > 0 && painSignals.careersPageUrl) {
    82	    const quote = painSignals.matches[0].quote;
    83	    return {
    84	      opener: `Hi — noticed ${firmName}'s careers page mentions "${quote}". When firms are at that point, the bottleneck usually shifts from sourcing to the candidate-experience polish that protects offer acceptance rates. Worth a 20-minute call to compare notes on what we're seeing across other ${sectorHint || "UK recruitment"} firms at the same stage?`,
    85	      evidenceLink: `[Source: ${firmName} careers page](${painSignals.careersPageUrl})`,
    86	    };
    87	  }
    88	
    89	  if (recentActivity.filings.length > 0) {
    90	    const filing = recentActivity.filings.find(
    91	      (f) => /allotment|appointment|incorporation/i.test(f.description),
    92	    ) ?? recentActivity.filings[0];
    93	    return {
    94	      opener: `Hi — saw the ${filing.description.toLowerCase()} on ${filing.date} at Companies House. Usually that's a signal of either fresh investment or a hiring push. We work with ${sectorHint || "UK recruitment"} firms in that exact transition; happy to share what we've seen work for similar-size operators.`,
    95	      evidenceLink: `[Source: Companies House filing on ${filing.date}](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber}/filing-history)`,
    96	    };
    97	  }
    98	
    99	  if (firmSignal.directors.length > 0) {
   100	    const cleanName = firmSignal.directors[0].name.replace(/^([A-Z]+),\s*(.+)$/, "$2 $1");
   101	    const ageYears = firmSignal.incorporationDate
   102	      ? Math.floor((Date.now() - Date.parse(firmSignal.incorporationDate)) / (365 * 24 * 60 * 60 * 1000))
   103	      : null;
   104	    return {
   105	      opener: `Hi ${cleanName.split(" ")[0]} — ${firmName} has been at Companies House for ${ageYears ?? "several"} years and is still actively trading. We work with established UK ${sectorHint || "recruitment"} firms on the operational side — the day-30 cleanup-and-attribution work that compounds across placements. Worth a short call?`,
   106	      evidenceLink: `[Source: Companies House profile](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber})`,
   107	    };
   108	  }
   109	
   110	  return {
   111	    opener: `Hi — looking at ${firmName}'s public footprint, the standard signals (CH filings, careers page, LinkedIn) aren't surfacing the usual indicators of hiring pressure. That itself is interesting — happy to compare what we're seeing across ${sectorHint || "UK recruitment"} sector peers if useful.`,
   112	    evidenceLink: `[Source: Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)})`,
   113	  };
   114	}
   115	
   116	/**
   117	 * Call Claude API to generate the opener. Uses prompt caching on the
   118	 * system prompt + tenant context (per claude-api skill conventions) so
   119	 * repeated calls within a session are cheap.
   120	 */
   121	async function generateOpenerViaLLM(
   122	  input: ConversationOpenerInput,
   123	  apiKey: string,
   124	): Promise<string> {
   125	  const client = new Anthropic({ apiKey });
   126	
   127	  const evidenceContext = buildEvidenceContext(input);
   128	  const voiceContext = (input.voiceCorpusSamples ?? []).slice(0, 5).join("\n---\n");
   129	  const toneRulesText = (input.toneRules ?? [])
   130	    .filter((r) => r.severity === "block" || r.severity === "warn")
   131	    .map((r) => `- ${r.rule_text}`)
   132	    .join("\n");
   133	
   134	  const systemPrompt = `You are writing the §12 "Conversation opener" section of a UK recruitment-firm diagnostic report. Output: a 2-3 sentence cold outreach opener written in the consultant's voice. Must be evidence-anchored to a specific signal from the report's §1-§11 evidence (Companies House data, careers-page quotes, LinkedIn signals, recent filings). NOT generic.
   135	
   136	Constraints:
   137	- 2-3 sentences MAX
   138	- Anchor to ONE specific evidence point (cite it inline)
   139	- No "I hope this finds you well" or generic openers
   140	- No salary / commission anchors
   141	- Suitable for cold outreach to a UK recruitment-firm decision-maker
   142	- Output ONLY the opener text — no prefix, no formatting, no quote marks
   143	
   144	${voiceContext ? `Voice corpus exemplars (write in this style):\n${voiceContext}\n\n` : ""}${toneRulesText ? `Tone rules to respect:\n${toneRulesText}\n\n` : ""}`;
   145	
   146	  const userPrompt = `Firm: ${input.firmName}
   147	Sector hint: ${input.sectorHint || "<none>"}
   148	
   149	Evidence context:
   150	${evidenceContext}
   151	
   152	Write the §12 conversation opener. Output only the opener text.`;
   153	
   154	  const response = await client.messages.create({
   155	    model: CLAUDE_MODEL,
   156	    max_tokens: 300,
   157	    system: systemPrompt,
   158	    messages: [{ role: "user", content: userPrompt }],
   159	  });
   160	
   161	  // Extract text from response content blocks
   162	  const textBlocks = response.content.filter(
   163	    (block): block is Anthropic.Messages.TextBlock => block.type === "text",
   164	  );
   165	  if (textBlocks.length === 0) {
   166	    throw new Error("LLM response had no text content");
   167	  }
   168	  const text = textBlocks.map((b) => b.text).join("\n").trim();
   169	
   170	  if (text.length < 50) {
   171	    throw new Error(`LLM response too short (${text.length} chars; expected ≥50)`);
   172	  }
   173	  if (text.length > 1000) {
   174	    throw new Error(`LLM response too long (${text.length} chars; expected ≤1000)`);
   175	  }
   176	
   177	  // Append the evidence-link as a separate line so the final formatted
   178	  // section still has a Markdown link (Gate A V2 requirement)
   179	  const { evidenceLink } = buildDeterministicOpener(input);
   180	  return text + "\n\n" + evidenceLink;
   181	}
   182	
   183	function buildEvidenceContext(input: ConversationOpenerInput): string {
   184	  const { firmName, firmSignal, painSignals, recentActivity } = input;
   185	  const lines: string[] = [];
   186	
   187	  if (firmSignal.companyNumber) {
   188	    lines.push(`- Companies House: ${firmName} (CRN ${firmSignal.companyNumber}, ${firmSignal.status ?? "active"}, incorporated ${firmSignal.incorporationDate ?? "date unknown"})`);
   189	    if (firmSignal.recentFilingCount > 0) {
   190	      lines.push(`- ${firmSignal.recentFilingCount} CH filings in last 90 days`);
   191	    }
   192	    if (firmSignal.directors.length > 0) {
   193	      const directorNames = firmSignal.directors.slice(0, 3).map((d) =>
   194	        d.name.replace(/^([A-Z]+),\s*(.+)$/, "$2 $1"),
   195	      ).join("; ");
   196	      lines.push(`- Directors: ${directorNames}`);
   197	    }
   198	  } else {
   199	    lines.push(`- Companies House: no UK registration found for "${firmName}"`);
   200	  }
   201	
   202	  if (painSignals.matches.length > 0) {
   203	    lines.push(`- Careers page pain signals:`);
   204	    for (const m of painSignals.matches.slice(0, 3)) {
   205	      lines.push(`  - "${m.quote}"`);
   206	    }
   207	  } else if (painSignals.careersPageUrl) {
   208	    lines.push(`- Careers page reachable but no urgency-phrase matches`);
   209	  }
   210	
   211	  if (recentActivity.filings.length > 0) {
   212	    lines.push(`- Recent CH filings (last 90d):`);
   213	    for (const f of recentActivity.filings.slice(0, 3)) {
   214	      lines.push(`  - ${f.date}: ${f.description}`);
   215	    }
   216	  }
   217	
   218	  return lines.join("\n");
   219	}
   220	
   221	function formatOpenerSection(
   222	  body: string,
   223	  _input: ConversationOpenerInput,
   224	  source: "llm" | "deterministic",
   225	): string {
   226	  const lines: string[] = ["## Conversation opener", ""];
   227	
   228	  // body is either the LLM-generated opener+evidence OR the deterministic
   229	  // opener+evidence (already includes the link line)
   230	  const bodyLines = body.split("\n");
   231	  // First non-empty line is the opener; rest is evidence link
   232	  const openerLines: string[] = [];
   233	  const linkLines: string[] = [];
   234	  let inLinks = false;
   235	  for (const line of bodyLines) {
   236	    if (line.startsWith("[Source:") || line.startsWith("[")) {
   237	      inLinks = true;
   238	    }
   239	    if (inLinks) {
   240	      linkLines.push(line);
   241	    } else if (line.trim()) {
   242	      openerLines.push(line);
   243	    }
   244	  }
   245	
   246	  if (openerLines.length === 0) {
   247	    // Defensive: body didn't split cleanly; output as-is
   248	    lines.push(`> ${body.replace(/\n/g, "\n> ")}`);
   249	  } else {
   250	    lines.push(`> ${openerLines.join(" ")}`);
   251	  }
   252	  lines.push("");
   253	  if (linkLines.length > 0) {
   254	    lines.push(linkLines.filter((l) => l.trim()).join("\n"));
   255	  }
   256	  lines.push("");
   257	  if (source === "llm") {
   258	    lines.push(
   259	      "**Generation:** LLM-driven (Claude API + evidence context). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0 scaffold; W4-5 polish wires real classifier.",
   260	    );
   261	  } else {
   262	    lines.push(
   263	      "**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.",
   264	    );
   265	  }
   266	
   267	  return lines.join("\n");
   268	}

exec
/bin/zsh -lc "nl -ba docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Codex disagreement — Diagnostic Gate A citation requirement + 4 follow-on findings
     2	
     3	**Date:** 2026-05-24 (Day 19; end of Week 3 goal execution)
     4	**Status:** Awaiting founder arbitration
     5	**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
     6	**Artefact:** `agents/recruitment/diagnostic/agent.md`
     7	**Codex output logs:**
     8	- Round 4: `logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md`
     9	- Round 5: `logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md`
    10	
    11	---
    12	
    13	## Context
    14	
    15	Week 3 goal at `docs/operations/goal-week-3-polish-and-scaffold.md` Step 7 (Codex Round 4 Phase 1) ratified `agents/recruitment/diagnostic/agent.md`. Codex found 4 issues; mechanical remediation applied (commit `6e0cb86`); Round 5 re-ratification found 5 new issues — 2 re-raises (Codex disagreed with my remediation framing), 3 new findings not visible at Round 4.
    16	
    17	Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.
    18	
    19	---
    20	
    21	## The 5 Round-5 issues, with my recommended disposition
    22	
    23	### Issue 1 (RE-RAISE) — Gate A citation requirement strength
    24	
    25	**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
    26	
    27	**My Round-4 remediation:** narrowed §1 from "per-claim citation" to "per-section citation" because validate.sh V2 implementation only checks per-section.
    28	
    29	**Founder decision needed:** which is the load-bearing source of truth?
    30	
    31	Option A — **Tighten Gate A to per-claim citation** (matches Ultraplan). Requires implementing per-claim citation validation in `validate.sh` (significant logic; W4 polish item but Codex says it should be Gate A v0).
    32	
    33	Option B — **Amend Ultraplan §8.1 A1 line 497** to read "no unsupported claims at section level" (loosens upstream to match v0 implementation).
    34	
    35	Option C — **Hybrid:** v0 Gate A = per-section (current); Gate B (post-launch quality signal) = per-claim spot-check sampling. Document this two-tier policy explicitly.
    36	
    37	**My recommendation:** **C** (hybrid). Per-claim validation is genuinely hard to automate at v0 (requires NLP claim-extraction + per-claim evidence-link matching); deferring to W4 is honest. But Codex is right that the §1 contract reads as if we're skipping it entirely — needs clearer "deferred to W4 with documented gap-coverage plan."
    38	
    39	### Issue 2 (NEW) — Step 11 Telegram notification missing decision-log call
    40	
    41	**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
    42	
    43	**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
    44	
    45	**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).
    46	
    47	### Issue 3 (RE-RAISE) — Gate B kill-criterion Trigger reference
    48	
    49	**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
    50	
    51	**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
    52	
    53	**Founder decision needed:** Diagnostic's Gate B metric doesn't map cleanly to ANY existing kill-criterion trigger.
    54	
    55	Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.
    56	
    57	Option B — **Add a new kill-criterion Trigger 11 (DIAGNOSTIC-CONVERSION-FAIL).** Threshold: <30% discovery-call rate sustained for 4 weeks across all live pilots. Owner: founder + Jack.
    58	
    59	**My recommendation:** **A** for v0 — remove the trigger reference; Diagnostic conversion is local-metric tracking. Add Trigger 11 in v1.1 if conversion-rate-driven scope-cut becomes operationally relevant.
    60	
    61	### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented
    62	
    63	**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
    64	
    65	**Disposition:** **Codex is correct.** My Round-4 remediation invented a new sentinel without registering it.
    66	
    67	**Recommendation:** **Two options for founder:**
    68	
    69	Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.
    70	
    71	Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
    72	
    73	**My recommendation:** **B** — cleaner, avoids sentinel proliferation. Feedback events are conceptually Diagnostic's domain (they validate Diagnostic outputs), so the agent_name should be Diagnostic with a specific action_type marker.
    74	
    75	### Issue 5 (NEW) — Missing Context/Decision/Consequences sections
    76	
    77	**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."
    78	
    79	**Disposition:** **Codex is correct about the skill requirement**, but the artefact type is wrong. `agent.md` files are NOT architecture-decision documents — they're agent specifications per ADR-003 v2 bundle pattern (6 files + 3 fixtures). They don't fit the Context/Decision/Consequences shape.
    80	
    81	**Recommendation:** **Build `review-agent-bundle.md` Codex skill** (deferred per execution-plan §3 lazy; now needed). The Round-4 manifest used `review-architecture-decision.md` as a temporary skill because `review-agent-bundle.md` doesn't exist yet. The correct ratification path for agent.md files is the agent-bundle skill, not architecture-decision.
    82	
    83	**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
    84	
    85	---
    86	
    87	## Recommended founder actions
    88	
    89	1. **Arbitrate Issues 1 + 3** (which framing to use; my recommendations above)
    90	2. **Accept Issue 2 fix** (mechanical; bundles with Concierge notification work)
    91	3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
    92	4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
    93	5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
    94	
    95	---
    96	
    97	## What this means for Week 3 goal closure
    98	
    99	Per `docs/operations/goal-week-3-polish-and-scaffold.md` §1 success criteria 10-12 (Codex Round 4 verdicts):
   100	
   101	- Phase 1 Diagnostic-only: **1 of 6 artefacts attempted**; result is **REJECTED-after-hard-ceiling** awaiting founder arbitration via this disagreement doc
   102	- Phase 2 full (5 new scaffolds): **deferred** pending Issue-5 resolution (review-agent-bundle.md skill build)
   103	
   104	**Week 3 goal is therefore complete to the boundary of what can be done without founder arbitration.** Final §10 end-of-goal report acknowledges this and queues the founder-decision items.
   105	
   106	Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
   107	
   108	---
   109	
   110	## Round-4-v2 results (post-skill-build, Day-19 13:25 UTC)
   111	
   112	After building `.codex/ratification/review-agent-bundle.md` (commit `825ebd4`) — the correct skill for agent.md ratification — all 6 agent.md files were re-ratified.
   113	
   114	**Verdict summary:** 6 of 6 REJECTED. Issues per artefact:
   115	
   116	| Artefact | Issues found | Round-4-v2 session |
   117	|---|---|---|
   118	| Diagnostic | 5 (same as Round 5 but with Issue-5-validate-impl-gap replacing Issue-5-doc-shape) | `logs/codex-ratification/20260524T101934Z-19923/` |
   119	| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
   120	| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
   121	| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
   122	| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
   123	| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |
   124	
   125	**Pattern across all 6:** the systemic issues fall into FIVE categories that span every agent.md:
   126	
   127	1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
   128	2. **Workflow steps missing decision-log calls** — most agent.md files have at least one Step (notification, operator alert, status update) that produces side-effects without `hh_decision_*` call. Same disposition as Diagnostic Issue 2 — mechanical fix during W4-13 build slices when cycle.sh is implemented.
   129	3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
   130	4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
   131	5. **§5 honesty about validate.sh implementation** — agent.md §5 sections describe Gate A behaviour that may not be implemented in the corresponding `validate.sh`. For Diagnostic, validate.sh exists + has gaps (Issue 5). For the 5 new scaffolds, validate.sh DOESN'T exist yet — §5 describes intent. Disposition: explicitly mark "intended behaviour; cycle.sh + validate.sh implementation at W-X build will deliver this" in §5 of each pre-build scaffold.
   132	
   133	## Recommended founder arbitration
   134	
   135	**Single founder decision unlocks all 6 ratifications:** approve the 5-category disposition above. Then mechanical remediation pass applies the dispositions across all 6 agent.md files. Re-ratify all 6 (Round 5 — final per hard ceiling); expect RATIFIED.
   136	
   137	Time cost: ~2 hours mechanical fixes (Claude) + ~10 min Codex re-runs.
   138	
   139	If founder REJECTS the disposition framework above OR wants per-issue review, escalate to Sunday review session with founder + Claude walking through each agent.md issue list.
   140	
   141	## Why the disposition framework is reasonable
   142	
   143	The 5 categories represent honest engineering trade-offs at v0:
   144	- Per-claim Gate A validation is genuinely hard to automate (NLP claim-extraction + per-claim evidence linkage); the hybrid v0+W4 path is the industry-standard approach.
   145	- Decision-log calls SHOULD be at every action; agent.md §4 specs the intent; cycle.sh implementation at build slice will deliver it.
   146	- Sentinel hygiene (Issue 4) is a real architectural concern; agent_name=agent + payload.action_type is the cleaner pattern; no reason to proliferate sentinels.
   147	- §5 honesty (Issue 5) is exactly the kind of "honest signal" the master brief §1 Rule 5 demands; framing §5 as "intended behaviour, build slice will deliver" is more honest than asserting Gate A as already-implemented.
   148	
   149	These are not unprincipled compromises — they're the right v0 stance with W4-13 polish path documented.
   150	
   151	---
   152	
   153	---
   154	
   155	## Janitor Round-5 (remediation) — empirical confirmation of bilateral pattern
   156	
   157	After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
   158	
   159	1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
   160	2. **`bullhorn_field_backfill` unregistered, would fail-safe to red:** my flag-for-addition framing didn't satisfy because `hook-helpers.sh::autosend_policy_lookup` fails to red on unknown action types AT RUNTIME, regardless of flag prose. Real bug requires either (a) policy row added BEFORE ratification, OR (b) explicit "blocked W5 prerequisite" framing not "executable output."
   161	3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
   162	4. **Schema field names STILL wrong:** my Round-4-v2 fix touched `headcount_band → size_employees` but missed `client.legal_name → name`, `registered_office_address` (doesn't exist; canonical is `address` per line 248), `sic_codes` (doesn't exist as canonical field). Schema audit was incomplete.
   163	5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
   164	
   165	**Empirical confirmation of the pattern documented in master brief §10.3 step 5:** Codex finds new issues at each round. Hard ceiling of ≤2 round-trips is the right structural protocol. Further autonomous Claude remediation passes will continue surfacing new issues that may not have been visible at earlier rounds (each fix changes the document, exposing different inconsistencies).
   166	
   167	This isn't Codex being adversarial — it's doing its job as "second pair of eyes" per top-level SKILL.md. The agent.md drafts I authored have systematic citation-drift + internal-consistency issues that need careful bilateral pass.
   168	
   169	## The bilateral session — what it would look like
   170	
   171	90-min Sunday founder review:
   172	1. Founder reads each Codex output log (~10 min per artefact × 6 = 60 min)
   173	2. Founder + Claude jointly walk through 5-category disposition (above) + per-agent specifics (15 min)
   174	3. Founder approves: (a) catalogue extensions (escalation-codes + autosend-policy batch additions), (b) schema field corrections, (c) §5/§6/§7 prose standardisation pattern (15 min)
   175	4. Single Claude execution pass applies all approved corrections to all 6 agent.md files
   176	5. Single Codex re-ratification round (Round 6) expected RATIFIED for the artefacts where Codex's framing was accepted, with documented disagreements for any artefacts where founder counter-argues
   177	
   178	Estimated wall-clock after founder review starts: ~2 hours (founder review + Claude remediation + Codex run).
   179	
   180	Without founder bilateral involvement, each autonomous remediation round burns ~30-60 min Claude time + 2-5 min Codex tokens, with low probability of RATIFIED on artefacts that have multiple systemic issues.
   181	
   182	---
   183	
   184	## Janitor Round 6 (exceeds hard ceiling) — 4 more NEW findings, all different from Rounds 4-5
   185	
   186	Despite master brief §10.3 step 5 protocol saying founder review after Round 5, Round 6 attempted with all Round-5 issues remediated (commit `aaa376d`). Round 6 returned REJECTED with **4 new findings**, none of which appeared in any prior round:
   187	
   188	1. Gate B composite score (≥12.5) weakens dual ULTRAPLAN thresholds (15% dedup AND 10% field-completeness independently)
   189	2. `recent_edit` schema confusion — it's a v0.2 separate table, not a decision_log field
   190	3. Schema field references — candidate has `bullhorn_id` not "CRN"; location line number 124 not 89
   191	4. `ESC_DUPLICATE_DETECTED` semantics — catalogue defines it for ≥0.85 human-review-required, not <0.85 reject
   192	
   193	**Cumulative empirical pattern across 4 rounds:**
   194	
   195	| Round | Skill | Issues found | Unique issues so far |
   196	|---|---|---|---|
   197	| Round 4 v1 | review-architecture-decision (wrong) | 4 | 4 |
   198	| Round 4 v2 | review-agent-bundle (correct) | 6 | 10 (6 new) |
   199	| Round 5 (remediation of R4-v2) | review-agent-bundle | 5 | 15 (5 new; none from R4-v2) |
   200	| Round 6 (remediation of R5) | review-agent-bundle | 4 | 19 (4 new; none from R5) |
   201	
   202	**21 unique issues across 4 rounds, ZERO repeats.** Master brief §10.3 step 5 hard ceiling exists for exactly this reason — each remediation pass surfaces issues that weren't visible at prior rounds because the document changes.
   203	
   204	**Definitive engineering conclusion:** the agent.md scaffolds I authored at "one-per-day" scaffold pace have ~15-20 systemic citation/consistency issues each. Codex correctly finds them. Auto-remediation rounds will continue finding new issues indefinitely. **The structural fix is bilateral founder+Claude session with careful per-line verification against 5 catalogues — not more grinding.**
   205	
   206	This document now contains 4 rounds of empirical evidence supporting the master brief's documented hard-ceiling protocol. Founder Sunday review session is the right next step.
   207	
   208	---
   209	
   210	## Janitor Round 7 — 23+ unique issues; pattern definitively closed
   211	
   212	After all 4 Round-6 issues remediated on Janitor (commit `1939d9b`), Round 7 returned REJECTED with **4 more new findings**, none from Rounds 4-6:
   213	
   214	1. `operator_notify_telegram` + `janitor_run_complete` are unregistered hh_decision_action types — hook-helpers fails them to red via `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`. (Found because my Round-6 commit added those calls without registering them.)
   215	2. §5 vs §6 STILL contradict on `ESC_DUPLICATE_DETECTED` — my Round-6 fix updated §6 cell but missed the §5 prose that still cited the wrong mapping.
   216	3. `ESC_GATE_B_MISS` definition in §6 still says "Composite Gate-B score <12.5" — composite removed from §3 + §5 prose in Round 6 but the §6 ESC table row missed.
   217	4. Tacit-note source — §1 + §3 still say `decision_log` resolution events; only §4 Step 8 was updated in Round 6. Same `recent_edit` table confusion in different sections.
   218	
   219	### Final empirical pattern: 23+ unique issues across 5 rounds, zero repeats
   220	

exec
/bin/zsh -lc "rg -n \"Trigger 8|revenue|Diagnostic|discovery|conversion\" docs/decisions/v1.0-kill-criterion.md | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
69:**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
123:**Operational-guess threshold; pilot data overrides.** Tune after first 100 pilot actions provide real cost-per-action data. Pre-pilot rationale: £0.50/action × ~200 actions/tenant-month = £100/tenant-month gross cost; viable only above £500/tenant-month revenue. If first-pilot data shows on-target spend, tighten threshold to ~£0.10/action (current £0.005 estimate × 20x safety margin).
158:### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
160:**Threshold:** After 3 completed pilots (defined as: pilot ran for ≥90 days with active agent fleet and quarterly Gate B revenue measurement), average Gate B revenue uplift per tenant <£20k/year.
198:**Recovery path:** None within v1.0. Mandatory ICO notification per UK GDPR Art. 33 (within 72 hours of discovery). Lessons logged comprehensively. Any v1.1 must be architecturally distinct (e.g., per-tenant physically-isolated infrastructure rather than shared Postgres with RLS).
227:- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
239:Trigger 10 escalates regulatory-clock-driven actions. UK GDPR Art. 33 mandates ICO notification within 72 hours of discovery; multi-person consultation cannot delay this clock.
334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.

exec
/bin/zsh -lc 'rg -n "ESC_VOICE_DRIFT|voice.classify|IFOS_VOICE_CLASSIFIER|classifier|score" packages/diagnostic-generator agents/recruitment/diagnostic -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/diagnostic-generator/README.md:24:- **§6 ICP fit** — composite score from §1/§5 vs tenant `target_patch.json`.
packages/diagnostic-generator/README.md:37:2. **No LLM-driven §12.** Conversation opener is deterministic anchor-based. W4 wires an LLM + voice classifier.
packages/diagnostic-generator/README.md:38:3. **No voice classifier gate.** validate.sh V3 skipped at v0 with explicit warning.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:3:# Adversarial case. Tests Gate A V3 (voice classifier ≥ 0.75) hard-fail
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:4:# behaviour by forcing a §12 conversation opener that scores BELOW 0.75
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:7:# ESC_VOICE_DRIFT row emitted, draft NOT written to vault.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:16:description: Adversarial — force voice classifier below 0.75; expect Gate A V3 failure
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:31:# Forces the voice classifier into a known-low-scoring path by injecting
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:42:  # voice. Voice classifier scores in 0.2-0.4 range against a real tenant
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:62:  V3_voice_score: FAIL  # < 0.75 after 3 retries — the canary fires here
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:69:  - escalation_code: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:86:    - "voice_classifier_score"
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:87:    - "ESC_VOICE_DRIFT"
agents/recruitment/diagnostic/cycle.sh:118:# data deferred to W4 (Proxycurl). Voice classifier gate skipped at v0.
agents/recruitment/diagnostic/tools.yaml:116:  # ── §4 Step 9 + §7 voice classifier ───────────────────────────────────
agents/recruitment/diagnostic/tools.yaml:117:  - name: voice_classifier
agents/recruitment/diagnostic/tools.yaml:120:      Per-tenant voice classifier for the §12 conversation opener.
agents/recruitment/diagnostic/tools.yaml:122:      hard-fails on score < 0.75 (after 3 retries). Backs onto _shared/
agents/recruitment/diagnostic/tools.yaml:125:      - IFOS_VOICE_CLASSIFIER_URL  # local microservice; OR fallback to LLM
agents/recruitment/diagnostic/tools.yaml:127:      - voice.classify  # text + tenant_slug → score in [0,1]
agents/recruitment/diagnostic/tools.yaml:133:      ttl_seconds: 0  # always fresh — score depends on current corpus state
agents/recruitment/diagnostic/tools.yaml:137:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:140:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:184:  - voice_classifier_microservice  # ~2 days at W3 start (OR LLM fallback)
agents/recruitment/diagnostic/fixtures/01-primary.yaml:84:  voice_classifier_score_min: 0.78
agents/recruitment/diagnostic/fixtures/01-primary.yaml:91:  V3_voice_score: PASS  # ≥ 0.75 required
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:72:  voice_classifier_score_min: 0.75
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:77:  V3_voice_score: PASS
agents/recruitment/diagnostic/README.md:25:| `fixtures/99-voice-drift-canary.yaml` | Adversarial: forces voice classifier near threshold | W3 build start |
agents/recruitment/diagnostic/context.sh:29:#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
packages/diagnostic-generator/src/sections/conversation-opener.ts:5:// rules. Voice classifier microservice still skipped per W3 scaffold spec
packages/diagnostic-generator/src/sections/conversation-opener.ts:7:// real classifier gate).
packages/diagnostic-generator/src/sections/conversation-opener.ts:259:      "**Generation:** LLM-driven (Claude API + evidence context). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0 scaffold; W4-5 polish wires real classifier.",
packages/diagnostic-generator/src/sections/conversation-opener.ts:263:      "**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.",
agents/recruitment/diagnostic/validate.sh:31:#   V3 — Section 12 voice classifier score ≥ 0.75
agents/recruitment/diagnostic/validate.sh:128:# V3 — §12 voice classifier ≥ 0.75
agents/recruitment/diagnostic/validate.sh:137:  # Voice classifier microservice call (W3 build wires this up)
agents/recruitment/diagnostic/validate.sh:138:  # For scaffold: assume IFOS_VOICE_CLASSIFIER_URL set; fail gracefully if not
agents/recruitment/diagnostic/validate.sh:139:  if [[ -n "${IFOS_VOICE_CLASSIFIER_URL:-}" ]]; then
agents/recruitment/diagnostic/validate.sh:140:    SCORE=$(curl -sS -X POST "${IFOS_VOICE_CLASSIFIER_URL}/classify" \
agents/recruitment/diagnostic/validate.sh:145:      2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('score', 0))" 2>/dev/null || echo "0")
agents/recruitment/diagnostic/validate.sh:148:      _pass "V3: §12 voice classifier score=${SCORE} (≥ 0.75)"
agents/recruitment/diagnostic/validate.sh:150:      _fail "V3: §12 voice classifier score=${SCORE} (< 0.75)"
agents/recruitment/diagnostic/validate.sh:153:    _warn "V3: IFOS_VOICE_CLASSIFIER_URL unset; voice classification SKIPPED (W3 build wires this)"
agents/recruitment/diagnostic/validate.sh:236:  #     length, voice-classifier miss) → ESC_AGENT_OUTPUT_SHAPE (warn)
packages/diagnostic-generator/src/sections/icp-fit.ts:23:    lines.push("No target_patch.json loaded for this tenant — cannot score ICP fit.");
packages/diagnostic-generator/src/sections/icp-fit.ts:44:      sectorReason = "no operator sector hint provided; neutral score";
packages/diagnostic-generator/src/sections/icp-fit.ts:58:  const scoresPresent: number[] = [];
packages/diagnostic-generator/src/sections/icp-fit.ts:59:  if (sectorScore !== null) scoresPresent.push(sectorScore);
packages/diagnostic-generator/src/sections/icp-fit.ts:60:  if (sizeScore !== null) scoresPresent.push(sizeScore);
packages/diagnostic-generator/src/sections/icp-fit.ts:63:    scoresPresent.length > 0
packages/diagnostic-generator/src/sections/icp-fit.ts:64:      ? Math.round(scoresPresent.reduce((a, b) => a + b, 0) / scoresPresent.length)
packages/diagnostic-generator/src/sections/icp-fit.ts:69:      ? `**Composite ICP fit score: ${composite}/100** (based on ${scoresPresent.length} dimension${scoresPresent.length === 1 ? "" : "s"} measurable at v0).`
packages/diagnostic-generator/src/sections/icp-fit.ts:70:      : "**ICP fit score not computable** — insufficient signals available.",
agents/recruitment/diagnostic/agent.md:16:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:66:- Section 12 (conversation opener) failing voice-classifier with score < 0.75 *(v0 hard-fail when voice-classifier URL reachable; warn + exit 0 when URL unreachable per §5 honesty note; W4 polish closes to unconditional hard-fail with explicit `validate_check_skipped` audit row)*
agents/recruitment/diagnostic/agent.md:107:   → ESC_VOICE_DRIFT raised internally by §12 LLM step if classifier <0.75 after 3 retries
agents/recruitment/diagnostic/agent.md:113:   → voice classifier + PII subchecks per §5 honesty note (warn-only on
agents/recruitment/diagnostic/agent.md:144:**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
agents/recruitment/diagnostic/agent.md:146:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings to stdout and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but no separate `decision_log` audit row is written. W4 polish closes these two cases to (a) unconditional hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
agents/recruitment/diagnostic/agent.md:150:- Section 12 voice classifier score ≥ 0.75. Sample retrieval is via `hh_load_voice_samples` (returns top-N voice corpus chunks); the classifier itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh` design — sample retrieval ≠ classifier scoring. **v0: warns + exit 0 if voice-classifier URL unreachable; W4 polish closes to hard-fail.**
agents/recruitment/diagnostic/agent.md:169:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:192:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: returns top-N voice-corpus chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker); feeds LLM prompt as voice exemplars. NOTE: sample retrieval is distinct from classifier scoring — voice classification itself is a separate service called by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` per `agents/_shared/voice-loader.sh`.
agents/recruitment/diagnostic/agent.md:193:- **`hh_load_recent_edits` last 30 days for `diagnostic`** (single agent_name arg per `voice-loader.sh::hh_load_recent_edits`; current `context.sh` passes `"diagnostic"` only): surfaces patterns of how consultant edits Diagnostic drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.

codex
REJECTED

1. Gate A voice validation is weaker than the §1 output contract. `agent.md` line 16 requires the opener to be voice-classified `≥ 0.75`, but lines 146 and 150 admit v0 exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unavailable; `validate.sh` lines 139-154 implements that warn-only path and lines 226-228 pass with warnings. This violates Rule 4 because a declared Gate A threshold can be skipped. Fix: make missing/unreachable voice classifier a hard-fail with an audit row, or downgrade §1/status so production is blocked until W4 closes it.

2. Voice-drift escalation semantics are internally inconsistent. `agent.md` lines 107, 169, and 193 say classifier score `<0.75` fires `ESC_VOICE_DRIFT`, and fixture `99-voice-drift-canary.yaml` line 69 expects that code; but `validate.sh` lines 233-251 maps voice-classifier miss to `ESC_AGENT_OUTPUT_SHAPE`. Fix: route V3 failures to `ESC_VOICE_DRIFT` consistently, or update `agent.md` and fixtures to make `ESC_AGENT_OUTPUT_SHAPE` canonical.

3. The output-shape claims overstate the built bundle’s LinkedIn coverage. `agent.md` lines 51-60 define sections 3-5, 7, 9, and 11 as using LinkedIn job posts/profiles/employees, while `packages/diagnostic-generator/src/sections/stubs.ts` lines 1-4 says those sections are stubs using Companies House fallback citations because LinkedIn deep data is absent. `agent.md` line 220 says bundle code is complete, which buries a load-bearing limitation. Fix: either implement the LinkedIn-backed sections before ratification, or explicitly mark those §3 sections and §8 status as v0 placeholder/degraded outputs.

4. The voice-loader citation is inaccurate. `agent.md` line 193 says `hh_load_recent_edits` takes a single `agent_name` arg and current `context.sh` passes `"diagnostic"` only; actual `voice-loader.sh` lines 223-235 define `[lookback_days] [agent_name]`, and `context.sh` line 160 calls `hh_load_recent_edits 30 "diagnostic"`. Fix: correct the signature claim and the cited implementation description in §7.
tokens used
126,589
REJECTED

1. Gate A voice validation is weaker than the §1 output contract. `agent.md` line 16 requires the opener to be voice-classified `≥ 0.75`, but lines 146 and 150 admit v0 exits 0 when `IFOS_VOICE_CLASSIFIER_URL` is unavailable; `validate.sh` lines 139-154 implements that warn-only path and lines 226-228 pass with warnings. This violates Rule 4 because a declared Gate A threshold can be skipped. Fix: make missing/unreachable voice classifier a hard-fail with an audit row, or downgrade §1/status so production is blocked until W4 closes it.

2. Voice-drift escalation semantics are internally inconsistent. `agent.md` lines 107, 169, and 193 say classifier score `<0.75` fires `ESC_VOICE_DRIFT`, and fixture `99-voice-drift-canary.yaml` line 69 expects that code; but `validate.sh` lines 233-251 maps voice-classifier miss to `ESC_AGENT_OUTPUT_SHAPE`. Fix: route V3 failures to `ESC_VOICE_DRIFT` consistently, or update `agent.md` and fixtures to make `ESC_AGENT_OUTPUT_SHAPE` canonical.

3. The output-shape claims overstate the built bundle’s LinkedIn coverage. `agent.md` lines 51-60 define sections 3-5, 7, 9, and 11 as using LinkedIn job posts/profiles/employees, while `packages/diagnostic-generator/src/sections/stubs.ts` lines 1-4 says those sections are stubs using Companies House fallback citations because LinkedIn deep data is absent. `agent.md` line 220 says bundle code is complete, which buries a load-bearing limitation. Fix: either implement the LinkedIn-backed sections before ratification, or explicitly mark those §3 sections and §8 status as v0 placeholder/degraded outputs.

4. The voice-loader citation is inaccurate. `agent.md` line 193 says `hh_load_recent_edits` takes a single `agent_name` arg and current `context.sh` passes `"diagnostic"` only; actual `voice-loader.sh` lines 223-235 define `[lookback_days] [agent_name]`, and `context.sh` line 160 calls `hh_load_recent_edits 30 "diagnostic"`. Fix: correct the signature claim and the cited implementation description in §7.
