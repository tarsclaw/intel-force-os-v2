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
session id: 019e59f6-ba28-7581-b915-091d273513a4
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

**Status:** Proposed (Day-11 pre-W3-build draft; awaits Q1 LOI + Codex ratification at first render).
**Date:** 2026-05-22.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W3-4 per master brief §8.2 row 1 (anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`.
**Build complexity:** M (1 week) per Ultraplan §8.1 A1.
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

Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY) → exits within 10-15 min per Ultraplan §8.1 A1 turnaround target.

### v1.1+ surfaces (deferred)

- Brain UI "Diagnose Firm" button → triggers via internal API
- Telegram bot command (`@ifos_bot diagnose Charterhouse Partners`)
- Bulk-mode (`ifosctl diagnostic --firm-list firms.csv`) — out of v1.0 scope

---

## §3 — The 12 required sections

Every report MUST contain these 12 sections in order. Gate A enforces section count + per-section citation.

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

**Gate A hard-fails:**

- Fewer than 12 sections present
- Any section with zero citation links
- Section 12 (conversation opener) failing voice-classifier with score < 0.75
- Output exceeds 2000 words OR is under 400 words (length-discipline boundary)

---

## §4 — Workflow

Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.

```
0. Session start — invocation arrives via CLI ifosctl diagnostic
   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
   → hh_decision_trigger("session_start", firm_name + sector_hint)

1. Validate input
   → validate.sh checks: firm name non-empty, sector (if provided) in known list,
     tenant_slug present, voice corpus reachable
   → Gate A: hard-fail if any check fails
   → ESC_INPUT_VALIDATION_FAIL if firm name malformed (new code added to catalogue this round)

2. Companies House lookup (Section 1)
   → companies_house_lookup(firm_name) via Companies House MCP connector
   → cache result for 7 days per gotcha §6 (rate-limit discipline)
   → extract: registration + revenue band + headcount band + directors + share moves
   → ESC_RATE_LIMIT_HIT if Companies House returns 429 (back off 60s, retry once)

3. Online footprint discovery (Section 2)
   → web HEAD + first 200 lines fetch on probable URLs:
     {firm}.com / {firm}.co.uk / linkedin.com/company/{slug}
   → LinkedIn company-page fetch (Proxycurl or similar)
   → record careers page state + last-updated signal

4. Job posts harvest (Sections 3 + 4 + 5 + 7)
   → LinkedIn job posts API (filtered to firm) — up to 50 most recent
   → careers page scrape if accessible
   → extract: sector, role type, location, salary band, tech stack
   → Gotcha §6: store summarised data only; do not retain raw profiles per LinkedIn ToS

5. Director + employee scan (Sections 7 + 11)
   → LinkedIn search for {firm} employees with titles matching head-of-talent / chro / chief people / hiring-manager / talent-acquisition variants
   → record name + URL + tenure + recent activity
   → max 10 named people; deduplicate

6. Pain signal extraction (Section 8)
   → regex pass over careers-page + LinkedIn director posts for:
     - urgency phrases ("rapid growth", "scaling fast", "we need", "tripling", "doubling")
     - frustration phrases (Glassdoor if accessible: "overworked", "burnout", "no support")
     - hiring-pressure phrases ("desperately seeking", "high-priority hire", "must hire by")
   → record each match with quote + source URL + context

7. ICP fit scoring (Section 6)
   → load tenant target_patch from common-target-patch.json
   → score each dimension (sectors / geographies / size_bands / deal_size_band)
   → composite score 0-100 + per-dimension breakdown
   → no external action; compute only

8. Recent activity scan (Section 10)
   → LinkedIn company posts in last 90 days (count + first 100 chars of each)
   → basic Google search for "{firm} announcement OR funding OR acquisition" last 90 days
   → Companies House filing history last 90 days

9. Conversation opener generation (Section 12)
   → LLM prompt: context = §1-§11 of the report (esp. §8 pain signals);
                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
                 constraint = tone rules (hh_load_tone_rules)
   → output 2-3 sentences with at least one evidence anchor
   → voice classifier scores the output against tenant style guide
   → ESC_VOICE_DRIFT if score < 0.75 after 3 retries

10. Markdown report assembly
    → render report from sections 1-12 using Diagnostic-specific template
    → write to /vault/{tenant_slug}/diagnostic-reports/{firm-slug}-{ISO-date}.md
    → hh_decision_output("diagnostic_report", "<path>", "12-section report on {firm}")

11. Operator notification (optional, per --notify-via flag)
    → if telegram: send via primitive 5 with report path + executive summary (first 200 chars)
      → hh_decision_action("operator_notify_telegram", "operator:{chat_id}", payload_hash, payload_preview)
      → action tier per autosend-policy.yaml: green (operator-only Telegram; no customer-facing comms)
    → if no flag: silent completion (consultant checks vault) — no decision-log row needed

12. Session close
    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
    → action tier per autosend-policy.yaml: green (no external send; vault write only)
    → exit code 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.

**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.

**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.

- All 12 sections present in the assembled report (count + heading check) — **v0: hard-fails as specified**
- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section) — **v0: hard-fails as specified**
- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
- Report length 400-2000 words — **v0: hard-fails as specified**
- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit — **v0: warns + flags `validate_check_skipped=true` if firm-domain whitelist absent; W4 polish closes to hard-fail**

