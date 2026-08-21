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
session id: 019e5a09-0d22-76b1-b384-ce1d1cfad0e7
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

**Status:** Proposed (Day-19; full bundle built — agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures all present; awaits Codex RATIFIED verdict on this agent.md + first production render against pilot tenant. Status flips Proposed → Accepted on Codex RATIFIED. See §10 for the ratification-readiness checklist.)
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

**Gate A hard-fails** (per ADR-006 + §5 spec):

- Fewer than 12 sections present
- Any section with zero citation links (per-section citation subcheck; ADR-006-canonical)
- Section 12 (conversation opener) failing voice-classifier with score < 0.75 *(v0 hard-fail when voice-classifier URL reachable; warn + `validate_check_skipped=true` flag when URL unreachable per §5 honesty note; W4 polish closes to unconditional hard-fail)*
- Output exceeds 2000 words OR is under 400 words (length-discipline boundary)
- PII detected outside firm boundary *(v0 hard-fail when firm-domain whitelist available; warn + `validate_check_skipped=true` flag when whitelist absent per §5 honesty note; W4 polish closes to unconditional hard-fail)*

**Per-step audit-row signatures** (per `decision_log`):
- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier

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
   → hh_decision_output("section_1_data", "firm:<slug>", "companies_house cached:<bool>")

3. Online footprint discovery (Section 2)
   → web HEAD + first 200 lines fetch on probable URLs:
     {firm}.com / {firm}.co.uk / linkedin.com/company/{slug}
   → LinkedIn company-page fetch (Proxycurl or similar)
   → record careers page state + last-updated signal
   → hh_decision_output("section_2_data", "firm:<slug>", "urls_found:<N>")

4. Job posts harvest (Sections 3 + 4 + 5 + 7)
   → LinkedIn job posts API (filtered to firm) — up to 50 most recent
   → careers page scrape if accessible
   → extract: sector, role type, location, salary band, tech stack
   → Gotcha §6: store summarised data only; do not retain raw profiles per LinkedIn ToS
   → hh_decision_output("section_3_4_5_7_data", "firm:<slug>", "posts_harvested:<N>")

5. Director + employee scan (Sections 7 + 11)
   → LinkedIn search for {firm} employees with titles matching head-of-talent / chro / chief people / hiring-manager / talent-acquisition variants
   → record name + URL + tenure + recent activity
   → max 10 named people; deduplicate
   → hh_decision_output("section_7_11_data", "firm:<slug>", "named_people:<N>")

6. Pain signal extraction (Section 8) — internal computation only (no external actions; no decision-log row required per master brief §8.1 Change 2)
   → regex pass over careers-page + LinkedIn director posts (data fetched in Steps 3-4) for:
     - urgency phrases ("rapid growth", "scaling fast", "we need", "tripling", "doubling")
     - frustration phrases (Glassdoor if accessible: "overworked", "burnout", "no support")
     - hiring-pressure phrases ("desperately seeking", "high-priority hire", "must hire by")
   → record each match with quote + source URL + context (in-memory only; folded into Step 10 report assembly)

7. ICP fit scoring (Section 6) — internal computation only
   → load tenant target_patch from common-target-patch.json (read-only; no decision-log row)
   → score each dimension (sectors / geographies / size_bands / deal_size_band)
   → composite score 0-100 + per-dimension breakdown (in-memory only)

8. Recent activity scan (Section 10)
   → LinkedIn company posts in last 90 days (count + first 100 chars of each)
   → basic Google search for "{firm} announcement OR funding OR acquisition" last 90 days
   → Companies House filing history last 90 days
   → hh_decision_output("section_10_data", "firm:<slug>", "activity_items:<N>")

9. Conversation opener generation (Section 12)
   → LLM prompt: context = §1-§11 of the report (esp. §8 pain signals);
                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
                 constraint = tone rules (hh_load_tone_rules)
   → output 2-3 sentences with at least one evidence anchor
   → voice classifier scores the output against tenant style guide
   → ESC_VOICE_DRIFT if score < 0.75 after 3 retries
   → hh_decision_output("section_12_opener", "firm:<slug>", "voice_score:<score>")

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

**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but are NOT written to `decision_log` as separate rows in v0. W4 polish closes these two cases to (a) hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.

- All 12 sections present in the assembled report (count + heading check) — **v0: hard-fails as specified**
- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section) — **v0: hard-fails as specified**
- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
- Report length 400-2000 words — **v0: hard-fails as specified**
- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit — **v0: warns + flags `validate_check_skipped=true` if firm-domain whitelist absent; W4 polish closes to hard-fail**

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
- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
- **`hh_load_recent_edits` last 30 days for `diagnostic`** (single agent_name arg per `voice-loader.sh::hh_load_recent_edits`; current `context.sh` passes `"diagnostic"` only): surfaces patterns of how consultant edits Diagnostic drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies (W3 prerequisites)

Diagnostic build cannot start until ALL of the following are confirmed:

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
I’ll verify the cited local sources and the diagnostic bundle shape before giving the ratification verdict.
exec
/bin/zsh -lc "nl -ba docs/briefs/master-brief.md | sed -n '585,605p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/ULTRAPLAN.md | sed -n '480,505p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
nl: docs/briefs/master-brief.md: No such file or directory

 succeeded in 0ms:
nl: docs/ULTRAPLAN.md: No such file or directory

exec
/bin/zsh -lc 'rg -n "ESC_VOICE_DRIFT|ESC_PII_LEAKAGE_RISK|ESC_RATE_LIMIT_HIT|ESC_INPUT_VALIDATION_FAIL|ESC_AGENT_OUTPUT_SHAPE|ESC_VOICE_DRIFT_TENANT|ESC_RENDERER_FAILED|ESC_BULLHORN_AUTH|ESC_AUTOSEND|ESC_VAULT" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
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
97:#### `ESC_BULLHORN_AUTH`
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
232:- **Trigger:** Agent entered degraded mode (drafts-only, no auto-send) per Ultraplan §3.5; typically downstream of `ESC_BULLHORN_AUTH` or similar
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
342:- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
475:2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)

