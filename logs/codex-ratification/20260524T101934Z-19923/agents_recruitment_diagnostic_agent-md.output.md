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
session id: 019e597f-49b5-7182-9a74-b10687ab1f0c
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

> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A hard-fails on any section missing its citation. (Per-claim citation validation is a W4 polish item; the v0 contract requires per-section coverage as a tractable Gate-A check.) The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).

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
    → if no flag: silent completion (consultant checks vault)

12. Session close
    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
    → action tier per autosend-policy.yaml: green (no external send; vault write only)
    → exit code 0
```

---

## §5 — Gates

### Gate A — validate.sh (hard-fail before action)

Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces:

- All 12 sections present in the assembled report (count + heading check)
- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section)
- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3)
- Report length 400-2000 words
- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter)
- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit

### Gate B — Outcome threshold (success metric, not block)

Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='_consultant_feedback'` + `phase='action'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field).

Gate B doesn't block the agent. It contributes to v1.0 kill-criterion §2 Trigger 8 ("Gate-B revenue uplift" — Diagnostic's discovery-call conversion is one of three signals feeding Trigger 8, alongside Janitor day-30 reports and Cash Conductor DSO improvement). Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review (not an immediate trigger fire).

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
| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⏸ Skill not built yet (lazy per execution plan §3) |

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

Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.

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
    16	> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A hard-fails on any section missing its citation. (Per-claim citation validation is a W4 polish item; the v0 contract requires per-section coverage as a tractable Gate-A check.) The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
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
   142	    → if no flag: silent completion (consultant checks vault)
   143	
   144	12. Session close
   145	    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
   146	    → action tier per autosend-policy.yaml: green (no external send; vault write only)
   147	    → exit code 0
   148	```
   149	
   150	---
   151	
   152	## §5 — Gates
   153	
   154	### Gate A — validate.sh (hard-fail before action)
   155	
   156	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces:
   157	
   158	- All 12 sections present in the assembled report (count + heading check)
   159	- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section)
   160	- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3)
   161	- Report length 400-2000 words
   162	- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter)
   163	- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit
   164	
   165	### Gate B — Outcome threshold (success metric, not block)
   166	
   167	Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='_consultant_feedback'` + `phase='action'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field).
   168	
   169	Gate B doesn't block the agent. It contributes to v1.0 kill-criterion §2 Trigger 8 ("Gate-B revenue uplift" — Diagnostic's discovery-call conversion is one of three signals feeding Trigger 8, alongside Janitor day-30 reports and Cash Conductor DSO improvement). Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review (not an immediate trigger fire).
   170	
   171	---
   172	
   173	## §6 — Escalation codes
   174	
   175	Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:
   176	
   177	| Code | Trigger | Severity | Routing |
   178	|---|---|---|---|
   179	| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
   180	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
   181	| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
   182	| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
   183	| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing | warn | operator_chat_id |
   184	| `ESC_RENDERER_FAILED` | (not Diagnostic's concern; renderer escalation only) | — | — |
   185	
   186	Diagnostic does NOT use:
   187	
   188	- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
   189	- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
   190	- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
   191	
   192	---
   193	
   194	## §7 — Voice + tone constraints
   195	
   196	Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   197	
   198	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
   199	  - No "I hope this finds you well" or other generic openers
   200	  - No salary or commission anchors in cold outreach
   201	  - Specific evidence anchor required (not generic "great company")
   202	- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
   203	- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly.
   204	
   205	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   206	
   207	---
   208	
   209	## §8 — Build dependencies (W3 prerequisites)
   210	
   211	Diagnostic build cannot start until ALL of the following are confirmed:
   212	
   213	| Dependency | Source | Status |
   214	|---|---|---|
   215	| Renderer + `_shared/` substrate | Day-8 + Round-3 commits | ✅ Ratified (Round 3) |
   216	| Live VPS migration applied | `bash scripts/run-live-migration.sh` | ⏸ Founder action |
   217	| Tenancy audit passes 12 invariants | `bash scripts/run-tenancy-audit.sh` | ⏸ Founder action |
   218	| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
   219	| `target_patch.json` for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI (per tenant-lifecycle.md §2) |
   220	| Voice corpus seeded for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI |
   221	| Companies House MCP connector | Build at W3 start (~1 day) | ⏸ Not built |
   222	| LinkedIn read-only MCP connector (or Proxycurl wrapper) | Build at W3 start (~2 days) | ⏸ Not built |
   223	| Web scraper utility (HEAD + first-N-lines) | Build at W3 start (~0.5 day) | ⏸ Not built |
   224	| `validate.sh` Gate A logic (12-section check) | Build at W3 start (~0.5 day) | ⏸ Not built |
   225	| `context.sh` hydration | Build at W3 start (~0.5 day) | ⏸ Not built |
   226	| 3 fixtures with golden outputs (01-primary + 02-edge-case-no-online-footprint + 99-voice-drift-canary) | Build at W3 start (~1 day) | ⏸ Not built |
   227	| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⏸ Skill not built yet (lazy per execution plan §3) |
   228	
   229	**Until ALL ratified items have ⏸ → ✅, W3 build slice does not start.**
   230	
   231	---
   232	
   233	## §9 — Status + open questions
   234	
   235	**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + W3 build slice start.
   236	
   237	**Recommended ratification path:** Author the agent.md draft (this document) Day 11 — frees W3 build to focus on the other 5 bundle files + 3 fixtures, not iterating on output contract under W3 deadline pressure. Founder reviews this draft when convenient; refinements drop in commits between Day 11 and W3 start.
   238	
   239	### Open questions for founder review
   240	
   241	| # | Question | Resolution path |
   242	|---|---|---|
   243	| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
   244	| Q2 | Should §11 (decision-maker map) be a separate section OR rolled into §3 + §4 + §5 + §7 as a sub-row? Currently named as a separate section. | Founder review at agent.md ratification. |
   245	| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | Resolved at W3 start before Companies House + LinkedIn MCP connectors authored. Founder + Claude decide together. |
   246	| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
   247	| Q5 | What's the "firm-slug" canonical form for the output filename? Companies House registration number? URL-slugified firm name? | Recommend Companies House number for stability; canonical-slug fallback for non-UK firms (v1.1+). |
   248	| Q6 | Should §10 (recent activity) include Glassdoor reviews? ToS implications. | Per gotcha §6 below: caution; default OFF for v1.0; explicit founder enable for v1.1+. |
   249	
   250	### Gotchas (carried forward from Ultraplan §8.1 A1)
   251	
   252	1. **LinkedIn ToS — cannot store profile data beyond the audit.** Profile fetches are cached only for the duration of the report generation (typ. 10-15 min). After report writes to vault, raw profile data is dropped from agent memory + no persistence in Postgres.
   253	2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
   254	3. **Glassdoor scraping — uncertain ToS compatibility.** Default OFF for v1.0. Per Q6 above.
   255	
   256	---
   257	
   258	## §10 — When this document ratifies
   259	
   260	Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.

exec
/bin/zsh -lc 'rg -n "Diagnostic|A1|Gate-B|Trigger 8|ESC_VOICE_DRIFT|ESC_INPUT_VALIDATION_FAIL|diagnostic_report_render|common-voice|hh_load_voice|hh_load_tone|hh_load_recent|_consultant_feedback|autosend" docs agents packages .codex 2>/dev/null' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg -n \"ESC_|diagnostic|voice|diagnostic_report_render|Gate-B|Trigger 8|Trigger 1|§8\\.2|A1|Companies House|600 requests|Proxycurl|AgentMail|Composio|packages/harness/cortextos\" docs agents .codex packages -g '"'!agents/recruitment/diagnostic/agent.md'"' 2>/dev/null" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
.codex/ratification/SKILL.md:26:4. **Quality gates before features** — Gate A (`validate.sh` hard-fails) + Gate B (`decision_log` mandatory writes) + autosend-safety-policy tier dispatch. Does this artefact bypass or weaken any gate?
.codex/ratification/review-schema-change.md:80:`agent_access_matrix:` must list every v1.0 agent (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) + state R / W / R+W / none for every entity_type.
.codex/ratification/review-schema-change.md:86:- `Diagnostic` must have `none` or `R` for all entities — Diagnostic doesn't write to Bullhorn per `sequencing-target.md` §2.1
.codex/ratification/review-schema-change.md:164:- **PII flagging missing** — fields holding email/phone/name should have a `notes:` line referencing `autosend-safety-policy §7 payload_preview PII rules`. Not blocking on absence but flag in RATIFIED-with-notes.
packages/diagnostic-generator/src/generate.ts:1:// Top-level Diagnostic report generator. Composes the 12 sections,
packages/diagnostic-generator/src/generate.ts:44:    `# Diagnostic report — ${firmName}`,
packages/diagnostic-generator/src/generate.ts:46:    `**Generated:** ${isoDate} by Intel Force OS Diagnostic agent (v0 — pre-W3 build).`,
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:211:        source: IFOS-derived (lookup against autosend-policy.yaml at edit time)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:212:        notes: References autosend-policy.yaml action_types. Drives per-action-type drift detection (e.g., are bullhorn_note_draft_internal drafts edited more than email_summary_to_customer drafts).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
.codex/ratification/review-architecture-decision.md:118:- If the decision references `payload.tier` or `payload.<key>`: confirm autosend-safety-policy §7 documents the field shape
packages/diagnostic-generator/src/cli.ts:13:  .description("Generate a 12-section Diagnostic report for a UK recruitment firm")
agents/_shared/autosend-policy.yaml:3:# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
agents/_shared/autosend-policy.yaml:4:# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/autosend-policy.yaml:246:  spot_check_queue_path: /vault/{tenant_slug}/spot-checks/   # Where autosend_spot_check_enqueue writes
.codex/ratification/review-agent-bundle.md:11:## §1 — agent.md required-section structure (per ADR-003 + Diagnostic precedent)
.codex/ratification/review-agent-bundle.md:20:| §3 | Output shape | Specific to agent. Diagnostic: 12 sections. Janitor: day-30 report + Bullhorn writes. Cash Conductor: reconciliation rows + chase drafts + weekly report | Missing; doesn't name the artefact paths; doesn't name the decision_log audit-row signature for each output |
.codex/ratification/review-agent-bundle.md:38:2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
.codex/ratification/review-agent-bundle.md:40:4. **autosend-safety-policy.yaml** for tier classifications. Verify the action_type exists in the policy + tier assignment matches.
.codex/ratification/review-agent-bundle.md:50:- Sentinel agent_names invented without registering in the catalogue (e.g. `_consultant_feedback` without an entry in escalation-codes.md or a documented sentinel registry)
.codex/ratification/review-agent-bundle.md:51:- Kill-criterion Trigger references swapped (Trigger 5 cited when content describes Trigger 8 territory)
.codex/ratification/review-agent-bundle.md:59:agent.md files come in two flavours per the Diagnostic precedent:
.codex/ratification/review-agent-bundle.md:75:**Production-ready (Status: Accepted OR In Force)** — written AFTER bundle files exist + pass tests. Diagnostic at Day-13 + Day-19 polish is production-ready. Additional requirements:
.codex/ratification/review-agent-bundle.md:135:## §6 — Special case: Diagnostic agent.md
.codex/ratification/review-agent-bundle.md:137:Diagnostic was scaffold-ratified at Day-11 (Round 3 RATIFIED) + production-shape polished at Day-13 (commits `97a57a2` + `2688b6a`) + Day-19 remediation (commit `6e0cb86`). Codex Round 4 Phase 1 hit hard ceiling — see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` for the 5-issue disposition.
.codex/ratification/review-agent-bundle.md:139:When re-ratifying Diagnostic agent.md with THIS skill (not review-architecture-decision):
.codex/ratification/review-agent-bundle.md:143:- If Issues 1-4 resolve via the founder arbitration recommendations in the disagreement doc (which I'd accept as the right framing for v0), then Diagnostic agent.md should RATIFY under this skill.
agents/_shared/escalation-codes.md:13:The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
agents/_shared/escalation-codes.md:31:Source: `docs/decisions/autosend-safety-policy.md` §5
agents/_shared/escalation-codes.md:43:- **Trigger:** Red-tier action attempted; refused entirely (red is the tier-override floor per autosend §8)
agents/_shared/escalation-codes.md:50:- **Trigger:** `autosend_policy_lookup()` could not resolve a tier for the given `action_type` (unknown action_type, malformed `autosend-policy.yaml`, or tenant override resolution failed)
agents/_shared/escalation-codes.md:120:#### `ESC_VOICE_DRIFT`
agents/_shared/escalation-codes.md:122:- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
agents/_shared/escalation-codes.md:170:#### `ESC_VOICE_DRIFT_TENANT`
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:177:#### `ESC_INPUT_VALIDATION_FAIL`
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:254:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
packages/harness/cortextos/package-lock.json:415:      "integrity": "sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==",
packages/harness/cortextos/package-lock.json:1401:      "integrity": "sha512-RAjXjP/8c6ZtzatZcA1RaQr6O1TRhzC+adn8YZDnChliZHviqIjmvFwHcxi4JKPSDAt6Uhf/7vqcBzQJy0PDJg==",
packages/harness/cortextos/package-lock.json:1818:      "integrity": "sha512-aCj4O5wKyszjMmDT4tZj93kxyydN/K5zPWSCe6/0AV/AA1pqe5ZBIw0a2ZfPQV7lL5/yb5HsUreJ6UFAF1tEQw==",
packages/harness/cortextos/package-lock.json:2065:      "integrity": "sha512-7tN6rFgBlMgpBML5j8typ92BKFi2sFQvIdpAqLA2beia5avZDrMs0FLZiM5etShWq5irVyGcGMEA1jcDaK7A/Q==",
packages/harness/cortextos/package-lock.json:2885:      "integrity": "sha512-bzyZ1e88w9O1iNJbKnOlvYTrWPDl46O1bG0D3XInv+9tkPrxrN8jUUTiFlDkkmKWgn1M6CfIA13SuGqOa9Korw==",
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:192:        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
docs/verticals/recruitment/vertical-schema.yaml:335:        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
docs/verticals/recruitment/vertical-schema.yaml:365:        notes: Free-text JD body. Subject to autosend-policy.md §7 — payload_preview must summarise, not embed full JD.
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:629:    description: Candidates engage with multiple contacts during the interview process (panel interviews, multiple stakeholders). Captures the relationship for autosend-policy `payload_preview` addressee verification.
docs/verticals/recruitment/vertical-schema.yaml:666:# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
docs/verticals/recruitment/vertical-schema.yaml:671:  Diagnostic:
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
packages/utilities/web-scraper/src/client.ts:9:// as an automated client via the more specific "IFOS-Diagnostic/0.1"
packages/utilities/web-scraper/src/client.ts:12:  "IFOS-Diagnostic/0.1 (+https://intelforce.io/contact)";
agents/_shared/hook-helpers.sh:3:# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:31:_HH_POLICY_FILE="${HH_POLICY_FILE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/autosend-policy.yaml}"
agents/_shared/hook-helpers.sh:202:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
agents/_shared/hook-helpers.sh:203:    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
agents/_shared/hook-helpers.sh:205:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
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
agents/_shared/hook-helpers.sh:265:autosend_policy_lookup() {
agents/_shared/hook-helpers.sh:268:    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
agents/_shared/hook-helpers.sh:285:# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:287:# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
agents/_shared/hook-helpers.sh:289:autosend_apply_tenant_override() {
agents/_shared/hook-helpers.sh:300:  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
agents/_shared/hook-helpers.sh:322:    printf 'autosend_apply_tenant_override: refusing to demote %s → %s for %s/%s\n' \
agents/_shared/hook-helpers.sh:329:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
agents/_shared/hook-helpers.sh:330:# Emits the standard autosend decision_log row with payload.tier set.
agents/_shared/hook-helpers.sh:331:autosend_emit_decision_log() {
agents/_shared/hook-helpers.sh:353:# autosend_escalate <ESC_CODE> [<key=value>...]
agents/_shared/hook-helpers.sh:357:autosend_escalate() {
agents/_shared/hook-helpers.sh:362:    printf 'autosend_escalate: unknown ESC code: %s\n' "${code}" >&2
agents/_shared/hook-helpers.sh:386:  # signal. Dispatcher (autosend-syncer) reads recent gating_failed rows and
agents/_shared/hook-helpers.sh:390:# autosend_should_sample <action_type> <tenant_slug>
agents/_shared/hook-helpers.sh:392:# 1 otherwise. Sample rate read from autosend-policy.yaml (sample_rate field);
agents/_shared/hook-helpers.sh:394:autosend_should_sample() {
agents/_shared/hook-helpers.sh:416:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
agents/_shared/hook-helpers.sh:419:autosend_spot_check_enqueue() {
agents/_shared/hook-helpers.sh:428:    printf 'autosend_spot_check_enqueue: cannot mkdir %s\n' "${spot_dir}" >&2
agents/_shared/hook-helpers.sh:451:# autosend_await_approval <action_type> <target> <payload_hash>
agents/_shared/hook-helpers.sh:457:autosend_await_approval() {
agents/_shared/hook-helpers.sh:511:        autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:539:  autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
packages/diagnostic-generator/src/sections/firm-signal.ts:83:      `No active Companies House registration found for **${firmName}**. Diagnostic proceeded against publicly visible non-CH signals only.`,
agents/_shared/README.md:12:| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
agents/_shared/README.md:13:| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
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
agents/_shared/README.md:88:**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
agents/_shared/README.md:167:- `agents/_shared/autosend-policy.yaml` (Reference — runtime table)
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:177:- `docs/decisions/autosend-safety-policy.md` — full tier model + §4 reference impl
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
agents/_shared/tests/test-hook-helpers.sh:82:export HH_POLICY_FILE="${REPO_ROOT}/agents/_shared/autosend-policy.yaml"
agents/_shared/tests/test-hook-helpers.sh:117:printf '\n[3] autosend_policy_lookup resolves each tier\n'
agents/_shared/tests/test-hook-helpers.sh:118:test_lookup_green() { local t; t=$(autosend_policy_lookup "diagnostic_report_render"); _assert_eq "green" "${t}" "green"; }
agents/_shared/tests/test-hook-helpers.sh:119:test_lookup_yellow() { local t; t=$(autosend_policy_lookup "bullhorn_candidate_dedupe"); _assert_eq "yellow" "${t}" "yellow"; }
agents/_shared/tests/test-hook-helpers.sh:120:test_lookup_orange() { local t; t=$(autosend_policy_lookup "bullhorn_note_customer_visible"); _assert_eq "orange" "${t}" "orange"; }
agents/_shared/tests/test-hook-helpers.sh:121:test_lookup_red() { local t; t=$(autosend_policy_lookup "xero_payment_initiate"); _assert_eq "red" "${t}" "red"; }
agents/_shared/tests/test-hook-helpers.sh:122:test_lookup_unknown() { autosend_policy_lookup "nonexistent_action" >/dev/null 2>&1; _assert_rc "1" "$?" "unknown"; }
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
agents/_shared/tests/test-hook-helpers.sh:191:printf '\n[9] autosend_apply_tenant_override — elevation allowed\n'
agents/_shared/tests/test-hook-helpers.sh:193:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
agents/_shared/tests/test-hook-helpers.sh:200:  result=$(autosend_apply_tenant_override "green" "bullhorn_note_internal" "${CTX_TENANT_SLUG}")
agents/_shared/tests/test-hook-helpers.sh:205:printf '\n[10] autosend_apply_tenant_override — demotion refused\n'
agents/_shared/tests/test-hook-helpers.sh:207:  local override_file="${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_config/autosend-overrides.yaml"
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
packages/harness/cortextos/tests/integration/concurrent-cron-mutations.test.ts:132:    // Diagnostic for debugging:
agents/_shared/tests/test-voice-loader.sh:70:printf '\n[1] hh_load_tone_rules returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:73:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:78:printf '\n[2] hh_load_tone_rules reads tone-rules.yaml fallback path\n'
agents/_shared/tests/test-voice-loader.sh:86:  out=$(hh_load_tone_rules)
agents/_shared/tests/test-voice-loader.sh:91:printf '\n[3] hh_load_voice_samples returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:94:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:99:printf '\n[4] hh_load_voice_samples surfaces style guide when present\n'
agents/_shared/tests/test-voice-loader.sh:103:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:110:printf '\n[5] hh_load_voice_samples top_k validation clamps to 10\n'
agents/_shared/tests/test-voice-loader.sh:113:  out=$(hh_load_voice_samples "task" "abc")  # non-numeric → 10
agents/_shared/tests/test-voice-loader.sh:115:  out=$(hh_load_voice_samples "task" "999")  # over cap → 10
agents/_shared/tests/test-voice-loader.sh:117:  out=$(hh_load_voice_samples "task" "0")    # zero → 10
agents/_shared/tests/test-voice-loader.sh:122:printf '\n[6] hh_load_recent_edits returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:125:  out=$(hh_load_recent_edits)
agents/_shared/tests/test-voice-loader.sh:132:printf '\n[7] hh_load_recent_edits accepts custom lookback_days\n'
agents/_shared/tests/test-voice-loader.sh:135:  out=$(hh_load_recent_edits 7 "concierge")
agents/_shared/tests/test-voice-loader.sh:141:printf '\n[8] hh_load_recent_edits lookback_days validation clamps to 30\n'
agents/_shared/tests/test-voice-loader.sh:144:  out=$(hh_load_recent_edits "abc")  # non-numeric → 30
agents/_shared/tests/test-voice-loader.sh:146:  out=$(hh_load_recent_edits "999")   # over cap → 30
agents/_shared/tests/test-voice-loader.sh:148:  out=$(hh_load_recent_edits "0")     # zero → 30
agents/_shared/tests/test-voice-loader.sh:156:  out1=$(hh_load_tone_rules | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:157:  out2=$(hh_load_voice_samples "task" | wc -l | tr -d ' ')
agents/_shared/tests/test-voice-loader.sh:158:  out3=$(hh_load_recent_edits | wc -l | tr -d ' ')
packages/utilities/web-scraper/package.json:5:  "description": "IFOS web scraper utility — HTTP HEAD + first-N-lines fetch + cache + robots.txt. Used by Diagnostic agent §4 Step 3+6+8 per agents/recruitment/diagnostic/tools.yaml.",
packages/utilities/web-scraper/README.md:3:IFOS web scraper utility for Diagnostic agent §4 Step 3 + 6 + 8 per `agents/recruitment/diagnostic/tools.yaml`.
packages/utilities/web-scraper/README.md:13:- **No JavaScript execution.** Lightweight HTTP only. JS-heavy sites return their server-rendered HTML (often a "JavaScript required" placeholder) — graceful degradation per Diagnostic gotcha §6.1.
packages/utilities/web-scraper/README.md:18:- **User agent:** `Mozilla/5.0 (compatible; IFOS-Diagnostic/0.1; +https://intelforce.io/bot)`. Identifies us; not deceptive.
packages/utilities/web-scraper/README.md:22:- **Timeout / connection refused** → returns `null`; logs warning; caller treats as "no signal" per Diagnostic gotcha §6.1.
packages/utilities/web-scraper/README.md:51:v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 539). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 539 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 540) — the FD-tier closer metric. Chase drafts are orange-tier per `autosend-safety-policy.yaml` (consultant approval required before send via Concierge); reconciliation writes are yellow-tier.
agents/recruitment/cash-conductor/agent.md:90:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. Output is a queued draft, NOT a send. Drafts route to Concierge (which handles the actual send pipeline + consultant approval per autosend §4 orange tier).
agents/recruitment/cash-conductor/agent.md:177:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
agents/recruitment/cash-conductor/agent.md:192:   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
agents/recruitment/cash-conductor/agent.md:204:    → Concierge handles autosend-bridge call to operator (D1 path per
agents/recruitment/cash-conductor/agent.md:240:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 539 verbatim):
agents/recruitment/cash-conductor/agent.md:277:| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:278:| `ESC_VOICE_DRIFT_TENANT` | Consultant edit-rate on chase drafts >50% in 30-day window | warn | operator + tenant-admin |
agents/recruitment/cash-conductor/agent.md:293:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:297:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:298:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Edit-distance >150 chars on >40% of chase recent_edits fires `ESC_VOICE_DRIFT_TENANT`.
agents/recruitment/cash-conductor/agent.md:311:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
packages/harness/cortextos/dashboard/src/app/globals.css:172:  --foreground: oklch(0.187 0 0);                /* #1A1A1A */
packages/harness/cortextos/dashboard/src/app/globals.css:222:  --secondary: oklch(0.187 0 0);                 /* #1A1A1A */
packages/harness/cortextos/dashboard/src/app/globals.css:224:  --muted: oklch(0.187 0 0);                    /* #1A1A1A */
packages/utilities/web-scraper/pnpm-lock.yaml:388:    resolution: {integrity: sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==}
packages/utilities/web-scraper/pnpm-lock.yaml:575:    resolution: {integrity: sha512-FJHFfqpKUI3A10WrWKiFbBZ7yVbGT4q4B5o1qKFFojqpaYoh9LrQgqWCmmcxQzVSXYtyB5bzkXrYzlHTs21MYA==}
packages/utilities/web-scraper/pnpm-lock.yaml:630:    resolution: {integrity: sha512-QVTUovf40zgTqlFVrKA1uXMVvU2QWEFWfAH8Wdc48IxLvrJMQVMBRjuQyUpzZCDkakImib9eVazbWlC6ksWtJw==}
packages/utilities/web-scraper/pnpm-lock.yaml:818:    resolution: {integrity: sha512-//nshmD55c46FuFw26xV/xFAaB5HF9Xdap7HJBBnrKdAd6/GxDBaNA1870O79+9ueg61cZLSVc+OaFlfmObYVQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:973:    resolution: {integrity: sha512-o5a9xKjbtuhY6Bi5S3+HvbRERmouabWbyUcpXXUA1u+GNUKoROi9byOJ8M0nHbHYHkYICiMlqxkg1KkYmm25Sw==}
packages/agents-runtime/_shared/common-accounting.json:30:      "description": "Default Cash Conductor cadence; tenant-overridable per autosend-safety-policy §6 tenant-override discipline."
packages/agents-runtime/_shared/common-notifications.json:25:      "description": "Primary surface for orange-tier approval gates per autosend-safety-policy §4."
packages/agents-runtime/_shared/common-notifications.json:49:      "description": "4h default per autosend-safety-policy §5 ESC_AUTOSEND_NEEDS_REVIEW; timeout converts orange-tier to ESC_AUTOSEND_NEEDS_REVIEW row."
packages/agents-runtime/_shared/common-voice.json:3:  "$id": "https://intelforce.os/schemas/common-voice.json",
packages/agents-runtime/_shared/common-voice.json:4:  "title": "common-voice",
packages/agents-runtime/_shared/common-voice.json:26:      "description": "Phrases that trigger ESC_VOICE_DRIFT before classifier scoring."
packages/agents-runtime/_shared/common-voice.json:40:      "description": "Window for hh_load_recent_edits queries against recent_edit table (vertical-schema v0.2)."
packages/agents-runtime/_shared/common-voice.json:46:      "description": "Minimum severity tone_rule that hh_load_tone_rules surfaces to the agent."
packages/agents-runtime/_shared/common-vault.json:21:      "description": "Relative to vault_root; holds _config.yaml + autosend-overrides.yaml."
packages/agents-runtime/_shared/common-vault.json:36:      "description": "Queue directory written by autosend_spot_check_enqueue per autosend-safety-policy §4."
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown attachment containing the consultant's "things I'd write down but there's no field for" observations. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:109:Length cap: 800 words. Voice-classified (≥0.75); falls back to "needs consultant review" placeholder if classifier persistently fails (ESC_VOICE_DRIFT).
agents/recruitment/scribe/agent.md:169:   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
agents/recruitment/scribe/agent.md:202:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:237:| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:256:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `scribe`** — surfaces rules like:
agents/recruitment/scribe/agent.md:260:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:261:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT` (separate from per-run drift).
agents/recruitment/scribe/agent.md:274:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
agents/recruitment/scribe/agent.md:331:- SLA + edit-rate Gate-B metrics measurable
packages/agents-runtime/_shared/common-target-patch.json:5:  "description": "Tenant's commercial sweet spot: sectors, geography, deal sizes, allow/block lists. Read by Sourcing Scout (W9) + Diagnostic (W3-4). Per PRODUCT-SPEC §5.3 line 363.",
packages/agents-runtime/_shared/common-target-patch.json:38:      "description": "Bands surface in Diagnostic ICP scoring + Sourcing Scout shortlist filtering."
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:270:      title: 'A1',
agents/recruitment/sourcing-scout/agent.md:90:## Diagnostic + exception list
agents/recruitment/sourcing-scout/agent.md:98:Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style. Rationale that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.
agents/recruitment/sourcing-scout/agent.md:166:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
agents/recruitment/sourcing-scout/agent.md:193:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 553 verbatim):
agents/recruitment/sourcing-scout/agent.md:231:| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:242:- `ESC_VOICE_DRIFT_TENANT` — per-candidate drift detected at run time (above); no separate 30-day tenant drift signal
agents/recruitment/sourcing-scout/agent.md:250:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `sourcing_scout`** — surfaces rules like:
agents/recruitment/sourcing-scout/agent.md:255:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:256:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT`.
agents/recruitment/sourcing-scout/agent.md:269:| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
packages/diagnostic-generator/package.json:5:  "description": "Diagnostic agent report generator — composes web-scraper + companies-house into a 12-section Markdown report for a UK recruitment firm.",
packages/diagnostic-generator/README.md:64:v0.1 — Diagnostic W3 pre-build per `agents/recruitment/diagnostic/agent.md` + `docs/operations/goal-option-c-diagnostic-end-to-end.md`.
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:61:| 6 | **Gate-B metric** | Composite score: (dedup % improvement × 0.5) + (field-completeness % improvement × 0.5). Target ≥12.5 (≥15% dedup + ≥10% field) per ULTRAPLAN A2 line 511 |
agents/recruitment/janitor/agent.md:67:Per `autosend-safety-policy.yaml` row `janitor_bullhorn_write`. Three write categories:
agents/recruitment/janitor/agent.md:120:   → 7-day cache per tools.yaml; rate-limit budget shared with Diagnostic
agents/recruitment/janitor/agent.md:134:     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
agents/recruitment/janitor/agent.md:138:     tier='yellow'; spot-check sample rate per autosend-policy.yaml row
agents/recruitment/janitor/agent.md:146:   → group by action_type; tally success/fail; compute Gate-B metric
agents/recruitment/janitor/agent.md:149:   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")
agents/recruitment/janitor/agent.md:152:   → if Gate-B target met: green-tier notification with summary
agents/recruitment/janitor/agent.md:153:   → if Gate-B target missed: yellow-tier notification + 200-char executive
agents/recruitment/janitor/agent.md:159:   → exit code 0 (or 1 if Gate-B missed for 3 consecutive runs → ESC_GATE_B_MISS)
agents/recruitment/janitor/agent.md:168:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:186:Gate B doesn't block the agent. It's the v1.0 kill-criterion §2 Trigger 8 supporting metric ("Gate-B revenue uplift" — Janitor's day-30 report is THE artefact that demonstrates "DSO drops" / "consultant time saved" claims to the FD-tier closer).
agents/recruitment/janitor/agent.md:201:| `ESC_VOICE_DRIFT` | Tacit-note narrative voice classifier <0.75 (after 3 retries) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:204:| `ESC_GATE_B_MISS` | Composite Gate-B score <12.5 for 3 consecutive runs | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:209:- `ESC_VOICE_DRIFT_TENANT` — that's for cross-tenant voice drift; Janitor is per-tenant
agents/recruitment/janitor/agent.md:219:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:223:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:224:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Drift >200 chars on >50% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT`.
agents/recruitment/janitor/agent.md:237:| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ Week 3 in progress |
agents/recruitment/diagnostic/cleanup.sh:3:# Diagnostic agent — cleanup.sh
packages/diagnostic-generator/tests/generate.test.ts:68:      expect(md).toMatch(/^# Diagnostic report — Charterhouse Partners/m);
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:1:# Diagnostic fixture — 99-voice-drift-canary
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:7:# ESC_VOICE_DRIFT row emitted, draft NOT written to vault.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:69:  - escalation_code: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:87:    - "ESC_VOICE_DRIFT"
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/RISK-REGISTER.md:35:| 14 | **Scripts authored Days 8+ never executed end-to-end against live until 2026-05-23** — Day-9 cohesion review claimed "foundation is sound for Diagnostic build" based on code+docs review, but no helper / migration / script had been exercised against live Postgres. Day-12 first execution surfaced 6 distinct drifts (password, DB name, TRIGGER grant, GUC rename, missing tenants row, table ownership/RLS-bypass). | High (now historical; mitigated) | High at time of discovery — any of the 6 could have manifested at first pilot LOI as silent failure or data leak. | Future script/migration authoring without an explicit "first live execution against migration-test tenant" milestone listed in the plan. | Day-12 closed loop: live migration 24/24 + tenancy audit 24/24. Future: every new script touching live Postgres must include a verified-on-VPS milestone in its acceptance criteria, not just unit-test-layer green. Day-9 cohesion review template updated to require live verification before "foundation verified" verdict. | **Mitigated.** Discovery surfaces a class lesson: ratification at code-and-docs layer is necessary but not sufficient; live execution is the third leg. |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:65:- 2026-05-20 (Day 9 evening) — **Architecture + tenancy verification slice complete.** 3 commits (`5c3fa66` + `c4348aa` + this commit). 4 new artefacts: tenancy-invariants.md (Reference; 12 invariants T1-T12 single source of truth), run-tenancy-audit.sh (multi-tenant adversarial smoke), architecture-cohesion-review.md (8-artefact cohesion + 14 remediation items + 4-boundary adversarial walk), tenant-lifecycle.md (Provision/Operate/Suspend/Offboard/Migrate). All 4 master-brief §3 boundaries verified HOLD at current artefact set. 3 of 5 contradictions in the ratified artefact set RESOLVED via ADR-004 + Day-8 remediation; 1 RESOLVED via consolidation in tenancy-invariants.md; 1 OPEN pending Founder Decision D3 (PII retention). 8 implicit assumptions documented; 3 catastrophic-if-false verified empirically. No new risks added — cohesion review's 14 remediation items + lifecycle's 8 gaps are all variance bounded by existing risks (#5 renderer + #10 PII + others) or low-severity lazy specs. Foundation deemed sound for Diagnostic build conditional on founder-decision bundle (D1+D2+D3) + Codex Round 2 closure + live tenancy audit pass.
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
agents/recruitment/diagnostic/fixtures/01-primary.yaml:1:# Diagnostic fixture — 01-primary
agents/recruitment/diagnostic/fixtures/01-primary.yaml:106:    action_type: diagnostic_report_render
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:1:# Diagnostic fixture — 02-edge-case-no-online-footprint
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:101:    action_type: diagnostic_report_render
agents/recruitment/diagnostic/cycle.sh:3:# Diagnostic agent — cycle.sh (workflow orchestration)
agents/recruitment/diagnostic/cycle.sh:12:# Per ADR-003 + sequencing-target.md §2.1: Diagnostic is Tier 2 (request-
agents/recruitment/diagnostic/cycle.sh:182:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:187:printf '\n\033[1;32mDiagnostic report written:\033[0m %s\n' "${REPORT_PATH}"
agents/recruitment/diagnostic/cycle.sh:198:      -d "text=Diagnostic report ready: ${FIRM_NAME} → ${REPORT_PATH}%0A%0A${SUMMARY}..." \
agents/recruitment/diagnostic/README.md:1:# Diagnostic — directory README
docs/architecture/tenancy-invariants.md:4:**Date:** 2026-05-20 (Day 9 evening — pre-Diagnostic-build architecture audit).
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/architecture/tenancy-invariants.md:253:| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |
agents/recruitment/diagnostic/tools.yaml:1:# Diagnostic agent — MCP tool declarations
agents/recruitment/diagnostic/tools.yaml:137:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:140:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:168:# Tools NOT in this manifest that Diagnostic must NEVER call:
agents/recruitment/diagnostic/tools.yaml:170:  - bullhorn       # Diagnostic is sales-tool tier; no ATS touch per sequencing-target.md §2.1
docs/architecture/architecture-cohesion-review.md:3:**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation audit).
docs/architecture/architecture-cohesion-review.md:74:| vault-concurrency.md §6 | ESC wiring | hook-helpers.sh::autosend_escalate | ✓ landed Phase 3 (e6e9df1) |
docs/architecture/architecture-cohesion-review.md:88:| A1 | **Postgres `current_setting('app.current_tenant', TRUE)` returns NULL when unset, never empty string.** RLS predicate `tenant_slug = current_setting(...)` relies on NULL≠'anything' semantics. | Every RLS policy on every tenant-data table | If empty string is returned, an INSERT with `tenant_slug=''` could leak across tenants. Postgres docs confirm NULL behaviour; assumption holds. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:123:### C4 — `recent_edit` PII vs autosend payload_preview discipline (OPEN — pending D3)
docs/architecture/architecture-cohesion-review.md:125:- **autosend-safety-policy.md** §7 says `payload_preview` MUST exclude raw PII (max 500 chars, no names/phones/emails)
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:150:| G4 | **The agent runtime's `validate.sh` invocation contract is implicit.** ADR-003 §2.1 row 5 says it's a verbatim copy to `.claude/hooks/validate.sh`. But what does the runtime DO with it? Is it called before every tool use? Once per session? | Medium (every agent uses validate.sh) | Diagnostic W3 build's agent.md preamble names the invocation; pattern propagates. Add to tenant-lifecycle runbook. |
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:190:**Verdict: BOUNDARY HOLDS at current artefact set.** Future agents need automated guardrail; queue as Phase-1 extension OR `review-agent-bundle.md` skill at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:217:**Verdict: BOUNDARY HOLDS at current artefact set.** Same pattern as adapter boundary — needs automated guardrail at Diagnostic W3.
docs/architecture/architecture-cohesion-review.md:231:| R5 | G4: validate.sh invocation contract | Medium | Document in tenant-lifecycle.md OR Diagnostic agent.md preamble | Claude Code | Diagnostic W3 build |
docs/architecture/architecture-cohesion-review.md:234:| R8 | Adapter + brain-replacement boundary automation | Medium | `review-agent-bundle.md` Codex skill at Diagnostic W3 | Claude Code | Diagnostic W3 |
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
docs/architecture/architecture-cohesion-review.md:254:**All 4 boundaries (submodule, adapter, vault/Postgres, brain-replacement) hold at current artefact set.** Two need automated guardrails at Diagnostic W3 (adapter + brain-replacement).
docs/architecture/architecture-cohesion-review.md:256:**The foundation is sound for Diagnostic build, conditional on:**
docs/architecture/architecture-cohesion-review.md:258:2. R4-R8 documented during this slice (Phase 2.2 + Diagnostic W3)
docs/architecture/architecture-cohesion-review.md:262:If those four hold, **Diagnostic agent build can begin with high confidence.**
agents/recruitment/diagnostic/validate.sh:4:# Diagnostic agent — validate.sh (Gate A enforcement)
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
packages/agent-renderer/src/synthesis/configJson.ts:26:    "common-voice.json",
packages/harness/cortextos/dashboard/package-lock.json:905:      "integrity": "sha512-hFoiJiTl63nn+kstHGBtewWSKnQLpyb155KHheA1l39uvtO9nWIop1p3udqPcUd/xbF1VLMO4n7OI6p7RbngDg==",
packages/harness/cortextos/dashboard/package-lock.json:1503:      "integrity": "sha512-+LpyBk7L44ZIXwz/VYfglaX/okxezESc6UxDSoyo2Ks6Jxc4Y7sGjpgU9s4PMgqgjj1gZCylTieNamqA1MF7Dg==",
packages/harness/cortextos/dashboard/package-lock.json:3987:      "integrity": "sha512-gPVA1UjRu1Y/IsB/dQEsp2V1pm44Of6+LWvbLc9SDk1c2KhhDRDBUkQCYVWe6f26uJb3fOK8saWMgtX8IrMk3g==",
packages/harness/cortextos/dashboard/package-lock.json:4043:      "integrity": "sha512-cINaoY2z7LVCrfHkIcmvj7osTOtm6VVT16b5oQdS4beibX2SYBwgYLmqhBjA1t51CarSaBuX5YNsWLjsqfW5Cw==",
packages/harness/cortextos/dashboard/package-lock.json:4927:      "integrity": "sha512-zRpUiDwd/xk6ADqPMATG8vc9VPrkck7T07OIx0gnjmJAnHnTVXNQG3vfvWNuiZIkwu9KrKdA1iJKfsfTVxE6NA==",
packages/harness/cortextos/dashboard/package-lock.json:5094:      "integrity": "sha512-aCj4O5wKyszjMmDT4tZj93kxyydN/K5zPWSCe6/0AV/AA1pqe5ZBIw0a2ZfPQV7lL5/yb5HsUreJ6UFAF1tEQw==",
packages/harness/cortextos/dashboard/package-lock.json:5408:      "integrity": "sha512-tdQAmyA18i4J7wprpYq8ClcxZy3SC31QMeByyCFyRt7BVHdREQZ5lpzoe5mFEYZUWe+oq8HBvk9JjpibyEV4Jg==",
packages/harness/cortextos/dashboard/package-lock.json:6056:      "integrity": "sha512-zWwRvqWiuBPr0muUG/78cW3aHROFCNIQ3zpmYDpwdbnt2m+xlNyRWpHBpa2lJjSBit7BQ+RXA1iwbSmu5yJ/EQ==",
packages/harness/cortextos/dashboard/package-lock.json:6249:      "integrity": "sha512-qhabwjQZ1Mk53XzXvmogf8KQ0tG0CQXF0CZ56+2/lVhmObgmaqj7x5A1DSrWdZd3kwI7GTPGUjFne+krRxYmFg==",
packages/harness/cortextos/dashboard/package-lock.json:6311:      "integrity": "sha512-A1rHYb06zjMGAxdLSkN2fXPBwuSaQ0iO5M/hdyS0Ajj1VBaRp0sPD3dn1FhME3c/JluGFbwSxyCfqdSbtQLAHQ==",
packages/harness/cortextos/dashboard/package-lock.json:7221:      "integrity": "sha512-7tN6rFgBlMgpBML5j8typ92BKFi2sFQvIdpAqLA2beia5avZDrMs0FLZiM5etShWq5irVyGcGMEA1jcDaK7A/Q==",
packages/harness/cortextos/dashboard/package-lock.json:7836:      "integrity": "sha512-upqt1SkGkODW9tsGNG5mtXTXtECizwtS2kA161M+gJPc1xdb/Ax629af6YrTwcOeQHbewrPNlE5Dx7kzvXTizA==",
packages/harness/cortextos/dashboard/package-lock.json:7992:      "integrity": "sha512-bCYeRA2rVibKZd+s2625gGnGF/t7DSqDs4dP7CrLA1m7jKWz6pps0LpYLJN8Q64HtmPKJ1hrN3nzPNKFEKOUiQ==",
packages/harness/cortextos/dashboard/package-lock.json:9210:      "integrity": "sha512-OWND8ei3VtNC9h7V60qff3SVobHr996CTwgxubgyQYEpg290h9J0buyECNNJexkFm5sOajh5G116RYA1c8ZMSw==",
packages/harness/cortextos/dashboard/package-lock.json:9979:      "integrity": "sha512-orRsuYpJVw8LdAwqqLykBj9ecS5/cRHlI5+nvTo8LcCKmzDmqVORXtOIYEEQuL9D4BxtA1lm5isAqzQZCoQ6Eg==",
packages/harness/cortextos/dashboard/package-lock.json:10023:      "integrity": "sha512-8Mf2cbV7x1cXPUILADGI3wuhfqWvtiLA1iclTDbFRZkgRQS0NqsPZphna9V+HyTEadheuPmjaJMsbzKQFOzLug==",
packages/harness/cortextos/dashboard/package-lock.json:10531:      "integrity": "sha512-pb/MYmXstAkysRFx8piNI1tGFNQIFA3vkE3Gq4EuA1dF6gHp/+vgZqsCGJapvy8N3Q+4o7FwvquPJcnZ7RYy4g==",
packages/harness/cortextos/dashboard/package-lock.json:11139:      "integrity": "sha512-bzyZ1e88w9O1iNJbKnOlvYTrWPDl46O1bG0D3XInv+9tkPrxrN8jUUTiFlDkkmKWgn1M6CfIA13SuGqOa9Korw==",
packages/harness/cortextos/dashboard/package-lock.json:11459:      "integrity": "sha512-vavAMRXOgBVNF6nyEEmL3DBK19iRpDcoIwW+swQ+CbGiu7lju6t+JklA1MHweoWtadgt4ISVUsXLyDq34ddcwA==",
agents/recruitment/diagnostic/context.sh:4:# Diagnostic agent — context.sh
agents/recruitment/diagnostic/context.sh:29:#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
packages/harness/cortextos/community/skills/system-diagnostics/SKILL.md:8:# System Diagnostics
agents/recruitment/diagnostic/agent.md:1:# Diagnostic — the sales tool
agents/recruitment/diagnostic/agent.md:7:**Build complexity:** M (1 week) per Ultraplan §8.1 A1.
agents/recruitment/diagnostic/agent.md:16:> **Diagnostic produces a single Markdown report at `/vault/<tenant>/diagnostic-reports/<firm-slug>-<ISO-date>.md`** that diagnoses one named UK firm's recruitment-buying signals. The report has exactly **12 sections** (enumerated in §3 below). Each section MUST contain at least **one** evidence link (Companies House URL, LinkedIn URL, or careers-page URL) — Gate A hard-fails on any section missing its citation. (Per-claim citation validation is a W4 polish item; the v0 contract requires per-section coverage as a tractable Gate-A check.) The report ends with a **2-3 sentence conversation opener** written in the consultant's voice (voice-classifier ≥ 0.75 per `common-voice.json`) suitable for cold outreach to the firm's hiring decision-maker. **No external sends** — Diagnostic writes to vault only; consultant reads + uses for prospect calls or directly pastes the conversation opener into LinkedIn/email manually. Typical report length: 600-1000 words. Gate B (success threshold): ≥ 30% of Diagnostic reports result in a discovery call booked within 14 days of generation (per Ultraplan §8.1 A1).
agents/recruitment/diagnostic/agent.md:33:Resolved by cortextOS daemon → spawns Diagnostic in Tier-2 batch mode (no persistent PTY) → exits within 10-15 min per Ultraplan §8.1 A1 turnaround target.
agents/recruitment/diagnostic/agent.md:84:   → ESC_INPUT_VALIDATION_FAIL if firm name malformed (new code added to catalogue this round)
agents/recruitment/diagnostic/agent.md:129:                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
agents/recruitment/diagnostic/agent.md:130:                 constraint = tone rules (hh_load_tone_rules)
agents/recruitment/diagnostic/agent.md:133:   → ESC_VOICE_DRIFT if score < 0.75 after 3 retries
agents/recruitment/diagnostic/agent.md:136:    → render report from sections 1-12 using Diagnostic-specific template
agents/recruitment/diagnostic/agent.md:145:    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:146:    → action tier per autosend-policy.yaml: green (no external send; vault write only)
agents/recruitment/diagnostic/agent.md:156:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Diagnostic's `validate.sh` enforces:
agents/recruitment/diagnostic/agent.md:160:- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3)
agents/recruitment/diagnostic/agent.md:162:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter)
agents/recruitment/diagnostic/agent.md:167:Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='_consultant_feedback'` + `phase='action'`; outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field).
agents/recruitment/diagnostic/agent.md:169:Gate B doesn't block the agent. It contributes to v1.0 kill-criterion §2 Trigger 8 ("Gate-B revenue uplift" — Diagnostic's discovery-call conversion is one of three signals feeding Trigger 8, alongside Janitor day-30 reports and Cash Conductor DSO improvement). Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review (not an immediate trigger fire).
agents/recruitment/diagnostic/agent.md:175:Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:
agents/recruitment/diagnostic/agent.md:179:| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:182:| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
agents/recruitment/diagnostic/agent.md:184:| `ESC_RENDERER_FAILED` | (not Diagnostic's concern; renderer escalation only) | — | — |
agents/recruitment/diagnostic/agent.md:186:Diagnostic does NOT use:
agents/recruitment/diagnostic/agent.md:188:- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
agents/recruitment/diagnostic/agent.md:189:- `ESC_AUTOSEND_*` — Diagnostic's only action is `diagnostic_report_render` (green tier per autosend-policy.yaml)
agents/recruitment/diagnostic/agent.md:190:- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
agents/recruitment/diagnostic/agent.md:198:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:202:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
agents/recruitment/diagnostic/agent.md:203:- **`hh_load_recent_edits` last 30 days for `concierge` + `diagnostic`**: surfaces patterns of how consultant edits agent drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly.
agents/recruitment/diagnostic/agent.md:211:Diagnostic build cannot start until ALL of the following are confirmed:
agents/recruitment/diagnostic/agent.md:243:| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
agents/recruitment/diagnostic/agent.md:250:### Gotchas (carried forward from Ultraplan §8.1 A1)
agents/recruitment/diagnostic/agent.md:270:*End of Diagnostic agent.md draft.*
packages/harness/cortextos/dashboard/public/file.svg:1:<svg fill="none" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><path d="M14.5 13.5V5.41a1 1 0 0 0-.3-.7L9.8.29A1 1 0 0 0 9.08 0H1.5v13.5A2.5 2.5 0 0 0 4 16h8a2.5 2.5 0 0 0 2.5-2.5m-1.5 0v-7H8v-5H3v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1M9.5 5V2.12L12.38 5zM5.13 5h-.62v1.25h2.12V5zm-.62 3h7.12v1.25H4.5zm.62 3h-.62v1.25h7.12V11z" clip-rule="evenodd" fill="#666" fill-rule="evenodd"/></svg>
agents/recruitment/concierge/README.md:14:The customer-comms agent. Highest-stakes v1.0 agent (XL complexity, 4 weeks build). 12 lifecycle events × 2 recipient roles = 24+ comms-template variants per tenant. Orange-tier autosend per `autosend-safety-policy.yaml` — consultant approval mandatory before send.
agents/recruitment/concierge/README.md:20:- `tools.yaml` — Bullhorn R+W + Microsoft Graph + Gmail + voice classifier + autosend bridge (per D1 outcome)
agents/recruitment/concierge/README.md:35:**Founder Decision D1 (autosend orange-tier path) MUST be resolved before W10 build starts.** Per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Three options:
agents/recruitment/concierge/README.md:38:- D1-C: no autosend; manual consultant pickup (0 dev; ships fastest but worst UX)
docs/architecture/agent-bundle-renderer-design.md:44:| `config.schema.json` (line 553) | Per-tenant JSON Schema, extending `common-*.json` shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) | the renderer (materialises to `config.json` per §2.1); per-tenant onboarding wizard at Product Spec §5.2 Day 4 fills schema fields | **Static schema; dynamic materialisation** per tenant |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:110:| `agents/recruitment/<name>/config.schema.json` | `orgs/<org>/agents/<name>/config.json` | **Synthesis** | (1) `config.schema.json` (the JSON Schema itself, used for validation); (2) `/vault/{tenant-slug}/_config.yaml` per Ultraplan §5.1 line 220 (provides per-tenant values that fill schema fields); (3) bundle-level defaults from any `default` keys in the schema; (4) common-*.json shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) — spec gap §2.1-B on where common schemas live | Materialised JSON validates clean against the source schema using Ajv (or equivalent) before the renderer writes; required fields all populated; no extra fields beyond schema. Daemon-required fields (per §1.2): `enabled` defaults true, `runtime` defaults `claude-code`, `max_session_seconds` defaults 255600, `working_directory` defaults to the rendered agent dir |
docs/architecture/agent-bundle-renderer-design.md:219:  - ESC_VOICE_DRIFT
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:234:   --task-type candidate-{event-type}` + `hh_load_recent_edits`
docs/architecture/agent-bundle-renderer-design.md:245:    { "$ref": "common-voice.json" },
docs/architecture/agent-bundle-renderer-design.md:270:        "ESC_VOICE_DRIFT": { "type": "string", "format": "telegram-chat-id" }
docs/architecture/agent-bundle-renderer-design.md:322:hh_load_tone_rules
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:324:hh_load_recent_edits --n 5 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:423:    "ESC_VOICE_DRIFT": "<acme operator chat id from _secrets.env>"
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
agents/recruitment/concierge/agent.md:3:**Status:** Proposed (Day-19 pre-W10-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice).
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Drafts are orange-tier per `autosend-safety-policy.yaml` — consultant approval required before send via the autosend-bridge mechanism (Founder Decision D1 path A bridge OR D1-B shim OR D1-C manual; W10 design selects). Sends route via tenant's Microsoft Graph OR Gmail (per-tenant config; AgentMail deferred to v1.1+). Gate A hard-fails any draft generated >30 minutes after lifecycle event, any draft with voice classifier <0.75, or any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). Gate B success threshold: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:104:The actual SEND happens through the autosend-bridge (D1 path) — consultant approves → send routes through Microsoft Graph / Gmail; Bullhorn activity-log entry written post-send.
agents/recruitment/concierge/agent.md:159:     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
agents/recruitment/concierge/agent.md:167:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries
agents/recruitment/concierge/agent.md:193:      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
agents/recruitment/concierge/agent.md:194:    → per autosend-policy.yaml: orange-tier; consultant approves
agents/recruitment/concierge/agent.md:229:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 verbatim:
agents/recruitment/concierge/agent.md:266:| `ESC_VOICE_DRIFT` | Voice classifier below position-specific threshold after 3 retries | warn (position 1-2) or **blocking** (position 3) | operator_chat_id (1-2) / operator + ifos_oncall (position 3) |
agents/recruitment/concierge/agent.md:274:| `ESC_VOICE_DRIFT_TENANT` | Cross-30-day consultant edit-rate >50% | warn | operator + tenant-admin |
agents/recruitment/concierge/agent.md:286:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
agents/recruitment/concierge/agent.md:293:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:294:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal at tenant level. Edit-distance >150 chars on >40% of recent_edit rows → ESC_VOICE_DRIFT_TENANT → tenant-admin reviews voice corpus + tone rules.
agents/recruitment/concierge/agent.md:312:| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
agents/recruitment/concierge/agent.md:314:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
agents/recruitment/concierge/agent.md:322:| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
agents/recruitment/concierge/agent.md:347:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
docs/architecture/cortexos-primitive-status.md:64:- v1.1: A7 Inbound Triage, A10 Competitor Interception, A11 Night Sourcer (with primitive 6), A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all require it.
docs/architecture/cortexos-primitive-status.md:122:- v1.1+: A7 Inbound Triage, A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all carry per-entity state across many days.
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
packages/agent-renderer/templates/claude-md-preamble.md:63:Auto-send tier policy per `_shared/autosend-policy.yaml`. Tenant override file (if present): `/vault/{{tenant_slug}}/_config/autosend-overrides.yaml` — read by `autosend_apply_tenant_override` per `docs/decisions/autosend-safety-policy.md` §4.
docs/runbooks/day-4-provisioning.md:1254:19. **§9 verification script bugs (Claude error, no state impact):** Initial run reported 4 FAILs of 22 checks. Diagnosis showed all were script bugs, not state failures: (a) `sshd -T` requires root to read host keys (`sudo sshd -T` works correctly); (b) `findmnt --verify` output format simpler post-LUKS-open (`Success, no errors or warnings detected`) than my regex expected. Diagnostic re-run confirmed all 22 of 22 actual state checks pass. State is verified clean.
packages/harness/cortextos/community/skills/officecli/SKILL.md:43:Path addressing uses 1-based indexing: `/body/p[1]`, `/slide[2]/shape[3]`, `/$Sheet:A1`
packages/harness/cortextos/community/skills/officecli/SKILL.md:102:officecli set $XLS 'Summary!A1' --prop value="Total Open"
packages/harness/cortextos/community/skills/officecli/SKILL.md:110:officecli set report.xlsx 'Sheet1!A1' --prop value="Property"
packages/harness/cortextos/community/skills/officecli/SKILL.md:132:  --prop background=1A1A2E
docs/architecture/vault-concurrency.md:397:**Status update 2026-05-20 (Day 8 Codex Round 1):** all 5 codes below are now catalogued at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`, Phase 1 of Week-1 slice) AND wired into the `autosend_escalate` helper at `agents/_shared/hook-helpers.sh` (commit `e6e9df1`, Phase 3 of Week-1 slice). The "_shared/hook-helpers.sh Week-1 prereq must wire these 5 codes" language below has been satisfied — current state is shipped + tested.
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/runbooks/operational-hygiene-protocol.md:26:- **Length discipline C+** — Day 5 autosend policy 658 lines vs 300-500 estimate; Day 6 vertical schema 899 lines vs same estimate
docs/runbooks/operational-hygiene-protocol.md:131:- §9 verification script had `sshd -T` without `sudo`. Without root, sshd cannot read host keys and exits with "no hostkeys available". The check appeared to fail though state was correct. Diagnostic re-run needed.
docs/runbooks/operational-hygiene-protocol.md:132:- §9 verification script had `findmnt --verify` regex matching old output format. Post-LUKS-open, output simplified to "Success, no errors or warnings detected" which the regex missed. Diagnostic re-run needed.
docs/runbooks/operational-hygiene-protocol.md:150:- Day 5 autosend policy: estimated 300-500 lines; actual 648. **+30% to +116% overshoot.**
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:268:**Root cause:** Day-4 runbook §1.4 invented "master brief §10.4 cost target" during drafting. The citation propagated through Day-5 kill criterion (3 instances), Day-5 autosend policy (1 instance), RISK-REGISTER (2 instances), current-priorities (1 instance) by trusting the Day-4 runbook citation rather than re-verifying against master brief. Citation transitivity, not master-brief drift.
docs/runbooks/operational-hygiene-protocol.md:275:| `docs/decisions/autosend-safety-policy.md` | 1 | Same cost-target replacement for the cyber-insurance budget reference |
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/runbooks/operational-hygiene-protocol.md:290:Day-6 structural summary claimed "30+ action_types across 6 v1.0 agents" in autosend policy §3. Actual count: 29 (Green 6 + Yellow 5 + Orange 10 + Red 8). The artefact itself does not make this claim — only my summary message did.
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
packages/agent-renderer/README.md:120:- **Telegram-down hang for orange-tier autosend** (autosend-safety-policy §5) is a Phase-3 concern in `hook-helpers.sh` `autosend_await_approval`, not a renderer concern. Documented for completeness.
docs/runbooks/tenant-lifecycle.md:4:**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation)
docs/runbooks/tenant-lifecycle.md:153:| Spot-check operator review | `autosend_spot_check_enqueue` writes to `/vault/<slug>/spot-checks/<file>.md`; operator reviews + flags as approved/rejected/escalate | (No invariant violation) |
docs/runbooks/pii-purge-operational-pattern.md:159:| Disk full during audit row write | UPDATE succeeds; audit row write fails; orphaned purge | Decision_log fallback to JSONL at `/var/log/ifos/decision-log.jsonl`; replay via autosend-syncer when disk recovers |
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:776:| Diagnostic | N/A | doesn't touch the per-tenant vault |
docs/architecture/second-brain-design.md:975:| **2.6** | Master brief §5 silent on concurrency | No mechanism for agent×agent, agent×human-in-Obsidian, or rewrite-backlinks cascade | Resolved in §2.6.1, §2.6.2, §2.6.3 of this design. Companion document `docs/architecture/vault-concurrency.md` LANDED (Day 3, commit `78680cc`). New escalation codes (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, `ESC_VAULT_RENAME_RACE`) CATALOGUED at `agents/_shared/escalation-codes.md` §2.2 (Day 8 commit `a279226`) + WIRED into `agents/_shared/hook-helpers.sh::autosend_escalate` (Day 8 commit `e6e9df1`). | **Closed 2026-05-20.** Catalogue + wiring complete; ESC codes callable from any rendered agent. |
docs/build-brief/00-MASTER-BRIEF.md:477:- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:580:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/build-brief/00-MASTER-BRIEF.md:595:| 1 | Diagnostic | 3–4 | LinkedIn + Companies House + scrape | Sales tool — needed before any other agent matters |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/specs/ULTRAPLAN.md:97:- The Diagnostic agent (sales tool)
docs/specs/ULTRAPLAN.md:155:hh_load_tone_rules
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:161:hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:182:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/specs/ULTRAPLAN.md:265:4. Run a single dry-run agent invocation (the Diagnostic) to validate the path end-to-end.
docs/specs/ULTRAPLAN.md:354:If any hard fail, the agent regenerates with the failure reason injected as additional context ("your previous draft used the banned phrase 'I hope this finds you well'; rewrite avoiding it"). After 3 retries with hard fails, escalate with `ESC_VOICE_DRIFT` or `ESC_SCHEMA_VIOLATION`.
docs/specs/ULTRAPLAN.md:376:If the rolling 4-week average drops by ≥5 percentage points: `ESC_VOICE_DRIFT_TENANT` fires. Email goes to the customer's primary contact AND to the internal CS Slack:
docs/specs/ULTRAPLAN.md:487:#### A1. The Diagnostic — the sales tool
docs/specs/ULTRAPLAN.md:605:#### A10. Competitor Interception (2 weeks)
docs/specs/ULTRAPLAN.md:619:#### A11. The Night Sourcer (2 weeks)
docs/specs/ULTRAPLAN.md:633:#### A12. T5 Supply Chain Auditor (parallel to v1.1 front-office work)
docs/specs/ULTRAPLAN.md:647:#### A13. T3 Compliance Watchtower (parallel to v1.1 front-office work)
docs/specs/ULTRAPLAN.md:685:| Diagnostic | ✓ | | | | ✓ | ✓ | | | | | Web scraper |
docs/specs/ULTRAPLAN.md:750:### Weeks 3–4 — Bullhorn + Diagnostic
docs/specs/ULTRAPLAN.md:753:- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint
docs/specs/ULTRAPLAN.md:755:Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact.
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/specs/_archive-build-handoff.md:377:| 1 | **Diagnostic** | 3–4 | LinkedIn + Companies House + web scrape | Sales tool — needed for pitch before any other agent matters |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/operations/codex-ratification-guide.md:397:If `IFOS_DB_URL` isn't set when the wrapper runs (or psql isn't on PATH or the live DB rejects the write), the row appends to `logs/codex-ratification.jsonl` instead. Same shape, JSON Lines. Replays into Postgres later via the autosend-syncer worker (Week 5+).
docs/specs/PRODUCT-SPEC.md:173:#### R13. The Diagnostic — the sales motion, productised
docs/specs/PRODUCT-SPEC.md:324:- 90-minute discovery call (driven by the Diagnostic output).
docs/specs/PRODUCT-SPEC.md:358:- `common-voice.json` — paths to voice profile, banned phrases, tone rules
docs/specs/PRODUCT-SPEC.md:471:- The Diagnostic (sales tool; already drafted)
docs/operations/codex-round-2-handoff.md:77:| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
docs/operations/codex-round-2-handoff.md:87:**Likely outcomes:** 11-12 of 14 RATIFY. Items #6 (autosend tier contradiction) and #14 (PII retention) are founder-decision-bound (D1/D3); Codex may RATIFY-with-advisory or REJECT pending decisions.
docs/operations/codex-round-2-handoff.md:107:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | `review-architecture-decision` | RATIFY (Proposed spec; alternatives weighed; ratifies cortextOS primitive-4 reuse) |
docs/operations/codex-round-2-handoff.md:139:bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-handoff.md:168:  review, tenant lifecycle, founder decision briefing, 2 disagreement docs, autosend
docs/operations/codex-round-2-handoff.md:174:  audit + verification artefacts before Diagnostic agent build begins
docs/operations/codex-round-2-handoff.md:211:  docs/decisions/autosend-safety-policy.md
docs/operations/codex-round-2-handoff.md:231:  docs/decisions/autosend-approval-bridge-spec.md  (review-architecture-decision)
docs/operations/codex-round-2-handoff.md:288:**Sub-case 2a: Same issue as Round 1** — incorporation didn't actually fix the root cause. Escalate to founder; reopen as a fresh issue. Likely candidates: autosend-safety-policy (D1 + D3 unresolved); v0.2 supplement (D3 unresolved).
docs/operations/codex-round-2-handoff.md:353:- **Foundation is fully double-reviewed** — Diagnostic agent build can begin with maximum confidence
docs/operations/codex-round-2-handoff.md:396:6. **Diagnostic agent build slice begins** — first ratified-foundation v1.0 agent
packages/agent-renderer/tests/fixtures/test-agent/tools.yaml:11:autosend_categories: []
docs/operations/codex-round-2-remediation-prompt.md:218:  | Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (sequencing-target §2.1) | Awaits Q1 LOI |
docs/operations/codex-round-2-remediation-prompt.md:238:  FIX 8 — autosend-approval-bridge-spec.md category mapping rewrite
docs/operations/codex-round-2-remediation-prompt.md:240:  File: docs/decisions/autosend-approval-bridge-spec.md
docs/operations/codex-round-2-remediation-prompt.md:243:  Issue 2: new autosend_approval_mappings table not added to
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
docs/operations/codex-ratification-execution-plan.md:72:| `review-agent-bundle.md` | The 6-file + 3-fixture pattern | ~250 | Pre-Diagnostic-W3 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:130:| 8 | autosend-safety-policy | `docs/decisions/autosend-safety-policy.md` | A |
docs/operations/codex-ratification-execution-plan.md:167:| 25 | autosend-policy.yaml | `agents/_shared/autosend-policy.yaml` | A |
docs/operations/codex-ratification-execution-plan.md:352:- **Option α** — Start immediately. Rationale: 33 items are already queued; Q1 turning YES will only ADD items (Diagnostic + Janitor + downstream). The 34-item queue is largely about Week 0 design artefacts that won't change post-LOI. Get them ratified now while context is fresh.
docs/operations/codex-ratification-execution-plan.md:429:- **Codex review of `agents/_shared/` runtime code via agent-bundle skill** — the 8-file `_shared/` set is reviewed under `review-architecture-decision.md` because it's not an agent bundle, it's the helper layer. Future agents (Diagnostic W3+) will be reviewed under `review-agent-bundle.md` once that skill exists.
docs/operations/codex-round-2-autonomous-prompt.md:97:For autosend-safety-policy.md (Tier 1 item #6) and v0.2 supplement (item 
docs/operations/codex-round-2-autonomous-prompt.md:253:4. **DO NOT make founder decisions.** Items like D1 (autosend orange tier), 
docs/operations/codex-round-2-autonomous-prompt.md:305:- A blocker on Diagnostic build — that runs separately after Round 2 + founder actions
docs/operations/codex-round-2-autonomous-prompt.md:318:**If SUMMARY.md shows clean (0 REJECTED OR all REJECTED are founder-decision-bound):** Round 2 done. Move to founder action sequence items 5-8 (live migration + tenancy audit + SeedLegals + Diagnostic build).
docs/operations/goal-week-3-polish-and-scaffold.md:1:# /goal — Week 3: Diagnostic polish + 5 agent.md scaffolds + Codex ratification
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:8:**Builds on:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 Diagnostic v0 — completed at commit `97a57a2`).
docs/operations/goal-week-3-polish-and-scaffold.md:19:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:24:9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
docs/operations/goal-week-3-polish-and-scaffold.md:29:14. **`agents/_shared/autosend-policy.yaml`** (29 action types; tier classifications)
docs/operations/goal-week-3-polish-and-scaffold.md:31:16. **`docs/operations/goal-option-c-diagnostic-end-to-end.md`** (Day-13 Diagnostic build; reference for Week-3 polish steps)
docs/operations/goal-week-3-polish-and-scaffold.md:33:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:41:### Diagnostic polish (Days 14-15)
docs/operations/goal-week-3-polish-and-scaffold.md:46:4. **Diagnostic bundle ratified by Codex.** Round 4 ratification run against agent.md + 5 siblings + 3 fixtures via `review-architecture-decision.md` skill. Verdict: RATIFIED (or remediation-pass if needed).
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:56:Each agent.md has the same 10-section structure as Diagnostic:
docs/operations/goal-week-3-polish-and-scaffold.md:59:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:70:10. **Round 4 ratification run executed** via `bash scripts/run-codex-ratification.sh` with the manifest extended to include 6 new artefacts (Diagnostic agent.md re-ratify + 5 new agent.md scaffolds).
docs/operations/goal-week-3-polish-and-scaffold.md:77:14. **`docs/RISK-REGISTER.md`** updated: Risk #2 (Bullhorn) blast radius confirmed reduced; Risk #5 (Renderer) state per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:89:| Diagnostic CH integration with real key | Goal §1 criterion 1; brings §1/§10/§11 from degraded → full |
docs/operations/goal-week-3-polish-and-scaffold.md:92:| Diagnostic Codex ratification | Master brief §10.5 always-ratify |
docs/operations/goal-week-3-polish-and-scaffold.md:101:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:105:| Proxycurl signup | Founder commercial action; gated on founder decision (cost ~$39/mo); if founder approves mid-week, wire LinkedIn deep data into Diagnostic |
docs/operations/goal-week-3-polish-and-scaffold.md:139:### DAY 14 — Diagnostic polish substrate (Steps 1-5)
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:212:   - **Retry:** if response shape malformed, retry once; if still bad, fall back to deterministic logic + emit `ESC_VOICE_DRIFT` warning row.
docs/operations/goal-week-3-polish-and-scaffold.md:217:   - Tone-rule violation in LLM output → retry then ESC_VOICE_DRIFT
docs/operations/goal-week-3-polish-and-scaffold.md:251:### DAY 15 — Diagnostic Codex ratification (Steps 6-7)
docs/operations/goal-week-3-polish-and-scaffold.md:267:Commit: `ops(codex-round-4): Diagnostic bundle + ADR-005 queue addition`
docs/operations/goal-week-3-polish-and-scaffold.md:269:#### Step 7 — Codex Round 4 Diagnostic-only run (~45 min)
docs/operations/goal-week-3-polish-and-scaffold.md:279:If all RATIFIED → mark Diagnostic ratified in manifest §1.10; proceed to Step 8.
docs/operations/goal-week-3-polish-and-scaffold.md:296:- Diagnostic's `agent.md` as the gold-standard structure
docs/operations/goal-week-3-polish-and-scaffold.md:298:Author the agent.md following Diagnostic's 10-section template. Specifics:
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§4 Workflow:** ~12 steps. Cron 02:00 UTC daily. Bullhorn auth refresh → entity scan → dedup pass → field completeness pass → tacit-note attach → Bullhorn writes (yellow tier; spot-check sampling per autosend §4) → report assembly → vault write → operator Telegram notify.
docs/operations/goal-week-3-polish-and-scaffold.md:314:Target: ~400 lines. Follows Diagnostic's structure verbatim. Every claim cites a specific master plan section + line number.
docs/operations/goal-week-3-polish-and-scaffold.md:334:Author following Diagnostic's template. Specifics:
docs/operations/goal-week-3-polish-and-scaffold.md:343:- **§6 Escalation codes:** ESC_BULLHORN_WRITE_FAIL, ESC_VOICE_DRIFT, ESC_SCHEMA_VIOLATION, ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
docs/operations/goal-week-3-polish-and-scaffold.md:344:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:363:Author following Diagnostic's template. Specifics:
docs/operations/goal-week-3-polish-and-scaffold.md:373:- **§7 Voice + tone:** chase drafts are voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:409:#### Step 12 — `agents/recruitment/concierge/agent.md` (~3-4 hours; most complex due to autosend orange-tier)
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:414:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:415:- `2026-05-20-codex-round-1-founder-decisions.md` §D1 (autosend orange-tier decision)
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:423:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:427:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/goal-week-3-polish-and-scaffold.md:440:Manifest now includes 6 new items (5 agent.md scaffolds + Diagnostic re-ratify). Founder runs:
docs/operations/goal-week-3-polish-and-scaffold.md:460:2. **`docs/RISK-REGISTER.md`** — Risk #2 (Bullhorn) status per A+B response state; Risk #5 (Renderer) updated per Diagnostic ratification.
docs/operations/goal-week-3-polish-and-scaffold.md:498:| LLM call rate-limited or 5xx (Step 4 runtime) | Built-in retry once; fall back to deterministic; emit ESC_VOICE_DRIFT warning |
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Founder approves Proxycurl signup mid-week | Wire LinkedIn deep data into Diagnostic via a new `@ifos/linkedin-proxycurl` package (similar to companies-house pattern); commit as separate slice; out of scope for goal §1 but high-value |
docs/operations/goal-week-3-polish-and-scaffold.md:525:- Step 7: Codex Round 4 Diagnostic-only run (founder runs the script)
docs/operations/goal-week-3-polish-and-scaffold.md:543:- Diagnostic agent.md (re-ratify; was Round-3 RATIFIED at scaffold form)
docs/operations/goal-week-3-polish-and-scaffold.md:544:- Diagnostic tools.yaml
docs/operations/goal-week-3-polish-and-scaffold.md:545:- Diagnostic cycle.sh (post-Day-13 generator wiring)
docs/operations/goal-week-3-polish-and-scaffold.md:546:- Diagnostic validate.sh (post-Day-13 V2 fix)
docs/operations/goal-week-3-polish-and-scaffold.md:552:### Round 4 Diagnostic-only run (Step 7)
docs/operations/goal-week-3-polish-and-scaffold.md:558:Mid-week early ratification of Diagnostic ensures: (a) the substrate is verified before 5 new scaffolds reference it; (b) any architectural concerns surface before the 5 new agent.md contracts are committed.
docs/operations/goal-week-3-polish-and-scaffold.md:608:Diagnostic state:
docs/operations/goal-week-3-polish-and-scaffold.md:627:  <SHA>  ops(codex-round-4): Diagnostic bundle queue addition
docs/operations/goal-week-3-polish-and-scaffold.md:641:  ✓ sequencing-target.md §3.1 — Build Wave 1 (Diagnostic) ratified;
docs/operations/goal-week-3-polish-and-scaffold.md:643:  ✓ v1.0-kill-criterion.md Trigger 2 — Diagnostic ratified ahead of
docs/operations/goal-week-3-polish-and-scaffold.md:650:    - Diagnostic voice classifier microservice
docs/operations/goal-week-3-polish-and-scaffold.md:651:    - Diagnostic LinkedIn deep data (if Proxycurl signed up)
docs/operations/goal-week-3-polish-and-scaffold.md:686:| 7 | The 5 agent.md scaffolds drift in style across days (different writing voice on different days) | Medium | Each scaffold re-reads Diagnostic's agent.md FIRST as the structural template; commit message references the structural anchor |
docs/operations/goal-week-3-polish-and-scaffold.md:700:**Day 20 is the soft target. Day 22 is the hard cutoff** (Trigger 2 fires Day 21 if Diagnostic not ratified). If Day 22 hits without completion, escalate to founder review + scope-cut decision.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:1:# Diagnostic report — Hays plc
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:3:**Generated:** 2026-05-24 by Intel Force OS Diagnostic agent (v0 — pre-W3 build).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:11:No active Companies House registration found for **Hays plc**. Diagnostic proceeded against publicly visible non-CH signals only.
docs/operations/seedlegals-engagement-queries.md:68:> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:1:# Diagnostic report — Hays plc
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:3:**Generated:** 2026-05-24 by Intel Force OS Diagnostic agent (v0 — pre-W3 build).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:11:No active Companies House registration found for **Hays plc**. Diagnostic proceeded against publicly visible non-CH signals only.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:1:# Codex disagreement — Diagnostic Gate A citation requirement + 4 follow-on findings
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:25:**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:33:Option B — **Amend Ultraplan §8.1 A1 line 497** to read "no unsupported claims at section level" (loosens upstream to match v0 implementation).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:41:**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:49:**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:53:**Founder decision needed:** Diagnostic's Gate B metric doesn't map cleanly to ANY existing kill-criterion trigger.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:55:Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:59:**My recommendation:** **A** for v0 — remove the trigger reference; Diagnostic conversion is local-metric tracking. Add Trigger 11 in v1.1 if conversion-rate-driven scope-cut becomes operationally relevant.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:61:### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:69:Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:73:**My recommendation:** **B** — cleaner, avoids sentinel proliferation. Feedback events are conceptually Diagnostic's domain (they validate Diagnostic outputs), so the agent_name should be Diagnostic with a specific action_type marker.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:101:- Phase 1 Diagnostic-only: **1 of 6 artefacts attempted**; result is **REJECTED-after-hard-ceiling** awaiting founder arbitration via this disagreement doc
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:16:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:32:**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:44:- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:45:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:164:Implementation work: <commit reference or "in autosend §9 update commit">
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
docs/decisions/autosend-approval-bridge-spec.md:6:**Surfaced by:** Founder Decision D1 (`docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`) + Codex Round 1 autosend rejection issue 2
docs/decisions/autosend-approval-bridge-spec.md:18:- `agents/_shared/hook-helpers.sh::autosend_await_approval` writes pending marker `/vault/<tenant>/pending-approvals/<hash>.pending`
docs/decisions/autosend-approval-bridge-spec.md:68:A new IFOS package: `packages/autosend-approval-bridge/`. ~200-250 lines of TypeScript. Runs as a long-lived process (PM2-managed alongside the daemon).
docs/decisions/autosend-approval-bridge-spec.md:79:  - Map IFOS action_type → cortextOS ApprovalCategory (autosend taxonomy)
docs/decisions/autosend-approval-bridge-spec.md:98:The bridge's `autosend_await_approval` polling loop (already in `hook-helpers.sh`) sees the new marker → returns 0 (approved) or 1 (rejected) → agent proceeds or escalates.
docs/decisions/autosend-approval-bridge-spec.md:102:Mapping `{ifos_payload_hash, cortextos_approval_id, tenant_slug, action_type, created_at, resolved_at}` lives in a small SQLite database at `${CTX_FRAMEWORK_ROOT}/autosend-bridge.db` OR (cleaner) a new Postgres table `autosend_approval_mappings`:
docs/decisions/autosend-approval-bridge-spec.md:105:CREATE TABLE IF NOT EXISTS autosend_approval_mappings (
docs/decisions/autosend-approval-bridge-spec.md:118:ALTER TABLE autosend_approval_mappings ENABLE ROW LEVEL SECURITY;
docs/decisions/autosend-approval-bridge-spec.md:119:CREATE POLICY tenant_isolation ON autosend_approval_mappings
docs/decisions/autosend-approval-bridge-spec.md:121:GRANT SELECT, INSERT, UPDATE ON autosend_approval_mappings TO ifos_app;
docs/decisions/autosend-approval-bridge-spec.md:128:`autosend_approval_mappings` becomes the 10th tenant-data table when the bridge implementation lands. The Week-9 bridge implementation slice MUST update `docs/architecture/tenancy-invariants.md` §1 and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` to include this table in T1-T3, T11, and audit coverage. This remediation corrects the spec only; the table does not exist yet, so the live invariant inventory remains the v0.2 nine-table set until the bridge migration ships.
docs/decisions/autosend-approval-bridge-spec.md:132:cortextOS Primitive 4 enumerates approval categories as `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` per `packages/harness/cortextos/src/types/index.ts`. IFOS action_types from `agents/_shared/autosend-policy.yaml` map as follows:
docs/decisions/autosend-approval-bridge-spec.md:171:`autosend_await_approval` already enforces 4h default timeout per action_type's `timeout` field in autosend-policy.yaml. If the timeout fires before operator responds:
docs/decisions/autosend-approval-bridge-spec.md:173:1. IFOS-side: poll loop exits → `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` → agent gives up
docs/decisions/autosend-approval-bridge-spec.md:185:| Postgres unreachable | Write bridge state to fallback JSONL at `/vault/_meta/autosend-bridge.jsonl`; same replay pattern as decision_log fallback |
docs/decisions/autosend-approval-bridge-spec.md:199:packages/autosend-approval-bridge/
docs/decisions/autosend-approval-bridge-spec.md:200:├── package.json              ← @ifos/autosend-approval-bridge; Node 20+
docs/decisions/autosend-approval-bridge-spec.md:226:Adding `autosend_approval_mappings` table requires:
docs/decisions/autosend-approval-bridge-spec.md:231:Total schema impact: 1 new table; tenancy-invariants.md grows from 12 to 13 invariants (T13: autosend_approval_mappings tenant_slug + RLS), or we count this as covered by T1-T3 already (cleaner).
docs/decisions/autosend-approval-bridge-spec.md:239:| A1 | Bridge process starts via PM2 + connects to Postgres + reads bridge state | `pm2 status ifos-autosend-bridge` shows online; bridge starts fresh on empty DB |
docs/decisions/autosend-approval-bridge-spec.md:245:| A7 | category mapping table covers all 10 v1.0 orange action_types | Lint test: every orange action_type in autosend-policy.yaml has a mapping entry |
docs/decisions/autosend-approval-bridge-spec.md:246:| A8 | Bridge state row in `autosend_approval_mappings` exists for every pending approval | Audit query: count(pending markers) == count(pending bridge state rows) |
docs/decisions/autosend-approval-bridge-spec.md:248:| A10 | Live VPS smoke: real Telegram chat receives approval message + button press routes back to marker | Founder Path A manual test on migration-test tenant |
docs/decisions/autosend-approval-bridge-spec.md:259:**Alternative:** as the next IFOS Claude slice (now). Pre-builds the prerequisite before Diagnostic W3-4 starts, so it's not blocking Concierge. ~2-3 days inserted before Diagnostic.
docs/decisions/autosend-approval-bridge-spec.md:261:**Founder decision:** schedule for Week 9 (sequential with master brief) OR insert now (parallel with Diagnostic prep).
docs/decisions/autosend-approval-bridge-spec.md:268:- **Building the IFOS-side `autosend_await_approval` polling loop** — already exists in `hook-helpers.sh` (Phase 3)
docs/decisions/autosend-approval-bridge-spec.md:285:| 6 | RLS on autosend_approval_mappings forgotten | Migration includes ENABLE ROW LEVEL SECURITY; tenancy audit T2 catches if missing |
docs/decisions/autosend-approval-bridge-spec.md:306:- Adds 1 tenant-data table (`autosend_approval_mappings`) → tenancy-invariants.md update OR considered covered by T1-T3 patterns
docs/decisions/autosend-approval-bridge-spec.md:307:- Adds 1 PM2-managed process (`ifos-autosend-bridge`) → ecosystem.config.js update
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:66:| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:82:| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:95:| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:99:| 6 | `docs/decisions/autosend-approval-bridge-spec.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:109:## §1.10 — Codex Round 4 queue (Week 3 Diagnostic + 5 agent.md scaffolds)
docs/decisions/2026-05-18-codex-ratification-manifest.md:111:Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).
docs/decisions/2026-05-18-codex-ratification-manifest.md:115:**Phase 1 (Day 15) — Diagnostic-only mid-week ratification.** Reason: substrate must be verified before 5 new scaffolds reference it. 6 items, all `review-architecture-decision.md` skill except the package-as-a-whole.
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:166:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:271:| 16 | `autosend-safety-policy.md` §10 pilot-agreement liability | Placeholder — legal review required before first pilot LOI | Pre-LOI legal review (commercial / regulatory). Codex can ratify the placeholder shape but cannot substitute for legal counsel. |
docs/operations/founder-legal-setup-guide.md:229:> Would you provide a quote? Happy to share more about our autosend-safety-policy on a call.
docs/decisions/ADR-004-renderer-implementation-deviations.md:144:**For Risk #5 (renderer-not-built).** Severity unchanged at High per ADR-003 line 145 staged ladder ("Drops to Medium once renderer code is committed AND the Diagnostic agent renders cleanly (Week 4)"). The Phase-2 commit `3c16d35` satisfies the first condition; the second condition (Diagnostic render) is gated on Q1 design-partner LOI. ADR-004 closes a stylistic gap (3 deviations) but does not change risk severity.
docs/decisions/ADR-004-renderer-implementation-deviations.md:150:**For future Diagnostic builds.** Decision 1 means agents/runbooks/onboarding-wizard documentation references `ifos-render-agent`, not `cortextos-ifos render-agent`. Cheap to update everywhere because no documentation has shipped yet — only ADR-003 + master brief §8.3 reference the old name, and both are addressed in §"Master brief edits authorised."
packages/agent-renderer/pnpm-lock.yaml:400:    resolution: {integrity: sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==}
packages/agent-renderer/pnpm-lock.yaml:587:    resolution: {integrity: sha512-FJHFfqpKUI3A10WrWKiFbBZ7yVbGT4q4B5o1qKFFojqpaYoh9LrQgqWCmmcxQzVSXYtyB5bzkXrYzlHTs21MYA==}
packages/agent-renderer/pnpm-lock.yaml:642:    resolution: {integrity: sha512-QVTUovf40zgTqlFVrKA1uXMVvU2QWEFWfAH8Wdc48IxLvrJMQVMBRjuQyUpzZCDkakImib9eVazbWlC6ksWtJw==}
packages/agent-renderer/pnpm-lock.yaml:864:    resolution: {integrity: sha512-//nshmD55c46FuFw26xV/xFAaB5HF9Xdap7HJBBnrKdAd6/GxDBaNA1870O79+9ueg61cZLSVc+OaFlfmObYVQ==}
packages/agent-renderer/pnpm-lock.yaml:1019:    resolution: {integrity: sha512-o5a9xKjbtuhY6Bi5S3+HvbRERmouabWbyUcpXXUA1u+GNUKoROi9byOJ8M0nHbHYHkYICiMlqxkg1KkYmm25Sw==}
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:25:- `agents/_shared/hook-helpers.sh` + `autosend-policy.yaml` (Phase 3, commit `e6e9df1`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:41:| Diagnostic build (W3-4) | None — Diagnostic doesn't touch Bullhorn | Awaits Q1 LOI |
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:81:| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
docs/decisions/autosend-safety-policy.md:108:| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
docs/decisions/autosend-safety-policy.md:109:| Diagnostic | `diagnostic_calendar_invite` | Books intro call with prospect; reputation + scheduling friction |
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
docs/decisions/autosend-safety-policy.md:189:      autosend_await_approval "$action_type" "$target" "$payload_hash"
docs/decisions/autosend-safety-policy.md:193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:209:The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
docs/decisions/autosend-safety-policy.md:245:  "action_type": "<enum from autosend-policy.yaml>",
docs/decisions/autosend-safety-policy.md:258:1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
docs/decisions/autosend-safety-policy.md:259:2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
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
docs/decisions/autosend-safety-policy.md:394:--     "policy_version_sha": "<git SHA of autosend-policy.yaml at execution>"
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:430:  'autosend_policy',
docs/decisions/autosend-safety-policy.md:470:Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
docs/decisions/autosend-safety-policy.md:510:docs/decisions/autosend-safety-policy.md in the IFOS code repository)
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:596:| 1 | Formal `action_type` taxonomy enum — should this live in autosend-policy.yaml only, or also in a typed schema for tools.yaml validation? | §3 + §4 | Defer to ADR-005 in Week 1; recommend typed enum in JSON Schema mirrored to YAML |
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
docs/operations/goal-option-c-diagnostic-end-to-end.md:1:# /goal — Option C: Diagnostic agent end-to-end against a real UK recruitment firm
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A1 (the 10-step workflow for Diagnostic, lines 495-526).
docs/operations/goal-option-c-diagnostic-end-to-end.md:32:1. **One Markdown file exists at `/vault/migration-test/diagnostic-reports/<firm-slug>-2026-05-24.md`** containing a 12-section Diagnostic report for a real UK recruitment firm chosen by the founder.
docs/operations/goal-option-c-diagnostic-end-to-end.md:55:9. **State files updated:** `current-priorities.md` Shipped section + `RISK-REGISTER.md` Risk #2 status (Diagnostic ratification path proven).
docs/operations/goal-option-c-diagnostic-end-to-end.md:65:| Web scraper utility | Diagnostic §4 Step 3 + 6 + 8 |
docs/operations/goal-option-c-diagnostic-end-to-end.md:66:| Companies House connector | Diagnostic §4 Step 2 + 10 |
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:252:- **Decision:** Week 3 (Days 13-20) repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) repurposed from Diagnostic-build to Diagnostic-polish + Codex ratification + (conditional) Bullhorn-MCP-build if A+B answered.
docs/operations/goal-option-c-diagnostic-end-to-end.md:257:Commit: `decision(ADR-005): Week 3 repurposed Bullhorn-MCP → Diagnostic acceleration`
docs/operations/goal-option-c-diagnostic-end-to-end.md:262:- Move Diagnostic agent.md scaffold from "Shipped" Day-11 to "shipped + extended" pointing at today's commits
docs/operations/goal-option-c-diagnostic-end-to-end.md:266:- Risk #2 (Bullhorn MCP build): note Diagnostic-doesn't-need-Bullhorn path explored Day-13; reduces blast radius if Bullhorn response delayed
docs/operations/goal-option-c-diagnostic-end-to-end.md:267:- Risk #3 (Q1 LOI): note that Diagnostic-as-sales-tool now has empirical artefact for the Q1 pitch
docs/operations/goal-option-c-diagnostic-end-to-end.md:309:| LLM generates §12 with banned phrase | V5 fails; retry up to 3x; if still failing, ESC_VOICE_DRIFT row + report blocked (matches fixture 99); record as known limitation, defer voice tuning to Week-4 polish. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:310:| Diagnostic report word count <400 | V4 fails; cycle.sh detects + retries with longer prompt; if still failing, surface as Diagnostic-spec issue (revisit agent.md §3 section count vs word budget). |
docs/operations/goal-option-c-diagnostic-end-to-end.md:357:ULTRAPLAN line 755 sets the bar: "Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:69:**Action:** KILL state. Rationale: the renderer architecture (ADR-003) was ratified in Week 0 Day 1 evening as the load-bearing Week-1 prerequisite. If Week 3 ends with no clean Diagnostic render, the renderer has fundamental gaps that the design did not anticipate. The renderer cannot be "patched"; v1.0 cannot ship without working render. Continuing into Weeks 4+ without resolution is sunk-cost reasoning.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:109:**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
docs/decisions/v1.0-kill-criterion.md:113:**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
docs/decisions/v1.0-kill-criterion.md:117:**Escalation path:** If three pilots experience this trigger within one quarter, escalate to system-wide PAUSE while structural autosend policy redesign happens (potential v1.1 advancement of orange tier).
docs/decisions/v1.0-kill-criterion.md:158:### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
docs/decisions/v1.0-kill-criterion.md:188:**Threshold:** ANY confirmed incident in which agent action results in PII (personally-identifiable information per UK GDPR Art. 4(1)) transmitted to an unauthorised party (cross-tenant recipient, unauthorised external recipient, or recipient outside tenant's declared data residency) AND not blocked by the RLS + autosend policy combination.
docs/decisions/v1.0-kill-criterion.md:196:**Action:** KILL. Rationale: multi-tenant trust is the structural foundation of v1.0. A single confirmed PII breach beyond the RLS + autosend boundary indicates the foundation is unsound. Continuing operation risks (a) further breaches, (b) regulatory action, (c) catastrophic loss of pilot trust. Wind-down protects existing pilots from further exposure.
docs/decisions/v1.0-kill-criterion.md:227:- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
docs/decisions/v1.0-kill-criterion.md:235:**Must-fill before first pilot LOI signs.** The pilot agreement may reference an external advisor for dispute resolution per `autosend-safety-policy.md` §10 placeholder language. Founder identifies and engages within Weeks 1-2.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:337:- The autosend safety policy per this Day 5 commit (green + red tiers only)
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/v1.0-kill-criterion.md:387:**For atomic-correction manifest.** Edit 10 (shared with autosend-safety-policy.md) adds the path drift correction. Manifest grows from 9 to 10.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:68:- **Sequencing:** `docs/decisions/sequencing-target.md` §4.1 ratifies the 6-agent build order; renderer is Week 1-2 prerequisite for the Diagnostic W3-4 first render per ADR-003 §5.2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:71:- **Risk #5 (renderer-not-built)** in `docs/RISK-REGISTER.md` reduced from Blocking → High on Day 1 evening when ADR-003 + design doc Accepted. Three-stage ladder to Medium (W4 first Diagnostic render) → Low (W13 all 5 v1.0 bundles rendered).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:117:6. **Renderer implementation per ADR-003** — ALLOWED in code repo but agent-build slices (Diagnostic et al.) DO NOT start until Q1 turns YES. Renderer can scaffold independently.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:121:1. **Diagnostic W3-4 agent build** — blocked; requires Q1=YES.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:142:- Q1 + Q3 = YES → Week 0 cleanly closes; Week 1 starts; Diagnostic W3-4 build begins.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:143:- Q1 = YES, Q3 = NO (accepted) → Week 0 closes by founder discretion; Week 1 starts with Risk #2 elevated; Diagnostic W3-4 begins under accepted risk; Janitor W5 contingent on Q3 clearing by then.
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:147:**For Risk #5 (renderer-not-built).** Severity drops from **Blocking** to **High** with ADR-003 Accepted — design exists, ratified; just needs implementing. Drops to **Medium** once renderer code is committed and the Diagnostic agent renders cleanly (Week 4). Drops to **Low** once all five v1.0 agent bundles render and pass validation. The risk register entry is updated in this session as part of the ADR-003 commit.
packages/mcp-connectors/companies-house/package.json:5:  "description": "IFOS Companies House MCP connector — search + profile + officers + filing history. Used by Diagnostic agent §4 Step 2 + 10 per agents/recruitment/diagnostic/tools.yaml.",
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:1:# ADR-005 — Week-3 Diagnostic acceleration (Bullhorn MCP deferred)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:19:| 4 | **Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint** per ULTRAPLAN line 753 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:35:**Week 3 (Days 13-20) is repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) is repurposed from Diagnostic-build to Diagnostic-polish + first-pilot-prep + (conditional) Bullhorn-MCP-build if A+B answered.**
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:41:| W3 Days 13-20: Bullhorn MCP server build | W3 Days 13-20: Diagnostic end-to-end (per `goal-option-c-diagnostic-end-to-end.md`) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:42:| W4 Days 21-27: Diagnostic end-to-end | W4 Days 21-27: Diagnostic polish + first-pilot prep + Bullhorn MCP if A+B answered |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:47:1. **Diagnostic is the named first agent.** `sequencing-target.md` §3.1 ratified Build Wave 1 = Diagnostic. Doing it earlier doesn't violate the sequence — it accelerates it.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:48:2. **The Week-4 milestone is achievable today.** ULTRAPLAN line 755: *"Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."* Option C produces exactly this; the dependencies (LinkedIn + Companies House + scrape) are independent of Bullhorn.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:49:3. **Week-3 time is otherwise idle.** Bullhorn MCP build cannot proceed without commercial answer. Spending Week 3 on Diagnostic uses that time productively.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:51:5. **Buffer on kill-criterion Trigger 2.** `v1.0-kill-criterion.md` Trigger 2 fires 2026-06-14 if Diagnostic doesn't render cleanly. Today is 2026-05-24 — 21 days of buffer. Building now beats the deadline by 3 weeks.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:61:- ⏸ Iteration on Diagnostic output quality across 10-20 real UK firms
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:108:- `sequencing-target.md` §3.1 (Build Wave 1 = Diagnostic)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:109:- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:118:| Does the Diagnostic v0 produce reports good enough to send Jack for Q1 pitch? | Iteration loop in W3 polish (Step 7 + follow-ups). Quality gate: founder approval after running against 5-10 real firms. |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:120:| Does this break the master plan's "do not build out of order" rule? | No: ordering of agents (Diagnostic first) is preserved; only the substrate-vs-agent ordering within Weeks 3-4 is swapped, which §1.4 fallback architecture explicitly anticipates |
packages/mcp-connectors/companies-house/README.md:3:IFOS Companies House MCP connector for Diagnostic agent §4 Step 2 + 10 per `agents/recruitment/diagnostic/tools.yaml`.
packages/mcp-connectors/companies-house/README.md:66:v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
docs/decisions/sequencing-target.md:21:| A1 | Diagnostic | 3-4 | LinkedIn + Companies House + scrape | "Sales tool — needed before any other agent matters" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:92:### 2.1 — A1 Diagnostic
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:100:| 5. Dependencies on other agents | **None** | Standalone. No upstream agent dependency; no downstream agent consumes Diagnostic output |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:181:W3-4: Diagnostic (A1)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:192:- W4: Risk #5 (renderer) — Diagnostic first user. Reduction trigger fires (High → Medium per RISK-REGISTER #5).
docs/decisions/sequencing-target.md:207:W3-4: Diagnostic (A1) — substrate proof, non-negotiable
docs/decisions/sequencing-target.md:228:W3-4: Diagnostic (A1)
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:255:| 4. Commercial value | Tied (Diagnostic substrate, then flagship Concierge last; closing demo at W12-13 per Ultraplan §9 line 781) | Wins on raw timing (Concierge W5-8 demoable earlier) — but loses on substrate quality (Concierge ships with degraded Notes-for-context) | Tied — Concierge W6-9 marginally earlier than Alpha but with same substrate gaps as Beta |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:281:| 1 | W3-4 | **Diagnostic** (A1) | Substrate-proof agent; first renderer production render per ADR-003 design §5.2 |
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:326:- The substrate-first principle (Diagnostic W3-4 before any Bullhorn-touching agent).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:395:### 6.2 — For Week 3 (Diagnostic build start)
docs/decisions/sequencing-target.md:399:- Smallest viable Diagnostic exercising renderer + `_shared/` + `decision_log` end-to-end per §2.1 substrate-exercise column.
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:402:- First production render lands W4 per ADR-003 design §5.2 line "First production render is the Diagnostic agent at Week 4."
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:414:Diagnostic W3-W4 build window is the first production renderer exercise per ADR-003 design §5.2. The reduction-trigger cascade per `docs/RISK-REGISTER.md` Risk #5 fires:
docs/decisions/sequencing-target.md:417:- W4 Diagnostic first-render-clean → **Medium** (renderer code proven against one production bundle).
docs/decisions/sequencing-target.md:438:- **Diagnostic doesn't render by end of W3** (Risk #5 unmitigated; renderer impl Week 1-2 didn't ship)
docs/decisions/sequencing-target.md:450:- §5 gating criteria N values are calibrated to agent-specific risk profile (Cash Conductor's 24h sustained-operation vs Diagnostic's 3 ad-hoc runs).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/sequencing-target.md:494:| W3 vs W4 framing | §6.2 + §6.4 | Build-window-vs-completion-week distinction: Diagnostic build W3-W4, first production render W4. Not a true discrepancy. |
docs/decisions/sequencing-target.md:507:| Substrate readiness for W3 Diagnostic build (renderer + `_shared/` + `decision_log`) | Claude Code | End of W2 | Already tracked from ADR-002 + ADR-003 |
docs/decisions/sequencing-target.md:520:| Diagnostic W3 build start (vs W4 first render) | If renderer impl slips past end of W2, Diagnostic build start slips correspondingly |
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:104:| Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (`sequencing-target.md` §2.1) | Awaits Q1 LOI |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:289:| **A1 Diagnostic** (no Bullhorn) | n/a | n/a | n/a | n/a | n/a | n/a — runs against public footprint per Ultraplan §8.1 line 489 |
packages/mcp-connectors/companies-house/pnpm-lock.yaml:384:    resolution: {integrity: sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:571:    resolution: {integrity: sha512-FJHFfqpKUI3A10WrWKiFbBZ7yVbGT4q4B5o1qKFFojqpaYoh9LrQgqWCmmcxQzVSXYtyB5bzkXrYzlHTs21MYA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:626:    resolution: {integrity: sha512-QVTUovf40zgTqlFVrKA1uXMVvU2QWEFWfAH8Wdc48IxLvrJMQVMBRjuQyUpzZCDkakImib9eVazbWlC6ksWtJw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:814:    resolution: {integrity: sha512-//nshmD55c46FuFw26xV/xFAaB5HF9Xdap7HJBBnrKdAd6/GxDBaNA1870O79+9ueg61cZLSVc+OaFlfmObYVQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:965:    resolution: {integrity: sha512-o5a9xKjbtuhY6Bi5S3+HvbRERmouabWbyUcpXXUA1u+GNUKoROi9byOJ8M0nHbHYHkYICiMlqxkg1KkYmm25Sw==}
packages/harness/cortextos/templates/analyst/.claude/skills/system-diagnostics/SKILL.md:7:# System Diagnostics
packages/harness/cortextos/community/agents/security/.claude/skills/system-diagnostics/SKILL.md:7:# System Diagnostics
packages/harness/cortextos/templates/orchestrator/.claude/skills/system-diagnostics/SKILL.md:7:# System Diagnostics
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/system-diagnostics/SKILL.md:6:# System Diagnostics
packages/harness/cortextos/templates/agent/.claude/skills/system-diagnostics/SKILL.md:7:# System Diagnostics

 succeeded in 0ms:
packages/diagnostic-generator/src/generate.ts:34:  // §1 — Firm signal (Companies House)
packages/diagnostic-generator/src/generate.ts:40:  // §10 — Recent activity (Companies House filings)
packages/diagnostic-generator/src/generate.ts:49:    `**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).`,
.codex/ratification/review-agent-bundle.md:19:| §2 | Invocation surface | CLI / webhook / cron / Brain UI / Telegram triggers; per-trigger auth requirements; v1.1+ deferred surfaces | Missing; lists surfaces not supported by master brief §8.2 (e.g. uses AgentMail before v1.1) |
.codex/ratification/review-agent-bundle.md:24:| §7 | Voice + tone constraints | `_shared/voice-loader.sh` integration; per-tenant scope; voice classifier threshold per agent.md §5 | Missing for agents that produce text output; threshold drift from master brief §8.1 Change 1 |
.codex/ratification/review-agent-bundle.md:37:1. **master brief §8.2 line N** for build wave (e.g. "W5 per master brief §8.2 line 596"). Verify the line range actually contains the row claimed.
.codex/ratification/review-agent-bundle.md:38:2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
.codex/ratification/review-agent-bundle.md:41:5. **agents/_shared/voice-loader.sh** for voice-related claims. Verify the helper functions exist.
.codex/ratification/review-agent-bundle.md:51:- Kill-criterion Trigger references swapped (Trigger 5 cited when content describes Trigger 8 territory)
.codex/ratification/review-agent-bundle.md:94:1. **cortextOS submodule** — agent.md must NOT reference files under `packages/harness/cortextos/*`. cortextOS primitives are referenced by index (#1 Persistent PTY, #5 Telegram surface, etc.) NOT by file path.
.codex/ratification/review-agent-bundle.md:96:2. **Composio/AgentMail adapter** — agent.md MUST NOT reference Composio or AgentMail directly. References to v1.1+ AgentMail integration via adapter boundary are allowed when explicitly framed as "deferred".
.codex/ratification/review-agent-bundle.md:98:3. **Vault/Postgres split** — agent.md output contracts: structured per-row state → Postgres (decision_log, recent_edit, voice_corpus); narrative content → vault (Markdown files under `/vault/<tenant>/`). REJECT if §3 output shape mixes these (e.g., proposing to write 12-section Markdown reports to a Postgres column).
.codex/ratification/review-agent-bundle.md:100:4. **Brain-replacement** — agent.md MUST NOT propose direct interaction with cortextOS's stock KB. All knowledge-base interaction goes through the four `bus/kb-*.sh` shadow points OR through the agent's `_shared/voice-loader.sh` helpers.
.codex/ratification/review-agent-bundle.md:123:- Boundary violation (submodule modification, Composio/AgentMail in body, vault/Postgres mix, KB direct access)
.codex/ratification/review-agent-bundle.md:128:- "ESC code list omits ESC_RATE_LIMIT_HIT which Step N implies — suggest adding"
.codex/ratification/review-agent-bundle.md:129:- "§8 prereq list missing the voice classifier microservice as W4-5 dependency"
.codex/ratification/review-agent-bundle.md:137:Diagnostic was scaffold-ratified at Day-11 (Round 3 RATIFIED) + production-shape polished at Day-13 (commits `97a57a2` + `2688b6a`) + Day-19 remediation (commit `6e0cb86`). Codex Round 4 Phase 1 hit hard ceiling — see `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` for the 5-issue disposition.
packages/agents-runtime/_shared/common-accounting.json:5:  "description": "Accounting-system stub used by Cash Conductor (W7-8 v1.0). Xero-only in v1.0 per master brief §8.2 row 4; extensible later. Per PRODUCT-SPEC §5.3 line 362.",
packages/harness/cortextos/src/telegram/logging.ts:107:  const hasMedia = !!(msg.photo || msg.document || msg.voice || msg.audio || msg.video || msg.video_note);
packages/harness/PINNED-SHA.md:11:This submodule at `packages/harness/cortextos/` is a **reference pin**, not
packages/harness/PINNED-SHA.md:40:cd ~/code/CortexOS/packages/harness/cortextos
packages/harness/PINNED-SHA.md:46:git add packages/harness/cortextos packages/harness/PINNED-SHA.md
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:1:# IFOS recruitment vertical schema v0.2 — voice corpus supplement
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:8:# Closes Day-7-honest-read gap #1 (voice corpus schema undefined). Required by
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:9:# master brief §8.1 Change 1: agents/_shared/voice-loader.sh wires
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:26:author: founder (Maddox), Phase-4 voice-corpus-substrate via Claude Code
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:37:#   generic primitive layer from Day-4 §6.3. The voice corpus requires (a) pgvector
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:47:#   The 6 voice_classifier_score / voice_drift_at_close fields added to existing
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:50:#   primitive layer; they are validated by the `validate_voice_scores` trigger
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:59:    bullhorn_source: none (IFOS-derived from /vault/<tenant>/_voice/ ingest)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:61:      - Scribe (R — voice samples for note-summary tone matching)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:62:      - Concierge (R — voice samples for outbound message generation)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:63:      - voice-drift-canary nightly cron (R — drift detection input)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:84:        source: IFOS-derived (vault _voice/ subdirectory enumeration)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:97:          Enum: ["paragraph", "sentence-window-5", "semantic-segment-v1"]. v0.2 ships with "paragraph" (simplest, deterministic). Other values reserved for v1.1 experimentation per Q5 voice gate research.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:126:    bullhorn_source: none (IFOS-derived; authored in /vault/<tenant>/_voice/tone-rules.yaml then synced to Postgres)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:155:        source: IFOS-derived (operator picks subset from master brief §8.2 agents)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:157:          Items: agent_name slugs from master brief §8.2 (e.g. ["scribe", "concierge"]). Empty array = applies to all agents. tone_rule rows MUST set this to at least one agent; "all agents" requires the empty-array literal.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:191:      Human edit to an agent's output captured at the point the consultant approves/edits/rejects a draft. Drives (a) the voice-drift-canary nightly cron, (b) future LoRA SFT pair generation per Ultraplan §6.1, (c) classifier retraining queue. Append-only per master brief §3.3 audit discipline.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:194:      - voice-drift-canary cron (R — drift detection)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:218:          Optional pointer to the entity the draft was about (e.g. "candidate", "client"). Enables linking voice drift to entity classes (some entity types correlate with more drift).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:267:  voice_samples_embedded:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:269:      Semantic-search index over voice_corpus text chunks. Read by hh_load_voice_samples to retrieve the top-K most-relevant voice samples for the agent's current task context.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:270:    table: voice_corpus_chunks                       # auxiliary table; see §3 migration SQL
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:279:      Per-tenant query pattern via RLS: SELECT * FROM voice_corpus_chunks WHERE tenant_slug = current_setting('app.current_tenant') ORDER BY embedding <=> $query_vec LIMIT 10. RLS predicate ensures cross-tenant isolation even if a developer forgets the WHERE clause.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:289:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:297:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:301:      notes: Same as candidate.voice_classifier_score, scoped to contractor sub-case.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:304:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:309:        Most-recent voice classifier score from Concierge outbound messages addressed to this contact. Drives addressee-specific drift detection (some contacts' tone preferences may differ from firm baseline).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:312:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:317:        Aggregate (last-7-day mean) voice classifier score across all Concierge messages about this brief. Drives "this brief is producing voice-drift messages — investigate" alerting.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:320:    voice_classifier_score:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:325:        v1.1+ Triage exercises this; v1.0 sets to NULL. Tracks voice score for outbound messages within a specific candidate-brief opportunity pairing.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:328:    voice_drift_at_close:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:341:  voice_corpus_governs_tone_rules:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:342:    source: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:346:      One voice_corpus version logically governs the set of tone_rules active at that version. When voice_corpus rolls forward (new version, is_active flipped), tone_rules don't migrate automatically — but the linkage records WHICH rules were active under WHICH corpus for audit and rollback.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:348:      Sparse in v0.2 (linkage is recorded but not actively queried). v1.1 voice-drift-canary cross-references to identify rule-corpus mismatches.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:352:    target: voice_corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:384:  Q11_voice_corpus_chunk_storage:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:395:      When a `severity: block` tone_rule fires Gate A, does the agent retry once, three times, or surface ESC_VOICE_DRIFT immediately?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:438:      Phase 5 — execute migration SQL against migration-test tenant; verify pgvector HNSW index builds clean; voice-loader.sh queries return expected shape; commit.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:440:  v1_0_voice:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:441:    expected_date: post-Concierge build (W10-13) — first agent to heavily exercise voice corpus
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:445:  v1_1_voice:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:446:    expected_date: post-first-pilot voice corpus mature (Q4 2026 if pilot lands)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:450:  v2_0_voice:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
agents/_shared/autosend-policy.yaml:29:  diagnostic_report_render:
agents/_shared/autosend-policy.yaml:31:    agent: diagnostic
agents/_shared/autosend-policy.yaml:53:  xero_query_invoices:
agents/_shared/autosend-policy.yaml:101:    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
agents/_shared/autosend-policy.yaml:151:  diagnostic_email_send:
agents/_shared/autosend-policy.yaml:153:    agent: diagnostic
agents/_shared/autosend-policy.yaml:155:    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
agents/_shared/autosend-policy.yaml:158:  diagnostic_calendar_invite:
agents/_shared/autosend-policy.yaml:160:    agent: diagnostic
agents/_shared/autosend-policy.yaml:180:  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
packages/harness/cortextos/src/telegram/media.ts:3: * Downloads and processes photo, document, audio, voice, video, and video_note messages.
packages/harness/cortextos/src/telegram/media.ts:14:  type: 'photo' | 'document' | 'audio' | 'voice' | 'video' | 'video_note';
packages/harness/cortextos/src/telegram/media.ts:144:  if (msg.voice) {
packages/harness/cortextos/src/telegram/media.ts:145:    const fileName = `voice_${date}.ogg`;
packages/harness/cortextos/src/telegram/media.ts:146:    const fileResponse = await api.getFile(msg.voice.file_id);
packages/harness/cortextos/src/telegram/media.ts:157:      type: 'voice',
packages/harness/cortextos/src/telegram/media.ts:163:      duration: msg.voice.duration,
packages/diagnostic-generator/src/cli.ts:12:  .name("ifos-diagnostic-generate")
packages/diagnostic-generator/src/cli.ts:14:  .requiredOption("--firm <name>", "Firm name (free-text; used for Companies House search)")
packages/diagnostic-generator/src/cli.ts:53:  process.stderr.write(`ifos-diagnostic-generate: ${(err as Error).message}\n`);
.codex/ratification/SKILL.md:24:3. **Reuse before build** — `_shared/` helpers (`hook-helpers.sh`, `voice-loader.sh`, `escalation-codes.md`) + `common-*.json` schemas + ESC catalogue exist; new code must reuse, not re-implement. Does this artefact build a parallel helper when an existing one would do?
.codex/ratification/SKILL.md:36:1. **Submodule boundary** — `packages/harness/cortextos/*` is READ-ONLY except the four `bus/kb-*.sh` files we shadow via `packages/brain/bus-overrides/`. Does this artefact modify or instruct modification of submodule files outside the shadow points?
.codex/ratification/SKILL.md:38:2. **Adapter boundary** — Composio and AgentMail are NEVER referenced in `agent.md`, `tools.yaml`, vault files, or fixtures. Does this artefact mention either name in those locations?
.codex/ratification/SKILL.md:40:3. **Vault/Postgres split** — Markdown content lives in vault (`/vault/<tenant>/`); structured state lives in Postgres (`decision_log`, `entities`, `entity_links`, `voice_corpus`, etc.); pgvector indexes over both. Does this artefact mix the two (e.g., narrative content into Postgres, structured state into markdown)?
.codex/ratification/review-schema-change.md:19:The vertical schema specifies (a) which `entity_type` slugs are valid, (b) what JSON shape `entities.data` takes per entity_type, (c) which `link_type` slugs are valid. **Schemas DO NOT create new Postgres tables in v0.X** — supplements that propose new tables (e.g., `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`) MUST be paired with explicit `docs/verticals/recruitment/migrations/vN.M-to-vN.M+1.sql` companion files OR explicitly mark the new tables as "auxiliary v0.X tables, not entities".
.codex/ratification/review-schema-change.md:34:- `v1_0_agent_access` — list of agents from master brief §8.2 with R / W / R+W disposition, OR explicit "none (v1.1+ exercise)"
.codex/ratification/review-schema-change.md:56:- If a field references a `voice_classifier_score` or similar [0.0, 1.0] bounded value, confirm the migration SQL adds a CHECK constraint OR a trigger
.codex/ratification/review-schema-change.md:142:## §9 — Voice corpus + voice score consistency (for v0.2 + later)
.codex/ratification/review-schema-change.md:144:If the supplement defines voice_corpus / tone_rule / recent_edit (Phase 4 patterns):
.codex/ratification/review-schema-change.md:146:- `voice_corpus` MUST have a `version` field (semver) + `is_active` boolean + at-most-one-active enforced (partial unique index in migration SQL)
.codex/ratification/review-schema-change.md:147:- `voice_corpus` chunking_strategy enum must be exhaustive — listing only "paragraph" without "sentence-window-N" or "semantic-segment-vN" reserved is acceptable for v0.X but should name the reserved values
.codex/ratification/review-schema-change.md:152:- `voice_classifier_score` fields on entities must be `[0.0, 1.0]` bounded — REJECT if no CHECK constraint or trigger is named in migration
.codex/ratification/review-schema-change.md:181:- [ ] (For v0.2+) voice corpus + tone_rule + recent_edit invariants checked
packages/agents-runtime/_shared/common-notifications.json:42:      "description": "IFOS-side oncall Telegram chat; receives ESC_AUTOSEND_POLICY_LOOKUP_FAILED + cross-tenant operational alerts."
packages/agents-runtime/_shared/common-notifications.json:49:      "description": "4h default per autosend-safety-policy §5 ESC_AUTOSEND_NEEDS_REVIEW; timeout converts orange-tier to ESC_AUTOSEND_NEEDS_REVIEW row."
.codex/ratification/review-architecture-decision.md:129:- **Submodule reference** — decision docs MAY name cortextOS files for reference (e.g., `add-agent.ts:131-140`); they MUST NOT propose modifying them. If the ADR proposes a modification to `packages/harness/cortextos/*` outside the shadow points, REJECT.
.codex/ratification/review-architecture-decision.md:131:- **Adapter boundary** — `Composio` and `AgentMail` may appear in INTERNAL discussion text (e.g., "we considered Composio") but MUST NOT appear in `tools.yaml` shape definitions, agent.md examples, or schema fixtures. If the ADR proposes including either in any of those locations, REJECT.
.codex/ratification/review-architecture-decision.md:175:- [ ] No Composio/AgentMail in `tools.yaml`/`agent.md` examples
.codex/ratification/review-postgres-migration.md:39:Auxiliary tables that are scoped per-tenant (e.g., `voice_corpus_chunks` referencing `voice_corpus(id)`) MUST also carry their OWN `tenant_slug` column + RLS policy — not rely on the parent table's RLS. (Joins with FK can be subverted; per-table RLS cannot.)
.codex/ratification/review-postgres-migration.md:61:For `voice_samples_embedded` and similar pgvector ANN indexes:
.codex/ratification/review-postgres-migration.md:86:- `SELECT, INSERT, UPDATE` for mutable tables (`voice_corpus`, `tone_rule`)
.codex/ratification/review-postgres-migration.md:87:- `SELECT, INSERT, UPDATE, DELETE` for append-and-purge (`voice_corpus_chunks`)
.codex/ratification/review-postgres-migration.md:124:  - `voice_corpus.chunking_strategy` CHECK IN ('paragraph', 'sentence-window-5', 'semantic-segment-v1')
.codex/ratification/review-postgres-migration.md:133:For triggers that validate JSONB content (e.g., `validate_voice_scores` from v0.2):
.codex/ratification/review-postgres-migration.md:158:2. Drop in reverse dependency order (e.g., `recent_edit` → `tone_rule` → `voice_corpus_chunks` → `voice_corpus`)
.codex/ratification/review-postgres-migration.md:191:- **CASCADE in CREATE FOREIGN KEY** — `REFERENCES voice_corpus(id) ON DELETE CASCADE` is fine; `ON UPDATE CASCADE` is suspicious for tenant_slug FKs (tenant slugs are pseudo-immutable; UPDATE cascade implies they change). Check that ON UPDATE CASCADE is intentional.
.codex/ratification/review-postgres-migration.md:193:- **Index on JSONB without GIN/GIST** — `CREATE INDEX foo_data_key_idx ON entities (data->>'voice_classifier_score')` works but is suboptimal for non-equality queries. Either use a GIN index OR the JSONB key extraction must be cast appropriately. Advisory; not a hard reject.
.codex/ratification/review-postgres-migration.md:208:Tenant A sets app.current_tenant='acme'; SELECT * FROM voice_corpus_chunks;
.codex/ratification/review-postgres-migration.md:209:Tenant B sets app.current_tenant='globex'; SELECT * FROM voice_corpus_chunks;
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
agents/_shared/escalation-codes.md:122:- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
agents/_shared/escalation-codes.md:127:#### `ESC_DUPLICATE_DETECTED`
agents/_shared/escalation-codes.md:134:#### `ESC_JSL_RED_FLAG`
agents/_shared/escalation-codes.md:141:#### `ESC_BRIEF_AMBIGUITY`
agents/_shared/escalation-codes.md:143:- **Trigger:** Brief Decoder (Sourcing Scout subskill at master brief §8.2 row 5; full agent in v1.1+) cannot resolve brief requirements to confident shortlist criteria
agents/_shared/escalation-codes.md:148:#### `ESC_PII_LEAKAGE_RISK`
agents/_shared/escalation-codes.md:156:#### `ESC_RATE_LIMIT_HIT`
agents/_shared/escalation-codes.md:163:#### `ESC_SCHEMA_VIOLATION`
agents/_shared/escalation-codes.md:170:#### `ESC_VOICE_DRIFT_TENANT`
agents/_shared/escalation-codes.md:172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
agents/_shared/escalation-codes.md:174:- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (CSM may need to retrain voice corpus)
agents/_shared/escalation-codes.md:177:#### `ESC_INPUT_VALIDATION_FAIL`
agents/_shared/escalation-codes.md:184:#### `ESC_AGENT_OUTPUT_SHAPE`
agents/_shared/escalation-codes.md:186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
agents/_shared/escalation-codes.md:194:#### `ESC_HUMAN_EDITING_LOCK`
agents/_shared/escalation-codes.md:201:#### `ESC_VAULT_CONCURRENCY`
agents/_shared/escalation-codes.md:203:- **Trigger:** Generic vault concurrency anomaly not covered by ESC_VAULT_LOCK_TIMEOUT / ESC_VAULT_VERSION_MISMATCH / ESC_VAULT_HUMAN_EDIT_BLOCKED / ESC_VAULT_CASCADE_*
agents/_shared/escalation-codes.md:209:#### `ESC_VAULT_RENAME_RACE`
agents/_shared/escalation-codes.md:216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
agents/_shared/escalation-codes.md:223:#### `ESC_CORTEXTOS_HANDOFF`
agents/_shared/escalation-codes.md:230:#### `ESC_CORTEXTOS_DEGRADED`
agents/_shared/escalation-codes.md:232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
agents/_shared/escalation-codes.md:245:| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
agents/_shared/escalation-codes.md:246:| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
agents/_shared/escalation-codes.md:254:1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
agents/_shared/escalation-codes.md:255:2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)
agents/_shared/escalation-codes.md:265:New codes added here BEFORE wiring into helpers + before any agent references them. Code names case-sensitive (`ESC_[A-Z][A-Z0-9_]*`).
docs/verticals/recruitment/vertical-schema.yaml:14:#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
docs/verticals/recruitment/vertical-schema.yaml:35:#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
docs/verticals/recruitment/vertical-schema.yaml:42:# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
docs/verticals/recruitment/vertical-schema.yaml:142:      voice_classifier_score:
docs/verticals/recruitment/vertical-schema.yaml:145:        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
docs/verticals/recruitment/vertical-schema.yaml:147:          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
docs/verticals/recruitment/vertical-schema.yaml:255:        source: IFOS-derived (Diagnostic enriches from Companies House per master brief §3.2 first-party MCP list)
docs/verticals/recruitment/vertical-schema.yaml:256:        notes: UK statutory identifier; key for Diagnostic agent's public-footprint enrichment per Ultraplan §8.1 A1.
docs/verticals/recruitment/vertical-schema.yaml:280:      - Companies House enrichment is Diagnostic agent's domain; the field is set by Diagnostic at first-pass.
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:674:    client: none  # Diagnostic enriches client public-footprint at Companies House but writes to a separate IFOS-internal diagnostic_report artefact, not to client entity directly
docs/verticals/recruitment/vertical-schema.yaml:680:    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
docs/verticals/recruitment/vertical-schema.yaml:758:    notes: Companies House number is IFOS-derived from Diagnostic enrichment, not Bullhorn-sourced.
docs/verticals/recruitment/vertical-schema.yaml:893:    target: Week-4-end (~2026-06-21 if Week 1 starts 2026-05-21 per Day-5 kill criterion §2 Trigger 1 calendar).
packages/agents-runtime/_shared/common-voice.json:3:  "$id": "https://intelforce.os/schemas/common-voice.json",
packages/agents-runtime/_shared/common-voice.json:4:  "title": "common-voice",
packages/agents-runtime/_shared/common-voice.json:5:  "description": "Per-tenant voice corpus reference. Read by agents/_shared/voice-loader.sh per master brief §8.1 Change 1. Schema substrate landed in vertical-schema.yaml v0.2 (Phase 4).",
packages/agents-runtime/_shared/common-voice.json:8:    "voice_corpus_path": {
packages/agents-runtime/_shared/common-voice.json:10:      "default": "/vault/{tenant_slug}/_voice/",
packages/agents-runtime/_shared/common-voice.json:11:      "description": "Vault directory holding voice samples and tone rules. Token {tenant_slug} resolved at render time."
packages/agents-runtime/_shared/common-voice.json:13:    "voice_pack_version": {
packages/agents-runtime/_shared/common-voice.json:16:      "description": "Tag matching docs/verticals/recruitment/vertical-schema.yaml voice_corpus.version row."
packages/agents-runtime/_shared/common-voice.json:20:      "default": "/vault/{tenant_slug}/_voice/style-guide.md",
packages/agents-runtime/_shared/common-voice.json:25:      "default": "/vault/{tenant_slug}/_voice/banned-phrases.md",
packages/agents-runtime/_shared/common-voice.json:26:      "description": "Phrases that trigger ESC_VOICE_DRIFT before classifier scoring."
packages/agents-runtime/_shared/common-voice.json:28:    "voice_classifier_threshold": {
packages/agents-runtime/_shared/common-voice.json:33:      "description": "Per bullhorn-integration-path.md §4.1 A6 Concierge gate; voice classifier scores below this fail Gate A."
packages/agents-runtime/_shared/common-voice.json:49:  "required": ["voice_corpus_path", "voice_classifier_threshold"],
packages/harness/cortextos/src/telegram/api.ts:87:  // diagnostic emitted at most once per chat_id per process lifetime.
packages/utilities/web-scraper/package.json:5:  "description": "IFOS web scraper utility — HTTP HEAD + first-N-lines fetch + cache + robots.txt. Used by Diagnostic agent §4 Step 3+6+8 per agents/recruitment/diagnostic/tools.yaml.",
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:16:| `tests/test-voice-loader.sh` | Offline test harness — 9 tests against fallback mode | 5 |
agents/_shared/README.md:42:| `HH_ESC_CATALOGUE` | no | Override path to `escalation-codes.md` | `${CTX_AGENT_DIR}/.claude/hooks/_shared/escalation-codes.md` |
agents/_shared/README.md:64:autosend_escalate             <ESC_CODE> [<key=value>...]
agents/_shared/README.md:78:| **orange** | Emit `phase=action` + escalate `ESC_AUTOSEND_NEEDS_REVIEW`, block on approval gate, return 0/1 | depends on approval |
agents/_shared/README.md:79:| **red** | Emit `phase=gating_failed` + escalate `ESC_AUTOSEND_BLOCKED`, return 1 | 1 |
agents/_shared/README.md:80:| _unknown_ | Emit `phase=gating_failed` (`fail-safe-red`) + escalate `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`, return 1 | 1 |
agents/_shared/README.md:88:**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).
agents/_shared/README.md:98:### `voice-loader.sh` helpers (3, master brief §8.1 Change 1)
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:134:Schema v0.2 voice corpus migration. Procedure:
agents/_shared/README.md:144:   - 4 new tables (`voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`)
agents/_shared/README.md:145:   - `voice_samples_embedded` HNSW index on `voice_corpus_chunks.embedding`
agents/_shared/README.md:146:   - `validate_voice_scores` trigger on `entities`
agents/_shared/README.md:147:   - 1 seed row in `voice_corpus` for `migration-test` with `version='v0.2-seed'`, `is_active=TRUE`
agents/_shared/README.md:148:4. Smoke `voice-loader.sh` against live DB:
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/_shared/README.md:170:- `agents/_shared/voice-loader.sh` (Reference — voice corpus + tone rules + recent edits)
agents/_shared/README.md:171:- `agents/_shared/tests/test-voice-loader.sh` (Reference — test harness, 9 tests)
packages/utilities/web-scraper/README.md:3:IFOS web scraper utility for Diagnostic agent §4 Step 3 + 6 + 8 per `agents/recruitment/diagnostic/tools.yaml`.
packages/utilities/web-scraper/README.md:51:v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
packages/agents-runtime/_shared/common-vault.json:13:    "voice_subdir": {
packages/agents-runtime/_shared/common-vault.json:15:      "default": "_voice/",
packages/agents-runtime/_shared/common-vault.json:16:      "description": "Relative to vault_root; holds style-guide.md + banned-phrases.md + voice samples."
packages/agents-runtime/_shared/common-vault.json:69:      "description": "MAX_RETRIES per vault-concurrency §4; raises ESC_VAULT_HUMAN_EDIT_BLOCKED on exhaust."
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:19:DROP TRIGGER IF EXISTS validate_voice_scores ON entities;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:20:DROP FUNCTION IF EXISTS validate_voice_score_fields();
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:28:DROP TABLE IF EXISTS voice_corpus_chunks  CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:29:DROP TABLE IF EXISTS voice_corpus         CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:32:-- §3 — Optional: purge voice_classifier_score / voice_drift_at_close keys
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:39:-- SET data = data - 'voice_classifier_score' - 'voice_drift_at_close'
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:41:--   AND (data ? 'voice_classifier_score' OR data ? 'voice_drift_at_close');
packages/diagnostic-generator/src/sections/online-footprint.ts:62:      // Remember the LAST status seen for diagnostic reporting if nothing matches
packages/diagnostic-generator/src/sections/online-footprint.ts:87:      `LinkedIn company page: [${data.linkedInUrl}](${data.linkedInUrl}) (page exists; LinkedIn bot-detection returned ${data.linkedInStatus}, full content needs authenticated fetch — Proxycurl integration v1.1).`,
packages/harness/cortextos/src/telegram/transcribe.ts:36: * Transcribe a Telegram voice .ogg file. Returns the trimmed transcript
agents/_shared/tests/test-hook-helpers.sh:83:export HH_ESC_CATALOGUE="${REPO_ROOT}/agents/_shared/escalation-codes.md"
agents/_shared/tests/test-hook-helpers.sh:109:  hh_decision_output "diagnostic_report" "/vault/x/y.md"
agents/_shared/tests/test-hook-helpers.sh:113:    && _assert_contains "${row}" '"output_type":"diagnostic_report"'
agents/_shared/tests/test-hook-helpers.sh:118:test_lookup_green() { local t; t=$(autosend_policy_lookup "diagnostic_report_render"); _assert_eq "green" "${t}" "green"; }
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
agents/_shared/tests/test-hook-helpers.sh:145:  hh_decision_action "xero_payment_initiate" "invoice:42" "def456" "test"
agents/_shared/tests/test-hook-helpers.sh:152:    && _assert_contains "${row}" '"escalation_code":"ESC_AUTOSEND_BLOCKED"'
agents/_shared/tests/test-hook-helpers.sh:154:_test_run "red action: rc=1 + phase=gating_failed + ESC_AUTOSEND_BLOCKED" test_action_red
agents/_shared/tests/test-hook-helpers.sh:166:    && _assert_contains "${row}" '"escalation_code":"ESC_AUTOSEND_NEEDS_REVIEW"'
agents/_shared/tests/test-hook-helpers.sh:168:_test_run "orange action approved: rc=0 + ESC_AUTOSEND_NEEDS_REVIEW row + tier=orange" test_action_orange_approve
agents/_shared/tests/test-hook-helpers.sh:179:printf '\n[8] hh_decision_action — unknown action_type → ESC_AUTOSEND_POLICY_LOOKUP_FAILED\n'
agents/_shared/tests/test-hook-helpers.sh:187:    && _assert_contains "${row}" '"escalation_code":"ESC_AUTOSEND_POLICY_LOOKUP_FAILED"'
agents/_shared/tests/test-hook-helpers.sh:189:_test_run "unknown action: rc=1 + ESC_AUTOSEND_POLICY_LOOKUP_FAILED" test_action_unknown
agents/_shared/tests/test-hook-helpers.sh:236:  autosend_escalate "ESC_NONEXISTENT_CODE" 2>/dev/null
agents/_shared/tests/test-hook-helpers.sh:287:  # (b) the autosend_escalate ESC_AUTOSEND_BLOCKED escalation row
agents/_shared/tests/test-hook-helpers.sh:293:    hh_decision_action "xero_payment_initiate" "invoice:${i}" "hashred${i}" "amount: £100"
agents/_shared/tests/test-hook-helpers.sh:298:  blocked_esc_count=$(grep -c '"escalation_code":"ESC_AUTOSEND_BLOCKED"' "${IFOS_DECISION_LOG_FALLBACK}")
agents/_shared/hook-helpers.sh:32:_HH_ESC_CATALOGUE="${HH_ESC_CATALOGUE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/escalation-codes.md}"
agents/_shared/hook-helpers.sh:87:  if [[ ! -f "${_HH_ESC_CATALOGUE}" ]]; then
agents/_shared/hook-helpers.sh:90:  if grep -Fq "\`${code}\`" "${_HH_ESC_CATALOGUE}"; then
agents/_shared/hook-helpers.sh:205:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:213:    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:236:      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:244:      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
agents/_shared/hook-helpers.sh:251:      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
agents/_shared/hook-helpers.sh:353:# autosend_escalate <ESC_CODE> [<key=value>...]
agents/_shared/hook-helpers.sh:356:# + ESC_AUTOSEND_POLICY_LOOKUP_FAILED meta-escalation.
agents/_shared/hook-helpers.sh:511:        autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
agents/_shared/hook-helpers.sh:537:  # Timed out — convert to ESC_AUTOSEND_NEEDS_REVIEW with timeout marker.
agents/_shared/hook-helpers.sh:539:  autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
packages/diagnostic-generator/src/sections/firm-signal.ts:1:// §1 — Firm signal. Companies House profile + officers + filing history.
packages/diagnostic-generator/src/sections/firm-signal.ts:83:      `No active Companies House registration found for **${firmName}**. Diagnostic proceeded against publicly visible non-CH signals only.`,
packages/diagnostic-generator/src/sections/firm-signal.ts:86:    lines.push(`Source: [Companies House search](${chUrl})`);
packages/diagnostic-generator/src/sections/firm-signal.ts:91:    `**${data.companyName}** (CRN ${data.companyNumber}) is currently ${data.status === "active" ? "active" : `\`${data.status}\``} at Companies House.`,
packages/diagnostic-generator/src/sections/firm-signal.ts:121:  lines.push(`Source: [Companies House profile](${chUrl})`);
agents/_shared/voice-loader.sh:3:# IFOS voice-loader — implements the 3 hh_load_* helpers per master brief
agents/_shared/voice-loader.sh:5:# voice corpus, tone rules, and recent edits into the agent's context bundle.
agents/_shared/voice-loader.sh:10:#   - Falls back to /vault/<tenant>/_voice/ markdown files if DB unavailable
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:28:# (helpers may not be loaded yet if voice-loader is called standalone).
agents/_shared/voice-loader.sh:102:  # Fallback: read /vault/<tenant>/_voice/tone-rules.yaml
agents/_shared/voice-loader.sh:103:  local fallback_file="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/_voice/tone-rules.yaml"
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:137:# Runs pgvector ANN against voice_corpus_chunks for the active voice_corpus
agents/_shared/voice-loader.sh:141:# voice-loader with the literal vector pre-encoded.
agents/_shared/voice-loader.sh:143:# Falls back to /vault/<tenant>/_voice/style-guide.md when DB or query vector
agents/_shared/voice-loader.sh:149:#     "voice_corpus_version": "v0.2-seed",
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:161:    # Live mode: run HNSW ANN query against active voice_corpus
agents/_shared/voice-loader.sh:164:         FROM voice_corpus_chunks vcc
agents/_shared/voice-loader.sh:165:         JOIN voice_corpus vc ON vc.id = vcc.voice_corpus_id
agents/_shared/voice-loader.sh:172:    version="$(_vl_psql_query "SELECT version FROM voice_corpus WHERE is_active = TRUE LIMIT 1;")"
agents/_shared/voice-loader.sh:173:    _vl_render_voice_samples_json "${rows}" "${version:-unknown}" "db" "${task_context}"
agents/_shared/voice-loader.sh:178:  local style_guide="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/_voice/style-guide.md"
agents/_shared/voice-loader.sh:180:    printf '{"samples":[],"voice_corpus_version":"fallback","source":"fallback","style_guide_path":"%s","task_context":"%s","reason":"%s"}\n' \
agents/_shared/voice-loader.sh:186:  printf '{"samples":[],"voice_corpus_version":"empty","source":"empty","task_context":"%s","reason":"no_db_no_style_guide"}\n' \
agents/_shared/voice-loader.sh:190:# Internal: render psql TSV → JSON for voice samples.
agents/_shared/voice-loader.sh:191:_vl_render_voice_samples_json() {
agents/_shared/voice-loader.sh:198:    printf '{"samples":[],"voice_corpus_version":"%s","source":"%s","task_context":"%s","count":0}\n' \
agents/_shared/voice-loader.sh:216:  printf '],"voice_corpus_version":"%s","source":"%s","task_context":"%s"}\n' \
agents/_shared/tests/test-voice-loader.sh:4:# Offline test harness for agents/_shared/voice-loader.sh.
agents/_shared/tests/test-voice-loader.sh:7:# Run: bash agents/_shared/tests/test-voice-loader.sh
agents/_shared/tests/test-voice-loader.sh:51:LOADER="${REPO_ROOT}/agents/_shared/voice-loader.sh"
agents/_shared/tests/test-voice-loader.sh:53:TMP_ROOT="$(mktemp -d -t voice-loader-test.XXXXXXXX)"
agents/_shared/tests/test-voice-loader.sh:63:mkdir -p "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_voice"
agents/_shared/tests/test-voice-loader.sh:80:  cat > "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_voice/tone-rules.yaml" <<EOF
agents/_shared/tests/test-voice-loader.sh:91:printf '\n[3] hh_load_voice_samples returns valid JSON in fallback mode\n'
agents/_shared/tests/test-voice-loader.sh:92:test_voice_samples_no_db() {
agents/_shared/tests/test-voice-loader.sh:94:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:97:_test_run "voice_samples fallback (no DB): valid JSON with task_context" test_voice_samples_no_db
agents/_shared/tests/test-voice-loader.sh:99:printf '\n[4] hh_load_voice_samples surfaces style guide when present\n'
agents/_shared/tests/test-voice-loader.sh:100:test_voice_samples_style_guide() {
agents/_shared/tests/test-voice-loader.sh:101:  echo "# Voice style" > "${IFOS_VAULT_ROOT}/${CTX_TENANT_SLUG}/_voice/style-guide.md"
agents/_shared/tests/test-voice-loader.sh:103:  out=$(hh_load_voice_samples "candidate-outreach")
agents/_shared/tests/test-voice-loader.sh:108:_test_run "voice_samples fallback: style_guide_path surfaced" test_voice_samples_style_guide
agents/_shared/tests/test-voice-loader.sh:110:printf '\n[5] hh_load_voice_samples top_k validation clamps to 10\n'
agents/_shared/tests/test-voice-loader.sh:111:test_voice_samples_invalid_top_k() {
agents/_shared/tests/test-voice-loader.sh:113:  out=$(hh_load_voice_samples "task" "abc")  # non-numeric → 10
agents/_shared/tests/test-voice-loader.sh:115:  out=$(hh_load_voice_samples "task" "999")  # over cap → 10
agents/_shared/tests/test-voice-loader.sh:117:  out=$(hh_load_voice_samples "task" "0")    # zero → 10
agents/_shared/tests/test-voice-loader.sh:120:_test_run "voice_samples top_k validation: non-numeric/over-cap/zero accepted" test_voice_samples_invalid_top_k
agents/_shared/tests/test-voice-loader.sh:157:  out2=$(hh_load_voice_samples "task" | wc -l | tr -d ' ')
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:9:-- Closes Day-7-honest-read gap #1 (voice corpus schema). v0.2 additions:
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:11:--   - 1 auxiliary table: voice_corpus_chunks (holds the pgvector index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:12:--   - 1 pgvector HNSW index: voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:43:-- §2 — Create voice_corpus table (per-tenant voice pack)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:46:CREATE TABLE IF NOT EXISTS voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:59:  CONSTRAINT voice_corpus_tenant_version_unique UNIQUE (tenant_slug, version)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:62:-- Partial unique index: at most one active voice_corpus per tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:63:CREATE UNIQUE INDEX IF NOT EXISTS voice_corpus_one_active_per_tenant
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:64:  ON voice_corpus (tenant_slug)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:67:CREATE INDEX IF NOT EXISTS voice_corpus_tenant_slug_idx ON voice_corpus (tenant_slug);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:69:ALTER TABLE voice_corpus ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:70:ALTER TABLE voice_corpus FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:71:DROP POLICY IF EXISTS voice_corpus_tenant_isolation ON voice_corpus;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:72:CREATE POLICY voice_corpus_tenant_isolation ON voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:76:-- §3 — Create voice_corpus_chunks table (pgvector substrate)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:78:-- One row per chunk produced from voice_corpus source docs. Embedding column
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:79:-- is the indexed surface for hh_load_voice_samples semantic retrieval.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:82:CREATE TABLE IF NOT EXISTS voice_corpus_chunks (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:85:  voice_corpus_id   BIGINT      NOT NULL REFERENCES voice_corpus (id) ON DELETE CASCADE,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:91:  CONSTRAINT voice_corpus_chunks_corpus_chunk_unique UNIQUE (voice_corpus_id, chunk_index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:94:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_tenant_idx ON voice_corpus_chunks (tenant_slug);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:95:CREATE INDEX IF NOT EXISTS voice_corpus_chunks_corpus_idx ON voice_corpus_chunks (voice_corpus_id);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:98:CREATE INDEX IF NOT EXISTS voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:99:  ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:103:ALTER TABLE voice_corpus_chunks ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:104:ALTER TABLE voice_corpus_chunks FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:105:DROP POLICY IF EXISTS voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:106:CREATE POLICY voice_corpus_chunks_tenant_isolation ON voice_corpus_chunks
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:177:GRANT SELECT, INSERT, UPDATE        ON voice_corpus        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:178:GRANT SELECT, INSERT, UPDATE, DELETE ON voice_corpus_chunks TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:182:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_id_seq        TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:183:GRANT USAGE, SELECT ON SEQUENCE voice_corpus_chunks_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:199:--   ALTER TABLE voice_corpus OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:200:--   ALTER TABLE voice_corpus_chunks OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:203:--   ALTER SEQUENCE voice_corpus_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:204:--   ALTER SEQUENCE voice_corpus_chunks_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:214:-- §7 — Extend entities.data JSONB with 6 voice-score keys
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:221:CREATE OR REPLACE FUNCTION validate_voice_score_fields()
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:224:  score_keys TEXT[] := ARRAY['voice_classifier_score', 'voice_drift_at_close'];
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:246:CREATE OR REPLACE TRIGGER validate_voice_scores
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:250:  EXECUTE FUNCTION validate_voice_score_fields();
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:280:-- §9 — Reference rows: seed migration-test tenant with a starter voice_corpus
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:282:-- Inserts a single empty active voice_corpus row for migration-test only.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:283:-- This lets Phase 5 voice-loader.sh return a defined-empty result rather
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:289:INSERT INTO voice_corpus (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:313:-- SELECT count(*) FROM voice_corpus WHERE tenant_slug = 'migration-test';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:315:-- SELECT indexname FROM pg_indexes WHERE tablename = 'voice_corpus_chunks';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:316:--   → expect: voice_corpus_chunks_pkey, voice_corpus_chunks_tenant_idx,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:317:--             voice_corpus_chunks_corpus_idx, voice_samples_embedded
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:321:--   → expect validate_voice_scores
packages/diagnostic-generator/src/sections/recent-activity.ts:1:// §10 — Recent activity. Companies House filings last 90 days +
packages/diagnostic-generator/src/sections/recent-activity.ts:42:      "No filings at Companies House in the last 90 days. May indicate quiet period OR firm is between annual cycles.",
packages/diagnostic-generator/src/sections/recent-activity.ts:46:      `${data.filings.length} filing${data.filings.length === 1 ? "" : "s"} in last 90 days (Companies House):`,
packages/diagnostic-generator/src/sections/recent-activity.ts:55:    "**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.",
packages/diagnostic-generator/src/sections/recent-activity.ts:58:  lines.push(`Source: [Companies House filing history](${chUrl})`);
packages/harness/cortextos/package-lock.json:415:      "integrity": "sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==",
packages/harness/cortextos/package-lock.json:1401:      "integrity": "sha512-RAjXjP/8c6ZtzatZcA1RaQr6O1TRhzC+adn8YZDnChliZHviqIjmvFwHcxi4JKPSDAt6Uhf/7vqcBzQJy0PDJg==",
packages/harness/cortextos/package-lock.json:1818:      "integrity": "sha512-aCj4O5wKyszjMmDT4tZj93kxyydN/K5zPWSCe6/0AV/AA1pqe5ZBIw0a2ZfPQV7lL5/yb5HsUreJ6UFAF1tEQw==",
packages/harness/cortextos/package-lock.json:2065:      "integrity": "sha512-7tN6rFgBlMgpBML5j8typ92BKFi2sFQvIdpAqLA2beia5avZDrMs0FLZiM5etShWq5irVyGcGMEA1jcDaK7A/Q==",
packages/harness/cortextos/package-lock.json:2885:      "integrity": "sha512-bzyZ1e88w9O1iNJbKnOlvYTrWPDl46O1bG0D3XInv+9tkPrxrN8jUUTiFlDkkmKWgn1M6CfIA13SuGqOa9Korw==",
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:6:**Artefact:** `agents/recruitment/diagnostic/agent.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:8:- Round 4: `logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:9:- Round 5: `logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md`
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:15:Week 3 goal at `docs/operations/goal-week-3-polish-and-scaffold.md` Step 7 (Codex Round 4 Phase 1) ratified `agents/recruitment/diagnostic/agent.md`. Codex found 4 issues; mechanical remediation applied (commit `6e0cb86`); Round 5 re-ratification found 5 new issues — 2 re-raises (Codex disagreed with my remediation framing), 3 new findings not visible at Round 4.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:25:**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:33:Option B — **Amend Ultraplan §8.1 A1 line 497** to read "no unsupported claims at section level" (loosens upstream to match v0 implementation).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:41:**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:49:**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:51:**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:57:Option B — **Add a new kill-criterion Trigger 11 (DIAGNOSTIC-CONVERSION-FAIL).** Threshold: <30% discovery-call rate sustained for 4 weeks across all live pilots. Owner: founder + Jack.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:59:**My recommendation:** **A** for v0 — remove the trigger reference; Diagnostic conversion is local-metric tracking. Add Trigger 11 in v1.1 if conversion-rate-driven scope-cut becomes operationally relevant.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:91:3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
agents/recruitment/cash-conductor/README.md:21:- `context.sh` — multi-provider auth refresh + voice corpus + 90-day token monitor
agents/recruitment/cash-conductor/README.md:22:- `validate.sh` — Gate A (invoice + amount + contact triple check + paid-in-24h block per ULTRAPLAN A4 line 539)
agents/recruitment/cash-conductor/README.md:27:- `fixtures/99-chase-paid-canary.yaml` — adversarial: chase proposed for invoice paid 12h ago — Gate A must reject (per ULTRAPLAN A4 line 539 verbatim)
agents/recruitment/cash-conductor/README.md:31:Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
agents/recruitment/cash-conductor/README.md:32:- Open Banking MCP connector + ESC_OPEN_BANKING_TOKEN_AGING UX
packages/harness/cortextos/dashboard/src/app/globals.css:172:  --foreground: oklch(0.187 0 0);                /* #1A1A1A */
packages/harness/cortextos/dashboard/src/app/globals.css:222:  --secondary: oklch(0.187 0 0);                 /* #1A1A1A */
packages/harness/cortextos/dashboard/src/app/globals.css:224:  --muted: oklch(0.187 0 0);                    /* #1A1A1A */
packages/harness/cortextos/community/catalog.json:222:      "name": "system-diagnostics",
packages/harness/cortextos/community/catalog.json:227:      "tags": ["diagnostics", "debug", "troubleshooting", "health"],
packages/harness/cortextos/community/catalog.json:230:      "install_path": "community/skills/system-diagnostics",
agents/recruitment/cash-conductor/agent.md:6:**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
agents/recruitment/cash-conductor/agent.md:9:**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
agents/recruitment/cash-conductor/agent.md:17:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) consultant-approved orange-tier payment-chase email drafts queued to Concierge for send (Concierge handles the actual send; Cash Conductor only drafts), and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO Bullhorn dependency — Cash Conductor operates entirely against the tenant's accounting + Open Banking stack, making it the most-independent v1.0 agent (per ADR-005 §5.1: this independence is its strategic value when Bullhorn paths are delayed). Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 539). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 539 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 540) — the FD-tier closer metric. Chase drafts are orange-tier per `autosend-safety-policy.yaml` (consultant approval required before send via Concierge); reconciliation writes are yellow-tier.
agents/recruitment/cash-conductor/agent.md:31:# - Xero/QuickBooks/Sage: invoice.created, invoice.sent, invoice.viewed,
agents/recruitment/cash-conductor/agent.md:32:#   invoice.paid, payment.received
agents/recruitment/cash-conductor/agent.md:41:# 07:00 UTC daily — bank feed catch-up + invoice age scan
agents/recruitment/cash-conductor/agent.md:55:ifosctl cash-conductor reconcile --tenant <slug> [--invoice <id>]
agents/recruitment/cash-conductor/agent.md:56:ifosctl cash-conductor draft-chase --tenant <slug> --invoice <id>
agents/recruitment/cash-conductor/agent.md:74:Per webhook event, Cash Conductor reconciles incoming bank deposits against the tenant's open invoice register. Match algorithm:
agents/recruitment/cash-conductor/agent.md:78:| 1 | Exact amount + matching invoice reference in transaction memo | 0.98 |
agents/recruitment/cash-conductor/agent.md:80:| 3 | Exact amount + within-90-day-of-invoice-issue window | 0.70 |
agents/recruitment/cash-conductor/agent.md:90:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. Output is a queued draft, NOT a send. Drafts route to Concierge (which handles the actual send pipeline + consultant approval per autosend §4 orange tier).
agents/recruitment/cash-conductor/agent.md:96:invoice_id: <accounting-system-invoice-id>
agents/recruitment/cash-conductor/agent.md:98:subject: "Friendly reminder — invoice <number> from <YYYY-MM-DD>"
agents/recruitment/cash-conductor/agent.md:99:body_markdown: <voice-classified consultant-tone reminder>
agents/recruitment/cash-conductor/agent.md:126:| 1 | **Week summary** | Receipts received + invoices issued + invoices paid + new chases sent |
agents/recruitment/cash-conductor/agent.md:128:| 3 | **Aged debtors** | Invoices outstanding bucketed (0-30 / 31-60 / 61-90 / 90+ days); per-client totals |
agents/recruitment/cash-conductor/agent.md:130:| 5 | **Cash-flow forecast** | 4-week forward cash projection (open invoices + expected payments per historical conversion rate) |
agents/recruitment/cash-conductor/agent.md:142:     Open Banking auth + voice corpus + tone rules
agents/recruitment/cash-conductor/agent.md:149:     fire ESC_OPEN_BANKING_TOKEN_AGING (operator must re-authorise)
agents/recruitment/cash-conductor/agent.md:150:   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on failure
agents/recruitment/cash-conductor/agent.md:163:4. Invoice register ingest (mode=webhook from accounting OR daily-sweep)
agents/recruitment/cash-conductor/agent.md:164:   → accounting.list_open_invoices() per provider
agents/recruitment/cash-conductor/agent.md:165:   → store in /vault/<tenant>/cash-conductor-cache/invoices.jsonl
agents/recruitment/cash-conductor/agent.md:168:   → for each transaction × open invoice: compute match confidence
agents/recruitment/cash-conductor/agent.md:174:   → accounting.write_payment_received(invoice_id, payment_id, amount, date)
agents/recruitment/cash-conductor/agent.md:176:   → ESC_ACCOUNTING_WRITE_FAIL on failure
agents/recruitment/cash-conductor/agent.md:179:7. Chase generation pass (for overdue, unmatched invoices)
agents/recruitment/cash-conductor/agent.md:180:   → query open invoices with age >7 days AND no Stage-1/2 reconciliation
agents/recruitment/cash-conductor/agent.md:186:8. LLM chase-draft generation (per overdue invoice)
agents/recruitment/cash-conductor/agent.md:187:   → prompt = (invoice details + client context + position-N tone +
agents/recruitment/cash-conductor/agent.md:188:     voice corpus + tone rules)
agents/recruitment/cash-conductor/agent.md:190:   → voice classifier scores against tenant style (≥0.75 for position 1-2;
agents/recruitment/cash-conductor/agent.md:192:   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
agents/recruitment/cash-conductor/agent.md:195:   → verify: invoice_number cited matches invoice_id
agents/recruitment/cash-conductor/agent.md:199:   → ESC_SCHEMA_VIOLATION on any miss
agents/recruitment/cash-conductor/agent.md:200:   → ESC_AUTOSEND_BLOCKED if chase proposed for paid invoice (defence-in-depth)
agents/recruitment/cash-conductor/agent.md:206:    → hh_decision_output("chase_draft", invoice_id, payload_preview);
agents/recruitment/cash-conductor/agent.md:218:    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)
agents/recruitment/cash-conductor/agent.md:242:- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
agents/recruitment/cash-conductor/agent.md:243:- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
agents/recruitment/cash-conductor/agent.md:250:Gate A failures fire `ESC_SCHEMA_VIOLATION` or `ESC_AUTOSEND_BLOCKED`; draft stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/cash-conductor/agent.md:260:This is THE FD-tier closer metric per master brief §8.2 line 597. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
agents/recruitment/cash-conductor/agent.md:270:| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:271:| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:272:| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:273:| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking token <30 days from 90-day expiry | warn (info if <60 days; warn if <30; blocking if <7) | operator_chat_id → ifos_oncall as expiry nears |
agents/recruitment/cash-conductor/agent.md:274:| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 3-4 match queued for review | info | (logged; aggregated to weekly report exception list) |
agents/recruitment/cash-conductor/agent.md:275:| `ESC_AUTOSEND_BLOCKED` | Chase proposed for paid invoice OR race condition detected | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:276:| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:277:| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:278:| `ESC_VOICE_DRIFT_TENANT` | Consultant edit-rate on chase drafts >50% in 30-day window | warn | operator + tenant-admin |
agents/recruitment/cash-conductor/agent.md:279:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:280:| `ESC_SCHEMA_VIOLATION` | Gate A miss (invoice/amount/contact validation) | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:281:| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
agents/recruitment/cash-conductor/agent.md:282:| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:283:| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval >24h | info | (logged; weekly report) |
agents/recruitment/cash-conductor/agent.md:291:Step 8 (chase-draft generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/cash-conductor/agent.md:297:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:298:- **`hh_load_recent_edits` last 30 days for `cash_conductor` agent**: detects consultant edit patterns. Edit-distance >150 chars on >40% of chase recent_edits fires `ESC_VOICE_DRIFT_TENANT`.
agents/recruitment/cash-conductor/agent.md:300:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/cash-conductor/agent.md:343:| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
agents/recruitment/cash-conductor/agent.md:347:| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
agents/recruitment/cash-conductor/agent.md:352:1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
agents/recruitment/cash-conductor/agent.md:353:2. **Bank feed reconciliation against invoice register is the hard logic.** Start with exact-amount matches (Stage 1-2); expand to fuzzy (Stage 3-4) as confidence builds.
agents/recruitment/cash-conductor/agent.md:355:4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
agents/recruitment/cash-conductor/agent.md:372:- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
packages/diagnostic-generator/src/sections/stubs.ts:3:// Each renders with a Companies House anchor as fallback citation so
packages/diagnostic-generator/src/sections/stubs.ts:10:    return `[Companies House profile](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber})`;
packages/diagnostic-generator/src/sections/stubs.ts:12:  return `[Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)})`;
packages/diagnostic-generator/src/sections/stubs.ts:21:      : "No operator-provided sector hint. SIC codes from Companies House are the only sector signal available without LinkedIn job-post data.",
packages/diagnostic-generator/src/sections/stubs.ts:23:      ? `Companies House SIC codes: ${firmSignal.sicCodes.join(", ")} — these are self-declared at registration and may not reflect current focus.`
packages/diagnostic-generator/src/sections/stubs.ts:26:    "**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.",
packages/diagnostic-generator/src/sections/stubs.ts:38:      : `Registered office address not visible at Companies House for ${firmName}.`,
packages/diagnostic-generator/src/sections/stubs.ts:40:    "**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:55:      : `Firm-age signal unavailable without Companies House incorporation date.`,
packages/diagnostic-generator/src/sections/stubs.ts:57:    "**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:67:    "**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:69:    "Companies House SIC codes give a coarse industry signal but no specific technology stack visibility.",
packages/diagnostic-generator/src/sections/stubs.ts:79:    "**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.",
packages/diagnostic-generator/src/sections/stubs.ts:81:    "Companies House does not surface competitor data at the firm level.",
packages/diagnostic-generator/src/sections/stubs.ts:90:    lines.push("Directors on file at Companies House (proxy for decision-makers until LinkedIn employee search is wired):");
packages/diagnostic-generator/src/sections/stubs.ts:100:      "**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/stubs.ts:103:    lines.push("No directors on file at Companies House (firm may be dissolved or unregistered).");
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:58:**Cost of delay:** Trigger 1 fires 2026-06-03 if no LOI. If LOI lands but advisor isn't engaged, founder has to choose between violating kill-criterion §3.4 or delaying LOI past Trigger 1. Engage now to avoid the forced choice.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:80:**Cost of delay:** Same as D2 — Trigger 1 fires 2026-06-03. If LOI lands before D3 resolves, founder ships v1.0 with D3-A indefinite retention, which is the worst legal posture. Bundle D2 + D3 resolution.
docs/_archive-build-pack/01-RECOMMENDATION.md:56:cortextOS in `packages/harness/cortextos/` is **vendored** — a copy of the upstream at a pinned SHA recorded in `packages/harness/.upstream-version`. Pulling upstream changes is a deliberate, batched operation; in between, you alter freely without merge pain. Codex gets a single, frozen surface to reason about.
docs/_archive-build-pack/01-RECOMMENDATION.md:135:├─ packages/harness/cortextos/dist/daemon.js     (cortextOS daemon)
docs/_archive-build-pack/01-RECOMMENDATION.md:182:- [ ] cortextOS is vendored into `packages/harness/cortextos/`, pinned by SHA, not forked
packages/utilities/web-scraper/pnpm-lock.yaml:388:    resolution: {integrity: sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==}
packages/utilities/web-scraper/pnpm-lock.yaml:575:    resolution: {integrity: sha512-FJHFfqpKUI3A10WrWKiFbBZ7yVbGT4q4B5o1qKFFojqpaYoh9LrQgqWCmmcxQzVSXYtyB5bzkXrYzlHTs21MYA==}
packages/utilities/web-scraper/pnpm-lock.yaml:630:    resolution: {integrity: sha512-QVTUovf40zgTqlFVrKA1uXMVvU2QWEFWfAH8Wdc48IxLvrJMQVMBRjuQyUpzZCDkakImib9eVazbWlC6ksWtJw==}
packages/utilities/web-scraper/pnpm-lock.yaml:818:    resolution: {integrity: sha512-//nshmD55c46FuFw26xV/xFAaB5HF9Xdap7HJBBnrKdAd6/GxDBaNA1870O79+9ueg61cZLSVc+OaFlfmObYVQ==}
packages/utilities/web-scraper/pnpm-lock.yaml:973:    resolution: {integrity: sha512-o5a9xKjbtuhY6Bi5S3+HvbRERmouabWbyUcpXXUA1u+GNUKoROi9byOJ8M0nHbHYHkYICiMlqxkg1KkYmm25Sw==}
docs/_archive-build-pack/06-BUILD-PLAN.md:35:- Copy `/Users/madsadmin/code/cortex-os-upstream/` → `packages/harness/cortextos/`
docs/_archive-build-pack/06-BUILD-PLAN.md:38:- Run `npm install && npm run build` inside `packages/harness/cortextos/` to produce `dist/`
docs/_archive-build-pack/06-BUILD-PLAN.md:39:- Add `packages/harness/cortextos` to root `.gitignore` for `node_modules/`
docs/_archive-build-pack/06-BUILD-PLAN.md:110:- Symlink (or copy) into `packages/harness/cortextos/bus/` overriding the upstream files
docs/_archive-build-pack/06-BUILD-PLAN.md:111:- Test: run `bash packages/harness/cortextos/bus/kb-query.sh "carry-over policy"` and get a valid response
docs/_archive-build-pack/06-BUILD-PLAN.md:222:- Adapt steps for v2: tool connections, voice profile capture, agent selection (which of the 11 to enable), Telegram bot creation, first ingest
packages/harness/cortextos/dashboard/src/lib/db.ts:205:/** Get row counts for all tables (useful for diagnostics) */
packages/diagnostic-generator/src/sections/conversation-opener.ts:4:// context + tenant voice corpus (when wired via voice-loader.sh) + tone
packages/diagnostic-generator/src/sections/conversation-opener.ts:26:  voiceCorpusSamples?: string[];
packages/diagnostic-generator/src/sections/conversation-opener.ts:94:      opener: `Hi — saw the ${filing.description.toLowerCase()} on ${filing.date} at Companies House. Usually that's a signal of either fresh investment or a hiring push. We work with ${sectorHint || "UK recruitment"} firms in that exact transition; happy to share what we've seen work for similar-size operators.`,
packages/diagnostic-generator/src/sections/conversation-opener.ts:95:      evidenceLink: `[Source: Companies House filing on ${filing.date}](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber}/filing-history)`,
packages/diagnostic-generator/src/sections/conversation-opener.ts:105:      opener: `Hi ${cleanName.split(" ")[0]} — ${firmName} has been at Companies House for ${ageYears ?? "several"} years and is still actively trading. We work with established UK ${sectorHint || "recruitment"} firms on the operational side — the day-30 cleanup-and-attribution work that compounds across placements. Worth a short call?`,
packages/diagnostic-generator/src/sections/conversation-opener.ts:106:      evidenceLink: `[Source: Companies House profile](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber})`,
packages/diagnostic-generator/src/sections/conversation-opener.ts:112:    evidenceLink: `[Source: Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)})`,
packages/diagnostic-generator/src/sections/conversation-opener.ts:128:  const voiceContext = (input.voiceCorpusSamples ?? []).slice(0, 5).join("\n---\n");
packages/diagnostic-generator/src/sections/conversation-opener.ts:134:  const systemPrompt = `You are writing the §12 "Conversation opener" section of a UK recruitment-firm diagnostic report. Output: a 2-3 sentence cold outreach opener written in the consultant's voice. Must be evidence-anchored to a specific signal from the report's §1-§11 evidence (Companies House data, careers-page quotes, LinkedIn signals, recent filings). NOT generic.
packages/diagnostic-generator/src/sections/conversation-opener.ts:144:${voiceContext ? `Voice corpus exemplars (write in this style):\n${voiceContext}\n\n` : ""}${toneRulesText ? `Tone rules to respect:\n${toneRulesText}\n\n` : ""}`;
packages/diagnostic-generator/src/sections/conversation-opener.ts:188:    lines.push(`- Companies House: ${firmName} (CRN ${firmSignal.companyNumber}, ${firmSignal.status ?? "active"}, incorporated ${firmSignal.incorporationDate ?? "date unknown"})`);
packages/diagnostic-generator/src/sections/conversation-opener.ts:199:    lines.push(`- Companies House: no UK registration found for "${firmName}"`);
agents/recruitment/scribe/README.md:16:- `tools.yaml` — Bullhorn W + Fathom R + Fireflies R + voice classifier
agents/recruitment/scribe/README.md:17:- `context.sh` — webhook handler + Bullhorn auth refresh + voice corpus
agents/recruitment/scribe/README.md:18:- `validate.sh` — Gate A (≥3 fields × confidence ≥0.6 + voice ≥0.75 + PII boundary)
docs/decisions/brain-ui-scope.md:17:- **v1.0 minimum (weeks 11-13):** wiki API + Postgres tables (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector voice samples + 9 `wiki-*.sh` parallel wrappers + 9 `wiki/lib/*.ts` modules. **No Brain UI** — operational access via Obsidian + CLI + psql.
docs/decisions/brain-ui-scope.md:20:- **v2.0:** second-brain-at-scale features (reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views per master brief §5.5).
docs/decisions/brain-ui-scope.md:43:- Highlights `ESC_*` escalations across all agents — `ESC_BULLHORN_AUTH`, `ESC_VOICE_DRIFT`, `ESC_DUPLICATE_DETECTED`, `ESC_RENDERER_FAILED`, etc.
docs/decisions/brain-ui-scope.md:102:Add `/brain/*` routes to the existing cortextOS Next.js 14 dashboard at `packages/harness/cortextos/dashboard/`. Master brief §5.3 lines 380-403 already names this pattern: "**same Next.js app, additional routes in a sibling folder**, mounted via the dashboard's `dashboard-ext` integration point" at `packages/dashboard-ext/src/app/(dashboard)/brain/`.
docs/decisions/brain-ui-scope.md:105:- Tight coupling to cortextOS submodule (`packages/harness/cortextos/dashboard/`) — submodule boundary per master brief §3.1 must hold; the `dashboard-ext` integration point is the cortextOS-blessed extension surface, not a fork.
docs/decisions/brain-ui-scope.md:176:> "- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation."
docs/decisions/brain-ui-scope.md:217:| Real-time vs polling for today view refresh (default polling 30-60s) | v1.1 planning — based on observed v1.0 escalation frequency; if `ESC_*` rate is high, real-time may matter |
packages/diagnostic-generator/src/sections/icp-fit.ts:77:    "**v0 limitation:** geography + deal_size_band scoring requires LinkedIn job-post data. Wire Proxycurl (W4 polish).",
packages/diagnostic-generator/src/sections/icp-fit.ts:84:  lines.push(`Source: [Companies House profile](${chUrl}) + tenant target_patch.json`);
docs/_archive-build-pack/02-PRODUCT-VISION.md:100:> Most AI tools also can't be trusted. Intel Force OS escalates when it's uncertain — when policy is unclear, data is weak, or output might embarrass you. Sensitive HR matters never get AI-drafted. The four-objection rule applies to every output: nothing sends without you. UK-hosted, GDPR-ready, built on Claude. Your operations, in your voice, at your standard.
docs/_archive-build-pack/02-PRODUCT-VISION.md:116:- **Brand voice** — direct, specific, honest about limits, quiet confidence, British English
agents/recruitment/scribe/agent.md:6:**Build wave:** v1.0 W6 per master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 line 517 (ULTRAPLAN says week 6-7; master brief says week 6; master brief authoritative).
agents/recruitment/scribe/agent.md:16:> **Scribe ingests a call transcript from Fathom / Fireflies / Ringover (webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown attachment containing the consultant's "things I'd write down but there's no field for" observations. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:109:Length cap: 800 words. Voice-classified (≥0.75); falls back to "needs consultant review" placeholder if classifier persistently fails (ESC_VOICE_DRIFT).
agents/recruitment/scribe/agent.md:131:   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice
agents/recruitment/scribe/agent.md:132:     corpus (for tacit-note voice) + tone rules + recent_edits (drift)
agents/recruitment/scribe/agent.md:137:   → ESC_SCHEMA_VIOLATION on signature mismatch; reject with 401
agents/recruitment/scribe/agent.md:142:   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
agents/recruitment/scribe/agent.md:146:   → ESC_PROVIDER_FETCH_FAIL on 4xx/5xx; retry once 30s backoff
agents/recruitment/scribe/agent.md:148:   → ESC_PII_LEAKAGE_RISK if transcript references non-tenant PII
agents/recruitment/scribe/agent.md:155:   → ESC_SCHEMA_VIOLATION if no resolvable entity (e.g., unknown phone number)
agents/recruitment/scribe/agent.md:159:     + 3 voice-corpus examples)
agents/recruitment/scribe/agent.md:162:   → require ≥3 fields with confidence ≥0.6 OR fire ESC_FIELD_EXTRACTION_LOW_CONFIDENCE
agents/recruitment/scribe/agent.md:165:   → prompt = (transcript + 8-category taxonomy + 3 voice-corpus examples
agents/recruitment/scribe/agent.md:168:   → voice classifier scores against tenant style guide
agents/recruitment/scribe/agent.md:169:   → ESC_VOICE_DRIFT if score <0.75 after 3 retries
agents/recruitment/scribe/agent.md:174:   → drop invalid; require ≥3 valid (per Gate A; failure = ESC_SCHEMA_VIOLATION)
agents/recruitment/scribe/agent.md:179:   → ESC_BULLHORN_WRITE_FAIL on failure; do NOT proceed to Step 9
agents/recruitment/scribe/agent.md:186:     reversing the field changes); ESC_BULLHORN_WRITE_FAIL
agents/recruitment/scribe/agent.md:190:   → if elapsed > 600 (10 min): warn ESC_SCRIBE_SLA_MISS (not blocking)
agents/recruitment/scribe/agent.md:206:- 1 tacit-note generated with voice classifier ≥0.75
agents/recruitment/scribe/agent.md:212:Gate A failures fire `ESC_SCHEMA_VIOLATION` or `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`; transcript stays in `/tmp` (auto-purged 24h); operator notified.
agents/recruitment/scribe/agent.md:224:Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → operator + ifos_oncall (likely indicates LLM prompt drift or taxonomy mismatch).
agents/recruitment/scribe/agent.md:234:| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:235:| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on field write OR note attach | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:236:| `ESC_PROVIDER_FETCH_FAIL` | Fathom/Fireflies/Ringover transcript fetch fails | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:237:| `ESC_VOICE_DRIFT` | Tacit-note voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:238:| `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE` | <3 fields with confidence ≥0.6 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:239:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in transcript or note | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:240:| `ESC_SCHEMA_VIOLATION` | Webhook signature fail OR vertical-schema validation fail | **blocking** | operator + ifos_oncall |
agents/recruitment/scribe/agent.md:241:| `ESC_SCRIBE_SLA_MISS` | Webhook-to-Bullhorn-write >10 min (Gate B miss) | info | (logged; aggregated to Gate B metric) |
agents/recruitment/scribe/agent.md:242:| `ESC_RATE_LIMIT_HIT` | Bullhorn or provider 429 | warn | operator_chat_id |
agents/recruitment/scribe/agent.md:243:| `ESC_AUTOSEND_YELLOW_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
agents/recruitment/scribe/agent.md:247:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Scribe writes are yellow
agents/recruitment/scribe/agent.md:248:- `ESC_BULLHORN_OAUTH_REVOKED` — escalated from `ESC_BULLHORN_AUTH` only after 6 consecutive auth failures (Concierge handles)
agents/recruitment/scribe/agent.md:254:Step 6 (tacit-note generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/scribe/agent.md:260:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal call summary note" task context.
agents/recruitment/scribe/agent.md:261:- **`hh_load_recent_edits` last 30 days for `scribe` agent**: detects consultant edit patterns. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT` (separate from per-run drift).
agents/recruitment/scribe/agent.md:263:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/scribe/agent.md:289:| LLM extraction + voice-classifier microservice | W4-5 polish | ⏸ |
agents/recruitment/scribe/agent.md:304:| Q2 | Per-call cost ceiling — LLM extraction + voice classification per call. Budget per pilot tenant? | Cost model: ~$0.10-0.30 per call (Claude API + voice classifier). At 50 calls/day per consultant × 5 consultants per tenant = ~$25-75/day per tenant. |
agents/recruitment/scribe/agent.md:309:| Q7 | What happens when transcript references PII outside tenant's Bullhorn data (e.g., consultant mentions a candidate's spouse's medical condition)? | ESC_PII_LEAKAGE_RISK; transcript NOT written to tacit-note; operator review. Document tenant policy. |
agents/recruitment/scribe/agent.md:331:- SLA + edit-rate Gate-B metrics measurable
docs/_archive-build-pack/README.md:33:Don't modify cortextOS upstream. Don't modify v1 in place. Build v2 fresh at `/Users/madsadmin/code/CortexOS/`. Vendor cortextOS into `packages/harness/cortextos/` with a `.upstream-version` SHA pin. Build `packages/brain/` that ships drop-in replacements for `bus/kb-*.sh` (same interface, graph+wiki backend). Lift v1's dashboard chrome, agent catalogue, governance model, and brand context as **concepts** into clean packages — never `cp -r`. Keep v1 unmodified until v2 reaches feature parity; then mechanical cutover. Full case in `01-RECOMMENDATION.md`.
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-approval-bridge-spec.md:20:- 4h timeout converts to `ESC_AUTOSEND_NEEDS_REVIEW`
docs/decisions/autosend-approval-bridge-spec.md:30:`packages/harness/cortextos/src/bus/approval.ts` already implements the Telegram approval flow:
docs/decisions/autosend-approval-bridge-spec.md:62:The Telegram bot itself is `packages/harness/cortextos/src/telegram/*` — also shipped + tested. Inline-button presses → `updateApproval(approvalId, 'approved'|'denied')` is wired end-to-end per `src/bus/approval.ts:178-229` + `src/daemon/agent-manager.ts` activity-channel poller.
docs/decisions/autosend-approval-bridge-spec.md:132:cortextOS Primitive 4 enumerates approval categories as `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` per `packages/harness/cortextos/src/types/index.ts`. IFOS action_types from `agents/_shared/autosend-policy.yaml` map as follows:
docs/decisions/autosend-approval-bridge-spec.md:142:| `diagnostic_email_send` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:143:| `diagnostic_calendar_invite` | `external-comms` |
docs/decisions/autosend-approval-bridge-spec.md:173:1. IFOS-side: poll loop exits → `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` → agent gives up
docs/decisions/autosend-approval-bridge-spec.md:182:| cortextOS approval system down (createApproval throws) | Write `<hash>.bridge-error` marker; IFOS poll-loop times out at 4h; ESC_AUTOSEND_NEEDS_REVIEW fires with `reason='bridge_unavailable'` |
docs/decisions/autosend-approval-bridge-spec.md:239:| A1 | Bridge process starts via PM2 + connects to Postgres + reads bridge state | `pm2 status ifos-autosend-bridge` shows online; bridge starts fresh on empty DB |
docs/decisions/autosend-approval-bridge-spec.md:248:| A10 | Live VPS smoke: real Telegram chat receives approval message + button press routes back to marker | Founder Path A manual test on migration-test tenant |
packages/harness/cortextos/src/daemon/fast-checker.ts:349:   * Format a Telegram voice/audio message for injection.
packages/harness/cortextos/dashboard/src/lib/data/organization.ts:2:// Reads context.json and brand-voice.md from the framework root org directory.
packages/harness/cortextos/dashboard/src/lib/data/organization.ts:47: * Read brand-voice.md for an org. Returns empty string if missing.
packages/harness/cortextos/dashboard/package-lock.json:905:      "integrity": "sha512-hFoiJiTl63nn+kstHGBtewWSKnQLpyb155KHheA1l39uvtO9nWIop1p3udqPcUd/xbF1VLMO4n7OI6p7RbngDg==",
packages/harness/cortextos/dashboard/package-lock.json:1503:      "integrity": "sha512-+LpyBk7L44ZIXwz/VYfglaX/okxezESc6UxDSoyo2Ks6Jxc4Y7sGjpgU9s4PMgqgjj1gZCylTieNamqA1MF7Dg==",
packages/harness/cortextos/dashboard/package-lock.json:3987:      "integrity": "sha512-gPVA1UjRu1Y/IsB/dQEsp2V1pm44Of6+LWvbLc9SDk1c2KhhDRDBUkQCYVWe6f26uJb3fOK8saWMgtX8IrMk3g==",
packages/harness/cortextos/dashboard/package-lock.json:4043:      "integrity": "sha512-cINaoY2z7LVCrfHkIcmvj7osTOtm6VVT16b5oQdS4beibX2SYBwgYLmqhBjA1t51CarSaBuX5YNsWLjsqfW5Cw==",
packages/harness/cortextos/dashboard/package-lock.json:4927:      "integrity": "sha512-zRpUiDwd/xk6ADqPMATG8vc9VPrkck7T07OIx0gnjmJAnHnTVXNQG3vfvWNuiZIkwu9KrKdA1iJKfsfTVxE6NA==",
packages/harness/cortextos/dashboard/package-lock.json:5094:      "integrity": "sha512-aCj4O5wKyszjMmDT4tZj93kxyydN/K5zPWSCe6/0AV/AA1pqe5ZBIw0a2ZfPQV7lL5/yb5HsUreJ6UFAF1tEQw==",
packages/harness/cortextos/dashboard/package-lock.json:5408:      "integrity": "sha512-tdQAmyA18i4J7wprpYq8ClcxZy3SC31QMeByyCFyRt7BVHdREQZ5lpzoe5mFEYZUWe+oq8HBvk9JjpibyEV4Jg==",
packages/harness/cortextos/dashboard/package-lock.json:6056:      "integrity": "sha512-zWwRvqWiuBPr0muUG/78cW3aHROFCNIQ3zpmYDpwdbnt2m+xlNyRWpHBpa2lJjSBit7BQ+RXA1iwbSmu5yJ/EQ==",
packages/harness/cortextos/dashboard/package-lock.json:6249:      "integrity": "sha512-qhabwjQZ1Mk53XzXvmogf8KQ0tG0CQXF0CZ56+2/lVhmObgmaqj7x5A1DSrWdZd3kwI7GTPGUjFne+krRxYmFg==",
packages/harness/cortextos/dashboard/package-lock.json:6311:      "integrity": "sha512-A1rHYb06zjMGAxdLSkN2fXPBwuSaQ0iO5M/hdyS0Ajj1VBaRp0sPD3dn1FhME3c/JluGFbwSxyCfqdSbtQLAHQ==",
packages/harness/cortextos/dashboard/package-lock.json:7221:      "integrity": "sha512-7tN6rFgBlMgpBML5j8typ92BKFi2sFQvIdpAqLA2beia5avZDrMs0FLZiM5etShWq5irVyGcGMEA1jcDaK7A/Q==",
packages/harness/cortextos/dashboard/package-lock.json:7836:      "integrity": "sha512-upqt1SkGkODW9tsGNG5mtXTXtECizwtS2kA161M+gJPc1xdb/Ax629af6YrTwcOeQHbewrPNlE5Dx7kzvXTizA==",
packages/harness/cortextos/dashboard/package-lock.json:7992:      "integrity": "sha512-bCYeRA2rVibKZd+s2625gGnGF/t7DSqDs4dP7CrLA1m7jKWz6pps0LpYLJN8Q64HtmPKJ1hrN3nzPNKFEKOUiQ==",
packages/harness/cortextos/dashboard/package-lock.json:9210:      "integrity": "sha512-OWND8ei3VtNC9h7V60qff3SVobHr996CTwgxubgyQYEpg290h9J0buyECNNJexkFm5sOajh5G116RYA1c8ZMSw==",
packages/harness/cortextos/dashboard/package-lock.json:9979:      "integrity": "sha512-orRsuYpJVw8LdAwqqLykBj9ecS5/cRHlI5+nvTo8LcCKmzDmqVORXtOIYEEQuL9D4BxtA1lm5isAqzQZCoQ6Eg==",
packages/harness/cortextos/dashboard/package-lock.json:10023:      "integrity": "sha512-8Mf2cbV7x1cXPUILADGI3wuhfqWvtiLA1iclTDbFRZkgRQS0NqsPZphna9V+HyTEadheuPmjaJMsbzKQFOzLug==",
packages/harness/cortextos/dashboard/package-lock.json:10531:      "integrity": "sha512-pb/MYmXstAkysRFx8piNI1tGFNQIFA3vkE3Gq4EuA1dF6gHp/+vgZqsCGJapvy8N3Q+4o7FwvquPJcnZ7RYy4g==",
packages/harness/cortextos/dashboard/package-lock.json:11139:      "integrity": "sha512-bzyZ1e88w9O1iNJbKnOlvYTrWPDl46O1bG0D3XInv+9tkPrxrN8jUUTiFlDkkmKWgn1M6CfIA13SuGqOa9Korw==",
packages/harness/cortextos/dashboard/package-lock.json:11459:      "integrity": "sha512-vavAMRXOgBVNF6nyEEmL3DBK19iRpDcoIwW+swQ+CbGiu7lju6t+JklA1MHweoWtadgt4ISVUsXLyDq34ddcwA==",
docs/_archive-build-pack/03-ARCHITECTURE.md:131:│   │   │   ├── boot.ts                (loads packages/harness/cortextos and starts)
docs/_archive-build-pack/03-ARCHITECTURE.md:158:`packages/harness/cortextos/` is a literal copy of cortex-os-upstream at a pinned SHA. `packages/harness/.upstream-version` records:
docs/_archive-build-pack/03-ARCHITECTURE.md:169:2. Diff `/tmp/cortextos` against `packages/harness/cortextos/`
docs/_archive-build-pack/03-ARCHITECTURE.md:179:cortextOS agents call `bus/kb-query.sh` etc. After vendoring, our build replaces those files in `packages/harness/cortextos/bus/` with wrappers that delegate to `packages/brain/cli/`. Diff:
docs/_archive-build-pack/03-ARCHITECTURE.md:325:├── voice/
docs/_archive-build-pack/03-ARCHITECTURE.md:326:│   └── voice-profile.md
agents/recruitment/sourcing-scout/README.md:16:- `tools.yaml` — Bullhorn R + Proxycurl + Reed + CV-Library + source-abstraction layer
agents/recruitment/sourcing-scout/README.md:17:- `context.sh` — multi-source auth refresh + voice corpus + DNC list load
agents/recruitment/sourcing-scout/README.md:18:- `validate.sh` — Gate A (5-15 candidates + contact method + ≥50 words + DNC + voice ≥0.75)
agents/recruitment/sourcing-scout/agent.md:3:**Status:** Proposed (Day-19 pre-W9-build scaffold; awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice).
agents/recruitment/sourcing-scout/agent.md:6:**Build wave:** v1.0 W9 per master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 line 545 (master brief says W9; ULTRAPLAN says W8-9; master brief authoritative).
agents/recruitment/sourcing-scout/agent.md:16:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button, Telegram command (`@ifos_bot scout <brief-id>`), OR webhook from a "new brief" event in Bullhorn (per ULTRAPLAN A5 line 547). Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate flagged "do not contact" in tenant vault (per ULTRAPLAN A5 line 553 verbatim). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 554 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:59:**Sources searched:** Bullhorn ATS + LinkedIn (Proxycurl) + Reed + CV-Library
agents/recruitment/sourcing-scout/agent.md:86:| LinkedIn (Proxycurl) | <N> | <score> | <remaining> |
agents/recruitment/sourcing-scout/agent.md:98:Voice-classified content: only the per-candidate match rationale (Step 9). Voice classifier ≥0.75 against tenant style. Rationale that fails after 3 retries → ESC_VOICE_DRIFT → candidate dropped from list + flagged in exception list.
agents/recruitment/sourcing-scout/agent.md:108:   → context.sh hydrates: tenant config + multi-source auth + voice corpus
agents/recruitment/sourcing-scout/agent.md:116:   → ESC_BRIEF_UNDERSPECIFIED if extraction yields <3 key dimensions
agents/recruitment/sourcing-scout/agent.md:119:   → bullhorn (read-only); LinkedIn/Proxycurl; Reed; CV-Library
agents/recruitment/sourcing-scout/agent.md:120:   → per-source ESC_<SOURCE>_AUTH on refresh failure
agents/recruitment/sourcing-scout/agent.md:121:   → if 2+ sources fail auth: ESC_SCHEMA_VIOLATION (abort early; insufficient
agents/recruitment/sourcing-scout/agent.md:127:   → ESC_RATE_LIMIT_HIT on 429
agents/recruitment/sourcing-scout/agent.md:129:4. LinkedIn search (via Proxycurl)
agents/recruitment/sourcing-scout/agent.md:134:   → ESC_LINKEDIN_RATE_LIMIT on Proxycurl quota hit
agents/recruitment/sourcing-scout/agent.md:139:   → ESC_REED_AUTH on auth fail; ESC_REED_RATE_LIMIT on quota
agents/recruitment/sourcing-scout/agent.md:144:   → ESC_CVLIBRARY_AUTH or _RATE_LIMIT
agents/recruitment/sourcing-scout/agent.md:158:   → ESC_DNC_FILTER_HIT if >5 candidates dropped (suggests over-eager
agents/recruitment/sourcing-scout/agent.md:164:   → prompt = (brief context + candidate profile + voice corpus + tone rules)
agents/recruitment/sourcing-scout/agent.md:165:   → voice classifier scores rationale (≥0.75)
agents/recruitment/sourcing-scout/agent.md:166:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries; drop candidate
agents/recruitment/sourcing-scout/agent.md:174:    → if any condition fails: ESC_SCHEMA_VIOLATION; partial draft to /tmp;
agents/recruitment/sourcing-scout/agent.md:199:- All rationales pass voice classifier ≥0.75
agents/recruitment/sourcing-scout/agent.md:203:Gate A failures fire `ESC_SCHEMA_VIOLATION`; draft to `/tmp`; operator review.
agents/recruitment/sourcing-scout/agent.md:211:Below 6-of-10 for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates ranking heuristic drift, source-mix imbalance, OR brief-input quality issue).
agents/recruitment/sourcing-scout/agent.md:223:| `ESC_BULLHORN_AUTH` | Bullhorn OAuth refresh fails | **blocking** (2+ source fails abort) | operator |
agents/recruitment/sourcing-scout/agent.md:224:| `ESC_LINKEDIN_AUTH` | Proxycurl API key invalid | warn (single-source fail OK if 2+ others succeed) | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:225:| `ESC_LINKEDIN_RATE_LIMIT` | Proxycurl quota exceeded | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:226:| `ESC_REED_AUTH` | Reed API fail | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:227:| `ESC_REED_RATE_LIMIT` | Reed 429 | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:228:| `ESC_CVLIBRARY_AUTH` | CV-Library API fail | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:229:| `ESC_CVLIBRARY_RATE_LIMIT` | CV-Library 429 | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:230:| `ESC_BRIEF_UNDERSPECIFIED` | LLM brief-parse yields <3 key dimensions | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:231:| `ESC_VOICE_DRIFT` | Per-candidate rationale voice classifier <0.75 after 3 retries | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:232:| `ESC_DNC_FILTER_HIT` | >5 candidates dropped by DNC list | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:233:| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in rationale | **blocking** | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:234:| `ESC_SCHEMA_VIOLATION` | Gate A failure | **blocking** | operator + ifos_oncall |
agents/recruitment/sourcing-scout/agent.md:235:| `ESC_GATE_B_MISS` | Below 6-of-10 for 30 consecutive days | warn | founder + operator |
agents/recruitment/sourcing-scout/agent.md:236:| `ESC_RATE_LIMIT_HIT` | Any source 429 (general) | warn | operator_chat_id |
agents/recruitment/sourcing-scout/agent.md:240:- `ESC_AUTOSEND_*` — no auto-send actions; pure read + report
agents/recruitment/sourcing-scout/agent.md:241:- `ESC_BULLHORN_WRITE_FAIL` — Bullhorn read-only
agents/recruitment/sourcing-scout/agent.md:242:- `ESC_VOICE_DRIFT_TENANT` — per-candidate drift detected at run time (above); no separate 30-day tenant drift signal
agents/recruitment/sourcing-scout/agent.md:248:Step 9 (per-candidate rationale generation) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/sourcing-scout/agent.md:255:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "candidate sourcing rationale" task context.
agents/recruitment/sourcing-scout/agent.md:256:- **`hh_load_recent_edits` last 30 days for `sourcing_scout` agent**: detects consultant edit patterns on rationales. Edit-distance >100 chars on >40% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT`.
agents/recruitment/sourcing-scout/agent.md:258:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/sourcing-scout/agent.md:274:| **Proxycurl commercial signup** + API access | Founder commercial; ~$39+/mo | ⏸ |
agents/recruitment/sourcing-scout/agent.md:277:| Proxycurl MCP connector | W9 build start (~2 days) | ⏸ |
agents/recruitment/sourcing-scout/agent.md:295:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:301:| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
agents/recruitment/sourcing-scout/agent.md:302:| Q2 | Proxycurl pricing — ~$39/mo for 5,000 credits at low volume; scales with usage. Per pilot tenant budget? | ~5-10 briefs/day per consultant × 50 calls/brief = up to 2,500 credits/day per consultant. Cost: ~$20-50/day at peak. |
agents/recruitment/sourcing-scout/agent.md:311:1. **LinkedIn rate limits via Proxycurl.** Proxycurl quota is per-credit; deep profile fetches cost more than searches. Plan for cost ceiling per brief.
packages/diagnostic-generator/package.json:2:  "name": "@ifos/diagnostic-generator",
packages/diagnostic-generator/package.json:10:    "ifos-diagnostic-generate": "./dist/cli.js"
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:120:- **`/vendor-cortextos`** — vendor cortextOS upstream into `packages/harness/cortextos/`. Updates `.upstream-version`. Run tests. Single command.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:136:- `feedback_voice.md` (type: feedback) — lift from v1's voice rules
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:160:| Weekly | "Pull cortextOS upstream, diff against `packages/harness/cortextos/`, surface what's safe to apply" | Keeps the vendored copy fresh without weekly manual checks |
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:254:- Modify packages/harness/cortextos/* except the four kb-* bus overrides
agents/recruitment/janitor/README.md:16:- `tools.yaml` — MCP declarations: Bullhorn R+W, Companies House, voice classifier
agents/recruitment/janitor/README.md:17:- `context.sh` — Session hydration (Bullhorn auth refresh + voice corpus + recent edits)
agents/recruitment/janitor/README.md:18:- `validate.sh` — Gate A (dedup confidence ≥0.85 + activity-window 90d + field-source confidence ≥0.7 + voice ≥0.75 + PII boundary + Bullhorn batch ≤100/min)
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:25:| 10 | `docs/architecture/vault-concurrency.md` | Reference | Verify 4 concurrency mechanisms + 5 ESC_VAULT_* codes + worked TypeScript examples |
docs/decisions/2026-05-18-codex-ratification-manifest.md:105:| 12 | `agents/_shared/hook-helpers.sh` + `agents/_shared/voice-loader.sh` + `scripts/run-codex-ratification.sh` | RATIFIED | Cross-cutting Risk #11 remediation incorporated in this commit; Round-3 RATIFIED. |
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
docs/decisions/2026-05-18-codex-ratification-manifest.md:167:| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:168:| 18 | vertical-schema.yaml v0.1 | REJECTED (3 issues) | Issue 1 (voice_classifier_score CHECK) **incorporated** with v0.2 trigger reference. Issue 2 (empty access arrays) **incorporated**. Issue 3 (versioning count) **incorporated**. Plus pre-existing YAML parse errors fixed. |
packages/diagnostic-generator/README.md:1:# @ifos/diagnostic-generator
packages/diagnostic-generator/README.md:3:Composes `@ifos/web-scraper` + `@ifos/companies-house` into a 12-section Markdown report for a UK recruitment firm. Called by `agents/recruitment/diagnostic/cycle.sh` after context.sh hydrates the session and before validate.sh runs Gate A.
packages/diagnostic-generator/README.md:8:node packages/diagnostic-generator/dist/cli.js \
packages/diagnostic-generator/README.md:15:Writes the Markdown report to stdout. `cycle.sh` captures it to `/tmp/diagnostic-draft-<slug>-<pid>.md`.
packages/diagnostic-generator/README.md:21:- **§3 Sector mix** — stub with Companies House SIC codes; LinkedIn jobs at W4.
packages/diagnostic-generator/README.md:22:- **§4 Geography** — Companies House registered office; LinkedIn job-post locations at W4.
packages/diagnostic-generator/README.md:23:- **§5 Deal-size band** — firm-age proxy from Companies House; LinkedIn salary bands at W4.
packages/diagnostic-generator/README.md:28:- **§10 Recent activity** — Companies House filings last 90 days; LinkedIn posts + Google news at W4.
packages/diagnostic-generator/README.md:29:- **§11 Decision-maker map** — Companies House directors as proxy; LinkedIn employee search at W4.
packages/diagnostic-generator/README.md:34:This is the **Day-13 v0 build** per `docs/operations/goal-option-c-diagnostic-end-to-end.md`. Limitations:
packages/diagnostic-generator/README.md:36:1. **No LinkedIn deep data.** Page-existence check via HEAD only. Full data needs Proxycurl signup (~$39/mo).
packages/diagnostic-generator/README.md:37:2. **No LLM-driven §12.** Conversation opener is deterministic anchor-based. W4 wires an LLM + voice classifier.
packages/diagnostic-generator/README.md:38:3. **No voice classifier gate.** validate.sh V3 skipped at v0 with explicit warning.
packages/diagnostic-generator/README.md:39:4. **No Google news search.** §10 only sees Companies House filings.
packages/diagnostic-generator/README.md:47:| Companies House API key missing | Throws CHAuthError at module init; cycle.sh exits non-zero |
packages/diagnostic-generator/README.md:48:| Companies House 404 (firm not registered) | Section §1 reports "no registration found"; §6+§10+§11 degrade gracefully |
packages/diagnostic-generator/README.md:50:| LinkedIn HEAD returns 999 (bot detection) | §2 treats as "page exists, deep data via Proxycurl"; not a failure |
packages/diagnostic-generator/README.md:51:| Network down | All Companies House + web-scraper calls fail; report degrades to "no-data" path but still 12 sections + ≥1 citation each (V1+V2 pass) |
packages/diagnostic-generator/README.md:64:v0.1 — Diagnostic W3 pre-build per `agents/recruitment/diagnostic/agent.md` + `docs/operations/goal-option-c-diagnostic-end-to-end.md`.
agents/recruitment/janitor/agent.md:6:**Build wave:** v1.0 W5 per master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 line 503 (ULTRAPLAN says week 5-6, master brief says week 5; master brief is authoritative).
agents/recruitment/janitor/agent.md:16:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate records, (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `decision_log` resolution events. Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). All Bullhorn writes are yellow-tier per `autosend-safety-policy.yaml` (sampled spot-checks; no synchronous approval; per-write audit row to `decision_log` with `agent_name='janitor'`).
agents/recruitment/janitor/agent.md:58:| 3 | **Field-completeness deltas** | Per entity-type table: which fields were filled in (e.g., candidate.location, contractor.day_rate); source of the backfill (Companies House lookup, LinkedIn enrichment, derivation from related entities) |
agents/recruitment/janitor/agent.md:61:| 6 | **Gate-B metric** | Composite score: (dedup % improvement × 0.5) + (field-completeness % improvement × 0.5). Target ≥12.5 (≥15% dedup + ≥10% field) per ULTRAPLAN A2 line 511 |
agents/recruitment/janitor/agent.md:70:2. **Field backfill** (`PATCH /Candidate/{id}` or `/Client/{id}`) — fills missing `location`, `industry`, `last_active_date`, etc. from Companies House (for clients) or LinkedIn/derivation (for candidates). Sources logged in payload.
agents/recruitment/janitor/agent.md:83:   → context.sh hydrates: tenant config + Bullhorn auth refresh + voice corpus
agents/recruitment/janitor/agent.md:90:   → ESC_BULLHORN_AUTH if refresh fails after 2 retries
agents/recruitment/janitor/agent.md:97:   → ESC_RATE_LIMIT_HIT if Bullhorn 429 (60s backoff per §1.1.2 of v0.2 supplement)
agents/recruitment/janitor/agent.md:117:6. Companies House enrichment (clients only)
agents/recruitment/janitor/agent.md:121:   → ESC_RATE_LIMIT_HIT on 429
agents/recruitment/janitor/agent.md:123:7. LinkedIn enrichment (candidates; v1.1 via Proxycurl)
agents/recruitment/janitor/agent.md:124:   → at v1.0: skipped (LinkedIn deep data deferred to W4 polish; Proxycurl
agents/recruitment/janitor/agent.md:133:   → for each group, generate narrative summary via voice-classified LLM
agents/recruitment/janitor/agent.md:134:     (voice corpus + tone rules; ESC_VOICE_DRIFT if classifier <0.75)
agents/recruitment/janitor/agent.md:140:   → on 4xx: emit ESC_BULLHORN_WRITE_FAIL; skip; continue
agents/recruitment/janitor/agent.md:141:   → on 5xx: emit ESC_BULLHORN_WRITE_FAIL; retry once with 30s backoff
agents/recruitment/janitor/agent.md:146:   → group by action_type; tally success/fail; compute Gate-B metric
agents/recruitment/janitor/agent.md:149:   → hh_decision_output("day_30_report", "<path>", "Gate-B score: <N>")
agents/recruitment/janitor/agent.md:152:   → if Gate-B target met: green-tier notification with summary
agents/recruitment/janitor/agent.md:153:   → if Gate-B target missed: yellow-tier notification + 200-char executive
agents/recruitment/janitor/agent.md:159:   → exit code 0 (or 1 if Gate-B missed for 3 consecutive runs → ESC_GATE_B_MISS)
agents/recruitment/janitor/agent.md:174:- Tacit-note narratives pass voice classifier ≥ 0.75
agents/recruitment/janitor/agent.md:178:Gate A failures fire `ESC_SCHEMA_VIOLATION` + draft report stays in `/tmp` (not vault); operator-review required.
agents/recruitment/janitor/agent.md:186:Gate B doesn't block the agent. It's the v1.0 kill-criterion §2 Trigger 8 supporting metric ("Gate-B revenue uplift" — Janitor's day-30 report is THE artefact that demonstrates "DSO drops" / "consultant time saved" claims to the FD-tier closer).
agents/recruitment/janitor/agent.md:188:Below ≥12.5 for 3 consecutive runs → fire `ESC_GATE_B_MISS` → flag for operator review (heuristic tuning may be needed; not a kill).
agents/recruitment/janitor/agent.md:198:| `ESC_BULLHORN_AUTH` | OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
agents/recruitment/janitor/agent.md:199:| `ESC_BULLHORN_WRITE_FAIL` | Bullhorn 4xx/5xx on merge/backfill/note write | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:200:| `ESC_RATE_LIMIT_HIT` | Bullhorn or Companies House 429 | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:201:| `ESC_VOICE_DRIFT` | Tacit-note narrative voice classifier <0.75 (after 3 retries) | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:202:| `ESC_PII_LEAKAGE_RISK` | PII detected in tacit-note outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/janitor/agent.md:203:| `ESC_SCHEMA_VIOLATION` | Gate A failure (merge confidence + activity window + field-source confidence) | **blocking** | operator + ifos_oncall |
agents/recruitment/janitor/agent.md:204:| `ESC_GATE_B_MISS` | Composite Gate-B score <12.5 for 3 consecutive runs | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:205:| `ESC_AUTOSEND_YELLOW_SPOT_CHECK` | Yellow-tier sample row selected for spot-check | info | operator_chat_id |
agents/recruitment/janitor/agent.md:209:- `ESC_VOICE_DRIFT_TENANT` — that's for cross-tenant voice drift; Janitor is per-tenant
agents/recruitment/janitor/agent.md:210:- `ESC_AUTOSEND_BLOCKED` — that's red-tier; Janitor doesn't do red writes
agents/recruitment/janitor/agent.md:211:- `ESC_BULLHORN_OAUTH_REVOKED` — escalated from `ESC_BULLHORN_AUTH` after 6 consecutive auth failures (different code; Concierge handles)
agents/recruitment/janitor/agent.md:217:Step 8 (tacit-note narrative generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/janitor/agent.md:223:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "internal note summary" task context. Feeds LLM prompt as voice exemplars.
agents/recruitment/janitor/agent.md:224:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Drift >200 chars on >50% of recent_edit rows fires `ESC_VOICE_DRIFT_TENANT`.
agents/recruitment/janitor/agent.md:226:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/janitor/agent.md:238:| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action; Trigger 1 fires 2026-06-03 if no LOI |
agents/recruitment/janitor/agent.md:243:| Companies House MCP connector | Day-13 shipped (`@ifos/companies-house`) | ✅ |
docs/decisions/ADR-004-renderer-implementation-deviations.md:30:**Why the deviation:** `cortextos-ifos` is the upstream CLI shipped from the cortextOS submodule at `/opt/homebrew/bin/cortextos-ifos`. Adding a `render-agent` subcommand to that binary requires modifying source in `packages/harness/cortextos/`, which violates master brief §3.1 boundary 1 (cortextOS submodule read-only). The boundary is non-negotiable per master brief §3.1 + the build-pack discipline that the submodule is a "reference pin, not the runtime."
docs/decisions/ADR-004-renderer-implementation-deviations.md:72:**Observation:** `cortextos-ifos list-agents` (which calls into `packages/harness/cortextos/src/bus/agents.ts` `listAgents()`) scans `${frameworkRoot}/orgs/<org>/agents/*` and treats every immediate directory child as an agent. `_shared/` sits in that location per ADR-003 §3.3.3 Option γ. Result: `_shared` appears in the list-agents output as if it were an agent named `_shared` in org `<tenant>`, with no display name + no config + status `stopped`.
docs/_archive-build-pack/04-DATA-MODEL.md:310:├── voice/
docs/_archive-build-pack/04-DATA-MODEL.md:311:│   └── voice-profile.md
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:3:**Product knowledge v2 inherits without rethinking. ICP, pricing, brand voice, invariants, agent catalogue, integrations, compliance posture. So strategic work doesn't get re-relitigated during the build. Treat this file as canon — if v2 needs to deviate, that's a separate decision recorded in `08-OPEN-DECISIONS.md`.**
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:29:1. It uses YOUR data (handbook, past replies, voice profile — not a generic template)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:60:| 04 | Lead Hunter | Sales | Daily 08:00 | 38 qualified leads | HubSpot, Companies House, Clay |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:207:- Companies House (Lead Hunter)
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:228:ONBOARD (24-72h)  → wizard: tools connect, voice profile, integrations
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:27:- `agents/_shared/voice-loader.sh` (Phase 5, commit `fe56e93`)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:31:Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:66:PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of
agents/recruitment/diagnostic/cleanup.sh:57:    '{"escalation_code":"ESC_PII_LEAKAGE_RISK","reason":"LinkedIn cache purge incomplete"}' \
agents/recruitment/diagnostic/cleanup.sh:71:# Companies House cache stays per tools.yaml (7-day TTL).
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
packages/harness/cortextos/dashboard/public/file.svg:1:<svg fill="none" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><path d="M14.5 13.5V5.41a1 1 0 0 0-.3-.7L9.8.29A1 1 0 0 0 9.08 0H1.5v13.5A2.5 2.5 0 0 0 4 16h8a2.5 2.5 0 0 0 2.5-2.5m-1.5 0v-7H8v-5H3v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1M9.5 5V2.12L12.38 5zM5.13 5h-.62v1.25h2.12V5zm-.62 3h7.12v1.25H4.5zm.62 3h-.62v1.25h7.12V11z" clip-rule="evenodd" fill="#666" fill-rule="evenodd"/></svg>
packages/diagnostic-generator/tests/online-footprint.test.ts:20:describe("@ifos/diagnostic-generator — online-footprint slug fallback", () => {
packages/diagnostic-generator/tests/generate.test.ts:13:  // Stub Companies House API key so client doesn't throw at module init.
packages/diagnostic-generator/tests/generate.test.ts:25:describe("@ifos/diagnostic-generator", () => {
docs/_archive-build-pack/05-MIGRATION-MAP.md:122:| Brand voice rules | KEEP | `WEBSITE-CONTEXT.md` §brand-identity-spec | `packages/agents/voice.md` — used by every agent that drafts customer-facing content |
docs/_archive-build-pack/05-MIGRATION-MAP.md:133:| TypeScript source | KEEP | `src/{bus,cli,daemon,hooks,pty,telegram,types,utils}/` | `packages/harness/cortextos/src/` |
docs/_archive-build-pack/05-MIGRATION-MAP.md:134:| CLI entry | KEEP | `dist/cli.js` (after `npm run build`) | `packages/harness/cortextos/dist/cli.js` |
docs/_archive-build-pack/05-MIGRATION-MAP.md:135:| Daemon entry | KEEP | `dist/daemon.js` | `packages/harness/cortextos/dist/daemon.js` |
docs/_archive-build-pack/05-MIGRATION-MAP.md:136:| Agent templates (Orchestrator, Analyst, Specialist, Hermes, M2C1) | KEEP | `templates/` | `packages/harness/cortextos/templates/` |
docs/_archive-build-pack/05-MIGRATION-MAP.md:137:| Org template | KEEP | `templates/org/` | `packages/harness/cortextos/templates/org/` |
packages/harness/cortextos/src/daemon/agent-manager.ts:344:        // Check for media messages (photo, document, voice, audio, video, video_note)
packages/harness/cortextos/src/daemon/agent-manager.ts:345:        const isMedia = !!(msg.photo || msg.document || msg.voice || msg.audio || msg.video || msg.video_note);
packages/harness/cortextos/src/daemon/agent-manager.ts:374:            } else if (media.type === 'voice' || media.type === 'audio') {
packages/harness/cortextos/src/daemon/agent-manager.ts:966: * checked, so replies to videos/photos/voice arrived as bare text with no
packages/harness/cortextos/src/daemon/agent-manager.ts:978:  if (replyMsg.voice) return '[voice message]';
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:1:# Diagnostic fixture — 99-voice-drift-canary
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:3:# Adversarial case. Tests Gate A V3 (voice classifier ≥ 0.75) hard-fail
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:5:# (LLM-generated using a deliberately off-voice prompt instruction).
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:7:# ESC_VOICE_DRIFT row emitted, draft NOT written to vault.
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:9:# Per kill-criterion §2 Trigger 5 + agent.md §6: voice drift is an
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:15:fixture_id: 99-voice-drift-canary
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:16:description: Adversarial — force voice classifier below 0.75; expect Gate A V3 failure
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:18:agent: diagnostic
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:22:  command: ifosctl diagnostic
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:31:# Forces the voice classifier into a known-low-scoring path by injecting
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:32:# an off-voice opener directly (bypasses LLM in test mode)
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:42:  # voice. Voice classifier scores in 0.2-0.4 range against a real tenant
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:62:  V3_voice_score: FAIL  # < 0.75 after 3 retries — the canary fires here
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:69:  - escalation_code: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:86:    - "voice_classifier_score"
agents/recruitment/diagnostic/fixtures/99-voice-drift-canary.yaml:87:    - "ESC_VOICE_DRIFT"
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:22:| 6 | **Concurrency-document-prerequisite** — without `docs/architecture/vault-concurrency.md`, the wiki/lib/concurrency.ts code can't be reviewed; week-5 first multi-agent test runs against unreviewed concurrency machinery | ~~Medium~~ **Closed** | ~~Medium~~ **Closed** | (closed) | **Closed 2026-05-16 Day 3 evening:** `docs/architecture/vault-concurrency.md` shipped at 455 lines. 4 mechanisms specified with TypeScript worked examples (`flock(2)`, Postgres optimistic concurrency, mtime debounce, rewrite-backlinks cascade). 5 new `ESC_VAULT_*` codes consolidated for `_shared/hook-helpers.sh` Week-1 prereq. Surfaces 1 new Day-4 tightening (`entities.version` column per §3.1). v1.0 atomicity gap honestly documented; v1.2+ WAL pattern deferred. **Source:** Spec gap 2.6 in `second-brain-design.md`. |
docs/RISK-REGISTER.md:36:| 13 | **GUC name drift between executed Day-4 reality and Days-8-11 codebase** — Day-4 §6.3 provisioned live RLS policies using `current_setting('app.current_tenant', TRUE)` (verified Day-11 via `\dp entities`), but Days 8-11 code (hook-helpers.sh, voice-loader.sh, run-live-migration.sh, run-tenancy-audit.sh, ifos-pii-purge.sh, v0.1-to-v0.2.sql) + Day-9 ratified docs (tenancy-invariants.md, architecture-cohesion-review.md) wrote `ifos.tenant_slug` instead. Three rounds of Codex ratification + cohesion review didn't catch it because no artefact in Days 8-11 was ever executed end-to-end against live Postgres. Surfaced 2026-05-22 during first live migration attempt (CREATE TRIGGER failed for separate privilege reason; founder ran `\dp entities` while diagnosing; the GUC mismatch was visible in policy output). | ~~High~~ → Low post-remediation | High (every Days-8-11 write to live Postgres would have silently failed RLS or returned 0 rows — silent data leak risk if ever inverted) | Any helper / migration / script execution against live Postgres that uses an RLS-protected table and returns surprising row counts; first end-to-end live execution of any of the 6 affected scripts; future `\dp` audit revealing additional drift. | Day-11 remediation (this commit): mechanical rename `ifos.tenant_slug` → `app.current_tenant` across 15 files; 29/29 helper tests still pass; v0.1-to-v0.2 migration verified to use the corrected GUC. Future: run `bash scripts/run-tenancy-audit.sh` post-migration to verify all 12 invariants against the live database. | **Mitigated in this commit pending live re-run of v0.2 migration + tenancy audit verification.** |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:62:- 2026-05-16 (Day 3 evening) — **Risk #6 closed.** `docs/architecture/vault-concurrency.md` shipped (455 lines, reference document). 4 mechanisms specified with worked examples; 5 new `ESC_VAULT_*` codes consolidated for `_shared/hook-helpers.sh` Week-1 prereq wiring (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_VERSION_MISMATCH`, `ESC_VAULT_HUMAN_EDIT_BLOCKED`, `ESC_VAULT_CASCADE_PARTIAL_FAILURE`, `ESC_VAULT_CASCADE_TIMEOUT`). Risk #7 edit count unchanged at 8 — `vault-concurrency.md` is reference synthesis, surfaces no new master-brief drifts. Surfaces one new Day-4 tightening (`entities.version` column per §3.1) — Day 4 now has 4 consolidated tightenings.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
agents/recruitment/diagnostic/fixtures/01-primary.yaml:14:agent: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:19:  command: ifosctl diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:84:  voice_classifier_score_min: 0.78
agents/recruitment/diagnostic/fixtures/01-primary.yaml:85:  vault_path_template: "/vault/migration-test/diagnostic-reports/charterhouse-partners-{ISO_DATE}.md"
agents/recruitment/diagnostic/fixtures/01-primary.yaml:91:  V3_voice_score: PASS  # ≥ 0.75 required
agents/recruitment/diagnostic/fixtures/01-primary.yaml:99:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:102:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:103:    payload_includes: {output_type: "diagnostic_draft"}
agents/recruitment/diagnostic/fixtures/01-primary.yaml:105:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:106:    action_type: diagnostic_report_render
agents/recruitment/diagnostic/fixtures/01-primary.yaml:109:    agent_name: diagnostic
agents/recruitment/diagnostic/fixtures/01-primary.yaml:110:    action_type: diagnostic_cleanup
packages/harness/cortextos/dashboard/src/lib/config.ts:85:  return path.join(CTX_FRAMEWORK_ROOT, 'orgs', org, 'brand-voice.md');
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:3:# Edge case: firm exists at Companies House but has placeholder website,
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:5:# the agent degrades gracefully — sections 1 (Companies House) populated;
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:7:# generates a voice-classified opener despite thin context.
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:15:agent: diagnostic
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:19:  command: ifosctl diagnostic
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:71:  citations_per_section_min: 1   # even thin sections cite Companies House
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:72:  voice_classifier_score_min: 0.75
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:76:  V2_per_section_citation: PASS  # thinner sections cite Companies House profile
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:77:  V3_voice_score: PASS
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:92:  - Companies House
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:99:    payload_includes: {output_type: "diagnostic_draft"}
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:101:    action_type: diagnostic_report_render
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:4:triggers: ["buy", "purchase", "pay for", "subscribe to", "need a credit card", "make a payment", "sign up for paid plan", "buy a domain", "purchase API credits", "pay invoice", "need to pay", "financial transaction", "virtual card", "agentcard"]
packages/harness/cortextos/community/skills/agentcard-purchase/SKILL.md:22:- Pay an invoice that was sent to the org
agents/recruitment/diagnostic/cycle.sh:19:#   - One Markdown file in /vault/<tenant_slug>/diagnostic-reports/<firm-slug>-<ISO-date>.md
agents/recruitment/diagnostic/cycle.sh:25:#   1  Workflow failure (specific step failed; ESC_* row emitted)
agents/recruitment/diagnostic/cycle.sh:29:# Build state: SCAFFOLD. MCP connectors not yet wired (Companies House,
agents/recruitment/diagnostic/cycle.sh:88:REPORT_DIR="${VAULT_ROOT}/${CTX_TENANT_SLUG}/diagnostic-reports"
agents/recruitment/diagnostic/cycle.sh:90:DRAFT_PATH="/tmp/diagnostic-draft-${FIRM_SLUG}-$$.md"
agents/recruitment/diagnostic/cycle.sh:102:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:104:    '{"escalation_code":"ESC_SCHEMA_VIOLATION","reason":"firm name too short"}' >/dev/null
agents/recruitment/diagnostic/cycle.sh:109:# Step 2-11 — Generate the 12 sections via @ifos/diagnostic-generator
agents/recruitment/diagnostic/cycle.sh:113:# data deferred to W4 (Proxycurl). Voice classifier gate skipped at v0.
agents/recruitment/diagnostic/cycle.sh:114:# CLI: packages/diagnostic-generator/dist/cli.js
agents/recruitment/diagnostic/cycle.sh:116:GENERATOR_CLI="${IFOS_REPO_ROOT:-${REPO_ROOT}}/packages/diagnostic-generator/dist/cli.js"
agents/recruitment/diagnostic/cycle.sh:119:  printf '  Run: cd packages/diagnostic-generator && pnpm build\n' >&2
agents/recruitment/diagnostic/cycle.sh:130:# Load Companies House API key from tenant secrets if present
agents/recruitment/diagnostic/cycle.sh:156:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:158:    '{"escalation_code":"ESC_SCHEMA_VIOLATION","reason":"generator stdout empty"}' >/dev/null
agents/recruitment/diagnostic/cycle.sh:166:hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:182:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:634:        <span class="glyph"></span><span>Companies House</span><span class="count">0</span>
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:739:            &middot; <a href="#">ESC_BRIEF_AMBIGUITY</a> raised to <a href="#">Sarah Whittaker</a>
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:785:            &middot; brand voice would otherwise read as harassment
docs/design-mockups/brain-ui-decisions-feed-light-v01.html:905:            &middot; auto-flagged before invoice generation
packages/agent-renderer/src/types.ts:49:  voice_threshold?: number;
docs/decisions/autosend-safety-policy.md:25:1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
docs/decisions/autosend-safety-policy.md:27:3. Reads from external systems that touch PII or have rate-limit/cost implications (LinkedIn profile lookups, Companies House director searches)
docs/decisions/autosend-safety-policy.md:61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
docs/decisions/autosend-safety-policy.md:67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:81:| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:96:| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |
docs/decisions/autosend-safety-policy.md:108:| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
docs/decisions/autosend-safety-policy.md:109:| Diagnostic | `diagnostic_calendar_invite` | Books intro call with prospect; reputation + scheduling friction |
docs/decisions/autosend-safety-policy.md:113:### Red examples (blocked entirely; `ESC_AUTOSEND_BLOCKED`)
docs/decisions/autosend-safety-policy.md:161:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
docs/decisions/autosend-safety-policy.md:168:    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
docs/decisions/autosend-safety-policy.md:187:      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
docs/decisions/autosend-safety-policy.md:194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
docs/decisions/autosend-safety-policy.md:200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
docs/decisions/autosend-safety-policy.md:229:Agents cannot invoke action_types not declared in their `tools.yaml`. Renderer validates this at render time per ADR-003 §4 (`ESC_RENDERER_FAILED` reason `bundle-malformed` if a declared action_type isn't in the policy).
docs/decisions/autosend-safety-policy.md:235:Three new escalation codes added to `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3. Codes follow the payload template established by `ESC_RENDERER_FAILED` in `agent-bundle-renderer-design.md` §4.
docs/decisions/autosend-safety-policy.md:237:### `ESC_AUTOSEND_NEEDS_REVIEW`
docs/decisions/autosend-safety-policy.md:259:2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
docs/decisions/autosend-safety-policy.md:280:### `ESC_AUTOSEND_BLOCKED`
docs/decisions/autosend-safety-policy.md:301:2. `autosend_escalate ESC_AUTOSEND_BLOCKED` notifies tenant operator informationally (no action required)
docs/decisions/autosend-safety-policy.md:313:Target: invoice:INV-2026-0042
docs/decisions/autosend-safety-policy.md:318:### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
docs/decisions/autosend-safety-policy.md:339:2. `autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED` notifies tenant operator AND IFOS oncall
docs/decisions/autosend-safety-policy.md:352:| Policy file `autosend-policy.yaml` corrupted (YAML parse error) | First `hh_decision_action` call returns parse error | Fail-safe red for ALL actions; `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` per action; agent halts | IFOS oncall restores from git history; renderer re-deploys; agent resumes |
docs/decisions/autosend-safety-policy.md:353:| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
docs/decisions/autosend-safety-policy.md:358:| Action_type declared in `tools.yaml` but missing from `autosend-policy.yaml` | Renderer pre-flight validation per ADR-003 §4 | `ESC_RENDERER_FAILED` with `reason='bundle-malformed'`; render aborts before agent deploys | Add `action_type` to policy file; Codex ratifies; re-render |
docs/decisions/autosend-safety-policy.md:582:1. **Jurisdiction.** IFOS Limited is UK Companies House registered → English law as default. Confirm with counsel; cross-border tenants may require alternate forum clauses.
docs/decisions/autosend-safety-policy.md:632:**For Week 1-2.** The `_shared/voice-loader.sh` + `hook-helpers.sh` Week-1 prerequisite (per ADR-002 §"For Week 1 work" + ADR-003 Decision 3) now has its `hh_decision_action` specification. Implementation work is well-defined: §4 pseudocode + §5 escalation payloads + §7 audit row schema.
docs/decisions/autosend-safety-policy.md:634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
agents/recruitment/diagnostic/README.md:18:| `tools.yaml` | MCP tool declarations (Companies House + LinkedIn read-only + web scraper) | W3 build start |
agents/recruitment/diagnostic/README.md:19:| `context.sh` | Session hydration (voice corpus + target_patch + tone rules) | W3 build start |
agents/recruitment/diagnostic/README.md:20:| `validate.sh` | Gate A enforcement (12 sections + per-section citation + voice ≥ 0.75 + PII boundary) | W3 build start |
agents/recruitment/diagnostic/README.md:25:| `fixtures/99-voice-drift-canary.yaml` | Adversarial: forces voice classifier near threshold | W3 build start |
agents/recruitment/diagnostic/README.md:52:- ⏸ Companies House + LinkedIn MCP connectors built
packages/harness/cortextos/dashboard/src/lib/__tests__/sync.test.ts:270:      title: 'A1',
docs/decisions/v1.0-kill-criterion.md:45:### Trigger 1 — DESIGN-PARTNER-BY-WEEK-2 (PAUSE)
docs/decisions/v1.0-kill-criterion.md:63:**Threshold:** Diagnostic agent does not render cleanly via `ifos-render-agent render diagnostic --tenant <slug>` by end of Week 3 (2026-06-14). "Cleanly" means: renderer exits 0, no `ESC_RENDERER_FAILED` rows in `decision_log`, validate.sh passes against all three fixtures. (CLI name per ADR-004 Decision 1; earlier drafts named this `cortextos-ifos render-agent` which violated master brief §3.1 boundary 1.)
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:158:### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
docs/decisions/v1.0-kill-criterion.md:186:### Trigger 10 — PII-LEAKAGE-INCIDENT (KILL)
docs/decisions/v1.0-kill-criterion.md:212:- For all KILL actions: founder decides; activates within 24h (within 4h for Trigger 10 PII per §3.5 emergency authority).
docs/decisions/v1.0-kill-criterion.md:226:- **Trigger 1 (Design partner) PAUSE → KILL escalation:** if PAUSE extends 4 weeks without signed LOI, founder consults Jack on whether to escalate to KILL (commercial assessment of pipeline) or extend PAUSE.
docs/decisions/v1.0-kill-criterion.md:227:- **Trigger 8 (Gate-B revenue) KILL:** founder decides KILL on revenue evidence; consults Jack on wind-down terms with existing pilots before 30-day notice goes out.
docs/decisions/v1.0-kill-criterion.md:237:### §3.5 — Emergency authority (Trigger 10 PII-LEAKAGE-INCIDENT specifically)
docs/decisions/v1.0-kill-criterion.md:239:Trigger 10 escalates regulatory-clock-driven actions. UK GDPR Art. 33 mandates ICO notification within 72 hours of discovery; multi-person consultation cannot delay this clock.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:350:- Adds AgentMail integration (Inbound Triage only) per master brief §3.2
docs/decisions/v1.0-kill-criterion.md:355:**Defined in Week 4+ once v1.0 has at least one pilot operational.** v1.1 kill criterion will incorporate v1.0 learnings + v1.1-specific triggers (e.g., wiki UI usability scores, voice classifier drift rates, LoRA training cost-per-tenant).
docs/decisions/v1.0-kill-criterion.md:371:**For Week 0 remaining.** Day 6 (vertical schema v0.1) and Day 7 (single-sentence test + Codex run) do not depend on this criterion directly. Day 7's question 1 (design partner LOI) is the structural Week-0 gate; this criterion's Trigger 1 (DESIGN-PARTNER-BY-WEEK-2) explicitly references that gap.
docs/decisions/v1.0-kill-criterion.md:373:**For Week 1-2.** All Week-1 work is conducted with awareness that Trigger 1 fires 2026-06-03 if no LOI (per §1 calendar — Wednesday end-of-Week-2). Founder allocates time accordingly: design-partner acquisition is a Week-1 sub-track, not an afterthought.
agents/recruitment/diagnostic/tools.yaml:14:agent: diagnostic
agents/recruitment/diagnostic/tools.yaml:18:  # ── §4 Step 2: Companies House lookup ─────────────────────────────────
agents/recruitment/diagnostic/tools.yaml:22:      Read-only access to Companies House UK API. Used in §4 Step 2 for
agents/recruitment/diagnostic/tools.yaml:24:      share-class moves. Rate-limited: 600 requests per 5-minute window per IP.
agents/recruitment/diagnostic/tools.yaml:42:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:48:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:54:      Read-only LinkedIn API (provider TBD at W3 build start — Proxycurl
agents/recruitment/diagnostic/tools.yaml:61:      - LINKEDIN_API_KEY  # provider-specific; Proxycurl or alternative
agents/recruitment/diagnostic/tools.yaml:69:      per_window: 100  # Proxycurl default per second
agents/recruitment/diagnostic/tools.yaml:77:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:80:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:83:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:116:  # ── §4 Step 9 + §7 voice classifier ───────────────────────────────────
agents/recruitment/diagnostic/tools.yaml:117:  - name: voice_classifier
agents/recruitment/diagnostic/tools.yaml:120:      Per-tenant voice classifier for the §12 conversation opener.
agents/recruitment/diagnostic/tools.yaml:121:      Scores §12 output against tenant's voice corpus + tone rules. Gate A
agents/recruitment/diagnostic/tools.yaml:123:      voice-loader.sh for tenant corpus + tone rules + recent_edits.
agents/recruitment/diagnostic/tools.yaml:127:      - voice.classify  # text + tenant_slug → score in [0,1]
agents/recruitment/diagnostic/tools.yaml:128:      - voice.tone_rule_check  # text + tone_rule_set → list of violations
agents/recruitment/diagnostic/tools.yaml:137:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:140:        escalation: ESC_VOICE_DRIFT
agents/recruitment/diagnostic/tools.yaml:162:        escalation: ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/tools.yaml:165:        escalation: ESC_RATE_LIMIT_HIT
agents/recruitment/diagnostic/tools.yaml:182:  - linkedin_readonly_mcp_connector  # ~2 days at W3 start (Proxycurl wrapper)
agents/recruitment/diagnostic/tools.yaml:184:  - voice_classifier_microservice  # ~2 days at W3 start (OR LLM fallback)
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:77:- **Enforcement:** `agents/_shared/hook-helpers.sh::_hh_emit_row` sets it via `SET LOCAL app.current_tenant = '${tenant}';` before INSERT. `agents/_shared/voice-loader.sh::_vl_psql_query` sets it via wrapped SQL. `packages/agent-renderer/src/renderer.ts` doesn't write to tenant-data tables directly (it writes to vault).
docs/architecture/tenancy-invariants.md:78:- **Documentation source:** `agents/_shared/hook-helpers.sh` lines ~75-95 (`_hh_emit_row` live-mode SQL) + `agents/_shared/voice-loader.sh` lines ~60-70 (`_vl_psql_query`).
docs/architecture/tenancy-invariants.md:81:  grep -n "SET LOCAL app.current_tenant\|SET app.current_tenant" agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh packages/agent-renderer/src/*.ts
docs/architecture/tenancy-invariants.md:155:- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
docs/architecture/tenancy-invariants.md:156:- **Enforcement:** Partial unique index in v0.2 migration §2: `CREATE UNIQUE INDEX voice_corpus_one_active_per_tenant ON voice_corpus (tenant_slug) WHERE is_active=TRUE`. Postgres enforces — duplicate INSERT fails.
docs/architecture/tenancy-invariants.md:161:  WHERE tablename='voice_corpus' AND indexname='voice_corpus_one_active_per_tenant';
docs/architecture/tenancy-invariants.md:176:  SELECT count(*) FROM voice_corpus;            -- expect 0
docs/architecture/tenancy-invariants.md:211:| T10 | Partial → Verified | v0.2 migration §2 partial unique index + tenancy audit | v0.2 migration design; pending Day-9 functional verify (post live migration) | Single-active voice corpus per tenant |
docs/architecture/tenancy-invariants.md:237:- **At every agent runtime write**: hook-helpers.sh + voice-loader.sh enforce T4 via `SET LOCAL app.current_tenant` pattern; relies on T11 (Postgres RLS) as the structural backstop.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:36:- **Kill criterion linkage:** Trigger 1 in `docs/decisions/v1.0-kill-criterion.md` §2 (DESIGN-PARTNER-BY-WEEK-2) fires end-of-day **2026-06-03** if no signed LOI by then. That is the binding tripwire — currently **14 calendar days** out from today (2026-05-20).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:90:| 1 | Design partner pilot Q3 2026 LOI? | **NO** | High — zero pipeline; Risk #3 High; Trigger 1 fires 2026-06-03 |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:148:- Trigger 1 (kill criterion DESIGN-PARTNER-BY-WEEK-2 PAUSE): fires end-of-day **2026-06-03** if no signed LOI.
packages/agent-renderer/src/synthesis/claudeMd.ts:26:    "{{voice_threshold}}": String(tenant.voice_threshold ?? 0.75),
docs/architecture/architecture-cohesion-review.md:73:| second-brain-design.md §2.6.4 | ESC_VAULT_* catalogue | escalation-codes.md | ✓ landed Phase 1 (a279226) — 4 of the 5 catalogued |
docs/architecture/architecture-cohesion-review.md:88:| A1 | **Postgres `current_setting('app.current_tenant', TRUE)` returns NULL when unset, never empty string.** RLS predicate `tenant_slug = current_setting(...)` relies on NULL≠'anything' semantics. | Every RLS policy on every tenant-data table | If empty string is returned, an INSERT with `tenant_slug=''` could leak across tenants. Postgres docs confirm NULL behaviour; assumption holds. |
docs/architecture/architecture-cohesion-review.md:93:| A6 | **Voice corpus chunks fit in pgvector memory at v1.0 scale.** HNSW index assumes per-tenant chunk count < 10K. | Phase 4 v0.2 supplement + voice-loader.sh queries | At 1 tenant × 5K chunks = ~30MB. 100 tenants × 5K = 3GB. Within Hetzner VPS RAM. Above 1000 tenants this becomes a real constraint. |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:147:| G1 | **Concierge "voice corpus refresh" cadence is undefined.** When does a tenant re-index? Operator triggers? Scheduled cron? Re-index on N% recent_edit drift? | Medium (Concierge W10 dependency) | New ADR at Concierge build time OR addendum to v0.2 supplement at v1.0 schema close. Owner: Claude Code, trigger: Week-9. |
docs/architecture/architecture-cohesion-review.md:166:**Boundary:** `packages/harness/cortextos/*` is read-only EXCEPT the four `bus/kb-*.sh` shadow points.
docs/architecture/architecture-cohesion-review.md:171:  - **A:** Grep finds no `write` / `mkdir` / `rm` operations targeting `packages/harness/cortextos/`. Renderer writes to `${frameworkRoot}/orgs/...` (outside submodule). Helpers don't touch submodule. ✓ Clean.
docs/architecture/architecture-cohesion-review.md:174:- **Q:** Could a developer accidentally `cd packages/harness/cortextos && vim README.md`?
docs/architecture/architecture-cohesion-review.md:175:  - **A:** Submodule HEAD detached at SHA `c21fbfe`. Any local edit shows as detached-HEAD modification but doesn't propagate to upstream. Edits are local-only until explicitly pushed upstream (which we never do). **Acceptable risk; covered by CLAUDE.md §"Never modify packages/harness/cortextos/* except..."**.
docs/architecture/architecture-cohesion-review.md:181:**Boundary:** Composio and AgentMail are NEVER referenced in `agent.md`, `tools.yaml`, vault files, or fixtures.
docs/architecture/architecture-cohesion-review.md:185:- **Q:** Are there any references to Composio/AgentMail in agent.md or tools.yaml?
docs/architecture/architecture-cohesion-review.md:187:- **Q:** Could a future agent silently introduce a Composio or AgentMail tool?
docs/architecture/architecture-cohesion-review.md:199:  - **A:** Helpers write to `/vault/<tenant>/decision-log.jsonl` (fallback mode) — that's structured. BUT it's an audit trail that replays into Postgres, not the source of truth. Vault `_voice/`, `_config/`, `_brand/`, `_playbooks/` are content (markdown). Vault `spot-checks/` is markdown notes. Vault `_secrets.env` is config (Path D). ✓ Mostly clean.
docs/architecture/architecture-cohesion-review.md:202:  - **A:** `recent_edit.original_text` + `edited_text` are narrative (raw text). `tone_rule.rule_text` is natural language. `voice_corpus_chunks.text_chunk` is text. **These ARE narrative content in Postgres** — but they're indexed for retrieval, not for primary storage. The vault remains the source of truth for the original docs; Postgres holds the indexable chunked + classified copy. ✓ Acceptable hybrid.
docs/architecture/architecture-cohesion-review.md:213:  - **A:** `packages/agent-renderer/`, `agents/_shared/`, hook-helpers, voice-loader — none reference cortextOS KB at all. They write to IFOS-side Postgres + vault. ✓
agents/recruitment/diagnostic/validate.sh:12:# validate.sh exits non-zero and emits an ESC_* escalation row to
agents/recruitment/diagnostic/validate.sh:25:#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts
agents/recruitment/diagnostic/validate.sh:31:#   V3 — Section 12 voice classifier score ≥ 0.75
agents/recruitment/diagnostic/validate.sh:128:# V3 — §12 voice classifier ≥ 0.75
agents/recruitment/diagnostic/validate.sh:148:      _pass "V3: §12 voice classifier score=${SCORE} (≥ 0.75)"
agents/recruitment/diagnostic/validate.sh:150:      _fail "V3: §12 voice classifier score=${SCORE} (< 0.75)"
agents/recruitment/diagnostic/validate.sh:153:    _warn "V3: IFOS_VOICE_CLASSIFIER_URL unset; voice classification SKIPPED (W3 build wires this)"
agents/recruitment/diagnostic/validate.sh:207:# At W3 build: extract firm domain from Companies House link to scope
agents/recruitment/diagnostic/validate.sh:233:  # Emit ESC_SCHEMA_VIOLATION row to decision_log with the failure list
agents/recruitment/diagnostic/validate.sh:234:  ESC_PAYLOAD=$(printf '{"escalation_code":"ESC_SCHEMA_VIOLATION","draft_path":"%s","failures":%s}' \
agents/recruitment/diagnostic/validate.sh:239:    "$(echo "${ESC_PAYLOAD}" | shasum | awk '{print $1}')" \
agents/recruitment/diagnostic/validate.sh:240:    "${ESC_PAYLOAD}" 2>/dev/null || true
packages/agent-renderer/src/synthesis/configJson.ts:26:    "common-voice.json",
docs/decisions/ADR-003-agent-bundle-renderer.md:13:ADR-002 §1.7-A surfaced the spec gap. Master brief §8 (lines 545-568) specifies the IFOS Agent Bundle v2 — six files plus three fixtures at `agents/recruitment/<name>/` — but is silent on how the bundle becomes a runnable cortextOS agent. The cortextOS daemon's `AgentManager.discoverAndStart()` (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`) reads from `${frameworkRoot}/orgs/<org>/agents/<name>/` with a cortextOS-shaped layout (`config.json`, `CLAUDE.md`, `.env`). The two layouts are incompatible without translation.
docs/decisions/ADR-003-agent-bundle-renderer.md:31:Per design §3.1: TypeScript Node. Tooling matched against `packages/harness/cortextos/package.json:11-13` for consistency:
docs/decisions/ADR-003-agent-bundle-renderer.md:78:> mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext}
docs/decisions/ADR-003-agent-bundle-renderer.md:91:> mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
docs/decisions/ADR-003-agent-bundle-renderer.md:102:> mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:156:- **`_shared/` helper code authoring** (`voice-loader.sh`, `hook-helpers.sh` contents) — already on the Week-1 prerequisite list per ADR-002 §"For Week 1 work." Not an ADR; just implementation work.
packages/harness/cortextos/community/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/community/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
agents/recruitment/diagnostic/context.sh:7:# Reading order: agent.md §4 Step 0 (session start) + §7 (voice + tone) first.
agents/recruitment/diagnostic/context.sh:10:# the first workflow step runs. Per master brief §8.1 Change 1: load voice
agents/recruitment/diagnostic/context.sh:19:#       CTX_AGENT_NAME=diagnostic
agents/recruitment/diagnostic/context.sh:21:#       CTX_VOICE_CORPUS_ID   active corpus id from voice_corpus table
agents/recruitment/diagnostic/context.sh:24:#   - Sources _shared/hook-helpers.sh + _shared/voice-loader.sh
agents/recruitment/diagnostic/context.sh:28:#   - Missing tenant_slug → exit 1 with ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/context.sh:29:#   - Missing voice corpus → exit 1 with ESC_VOICE_DRIFT (no fallback for
agents/recruitment/diagnostic/context.sh:31:#   - target_patch unreachable → exit 1 with ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/context.sh:35:CTX_AGENT_NAME="diagnostic"
agents/recruitment/diagnostic/context.sh:71:source "${_SHARED_DIR}/voice-loader.sh"
agents/recruitment/diagnostic/context.sh:83:hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
agents/recruitment/diagnostic/context.sh:122:# 3 — Load voice corpus active row
agents/recruitment/diagnostic/context.sh:125:# Used in §4 Step 9 (conversation opener voice classification). The voice
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:138:  printf 'context.sh: No active voice corpus for tenant %s\n' "${CTX_TENANT_SLUG}" >&2
agents/recruitment/diagnostic/context.sh:144:# 4 — Load tone rules (filtered to diagnostic agent)
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:157:# 5 — Load recent_edits (voice drift signal)
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:173:printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:5:**Companion:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:17:| 1-2 | Renderer + `_shared/` + voice corpus + schema v0.2 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:19:| 4 | **Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint** per ULTRAPLAN line 753 |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:28:- **Week 1-2 work landed early** (Day 8, commits a279226 → fe56e93). Renderer + `_shared/` + v0.2 schema + voice corpus all live + ratified.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:41:| W3 Days 13-20: Bullhorn MCP server build | W3 Days 13-20: Diagnostic end-to-end (per `goal-option-c-diagnostic-end-to-end.md`) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:48:2. **The Week-4 milestone is achievable today.** ULTRAPLAN line 755: *"Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."* Option C produces exactly this; the dependencies (LinkedIn + Companies House + scrape) are independent of Bullhorn.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:58:- ✅ Web scraper + Companies House MCP connector + diagnostic-generator package shipped Day 13 (commits `800a265`, `860f29c`, `5614dcb`, `fd38254`)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:60:- ⏸ Step 7 (real-firm smoke run against founder's choice) pending: Companies House API key registration + firm name
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:85:- Q1 LOI gate (Jack's lane; Trigger 1 fires 2026-06-03 if no LOI)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:94:| Companies House connector + 13/13 tests | ✅ | `5614dcb` |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:95:| diagnostic-generator package + cycle.sh wiring | ✅ | `fd38254` |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:98:| Companies House API key registration | ⏸ Founder | — |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:111:- `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:119:| LinkedIn deep data via Proxycurl: now or W4? | Day-13 founder pick: Option A (free unauthenticated path) for v0; Proxycurl evaluated W4 polish |
docs/architecture/agent-bundle-renderer-design.md:35:        └── 99-voice-drift-canary/      # NEW IN V2 — every agent has one.
docs/architecture/agent-bundle-renderer-design.md:44:| `config.schema.json` (line 553) | Per-tenant JSON Schema, extending `common-*.json` shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) | the renderer (materialises to `config.json` per §2.1); per-tenant onboarding wizard at Product Spec §5.2 Day 4 fills schema fields | **Static schema; dynamic materialisation** per tenant |
docs/architecture/agent-bundle-renderer-design.md:45:| `tools.yaml` (line 554) | MCP servers + scopes + degraded modes for external execution backends (Bullhorn, Companies House, Microsoft Graph etc. per master brief §3.2 first-party MCP list) | the renderer (passes through to rendered agent dir); agent uses it via Claude Code's MCP loading at PTY spawn time | **Static** — founder writes once per agent |
docs/architecture/agent-bundle-renderer-design.md:47:| `context.sh` (line 556) | Hydrates CONTEXT via the context-assembly API (master brief §9 data layer diagram). Calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits` from `_shared/voice-loader.sh` (master brief §8.1 Change 1) | invoked by the agent itself at session start to assemble its working context | **Static** — founder writes once |
docs/architecture/agent-bundle-renderer-design.md:50:| `tests/fixtures/99-voice-drift-canary/` (line 565) | Same input, run weekly in CI, output diffed against historical baselines (master brief §8.1 Change 1 framing context). New in v2. | weekly CI cron; voice classifier (Ultraplan §6.2) scores drift | **Static fixture; dynamic comparison** week-over-week |
docs/architecture/agent-bundle-renderer-design.md:55:- **§1.1-B:** master brief §8.1 mentions `_shared/hook-helpers.sh` and `_shared/voice-loader.sh` but does not specify where `_shared/` lives in the rendered output. The bundle's `validate.sh` and `context.sh` `source` these helpers — the renderer needs to materialise the path. Recommended resolution: place `_shared/` at `${projectRoot}/orgs/<org>/agents/_shared/` (one per org, symlinked into every agent dir's `.claude/hooks/_shared/`); rendered hook scripts source via `${CTX_AGENT_DIR}/.claude/hooks/_shared/<helper>.sh`.
docs/architecture/agent-bundle-renderer-design.md:61:**Discovery mechanism** (`packages/harness/cortextos/src/daemon/agent-manager.ts:906-941` `discoverAgents()`):
docs/architecture/agent-bundle-renderer-design.md:109:| `agents/recruitment/<name>/agent.md` | `orgs/<org>/agents/<name>/CLAUDE.md` | **Synthesis** | (1) `agent.md` body verbatim; (2) **cortextOS preamble template** — spec gap §2.1-A; (3) per-tenant footer (resolved tenant_slug, current `_voice/style-guide.md` path, decision_log Postgres role); (4) hook invocation block referencing `.claude/hooks/{validate,context}.sh` paths | Lint pass: no unresolved `{{tenant_slug}}` / `{{...}}` placeholders survive; preamble matches the renderer's canonical preamble version (hash check); CLAUDE.md is non-empty and parses as valid markdown |
docs/architecture/agent-bundle-renderer-design.md:110:| `agents/recruitment/<name>/config.schema.json` | `orgs/<org>/agents/<name>/config.json` | **Synthesis** | (1) `config.schema.json` (the JSON Schema itself, used for validation); (2) `/vault/{tenant-slug}/_config.yaml` per Ultraplan §5.1 line 220 (provides per-tenant values that fill schema fields); (3) bundle-level defaults from any `default` keys in the schema; (4) common-*.json shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) — spec gap §2.1-B on where common schemas live | Materialised JSON validates clean against the source schema using Ajv (or equivalent) before the renderer writes; required fields all populated; no extra fields beyond schema. Daemon-required fields (per §1.2): `enabled` defaults true, `runtime` defaults `claude-code`, `max_session_seconds` defaults 255600, `working_directory` defaults to the rendered agent dir |
docs/architecture/agent-bundle-renderer-design.md:115:| `agents/recruitment/<name>/tests/fixtures/{01-primary,02-edge-case-*,99-voice-drift-canary}/` | **Not rendered** | **Stays in source** | n/a | n/a — fixtures live in the IFOS repo at `agents/recruitment/<name>/tests/fixtures/`; CI fixture runner (master brief §8.3 line 628) reads them there; runtime does not need them |
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:125:- **§2.1-C:** Ultraplan §5.1 line 220 names `_voice/`, `_playbooks/`, `_decisions/`, `_config.yaml` under `/vault/{tenant}/` but does not enumerate `_secrets.env`. Recommended resolution: add `_secrets.env` to the per-tenant vault skeleton; created at tenant provisioning (Ultraplan §5.5 line 263 `provision-tenant.sh {slug}` step 2). Mode `0600` owned by `ifos-tenant-{slug}`. Per Master Brief §3.3 "structured data lives in Postgres" applies to entity data; per-tenant *secrets* are the canonical exception that lives on the filesystem.
docs/architecture/agent-bundle-renderer-design.md:129:**The renderer does NOT copy `packages/harness/cortextos/templates/agent/.claude/skills/`.** None of the 24 cortextOS-template skills land in the IFOS agent's rendered directory.
docs/architecture/agent-bundle-renderer-design.md:134:- **Master brief §1 Rule 3 (Reuse before build)** — "Every agent uses `agents/_shared/` modules… No agent writes its own logging, voice handling, or approval gate." `_shared/` is the IFOS reuse surface. Inheriting a parallel reuse surface (cortextOS's `.claude/skills/`) creates two reuse vocabularies — confusing and error-prone.
docs/architecture/agent-bundle-renderer-design.md:149:`activity-channel`, `agent-browser`, `agent-management`, `auto-skill`, `autoresearch`, `bus-reference`, `comms`, `cron-management`, `env-management`, `event-logging`, `guardrails-reference`, `human-tasks`, `m2c1-worker`, `onboarding`, `soul-philosophy`, `system-diagnostics`, `tool-registration`, `worker-agents` — 18 above, plus the `memory-management` skill referenced from `agent/.claude/skills/onboarding/SKILL.md:42` that I haven't catalogued individually.
docs/architecture/agent-bundle-renderer-design.md:151:The blanket position: **per-skill opt-in is deferred to per-agent bundle authoring.** Each IFOS bundle's `tools.yaml` may reference cortextOS-template skills it wants to inherit explicitly; the renderer reads the opt-in list, materialises only those skills into `.claude/skills/<name>/` in the rendered output, and copies the source `SKILL.md` from `packages/harness/cortextos/templates/agent/.claude/skills/<name>/`. **Default is exclusion. Opt-in is the only mechanism.** This is the structural opposite of `cortextos-ifos add-agent`, which default-includes all 24.
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:180:    └── 99-voice-drift-canary/
docs/architecture/agent-bundle-renderer-design.md:189:check-in missed, every comms in firm voice.
docs/architecture/agent-bundle-renderer-design.md:192:Every lifecycle event → draft within 30 minutes, voice score ≥ 0.75, correct
docs/architecture/agent-bundle-renderer-design.md:207:  within 30 minutes in firm voice (classifier score ≥ 0.75), addressed to
docs/architecture/agent-bundle-renderer-design.md:209:voice_anchors:
docs/architecture/agent-bundle-renderer-design.md:210:  - "_voice/style-guide.md"
docs/architecture/agent-bundle-renderer-design.md:211:  - "_voice/samples (3 nearest neighbors via voice-loader)"
docs/architecture/agent-bundle-renderer-design.md:215:  - voice_classifier_score >= 0.75
docs/architecture/agent-bundle-renderer-design.md:219:  - ESC_VOICE_DRIFT
docs/architecture/agent-bundle-renderer-design.md:220:  - ESC_PII_LEAKAGE_RISK
docs/architecture/agent-bundle-renderer-design.md:221:  - ESC_DUPLICATE_DETECTED
docs/architecture/agent-bundle-renderer-design.md:233:3. Load voice context via `hh_load_tone_rules` + `hh_load_voice_samples
docs/architecture/agent-bundle-renderer-design.md:245:    { "$ref": "common-voice.json" },
docs/architecture/agent-bundle-renderer-design.md:270:        "ESC_VOICE_DRIFT": { "type": "string", "format": "telegram-chat-id" }
docs/architecture/agent-bundle-renderer-design.md:311:# Banned-phrase + length + voice classifier + schema + PII checks
docs/architecture/agent-bundle-renderer-design.md:320:source "${CTX_AGENT_DIR}/.claude/hooks/_shared/voice-loader.sh"
docs/architecture/agent-bundle-renderer-design.md:323:hh_load_voice_samples --n 3 --task-type "${TASK_TYPE:-candidate-acknowledgement}"
docs/architecture/agent-bundle-renderer-design.md:349:The org-level `_shared/` resolves to `orgs/acme/agents/_shared/`, containing `hook-helpers.sh`, `voice-loader.sh`, `escalation-codes.md`, `common-*.json` schemas. The `_shared/` origination question (founder's carry-forward from §1) is addressed in §3.3.
docs/architecture/agent-bundle-renderer-design.md:381:- Voice anchor: /vault/acme/_voice/style-guide.md (importance threshold 0.75)
docs/architecture/agent-bundle-renderer-design.md:392:PII is a `ESC_PII_LEAKAGE_RISK` escalation. Voice samples and tone rules in
docs/architecture/agent-bundle-renderer-design.md:393:`/vault/acme/_voice/`. Decision log writes go to Postgres role
docs/architecture/agent-bundle-renderer-design.md:423:    "ESC_VOICE_DRIFT": "<acme operator chat id from _secrets.env>"
docs/architecture/agent-bundle-renderer-design.md:465:Rationale: matches existing IFOS package convention. Master brief §4.1 line 195-204 enumerates the operative package directories (`packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}/`); the renderer is a distinct concern (bundle → runtime translation) that doesn't belong inside any of those. It's not the brain (wiki content, per ADR-002), not the harness (read-only submodule per master brief §3.1), not agents-runtime/_shared/ (the shared helper *content*, not the *tooling* that materialises agents). Standalone `packages/agent-renderer/` keeps the surface clean.
docs/architecture/agent-bundle-renderer-design.md:467:Tooling stack chosen for cortextOS consistency (verified against `packages/harness/cortextos/package.json`):
docs/architecture/agent-bundle-renderer-design.md:540:- **Schema refs:** `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` per spec gap §2.1-B and Ultraplan §5.3 line 357-364.
docs/architecture/agent-bundle-renderer-design.md:550:1. IFOS repo is the canonical source: `agents/_shared/{voice-loader.sh, hook-helpers.sh, escalation-codes.md, common-*.json, ...}`.
docs/architecture/agent-bundle-renderer-design.md:638:**Escalation:** `ESC_RENDERER_FAILED` row written to `decision_log` Postgres table with `agent_name='_renderer'`, `phase='gating_failed'`, `payload->>'reason'='schema-validation-failure'`. (`phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — see ADR-004 Decision 7; the 5-value enum is `trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 schema migration.) If `--notify-on-failure` (default true), Telegram message to the operator with the validation path.
docs/architecture/agent-bundle-renderer-design.md:642:**Detection:** Preflight check — before any writes, renderer verifies the source paths referenced by `agents/_shared/` are present and contain expected entry points (`voice-loader.sh`, `hook-helpers.sh`, `common-*.json`).
docs/architecture/agent-bundle-renderer-design.md:648:**Escalation:** same `ESC_RENDERER_FAILED` row; reason field `shared-helpers-missing`.
docs/architecture/agent-bundle-renderer-design.md:658:**Escalation:** `ESC_RENDERER_FAILED`; reason `bundle-malformed`.
docs/architecture/agent-bundle-renderer-design.md:668:**Escalation:** `ESC_RENDERER_FAILED`; reason `tenant-not-provisioned`.
docs/architecture/agent-bundle-renderer-design.md:704:- **`ESC_RENDERER_FAILED`** — renderer exited non-zero. Carries `reason` substring (`schema-validation-failure`, `bundle-malformed`, `shared-helpers-missing`, `tenant-not-provisioned`, `atomic-rename-failed`, `non-rendered-target`).
docs/architecture/agent-bundle-renderer-design.md:708:- **Audit log:** Postgres `decision_log` row with `tenant_slug`, `agent_name='_renderer'`, `phase='gating_failed'` (failures) or `phase='action'` (successful renders), `payload->>'reason'` carries the reason code. RLS-isolated per tenant. Codex's Day-7 ratification report queries this table for all rows where `agent_name='_renderer' AND payload->>'reason' LIKE 'ESC_RENDERER_FAILED%'`. (Per ADR-004 Decision 7: `phase='render'` was named in earlier drafts but is NOT in the live CHECK enum — use the 5-value enum from Day-4 §6.3 + Day-5 schema migration.)
docs/architecture/agent-bundle-renderer-design.md:718:The cortextOS `cortextos-ifos add-agent` command (`packages/harness/cortextos/src/cli/add-agent.ts:18-316`) is **unchanged**. IFOS does **not** use it for IFOS-owned agents. The R2 commitment per ADR-002 §1.7-A drives this.
docs/architecture/agent-bundle-renderer-design.md:760:| `packages/agents-runtime/_shared/{voice-loader,hook-helpers}.sh` (per ADR-002 prerequisite) | Claude Code | Weeks 1-2 |
docs/architecture/agent-bundle-renderer-design.md:761:| `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` (per spec gap §2.1-B) | Claude Code | Weeks 1-2 |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/agent-bundle-renderer-design.md:775:**Current** (master brief §4.1 line 195-204): "Create the operative directory structure" followed by an `mkdir -p` command listing `packages/{harness, brain, agents-runtime, vertical-adapters, mcp-connectors, context-assembly, decision-log, vault-syncer, voice, onboarding-wizard, dashboard-ext}`.
docs/architecture/agent-bundle-renderer-design.md:780:mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:19:The Day-1 cortextOS primitive audit (`docs/architecture/cortexos-primitive-status.md` — Primitive 3) surfaced that **none of those four files exist at SHA `c21fbfe`**. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. Reading `kb-setup.sh` revealed the substrate underneath: `mmrag.py` over ChromaDB with Gemini embeddings and 1000-char chunks (`docs/architecture/cortexos-kb-surface-investigation.md` §"What is cortextOS's KB substrate"). That data model is incompatible with the IFOS wiki's entity-document model in master brief §5.2.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:27:cortextOS's `bus/kb-*.sh` surface and the `mmrag.py` / ChromaDB / Gemini stack at `packages/harness/cortextos/knowledge-base/` remain **untouched**. IFOS agents do **not** invoke `kb-query`, `kb-ingest`, `kb-collections`, or `kb-setup`. The §3.1 "edit-exception for four `bus/kb-*.sh` shadow points" in the master brief becomes a **dead clause**: there is no shadowing, the exception is never exercised, and §3.1's "never edit `packages/harness/cortextos/*`" stands without qualifier.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:64:- **pgvector index (v1.0):** `voice_samples_embedded` only — embedding model `gemini-embedding-001` (3072 dimensions), matching cortextOS's KB substrate for forward-compatibility per design §2.4.3.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:81:**Current** (master brief §3.4 line 167-176): "We replace the stock knowledge base without forking by **shadowing the four `bus/kb-*.sh` shell entry points**. … 1. Vendored copy at `packages/harness/cortextos/bus/kb-*.sh` is left untouched. 2. Our overrides live at `packages/brain/bus-overrides/kb-*.sh`. 3. PM2 `ecosystem.config.js` sets `PATH` so our overrides are picked up first…"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:83:**Proposed:** "IFOS implements its second brain as a **parallel system**, not by shadowing cortextOS's stock knowledge base. cortextOS's `bus/kb-*.sh` files (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh` at SHA `c21fbfe`) remain untouched and continue to serve cortextOS-template agents. IFOS agents invoke a parallel wrapper surface at `packages/brain/bus-overrides/wiki-*.sh` (9 v1.0 + 1 v1.1 stub) that dispatches to `packages/brain/wiki/lib/` against Postgres + filesystem markdown. The §3.1 'four `bus/kb-*.sh` shadow points' edit-exception is unused — IFOS does not edit any file under `packages/harness/cortextos/`. See `docs/architecture/second-brain-design.md` for the full design."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:93:> "v1.0 minimum (weeks 11-13) — 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; no Brain UI yet. Total v1.0 effort ~11-13 person-days. v1.1 adds `wiki-find.sh` + `wiki-history.sh` + Brain UI today-view and backlinks panel."
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:109:**For the v1.0 brain build (weeks 11-13).** Reference `second-brain-design.md` §3.4 closing paragraph. Weeks 11-13 hold; scope is materially clarified (9 wrappers + 9 library modules + 4 tables + pgvector voice index vs. the original "shadow four files + 2 .ts files" framing). v1.0 effort estimated at 11-13 person-days, fitting the 15-day budget.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:115:3. **`agents/_shared/{voice-loader,hook-helpers}.sh`** per master brief §8.1 Change 1 + Change 2. The wiki library invokes `hh_decision_*` from `hook-helpers.sh` for every operation; `voice-loader.sh` calls `wiki/lib/search.ts` against `voice_samples_embedded`. Lands Week 1-2.
agents/recruitment/concierge/README.md:20:- `tools.yaml` — Bullhorn R+W + Microsoft Graph + Gmail + voice classifier + autosend bridge (per D1 outcome)
agents/recruitment/concierge/README.md:21:- `context.sh` — multi-source auth + voice corpus + comms-template library + addressee-resolution data
agents/recruitment/concierge/README.md:22:- `validate.sh` — Gate A (SLA 30 min + voice ≥0.75 per-position + addressee + tone-rule + PII + anti-duplicate) — most complex validator of v1.0
agents/recruitment/concierge/README.md:26:- `fixtures/02-edge-case-rejection.yaml` — position-3 voice ≥0.82 test
docs/architecture/cortexos-kb-surface-investigation.md:4:**Audited SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383` (`packages/harness/cortextos/` reference pin)
docs/architecture/cortexos-kb-surface-investigation.md:12:Day-1 audit of cortextOS Primitive 3 (`docs/architecture/cortexos-primitive-status.md`) surfaced that master brief §3.4 names four shadow files (`kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`) that **do not exist** at the verified SHA. The real files at `packages/harness/cortextos/bus/` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`.
docs/architecture/cortexos-kb-surface-investigation.md:42:Captured verbatim from the Day-1 audit (`packages/harness/cortextos/bus/kb-setup.sh`, full file 121 lines).
agents/recruitment/concierge/agent.md:6:**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
agents/recruitment/concierge/agent.md:16:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Drafts are orange-tier per `autosend-safety-policy.yaml` — consultant approval required before send via the autosend-bridge mechanism (Founder Decision D1 path A bridge OR D1-B shim OR D1-C manual; W10 design selects). Sends route via tenant's Microsoft Graph OR Gmail (per-tenant config; AgentMail deferred to v1.1+). Gate A hard-fails any draft generated >30 minutes after lifecycle event, any draft with voice classifier <0.75, or any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). Gate B success threshold: <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts (per ULTRAPLAN A6 line 567). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:59:- AgentMail integration (agent-identity sends for non-rejection comms)
agents/recruitment/concierge/agent.md:93:subject: <subject line; voice-classified>
agents/recruitment/concierge/agent.md:94:body_markdown: <body; voice-classified>
agents/recruitment/concierge/agent.md:95:voice_score: <0-1>
agents/recruitment/concierge/agent.md:102:Each draft: `decision_log` row with `agent_name='concierge'`, `phase='action'`, `action_type='concierge_draft_<event_type>'`, `tier='orange'`, payload includes voice_score + recipient + escalation_position.
agents/recruitment/concierge/agent.md:115:     Microsoft Graph / Gmail auth + AgentMail (if v1.1+ enabled) +
agents/recruitment/concierge/agent.md:116:     voice corpus + tone rules + recent_edits + tenant comms-template
agents/recruitment/concierge/agent.md:127:   → ESC_LIFECYCLE_STATE_UNKNOWN if state transition not in 12-event taxonomy
agents/recruitment/concierge/agent.md:140:   → ESC_BULLHORN_RATE_LIMIT on 429; ESC_BULLHORN_AUTH on auth fail
agents/recruitment/concierge/agent.md:141:   → ESC_CANDIDATE_DATA_INCOMPLETE if critical fields missing (no email,
agents/recruitment/concierge/agent.md:149:   → ESC_ADDRESSEE_MISMATCH if check fails (blocking); draft aborted
agents/recruitment/concierge/agent.md:159:     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
agents/recruitment/concierge/agent.md:163:   → prompt = (event context + candidate state history + voice corpus
agents/recruitment/concierge/agent.md:167:   → ESC_VOICE_DRIFT if classifier <0.75 after 3 retries
agents/recruitment/concierge/agent.md:170:   → voice classifier scores the draft
agents/recruitment/concierge/agent.md:175:   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
agents/recruitment/concierge/agent.md:179:   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
agents/recruitment/concierge/agent.md:187:    → ESC_PII_LEAKAGE_RISK on hit (blocking)
agents/recruitment/concierge/agent.md:195:    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within 24h (D1-A/B)
agents/recruitment/concierge/agent.md:200:    → ESC_SEND_FAIL on 4xx/5xx; retry once 30s backoff
agents/recruitment/concierge/agent.md:218:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:232:- **"voice classifier score ≥ 0.75"** (per position; position-3 sensitive sends ≥0.82)
agents/recruitment/concierge/agent.md:239:Gate A failures fire `ESC_SCHEMA_VIOLATION` or `ESC_ADDRESSEE_MISMATCH` or `ESC_TONE_RULE_VIOLATION` (all blocking); draft to `/tmp`; operator notified immediately.
agents/recruitment/concierge/agent.md:249:Gate B doesn't block individual sends. Tracked monthly via the tenant's day-30 metrics roll-up. Both metrics below target for 30 consecutive days → `ESC_GATE_B_MISS` → founder + operator review (likely indicates LLM drift, lifecycle-event detection gaps, OR tenant-specific style mismatch).
agents/recruitment/concierge/agent.md:259:| `ESC_BULLHORN_AUTH` | OAuth refresh fails | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:260:| `ESC_BULLHORN_OAUTH_REVOKED` | 6+ consecutive auth failures | **blocking** | founder + ifos_oncall + tenant-admin |
agents/recruitment/concierge/agent.md:261:| `ESC_BULLHORN_RATE_LIMIT` | 429 from Bullhorn | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:262:| `ESC_MS_GRAPH_AUTH` / `ESC_GMAIL_AUTH` | Email-provider auth fail | **blocking** | operator + ifos_oncall + tenant-admin (token re-auth required) |
agents/recruitment/concierge/agent.md:263:| `ESC_LIFECYCLE_STATE_UNKNOWN` | Bullhorn state transition not in 12-event taxonomy | warn (handler logs + skips draft) | operator_chat_id |
agents/recruitment/concierge/agent.md:264:| `ESC_CANDIDATE_DATA_INCOMPLETE` | Missing email / name in Bullhorn entity | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:265:| `ESC_ADDRESSEE_MISMATCH` | Step 4 critical — wrong recipient | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:266:| `ESC_VOICE_DRIFT` | Voice classifier below position-specific threshold after 3 retries | warn (position 1-2) or **blocking** (position 3) | operator_chat_id (1-2) / operator + ifos_oncall (position 3) |
agents/recruitment/concierge/agent.md:267:| `ESC_TONE_RULE_VIOLATION` | Block-severity tone rule hit | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:268:| `ESC_PII_LEAKAGE_RISK` | PII outside firm boundary | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:269:| `ESC_CONCIERGE_SLA_MISS` | Draft >30 min after lifecycle event | warn | (logged; aggregated to Gate B) |
agents/recruitment/concierge/agent.md:270:| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within 24h | warn | operator + tenant-admin |
agents/recruitment/concierge/agent.md:271:| `ESC_SEND_FAIL` | Email provider 4xx/5xx | warn | operator_chat_id |
agents/recruitment/concierge/agent.md:272:| `ESC_AUTOSEND_BLOCKED` | Send attempted on red-tier action OR Gate A failed | **blocking** | operator + ifos_oncall |
agents/recruitment/concierge/agent.md:273:| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% for 30 consecutive days | warn | founder + operator |
agents/recruitment/concierge/agent.md:274:| `ESC_VOICE_DRIFT_TENANT` | Cross-30-day consultant edit-rate >50% | warn | operator + tenant-admin |
agents/recruitment/concierge/agent.md:275:| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info) | info | (logged) |
agents/recruitment/concierge/agent.md:276:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Orange-tier sample row selected for audit | info | operator_chat_id |
agents/recruitment/concierge/agent.md:284:Steps 7-8 (draft generation + voice/tone validation) are the load-bearing voice surface of v1.0. The agent integrates with `_shared/voice-loader.sh`:
agents/recruitment/concierge/agent.md:293:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
agents/recruitment/concierge/agent.md:294:- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal at tenant level. Edit-distance >150 chars on >40% of recent_edit rows → ESC_VOICE_DRIFT_TENANT → tenant-admin reviews voice corpus + tone rules.
agents/recruitment/concierge/agent.md:297:- Position 1 (standard sends — acknowledgement, prep, debrief, nurture): voice ≥0.75
agents/recruitment/concierge/agent.md:298:- Position 2 (placement-positive, status-update): voice ≥0.78
agents/recruitment/concierge/agent.md:299:- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 line 570 explicitly names rejection voice as the hardest case)
agents/recruitment/concierge/agent.md:301:Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
agents/recruitment/concierge/agent.md:350:| Q4 | Rejection emails (event 6) — Position 3 (voice ≥0.82). Is this enough, or should rejections route to consultant for full draft (not just approve)? | Founder review with first pilot consultant. Recommend: Concierge drafts; consultant approves; never bypasses voice gate. |
agents/recruitment/concierge/agent.md:354:| Q8 | AgentMail (v1.1+) — agent-identity sends. Should Concierge use AgentMail for rejection emails (less personal pressure on consultant approving) or always tenant-identity? | v1.0: tenant-identity (Microsoft Graph / Gmail). v1.1+: AgentMail experiment per tenant opt-in. |
agents/recruitment/concierge/agent.md:356:| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
agents/recruitment/concierge/agent.md:363:4. **Microsoft Graph vs Gmail per-tenant** — each tenant chooses based on their existing email stack. v1.0 supports both; v1.1+ may add AgentMail.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:19:- `grep -rn chokidar packages/harness/cortextos/src/` returns **zero** hits.
docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md:20:- `chokidar@^5.0.0` in `packages/harness/cortextos/package.json:47` is real, but `grep -rn chokidar packages/harness/cortextos/` shows the only application code use is `packages/harness/cortextos/dashboard/src/lib/watcher.ts:5` (`import { watch, type FSWatcher } from 'chokidar';`) — the **dashboard UI's file-change feed**, not the inter-agent bus.
docs/architecture/cortexos-primitive-status.md:5:**Audited SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383` (`packages/harness/cortextos/` reference pin, per `packages/harness/PINNED-SHA.md`)
docs/architecture/cortexos-primitive-status.md:44:- `packages/harness/cortextos/src/pty/agent-pty.ts:31-189` — `AgentPTY` class. Lazy-loads `node-pty` at line 59-61 (`const nodePty = require('node-pty'); this.spawnFn = nodePty.spawn;`), spawns the `claude` binary directly in a 200×50 xterm-256color PTY at line 146-152, wires `onData` → `OutputBuffer` and `onExit` → handler, and includes the "trust this folder?" auto-accept at lines 173-188 (sends `\r` at 5s and 8s after spawn).
docs/architecture/cortexos-primitive-status.md:45:- `packages/harness/cortextos/src/daemon/agent-process.ts:21-720` — `AgentProcess` orchestrates the full lifecycle. Notable hardening visible in the code: BUG-040 lifecycle-generation guard (`agent-process.ts:111` and `:142-146`), BUG-032 CRLF + 5s wait on `/exit` graceful shutdown (`:227-231`), BUG-011 exit-promise race fix (`:133-152, :248-256`), BUG-048 stale-config session-timer re-read (`:611-636`). Crash recovery uses exponential backoff capped at 5 minutes (`:437`), `max_crashes_per_day` default 10 (`:28`), halts the agent after exceeded.
docs/architecture/cortexos-primitive-status.md:46:- `packages/harness/cortextos/src/daemon/index.ts:30-214` — daemon-level crash plumbing. `recordCrash` / `shouldSendCrashLoopAlert` / `writeDaemonCrashedMarkers` form the crash-loop detector (3 crashes in 15 min triggers a Telegram alert with 30-min cooldown, `:34-36`). PM2's `max_restarts: 10` in `ecosystem.config.js:47` is the circuit breaker beyond it.
docs/architecture/cortexos-primitive-status.md:47:- `packages/harness/cortextos/ecosystem.config.js:14-51` — daemon script entry, env-driven, `autorestart: true`, `max_restarts: 10`, `restart_delay: 5000`. The 35-line comment block above `max_restarts` explicitly names the 2026-04-22 storm and warns against raising the values without strengthening the upstream fix.
docs/architecture/cortexos-primitive-status.md:48:- `packages/harness/cortextos/package.json:48` — `node-pty: ^1.1.0` runtime dep; `engines.node: ">=20.0.0"`.
docs/architecture/cortexos-primitive-status.md:62:- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
docs/architecture/cortexos-primitive-status.md:64:- v1.1: A7 Inbound Triage, A10 Competitor Interception, A11 Night Sourcer (with primitive 6), A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all require it.
docs/architecture/cortexos-primitive-status.md:121:- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
docs/architecture/cortexos-primitive-status.md:122:- v1.1+: A7 Inbound Triage, A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all carry per-entity state across many days.
docs/architecture/cortexos-primitive-status.md:124:**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."
docs/architecture/cortexos-primitive-status.md:184:2. **The four `kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 lists `kb-search.sh`, `kb-add.sh`, `kb-update.sh`, `kb-list.sh`. The actual files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. This is the brain-replacement seam — the master brief's named files do not exist at SHA `c21fbfe`. Either the brief was written against a different cortextOS version, or the four shadow points need to be revised. This is a Day-7 Codex-ratification-blocking discrepancy.
docs/architecture/cortexos-primitive-status.md:189:- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.
docs/architecture/cortexos-primitive-status.md:219:diff <(ls packages/harness/cortextos/bus/kb-*.sh | xargs -n1 basename) \
docs/architecture/cortexos-primitive-status.md:257:- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."
docs/architecture/cortexos-primitive-status.md:284:  packages/harness/cortextos/src/
docs/architecture/cortexos-primitive-status.md:303:- `src/telegram/transcribe.ts` (137 lines) + `src/telegram/media.ts` (217 lines) — voice-note transcription and image/document handling — past the "approval surface" minimum but indicates the surface is production-grade for general agent comms.
docs/architecture/cortexos-primitive-status.md:358:grep -rn "apns\|push.notification" packages/harness/cortextos/src/   # zero hits
docs/architecture/cortexos-primitive-status.md:359:grep -rn "outbound-messages.jsonl" packages/harness/cortextos/src/   # one hit at cli/bus.ts:1644
docs/architecture/cortexos-primitive-status.md:390:- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
docs/architecture/cortexos-primitive-status.md:393:**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").
docs/architecture/cortexos-primitive-status.md:457:- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
docs/decisions/sequencing-target.md:9:**Reading order:** master brief §8.2 (the build-order table) + Ultraplan §9 (the existing 14-week sprint plan) first; then this document end-to-end; then `docs/decisions/bullhorn-integration-path.md` §4.1 + §6 for the Bullhorn-dependency carry-forward; then `docs/decisions/ADR-003-agent-bundle-renderer.md` §5.2 for the renderer's Week-1-prerequisite role.
docs/decisions/sequencing-target.md:17:Master brief §8.2 (lines 597-611) names six v1.0 agents and assigns build weeks:
docs/decisions/sequencing-target.md:19:| # | Agent | Weeks (master brief §8.2) | Key dependency | Why this order (master brief verbatim) |
docs/decisions/sequencing-target.md:21:| A1 | Diagnostic | 3-4 | LinkedIn + Companies House + scrape | "Sales tool — needed before any other agent matters" |
docs/decisions/sequencing-target.md:26:| A6 | Concierge | 10-13 | Bullhorn + MS Graph + AgentMail | "First Tier-1 always-on closing demo; 4-week build" |
docs/decisions/sequencing-target.md:40:**Week 3 needs a starting agent.** The renderer (ADR-003) lands Week 1-2; `_shared/voice-loader.sh` + `hook-helpers.sh` land Week 1-2; Postgres `decision_log` lands Day 4 Week 0. By Week 3 the substrate is live and waiting for its first user. Without §A (first agent), Week 3 doesn't have a build target.
docs/decisions/sequencing-target.md:55:| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
docs/decisions/sequencing-target.md:76:The recommended sequence in §4 assumes v1.0 ships all six agents on the master brief §8.2 timeline. The scope-cut contingency activates on **Week 5 burn-down review** if Bullhorn auth (Risk #2) or Hire #1 status (Risk #4) tripwires fire.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:82:Per master brief §0 ("the master brief wins on every point of conflict"), the canonical sequence per master brief §8.2 places Cash Conductor at W7-8 before Sourcing Scout at W9. The Ultraplan §9 rationale (line 766) explicitly anchors this to Hire #1 onboarding: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 (verify, don't assume)" — Cash Conductor's Xero MCP + Open Banking integration is the right work for a new hire's first sprint per Ultraplan §9 line 766.
docs/decisions/sequencing-target.md:90:Six agents, six tables. Anchored to master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 487-690 + Product Spec §2.2 R-rows + `docs/decisions/bullhorn-integration-path.md` §4.1 + `docs/RISK-REGISTER.md` Risks #1, #2, #5.
docs/decisions/sequencing-target.md:92:### 2.1 — A1 Diagnostic
docs/decisions/sequencing-target.md:96:| 1. Implementation simplicity | **High** | Tier 2 (request-driven, no persistent PTY); no Bullhorn; single output (12-page audit report); Ultraplan §8.1 line 498 estimate **M (1 week)**. MCP servers: Companies House (free public API), LinkedIn (Proxycurl, read-only), web scraper for careers pages |
docs/decisions/sequencing-target.md:97:| 2. Substrate exercise | **Medium-High** | Exercises renderer (ADR-003) end-to-end, `_shared/voice-loader.sh` (audit narrative tone in founder's voice per Ultraplan §8.1 line 495), `_shared/hook-helpers.sh` (decision_log writes), Postgres `decision_log` per ADR-002. Does NOT exercise Bullhorn auth refresh-loop (Day 2 §4.5), wiki API (v1.0 weeks 11-13 per `second-brain-design.md` §3.4), or cortextOS Primitives 1+2+4+5 (Tier 2 means no PTY persistence) |
docs/decisions/sequencing-target.md:98:| 3. Risk de-risking | **High for Risk #5; None for Risk #1+#2** | **First production exercise of the renderer** per ADR-003 design §5.2 line "First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4." Renderer + `_shared/` + decision_log working end-to-end means Risk #5 staged reduction trigger from RISK-REGISTER fires (Medium severity). Doesn't touch Risk #2 (no Bullhorn) or Risk #1 (no Tier-1 primitives) |
docs/decisions/sequencing-target.md:99:| 4. Commercial value | **Medium** | Internal sales tool per Product Spec §2.2 R13 ("Not on the customer pricing card"). Drives qualified discovery-call pipeline. Demoable to a prospect but not the closing demo. Ultraplan §8.1 line 499 Gate B target: "≥30% of diagnostics produced lead to a discovery call booked" |
docs/decisions/sequencing-target.md:103:**Readiness summary:** Diagnostic — simplest implementation (~1 week per Ultraplan §8.1), exercises renderer + `_shared/` + decision_log end-to-end without Bullhorn or wiki, no cross-agent dependencies, ready by end of Week 4 per master brief §8.2 line 601 + Ultraplan §9 line 753.
docs/decisions/sequencing-target.md:109:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 513 estimate **L (2 weeks)** — the Bullhorn MCP work is rate-limiting per Ultraplan §8.1 line 514 ("Bullhorn MCP server doesn't exist yet — this is the critical-path build"). One MCP server (Bullhorn) + Companies House for enrichment. Single primary output (cleanup report) but with continuous nightly cron pattern |
docs/decisions/sequencing-target.md:112:| 4. Commercial value | **High** | Per master brief §8.2 line 602: "First demoable inside-ATS result; day-30 before/after closes deals." Product Spec §2.2 R9: day-30 cleanup report is "the closing artefact in sales." Ultraplan §8.1 line 512 Gate B: ≥15% dedup + ≥10% field completeness improvement in day-30 report |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:125:| 4. Commercial value | **High** | Per master brief §8.2 line 603: "Post-call note in Bullhorn within 10 min — second-most-demoable." Product Spec §2.2 R6: "Your firm's institutional memory finally lives somewhere." Critical downstream: **every Tier-1 v1.0 agent reuses Scribe's voice-and-tacit-note plumbing** |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:136:| 2. Substrate exercise | **High** | **First Tier-1 always-on agent** — exercises cortextOS **Primitive 1** (persistent PTY/PM2, flagged "shipped but flaky" in cortextos-primitive-status.md). First exercise of **Primitive 4** (approval gates) for chase email auto-send per master brief §8.2 line 604. First exercise of **Primitive 5** (Telegram approval surface) for FD-tier approval flow. **Does NOT touch Bullhorn** — independent integration path per `bullhorn-integration-path.md` §1.2 (Cash Conductor uses Xero/QuickBooks/Sage + Open Banking, not Bullhorn) |
docs/decisions/sequencing-target.md:138:| 4. Commercial value | **High** | Per master brief §8.2 line 604: "FD-tier closer; 'DSO drops by 15 days'." Product Spec §2.2 R2: £40-120k working capital unlock per agency, "one bad debt caught per quarter pays for the entire suite" |
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:150:| 1. Implementation simplicity | **Medium** | Ultraplan §8.1 line 554 estimate **L (2 weeks)** — multi-source aggregation logic is the work. Four data sources (Bullhorn read + LinkedIn via Proxycurl + Reed.co.uk + CV-Library). Bounded output (5-15 candidates per query per Ultraplan §8.1 line 552). Tier 2 request-response |
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:155:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn (already on if Janitor shipped) + LinkedIn (Proxycurl API key — single application-level key, not per-tenant) + Reed OAuth + CV-Library OAuth per tenant |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:166:| 4. Commercial value | **Highest** | Per master brief §8.2 line 606: "First Tier-1 always-on closing demo; 4-week build." Product Spec §2.2 R7: 15-25% lift in placement-driven referral revenue ("post-placement nurture is the cheapest BD channel in recruitment and you currently leave it on the table"). The flagship v1.0 closing demo |
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:168:| 6. Tenant-onboarding readiness | **Hardest** | Needs Bullhorn + Microsoft Graph (or Gmail) per tenant + full voice corpus loaded + nurture cadence config per stage + auto-send approval categories (Solo: drafts-only; Boutique+: candidate-acknowledgement auto-send) + do-not-contact flags. Full onboarding-wizard Day 4 work (Product Spec §5.2) |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:176:Three orderings evaluated against §1.3 criteria. **Option Alpha is the master-brief §8.2 canonical sequence** (correcting the §1.5 founder-prompt drift); Options Beta and Gamma are tested as alternatives.
docs/decisions/sequencing-target.md:178:### 3.1 — Option Alpha (canonical, master-brief §8.2)
docs/decisions/sequencing-target.md:181:W3-4: Diagnostic (A1)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:207:W3-4: Diagnostic (A1) — substrate proof, non-negotiable
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:228:W3-4: Diagnostic (A1)
docs/decisions/sequencing-target.md:253:| 2. Substrate exercise (sequential build-up) | **Wins** — each agent extends the substrate of the prior (renderer → Bullhorn auth → voice → Tier-1 primitives → multi-source → full Tier-1 lifecycle) | Loses — Concierge has to build its own Bullhorn auth + voice substrate inline | Loses — Concierge built before its substrate dependencies (Scribe's Notes-for-context not yet available) |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:275:**This section ratifies master brief §8.2 lines 597-611 + Ultraplan §9 lines 717-801 as the v1.0 sequence of record. Day 3's contribution is the §5 gating criteria + §4.3 named revisit conditions — not a new sequence proposal.** Master brief §8.2 already named the order; this document closes the "confirm or revise" decision per master brief §6 Day 3 line 471 as **confirm**.
docs/decisions/sequencing-target.md:281:| 1 | W3-4 | **Diagnostic** (A1) | Substrate-proof agent; first renderer production render per ADR-003 design §5.2 |
docs/decisions/sequencing-target.md:283:| 3 | W6 | **Scribe** (A3) | voice-loader-for-tacit-notes first exercise; Concierge-upstream Notes-for-context |
docs/decisions/sequencing-target.md:300:**Trigger 1 — Risk #2 materialises in Week 4-5.** If Bullhorn auth path breaks (Day 2 Sub-decisions A or B don't flip to Accepted, marketplace required but unobtainable, OAuth flow blocks deployment, or per-tenant client_id ticket cycle slows past 5 business days per `bullhorn-integration-path.md` §1.3 row 5):
docs/decisions/sequencing-target.md:304:- **Updates required:** `.agents/current-priorities.md` open list; this document's §4.1 table; master brief §8.2 (atomic correction commit edit, joining the 7-edit manifest); `docs/RISK-REGISTER.md` Risk #2 row.
docs/decisions/sequencing-target.md:311:- **Updates required:** same set as Trigger 1 plus founder's Q3 personal cadence (Cash Conductor's L/2-week build becomes founder solo at W7-8, slowing but not blocking).
docs/decisions/sequencing-target.md:318:- **Updates required:** §4.1 table (Cash Conductor weeks); master brief §8.2; downstream agent weeks shift accordingly.
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:347:1. **All Gate A checks passing in agent N's `validate.sh`** per master brief §1 Rule 4 + §8.1 Change 2 (banned-phrase / length / voice-classifier / schema / PII-boundary).
docs/decisions/sequencing-target.md:348:2. **First production run lands clean** for at least one tenant — no `ESC_*` escalation rows in `decision_log` for agent N's run.
docs/decisions/sequencing-target.md:350:4. **Voice-canary fixture passes** per master brief §8.1 Change 1 (`tests/fixtures/99-voice-drift-canary/` per ADR-002 §2.1 row 7).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:361:| **Scribe → Cash Conductor** | **10 voice-anchored note writes across 3+ tenants** (statistical sample for voice classifier convergence per Ultraplan §6.2) | `voice-loader.sh` exercised on every write; voice-canary fixture passes for Scribe specifically; Bullhorn Note write idempotent (re-running same input doesn't duplicate Notes); 5-min SLA met for 9/10 runs per Ultraplan §8.1 line 521 |
docs/decisions/sequencing-target.md:362:| **Cash Conductor → Sourcing Scout** | **1 Tier-1 sustained-operation cycle for 1+ tenant** (24+ hours uninterrupted PTY uptime) **plus Hire #1 onboarded and productive** | cortextOS Primitives 1+4+5 all exercised without `ESC_CORTEXTOS_*` escalation; first DSO baseline captured for 1 tenant per Ultraplan §8.1 line 540; Hire #1 has merged at least one PR on Cash Conductor code path |
docs/decisions/sequencing-target.md:363:| **Sourcing Scout → Concierge** | **3 LinkedIn rate-limit-budget cycles** (each cycle = full daily rate-limit window hit and reset) **plus 1 source-discovery run** producing 5-15 candidates per Ultraplan §8.1 line 552 | LinkedIn rate-limit budget verified ≤ Day 2 §4.4 allocation; no `ESC_RATE_LIMIT_HIT` escalations sustained over a 24-hour observation window per Ultraplan §10 row #6 |
docs/decisions/sequencing-target.md:373:3. **Either fix-and-retry (1 additional week)** or **scope-cut contingency activates** per §4.3 Trigger 1 (if Risk #2 derived) or §4.3 Trigger 2 (if Risk #4 derived).
docs/decisions/sequencing-target.md:389:- `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` per master brief §8.1 Changes 1+2.
docs/decisions/sequencing-target.md:397:First agent build starts W3 per §4.1 row 1 + master brief §8.2 line 601 ("Weeks 3-4"). Concrete scope:
docs/decisions/sequencing-target.md:400:- **No Bullhorn integration** for Diagnostic per master brief §8.2 line 601 ("LinkedIn + Companies House + scrape" only).
docs/decisions/sequencing-target.md:404:The W3 build / W4 first-render framing is internally consistent across master brief §8.2 ("Weeks 3-4" range), Ultraplan §9 line 753 ("Week 4: Diagnostic agent built end-to-end"), and ADR-003 design §5.2 — no discrepancy requires correction. The earlier draft concern about W3 vs W4 is resolved by the build-window-vs-completion-week distinction: Diagnostic build window is W3-W4; first production render lands W4.
docs/decisions/sequencing-target.md:410:§4.3 Trigger 1 activation point: end of W4 weekly review if Sub-decisions A and B still Proposed.
docs/decisions/sequencing-target.md:448:- §4.1 ratified sequence matches master brief §8.2 (no drift).
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
packages/agent-renderer/templates/claude-md-preamble.md:36:- Voice anchor: `/vault/{{tenant_slug}}/_voice/style-guide.md` (importance threshold {{voice_threshold}})
packages/agent-renderer/templates/claude-md-preamble.md:58:- Cross-tenant PII is an `ESC_PII_LEAKAGE_RISK` escalation per `_shared/escalation-codes.md`.
packages/agent-renderer/templates/claude-md-preamble.md:59:- Voice samples and tone rules live under `/vault/{{tenant_slug}}/_voice/`.
packages/harness/cortextos/community/skills/officecli/SKILL.md:43:Path addressing uses 1-based indexing: `/body/p[1]`, `/slide[2]/shape[3]`, `/$Sheet:A1`
packages/harness/cortextos/community/skills/officecli/SKILL.md:102:officecli set $XLS 'Summary!A1' --prop value="Total Open"
packages/harness/cortextos/community/skills/officecli/SKILL.md:110:officecli set report.xlsx 'Sheet1!A1' --prop value="Property"
packages/harness/cortextos/community/skills/officecli/SKILL.md:132:  --prop background=1A1A2E
docs/architecture/vault-concurrency.md:19:- **Founder via Obsidian** — writes `_voice/`, `_playbooks/`, `_decisions/`, free-form `## Notes` sections of any compiled entity (§2.4.1).
docs/architecture/vault-concurrency.md:60:- **Timeout** — 5 seconds default (`OP_LOCK_TIMEOUT_S = 5`). If acquisition fails within 5s, raise `ESC_VAULT_LOCK_TIMEOUT`.
docs/architecture/vault-concurrency.md:191:- **1 retry** on `ESC_VAULT_VERSION_MISMATCH` with 100ms backoff (`OP_RETRY_BACKOFF_MS = 100`).
docs/architecture/vault-concurrency.md:192:- If second attempt also fails: raise `ESC_VAULT_VERSION_MISMATCH`, record in `decision_log` with `phase='gating_failed'` per `sequencing-target.md` §5-A enum extension, log human-readable error to operator Telegram per primitive 5 escalation surface.
docs/architecture/vault-concurrency.md:246:  → debounce check (§4) ───→ if ESC_VAULT_HUMAN_EDIT_BLOCKED, release flock and surface
docs/architecture/vault-concurrency.md:257:The 5-retry × 6s-wait pattern caps worst-case wait at 30s (5 × 6s = 30s) before raising `ESC_VAULT_HUMAN_EDIT_BLOCKED`. Total operation budget from flock-acquire to escalation: ~35s. Worth surfacing to operator at this point — likely a long Obsidian session that needs founder attention to schedule agent work around.
docs/architecture/vault-concurrency.md:381:**V1.0 mitigation:** surface partial failure as `ESC_VAULT_CASCADE_PARTIAL_FAILURE` carrying the list of `failures` (referencing entities whose markdown bodies were not rewritten). Record in `decision_log` with `phase='gating_failed'`, `metadata` containing the failures list. **Founder reviews and manually reconciles** — for each failure, run the rewrite by hand (most edits are small) or accept temporary inconsistency until next operation through that entity.
docs/architecture/vault-concurrency.md:389:**V1.0 cascade timeout: 30 seconds** (`CASCADE_TIMEOUT_MS = 30_000`). If exceeded, raise `ESC_VAULT_CASCADE_TIMEOUT` with `failures.length` (entities not yet rewritten) and `refs.length` (total cascade size). Decision_log entry per `phase='gating_failed'`. **Founder reviews** — for large cascades (>30s), the rename is structurally expensive and may warrant rescheduling to off-hours.
docs/architecture/vault-concurrency.md:403:| `ESC_VAULT_LOCK_TIMEOUT` | §2: `flock` acquisition failed within `OP_LOCK_TIMEOUT_S = 5` seconds | `gating_failed` | Telegram operator chat per primitive 5 |
docs/architecture/vault-concurrency.md:404:| `ESC_VAULT_VERSION_MISMATCH` | §3: Postgres optimistic-concurrency UPDATE found 0 rows after retry | `gating_failed` | Telegram operator chat |
docs/architecture/vault-concurrency.md:405:| `ESC_VAULT_HUMAN_EDIT_BLOCKED` | §4: Obsidian debounce hit `MAX_RETRIES = 5` (file mtime still recent after 30s of waiting) | `gating_failed` | Telegram operator chat |
docs/architecture/vault-concurrency.md:406:| `ESC_VAULT_CASCADE_PARTIAL_FAILURE` | §5: rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite | `gating_failed` | Telegram operator chat, plus `failures` list in decision_log metadata |
docs/architecture/vault-concurrency.md:407:| `ESC_VAULT_CASCADE_TIMEOUT` | §5: cascade exceeded `CASCADE_TIMEOUT_MS = 30_000` ms | `gating_failed` | Telegram operator chat, plus partial-progress counters |
docs/architecture/vault-concurrency.md:409:All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **All 5 codes catalogued + wired as of Day 8 2026-05-20** at `agents/_shared/escalation-codes.md` §2.2 (commit `a279226`) and `agents/_shared/hook-helpers.sh::autosend_escalate` (commit `e6e9df1`). Test coverage in `agents/_shared/tests/test-hook-helpers.sh`.
docs/architecture/vault-concurrency.md:424:| Cascade atomicity gap (v1.0 mitigation via `ESC_VAULT_CASCADE_PARTIAL_FAILURE` + decision_log + manual reconciliation; full atomicity via write-ahead-log deferred to v1.2+) | §5.4 |
docs/architecture/vault-concurrency.md:438:| `_shared/hook-helpers.sh` wires 5 new `ESC_VAULT_*` codes (in addition to `ESC_BULLHORN_AUTH` + `ESC_RENDERER_FAILED`) | Week 1-2 | Claude Code | `current-priorities.md` Week-1 prereq #3 + §6 of this document |
docs/build-brief/00-MASTER-BRIEF.md:27:├── packages/harness/cortextos/      ← cortextOS vendored at a pinned SHA. READ-ONLY.
docs/build-brief/00-MASTER-BRIEF.md:44:We add: a vertical schema for UK recruitment; 18 agents in the v2 bundle pattern; an Obsidian-style wiki + graphify second brain that **replaces** cortextOS's stock knowledge-base behind the `bus/kb-*.sh` boundary; MCP connectors for Bullhorn/Companies House/Xero/Microsoft Graph; an entity-graph + decision-log Postgres layer with RLS; a per-tenant LoRA pipeline (v2.0 work); and a five-day onboarding wizard.
docs/build-brief/00-MASTER-BRIEF.md:56:3. **Reuse before build.** Every agent uses `agents/_shared/` modules: voice loader, decision-log writer, validate primitives, escalation router. No agent writes its own logging, voice handling, or approval gate. If the shared module is missing, build the module first, then the agent.
docs/build-brief/00-MASTER-BRIEF.md:129:`packages/harness/cortextos/` is the cortextOS source code, vendored at a pinned SHA via git submodule. **No file in this tree gets edited.**
docs/build-brief/00-MASTER-BRIEF.md:136:2. **Open a PR upstream.** Cross-vertical primitive (a better file-bus locking mechanism, a new approval-gate type) → branch off `~/code/cortex-os-upstream/main`, fix it there, open the PR. Do **not** merge to our `packages/harness/cortextos/` SHA until the PR is merged or rejected.
docs/build-brief/00-MASTER-BRIEF.md:141:### 3.2 The Composio/AgentMail adapter boundary
docs/build-brief/00-MASTER-BRIEF.md:145:Composio and AgentMail appear ONLY behind the adapter boundary at `packages/vertical-adapters/recruitment/`. No `agent.md`, no `tools.yaml` `required:` block, no eval fixture, no vault file references either tool directly.
docs/build-brief/00-MASTER-BRIEF.md:151:| Companies House, Xero, QuickBooks, FreeAgent, Sage, HMRC MTD | `packages/mcp-connectors/{name}/` first-party MCP | Vertical-specific or UK-specific |
docs/build-brief/00-MASTER-BRIEF.md:152:| Gmail, Outlook, Slack, HubSpot, DocuSign, Calendly, Notion | Via Composio, behind adapter | Commodity SaaS, no vertical specificity |
docs/build-brief/00-MASTER-BRIEF.md:153:| AgentMail | v1.1 Inbound Triage only, behind adapter | Inbox provisioning for agent-identity sends |
docs/build-brief/00-MASTER-BRIEF.md:159:- **Markdown lives in the vault.** Anything human-readable, voice-related, narrative, playbook-like, or that an agent edits and a human reviews.
docs/build-brief/00-MASTER-BRIEF.md:163:The vault is the source of truth for voice and playbooks. Postgres is the source of truth for state and provenance. The Brain UI reads both via the `context-assembly` API (the single audit-logged surface).
docs/build-brief/00-MASTER-BRIEF.md:167:IFOS implements its second brain as a **parallel system**, not by shadowing cortextOS's stock knowledge base. cortextOS's `bus/kb-*.sh` files (`kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh` at SHA `c21fbfe`) remain untouched and continue to serve cortextOS-template agents. IFOS agents invoke a parallel wrapper surface at `packages/brain/bus-overrides/wiki-*.sh` (9 v1.0 + 1 v1.1 stub) that dispatches to `packages/brain/wiki/lib/` against Postgres + filesystem markdown. The §3.1 "four `bus/kb-*.sh` shadow points" edit-exception is unused — IFOS does not edit any file under `packages/harness/cortextos/`. See `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` + `docs/architecture/second-brain-design.md` for the full design.
docs/build-brief/00-MASTER-BRIEF.md:189:mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
docs/build-brief/00-MASTER-BRIEF.md:199:git submodule add https://github.com/grandamenium/cortextos.git packages/harness/cortextos
docs/build-brief/00-MASTER-BRIEF.md:200:cd packages/harness/cortextos
docs/build-brief/00-MASTER-BRIEF.md:215:cd packages/harness/cortextos
docs/build-brief/00-MASTER-BRIEF.md:219:git add packages/harness/cortextos packages/harness/PINNED-SHA.md
docs/build-brief/00-MASTER-BRIEF.md:350:2. **Compile.** A scheduled compile job (per-tenant nightly cron via cortextos `bus add-cron`) reads `raw/*` newer than the last compile, calls Claude (via the runtime; voice-loaded for the tenant), and either creates new pages in `compiled/{type}/{slug}.md` or extends existing ones. Every compiled page has wiki-link backrefs (`[[Candidate: Sarah Bowen]]`) and YAML frontmatter:
docs/build-brief/00-MASTER-BRIEF.md:406:- **The voice-quality strip.** Persistent footer showing the rolling 4-week voice classifier score. Green ≥ 0.80, amber 0.70–0.80, red < 0.70. Click for trend graph + recent-edit-pattern callouts. **Voice quality is structurally visible, never hidden.**
docs/build-brief/00-MASTER-BRIEF.md:413:| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
docs/build-brief/00-MASTER-BRIEF.md:416:| **v2.0 — the second brain at scale** | Q3 2027 | Reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views |
docs/build-brief/00-MASTER-BRIEF.md:449:  - Read `packages/harness/cortextos/README.md`, `CHANGELOG.md`, `CRONS_MIGRATION_GUIDE.md`
docs/build-brief/00-MASTER-BRIEF.md:450:  - Scan `packages/harness/cortextos/src/{daemon,bus,hooks}/`
docs/build-brief/00-MASTER-BRIEF.md:464:- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation.
docs/build-brief/00-MASTER-BRIEF.md:513:| `00-PATTERN-REFERENCE.md` | 6-file agent bundle pattern | `docs/architecture/PATTERN-REFERENCE.md` | Update to v2: `99-voice-drift-canary` fixture required |
docs/build-brief/00-MASTER-BRIEF.md:557:        └── 99-voice-drift-canary/      # NEW IN V2 — every agent has one.
docs/build-brief/00-MASTER-BRIEF.md:566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
docs/build-brief/00-MASTER-BRIEF.md:580:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/build-brief/00-MASTER-BRIEF.md:581:- `ESC_BULLHORN_AUTH` — OAuth token expired/revoked
docs/build-brief/00-MASTER-BRIEF.md:582:- `ESC_DUPLICATE_DETECTED` — high-confidence dedup needs human review
docs/build-brief/00-MASTER-BRIEF.md:583:- `ESC_JSL_RED_FLAG` — Supply Chain Auditor detected red flag
docs/build-brief/00-MASTER-BRIEF.md:584:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder cannot confidently shortlist
docs/build-brief/00-MASTER-BRIEF.md:585:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/build-brief/00-MASTER-BRIEF.md:586:- `ESC_RATE_LIMIT_HIT` — upstream API rate-limited (esp. LinkedIn)
docs/build-brief/00-MASTER-BRIEF.md:587:- `ESC_SCHEMA_VIOLATION` — agent produced output violating vertical schema
docs/build-brief/00-MASTER-BRIEF.md:595:| 1 | Diagnostic | 3–4 | LinkedIn + Companies House + scrape | Sales tool — needed before any other agent matters |
docs/build-brief/00-MASTER-BRIEF.md:600:| 6 | Concierge | 10–13 | Bullhorn + MS Graph + AgentMail | First Tier-1 always-on closing demo; 4-week build |
docs/build-brief/00-MASTER-BRIEF.md:612:mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
docs/build-brief/00-MASTER-BRIEF.md:695:        │  • First-party MCP  packages/mcp-connectors/: Bullhorn, Companies House, Xero, etc.        │
docs/build-brief/00-MASTER-BRIEF.md:696:        │  • Composio (commodity SaaS): Gmail, Outlook, Slack, HubSpot                               │
docs/build-brief/00-MASTER-BRIEF.md:697:        │  • AgentMail (v1.1 Triage only): agent-identity inbox                                      │
docs/build-brief/00-MASTER-BRIEF.md:698:        │  • Direct vendor API: Microsoft Graph delegated send, Proxycurl LinkedIn                   │
docs/build-brief/00-MASTER-BRIEF.md:780:- `_shared/` shell helpers (voice loader, decision-log writer, validate primitives)
docs/build-brief/00-MASTER-BRIEF.md:797:- Anything where the temptation is "let me just edit `packages/harness/cortextos/...`" — stop, re-read §3.1
docs/build-brief/00-MASTER-BRIEF.md:805:> 2. The cortextOS boundary (no edits to `packages/harness/cortextos/`)
docs/build-brief/00-MASTER-BRIEF.md:806:> 3. The Composio/AgentMail adapter boundary
docs/build-brief/00-MASTER-BRIEF.md:823:| "Let me edit `packages/harness/cortextos/...`" | §3.1 |
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:828:| "Let me use Composio for the Bullhorn connector..." | §3.2 |
docs/build-brief/00-MASTER-BRIEF.md:860:Recruitment-operations product for UK agencies, built on cortextOS (`packages/harness/cortextos/`,
docs/build-brief/00-MASTER-BRIEF.md:878:- Never edit `packages/harness/cortextos/*` except the four `bus/kb-*.sh` files we shadow via
docs/build-brief/00-MASTER-BRIEF.md:882:- Never reference Composio or AgentMail in `agent.md`, `tools.yaml`, vault files, or fixtures —
docs/build-brief/00-MASTER-BRIEF.md:928:- Don't modify `packages/harness/cortextos/*` except the four `bus/kb-*.sh` shadow points
docs/build-brief/00-MASTER-BRIEF.md:953:> 3. You understand the Composio/AgentMail adapter boundary
docs/build-brief/00-MASTER-BRIEF.md:955:> 5. You understand the agent bundle v2 pattern (6 files + 3 fixtures, incl. 99-voice-drift-canary)
docs/build-brief/00-MASTER-BRIEF.md:969:- Edit `packages/harness/cortextos/...` because "it'll be faster than upstreaming"
docs/build-brief/00-MASTER-BRIEF.md:970:- Ship an agent without a 99-voice-drift-canary because "we'll add it later"
docs/build-brief/00-MASTER-BRIEF.md:973:- Use Composio for Bullhorn because "the catalogue says they have it" (they don't, and even if they did, see §3.2)
docs/build-brief/00-MASTER-BRIEF.md:986:6. **The quality gates** — Gate A binary per-run, Gate B 90-day, Gate C weekly voice classifier
docs/decisions/bullhorn-integration-path.md:9:**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.
docs/decisions/bullhorn-integration-path.md:33:| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:35:| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
docs/decisions/bullhorn-integration-path.md:38:| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |
docs/decisions/bullhorn-integration-path.md:55:- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:230:- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
docs/decisions/bullhorn-integration-path.md:281:Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:286:| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
docs/decisions/bullhorn-integration-path.md:287:| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
docs/decisions/bullhorn-integration-path.md:288:| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
docs/decisions/bullhorn-integration-path.md:289:| **A1 Diagnostic** (no Bullhorn) | n/a | n/a | n/a | n/a | n/a | n/a — runs against public footprint per Ultraplan §8.1 line 489 |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:353:  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
docs/decisions/bullhorn-integration-path.md:411:- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
docs/decisions/bullhorn-integration-path.md:484:| §4.5 (architectural emergence) | §4.5 | Access-token refresh-loop: per-agent background task, 8-minute cycle, retry-once-then-`ESC_BULLHORN_AUTH` |
docs/decisions/bullhorn-integration-path.md:502:| `ESC_BULLHORN_AUTH` escalation code wired into `agents/_shared/escalation-codes.md` | Claude Code | Week 1-2 (alongside `_shared/hook-helpers.sh` Week-1 prereq from ADR-002) |
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
packages/agent-renderer/README.md:7:**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.
packages/agent-renderer/README.md:102:Every failure returns `outcome: "failed"` + `reason: "<code>: <message>"`. Codes follow `agent-bundle-renderer-design.md` §4 + map to `ESC_RENDERER_FAILED` per `agents/_shared/escalation-codes.md` §2.4:
packages/agent-renderer/README.md:117:- **`_shared/` copy-not-symlink staleness.** Renderer COPIES `agents/_shared/` to `${frameworkRoot}/orgs/<org>/agents/_shared/` per ADR-003 §3.3.3 Option γ — does NOT symlink. Mid-pilot edits to `agents/_shared/{voice-loader,hook-helpers}.sh` require re-running `render-agent` for each tenant. v1.0 acceptable (single-tenant pilot); v1.1 may add SHA-based skip-if-unchanged optimisation.
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/day-4-provisioning.md:1228:9. **§4 self-inflicted defensive check (Claude error):** Claude added `sudo file -s /dev/disk/by-id/...` defensive check not in runbook §4.1; `file` not installed on base image; `set -e` aborted before §4.2 install. Reverted to exact runbook commands. Lesson: stop adding defensive diagnostics beyond runbook spec when execution is in section-by-section gated mode.
docs/runbooks/day-4-provisioning.md:1287:- Not the `_shared/voice-loader.sh` + `hook-helpers.sh` build (the remaining Week-1 prereq)
packages/harness/cortextos/community/agents/orchestrator/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/community/agents/orchestrator/SOUL.md:56:- External: org brand voice, professional, opinionated when asked
docs/runbooks/operational-hygiene-protocol.md:125:**Rule:** When executing a runbook, run exactly the commands in the runbook. Do not add defensive checks, verification probes, or "while we're here" diagnostics beyond what the runbook specifies.
docs/runbooks/operational-hygiene-protocol.md:298:- `master brief §8.1 Change 1/2/3` (voice loader / decision logging / escalation codes) — ✅ verified all three Changes exist with correct content
docs/runbooks/tenant-lifecycle.md:80:mkdir -p /vault/${SLUG}/{_voice,_config,_brand,_playbooks,spot-checks,pending-approvals,wiki/raw}
docs/runbooks/tenant-lifecycle.md:101:voice_threshold: 0.75
docs/runbooks/tenant-lifecycle.md:104:# Step 7: Seed initial voice corpus row (empty — operator uploads docs separately)
docs/runbooks/tenant-lifecycle.md:106:  INSERT INTO voice_corpus (tenant_slug, version, source_doc_count, source_doc_origin,
docs/runbooks/tenant-lifecycle.md:112:for agent in diagnostic; do
docs/runbooks/tenant-lifecycle.md:133:- Initial voice_corpus row with `is_active=TRUE` (T10 invariant)
docs/runbooks/tenant-lifecycle.md:149:| Voice corpus re-index | Operator uploads new docs to `/vault/<slug>/_voice/`; `ifosctl reindex-voice --tenant <slug>` runs ingest pipeline + flips `is_active` atomically | T10 (single-active per tenant) |
docs/runbooks/tenant-lifecycle.md:150:| Tone rule add/edit | Tenant operator edits `/vault/<slug>/_voice/tone-rules.yaml` OR Brain UI v1.1; sync to Postgres `tone_rule` table | T1-T3 (RLS isolation) |
docs/runbooks/tenant-lifecycle.md:151:| Bullhorn OAuth refresh | Per-agent 8-min cycle per `bullhorn-integration-path.md` §4.5; ESC_BULLHORN_AUTH on failure | (No invariant violation; runtime concern) |
docs/runbooks/tenant-lifecycle.md:247:  DELETE FROM voice_corpus_chunks WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:248:  DELETE FROM voice_corpus      WHERE tenant_slug='<slug>';
docs/runbooks/tenant-lifecycle.md:343:- **T10**: voice_corpus is_active=TRUE single-per-tenant (Migrate transition needs atomic flip)
docs/runbooks/tenant-lifecycle.md:351:- **Voice corpus re-index** (Active sub-state): new `voice_corpus` row inserted with `is_active=TRUE`; old row updated to `is_active=FALSE` in same transaction. Partial unique index (T10) enforces no two `is_active=TRUE` rows simultaneously.
docs/runbooks/tenant-lifecycle.md:391:| L8 | Voice corpus re-index ergonomic command (currently manual SQL + ingest) | Medium | `ifosctl reindex-voice --tenant <slug>` v1.1+ | First tenant requests re-index |
docs/specs/ULTRAPLAN.md:34:**Rule 3 — Reuse before build.** Every agent uses the shared `_shared/` modules (voice loader, decision log writer, validate primitives, escalation router). No agent writes its own logging, its own voice handling, its own approval gate. If a shared module is missing, build the module first, then the agent.
docs/specs/ULTRAPLAN.md:73:- **The persistent PTY.** Agent process is *already running* with firm voice profile, ATS state, current pipeline, recent context pre-loaded. Sub-second to first useful action. Lambda cold starts are 3–8 seconds before the first token; Triage at that latency stops being magical.
docs/specs/ULTRAPLAN.md:90:- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
docs/specs/ULTRAPLAN.md:137:        └── 99-voice-drift-canary/
docs/specs/ULTRAPLAN.md:142:The 99-voice-drift-canary fixture is new in v2. Every agent has one — a fixture designed to expose voice drift over time. Run weekly in CI; output diffed against historical baselines.
docs/specs/ULTRAPLAN.md:148:Phase 2 has each `context.sh` `cat` the voice profile inline. That works for nine agents; it's brittle at eighteen. v2 introduces `_shared/voice-loader.sh`:
docs/specs/ULTRAPLAN.md:152:source /tenant/.claude/bin/_shared/voice-loader.sh
docs/specs/ULTRAPLAN.md:157:# Retrieve top-N similar samples from voice corpus
docs/specs/ULTRAPLAN.md:158:hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"
docs/specs/ULTRAPLAN.md:164:Every agent's `context.sh` becomes 30 lines instead of 200. The voice loader is the canonical surface; agents never read the voice corpus directly.
docs/specs/ULTRAPLAN.md:182:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
docs/specs/ULTRAPLAN.md:183:- `ESC_BULLHORN_AUTH` — Bullhorn OAuth token expired or revoked
docs/specs/ULTRAPLAN.md:184:- `ESC_DUPLICATE_DETECTED` — Janitor found a high-confidence dedup candidate requiring human review
docs/specs/ULTRAPLAN.md:185:- `ESC_JSL_RED_FLAG` — Supply Chain Auditor detected a red-flag pattern requiring immediate consultant attention
docs/specs/ULTRAPLAN.md:186:- `ESC_BRIEF_AMBIGUITY` — Brief Decoder found ambiguities that prevent confident shortlisting
docs/specs/ULTRAPLAN.md:187:- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
docs/specs/ULTRAPLAN.md:188:- `ESC_RATE_LIMIT_HIT` — upstream API (LinkedIn especially) rate limited
docs/specs/ULTRAPLAN.md:189:- `ESC_SCHEMA_VIOLATION` — agent produced output that violates the vertical schema (e.g., a "placement" with no candidate)
docs/specs/ULTRAPLAN.md:199:- `99-voice-drift-canary` — the structural canary.
docs/specs/ULTRAPLAN.md:220:- Inside: `_voice/`, `_playbooks/`, `_decisions/`, `candidates/`, `clients/`, `opportunities/`, `temp/` (if Temp tier active), `_config.yaml`.
docs/specs/ULTRAPLAN.md:230:- pgvector extension installed for the voice corpus embeddings (per-tenant, partitioned the same way).
docs/specs/ULTRAPLAN.md:300:## 6. The voice delivery system — how we technically deliver "in your voice" at 10/10
docs/specs/ULTRAPLAN.md:302:This is the answer to Q8, restated as a build specification. Voice is the single most important thing to get right. If voice fails, the product is a £49/month ChatGPT wrapper, not a £6,950/month operator.
docs/specs/ULTRAPLAN.md:306:**Layer 1 — The voice corpus (data).**
docs/specs/ULTRAPLAN.md:318:- Appended to the voice corpus weekly, with the edit's "lesson" extracted ("consultant shortened the opening", "consultant replaced 'I hope this finds you well' with nothing").
docs/specs/ULTRAPLAN.md:321:**Layer 2 — Runtime voice application (prompt assembly).**
docs/specs/ULTRAPLAN.md:323:Every agent's `context.sh` calls `_shared/voice-loader.sh`, which:
docs/specs/ULTRAPLAN.md:327:   You are writing in the voice of {firm name}. Hard rules:
docs/specs/ULTRAPLAN.md:348:- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
docs/specs/ULTRAPLAN.md:354:If any hard fail, the agent regenerates with the failure reason injected as additional context ("your previous draft used the banned phrase 'I hope this finds you well'; rewrite avoiding it"). After 3 retries with hard fails, escalate with `ESC_VOICE_DRIFT` or `ESC_SCHEMA_VIOLATION`.
docs/specs/ULTRAPLAN.md:362:3. Eval the adapter against held-out drafts using the voice classifier — promote only if the adapter beats the RAG baseline by ≥5 percentage points on the voice score *and* doesn't regress on compliance or factual checks.
docs/specs/ULTRAPLAN.md:365:The LoRA improves voice score from ~80% (RAG + scaffolding) to ~90%+. This is what justifies the Scale tier at £6,950/mo.
docs/specs/ULTRAPLAN.md:369:### 6.2 The voice drift alerting
docs/specs/ULTRAPLAN.md:373:2. Run the voice classifier on each.
docs/specs/ULTRAPLAN.md:376:If the rolling 4-week average drops by ≥5 percentage points: `ESC_VOICE_DRIFT_TENANT` fires. Email goes to the customer's primary contact AND to the internal CS Slack:
docs/specs/ULTRAPLAN.md:378:> "Your voice quality score has dropped from 0.83 to 0.76 over the last 4 weeks. This usually means new edit patterns we haven't absorbed. Can we book 30 minutes to review samples?"
docs/specs/ULTRAPLAN.md:380:We never silently accept voice drift. The structural commitment is that voice quality is measurable, measured, and surfaced.
docs/specs/ULTRAPLAN.md:382:### 6.3 The sales-floor demo of voice quality
docs/specs/ULTRAPLAN.md:388:3. Show the voice classifier score live on the screen: "0.84. Here's the draft."
docs/specs/ULTRAPLAN.md:434:- **Edit then send** — captures the diff for the voice corpus
docs/specs/ULTRAPLAN.md:487:#### A1. The Diagnostic — the sales tool
docs/specs/ULTRAPLAN.md:493:- **MCP tools required:** Companies House, LinkedIn (read-only), web scraper for careers pages
docs/specs/ULTRAPLAN.md:494:- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
docs/specs/ULTRAPLAN.md:495:- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
docs/specs/ULTRAPLAN.md:497:- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
docs/specs/ULTRAPLAN.md:499:- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.
docs/specs/ULTRAPLAN.md:507:- **MCP tools required:** Bullhorn (read-write), Companies House (for entity enrichment)
docs/specs/ULTRAPLAN.md:509:- **External APIs:** Bullhorn REST API, Companies House
docs/specs/ULTRAPLAN.md:533:- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:541:- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.
docs/specs/ULTRAPLAN.md:549:- **MCP tools required:** Bullhorn (read for ATS passive matches), LinkedIn (via Proxycurl or similar), Reed.co.uk API, CV-Library API
docs/specs/ULTRAPLAN.md:551:- **External APIs:** Proxycurl, Reed, CV-Library
docs/specs/ULTRAPLAN.md:555:- **Gotchas:** LinkedIn rate limits via Proxycurl. Reed/CV-Library have separate auth and separate result schemas. Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it.
docs/specs/ULTRAPLAN.md:563:- **MCP tools required:** Bullhorn (read for state, write for activity log), Microsoft Graph / Gmail (send), AgentMail (optional for agent-identity sends)
docs/specs/ULTRAPLAN.md:565:- **External APIs:** Microsoft Graph or Google Workspace per tenant; AgentMail for v1.1+
docs/specs/ULTRAPLAN.md:566:- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
docs/specs/ULTRAPLAN.md:577:- **Trigger type:** Inbound email webhook (Microsoft Graph subscription or AgentMail webhook), LinkedIn InMail webhook, website contact form webhook
docs/specs/ULTRAPLAN.md:579:- **MCP tools required:** Microsoft Graph or Gmail (read + send), AgentMail (send, where agent-identity is needed), Bullhorn (read for candidate matching), LinkedIn (read)
docs/specs/ULTRAPLAN.md:581:- **External APIs:** Microsoft Graph subscriptions, AgentMail
docs/specs/ULTRAPLAN.md:585:- **Gotchas:** This is the most dangerous auto-send agent. Auto-send categories must be gated tightly (acknowledge-new-candidate only at v1.1 launch, expand after 30 days of clean data). Misclassification of a complaint as a routine inbound is a relationship killer. The deliverability test for AgentMail vs Microsoft Graph is the rate-limiting research.
docs/specs/ULTRAPLAN.md:605:#### A10. Competitor Interception (2 weeks)
docs/specs/ULTRAPLAN.md:613:- **External APIs:** Broadbean (no public API — scraping required), LinkedIn, Companies House
docs/specs/ULTRAPLAN.md:619:#### A11. The Night Sourcer (2 weeks)
docs/specs/ULTRAPLAN.md:633:#### A12. T5 Supply Chain Auditor (parallel to v1.1 front-office work)
docs/specs/ULTRAPLAN.md:639:- **MCP tools required:** Companies House (umbrella entity monitoring), HMRC (RTI spot-check via PAYE Employer queries), umbrella-provider APIs (Parasol, Brookson, Giant — top UK umbrellas)
docs/specs/ULTRAPLAN.md:641:- **External APIs:** Companies House, HMRC (RTI submissions visibility — this is the hard one; access may require Government Gateway credentials at the tenant level), umbrella-provider APIs (which often don't exist publicly — fallback to manual data ingestion)
docs/specs/ULTRAPLAN.md:647:#### A13. T3 Compliance Watchtower (parallel to v1.1 front-office work)
docs/specs/ULTRAPLAN.md:653:- **MCP tools required:** Bullhorn (contractor data), Voyager Infinity / 3R (where used), Companies House
docs/specs/ULTRAPLAN.md:667:| Real-Time Pulse | L (2 weeks) | Microsoft Graph subscriptions + LinkedIn + Companies House watchers | The signal-weighting per tenant is the per-customer config work |
docs/specs/ULTRAPLAN.md:671:| T2 Sunday-Evening Timesheet Ranger | M (1 week) | Bullhorn/Voyager + Microsoft Graph | The voice quality on per-contractor history is the work |
docs/specs/ULTRAPLAN.md:683:| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
docs/specs/ULTRAPLAN.md:711:5. **Companies House** — 6 of 18. Free API, easy build.
docs/specs/ULTRAPLAN.md:712:6. **LinkedIn (via Proxycurl)** — 6 of 18. Third-priority.
docs/specs/ULTRAPLAN.md:745:- Week 1: Agent Bundle v2 pattern refactor; `_shared/` module build; voice loader; escalation codes catalogue; vertical schema v0.1
docs/specs/ULTRAPLAN.md:753:- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint
docs/specs/ULTRAPLAN.md:822:| 6 | LinkedIn rate limits via Proxycurl are tighter than expected | Medium | Medium | Sourcing Scout cost >£100/run | Negotiate Proxycurl enterprise plan; defer Night Sourcer to v1.2 if needed |
packages/harness/cortextos/src/cli/install.ts:259:    // Best-effort: failures degrade voice messages to path-only (no transcript)
packages/agent-renderer/tests/fixtures/test-tenant-vault/test-tenant-b/_config.yaml:5:voice_threshold: 0.80
docs/architecture/second-brain-design.md:18:Discovery sweep: `grep -rn "kb-query\|kb-ingest\|kb-collections\|kb-setup\|knowledge-base\|knowledge\.md" packages/harness/cortextos/templates/` returned 34 files. Eliminating duplicates (the `knowledge-base` skill ships verbatim in `agent`, `analyst`, `orchestrator`, and `agent-codex` template trees), the operationally distinct use cases are:
docs/architecture/second-brain-design.md:74:- The mmrag.py engine, ChromaDB index, Gemini embeddings, venv, and `bus/kb-*.sh` scripts under `packages/harness/cortextos/` are not modified, removed, or shadowed.
docs/architecture/second-brain-design.md:76:- This respects master brief §3.1 ("never edit `packages/harness/cortextos/*` except the four `bus/kb-*.sh` shadow points") without exercising the exception — we don't shadow them at all.
docs/architecture/second-brain-design.md:102:soul-philosophy  system-diagnostics  tasks  tool-registration
docs/architecture/second-brain-design.md:120:└── tests/fixtures/{01-primary, 02-edge-case-X, 99-voice-drift-canary}/
docs/architecture/second-brain-design.md:132:| **R2. Bundle-only** | Renderer writes the cortextOS-compatible per-agent directory from scratch: a minimal `config.json` + `.env` + a thin `CLAUDE.md` that loads only the IFOS-relevant context. No `.claude/skills/` tree copied; IFOS-specific helpers mount in via `agents/_shared/` (master brief §8.1 Change 1 "voice handling moves into `_shared/voice-loader.sh`"). | **No.** IFOS agents have only the skills IFOS explicitly grants them. | Clean separation; outcome **(a)** per the founder's enumeration. |
docs/architecture/second-brain-design.md:162:├── _voice/                                         ← voice profile (Ultraplan §5.1 line 220)
docs/architecture/second-brain-design.md:197:| `_voice/style-guide.md` | one file | markdown | fixed name | Onboarding wizard Day 3 (founder); Concierge edits via Brain UI v1.1+ | every agent's `context.sh` via `_shared/voice-loader.sh` (Ultraplan §6.1 line 322) |
docs/architecture/second-brain-design.md:198:| `_voice/tone-rules.yaml` | one file | YAML | fixed name | Onboarding wizard Day 3 | `_shared/voice-loader.sh hh_load_tone_rules`; `validate.sh` banned-phrase check |
docs/architecture/second-brain-design.md:199:| `_voice/samples/` | one file per sample | markdown with frontmatter | `{epoch}-{rand5}.md` | Onboarding wizard Day 3 (founder pastes 20+ emails); ongoing append per consultant edit (Ultraplan §6.1 line 316) | `voice-loader.sh hh_load_voice_samples` (pgvector top-N retrieval) |
docs/architecture/second-brain-design.md:212:| `wiki/compiled/placements/{slug}.md` | one per Placement | same | same | Concierge (v1.0) on placement event | Cash Conductor (v1.0) for invoice context; future Pulse |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:238:| Placement | **v1.0** | Concierge (v1.0 A6) produces; Cash Conductor (v1.0 A4) reads for invoice context |
docs/architecture/second-brain-design.md:239:| Contact (client-side individual) | **v1.0** | Cash Conductor needs invoice-recipient contacts; Scribe extracts decision-makers from calls; Concierge sends to named contacts. Modeled under `wiki/compiled/people/` |
docs/architecture/second-brain-design.md:362:invoice_id: inv_2026_0042                            # optional; Cash Conductor populates
docs/architecture/second-brain-design.md:453:  - **Founder via Obsidian** writes to `_voice/`, `_playbooks/`, `wiki/raw/notes/`, free-form `## Notes` sections of any compiled entity. Founder has shell access as `ifos-tenant-{slug}` (or runs Obsidian on the same UID via SSHFS/sync — operational detail for the Day 4 infra plan).
docs/architecture/second-brain-design.md:553:  human_diff        TEXT,                                -- for phase=action=edit-then-send: the diff captured for voice corpus
docs/architecture/second-brain-design.md:575:**v1.0 use:** voice corpus only. Ultraplan §6.1 line 314 says "samples/{n}.md — raw samples indexed for RAG retrieval (embedded with pgvector at capture time)" and line 322 says voice-loader.sh retrieves "the 3 most semantically similar past samples to the current task via pgvector cosine similarity."
docs/architecture/second-brain-design.md:580:CREATE TABLE voice_samples_embedded (
docs/architecture/second-brain-design.md:582:  sample_id         TEXT NOT NULL,                       -- {epoch}-{rand5} from _voice/samples/{epoch}-{rand5}.md
docs/architecture/second-brain-design.md:590:CREATE INDEX voice_samples_embedding_idx ON voice_samples_embedded
docs/architecture/second-brain-design.md:593:ALTER TABLE voice_samples_embedded ENABLE ROW LEVEL SECURITY;
docs/architecture/second-brain-design.md:594:CREATE POLICY voice_samples_tenant_isolation ON voice_samples_embedded
docs/architecture/second-brain-design.md:601:2. **Operational simplicity.** One Gemini API key (`GEMINI_API_KEY` in `secrets.env`) serves both cortextOS's KB (its own use) and IFOS's voice corpus. Cost is identical per-token.
docs/architecture/second-brain-design.md:604:**Granularity:** one vector per voice sample (whole-file embedding, not chunked). Voice samples are short (typically 100-400 words per sample); chunking adds no value at this scale and increases the storage / retrieval count.
docs/architecture/second-brain-design.md:622:              │ writes _voice/, _playbooks/, _decisions/,    │ writes wiki/raw/, wiki/compiled/
docs/architecture/second-brain-design.md:628:        │  _voice/ samples/*.md  ─┐                                    │
docs/architecture/second-brain-design.md:636:            /update-     │                              │ on _voice/samples/ change
docs/architecture/second-brain-design.md:640:        │  entities (JSONB +trgm+GIN)│    │  voice_samples_embedded     │
docs/architecture/second-brain-design.md:654:        │  voice-loader.sh hh_load_voice_samples → pgvector ANN        │
docs/architecture/second-brain-design.md:701:- If the file lock times out (5 seconds), the operation fails with `ESC_VAULT_LOCK_TIMEOUT` per master brief §8.1 Change 3 vocabulary (new code; goes in `_shared/escalation-codes.md` v0.1).
docs/architecture/second-brain-design.md:702:- If the Postgres UPDATE fails after 3 retries, the operation fails with `ESC_VAULT_CONCURRENCY` (new code).
docs/architecture/second-brain-design.md:722:1. **Hands-off frontmatter field** — every entity's frontmatter carries an optional `human_editing: true` flag the founder can set in Obsidian when they want a quiet window. While set, agent `update-entity` and `append-to-narrative` operations on this entity return `ESC_HUMAN_EDITING_LOCK` (new code) and re-queue with exponential backoff (1 min, 4 min, 16 min, then escalate to operator via Telegram). The flag is a soft handoff, not a hard guarantee — but it gives the founder explicit control during sensitive edits.
docs/architecture/second-brain-design.md:725:4. **No follow-rename collision** — agents do not use Obsidian's built-in rename feature (we don't have a UI). Rename happens via `update-entity` with a new `display_name`, which triggers `rewrite-backlinks` (§2.6.3). If the human renames a file in Obsidian during this window, the file-path-changes mid-cascade — the cascade detects the rename via the next-scan inotify event and aborts with `ESC_VAULT_RENAME_RACE` (new code), surfacing to the operator.
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:773:| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
docs/architecture/second-brain-design.md:784:These assumptions inform §2.4 and §2.5: hot reads go through Postgres-indexed paths (trigram for fuzzy names, GIN for JSONB attributes, plain indexed columns for id/type lookups); write hot-paths use the atomic-file + Postgres-row pattern; pgvector is reserved for voice (low-latency-tolerant retrieval, not transactional) and stays out of the hot agent paths.
docs/architecture/second-brain-design.md:795:- **§2.4:** four Postgres tables + pgvector voice index + filesystem markdown.
docs/architecture/second-brain-design.md:796:- **§2.6:** concurrency enforced via `flock(2)` + Postgres optimistic concurrency + Obsidian-aware debounce; new escalation codes `ESC_VAULT_*`.
docs/architecture/second-brain-design.md:826:        ├── concurrency.ts       ← flock wrapper + ESC_VAULT_* mapping
docs/architecture/second-brain-design.md:830:Each `wiki-*.sh` is a thin shim execing `node ${SCRIPT_DIR}/../wiki-cli/dist/cli.js <op> "$@"`. Pattern matches cortextOS's 47-script `bus/` layout verbatim (see `packages/harness/cortextos/bus/send-message.sh:22`). Agent invocation from inside PTY:
docs/architecture/second-brain-design.md:890:| **Multi-tenancy enforcement** — how `tenant_slug` is validated at the entry point (master brief §3.5) | Wrapper reads `CTX_TENANT_SLUG` env var (set by PM2 ecosystem per-tenant process group); CLI handler validates that the arg `--tenant` matches the env or fails with `ESC_PII_LEAKAGE_RISK`. Kernel-enforced isolation underneath (POSIX 0700 per Ultraplan §5.1) means a wrong tenant fails at filesystem read. | Server receives `CTX_TENANT_SLUG` at connection setup via MCP server args; rejects any tool call whose `tenant_slug` mismatches the connection identity. Filesystem isolation underneath same as α. One enforcement site. | Library validates `tenant_slug` against env var. Same enforcement model as α, but agent-side discipline depends on skill docs being followed. |
docs/architecture/second-brain-design.md:891:| **Operational complexity** — new infrastructure introduced | None new. 12 shell wrappers + a Node CLI binary + a library; same shape as `packages/harness/cortextos/bus/`. No new PM2 process. | One new PM2 process per machine (`ifos-wiki-mcp`). Adds to the operations surface: process supervision, restart policy, port allocation, logs to manage. At Sovereign tier (one cluster slice per tenant per Ultraplan §5.4) this is one extra process per tenant. | Skill files added to every agent at scaffold time. Under R2 renderer (recommended), the renderer must be extended to inject the wiki skill — additional renderer logic. Under R1, automatic. |
docs/architecture/second-brain-design.md:893:| **Consistency with cortextOS bus convention** | Identical pattern: 47 existing bus wrappers under `packages/harness/cortextos/bus/` all do `exec node dist/cli.js bus <command>`. Option α uses the same 3-line shim shape. Zero cognitive tax for an engineer who already understands cortextOS. | New surface (MCP). Aligns with the vertical-adapter pattern (master brief §3.2) where Bullhorn / Companies House etc. are MCP servers — so consistent with that pattern, not with the bus pattern. | Aligns with cortextOS's skill convention (each template ships `.claude/skills/` with kb / memory / tasks / heartbeat / etc.). Inconsistent with the bus pattern; consistent with the skill pattern; awkward under R2. |
docs/architecture/second-brain-design.md:894:| **v1.0 minimum effort estimate** | ~11-13 days. Breakdown: 12 wrappers × 0.25 day = 3 days; Node CLI + dispatch = 1 day; library (12 ops, concurrency, frontmatter parse/write) = 4-5 days; Postgres migrations = 1 day; pgvector voice integration = 1 day; concurrency tests = 1-2 days. | ~14-17 days. Adds: MCP server scaffolding + tool registration + JSON-RPC handling + PM2 integration + multi-tenant connection-identity validation. The library effort is the same; the server adds ~3-4 days. | ~9-11 days **IF R1**. Under R2, **probably impossible without renderer changes** — adds ~5 days for renderer modification + skill injection logic + per-agent install path. Total under R2: ~14-16 days, **and** undermines R2's clean-separation promise. |
docs/architecture/second-brain-design.md:907:2. **Master brief §8 (Agent Bundle v2 pattern + `tools.yaml` contract).** §8.1 specifies the bundle has `tools.yaml` for "MCP servers + scopes + degraded modes" — i.e. external MCP connectors (Bullhorn, Companies House, Xero). The wiki is **internal** to IFOS, not an external execution backend. Treating wiki ops as bus commands (Option α) keeps `tools.yaml` clean of internal-surface declarations; treating them as MCP tools (Option β) conflates internal-data-access with external-tool-invocation in the same `tools.yaml`.
docs/architecture/second-brain-design.md:938:| Implied: cortextOS KB is the substrate | Explicit: parallel system. cortextOS KB untouched, IFOS owns Postgres entities/links/decision_log + pgvector voice + filesystem markdown |
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/architecture/second-brain-design.md:951:4. **`agents/_shared/voice-loader.sh`** per master brief §8.1 Change 1. Reads voice_samples_embedded via wiki lib. **Week 1-2.**
docs/architecture/second-brain-design.md:967:| **2.1-A** | Master brief §5.1 lines 297-349 vs Ultraplan §5.1 line 220 disagree on vault layout | Two vault structures specified in different docs | Adopt the merged tree in §2.1 of this design: `/vault/{slug}/` top-level (`_voice/ _playbooks/ _decisions/ _config.yaml wiki/ temp/`) with the master brief's `wiki/{raw,compiled,.wiki}/` subtree underneath. Codex ratifies on Day 7 by reading §2.1. | No |
docs/architecture/second-brain-design.md:974:| **2.4-C** | Master brief / Ultraplan silent on embedding model | No model specified for voice_samples_embedded or future compiled/ embeddings | Adopt `gemini-embedding-001` (3072 dims) — matches cortextOS's KB substrate per kb-setup.sh migration target. Same `GEMINI_API_KEY` serves both. Revisit if a sharply better model ships before Week 11. | No |
docs/architecture/second-brain-design.md:975:| **2.6** | Master brief §5 silent on concurrency | No mechanism for agent×agent, agent×human-in-Obsidian, or rewrite-backlinks cascade | Resolved in §2.6.1, §2.6.2, §2.6.3 of this design. Companion document `docs/architecture/vault-concurrency.md` LANDED (Day 3, commit `78680cc`). New escalation codes (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, `ESC_VAULT_RENAME_RACE`) CATALOGUED at `agents/_shared/escalation-codes.md` §2.2 (Day 8 commit `a279226`) + WIRED into `agents/_shared/hook-helpers.sh::autosend_escalate` (Day 8 commit `e6e9df1`). | **Closed 2026-05-20.** Catalogue + wiring complete; ESC codes callable from any rendered agent. |
docs/architecture/second-brain-design.md:976:| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
docs/architecture/second-brain-design.md:983:**Master brief §5.5's v1.0 minimum brain build stays at weeks 11-13, but the scope is materially clarified.** The "shadow four files + 2 .ts files" framing is replaced by "9 wiki-*.sh parallel wrappers + 9 wiki/lib/*.ts modules + 4 Postgres tables with RLS + pgvector for voice samples." Total v1.0 effort: ~11-13 person-days, fitting the 15-day budget. **Three Week-1 prerequisites move into focus:** ADR-003 renderer design (without it, no IFOS agent can run), `vault-concurrency.md` companion document (without it, the `flock`+Postgres-optimistic-concurrency code can't be reviewed), and `agents/_shared/{voice-loader,hook-helpers}.sh` (without these, the wiki library has no calling conventions). **One Day-4 (this week) tightening:** the Postgres schema migration from `entity_graph` (single table) to `entities` + `entity_links` (two tables) is part of the master brief §6 Day 4 infra task, not deferred. v1.2 graph view and v2.0 LoRA scale-tier are forward-compatible under the chosen Option α with no architectural changes.
packages/agent-renderer/tests/fixtures/test-tenant-vault/migration-test/_config.yaml:5:voice_threshold: 0.75
docs/specs/_archive-build-handoff.md:55:│  • MCP connectors (Bullhorn, MS Graph, Companies House) │
docs/specs/_archive-build-handoff.md:193:3. Reuse before build — agents use _shared/ modules. No agent writes its own logging, voice handling, or approval gate.
docs/specs/_archive-build-handoff.md:205:- tests/fixtures/01-primary/, 02-edge-case-*/, 99-voice-drift-canary/
docs/specs/_archive-build-handoff.md:266:Also Day 4: scope the first MCP server (Bullhorn) — document the `tools.yaml` shape per the Pattern Reference and the Composio/AgentMail adoption doc §3.5. Note: per the adoption doc, Bullhorn is **first-party MCP** (vertical-specific). Composio is *not* the path for it.
docs/specs/_archive-build-handoff.md:331:mkdir -p agents/janitor/tests/fixtures/{01-primary,02-edge-case-merged-duplicates,99-voice-drift-canary}
docs/specs/_archive-build-handoff.md:341:# Then the fixtures (01-primary, 02-edge-case, 99-voice-drift-canary) with golden outputs.
docs/specs/_archive-build-handoff.md:351:- Implementing `_shared/hook-helpers.sh` extensions (voice loader, decision-log writer)
docs/specs/_archive-build-handoff.md:377:| 1 | **Diagnostic** | 3–4 | LinkedIn + Companies House + web scrape | Sales tool — needed for pitch before any other agent matters |
docs/specs/_archive-build-handoff.md:382:| 6 | **Concierge** | 10–13 | Bullhorn + Microsoft Graph + AgentMail | First Tier 1 always-on closing demo; 4-week build |
docs/specs/_archive-build-handoff.md:390:## 6. The Composio/AgentMail boundary — critical for tools.yaml
docs/specs/_archive-build-handoff.md:394:**Composio adopted for commodity SaaS only:**
docs/specs/_archive-build-handoff.md:398:**Composio rejected for vertical systems:**
docs/specs/_archive-build-handoff.md:400:- Companies House, Xero, QuickBooks, FreeAgent, Sage, HMRC MTD
docs/specs/_archive-build-handoff.md:403:**AgentMail adopted as the inbox layer for one agent only:**
docs/specs/_archive-build-handoff.md:407:**The architectural rule (§3 of that document):** agents call adapters, adapters call execution backends. No `agent.md`, no `tools.yaml` `required:` block, no eval fixture references Composio or AgentMail by name. The adapter boundary is enforced in code review.
docs/specs/_archive-build-handoff.md:409:**For Day 4 (first MCP scope):** Bullhorn is first-party. Composio is not the path. Build the connector at `packages/mcp-connectors/bullhorn/` per the Pattern Reference's `tools.yaml` shape.
docs/specs/_archive-build-handoff.md:419:3. **Reuse before build** — every agent uses shared `_shared/` modules. No agent writes its own logging, its own voice handling, its own approval gate.
docs/specs/_archive-build-handoff.md:432:- **The 99-voice-drift-canary fixture** is new in v2. Every agent has one. Run weekly in CI; output diffed against historical baselines. This is your structural early-warning for voice rot as the corpus grows.
docs/specs/_archive-build-handoff.md:450:| "Let me use Composio for the Bullhorn connector..." | §6 of this doc |
docs/specs/_archive-build-handoff.md:478:- Ship an agent without a 99-voice-drift-canary fixture because "we'll add it later"
docs/operations/codex-ratification-guide.md:176:no submodule modifications proposed; no Composio/AgentMail in tools.yaml; vault/
docs/specs/PRODUCT-SPEC.md:66:- **Output contract:** Every email, LinkedIn InMail, and website contact-form submission gets a personalised reply within 60 seconds, in firm voice, at any hour. Draft for sensitive categories, auto-send for pre-approved categories. A single Telegram message at 09:00 surfaces overnight inbounds the consultant should look at first.
docs/specs/PRODUCT-SPEC.md:71:- **Per-tenant config:** mailbox OAuth list, auto-send approval categories, escalation thresholds, voice profile path, firm-specific suppressions (named recruiters whose emails always escalate).
docs/specs/PRODUCT-SPEC.md:75:- **Output contract:** Every invoice has a live status — sent, opened, escalating, paid. Payment lands → consultant gets the commission notification within minutes. Aged debt sweep runs at 07:00 with three drafted chase emails per debtor (soft, firm, escalation) ready for one-click approval.
docs/specs/PRODUCT-SPEC.md:84:- **Output contract (digest mode):** Monday 06:00 — 5–8 named BD opportunities with hiring signal, decision-maker identified, relationship history checked, salary benchmark, and drafted outreach in firm voice. Every Friday — a one-pager review of the week's BD outcomes.
docs/specs/PRODUCT-SPEC.md:112:- **Output contract:** Every call (Fathom, Fireflies, Ringover) gets parsed into ATS structured fields *and* tacit notes that don't fit any field: "client said they'd never hire from Bank X because of a 2019 grudge", "candidate's actual reason for leaving is the new line manager, not the salary". Tacit notes power every other agent's voice and judgement.
docs/specs/PRODUCT-SPEC.md:121:- **Output contract:** Every active candidate and every placed client gets the right comms at the right time, in firm voice, drafted (Solo/Boutique) or auto-sent (Growth+): post-interview chase, post-rejection care, post-placement check-ins at week 1 / month 1 / month 3 / month 6 / month 12 / month 24. Plus referral-extraction prompts every 6 months for the first 24 months post-placement.
docs/specs/PRODUCT-SPEC.md:126:- **Per-tenant config:** nurture cadence per stage, voice tone per stage, referral-prompt templates, lifecycle-stage to comms-template mapping, do-not-contact flags.
docs/specs/PRODUCT-SPEC.md:130:- **Output contract:** Continuous health score per client across email engagement, LinkedIn activity at the company, Companies House filings, placed-candidate signals (a placed candidate posting "new chapter" → likely about to leave). Within hours of a critical signal, the senior consultant gets a Telegram nudge with context and drafted re-engagement.
docs/specs/PRODUCT-SPEC.md:175:- **Output contract:** Pre-sales — runs against any UK recruitment firm's public footprint (Companies House, careers page, public ATS data, LinkedIn signals). Produces a 12-page audit identifying the firm's specific operational pain. Used as the cold-outreach hook and the discovery-call agenda.
docs/specs/PRODUCT-SPEC.md:194:- **Output contract:** Friday 17:00 cutoff. Sunday 19:00–21:00 — Ranger sends soft, personalised nudges to outstanding contractors in firm voice. Monday 09:00 — harder sweep on the residual with client-approver Cc. Per-contractor history informs the tone (holiday vs serial offender vs slow-approver client).
docs/specs/PRODUCT-SPEC.md:226:- **Output contract:** Every day: hours-to-agency vs hours-to-umbrella vs hours-to-client, charge-rate vs pay-rate vs invoice-amount, employer-NIC vs margin. Flags discrepancies to FD with one-click correction draft.
docs/specs/PRODUCT-SPEC.md:245:| **Scale** (26–50 fee earners) | £6,950 | All Growth + per-firm LoRA adapter + Sovereign-tier inference (UK on-prem) + priority support | "Half a junior recruiter replaced per consultant in operational drag. Per-firm voice that's genuinely indistinguishable from your top performer. £820k–£1.4M of demonstrable annual value created." |
docs/specs/PRODUCT-SPEC.md:268:                  │  canonical entities, voice, escalations  │
docs/specs/PRODUCT-SPEC.md:274:       │  voice profile, playbooks, candidate/client/brief data   │
docs/specs/PRODUCT-SPEC.md:297:The story for the customer: **"Every agent makes every other agent smarter. The Scribe captures your senior consultant's judgement → the Concierge writes in that judgement's voice → the Client Hunter pitches BD using that judgement's framing → the Pulse watches relationships through that judgement's lens. After 6 months, the system writes in your firm's voice better than your second-best consultant does."**
docs/specs/PRODUCT-SPEC.md:299:This is the answer to "why not just use ChatGPT" — ChatGPT doesn't know your placements, your voice, your decisions, or your firm's specific judgement patterns. The Vault + Decision Log + per-firm LoRA stack does.
docs/specs/PRODUCT-SPEC.md:312:2. **The per-tenant `/vault/{tenant}/` directory** — voice profile, playbooks, ICP definition, target patch, brand templates, banned phrases, customer-specific suppression lists.
docs/specs/PRODUCT-SPEC.md:334:- AI-guided wizard: customer pastes 10–20 sample emails from their top performer; system extracts voice profile, tone rules, banned phrases.
docs/specs/PRODUCT-SPEC.md:336:- `/vault/{tenant}/_voice/style-guide.md` saved.
docs/specs/PRODUCT-SPEC.md:345:- Cash Conductor runs against historical invoices — produces the DSO baseline.
docs/specs/PRODUCT-SPEC.md:347:- End-of-day call: 30 minutes, walk through outputs, confirm voice quality.
docs/specs/PRODUCT-SPEC.md:358:- `common-voice.json` — paths to voice profile, banned phrases, tone rules
docs/specs/PRODUCT-SPEC.md:381:2. **"Add it to your vault as a markdown file — the agents will read it on next run."** This is the answer for tone, voice, playbook, suppression-list, and similar text-based asks. ~25% of the time.
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:413:- **Intel Force OS layer:** vertical schema, agent definitions (the `agent.md` files), MCP connectors to ATS / accounting / Microsoft Graph / Companies House, vault syncer, decision log, per-tenant adapter training pipeline, Brain UI.
docs/specs/PRODUCT-SPEC.md:528:7. **Concierge** — "No candidate ghosted, no client check-in missed, every comms in your voice."
docs/operations/codex-round-2-handoff.md:82:| 11 | `docs/decisions/v1.0-kill-criterion.md` | Trigger 1 date + Trigger 2 CLI + Trigger 4 threshold | RATIFY (all three fixed) |
docs/operations/codex-round-2-handoff.md:84:| 13 | `docs/verticals/recruitment/vertical-schema.yaml` | voice_classifier_score CHECK + empty access + versioning count | RATIFY (all three fixed) |
packages/agent-renderer/pnpm-lock.yaml:400:    resolution: {integrity: sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==}
packages/agent-renderer/pnpm-lock.yaml:587:    resolution: {integrity: sha512-FJHFfqpKUI3A10WrWKiFbBZ7yVbGT4q4B5o1qKFFojqpaYoh9LrQgqWCmmcxQzVSXYtyB5bzkXrYzlHTs21MYA==}
packages/agent-renderer/pnpm-lock.yaml:642:    resolution: {integrity: sha512-QVTUovf40zgTqlFVrKA1uXMVvU2QWEFWfAH8Wdc48IxLvrJMQVMBRjuQyUpzZCDkakImib9eVazbWlC6ksWtJw==}
packages/agent-renderer/pnpm-lock.yaml:864:    resolution: {integrity: sha512-//nshmD55c46FuFw26xV/xFAaB5HF9Xdap7HJBBnrKdAd6/GxDBaNA1870O79+9ueg61cZLSVc+OaFlfmObYVQ==}
packages/agent-renderer/pnpm-lock.yaml:1019:    resolution: {integrity: sha512-o5a9xKjbtuhY6Bi5S3+HvbRERmouabWbyUcpXXUA1u+GNUKoROi9byOJ8M0nHbHYHkYICiMlqxkg1KkYmm25Sw==}
docs/_supplementary/PRD-autonomous-agent.md:257:**Niche**: AI business automation (voice agents, chatbots, automation workflows)  
docs/_supplementary/PRD-autonomous-agent.md:637:  topic_priority: 'voice_agents' | 'chatbots' | 'automation' | 'business_results' | 'industry_insights' | 'personal_brand';
docs/_supplementary/PRD-autonomous-agent.md:673:- Rotate through pillars: voice_agents, chatbots, automation, business_results, industry_insights
docs/_supplementary/PRD-autonomous-agent.md:680:  "topic_priority": "voice_agents|chatbots|automation|business_results|industry_insights|personal_brand",
docs/_supplementary/PRD-autonomous-agent.md:1035:- Niche: AI business automation (voice agents, chatbots, workflows)
docs/_supplementary/PRD-autonomous-agent.md:1244:  voiceId: string;         // Angela or Hope (ElevenLabs V3 native)
docs/_supplementary/PRD-autonomous-agent.md:1268:        voice: {
docs/_supplementary/PRD-autonomous-agent.md:1271:          voice_id: config.voiceId,
docs/_supplementary/PRD-autonomous-agent.md:1571:      "key": "screen_voiceagent_booking_01",
docs/_supplementary/PRD-autonomous-agent.md:1573:      "path": "workspace/assets/videos/screen_voiceagent_booking_01.mp4",
docs/_supplementary/PRD-autonomous-agent.md:1576:      "topics": ["voice_agents", "booking", "automation"],
docs/_supplementary/PRD-autonomous-agent.md:1785:- "Reject text_card template when topic is voice_agents"
docs/_supplementary/PRD-autonomous-agent.md:2121:- [ ] Record 5+ screen recordings: chatbot demo, voice agent, workflow builder, dashboard, client call
docs/_supplementary/PRD-autonomous-agent.md:2485:HEYGEN_VOICE_ID=...         # Angela or Hope voice ID
packages/agent-renderer/tests/fixtures/test-agent/tools.yaml:9:  - ESC_SCHEMA_VIOLATION
docs/operations/codex-round-2-remediation-prompt.md:162:    - agents/_shared/voice-loader.sh (every voice corpus read)
docs/operations/codex-round-2-remediation-prompt.md:172:  Specifically in voice-loader.sh::_vl_psql_query: wrap the wrapped SQL
docs/operations/codex-round-2-remediation-prompt.md:180:    bash agents/_shared/tests/test-voice-loader.sh
docs/operations/codex-round-2-remediation-prompt.md:187:                              agents/_shared/voice-loader.sh
docs/operations/codex-round-2-remediation-prompt.md:203:      voice-loader — none of which reference Bullhorn). A+B MUST flip
docs/operations/codex-round-2-remediation-prompt.md:247:         (from packages/harness/cortextos/src/types/index.ts lines 117-121):
docs/operations/codex-round-2-remediation-prompt.md:257:           diagnostic_email_send               → external-comms
docs/operations/codex-round-2-remediation-prompt.md:258:           diagnostic_calendar_invite          → external-comms
docs/operations/codex-round-2-remediation-prompt.md:402:    - hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh  (FIX 5)
docs/operations/codex-round-2-remediation-prompt.md:429:     - All test suites still pass (hook-helpers 20/20 + voice-loader 9/9 +
docs/operations/codex-round-2-remediation-prompt.md:471:git add agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh \
docs/operations/codex-round-2-remediation-prompt.md:503:    - hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh:
docs/operations/codex-round-2-remediation-prompt.md:584:7. Re-run agents/_shared/tests/test-hook-helpers.sh + test-voice-loader.sh
docs/operations/codex-round-2-remediation-prompt.md:622:5. hook-helpers.sh + voice-loader.sh + run-codex-ratification.sh transaction wrapping (Risk #11 mitigation across all runtime helpers)
packages/mcp-connectors/companies-house/src/rate-limit.ts:1:// Rate limiter for Companies House. CH documented: 600 requests / 5-min
packages/mcp-connectors/companies-house/src/client.ts:1:// HTTP client for Companies House REST API.
docs/_supplementary/build-plan-original.md:167:- Tone matches brand voice profile? (0–5)
docs/_supplementary/build-plan-original.md:200:- **Tier 1 (always present)** — `CLAUDE.md` (4KB max). Client name, industry, voice summary, key people, brand do/don'ts. This is the brain stem.
docs/_supplementary/build-plan-original.md:288:- **Companies House API** (free, UK-authoritative firmographic data) — primary source for UK SMEs
docs/_supplementary/build-plan-original.md:312:- Companies House rate limits (600/5min — respected via in-memory counter)
docs/_supplementary/build-plan-original.md:354:- Tenant's brand voice profile (from vault)
docs/_supplementary/build-plan-original.md:377:## Client voice profile
docs/_supplementary/build-plan-original.md:378:<content of /vault/brand/voice-profile.md>
docs/_supplementary/build-plan-original.md:440:- [ ] Tone matches voice profile (run your own rubric check)
docs/_supplementary/build-plan-original.md:465:- Brand voice match 0–5
docs/_supplementary/build-plan-original.md:525:- Brand voice profile
docs/_supplementary/build-plan-original.md:579:From a one-line brief, produce long-form content (articles, scripts, thought-leadership posts) in the client's voice.
docs/_supplementary/build-plan-original.md:582:**First-pass publish rate** — % of generated drafts that get published without substantive human edits. Target: >50% at month 3. Higher as voice profile matures.
docs/_supplementary/build-plan-original.md:590:**Sonnet 4.6** baseline. Opus 4.7 for Tier 2+ clients whose voice is highly distinctive or technical.
docs/_supplementary/build-plan-original.md:594:- The client's voice profile (≥5 sample pieces, ingested at onboarding)
docs/_supplementary/build-plan-original.md:606:- **Context** — voice profile + 3 retrieved past pieces + brief
docs/_supplementary/build-plan-original.md:609:  2. Draft section by section, maintaining voice
docs/_supplementary/build-plan-original.md:615:- **Quality gates** — length within 10% of brief, no banned phrases from voice profile, no obvious AI tells ("In today's fast-paced world", "Let's dive in", etc.)
docs/_supplementary/build-plan-original.md:649:Medium. The integrations are light; the voice profile ingestion (§19.3) is where the real engineering goes.
docs/_supplementary/build-plan-original.md:671:- Brand voice profile
docs/_supplementary/build-plan-original.md:727:- Brand voice
docs/_supplementary/build-plan-original.md:760:DocuSign webhook `envelope-completed` or Stripe webhook `invoice.paid` (whichever signals "new client" in this client's workflow, configured in wizard).
docs/_supplementary/build-plan-original.md:895:**Not a Claude Code sub-agent.** Voice-first systems have hard real-time constraints (sub-500ms response) that Claude Code isn't built for. Use a dedicated voice platform:
docs/_supplementary/build-plan-original.md:896:- **Vapi** (best-in-class developer voice platform, supports Claude via proxy, ~$0.05/min)
docs/_supplementary/build-plan-original.md:914:- Out-of-hours behaviour (voicemail? emergency line?)
docs/_supplementary/build-plan-original.md:1004:4. Optional: analyze past ad performance for voice/structure that worked
docs/_supplementary/build-plan-original.md:1069:[Voice Profile Ingester] — processes uploaded brand docs → voice-profile.md
docs/_supplementary/build-plan-original.md:1115:- Brand voice quick-capture: 3 adjectives + 3 banned adjectives + one-sentence "we would never say..."
docs/_supplementary/build-plan-original.md:1133:  - Generates draft voice profile
docs/_supplementary/build-plan-original.md:1174:7. Billing — current month, forecast, invoice history
docs/_supplementary/build-plan-original.md:1264:| Companies House | No | Build your own (easy — free API) |
docs/_supplementary/build-plan-original.md:1350:- Third-party APIs (Prospeo, Cognism, etc.): track per-tenant calls in your own DB, reconcile monthly with provider invoices.
docs/_supplementary/build-plan-original.md:1358:- Next invoice date
docs/_supplementary/build-plan-original.md:1369:- Setup fees (one-off invoice)
docs/_supplementary/build-plan-original.md:1439:- **Approve with edits** — inline edit, then fire. Edits feed back into the voice profile.
packages/harness/cortextos/tests/sprint1-templates.test.ts:283:        'context.json', 'goals.json', 'brand-voice.md',
packages/harness/cortextos/community/agents/agent/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/community/agents/agent/SOUL.md:54:- External: org brand voice, professional, opinionated when asked
docs/operations/codex-ratification-execution-plan.md:101:- [ ] Submodule boundary (read-only on packages/harness/cortextos/)
docs/operations/codex-ratification-execution-plan.md:102:- [ ] Adapter boundary (no Composio/AgentMail names in agent.md/tools.yaml/fixtures)
docs/operations/codex-ratification-execution-plan.md:168:| 26 | voice-loader.sh + tests | `agents/_shared/voice-loader.sh` + `tests/test-voice-loader.sh` | A |
docs/operations/codex-ratification-execution-plan.md:348:Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:560:  test('processes voice message', async () => {
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:561:    mock.storeFile('voice_id', Buffer.from('ogg-data'));
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:569:      voice: { file_id: 'voice_id', duration: 5 },
packages/harness/cortextos/tests/playwright/telegram-api.spec.ts:574:    expect(result!.type).toBe('voice');
packages/agent-renderer/tests/fixtures/test-agent/tests/fixtures/99-voice-drift-canary/input.txt:1:voice drift canary
packages/mcp-connectors/companies-house/src/cache.ts:1:// Disk cache for Companies House responses. 7-day TTL per tools.yaml.
docs/operations/goal-week-3-polish-and-scaffold.md:5:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:8:**Builds on:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 Diagnostic v0 — completed at commit `97a57a2`).
docs/operations/goal-week-3-polish-and-scaffold.md:19:4. **`docs/specs/ULTRAPLAN.md`** §8.1 in full (per-agent A1-A6 specs, lines 495-572) + §9 (Bullhorn critical path, lines 720-770) + §10 (risk rows + contingencies)
docs/operations/goal-week-3-polish-and-scaffold.md:26:11. **`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`** (today's sequencing change)
docs/operations/goal-week-3-polish-and-scaffold.md:27:12. **`agents/recruitment/diagnostic/agent.md`** in full (the gold-standard agent.md to model from)
docs/operations/goal-week-3-polish-and-scaffold.md:31:16. **`docs/operations/goal-option-c-diagnostic-end-to-end.md`** (Day-13 Diagnostic build; reference for Week-3 polish steps)
docs/operations/goal-week-3-polish-and-scaffold.md:33:After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Six v1.0 agents: [list with weeks]. ULTRAPLAN §8.1 agent line ranges: [A1 lines 495-505, A2 lines 507-514, ...]. Week-3 scope confirmed. Ready to begin Step 1."**
docs/operations/goal-week-3-polish-and-scaffold.md:43:1. **Companies House data flows end-to-end.** Founder has registered the API key (Step 2). Re-running cycle.sh against Hays plc produces §1 + §10 + §11 with REAL CH data (not "no registration found"). Updated artefact at `docs/artefacts/diagnostic-hays-plc-2026-05-2X.md`.
docs/operations/goal-week-3-polish-and-scaffold.md:45:3. **§12 conversation opener is LLM-driven, not deterministic.** Calls Claude API (or OpenAI fallback) with §1-§11 context + tenant voice corpus + tone rules. Voice classifier microservice STUB in place (real classifier W4-5; for now: skip-with-warning preserved).
docs/operations/goal-week-3-polish-and-scaffold.md:50:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:51:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:52:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:53:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:54:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:63:- §7 Voice + tone constraints (`hh_load_tone_rules` filter; voice classifier threshold)
docs/operations/goal-week-3-polish-and-scaffold.md:93:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:105:| Proxycurl signup | Founder commercial action; gated on founder decision (cost ~$39/mo); if founder approves mid-week, wire LinkedIn deep data into Diagnostic |
docs/operations/goal-week-3-polish-and-scaffold.md:106:| Voice classifier microservice | Reserved for W4-5 polish; for Week 3, §12 LLM call skips voice-classifier gate (V3 stays as a skipped-with-warning) |
docs/operations/goal-week-3-polish-and-scaffold.md:110:| Modifying `_shared/hook-helpers.sh` or `_shared/voice-loader.sh` beyond bug fixes | These are foundational substrate; 29/29 tests pass; treat as stable |
docs/operations/goal-week-3-polish-and-scaffold.md:122:| Step 2 | Companies House API key | Founder registers self-service at `https://developer.company-information.service.gov.uk/`; saves to `/vault/migration-test/_secrets.env` (VPS) OR `~/.ifos-local-vault/migration-test/_secrets.env` (local). NEVER pasted in chat. |
docs/operations/goal-week-3-polish-and-scaffold.md:150:(cd packages/diagnostic-generator && pnpm build)
docs/operations/goal-week-3-polish-and-scaffold.md:154:(cd packages/diagnostic-generator && pnpm test) | tail -3
docs/operations/goal-week-3-polish-and-scaffold.md:156:bash agents/_shared/tests/test-voice-loader.sh | tail -3
docs/operations/goal-week-3-polish-and-scaffold.md:163:#### Step 2 — Founder gate: Companies House API key registration
docs/operations/goal-week-3-polish-and-scaffold.md:167:> Founder action needed: register for Companies House API key at `https://developer.company-information.service.gov.uk/` (verified 2026-05-24). 15 minutes self-service. Save the key via SSH to the VPS:
docs/operations/goal-week-3-polish-and-scaffold.md:189:Edit `packages/diagnostic-generator/src/sections/online-footprint.ts`:
docs/operations/goal-week-3-polish-and-scaffold.md:196:pnpm test --filter @ifos/diagnostic-generator
docs/operations/goal-week-3-polish-and-scaffold.md:197:pnpm typecheck --filter @ifos/diagnostic-generator
docs/operations/goal-week-3-polish-and-scaffold.md:200:Commit: `fix(diagnostic): LinkedIn slug suffix-strip — Hays plc → linkedin.com/company/hays`
docs/operations/goal-week-3-polish-and-scaffold.md:204:Edit `packages/diagnostic-generator/src/sections/conversation-opener.ts`:
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-week-3-polish-and-scaffold.md:212:   - **Retry:** if response shape malformed, retry once; if still bad, fall back to deterministic logic + emit `ESC_VOICE_DRIFT` warning row.
docs/operations/goal-week-3-polish-and-scaffold.md:217:   - Tone-rule violation in LLM output → retry then ESC_VOICE_DRIFT
docs/operations/goal-week-3-polish-and-scaffold.md:221:pnpm test --filter @ifos/diagnostic-generator
docs/operations/goal-week-3-polish-and-scaffold.md:222:pnpm typecheck --filter @ifos/diagnostic-generator
docs/operations/goal-week-3-polish-and-scaffold.md:223:pnpm build --filter @ifos/diagnostic-generator
docs/operations/goal-week-3-polish-and-scaffold.md:226:Commit: `feat(diagnostic): §12 LLM-driven conversation opener with voice-corpus context`
docs/operations/goal-week-3-polish-and-scaffold.md:232:rm -f ~/.ifos-local-vault/migration-test/diagnostic-reports/*.md
docs/operations/goal-week-3-polish-and-scaffold.md:234:export CTX_AGENT_DIR=$(pwd)/agents/recruitment/diagnostic
docs/operations/goal-week-3-polish-and-scaffold.md:237:bash agents/recruitment/diagnostic/cycle.sh --firm "Hays plc" --sector recruitment
docs/operations/goal-week-3-polish-and-scaffold.md:247:Copy to `docs/artefacts/diagnostic-hays-plc-2026-05-2X.md` (where X is the run date).
docs/operations/goal-week-3-polish-and-scaffold.md:249:Commit: `milestone(diagnostic): Hays plc full-data re-run — real CH + LLM §12`
docs/operations/goal-week-3-polish-and-scaffold.md:258:1. `agents/recruitment/diagnostic/agent.md` — re-ratify (was Round-3 RATIFIED at scaffold; now production-shape)
docs/operations/goal-week-3-polish-and-scaffold.md:259:2. `agents/recruitment/diagnostic/tools.yaml`
docs/operations/goal-week-3-polish-and-scaffold.md:260:3. `agents/recruitment/diagnostic/cycle.sh` (post-Day-13 generator wiring)
docs/operations/goal-week-3-polish-and-scaffold.md:261:4. `agents/recruitment/diagnostic/validate.sh` (post-Day-13 V2 fix)
docs/operations/goal-week-3-polish-and-scaffold.md:262:5. `packages/diagnostic-generator/` (the package as a whole; ratifies via `review-architecture-decision.md` skill)
docs/operations/goal-week-3-polish-and-scaffold.md:263:6. `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` (Day-13 sequencing decision)
docs/operations/goal-week-3-polish-and-scaffold.md:274:bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic
docs/operations/goal-week-3-polish-and-scaffold.md:277:Captures verdicts in `logs/codex-ratification/round-4/diagnostic/`. Each artefact: RATIFIED | NEEDS-REMEDIATION | REJECTED.
docs/operations/goal-week-3-polish-and-scaffold.md:284:Commit: `decision(codex-round-4): diagnostic verdicts — <N> RATIFIED / <M> REJECTED`
docs/operations/goal-week-3-polish-and-scaffold.md:292:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:301:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:308:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_BULLHORN_WRITE_FAIL, ESC_SCHEMA_VIOLATION, ESC_RATE_LIMIT_HIT, ESC_AUTOSEND_YELLOW_SPOT_CHECK.
docs/operations/goal-week-3-polish-and-scaffold.md:330:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:336:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§4 Workflow:** ~10 steps. Webhook from Fathom → transcript fetch → LLM field-extraction → schema validation against vertical-schema.yaml fields → Bullhorn write (yellow tier with spot-check) → tacit-note generation (consultant voice via voice-loader) → Bullhorn attach → operator notify if confidence <0.8.
docs/operations/goal-week-3-polish-and-scaffold.md:341:- **§5 Gate A:** validate.sh hard-fails on missing transcript, field-extraction confidence <0.6, Bullhorn write FK-violation, voice-classifier <0.75 on tacit note.
docs/operations/goal-week-3-polish-and-scaffold.md:343:- **§6 Escalation codes:** ESC_BULLHORN_WRITE_FAIL, ESC_VOICE_DRIFT, ESC_SCHEMA_VIOLATION, ESC_FIELD_EXTRACTION_LOW_CONFIDENCE.
docs/operations/goal-week-3-polish-and-scaffold.md:344:- **§7 Voice + tone:** tacit-note is consultant-voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:345:- **§8 Build prerequisites:** Bullhorn MCP connector (R+W) + Fathom/Fireflies MCP connector (founder commercial signup) + LLM extraction prompt + voice classifier microservice (W5+).
docs/operations/goal-week-3-polish-and-scaffold.md:358:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:359:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:365:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **§1 Output contract:** reconciles invoices against bank deposits; chases overdue payments via approved orange-tier email drafts (consultant approves before send); writes payment status updates to accounting system; generates weekly cash-flow report to `/vault/<tenant>/cash-conductor-reports/`. No Bullhorn dependency — operates entirely against Xero / QuickBooks / Sage + Open Banking.
docs/operations/goal-week-3-polish-and-scaffold.md:368:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:369:- **§4 Workflow:** ~14 steps. Cron daily 06:00 UTC. Fetch open invoices (Xero/QB/Sage rotation per tenant config) → fetch bank transactions (Open Banking) → match invoices ↔ deposits → identify unmatched + overdue → generate chase drafts → write reconciliation rows → weekly report assembly (Mondays).
docs/operations/goal-week-3-polish-and-scaffold.md:370:- **§5 Gate A:** validate.sh hard-fails on accounting API auth failure, bank API auth failure, reconciliation false-positive rate >2%, chase-draft content failing voice classifier.
docs/operations/goal-week-3-polish-and-scaffold.md:371:- **§5 Gate B:** ≥95% invoice match accuracy (vs human spot-check) + ≥15% reduction in days-sales-outstanding (DSO) after 60 days operation.
docs/operations/goal-week-3-polish-and-scaffold.md:372:- **§6 Escalation codes:** ESC_ACCOUNTING_AUTH, ESC_BANK_AUTH, ESC_RECONCILIATION_AMBIGUOUS, ESC_AUTOSEND_BLOCKED.
docs/operations/goal-week-3-polish-and-scaffold.md:373:- **§7 Voice + tone:** chase drafts are voice-classified; ESC_VOICE_DRIFT if <0.75.
docs/operations/goal-week-3-polish-and-scaffold.md:387:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:393:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:397:- **§4 Workflow:** ~10 steps. Brief fetch → keyword extraction → Bullhorn candidate search (filtered) → LinkedIn search (via Proxycurl or equiv) → semantic ranking → confidence scoring → match rationale generation → report assembly.
docs/operations/goal-week-3-polish-and-scaffold.md:400:- **§6 Escalation codes:** ESC_BULLHORN_AUTH, ESC_LINKEDIN_AUTH, ESC_RATE_LIMIT_HIT, ESC_BRIEF_UNDERSPECIFIED.
docs/operations/goal-week-3-polish-and-scaffold.md:401:- **§7 Voice + tone:** N/A (internal output; no customer-facing voice).
docs/operations/goal-week-3-polish-and-scaffold.md:402:- **§8 Build prerequisites:** Bullhorn MCP read + LinkedIn integration (Proxycurl signup OR LinkedIn API partner-tier) + ranking model (LLM-based or embedding-based).
docs/operations/goal-week-3-polish-and-scaffold.md:413:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:420:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:425:- **§5 Gate A:** validate.sh hard-fails on missing approval-bridge auth (if D1-A bridge), voice classifier <0.75, tone-rule block-severity hit, schema violation, orange-tier-spot-check sample selected.
docs/operations/goal-week-3-polish-and-scaffold.md:427:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:428:- **§7 Voice + tone:** highest stakes of any agent — customer-facing sends. Voice classifier required (no skip). Tone rules strict (block-severity hit = ESC_TONE_RULE_VIOLATION).
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/goal-week-3-polish-and-scaffold.md:498:| LLM call rate-limited or 5xx (Step 4 runtime) | Built-in retry once; fall back to deterministic; emit ESC_VOICE_DRIFT warning |
docs/operations/goal-week-3-polish-and-scaffold.md:499:| Voice corpus empty for migration-test (Step 4 ANN query) | hh_load_voice_samples returns empty array; LLM call proceeds with generic context; flag in commit message as W4 polish item |
docs/operations/goal-week-3-polish-and-scaffold.md:502:| Companies House API key returns 401 (invalid key) | Founder re-registers (free; key may be revoked if not used in N days per CH policy); retry after new key saved |
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Founder approves Proxycurl signup mid-week | Wire LinkedIn deep data into Diagnostic via a new `@ifos/linkedin-proxycurl` package (similar to companies-house pattern); commit as separate slice; out of scope for goal §1 but high-value |
docs/operations/goal-week-3-polish-and-scaffold.md:523:- Step 2: Companies House API key registration
docs/operations/goal-week-3-polish-and-scaffold.md:529:- Any external service requiring paid signup (Proxycurl, Fathom, Xero dev, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:547:- packages/diagnostic-generator/ (as a whole package)
docs/operations/goal-week-3-polish-and-scaffold.md:555:bash scripts/run-codex-ratification.sh --round 4 --subset diagnostic
docs/operations/goal-week-3-polish-and-scaffold.md:589:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:594:7. **Voice + tone (§7) integrates with `_shared/voice-loader.sh`.** No alternative voice system invented.
docs/operations/goal-week-3-polish-and-scaffold.md:624:  <SHA>  fix(diagnostic): LinkedIn slug suffix-strip
docs/operations/goal-week-3-polish-and-scaffold.md:625:  <SHA>  feat(diagnostic): §12 LLM-driven conversation opener
docs/operations/goal-week-3-polish-and-scaffold.md:626:  <SHA>  milestone(diagnostic): Hays plc full-data re-run
docs/operations/goal-week-3-polish-and-scaffold.md:628:  <SHA>  decision(codex-round-4-diagnostic): N RATIFIED / M REJECTED
docs/operations/goal-week-3-polish-and-scaffold.md:640:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:650:    - Diagnostic voice classifier microservice
docs/operations/goal-week-3-polish-and-scaffold.md:651:    - Diagnostic LinkedIn deep data (if Proxycurl signed up)
docs/operations/goal-week-3-polish-and-scaffold.md:660:  - <Proxycurl signup if approved>
docs/operations/goal-week-3-polish-and-scaffold.md:670:  - Approve Proxycurl signup ($39/mo)?
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 6 | LLM-driven §12 produces opener that fails voice classifier consistently | Medium | Deterministic fallback already in place; flag as W4 polish (real voice classifier wires up later) |
docs/operations/goal-week-3-polish-and-scaffold.md:686:| 7 | The 5 agent.md scaffolds drift in style across days (different writing voice on different days) | Medium | Each scaffold re-reads Diagnostic's agent.md FIRST as the structural template; commit message references the structural anchor |
packages/mcp-connectors/companies-house/src/types.ts:1:// TypeScript types for Companies House REST API responses.
docs/operations/seedlegals-engagement-queries.md:46:>    - **AI model training corpus** for the SaaS vendor's voice fine-tuning pipeline (per-tenant fine-tuning, not cross-tenant)
docs/operations/seedlegals-engagement-queries.md:74:> 4. **Auto-send liability allocation:** SaaS vendor responsible for false-positive auto-sends (e.g., a payment reminder sent to a settled invoice); tenant responsible for content of approved sends (e.g., consultant approved a draft that contained an error).
docs/operations/seedlegals-engagement-queries.md:95:>   - SaaS vendor: source code, fine-tuning data, voice corpus, customer pipeline
docs/operations/seedlegals-engagement-queries.md:167:- 2026-06-03 (Trigger 1) date approaches; LOI process accelerates without legal infrastructure
docs/_supplementary/strategic-plan.md:70:| Voice layer | Not shown in reel | Native voice receptionist agent |
docs/_supplementary/strategic-plan.md:81:1. **Lead Hunter** — scrapes + qualifies leads (Apollo, Clay, Companies House), writes to CRM with enrichment
docs/_supplementary/strategic-plan.md:86:4. **Content Creator** — trained on client voice docs, produces long-form content from one-line briefs
docs/_supplementary/strategic-plan.md:253:  - Brand voice (upload docs or paste examples)
docs/_supplementary/strategic-plan.md:295:      voice-profile.json
docs/_supplementary/strategic-plan.md:338:- [ ] **You**: Voice ingestion pipeline (upload docs → vector store → voice profile)
docs/_supplementary/strategic-plan.md:407:| **Growth** | £7,500 | £1,500 | Full 9 agents, dashboard, all integrations, voice training |
docs/_supplementary/strategic-plan.md:420:2. **Vertical context libraries** — every dental client you onboard improves your dental voice profile, your dental SOP templates, your dental integration library. Network effect per-vertical.
docs/_supplementary/strategic-plan.md:445:- **You try to build everything** (voice + SEO + ads + HR + custom) — this kills you. **Ship 9 agents. Nothing else until month 4.** Write this on your wall.
docs/_supplementary/planning-phase-brief.md:34:| **CC5** | **Voice Ingestion Pipeline** — document → voice profile extraction service | Python or TypeScript | §3.3 |
docs/_supplementary/planning-phase-brief.md:38:| **CC9** | **Custom MCP Servers (6 of them)** — DocuSign, GA4, Meta Ads, Companies House, Prospeo, Dentally | Python (FastMCP) or TypeScript | §3.8 (six of the 15 integration specs) |
docs/_supplementary/planning-phase-brief.md:179:- Session 26: Integration Specs Batch 3 — Companies House, Prospeo, Kaspr, Loom, Google Drive (3.8)
docs/_supplementary/technical-strategy-v2.md:215:    /voice-receptionist
docs/_supplementary/technical-strategy-v2.md:244:End-to-end under 15 minutes of compute time. Your human time: approve the voice profile in the wizard, review smoke-test outputs, kickoff call. Target: under 4 hours of your time per client.
docs/_supplementary/technical-strategy-v2.md:326:| **CLAUDE.md (brain stem)** | Client identity, voice, key people, pointers into the vault | Auto-loaded every session | Project root |
docs/_supplementary/technical-strategy-v2.md:355:    voice-profile.md          ← core doc; referenced in CLAUDE.md
docs/_supplementary/technical-strategy-v2.md:365:1. **The graph view.** Clients can open their vault in Obsidian and literally *see* their business brain. Notes linked by `[[wikilinks]]` render as a force-directed graph. A new proposal auto-links to the client, which links to past deals, which links to brand voice. The graph grows visibly over time. This is a pure wow-factor feature for sophisticated buyers.
docs/_supplementary/technical-strategy-v2.md:538:Mitigation: **human-in-the-loop at the trust boundary.** Every proposal gets reviewed by the sales lead before it sends. Every invoice-adjacent action requires a human click. Every external-facing piece of content goes to a "review" inbox before posting. Agents draft and queue. Humans approve. This is not a limitation — it's a feature. You are augmenting the team, not replacing them. Sell it that way from day one.
docs/_supplementary/execution-plan.md:47:The wizard flow (five steps, with copy), the provisioning orchestrator (state machine, rollback paths), the voice ingestion pipeline (past proposals → voice profile). These are IP-critical — worth extra engineering depth.
docs/_supplementary/execution-plan.md:65:Logo + variants, colour + typography lock, brand voice guide (yours, not clients'), marketing site copy (homepage, pricing, about, case studies stub), social media presence plan.
docs/_supplementary/execution-plan.md:154:  - *Purpose:* SessionStart hook that hydrates CLAUDE.md with retrieved past proposals + pricing framework + voice profile.
docs/_supplementary/execution-plan.md:157:  - *Prompt:* "Write `proposal-builder/context.sh` — the SessionStart hook that: (1) parses the trigger payload to identify the prospect, (2) queries the pgvector index for 3 most similar past winning proposals, (3) loads the brand voice profile and pricing framework, (4) appends all this into CLAUDE.md's Context section. Assume the vault is at /tenant/vault and pgvector is accessible via a simple CLI wrapper `vault-search`."
docs/_supplementary/execution-plan.md:181:  - *Prompt:* "Write the Minimal Vault Structure Specification: the starting directory tree for a new tenant's Obsidian vault (/vault/clients, /vault/brand, /vault/sops, /vault/content, /vault/daily, /vault/archive), the seed files with templates (CLAUDE.md, brand/voice-profile.md, brand/pricing.md — all with `[INSERT-FROM-WIZARD]` tokens), the frontmatter conventions (required tags, date formats), and the initial .gitignore + README.md explaining the vault to the client."
docs/_supplementary/execution-plan.md:209:  - *Prompt:* "Produce the full Lead Hunter agent bundle per Build Plan §5: `agent.md` (Haiku-targeted, ICP-rubric-driven prompt), `config.schema.json` (ICP definition schema with industry SIC codes, employee bands, geography, revenue, disqualifiers), `tools.yaml` (Companies House, Prospeo, Kaspr, HubSpot — declare as UK-context stack, NOT Apollo), `validate.sh` (JSON schema + dedup + completeness checks), `context.sh` (no heavy retrieval — inject current CRM record hashes for dedup), 3 test fixtures + golden lead outputs."
docs/_supplementary/execution-plan.md:213:- [ ] **2.4 — Content Creator full bundle** (6 files) — Build Plan §8. *Effort: 3C (voice profile integration is heavier)*
docs/_supplementary/execution-plan.md:249:  - *Prompt:* "Write the Provisioning System Engineering Specification per Build Plan §19: the full state machine (every step as a state with entry/exit conditions), the exact data flow from `wizard.config.json` through template rendering → secret encryption → vault initialisation → voice ingestion trigger → embedding index → container start → cron install → webhook register → smoke tests → dashboard go-live. Cover: idempotency, atomic rollback on any failure, versioning of every output, observability hooks, the exact CLI commands. Target: a senior dev can implement in 2 weeks from this spec alone."
docs/_supplementary/execution-plan.md:255:  - *Prompt:* "Write the Configuration Centre Wizard Full UX Specification: each of the 5 steps (Company Profile, Integrations, Agent Selection, Voice & Context Training, Go-Live) as its own section covering: every field on the screen with label + placeholder + help text + validation rules, the interaction flow, the error states, the empty states, the progress indicators, autosave behaviour, the resume-mid-flow behaviour, the step-to-step navigation logic. Include the copy voice — warm, confident, never condescending, UK-English spellings. This doc feeds a designer and a dev in parallel."
docs/_supplementary/execution-plan.md:258:  - *Purpose:* the critical pipeline where uploaded past proposals → structured voice profile. Quietly one of the highest-leverage components.
docs/_supplementary/execution-plan.md:261:  - *Prompt:* "Write the Voice Ingestion Pipeline Specification: the pipeline that takes client-uploaded documents (PDFs of past proposals, brand guidelines, sample emails — up to 50MB mixed formats) and produces: (1) a structured `voice-profile.md` with tone descriptors + banned phrases + rhythm analysis + signature turns-of-phrase, (2) a `pricing-framework.md` extracted from past proposals, (3) chunked + embedded vault entries for retrieval. Cover: document parsing (mammoth for docx, pypdf for PDF, plaintext for rest), chunking strategy (semantic not fixed-size), embedding call batching, the LLM pipeline that produces the voice profile (Sonnet 4.6 reading 5–20 samples and writing the profile), validation checkpoint where client reviews and edits before approving. Include edge cases (document in non-English, mixed formats in one upload, corrupt PDFs)."
docs/_supplementary/execution-plan.md:291:  - *Prompt per integration:* "Write the {Integration Name} Integration Specification: the MCP server choice (fork X / build from Y spec / official), auth setup (OAuth flow or API key), the scopes/permissions required and why, the specific operations used by agents (read leads, write deals, fetch transcript, etc.), fallback behaviour on failure, test checklist, rate limit handling. Priority 1 integrations: Fathom, HubSpot, Gmail, Slack, Notion, DocuSign. Priority 2: Companies House, Prospeo, Kaspr, Stripe, GA4, Meta Ads, Cal.com, Loom, Google Drive."
docs/_supplementary/execution-plan.md:303:  - *Prompt:* "Write the Cost & Billing System Engineering Specification per Build Plan §27: the Anthropic API metadata tagging pattern for per-tenant attribution, the third-party API cost tracking table schema, the infra cost allocation formula, Stripe subscription setup (price IDs per tier, metered overages, setup fees as one-off invoices), the dashboard view that shows clients their current usage against allowance, the operator view that shows gross margin per tenant + anomaly detection."
docs/_supplementary/execution-plan.md:373:  - *Prompt:* "Write the Billing View Specification: current plan + next invoice, current-month usage against allowance with forecast, invoice history + download, payment method management (Stripe Customer Portal link), plan upgrade/downgrade flow, overage projection alerts."
docs/_supplementary/execution-plan.md:386:  - *Prompt:* "Write the Settings View Specification: tenant-wide config (brand voice re-training trigger, notification preferences, approval policies, working hours, data residency info), danger-zone (pause all agents, archive tenant, delete data)."
docs/_supplementary/execution-plan.md:409:  - *Prompt:* "Draft an MSA template for IntelForce AI OS: parties, scope of services referencing the 9 core agents + add-ons, service levels (uptime target, response time targets), fees + payment terms (monthly retainer + setup + overages), term + termination (rolling monthly with 30 day notice, immediate for material breach), IP (client retains their data + voice profile; IntelForce retains the platform + agent templates), confidentiality, warranties, liability caps, indemnification, UK law + England jurisdiction. Mark solicitor-review-required clauses clearly. Written in plain English with legal precision, not dense legalese."
docs/_supplementary/execution-plan.md:490:  - *Prompt:* "Write the Client Onboarding Human-Hours Playbook: the exact 4-hour breakdown across the 72-hour window: pre-wizard 30-min kickoff call script, mid-wizard voice-profile review (60 min), smoke-test review (30 min), go-live call (90 min), week-1 check-in (30 min). Each with: objectives, agenda, artefacts produced, what 'success' looks like."
docs/_supplementary/execution-plan.md:494:  - *Prompt:* "Write the IntelForce AI OS Support Playbook: the 20 most likely client support tickets (agent produced bad output, integration disconnected, can't log in, need user added, billing question, want to pause agent, want to rename agent, want new capability, approval queue stuck, question about a log entry, invoice dispute, want to downgrade, want to upgrade, data export request, GDPR DSAR, cancellation request, 'it's not working' vague, hallucination complaint, proposal draft was wrong, voice is drifting). Per ticket: diagnostic questions, resolution steps, escalation path, expected resolution time, template response."
docs/_supplementary/execution-plan.md:503:  - *Prompt:* "Write the Monitoring & Alert Playbook: every alert the observability stack fires, with for each: the condition that triggers it, the likely root causes, the diagnostic commands, the resolution steps, the escalation rules. Organise by severity tier."
docs/_supplementary/execution-plan.md:560:  - *Prompt:* "Produce the complete Hospitality Vertical Pack for boutique hotels and Eden-adjacent properties: booking engine integrations (Mews, Cloudbeds), hospitality-specific agents (concierge assistant, guest-experience reporter), voice receptionist tuning, luxury brand voice patterns."
docs/_supplementary/execution-plan.md:596:- **Human professionals:** solicitor reviews MSA/DPA (5.1, 5.2), designer polishes the dashboard specs (4.1, 4.6), voice-over artist records the Voice Receptionist greetings (7.3).
docs/_supplementary/execution-plan.md:603:- **Voice profile** — takes real past proposals. If you don't have 3+ from a founding customer, the voice profile is speculative. Do the founding customer discovery first.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:11:No active Companies House registration found for **Hays plc**. Diagnostic proceeded against publicly visible non-CH signals only.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:13:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:26:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:28:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:32:Registered office address not visible at Companies House for Hays plc.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:34:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:36:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:40:Firm-age signal unavailable without Companies House incorporation date.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:42:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:44:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:56:Companies House SIC codes give a coarse industry signal but no specific technology stack visibility.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:58:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:68:**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:70:Companies House does not surface competitor data at the firm level.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:72:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:76:No filings at Companies House in the last 90 days. May indicate quiet period OR firm is between annual cycles.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:78:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:80:Source: [Companies House filing history](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:84:No directors on file at Companies House (firm may be dissolved or unregistered).
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:86:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:92:[Source: Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:6:**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:11:No active Companies House registration found for **Hays plc**. Diagnostic proceeded against publicly visible non-CH signals only.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:13:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:26:**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:28:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:32:Registered office address not visible at Companies House for Hays plc.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:34:**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:36:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:40:Firm-age signal unavailable without Companies House incorporation date.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:42:**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:44:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:54:**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:56:Companies House SIC codes give a coarse industry signal but no specific technology stack visibility.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:58:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:68:**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:70:Companies House does not surface competitor data at the firm level.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:72:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:76:No filings at Companies House in the last 90 days. May indicate quiet period OR firm is between annual cycles.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:78:**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:80:Source: [Companies House filing history](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:84:No directors on file at Companies House (firm may be dissolved or unregistered).
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:86:Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:92:[Source: Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:94:**v0 limitation:** voice classifier ≥ 0.75 gate (per agent.md §5 V3) skipped at v0; opener is deterministic anchor-based composition. Wire LLM + per-tenant voice classifier at W4 polish.
packages/agent-renderer/tests/fixtures/test-agent/agent.md:22:Single ESC code in scope: `ESC_SCHEMA_VIOLATION` on malformed input. Routes per
packages/harness/cortextos/tests/integration/phase3-docs-backtest.test.ts:630:    // Must prescribe list-crons as first diagnostic
docs/operations/founder-legal-setup-guide.md:18:2. **Takes autonomous actions** on behalf of recruitment agencies (LinkedIn messages, Bullhorn writes, payment reminders). This creates **professional liability** — if your AI sends a wrong payment chase to a settled invoice, the agency may be liable to the candidate; they may seek to pass that liability to you.
packages/mcp-connectors/companies-house/package.json:5:  "description": "IFOS Companies House MCP connector — search + profile + officers + filing history. Used by Diagnostic agent §4 Step 2 + 10 per agents/recruitment/diagnostic/tools.yaml.",
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A1 (the 10-step workflow for Diagnostic, lines 495-526).
docs/operations/goal-option-c-diagnostic-end-to-end.md:19:5. **`agents/recruitment/diagnostic/agent.md`** — the existing output contract. Read in full.
docs/operations/goal-option-c-diagnostic-end-to-end.md:20:6. **`agents/recruitment/diagnostic/tools.yaml`** — MCP tool declarations the executor must implement.
docs/operations/goal-option-c-diagnostic-end-to-end.md:32:1. **One Markdown file exists at `/vault/migration-test/diagnostic-reports/<firm-slug>-2026-05-24.md`** containing a 12-section Diagnostic report for a real UK recruitment firm chosen by the founder.
docs/operations/goal-option-c-diagnostic-end-to-end.md:34:2. **The report passes Gate A (validate.sh)** clean: 12 sections present, ≥1 citation per section, word count 400-2000, no banned phrases (V3 voice classifier passes OR skipped with explicit warning if `IFOS_VOICE_CLASSIFIER_URL` unset for v0).
docs/operations/goal-option-c-diagnostic-end-to-end.md:41:   - `pnpm test` returns green (≥10 vitest unit tests per package; integration test against live Companies House API marked `.skipIf(!process.env.COMPANIES_HOUSE_API_KEY)`)
docs/operations/goal-option-c-diagnostic-end-to-end.md:49:6. **A decision-log audit trail** for the smoke run: 3+ rows in `decision_log` (trigger + output + action), all under `agent_name='diagnostic'`, with `tenant_slug='migration-test'`.
docs/operations/goal-option-c-diagnostic-end-to-end.md:66:| Companies House connector | Diagnostic §4 Step 2 + 10 |
docs/operations/goal-option-c-diagnostic-end-to-end.md:68:| §12 conversation opener — LLM-generated, minimal voice gate | Sufficient for v0 demo; full voice classifier in W4 polish |
docs/operations/goal-option-c-diagnostic-end-to-end.md:77:| LinkedIn integration (Proxycurl, etc.) | Requires founder commercial action (Proxycurl signup ~£50/mo); LinkedIn paths remain stubbed; fixture 02 verifies graceful degradation already |
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:89:- **Do NOT** modify `_shared/hook-helpers.sh` or `_shared/voice-loader.sh` beyond fixing genuine bugs (29/29 tests pass; treat as stable substrate)
docs/operations/goal-option-c-diagnostic-end-to-end.md:90:- **Do NOT** sign up for any paid service (Proxycurl, etc.) — founder gates external spend
docs/operations/goal-option-c-diagnostic-end-to-end.md:99:**Companies House Developer API Key** (free; founder registers at https://developer.company-information.service.gov.uk/ — URL verified 2026-05-24 by curl).
docs/operations/goal-option-c-diagnostic-end-to-end.md:104:2. State: "Founder action needed: register for Companies House API key at https://developer.company-information.service.gov.uk/ (free, 5 min). Save the key as: `echo 'COMPANIES_HOUSE_API_KEY=<your-key>' >> /vault/migration-test/_secrets.env && chmod 600 /vault/migration-test/_secrets.env`. Confirm when done; do NOT paste the key into chat."
docs/operations/goal-option-c-diagnostic-end-to-end.md:145:### Step 3 — Companies House connector (~90 min)
docs/operations/goal-option-c-diagnostic-end-to-end.md:148:- `client.ts` — Companies House REST client with Basic auth (API key as username, empty password per CH docs)
docs/operations/goal-option-c-diagnostic-end-to-end.md:155:- `errors.ts` — 429 → ESC_RATE_LIMIT_HIT, 5xx → ESC_SCHEMA_VIOLATION
docs/operations/goal-option-c-diagnostic-end-to-end.md:160:- Schema validation against Companies House response shapes
docs/operations/goal-option-c-diagnostic-end-to-end.md:177:STOP. Output to founder: "Step 4 — please register for Companies House API key at https://developer.company-information.service.gov.uk/. Save to /vault/migration-test/_secrets.env via SSH. Do NOT paste the key in chat. Confirm when saved."
docs/operations/goal-option-c-diagnostic-end-to-end.md:181:### Step 5 — Companies House integration smoke test (~20 min)
docs/operations/goal-option-c-diagnostic-end-to-end.md:195:Replace the stub `_section_1()` through `_section_11()` functions in `agents/recruitment/diagnostic/cycle.sh` with real connector calls:
docs/operations/goal-option-c-diagnostic-end-to-end.md:201:- `_section_7-11` mostly LinkedIn-dependent — use stubs producing "LinkedIn integration v1.1" content with Companies House anchor as fallback citation
docs/operations/goal-option-c-diagnostic-end-to-end.md:202:- `_section_12` calls a minimal LLM (Claude or local) with §1-§11 context to produce 2-3 sentence opener; voice classifier SKIPPED (warn, don't fail)
docs/operations/goal-option-c-diagnostic-end-to-end.md:204:Sections producing real content: §1 (Companies House) + §2 (Companies House URL + web scraper for {firm} domain) + §6 (ICP fit derived from §1).
docs/operations/goal-option-c-diagnostic-end-to-end.md:205:Sections producing stub content with Companies House anchor: §3-§5, §7-§11.
docs/operations/goal-option-c-diagnostic-end-to-end.md:206:Section §12: LLM-generated, voice-classification skipped.
docs/operations/goal-option-c-diagnostic-end-to-end.md:210:Acceptance: `bash agents/recruitment/diagnostic/cycle.sh --firm "Test Firm Name" --tenant migration-test` produces a draft at /tmp/... and Gate A passes (V3 warning only).
docs/operations/goal-option-c-diagnostic-end-to-end.md:212:Commit: `feat(diagnostic): wire web-scraper + companies-house into cycle.sh §1+§2+§6`
docs/operations/goal-option-c-diagnostic-end-to-end.md:218:- A well-known firm ("Charterhouse Partners", "Hays plc", "Robert Walters") — Companies House will return real data
docs/operations/goal-option-c-diagnostic-end-to-end.md:227:ifosctl diagnostic --firm "<firm name>" --tenant migration-test
docs/operations/goal-option-c-diagnostic-end-to-end.md:232:export CTX_AGENT_DIR=$(pwd)/agents/recruitment/diagnostic
docs/operations/goal-option-c-diagnostic-end-to-end.md:235:bash agents/recruitment/diagnostic/cycle.sh --firm "<firm name>"
docs/operations/goal-option-c-diagnostic-end-to-end.md:238:Verify the report at `/vault/migration-test/diagnostic-reports/<slug>-2026-05-24.md`:
docs/operations/goal-option-c-diagnostic-end-to-end.md:244:Commit: `milestone(diagnostic): first end-to-end run — <firm name> report at <path>`
docs/operations/goal-option-c-diagnostic-end-to-end.md:248:Write `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` documenting:
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-option-c-diagnostic-end-to-end.md:283:- Recommendations for Week-4 polish (weak sections, voice classifier wiring, LinkedIn integration if Proxycurl signed up)
docs/operations/goal-option-c-diagnostic-end-to-end.md:306:| Companies House API key blocks (founder slow to register) | Pause at Step 4; founder runs other work; resume when key saved. Steps 1-3 + 6 (partially) still committable. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:307:| Companies House API returns unexpected schema | Schema-validation error in connector; surface as Risk #14 in register; downgrade §1 to stub with Companies House URL as citation; continue. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:309:| LLM generates §12 with banned phrase | V5 fails; retry up to 3x; if still failing, ESC_VOICE_DRIFT row + report blocked (matches fixture 99); record as known limitation, defer voice tuning to Week-4 polish. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:311:| Founder picks a firm name not found in Companies House | Search returns 0 results; cycle.sh degrades to "Companies House: no UK registration found"; continues with web-scraper + stubs; still produces a valid 12-section report. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:312:| Real run reveals Gate A V3 voice classifier was actually needed (skipped warning was too lenient) | Surface as W4 polish item; do not block the milestone. |
docs/operations/goal-option-c-diagnostic-end-to-end.md:326:- Step 4 — Companies House API key registration
docs/operations/goal-option-c-diagnostic-end-to-end.md:330:- Any external service requiring paid signup (Proxycurl, OpenAI tier, etc.)
docs/operations/goal-option-c-diagnostic-end-to-end.md:362:2. **Cite real Companies House data** for §1 (no stubs)
docs/operations/goal-option-c-diagnostic-end-to-end.md:364:4. **Have a §12 conversation opener that's not generic** — even if voice classifier skipped, the opener should anchor to a specific evidence point from §1-§11 (filings, headcount, hiring posts)
docs/operations/goal-option-c-diagnostic-end-to-end.md:381:Report path:       [/vault/migration-test/diagnostic-reports/<slug>-<date>.md]
docs/operations/goal-option-c-diagnostic-end-to-end.md:384:Gate A:            PASS (V3 warning — voice classifier skipped per scaffold)
docs/operations/goal-option-c-diagnostic-end-to-end.md:392:  5. [SHA] feat(diagnostic): wire web-scraper + companies-house into cycle.sh
docs/operations/goal-option-c-diagnostic-end-to-end.md:393:  6. [SHA] milestone(diagnostic): first end-to-end run
docs/operations/goal-option-c-diagnostic-end-to-end.md:402:  - [LinkedIn integration via Proxycurl signup]
packages/mcp-connectors/companies-house/src/errors.ts:1:// Error types for Companies House connector. Maps to escalation codes per
packages/mcp-connectors/companies-house/src/errors.ts:18:    super("Companies House API key invalid or missing", endpoint, 401);
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:35:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:49:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:56:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:66:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/transcribe.test.ts:80:    const oggPath = join(workDir, 'voice.ogg');
packages/harness/cortextos/tests/unit/telegram/media.test.ts:172:  it('processes voice messages', async () => {
packages/harness/cortextos/tests/unit/telegram/media.test.ts:174:      voice: { file_id: 'voice1', duration: 5 },
packages/harness/cortextos/tests/unit/telegram/media.test.ts:176:    const api = createMockApi('voice/file_123.ogg');
packages/harness/cortextos/tests/unit/telegram/media.test.ts:180:    expect(result!.type).toBe('voice');
packages/harness/cortextos/tests/unit/telegram/media.test.ts:183:    expect(result!.file_path).toMatch(/voice_\d+\.ogg$/);
packages/harness/cortextos/tests/unit/telegram/media.test.ts:187:  it('voice message has undefined transcript when transcription disabled', async () => {
packages/harness/cortextos/tests/unit/telegram/media.test.ts:189:      voice: { file_id: 'voice1', duration: 5 },
packages/harness/cortextos/tests/unit/telegram/media.test.ts:191:    const api = createMockApi('voice/file_123.ogg');
packages/harness/cortextos/tests/unit/telegram/media.test.ts:255:      voice: { file_id: 'v1', duration: 3 },
packages/harness/cortextos/tests/unit/telegram/media.test.ts:257:    const api = createMockApi('voice/file.ogg');
packages/agent-renderer/tests/unit/synthesis.test.ts:58:      tenant: { tenant_slug: "migration-test", tenant_legal_name: "Migration Test Ltd", tier: "boutique", operating_window: "business-hours", voice_threshold: 0.75 } as TenantConfig,
packages/mcp-connectors/companies-house/README.md:3:IFOS Companies House MCP connector for Diagnostic agent §4 Step 2 + 10 per `agents/recruitment/diagnostic/tools.yaml`.
packages/mcp-connectors/companies-house/README.md:14:Companies House uses HTTP Basic auth with the API key as username + empty password. Per their docs:
packages/mcp-connectors/companies-house/README.md:23:- **Rate limit:** 600 requests / 5-minute window per IP (Companies House documented). Connector pre-emptively backs off at 80% capacity.
packages/mcp-connectors/companies-house/README.md:24:- **Cache:** 7-day TTL per `(company_number, capability)` (matches `tools.yaml`). Companies House data changes slowly; 7 days is safe.
packages/mcp-connectors/companies-house/README.md:32:| 401 | API key invalid; fail-fast | ESC_SCHEMA_VIOLATION |
packages/mcp-connectors/companies-house/README.md:34:| 429 | Rate limited; back off 60s, retry once | ESC_RATE_LIMIT_HIT |
packages/mcp-connectors/companies-house/README.md:35:| 5xx | Server error; fail-fast | ESC_SCHEMA_VIOLATION |
packages/mcp-connectors/companies-house/README.md:62:Integration tests against live Companies House API are skipped unless `COMPANIES_HOUSE_API_KEY` env is set.
packages/mcp-connectors/companies-house/README.md:66:v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:315:  it('returns [voice message] for voice messages', () => {
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:316:    const msg = { message_id: 5, chat: { id: 1 }, voice: { file_id: 'vc1', duration: 5 } };
packages/harness/cortextos/tests/unit/daemon/agent-manager.test.ts:317:    expect(buildReplyContext(msg)).toBe('[voice message]');
packages/harness/cortextos/dashboard/src/app/api/messages/upload/route.ts:22: *   type    - 'photo' | 'voice' | 'document' | 'video'
packages/harness/cortextos/dashboard/src/app/api/messages/upload/route.ts:84:  const typeLabel = type === 'photo' ? 'photo' : type === 'voice' ? 'voice message' : type === 'video' ? 'video' : 'document';
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:744:    it('formats voice message with duration', () => {
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:748:        '/tmp/telegram-images/voice_1743718313.ogg',
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:754:      expect(result).toContain('local_file: /tmp/telegram-images/voice_1743718313.ogg');
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:759:      const result = FastChecker.formatTelegramVoiceMessage('Alice', '123', '/tmp/voice.ogg', undefined);
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:768:        '/tmp/voice.ogg',
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:775:      expect(result).toContain('local_file: /tmp/voice.ogg');
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:780:      const noArg = FastChecker.formatTelegramVoiceMessage('Alice', '123', '/tmp/voice.ogg', 5);
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:781:      const empty = FastChecker.formatTelegramVoiceMessage('Alice', '123', '/tmp/voice.ogg', 5, '   ');
packages/harness/cortextos/dashboard/src/components/comms/channel-view.tsx:28:  /** Optional: set by the channel API when the message origin is a voice note. */
packages/harness/cortextos/dashboard/src/components/comms/channel-view.tsx:343:            const isVoice = msg.media_type === 'voice';
packages/harness/cortextos/dashboard/src/components/comms/channel-view.tsx:359:                      <IconMicrophone size={11} className="text-muted-foreground" aria-label="voice message" />
packages/harness/cortextos/community/agents/security/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/community/agents/security/SOUL.md:54:- External: org brand voice, professional, opinionated when asked
packages/mcp-connectors/companies-house/pnpm-lock.yaml:384:    resolution: {integrity: sha512-+A1NJmfM8WNDv5CLVQYJ5PshuRm/4cI6WMZRg1by1GwPIQPCTs1GLEUHwiiQGT5zDdyLiRM/l1G0Pv54gvtKIg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:571:    resolution: {integrity: sha512-FJHFfqpKUI3A10WrWKiFbBZ7yVbGT4q4B5o1qKFFojqpaYoh9LrQgqWCmmcxQzVSXYtyB5bzkXrYzlHTs21MYA==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:626:    resolution: {integrity: sha512-QVTUovf40zgTqlFVrKA1uXMVvU2QWEFWfAH8Wdc48IxLvrJMQVMBRjuQyUpzZCDkakImib9eVazbWlC6ksWtJw==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:814:    resolution: {integrity: sha512-//nshmD55c46FuFw26xV/xFAaB5HF9Xdap7HJBBnrKdAd6/GxDBaNA1870O79+9ueg61cZLSVc+OaFlfmObYVQ==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:965:    resolution: {integrity: sha512-o5a9xKjbtuhY6Bi5S3+HvbRERmouabWbyUcpXXUA1u+GNUKoROi9byOJ8M0nHbHYHkYICiMlqxkg1KkYmm25Sw==}
packages/harness/cortextos/dashboard/src/app/api/comms/channel/[pair]/route.ts:17:  /** Optional origin marker — set when the message came from a Telegram voice
packages/harness/cortextos/dashboard/src/app/api/comms/channel/[pair]/route.ts:118:  // Voice transcript dedup — Telegram voice notes produce two log entries
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:547:  it('voice without transcript: surfaces local_file + duration but no transcript line', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:550:local_file: telegram-images/voice_1234.ogg
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:555:    expect(out).toContain('local_file: telegram-images/voice_1234.ogg');
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:560:  it('voice with transcript: surfaces transcript text', () => {
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:563:local_file: telegram-images/voice_1234.ogg
packages/harness/cortextos/tests/unit/pty/codex-app-server-pty.test.ts:573:    expect(out).toContain('local_file: telegram-images/voice_1234.ogg');
packages/harness/cortextos/community/agents/security/.claude/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/community/agents/security/.claude/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/templates/orchestrator/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/orchestrator/SOUL.md:56:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/templates/hermes/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/hermes/SOUL.md:54:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/templates/analyst/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/analyst/SOUL.md:53:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/src/types/index.ts:496:  voice?: TelegramVoice;
packages/harness/cortextos/community/agents/security/.claude/skills/soul-philosophy/SKILL.md:26:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/community/agents/security/.claude/skills/soul-philosophy/SKILL.md:124:- Use the org's brand voice
packages/harness/cortextos/scripts/install-whisper-model.sh:3:# Telegram voice transcription. Idempotent. Skips the download if the model
packages/harness/cortextos/templates/agent-codex/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/agent-codex/SOUL.md:56:- Org brand voice, professional, opinionated when asked
packages/harness/cortextos/community/agents/analyst/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/community/agents/analyst/SOUL.md:53:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/templates/analyst/.claude/skills/soul-philosophy/SKILL.md:26:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/templates/analyst/.claude/skills/soul-philosophy/SKILL.md:106:- Use the org's brand voice
packages/harness/cortextos/templates/orchestrator/.claude/skills/soul-philosophy/SKILL.md:26:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/templates/orchestrator/.claude/skills/soul-philosophy/SKILL.md:124:- Use the org's brand voice
packages/harness/cortextos/templates/analyst/.claude/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/templates/analyst/.claude/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/soul-philosophy/SKILL.md:18:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/soul-philosophy/SKILL.md:116:- Use the org's brand voice
packages/harness/cortextos/templates/orchestrator/.claude/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/templates/orchestrator/.claude/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/templates/agent/SOUL.md:10:Use the bus scripts. Every action that does NOT go through the bus is invisible. The bus is your voice.
packages/harness/cortextos/templates/agent/SOUL.md:54:- External: org brand voice, professional, opinionated when asked
packages/harness/cortextos/templates/orchestrator/.claude/skills/agent-migration/SKILL.md:243:Then proceed with cortextOS onboarding (/onboarding), but treat it as a migration-aware onboarding: skip or fast-track any steps that are already handled by the pre-loaded files (identity, role, voice, goals). Focus onboarding on: tool access verification, API key setup, cron confirmation, and any gaps specific to your domain.'
packages/harness/cortextos/templates/agent/.claude/skills/system-diagnostics/SKILL.md:2:name: system-diagnostics
packages/harness/cortextos/templates/agent/.claude/skills/system-diagnostics/SKILL.md:3:description: "Something in the system feels stuck or wrong — tasks are not moving, an agent has gone quiet, goals have not been updated in days, or the orchestrator has asked for a system health report. You need to run a structured check: stale tasks, stale goals, overdue human tasks, fleet heartbeat status, and metrics. This is your diagnostic toolkit. Run it on every heartbeat (orchestrator) and whenever something seems off."
packages/harness/cortextos/templates/agent/.claude/skills/soul-philosophy/SKILL.md:26:The bus is not bureaucracy. The bus is your voice.
packages/harness/cortextos/templates/agent/.claude/skills/soul-philosophy/SKILL.md:124:- Use the org's brand voice

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '110,195p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   110	- **Trigger:** Renderer exited non-zero. Mid-render atomic-rename per ADR-003 §3.3.4 means the prior agent dir at target is preserved (`.prev.<timestamp>/`) — no half-rendered state visible to daemon discovery
   111	- **Phase:** `gating_failed`
   112	- **Routing:** `operator_chat_id`; CC `ifos_oncall_chat_id` only on `atomic-rename-failed` (infrastructure failure, not author error)
   113	- **Agent name:** `_renderer` (sentinel; not a real agent)
   114	- **Payload fields:** `reason` (one of `schema-validation-failure`, `bundle-malformed`, `shared-helpers-missing`, `tenant-not-provisioned`, `atomic-rename-failed`, `non-rendered-target`), `agent_name_attempted`, `tenant_slug_attempted`
   115	- **Codex query:** `SELECT * FROM decision_log WHERE agent_name='_renderer' AND human_action LIKE 'ESC_RENDERER_FAILED%'` per ADR-003 §4.7
   116	
   117	### 2.5 — Recruitment-domain vocabulary (8 codes)
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '258,280p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   258	## §10 — When this document ratifies
   259	
   260	Per `.codex/ratification/review-agent-bundle.md` (skill not yet built; lazy per execution-plan §3): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
   261	
   262	Status flips to Accepted when:
   263	- Codex Round-3+ ratifies the full bundle
   264	- Founder approves §3's 12-section list as canonical
   265	- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   266	- Gate B baseline measurement begins (30% target; 4-week window)
   267	
   268	Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.
   269	
   270	*End of Diagnostic agent.md draft.*

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,45p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS auto-send policy (runtime table)
     2	#
     3	# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
     4	# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
     5	# hh_decision_action() invocation. Per-tenant overrides live in Postgres
     6	# tenant_adapters.config.tier_overrides (§8).
     7	#
     8	# 29 v1.0 action_types: 6 green + 5 yellow + 10 orange + 8 red.
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
    21	version: "v1.0-2026-05-20"
    22	
    23	action_types:
    24	
    25	  # ───────────────────────────────────────────────────────────
    26	  # GREEN — auto-send without review (6 action_types)
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
   141	
   142	**Threshold:** Total Hetzner monthly infrastructure cost exceeds **£100/month at 3 active tenants**.
   143	
   144	**Rationale:** 15x headroom from the current £6.40/month single-tenant baseline (per Day-4 runbook §1.4: CX22 + 50 GB volume + backups = €5 + €1.20 + €2.40 ≈ £6.40). At 3 tenants on shared single-server architecture, expected cost should remain near baseline. If Postgres + LUKS-volume growth + vector-index growth pushes >£100/month at 3 tenants, infrastructure approach needs pivot.
   145	
   146	**Owner:** Founder; monthly check via Hetzner billing.
   147	
   148	**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
   149	
   150	**Action:** PIVOT — likely vectors:
   151	
   152	- **Self-host:** founder's Mac Studio cluster from prior research as primary; Hetzner as backup. Saves money but adds maintenance.
   153	- **Provider switch:** alternate eu-central provider (Mythic Beasts, OVH, Scaleway) with better price-per-tenant economics.
   154	- **Architecture compaction:** per-tenant resource pooling rather than per-tenant servers.
   155	
   156	**Recovery path:** Rescoped infrastructure plan; pivoted v1.0 continues with adjusted Day-4 runbook §1.4 founder-set cost budget (master brief does not specify a numeric cost target; budget adjustment is a runbook revision, not a master-brief edit).
   157	
   158	### Trigger 8 — GATE-B-REVENUE-UPLIFT (KILL)
   159	
   160	**Threshold:** After 3 completed pilots (defined as: pilot ran for ≥90 days with active agent fleet and quarterly Gate B revenue measurement), average Gate B revenue uplift per tenant <£20k/year.
   161	
   162	**Owner:** Founder; assessed at end of each pilot.
   163	
   164	**Source:** Master brief §6 Day 5 line 486 — canonical example trigger from master brief.
   165	
   166	**Action:** KILL. Rationale: the wedge does not produce demonstrable ROI at the threshold required to sustain v1.0 commercially. £20k/year/tenant is the breakeven floor — below this, IFOS cannot fund continued operation at v1.0 pricing.
   167	
   168	**Recovery path:** None within v1.0. Lessons feed v1.1 if launched. The vertical assumption (UK recruitment) or product assumption (agent fleet vs. point tools) may need reconsidering for any next initiative.
   169	
   170	### Trigger 9 — CORTEXOS-PRIMITIVE-CHRONIC-FAILURE (PAUSE)
   171	
   172	**Threshold:** cortextOS primitives 3 (file bus per `cortexos-primitive-status.md` line item 3) or 4 (approval gates per primitive 4) report >1 production incident per week across **2 consecutive weeks** for any single pilot.
   173	
   174	**Threshold tightened Day 5 (2026-05-18) from 4 weeks to 2 weeks.** Rationale: Risk #1 severity was downgraded Day 1 because primitives 3 + 4 confirmed "shipped and tested" per `cortexos-primitive-status.md`. If field evidence shows failure-rate spike for 2 consecutive weeks, that is an actionable signal — waiting 4 weeks delays remediation by 50% within the v1.0 build timeline (Weeks 1-13).
   175	
   176	**Owner:** IFOS oncall; weekly check via `decision_log` + cortextOS daemon logs.
   177	
   178	**Source:** Master brief §12 Risk #1; Day-1 audit results in `cortexos-primitive-status.md` (primitive 1 PTY/PM2 is "shipped but flaky"; primitives 3 + 4 confirmed "shipped and tested" but field evidence may diverge).
   179	
   180	**Action:** PAUSE. Rationale: cortextOS primitive instability is a structural threat to every IFOS agent — every agent uses the file bus and most use approval gates. Chronic failure points to either (a) cortextOS regression upstream OR (b) IFOS usage pattern incompatible with cortextOS at scale.

exec
/bin/zsh -lc "rg --files docs | rg -i 'master|ultra|brief|operational'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/build-brief/00-MASTER-BRIEF.md
docs/runbooks/pii-purge-operational-pattern.md
docs/runbooks/operational-hygiene-protocol.md
docs/specs/ULTRAPLAN.md
docs/_supplementary/planning-phase-brief.md

exec
/bin/zsh -lc "find . -maxdepth 4 -iname '*ULTRA*' -o -iname '*brief*' -o -iname '*master*' | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 129ms:
./legacy/v1/MASTER-INDEX.md
./docs/_supplementary/planning-phase-brief.md
./docs/specs/ULTRAPLAN.md
./docs/build-brief
./docs/build-brief/00-MASTER-BRIEF.md

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '70,255p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '470,510p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '330,380p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   470	```
   471	Agent name + tier
   472	Build wave (v1.0 / v1.1 / v1.2 / v2.0)
   473	Always-on? (Tier 1 / Tier 2)
   474	Trigger type
   475	CortexOS primitives required
   476	MCP tools required
   477	Shared modules required
   478	External APIs / dependencies
   479	Gate A specifics
   480	Gate B target (restated from §7.2)
   481	Build complexity (S / M / L / XL where S=2 days, M=1 week, L=2 weeks, XL=4 weeks)
   482	Gotchas (the things that will bite us)
   483	```
   484	
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
   496	- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data
   497	- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
   498	- **Build complexity:** **M** (1 week)
   499	- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.
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

 succeeded in 0ms:
   330	   - Closing: {pattern}
   331	   - Length: {min}–{max} words
   332	   - Spelling: {British|US}
   333	   - Formality marker: {casual|formal|mixed}
   334	   ```
   335	
   336	2. Retrieves the 3 most semantically similar past samples to the current task via pgvector cosine similarity. Injects them as in-context examples.
   337	
   338	3. Loads the 5 most recent consultant-edited drafts of this task type, showing both the original draft AND the edit, so the model learns the editing pattern in-context.
   339	
   340	The total prompt overhead is ~2,500 tokens. Acceptable given context windows now exceed 200k.
   341	
   342	**Layer 3 — Validation (validate.sh).**
   343	
   344	Before any draft leaves the agent:
   345	
   346	- **Banned-phrase check** — exact-match grep against `tone-rules.yaml`'s banned list. Hard fail if any present. Cost: <50ms.
   347	- **Length bounds check** — word count against `tone-rules.yaml`'s min/max. Hard fail if outside. Cost: <10ms.
   348	- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
   349	- **Schema check** — does the draft have the required structural elements (greeting, body, closing, signature)? Defined per task type in the tone-rules. Hard fail if missing. Cost: <50ms.
   350	- **PII boundary check** — does the draft reference any PII outside the firm boundary (e.g., another tenant's candidate's name)? Hard fail. Cost: <100ms.
   351	
   352	Total Gate A latency: <500ms. Acceptable.
   353	
   354	If any hard fail, the agent regenerates with the failure reason injected as additional context ("your previous draft used the banned phrase 'I hope this finds you well'; rewrite avoiding it"). After 3 retries with hard fails, escalate with `ESC_VOICE_DRIFT` or `ESC_SCHEMA_VIOLATION`.
   355	
   356	**Layer 4 — The Scale-tier LoRA upgrade (v2.0).**
   357	
   358	Once a tenant has 6+ months of decision logs, they qualify for the per-firm LoRA adapter. The pipeline:
   359	
   360	1. Extract SFT pairs from the decision log: (agent prompt + context, consultant-edited final output) for every approved or edited draft.
   361	2. Train a LoRA adapter (rank 8–16) on a base model — Qwen3 70B for the cluster, or Claude/Anthropic API with similar fine-tuning if cloud-tier.
   362	3. Eval the adapter against held-out drafts using the voice classifier — promote only if the adapter beats the RAG baseline by ≥5 percentage points on the voice score *and* doesn't regress on compliance or factual checks.
   363	4. Serve the adapter from the cluster at inference time; agents transparently use it.
   364	
   365	The LoRA improves voice score from ~80% (RAG + scaffolding) to ~90%+. This is what justifies the Scale tier at £6,950/mo.
   366	
   367	The training pipeline itself is the v2.0 work; the data capture starts at v1.0 with the decision log writes from §4.2.
   368	
   369	### 6.2 The voice drift alerting
   370	
   371	Weekly cron job per tenant:
   372	1. Sample 20 drafts the agent produced that week.
   373	2. Run the voice classifier on each.
   374	3. Compute the average score and the 4-week rolling trend.
   375	
   376	If the rolling 4-week average drops by ≥5 percentage points: `ESC_VOICE_DRIFT_TENANT` fires. Email goes to the customer's primary contact AND to the internal CS Slack:
   377	
   378	> "Your voice quality score has dropped from 0.83 to 0.76 over the last 4 weeks. This usually means new edit patterns we haven't absorbed. Can we book 30 minutes to review samples?"
   379	
   380	We never silently accept voice drift. The structural commitment is that voice quality is measurable, measured, and surfaced.

exec
/bin/zsh -lc "rg --files | rg 'common.*(voice|target)|target.*patch|autosend-safety-policy'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/agents-runtime/_shared/common-voice.json
packages/agents-runtime/_shared/common-target-patch.json
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md
docs/decisions/autosend-safety-policy.md

exec
/bin/zsh -lc "rg -n \"_consultant_feedback|consultant feedback|diagnostic-feedback|feedback\" docs agents packages -g '"'!agents/recruitment/diagnostic/agent.md'"'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg -n \"common-voice|voice_classifier_threshold|target_patch|target-patch|common-target\" agents packages docs -g '"'!agents/recruitment/diagnostic/agent.md'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/diagnostic-generator/README.md:12:  --target-patch /vault/migration-test/target_patch.json
packages/diagnostic-generator/README.md:24:- **§6 ICP fit** — composite score from §1/§5 vs tenant `target_patch.json`.
packages/diagnostic-generator/src/cli.ts:1:// CLI entry point. Parses args, loads tenant target_patch if available,
packages/diagnostic-generator/src/cli.ts:17:  .option("--target-patch <path>", "Path to tenant target_patch.json", "")
packages/diagnostic-generator/src/cli.ts:35:    process.stderr.write(`warning: could not load target_patch from ${path}: ${(err as Error).message}\n`);
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:294:        Most-recent voice classifier score (0.0-1.0) from any outbound Concierge message about this candidate. Concierge's autosend Gate A per bullhorn-integration-path.md §4.1 A6. NULL means no outbound message yet sent for this candidate. Threshold default 0.75 per common-voice.json.voice_classifier_threshold.
agents/_shared/escalation-codes.md:122:- **Trigger:** Voice classifier score below `common-voice.json.voice_classifier_threshold` (default 0.75) after 3 retries per Ultraplan §5.3 retry budget
packages/diagnostic-generator/src/sections/icp-fit.ts:2:// target_patch.json. v0: deterministic scoring on 2 dimensions
packages/diagnostic-generator/src/sections/icp-fit.ts:20:  const lines: string[] = ["## ICP fit vs target_patch", ""];
packages/diagnostic-generator/src/sections/icp-fit.ts:23:    lines.push("No target_patch.json loaded for this tenant — cannot score ICP fit.");
packages/diagnostic-generator/src/sections/icp-fit.ts:26:      `Source: [tenant config](vault://${firmSignal.companyNumber ? "target-patch" : "target-patch"})`,
packages/diagnostic-generator/src/sections/icp-fit.ts:84:  lines.push(`Source: [Companies House profile](${chUrl}) + tenant target_patch.json`);
packages/agents-runtime/_shared/common-voice.json:3:  "$id": "https://intelforce.os/schemas/common-voice.json",
packages/agents-runtime/_shared/common-voice.json:4:  "title": "common-voice",
packages/agents-runtime/_shared/common-voice.json:28:    "voice_classifier_threshold": {
packages/agents-runtime/_shared/common-voice.json:49:  "required": ["voice_corpus_path", "voice_classifier_threshold"],
packages/agent-renderer/src/synthesis/configJson.ts:26:    "common-voice.json",
packages/agent-renderer/src/synthesis/configJson.ts:31:    "common-target-patch.json",
packages/agents-runtime/_shared/common-target-patch.json:3:  "$id": "https://intelforce.os/schemas/common-target-patch.json",
packages/agents-runtime/_shared/common-target-patch.json:4:  "title": "common-target-patch",
docs/architecture/agent-bundle-renderer-design.md:44:| `config.schema.json` (line 553) | Per-tenant JSON Schema, extending `common-*.json` shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) | the renderer (materialises to `config.json` per §2.1); per-tenant onboarding wizard at Product Spec §5.2 Day 4 fills schema fields | **Static schema; dynamic materialisation** per tenant |
docs/architecture/agent-bundle-renderer-design.md:110:| `agents/recruitment/<name>/config.schema.json` | `orgs/<org>/agents/<name>/config.json` | **Synthesis** | (1) `config.schema.json` (the JSON Schema itself, used for validation); (2) `/vault/{tenant-slug}/_config.yaml` per Ultraplan §5.1 line 220 (provides per-tenant values that fill schema fields); (3) bundle-level defaults from any `default` keys in the schema; (4) common-*.json shared schemas listed in Product Spec §5.3 (e.g. `common-voice.json`, `common-notifications.json`, `common-ats.json`) — spec gap §2.1-B on where common schemas live | Materialised JSON validates clean against the source schema using Ajv (or equivalent) before the renderer writes; required fields all populated; no extra fields beyond schema. Daemon-required fields (per §1.2): `enabled` defaults true, `runtime` defaults `claude-code`, `max_session_seconds` defaults 255600, `working_directory` defaults to the rendered agent dir |
docs/architecture/agent-bundle-renderer-design.md:124:- **§2.1-B:** master brief §8.1 line 553 says `config.schema.json` extends "`common-*.json`" but doesn't say where the `common-*.json` shared schemas live. Recommended resolution: `packages/agents-runtime/_shared/common-{client, voice, notifications, vault, ats, accounting, target-patch}.json` per Ultraplan §5.3 line 357-364 enumeration. The renderer resolves `$ref` to these paths during schema materialisation.
docs/architecture/agent-bundle-renderer-design.md:245:    { "$ref": "common-voice.json" },
docs/architecture/agent-bundle-renderer-design.md:540:- **Schema refs:** `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` per spec gap §2.1-B and Ultraplan §5.3 line 357-364.
docs/architecture/agent-bundle-renderer-design.md:761:| `packages/agents-runtime/_shared/common-{client,voice,notifications,vault,ats,accounting,target-patch}.json` (per spec gap §2.1-B) | Claude Code | Weeks 1-2 |
docs/operations/goal-week-3-polish-and-scaffold.md:208:   - **Prompt:** structured prompt including (a) full §1-§11 context as concatenated Markdown, (b) tenant voice corpus top-5 ANN matches from `CTX_VOICE_CORPUS_ID` (read via `hh_load_voice_samples`), (c) tenant tone rules filtered to "diagnostic" (read via `hh_load_tone_rules`), (d) 3 examples of "good" cold outreach style from `agents/_shared/common-voice.json` if available.
docs/operations/goal-option-c-diagnostic-end-to-end.md:200:- `_section_6` reads `target_patch.json`, computes composite ICP fit score from §1-§5 outputs
agents/recruitment/janitor/agent.md:244:| Tenant `target_patch.json` + `_secrets.env` provisioned | provision-tenant.sh ran for first pilot | ⏸ Post-LOI |
agents/recruitment/diagnostic/cycle.sh:123:# target_patch.json — optional; if missing, §6 ICP fit degrades to "no patch"
agents/recruitment/diagnostic/cycle.sh:124:TARGET_PATCH_PATH="${VAULT_ROOT}/${CTX_TENANT_SLUG}/target_patch.json"
agents/recruitment/diagnostic/cycle.sh:127:  TARGET_PATCH_FLAG="--target-patch ${TARGET_PATCH_PATH}"
agents/recruitment/diagnostic/README.md:19:| `context.sh` | Session hydration (voice corpus + target_patch + tone rules) | W3 build start |
agents/recruitment/diagnostic/README.md:50:- ⏸ `target_patch.json` for first pilot tenant
agents/recruitment/diagnostic/context.sh:11:# corpus + tone rules + recent edits + target_patch from the tenant's
agents/recruitment/diagnostic/context.sh:20:#       CTX_TARGET_PATCH      JSON path or inline (per common-target-patch.json)
agents/recruitment/diagnostic/context.sh:31:#   - target_patch unreachable → exit 1 with ESC_SCHEMA_VIOLATION
agents/recruitment/diagnostic/context.sh:90:# 2 — Load target_patch (tenant's commercial sweet spot)
agents/recruitment/diagnostic/context.sh:93:# target_patch defines sectors / geographies / size_bands / deal_size_band
agents/recruitment/diagnostic/context.sh:94:# per common-target-patch.json schema. Loaded from tenant's _config.yaml or
agents/recruitment/diagnostic/context.sh:97:# target_patch resolution order:
agents/recruitment/diagnostic/context.sh:98:#   1. CTX_AGENT_DIR/target_patch.json (rendered agent path)
agents/recruitment/diagnostic/context.sh:99:#   2. ${VAULT_ROOT}/${CTX_TENANT_SLUG}/target_patch.json (per-tenant vault)
agents/recruitment/diagnostic/context.sh:103:  "${CTX_AGENT_DIR}/target_patch.json" \
agents/recruitment/diagnostic/context.sh:104:  "${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/target_patch.json" ; do
agents/recruitment/diagnostic/context.sh:116:  printf 'context.sh: no target_patch.json found; ICP fit will degrade to "not computable"\n' >&2
agents/recruitment/diagnostic/context.sh:173:printf '[diagnostic context.sh] tenant=%s corpus_id=%s tone_rules=%s recent_edits=%s target_patch=loaded\n' \
docs/specs/ULTRAPLAN.md:609:- **Trigger type:** Broadbean / job-board scraper detects a target-patch company posted via a competitor agency
docs/specs/PRODUCT-SPEC.md:85:- **Output contract (Competitor Interception, real-time):** Within 5 minutes of a target-patch company posting a role through Hudson, Robert Walters, or any other competitor agency: Telegram fires — "Greenstone, you've placed there twice, 3 candidates ready, drafted outreach. Send tonight?"
docs/specs/PRODUCT-SPEC.md:162:- **Per-tenant config:** target-patch definition (shared with Client Hunter), anonymisation rules, fee structure templates per pitch type, do-not-pitch flags per candidate.
docs/specs/PRODUCT-SPEC.md:358:- `common-voice.json` — paths to voice profile, banned phrases, tone rules
docs/specs/PRODUCT-SPEC.md:363:- `common-target-patch.json` — sectors, geography, size, named-company allowlist/blocklist
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:46:## ICP fit vs target_patch
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:48:No target_patch.json loaded for this tenant — cannot score ICP fit.
docs/artefacts/diagnostic-hays-plc-2026-05-24-v2.md:50:Source: [tenant config](vault://target-patch)
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:46:## ICP fit vs target_patch
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:48:No target_patch.json loaded for this tenant — cannot score ICP fit.
docs/artefacts/diagnostic-hays-plc-2026-05-24.md:50:Source: [tenant config](vault://target-patch)

 succeeded in 0ms:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:61:### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:63:**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:69:Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:71:Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:136:- `feedback_voice.md` (type: feedback) — lift from v1's voice rules
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:137:- `feedback_invariants.md` (type: feedback) — the seven non-negotiable invariants from `07-V1-INHERITED-CONTEXT.md` §3
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:82:- "In exchange for founding rate: (a) honest feedback, (b) reference/testimonial willingness after 3 months"
docs/decisions/2026-05-18-codex-ratification-manifest.md:193:> 4. **Claude Code** reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)
docs/decisions/autosend-safety-policy.md:302:3. Operator may file a `false-block` feedback report via Brain UI if the tier classification seems wrong; report becomes input to next policy review
docs/decisions/autosend-safety-policy.md:481:- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
docs/decisions/autosend-safety-policy.md:488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
docs/decisions/autosend-safety-policy.md:603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
docs/decisions/autosend-safety-policy.md:624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
agents/recruitment/scribe/agent.md:313:1. **Tacit-note extraction is the hard part.** Start with small taxonomy (8 categories above); expand based on consultant feedback. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.
docs/decisions/v1.0-kill-criterion.md:109:**Threshold:** More than 3 confirmed red-tier autosend breaches per pilot per week from actions that should have been classified as green or yellow. "Confirmed" means: tenant operator files a `false-block` feedback report via Brain UI (or equivalent v1.0 manual channel) AND IFOS oncall agrees the tier classification was wrong. Threshold measured per individual pilot over rolling 7-day windows.
docs/architecture/second-brain-design.md:716:This is the carry-forward concern from Batch 1 feedback. The risk is real and Obsidian-specific.
docs/operations/codex-ratification-guide.md:20:- `REJECTED` — Codex flags concrete numbered issues. You either incorporate the feedback or write a disagreement doc explaining why Codex is wrong.
agents/recruitment/sourcing-scout/agent.md:209:Measured via consultant feedback loop: each candidate in a Sourcing Scout report gets a "useful / not useful" tag from the consultant via Brain UI v1.1 OR Telegram reply OR Bullhorn note. Aggregate over rolling 30-day window per tenant.
agents/recruitment/sourcing-scout/agent.md:304:| Q4 | Rationale length — 50 words feels short for high-quality match explanation. Bump to 100? | Founder review with first pilot consultant feedback. ULTRAPLAN A5 line 553 says "≥ 50 words" — using as floor. |
agents/recruitment/sourcing-scout/agent.md:305:| Q5 | Gate B 6-of-10 metric — measured via consultant feedback. Brain UI v1.0 doesn't have feedback UX yet. Telegram reply? | v1.0: Telegram reply with "/scout-feedback <candidate-id> useful|not-useful". v1.1: Brain UI button. |
agents/recruitment/sourcing-scout/agent.md:330:- Gate B feedback loop operational (Telegram OR Brain UI)
docs/operations/codex-ratification-execution-plan.md:284:When Codex REJECTS and Claude Code either incorporates feedback OR counter-argues, write to:
docs/operations/codex-ratification-execution-plan.md:389:6. **Codex ratifies this execution plan itself** (item #32) — recursive. Plan is updated based on the run-retro feedback.
docs/operations/codex-ratification-execution-plan.md:425:- **Pre-ratification editorial sweep** — Codex is the editorial review; Claude doesn't pre-clean artefacts hoping Codex won't catch the issue. Honest artefacts in; honest feedback out.
docs/operations/codex-ratification-execution-plan.md:426:- **Custom Codex prompting beyond the SKILL.md** — the skill IS the prompt. If a skill needs tightening based on first-run feedback, update the skill + re-ratify the affected artefacts.
docs/operations/goal-week-3-polish-and-scaffold.md:426:- **§5 Gate B:** <5% incorrect-send rate (per consultant feedback loop) + ≥90% lifecycle-event coverage (no missed transitions).
docs/operations/goal-week-3-polish-and-scaffold.md:430:- **§9 Open questions:** 8-10 covering message template library, lifecycle-event coverage (which events get auto-draft), per-tenant tone-rule customisation, spot-check sample rate, consultant feedback loop.
docs/runbooks/operational-hygiene-protocol.md:331:| 4 | How does this protocol interact with Codex ratification? | Codex reviews against this doc as criteria. If Codex flags a Day-7 artefact for violating §2/§3/§4/§5, that's actionable feedback, not a separate failure mode. |
agents/recruitment/concierge/agent.md:97:attached_documents: <list — e.g., feedback summary, prep guide, comms history>
agents/recruitment/concierge/agent.md:382:- Gate B feedback loop operational (consultant approve/edit distinguishable)
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/delegation-matrix/SKILL.md:49:4. **Agent** applies Codex feedback, opens PR
packages/harness/cortextos/templates/orchestrator/.claude/skills/evening-review/SKILL.md:89:| Learning | Did I apply yesterday's feedback? | |
docs/_supplementary/PRD-autonomous-agent.md:1736:### src/learning/feedback.ts
docs/_supplementary/PRD-autonomous-agent.md:1954:  feedbackNotes?: string;
docs/_supplementary/PRD-autonomous-agent.md:2325:- [ ] Build `src/learning/feedback.ts`
docs/_supplementary/PRD-autonomous-agent.md:2423:│   │   ├── feedback.ts
packages/harness/cortextos/templates/orchestrator/.claude/skills/soul-philosophy/SKILL.md:73:- Use for: user preferences, cross-agent knowledge, system-wide patterns, feedback that applies to everyone.
packages/harness/cortextos/templates/m2c1-worker/.claude/skills/m2c1-worker/SKILL.md:277:cortextos bus send-message <worker-name> normal 'PLAN_REJECTED. Revise: <specific feedback>. Resend when updated.'
docs/build-brief/00-MASTER-BRIEF.md:739:4. **Claude Code** reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)
docs/specs/ULTRAPLAN.md:426:| T3 Compliance Watchtower | Zero compliance deadlines missed in the tenant; <2 false-positive alerts per tenant per month | Decision-log + tenant feedback |
packages/harness/cortextos/dashboard/README.md:30:You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!
docs/_supplementary/build-plan-original.md:169:Threshold: average ≥ 3.5 → passes to human. Below → regenerates once with the rubric failures as feedback. Two failures → flag for manual review, no auto-send.
docs/_supplementary/build-plan-original.md:470:Threshold: avg ≥ 3.8 (higher than other agents because this is the trust-critical one). Below → regenerate with feedback.
docs/_supplementary/build-plan-original.md:1440:- **Reject** — with reason code. Agent retries once with feedback, or flags as unsolvable.
packages/harness/cortextos/community/skills/delegation-matrix/SKILL.md:49:4. **Agent** applies Codex feedback, opens PR
docs/_supplementary/execution-plan.md:231:  - *Prompt:* "Write the LLM-as-Judge Rubric Library: one rubric prompt per agent (10 total including Librarian) following the 0–5 scoring pattern in Build Plan §2.2. Each rubric is a standalone file (`rubrics/{agent-name}.md`) with: the exact grader system prompt, the 4–5 scoring dimensions, the passing threshold, the feedback-on-fail format."
docs/_supplementary/execution-plan.md:605:- **Sales scripts** — need real demo feedback. Do 5 demos with the rough script, rewrite based on objections actually heard.
packages/harness/cortextos/community/skills/evening-review/SKILL.md:90:| Learning | Did I apply yesterday's feedback? | |
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/m2c1-worker/SKILL.md:276:cortextos bus send-message <worker-name> normal 'PLAN_REJECTED. Revise: <specific feedback>. Resend when updated.'
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/soul-philosophy/SKILL.md:65:- Use for: user preferences, cross-agent knowledge, system-wide patterns, feedback that applies to everyone.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/auto-skill/SKILL.md:113:The orchestrator includes it in the next morning briefing for the user. The user replies `approve [skill-name]`, `reject [skill-name] [reason]`, or `revise [skill-name] [feedback]`.
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/auto-skill/SKILL.md:159:# Apply feedback and re-save the draft
packages/harness/cortextos/templates/agent-codex/plugins/cortextos-agent-skills/skills/auto-skill/SKILL.md:161:cortextos bus send-message $CTX_ORCHESTRATOR_AGENT normal "Skill candidate [skill-name] revised per feedback. Ready for re-review."
packages/harness/cortextos/templates/agent/.claude/skills/m2c1-worker/SKILL.md:277:cortextos bus send-message <worker-name> normal 'PLAN_REJECTED. Revise: <specific feedback>. Resend when updated.'
packages/harness/cortextos/dashboard/src/components/agents/agent-actions.tsx:47:  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null);
packages/harness/cortextos/dashboard/src/components/agents/agent-actions.tsx:161:      {feedback && (
packages/harness/cortextos/dashboard/src/components/agents/agent-actions.tsx:164:            feedback.type === 'success' ? 'text-green-600' : 'text-destructive'
packages/harness/cortextos/dashboard/src/components/agents/agent-actions.tsx:167:          {feedback.message}
packages/harness/cortextos/dashboard/src/components/agents/memory-tab.tsx:97:      {/* Save feedback */}
packages/harness/cortextos/templates/agent/.claude/skills/soul-philosophy/SKILL.md:73:- Use for: user preferences, cross-agent knowledge, system-wide patterns, feedback that applies to everyone.
packages/harness/cortextos/templates/agent/.claude/skills/auto-skill/SKILL.md:114:The orchestrator includes it in the next morning briefing for the user. The user replies `approve [skill-name]`, `reject [skill-name] [reason]`, or `revise [skill-name] [feedback]`.
packages/harness/cortextos/templates/agent/.claude/skills/auto-skill/SKILL.md:160:# Apply feedback and re-save the draft
packages/harness/cortextos/templates/agent/.claude/skills/auto-skill/SKILL.md:162:cortextos bus send-message $CTX_ORCHESTRATOR_AGENT normal "Skill candidate [skill-name] revised per feedback. Ready for re-review."
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:4:description: "Write key decisions, project milestones, and feedback rules back to the Obsidian vault. Use this after confirming any architectural decision, project milestone, or durable feedback rule — keeps the vault current with agent memory."
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:10:> Write agent decisions and milestones back to the Obsidian vault so it stays current with agent memory. Use after confirming any significant decision, project milestone, or durable feedback rule.
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:19:- Receive and confirm a durable feedback rule (e.g. "always do X, never do Y")
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:95:### 3. Log a durable feedback rule
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:97:Feedback rules that should persist append to `01-Memory/agent-feedback.md`:
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:101:  path="01-Memory/agent-feedback.md" \
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:105:**Rule:** <The feedback rule>
packages/harness/cortextos/community/skills/obsidian-log/SKILL.md:136:- [ ] Is this a decision, milestone, or feedback rule — not just a task update?
packages/harness/cortextos/community/agents/security/.claude/skills/auto-skill/SKILL.md:114:The orchestrator includes it in the next morning briefing for the user. The user replies `approve [skill-name]`, `reject [skill-name] [reason]`, or `revise [skill-name] [feedback]`.
packages/harness/cortextos/community/agents/security/.claude/skills/auto-skill/SKILL.md:160:# Apply feedback and re-save the draft
packages/harness/cortextos/community/agents/security/.claude/skills/auto-skill/SKILL.md:162:cortextos bus send-message $CTX_ORCHESTRATOR_AGENT normal "Skill candidate [skill-name] revised per feedback. Ready for re-review."
packages/harness/cortextos/community/agents/security/.claude/skills/soul-philosophy/SKILL.md:73:- Use for: user preferences, cross-agent knowledge, system-wide patterns, feedback that applies to everyone.
packages/harness/cortextos/community/agents/security/.claude/skills/m2c1-worker/SKILL.md:277:cortextos bus send-message <worker-name> normal 'PLAN_REJECTED. Revise: <specific feedback>. Resend when updated.'

exec
/bin/zsh -lc "nl -ba docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
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
   108	*End of Codex disagreement document.*

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
/bin/zsh -lc "ls -la agents/recruitment/diagnostic && nl -ba agents/recruitment/diagnostic/tools.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
total 144
drwxr-xr-x@ 10 madsadmin  staff    320 May 24 11:12 .
drwxr-xr-x@  8 madsadmin  staff    256 May 24 10:46 ..
-rw-r--r--@  1 madsadmin  staff   3251 May 22 14:59 README.md
-rw-r--r--@  1 madsadmin  staff  19408 May 24 11:12 agent.md
-rwxr-xr-x@  1 madsadmin  staff   3796 May 23 16:57 cleanup.sh
-rwxr-xr-x@  1 madsadmin  staff   9007 May 24 10:44 context.sh
-rwxr-xr-x@  1 madsadmin  staff  10295 May 24 09:20 cycle.sh
drwxr-xr-x@  5 madsadmin  staff    160 May 23 16:57 fixtures
-rw-r--r--@  1 madsadmin  staff   8111 May 23 16:53 tools.yaml
-rwxr-xr-x@  1 madsadmin  staff  11249 May 24 09:30 validate.sh
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

codex
REJECTED

1. Gate A weakens the ULTRAPLAN A1 source-data requirement. Line 16 and lines 62-67 require only per-section citation coverage, but `docs/specs/ULTRAPLAN.md` lines 496-497 require all 12 sections and “no claims unsupported by source data.” This downgrades a stated Gate A constraint into a W4 polish item. Fix by enforcing claim-level source support in Gate A, or explicitly amend the upstream spec and record the drift.

2. Step 11 performs an external side-effect without a decision-log call. Lines 140-142 send a Telegram notification, while line 73 says every output/action step MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146. Fix by adding a specific `hh_decision_action`/autosend action type for `operator_notify_telegram`, or remove the notification from v1.0.

3. Gate B is mis-mapped to kill-criterion Trigger 8. Line 169 says Diagnostic’s 30% discovery-call conversion feeds Trigger 8, but `docs/decisions/v1.0-kill-criterion.md` lines 158-160 define Trigger 8 as average Gate B revenue uplift after 3 completed pilots. Fix by removing the Trigger 8 claim or adding a separate documented Diagnostic conversion trigger.

4. `_consultant_feedback` is an undocumented sentinel agent name. Line 167 writes Gate B rows with `agent_name='_consultant_feedback'`, but the sentinel catalogue does not register that name; `agents/_shared/escalation-codes.md` only documents existing sentinel patterns such as `_renderer`. Fix by using `agent_name='diagnostic'` with a feedback action type, or register `_consultant_feedback` with payload shape and emit rules.

5. The Gate A claims do not match the present bundle implementation. Lines 156-163 say `validate.sh` hard-fails voice score and PII checks, but `agents/recruitment/diagnostic/validate.sh` lines 153 and 216-217 only warn/skip when the voice classifier URL or firm-domain whitelist is unavailable. Fix the implementation to hard-fail as specified, or amend §5 to honestly state the degraded checks.
tokens used
74,480
REJECTED

1. Gate A weakens the ULTRAPLAN A1 source-data requirement. Line 16 and lines 62-67 require only per-section citation coverage, but `docs/specs/ULTRAPLAN.md` lines 496-497 require all 12 sections and “no claims unsupported by source data.” This downgrades a stated Gate A constraint into a W4 polish item. Fix by enforcing claim-level source support in Gate A, or explicitly amend the upstream spec and record the drift.

2. Step 11 performs an external side-effect without a decision-log call. Lines 140-142 send a Telegram notification, while line 73 says every output/action step MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146. Fix by adding a specific `hh_decision_action`/autosend action type for `operator_notify_telegram`, or remove the notification from v1.0.

3. Gate B is mis-mapped to kill-criterion Trigger 8. Line 169 says Diagnostic’s 30% discovery-call conversion feeds Trigger 8, but `docs/decisions/v1.0-kill-criterion.md` lines 158-160 define Trigger 8 as average Gate B revenue uplift after 3 completed pilots. Fix by removing the Trigger 8 claim or adding a separate documented Diagnostic conversion trigger.

4. `_consultant_feedback` is an undocumented sentinel agent name. Line 167 writes Gate B rows with `agent_name='_consultant_feedback'`, but the sentinel catalogue does not register that name; `agents/_shared/escalation-codes.md` only documents existing sentinel patterns such as `_renderer`. Fix by using `agent_name='diagnostic'` with a feedback action type, or register `_consultant_feedback` with payload shape and emit rules.

5. The Gate A claims do not match the present bundle implementation. Lines 156-163 say `validate.sh` hard-fails voice score and PII checks, but `agents/recruitment/diagnostic/validate.sh` lines 153 and 216-217 only warn/skip when the voice classifier URL or firm-domain whitelist is unavailable. Fix the implementation to hard-fail as specified, or amend §5 to honestly state the degraded checks.