### Gate B — Outcome threshold (success metric, not block)

Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `payload.action_type='consultant_feedback'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with a payload action_type marker rather than a new sentinel.

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
| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing | warn | operator_chat_id |
| `ESC_RENDERER_FAILED` | (not Diagnostic's concern; renderer escalation only) | — | — |

Diagnostic does NOT use:

- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention

---

## §7 — Voice + tone constraints

Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:

- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
  - No "I hope this finds you well" or other generic openers
  - No salary or commission anchors in cold outreach
  - Specific evidence anchor required (not generic "great company")
- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies (W3 prerequisites)

Diagnostic build cannot start until ALL of the following are confirmed:

| Dependency | Source | Status |
|---|---|---|
| Renderer + `_shared/` substrate | Day-8 + Round-3 commits | ✅ Ratified (Round 3) |
| Live VPS migration applied | `bash scripts/run-live-migration.sh` | ⏸ Founder action |
| Tenancy audit passes 12 invariants | `bash scripts/run-tenancy-audit.sh` | ⏸ Founder action |
| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
| `target_patch.json` for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI (per tenant-lifecycle.md §2) |
| Voice corpus seeded for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI |
| Companies House MCP connector | Build at W3 start (~1 day) | ⏸ Not built |
| LinkedIn read-only MCP connector (or Proxycurl wrapper) | Build at W3 start (~2 days) | ⏸ Not built |
| Web scraper utility (HEAD + first-N-lines) | Build at W3 start (~0.5 day) | ⏸ Not built |
| `validate.sh` Gate A logic (12-section check) | Build at W3 start (~0.5 day) | ⏸ Not built |
| `context.sh` hydration | Build at W3 start (~0.5 day) | ⏸ Not built |
| 3 fixtures with golden outputs (01-primary + 02-edge-case-no-online-footprint + 99-voice-drift-canary) | Build at W3 start (~1 day) | ⏸ Not built |
| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ✅ Skill built Day 19 (`.codex/ratification/review-agent-bundle.md`) |

**Until ALL ratified items have ⏸ → ✅, W3 build slice does not start.**

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + W3 build slice start.

**Recommended ratification path:** Author the agent.md draft (this document) Day 11 — frees W3 build to focus on the other 5 bundle files + 3 fixtures, not iterating on output contract under W3 deadline pressure. Founder reviews this draft when convenient; refinements drop in commits between Day 11 and W3 start.

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
I’ll verify the cited project files and the current bundle state before giving the ratification verdict.
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Diagnostic — the sales tool
     2	
     3	**Status:** Proposed (Day-11 pre-W3-build draft; awaits Q1 LOI + Codex ratification at first render).
     4	**Date:** 2026-05-22.
     5	**Author:** Founder (Maddox) + Claude Code.
     6	**Build wave:** v1.0 W3-4 per master brief §8.2 row 1 (anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`.
     7	**Build complexity:** M (1 week) per Ultraplan §8.1 A1.
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
    33	Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY) → exits within 10-15 min per Ultraplan §8.1 A1 turnaround target.
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
    45	Every report MUST contain these 12 sections in order. Gate A enforces section count + per-section citation.
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
    62	**Gate A hard-fails:**
    63	
    64	- Fewer than 12 sections present
    65	- Any section with zero citation links
    66	- Section 12 (conversation opener) failing voice-classifier with score < 0.75
    67	- Output exceeds 2000 words OR is under 400 words (length-discipline boundary)
    68	
    69	---
    70	
    71	## §4 — Workflow
    72	
    73	Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
    74	
    75	```
    76	0. Session start — invocation arrives via CLI ifosctl diagnostic
    77	   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
    78	   → hh_decision_trigger("session_start", firm_name + sector_hint)
    79	
    80	1. Validate input
    81	   → validate.sh checks: firm name non-empty, sector (if provided) in known list,
    82	     tenant_slug present, voice corpus reachable
    83	   → Gate A: hard-fail if any check fails
    84	   → ESC_INPUT_VALIDATION_FAIL if firm name malformed (new code added to catalogue this round)
    85	
    86	2. Companies House lookup (Section 1)
    87	   → companies_house_lookup(firm_name) via Companies House MCP connector
    88	   → cache result for 7 days per gotcha §6 (rate-limit discipline)
    89	   → extract: registration + revenue band + headcount band + directors + share moves
    90	   → ESC_RATE_LIMIT_HIT if Companies House returns 429 (back off 60s, retry once)
    91	
    92	3. Online footprint discovery (Section 2)
    93	   → web HEAD + first 200 lines fetch on probable URLs:
    94	     {firm}.com / {firm}.co.uk / linkedin.com/company/{slug}
    95	   → LinkedIn company-page fetch (Proxycurl or similar)
    96	   → record careers page state + last-updated signal
    97	
    98	4. Job posts harvest (Sections 3 + 4 + 5 + 7)
    99	   → LinkedIn job posts API (filtered to firm) — up to 50 most recent
   100	   → careers page scrape if accessible
   101	   → extract: sector, role type, location, salary band, tech stack
   102	   → Gotcha §6: store summarised data only; do not retain raw profiles per LinkedIn ToS
   103	
   104	5. Director + employee scan (Sections 7 + 11)
   105	   → LinkedIn search for {firm} employees with titles matching head-of-talent / chro / chief people / hiring-manager / talent-acquisition variants
   106	   → record name + URL + tenure + recent activity
   107	   → max 10 named people; deduplicate
   108	
   109	6. Pain signal extraction (Section 8)
   110	   → regex pass over careers-page + LinkedIn director posts for:
   111	     - urgency phrases ("rapid growth", "scaling fast", "we need", "tripling", "doubling")
   112	     - frustration phrases (Glassdoor if accessible: "overworked", "burnout", "no support")
   113	     - hiring-pressure phrases ("desperately seeking", "high-priority hire", "must hire by")
   114	   → record each match with quote + source URL + context
   115	
   116	7. ICP fit scoring (Section 6)
   117	   → load tenant target_patch from common-target-patch.json
   118	   → score each dimension (sectors / geographies / size_bands / deal_size_band)
   119	   → composite score 0-100 + per-dimension breakdown
   120	   → no external action; compute only
   121	
   122	8. Recent activity scan (Section 10)
   123	   → LinkedIn company posts in last 90 days (count + first 100 chars of each)
   124	   → basic Google search for "{firm} announcement OR funding OR acquisition" last 90 days
   125	   → Companies House filing history last 90 days
   126	
   127	9. Conversation opener generation (Section 12)
   128	   → LLM prompt: context = §1-§11 of the report (esp. §8 pain signals);
   129	                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
   130	                 constraint = tone rules (hh_load_tone_rules)
   131	   → output 2-3 sentences with at least one evidence anchor
   132	   → voice classifier scores the output against tenant style guide
   133	   → ESC_VOICE_DRIFT if score < 0.75 after 3 retries
   134	
   135	10. Markdown report assembly
   136	    → render report from sections 1-12 using Diagnostic-specific template
   137	    → write to /vault/{tenant_slug}/diagnostic-reports/{firm-slug}-{ISO-date}.md
   138	    → hh_decision_output("diagnostic_report", "<path>", "12-section report on {firm}")
   139	
   140	11. Operator notification (optional, per --notify-via flag)
   141	    → if telegram: send via primitive 5 with report path + executive summary (first 200 chars)
   142	      → hh_decision_action("operator_notify_telegram", "operator:{chat_id}", payload_hash, payload_preview)
   143	      → action tier per autosend-policy.yaml: green (operator-only Telegram; no customer-facing comms)
   144	    → if no flag: silent completion (consultant checks vault) — no decision-log row needed
   145	
   146	12. Session close
   147	    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
   148	    → action tier per autosend-policy.yaml: green (no external send; vault write only)
   149	    → exit code 0
   150	```
   151	
   152	---
   153	
   154	## §5 — Gates
   155	
   156	### Gate A — validate.sh (hard-fail before action)
   157	
   158	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
   159	
   160	**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
   161	
   162	**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
   163	
   164	- All 12 sections present in the assembled report (count + heading check) — **v0: hard-fails as specified**
   165	- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section) — **v0: hard-fails as specified**
   166	- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
   167	- Report length 400-2000 words — **v0: hard-fails as specified**
   168	- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
   169	- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit — **v0: warns + flags `validate_check_skipped=true` if firm-domain whitelist absent; W4 polish closes to hard-fail**
   170	
   171	### Gate B — Outcome threshold (success metric, not block)
   172	
   173	Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `payload.action_type='consultant_feedback'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with a payload action_type marker rather than a new sentinel.
   174	
   175	Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
   176	
   177	---
   178	
   179	## §6 — Escalation codes
   180	
   181	Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:
   182	
   183	| Code | Trigger | Severity | Routing |
   184	|---|---|---|---|
   185	| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
   186	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
   187	| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
   188	| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
   189	| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing | warn | operator_chat_id |
   190	| `ESC_RENDERER_FAILED` | (not Diagnostic's concern; renderer escalation only) | — | — |
   191	
   192	Diagnostic does NOT use:
   193	
   194	- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
   195	- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
   196	- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
   197	
   198	---
   199	
   200	## §7 — Voice + tone constraints
   201	
   202	Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   203	
   204	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
   205	  - No "I hope this finds you well" or other generic openers
   206	  - No salary or commission anchors in cold outreach
   207	  - Specific evidence anchor required (not generic "great company")
   208	- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
   209	- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly.
   210	
   211	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   212	
   213	---
   214	
   215	## §8 — Build dependencies (W3 prerequisites)
   216	
   217	Diagnostic build cannot start until ALL of the following are confirmed:
   218	
   219	| Dependency | Source | Status |
   220	|---|---|---|
   221	| Renderer + `_shared/` substrate | Day-8 + Round-3 commits | ✅ Ratified (Round 3) |
   222	| Live VPS migration applied | `bash scripts/run-live-migration.sh` | ⏸ Founder action |
   223	| Tenancy audit passes 12 invariants | `bash scripts/run-tenancy-audit.sh` | ⏸ Founder action |
   224	| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
   225	| `target_patch.json` for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI (per tenant-lifecycle.md §2) |
   226	| Voice corpus seeded for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI |
   227	| Companies House MCP connector | Build at W3 start (~1 day) | ⏸ Not built |
   228	| LinkedIn read-only MCP connector (or Proxycurl wrapper) | Build at W3 start (~2 days) | ⏸ Not built |
   229	| Web scraper utility (HEAD + first-N-lines) | Build at W3 start (~0.5 day) | ⏸ Not built |
   230	| `validate.sh` Gate A logic (12-section check) | Build at W3 start (~0.5 day) | ⏸ Not built |
   231	| `context.sh` hydration | Build at W3 start (~0.5 day) | ⏸ Not built |
   232	| 3 fixtures with golden outputs (01-primary + 02-edge-case-no-online-footprint + 99-voice-drift-canary) | Build at W3 start (~1 day) | ⏸ Not built |
   233	| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ✅ Skill built Day 19 (`.codex/ratification/review-agent-bundle.md`) |
   234	
   235	**Until ALL ratified items have ⏸ → ✅, W3 build slice does not start.**
   236	
   237	---
   238	
   239	## §9 — Status + open questions
   240	
   241	**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + W3 build slice start.
   242	
   243	**Recommended ratification path:** Author the agent.md draft (this document) Day 11 — frees W3 build to focus on the other 5 bundle files + 3 fixtures, not iterating on output contract under W3 deadline pressure. Founder reviews this draft when convenient; refinements drop in commits between Day 11 and W3 start.
   244	
   245	### Open questions for founder review
   246	
   247	| # | Question | Resolution path |
   248	|---|---|---|
   249	| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
   250	| Q2 | Should §11 (decision-maker map) be a separate section OR rolled into §3 + §4 + §5 + §7 as a sub-row? Currently named as a separate section. | Founder review at agent.md ratification. |
   251	| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | Resolved at W3 start before Companies House + LinkedIn MCP connectors authored. Founder + Claude decide together. |
   252	| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
   253	| Q5 | What's the "firm-slug" canonical form for the output filename? Companies House registration number? URL-slugified firm name? | Recommend Companies House number for stability; canonical-slug fallback for non-UK firms (v1.1+). |
   254	| Q6 | Should §10 (recent activity) include Glassdoor reviews? ToS implications. | Per gotcha §6 below: caution; default OFF for v1.0; explicit founder enable for v1.1+. |
   255	
   256	### Gotchas (carried forward from Ultraplan §8.1 A1)
   257	
   258	1. **LinkedIn ToS — cannot store profile data beyond the audit.** Profile fetches are cached only for the duration of the report generation (typ. 10-15 min). After report writes to vault, raw profile data is dropped from agent memory + no persistence in Postgres.
   259	2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
   260	3. **Glassdoor scraping — uncertain ToS compatibility.** Default OFF for v1.0. Per Q6 above.

exec
/bin/zsh -lc 'rg -n "ESC_VOICE_DRIFT|ESC_PII_LEAKAGE_RISK|ESC_RATE_LIMIT_HIT|ESC_INPUT_VALIDATION_FAIL|ESC_AGENT_OUTPUT_SHAPE|ESC_RENDERER_FAILED|ESC_VOICE_DRIFT_TENANT|ESC_VAULT|ESC_AUTOSEND" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
24:The Telegram message is templated via `common-notifications.json` `escalation_routes.<ESC_CODE>` if present; otherwise routed to `operator_chat_id`. `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` additionally CCs `ifos_oncall_chat_id`.
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
108:#### `ESC_RENDERER_FAILED`
115:- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
120:#### `ESC_VOICE_DRIFT`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
201:#### `ESC_VAULT_CONCURRENCY`
203:- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
209:#### `ESC_VAULT_RENAME_RACE`
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
342:- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
475:2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)

exec
/bin/zsh -lc 'rg -n "diagnostic|diagnostic_report_render|consultant_feedback|telegram|green|Tier|tier|operator" autosend-safety-policy.yaml agents/_shared/voice-loader.sh docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md 2>/dev/null' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:3:**Status:** Accepted (2026-05-24, Day 19; founder-arbitrated under master brief §10.3 step 5 + bilateral-disposition Cat-1 framework; Codex 10 rounds REJECTED with last-mile mechanical findings only after R7's architectural split resolved Rule 4 + Rule 2 substantively. R7 finding was the structural breakthrough — Tier 2 moved out of Gate A entirely; R8-R10 findings are cross-reference sync mechanics, not architectural objections. Per `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 5: documented Codex disagreement, founder-arbitrated Accepted)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:7:**Driven by:** `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ — Codex re-flags Cat-1 every round because bilateral-disposition docs are not auto-trusted as in-band Gate A acceptances; the canonical authoritative path for upstream-spec amendments is an ADR
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:19:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:21:The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:23:(Voice classifier ≥ 0.75 and PII boundary checks are also Gate A requirements per the same v0 contract. Their v0 implementation in `validate.sh` is partial — `validate.sh` warns and emits `validate_check_skipped=true` when the voice-classifier URL is unreachable or the firm-domain whitelist is absent, rather than hard-failing; W4-polish closes these to hard-fail per `agents/recruitment/diagnostic/agent.md` §5 honesty note. These warn-only-paths exist in v0 but are not affected by this ADR; this ADR addresses ONLY the "no claims unsupported by source data" clause from line 496.)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:25:This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:43:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`. **The per-section citation subcheck has no warn-only paths** (full implementation; hard-fail at v0). This satisfies Rule 4 (Quality gates before features) for the per-section subcheck — Gate A's section-citation requirement is unambiguously hard-fail; the upstream ULTRAPLAN clause "no claims unsupported by source data" is interpreted at Gate A as "every section has at least one evidence link", consistent with the implementation.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:74:> - **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:83:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:103:- `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (this file) lands as Proposed
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:104:- `agents/recruitment/diagnostic/validate.sh` retains current per-section enforcement (no implementation change)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:108:- `agents/recruitment/diagnostic/agent.md` §1 + §5 framing edited to explicitly reference ADR-006 (Tier 1 hard-fail / Tier 2 W4 polish per-claim spot-check). NOT yet present in agent.md as of this commit; lands in the post-ratify commit.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:118:- Per-claim spot-check pipeline lands as Tier 2 validate.sh extension
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:125:- `agents/recruitment/diagnostic/agent.md` §1 → will cite "Per ADR-006, Gate A is two-tier..."
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:126:- `agents/recruitment/diagnostic/agent.md` §5 → will cite "Tier 1 hard-fail (per-section); Tier 2 W4 polish (per-claim spot-check) per ADR-006"
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:127:- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Phase 4 Cat-ζ section → references ADR-006 as the closure mechanism (already cross-referenced in commit `1f8c92f`)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:138:| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:6:**Artefact:** `agents/recruitment/diagnostic/agent.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:8:- Round 4: `logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:9:- Round 5: `logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:15:Week 3 goal at `docs/operations/goal-week-3-polish-and-scaffold.md` Step 7 (Codex Round 4 Phase 1) ratified `agents/recruitment/diagnostic/agent.md`. Codex found 4 issues; mechanical remediation applied (commit `6e0cb86`); Round 5 re-ratification found 5 new issues — 2 re-raises (Codex disagreed with my remediation framing), 3 new findings not visible at Round 4.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:35:Option C — **Hybrid:** v0 Gate A = per-section (current); Gate B (post-launch quality signal) = per-claim spot-check sampling. Document this two-tier policy explicitly.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:41:**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:43:**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:61:### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:69:Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:91:3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:128:2. **Workflow steps missing decision-log calls** — most agent.md files have at least one Step (notification, operator alert, status update) that produces side-effects without `hh_decision_*` call. Same disposition as Diagnostic Issue 2 — mechanical fix during W4-13 build slices when cycle.sh is implemented.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:130:4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:159:1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:214:1. `operator_notify_telegram` + `janitor_run_complete` are unregistered hh_decision_action types — hook-helpers fails them to red via `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`. (Found because my Round-6 commit added those calls without registering them.)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:259:- Cat-4 (sentinel hygiene): Diagnostic `_consultant_feedback` → agent_name='diagnostic' + payload.action_type
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:261:- Cross-section consistency: removed (new — W-X catalogue add) annotations; ESC_AUTOSEND_BLOCKED kept red-tier-only; ESC_SCHEMA_VIOLATION kept schema-field-violation-only; ESC_VOICE_DRIFT_TENANT removed from direct firing across all agents; ESC_AUTOSEND_YELLOW_SPOT_CHECK → ESC_AUTOSEND_SAMPLED_SPOT_CHECK
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:364:- `cycle.sh` adds `hh_decision_action("operator_notify_telegram", ...)` call before Step 14 Telegram send
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:387:5. §6 says only one action_type but cycle.sh now has operator_notify_telegram (Round-9 introduced by Cat-δ commit) — Cat-α; align §6

codex
I’ve got the artefact lines and initial citation hits. A few claims depend on source catalogues and live sibling files, so I’m checking those exact references now rather than relying on the pasted text.
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '261,340p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   261	
   262	---
   263	
   264	## §10 — When this document ratifies
   265	
   266	Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
   267	
   268	Status flips to Accepted when:
   269	- Codex Round-3+ ratifies the full bundle
   270	- Founder approves §3's 12-section list as canonical
   271	- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   272	- Gate B baseline measurement begins (30% target; 4-week window)
   273	
   274	Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.
   275	
   276	*End of Diagnostic agent.md draft.*

exec
/bin/zsh -lc 'rg --files agents/recruitment/diagnostic agents/_shared | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/README.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
agents/_shared/voice-loader.sh
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
/bin/zsh -lc "rg --files | rg '("'^|/)(master|MASTER|ULTRAPLAN|ultraplan|sequencing-target|autosend-safety-policy|vertical-schema|common-voice|common-target-patch|v1'"\\.0-kill-criterion|tenant-lifecycle).*'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
packages/agents-runtime/_shared/common-voice.json
packages/agents-runtime/_shared/common-target-patch.json
docs/runbooks/tenant-lifecycle.md
docs/specs/ULTRAPLAN.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/sequencing-target.md
legacy/v1/MASTER-INDEX.md

exec
/bin/zsh -lc 'rg -n "hh_decision_|operator_notify_telegram|diagnostic_report_render|diagnostic_report|consultant_feedback|autosend|action_type" agents/_shared/hook-helpers.sh autosend-safety-policy.yaml agents/recruitment/diagnostic/validate.sh agents/recruitment/diagnostic/cycle.sh 2>/dev/null' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
agents/recruitment/diagnostic/validate.sh:259:  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
agents/recruitment/diagnostic/cycle.sh:102:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:156:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:166:hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:182:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:198:    # operator_notify_telegram is green-tier per autosend-policy.yaml so the
agents/recruitment/diagnostic/cycle.sh:205:    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
agents/_shared/hook-helpers.sh:3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:31:_HH_POLICY_FILE="${HH_POLICY_FILE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/autosend-policy.yaml}"
agents/_shared/hook-helpers.sh:163:# 3 hh_decision_* contracts (master brief §8.1 Change 2)
agents/_shared/hook-helpers.sh:166:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:168:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:180:hh_decision_output() {
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:193:hh_decision_action() {
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
agents/_shared/hook-helpers.sh:259:# 7 autosend_* helpers (autosend-safety-policy §4)
agents/_shared/hook-helpers.sh:262:# autosend_policy_lookup <action_type>
agents/_shared/hook-helpers.sh:264:# 1 if action_type missing from policy file.
agents/_shared/hook-helpers.sh:265:autosend_policy_lookup() {
agents/_shared/hook-helpers.sh:266:  local action_type="$1"
agents/_shared/hook-helpers.sh:268:    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
agents/_shared/hook-helpers.sh:271:  # YAML lookup via awk — finds the action_type key, then reads tier:
agents/_shared/hook-helpers.sh:274:  tier=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:285:# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:287:# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
agents/_shared/hook-helpers.sh:289:autosend_apply_tenant_override() {
agents/_shared/hook-helpers.sh:291:  local action_type="$2"
agents/_shared/hook-helpers.sh:300:  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
agents/_shared/hook-helpers.sh:307:  override=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:322:    printf 'autosend_apply_tenant_override: refusing to demote %s → %s for %s/%s\n' \
agents/_shared/hook-helpers.sh:323:      "${base_tier}" "${override}" "${tenant_slug}" "${action_type}" >&2
agents/_shared/hook-helpers.sh:329:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:330:# Emits the standard autosend decision_log row with payload.tier set.
agents/_shared/hook-helpers.sh:331:autosend_emit_decision_log() {
agents/_shared/hook-helpers.sh:334:  local action_type="$3"
agents/_shared/hook-helpers.sh:341:  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
agents/_shared/hook-helpers.sh:343:    "$(_hh_json_escape "${action_type}")" \
agents/_shared/hook-helpers.sh:353:# autosend_escalate <ESC_CODE> [<key=value>...]
agents/_shared/hook-helpers.sh:357:autosend_escalate() {
agents/_shared/hook-helpers.sh:362:    printf 'autosend_escalate: unknown ESC code: %s\n' "${code}" >&2
agents/_shared/hook-helpers.sh:386:  # signal. Dispatcher (autosend-syncer) reads recent gating_failed rows and
agents/_shared/hook-helpers.sh:390:# autosend_should_sample <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:392:# 1 otherwise. Sample rate read from autosend-policy.yaml (sample_rate field);
agents/_shared/hook-helpers.sh:394:autosend_should_sample() {
agents/_shared/hook-helpers.sh:395:  local action_type="$1"
agents/_shared/hook-helpers.sh:398:  rate=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:416:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
agents/_shared/hook-helpers.sh:419:autosend_spot_check_enqueue() {
agents/_shared/hook-helpers.sh:420:  local action_type="$1"
agents/_shared/hook-helpers.sh:428:    printf 'autosend_spot_check_enqueue: cannot mkdir %s\n' "${spot_dir}" >&2
agents/_shared/hook-helpers.sh:434:  local outfile="${spot_dir}/${timestamp}-${action_type}-${payload_hash:0:12}.md"
agents/_shared/hook-helpers.sh:441:    printf '# Spot check — %s\n\n' "${action_type}"
agents/_shared/hook-helpers.sh:451:# autosend_await_approval <action_type> <target> <payload_hash>
agents/_shared/hook-helpers.sh:457:autosend_await_approval() {
agents/_shared/hook-helpers.sh:458:  local action_type="$1"
agents/_shared/hook-helpers.sh:463:  timeout_iso=$(awk -v key="${action_type}" '
agents/_shared/hook-helpers.sh:488:    printf 'action_type=%s\n' "${action_type}"
agents/_shared/hook-helpers.sh:511:        autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:539:  autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \

exec
/bin/zsh -lc "rg -n \"§8\\.2|W3|Diagnostic|diagnostic|Week 3|8\\.2|A1|12|required sections|30%|10-15|no claims unsupported|LinkedIn ToS|600 requests\" docs/specs/ULTRAPLAN.md docs/decisions/sequencing-target.md docs/decisions/v1.0-kill-criterion.md docs/runbooks/tenant-lifecycle.md docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
docs/verticals/recruitment/vertical-schema.yaml:479:        enum: [pre_start, week_1, month_1, month_3, month_6, month_12, month_24, completed]
docs/verticals/recruitment/vertical-schema.yaml:671:  Diagnostic:
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:809:    status: DEFERRED to Week 3-4
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:861:    v0_1_decision: placement.lifecycle_stage enum is hardcoded to Product Spec §2.2 R7 values (pre_start, week_1, month_1, month_3, month_6, month_12, month_24, completed).
docs/verticals/recruitment/vertical-schema.yaml:862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.
docs/verticals/recruitment/vertical-schema.yaml:866:  Q12_source_field_schema:
docs/verticals/recruitment/vertical-schema.yaml:886:      Structural cut. 8 entities + 10 relationships + agent-access matrix + Bullhorn mapping. Minimal field sets (10-20 per entity). 12 open questions catalogued (Q1, Q4 resolved at Day 6; Q2, Q3, Q5-Q12 deferred with named triggers).
docs/verticals/recruitment/vertical-schema.yaml:890:    expected_date: post Week 3-4 (after Janitor build verifies against real Bullhorn data)
docs/decisions/v1.0-kill-criterion.md:6:**Master brief §:** §6 Day 5 (line 486) + §12 Risk Register + §1 Rule 5 (honest signal before optimistic projection)
docs/decisions/v1.0-kill-criterion.md:61:### Trigger 2 — DIAGNOSTIC-NO-RENDER-W3 (KILL)
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:69:**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:178:**Source:** Master brief §12 Risk #1; Day-1 audit results in `cortexos-primitive-status.md` (primitive 1 PTY/PM2 is "shipped but flaky"; primitives 3 + 4 confirmed "shipped and tested" but field evidence may diverge).
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:21:| A1 | Diagnostic | 3-4 | LinkedIn + Companies House + scrape | "Sales tool — needed before any other agent matters" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:32:- **A. First agent.** Which agent ships first in Week 3-4? Anchors the renderer (ADR-003) + `_shared/` helpers (Week-1-2 prereqs from ADR-002) + Postgres `decision_log` (Day 4 Week 0) end-to-end test. Affects how risk surfaces — first agent is the smoke test for every substrate dependency.
docs/decisions/sequencing-target.md:40:**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
docs/decisions/sequencing-target.md:46:The Day-7 single-sentence test (master brief §6 Day 7 / Ultraplan §12) doesn't directly test sequencing — but Q4 ("Have we scoped the Agent Bundle v2 refactor and is the work <5 days?") and the Week-0 deliverable list at Ultraplan §9 line 737-741 both assume a sequenced plan exists. The Day 7 review surfaces this document for Codex ratification.
docs/decisions/sequencing-target.md:57:| 4 | **Commercial value** | Whether the agent's output is demoable to a design partner / first paying customer per Product Spec §2.2 R-rows | Earlier commercial-value agents accelerate the first-pilot conversion (Ultraplan §9 line 725 target Week 12); but commercial-value agents are typically the more complex ones, conflicting with criterion 1 |
docs/decisions/sequencing-target.md:65:Per master brief §12 / Ultraplan §10 row #2 (the four-risks-that-kill-v1.0 table), the **documented v1.0 scope-cut contingency** is verbatim:
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:92:### 2.1 — A1 Diagnostic
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:99:| 4. Commercial value | **Medium** | Internal sales tool per Product Spec §2.2 R13 ("Not on the customer pricing card"). Drives qualified discovery-call pipeline. Demoable to a prospect but not the closing demo. Ultraplan §8.1 line 499 Gate B target: "≥30% of diagnostics produced lead to a discovery call booked" |
docs/decisions/sequencing-target.md:100:| 5. Dependencies on other agents | **None** | Standalone. No upstream agent dependency; no downstream agent consumes Diagnostic output |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:111:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:163:| 1. Implementation simplicity | **High complexity (Low simplicity)** | Ultraplan §8.1 line 568 estimate **XL (4 weeks)** — biggest v1.0 agent. Lifecycle state machine across 24+ months of candidate post-placement (week-1 / month-1 / month-3 / month-6 / month-12 / month-24 nurture per Product Spec §2.2 R7). Six-plus comms types (acknowledgement, prep, debrief, rejection, placement, multi-stage check-ins) |
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:181:W3-4: Diagnostic (A1)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:192:- W4: Risk #5 (renderer) — Diagnostic first user. Reduction trigger fires (High → Medium per RISK-REGISTER #5).
docs/decisions/sequencing-target.md:202:**Hire-#1-onboarding fit:** **Excellent.** Cash Conductor at W7-8 matches Ultraplan §9 line 766 verbatim. Hire #1 (assumed W7) takes Cash Conductor's three-accounting-API + Open-Banking work as first sprint — well-scoped, independent of the Bullhorn track founder has been driving solo W3-W6.
docs/decisions/sequencing-target.md:207:W3-4: Diagnostic (A1) — substrate proof, non-negotiable
docs/decisions/sequencing-target.md:212:W12-13: Cash Conductor (A4)
docs/decisions/sequencing-target.md:215:**Why this ordering:** Get the flagship demoable agent (Concierge) live earliest to accelerate first-pilot conversion per Ultraplan §9 line 725 target Week 12.
docs/decisions/sequencing-target.md:220:2. **Risk #1 derisk pushed to W12-13.** Cash Conductor's Tier-1 Primitives 1+4+5 first-exercise happens after Concierge's 4-week XL build. If Risk #1 materialises at W12-13, the entire v1.0 production-critical surface is at risk with no Hire-#1-takeover slot for Cash Conductor.
docs/decisions/sequencing-target.md:221:3. **Hire-#1 anchor broken.** Cash Conductor at W12-13 means Hire #1 (W7 start) has nothing to take on for 5 weeks. Hire #1's first sprint becomes "help with Concierge" — wrong scope for an onboarding sprint (Concierge is XL and founder-led).
docs/decisions/sequencing-target.md:228:W3-4: Diagnostic (A1)
docs/decisions/sequencing-target.md:233:W12:  Sourcing Scout (A5)
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:255:| 4. Commercial value | Tied (Diagnostic substrate, then flagship Concierge last; closing demo at W12-13 per Ultraplan §9 line 781) | Wins on raw timing (Concierge W5-8 demoable earlier) — but loses on substrate quality (Concierge ships with degraded Notes-for-context) | Tied — Concierge W6-9 marginally earlier than Alpha but with same substrate gaps as Beta |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:281:| 1 | W3-4 | **Diagnostic** (A1) | Substrate-proof agent; first renderer production render per ADR-003 design §5.2 |
docs/decisions/sequencing-target.md:288:**Status: Accepted** as the v1.0 plan of record. Binds Week 3-13 build cadence subject to §4.3 revisit conditions.
docs/decisions/sequencing-target.md:294:The Hire-#1 anchor at W7-8 per Ultraplan §9 line 766 is load-bearing — Cash Conductor's three-accounting-API + Open-Banking work is well-scoped for Hire #1's first sprint. Beta and Gamma both displace Cash Conductor past W7-8 (W12-13 and W11 respectively), leaving Hire #1 with no first-sprint scope per §3.2 and §3.3 structural defects.
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:326:- The substrate-first principle (Diagnostic W3-4 before any Bullhorn-touching agent).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:395:### 6.2 — For Week 3 (Diagnostic build start)
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:399:- Smallest viable Diagnostic exercising renderer + `_shared/` + `decision_log` end-to-end per §2.1 substrate-exercise column.
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:401:- Output: 12-page audit per Ultraplan §8.1 line 489-496 against a real prospect's public footprint.
docs/decisions/sequencing-target.md:402:- First production render lands W4 per ADR-003 design §5.2 line "First production render is the Diagnostic agent at Week 4."
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:414:Diagnostic W3-W4 build window is the first production renderer exercise per ADR-003 design §5.2. The reduction-trigger cascade per `docs/RISK-REGISTER.md` Risk #5 fires:
docs/decisions/sequencing-target.md:417:- W4 Diagnostic first-render-clean → **Medium** (renderer code proven against one production bundle).
docs/decisions/sequencing-target.md:420:No new discrepancy to surface — earlier draft concern about W3-vs-W4 framing resolved per §6.2.
docs/decisions/sequencing-target.md:438:- **Diagnostic doesn't render by end of W3** (Risk #5 unmitigated; renderer impl Week 1-2 didn't ship)
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:494:| W3 vs W4 framing | §6.2 + §6.4 | Build-window-vs-completion-week distinction: Diagnostic build W3-W4, first production render W4. Not a true discrepancy. |
docs/decisions/sequencing-target.md:507:| Substrate readiness for W3 Diagnostic build (renderer + `_shared/` + `decision_log`) | Claude Code | End of W2 | Already tracked from ADR-002 + ADR-003 |
docs/decisions/sequencing-target.md:508:| Day 2 commercial conversations land by start of W4 (Risk #2 reduction triggers) | Founder | Sunday-Monday outreach; resolved by end of W3 | Already tracked from `bullhorn-integration-path.md` §1.3 |
docs/decisions/sequencing-target.md:520:| Diagnostic W3 build start (vs W4 first render) | If renderer impl slips past end of W2, Diagnostic build start slips correspondingly |
docs/specs/ULTRAPLAN.md:97:- The Diagnostic agent (sales tool)
docs/specs/ULTRAPLAN.md:198:- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
docs/specs/ULTRAPLAN.md:265:4. Run a single dry-run agent invocation (the Diagnostic) to validate the path end-to-end.
docs/specs/ULTRAPLAN.md:281:- Vault: nightly snapshot via Restic to S3-compatible storage (UK region) with 30 days of dailies, 12 months of monthlies.
docs/specs/ULTRAPLAN.md:417:| Inbound Triage | 95% of inbounds get response within 60s; consultant-edit rate <30% on auto-sent categories | Decision-log query over 30 days, per tenant |
docs/specs/ULTRAPLAN.md:418:| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
docs/specs/ULTRAPLAN.md:419:| Client Hunter | ≥ 20 BD opportunities/month produced with ≥ 30% receiving consultant action | Decision-log query; action defined as "approved-and-sent" |
docs/specs/ULTRAPLAN.md:487:#### A1. The Diagnostic — the sales tool
docs/specs/ULTRAPLAN.md:496:- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
docs/specs/ULTRAPLAN.md:497:- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
docs/specs/ULTRAPLAN.md:499:- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.
docs/specs/ULTRAPLAN.md:539:- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
docs/specs/ULTRAPLAN.md:571:### 8.2 v1.1 agents (seven, in build order)
docs/specs/ULTRAPLAN.md:583:- **Gate B target:** 95% within 60s; consultant edit-rate <30% on auto-sent categories; <2% wrong-classification rate
docs/specs/ULTRAPLAN.md:605:#### A10. Competitor Interception (2 weeks)
docs/specs/ULTRAPLAN.md:619:#### A11. The Night Sourcer (2 weeks)
docs/specs/ULTRAPLAN.md:628:- **Gate A:** 8–12 candidates per brief; each has rationale ≥ 50 words; drafts for each are valid (Gate A on the draft itself); no rate-limit exceptions raised
docs/specs/ULTRAPLAN.md:633:#### A12. T5 Supply Chain Auditor (parallel to v1.1 front-office work)
docs/specs/ULTRAPLAN.md:642:- **Gate A:** every red-flag pattern (e.g., FCSA accreditation lapsed, complaint volume spike, director change) produces an alert within 24 hours; quarterly audit pack contains all required sections
docs/specs/ULTRAPLAN.md:647:#### A13. T3 Compliance Watchtower (parallel to v1.1 front-office work)
docs/specs/ULTRAPLAN.md:685:| Diagnostic | ✓ | | | | ✓ | ✓ | | | | | Web scraper |
docs/specs/ULTRAPLAN.md:725:- The first pilot lands at week 10 (mid-July 2026) for a 2-week pilot, converting to paid week 12.
docs/specs/ULTRAPLAN.md:750:### Weeks 3–4 — Bullhorn + Diagnostic
docs/specs/ULTRAPLAN.md:752:- Week 3: Bullhorn MCP server build (auth, read endpoints, write endpoints, webhook subscription)
docs/specs/ULTRAPLAN.md:753:- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint
docs/specs/ULTRAPLAN.md:755:Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact.
docs/specs/ULTRAPLAN.md:801:6. Concierge's deep nurture sequence (months 12 and 24 check-ins) — can be added in v1.1
docs/specs/ULTRAPLAN.md:828:| 12 | A pilot churns within 90 days | Medium | High | Gate B failure at month 2 OR Gate C reject rate >10% sustained 2 weeks | Engineer pairs with tenant; if not recoverable by month 3, churn-with-grace and capture learnings |
docs/specs/ULTRAPLAN.md:865:- [ ] v1.0 kill criterion documented (Q12). **Owner:** Maddox. **Output:** `v1-kill-criterion.md`.
docs/specs/ULTRAPLAN.md:885:## 12. The single-sentence test
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:357:      Recorded but not actively driving retraining in v1.0 (Brain UI v1.1 surfaces the queue; v2.0 LoRA pipeline reads it). v0.2 establishes the linkage schema so production data accumulates cleanly from W3 forward.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:393:  Q12_tone_rule_severity_block_path:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/runbooks/tenant-lifecycle.md:4:**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation)
docs/runbooks/tenant-lifecycle.md:6:**Companion:** `docs/architecture/tenancy-invariants.md` (the 12 invariants every state must preserve).
docs/runbooks/tenant-lifecycle.md:38:Four states + one self-loop (Migrate). Every state transition preserves the 12 tenancy invariants from `tenancy-invariants.md`.
docs/runbooks/tenant-lifecycle.md:112:for agent in diagnostic; do
docs/runbooks/tenant-lifecycle.md:118:# Expect: all 12 invariants pass; new tenant appears in T1-T3 enumerations
docs/runbooks/tenant-lifecycle.md:129:- New tenant passes all 12 tenancy invariants per `bash scripts/run-tenancy-audit.sh`
docs/runbooks/tenant-lifecycle.md:273:- Tenant slug freed for future reuse (after 12-month cooling period to avoid confusion with legacy data — recommended, not enforced)
docs/runbooks/tenant-lifecycle.md:293:bash scripts/run-tenancy-audit.sh   # verify all 12 invariants still hold
docs/runbooks/tenant-lifecycle.md:336:Regardless of state transition, the 12 tenancy invariants from `docs/architecture/tenancy-invariants.md` MUST hold:
docs/runbooks/tenant-lifecycle.md:345:- **T12**: `_shared/` helpers tenant-agnostic (compile-time invariant; not state-dependent)
docs/runbooks/tenant-lifecycle.md:402:- `docs/architecture/tenancy-invariants.md` (the 12 invariants every state preserves)

exec
/bin/zsh -lc 'rg -n "diagnostic_report_render|operator_notify_telegram|consultant_feedback|diagnostic_draft|validate_gate_a_fail|tier:|green|yellow|orange|red" agents/_shared/autosend-policy.yaml docs/decisions/autosend-safety-policy.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:4:# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
agents/_shared/autosend-policy.yaml:8:# 41 v1.0 action_types: 13 green + 10 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:10:#   tier            green|yellow|orange|red
agents/_shared/autosend-policy.yaml:11:#   agent           v1.0 owning agent (or "all" if cross-cutting red rule)
agents/_shared/autosend-policy.yaml:13:#   sample_rate     yellow only: 1-in-N for spot-check sampling
agents/_shared/autosend-policy.yaml:14:#   block_reason    red only: enum from §3 red table column 2
agents/_shared/autosend-policy.yaml:15:#   timeout         orange only: ISO-8601 duration; default PT4H if absent
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/autosend-policy.yaml:30:    tier: green
agents/_shared/autosend-policy.yaml:36:    tier: green
agents/_shared/autosend-policy.yaml:42:    tier: green
agents/_shared/autosend-policy.yaml:48:    tier: green
agents/_shared/autosend-policy.yaml:54:    tier: green
agents/_shared/autosend-policy.yaml:60:    tier: green
agents/_shared/autosend-policy.yaml:65:  operator_notify_telegram:
agents/_shared/autosend-policy.yaml:66:    tier: green
agents/_shared/autosend-policy.yaml:72:    tier: green
agents/_shared/autosend-policy.yaml:78:    tier: green
agents/_shared/autosend-policy.yaml:84:    tier: green
agents/_shared/autosend-policy.yaml:90:    tier: green
agents/_shared/autosend-policy.yaml:96:    tier: green
agents/_shared/autosend-policy.yaml:98:    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
agents/_shared/autosend-policy.yaml:102:    tier: green
agents/_shared/autosend-policy.yaml:112:    tier: yellow
agents/_shared/autosend-policy.yaml:119:    tier: yellow
agents/_shared/autosend-policy.yaml:126:    tier: yellow
agents/_shared/autosend-policy.yaml:133:    tier: yellow
agents/_shared/autosend-policy.yaml:140:    tier: yellow
agents/_shared/autosend-policy.yaml:147:    tier: yellow
agents/_shared/autosend-policy.yaml:154:    tier: yellow
agents/_shared/autosend-policy.yaml:161:    tier: yellow
agents/_shared/autosend-policy.yaml:164:    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
agents/_shared/autosend-policy.yaml:168:    tier: yellow
agents/_shared/autosend-policy.yaml:175:    tier: yellow
agents/_shared/autosend-policy.yaml:178:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
agents/_shared/autosend-policy.yaml:186:    tier: orange
agents/_shared/autosend-policy.yaml:194:    tier: orange
agents/_shared/autosend-policy.yaml:201:    tier: orange
agents/_shared/autosend-policy.yaml:208:    tier: orange
agents/_shared/autosend-policy.yaml:215:    tier: orange
agents/_shared/autosend-policy.yaml:222:    tier: orange
agents/_shared/autosend-policy.yaml:229:    tier: orange
agents/_shared/autosend-policy.yaml:236:    tier: orange
agents/_shared/autosend-policy.yaml:243:    tier: orange
agents/_shared/autosend-policy.yaml:246:    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"
agents/_shared/autosend-policy.yaml:250:    tier: orange
agents/_shared/autosend-policy.yaml:261:    tier: red
agents/_shared/autosend-policy.yaml:268:    tier: red
agents/_shared/autosend-policy.yaml:275:    tier: red
agents/_shared/autosend-policy.yaml:282:    tier: red
agents/_shared/autosend-policy.yaml:289:    tier: red
agents/_shared/autosend-policy.yaml:292:    reason: "PII transmitted outside tenant's declared data residency (GDPR boundary breach)"
agents/_shared/autosend-policy.yaml:296:    tier: red
agents/_shared/autosend-policy.yaml:299:    reason: "Sending tenant-A data to tenant-B recipient; RLS-enforced + red-listed for defence-in-depth"
agents/_shared/autosend-policy.yaml:303:    tier: red
agents/_shared/autosend-policy.yaml:306:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:310:    tier: red
agents/_shared/autosend-policy.yaml:321:  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
agents/_shared/autosend-policy.yaml:331:  - "tier ∈ {green, yellow, orange, red}"
agents/_shared/autosend-policy.yaml:332:  - "yellow action_types MUST declare sample_rate (positive integer)"
agents/_shared/autosend-policy.yaml:333:  - "orange action_types MUST declare timeout (ISO-8601 duration)"
agents/_shared/autosend-policy.yaml:334:  - "red action_types MUST declare block_reason"
agents/_shared/autosend-policy.yaml:335:  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
agents/_shared/autosend-policy.yaml:336:  - "41 total action_types (13 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"
docs/decisions/autosend-safety-policy.md:25:1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
docs/decisions/autosend-safety-policy.md:28:4. Any action declared as side-effecting in `tools.yaml` for an agent, regardless of category
docs/decisions/autosend-safety-policy.md:33:- Render-time renderer operations (writing rendered agent dirs to `${frameworkRoot}/orgs/<org>/agents/<name>/`)
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
docs/decisions/autosend-safety-policy.md:55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
docs/decisions/autosend-safety-policy.md:79:| Agent | action_type | Why green |
docs/decisions/autosend-safety-policy.md:81:| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
docs/decisions/autosend-safety-policy.md:90:| Agent | action_type | Sample rate | Why yellow |
docs/decisions/autosend-safety-policy.md:100:| Agent | action_type | Why orange |
docs/decisions/autosend-safety-policy.md:110:| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
docs/decisions/autosend-safety-policy.md:115:| action_type | block_reason | Why red |
docs/decisions/autosend-safety-policy.md:121:| `pii_export_outside_tenant_geography` | `pii_geographic_breach` | PII transmitted outside tenant's declared data residency (e.g., GDPR boundary breach) |
docs/decisions/autosend-safety-policy.md:122:| `cross_tenant_data_send` | `cross_tenant_violation` | Sending tenant-A data to tenant-B recipient; structurally enforced by RLS but red-listed for defence-in-depth |
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:136:The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
docs/decisions/autosend-safety-policy.md:138:### Reference implementation (bash pseudocode for `_shared/hook-helpers.sh`)
docs/decisions/autosend-safety-policy.md:153:  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
docs/decisions/autosend-safety-policy.md:160:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
docs/decisions/autosend-safety-policy.md:165:  # 2. Apply tenant override (elevation only; red is floor)
docs/decisions/autosend-safety-policy.md:167:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:174:    green)
docs/decisions/autosend-safety-policy.md:175:      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:178:    yellow)
docs/decisions/autosend-safety-policy.md:179:      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
docs/decisions/autosend-safety-policy.md:185:    orange)
docs/decisions/autosend-safety-policy.md:186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
docs/decisions/autosend-safety-policy.md:192:    red)
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:198:      # Fail-safe: unknown tier → red
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
docs/decisions/autosend-safety-policy.md:220:  - bullhorn_brief_read              # green
docs/decisions/autosend-safety-policy.md:221:  - bullhorn_candidate_query         # green
docs/decisions/autosend-safety-policy.md:222:  - bullhorn_note_draft_internal     # yellow (sample 1-in-10)
docs/decisions/autosend-safety-policy.md:223:  - bullhorn_note_customer_visible   # orange (CANONICAL — bullhorn-integration-path §4.1)
docs/decisions/autosend-safety-policy.md:224:  - gmail_outlook_send_to_candidate  # orange
docs/decisions/autosend-safety-policy.md:225:  - calendar_invite_send             # orange
docs/decisions/autosend-safety-policy.md:226:  - twilio_sms_send                  # orange
docs/decisions/autosend-safety-policy.md:229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
docs/decisions/autosend-safety-policy.md:239:**Tier:** orange
docs/decisions/autosend-safety-policy.md:240:**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
docs/decisions/autosend-safety-policy.md:282:**Tier:** red
docs/decisions/autosend-safety-policy.md:283:**Fires when:** a red-tier action is invoked; blocked unconditionally
docs/decisions/autosend-safety-policy.md:292:  "block_reason": "<enum: red_tier_classification | blocked_recipient | unauthorized_adapter | cross_tenant_violation | payment_action | billing_modification | legal_artefact | pii_geographic_breach>",
docs/decisions/autosend-safety-policy.md:301:2. `autosend_escalate ESC_AUTOSEND_BLOCKED` notifies tenant operator informationally (no action required)
docs/decisions/autosend-safety-policy.md:304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
docs/decisions/autosend-safety-policy.md:309:🔴 IFOS auto-send blocked (no action required)
docs/decisions/autosend-safety-policy.md:314:Block reason: payment_action (red-tier; never auto-sent in v1.0)
docs/decisions/autosend-safety-policy.md:320:**Tier:** fail-safe-red (treated as red)
docs/decisions/autosend-safety-policy.md:330:  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
docs/decisions/autosend-safety-policy.md:338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
docs/decisions/autosend-safety-policy.md:352:| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
docs/decisions/autosend-safety-policy.md:353:| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:355:| `decision_log` table unreachable (Postgres down, RLS context unset, network partition) | INSERT raises error | **Hard blocking error**; agent halts entirely with non-zero exit; no actions taken at all | Postgres restored OR session restarted with valid context; agent resumes from last checkpoint |
docs/decisions/autosend-safety-policy.md:356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
docs/decisions/autosend-safety-policy.md:357:| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
docs/decisions/autosend-safety-policy.md:358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
docs/decisions/autosend-safety-policy.md:380:--   phase = 'action'         when allowed (green/yellow/orange-approved)
docs/decisions/autosend-safety-policy.md:381:--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
docs/decisions/autosend-safety-policy.md:384:--     "tier": "green|yellow|orange|red|fail-safe-red",
docs/decisions/autosend-safety-policy.md:390:--     "approval_id": "<cortextOS approval gate id if orange>",
docs/decisions/autosend-safety-policy.md:393:--     "block_reason": "<enum if red/fail-safe-red>",
docs/decisions/autosend-safety-policy.md:408:`payload_preview` is **explicitly required to exclude raw PII**. It is a human-readable summary that:
docs/decisions/autosend-safety-policy.md:433:      "bullhorn_note_internal": "yellow",
docs/decisions/autosend-safety-policy.md:434:      "linkedin_connection_request": "orange",
docs/decisions/autosend-safety-policy.md:435:      "bullhorn_candidate_dedupe": "orange"
docs/decisions/autosend-safety-policy.md:461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
docs/decisions/autosend-safety-policy.md:462:2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
docs/decisions/autosend-safety-policy.md:463:3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
docs/decisions/autosend-safety-policy.md:476:### v1.0 ships with green + red only
docs/decisions/autosend-safety-policy.md:480:- **Green and red** give the binary "allowed" vs "blocked" classification needed for a low-risk v1.0 launch. Every action is either fully auto-sent or fully blocked. No "needs approval" or "sampled" intermediate states.
docs/decisions/autosend-safety-policy.md:481:- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:483:- v1.0 handles "needs approval" cases via **ad-hoc Telegram approval** outside the policy pipeline: agent emits a manual approval request via existing primitive 5, founder/operator resolves manually, agent proceeds. These cases are tracked as "would-be-orange" candidates for v1.1 prioritisation.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
docs/decisions/autosend-safety-policy.md:489:- Existing green and red actions remain unchanged. v1.0 → v1.1 transition is purely additive.
docs/decisions/autosend-safety-policy.md:493:- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
docs/decisions/autosend-safety-policy.md:494:- **Per-recipient reputation:** recipients with high engagement may be in implicit "always-orange" zone; recipients with prior unsubscribes may be elevated to red.
docs/decisions/autosend-safety-policy.md:500:## §10 — Pilot-agreement liability language (PLACEHOLDER — legal review required)
docs/decisions/autosend-safety-policy.md:511:classifies each agent action into one of four tiers: green, yellow,
docs/decisions/autosend-safety-policy.md:512:orange, or red. The classification in effect at the moment of send, as
docs/decisions/autosend-safety-policy.md:521:  (a) any action classified as green by the policy at time of send;
docs/decisions/autosend-safety-policy.md:522:  (b) any action classified as yellow that passed spot-check review or
docs/decisions/autosend-safety-policy.md:524:  (c) any action classified as orange that was approved by Tenant's
docs/decisions/autosend-safety-policy.md:537:  (b) failure of the policy lookup mechanism (decision_log fail-safe-red
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:582:1. **Jurisdiction.** IFOS Limited is UK Companies House registered → English law as default. Confirm with counsel; cross-border tenants may require alternate forum clauses.
docs/decisions/autosend-safety-policy.md:596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
docs/decisions/autosend-safety-policy.md:604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
docs/decisions/autosend-safety-policy.md:605:| 10 | Telegram bot reliability — primitive 5 is shipped but not battle-tested at v1.0 pilot scale. What's the SLA on approval gate notification? | §5 + §6 | Recommend instrumentation in Week 1-2 as part of `_shared/` helpers build. Target: 95th percentile notification latency <30s. Below-target events trigger v1.1 evaluation of alternate channels. |
docs/decisions/autosend-safety-policy.md:607:### Items NOT deferred (resolved inline above)
docs/decisions/autosend-safety-policy.md:613:- **Whether red can be relaxed:** No, §8 rule 2 — red is absolute.
docs/decisions/autosend-safety-policy.md:620:- **Q3 (lookup latency / 71-hour cache lifetime):** ACCEPTED for v1.0. Policy hot-reload deliberately deferred to v1.1+; v1.0 accepts up-to-71-hour delay on policy changes taking effect at agent layer. Material policy changes must wait for next 71-hour boundary (cortextOS context rotation per master brief §2.4 primitive 2) or trigger deliberate cortextOS PTY restart. Operational footgun documented in §4.
docs/decisions/autosend-safety-policy.md:621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
docs/decisions/autosend-safety-policy.md:622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
docs/decisions/autosend-safety-policy.md:624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/autosend-safety-policy.md:642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
docs/decisions/autosend-safety-policy.md:645:4. §10 placeholder language (substantive review deferred to legal counsel, but Codex reviews structural completeness)
docs/decisions/autosend-safety-policy.md:656:- **Proposed** (this commit) → **Accepted** (post-Codex Day-7) → **In force** (when Week-1 `_shared/hook-helpers.sh` implementation completes)
docs/decisions/autosend-safety-policy.md:657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.
docs/decisions/autosend-safety-policy.md:658:- v1.0 implementation prerequisite: this policy + the Week-1 `_shared/` helpers + ADR-003 renderer + Day-4 Postgres schema (all four are present after this commit lands).

exec
/bin/zsh -lc "rg -n \"master brief|§8\\.2|Build wave|W3|Diagnostic|diagnostic|Persistent PTY|Telegram|Change 1|Change 2|Rule 1\" docs legacy .codex agents packages -g '*.md' -g '*.yaml' -g '*.yml' | head -200" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/autosend-policy.yaml:31:    agent: diagnostic
agents/_shared/autosend-policy.yaml:68:    reason: "Internal operator-only Telegram notification (escalations + run-complete markers); not customer-facing; idempotent within decision_log payload_hash dedup window"
agents/_shared/autosend-policy.yaml:228:  diagnostic_email_send:
agents/_shared/autosend-policy.yaml:230:    agent: diagnostic
agents/_shared/autosend-policy.yaml:232:    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
agents/_shared/autosend-policy.yaml:235:  diagnostic_calendar_invite:
agents/_shared/autosend-policy.yaml:237:    agent: diagnostic
.codex/ratification/review-agent-bundle.md:11:## §1 — agent.md required-section structure (per ADR-003 + Diagnostic precedent)
.codex/ratification/review-agent-bundle.md:18:| §1 | Output contract | One-paragraph screenshot per master brief §1 Rule 1. Names WHAT the agent produces in a single paragraph, readable cold | Missing; >3 paragraphs; doesn't name vault write path; doesn't name Gate A + Gate B thresholds |
.codex/ratification/review-agent-bundle.md:19:| §2 | Invocation surface | CLI / webhook / cron / Brain UI / Telegram triggers; per-trigger auth requirements; v1.1+ deferred surfaces | Missing; lists surfaces not supported by master brief §8.2 (e.g. uses AgentMail before v1.1) |
.codex/ratification/review-agent-bundle.md:20:| §3 | Output shape | Specific to agent. Diagnostic: 12 sections. Janitor: day-30 report + Bullhorn writes. Cash Conductor: reconciliation rows + chase drafts + weekly report | Missing; doesn't name the artefact paths; doesn't name the decision_log audit-row signature for each output |
.codex/ratification/review-agent-bundle.md:22:| §5 | Gates | Gate A: validate.sh hard-fail conditions. Gate B: outcome success threshold + measurement mechanism | Missing; Gate A conditions not testable; Gate B threshold not cited to ULTRAPLAN/master brief; Gate A weaker than §1 output contract |
.codex/ratification/review-agent-bundle.md:24:| §7 | Voice + tone constraints | `_shared/voice-loader.sh` integration; per-tenant scope; voice classifier threshold per agent.md §5 | Missing for agents that produce text output; threshold drift from master brief §8.1 Change 1 |
.codex/ratification/review-agent-bundle.md:37:1. **master brief §8.2 line N** for build wave (e.g. "W5 per master brief §8.2 line 596"). Verify the line range actually contains the row claimed.
.codex/ratification/review-agent-bundle.md:38:2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
.codex/ratification/review-agent-bundle.md:48:- master brief week N cited but row mismatches (e.g. "W5" but the row says W6)
.codex/ratification/review-agent-bundle.md:53:**Drift between master brief and ULTRAPLAN is the norm, not an error.** Master brief is authoritative per project hierarchy. agent.md should cite BOTH with a "drift flag" note if the build-wave timing differs (e.g. Sourcing Scout: master brief W9 vs ULTRAPLAN A5 W8-9 — note the drift; use master brief).
.codex/ratification/review-agent-bundle.md:59:agent.md files come in two flavours per the Diagnostic precedent:
.codex/ratification/review-agent-bundle.md:61:**Pre-build scaffold (Status: Proposed)** — written BEFORE the sibling bundle files exist. The 5 W3-scaffold agents (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) are all pre-build scaffolds. Allowed gaps:
.codex/ratification/review-agent-bundle.md:75:**Production-ready (Status: Accepted OR In Force)** — written AFTER bundle files exist + pass tests. Diagnostic at Day-13 + Day-19 polish is production-ready. Additional requirements:
.codex/ratification/review-agent-bundle.md:92:Every agent.md is checked against the four boundaries (master brief §3):
.codex/ratification/review-agent-bundle.md:94:1. **cortextOS submodule** — agent.md must NOT reference files under `packages/harness/cortextos/*`. cortextOS primitives are referenced by index (#1 Persistent PTY, #5 Telegram surface, etc.) NOT by file path.
.codex/ratification/review-agent-bundle.md:111:- All citations verified against source files (master brief / ULTRAPLAN / escalation-codes / vertical-schema)
.codex/ratification/review-agent-bundle.md:135:## §6 — Special case: Diagnostic agent.md
.codex/ratification/review-agent-bundle.md:137:Diagnostic was scaffold-ratified at Day-11 (Round 3 RATIFIED) + production-shape polished at Day-13 (commits `97a57a2` + `2688b6a`) + Day-19 remediation (commit `6e0cb86`). Codex Round 4 Phase 1 hit hard ceiling — see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` for the 5-issue disposition.
.codex/ratification/review-agent-bundle.md:139:When re-ratifying Diagnostic agent.md with THIS skill (not review-architecture-decision):
.codex/ratification/review-agent-bundle.md:143:- If Issues 1-4 resolve via the founder arbitration recommendations in the disagreement doc (which I'd accept as the right framing for v0), then Diagnostic agent.md should RATIFY under this skill.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:75:          Semver tag (e.g. "v0.1", "v0.2-2026-06-15"). Bump on re-index. Live pack is the row with `is_active: true`; historical packs preserved for audit + rollback per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:168:          Provenance: "founder" (default tenant-onboarding rules), "tenant-admin" (added via Brain UI), "ifos-csm" (added during CSM intervention per master brief §10 CSM workflow).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:191:      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:357:      Recorded but not actively driving retraining in v1.0 (Brain UI v1.1 surfaces the queue; v2.0 LoRA pipeline reads it). v0.2 establishes the linkage schema so production data accumulates cleanly from W3 forward.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/verticals/recruitment/vertical-schema.yaml:10:# Source: master brief §6 Day 6 line 490 (8 core entities)
docs/verticals/recruitment/vertical-schema.yaml:26:  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
docs/verticals/recruitment/vertical-schema.yaml:27:  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:36:#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:216:      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
docs/verticals/recruitment/vertical-schema.yaml:289:      - (v1.1+) Inbound Triage — R+W expansion per master brief §9
docs/verticals/recruitment/vertical-schema.yaml:537:      A contractor's weekly hours record. v2.0 entity — exercised by T2 Timesheet agent + T6 Pay & Bill agent per master brief §9. v0.1 captures placeholder shape only.
docs/verticals/recruitment/vertical-schema.yaml:671:  Diagnostic:
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:822:    revisit_trigger: v1.1 Inbound Triage agent build per master brief §9 expands decision-authority modelling.
docs/verticals/recruitment/vertical-schema.yaml:829:    rationale: T2 + T6 builds are v2.0 per master brief §9; full schema requires pay/bill modelling not yet designed.
docs/verticals/recruitment/vertical-schema.yaml:896:    expected_date: post first-pilot operations (Q4 2026 if pilot lands per master brief §6 Day 7 question 1)
docs/verticals/recruitment/vertical-schema.yaml:901:    expected_date: 2027+ per master brief §9 build sequence
.codex/ratification/SKILL.md:16:## §1 — The five rules (master brief §1)
.codex/ratification/SKILL.md:32:## §2 — The four boundaries (master brief §3)
.codex/ratification/SKILL.md:50:- **Citation accuracy** — section references like "§X.Y" MUST be verifiable. Open the cited file at the cited line/section; does the citation hold? Past violations: a Day-6 audit found 15 fabricated "master brief §10.4 cost target" references; §10.4 is actually the Codex exclusion list.
.codex/ratification/SKILL.md:56:- **Dates** — operational-hygiene-protocol §5 + master brief §1 Rule 5. Absolute dates (not relative — "by Friday" is wrong; "by 2026-06-03" is right). Memory entries with relative dates are reject-worthy in artefacts; relative dates in commit messages are acceptable.
agents/_shared/escalation-codes.md:4:**Mandated by:** master brief §8.1 Change 3 — "Build the catalogue in Week 0. New codes only when production demands one."
agents/_shared/escalation-codes.md:11:Every `ESC_*` is a payload written to Postgres `decision_log` (per master brief §8.1 Change 2 + Day-4 §6.3 schema) plus a Telegram notification to the operator (per master brief §2.4 primitive 5 + `common-notifications.json` routing).
agents/_shared/escalation-codes.md:24:The Telegram message is templated via `common-notifications.json` `escalation_routes.<ESC_CODE>` if present; otherwise routed to `operator_chat_id`. `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` additionally CCs `ifos_oncall_chat_id`.
agents/_shared/escalation-codes.md:37:- **Routing:** `operator_chat_id` via Telegram approval gate (primitive 4)
agents/_shared/escalation-codes.md:118:Source: master brief §8.1 Change 3 lines 585-592
agents/_shared/escalation-codes.md:131:- **Routing:** `operator_chat_id` via Telegram approval gate
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:158:- **Trigger:** Upstream API rate-limited; especially LinkedIn (Sourcing Scout multi-source pulls) per master brief §8.1 Change 3 line 592 + bullhorn-integration-path.md §2.2 (Bullhorn 429s)
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:198:- **Routing:** log-only (no Telegram noise)
agents/_shared/escalation-codes.md:333:- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:379:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
agents/_shared/escalation-codes.md:465:| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
agents/_shared/escalation-codes.md:466:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
agents/_shared/escalation-codes.md:474:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
agents/_shared/escalation-codes.md:479:The catalogue is read at process start via `_shared/escalation-codes-table.sh` (machine-readable companion; deferred to Phase 3 or first use, whichever lands first). If absent, helpers fall back to permissive write (log row only; no Telegram) + emit a one-shot operational warning.
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:48:### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)
agents/_shared/README.md:82:## Telegram-down failure mode
agents/_shared/README.md:88:**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
.codex/ratification/review-postgres-migration.md:100:`decision_log` is append-only per Day-4 §6.3 + master brief §3.3 audit discipline. `recent_edit` extends this pattern per v0.2 supplement.
.codex/ratification/review-schema-change.md:34:- `v1_0_agent_access` — list of agents from master brief §8.2 with R / W / R+W disposition, OR explicit "none (v1.1+ exercise)"
.codex/ratification/review-schema-change.md:80:`agent_access_matrix:` must list every v1.0 agent (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) + state R / W / R+W / none for every entity_type.
.codex/ratification/review-schema-change.md:86:- `Diagnostic` must have `none` or `R` for all entities — Diagnostic doesn't write to Bullhorn per `sequencing-target.md` §2.1
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
docs/_archive-build-pack/08-OPEN-DECISIONS.md:38:## §3 · Telegram as a v2 channel — Phase 1 or Phase 3?
docs/_archive-build-pack/08-OPEN-DECISIONS.md:40:**Decision needed:** When does Telegram control become a real shipped feature?
docs/_archive-build-pack/08-OPEN-DECISIONS.md:42:cortextOS ships Telegram natively. v2 inherits it for free at the harness level. But:
docs/_archive-build-pack/08-OPEN-DECISIONS.md:44:- Phase 1 ship: founders can already use Telegram against the dev daemon. Cool for demos, doesn't affect customers.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:45:- Phase 2 (dashboard) doesn't depend on Telegram.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:46:- Phase 3 customer-facing Telegram = needs onboarding flow ("create your bot, paste the token"), permissions model, etc.
docs/_archive-build-pack/08-OPEN-DECISIONS.md:52:| **A. Phase 1 internal only; Phase 3 customer-facing** | Lets v2 land the brain swap without UX work on Telegram. | Telegram is a v2 differentiator; delaying it hurts the demo. |
docs/_archive-build-pack/08-OPEN-DECISIONS.md:53:| **B. Phase 2 customer-facing** | Telegram is in scope as part of the dashboard build. Demo-ready. | Adds 1 slice to Phase 2. |
docs/_archive-build-pack/08-OPEN-DECISIONS.md:56:**Recommendation:** **C.** Internal-only Telegram in Phase 1 (the daemon needs it for "Phase 0 alive" anyway). Customer-facing Telegram in Phase 3 alongside per-tenant daemon spawning. Demos in the Phase 1–2 window use the founder's bot pointing at the demo tenant.
.codex/ratification/review-architecture-decision.md:29:5. **Consequences section** — what changes downstream. Includes risk register implications, master brief edits authorised (if any), downstream-artefact updates required. **Required for `Proposed | Accepted`. EXEMPT for `Reference` + `In Force` — downstream impact may be inline (e.g., "Day-7 single-sentence test Q2 references this audit") rather than under a dedicated heading; verify via cross-references in body text.**
.codex/ratification/review-architecture-decision.md:60:For every cited section reference (e.g., "master brief §6 Day 7 line 502"):
.codex/ratification/review-architecture-decision.md:66:If even one citation is wrong, REJECT with the specific citation listed. Past pattern: `master brief §10.4 cost target` cited 15 times; §10.4 is actually the Codex exclusion list with no cost-target content.
.codex/ratification/review-architecture-decision.md:76:If the ADR authorises master brief edits (an "## Master brief edits authorised by this ADR" section):
.codex/ratification/review-architecture-decision.md:79:2. The edit's line numbers MUST match the live master brief (sample-check at least one).
.codex/ratification/review-architecture-decision.md:112:## §7 — Decision_log audit fields (master brief §8.1 Change 2)
docs/_archive-build-pack/01-RECOMMENDATION.md:138:│        ├─ bus/send-message.sh      → Telegram or v2 dashboard
docs/_archive-build-pack/01-RECOMMENDATION.md:185:- [ ] Telegram-control as a v2 feature is decided (see `08-OPEN-DECISIONS.md` §3)
packages/harness/PINNED-SHA.md:26:   (master brief §3.4 and §5).
packages/harness/PINNED-SHA.md:53:- Codex ratification per master brief §10
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:15:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/cash-conductor/agent.md:63:- Per-tenant Telegram daily summary
agents/recruitment/cash-conductor/agent.md:137:14 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/cash-conductor/agent.md:261:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:283:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:326:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:337:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
agents/recruitment/cash-conductor/agent.md:369:| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
agents/recruitment/cash-conductor/agent.md:371:| Q5 | Reconciliation Stage 3-4 (fuzzy / ambiguous matches) — consultant review queue UX. Brain UI workflow? Telegram? | v1.0: weekly report exception list. v1.1: Brain UI per-row review queue. |
agents/recruitment/cash-conductor/agent.md:381:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:398:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
docs/_archive-build-pack/06-BUILD-PLAN.md:22:**Goal:** A v2 codebase that boots a cortextOS daemon with one Orchestrator agent that can send a Telegram message saying "Phase 0 alive". No brain, no dashboard, no governance yet. Just the bones standing up.
docs/_archive-build-pack/06-BUILD-PLAN.md:50:- Wire Telegram bot token via `.env.local`
docs/_archive-build-pack/06-BUILD-PLAN.md:52:- Verify: Orchestrator sends a Telegram message "Phase 0 alive — <timestamp>"
docs/_archive-build-pack/06-BUILD-PLAN.md:65:- [ ] Orchestrator sends one Telegram message visible in the configured chat
docs/_archive-build-pack/06-BUILD-PLAN.md:70:**Time check:** if Phase 0 is approaching 2 sessions, stop and ask why. Likely cause is environmental (PM2 setup, Telegram bot creation). Don't push through; debug the environment, then resume.
docs/_archive-build-pack/06-BUILD-PLAN.md:222:- Adapt steps for v2: tool connections, voice profile capture, agent selection (which of the 11 to enable), Telegram bot creation, first ingest
docs/_archive-build-pack/06-BUILD-PLAN.md:246:- Verify: customer can log in to v2, sees their brain populated, agents drafting, approvals queue populated, Telegram works
agents/recruitment/janitor/README.md:9:| `agent.md` | Output-contract-first agent specification per master brief §1 Rule 1 | Proposed |
agents/recruitment/janitor/README.md:30:- Bullhorn MCP connector built (W3-W4 conditional per ADR-005)
packages/utilities/web-scraper/README.md:3:IFOS web scraper utility for Diagnostic agent §4 Step 3 + 6 + 8 per `agents/recruitment/diagnostic/tools.yaml`.
packages/utilities/web-scraper/README.md:13:- **No JavaScript execution.** Lightweight HTTP only. JS-heavy sites return their server-rendered HTML (often a "JavaScript required" placeholder) — graceful degradation per Diagnostic gotcha §6.1.
packages/utilities/web-scraper/README.md:18:- **User agent:** `Mozilla/5.0 (compatible; IFOS-Diagnostic/0.1; +https://intelforce.io/bot)`. Identifies us; not deceptive.
packages/utilities/web-scraper/README.md:22:- **Timeout / connection refused** → returns `null`; logs warning; caller treats as "no signal" per Diagnostic gotcha §6.1.
packages/utilities/web-scraper/README.md:51:v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
docs/_archive-build-pack/02-PRODUCT-VISION.md:9:v1 was *a managed agent workforce* — eleven agents that draft, never send, escalate when uncertain, governed by approvals. It worked, but the agents were largely reactive — each waiting for its trigger, doing its job, queuing for review. v2 makes that workforce **persistent, proactive, and compounding**. cortextOS gives us a 24/7 daemon that keeps agents resident across days, not minutes — so agents can be assigned long-running goals ("watch the inbox for grievance signals; surface weekly trends"), not just one-shot tasks. The wiki+graphify brain replaces stock RAG with a memory layer the founder can *see* — a beautiful Obsidian-style vault that grows visibly, with a graph view that makes the compounding tangible. The dashboard becomes both *operations console* and *brain explorer*. The Telegram integration becomes the founder's mobile-control surface, so v2 is the first version of Intel Force that the operator can run from their phone in line at the coffee shop.
docs/_archive-build-pack/02-PRODUCT-VISION.md:44:What it gives the customer: a single agent ("Boss" — cortextOS's term, or rename it) they talk to in Telegram, that knows everything that's happening. "What's running right now?" "Approve all low-sensitivity HR drafts from this morning." "Add a cron that checks Stripe revenue every Monday at 8am and flags anomalies." Conversational.
docs/_archive-build-pack/02-PRODUCT-VISION.md:94:> What makes it different is the **Brain**: a private second-brain your company builds in real time. The handbook you uploaded, the proposals that closed, the way Sarah handles holiday requests differently from Tom — it all goes in. As the agents work and you approve their drafts, the Brain compounds. By month three, the system reads like you. By month twelve, no one can replicate what you've built. You can see it growing in the dashboard's graph view — a stunning Obsidian-style map of your operations that gets denser every day. Control everything from your phone via Telegram, or the web dashboard, or the iOS app when it ships.
docs/_archive-build-pack/02-PRODUCT-VISION.md:131:- **Telegram is first-class.** v1 had Teams + Slack. v2 adds Telegram as the founder's mobile-control surface (cortextOS's native channel).
docs/_archive-build-pack/02-PRODUCT-VISION.md:132:- **Orchestrator exists.** v1 had no planning agent. v2 has an explicit "Boss" the customer talks to in Telegram.
docs/_archive-build-pack/02-PRODUCT-VISION.md:141:- **Microsoft Teams as primary channel** → secondary in v2. Telegram is primary. Teams gets ported in Phase 3 if/when a customer demands it.
docs/_archive-build-pack/02-PRODUCT-VISION.md:168:- Whether the Telegram interface ships in Phase 1 or Phase 3 (`08-OPEN-DECISIONS.md` §3)
docs/_archive-build-pack/README.md:13:| **cortextOS upstream** | `/Users/madsadmin/code/cortex-os-upstream/` | The agentic harness. v0.1.1. Persistent 24/7 Claude Code agents, PM2-managed, file-bus coordination, Telegram + Next.js dashboard. Read-only reference. |
docs/_archive-build-pack/README.md:25:cortextOS is a Node 20+ daemon (`dist/daemon.js`, CLI `dist/cli.js`) that runs Claude Code (or OpenAI's `codex-app-server`) in persistent PTY sessions under PM2, auto-restarting on crash or after a 71-hour context rotation. Agents coordinate through a shared **file bus** (47 shell scripts in `bus/`) that wrap a TypeScript bus in `src/bus/`. Templates in `templates/` define agent roles — Orchestrator, Analyst, Specialist, Hermes, M2C1-worker. Telegram is the primary control surface; a Next.js 14 dashboard in `dashboard/` is secondary.
agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:14:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/janitor/agent.md:59:| 4 | **Tacit-note coverage** | Notes harvested from `decision_log` resolved with `outcome='approved_after_edit'` per master brief §8.1 Change 2; attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:79:12 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/janitor/agent.md:125:   → 7-day cache per tools.yaml; rate-limit budget shared with Diagnostic
agents/recruitment/janitor/agent.md:158:11. Operator notification (Telegram)
agents/recruitment/janitor/agent.md:177:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:237:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:248:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ Week 3 in progress |
agents/recruitment/janitor/agent.md:252:| Bullhorn MCP connector built | W3-W4 conditional (per ADR-005 sequencing) | ⏸ Not started |
packages/harness/cortextos/README.md:5:**Persistent 24/7 Claude Code agents you control from Telegram or your phone.**
packages/harness/cortextos/README.md:10:Telegram chat
packages/harness/cortextos/README.md:32:- **Multi-runtime** — Run agents on `claude-code` (default) or OpenAI's `codex-app-server`. Both runtimes share the same bus, crons, dashboard, and Telegram integration; pick per-agent.
packages/harness/cortextos/README.md:33:- **Telegram + iOS control** — Send commands, approve actions, and get reports from anywhere. Native iOS app coming soon.
packages/harness/cortextos/README.md:43:    U["User (Telegram / iOS)"] --> CLI["cortextOS Daemon (Node.js)"]
packages/harness/cortextos/README.md:57:**Requirements:** Node.js 20+, Claude API key, PM2, Telegram bot token from @BotFather.
packages/harness/cortextos/README.md:72:Onboarding handles everything: dependency checks, org setup, bot creation, PM2 config, and dashboard launch. Your Orchestrator comes online in Telegram and finishes its own setup there.
packages/harness/cortextos/README.md:82:# Add Telegram credentials for each agent
packages/harness/cortextos/README.md:106:| Telegram bot token | Create via @BotFather |
packages/harness/cortextos/community/skills/onboarding/SKILL.md:3:description: "You have just booted for the first time — there is no .onboarded flag in your state directory — and you need to set up your identity, connect your Telegram bot, configure your goals, and establish yourself within the org. Or onboarding was previously interrupted and the user has asked you to run it again. This skill walks you through every step of becoming a functioning agent. Do not skip steps. Do not start normal operations until onboarding is complete."
packages/harness/cortextos/community/skills/onboarding/SKILL.md:66:| Telegram bot connected and tested | `.env` (BOT_TOKEN, CHAT_ID) |
packages/harness/cortextos/community/skills/onboarding/SKILL.md:100:Then notify the user via Telegram that you are online and ready.
packages/harness/cortextos/community/skills/onboarding/SKILL.md:117:- Do NOT send a Telegram message claiming you are online until onboarding is complete
agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:14:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:51:- Telegram command (`@ifos_bot scribe replay <call-id>`)
agents/recruitment/scribe/agent.md:127:10 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
agents/recruitment/scribe/agent.md:214:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:279:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/scribe/agent.md:290:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
agents/recruitment/scribe/agent.md:294:| Bullhorn MCP write capability | W3-W4-W5 build chain | ⏸ |
docs/_archive-build-pack/03-ARCHITECTURE.md:214:                  │  Telegram bot        │   ← cortextOS native
docs/_archive-build-pack/03-ARCHITECTURE.md:259:### 5.1 An employee asks an HR question (Teams or Telegram)
docs/_archive-build-pack/03-ARCHITECTURE.md:262:User → Telegram (or Teams via bus/teams-receive.sh which we add later)
docs/_archive-build-pack/03-ARCHITECTURE.md:271:     → bus/send-message.sh notifies the operator (Telegram + dashboard)
docs/_archive-build-pack/03-ARCHITECTURE.md:272:Operator → opens dashboard /approvals OR replies "approve" in Telegram
docs/_archive-build-pack/03-ARCHITECTURE.md:298:Reporting agent runs at 9:05: bus/send-message.sh Telegram with morning brief
docs/_archive-build-pack/03-ARCHITECTURE.md:299:Operator gets a single Telegram message:
docs/_archive-build-pack/03-ARCHITECTURE.md:487:## 8. Telegram + iOS
docs/_archive-build-pack/03-ARCHITECTURE.md:489:cortextOS ships native Telegram bot per-org. v2 inherits this. Telegram becomes the primary mobile-control surface — see `02-PRODUCT-VISION.md` §Cortex.
docs/_archive-build-pack/03-ARCHITECTURE.md:504:| Telegram | cortextOS-native (uses Telegram Bot API directly) |
packages/harness/cortextos/CHANGELOG.md:70:cortextOS is a persistent 24/7 multi-agent framework built on Claude Code. Agents run as PM2-managed PTY processes, communicate over a file-based message bus, manage tasks, log analytics events, and are controlled via Telegram. This Node.js package ships the entire framework as a single `npm install` with a unified `cortextos` CLI.
packages/harness/cortextos/CHANGELOG.md:176:- **`postActivity()`**: Sends activity update to Telegram (reads BOT_TOKEN/CHAT_ID from `.env`)
packages/harness/cortextos/CHANGELOG.md:210:| `bus send-telegram <chat_id> '<text>'` | Send Telegram message |
packages/harness/cortextos/CHANGELOG.md:411:General-purpose persistent agent. 24/7, Telegram-controlled, task-focused.
packages/harness/cortextos/CHANGELOG.md:422:- `.claude/settings.json` — hooks: plan mode approval, permission requests, ask-user-question, all routed to Telegram
packages/harness/cortextos/CHANGELOG.md:426:- `skills/comms/` — Telegram and agent-to-agent message formats
packages/harness/cortextos/CHANGELOG.md:458:| Sprint 6 — Fast Checker | `sprint6-fastchecker.test.ts` | 18 | Telegram polling, callback routing, AskUserQuestion TUI |
packages/harness/cortextos/CHANGELOG.md:469:| Unit — Telegram | `unit/telegram/*.test.ts` | 18 | Message formatting, photo handling, keyboard markup |
packages/harness/cortextos/CHANGELOG.md:493:│   ├── daemon/       # FastChecker daemon (Telegram polling, message routing, callback handling)
packages/harness/cortextos/community/skills/comms/SKILL.md:39:If you send a Telegram message that asks a question and you need the answer before continuing your work, you MUST end your current response entirely (stop all tool execution, produce no more output). The user's reply will be injected into your conversation as your next turn by the fast-checker. If you keep executing tools after sending the question, the reply gets queued by Claude Code and you will never see it until your turn ends. End your turn, and the reply arrives.

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,230p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '1,320p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/cycle.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/tools.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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
     2	#
     3	# Diagnostic agent — cycle.sh (workflow orchestration)
     4	#
     5	# Status: Proposed (pre-W3-build scaffold; Day-12 author).
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
    29	# Build state: SCAFFOLD. MCP connectors not yet wired (Companies House,
    30	# LinkedIn, web scraper) — those land at W3 start. This script:
    31	#   - Structures the 10-step flow with proper hook-helpers integration
    32	#   - Stubs each external call with a clear "W3 BUILD: <what's missing>"
    33	#     comment + a fail-clean fallback message
    34	#   - Generates a valid-shape Markdown report that passes V1+V2 even
    35	#     without real upstream data, useful for fixture-driven testing
    36	
    37	set -uo pipefail
    38	
    39	# ────────────────────────────────────────────────────────────────────────
    40	# Arguments
    41	# ────────────────────────────────────────────────────────────────────────
    42	
    43	FIRM_NAME=""
    44	SECTOR_HINT=""
    45	NOTIFY_VIA=""
    46	
    47	while [[ $# -gt 0 ]]; do
    48	  case "$1" in
    49	    --firm) FIRM_NAME="$2"; shift 2 ;;
    50	    --sector) SECTOR_HINT="$2"; shift 2 ;;
    51	    --notify-via) NOTIFY_VIA="$2"; shift 2 ;;  # used below in Step 14
    52	    *) printf 'cycle.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
    53	  esac
    54	done
    55	
    56	if [[ -z "${FIRM_NAME}" ]]; then
    57	  printf 'cycle.sh: --firm <name> required\n' >&2
    58	  exit 2
    59	fi
    60	
    61	export IFOS_DIAGNOSTIC_FIRM_NAME="${FIRM_NAME}"
    62	
    63	# ────────────────────────────────────────────────────────────────────────
    64	# Step 0 — Context hydration
    65	# ────────────────────────────────────────────────────────────────────────
    66	
    67	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    68	  printf 'cycle.sh: CTX_AGENT_DIR unset (agent not rendered)\n' >&2
    69	  exit 1
    70	fi
    71	
    72	# shellcheck source=/dev/null
    73	source "${CTX_AGENT_DIR}/context.sh"
    74	
    75	# Sanity
    76	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    77	  printf 'cycle.sh: CTX_TENANT_SLUG unset after context.sh\n' >&2
    78	  exit 1
    79	fi
    80	
    81	# ────────────────────────────────────────────────────────────────────────
    82	# Compute firm-slug for filename + draft path
    83	# ────────────────────────────────────────────────────────────────────────
    84	
    85	FIRM_SLUG=$(printf '%s' "${FIRM_NAME}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9- ' | tr ' ' '-' | sed 's/--*/-/g; s/^-//; s/-$//')
    86	ISO_DATE=$(date -u +"%Y-%m-%d")
    87	VAULT_ROOT="${IFOS_VAULT_ROOT:-/vault}"
    88	REPORT_DIR="${VAULT_ROOT}/${CTX_TENANT_SLUG}/diagnostic-reports"
    89	REPORT_PATH="${REPORT_DIR}/${FIRM_SLUG}-${ISO_DATE}.md"
    90	DRAFT_PATH="/tmp/diagnostic-draft-${FIRM_SLUG}-$$.md"
    91	
    92	mkdir -p "${REPORT_DIR}" 2>/dev/null || {
    93	  printf 'cycle.sh: cannot create %s\n' "${REPORT_DIR}" >&2
    94	  exit 1
    95	}
    96	
    97	# ────────────────────────────────────────────────────────────────────────
    98	# Step 1 — Validate input + sector
    99	# ────────────────────────────────────────────────────────────────────────
   100	
   101	if [[ ${#FIRM_SLUG} -lt 2 ]]; then
   102	  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
   103	    "$(printf '%s' "${FIRM_NAME}" | shasum | awk '{print $1}')" \
   104	    '{"escalation_code":"ESC_SCHEMA_VIOLATION","reason":"firm name too short"}' >/dev/null
   105	  exit 1
   106	fi
   107	
   108	# ────────────────────────────────────────────────────────────────────────
   109	# Step 2-11 — Generate the 12 sections via @ifos/diagnostic-generator
   110	# ────────────────────────────────────────────────────────────────────────
   111	#
   112	# v0 build (Day 13): web-scraper + companies-house wired; LinkedIn deep
   113	# data deferred to W4 (Proxycurl). Voice classifier gate skipped at v0.
   114	# CLI: packages/diagnostic-generator/dist/cli.js
   115	
   116	GENERATOR_CLI="${IFOS_REPO_ROOT:-${REPO_ROOT}}/packages/diagnostic-generator/dist/cli.js"
   117	if [[ ! -f "${GENERATOR_CLI}" ]]; then
   118	  printf 'cycle.sh: generator CLI not built at %s\n' "${GENERATOR_CLI}" >&2
   119	  printf '  Run: cd packages/diagnostic-generator && pnpm build\n' >&2
   120	  exit 1
   121	fi
   122	
   123	# target_patch.json — optional; if missing, §6 ICP fit degrades to "no patch"
   124	TARGET_PATCH_PATH="${VAULT_ROOT}/${CTX_TENANT_SLUG}/target_patch.json"
   125	TARGET_PATCH_FLAG=""
   126	if [[ -f "${TARGET_PATCH_PATH}" ]]; then
   127	  TARGET_PATCH_FLAG="--target-patch ${TARGET_PATCH_PATH}"
   128	fi
   129	
   130	# Load Companies House API key from tenant secrets if present
   131	if [[ -f "${VAULT_ROOT}/${CTX_TENANT_SLUG}/_secrets.env" && -z "${COMPANIES_HOUSE_API_KEY:-}" ]]; then
   132	  set -a
   133	  # shellcheck source=/dev/null
   134	  source "${VAULT_ROOT}/${CTX_TENANT_SLUG}/_secrets.env"
   135	  set +a
   136	fi
   137	
   138	if [[ -z "${COMPANIES_HOUSE_API_KEY:-}" ]]; then
   139	  printf 'cycle.sh: COMPANIES_HOUSE_API_KEY not set\n' >&2
   140	  printf '  Founder action: register at https://developer.company-information.service.gov.uk/ and save key to %s/_secrets.env\n' \
   141	    "${VAULT_ROOT}/${CTX_TENANT_SLUG}" >&2
   142	  exit 1
   143	fi
   144	
   145	# shellcheck disable=SC2086
   146	node "${GENERATOR_CLI}" \
   147	  --firm "${FIRM_NAME}" \
   148	  --tenant "${CTX_TENANT_SLUG}" \
   149	  --sector "${SECTOR_HINT}" \
   150	  ${TARGET_PATCH_FLAG} \
   151	  --iso-date "${ISO_DATE}" \
   152	  > "${DRAFT_PATH}"
   153	
   154	if [[ ! -s "${DRAFT_PATH}" ]]; then
   155	  printf 'cycle.sh: generator produced empty output\n' >&2
   156	  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
   157	    "$(date +%s)" \
   158	    '{"escalation_code":"ESC_SCHEMA_VIOLATION","reason":"generator stdout empty"}' >/dev/null
   159	  exit 1
   160	fi
   161	
   162	# ────────────────────────────────────────────────────────────────────────
   163	# Step 12 — Validate (Gate A)
   164	# ────────────────────────────────────────────────────────────────────────
   165	
   166	hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
   167	  "${FIRM_NAME} 12-section draft (pre-validate)" >/dev/null
   168	
   169	if ! bash "${CTX_AGENT_DIR}/validate.sh" "${DRAFT_PATH}"; then
   170	  printf 'cycle.sh: Gate A failed; draft NOT moved to vault\n' >&2
   171	  rm -f "${DRAFT_PATH}"
   172	  exit 3
   173	fi
   174	
   175	# ────────────────────────────────────────────────────────────────────────
   176	# Step 13 — Atomic vault write (per ADR-003 §3.3.4 atomic-write protocol)
   177	# ────────────────────────────────────────────────────────────────────────
   178	
   179	mv -f "${DRAFT_PATH}" "${REPORT_PATH}"
   180	chmod 600 "${REPORT_PATH}"
   181	
   182	hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
   183	  "$(shasum "${REPORT_PATH}" | awk '{print $1}')" \
   184	  "$(printf '{"vault_path":"%s","firm_name":"%s","tenant":"%s"}' \
   185	      "${REPORT_PATH}" "${FIRM_NAME}" "${CTX_TENANT_SLUG}")" >/dev/null
   186	
   187	printf '\n\033[1;32mDiagnostic report written:\033[0m %s\n' "${REPORT_PATH}"
   188	
   189	# ────────────────────────────────────────────────────────────────────────
   190	# Step 14 — Optional notify
   191	# ────────────────────────────────────────────────────────────────────────
   192	
   193	if [[ "${NOTIFY_VIA}" == "telegram" ]]; then
   194	  if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_OPERATOR_CHAT_ID:-}" ]]; then
   195	    SUMMARY=$(head -200 "${REPORT_PATH}" | sed 's/[^[:print:][:space:]]//g' | head -c 200)
   196	
   197	    # Emit decision_log row BEFORE the send per agent.md §4 Step 11 spec —
   198	    # operator_notify_telegram is green-tier per autosend-policy.yaml so the
   199	    # send executes regardless; this row records the action for audit.
   200	    NOTIFY_PAYLOAD=$(printf '{"recipient":"operator","chat_id":"%s","report_path":"%s","firm":"%s","summary_len":%d}' \
   201	      "${TELEGRAM_OPERATOR_CHAT_ID}" \
   202	      "${REPORT_PATH}" \
   203	      "${FIRM_NAME}" \
   204	      "${#SUMMARY}")
   205	    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
   206	      "$(echo "${NOTIFY_PAYLOAD}" | shasum | awk '{print $1}')" \
   207	      "${NOTIFY_PAYLOAD}" 2>/dev/null || true
   208	
   209	    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
   210	      -d "chat_id=${TELEGRAM_OPERATOR_CHAT_ID}" \
   211	      -d "text=Diagnostic report ready: ${FIRM_NAME} → ${REPORT_PATH}%0A%0A${SUMMARY}..." \
   212	      >/dev/null 2>&1 || \
   213	      printf 'cycle.sh: telegram notify failed (non-fatal)\n' >&2
   214	  else
   215	    printf 'cycle.sh: --notify-via telegram set but credentials missing; skipped\n' >&2
   216	  fi
   217	fi
   218	
   219	# Call cleanup (drop transient LinkedIn cache per ToS gotcha §6.1)
   220	bash "${CTX_AGENT_DIR}/cleanup.sh" 2>/dev/null || true
   221	
   222	exit 0

 succeeded in 0ms:
     1	# Diagnostic agent — MCP tool declarations
     2	#
     3	# Status: Proposed (pre-W3-build scaffold; Day-11 author, awaits W3-4 build).
     4	# Author: Claude Code (initial scaffold) + W3 build slice
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
/bin/zsh -lc "nl -ba docs/decisions/sequencing-target.md | sed -n '92,104p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '487,500p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba packages/agents-runtime/_shared/common-target-patch.json | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

 succeeded in 0ms:
     1	{
     2	  "$schema": "https://json-schema.org/draft/2020-12/schema",
     3	  "$id": "https://intelforce.os/schemas/common-target-patch.json",
     4	  "title": "common-target-patch",
     5	  "description": "Tenant's commercial sweet spot: sectors, geography, deal sizes, allow/block lists. Read by Sourcing Scout (W9) + Diagnostic (W3-4). Per PRODUCT-SPEC §5.3 line 363.",
     6	  "type": "object",
     7	  "properties": {
     8	    "sectors": {
     9	      "type": "array",
    10	      "items": { "type": "string" },
    11	      "minItems": 0,
    12	      "description": "Tenant's target sectors; e.g. ['fintech', 'public-sector-tech', 'climate']. Free-form strings."
    13	    },
    14	    "geographies": {
    15	      "type": "array",
    16	      "items": { "type": "string" },
    17	      "minItems": 0,
    18	      "default": ["UK"],
    19	      "description": "ISO-3166-alpha-2 codes or region labels; UK first per master brief §4."
    20	    },
    21	    "size_bands": {
    22	      "type": "array",
    23	      "items": {
    24	        "type": "string",
    25	        "enum": ["startup-1-50", "scaleup-50-250", "midmarket-250-1000", "enterprise-1000-plus"]
    26	      },
    27	      "default": ["scaleup-50-250"],
    28	      "description": "Headcount bands defining typical client size."
    29	    },
    30	    "deal_size_band_gbp": {
    31	      "type": "object",
    32	      "properties": {
    33	        "perm_min": { "type": "number", "minimum": 0, "default": 5000 },
    34	        "perm_max": { "type": "number", "minimum": 0, "default": 50000 },
    35	        "contract_day_rate_min": { "type": "number", "minimum": 0, "default": 400 },
    36	        "contract_day_rate_max": { "type": "number", "minimum": 0, "default": 1500 }
    37	      },
    38	      "description": "Bands surface in Diagnostic ICP scoring + Sourcing Scout shortlist filtering."
    39	    },
    40	    "named_allowlist": {
    41	      "type": "array",
    42	      "items": { "type": "string" },
    43	      "default": [],
    44	      "description": "Explicit firm names always in-scope (overrides sectors/size filters)."
    45	    },
    46	    "named_blocklist": {
    47	      "type": "array",
    48	      "items": { "type": "string" },
    49	      "default": [],
    50	      "description": "Explicit firm names always out-of-scope (overrides other includes)."
    51	    },
    52	    "competitor_blocklist": {
    53	      "type": "array",
    54	      "items": { "type": "string" },
    55	      "default": [],
    56	      "description": "Competing recruitment firms; agents must not contact their candidates."
    57	    }
    58	  },
    59	  "required": ["sectors", "geographies"],
    60	  "additionalProperties": false
    61	}

exec
/bin/zsh -lc "nl -ba packages/agents-runtime/_shared/common-voice.json | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|stock KB|kb-|brain system|Postgres|postgres|decision_log|/vault" agents/recruitment/diagnostic/agent.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
16:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
137:    → write to /vault/{tenant_slug}/diagnostic-reports/{firm-slug}-{ISO-date}.md
162:**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
173:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `payload.action_type='consultant_feedback'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with a payload action_type marker rather than a new sentinel.
258:1. **LinkedIn ToS — cannot store profile data beyond the audit.** Profile fetches are cached only for the duration of the report generation (typ. 10-15 min). After report writes to vault, raw profile data is dropped from agent memory + no persistence in Postgres.

exec
/bin/zsh -lc "rg -n \"Weeks 3-4|W3-4|Diagnostic|Sales tool|needed before any other agent matters|§8\\.2|8\\.2\" . -g '*.md' -g '*.yaml' | head -200" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
./docs/architecture/tenancy-invariants.md:4:**Date:** 2026-05-20 (Day 9 evening — pre-Diagnostic-build architecture audit).
./docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
./pnpm-lock.yaml:13:        version: 8.20.0
./pnpm-lock.yaml:16:        version: 3.0.1(ajv@8.20.0)
./pnpm-lock.yaml:788:  ajv@8.20.0:
./pnpm-lock.yaml:1019:  mlly@1.8.2:
./pnpm-lock.yaml:1690:  ajv-formats@3.0.1(ajv@8.20.0):
./pnpm-lock.yaml:1692:      ajv: 8.20.0
./pnpm-lock.yaml:1694:  ajv@8.20.0:
./pnpm-lock.yaml:1881:      mlly: 1.8.2
./pnpm-lock.yaml:1966:  mlly@1.8.2:
./pnpm-lock.yaml:2006:      mlly: 1.8.2
./agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
./agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
./agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
./agents/_shared/escalation-codes.md:379:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
./docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
./docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
./docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
./docs/RISK-REGISTER.md:35:| 14 | **Scripts authored Days 8+ never executed end-to-end against live until 2026-05-23** — Day-9 cohesion review claimed "foundation is sound for Diagnostic build" based on code+docs review, but no helper / migration / script had been exercised against live Postgres. Day-12 first execution surfaced 6 distinct drifts (password, DB name, TRIGGER grant, GUC rename, missing tenants row, table ownership/RLS-bypass). | High (now historical; mitigated) | High at time of discovery — any of the 6 could have manifested at first pilot LOI as silent failure or data leak. | Future script/migration authoring without an explicit "first live execution against migration-test tenant" milestone listed in the plan. | Day-12 closed loop: live migration 24/24 + tenancy audit 24/24. Future: every new script touching live Postgres must include a verified-on-VPS milestone in its acceptance criteria, not just unit-test-layer green. Day-9 cohesion review template updated to require live verification before "foundation verified" verdict. | **Mitigated.** Discovery surfaces a class lesson: ratification at code-and-docs layer is necessary but not sufficient; live execution is the third leg. |
./docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
./docs/RISK-REGISTER.md:65:- 2026-05-20 (Day 9 evening) — **Architecture + tenancy verification slice complete.** 3 commits (`5c3fa66` + `c4348aa` + this commit). 4 new artefacts: tenancy-invariants.md (Reference; 12 invariants T1-T12 single source of truth), run-tenancy-audit.sh (multi-tenant adversarial smoke), architecture-cohesion-review.md (8-artefact cohesion + 14 remediation items + 4-boundary adversarial walk), tenant-lifecycle.md (Provision/Operate/Suspend/Offboard/Migrate). All 4 master-brief §3 boundaries verified HOLD at current artefact set. 3 of 5 contradictions in the ratified artefact set RESOLVED via ADR-004 + Day-8 remediation; 1 RESOLVED via consolidation in tenancy-invariants.md; 1 OPEN pending Founder Decision D3 (PII retention). 8 implicit assumptions documented; 3 catastrophic-if-false verified empirically. No new risks added — cohesion review's 14 remediation items + lifecycle's 8 gaps are all variance bounded by existing risks (#5 renderer + #10 PII + others) or low-severity lazy specs. Foundation deemed sound for Diagnostic build conditional on founder-decision bundle (D1+D2+D3) + Codex Round 2 closure + live tenancy audit pass.
./docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
./docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
./agents/_shared/README.md:88:**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
./agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
./docs/architecture/architecture-cohesion-review.md:3:**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation audit).
./docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
./docs/architecture/architecture-cohesion-review.md:150:| G4 | **The agent runtime's `validate.sh` invocation contract is implicit.** ADR-003 §2.1 row 5 says it's a verbatim copy to `.claude/hooks/validate.sh`. But what does the runtime DO with it? Is it called before every tool use? Once per session? | Medium (every agent uses validate.sh) | Diagnostic W3 build's agent.md preamble names the invocation; pattern propagates. Add to tenant-lifecycle runbook. |
./docs/architecture/architecture-cohesion-review.md:190:**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.
./docs/architecture/architecture-cohesion-review.md:217:**Verdict: BOUNDARY HOLDS at current artefact set.** Same pattern as adapter boundary — needs automated guardrail at Diagnostic W3.
./docs/architecture/architecture-cohesion-review.md:231:| R5 | G4: validate.sh invocation contract | Medium | Document in tenant-lifecycle.md OR Diagnostic agent.md preamble | Claude Code | Diagnostic W3 build |
./docs/architecture/architecture-cohesion-review.md:234:| R8 | Adapter + brain-replacement boundary automation | Medium | `review-agent-bundle.md` Codex skill at Diagnostic W3 | Claude Code | Diagnostic W3 |
./docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
./docs/architecture/architecture-cohesion-review.md:254:**All 4 boundaries (submodule, adapter, vault/Postgres, brain-replacement) hold at current artefact set.** Two need automated guardrails at Diagnostic W3 (adapter + brain-replacement).
./docs/architecture/architecture-cohesion-review.md:256:**The foundation is sound for Diagnostic build, conditional on:**
./docs/architecture/architecture-cohesion-review.md:258:2. R4-R8 documented during this slice (Phase 2.2 + Diagnostic W3)
./docs/architecture/architecture-cohesion-review.md:262:If those four hold, **Diagnostic agent build can begin with high confidence.**
./docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
./docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
./docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
./agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
./docs/build-brief/00-MASTER-BRIEF.md:591:### 8.2 The build order — v1.0 only
./docs/build-brief/00-MASTER-BRIEF.md:595:| 1 | Diagnostic | 3–4 | LinkedIn + Companies House + scrape | Sales tool — needed before any other agent matters |
./docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
./docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
./docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
./docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
./docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:328:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:348:The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:352:This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:358:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:368:### Decision 1 — Diagnostic Gate A citation validation is a two-tier policy (per-section v0 hard-fail + per-claim W4 spot-check warn)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:372:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:376:A statistical sample (1-in-N, configurable per tenant; default 1-in-10) of Diagnostic reports undergo post-render per-claim citation validation:
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:387:**Owner of both schema supplements:** Claude Code. **Trigger:** W4-polish (after Diagnostic v0 first-pilot launch); estimated 2026-06-21 to 2026-06-28. **Sequencing constraint:** Tier 2 sampling MUST NOT activate until BOTH supplements (autosend-safety-policy §7 audit-shape supplement + v0.3 vertical-schema supplement) land AND ratify via Codex. This ADR's Decision 1 stands; Decision 1's Tier 2 mechanism is architecturally specified, but the concrete payload + config-field shapes are downstream schema work outside this ADR's scope.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:391:When the voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports, the per-claim spot-check pipeline activates. Until then, Tier 2 is documented intent only.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:416:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:446:- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the unchanged ULTRAPLAN line 497 prose alone)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md:483:- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
./docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
./docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
./docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
./docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
./docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
./docs/verticals/recruitment/vertical-schema.yaml:671:  Diagnostic:
./docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
./docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
./docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
./packages/diagnostic-generator/README.md:64:v0.1 — Diagnostic W3 pre-build per `agents/recruitment/diagnostic/agent.md` + `docs/operations/goal-option-c-diagnostic-end-to-end.md`.
./agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
./agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
./agents/recruitment/cash-conductor/agent.md:283:This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
./agents/recruitment/cash-conductor/agent.md:337:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
./agents/recruitment/cash-conductor/agent.md:381:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
./agents/recruitment/cash-conductor/agent.md:398:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
./agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
./agents/recruitment/janitor/agent.md:125:   → 7-day cache per tools.yaml; rate-limit budget shared with Diagnostic
./agents/recruitment/janitor/agent.md:248:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ Week 3 in progress |
./docs/specs/ULTRAPLAN.md:97:- The Diagnostic agent (sales tool)
./docs/specs/ULTRAPLAN.md:265:4. Run a single dry-run agent invocation (the Diagnostic) to validate the path end-to-end.
./docs/specs/ULTRAPLAN.md:487:#### A1. The Diagnostic — the sales tool
./docs/specs/ULTRAPLAN.md:571:### 8.2 v1.1 agents (seven, in build order)
./docs/specs/ULTRAPLAN.md:685:| Diagnostic | ✓ | | | | ✓ | ✓ | | | | | Web scraper |
./docs/specs/ULTRAPLAN.md:750:### Weeks 3–4 — Bullhorn + Diagnostic
./docs/specs/ULTRAPLAN.md:753:- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint
./docs/specs/ULTRAPLAN.md:755:Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact.
./agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:1:# Diagnostic fixture — 99-voice-drift-canary
./agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
./agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
./agents/recruitment/scribe/agent.md:290:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
./docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
./docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
./docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
./docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
./docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
./docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
./docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
./agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
./agents/recruitment/sourcing-scout/agent.md:90:## Diagnostic + exception list
./agents/recruitment/sourcing-scout/agent.md:295:| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
./agents/recruitment/diagnostic/fixtures/01-primary.yaml:1:# Diagnostic fixture — 01-primary
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:341:# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:361:The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:365:This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:371:This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:381:### Decision 1 — Diagnostic Gate A citation validation is a two-tier policy (per-section v0 hard-fail + per-claim W4 spot-check warn)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:385:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:389:A statistical sample (1-in-N, configurable per tenant; default 1-in-10) of Diagnostic reports undergo post-render per-claim citation validation:
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:400:**Owner of both schema supplements:** Claude Code. **Trigger:** W4-polish (after Diagnostic v0 first-pilot launch); estimated 2026-06-21 to 2026-06-28. **Sequencing constraint:** Tier 2 sampling MUST NOT activate until BOTH supplements (autosend-safety-policy §7 audit-shape supplement + v0.3 vertical-schema supplement) land AND ratify via Codex. This ADR's Decision 1 stands; Decision 1's Tier 2 mechanism is architecturally specified, but the concrete payload + config-field shapes are downstream schema work outside this ADR's scope.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:404:When the voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports, the per-claim spot-check pipeline activates. Until then, Tier 2 is documented intent only.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:429:- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:459:- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the unchanged ULTRAPLAN line 497 prose alone)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:496:- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:530:   487	#### A1. The Diagnostic — the sales tool
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:551:     1	# ADR-006 — Diagnostic Gate A hybrid (per-section v0 + per-claim W4 spot-check)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:571:    21	The "no claims unsupported by source data" clause implies **per-claim citation validation** — every factual claim in the report must have a backing source link. The Diagnostic v0 implementation at `agents/recruitment/diagnostic/validate.sh` enforces **per-section citation** (regex `\[.+\]\(.+\)` requires ≥1 markdown link per section); per-claim validation is NOT implemented at v0.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:575:    25	This creates a documented gap between the upstream spec and the v0 implementation. Codex Round 4-9 has flagged this as "Gate A weakens ULTRAPLAN source-data requirement" across 10 ratification rounds (see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` Round 9 Diagnostic finding #1). Per-claim citation validation requires:
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:581:    31	This is genuinely hard engineering work — single-week W3 build slice cannot deliver it correctly. The honest options are: (a) defer Diagnostic v0 launch until per-claim validation lands (likely W6+ before any pilot tenant sees a Diagnostic report — pushes past Trigger 2 firing date 2026-06-14), (b) launch v0 with per-section validation + W4 polish for per-claim spot-check sampling, (c) amend ULTRAPLAN to match v0 implementation reality.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:591:    41	### Decision 1 — Diagnostic Gate A citation validation is a two-tier policy (per-section v0 hard-fail + per-claim W4 spot-check warn)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:595:    45	Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:599:    49	A statistical sample (1-in-N, configurable per tenant; default 1-in-10) of Diagnostic reports undergo post-render per-claim citation validation:
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:610:    60	**Owner of both schema supplements:** Claude Code. **Trigger:** W4-polish (after Diagnostic v0 first-pilot launch); estimated 2026-06-21 to 2026-06-28. **Sequencing constraint:** Tier 2 sampling MUST NOT activate until BOTH supplements (autosend-safety-policy §7 audit-shape supplement + v0.3 vertical-schema supplement) land AND ratify via Codex. This ADR's Decision 1 stands; Decision 1's Tier 2 mechanism is architecturally specified, but the concrete payload + config-field shapes are downstream schema work outside this ADR's scope.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:614:    64	When the voice classifier microservice ships + first pilot tenant accumulates ≥30 Diagnostic reports, the per-claim spot-check pipeline activates. Until then, Tier 2 is documented intent only.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:639:    89	- Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 KILL per `docs/decisions/v1.0-kill-criterion.md` §Trigger 2 line 63 threshold: "Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic` by end of Week 3 (2026-06-14)... renderer exits 0, no ESC_RENDERER_FAILED rows in decision_log, validate.sh passes against all three fixtures") fires in 21 days from Day 19. Validate.sh is part of the Trigger 2 success criterion; deferring per-claim validation work into validate.sh would extend the build slice past 2026-06-14 with high confidence (per-claim NLP pipeline + tuning ≈ 6 weeks)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:669:   119	- Codex Round 10+ on Diagnostic agent.md should accept the Gate A framing because the upstream contract is now this ADR (not the unchanged ULTRAPLAN line 497 prose alone)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:706:   156	- Diagnostic agent.md §1 + §5 cite ADR-006 explicitly (next commit)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:721:    63	**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:727:    69	**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:737:/bin/zsh -lc 'rg -n "Round 9|Diagnostic finding #1|ADR-006|Cat-ζ|Cat-1|Gate A weakens" docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md' in /Users/madsadmin/code/CortexOS
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:739:256:- Cat-1 (Gate A hybrid): Diagnostic §1 verified already correct
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:741:348:## Phase 4 — Cat-γ widening + Cat-δ Diagnostic polish + Round 9 (2026-05-24, founder "proceed" instruction)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:748:404:- **B) Add ADR-006 (Diagnostic Gate A hybrid)** — formal architecture decision explicitly amending ULTRAPLAN A1 to the hybrid framing; ratified separately by Codex via review-architecture-decision skill. Likely accepted because ADR ratification path treats the decision as authoritative.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:752:413:**Stopping condition met:** founder's "proceed" → Cat-γ widening + Cat-δ Diagnostic polish + Round 9 + this categorization is the conclusive "RATIFY-or-document-disagreement" outcome per the bilateral disposition. No further autonomous remediation will be attempted.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:753:416:1. **ADR-006 Diagnostic Gate A hybrid** — closes Cat-1/Cat-ζ disagreement permanently for Diagnostic + sets pattern for other agents' Gate A framings
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:755:426:| Diagnostic | Pre-Build-Round-9-Reviewed | 5 (1 Cat-ζ + 4 Cat-α) | ADR-006 lands; mechanical §6/§8 cleanup |
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:776:     4	# Diagnostic agent — validate.sh (Gate A enforcement)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:1090:agents/recruitment/diagnostic/validate.sh:4:# Diagnostic agent — validate.sh (Gate A enforcement)
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:1126:agents/recruitment/diagnostic/agent.md:16:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A hard-fails on any section missing its citation. (Per-claim citation validation is a W4 polish item; the v0 contract requires per-section coverage as a tractable Gate-A check.) The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:1151:   158	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces the following SPEC. **Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements most of these checks today but warns-only on two upstream-unavailable cases (voice-classifier URL unreachable, firm-domain whitelist absent). Hard-fail behaviour on those two cases is a W4 polish item; current v0 honesty-flags them in `decision_log` payload with `validate_check_skipped=true` instead of hard-failing. The spec below describes the W4-complete contract; the W4 build slice closes the two gaps.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:1162:   169	Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `payload.action_type='consultant_feedback'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with a payload action_type marker rather than a new sentinel.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:1187:docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:45:Every one of the 12 sections in the rendered Diagnostic Markdown report MUST contain ≥1 evidence link (markdown link of the form `[label](url)`). Implemented at `agents/recruitment/diagnostic/validate.sh` via regex check per section heading. Hard-fail on miss → `ESC_AGENT_OUTPUT_SHAPE`.
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:1210:docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:1211:docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
./logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md:1239:   186	- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
./agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:1:# Diagnostic fixture — 02-edge-case-no-online-footprint
./docs/specs/_archive-build-handoff.md:377:| 1 | **Diagnostic** | 3–4 | LinkedIn + Companies House + web scrape | Sales tool — needed for pitch before any other agent matters |
./docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
./packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
./agents/recruitment/diagnostic/README.md:1:# Diagnostic — directory README
./agents/recruitment/diagnostic/README.md:3:**Status:** Proposed (Day-11 pre-build scaffold; awaits W3-4 build slice).
./agents/recruitment/diagnostic/tools.yaml:1:# Diagnostic agent — MCP tool declarations
./agents/recruitment/diagnostic/tools.yaml:3:# Status: Proposed (pre-W3-build scaffold; Day-11 author, awaits W3-4 build).
./agents/recruitment/diagnostic/tools.yaml:168:# Tools NOT in this manifest that Diagnostic must NEVER call:
./agents/recruitment/diagnostic/tools.yaml:170:  - bullhorn       # Diagnostic is sales-tool tier; no ATS touch per sequencing-target.md §2.1
./docs/specs/PRODUCT-SPEC.md:173:#### R13. The Diagnostic — the sales motion, productised
./docs/specs/PRODUCT-SPEC.md:324:- 90-minute discovery call (driven by the Diagnostic output).
./docs/specs/PRODUCT-SPEC.md:471:- The Diagnostic (sales tool; already drafted)
./agents/recruitment/diagnostic/agent.md:1:# Diagnostic — the sales tool
./agents/recruitment/diagnostic/agent.md:6:**Build wave:** v1.0 W3-4 per master brief §8.2 row 1 (anchor wave). First v1.0 agent; first production render exercise of the renderer at `packages/agent-renderer/`.
./agents/recruitment/diagnostic/agent.md:16:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A's per-section citation subcheck hard-fails on any section missing its citation, per `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). ADR-006 establishes Gate A as per-section hard-fail; per-claim citation analysis is a separate post-launch quality metric outside Gate A (future W4 ADR + schema supplements). The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
./agents/recruitment/diagnostic/agent.md:33:Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY) → exits within 10-15 min per Ultraplan §8.1 A1 turnaround target.
./agents/recruitment/diagnostic/agent.md:136:    → render report from sections 1-12 using Diagnostic-specific template
./agents/recruitment/diagnostic/agent.md:158:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
./agents/recruitment/diagnostic/agent.md:173:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `payload.action_type='consultant_feedback'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with a payload action_type marker rather than a new sentinel.
./agents/recruitment/diagnostic/agent.md:175:Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
./agents/recruitment/diagnostic/agent.md:181:Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:
./agents/recruitment/diagnostic/agent.md:190:| `ESC_RENDERER_FAILED` | (not Diagnostic's concern; renderer escalation only) | — | — |
./agents/recruitment/diagnostic/agent.md:192:Diagnostic does NOT use:
./agents/recruitment/diagnostic/agent.md:194:- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
./agents/recruitment/diagnostic/agent.md:195:- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
./agents/recruitment/diagnostic/agent.md:196:- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
./agents/recruitment/diagnostic/agent.md:217:Diagnostic build cannot start until ALL of the following are confirmed:
./agents/recruitment/diagnostic/agent.md:276:*End of Diagnostic agent.md draft.*
./docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
./docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
./docs/architecture/second-brain-design.md:776:| Diagnostic | N/A | doesn't touch the per-tenant vault |
./docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
./legacy/v1/docs/phase-1-poc-stack/platform-specs/webhook-receiver-spec.md:264:### 8.2 In-memory cache
./docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
./agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
./agents/recruitment/concierge/agent.md:355:| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
./docs/_supplementary/PRD-autonomous-agent.md:1143:  "overall_score": 8.2,
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:162:## §1 — agent.md required-section structure (per ADR-003 + Diagnostic precedent)
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:170:| §2 | Invocation surface | CLI / webhook / cron / Brain UI / Telegram triggers; per-trigger auth requirements; v1.1+ deferred surfaces | Missing; lists surfaces not supported by master brief §8.2 (e.g. uses AgentMail before v1.1) |
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:171:| §3 | Output shape | Specific to agent. Diagnostic: 12 sections. Janitor: day-30 report + Bullhorn writes. Cash Conductor: reconciliation rows + chase drafts + weekly report | Missing; doesn't name the artefact paths; doesn't name the decision_log audit-row signature for each output |
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:188:1. **master brief §8.2 line N** for build wave (e.g. "W5 per master brief §8.2 line 596"). Verify the line range actually contains the row claimed.
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:189:2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:210:agent.md files come in two flavours per the Diagnostic precedent:
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:226:**Production-ready (Status: Accepted OR In Force)** — written AFTER bundle files exist + pass tests. Diagnostic at Day-13 + Day-19 polish is production-ready. Additional requirements:
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:286:## §6 — Special case: Diagnostic agent.md
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:288:Diagnostic was scaffold-ratified at Day-11 (Round 3 RATIFIED) + production-shape polished at Day-13 (commits `97a57a2` + `2688b6a`) + Day-19 remediation (commit `6e0cb86`). Codex Round 4 Phase 1 hit hard ceiling — see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` for the 5-issue disposition.
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:290:When re-ratifying Diagnostic agent.md with THIS skill (not review-architecture-decision):
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:294:- If Issues 1-4 resolve via the founder arbitration recommendations in the disagreement doc (which I'd accept as the right framing for v0), then Diagnostic agent.md should RATIFY under this skill.
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:311:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:321:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:595:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:719:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
./logs/codex-ratification/20260524T115355Z-4405/agents_recruitment_scribe_agent-md.output.md:730:docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.

exec
/bin/zsh -lc "find . -maxdepth 3 -iname '*master*brief*' -o -iname '*master*' | sort" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
./docs/build-brief/00-MASTER-BRIEF.md
./legacy/v1/MASTER-INDEX.md

codex
REJECTED

1. Build/status signal is internally contradictory. Lines 217-233 say the Diagnostic build cannot start and list `validate.sh`, `context.sh`, fixtures, and connectors as “⏸ Not built,” but line 162 says the v0 `validate.sh` exists and implements Gate A today, and the bundle files are present at `agents/recruitment/diagnostic/{tools.yaml,context.sh,validate.sh,cycle.sh,cleanup.sh}` plus all three fixtures. Fix §8 and the Status field to reflect the current production-shape scaffold state, or remove claims about implemented v0 behaviour.

2. Gate A is weaker than the §1/§3 output contract. Line 16 and lines 62-67 state voice-classifier failure is a Gate A hard-fail, but lines 162 and 166 explicitly allow warn-only success when the classifier URL is unreachable; line 169 similarly allows warn-only PII boundary skips. Fix by either making these checks hard-fail now or changing §1/§3 to state the actual v0 Gate A contract without overstating hard-fail coverage.

3. §3 output shape omits required audit-row signatures. Lines 43-67 enumerate the 12 sections and Gate A checks, but the type-specific skill requires §3 to name the artefact path and the `decision_log` audit-row signature for each output. The path appears in §1 and the audit calls appear later in §4, but §3 itself does not satisfy the required structure. Fix §3 to include `/vault/<tenant>/diagnostic-reports/...` plus the `hh_decision_output` / `hh_decision_action` signatures for the report render and optional operator notification.

4. Workflow steps that produce section content or take external actions lack `hh_decision_*` calls. Lines 86-133 perform Companies House lookup, online discovery, LinkedIn harvest, employee scan, pain extraction, scoring, recent activity scan, and opener generation, but no `hh_decision_*` call appears until report assembly at line 138. The document’s own rule at line 73 requires such calls for every output/action step. Fix by adding decision-log calls for each side-effecting/extraction step, or explicitly redefining those steps as non-output internal computation and logging the actual tool actions.

5. Required build-wave citation is incomplete and omits drift handling. Line 6 cites “master brief §8.2 row 1” instead of the required line-specific citation; the live master brief row is `docs/build-brief/00-MASTER-BRIEF.md` line 595. Line 7 cites ULTRAPLAN A1, whose live build wave is week 4-5 at `docs/specs/ULTRAPLAN.md` line 489, which drifts from master brief W3-4. Fix the header to cite master brief line 595 and ULTRAPLAN line 489 with an explicit drift flag naming master brief as authoritative.
tokens used
98,490
REJECTED

1. Build/status signal is internally contradictory. Lines 217-233 say the Diagnostic build cannot start and list `validate.sh`, `context.sh`, fixtures, and connectors as “⏸ Not built,” but line 162 says the v0 `validate.sh` exists and implements Gate A today, and the bundle files are present at `agents/recruitment/diagnostic/{tools.yaml,context.sh,validate.sh,cycle.sh,cleanup.sh}` plus all three fixtures. Fix §8 and the Status field to reflect the current production-shape scaffold state, or remove claims about implemented v0 behaviour.

2. Gate A is weaker than the §1/§3 output contract. Line 16 and lines 62-67 state voice-classifier failure is a Gate A hard-fail, but lines 162 and 166 explicitly allow warn-only success when the classifier URL is unreachable; line 169 similarly allows warn-only PII boundary skips. Fix by either making these checks hard-fail now or changing §1/§3 to state the actual v0 Gate A contract without overstating hard-fail coverage.

3. §3 output shape omits required audit-row signatures. Lines 43-67 enumerate the 12 sections and Gate A checks, but the type-specific skill requires §3 to name the artefact path and the `decision_log` audit-row signature for each output. The path appears in §1 and the audit calls appear later in §4, but §3 itself does not satisfy the required structure. Fix §3 to include `/vault/<tenant>/diagnostic-reports/...` plus the `hh_decision_output` / `hh_decision_action` signatures for the report render and optional operator notification.

4. Workflow steps that produce section content or take external actions lack `hh_decision_*` calls. Lines 86-133 perform Companies House lookup, online discovery, LinkedIn harvest, employee scan, pain extraction, scoring, recent activity scan, and opener generation, but no `hh_decision_*` call appears until report assembly at line 138. The document’s own rule at line 73 requires such calls for every output/action step. Fix by adding decision-log calls for each side-effecting/extraction step, or explicitly redefining those steps as non-output internal computation and logging the actual tool actions.

5. Required build-wave citation is incomplete and omits drift handling. Line 6 cites “master brief §8.2 row 1” instead of the required line-specific citation; the live master brief row is `docs/build-brief/00-MASTER-BRIEF.md` line 595. Line 7 cites ULTRAPLAN A1, whose live build wave is week 4-5 at `docs/specs/ULTRAPLAN.md` line 489, which drifts from master brief W3-4. Fix the header to cite master brief line 595 and ULTRAPLAN line 489 with an explicit drift flag naming master brief as authoritative.