exec
/bin/zsh -lc 'rg -n "diagnostic_report_render|operator_notify_telegram|consultant_feedback|green|tier" agents/_shared/autosend-policy.yaml agents/_shared/autosend-safety-policy.yaml 2>/dev/null' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:8:# 43 v1.0 action_types: 15 green + 10 yellow + 10 orange + 8 red.
agents/_shared/autosend-policy.yaml:10:#   tier            green|yellow|orange|red
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
agents/_shared/autosend-policy.yaml:102:    tier: green
agents/_shared/autosend-policy.yaml:107:  consultant_feedback:
agents/_shared/autosend-policy.yaml:108:    tier: green
agents/_shared/autosend-policy.yaml:114:    tier: green
agents/_shared/autosend-policy.yaml:124:    tier: yellow
agents/_shared/autosend-policy.yaml:131:    tier: yellow
agents/_shared/autosend-policy.yaml:138:    tier: yellow
agents/_shared/autosend-policy.yaml:145:    tier: yellow
agents/_shared/autosend-policy.yaml:152:    tier: yellow
agents/_shared/autosend-policy.yaml:159:    tier: yellow
agents/_shared/autosend-policy.yaml:166:    tier: yellow
agents/_shared/autosend-policy.yaml:173:    tier: yellow
agents/_shared/autosend-policy.yaml:180:    tier: yellow
agents/_shared/autosend-policy.yaml:187:    tier: yellow
agents/_shared/autosend-policy.yaml:190:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
agents/_shared/autosend-policy.yaml:198:    tier: orange
agents/_shared/autosend-policy.yaml:206:    tier: orange
agents/_shared/autosend-policy.yaml:213:    tier: orange
agents/_shared/autosend-policy.yaml:220:    tier: orange
agents/_shared/autosend-policy.yaml:227:    tier: orange
agents/_shared/autosend-policy.yaml:234:    tier: orange
agents/_shared/autosend-policy.yaml:241:    tier: orange
agents/_shared/autosend-policy.yaml:248:    tier: orange
agents/_shared/autosend-policy.yaml:255:    tier: orange
agents/_shared/autosend-policy.yaml:262:    tier: orange
agents/_shared/autosend-policy.yaml:273:    tier: red
agents/_shared/autosend-policy.yaml:280:    tier: red
agents/_shared/autosend-policy.yaml:287:    tier: red
agents/_shared/autosend-policy.yaml:294:    tier: red
agents/_shared/autosend-policy.yaml:301:    tier: red
agents/_shared/autosend-policy.yaml:308:    tier: red
agents/_shared/autosend-policy.yaml:315:    tier: red
agents/_shared/autosend-policy.yaml:322:    tier: red
agents/_shared/autosend-policy.yaml:333:  approval_timeout: PT4H        # Default orange-tier approval window per §8 rule 5
agents/_shared/autosend-policy.yaml:343:  - "tier ∈ {green, yellow, orange, red}"
agents/_shared/autosend-policy.yaml:347:  - "tenant overrides may only ELEVATE tier (green→yellow→orange→red); red is floor"
agents/_shared/autosend-policy.yaml:348:  - "43 total action_types (15 green + 10 yellow + 10 orange + 8 red); v1.0 frozen as of 2026-05-24 bilateral-disposition extension"

codex
The first two citation paths in the artefact are not present at those names, so I’m locating the authoritative brief and Ultraplan files before deciding whether that is source drift or only path naming.
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
/bin/zsh -lc 'rg -n "hh_load_tone_rules|hh_load_voice_samples|hh_load_recent_edits|hh_decision_output|hh_decision_action|hh_decision_trigger" agents/_shared agents/recruitment/diagnostic' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/diagnostic/cleanup.sh:55:  hh_decision_action "linkedin_cache_purge_fail" "cleanup:${CTX_TENANT_SLUG}" \
agents/recruitment/diagnostic/cleanup.sh:79:hh_decision_action "diagnostic_cleanup" "agent:${CTX_AGENT_NAME:-diagnostic}" \
agents/_shared/autosend-policy.yaml:5:# hh_decision_action() invocation. Per-tenant overrides live in Postgres
agents/recruitment/diagnostic/cycle.sh:102:  hh_decision_action "diagnostic_input_invalid" "firm:${FIRM_NAME}" \
agents/recruitment/diagnostic/cycle.sh:156:  hh_decision_action "diagnostic_generator_empty" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:166:hh_decision_output "diagnostic_draft" "${DRAFT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:183:hh_decision_output "diagnostic_report" "${REPORT_PATH}" \
agents/recruitment/diagnostic/cycle.sh:186:hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
agents/recruitment/diagnostic/cycle.sh:209:    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
agents/_shared/hook-helpers.sh:166:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:168:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:177:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:180:hh_decision_output() {
agents/_shared/hook-helpers.sh:190:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:193:hh_decision_action() {
agents/recruitment/diagnostic/context.sh:25:#   - Emits hh_decision_trigger("session_start", ...) as first audit row
agents/recruitment/diagnostic/context.sh:83:hh_decision_trigger "session_start" "diagnostic agent for firm: ${IFOS_DIAGNOSTIC_FIRM_NAME:-<unset>}" \
agents/recruitment/diagnostic/context.sh:85:    printf 'context.sh: hh_decision_trigger failed; vault may be unwritable\n' >&2
agents/recruitment/diagnostic/context.sh:129:VOICE_CORPUS_JSON=$(hh_load_voice_samples "diagnostic-conversation-opener" 1 2>/dev/null || echo '{}')
agents/recruitment/diagnostic/context.sh:147:CTX_TONE_RULES=$(hh_load_tone_rules "diagnostic" 2>/dev/null || printf '{"rules":[],"source":"empty"}')
agents/recruitment/diagnostic/context.sh:160:CTX_RECENT_EDITS_REF=$(hh_load_recent_edits 30 "diagnostic" 2>/dev/null || printf '{"edits":[],"source":"empty"}')
agents/recruitment/diagnostic/validate.sh:259:  hh_decision_action "validate_gate_a_fail" "draft:${DRAFT}" \
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/voice-loader.sh:223:# hh_load_recent_edits [<lookback_days>] [<agent_name>]
agents/_shared/voice-loader.sh:233:hh_load_recent_edits() {
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
agents/_shared/README.md:14:| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
agents/_shared/README.md:51:hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/README.md:52:hh_decision_output  <output_type> <artefact_ref> [<reason>]
agents/_shared/README.md:53:hh_decision_action  <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/README.md:56:`hh_decision_action` is the **gated** call. Returns `0` if action allowed, `1` if blocked or approval rejected. All three write a `decision_log` row before returning.
agents/_shared/README.md:72:`hh_decision_action` dispatches per tier:
agents/_shared/README.md:101:hh_load_tone_rules    [<agent_name>]                # JSON: { rules: [...], source }
agents/_shared/README.md:102:hh_load_voice_samples <task_context> [<top_k>]      # JSON: { samples: [...], voice_corpus_version, source }
agents/_shared/README.md:103:hh_load_recent_edits  [<lookback_days>] [<agent_name>]  # JSON: { edits: [...], lookback_days, source }
agents/_shared/README.md:106:Each emits exactly one line of JSON to stdout. Live mode (`IFOS_DB_URL` set + `psql` on PATH) issues `SET LOCAL app.current_tenant` + RLS-isolated SELECT against `tone_rule` / `voice_corpus_chunks` (HNSW ANN) / `recent_edit`. Fallback mode returns empty arrays + reason codes; `hh_load_voice_samples` surfaces `style_guide_path` if `/vault/<tenant>/_voice/style-guide.md` exists.
agents/_shared/README.md:108:**`hh_load_voice_samples` query vector:** shell can't generate embeddings. Callers from Python/Node MUST embed the task context first, encode to pgvector literal (e.g. `[0.123,0.456,...]`), and pass via `IFOS_VL_QUERY_VECTOR` env var before invoking. Without it, the helper falls back to the style-guide-only path.
agents/_shared/README.md:120:   bash -c 'source agents/_shared/hook-helpers.sh; hh_decision_trigger "manual_smoke_test"'
agents/_shared/README.md:153:   bash -c 'source agents/_shared/voice-loader.sh; hh_load_tone_rules' | jq .
agents/recruitment/diagnostic/agent.md:71:- Step 10 report assembly → `hh_decision_output("diagnostic_report", "<vault_path>", "12-section report on <firm>")`
agents/recruitment/diagnostic/agent.md:72:- Step 11 (optional) operator notify → `hh_decision_action("operator_notify_telegram", "operator:<chat_id>", payload_hash, payload_preview)` — green tier per autosend-policy.yaml
agents/recruitment/diagnostic/agent.md:73:- Step 12 session close → `hh_decision_action("diagnostic_report_render", "firm:<slug>", payload_hash, payload_preview)` — green tier
agents/recruitment/diagnostic/agent.md:84:   → hh_decision_trigger("session_start", firm_name + sector_hint)
agents/recruitment/diagnostic/agent.md:97:   → hh_decision_output("section_1_data", "firm:<slug>", "companies_house cached:<bool>")
agents/recruitment/diagnostic/agent.md:104:   → hh_decision_output("section_2_data", "firm:<slug>", "urls_found:<N>")
agents/recruitment/diagnostic/agent.md:111:   → hh_decision_output("section_3_4_5_7_data", "firm:<slug>", "posts_harvested:<N>")
agents/recruitment/diagnostic/agent.md:117:   → hh_decision_output("section_7_11_data", "firm:<slug>", "named_people:<N>")
agents/recruitment/diagnostic/agent.md:135:   → hh_decision_output("section_10_data", "firm:<slug>", "activity_items:<N>")
agents/recruitment/diagnostic/agent.md:139:                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
agents/recruitment/diagnostic/agent.md:140:                 constraint = tone rules (hh_load_tone_rules)
agents/recruitment/diagnostic/agent.md:144:   → hh_decision_output("section_12_opener", "firm:<slug>", "voice_score:<score>")
agents/recruitment/diagnostic/agent.md:149:    → hh_decision_output("diagnostic_report", "<path>", "12-section report on {firm}")
agents/recruitment/diagnostic/agent.md:153:      → hh_decision_action("operator_notify_telegram", "operator:{chat_id}", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:158:    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
agents/recruitment/diagnostic/agent.md:177:- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
agents/recruitment/diagnostic/agent.md:179:- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
agents/recruitment/diagnostic/agent.md:215:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
agents/recruitment/diagnostic/agent.md:219:- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
agents/recruitment/diagnostic/agent.md:220:- **`hh_load_recent_edits` last 30 days for `diagnostic`** (single agent_name arg per `voice-loader.sh::hh_load_recent_edits`; current `context.sh` passes `"diagnostic"` only): surfaces patterns of how consultant edits Diagnostic drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
agents/_shared/tests/test-hook-helpers.sh:95:printf '\n[1] hh_decision_trigger writes a phase=trigger row\n'
agents/_shared/tests/test-hook-helpers.sh:98:  hh_decision_trigger "session_start" "boot"
agents/_shared/tests/test-hook-helpers.sh:106:printf '\n[2] hh_decision_output writes a phase=output row\n'
agents/_shared/tests/test-hook-helpers.sh:109:  hh_decision_output "diagnostic_report" "/vault/x/y.md"
agents/_shared/tests/test-hook-helpers.sh:129:printf '\n[4] hh_decision_action — green tier emits action row, rc=0\n'
agents/_shared/tests/test-hook-helpers.sh:132:  hh_decision_action "diagnostic_report_render" "candidate:test" "abc123" "test preview"
agents/_shared/tests/test-hook-helpers.sh:142:printf '\n[5] hh_decision_action — red tier emits gating_failed row, rc=1\n'
agents/_shared/tests/test-hook-helpers.sh:145:  hh_decision_action "xero_payment_initiate" "invoice:42" "def456" "test"
agents/_shared/tests/test-hook-helpers.sh:156:printf '\n[6] hh_decision_action — orange tier with test-mode approve → rc=0\n'
agents/_shared/tests/test-hook-helpers.sh:159:  HH_AWAIT_TEST_MODE=approve hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash1" "preview"
agents/_shared/tests/test-hook-helpers.sh:170:printf '\n[7] hh_decision_action — orange tier with test-mode reject → rc=1\n'
agents/_shared/tests/test-hook-helpers.sh:173:  HH_AWAIT_TEST_MODE=reject hh_decision_action "bullhorn_note_customer_visible" "candidate:s.bowen" "hash2" "preview"
agents/_shared/tests/test-hook-helpers.sh:179:printf '\n[8] hh_decision_action — unknown action_type → ESC_AUTOSEND_POLICY_LOOKUP_FAILED\n'
agents/_shared/tests/test-hook-helpers.sh:182:  hh_decision_action "nonexistent_action" "x" "hash3" "preview"
agents/_shared/tests/test-hook-helpers.sh:270:printf '\n[15] hh_decision_action — yellow tier emits row + may enqueue spot-check\n'
agents/_shared/tests/test-hook-helpers.sh:273:  hh_decision_action "bullhorn_candidate_dedupe" "candidate:foo" "hash9" "preview"
agents/_shared/tests/test-hook-helpers.sh:293:    hh_decision_action "xero_payment_initiate" "invoice:${i}" "hashred${i}" "amount: £100"

exec
/bin/zsh -lc "rg --files | rg -i 'master.*brief|ultraplan|sequencing-target|voice-loader|vertical-schema|v0.2|kill-criterion|ADR-006|ADR-003|ADR-004|tenant-lifecycle|CLAUDE.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
CLAUDE.md
CLAUDE.md.previous
packages/agent-renderer/templates/claude-md-preamble.md
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
agents/_shared/voice-loader.sh
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121942Z-25986/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
agents/_shared/tests/test-voice-loader.sh
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md
docs/decisions/ADR-004-renderer-implementation-deviations.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/sequencing-target.md
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/runbooks/tenant-lifecycle.md
docs/build-brief/00-MASTER-BRIEF.md
docs/specs/ULTRAPLAN.md
logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T120906Z-15808/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122757Z-34820/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/round-3-remediation/docs_verticals_recruitment_migrations_v0-2-to-v0-3-pii-purge-sql.output.md
logs/codex-ratification/round-3-remediation/docs_verticals_recruitment_migrations_v0-1-to-v0-2-sql.output.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121128Z-17565/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121805Z-24288/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122624Z-33390/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121550Z-21533/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122440Z-32123/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
logs/codex-ratification/round-2-autonomous/docs_decisions_v1-0-kill-criterion-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_migrations_v0-2-to-v0-3-pii-purge-sql.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_sequencing-target-md.output.md
logs/codex-ratification/round-2-autonomous/docs_runbooks_tenant-lifecycle-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_migrations_v0-3-to-v0-2-pii-purge-sql.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_ADR-003-agent-bundle-renderer-md.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-v0-2-supplement-yaml.output.md
logs/codex-ratification/round-2-autonomous/docs_verticals_recruitment_vertical-schema-yaml.output.md
packages/harness/cortextos/CLAUDE.md
legacy/v1/NOTES-FROM-CLAUDE.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T121347Z-19674/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
legacy/v1/CLAUDE.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.prompt.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.output.md
logs/codex-ratification/20260524T122200Z-28824/docs_decisions_ADR-006-diagnostic-gate-a-hybrid-md.verdict.txt
packages/harness/cortextos/community/agents/orchestrator/CLAUDE.md
packages/harness/cortextos/community/agents/agentic-crm-assistant/CLAUDE.md
packages/harness/cortextos/templates/analyst/CLAUDE.md
legacy/v1/docs/build-kit/CLAUDE.md
packages/harness/cortextos/community/agents/analyst/CLAUDE.md
packages/harness/cortextos/templates/orchestrator/CLAUDE.md
packages/harness/cortextos/community/agents/agent/CLAUDE.md
packages/harness/cortextos/community/agents/security/CLAUDE.md
packages/harness/cortextos/dashboard/CLAUDE.md
packages/harness/cortextos/templates/agent/CLAUDE.md

exec
/bin/zsh -lc "nl -ba docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md | sed -n '1,180p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/sequencing-target.md | sed -n '1,90p'" in /Users/madsadmin/code/CortexOS
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

codex
The local files confirm the cited master-brief and Ultraplan anchors for the build wave and Gate A text. I’m now checking whether the production bundle implementation matches the `agent.md` claims, since this artefact says the full bundle is already built.
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/cycle.sh | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/validate.sh | sed -n '1,340p'" in /Users/madsadmin/code/CortexOS
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
   104	    '{"escalation_code":"ESC_INPUT_VALIDATION_FAIL","input_field":"firm","input_value_preview":"<malformed>","validation_rule_violated":"min_length_2"}' >/dev/null
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
   158	    '{"escalation_code":"ESC_AGENT_OUTPUT_SHAPE","agent_name":"diagnostic","shape_rule_violated":"non_empty_output","expected_value":"non-empty stdout","actual_value":"empty"}' >/dev/null
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
   182	# Final report output row per agent.md §3 audit-row signature
   183	hh_decision_output "diagnostic_report" "${REPORT_PATH}" \
   184	  "12-section report on ${FIRM_NAME}" >/dev/null
   185	
   186	hh_decision_action "diagnostic_report_render" "firm:${FIRM_SLUG}" \
   187	  "$(shasum "${REPORT_PATH}" | awk '{print $1}')" \
   188	  "$(printf '{"vault_path":"%s","firm_name":"%s","tenant":"%s"}' \
   189	      "${REPORT_PATH}" "${FIRM_NAME}" "${CTX_TENANT_SLUG}")" >/dev/null
   190	
   191	printf '\n\033[1;32mDiagnostic report written:\033[0m %s\n' "${REPORT_PATH}"
   192	
   193	# ────────────────────────────────────────────────────────────────────────
   194	# Step 14 — Optional notify
   195	# ────────────────────────────────────────────────────────────────────────
   196	
   197	if [[ "${NOTIFY_VIA}" == "telegram" ]]; then
   198	  if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_OPERATOR_CHAT_ID:-}" ]]; then
   199	    SUMMARY=$(head -200 "${REPORT_PATH}" | sed 's/[^[:print:][:space:]]//g' | head -c 200)
   200	
   201	    # Emit decision_log row BEFORE the send per agent.md §4 Step 11 spec —
   202	    # operator_notify_telegram is green-tier per autosend-policy.yaml so the
   203	    # send executes regardless; this row records the action for audit.
   204	    NOTIFY_PAYLOAD=$(printf '{"recipient":"operator","chat_id":"%s","report_path":"%s","firm":"%s","summary_len":%d}' \
   205	      "${TELEGRAM_OPERATOR_CHAT_ID}" \
   206	      "${REPORT_PATH}" \
   207	      "${FIRM_NAME}" \
   208	      "${#SUMMARY}")
   209	    hh_decision_action "operator_notify_telegram" "operator:${TELEGRAM_OPERATOR_CHAT_ID}" \
   210	      "$(echo "${NOTIFY_PAYLOAD}" | shasum | awk '{print $1}')" \
   211	      "${NOTIFY_PAYLOAD}" 2>/dev/null || true
   212	
   213	    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
   214	      -d "chat_id=${TELEGRAM_OPERATOR_CHAT_ID}" \
   215	      -d "text=Diagnostic report ready: ${FIRM_NAME} → ${REPORT_PATH}%0A%0A${SUMMARY}..." \
   216	      >/dev/null 2>&1 || \
   217	      printf 'cycle.sh: telegram notify failed (non-fatal)\n' >&2
   218	  else
   219	    printf 'cycle.sh: --notify-via telegram set but credentials missing; skipped\n' >&2
   220	  fi
   221	fi
   222	
   223	# Call cleanup (drop transient LinkedIn cache per ToS gotcha §6.1)
   224	bash "${CTX_AGENT_DIR}/cleanup.sh" 2>/dev/null || true
   225	
   226	exit 0

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/context.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# shellcheck disable=SC2034
     3	#
     4	# Diagnostic agent — context.sh
     5	#
     6	# Status: Proposed (pre-W3-build scaffold; Day-12 author).
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

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/tools.yaml | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
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
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '70,250p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '120,190p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
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

exec
/bin/zsh -lc 'rg -n "validate_gate_a_fail|diagnostic_input_invalid|diagnostic_generator_empty|diagnostic_cleanup|linkedin_cache_purge_fail" agents/_shared/autosend-policy.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
113:  validate_gate_a_fail:

exec
/bin/zsh -lc "nl -ba docs/decisions/v1.0-kill-criterion.md | sed -n '50,90p;130,170p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '24,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    24	
    25	  # ───────────────────────────────────────────────────────────
    26	  # GREEN — auto-send without review (15 action_types)
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
   119	  # ───────────────────────────────────────────────────────────
   120	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '1,280p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Diagnostic — the sales tool
     2	
     3	**Status:** Proposed (Day-19; full bundle built — agent.md + cycle.sh + validate.sh + context.sh + tools.yaml + cleanup.sh + 3 fixtures all present; awaits Codex RATIFIED verdict on this agent.md + first production render against pilot tenant. Status flips Proposed → Accepted on Codex RATIFIED. See §10 for the ratification-readiness checklist.)
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
    62	**Gate A hard-fails** (per ADR-006 + §5 spec):
    63	
    64	- Fewer than 12 sections present
    65	- Any section with zero citation links (per-section citation subcheck; ADR-006-canonical)
    66	- Section 12 (conversation opener) failing voice-classifier with score < 0.75 *(v0 hard-fail when voice-classifier URL reachable; warn + `validate_check_skipped=true` flag when URL unreachable per §5 honesty note; W4 polish closes to unconditional hard-fail)*
    67	- Output exceeds 2000 words OR is under 400 words (length-discipline boundary)
    68	- PII detected outside firm boundary *(v0 hard-fail when firm-domain whitelist available; warn + `validate_check_skipped=true` flag when whitelist absent per §5 honesty note; W4 polish closes to unconditional hard-fail)*
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
    79	Per master brief §8.1 Change 2, every workflow step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
    80	
    81	```
    82	0. Session start — invocation arrives via CLI ifosctl diagnostic
    83	   → context.sh hydrates: voice corpus + tone rules + recent edits + target_patch.json
    84	   → hh_decision_trigger("session_start", firm_name + sector_hint)
    85	
    86	1. Validate input
    87	   → validate.sh checks: firm name non-empty, sector (if provided) in known list,
    88	     tenant_slug present, voice corpus reachable
    89	   → Gate A: hard-fail if any check fails
    90	   → ESC_INPUT_VALIDATION_FAIL if firm name malformed (new code added to catalogue this round)
    91	
    92	2. Companies House lookup (Section 1)
    93	   → companies_house_lookup(firm_name) via Companies House MCP connector
    94	   → cache result for 7 days per gotcha §6 (rate-limit discipline)
    95	   → extract: registration + revenue band + headcount band + directors + share moves
    96	   → ESC_RATE_LIMIT_HIT if Companies House returns 429 (back off 60s, retry once)
    97	   → hh_decision_output("section_1_data", "firm:<slug>", "companies_house cached:<bool>")
    98	
    99	3. Online footprint discovery (Section 2)
   100	   → web HEAD + first 200 lines fetch on probable URLs:
   101	     {firm}.com / {firm}.co.uk / linkedin.com/company/{slug}
   102	   → LinkedIn company-page fetch (Proxycurl or similar)
   103	   → record careers page state + last-updated signal
   104	   → hh_decision_output("section_2_data", "firm:<slug>", "urls_found:<N>")
   105	
   106	4. Job posts harvest (Sections 3 + 4 + 5 + 7)
   107	   → LinkedIn job posts API (filtered to firm) — up to 50 most recent
   108	   → careers page scrape if accessible
   109	   → extract: sector, role type, location, salary band, tech stack
   110	   → Gotcha §6: store summarised data only; do not retain raw profiles per LinkedIn ToS
   111	   → hh_decision_output("section_3_4_5_7_data", "firm:<slug>", "posts_harvested:<N>")
   112	
   113	5. Director + employee scan (Sections 7 + 11)
   114	   → LinkedIn search for {firm} employees with titles matching head-of-talent / chro / chief people / hiring-manager / talent-acquisition variants
   115	   → record name + URL + tenure + recent activity
   116	   → max 10 named people; deduplicate
   117	   → hh_decision_output("section_7_11_data", "firm:<slug>", "named_people:<N>")
   118	
   119	6. Pain signal extraction (Section 8) — internal computation only (no external actions; no decision-log row required per master brief §8.1 Change 2)
   120	   → regex pass over careers-page + LinkedIn director posts (data fetched in Steps 3-4) for:
   121	     - urgency phrases ("rapid growth", "scaling fast", "we need", "tripling", "doubling")
   122	     - frustration phrases (Glassdoor if accessible: "overworked", "burnout", "no support")
   123	     - hiring-pressure phrases ("desperately seeking", "high-priority hire", "must hire by")
   124	   → record each match with quote + source URL + context (in-memory only; folded into Step 10 report assembly)
   125	
   126	7. ICP fit scoring (Section 6) — internal computation only
   127	   → load tenant target_patch from common-target-patch.json (read-only; no decision-log row)
   128	   → score each dimension (sectors / geographies / size_bands / deal_size_band)
   129	   → composite score 0-100 + per-dimension breakdown (in-memory only)
   130	
   131	8. Recent activity scan (Section 10)
   132	   → LinkedIn company posts in last 90 days (count + first 100 chars of each)
   133	   → basic Google search for "{firm} announcement OR funding OR acquisition" last 90 days
   134	   → Companies House filing history last 90 days
   135	   → hh_decision_output("section_10_data", "firm:<slug>", "activity_items:<N>")
   136	
   137	9. Conversation opener generation (Section 12)
   138	   → LLM prompt: context = §1-§11 of the report (esp. §8 pain signals);
   139	                 constraint = consultant voice (hh_load_voice_samples for top-5 ANN match);
   140	                 constraint = tone rules (hh_load_tone_rules)
   141	   → output 2-3 sentences with at least one evidence anchor
   142	   → voice classifier scores the output against tenant style guide
   143	   → ESC_VOICE_DRIFT if score < 0.75 after 3 retries
   144	   → hh_decision_output("section_12_opener", "firm:<slug>", "voice_score:<score>")
   145	
   146	10. Markdown report assembly
   147	    → render report from sections 1-12 using Diagnostic-specific template
   148	    → write to /vault/{tenant_slug}/diagnostic-reports/{firm-slug}-{ISO-date}.md
   149	    → hh_decision_output("diagnostic_report", "<path>", "12-section report on {firm}")
   150	
   151	11. Operator notification (optional, per --notify-via flag)
   152	    → if telegram: send via primitive 5 with report path + executive summary (first 200 chars)
   153	      → hh_decision_action("operator_notify_telegram", "operator:{chat_id}", payload_hash, payload_preview)
   154	      → action tier per autosend-policy.yaml: green (operator-only Telegram; no customer-facing comms)
   155	    → if no flag: silent completion (consultant checks vault) — no decision-log row needed
   156	
   157	12. Session close
   158	    → hh_decision_action("diagnostic_report_render", "firm:{slug}", payload_hash, payload_preview)
   159	    → action tier per autosend-policy.yaml: green (no external send; vault write only)
   160	    → exit code 0
   161	```
   162	
   163	---
   164	
   165	## §5 — Gates
   166	
   167	### Gate A — validate.sh (hard-fail before action)
   168	
   169	Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
   170	
   171	**Per ADR-006 (canonical interpretation of ULTRAPLAN §8.1 A1 line 496 Gate A clause "no claims unsupported by source data"):** Gate A's citation subcheck is per-section hard-fail (every one of the 12 sections has ≥1 evidence link). Per-claim citation analysis is a SEPARATE post-launch quality metric, NOT Gate A — to be authored as a future W4 ADR with schema supplements when the voice-classifier microservice ships + first pilot tenant accumulates ≥30 reports.
   172	
   173	**Honesty note (per bilateral-disposition Cat-5):** the v0 `validate.sh` at `agents/recruitment/diagnostic/validate.sh` implements the per-section citation subcheck as hard-fail today (no warn-only path). It also implements the voice classifier and PII subchecks but **prints warnings and exits 0** when upstream services are unreachable (voice-classifier URL down, firm-domain whitelist absent) — these warnings are visible in stdout but are NOT written to `decision_log` as separate rows in v0. W4 polish closes these two cases to (a) hard-fail behaviour AND (b) explicit `validate_check_skipped` audit rows. The spec below describes the W4-complete contract; the W4 build slice closes the voice + PII gaps. ADR-006 does NOT modify the voice + PII subchecks — only the citation subcheck.
   174	
   175	- All 12 sections present in the assembled report (count + heading check) — **v0: hard-fails as specified**
   176	- Every section has ≥ 1 markdown link (regex `\[.+\]\(.+\)` per section) — **v0: hard-fails as specified**
   177	- Section 12 voice classifier score ≥ 0.75 (`hh_load_voice_samples` returns ANN match + classifier; score computed via tenant's voice classifier per Ultraplan §5.3) — **v0: warns + flags `validate_check_skipped=true` if voice-classifier URL unreachable; W4 polish closes to hard-fail**
   178	- Report length 400-2000 words — **v0: hard-fails as specified**
   179	- No banned phrases per `tone_rule` table (`hh_load_tone_rules` filter) — **v0: hard-fails as specified**
   180	- No PII outside the firm boundary (regex pass for emails/phones that don't match `{firm}.com` or known director email patterns) — fires `ESC_PII_LEAKAGE_RISK` immediately on hit — **v0: warns + flags `validate_check_skipped=true` if firm-domain whitelist absent; W4 polish closes to hard-fail**
   181	
   182	### Gate B — Outcome threshold (success metric, not block)
   183	
   184	Per Ultraplan §8.1 A1: ≥ 30% of Diagnostic reports lead to a discovery call booked within 14 days of generation. Measured by consultant feedback loop — Telegram reply `/diagnostic-feedback <report-id> booked|not-booked` (v1.0) or Brain UI button (v1.1). Aggregated as `decision_log` rows with `agent_name='diagnostic'` + `phase='action'` + `action_type='consultant_feedback'` (registered green-tier action_type per `agents/_shared/autosend-policy.yaml`); outcome metric computed by Gate-B rollup query at the weekly review (not stored as a single `decision_log.payload` field). Sentinel agent_names (`_renderer`, `_tenant_admin`, `_codex_ratifier`) are reserved for system actors — consultant feedback is conceptually Diagnostic's domain (validating Diagnostic's output), so the firing agent_name is `diagnostic` with the registered `consultant_feedback` action_type rather than a new sentinel.
   185	
   186	Gate B is a local leading metric for Diagnostic quality; it does NOT feed any v1.0 kill-criterion trigger directly. (Per bilateral-disposition Cat-3 at `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`: kill-criterion §2 Trigger 8 is revenue uplift after 3 completed pilots, not Diagnostic conversion. A separate agent-specific Trigger 11 may be added in v1.1 if conversion-driven scope cuts become operationally relevant.) Below 30% sustained for 4 weeks → revisit Diagnostic's output quality at next Sunday review.
   187	
   188	---
   189	
   190	## §6 — Escalation codes
   191	
   192	Diagnostic uses these ESC codes from `agents/_shared/escalation-codes.md`:
   193	
   194	| Code | Trigger | Severity | Routing |
   195	|---|---|---|---|
   196	| `ESC_VOICE_DRIFT` | Section 12 voice classifier < 0.75 after 3 retries | warn | operator_chat_id |
   197	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary | **blocking** | operator + ifos_oncall |
   198	| `ESC_RATE_LIMIT_HIT` | Companies House or LinkedIn 429 | warn | operator_chat_id |
   199	| `ESC_INPUT_VALIDATION_FAIL` | Malformed firm name input (Step 1 validation) | warn | operator_chat_id |
   200	| `ESC_AGENT_OUTPUT_SHAPE` | Section count != 12 OR Gate-A per-section citation missing OR generator produced empty stdout (Step 8 fallback) | warn | operator_chat_id |
   201	
   202	Diagnostic does NOT use:
   203	
   204	- `ESC_RENDERER_FAILED` — that code is owned by the `_renderer` sentinel (agent_name='_renderer') per catalogue §2.4; Diagnostic never fires it
   205	- `ESC_BULLHORN_AUTH` — Diagnostic never touches Bullhorn (per sequencing-target.md §2.1)
   206	- `ESC_AUTOSEND_*` — Diagnostic's actions are `diagnostic_report_render` + `operator_notify_telegram` + `consultant_feedback` (all green tier per autosend-policy.yaml)
   207	- `ESC_VAULT_*` — Diagnostic writes to one file per invocation; no concurrent-write contention
   208	
   209	---
   210	
   211	## §7 — Voice + tone constraints
   212	
   213	Section 12 (conversation opener) is voice-classified. The agent integrates with `_shared/voice-loader.sh`:
   214	
   215	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `diagnostic`** — surfaces rules like:
   216	  - No "I hope this finds you well" or other generic openers
   217	  - No salary or commission anchors in cold outreach
   218	  - Specific evidence anchor required (not generic "great company")
   219	- **`hh_load_voice_samples` ANN query against tenant's voice_corpus**: top-5 chunks closest to current task context (cold-outreach-to-recruitment-firm-decision-maker). Feeds LLM prompt as voice exemplars.
   220	- **`hh_load_recent_edits` last 30 days for `diagnostic`** (single agent_name arg per `voice-loader.sh::hh_load_recent_edits`; current `context.sh` passes `"diagnostic"` only): surfaces patterns of how consultant edits Diagnostic drafts. Per-run `ESC_VOICE_DRIFT` fires when the §12 voice classifier score is below 0.75 after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` fires per `escalation-codes.md` ESC_VOICE_DRIFT_TENANT trigger — ≥5 `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7-day window (per the nightly voice-drift cron). Edit-distance metrics are tracked separately for analytics but do NOT fire ESC_VOICE_DRIFT_TENANT directly. v1.1 may add multi-agent edit-history merging (`concierge` + `diagnostic` joint signal); v1.0 is per-agent.
   221	
   222	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   223	
   224	---
   225	
   226	## §8 — Build dependencies (W3 prerequisites)
   227	
   228	Diagnostic build cannot start until ALL of the following are confirmed:
   229	
   230	| Dependency | Source | Status |
   231	|---|---|---|
   232	| Renderer + `_shared/` substrate | Day-8 + Round-3 commits | ✅ Ratified (Round 3) |
   233	| Live VPS migration applied | `bash scripts/run-live-migration.sh` | ✅ Applied Day 12 |
   234	| Tenancy audit passes 12 invariants | `bash scripts/run-tenancy-audit.sh` | ✅ 24/24 invariants verified Day 12 |
   235	| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
   236	| `target_patch.json` for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI (per tenant-lifecycle.md §2) |
   237	| Voice corpus seeded for the first pilot tenant | Pilot onboarding | ⏸ Post-LOI |
   238	| Companies House MCP connector | `packages/mcp-connectors/companies-house/` | ✅ Shipped Day 13; 13/13 tests passing |
   239	| LinkedIn read-only via web-scraper | `packages/utilities/web-scraper/` | ✅ Shipped Day 13; 12/12 tests passing (Proxycurl deferred to W4) |
   240	| Web scraper utility (HEAD + first-N-lines) | `packages/utilities/web-scraper/` | ✅ Shipped Day 13 |
   241	| `validate.sh` Gate A logic (12-section check) | `agents/recruitment/diagnostic/validate.sh` | ✅ Built; per-section subcheck hard-fail per ADR-006; voice + PII subchecks warn-only on upstream-unavailable per §5 honesty note (W4 polish closes) |
   242	| `context.sh` hydration | `agents/recruitment/diagnostic/context.sh` | ✅ Built |
   243	| 3 fixtures with golden outputs | `agents/recruitment/diagnostic/fixtures/` | ✅ Built (01-primary + 02-edge-case + 99-voice-drift-canary) |
   244	| Other bundle files (cycle.sh, tools.yaml, cleanup.sh) | `agents/recruitment/diagnostic/` | ✅ All built |
   245	| Codex ratification of full agent bundle | Post-build via `review-agent-bundle.md` skill | ⚠ 10 rounds attempted; ADR-006 (Accepted) closed Cat-1 Gate A finding; residual mechanical findings tracked in disagreement doc Phase 4-5 |
   246	
   247	**Until ALL ratified items have ⏸ → ✅, W3 build slice does not start.**
   248	
   249	---
   250	
   251	## §9 — Status + open questions
   252	
   253	**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + W3 build slice start.
   254	
   255	**Recommended ratification path:** Author the agent.md draft (this document) Day 11 — frees W3 build to focus on the other 5 bundle files + 3 fixtures, not iterating on output contract under W3 deadline pressure. Founder reviews this draft when convenient; refinements drop in commits between Day 11 and W3 start.
   256	
   257	### Open questions for founder review
   258	
   259	| # | Question | Resolution path |
   260	|---|---|---|
   261	| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
   262	| Q2 | Should §11 (decision-maker map) be a separate section OR rolled into §3 + §4 + §5 + §7 as a sub-row? Currently named as a separate section. | Founder review at agent.md ratification. |
   263	| Q3 | Proxycurl vs alternative LinkedIn API surface? Cost + ToS implications. | Resolved at W3 start before Companies House + LinkedIn MCP connectors authored. Founder + Claude decide together. |
   264	| Q4 | Gate B (30% discovery-call-to-report ratio) measured how? Manual tagging by consultant OR auto-detection via Bullhorn calendar links? | v1.0 manual tagging via Telegram resolution; v1.1 auto-detection. |
   265	| Q5 | What's the "firm-slug" canonical form for the output filename? Companies House registration number? URL-slugified firm name? | Recommend Companies House number for stability; canonical-slug fallback for non-UK firms (v1.1+). |
   266	| Q6 | Should §10 (recent activity) include Glassdoor reviews? ToS implications. | Per gotcha §6 below: caution; default OFF for v1.0; explicit founder enable for v1.1+. |
   267	
   268	### Gotchas (carried forward from Ultraplan §8.1 A1)
   269	
   270	1. **LinkedIn ToS — cannot store profile data beyond the audit.** Profile fetches are cached only for the duration of the report generation (typ. 10-15 min). After report writes to vault, raw profile data is dropped from agent memory + no persistence in Postgres.
   271	2. **Companies House rate limits — cache aggressively.** Free tier is 600 requests per 5-minute window per IP. Cache responses for 7 days per (company_number) key. Pre-emptive 60s backoff on first 429.
   272	3. **Glassdoor scraping — uncertain ToS compatibility.** Default OFF for v1.0. Per Q6 above.
   273	
   274	---
   275	
   276	## §10 — When this document ratifies
   277	
   278	Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
   279	
   280	Status flips to Accepted when:

exec
/bin/zsh -lc "nl -ba agents/recruitment/diagnostic/agent.md | sed -n '276,310p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   276	## §10 — When this document ratifies
   277	
   278	Per `.codex/ratification/review-agent-bundle.md` (skill built Day 19; commit `825ebd4`): this agent.md plus the 5 sibling bundle files plus 3 fixtures ratify as a unit at W3 build end.
   279	
   280	Status flips to Accepted when:
   281	- Codex Round-3+ ratifies the full bundle
   282	- Founder approves §3's 12-section list as canonical
   283	- First production render against the first pilot tenant succeeds (per ADR-003 §4 + ADR-004 Decision 7 audit row)
   284	- Gate B baseline measurement begins (30% target; 4-week window)
   285	
   286	Until then: this document is a forward-looking scaffold. Conservative pre-build clarity — not a binding contract until ratification.
   287	
   288	*End of Diagnostic agent.md draft.*

exec
/bin/zsh -lc 'test -f .codex/ratification/review-agent-bundle.md; echo $?; ls .codex/ratification 2>/dev/null' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
0
SKILL.md
review-agent-bundle.md
review-architecture-decision.md
review-postgres-migration.md
review-schema-change.md

codex
REJECTED

1. Status-flip criteria conflict. Line 3 says status flips Proposed → Accepted “on Codex RATIFIED,” but lines 280-284 add founder approval, first production render, and Gate B baseline as additional acceptance criteria. This violates honest-signal status requirements because the reader cannot tell what RATIFIED actually unlocks. Fix by making line 3 and §10 use the same complete status-flip checklist.

2. Build state is internally inconsistent. Lines 3 and 238-244 say the full bundle and fixtures are built, while lines 228 and 247 say the W3 build slice cannot start until pending items clear, and line 253 says it awaits “W3 build slice start.” This mixes pre-build scaffold language with production-bundle language. Fix by recasting §8 as “production-readiness dependencies” or reverting the document to a true pre-build scaffold.

3. Gate A claims do not match `validate.sh`. Lines 66, 177, and 180 claim skipped voice/PII checks flag `validate_check_skipped=true` and that PII outside the firm boundary fires `ESC_PII_LEAKAGE_RISK`; `validate.sh` lines 153 and 216-220 only print warnings, set no flag, do not check phones, and do not emit a PII escalation on warning. Fix by either implementing the claimed flags/escalations/checks or editing agent.md to state the exact v0 behavior.

4. §4 workflow audit rows are not implemented by the built bundle. Lines 92-144 specify per-step `hh_decision_output` rows for sections 1, 2, 3/4/5/7, 7/11, 10, and 12; `cycle.sh` instead invokes a single generator at lines 146-152 and only writes `diagnostic_draft`, `diagnostic_report`, and `diagnostic_report_render` rows at lines 166-186. For a full bundle, the workflow contract and implementation must match. Fix by either adding the per-step audit rows or rewriting §4 to describe the generator-level implementation.

5. Voice-loader citation overclaims helper behavior. Line 177 says `hh_load_voice_samples` returns “ANN match + classifier,” but `agents/_shared/voice-loader.sh` lines 151-188 only returns voice samples/style-guide fallback; classification is performed separately by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` at lines 139-151. Fix the wording to separate sample retrieval from classifier scoring.
tokens used
69,808
REJECTED

1. Status-flip criteria conflict. Line 3 says status flips Proposed → Accepted “on Codex RATIFIED,” but lines 280-284 add founder approval, first production render, and Gate B baseline as additional acceptance criteria. This violates honest-signal status requirements because the reader cannot tell what RATIFIED actually unlocks. Fix by making line 3 and §10 use the same complete status-flip checklist.

2. Build state is internally inconsistent. Lines 3 and 238-244 say the full bundle and fixtures are built, while lines 228 and 247 say the W3 build slice cannot start until pending items clear, and line 253 says it awaits “W3 build slice start.” This mixes pre-build scaffold language with production-bundle language. Fix by recasting §8 as “production-readiness dependencies” or reverting the document to a true pre-build scaffold.

3. Gate A claims do not match `validate.sh`. Lines 66, 177, and 180 claim skipped voice/PII checks flag `validate_check_skipped=true` and that PII outside the firm boundary fires `ESC_PII_LEAKAGE_RISK`; `validate.sh` lines 153 and 216-220 only print warnings, set no flag, do not check phones, and do not emit a PII escalation on warning. Fix by either implementing the claimed flags/escalations/checks or editing agent.md to state the exact v0 behavior.

4. §4 workflow audit rows are not implemented by the built bundle. Lines 92-144 specify per-step `hh_decision_output` rows for sections 1, 2, 3/4/5/7, 7/11, 10, and 12; `cycle.sh` instead invokes a single generator at lines 146-152 and only writes `diagnostic_draft`, `diagnostic_report`, and `diagnostic_report_render` rows at lines 166-186. For a full bundle, the workflow contract and implementation must match. Fix by either adding the per-step audit rows or rewriting §4 to describe the generator-level implementation.

5. Voice-loader citation overclaims helper behavior. Line 177 says `hh_load_voice_samples` returns “ANN match + classifier,” but `agents/_shared/voice-loader.sh` lines 151-188 only returns voice samples/style-guide fallback; classification is performed separately by `validate.sh` via `IFOS_VOICE_CLASSIFIER_URL` at lines 139-151. Fix the wording to separate sample retrieval from classifier scoring.
